%%% -------------------------------------------------------------------
%%% Author  : XiaoSheng
%%% Description :
%%%
%%% Created : 2011-2-13
%%% -------------------------------------------------------------------
-module(nodes_montior_server).

-behaviour(gen_server).
-export([start_link/2, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {info, ping_node}).

start_link(Info, PingNode) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Info, PingNode], []).


init([Info, PingNode]) ->
    ok = net_kernel:monitor_nodes(true),
    {ok, #state{info=Info, ping_node=PingNode}}.

    
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(re_ping_node, #state{ping_node=PingNode}=State) ->
    case net_adm:ping(list_to_atom(PingNode)) of
        pong ->
            ok;
        pang ->
            erlang:send_after(2000, self(), re_ping_node)
     end,
    {noreply, State};

handle_info({nodedown, Node}, #state{info=Info, ping_node=PingNode}=State) when Node =:= PingNode ->
    send_msg_to_master(Node, Info, "退出了"),
    erlang:send_after(2000, self(), re_ping_node),
    {noreply, State};

handle_info({nodedown, Node}, #state{info=Info, ping_node=_PingNode}=State) ->
	send_msg_to_master(Node, Info, "退出了"),
    {noreply, State};

%%handle_info({nodeup, Node}, #state{info=Info, ping_node=PingNode}=State) ->
	%%send_msg_to_master(Node, Info, "启动了"),
    %%{noreply, State};
    
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

send_msg_to_master(Node, Info, Msg) ->
	try
        {ok, ConfigList} = file:consult("mobiles.config"),

		{_, FromMobile} = lists:keyfind(from_mobile, 1, ConfigList),
		{_, FromMobilePwd} = lists:keyfind(from_mobile_pwd, 1, ConfigList),
        {_, MasterMobileList} = lists:keyfind(master_mobile_list, 1, ConfigList),
		MasterMobileListStr = string:join(MasterMobileList, ","),
		
		Command = lists:concat([
			"fetion --mobile=",
			FromMobile,
			" --pwd=",
			FromMobilePwd,
			" --to=", 
			MasterMobileListStr, 
			" --msg-utf8=",
			Node,
			",",
			Msg,
            ",",
            Info
			]),
		
			Port = erlang:open_port({spawn, Command}, [stream]),
    		erlang:port_close(Port)
	catch
		_:Error ->
			io:format("~ts:~w", ["发送短信给管理员时发生了错误", Error])
	end.