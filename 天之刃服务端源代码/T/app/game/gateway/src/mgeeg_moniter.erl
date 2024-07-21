%%% -------------------------------------------------------------------
%%% Author  : QingliangCn
%%% Description :
%%%
%%% Created : 2010-4-29
%%% -------------------------------------------------------------------
-module(mgeeg_moniter).

-behaviour(gen_server).
-include("mgeeg.hrl").
-export([
         start/0, 
         start_link/0,
         reload_nodes/0
        ]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {login_node, map_node, world_node}).

start() ->
    {ok, _} = supervisor:start_child(
                mgeeg_sup, 
                {?MODULE, 
                 {?MODULE, start_link, []}, 
                 transient, 10000, worker, [?MODULE]}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


reload_nodes() ->
    gen_server:call(?MODULE, reload).


init([]) ->
    timer:sleep(3000),
    ets:new(ets_nodes_status, [protected, named_table, set]),
    ok = net_kernel:monitor_nodes(true),
    ets:insert(ets_nodes_status, {login, true}),
    register_to_login(),
    NewState = do_reload(),
    timer:send_after(100, send_run_queue),
    {ok, NewState}.


handle_call(reload, _, _) ->
    NewState = do_reload(),
    {reply, ok, NewState};
    
    
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.


%%向login.server发送负载信息
handle_info(send_run_queue, State) ->
    case global:whereis_name(mgeel_line) of
        undefined ->
            ignore;
        _ ->
            Line = mgeeg_config:get(line),
            global:send(mgeel_line, {run_queue, Line, erlang:length(erlang:processes())})
    end,
    timer:send_after(1000, send_run_queue),
    {noreply, State};


handle_info({nodedown, Node}, State) when Node =:= State#state.login_node  ->
    ?ERROR_MSG("login server is down!!!", []),
    ets:insert(ets_nodes_status, {login, false}),
    {noreply, State};

handle_info({nodedown, Node}, State) ->
    ?DEBUG("unknow node ~w", [Node]),
    {noreply, State};


handle_info({nodeup, Node}, State) when Node =:= State#state.login_node ->
    ?ERROR_MSG("login server is up", []),
    timer:sleep(6000),
    ets:insert(ets_nodes_status, {login, true}),
    register_to_login(),
    {noreply, State};
    
    
handle_info(Info, State) ->
    ?DEBUG("unknow info ~w ~w", [Info, State]),
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------

register_to_login() ->
    {Host, Port} = mgeeg_config:get(host_port),
    gen_server:call({global, mgeel_line}, {register, Host, Port}).


do_reload() ->
    LoginNode = lists:foldl(
                  fun(Node, Acc) ->
                          case string:str(erlang:atom_to_list(Node), "mgeel@") =:= 1 of
                              true ->
                                  Node;
                              false ->
                                  Acc
                          end
                  end, none, [erlang:node() | erlang:nodes()]),
    case LoginNode =:= none of
        true ->
            erlang:throw(login_not_start);
        false ->
            #state{login_node=LoginNode, map_node=undefined, world_node=undefined}
    end.
