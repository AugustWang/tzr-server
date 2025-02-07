%%%----------------------------------------------------------------------
%%% File    : mgeem_logger_h.erl
%%% Author  : Qingliang
%%% Created : 2010-01-01
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------

-define(APP_NAME, map.server).

-define(DEV(Format, Args),
        common_logger:dev(?APP_NAME, ?MODULE, ?LINE, Format, Args)).

-define(DEBUG(Format, Args),
        common_logger:debug_msg(?APP_NAME, ?MODULE,?LINE,Format, Args)).

-define(INFO_MSG(Format, Args),
        common_logger:info_msg( node(), ?MODULE,?LINE,Format, Args)).
			      
-define(WARNING_MSG(Format, Args),
        common_logger:warning_msg( node(), ?MODULE,?LINE,Format, Args)).

			      
-define(ERROR_MSG(Format, Args),
        common_logger:error_msg( node(), ?MODULE,?LINE,Format, Args)).

%%带STACK的ERROR_MSG
-define(ERROR_MSG_STACK(Arg1,Arg2),  %% Args为两个参数
        common_logger:error_msg( node(), ?MODULE,?LINE,"Info:~s, Error: ~w, Stack:~w", [Arg1,Arg2,erlang:get_stacktrace()])).

-define(CRITICAL_MSG(Format, Args),
        common_logger:critical_msg( node(), ?MODULE,?LINE,Format, Args)).

-define(HOOK_CATCH(F), try F() catch E:E2 -> ?ERROR_MSG("~ts:~p ~p ~p", ["严重问题", E, E2, erlang:get_stacktrace()]) end).

-define(UNICAST_TOC(R2),common_misc:unicast2(PID, Unique, Module, Method, R2)).

-record(listener, {node, protocol, host, port}).

-define(ETS_IN_MAP_DATA, mgee_ets_in_vw_map_data).
-define(ETS_MONSTER_INFO_MAP,mgee_ets_monster_info).
-define(ETS_MONSTER_POS,ets_monster_pos).
-define(ETS_MONSTER_BUFFS,ets_monster_buffs).
-define(ETS_MAP_INFO, ets_map_info).
-define(ETS_ROLE_TX_TY, ets_role_tx_ty).
-define(ETS_MAP_NPC, ets_vw_map_npc).
-define(ETS_MAP_MONSTER, ets_vw_map_monster).
-define(ETS_ROLEID_PID_MAP, ets_roleid_pid_map).
-define(ETS_MAP_LIST, ets_virtual_world_list).
-define(ETS_MAP_DATA_TMP, load_map_data_titl_resolv).
-define(ETS_MAP_BORN_TMP, load_map_data_born).
-define(MONSTER_BASEINFO_MAP,monster_baseinfo_map).
-define(ETS_MAP_DATA_STALL, ets_map_data_stall).
-define(ETS_MAP_DATA_READO, ets_map_data_reado).
-define(ETS_MAP_BOSS_AI_INFO,ets_map_boss_ai_info).
-define(ETS_MAP_LEVEL_LIMIT, ets_map_level_limit).
-define(ETS_BONFIRES, ets_bonfires).
-define(ETS_COLLECT_POINTS, ets_collect_points).

-define(ETS_MAPS, ets_maps).

-include("common.hrl").



-record(map_state, {mapid, map_name, pg2_name, mod_fight_pid, offsetx, offsety, grid_width, grid_height, mapnif}).

-define(MONSTER_CREATE_TYPE_NORMAL, 1).%%普通怪物
-define(MONSTER_CREATE_TYPE_YBC, 2).%%镖车怪物
-define(MONSTER_CREATE_TYPE_FAMILY_YBC, 3).%%门派镖车
-define(MONSTER_CREATE_TYPE_MANUAL_CALL, 4).%%手动召唤的怪物
-define(MIN_MONSTER_WORK_TICK,200).%%怪物轮询最小时间间隔


-define(NORMAL,1).%%普通怪
-define(ELITE,2).%%精英怪
-define(BOSS,3).%%BOSS怪

-define(GUARD_STATE,1). %%怪物警戒状态
-define(FIGHT_STATE,2). %%怪物战斗状态
-define(DEAD_STATE,3).  %%怪物死亡状态
-define(RETURN_STATE,4). %%怪物返回状态
-define(FIRST_BORN_STATE, 6). %%第一次进入
-define(PATROL_STATE, 7). %%巡逻状态
-define(HOLD_STATE, 8). %%占有状态

