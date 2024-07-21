%% 天之刃 活动模块宏定义 文件




%% 活动四： 极速讨伐，成就佳话
%% complete_seconds 完成时间单们秒 
%% vwf_time_desc 活动时间描述
%% item_id 道具id
%% item_bind 是否绑定 true or false
%% item_number 道具数量 
%% item_type 道具类型 1,2,3
-record(r_role_activity_vwf,{vwf_time_desc = "",complete_seconds = 0,item_type = 0,item_id = 0, item_bind = true,item_number = 0}).



%% 通用的活动奖励配置
%% award_item_id 奖励道具
%% award_count 奖励的道具数量
%% award_rate 奖励的概率,例如40表示有百分之四十的机会获得
%% bind_type 绑定类型：true表示绑定；false表示不绑定
-record(r_activity_common_award,{award_item_id,award_num,award_rate,bind_type}).


%% 怪物掉落的活动奖励配置
%% monster_list 怪物ID列表
%% award_item_id 奖励道具
%% award_count 奖励的道具数量
%% award_rate 奖励的概率,例如40表示有百分之四十的机会获得
%% bind_type 绑定类型：true表示绑定；false表示不绑定
-record(r_activity_monster_award_one,{monster_list=[],award_item_id,award_num,award_rate,bind_type}).

%% 怪物掉落的活动奖励配置，可以掉落多种
%% monster_list 怪物ID列表
%% award_prop_list 奖励的道具列表 [#r_award_prop{}]
%% award_rate 奖励的概率,例如40表示有百分之四十的机会获得
%% award_type 奖励方式，1=随机取一个；2=给予全部道具
-record(r_activity_monster_award_multi,{monster_list=[],award_prop_list,award_rate,award_type}).

-record(r_award_prop,{item_id,num,bind,weight}).

%% 个人拉镖
%% start_time 活动具体时间 时分秒
%% end_time 结束具体时间 时分秒
%% award_expr_times     奖励经验倍数
%% award_silver_times     奖励非绑银倍数
%% award_silver_bind_times     奖励绑银倍数
-record(r_activity_person_ybc_award,{start_time,end_time,award_expr_times=1,award_silver_times=1,award_silver_bind_times=1,
                                     award_prop_list=[]}).

%% 齐聚门派贺新年的活动配置
%% monster_list 怪物ID列表
%% call_cmm_boss_count  召唤BOSS次数
%% award_expr_times     奖励经验倍数
-record(r_activity_family_award,{monster_list=[],call_cmm_boss_count=1,award_expr_times=1}).

%% 打怪经验奖励，暂时只支持所有怪物
%% award_exp_times 奖励经验倍数
%% award_exp_last_hour 奖励经验的持续多少小时
-record(r_activity_monster_exp_award, {award_exp_times=1,award_exp_last_hour=0}).


