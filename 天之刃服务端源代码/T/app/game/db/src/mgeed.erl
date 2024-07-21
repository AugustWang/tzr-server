%%%----------------------------------------------------------------------
%%% File    : mgeed.erl
%%% Author  : Qingliang
%%% Purpose : MGEE application
%%% Created : 2010-01-01
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------

-module(mgeed).

-behaviour(application).
-export([
	 start/2,
	 stop/1,
	 start/0,
	 stop/0
        ]).


-export([]).


-define(APPS, [sasl, mgeed]).

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
start(_Name, []) ->
    {ok, SupPid} = mgeed_sup:start_link(),
    lists:foreach(
      fun ({Msg, Thunk}) ->
              io:format("starting ~-40s ...", [Msg]),
              Thunk(),
              io:format("done~n");
          ({Msg, M, F, A}) ->
              io:format("starting ~-40s ...", [Msg]),
              apply(M, F, A),
              io:format("done~n")
      end,
      [{"MGEED Logger",
        fun() ->	
                error_logger:add_report_handler(common_logger_h, ""),
                common_config_dyn:reload(common),
                common_loglevel:set(common_config:get_log_level())
        end},
       {"Common Config init",
        fun() ->
                common_config_dyn:init(common)
        end},
       {"Ping manager",
        fun() ->
                {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
                net_kernel:connect_node(erlang:list_to_atom(MasterNodeTmp)),
                timer:sleep(2000),                
                ok
        end},
       {"Mysql Server",
        fun() ->
                MiniPoolSize = mod_mysql:get_mini_pool_size(),
                mod_mysql:start(MiniPoolSize)
        end},
       {"DB Persistent Server",
        fun() ->
                mgeed_persistent:start()
        end},
       {"Mnesia table Init",
        fun () ->
                mgeed_mnesia:init()
        end},
       {"MGEED Monitor Agent",
        fun() ->
                SupList = [mgeed_sup],
                common_monitor_agent:start_link(SupList),
                common_monitor_agent:set_monitor_db(true)
        end},
       {"Write Finish File",
        fun() ->
                global:send(manager_node, {db_node_up, erlang:node()}),
                file:write_file("/data/tzr/server/ebin/db/run.lock", "started")
        end}
      ]),
    io:format("~nsystem running :)~n"),
    {ok, SupPid}.


stop(_State) ->
    file:delete("/data/tzr/server/ebin/db/run.lock"),
    ok.


