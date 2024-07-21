-define(TYPE_BORN_NOTICE, 1).
-define(TYPE_BORN_MONSTER, 2).
-define(ACTIVITY_LIST, activity_list).
-define(ACTIVITY_CONFIG_KEY, dynamic_monster).
-define(BOSS_GROUP_LIST, boss_group_list).
-define(BOSS_GROUP_VIEW_LIST,boss_group_view_list).
-define(BOSS_GROUP_NEXT_REFLASH_TIME,boss_group_next_reflash_time).
-define(DYNAMIC_MONSTER_KEY,100018).
-define(BOSS_GROUP_CONFIG_CREATE_TIME,{5,0,0}).
%%监狱id 都给这个地图执行

%%%%%% 动态boss群配置
%% id:唯一id
%% is_open:开关
%% type:类型 1:每日，2:每周  3:临时(暂时不做，活动用)
%% start_day: 整个活动的起始日期 {{open_day,xx}}:开服时间   {{xx,xx,xx}} 固定时间
%% end_day:整个活动的结束日期  {{open_day,xx}}:依据开服时间 {{xx,xx,xx}}:固定时间
%% start_time: 起始时间        {xx,xx,xx}
%% end_time: 结束时间          {xx,xx,xx}
%% last_time:活动持续时间   整数秒
%% space_time:间隔时间      整数秒
-record(r_boss_group,{id,is_open,type,week_day,start_day,start_time,end_day,end_time,last_time,space_time,dynamic_monster_list}).

-define(ACTIVITY_TYPE_EVERY_DAY,1).
-define(ACTIIVTY_TYPE_EVERY_WEEK,2).

-define(BOSS_GROUP_GET_LIST,1).
-define(BOSS_GROUP_GET_DETAIL,2).
-define(BOSS_GROUP_TRANSFER,3).