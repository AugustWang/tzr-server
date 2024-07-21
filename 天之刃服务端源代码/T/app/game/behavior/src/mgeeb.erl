%%%----------------------------------------------------------------------
%%% File    : mgeeb.erl
%%% Author  : Qingliang
%%% Created : 2010-06-28
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------

-module(mgeeb).

-behaviour(application).

-export([
	 start/2,
	 stop/1,
	 start/0,
	 stop/0
        ]).

-define(APPS, [sasl, mgeeb]).

%% --------------------------------------------------------------------

start() ->
    try
        ok = common_misc:start_applications(?APPS) 
    after
        %%give the error loggers some time to catch up
        timer:sleep(100)
    end.

stop() ->
    ok = common_misc:stop_applications(?APPS).

%% --------------------------------------------------------------------
start(normal, []) ->
    {ok, SupPid} = mgeeb_sup:start_link(),
    lists:foreach(
      fun ({Msg, Thunk}) ->
               io:format("starting ~-32s ...", [Msg]),
               Thunk(),
               io:format("done~n");
         ({Msg, M, F, A}) ->
              io:format("starting ~-20s ...", [Msg]),
              apply(M, F, A),
              io:format("done~n")
      end,
      [
       {"Behavior Logger",
        fun() ->
                error_logger:add_report_handler(common_logger_h, ""),
                {ok, LogLevel} = application:get_env(log_level),
                common_loglevel:set(LogLevel)
        end},
       {"Common Config init",
        fun() ->
                common_config_dyn:init(common),
                ok
        end},
       {"Behavior Logger Writter",
        fun() ->
                behavior_serverlog:start()
        end},
       {"Ping Manager",
        fun() ->
                {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
                net_kernel:connect_node(erlang:list_to_atom(MasterNodeTmp)),
                timer:sleep(1000),                
                ok
        end},
       {"Cache Server",
        fun() ->
                behavior_cache_server:start(mgeeb_sup)
        end},
       {"Behavior Server",
        fun() ->
                try 
                    behavior_server:start()
                catch
                    _:Reason ->
                        io:format(
                          "~w;~w~n", 
                          ["Behavior Server Start Catch Exception", Reason]
                         )
                end
        end},
       {"Try to connect DB Node Server",
        fun() ->
                try_conn_db_node()
        end},
       {"MGEEB Monitor Agent",
               fun() ->
                       SupList = [mgeeb_sup],
                       common_monitor_agent:start_link(SupList)
               end},
       {"Write Finish File",
        fun() ->
                global:send(manager_node, {behavior_node_up, erlang:node()}),
                file:write_file("/data/tzr/server/ebin/behavior/run.lock", "started")
        end}
      ]
                 ),
    io:format("~nbroker running~n"),
    {ok, SupPid}.

%% --------------------------------------------------------------------
stop(_State) ->
    file:delete("/data/tzr/server/ebin/behavior/run.lock"),
    ok.

try_conn_db_node()->
    DbNodeName = common_config:get_db_node_name(),
    net_adm:ping(DbNodeName),
    ok.


