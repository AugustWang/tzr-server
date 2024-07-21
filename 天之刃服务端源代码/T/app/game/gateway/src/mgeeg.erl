%%%----------------------------------------------------------------------
%%% File    : mgeeg.erl
%%% Author  : Qingliang
%%% Purpose : MGEE application
%%% Created : 2010-03-10
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------

-module(mgeeg).

-behaviour(application).
-include("mgeeg.hrl").
-export([
	 start/2,
	 stop/1,
	 start/0,
	 stop/0
        ]).

-define(APPS, [sasl, mgeeg]).

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
    {ok, SupPid} = mgeeg_sup:start_link(),
    lists:foreach(
      fun ({Msg, Thunk}) ->
              io:format("starting ~-24s ...", [Msg]),
              Thunk(),
              io:format("done~n");
          ({Msg, M, F, A}) ->
              io:format("starting ~-20s ...", [Msg]),
              apply(M, F, A),
              io:format("done~n")
      end, 
      [{"MGEE Line Logger",
            fun () ->
                    error_logger:add_report_handler(common_logger_h, ""),
                    common_config_dyn:reload(common),
                    common_loglevel:set(common_config:get_log_level())
            end},
       {"Common Config init",
        fun() ->
                common_config_dyn:init(common),
                ok
        end},
       {"Common Role Line Map Server",
        fun() ->
                common_role_line_map:start(mgeeg_sup)
        end},
       {"Mysql Server",
        fun() ->
                mod_mysql:start(),
                common_general_log_server:start(mgeeg_sup)
        end},
       {"Join Mnesia Group",
        fun () -> 
                {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
                net_kernel:connect_node(erlang:list_to_atom(MasterNodeTmp)),
                timer:sleep(2000), 
                common_db:join_group(),
                ok
        end
       },
       {"DB Cache Server",
        fun() ->
                timer:sleep(2000),
                db_loader:init_line_tables(),
                db_loader:load_line_whole_tables()
        end
       },       
       {"MGEE Line Config Server",
        fun () -> 
                inets:start(),
                mgeeg_config:start(),
                {ok, [[PortStr]]} = init:get_argument(port),
                {ok, [[Host]]} = init:get_argument(host),
                Port = erlang:list_to_integer(PortStr),
                ?DEBUG("~ts:~w ~w", ["启动分线", Host, Port]),
                mgeeg_config:set(host_port, {Host, Port}),
                mgeeg_config:set(line, Port)
        end},
       {"MGEE Line Moniter",
        fun () ->
                mgeeg_stat_server:start(),
                mgeeg_moniter:start()
        end},
       {"MGEE Line Router Server",
        fun () ->
                mgeeg_router:start(mgeeg_config:get(line))
        end},
       {"MGEE Line Role-VW Map Server",
        fun () ->
                mgeeg_role_map_table:start(mgeeg_config:get(line))
        end},
       {"MGEE Line Role-Sock Map Server",
        fun () -> 
                mgeeg_role_sock_map:start() 
        end},
       {"MGEE Line Broadcast Server",
        fun () -> 
                mgeeg_broadcast:start(mgeeg_config:get(line)) 
        end},
       {"MGEE Line Unicast Server",
        fun () -> 
                mgeeg_unicast:start(mgeeg_config:get(line)) 
        end},
       {"TCP listeners",
        fun () ->
                mgeeg_networking:start(),
                {_, Port} = mgeeg_config:get(host_port),
                case Port > 0 of
                    true ->
                        ok = mgeeg_networking:start_tcp_listener(Port, 30);
                    false ->
                        throw(wrong_port)
                end
        end},
       {"mgeeg Monitor Agent",
        fun() ->
                SupList = [mgeeg_sup],
                common_monitor_agent:start_link(SupList),
                common_monitor_agent:set_monitor_line_msg(true)
        end},
       {"Write Finish File",
        fun() ->
                global:send(manager_node, {gateway_node_up, erlang:node()})
        end}
      ]),
    io:format("~nbroker running~n"),
    Line = mgeeg_config:get(line),
    {ok, SupPid, Line}.

%% --------------------------------------------------------------------
stop(Line) ->
    File = lists:concat(["/data/tzr/server/ebin/line/" ++ "run_" + Line + ".lock"]),
    file:delete(File),
    ok.

