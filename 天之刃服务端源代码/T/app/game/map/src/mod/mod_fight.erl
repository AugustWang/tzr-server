%% Author: liuwei
%% Created: 2010-6-24
%% Description: TODO: Add description to mod_fight
-module(mod_fight).

-include("mgeem.hrl").

-export([
         handle/2, 
         get_dest_type/1,
         get_actors_around_map_grid/3,
         get_target_actor_in_area2/1,
         judge_pk_mode/8,
         judge_pk_mode_enemy3/3,
         get_effect_actor/9,
         detail_to_actorbuff/5,
         int_type_to_atom_type/1
        ]).

-export([
         set_last_skill_time/3,
         get_last_skill_time/2,
         erase_last_skill_time/2,
         erase_last_attack_time/2]).

-define(last_attack_time, last_attack_time).
-define(last_skill_time, last_skill_time).

%%
%% API Functions
%%
handle({Unique, ?FIGHT, ?FIGHT_ATTACK, DataIn, RoleID, PID, _Line}, MapState) when is_integer(Unique)->
    %%一旦战斗就代表玩家停止下来了，所以就需要清楚玩家的最后移动路径了
    mod_map_actor:erase_actor_pid_lastwalkpath(RoleID,role),
    mod_map_actor:erase_actor_pid_lastkeypath(RoleID,role),
    
    do_role_attack(Unique,?FIGHT,?FIGHT_ATTACK,DataIn,RoleID,PID,MapState);

handle({monster_attack, ?FIGHT, ?FIGHT_ATTACK, DataIn, MonsterID}, MapState) ->
    do_monster_attack(DataIn, MonsterID, MapState);

handle({server_npc_attack, ?FIGHT, ?FIGHT_ATTACK, DataIn, ServerNpcID}, MapState) ->
    do_server_npc_attack(DataIn, ServerNpcID, MapState);

handle(Info,_State) ->
    ?ERROR_MSG("~w, unrecognize msg: ~w", [?MODULE,Info]).


%%
%%First Level Local Functions
%%
do_role_attack(Unique,Module,Method,DataIn,RoleID,PID,MapState)->
    #m_fight_attack_tos{target_id=TargetID, target_type=TargetType, skillid=SkillID} = DataIn,
    case hook_fight:check_fight_condition(RoleID,TargetID,TargetType,SkillID) of
        true ->
            do_role_attack2(DataIn, RoleID, Unique, MapState);
        {error, Reason} ->
            SendSelf = #m_fight_attack_toc{succ=false, reason=Reason},
            common_misc:unicast2(PID,RoleID,Unique,Module,Method,SendSelf)
    end.

do_role_attack2(DataIn, RoleID, Unique, MapState) ->
   #m_fight_attack_tos{
                 tile=Tile, target_id=TargetID, dir=Dir, src_type=AType,
                 target_type=TargetType, skillid=SkillID} = DataIn,
    
     %%目标类型
    TargetTypeAtom = int_type_to_atom_type(TargetType),
    %%攻击者类型
    case AType of
        ?TYPE_PET ->
           do_pet_attack(TargetID, TargetType, TargetTypeAtom, Tile, Dir, SkillID, RoleID, Unique, MapState);
        _ ->
           do_role_attack3(TargetID, TargetType, TargetTypeAtom, Tile, Dir, SkillID, RoleID, Unique, MapState)
    end.
    
do_role_attack3(TargetID, TargetType, TargetTypeAtom, Tile, Dir, SkillID, RoleID, Unique, MapState) ->
    #p_map_tile{tx=TX, ty=TY} = Tile, 
    DestPos = #p_pos{tx=TX, ty=TY, dir=0},
    MapID = MapState#map_state.mapid,
    %%开始攻击
    Result = do_attack(RoleID, role, TargetID, TargetTypeAtom, SkillID, TX, TY, Dir, MapID),
    %%广播结果
    do_result(RoleID, role, Unique, SkillID, MapState, Result, Dir, DestPos, TargetID, TargetType).

%%宠物使用技能战斗
do_pet_attack(TargetID, TargetType, TargetTypeAtom, Tile, Dir, SkillID, RoleID, Unique, MapState) ->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            R = #m_fight_attack_toc{succ=false, reason=?_LANG_PET_NOT_SUMMONED, src_type=?TYPE_PET},
            common_misc:unicast({role, RoleID}, Unique, ?FIGHT, ?FIGHT_ATTACK, R);
        PetID ->
            #p_map_tile{tx=TX, ty=TY} = Tile, 
            DestPos = #p_pos{tx=TX, ty=TY, dir=0},
            
            MapID = MapState#map_state.mapid,
            
            %%开始攻击
            Result = do_attack(PetID, pet, TargetID, TargetTypeAtom, SkillID, TX, TY, Dir, MapID),
            
            ?DEBUG("do_role_attack, result: ~w", [Result]),
            
            %%广播结果
            do_result({PetID,RoleID}, pet, Unique, SkillID, MapState, Result, Dir, DestPos, TargetID, TargetType)
    end.

     
    
do_monster_attack({TargetID, Skill, role}, MonsterID, MapState) ->
    case mod_map_actor:get_actor_txty_by_id(MonsterID,monster) of
        {MX,MY} ->
            case mod_map_actor:get_actor_txty_by_id(TargetID, role) of
                {TX,TY} ->
                    MapID = MapState#map_state.mapid,
                    Dir = get_fight_dir(MX,MY,TX,TY),
                    Result = do_attack(MonsterID, monster, TargetID, role, Skill, TX, TY, Dir, MapID),
                    {SkillID,_} = Skill,
                    DestPos = #p_pos{tx = TX,ty = TY,dir = Dir},
                    do_result(MonsterID, monster, ?DEFAULT_UNIQUE, 
                              SkillID, MapState, Result, Dir,DestPos, TargetID, ?TYPE_ROLE);
                _ ->
                    mod_map_monster:delete_role_from_monster_enemy_list(MonsterID,TargetID,role)
            end;
        _ ->
            ?INFO_MSG("unexcept error, can not find monster pos",[])
    end;
do_monster_attack({TargetID, Skill, pet}, MonsterID, MapState) ->
    case mod_map_actor:get_actor_txty_by_id(MonsterID,monster) of
        {MX,MY} ->
            
            case mod_map_actor:get_actor_mapinfo(TargetID, pet) of
                undefined ->
                    mod_map_monster:delete_role_from_monster_enemy_list(MonsterID,TargetID,pet);
                PetMapInfo ->
                    RoleID = PetMapInfo#p_map_pet.role_id,
                    case mod_map_pet:get_pet_pos_from_owner(RoleID) of
                        #p_pos{tx=TX,ty=TY} ->
                            MapID = MapState#map_state.mapid,
                            Dir = get_fight_dir(MX,MY,TX,TY),
                            Result = do_attack(MonsterID, monster, TargetID, pet, Skill, TX, TY, Dir, MapID),
                            {SkillID,_} = Skill,
                            DestPos = #p_pos{tx = TX,ty = TY,dir = Dir},
                            do_result(MonsterID, monster, ?DEFAULT_UNIQUE, 
                                      SkillID, MapState, Result, Dir,DestPos, TargetID, ?TYPE_PET);
                        _ ->
                            mod_map_monster:delete_role_from_monster_enemy_list(MonsterID,TargetID,pet)
                    end
            end;
        _ ->
            ?INFO_MSG("unexcept error, can not find monster pos",[])
    end.

do_server_npc_attack(DataIn, ServerNpcID, MapState) ->
    ?DEBUG("server_npc fight attack request ~p", [DataIn]),
    {TargetID, Skill, TargetType} = DataIn,
    case mod_map_actor:get_actor_txty_by_id(ServerNpcID,server_npc) of
        {MX,MY} ->
            case mod_map_actor:get_actor_txty_by_id(TargetID, TargetType) of
                {TX,TY} ->
                    MapID = MapState#map_state.mapid,
                    Dir = get_fight_dir(MX,MY,TX,TY),
                    Result = do_attack(ServerNpcID, server_npc, TargetID, TargetType, Skill, TX, TY, Dir, MapID),
                    {SkillID,_} = Skill,
                    DestPos = #p_pos{tx = TX,ty = TY,dir = Dir},
                    do_result(ServerNpcID, server_npc, ?DEFAULT_UNIQUE, 
                              SkillID, MapState, Result, Dir,DestPos, TargetID, get_dest_type(TargetType));
                _ ->
                    mod_server_npc:delete_role_from_server_npc_enemy_list(ServerNpcID,TargetID)
            end;
        _ ->
            ?INFO_MSG("unexcept error, can not find server_npc pos",[])
    end.

%%
%% Second Level Local Functions
%%
                                
