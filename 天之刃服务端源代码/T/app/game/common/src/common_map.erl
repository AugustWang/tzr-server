%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created :  2 Nov 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_map).
-include("common.hrl").
-include("common_server.hrl").

%% API
-export([
         get_warofcity_map_name/1,
         get_common_map_name/1,
         get_mission_fb_map_name/2,
         get_map_str_name/1,
         get_family_map_name/1,
         get_faction_id_by_map_id/1,
         exit/1,exit/2
        ]).

-export([
         info/2,
         is_doing_ybc/1,
         dynamic_create_monster/2,
         dynamic_delete_monster/2,
         del_event_timer/1,
         reg_new_event_timer/4,
         trigger_event_timer/0,
         send_to_all_map/1,
         family_info/2,
         get_map_family_id/0,
         set_map_family_id/2
        ]).

-export([show_boss_group/1,
         reset_boss_group/1,
         close_boss_group/1,
         %%英雄副本排行
         hero_fb_ranking/1]).

-define(dict_event_timer_cd, dict_event_timer_cd).%%控制检查间隔时间
-define(event_timer_cd_time, 5).%%累计被loop5次就计算

exit(Reason)->
    erlang:exit(self(),Reason).
exit(PID,Reason)->
    erlang:exit(PID,Reason).

info(PName, Info) when erlang:is_list(PName) orelse erlang:is_atom(PName) ->
    case global:whereis_name(PName) of
        undefined ->
            ignore;
        PID ->
            PID ! Info
    end.

family_info(FamilyID, Info) ->
    case global:whereis_name(get_family_map_name(FamilyID)) of
        undefined ->
            ignore;
        PID ->
            PID ! {mod_map_family, Info}
    end.

get_family_map_name(FamilyID) when is_integer(FamilyID) ->
    lists:concat(["map_family_", FamilyID]).

%% 拼凑地图争夺战地图进程的名字
get_warofcity_map_name(MapID) when is_integer(MapID) ->
    lists:concat(["map_warofcity_", MapID]).

get_common_map_name(MapID) when is_integer(MapID) ->
    lists:concat([mgee_map_, MapID]).

%% @doc 获取任务副本地图进程名
get_mission_fb_map_name(MapID, RoleID) ->
    lists:concat(["mgee_mission_fb_map_", MapID, "_", RoleID]).

%%@doc 获取地图的中文名称，例如 11000->"云州-太平村"
get_map_str_name(MapID) when is_integer(MapID) ->
    [MapNameStr] = common_config_dyn:find(map_info,MapID),
    MapNameStr.

is_doing_ybc(RoleID) ->
    [RoleState] = db:dirty_read(?DB_ROLE_STATE, RoleID),
    RoleYbcState = RoleState#r_role_state.ybc,
    if
        RoleYbcState =:= 3 ->
            true;
        RoleYbcState =:= 2 ->
            true;
        RoleYbcState =:= 1 ->
            true; 
        true ->
            false
    end.
	

dynamic_create_monster(notice, Key) ->
    [Msg] = common_config_dyn:find(dynamic_monster, {notice, Key}),
    common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], ?BC_MSG_TYPE_CHAT_WORLD, Msg);
dynamic_create_monster(monster, Key) ->
    [MonsterList] = common_config_dyn:find(dynamic_monster, {monster, Key}),
    lists:foreach(
      fun({MapID, TMonsterList}) ->
              MapProcessName = common_misc:get_map_name(MapID),
              catch global:send(MapProcessName, {mod_map_monster, {dynamic_create_monster2, TMonsterList}})
      end, MonsterList);
