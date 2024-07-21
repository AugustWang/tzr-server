-record(r_consume_log, {type, log_id, user_id, use_bind,use_unbind, mtime, mtype, mdetail, item_id, item_amount}).


%% 注意：如果消费类型有增加，需要将修改同步到以下目录的相应文件
%%	/app/web/game.www/admin/class/log_silver_class.php
%%  /app/web/game.www/admin/class/log_gold_class.php
%%	/app/web/game.www/admin/update/update_use_gold_log.php

%% 消费类型,银两
-define(CONSUME_TYPE_SILVER_DEDUCT_FROM_GM,1001).                   %%GM后台扣除银两
-define(CONSUME_TYPE_SILVER_BUY_ITEM_FROM_SHOP,1002).               %%系统商店购买道具
-define(CONSUME_TYPE_SILVER_FROM_EXCHANGE,1003).                    %%通过交易失去银两，属于流通
-define(CONSUME_TYPE_SILVER_BUY_GOLD_FROM_BANK,1004).               %%钱庄购买元宝，属于流通
-define(CONSUME_TYPE_SILVER_FEE_BUY_GOLD_FROM_BANK,1005).           %%钱庄交易元宝的手续费
-define(CONSUME_TYPE_SILVER_BUY_ITEM_FROM_STALL,1006).              %%摆摊购买道具，属于流通
-define(CONSUME_TYPE_SILVER_FEE_BUY_ITEM_FROM_STALL,1007).          %%摆摊的手续费
-define(CONSUME_TYPE_SILVER_DROP_FOR_DEAD,1008).                    %%死亡掉落的失去银两
-define(CONSUME_TYPE_SILVER_CREATE_FAMILY,1009).                    %%创建门派手续费
-define(CONSUME_TYPE_SILVER_DONATION,1010).                         %%国库捐款的扣银两
%%-define(CONSUME_TYPE_SILVER_YABIAOCHE,1011).                        %%押镖车的扣银两,(已废弃)
-define(CONSUME_TYPE_SILVER_UP_SKILL,1012).                         %%升级技能的扣银两
-define(CONSUME_TYPE_SILVER_FIX_EQUIP,1013).                        %%修理装备的扣银两
-define(CONSUME_TYPE_SILVER_SEND_LABA,1014).                        %%发送喇叭消息的扣银两
-define(CONSUME_TYPE_SILVER_REFRESH_MISSION,1015).                  %%刷新任务的扣银两,(暂时还没用上)
-define(CONSUME_TYPE_SILVER_FIVE_ELE_REFRESH,1016).                 %%人物五行属性刷新的扣银两
-define(CONSUME_TYPE_SILVER_RELIVE,1017).                   		%%复活扣除银两
-define(CONSUME_TYPE_SILVER_CHEFU,1018).                   			%%车夫扣除银两
-define(CONSUME_TYPE_SILVER_MAIL,1019).                   			%%信件扣除银两
-define(CONSUME_TYPE_SILVER_DEPOT,1020).                   			%%开通仓库扣除银两
-define(CONSUME_TYPE_SILVER_MISSION_YBC, 1022).                     %% 任务押镖扣钱
-define(CONSUME_TYPE_SILVER_STALL_TAX, 1023).                       %% 摆摊交易税
-define(CONSUME_TYPE_SILVER_HAIR_CUT, 1024).                        %% 发型扣银两
-define(CONSUME_TYPE_SILVER_FAMILY_YBC, 1025).                      %% 门派拉镖扣银两
-define(CONSUME_TYPE_SILVER_PLANT_UP_SKILL, 1026).                  %% 种植升级技能扣银两
-define(CONSUME_TYPE_SILVER_COUNTER_TREASURE, 1027).                  %% 进入大明宝藏副本扣银两
-define(CONSUME_TYPE_SILVER_CHANGE_HEAD, 1028).                     %% 变换头像扣除银两
-define(CONSUME_TYPE_SILVER_CHANGE_SKIN, 1029).                     %% 取消变身扣除银两


-define(CONSUME_TYPE_SILVER_EQUIP_REINFORCE,1030). %% 装备强化
-define(CONSUME_TYPE_SILVER_EQUIP_COMPOSE,1031). %% 材料合成
-define(CONSUME_TYPE_SILVER_EQUIP_PUNCH,1032). %% 装备打孔
-define(CONSUME_TYPE_SILVER_EQUIP_INLAY,1033). %% 宝石镶嵌
-define(CONSUME_TYPE_SILVER_EQUIP_UNLOAD,1034). %% 宝石拆卸
-define(CONSUME_TYPE_SILVER_EQUIP_BIND,1035). %% 装备绑定
-define(CONSUME_TYPE_SILVER_EQUIP_BUILD,1036). %% 装备打造
-define(CONSUME_TYPE_SILVER_EQUIP_QUALITY,1037). %% 装备品质改造
-define(CONSUME_TYPE_SILVER_EQUIP_SIGNATURE,1038). %% 装备签名
-define(CONSUME_TYPE_SILVER_EQUIP_UPGRADE,1039). %% 装备升级
-define(CONSUME_TYPE_SILVER_EQUIP_DECOMPOSE,1040). %% 装备分解
-define(CONSUME_TYPE_SILVER_EQUIP_FIVEELE,1041). %% 装备五行改造

