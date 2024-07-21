%%包含其他文件
-include("mnesia.hrl").
-include("mm_define.hrl").
-include("all_pb.hrl").
-include("global_lang.hrl").
-include("error_no.hrl").
-include("skill.hrl").
-include("title.hrl").
-include("log_consume_type.hrl").
-include("log_item_type.hrl").
-include("mysql_db_define.hrl").
-include("user_event_type.hrl").
-include("mccq_activity.hrl").
-include("common_records.hrl").
-include("mission_event.hrl").

%%日志相关
-define(PRINT(Format, Args),
        io:format(Format, Args)).
		
-define(SYSTEM_LOG(Format, Args), global:send(manager_log, {system_log, erlang:localtime(), Format, Args})).

%% 定义单元测试相关宏
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.
    

%% 地图数据相关定义
-define(TILE_SIZE, 44).
-define(CORRECT_VALUE, 1.225).
-define(CORRECT_VALUE_MAP, 10000000).
%%

-define(FACTIONID_LIST, [1, 2, 3]).
-define(FACTION_KING_NAME, [{1, "云州王"}, {2, "沧州王"}, {3, "幽州王"}]).

-record(r_unicast, {unique, module, method, roleid, record}).
-record(r_broadcast, {module, method, roleid, record}).

%%玩家状态
-define(ROLE_STATE_NORMAL,0).
-define(ROLE_STATE_DEAD,1).
-define(ROLE_STATE_FIGHT, 2).
-define(ROLE_STATE_EXCHANGE, 3).
-define(ROLE_STATE_ZAZEN, 4). %%打坐状态
-define(ROLE_STATE_STALL, 5). %%摆摊状态
-define(ROLE_STATE_TRAINING, 6). %%训练状态
-define(ROLE_STATE_COLLECT,7). %%采集状态
-define(ROLE_STATE_YBC_FAMILY, 8). %% 门派拉镖状态
-define(ROLE_STATE_STALL_SELF, 9). %% 亲自摆摊中
-define(ROLE_STATE_STALL_AUTO, 10). %% 自动摆摊中
%%-define(ROLE_STATE_ON_HOOK, 11). %%在线挂机中


%%boss log的状态
-define(LOG_BOSS_SPAWN_STATE,1). %%boss重生
-define(LOG_BOSS_DEAD_STATE,2). %%boss死亡
-define(LOG_BOSS_OTHER_STATE,3). %%boss其他状态

%%{15,2,4564564648,[r_log_boss_item_drop],879512} 
-record(r_log_boss_state,
            {boss_id,boss_type,boss_name,boss_state,map_id=0,special_id=0,mtime,drop_item,last_hurt_player,ext}). %% boss日志的record
%%{BossID,BossState,Time,DropItemsList,LastHurt} 
-record(r_log_boss_item_drop,{item_type,item_typeid,color=0,quality=0,num=1}).


-define(ACCEPT_LOG(Format, Args), error_logger:info_msg(Format, Args)).
%% 单独模块日志记录

-define(M_DEV(Format, Args),
        common_logger:dev(node(), ?MODULE, ?LINE, Format, Args)).

-define(M_DEBUG(Format, Args),
    common_logger:debug_msg(node(), ?MODULE, ?LINE, Format, Args)).

-define(M_INFO_MSG(Format, Args),
    common_logger:info_msg( node(), ?MODULE, ?LINE, Format, Args)).
			      
-define(M_WARNING_MSG(Format, Args),
    common_logger:warning_msg( node(), ?MODULE, ?LINE, Format, Args)).
			      
-define(M_ERROR_MSG(Format, Args),
    common_logger:error_msg( node(), ?MODULE, ?LINE, Format, Args)).

-define(M_CRITICAL_MSG(Format, Args),
    common_logger:critical_msg( node(), ?MODULE, ?LINE, Format, Args)).


-define(DBG(Format, Args),
    common_logger:error_msg( node(), ?MODULE, ?LINE, Format, Args)).
