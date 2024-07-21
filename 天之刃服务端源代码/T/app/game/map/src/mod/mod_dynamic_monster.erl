%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2011, 
%%% @doc
%%%
%%% @end
%%% Created : 21 Jul 2011 by  <>
%%%-------------------------------------------------------------------
-module(mod_dynamic_monster).

-include("mgeem.hrl").
-include("dynamic_monster.hrl").

-define(check_boss_group_init_interval,10000).

-export([
         hook_map_init/1,
         hook_map_loop/1]).

-export([show_boss_group/1,
         reset_boss_group/1,
         close_boss_group/1,
         update_born_map/2]).

-export([check_init_boss_group/1,
         get_boss_group_list/0,
         get_boss_group_view_list/0,
         boss_group_view_init/2]).



%% @doc 地图每秒循环
hook_map_loop(Now) ->
    hook_dynamic_monster(Now),
    hook_boss_group_reflash(Now),
    hook_boss_group(Now).

hook_dynamic_monster(Now)->
    case get_activity_list() of
        undefined ->
            ignore; 
        [] ->
            ignore;
        [{StartTime, R}|TActivityList] ->
            if StartTime > Now ->
                   ignore;
               true ->
                   hook_dynamic_monster2(R, TActivityList)
            end
    end.
hook_dynamic_monster2(R, TActivityList) ->
    #r_activity_dynamic_monster{type=Type, config_key=ConfigKey} = R,
    if Type =:= ?TYPE_BORN_NOTICE ->
            common_map:dynamic_create_monster(notice, ConfigKey);
       true ->
            common_map:dynamic_create_monster(monster, ConfigKey)
    end,
    set_activity_list(TActivityList).

hook_boss_group(Now)->
    case get_boss_group_list() of
        [{StartTime,ID,HandleType,RList}|TBossGroupList]->
            if StartTime >Now->
                   ignore;
               true->
                   %%reset_boss_group_view(StartTime,HandleType),
                   hook_boss_group2(ID,RList,HandleType,TBossGroupList)
            end;
        _->ignore
    end.

hook_boss_group2(ID,[R],HandleType,TActivityList) ->
    #r_activity_dynamic_monster{type=Type, config_key=ConfigKey} = R,
    if HandleType=:=delete andalso Type =:=?TYPE_BORN_MONSTER ->
           common_map:dynamic_delete_monster(boss_group,ConfigKey);
       HandleType=:=create andalso Type =:=?TYPE_BORN_MONSTER ->
           common_map:dynamic_create_monster(boss_group, {ID,ConfigKey});
       true->ignore
    end,
    set_boss_group_list(TActivityList).


%%重设某类型的怪物
reset_boss_group(all)->
    hook_map_init1(?BOSS_GROUP_KEY).

show_boss_group(_)->
    NextReflashTime = get_boss_group_next_reflash_time(),
    ViewList = get_boss_group_view_list(),
    List = get_boss_group_list(),
    ?ERROR_MSG("BOSS_GROUP==============~nNextReflashTime:~w.~nViewList:~w.~nList:~w~n",[NextReflashTime,ViewList,List]).


%%该项清除仅当天有效！
%%清除创建项，提高删除项优先级
close_boss_group(ID)->
    Now = common_tool:now(),
    WaitingList = get_boss_group_list(),
    WaitingList1 =    
        if ID =:=all ->
               set_boss_group_view_list({date(),[]}),
               lists:foldl(fun({_StartTime,_ID,HandleType,RList},TmpWaitingList)->
                                   case HandleType of
                                       delete->[{Now,_ID,HandleType,RList}|TmpWaitingList];
                                       _->TmpWaitingList
                                   end
                           end, [], WaitingList);
           is_integer(ID) ->
               {DateTime,BossGroupViewList} = get_boss_group_view_list(),
               case lists:keyfind(ID, 1, BossGroupViewList) of
                   false->[];
                   BossGroupView->set_boss_group_view_list({DateTime,lists:delete(BossGroupView, BossGroupViewList)})
               end,
               lists:foldl(fun({StartTime,_ID,HandleType,RList},TmpWaitingList)->
                                   case ID=:=_ID of
                                       true->
                                           case HandleType of
                                               delete->[{Now,_ID,HandleType,RList}|TmpWaitingList];
                                               create->TmpWaitingList
                                           end;
                                       false->[{StartTime,_ID,HandleType,RList}|TmpWaitingList]
                                   end
                           end, [], WaitingList)
        end,
    set_boss_group_list(lists:keysort(1,WaitingList1)).

   
