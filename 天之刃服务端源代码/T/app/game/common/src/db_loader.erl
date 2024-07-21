%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc 自动加载和卸载帐号/角色数据接口
%%%
%%% @end
%%% Created :  1 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(db_loader).

-include("common.hrl").
-include("common_server.hrl").

-define(DEF_RAM_TABLE(Type,Rec),
        [ {ram_copies, [node()]},
          {type, Type},
          {record_name, Rec},
          {attributes, record_info(fields, Rec)}
        ]).

-export([
         load_role_table/1,
         load_account_table/1,
         load_login_whole_tables/0,
         load_map_whole_tables/0,
         load_world_whole_tables/0,
         load_line_whole_tables/0,
         load_chat_whole_tables/0,
         init_line_tables/0,
         init_map_tables/0,
         init_login_tables/0,
         init_world_tables/0,
         init_chat_tables/0,
         map_table_defines/0,
         define_table_mapping/0,
         define_table_mapping/1
        ]).

-export([
         load_role_data/2,
         delay_load_tables/0,
         delay_load_tables_with_offline/0
        ]).


%% 延迟加载表，这些数据只在玩家上线时才加载
%% 要求：
%% 1. 类型为set
%% 2. 主键为role_id
delay_load_tables() ->
    [
     ?DB_ROLE_POS,
     ?DB_ROLE_FIGHT,
     ?DB_ROLE_STATE,
     ?DB_SKILL_TIME,
     ?DB_ROLE_EDUCATE,
     ?DB_SYSTEM_CONFIG,
     ?DB_SHORTCUT_BAR,
     ?DB_ROLE_PERSONAL_FB
    ].


%% 有些表在玩家不在线时一样会操作，例如信件表
%% 这种类型的延迟加载表在读取数据时有如下要求：
%% 1. 必须是set类型
%% 2. 主键为role_id
%% 3. 重载dirty_read和read操作，读取不到信息时从p表尝试取一次数据
delay_load_tables_with_offline() ->
    [
     ?DB_ROLE_ATTR, 
     ?DB_ROLE_BASE
    ].
    

%% 载入角色数据
load_role_data(AccountName, RoleID) ->
    ok = gen_server:call({global, db_persistent}, {load_role_data, AccountName, RoleID}, 100000),
    ok.


-spec(define_table_mapping() -> list()).
define_table_mapping()->
    lists:concat([
                  define_table_mapping(login),
                  define_table_mapping(chat),
                  define_table_mapping(map),
                  define_table_mapping(world)
                 ]).
                 
get_ptab_name(Tab)->
    common_tool:list_to_atom(lists:concat([Tab, "_p"])).

-define(TABLE_MAPPING(TabList),[ {get_ptab_name(Tab),Tab}|| Tab<- TabList ]).

define_table_mapping(login)->
    %% login
    ?TABLE_MAPPING(
    [?DB_ROLE_FACTION,
     ?DB_ACCOUNT,
     ?DB_ROLEID_COUNTER,
     ?DB_FCM_DATA,
     ?DB_ROLE_NAME
    ]);
define_table_mapping(chat)->
    %% chat
    ?TABLE_MAPPING(
    [ 
     ?DB_CHAT_CHANNELS,
     ?DB_CHAT_CHANNEL_ROLES,
     ?DB_BAN_CHAT_USER,
     ?DB_CHAT_ROLE_CHANNELS
    ]);
