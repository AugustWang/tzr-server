%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2010, 
%%% @doc
%%%     用来将地图进程中的玩家数据保存到mnesia中
%%% @end
%%% Created : 21 Dec 2010 by  <>
%%%-------------------------------------------------------------------
-module(mgeem_persistent).

-include("mgeem.hrl").

%% API
-export([
         start/0,
         start_link/0
        ]).

-export([
         role_detail_persistent/1, 
         role_base_attr_persistent/2,
         role_bag_persistent/1,
         role_conlogin_persistent/1,
         role_accumulate_exp_persistent/1,
         role_pos_persistent/1,
         role_vip_persistent/1,
         role_hero_fb_persistent/1,
         role_monster_drop_persistent/1,
         role_refining_box_persistent/1,
         role_goal_persistent/1,
         role_map_ext_info_persistent/1,
         role_achievement_persistent/1,
         role_skill_list_persistent/2,
         role_fight_persistent/1
        ]).

-export([
         ybc_persistent/2,
         ybc_persistent/3
        ]).

-export([
         mission_data_persistent/2
        ]).
%% Gen Server Call Back
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% Record Defin
-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    {ok, _} = supervisor:start_child(mgeem_sup, {?MODULE,
                                                 {?MODULE, start_link, []},
                                                 transient, brutal_kill, worker, 
                                                 [?MODULE]}).

%%%================镖车模块 - START==================
ybc_persistent(YbcID, YbcMapInfo) ->
    erlang:send(?MODULE, {ybc_persistent, YbcID, YbcMapInfo}).

ybc_persistent(YbcID, MapID, YbcMapInfo) ->
    erlang:send(?MODULE, {ybc_persistent, YbcID, MapID, YbcMapInfo}).

%%%================镖车模块 - END==================