%% 是否需要重设时间
hook_boss_group_reflash(TimeStamp)->
    NextReflashTime=get_boss_group_next_reflash_time(),
    case NextReflashTime<TimeStamp of
        true->
            WaitingList=get_boss_group_list(),
            {Date, Time}=common_tool:seconds_to_datetime(TimeStamp),
            case common_config_dyn:find(mccq_activity, ?BOSS_GROUP_KEY) of
                []->ignore;
                [ConfigList]->
                    NewWaitingList = 
                    lists:foldl(fun(Config,TmpWaitingList)->
                                     create_tomorrow_waiting_list(Config,{Date,Time},TmpWaitingList)        
                                end, WaitingList, ConfigList),
                    NewNextReflashTime = common_tool:datetime_to_seconds({Date,?BOSS_GROUP_CONFIG_CREATE_TIME})+86400,
                    set_boss_group_next_reflash_time(NewNextReflashTime),
                    set_boss_group_list(lists:keysort(1, NewWaitingList))
            end;
        false->
            ignore
    end.
    



%% @doc 地图初始化hook   ================================================
hook_map_init(?DEFAULT_MAPID) ->
    case common_config_dyn:find(mccq_activity, ?ACTIVITY_CONFIG_KEY) of
        [] ->
            ignore;
        [ActKeyList] when is_list(ActKeyList) ->
            [hook_map_init1(ActKey)||ActKey<-ActKeyList];
        _ ->
            ok
    end;
hook_map_init(_MapId) ->
    ignore. 

hook_map_init1(ActKey)->
    case common_config_dyn:find(mccq_activity, ActKey) of
        [] ->
            ignore;
        [ConfigList] ->
            Now = common_tool:now(),
            case ActKey of
                ?BOSS_GROUP_KEY->
                    erlang:send_after(?check_boss_group_init_interval,self(),{mod_map_monster,{check_init_boss_group,ConfigList}});
                _->
                    hook_map_init2(ConfigList,Now, [])
            end
    end.

check_init_boss_group(ConfigList)->
    case common_config_dyn:find(dynamic_monster,boss_group_mapid_list) of
        [MapIDList]->
            Flag =  lists:all(
                      fun(MapID)-> 
                              MapProcessName = common_map:get_common_map_name(MapID),
                              global:whereis_name(MapProcessName)=/=undefined 
                      end, 
                      MapIDList),
            case Flag of
                true->
                    Date = date(),
                    DateTime = {Date,time()},
                    boss_group_view_init(ConfigList,DateTime),
                    hook_boss_group_init(ConfigList,DateTime,[]),           
                    %% 今天凌晨0点+86400+5*3600 =明天凌晨五点
                    NextReflashTime = common_tool:datetime_to_seconds({Date,?BOSS_GROUP_CONFIG_CREATE_TIME})+86400,
                    set_boss_group_next_reflash_time(NextReflashTime);
                _->
                    ?ERROR_MSG("有地图还没启动  等10秒",[]),
                    erlang:send_after(?check_boss_group_init_interval,self(),{mod_map_monster,{check_init_boss_group,ConfigList}})
            end;  
        _->
            ?ERROR_MSG("boss群出生地图没有配置",[]),
            ignore
    end.


%%-----------初始化动态生成怪列表---------------------
hook_map_init2([], _Now, ActivityList) ->
    if
        ActivityList =:= [] ->
            ignore;
        true ->
            set_activity_list(lists:keysort(1, ActivityList))
    end;