define_table_mapping(map)->
    %% map 
    ?TABLE_MAPPING(
    [ 
     ?DB_MONSTERID_COUNTER,
     ?DB_MONSTER_PERSISTENT_INFO,
     %% --
     ?DB_ROLE_POS,
     ?DB_ROLE_FIGHT,
     ?DB_ROLE_STATE,
     %%载入玩家摊位表
     ?DB_STALL,
     ?DB_STALL_SILVER,
     ?DB_STALL_GOODS,
     ?DB_STALL_GOODS_TMP,
     ?DB_SKILL_TIME,
     
     ?DB_YBC,            
     ?DB_YBC_INDEX,       
     ?DB_YBC_UNIQUE,
     ?DB_YBC_PERSON,
     ?DB_VIE_WORLD_FB_LOG,
     ?DB_MAP_ONLINE,
     ?DB_EQUIP_ONEKEY,
     %%通用的key-value表
     ?DB_EVENT_STATE,
     %%通用统计表
     ?DB_COUNTER,
     %%地图活动时间表
     ?DB_MAP_EVENT_TIMER,
     %%训练营
     ?DB_TRAINING_CAMP,
     %% 商贸活动
     ?DB_ROLE_TRADING,
     %% 门派仓库
     ?DB_FAMILY_DEPOT,
     %%鲜花
     ?DB_ROLE_RECEIVE_FLOWERS,
     ?DB_ROLE_GIVE_FLOWERS,
     ?DB_ROLE_LEVEL_GIFT,
     ?DB_ROLE_TIME_GIFT,
     %% 国战
     ?DB_WAROFFACTION,
     %% 赠品模块
     ?DB_ROLE_PRESENT,
     %% 日常活动/福利模块
     ?DB_ROLE_ACTIVITY_TASK,
     ?DB_ROLE_ACTIVITY_BENEFIT,
     %% 玩家坐骑刷颜色数据
     ?DB_ROLE_MOUNT,
     %%宠物
     ?DB_PET,
     ?DB_SPY,
     ?DB_PET_FEED,
     ?DB_ROLE_PET_BAG,
     ?DB_PET_EGG,
     %% 师门同心副本
     ?DB_EDUCATE_FB,
     %% 个人副本
     ?DB_ROLE_PERSONAL_FB,
     ?DB_PERSONAL_FB,
     %% 场景大战副本
     ?DB_SCENE_WAR_FB,
     %% 玩家礼包表
     ?DB_ROLE_GIFT,
     %%门派采集 玩家奖励信息
     ?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO,

     %% 英雄副本
     ?DB_HERO_FB_RECORD,
     %% 任务副本
     ?DB_ROLE_MISSION_FB,
     ?DB_SHOP_CUXIAO,
     %% 天工炉箱子日志
     ?DB_BOX_GOODS_LOG
    ]);
define_table_mapping(world)->
    %% world 
    ?TABLE_MAPPING(
    [
     ?DB_SHEET_COUNTER,
     ?DB_BANK_SELL,
     ?DB_BANK_BUY,
     ?DB_BROADCAST_MESSAGE,
     ?DB_FAMILY_COUNTER,
     %% ----
     ?DB_ROLE_BASE,    
     ?DB_ROLE_ATTR,    
     ?DB_ROLE_EXT,
     
     ?DB_FAMILY,
     ?DB_FAMILY_EXT,
     ?DB_ROLE_FAMILY_PARTTAKE,
     ?DB_FAMILY_INVITE,
     ?DB_FAMILY_REQUEST,
     ?DB_WAROFKING_HISTORY,
     ?DB_WAROFKING_HISTORY_INDEX,
     ?DB_NORMAL_TITLE,
     ?DB_SPEC_TITLE,
     ?DB_TITLE_COUNTER,
     ?DB_WAROFKING,
     %% 门派技能模块
     ?DB_FAMILY_SKILL_RESEARCH,
     %% 门派的基本资产表
     ?DB_FAMILY_ASSETS,
     %%载入好友表
     ?DB_FRIEND,
     %%玩家信件表
     ?DB_COMMON_LETTER,
     %%钱庄信息表
     ?DB_BANK_SHEETS,
     %%快捷键
     ?DB_SHORTCUT_BAR,
     %%师徒
     ?DB_ROLE_EDUCATE,
     ?DB_SYSTEM_CONFIG,
     %%排行榜
     ?DB_ROLE_LEVEL_RANK,
     ?DB_ROLE_PKPOINT_RANK,
     ?DB_ROLE_WORLD_PKPOINT_RANK,
     ?DB_FAMILY_ACTIVE_RANK,
     ?DB_EQUIP_REFINING_RANK,
     ?DB_EQUIP_REINFORCE_RANK,
     ?DB_EQUIP_STONE_RANK,
     ?DB_ROLE_GONGXUN_RANK,
     ?DB_ROLE_TODAY_GONGXUN_RANK,
     ?DB_ROLE_YESTERDAY_GONGXUN_RANK,
     ?DB_FAMILY_GONGXUN_PERSISTENT_RANK,
     ?DB_ROLE_PET_RANK,
     
     ?DB_PAY_LOG, 
     ?DB_PAY_LOG_INDEX,
     ?DB_FACTION,
     ?DB_WAROFFACTION_RECORD,
     ?DB_WAROFFACTION_COUNTER,
     %%通用的key-value表
     ?DB_EVENT_STATE,
     %% 鲜花排行榜
     ?DB_ROLE_GIVE_FLOWERS_RANK,
     ?DB_ROLE_GIVE_FLOWERS_TODAY_RANK,
     ?DB_ROLE_GIVE_FLOWERS_YESTERDAY_RANK,
     ?DB_ROLE_RECE_FLOWERS_RANK,
     ?DB_ROLE_RECE_FLOWERS_TODAY_RANK,
     ?DB_ROLE_RECE_FLOWERS_YESTERDAY_RANK,
     ?DB_ROLE_GIVE_FLOWERS_LAST_WEEK_RANK,
     ?DB_ROLE_RECE_FLOWERS_LAST_WEEK_RANK,
     ?DB_ROLE_GIVE_FLOWERS_THIS_WEEK_RANK,
     ?DB_ROLE_RECE_FLOWERS_THIS_WEEK_RANK,
     ?DB_MONEY_EVENT,
     ?DB_MONEY_EVENT_COUNTER,
     %% 离线消息
     ?DB_OFFLINE_MSG,
     ?DB_WORLD_COUNTER,
     ?DB_ACTIVITY_REWARD,
     ?DB_FAMILY_DONATE,
     ?DB_ROLE_SQ_FB_INFO,
     ?DB_ROLE_EXE_FB_INFO
    ]).


