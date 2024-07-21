%%% -------------------------------------------------------------------
%%% Author  : xiaosheng
%%% Description : 学习技能
%%%
%%% Created : 2010-9-5
%%% -------------------------------------------------------------------
-module(hook_add_friend).
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
%% Parameter: int() RoleID 角色id
%% Parameter: int() FromRoleID 发起人ID
%% Parameter: int() ToRoleID 接受人ID
%% Returns: ok
%% --------------------------------------------------------------------
%%检查
hook({_RoleID, FromRoleID, ToRoleID}) ->
    %% 特殊任务事件
    catch common_misc:send_to_rolemap(FromRoleID,{hook_mission_event,{special_event,FromRoleID,?MISSON_EVENT_ADD_FRIEND}}),
    catch common_misc:send_to_rolemap(ToRoleID,{hook_mission_event,{special_event,ToRoleID,?MISSON_EVENT_ADD_FRIEND}}),
    hook_achievement(FromRoleID, ToRoleID),
    ok.

%% 成就 add by caochuncheng 2011-03-07
hook_achievement(FromRoleId, ToRoleId) ->
    FromFriendList = 
        case mod_friend_server:get_dirty_friend_list(FromRoleId) of
            {error,_FReason} ->
                [];
            FList ->
                FList
        end,
    FromEventIdList = 
        if erlang:length(FromFriendList) >= 50 ->
                [401001,401002];
           erlang:length(FromFriendList) >= 200 ->
                [401001,401002,401003];
           true ->
                [401001]
        end,    
    catch common_mod_goal:hook_friend_num(FromRoleId, erlang:length(FromFriendList)),
    catch common_achievement:hook(#r_achievement_hook{role_id = FromRoleId,event_ids = FromEventIdList}),
    ToFriendList = 
        case mod_friend_server:get_dirty_friend_list(ToRoleId) of
            {error,_TReason} ->
                [];
            TList ->
                TList
        end,
    ToEventIdList = 
        if erlang:length(ToFriendList) >= 50 ->
                [401001,401002];
           erlang:length(ToFriendList) >= 200 ->
                [401001,401002,401003];
           true ->
                [401001]
        end,
    catch common_mod_goal:hook_friend_num(ToRoleId, erlang:length(ToFriendList)),
    catch common_achievement:hook(#r_achievement_hook{role_id = ToRoleId,event_ids = ToEventIdList}),
    ok.

