%% 道具日志的操作类型



%%-----------------------------------------------------
%%##############严重注意###########
%% 若有修改此配置文件务必通知游戏管理后台作相应修改，涉及游戏管理后台文件：
%%  /data/mtzr/app/web/game.www/admin/class/item_log_class.php
%%  /data/mtzr/app/web/game.www/admin/update/update_stat_item_consume_order.php 
%%=====================================================

%% 所有获得的都用 1xxx ，所有失去的都用2xxx，所有转移的都用3***，全部统一用四位数，否则可能会影响程序中判断结果

-define(LOG_ITEM_TYPE_OTHER_HUO_DE,1000).                %%（其他）获得            
-define(LOG_ITEM_TYPE_OTHER_SHI_QU,2000).                %%（其他）失去     
       

-define(LOG_ITEM_TYPE_HOU_TAI_ZENG_SONG,1001).         %%后台赠送       
-define(LOG_ITEM_TYPE_XI_TONG_ZENG_SONG,1002).         %%系统赠送    
-define(LOG_ITEM_TYPE_LI_BAO_HUO_DE,1003).             %%使用礼包获得   
-define(LOG_ITEM_TYPE_CAI_JI_HUO_DE,1004).             %%采集获得      
-define(LOG_ITEM_TYPE_SHI_QU_HUO_DE,1005).             %%拾取获得      
-define(LOG_ITEM_TYPE_REN_WU_HUO_DE,1006).             %%任务获得      
-define(LOG_ITEM_TYPE_SHI_TU_JIANG_LI,1007).           %%师徒奖励       
-define(LOG_ITEM_TYPE_HUO_DONG_JIANG_PIN,1008).               %%活动奖品       
-define(LOG_ITEM_TYPE_XIN_SHOU_MU_BIAO_JIANG_PIN,1009).       %%新手目标奖品                 
-define(LOG_ITEM_TYPE_SHANG_DIAN_GOU_MAI,1010).               %%商店购买       
-define(LOG_ITEM_TYPE_JIAO_YI_HUO_DE,1011).            %%交易获得       
-define(LOG_ITEM_TYPE_BAI_TAN_HUO_DE,1012).            %%摆摊获得       
-define(LOG_ITEM_TYPE_DA_ZAO_HUO_DE,1013).             %%打造获得      
-define(LOG_ITEM_TYPE_HE_CHENG_HUO_DE,1014).           %%合成获得       
-define(LOG_ITEM_TYPE_CHAI_XIE_HUO_DE,1015).           %%拆卸获得
-define(LOG_ITEM_TYPE_ZHUANG_BEI_SHENG_JI_HUO_DE,1016).        %%装备升级获得                 
-define(LOG_ITEM_TYPE_ZHUANG_BEI_FEN_JIE_HUO_DE,1017).         %%装备分解获得                 
-define(LOG_ITEM_TYPE_LIAN_ZHI_HUO_DE,1018).           %%炼制获得         （暂时没有）
-define(LOG_ITEM_TYPE_KAI_KONG_HUO_DE,1019).           %%开孔获得    
-define(LOG_ITEM_TYPE_XIN_JIAN_FU_JIAN_HUO_DE,1020).    %%信件附件获得
-define(LOG_ITEM_TYPE_GAIN_NPC_EXCHANGE_DEAL,1021).          %%NPC兑换获得
-define(LOG_ITEM_TYPE_GAIN_ACTIVITY_GET,1022).          %%节日活动获得
-define(LOG_ITEM_TYPE_CAI_JI_COUNTRY_TREASURE,1023).    %%大明宝藏活动的采集获得
-define(LOG_ITEM_TYPE_ENTER_EDUCATE_FB,1024).    %%进入师门同心副本获得
-define(LOG_ITEM_TYPE_ACTPOINT_AWARD,1025).    %%活跃度奖励获得
-define(LOG_ITEM_TYPE_GAIN_CONLOGIN, 1026).		%% 领取连续登录奖励获得
-define(LOG_ITEM_TYPE_TAKE_OFFICE_EQUIP,1027).    %%领取官印获得
-define(LOG_ITEM_TYPE_FAMILY_DEPOT_GETOUT,1028).    %%门派仓库领取获得
-define(LOG_ITEM_TYPE_ACTIVITY_BENEFIT_AWARD,1029).    %%日常福利获得
-define(LOG_ITEM_TYPE_SCENE_WAR_FB_AWARD,1030).    %%场景大战副本获得
-define(LOG_ITEM_TYPE_CAI_JI_SCENE_WAR_FB,1031).    %%场景大战副本采集获得
-define(LOG_ITEM_TYPE_GIFT_ITEM_AWARD,1032).    %%道具奖励获得
-define(LOG_ITEM_TYPE_QIANG_HUA_HUO_DE,1033).           %%强化获得  
-define(LOG_ITEM_TYPE_XIANG_QIAN_HUO_DE,1034).          %%镶嵌获得
-define(LOG_ITEM_TYPE_RETAKE_HUO_DE,1035).              %%天工炉取回物品获得
-define(LOG_ITEM_TYPE_UPCOLOR_HUO_DE,1036).              %%提升装备颜色获得
-define(LOG_ITEM_TYPE_PET_REFINING_HUO_DE,1037).        %%宠物炼制获得

