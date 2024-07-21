-module(update_mnesia_0_0_1).

-compile(export_all).

%% bag_basic_list = [{bag_id,bag_type_id,due_time,rows,columns}],玩家对应的背包状况
-record(r_role_bag_basic,{role_id,bag_basic_list}).

connect_db() ->
    [MasterHost] = common_config_dyn:find_common(master_host),
    net_kernel:connect_node(erlang:list_to_atom(lists:concat(["master@", MasterHost]))),
    common_db:join_group(),
    ok.

update() ->
    connect_db(),
    code:load_file(common_config_dyn),
    common_config_dyn:init(),
    update_db_role_attr(),
    common_up_db_goods:up_equip_info(),
    %% 背包修改，即可以支持设置格子数
    update_db_role_bag(),
    update_db_friend(),
    update_db_role_achievement(),
    update_db_role_hero_fb_info(),
    update_db_hero_fb_record(),
    update_db_role_skill(),
    update_db_system_config(),
    update_db_role_base(),
    ok.

update_db_role_attr() ->
    TransFormer = 
        fun(R) ->
               case R of
                   {p_role_attr,ROLE_ID,ROLE_NAME,NEXT_LEVEL_EXP,EXP,LEVEL,FIVE_ELE_ATTR,LAST_LOGIN_LOCATION,EQUIPS,JUNGONG,CHARM,COUPLE_ID,COUPLE_NAME,SKIN,CUR_ENERGY,MAX_ENERGY,REMAIN_SKILL_POINTS,GOLD,GOLD_BIND,SILVER,SILVER_BIND,SHOW_CLOTH,MORAL_VALUES,GONGXUN,LAST_LOGIN_IP,OFFICE_ID,OFFICE_NAME,UNBUND,FAMILY_CONTRIBUTE,ACTIVE_POINTS,CATEGORY,SHOW_EQUIP_RING,IS_PAYED} ->
                       {p_role_attr,ROLE_ID,ROLE_NAME,NEXT_LEVEL_EXP,EXP,LEVEL,FIVE_ELE_ATTR,LAST_LOGIN_LOCATION,EQUIPS,JUNGONG,CHARM,COUPLE_ID,COUPLE_NAME,SKIN,CUR_ENERGY,MAX_ENERGY,REMAIN_SKILL_POINTS,GOLD,GOLD_BIND,SILVER,SILVER_BIND,SHOW_CLOTH,MORAL_VALUES,GONGXUN,LAST_LOGIN_IP,OFFICE_ID,OFFICE_NAME,UNBUND,FAMILY_CONTRIBUTE,ACTIVE_POINTS,CATEGORY,SHOW_EQUIP_RING,IS_PAYED,0,0};
                   _ ->
                       R
               end
        end,
    Fields = [role_id,role_name,next_level_exp,exp,level,five_ele_attr,last_login_location,equips,jungong,charm,couple_id,couple_name,skin,cur_energy,max_energy,remain_skill_points,gold,gold_bind,silver,silver_bind,show_cloth,moral_values,gongxun,last_login_ip,office_id,office_name,unbund,family_contribute,active_points,category,show_equip_ring,is_payed,sum_prestige,cur_prestige],
    {atomic, ok} = mnesia:transform_table(db_role_attr, TransFormer, Fields, p_role_attr),
    {atomic, ok} = mnesia:transform_table(db_role_attr_p, TransFormer, Fields, p_role_attr).

