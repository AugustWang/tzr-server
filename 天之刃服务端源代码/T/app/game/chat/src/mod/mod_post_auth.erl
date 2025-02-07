-module(mod_post_auth).
-include("mgeec.hrl").

-export([
         auth_chat_in_pairs/3,
         auth_chat_in_channel/3
        ]).

auth_chat_in_pairs(DataRecord, RoleChatInfo, State) ->
    ToRoleName = DataRecord#m_chat_in_pairs_tos.to_rolename,
    ShowType = DataRecord#m_chat_in_pairs_tos.show_type,
    FromRoleName = RoleChatInfo#p_chat_role.rolename,
    if
        FromRoleName =:= ToRoleName ->
            ToRoleID = common_misc:get_roleid(ToRoleName),
            FailDataRecord = 
                #m_chat_in_pairs_toc{succ=false, 
                                     reason=?_LANG_SYSTEM_ERROR,
                                     show_type = ShowType,
                                     error_code=?CHAT_ERROR_CODE_TALK_TO_SELF,
                                     to_role_id=ToRoleID},
            {false, talk_to_self, FailDataRecord};
        true ->
            auth_chat_in_pairs_2(DataRecord, RoleChatInfo, State)
    end.
auth_chat_in_pairs_2(DataRecord, RoleChatInfo, State) ->
    ToRoleName = DataRecord#m_chat_in_pairs_tos.to_rolename,
    ShowType = DataRecord#m_chat_in_pairs_tos.show_type,
    ToRolePName = common_misc:chat_get_role_pname(ToRoleName),
    case global:whereis_name(ToRolePName) of
        undefined ->
            ToRoleID = common_misc:get_roleid(ToRoleName),
            FailDataRecord = 
                #m_chat_in_pairs_toc{succ=false, 
                                     reason=?_LANG_CHAT_ROLE_NOT_ONLINE,
                                     show_type = ShowType,
                                     error_code=?CHAT_ERROR_CODE_ROLE_NOT_ONLINE,
                                     to_role_id=ToRoleID},
            {false, role_not_online, FailDataRecord};
        _ ->
            auth_chat_in_pairs_3(DataRecord, RoleChatInfo, State)
    end.
auth_chat_in_pairs_3(DataRecord, RoleChatInfo, State) ->
    ToRoleName = DataRecord#m_chat_in_pairs_tos.to_rolename,
    ShowType = DataRecord#m_chat_in_pairs_tos.show_type,
    BlackList = get(black_list),
    ?DEBUG("auth_chat_in_pairs_3, torolename: ~w, blacklist: ~w", [ToRoleName, BlackList]),

    case lists:keyfind(ToRoleName, #p_chat_role.rolename, BlackList) of
        false ->
            auth_chat_in_pairs_4(DataRecord, RoleChatInfo, State);
        _ ->
            ToRoleID = common_misc:get_roleid(ToRoleName),
            FailDataRecord = 
                #m_chat_in_pairs_toc{succ=false, 
                                     reason=?_LANG_CHAT_ROLE_IN_BLACKLIST,
                                     show_type = ShowType,
                                     error_code=?CHAT_ERROR_CODE_IN_ROLE_BLACKLIST,
                                     to_role_id=ToRoleID},
            {false, in_role_blacklist, FailDataRecord}
    end.

auth_chat_in_pairs_4(DataRecord, _RoleChatInfo, State) ->
    ToRoleName = DataRecord#m_chat_in_pairs_tos.to_rolename,
    ShowType = DataRecord#m_chat_in_pairs_tos.show_type,
    case auth_time_limit(State) of
        true ->
            true;
        false ->
            ToRoleID = common_misc:get_roleid(ToRoleName),
            FailDataRecord = 
                #m_chat_in_pairs_toc{succ=false, 
                                     reason=?_LANG_CHAT_TOO_FAST,
                                     show_type = ShowType,
                                     error_code=?CHAT_ERROR_CODE_CHAT_TOO_FAST,
                                     to_role_id=ToRoleID},
            {false, chat_too_fast, FailDataRecord}
    end.

auth_chat_in_channel(DataRecord, RoleChatInfo, State) ->
    CheckTimeLimit = auth_time_limit(State),
    if
        CheckTimeLimit =:= true ->
            auth_chat_in_channel_2(DataRecord, RoleChatInfo, State);
        true ->
            CheckTimeLimit
    end.
auth_chat_in_channel_2(DataRecord, _RoleChatInfo, State) ->
    ChannelSign = DataRecord#m_chat_in_channel_tos.channel_sign,
    RoleID = State#chat_role_state.role_id,
    case mgeec_misc:check_in_channel(ChannelSign, RoleID) of
        true ->
            %% 判断禁言
            case mod_chat_ban:auth_ban(RoleID) of
                true->
					true;
                    %%auth_chat_in_channel_3(DataRecord, RoleChatInfo, State);
                {false, Message}->
                    {false, Message}
            end;
        false ->
            {false, ?_LANG_CHAT_NOT_IN_CHANNEL}
    end.
%%auth_chat_in_channel_3(DataRecord, _RoleChatInfo, State) ->
%%    ChannelSign = DataRecord#m_chat_in_channel_tos.channel_sign,
%%    WorldChannelSign = common_misc:chat_get_world_channel_pname(),
%%    if
%%        ChannelSign =:= WorldChannelSign ->
%%            RoleID = State#chat_role_state.role_id,
%%            {ok, RoleAttr} = common_misc:get_dirty_role_attr(RoleID),
%%            RoleSilver = RoleAttr#p_role_attr.silver,
%%            RoleSilverBind = RoleAttr#p_role_attr.silver_bind,
%%            if
%%                RoleSilverBind + RoleSilver < 200 ->
%%                    {false, ?_LANG_CHAT_WORLDCHAT_NEED_MONEY};
%%                true ->
%%                    true
%%            end;
%%        true ->
%%            true
%%    end.

auth_time_limit(State) ->
    LastChatTime = 
        State#chat_role_state.last_chat_time,

    Check = 
        common_misc:diff_time(LastChatTime) >= ?CHAT_TIME_LIMIE,
    if
        Check =:= true ->
            true;
        true ->
            false
    end.
