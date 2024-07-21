%%%----------------------------------------------------------------------
%%% File    : mgeed_mnesia.erl
%%% Author  : Qingliang
%%% Created : 2010-01-02
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------


-module(mgeed_mnesia).

-include("mgeed.hrl").

-export([
         init/0,
         init_db/0,
         master_init_once/0,
         cluster_init_once/0,
         table_defines/0
        ]).

-define(DEF_DISK_TABLE(Type,Rec),
        [{disc_copies, [node()]},
         {type, Type},
         {record_name, Rec},
         {attributes, record_info(fields, Rec)}
        ]).


init() ->
    do_init(),
    prepare(),
    wait_for_tables(),
    mod_mnesia_init:init(),
    ok.
                      


do_init() ->
    case mnesia:system_info(extra_db_nodes) of
        [] ->
            mnesia:create_schema([node()]);
        _ ->
            ok
    end,
    application:start(mnesia, permanent),
    mnesia:change_table_copy_type(schema, node(), disc_copies).


master_init_once() ->
    case mnesia:system_info(is_running) of
	no ->
            ok;
	yes ->
            mnesia:stop()
    end,
    mnesia:create_schema([node()]).

cluster_init_once() ->
    case mnesia:system_info(is_running) of
	no ->
            ok;
	yes ->
            mnesia:stop()
    end,
    mnesia:delete_schema([node()]).


prepare() ->
    case mnesia:system_info(is_running) of
        yes -> 
            ok;
        no -> 
            throw({error, mnesia_not_running})
    end,
    MnesiaDir = dir() ++ "/",
    case filelib:ensure_dir(MnesiaDir) of
        {error, Reason} ->
            throw({error, {cannot_create_mnesia_dir, MnesiaDir, Reason}});
        ok -> 
            ok
    end.


dir() -> 
    mnesia:system_info(directory).


init_db() ->
    lists:foreach(
      fun({Tab, Definition}) ->
              A = mnesia:create_table(Tab, Definition),
              ?DEBUG("create table ~p : ~p" , [Tab, A])
      end,
      table_defines()
     ).


wait_for_tables() ->
    init_db(),
    %%[mnesia:force_load_table(Tab) || Tab <- mnesia:system_info(local_tables)].
    mnesia:wait_for_tables(mnesia:system_info(local_tables), infinity),
    ok.