%%如果SrcActorType是role, SkillInfo == SkillID，如果是monster或者npc, SkillInfo == {SkillID, Level}
do_attack(SActorID, SActorType, DActorID, DActorType, SkillInfo, TX, TY, Dir, MapID) ->
    SActorMapInfo = mod_map_actor:get_actor_mapinfo(SActorID, SActorType),
    case SActorType of
        role ->
            #p_map_role{state=SState, state_buffs=SActorBuff, pos=SPos} = SActorMapInfo,
            SIsDead = (SState=:=?ROLE_STATE_DEAD);
        monster ->
            #p_map_monster{state=SState, state_buffs=SActorBuff, pos=SPos} = SActorMapInfo,
            SIsDead = (SState=:=?DEAD_STATE);
        server_npc ->
            #p_map_server_npc{state=SState, state_buffs=SActorBuff, pos=SPos} = SActorMapInfo,
            SIsDead = (SState=:=?DEAD_STATE);
        pet ->
            #p_map_pet{state=SState, state_buffs=SActorBuff} = SActorMapInfo,
            SPos = mod_map_pet:get_pet_pos_from_owner(SActorMapInfo#p_map_pet.role_id),
            SIsDead = (SState=:=?DEAD_STATE)
    end,
    %% 强制下马
    if SActorType =:= role orelse SActorType =:= pet ->
            force_mountdown(SActorID,SActorType,SActorMapInfo); 
       true ->
            next
    end,
    if SActorBuff =:= undefined ->
            SActorBuff2 = [];
       true ->
            SActorBuff2 = SActorBuff
    end,
    %% 角色是否可以发起攻击，各种判断
    case catch check_actor_can_attack(SActorID, SActorType, SActorMapInfo, DActorID, DActorType, SkillInfo, TX, TY, SPos, SIsDead, SActorBuff2, MapID) of
        {ok, SActorAttr, SkillBaseInfo, SkillLevelInfo, TX2, TY2} ->
            do_attack2(SActorID, SActorType, SActorMapInfo, SActorAttr, SActorBuff2, SkillBaseInfo, SkillLevelInfo,
                       DActorID, DActorType, TX2, TY2, Dir, MapID);
        {Reason,ReasonCode} when erlang:is_binary(Reason) ->
            {error,Reason,ReasonCode};
        Reason when erlang:is_binary(Reason) ->
            {error, Reason};
        Reason ->
            ?ERROR_MSG("check_actor_can_attack error, reason: ~w", [Reason]),
            {error, ?_LANG_SYSTEM_ERROR}
    end.

check_actor_can_attack(SActorID, SActorType, SActorMapInfo, DActorID, DActorType, SkillInfo, TX, TY, SPos, SIsDead, SActorBuff, MapID) ->
    assert_actor_state(SIsDead),
    %% 角色buff判断
    assert_actor_buffs(SActorBuff, SActorType, SkillInfo),
    {ok, SkillBaseInfo} = mod_skill_manager:get_skill_info(SkillInfo),
    if SkillBaseInfo#p_skill.target_type =:= ?TARGET_TYPE_AREA_MAP ->
            DActorMapInfo = undefined;
       true ->
            DActorMapInfo = mod_map_actor:get_actor_mapinfo(DActorID, DActorType)
    end,
    if SkillBaseInfo#p_skill.target_type =/= ?TARGET_TYPE_AREA_MAP andalso
       DActorMapInfo =:= undefined ->
            erlang:throw({?_LANG_FIGHT_TARGET_NOT_EXIST,90002});
       true ->
            ok
    end,
    case DActorType of
        role ->
            #p_map_role{pos=DPos, state=DState} = DActorMapInfo,
            DIsDead = (DState =:= ?ROLE_STATE_DEAD);
        monster ->
            #p_map_monster{pos=DPos, state=DState} = DActorMapInfo,
            DIsDead = (DState =:= ?DEAD_STATE);
        server_npc ->
            #p_map_server_npc{pos=DPos, state=DState} = DActorMapInfo,
            DIsDead = (DState =:= ?DEAD_STATE);
        ybc ->
            #p_map_ybc{pos=DPos, hp=DHP} = DActorMapInfo,
            DIsDead = (DHP =:= 0);
        pet ->
            DIsDead = (DActorMapInfo#p_map_pet.hp =:= 0),
            DPos = mod_map_pet:get_pet_pos_from_owner(DActorMapInfo#p_map_pet.role_id);
        _ ->
            DIsDead = false,
            DPos = #p_pos{tx=TX, ty=TY}
    end,
    #p_pos{tx=TX2, ty=TY2} = DPos,
    %% 攻击距离判断
    assert_distance(SPos, TX2, TY2, SkillBaseInfo#p_skill.target_type, SkillBaseInfo#p_skill.distance),
    %% 目标状态判断
    assert_target_state(DActorType, DActorMapInfo, DIsDead, SkillBaseInfo#p_skill.id, SkillBaseInfo#p_skill.target_type),
    SActorAttr = get_dirty_actor_fight_attr(SActorType, SActorID),
    {ok, SkillLevel} = mod_skill_manager:get_dirty_actor_skill_level(SActorID, SActorType, SkillInfo), 
    {ok, SkillLevelInfo} = mod_skill_manager:get_skill_level_info(SkillInfo, SkillLevel),
    %% 国战判断
    assert_waroffaction(SActorType, SActorMapInfo, DActorType, DActorMapInfo),
    %% 特殊技能判断
    assert_spec_skill(SkillBaseInfo#p_skill.id, SPos, TX2, TY2),
    %% pk模式判断
    assert_pk_mode(SActorType, SActorID, SActorMapInfo, SActorAttr#actor_fight_attr.pk_mode, DActorType, DActorID, 
                   SkillBaseInfo#p_skill.target_type, SkillBaseInfo#p_skill.effect_type, MapID),
    %% 冷却时间小于2秒的技能，冷却时间会受攻击速度的影响
    #p_skill_level{cool_time=CoolTime} = SkillLevelInfo,
    AttackSpeed = SActorAttr#actor_fight_attr.attack_speed, 
    case CoolTime =< 2000 of
        true ->
            SkillLevelInfo2 = SkillLevelInfo#p_skill_level{cool_time=common_tool:ceil(CoolTime*1000/AttackSpeed)};
        _ ->
            SkillLevelInfo2 = SkillLevelInfo
    end,
    %% 攻击速度判断
    assert_attack_speed(SActorType, SActorID, SkillBaseInfo#p_skill.id, SkillLevelInfo2#p_skill_level.cool_time, AttackSpeed),
    {ok, SActorAttr, SkillBaseInfo, SkillLevelInfo2, TX2, TY2}.

force_mountdown(_PetID,pet,PetMapInfo) ->
    mod_equip_mount:force_mountdown(PetMapInfo#p_map_pet.role_id);
force_mountdown(RoleID,role,_)->
    mod_equip_mount:force_mountdown(RoleID).

assert_pk_mode(SActorType, SActorID, SActorMapInfo, PKMode, DActorType, DActorID, TargetType, EffectType, MapID) ->
    if TargetType =:= ?TARGET_TYPE_AREA_MAP orelse TargetType =:= ?TARGET_TYPE_SELF_AROUND
       orelse TargetType =:= ?TARGET_TYPE_SELF_FRONT  ->
            ok;
       true ->
            {DActorType2, DActorID2} =
                if TargetType =:= ?TARGET_TYPE_SELF ->
                        {SActorType, SActorID};
                   true ->
                        {DActorType, DActorID}
                end,
            assert_pk_mode2(SActorType, SActorID, SActorMapInfo, PKMode, DActorType2, DActorID2, EffectType, MapID)
    end.

assert_pk_mode2(SActorType, SActorID, SActorMapInfo, PKMode, DActorType, DActorID, EffectType, MapID) ->
    case judge_pk_mode(EffectType, SActorID, SActorType, PKMode, SActorMapInfo,
                       DActorType, DActorID, MapID)
    of
        {true, _} ->
            ok;
        {false, Reason} ->
            erlang:throw(Reason)
    end.

do_attack2(SActorID, SActorType, SActorMapInfo, SActorAttr, SActorBuff, SkillBaseInfo, SkillLevelInfo,
           DActorID, DActorType, TX, TY, Dir, MapID) ->
    %%已经可以使用技能了，减魔
    case deduct_skill_consumables(SkillLevelInfo, SActorMapInfo, SActorType) of
        ok ->
            case SActorType of
                role ->
                    %% 战斗hook
                    ?TRY_CATCH(hook_map_role:attack(SActorID, DActorType, DActorID, SkillBaseInfo), Err1);
                _ ->
                    ignore
            end,
            SkillID = SkillBaseInfo#p_skill.id,
            %%两个陷阱技能特殊处理
            case SkillID =:= ?SKILL_FIRE_TRAP orelse SkillID =:= ?SKILL_JINGJI_TRAP of
                true ->
                    do_attack3_1(SActorID, SActorType, SActorMapInfo, SActorAttr, TX, TY, SkillBaseInfo, SkillLevelInfo);
                _ ->
                    do_attack3_2(SActorID, SActorType, SActorMapInfo, SActorAttr, SActorBuff, SkillBaseInfo, SkillLevelInfo,
                                 DActorID, DActorType, TX, TY, Dir, MapID)
            end;

        {error, Reason} ->
            throw(Reason)
    end.

%%陷阱直接放在施放者角色的格子上
do_attack3_1(SActorID, role, SActorMapInfo, SActorAttr, TX, TY, SkillBaseInfo, SkillLevelInfo) ->
    #p_map_role{role_name=RoleName, faction_id=SFactionID, family_id=SFamilyID, team_id=STeamID} = SActorMapInfo,
    #p_skill{target_area=TargetArea} = SkillBaseInfo,
    #p_skill_level{skill_id=SkillID, effects=Effects, buffs=Buffs} = SkillLevelInfo,
    PKMode = SActorAttr#actor_fight_attr.pk_mode,
    [{TrapType, LastTime}] = common_config_dyn:find(etc, {trap_skill, SkillID}),

    MapTrap = #p_map_trap{
      trap_id=mod_map_trap:get_trap_id(),
      owner_id=SActorID,
      owner_name=RoleName,
      owner_type=?TYPE_ROLE,
      faction_id=SFactionID,
      family_id=SFamilyID,
      team_id=STeamID,
      pk_mode=PKMode,
      target_area=TargetArea,
      effects=get_effect_id_list(Effects),
      buffs=get_buff_id_list(Buffs),
      skill_id=SkillID,
      pos=#p_pos{tx=TX, ty=TY},
      remove_time=common_tool:now() + LastTime,
      trap_type=TrapType
     },
    
    mod_map_trap:set_trap_on_map(MapTrap),
    {ok, []};

do_attack3_1(_SActorID, _SActorType, _SActorMapInfo, _SActorAttr, _TX, _TY, _SkillBaseInfo, _SkillLevelInfo) ->
    {ok, []}.

do_attack3_2(SActorID, SActorType, SActorMapInfo, SActorAttr, SActorBuff, SkillBaseInfo, SkillLevelInfo,
             DActorID, DActorType, TX, TY, Dir, MapID) ->

    #p_skill{target_type=TargetType, target_area=TargetArea} = SkillBaseInfo,
    %%找出技能攻击范围内的所有角色
    EffectActorList = get_target_actor_in_area(SActorID, SActorType, DActorID, DActorType,
                                               TX, TY, Dir, TargetType, TargetArea),
    %%对每个攻击目标施加效果及BUFF
    ResultList =
        lists:foldr(
          fun({ActorType, ActorID}, Acc) ->
                  case mod_map_actor:get_actor_mapinfo(ActorID, ActorType) of
                      undefined ->
                          Acc;
                      ActorMapInfo ->
                          %%如果一个技能既带效果又有物理攻击的话那么物理攻击仅对选中的角色有效
                          Flag = (ActorID=:=DActorID andalso ActorType=:=DActorType 
                                  andalso SkillBaseInfo#p_skill.contain_common_attack),

                          %%对每个目标施加效果及BUFF，还有返回结果
                          Result = calc_skill_effect(SkillBaseInfo, SkillLevelInfo, Flag, SActorID, SActorType, SActorAttr, SActorBuff,
                                                     ActorID, ActorType, ActorMapInfo, SActorMapInfo, MapID),

                          case Result of
                              [] ->
                                  Acc;
                              _ ->
                                  [Result|Acc]
                          end
                  end
          end, [], EffectActorList),

    {ok, ResultList}.

%%计算技能对每个目标造成的效果
calc_skill_effect(SkillBaseInfo, SkillLevelInfo, Flag, SActorID, SActorType, SActorAttr, SActorBuff,
                  DActorID, DActorType, DActorMapInfo, SActorMapInfo, MapID) ->

    case DActorType of
        role ->
            ?TRY_CATCH(hook_map_role:be_attacked(DActorID, SActorID, SActorType, SkillBaseInfo), Err1),
            #p_map_role{state_buffs=DActorBuff, state=DState} = DActorMapInfo,
            DIsDead = (DState =:= ?ROLE_STATE_DEAD);
        monster ->
            #p_map_monster{state_buffs=DActorBuff, state=DState} = DActorMapInfo,
            DIsDead = (DState =:= ?DEAD_STATE);
        server_npc ->
            #p_map_server_npc{state_buffs=DActorBuff, state=DState} = DActorMapInfo,
            DIsDead = (DState =:= ?DEAD_STATE);
        ybc ->
            %% 镖车死亡状态判断
            #p_map_ybc{buffs=DActorBuff, hp=DHP} = DActorMapInfo,
            DIsDead = (DHP =:= 0);
        pet ->
            #p_map_pet{state_buffs=DActorBuff, hp=DHP} = DActorMapInfo,
            DIsDead = (DHP =:= 0)
    end,
    case DActorBuff =:= undefined of
        true ->
            DActorBuff2 = [];
        _ ->
            DActorBuff2 = DActorBuff
    end,
    SkillID = SkillLevelInfo#p_skill_level.skill_id,
    case catch check_target_can_attack(SActorType, SActorID, SActorAttr, SActorMapInfo, 
                                       DActorType, DActorID, DActorMapInfo, DIsDead, SkillBaseInfo, MapID) of
        ok ->
            calc_skill_effect2(SkillBaseInfo, SkillLevelInfo, Flag, SActorID, SActorType, SActorAttr, SActorBuff,
                               DActorID, DActorType, DActorBuff2, SkillID);
        _ ->
            []
    end.

check_target_can_attack(SActorType, SActorID, SActorAttr, SActorMapInfo, DActorType, DActorID, DActorMapInfo, DIsDead, SkillBaseInfo, MapID) ->
    assert_target_state(DActorType, DActorMapInfo, DIsDead, SkillBaseInfo#p_skill.id, SkillBaseInfo#p_skill.target_type),
    assert_waroffaction(SActorType, SActorMapInfo, DActorType, DActorMapInfo),
    assert_pk_mode2(SActorType, SActorID, SActorMapInfo, SActorAttr#actor_fight_attr.pk_mode, 
                    DActorType, DActorID, SkillBaseInfo#p_skill.effect_type, MapID),
    ok.

calc_skill_effect2(SkillBaseInfo, SkillLevelInfo, Flag, SrcActorID, SrcActorType, SrcActorAttr, SrcActorBuff,
                   DActorID, DActorType, DActorBuff, SkillID) ->

    %%获取被攻击者战斗属性，现在这种处理还不是很好。。。
    case get_dirty_actor_fight_attr(DActorType, DActorID) of
        {error, _} ->
            [];
        DActorAttr ->
            #p_skill_level{buffs=SkillBuffList, effects=SkillEffectList, category=Category, level=SkillLevel} = SkillLevelInfo,
            #p_skill{effect_type=EffectType} = SkillBaseInfo,

            %%是否闪避
            case judge_miss_attack(SrcActorAttr, DActorAttr, SkillEffectList, Flag) of
                true ->
                    #p_attack_result{dest_id=DActorID, dest_type=get_dest_type(DActorType), buffs=[], is_miss=true};

                false ->
                    calc_skill_effect3(SrcActorID, SrcActorType, SrcActorAttr, SrcActorBuff, SkillEffectList, SkillBuffList, Category,
                                       DActorID, DActorType, DActorAttr, DActorBuff, Flag, SkillLevel, EffectType, SkillID)
            end
    end.

calc_skill_effect3(SrcActorID, SrcActorType, SrcActorAttr, SrcActorBuff, SkillEffectList, SkillBuffList, Category,
                   DActorID, DActorType, DActorAttr, DActorBuff, Flag, SkillLevel, EffectType, SkillID) ->

    %%由施法者BUFF引发的BUFF
    SkillBuffList2 = buf_to_buf(SrcActorBuff, SkillBuffList, SkillLevel, SrcActorType, SrcActorID, DActorID),

    %%施法者身上的装备引发的BUFF
    %%目前装备引发的都是减益的BUFF，如果目标是自己或者是友方的话，BUFF无效
    case EffectType =:= ?SKILL_EFFECT_TYPE_SELF
        orelse EffectType =:= ?SKILL_EFFECT_TYPE_FRIEND
        orelse EffectType =:= ?SKILL_EFFECT_TYPE_FRIEND_ROLE
    of
        
        true ->
            SkillBuffList3 = SkillBuffList2;

        _ ->
            SkillBuffList3 = buff_by_equip(SrcActorAttr, SkillBuffList2, SrcActorType, SrcActorID, DActorID, DActorAttr)
    end,
    ?DEBUG("calc_skill_effect2, skillbufflist3: ~w", [SkillBuffList3]),

    %%是否无敌，无敌状态下不受BUFF影响
    Unbeatable = if_actor_unbeatable(DActorBuff, DActorType),
    case Unbeatable of
        true ->
            SkillBuffList4 = [];

        _ ->
            SkillBuffList4 = SkillBuffList3
    end,
    ?DEBUG("calc_skill_effect2, unbeatable: ~w", [Unbeatable]),

    %%加BUFF，假设都是成功的。。。
    mod_buff:add_buff_to_actor(SrcActorID, SrcActorType, SkillBuffList4, DActorID, DActorType, DActorAttr),

    %%获取最终加在角色上面的效果，有些效果可能不会发挥作用（存在概率）
    SkillEffect = sum_skill_effect(Flag, SkillEffectList, SrcActorAttr, Category, Unbeatable),
    ?DEBUG("calc_skill_effect3, skilleffect: ~w", [SkillEffect]),

    calc_skill_effect4(SrcActorID, SrcActorID, SrcActorType, SrcActorAttr, SrcActorBuff, SkillEffect,
                       DActorID, DActorType, DActorAttr, DActorBuff, SkillBuffList4, SkillID).

calc_skill_effect4(SrcActorID, SrcActorID, SrcActorType, SrcActorAttr, SrcActorBuff, SkillEffect,
                   DActorID, DActorType, DActorAttr, DActorBuff, SkillBuffList, SkillID) ->
    
    %%把效果逐个加到目标上面，并返回结果以及目标新的战斗属性
    {Result, SrcActorAttr3} =
        lists:foldl(
          fun(Effect, {Acc, SrcActorAttrTmp}) ->
                  case mod_effect:calc_effect_final_value(SrcActorAttr,SrcActorID, SrcActorType, Effect,
                                                          DActorAttr, DActorID, DActorType, DActorBuff, SkillID) of
                      {ok, ResultType, ResultValue, IsDoubleAttack} ->

                          case Acc of
                              nil ->
                                  {{ResultType, ResultValue, IsDoubleAttack}, SrcActorAttrTmp};

                              {ResultType, OldValue, _} ->
                                  {{ResultType, ResultValue+OldValue, IsDoubleAttack}, SrcActorAttrTmp};

                              _ ->
                                  {Acc, SrcActorAttrTmp}
                          end;

                      {ok, SrcActorAttr2} ->
                          {Acc, SrcActorAttr2};
                      
                      {error, _} ->
                          {Acc, SrcActorAttrTmp}
                  end   
          end, {nil, SrcActorAttr}, SkillEffect),
    
    %%没有一个效果加成功那么返回为空。。。。
    %%这样处理也不是很好，存在BUFF加成功但是效果没加成功的可能，或者有的技能只有BUFF没有EFFECT
    case Result of
        nil ->
            case SkillBuffList =:= [] of
                true ->
                    [];

                false ->
                    #p_attack_result{dest_id=DActorID, dest_type=get_dest_type(DActorType),
                                     buffs=detail_to_actorbuff(SrcActorID, SrcActorType, DActorID, DActorType, SkillBuffList)}
            end;

        {ResultType, ResultValue, IsDoubleAttack} ->

            %%计算效果最终伤害值
            calc_skill_effect5(ResultType, common_tool:ceil(ResultValue), SrcActorAttr3, DActorID, SkillBuffList,
                               DActorAttr, DActorBuff, DActorType, SrcActorBuff, SrcActorID, SrcActorType, IsDoubleAttack)
    end.

calc_skill_effect5(ResultType, ResultValue, SrcActorAttr, DActorID, SkillBuffList,
                   DActorAttr, DActorBuff, DActorType, SrcActorBuff, SrcActorID, SrcActorType, IsDoubleAttack) ->

    %%计算攻击方和被攻击方的buff的影响
    #actor_fight_attr{actor_id=DActorID, actor_name=DActorName} = DActorAttr,

    ResultValue2 = calc_result_after_buff(ResultValue, DActorBuff, DActorID, DActorType, DActorAttr,
                                              SrcActorID, DActorName, SrcActorBuff, SrcActorType, SrcActorAttr),
    ResultValue3 = common_tool:ceil(ResultValue2),

    %%伤害反射
    hurt_rebound(SrcActorID, SrcActorType, DActorType, DActorAttr, ResultValue3),

    calc_src_result(SrcActorID, SrcActorType, SrcActorBuff, ResultValue3),

    mod_effect:apply_effect(ResultType, ResultValue3, DActorType, DActorID, 
                            SrcActorAttr, SrcActorID, SrcActorType),

    #p_attack_result{dest_id=DActorID, dest_type=get_dest_type(DActorType),
                     buffs=detail_to_actorbuff(SrcActorID, SrcActorType, DActorID, DActorType, SkillBuffList),
                     is_erupt=IsDoubleAttack, result_type=ResultType, result_value=ResultValue3}.

calc_src_result(RoleID, _SrcActorType, SrcBuffs, ResultValue) ->
    lists:foreach(
      fun(Buff) ->
              #p_actor_buf{buff_id=BuffID, buff_type=Type} = Buff,

              {ok, Detail} = mod_skill_manager:get_buf_detail(BuffID),
              {ok, Func} = mod_skill_manager:get_buff_func_by_type(Type),

              #p_buf{value=Value} = Detail,
              case Func of
                  %%吸血
                  drains ->
                      Incre = common_tool:ceil(ResultValue*(Value/10000)),
                      self() ! {mod_map_role,{role_add_hp, RoleID, Incre, RoleID}};
                  _ ->
                      ok
              end
      end, SrcBuffs).              

calc_result_after_buff(ResultValue, DActorBuff, DActorID, DActorType, _DActorAttr, SrcActorID, _DActorName, _SrcActorBuff, SrcActorType, SrcActorAttr) ->
    lists:foldl(
      fun(Buff, Acc) ->
              #p_actor_buf{buff_id=BuffID, buff_type=Type} = Buff,

              {ok, Detail} = mod_skill_manager:get_buf_detail(BuffID),
              {ok, Func} = mod_skill_manager:get_buff_func_by_type(Type),

              #p_buf{value=Value, level=Level} = Detail,

              case Func of
                  %%伤害转化成魔法
                  hurt_to_magic ->
                      hurt_to_magic(DActorID, Acc, Value);
                  %%伤害吸收
                  reduce_hurt ->
                      Acc*(1-(Value/10000));
                  %%减速
                  reduce_actor_speed ->
                      case if_active(Value) of
                          true ->
                              BuffID2 = 554 + Level,
                              {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID2),
                              mod_buff:add_buff_to_actor(DActorID, DActorType, BuffDetail, SrcActorID, SrcActorType, SrcActorAttr),
                              Acc;
                          false ->
                              Acc
                      end;
                  pet_wall ->
                    %%这里不判断玩家是否有召唤出来的宠物，默认认为玩家一定有召唤一只有复活技能的宠物，伤害吸收暂时写死10%
                    case random:uniform(10000) =< Value of
                        true ->
                            mod_map_pet:reduce_role_pet_hp_on_pet_wall(DActorID,trunc(Acc/10),SrcActorID,SrcActorType),
                            trunc(Acc * 9000 / 10000);
                        false ->
                            Acc
                    end;
                  _ ->
                      Acc
              end
         end, ResultValue, DActorBuff).

hurt_to_magic(ActorID, Acc, Value) ->
    Rate = common_tool:random(1, 100),
    case Rate =< 10 of
        true ->
            self() ! {mod_map_role, {role_add_mp, ActorID, common_tool:ceil(Acc*Value/10000), ActorID}},
            Acc;
        false ->
            Acc
    end.

%%广播结果
do_result(SrcActorID, SrcActorType, Unique, SkillID, MapState, Result, Dir, DestPos, TargetID, TargetType) ->
    %%宠物战斗的消息需要返回给客户端，所以特殊处理
    case SrcActorID of
        {PetID,RoleID} ->
            SrcActorID2=PetID,
             SrcActorID3=RoleID;
        _ ->
            SrcActorID2=SrcActorID,
             SrcActorID3=SrcActorID
    end,

    %%更新攻击者方向
    SrcPos = update_actor_pos_after_fight(SrcActorID, SrcActorType, Dir),

    case Result of
        %%出错了
        {error, Reason,ReasonCode} ->
            do_fight_attack_error(SrcActorType,SrcActorID3,Unique,SrcActorID2,Reason,ReasonCode);
        {error, Reason} ->
            do_fight_attack_error(SrcActorType,SrcActorID3,Unique,SrcActorID2,Reason,0);
        {ok, ResultList} ->
            DestList = 
                lists:foldl(
                  fun(AttackResult, Acc) ->
                          DestActorID = AttackResult#p_attack_result.dest_id,
                          DestActorType = AttackResult#p_attack_result.dest_type,

                          case DestActorType of
                              ?TYPE_ROLE ->
                                  [{role, DestActorID}|Acc];
                              ?TYPE_MONSTER ->
                                  [{monster, DestActorID}|Acc];
                              ?TYPE_YBC ->
                                  [{monster, DestActorID}| Acc];
                              ?TYPE_SERVER_NPC ->
                                  [{server_npc, DestActorID}| Acc];  
                              ?TYPE_PET ->
                                  [{pet, DestActorID}| Acc];  
                              _ ->
                                  Acc
                          end
                  end, [], ResultList),

            SrcType = get_dest_type(SrcActorType),
            case SrcActorType of
                role ->
                    R = #m_fight_attack_toc{
                      return_self=true, 
                      src_id=SrcActorID2, 
                      src_type=SrcType, 
                      src_pos=SrcPos,dir=Dir,
                      skillid=SkillID,
                      dest_pos=DestPos,
                      result=ResultList,
                      target_id=TargetID,
                      target_type=TargetType
                     },
                    common_misc:unicast({role, SrcActorID3}, Unique, ?FIGHT, ?FIGHT_ATTACK, R);
                pet ->
                    R = #m_fight_attack_toc{
                      return_self=true, 
                      src_id=SrcActorID2, 
                      src_type=SrcType, 
                      src_pos=SrcPos,dir=Dir,
                      skillid=SkillID,
                      dest_pos=DestPos,
                      result=ResultList,
                      target_id=TargetID,
                      target_type=TargetType
                     },
                    common_misc:unicast({role, SrcActorID3}, Unique, ?FIGHT, ?FIGHT_ATTACK, R);
                _ ->
                    ok
            end,

            BroadCast = #m_fight_attack_toc{
              return_self=false, 
              src_id=SrcActorID2, 
              src_type=SrcType,
              src_pos=SrcPos,dir=Dir,
              dest_pos=DestPos,
              skillid=SkillID,
              result=ResultList,
              target_id=TargetID,
              target_type=TargetType
             },
            mgeem_map:do_broadcast_insence_include([{SrcActorType, SrcActorID2}|DestList], 
                                                   ?FIGHT, ?FIGHT_ATTACK, BroadCast, MapState)
    end.

do_fight_attack_error(SrcActorType,SrcActorID3,Unique,SrcActorID2,Reason,ReasonCode) ->
    SrcType = get_dest_type(SrcActorType),
    SelfRecord = #m_fight_attack_toc{succ=false, reason=Reason, reason_code = ReasonCode, src_type=SrcType, src_id=SrcActorID2},
    case SrcActorType of
        role ->
            common_misc:unicast({role, SrcActorID3}, Unique, ?FIGHT, ?FIGHT_ATTACK, SelfRecord);
        pet ->
            common_misc:unicast({role, SrcActorID3}, Unique, ?FIGHT, ?FIGHT_ATTACK, SelfRecord);
        monster ->
            ignore;
        server_npc ->
            ignore
    end.


-spec(get_dirty_actor_fight_attr(Type::atom(), ActorID::integer()) 
      -> {error, list()} | {ok, #actor_fight_attr{}}).
get_dirty_actor_fight_attr(role, RoleID) ->
    case mod_map_role:get_role_base(RoleID) of
        {error, _} ->
            {error, system_error};
        {ok, RoleBase} ->
            #p_role_base{role_name=RoleName,
                         max_phy_attack=MaxPhyAttack,
                         min_phy_attack=MinPhyAttack, 
                         max_magic_attack=MaxMagicAttack, 
                         min_magic_attack=MinMagicAttack,
                         phy_defence=PhyDefence,
                         magic_defence=MagicDefence,
                         buffs=Buffs,
                         luck=Luck,
                         no_defence=NoDefence,
                         miss=Miss,
                         double_attack=DoubleAttack,
                         phy_anti=PhyAnti,
                         magic_anti=MagicAnti,
                         pk_mode = PKMode,
                         pk_points = PKPoints,
                         team_id = TeamID,
                         family_id = FamilyID,
                         faction_id = FactionID,
                         if_gray_name = GrayName,
                         max_hp=MaxHP,
                         phy_hurt_rate=PhyHurtRate,
                         magic_hurt_rate=MagHurtRate,
                         attack_speed=AttackSpeed,
                         dizzy=Dizzy,
                         poisoning=Poisoning,
                         freeze=Freeze,
                         poisoning_resist=PoisoningResist,
                         dizzy_resist=DizzyResist,
                         freeze_resist=FreezeResist,
                         hurt_rebound=HurtRebound,
                         equip_score=EquipScore,
                         spec_score_one=SpecScoreOne,
                         spec_score_two=SpecScoreTwo,
                         hit_rate=HitRate
                        } = RoleBase,
            #actor_fight_attr{actor_id=RoleID,
                              actor_name=RoleName,
                              max_phy_attack=MaxPhyAttack,
                              min_phy_attack=MinPhyAttack, 
                              max_magic_attack=MaxMagicAttack, 
                              min_magic_attack=MinMagicAttack,
                              phy_defence=PhyDefence,
                              magic_defence=MagicDefence,
                              buffs=Buffs,
                              luck=Luck,
                              no_defence=NoDefence,
                              miss=Miss,
                              double_attack=DoubleAttack,
                              phy_anti=PhyAnti,
                              magic_anti=MagicAnti,
                              pk_mode = PKMode,
                              pk_points = PKPoints,
                              team_id = TeamID,
                              family_id = FamilyID,
                              faction_id = FactionID,
                              gray_name = GrayName,
                              max_hp=MaxHP,
                              phy_hurt_rate=PhyHurtRate,
                              magic_hurt_rate=MagHurtRate,
                              attack_speed=AttackSpeed,
                              dizzy=Dizzy,
                              poisoning=Poisoning,
                              freeze=Freeze,
                              poisoning_resist=PoisoningResist,
                              dizzy_resist=DizzyResist,
                              freeze_resist=FreezeResist,
                              hurt_rebound=HurtRebound,
                              equip_score=EquipScore,
                              spec_score_one=SpecScoreOne,
                              spec_score_two=SpecScoreTwo,
                              hit_rate=HitRate
                             };
        _ ->
            {error, system_error}
    end;

get_dirty_actor_fight_attr(monster, MonsterID) ->
    ?DEBUG("get monster attr",[]),
    case  mod_map_monster:get_monster_state(MonsterID) of
        undefined ->
            {error, system_error};
        MonsterState ->
            MonsterInfo = MonsterState#monster_state.monster_info,
            ?DEBUG("get_dirty_monster_attr  ~p",[MonsterInfo]),
            #p_monster{monstername = MonsterName,
                       min_attack = MinAttack,
                       max_attack = MaxAttack,
                       phy_defence = PhyDefence,
                       magic_defence = MagicDefence,                   
                       dead_attack = DoubleAttack,         
                       lucky = Luck,                         
                       miss = Miss,
                       buffs=Buffs,                        
                       no_defence = NoDefence, 
                       phy_anti=PhyAnti,
                       magic_anti=MagicAnti,
                       max_hp=MaxHP,
                       attack_speed=AttackSpeed,
                       poisoning_resist=PoisoningResist,
                       dizzy_resist=DizzyResist,
                       freeze_resist=FreezeResist,
                       equip_score=EquipScore,
                       spec_score_one=SpecScoreOne,
                       spec_score_two=SpecScoreTwo,
                       hit_rate=HitRate
                      } = MonsterInfo,
            #actor_fight_attr{actor_id=MonsterID,
                              actor_name=MonsterName,
                              max_phy_attack=MaxAttack,
                              min_phy_attack=MinAttack, 
                              max_magic_attack=MaxAttack, 
                              min_magic_attack=MinAttack,
                              phy_defence=PhyDefence,
                              magic_defence=MagicDefence,
                              buffs=Buffs,
                              luck=Luck,
                              no_defence=NoDefence,
                              miss=Miss,
                              double_attack=DoubleAttack,
                              phy_anti=PhyAnti,
                              magic_anti=MagicAnti,
                              max_hp=MaxHP,
                              attack_speed=AttackSpeed,
                              poisoning_resist=PoisoningResist,
                              dizzy_resist=DizzyResist,
                              freeze_resist=FreezeResist,
                              equip_score=EquipScore,
                              spec_score_one=SpecScoreOne,
                              spec_score_two=SpecScoreTwo,
                              hit_rate=HitRate
                        }
    end;
get_dirty_actor_fight_attr(server_npc, MonsterID) ->
    ?DEBUG("get monster attr",[]),
    case  mod_server_npc:get_server_npc_state(MonsterID) of
        undefined ->
            {error, system_error};
        MonsterState ->
            MonsterInfo = MonsterState#server_npc_state.server_npc_info,
            ?DEBUG("get_dirty_monster_attr  ~p",[MonsterInfo]),
            #p_server_npc{
                    npc_name = MonsterName,
                    min_attack = MinAttack,
                    max_attack = MaxAttack,
                    phy_defence = PhyDefence,
                    magic_defence = MagicDefence,                   
                    dead_attack = DoubleAttack,         
                    lucky = Luck,                         
                    miss = Miss,
                    buffs=Buffs,                        
                    no_defence = NoDefence, 
                    phy_anti=PhyAnti,
                    magic_anti=MagicAnti,
                    max_hp=MaxHP,
                    attack_speed=AttackSpeed,
                    poisoning_resist=PoisoningResist,
                    dizzy_resist=DizzyResist,
                    freeze_resist=FreezeResist,
                    equip_score=EquipScore,
                    spec_score_one=SpecScoreOne,
                    spec_score_two=SpecScoreTwo,
                    hit_rate=HitRate
                   } = MonsterInfo,
            #actor_fight_attr{
                         actor_id=MonsterID,
                         actor_name=MonsterName,
                         max_phy_attack=MaxAttack,
                         min_phy_attack=MinAttack, 
                         max_magic_attack=MaxAttack, 
                         min_magic_attack=MinAttack,
                         phy_defence=PhyDefence,
                         magic_defence=MagicDefence,
                         buffs=Buffs,
                         luck=Luck,
                         no_defence=NoDefence,
                         miss=Miss,
                         double_attack=DoubleAttack,
                         phy_anti=PhyAnti,
                         magic_anti=MagicAnti,
                         max_hp=MaxHP,
                         attack_speed=AttackSpeed,
                         poisoning_resist=PoisoningResist,
                         dizzy_resist=DizzyResist,
                         freeze_resist=FreezeResist,
                         equip_score=EquipScore,
                         spec_score_one=SpecScoreOne,
                         spec_score_two=SpecScoreTwo,
                         hit_rate=HitRate
                        }
    end;
get_dirty_actor_fight_attr(ybc, YbcID) ->
    YbcMapInfo = mod_map_actor:get_actor_mapinfo(YbcID, ybc),
    #p_map_ybc{ybc_id=YbcID, name=YbcName,
               physical_defence=PhyDefence,
               magic_defence=MagicDefence,
               max_hp=MaxHP
              } = YbcMapInfo,
    #actor_fight_attr{
                      actor_id=YbcID,
                      actor_name=YbcName,
                      max_phy_attack=0,
                      min_phy_attack=0,
                      max_magic_attack=0,
                      min_magic_attack=0,
                      phy_defence=PhyDefence,
                      magic_defence=MagicDefence,
                      buffs=[],
                      luck=0,
                      no_defence=0,
                      miss=0,
                      double_attack=0,
                      phy_anti=0,
                      magic_anti=0, max_hp=MaxHP, attack_speed=0,
                      poisoning_resist=0,
                      dizzy_resist=0,
                      freeze_resist=0};