-define(DBG(),
    common_logger:error_msg( node(), ?MODULE, ?LINE, "debug", [])).


%%战士职业
-define(CATEGORY_WARRIOR,1).
%%射手职业
-define(CATEGORY_HUNTER,2).
%%侠客职业
-define(CATEGORY_RANGER,3).
%%医仙职业
-define(CATEGORY_DOCTOR,4).
%%怪物职业
-define(CATEGORY_MONSTER,5).
%%宠物物理型职业
-define(CATEGORY_PET_PHY,8).
%%宠物法力型职业
-define(CATEGORY_PET_MAGIC,9).
%%门派职业
-define(CATEGORY_FAMILY,7).

-define(DEFAULT_UNIQUE, 0).

%%摆摊所需要的最小等级
-define(STALL_MIN_LEVEL, 1).
%%摆摊所需要交的银两税
-define(STALL_BASE_TAX, 20).
%%托管摆摊每小时多少文
-define(STALL_AUTO_SILVER_PER_HOUR, 10).
%%摊位中保存多少条聊天记录
-define(STALL_CHAT_LOGS_MAX_NUM, 15).
%% 雇佣摆摊交易税
-define(AUTO_STALL_INCOME_TAX_RATE, 0.03).
%% 亲自摆摊交易税
-define(SELF_STALL_INCOME_TAX_RATE, 0.01).

%%每个结点都会建立这个ets表:
%%    common_misc:set_role_line_by_id(RoleID, Line)
%%    common_misc:get_role_line_by_id(RoleID, Line)
%%    common_misc:remove_role_line_by_id(RoleID)
-define(ETS_ROLE_LINE_MAP, ets_role_line_map).

%% 用于调试
-ifdef(DEBUG).
-define(GEN_SERVER_OPTIONS, [{debug, [trace,log]}]).
-else.
-define(GEN_SERVER_OPTIONS, []).
-endif.


%%标示道具状态：0=正常状态，1=摊位状态（不可使用、不可拆分、不可交易、不可摧毁），2=装备无效状态
-define(GOODS_STATE_NORMAL, 0).
-define(GOODS_STATE_IN_STALL, 1).
-define(GOODS_STATE_EQUIP_INVALID, 2).


%%摊位中最多多少个物品位置
-define(STALL_MAX_OF_GOODS, 36).

%%物品类型
-define(TYPE_ITEM,  1).
-define(TYPE_STONE, 2).
-define(TYPE_EQUIP, 3).
-record(r_item_create_info,{role_id,bag_id,bagposition,num=0,typeid,bind=false,start_time=0,end_time=0,color=0}).
-record(r_stone_create_info,{role_id,bag_id,bagposition,num=0,typeid,bind=false,start_time=0,end_time=0}).
-record(r_equip_create_info,{role_id,bag_id,bagposition,num=0,typeid,bind=false,start_time=0,end_time=0,color=0,
       quality=1,punch_num=0,property=undefined,rate=0,result=0,result_list=[],interface_type,sub_quality = 1}).
-record(r_mount_create_info,{role_id,bag_id,bagposition,num=0,typeid,bind=false,start_time=0,end_time=0}).

%% 循环作用的buff
-define(TIMER_LOOP_BUFF, [burning, poisoning, out_of_mind, add_hp]).


-define(DEFAULT_ROLE_STATUS, 0).
-define(DEFAULT_ROLE_HP, 1000).
-define(DEFAULT_ROLE_MP, 60).
-define(BASE_ROLE_MAX_HP, 1000).
-define(BASE_ROLE_MAX_MP, 60).

-define(DEFAULT_FAMILY_MEMBER_TITLE, <<"帮众">>).

-define(FAMILY_TITLE_OWNER, <<"掌门">>).

-define(FAMILY_TITLE_SECOND_OWNER, <<"长老">>).

-define(FAMILY_TITLE_LEFT_PROTECTOR, <<"左护法">>).

