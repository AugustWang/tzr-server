%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     mod_mysql_assist_server 辅助实现keepalive等功能
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(mod_mysql_assist_server).
-behaviour(gen_server).


-export([start_link/0]).
-export([start/0]).
-export([start_mysql_pool/1,start_mysql_pool/2]).
-export([add_connection/1]).


%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(MYSQL_CONNECT_POOL_ID, mysql_connect_pool_id).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common.hrl").
-include("common_server.hrl").
-define(KEEPALIVE_TIMEOUT, 30000).
-define(MSG_KEEPALIVE, ming2_do_keepalive).

-define(ENCODING, utf8).
-define(MYSQL_PORT, 3306).




%% ====================================================================
%% External functions
%% ====================================================================
start() ->
    {ok,_} = supervisor:start_child(common_mysql_sup, 
                           {?MODULE, 
                            {?MODULE, start_link,[]},
                            transient, brutal_kill, worker, [?MODULE]}).
    

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],[]).


init([]) ->
    erlang:process_flag(trap_exit,true),
    
    erlang:send_after(?KEEPALIVE_TIMEOUT, self(), ?MSG_KEEPALIVE),
    {ok, []}.

start_mysql_pool(PoolSize) when is_integer(PoolSize) ->
    MySqlConfig = common_config:get_mysql_config(),
    ok = start_mysql_pool(PoolSize,MySqlConfig).
    

start_mysql_pool(PoolSize,MySqlConfig) when is_integer(PoolSize) andalso is_tuple(MySqlConfig) ->
    {Host, UserName, Password, DataBase} = MySqlConfig,
    ok = do_start_mysql_pool(Host, UserName, Password, DataBase,PoolSize).


add_connection(AddPoolSize)->
    PoolId = ?MYSQL_CONNECT_POOL_ID,
    Encoding = ?ENCODING,
    
    LinkConnections = true,
    {Host, UserName, Password, DataBase} = common_config:get_mysql_config(),
    erlydb_mysql:make_connection(AddPoolSize, PoolId, DataBase, Host, ?MYSQL_PORT,
                                 UserName, Password, Encoding, LinkConnections).
 
 
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

terminate(Reason, State) ->
    ?ERROR_MSG("mod_mysql_assist_server is terminating,Reason=~w,State=~w",[Reason,State]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

%%@return ok | {error, Err}
do_start_mysql_pool(Host, UserName, Password, DataBase,PoolSize) ->
    Encoding = ?ENCODING,
    LogLevel = common_loglevel:get(),
    LogFun = case (LogLevel>3) of
                 true-> 
                     fun mod_mysql:db_debug_log/4;
                 false->
                     fun mod_mysql:db_error_log/4
             end,
    
    %% 默认mysql启动的server是 mysql_dispatcher
    %% erlydb_mysql:start 方法则重启db之后连接池是失效的
    %% erlydb_mysql:start_link 方法则重启db之后连接池是有效的
    erlydb_mysql:start_link([{pool_id, ?MYSQL_CONNECT_POOL_ID},
                             {hostname, Host}, 
                             {port, ?MYSQL_PORT}, 
                             {username, UserName}, 
                             {password, Password}, 
                             {database, DataBase},
                             {logfun, LogFun},                             
                             {encoding, Encoding}, 
                             {poolsize, PoolSize}]).
    


do_handle_info(?MSG_KEEPALIVE)->
    try
        mod_mysql:select(<<"SELECT 1;">>)
    catch
        _:Reason->
            ?WARNING_MSG("do keepalive error, Reason=~w",[Reason])
    end,
    
    erlang:send_after(?KEEPALIVE_TIMEOUT, self(), ?MSG_KEEPALIVE);

do_handle_info(Info)->
    ?ERROR_MSG("receive unknown message,Info=~w",[Info]),
    ignore.