load_login_whole_tables() ->
    Tables = define_table_mapping(login),
    do_load_tables(Tables),
    [ do_add_tab_index(TabIndex)|| TabIndex <- login_table_indexs() ],
    do_subscribe_tables(Tables,mgeel_sup),
    ok.



load_map_whole_tables() ->
    Tables = define_table_mapping(map),
    do_load_tables(Tables),
    [ do_add_tab_index(TabIndex)|| TabIndex <- map_table_indexs() ],

    %% no subscribe!!! the subscribe must be done after load_map_whole_tables in the 'mgeem_distribution' module
    ok.


load_world_whole_tables() ->
    Tables = define_table_mapping(world),
    do_load_tables(Tables),
    [ do_add_tab_index(TabIndex)|| TabIndex <- world_table_indexs() ],
    do_subscribe_tables(Tables,mgeew_sup).


load_line_whole_tables() ->
    ok.

load_chat_whole_tables() ->
    Tables = define_table_mapping(chat),
    do_load_tables(Tables),
 
    [ do_add_tab_index(TabIndex)|| TabIndex <- chat_table_indexs() ],
    %% subscribe
    do_subscribe_tables(Tables,mgeec_sup).


%%帐号登录后初始化帐号相关表，例如fcm等等
load_account_table(_AccountName) -> 
    ok.

%%帐号登录后需要提前载入帐号下角色的所有相关数据，有些表是在init_whole_table中载入的
load_role_table(_AccountName) -> 
    ok.


init_chat_tables() ->
    lists:foreach(
      fun({Tab, Definition}) ->
              mnesia:create_table(Tab, Definition)
      end,
      chat_table_defines()
     ),
    ok.


init_line_tables() ->
    lists:foreach(
      fun({Tab, Definition}) ->
              mnesia:create_table(Tab, Definition)
      end,
      line_table_defines()
     ),
    ok.


init_map_tables() ->
    lists:foreach(
      fun({Tab, Definition}) ->
              mnesia:create_table(Tab, Definition)
      end,
      map_table_defines()
     ),
    ok.


init_login_tables() ->
    lists:foreach(
      fun({Tab, Definition}) ->
              mnesia:create_table(Tab, Definition)
      end,
      login_table_defines()
     ),
    ok.


init_world_tables() ->
    lists:foreach(
      fun({Tab, Definition}) ->
              mnesia:create_table(Tab, Definition)
      end,
      world_table_defines()
     ),
    ok.


login_table_defines() ->
    [
     {?DB_ROLE_FACTION,
        ?DEF_RAM_TABLE(set,r_role_faction)},
     {?DB_ACCOUNT,
        ?DEF_RAM_TABLE(set,r_account)},
     {?DB_ROLE_NAME,
        ?DEF_RAM_TABLE(set,r_role_name)},
     {?DB_FCM_DATA, 
        ?DEF_RAM_TABLE(set,r_fcm_data)},
     {?DB_ROLEID_COUNTER,
        ?DEF_RAM_TABLE(set,r_roleid_counter)},
     {?DB_BAN_USER,
        ?DEF_RAM_TABLE(set,r_ban_user)},
     {?DB_BAN_IP,
        ?DEF_RAM_TABLE(set,r_ban_ip)}
    ].