-define(FAMILY_TITLE_RIGHT_PROTECTOR, <<"右护法">>).

-define(FAMILY_TITLE_INTERIOR_MANAGER, <<"内务使">>).
%%当调用common_role_money异步接口修改Money，返回的消息Tag
-define(REDUCE_ROLE_MONEY_SUCC,reduce_role_money_succ).
-define(REDUCE_ROLE_MONEY_FAILED,reduce_role_money_failed).
-define(ADD_ROLE_MONEY_SUCC,add_role_money_succ).
-define(ADD_ROLE_MONEY_FAILED,add_role_money_failed).
-define(CHANGE_ROLE_MONEY_SUCC,change_role_money_succ).
-define(CHANGE_ROLE_MONEY_FAILED,change_role_money_failed).

-define(DEFAULT_ROLE_STR, 0).
-define(DEFAULT_ROLE_INT, 0).
-define(DEFAULT_ROLE_CON, 0).
-define(DEFAULT_ROLE_DEX, 0).
-define(DEFAULT_ROLE_MEN, 0).
-define(DEFAULT_ROLE_EXP, 0).
-define(DEFAULT_ROLE_NEXT_LEVEL_EXP,10).
-define(DEFAULT_ROLE_LEVEL, 0).
-define(DEFAULT_ATTR_POINT, 1).
-define(DEFAULT_FIVE_ELE_ATTR, 0).
-define(DEFAULT_PK_TITLE, 0).
-define(DEFAULT_MAX_PHY_ATTACK, 11).
-define(DEFAULT_MIN_PHY_ATTACK, 11).
-define(DEFAULT_MAX_MAGIC_ATTACK, 11).
-define(DEFAULT_MIN_MAGIC_ATTACK, 11).
-define(DEFAULT_PHY_DEFENCE, 1).
-define(DEFAULT_MAGIC_DEFENCE, 1).
-define(DEFAULT_HP_RECOVER_SPEED, 3).
-define(DEFAULT_MP_RECOVER_SPEED, 1).
-define(DEFAULT_LUCK, 0).
-define(DEFAULT_MOVE_SPEED, 170).
-define(DEFAULT_ATTACK_SPEED, 1000).
-define(DEFAULT_ERUPT_ATTACK_RATE, 100).
-define(DEFAULT_NO_DEFENCE, 0).
-define(DEFAULT_MISS, 2).
-define(DEFAULT_DOUBLE_ATTACK, 100).
-define(DEFAULT_ENERGY, 4000).

-define(DEFAULT_PK_MODE, 4).
-define(DEFAULT_PK_POINTS, 0).
-define(DEFAULT_REMAIN_SKILL_POINT, 1).
-define(DEFAULT_GOLD, 0).
-define(DEFAULT_GOLD_BIND, 0).
-define(DEFAULT_SILVER, 0).
-define(DEFAULT_SILVER_BIND, 0).
-define(DEFAULT_ACTIVE_POINTS, 1). %%默认的玩家活跃度

-define(CHANNEL_SIGN_WORLD, "channel_world").
-define(CHANNEL_SIGN_FAMILY, "channel_family").
-define(CHANNEL_SIGN_FACTION, "channel_faction").
-define(CHANNEL_SIGN_TEAM, "channel_team").
-define(CHANNEL_SIGN_LEVEL_CHANNEL, "channel_level_channel").

-define(CHANNEL_TYPE_WORLD, 1).%%世界
-define(CHANNEL_TYPE_FACTION, 2).%%国家
-define(CHANNEL_TYPE_FAMILY, 3).%%门派
-define(CHANNEL_TYPE_TEAM, 4).%%组队
-define(CHANNEL_TYPE_LEVEL, 5).%%同等级频道
-define(CHANNEL_TYPE_PAIRS, 6).%%私聊类型

