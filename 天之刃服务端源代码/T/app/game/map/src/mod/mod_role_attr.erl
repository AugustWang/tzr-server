%% Author: QingliangCn
%% Created: 2010-4-15
%% Description: TODO: Add description to mod_role_attr
-module(mod_role_attr).
-include("mgeem.hrl").

-define(BIG_NEGATIVE_NUMBER, -100000000).

-export([
         calc_first_level_attr/2,
         calc_second_level_attr/3,
         get_new_attr_points/1
        ]).

-spec(get_new_attr_points(Level::integer()) -> integer()).
get_new_attr_points(Level) 
  when Level >= 1, Level =< 50 ->
    3;
get_new_attr_points(Level) 
  when Level >= 51, Level =< 100 ->
    4;
get_new_attr_points(Level) 
  when Level >= 101, Level =< 150 ->
    5;
get_new_attr_points(Level) 
  when Level >= 151, Level =< 160 ->
    6.


%%计算玩家一级属性
calc_first_level_attr(RoleAttr,RoleBase) ->
    #p_role_base{
                 role_id=RoleID, 
                 base_str=STR2, 
                 base_int=INT2, 
                 base_con=CON2, 
                 base_dex=DEX2, 
                 base_men=MEN2
                } = RoleBase,
    RoleID = RoleBase#p_role_base.role_id,
    
    %%做下防御。。以防万一。。。
    case RoleAttr#p_role_attr.equips of
        undefined ->
            Equip2 = [];
        Equip ->
            Equip2 = Equip
    end,
    Equips = lists:foldl(
               fun(Goods,Acc) ->
                       [BaseInfo] = common_config_dyn:find_equip(Goods#p_goods.typeid),
                       [{Goods,BaseInfo}|Acc]
               end,[], Equip2),
    RtnFirstAttr = mod_equip2:get_flevel_equip_attr(Equips),
    case RtnFirstAttr of
        {fail, Reason} ->
            ?ERROR_MSG("~ts:~w", ["获得玩家的一级属性结果失败", Reason]),
            {error, system_error};
        _ ->
            #role_first_level_attr{str=STR1, int=INT1, con=CON1, dex=DEX1, men=MEN1} = RtnFirstAttr,
            #role_first_level_attr{
                                   str=STR3, 
                                   int=INT3, 
                                   con=CON3, 
                                   dex=DEX3, 
                                   men=MEN3
                                  } = calc_flevel_attr_by_buffs(RoleBase),
            RtnAttr = #role_first_level_attr{
                                             str=STR1+STR2+STR3, 
                                             int=INT1+INT2+INT3, 
                                             con=CON1+CON2+CON3, 
                                             dex=DEX1+DEX2+DEX3, 
                                             men=MEN1+MEN2+MEN3
                                            },
            {ok, RtnAttr}
    end.

