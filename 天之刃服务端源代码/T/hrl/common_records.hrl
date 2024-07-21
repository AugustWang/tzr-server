
%% 给玩家的赠品配置（登陆的时候给予赠送）
%% present_id:int()
%% title:binary()
%% max_times:int()  表示该则赠品的最大领取次数
%% level:int()      领取赠品的等级要求
%% item_list_male:list()    表示男性玩家的赠送道具列表
%% item_list_female:list()  表示女性玩家的赠送道具列表
%% is_direct_get:bool()  是否直接获取赠品
%% npc_list:list()      寻路的NPC列表
%% start_date:date()   
%% end_date:date()   
-record(r_present_config, {present_id,title,max_times,level,item_list_male,item_list_female,is_direct_get,npc_list,start_date,end_date}).


%% 门派技能的具体配置
%% skill_id:int()  
%% level:int()      技能等级
%% category:int()   职业分类
%% learn_need_silver:int()  (学习)消耗银两
%% forget_need_silver:int()  (遗忘)消耗银两
%% learn_family_contribute:int() (学习)消耗门派贡献度  
%% need_family_money:int() (研究)消耗门派资金
%% need_family_active_point:int()  (研究)消耗门派繁荣度
-record(r_family_skill,{skill_id,level,category,learn_need_silver,forget_need_silver,learn_family_contribute,need_family_money,need_family_active_point}).

%% 门派BUFF的具体配置
%% fml_buff_id:integer()    门派BUFF对应的ID
%% buff_level:integer()    技能BUFF对应的等级
%% buff_id:integer()    可以领取的技能BUFF的ID
%% need_family_contribute:integer()    需要扣除的门派贡献度
-record(r_family_buff,{fml_buff_id,buff_level,buff_id,need_family_contribute}).


%% 门派技能限制的配置
%% family_level:int()  门派等级
%% skill_count:int()   技能个数限制
%% skill_level:int()   技能等级
%% forget_family_money:int()    遗忘时消耗的门派资金
-record(r_family_skill_limit, {family_level,skill_count,skill_level,forget_family_money}).

%% 门派的基本数值配置
%%  max_member:int() 对应的门派最大人数限制
%%  second_owners:int() 对应的长老人数限制
%%  uplevel_money:int() 对应的升级银两
%%  uplevel_ap:int() 对应的升级繁荣度
%%  daily_maintain_money:int()   每天地图消耗的银两
%%  daily_maintain_ap:int()      每天地图消耗的繁荣度
-record(r_family_config,{level,max_member,second_owners,uplevel_money,uplevel_ap,
                            daily_maintain_money,daily_maintain_ap}).

%% 门派BOSS的数值配置
%%  *_boss_type:int() BOSS类型ID
%%  *_boss_money:int() 消耗银两
%%  *_boss_ap:int() 消耗的繁荣度(ActivePoint)
%%  *_boss_fc:int() 消耗的贡献度(FamilyContribute)
-record(r_family_boss_config,{level,uplevel_boss_type,uplevel_boss_money,uplevel_boss_ap,uplevel_boss_fc,
                              common_boss_type,common_boss_money,common_boss_ap,common_boss_fc}).


%% 门派种植的数值配置
%%  max_farm_size:int()   级别对应的田地上限
%%  deduct_ap:int()       需要扣除的门派繁荣度
%%  deduct_money:int()    需要扣除的门派资金
-record(r_family_plant_config,{level,max_farm_size,deduct_ap,deduct_money}).


%% 门派种植技能的数值配置
%%  need_role_level:int()   所需的玩家等级
%%  need_proficiency:int()  所需的玩家熟练度
%%  need_silver:int()       所需的银两
%%  need_expr:int()         所需的经验值
%%  family_contribute:int() 所需的门派贡献度
%%  gain_prificiency_quick:int() 种植本等级药物将获得熟练度（快熟）
%%  gain_prificiency_slow:int()  种植本等级药物将获得熟练度（慢熟）
-record(r_plant_skill_config,{level,need_role_level,need_proficiency,need_expr,need_silver,
                                   family_contribute,gain_prificiency_quick,gain_prificiency_slow}).

