%% Author: QingliangCn
%% Created: 2010-4-23
%% Description: TODO: Add description to mod_effect
-module(mod_effect).
-include("mgeem.hrl").

-export([
         get_actor_base_attack/2,
         get_actor_base_defence/2,
         calc_effect_final_value/9,
         apply_effect/7,
         calc_die_together/2,
         reduce_hp/6,
         broadcast_skill_effect/6,
         broadcast_skill_effect/5,
         has_buff_die_together/1
        ]).


%% --------------------------------------------------------------------
%% APIs For mod_fight
%% --------------------------------------------------------------------
get_actor_base_attack(ActorAttr,Type) ->
    case Type of
        phy ->
            get_actor_phy_attack(ActorAttr);
        magic ->
            get_actor_magic_attack(ActorAttr)
    end.

get_actor_base_defence(ActorAttr,Type) ->
    case Type of
        phy ->
            get_actor_phy_defence(ActorAttr);
        magic ->
            get_actor_magic_defence(ActorAttr)
    end.

calc_effect_final_value(SActorAttr, SActorID, SActorType, Effect, DActorAttr, DActorID, DActorType, BuffList, SkillID) ->
    CalcType = Effect#p_effect.calc_type,

    case CalcType of
        
        %%攻击力造成的伤害（法攻或物攻）
        ?CALC_TYPE_BASE_PHY_ATTACK ->
            calc_reduce_hp_by_phy(SActorID, SActorType, SActorAttr, DActorID, DActorType, DActorAttr, Effect, BuffList);
        ?CALC_TYPE_BASE_MAGIC_ATTACK ->
            calc_reduce_hp_by_magic(SActorID, SActorType, SActorAttr, DActorID, DActorType, DActorAttr, Effect, BuffList);

        %%绝对伤害，例如有些技能附加多少多少伤害
        ?CALC_TYPE_ABSOLUTE_PHY_ATTACK ->
            calc_reduce_hp_by_phy_absolute(SActorID, SActorType, SActorAttr, DActorID, DActorType, DActorAttr, Effect, BuffList);
        ?CALC_TYPE_ABSOLUTE_MAGIC_ATTACK ->
            calc_reduce_hp_by_magic_absolute(SActorID, SActorType, SActorAttr, DActorID, DActorType, DActorAttr, Effect, BuffList);

        %%重击
        ?CALC_TYPE_DOUBLE_ATTACK ->
            calc_add_double_attack_rate(Effect, SActorAttr);

        %%驱散
        ?CALC_TYPE_DISPEL_BUFF ->
            calc_dispel_buff(DActorID, DActorType, SActorAttr, SActorID, SActorType, BuffList);

        %%复活
        ?CALC_TYPE_RELIVE ->
            calc_relive(DActorID, DActorType, Effect, SActorAttr);

        %%瞬移
        ?CALC_TYPE_TRANSFER ->
            calc_transfer(Effect, SActorAttr, SActorID, SActorType);

        %%冲锋
        ?CALC_TYPE_CHARGE ->
            calc_charge(DActorID, DActorType, SActorAttr, SActorID, SActorType);

        %%吸魔
        ?CALC_TYPE_ABSORB_MP ->
            calc_absorb_mp(SActorID, SActorType, SActorAttr, DActorID, DActorType, Effect, SkillID);

        %%下马
        ?CALC_TYPE_MOUNT_DOWN ->
            calc_mount_down(SActorID, SActorType, SActorAttr, DActorID, DActorType, Effect, SkillID);
        ?CALC_TYPE_ADD_HP_WITH_PET_HP ->
            calc_add_hp_with_pet_hp(SActorID, SActorType, SActorAttr, DActorID, DActorType, Effect, SkillID);
        ?CALC_TYPE_ADD_MP_WITH_PET_HP ->
            calc_add_mp_with_pet_hp(SActorID, SActorType, SActorAttr, DActorID, DActorType, Effect, SkillID);
       %%咆哮
        ?CALC_TYPE_PAO_XIAO ->
            calc_pao_xiao(SActorID, SActorType, SActorAttr, DActorID, DActorType, Effect, SkillID);
        %%驱散有害的BUFF
        ?CALC_TYPE_DISPEL_DEBUFF ->
            calc_dispel_debuff(SActorID, SActorType, SActorAttr, DActorID, DActorType, Effect, SkillID);
        _ ->
            {error, no_effect}
    end.