-spec(calc_flevel_attr_by_buffs(Buffs::list()) -> #role_first_level_attr{}).
calc_flevel_attr_by_buffs(RoleBase) ->
    Buffs = RoleBase#p_role_base.buffs,
    lists:foldl(
      fun(Buf, Acc) ->
              #p_actor_buf{buff_id=BuffID, buff_type=Type} = Buf,
              {ok, Detail} = mod_skill_manager:get_buf_detail(BuffID),
              {ok, Func} = mod_skill_manager:get_buff_func_by_type(Type),
              #p_buf{value=Value, absolute_or_rate=ValueType} = Detail,
              case Func of
                  add_first_level_attr ->
                      #role_first_level_attr{str=Str, int=Int, con=Con, dex=Dex, men=Men} = Acc,
                      #role_first_level_attr{str=Str+Value, int=Int+Value, con=Con+Value,
                                             dex=Dex+Value, men=Men+Value};
                  add_mem ->
                      add_men(RoleBase, Acc, ValueType, Value);
                  add_int ->
                      add_int(RoleBase, Acc, ValueType, Value);
                  add_str ->
                      add_str(RoleBase, Acc, ValueType, Value);
                  add_dex ->
                      add_dex(RoleBase, Acc, ValueType, Value);
                  add_con ->
                      add_con(RoleBase, Acc, ValueType, Value);
                  pet_add_men ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      add_men(RoleBase, Acc, ValueType, NewValue);
                  pet_add_str ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      add_str(RoleBase, Acc, ValueType, NewValue);
                  pet_add_int ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      add_int(RoleBase, Acc, ValueType, NewValue);
                  pet_add_dex ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      add_dex(RoleBase, Acc, ValueType, NewValue);
                  pet_add_con ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      add_con(RoleBase, Acc, ValueType, NewValue);
                  _ ->
                      Acc
              end
      end, #role_first_level_attr{}, Buffs).

add_men(RoleBase, Acc, ValueType, Value) ->
    Men = Acc#role_first_level_attr.men,
    case ValueType of
        0 ->
            Acc#role_first_level_attr{men=Men+Value};
        1 ->
            Acc#role_first_level_attr{men=Men+common_tool:ceil(RoleBase#p_role_base.men*Value/10000)}
    end.

add_int(RoleBase, Acc, ValueType, Value) ->
    Int = Acc#role_first_level_attr.int,
    case ValueType of
        0 ->
            Acc#role_first_level_attr{int=Int+Value};
        _ ->
            Acc#role_first_level_attr{int=Int=common_tool:ceil(RoleBase#p_role_base.int2*Value/10000)}
    end.

add_str(RoleBase, Acc, ValueType, Value) ->
    Str = Acc#role_first_level_attr.str,
    case ValueType of
        0 ->
            Acc#role_first_level_attr{str=Str+Value};
        1 ->
            Acc#role_first_level_attr{str=Str+common_tool:ceil(RoleBase#p_role_base.str*Value/10000)}
    end.

add_dex(RoleBase, Acc, ValueType, Value) ->
    Dex = Acc#role_first_level_attr.dex,
    case ValueType of
        0 ->
            Acc#role_first_level_attr{dex=Dex+Value};
        _ ->
            Acc#role_first_level_attr{dex=Dex=common_tool:ceil(RoleBase#p_role_base.dex*Value/10000)}
    end.

add_con(RoleBase, Acc, ValueType, Value) ->
    Con = Acc#role_first_level_attr.con,
    case ValueType of
        0 ->
            Acc#role_first_level_attr{con=Con+Value};
        1 ->
            Acc#role_first_level_attr{con=Con+common_tool:ceil(RoleBase#p_role_base.con*Value/10000)}
    end.



calc_slevel_attr_by_buffs(RoleBase, FirstLevelAttr) ->
    #role_first_level_attr{str=_STR, int=_INT, con=_CON, dex=_DEX, men=MEN} = FirstLevelAttr,
    #p_role_base{role_id=RoleID, buffs=Buffs} = RoleBase,
    ?DEBUG("calc_slevel_attr_by_buffs, buffs: ~w", [Buffs]),
    
    lists:foldl(
      fun(Buf, Acc0) ->
              #p_actor_buf{buff_id=BuffID, buff_type=Type, from_actor_id=FromRoleID} = Buf,
              {ok, Detail} = mod_skill_manager:get_buf_detail(BuffID),
              #p_buf{value=Value, absolute_or_rate=ValueType} = Detail,
              {ok, Func} = mod_skill_manager:get_buff_func_by_type(Type),
              
              case Func of
                  add_hp_recover ->
                      Old = Acc0#role_second_level_attr.hp_recover_speed,
                      Acc = Acc0#role_second_level_attr{hp_recover_speed=( Old + Value)};
                  add_mp_recover ->
                      Old = Acc0#role_second_level_attr.mp_recover_speed,
                      case ValueType of
                          0 ->
                              Acc = Acc0#role_second_level_attr{mp_recover_speed=( Old + Value)};
                          1 ->
                              Acc = Acc0#role_second_level_attr{mp_recover_speed=(Old+common_tool:ceil(RoleBase#p_role_base.max_mp*Value/10000))}
                      end;
                  reduce_hp_recover ->
                      Old = Acc0#role_second_level_attr.hp_recover_speed,
                      Acc = Acc0#role_second_level_attr{hp_recover_speed=( Old - Value)};
                  reduce_mp_recover ->
                      Old = Acc0#role_second_level_attr.mp_recover_speed,
                      Acc = Acc0#role_second_level_attr{mp_recover_speed=( Old - Value)};
                  add_move_speed ->
                      Old = Acc0#role_second_level_attr.move_speed,
                      Acc = Acc0#role_second_level_attr{move_speed=( Old + Value)};
                  reduce_move_speed ->
                      Old = Acc0#role_second_level_attr.move_speed,
                      case ValueType of
                          0 ->
                              Acc = Acc0#role_second_level_attr{move_speed=(Old-Value)};
                          1 ->
                              Acc = Acc0#role_second_level_attr{move_speed=Old-common_tool:ceil(?DEFAULT_MOVE_SPEED*Value/10000)}
                      end;
                  dizzy ->
                      Acc = Acc0#role_second_level_attr{move_speed_rate=-10000};
                  stop_body ->
                      Acc = Acc0#role_second_level_attr{move_speed_rate=-10000};
                  phy_attack_zero ->
                      Acc = Acc0#role_second_level_attr{phy_attack_rate=?BIG_NEGATIVE_NUMBER};
                  add_phy_attack ->
                      Acc = add_phy_attack(RoleBase, Acc0, ValueType, Value);
                  reduce_phy_attack ->
                      case ValueType of
                          0 ->
                              OldMax = Acc0#role_second_level_attr.max_phy_attack,
                              OldMin = Acc0#role_second_level_attr.max_phy_attack,
                              Acc = Acc0#role_second_level_attr{
                                                                max_phy_attack=(OldMax-Value),
                                                                min_phy_attack=(OldMin-Value)
                                                               };
                          1 ->
                              Old = Acc0#role_second_level_attr.phy_attack_rate,
                              Acc = Acc0#role_second_level_attr{phy_attack_rate=( Old - Value)}
                      end;
                  add_magic_attack ->
                      Acc = add_magic_attack(RoleBase, Acc0, ValueType, Value);
                  reduce_magic_attack ->
                      case ValueType of
                          0 ->
                              OldMax = Acc0#role_second_level_attr.max_magic_attack,
                              OldMin = Acc0#role_second_level_attr.min_magic_attack,
                              Acc = Acc0#role_second_level_attr{
                                                                max_magic_attack=(OldMax-Value),
                                                                min_magic_attack=(OldMin-Value)
                                                               };
                          1 ->
                              Old = Acc0#role_second_level_attr.magic_attack_rate,
                              Acc = Acc0#role_second_level_attr{magic_attack_rate=( Old - Value)}
                      end;
                  add_phy_defence ->
                      Acc = add_phy_defence(RoleBase, Acc0, ValueType, Value);
                  reduce_phy_defence ->
                      case ValueType of
                          0 ->
                              Old = Acc0#role_second_level_attr.phy_defence,
                              Acc = Acc0#role_second_level_attr{phy_defence=( Old - Value)};
                          1 ->
                              Old = Acc0#role_second_level_attr.phy_defence_rate,
                              Acc = Acc0#role_second_level_attr{phy_defence_rate=( Old - Value)}
                      end;
                  add_magic_defence ->
                      Acc = add_magic_defence(RoleBase, Acc0, ValueType, Value);
                  reduce_magic_defence ->
                      case ValueType of
                          0 ->
                              Old = Acc0#role_second_level_attr.magic_defence,
                              Acc = Acc0#role_second_level_attr{magic_defence=( Old - Value)};
                          1 ->
                              Old = Acc0#role_second_level_attr.magic_defence_rate,
                              Acc = Acc0#role_second_level_attr{magic_defence_rate=( Old - Value)}
                      end;
                  add_max_hp ->
                      Acc = add_max_hp(RoleBase, Acc0, ValueType, Value);
                  add_max_mp ->
                      case ValueType of
                          0 ->
                              Old = Acc0#role_second_level_attr.max_mp,
                              Acc = Acc0#role_second_level_attr{max_mp=( Old + Value)};
                          1 ->
                              Old = Acc0#role_second_level_attr.max_mp_rate,
                              Acc = Acc0#role_second_level_attr{max_mp_rate=( Old + Value)}
                      end;
                  add_attack_by_men ->
                      OldPhyMax = Acc0#role_second_level_attr.max_phy_attack,
                      OldPhyMin = Acc0#role_second_level_attr.min_phy_attack,
                      OldMagicMax = Acc0#role_second_level_attr.max_magic_attack,
                      OldMagicMin = Acc0#role_second_level_attr.min_magic_attack,
                      
                      %%如果施法者是自己，则直接从一级属性那里取，不然取到的可能是旧的
                      case FromRoleID =:= RoleID of
                          true ->
                              MEN2 = MEN;
                          
                          _ ->
                              case common_misc:get_dirty_role_base(FromRoleID) of
                                  {ok, FromRoleBase} ->
                                      MEN2 = FromRoleBase#p_role_base.men;
                                  
                                  _ ->
                                      MEN2 = 0
                              end
                      end,
                      
                      Value2 = common_tool:ceil((Value/10000)*MEN2),
                      Acc = Acc0#role_second_level_attr{
                                                        max_phy_attack=(OldPhyMax+Value2),
                                                        max_magic_attack=(OldMagicMax+Value2),
                                                        min_phy_attack=(OldPhyMin+Value2),
                                                        min_magic_attack=(OldMagicMin+Value2)
                                                       };
                  
                  paralysis ->
                      Old = Acc0#role_second_level_attr.move_speed,
                      case ValueType of
                          0 ->
                              Acc = Acc0#role_second_level_attr{move_speed=(Old-Value)};
                          1 ->
                              Acc = Acc0#role_second_level_attr{move_speed=Old-common_tool:ceil(?DEFAULT_MOVE_SPEED*Value/10000)}
                      end;
                  add_miss ->
                      Old =  Acc0#role_second_level_attr.miss,
                      Acc = Acc0#role_second_level_attr{miss = (Old + Value)};
                  reduce_miss ->
                      Old =  Acc0#role_second_level_attr.miss,
                      Acc = Acc0#role_second_level_attr{miss = (Old - Value)};
                  
                  add_no_defence ->
                      Old =  Acc0#role_second_level_attr.no_defence,
                      Acc = Acc0#role_second_level_attr{no_defence = (Old + Value)};
                  reduce_no_defence ->
                      Old =  Acc0#role_second_level_attr.no_defence,
                      Acc = Acc0#role_second_level_attr{no_defence = (Old - Value)};
                  
                  add_double_attack ->
                      Old =  Acc0#role_second_level_attr.double_attack,
                      Acc = Acc0#role_second_level_attr{double_attack = (Old + Value)};
                  reduce_double_attack ->
                      Old =  Acc0#role_second_level_attr.double_attack,
                      Acc = Acc0#role_second_level_attr{double_attack = (Old - Value)};
                  
                  add_phy_anti ->
                      Old =  Acc0#role_second_level_attr.phy_anti,
                      Acc = Acc0#role_second_level_attr{phy_anti = (Old + Value)};
                  reduce_phy_anti ->
                      Old =  Acc0#role_second_level_attr.phy_anti,
                      Acc = Acc0#role_second_level_attr{phy_anti = (Old - Value)};
                  
                  add_magic_anti ->
                      Old =  Acc0#role_second_level_attr.magic_anti,
                      Acc = Acc0#role_second_level_attr{magic_anti = (Old + Value)};
                  reduce_magic_anti ->
                      Old =  Acc0#role_second_level_attr.magic_anti,
                      Acc = Acc0#role_second_level_attr{magic_anti = (Old - Value)};
                  reduce_defen_by_mem ->
                      PhyDefen = Acc0#role_second_level_attr.phy_defence,
                      MagicDefen = Acc0#role_second_level_attr.magic_defence,
                      
                      case FromRoleID =:= RoleID of
                          true ->
                              MEN2 = MEN;
                          
                          _ ->
                              case common_misc:get_dirty_role_base(FromRoleID) of
                                  {ok, FromRoleBase} ->
                                      MEN2 = FromRoleBase#p_role_base.men;
                                  
                                  _ ->
                                      MEN2 = 0
                              end
                      end,
                      
                      Value2 = common_tool:ceil(MEN2*Value/10000),
                      Acc = #role_second_level_attr{
                                                    phy_defence=PhyDefen-Value2,
                                                    magic_defence=MagicDefen-Value2
                                                   };
                  
                  add_defen_by_men ->
                      PhyDefen = Acc0#role_second_level_attr.phy_defence,
                      MagicDefen = Acc0#role_second_level_attr.magic_defence,
                      
                      case FromRoleID =:= RoleID of
                          true ->
                              MEN2 = MEN;
                          
                          _ ->
                              case common_misc:get_dirty_role_base(FromRoleID) of
                                  {ok, FromRoleBase} ->
                                      MEN2 = FromRoleBase#p_role_base.men;
                                  
                                  _ ->
                                      MEN2 = 0
                              end
                      end,
                      
                      Value2 = common_tool:ceil(MEN2*Value/10000),
                      Acc = #role_second_level_attr{
                                                    phy_defence=PhyDefen+Value2,
                                                    magic_defence=MagicDefen+Value2
                                                   };
                  add_attack ->
                      case ValueType of
                          1 ->
                              PhyAttRate = Acc0#role_second_level_attr.phy_attack_rate,
                              MagAttRate = Acc0#role_second_level_attr.magic_attack_rate,
                              Acc = Acc0#role_second_level_attr{phy_attack_rate=PhyAttRate+Value, magic_attack_rate=MagAttRate+Value};
                          0 ->
                              MaxPhyAttack = Acc0#role_second_level_attr.max_phy_attack,
                              MinPhyAttack = Acc0#role_second_level_attr.min_phy_attack,
                              MaxMagAttack = Acc0#role_second_level_attr.max_magic_attack,
                              MinMagAttack = Acc0#role_second_level_attr.min_magic_attack,
                              Acc = Acc0#role_second_level_attr{
                                                                min_phy_attack=MinPhyAttack+Value,
                                                                max_phy_attack=MaxPhyAttack+Value,
                                                                min_magic_attack=MinMagAttack+Value,
                                                                max_magic_attack=MaxMagAttack+Value
                                                               }
                      end;
                  reduce_attack ->
                      case ValueType of
                          1 ->
                              PhyAttRate = Acc0#role_second_level_attr.phy_attack_rate,
                              MagAttRate = Acc0#role_second_level_attr.magic_attack_rate,
                              Acc = Acc0#role_second_level_attr{phy_attack_rate=PhyAttRate-Value, magic_attack_rate=MagAttRate-Value};
                          0 ->
                              MaxPhyAttack = Acc0#role_second_level_attr.max_phy_attack,
                              MinPhyAttack = Acc0#role_second_level_attr.min_phy_attack,
                              MaxMagAttack = Acc0#role_second_level_attr.max_magic_attack,
                              MinMagAttack = Acc0#role_second_level_attr.min_magic_attack,
                              Acc = Acc0#role_second_level_attr{
                                                                min_phy_attack=MinPhyAttack-Value,
                                                                max_phy_attack=MaxPhyAttack-Value,
                                                                min_magic_attack=MinMagAttack-Value,
                                                                max_magic_attack=MaxMagAttack-Value
                                                               }
                      end;
                  add_defence ->
                      case ValueType of
                          0 ->
                              PhyDefen = Acc0#role_second_level_attr.phy_defence,
                              MagDefen = Acc0#role_second_level_attr.magic_defence,
                              Acc = Acc0#role_second_level_attr{phy_defence=PhyDefen+Value, magic_defence=MagDefen+Value};
                          1 ->
                              PhyDefRate = Acc0#role_second_level_attr.phy_defence_rate,
                              MagDefRate = Acc0#role_second_level_attr.magic_defence_rate,
                              Acc = Acc0#role_second_level_attr{phy_defence_rate=PhyDefRate+Value, magic_defence_rate=MagDefRate+Value}
                      end;
                  reduce_defence ->
                      case ValueType of
                          0 ->
                              PhyDefen = Acc0#role_second_level_attr.phy_defence,
                              MagDefen = Acc0#role_second_level_attr.magic_defence,
                              Acc = Acc0#role_second_level_attr{phy_defence=PhyDefen-Value, magic_defence=MagDefen-Value};
                          1 ->
                              PhyDefRate = Acc0#role_second_level_attr.phy_defence_rate,
                              MagDefRate = Acc0#role_second_level_attr.magic_defence_rate,
                              Acc = Acc0#role_second_level_attr{phy_defence_rate=PhyDefRate-Value, magic_defence_rate=MagDefRate-Value}
                      end;
                  add_anti ->
                      PhyAnti = Acc0#role_second_level_attr.phy_anti,
                      MagAnti = Acc0#role_second_level_attr.magic_anti,
                      Acc = Acc0#role_second_level_attr{phy_anti=PhyAnti+Value, magic_anti=MagAnti+Value};
                  reduce_anti ->
                      PhyAnti = Acc0#role_second_level_attr.phy_anti,
                      MagAnti = Acc0#role_second_level_attr.magic_anti,
                      Acc = Acc0#role_second_level_attr{phy_anti=PhyAnti-Value, magic_anti=MagAnti-Value}; 
                  add_phy_hurt ->
                      Acc = add_phy_hurt(Acc0, Value);
                  reduce_phy_hurt ->
                      Acc = reduce_phy_hurt(Acc0, Value);
                  add_magic_hurt ->
                      Acc = add_magic_hurt(Acc0, Value);
                  reduce_magic_hurt ->
                      Acc = reduce_magic_hurt(Acc0, Value);
                  add_hurt ->
                      Acc1 = add_phy_hurt(Acc0, Value),
                      Acc = add_magic_hurt(Acc1, Value);
                  reduce_hurt ->
                      Acc1 = reduce_phy_hurt(Acc0, Value),
                      Acc = reduce_magic_hurt(Acc1, Value);
                  add_attack_speed ->
                      Acc = add_attack_speed(Acc0, Value, ValueType);
                  reduce_attack_speed ->
                      Acc = reduce_attack_speed(Acc0, Value, ValueType);
                  hurt_rebound ->
                      Acc = add_hurt_rebound(Acc0, Value);
                  pet_add_phy_attack ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      Acc = add_phy_attack(RoleBase, Acc0, ValueType, NewValue);
                  pet_add_phy_defence ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      Acc = add_phy_defence(RoleBase, Acc0, ValueType, NewValue);
                  pet_add_magic_attack ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      Acc = add_magic_attack(RoleBase, Acc0, ValueType, NewValue);
                  pet_add_magic_defence ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      Acc = add_magic_defence(RoleBase, Acc0, ValueType, NewValue);
                  pet_add_max_hp ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      Acc = add_max_hp(RoleBase, Acc0, ValueType, NewValue);
                  pet_add_max_mp ->
                      NewValue = mod_map_pet:get_pet_buff_final_value(RoleBase#p_role_base.role_id,BuffID,Value),
                      Acc = add_max_mp(RoleBase, Acc0, ValueType, NewValue);
                  _ ->
                      Acc = Acc0
            end,
            Acc
    end, #role_second_level_attr{}, Buffs).

calc_second_level_attr(RoleAttr, RoleBase, FirstLevelAttr) ->
    #role_first_level_attr{str=STR, int=INT, con=CON, dex=DEX, men=MEN} = FirstLevelAttr,
    %%RoleID = RoleAttr#p_role_attr.role_id,
    Level = RoleAttr#p_role_attr.level,
    case RoleAttr#p_role_attr.equips of
        undefined ->
            Equips2 = [];
        Equips ->
            Equips2 = Equips
    end,
    RtnSecondAttr = mod_equip2:get_slevel_equip_attr(Equips2),
    case RtnSecondAttr of
        {fail, Reason} ->
            ?DEBUG("mod_equip:get_slevel_equip_attr failed ~w", [Reason]),
            {error, system_error};
        _ ->
            #role_second_level_attr{
                                    max_hp=MaxHP1, 
                                    max_mp=MaxMP1,
                                    max_hp_rate=MaxHPRate1,
                                    max_mp_rate=MaxMPRate1,
                                    max_phy_attack=MaxPhyAttack1,
                                    min_phy_attack=MinPhyAttack1,
                                    phy_attack_rate=PhyAttackRate1,
                                    max_magic_attack=MaxMagicAttack1,
                                    min_magic_attack=MinMagicAttack1,
                                    magic_attack_rate=MagicAttackRate1,
                                    phy_defence=PhyDefence1,
                                    phy_defence_rate=PhyDefenceRate1,
                                    magic_defence=MagicDefence1,
                                    magic_defence_rate=MagicDefenceRate1,
                                    hp_recover_speed=HPRecoverSpeed1,
                                    mp_recover_speed=MPRecoverSpeed1,
                                    luck=Luck1,
                                    move_speed=MoveSpeed1,
                                    move_speed_rate=MoveSpeedRate1,
                                    attack_speed=AttackSpeed1,
                                    attack_speed_rate=AttackSpeedRate1,
                                    miss=Miss1,
                                    no_defence=NoDefence1,
                                    double_attack=DoubleAttack1,
                                    dizzy=Dizzy1,
                                    poisoning=Poisoning1,
                                    freeze=Freeze1,
                                    poisoning_resist=PoisoningResist1,
                                    dizzy_resist=DizzyResist1,
                                    freeze_resist=FreezeResist1,
                                    phy_hurt_rate=PhyHurt1,
                                    magic_hurt_rate=MagicHurt1,
                                    hurt = Hurt1,
                                    phy_anti = PhyAnti1,
                                    magic_anti = MagicAnti1,
                                    hurt_rebound = HurtRebound1
                                   } = RtnSecondAttr,
            
            #role_second_level_attr{
                                    max_hp=MaxHP2, 
                                    max_mp=MaxMP2,
                                    max_hp_rate=MaxHPRate2,
                                    max_mp_rate=MaxMPRate2,
                                    max_phy_attack=MaxPhyAttack2,
                                    min_phy_attack=MinPhyAttack2,
                                    phy_attack_rate=PhyAttackRate2,
                                    max_magic_attack=MaxMagicAttack2,
                                    min_magic_attack=MinMagicAttack2,
                                    magic_attack_rate=MagicAttackRate2,
                                    phy_defence=PhyDefence2,
                                    phy_defence_rate=PhyDefenceRate2,
                                    magic_defence=MagicDefence2,
                                    magic_defence_rate=MagicDefenceRate2,
                                    hp_recover_speed=HPRecoverSpeed2,
                                    mp_recover_speed=MPRecoverSpeed2,
                                    luck=Luck2,
                                    move_speed=MoveSpeed2,
                                    move_speed_rate=MoveSpeedRate2,
                                    attack_speed=AttackSpeed2,
                                    attack_speed_rate=AttackSpeedRate2,
                                    miss=Miss2,
                                    no_defence=NoDefence2,
                                    double_attack=DoubleAttack2,
                                    phy_hurt_rate=PhyHurt2,
                                    magic_hurt_rate=MagicHurt2,
                                    hurt = Hurt2,
                                    phy_anti = PhyAnti2,
                                    magic_anti = MagicAnti2,
                                    hurt_rebound = HurtRebound2
                                   } = calc_slevel_attr_by_buffs(RoleBase, FirstLevelAttr),
            
            LevelBaseHP = common_misc:get_level_base_hp(Level),
            LevelBaseMP = common_misc:get_level_base_mp(Level),
            MaxHP = common_tool:ceil((LevelBaseHP + MaxHP1 + MaxHP2 + STR * 2 + CON * 25 + MEN * 2) 
                                         * (1 + (MaxHPRate1 + MaxHPRate2)/10000)),
            MaxMP = common_tool:ceil((LevelBaseMP + MaxMP1 + MaxMP2 + INT * 3 + MEN * 2) 
                                         * (1 + (MaxMPRate1 + MaxMPRate2)/10000)),
            MaxPhyAttackTmp = common_tool:ceil((?DEFAULT_MAX_PHY_ATTACK + STR + MaxPhyAttack1 + MaxPhyAttack2) 
                                                   * (1 + (PhyAttackRate1 + PhyAttackRate2)/10000)),
            case MaxPhyAttackTmp < 0 of
                true ->
                    MaxPhyAttack = 0;
                false ->
                    MaxPhyAttack = MaxPhyAttackTmp
            end,
            MinPhyAttackTmp = common_tool:ceil((?DEFAULT_MIN_PHY_ATTACK + STR + MinPhyAttack1 + MinPhyAttack2) 
                                                   * (1 + (PhyAttackRate1 + PhyAttackRate2)/10000)),
            case MinPhyAttackTmp < 0 of
                true ->
                    MinPhyAttack = 0;
                false ->
                    MinPhyAttack = MinPhyAttackTmp
            end,
            MaxMagicAttackTmp = common_tool:ceil((?DEFAULT_MAX_MAGIC_ATTACK + INT*1.3
                                                      + MaxMagicAttack1 + MaxMagicAttack2) 
                                                     * (1 + (MagicAttackRate1 + MagicAttackRate2)/10000)),
            case MaxMagicAttackTmp < 0 of
                true ->
                    MaxMagicAttack = 0;
                false ->
                    MaxMagicAttack = MaxMagicAttackTmp
            end,
            
            MinMagicAttackTmp = common_tool:ceil((?DEFAULT_MIN_MAGIC_ATTACK + INT*1.3
                                                      + MinMagicAttack1 + MinMagicAttack2)
                                                     * (1 + (MagicAttackRate1 + MagicAttackRate2)/10000)),
            case MinMagicAttackTmp < 0 of
                true ->
                    MinMagicAttack = 0;
                false ->
                    MinMagicAttack = MinMagicAttackTmp
            end,
            PhyDefenceTmp = common_tool:ceil(((?DEFAULT_PHY_DEFENCE + DEX * 1) 
                                                  + PhyDefence1 + PhyDefence2) 
                                                 * (1 + (PhyDefenceRate1 + PhyDefenceRate2)/10000)),
            case PhyDefenceTmp < 0 of
                true ->
                    PhyDefence = 0;
                false ->
                    PhyDefence = PhyDefenceTmp
            end,
            MagicDefenceTmp = common_tool:ceil(
                                ((?DEFAULT_MAGIC_DEFENCE + DEX * 1.1) 
                                     + MagicDefence1 + MagicDefence2) 
                                    * (1 + (MagicDefenceRate1 + MagicDefenceRate2)/10000)
                                              ),
            case MagicDefenceTmp < 0 of
                true ->
                    MagicDefence = 0;
                false ->
                    MagicDefence = MagicDefenceTmp
            end,
            HPRecoverSpeed = ?DEFAULT_HP_RECOVER_SPEED + HPRecoverSpeed1 + HPRecoverSpeed2,
            MPRecoverSpeed = ?DEFAULT_MP_RECOVER_SPEED + MPRecoverSpeed1 + MPRecoverSpeed2,
            Luck = ?DEFAULT_LUCK + Luck1 + Luck2,
            MoveSpeedTmp = common_tool:ceil((?DEFAULT_MOVE_SPEED+MoveSpeed1+ MoveSpeed2) 
                                                * (1+(MoveSpeedRate1+MoveSpeedRate2)/10000)),
            case MoveSpeedTmp < 0 of
                true ->
                    MoveSpeed = 0;
                false ->
                    MoveSpeed = MoveSpeedTmp
            end,
            AttackSpeed = common_tool:ceil((?DEFAULT_ATTACK_SPEED + AttackSpeed1 + AttackSpeed2 + DEX * 0.2) 
                                               * (1 + (AttackSpeedRate1 + AttackSpeedRate2)/10000)),
            Miss = Miss1 + Miss2 + ?DEFAULT_MISS,
            NoDefence = NoDefence1 + NoDefence2 + ?DEFAULT_NO_DEFENCE,
            
            DoubleAttack = common_tool:ceil(DoubleAttack1 + DoubleAttack2 + ?DEFAULT_DOUBLE_ATTACK + CON * 1), 
            
            Rtn = #role_second_level_attr{
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
                                          phy_hurt_rate=PhyHurt2+PhyHurt1,
                                          magic_hurt_rate=MagicHurt2+MagicHurt1,
                                          dizzy=Dizzy1,
                                          poisoning=Poisoning1,
                                          freeze=Freeze1,
                                          poisoning_resist=PoisoningResist1,
                                          dizzy_resist=DizzyResist1,
                                          freeze_resist=FreezeResist1,
                                          hurt = Hurt1+Hurt2,
                                          phy_anti = PhyAnti1+PhyAnti2,
                                          magic_anti = MagicAnti1+MagicAnti2,
                                          hurt_rebound = HurtRebound1+HurtRebound2
                                         },
            {ok, Rtn}
    end.

