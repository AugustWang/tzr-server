-record(r_roleid_counter, {id, last_role_id}).
-record(r_account, {account_name, create_time, role_num}).

-record(r_bag_config,{typeid,rows,columns,grid_number}).
%% chat_time, team_time,fb_time 结构为 {Date,Times} or undefined
-record(r_friend,{roleid, friendid, type, friendly, chat_time, team_time, relative=[],fb_time}).
-record(r_friend_request, {roleid, request_roleid}).
-record(currency_type,{id, name, method}).
-record(r_shop_shops,{id, name, branchs, goods,time}).
%% bind: 1、 根据货币; 2、强制绑定 3、强制不绑定
%% price_bind: 1、不要求 2、一定绑定 3、一定不绑定
%% fixed_price 废弃字段
-record(r_shop_goods,{id, num, bind, modify, price_bind, price, fixed_price,time,role_grade,type,seat,discount_type}).
-record(price_time_list,{id, time, set_goods, recover_goods}).
-record(r_shop_npc,{id,shops}).
-record(r_monsterid_counter, {id, last_monster_id}).
-record(r_letter_info,{id, sender, receiver, title, send_time, out_time, goods_list, type, state=1, text="", goods_take=[]}).
-record(r_letter,{role_id,singles,manys,receives,count,send_time,send_count}).
-record(r_letter_sender,{role_id,single,many,count}).
-record(r_letter_receiver,{role_id,letter,count}).
-record(r_bank_sell, {price, sheet_id, num}).
-record(r_bank_buy, {price, sheet_id, num}).
-record(r_sheet_counter, {id, last_sheet_id}).
-record(r_shortcut_bar, {roleid, shortcut_list, selected}).
-record(r_gift,{id, type, gift_list}).

-record(r_sys_config, {roleid, sys_config}).
-record(r_big_hp_mp, {id,total,type,share}).
-record(r_monster_persistent_info,{monsterid,typeid,key,state,mapname,hp,mp,ext}).


-define(DB_ACCOUNT, db_account).
-define(DB_ACCOUNT_P, db_account_p).

-define(DB_ROLEID_COUNTER, db_roleid_counter).
-define(DB_ROLEID_COUNTER_P, db_roleid_counter_p).

%%角色内存表
-define(DB_ROLE_ATTR, db_role_attr).
-define(DB_ROLE_BASE, db_role_base).
-define(DB_ROLE_FIGHT, db_role_fight).
-define(DB_ROLE_POS, db_role_pos).
-define(DB_ROLE_EXT, db_role_ext).

%%角色持久表
-define(DB_ROLE_ATTR_P, db_role_attr_p).
-define(DB_ROLE_BASE_P, db_role_base_p).
-define(DB_ROLE_FIGHT_P, db_role_fight_p).
-define(DB_ROLE_POS_P, db_role_pos_p).
-define(DB_ROLE_EXT_P, db_role_ext_p).

%% table:背包表
-define(DB_ROLE_BAG_P, db_role_bag_p).
-define(DB_ROLE_BAG_BASIC_P, db_role_bag_basic_p).
%% role_bag_key = {role_id,bag_id},相当于联合主键
-record(r_role_bag,{role_bag_key,bag_goods}).%%{RoleID, BagID}
%% bag_basic_list = [{bag_id,bag_type_id,due_time,rows,columns}],玩家对应的背包状况
-record(r_role_bag_basic,{role_id,bag_basic_list}).


-define(DB_GOODS_MAP, goods_map).
-define(DB_FRIEND,db_friend).
-define(DB_FRIEND_REQUEST, db_friend_request).
-define(DB_CURRENCY_TYPE, currency_type).
-define(DB_SHOP_SHOPS, shop_shops).
-define(DB_SHOP_GOODS, shop_goods).
%% 新的促销表
-define(DB_SHOP_CUXIAO, db_shop_cuxiao).
-define(DB_SHOP_CUXIAO_P, db_shop_cuxiao_p).
-record(p_shop_cuxiao_item, {key, shop_id, item_id, num, begin_time, end_time, price}).
-record(r_shop_cuxiao_flag, {time, flag}).
-record(p_shop_cuxiao_config, {item_id, num, price}).
-define(DB_SHOP_CUXIAO_FLAG_P, db_shop_cuxiao_flag_p).

-define(DB_PRICE_TIME, price_time_table).
-define(DB_MONSTER_PERSISTENT_INFO, db_monster_persistent_info).
-define(DB_MONSTERID_COUNTER, db_monsterid_couter).
-define(DB_SHOP_NPC, shop_npc).
-define(DB_LETTER_SENDER, letter_sender).
-define(DB_LETTER_RECEIVER, letter_receiver).
-define(DB_BANK_SHEETS, db_bank_sheets).
-define(DB_BANK_SELL, db_bank_sell).
-define(DB_BANK_BUY, db_bank_buy).
-define(DB_SHEET_COUNTER, db_sheet_counter).
-define(DB_SHORTCUT_BAR, db_shortcut_bar).
-define(DB_SYSTEM_CONFIG, db_system_config).


-define(DB_GOODS_MAP_P, goods_map_p).
-define(DB_FRIEND_P,db_friend_p).
-define(DB_FRIEND_REQUEST_P, db_friend_request_p).
-define(DB_CURRENCY_TYPE_P, currency_type_p).
-define(DB_SHOP_SHOPS_P, shop_shops_p).
-define(DB_SHOP_GOODS_P, shop_goods_p).
-define(DB_PRICE_TIME_P, price_time_table_p).
-define(DB_MONSTER_PERSISTENT_INFO_P, db_monster_persistent_info_p).
-define(DB_MONSTERID_COUNTER_P, db_monsterid_couter_p).
-define(DB_SHOP_NPC_P, shop_npc_p).
-define(DB_LETTER_SENDER_P, letter_sender_p).
-define(DB_LETTER_RECEIVER_P, letter_receiver_p).
-define(DB_BANK_SHEETS_P, db_bank_sheets_p).
-define(DB_BANK_SELL_P, db_bank_sell_p).
-define(DB_BANK_BUY_P, db_bank_buy_p).
-define(DB_SHEET_COUNTER_P, db_sheet_counter_p).
-define(DB_SHORTCUT_BAR_P, db_shortcut_bar_p).
-define(DB_SYSTEM_CONFIG_P, db_system_config_p).



%% table:记录服务器中每个国家的角色的数量
-define(DB_ROLE_FACTION, db_role_faction).
-define(DB_ROLE_FACTION_P, db_role_faction_p).
-record(r_role_faction, {faction_id, number}).

%% table:记录玩家技能
-define(DB_ROLE_SKILL_P, db_role_skill_p).
-record(r_role_skill,{role_id,skill_list = []}).
%% skill_id 技能id
%% cur_level 技能当前级别
%% category 技能当前职业
-record(r_role_skill_info, {skill_id, cur_level, category}).



%%Npc Mission================================================================
%%mission_data=#mission_data{}
-record(r_db_mission_data, {role_id, mission_data}).
-define(DB_MISSION_DATA_P, db_mission_data_p).
%%Npc Mission================================================================


