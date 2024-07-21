%% Author: liuwei
%% Created: 2010-9-15
%% Description: TODO: Add description to mod_map_role
-module(mod_map_role).

-include("mgeem.hrl").  
-include("equip.hrl").

%% 内部接口，进程字典实现
-export([
         init/0,
         set_role_detail/2,
         get_role_base/1,
         get_role_attr/1,
         set_role_base/2,
         set_role_attr/2,
         get_role_pos/1,
         get_role_conlogin/1,
         set_role_conlogin/2,
         get_role_goal/1,
         set_role_goal/2,
         set_role_pos_detail/2,
         get_role_pos_detail/1,
         get_role_state/1,
         set_role_state/2,
         set_role_fight/2,
         get_role_fight/1
         ]).
-export([
         clear_role_detail/1,
         clear_role_state/1,
         clear_role_spec_state/1,
         clear_role_timer/1
         ]).

-export([
         handle/2
         ]).

-export([
         update_role_id_list_in_transaction/3,
         role_base_attr_persistent/0,
         get_map_faction_id/1,
         
         level_up/5,
         t_add_exp/3,
         calc_attr/2,
         do_after_level_up/6,
         t_level_up/5,
         get_relive_silver/4,
         do_skill_charge/5,
         dead_punish/5,
         do_role_reduce_mp/3,
         do_update_map_role_info/3,
         reduce_equip_endurance/2,
         kick_role/2,
         enter_exception/6,
         diff_map_change_pos/4,
         do_role_add_hp/3,
         do_role_add_mp/3,
         diff_map_change_pos/5,
         do_role_reduce_hp/6,
         do_change_map/5,
         do_role_recover/1,
         update_role_fight_time/4,
         is_role_fighting/1,
         update_offline_time_and_ip/2,
         update_online_time/1,
         map_enter_broadcast/2,
         clear_role_spec_buff/1,
         is_in_waroffaction/1,
         do_add_exp/2,
         is_role_exit_game/1,
         do_reset_role_energy/2,
         do_monster_dead_add_exp/6
        ]).

-export([
         add_exp/2,
         add_buff/2,
         attr_change/1,
         call_ybc_mission_status/1,
         get_role_accumulate_exp/1,
         set_role_accumulate_exp/2,
         update_role_attr/2
        ]).

-export([erase_role_map_ext_info/1,
         set_role_map_ext_info/2,
         get_role_map_ext_info/1,
         t_set_role_map_ext_info/2]).


-export([do_attr_change/1]).
%%do_attr_change/1跟attr_change/1的区别在于前者是同步调用，后者是异步调用（通过发送消息）

-define(PK_STATE_RED, 2).
-define(PK_STATE_YELLOW, 1).
-define(PK_STATE_WHITE, 0).
 
-define(AUTO_RELIVE_TIME, 600000).
-define(RELIVE_TYPE, [1, 2, 3]).
-define(CLEAR_FIGHT_STATE_DIFF, 10).
-define(ROLE_BASE_ATTR_PERSISTENT_INTERVAL, 300).

-define(dead_type_hero_fb, 1). %% 在副本死亡
-define(dead_type_die_together, 2). %% 同归于尽死亡

-record(r_drop_rate, {pk_state, silver_drop_rate, bag_drop_rate, equip_drop_rate}).

%%
%% ========================== API Functions ===========================
%%

init() ->
    erlang:put(?role_id_list_in_transaction, []).


set_role_detail(RoleID, RoleDetail) ->
    #r_role_map_detail{
               base = RoleBase,attr = RoleAttr,conlogin = RoleConlogin,accumulate_info = AccumulateInfo,vip_info = VipInfo,
               hero_fb_info = HeroFBInfo,role_monster_drop = DropInfo,refining_box_info = RefiningBoxInfo, goal_info = RoleGoalInfo, 
               achievement_info = AchievementInfo,team_info = TeamInfo,map_ext_info = MapExtInfo,skill_list = SkillList,pos=RolePos,
               role_fight=RoleFight} = RoleDetail,
    erlang:put({?role_base, RoleID}, RoleBase),
    erlang:put({?role_attr, RoleID}, RoleAttr),
    erlang:put({?role_conlogin, RoleID}, RoleConlogin),
    erlang:put({?role_accumulate_exp, RoleID}, AccumulateInfo),
    erlang:put({?role_goal_info, RoleID}, RoleGoalInfo),
    erlang:put({?role_pos, RoleID}, RolePos),
    erlang:put({?role_fight, RoleID}, RoleFight),
    mgeem_persistent:role_pos_persistent(RolePos),
    %% 初始化角色VIP信息
    mod_vip:init_role_vip_info(RoleID, VipInfo),
    mod_refining_box:init_role_refining_box_info(RoleID,RefiningBoxInfo),
    mod_achievement:init_role_achievement_info(RoleID,AchievementInfo),
    mod_map_team:init_role_team_info(RoleID,TeamInfo),
    %% 初始化角色英雄副本信息
    mod_hero_fb:set_role_hero_fb_info(RoleID, HeroFBInfo, false),
    mod_map_drop:set_role_monster_drop(RoleID, DropInfo),
    init_role_map_ext_info(RoleID,MapExtInfo),
    mod_skill:init_role_skill_list(RoleID, SkillList),
    ok.

set_role_pos_detail(RoleID, RolePos) when erlang:is_record(RolePos, p_role_pos) ->
    update_role_id_list_in_transaction(RoleID, ?role_pos, ?role_pos_copy),
    erlang:put({?role_pos, RoleID}, RolePos).

get_role_pos_detail(RoleID) ->
    case erlang:get({?role_pos, RoleID}) of
        undefined ->
            {error, role_not_found};
        Value ->
            {ok, Value}
    end.
%% 获得角色累积经验的相关信息
get_role_accumulate_exp(RoleID) ->
    case erlang:get({?role_accumulate_exp, RoleID}) of
        undefined ->
            {error, role_not_found};
        Value ->
            {ok, Value}
    end.

%% 设置玩家的目标信息
set_role_goal(RoleID, RoleGoalInfo) ->
    update_role_id_list_in_transaction(RoleID, ?role_goal_info, ?role_goal_info_copy),
    erlang:put({?role_goal_info, RoleID}, RoleGoalInfo).

get_role_goal(RoleID) ->
    case erlang:get({?role_goal_info, RoleID}) of
        undefined ->
            {error, role_not_found};
        Value ->
            {ok, Value}
    end.


set_role_accumulate_exp(RoleID, AccumulateExpInfo) ->
    update_role_id_list_in_transaction(RoleID, ?role_accumulate_exp, ?role_accumulate_exp_copy),
    erlang:put({?role_accumulate_exp, RoleID}, AccumulateExpInfo).

get_role_base(RoleID) ->
    case erlang:get({?role_base, RoleID}) of
        undefined ->
            {error, role_not_found};
        Value ->
            {ok, Value}
    end.
get_role_attr(RoleID) ->
    case erlang:get({?role_attr, RoleID}) of
        undefined ->
            {error, role_not_found};
        Value ->
            {ok, Value}
    end.

%% 角色连续登录奖励的详细信息  #r_role_conlogin_reward
get_role_conlogin(RoleID) ->
    case erlang:get({?role_conlogin, RoleID}) of
        undefined ->
            {error, role_not_found};
        Value ->
            {ok, Value}
    end.

set_role_conlogin(RoleID, RoleConloginReward) ->
    update_role_id_list_in_transaction(RoleID, ?role_conlogin, ?role_conlogin_copy),
    erlang:put({?role_conlogin, RoleID}, RoleConloginReward).

set_role_base(RoleID, RoleBase) ->
    %% ！！！一定要先执行update才进行put，update里面会先备份数据，且进程字典存储结构必须为{*, RoleID}，{*_copy, RoleID}
    update_role_id_list_in_transaction(RoleID, ?role_base, ?role_base_copy),
    erlang:put({?role_base, RoleID}, RoleBase).
    
set_role_attr(RoleID, RoleAttr) ->
    update_role_id_list_in_transaction(RoleID, ?role_attr, ?role_attr_copy),
    erlang:put({?role_attr, RoleID}, RoleAttr).

set_role_fight(RoleId, RoleFight) ->
    case common_role:is_in_role_transaction() of
        true ->
            t_set_role_fight(RoleId, RoleFight);
        _ ->
            {atomic, _} = common_transaction:t(fun() -> t_set_role_fight(RoleId, RoleFight) end)
    end.

t_set_role_fight(RoleId, RoleFight) ->
    update_role_id_list_in_transaction(RoleId, ?role_fight, ?role_fight_copy),
    erlang:put({?role_fight, RoleId}, RoleFight).

get_role_fight(RoleId) ->
    case erlang:get({?role_fight, RoleId}) of
        undefined ->
            {error, not_found};
        RoleFight ->
            {ok, RoleFight}
    end.
clear_role_detail(RoleID) ->
    %% 持久化
    {ok, RoleBase} = get_role_base(RoleID),
    {ok, RoleAttr} = get_role_attr(RoleID),
    {ok, RoleConlogin} = get_role_conlogin(RoleID),
    {ok, RoleGoalInfo} = get_role_goal(RoleID),
    {ok, RolePos} = get_role_pos_detail(RoleID),
    {ok, RoleFight} = get_role_fight(RoleID),
    case get_role_accumulate_exp(RoleID) of
         {ok, RoleAccumulateExp} ->
               mgeem_persistent:role_accumulate_exp_persistent(RoleAccumulateExp);
          _ ->
               ignore
    end,
    RoleDetail = #p_role{base=RoleBase, attr=RoleAttr},
    mgeem_persistent:role_detail_persistent(RoleDetail),
    mgeem_persistent:role_conlogin_persistent(RoleConlogin),
    mgeem_persistent:role_goal_persistent(RoleGoalInfo),
    mgeem_persistent:role_pos_persistent(RolePos),
    mgeem_persistent:role_fight_persistent(RoleFight),
    erlang:erase({?role_conlogin, RoleID}),
    erlang:erase({?role_base, RoleID}),
    erlang:erase({?role_attr, RoleID}),
    erlang:erase({?role_accumulate_exp, RoleID}),
    erlang:erase({?role_pos, RoleID}),
    erlang:erase({?role_fight, RoleID}),
    ok.

%%type, true, attack, false, defen
reduce_equip_endurance(RoleID, Type) ->
    case Type of
        true ->
            reduce_equip_endurance2_1(RoleID);
        false ->
            reduce_equip_endurance2_2(RoleID)
    end.


%%踢玩家掉线
kick_role(RoleID, Line) ->
    hook_map_role:kick_role(RoleID),
    Pid = get({roleid_to_pid,RoleID}),
    case Pid of
        undefined ->
            nil;
        _ ->
            erase({roleid_to_pid,RoleID}),
            mgeem_router:kick_role(RoleID, Line, not_valid_client)
    end.

%%@doc 发送HP/MP的更新到前端
send_role_hpmp_change(RoleID, RoleMapInfo)->
    mod_map_actor:set_actor_mapinfo(RoleID, role, RoleMapInfo),
    HPChange = #p_role_attr_change{change_type=?ROLE_HP_CHANGE, new_value=RoleMapInfo#p_map_role.hp},
    MPChange = #p_role_attr_change{change_type=?ROLE_MP_CHANGE, new_value=RoleMapInfo#p_map_role.mp},
    Record = #m_role2_attr_change_toc{roleid=RoleID, changes=[HPChange, MPChange]},
    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, Record).

get_role_pos(RoleID) ->
    case mod_map_actor:get_actor_pos(RoleID, role) of
        undefined ->
            {error, not_found};
        RolePos ->
            {ok, RolePos}
    end.

%% add caochuncheng 2010-09-20
enter_exception(Unique, Pid, RoleID, RoleMapInfo, Line, State) ->
    Record = #m_map_enter_toc{succ=false},
    common_misc:unicast(Line, RoleID, Unique, ?MAP, ?MAP_ENTER, Record),
    Pid ! {sure_enter_map, erlang:self()},

    #p_map_role{faction_id=FactionID} = RoleMapInfo,
    mod_map_actor:set_actor_mapinfo(RoleID, role, RoleMapInfo),

    MapID = State#map_state.mapid,
    HomeMapID = common_misc:get_home_mapid(FactionID, MapID),
    {_, TX2, TY2} = common_misc:get_born_info_by_map(HomeMapID),
    diff_map_change_pos(?CHANGE_MAP_TYPE_RETURN_HOME, RoleID, HomeMapID, TX2, TY2).

%%无论玩家使用何种方式走路，每经过一格都必须要发一次消息给服务端
handle({Unique, Module, ?MOVE_WALK, DataIn, RoleID, _PID, Line}, State) -> 
    do_walk({Unique, Module, ?MOVE_WALK, DataIn, RoleID, Line}, State);
handle({_Unique, ?MOVE, ?MOVE_WALK_PATH, DataIn, RoleID, _PID, _Line}, State) ->
    do_walk_path(?MOVE, ?MOVE_WALK_PATH, DataIn, RoleID, State);
%%复活处理
handle({relive, RoleID, Type, RoleAttr, Unique}, State) ->
    do_relive(RoleID, Type, RoleAttr, Unique, State);
handle({role_reduce_hp, RoleID, Decrement, SrcActorName, SrcActorID, SrcActorType}, State) ->
    do_role_reduce_hp(RoleID, Decrement, SrcActorName, SrcActorID, SrcActorType, State);
handle({role_add_hp, RoleID, Increment, SRoleID}, _State) ->
    do_role_add_hp(RoleID, Increment, SRoleID);    
handle({role_add_mp, RoleID, Increment, RoleID}, _State) ->
    do_role_add_mp(RoleID, Increment, RoleID);
%% 杀死怪物加经验
handle({monster_dead_add_exp, RoleID, Add, MonsterType, RoleState, KillFlag, EnergyIndex}, _State) ->
    do_monster_dead_add_exp(RoleID, Add, MonsterType, RoleState, KillFlag, EnergyIndex);
handle({add_exp, RoleID, Add}, _State) ->
    do_add_exp(RoleID, Add);
handle({gm_level_up, RoleAttr, RoleBase, Level, Level2, Exp}, _State) ->
    level_up(RoleAttr, RoleBase, Level, Level2, Exp);
%% 升级
handle({level_up,RoleID,RoleAttr, RoleBase},_State) ->
    do_level_up(RoleID,RoleAttr, RoleBase);
%%回城
handle({return_home, RoleID}, State) ->
    do_return_home(RoleID, State);

%%送回太平村
handle({return_peace_village, RoleID},_State) ->
    do_return_peace_village(RoleID);

%% mgeem_map发送过来的，最终是通过monitor来实现的
handle({role_exit, PID}, State) ->
    case erlang:get({role_id, PID}) of
        undefined ->
            ignore;
        RoleID ->
             do_client_exit(RoleID, PID, State)
    end;

%%全地图随机移动
handle({random_move, RoleID}, State) ->
    do_random_move(RoleID, State);
%% 追踪玩家
handle({trace_role, Unique, Module, Method, PID, {TargetID, TargetName, GoodsID, Num}}, _State) ->
    do_trace_role(Unique, Module, Method, PID, TargetID, TargetName, GoodsID, Num);
%%跟新玩家地图信息
handle({update_map_role_info,NewBase,NewAttr}, State) ->
    do_update_map_role_info(NewBase, NewAttr, State);