hook_map_init2([H|TConfigList], Now, ActivityList) ->
    {IsOpen, StartTime, _EndTime, #r_activity_dynamic_monster{type=Type}=Record} = H,
    ActivityList2 = 
        if
            (not IsOpen) orelse (Type =/= ?TYPE_BORN_NOTICE andalso Type =/= ?TYPE_BORN_MONSTER) ->
                ActivityList;
            true ->
                StartTimeStamp = common_tool:datetime_to_seconds(StartTime),
                if StartTimeStamp > Now ->
                        [{StartTimeStamp, Record}|ActivityList];
                   true ->
                        ActivityList
                end
        end,
    hook_map_init2(TConfigList, Now, ActivityList2).

%%----------------------------初始化boss群----------------------

hook_boss_group_init([],_NowDateTime,WaitingList)->
    if WaitingList=:=[] ->
           ignore;
       true->
           %% 前端请求活动列表用
           SortWaitingList = lists:keysort(1, WaitingList),
           set_boss_group_list(SortWaitingList)
    end;

%% 地图初始化时要准备今天和明天的列表，每天凌晨5点的时候添加后一天的boss出生列表
hook_boss_group_init([H|TConfigList],NowDateTime,WaitingList)->
    NewWaitingList =
    case H#r_boss_group.type of
        ?ACTIVITY_TYPE_EVERY_DAY->
            WaitingList1 = create_today_waiting_list(H,NowDateTime,WaitingList),
            create_tomorrow_waiting_list(H,NowDateTime,WaitingList1);
        _->WaitingList
    end,
    %%生成boss列表 维护
    hook_boss_group_init(TConfigList,NowDateTime,NewWaitingList).

%% 只创造今天的等待列表
create_today_waiting_list(BossGroup,{NowDate,NowTime},WaitingList)->
    Now = common_tool:datetime_to_seconds({NowDate,NowTime}),
    #r_boss_group{id=ID,is_open=IsOpen,
                  start_day=StartDate,end_day=EndDate,
                  start_time = StartTime,end_time=EndTime,
                  last_time=LastTime,space_time =SpaceTime,
                  dynamic_monster_list=DynamicMonsterList} = BossGroup,
    %%1.开启的 2.结束时间大于当前时间 3.起始日期零点距离当前时间不超过一天
    case IsOpen %% 1.开启的
        andalso Now<get_time_stamp({EndDate,EndTime}) %% 当前时间小于活动结束时间
        andalso StartDate =< NowDate  %% 活动开始日期在今天之前 （包括今天）
        andalso EndTime>=NowTime of   %% 活动结束时间要大于当前时间
        true->
            %%当前时间距离活动计算时间不足24小时
            TodayEndTimeStamp = get_time_stamp({NowDate,EndTime}),
            TodayStartTimeStamp = get_time_stamp({NowDate,StartTime}),
            %% 获取下一条要生成的数据的时间
            StartTimeStamp = get_next_time_stamp(Now,TodayStartTimeStamp,TodayEndTimeStamp,SpaceTime),
            tool_create_waiting_list(StartTimeStamp,TodayEndTimeStamp,LastTime,SpaceTime,ID,DynamicMonsterList,WaitingList);
        false->
            WaitingList
    end.


get_next_time_stamp(Now,StartTime,EndTime,SpaceTime)->
    case StartTime<EndTime andalso StartTime<Now andalso EndTime=< Now of
        true->
            get_next_time_stamp(Now,StartTime+SpaceTime,EndTime,SpaceTime);
        false->
            StartTime
    end.
%% 创造第二天的等待列表
create_tomorrow_waiting_list(BossGroup,{NowDate,_NowTime},WaitingList)->
    #r_boss_group{id=ID,is_open=IsOpen,
                  start_day=StartDate,end_day=EndDate,
                  start_time=StartTime,end_time=EndTime,
                  last_time=LastTime,space_time =SpaceTime,
                  dynamic_monster_list=DynamicMonsterList} = BossGroup,
    %%1.开启的 2.结束时间大于等于第二天3.起始日期零点距离当前时间不超过一天
    TodayDateTime = common_tool:datetime_to_seconds({NowDate,{0,0,0}}),
    case IsOpen  %%1.开启的
             andalso TodayDateTime+86400 =< get_time_stamp({EndDate,{0,0,0}})   %% 2.结束时间大于等于第二天
             andalso get_time_stamp({StartDate,{0,0,0}})=<TodayDateTime+86400 of        %%3.起始日期小于等于第二天
        true->
            StartTimeStamp = get_time_stamp({NowDate,StartTime})+86400,
            EndTimeStamp = get_time_stamp({NowDate,EndTime})+86400,
            tool_create_waiting_list(StartTimeStamp,EndTimeStamp,LastTime,SpaceTime,ID,DynamicMonsterList,WaitingList);
        
        false->WaitingList
    end.

