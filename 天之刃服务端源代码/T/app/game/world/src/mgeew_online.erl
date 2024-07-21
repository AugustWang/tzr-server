%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     记录在线人数的列表，并定时将在线列表持久化到数据库中
%%%      用mnesia表来存储在线玩家列表
%%% @end
%%% Created : 2010-11-18
%%%-------------------------------------------------------------------
-module(mgeew_online).

-behaviour(gen_server).
-include("mgeew.hrl").

-export([start/0, 
         start_link/0
         ]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%% --------------------------------------------------------------------


%%定时发消息进行持久化
-define(DUMP_ONLINE_INTERVAL, 30 * 1000).
-define(DUMP_LOGIN_INTERVAL, 60 * 1000).

-define(DEFAULT_MEMCACHE_HOST, "127.0.0.1").
-define(DEFAULT_MEMCACHE_PORT, 11211).


-define(MSG_DUMP_ONLINE_LIST, dump_online_list).
-define(MSG_DUMP_LOGIN_LOG, dump_login_log).

-define(LOGIN_LOG_QUEUE,login_log_queue).
-define(ONLINE_USER_ADD_QUEUE, online_user_add_queue).
-define(ONLINE_USER_DEL_QUEUE, online_user_del_queue).

-record(state, {}).



%% ====================================================================
%% API functions
%% ====================================================================


%% ====================================================================
%% External functions
%% ====================================================================

start() ->
    mod_online_update_server:start(),
    {ok, _} = supervisor:start_child(mgeew_sup, {?MODULE,
                                                 {?MODULE, start_link, []},
                                                 transient, brutal_kill, worker, 
                                                 [?MODULE]}).

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).