%%Team Begin================================================================
%% 终级玩家组队信息结构
%% team_id玩家创建队伍的时间时间戳
%% proccess_name 玩家队伍进程名称
%% role_list 队伍成员信息 [p_team_role,...]
%% next_bc_time 玩家下次通知组队进程时间
%% pick_type 物品拾取模式，1：自由拾取，2：独自拾取
%% invite_list 邀请列表[r_role_team_invite,...]
%% do_status 玩家当前处理状态 0正常，1邀请，2加入队伍
-record(r_role_team,{role_id,team_id = 0,proccess_name,role_list = [],next_bc_time = 0,
                     pick_type = 1,invite_list = [],do_status = 0}).
%% role_id 玩家id
%% invite_id 被邀请的玩家id
%% invite_type 玩家邀请类型  0 正常情况 1收徒 2 拜师
%% invite_time 邀请时间 
%% invite_status 邀请状态 0:合法，1:队长转移时队长之前的邀请，9:非法状态
-record(r_role_team_invite,{role_id,team_id = 0,invite_id,invite_type = 0,invite_time = 0,invite_status = 0}).
%%Team End================================================================

%%Stall
%% detail -> list [p_stall_good]
-record(r_role_stall, {roleid, state, detail}).

%%记录当前有哪些摊位 
-define(DB_STALL, db_stall).
-define(DB_STALL_P, db_stall_p).
-record(r_stall, {role_id, start_time, mode, time_hour, remain_time, name, role_name, tx, ty, mapid, use_silver, use_silver_bind}).

%%摆摊前放在摊位中的物品会记录下来的
-define(DB_STALL_GOODS_TMP, db_stall_goods_tmp).
-define(DB_STALL_GOODS_TMP_P, db_stall_goods_tmp_p).


%%记录所有玩家摊位中的物品
-define(DB_STALL_GOODS, db_stall_goods).
-define(DB_STALL_GOODS_P, db_stall_goods_p).
%% price_type价格类型：1、银两，2、元宝
-record(r_stall_goods, {id, role_id, stall_price, price_type, pos, goods_detail}).
%%用于保存玩家摆摊所获得的银两
-define(DB_STALL_SILVER, db_stall_silver).
-define(DB_STALL_SILVER_P, db_stall_silver_p).
-record(r_stall_silver, {role_id, get_silver, get_gold}).

%% ybc 1 个人 8 门派 3组队 trading 0 不是商贸状态，1 商贸状态
%% shou_bian 0 非守边状态 1守边状态 2守边超时
-record(r_role_state, {role_id, stall_auto=false, stall_self=false, fight=false, sitdown=false, normal=true, exchange=false, ybc=0, trading = 0, shou_bian = 0}).
-define(DB_ROLE_STATE, db_role_state).
-define(DB_ROLE_STATE_P, db_role_state_p).

%%门派相关持久化表
-define(DB_FAMILY_P, db_family_p).
-define(DB_FAMILY_COUNTER_P, db_family_counter_p).
-define(DB_FAMILY_INVITE_P, db_family_invite_p).
-define(DB_FAMILY_REQUEST_P, db_family_request_p).
-define(DB_FAMILY_EXT_P, db_family_ext_p).

%%门派对应的临时表
-define(DB_FAMILY, db_family).
-define(DB_FAMILY_COUNTER, db_family_counter).
-define(DB_FAMILY_INVITE, db_family_invite).
-define(DB_FAMILY_REQUEST, db_family_request).
-define(DB_FAMILY_EXT, db_family_ext).

%%称号对应的表
-record(r_title_counter,{id,last_title_id}).
-define(DB_NORMAL_TITLE, db_normal_title).
-define(DB_NORMAL_TITLE_P, db_normal_title_p).
-define(DB_SPEC_TITLE,db_spec_title).
-define(DB_SPEC_TITLE_P,db_spec_title_p).
-define(DB_TITLE_COUNTER,db_title_counter).
-define(DB_TITLE_COUNTER_P,db_title_counter_p).



-record(r_family_counter, {id, value}).

-record(r_family_ext, {family_id, 
						last_set_owner_time,
            common_boss_called,
            common_boss_killed,
            common_boss_call_time=0,    %%普通BOSS的召唤日期，注意这里是日期
						last_ybc_finish_date={0, 0, 0}, %% 上次接镖结束日期 {Y, M, D}
						last_ybc_begin_time=0, %% 上次接镖开始时间，单位为秒
						last_ybc_result=none,	%% 上次接镖的结果
						ybc_id=0, 
						ybc_role_list, %% [{role_id, silver}, ...]
            last_resume_time, %%上次扣除地图费用时间
						last_card_use_count = 0,
						last_card_use_day = {0,0,0},
						last_deliver_dist_pos = 0,  %% 上一次传送的地点,默认为零,查到为0则不传送
            common_boss_call_count = 0  %% 普通BOSS的今日召唤次数 
}).

%% 门派降低补偿
-record(r_family_level_reduce, {level, money, ac}).

-record(r_family_event_log,{
	  mdate, %%记录时间,时间戳
	  content %%必须通过对用的函数来生成内容,其中会包含颜色信息
}).


%%出生点
-record(r_born_point, {mapid, tx, ty}).

%% 消息广播
-define(DB_BROADCAST_MESSAGE, db_broadcast_message).
-define(DB_BROADCAST_MESSAGE_P, db_broadcast_message_p).
-record(r_broadcast_message,{id,foreign_id,unique,msg_type,msg_record,create_time,expected_time,send_time,send_times,send_flag,send_desc}).


-record(r_role_map_process_name, {role_id, map_process_name, old_map_process_name}).

%%系统群成员表
%%#p_chat_group_member_info
-define(DB_CHAT_CHANNEL_ROLES, db_chat_channel_roles).
-define(DB_CHAT_CHANNEL_ROLES_P, db_chat_channel_roles_p).

-define(DB_CHAT_ROLE_CHANNELS, db_chat_role_channels).
-define(DB_CHAT_ROLE_CHANNELS_P, db_chat_role_channels_p).
-record(r_chat_role_channel_info, {role_id, channel_sign, channel_type}).

%%#p_chat_channel_info
-define(DB_CHAT_CHANNELS, db_chat_channels).
-define(DB_CHAT_CHANNELS_P, db_chat_channels_p).

-define(DB_ROLE_EDUCATE, db_role_educate).
-define(DB_ROLE_EDUCATE_P, db_role_educate_p).
-record(r_educate_role_info,{roleid,faction_id,level,sex,title,name,exp_gifts1,exp_gifts2,exp_devote1,exp_devote2,moral_values,teacher,teacher_name,students,student_num,max_student_num, expel_time,dropout_time,online,apprentice_level,release_info}).
-record(r_release_info,{rel_admissions=false,rel_adm_msg="",rel_adm_time=0,rel_apprentice=false,rel_app_msg="",rel_app_time=0}).
-record(r_fcm_data, {account, card, truename, offline_time=0,  total_online_time=0, passed=false}).
-define(DB_FCM_DATA, db_fcm_data).
-define(DB_FCM_DATA_P, db_fcm_data_p).

%% 记录镖车的详情
-define(DB_YBC, db_ybc).
-define(DB_YBC_P, db_ybc_p).

%% 用于判断镖车是否已经创建
-define(DB_YBC_UNIQUE, db_ybc_unique).
-define(DB_YBC_UNIQUE_P, db_ybc_unique_p).

%% 镖车ID表
-define(DB_YBC_INDEX, db_ybc_index).
-define(DB_YBC_INDEX_P, db_ybc_index_p).

