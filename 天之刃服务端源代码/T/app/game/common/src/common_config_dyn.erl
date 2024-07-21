%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     common_config 的动态加载实现版本，之后可以取缔common_config
%%%     目前只支持key-value或者record（首字段为key）的配置文件
%%% @end
%%% Created : 2010-12-2
%%%-------------------------------------------------------------------
-module(common_config_dyn).


%% API
-export([init/0,init_basic/0,init_root/0]).
-export([reload_all/0,reload/1]).
-export([list_item/0,list_equip/0,list_stone/0,list_driver/0]).
-export([find_item/1,find_equip/1,find_stone/1]).
-export([find_mm_map/1,find_common/1,find_manage_mm_map/1]).
-export([init/1,list/1]).

-export([find/2]).
-export([list_by_module/1]).
-export([gen_all_beam/0]).

-export([load_gen_src/2,load_gen_src/3]).

-define(MGE_ROOT_CONFIG, "/data/tzr/server/config/").
-define(MGE_ROOT_SETTING, "/data/tzr/server/setting/").

-define(DEFINE_CONFIG_MODULE(Name,FilePath,FileType),{ Name, codegen_name(Name),
                                                       ?MGE_ROOT_CONFIG ++ FilePath, FileType }).

-define(DEFINE_CONFIG_MODULE_EX(Name,FilePath,FileType,KeyType), { Name, codegen_name(Name),
                                                           ?MGE_ROOT_CONFIG ++ FilePath, FileType, KeyType }).

-define(DEFINE_SETTING_MODULE(Name,FilePath,FileType),{ Name, codegen_name(Name),
                                                        ?MGE_ROOT_SETTING ++ FilePath, FileType }).

%% 支持4种文件类型：record_consult,key_value_consult,key_value_list,record_list,

-define(BASIC_CONFIG_FILE_LIST,[    %%配置模块名称,路径,类型
                                    ?DEFINE_SETTING_MODULE(common,"common.config",key_value_consult),
                                    ?DEFINE_CONFIG_MODULE(mm_map,"mm_map.config",key_value_list),
                                    ?DEFINE_CONFIG_MODULE(module_method_open,  "module_method_open.config",key_value_consult),
                                    ?DEFINE_CONFIG_MODULE(stat, "stat.config", key_value_consult),
                                    ?DEFINE_CONFIG_MODULE(title, "title.config", key_value_consult)
                               ]).

-define(ROOT_CONFIG_FILE_LIST,[    %%配置模块名称,路径,类型
                                   ?DEFINE_CONFIG_MODULE(item,  "world/item.config",record_consult),
                                   ?DEFINE_CONFIG_MODULE(stone,  "world/stone.config",record_consult),
                                   ?DEFINE_CONFIG_MODULE(equip,  "world/equip.config",record_consult),
                                   ?DEFINE_CONFIG_MODULE(born,"born.config",key_value_list),
                                   ?DEFINE_CONFIG_MODULE(born_point,"born_point.config",record_consult),
                                   ?DEFINE_CONFIG_MODULE(buff_type,"buff_type.config",key_value_list),
                                   ?DEFINE_CONFIG_MODULE(buffs,"buffs.config",record_list),
                                   ?DEFINE_CONFIG_MODULE(driver,"driver.config",record_consult),
                                   ?DEFINE_CONFIG_MODULE(ybc_person_cost,"ybc_person_cost.config", record_consult),
                                   %%?DEFINE_CONFIG_MODULE(level_channel,"level_channel.config",key_value_list),
                                   ?DEFINE_CONFIG_MODULE(map_info,"map_info.config",key_value_consult),

                                   ?DEFINE_CONFIG_MODULE(effects,"effects.config",record_list),
                                   ?DEFINE_CONFIG_MODULE(level,"level.config",record_list),
                                   ?DEFINE_CONFIG_MODULE(activate_code,"activate_code.config",record_consult),
                                   ?DEFINE_CONFIG_MODULE(logs,"logs.config",key_value_consult),
                                   ?DEFINE_CONFIG_MODULE(etc, "etc.config", key_value_consult),
                                   ?DEFINE_CONFIG_MODULE(mccq_activity,  "mccq_activity.config",key_value_consult)
                              ]).

