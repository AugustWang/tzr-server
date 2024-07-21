%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2010, 
%%% @doc
%%% 好友度变化hook
%%% @end
%%% Created :  9 Dec 2010 by  <>
%%%-------------------------------------------------------------------
-module(hook_friendly_change).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeew.hrl").


-export([
         hook/1
        ]).


%% API
%% %%type: 方式，1、组队，2、聊天
hook({RoleId, FriendId, Friendly, Type}) ->
    ?DEBUG("~ts,RoleId=~w, FriendId=~w, Friendly=~w, Type=~w",["好友度变化hook",RoleId, FriendId, Friendly, Type]),
    hook_achievement(RoleId,FriendId),
    ok.

%% 成就系统添加hook
hook_achievement(FromRoleId,ToRoleId) ->
    FromFriendList = 
        case mod_friend_server:get_dirty_friend_list(FromRoleId) of
            {error,_FReason} ->
                [];
            FList ->
                FList
        end,
    {FromFriendList2,FromFriendList100,FromFriendList1000} = 
        lists:foldl(
          fun(FR,{AccF2,AccF100,AccF1000}) ->
                  NewAccF2 = 
                      if FR#r_friend.friendly >= 2 ->
                              [FR|AccF2];
                         true ->
                              AccF2
                      end,
                  NewAccF100 = 
                      if FR#r_friend.friendly >= 100 ->
                              [FR|AccF100];
                         true ->
                              AccF100
                      end,
                  NewAccF1000 = 
                      if FR#r_friend.friendly >= 1000 ->
                              [FR|AccF1000];
                         true ->
                              AccF1000
                      end,
                  {NewAccF2,NewAccF100,NewAccF1000}
          end,{[],[],[]},FromFriendList),
    FromEventIdList = [],
    FromEventIdList2 = 
        if erlang:length(FromFriendList2) >= 5 ->
                [100004 | FromEventIdList];
           true ->
                FromEventIdList
        end,
    FromEventIdList3 = 
        if FromFriendList100 =/= [] ->
                [401004|FromEventIdList2];
           true ->
                FromEventIdList2
        end,
    FromEventIdList4 = 
        if FromFriendList1000 =/= [] ->
                [401005|FromEventIdList3];
           true ->
                FromEventIdList3
        end,
    if FromEventIdList4 =/= [] ->
            catch common_achievement:hook(#r_achievement_hook{role_id = FromRoleId,event_ids = FromEventIdList4});
       true ->
            next
    end,
    ToFriendList = 
        case mod_friend_server:get_dirty_friend_list(ToRoleId) of
            {error,_TReason} ->
                [];
            TList ->
                TList
        end,
    {ToFriendList2,ToFriendList100,ToFriendList1000} = 
        lists:foldl(
          fun(TR,{AccT2,AccT100,AccT1000}) ->
                  NewAccT2 = 
                      if TR#r_friend.friendly >= 2 ->
                              [TR|AccT2];
                         true ->
                              AccT2
                      end,
                  NewAccT100 = 
                      if TR#r_friend.friendly >= 100 ->
                              [TR|AccT100];
                         true ->
                              AccT100
                      end,
                  NewAccT1000 = 
                      if TR#r_friend.friendly >= 1000 ->
                              [TR|AccT1000];
                         true ->
                              AccT1000
                      end,
                  {NewAccT2,NewAccT100,NewAccT1000}
          end,{[],[],[]},ToFriendList),
    ToEventIdList = [],
    ToEventIdList2 = 
        if erlang:length(ToFriendList2) >= 5 ->
                [100004 | ToEventIdList];
           true ->
                ToEventIdList
        end,
    ToEventIdList3 =
        if ToFriendList100 =/= [] ->
                [401004 | ToEventIdList2];
           true ->
                ToEventIdList2
        end,
    ToEventIdList4 =
        if ToFriendList1000 =/= [] ->
                [401005|ToEventIdList3];
           true ->
                ToEventIdList3
        end,
    if ToEventIdList4 =/= [] ->
            catch common_achievement:hook(#r_achievement_hook{role_id = ToRoleId,event_ids = ToEventIdList4});
       true ->
            next
    end,
    ok.
