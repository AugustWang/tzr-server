-record(role_skill_detail, {role_id, skill_id, cur_level}).

%%macro
-define(TYPE_ROLE,1).
-define(TYPE_MONSTER,2).
-define(TYPE_PET,3).
-define(TYPE_OTHER,0).
-define(TYPE_YBC,7).
-define(TYPE_SERVER_NPC,10).

%%========技能施法方式=====================
-define(ATTACK_TYPE_ACTIVE,1).
-define(ATTACK_TYPE_PASSIVE,2).

%%========技能最终效果类型=================
%%减血
-define(RESULT_TYPE_REDUCE_HP,1).
%%加血
-define(RESULT_TYPE_ADD_HP,2).
%%减蓝
-define(RESULT_TYPE_REDUCE_MP,3).
%%加蓝
-define(RESULT_TYPE_ADD_MP,4). 


%%========技能作用范围类型==================
%%施法者自己
-define(TARGET_TYPE_SELF,1).
%%施法者自己的周围
-define(TARGET_TYPE_SELF_AROUND,2).
%%施法者前方区域
-define(TARGET_TYPE_SELF_FRONT,3).
%%选择的目标
-define(TARGET_TYPE_OTHER,4).
%%选择目标的周围区域
-define(TARGET_TYPE_OTHER_AROUND,5).
%%选择目标的前方区域
-define(TARGET_TYPE_OTHER_FRONT,6).
%%选择的坐标点范围区域内的地图
-define(TARGET_TYPE_AREA_MAP,7).
%%宠物主人
-define(TARGET_TYPE_PET_OWNER,8).

 

%%===========技能效果类型===================
%%普通物理攻击力
-define(CALC_TYPE_BASE_PHY_ATTACK,1).
%%普通魔法攻击力
-define(CALC_TYPE_BASE_MAGIC_ATTACK,2).
%%物理伤害绝对值输出
-define(CALC_TYPE_ABSOLUTE_PHY_ATTACK,3).
%%法力伤害绝对值输出
-define(CALC_TYPE_ABSOLUTE_MAGIC_ATTACK,4).
%%重击
-define(CALC_TYPE_DOUBLE_ATTACK,7).
%%驱散
-define(CALC_TYPE_DISPEL_BUFF,9).
%%复活
-define(CALC_TYPE_RELIVE,10).
%%瞬移
-define(CALC_TYPE_TRANSFER,11).
%%冲锋
-define(CALC_TYPE_CHARGE,12).
%%吸魔
-define(CALC_TYPE_ABSORB_MP, 13).
%%下马
-define(CALC_TYPE_MOUNT_DOWN, 14).
%%根据宠物血量加血
-define(CALC_TYPE_ADD_HP_WITH_PET_HP, 15).
%%根据宠物血量加蓝
-define(CALC_TYPE_ADD_MP_WITH_PET_HP, 16).
%%咆哮
-define(CALC_TYPE_PAO_XIAO, 17).
%%驱散有害的buff
-define(CALC_TYPE_DISPEL_DEBUFF, 18).


%%===============特殊技能ID==================
%%冲锋技能
-define(SKILL_CHARGE,12104001).
%%复活技能
-define(SKILL_RELIVE,41108001).
%%火焰陷阱
-define(SKILL_FIRE_TRAP,21209002).
%%荆棘陷阱
-define(SKILL_JINGJI_TRAP,21209001).
%%怪物和NPC召唤
-define(SKILL_SUMMON,91106001).
%%怪物传送的技能
-define(SKILL_TRANSFER,91107001).

%%普通近身攻击
-define(SKILL_NORMAL_SHORT_ATTACK,1).
%%普通远程攻击
-define(SKILL_NORMAL_FAR_ATTACK,2).
%%远程法力攻击
-define(SKILL_MAGIC_FAR_ATTACK, 5).
%%宠物普通远程物理攻击
-define(SKILL_PET_PHY_FAR_ATTACK,6).
%%宠物普通远程法力攻击
-define(SKILL_PET_MAGIC_FAR_ATTACK, 7).


%%====================技能有效目标==========
%%自身
-define(SKILL_EFFECT_TYPE_SELF,1).
%%友方全部
-define(SKILL_EFFECT_TYPE_FRIEND,2).
%%敌方全部
-define(SKILL_EFFECT_TYPE_ENEMY,3).
%%友方玩家
-define(SKILL_EFFECT_TYPE_FRIEND_ROLE,4).
%%敌方玩家
-define(SKILL_EFFECT_TYPE_ENEMY_ROLE,5).
%%怪物
-define(SKILL_EFFECT_TYPE_MONSTER,6).
%%宠物
-define(SKILL_EFFECT_TYPE_PET,7).
%%押送物
-define(SKILL_EFFECT_TYPE_YBC,8).
%%所有玩家（包括友方和敌方）
-define(SKILL_EFFECT_TYPE_ALL_PLAYER,9).
%%所有目标（所有玩家和怪物等）
-define(SKILL_EFFECT_TYPE_ALL_TARGET,10).
%%NPC
-define(SKILL_EFFECT_TYPE_SERVER_NPC,11).
%% 宠物主人
-define(SKILL_EFFECT_TYPE_MASTER, 12).
%% 坐骑
-define(SKILL_EFFECT_TYPE_MOUNT, 13).


%%====================技能BUFF持续类型==========
%%普通的持续一定的有限
-define(BUFF_LAST_TYPE_REAL_TIME,1).
%%没有时间限制
-define(BUFF_LAST_TYPE_FOREVER_TIME,2).
%%持续的角色在线时间
-define(BUFF_LAST_TYPE_ONLINE_TIME,3).
%%持续的角色在线时间
-define(BUFF_LAST_TYPE_REAL_INTERVAL_TIME,4).
%%宠物出战时拥有
-define(BUFF_LAST_TYPE_SUMMONED_PET,5).


%%====================技能BUFF持续效果类型==========
%%减血
-define(BUFF_INTERVAL_EFFECT_REDUCE_HP,1).
%%加血
-define(BUFF_INTERVAL_EFFECT_ADD_HP,2).
%%减蓝
-define(BUFF_INTERVAL_EFFECT_REDUCE_MP,3).


%%====================一些特殊的BUFF的类型==========
%%经验加倍
-define(BUFF_TYPE_ADD_EXP_MULTIPLE,1000).
-define(FRIEND_BUFF_TYPE,83).
-define(EDUCATE_BUFFTYPE1,89).
-define(EDUCATE_BUFFTYPE2,90).
-define(VIP_MULTI_EXP_TYPE, 1050).

%%===================一些特殊的buf=================
-define(EDUCATE_BUFFID1,10535).
-define(EDUCATE_BUFFID2,10536).