%%角色单项属性变化
-define(ROLE_HP_CHANGE,1).
-define(ROLE_MP_CHANGE,2).
-define(ROLE_SKILL_POINT_CHANGE,3).
-define(ROLE_ATTR_POINT_CHANGE,4).
-define(ROLE_EXP_CHANGE,5).
-define(ROLE_SILVER_CHANGE,6). %% 角色银子变化
-define(ROLE_SILVER_BIND_CHANGE,7). %% 角色绑定银子变化
-define(ROLE_GOLD_CHANGE, 8). %%角色元宝变化
-define(ROLE_GOLD_BIND_CHANGE, 9). %%角色绑定元宝变化
-define(ROLE_ENERGY_CHANGE, 10). %%角色精力值变化
-define(ROLE_GONGXUN_CHANGE, 11). %% 玩家功勋值变化
-define(ROLE_FAMILY_CONTRIBUTE_CHANGE,12).  %%角色门派贡献度变化
-define(ROLE_FAMILYID_CHANGE,13). %%角色门派发生变化,0为暂时没有门派
-define(ROLE_CHARM_CHANGE,14).         %%角色的魅力值变化
-define(ROLE_ACTIVE_POINTS_CHANGE,15). %%角色的活跃度变化
-define(ROLE_ENERGY_REMAIN_CHANGE, 16). %% 角色昨天剩余精力值变化
-define(ROLE_SUM_PRESTIGE_CHANGE, 17). %% 玩家总声望值
-define(ROLE_CUR_PRESTIGE_CHANGE, 18). %% 玩家当前望值

%%门派单项属性变化
-define(FAMILY_MONEY_CHANGE,1).         %%门派资金
-define(FAMILY_ACTIVEPOINT_CHANGE,2).   %%门派繁荣度

-record(p_ybc_walk_info, {last_path, last_target_pos, last_walk_time, next_walk_time}).

-define(RELIVE_TYPE_SKILL, 4). %% 技能复活
-define(RELIVE_TYPE_PLAIN, 2).%%原地脑残复活
-define(RELIVE_TYPE_BACK_CITY, 3).%%回城复活
-define(RELIVE_TYPE_PLAIN_MONEY, 1).%%原地扣钱复活


-define(MENU_ID_FURNANCE, 1).%%天工炉菜单ID

-define(FCM_OFFLINE_TIME, 5*3600).%%下线总时间大于多少时才能玩游戏
-define(FCM_TOTAL_TIME, 5*3600). %%多长时间没有收益
-define(FCM_HALF_TIME, 3*3600). %%多长时间收益减半
%%-define(FCM_TOTAL_TIME, 30).
-define(FCM_TIME_LIST, [0, 3600, 7200, 9000, 9900, 10500, ?FCM_TOTAL_TIME]).%%时间段列表
%%-define(FCM_TIME_LIST, [0, 3, 5, 10, 15, 20, ?FCM_TOTAL_TIME]).%%时间段列表
-define(FCM_OPEN, false).%%false为关闭防沉迷判断


%% 登录用到的key 加密值
-define(TICKET_SUBFIX, "bx32017616e8396cbfae965ba2162f32").

-define(YBC_ATTACK_TRUE_ALL, 1).%%1任何满足游戏条件的都可以攻击
-define(YBC_ATTACK_FALSE_ALL, 2).%%1任何人不可以攻击

%% 用于创建镖车接口: role_list [{role_id, role_name, level, bind_silver, silver}, ...]
-record(p_ybc_create_info, {role_list, create_type, color, max_hp, move_speed, name, creator_id, create_time, faction_id, end_time, buffs, recover_speed, magic_defence, physical_defence, group_type, group_id, can_attack, level}).

-record(ybc_config, {friendly_type,
                     friendly_id, 
                     ybc_name,
                     creator_role_id, 
                     role_list=[], 
                     ybc_monster_type, 
                     move_speed_multiple=1, 
                     end_pos, 
                     mission_id, 
                     max_hp,
                     color=1,
                     time_limit, 
                     total_time,
                     cost_silver=0,
                     cost_silver_bind=0,
                     cost_gold=0,
                     cost_gold_bind=0,
                     creator_level=0,
                     creator_faction=0,
                     attack_type=1,%%1任何满足游戏条件的都可以攻击 任何人不可以攻击
                     status,
                     monster_id,
                     map_process_name}).%%镖车配置