add_phy_hurt(SecondLevelAttr, Value) ->
    PhyHurt = SecondLevelAttr#role_second_level_attr.phy_hurt_rate,
    SecondLevelAttr#role_second_level_attr{phy_hurt_rate=PhyHurt+Value}.

reduce_phy_hurt(SecondLevelAttr, Value) ->
    PhyHurt = SecondLevelAttr#role_second_level_attr.phy_hurt_rate,
    SecondLevelAttr#role_second_level_attr{phy_hurt_rate=PhyHurt-Value}.

add_magic_hurt(SecondLevelAttr, Value) ->
    MagicHurt = SecondLevelAttr#role_second_level_attr.magic_hurt_rate,
    SecondLevelAttr#role_second_level_attr{magic_hurt_rate=MagicHurt+Value}.

reduce_magic_hurt(SecondLevelAttr, Value) ->
    MagicHurt = SecondLevelAttr#role_second_level_attr.magic_hurt_rate,
    SecondLevelAttr#role_second_level_attr{magic_hurt_rate=MagicHurt-Value}.

add_attack_speed(SecondLevelAttr, Value, ValueType) ->
    case ValueType of
        0 ->
            AttackSpeed = SecondLevelAttr#role_second_level_attr.attack_speed,
            SecondLevelAttr#role_second_level_attr{attack_speed=AttackSpeed+Value};
        1 ->
            AttackSpeedRate = SecondLevelAttr#role_second_level_attr.attack_speed_rate,
            SecondLevelAttr#role_second_level_attr{attack_speed_rate=AttackSpeedRate+Value}
    end.

