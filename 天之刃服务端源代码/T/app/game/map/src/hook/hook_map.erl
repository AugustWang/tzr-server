%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc 
%%%     地图hook接口
%%%     处理每个地图进程的init,terminate和循环
%%% @end
%%% Created :  8 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(hook_map).

-include("mgeem.hrl").


%% API
-export([
         loop/1,
         loop_ms/0,
         init/2,
         terminate/0
        ]).


%%地图每秒钟的循环
loop(MapID) ->
    Now = common_tool:now(),
    case MapID =:= 11111 orelse MapID =:= 12111 orelse MapID =:= 13111 of
        true ->
            ?TRY_CATCH(mod_warofking:check_end_of_war(),Err1);
        false ->
            ignore
    end,
    ?TRY_CATCH(mod_map_ybc:loop(),Err2),
    %%自动回血
    ?TRY_CATCH(mod_map_actor:auto_recover(),Err3),
    ?TRY_CATCH(mod_map_collect:check_collect(),Err4),
    ?TRY_CATCH(mod_item:check_item_use_log(),Err5),
    ?TRY_CATCH(mod_server_npc:loop(),Err7),
    ?TRY_CATCH(common_map:trigger_event_timer(),Err9),
    ?TRY_CATCH(mod_trading:loop(MapID),Err10),
    ?TRY_CATCH(mod_map_role:role_base_attr_persistent(),Err11),
    ?TRY_CATCH(mod_role_on_zazen:loop(MapID),Err12),
    %%?TRY_CATCH(mod_map_family_plant:loop(MapID),Err13),
    ?TRY_CATCH(mod_country_treasure:loop(MapID),Err14),
    ?TRY_CATCH(mod_map_actor:clear_other_faction_role(), Err15),
    ?TRY_CATCH(mod_educate_fb:loop(MapID),Err16),
    ?TRY_CATCH(mod_map_pet:loop(MapID),Err17),
    ?TRY_CATCH(mod_conlogin:loop_minday(),Err18),
    ?TRY_CATCH(mod_spy:hook_map_loop_s(MapID), Err19),
    ?TRY_CATCH(mod_pet_feed:check_feed_over(), Err20),
    ?TRY_CATCH(mod_pet_grow:check_grow_over(), Err21),
    ?TRY_CATCH(mod_scene_war_fb:loop(MapID),Err22),
    ?TRY_CATCH(mod_present_mail:loop(MapID),Err23),
    ?TRY_CATCH(mod_mission_loop:loop(),Err24),
    ?TRY_CATCH(mod_map_bonfire:loop_check(),Err25),
    ?TRY_CATCH(mod_family_collect:loop(),Err26),	
    %%?TRY_CATCH(mod_vip:do_vip_list_info_update(MapID), Err27),
    ?TRY_CATCH(mod_role_buff:hook_map_loop_sec(), Err28),
    ?TRY_CATCH(mod_shop:loop(), Err29),
    ?TRY_CATCH(mod_map_team:loop(), Err30),
    ?TRY_CATCH(mod_dynamic_monster:hook_map_loop(Now), Err31),
    ?TRY_CATCH(mod_pet_training:hook_map_loop(Now),Err32),
    ?TRY_CATCH(mod_stall_list:hook_map_loop(MapID, Now), Err33),
    ?TRY_CATCH(mod_shuaqi_fb:loop(MapID,Now),Err34),
    ?TRY_CATCH(mod_exercise_fb:loop(MapID, Now),Err35),
    ?TRY_CATCH(mod_item:loop(MapID, Now),Err36),
    ok.

loop_ms() ->
    ?TRY_CATCH(mod_map_ybc:loop_ms(),Err1),
    ?TRY_CATCH(mod_map_trap:hook_map_loop_ms(),Err2),
    ?TRY_CATCH(mgeem_map:flush_all_role_msg_queue(), Err3),
    ok.
    

init(MapID, MapName) ->
    ?TRY_CATCH(mod_map_bonfire:init(MapID),Err00),
    ?TRY_CATCH(mod_refining_bag:init_drop_goods_id(),Err1),
    ?TRY_CATCH(mod_map_monster:init_monster_id_list(),Err2),
    ?TRY_CATCH(mod_server_npc:init_server_npc_id_list(),Err3),
    ?TRY_CATCH(mod_server_npc:init_map_server_npc(MapID, MapName),Err4),
    
    %%门派副本不自动出生怪物
    IsSceneWarFbBornMonster = mod_scene_war_fb:is_scene_war_fb_born_monster(MapID),
    if MapID =:= 10300 
       orelse MapID =:= 10400
       orelse MapID =:= 10500
       orelse MapID =:= 10600 
       orelse IsSceneWarFbBornMonster =:= false ->
            ignore;
       true ->
            ?TRY_CATCH(mod_map_monster:init_map_monster(MapName, MapID),Err5)
    end,
    ?TRY_CATCH(mod_warofking:init_map_data(MapID, MapName),Err7),
    ?TRY_CATCH(mod_map_ybc:init(MapID, MapName),Err8),
    ?TRY_CATCH(mod_warofcity:init(),Err9),
    ?TRY_CATCH(mod_stall:init(MapName),Err10),
    ?TRY_CATCH(mod_vie_world_fb:init_map_data(MapID, MapName),Err11),
    ?TRY_CATCH(mod_trading:init(MapID, MapName),Err12),
    ?TRY_CATCH(mod_role_on_zazen:init(MapID),Err13),
    %% 通知mgeew_system_buff地图起来了
    case global:whereis_name(mgeew_system_buff) of
        undefined ->
            ignore;
        PID ->
            PID ! {map_init, MapName}
    end,
    ?TRY_CATCH(mod_country_treasure:init(MapID, MapName),Err14),
    ?TRY_CATCH(mod_system_notice:init(), Err15),
    ?TRY_CATCH(mod_map_pet:init(),Err16),
    ?TRY_CATCH(mod_spy:hook_map_init(MapID), Err17),
    ?TRY_CATCH(mod_pet_feed:init_role_pet_feed(), Err18),
    ?TRY_CATCH(mod_pet_grow:init(), Err19),
    ?TRY_CATCH(mod_map_trap:init_map_trap_list(), Err20),
    ?TRY_CATCH(mod_scene_war_fb:init(MapID, MapName), Err21),
    ?TRY_CATCH(mod_family_collect:init(MapID, MapName), Err22),
    ?TRY_CATCH(mod_vip:hook_map_init(MapID), Err23),
    ?TRY_CATCH(mod_stall_list:init(MapID), Err24),
    ?TRY_CATCH(mod_waroffaction:init(MapID), Err25),
    ?TRY_CATCH(mod_dynamic_monster:hook_map_init(MapID), Err26),
    ?TRY_CATCH(mod_achievement:init(MapID), Err27),
    ?TRY_CATCH(mod_role2:init(MapID), Err28),
    ?TRY_CATCH(mod_item:init(MapID), Err29),
    ok.

terminate() ->
    ?TRY_CATCH(mod_map_ybc:terminate(),Err1),
    ?TRY_CATCH(mod_stall:do_terminate(),Err2),
    ?TRY_CATCH(mod_map_role:role_base_attr_persistent(),Err3),
    ok.

