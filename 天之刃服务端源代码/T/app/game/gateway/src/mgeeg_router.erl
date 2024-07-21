%%%----------------------------------------------------------------------
%%% File    : mgeeg_line_router.erl
%%% Author  : Qingliang
%%% Created : 2010-03-25
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------
-module(mgeeg_router).

-behaviour(gen_server).

-include("mgeeg.hrl").

-export([
         router/1,
         router2/1, 
         reload_router_map/1, 
         start/1, 
         start_link/1
        ]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


start(Line) ->
    {ok, _} = supervisor:start_child(mgeeg_sup, 
                                     {mgeeg_router,
                                      {mgeeg_router, start_link, [Line]},
                                      transient, brutal_kill, worker, [mgeeg_router]
                                     }).

start_link(Line) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Line], []).

%% --------------------------------------------------------------------

router({Unique, Module, Method, DataRecord, RoleID, PID, Line}) ->
    %%mm_parser:parse(Module,Method,DataRecord),
    case common_config:chk_module_method_open(Module, Method) of
        true ->
            catch common_stat:stat_method(Module,Method),
            router2({Unique, Module, Method, DataRecord, RoleID, PID, Line});
        {false, Reason} ->
            ?ERROR_MSG("~p ~p", [Module, Method]),
            R = #m_system_message_toc{message=Reason},
            Socket = erlang:get(socket),
            case catch mgeeg_packet:packet_encode(?DEFAULT_UNIQUE, ?SYSTEM, ?SYSTEM_MESSAGE, R) of
                {'EXIT', Error} ->
                    ?ERROR_MSG("~ts:~w ~w", ["编码数据包出错", Error, {?SYSTEM, ?SYSTEM_MESSAGE, R}]);
                Bin ->
                    case erlang:is_port(Socket) of
                        true ->
                            erlang:port_command(Socket, Bin, [force]);
                        false ->
                            ignore
                    end
            end
    end.

router2({Unique, Module, Method, DataRecord, _RoleID, _Pid, _Line}) 
  when Module =:= ?SYSTEM andalso Method =:= ?SYSTEM_HEARTBEAT ->
    #m_system_heartbeat_tos{time=Time} = DataRecord,
    R = #m_system_heartbeat_toc{time=Time, server_time=common_tool:now()},
    Socket = erlang:get(socket),
    case catch  mgeeg_packet:packet_encode(Unique, Module, Method, R) of
        {'EXIT', Error} ->
            ?ERROR_MSG("~ts:~w ~w", ["编码数据包出错", Error, {Module, Method, R}]);
        Bin ->
            case erlang:is_port(Socket) of
                true ->
                    erlang:port_command(Socket, Bin, [force]);
                false ->
                    ignore
            end
    end;

