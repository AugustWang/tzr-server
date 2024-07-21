%%%----------------------------------------------------------------------
%%% @copyright 2011 
%%%
%%% @author markycai, 2011-06-30
%%% @doc  活动配置
%%% @end
%%%----------------------------------------------------------------------
%%排行榜活动
-define(RANK_ROLE_LEVEL_KEY,1001).       %%等级
-define(RANK_EQUIP_REFINING_KEY,1005).   %%神兵总分
-define(RANK_EQUIP_REINFORCE_KEY,1006).  %%强化
-define(RANK_EQUIP_STONE_KEY,1007).      %%镶嵌
-define(RANK_PET_KEY,1008).
-define(RANK_YDAY_GIVE_FLOWER_KEY,1009).
-define(RANK_YDAY_RECV_FLOWER_KEY,1010).

%%充值活动
-define(SPEND_SUM_PAY_KEY,2001).
-define(SPEND_ONCE_PAY_KEY,2002).
-define(SPEND_USE_GOLD_KEY,2003).

%%特殊类活动 
-define(OTHER_EQUIP_REINFORCE_KEY,3001).    %%指定强化
-define(OTHER_EQUIP_STONE_KEY,3002).        %%指定镶嵌
-define(OTHER_EQUIP_SCORE_KEY,3003).        %%指定装备评分
-define(OTHER_EQUIP_HOLE_KEY,3004).         %%指定开孔
-define(OTHER_PET_UNDERSTANDING_KEY,3005).  %%宠物悟性
-define(OTHER_PET_SKILL_COUNT_KEY,3006).    %%宠物技能数
-define(OTHER_PET_APTITUDE_KEY,3007).       %%宠物资质
-define(OTHER_ROLE_LEVEL_KEY,3008).         %%指定等级
%%活动列表
-define(ACTIVITY_CONFIG_LIST,[{?SPEND_SUM_PAY_KEY,spend_activity},
                              {?SPEND_ONCE_PAY_KEY,spend_activity},
                              {?SPEND_USE_GOLD_KEY,spend_activity},
                              {?RANK_ROLE_LEVEL_KEY,ranking_activity},
                              {?RANK_EQUIP_REFINING_KEY,ranking_activity},
                              {?RANK_EQUIP_REINFORCE_KEY,ranking_activity},
                              {?RANK_EQUIP_STONE_KEY,ranking_activity},
                              {?RANK_PET_KEY,ranking_activity},
                              {?RANK_YDAY_GIVE_FLOWER_KEY,ranking_activity},
                              {?RANK_YDAY_RECV_FLOWER_KEY,ranking_activity},
                              {?OTHER_EQUIP_REINFORCE_KEY,other_activity},
                              {?OTHER_EQUIP_STONE_KEY,other_activity},
                              {?OTHER_ROLE_LEVEL_KEY,other_activity},
                              {?OTHER_EQUIP_HOLE_KEY,other_activity},
                              {?OTHER_PET_UNDERSTANDING_KEY,other_activity},
                              {?OTHER_PET_SKILL_COUNT_KEY,other_activity},
                              {?OTHER_PET_APTITUDE_KEY,other_activity},
                              {?OTHER_EQUIP_SCORE_KEY,other_activity}]).


%%独立和无限
-define(LIMIT,1). %%有限
-define(UNLIMIT,0). %%无限

%%等待地图处理时间
-define(REQUEST_LAST_TIME,5).%%秒

-define(BAN,-2).
-define(DONE,-1).   %%已领取
-define(ABLE,1).   %%可领
-define(UNABLE,0). %%未完成


%% button状态，只前端显示button用
-define(UNREACH,1). %% 未完成
-define(CANGET,2).  %% 可领取
-define(FINISH,3).  %% 已领取
-define(CANNOT,4).  %% 不可领

%% 奖励物品
%% type_id:int() 物品id
%% num:int() 物品数目
%% bind:int() 是否绑定  0表示不绑
%% last_time:int() 持续时间 0表示永久 >0表示持续多少秒
-record(r_prize_goods,{type_id,type,num,bind=true,color,quality,last_time}).

%% 条件映射奖励
%% condition:tuple() 奖励条件
%% 充值消费类
%% 累计充值:golds:int()
%% 单笔充值:golds:int()
%% 累计消费:golds:int()
%% 排行榜类
%% 等级排行榜:{startlevel,endlevel}:tuple()
%% 特殊类
%% 装备强化：{type_id:int(),reinforce_result:int()}:tuple()

%% multi:int()奖励倍数
%% prize_goods:list() [#r_prize_goods] 奖励物品列表
-record(r_condition_prize,{condition_id,condition,multi,prize_goods}).

%% key:int()活动id
%% limit:int() 独立或无限 0表示无限 
%% visible_start_time:date() 可见起始时间
%% visible_end_time:date()  可见结束时间
%% activity_start_time:date() 活动起始时间
%% activity_end_time:date() 活动结束时间
%% reward_start_time:date() 领奖起始时间
%% reward_end_time:date() 领奖结束时间
%% activity_title:string() 介绍标题
%% activity_text:string() 介绍内容
%% condition_prize:list()[#r_condition_prize] 条件与奖励
%%-record(r_special_activity,{key,times,start_time,end_time,condition,limit,multi,prize_goods,activity_title,activity_text}).
-record(r_spend_activity,{key,
                            limit,
                            visible_start_time,
                            visible_end_time,
                            activity_start_time,
                            activity_end_time,
                            reward_start_time,
                            reward_end_time,
                            activity_title,
                            activity_text,
                            condition_prize}).

%% 排行榜活动
%% activity_start_time:date() 忽略之
%% activity_end_time:date() 活动时间点，即获取排行榜数据的时间，排行榜编辑器确定活动只做一天，即独立
-record(r_ranking_activity,{key,
                            limit=1,
                            visible_start_time,
                            visible_end_time,
                            activity_start_time=0,
                            activity_end_time,
                            reward_start_time,
                            reward_end_time,
                            activity_title,
                            activity_text,
                            condition_prize}).

%% 特殊类活动
-record(r_other_activity,{key,
                            limit=0,
                            visible_start_time,
                            visible_end_time,
                            activity_start_time,
                            activity_end_time,
                            reward_start_time,
                            reward_end_time,
                            activity_title,
                            activity_text,
                            condition_prize}).