-define(YBC_TYPE_SINGLE, 1).%%个人镖车
-define(YBC_TYPE_FAMILY, 2).%%门派镖车

-define(YBC_STATUS_NORMAL, 0). %% 正常状态
-define(YBC_STATUS_NOT_NEARBY, 1).%%镖车不在附近
-define(YBC_STATUS_KILLED, 2). %%镖车被干掉了
-define(YBC_STATUS_TIMEOUT, 3). %%镖车超时
-define(YBC_STATUS_SUCC, 4). %%成功完成
-define(YBC_STATUS_TIMEOUT_DEL, 5).%%镖车超时被系统删除
-define(YBC_STATUS_STOP, 6).

-define(YBC_FAMILY_MEMBER_STATUS_NORMAL, 1).
-define(YBC_FAMILY_MEMBER_STATUS_FARAWAY, 2).
-define(YBC_FAMILY_MEMBER_STATUS_OFFLINE, 3).



-define(ERROR_LOG(Format, Args), common_logger:error_msg( node(), ?MODULE, ?LINE, Format, Args)).

-define(TRY_CATCH(Fun,Tip,ErrType,ErrReason), 
        try 
            Fun
        catch 
            ErrType:ErrReason -> 
                ?ERROR_MSG("~ts: ErrType=~w,Reason=~w,Stacktrace=~w", [Tip,ErrType,ErrReason,erlang:get_stacktrace()]) 
        end).
-define(TRY_CATCH(Fun,ErrType,ErrReason), 
        try 
            Fun
        catch 
            ErrType:ErrReason -> 
                ?ERROR_MSG("ErrType=~w,Reason=~w,Stacktrace=~w", [ErrType,ErrReason,erlang:get_stacktrace()]) 
        end).
-define(TRY_CATCH(Fun,ErrReason), 
        try 
            Fun
        catch 
            _:ErrReason -> 
                ?ERROR_MSG("Reason=~w,Stacktrace=~w", [ErrReason,erlang:get_stacktrace()]) 
        end).
-define(TRY_CATCH(Fun), ?TRY_CATCH(Fun,ErrType,ErrReason)).

-define(DO_HANDLE_INFO(Info,State),  
        try do_handle_info(Info) catch _:Reason -> ?ERROR_LOG("Info:~w,State=~w, Reason: ~w, strace:~w", [Info,State, Reason, erlang:get_stacktrace()]) end).

-define(DO_HANDLE_INFO_STATE(Info, State), 
        try do_handle_info(Info, State) catch _:Reason -> ?ERROR_LOG("Info:~w,State=~w, Reason: ~w, strace:~w", [Info,State, Reason, erlang:get_stacktrace()]) end).

-define(DEBUG_HANDLE_INFO(Req,State),
        try
            {Fun,Args} = Req,
            R = erlang:apply(?MODULE,Fun, Args),
            ?ERROR_MSG("apply result=~w",[R])
        catch _:Reason -> 
            ?ERROR_MSG("DEBUG_HANDLE_INFO error,Req:~w,State=~w, Reason: ~w, strace:~w", [Req,State, Reason, erlang:get_stacktrace()]) 
        end,
        {noreply, State}).