map_table_defines() -> 
    [
     {?DB_ROLE_POS, [
                     {attributes, record_info(fields, p_role_pos)},
                     {record_name, p_role_pos},
                     {ram_copies, [node()]}
                    ]},
     {?DB_ROLE_FIGHT, [
                       {attributes, record_info(fields, p_role_fight)},
                       {record_name, p_role_fight},
                       {ram_copies, [node()]}
                      ]},
     {?DB_MONSTER_PERSISTENT_INFO, [
                                    {ram_copies, [node()]}, 
                                    {type, set},                                                                                    
                                    {record_name, r_monster_persistent_info},
                                    {attributes, record_info(fields, r_monster_persistent_info)}
                                   ]},
     {?DB_ROLE_STATE, [
                       {ram_copies, [node()]},
                       {type, set},
                       {record_name, r_role_state},
                       {attributes, record_info(fields, r_role_state)}
                      ]},
     {?DB_STALL, [
                  {ram_copies, [node()]},
                  {type, set},
                  {index, [mapid, mode]},
                  {record_name, r_stall},
                  {attributes, record_info(fields, r_stall)}
                 ]},
     {?DB_STALL_SILVER, [
                         {ram_copies, [node()]},
                         {type, set},
                         {record_name, r_stall_silver},
                         {attributes, record_info(fields, r_stall_silver)}
                        ]},
     {?DB_STALL_GOODS, [
                        {ram_copies, [node()]},
                        {type, set},
                        {record_name, r_stall_goods},
                        {attributes, record_info(fields, r_stall_goods)}
                       ]},
     {?DB_STALL_GOODS_TMP, [
                            {ram_copies, [node()]},
                            {type, set},
                            {record_name, r_stall_goods},
                            {attributes, record_info(fields, r_stall_goods)}
                           ]},
     {?DB_MAP_ONLINE, 
      [ {ram_copies, [node()]},
        {type, set},
        {record_name, r_map_online},
        {attributes, record_info(fields, r_map_online)}
      ]},
     {?DB_MONSTERID_COUNTER, [
                              {attributes, record_info(fields, r_monsterid_counter)},
                              {record_name, r_monsterid_counter},
                              {ram_copies, [node()]}
                             ]},
     {?DB_SKILL_TIME,
      [{record_name, r_skill_time},
       {attributes, record_info(fields, r_skill_time)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_YBC, 
      [{record_name, r_ybc},
       {attributes, record_info(fields, r_ybc)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_YBC_INDEX, 
      [{record_name, r_ybc_index},
       {attributes, record_info(fields, r_ybc_index)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_YBC_UNIQUE, 
      [{record_name, r_ybc_unique},
       {attributes, record_info(fields, r_ybc_unique)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_YBC_PERSON, 
      [{record_name, r_ybc_person},
       {attributes, record_info(fields, r_ybc_person)},
       {ram_copies, [node()]}
      ]
     },

     {?DB_VIE_WORLD_FB_LOG,
        ?DEF_RAM_TABLE(set,r_vie_world_fb_log)},
     {?DB_EQUIP_ONEKEY,
        ?DEF_RAM_TABLE(set,r_equip_onekey)},
     {?DB_EVENT_STATE,
        ?DEF_RAM_TABLE(set,r_event_state)},
     {?DB_MAP_EVENT_TIMER,
        ?DEF_RAM_TABLE(set,r_map_event_timer)},
     {?DB_COUNTER,
        ?DEF_RAM_TABLE(set,r_counter)},

     %% 训练营
     {?DB_TRAINING_CAMP,
        ?DEF_RAM_TABLE(set,r_training_camp)},
     %% 商贸活动
     {?DB_ROLE_TRADING,
        ?DEF_RAM_TABLE(set,r_role_trading)},
     %% 门派仓库
     {?DB_FAMILY_DEPOT,
        ?DEF_RAM_TABLE(set,r_family_depot)},
     %% 鲜花
     {?DB_ROLE_RECEIVE_FLOWERS,
        ?DEF_RAM_TABLE(set,r_receive_flowers)},
     {?DB_ROLE_GIVE_FLOWERS,
        ?DEF_RAM_TABLE(set,r_give_flowers)},
     {?DB_ROLE_LEVEL_GIFT,
        ?DEF_RAM_TABLE(set,r_role_level_gift)},
	 {?DB_ROLE_TIME_GIFT,
        ?DEF_RAM_TABLE(set,r_role_time_gift)},
     %% 玩家活动状态表
     {?DB_ROLE_ACTIVITY,
        ?DEF_RAM_TABLE(set,r_role_activity)},
     {?DB_WAROFFACTION,
        ?DEF_RAM_TABLE(set, r_waroffaction)},
     {?DB_PET,
        ?DEF_RAM_TABLE(set, p_pet)},
     {?DB_PET_FEED,
        ?DEF_RAM_TABLE(set, p_pet_feed)}, 
     {?DB_ROLE_PET_BAG,
        ?DEF_RAM_TABLE(set, p_role_pet_bag)},
     {?DB_PET_EGG,
        ?DEF_RAM_TABLE(set, p_role_pet_egg_type_list)},
     {?DB_SPY,
        ?DEF_RAM_TABLE(set, r_spy)},
     %% 赠品模块
     {?DB_ROLE_PRESENT,
        ?DEF_RAM_TABLE(set,r_role_present)},
     %% 日常活动/福利模块
     {?DB_ROLE_ACTIVITY_TASK,
        ?DEF_RAM_TABLE(set,r_role_activity_task)},
     {?DB_ROLE_ACTIVITY_BENEFIT,
        ?DEF_RAM_TABLE(set,r_role_activity_benefit)},
     %% 玩家坐骑刷颜色数据
     {?DB_ROLE_MOUNT,
        ?DEF_RAM_TABLE(set,r_role_mount)},
     %% 师门同心副本
     {?DB_EDUCATE_FB,
        ?DEF_RAM_TABLE(set,r_educate_fb)},
     %% 个人副本
     {?DB_ROLE_PERSONAL_FB,
        ?DEF_RAM_TABLE(set, r_role_personal_fb)},
     {?DB_PERSONAL_FB,
        ?DEF_RAM_TABLE(set, r_personal_fb)},
     %% 场景大战副本
     {?DB_SCENE_WAR_FB,
        ?DEF_RAM_TABLE(set, r_scene_war_fb)},
     %% 礼包表
     {?DB_ROLE_GIFT,?DEF_RAM_TABLE(set, r_role_gift)},
     {?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO,?DEF_RAM_TABLE(set, p_family_collect_role_prize_info)},

     %% 英雄副本
     {?DB_HERO_FB_RECORD, ?DEF_RAM_TABLE(set, r_hero_fb_record)},
     %% 任务副本
     {?DB_ROLE_MISSION_FB, ?DEF_RAM_TABLE(set, r_role_mission_fb)},
     {?DB_SHOP_CUXIAO, ?DEF_RAM_TABLE(set, p_shop_cuxiao_item)},
     %% 天工炉箱子日志表
     {?DB_BOX_GOODS_LOG, ?DEF_RAM_TABLE(set, r_box_goods_log)}
    ].


world_table_defines() ->
    [
     {?DB_ROLE_ATTR, [
                      {attributes, record_info(fields, p_role_attr)},
                      {record_name, p_role_attr},
                      {ram_copies, [node()]}
                     ]},
     {?DB_ROLE_BASE, [
                      {attributes, record_info(fields, p_role_base)},
                      {record_name, p_role_base},
                      {ram_copies, [node()]}
                     ]},
     {?DB_ROLE_EXT, [
                     {attributes, record_info(fields, p_role_ext)},
                     {record_name, p_role_ext},
                     {ram_copies, [node()]}
                    ]},
     {?DB_FRIEND, 
      [ {ram_copies, [node()]},
        {type, bag }, 
        {record_name, r_friend}, 
        {attributes, record_info(fields, r_friend)} ]}, 

     {?DB_FRIEND_REQUEST, 
      [ {ram_copies, [node()]},
        {type, bag }, 
        {record_name, r_friend_request}, 
        {attributes, record_info(fields, r_friend_request)} ]},
     {?DB_FAMILY_NAME,
      ?DEF_RAM_TABLE(set,r_family_name)},

     {?DB_BANK_SHEETS,
      [ {ram_copies, [node()]}, 
        {type, set},
        {record_name, p_bank_sheet}, 
        {attributes, record_info(fields, p_bank_sheet)} ]},

     %%this table will not persitent to the disk_copies
     {?DB_USER_ONLINE,
      [ {ram_copies, [node()]}, 
        {type, set},
        {record_name, r_role_online}, 
        {attributes, record_info(fields, r_role_online)} ]},

     {?DB_BANK_SELL,
      [ {ram_copies, [node()]}, 
        {type, ordered_set},
        {record_name, r_bank_sell}, 
        {attributes, record_info(fields, r_bank_sell)} ]}, 

     {?DB_BANK_BUY,
      [ {ram_copies, [node()]}, 
        {type, ordered_set},
        {record_name, r_bank_buy}, 
        {attributes, record_info(fields, r_bank_buy)} ]},

     {?DB_SHEET_COUNTER,
      [ {ram_copies, [node()]}, 
        {type, set},
        {record_name, r_sheet_counter}, 
        {attributes, record_info(fields, r_sheet_counter)} ]},
     {?DB_SHORTCUT_BAR,
      [ {ram_copies, [node()]}, 
        {type, set},
        {record_name, r_shortcut_bar}, 
        {attributes, record_info(fields, r_shortcut_bar)} ]},
     {?DB_BROADCAST_MESSAGE,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, r_broadcast_message}, 
       {attributes, record_info(fields, r_broadcast_message)}]},
     %%门派相关表
     {?DB_FAMILY,
        ?DEF_RAM_TABLE(set,p_family_info)},
     {?DB_FAMILY_EXT,
        ?DEF_RAM_TABLE(set,r_family_ext)},
     {?DB_FAMILY_COUNTER,
        ?DEF_RAM_TABLE(set,r_family_counter)},
     {?DB_FAMILY_INVITE,
        ?DEF_RAM_TABLE(bag,p_family_invite_info)},
     {?DB_FAMILY_REQUEST,
        ?DEF_RAM_TABLE(bag,p_family_request_info)},

     %% 门派技能模块
     {?DB_FAMILY_SKILL_RESEARCH,
        ?DEF_RAM_TABLE(set,r_family_skill_research)},
     %% 门派的资产表
     {?DB_FAMILY_ASSETS,
        ?DEF_RAM_TABLE(set,r_family_assets)},
     %% 玩家参与门派活动的记录
     {?DB_ROLE_FAMILY_PARTTAKE,
        ?DEF_RAM_TABLE(set,r_role_family_parttake)},
     %%师徒
     {?DB_ROLE_EDUCATE,
        ?DEF_RAM_TABLE(set,r_educate_role_info)},
     {?DB_SYSTEM_CONFIG,
        ?DEF_RAM_TABLE(set,r_sys_config)},
     {?DB_ROLE_LEVEL_RANK,
        ?DEF_RAM_TABLE(set,p_role_level_rank)},
     {?DB_ROLE_PKPOINT_RANK,
        ?DEF_RAM_TABLE(set,p_role_pkpoint_rank)},
     {?DB_ROLE_WORLD_PKPOINT_RANK,
        ?DEF_RAM_TABLE(set,p_role_pkpoint_rank)},

     {?DB_FAMILY_ACTIVE_RANK, 
      [{record_name, p_family_active_rank},
       {attributes, record_info(fields, p_family_active_rank)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_EQUIP_REFINING_RANK, 
      [{record_name, p_equip_rank},
       {attributes, record_info(fields, p_equip_rank)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_EQUIP_REINFORCE_RANK, 
      [{record_name, p_equip_rank},
       {attributes, record_info(fields, p_equip_rank)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_EQUIP_STONE_RANK, 
      [{record_name, p_equip_rank},
       {attributes, record_info(fields, p_equip_rank)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_FAMILY_GONGXUN_PERSISTENT_RANK,
      [{record_name, p_family_gongxun_persistent_rank},
       {attributes, record_info(fields, p_family_gongxun_persistent_rank)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_ROLE_GONGXUN_RANK, 
      [{record_name, p_role_gongxun_rank},
       {attributes, record_info(fields, p_role_gongxun_rank)},
       {ram_copies, [node()]}
      ]
     },
      {?DB_ROLE_TODAY_GONGXUN_RANK, 
      [{record_name, p_role_gongxun_rank},
       {attributes, record_info(fields, p_role_gongxun_rank)},
       {ram_copies, [node()]}
      ]
     },
      {?DB_ROLE_YESTERDAY_GONGXUN_RANK, 
      [{record_name, p_role_gongxun_rank},
       {attributes, record_info(fields, p_role_gongxun_rank)},
       {ram_copies, [node()]}
      ]
     },
      {?DB_ROLE_PET_RANK, 
      [{record_name, p_role_pet_rank},
       {attributes, record_info(fields, p_role_pet_rank)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_NORMAL_TITLE,
      [{record_name, p_title},
       {attributes, record_info(fields, p_title)},
       {ram_copies, [node()]}
      ]
     },
     {?DB_SPEC_TITLE,
      [{record_name, p_title},
       {attributes, record_info(fields, p_title)},
       {ram_copies, [node()]}
      ]
     },
     {
       ?DB_TITLE_COUNTER,
       [{record_name, r_title_counter},
        {attributes, record_info(fields, r_title_counter)},
        {ram_copies, [node()]}]
     },
     {?DB_WAROFKING_HISTORY, 
      [
       {ram_copies, [node()]},
       {type, set},
       {record_name, r_warofking_history},
       {attributes, record_info(fields, r_warofking_history)}
      ]},
     {?DB_WAROFKING_HISTORY_INDEX, 
      [
       {ram_copies, [node()]},
       {type, set},
       {record_name, r_warofking_history_index},
       {attributes, record_info(fields, r_warofking_history_index)}
      ]},
     {?DB_PAY_LOG, 
      [
       {ram_copies, [node()]},
       {type, set},
       {record_name, r_pay_log},
       {attributes, record_info(fields, r_pay_log)}
      ]},
     {?DB_PAY_LOG_INDEX, 
      [
       {ram_copies, [node()]},
       {type, set},
       {record_name, r_pay_log_index},
       {attributes, record_info(fields, r_pay_log_index)}
      ]},
     {?DB_FACTION,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_faction},
       {attributes, record_info(fields, p_faction)}
      ]
     },
    {?DB_WAROFFACTION_RECORD,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_waroffaction_record},
       {attributes, record_info(fields, p_waroffaction_record)}
      ]
     },  
    {?DB_WAROFFACTION_COUNTER,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, r_waroffaction_counter},
       {attributes, record_info(fields, r_waroffaction_counter)}
      ]
     },
     {?DB_WAROFKING,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, db_warofking},
       {attributes, record_info(fields, db_warofking)}
      ]
      },
     {?DB_EVENT_STATE,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, r_event_state},
       {attributes, record_info(fields, r_event_state)}
      ]},

     {?DB_ROLE_GIVE_FLOWERS_RANK,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_role_give_flowers_rank},
       {attributes, record_info(fields, p_role_give_flowers_rank)}
      ]},
     {?DB_ROLE_GIVE_FLOWERS_TODAY_RANK,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_role_give_flowers_today_rank},
       {attributes, record_info(fields, p_role_give_flowers_today_rank)}
      ]},
     {?DB_ROLE_GIVE_FLOWERS_YESTERDAY_RANK,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_role_give_flowers_yesterday_rank},
       {attributes, record_info(fields, p_role_give_flowers_yesterday_rank)}
      ]},
      {?DB_ROLE_GIVE_FLOWERS_LAST_WEEK_RANK,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_role_give_flowers_last_week_rank},
       {attributes, record_info(fields, p_role_give_flowers_last_week_rank)}
      ]},
       {?DB_ROLE_GIVE_FLOWERS_THIS_WEEK_RANK,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_role_give_flowers_this_week_rank},
       {attributes, record_info(fields, p_role_give_flowers_this_week_rank)}
      ]},
     {?DB_ROLE_RECE_FLOWERS_RANK,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_role_rece_flowers_rank},
       {attributes, record_info(fields, p_role_rece_flowers_rank)}
      ]},
     {?DB_ROLE_RECE_FLOWERS_TODAY_RANK,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_role_rece_flowers_today_rank},
       {attributes, record_info(fields, p_role_rece_flowers_today_rank)}
      ]},
     {?DB_ROLE_RECE_FLOWERS_YESTERDAY_RANK,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_role_rece_flowers_yesterday_rank}, 
       {attributes, record_info(fields, p_role_rece_flowers_yesterday_rank)}
      ]},
     {?DB_ROLE_RECE_FLOWERS_LAST_WEEK_RANK,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_role_rece_flowers_last_week_rank}, 
       {attributes, record_info(fields, p_role_rece_flowers_last_week_rank)}
      ]},
     {?DB_ROLE_RECE_FLOWERS_THIS_WEEK_RANK,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, p_role_rece_flowers_this_week_rank}, 
       {attributes, record_info(fields, p_role_rece_flowers_this_week_rank)}
      ]},
     {?DB_MONEY_EVENT,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, r_money_event},
       {attributes, record_info(fields, r_money_event)}
      ]},
     {?DB_MONEY_EVENT_COUNTER,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, r_money_event_counter},
       {attributes, record_info(fields, r_money_event_counter)}
      ]},
     {?DB_USER_EVENT_COUNTER,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, r_user_event_counter},
       {attributes, record_info(fields, r_user_event_counter)}
      ]},
     {?DB_USER_EVENT,
      [{ram_copies, [node()]},
       {type, set},
       {record_name, r_user_event},
       {attributes, record_info(fields, r_user_event)}
      ]},
     %% 玩家活动状态表
     {?DB_ROLE_ACTIVITY,
      ?DEF_RAM_TABLE(set,r_role_activity)},
	 %% 离线消息
	 {?DB_OFFLINE_MSG,
	  	?DEF_RAM_TABLE(set,r_offline_msg)},
     {?DB_WORLD_COUNTER,
        ?DEF_RAM_TABLE(set,r_world_counter)},
     {?DB_COMMON_LETTER,
        ?DEF_RAM_TABLE(set,r_common_letter)},
     {?DB_ACTIVITY_REWARD,
        ?DEF_RAM_TABLE(set,r_activity_reward)},
     {?DB_FAMILY_DONATE,
        ?DEF_RAM_TABLE(set,r_family_donate)},
     {?DB_ROLE_SQ_FB_INFO,
        ?DEF_RAM_TABLE(set,r_role_sq_fb_info)},
     {?DB_ROLE_EXE_FB_INFO,
        ?DEF_RAM_TABLE(set,r_role_exe_fb_info)}
    ].

