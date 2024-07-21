%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc TEMPLATE.

-module(mgeeweb).
-author('author <author@example.com>').
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.

%% @spec start() -> ok
%% @doc Start the mgeeweb server.
start() ->
    application:start(sasl),
    mgeeweb_deps:ensure(),
    ensure_started(crypto),
    application:start(mgeeweb),
    {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
    net_kernel:connect_node(erlang:list_to_atom(MasterNodeTmp)),
    timer:sleep(2000), 
    mod_distribution_service:join_db_group(),
    global:send(manager_node, {mgeeweb_node_up, erlang:node()}),
    ok.

%% @spec stop() -> ok
%% @doc Stop the mgeeweb server.
stop() ->
    Res = application:stop(mgeeweb),
    application:stop(crypto),
    Res.