-record(r_ybc_index, {id, value}).
%% unique : {group_type, group_id, creator_id} group_type-->1 个人 2 门派 
-record(r_ybc_unique, {unique, id}).

%% 这里镖车的其他属性 role_list: [{role_id, role_name, level, bind_silver, silver}, ...]
-record(r_ybc, {ybc_id, status, role_list, map_id, hp, max_hp, pos, move_speed, name, create_type, creator_id, faction_id, group_id, group_type, physical_defence, magic_defence, recover_speed, buffs, create_time, end_time, color, can_attack, level}).

%% 个人拉镖信息表
%% last_auto_date  		最后一次自动拉镖的日期
%% auto 				是否默认自动拉镖
-record(r_ybc_person, {role_id, last_complete_time, do_times, complete_times, current_color, color_change_times=0, last_auto_date={0,0,0}, auto=false}).
-define(DB_YBC_PERSON, db_ybc_person).
-define(DB_YBC_PERSON_P, db_ybc_person_p).

-define(DB_KEY_PROCESS, db_key_process).
-record(r_key_process, {name, node}).


-define(DB_MAP_ONLINE, db_map_online).
-define(DB_MAP_ONLINE_P, db_map_online_p).
-record(r_map_online, {map_name, map_id, online,node}).

%%Ranking Begin================================================================
%% 角色等级排行榜
-define(DB_ROLE_LEVEL_RANK, db_role_level_rank).
-define(DB_ROLE_LEVEL_RANK_P, db_role_level_rank_p).
-define(DB_ROLE_PKPOINT_RANK, db_role_pkpoint_rank).
-define(DB_ROLE_PKPOINT_RANK_P, db_role_pkpoint_rank_p).
-define(DB_ROLE_WORLD_PKPOINT_RANK, db_role_world_pkpoint_rank).
-define(DB_ROLE_WORLD_PKPOINT_RANK_P, db_role_world_pkpoint_rank_p).
-define(DB_FAMILY_ACTIVE_RANK, db_family_active_rank).
-define(DB_FAMILY_ACTIVE_RANK_P, db_family_active_rank_p).
-define(DB_EQUIP_REFINING_RANK, db_equip_refining_rank).
-define(DB_EQUIP_REFINING_RANK_P, db_equip_refining_rank_p).
-define(DB_EQUIP_REINFORCE_RANK, db_equip_reinforce_rank).
-define(DB_EQUIP_REINFORCE_RANK_P, db_equip_reinforce_rank_p).
-define(DB_EQUIP_STONE_RANK, db_equip_stone_rank).
-define(DB_EQUIP_STONE_RANK_P, db_equip_stone_rank_p). 
-define(DB_ROLE_GONGXUN_RANK, db_role_gongxun_rank).
-define(DB_ROLE_GONGXUN_RANK_P, db_role_gongxun_rank_p).
-define(DB_ROLE_TODAY_GONGXUN_RANK, db_role_today_gongxun_rank).
-define(DB_ROLE_TODAY_GONGXUN_RANK_P, db_role_today_gongxun_rank_p).
-define(DB_ROLE_YESTERDAY_GONGXUN_RANK, db_role_yesterday_gongxun_rank).
-define(DB_ROLE_YESTERDAY_GONGXUN_RANK_P, db_role_yesterday_gongxun_rank_p).
-define(DB_FAMILY_GONGXUN_PERSISTENT_RANK, db_family_gongxun_persistent_rank).
-define(DB_FAMILY_GONGXUN_PERSISTENT_RANK_P, db_family_gongxun_persistent_rank_p).
%%送花排行榜（送花谱，今日送花榜，昨日送花榜）
-define(DB_ROLE_GIVE_FLOWERS_RANK, db_role_give_flowers_rank). 
-define(DB_ROLE_GIVE_FLOWERS_RANK_P, db_role_give_flowers_rank_p).
-define(DB_ROLE_GIVE_FLOWERS_TODAY_RANK, db_role_give_flowers_today_rank).
-define(DB_ROLE_GIVE_FLOWERS_TODAY_RANK_P,db_role_give_flowers_today_rank_p).
-define(DB_ROLE_GIVE_FLOWERS_YESTERDAY_RANK, db_role_give_flowers_yesterday_rank).
-define(DB_ROLE_GIVE_FLOWERS_YESTERDAY_RANK_P,db_role_give_flowers_yesterday_rank_p).
-define(DB_ROLE_GIVE_FLOWERS_LAST_WEEK_RANK, db_role_give_flowers_last_week_rank).
-define(DB_ROLE_GIVE_FLOWERS_LAST_WEEK_RANK_P,db_role_give_flowers_last_week_rank_p).
-define(DB_ROLE_GIVE_FLOWERS_THIS_WEEK_RANK, db_role_give_flowers_this_week_rank).
-define(DB_ROLE_GIVE_FLOWERS_THIS_WEEK_RANK_P,db_role_give_flowers_this_week_rank_p).
-define(DB_ROLE_PET_RANK, db_role_pet_rank).
-define(DB_ROLE_PET_RANK_P, db_role_pet_rank_p).


%%鲜花排行榜（百花谱，今日鲜花榜，昨日鲜花榜）
-define(DB_ROLE_RECE_FLOWERS_RANK, db_role_rece_flowers_rank).
-define(DB_ROLE_RECE_FLOWERS_RANK_P,db_role_rece_flowers_rank_p).
-define(DB_ROLE_RECE_FLOWERS_TODAY_RANK, db_role_rece_flowers_today_rank).
-define(DB_ROLE_RECE_FLOWERS_TODAY_RANK_P, db_role_rece_flowers_today_rank_p).
-define(DB_ROLE_RECE_FLOWERS_YESTERDAY_RANK, db_role_rece_flowers_yesterday_rank).
-define(DB_ROLE_RECE_FLOWERS_YESTERDAY_RANK_P, db_role_rece_flowers_yesterday_rank_p).
-define(DB_ROLE_RECE_FLOWERS_LAST_WEEK_RANK, db_role_rece_flowers_last_week_rank).
-define(DB_ROLE_RECE_FLOWERS_LAST_WEEK_RANK_P, db_role_rece_flowers_last_week_rank_p).
-define(DB_ROLE_RECE_FLOWERS_THIS_WEEK_RANK, db_role_rece_flowers_this_week_rank).
-define(DB_ROLE_RECE_FLOWERS_THIS_WEEK_RANK_P, db_role_rece_flowers_this_week_rank_p).
%%Ranking End================================================================



%%封禁ip,封禁账号表,禁言表
-define(DB_BAN_USER,db_ban_user).
-define(DB_BAN_USER_P,db_ban_user_p).


-define(DB_BAN_IP,db_ban_ip).
-define(DB_BAN_IP_P,db_ban_ip_p).

-define(DB_BAN_CHAT_USER,db_ban_chat_user).
-define(DB_BAN_CHAT_USER_P,db_ban_chat_user_p).

-define(DB_BAN_CONFIG_P,db_ban_config_p).

-record(r_ban_user,{rolename,deadline,adminid}).
-record(r_ban_ip,{ip,deadline,adminid}).