%%%================角色信息 - START==================
role_detail_persistent(#p_role{base=RoleBase, attr=RoleAttr}) ->
    role_base_attr_persistent(RoleBase, RoleAttr).

role_base_attr_persistent(RoleBase, RoleAttr) ->
    erlang:send(?MODULE, {role_base_attr_persistent, RoleBase, RoleAttr}).
%% 玩家背包信息
role_bag_persistent(Bag) ->
    erlang:send(?MODULE, {common_persistent, ?DB_ROLE_BAG_P, Bag}).

role_conlogin_persistent(RoleConlogin) ->
    erlang:send(?MODULE, {common_persistent, ?DB_ROLE_CONLOGIN_P, RoleConlogin}).

role_accumulate_exp_persistent(RoleAccumulateExp) ->
    erlang:send(?MODULE, {common_persistent, ?DB_ROLE_ACCUMULATE_P, RoleAccumulateExp}).
%% 玩家位置
role_pos_persistent(RolePos) ->
    erlang:send(?MODULE, {common_persistent, ?DB_ROLE_POS, RolePos}).
%% 玩家VIP
role_vip_persistent(VipInfo) ->
    erlang:send(?MODULE, {role_vip, VipInfo}).
%% 个人副本
role_hero_fb_persistent(HeroFBInfo) ->
    erlang:send(?MODULE, {common_persistent, ?DB_ROLE_HERO_FB_P, HeroFBInfo}).
%% 怪物掉落
role_monster_drop_persistent(DropInfo) ->
    erlang:send(?MODULE, {common_persistent, ?DB_ROLE_MONSTER_DROP_P, DropInfo}).
%% 玩家箱子
role_refining_box_persistent(RefiningBoxInfo) ->
    erlang:send(?MODULE, {common_persistent, ?DB_ROLE_BOX_P, RefiningBoxInfo}).
%% 玩家传奇目标
role_goal_persistent(RoleGoal) ->
    erlang:send(?MODULE, {common_persistent, ?DB_ROLE_GOAL_P, RoleGoal}).

%% 玩家成就
role_achievement_persistent(AchievementInfo) ->
    erlang:send(?MODULE, {common_persistent, ?DB_ROLE_ACHIEVEMENT_P, AchievementInfo}).
%% 玩家扩展信息
role_map_ext_info_persistent(RoleMapExtInfo)->
    erlang:send(?MODULE, {role_map_ext_info,RoleMapExtInfo}).

%% 玩家技能
role_skill_list_persistent(RoleID, SkillList) ->
    erlang:send(?MODULE, {role_skill_list, RoleID, SkillList}).
%% 战斗信息
role_fight_persistent(RoleFight) ->
    erlang:send(?MODULE, {common_persistent, ?DB_ROLE_FIGHT, RoleFight}).
%%%================角色信息 - END==================

%%%================任务相关 - START==================
mission_data_persistent(RoleID, MissionData) ->
    erlang:send(?MODULE, {mission_data_persistent, RoleID, MissionData}).
%%%================任务相关 - END==================


%% Gen Server Call Back
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({'EXIT', _, Reason}, State) ->
    ?INFO_MSG("~ts:~w", ["持久化进程关闭", Reason]),
    {stop, normal, State};

handle_info(Info, State) ->
    ?DO_HANDLE_INFO(Info,State),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%%================角色信息 - START==================
do_handle_info({role_base_attr_persistent, RoleBase, RoleAttr}) ->
    do_role_base_attr_persistent(RoleBase, RoleAttr);
do_handle_info({common_persistent, Tab, Record}) ->
    db_common_persistent(Tab, Record);
do_handle_info({role_vip, VipInfo}) ->
    do_role_vip(VipInfo);
do_handle_info({role_map_ext_info,RoleMapExtInfo}) ->
    do_role_map_ext_info(RoleMapExtInfo);
do_handle_info({role_skill_list, RoleID, SkillList}) ->
    do_role_skill_list(RoleID, SkillList);
%%%================角色信息 - END==================

%%%================镖车模块 - START==================
do_handle_info({ybc_persistent, YbcID, YbcMapInfo}) ->
    do_ybc_persistent(YbcID, YbcMapInfo);

do_handle_info({ybc_persistent, YbcID, MapID, YbcMapInfo}) ->
    do_ybc_persistent(YbcID, MapID, YbcMapInfo);
%%%================镖车模块 - END==================

%%%================任务模块 - START==================
do_handle_info({mission_data_persistent, RoleID, MissionData}) ->
    do_mission_data_persistent(RoleID, MissionData);
%%%================任务模块 - END==================

do_handle_info(Info) ->
    ?ERROR_MSG("mgeem_persistent, unknow info: ~w", [Info]).

db_common_persistent(Tab, Record) ->
    case db:transaction(fun() -> db:write(Tab, Record, write) end) of
        {atomic, ok} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("~ts: ~w, ~w, ~w", ["持久化角色信息出错: ", Tab, Error, Record])
    end.

%%%================镖车模块 - START==================
do_ybc_persistent(YbcID, YbcMapInfo) ->
    case db:transaction(fun() ->
            case db:read(?DB_YBC, YbcID, write) of
                [] ->
                    ignore;
                [YbcInfo] ->
                    NewYbcInfo = mod_map_ybc:get_new_ybc_info(YbcInfo, YbcMapInfo),
                    db:write(?DB_YBC, NewYbcInfo, write)
            end
        end)
    of
        {atomic, ok} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w ~w", ["持久化镖车信息出错", Error, YbcMapInfo])
    end.

do_ybc_persistent(YbcID, MapID, YbcMapInfo) ->
    case db:transaction(fun() ->
                                case db:read(?DB_YBC, YbcID, write) of
                                    [] ->
                                        ignore;
                                    [YbcInfo] ->
                                        NewYbcInfo = mod_map_ybc:get_new_ybc_info(YbcInfo, YbcMapInfo),
                                        db:write(?DB_YBC, NewYbcInfo#r_ybc{map_id=MapID}, write)
                                end
                        end)
    of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w ~w", ["持久化镖车信息出错", Error, YbcMapInfo])
    end.
%%%================镖车模块 - END==================
%%%================角色信息 - START==================
do_role_skill_list(RoleID, SkillList) ->
    case db:transaction(
           fun() ->
                   db:write(?DB_ROLE_SKILL_P, #r_role_skill{role_id = RoleID,skill_list = SkillList}, write)
           end)
    of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("持久化角色技能列表出错，error: ~w", [{Error, SkillList}])
    end.
do_role_vip(VipInfo) ->
    case db:transaction(fun() -> db:write(?DB_ROLE_VIP_P, VipInfo, write) end) of
        {atomic, ok} ->
             ?TRY_CATCH(
                mysql_persistent_handler:dirty_write_batch(?DB_ROLE_VIP_P, [VipInfo])
            ),
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("持久化角色VIP信息出错: ~w", [Error])
    end.
%% 玩家地图扩展信息持久化
%% 包括这种信息和那种信息
do_role_map_ext_info(RoleMapExtInfo)->
    #r_role_map_ext{training_pets=TrainingPets} = RoleMapExtInfo,
    case is_record(TrainingPets,r_pet_training) of
        true->
            do_pet_training_persistent(TrainingPets);
        _->
            ?ERROR_MSG("trainingPet ignore~w~n",[TrainingPets]),
            ignore
    end.

%% 宠物训练信息持久化
do_pet_training_persistent(TrainingPets)-> 
    case db:transaction(
           fun()->
                   db:write(?DB_PET_TRAINING_P,TrainingPets,write) end)
        of
        {atomic,_}->
            ok;
        {aborted,Error}->
            ?ERROR_MSG("~ts:~w", ["持久化宠物训练信息数据出错", Error])
    end.

%% 部分门派、官职的数据是不采用 地图中的缓存数据
do_role_base_attr_persistent(RoleBase, RoleAttr) ->
    case db:transaction(
           fun() ->
                   [#p_role_base{family_id=FamilyID, family_name=FamilyName}] = db:read(?DB_ROLE_BASE, RoleBase#p_role_base.role_id, write),
                   [#p_role_attr{office_id=OfficeID, 
                                 office_name=OfficeName,
                                 is_payed=IsPayed,
                                 family_contribute=FC}] = db:read(?DB_ROLE_ATTR, RoleBase#p_role_base.role_id, write),
                   db:write(?DB_ROLE_BASE, RoleBase#p_role_base{family_id=FamilyID, family_name=FamilyName}, write),
                   db:write(?DB_ROLE_ATTR, RoleAttr#p_role_attr{office_id=OfficeID, office_name=OfficeName, is_payed=IsPayed,
                                                                family_contribute=FC}, write)
           end)
        of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("do_role_base_attr_persistent, 可能worlderror: ~w", [Error]),
            case Error of
                {no_exists,_}->
                    common_db:join_group(),
                    ?ERROR_MSG("找不到mnesia表，可能world节点挂了!", []);
                _ ->
                    ignore
            end
    end.
%%%================角色信息 - END==================

%%%================任务模块 - START==================
do_mission_data_persistent(RoleID, MissionData) 
  when is_record(MissionData, mission_data) ->
    db:dirty_write(?DB_MISSION_DATA_P, 
                   #r_db_mission_data{
                    role_id=RoleID,
                    mission_data=MissionData});
do_mission_data_persistent(RoleID, MissionData) ->
    ?ERROR_MSG("~ts:RoleID-->~w, MissionData-->~w, Trace:~w", 
               ["试图存储任务数据，但数据非法，不是record mission_data", 
               RoleID, 
               MissionData,
               erlang:get_stacktrace()]).
%%%================任务模块 - END==================