%% 子目录下面的配置文件，注释掉的行 表示不支持
-define(SUB_CONFIG_FILE_LIST,[    %%配置模块名称,路径,类型


                                  ?DEFINE_CONFIG_MODULE(extend_bag,  "world/extend_bag.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(gift,  "world/gift.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(bighpmp,  "world/big_hp_mp.config",record_consult),

                                  ?DEFINE_CONFIG_MODULE(broadcast,  "world/broadcast.config",key_value_list),
                                  ?DEFINE_CONFIG_MODULE(compose,  "world/compose.config",key_value_list),
                                  ?DEFINE_CONFIG_MODULE(equip_bind,  "world/equip_bind.config",key_value_list),
                                  ?DEFINE_CONFIG_MODULE(equip_build,  "world/equip_build.config",key_value_list),
                                  ?DEFINE_CONFIG_MODULE(equip_change,  "world/equip_change.config",key_value_list),
                                  ?DEFINE_CONFIG_MODULE(equip_five_ele,  "world/equip_five_ele.config",key_value_list),
                                  %% equip_whole_attr暂时不需要
                                  ?DEFINE_CONFIG_MODULE(equip_whole_attr,  "world/equip_whole_attr.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(refining_box,  "world/refining_box.config",key_value_consult),

                                  %%?DEFINE_CONFIG_MODULE(equip_link,  "world/equip_link.config",record_consult),
                                  %%?DEFINE_CONFIG_MODULE(letter,  "world/letter.config",key_value_list),
                                  %%?DEFINE_CONFIG_MODULE(punch,  "world/punch.config",record_consult),
                                  %%?DEFINE_CONFIG_MODULE(receiver_letter,  "world/receiver_letter.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(refining,  "world/refining.config",key_value_list),
                                  %%?DEFINE_CONFIG_MODULE(send_letter,  "world/send_letter.config",record_consult),

                                  ?DEFINE_CONFIG_MODULE(educate,  "world/educate.config",key_value_consult),
                                  %%?DEFINE_CONFIG_MODULE(rank_info,  "world/rank_info.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(training,  "world/training_exp.config",key_value_list),

                                  %%?DEFINE_CONFIG_MODULE(broadcast_admin,  "world/broadcast_admin_data.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(broadcast_loop,  "world/broadcast_loop.config",record_consult),

                                  ?DEFINE_CONFIG_MODULE(item_cd,  "world/item_cd.config",key_value_list),
                                  ?DEFINE_CONFIG_MODULE(team,  "world/team.config",key_value_list),
                                  ?DEFINE_CONFIG_MODULE(family,  "world/family.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(family_boss,  "world/family_boss.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(family_level_reduce,  "world/family_level_reduce.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(family_depot,  "world/family_depot.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(family_buff,  "world/family_buff.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(family_base_info,  "world/family_base_info.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(mount_level,  "world/mount_level.config",key_value_consult),

                                  ?DEFINE_CONFIG_MODULE(family_plant,  "world/family_plant.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(plant_farm,  "world/plant_farm.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(plant_skill,  "world/plant_skill.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(friend,  "world/friend.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(mission_etc,  "mission/mission_etc.config",key_value_consult),
                                  
                                  ?DEFINE_CONFIG_MODULE(monster,  "monster/monster.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(monster_etc, "monster/monster_etc.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(boss_ai,  "monster/boss_ai.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(monster_drop_broadcast,  "monster/monster_drop_broadcast.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(server_npc,  "monster/server_npc.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(server_npc_born,  "monster/server_npc_born.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(waroffaction_guarder,  "monster/waroffaction_guarder.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(waroffaction_etc, "monster/waroffaction_etc.config", key_value_consult),

                                  ?DEFINE_CONFIG_MODULE(pet,  "pet/pet.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(pet_skill,  "pet/pet_skill.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(pet_aptitude,  "pet/pet_aptitude.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(pet_level,  "pet/pet_level.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(pet_training_exp,"pet/pet_training_exp.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(pet_understanding,  "pet/pet_understanding.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(pet_grow,  "pet/pet_grow.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(pet_etc,  "pet/pet_etc.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(pet_training,"pet/pet_training.config",key_value_consult),
                                  
                                  ?DEFINE_CONFIG_MODULE(shop_price_time,  "world/shop_price_time.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(shop_cu_xiao,  "world/shop_cu_xiao.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(shop_test,  "world/shop_test.config",record_consult),

                                  ?DEFINE_CONFIG_MODULE(skill,"map/skill.config",record_list),
                                  ?DEFINE_CONFIG_MODULE(skill_level_tmp, "map/skill_level_tmp.config", key_value_list),
                                  ?DEFINE_CONFIG_MODULE(skill_level,"map/skill_level.config",key_value_list),

                                  ?DEFINE_CONFIG_MODULE(npc_exchange,  "map/npc_exchange.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(money,  "map/money.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(collect,  "map/collect_base.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(map_level_limit,  "map/map_level_limit.config",key_value_list),
                                  ?DEFINE_CONFIG_MODULE(collect_base,  "map/collect_base.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(vie_world_fb,  "map/vie_world_fb.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(trading,  "map/trading.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(role_on_zazen,  "map/role_on_zazen.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(country_treasure,  "map/country_treasure.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(educate_fb,  "map/educate_fb.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(achievement_hook,  "map/achievement_hook.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(achievement_event,  "map/achievement_event.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(achievement,  "map/achievement.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(scene_war_fb,  "map/scene_war_fb.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(item_gift,  "map/item_gift.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(dynamic_monster, "monster/dynamic_monster.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(prestige_exchange,  "map/prestige_exchange.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(monster_change,  "monster/monster_change.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(equip_add_magic,  "world/equip_add_magic.config",key_value_consult),

                                  ?DEFINE_CONFIG_MODULE(fb_manual_monster,  "monster/fb_manual_monster.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(item_effect, "map/item_effect.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(activity_mission, "map/activity_mission.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(drop_goods_notify,  "map/drop_goods_notify.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(monster_born_and_dead_broadcast, "map/monster_born_and_dead_broadcast.config", record_consult),
                                  ?DEFINE_CONFIG_MODULE(flowers, "map/flowers.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(level_gift, "map/level_gift.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(time_gift, "map/time_gift.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(spy, "map/spy.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(jail, "map/jail.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(office, "world/office.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(present, "map/present.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(activity_reward, "map/activity_reward.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(activity_today, "map/activity_today.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(family_skill, "map/family_skill.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(family_skill_limit, "map/family_skill_limit.config", record_consult),
                                  ?DEFINE_CONFIG_MODULE(server_npc_born_num, "monster/server_npc_born_num.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(hero_fb, "map/hero_fb.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(mission_fb, "map/mission_fb.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(server_npc_born_num, "monster/server_npc_born_num.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(vip, "map/vip.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(mission_auto, "mission/mission_auto.config", record_consult),
                                  ?DEFINE_CONFIG_MODULE(mission_collect_points, "mission/mission_collect_points.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(family_collect, "map/family_collect.config", record_consult),
                                  ?DEFINE_CONFIG_MODULE(bonfire, "map/bonfire.config", record_consult),
                                  ?DEFINE_CONFIG_MODULE(drunk_buff_value, "map/drunk_buff_value.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(shuaqi_fb, "map/shuaqi_fb.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(exercise_fb, "map/exercise_fb.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(rank_activity,"activity/rank_activity.config",record_consult),
                                  ?DEFINE_CONFIG_MODULE(personybc, "map/personybc.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(monster_drop_times, "map/monster_drop_times.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(server_pos, "map/server_pos.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(monster_addition, "monster/monster_addition.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(monster_born_condition, "monster/monster_born_condition.config", key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(stall_list,"map/stall_list.config",key_value_consult),
                                  ?DEFINE_CONFIG_MODULE(spend_activity, "activity/spend_activity.config", record_consult),
                                  ?DEFINE_CONFIG_MODULE(ranking_activity, "activity/ranking_activity.config", record_consult),
                                  ?DEFINE_CONFIG_MODULE(other_activity, "activity/other_activity.config", record_consult)

                                  %% 这几个表暂时不处理
                                  %%?DEFINE_CONFIG_MODULE(server_npc_born,  "monster/server_npc_born.config",record_consult),
                                  %%?DEFINE_CONFIG_MODULE(server_npc,  "monster/server_npc.config",record_consult),
                                  %%?DEFINE_CONFIG_MODULE(vie_world_fb_monster,  "monster/vie_world_fb_monster.config",record_consult) 
                             ]).

-define(SELF_LOAD_CONFIG_FILE_LIST, [
                                     ?DEFINE_CONFIG_MODULE(family_ybc_money, "family_ybc_money.config",record_consult),
                                     ?DEFINE_CONFIG_MODULE(activity_pay_first, "activity/activity_pay_first.config", record_consult),
                                     ?DEFINE_CONFIG_MODULE(conlogin_reward, "conlogin_reward.config", record_consult),
                                     ?DEFINE_CONFIG_MODULE(pay_gift, "activity/pay_gift.config", key_value_consult),
                                     ?DEFINE_CONFIG_MODULE(faction_war, "map/faction_war.config", key_value_consult),
                                     ?DEFINE_CONFIG_MODULE(receiver_server, "receiver/receiver_server.config", key_value_consult),
                                     ?DEFINE_CONFIG_MODULE(goal, "map/goal.config", record_consult),
                                     ?DEFINE_CONFIG_MODULE(goal, "map/goal.config", record_consult)
                                    ]).


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common.hrl").
-include("common_server.hrl").
-define(FOREACH(Fun,List),lists:foreach(fun(E)-> Fun(E)end, List)).

%% ====================================================================
%% API Functions
%% ====================================================================
init_basic()->
    ?FOREACH(catch_do_load_config,?BASIC_CONFIG_FILE_LIST),
    ok.

init_root()->
    ?FOREACH(catch_do_load_config,?BASIC_CONFIG_FILE_LIST),
    ?FOREACH(catch_do_load_config,?ROOT_CONFIG_FILE_LIST),
    ok.

init()->
    ?FOREACH(catch_do_load_config,?BASIC_CONFIG_FILE_LIST),
    ?FOREACH(catch_do_load_config,?SUB_CONFIG_FILE_LIST),
    ?FOREACH(catch_do_load_config,?ROOT_CONFIG_FILE_LIST),
    ok.



%%@result   ok | {error,not_found}
init(ConfigName) when is_atom(ConfigName)->
    reload(ConfigName).

reload_all()->
    AllFileList = lists:concat( [?SUB_CONFIG_FILE_LIST,
                                 ?ROOT_CONFIG_FILE_LIST,
                                 ?SELF_LOAD_CONFIG_FILE_LIST,
                                 ?BASIC_CONFIG_FILE_LIST]),
    ?FOREACH(catch_do_load_config,AllFileList),
    ok.

%%@spec reload(ConfigName::atom())
%%@result   ok | {error,not_found}
reload(ConfigName) when is_atom(ConfigName)->
    AllFileList = lists:concat( [?SUB_CONFIG_FILE_LIST,
                                 ?ROOT_CONFIG_FILE_LIST,
                                 ?SELF_LOAD_CONFIG_FILE_LIST,
                                 ?BASIC_CONFIG_FILE_LIST]),
    case lists:keyfind(ConfigName, 1, AllFileList) of
        false->
            {error,not_found};
        ConfRec->
            reload2(ConfRec),
            ok
    end.
reload2({AtomName,ConfigModuleName,FilePath,FileType}) ->
    reload2({AtomName,ConfigModuleName,FilePath,FileType,set});
     
reload2({AtomName,ConfigModuleName,FilePath,_,_}=ConfRec) ->
    try
        {ok, Code} = do_load_config(ConfRec),
        file:write_file(lists:concat(["/data/tzr/server/ebin/config/", ConfigModuleName, ".beam"]), Code, [write, binary])
    catch
        Err:Reason->
            ?ERROR_MSG("Reason=~w,AtomName=~w,ConfigModuleName=~p,FilePath=~p",[Reason,AtomName,ConfigModuleName,FilePath]),
            throw({Err,Reason})
    end.
%%@doc 获取指定配置的配置项列表
list_item()->
    list_by_module( item_config_codegen).
list_equip()->
    list_by_module( equip_config_codegen).
list_stone()->
    list_by_module( stone_config_codegen).
list_driver()->
    list_by_module( driver_config_codegen).

%% 常用的几个配置读取接口
%%@result   [] | [Result]
find_item(Key)->
    find_by_module(item_config_codegen,Key).
find_equip(Key)->
    find_by_module(equip_config_codegen,Key).
find_stone(Key)->
    find_by_module(stone_config_codegen,Key).
find_mm_map(Key)->
    find_by_module(mm_map_config_codegen,Key).
find_common(Key)->
    find_by_module(common_config_codegen,Key).
find_manage_mm_map(Key) ->
    find_by_module(manmage_mm_map_config_codegen,Key).
%%@spec list/1
%%@doc 为了尽量少改动，接口符合ets:lookup方法的返回值规范，
%%@result   [] | [Result]
list(ConfigName)->
    case do_list(ConfigName) of
        undefined-> [];
        not_implement -> [];
        Val -> Val
    end.

%%@spec find/2
%%@doc 为了尽量少改动，接口符合ets:lookup方法的返回值规范，
%%@result   [] | [Result]
find(ConfigName,Key)->
    case do_find(ConfigName,Key) of
        undefined-> [];
        not_implement -> [];
        Val -> [Val]
    end.

%%@spec list_by_module/1
%%@result   [] | [Result]
list_by_module(ModuleName) when is_atom(ModuleName)->
    case ModuleName:list() of
        undefined-> [];
        not_implement -> [];
        Val -> Val
    end.

%%@spec find_by_module/2
%%@doc  为了尽量少改动，接口符合ets:lookup方法的返回值规范，
%%      如果你的configName是属于频繁调用的，可以在此指定 codegen的模块名
%%@result   [] | [Result]
find_by_module(ModuleName,Key) when is_atom(ModuleName)->
    case ModuleName:find_by_key(Key) of
        undefined-> [];
        not_implement -> [];
        Val -> [Val]
    end.


%%@spec do_list/1
do_list(ConfigName) ->
    ModuleName = common_tool:list_to_atom( codegen_name(ConfigName) ),
    ModuleName:list().

%%@spec do_find/2
do_find(ConfigName,Key) ->
    ModuleName = common_tool:list_to_atom( codegen_name(ConfigName) ),
    ModuleName:find_by_key(Key).

%%@spec load_gen_src/2
%%@doc ConfigName配置名，类型为atom(),KeyValues类型为[{key,Value}|...]
load_gen_src(ConfigName,KeyValues) ->
    load_gen_src(ConfigName,KeyValues,[]).

%%@spec load_gen_src/2
%%@doc ConfigName配置名，类型为atom(),KeyValues类型为[{key,Value}|...]
load_gen_src(ConfigName,KeyValues,ValList) ->
    do_load_gen_src(codegen_name(ConfigName),set,KeyValues,ValList).

%% ====================================================================
%% Local Functions
%% ====================================================================

codegen_name(Name)->
    lists:concat([Name,"_config_codegen"]).

catch_do_load_config({AtomName,ConfigModuleName,FilePath,FileType}) ->
        catch_do_load_config({AtomName,ConfigModuleName,FilePath,FileType,set});
     
catch_do_load_config({AtomName,ConfigModuleName,FilePath,_,_}=ConfRec) ->
             try
                 do_load_config(ConfRec)
             catch
                 Err:Reason->
                     ?ERROR_MSG("Reason=~w,AtomName=~w,ConfigModuleName=~p,FilePath=~p",[Reason,AtomName,ConfigModuleName,FilePath]),
                     throw({Err,Reason})
             end.

gen_all_beam() ->
    BasicConfigFileList = lists:keydelete(common, 1, ?BASIC_CONFIG_FILE_LIST),
    AllFileList = lists:concat( [?SUB_CONFIG_FILE_LIST,
                                 ?ROOT_CONFIG_FILE_LIST,
                                 ?SELF_LOAD_CONFIG_FILE_LIST,
                                 BasicConfigFileList]),
    lists:foreach(
      fun({AtomName, ConfigModuleName, FilePath, Type}) ->
              io:format("~p~n", [AtomName]),
              gen_all_beam2(AtomName, ConfigModuleName, FilePath, Type, set);
         ({AtomName, ConfigModuleName, FilePath, Type, KeyType}) ->
              io:format("~p~n", [AtomName]),
              gen_all_beam2(AtomName, ConfigModuleName, FilePath, Type, KeyType)
      end, AllFileList),
    c:cd("/data/mtzr/config/src"),
    make:all(),
    ok.

gen_all_beam2(AtomName, ConfigModuleName, FilePath, Type, KeyType) ->
    case AtomName =:= common of
        true ->
            ignore;
        false ->
            try
                gen_src_file(ConfigModuleName, FilePath, Type, KeyType)
            catch
                Err:Reason->
                    throw({Err,FilePath,Reason})
            end
    end.

gen_src_file(ConfigModuleName, FilePath, Type, KeyType) ->
    if 
        Type =:= record_consult ->
            {ok,RecList} = file:consult(FilePath),
            KeyValues = [ begin
                              Key = element(2,Rec), {Key,Rec}
                          end || Rec<- RecList ],
            ValList = RecList;
        Type =:= record_list ->
            {ok,[RecList]} = file:consult(FilePath),
            KeyValues = [ begin
                              Key = element(2,Rec), {Key,Rec}
                          end || Rec<- RecList ],
            ValList = RecList;
        Type =:= key_value_consult ->
            {ok,RecList} = file:consult(FilePath),
            KeyValues = RecList,
            ValList = RecList;
        true ->
            {ok,[RecList]} = file:consult(FilePath),
            KeyValues = RecList,
            ValList = RecList
    end,
    Src = common_config_code:gen_src(ConfigModuleName,KeyType,KeyValues,ValList),
    file:write_file(lists:concat(["/data/mtzr/config/src/", ConfigModuleName, ".erl"]), Src, [write, binary, {encoding, utf8}]),
    ok.

do_load_config({_AtomName,ConfigModuleName,FilePath,record_consult, Type}) ->
    {ok,RecList} = file:consult(FilePath),
    KeyValues = [ begin
                      Key = element(2,Rec), {Key,Rec}
                  end || Rec<- RecList ],
    ValList = RecList,
    do_load_gen_src(ConfigModuleName,Type,KeyValues,ValList);

do_load_config({_AtomName,ConfigModuleName,FilePath,record_list, Type}) ->
    {ok,[RecList]} = file:consult(FilePath),
    KeyValues = [ begin
                      Key = element(2,Rec), {Key,Rec}
                  end || Rec<- RecList ],
    ValList = RecList,
    do_load_gen_src(ConfigModuleName,Type,KeyValues,ValList);

do_load_config({_AtomName,ConfigModuleName,FilePath,key_value_consult, Type})->
    {ok,RecList} = file:consult(FilePath),
    KeyValues = RecList,
    ValList = RecList,
    do_load_gen_src(ConfigModuleName,Type,KeyValues,ValList);

do_load_config({_AtomName,ConfigModuleName,FilePath,key_value_list, Type})->
    {ok,[RecList]} = file:consult(FilePath),
    KeyValues = RecList,
    ValList = RecList,
    do_load_gen_src(ConfigModuleName,Type,KeyValues,ValList).

%%@doc 生成源代码，执行编译并load
do_load_gen_src(ConfigModuleName,Type,KeyValues,ValList)->
    try
        Src = common_config_code:gen_src(ConfigModuleName,Type,KeyValues,ValList),
        {Mod, Code} = dynamic_compile:from_string( Src ),
        code:load_binary(Mod, ConfigModuleName ++ ".erl", Code),
        {ok, Code}
    catch
        Type:Reason -> 
            Trace = erlang:get_stacktrace(), string:substr(erlang:get_stacktrace(), 1,200),
            ?CRITICAL_MSG("Error compiling ~p: Type=~w,Reason=~w,Trace=~w,~n", [ConfigModuleName, Type, Reason,Trace ])
    end.
