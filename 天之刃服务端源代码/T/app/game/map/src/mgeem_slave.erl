%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 16 Dec 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mgeem_slave).

%% API
-export([start/0]).

start() ->
    {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
    MasterNode = erlang:list_to_atom(MasterNodeTmp),
    net_kernel:connect_node(MasterNode),
    erlang:process_flag(trap_exit, true),
    erlang:monitor_node(MasterNode, true),
    timer:sleep(2000),
    global:send(lists:concat(["master_", MasterNode]), {slave_started, erlang:node()}),
    loop(MasterNode).

loop(MasterNode) ->
    receive 
        {nodedown, MasterNode} ->
            init:stop();
        _ ->
            loop(MasterNode)
    end.
