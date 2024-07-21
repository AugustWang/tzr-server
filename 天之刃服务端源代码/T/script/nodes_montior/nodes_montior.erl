-module(nodes_montior).

-behaviour(application).

-export([
	 start/2,
	 stop/1,
	 start/0,
	 stop/0
        ]).

-define(APPS, [sasl, nodes_montior]).

%% --------------------------------------------------------------------

start() ->
    {ok, [[PingNode]]} = init:get_argument(ping_node),
    pong = net_adm:ping(list_to_atom(PingNode)),
    timer:sleep(2000),
    ok = application:start(sasl),
    ok = application:start(nodes_montior).

stop() ->
    ok = application:stop(nodes_montior),
    ok = application:stop(sasl).

%% --------------------------------------------------------------------
start(normal, []) ->
    {ok, [[Info]]} = init:get_argument(info),
    {ok, [[PingNode]]} = init:get_argument(ping_node),
    nodes_montior_server:start_link(Info, PingNode),
    {ok, self()}.

%% --------------------------------------------------------------------
stop(_State) ->
    init:stop(),
    ok.