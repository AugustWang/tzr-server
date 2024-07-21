%% 逐鹿天下副本HRL文件


%% 逐鹿天下副本配置文件表
-define(ETS_VIE_WORLD_FB_CONFIG,ets_vie_world_fb_config).

%% 是否已经初始化逐鹿天下副本ServerNPC数据
-define(VIE_WORLD_FB_STATUS_INIT,1).
-define(VIE_WORLD_FB_STATUS_RUNNING,2).


%% 逐鹿天下副本怪物配置ETS表
-define(ETS_VIE_WORLD_FB_MONSTER,ets_vie_world_fb_monster).
%% id monster_id 怪物id monster_level 怪物级别 type怪物类型 1普通怪物，2精英怪，3Boss怪
%% bron_list 怪物出生点列表[r_vwf_monster_bron]
-record(r_vwf_monster,{monster_id,level,type,bron_list}).
%% 怪物出生点记录
-record(r_vwf_monster_bron,{tx,ty}).

%% 最小级别，最大级别，权重值
-record(r_vwf_role_level_weight,{min_level,max_level,weight}).

%% 逐鹿天下玩家信息记录
-record(r_vwf_role_info,{role_id,role_name,account_name,level,faction_id,family_id,team_id,map_id,pos}).

%% 讨伐敌营副本入口地图的出生点配置
-record(r_vwf_enter_map_bron,{map_id,tx,ty,map_name}).