router2({_Unique, Module, Method, DataRecord, _RoleID, _PID, _Line})
  when Module =:= ?SYSTEM andalso Method =:= ?SYSTEM_SET_FCM ->
    #m_system_set_fcm_tos{name=Realname, card=Card} = DataRecord,
    case common_config:get_agent_name() of
        "4399" ->
            Url = lists:concat([common_config:get_fcm_validation_url(), "?account=",
                                mochiweb_util:quote_plus(erlang:get(account_name)), "&truename=", mochiweb_util:quote_plus(Realname), "&card=",
                                Card, "&sign=", common_tool:md5(lists:concat([Realname, 
                                                                              common_tool:to_list(erlang:get(account_name)), 
                                                                              common_config:get_fcm_validation_key(),
                                                                              Card]))]),
            ok;
        "2918" ->
            %% 做了urlencode
            MD5 = common_tool:md5(lists:concat([mochiweb_util:quote_plus(Realname), mochiweb_util:quote_plus(erlang:get(account_name)),
                                                common_config:get_fcm_validation_key(), Card])),
            Param = mochiweb_util:urlencode([{"account", erlang:get(account_name)}, {"truename", Realname}, {"card", Card}]),
            Url = lists:concat([common_config:get_fcm_validation_url(), "?", Param, "&sign=", MD5]);
        "96pk" ->
            %% 做了urlencode
            MD5 = common_tool:md5(lists:concat([mochiweb_util:quote_plus(Realname), 
                                                mochiweb_util:quote_plus(erlang:get(account_name)),
                                                common_config:get_fcm_validation_key(), Card])),
            Param = mochiweb_util:urlencode([{"account", erlang:get(account_name)}, {"truename", Realname}, {"card", Card}]),
            Url = lists:concat([common_config:get_fcm_validation_url(), Param, "&sign=", MD5]);
        "pptv" ->
            MD5 = common_tool:md5(lists:concat([mochiweb_util:quote_plus(Realname), 
                                                mochiweb_util:quote_plus(erlang:get(account_name)),
                                                common_config:get_fcm_validation_key(), Card])),
            [ServerID] = common_config_dyn:find(common,game_id),
            Param = mochiweb_util:urlencode([{"gid", "mccq"}, {"account", erlang:get(account_name)}, {"truename", Realname}, {"card", Card},{"server_id",ServerID}]),
            Url = lists:concat([common_config:get_fcm_validation_url(), "?", Param, "&sign=", MD5]);
        _ ->
            MD5 = common_tool:md5(lists:concat([mochiweb_util:quote_plus(Realname), mochiweb_util:quote_plus(erlang:get(account_name)),
                                                common_config:get_fcm_validation_key(), Card])),
            [ServerID] = common_config_dyn:find(common,game_id),
            Param = mochiweb_util:urlencode([{"account", erlang:get(account_name)}, {"truename", Realname}, {"card", Card},{"server_id",ServerID}]),
            Url = lists:concat([common_config:get_fcm_validation_url(), "?", Param, "&sign=", MD5])
    end,
    %% 向平台发起请求，异步请求
    httpc:request(get, {Url, []},
                  [], [{sync, false}]),
    ok;
    
