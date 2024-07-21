%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2011, 
%%% @doc
%%% 成就公共的 hook
%%% @end
%%% Created :  8 Mar 2011 by  <caochuncheng>
%%%-------------------------------------------------------------------
-module(common_hook_achievement).

-include("common.hrl").
-include("common_server.hrl").

%% API
-export([hook/1]).

%% {hook模块名 {事件 数据}}
hook({mod_item_effect,DataInfo}) ->
    ?TRY_CATCH( do_mod_item_effect(DataInfo),Err);
hook({mod_exchange,DataInfo}) ->
    ?TRY_CATCH( do_mod_exchange(DataInfo),Err);
hook({mod_stall,DataInfo}) ->
    ?TRY_CATCH( do_mod_stall(DataInfo),Err);
hook({mod_role2,DataInfo}) ->
    ?TRY_CATCH( do_mod_role2(DataInfo),Err);
hook({mod_depot,DataInfo}) ->
    ?TRY_CATCH( do_mod_depot(DataInfo),Err);
hook({mod_shop,DataInfo}) ->
    ?TRY_CATCH( do_mod_shop(DataInfo),Err);
hook({mod_training,DataInfo}) ->
    ?TRY_CATCH( do_mod_training(DataInfo),Err);
hook({mod_friend_server,DataInfo}) ->
    ?TRY_CATCH( do_mod_friend_server(DataInfo),Err);
hook({mod_mission,DataInfo}) ->
    ?TRY_CATCH( do_mod_mission(DataInfo),Err);
hook({mod_map_role,DataInfo}) ->
    ?TRY_CATCH( do_mod_map_role(DataInfo),Err);
hook({mod_flowers,DataInfo}) ->
    ?TRY_CATCH( do_mod_flowers(DataInfo),Err);
hook({mod_monster,DataInfo}) ->
    ?TRY_CATCH( do_mod_monster(DataInfo),Err);
hook({mod_fb,DataInfo}) ->
    ?TRY_CATCH( do_mod_fb(DataInfo),Err);
%% hook({mod_equip,DataInfo}) ->
%%     ?TRY_CATCH( do_mod_equip(DataInfo),Err);

hook({family_module,DataInfo}) ->
    ?TRY_CATCH( do_family_module(DataInfo),Err);
hook({mgeew_educate_server,DataInfo}) ->
    ?TRY_CATCH( do_mgeew_educate_server(DataInfo),Err);

hook({chat_module,DataInfo}) ->
    ?TRY_CATCH( do_chat_module(DataInfo),Err);
hook({chat_gm,{RoleId,EventId,AddProgress}}) ->
    catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [EventId],add_progress = AddProgress});
hook(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 玩家使用物品事件
do_mod_item_effect({add_hp,_RoleId}) ->
    %%common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406008]});
    ok;
do_mod_item_effect({add_mp,_RoleId}) ->
    %%common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406008]});
    ok;
do_mod_item_effect({add_big_hp,_RoleId}) ->
    %%common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406008]});
    ok;
do_mod_item_effect({add_big_mp,_RoleId}) ->
    %%common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406008]});
    ok;
do_mod_item_effect({used_extend_bag,RoleId}) ->
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406004]});
do_mod_item_effect(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.
%% 玩家交易
do_mod_exchange({exchange_confirm,RoleIdA,RoleIdB}) ->
    common_achievement:hook(#r_achievement_hook{role_id = RoleIdA,event_ids = [402002]}),
    common_achievement:hook(#r_achievement_hook{role_id = RoleIdB,event_ids = [402002]});
%% ExchangeInfo 结构为 r_npc_exchange_info
do_mod_exchange({npc_deal,RoleId,ExchangeInfo}) ->
    #r_npc_deal{deal_unique_id = DealUniqueId} = ExchangeInfo,
    [ChuelingList] = common_config_dyn:find(achievement_hook,event_306005),%% 使用除恶令兑换
    case lists:member(DealUniqueId,ChuelingList) of
        true ->
            common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [306005]});
        false ->
            ignore
    end;
do_mod_exchange(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 玩家摆摊
do_mod_stall({stall_request,_RoleId}) ->
    %% common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [402001]}); 
    ok;
do_mod_stall(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 玩家摆摊
do_mod_role2({zazen,_RoleId}) ->
    %%common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406005]});
    ok;