%%处理换装
handle({role_skin_change, RoleID, Skin}, State) ->
    do_update_map_role_info(RoleID, [{#p_map_role.skin, Skin}], State);

%%随机移动技能
handle({skill_transfer,ActorID, ActorType,DistRound}, State) ->
    do_skill_transfer(ActorID, ActorType,DistRound,State);
%%冲锋技能
handle({skill_charge,SrcActorID, SrcActorType,ActorID,ActorType}, State) ->
    do_skill_charge(SrcActorID, SrcActorType, ActorID, ActorType, State);
handle({bubble_msg, RoleID, Line, DataIn}, State) ->
    do_bubble_msg(RoleID, Line, DataIn, State);
handle({change_cur_title, RoleID, TitleID, TitleName, Color}, State) ->
    do_change_titlename(RoleID, TitleID, TitleName, Color, State);

%%门派成员传动参与boss战
handle({family_member_enter_map_copy,RoleID,R},_State)->
    do_handle_family_member_enter_mapcopy(RoleID,R);

%%门派令
handle({family_membergather,RoleID,R},_State)->
    do_handle_family_member_gather(RoleID,R);

handle({educate_dead_call_help,RoleID,R},_State)->
    do_handle_educate_help_call(RoleID,R);

%%把玩家踢出门派地图
handle({family_member_cast_to_born_place,RoleID,R},_State)->
    do_handle_cast_member_to_born_palce(RoleID,R);

%%地图跳转，只打个标记，不发跳转消息到客户端
handle({change_map, RoleID, MapID, TX, TY, ChangeMapType}, _State) ->
    do_change_map(RoleID, MapID, TX, TY, ChangeMapType);

%% 自动复活
handle({auto_relive, RoleID}, _State) ->
    mod_role2:do_relive(?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_RELIVE, RoleID, ?RELIVE_TYPE_BACK_CITY);
%% 开始启动减PK值计时
handle({reduce_pk_point_start, RoleID}, _State) ->
    mod_pk:reduce_pk_point_start(RoleID);
%% 定时减PK值
handle({reduce_pk_point, RoleID, Reduce, ReduceType}, _State) ->
    mod_pk:reduce_pk_point(RoleID, Reduce, ReduceType);
%% 取消灰名
handle({cancel_gray_name, RoleID}, _State) ->
    mod_gray_name:cancel_gray_name(RoleID);
%% 加功勋
handle({add_gongxun, RoleID, Add}, _State) ->
    mod_gongxun:add_gongxun(RoleID, Add);
%% 返还完成门派拉镖帮众押金
handle({return_family_ybc_silver, RoleID, RoleName, FamilyPID, Silver}, _State) ->
    mod_ybc_family:return_family_ybc_silver(RoleID,RoleName,FamilyPID,Silver);
%% 减功勋
handle({reduce_gongxun, RoleID, Reduce}, _State) ->
    mod_gongxun:reduce_gongxun(RoleID, Reduce);
%% 添加BUFF
handle({add_buff, RoleID, SActorID, SActorType, AddBuffs}, _State) ->
    mod_role_buff:add_buff(RoleID, SActorID, SActorType, AddBuffs);
%% 移除BUFF
handle({remove_buff, RoleID, SActorID, SActorType, RemoveBuffs}, _State) ->
    mod_role_buff:remove_buff(RoleID, SActorID, SActorType, RemoveBuffs);
%% BUFF循环
handle({buff_loop, RoleID, Module, Method, Args, Interval, RemainTime}, _State) ->
    mod_role_buff:buff_loop(RoleID, Module, Method, Args, Interval, RemainTime);
%% SOCKET断开
handle({client_exit, RoleID, PID}, State) ->
    do_client_exit(RoleID, PID, State);
%% 重算属性
handle({attr_change, RoleID}, _State) ->
    do_attr_change(RoleID);
%% 某人被外国人杀了
handle({killed_by_foreigner, RoleID, FactionID, MapID, TX, TY}, _State) ->
    put({killed_by_foreigner, MapID, TX, TY}, {RoleID, FactionID}),
    %% 5分钟后清掉标记
    erlang:send_after(60*1000, self(), {mod_map_role, {erase_killed_by_foreigner, MapID, TX, TY}});
%% 清除标记
handle({erase_killed_by_foreigner, MapID, TX, TY}, _State) ->
    erase({killed_by_foreigner, MapID, TX, TY});
%% 进入地图广播
handle({map_enter_broadcast, RoleID, MFID, Msg}, _State) ->
    do_map_enter_broadcast(RoleID, MFID, Msg);
%% 技能返回经验
handle({skill_return_exp, RoleID}, _MapState) ->
    do_skill_return_exp(RoleID);
handle({reset_role_energy, RoleID}, _MapState) ->
    do_reset_role_energy(RoleID);
%%扣钱接口
handle({reduce_money, Request}, _State) ->
    mod_role_money:do_reduce_money(Request);
handle({add_money, Request}, _State) ->
    mod_role_money:do_add_money(Request);
%%警惕！此处是GM指令专用
handle({set_money, Request}, _State) ->
    mod_role_money:do_set_money(Request);
handle({change_money, Request}, _State) ->
    mod_role_money:do_change_money(Request);
handle({moral_value_to_pkpoint, MoralPID, RoleID, MoralValue, Msg}, _State) ->
    do_moral_value_to_pkpoint(MoralPID, RoleID, MoralValue, Msg);

handle(Msg,_State) ->
    ?ERROR_MSG("uexcept msg = ~w",[Msg]).

%%
%% ========================= Local Functions ==================================
%%
%% 追踪玩家
do_trace_role(Unique, Module, Method, PID, TargetID, TargetName, GoodsID, Num) ->
    case mod_map_role:get_role_pos(TargetID) of
        {ok, #p_pos{tx=TX, ty=TY}} ->
            DataRecord = #m_item_trace_toc{goods_id=GoodsID, goods_num=Num, target_name=TargetName,
                                           target_mapid=mgeem_map:get_mapid(), target_tx=TX, target_ty=TY},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord);
        {error, _} ->
            R = #m_item_trace_toc{succ=false, reason=?_LANG_ITEM_TRACE_ROLE_NOT_FOUND},
            common_misc:unicast2(PID, Unique, Module, Method, R)
    end.    

do_handle_cast_member_to_born_palce(RoleID,R)->
    ?DEBUG("mizu finalkickyouout ~p",[RoleID]),
    #m_map_change_map_toc{
			   mapid = MapID,
			   tx = X,
			   ty = Y
			 } = R,
    diff_map_change_pos(RoleID,MapID,X,Y).
%% 门派活动召集,通过门派地图NPC发布召集信息
do_handle_family_member_enter_mapcopy(RoleID,R)->
    hook_map_role:hook_change_map_by_call(?CHANGE_MAP_FAMILY_NPC_CALL,RoleID),
    #m_map_change_map_toc{mapid = MapID,tx=TX,ty=TY} = R,
    diff_map_change_pos(RoleID,MapID,TX,TY).

%% 门派令召集
do_handle_family_member_gather(RoleID,R)->
    hook_map_role:hook_change_map_by_call(?CHANGE_MAP_FAMILY_GATHER_CALL,RoleID),
    #m_map_change_map_toc{mapid = MapID, tx=TX,ty = TY} = R,
    diff_map_change_pos(RoleID,MapID,TX,TY).

%% 师徒死亡召集
do_handle_educate_help_call(RoleID,R)->
    hook_map_role:hook_change_map_by_call(?CHANGE_MAP_EDUCATE_HELP_CALL,RoleID),
    #m_map_change_map_toc{mapid = MapID, tx=TX,ty = TY} = R,
    diff_map_change_pos(RoleID,MapID,TX,TY).

do_walk({Unique, Module, Method, DataIn, RoleID, Line}, _State) ->
    #m_move_walk_tos{pos=#p_pos{tx=TX, ty=TY, dir=DIR}} = DataIn,
    %% ?DEBUG("~ts: [~w] ~ts ~w", ["玩家", RoleID, "想走路到", DataIn]),
    hook_map_role:role_pos_change(RoleID),
    case mod_map_actor:get_actor_pos(RoleID, role) of
        undefined ->
            ?ERROR_MSG("~ts [~w] : ~ts", ["踢掉玩家", RoleID, "原因是没有发现玩家的位置"]), 
            kick_role(RoleID, Line);
        #p_pos{tx=OldTX, ty=OldTY} ->
            %%判断移动是否合法
            case erlang:abs(OldTX - TX) =< 1 andalso erlang:abs(OldTY - TY) =< 1 of
                true ->
                    do_walk2(Unique, Module, Method, {TX, TY, DIR}, RoleID, Line);
                false ->
                    sync_role_pos(RoleID, Line)
            end
    end.
do_walk2(_Unique, _Module, _Method, {TX, TY, DIR}, RoleID, Line) ->
    %%判断安全区
    case get({TX, TY}) of
        undefined ->
            ?ERROR_MSG("~ts: ~w ~w", ["玩家由于走到一个不可走的格子上而被踢掉了", TX, TY]), 
            kick_role(RoleID, Line);
        _ ->
            do_walk3(RoleID, TX, TY, DIR)
    end. 
do_walk3(RoleID, TX, TY, DIR) ->
    %% get user's cur slice
    %% update user's slice when needed
    mod_map_actor:update_slice_by_txty(RoleID, role, TX, TY, DIR).
    %mod_map_pet:update_role_pet_slice(RoleID, TX, TY, DIR).


%%处理玩家走路路径信息
do_walk_path(?MOVE, ?MOVE_WALK_PATH, DataIn, RoleID, State) ->
    %%这里将来可能需要做检查，以防外挂恶意构造
    #map_state{offsetx=OffsetX, offsety=OffsetY} = State,
    mod_map_actor:set_actor_pid_lastwalkpath(RoleID, role, DataIn#m_move_walk_path_tos.walk_path),
    DataOther = #m_move_walk_path_toc{
      roleid=RoleID,
      walk_path=DataIn#m_move_walk_path_tos.walk_path
     },
    ?DEBUG("~ts:~w", ["玩家走路路径", DataIn]),
    %%理论上这里应该不需要判断，因为这个位置实际上是已经验证过了的
    case mod_map_actor:get_actor_txty_by_id(RoleID, role) of
        {TX, TY}->
            %% ?DEBUG("~ts ~w ~w", ["获得玩家当前的格子位置", TX, TY]),
            AllSlice = mgeem_map:get_9_slice_by_txty(TX, TY, OffsetX, OffsetY),
            InSlice = mgeem_map:get_slice_by_txty(TX, TY, OffsetX, OffsetY),
            %%判断位置，有多种原因可能造成计算出的slice是undefined
            case AllSlice =/= undefined andalso InSlice =/= undefined of
                true ->
                    AroundSlices = lists:delete(InSlice, AllSlice),
                    RoleIDList1 = lists:delete(RoleID,mod_map_actor:slice_get_roles(InSlice)),
                    RoleIDList2 = mgeem_map:get_all_in_sence_user_by_slice_list(AroundSlices),
                    mgeem_map:broadcast(RoleIDList1, RoleIDList2, ?DEFAULT_UNIQUE, 
                                          ?MOVE, ?MOVE_WALK_PATH, DataOther);
                false ->
                    ignore
            end;
        undefined ->
            ignore
    end.

%% @doc 角色复活
do_relive(RoleID, ReliveType, RoleReliveInfo, Unique, MapState) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            ignore;
        RoleMapInfo ->
            #p_map_role{pos=Pos} = RoleMapInfo,
            %% 清掉角色所占的位置
            #p_pos{tx=TX, ty=TY} = Pos,
            mod_map_actor:deref_tile_pos(RoleID, role, TX, TY),
            %% 设置角色血量
            {HP, MP, RoleBase} = RoleReliveInfo,
            {ok, RoleFight} = get_role_fight(RoleID),
            RoleFight2 = RoleFight#p_role_fight{hp=HP, mp=MP},
            RoleMapInfo2 = RoleMapInfo#p_map_role{hp=HP, mp=MP, last_walk_path=undefined, state=?ROLE_STATE_NORMAL, gray_name=false},
            
            case ReliveType =:= ?RELIVE_TYPE_PLAIN orelse ReliveType =:= ?RELIVE_TYPE_PLAIN_MONEY of
                true ->
                    do_relive_plain(RoleID, RoleBase, RoleMapInfo2, RoleFight2, MapState, Unique);
                _ ->
                    do_relive_return_home(RoleID, RoleBase, RoleMapInfo2, RoleFight2, MapState, Unique)
            end
    end.

%% @doc 原地复活
do_relive_plain(RoleID, RoleBase, RoleMapInfo, RoleFight, MapState, Unique) ->
    set_role_fight(RoleID, RoleFight),
    mod_map_actor:set_actor_mapinfo(RoleID, role, RoleMapInfo),
    {ok, RolePos} = mod_map_role:get_role_pos_detail(RoleID),
    #p_map_role{pos=Pos} = RoleMapInfo,
    RolePos2 = RolePos#p_role_pos{pos=Pos},
    DataRecord = #m_role2_relive_toc{succ=true, 
                                     map_changed=false, 
                                     map_role=RoleMapInfo,
                                     role_base=RoleBase, 
                                     role_pos=RolePos2, 
                                     role_fight=RoleFight},
    common_misc:unicast({role, RoleID}, Unique, ?ROLE2, ?ROLE2_RELIVE, DataRecord),

    AllNewSlice = mgeem_map:get_9_slice_by_actorid_list([{role, RoleID}], MapState),
    relive_slice_enter(RoleID, AllNewSlice),
    ok.

%% 平江地图ID
-define(pingjianid(FactionID), 10000 + FactionID * 1000 + 102).
%% 王都地图ID
-define(jingchengid(FactionID), 10000 + FactionID * 1000 + 100).

%% @doc 获取死亡回城点
get_relive_home_mapid(RoleMapInfo, FactionID, MapID, PKPoints) ->
    [JailPKPoint] = common_config_dyn:find(jail, jail_in_pkpoints),
    InJail = mod_jail:check_in_jail(MapID),
    AttackFactionID = mod_waroffaction:get_attack_faction_id(),
    DefenceFID = mod_waroffaction:get_defence_faction_id(),
    InHeroFB = mod_hero_fb:is_in_hero_fb(),
    CountryTreasureMapID = mod_country_treasure:get_country_treasure_fb_map_id(),
    IsSceneFbMapId = mod_scene_war_fb:is_scene_war_fb_map_id(MapID),
    IsMissionFBMapID = mod_mission_fb:is_mission_fb_map_id(MapID),
    IsInWarOfKing = mod_warofking:is_warofking_map(),
    if PKPoints >= JailPKPoint ->
            get_relive_home_mapid_jail(RoleMapInfo, InJail);
       PKPoints >= ?RED_NAME_PKPOINT andalso InJail ->
            get_relive_home_mapid_jail(RoleMapInfo, InJail);
       FactionID =:= AttackFactionID ->
            get_relive_home_mapid_waroffaction_attack(RoleMapInfo, MapID);
       FactionID =:= DefenceFID ->
            get_relive_home_mapid_waroffaction_defence(RoleMapInfo, MapID);
       IsInWarOfKing =:= true ->
            mod_warofking:get_warofking_born_info(RoleMapInfo, MapID);
       InHeroFB ->
            get_relive_home_mapid_herofb(RoleMapInfo);
       MapID =:= CountryTreasureMapID ->
            get_relive_home_mapid_country_treasure_fb(RoleMapInfo, MapID);
       IsSceneFbMapId ->
            get_relive_home_mapid_scene_war_fb(RoleMapInfo, MapID);
       IsMissionFBMapID ->
            get_relive_home_mapid_mission_fb(RoleMapInfo, MapID);
       true ->
            get_relive_home_mapid_normal(RoleMapInfo, MapID)
    end.