dynamic_create_monster(boss_group,{BossID,Key})->
    [CountryList] = common_config_dyn:find(dynamic_monster,{boss_group,Key}),
    CountryMapIDList = 
        lists:foldl(
          fun({CountryID,MapList},TmpMapIDList)->
                  {MapID,BornNum,MonsterList,_}=lists:nth(mod_refining:get_random_number([Weight||{_MapID,_BornNum,_MonsterList,Weight}<-MapList],0,1), MapList),
                  {ok,NewMonsterList} = random_monster_list(BornNum,MonsterList,[]),
                  MapProcessName = common_misc:get_map_name(MapID),
                  ?TRY_CATCH(global:send(MapProcessName, {mod_map_monster, {dynamic_create_boss_group, NewMonsterList,Key}}),Err),
                  [{CountryID,common_misc:get_born_info_by_map(MapID)}|TmpMapIDList]
          end,[],CountryList),
    mod_dynamic_monster:update_born_map(BossID,CountryMapIDList),
    [{NoticeType,Notice}] = common_config_dyn:find(dynamic_monster,{notice_boss_group,Key}),
    case NoticeType of
        world->
            [{_CountryID,MapID}|_TCountryMapIDList] = CountryMapIDList,
            case common_misc:get_born_info_by_map(MapID) of
                error->?DEBUG("error, no map born point",[]);
                {MapID, TX, TY}->
                    common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], 
                                                       ?BC_MSG_TYPE_CHAT_WORLD, 
                                                       Notice,
                                                       [?BOSS_GROUP_KEY,MapID,TX,TY,BossID])
            end;
        map->
            lists:foreach(
              fun({CountryID,MapID})->
                      case common_misc:get_born_info_by_map(MapID) of
                          error->?DEBUG("error, no map born point",[]);
                          {MapID, TX, TY}->
                              common_broadcast:bc_send_msg_faction(CountryID,
                                                                   [?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_CHAT],
                                                                   ?BC_MSG_TYPE_CHAT_COUNTRY,
                                                                   lists:flatten(io_lib:format(Notice, common_config_dyn:find(map_info,MapID))),
                                                                   [?BOSS_GROUP_KEY,MapID,TX,TY,BossID]
                                                                  )
                      end
              end, CountryMapIDList)
    end;
dynamic_create_monster(MapIDList, CreateDataList) ->
    lists:foreach(fun(MapID) ->
        MapProcessName = common_misc:get_map_name(MapID),
        lists:foreach(fun(CreateData) ->
            catch global:send(MapProcessName, {mod_map_monster, {dynamic_create_monster, CreateData}})
        end, CreateDataList)
    end, MapIDList).

dynamic_delete_monster(boss_group,Key)->
    [CountryList] = common_config_dyn:find(dynamic_monster,{boss_group,Key}),
    lists:foreach(
      fun({_CountryID,MapList})->
        lists:foreach(fun({MapID,_,_,_})->
                              MapProcessName = common_misc:get_map_name(MapID),
                              catch global:send(MapProcessName, {mod_map_monster, {dynamic_delete_boss_group, Key}})
                      end,MapList)  
      end,CountryList);
dynamic_delete_monster(MapIDList, MonsterIDList) ->
	lists:foreach(fun(MapID) ->
        MapProcessName = common_misc:get_map_name(MapID),
        lists:foreach(fun(MonsterID) ->
            catch global:send(MapProcessName, {mod_map_monster, {dynamic_delete_monster, MonsterID}})
        end, MonsterIDList)
    end, MapIDList).

%% Info=ID:int()|all:atom()
reset_boss_group(Info)->
     MapProcessName = common_misc:get_map_name(?DEFAULT_MAPID),
     catch global:send(MapProcessName, {mod_map_monster,{reset_boss_group,Info}}).

close_boss_group(Info)->
     MapProcessName = common_misc:get_map_name(?DEFAULT_MAPID),
     catch global:send(MapProcessName, {mod_map_monster,{close_boss_group,Info}}).

show_boss_group(Info)->
     MapProcessName = common_misc:get_map_name(?DEFAULT_MAPID),
     catch global:send(MapProcessName, {mod_map_monster,{show_boss_group,Info}}).

hero_fb_ranking(Info)->
     MapProcessName = common_misc:get_map_name(?DEFAULT_MAPID),
     catch global:send(MapProcessName, {mod_hero_fb,{hero_fb_ranking,Info}}).

del_event_timer(ID) ->
    db:dirty_delete(?DB_MAP_EVENT_TIMER, ID).

%%TimeType-->one_time一次性
reg_new_event_timer(TimeType, Time, InfoType, Info) ->
    {ok, ID} = common_misc:trans_get_new_counter(map_event_timer),
    Data = #r_map_event_timer{id=ID, 
                              time_type=TimeType, 
                              time=Time, 
                              info_type=InfoType, 
                              info=Info},
    db:dirty_write(?DB_MAP_EVENT_TIMER, Data),
    Data.

