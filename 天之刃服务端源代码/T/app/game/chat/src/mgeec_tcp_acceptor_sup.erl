-module(mgeec_tcp_acceptor_sup).

-include("mgeec.hrl").

-behavior(supervisor).

-define(SERVER, ?MODULE).

-export([start_link/0, init/1]).
 
start_link() ->
    {ok, _Pid} = 
        supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->

    ChildSpec = 
        {mgeec_tcp_acceptor,
         {mgeec_tcp_acceptor,
          start_link,
          []
         },
         transient, brutal_kill, worker, [mgeec_tcp_acceptor]},

    {ok, {{simple_one_for_one, 10, 10}, [ChildSpec]}}.
