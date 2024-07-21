%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @doc 传奇目标hook模块
%%%
%%% @end
%%% Created : 14 Jun 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_mod_goal).

-include("common_server.hrl").
-include("common.hrl").

%% API
-export([
         hook_equip_wear/3,
         hook_level_up/2,
         hook_friend_num/2,
         hook_skill_level_up/3,
         hook_monster_dead/2,
         finish_fero_fb/2,
         finish_scene_war_fb/2,
         hook_educate/2,
         hook_family_change/2,
         hook_pet_color_change/2,
         hook_ybc_color_change/2,
         role_family_contribution_change/2,
         hook_equip_build/2,
         hook_learn_family_skill/3,
         hook_family_collect_score/2,
         hook_pet_level_up/2,
         family_level_up/2,
         hook_apoint_assign/2,
         hook_refining_inlay/1,
         hook_equip_bind/1,
         hook_pet_learn_skill/2,
         hook_gongxun/3,
         do_hook2/2,
         do_hook_process2/3,
         set_open/0,
         set_close/0,
         hook_equip_inlay/1,
         hook_pet_grow_update/2,
         hook_pet_refresh_aptitude/1
        ]).

%% 哪些目标是开启的
-define(ENABLE_GOAL_LIST, [110001,110002,110003,110004,110005,110006,110007,110008,110009,
                           120001,120002,120003,120004,120005,
                           130001,130002,130003,130004,130005,130006,130007,130008,130009,130010,
                           140001,140002,140003,140004,140005,140006,140007]).

%%%===================================================================
%%% API
%%%===================================================================

%% 好友数量
hook_friend_num(RoleID, FriendNum) ->
    GoalID = 140006,
    do_hook_process(RoleID, GoalID, FriendNum).

%% 穿装备目标
hook_equip_wear(RoleID, SlotNum, Color) ->
    case Color >= 4 andalso SlotNum =:= 4 of
        true ->
            do_hook(RoleID, 140002);
        _ ->
            ok
    end,
    case mod_map_role:get_role_base(RoleID) of
        {ok,RoleBase} ->
            case RoleBase#p_role_base.max_phy_attack >= 1000 orelse  RoleBase#p_role_base.max_magic_attack >= 1000 of
                true ->
                    do_hook(RoleID, [130009,130010]);
                _ ->
                    case RoleBase#p_role_base.max_phy_attack >= 700 orelse  RoleBase#p_role_base.max_magic_attack >= 700 of
                        true ->
                            do_hook(RoleID, 130009);
                        _ ->
                            ok
                    end
            end;
        _ ->
            ok
    end,
    ok.
%% 镶嵌宝石
hook_equip_inlay(RoleID) ->
    GoalID = 140001,
    do_hook(RoleID, GoalID).
%% 宠物训宠能力
hook_pet_grow_update(RoleID,Level) ->
    if Level >= 15 ->
           GoalID = [130002,130004];
       Level >= 10 ->
           GoalID = [130002];
       true ->
           GoalID = -1
    end,
    do_hook(RoleID, GoalID).
%% 第一次给宠物洗灵
hook_pet_refresh_aptitude(RoleID) ->
    do_hook(RoleID, 140004).
%% 升级了
hook_level_up(RoleID, Level) ->
    if 
        Level >= 46 ->
            GoalID = [110001,110002,110003,110004,110005,110006,110007];
        Level >= 45 ->
            GoalID = [110001,110002,110003,110004,110005,110006];
        Level >= 44 ->
            GoalID = [110001,110002,110003,110004,110005];
        Level >= 43 ->
            GoalID = [110001,110002,110003,110004];
        Level >= 42 ->
            GoalID = [110001,110002,110003];
        Level >= 40  ->
            GoalID = [110001,110002];
        Level >= 35 ->
            GoalID = [110001];        
        true ->
            GoalID = -1
    end,
    do_hook(RoleID, GoalID).

%% 技能升级了
hook_skill_level_up(RoleID, _SkillID, Level) ->
    if 
        Level >= 15 ->
            GoalID = [130001,130003];
        Level >= 10 ->
            GoalID = [130001];
        true ->
            GoalID = -1
    end,
    do_hook(RoleID, GoalID).

%% 处理怪物死亡
hook_monster_dead(RoleID, TypeID) ->
    %% BOSS群的所有BOSS id
    BossTypeIdList = [30402101,30502101,30602101,30702101,30802101,30902101,31002101,31102101,31202101],
    case lists:member(TypeID,BossTypeIdList) of
        true ->
            GoalID = 140007;
        _ ->
            GoalID = -1
    end,
    do_hook(RoleID, GoalID).

%% 完成大明英雄副本
finish_fero_fb(RoleID, BarrierID) ->
    if 
        BarrierID =:= 101 ->
            GoalID = 120001;%% 第1关
        BarrierID =:= 210 ->
            GoalID = 120004;%% 第20关
        BarrierID =:= 310 ->
            GoalID = 120005;%% 第30关
        true ->
            GoalID = -1
    end,
    do_hook(RoleID, GoalID).
%% 场景副本
finish_scene_war_fb(RoleIdList,FbType) ->
    if FbType =:= 5 ->
           GoalID = 120002;
       FbType =:= 6 ->
           GoalID = 120003;
       true ->
           GoalID = -1
    end,
    lists:foreach(
      fun(RoleID) -> 
              do_hook(RoleID, GoalID)
      end,RoleIdList).

%% 组成师徒了
hook_educate(_RoleID1, _RoleID2) ->
    ignore.