reduce_attack_speed(SecondLevelAttr, Value, ValueType) ->
    case ValueType of
        0 ->
            AttackSpeed = SecondLevelAttr#role_second_level_attr.attack_speed,
            SecondLevelAttr#role_second_level_attr{attack_speed=AttackSpeed-Value};
        1 ->
            AttackSpeedRate = SecondLevelAttr#role_second_level_attr.attack_speed_rate,
            SecondLevelAttr#role_second_level_attr{attack_speed_rate=AttackSpeedRate-Value}
    end.

%%技能的话是百分百伤害反射
add_hurt_rebound(SecondLevelAttr, Value) ->
    HurtRebound = SecondLevelAttr#role_second_level_attr.hurt_rebound,
    SecondLevelAttr#role_second_level_attr{hurt_rebound=HurtRebound+Value}.


add_phy_attack(_RoleBase, Acc0, ValueType, Value) ->
    case ValueType of
        0 ->
            OldMax = Acc0#role_second_level_attr.max_phy_attack,
            OldMin = Acc0#role_second_level_attr.min_phy_attack,
            Acc0#role_second_level_attr{
                                        max_phy_attack=(OldMax+Value),
                                        min_phy_attack=(OldMin+Value)
                                       };
        1 ->
            Old= Acc0#role_second_level_attr.phy_attack_rate,
            Acc0#role_second_level_attr{phy_attack_rate=( Old + Value)}
    end.