line_table_defines() ->
    [].

chat_table_defines() ->
    [
     {?DB_CHAT_CHANNEL_ROLES, 
      [ {ram_copies, [node()]},
        {type, bag},
        {record_name, p_chat_channel_role_info},
        {attributes, record_info(fields, p_chat_channel_role_info)}
      ]},
     {?DB_CHAT_ROLE_CHANNELS, 
      [ {ram_copies, [node()]},
        {type, bag},
        {record_name, r_chat_role_channel_info},
        {attributes, record_info(fields, r_chat_role_channel_info)}
      ]},
     {?DB_CHAT_CHANNELS, 
      [ {ram_copies, [node()]},
        {type, set},
        {record_name, p_channel_info},
        {attributes, record_info(fields, p_channel_info)}
      ]},
     {?DB_BAN_CHAT_USER, 
      [ {ram_copies, [node()]},
        {type, set},
        {record_name, r_ban_chat_user},
        {attributes, record_info(fields, r_ban_chat_user)}
      ]}
    ].


%% @spec do_add_tab_index/1
%% @doc 对mnesia的内存表增加索引
do_add_tab_index(TabIndexDefine)->
    {Tab, [{index, IndexList} ]} = TabIndexDefine,
    [ db:add_table_index(Tab, AttrName) ||AttrName <- IndexList  ].

