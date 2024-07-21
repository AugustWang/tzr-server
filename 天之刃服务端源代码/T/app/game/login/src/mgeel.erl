%%%----------------------------------------------------------------------
%%% File    : mgeel.erl
%%% Author  : Qingliang
%%% Purpose : MGEE application
%%% Created : 2010-03-10
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------

-module(mgeel).

-behaviour(application).

-include("mgeel.hrl").

-export([
	 start/2,
	 stop/1,
	 start/0,
	 stop/0
        ]).

-define(APPS, [sasl, mgeel]).

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
    {ok, SupPid} = mgeel_sup:start_link(),
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
      {"MGEE Login Logger",
        fun() ->
                error_logger:add_report_handler(common_logger_h, ""),
                common_config_dyn:reload(common),
                common_loglevel:set(common_config:get_log_level())
        end},
       {"Common Config init",
        fun() ->
                common_config_dyn:init(common),
                ok
        end},
       {"Join Mnesia Group",
        fun() ->
                {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
                net_kernel:connect_node(erlang:list_to_atom(MasterNodeTmp)),
                timer:sleep(2000), 
                %%加入mnesia集群
                common_db:join_group()
        end},
       {"Mysql Server",
        fun() ->
                mod_mysql:start()
        end},
       {"DB Cache Server",
        fun() ->
                timer:sleep(3000),
                db_loader:init_login_tables(),
                db_loader:load_login_whole_tables()
        end},
       {"MGEEL Account Server",
        fun() ->
                mgeel_account_server:start()
        end},
       {"MGEEL Key Server",
        fun () ->
                mgeel_key_server:start()
        end},
       {"MGEEL Stat Server",
        fun () ->
                mgeel_stat_server:start()
        end},
       {"MGEEL Line Server",
        fun() ->
                mgeel_line:start()
        end},
       {"S2S server", 
        fun() ->
                {ok, S2SPort} = application:get_env(s2s_port),
                io:format("start, s2s_port: ~w", [S2SPort]),
                mgeel_s2s:start(S2SPort)
        end},
       {"MGEEL GM Server",
        fun() ->
                mgeel_gm_server:start()
        end},
       {"MGEEL - Log Server",
        fun() ->
                common_item_log_server:start(mgeel_sup)
        end},
       {"Write Finish File",
        fun() ->
                global:send(manager_node, {login_node_up, erlang:node()})
        end}
	  ]
	  ),
    io:format("~nbroker running~n"),
    {ok, SupPid}.

%% --------------------------------------------------------------------
stop(_State) ->
    file:delete("/data/tzr/server/ebin/login/run.lock"),
    ok.