-define(FIRST_ENEMY_LEVEL,1).  %%一级仇恨
-define(SECOND_ENEMY_LEVEL,2). %%二级仇恨
-define(THIRD_ENEMY_LEVEL,3).  %%三级仇恨

-define(REFRESH_BY_INTERVAL,1). %%死亡后间隔一定时间刷新
-define(REFRESH_BY_TIMEBUCKET,2). %%定时刷新

-define(BLOOD,1).  %%血属性
-define(MAGIC,2).  %%蓝属性

-define(ACTOR_ATTACK_TYPE_PHY,1).
-define(ACTOR_ATTACK_TYPE_PHY_FAR,2).
-define(ACTOR_ATTACK_TYPE_MAGIC,3).
-define(ACTOR_ATTACK_TYPE_MAGIC_FAR,4).

-define(INFINITY_TICK,2000000000).   %%无穷大

%% monster_change_info 怪物变化配置信息 r_monster_change
-record(monster_state, {monster_info, %% record() p_monster
                        ai_info,      %% record() p_boss_ai_plan
                        mapname,
                        map_id,
                        deadtime,     %% int()
                        last_path,
                        buf_timer_ref,%% list() [{buffType:int(),time:int()}|L]
                        create_type,
                        created_time,
                        walk_path,
                        patrol_pos,
                        touched_ai_condition_list,
                        last_attack_time,
                        last_enemy_pos,
                        post_dead_fun,
                        next_work_tick,
                        next_work_truple,
                        special_data,
                        first_attack_time = 0,
                        monster_change_info}).

-record(actor_fight_attr, {
                           actor_id,
                           actor_name,
                           max_phy_attack, 
                           min_phy_attack, 
                           max_magic_attack, 
                           min_magic_attack,
                           phy_defence,
                           magic_defence,
                           buffs=[],
                           luck,
                           no_defence,
                           miss,
                           double_attack,
                           phy_anti,
                           magic_anti,
                           pk_mode,
                           pk_points,
                           team_id,
                           family_id,
                           faction_id,
                           gray_name,
                           max_hp,
                           phy_hurt_rate,
                           magic_hurt_rate,
                           attack_speed,
                           dizzy,
                           poisoning,
                           freeze,
                           poisoning_resist,
                           dizzy_resist,
                           freeze_resist,
                           hurt_rebound,
						   equip_score = 0,
						   spec_score_one = 0,
						   spec_score_two = 0,
						   hit_rate = 10000
                          }).


-define(MAP_SLICE_WIDTH, 501).
-define(MAP_SLICE_HEIGHT, 290).
-define(MONSTAER_TYPE,monster).
-define(ROLE_TYPE,role).

-define(PK_PEACE, 0). %和平模式
-define(PK_ALL, 1). %全体模式
-define(PK_TEAM, 2). %组队模式
-define(PK_FAMILY, 3). %门派模式
-define(PK_FACTION, 4). %国家模式
-define(PK_MASTER, 5). %善恶模式


-define(TARGET_SELF, 0).
-define(TARGET_PET, 1).
-define(TARGET_MONSTER, 2).
-define(TARGET_ENEMY, 3).
-define(TARGET_FRIEND, 4).

-define(YBC_CHANGE_MAP_DISTANCE, 10).%% 镖车与角色距离多远时可以切换地图
-define(YBC_WALK_ALLOW_DISTANCE, 23).%% 镖车跟随的有效距离
-define(YBC_WALK_MIN_STOP_DISTANCE, 3).%% 镖车在角色周围的多少个格子就自动停下不跟随了 即与角色保持一定距离
-define(YBC_COMMIT_DISTANCE, 5).%%镖车提交的距离 即距离NPC多远就可以提交


%%world move to map
-define(MAX_OVER_LAP,50).

-record(role_first_level_attr, {
                                str=0, 
                                int=0, 
                                con=0, 
                                dex=0, 
                                men=0
                               }).

-record(role_second_level_attr, {
                                 max_hp=0,
                                 max_mp=0,
                                 max_hp_rate=0,
                                 max_mp_rate=0,
                                 phy_attack_rate=0,
                                 max_phy_attack=0, 
                                 min_phy_attack=0,
                                 max_magic_attack=0, 
                                 min_magic_attack=0,
                                 magic_attack_rate=0, 
                                 phy_defence=0, 
                                 phy_defence_rate=0,
                                 magic_defence=0,
                                 magic_defence_rate=0,
                                 hp_recover_speed=0,
                                 mp_recover_speed=0,
                                 luck=0,
                                 move_speed=0,
                                 move_speed_rate=0,
                                 attack_speed=0,
                                 attack_speed_rate=0,
                                 miss=0,
                                 no_defence=0,
                                 double_attack=0,
                                 phy_anti=0,
                                 magic_anti=0,
                                 phy_hurt_rate=0,
                                 magic_hurt_rate=0,
                                 dizzy=0,
                                 poisoning=0,
                                 freeze=0,
                                 poisoning_resist=0,
                                 dizzy_resist=0,
                                 freeze_resist=0,
                                 hurt = 0,
                                 hurt_rebound = 0
                                }).