do_mod_role2({first_five_ele_attr,RoleId}) ->
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [302001]});
do_mod_role2({update_five_ele_attr,RoleId}) ->
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [302002]});
do_mod_role2({on_hook,RoleId}) -> %% 打坐挂机
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406006]});
do_mod_role2({level_change,RoleId,OldLevel,NewLevel}) -> %% 玩家升级
    do_role_level_change(RoleId,OldLevel,NewLevel);
do_mod_role2({conlogin,RoleId}) -> %% 玩家累积登录
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [201001]});
do_mod_role2({point_assgin,RoleId}) -> %% 分配属性点
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [408007]});
do_mod_role2(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.
do_role_level_change(RoleId,_OldLevel,NewLevel) ->
    EventLevelList = [{301002,10},{301003,20},{301004,30},{100005,40},{301005,40},
                      {301006,50},{301007,60},{301008,70},{301009,80},{301010,90},{301011,100},
                      {301012,110},{301013,120}],
    %% ,{301014,130},{301015,140},{301016,150} 暂时不开放
    EventIds = 
        lists:foldl(
          fun({EventId,CheckLevel},Acc) ->
                  if NewLevel =:= CheckLevel ->
                          [EventId|Acc];
                     NewLevel =:= CheckLevel + 1 ->
                          [EventId|Acc];
                     NewLevel =:= CheckLevel + 2 ->
                          [EventId|Acc];
                     NewLevel =:= CheckLevel + 3 ->
                          [EventId|Acc];
                     true ->
                          Acc
                  end
          end,[],EventLevelList),
    if EventIds =/= [] ->
            common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = EventIds});
       true ->
            ok
    end.
do_chat_module({?CHANNEL_TYPE_WORLD,RoleId}) -> %%世界
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [405001]});
do_chat_module({?CHANNEL_TYPE_FACTION,RoleId}) -> %%国家
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [405002]});
do_chat_module({?CHANNEL_TYPE_FAMILY,RoleId}) -> %%门派
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [405003]});
do_chat_module({?CHANNEL_TYPE_TEAM,RoleId}) -> %%组队
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [405004]});
do_chat_module({?CHANNEL_TYPE_LEVEL,_RoleId}) -> %%同等级频道
%%     common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [405007]});
    ok;
do_chat_module({?CHANNEL_TYPE_PAIRS,RoleId}) -> %%私聊类型
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [405005]});
do_chat_module({mod_broadcast,RoleId}) -> %%喇叭发言
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [405006]});
do_chat_module(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 玩家仓库操作
do_mod_depot({RoleId,BagId}) ->
    if BagId =:= 7 ->
            common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406001]});
       BagId =:= 8 ->
            common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406002]});
       BagId =:= 9 ->
            common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406003]});
       true ->
            ignore
    end;
do_mod_depot(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 商店模块
do_mod_shop({buy,_RoleId,_GoodsList}) ->
    %%common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406010]});
    ok;
do_mod_shop(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 训练营模块
do_mod_training({start,RoleId}) ->
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406007]});
do_mod_training(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 好友模块
do_mod_friend_server({modify_info,_RoleId}) -> %% 修改心情
    %%common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406009]});
    ok;
do_mod_friend_server(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.


%% 任务模块
do_mod_mission({citan,RoleId}) -> %% 刺探
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [306010]});
do_mod_mission({guotan,RoleId}) -> %% 国探
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [306010,306011]});
do_mod_mission({shoubian,RoleId}) -> %% 守边
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [306008]});
do_mod_mission({shoubian_zhanggong,RoleId}) -> %% 守边双倍战功
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [306009]});

do_mod_mission({mission_commit,MissionHookRecord}) 
  when erlang:is_record(MissionHookRecord,r_mission_hook)-> %% 完成任务并领取奖励
    do_mission_commit(MissionHookRecord);
%% MissionData 结构为 {RoleId,MissionId,HMissionType,{BigGroup, SmallGroup}}
do_mod_mission({mission_commit,MissionData}) -> %% 完成任务并领取奖励
    do_mission_commit(MissionData);
do_mod_mission(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.
%% 完成任务并领取奖励
do_mission_commit(MissionHookRecord) 
  when erlang:is_record(MissionHookRecord,r_mission_hook)->
    #r_mission_hook{role_id = RoleId,
                    mission_id = MissionId,
                    mission_type = _MissionType,
                    big_group = BigGroup,
                    small_group = _SmallGroup,
                    do_type = DoType,
                    do_times = DoTimes} = MissionHookRecord,
    case DoType of
        1 -> %% 自动任务
            do_mission_commit2(RoleId,MissionId,BigGroup,DoTimes);
        _ ->
            do_mission_commit2(RoleId,MissionId,BigGroup,1)
    end;
