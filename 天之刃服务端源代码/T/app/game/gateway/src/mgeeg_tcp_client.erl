%%%-------------------------------------------------------------------
%%% @author QingliangCn <qing.liang.cn@gmail.com>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 18 Sep 2010 by QingliangCn <qing.liang.cn@gmail.com>
%%%-------------------------------------------------------------------
-module(mgeeg_tcp_client).

-behaviour(gen_server).

-include("mgeeg.hrl"). 

%% API
-export([start_link/2]).

-export([
         init/1, 
         handle_call/3,
         handle_cast/2, 
         handle_info/2, 
         terminate/2, 
         code_change/3
        ]).

-define(state_wait_for_handshaking, wait_for_handshaking).

-define(state_wait_for_authkey, wait_for_authkey).

-define(state_wait_for_enter_map, wait_for_enter_map).

-define(state_init_distribution, state_init_distribution).

-define(state_normal_game, normal_game).

-define(HEARTBEAT_MAX_FAILED_TIME, 8).

-define(LOOP_TICKET, 1000).

-define(FCM_KICK_TIME, 3 * 3600).


-record(state, {
          socket, 
          account, 
          role_id, 
          ip, 
          last_heartbeat_time, 
          heartbeat_failed_time=0, 
          line, 
          last_packet_time,
          sum_packet=0,
          reg_name,
          fsm_state=?state_wait_for_authkey,
          last_fsm_state_time=0 %%最后一次状态改变时间
         }).

-define(OFFLINE_REASON_TCP_CLOSED, 0).

%%%===================================================================

start_link(ClientSocket, Line) ->
    gen_server:start_link(?MODULE, [ClientSocket, Line], [{spawn_opt, [{min_heap_size, 10*1024},{min_bin_vheap_size, 10*1024}]}]).

%%--------------------------------------------------------------------

init([ClientSocket, Line]) ->
    erlang:process_flag(trap_exit, true),
    clear_enter_map_status(),
    case inet:peername(ClientSocket) of
        {ok, {IP, _}} ->
            erlang:put(socket, ClientSocket),
            {ok, #state{socket=ClientSocket, line=Line, ip=IP, last_packet_time=common_tool:now()}};
        {error, Reason} ->
            {stop, inet:format_error(Reason)}
    end.

%%--------------------------------------------------------------------

handle_call(shutdown, _, State) ->
    do_terminate(server_shutdown, State),
    {stop, normal, ok,  State};

handle_call(login_again, _From, State) ->
    do_terminate(login_again, State),
    {stop, normal, ok,  State};

handle_call(Request, From, State) ->
    ?ERROR_MSG("~ts: ~w from ~w", ["未知的call", Request, From]),
    Reply = ok,
    {reply, Reply, State}.

handle_cast(Msg, State) ->
    ?ERROR_MSG("~ts: ~w", ["未知的cast", Msg]),
    {noreply, State}.

%%--------------------------------------------------------------------

do_handle_data(Socket, IP, DataBin, State, Fcm) when Fcm =:= ?state_wait_for_authkey ->
    case do_auth_key(DataBin) of
        {error, Unique, Reason} ->
            ClientSocket = State#state.socket,
            reply_after_auth_failed(ClientSocket, Unique, Reason),
            do_terminate(error_auth_key, State),
            {stop, normal, State};
        {ok, Unique, AccountName, RoleID} ->
            %% 加载角色数据
            db_loader:load_role_data(AccountName, RoleID),
            erlang:put(account_name, AccountName),
            ?DEV("~ts", ["认证成功，等待进入地图请求"]),
            RegName = common_misc:get_role_line_process_name(AccountName),
            case do_login_again(RegName, RoleID) of
                ok ->
                    yes = global:register_name(RegName, self()),
                    common_behavior:send({role_login, RoleID, AccountName, IP}),
                    erlang:put(account_name, AccountName),
                    case init_fcm(AccountName) of
                        ok ->
                            prim_inet:async_recv(Socket, 0, -1),
                            ClientSocket = State#state.socket, 
                            reply_after_auth_succ(ClientSocket, Unique, RoleID),
                            NewState = State#state{account=AccountName, role_id=RoleID, fsm_state=?state_wait_for_enter_map},
                            {noreply, NewState};
                        {error, fcm_kick_off_not_enough_off_time} ->
                            do_terminate(fcm_kick_off_not_enough_off_time, State),
                            {stop, normal, State};
                        {ok, need_fcm, TotalOnlineTime} ->
                            prim_inet:async_recv(Socket, 0, -1),
                            ClientSocket = State#state.socket, 
                            reply_after_auth_succ(ClientSocket, Unique, RoleID),
                            NewState = State#state{account=AccountName, role_id=RoleID, fsm_state=?state_wait_for_enter_map},
                            %% 版署服特殊处理，即玩家没有通过防沉迷，登录游戏即立即提示
                            %% erlang:send_after(1000, erlang:self(), {need_fcm_notify, -99999999}),
                            %% 第一次防沉迷弹出时间
                            erlang:send_after(3600 * 1000, erlang:self(), {need_fcm_notify, TotalOnlineTime + 3600}),
                            case TotalOnlineTime >= 7200 of
                                true ->
                                    mgeeg_packet:packet_encode_send(Socket, ?DEFAULT_UNIQUE, ?SYSTEM, ?SYSTEM_FCM, 
                                                                    #m_system_fcm_toc{info="",total_time=TotalOnlineTime, 
                                                                                      remain_time=10800-TotalOnlineTime});
                                false ->
                                    case TotalOnlineTime >= 3600 of
                                        true ->
                                            mgeeg_packet:packet_encode_send(Socket, ?DEFAULT_UNIQUE, ?SYSTEM, ?SYSTEM_FCM, 
                                                                            #m_system_fcm_toc{info="",total_time=TotalOnlineTime,
                                                                                              remain_time=10800-TotalOnlineTime});
                                        false ->
                                            erlang:send_after((3600 - TotalOnlineTime) * 1000, erlang:self(), {notify_fcm, 3600})
                                    end
                            end,
                            KickTime = ?FCM_KICK_TIME - TotalOnlineTime,
                            %% 满三个小时就干掉这个号
                            erlang:send_after(KickTime * 1000, erlang:self(), fcm_kick_time),
                            {noreply, NewState}
                    end;
                {error, Reason} ->
                    do_terminate(Reason, State),
                    {stop, normal, State}
            end
    end;