get_relive_home_mapid_mission_fb(RoleMapInfo, MapID) ->
    #p_map_role{faction_id=FactionID} = RoleMapInfo,
    mod_mission_fb:get_mission_fb_quit_pos(FactionID, MapID).

%% @doc 大明宝藏死亡回城点
get_relive_home_mapid_country_treasure_fb(RoleMapInfo, MapID) ->
    #p_map_role{faction_id=FactionID} = RoleMapInfo,
    {TX, TY} = mod_country_treasure:get_country_treasure_fb_born_points(10000+FactionID*1000+100),
    {MapID, TX, TY}.
%% @doc 场景大战副本死亡回城点
get_relive_home_mapid_scene_war_fb(RoleMapInfo, MapID) ->
    case common_misc:get_born_info_by_map(MapID) of
        {MapID, TX, TY} ->
            {MapID, TX, TY};
        _ ->
            get_relive_home_mapid_normal(RoleMapInfo, MapID)
    end.

get_relive_home_mapid_normal(RoleMapInfo, MapID) ->
    #p_map_role{faction_id=FactionID} = RoleMapInfo,
    HomeMapID = common_misc:get_home_mapid(FactionID, MapID),
    common_misc:get_born_info_by_map(HomeMapID).

get_relive_home_mapid_herofb(RoleMapInfo) ->
    mod_hero_fb:get_hero_fb_quit_pos(RoleMapInfo#p_map_role.faction_id).

%% @doc 获取国战时期防守方回城点
get_relive_home_mapid_waroffaction_defence(RoleMapInfo, MapID) ->
    #p_map_role{faction_id=FactionID} = RoleMapInfo,
    case mod_waroffaction:get_waroffaction_stage() of
        ?WAROFFACTION_FIRST_STAGE ->
            {?pingjianid(FactionID), 59, 21};
        ?WAROFFACTION_SECOND_STAGE ->
            {?jingchengid(FactionID), 64, 66};
        ?WAROFFACTION_THIRD_STAGE ->
            {?jingchengid(FactionID), 64, 66};
        _ ->
            get_relive_home_mapid_normal(RoleMapInfo, MapID)
    end.

%% @doc 获取国战时间攻击方回城点
get_relive_home_mapid_waroffaction_attack(RoleMapInfo, MapID) ->
    DefenFactionID = mod_waroffaction:get_defence_faction_id(),
    case mod_waroffaction:get_waroffaction_stage() of
        ?WAROFFACTION_FIRST_STAGE ->
            {?pingjianid(DefenFactionID), 27, 43};
        ?WAROFFACTION_SECOND_STAGE ->
            {?jingchengid(DefenFactionID), 92, 94};
        ?WAROFFACTION_THIRD_STAGE ->
            {?jingchengid(DefenFactionID), 92, 94};
        _ ->
            get_relive_home_mapid_normal(RoleMapInfo, MapID)
    end.

get_relive_home_mapid_jail(RoleMapInfo, IsInJail) ->
    %% 进入监狱发送信件
    case IsInJail of
        true ->
            ignore;
        _ ->
            #p_map_role{role_id=RoleID, role_name=RoleName} = RoleMapInfo,
            Letter = common_letter:create_temp(?JAIL_LETTER, [RoleName]),
            common_letter:sys2p(RoleID, Letter, "来自监狱长的信件", 3)
    end,

    [JailMapID] = common_config_dyn:find(jail, jail_map_id),
    [{TX, TY}] = common_config_dyn:find(jail, jail_map_born_point),
    {JailMapID, TX, TY}.

%% @doc 回城复活
do_relive_return_home(RoleID, RoleBase, RoleMapInfo, RoleFight, MapState, Unique) ->
    #map_state{mapid=MapID} = MapState,
    %% 取消师徒副本
    catch mod_educate_fb:do_cancel_role_educate_fb(RoleID),
    %% 获取主城ID
    #p_map_role{faction_id=FactionID, hp=HP, mp=MP, pk_point=PKPoints} = RoleMapInfo,
    {HomeMapID, TX, TY} = get_relive_home_mapid(RoleMapInfo, FactionID, MapID, PKPoints),
    {ok, RolePos} = mod_map_role:get_role_pos_detail(RoleID),
    case MapID =:= HomeMapID orelse (mod_warofcity:is_war_map() andalso mod_warofcity:is_in_wartime()) of
        true ->
            %% 地图争夺战特殊处理
            case mod_warofcity:is_war_map() of
                true ->
                    HP2 = common_tool:ceil(HP*0.01),
                    MP2 = common_tool:ceil(MP*0.01);
                _ ->
                    HP2 = HP,
                    MP2 = MP
            end,

            RoleMapInfo2 = RoleMapInfo#p_map_role{hp=HP2, mp=MP2},
            RoleFight2 = RoleFight#p_role_fight{hp=HP2, mp=MP2},
            RolePos2 = RolePos#p_role_pos{map_id=MapID, pos=#p_pos{tx=TX, ty=TY, dir=0}},

            mod_map_actor:set_actor_mapinfo(RoleID, role, RoleMapInfo2),
            set_role_fight(RoleID, RoleFight2),

            DataRecord = #m_role2_relive_toc{succ=true, map_changed=false, map_role=RoleMapInfo2,
                                             role_base=RoleBase, role_pos=RolePos2, role_fight=RoleFight2},
            common_misc:unicast({role, RoleID}, Unique, ?ROLE2, ?ROLE2_RELIVE, DataRecord),
            %% 同地图跳转
            mod_map_actor:same_map_change_pos(RoleID, role, TX, TY, ?CHANGE_POS_TYPE_RELIVE, MapState);

        _ ->
            RolePos2 = RolePos#p_role_pos{map_id=HomeMapID, pos=#p_pos{tx=TX, ty=TY, dir=0}},
            mod_map_actor:set_actor_mapinfo(RoleID, role, RoleMapInfo),
            set_role_fight(RoleID, RoleFight),

            DataRecord = #m_role2_relive_toc{succ=true, map_changed=true, map_role=RoleMapInfo,
                                             role_base=RoleBase, role_pos=RolePos2, role_fight=RoleFight},
            common_misc:unicast({role, RoleID}, Unique, ?ROLE2, ?ROLE2_RELIVE, DataRecord),
            %% 不同地图跳转
            diff_map_change_pos(?CHANGE_MAP_TYPE_RELIVE, RoleID, HomeMapID, TX, TY)
    end,
    ok.

%%玩家扣血
do_role_reduce_hp(RoleID, Decrement, SActorName, SActorID, SActorType, MapState) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            nil;
        RoleMapInfo ->
            ?TRY_CATCH(hook_map_role:role_reduce_hp(RoleMapInfo, SActorID, SActorType),Err1),
            RoleMapInfo2 = reduce_hp(RoleID, RoleMapInfo, Decrement),
            send_role_hpmp_change(RoleID, RoleMapInfo2),

            #p_map_role{hp=HP2, state=State} = RoleMapInfo2,
            case HP2 =< 0 andalso State =/= ?ROLE_STATE_DEAD of
                true ->
                    role_dead(RoleID, RoleMapInfo2, SActorID, SActorType, SActorName, MapState#map_state.mapid);
                _ ->
                    ignore
            end
    end.

%%玩家加血
do_role_add_hp(RoleID, Add, _SActorID) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            ignore;
        RoleMapInfo ->
            RoleMapInfo2 = add_hp(RoleID, RoleMapInfo, Add),
            send_role_hpmp_change(RoleID, RoleMapInfo2)
    end.

%%玩家加蓝
do_role_add_mp(RoleID, Add, _SActorID) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            ignore;
        RoleMapInfo ->
            RoleMapInfo2 = add_mp(RoleID, RoleMapInfo, Add),
            send_role_hpmp_change(RoleID, RoleMapInfo2)
    end.

do_role_reduce_mp(RoleID, Reduce, _SActorID) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            ignore;
        RoleMapInfo ->
            RoleMapInfo2 = reduce_mp(RoleID, RoleMapInfo, Reduce),
            send_role_hpmp_change(RoleID, RoleMapInfo2)
    end.

%%自动回血回蓝
do_role_recover(RoleID) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            ignore;
        RoleMapInfo ->
            #p_map_role{state=State, max_hp=MaxHP, max_mp=MaxMP} = RoleMapInfo,
            {ok, RoleBase} = get_role_base(RoleID),
            #p_role_base{hp_recover_speed=HPRecoverSpeed, mp_recover_speed=MPRecoverSpeed} = RoleBase,
            
            case State of
                ?ROLE_STATE_DEAD ->
                    RecoverHP = 0,
                    RecoverMP = 0;
                ?ROLE_STATE_ZAZEN ->
                    RecoverHP = common_tool:ceil(MaxHP*50/10000+HPRecoverSpeed+20),
                    RecoverMP = common_tool:ceil(MaxMP*50/10000+MPRecoverSpeed+2);
                _ ->
                    RecoverHP = HPRecoverSpeed,
                    RecoverMP = MPRecoverSpeed
            end,
            RoleMapInfo2 = add_hp(RoleID, RoleMapInfo, RecoverHP),
            RoleMapInfo3 = add_mp(RoleID, RoleMapInfo2, RecoverMP),
            send_role_hpmp_change(RoleID, RoleMapInfo3)
    end.      

%%清除玩家的计时器
clear_role_timer(RoleState) ->    
    #r_role_state2{gray_name_timer_ref=GrayTimer,
                   pkpoint_timer_ref=PKPointTimer, 
                   buff_timer_ref=BuffTimerList,
                   training_timer_ref=TrainingTimer
                  } = RoleState,
    GrayTime =
        case 
            erlang:is_reference(GrayTimer) andalso 
            erlang:cancel_timer(GrayTimer) 
        of
            false ->
                0;
            T1 ->
                T1
        end,
    PKTime =
        case 
            erlang:is_reference(PKPointTimer) andalso
            erlang:cancel_timer(PKPointTimer)
        of
            false ->
                0;
            T2 ->
                T2
        end,
    TrainingTime =
        case
            erlang:is_reference(TrainingTimer) andalso
            erlang:cancel_timer(TrainingTimer)
        of
            false ->
                0;
            T3 ->
                T3
        end,
    BuffTimeList = clear_role_buff_timer(BuffTimerList),
    {ok,[{gray_time,GrayTime},{pk_time,PKTime},{training_time, TrainingTime}, {buff_time_list,BuffTimeList}]}.

clear_role_buff_timer(BuffTimerList) ->
    case BuffTimerList of
        undefined ->
            [];
        _ ->
            lists:foldl(
              fun({BuffType, {TimerRef, Msg}},AL) ->
                      case erlang:cancel_timer(TimerRef) of
                          false ->
                              AL;
                          Time ->
                              [{BuffType, {Time, Msg}}|AL]
                      end
              end,[], BuffTimerList)
    end.

do_level_up(RoleID, RoleAttr, RoleBase) ->
    {ok,RoleFight} = get_role_fight(RoleID),
    MaxHP = RoleBase#p_role_base.max_hp,
    MaxMP = RoleBase#p_role_base.max_mp,
    NewRoleFight = RoleFight#p_role_fight{hp=MaxHP, mp=MaxMP},
    set_role_fight(RoleID, NewRoleFight),
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            nil;
        MapRoleInfo ->
            Level = RoleAttr#p_role_attr.level,
            NewMapRoleInfo = MapRoleInfo#p_map_role{
                               hp = MaxHP,
                               mp = MaxMP,
                               max_hp = MaxHP,
                               max_mp = MaxMP,
                               level = Level},
            send_role_hpmp_change(RoleID, NewMapRoleInfo)
    end.            


do_update_map_role_info(RoleBase, RoleAttr, State) when is_record(RoleBase, p_role_base) andalso is_record(RoleAttr,p_role_attr) ->
    #p_role_base{
                  role_id = RoleID, status = Status, faction_id=FactionID,
                  family_id=FamilyID, family_name=FamilyName,
                  max_hp=MaxHP,buffs = Buffs,
                  max_mp=MaxMP, move_speed=MoveSpeed,
                  team_id = TeamID,pk_points  = PkPoint,
                  if_gray_name = IfGrayName
                } = RoleBase,
    #p_role_attr{skin=Skin, level=Level, equips=EquipList} = RoleAttr,
    OldMapInfo = mod_map_actor:get_actor_mapinfo(RoleID,role),
    {ok, EquipRingColor, MountColor} = common_misc:get_equip_ring_and_mount_color(EquipList),
    case OldMapInfo of
        OldMapInfo when erlang:is_record(OldMapInfo, p_map_role) ->
            RoleMapInfo = OldMapInfo#p_map_role{
                            faction_id=FactionID, family_id=FamilyID,
                            family_name=FamilyName, max_hp=MaxHP, max_mp=MaxMP,
                            state_buffs = Buffs,skin=Skin, move_speed=MoveSpeed, team_id=TeamID, 
                            level=Level, pk_point=PkPoint, state=Status,
                            gray_name=IfGrayName, equip_ring_color=EquipRingColor, mount_color=MountColor
                           },
            %%TODO:这里的state挺危险！！
            Record = #m_map_update_actor_mapinfo_toc{actor_id = RoleID,actor_type = ?TYPE_ROLE,role_info = RoleMapInfo},
            mgeem_map:do_broadcast_insence_include([{role,RoleID}],?MAP,?MAP_UPDATE_ACTOR_MAPINFO,Record,State),
            %% ?DEV("=======~ts====~w====", ["准备写入玩家地图信息", RoleMapInfo]),
            mod_map_actor:set_actor_mapinfo(RoleID,role,RoleMapInfo);
        OldMapInfo ->
            ?ERROR_MSG("~ts:~w", ["地图角色信息匹配出错了", OldMapInfo])
    end;
%%newvaluelist: [{field, newvalue}...]
do_update_map_role_info(RoleID, NewValueList, State) when is_integer(RoleID) ->
    MapInfo =  mod_map_actor:get_actor_mapinfo(RoleID, role),
    ?DEBUG("do_update_map_role_info, mapinfo: ~w, newvaluelist: ~w", [MapInfo, NewValueList]),
    IsMapInfo = is_record(MapInfo, p_map_role),
    case IsMapInfo of
        true ->
            MapInfo2 =
                lists:foldl(
                  fun({Field, NewValue}, Acc) ->
                          setelement(Field, Acc, NewValue)
                  end, MapInfo, NewValueList),
            mod_map_actor:set_actor_mapinfo(RoleID, role, MapInfo2),
            catch do_hook_update_map_role_info(RoleID,NewValueList,MapInfo2),
            R = #m_map_update_actor_mapinfo_toc{actor_id=RoleID, actor_type=?TYPE_ROLE, role_info=MapInfo2},
            mgeem_map:do_broadcast_insence_include([{role, RoleID}], ?MAP, ?MAP_UPDATE_ACTOR_MAPINFO, R, State);
        false ->
            ?DEBUG("do_update_map-role_info, false", []),
            ok
    end.