get_dirty_actor_fight_attr(pet, PetID) ->
    case get({?ROLE_PET_INFO,PetID}) of
        undefined ->
            {error, system_error};
        PetInfo ->
            #p_pet{pet_name=PetName,
                   max_hp=MaxHP, 
                   attack_speed=AttackSpeed,
                   double_attack=DoubleAttack, 
                   phy_defence=PhyDefence,
                   magic_defence=MagicDefence,
                   phy_attack=PhyAttack, 
                   magic_attack=MagicAttack,
                   buffs=Buffs,
                   pk_mode=PkMode,
                   level=Level
                  } = PetInfo,
            #actor_fight_attr{
                        actor_id=PetID,
                        actor_name=PetName,
                        max_phy_attack=PhyAttack,
                        min_phy_attack=PhyAttack,
                        max_magic_attack=MagicAttack,
                        min_magic_attack=MagicAttack,
                        phy_defence=PhyDefence,
                        magic_defence=MagicDefence,
                        buffs=Buffs,
                        pk_mode=PkMode,
                        luck=0,
                        no_defence=0,
                        miss=0,
                        double_attack=DoubleAttack,
                        phy_anti=0,
                        magic_anti=0, 
                        max_hp=MaxHP, 
                        attack_speed=AttackSpeed,
                        poisoning_resist=0,
                        dizzy_resist=0,
                        freeze_resist=0,
                        equip_score=common_tool:ceil(Level*2.5)}
    end; 
