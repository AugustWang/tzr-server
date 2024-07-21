%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 14 Nov 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_warofking).

-include("common.hrl").

%% API
-export([
         is_begin_apply/1,
         is_begin_war/1,
         is_family_join/2
        ]).


%%王座争霸战尚未开始报名
-define(WAROFKING_STATUS_NOT_BEGIN, 0).
%%王座争霸战开始报名
-define(WAROFKING_STATUS_BEGIN_APPLY, 1).
%%王座争霸战正在进行中
-define(WAROFKING_STATUS_BEGIN_WAR, 2).


%%判断王座争霸战是否已经开始报名申请了
is_begin_apply(FactionID) ->
    [#db_warofking{status=Status}] = db:dirty_read(?DB_WAROFKING, FactionID),
    Status =:= ?WAROFKING_STATUS_BEGIN_APPLY.

%%判断王座争霸战是否已经开始了
is_begin_war(FactionID) ->
    [#db_warofking{status=Status}] = db:dirty_read(?DB_WAROFKING, FactionID),
    Status =:= ?WAROFKING_STATUS_BEGIN_WAR.

%%判断某个门派是否报名参与了本届王座争霸战
is_family_join(FactionID, FamilyID) ->
    [#db_warofking{join_families=FamilyList}] = db:dirty_read(?DB_WAROFKING, FactionID),
    lists:keymember(FamilyID, #p_family_info.family_id, FamilyList).