%% 门派种植农作物种子的数值配置
%%  skill_level:int()       技能等级
%%  seed_type:int()         种子类型，1=快熟；2=慢熟
%%  family_contribute:int() 需要扣除的门派贡献度
%%  fruit_id:int()      收获的果实ID
%%  fruit_count:int()   收获的果实数量
%%  fruit_random:int()   收获的果实概率
-record(r_plant_seeds_config,{id,name,skill_level,seed_type,family_contribute,fruit_id,fruit_count,fruit_rate}).

%% 种植田地的坐标信息
-record(r_plant_farm_config,{farm_id,tx,ty}).


%% NPC兑换的属性定义
%% deal_unique_id:兑换的唯一ID，前端是由deal_id*10000 +  sub_id 组成
%% deal_type: 兑换类型：1=属性兑换 2=物品兑换
%% deduct_item_type: 扣除的物品/积分类型
%% deduct_item_num: 扣除的物品/积分数量
%% award_item_list:  奖励的物品列表
%% award_attr_list:  奖励的积分列表，可以是经验或宗族资金等
%%          [{type,amount},..],奖励配置 type=exp 奖励人物经验 type=family_money 宗族资金
%% limit_deal_maps:限定交易的地图ID列表
%% limit_deal_times:限定交易的最大次数,0表示不限制
-record(r_npc_deal,{deal_unique_id,deal_type,deduct_item_type,deduct_item_num=0,award_item_list=[],award_attr_list=[],limit_deal_maps=[],limit_deal_times=0}).

%% 简单的道具信息
-record(r_simple_prop, {prop_id,prop_type,prop_num=1,bind=true,quality=0,color=0}).


%% 日常任务、日常福利的配置项
-record(r_activity_today, {id,order_id,types=1,name,delay_days,need_level,need_family,total_times,add_ap}).

%%  id 活动的唯一ID
%%  exp_plus 经验加成的基数
%%  exp_mult 经验乘法的基数
-record(r_activity_base_reward, {id,exp_mult,exp_plus}).

%% id 活动的唯一ID
%% type 类型 1 广播 2 出生怪物 3 大明宝藏胜利方出生怪物
%% config_key 怪物KEY（对应配置dynamic_monster.config）
-record(r_activity_dynamic_monster, {id, type, config_key}).

%%  count 任务数量
%%  reward_item_list 奖励道具的配置列表
-record(r_activity_extra_reward, {count,exp_mult,exp_plus,reward_item_list}).
%%  奖励道具的配置项
-record(r_item_reward, {type,item_type_id,item_num,is_bind}).


%% 今日活动对应的任务属性
-record(r_activity_mission,{id,big_group,mission_id_list}).

%% 激活码的配置属性
%%      publish_id:int() 发放激活码的唯一ID，建议是发放类型+发放批次构成
%%      gift_id:int() 礼包ID
%%      gift_num:int() 礼包数目
%%      begin_time:int() 领取的限定开始时间戳，0表示没有限制
%%      end_time:int() 领取的限定结束时间戳，0表示没有限制
-record(r_activate_code_info,{publish_id,gift_id,gift_num,begin_time=0,end_time=0}).



%% 连续登录奖励的配置
%% id:唯一标识
%% min_level:int() 角色最小等级
%% max_level:int()
%% begin_day:int() 角色最少连续登陆天数天数
%% end_day:int()
%% num:int() 道具数量
%% type:int() 道具类型 1:道具 ..
%% type_id:int() 道具id  如 10800020
%% bind:bool() 道具是否绑定
%% silver:int() 需要付费银两数 
%% gold:int() 需要付费元宝数
%% need_payed:bool() 是否需要充值的条件
%% loop_day:int() 循环间隔天数
%% need_vip_level:int() 需要的vip等级
-record(r_conlogin_reward, {id, min_level, max_level, begin_day, end_day, num, type, type_id, bind, silver, gold, need_payed, loop_day, need_vip_level}).