get_dirty_actor_fight_attr(In, _) ->
    ?ERROR_MSG("get_dirty_actor_fight_attr type ~p not implement", [In]),
    {error, not_implement}.


%%判断是否在技能施法距离之内
assert_distance(SPos, TX, TY, TargetType, Distance) ->
    if TargetType =:= ?TARGET_TYPE_SELF ->
            next;
       true ->
            #p_pos{tx=X, ty=Y} = SPos,
            %% 实际攻击距离比实际配的多1，缓解客户端看到能攻击，但提示在攻击范围之外的现象
            if erlang:abs(TX-X) =< Distance + 1 andalso erlang:abs(TY-Y) =< Distance + 1 ->
                    next;
               true ->
                    erlang:throw(?_LANG_FIGHT_NOT_IN_ATTACK_RANGE)
            end
    end.

%% 目标状态判断
assert_target_state(DActorType, DActorMapInfo, DIsDead, SkillId, TargetType) ->
    if TargetType =:= ?TARGET_TYPE_AREA_MAP ->
            next;
       SkillId =:= ?SKILL_RELIVE andalso (not DIsDead) ->
            erlang:throw(?_LANG_FIGHT_CANT_RELIVE_ALIVE);
       SkillId =:= ?SKILL_RELIVE andalso DActorType =/= role ->
            erlang:throw(?_LANG_FIGHT_CANT_RELIVE_ACTOR);
       SkillId =:= ?SKILL_RELIVE ->
            next;
       DIsDead ->
            erlang:throw(?_LANG_FIGHT_ERROR_ACTOR_DEAD);
       true ->
            case judge_is_invincible(DActorMapInfo) of
                true ->
                    erlang:throw(?_LANG_FIGHT_BONFIRE_INVINCIBLE);
                false ->
                    next
            end
    end.

