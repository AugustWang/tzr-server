%%%----------------------------------------------------------------------
%%% @copyright 2010 mgeew (Ming Game Engine Erlang - World Server)
%%%
%%% @author odinxu, 2010-03-24
%%% @doc MGEE World Application
%%% @end
%%%----------------------------------------------------------------------

-module(mgeew).

-behaviour(application).
-include("mgeew.hrl").

-export([
	 start/2,
	 stop/1,
	 start/0,
	 stop/0
        ]).

-define(APPS, [sasl, mgeew]).

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
    {ok, SupPid} = mgeew_sup:start_link(),
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
       {"MGEE World - Logger",
        fun() ->
                error_logger:add_report_handler(common_logger_h, ""),
                common_config_dyn:reload(common),
                common_loglevel:set(common_config:get_log_level())
        end},
        {"Common Config init",
         fun() ->
                 common_config_dyn:init(common),
                 common_mod_goal:set_open()
         end},
        {"Common Role Line World Server",
        fun() ->
                common_role_line_map:start(mgeew_sup)
        end},
       {"MGEE World - Config Server",
        fun() ->
                mgeew_config:start()		 
        end},
       {"Join Mnesia Group",
        fun () ->
                {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
                net_kernel:connect_node(erlang:list_to_atom(MasterNodeTmp)),
                timer:sleep(2000), 
                common_db:join_group()                
        end},
       {"Mysql Server",
        fun() ->
                PoolSize = mod_mysql:get_large_pool_size(),
                mod_mysql:start( PoolSize )
        end},	   
       {"DB Cache Server",
        fun() ->
                timer:sleep(3000),
                db_loader:init_world_tables(),
                db_loader:load_world_whole_tables()
        end
       },
       {"User Event Server",
        fun() ->
                mgeew_user_event:start()
        end},    
       {"Pay Server",
        fun() ->
                mgeew_pay_server:start()
        end},
       {"Office Server",
        fun() ->
                mgeew_office:start()
        end},
        {"Event Server",
        fun() ->
                mgeew_event:start()
        end},
       {"System Buff",
        fun() ->
                mgeew_system_buff:start()
        end},
       {"MGEE World - Log Server",
        fun() ->
                mgeew_behavior_log_server:start(),
                mgeew_consume_log_server:start(),
                common_general_log_server:start(mgeew_sup),
                common_item_log_server:start(mgeew_sup),
				mgeew_pet_log_server:start(),
                mgeew_super_item_log_server:start()
        end},
       {"MGEE World Mission Log Server Init ",
        fun () ->
                mgeew_mission_log_server:start(),
                mgeew_loop_mission_log_server:start()
        end},
	   {"MGEE Bank_Sheet Log Server Init ",
        fun () ->
                mgeew_bank_sheet_log_server:start()
        end},
	   {"MGEE country_treasure Log Server Init ",
        fun () ->
                mgeew_country_treasure_log_server:start()
        end},
       {"MGEE Family Server",
        fun() ->
                mod_family_data_server:start(),
                mod_family_manager:start()
        end
       },
       {"MGEE Team Server",
        fun () ->
                mod_team_server:start()
        end},
       {"MGEE Skill_server",
        fun () ->
                mgeew_skill_server:start()
        end},
       {"MGEE Mgeew_letter_server ok Server",
        fun() ->
                mgeew_letter_server:start()
        end},
       {"MGEE Mgeew_educate_server ok Server",
        fun() ->
                mgeew_educate_server:start()
        end},
       {"MGEE Mgeew_admin_server ok Server",
        fun() ->
                mgeew_admin_server:start()
        end},
       {"MGEE Mgeew_online ok Server",
        fun() ->
                mgeew_online:start()
        end},
       {"MGEEW Money Event Server",
        fun() ->
                mgeew_money_event_server:start()
        end},
       {"Mod Bank Server",
        fun () ->
                mod_bank_server:start()
        end},
       {"Mod Friend Server",
        fun () ->
                mod_friend_server:start()
        end},
       {"Mod Broadcast Server",
        fun() ->
                db:change_table_copy_type(?DB_BROADCAST_MESSAGE,node(),ram_copies),
                mgeew_broadcast_loop_server:start_link(),
                mod_broadcast_server:start()
        end },
       {"Ranking Server",
        fun() ->
                mgeew_ranking:start()
        end },
       {"MGEEW Monitor Agent",
        fun() ->
                mgeew_monitor_server:start_link(),
                SupList = [mgeew_role_sup,mgeew_sup,mod_broadcast_sup,mod_family_sup],
                common_monitor_agent:start_link(SupList),
                common_monitor_agent:set_monitor_sys(true)
        end},
       {"Write Finish File",
        fun() ->
                ?INFO_MSG("~w start ok",[?MODULE]),
                global:send(manager_node, {world_node_up, erlang:node()}),
                file:write_file("/data/tzr/server/ebin/world/run.lock", "started")
        end},
       {"Special Activity Server",
        fun() ->
                mgeew_activity_server:start()
        end}
      ]
     ),
    io:format("~nbroker running~n"),
    {ok, SupPid}.

%% --------------------------------------------------------------------
stop(_State) ->
	file:delete("/data/tzr/server/ebin/world/run.lock"),
    ok.