%% 活动面板中的活跃度奖励的配置
%% actpoint:int()   需要活跃度
%% exp_plus:int()   经验奖励的加法基数
%% exp_mult:int()   经验奖励的乘法基数
%% reward_item_list :  [ {type,item_type_id,item_amount,is_bind} ]，奖励的（道具）物品列表,type=1表示道具，type=2表示宝石，type=3表示装备
%%                          is_bind: bool() 奖励的道具是否绑定
-record(r_activity_actpoint_reward, {actpoint,exp_plus,exp_mult,reward_item_list}).

%% 可获得活跃度的活动列表
%% id:int() 活动ID
%% name:binary() 活动名称,例如个人拉镖
%% max_ap:int() 最高可获得的活跃度
-record(r_activity_actpoint_item, {id,name,max_ap}).

%% 坐骑级别和速度加成的配置
%% level:int() 级别
%% speed:int() 速度加成
-record(r_mount_level, {level,speed}).

%% 坐骑刷新的权重配置
%% level:int() 级别
%% weight:int() 权重
%% increment:int() 每次刷新后的权重增量
-record(r_mount_color_weight, {level,weight,increment}).

%% 门派仓库的配置
%% bag_id:int() 背包ID
%% need_family_money:int() 需要扣除的门派资金
-record(r_family_depot_config, {bag_id,need_family_money}).
 

%% 镖车的扩展信息
%% buff_timer_list: list() buff计时器信息的列表,是r_buff_timer_info的列表
-record(r_map_ybc_ext, {buff_timer_list}).

%% buff的计时器信息
-record(r_buff_timer_info, {timer_ref,time,buff_type,msg}).

%% item_effect方法的默认返回值类型
%% item_info:#p_goods()
%% role_base:#p_role_base()
%% role_attr:#p_role_attr()
%% msg_list:list() 可以是fun列表，也可以是msg列表
%% prompt_list:list()
-record(r_item_effect_result, {item_info,role_base,role_attr,msg_list=[],prompt_list=[]}).


%% 玩家数据从分线发送地图时用的record
%% base -> p_role_base
%% attr -> p_role_attr
%% conlogin -> r_role_conlgin 连续登录信息
%% bag -> 玩家背包信息
%% role_map_info -> p_map_role
%% accumulate_info -> r_role_accumulate 角色累积经验信息
%% mission_cache -> 任务缓存 tuple
%% mission_doing -> 正在做的任务列表 list
%% mission_counter -> 计数器 tuple
%% mission_listener --> 任务侦听器 list
%% mission_tutorial --> 新手任务 tuple
%% refining_box_info 玩家Refining Box记录
%% achievement_info 玩家成就记录
%% skill_list 技能列表
%% role_fight 战斗
-record(r_role_full_info, {role_id, base, attr, pos, conlogin, bag, role_map_info, accumulate_info, 
                           vip_info, mission_data, pet_grow_info, hero_fb_info, role_monster_drop,
                           refining_box_info, goal_info, achievement_info,team_info,map_ext_info,
                           skill_list,role_fight}).
-record(r_role_map_detail, {base,attr,pos,conlogin,accumulate_info,vip_info,hero_fb_info,
                            role_monster_drop,refining_box_info, goal_info, achievement_info,
                            team_info,map_ext_info,skill_list,role_fight}).

%% 记录玩家任务日志的record
%% total:integer    任务的请求总次数
-record(r_mission_log,{role_id,mission_id,mission_type,status,total,mtime}).

%% 任务hook record定义
%% mission_id 任务id 
%% mission_type 任务类型 主线和支线 1主线,2支线,3循环
%% big_group 任务大组
%% small_group 任务小组
%% do_type 执行类型 0正常 1委托(自动任务)
%% do_times 执行次数
-record(r_mission_hook,{role_id,mission_id,mission_type,big_group = 0,small_group = 0,do_type = 0,do_times = 1}).