assert_waroffaction(SActorType, SActorMapInfo, DActorType, DActorMapInfo) ->
    %% 国战期间不能攻击本国战斗NPC第三方国家
    case SActorType =:= role andalso  DActorType =:= server_npc andalso mod_map_role:is_in_waroffaction(SActorMapInfo#p_map_role.faction_id)
        andalso DActorMapInfo#p_map_server_npc.npc_country =:= SActorMapInfo#p_map_role.faction_id
    of
        true ->
            erlang:throw(?_LANG_FIGHT_CANT_ATTACK_NPC_IN_WAROFFACTION);
        _ ->
            case SActorType =:= role andalso DActorType =:= server_npc 
                andalso (DActorMapInfo#p_map_server_npc.npc_country =:= mod_waroffaction:get_defence_faction_id())
                andalso (not mod_map_role:is_in_waroffaction(SActorMapInfo#p_map_role.faction_id))
            of
                true ->
                    erlang:throw(?_LANG_FIGHT_CANT_ATTACK_OTHER_NPC_IN_WAROFFACTION);
                _ ->
                    ok
            end
    end.

%% 特殊技能判断
assert_spec_skill(SkillID, SPos, DTX, DTY) ->
    if SkillID =:= ?SKILL_CHARGE ->
            assert_skill_charge(SPos#p_pos.tx, SPos#p_pos.ty, DTX, DTY);
       true ->
            ok
    end.

assert_skill_charge(STX, STY, DTX, DTY) ->
    {NX, NY} = get_next_point(STX, STY, DTX, DTY),
    if NX =:= DTX andalso NY =:= DTY ->
            ok;
       true ->
            case get({NX, NY}) of
                undefined ->
                    erlang:throw(?_LANG_FIGHT_CHARGE_BARRIER_IN_FRONT);
                _ ->
                    case get({ref, NX, NY}) of
                        [] ->
                            assert_skill_charge(NX, NY, DTX, DTY);
                        _ ->
                            erlang:throw(?_LANG_FIGHT_CHARGE_BARRIER_IN_FRONT)
                    end
            end
    end.

get_next_point(X, Y, TX, TY) ->
    lists:foldl(
      fun(CX, Acc) ->
              lists:foldl(
                fun(CY, {MinX, MinY}) ->
                        case abs(TY-CY)+abs(TX-CX) < abs(TY-MinY)+abs(TX-MinX) of
                            true ->
                                {CX, CY};
                            _ ->
                                {MinX, MinY}
                        end
                end, Acc, lists:seq(Y-1, Y+1))
      end, {X, Y}, lists:seq(X-1, X+1)).

assert_actor_state(IsDead) ->
    if IsDead ->
            erlang:throw(?_LANG_FIGHT_ACTOR_DEAD);
       true ->
            next
    end.

%% @doc 是否能够使用技能，BUFF影响
assert_actor_buffs(SActorBuff, SActorType, SkillInfo) ->
    lists:foreach(
      fun(Buff) ->
              case mod_skill_manager:get_buff_func_by_type(Buff#p_actor_buf.buff_type) of
                  %%麻痹
                  {ok, paralysis} ->
                      erlang:throw(?_LANG_FIGHT_ACTOR_PAPALYSIS);
                  %%沉默
                  {ok, silent} ->
                      %% 沉默状态下还能够使用普通的攻击
                      if SActorType =:= role ->
                              SkillID = SkillInfo;
                         true ->
                              {SkillID, _} = SkillInfo
                      end,
                      if SkillID < 10 ->
                              ignore;
                         true ->
                              erlang:throw(?_LANG_FIGHT_ACTOR_SILENT)
                      end;
                  {ok,add_rigid} -> %%无敌，无攻
                      erlang:throw(?_LANG_FIGHT_ACTOR_UNBEAT);
                  {ok, dizzy} -> %%晕迷
                      erlang:throw(?_LANG_FIGHT_ACTOR_DIZZY);
                  _ ->
                      ignore
              end
      end, SActorBuff).

get_last_attack_time(ActorType, ActorID) ->
    case erlang:get({?last_attack_time, ActorType, ActorID}) of
        undefined ->
            {0, 0, 0};
        AttackTime ->
            AttackTime
    end.

set_last_attack_time(ActorType, ActorID, Now) ->
    erlang:put({?last_attack_time, ActorType, ActorID}, Now).

erase_last_attack_time(ActorType, ActorID) ->
    erlang:erase({?last_attack_time, ActorType, ActorID}).

set_last_skill_time(ActorType, ActorID, SkillTime) ->
    erlang:put({?last_skill_time, ActorType, ActorID}, SkillTime).

get_last_skill_time(ActorType, ActorID) ->
    case erlang:get({?last_skill_time, ActorType, ActorID}) of
        undefined ->
            [];
        SkillTime ->
            SkillTime
    end.

erase_last_skill_time(ActorType, ActorID) ->
    erlang:erase({?last_skill_time, ActorType, ActorID}).

set_last_skill_time(ActorType, ActorID, SkillID, Now) ->
    SkillTime = get_last_skill_time(ActorType, ActorID),
    SkillTime2 = [{SkillID, Now}|lists:keydelete(SkillID, 1, SkillTime)],
    set_last_skill_time(ActorType, ActorID, SkillTime2).

get_last_skill_time(ActorType, ActorID, SkillID) ->
    SkillTime = get_last_skill_time(ActorType, ActorID),
    case lists:keyfind(SkillID, 1, SkillTime) of
        false ->
            {0, 0, 0};
        {_, LastUseTime} ->
            LastUseTime
    end.

%% 冷却时间是否到了，怪物就不必验证了
assert_attack_speed(ActorType, ActorID, SkillID, CoolTime, AttackSpeed) 
  when ActorType =:= role orelse ActorType =:= pet ->

    Now = erlang:now(),
    LastUseTime =  get_last_skill_time(ActorType, ActorID, SkillID),
    TimerDiff = timer:now_diff(Now, LastUseTime),
    case TimerDiff / 1000 > CoolTime - 100 of
        true ->
            assert_attack_speed2(ActorType, ActorID, SkillID, AttackSpeed, Now);
        _ ->
            erlang:throw({?_LANG_FIGHT_ILLEGAL_SKILL_INTERVAL,90001})
    end;
assert_attack_speed(_ActorType, _ActorID, _SkillId, _CoolTime, _AttackSpeed) ->
    ok.

assert_attack_speed2(ActorType, ActorID, SkillID, AttackSpeed, Now) ->
    LastAttackTime = get_last_attack_time(ActorType, ActorID),
    case timer:now_diff(Now, LastAttackTime) / 1000 > 1000000 / AttackSpeed - 200 of
        true ->
            set_last_skill_time(ActorType, ActorID, SkillID, Now),
            set_last_attack_time(ActorType, ActorID, Now);
        _ ->
            erlang:throw({?_LANG_FIGHT_ATTACK_SPEED_ILLEGAL,90000})
    end.

%%判断魔法值，技能消耗物品等
deduct_skill_consumables(SkillLevelInfo, SActorMapInfo, role) ->
    #p_skill_level{consume_mp=ConsumeMp} = SkillLevelInfo,
    #p_map_role{role_id=RoleID} = SActorMapInfo,
    if
        ConsumeMp =< 0 ->
            ok;
        SActorMapInfo#p_map_role.mp >= ConsumeMp ->
            mod_map_role:do_role_reduce_mp(RoleID, ConsumeMp, RoleID),
            ok;
        true ->
            {error, ?_LANG_SKILL_ROLE_MP_NOT_ENOUGH}
    end;
deduct_skill_consumables(_, _, _) ->
    ok.

%%获取技能对应的作用范围为的目标，如群攻的目标
get_target_actor_in_area(SrcActorID, SrcActorType, DActorID, DActorType, TX, TY, Dir, TargetType, TergetArea) ->
    case TargetType of

        %%施法者自己
        ?TARGET_TYPE_SELF ->
            [{SrcActorType, SrcActorID}];
        
        %%施法者自己周围
        ?TARGET_TYPE_SELF_AROUND ->
            List = get_actors_around_map_grid(TX, TY, TergetArea),
            get_target_actor_in_area2(List);

        %%施法者前方区域
        ?TARGET_TYPE_SELF_FRONT ->
            case mod_map_actor:get_actor_txty_by_id(SrcActorID, SrcActorType) of
                undefined ->
                    [];

                {SrcTX, SrcTY} ->
                    List = get_actors_front_map_grid(SrcTX, SrcTY, Dir, TergetArea),
                    List2 = get_target_actor_in_area2(List),
                    case lists:member({DActorType, DActorID}, List2) of
                        false ->
                             [{DActorType, DActorID}|List2];
                        true ->
                            List2
                    end
            end;

        %%选择的目标
        ?TARGET_TYPE_OTHER ->
            [{DActorType, DActorID}];

        %%选择的目标周围
        ?TARGET_TYPE_OTHER_AROUND ->
            List = get_actors_around_map_grid(TX, TY, TergetArea),
            get_target_actor_in_area2(List);

        %%选择目标的周围
        ?TARGET_TYPE_OTHER_FRONT ->
            List = get_actors_front_map_grid(TX, TY, Dir, TergetArea),
            get_target_actor_in_area2(List);

        %%地图区域
        ?TARGET_TYPE_AREA_MAP ->
            [];
        
        %%宠物主人
        ?TARGET_TYPE_PET_OWNER -> 
            case get({?PET_INFO,SrcActorID}) of
                undefined ->
                    [];
                #p_pet{role_id=OwnerID}->
                    [{role,OwnerID}]
            end;
        %%其它
        _ ->
            []
    end.



%%根据格子列表获取所有的目标
get_target_actor_in_area2(List) ->
    lists:foldr(
      fun({TX, TY}, Acc) ->
              case get({ref, TX, TY}) of
                  undefined -> 
                      Acc;
                  List2 ->
                      lists:append(Acc, List2)
              end
      end, [], List).


%%获取目标前方范围内的的格子
get_actors_front_map_grid(TX,TY,Dir,TergetArea) ->
    case Dir of
        0 ->
            case TergetArea of
                3 ->
                    [{TX-1,TY},{TX-1,TY-1},{TX,TY-1}];
                5 ->
                    [{TX-1,TY+1},{TX-1,TY},{TX-1,TY-1},{TX,TY-1},{TX+1,TY-1}]
            end;
        1 ->
            case TergetArea of
                3 ->
                    [{TX-1,TY-1},{TX,TY-1},{TX+1,TY-1}];
                5 ->
                    [{TX-1,TY},{TX-1,TY-1},{TX,TY-1},{TX+1,TY-1},{TX+1,TY}]
            end;
        2 ->
            case TergetArea of
                3 ->
                    [{TX,TY-1},{TX+1,TY-1},{TX+1,TY}];
                5 ->
                    [{TX-1,TY-1},{TX,TY-1},{TX+1,TY-1},{TX+1,TY},{TX+1,TY+1}]
            end;
        3 ->
            case TergetArea of
                3 ->
                    [{TX+1,TY-1},{TX+1,TY},{TX+1,TY+1}];
                5 ->
                    [{TX,TY-1},{TX+1,TY-1},{TX+1,TY},{TX+1,TY+1},{TX,TY+1}]
            end;
        4 ->
            case TergetArea of
                3 ->
                    [{TX+1,TY},{TX+1,TY+1},{TX,TY+1}];
                5 ->
                    [{TX+1,TY-1},{TX+1,TY},{TX+1,TY+1},{TX,TY+1},{TX-1,TY+1}]
            end;
        5 ->
            case TergetArea of
                3 ->
                    [{TX+1,TY+1},{TX,TY+1},{TX-1,TY+1}];
                5 ->
                    [{TX+1,TY},{TX+1,TY+1},{TX,TY+1},{TX-1,TY+1},{TX-1,TY}]
            end;
        6 ->
            case TergetArea of
                3 ->
                    [{TX,TY+1},{TX-1,TY+1},{TX-1,TY}];
                5 ->
                    [{TX+1,TY+1},{TX,TY+1},{TX-1,TY+1},{TX-1,TY},{TX-1,TY-1}]
            end;
        7 ->
            case TergetArea of
                3 ->
                    [{TX-1,TY+1},{TX-1,TY},{TX-1,TY-1}];
                5 ->
                    [{TX,TY+1},{TX-1,TY+1},{TX-1,TY},{TX-1,TY-1},{TX,TY-1}]
            end
    end.


%%获取目标周围范围内的格子
get_actors_around_map_grid(TX, TY, TergetArea) ->
    %%TergetArea为3表示3*3的区域，即玩家自身格子和周围一圈的格子
    Num = round((TergetArea-1)/2),
    SX = TX - Num,
    EX = TX + Num,
    SY = TY - Num,
    EY = TY + Num,
    lists:foldr(
      fun(X, Acc) ->
              lists:foldr(
                fun(Y, Acc0) ->
                        [{X, Y}|Acc0]
                end, Acc, lists:seq(SY, EY))
      end, [], lists:seq(SX, EX)).


%%计算施法者各项技能效果的累计值，无敌状态下只有驱散才能发挥作用
sum_skill_effect(Flag, SkillEffectList, SrcActorAttr, Category, Unbeatable) ->
    ?DEBUG("sum_skill_effect, skilleffectlist: ~w", [SkillEffectList]),

    List = 
        case Unbeatable of
            true ->
                [];
            false ->
                case Flag of
                    true ->
                        get_base_attack_effect(SrcActorAttr, Category);
                    false ->
                        []
                end
        end,

    lists:foldr(
      fun(Effect, Acc) ->
              #p_effect{probability=Rate, calc_type=CalcType} = Effect,

              case Unbeatable of
                  true ->
                      case CalcType of
                          ?CALC_TYPE_DISPEL_BUFF ->
                              if_take_effect(Rate, Acc, Effect,SrcActorAttr);
                          _ ->
                              Acc
                      end;

                  _ ->
                      if_take_effect(Rate, Acc, Effect,SrcActorAttr)
              end
      end, List, SkillEffectList).


%%PK模式判定。。。
%%{true, reason}，对于true里面的reason是没用的，仅为了统一处理
judge_pk_mode(EffectType, SActorID, monster, _PKMode, _SActorMapInfo, DActorType, DActorID, _MapID) -> 
    case EffectType of
        ?SKILL_EFFECT_TYPE_SELF ->
            {SActorID =:= DActorID andalso monster =:= DActorType, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET};
        ?SKILL_EFFECT_TYPE_ENEMY ->
            {not(DActorType =:= monster), ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET};
        ?SKILL_EFFECT_TYPE_FRIEND ->
            {DActorType =:= monster, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET};
        _ ->
            {true, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET}
    end;
judge_pk_mode(EffectType, SActorID, server_npc, _PKMode, _SActorMapInfo, DActorType, DActorID, _MapID) -> 
    case EffectType of
        ?SKILL_EFFECT_TYPE_SELF ->
            {SActorID =:= DActorID andalso server_npc =:= DActorType, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET};
        ?SKILL_EFFECT_TYPE_ENEMY ->
            %% NPC不攻击摆摊的玩家
            case DActorType of
                server_npc ->
                    {false, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET};
                role ->
                    case mod_map_actor:get_actor_mapinfo(DActorID, role) of
                        undefined ->
                            {false, ?_LANG_SYSTEM_ERROR};
                        #p_map_role{state=?ROLE_STATE_STALL} ->
                            {false, ?_LANG_FIGHT_TARGET_STALL};
                        _ ->
                            {true, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET}
                    end;
                _ ->
                    {true, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET}
            end; 
        ?SKILL_EFFECT_TYPE_FRIEND ->
            {DActorType =:= server_npc, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET};
        _ ->
            {true, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET}
    end;
judge_pk_mode(EffectType, SActorID, role, PKMode, SActorMapInfo,
              DActorType, DActorID, MapID) ->

    case EffectType of
        ?SKILL_EFFECT_TYPE_SELF ->
            {SActorID =:= DActorID andalso role =:= DActorType, ?_LANG_FIGHT_SKILL_JUST_SELF};
        ?SKILL_EFFECT_TYPE_MONSTER ->
            {DActorType =:= monster, ?_LANG_FIGHT_SKILL_JUST_MONSTER};
        ?SKILL_EFFECT_TYPE_SERVER_NPC ->
            {DActorType =:= server_npc, ?_LANG_FIGHT_SKILL_JUST_MONSTER};
        ?SKILL_EFFECT_TYPE_PET ->
            {DActorType =:= pet, ?_LANG_FIGHT_SKILL_JUST_PET};
        ?SKILL_EFFECT_TYPE_YBC ->
            {DActorType =:= ybc, ?_LANG_FIGHT_SKILL_JUST_YBC};
        ?SKILL_EFFECT_TYPE_ENEMY ->
            if
                DActorType =:= role ->
                    judge_pk_mode_enemy(PKMode, SActorID, SActorMapInfo, DActorID, MapID);
                DActorType =:= ybc ->
                    judge_pk_mode_ybc(PKMode, SActorID, SActorMapInfo, DActorID);
                DActorType =:= server_npc ->
                    judge_pk_mode_npc(PKMode, SActorID, SActorMapInfo, DActorID);
                DActorType =:= pet ->
                    judge_pk_mode_pet(PKMode, SActorID, SActorMapInfo, DActorID);
                true ->
                    {true, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET}
            end;
        ?SKILL_EFFECT_TYPE_ENEMY_ROLE ->
            case DActorType =:= role of
                false ->
                    {true, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET};
                true ->
                    judge_pk_mode_enemy(PKMode, SActorID, SActorMapInfo, DActorID, MapID)
            end;
        ?SKILL_EFFECT_TYPE_FRIEND ->
            case DActorType =:= role of
                false ->
                    {false, ?_LANG_FIGHT_SKILL_JUST_FRIEND};
                true ->
                    judge_pk_mode_friend(PKMode, SActorID, SActorMapInfo, DActorID)
            end;
        ?SKILL_EFFECT_TYPE_FRIEND_ROLE ->
            case DActorType =:= role of
                false ->
                    {false, ?_LANG_FIGHT_SKILL_JUST_FRIEND};
                true ->
                    judge_pk_mode_friend(PKMode, SActorID, SActorMapInfo, DActorID)
            end;
        ?SKILL_EFFECT_TYPE_ALL_PLAYER ->
            {DActorType =:= role, ?_LANG_FIGHT_SKILL_JUST_ROLE};
        _ ->
            {true, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET}
    end;
judge_pk_mode(EffectType, SActorID, pet, PKMode, SActorMapInfo,
              DActorType, DActorID, MapID) ->
    RoleID = SActorMapInfo#p_map_pet.role_id,
    case EffectType of
        ?SKILL_EFFECT_TYPE_SELF ->
            {SActorID =:= DActorID andalso pet =:= DActorType, ?_LANG_FIGHT_SKILL_JUST_SELF};
        ?SKILL_EFFECT_TYPE_PET ->
            {DActorType =:= pet, ?_LANG_FIGHT_SKILL_JUST_PET};
        ?SKILL_EFFECT_TYPE_MASTER ->
            {DActorType =:= role andalso RoleID =:= DActorID, ?_LANG_FIGHT_SKILL_JUST_YBC};
       _ ->
            RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID, role),
            judge_pk_mode(EffectType, RoleID, role, PKMode, RoleMapInfo,
              DActorType, DActorID, MapID)
    end.

%% @doc NPC攻击判断
judge_pk_mode_npc(PKMode, _SActorID, SActorMapInfo, DActorID) ->
    case mod_map_actor:get_actor_mapinfo(DActorID, server_npc) of
        undefined ->
            {false, ?_LANG_SYSTEM_ERROR};
        DMapInfo ->
            #p_map_server_npc{is_undead=IsUndead, npc_country=NPCCountry} = DMapInfo,
            %% 无敌状态不能攻击
            case IsUndead of
                true ->
                    {false, ?_LANG_FIGHT_TARGET_UNDEAD};
                _ ->
                    judge_pk_mode_npc2(PKMode, SActorMapInfo, NPCCountry)
            end
    end.
judge_pk_mode_npc2(PKMode, SActorMapInfo, NPCCountry) ->
    #p_map_role{faction_id=SFactionID} = SActorMapInfo,

    case PKMode of
        ?PK_PEACE -> %% 合平模式
            {false, ?_LANG_FIGHT_ENEMY_PK_PEACE};
        ?PK_FACTION -> %% 国家模式
            {SFactionID =/= NPCCountry, ?_LANG_FIGHT_NPC_FACTION};
        ?PK_MASTER ->
            {false, ?_LANG_FIGHT_NPC_MASTER_MODE};
        _ ->
            {true, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET}
    end.

%% 镖车攻击判断
judge_pk_mode_ybc(PKMode, SActorID, SActorMapInfo, DActorID) ->
    DMapInfo = mod_map_actor:get_actor_mapinfo(DActorID, ybc),
    FamilyID = DMapInfo#p_map_ybc.group_id,

    case DMapInfo#p_map_ybc.can_attack of
        true ->
            %% 判断是不是自己的镖车
            case DMapInfo#p_map_ybc.creator_id =:= SActorID of
                true ->
                    {false, ?_LANG_FIGHT_CANNT_ATTACK_SELF_YBC};
                false ->
                    %% 判断是不是自己门派的镖车
                    case FamilyID >0 andalso FamilyID =:= SActorMapInfo#p_map_role.family_id of
                        true ->
                            {false, ?_LANG_FIGHT_CANNT_ATTACK_SELF_FAMILY_YBC};
                        false ->
                            case PKMode of
                                ?PK_PEACE -> %和平模式
                                    {false, ?_LANG_FIGHT_ENEMY_PK_PEACE};
                                _ ->
                                    DPos = DMapInfo#p_map_ybc.pos,
                                    DSafe = get({DPos#p_pos.tx, DPos#p_pos.ty}),
                                    case DSafe =:= safe orelse DSafe =:= absolute_safe of
                                        true ->
                                            {false, ?_LANG_FIGHT_IN_SAFE_AREA};
                                        _ ->
                                            {true, true}
                                    end
                            end
                    end
            end;
        false ->
            case mod_waroffaction:check_in_waroffaction_time() of
                true ->
                   %% 判断是不是自己的镖车
                    case DMapInfo#p_map_ybc.creator_id =:= SActorID of
                        true ->
                            {false, ?_LANG_FIGHT_CANNT_ATTACK_SELF_YBC};
                        false ->
                            %% 判断是不是自己门派的镖车
                            case FamilyID =:= SActorMapInfo#p_map_role.family_id of
                                true ->
                                    {false, ?_LANG_FIGHT_CANNT_ATTACK_SELF_FAMILY_YBC};
                                false ->
                                    case PKMode of
                                        ?PK_PEACE -> %和平模式
                                            {false, ?_LANG_FIGHT_ENEMY_PK_PEACE};
                                        _ ->
                                            DPos = DMapInfo#p_map_ybc.pos,
                                            DSafe = get({DPos#p_pos.tx, DPos#p_pos.ty}),
                                            case DSafe =:= safe orelse DSafe =:= absolute_safe of
                                                true ->
                                                    {false, ?_LANG_FIGHT_IN_SAFE_AREA};
                                                _ ->
                                                    {true, true}
                                            end
                                    end
                            end
                    end;
                false ->
                    {false, ?_LANG_FIGHT_YBC_CANNT_ATTACK}
            end
    end.


%%宠物攻击判断
judge_pk_mode_pet(PKMode, SActorID, SActorMapInfo, DActorID) ->
    case mod_map_actor:get_actor_mapinfo(DActorID, pet) of
        undefined ->
            {false, ?_LANG_SYSTEM_ERROR};
        DPetMapInfo ->
            RoleID = DPetMapInfo#p_map_pet.role_id,
            MapID = mgeem_map:get_mapid(),
            judge_pk_mode_enemy(PKMode, SActorID, SActorMapInfo, RoleID, MapID) 
    end.
                    
    
judge_pk_mode_enemy(SActorMode, SActorID, SActorMapInfo, DActorID, MapID) ->
    case SActorID =:= DActorID of
        true ->
            {false, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET};
        _ ->
            case mod_map_actor:get_actor_mapinfo(DActorID, role) of
                undefined ->
                    {false, ?_LANG_SYSTEM_ERROR};
                
                DActorMapInfo ->
                    case hook_fight:check_fight_pk_mod(SActorID, SActorMapInfo, DActorID, DActorMapInfo,MapID) of
                        true ->
                            #p_map_role{pos=SPos} = SActorMapInfo,
                            #p_map_role{faction_id=DFactionID, pos=DPos} = DActorMapInfo,
                            
                            case check_fight_pos(SPos, DPos, DFactionID, MapID) of
                                true ->
                                    judge_pk_mode_enemy3(SActorMode, SActorMapInfo, DActorMapInfo);
                                {false, Reason} ->
                                    {false, Reason}
                            end;
                        {false, Reason} ->
                            {false, Reason}
                    end
            end
    end.

judge_pk_mode_enemy3(SActorMode, SActorMapInfo, DActorMapInfo) ->
    case SActorMode of
        ?PK_PEACE -> %合平模式
            {false, ?_LANG_FIGHT_ENEMY_PK_PEACE};
        ?PK_ALL -> %全体模式
            {true, ?_LANG_FIGHT_ENEMY_PK_PEACE};

        ?PK_TEAM -> %组队模式
            {not (SActorMapInfo#p_map_role.team_id =/= 0 andalso
                  SActorMapInfo#p_map_role.team_id =:= DActorMapInfo#p_map_role.team_id),
             ?_LANG_FIGHT_ENEMY_PK_TEAM};

        ?PK_FAMILY -> %门派模式
            {not (SActorMapInfo#p_map_role.family_id =/= 0 andalso
                  SActorMapInfo#p_map_role.family_id =:= DActorMapInfo#p_map_role.family_id),
             ?_LANG_FIGHT_ENEMY_PK_FAMILY};

        ?PK_FACTION -> %国家模式
            {not (SActorMapInfo#p_map_role.faction_id =:= DActorMapInfo#p_map_role.faction_id),
             ?_LANG_FIGHT_ENEMY_PK_FACTION};

        ?PK_MASTER -> %善恶模式
            DActorPKPoints = DActorMapInfo#p_map_role.pk_point,
            {DActorPKPoints > 18 orelse DActorMapInfo#p_map_role.gray_name,
             ?_LANG_FIGHT_ENEMY_PK_MASTER}
    end.

judge_pk_mode_friend(SrcActorMode, SActorID, SrcActorMapInfo, ActorID) ->
    case SActorID =:= ActorID of
        true ->
            {true, ?_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET};
        _ ->
            case mod_map_actor:get_actor_mapinfo(ActorID, role) of
                undefined ->
                    {false, ?_LANG_SYSTEM_ERROR};

                ActorMapInfo ->
                    case SrcActorMode of
                        ?PK_PEACE ->
                            {true, ?_LANG_FIGHT_ENEMY_PK_PEACE};
                        ?PK_ALL ->
                            {true, ?_LANG_FIGHT_ENEMY_PK_PEACE};

                        ?PK_TEAM ->
                            {SrcActorMapInfo#p_map_role.team_id =/= 0 andalso
                             SrcActorMapInfo#p_map_role.team_id =:= ActorMapInfo#p_map_role.team_id,
                             ?_LANG_FIGHT_FRIEND_PK_TEAM};

                        ?PK_FAMILY ->
                            {SrcActorMapInfo#p_map_role.family_id =/= 0 andalso
                             SrcActorMapInfo#p_map_role.family_id =:= ActorMapInfo#p_map_role.family_id,
                             ?_LANG_FIGHT_FRIEND_PK_FAMILY};

                        ?PK_FACTION ->
                            {SrcActorMapInfo#p_map_role.faction_id =:= ActorMapInfo#p_map_role.faction_id,
                             ?_LANG_FIGHT_FRIEND_PK_FACTION};

                        ?PK_MASTER ->
                            ActorPKPoints = ActorMapInfo#p_map_role.pk_point,
                            {not (ActorPKPoints > 18 orelse ActorMapInfo#p_map_role.gray_name),
                             ?_LANG_FIGHT_FRIEND_PK_MASTER}
                    end
            end
    end.


%%累加基础的物理攻击力和法力攻击力
concat_to_effect_list(Effect, EffectList, SrcActorAttr) ->
    ?DEBUG("concat_to_effect_list, effect: ~w, effectlist: ~w", [Effect, EffectList]),
    #p_effect{calc_type=CalcType,
              value=Value,
              absolute_or_rate=RateType
             } = Effect,
    case CalcType =:= ?CALC_TYPE_BASE_PHY_ATTACK orelse CalcType =:= ?CALC_TYPE_BASE_MAGIC_ATTACK of
        true ->
            %%增加攻击力百分比
            case RateType =:= 2 of
                true ->
                    case CalcType =:= ?CALC_TYPE_BASE_PHY_ATTACK of
                        true ->
                            Value2 = trunc(SrcActorAttr#actor_fight_attr.max_phy_attack * Value / 10000);
                        false ->
                            Value2 = trunc(SrcActorAttr#actor_fight_attr.max_magic_attack * Value / 10000)
                    end;
                false ->
                    Value2 = Value
            end,
            case lists:keyfind(CalcType, #p_effect.calc_type, EffectList) of
                false ->
                    [Effect#p_effect{value=Value2}|EffectList];
                TmpEffect ->
                    TmpValue = TmpEffect#p_effect.value,
                    NewEffect =  TmpEffect#p_effect{value=Value2+TmpValue},
                    lists:keyreplace(CalcType, #p_effect.calc_type, EffectList, NewEffect)
            end;
        false ->
            [Effect|EffectList]
    end.


%%获取直接的普通攻击产生的效果
get_base_attack_effect(SrcActorAttr,Category) ->
    case Category of
        ?CATEGORY_WARRIOR ->
            CALCTYPE = ?CALC_TYPE_BASE_PHY_ATTACK,
            AttackValue =  mod_effect:get_actor_base_attack(SrcActorAttr,phy);
        ?CATEGORY_HUNTER ->
            CALCTYPE = ?CALC_TYPE_BASE_PHY_ATTACK,
            AttackValue =  mod_effect:get_actor_base_attack(SrcActorAttr,phy);
        ?CATEGORY_RANGER ->
            CALCTYPE = ?CALC_TYPE_BASE_MAGIC_ATTACK,
            AttackValue =  mod_effect:get_actor_base_attack(SrcActorAttr,magic);
        ?CATEGORY_DOCTOR ->
            CALCTYPE = ?CALC_TYPE_BASE_MAGIC_ATTACK,
            AttackValue =  mod_effect:get_actor_base_attack(SrcActorAttr,magic);
        ?CATEGORY_PET_PHY ->
            CALCTYPE = ?CALC_TYPE_BASE_PHY_ATTACK,
            AttackValue =  mod_effect:get_actor_base_attack(SrcActorAttr,phy);
        ?CATEGORY_PET_MAGIC ->
            CALCTYPE = ?CALC_TYPE_BASE_MAGIC_ATTACK,
            AttackValue =  mod_effect:get_actor_base_attack(SrcActorAttr,magic);
        _ ->
            CALCTYPE = ?CALC_TYPE_BASE_PHY_ATTACK,
            AttackValue =  mod_effect:get_actor_base_attack(SrcActorAttr,phy)
    end,

    Effect =
        #p_effect{
      calc_type = CALCTYPE,
      absolute_or_rate = 0, %%绝对值
      value = AttackValue,
      probability = 10000     %%100%触发
     },

    [Effect].





%%获取怪物战斗时的战斗方向
get_fight_dir(TX1, TY1, TX2, TY2) ->
    {PX1, PY1} = common_misc:get_iso_index_mid_vertex(TX1, 0, TY1),
    {PX2, PY2} = common_misc:get_iso_index_mid_vertex(TX2, 0, TY2),
    X = PX2 - PX1,
    Y = PY2 - PY1,
    AbsX = abs(X),
    AbsX2 = AbsX * 4,
    AbsY = abs(Y),
    AbsY2 = AbsY * 4,
    case X > 0 of
        true ->
            case Y > 0 of
                true->
                    case AbsY > AbsX of
                        true ->
                            case AbsY > AbsX2 of
                                true ->
                                    4;
                                false ->
                                    3
                            end;
                        false ->
                            case AbsX > AbsY2 of
                                true ->
                                    2;
                                false ->
                                    3
                            end
                    end;
                false ->
                    case AbsY > AbsX of
                        true ->
                            case AbsY > AbsX2 of
                                true ->
                                    0;
                                false ->
                                    1
                            end;
                        false ->
                            case AbsX > AbsY2 of
                                true ->
                                    2;
                                false ->
                                    1
                            end
                    end
            end;
        false ->
            case Y > 0 of
                true->
                    case AbsY > AbsX of
                        true ->
                            case AbsY > AbsX2 of
                                true ->
                                    4;
                                false ->
                                    5
                            end;
                        false ->
                            case AbsX > AbsY2 of
                                true ->
                                    6;
                                false ->
                                    5
                            end
                    end;
                false ->
                    case AbsY > AbsX of
                        true ->
                            case AbsY > AbsX2 of
                                true ->
                                    0;
                                false ->
                                    7
                            end;
                        false ->
                            case AbsX > AbsY2 of
                                true ->
                                    6;
                                false ->
                                    7
                            end
                    end
            end
    end.


%%战斗后跟换目标的方向
update_actor_pos_after_fight({_PetID,RoleID}, pet, Dir) ->
    SrcPos = mod_map_pet:get_pet_pos_from_owner(RoleID),
    SrcPos#p_pos{dir=Dir};
update_actor_pos_after_fight(SrcActorID, SrcActorType, Dir) ->

    case mod_map_actor:get_actor_pos(SrcActorID, SrcActorType) of
        undefined ->
            undefined;

        SrcPos ->              
            NewPos = SrcPos#p_pos{dir=Dir},
            mod_map_actor:set_actor_pos_after_dir_change(SrcActorID, SrcActorType, NewPos),
            NewPos
    end.


%%计算是否闪避
judge_miss_attack(SActorAttr, DActorAttr, SkillEffectList, Flag) ->
    case length(SkillEffectList) > 0 orelse Flag =:= true of
        false ->
            false;
        true ->
            #actor_fight_attr{hit_rate=SHitRate} = SActorAttr,
            #actor_fight_attr{miss=DMiss} = DActorAttr,
            Miss = 10000 - (SHitRate-DMiss),
            Rand = random:uniform(10000),
            Miss >= Rand
    end.

%%
judge_is_invincible(#p_map_role{role_id=RoleID,state=?ROLE_STATE_ZAZEN,state_buffs=Buffs}) ->
    %%如果在喝了酒在篝火不边加经验就是不能攻击的
    case lists:keyfind(1035, #p_actor_buf.buff_type, Buffs) of
        false ->
            false;
        _ ->
            mod_map_bonfire:change_range_has_bonfire(RoleID)
    end;
judge_is_invincible(#p_map_role{state=State}) ->
    ?DEBUG("judge_is_invincible state:~w~n",[State]),
    false;
judge_is_invincible(_) ->
    false.

get_dest_type(ActorType) ->
    case ActorType of
        role ->
            ?TYPE_ROLE;
        monster ->
            ?TYPE_MONSTER;
        pet ->
            ?TYPE_PET;
        ybc ->
            ?TYPE_YBC;
        server_npc ->
            ?TYPE_SERVER_NPC;
        _ ->
            ?TYPE_OTHER
    end.

%%是否无敌
if_actor_unbeatable(BuffList, _ActorType) ->
    lists:foldl(
      fun(Buff, Acc) ->
              Type = Buff#p_actor_buf.buff_type,
              {ok, Func} = mod_skill_manager:get_buff_func_by_type(Type),

              case Func of
                  unbeatable ->
                      true;
                  add_rigid ->%%特殊的无敌
                      true;
                  _ ->
                      Acc
              end
      end, false, BuffList).

if_take_effect(Rate, Acc, Effect,SrcActorAttr) ->
    case Rate of 
        10000 ->
            concat_to_effect_list(Effect, Acc, SrcActorAttr);

        _ -> 
            Rand = random:uniform(10000),
            case Rand =< Rate of
                true ->
                    concat_to_effect_list(Effect, Acc, SrcActorAttr);
                false ->
                    Acc
            end
    end.

%%如果技能是作用于自己的，那么无效
buf_to_buf(_SrcActorBuff, SkillBufList, _Level, _SrcActorType, _SrcActorID, _SrcActorID) ->
    SkillBufList;
buf_to_buf(SrcActorBuff, SkillBufList, Level, _SrcActorType, _SrcActorID, _ActorID) ->
    lists:foldl(
      fun(Buff, Acc) ->
              #p_actor_buf{buff_id=BuffID, buff_type=BuffType} = Buff,
              {ok, Detail} = mod_skill_manager:get_buf_detail(BuffID),
              {ok, Func} = mod_skill_manager:get_buff_func_by_type(BuffType),

              #p_buf{value=Value} = Detail,

              case Func of

                  %%定身，给自己攻击对象增加一个额外的定向BUFF
                  let_actor_stop ->
                      case if_active(Value) of
                          true ->
                              BuffID2 = 542 + Level,
                              {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID2),
                              [BuffDetail|Acc];

                          false ->
                              Acc
                      end;
                  _ ->
                      Acc
              end
      end, SkillBufList, SrcActorBuff).

if_active(Value) ->
    Rate = random:uniform(10000),
    Rate =< Value.

%%暂时这样写。。。
buff_by_equip(_SActorAttr, SkillBuffList, _ActorType, _SActorID, _SActorID, _DActorAttr) ->
    SkillBuffList;
buff_by_equip(SrcActorAttr, SkillBuffList, role, _SrcActorID, _ActorID, DActorAttr) ->
    Dizzy = SrcActorAttr#actor_fight_attr.dizzy,
    Poisoning = SrcActorAttr#actor_fight_attr.poisoning,
    Freeze = SrcActorAttr#actor_fight_attr.freeze,
    DizzyResist = DActorAttr#actor_fight_attr.dizzy_resist,
    PoisoningResist = DActorAttr#actor_fight_attr.poisoning_resist,
    FreezeResist = DActorAttr#actor_fight_attr.freeze_resist,

    %%眩晕
    SkillBuffList2 =
        case if_active(Dizzy-DizzyResist) of
            false ->
                SkillBuffList;
            _ ->
                {ok, BuffDetail} = mod_skill_manager:get_buf_detail(10515),
                [BuffDetail|SkillBuffList]
        end,

    %%中毒
    SkillBuffList3 =
        case if_active(Poisoning-PoisoningResist) of
            false ->
                SkillBuffList2;
            _ ->
                {ok, BuffDetail2} = mod_skill_manager:get_buf_detail(10517),
                [BuffDetail2|SkillBuffList2]
        end,

    %%冰冻
    SkillBuffList4 =
        case if_active(Freeze-FreezeResist) of
            false ->
                SkillBuffList3;
            _ ->
                {ok, BuffDetail3} = mod_skill_manager:get_buf_detail(10516),
                [BuffDetail3|SkillBuffList3]
        end,
    SkillBuffList4;
buff_by_equip(_SActorAttr, SkillBuffList, _ActorType, _SActorID, _DActorID, _DActorAttr) ->
    SkillBuffList.

detail_to_actorbuff(SrcActorID, SrcActorType, DActorID, DActorType, SkillBuffList) ->
    lists:map(
      fun(BuffDetail) ->
              get_actor_buff(SrcActorID, SrcActorType, DActorID, DActorType, BuffDetail)
      end, SkillBuffList).

get_actor_buff(SrcActorID, SrcActorType, DActorID, DActorType, BuffDetail) ->
    #p_buf{
            buff_id=BuffID,
            last_value=LastValue,
            value=Value,
            buff_type=BuffType
          } = BuffDetail,

    BeginTime = common_tool:now(),

    #p_actor_buf{
                  buff_id=BuffID,
                  buff_type=BuffType,
                  actor_id=DActorID,
                  actor_type=mod_fight:get_dest_type(DActorType),
                  from_actor_id=SrcActorID,
                  from_actor_type=mod_fight:get_dest_type(SrcActorType),
                  value=Value,
                  start_time=BeginTime,
                  end_time=BeginTime+LastValue,
                  remain_time=LastValue
                }.

%%伤害反射
hurt_rebound(SrcActorID, SrcActorType, role, DActorAttr, Value) ->
    #actor_fight_attr{actor_id=DActorID, actor_name=DActorName, hurt_rebound=HurtRebound} = DActorAttr,
    ?DEBUG("hurt_rebound, ~w", [HurtRebound]),
    
    case HurtRebound =:= 0 of
        false ->
            mod_effect:reduce_hp(common_tool:ceil(Value*HurtRebound/10000), SrcActorType, SrcActorID, DActorName, DActorID, role),
            MapState = mgeem_map:get_state(),
            mod_effect:broadcast_skill_effect(SrcActorID, SrcActorType, DActorID, role, common_tool:ceil(Value*HurtRebound/10000), MapState);
        _ ->
            ok
    end;
hurt_rebound(_SrcActorID, _SrcActorType, _DactorType, _DActorAttr, _Value) ->
    ignore.
        

%%安全区判断
%%在绝对安全区内无法战斗，也无法攻击在绝对安全区内的人
%%相对安全区内无法战斗，但本国玩家可以攻击在安全区内的外国玩家
check_fight_pos(SPos, DPos, DFactionID, MapID) ->
    ?DEBUG("ckeck_fight_pos, spos: ~w, dpos: ~w", [SPos, DPos]),
    SSafe = get({SPos#p_pos.tx, SPos#p_pos.ty}),
    DSafe = get({DPos#p_pos.tx, DPos#p_pos.ty}),

    case SSafe =:= safe orelse SSafe =:= absolute_safe of
        true ->
            {false, ?_LANG_FIGHT_IN_SAFE_AREA};

        _ ->
            case (DSafe =:= safe andalso common_misc:if_in_self_country(DFactionID, MapID))
                orelse DSafe =:= absolute_safe
            of
                true ->
                    {false, ?_LANG_FIGHT_TARGET_IN_SAFE_AREA};

                _ ->
                    true
            end
    end.

get_buff_id_list(Buffs) ->
    lists:map(
      fun(Buff) ->
              Buff#p_buf.buff_id
      end, Buffs).

get_effect_id_list(Effects) ->
    lists:map(
      fun(Effect) ->
              Effect#p_effect.effect_id
      end, Effects).

get_effect_actor(TX, TY, TargetArea, EffectType, SActorID, SActorType, PKMode, MapID, MapInfo) ->
    IDList = get_actors_around_map_grid(TX, TY, TargetArea),
    ActorList =  get_target_actor_in_area2(IDList),
    lists:foldr(
      fun({ActorType, ActorID}, Acc) ->
              %%PK模式判断
              case catch judge_pk_mode(EffectType, SActorID, SActorType, PKMode, MapInfo,
                                       ActorType, ActorID, MapID)
              of
                  {true, _} ->
                      [{ActorID, ActorType}|Acc];
                  {false, _} ->
                      Acc;
                  _ ->
                      Acc
              end
      end, [], ActorList).

int_type_to_atom_type(ActorType) ->
    case ActorType of
        ?TYPE_PET ->
            pet;
        ?TYPE_ROLE ->
            role;
        ?TYPE_YBC ->
            ybc;
        ?TYPE_MONSTER ->
            monster;
        ?TYPE_SERVER_NPC ->
            server_npc;
        _ ->
            undefined
    end.
