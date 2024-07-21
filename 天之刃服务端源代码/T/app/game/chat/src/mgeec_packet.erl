-module(mgeec_packet).

-include("mgeec.hrl").

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
            {ok, mgeec_packet:unpack(RealData)};
        {error, closed} ->
            {error, catch_error};
	{error, Reason} ->
            ?ERROR_MSG("~ts:~w", ["接收数据失败", Reason]),
            {error, catch_error}
    end.

%% @desc sometime we need the Timeout option
recv(ClientSock, Timeout) ->
    case gen_tcp:recv(ClientSock, 0, Timeout) of
        {ok, ?HEART_BEAT} ->
            {ok, heartbeat};
        {ok, RealData} ->
            {ok, mgeec_packet:unpack(RealData)};
        {error, closed} ->
            {error, catch_error};
        {error, Reason} ->
            ?ERROR_MSG("~ts:~w", ["接收数据失败", Reason]),
            {error, catch_error}
    end.


packet_encode_send(ClientSock, Unique, Module, Method, DataRecord) ->
    case (catch packet_encode_send2(ClientSock, Unique, Module, Method, DataRecord) ) of
	{'EXIT', Info} ->
            ?ERROR_MSG("~ts:~w~n~ts:~w~n~ts:~w~n~ts:~w~n~ts:~w~n~ts:~w", 
                       ["打包并发送数据失败了",
                        "=========================",
                        "错误原因",
                        Info,
                        "前端Unique",
                        Unique,
                        "模块",
                        Module,
                        "方法",
                        Method,
                        "数据",
                        DataRecord
                        ]);
        {exception, Info} -> 
            ?ERROR_MSG("~ts:~w~n~ts:~w~n~ts:~w~n~ts:~w~n~ts:~w~n~ts:~w", 
                       ["打包并发送数据失败了",
                        "=========================",
                        "错误原因",
                        Info,
                        "前端Unique",
                        Unique,
                        "模块",
                        Module,
                        "方法",
                        Method,
                        "数据",
                        DataRecord
                        ]);
	_ ->
            ok
    end. 		


packet_encode_send2(ClientSock, Unique, Module, Method, DataRecord) ->
    DataBin = encode(Method, DataRecord),
    send(ClientSock, mgeec_packet:packet(Unique, Module, Method, DataBin)).


send(ClientSock, Bin) ->
    ?DEV("~ts:~w", ["准备通过Socket发送数据", Bin]),
    case gen_tcp:send(ClientSock, Bin) of
	ok -> 
            ok;
	{error, Reason} -> 
            exit(self(), {socket_send_error, Reason}),
            {error, Reason}
    end.


send(ClientSock, Unique, Module, Method, DataRecord) ->
    Bin = packet(Unique, Module, Method, encode(Method, DataRecord)),
    send(ClientSock, Bin).


packet_encode(Unique, Module, Method, DataRecord) ->
    packet(Unique, Module, Method, encode(Method, DataRecord)).


packet(Unique, Module, Method, Data) when is_integer(Module) and is_integer(Method) ->
    if erlang:byte_size(Data) >= 100 ->
            DataCompress = zlib:compress(Data),
            <<1:1, Unique:15, Module:8, Method:16, DataCompress/binary>>;
       true ->
            <<Unique:16, Module:8, Method:16, Data/binary>>
    end;
packet(Unique, Module, Method, Data) ->
    throw({error, {packet_failed, Unique, Module, Method, Data}}).


unpack(DataRaw) ->
    <<IsZip:1, Unique:15, ModuleID:8, MethodID:16, DataBin/binary>> = DataRaw,

    ?DEV("~ts~w~n~ts:~w~n~ts:~w~n~ts:~w~ts:~w", 
         [
          "解包Socket数据",
          "============================",
          "压缩标志",
          IsZip,
          "前端Unique",
          Unique,
          "模块",
          ModuleID,
          "方法",
          MethodID
         ]),

    case IsZip of
	0 -> 
            {Unique, ModuleID, MethodID, decode(MethodID, DataBin)};
	1 -> 
            case DataBin of
		<<>> -> 
                    {Unique, ModuleID, MethodID, <<>>};		
		_ ->	
                    {Unique, ModuleID, MethodID, decode(MethodID, zlib:uncompress(DataBin))}
            end
    end.


get_decode_func(Module_Method) ->
    erlang:list_to_atom(
      lists:concat(
        [decode_m_, erlang:atom_to_list(Module_Method), "_tos"])
     ).


get_encode_func(Module_Method) ->
    erlang:list_to_atom(
      lists:concat(
        [encode_m_, erlang:atom_to_list(Module_Method), "_toc"])
     ).


encode(Method, DataRecord) ->
    ?DEV("~ts:~w ~ts:~w", ["编码码操作, 方法ID", Method, "数据", DataRecord]),
    case common_config_dyn:find_mm_map( Method) of
        [Module_Method] ->
	    apply(all_pb, get_encode_func(Module_Method), [DataRecord]);
        _ ->
            throw({exception, {unknow_method, Method}})
    end.


decode(Method, DataBin) ->
    ?DEV("~ts:~w", ["解码操作, 方法ID", Method]),
    case common_config_dyn:find_mm_map( Method) of
        [ Module_Method ] ->
            DataRecord = apply(all_pb, get_decode_func(Module_Method), [DataBin]),
            ?DEV("~ts:~w", ["解码结果", DataRecord]),
            DataRecord;
        _ ->
            throw({exception, {unknow_method, Method}})
    end.
