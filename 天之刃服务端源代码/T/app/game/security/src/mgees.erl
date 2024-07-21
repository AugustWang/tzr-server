%% Author: Administrator
%% Created: 2010-3-18
%% Description: TODO: Add description to security
-module(mgees).

-behaviour(application).

-export([
	 start/0,
	 start/2,
	 stop/1
        ]).


start() ->
    try
        application:start( sasl ),
        timer:sleep(100),
        application:start( mgees ),
        ok
    after
        timer:sleep(100)
    end.


start(_Type, _StartArgs) ->
    {ok, AcceptorNum} = application:get_env(acceptor_num),
    {ok, Port} = application:get_env(listen_port),
    case mgees_sup:start_link({Port,AcceptorNum}) of
	{ok, Pid} ->
            {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
            net_kernel:connect_node(erlang:list_to_atom(MasterNodeTmp)),
            timer:sleep(3000),
            global:send(manager_node, {security_node_up, erlang:node()}),
            ok = file:write_file("/data/tzr/server/ebin/security/run.lock", "started"),
	    {ok, Pid};
	Error ->
	    Error
    end.

stop(_State) ->
    file:delete("/data/tzr/server/ebin/security/run.lock"),
    ok.