%% --------------------------------------------------------------------
init([]) ->
    clear_user_online(),
    erlang:send_after(?DUMP_ONLINE_INTERVAL, self(), ?MSG_DUMP_ONLINE_LIST),
    erlang:send_after(?DUMP_LOGIN_INTERVAL, self(), ?MSG_DUMP_LOGIN_LOG),
    connect_memcache(false),
    
    {ok, #state{}}.
 
 
%% ====================================================================
%% Server functions
%%      gen_server callbacks
%% ====================================================================
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(Info, State) ->
    ?DO_HANDLE_INFO(Info,State),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


connect_memcache(IsReconnect)->
    try
        case IsReconnect of
            true->
                catch merle:disconnect();
            _ ->
                ignore
        end,
        case common_config_dyn:find_common(memcache_config) of
            [{McHost, McPort}] ->
                ?INFO_MSG("{McHost, McPort}=~w",[{McHost, McPort}]),
                {ok,_} = merle:connect(McHost, McPort);
            _ ->
                {ok,_} = merle:connect(?DEFAULT_MEMCACHE_HOST, ?DEFAULT_MEMCACHE_PORT)
        end
    catch
        _:Error->
            ?ERROR_MSG("连接Memcache出错,Reason=~w", [Error])
    end.


%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
do_handle_info({add_online, RoleOnline, Line ,Level}=Info)->
    ?DEBUG("收到在线信息,Info=~w",[Info]),
    %% 注册玩家分线
    #r_role_online{role_id=RoleID} = RoleOnline,
    common_misc:set_role_line_by_id(RoleID, Line),
    
    #r_role_online{role_id=RoleID,login_time=LogTime,login_ip=LoginIP} = transform_ip(RoleOnline),
    
    update_queue(?LOGIN_LOG_QUEUE,[RoleID,LogTime,LoginIP,Level]),
    ok;

do_handle_info({remove_online,RoleID}=Info)->
    ?DEBUG("收到离线信息,Info=~w",[Info]),
    %% 移除玩家分线
    common_misc:remove_role_line_by_id(RoleID),
    ok;

do_handle_info(?MSG_DUMP_ONLINE_LIST)->
    
    do_dump_online_list(),
    
    erlang:send_after(?DUMP_ONLINE_INTERVAL, self(), ?MSG_DUMP_ONLINE_LIST);

%% 写入每分钟的在线人数，以及一分钟内的玩家登陆记录
do_handle_info(?MSG_DUMP_LOGIN_LOG)->
    do_dump_online_num(),
    case get(?LOGIN_LOG_QUEUE) of
        undefined-> ignore;
        [] -> ignore;
        Queues ->
            do_dump_login_log(Queues)
    end,
    
    erlang:send_after(?DUMP_LOGIN_INTERVAL, self(), ?MSG_DUMP_LOGIN_LOG);

do_handle_info(Info)->
    ?ERROR_MSG("receive unknown message,Info=~w",[Info]),
    ignore.

%%@doc 将在线用户数，每分钟统计到db中
do_dump_online_num()->
    try
        OnlineNum = db:table_info(?DB_USER_ONLINE,size),
        {{Year, Month, Day}, {Hour, Min, _}} = calendar:local_time(),
        Statement={esql,{insert, ?T_LOG_ONLINE,
                         [online, dateline, week_day, year, month, day, hour, min],
                         [[OnlineNum, common_tool:now(), common_time:weekday(), Year, Month, Day, Hour, Min]]}},
        
        {ok,_} = mod_mysql:insert(Statement)
    catch
        _:Reason1->
            ?ERROR_MSG("写在线用户数失败,Reason=~w", [Reason1])
    end.
    

%%@doc 将在线列表更新到数据库中
do_dump_online_list()->
    
    try
        Pattern = #r_role_online{_='_'},
        case db:dirty_match_object(?DB_USER_ONLINE,Pattern) of
            OnlineList when is_list(OnlineList)->
                OnlineNum = erlang:length(OnlineList),
                
                try
                    ok = merle:set_integer(online, 0, 3600, OnlineNum)
                catch
                    _:Reason2->
                        ?ERROR_MSG("向memcache写在线人数出错,Reason=~w", [Reason2]),
                        connect_memcache(true),
                        catch merle:set_integer(online, 0, 3600, OnlineNum)
                end,
                case OnlineList of
                    []->
                        clear_user_online();
                    _ ->                        
                        Queues = [ transform_rec_to_list(R)|| R<-OnlineList ],
                        do_insert_users(Queues)
                end;
            {'EXIT', ExtError} ->
                ?ERROR_MSG("读取在线玩家列表出错！Reason=~w",[ExtError]);
            _ ->
                ignore
        end
    catch
        _:Reason->
            ?ERROR_MSG("更新在线玩家列表出错,Reason=~w,stacktrace=~w",[Reason,erlang:get_stacktrace()])
    end.


transform_rec_to_list(Rec)->
    [_H|FieldList] = tuple_to_list( transform_ip(Rec) ),
    FieldList.

transform_ip(#r_role_online{login_ip=LoginIP} = RoleOnline)->
    RoleOnline#r_role_online{login_ip= common_tool:ip_to_str(LoginIP) }.

%%@doc 将数据更新到log的队列
update_queue(TheKey,Val)->
    %%?ERROR_MSG("更新队列,Key=~w,Val=~w",[TheKey,Val]),
    case get(TheKey) of
        undefined ->
            put(TheKey, [Val]);
        Queues ->
            put( TheKey,[ Val|Queues ] )
    end.
    
%%@doc 记录玩家的登录日志
do_dump_login_log(Queues)->
    try
        %%批量插入的数据，目前最大不能超过3M
        FieldNames = [ role_id,log_time,login_ip,level ],

        QueuesInsert = lists:reverse(Queues),
        mod_mysql:batch_insert(t_log_login,FieldNames,QueuesInsert,3000),
        
        %%插入成功之后，再修改进程字典
        put(?LOGIN_LOG_QUEUE,[])
    catch
        _:Reason->
            ?ERROR_MSG("记录玩家登录日志出错,Reason=~w,stacktrace=~w",[Reason,erlang:get_stacktrace()])
    end.
  

%%@doc 清空在线用户列表
clear_user_online()->
    try
        SQL = mod_mysql:get_esql_delete(t_user_online, [] ),
        {ok,_} = mod_mysql:delete(SQL)
    catch
        _:Reason->
            ?ERROR_MSG("清空在线用户列表出错,Reason=~w,stacktrace=~w",[Reason,erlang:get_stacktrace()])
    end.


do_insert_users(Queues)->
    %%先清空整个在线用户表
    clear_user_online(),
    
    %%批量插入的数据，目前最大不能超过3M
    FieldNames = record_info(fields,r_role_online),
    BatchFieldValues = Queues,
    
    mod_mysql:batch_insert(t_user_online,FieldNames,BatchFieldValues,3000).
   