%% 玩家门派发生变化了
hook_family_change(RoleID, FamilyID) ->
    case FamilyID > 0 of
        true ->
            GoalID = 140005,
            do_hook(RoleID, GoalID);
        false ->
            ignore
    end.

%% 宠物颜色变化
hook_pet_color_change(_RoleID, _Color) ->
    ok.    

%% 镖车颜色
hook_ybc_color_change(_RoleID, _Color) ->
    ok.


%% 玩家的门派贡献发生变化了
role_family_contribution_change(RoleID, NewContribution) ->
    if
        NewContribution >= 50 ->
            GoalID = 130007;
        true ->
            GoalID = -1
    end,
    do_hook(RoleID, GoalID).

%% 装备打造
hook_equip_build(_RoleID, _NewEquip) ->
    ok.

%% 学习门派技能
hook_learn_family_skill(_RoleID, _SkillID, _NextSkillLevel) ->
    ok.

%% 门派采集积分
hook_family_collect_score(_RoleIDList, _Score) ->
    ok.

%% 宠物升级
hook_pet_level_up(RoleID, Level) ->
    if
        Level >= 40 ->
            GoalID = [110008,110009];
        Level >= 25 ->
            GoalID = [110008];
        true ->
            GoalID = -1
    end,
    do_hook(RoleID, GoalID).

%% 门派升级了
family_level_up(RoleIDList, Level) ->
    if 
        Level >= 2 ->
            [do_hook(RoleID, 130008) || RoleID <- RoleIDList];
        true ->
            ignore
    end.

%% 角色属性点变化
hook_apoint_assign(_RoleID, _RoleBase) ->
    ok.

%% 灵石镶嵌
hook_refining_inlay(RoleID) ->
    do_hook(RoleID, 10053).

%% 装备绑定
hook_equip_bind(_RoleID) ->
    ok.

%% 宠物学习新技能
hook_pet_learn_skill(RoleID, NumOfSkill) ->
    if 
        NumOfSkill >= 1 ->
            GoalID = 140003;
        true ->
            GoalID = -1
    end,
    do_hook(RoleID, GoalID).

%% 获得战功
hook_gongxun(RoleID, All, _Add) ->
    if All > 20 ->
           GoalID = [130005,130006];
       true ->
           GoalID = 130005
    end,
    do_hook(RoleID, GoalID).
    

%%%===================================================================
%%% Internal functions
%%%===================================================================
do_hook(RoleID, GoalID) ->    
    case common_goal_flag:is_open() of
        true ->
            try
                do_hook2(RoleID, GoalID) 
            catch E:E2 ->
                    ?ERROR_MSG("~ts:~w ~w", ["传奇目标hook出错", {E, E2}, {RoleID, GoalID}])
            end;
        false ->
            ignore
    end.

do_hook2(RoleID, GoalID) when erlang:is_integer(GoalID) ->
    %% 判断目标是否已开启
    case lists:member(GoalID, ?ENABLE_GOAL_LIST) of
        true ->
            %% 判断是否在地图进程中
            case erlang:get(is_map_process) of
                true ->
                    mod_goal:handle({hook_goal_event, RoleID, GoalID}),
                    ok;
                _ ->
                    common_misc:send_to_rolemap(RoleID, {mod_goal, {hook_goal_event, RoleID, GoalID}}),
                    ok
            end;
        false ->
            ignore
    end;    
do_hook2(RoleID, GoalIDList) ->
    [do_hook2(RoleID, GoalID) || GoalID <- GoalIDList].

%% 进度模式下的目标，process为当前的进度，这种接口的前提是每次都知道具体的数量，所以好友是合适的，打怪是不合适的
%% 好友的消息来自world，有时可能会丢失，那就比较郁闷了
do_hook_process(RoleID, GoalID, Process) ->
    case common_goal_flag:is_open() of
        true ->
            do_hook_process2(RoleID, GoalID, Process) ,
            try
                do_hook_process2(RoleID, GoalID, Process) 
            catch E:E2 ->
                    ?ERROR_MSG("~ts:~w ~w", ["传奇目标hook出错", {E, E2}, {RoleID, GoalID, Process}])
            end;
        false ->
            ignore
    end.

do_hook_process2(RoleID, GoalID, Process) ->
    %% 判断目标是否已开启
    case lists:member(GoalID, ?ENABLE_GOAL_LIST) of
        true ->
            %% 判断是否在地图进程中
            case erlang:get(is_map_process) of
                true ->
                    mod_goal:handle({hook_goal_event_process, RoleID, GoalID, Process});
                _ ->
                    common_misc:send_to_rolemap(RoleID, {mod_goal, {hook_goal_event_process, RoleID, GoalID, Process}})
            end;
        false ->
            ignore
    end.
    
set_open() ->
    try
        {Mod,Code} = dynamic_compile:from_string(common_flag_src(true)),
        code:load_binary(Mod, "common_mod_flag.erl", Code)
    catch
        Type:Error -> io:format("Error compiling common_mod_flag (~p): ~p~n", [Type, Error])
    end,
    ok.

set_close() ->
    try
        {Mod,Code} = dynamic_compile:from_string(common_flag_src(false)),
        code:load_binary(Mod, "common_goal_flag.erl", Code)
    catch
        Type:Error -> io:format("Error compiling common_goal_flag (~p): ~p~n", [Type, Error])
    end,
    ok.

common_flag_src(Flag) ->
    "-module(common_goal_flag).

     -export([is_open/0]).

     is_open() ->
         " ++ common_tool:to_list(Flag) ++ ".
".