do_handle_data(Socket, _IP, DataBin, State, Fcm) when Fcm =:= ?state_wait_for_enter_map ->
    {Unique, _Module, _Method, _} = mgeeg_packet:decode(DataBin),
    #state{socket=ClientSock, role_id=RoleID, line=Line, ip=IP} = State,
    %%进入地图/然后在world中注册角色进程
    map_socket(Line, RoleID, ClientSock, self()),
    case init_role_distribution(Unique, self(), RoleID, Line, IP) of
        ok ->
            prim_inet:async_recv(Socket, 0, -1),
            ?DEV("~ts", ["注册玩家进程完成，等待确认进入地图"]),
            NewState = State#state{fsm_state=?state_init_distribution},
            {noreply, NewState};
        {error, cant_get_role_map} ->
            do_terminate(mgeem_router_not_found, State),
            {stop, normal, State};
        {error,Reason} ->
            do_terminate(Reason, State),
            {stop, normal, State}
    end;
do_handle_data(Socket, _IP, DataBin, State, Fcm) when Fcm =:= ?state_normal_game ->
    #state{sum_packet=SumPacket, line=Line, role_id=RoleID, socket=_Socket} = State,
    {Unique, Module, Method, Record} = mgeeg_packet:decode(DataBin),
    ?DEBUG("~w", [{Unique, Module, Method, Record}]),
    prim_inet:async_recv(Socket, 0, -1),
    case Module =:= ?CHAT of
        true ->
            case erlang:get(chat_pid) of
                undefined ->
                    %% 聊天进程尚未初始化好，先缓存聊天请求
                    case erlang:get(chat_cache) of
                        undefined ->
                            erlang:put(chat_cache, [{Method, Module, RoleID, Record, erlang:self(), Unique}]);
                        List ->
                            erlang:put(chat_cache, [{Method, Module, RoleID, Record, erlang:self(), Unique} | List])
                    end,
                    ok;
                ChatPID ->
                    ChatPID ! {Method, Module, RoleID, Record, erlang:self(), Unique}
            end,
            ok;
        false ->
            %% 当前是否正在切换地图
            case is_enter_map_status() of
                true ->
                    case Module =:= ?MAP andalso (Method =:= ?MAP_ENTER andalso Method =:= ?MAP_TRANSFER)  of
                        true ->
                            ignore;
                        false ->
                            mgeeg_router:router({Unique, Module, Method, Record, RoleID, self(), Line})
                    end;
                false ->
                    case Module =:= ?MAP andalso (Method =:= ?MAP_ENTER andalso Method =:= ?MAP_TRANSFER) of
                        true ->
                            set_enter_map_status(),                
                            mgeeg_router:router({Unique, Module, Method, Record, RoleID, self(), Line});
                        false ->
                            mgeeg_router:router({Unique, Module, Method, Record, RoleID, self(), Line})
                    end
            end
    end,
    NewState = State#state{last_heartbeat_time=common_tool:now(), 
                           heartbeat_failed_time=0, sum_packet=SumPacket+1},
    {noreply, NewState}.

is_enter_map_status() ->
    erlang:get(is_enter_map).
set_enter_map_status() ->
    erlang:put(is_enter_map, true).
clear_enter_map_status() ->
    erlang:put(is_enter_map, false).