trigger_event_timer() ->
    case get(?dict_event_timer_cd) of
        CDTime when CDTime >= ?event_timer_cd_time ->
            List = db:dirty_match_object(
                     ?DB_MAP_EVENT_TIMER, 
                     #r_map_event_timer{_='_'}),
            
            trigger_event_timer_2(List),
            put(?dict_event_timer_cd, 0);
        CDTime ->
            put(?dict_event_timer_cd, CDTime+1)
    end.

trigger_event_timer_2([]) ->
    ignore;
trigger_event_timer_2([EventTimeData|List]) ->
    TimeType = EventTimeData#r_map_event_timer.time_type,
    case TimeType of
        one_time ->
            trigger_one_time(EventTimeData);
        Other ->
            ?ERROR_MSG("~ts:~w", ["未知的地图活动时间类型", Other]),
            ignore
    end,
    trigger_event_timer_2(List).

trigger_one_time(EventTimeData) ->
    #r_map_event_timer{id=_ID, 
                       time=Time, 
                       info_type=InfoType, 
                       info=Info} = EventTimeData,
    
    TimeDiff = common_misc:diff_time(Time),
    if
        TimeDiff >= 0 ->
            trigger_send_info(InfoType, Info, EventTimeData),
            db:dirty_delete_object(?DB_MAP_EVENT_TIMER, EventTimeData);
        true ->
            ignore
    end.

trigger_send_info({map, event_timer_info, MapIDS}, Info, EventTimeData) ->
    lists:foreach(
      fun(MapID) ->
        common_misc:send_to_map(MapID, {event_timer_info, Info, EventTimeData})
      end, MapIDS);

trigger_send_info({map, diy_info, MapIDS}, Info, _EventTimeData) ->
    lists:foreach(
      fun(MapID) ->
        common_misc:send_to_map(MapID, Info)
      end, MapIDS);

trigger_send_info({role_map_strict, event_timer_info, RoleIDS}, Info, EventTimeData) ->
    lists:foreach(
      fun(RoleID) ->
        common_misc:send_to_rolemap(strict, RoleID, {event_timer_info, Info, EventTimeData})
      end, RoleIDS);

trigger_send_info({role_map_strict, diy_info, RoleIDS}, Info, _EventTimeData) ->
    lists:foreach(
      fun(RoleID) ->
        common_misc:send_to_rolemap(strict, RoleID, Info)
      end, RoleIDS);

trigger_send_info({map_router, event_timer_info}, Info, EventTimeData) ->
    global:send(mgeem_router, {event_timer_info, Info, EventTimeData});
trigger_send_info({map_router, diy_info}, Info, _EventTimeData) ->
    global:send(mgeem_router, Info);

trigger_send_info(Other, Info, EventTimeData) ->
    ?ERROR_MSG("~ts:Other ~w Info ~w EventTimeData ~w", ["未知的地图活动时间类型", Other, Info, EventTimeData]).

%% @doc 发消息到所有地图
send_to_all_map(Info) ->
    MapNameList = 
        case catch db:dirty_match_object(?DB_MAP_ONLINE, #r_map_online{_='_'}) of
            {'EXIT', _} -> [];
            []-> [];
            RecList ->
                [R#r_map_online.map_name || R <-RecList]
        end,
    lists:foreach(
      fun(MapProcessName) ->
              case global:whereis_name(MapProcessName) of
                  undefined ->
                      ignore;
                  PID ->
                      PID ! Info
              end
      end,MapNameList).

%%获取门派地图对应的门派ID
get_map_family_id() ->
     get(family_map_family_id).


%%设置门派地图的门派ID
set_map_family_id(MapName,10300) ->
    [FamilyIDStr] = string:tokens(MapName, "map_family_"),
    {FamilyID,_} = string:to_integer(FamilyIDStr),
    put(family_map_family_id,{FamilyID,MapName});
set_map_family_id(_MapName,_) ->
    ok.

get_faction_id_by_map_id(MapId) ->
    MapId rem 10000 div 1000.

random_monster_list(_BornNum,[],NewMonsterList)->
    {ok,NewMonsterList};
random_monster_list(BornNum,MonsterList,NewMonsterList)->
    case BornNum>0 of
        true->
            Num = common_tool:random(1, erlang:length(MonsterList)),
            MonsterInfo = lists:nth(Num, MonsterList),
            random_monster_list(BornNum-1,lists:delete(MonsterInfo, MonsterList),[MonsterInfo|NewMonsterList]);
        false->
            {ok,NewMonsterList}
    end.