-define(CONSUME_TYPE_SILVER_DONATE_FACTION_SILVER, 1042).           %% 向国库捐款扣银两
-define(CONSUME_TYPE_SILVER_JAIL_OUT_FORCE, 1043).                  %% 强行出狱弹出银两
-define(CONSUME_TYPE_SILVER_FETCH_CONLOGIN_REWARD, 1044).			%%连续登录奖励购买

-define(CONSUME_TYPE_SILVER_PET_LEARN_SKILL, 1050).			        %%宠物学技能扣除银两
-define(CONSUME_TYPE_SILVER_PET_REFRESH_APTITUDE, 1051).			%%宠物洗灵扣除银两
-define(CONSUME_TYPE_SILVER_PET_ADD_UNDERSTANDING, 1052).			%%宠物提悟扣除银两
-define(CONSUME_TYPE_SILVER_PET_ADD_LIFE, 1053).			        %%宠物延寿扣除银两
-define(CONSUME_TYPE_CHAT_WORLD, 1054).                             %%世界聊天扣除银子
-define(CONSUME_TYPE_SILVER_PET_GROW, 1055).                        %% 训宠能力等级提升消耗银子
-define(CONSUME_TYPE_SILVER_PET_FORGET_SKILL, 1056).                %% 训宠遗忘技能扣除银子
-define(CONSUME_TYPE_SILVER_FAMILY_COLLECT_REFRESH_PRIZE, 1057).    %% 门派采集玩家刷新奖励
-define(CONSUME_TYPE_SILVER_PET_REFINING, 1058).                    %% 宠物炼制扣除银两

-define(CONSUME_TYPE_SILVER_EQUIP_UPCOLOR_GREEN,1059). %% 提升装备颜色：绿
-define(CONSUME_TYPE_SILVER_EQUIP_UPCOLOR_BLUE,1060). %% 提升装备颜色：蓝
-define(CONSUME_TYPE_SILVER_EQUIP_UPCOLOR_PURPLE,1061). %% 提升装备颜色：紫
-define(CONSUME_TYPE_SILVER_EQUIP_UPCOLOR_ORANGE,1062). %% 提升装备颜色：橙
-define(CONSUME_TYPE_SILVER_EQUIP_UPCOLOR_GOLD,1063). %% 提升装备颜色：金

-define(CONSUME_TYPE_SILVER_BUY_ITEM_FROM_MARKET, 1064).			%% 市场购买扣除银两
-define(CONSUME_TYPE_SILVER_PET_TRICK_LEARN, 1065).			        %% 宠物学习或刷新特技
-define(CONSUME_TYPE_SILVER_BUY_BACK, 1066).                        %% 买回物品扣去银两
-define(CONSUME_TYPE_SILVER_RETURN_FAMILY, 1067).                   %% 回门派扣去银两
-define(CONSUME_TYPE_SILVER_PET_TRAINING_START,1068).  %%宠物训练消费银两
-define(CONSUME_TYPE_SIVLER_FAMILY_DONATE,1069).       %%宗族捐献消费银两
-define(CONSUME_TYPE_SIVLER_EQUIP_ADD_MAGIC,1070).     %%装备附魔消费银两