apply_effect(ResultType,ResultValue,ActorType,ActorID,SrcActorAttr,SrcActorID, SrcActorType) ->
    SrcActorName = SrcActorAttr#actor_fight_attr.actor_name,
    ?DEBUG("ResultType ~w = ~w~n",[ResultType,?RESULT_TYPE_REDUCE_HP]),
    case ResultType of
        ?RESULT_TYPE_REDUCE_HP ->
            reduce_hp(ResultValue, ActorType, ActorID, SrcActorName, SrcActorID, SrcActorType);
        ?RESULT_TYPE_ADD_HP ->
            add_hp(ResultValue, ActorType, ActorID, SrcActorName, SrcActorID);
        ?RESULT_TYPE_REDUCE_MP ->
            reduce_mp(ResultValue, ActorType, ActorID, SrcActorName, SrcActorID, SrcActorType);
        ?RESULT_TYPE_ADD_MP ->
             add_mp(ResultValue, ActorType, ActorID, SrcActorName, SrcActorID);
        _ ->
            nil
    end.

%% --------------------------------------------------------------------
%% Internal Functions
%% --------------------------------------------------------------------
calc_reduce_hp_by_phy(SActorID, SActorType, SActorAttr, DActorID, DActorType, DActorAttr,
                      Effect, BuffList) ->

    %%攻取攻击伤害值以及被攻击方的防御力及防御抗性
    %% add by caochuncheng 怪物基础攻击作用，取目标的最高防御来计算
    #p_effect{value=AttackValue} = Effect,
    #actor_fight_attr{phy_defence=PhyDefence, 
                      phy_anti=PhyAnti, 
                      magic_defence=MagicDefence, 
                      magic_anti=MagicAnti,
                      equip_score=DEquipScore, 
                      spec_score_two=DSpecScore2} = DActorAttr,
    case SActorType =:= mod_fight:int_type_to_atom_type(?TYPE_MONSTER) 
        andalso (DActorType =:= mod_fight:int_type_to_atom_type(?TYPE_PET)
                 orelse DActorType =:= mod_fight:int_type_to_atom_type(?TYPE_ROLE) ) of
        true ->
            DActorDefence = if MagicDefence > PhyDefence -> MagicDefence; true -> PhyDefence end,
            DActorAnti = if MagicAnti > PhyAnti -> MagicAnti; true -> PhyAnti end;
         _->
             DActorDefence = PhyDefence, 
             DActorAnti = PhyAnti
    end,
    #actor_fight_attr{phy_hurt_rate=PhyHurtRate, 
                      no_defence=NoDefence, 
                      double_attack=DoubleAttack,
                      equip_score=SEquipScore,
                      spec_score_one=SSpecScore1
                     } = SActorAttr,

    case get_fight_actor_level(SActorID, SActorType, DActorID, DActorType) of
        {error, Reason} ->
            {error, Reason};

        {ok, SActorLevel, DActorLevel} ->
            %%计算伤害值
            {ResultValue, IfNoDefence} = calc_harm_value(AttackValue, DActorDefence, NoDefence, SActorLevel, DActorLevel, SSpecScore1,
                                                         SEquipScore, DEquipScore, DSpecScore2),
            %%BUFF影响
            ResultValue2 = calc_result_after_buff(ResultValue, BuffList, DActorType, 1),

            %%攻击方伤害加深、被攻击方抗性及等级压制，怪物暂时还没伤害加深属性
            case SActorType =:= role of
                true ->
                    case DActorType of
                        ybc ->
                            ResultValue3 =  ResultValue2*(1+PhyHurtRate/10000)*(1-DActorAnti/10000);
                        _ ->
                            ResultValue3 = ResultValue2*(1+PhyHurtRate/10000)*(1-DActorAnti/10000) 
                                * get_level_press_coefficient(SActorLevel, DActorLevel, SActorType, DActorType)
                    end;
                false ->
                    ResultValue3 = ResultValue2*(1-DActorAnti/10000)*get_level_press_coefficient(SActorLevel, DActorLevel, SActorType, DActorType)
            end,
            %%是否重击，破甲跟重击不重叠
            ResultValue4 = if_double_attack(DoubleAttack, IfNoDefence, ResultValue3),
            case ResultValue3 =:= ResultValue4 of
                true ->
                    IsDoubleAttack = false;
                _ ->
                    IsDoubleAttack = true
            end,
            %% 因等级压制造成0血，最小伤害1
            case ResultValue4 =< 0 of
                true ->
                    ResultValue5 = 1;
                _ ->
                    ResultValue5= ResultValue4
            end,
            {ok, ?RESULT_TYPE_REDUCE_HP, ResultValue5, IsDoubleAttack}
    end.