add_phy_defence(_RoleBase, Acc0, ValueType, Value) ->
    case ValueType of
        0 ->
            Old = Acc0#role_second_level_attr.phy_defence,
            Acc0#role_second_level_attr{phy_defence=( Old + Value)};
        1 ->
            Old = Acc0#role_second_level_attr.phy_defence_rate,
            Acc0#role_second_level_attr{phy_defence_rate=( Old + Value)}
    end.


add_magic_attack(_RoleBase, Acc0, ValueType, Value) ->
    case ValueType of
        0 ->
            OldMax = Acc0#role_second_level_attr.max_magic_attack,
            OldMin = Acc0#role_second_level_attr.min_magic_attack,
            Acc0#role_second_level_attr{
                                        max_magic_attack=(OldMax+Value),
                                        min_magic_attack=(OldMin+Value)
                                       };
        1 ->
            Old= Acc0#role_second_level_attr.magic_attack_rate,
            Acc0#role_second_level_attr{magic_attack_rate=( Old + Value)}
    end.


add_magic_defence(_RoleBase, Acc0, ValueType, Value) ->
    case ValueType of
        0 ->
            Old = Acc0#role_second_level_attr.magic_defence,
            Acc0#role_second_level_attr{magic_defence=( Old + Value)};
        1 ->
            Old = Acc0#role_second_level_attr.magic_defence_rate,
            Acc0#role_second_level_attr{magic_defence_rate=( Old + Value)}
    end.


add_max_hp(_RoleBase, Acc0, ValueType, Value) ->
    case ValueType of
        0 ->
            Old = Acc0#role_second_level_attr.max_hp,
            Acc0#role_second_level_attr{max_hp=( Old + Value)};
        1 ->
            Old = Acc0#role_second_level_attr.max_hp_rate,
            Acc0#role_second_level_attr{max_hp_rate=( Old + Value)}
    end.


add_max_mp(_RoleBase, Acc0, ValueType, Value) ->
    case ValueType of
        0 ->
            Old = Acc0#role_second_level_attr.max_mp,
            Acc0#role_second_level_attr{max_mp=( Old + Value)};
        1 ->
            Old = Acc0#role_second_level_attr.max_mp_rate,
            Acc0#role_second_level_attr{max_mp_rate=( Old + Value)}
    end.