%% 获得类型,银两
-define(GAIN_TYPE_SILVER_GIVE_FROM_GM,2001).            %%GM后台赠送银两
-define(GAIN_TYPE_SILVER_FROM_NEW_ROLE,2002).           %%创建角色默认银两
-define(GAIN_TYPE_SILVER_FROM_STALL_SELL_ITEM,2003).    %%摆摊出售道具，属于流通
-define(GAIN_TYPE_SILVER_FROM_EXCHANGE,2004).           %%通过交易获得银两，属于流通
-define(GAIN_TYPE_SILVER_FROM_BANK,2005).               %%通过钱庄获得银两，属于流通
%%-define(GAIN_TYPE_SILVER_FROM_TASK,2006).               %%任务获得银两,(已废弃)
-define(GAIN_TYPE_SILVER_FROM_SYS_SELL_ITEM,2007).      %%向系统出售道具,(暂时还没用上)
-define(GAIN_TYPE_SILVER_FROM_PICKUP,2008).             %%拾取获得银两
-define(GAIN_TYPE_SILVER_UNDO_BANK_BUY, 2009).          %%钱庄撤消买单，退回银两
-define(GAIN_TYPE_SILVER_STALL_CANCEL, 2010).           %%雇佣摆摊未到期退回部分手续费
-define(GAIN_TYPE_SILVER_MISSION_YBC, 2011).            %%镖车任务获得银两
-define(GAIN_TYPE_SILVER_MISSION_NORMAL, 2012).         %%普通任务
-define(GAIN_TYPE_SILVER_SALE_ITEM_FROM_SHOP,2013).     %%把物品出售给npc商店
-define(GAIN_TYPE_SILVER_ITEM_USE,2014).                %%使用银票道具获得银子
%%-define(GAIN_TYPE_SILVER_ACHIEVEMENT,2015).             %%成就系统获得银子
-define(GAIN_TYPE_SILVER_TRADING,2016).                 %%商贸获得银子
-define(GAIN_TYPE_SILVER_NPC_EXCHANGE,2017).            %%NPC兑换获得银子
-define(GAIN_TYPE_SILVER_CANCEL_FAMILY_YBC, 2018).		%%(副)掌门放弃门派拉镖退还银子
-define(GAIN_TYPE_SILVER_GIVEUP_FAMILY_YBC, 2019).		%%帮众放弃了门派拉镖退还银子
-define(GAIN_TYPE_SILVER_FAMILY_YBC, 2020).             %%门派拉镖获得银两
-define(GAIN_TYPE_SILVER_ACTIVITY_VWF, 2021).           %% 极速讨伐敌营活动获取绑定银子
-define(GAIN_TYPE_SILVER_LETTER_RETURN,2022).           %%信件发送失败，返还银两
-define(GAIN_TYPE_SILVER_FROM_MARKET_SELL_ITEM, 2023).	%% 市场出售获得银两
-define(GAIN_TYPE_SILVER_FROM_GOAL, 2024). 				%% 传奇目标赠送银两