calc_reduce_hp_by_magic(SActorID, SActorType, SActorAttr, DActorID, DActorType, DActorAttr, 
                        Effect, BuffList) ->

    #p_effect{value=AttackValue} = Effect,
    %% add by caochuncheng 怪物基础攻击作用，取目标的最高防御来计算
    #actor_fight_attr{phy_defence=PhyDefence, 
                      phy_anti=PhyAnti, 
                      magic_defence=MagicDefence, 
                      magic_anti=MagicAnti,
                      spec_score_two=DSpecScore2,
                      equip_score=DEquipScore} = DActorAttr,
    case SActorType =:= mod_fight:int_type_to_atom_type(?TYPE_MONSTER) 
        andalso (DActorType =:= mod_fight:int_type_to_atom_type(?TYPE_PET)
                 orelse DActorType =:= mod_fight:int_type_to_atom_type(?TYPE_ROLE) ) of
        true ->
            DActorDefence = if MagicDefence > PhyDefence -> MagicDefence; true -> PhyDefence end,
            DActorAnti = if MagicAnti > PhyAnti -> MagicAnti; true -> PhyAnti end;
        _->
            DActorDefence = MagicDefence, 
            DActorAnti = MagicAnti
    end,
    #actor_fight_attr{magic_hurt_rate=MagHurtRate, 
                      no_defence=NoDefence, 
                      double_attack=DoubleAttack,
                      equip_score=SEquipScore,
                      spec_score_one=SSpecScore1} = SActorAttr,

    case get_fight_actor_level(SActorID, SActorType, DActorID, DActorType) of
        {error, Reason} ->
            {error, Reason};

        {ok, SActorLevel, DActorLevel} ->

            {ResultValue, IfNoDefence} = calc_harm_value(AttackValue, DActorDefence, NoDefence, SActorLevel, DActorLevel, SSpecScore1,
                                                         SEquipScore, DEquipScore, DSpecScore2),

            ResultValue2 = calc_result_after_buff(ResultValue, BuffList, DActorType, 2),

            case SActorType =:= role of
                true ->
                    ResultValue3 = ResultValue2*(1+MagHurtRate/10000)*(1-DActorAnti/10000)*get_level_press_coefficient(SActorLevel, DActorLevel, SActorType, DActorType);
                false ->
                    ResultValue3 = ResultValue2*(1-DActorAnti/10000)*get_level_press_coefficient(SActorLevel, DActorLevel, SActorType, DActorType)
            end,
            ResultValue4 = if_double_attack(DoubleAttack, IfNoDefence, ResultValue3),
            case ResultValue4 =:= ResultValue3 of
                true ->
                    IsDoubleAttack = false;
                _ ->
                    IsDoubleAttack = true
            end,
            case ResultValue4 =< 0 of
                true ->
                    ResultValue5 = 1;
                _ ->
                    ResultValue5 = ResultValue4
            end,

            {ok, ?RESULT_TYPE_REDUCE_HP, ResultValue5, IsDoubleAttack}
    end.

