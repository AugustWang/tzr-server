-module(mod_join_auth).
-include("mgeec.hrl").

-export([auth/1]).

auth(Socket) ->
    spawn(fun() -> do_1(Socket) end).

do_1(Socket) ->
    case gen_tcp:recv(Socket, 23) of        
        {ok, ?CROSS_DOMAIN_FLAG} ->
            inet:setopts(Socket, [{packet, 2}]),
            do_2(Socket);
        {ok, Handshaking}  ->
            ?DEV("~ts:~w", ["收到握手包", Handshaking]),
            gen_tcp:recv(Socket, 2),
            inet:setopts(Socket, [{packet, 2}]),
            do_2(Socket);
        
        Other ->
            ?ERROR_MSG("~ts:~w", ["收到未知数据包", Other]),
            catch erlang:port_close(Socket),
            exit(unknow_packet)
    end.

do_2(Socket) ->
    case mgeec_packet:recv(Socket) of
        {ok, {Unique, ?CHAT, ?CHAT_AUTH, DataRecord}} ->
            do_3(Unique, Socket, DataRecord);
        Other ->
            ?DEV("~ts:~w", ["无法识别的验证登录数据", Other]),
            catch erlang:port_close(Socket),
            exit(unknow_auth_data)
    end.

do_3(Unique, Socket, AuthDataRecord) ->
            
    ?DEV("~ts:~w", ["收到验证登录数据", AuthDataRecord]),

    #m_chat_auth_tos{account=Account,
                     roleid=RoleID,
                     key=Key} = AuthDataRecord,

    AuthResult = 
        gen_server:call({global, mgeel_key_server}, 
                        {auth_key, erlang:list_to_binary(Account), RoleID, Key}),
    case AuthResult of
        ok ->
            do_4(Unique, RoleID, Socket);
        
        _ ->
            FailDataRecord = 
                #m_chat_auth_toc{succ=false, 
                                 reason=?_LANG_CHAT_AUTH_LOGIN_FAIL},

            mgeec_packet:packet_encode_send(Socket, 
                                            Unique,  
                                            ?CHAT, 
                                            ?CHAT_AUTH, 
                                            FailDataRecord),
            catch erlang:port_close(Socket),
            exit(auth_failed)
    end.
            

do_4(Unique, RoleID, Socket) ->
    
    case mgeec_misc:d_get_chat_init_data(RoleID) of

        false ->
            FailDataRecord = 
                #m_chat_auth_toc{succ=false, 
                                 reason=?_LANG_SYSTEM_ERROR},

            mgeec_packet:packet_encode_send(Socket, 
                                            Unique,  
                                            ?CHAT, 
                                            ?CHAT_AUTH, 
                                            FailDataRecord),
            catch erlang:port_close(Socket),
            exit(get_role_attr_fail);

        {RoleBase, RoleAttr, RoleExt, RoleChatInfo, ChannelList} -> 
            
            ?DEV("~ts:~w", ["玩家的频道列表", ChannelList]),

            SuccDataRecord = 
                #m_chat_auth_toc{succ=true, 
                                 channel_list=ChannelList, 
                                 black_list=[], 
                                 gm_auth=[]},

            mgeec_packet:packet_encode_send(Socket, 
                                            Unique,  
                                            ?CHAT, 
                                            ?CHAT_AUTH, 
                                            SuccDataRecord),

            RoleName = RoleBase#p_role_base.role_name,
            ChatRolePName = common_misc:chat_get_role_pname(RoleName),
            
            case global:whereis_name(ChatRolePName) of
                undefined ->
                    ok;
                OldPid ->
                    gen_server:call(OldPid, login_again)
            end,
            
            {ok, Pid} = 
                supervisor:start_child(mgeec_role_sup, 
                                       [{RoleID, 
                                         RoleName, 
                                         ChatRolePName, 
                                         Socket, 
                                         {RoleBase, RoleAttr, RoleExt, RoleChatInfo, ChannelList}, 
                                         self()}]),
            
            lists:foreach(
              fun(Item) ->
                      mgeec_misc:set_channel_role(Item, 
                                                  RoleID,
                                                  RoleName,
                                                  RoleChatInfo, 
                                                  Socket,
                                                  Pid)
                      
              end, ChannelList),


            erlang:link(Pid),
            recv_loop(RoleID, Pid, Socket)
    end.

recv_loop(RoleID, RoleProcess, Socket) ->
      case mgeec_packet:recv(Socket) of
          {ok, heartbeat} ->
              ?DEV("~ts", ["收到心跳包 (:"]),
              recv_loop(RoleID, RoleProcess, Socket);

          {ok, {Unique, ModuleID, MethodID, DataRecord}} ->

              RouterData = {MethodID, 
                            ModuleID, 
                            RoleID, 
                            DataRecord, 
                            Socket, 
                            Unique},

              mgeec_misc:cast_role_router({pid, RoleProcess}, RouterData),

              recv_loop(RoleID, RoleProcess, Socket);
          {error,catch_error} ->
              exit(RoleProcess, normal);
          Other ->
              ?ERROR_MSG("~ts:~w", ["收到未知数据包", Other]),
              exit(RoleProcess, offline)
      end.