%% 处理防沉迷请求结果,httpc发起的
handle_info({http, {_, FcmHttpResult}}, #state{account=AccountName, socket=Socket} = State) ->
    ?ERROR_MSG("~p", [FcmHttpResult]),
    case FcmHttpResult of
        {Succ, _, Result} ->
            case Succ of
                {_, 200, "OK"} ->
                    Result2 = common_tool:to_integer(Result),
                    case common_fcm:get_fcm_validation_tip(Result2) of
                        true ->
                            %% 通知客户端结果
                            R = #m_system_set_fcm_toc{succ=true},
                            common_fcm:set_account_fcm(AccountName),
                            ok;
                        {false, Reason} ->
                            R = #m_system_set_fcm_toc{succ=false, reason=Reason}
                    end,
                    mgeeg_packet:packet_encode_send(Socket, ?DEFAULT_UNIQUE, ?SYSTEM,
                                                        ?SYSTEM_SET_FCM, R),
                    ok;
                _ ->
                    ?ERROR_MSG("~ts:~p", ["请求平台验证防沉迷出错", Succ]),
                    R = #m_system_set_fcm_toc{succ=false, reason=?_LANG_FCM_SYSTEM_ERROR_WHEN_REQUEST_PLATFORM},
                    mgeeg_packet:packet_encode_send(Socket, ?DEFAULT_UNIQUE, ?SYSTEM,
                                                        ?SYSTEM_SET_FCM, R)
            end;
        _ ->
            R = #m_system_set_fcm_toc{succ=false, reason=?_LANG_FCM_SYSTEM_ERROR_WHEN_REQUEST_PLATFORM},
            mgeeg_packet:packet_encode_send(Socket, ?DEFAULT_UNIQUE, ?SYSTEM,
                                                ?SYSTEM_SET_FCM, R)
    end,
    {noreply, State};

handle_info({inet_async, Socket, _Ref, {ok, Data}}, #state{ip=IP, fsm_state=FSM} = State) ->
    Rtn = do_handle_data(Socket, IP, Data, State, FSM),    
    Rtn;
handle_info({inet_async, _Socket, _Ref, {error, closed}}, State) ->
    case State#state.fsm_state of
        ?state_normal_game ->
            erlang:put(offline_status, true),
            erlang:send_after(10 * 1000, erlang:self(), real_offline),
            {noreply, State};
        _ ->
            do_terminate(tcp_closed, State),
            {stop, normal, State}
    end;
    
handle_info({inet_async, _Socket, _Ref, {error, Reason}}, State) ->
    ?ERROR_MSG("~ts:~w", ["Socket出错", Reason]),
    do_terminate(tcp_error, State),
    {stop, normal, State};

handle_info(real_offline, State) ->
    do_terminate(tcp_closed, State),
    {stop, normal, State};

handle_info({notify_fcm, TotalOnlineTime}, #state{account=AccountName, socket=Socket} = State) ->
    case db:dirty_read(?DB_FCM_DATA, common_tool:to_binary(AccountName)) of
        [#r_fcm_data{passed=true}] ->
            ignore;
        _ ->
            erlang:send_after(3600 * 1000, erlang:self(), {notify_fcm, TotalOnlineTime + 3600}),
            DataRecord = #m_system_fcm_toc{total_time=TotalOnlineTime, info="", remain_time=10800-TotalOnlineTime},
            mgeeg_packet:packet_encode_send(Socket, ?DEFAULT_UNIQUE, ?SYSTEM,
                                                ?SYSTEM_FCM, DataRecord)
    end,
    {noreply, State};        

%% 通知客户端显示一个防沉迷的提示界面出来
handle_info({need_fcm_notify, TotalOnlineTime}, #state{account=AccountName, socket=Socket} = State) ->
    case TotalOnlineTime =:= -99999999 of
        true ->
            DataRecordOne = #m_system_need_fcm_toc{remain_time=0},
            mgeeg_packet:packet_encode_send(Socket, ?DEFAULT_UNIQUE, ?SYSTEM,?SYSTEM_NEED_FCM, DataRecordOne);
        _ ->
            case db:dirty_read(?DB_FCM_DATA, common_tool:to_binary(AccountName)) of
                [#r_fcm_data{passed=true}] ->
                    ignore;
                _ ->
                    erlang:send_after(1200 * 1000, erlang:self(), {need_fcm_notify, TotalOnlineTime + 1200}),
                    DataRecord = #m_system_need_fcm_toc{remain_time=TotalOnlineTime},
                    mgeeg_packet:packet_encode_send(Socket, ?DEFAULT_UNIQUE, ?SYSTEM,
                                                    ?SYSTEM_NEED_FCM, DataRecord)
            end
    end,
    {noreply, State};
handle_info(fcm_kick_time, #state{account=AccountName} = State) ->
    %%判断玩家是否通过了防沉迷，没有则直接T下线
    [FcmData] = db:dirty_read(?DB_FCM_DATA, common_tool:to_binary(AccountName)),
    #r_fcm_data{passed=Passed} = FcmData,
    %%踢玩家下线时先判断防沉迷是否已经打开了
    case Passed andalso common_config:is_fcm_open() of
        true ->
            {noreply, State};
        false ->            
            do_terminate(fcm_kick_off, State),
            {stop, normal, State}
    end;

handle_info(loop, State) ->
    #state{last_packet_time=LastPacketTime, last_heartbeat_time=LastHeartbeatTime} = State,
    DifTime = common_tool:now() - LastPacketTime,
    %% 一定时间内如果收不到玩家的心跳包，则直接踢掉玩家
    case common_tool:now() - LastHeartbeatTime > 60 of
        true ->
            do_terminate(no_heartbeat, State),
            {stop, normal, State};
        false ->
            case DifTime > 10  of
                true ->
                    %%检查玩家平均发包速度
                    SumPacket = State#state.sum_packet,
                    case SumPacket / DifTime > 18 of
                        true ->
                            do_terminate(too_many_packet, State),
                            {stop, normal, State};
                        false ->
                            erlang:send_after(?LOOP_TICKET, self(), loop),
                            {noreply, State#state{sum_packet=0, last_packet_time=common_tool:now()}}
                    end;
                false ->
                    erlang:send_after(?LOOP_TICKET, self(), loop),
                    {noreply, State}
            end
    end;

handle_info({message, Unique, Module, Method, DataRecord}, #state{socket=Socket} = State) ->
    case erlang:get(offline_status) of
        true ->
            {noreply, State};
        _ ->
            ?DEBUG("~w", [{message, Unique, Module, Method, DataRecord}]),
            case catch  mgeeg_packet:packet_encode(Unique, Module, Method, DataRecord) of
                {'EXIT', Error} ->
                    ?ERROR_MSG("~ts:~w ~w", ["编码数据包出错", Error, {Module, Method, DataRecord}]),
                    {noreply, State};
                Bin ->
                    case erlang:is_port(Socket) of
                        true ->
                            erlang:port_command(Socket, Bin),
                            {noreply, State};
                        false ->
                            do_terminate(tcp_closed, State),
                            {stop, normal, State}
                    end
            end
    end;

handle_info({binary, Bin},  #state{socket=Socket} = State) ->
    case erlang:get(offline_status) of
        true ->
            {noreply, State};
        _ ->
            case erlang:is_port(Socket) of
                true ->
                    erlang:port_command(Socket, Bin),
                    {noreply, State};
                false ->
                    do_terminate(tcp_error, State),
                    {stop, normal, State}
            end
    end;

handle_info({binaries, Bins},  #state{socket=Socket} = State) ->
    case erlang:get(offline_status) of
        true ->
            {noreply, State};
        _ ->
            case erlang:is_port(Socket) of
                true ->
                    [begin
                         erlang:port_command(Socket, Bin)
                     end || Bin <- Bins],
                    {noreply, State};
                false ->
                    do_terminate(tcp_error, State),
                    {stop, normal, State}
            end
    end;

handle_info({inet_reply, _Sock, ok}, State) ->
    {noreply, State};

handle_info({inet_reply, _Sock, Result}, State) ->
    ?ERROR_MSG("~ts:~p", ["socket发送结果", Result]),
    do_terminate(tcp_send_error, State),
    {stop, normal, State};

handle_info({chat_process, PID, ChannelList}, State) ->
    SuccDataRecord =  #m_chat_auth_toc{succ=true, 
                                       channel_list=ChannelList, 
                                       black_list=[], 
                                       gm_auth=[]},
    Socket = erlang:get(socket),
    case catch mgeeg_packet:packet_encode(?DEFAULT_UNIQUE, ?CHAT, ?CHAT_AUTH, SuccDataRecord) of
        {'EXIT', Error} ->
            ?ERROR_MSG("~ts:~w ~w", ["编码数据包出错", Error, {?CHAT, ?CHAT_AUTH, SuccDataRecord}]);
        Bin ->
            case erlang:is_port(Socket) of
                true ->
                    erlang:port_command(Socket, Bin, [force]);
                false ->
                    ignore
            end
    end,
    erlang:put(chat_pid, PID),
    case erlang:get(chat_cache) of
        undefined ->
            ingnore;
        List ->
            list:foreach(
              fun(M) ->
                      PID ! M
              end, List)
    end,
    {noreply, State};

handle_info(start, #state{socket=Socket} = State) ->
    prim_inet:async_recv(Socket, 0, -1),
    {noreply, State};

handle_info({router_to_map, Msg}, State) ->
    case erlang:get(map_pid) of
        undefined ->
            ignore;
        PID ->
            PID ! Msg
    end,
    {noreply, State};

handle_info({sure_enter_map, MapPID}, State) ->
    case erlang:get(map_pid) of
        undefined ->            
            erlang:put(map_pid, MapPID),
            prim_inet:async_recv(State#state.socket, 0, -1),
             case common_config:is_debug() of
                true ->
                    ok;
                false ->
                    erlang:send_after(?LOOP_TICKET, self(), loop)
            end;
        _ ->
            erlang:put(map_pid, MapPID),
            prim_inet:async_recv(State#state.socket, 0, -1),
            ignore
    end,
    clear_enter_map_status(),
    case State#state.fsm_state =:= ?state_init_distribution of
        true ->            
            NewState = State#state{fsm_state=?state_normal_game, last_heartbeat_time=common_tool:now(), last_packet_time=common_tool:now()},
            {noreply, NewState};
        false ->
            {noreply, State}
    end;

handle_info({enter_map_failed, _}, State) ->
    ?ERROR_MSG("~ts", ["玩家进入地图失败，原因：地图无法启动"]),
    do_terminate(enter_map_failed, State),
    {stop, normal, State};

%%后台的踢人接口
handle_info({kick_by_admin},State)->
    do_terminate(admin_kick,State),
    {stop,normal,State};

handle_info({'EXIT', _, role_map_process_not_found}, State) ->
    do_terminate(role_map_process_not_found, State),
    {stop, normal, State};

handle_info({'EXIT', _, Reason}, State) ->
    do_terminate(Reason, State),
    {stop, normal, State};

handle_info(Info, State) ->
    ?ERROR_MSG("~ts:~w", ["未知的消息", Info]),
    {noreply, State}.

%%--------------------------------------------------------------------

terminate(Reason, State) ->
    case get(already_do_terminate) of
        true ->
            ignore;
        _ ->
            do_terminate(Reason, State)
    end,
    ok.

do_terminate(Reason, State) ->
    #state{socket=Socket, role_id=RoleID, reg_name=RegName, ip=_IP, line=Line, fsm_state=FsmState} = State,
    Account = erlang:get(account_name),
    case RegName of
        undefined ->
            ignore;
        _ ->
            global:unregister_name(RegName)
    end,       
    case Account of
        undefined ->
            ignore;
        _ ->
            %% 通知聊天
            catch global:send(mgeec_client_manager, {offline, Account, RoleID})
    end,
    case Reason =:= tcp_closed of
        true ->
            case Account of
                undefined ->
                    ok;
                _ ->
                    common_general_log_server:log_user_offline(#r_user_offline{account_name=Account, 
                                                                               offline_time=common_tool:now(),
                                                                               offline_reason_no=?OFFLINE_REASON_TCP_CLOSED})
            end;
        false ->
            case  common_line:get_exit_info(Reason) of
                {_, {ErrorNo, ErrorInfo}} ->
                    case ErrorNo of
                        10017 ->
                            [#r_fcm_data{offline_time=OffLineTime}] = db:dirty_read(?DB_FCM_DATA, common_tool:to_binary(Account)),
                            OffLineTimeTotal = common_tool:now() - OffLineTime,
                            NeedTime = 5 * 3600 - OffLineTimeTotal,
                            Hour = NeedTime div 3600,
                            Min = (NeedTime rem 3600) div 60,
                            ErrorInfo2 = io_lib:format("您的累计下线时间不满5小时，为了保证您能正常游戏，请您稍后登陆。还需要等待~p时~p分", [Hour, Min]);
                        _ ->
                            ErrorInfo2 = ErrorInfo
                    end,
                    %% 通知客户端退出的原因
                    kick_role(ErrorNo, ErrorInfo2, Socket),
                    case Account of
                        undefined ->
                            ignore;
                        _ ->
                            common_general_log_server:log_user_offline(#r_user_offline{account_name=Account, 
                                                                                       offline_time=common_tool:now(),
                                                                                       offline_reason_no=ErrorNo})
                    end;
                false ->
                    ?ERROR_MSG("~ts:~p ~w", ["网关账号退出原因异常", Reason, erlang:get_stacktrace()])
            end            
    end,    
    %% 等待1秒钟，尽可能的让socket中的数据发送完成，socket不用关闭了，本进程退出后会自动关闭
    timer:sleep(1000),
    %% 移出在线列表
    remove_online(RoleID),
    case FsmState of 
        ?state_normal_game ->
            NameB = mgeeg_broadcast:process_name(Line),
            case global:whereis_name(NameB) of
                undefined ->
                    ignore;
                PIDB ->
                    PIDB ! {erase, RoleID, self()}
            end,
            NameU = mgeeg_unicast:process_name(Line),
            case global:whereis_name(NameU) of
                undefined ->
                    ignore;
                PIDU ->
                    PIDU ! {erase, RoleID, self()}
            end,
            mgeeg_role_sock_map ! {erase, RoleID, self()},            
            OnlineTime = common_tool:now() - erlang:get(login_time),
            case common_config:is_fcm_open() of
                true ->
                    case db:dirty_read(?DB_FCM_DATA, common_tool:to_binary(Account)) of
                        [] ->
                            db:dirty_write(?DB_FCM_DATA,  #r_fcm_data{offline_time=common_tool:now(), account=Account, 
                                                                      passed=false,
                                                                      total_online_time=OnlineTime}),
                            ok;
                        %%防沉迷，记录下线时间
                        [#r_fcm_data{total_online_time=TotalOnlineTime, passed=Passed} = FcmData] ->
                            case Passed of
                                true ->
                                    ignore;
                                false ->                            
                                    catch db:dirty_write(?DB_FCM_DATA, FcmData#r_fcm_data{offline_time=common_tool:now(), 
                                                                                          total_online_time=TotalOnlineTime + OnlineTime})
                            end
                    end;
                false ->
                    ignore
            end;
        ?state_wait_for_handshaking ->
            ?ERROR_MSG("~ts", ["退出时尚未发出握手请求"]),
            ok;
        ?state_wait_for_authkey ->
            ?ERROR_MSG("~ts", ["退出时尚未发出auth_key请求"]),
            ok;
        ?state_wait_for_enter_map ->
            ?ERROR_MSG("~ts", ["退出时尚未发出enter_map请求"]),
            ok;
        ?state_init_distribution ->
            ?ERROR_MSG("~ts", ["退出时已经收到enter_map请求，但是没有分线进程还没确认进入地图，可能是进入地图时出错"])
    end,
    put(already_do_terminate, true),
    ok.

%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%==================================================================

%% 验证key
do_auth_key(Bin) ->
    case mgeeg_packet:decode(Bin) of
        {Unique, _Module, _Method, #m_auth_key_tos{account_name=Account, key=Key, role_id=RoleID}} = R ->
            ?DEV("~w", [R]),
            case gen_server:call({global, mgeel_key_server}, 
                                 {auth_key,  erlang:list_to_binary(Account), RoleID, Key}) of
                ok ->         
                    {ok, Unique, Account, RoleID};
                {error, Msg} ->
                    {error, Unique, Msg}
            end;
        _Other -> 
            {error, ?DEFAULT_UNIQUE, ?_LANG_AUTH_WRONG_PACKET}
    end.


%%帐号认证成功之后发给客户端的信息
reply_after_auth_succ(ClientSocket, Unique, RoleID) ->
    RoleDetail = common_misc:get_role_detail(RoleID),
    RoleDetail2 = do_role_exit_exception(RoleDetail),
    #p_role{base=RoleBase1,attr=RoleAttr1,pos=RolePos1} = RoleDetail2,
    case RoleAttr1#p_role_attr.level =:= 0 of
        true ->
            RoleAttr2 = RoleAttr1#p_role_attr{level=1},
            db:transaction(fun() -> db:write(?DB_ROLE_ATTR, RoleAttr2, write) end);            
        false ->
            RoleAttr2 = RoleAttr1
    end,
    
    RolePos3 = mgeeg_map_handler:update_map_info(RoleID,RoleBase1,RoleAttr2,RolePos1),
    RoleDetail3 = RoleDetail2#p_role{pos=RolePos3, attr=RoleAttr2},
    Bags = common_bag2:get_role_all_bags(RoleID),
    FamilyID = (RoleDetail#p_role.base)#p_role_base.family_id,
    case FamilyID > 0 of
        true ->
            [FamilyInfo] = db:dirty_read(?DB_FAMILY, FamilyID);
        false ->
            FamilyInfo = undefined
    end,

    DataRecord= #m_auth_key_toc{succ=true,  bags=Bags, role_details=RoleDetail3, family=FamilyInfo, server_time=common_tool:now()},
    mgeeg_packet:send(ClientSocket, Unique, ?AUTH, ?AUTH_KEY, DataRecord),

    case common_config:is_client_stat_open() of
        true->
            %%发送统计开关的消息
            RecordStat = #m_stat_config_toc{is_open=true},
            mgeeg_packet:send(ClientSocket, Unique, ?STAT, ?STAT_CONFIG, RecordStat);
        _ ->
            ignore
    end.


%%帐号认证失败，发给客户端的信息
reply_after_auth_failed(ClientSocket, Unique, Reason) ->
    Rtn = #m_auth_key_toc{succ=false, reason=Reason},
    mgeeg_packet:packet_encode_send(ClientSocket, Unique, ?AUTH, ?AUTH_KEY, Rtn).


%%映射socket
map_socket(Line, RoleID, ClientSock, PID)->
    NameB = mgeeg_broadcast:process_name(Line),
    global:send(NameB, {role, RoleID, PID, ClientSock}),
    NameU = mgeeg_unicast:process_name(Line),
    global:send(NameU, {role, RoleID, PID, ClientSock}),
    mgeeg_role_sock_map ! {role, RoleID, PID, ClientSock}.


%% 获取角色的一些信息发往地图，在这里处理是希望尽量把一些可能堵塞的操作从地图转移到分线中来
get_role_info(RoleID) ->
    RoleDetail = common_misc:get_role_detail(RoleID),
    RoleConloginReward = common_misc:get_role_conlogin_reward(RoleID),
	case db:dirty_read(?DB_ROLE_ACCUMULATE_P, RoleID) of
		[] ->
			AccumulateInfo = undefined;
		[AccumulateInfo] ->
			ok
	end,
    case db:dirty_read(?DB_ROLE_VIP_P, RoleID) of
        [] ->
            VipInfo = undefined;
        [VipInfo] ->
            ok
    end,
    case db:dirty_read(?DB_ROLE_HERO_FB_P, RoleID) of
        [] ->
            HeroFBInfo = undefined;
        [HeroFBInfo] ->
            ok
    end,
    case db:dirty_read(?DB_ROLE_MONSTER_DROP_P, RoleID) of
        [] ->
            DropInfo = undefined;
        [#r_role_monster_drop{kill_times=[]}] ->
            db:dirty_delete(?DB_ROLE_MONSTER_DROP_P, RoleID),
            DropInfo = undefined;
        [DropInfo] ->
            ok
    end,
    case db:dirty_read(?DB_ROLE_BOX_P, RoleID) of
        [] ->
            RefiningBoxInfo = undefined;
        [RefiningBoxInfo] ->
            ok
    end,
    case db:dirty_read(?DB_ROLE_ACHIEVEMENT_P, RoleID) of
        [] ->
            AchievementInfo = undefined;
        [AchievementInfo] ->
            ok
    end,
    #p_role{base=RoleBase, ext=RoleExt, fight=RoleFight,attr=RoleAttr, pos = RolePos} = RoleDetail,
    if RoleBase#p_role_base.status =:= ?ROLE_STATE_DEAD ->
            RoleBase2 = RoleBase#p_role_base{status=?ROLE_STATE_NORMAL};
       true ->
            RoleBase2 = RoleBase
    end,
    OffLineTime = {RoleExt#p_role_ext.last_offline_time div 1000000, 
                    RoleExt#p_role_ext.last_offline_time rem 1000000, 0},
    {OffLineDate, _} = calendar:now_to_local_time(OffLineTime),
    Now = common_tool:now(),
    NowDate = common_time:time_to_date(Now),
    #p_role{fight=RoleFight} = RoleDetail,
    RoleFight2 = init_role_energy(RoleFight, Now, NowDate),
    RoleDetail2 =
        case NowDate =:= OffLineDate of
            true ->
                RoleDetail#p_role{fight=RoleFight2, base=RoleBase2};
            false ->
                common_letter:init_role_letter(RoleID),
                notify_attr_change(RoleID),
                RoleDetail#p_role{fight=RoleFight2, base=RoleBase2,pos = RolePos,
                                  attr=init_role_attr(RoleID,RoleAttr)}
        end,
    case (RoleDetail2#p_role.base)#p_role_base.team_id =/= 0 of
        true ->
            RoleTeamInfo = #r_role_team{role_id = RoleID,team_id = (RoleDetail2#p_role.base)#p_role_base.team_id};
        _ ->
            RoleTeamInfo = #r_role_team{role_id = RoleID}
    end,
    if 
        VipInfo =:= undefined ->
            VipLevel = 0;
        VipInfo#p_role_vip.is_expire ->
            VipLevel = 0;
        true ->
            VipLevel = VipInfo#p_role_vip.vip_level
    end,
    RoleMapInfo = get_role_map_info_by_role_detail(RoleDetail2),
    RoleMapInfo2 = RoleMapInfo#p_map_role{vip_level=VipLevel},
    
    case db:dirty_read(?DB_PET_TRAINING_P,RoleID) of
        []->
            PetTrainingInfo = #r_pet_training{role_id=RoleID,
                                              pet_training_list=[]};
        [PetTrainingInfo]->
            ok
    end,
    MapExtInfo = #r_role_map_ext{buy_back_goods=[],training_pets=PetTrainingInfo},
    case db:dirty_read(?DB_ROLE_SKILL_P, RoleID) of
        [] ->
            SkillList = [];
        [#r_role_skill{skill_list = SkillList}] ->
            ok
    end,
    %%====获取任务相关数据 - START=====
    %%TODO 从数据库获取数据
    case db:dirty_read(?DB_MISSION_DATA_P, RoleID) of
        [] ->
            MissionData = #mission_data{last_store_time=common_tool:now()};
        [MissionDBData] ->
            MissionData = (MissionDBData#r_db_mission_data.mission_data)#mission_data{last_store_time=common_tool:now()}
    end,
    %%====获取任务相关数据 - END=====
    [RoleGoalInfo] = db:dirty_read(?DB_ROLE_GOAL_P, RoleID),
    {RoleMapInfo2, RoleDetail2, 
     RoleConloginReward, AccumulateInfo, VipInfo,
     MissionData, HeroFBInfo, DropInfo,RefiningBoxInfo, RoleGoalInfo,AchievementInfo,RoleTeamInfo,MapExtInfo,SkillList}.


init_role_energy(RoleFight, Now, NowDate) when is_record(RoleFight,p_role_fight)->
    #p_role_fight{role_id=RoleID, energy=Energy, energy_remain=EnergyRemain, time_reset_energy=TimeReset} = RoleFight,
    NowDays = calendar:date_to_gregorian_days(NowDate),
    ResetDate = common_time:time_to_date(TimeReset),
    ResetDays = calendar:date_to_gregorian_days(ResetDate),

    case NowDate =:= ResetDate of
        true ->
            RoleFight;
        _ ->
            EnergyRemain2 = Energy + EnergyRemain + (NowDays-ResetDays-1) * ?DEFAULT_ENERGY,
            case EnergyRemain2 >= ?MAX_REMAIN_ENERGY of
                true ->
                    EnergyRemain3 = ?MAX_REMAIN_ENERGY;
                _ ->
                    EnergyRemain3 = EnergyRemain2
            end,

            RoleFight2 = RoleFight#p_role_fight{energy=?DEFAULT_ENERGY, energy_remain=EnergyRemain3, time_reset_energy=Now},
            db:dirty_write(?DB_ROLE_FIGHT, RoleFight2),
            
            ChangeAttList = [#p_role_attr_change{change_type=?ROLE_ENERGY_CHANGE, new_value=?DEFAULT_ENERGY},
                             #p_role_attr_change{change_type=?ROLE_ENERGY_REMAIN_CHANGE, new_value=EnergyRemain3}],
            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttList),
            RoleFight2
    end.


%%隔天登陆时重置玩家活跃度
init_role_attr(_RoleID,RoleAttr) when is_record(RoleAttr,p_role_attr)->
    RoleAttr2 = RoleAttr#p_role_attr{active_points=0},
    db:dirty_write(?DB_ROLE_ATTR, RoleAttr2),
    RoleAttr2.

%%@doc 通知前端更新玩家属性值
notify_attr_change(RoleID) when is_integer(RoleID)->
    ChangeAttList = [#p_role_attr_change{change_type=?ROLE_ACTIVE_POINTS_CHANGE,new_value=0}],
    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttList).

get_role_map_info_by_role_detail(RoleDetail) ->
    #p_role{base=RoleBase, fight=RoleFight, pos=RolePos, attr=RoleAttr} = RoleDetail,
    #p_role_base{role_id=RoleID, role_name=RoleName, faction_id=FactionID, team_id=TeamID, family_id=FamilyID,
                 family_name=FamilyName, max_hp=MaxHP, max_mp=MaxMP, move_speed=MoveSpeed, cur_title=CurTitle,
                 cur_title_color=Color, pk_points=PkPoint, if_gray_name=IfGrayName, buffs=Buffs, status=State} = RoleBase,
    #p_role_attr{level=Level, skin=Skin, show_cloth=ShowCloth, show_equip_ring=ShowEquipRing, equips=Equips} = RoleAttr,
    #p_role_pos{pos=Pos} = RolePos,
    #p_role_fight{hp=HP, mp=MP} = RoleFight,
    {ok, EquipRingColor, MountColor} = common_misc:get_equip_ring_and_mount_color(Equips),
    #p_map_role{
                 %%拼凑玩家在地图中的信息
                 role_id=RoleID, role_name=RoleName,faction_id=FactionID,
                 cur_title=CurTitle , cur_title_color=Color, family_id=FamilyID,
                 family_name=FamilyName,pos=Pos, hp=HP, max_hp=MaxHP,
                 mp=MP, max_mp=MaxMP, skin=Skin, move_speed=MoveSpeed, team_id=TeamID, 
                 level=Level, pk_point  = PkPoint, gray_name = IfGrayName,
                 state_buffs=Buffs, state=State, show_cloth=ShowCloth,
                 show_equip_ring=ShowEquipRing, equip_ring_color=EquipRingColor, mount_color=MountColor,
                 sex = RoleBase#p_role_base.sex, category = RoleAttr#p_role_attr.category
               }.

%%在分布式系统中初始化角色信息：进入地图/注册world role进程
init_role_distribution(Unique, PID, RoleID, Line, ClientIP) ->
    case db:transaction(
           fun() ->
                   [#p_role_pos{map_process_name=MapName}] = db:read(?DB_ROLE_POS, RoleID, write),
                   MapName
           end)
        of
        {atomic, MapName} ->
            {RoleMapInfo, RoleDetail, 
             RoleConlogin, AccumulateInfo, VipInfo,
             MissionData, HeroFBInfo, DropInfo,RefiningBoxInfo, 
             RoleGoal,AchievementInfo,TeamInfo,MapExtInfo,SkillList} = get_role_info(RoleID),
            %%统计玩家进入游戏窗口
            common_admin_hook:hook({enter_flash_window, RoleID,ClientIP}),
            case common_bag2:init_role_bag_info(RoleID) of
                {ok,RoleBagInfoList} ->
                    %% 加入在线列表
                    add_online(RoleDetail#p_role.base, ClientIP,Line),
                    
                    reset_role_pet_feed_info(RoleID),
                    RolePetGrowInfo = get_role_pet_grow_info(RoleID),
                    RoleFullInfo = #r_role_full_info{role_id=RoleID, base=RoleDetail#p_role.base,pos = RoleDetail#p_role.pos,
                                                     attr=RoleDetail#p_role.attr, conlogin=RoleConlogin, 
                                                     accumulate_info=AccumulateInfo, vip_info=VipInfo,
                                                     bag=RoleBagInfoList, role_map_info=RoleMapInfo,
                                                     mission_data=MissionData, pet_grow_info=RolePetGrowInfo,
                                                     hero_fb_info=HeroFBInfo, role_monster_drop=DropInfo,
                                                     goal_info=RoleGoal,achievement_info = AchievementInfo,
                                                     refining_box_info = RefiningBoxInfo,team_info = TeamInfo,
                                                     map_ext_info = MapExtInfo,skill_list = SkillList,
                                                     role_fight=RoleDetail#p_role.fight},
                    do_send_to_map(Unique, PID, RoleFullInfo, Line, ClientIP,MapName),
                    
                    %% 通知聊天
                    catch global:send(mgeec_client_manager, {online, erlang:self(), RoleID, RoleDetail#p_role.base, RoleDetail#p_role.attr,
                                                            RoleDetail#p_role.ext}),
                    ok;
                {error,Reason} ->
                    {error,Reason}
            end;
        {aborted, Error} ->
            ?ERROR_MSG("init_role_distribution, error: ~w", [Error]),
            {error, cant_get_role_map}        
    end.

%%发送进入地图的消息
do_send_to_map(Unique, PID, RoleFullInfo, Line, ClientIP,MapName)->
    Info = {first_enter, {Unique, PID, RoleFullInfo, Line, ClientIP}},
    case global:whereis_name(MapName) of
        MapPid when is_pid(MapPid)->
            MapPid ! Info,
            MapPid;
        undefined->
            #p_role_base{faction_id=FactionID} = RoleFullInfo#r_role_full_info.base,
            MapID = 10000 + FactionID * 1000, %%太平村地图ID
            HomeCityMapName = common_misc:get_map_name(MapID),
            global:send(HomeCityMapName, Info)
    end.

%% 初始化防沉迷信息
init_fcm(AccountName) ->
    erlang:put(login_time, common_tool:now()),
    case common_config:is_fcm_open() of
        false ->
            db:dirty_write(?DB_FCM_DATA, #r_fcm_data{account=common_tool:to_binary(AccountName), 
                                                     total_online_time=0, offline_time=common_tool:now()}),
            ok;
        true ->
            case db:dirty_read(?DB_FCM_DATA, common_tool:to_binary(AccountName)) of                
                [FcmData] ->
                    #r_fcm_data{offline_time=OffLineTime, passed=Passed, total_online_time=TotalOnlineTime} = FcmData;
                [] ->
                    FcmData = #r_fcm_data{account=common_tool:to_binary(AccountName),
                                          passed=false, offline_time=0, total_online_time=0},
                    db:dirty_write(?DB_FCM_DATA, FcmData),
                    Passed = false,
                    OffLineTime = 0,
                    TotalOnlineTime = 0
            end,
            %%如果通过了防沉迷，就不管了
            case Passed of
                true ->
                    ok;
                false ->
                    %%如果离线时间超过5小时或者隔天登陆，持续在线时间清零
                    OffLineTimeTotal = common_tool:now() - OffLineTime,
                    OffLineDate = common_time:time_to_date(OffLineTime),
                    {NowDate, _} = erlang:localtime(),
                    case OffLineTimeTotal >= ?FCM_OFFLINE_TIME orelse OffLineDate =/= NowDate of
                        true ->
                            db:dirty_write(?DB_FCM_DATA, FcmData#r_fcm_data{total_online_time=0}),
                            {ok, need_fcm, 0};
                        false ->
                            case TotalOnlineTime >= ?FCM_KICK_TIME of
                                true ->
                                    {error, fcm_kick_off_not_enough_off_time};
                                false ->
                                    {ok, need_fcm, TotalOnlineTime}
                            end
                    end
            end
    end.

%% 踢掉玩家
kick_role(ErrorNo, ErrorInfo, Socket) ->
    case erlang:is_port(Socket) of
        true ->
            R = #m_system_error_toc{error_info=ErrorInfo, error_no=ErrorNo},
            mgeeg_packet:packet_encode_send(Socket, ?DEFAULT_UNIQUE, ?SYSTEM, ?SYSTEM_ERROR, R);
        false ->
            ignore
    end.
%% T掉上次登录的角色
do_login_again(RegName, _RoleID) ->
    case global:whereis_name(RegName) of
        undefined ->
            ok;
        Pid ->
            erlang:monitor(process, Pid),
            %% 10秒之后强制kill ，
            case catch gen_server:call(Pid, login_again, 10000) of
                ok ->
                    ok;
                _ ->
                    erlang:exit(Pid, kill),
                    ok
            end,
            receive
                {'DOWN', _, process, _, _} ->
                    ok;
                Info ->
                    ?ERROR_MSG("~ts:~p", ["重复登录时收到意外消息", Info]),
                    {error, login_again_error}
            after 10000 ->
                    {error, login_again_timeout}
            end
    end.


%% 异常退出处理
do_role_exit_exception(RoleDetail) ->
    #p_role{base=RoleBase, fight=RoleFight} = RoleDetail,
    #p_role_base{status=Status} = RoleBase,
    #p_role_fight{hp=HP} = RoleFight,

    case Status =:= ?ROLE_STATE_DEAD orelse HP =< 0 of
        true ->
            case db:transaction(
                   fun() ->
                           t_do_role_exit_exception(RoleDetail)
                   end)
            of
                {atomic, RoleDetail2} ->
                    RoleDetail2;
                {error, Error} ->
                    ?ERROR_MSG("do_role_exit_exception, error: ~w", [Error]),
                    RoleDetail
            end;
        _ ->
            RoleDetail
    end.

t_do_role_exit_exception(RoleDetail) ->
    #p_role{base=RoleBase, fight=RoleFight, pos=RolePos} = RoleDetail,
    #p_role_base{role_id=RoleID,faction_id=FactionID, max_hp=MaxHP, max_mp=MaxMP} = RoleBase,
    #p_role_pos{map_id=MapID,map_process_name=OldMapPName} = RolePos,
    
    [HeroFBMapIDList] = common_config_dyn:find(hero_fb, fb_map_id_list),
    IsHeroFBMapID = lists:member(MapID, HeroFBMapIDList),
    [SqFBMapIDList] = common_config_dyn:find(shuaqi_fb,sq_fb_map_list),
    IsSqFBMapID = lists:member(MapID,SqFBMapIDList),
    %% 如果是地图争夺战则特殊处理
    if MapID =:= 10301 orelse MapID =:= 10400 orelse MapID =:= 10600 ->
           RolePos2 = RolePos,
           RoleFight2 = RoleFight#p_role_fight{hp=common_tool:ceil(MaxHP*0.01), mp=common_tool:ceil(MaxMP*0.01)};
       IsHeroFBMapID =:=true->
           case db:dirty_read(?DB_ROLE_HERO_FB_P,RoleID) of
               [#p_role_hero_fb_info{enter_pos=EnterPos,enter_mapid=EnterMapID}] ->
                   EnterMapPName = common_map:get_common_map_name(EnterMapID),
                   RolePos2 = RolePos#p_role_pos{map_id=EnterMapID, pos=EnterPos, map_process_name=EnterMapPName, old_map_process_name=OldMapPName},
                   db:write(?DB_ROLE_POS, RolePos2, write);
               _->
                   HomeMapID = common_misc:get_home_mapid(FactionID, MapID),
                   {HomeMapID, TX, TY} = common_misc:get_born_info_by_map(HomeMapID),
                   MapPName = common_map:get_common_map_name(HomeMapID),
                   Pos = #p_pos{tx=TX, ty=TY, px=0, py=0, dir=0},
                   RolePos2 = RolePos#p_role_pos{map_id=HomeMapID,pos=Pos,map_process_name=MapPName,old_map_process_name=OldMapPName},
                   db:write(?DB_ROLE_POS, RolePos2, write)
           end,
           RoleFight2 = RoleFight#p_role_fight{hp=MaxHP, mp=MaxMP};
       IsSqFBMapID =:= true->
           RolePos2 = RolePos,
           RoleFight2 = RoleFight#p_role_fight{hp=common_tool:ceil(MaxHP*0.01), mp=common_tool:ceil(MaxMP*0.01)};
       true -> 
           RoleFight2 = RoleFight#p_role_fight{hp=MaxHP, mp=MaxMP},
           HomeMapID = common_misc:get_home_mapid(FactionID, MapID),
           {HomeMapID, TX, TY} = common_misc:get_born_info_by_map(HomeMapID),
           MapPName = common_map:get_common_map_name(HomeMapID),
           Pos = #p_pos{tx=TX, ty=TY, px=0, py=0, dir=0},
           RolePos2 = RolePos#p_role_pos{map_id=HomeMapID,pos=Pos,map_process_name=MapPName,old_map_process_name=OldMapPName},
           db:write(?DB_ROLE_POS, RolePos2, write)
    end,
    
    RoleBase2 = RoleBase#p_role_base{status=?ROLE_STATE_NORMAL},
    db:write(?DB_ROLE_FIGHT, RoleFight2, write),
    db:write(?DB_ROLE_BASE, RoleBase2, write),
    RoleDetail#p_role{fight=RoleFight2, pos=RolePos2, base=RoleBase2}.

%% @doc 加入在线列表
add_online(RoleBase, ClientIP,Line) ->
    LoginTime = common_tool:now(),
    #p_role_base{role_id=RoleID, role_name=RoleName, account_name=AccountName, faction_id=FactionId, 
                 family_id=FamilyId} = RoleBase,
    RoleOnline = #r_role_online{role_id=RoleID, role_name=RoleName, account_name=AccountName, faction_id=FactionId, 
                   family_id=FamilyId, login_time=LoginTime, login_ip=ClientIP,line=Line},
    
    case db:transaction(
           fun() ->
                   db:write(?DB_USER_ONLINE, RoleOnline, write)
           end)
    of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("add_online, error: ~w", [Error])
    end.

%% @doc 移出在线列表
remove_online(RoleID) ->
    case db:transaction(
           fun() ->
                   db:delete(?DB_USER_ONLINE, RoleID, write)
           end)
    of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("remove_online, error: ~w", [Error])
    end.


reset_role_pet_feed_info(RoleID) ->
    Fun = fun()->
                  [FeedInfo] = db:read(?DB_PET_FEED,RoleID),
                  #p_pet_feed{
                              last_feed_day=LastFeedDay,
                              last_clear_star_week=LastClearStarWeek
                              }=FeedInfo,
                  Date=erlang:date(),
                  Day = calendar:date_to_gregorian_days(Date),
                  WeekDay=calendar:day_of_the_week(Date),
                  Day2=Day-WeekDay-1,
                  case LastFeedDay =:= undefined orelse LastFeedDay < Day of
                      true ->
                          FeedInfo2 = FeedInfo#p_pet_feed{last_feed_day=Day,feed_time=0};
                      false ->
                          FeedInfo2 = FeedInfo
                  end,
                  
                   case LastClearStarWeek =:= undefined orelse LastClearStarWeek < Day2 of
                      true ->
                          OldLevel = FeedInfo2#p_pet_feed.star_level,
                          OldExp = FeedInfo2#p_pet_feed.last_feed_exp,
                          case FeedInfo2#p_pet_feed.state =:= 3 of
                              false ->
                                  case OldLevel of
                                      2 -> NewExp = trunc(OldExp/2),NewTick=18+random:uniform(7);
                                      3 -> NewExp = trunc(OldExp/3),NewTick=20+random:uniform(7);
                                      4 -> NewExp = trunc(OldExp/6),NewTick=22+random:uniform(7);
                                      5 -> NewExp = trunc(OldExp/8),NewTick=24+random:uniform(7);
                                      6 -> NewExp = trunc(OldExp/10),NewTick=26+random:uniform(7);
                                      7 -> NewExp = trunc(OldExp/12),NewTick=28+random:uniform(7);
                                      8 -> NewExp = trunc(OldExp/19),NewTick=30+random:uniform(7);
                                      9 -> NewExp = trunc(OldExp/25),NewTick=31+random:uniform(7);
                                      _ -> NewExp = OldExp,NewTick=18+random:uniform(7)
                                  end;
                              true ->
                                  NewExp=OldExp,
                                  NewTick=FeedInfo2#p_pet_feed.feed_tick
                          end,    
                          FeedInfo3 = FeedInfo2#p_pet_feed{star_level=1,
                                                           feed_tick=NewTick,
                                                           last_feed_exp=NewExp,
                                                           free_star_up_flag=false,
                                                           last_clear_star_week=Day2,
                                                           star_up_flag=false,
                                                           star_up_fail_time=0};
                      false ->
                          FeedInfo3 = FeedInfo2
                  end,
                  
                  case FeedInfo3 =:= FeedInfo of
                      true ->
                          ignore;
                      false ->
                          db:write(?DB_PET_FEED,FeedInfo3,write)
                  end
          end,
    db:transaction(Fun).  

get_role_pet_grow_info(RoleID) ->
    Fun = fun()->
                  case db:read(?DB_ROLE_PET_GROW,RoleID) of
                      [] ->
                          GrowInfo=#p_role_pet_grow{role_id=RoleID},
                          db:write(?DB_ROLE_PET_GROW,GrowInfo,write),
                          {GrowInfo,undefined};
                      [GrowInfo] ->
                          case GrowInfo#p_role_pet_grow.state =:= 4 of
                              true ->
                                  OverTick = GrowInfo#p_role_pet_grow.grow_over_tick,
                                  {GrowInfo,OverTick};
                              false ->
                                  {GrowInfo,undefined}
                          end
                  end
          end,
    case db:transaction(Fun) of
        {atomic, Info} ->
            Info;
        {aborted, Error} ->
            ?ERROR_MSG("remove_online, error: ~w", [Error])
    end.
                

                 

