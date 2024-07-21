-module(mgeec_tcp_sup).

-include("mgeec.hrl").

-behavior(supervisor).

-define(SERVER, ?MODULE).

-export([start/0, start_link/0, init/1]).

start() ->
    {ok, _} = 
        supervisor:start_child(mgeec_sup,
                               {?MODULE, 
                                {?MODULE, start_link, []},
                                transient, infinity, supervisor, [?MODULE]}
                              ),
    
    {ok, _} = 
        supervisor:start_child(?SERVER,
                               {mgeec_tcp_acceptor_sup, 
                                {mgeec_tcp_acceptor_sup, start_link, []},
                                transient, infinity, supervisor, [mgeec_tcp_acceptor_sup]}
                              ),
    
    {ok, _} = 
        supervisor:start_child(?SERVER,
                               {mgeec_tcp_listener, 
                                {mgeec_tcp_listener, start_link, []},
                                transient, 500, worker, [mgeec_tcp_listener]}
                              ).
        

start_link() ->
    {ok, _Pid} = 
        supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    {ok, {{one_for_one, 10, 10}, []}}.
