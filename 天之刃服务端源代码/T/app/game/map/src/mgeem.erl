%%%----------------------------------------------------------------------
%%% File    : mgeev.erl
%%% Author  : Qingliang
%%% Purpose : MGEE application
%%% Created : 2010-03-10
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------

-module(mgeem).

-behaviour(application).
-include("mgeem.hrl").
-export([
	 start/2,
	 stop/1,
	 start/0,
	 stop/0
        ]).

-define(APPS, [sasl, mgeem]).

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
    {ok, SupPid} = mgeem_sup:start_link(),
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
      [{"MGEE MAP Logger",
        fun () ->
                error_logger:add_report_handler(common_logger_h, ""),
                common_config_dyn:reload(common),
                common_loglevel:set(common_config:get_log_level())
        end},
       {"Join Mnesia Group",
        fun () -> 
                common_db:join_group(),
                ok
        end},
       {"MGEE MAP Mission Init",
        fun () ->
                mgeem_mission:start()
        end},
       {"Common Config init",
        fun() ->
                common_mod_goal:set_open(),
                common_config_dyn:init(common),
                ok
        end},
       {"Refining Forging Config init",
        fun() ->
                mod_forging_config:init()
        end},
       {"Trading Config init",
        fun() ->
                mod_trading_config:init()
        end},
       {"Init Shop Config",
        fun() ->
                mod_shop:init()
        end},
       {"Init Equip Build Server Config",
        fun() ->
                mod_equip_build:init_ets()
        end},
       {"Init Drop ID ETS Table",
        fun() ->
                mod_map_drop:init(),
                ok
        end},
       {"Common Role Line Map Server",
        fun() ->
                common_role_line_map:start(mgeem_sup)
        end},
       
       {"Mysql Server",
        fun() ->
                mod_mysql:start()
        end},
       {"DB Cache Server",
        fun() ->
                timer:sleep(2000),
                lists:foreach(
                  fun({Tab, _}) ->
                          db:add_table_copy(Tab, node(), ram_copies)
                  end, db_loader:map_table_defines())
        end
       },
       {"MGEE Map - Log Server",
        fun() ->
                common_general_log_server:start(mgeem_sup),
                common_item_log_server:start(mgeem_sup)
        end},
       
       {"MGEE MAP Vie World FB Data Init",
        fun() ->
                mod_vie_world_fb:init_ets()
        end},
       {"Pg22 Server",
        fun() ->
                pg22:start()
        end},
       {"MGEE MAP Router Server",
        fun () ->
                mgeem_router:start(),
                mgeem_map_sup:start()
        end},
       {"MGEE MAP Loader Server",
        fun() ->
                global:registered_names(),
                timer:sleep(2000),
                mod_map_loader:start()
        end},
       {"MGEE MAP Skill Init",
        fun () ->
                mod_skill_manager:start()
        end},
       {"MGEE MAP Exchange Init",
        fun() ->
                mod_exchange:init()
        end},
       {"MGEEM Monitor Agent",
        fun() ->
                SupList = [mgeem_map_sup,mgeem_sup],
                common_monitor_agent:start_link(SupList),
                common_monitor_agent:set_monitor_map_msg(true)
        end},
       {"MGEEM Persistent Server",
        fun() ->
                mgeem_persistent:start()
        end},
       {"MGEEM Event Server",
        fun() ->
                mgeem_event:start()
        end},
       {"Write Finish File",
        fun() ->
                ?INFO_MSG("~w start ok",[?MODULE]),
                file:write_file("/data/tzr/server/ebin/map/run.lock", "started")
        end}
      ]),
    io:format("~nbroker running~n"),
    {ok, SupPid}.

%% --------------------------------------------------------------------
stop(_State) ->
    file:delete("/data/tzr/server/ebin/map/run.lock"),
    ok.
