%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 18 Nov 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_event).

-include("common_server.hrl").
-include("common.hrl").

%% API
-export([
         in_warofcity/0,
         check_is_waroffaction_time/0,
         check_is_warofking_time/0
        ]).

%% 当前是否处于地图争夺战期间
in_warofcity() ->
    true.

%% 检查是否国战时间  
check_is_waroffaction_time()->
    case db:dirty_read(?DB_WAROFFACTION, 1) of
        []->
            false;
        _->
            true
    end.

%% 检查是否国王争夺战时间
check_is_warofking_time()->
    case common_time:weekday() of
        6->
            WOKConfig = common_config:get_warofking_config(),
            {
             {apply_begin_time, {ApplyBeginTimeHour, ApplyBeginTimeMin}},
             {apply_time, ApplyTime},
             {safe_time, SafeTime},
             {war_time, WarTime}
            } = WOKConfig,
            {H,M,S} = erlang:time(),
            TodaySecond = H*60*60 + M*60 + S,
            WOKStartTime = ApplyBeginTimeHour*60*60 + ApplyBeginTimeMin*60 + ApplyTime,
            WOKEndTime = WOKStartTime + SafeTime + WarTime,
            TodaySecond>WOKStartTime andalso TodaySecond<WOKEndTime;
        _->
            false
    end.