%% 消费类型,元宝
-define(CONSUME_TYPE_GOLD_DEDUCT_FROM_GM,3001).     %%GM后台扣除元宝
-define(CONSUME_TYPE_GOLD_SELL_FROM_BANK,3002).     %%钱庄出售元宝，属于流通
-define(CONSUME_TYPE_GOLD_BUY_ITEM_FROM_SHOP,3003). %%系统商店购买道具
-define(CONSUME_TYPE_GOLD_TRAINING_OFFLINE,3004).   %%训练场离线挂机
-define(CONSUME_TYPE_GOLD_RELIVE,3005).             %%复活失去元宝（暂时没用）
-define(CONSUME_TYPE_GOLD_ENABLE_MAP,3006).         %%开启门派地图扣除元宝
-define(CONSUME_TYPE_GOLD_MISSION_YBC, 3007).       %%镖车任务扣除元宝
-define(CONSUME_TYPE_GOLD_SEX_CHANGE, 3008).        %%变性扣除元宝
-define(CONSUME_TYPE_GOLD_EDUCATE_FB_LUCKY_COUNT, 3009).        %%师徒副本刷幸运积分扣除元宝
-define(CONSUME_TYPE_GOLD_JAIL_DONATE, 3010).       %% 捐献监狱建设费
-define(CONSUME_TYPE_GOLD_FETCH_CONLOGIN_REWARD, 3011).			%% 连续登录奖励购买
-define(CONSUME_TYPE_GOLD_AUTO_MISSION, 3014).      %%自动任务扣除元宝
-define(CONSUME_TYPE_GOLD_ACTPOINT_BUY, 3012).      %% 购买活跃度扣除元宝
-define(CONSUME_TYPE_GOLD_PET_CHANGE_NAME, 3013).      %% 宠物改名扣除元宝
-define(CONSUME_TYPE_GOLD_REFRESH_ACCUMULATE_EXP, 3015). %% 刷新累积经验消耗元宝
-define(CONSUME_TYPE_GOLD_EQUIP_MOUNT_RENEWAL, 3016). %% 坐骑续期消耗元宝
-define(CONSUME_TYPE_GOLD_PET_FEED_STAR_UP, 3017). %% 宠物提升训练星级消耗元宝
-define(CONSUME_TYPE_GOLD_PET_FEED_SPEED_UP, 3018). %% 宠物训练加速消耗元宝
-define(CONSUME_TYPE_GOLD_VIP_ACTIVE, 3019).        %% 开通VIP
-define(CONSUME_TYPE_GOLD_ACTIVITY_BENEFIT_BUY, 3020).      %% 购买活动勋章扣除元宝
-define(CONSUME_TYPE_GOLD_PET_GROW_SPEED_UP, 3021).      %% 宠物训宠加速完成
-define(CONSUME_TYPE_GOLD_SCENE_WAR_FB, 3022).      %% 挑战场景大战费用
-define(CONSUME_TYPE_GOLD_PET_ADD_LIFE, 3023).      %% 宠物面板延寿
-define(CONSUME_TYPE_GOLD_PET_ADD_SKILL_GRID, 3024).      %% 宠物增加技能栏
-define(CONSUME_TYPE_GOLD_PET_EXTRA_FEED, 3025).      %% 宠物增加技能栏
-define(CONSUME_TYPE_GOLD_FROM_EXCHANGE, 3026).		%% 交易失去元宝
-define(CONSUME_TYPE_GOLD_BUY_ITEM_FROM_STALL, 3027).         %% 摆摊购买道具获得元宝
-define(CONSUME_TYPE_GOLD_AUTO_YBC, 3028). %% 自动个人拉镖消耗元宝
-define(CONSUME_TYPE_GOLD_BUY_HERO_FB_TIMES, 3029). %% 购买英雄副本次数消耗元宝
-define(CONSUME_TYPE_GOLD_PET_EGG_REFRESH, 3030). %% 刷新宠物蛋消耗元宝
-define(CONSUME_TYPE_GOLD_OPEN_BOX, 3031). %% 开箱子消耗元宝
-define(CONSUME_TYPE_GOLD_BUY_ITEM_FROM_MARKET, 3032). %% 市场购买失去元宝
-define(CONSUME_TYPE_GOLD_VIP_REMOTE_DEPOT, 3033). %% VIP开通远程仓库失去元宝
-define(CONSUME_TYPE_GOLD_CREATE_FAMILY,3034). %%创建门派手续费
-define(CONSUME_TYPE_GOLD_PET_CHANGE_TRAINING_MODE,3035). %% 改变训练模式消费元宝
-define(CONSUME_TYPE_GOLD_ADD_PET_TRAINING_ROOM,3036).            %% 添加宠物训练空位消费元宝
-define(CONSUME_TYPE_GOLD_RESET_FLY_TRAINING_CD_TIME,3037).   %%重设宠物突飞猛进cd时间消费元宝
-define(CONSUME_TYPE_GOLD_FAMILY_DONATE,3038).       %%宗族捐献消费元宝
-define(CONSUME_TYPE_GOLD_AUTO_REFRESH_YBC_COLOR,3039).   %% 一键刷新镖车颜色消耗

%% 获得类型,元宝
-define(GAIN_TYPE_GOLD_GIVE_FROM_GM,4001).          %%GM后台赠送元宝
-define(GAIN_TYPE_GOLD_FROM_NEW_ROLE,4002).         %%创建角色默认元宝
-define(GAIN_TYPE_GOLD_BUY_FROM_BANK,4003).         %%钱庄购买元宝，属于流通
-define(GAIN_TYPE_GOLD_FROM_PAY,4004).              %%通过充值获得元宝
-define(GAIN_TYPE_GOLD_UNDO_BANK_SELL, 4005).       %%钱庄撤消卖单退回元宝，属于流通
-define(GAIN_TYPE_GOLD_SALE_ITEM_FROM_SHOP,4006).   %%把物品出售给npc商店
-define(GAIN_TYPE_GOLD_ITEM_USE,4007).              %%道具使用获得元宝
-define(GAIN_TYPE_GOLD_MISSION_YBC, 4008).          %%镖车任务获得元宝
%%-define(GAIN_TYPE_GOLD_ACHIEVEMENT, 4009).          %%成就系统获得元宝
-define(GAIN_TYPE_GOLD_NPC_EXCHANGE,4010).          %%NPC兑换获得元宝

-define(GAIN_TYPE_GOLD_FROM_EXCHANGE, 4011).		%% 通过交易获得元宝
-define(GAIN_TYPE_GOLD_FROM_STALL_SELL_ITEM, 4012).           %% 摆摊出售道具获得元宝
-define(GAIN_TYPE_GOLD_FROM_MARKET_SELL_ITEM, 4013).	%% 市场出售获得元宝
-define(GAIN_TYPE_GOLD_FROM_GOAL, 4014). 			%% 传奇目标赠送元宝


%%GM指 令
-define(GAIN_TYPE_SILVER_GIVE_FROM_GM_CODE,5001).       %%GM指令获得银两
-define(GAIN_TYPE_GOLD_GIVE_FROM_GM_CODE,5002).         %%GM指令获取元宝