%%任务进程字典record
-record(mission_data, {
    last_store_time=0,%%上次存储的时间 上线时会被置为上线时间 以避免大量玩家同时间持久化数据
    data_version=0,%%数据版本号
    mission_list=[],%%正在做的任务+可接任务列表 #p_mission_info{}
    tutorial_list=[],%%新手任务列表 
    listener_list=[],%%侦听器列表 #mission_listener_trigger_data{}
    counter_list=[],%%统计列表 #mission_counter{}
    auto_list=[],%%委托任务列表 #r_role_mission_auto{}
    extend_list=[]
}).

%% 循环广播的record
%% circle_type:int()   1=每天的固定时间
%% msg_type:int()   1=世界广播
%% msg_range:int()  1=世界
%% msg:binary() 广播的消息内容
-record(r_bc_msg,{id,circle_type,msg_range,msg_type,start_time,msg}).

%% 日常福利统计日志的record
%% reward_date:int()   领奖日期
%% reward_time:int()   领奖时间
%% task_num:int()      总共的任务数
-record(r_act_benefit_log,{role_id,reward_date,reward_time,task_num,buy_num}).

%% 玩家升级日志的record
%% role_id:int()   玩家ID
%% faction_id:int()  国家ID
%% level:int()      级别
%% log_time:int()   日志时间
-record(r_role_level_log,{role_id,faction_id,level,log_time}).


%% 连续登录奖励领取日志
-record(r_conlogin_log, {role_id, level=0, days=0, type_id=0, bind=0, type=0, num=0, gold=0, gold_bind=0, silver=0, silver_bind=0, dateline=0}).

%% vip开通续费日志
-record(r_vip_pay_log, {role_id, pay_type, pay_time, is_first=0}).
%% 场景大战副本类型
%% type 副本类型 1:鄱阳湖大战
%% fb_name 副本名称
%% fb_map_id 副本地图
%% fb_level 副本级别
%% fb_level_name 副本级别名称
%% min_level 副本进入的最低级别
%% max_level 副本进入的最高级别
%% max_seconds 副本存在的最长时间 单位:秒
%% valid_seconds 副本开始后多久时间内还可以进入
-record(r_sw_fb_mcm,{fb_type, fb_map_id, fb_name, fb_level, fb_level_name,min_level,max_level,max_seconds,valid_seconds,must_team,team_member,born_monster,born_elite,monster_number}).

%% 守边的任务日志
-record(r_shoubian_log, {id, role_id, faction_id, mdate, status=0, success=0, fail=0, total=0}).

%% 刺探的任务日志
-record(r_citan_log, {id, type, role_id, faction_id, mdate, status=0, success=0, fail=0, total=0}).


%% 通过邮件赠送玩家礼品的record
%% mail_key:atom()   邮件的key
%% mail_title:binary()   邮件标题
%% mail_text:binary()    邮件内容
-record(r_present_mail_info,{mail_key,mail_title,mail_text,has_attach=false,item_type=0,item_id=0,item_num=0}).

%% 委托任务的配置
%% id:integer 委托任务的唯一ID
%% name:binary 任务名称
%% mission_id:integer 关联的任务ID
%% faction_id:integer 国家ID
%% loop_times:integer 循环次数
%% total_time:integer 总共持续时间(单位：秒)
%% need_gold:integer 扣除的元宝
%% big_group:integer 循环任务的大组
%% is_broadcast:boolean 接任务后是否需要广播
-record(r_mission_auto_conf,{id,name,mission_id,faction_id,min_level=20,loop_times=0,total_time=0,need_gold=0,big_group=0,is_broadcast=false}).

%% 委托任务在数据库中的配置
%% mission_auto:#p_mission_auto
-record(r_role_mission_auto,{id,mission_auto,deduct_gold=0,deduct_gold_bind=0}).

