%%%----------------------------------------------------------------------
%%% File    : mgeeg_networking.erl
%%% Author  : Qingliang
%%% Created : 2010-01-02
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------

-module(mgeeg_networking).

-define(TCP_OPTS, [
                   binary, 
                   {packet, 0},
                   {reuseaddr, true}, 
                   {nodelay, true},   
                   {delay_send, true}, 
                   {active, false},
                   {backlog, 1024},
                   {exit_on_close, false},
                   {send_timeout, 15000}
                  ]).

-include("mgeeg.hrl").
-include_lib("kernel/include/inet.hrl").

-export([start/0, start_tcp_listener/2, start_listener/3, stop_tcp_listener/2]).
-export([
         tcp_listener_started/2, 
         tcp_listener_stopped/2, 
         tcp_host/1
        ]).

%% API Functions

start() ->
    {ok, _} = supervisor:start_child(mgeeg_sup, {mgeeg_tcp_client_sup,
                                                     {mgeeg_tcp_client_sup, start_link, []},
                                                     permanent, infinity, supervisor, 
                                                     [mgeeg_tcp_client_sup]}).


start_tcp_listener(Port, AcceptorNum) ->
    start_listener(Port, AcceptorNum,
                   {?MODULE, start_client, []}).

start_listener(Port, AcceptorNum, OnConnect) ->
    {ok,_} = supervisor:start_child(
               mgeeg_sup,
               {mgeeg_tcp_listener_sup,
                {mgeeg_tcp_listener_sup, start_link,
                 [Port, ?TCP_OPTS ,
                  {?MODULE, tcp_listener_started, [localhost]},
                  {?MODULE, tcp_listener_stopped, [localhost]},
                  OnConnect, AcceptorNum]},
                transient, infinity, supervisor, [mgeeg_tcp_listener_sup]}),
    ok.

stop_tcp_listener(Host, Port) ->
    {ok, IPAddress} = inet:getaddr(Host, inet),
    Name = common_misc:tcp_name(mgeeg_tcp_listener_sup, IPAddress, Port),
    ok = supervisor:terminate_child(mgeeg_sup, Name),
    ok = supervisor:delete_child(mgeeg_sup, Name),
    ok.


tcp_listener_started(Host, Port) ->
    ?INFO_MSG("~ts ~w:~w", ["端口开始监听", Host, Port]),
    ok.

tcp_listener_stopped(Host, Port) ->
    ?INFO_MSG("~ts ~w:~w", ["端口停止监听", Host, Port]),
    ok.


tcp_host({0,0,0,0}) ->
    {ok, Hostname} = inet:gethostname(),
    case inet:gethostbyname(Hostname) of
        {ok, #hostent{h_name = Name}} -> Name;
        {error, _Reason} -> Hostname
    end;
tcp_host(IPAddress) ->
    case inet:gethostbyaddr(IPAddress) of
        {ok, #hostent{h_name = Name}} -> Name;
        {error, _Reason} -> inet_parse:ntoa(IPAddress)
    end.
