%% Author: QingliangCn
%% Created: 2010-3-17
%% Description: TODO: Add description to mgeel_packet_s2s
-module(mgeel_s2s_packet).

-include("mgeel.hrl").

-export([
         packet/4,
         unpack/1,
         send/2,
         recv/1,
         get_decode_func/2,
         get_encode_func/2,
         encode/3,
         decode/3,
         encode_packet_send/5
        ]).


encode_packet_send(ClientSock, Unique, Module, Method, DataRecord) ->
    BinData =  mgeel_s2s_packet:packet( 
                 Unique, Module, Method, mgeel_s2s_packet:encode(Module, Method, DataRecord)),
    ?DEBUG("BinData:~w~n",[erlang:byte_size(BinData)]),
    mgeel_s2s_packet:send(ClientSock, BinData).


packet(Unique, Module, Method, Data) when is_list(Module) and is_list(Method) ->
    Module2 = list_to_binary(Module),
    Method2 = list_to_binary(Method),
    packet(Unique, Module2, Method2, Data);
packet(Unique, Module, Method, Data) when is_binary(Module) and is_binary(Method) ->
    ModuleLen = erlang:byte_size(Module),
    MethodLen = erlang:byte_size(Method),
    <<Unique:32, ModuleLen:32, MethodLen:32, Module/binary, Method/binary, Data/binary>>;
packet(_, _, _, _) ->
    throw({error, args_type_wrong}).


unpack(DataRaw) ->
    <<Unique:32, ModuleLen:32, MethodLen:32, Data2/binary>> = DataRaw,
    ?DEBUG("~w,~w,~w~n",[ModuleLen, MethodLen, Data2]),
    <<Module:ModuleLen/binary, Method:MethodLen/binary, Data3/binary>> =  Data2,
    ?DEBUG("~w,~w,~w~n",[Module, Method, Data3]),
    case Data3 of
        <<>> -> 
            {Unique, Module, Method, <<>>};     
        _    -> 
            
            R = decode(Module, Method, Data3),
            {Unique, Module, Method, R}
    end.


send(ClientSock, Bin)when is_port(ClientSock) ->
    ?DEBUG("SocketInfo:~p~n",[inet:peername(ClientSock)]),
    case erlang:port_command(ClientSock, Bin, [force]) of
        true -> 
            ?DEBUG("packet send ~w ok ", [Bin]),
            ok;
        false ->
            {error,closed}
    end.


recv(ClientSock) ->
    case gen_tcp:recv(ClientSock, 0) of
        {ok, RealData} ->
            ?DEBUG("S2S Packet:~w~n",[RealData]),
            {ok, mgeel_s2s_packet:unpack(RealData)};
        {error, Reason} ->
            ?ERROR_MSG("read packet failed: ~w on socket ~w", [Reason, ClientSock]),
            {error, Reason}
    end.


get_decode_func(Module, Method) ->
    common_tool:list_to_atom(
      lists:concat(
        [decode_adm_, common_tool:to_list(Module), "_", common_tool:to_list(Method), "_tos"])).


get_encode_func(Module, Method) ->
    common_tool:list_to_atom(
      lists:concat(
        [encode_adm_, common_tool:to_list(Module), "_",common_tool:to_list(Method), "_toc"])).


encode(Module, Method, DataRecord) ->
    apply(behavior_pb, get_encode_func(Module, Method), [DataRecord]).
    

decode(Module, Method, DataBin) ->
    apply(behavior_pb, get_decode_func(Module, Method), [DataBin]).