%% 怪物经验记录处理
%% id,唯一标记，killer_id 杀死怪物的RoleId, map_id 地图id monster_id  怪物id, ,monster_type 怪物类型 
%% monster_tx,monster_ty 怪物死亡坐标，role_exp_list 获取得经验的玩家记录类型r_monster_role_exp
%% team_exp_list  队伍经验记录r_monster_team_exp, monster_level 怪物等级, monster_rarity 怪物类型（普通、精英、BOSS）
-record(r_monster_exp,{id,killer_id,map_id,monster_id,monster_type,monster_level, monster_rarity,monster_tx,monster_ty,role_exp_list,team_exp_list}).
%% 怪物经验玩家经验记录
-record(r_monster_role_exp,{role_id,exp,energy_index}).
%% 队伍经验记录,team_sub_list 队伍成员经验记录列表r_monster_team_sub_exp
-record(r_monster_team_exp,{team_id,team_sub_list}).
%% role_id 角色id,exp 角色所得经验
-record(r_monster_team_sub_exp,{role_id, exp, team_id, team_exp, level,kill_flag,status,energy_index}).

%%地图跳转类型
-define(CHANGE_MAP_TYPE_NORMAL, 1).%%普通
-define(CHANGE_MAP_TYPE_RETURN_HOME, 2).%%回城切换地图
-define(CHANGE_MAP_TYPE_DRIVER, 3). %%车夫
-define(CHANGE_MAP_TYPE_VWF, 4). %%进入逐鹿天下副本地图
-define(CHANGE_MAP_TYPE_WAROFKING, 5). %%王座争霸战
-define(CHANGE_MAP_TYPE_COUNTRY_TREASURE, 6). %%大明宝藏副本地图
-define(CHANGE_MAP_TYPE_RELIVE, 7). %% 复活跳转
-define(CHANGE_MAP_TYPE_EDUCATE_FB, 8). %%师门同心副本地图
-define(CHANGE_MAP_TYPE_EDUCATE, 9). %%师徒免费传送
-define(CHANGE_MAP_TYPE_SCENE_WAR_FB, 10). %%场景大战副本地图

%% 道具日志模块
%% bind_type:integer()，绑定类型；0=未知，1=绑定，2=不绑定
-record(r_item_log,{role_id,role_level,action,item_id,amount,equip_id,color,fineness,start_time,end_time,bind_type,super_unique_id=0}).

%% 用户流失率行为日志模块
-record(r_fluctuation_behavior_log,{role_id,log_time,behavior_type,login_ip}).

%% 创建道具接口
-record(r_goods_create_info, {bind=false, bag_id, position,type, type_id, start_time=0, end_time=0, num=0, color=0,quality=1,punch_num=0,
property,rate=0,result=0,result_list=[],interface_type,sub_quality = 1}).

%% 交易日志
-record(r_exchange_log, {from_role_id, from_role_name, from_silver, from_gold, from_goods, to_role_id, to_role_name, to_silver, to_gold, to_goods, time}).
%% 信件日志
-record(r_letter_log, {role_id, role_name, target_role_id, target_role_name, goods, time}).

%%个人拉镖日志
-record(r_personal_ybc_log,{role_id,start_time,ybc_color,final_state,end_time}).

%%门派拉镖日志记录
-record(r_family_ybc_log,{ybc_no,family_id,mtime,content}).

%% 个人副本日志
-record(r_personal_fb_log, {role_id, role_name, faction_id, fb_id, start_time, end_time, status}).

%% 门派采集活动日志
-record(r_family_collect_log, {family_id, time, role_num, score}).

%% 玩家进程字典信息
%% buy_back_goods 买回物品
%% training_pets:record() r_pet_training 宠物训练信息
-record(r_role_map_ext,{buy_back_goods,training_pets}).








%% 红名PK点
-define(RED_NAME_PKPOINT, 18).