calc_reduce_hp_by_phy_absolute(SActorID, SActorType, SActorAttr, DActorID, DActorType, DActorAttr, 
                               Effect, BuffList) ->

    #p_effect{value=AttackValue} = Effect,
    PhyAnti = DActorAttr#actor_fight_attr.phy_anti,
    PhyHurtRate = SActorAttr#actor_fight_attr.phy_hurt_rate,
    DoubleAttack = SActorAttr#actor_fight_attr.double_attack,

    case get_fight_actor_level(SActorID, SActorType, DActorID, DActorType) of
        {error, Reason} ->
            {error, Reason};

        {ok, SActorLevel, DActorLevel} ->

            ResultValue = calc_result_after_buff(AttackValue, BuffList, DActorType, 1),

            case SActorType =:= role of
                true ->
                    ResultValue2 = ResultValue*(1+PhyHurtRate/10000)*(1-PhyAnti/10000)*get_level_press_coefficient(SActorLevel, DActorLevel, SActorType, DActorType);
                false ->
                    ResultValue2 = ResultValue*(1-PhyAnti/10000)*get_level_press_coefficient(SActorLevel, DActorLevel, SActorType, DActorType)
            end, 
            ResultValue3 = if_double_attack(DoubleAttack, false, ResultValue2),
            case ResultValue2 =:= ResultValue3 of
                true ->
                    IsDoubleAttack = false;
                _ ->
                    IsDoubleAttack = true
            end,
            case ResultValue3 =< 0 of
                true ->
                    ResultValue4 = 1;
                _ ->
                    ResultValue4 = ResultValue3
            end,

            {ok, ?RESULT_TYPE_REDUCE_HP, ResultValue4, IsDoubleAttack}
    end.

calc_reduce_hp_by_magic_absolute(SActorID, SActorType, SActorAttr, DActorID, DActorType, DActorAttr, 
                                 Effect, BuffList) ->

    #p_effect{value=AttackValue} = Effect,
    MagicAnti = DActorAttr#actor_fight_attr.magic_anti,
    MagHurtRate = SActorAttr#actor_fight_attr.magic_hurt_rate,
    DoubleAttack = SActorAttr#actor_fight_attr.double_attack,

    case get_fight_actor_level(SActorID, SActorType, DActorID, DActorType) of
        {error, Reason} ->
            {error, Reason};

        {ok, SActorLevel, DActorLevel} ->

            ResultValue = calc_result_after_buff(AttackValue, BuffList, DActorType, 2),

            case SActorType =:= role of
                true ->
                    ResultValue2 = ResultValue*(1+MagHurtRate/10000)*(1-MagicAnti/10000)*get_level_press_coefficient(SActorLevel, DActorLevel, SActorType, DActorType);
                false ->
                    ResultValue2 = ResultValue*(1-MagicAnti/10000)*get_level_press_coefficient(SActorLevel, DActorLevel, SActorType, DActorType)
            end,
            ResultValue3 = if_double_attack(DoubleAttack, false, ResultValue2),
            case ResultValue2 =:= ResultValue3 of
                true ->
                    IsDoubleAttack = false;
                _ ->
                    IsDoubleAttack = true
            end,
            case ResultValue3 =< 0 of
                true ->
                    ResultValue4 = 1;
                _ ->
                    ResultValue4 = ResultValue3
            end,
            {ok, ?RESULT_TYPE_REDUCE_HP, ResultValue4, IsDoubleAttack}
    end.

calc_add_double_attack_rate(Effect,SrcActorAttr) ->
    #p_effect{value = AddRate} = Effect,
    DoubleAttackRate = SrcActorAttr#actor_fight_attr.double_attack,
    NewSrcAttr = SrcActorAttr#actor_fight_attr{double_attack = DoubleAttackRate + AddRate},
    {ok,NewSrcAttr}.

calc_dispel_buff(ActorID, ActorType, SrcActorAttr, SrcActorID, SrcActorType, _BuffList) ->
    mod_buff:dispel_actor_fight_buffs(SrcActorID, SrcActorType, ActorID, ActorType),
    {ok, SrcActorAttr}.

calc_relive(ActorID,ActorType,Effect,SrcActorAttr) ->
    #p_effect{ value = ResumRate} = Effect,
    case ActorType of
        role ->
            mod_role2:do_relive(?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_RELIVE, ActorID, {?RELIVE_TYPE_SKILL, ResumRate});
        _ ->
            nil
    end,
    {ok,SrcActorAttr}.           

calc_transfer(Effect,SrcActorAttr,SrcActorID, SrcActorType) ->
    #p_effect{ value = DistRound} = Effect,
    self() ! {mod_map_role, {skill_transfer,SrcActorID, SrcActorType,DistRound}},
    {ok,SrcActorAttr}.      

calc_charge(ActorID,ActorType,SrcActorAttr,SrcActorID, SrcActorType) ->
    mod_map_role:do_skill_charge(SrcActorID, SrcActorType, ActorID, ActorType, mgeem_map:get_state()),
    {ok,SrcActorAttr}.