%% MissionData 结构为 {RoleId,MissionId,HMissionType,{BigGroup, SmallGroup}}
do_mission_commit(MissionData) ->
    case MissionData of
        {RoleId,MissionId,_HMissionType,0} ->
            do_mission_commit2(RoleId,MissionId,0,1);
        {RoleId,MissionId,_HMissionType,{BigGroup, _SmallGroup}} ->
            do_mission_commit2(RoleId,MissionId,BigGroup,1);
        _ ->
            ignore
    end.
do_mission_commit2(RoleId,MissionId,BigMissionGroup,AddProgress) ->
    %% 根据任务id来判断成就的关系
    [Event305001List] = common_config_dyn:find(achievement_hook,event_305001),%% 完成所有新手任务
    [Event305002List] = common_config_dyn:find(achievement_hook,event_305002),%% 完成横涧山的所有主线任务
    [Event305003List] = common_config_dyn:find(achievement_hook,event_305003),%% 完成鄱阳湖的所有主线任务
    [Event305004List] = common_config_dyn:find(achievement_hook,event_305004),%% 完成平江的所有主线任务
    [Event305005List] = common_config_dyn:find(achievement_hook,event_305005),%% 完成杏花岭的所有主线任务
    [Event305006List] = common_config_dyn:find(achievement_hook,event_305006),%% 完成西凉的所有主线任务
    [Event305007List] = common_config_dyn:find(achievement_hook,event_305007),%% 完成大漠的所有主线任务
    [Event305008List] = common_config_dyn:find(achievement_hook,event_305008),%% 完成安南的所有主线任务
    [Event305009List] = common_config_dyn:find(achievement_hook,event_305009),%% 完成泉州的所有主线任务
    [Event305010List] = common_config_dyn:find(achievement_hook,event_305010),%% 完成土木堡的所有主线任务
    [Event305011List] = common_config_dyn:find(achievement_hook,event_305011),%% 完成浙东的所有主线任务
    [Event305012List] = common_config_dyn:find(achievement_hook,event_305012),%% 第一次完成英雄任务
    [Event305013List] = common_config_dyn:find(achievement_hook,event_305013),%% 完成所有英雄任务
    [JianGongLiYeList] = common_config_dyn:find(achievement_hook,event_jiangongliye),%% 建功立业任务 建功立业任务组id
    [ChuELingList] = common_config_dyn:find(achievement_hook,event_chueling),%% 除恶令
    EventList = [{Event305001List,305001},{Event305002List,305002},{Event305003List,305003},
                 {Event305004List,305004},{Event305005List,305005},{Event305006List,305006},
                 {Event305007List,305007},{Event305008List,305008},{Event305009List,305009},
                 {Event305010List,305010},{Event305011List,305011},{Event305012List,305012},
                 {Event305013List,305013},{ChuELingList,306004}],
    EventIdList = 
        lists:foldl(
          fun({EventMissionLists,EventId},AccEventIdList) ->
                  case lists:member(MissionId,EventMissionLists) of
                      true ->
                          [EventId|AccEventIdList];
                      false ->
                          AccEventIdList
                  end
          end,[],EventList),
    EventIdList2  = 
        case lists:member(BigMissionGroup,JianGongLiYeList) of
            true ->
                [306001|EventIdList];
            false ->
                EventIdList
        end,
    if EventIdList2 =/= [] ->
            common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = EventIdList2,add_progress = AddProgress});
       true ->
            ignore
    end,
    ok.
%% 地图人物模块
do_mod_map_role({team_id,_RoleId,_TeamId,_MapRoleInfo}) -> %% 组队
    %% if TeamId =/= 0 ->
    %%         common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [406011]});
    %%    true ->
    %%         next
    %% end;
    ok;
do_mod_map_role(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 怪物模块
do_mod_monster({monster_dead,RoleId,MonsterType}) -> 
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [408010]}),
    if MonsterType =:= 30452101 -> %% 杀死张士诚
            common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [100008]});
       true ->
            next
    end;
