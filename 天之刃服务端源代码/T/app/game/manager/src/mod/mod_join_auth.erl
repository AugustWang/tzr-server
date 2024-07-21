-module(mod_join_auth).
-include("manager.hrl").

-export([auth/1]).

auth(Socket) ->
    spawn(fun() -> do_1(Socket) end).

do_1(Socket) ->
    case gen_tcp:recv(Socket, 0) of

        {ok, ?HEART_BEAT} ->
            ?DEV("~ts", ["收到心跳包 (:"]),
            do_1(Socket);

        {ok, Handshaking}  
          when erlang:byte_size(Handshaking) =:= 23 ->
            ?DEV("~ts:~w", ["收到握手包", Handshaking]),
            do_2(Socket);
        
        Other ->
            ?ERROR_MSG("~ts:~w", ["收到未知数据包", Other]),
            catch erlang:port_close(Socket),
            exit(unknow_packet)
    end.

do_2(Socket) ->
    PacketModule = common_packet:new(common_config_dyn, find_manage_mm_map),
    case PacketModule:recv(Socket) of
        
        {ok, heartbeat} ->
            ?DEV("~ts", ["收到心跳包 (:"]),
            do_2(Socket);

        {ok, {Unique, _AuthModule, _AuthMethod, DataRecord}} ->
            do_3(Unique, Socket, DataRecord, PacketModule);

        Other ->
            ?DEV("~ts:~w", ["无法识别的验证登录数据", Other]),
            catch erlang:port_close(Socket),
            exit(unknow_auth_data)
    end.

%%验证登录
do_3(_Unique, Socket, _DataRecord, PacketModule) ->
    AdminID = 0,
    AdminProcess = spawn(fun() -> ignore end),
    recv_loop(AdminID, AdminProcess, Socket, PacketModule).

%%开始循环接受消息
recv_loop(AdminID, AdminProcess, Socket, PacketModule) ->
      case PacketModule:recv(Socket) of
          {ok, heartbeat} ->
              ?DEV("~ts", ["收到心跳包 (:"]),
              recv_loop(AdminID, AdminProcess, Socket, PacketModule);

          {ok, {Unique, ModuleID, MethodID, DataRecord}} ->

              RouterData = {MethodID, 
                            ModuleID, 
                            AdminID, 
                            DataRecord, 
                            Socket, 
                            Unique},
              %%TODO 伪代码
              AdminProcess ! RouterData,

              recv_loop(AdminID, AdminProcess, Socket, PacketModule);
          {error,catch_error} ->
              exit(AdminProcess, normal);
          Other ->
              ?ERROR_MSG("~ts:~w", ["收到未知数据包", Other]),
              exit(AdminProcess, offline)
      end.