%%禁言记录
    %% duration - integer() - 封禁时长，单位：分钟
    %% type - integer() - 禁言者(0:GM/神眼/后台;1国王/皇帝
-record(r_ban_chat_user,{role_id,role_name,time_start,time_end,duration,reason,type}).
    %% type - integer() - 禁言类型(0:GM/神眼/后台;1国王/皇帝
-record(bankey,{type=1,roleid}).
-record(r_ban_config,{ban_key=#bankey{roleid=0},ban_times=0,todays}).

%%============= 
-define(DB_WAROFKING_HISTORY_P, db_warofking_history_p).
-define(DB_WAROFKING_HISTORY, db_warofking_history).

-define(DB_WAROFKING_HISTORY_INDEX_P, db_warofking_history_index_p).
-define(DB_WAROFKING_HISTORY_INDEX, db_warofking_history_index).

-record(r_warofking_history, {index, begin_time, end_time, condition_families, join_families, winner_family_1, winner_family_2, winner_family_3}).
-record(r_warofking_history_index, {id, value}).


%%当前在线用户表
-define(DB_USER_ONLINE, db_user_online).


%% 在线用户列表
-record(r_role_online,{role_id, role_name, account_name, faction_id, family_id, login_time, login_ip, line}).





%%---------------------训练营-----------------------
-record(r_training_camp, {role_id, training_point=0, start_time, last_time, in_training=false}).

-define(DB_TRAINING_CAMP, db_training_camp).
-define(DB_TRAINING_CAMP_P, db_training_camp_p).

%%-----------------------
-record(r_skill_time, {role_id, last_use_time}).

-define(DB_SKILL_TIME, db_skill_time).
-define(DB_SKILL_TIME_P, db_skill_time_p).
-define(DB_PAY_LOG, db_pay_log).
-define(DB_PAY_LOG_P, db_pay_log_p).

-define(DB_PAY_LOG_INDEX, db_pay_log_index).
-define(DB_PAY_LOG_INDEX_P, db_pay_log_index_p).

-record(r_pay_log, {id, order_id, role_id, role_name, account_name, pay_time, pay_gold, pay_money, year, month, day, hour, role_level, is_first}).
-record(r_pay_log_index, {id, value}).


%% 官职与国家结构
-define(DB_FACTION, db_faction).
-define(DB_FACTION_P, db_faction_p).

%%国战记录
-define(DB_WAROFFACTION_RECORD, db_waroffaction_record).
-define(DB_WAROFFACTION_RECORD_P, db_waroffaction_record_p).
-record(r_waroffaction_counter, {key,last_record_id}).
-define(DB_WAROFFACTION_COUNTER, db_waroffaction_counter).
-define(DB_WAROFFACTION_COUNTER_P, db_waroffaction_counter_p).

%% 地图争夺战
-define(DB_WAROFCITY, db_warofcity).
-define(DB_WAROFCITY_P, db_warofcity_p).

-define(DB_WAROFCITY_APPLY, db_warofcity_apply).
-define(DB_WAROFCITY_APPLY_P, db_warofcity_apply_p).
%% 一并记录某个地图有哪些门派参与争夺，总的资金已经有多少了
-record(r_warofcity_apply, {family_id, family_name, map_id}).

%% 玩家成就表
-define(DB_ROLE_ACHIEVEMENT_P,db_role_achievement_p).
%% achievements = [r_role_achievement,..] 玩家成就列表
%% lately_achievements = [r_role_achievement,...] 最近完成成就列表
%% stat_info %% 成就统计信息 [r_role_achievement_stat_info,...]
-record(r_db_role_achievement,{role_id,achievements = [],lately_achievements = [],stat_info = []}).
%% achieve_group_id 组id achieve_id成就id,status当前状态,
%% achieve_type 成就类型 0子成就 1组成就
%% event事件列表[r_role_achievement_event,...]，create_time创建时间，complete_time完成时间，award_time领奖时间
-record(r_role_achievement,{achieve_id,class_id = 0,group_id = 0,achieve_type = 0,status = 0,event = [],
                            create_time,complete_time,award_time,cur_progress = 0,total_progress = 0}).
%% event_id事件id,event_status事件状态 0 未完成 1已完成
-record(r_role_achievement_event,{event_id,event_status}).
%% type 类型 0 全部 class_id 成就分类id 
%% cur_progress 当前已经完成的进度
%% award_point 此分类成就获得的成就点
-record(r_role_achievement_stat_info,{type,cur_progress = 0,award_point = 0}).

%% 全服成就表
-define(DB_ACHIEVEMENT_RANK_P,db_achievement_rank_p).
%% role_id 完成此成就玩家id
%% role_name 完成此成就玩家的名称
%% faction_id 完成此成就玩家的国家 
-record(r_achievement_rank,{achieve_id,class_id = 0,group_id = 0,achieve_type = 0,status = 0,event = [],
                            create_time,complete_time = 0,award_time = 0,cur_progress = 0,total_progress = 0,
                            role_id=0,role_name,faction_id=0}).

%% 记录当前正在进行中的王座争霸战
-define(DB_WAROFKING, db_warofking).
-define(DB_WAROFKING_P, db_warofking_p).
%% 当前事件表记录 type 为类型，定义在 event_type.hrl中， status为各个事件的私有状态
-record(db_warofking, {faction_id, begin_time, end_time, status, join_families, condition_families}).

%% 逐鹿天下副本表
%% 逐鹿天下副本日志表
-define(DB_VIE_WORLD_FB_LOG_P,db_vie_world_fb_log_p).
-define(DB_VIE_WORLD_FB_LOG,db_vie_world_fb_log).

%%NPC持久化信息
-define(DB_SERVER_NPC_PERSISTENT_INFO_P,db_server_npc_persistent_info_p).
-define(DB_SERVER_NPC_PERSISTENT_INFO,db_server_npc_persistent_info).
-record(r_server_npc_persistent_info,{npc_id,type_id,key,state,mapname,hp,mp,ext}).

%% 逐鹿天下副本日志记录
%% role_id 玩家id,faction_id国家id,map_id地图id,pos地图位置，in_time进入副本时间，ount_time退出副本时间
%% status 0进入副本，1成功完成副本，2未完成副本，3，掉线，4 退出队伍，5 死亡回城
-record(r_vie_world_fb_log,{role_id,role_name,account_name,faction_id,npc_id,map_id,pos,in_time,out_time,status}).
%% 玩家讨伐敌营副本日志
-record(r_vwf_log,{faction_id = 0,map_id = 0,map_name = "",npc_id = 0,vwf_monster_level = 0,start_time = 0,
status = 0,in_vwf_role_ids = "",in_vwf_role_names= "",in_vwf_number = 0,
end_time = 0,out_vwf_role_ids = "",out_vwf_number = 0,leader_role_id = 0,deal_state = 0,leader_role_name = ""}).

-record(r_vwf_role_log,{faction_id = 0,map_id = 0,map_name = "",npc_id = 0,vwf_monster_level = 0,
start_time = 0,role_id = 0,role_name = "",end_time = 0,leader_role_id = 0,leader_role_name = ""}).

-define(DB_ROLE_BAG2, db_role_bag2).

-record(r_role_bag2, {role_id, bags}).

%% 系统配置信息表
-define(DB_CONFIG_SYSTEM_P, db_config_system_p).
%% 系统配置record结构
-record(r_config_system, {key, value}).

%% 一键换装表
-define(DB_EQUIP_ONEKEY, db_equip_onekey).
-define(DB_EQUIP_ONEKEY_P, db_equip_onekey_p).
-record(r_equip_onekey, {role_id, equips_list}).


-define(DB_MAP_EVENT_TIMER, db_map_event_timer).
-define(DB_MAP_EVENT_TIMER_P, db_map_event_timer_p).
%%next_time-->如果为0则该记录可以删除,如果不为0,那么
%%info_type
%%    {map, MapIDS}
%%    {role_map, RoleIDS}
%%time_type-->时间类型
%%time-->时间
-record(r_map_event_timer, {id, time_type, time, info_type, info}).

-define(DB_COUNTER, db_counter).
-define(DB_COUNTER_P, db_counter_p).
-record(r_counter, {key, value=0}).
-define(DB_WORLD_COUNTER,db_world_counter).
-define(DB_WORLD_COUNTER_P,db_world_counter_p).
-record(r_world_counter,{key,value=0}).

-define(DB_EVENT_STATE, db_event_state).
-define(DB_EVENT_STATE_P, db_event_state_p).
-record(r_event_state, {key, data}).

%% 商贸活动持久化数据表
-define(DB_ROLE_TRADING_P,db_role_trading_p).
-define(DB_ROLE_TRADING,db_role_trading).
%% role_id 玩家id bill 商票金额:文  max_bill 商票价值上限：文,trading_times 商贸次数
%% map_id 地图id npc_id 商店NPC ID
%% status 商贸状态 1 领取 2 交还 3 销毁 4 人工清理
%% start_time 领取商票时间 last_bill 最终商票价值：文 end_time,交还商票时间 
%% goods 物品信息 p_trading_goods, family_money 门派收益 family_contribution 门派贡献度
%% role_trading_bill 玩家当前商贸商票信息 r_role_trading_bill award_type 奖励类型 1 银子，2 绑定银子
-record(r_role_trading,{role_id,map_id,npc_id,bill = 0,max_bill = 0,
trading_times = 0,status = 0,start_time,last_bill = 0,family_money = 0,
family_contribution = 0,end_time = 0,goods = [],role_trading_bill,award_type = 0}).
%% role_id 玩家id role_name 玩家名称 role_level 玩家级别 faction_id 国家id,
%% family_id 门派id family_name 门派名称 bill 商票金额：文 max_bill 商票价值上限：文 trading_times 商贸次数 
%% status商贸状态 start_time 领取商票时间 last_bill 最终商票价值 end_time 交还商票时间
%% family_money 门派收益 family_contribution 门派贡献度 base_bill 商票基本价值 award_type 奖励类型 1 银子，2 绑定银子
-record(r_role_trading_log,{role_id,role_name,role_level,faction_id,family_id,family_name,
base_bill = 0,bill = 0,max_bill = 0,trading_times = 0,status = 0,start_time = 0,last_bill = 0,
family_money = 0,family_contribution = 0,end_time = 0,award_type = 0}).
%%赠送鲜花
-define(DB_ROLE_GIVE_FLOWERS, db_role_give_flowers).
-define(DB_ROLE_GIVE_FLOWERS_P, db_role_give_flowers_p).
-record(r_give_flowers,{role_id,score=0}).
%%鲜花接收
-define(DB_ROLE_RECEIVE_FLOWERS, db_role_receive_flowers).
-define(DB_ROLE_RECEIVE_FLOWERS_P, db_role_receive_flowers_p).
-record(r_receive_flowers,{role_id,flowers=[],count=1,charm=0}).


-define(DB_MONEY_EVENT_COUNTER, db_role_money_event_counter).
-define(DB_MONEY_EVENT_COUNTER_P, db_role_money_event_counter_p).
-define(DB_MONEY_EVENT, db_money_event).
-define(DB_MONEY_EVENT_P, db_money_event_p).
-record(r_money_event_counter, {id, event_id}).
-record(r_money_event, {event_id, role_id, event_info, money_change, state}).


%%记录角色事件表
-define(DB_USER_EVENT_COUNTER, db_user_event_counter).
-define(DB_USER_EVENT_COUNTER_P, db_user_event_counter_p).
-define(DB_USER_EVENT, db_user_event).
-define(DB_USER_EVENT_P, db_user_event_p).
-record(r_user_event_counter, {id, value}).
-record(r_user_event, {id, role_id, type, data}).

%%种植模块的表
%%门派对应的种植数据
-define(DB_FAMILY_PLANT, db_family_plant).
-define(DB_FAMILY_PLANT_P, db_family_plant_p).
%% farm_list 田地列表  => list( p_farm_info )
-record(r_family_plant,{family_id,farm_list,max_farm_id}).

%%个人对应的种植数据
-define(DB_ROLE_PLANT, db_role_plant).
-define(DB_ROLE_PLANT_P, db_role_plant_p).
%% r_role_plant,{role_id,田地ID,当前技能,当前熟练度,剩余施肥次数,给自己的施肥次数}
-record(r_role_plant,{role_id,farm_id,cur_skill_level,cur_proficiency,remain_fertilize_times,self_fertilize_times}).

%%个人对应的种植日志
-define(DB_ROLE_PLANT_LOG, db_role_plant_log).
-define(DB_ROLE_PLANT_LOG_P, db_role_plant_log_p).
%% logs 字符串日志的列表 => list( string )
-record(r_role_plant_log,{role_id,logs}).

-define(DB_ROLE_LEVEL_GIFT, db_role_level_gift).
-define(DB_ROLE_LEVEL_GIFT_P,db_role_level_gift_p).     
-record(r_role_level_gift,{role_id,gifts=[]}).

%% 时间礼包
-define(DB_ROLE_TIME_GIFT, db_role_time_gift).
-define(DB_ROLE_TIME_GIFT_P,db_role_time_gift_p).     
-record(r_role_time_gift,{role_id,gifts}).

%% 礼包表定义玩家以后的其它礼包都包含处理
-define(DB_ROLE_GIFT,db_role_gift).
-define(DB_ROLE_GIFT_P,db_role_gift_p).
%% gifts 玩家礼包信息 [r_role_gift_info,...]
-record(r_role_gift,{role_id,gifts = []}).
%% gift_type 为礼包类型 1:道具礼包 2:等级礼包 3:时间礼包
%% cur_gift 未定义结构，不同的礼可以存放不同的结构
%% expand_field 扩展字段 结构未定义
%% status 礼包状态自己定义 默认为0
-record(r_role_gift_info,{gift_type,cur_gift,status = 0,expand_field}).

%% 玩家活动状态表（主要是节日活动）
-define(DB_ROLE_ACTIVITY, db_role_activity).
-define(DB_ROLE_ACTIVITY_P, db_role_activity_p).
%% activitys 玩家活动信息 结构为 [r_role_activity_info,...]
-record(r_role_activity,{role_id,activitys = []}).
%% 玩家活动详细信息 
%% key 活动标志
%% complete_times 完成次数 complete_time 最后一次完成时间 award_times 领奖次数 award_time 最后一次领取时间
-record(r_role_activity_info,{key,complete_times = 0,complete_time = 0,award_times = 0,award_time = 0}).

-define(DB_PAY_ACTIVITY_P, db_pay_activity_p).

%%首充活动记录
%% role_id 角色id
%% all_pay_gold 累积充值的元宝
%% get_first 玩家已领取首充礼包
%% accumulate_history 累积充值领取记录
%% single_history 单次充值领取记录
-record(r_pay_activity, {role_id, all_pay_gold=0, get_first=false, accumulate_history=[]}).

%% 首充赠送规则
%% gain_gold 充了多少元宝或者以上
%% gift_id   奖励的礼包ID
-record(r_pay_activity_info, {gain_gold, gift_id}).

%% 国战，记录国战相关状态
-define(DB_WAROFFACTION, db_waroffaction).
-define(DB_WAROFFACTION_P, db_waroffaction_p).
%% 只有一条纪录，KEY为1，war_status：国战状态，attack_faction_id：攻击国，defen_faction_id：防守国
-record(r_waroffaction, {key, war_status, attack_faction_id, defence_faction_id}).


%% 记录玩家下线日志
-record(r_user_offline, {account_name, offline_time, offline_reason_no}).


%%宠物系统
-define(DB_PET, db_pet).
-define(DB_PET_P, db_pet_p).
-define(DB_PET_FEED, db_pet_feed).
-define(DB_PET_FEED_P, db_pet_feed_p).
-define(DB_ROLE_PET_GROW, db_role_pet_grow).
-define(DB_ROLE_PET_BAG, db_role_pet_bag).
-define(DB_ROLE_PET_BAG_P, db_role_pet_bag_p).
-define(DB_PET_EGG, db_pet_egg).
-define(DB_PET_EGG_P, db_pet_egg_p).

%% 角色数据是否载入的映射表
-define(DB_USER_DATA_LOAD_MAP_P, db_user_data_load_map_p).
-record(r_user_data_load_map, {role_id, load_time}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 刺探
-define(DB_SPY, db_spy).
-define(DB_SPY_P, db_spy_p).
%% to_faction_count: 国家计数，last_time_accept: 上次接任务时间
-record(r_spy, {role_id, last_time_accept, last_choices, to_faction_times}).
-define(DB_ROLE_NAME_P, db_role_name_p).
-define(DB_ROLE_NAME, db_role_name).

-record(r_role_name, {role_name, role_id}).

-define(DB_FAMILY_NAME_P, db_family_name_p).
-define(DB_FAMILY_NAME, db_family_name).

-record(r_family_name, {family_name, family_id}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 师门同心副本
-define(DB_EDUCATE_FB_P,db_educate_fb_p).
-define(DB_EDUCATE_FB,db_educate_fb).
%% role_id 玩家id status 玩家师门副本状态 0 无状态 1 进行 2 完成 3 领奖
%% times 次数 count 分数 start_time 开始时间 end_time 结束时间
%% map_id,pos 玩家进入副本前所在的地图id 和位置信息结构为p_pos
%% fb_map_name 副本进程名称
%% income_item_count 使用赌博道具次数
%% award_list 师徒副本获得的奖励道具 p_goods
%% bc_list 获得的道具奖励是否要广播 [0,1,0] 0不广播 1广播
-record(r_educate_fb,{role_id,role_name,faction_id,level,status = 0,times = 0,
count = 0,lucky_count = 0,start_time = 0,end_time = 0,map_id,pos,fb_map_name,income_item_count = 0,
award_time = 0,award_list = [],bc_list = []}).
%% 师门同心副本日志记录
-record(r_educate_fb_log,{faction_id,leader_role_id,leader_role_name,monster_level = 0,
start_time = 0,status = 0,end_time = 0,count = 0,in_role_ids,in_role_names,out_role_ids,
in_number = 0,out_number = 0,dead_times = 0}).
%% 师门同心副本玩家日志记录
-record(r_educate_fb_role_log,{faction_id,role_id,role_name,leader_role_id,leader_role_name,
monster_level = 0,start_time = 0,status = 0,end_time = 0,count = 0, times = 0,lucky_count = 0,
dead_times = 0}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 赠送模块
%% table:记录服务器中每个国家的角色的数量
-define(DB_ROLE_PRESENT, db_role_present).
-define(DB_ROLE_PRESENT_P, db_role_present_p).
%% present_list 是tuple的list;其元素是{present_id,num}，表示赠送ID及其领取的次数
-record(r_role_present, {role_id, present_list}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 门派技能模块
%% table:记录服务器中每个国家的角色的数量
-define(DB_FAMILY_SKILL_RESEARCH, db_family_skill_research).
-define(DB_FAMILY_SKILL_RESEARCH_P, db_family_skill_research_p).
%%  research_key = {family_id,skill_id}
-record(r_family_skill_research, {research_key, family_id, skill_id, cur_level}).



%% 连续登录奖励
-define(DB_ROLE_CONLOGIN_P, db_role_conlogin_p).

%% role_id 					角色id
%% con_day 					角色已经连续登录的天数
%% last_con_refresh_date 	最后一次刷新连续登录天数的日期
%% not_show_date			用来判断当天是否不显示连续登录界面
%% last_login_date			最后一次登录的日期
%% fetch_history 			已经领取的奖励列表, {id, num} 
%%								num表示领取的数量，只在收费奖励时有用
%% login_days				到目前为止玩家总共登录过多少天了，当天登录过则+1，否则不变
-record(r_role_conlogin, {role_id, con_day=0, last_con_refresh_date, not_show_date, last_login_date, fetch_history=[]}).

%% 个人副本
-define(DB_PERSONAL_FB_P, db_personal_fb_p).
-define(DB_PERSONAL_FB, db_personal_fb).
%% fb_id				副本ID，目前1－10
%% base_time			最短时间
%% winner_id			最短时间的角色ID
%% time_finish			完成时间
%% winner_faction_id	纪录保持者国家ID
-record(r_personal_fb, {fb_id, time_used, winner_id, time_finish}).

-define(DB_ROLE_PERSONAL_FB_P, db_role_personal_fb_p).
-define(DB_ROLE_PERSONAL_FB, db_role_personal_fb).
%% role_id				角色ID
%% fb_info				r_role_fb_info列表
%% last_time_finish		上次完成时间
%% today_count			今天完成次数
-record(r_role_personal_fb, {role_id, fb_info, last_time_accept, today_count, lost_time, last_fb_passed, exp_get}).
%% fb_id				副本ID
%% 
-record(r_role_fb_info, {fb_id, best_record, state}).

%% 系统公告
-define(DB_SYSTEM_NOTICE_P, db_system_notice_p).
-record(r_system_notice, {id, notice}).

%% 离线消息
-define(DB_OFFLINE_MSG, db_offline_msg).
-define(DB_OFFLINE_MSG_P, db_offline_msg_p).
-record(r_offline_msg,{role_id,msg_list=[]}).

%%%%%% table:记录每个玩家的日常福利
-define(DB_ROLE_ACTIVITY_BENEFIT, db_role_activity_benefit).
-define(DB_ROLE_ACTIVITY_BENEFIT_P, db_role_activity_benefit_p).
%% role_id:int()
%% buy_count:int() 当天购买勋章的次数
%% act_bnft_list:list() 活动任务的列表  [{act_task_id,finish_date}]
-record(r_role_activity_benefit, {role_id,reward_date,buy_date,buy_count=0,act_bnft_list=[]}).

%%%%%% table:记录每个玩家的日常活动
-define(DB_ROLE_ACTIVITY_TASK, db_role_activity_task).
-define(DB_ROLE_ACTIVITY_TASK_P, db_role_activity_task_p).
%% role_id:int()
%% act_task_list:list() 活动任务的列表  [{act_task_id,finish_date,finish_times}]
-record(r_role_activity_task, {role_id,act_task_list=[]}).

%%%%%% table:记录玩家坐骑的部分信息
-define(DB_ROLE_MOUNT, db_role_mount).
-define(DB_ROLE_MOUNT_P, db_role_mount_p).
%% color_weights:list() tuple_list刷坐骑的当前权重列表
-record(r_role_mount, {role_id,color_weights}).

%%%%%% table:玩家参与门派活动的记录，包括领取门派BUFF
-define(DB_ROLE_FAMILY_PARTTAKE, db_role_family_parttake).
-define(DB_ROLE_FAMILY_PARTTAKE_P, db_role_family_parttake_p).
%% com_boss_date:date() 参与门派BOSS活动的日期（普通boss）
%% family_ybc_date:date() 参与门派拉镖活动的日期
%% get_buff_date:date()  领取门派技能福利的日期
%% fmldepot_getout_date:date()  从门派仓库取出物品的日期
%% fmldepot_getout_times:int()  当天从门派仓库取出物品的次数
-record(r_role_family_parttake, {role_id,com_boss_date,family_ybc_date,fetch_buff_date,fmldepot_getout_date,fmldepot_getout_times=0}).


%%%%%% table:门派仓库的背包表
-define(DB_FAMILY_DEPOT, db_family_depot).
-define(DB_FAMILY_DEPOT_P, db_family_depot_p).
%% depot_key:tuple  {family_id,bag_id}
%% bag_goods:list() [p_goods]
-record(r_family_depot, {depot_key,bag_goods}).

%%%%%% table:门派的一些基本资产表
%%门派的资产表，主要存放一些基本的数据，例如门派仓库数目
-define(DB_FAMILY_ASSETS, db_family_assets).
-define(DB_FAMILY_ASSETS_P, db_family_assets_p).
%% bag_num:integer() 仓库的背包个数
-record(r_family_assets, {family_id,bag_num}).


%% 玩家累积经验记录表
-define(DB_ROLE_ACCUMULATE_EXP_P, db_role_accumulate_exp_p).
%% id 累积活动类型，定义在 map ->  mod_accumulate_exp.erl 中
%% days		已经多少天没有作对应的任务了
%% rate		当前可以领取的经验比例是多少，默认是10%，存储时的值是10
%% last_done_level	最后一次做这个任务或者活动的等级，用于计算经验
-record(r_accumulate_exp_info, {id, days, last_done_date, rate, last_done_level}).
%% role_id 角色ID
%% list 玩家的累积经验详情列表，每个元素为一个 r_accumulte_info, 如果找不到对应的r_accumulte_info，则说明玩家之前没有做过该任务
-record(r_role_accumulate_exp, {role_id, list=[]}).

%% VIP表
-define(DB_ROLE_VIP_P, db_role_vip_p).


%%%%%%%%% 信件模块重构  %%%%%%%%%%%%%%%%%%%
%%%%%%%%% 私人信件表  
-define(DB_PERSONAL_LETTER,db_personal_letter_p).
-define(DB_PERSONAL_LETTER_P,db_personal_letter_p).
%% id:int() 信件id
%% send_id:integer() 发件人的id
%% recv_id:integer() 收件人id
%% del_type:integer() 删除类型 0:都没删 ，-1:发件人删除，1:收件人删除
%% send_name:string() 发件人姓名
%% recv_name:strint() 收件人姓名
%% send_time:date() 发信时间
%% out_time:date() 信件过期时间
%% goods_list:list() [p_goods] 交易物品
%% type:int() 信件类型：私人，门派，系统，gm ，后台
%% state:int() 信件状态：没打开，打开没收物品,打开收取物品  
%% title:string() 信件标题
%% text:string() 信件内容
-record(r_personal_letter,{id,send_id,recv_id,del_type=0,send_name,recv_name,send_time,out_time,goods_list=[],type,send_state=1,recv_state=1,title,text=""}).

%%%%%%%% 群体信件表
-define(DB_PUBLIC_LETTER,db_public_letter_p).
-define(DB_PUBLIC_LETTER_P,db_public_letter_p).
%% role_id:int()角色id 
%% letterbox:list() [r_letter_detail]
%% count:int() 最后一条数据的id
-record(r_public_letter,{role_id,role_name,letterbox=[],count}).
%% id:int() 信件id
%% sender_name:() 发件人姓名
%% goods_list:list() [p_goods]交易物品
%% type:int() 信件类型：私人，门派，系统，gm ，后台
%% state:int() 信件状态：没打开，打开,收取物品
-record(r_letter_detail,{id,send_time,out_time,send_id,send_name,goods_list=[],type,state=1,title,text}).

%%%%%% 公共信件内容表
-define(DB_COMMON_LETTER,db_common_letter).
-define(DB_COMMON_LETTER_P,db_common_letter_p).
%% id:int() 公共信件id
%% sender:string() 发件人
%% title:string() 公共信件内容
%% send_time:date() 发送时间
%% out_time:date() 过期时间
%% type:int() 信件类型：私人，门派，系统，gm ，后台
%% text:string() 信件内容
-record(r_common_letter,{id,send_time,out_time,type,title,text=""}).

%% 场景大战副本类型
-define(DB_SCENE_WAR_FB_P,db_scene_war_fb_p).
-define(DB_SCENE_WAR_FB,db_scene_war_fb).
%% 场景大战副本记录
%% fb_info 场景大战副本信息 结构为 [r_scene_war_fb_info,..]
-record(r_scene_war_fb,{role_id,role_name,faction_id,level,team_id = 0,status = 0,
start_time = 0,end_time = 0,map_id,pos,fb_map_name,fb_id,fb_seconds,fb_type,fb_level,fb_info = []}).
-record(r_scene_war_fb_info,{times = 0,fb_type}).

%% 场景大战副本日志记录
-record(r_scene_war_fb_log,{role_id,role_name,faction_id,level,team_id = 0,status = 0,times = 0,
start_time = 0,end_time = 0,fb_id,fb_seconds,fb_type,fb_level,dead_times = 0,
in_number = 0,out_number = 0,in_role_ids,in_role_names,out_role_ids,
monster_born_number = 0,monster_dead_number = 0}).
%% 场景大战副本采集物日志表
-record(r_scene_war_fb_log_collect,{fb_id,fb_seconds,collect_id,collect_number}).

-define(DB_FAMILY_COLLECT_ROLE_PRIZE_INFO, db_family_collect_role_prize_info).
-define(DB_FAMILY_COLLECT_ROLE_PRIZE_INFO_P, db_family_collect_role_prize_info_p).

%% 英雄副本
-define(DB_HERO_FB_RECORD_P, db_hero_fb_record_p).
-define(DB_HERO_FB_RECORD, db_hero_fb_record).
-record(r_hero_fb_record, {barrier_id, best_record}).


%% 单人副本数据表
-define(DB_ROLE_MISSION_FB_P, db_role_mission_fb_p).
-define(DB_ROLE_MISSION_FB, db_role_mission_fb).
%% fb_key={role_id,fb_id}
-record(r_role_mission_fb, {fb_key,has_fb_prop,prop_id,prop_num,fetch_prop_time,back_prop_time}).

-define(DB_ROLE_HERO_FB_P, db_role_hero_fb_p).
%%累积经验
-define(DB_ROLE_ACCUMULATE_P,db_role_accumulate_p).
-record(tasklist,{lastleve,thisdaynum,accstate,thisday}).   %%每个角色每天只有一条，有多少天就有多少条 原始记录
-record(r_day_task,{taskid,daynum,listask}).%%每个角色有四条listask是个列表
%%isget是否已领取
-record(r_role_accumutlate,{roleid,accstarday,list_rec,isget,rate}).%%list_rec是个列表，每个角色有一条

%% 角色打指定怪没有掉落的次数纪录
-define(DB_ROLE_MONSTER_DROP, db_role_monster_drop).
-define(DB_ROLE_MONSTER_DROP_P, db_role_monster_drop_p).
%% kill_times: [{{map_id, monster_type_id}, times}...]
%% times: 杀死次数
-record(r_role_monster_drop, {role_id, kill_times}).


%% 玩家箱子记录
-define(DB_ROLE_BOX_P,db_role_box_p).
%% start_time 本次箱子的开始时间
%% end_time 本次箱子的结束时间
%% is_generate 表示是否已经按正常的时间生产箱子物品 0未生成 1已生成
%% fee_flag 标记 0表示玩家未使用费用 1表示玩家使用费用
%% cur_list 本次玩家可获得的物品列表
%% all_list 玩家开箱子的所有物品
%% free_times 玩家自动刷新箱子物品次数
%% fee_times 玩家使用元宝开箱子的次数
%% log_list 玩家开箱子记录 [r_box_goods_log,...]
%% is_restore 刷新是否自动放置物品到宝物箱 0不自动，1自动
%% box_goods_index 宝箱物品id索引
-record(r_role_box,{role_id,faction_id,start_time = 0,end_time = 0,is_generate = 0,fee_flag = 0, 
cur_list = [],bc_list = [],all_list = [],log_list = [],free_times = 0,fee_times = 0,is_restore = 0,
box_gid_index = 1}).

%% 玩家箱子物品获得记录表
-define(DB_BOX_GOODS_LOG_P,db_box_goods_log_p).
-define(DB_BOX_GOODS_LOG,db_box_goods_log).
%% award_list 玩家当次获得的物品列表[p_goods,...]
%% key {role_id,common_tool:now_nanosecond}
-record(r_box_goods_log,{key,role_id,role_sex,role_name,faction_id,award_time = 0,award_list = []}).

-define(DB_ROLE_NPC_DEAL_P,db_role_npc_deal_p).
%% key={role_id,deal_id}
-record(r_role_npc_deal,{key={0,0},total_deal_num=0,last_deal_num=0,last_deal_time}).

%% 玩家传奇目标信息
-define(DB_ROLE_GOAL_P, db_role_goal_p).

%% 玩家活动奖励信息
-define(DB_ACTIVITY_REWARD_P,db_activity_reward_p).
-define(DB_ACTIVITY_REWARD,db_activity_reward).
%% role_id:int() 玩家角色id
%% reward_list:list() [r_reward_info]
-record(r_activity_reward,{role_id,reward_list}).
%% reward_key:int() 活动id
%% log_time:date() 记录时间
%% recv_times:int()领取次数
%% =======================
%% reward_info:tuple() 
%% 累计充值：tuple():{sum_gold} 记录活动时间内总充值金额 
%% 单笔最高：list():{max_gold} 记录活动时间内最高一次充值金额
%% 累计消费: tuple():{sum_gold} 记录活动时间内总消费金额
%% 排行榜 :等级
%% =========================
%% able_get:int() 是否可以领取，0：不行 1：可以
-record(r_reward_info,{reward_key,log_time,reward_info,recv_times=0,able=0}).

%% 玩家充值失败的记录
-define(DB_PAY_FAILED_P, db_pay_failed_p).
-record(r_pay_failed, {order_id, role_id, pay_gold}).

%% 宠物训练信息 
-define(DB_PET_TRAINING_P,db_pet_training_p).
%% 玩家宠物训练信息 pet_training_list:list() [r_pet_training_detail]
-record(r_pet_training,{role_id,cur_room=2,pet_training_list=[]}).   %%暂时
%% 宠物训练详细信息
%% training_start_time:int() 训练起始时间
%% training_end_time:int() 训练结束时
%% last_add_exp_time:int() 上次加经验时间    玩家下线上线   游戏关闭启动有用
%% next_add_exp_time:int() 下次加经验时间   地图循环用
%% training_mode:int() 训练模式  
%% fly_cd_end_time:int() 突飞猛进cd结束时间
-record(r_pet_training_detail,{pet_id,training_start_time,training_end_time,last_add_exp_time,next_add_exp_time,training_mode,fly_cd_end_time,total_get_exp=0}).

%% 宗族采集
-define(DB_FAMILY_DONATE_P,db_family_donate_p).
-define(DB_FAMILY_DONATE,db_family_donate).
%% gold_donate_record:list()[p_family_donate_info]
-record(r_family_donate,{family_id,gold_donate_record,silver_donate_record}).


%% 刷棋副本
-define(DB_ROLE_SQ_FB_INFO,db_role_sq_fb_info).
-define(DB_ROLE_SQ_FB_INFO_P,db_role_sq_fb_info_p).

%% 玩家副本数据
%% fb_info:list()[r_sq_fb_fight_info:record()] 玩家当天副本信息
-record(r_role_sq_fb_info,{role_id,fb_map_name,enter_map_id,enter_pos,fb_info=[]}).
-record(r_role_sq_fb_detail,{fb_type,last_enter_time,fight_times=0}).

%% 刷棋副本日志
-record(r_shuaqi_fb_log,{role_id,role_name,faction_id,level,team_id = 0,status = 0,times = 0,
                         start_time = 0,end_time = 0,fb_type,monster_level=0,dead_times = 0,
                         in_number = 0,in_role_ids,in_role_names,monster_total_number=0,
                         monster_born_number = 0,monster_dead_number = 0,monster_change_times=0}).

%% 玩家经验瓶表
-define(DB_ROLE_EXP_BOTTLE_P,db_role_exp_bottle_p).
%% key = {role_id,type} type 1表示好友祝福经验
%% total_exp 总经验 cur_exp 当前经验 times 次数 op_time 操作时间
-record(r_role_exp_bottle,{key, role_id,total_exp = 0,cur_exp = 0,times = 0, op_time = 0}).

%% 练功房副本
-define(DB_ROLE_EXE_FB_INFO,db_role_exe_fb_info).
-define(DB_ROLE_EXE_FB_INFO_P,db_role_exe_fb_info_p).

-record(r_role_exe_fb_info,{role_id,fb_map_name,enter_map_id,enter_pos,fb_info=[]}).
-record(r_role_exe_fb_detail,{fb_type,last_enter_time,fight_times=0}).
%% 练功房副本日志
-record(r_exercise_fb_log,{role_id,role_name,faction_id,level,team_id=0,status=0,times=0,
                           start_time=0,end_time=0,fb_type,monster_level=0,
                           in_number=0,in_role_ids,in_role_names,monster_total_number=0,
                           monster_born_number=0,monster_dead_number=0,cur_pass_id=0,cur_born_times=0}).