-define(LOG_ITEM_TYPE_PAY_FIRST_GIFT_HUO_DE,1038).        %%首充礼包获得
-define(LOG_ITEM_TYPE_PAY_GIFT_HUO_DE,1039).        %%单次充值礼包获得
-define(LOG_ITEM_TYPE_OPEN_BOX_HUO_DE,1040).        %%天工开物获得
-define(LOG_ITEM_TYPE_MARKET_HUO_DE, 1042).			  %%市场获得
-define(LOG_ITEM_TYPE_BOX_RESTORE_HUO_DE,1043).        %%宝物空间获得
-define(LOG_ITEM_TYPE_HERO_FB_SELECT_POKER_HUO_DE,1044).  %%个人副本翻牌获得
-define(LOG_ITEM_TYPE_GAIN_PRESTIGE, 1045).             %% 声望兑换获得
-define(LOG_ITEM_TYPE_TI_SHENG_PIN_ZHI_HUO_DE,1046).       %%装备重铸获得  
-define(LOG_ITEM_TYPE_SPECIAL_ACTIVITY_HUO_DE,1047).   %% 特殊活动获得
-define(LOG_ITEM_TYPE_EQUIP_ADD_MAGIC_HUO_DE,1048).    %%装备附魔获得
-define(LOG_ITEM_TYPE_SPECIAL_USE_HUO_DE,1049). %% 特殊使用物品获得
-define(LOG_ITEM_TYPE_GAIN_GOAL, 1050).					%% 领取传奇目标获得


-define(LOG_ITEM_TYPE_CHU_SHOU_XI_TONG,2001).          %%出售给系统       
-define(LOG_ITEM_TYPE_JIAO_YI_SHI_QU,2002).            %%交易失去       
-define(LOG_ITEM_TYPE_BAI_TAN_CHU_SHOU,2003).          %%摆摊出售       
-define(LOG_ITEM_TYPE_SHOU_DONG_DIU_QI,2004).          %%手动丢弃       
-define(LOG_ITEM_TYPE_SHI_YONG_SHI_QU,2005).           %%使用失去       
-define(LOG_ITEM_TYPE_REN_WU_KOU_CHU,2006).            %%任务扣除       
-define(LOG_ITEM_TYPE_HUO_DONG_KOU_CHU,2007).          %%活动扣除       
-define(LOG_ITEM_TYPE_TI_SHENG_PIN_ZHI_SHI_QU,2008).       %%提升品质失去                 
-define(LOG_ITEM_TYPE_ZHONG_XIN_BANG_DING_SHI_QU,2009).    %%重新绑定失去                 
-define(LOG_ITEM_TYPE_QIANG_HUA_SHI_QU,2010).          %%强化失去       
-define(LOG_ITEM_TYPE_DA_ZAO_SHI_QU,2011).             %%打造失去      
-define(LOG_ITEM_TYPE_HE_CHENG_SHI_QU,2012).           %%合成失去       
-define(LOG_ITEM_TYPE_CHAI_XIE_SHI_QU,2013).           %%拆卸失去       
-define(LOG_ITEM_TYPE_XIANG_QIAN_SHI_QU,2014).         %%镶嵌失去       
-define(LOG_ITEM_TYPE_ZHUANG_BEI_SHENG_JI_SHI_QU,2015).    %%装备升级失去                 
-define(LOG_ITEM_TYPE_ZHUANG_BEI_FEN_JIE_SHI_QU,2016).     %%装备分解失去                 
-define(LOG_ITEM_TYPE_WU_XING_GAI_ZAO_SHI_QU,2017).        %%五行改造失去                 
-define(LOG_ITEM_TYPE_LIAN_ZHI_SHI_QU,2018).           %%炼制失去       （暂时没有）
-define(LOG_ITEM_TYPE_DIAO_LUO_SHI_QU, 2019).          %%掉落失去 (死亡掉落)
-define(LOG_ITEM_TYPE_KAI_KONG_SHI_QU,2020).           %%开孔失去 
-define(LOG_ITEM_TYPE_XIN_JIAN_FU_JIAN_SHI_QU,2021).    %%信件附件失去
-define(LOG_ITEM_TYPE_LOST_NPC_EXCHANGE_DEAL,2022).     %%NPC兑换失去
-define(LOG_ITEM_TYPE_QUIT_EDUCATE_FB,2023).            %%退出师门同心副本失去
-define(LOG_ITEM_TYPE_RETRIEVE_OFFICE_EQUIP,2024).      %%回收官印
-define(LOG_ITEM_TYPE_FAMILY_DEPOT_PUTIN,2025).      %%门派仓库存入失去
-define(LOG_ITEM_TYPE_RETAKE_SHI_QU,2026).           %%天工炉取回物品失去
-define(LOG_ITEM_TYPE_UPCOLOR_SHI_QU,2027).              %%提升装备颜色失去
-define(LOG_ITEM_TYPE_MARKET_CHU_SHOU, 2028).			 %%市场出售
-define(LOG_ITEM_TYPE_BOX_RESTORE_P_CHU_SHOU, 2029).			 %%宝物空间提取失去
-define(LOG_ITEM_TYPE_BOX_RESTORE_D_CHU_SHOU, 2030).			 %%宝物空间销毁失去
-define(LOG_ITEM_TYPE_PET_FLY_TRAINING_SHI_QU,2031).             %%宠物突飞猛进失去
-define(LOG_ITEM_TYPE_EQUIP_ADD_MAGIC_SHI_QU,2032).             %%装备附魔失去
-define(LOG_ITEM_TYPE_TASK_SHI_QU,2033). %% 任务扣除物品
-define(LOG_ITEM_TYPE_SPECIAL_USE_SHI_QU,2034). %% 特殊使用物品扣除

-define(LOG_ITEM_TYPE_GAIN_STALL_GETOUT, 3001).          %%摊位取出
-define(LOG_ITEM_TYPE_LOST_STALL_PUTIN, 3002).          %%放进摊位

-define(LOG_ITEM_TYPE_LOST_REFRESH_ACCUMULATE_EXP, 3003). %% 刷新累积经验失去
-define(LOG_ITEM_TYPE_FLOWERS_GIVE_SHI_QU, 3004). %%鲜花赠送失去

