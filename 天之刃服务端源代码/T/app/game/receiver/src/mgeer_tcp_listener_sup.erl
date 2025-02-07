%%%----------------------------------------------------------------------
%%% File    : mgeer_tcp_listener_sup.erl
%%% Author  : Qingliang
%%% Created : 2010-01-02
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------

-module(mgeer_tcp_listener_sup).

-behaviour(supervisor).

-export([start_link/5, start_link/6]).

-export([init/1]).

start_link(Port, SocketOpts, OnStartup, OnShutdown,
           AcceptCallback) ->
    start_link(Port, SocketOpts, OnStartup, OnShutdown,
               AcceptCallback, 1).

start_link(Port, SocketOpts, OnStartup, OnShutdown,
           AcceptCallback, ConcurrentAcceptorCount) ->
    supervisor:start_link(
      ?MODULE, {Port, SocketOpts, OnStartup, OnShutdown,
                AcceptCallback, ConcurrentAcceptorCount}).

init({Port, SocketOpts, OnStartup, OnShutdown,
      AcceptCallback, ConcurrentAcceptorCount}) ->
    %% This is gross. The tcp_listener needs to know about the
    %% mgee_tcp_acceptor_sup, and the only way I can think of accomplishing
    %% that without jumping through hoops is to register the
    %% mgee_tcp_acceptor_sup.
    {ok, {{one_for_all, 10, 10},
          [{mgeer_tcp_acceptor_sup, {mgeer_tcp_acceptor_sup, start_link,
                               [AcceptCallback]},
            transient, infinity, supervisor, [mgeer_tcp_acceptor_sup]},
           {mgeer_tcp_listener, {mgeer_tcp_listener, start_link,
                           [Port, SocketOpts,
                            ConcurrentAcceptorCount, mgeer_tcp_acceptor_sup,
                            OnStartup, OnShutdown]},
            transient, 100, worker, [mgeer_tcp_listener]}]}}.
