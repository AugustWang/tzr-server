-module(update_mnesia_0_1_3).

-compile(export_all).


-record(p_role_attr, {role_id,role_name,next_level_exp,exp,level,five_ele_attr,last_login_location,equips,jungong=0,charm=0,couple_id=0,couple_name="",skin,cur_energy=2000,max_energy=2000,remain_skill_points=0,gold=0,gold_bind=0,silver=0,silver_bind=0,show_cloth=true,moral_values=0,gongxun=0,last_login_ip="",office_id=0,office_name="",unbund=false,family_contribute=0,active_points=0,category,show_equip_ring=true,is_payed=false,sum_prestige=0,cur_prestige=0}).

connect_db() ->
    [MasterHost] = common_config_dyn:find_common(master_host),
    net_kernel:connect_node(erlang:list_to_atom(lists:concat(["master@", MasterHost]))),
    common_db:join_group(),
    ok.

update() ->
    connect_db(),
    code:load_file(common_config_dyn),
    common_config_dyn:init(),
    update_db_role_attr(), %% 更新p_skin结构
    common_up_db_goods:up_p_goods_structure(), %% 更新p_goods结构
    common_up_db_goods:reclac_equip_refining_index(), %% 重算装备精炼系数
    ok.

update_db_role_attr() ->
    RoleAttrList = db:dirty_match_object(db_role_attr_p, #p_role_attr{_='_' }),
    lists:foreach(
      fun(RoleAttr) ->  
              case RoleAttr#p_role_attr.skin of
                  {p_skin,SKINID,HAIR_TYPE,HAIR_COLOR,WEAPON,CLOTHES,MOUNTS,ASSIS_WEAPON,FASHION} ->
                      NewSkin = {p_skin,SKINID,HAIR_TYPE,HAIR_COLOR,WEAPON,CLOTHES,MOUNTS,ASSIS_WEAPON,FASHION,0};
                  _ ->
                      NewSkin = RoleAttr#p_role_attr.skin
              end,
              db:dirty_write(db_role_attr,RoleAttr#p_role_attr{skin = NewSkin}),
              db:dirty_write(db_role_attr_p,RoleAttr#p_role_attr{skin = NewSkin})
      end, RoleAttrList),
    ok.