%% 角色事务相关宏
-define(role_id_list_in_transaction, role_id_list_in_transaction).
-define(role_base, role_base).
-define(role_attr, role_attr).
-define(role_base_copy, role_base_copy).
-define(role_attr_copy, role_attr_copy).
-define(role_conlogin, role_conlogin).
-define(role_conlogin_copy, role_conlogin_copy).
-define(role_accumulate_exp, role_accumulate_exp).
-define(role_accumulate_exp_copy, role_accumulate_exp_copy).
-define(mod_map_role_transaction_flag, mod_map_role_transaction_flag).
-define(role_vip, role_vip).
-define(role_vip_copy, role_vip_copy).
-define(role_hero_fb, role_hero_fb).
-define(role_hero_fb_copy, role_hero_fb_copy).
-define(role_monster_drop, role_monster_drop).
-define(role_monster_drop_copy, role_monster_drop_copy).
-define(role_refining_box, role_refining_box).
-define(role_refining_box_copy, role_refining_box_copy).
-define(role_goal_info, role_goal_info).
-define(role_goal_info_copy, role_goal_info_copy).
-define(role_achievement, role_achievement).
-define(role_achievement_copy, role_achievement_copy).
-define(role_team, role_team).
-define(role_team_copy, role_team_copy).
-define(role_map_ext,role_map_ext).
-define(role_map_ext_copy,role_map_ext_copy).
-define(role_skill, role_skill).
-define(role_skill_copy, role_skill_copy).
-define(role_pos, role_pos).
-define(role_pos_copy, role_pos_copy).
-define(role_fight, role_fight).
-define(role_fight_copy, role_fight_copy).

%% mission事务相关
-define(MAP_MISSION_TRANSACTION_FLAG,map_mission_transaction_flag).
-define(MISSION_ROLE_IDLIST_IN_TRANSACTION,mission_role_idlist_in_transaction).
%% mission进程字典数据key
-define(MISSION_DATA_DICT_KEY(RoleID), {mission_data_dict_key, RoleID}).
-define(MISSION_DATA_DICT_KEY_COPY(RoleID), {mission_data_dict_key_copy, RoleID}).


%%装备颜色-----------------------------------------------------------------------------
-define(COLOUR_WHITE, 1). %白色
-define(COLOUR_GREEN, 2). %绿色
-define(COLOUR_BLUE, 3).  %蓝色
-define(COLOUR_PURPLE, 4).%紫色
-define(COLOUR_ORANGE,5). %橙色
-define(COLOUR_GOLD,6).   %金色

%%装备品质----------------------------------------------------------------------------
-define(QUALITY_GENERAL, 1).  %普通
-define(QUALITY_WELL, 2).     %精良
-define(QUALITY_GOOD, 3).     %优质
-define(QUALITY_FLAWLESS, 4).  %无暇
-define(QUALITY_PERFECT, 5).  %完美 

%% 召集类型
-define(CHANGE_MAP_FAMILY_NPC_CALL,1). %% 门派活动召集,通过门派地图NPC发布召集信息
-define(CHANGE_MAP_FAMILY_GATHER_CALL,2). %% 门派令召集
-define(CHANGE_MAP_FAMILY_YBC_CALL,3). %% 门派拉镖召集
-define(CHANGE_MAP_WAROFFACTION_CALL,4).
-define(CHANGE_MAP_WAROFKING_CALL,5).%% 王座争霸战召集
-define(CHANGE_MAP_EDUCATE_HELP_CALL,6). %%师徒死亡召集

%% 日常任务、日常福利的活动ID，必须跟activity_today.config对应
-define(ACTIVITY_TASK_PERSON_YBC,10001).  %%个人拉镖  
-define(ACTIVITY_TASK_COUNTRY_TREASURE,10002).  %%大明宝藏
-define(ACTIVITY_TASK_FAMILY_BOSS,10003).  %%门派普通BOSS 
-define(ACTIVITY_TASK_FAMILY_YBC,10004).  %%门派拉镖
-define(ACTIVITY_TASK_DXWL_FB,10005).     %%地下王陵副本
-define(ACTIVITY_TASK_MSZD_FB,10006).     %%魔神之殿
-define(ACTIVITY_TASK_SHUAQI_FB,10007).  %%西瓜副本
-define(ACTIVITY_TASK_PERSON_FB,10008).  %%个人副本
-define(ACTIVITY_TASK_SCENE_WAR_FB_PHY,10009).  %%鄱阳湖副本
-define(ACTIVITY_TASK_SCENE_WAR_FB_DTFD, 10011). %% 洞天福地副本
-define(ACTIVITY_TASK_EDUCATE_FB,10013).  %%师徒副本
-define(ACTIVITY_TASK_TRADING,10012). %%商贸
-define(ACTIVITY_TASK_EXERCISE_FB,10080). %% 试炼副本
-define(ACTIVITY_TASK_BONFIRE,10081). %% 个人篝火
-define(ACTIVITY_TASK_CHUELING,20001).  %%除恶令任务 
-define(ACTIVITY_TASK_SHOUBIAN,20002).  %%守边
-define(ACTIVITY_TASK_SPY,20003).   %%刺探



