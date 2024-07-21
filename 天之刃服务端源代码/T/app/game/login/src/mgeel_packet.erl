%% Author: Administrator
%% Created: 2010-1-3
%% Description: TODO: Add description to mgee_packet_decode
-module(mgeel_packet).

-include("mgeel.hrl").

-export([
         recv/1, 
         send/2, 
         send/5,
         recv/2, 
         packet_encode_send/5,
         packet_encode/4
        ]).

-export([
         packet/4, 
         unpack/1,
         get_decode_func/1,
         get_encode_func/1,
         encode/2,
         decode/2
        ]).


%% here we don't care the cross domain file
recv(ClientSock) ->
    case gen_tcp:recv(ClientSock, 0) of
	{ok, ?HEART_BEAT} ->
            {ok, heartbeat};
	{ok, RealData} ->
            {ok, mgeel_packet:unpack(RealData)};
	{error, Reason} ->
            ?WARNING_MSG("read packet data failed: ~w on socket ~w", [Reason, ClientSock]),
            {error, catch_error}
    end.

%% @desc sometime we need the Timeout option
recv(ClientSock, Timeout) ->
    case gen_tcp:recv(ClientSock, 0, Timeout) of
        {ok, ?HEART_BEAT} ->
            {ok, heartbeat};
        {ok, RealData} ->
            {ok, mgeel_packet:unpack(RealData)};
        {error, Reason} ->
            ?ERROR_MSG("read packet data failed: ~w on socket ~w", [Reason, ClientSock]),
            {error, catch_error}
    end.


packet_encode_send(ClientSock, Unique, Module, Method, DataRecord) ->
	case (catch packet_encode_send2(ClientSock, Unique, Module, Method, DataRecord) ) of
	{'EXIT', Info} -> 
		?ERROR_MSG("error when packet_encode_send Module:~w, Method:~w, Info:~w", 
 					[Module, Method, Info]);
    {exception, Info} -> 
        ?ERROR_MSG("error when packet_encode_send Module:~w, Method:~w, Info:~w", 
                    [Module, Method, Info]);
	_ ->
		ok
	end. 		



packet_encode_send2(ClientSock, Unique, Module, Method, DataRecord) ->
    ?DEBUG("~w ~w ~w ~w ~w", [ClientSock, Unique, Module, Method, DataRecord]),
    DataBin = encode(Method, DataRecord),
    send(ClientSock, mgeel_packet:packet(Unique, Module, Method, DataBin)).


send(ClientSock, Bin) ->
    case gen_tcp:send(ClientSock, Bin) of
	ok -> 
            ok;
	{error, Reason} -> 
            ?WARNING_MSG("send data ~w error : ~w", [Bin, Reason]),
            {error, Reason}
    end.


send(ClientSock, Unique, Module, Method, DataRecord) ->
    Bin = mgeel_packet:packet(Unique, Module, Method, encode(Method, DataRecord)),
    send(ClientSock, Bin).


packet_encode(Unique, Module, Method, DataRecord) ->
    mgeel_packet:packet(Unique, Module, Method, encode(Method, DataRecord)).


packet(Unique, Module, Method, Data) when is_integer(Module) and is_integer(Method) ->
    if erlang:byte_size(Data) >= 100 ->
            DataCompress = zlib:compress(Data),
            <<1:1, Unique:15, Module:8, Method:16, DataCompress/binary>>;
       true ->
            <<Unique:16, Module:8, Method:16, Data/binary>>
    end;
packet(_, _, _, _) ->
    throw({error, args_type_wrong}).


unpack(DataRaw) ->
    <<IsZip:1, Unique:15, ModuleID:8, MethodID:16, Data/binary>> = DataRaw,
    case IsZip of
	0 -> 
            {Unique, ModuleID, MethodID, Data};
	1 -> 
            case Data of
                                                % some method, may be not protobuf data.
		<<>> -> 
                    {Unique, ModuleID, MethodID, <<>>};		
		_    ->	
                    {Unique, ModuleID, MethodID, zlib:uncompress(Data)}
            end
    end.


get_decode_func(Module_Method) ->
    common_tool:list_to_atom(
      lists:concat(
        [decode_m_, common_tool:to_list(Module_Method), "_tos"])).


get_encode_func(Module_Method) ->
    common_tool:list_to_atom(
      lists:concat(
        [encode_m_, common_tool:to_list(Module_Method), "_toc"])).


encode(Method, DataRecord) ->
    case common_config_dyn:find_mm_map( Method) of
        [ Module_Method ] ->
	    apply(all_pb, get_encode_func(Module_Method), [DataRecord]);
        _ ->
            throw({exception, unknow_method})
    end.


decode(Method, DataBin) ->
    case common_config_dyn:find_mm_map( Method) of
        [ Module_Method ] ->
            apply(all_pb, get_decode_func(Module_Method), [DataBin]);
        _ ->
            throw({exception, unknow_method})
    end.