tool_create_waiting_list(StartTimeStamp,EndTimeStamp,LastTime,SpaceTime,ID,DynamicMonsterList,WaitingList)->
    case StartTimeStamp>=EndTimeStamp of
        true->[];
        false->
            lists:foldr(fun(BeginTimeStamp,Acc)-> 
                                [{BeginTimeStamp+LastTime,ID,delete,DynamicMonsterList}|[{BeginTimeStamp,ID,create,DynamicMonsterList}|Acc]] 
                        end, 
                        WaitingList,
                        lists:seq(StartTimeStamp, EndTimeStamp, SpaceTime))
    end.
 
get_time_stamp({TheDay,TheTime})->
    case TheDay of
        {open_day,Days}->
            {{OpenYear,OpenMonth,OpenDay},{_,_,_}}=common_config:get_open_day(),
            common_tool:datetime_to_seconds({{OpenYear,OpenMonth,OpenDay},TheTime})+Days*86400;
        {_Year,_Month,_Day}->
            common_tool:datetime_to_seconds({{_Year,_Month,_Day},TheTime});
        _->0
    end.

%% ---------------------------------------------

boss_group_view_init(ConfigList,{Date,_Time})->
    DateTime = common_tool:datetime_to_seconds({Date,{0,0,0}}),
    {_OldDateTime,OldViewList}=get_boss_group_view_list(),
    ViewList =
        lists:foldr(
          fun(BossGroup,TmpViewList)->
                  case get_time_stamp({BossGroup#r_boss_group.start_day,{0,0,0}})=< DateTime
                           andalso get_time_stamp({BossGroup#r_boss_group.end_day,{0,0,0}})>=DateTime  of
                      true->
                          BornPlaceList = 
                          case lists:keyfind(BossGroup#r_boss_group.id,1,OldViewList) of
                              false->
                                  [];
                              {_ID,_StartTime,_EndTime,_LastTime,_SpaceTime,OldBornPlaceList}->
                                  OldBornPlaceList
                          end,
                            [{BossGroup#r_boss_group.id,
                              BossGroup#r_boss_group.start_time,
                              BossGroup#r_boss_group.end_time,
                              BossGroup#r_boss_group.last_time,
                              BossGroup#r_boss_group.space_time,
                              BornPlaceList}|TmpViewList];
                      false->TmpViewList
                  end
          end,[],ConfigList),
    set_boss_group_view_list({DateTime,ViewList}),
    {DateTime,ViewList}.

%% reset_boss_group_view(TimeStamp,create)->
%%     {DateTime,_ViewList}=get_boss_group_view_list(),
%%     case TimeStamp>DateTime+86400 of
%%         true->
%%             ConfigList=
%%               case common_config_dyn:find(mccq_activity,?BOSS_GROUP_KEY) of
%%                   []->[];
%%                   [_ConfigList]->_ConfigList
%%               end,
%%             boss_group_view_init(ConfigList,{date(),{0,0,0}});
%%         false->ignore
%%     end;
%% reset_boss_group_view(_,_)->
%%     ignore.

update_born_map(ID,List)->
    {DateTime,ViewList} = get_boss_group_view_list(),
    case lists:keyfind(ID, 1, ViewList) of
        false->ignore;
        {ID,StartTime,EndTime,LastTime,SpaceTime,_} ->
            set_boss_group_view_list({DateTime,lists:keyreplace(ID, 1, ViewList, {ID,StartTime,EndTime,LastTime,SpaceTime,List})})
    end.
                           
% =================================================

set_boss_group_next_reflash_time(Time)->
    erlang:put(?BOSS_GROUP_NEXT_REFLASH_TIME,Time).

get_boss_group_next_reflash_time()->
    case erlang:get(?BOSS_GROUP_NEXT_REFLASH_TIME) of
        undefined->9999999999;
        Time->Time
    end.

set_boss_group_view_list(Value)->
    erlang:put(?BOSS_GROUP_VIEW_LIST,Value).

get_boss_group_view_list()->
    case erlang:get(?BOSS_GROUP_VIEW_LIST) of
        undefined->{0,[]};
        L->L
    end.


set_boss_group_list(List)->
    erlang:put(?BOSS_GROUP_LIST,List).

get_boss_group_list()->
    case erlang:get(?BOSS_GROUP_LIST) of
        undefined->
            [];
        L->L
    end.


set_activity_list(List) ->
    erlang:put(?ACTIVITY_LIST, List).

get_activity_list() ->
    case erlang:get(?ACTIVITY_LIST) of
        undefined ->
            [];
        L ->
            L
    end.