%% 宠物操作日志类型
-define(PET_ACTION_TYPE_THROW,101).  %%放生宠物
-define(PET_ACTION_TYPE_REFRESH_APTITUDE,102).  %%宠物洗灵
-define(PET_ACTION_TYPE_ADD_UNDERSTANDING,103).  %%宠物提悟
-define(PET_ACTION_TYPE_ADD_LIFE,104).  %%宠物延寿
-define(PET_ACTION_TYPE_LEARN_SKILL,105).  %%宠物学技能
-define(PET_ACTION_TYPE_REFRESH_ATTR,106).  %%宠物洗髓
-define(PET_ACTION_TYPE_DEAD,107).  %%宠物死亡
-define(PET_ACTION_TYPE_ADD_SKILL_GRID,108).  %%宠物增加技能栏
-define(PET_ACTION_TYPE_FORGET_SKILL,109).  %%宠物遗忘技能
-define(PET_ACTION_TYPE_REFINING,110).  %%宠物遗忘技能
-define(PET_ACTION_TYPE_TRICK_LEARN,111).  %%宠物领悟新的特技
-define(PET_ACTION_TYPE_TRICK_UPGRADE,112).  %%宠物升级特技 
-define(PET_ACTION_TYPE_LEVEL_UP,113).  %%宠物升级

%%宠物获得类型
-define(PET_GET_TYPE_USE_ITEM,1).  %%使用宠物召唤符获得

-define(MISSION_LISTENER_MONSTER, 1).%%怪物侦听器
-define(MISSION_LISTENER_MONSTER_S_MONSTER, 1001).%%怪物侦听器
-define(MISSION_LISTENER_MONSTER_S_PROP, 1002).%%怪物掉落道具侦听器

-define(MISSION_LISTENER_PROP, 2).%%道具侦听器
-define(MISSION_LISTENER_PROP_S_PROP, 2001).%%道具侦听器

%% 精力值最多可积累
-define(MAX_REMAIN_ENERGY, 10000).

%%
-record(p_bonfire,{map_id,type_list,state,time,range}).


%% 组队状态
-define(TEAM_DO_STATUS_NORMAL, 0).
-define(TEAM_DO_STATUS_INVITE, 1).
-define(TEAM_DO_STATUS_ACCEPT, 2).
-define(TEAM_DO_STATUS_REFUSE, 3).
-define(TEAM_DO_STATUS_LEAVE, 4).
-define(TEAM_DO_STATUS_KICK, 5).
-define(TEAM_DO_STATUS_CHANGE_LEADER, 6).
-define(TEAM_DO_STATUS_PICK, 7).
-define(TEAM_DO_STATUS_DISBAND, 8).
-define(TEAM_DO_STATUS_MEMBER_INVITE, 9).
-define(TEAM_DO_STATUS_APPLY, 10).
-define(TEAM_DO_STATUS_CREATE, 11).

%% boss群标志
-define(BOSS_GROUP_KEY,100019).

-define(DEFAULT_MAPID,10700).

%% 帐号类型
-define(ACCOUNT_TYPE_NORMAL,0).%% 正常玩家帐号
-define(ACCOUNT_TYPE_GM,1).%% GM帐号
-define(ACCOUNT_TYPE_ADMIN,2).%% 后台模拟帐号
-define(ACCOUNT_TYPE_GUEST,3).%% 客户帐号


