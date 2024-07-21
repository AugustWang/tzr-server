-module(mgeec).

-behaviour(application).
-include("mgeec.hrl").

-export([
	 start/2,
	 stop/1,
	 start/0,
	 stop/0
        ]).

-define(APPS, [sasl, mgeec]).

%% --------------------------------------------------------------------

start() ->
    try
        ok = common_misc:start_applications(?APPS) 
    after
        timer:sleep(100)
    end.

stop() ->
    ok = common_misc:stop_applications(?APPS).

%% --------------------------------------------------------------------
start(normal, []) ->
    {ok, SupPid} = mgeec_sup:start_link(),
    io:format("~n", []),
    lists:foreach(
      fun ({Msg, Thunk}) ->
              io:format("starting ~p ...", [Msg]),
              Thunk(),
              io:format("done~n");
          ({Msg, M, F, A}) ->
              io:format("starting ~p ...", [Msg]),
              apply(M, F, A),
              io:format("done~n")
      end,
      [       
              {"MGEE Chat - Info Logger",
               fun() ->
                       error_logger:add_report_handler(common_logger_h, ""),
                       common_config_dyn:reload(common),
                       common_loglevel:set(common_config:get_log_level())
               end},
              {"Common Config init",
                fun() ->
                        common_config_dyn:init(common)
                end},
              {"Join Group",
               fun () -> 
                       {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
                       net_kernel:connect_node(erlang:list_to_atom(MasterNodeTmp)),
                       timer:sleep(2000), 
                       common_db:join_group()
               end},
              {"MGEE Chat - Msg Logger",
               fun() ->
                       mgeec_logger:start()
               end},
			  {"Mysql Server",
			   fun() ->
                	   mod_mysql:start()
			   end},
              {"DB Cache Server",
               fun() ->
                       timer:sleep(2000),
                       db_loader:init_chat_tables(),
                       db_loader:load_chat_whole_tables()
               end
              },
              {"Module Method Map init",
               fun() ->
                       mgeec_mm_map:start()
               end},
              {"Start Config Loader",
               fun() ->
                       mgeec_config:start()
               end},
              {"start client manager", 
               fun() ->
                       mgeec_client_manager:start()
               end},
              {"Start Actor Supverisor",
               fun() ->
                       mgeec_role_sup:start()
               end},
              {"Start Channel Supverisor",
               fun() ->
                       mgeec_channel_sup:start()
               end},
              {"Start Broadcast Supverisor",
               fun() ->
                       mgeec_broadcast_sup:start()
               end},
              {"Start Broadcast Server",
               fun() ->
                       mgeec_broadcast:start()
               end},
              {"Start Server Stop Clear Server",
               fun() ->
                       mgeec_server_stop:start()
               end},
              {"Start Mgeec Goods Cache",
               fun() ->
                       mgeec_goods_cache:start()
               end},
              {"MGEEC Monitor Agent",
               fun() ->
                       SupList = [mgeec_sup,mgeec_channel_sup,mgeec_broadcast_sup],
                       common_monitor_agent:start_link(SupList),
                       common_monitor_agent:set_monitor_sys(true)
               end},
              {"MGEEC Chat Reconnect",
               fun() ->
                       mgeec_reconnect_server:start()
               end},
              {"Write Finish File",
               fun() ->
                       global:send(manager_node, {chat_node_up, erlang:node()}),
                       file:write_file("/data/tzr/server/ebin/chat/run.lock", "started")
               end}
      ]
     ),
    io:format("~nbroker running~n"),
    {ok, SupPid}.

%% --------------------------------------------------------------------
stop(_State) ->
    file:delete("/data/tzr/server/ebin/chat/run.lock"),
    ok.