%% 背包修改，即可以支持设置格子数
%% [{bag_id,bag_type_id,due_time,roles,columns}]
%% 更新为 [{bag_id,bag_type_id,due_time,roles,columns,grid_number}]
update_db_role_bag() ->
    RoleBagBasicList = db:dirty_match_object(db_role_bag_basic_p, #r_role_bag_basic{_='_' }),
    lists:foreach(
      fun(RoleBagBasic) ->
              BagBasicList = 
                  lists:foldl(
                    fun(R,AccBagBasicList) -> 
                            case R of
                                {BAG_ID,BAG_TYPE_ID,DUE_TIME,ROWS,COLUMNS} ->
                                    if BAG_ID =:= 1 ->
                                           [{BAG_ID,BAG_TYPE_ID,DUE_TIME,5,8,40} | AccBagBasicList];
                                       BAG_ID =:= 2 orelse BAG_ID =:= 3 orelse BAG_ID =:= 4->
                                           AccBagBasicList;
%%                                            [{r_bag_config,_,PRows,PColumns,PGridNumber}] = 
%%                                                common_config_dyn:find(extend_bag,BAG_TYPE_ID),
%%                                            [{BAG_ID,BAG_TYPE_ID,DUE_TIME,PRows,PColumns,PGridNumber} | AccBagBasicList];
                                       true ->
                                           [{BAG_ID,BAG_TYPE_ID,DUE_TIME,ROWS,COLUMNS,ROWS * COLUMNS} | AccBagBasicList]
                                    end;
                                _ ->
                                    [R | AccBagBasicList]
                            end
                    end,[],RoleBagBasic#r_role_bag_basic.bag_basic_list),
              db:dirty_delete(db_role_bag_p,{RoleBagBasic#r_role_bag_basic.role_id,2}),
              db:dirty_delete(db_role_bag_p,{RoleBagBasic#r_role_bag_basic.role_id,3}),
              db:dirty_delete(db_role_bag_p,{RoleBagBasic#r_role_bag_basic.role_id,4}),
              db:dirty_write(db_role_bag_basic_p,RoleBagBasic#r_role_bag_basic{bag_basic_list = BagBasicList})
      end,RoleBagBasicList),
    ok.
%% 更新好友数据结构，添加副本类型好友度字段
%% chat_time, team_time,fb_time 结构为 {Date,Times} or undefined
%% -record(r_friend,{roleid, friendid, type, friendly, chat_time, team_time, relative=[],fb_time}).
update_db_friend() ->
    TransFormer = 
        fun(R) ->
               case R of
                   {r_friend,ROLEID,FRIENDID,TYPE,FRIENDLY,CHAT_TIME,TEAM_TIME,RELATIVE} ->
                       {r_friend,ROLEID,FRIENDID,TYPE,FRIENDLY,CHAT_TIME,TEAM_TIME,RELATIVE,undefined};
                   _ ->
                       R
               end
        end,
    Fields = [roleid, friendid, type, friendly, chat_time, team_time, relative,fb_time],
    {atomic, ok} = mnesia:transform_table(db_friend, TransFormer, Fields, r_friend),
    {atomic, ok} = mnesia:transform_table(db_friend_p, TransFormer, Fields, r_friend),
    ok.

%% 更新玩家成就表
update_db_role_achievement() ->
    TransFormer = 
        fun(R) ->
                case R of
                    {r_db_role_achievement,ROLEID,_ACHIEVEMENTS} ->
                        {r_db_role_achievement,ROLEID,[],[],[]};
                    _ ->
                        R
                end
        end,
    Fields = [role_id,achievements,lately_achievements,stat_info],
    {atomic, ok} = mnesia:transform_table(db_role_achievement_p, TransFormer, Fields, r_db_role_achievement),
    ok.
%% 清空个人副本表
update_db_role_hero_fb_info() ->
    TransFormer = 
        fun(R) ->
               case R of
                   {p_role_hero_fb_info,ROLE_ID,LAST_ENTER_TIME,_TODAY_COUNT,_PROGRESS,_REWARDS,_FB_RECORD,MAX_ENTER_TIMES,_BUY_COUNT} ->
                        {p_role_hero_fb_info,ROLE_ID,LAST_ENTER_TIME,0,101,[],[],MAX_ENTER_TIMES,0,0,undefined};
                   _ ->
                       R
               end
        end,
    Fields = [role_id,last_enter_time,today_count,progress,rewards,fb_record,max_enter_times,buy_count,enter_mapid,enter_pos],
    {atomic, ok} = mnesia:transform_table(db_role_hero_fb_p, TransFormer, Fields, p_role_hero_fb_info).

%% 清空个人副本排行榜
update_db_hero_fb_record()->
    TransFormer = 
        fun(R) ->
               case R of
                   {r_hero_fb_record,BarrierID,_} ->
                        {r_hero_fb_record,BarrierID,[]};
                   _ ->
                       R
               end
        end,
    Fields = [barrier_id, best_record],
    {atomic, ok} = mnesia:transform_table(db_hero_fb_record_p, TransFormer, Fields, r_hero_fb_record).

%% 清空背包数据
update_clean_role_bag()->
    TransFormer = 
        fun(R) ->
               case R of
                   {r_role_bag,Key,_} ->
                       {r_role_bag,Key,[]};
                   _ ->
                       R
               end
        end,
    Fields = [role_bag_key,bag_goods],
    {atomic, ok} = mnesia:transform_table(db_role_bag_p, TransFormer, Fields, r_role_bag).
%% 玩家技能处理
update_db_role_skill() ->
    db:delete_table(db_role_skill),
    db:delete_table(db_role_category),
    db:delete_table(db_role_category_p),
    TransFormer = 
        fun(R) ->
                case R of
                    {r_role_skill,_Key,ROLEID,_SkillId,_CurLevel,_Category} ->
                        {r_role_skill,ROLEID,[]};
                    _ ->
                        R
                end
        end,
    Fields = [role_id,skill_list],
    {atomic, ok} = mnesia:transform_table(db_role_skill_p, TransFormer, Fields, r_role_skill),
    ok.

%% 玩家配置表添加字段
update_db_system_config() ->
    TransFormer = 
        fun(R) ->
                case R of
                    {r_sys_config, RoleId, SysConfig} ->
                        SysConfig2 = 
                            case SysConfig of
                                {p_sys_config,SCENCE_VOL,GAME_VOL,BACK_SOUND,GAME_SOUND,IMAGE_QUALITY,
                                 PRIVATE_CHAT,NATION_CHAT,FAMILY_CHAT,WORLD_CHAT,TEAM_CHAT,CENTER_BROADCAST,
                                 SKILL_EFFECT,SHOW_CLOTH,BY_FIND,SHOW_TITLE,SHOW_FAMILY,SHOW_NAME,SHOW_FACTION,
                                 AUTO_FIGHT,AUTO_USE_HP,HP_BELOW,AUTO_USE_MP,MP_BELOW,AUTO_BUY,AUTO_RETURN_HOME,
                                 AUTO_PICK_EQUIP,AUTO_PICK_STONE,AUTO_PICK_DRUG,AUTO_PICK_OTHER,PICK_EQUIP_COLOR,
                                 PICK_OTHER_COLOR,AUTO_USE_SKILL,SKILL_LIST,AUTO_SEARCH,AUTO_TEAM,AUTO_ACCEPT,
                                 HOOK_TIME,TIME_LEVEL,SHOW_DROPGOODS_NAME,SHOW_EQUIP_COMPARE,BY_HP_TYPEID,
                                 BY_MP_TYPEID,OTHER_FACTION,ACCEPT_FRIEND_REQUEST,PET_AUTO_USE_HP,PET_HP_BELOW,
                                 PET_BY_HP_TYPEID,PET_AUTO_USE_SKILL} ->
                                    {p_sys_config,SCENCE_VOL,GAME_VOL,BACK_SOUND,GAME_SOUND,IMAGE_QUALITY,
                                     PRIVATE_CHAT,NATION_CHAT,FAMILY_CHAT,WORLD_CHAT,TEAM_CHAT,CENTER_BROADCAST,
                                     SKILL_EFFECT,SHOW_CLOTH,BY_FIND,SHOW_TITLE,SHOW_FAMILY,SHOW_NAME,SHOW_FACTION,
                                     AUTO_FIGHT,AUTO_USE_HP,HP_BELOW,AUTO_USE_MP,MP_BELOW,AUTO_BUY,AUTO_RETURN_HOME,
                                     AUTO_PICK_EQUIP,AUTO_PICK_STONE,AUTO_PICK_DRUG,AUTO_PICK_OTHER,PICK_EQUIP_COLOR,
                                     PICK_OTHER_COLOR,AUTO_USE_SKILL,SKILL_LIST,AUTO_SEARCH,AUTO_TEAM,AUTO_ACCEPT,
                                     HOOK_TIME,TIME_LEVEL,SHOW_DROPGOODS_NAME,SHOW_EQUIP_COMPARE,BY_HP_TYPEID,
                                     BY_MP_TYPEID,OTHER_FACTION,ACCEPT_FRIEND_REQUEST,PET_AUTO_USE_HP,PET_HP_BELOW,
                                     PET_BY_HP_TYPEID,PET_AUTO_USE_SKILL,1,1,1};
                                _ ->
                                    SysConfig
                            end,
                        {r_sys_config, RoleId, SysConfig2};
                    _ ->
                        R
                end
        end,
    Fields = [roleid, sys_config],
    {atomic, ok} = mnesia:transform_table(db_system_config, TransFormer, Fields, r_sys_config),
    {atomic, ok} = mnesia:transform_table(db_system_config_p, TransFormer, Fields, r_sys_config),
    ok.
%% 添加account_type字段
update_db_role_base()->
    TransFormer = 
        fun(R) ->
                case R of
                    {p_role_base,ROLE_ID,ROLE_NAME,ACCOUNT_NAME,SEX,CREATE_TIME,STATUS,HEAD,FACTION_ID,
                     TEAM_ID,FAMILY_ID,FAMILY_NAME,MAX_HP,MAX_MP,STR,INT2,CON,DEX,MEN,BASE_STR,BASE_INT,
                     BASE_CON,BASE_DEX,BASE_MEN,REMAIN_ATTR_POINTS,PK_TITLE,MAX_PHY_ATTACK,MIN_PHY_ATTACK,
                     MAX_MAGIC_ATTACK,MIN_MAGIC_ATTACK,PHY_DEFENCE,MAGIC_DEFENCE,HP_RECOVER_SPEED,MP_RECOVER_SPEED,
                     LUCK,MOVE_SPEED,ATTACK_SPEED,ERUPT_ATTACK_RATE,NO_DEFENCE,MISS,DOUBLE_ATTACK,PHY_ANTI,
                     MAGIC_ANTI,CUR_TITLE,CUR_TITLE_COLOR,PK_MODE,PK_POINTS,LAST_GRAY_NAME,IF_GRAY_NAME,WEAPON_TYPE,
                     BUFFS,PHY_HURT_RATE,MAGIC_HURT_RATE,DISABLE_MENU,DIZZY,POISONING,FREEZE,HURT,POISONING_RESIST,
                     DIZZY_RESIST,FREEZE_RESIST,HURT_REBOUND,ACHIEVEMENT,EQUIP_SCORE,SPEC_SCORE_ONE,SPEC_SCORE_TWO,HIT_RATE} ->
                        {p_role_base,ROLE_ID,ROLE_NAME,ACCOUNT_NAME,SEX,CREATE_TIME,STATUS,HEAD,FACTION_ID,
                         TEAM_ID,FAMILY_ID,FAMILY_NAME,MAX_HP,MAX_MP,STR,INT2,CON,DEX,MEN,BASE_STR,BASE_INT,
                         BASE_CON,BASE_DEX,BASE_MEN,REMAIN_ATTR_POINTS,PK_TITLE,MAX_PHY_ATTACK,MIN_PHY_ATTACK,
                         MAX_MAGIC_ATTACK,MIN_MAGIC_ATTACK,PHY_DEFENCE,MAGIC_DEFENCE,HP_RECOVER_SPEED,MP_RECOVER_SPEED,
                         LUCK,MOVE_SPEED,ATTACK_SPEED,ERUPT_ATTACK_RATE,NO_DEFENCE,MISS,DOUBLE_ATTACK,PHY_ANTI,
                         MAGIC_ANTI,CUR_TITLE,CUR_TITLE_COLOR,PK_MODE,PK_POINTS,LAST_GRAY_NAME,IF_GRAY_NAME,WEAPON_TYPE,
                         BUFFS,PHY_HURT_RATE,MAGIC_HURT_RATE,DISABLE_MENU,DIZZY,POISONING,FREEZE,HURT,POISONING_RESIST,
                         DIZZY_RESIST,FREEZE_RESIST,HURT_REBOUND,ACHIEVEMENT,EQUIP_SCORE,SPEC_SCORE_ONE,SPEC_SCORE_TWO,HIT_RATE,0};
                    _ ->
                        R
                end
        end,
    Fields = [role_id,role_name,account_name,sex,create_time,status,head,faction_id,team_id,family_id,family_name,max_hp,
              max_mp,str,int2,con,dex,men,base_str,base_int,base_con,base_dex,base_men,remain_attr_points,pk_title,max_phy_attack,
              min_phy_attack,max_magic_attack,min_magic_attack,phy_defence,magic_defence,hp_recover_speed,mp_recover_speed,
              luck,move_speed,attack_speed,erupt_attack_rate,no_defence,miss,double_attack,phy_anti,magic_anti,cur_title,
              cur_title_color,pk_mode,pk_points,last_gray_name,if_gray_name,weapon_type,buffs,phy_hurt_rate,magic_hurt_rate,
              disable_menu,dizzy,poisoning,freeze,hurt,poisoning_resist,dizzy_resist,freeze_resist,hurt_rebound,achievement,
              equip_score,spec_score_one,spec_score_two,hit_rate,account_type],
    {atomic, ok} = mnesia:transform_table(db_role_base, TransFormer, Fields, p_role_base),
    {atomic, ok} = mnesia:transform_table(db_role_base_p, TransFormer, Fields, p_role_base),
    ok.

update_db_role_pet_bag_record()->
    TransFormer = 
        fun(R) ->
               case R of
                   {p_role_pet_bag,RoleID,Content,Pets} ->
                       case is_list(Pets) of
                           true->
                               NewPets=[{p_pet_id_name,PetID,Name,Color,TypeID,Index,0,0}||{p_pet_id_name,PetID,Name,Color,TypeID,Index}<-Pets],
                               {p_role_pet_bag,RoleID,Content,NewPets};
                           false->
                               {p_role_pet_bag,RoleID,Content,Pets}
                       end;
                   _ ->
                       R
               end
        end,
    Fields = [role_id, content,pets],
    {atomic, ok} = mnesia:transform_table(db_role_pet_bag, TransFormer, Fields, p_role_pet_bag),
    {atomic, ok} = mnesia:transform_table(db_role_pet_bag_p, TransFormer, Fields, p_role_pet_bag).


update_db_shuaqi_role_record()->
    TransFormer = 
        fun(R) ->
               case R of
                   {r_role_sq_fb_info,RoleID,[]} ->
                       {r_role_sq_fb_info,RoleID,"",0,undefined,[]};
                   _ ->
                       R
               end
        end,
    Fields = [role_id, fb_map_name,enter_map_id,enter_pos,fb_info],
    {atomic, ok} = mnesia:transform_table(db_role_sq_fb_info, TransFormer, Fields, r_role_sq_fb_info),
    {atomic, ok} = mnesia:transform_table(db_role_sq_fb_info_p, TransFormer, Fields, r_role_sq_fb_info).

update_role_pos() ->
    TransFunc = fun(R) ->
                    case R of
                        {p_role_pos, RoleID, MapID, Pos} ->
                            case catch db:dirty_read(db_role_process_name, RoleID) of
                                [{r_role_map_process_name, RoleID, MapName, OldMapName}] ->
                                    {p_role_pos, RoleID, MapID, Pos, MapName, OldMapName};
                                _ ->
                                    MapName = common_map:get_common_map_name(MapID),
                                    {p_role_pos, RoleID, MapID, Pos, MapName, MapName}
                            end;
                        _ ->
                            R
                    end
                end,
    Fields = [role_id,map_id,pos,map_process_name,old_map_process_name],
    {atomic, ok} = mnesia:transform_table(db_role_pos, TransFunc, Fields, p_role_pos),
    {atomic, ok} = mnesia:transform_table(db_role_pos_p, TransFunc, Fields, p_role_pos),
    mnesia:delete_table(db_role_process_name).