%%普通Server NPC出生方式
-define(SERVER_NPC_CREATE_TYPE_NORMAL, 1).
%%召唤出生方式
-define(SERVER_NPC_CREATE_TYPE_MANUAL, 2).


%% 逐鹿天下副本Server NPC基本信息配置ETS表
%% 保存的记录结果为：p_server_npc_base_info
-define(ETS_SERVER_NPC,ets_server_npc).


%% 逐鹿天下副本Server NPC出生点配置ETS表
-define(ETS_SERVER_NPC_BORN,ets_server_npc_born).
%% 第一版本的Server NPC 出生点配置
%% map_id 地图id
%% npc_type Server NPC 类型 1，逐鹿天下副本Server NPC
%% sub_list 结构为[r_server_npc_born_sub,r_server_npc_born_sub,...]
-record(r_server_npc_born,{map_id,npc_type,sub_list}).
-record(r_server_npc_born_sub,{npc_type_id,tx,ty,dir}).

%% 逐鹿天下副本Server NPC 类型
-define(SERVER_NPC_TYPE_VWF,1).
%% 不动的设施Server NPC 类型
-define(SERVER_NPC_TYPE_UNMOVE,2).
%% 战斗守卫等Server NPC 类型
-define(SERVER_NPC_TYPE_FIGHT,3).

%% Server NPC 状态
-record(server_npc_state,{
                          server_npc_info,
                          dead_call_back_fun,
                          ai_info,
                          mapname,
                          map_id,
                          deadtime,last_path,
                          buf_timer_ref,
                          create_type,
                          created_time,
                          walk_path,
                          patrol_pos,
                          touched_ai_condition_list,
                          last_attack_time,
                          last_enemy_pos,
                          next_work_tick,
                          next_work_truple,
                          special_data
                         }).
%% 初始化Server NPC 参数记录
%% server_npc Server NPC信息结构为 p_server_npc
%% create_type 创建类型，map_id 地图id,map_name地图名称，dead_call_back_fun死亡回调函数 state Server NPC 状态
%% special_data 其它特殊数据
-record(r_server_npc_param,{server_npc, create_type, map_id, map_name, dead_call_back_fun, state, special_data}).
-record(p_level_exp, {level, exp}).

%% 角色状态
-record(r_role_state2, {role_id, role_name, line, pid, client_ip, gray_name_time=0, 
                        gray_name_timer_ref, pkpoint_timer_ref, buff_timer_ref, auto_ybc=false, training_timer_ref}).

%% 灰名取消时间
-define(GRAY_NAME_TIME, 30000).
-define(PKPOINT_REDUCE_TIME, 10*60*1000).

%% 防御装备类型
-define(DEFENEQUIP, [401, 501, 601, 701, 801, 901]).
%% 攻击装备类型
-define(ATTACKEQUIP, [101, 102, 103, 104, 105, 201, 301, 1001]).
%% 所有会减耐久度的类型
-define(ALLEQUIP, [401, 501, 601, 701, 801, 901, 101, 102, 103, 104, 105, 201, 301, 1001]).

%% 怪物出生死亡广播
-record(r_monster_born_and_dead_broadcast, {monster_type_id, born_broadcast, dead_broadcast, broadcast_channel}).

%% 位置跳转类型
-define(CHANGE_POS_TYPE_NORMAL, 1). %% 普通
-define(CHANGE_POS_TYPE_CHARGE, 2).	%% 冲锋
-define(CHANGE_POS_TYPE_RELIVE, 3). %% 复活

%% 最大掉落数量
-define(MAX_DROP_NUM, 5).

%%宠物系统相关
-define(ROLE_PET_INFO,role_pet_info).
-define(ROLE_SUMMONED_PET_ID,role_summoned_pet_id).
-define(PET_ID_LIST,pet_id_list).
-define(LAST_REDUCE_LIFE_TICK,last_reduce_life_tick).
-define(PET_BUFF_TIMER_REF,pet_buff_timer_ref).