login_table_indexs() ->
    [].

map_table_indexs() ->
    [
     {?DB_STALL_GOODS,
      [{index, [role_id]} ]},
     {?DB_STALL_GOODS_TMP,
      [{index, [role_id]} ]},
     {?DB_YBC_PERSON,
      [ {index, [role_id]} ]}
    ].


world_table_indexs() ->
    [
     {?DB_STALL,
      [ {index, [mapid, mode]} ]},

     {?DB_ROLE_BASE,
      [ {index, [role_name, account_name, family_id]} ]},

     {?DB_BANK_SHEETS,
      [ {index, [roleid]}
      ]},
     {?DB_BROADCAST_MESSAGE,
      [ {index, [msg_type,expected_time,send_flag]}
      ]},
     %%私人信件表
     {?DB_PERSONAL_LETTER_P,
      [ {index, [sender_id,receiver_id]}]}
    ].

chat_table_indexs() ->
    [].




do_subscribe_tables(Tables,Sup)->
    lists:foreach(
      fun({Tab_Disk,Tab_Ram}) ->
              db_subscriber:start( Sup,Tab_Ram,Tab_Disk )
      end, Tables).

do_load_tables(Tables)->
    lists:foreach(
      fun({Tab_Disk,Tab_Ram}) ->
              case lists:member(Tab_Ram, db_loader:delay_load_tables()) 
                  orelse lists:member(Tab_Ram, db_loader:delay_load_tables_with_offline()) 
              of
                  true->
                      ignore;
                  _ ->
                      statistics(wall_clock),
                      statistics(runtime),
                      db:load_whole_table(Tab_Disk,Tab_Ram),
                      {_, Time1} = statistics(wall_clock),
                      {_, Time2} = statistics(runtime),
                      ?ERROR_MSG("~ts:~p ~ts wall_clock: ~p, runtime:~p", ["加载表", Tab_Ram, "耗时 -> ", Time1, Time2])
              end
      end, Tables).