%% add by caochuncheng 玩家状态变化需要同步到p_role_base
do_hook_update_map_role_info(RoleId,NewValueList,MapInfo) ->
    lists:foreach(
      fun({Field, NewValue}) ->
              %%角色状态改变hook
              case Field =:= #p_map_role.state of
                  true ->
                      do_role_state_change(RoleId, MapInfo#p_map_role.state, NewValue);
                  _ ->
                      ignore
              end
      end,NewValueList).

do_role_state_change(RoleID, OldState, NewState) ->
    hook_map_role:state_change(RoleID,OldState,NewState),
    case OldState =:= ?ROLE_STATE_ZAZEN 
        andalso (NewState =:= ?ROLE_STATE_TRAINING orelse NewState =:= ?ROLE_STATE_STALL orelse NewState =:= ?ROLE_STATE_COLLECT)
    of
        true when NewState =:= ?ROLE_STATE_STALL ->
            case common_transaction:transaction(
                   fun() ->
                           {ok, RoleBase} = get_role_base(RoleID),
                           set_role_base(RoleID, RoleBase#p_role_base{status=?ROLE_STATE_NORMAL})
                   end)
            of
                {atomic, _} ->
                    remove_zazen_buff(RoleID);
                {aborted, R} ->
                    ?ERROR_MSG("do_role_state_change, error: ~w", [R])
            end;
        true ->
            remove_zazen_buff(RoleID);
        _ ->
            ignore
    end.
             

add_hp(_RoleID, RoleMapInfo, Add) ->
    #p_map_role{hp=HP, max_hp=MaxHP} = RoleMapInfo,
    
    case HP =< 0 orelse HP =:= MaxHP of
        true ->
            RoleMapInfo;
        _ ->
            HP2 = HP + Add,
            case HP2 >= MaxHP of
                true ->
                    HP3 = MaxHP;
                _ ->
                    HP3 = HP2
            end,
            
            RoleMapInfo#p_map_role{hp=HP3}
    end.

reduce_hp(_RoleID, RoleMapInfo, Reduce) ->
    #p_map_role{hp=HP} = RoleMapInfo,
    
    case HP =< 0 of
        true ->
            RoleMapInfo;
        _ ->
            HP2 = HP - Reduce,
            case HP2 >= 0 of
                true ->
                    HP3 = HP2;
                _ ->
                    HP3 = 0
            end,
            
            RoleMapInfo#p_map_role{hp=HP3}
    end.

add_mp(_RoleID, RoleMapInfo, Add) ->
    #p_map_role{mp=MP, max_mp=MaxMP, state=State} = RoleMapInfo, 
    
    case State =:= ?ROLE_STATE_DEAD orelse MP =:= MaxMP of
        true ->
            RoleMapInfo;
        _ ->
            MP2 = MP + Add,
            case MP2 >= MaxMP of
                true ->
                    MP3 = MaxMP;
                _ ->
                    MP3 = MP2
            end,
            
            RoleMapInfo#p_map_role{mp=MP3}
    end.

reduce_mp(_RoleID, RoleMapInfo, Reduce) ->
    #p_map_role{mp=MP, max_mp=_MaxMP} = RoleMapInfo,
    
    case MP =< 0 of
        true ->
            RoleMapInfo;
        _ ->
            MP2 = MP - Reduce,
            case MP2 >= 0 of
                true ->
                    MP3 = MP2;
                _ ->
                    MP3 = 0
            end,
            
            RoleMapInfo#p_map_role{mp=MP3}
    end.

%%同步玩家位置
sync_role_pos(RoleID, Line) ->
    case  mod_map_actor:get_actor_pos(RoleID, role) of
        undefined ->
            kick_role(RoleID, Line);
        Pos ->
            mod_map_actor:erase_actor_pid_lastwalkpath(RoleID, role),
            mod_map_actor:erase_actor_pid_lastkeypath(RoleID, role),
            DataRecord = #m_move_sync_toc{roleid=RoleID, pos=Pos},
            ?DEBUG("sync role [~w] to ~w", [RoleID, Pos]),
            mgeem_map:do_broadcast_insence_include([{role, RoleID}], ?MOVE, ?MOVE_SYNC, DataRecord,mgeem_map:get_state())
    end.


reduce_equip_endurance2_1(RoleID) ->
    case get({attack_count, RoleID}) of
        undefined ->
            put({attack_count, RoleID}, 1);
        Num when Num+1 =:= 200 ->
            put({attack_count, RoleID}, 0),
            Reduce = get_endurance_reduce_num(RoleID, Num, attack),
            mod_equip:reduce_equip_endurance(RoleID, ?ATTACKEQUIP, -Reduce, true, 0);
        Num ->
            put({attack_count, RoleID}, Num+1)
    end.

reduce_equip_endurance2_2(RoleID) ->
    case get({defen_count, RoleID}) of
        undefined ->
            put({defen_count, RoleID}, 1);
        Num when Num+1 =:= 200 ->
            put({defen_count, RoleID}, 0),
            Reduce = get_endurance_reduce_num(RoleID, Num, defen),
            mod_equip:reduce_equip_endurance(RoleID, ?DEFENEQUIP, -Reduce, true, 0);
        Num ->
            put({defen_count, RoleID}, Num+1)
    end.

%% @doc 每秒最多只能减一点耐久
get_endurance_reduce_num(RoleID, Num, attack) ->
    case get({last_en_reduce_time_attack, RoleID}) of
        undefined ->
            R = Num;
        Time ->
            Now = common_tool:now(),
            case Num > Now - Time of
                true ->
                    R = Now - Time;
                _ ->
                    R = Num
            end
    end,
    put({last_en_reduce_time_attack, RoleID}, common_tool:now()),
    R;
get_endurance_reduce_num(RoleID, Num, defen) ->
    case get({last_en_reduce_time_defen, RoleID}) of
        undefined ->
            R = Num;
        Time ->
            Now = common_tool:now(),
            case Num > Now - Time of
                true ->
                    R = Now - Time;
                _ ->
                    R = Num
            end
    end,
    put({last_en_reduce_time_defen, RoleID}, common_tool:now()),
    R.

relive_slice_enter(_, AllSlice) when erlang:length(AllSlice) =:= 0 ->
    ignore;
relive_slice_enter(RoleID, AllSlice) ->
    Module = ?ROLE2, 
    Method = ?ROLE2_RELIVE,
    AroundRoles = mgeem_map:get_all_in_sence_user_by_slice_list(AllSlice),
    Role2 = mod_map_actor:get_actor_mapinfo(RoleID, role),  
    DataRecord2 = #m_role2_relive_toc{return_self=false, map_role=Role2},
    AroundRoles2 = lists:delete(RoleID, AroundRoles),
    mgeem_map:broadcast(AroundRoles2, ?DEFAULT_UNIQUE, Module, Method, DataRecord2).



do_random_move(RoleID, State) ->
    Pos = mod_map_actor:get_actor_pos(RoleID, role),
    #p_pos{tx=TX, ty=TY} = Pos,
    #map_state{grid_width=GridWidth, grid_height=GridHeight} = State,
    {X, Y} = get_random_tx_ty(TX, TY, GridWidth, GridHeight, 1),
    mod_map_actor:same_map_change_pos(RoleID, role, X, Y, ?CHANGE_POS_TYPE_NORMAL, State).

get_random_tx_ty(TX, TY, _GridWidth, _GridHeight, 20) ->
    {TX, TY};
get_random_tx_ty(TX, TY, GridWidth, GridHeight, N) ->
    X = random:uniform(GridWidth) div ?TILE_SIZE,
    Y = random:uniform(GridHeight) div ?TILE_SIZE,
    case get({X, Y}) of
        undefined ->
            get_random_tx_ty(TX, TY, GridWidth, GridHeight, N+1);
        safe ->
            {X, Y};
        _ ->
            case get({ref, X, Y}) of
                [] ->
                    {X, Y};
                _ ->
                    get_random_tx_ty(TX, TY, GridWidth, GridHeight, N+1)
            end
    end.


do_return_home(RoleID, State) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            ?ERROR_MSG("do_return_home, cant find role mapinfo, roleid: ~w", [RoleID]);
        RoleMapInfo ->
            FactionID = RoleMapInfo#p_map_role.faction_id,
            MapID = State#map_state.mapid,
            HomeMapID = common_misc:get_home_mapid(FactionID, MapID),
            case MapID =:= HomeMapID of
                true ->
                    {MapID, TX, TY} = common_misc:get_born_info_by_map(MapID),
                    mod_map_actor:same_map_change_pos(RoleID, role, TX, TY, ?CHANGE_POS_TYPE_NORMAL, State);
                false ->
                    {HomeMapID, TX, TY} = common_misc:get_born_info_by_map(HomeMapID),
                    diff_map_change_pos(?CHANGE_MAP_TYPE_RETURN_HOME, RoleID, HomeMapID, TX, TY)
            end
    end.

do_return_peace_village(RoleID)->
    case common_misc:get_dirty_role_base(RoleID) of
        {ok,RoleBase} ->
            #p_role_base{faction_id=FactionID} = RoleBase,
            MapID = 10000 + FactionID * 1000, %%太平村地图ID
            {MapID, TX, TY} = common_misc:get_born_info_by_map(MapID),
            diff_map_change_pos(RoleID, MapID, TX, TY),
            ?DEBUG("do_return_peace_village  RoleID=~w, MapID=~w, TX2=~w, TY2=~w",[RoleID, MapID, TX, TY]);
        Reason ->
            ?ERROR_MSG("~ts,RoleId=~w,Reason=~w",["脏读角色基础数据出错",RoleID,Reason])
    end.

diff_map_change_pos(RoleID, MapID, TX, TY) ->
    put({enter, RoleID}, {MapID, TX, TY}),

    DataRecord = #m_map_change_map_toc{mapid=MapID, tx=TX, ty=TY},
    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?MAP, ?MAP_CHANGE_MAP, DataRecord).

diff_map_change_pos(ChangeType, RoleID, MapID, TX, TY) ->
    %%跨地图传送类型
    put({change_map_type, RoleID}, ChangeType),

    %%打个标记，非跳转点进行跳转需要这一步
    put({enter, RoleID}, {MapID, TX, TY}),
    
    DataRecord = #m_map_change_map_toc{mapid=MapID, tx=TX, ty=TY},
    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?MAP, ?MAP_CHANGE_MAP, DataRecord).

do_skill_transfer(ActorID, ActorType,DistRound,State) ->
    Pos = mod_map_actor:get_actor_pos(ActorID,ActorType),
    #p_pos{tx = TX, ty = TY} = Pos,
    {TX2,TY2} = get_random_tx_ty_in_distround(TX, TY , DistRound, 0),
    mod_map_actor:same_map_change_pos(ActorID, ActorType, TX2, TY2, ?CHANGE_POS_TYPE_NORMAL, State).

%%连续20次不能随机到可走点的话随机回原点
get_random_tx_ty_in_distround(TX, TY , _DistRound, 20) ->
    {TX,TY};
get_random_tx_ty_in_distround(TX, TY , DistRound, Num) ->
    X = random:uniform(DistRound*2+1) - DistRound + TX,
    Y = random:uniform(DistRound*2+1) - DistRound + TY,
    case get({X, Y}) of
        undefined ->
            get_random_tx_ty_in_distround(TX, TY , DistRound, Num+1);
        safe ->
            {X, Y};
        _ ->
            case get({ref, X, Y}) of
                [] ->
                    {X,Y};
                _ ->
                    get_random_tx_ty_in_distround(TX, TY , DistRound, Num+1)
            end
    end.

do_skill_charge(ActorID, ActorType,DestActorID,DestActorType,State) ->
    case mod_map_actor:get_actor_pos(ActorID,ActorType) of
        undefined ->
            ignore;
        Pos ->
            #p_pos{tx = TX, ty = TY} = Pos,
            case mod_map_actor:get_actor_pos(DestActorID,DestActorType) of
                undefined ->
                    ignore;
                DestPos ->
                    #p_pos{tx = DestTX, ty = DestTY} = DestPos,
                    {_, {NewTX,NewTY}} = get_charge_tx_ty(TX,TY,DestTX,DestTY),
                    case NewTX =:= TX andalso NewTY =:= TY of
                        true ->
                            nil;
                        false ->
                            mod_map_actor:same_map_change_pos(ActorID, ActorType, NewTX, NewTY, ?CHANGE_POS_TYPE_CHARGE, State)
                    end
            end
    end.


get_charge_tx_ty(TX,TY,DestTX,DestTY) ->
    OldDis =  abs(DestTX - TX) + abs(DestTY - TY),
    List = lists:foldr(
             fun(X,Acc0) ->
                     lists:foldr(
                       fun(Y,Acc1) ->
                               [{X,Y}|Acc1]
                       end,Acc0,[DestTY-1,DestTY,DestTY+1])
             end,[],[DestTX-1,DestTX,DestTX+1]),
    lists:foldr(
      fun({X ,Y}, {Acc0,Acc1}) ->
              case get({TX, TY}) of
                  undefined ->
                      {Acc0,Acc1};
                  safe ->
                      get_charge_tx_ty2(X,Y,TX,TY,Acc0,Acc1);
                  not_safe ->
                      get_charge_tx_ty2(X,Y,TX,TY,Acc0,Acc1);
                  _ ->
                      case get({ref,TX,TY}) of
                          [] ->
                              get_charge_tx_ty2(X,Y,TX,TY,Acc0,Acc1);
                          _ ->
                              {Acc0,Acc1}
                      end
              end
      end,{OldDis,{DestTX,DestTY}},List).
get_charge_tx_ty2(X,Y,TX,TY,Acc0,Acc1) ->
    Dis = abs(X - TX) + abs(Y - TY),
    case Dis < Acc0 of
        true ->
            {Dis,{X,Y}};              
        false ->
            {Acc0,Acc1}
    end.

do_bubble_msg(RoleID, Line, DataIn, State) ->
    Msg = DataIn#m_bubble_send_tos.msg,
    Type = DataIn#m_bubble_send_tos.action_type,
    ToRoleID = DataIn#m_bubble_send_tos.to_role_id,
    case mod_map_actor:get_actor_txty_by_id(RoleID, role) of
        {TX2, TY2}->
            {ok, RoleBase} = mod_map_role:get_role_base(RoleID),

            DataRecord = #m_bubble_msg_toc{
              actor_type=1, 
              actor_id=RoleID, 
              actor_name=RoleBase#p_role_base.role_name,
              actor_sex=RoleBase#p_role_base.sex,
              actor_faction=RoleBase#p_role_base.faction_id,
              action_type = Type,
              actor_head=RoleBase#p_role_base.head,
              msg=Msg,
              to_role_id=ToRoleID},

            OffsetX = State#map_state.offsetx,
            OffsetY = State#map_state.offsety,
            AllSlice = mgeem_map:get_9_slice_by_txty(TX2, TY2, OffsetX, OffsetY),
            RoleIDList = mgeem_map:get_all_in_sence_user_by_slice_list(AllSlice),
            ?DEBUG("~ts:~w", ["要发送到的玩家进程号", RoleIDList]),
            mgeem_map:broadcast(RoleIDList, 
                                  ?DEFAULT_UNIQUE, 
                                  ?BUBBLE, 
                                  ?BUBBLE_MSG, 
                                  DataRecord),
            case Type of
                1->global:send(mgeel_stat_server,{big_face,Msg});
                _->ignore
            end;
        undefined ->
            mod_map_role:kick_role(RoleID, Line)
    end.