-define(PET_NORMAL_STATE,1).
-define(PET_FEED_STATE,3).
-define(PET_GROW_STATE,4).


%%国战时间
-define(back_faction_time, back_faction_time).
-define(defen_faction_id, defen_faction_id).
%%自动T除别国玩家保护时间
-define(map_protected_time, map_protected_time).

-define(MAP_PROTECT_RC_FACTION_YBC, 1).%%保护理由-国运
-define(MAP_PROTECT_RC_FACTION_WAR, 2).%%保护理由-国战

%% 减PK值类型
-define(PK_POINT_REDUCE_TYPE_NORMAL, 1).
-define(PK_POINT_REDUCE_TYPE_PER_TEN_MIN, 2).

%% 门派地图的MapID
-define(DEFAULT_FAMILY_MAP_ID,10300).

-include("letter.hrl").


%% 宏定义要求同样的命名规约，用于发送succ=false的toc数据结构
-define(SEND_ERR_TOC(RecName,Reason),        
        R2 = #RecName{succ=false,reason=Reason},common_misc:unicast(Line, RoleID, Unique, Module, Method, R2)
).
-define(SEND_ERR_TOC2(RecName,Reason),        
        case is_binary(Reason) of
            true ->
                R3 = #RecName{succ=false,reason=Reason},common_misc:unicast(Line, RoleID, Unique, Module, Method, R3);
            false ->
                ?ERROR_MSG_STACK("SystemError",Reason),
                R3 = #RecName{succ=false,reason=?_LANG_SYSTEM_ERROR},common_misc:unicast(Line, RoleID, Unique, Module, Method, R3)
            end
).

%% 多倍经验BUFF类型
-define(EXP_BUFF_TYPE, [1000, 89, 90, 1050]).

%% 普通获得经验
-define(EXP_ADD_TYPE_NORMAL, 0).
%% 训练获得经验
-define(EXP_ADD_TYPE_TRAINING, 1).

%% title: 称号，color: 颜色, multi_exp_buff_id: 多倍经验的BUFFID, multi_exp_times: 多倍经验可领取次数, mission_transfer_times: 任务免费传送次数
%% shop_discount: 商店折扣
-record(r_vip_level_info, {title_name, color, multi_exp_buff_id, multi_exp_times, accumulate_exp_times, mission_transfer_times, shop_discount, pet_training_times, pet_understanding_rate}).
%% 
-record(r_vip_card, {gold, item_need, last_time, time_add}).

%%国战阶段 
-define(WAROFFACTION_STAGE, waroffaction_stage).
%%国战开始前1小时的准备阶段
-define(WAROFFACTION_READY_STAGE, waroffaction_ready_stage). 
%%国战第一阶段，打平江箭塔
-define(WAROFFACTION_FIRST_STAGE, waroffaction_first_stage).
%%国战第二阶段，打王都的张将军
-define(WAROFFACTION_SECOND_STAGE, waroffaction_second_stage).
%%国战第三阶段，打王都的国旗
-define(WAROFFACTION_THIRD_STAGE, waroffaction_third_stage).
%%国战结束阶段，国战时间结束或者国旗被砍倒
-define(WAROFFACTION_END_STAGE, waroffaction_end_stage).

-record(r_sort_type, {category, sub_category, typeid, sort_type, gold_first, min_level, max_level, color, pro, page, is_reverse}).
%% 排序类型
%% 1、等级排序 2、数量排序 3、价格排序
-define(SORT_TYPE_LEVEL, 1).
-define(SORT_TYPE_NUM, 2).
-define(SORT_TYPE_PRICE, 3).

%% 怪物变形相关配置
%% monster_type_id 怪物类型id
%% is_attack 怪物是否攻击 0怪物攻击 1怪物不攻击
%% dont_interval_seconds 怪物不攻击持续时间，单位秒
%% next_monster_type_id 变形的怪物类型id
-record(r_monster_change_info,{monster_type_id = 0,is_attack = 0,dont_interval_seconds = 0,next_monster_type_id = 0}).

-define(PICK_TYPE_NORMAL, 1).
-define(PICK_TYPE_BOX, 2).
-define(DROPTHING_TYPE_BOX,11). %%特殊道具——宝箱

%%常见错误类型
-define(ERR_OK, 0). %%OK
-define(ERR_SYS_ERR, 1).    %%系统错误
-define(ERR_OTHER_ERR, 2).  %%其他错误，具体原因见Reason
-define(ERR_INTERFACE_ERR, 3).  %%接口错误