%% 创建特殊道具记录
%% item_type 道具类型 
%% item_id 道具类型id
%% item_num 道具数量
%% bind 绑定概率 100 绑定 0不绑定 100绑定权值
%% start_time 开始时间 时间截
%% end_time 结束时间 时间截
%% days 创建此道具时 有效期多少天
%% color  颜色 [1,0,0,0,0,0]
%% quality 品质 [1,0,0,0,0]
%% sub_quality 子品质 [1,0,0,0]
%% reinforce 强化 [16,..] 强化配置，十位数表时级别，个位数表进星级 不可以断级配置
%% punch_num 孔数 1,2,3,4,5,6
%% stons 宝石 [typeId,...] 要配置宝石就必须配置孔位
%% add_attr 结构为 [{code,level},...]   此装备玩家重新绑定时就会部分属性消失
%% code 为绑定属性的编码，
%% 1、主属性,2、力量,3、敏捷,4、智力,5、精神,6、体质,7、最大生命值,8、最大法力值,9、生命恢复速度,10、法力恢复速度,11、攻击速度,12、移动速度,
%% level 为绑定属性的级别 1,2,3,4,5,6
-record(r_goods_create_special,{item_type,item_id,item_num,bind,start_time = 0,end_time = 0,days = 0,
                                color = [],quality = [],sub_quality = [],reinforce=[],punch_num,stons =[],add_attr = []}).

%% 道具礼包配置，主要用来赠送装备
%% id 唯一标识
%% category 玩家职业 1战士,2射手,3侠客,4医仙 如果玩家没有职业即默认为1战士处理
%% role_level 玩家级别
%% item_type 道具类型 
%% item_id 道具类型id
%% number 道具数量
%% bind 绑定概率 100 绑定 0不绑定 100绑定权值
%% start_time 开始时间 时间截
%% end_time 结束时间 时间截
%% days 创建此道具时 有效期多少天
%% color  颜色 [1,0,0,0,0,0]
%% quality 品质 [1,0,0,0,0]
%% sub_quality 子品质 [1,0,0,0]
%% reinforce 强化 [16,..] 强化配置，十位数表时级别，个位数表进星级 不可以断级配置
%% punch_num 孔数 1,2,3,4,5,6
%% add_attr 结构为 [{code,level},...]   此装备玩家重新绑定时就会部分属性消失
%% code 为绑定属性的编码，
%% 1、主属性,2、力量,3、敏捷,4、智力,5、精神,6、体质,7、最大生命值,8、最大法力值,9、生命恢复速度,10、法力恢复速度,11、攻击速度,12、移动速度,
%% level 为绑定属性的级别 1,2,3,4,5,6
-record(r_item_gift_base,{id,category,role_level,item_type,item_id,item_number,bind,start_time = 0,end_time = 0,days = 0,
                          color,quality,sub_quality = 1,reinforce,punch_num,add_attr}).
						  
%% 英雄副本关卡信息
%% barrier 关卡序号
%% fight_times: 攻击次数
%% prestige:声望
%% expect_times:期望时间
%% expect_score:期望分数
%% select_count:可翻牌数量
%% poker_count:总牌数
%% poker_reward_list:奖励列表
-record(r_hero_fb_barrier_info, {barrier_id, map_id, next_barrier_id, barrier,fight_times,prestige,expect_times,expect_score,title_code,select_times,poker_count,poker_reward_list=[]}).

%% 任务副本的信息配置
%% fb_id integer() 副本ID
%% map_id integer() 地图ID
%% mission_id_list list() 关联的任务ID列表
%% min_level integer() 最小级别
%% max_level integer() 最大级别
%% relive_type integer() 复活方式。1=免费复活，2=正常复活
%% fb_prop_formula integer() 副本中的装备的给予方式。0=无，1=按照职业类型赠送
%% fb_prop_list integer() 副本中的道具列表。
%% complete_mission_id_list list() 副本中完成的任务id
%% complete_type 完成类型 0=副本中的精英和BOSS怪物死亡,1=完成任务
%% monster_create_type 怪物出生类型 1=正常（重生），4=召唤（不重生）
-record(r_mission_fb_info, {fb_id, map_id, mission_id_list=[], min_level=1, max_level=100, 
                            relive_type=1, fb_prop_formula=0,fb_prop_list=[],complete_mission_id_list=[],
                            complete_type = 0,monster_create_type=4}).


%% 副本中赠送的道具信息
-record(r_fb_prop, {prop_id,prop_type,prop_num,bind=true,color=1,quality=1,sub_quality=1,punch_num=0}).



