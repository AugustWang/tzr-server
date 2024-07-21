%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2011, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created :  7 Jan 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(user_event_disposit).

%% API
-export([handle/2]).

-include("mgeew.hrl").

handle(EventType, EventData) ->
    do_handle_event(EventType, EventData).

do_handle_event(?USER_EVENT_TYPE_FAMILY_YBC_CANCEL_ADD_SILVER, EventData) ->
    do_family_ybc_cancel(EventData),
    ok;
do_handle_event(?USER_EVENT_TYPE_FAMILY_YBC_GIVEUP_ADD_SILVER, EventData) ->
    do_family_ybc_giveup(EventData),
    ok;

do_handle_event(EventType, EventData) ->
    ?ERROR_MSG("~ts:~w", ["未知的角色托管事件", {EventType, EventData}]).

%% 处理门派拉镖取消
do_family_ybc_cancel(EventData) ->
    %% 首先要记录事件
    lists:foreach(
      fun({RoleID, Silver}) ->
              common_role_money:add(RoleID, [{silver, Silver, ?GAIN_TYPE_SILVER_CANCEL_FAMILY_YBC, ""}],
                                    {disposit, family_ybc_cancel_succ}, {disposit, family_ybc_cancel_failed}),
              %% 还原角色的状态
              db:transaction(
                fun() -> 
                        [RoleState] = db:read(?DB_ROLE_STATE, RoleID, write), 
                        db:write(?DB_ROLE_STATE, RoleState#r_role_state{ybc=undefined}, write)
                end),                                                                                        
              mgeew_user_event:record(RoleID, ?USER_EVENT_TYPE_FAMILY_YBC_CANCEL_ADD_SILVER, Silver)
      end, EventData),
    ok.
              

%% 处理帮众放弃门派拉镖
do_family_ybc_giveup(EventData) ->
    {RoleID, Silver} = EventData,
    mgeew_user_event:record(RoleID, ?USER_EVENT_TYPE_FAMILY_YBC_GIVEUP_ADD_SILVER, Silver),
    %% 还原角色的状态
    db:transaction(
      fun() -> 
              [RoleState] = db:read(?DB_ROLE_STATE, RoleID, write), 
              db:write(?DB_ROLE_STATE, RoleState#r_role_state{ybc=undefined}, write)
      end), 
    common_role_money:add(RoleID, [{silver, Silver, ?GAIN_TYPE_SILVER_GIVEUP_FAMILY_YBC, ""}],
                          {disposit, family_ybc_giveup_succ}, {disposit, family_ybc_giveup_failed}).