get_actor_magic_attack(RoleAttr) ->
    Luck = common_tool:random(1, 100) + RoleAttr#actor_fight_attr.luck,
    MaxMA = RoleAttr#actor_fight_attr.max_magic_attack,
    MinMA = RoleAttr#actor_fight_attr.min_magic_attack,

    if 
        Luck > 100 ->
            MagicAttack = MaxMA;
        Luck < 1 ->
            MagicAttack = MinMA;
        true ->
            case MinMA > MaxMA  of
                true ->
                    MagicAttack =  MaxMA;
                false ->
                    MagicAttack = common_tool:random(MinMA, MaxMA)
            end
    end,

    MagicAttack.


get_actor_magic_defence(RoleAttr) ->
    RoleAttr#actor_fight_attr.magic_defence.


get_actor_phy_attack(RoleAttr) ->
    Luck = random:uniform(100) + RoleAttr#actor_fight_attr.luck,
    MaxPA = RoleAttr#actor_fight_attr.max_phy_attack,
    MinPA = RoleAttr#actor_fight_attr.min_phy_attack,

    if 
        Luck > 100 ->
            PhyAttack = MaxPA;
        Luck < 1 ->
            PhyAttack = MinPA;
        true ->
            Random = random:uniform(MaxPA+1-MinPA),
            PhyAttack = MinPA + Random - 1
    end,

    PhyAttack.


get_actor_phy_defence(RoleAttr) ->
    RoleAttr#actor_fight_attr.phy_defence.


get_not_de_defence_rate() ->
    common_tool:random(500, 700) * 0.0001.


calc_harm_value(AttackValue, Defence, NoDefence, SActorLevel, DActorLevel, SSpecScore1,
                SEquipScore, DEquipScore, DSpecScore2) ->
    IfNoDefence = if_active(NoDefence),

    case IfNoDefence of
        true ->
            Defence2 = 0;

        _ ->
            Defence2 = Defence
    end, 
    %% 精炼附加伤害1
    RefiningAddHurt1 = get_refining_add_hurt_1(SActorLevel, DActorLevel, SSpecScore1, SEquipScore, DEquipScore),
    case RefiningAddHurt1 >= 3000 of
        true ->
            RefiningAddHurt12 = 3000;
        _ ->
            RefiningAddHurt12 = RefiningAddHurt1
    end,
    %% 精炼附加伤害2
    RefiningAddHurt2 = get_refining_add_hurt_2(SEquipScore, DSpecScore2),

    case AttackValue > Defence2 of
        %%破防
        true ->
            {(AttackValue-Defence2)+AttackValue*get_not_de_defence_rate()+RefiningAddHurt12+RefiningAddHurt2, IfNoDefence};
        %%不破防
        false ->
            {AttackValue*(AttackValue/Defence2)*get_not_de_defence_rate()+RefiningAddHurt12+RefiningAddHurt2, IfNoDefence}
    end.


reduce_hp(ResultValue, ActorType, ActorID, SrcActorName, SrcActorID, SrcActorType) ->
    case ActorType of
        role ->
            MapState = mgeem_map:get_state(),
            %% 打断采集
            mod_map_collect:stop_collect(ActorID,?_LANG_COLLECT_BREAK),
            mod_item:stop_use_special_item(ActorID),
            %% 减血
            mod_map_role:do_role_reduce_hp(ActorID, ResultValue, SrcActorName, SrcActorID, SrcActorType, MapState);
        monster ->
            mod_map_monster:reduce_hp(ActorID,ResultValue, SrcActorID,SrcActorType);
        server_npc ->
            mod_server_npc:reduce_hp(ActorID,ResultValue, SrcActorID,SrcActorType);
        ybc ->
            mod_map_ybc:reduce_hp(ActorID, ResultValue, SrcActorID, SrcActorType);
         pet ->
            mod_map_pet:pet_reduce_hp(ActorID, ResultValue,SrcActorID, SrcActorType);
        _ ->
            nil
    end.


add_hp(ResultValue, ActorType, ActorID, _SrcActorName, SrcActorID) ->
    case ActorType of
        role ->
            mod_map_role:do_role_add_hp(ActorID, ResultValue,SrcActorID);
        monster ->
            nil;
        server_npc ->
            nil;
        pet ->
            nil;
        _ ->
            nil
    end.


reduce_mp(_ResultValue, ActorType, _ActorID, _SrcActorName, _SrcActorID, _SrcActorType) ->
    case ActorType of
        _ ->
            nil
    end.