do_change_titlename(RoleID, TitleID, TitleName, TitleColor, State) ->
    case mod_map_actor:get_actor_mapinfo(RoleID,role) of
        undefined ->
            nil;
        MapInfo ->
            {ok, RoleBase} = get_role_base(RoleID),
            #p_role_base{cur_title=OldTitleName} = RoleBase,

            RoleTitles = common_title:get_role_sence_titles(RoleID),

            %% 如果当前的称号还有效的话，就不换了
            case lists:keyfind(OldTitleName, #p_title.name, RoleTitles) of
                false ->
                    RoleBase2 = RoleBase#p_role_base{cur_title=TitleName, cur_title_color=TitleColor},
                    common_transaction:transaction(fun() ->set_role_base(RoleID, RoleBase2) end),

                    mod_map_actor:set_actor_mapinfo(RoleID,role,MapInfo#p_map_role{cur_title=TitleName,cur_title_color=TitleColor}),

                    DataRecord = #m_title_change_cur_title_toc{succ=true, id=TitleID, color=TitleColor},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?TITLE, ?TITLE_CHANGE_CUR_TITLE, DataRecord),

                    DataBroadcast = #m_map_update_actor_mapinfo_toc{
                      actor_id = RoleID,
                      actor_type = ?TYPE_ROLE,
                      role_info = MapInfo#p_map_role{cur_title=TitleName,cur_title_color=TitleColor}},
                    mgeem_map:do_broadcast_insence_include([{role,RoleID}],?MAP, ?MAP_UPDATE_ACTOR_MAPINFO, DataBroadcast, State);
                _ ->
                    ignore
            end
    end.

role_dead(RoleID, RoleMapInfo, SActorID, SActorType, SActorName, MapID) ->
    %%死亡hook
    catch hook_map_role:role_dead(RoleID, RoleMapInfo, SActorID, SActorType),

    case common_transaction:transaction(
           fun() ->
                   t_do_role_dead(RoleID)
           end)
    of
        {atomic, {ok, RoleBase}} ->
            %%强制玩家下马
            catch mod_equip_mount:force_mountdown(RoleID),
            
              %%召回出战中的宠物
            catch mod_map_pet:role_pet_quit(RoleID),
            %% 死亡时持久化角色数据
            {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
            {ok, RoleBase2} = mod_map_role:get_role_base(RoleID),
            
%            catch mod_map_pet:check_pet_can_relive_owner(RoleBase2),
            
            mgeem_persistent:role_base_attr_persistent(RoleBase2, RoleAttr),

            MapState = mgeem_map:get_state(),
            Change = [{#p_map_role.hp, 0}, {#p_map_role.state, ?ROLE_STATE_DEAD}, {#p_map_role.gray_name, false}],
            do_update_map_role_info(RoleID, Change, MapState),

            %% 去掉清灰名定时
            case get({gray_name_timer, RoleID}) of
                undefined ->
                    ignore;
                TimerRef ->
                    erlang:cancel_timer(TimerRef)
            end,

            %% 清除角色BUFF
            mod_role_buff:remove_buff(RoleID, 0),

            %%死亡广播
            ToOther = #m_role2_dead_other_toc{roleid=RoleID},
            mgeem_map:do_broadcast_insence([{role, RoleID}], ?ROLE2, ?ROLE2_DEAD_OTHER, ToOther, MapState),

            IsInHeroFB = mod_hero_fb:is_in_hero_fb(),
            IsInJail = mod_jail:check_in_jail(MapID),
            %% PK值达到一定数量时，直接在监狱复活
            #p_role_base{pk_points=PKPoints, buffs=Buffs} = RoleBase,
            [JailPKPoints] = common_config_dyn:find(jail, jail_in_pkpoints),
            HasBuffDieTogether = mod_effect:has_buff_die_together(Buffs),

            SActorName2 = get_killer_name(SActorID, SActorType, SActorName),
            if
                HasBuffDieTogether ->
                    %% 同归于尽
                    mod_effect:calc_die_together(RoleMapInfo, MapState),
                    Record = #m_role2_dead_toc{killer=SActorName2, dead_type=?dead_type_die_together},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_DEAD, Record);

                IsInHeroFB ->
                    Record = #m_role2_dead_toc{killer=SActorName2, dead_type=?dead_type_hero_fb},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_DEAD, Record);

                PKPoints >= JailPKPoints andalso (not IsInJail) ->
                    %% 抓进监狱广播
                    #p_role_base{faction_id=FactionID, role_name=RoleName} = RoleBase,
                    case SActorType of
                        server_npc ->
                            Msg = lists:flatten(io_lib:format(?_LANG_JAIL_KILL_BY_SERVER_NPC, [RoleName,SActorName]));
                        role ->
                            Msg = lists:flatten(io_lib:format(?_LANG_JAIL_KILL_BY_PLAYER, [SActorName, RoleName]));
                        _ ->
                            Msg = lists:flatten(io_lib:format(?_LANG_JAIL_KILL_BY_MONSTER, [RoleName]))
                    end,
                    common_broadcast:bc_send_msg_faction(FactionID, [?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], ?BC_MSG_TYPE_CHAT_WORLD, Msg),

                    mod_role2:do_relive(?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_RELIVE, RoleID, ?RELIVE_TYPE_BACK_CITY);

                true ->
                    %% 纪录角色死亡时间
                    put({role_dead_time, RoleID}, common_tool:now()),

                    %% 十分钟后自动复活
                    TimerRef2 = erlang:send_after(?AUTO_RELIVE_TIME, self(), {mod_map_role, {auto_relive, RoleID}}),
                    put({auto_relive_timer_ref, RoleID}, TimerRef2),

                    %%获取原地健康复活需要银两
                    #p_role_base{faction_id=FactionID} = RoleBase,
                    #p_role_attr{equips=Equips, level=Level} = RoleAttr,
                    SilverNeed = get_relive_silver(FactionID, Level, Equips, MapState),
                    Record = #m_role2_dead_toc{killer=SActorName2, relive_type=?RELIVE_TYPE, relive_silver=SilverNeed},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_DEAD, Record)
            end;
        {aborted, Error} ->
            ?ERROR_MSG("do_role_dead2, error: ~w", [Error]),
            ignore
    end.

t_do_role_dead(RoleID) ->
    {ok, RoleBase} = get_role_base(RoleID),
    
    RoleBase2 = RoleBase#p_role_base{status=?ROLE_STATE_DEAD, if_gray_name=false},
    set_role_base(RoleID, RoleBase2),
    
    {ok, RoleBase2}.

%% @doc 死亡惩罚
dead_punish(RoleID, RoleMapInfo, SActorType, MapState, Flag) ->
    %% 掉落：银两或道具，国战期间，参战双方不掉落
    #map_state{mapid=MapID} = MapState,
    #p_map_role{faction_id=FactionID, pk_point=PKPoint} = RoleMapInfo,
    IsInHeroFB = mod_hero_fb:is_hero_fb_map_id(MapID),
    IsInMissionFB = mod_mission_fb:is_mission_fb_map_id(MapID),
    case Flag orelse is_in_waroffaction_dirty(FactionID, MapID) orelse mod_jail:check_in_jail(MapID)
        orelse MapID =:= 10500 orelse IsInHeroFB orelse IsInMissionFB of
        true ->
            ignore;
        _ ->
            role_dead_drop(RoleID, PKPoint, SActorType, MapState)
    end,
    
    %%减装备耐久度
    dead_reduce_equip_endurance(RoleMapInfo, SActorType, MapState#map_state.mapid).

role_dead_drop(RoleID, PKPoint, SActorType, State) ->
    case db:transaction(
           fun() ->
                   t_dead_drop(RoleID, PKPoint, SActorType)
           end)
    of
        {atomic, {DropInfo, UpdateGoodsList, DelGoodsList, DropSilver, Silver, _ReduceList, AttrChangeFlag, _Skin, _Equips}} ->
            DelGoodsList2 = lists:foldl(fun(Goods, Acc) -> [Goods#p_goods{current_num=?MAX_DROP_NUM}|Acc] end, DelGoodsList, UpdateGoodsList),
            drop_goods_log(DelGoodsList2),
            case DropSilver of
                [] ->
                    ok;
                _ ->
                    SilverChange = #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=Silver},
                    DataRecord = #m_role2_attr_change_toc{roleid=RoleID, changes=[SilverChange]},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord)
            end,

            %%掉落并通知客户端物品变动
            case length(DropInfo) =:= 0 of
                true ->
                    ok;
                false ->
                    mod_map_drop:handle({dropthing, RoleID, DropInfo}, State),
                    
                    case UpdateGoodsList of
                        [] ->
                            ok;
                        _ ->
                            common_misc:update_goods_notify({role, RoleID}, UpdateGoodsList)
                    end,

                    case DelGoodsList of
                        [] ->
                            ok;
                        _ ->
                            common_misc:del_goods_notify({role, RoleID}, DelGoodsList)
                    end
            end,

            case AttrChangeFlag of
                true ->
                    attr_change(RoleID);
                _ ->
                    ok
            end;

        {aborted, Error} ->
            ?ERROR_MSG("role_dead_drop, error: ~w", [Error]),

            {error, system_error}
    end.

drop_goods_log(GoodsList) ->
    lists:foreach(
      fun(Goods) ->
              #p_goods{roleid=RoleID}=Goods,
              common_item_logger:log(RoleID,Goods,?LOG_ITEM_TYPE_DIAO_LUO_SHI_QU)
      end,GoodsList).

t_dead_drop(RoleID, PKPoint, SActorType) ->
    %%银两掉落
    {ok, RoleAttr} = get_role_attr(RoleID),
    {DropSilver, Silver} = t_drop_silver(RoleID, RoleAttr#p_role_attr.silver, PKPoint, SActorType),
    RoleAttr2 = RoleAttr#p_role_attr{silver=Silver},
    
    %%身上的物品掉落
    {UpdateGoodsList, DelGoodsList, DropGoodsInfo, ReduceList, AttrChangeFlag, Skin, Equips} =
        t_get_drop_goods(RoleID, RoleAttr2, PKPoint, SActorType),
    
    {lists:append(DropSilver, DropGoodsInfo), UpdateGoodsList, DelGoodsList, DropSilver, Silver, ReduceList, AttrChangeFlag, Skin, Equips}.
    
t_drop_silver(RoleID, Silver, PKPoint, SActorType) ->
    DropRate = get_silver_drop_rate(PKPoint, SActorType),
    SilverDrop = common_tool:ceil(Silver*DropRate/10000),
    case Silver < SilverDrop of
        true ->
            SilverDrop2 = Silver;
        false ->
            SilverDrop2 = SilverDrop
    end,
    case SilverDrop2 =/= 0 of
        true ->
            common_consume_logger:use_silver({RoleID, 0, SilverDrop2, ?CONSUME_TYPE_SILVER_DROP_FOR_DEAD, 
                                              ""}),
            {[#p_map_dropthing{roles=[], ismoney=true, money=SilverDrop2}], Silver-SilverDrop2};
        _ ->
            {[], Silver}
    end.

%%获取掉落物
t_get_drop_goods(RoleID, RoleAttr, PKPoint, SActorType) ->
    %%获取角色身上所有的东西
    EquipList = RoleAttr#p_role_attr.equips,
    GoodsList = mod_refining_bag:get_goods_by_bag_ids(RoleID,[1,2,3,4]),
    GoodsList2 = lists:append([EquipList,GoodsList]),
    {ok, RoleBase} = get_role_base(RoleID),
    {DropList, ReduceList} = get_drop_goods(GoodsList2, PKPoint, SActorType),
    
    %%获取掉落信息及新的角色属性
    {UpdateGoodsList, DelGoodsList, DropGoodsInfo, RoleAttr2, RoleBase2} = mod_goods:t_drop_goods(DropList, [], [], [], RoleAttr, RoleBase),
    set_role_attr(RoleID, RoleAttr2),

    %%如果身上的装备掉了，则要重新计算属性
    case length(RoleAttr#p_role_attr.equips) =:= length(RoleAttr2#p_role_attr.equips) of
        true ->
            AttrChangeFlag = false,
            ok;
        _ ->
            set_role_base(RoleID, RoleBase2),
            AttrChangeFlag = true
    end,

    #p_role_attr{skin=Skin} = RoleAttr,
    #p_role_attr{skin=Skin2, equips=Equips} = RoleAttr2,
    case Skin =:= Skin2 of
        true ->
            Skin3 = undefined;
        _ ->
            Skin3 = Skin2
    end,
    {UpdateGoodsList, DelGoodsList, DropGoodsInfo, ReduceList, AttrChangeFlag, Skin3, Equips}. 

%%返回掉落列表及减耐久列表
get_drop_goods(GoodsList, PKPoint, SActorType) ->
    lists:foldl(
      fun(Goods, {DropList, ReduceList}) ->
              #p_goods{bagid=BagID, bind=Bind, type=Type} = Goods,
              %%获取掉落概率
              Rate = get_goods_drop_rate(BagID, PKPoint, SActorType),
              %%是否可以掉落
              case if_goods_drop(Rate, Bind, BagID, Type) of
                  true ->
                      {[Goods|DropList], ReduceList};
                  false ->
                      %%不掉的话可以减耐久列表，只有装备才减耐久度。。。
                      case BagID =:= 0 andalso Type =:= 3 of
                          true ->
                              {DropList, [Goods|ReduceList]};
                          _ ->
                              {DropList, ReduceList}
                      end
              end
      end, {[], []}, GoodsList).

%%获取掉落的概率
get_goods_drop_rate(BagID, PKPoint, _SrcActorType) ->
    %%身上及背包里面的东西有不同的概率
    PKState = get_pk_state(PKPoint),
    [DropRate] = common_config_dyn:find(etc, {drop_rate, PKState}),
    case BagID =:= 0 of
        true ->
            #r_drop_rate{equip_drop_rate={Min, Max}} = DropRate;
        false ->
            #r_drop_rate{bag_drop_rate={Min, Max}} = DropRate
    end,
    common_tool:random(Min, Max).

if_goods_drop(Rate, Bind, BagID, Type) ->
    %%绑定的东西不会掉落
    case Bind of
        true ->
            false;
        false ->
            %%背包及身上以外的东西不会掉落
            case BagID =:= 1 orelse BagID =:= 2 orelse BagID =:= 3 orelse BagID =:= 4
                orelse (BagID =:= 0 andalso Type =:= 3) of
                false ->
                    false;
                _ ->
                    R = random:uniform(10000),
                    R =< Rate
            end
    end.

%%获取银两掉落概率
get_silver_drop_rate(PKPoint, _SrcActorType) ->
    PKState = get_pk_state(PKPoint),
    [#r_drop_rate{silver_drop_rate={Min, Max}}] = common_config_dyn:find(etc, {drop_rate, PKState}),
    common_tool:random(Min, Max).

dead_reduce_equip_endurance(RoleMapInfo, SActorType, MapID) ->
    %%获取耐久度减少的比例，随PK值及攻击角色而变
    Rate = get_reduce_endurance_rate(RoleMapInfo, SActorType, MapID),

    mod_equip:reduce_equip_endurance(RoleMapInfo#p_map_role.role_id, ?ALLEQUIP, -Rate, false, 0).

%% @doc 获取耐久度掉落概率
get_reduce_endurance_rate(RoleMapInfo, SrcActorType, MapID) ->
    #p_map_role{pk_point=PKPoint, faction_id=FactionID} = RoleMapInfo,
    %% 是否在国内，以及是国战期间，概率不同
    case common_misc:if_in_self_country(FactionID, MapID) of
        true ->
            case is_in_waroffaction_dirty(FactionID, MapID) of
                true ->
                    Rate = 100 / 70;
                _ ->
                    Rate = 2
            end;
        _ ->
            case is_in_waroffaction_dirty(FactionID, MapID) of
                true ->
                    Rate = 100 / 45;
                _ ->
                    Rate = 100 / 30
            end
    end,
    %% PK值状况，被谁杀死影响倍数
    PKState = get_pk_state(PKPoint),
    if
        PKState =:= ?PK_STATE_RED andalso SrcActorType =:= role ->
            Rate * 2;
        PKState =:= ?PK_STATE_YELLOW andalso SrcActorType =:= role ->
            Rate * 1.5;
        PKState =:= ?PK_STATE_RED andalso SrcActorType =:= monster ->
            Rate * 1.5;
        PKState =:= ?PK_STATE_YELLOW andalso SrcActorType =:= monster ->
            Rate * 1.3;
        true ->
            Rate
    end.

%% @doc 是否国战，以及是否参战国
is_in_waroffaction(FactionID) ->
    case mod_waroffaction:get_attack_faction_id() of
        FactionID ->
            true;
        _ ->
            case mod_waroffaction:get_defence_faction_id() of
                FactionID ->
                    true;
                _ ->
                    false
            end
    end.

%% @doc 是否国战，赃读数据库
is_in_waroffaction_dirty(FactionID, MapID) ->
    case db:dirty_read(?DB_WAROFFACTION, 1) of
        [WarInfo] ->
            #r_waroffaction{defence_faction_id=DFactionID, attack_faction_id=AFactionID} = WarInfo,
            [WarMapList] = common_config_dyn:find(etc, {waroffaction_map_id, DFactionID}),
            lists:member(MapID, WarMapList) andalso (FactionID =:= DFactionID orelse FactionID =:= AFactionID);
        _ ->
            false
    end.

%%------------------------------------------------------------------------------------------------------------------
%%玩家增加经验
add_exp(RoleID,Increment) ->
    self() ! {mod_map_role, {add_exp, RoleID, Increment}}.

add_buff(RoleID, BuffDetail) ->
    self() ! {mod_map_role, {add_buff, RoleID, RoleID, role, BuffDetail}}.

attr_change(RoleID) ->
    self() ! {mod_map_role, {attr_change, RoleID}}.

call_ybc_mission_status(RoleID) ->
    Proc = common_misc:get_world_role_process_name(RoleID),
    gen_server:call({global,Proc},{ybc_mission_status,RoleID}).


%%ChangeMapType: 地图跳转类型，定义见common.hrl，暂时只有镖车用到
do_change_map(RoleID, MapID, TX, TY, ChangeMapType) ->
    put({enter, RoleID}, {MapID, TX, TY}),
    put({change_map_type, RoleID}, ChangeMapType).


get_pk_state(PKPoint) ->
    if
        PKPoint > 19 ->
            ?PK_STATE_RED;
        PKPoint > 0 ->
            ?PK_STATE_YELLOW;
        true ->
            ?PK_STATE_WHITE
    end.

do_monster_dead_add_exp(RoleID, Add, MonsterType, RoleState, KillFlag, EnergyIndex) ->
    %% 任务计算怪物时，按最后一刀的功击体来计算
    case KillFlag of
        true ->
            hook_monster_dead_exp:hook({RoleID, MonsterType, Add});
        _ ->
            next
    end,
    %% 当组队时，队员死亡不可以获取经验
    if RoleState =:= ?ROLE_STATE_DEAD ->
           ignore;
       true ->
           do_add_exp(RoleID, Add),
           ok
    end,
    try
        %% 玩家精力值小于1时，已在怪物那里直接加了经验
        case EnergyIndex >= 1 of
            true ->
                mod_map_pet:add_pet_exp(RoleID, Add,true);
            _ ->
                ignore
        end
    catch
        _:Error ->
            ?ERROR_MSG("add_pet_exp when role add monster dead exp, error: ~w, stacktrace: ~w", [Error, erlang:get_stacktrace()])
    end.

    
%%增加经验
do_add_exp(RoleID, Add) ->
    %% 防止出现小数点
    Add2 = common_tool:ceil(Add),
    case common_transaction:transaction(
           fun() ->
                   t_add_exp(RoleID, Add2, ?EXP_ADD_TYPE_NORMAL)
           end)
    of
        {atomic, {exp_change, Exp}} ->
            ExpChange = #p_role_attr_change{change_type=?ROLE_EXP_CHANGE, new_value=Exp},
            DataRecord = #m_role2_attr_change_toc{roleid=RoleID, changes=[ExpChange]},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord),
            ok;

        {atomic, {level_up, Level, RoleAttr, RoleBase}} ->
            do_after_level_up(Level, RoleAttr, RoleBase, Add2, ?DEFAULT_UNIQUE, true),
            ok;
        %% 悲剧的写法
        {aborted, ?_LANG_ROLE2_ADD_EXP_EXP_FULL} ->
            DataRecord = #m_role2_exp_full_toc{text=?_LANG_ROLE2_ADD_EXP_EXP_FULL},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_EXP_FULL, DataRecord),
            {fail,?_LANG_ROLE2_ADD_EXP_EXP_FULL};

        {aborted, Reason} when is_binary(Reason) ->
            {fail,Reason};
        {aborted, Reason} ->
            ?ERROR_MSG("do_add_exp, reason: ~w", [Reason]),
            {fail,Reason}                                      
    end.

%%level: 原等级，roleattr, rolebase：新的角色属性，online: 角色是否在线
do_after_level_up(Level, RoleAttr, RoleBase, Add, Unique, Online) ->
    %% 升级时进行持久化
    mgeem_persistent:role_base_attr_persistent(RoleBase, RoleAttr),
    #p_role_attr{role_id=RoleID, role_name=RoleName, level=Level2, exp=Exp, next_level_exp=NextLevelExp, 
                 remain_skill_points=RemainSkillPoint} = RoleAttr,
    #p_role_base{faction_id=FactionID, remain_attr_points=RemainAttrPoint,
                 max_hp=MaxHP, max_mp=MaxMP} = RoleBase,

    %%通知排行榜
    case Level2 >= 30 of
        true ->
            RoleLevelRank = common_ranking:get_level_rank_record(RoleBase, RoleAttr),
            global:send(mgeew_ranking, {ranking_element_update, ranking_role_level, RoleLevelRank}),
            add_level_title(Level, Level2, RoleID);
        _ ->
            ignore
    end,

    %%玩家升级hook触发点~~大家可以往 hook_level_change 模块 里面堆自己的代码 别在这里
    %%该函数返回ok
    hook_level_change:hook({RoleID, Level, Level2, FactionID}),
    %%发送等级信件
    send_level_up_mail(RoleID, RoleName, Level, Level2),

    case Online of
        true ->
            %%通知地图角色升级
            common_misc:send_to_rolemap(RoleID, {mod_map_role, {level_up, RoleID, RoleAttr, RoleBase}}),
            %%升级消息通知
            DataRecord = #m_role2_levelup_toc{
              level=Level2,
              attr_points=RemainAttrPoint,
              maxhp=MaxHP,
              maxmp=MaxMP,
              skill_points=RemainSkillPoint,
              exp=Exp,
              next_level_exp=NextLevelExp,
              total_add_exp=Add
             },
            common_misc:unicast({role, RoleID}, Unique, ?ROLE2, ?ROLE2_LEVELUP, DataRecord),
            
            %%前10级自动加属性点后通知新的rolebase
            case Level2 < 20 of
                true ->
                    DataRecord2 = #m_role2_base_reload_toc{role_base=RoleBase},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_BASE_RELOAD, DataRecord2);
                false ->
                    ignore
            end,

            %% 20级以下不广播特级消息，前端不播特效。。。
            case Level2 < 20 of
                true ->
                    ignore;
                _ ->
                    ToOther = #m_role2_levelup_other_toc{roleid=RoleID},
                    mgeem_map:broadcast([RoleID], ?ROLE2, ?ROLE2_LEVELUP_OTHER, ToOther)
            end,
            
            %%升级后给予赠品通知
            mod_present:hook_level_up(RoleID,RoleAttr,RoleBase);
        _ ->
            ignore
    end.

t_add_exp(RoleID, Add, ExpAddType) ->
    Add2 = common_tool:ceil(Add),
    {ok, RoleAttr} = get_role_attr(RoleID),
    #p_role_attr{exp=Exp, level=Level, next_level_exp=NextLevelExp} = RoleAttr,
    {ok, #p_role_base{status=RoleState}} = get_role_base(RoleID),
    %% 训练状态下不能获取经验
    case RoleState =:= ?ROLE_STATE_TRAINING andalso ExpAddType =:= ?EXP_ADD_TYPE_NORMAL of
        true ->
            common_transaction:abort(?_LANG_ROLE2_ADD_EXP_TRAINING_STATE);
        _ ->
            ok
    end,
    %% 当前经验如果已经储满的话，则不能再获得经验
    case Exp >= NextLevelExp * 3 of
        true ->
            common_transaction:abort(?_LANG_ROLE2_ADD_EXP_EXP_FULL);
        _ ->
            ok
    end,
    Exp2 = Exp + Add2,
    case Exp2 >= NextLevelExp of
        true ->
            [AutoLevelUp] = common_config_dyn:find(etc, auto_level_up),
            case Level < AutoLevelUp of
                true ->
                    t_auto_level_up(RoleAttr, Exp2);
                _ ->
                    t_add_exp2(RoleAttr, Exp2)
            end;
        _ ->
            t_add_exp2(RoleAttr, Exp2)
    end.

t_add_exp2(RoleAttr, Exp) ->
    RoleAttr2 = RoleAttr#p_role_attr{exp=Exp},
    set_role_attr(RoleAttr#p_role_attr.role_id, RoleAttr2),
    {exp_change, Exp}.

t_auto_level_up(RoleAttr, Exp) ->
    #p_role_attr{role_id=RoleID, level=Level} = RoleAttr,
    {ok, RoleBase} = get_role_base(RoleID),
    
    {Level2, Exp2} = mod_exp:get_new_level(Exp, Level),
    t_level_up(RoleAttr, RoleBase, Level, Level2, Exp2).
 
send_level_up_mail(RoleID, _RoleName, _Level, Level2) ->
    %% 去掉玩家升级信件功能，只是暂时的，后续会开放 Level2 > 39
    case Level2 > 0 of
        true ->
            ignore;
        _ ->
            if
				Level2 =:= 25 ->
                    Text = common_letter:create_temp(?LEVEL_TWENTY_FIVE_LETTER,[?NPC_BAO_ZANG_CHUAN_SONG]);
                Level2 =:= 28 -> 
                    Text = common_letter:create_temp(?LEVEL_TWENTY_EIGHT_LETTER,[?NPC_LI_MENG_YANG,?NPC_ZHANG_SAN_FENG]);
				Level2 =:= 30 ->
                    Text = common_letter:create_temp(?LEVEL_THIRTY_LETTER,[?NPC_XIA_YUAN_JI]);
				Level2 =:= 39 ->
                    Text = common_letter:create_temp(?LEVEL_THIRTY_NINE_LETTER,[?NPC_MU_YING]);
                true ->
                    Text = 0
            end,
			?DEBUG("Text:~w~n",[Text]),
            case Text =/= 0 of
                true ->
                    common_letter:sys2p(RoleID,Text,"快速升级提示",5);
                _ ->
                    ignore
            end
    end.

level_up(RoleAttr, RoleBase, Level, Level2, Exp) ->
    case db:transaction(
           fun() ->
                   t_level_up(RoleAttr, RoleBase, Level, Level2, Exp)
           end)
    of
        {atomic, {level_up, Level, RoleAttr2, RoleBase2}} ->
            do_after_level_up(Level, RoleAttr2, RoleBase2, Exp, ?DEFAULT_UNIQUE, true);
        {aborted, R} ->
            ?ERROR_MSG("level_up, r: ~w", [R])
    end.

t_level_up(RoleAttr, RoleBase, Level, Level2, Exp) ->
    #p_role_attr{role_id=RoleID, remain_skill_points=RemainSkillPoint,category = Category} = RoleAttr,
    #p_role_base{remain_attr_points=RemainAttrPoint} = RoleBase,
    
    RemainAttrPoint2 =
        lists:foldl(
          fun(L, Acc) ->
                  Acc + mod_role_attr:get_new_attr_points(L)
          end, RemainAttrPoint, lists:seq(Level+1, Level2)),
    RemainSkillPoint2 = RemainSkillPoint + Level2 - Level,
    %% *级以下，根据玩家手中的武器自动加属性点
    [AutoAddAttrRoleLevel] = common_config_dyn:find(etc,auto_add_attr_role_level),
    RoleAttr2 = RoleAttr#p_role_attr{remain_skill_points=RemainSkillPoint2, level=Level2, exp=Exp},
    case Level2 < AutoAddAttrRoleLevel andalso Category > 0 of
        true ->
            if
                %% 刀：敏捷
                Category =:= 1 ->
                    RoleBase2 = RoleBase#p_role_base{remain_attr_points=0,
                                                     base_dex=(RoleBase#p_role_base.base_dex)+RemainAttrPoint2};
                %% 弓：力量
                Category =:= 2 ->
                    RoleBase2 = RoleBase#p_role_base{remain_attr_points=0,
                                                     base_str=(RoleBase#p_role_base.base_str)+RemainAttrPoint2};
                %% 杖：智力
                Category =:= 3 ->
                    RoleBase2 = RoleBase#p_role_base{remain_attr_points=0,
                                                     base_int=(RoleBase#p_role_base.base_int)+RemainAttrPoint2};
                %% 扇：精神
                true ->
                    RoleBase2 = RoleBase#p_role_base{remain_attr_points=0,
                                                     base_men=(RoleBase#p_role_base.base_men)+RemainAttrPoint2}
                    
            end;
        false ->
            RoleBase2 = RoleBase#p_role_base{remain_attr_points=RemainAttrPoint2}
    end,
    %% 重算属性
    case calc_attr(RoleAttr2, RoleBase2) of
        {ok, RoleAttr3, RoleBase3} ->
            set_role_attr(RoleID, RoleAttr3),
            set_role_base(RoleID, RoleBase3),
            {level_up, Level, RoleAttr3, RoleBase3};
        {error, Reason} ->
            common_transaction:abort(Reason)
    end.

add_level_title(OldLevel, NewLevel, RoleID) ->
    case OldLevel =:= 29  orelse OldLevel =:= 49 
        orelse OldLevel =:= 79 orelse OldLevel =:= 99 of
        true ->
            common_title:add_title(?TITLE_ROLE_LEVEL_RANK,RoleID,NewLevel);
        false ->
            nil
    end.

calc_attr(RoleAttr,RoleBase) ->
    {RoleBase3, RoleAttr2, EquipsList} = 
        case RoleAttr#p_role_attr.equips of
            undefined -> {RoleBase, RoleAttr#p_role_attr{equips=[]}, []};
            _ -> check_equips_valid(RoleBase, RoleAttr)
        end,
    RoleAttr3 = RoleAttr2#p_role_attr{equips=EquipsList},
    %% 重算一级属性
    case mod_role_attr:calc_first_level_attr(RoleAttr3, RoleBase3) of
        {ok, FirstLevelAttr} -> 
            #role_first_level_attr{str=STR, int=INT, con=CON, dex=DEX, men=MEN} = FirstLevelAttr,
            Level = RoleAttr3#p_role_attr.level,
            case mod_role_attr:calc_second_level_attr(RoleAttr3, RoleBase3, FirstLevelAttr) of
                {error, system_error} ->
                    {error, ?_LANG_SYSTEM_ERROR};
                {ok, RoleSecondLevelAttr} ->
                    #role_second_level_attr{
                  max_hp=MaxHP, 
                  max_mp=MaxMP,
                  max_phy_attack=MaxPhyAttack,
                  min_phy_attack=MinPhyAttack,
                  max_magic_attack=MaxMagicAttack,
                  min_magic_attack=MinMagicAttack,
                  phy_defence=PhyDefence,
                  magic_defence=MagicDefence,
                  hp_recover_speed=HPRecoverSpeed,
                  mp_recover_speed=MPRecoverSpeed,
                  luck=Luck,
                  move_speed=MoveSpeed,
                  attack_speed=AttackSpeed,
                  miss=Miss,
                  no_defence=NoDefence,
                  double_attack=DoubleAttack,
                  phy_hurt_rate=PhyHurt,
                  magic_hurt_rate=MagicHurt,
                  dizzy=Dizzy,
                  poisoning=Poisoning,
                  freeze=Freeze,
                  poisoning_resist=PoisoningResist,
                  dizzy_resist=DizzyResist,
                  freeze_resist=FreezeResist,
                  hurt = Hurt,
                  phy_anti = PhyAnti,
                  magic_anti = MagicAnti,
                  hurt_rebound = HurtRebound
                 } = RoleSecondLevelAttr,
                    NewRoleBase = RoleBase3#p_role_base{max_hp=MaxHP, max_mp=MaxMP, str=STR, int2=INT,
                                                       con=CON, dex=DEX, men=MEN, max_phy_attack=MaxPhyAttack,
                                                       min_phy_attack=MinPhyAttack, max_magic_attack=MaxMagicAttack,
                                                       min_magic_attack=MinMagicAttack, phy_defence=PhyDefence,
                                                       magic_defence=MagicDefence, hp_recover_speed=HPRecoverSpeed,
                                                       mp_recover_speed=MPRecoverSpeed, luck=Luck, move_speed=MoveSpeed,
                                                       attack_speed=AttackSpeed, miss=Miss, no_defence=NoDefence,
                                                       double_attack=DoubleAttack, phy_hurt_rate=PhyHurt+Hurt,
                                                       magic_hurt_rate=MagicHurt+Hurt, dizzy=Dizzy, poisoning=Poisoning,
                                                       freeze=Freeze, poisoning_resist=PoisoningResist,
                                                       dizzy_resist=DizzyResist, freeze_resist=FreezeResist,
                                                       phy_anti = PhyAnti,magic_anti = MagicAnti,
                                                       hurt_rebound = HurtRebound, equip_score=get_new_equip_score(RoleAttr3#p_role_attr.equips)
                                                      },
                    NewRoleAttr = RoleAttr3#p_role_attr{next_level_exp=mod_exp:get_cur_level_exp(Level)},
                    do_update_map_role_info(NewRoleBase, NewRoleAttr, mgeem_map:get_state()),
                    {ok, NewRoleAttr, NewRoleBase}
            end;
        {error, system_error} ->
            {error, ?_LANG_SYSTEM_ERROR}
    end.

%%10级以下玩家免费复活
get_relive_silver(_FactionID, Level, _Equips, _MapState) when Level =< 10 ->
    0;
get_relive_silver(FactionID, Level, Equips, MapState) ->
    MapId = MapState#map_state.mapid,
    case Equips =:= undefined of
        true ->
            Equips2 = [];
        _ ->
            Equips2 = Equips
    end,
    
    AllIndex =
        lists:foldl(
          fun(Equip, I) ->
                  RefinIndex = Equip#p_goods.refining_index,
                  I + common_tool:ceil(RefinIndex/100)
          end, 10, Equips2),
    SilverNeed = if MapId =:= 10500 ->
                        ReliveSilver = common_tool:ceil(AllIndex*Level/10),
                        if ReliveSilver < 20 ->
                               20;
                           true ->
                               ReliveSilver
                        end;
                    true ->
                        common_tool:ceil(AllIndex*Level/2)
                 end,
    case is_in_waroffaction_dirty(FactionID, MapId) of
        true ->
            trunc(SilverNeed/5);
        false ->
            SilverNeed
    end.
    

do_client_exit(RoleID, _PID, MapState) ->
    %% 角色下线HOOK
    hook_map_role:role_offline(RoleID),
    %% 角色退出游戏标记
    set_role_exit_game_mark(RoleID),
    %% 退出地图
    mod_map_actor:do_quit(RoleID, role, MapState).

do_attr_change(RoleID) ->
    case common_transaction:transaction(
           fun() ->
                   {ok, RoleAttr} = get_role_attr(RoleID),
                   {ok, RoleBase} = get_role_base(RoleID),

                   case calc_attr(RoleAttr, RoleBase) of
                       {ok, RoleAttr2, RoleBase2} ->
                           set_role_attr(RoleID, RoleAttr2),
                           set_role_base(RoleID, RoleBase2),
                           {ok, RoleAttr2, RoleBase2};
                       {error, Reason} ->
                           throw(Reason)
                   end
           end)
    of
        {atomic, {ok, NewRoleAttr, NewRoleBase}} ->
            %%calc_attr中已经更新
            %%do_update_map_role_info(RoleBase,RoleAttr, mgeem_map:get_state()),
            Record = #m_role2_reload_toc{role_base=NewRoleBase, role_attr=NewRoleAttr},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_RELOAD, Record);
        {aborted, Reason} when is_binary(Reason) ->
            ok;
        {aborted, Reason} ->
            ?ERROR_MSG("do_attr_change, error: ~w", [Reason])
    end.

set_role_state(RoleID, RoleState) ->
    put({role_state, RoleID}, RoleState).

get_role_state(RoleID) ->
    case get({role_state, RoleID}) of
        undefined ->
            {error, system_error};
        RoleState ->
            {ok, RoleState}
    end.

clear_role_state(RoleID) ->
    erase({role_state, RoleID}).

update_role_id_list_in_transaction(RoleId, Key, KeyBk) ->
    case erlang:get(?role_id_list_in_transaction) of
        undefined ->
            erlang:throw({error, not_in_transaction});
        BkList ->
            case lists:member({RoleId, Key, KeyBk}, BkList) of
                true ->
                    ignore;
                _ ->
                    erlang:put(?role_id_list_in_transaction, [{RoleId, Key, KeyBk}|BkList]),
                    case erlang:get({Key, RoleId}) of
                        undefined ->
                            ignore;
                        Value ->
                            erlang:put({KeyBk, RoleId}, Value)
                    end
            end
    end.

%% @doc 更新角色战斗时间，用于战斗状态判定
%% @spec 只有与玩家战斗的时候才会更新此状态
update_role_fight_time(RoleID, ActorType, ActorID, SkillEffectType) ->
    Auth = (ActorType=:=role andalso ActorID=/=RoleID andalso SkillEffectType=/=?SKILL_EFFECT_TYPE_FRIEND andalso
            SkillEffectType=/=?SKILL_EFFECT_TYPE_FRIEND_ROLE),

    case Auth of
        true ->
            put({role_fight_time, RoleID}, common_tool:now());
        _ ->
            ignore
    end.

%% @doc 是否处于战斗状态
is_role_fighting(RoleID) ->
    case get({role_fight_time, RoleID}) of
        undefined ->
            false;
        FightTime ->
            not (common_tool:now() - FightTime >= ?CLEAR_FIGHT_STATE_DIFF)
    end.

%%@doc 更新最后一次登录时间
update_online_time(RoleID)->
    [RoleExt] = db:dirty_read(?DB_ROLE_EXT, RoleID),
    RoleExt2 = RoleExt#p_role_ext{last_login_time=common_tool:now()},
    db:dirty_write(?DB_ROLE_EXT, RoleExt2).

%% @doc 纪录角色下线时间及IP
update_offline_time_and_ip(RoleID, ClientIP) ->
    {ok, RoleAttr} = get_role_attr(RoleID),
    RoleAttr2 = RoleAttr#p_role_attr{last_login_ip=common_tool:ip_to_str(ClientIP)},
    common_transaction:transaction(fun() -> mod_map_role:set_role_attr(RoleID, RoleAttr2) end),
    
    [RoleExt] = db:dirty_read(?DB_ROLE_EXT, RoleID),
    RoleExt2 = RoleExt#p_role_ext{last_offline_time=common_tool:now()},
    db:dirty_write(?DB_ROLE_EXT, RoleExt2).

%%同步角色某些属性更新到map
update_role_attr({family_contribute,Value},RoleID) ->
    ?DEBUG("角色:~w",[Value]),
    {ok, RoleAttr} = get_role_attr(RoleID),
    RoleAttr2 = RoleAttr#p_role_attr{family_contribute=Value},
    common_transaction:transaction(fun() -> mod_map_role:set_role_attr(RoleID, RoleAttr2) end).
    
%% @doc 进入地图广播，外国人进入本国地图，及满足一定条件
map_enter_broadcast(RoleID, MapID) ->
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    #p_role_base{role_name=RoleName, faction_id=FactionID} = RoleBase,
    
    %% 中立区、副本或本国不用广播
    case get_map_faction_id(MapID) of
        {ok, copy_or_neutral} ->
            ignore;
        {ok, FactionID} ->
            ignore;
        {ok, MFID} ->
            {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
            #p_role_attr{gongxun=GongXun} = RoleAttr,
            
            %% 战功低于50不用广播
            case GongXun >= 50 of
                true ->
                    map_enter_broadcast2(RoleID, RoleName, FactionID, MapID, MFID, GongXun);
                _ ->
                    ignore
            end
    end.

map_enter_broadcast2(RoleID, RoleName, FactionID, MapID, MFID, GongXun) ->
    FactionName = common_misc:get_faction_name(FactionID),
    MapName = common_map:get_map_str_name(MapID),
    
    if
        GongXun < 100 ->
            Msg = io_lib:format("~s危险人物[~s]在~s出没，广大国民请做好防范工作", [FactionName, RoleName, MapName]);
        GongXun < 200 ->
            Msg = io_lib:format("~s丧心病狂[~s]在~s出没，广大国民请做好防范工作", [FactionName, RoleName, MapName]);
        true ->
            Msg = io_lib:format("~s杀人狂魔[~s]在~s出没，广大国民请做好防范工作", [FactionName, RoleName, MapName])
    end,
    Msg2 = lists:flatten(Msg),

    TimerRef = erlang:send_after(10000, self(), {mod_map_role, {map_enter_broadcast, RoleID, MFID, Msg2}}),
    put({map_enter_broadcast_timer, RoleID}, TimerRef).

do_map_enter_broadcast(RoleID, MFID, Msg) ->
    common_broadcast:bc_send_msg_faction(MFID, ?BC_MSG_TYPE_CENTER, ?BC_MSG_SUB_TYPE, Msg),
    common_broadcast:bc_send_msg_role(RoleID, ?BC_MSG_TYPE_CENTER, Msg).

%% @doc 根据地图ID获取国家ID
get_map_faction_id(MapID) ->
    case MapID rem 10000 div 1000 of
        0 ->
            {ok, copy_or_neutral};
        FID ->
            {ok, FID}
    end.

%% @doc 清除角色身上特殊BUFF            
clear_role_spec_buff(RoleID) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            ok;
        MapRoleInfo ->
            #p_map_role{role_id=RoleID, state_buffs=Buffs} = MapRoleInfo,
            RemoveList =
                lists:foldl(
                  fun(ActorBuff, Acc) ->
                          BuffType = ActorBuff#p_actor_buf.buff_type,
                          %%隐身
                          case BuffType =:= 36 of
                              true ->
                                  [BuffType|Acc];
                              _ ->
                                  Acc
                          end
                  end, [], Buffs),
            mod_role_buff:remove_buff(RoleID, RoleID, role, RemoveList)
    end.

%% @doc 清除角色的特殊状态，如打坐
clear_role_spec_state(RoleID) ->
    RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID, role),
    case RoleMapInfo of
        undefined ->
            ?ERROR_MSG("~ts:~w", ["清理角色状态信息失败了,找不到玩家地图信息", RoleID]);
        RoleMapInfo ->
            #p_map_role{role_id=RoleID, state=State} = RoleMapInfo,

            case State of
                ?ROLE_STATE_ZAZEN ->
                    clear_role_spec_state2(RoleID, RoleMapInfo);
                _ ->
                    ok
            end
    end. 
clear_role_spec_state2(RoleID, MapInfo) ->
    case common_transaction:transaction(
           fun() ->
                   {ok, RoleBase} = get_role_base(RoleID),
                   RoleBase2 = RoleBase#p_role_base{status=?ROLE_STATE_NORMAL},
                   set_role_base(RoleID, RoleBase2)
           end)
    of
        {atomic, _} ->
            NewMapInfo = MapInfo#p_map_role{state = ?ROLE_STATE_NORMAL},
            mod_map_actor:set_actor_mapinfo(RoleID, role, NewMapInfo),
            {ok,SumExp} = mod_role_on_zazen:del_map_role_on_zazen(RoleID),
            DataRecord = #m_role2_zazen_toc{status=false,sum_exp=SumExp},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ZAZEN, DataRecord),
            ToOther = #m_role2_zazen_toc{roleid=RoleID, return_self=false, status=false},
            mgeem_map:do_broadcast_insence([{role, RoleID}], ?ROLE2, ?ROLE2_ZAZEN, ToOther, mgeem_map:get_state()),
            %% 清掉打坐BUFF
            remove_zazen_buff(RoleID);
        {aborted, R} ->
            ?DEBUG("clear_role_spec_state2, r: ~w", [R]),
            ok
    end.

%% @doc 清除打坐buff
remove_zazen_buff(RoleID) ->
    mod_role_buff:remove_buff(RoleID, RoleID, role, 1002).

%% @doc 角色attr、base定时持久化
role_base_attr_persistent() ->
    Now = common_tool:now(),
    case get(role_base_attr_last_persistent_time) of
        undefined ->
            role_base_attr_persistent2(Now);
        Time ->
            case Now - Time >= ?ROLE_BASE_ATTR_PERSISTENT_INTERVAL of
                true ->
                    role_base_attr_persistent2(Now);
                _ ->
                    ignore
            end
    end.

role_base_attr_persistent2(Now) ->
    lists:foreach(
      fun(RoleID) ->
              case get_role_attr(RoleID) of
                  {ok, RoleAttr} ->
                      case get_role_base(RoleID) of
                          {ok, RoleBase} ->
                              {ok, RoleFight} = get_role_fight(RoleID),
                              mgeem_persistent:role_fight_persistent(RoleFight),
                              mod_bag:role_bag_info_persistent(RoleID),
                              mgeem_persistent:role_base_attr_persistent(RoleBase, RoleAttr),
                              case get_role_conlogin(RoleID) of
                                  {ok, RoleConlogin} ->
                                      mgeem_persistent:role_conlogin_persistent(RoleConlogin);
                                  _ ->
                                      ignore
                              end,
                              case get_role_accumulate_exp(RoleID) of
                                  {ok, RoleAccumulateExp} ->
                                      mgeem_persistent:role_accumulate_exp_persistent(RoleAccumulateExp);
                                  _ ->
                                      ignore
                              end,
                              catch mod_mission_data:persistent(RoleID),
                              %% 持久化角色VIP信息
                              case mod_vip:get_role_vip_info(RoleID) of
                                  {ok, VipInfo} ->
                                      %% 检测VIP是否过期
                                      mod_vip:check_vip_valid(VipInfo, Now),
                                      mgeem_persistent:role_vip_persistent(VipInfo);
                                  _ ->
                                      ignore
                              end,
                              %% 持久化角色英雄副本信息
                              case mod_hero_fb:get_role_hero_fb_info(RoleID) of
                                  {ok, HeroFBInfo} ->
                                      mgeem_persistent:role_hero_fb_persistent(HeroFBInfo);
                                  _ ->
                                      ignore
                              end,
                              case mod_map_drop:get_role_monster_drop(RoleID) of
                                  {ok, DropInfo} ->
                                      mgeem_persistent:role_monster_drop_persistent(DropInfo);
                                  _ ->
                                      ignore
                              end,
                              %% 持久化角色Refining Box信息
                              case mod_refining_box:get_role_refining_box_info(RoleID) of
                                  {ok, RefiningBoxInfo} ->
                                      mgeem_persistent:role_refining_box_persistent(RefiningBoxInfo);
                                  _ ->
                                      ignore
                              end,
                              %% 持久化
                              case get_role_goal(RoleID) of
                                  {ok, RoleGoalInfo} ->
                                      mgeem_persistent:role_goal_persistent(RoleGoalInfo);
                                  _ ->
                                      ignore
                              end,
                              %% 持久化
                              case mod_achievement:get_role_achievement_info(RoleID) of
                                  {ok, AchievementInfo} ->
                                      mgeem_persistent:role_achievement_persistent(AchievementInfo);
                                  _ ->
                                      ignore
                              end,
                              %% 持久化玩家技能
                              case mod_skill:get_role_skill_list(RoleID) of
                                  [] ->
                                      ignore;
                                  SkillList ->
                                      mgeem_persistent:role_skill_list_persistent(RoleID, SkillList)
                              end,
                              %% 玩家地图扩展信息定时持久化
                              case get_role_map_ext_info(RoleID) of
                                 {ok,RoleMapExtInfo}->
                                      mgeem_persistent:role_map_ext_info_persistent(RoleMapExtInfo);
                                 _->
                                      ignore
                              end,
                              ok;
                          _ ->
                              ?ERROR_MSG("~ts: ~w", ["地图在线列表中，存在不在线的角色ID：", RoleID])
                      end;
                  _ ->
                      ?ERROR_MSG("~ts: ~w", ["地图在线列表中，存在不在线的角色ID：", RoleID])
              end
      end, mgeem_map:get_all_roleid()),
    put(role_base_attr_last_persistent_time, Now).

%% @doc 师徒值兑换PK点
do_moral_value_to_pkpoint(MoralPID, RoleID, MoralValue, Msg) ->
    case common_transaction:transaction(
           fun() ->
                   {ok, RoleBase} = get_role_base(RoleID),
                   #p_role_base{pk_points=PKPoints} = RoleBase,

                   ReducePoint = MoralValue div 10,
                   case PKPoints - ReducePoint < 0 of
                       true ->
                           PKPoints2 = 0;
                       _ ->
                           PKPoints2 = PKPoints - ReducePoint
                   end,

                   RoleBase2 = RoleBase#p_role_base{pk_points=PKPoints2},
                   set_role_base(RoleID, RoleBase2),

                   {ok, MoralValue-(PKPoints-PKPoints2)*10, PKPoints-PKPoints2, PKPoints2}
           end)
    of
        {atomic, {ok, ReturnPoint, ReducePoint, PKPoint2}} -> 
            do_update_map_role_info(RoleID, [{#p_map_role.pk_point, PKPoint2}], mgeem_map:get_state()),
            MoralPID ! {moral_value_to_pkpoint_succ, RoleID, ReturnPoint, ReducePoint, Msg},
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("do_moral_value_to_pkpoint, error: ~w", [Error]),
            MoralPID ! {moral_value_to_pkpoint_fail, RoleID, MoralValue, Msg}
    end.
    

%% @doc 判断装备是否生效
check_equips_valid(RoleBase, RoleAttr) ->
    %% 官职装备只有在国内以及国战期间才有效果
    #p_role_base{faction_id=FactionID} = RoleBase,
    [OfficalEquip] = common_config_dyn:find(etc, offical_equip_typeid),
    IsOfficalEquipActive = is_offical_equip_active(FactionID),

    lists:foldl(
      fun(Equip, {RB, RA, EquipList}) ->
              %% 装备是否过期
              #p_goods{typeid=TypeID, loadposition=SlotNum} = Equip,
              case check_in_use_time(Equip) of
                  true ->
                      case lists:member(TypeID, OfficalEquip) andalso (not IsOfficalEquipActive) of
                          true ->
                              {RB, RA, [Equip#p_goods{state=?GOODS_STATE_EQUIP_INVALID}|EquipList]};
                          _ ->
                              case SlotNum =:= ?UI_LOAD_POSITION_MOUNT of
                                  true ->
                                      {RB, RA, [Equip|EquipList]};
                                  _ ->
                                      {RB, RA, [Equip#p_goods{state=?GOODS_STATE_NORMAL}|EquipList]}
                              end
                      end;
                  _ ->
                      {ok, RA2, _} = mod_equip:get_role_skin_change_info(RA, SlotNum, 0, 0),
                      RB2 = mod_equip:cut_weapon_type(SlotNum, RB),
                      {RB2, RA2, [Equip#p_goods{state=?GOODS_STATE_EQUIP_INVALID}|EquipList]}
              end
      end, {RoleBase, RoleAttr, []}, RoleAttr#p_role_attr.equips).

check_in_use_time(ItemInfo) ->
    #p_goods{start_time = StartTime,
             end_time = EndTime} = ItemInfo,
    Now = common_tool:now(),        
    if StartTime =:= 0  orelse
       StartTime =< Now ->
           if EndTime =:= 0  orelse
                EndTime >= Now ->
                    true;
                true ->
                    false
    end;
       true ->
            false
    end.

-define(equip_not_include_slot, [5, 7, 8, 14]).

%% @doc 获取装备积分
get_new_equip_score(EquipList) ->
    lists:foldl(
      fun(EquipInfo, Acc) ->
              #p_goods{loadposition=SlotNum, current_colour=Color} = EquipInfo,
              case lists:member(SlotNum, ?equip_not_include_slot) 
                  andalso EquipInfo#p_goods.type =:= ?TYPE_EQUIP of
                  true ->
                      Acc;
                  _ ->
                      Acc+Color+get_fight_refining_index(EquipInfo)
              end
      end, 0, EquipList).
%% add by caochuncheng 由于精炼系数公式修改，在战斗计算中必须使用旧的方式计算
%% 新的 精炼系数 公式 = （颜色值 - 1） + （品质值 -1） + 强化等级 + 绑定等级（最高级） +　镶嵌石头个数 +　镶嵌石头（最高级）
get_fight_refining_index(EquipGoods) ->
    Color = 
        case erlang:is_integer(EquipGoods#p_goods.current_colour) of
            true ->
                EquipGoods#p_goods.current_colour;
            _ ->
                0
        end,
    Quality = 
        case erlang:is_integer(EquipGoods#p_goods.quality) of
            true ->
                EquipGoods#p_goods.quality;
            _ ->
                0
        end,
    StoneNum = 
        case erlang:is_integer(EquipGoods#p_goods.stone_num) of
            true ->
                EquipGoods#p_goods.stone_num;
            _ ->
                0
        end,
    ReinforceLevel = 
        case erlang:is_integer(EquipGoods#p_goods.reinforce_result) =:= true
                 andalso EquipGoods#p_goods.reinforce_result > 0 of
            true ->
                erlang:trunc(EquipGoods#p_goods.reinforce_result / 10);
            _ ->
                0
        end,
    MaxBindLevel = 
        case EquipGoods#p_goods.equip_bind_attr of
            undefined -> 0;
            [] -> 0;
            _ ->
                lists:foldl(
                  fun(EquipBindAttrRecord,AccBindLevel) ->
                          case  EquipBindAttrRecord#p_equip_bind_attr.attr_level > AccBindLevel of
                              true ->
                                  EquipBindAttrRecord#p_equip_bind_attr.attr_level;
                              _ ->
                                  AccBindLevel
                          end
                  end,0,EquipGoods#p_goods.equip_bind_attr)
        end,
    %% 镶嵌石头（最高级）
    MaxStoneLevel = 
        case EquipGoods#p_goods.stones of
            undefined -> 0;
            [] -> 0;
            _ ->
                lists:foldl(
                  fun(StoneGoods,AccStoneLevel) ->
                          case StoneGoods#p_goods.level > AccStoneLevel of
                              true ->
                                  StoneGoods#p_goods.level;
                              _ ->
                                  AccStoneLevel
                          end
                  end, 0, EquipGoods#p_goods.stones)
        end,
    RefiningIndex = (Color - 1) +  (Quality - 1) + ReinforceLevel + MaxBindLevel + StoneNum + MaxStoneLevel,
    case RefiningIndex < 0 of
        true ->
            0;
        _ ->
            RefiningIndex
    end.

%% @doc 官职装备是否生效，国内或外国参与国战
is_offical_equip_active(FactionID) ->
    MapID = mgeem_map:get_mapid(),
    common_misc:if_in_self_country(FactionID, MapID) orelse is_in_copy_map(MapID) orelse is_in_waroffaction(FactionID).

is_in_copy_map(MapID) ->
    case MapID rem 10000 div 1000 of
        0 ->
            MapID div 100 =/= 102;
        _ ->
            false
    end.

%% @doc 设置角色退出游戏标记
set_role_exit_game_mark(RoleID) ->
    put({exit_game, RoleID}, true).

%% @doc 角色是否退出游戏，！！！获取后标记将被清除，暂时仅用于个人副本
is_role_exit_game(RoleID) ->
    case erlang:get({exit_game, RoleID}) of
        undefined ->
            false;
        _ ->
            erlang:erase({exit_game, RoleID}),
            true
    end.

%% @doc 获取杀手姓名
get_killer_name(ActorID, ActorType, ActorName) ->
    case ActorType of
        pet ->
            case mod_map_actor:get_actor_mapinfo(ActorID, pet) of
                undefined ->
                    ActorName;
                #p_map_pet{role_id=MasterID} ->
                    case mod_map_role:get_role_base(MasterID) of
                        {ok, MasterBase} ->
                            MasterBase#p_role_base.role_name;
                        _ ->
                            ActorName
                    end
            end;
        _ ->
            ActorName
    end.

%% @doc 重置精力值
do_reset_role_energy(RoleID, Now) ->
    {ok, RoleFight} = get_role_fight(RoleID),
    #p_role_fight{energy=Energy, energy_remain=EnergyRemain} = RoleFight,
    
    case EnergyRemain + Energy >= ?MAX_REMAIN_ENERGY of
        true ->
            EnergyRemain2 = ?MAX_REMAIN_ENERGY;
        _ ->
            EnergyRemain2 = Energy + EnergyRemain
    end,
    
    RoleFight2 = RoleFight#p_role_fight{energy=?DEFAULT_ENERGY, energy_remain=EnergyRemain2, time_reset_energy=Now},
    set_role_fight(RoleID, RoleFight2),
    
    ChangeAttList = [#p_role_attr_change{change_type=?ROLE_ENERGY_CHANGE, new_value=?DEFAULT_ENERGY},
                     #p_role_attr_change{change_type=?ROLE_ENERGY_REMAIN_CHANGE, new_value=EnergyRemain2}],
    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttList).

do_reset_role_energy(RoleID) ->
    {ok, RoleFight} = get_role_fight(RoleID),
    set_role_fight(RoleID, RoleFight#p_role_fight{energy=?DEFAULT_ENERGY}),
    ChangeAttList = [#p_role_attr_change{change_type=?ROLE_ENERGY_CHANGE, new_value=?DEFAULT_ENERGY}],
    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttList).

%% @doc 技能返回经验
do_skill_return_exp(RoleID) ->
    SkillList = mod_skill:get_role_skill_list(RoleID),
    ExpReturn =
        lists:foldl(
          fun(#r_role_skill_info{skill_id=SkillID, cur_level=SkillLevel, category=Cate}, Acc) when Cate =< 4 ->
                  [LevelInfoList] = common_config_dyn:find(skill_level_tmp, SkillID),
                  Acc + lists:foldl(fun(#p_skill_level{level=L, consume_exp=ExpNeed}, Acc2) ->
                                            case L =< SkillLevel of
                                                true ->
                                                    Acc2 + ExpNeed;
                                                _ ->
                                                    Acc2
                                            end
                                    end, 0, LevelInfoList);
             (_, Acc) ->
                  Acc
          end, 0, SkillList),
    Percent = [1, 0.8, 0.7, 0.5],
    {_, _, ExpReturn2} =
        lists:foldl(
          fun(E, {Count, Remain, Return}) ->
                  Remain2 = Remain - E,
                  case Remain2 > 0 andalso E =/= 10000001 of
                      true ->
                          {Count+1, Remain2, common_tool:ceil(Return+E*lists:nth(Count, Percent))};
                      _ ->
                          {Count+1, 0, common_tool:ceil(Return+Remain*lists:nth(Count, Percent))}
                  end
          end, {1, ExpReturn, 0}, [1000000, 4000000, 5000000, 10000001]),
    case ExpReturn2 > 0 of
        true ->
            {ok, #p_role_attr{role_name=RoleName, cur_energy=CurEnergy, level=RoleLevel}=RoleAttr} = mod_map_role:get_role_attr(RoleID),
            case CurEnergy =:= 1 of
                true ->
                    ignore;
                _ ->
                    RoleAttr2 = RoleAttr#p_role_attr{cur_energy=1},
                    {atomic, _} = common_transaction:t(fun() -> mod_map_role:set_role_attr(RoleID, RoleAttr2) end),
                    do_add_exp(RoleID, ExpReturn2),
                    case RoleLevel > 20 of
                        true ->
                            Text = common_letter:create_temp(?SKILL_RETURN_EXP_LETTER, [RoleName, ExpReturn]),
                            common_letter:sys2p(RoleID, Text, "技能经验返还", 14);
                        _ ->
                            ignore
                    end
            end;
        _ ->
            ignore
    end.

%% @doc 玩家进程字典数据相关处理       
%% @doc 初始化玩家地图进程字典信息，进入地图调用
init_role_map_ext_info(RoleId, ExpInfo) ->
    case ExpInfo of
        undefined ->
            ignore;
        _ ->
            erlang:put({?role_map_ext, RoleId}, ExpInfo)
    end.
%% @doc 获取玩家地图进程字典扩展信息
get_role_map_ext_info(RoleId) ->
    case erlang:get({?role_map_ext, RoleId}) of
        undefined ->
            {error, not_found};
        ExtInfo ->
            {ok,ExtInfo}
    end.
%% @doc 清楚玩家地图进程字典信息
erase_role_map_ext_info(RoleId) ->
    case get_role_map_ext_info(RoleId) of
        {ok, ExtInfo} ->
            mgeem_persistent:role_map_ext_info_persistent(ExtInfo),
            erlang:erase({?role_map_ext, RoleId});
        _ ->
            ignore
    end.

%% @doc 事务写地图进程字典玩家扩展信息
t_set_role_map_ext_info(RoleId, ExtInfo) ->
    update_role_id_list_in_transaction(RoleId, ?role_map_ext, ?role_map_ext_copy),
    erlang:put({?role_map_ext, RoleId}, ExtInfo).

%% @doc 
set_role_map_ext_info(RoleId, ExpInfo) ->
    case common_transaction:transaction(
           fun() ->
                   t_set_role_map_ext_info(RoleId,ExpInfo)
           end)
    of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("set_role_map_ext_info, error: ~w", [Error]),
            error
    end.
