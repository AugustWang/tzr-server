-module(mod_equip2).

-include("mgeem.hrl").

-export([
         get_flevel_equip_attr/1,
         get_slevel_equip_attr/1
       ]).

%%@doc 获取一级装备属性
get_flevel_equip_attr(Equips) ->
    sum_flevel_attr(Equips,#role_first_level_attr{_=0}).

sum_flevel_attr([],Attr) ->
    ?DEBUG("all equip first Attr = ~w",[Attr]),
    Attr;
sum_flevel_attr([{EquipInfo,BaseInfo}|T], Attr) ->
    sum_flevel_attr(T,sum_first_attr(Attr,EquipInfo,BaseInfo)).

sum_first_attr(Attr,EquipInfo,_BaseInfo) 
  when EquipInfo#p_goods.current_endurance > 0 andalso EquipInfo#p_goods.state =:= ?GOODS_STATE_NORMAL->
    ?DEV("property:~w,typeId:~w~n",
         [EquipInfo#p_goods.add_property,EquipInfo#p_goods.typeid]), 
    Prop = EquipInfo#p_goods.add_property,
    #role_first_level_attr{str = Power,
                           dex = Agile,
                           int = Brain,
                           con = Vitality,
                           men = Spirit} = Attr,
    #role_first_level_attr{str = Power + 
                               Prop#p_property_add.power,
                           dex = Agile + 
                               Prop#p_property_add.agile,
                           int = Brain + 
                               Prop#p_property_add.brain,
                           men = Spirit + 
                               Prop#p_property_add.spirit,
                           con = Vitality + 
                               Prop#p_property_add.vitality};
sum_first_attr(Attr,_EquipInfo,_BaseInfo) ->
    Attr.

%%@doc 获取二级装备属性
get_slevel_equip_attr(Equips) ->
    sum_slevel_attr(Equips,#role_second_level_attr{_=0}).

sum_slevel_attr([],Attr) ->
    ?DEBUG("all equip second Attr = ~w",[Attr]),
    Attr;
sum_slevel_attr([EquipInfo|T] , Attr) ->
    sum_slevel_attr(T,sum_second_attr(Attr,EquipInfo)).

sum_second_attr(Attr,EquipInfo)
  when EquipInfo#p_goods.current_endurance > 0 andalso EquipInfo#p_goods.state =:= ?GOODS_STATE_NORMAL->
    Prop = EquipInfo#p_goods.add_property,
    #role_second_level_attr{max_hp = Attr#role_second_level_attr.max_hp+
                                Prop#p_property_add.blood,
                            max_mp = Attr#role_second_level_attr.max_mp+
                                Prop#p_property_add.magic,
                            max_hp_rate = Attr#role_second_level_attr.max_hp_rate+
                                Prop#p_property_add.blood_rate,
                            max_mp_rate = Attr#role_second_level_attr.max_mp_rate+
                                Prop#p_property_add.magic_rate,
                            max_phy_attack = Attr#role_second_level_attr.max_phy_attack+
                                Prop#p_property_add.max_physic_att,
                            phy_attack_rate = Attr#role_second_level_attr.phy_attack_rate+
                                Prop#p_property_add.physic_att_rate,
                            min_phy_attack = Attr#role_second_level_attr.min_phy_attack+
                                Prop#p_property_add.min_physic_att, 
                            max_magic_attack  = Attr#role_second_level_attr.max_magic_attack+
                                Prop#p_property_add.max_magic_att, 
                            min_magic_attack = Attr#role_second_level_attr.min_magic_attack+
                                Prop#p_property_add.min_magic_att,
                            magic_attack_rate = Attr#role_second_level_attr.magic_attack_rate+
                                Prop#p_property_add.magic_att_rate, 
                            phy_defence = Attr#role_second_level_attr.phy_defence+
                                Prop#p_property_add.physic_def, 
                            phy_defence_rate = Attr#role_second_level_attr.phy_defence_rate+
                                Prop#p_property_add.physic_def_rate,
                            magic_defence = Attr#role_second_level_attr.magic_defence+
                                Prop#p_property_add.magic_def,
                            magic_defence_rate = Attr#role_second_level_attr.magic_defence_rate+
                                Prop#p_property_add.magic_def_rate,
                            hp_recover_speed = Attr#role_second_level_attr.hp_recover_speed+
                                Prop#p_property_add.blood_resume_speed,
                            mp_recover_speed = Attr#role_second_level_attr.mp_recover_speed+
                                Prop#p_property_add.magic_resume_speed,
                            luck = Attr#role_second_level_attr.luck+
                                Prop#p_property_add.lucky,
                            move_speed = Attr#role_second_level_attr.move_speed+
                                Prop#p_property_add.move_speed,
                            attack_speed = Attr#role_second_level_attr.attack_speed+
                                Prop#p_property_add.attack_speed,
                            miss = Attr#role_second_level_attr.miss+
                                Prop#p_property_add.dodge,
                            no_defence = Attr#role_second_level_attr.no_defence+
                                Prop#p_property_add.no_defence,
                            double_attack = Attr#role_second_level_attr.double_attack+
                                Prop#p_property_add.dead_attack,
                            dizzy=Attr#role_second_level_attr.dizzy+
                                Prop#p_property_add.dizzy,
                            poisoning=Attr#role_second_level_attr.poisoning+
                                Prop#p_property_add.poisoning,
                            freeze= Attr#role_second_level_attr.freeze+
                                Prop#p_property_add.freeze,
                            poisoning_resist=Attr#role_second_level_attr.poisoning_resist+
                                Prop#p_property_add.poisoning_resist,
                            dizzy_resist=Attr#role_second_level_attr.dizzy_resist+
                                Prop#p_property_add.dizzy_resist,
                            freeze_resist=Attr#role_second_level_attr.freeze_resist+
                                Prop#p_property_add.freeze_resist,
                            phy_hurt_rate=Attr#role_second_level_attr.phy_hurt_rate+
                                Prop#p_property_add.hurt,
                            magic_hurt_rate=Attr#role_second_level_attr.magic_hurt_rate+
                                Prop#p_property_add.hurt,
                            hurt = Attr#role_second_level_attr.hurt+
                                Prop#p_property_add.hurt,
                            phy_anti = Attr#role_second_level_attr.phy_anti+
                                Prop#p_property_add.phy_anti,
                            magic_anti = Attr#role_second_level_attr.magic_anti+
                                Prop#p_property_add.magic_anti,
                            hurt_rebound = Attr#role_second_level_attr.hurt_rebound+
                                Prop#p_property_add.hurt_rebound,
                            move_speed_rate= 0,
                            attack_speed_rate= 0
                           };
sum_second_attr(Attr,_EquipInfo) ->
    Attr.