add_mp(ResultValue, ActorType, ActorID, _SrcActorName, SrcActorID) ->
    case ActorType of
        role ->
            mod_map_role:do_role_add_mp(ActorID, ResultValue,SrcActorID);
        _ ->
            nil
    end.

%%type: 1、物理攻击，2、魔法攻击
calc_result_after_buff(ResultValue, BuffList, ActorType, Type) ->
    ?DEV("calc_result_after_buff, bufflist: ~w, actortype: ~w", [BuffList, ActorType]),

    lists:foldl(
      fun(Buff, Acc) ->
              #p_actor_buf{buff_id=BuffID, buff_type=BuffType} = Buff,

              {ok, Detail} = mod_skill_manager:get_buf_detail(BuffID),
              {ok, Func} = mod_skill_manager:get_buff_func_by_type(BuffType),

              #p_buf{value=Value, absolute_or_rate=_ValueType} = Detail,

              ?DEBUG("calc_result_after_buff, func: ~w, value: ~w", [Func, Value]),
              case Func of

                  %%物理免疫
                  phy_immune ->
                      case Type of
                          1 -> 
                              0;
                          2 ->
                              Acc
                      end;

                  %%魔法免疫
                  magic_immune ->
                      case Type of
                          1 ->
                              Acc;
                          2 ->
                              0
                      end;

                  %%增加物理伤害
                  add_phy_hurt ->
                      case Type of
                          2 ->
                              Acc;
                          1 ->
                              ResultValue*(1+Value/10000)
                      end;
                  _ ->
                      Acc
              end
      end, ResultValue, BuffList).

%%获取攻击双方等级
get_fight_actor_level(SActorID, SActorType, DActorID, DActorType) ->
    case get_actor_level(SActorID, SActorType) of
        {error, Reason} ->
            {error, Reason};
        
        {ok, SActorLevel} ->
            case get_actor_level(DActorID, DActorType) of
                {error, Reason} ->
                    {error, Reason};
                
                {ok, DActorLevel} ->
                    {ok, SActorLevel, DActorLevel}
            end
    end.

