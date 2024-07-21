%% Author: Qingliang.Cn
%% Created: 2010-06-30
%% Description: 简单的封包、解包模块
-module(mgeer_packet).

%%
%% Include files
%%
-include("mgeer.hrl").

%%
%% Exported Functions
%%
-export([
         recv/1, 
         send/4,
         recv/2, 
         packet/3, 
         unpack/1,
         packet_send/4,
		 decode/2
        ]).


recv(ClientSock) ->
    case gen_tcp:recv(ClientSock, 0) of
        {ok, <<"heartbeat">>} ->
            {ok, heartbeat};
        {ok, RealData} ->
            {Unique, BehaviorList} = mgeer_packet:unpack(RealData),
            %%直接在这里确认unique包
            sure_unique(ClientSock, Unique),
            {ok, BehaviorList};
        {error, Reason} ->
            ?ERROR_MSG("~ts: ~p , socket ~p", ["读取数据出错", Reason, ClientSock]),
            {error, Reason}
    end.


%%确认收到某个包了
sure_unique(ClientSock, Unique) ->
    R = #b_server_unique_toc{unique=Unique},
    send(ClientSock, ?B_SERVER, ?B_SERVER_UNIQUE, R).


%% @desc 有时需要超时选项
recv(ClientSock, Timeout) ->
    case gen_tcp:recv(ClientSock, 0, Timeout) of
	{ok, RealData} ->
	    {ok, mgeer_packet:unpack(RealData)};
	{error, Reason} ->
	    ?ERROR_MSG("read packet data failed: ~p on socket ~p", [Reason, ClientSock]),
	    {error, Reason}
    end.


%%封包、发送
packet_send(ClientSock, Module, Method, DataRecord) ->
    send(ClientSock, mgeer_packet:packet(Module, Method, DataRecord)).


send(ClientSock, Bin) ->
    ?DEBUG("~ts: ~p", ["准备发送数据", Bin]),
    case gen_tcp:send(ClientSock, Bin) of
	ok -> 
            ok;
	{error, closed} -> 
            {error, closed};
	{error, Reason} -> 
            {error, Reason}
    end.


%%receiver发给behavior的包的格式为 {module, method, binary_data}
send(ClientSock, Module, Method, DataRecord) ->
    send(ClientSock, packet(Module, Method, DataRecord)).


packet(Module, Method, DataRecord) ->
    erlang:term_to_binary({Module, Method, DataRecord}).


%%解包
unpack(Data) ->
    <<Unique:32, Data2/binary>> = Data,
    BehaviorList = erlang:binary_to_term(Data2),
    {Unique, BehaviorList}.



%%@spec decode(Module_Method::atom(), DataBin::binary())-> #record
decode(Module_Method, DataBin) ->
	apply(behavior_pb, get_decode_func(Module_Method), [DataBin]).


get_decode_func(Module_Method) ->
	common_tool:list_to_atom(
	  lists:concat(
		[decode_b_, common_tool:to_list(Module_Method), "_tos"])).