do_mod_monster(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 副本模块
do_mod_fb({country_treasure_enter,RoleId}) -> %% 进入大明宝藏副本地图
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [307001]});
do_mod_fb({country_treasure_collect,RoleId}) -> %% 大明宝藏挖宝
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [307002]});
do_mod_fb({educate_fb_complete,RoleIdList,FbCount}) -> %% 师徒副本
    lists:foreach(
      fun(RoleId)-> 
              EventIdList = 
                  if FbCount >= 55 ->
                          [307004,307005];
                     true ->
                          [307004]
                  end,
              common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = EventIdList})
      end,RoleIdList);
do_mod_fb({vwf_complete,RoleIdList}) -> %% 讨伐敌营副本
    lists:foreach(
      fun(RoleId)-> 
              common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [307003]})
      end,RoleIdList);
do_mod_fb(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 鲜花模块
do_mod_flowers({give_flowers,GiveRoleId,ReceRoleId,AddFlowersScore}) -> 
    case common_misc:if_friend(GiveRoleId,ReceRoleId) of
        true ->
            common_achievement:hook(#r_achievement_hook{role_id = GiveRoleId,event_ids = [407001],add_progress = AddFlowersScore});
        false ->
            ok
    end;
do_mod_flowers({rece_flowers,_GiveRoleId,ReceRoleId,RoleCharm}) ->
    ReceEventIdList = 
        if RoleCharm >= 9999 ->
                [407002,407003,407004];
           RoleCharm >= 1000 ->
                [407002,407003];
           RoleCharm >= 30 ->
                [407002];
           true ->
                []
        end,
    if ReceEventIdList =/= [] ->
            common_achievement:hook(#r_achievement_hook{role_id = ReceRoleId,event_ids = ReceEventIdList});
       true ->
            next
    end;
do_mod_flowers(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

%% 门派模块
do_family_module({agree,RoleId,_FamilyId,_RoleBase}) -> %% 加入门派
    common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [100001]});
do_family_module({family_ybc,RoleIdList}) -> %% 门派拉镖
    lists:foreach(
      fun(RoleId) ->
              catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [306014]})
      end,RoleIdList);
do_family_module({common_boss_dead,RoleIdList}) -> %% 门派Boss
    lists:foreach(
      fun(RoleId) ->
              catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [306013]})
      end,RoleIdList);

do_family_module(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.


%% 师徒模块
do_mgeew_educate_server({agree,TeacherInfo,StudentInfo}) -> %% 同意拜师
    do_role_educate_agree(TeacherInfo),
    do_role_educate_agree(StudentInfo);
do_mgeew_educate_server({graduate,RoleId,NewLevel,_StudentInfo,TeacherInfo})->
    #r_educate_role_info{roleid = TeacherRoleId,students = TeacherStudents} = TeacherInfo,
    OutStudentsList = 
        lists:foldl(
          fun(StudentRoleId,AccOutStudentsList) ->
                  RoleLevel = 
                      if RoleId =:= StudentRoleId ->
                              NewLevel;
                         true ->
                              case common_misc:get_dirty_role_attr(StudentRoleId) of
                                  {ok, #p_role_attr{level = RoleLevelT}} ->
                                      RoleLevelT;
                                  _ ->
                                      0
                              end
                      end,
                  if RoleLevel >= 60 ->
                          [StudentRoleId|AccOutStudentsList];
                     true ->
                          AccOutStudentsList
                  end
          end,[],TeacherStudents),
    EventIdList = 
        if erlang:length(OutStudentsList) >= 10 ->
                [404002,404003];
           erlang:length(OutStudentsList) >= 2 ->
                [404002];
           true ->
                []
        end,
    if EventIdList =/= [] ->
            common_achievement:hook(#r_achievement_hook{role_id = TeacherRoleId,event_ids = EventIdList});
       true ->
            ok
    end;
do_mgeew_educate_server(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块hook无法处理此消息",Info]),
    ok.

do_role_educate_agree(EducateInfo) ->
    #r_educate_role_info{roleid = RoleId,teacher = Teacher,students = Students} = EducateInfo,
    EventIdList = 
        case Students of
            undefined ->
                case Teacher of
                    undefined ->
                        [];
                    _ ->
                        [100003]
                end;
            [] ->
                case Teacher of
                    undefined ->
                        [];
                    _ ->
                        [100003]
                end;
            _ ->
                case Teacher of
                    undefined ->
                        [100003,404004];
                    _ ->
                        [100003,404004]
                end
        end,
    if EventIdList =/= [] ->
            common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = EventIdList});
       true ->
            ok
    end.