%%获取ACTOR等级
get_actor_level(ActorID, ActorType) ->
    case ActorType of
        role -> 
            case mod_map_actor:get_actor_mapinfo(ActorID, role) of
                undefined ->
                    {error, system_error};
                
                RoleMapInfo ->
                    {ok, RoleMapInfo#p_map_role.level}
            end;
        
        monster ->
            case mod_map_monster:get_monster_state(ActorID) of
                undefined ->
                    {error, system_error};
                
                MonsterState ->
                    MonsterInfo = MonsterState#monster_state.monster_info,
                    #p_monster{typeid=TypeID} = MonsterInfo,
                    [MonsterBaseInfo] = common_config_dyn:find(monster, TypeID),
                    {ok, MonsterBaseInfo#p_monster_base_info.level}
            end;
         server_npc ->
            case mod_server_npc:get_server_npc_state(ActorID) of
                undefined ->
                    {error, system_error};
                ServerNpcState ->
                    ServerNpcInfo =ServerNpcState#server_npc_state.server_npc_info,
                    #p_server_npc{type_id=TypeID} = ServerNpcInfo,
                    [ServerNpcBaseInfo] = common_config_dyn:find(server_npc, TypeID),
                    {ok, ServerNpcBaseInfo#p_server_npc_base_info.level}
            end;
        ybc ->
            {ok, 100};
        pet ->
             case mod_map_actor:get_actor_mapinfo(ActorID, pet) of
                undefined ->
                    {error, system_error};
                
                RetMapInfo ->
                    {ok, RetMapInfo#p_map_pet.level}
            end
    end.

%%获取等级压制系数
get_level_press_coefficient(SActorLevel, DActorLevel, SActorType, DActorType) ->
    if
        SActorType =:= role andalso DActorType =:= role ->
            1;
        SActorType =:= role andalso DActorType =:= server_npc ->
            1;
        SActorType =:= server_npc andalso DActorType =:= role ->
            1;
        true ->
            Coefficient = 1+((SActorLevel-DActorLevel)*0.01),
            case Coefficient < 0 of
                true ->
                    0;
                _ ->
                    Coefficient
            end
    end.

if_active(Rate) ->
    R = common_tool:random(1, 10000),
    R =< Rate.

if_double_attack(DoubleAttack, IfNoDefence, ResultValue) ->
    case IfNoDefence of
        true ->
            ResultValue;
        _ ->
            case if_active(DoubleAttack) of
                true ->
                    ResultValue * 2;
                _ ->
                    ResultValue
            end
    end.

-define(die_together_skill_id, 11103006).
-define(die_together_buff_type, 1033).

%%同归于尽。。。
calc_die_together(MapInfo, MapState) ->
    #p_map_role{role_id=RoleID, role_name=RoleName, max_hp=MaxHP, pos=Pos} = MapInfo,
    #map_state{mapid=MapID} = MapState,
    #p_pos{tx=TX, ty=TY} = Pos,

    {ok, #p_role_base{pk_mode=PKMode}} = mod_map_role:get_role_base(RoleID),

    %%给周围8个格子的敌人造成最大生命20%的伤害
    EffectActor = mod_fight:get_effect_actor(TX, TY, 3, ?SKILL_EFFECT_TYPE_ENEMY, RoleID, role, PKMode, MapID, MapInfo),
    ?DEBUG("calc_perish, effectactor: ~w", [EffectActor]),

    ResultList =
        lists:foldl(
          fun({ActorID, ActorType}, Acc) ->
                  ResultValue = common_tool:ceil(MaxHP*0.2),
                  reduce_hp(ResultValue, ActorType, ActorID, RoleName, RoleID, role),
                  [{ActorID, ActorType, ?RESULT_TYPE_REDUCE_HP, ResultValue, []}|Acc]
          end, [], EffectActor),

    broadcast_skill_effect(RoleID, role, ?die_together_skill_id, ResultList, MapState).

%% @doc 是否有同归于尽BUFF
has_buff_die_together([]) ->
    false;
has_buff_die_together([Buff|T]) ->
    #p_actor_buf{buff_type=BuffType} = Buff,
    case BuffType of
        ?die_together_buff_type ->
            true;
        _ ->
            has_buff_die_together(T)
    end.

broadcast_skill_effect(ActorID, ActorType, SActorID, SActorType, Value, MapState) ->
    Effect = #p_buff_effect{effect_type=?BUFF_INTERVAL_EFFECT_REDUCE_HP, effect_value=Value, buff_type=0},

    Record = #m_fight_buff_effect_toc{
      actor_id=ActorID,
      actor_type=mod_fight:get_dest_type(ActorType),
      buff_effect=[Effect],
      src_id=SActorID,
      src_type=mod_fight:get_dest_type(SActorType)},

    case ActorType of
        monster ->
            mgeem_map:do_broadcast_insence([{SActorType, SActorID}], ?FIGHT, ?FIGHT_BUFF_EFFECT, Record, MapState);
        server_npc ->
            mgeem_map:do_broadcast_insence([{SActorType, SActorID}], ?FIGHT, ?FIGHT_BUFF_EFFECT, Record, MapState);
        _ ->
            mgeem_map:do_broadcast_insence_include([{SActorType, SActorID}], ?FIGHT, ?FIGHT_BUFF_EFFECT, 
                                                   Record, MapState)
    end.

%%resultlist: [{dactorid, dactortype, type, value, buffs}...]，没有的项写undefined
broadcast_skill_effect(SActorID, SActorType, SkillID, ResultList, MapState) ->
    Result =
        lists:map(
          fun({DActorID, DActorType, ResultType, ResultValue, Buffs}) ->
                  #p_attack_result{dest_id=DActorID, dest_type=mod_fight:get_dest_type(DActorType),
                                   result_type=ResultType, result_value=ResultValue, buffs=Buffs}
          end, ResultList),

    Record = #m_fight_attack_toc{
      src_id=SActorID,
      src_type=mod_fight:get_dest_type(SActorType),
      skillid=SkillID,
      result=Result
     },

    case SActorType of
        monster ->
            mgeem_map:do_broadcast_insence([{SActorType, SActorID}], ?FIGHT, ?FIGHT_ATTACK, Record, MapState);
        server_npc ->
            mgeem_map:do_broadcast_insence([{SActorType, SActorID}], ?FIGHT, ?FIGHT_ATTACK, Record, MapState);
        _ ->
            mgeem_map:do_broadcast_insence_include([{SActorType, SActorID}], ?FIGHT, ?FIGHT_ATTACK, 
                                                   Record, MapState)
    end.

calc_absorb_mp(SActorID, SActorType, SActorAttr, DActorID, role, Effect, SkillID) ->
    #p_effect{absolute_or_rate=AOE, value=Value} = Effect,

    case mod_map_actor:get_actor_mapinfo(DActorID, role) of
        undefined ->
            ignore;
        #p_map_role{mp=MP, max_mp=MaxMP} ->
            case AOE of
                1 ->
                    Reduce = Value;
                _ ->
                    Reduce = common_tool:ceil(MaxMP*Value/10000)
            end,

            case MP =< 0 of
                true ->
                    Reduce2 = 0;
                _ ->
                    Rd = MP - Reduce,
                    case Rd >= 0 of
                        true ->
                            Reduce2 = Reduce;
                        _ ->
                            Reduce2 = MP
                    end
            end,

            case Reduce2 =:= 0 of
                true ->
                    ignore;
                _ ->
                    mod_map_role:do_role_reduce_mp(DActorID, Reduce2, SActorID),
                    mod_map_role:do_role_add_mp(SActorID, Reduce2, SActorID),

                    ResultList = [{DActorID, role, ?RESULT_TYPE_REDUCE_MP, Reduce2, undefined},
                                  {SActorID, role, ?RESULT_TYPE_ADD_MP, Reduce2, undefined}
                                 ],
                    broadcast_skill_effect(SActorID, SActorType, SkillID, ResultList, mgeem_map:get_state())
            end
    end,
    {ok, SActorAttr};
calc_absorb_mp(_SActorID, _SActorType, SActorAttr, _DActorID, _DActorType, _Effect, _SkillID) ->
    {ok, SActorAttr}.

%%下马
calc_mount_down(_SActorID, _SActorType, SActorAttr, DActorID, role, _Effect, _SkillID)->
    mod_equip_mount:force_mountdown(DActorID),
    {ok, SActorAttr};
calc_mount_down(_SActorID, _SActorType, SActorAttr, _DActorID, _DActorType, _Effect, _SkillID) ->
    {ok, SActorAttr}.


%%根据宠物血量加血
calc_add_hp_with_pet_hp(_SActorID, pet, SActorAttr, _DActorID, role, Effect, _SkillID) ->
     #p_effect{value = AddRate} = Effect,
     PetHp = SActorAttr#actor_fight_attr.max_hp,
     AddHp = trunc(AddRate * PetHp / 10000),
      {ok, ?RESULT_TYPE_ADD_HP, AddHp, false};
calc_add_hp_with_pet_hp(_, _, SActorAttr, _, role, _, _) ->
     {ok,SActorAttr}.   


%%根据宠物血量加蓝
calc_add_mp_with_pet_hp(_SActorID, pet, SActorAttr, _DActorID, role, Effect, _SkillID) ->
     #p_effect{value = AddRate} = Effect,
     PetHp = SActorAttr#actor_fight_attr.max_hp,
     AddHp = trunc(AddRate * PetHp / 10000),
      {ok, ?RESULT_TYPE_ADD_MP, AddHp, false};
calc_add_mp_with_pet_hp(_, _, SActorAttr, _, role, _, _) ->
     {ok,SActorAttr}. 


calc_pao_xiao(_SActorID, _SActorType, SActorAttr, _DActorID, _DActorType, _Effect, _SkillID) ->
    {ok,SActorAttr}. 


calc_dispel_debuff(SActorID, SActorType, SActorAttr, DActorID, DActorType, _Effect, _SkillID) ->
     mod_buff:dispel_actor_debuffs(SActorID, SActorType, DActorID, DActorType),
    {ok, SActorAttr}.
      
                                                                                               

%% @doc 获取精炼附加伤害1
get_refining_add_hurt_1(SLevel, DLevel, SSpecScore1, SEquipScore, DEquipScore) ->
    math:pow(2, common_tool:floor((SLevel-DLevel)/15)) * SSpecScore1 * math:pow(2, common_tool:floor((SEquipScore-DEquipScore)/20)).


%% @doc 获取精炼附加伤害2
get_refining_add_hurt_2(SEquipScore, DSpecScore2) ->
    SEquipScore * DSpecScore2.
    