table_defines() ->
    [
     {?DB_ROLE_FACTION_P,
      [
       {attributes, record_info(fields, r_role_faction)},
       {record_name, r_role_faction},
       {disc_copies, [node()]}
      ]},
     {?DB_ACCOUNT_P, [
                    {attributes, record_info(fields, r_account)},
                    {record_name, r_account},
                    {disc_copies, [node()]}
                   ]},
     {?DB_ROLE_ATTR_P, [
                      {attributes, record_info(fields, p_role_attr)},
                      {record_name, p_role_attr},
                      {disc_copies, [node()]}
                     ]},
     {?DB_ROLE_BASE_P, [
                      {attributes, record_info(fields, p_role_base)},
                      {record_name, p_role_base},
                      {index, [role_name, account_name]},
                      {disc_copies, [node()]}
                     ]},
     {?DB_ROLE_NAME_P,
      ?DEF_DISK_TABLE(set,r_role_name)},
     {?DB_ROLE_FIGHT_P, [
                       {attributes, record_info(fields, p_role_fight)},
                       {record_name, p_role_fight},
                       {disc_copies, [node()]}
                      ]},
     {?DB_ROLE_POS_P, [
                     {attributes, record_info(fields, p_role_pos)},
                     {record_name, p_role_pos},
                     {disc_copies, [node()]}
                    ]},
     {?DB_ROLE_EXT_P, [
                     {attributes, record_info(fields, p_role_ext)},
                     {record_name, p_role_ext},
                     {disc_copies, [node()]}
                    ]},
     {?DB_ROLEID_COUNTER_P, [
                           {attributes, record_info(fields, r_roleid_counter)},
                           {record_name, r_roleid_counter},
                           {disc_copies, [node()]}
                          ]},

     {?DB_MONSTERID_COUNTER_P,
        ?DEF_DISK_TABLE(set,r_monsterid_counter)},
     {?DB_MONSTER_PERSISTENT_INFO_P,
        ?DEF_DISK_TABLE(set,r_monster_persistent_info)},
     {?DB_ROLE_STATE_P, [
                       {disc_copies, [node()]},
                       {type, set},
                       {record_name, r_role_state},
                       {attributes, record_info(fields, r_role_state)}
                      ]},
     {?DB_STALL_P, [
                  {disc_copies, [node()]},
                  {type, set},
                  {index, [mapid, mode]},
                  {record_name, r_stall},
                  {attributes, record_info(fields, r_stall)}
                 ]},
     {?DB_STALL_SILVER_P, [
                         {disc_copies, [node()]},
                         {type, set},
                         {record_name, r_stall_silver},
                         {attributes, record_info(fields, r_stall_silver)}
                        ]},
     {?DB_STALL_GOODS_P, [
                        {disc_copies, [node()]},
                        {type, set},
                        {record_name, r_stall_goods},
                        {index, [role_id]},
                        {attributes, record_info(fields, r_stall_goods)}
                       ]},
     {?DB_STALL_GOODS_TMP_P, [
                            {disc_copies, [node()]},
                            {type, set},
                            {record_name, r_stall_goods},
                            {index, [role_id]},
                            {attributes, record_info(fields, r_stall_goods)}
                           ]},

     {?DB_ROLE_BAG_P, 
      [ {disc_copies, [node()]},
        {type, set}, 
        {record_name, r_role_bag},
        {attributes, record_info(fields, r_role_bag)} ]},
     {?DB_ROLE_BAG_BASIC_P, 
      [ {disc_copies, [node()]},
        {type, set}, 
        {record_name, r_role_bag_basic},
        {attributes, record_info(fields, r_role_bag_basic)} ]},
     {?DB_FRIEND_P, 
      [ {disc_copies, [node()]},
        {type, bag }, 
        {record_name, r_friend}, 
        {attributes, record_info(fields, r_friend)} ]}, 
     {?DB_ROLE_SKILL_P, 
      [ {disc_copies, [node()]}, 
        {type, set}, 
        {record_name, r_role_skill}, 
        {attributes, record_info(fields, r_role_skill)} ]},
     %%任务
     {?DB_MISSION_DATA_P,
      [ {disc_copies, [node()]}, 
        {type, set}, 
        {record_name, r_db_mission_data}, 
        {attributes, record_info(fields, r_db_mission_data)} ]},

     {?DB_BANK_SHEETS_P,
      [ {disc_copies, [node()]}, 
        {type, set},
        {record_name, p_bank_sheet}, 
        {index, [roleid]},
        {attributes, record_info(fields, p_bank_sheet)} ]}, 

     {?DB_BANK_SELL_P,
      [ {disc_copies, [node()]}, 
        {type, ordered_set},
        {record_name, r_bank_sell}, 
        {attributes, record_info(fields, r_bank_sell)} ]}, 

     {?DB_BANK_BUY_P,
      [ {disc_copies, [node()]}, 
        {type, ordered_set},
        {record_name, r_bank_buy}, 
        {attributes, record_info(fields, r_bank_buy)} ]},

     {?DB_SHEET_COUNTER_P,
      [ {disc_copies, [node()]}, 
        {type, set},
        {record_name, r_sheet_counter}, 
        {attributes, record_info(fields, r_sheet_counter)} ]},
     {?DB_SHORTCUT_BAR_P,
      [ {disc_copies, [node()]}, 
        {type, set},
        {record_name, r_shortcut_bar}, 
        {attributes, record_info(fields, r_shortcut_bar)} ]},
     {?DB_BROADCAST_MESSAGE_P,
      [{disc_copies, [node()]},
       {type, set},
       {index, [msg_type,expected_time,send_flag]},
       {record_name, r_broadcast_message}, 
       {attributes, record_info(fields, r_broadcast_message)}]},
     %%门派相关蟿
     {?DB_FAMILY_P, 
      [ {disc_copies, [node()]},
        {type, set},
        {record_name, p_family_info},
        {attributes, record_info(fields, p_family_info)}
      ]},
     {?DB_FAMILY_EXT_P, 
      [ {disc_copies, [node()]},
        {type, set},
        {record_name, r_family_ext},
        {attributes, record_info(fields, r_family_ext)}
      ]},
     {?DB_FAMILY_NAME_P,
      ?DEF_DISK_TABLE(set,r_family_name)},
     {?DB_FAMILY_COUNTER_P, 
      [ {disc_copies, [node()]},
        {type, set},
        {record_name, r_family_counter},
        {attributes, record_info(fields, r_family_counter)}
      ]},
     {?DB_FAMILY_INVITE_P, 
      [ {disc_copies, [node()]},
        {type, bag},
        {record_name, p_family_invite_info},
        {attributes, record_info(fields, p_family_invite_info)}
      ]},
     {?DB_FAMILY_REQUEST_P, 
      [ {disc_copies, [node()]},
        {type, bag},
        {record_name, p_family_request_info},
        {attributes, record_info(fields, p_family_request_info)}
      ]},
     %% 聊天模块
     {?DB_CHAT_CHANNEL_ROLES_P, 
      [ {disc_copies, [node()]},
        {type, bag},
        {record_name, p_chat_channel_role_info},
        {attributes, record_info(fields, p_chat_channel_role_info)}
      ]},
     {?DB_CHAT_ROLE_CHANNELS_P, 
      [ {disc_copies, [node()]},
        {type, bag},
        {record_name, r_chat_role_channel_info},
        {attributes, record_info(fields, r_chat_role_channel_info)}
      ]},
     {?DB_CHAT_CHANNELS_P, 
      [ {disc_copies, [node()]},
        {type, set},
        {record_name, p_channel_info},
        {attributes, record_info(fields, p_channel_info)}
      ]},
     {?DB_BAN_CHAT_USER_P, 
      [ {disc_copies, [node()]},
        {type, set},
        {record_name, r_ban_chat_user},
        {attributes, record_info(fields, r_ban_chat_user)}
      ]},
     %%师徒
     {?DB_ROLE_EDUCATE_P,
      [ {disc_copies, [node()]},
        {type, set},
        {record_name, r_educate_role_info},
        {attributes, record_info(fields, r_educate_role_info)}
      ]},
     {?DB_FCM_DATA_P, 
      [ {disc_copies, [node()]},
        {type, set},
        {record_name, r_fcm_data},
        {attributes, record_info(fields, r_fcm_data)}
      ]},

     {?DB_KEY_PROCESS, 
      [ {ram_copies, [node()]},
        {type, set},
        {record_name, r_key_process},
        {attributes, record_info(fields, r_key_process)}
      ]},
     {?DB_SYSTEM_CONFIG_P, 
      [ {disc_copies, [node()]},
        {type, set},
        {record_name, r_sys_config},
        {attributes, record_info(fields, r_sys_config)}
      ]},
     {?DB_ROLE_LEVEL_RANK_P, 
      [{record_name, p_role_level_rank},
       {attributes, record_info(fields, p_role_level_rank)},
       {disc_copies, [node()]}
      ]},
     {
       ?DB_NORMAL_TITLE_P,
       [{record_name, p_title},
        {attributes, record_info(fields, p_title)},
        {disc_copies, [node()]}]
     },
     {
       ?DB_SPEC_TITLE_P,
       [{record_name, p_title},
        {attributes, record_info(fields, p_title)},
        {disc_copies, [node()]}]
     },
     {
       ?DB_TITLE_COUNTER_P,
       [{record_name, r_title_counter},
        {attributes, record_info(fields, r_title_counter)},
        {disc_copies, [node()]}]
     },
     {?DB_ROLE_PKPOINT_RANK_P, 
      [{record_name, p_role_pkpoint_rank},
       {attributes, record_info(fields, p_role_pkpoint_rank)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_ROLE_WORLD_PKPOINT_RANK_P, 
      [{record_name, p_role_pkpoint_rank},
       {attributes, record_info(fields, p_role_pkpoint_rank)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_FAMILY_ACTIVE_RANK_P, 
      [{record_name, p_family_active_rank},
       {attributes, record_info(fields, p_family_active_rank)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_EQUIP_REFINING_RANK_P, 
      [{record_name, p_equip_rank},
       {attributes, record_info(fields, p_equip_rank)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_EQUIP_REINFORCE_RANK_P, 
      [{record_name, p_equip_rank},
       {attributes, record_info(fields, p_equip_rank)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_EQUIP_STONE_RANK_P, 
      [{record_name, p_equip_rank},
       {attributes, record_info(fields, p_equip_rank)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_ROLE_GONGXUN_RANK_P, 
      [{record_name, p_role_gongxun_rank},
       {attributes, record_info(fields, p_role_gongxun_rank)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_ROLE_TODAY_GONGXUN_RANK_P, 
      [{record_name, p_role_gongxun_rank},
       {attributes, record_info(fields, p_role_gongxun_rank)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_ROLE_YESTERDAY_GONGXUN_RANK_P, 
      [{record_name, p_role_gongxun_rank},
       {attributes, record_info(fields, p_role_gongxun_rank)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_FAMILY_GONGXUN_PERSISTENT_RANK_P,
      [{record_name, p_family_gongxun_persistent_rank},
       {attributes, record_info(fields, p_family_gongxun_persistent_rank)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_ROLE_PET_RANK_P, 
      [{record_name, p_role_pet_rank},
       {attributes, record_info(fields, p_role_pet_rank)},
       {disc_copies, [node()]}
      ]},
%%%%%here
     {?DB_BAN_USER_P,
      [ {disc_copies,[node()]},
	{type,set},
	{record_name,r_ban_user},
	{attributes,record_info(fields,r_ban_user)}
      ]
     },

     {?DB_BAN_IP_P,
      [{disc_copies,[node()]},
       {type,set},
       {record_name,r_ban_ip},
       {attributes,record_info(fields,r_ban_ip)}
      ]
     },

     %% 王座争霸战历史记录表
     {?DB_WAROFKING_HISTORY_P, 
      [
       {disc_copies, [node()]},
       {type, set},
       {record_name, r_warofking_history},
       {attributes, record_info(fields, r_warofking_history)}
      ]},
     {?DB_WAROFKING_HISTORY_INDEX_P, 
      [
       {disc_copies, [node()]},
       {type, set},
       {record_name, r_warofking_history_index},
       {attributes, record_info(fields, r_warofking_history_index)}
      ]},
      
     {?DB_TRAINING_CAMP_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_training_camp},
       {attributes, record_info(fields, r_training_camp)}
      ]
     },
     {?DB_PAY_LOG_P, 
      [
       {disc_copies, [node()]},
       {type, set},
       {record_name, r_pay_log},
       {attributes, record_info(fields, r_pay_log)}
      ]},
     {?DB_PAY_LOG_INDEX_P, 
      [
       {disc_copies, [node()]},
       {type, set},
       {record_name, r_pay_log_index},
       {attributes, record_info(fields, r_pay_log_index)}
      ]},

     {?DB_SKILL_TIME_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_skill_time},
       {attributes, record_info(fields, r_skill_time)}
      ]
     },

     {?DB_FACTION_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_faction},
       {attributes, record_info(fields, p_faction)}
      ]
     },
      {?DB_WAROFFACTION_RECORD_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_waroffaction_record},
       {attributes, record_info(fields, p_waroffaction_record)}
      ]
     },
      {?DB_WAROFFACTION_COUNTER_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_waroffaction_counter},
       {attributes, record_info(fields, r_waroffaction_counter)}
      ]
     },
     {?DB_ROLE_ACHIEVEMENT_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_db_role_achievement},
       {attributes, record_info(fields, r_db_role_achievement)}
      ]
     },
     {?DB_WAROFKING_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, db_warofking},
       {attributes, record_info(fields, db_warofking)}
      ]},
     {?DB_YBC_P, 
      [{record_name, r_ybc},
       {attributes, record_info(fields, r_ybc)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_YBC_INDEX_P, 
      [{record_name, r_ybc_index},
       {attributes, record_info(fields, r_ybc_index)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_YBC_UNIQUE_P, 
      [{record_name, r_ybc_unique},
       {attributes, record_info(fields, r_ybc_unique)},
       {disc_copies, [node()]}
      ]
     },
     {?DB_YBC_PERSON_P, 
      [{record_name, r_ybc_person},
       {attributes, record_info(fields, r_ybc_person)},
       {disc_copies, [node()]}
      ]},
     {?DB_VIE_WORLD_FB_LOG_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_vie_world_fb_log},
       {attributes, record_info(fields, r_vie_world_fb_log)}
      ]},
     {?DB_CONFIG_SYSTEM_P, 
      [{disc_copies, [node()]},
      {type, set},
      {record_name, r_config_system},
      {attributes, record_info(fields, r_config_system)}
      ]},
     {?DB_EQUIP_ONEKEY_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_equip_onekey},
       {attributes, record_info(fields, r_equip_onekey)}
      ]},
     {?DB_EVENT_STATE_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_event_state},
       {attributes, record_info(fields, r_event_state)}
      ]},
     {?DB_MAP_EVENT_TIMER_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_map_event_timer},
       {attributes, record_info(fields, r_map_event_timer)}
      ]},
     {?DB_COUNTER_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_counter},
       {attributes, record_info(fields, r_counter)}
      ]},
     %% 商贸活动
     {?DB_ROLE_TRADING_P,
        ?DEF_DISK_TABLE(set,r_role_trading)},
     %% 门派仓库
     {?DB_FAMILY_DEPOT_P,
        ?DEF_DISK_TABLE(set,r_family_depot)},
     %% 门派的资产表
     {?DB_FAMILY_ASSETS_P,
        ?DEF_DISK_TABLE(set,r_family_assets)},
     {?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO_P,
        ?DEF_DISK_TABLE(set,p_family_collect_role_prize_info)},
     {?DB_ROLE_PLANT_P,
        ?DEF_DISK_TABLE(set,r_role_plant)},
     {?DB_ROLE_PLANT_LOG_P,
        ?DEF_DISK_TABLE(set,r_role_plant_log)},
     %% 鲜花
     {?DB_ROLE_RECEIVE_FLOWERS_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_receive_flowers},
       {attributes, record_info(fields, r_receive_flowers)}
      ]},
     {?DB_ROLE_GIVE_FLOWERS_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_give_flowers},
       {attributes, record_info(fields, r_give_flowers)}
      ]},
     {?DB_ROLE_GIVE_FLOWERS_RANK_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_role_give_flowers_rank},
       {attributes, record_info(fields, p_role_give_flowers_rank)}
      ]},
     {?DB_ROLE_GIVE_FLOWERS_TODAY_RANK_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_role_give_flowers_today_rank},
       {attributes, record_info(fields, p_role_give_flowers_today_rank)}
      ]},
     {?DB_ROLE_GIVE_FLOWERS_YESTERDAY_RANK_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_role_give_flowers_yesterday_rank},
       {attributes, record_info(fields, p_role_give_flowers_yesterday_rank)}
      ]},
      {?DB_ROLE_GIVE_FLOWERS_LAST_WEEK_RANK_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_role_give_flowers_last_week_rank},
       {attributes, record_info(fields, p_role_give_flowers_last_week_rank)}
      ]},
      {?DB_ROLE_GIVE_FLOWERS_THIS_WEEK_RANK_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_role_give_flowers_this_week_rank},
       {attributes, record_info(fields, p_role_give_flowers_this_week_rank)}
      ]},
     {?DB_ROLE_RECE_FLOWERS_RANK_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_role_rece_flowers_rank},
       {attributes, record_info(fields, p_role_rece_flowers_rank)}
      ]},
     {?DB_ROLE_RECE_FLOWERS_TODAY_RANK_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_role_rece_flowers_today_rank},
       {attributes, record_info(fields, p_role_rece_flowers_today_rank)}
      ]},
     {?DB_ROLE_RECE_FLOWERS_YESTERDAY_RANK_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_role_rece_flowers_yesterday_rank},
       {attributes, record_info(fields, p_role_rece_flowers_yesterday_rank)}
      ]},
     {?DB_ROLE_RECE_FLOWERS_LAST_WEEK_RANK_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_role_rece_flowers_last_week_rank},
       {attributes, record_info(fields, p_role_rece_flowers_last_week_rank)}
      ]},
     {?DB_ROLE_RECE_FLOWERS_THIS_WEEK_RANK_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, p_role_rece_flowers_this_week_rank},
       {attributes, record_info(fields, p_role_rece_flowers_this_week_rank)}
      ]},
     {?DB_MONEY_EVENT_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_money_event},
       {attributes, record_info(fields, r_money_event)}
      ]},
     {?DB_MONEY_EVENT_COUNTER_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_money_event_counter},
       {attributes, record_info(fields, r_money_event_counter)}
      ]},
     {?DB_USER_EVENT_COUNTER_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_user_event_counter},
       {attributes, record_info(fields, r_user_event_counter)}
      ]},
     {?DB_USER_EVENT_P,
      [{disc_copies, [node()]},
       {type, set},
       {record_name, r_user_event},
       {attributes, record_info(fields, r_user_event)}
      ]},
     {?DB_ROLE_LEVEL_GIFT_P,
      ?DEF_DISK_TABLE(set, r_role_level_gift)},
     {?DB_ROLE_TIME_GIFT_P,
      ?DEF_DISK_TABLE(set, r_role_time_gift)},
     %% 玩家活动状态表
     {?DB_ROLE_ACTIVITY_P,
      ?DEF_DISK_TABLE(set, r_role_activity)},
     %% 记录玩家充值活动情况的表
     {?DB_PAY_ACTIVITY_P, 
      ?DEF_DISK_TABLE(set, r_pay_activity)}, 
     %% 国战   
     {?DB_WAROFFACTION_P,
      ?DEF_DISK_TABLE(set,r_waroffaction)},
     %%宠物
     {?DB_PET_P,
      ?DEF_DISK_TABLE(set, p_pet)},
     {?DB_PET_FEED_P,
      ?DEF_DISK_TABLE(set, p_pet_feed )},
     {?DB_ROLE_PET_GROW,
      ?DEF_DISK_TABLE(set, p_role_pet_grow )},
     {?DB_ROLE_PET_BAG_P,
      ?DEF_DISK_TABLE(set, p_role_pet_bag)},
     {?DB_PET_EGG_P,
      ?DEF_DISK_TABLE(set, p_role_pet_egg_type_list)},
     {?DB_USER_DATA_LOAD_MAP_P,
      ?DEF_DISK_TABLE(set, r_user_data_load_map)},
     {?DB_SPY_P,
      ?DEF_DISK_TABLE(set, r_spy)},
     %% 赠品模块
     {?DB_ROLE_PRESENT_P,
      ?DEF_DISK_TABLE(set, r_role_present)},     
     %% 门派技能模块
     {?DB_FAMILY_SKILL_RESEARCH_P,
      ?DEF_DISK_TABLE(set, r_family_skill_research)},   
     %% 日常活动/福利模块
     {?DB_ROLE_ACTIVITY_TASK_P,
      ?DEF_DISK_TABLE(set, r_role_activity_task)}, 
     {?DB_ROLE_ACTIVITY_BENEFIT_P,
      ?DEF_DISK_TABLE(set, r_role_activity_benefit)}, 
     %% 玩家坐骑刷颜色数据
     {?DB_ROLE_MOUNT_P,
      ?DEF_DISK_TABLE(set, r_role_mount)},  
     %% 师门同心副本
     {?DB_EDUCATE_FB_P,
      ?DEF_DISK_TABLE(set,r_educate_fb)},
     {?DB_ROLE_CONLOGIN_P,
      ?DEF_DISK_TABLE(set,r_role_conlogin)},
     {?DB_SYSTEM_NOTICE_P,
      ?DEF_DISK_TABLE(set,r_system_notice)},
     %% 个人副本
     {?DB_ROLE_PERSONAL_FB_P,
      ?DEF_DISK_TABLE(set,r_role_personal_fb)},
     {?DB_PERSONAL_FB_P,
      ?DEF_DISK_TABLE(set,r_personal_fb)},
     %% 玩家参与门派活动的记录
     {?DB_ROLE_FAMILY_PARTTAKE_P,
      ?DEF_DISK_TABLE(set,r_role_family_parttake)},
     %% 离线消息
     {?DB_OFFLINE_MSG_P,
      ?DEF_DISK_TABLE(set,r_offline_msg)},
     {?DB_ROLE_ACCUMULATE_EXP_P,
      ?DEF_DISK_TABLE(set,r_role_accumulate_exp)},
     {?DB_ROLE_ACCUMULATE_P,?DEF_DISK_TABLE(set,r_role_accumutlate)},
     {?DB_COMMON_LETTER_P, 
      ?DEF_DISK_TABLE(set,r_common_letter)},
     {?DB_PERSONAL_LETTER_P,
      ?DEF_DISK_TABLE(set,r_personal_letter)},
     {?DB_PUBLIC_LETTER_P,
      ?DEF_DISK_TABLE(set,r_public_letter)},
     {?DB_WORLD_COUNTER_P,
      ?DEF_DISK_TABLE(set,r_world_counter)},
     {?DB_ROLE_VIP_P,?DEF_DISK_TABLE(set, p_role_vip)},
     %% 场景大战副本
     {?DB_SCENE_WAR_FB_P,?DEF_DISK_TABLE(set,r_scene_war_fb)},
     %% 玩家礼包表
     {?DB_ROLE_GIFT_P,?DEF_DISK_TABLE(set,r_role_gift)},
     {?DB_ROLE_HERO_FB_P,?DEF_DISK_TABLE(set, p_role_hero_fb_info)},
     %% 英雄副本
     {?DB_HERO_FB_RECORD_P, ?DEF_DISK_TABLE(set, r_hero_fb_record)},
     %% 任务任务副本
     {?DB_ROLE_MISSION_FB_P, ?DEF_DISK_TABLE(set, r_role_mission_fb)},
     %%禁言配置表
     {?DB_BAN_CONFIG_P,?DEF_DISK_TABLE(set,r_ban_config)},
     {?DB_SHOP_CUXIAO_P,?DEF_DISK_TABLE(set,p_shop_cuxiao_item)},
     {?DB_SHOP_CUXIAO_FLAG_P,?DEF_DISK_TABLE(set,r_shop_cuxiao_flag)},
     {?DB_ROLE_MONSTER_DROP_P, ?DEF_DISK_TABLE(set, r_role_monster_drop)},
     {?DB_ROLE_NPC_DEAL_P, ?DEF_DISK_TABLE(set, r_role_npc_deal)},
     %% 开箱子表
     {?DB_ROLE_BOX_P,?DEF_DISK_TABLE(set,r_role_box)},
     {?DB_BOX_GOODS_LOG_P,?DEF_DISK_TABLE(set,r_box_goods_log)},
     %% 传奇目标
     {?DB_ROLE_GOAL_P, ?DEF_DISK_TABLE(set, p_role_goal)},
     {?DB_ACTIVITY_REWARD_P,?DEF_DISK_TABLE(set,r_activity_reward)},
     {?DB_PAY_FAILED_P, ?DEF_DISK_TABLE(set, r_pay_failed)},
     %% 全服成就表
     {?DB_ACHIEVEMENT_RANK_P,?DEF_DISK_TABLE(set,r_achievement_rank)},
     %% 宠物扩展信息
     {?DB_PET_TRAINING_P,?DEF_DISK_TABLE(set,r_pet_training)},
     %% 宗族捐献
     {?DB_FAMILY_DONATE_P,?DEF_DISK_TABLE(set,r_family_donate)},
     %% 刷棋副本角色信息
     {?DB_ROLE_SQ_FB_INFO_P,?DEF_DISK_TABLE(set,r_role_sq_fb_info)},
     %% 玩家经验瓶表
     {?DB_ROLE_EXP_BOTTLE_P,?DEF_DISK_TABLE(set,r_role_exp_bottle)},
     %% 练功房角色信息
     {?DB_ROLE_EXE_FB_INFO_P,?DEF_DISK_TABLE(set,r_role_exe_fb_info)}
    ].
