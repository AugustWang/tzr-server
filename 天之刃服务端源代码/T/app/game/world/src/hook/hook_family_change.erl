%%% -------------------------------------------------------------------
%%% Author  : xiaosheng
%%% Description : 门派变更
%%%
%%% Created : 2010-7-22
%%% -------------------------------------------------------------------
-module(hook_family_change).
-export([
         hook/1
        ]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeew.hrl").

%% --------------------------------------------------------------------
%% Function: hook/1
%% Description: hook检查口
%% Parameter: int() NewFamilyID 新门派ID
%% Parameter: record() OldRoleBase #p_role_base 未改变门派前的角色信息
%% Returns: ok
%% --------------------------------------------------------------------
hook({RoleID, NewFamilyID, OldFamilyID}) ->
    hook_chat(NewFamilyID, OldFamilyID, RoleID).


%% ====================================================================
%% 第三方hook代码放置在此
%% ====================================================================

%%聊天
hook_chat(NewFamilyID, OldFamilyID, RoleName) ->
    if
        OldFamilyID =/= 0 ->
            common_misc:chat_leave_family_channel(RoleName, OldFamilyID);
        true ->
            ignore
    end,

    if
        NewFamilyID =/= 0 ->
            common_misc:chat_join_family_channel(RoleName, NewFamilyID);
        true ->
            ignore
    end.