router2({Unique, Module, Method, DataIn, RoleID, PID, Line}) when Method =:= ?STALL_OPEN ->
    case db:dirty_read(?DB_STALL, RoleID) of
        [] ->
            case erlang:get(map_pid) of
                undefined ->
                    exit(self(), role_map_process_not_found);
                MapPID ->
                    MapPID ! {Unique, Module, Method, DataIn, RoleID, PID, Line}
            end;
        [#r_stall{mapid=MapID}] ->
            MapPName = common_misc:get_map_name(MapID),
            case global:whereis_name(MapPName) of
                undefined ->
                    DataRecord = #m_stall_open_toc{goods=[], state=3},%% 3、未摆摊状态
                    common_misc:unicast2(PID, Unique, Module, Method, DataRecord);
                MapPID ->
                    MapPID ! {Unique, Module, Method, DataIn, RoleID, PID, Line}
            end
    end;

router2({Unique, Module, Method, DataIn, RoleID, PID, Line}) when Method =:= ?STALL_CHAT ->
    #m_stall_chat_tos{target_role_id=TargetRoleID} = DataIn, 
    case common_misc:get_stall_map_pid(TargetRoleID) of
        {ok, MapPID} ->
            MapPID ! {Unique, Module, Method, DataIn, RoleID, PID, Line};
        _ ->
            DataRecord = #m_stall_chat_toc{succ=false, reason=?_LANG_STALL_TARGET_ROLE_NOT_STALLING},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord)
    end;

router2({Unique, Module, Method, DataIn, RoleID, PID, Line}) when Method =:= ?STALL_LIST ->
    case global:whereis_name("mgee_map_10700") of
        undefined ->
            DataRecord = #m_stall_list_toc{succ=false, reason=?_LANG_SYSTEM_ERROR},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord);
        MapPID ->
            MapPID ! {Unique, Module, Method, DataIn, RoleID, PID, Line}
    end;

router2({Unique, Module, Method, DataIn, RoleID, PID, Line}) when Method =:= ?STALL_DETAIL ->
    #m_stall_detail_tos{role_id=TargetRoleID} = DataIn,
    case common_misc:get_stall_map_pid(TargetRoleID) of
        {ok, MapPID} ->
            MapPID ! {Unique, Module, Method, DataIn, RoleID, PID, Line};
        _ ->
            DataRecord = #m_stall_detail_toc{succ=false, reason=?_LANG_STALL_HAS_FINISH},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord)
    end;
router2({Unique, Module, Method, DataRecord, RoleID, Pid, Line})
  when Module =:= ?MAP
       %%orelse Module =:= ?LETTER
       orelse Module =:= ?DEPOT
       orelse Module =:= ?GOODS
       orelse Module =:= ?ITEM
       orelse Module =:= ?EQUIP
       orelse Module =:= ?STONE
       orelse Module =:= ?SHOP
       orelse Module =:= ?EXCHANGE
       orelse Module =:= ?REFINING
       orelse Module =:= ?MOVE 
       orelse Module =:= ?FIGHT
       orelse Module =:= ?CONLOGIN
       orelse Module =:= ?SKILL
       %%orelse Module =:= ?LETTER
       orelse Module =:= ?STALL 
       orelse Module =:= ?EQUIP_BUILD
       orelse Module =:= ?BUBBLE 
       orelse Module =:= ?WAROFCITY
       orelse Module =:= ?MISSION
       orelse Module =:= ?ACHIEVEMENT
       orelse Module =:= ?DRIVER
       orelse Module =:= ?VIE_WORLD_FB
       orelse Module =:= ?TRADING
       orelse Module =:= ?TEAM
       orelse Module =:= ?EQUIPONEKEY
       orelse Module =:= ?COLLECT
       orelse Module =:= ?EXCHANGE
       orelse Module =:= ?ROLE2
       orelse Module =:= ?SYSTEM
       orelse Module =:= ?SHORTCUT
       orelse Module =:= ?TITLE
       orelse Module =:= ?ACTIVITY
       orelse Module =:= ?TRAININGCAMP
       orelse Module =:= ?NEWCOMER
       orelse Module =:= ?WAROFFACTION
       orelse Module =:= ?COUNTRY_TREASURE
       orelse Module =:= ?SPY
       orelse Module =:= ?ACCUMULATE_EXP
       orelse Module =:= ?JAIL
       orelse Module =:= ?EDUCATE_FB
       orelse Module =:= ?PERSONAL_FB
       orelse Module =:= ?HERO_FB
       orelse Module =:= ?MISSION_FB
       orelse Module =:= ?VIP
       orelse Module =:= ?SCENE_WAR_FB
       orelse Module =:= ?GIFT
       orelse (Module =:= ?RANKING andalso Method =:= ?RANKING_EQUIP_JOIN_RANK)
       orelse (Module =:= ?BROADCAST andalso Method =:= ?BROADCAST_LABA)
       orelse (Module =:= ?WAROFKING 
               andalso 
                 (
                 Method =:= ?WAROFKING_HOLD 
                 orelse Method =:= ?WAROFKING_ENTER
                 orelse Method =:= ?WAROFKING_GETMARKS
                 orelse Method =:= ?WAROFKING_SAFETIME
                )
              )
       orelse Module =:= ?PERSONYBC
       orelse Module =:= ?FLOWERS 
       orelse Module =:= ?PRESENT 
       orelse (Module =:= ?FMLDEPOT andalso (Method =:= ?FMLDEPOT_LIST_GOODS orelse
                                              Method =:= ?FMLDEPOT_PUTIN orelse
                                              Method =:= ?FMLDEPOT_LIST_LOG   ) )
       orelse (Module =:= ?PLANT andalso Method =/= ?PLANT_ASSART )
       orelse Module =:= ?LEVEL_GIFT 
       orelse Module =:= ?PET
       orelse Module =:= ?BONFIRE
       orelse Module =:= ?GOAL
       orelse Module =:= ?FAMILY_COLLECT 
       orelse Module =:= ?PRESTIGE
       orelse (Module =:= ?SPECIAL_ACTIVITY andalso Method=:=?SPECIAL_ACTIVITY_STAT)
       orelse (Module =:= ?FAMILY andalso Method=:=?FAMILY_DONATE)
       orelse Module =:= ?SHUAQI_FB 
       orelse Module =:= ?EXERCISE_FB 
       orelse Module =:= ?MONSTER ->
    case erlang:get(map_pid) of
        undefined ->
             exit(self(), role_map_process_not_found);
        PID ->
            PID ! {Unique, Module, Method, DataRecord, RoleID, Pid, Line}
    end;


router2({Unique, Module, Method, DataRecord, RoleID, PID, Line})
  when Module =:= ?FAMILY 
       orelse (Module =:= ?FMLSKILL)
       orelse (Module =:= ?FMLDEPOT)
       orelse (Module =:= ?PLANT andalso Method =:= ?PLANT_ASSART ) ->
    case global:whereis_name(mod_family_manager) of
        undefined ->
            ignore;
        GPID ->
            GPID ! {Unique, Module, Method, DataRecord, RoleID, PID, Line}
    end;


router2({Unique, Module, Method, DataRecord, RoleID, PID, Line}) 
  when Module =:= ?WAROFKING andalso (Method =:= ?WAROFKING_APPLY orelse Method =:= ?WAROFKING_AGREE_ENTER) ->
    catch global:send(mgeew_event, {mod_event_warofking, {Unique, Module, Method, DataRecord, RoleID, PID, Line}});


router2({Unique, Module, Method, DataRecord, RoleID, PID, Line}) 
  when Module =:= ?OFFICE  ->
    catch global:send(mgeew_office, {Unique, Module, Method, DataRecord, RoleID, PID, Line});

   
router2({Unique, Module, Method, DataRecord, RoleID, Pid, Line}) 
  when Module =:= ?CONFIG ->
    mgeeg_config:handle({Unique, Module, Method, DataRecord, RoleID, Pid, Line});

   
router2({Unique, _Module, ?CHAT_RECONNECT, _DataRecord, RoleID, _Pid, Line}) ->
    case global:whereis_name(mgeec_reconnect_server) of
        PidChatReconn when is_pid(PidChatReconn) ->
            PidChatReconn ! {reconnect, Unique, RoleID, Line};
        _ ->
            ?ERROR_MSG("~ts:~w", ["玩家希望重连聊天服务器，但服务器没开启来，角色ID:", RoleID]),
            DataRecord = #m_chat_reconnect_toc{succ = false, reason=?_LANG_SYSTEM_ERROR},
            common_misc:unicast(Line, RoleID, Unique, ?CHAT, ?CHAT_RECONNECT, DataRecord)
    end;

%% 新版本聊天重连处理
router2({Unique, ?AUTH, ?AUTH_CHAT_KEY, DataRecord, RoleID, Pid, _Line}) 
  when erlang:is_record(DataRecord,m_auth_chat_key_tos)->
    case global:whereis_name(mgeec_reconnect_server) of
        PidChatReconn when is_pid(PidChatReconn) ->
            PidChatReconn ! {new_reconnect, Unique, ?AUTH, ?AUTH_CHAT_KEY, DataRecord, RoleID, Pid};
        _ ->
            ?ERROR_MSG("~ts:~w", ["玩家希望重连聊天服务器，但服务器没开启来，角色ID:", RoleID]),
            DataRecord = #m_auth_chat_key_toc{
              succ = false, 
              times = DataRecord#m_auth_chat_key_tos.times,
              reason=?_LANG_SYSTEM_ERROR},
            common_misc:unicast2(Pid, Unique, ?AUTH, ?AUTH_CHAT_KEY, DataRecord)
    end;
    