%% 副本掉落物品统计
%% type_id:int() 物品id
%% map_id:int() 地图id
%% drop_time:date() 获取物品时间
%% fb_type:int() 副本类型
-record(r_fb_drop_thing_log,{type_id,map_id,drop_time,fb_type}).


%% 传奇目标hook record
-record(r_goal_hook_record, {role_id, goal_id}).

%% 组队同步消息记录定义
%% role_id 玩家id
%% level 玩家级别
%% map_id 玩家所在地图信息
%% five_ele_attr 玩家五行属性
%% skin 玩家形象
-record(r_role_team_sync_data,{role_id,level,map_id,map_name,tx,ty,hp,mp,max_hp,max_mp,five_ele_attr = 0,category = 0,skin}).

%% 好友基本信息记录定义
%% min_friendly 最小好友度
%% max_friendly 最大好友度
%% friend_level 好友级别
%% friend_title 好友度称号
%% add_exp 祝福好友经验加成 百分比
%% add_attr 好友组队攻击加成
-record(r_friend_base_info,{min_friendly,max_friendly,friend_level,friend_title,add_exp,add_attr}).

%% 成就配置记录定义
%% 成就事件记录
%% event_id事件id
%% event_type 事件类型 1个人成就 2成就榜成就
%% event_desc事件描述
-record(r_achievement_event,{event_id,event_type = 0,event_desc}).
%% 成就配置记录
%% achieve_id 成就id
%% class_id 成就分类id
%% group_id 成就组id
%% achieve_type 成就类型 0一般成就 1组成就 2 全服成就
%% items 奖励道具配置
%% event事件列表 [r_achievement_event,..]
%% achieve_point 成就点
%% total_progress 成就总进度
%% broadcast_type 广播类型 0不广播 1世界广播 2国家广播 3门派广播 4组队广播
%% pop_type 前端是否弹窗显示 0不弹窗 1弹窗提示
%% is_open 是否开启此成就 0未开启 1开启
%% achieve_title_code 玩家称号编码,0没有称号奖励
-record(r_achievement_config,{achieve_id,class_id = 0,group_id = 0,achieve_type = 0,items = [],event = [],achieve_point = 0,
                              total_progress = 0,broadcast_type = 0,pop_type = 0,is_open = 0,achieve_title_code = 0}).
%% 道具id,item_type道具类型，number道具数
%% TODO 以后必须针对装备进行扩展，如赠送的装备的颜色，品质,绑定概率 100的权值，100表示绑定，0表示不绑定，等
-record(r_achievement_item,{item_id,item_type,number = 0,color=[1,0,0,0,0,0],quality=[1,0,0,0,0],bind = 0}).

%% 成就模块 hook 记录定义
-record(r_achievement_hook,{role_id,event_ids,add_progress = 1}).

%% 成就称号配置
%% code 成就编码
%% title_name 成就称号
%% is_show_in_chat 是否在聊天中显示
%% is_show_in_sence 是否在场景中显示
%% title_color 称号显示的颜色
-record(r_achievement_title,{code,title_name,is_show_in_chat,is_show_in_sence,title_color}).
-record(r_hero_fb_title,{code,title_name,is_show_in_chat,is_show_in_sence,title_color}).

%% 奖励什么的公共结构 copy至r_prestige_exchange_base_item

-record(r_common_item_base_info,{item_type,item_id,item_number,bind = 0,color = 0,quality = 0,sub_quality = 0,reinforce = [],
                                         punch_num = 0,add_attr = []}).

%%  金钱兑换卡的配置
%%  deal_list=[]表示兑换后的列表
-record(r_money,{id,name,deal_list}).

%% 任务赠送道具特殊使用
%% start_time 开始时间 end_time 结束时间 new_type_id 获得的道具id new_number 道具数量
%% total_progress 进度数 progress_desc 读条描述
-record(r_item_special_dict,{role_id = 0,item_id = 0,start_time = 0,end_time = 0,new_type_id = 0,new_number = 0,total_progress = 0,progress_desc}).

