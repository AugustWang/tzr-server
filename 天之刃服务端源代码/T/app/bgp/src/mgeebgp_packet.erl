%% Author: bisonwu
%% Created: Jul 13, 2010
%% Description: TODO: Add description to mgeebgp_packet
-module(mgeebgp_packet).

%%
%% Include files
%%
-include("common.hrl").
-include("mgeebgp_comm.hrl").

 

%%
%% Exported Functions
%%
-export([decode/2,unpack/1]).
-export([send_toc/3,send_admin/3,send/2]).

%%
%% API Functions
%%

-define(SEND_BGP_TOC(Data),send(ClientSock,
                                packet_encode(?BGP,?BGP_LOGIN,encode_m_bgp_login_toc,Data))).


%% @doc send the result to client
%% @spec send_toc/2 
send_toc(ClientSock,ID,{ok})->
    DataToc = #m_bgp_login_toc{id=ID,succ=true},
    ?SEND_BGP_TOC(DataToc);
send_toc(ClientSock,ID,{error,Reason})->
    
    case Reason of
        Bin when is_binary(Reason)->
            DataToc = #m_bgp_login_toc{id=ID,succ=false,reason=Bin };
        timeout->
            DataToc = #m_bgp_login_toc{id=ID,succ=false,reason= ?_LANG_TIMEOUT };
        _ ->
            DataToc = #m_bgp_login_toc{id=ID,succ=false,reason= ?_LANG_SYSTEM_ERROR }
    end,
    ?SEND_BGP_TOC(DataToc).

%% @doc send the admin result
%% @spec send_admin(ClientSock::sock(),Result::string(),RequestName::string())
send_admin(_ClientSock,_Result,RequestName)->
    ?ERROR_MSG("暂时不支持admin操作，RequestName=~w",[RequestName]),
    ignore.

%%
%% Local Functions
%%


send(ClientSock, Bin) ->
    %% ?TEST_MSG("packet send ~p ", [Bin]),
    PacketLen = erlang:byte_size(Bin),
    SendBin = <<PacketLen:32, Bin/binary>>,
    case gen_tcp:send(ClientSock, SendBin) of
        ok -> ok;
        {error, closed} -> {error, closed};
        {error, Reason} -> {error, Reason}
    end.
  

unpack(DataRaw) ->
    <<IsZip:1, Unique:15,  ModuleID:8, MethodID:16, Data/binary>> = DataRaw,
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

packet_encode(Module, Method, Fun_Str, DataRecord) when is_atom(Fun_Str)->
    packet(0,Module, Method, encode(Fun_Str, DataRecord)).


packet(Unique, Module, Method, Data) when is_integer(Module) and is_integer(Method) ->
    if erlang:byte_size(Data) >= 100 ->
            DataCompress = zlib:compress(Data),
            <<1:1, Unique:15, Module:8, Method:16, DataCompress/binary>>;
       true ->
            <<Unique:16, Module:8, Method:16, Data/binary>>
    end;
packet(_, _, _, _) ->
    throw({error, args_type_wrong}).



%%@param Fun_Str:atom() eg:decode_m_bgp_login_tos
decode(Fun_Str, DataBin) when is_atom(Fun_Str)->
    apply(all_pb, Fun_Str, [DataBin]).


%%@param Fun_Str:atom() eg:encode_m_bgp_login_toc
encode(Fun_Str, DataRecord1) when is_atom(Fun_Str) ->
    apply(all_pb, Fun_Str, [DataRecord1]).