router2({Unique, Module, Method, DataRecord, RoleID, Pid, Line}) ->
    do_router({Unique, Module, Method, DataRecord, RoleID, Pid, Line}).


do_router({Unique, Module, Method, DataRecord, RoleID, Pid, Line}) ->
    Info = {Unique, Module, Method, DataRecord, RoleID, Pid, Line},
    case Module of
        ?MAP ->
            global:send(mgeem_router, Info);
        ?BANK ->
            global:send(mod_bank_server, Info);
        ?BROADCAST ->
            global:send("mod_broadcast_server", Info);
        ?FRIEND ->
            global:send(mod_friend_server, Info);
        ?EDUCATE ->
            global:send(mgeew_educate_server, Info);
        ?GM ->
            global:send(mgeel_s2s_client, Info);
        ?STAT ->
            global:send(mgeel_stat_server, Info);
        ?RANKING ->
            global:send(mgeew_ranking, Info);
        ?LETTER ->
            global:send(mgeew_letter_server, Info);
        ?SPECIAL_ACTIVITY->
            global:send(mgeew_activity_server,Info);
        _ ->
            ?DEBUG("undefined module ~w", [Module]), 
            ok
    end.

%% use this method to update the moudle method map data.
reload_router_map(Filename) ->
    {ok, _Map} = file:consult(Filename),
    ok.

%% --------------------------------------------------------------------
init([_Line]) ->
    {ok, none}.


handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


handle_cast(_Msg, State) ->
    {noreply, State}.


handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
