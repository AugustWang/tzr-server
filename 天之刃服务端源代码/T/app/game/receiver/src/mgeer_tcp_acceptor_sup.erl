%%%----------------------------------------------------------------------
%%% File    : mgeer_tcp_acceptor_sup.erl
%%% Author  : Qingliang
%%% Created : 2010-03-10
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------

-module(mgeer_tcp_acceptor_sup).

-behaviour(supervisor).

-include("mgeer.hrl").

-export([start_link/1]).
-export([init/1]).

start_link(Callback) ->
    supervisor:start_link({local,?MODULE}, ?MODULE, Callback).

init(Callback) ->
    {ok, {{simple_one_for_one, 10, 10},
          [{mgeer_tcp_acceptor, {mgeer_tcp_acceptor, start_link, [Callback]},
            transient, brutal_kill, worker, [mgeer_tcp_acceptor]}]}}.
