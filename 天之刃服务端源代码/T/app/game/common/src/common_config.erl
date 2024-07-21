%%%-------------------------------------------------------------------
%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 27 Jun 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_config).

-include("common.hrl").

%% API
-export([
         is_debug_sql/0,
         get_host_info/0,
         get_system_info/0,
         get_system_info/1,
         get_line_start_port/0,
         get_line_acceptor_num/0,
         get_login_port/0,
         get_login_acceptor_num/0,
         get_receiver_http_host/0,
         get_receiver_host/0,
         get_chat_config/0,
         get_root_config_file_path/1,
         get_map_config_dir/0,
         get_world_config_file_path/1,
         get_map_config_file_path/1,
         get_map_jump_config/0,
         get_event_config/0,
         get_mysql_config/0,
         get_warofking_config/0,
         is_debug/0,
         get_map_info_config/0,
         get_not_persistent_table_list/0,
         get_mission_setting/0,
         get_mission_file_path/0,
         get_behavior_node_name/0,
         get_relive_config/0,
         get_db_node_name/0,
         get_levelexps/0,
         get_map_slave_num/0,
         get_map_slave_weight_list/0,
         get_receiver_host_acceptor_num/0,
         get_level_channel_list/0,
         get_open_day/0,
         get_opened_days/0,
         is_fcm_open/0,
         get_driver_config/0,
         is_open_vie_world_fb/0,
         get_agent_name/0,
         get_game_id/0,
         get_line_auth_key/0,
         get_fcm_validation_key/0,
         get_fcm_validation_url/0,
         chk_module_method_open/2,
         get_map_master_ip/0,
         get_map_slaves/0,
         is_activity_pay_first_open/0,
         set_activity_pay_first_flag/1,
         is_client_stat_open/0,
         get_log_level/0,
         get_super_key/0
        ]).

-define(MGE_ROOT, "/data/tzr/server/").


get_super_key() ->
    [Val] = common_config_dyn:find_common(line_super_key),
    Val.    

get_log_level() ->
    [Val] = common_config_dyn:find_common(log_level),
    Val.

%% 是否活动是否打开了
is_activity_pay_first_open() ->
    case db:dirty_read(?DB_CONFIG_SYSTEM_P, open_pay_first) of
        [] ->
            false;
        [#r_config_system{value=Value}] ->
            case Value of
                true ->
                    true;
                _ ->
                    false
            end
    end.

%% 控制首充活动开关
set_activity_pay_first_flag(Flag) ->
    case Flag of
        true ->
            db:transaction(
              fun() ->
                      db:write(?DB_CONFIG_SYSTEM_P, {r_config_system, open_pay_first, true}, write)
              end);
        _ ->
            db:transaction(
              fun() ->
                      db:write(?DB_CONFIG_SYSTEM_P, {r_config_system, open_pay_first, false}, write)
              end)
    end.


%% 活动地图主节点的ip地址
get_map_master_ip() ->
    {ok, List} = file:consult("/data/tzr/server/setting/host_info.config"),
    proplists:get_value(game_host, List).

%% 或者地图分布式slave机器列表
get_map_slaves() ->
    {ok, List} = file:consult("/data/tzr/server/setting/host_info.config"),
    lists:delete('127.0.0.1', proplists:get_value(map_slave, List)).

%% 判断某个模块是否打开了
chk_module_method_open(Module, Method) ->
    case common_config_dyn:find(module_method_open, Module) of
        [] ->
            {false, "该功能维护中，详情请见官方公告"};
        [{Flag, Reason}] ->
            case Flag of
                true ->
                    case common_config_dyn:find(module_method_open, {Module, Method}) of
                        [] ->
                            {false, "该功能维护中，详情请见官方公告"};
                        [{Flag2, Reason2}] ->
                            case Flag2 of
                                true ->
                                    true;
                                false ->
                                    {false, Reason2}
                            end
                    end;
                false ->
                    {false, Reason}
            end
    end.


%% 获取防沉迷验证的地址
get_fcm_validation_url() ->
    [Val] = common_config_dyn:find_common(fcm_validation_url),
    Val.

get_fcm_validation_key() ->
    [Val] = common_config_dyn:find_common(fcm_validation_key),
    Val.

%% 获取代理商名字    
get_agent_name() ->
    [Val] = common_config_dyn:find_common(agent_name),
    Val.

%% 获取游戏服ID
get_game_id() ->
    [Val] = common_config_dyn:find_common(game_id),
    Val.


%% 获取开服日志 {{Year, Month, Day}, {Hour, Min, Sec}}
get_open_day() ->
    [Val] = common_config_dyn:find_common(server_start_datetime),
    Val.

%% 获得当前为开服第几天，如果今天是6月28日，开服日期为6月28日，则今天为开服第一天，返回1
get_opened_days() ->
    [{Date, _}] = common_config_dyn:find_common(server_start_datetime),
    {Date2, _} = erlang:localtime(),
    erlang:abs( calendar:date_to_gregorian_days(Date) - calendar:date_to_gregorian_days(Date2) ) + 1.
    
is_open_vie_world_fb() ->
    [Val] = common_config_dyn:find(etc,is_open_vie_world_fb),
    Val.

%% 判断防沉迷是否打开，直接从数据库中读取
is_fcm_open() ->
    case db:dirty_read(?DB_CONFIG_SYSTEM_P, fcm) of
        [] ->
            false;
        [#r_config_system{value=Value}] ->
            case Value of
                true ->
                    true;
                _ ->
                    false
            end
    end.

%%@doc 设置为true可以输出erlang的sql语句
is_debug_sql()->
    false.


is_debug() ->
    [Val] = common_config_dyn:find(common, is_debug),
    Val.

get_line_auth_key() ->
    [Val] = common_config_dyn:find(common, line_auth_key),
    Val.

get_receiver_host_acceptor_num() ->
    [Val] = common_config_dyn:find_common(receiver_host_acceptor_num),
    Val.

    
get_map_slave_num() ->
    HostInfoConfig = get_host_info(),
    case lists:keyfind(map_slave_num, 1, HostInfoConfig) of
        {map_slave_num, SlaveNum} when is_integer(SlaveNum)->
            SlaveNum;
        _ ->
            3
    end.

get_map_slave_weight_list() ->   
    HostInfoConfig = get_host_info(),
    lists:foldl(
      fun(Item, Result) ->
              Name = erlang:element(1, Item),
              case Name of
                  map_slave_weight -> 
                      [Item|Result];
                  _ ->
                      Result
              end
      end, [], HostInfoConfig).

get_levelexps() ->
    {ok, [LevelExps]} = file:consult(lists:concat([?MGE_ROOT, "config/level.config"])),
    LevelExps.


get_relive_config() ->
    {ok, [List]} = file:consult(lists:concat([?MGE_ROOT, "config/relive.config"])),
    List.

get_not_persistent_table_list() ->
    {ok, TableList} = file:consult(lists:concat([?MGE_ROOT, "config/not_persistent_table.config"])),
    TableList.


%%读取事件配置文件
get_event_config() ->
    EventConfigFile = lists:concat([?MGE_ROOT, "config/event.config"]),
    {ok, EventConfig} = file:consult(EventConfigFile),
    EventConfig.

get_warofking_config() ->
    Config = ?MODULE:get_event_config(),
    proplists:get_value(mod_event_warofking, Config).


get_mysql_config() ->
    [Val] = common_config_dyn:find_common(mysql_config),
    Val.

%%获得当前所有分线的配置信息
get_host_info() ->
    HostInfoConfigFile = lists:concat([?MGE_ROOT, "setting/host_info.config"]),
    {ok, HostInfoConfig} = file:consult(HostInfoConfigFile),
    HostInfoConfig.

%%获得新的系统配置信息
get_system_info() ->
    SysInfoConfigFile = lists:concat([?MGE_ROOT, "config/system/system_info.config"]),
    {ok, SysInfoConfig} = file:consult(SysInfoConfigFile),
    SysInfoConfig.

get_system_info(Key) ->
    SysConfig = get_system_info(),
    {Key, KeyVal} = lists:keyfind(Key, 1, SysConfig),
    KeyVal. 

get_login_port() ->
    HostInfoConfig = get_host_info(),
    {login_port, LoginPort} = lists:keyfind(login_port, 1, HostInfoConfig),
    LoginPort.

get_login_acceptor_num() ->
    HostInfoConfig = get_host_info(),
    {login_acceptor_num, LoginAcceptorNum} = lists:keyfind(login_acceptor_num, 1, HostInfoConfig),
    LoginAcceptorNum.

get_line_start_port() ->
    HostInfoConfig = get_host_info(),
    {line_start_port, LineStartPort} = lists:keyfind(line_start_port, 1, HostInfoConfig),
    LineStartPort.

get_line_acceptor_num() ->
    HostInfoConfig = get_host_info(),
    {line_acceptor_num, LineAcceptorNum} = lists:keyfind(line_acceptor_num, 1, HostInfoConfig),
    LineAcceptorNum.

get_receiver_host() ->
    RecvHostList = common_config_dyn:find_common(receiver_host),
    lists:foldl(
      fun(RecvHost,Result)->
              {Host,Post} = RecvHost,
              [{receiver_host,Host,Post}|Result]
              end, [], RecvHostList).

get_receiver_http_host() ->
    HostInfoConfig = get_host_info(),
    lists:keyfind(receiver_web, 1, HostInfoConfig).
   
get_behavior_node_name() ->
    HostInfoConfig = get_host_info(),
    {behavior_node, BehaviorNodeName} = lists:keyfind(behavior_node, 1, HostInfoConfig),
    BehaviorNodeName.
     
get_db_node_name() ->
    lists:foldl(
      fun(Node, Acc) ->
              case erlang:atom_to_list(Node) of
                  "mgeed" ++ _ ->
                      Node;
                  _ ->
                      Acc
              end
      end, erlang:node(), [erlang:node() | erlang:nodes()]).


get_chat_config() ->
    HostInfoConfig = get_host_info(),
    lists:keyfind(chat_config, 1, HostInfoConfig).
get_root_config_file_path(ConfigName) ->
    lists:concat([?MGE_ROOT,"config/", ConfigName ,".config"]).
get_map_config_dir() ->
    lists:concat([?MGE_ROOT, "config/map/mcm/"]).
get_map_config_file_path(monster) ->
    lists:concat([?MGE_ROOT, "config/monster/monster.config"]);
get_map_config_file_path(boss_ai) ->
    lists:concat([?MGE_ROOT, "config/monster/boss_ai.config"]);
get_map_config_file_path(shop_npcs) ->
    lists:concat([?MGE_ROOT, "config/world/shop_npcs.config"]);
get_map_config_file_path(shop_price_time) ->
    lists:concat([?MGE_ROOT, "config/world/shop_price_time.config"]);
get_map_config_file_path(shop_shops) ->
    lists:concat([?MGE_ROOT, "config/world/shop_shops.config"]);
get_map_config_file_path(shop_test) ->
    lists:concat([?MGE_ROOT, "config/world/shop_test.config"]);
get_map_config_file_path(collect) ->
    lists:concat([?MGE_ROOT, "config/map/collect_base_info.config"]);
get_map_config_file_path(server_npc_born) ->
    lists:concat([?MGE_ROOT, "config/monster/server_npc_born.config"]);
get_map_config_file_path(server_npc) ->
    lists:concat([?MGE_ROOT, "config/monster/server_npc.config"]);
get_map_config_file_path(vwf_monster) ->
    lists:concat([?MGE_ROOT, "config/monster/vie_world_fb_monster.config"]);
get_map_config_file_path(country_treasure) ->
    lists:concat([?MGE_ROOT, "config/map/country_treasure.config"]);
get_map_config_file_path(ConfigName) ->
    lists:concat([?MGE_ROOT,"config/map/", ConfigName ,".config"]).

  
%% 获得地图跳转点信息
get_map_jump_config() ->  
    FilePath = lists:concat([?MGE_ROOT, "config/map_jump.config"]),
    {ok, JumpList} = file:consult(FilePath),
    JumpList.

get_level_channel_list() ->
    FilePath = lists:concat([?MGE_ROOT, "config/level_channel.config"]),
    {ok, LevelChannelList} = file:consult(FilePath),
    LevelChannelList.

get_driver_config() ->
    FilePath = lists:concat([?MGE_ROOT, "config/driver.config"]),
    {ok, ConfigList} = file:consult(FilePath),
    ConfigList.
   
get_mission_file_path() ->
    lists:concat([?MGE_ROOT, "config/mission/"]).

%% 所有world模块配置文件路径
get_world_config_file_path(broadcast_admin) ->
    lists:concat([?MGE_ROOT, "config/world/broadcast_admin_data.config"]);
get_world_config_file_path(broadcast) ->
    lists:concat([?MGE_ROOT, "config/world/broadcast.config"]);
get_world_config_file_path(rank_info) ->
    lists:concat([?MGE_ROOT, "config/world/ranking/rank_info.config"]);
get_world_config_file_path(training) ->
    lists:concat([?MGE_ROOT, "config/world/training_exp.config"]);
get_world_config_file_path(bighpmp) ->
    lists:concat([?MGE_ROOT, "config/world/big_hp_mp.config"]);
get_world_config_file_path(ConfigName) ->
    lists:concat([?MGE_ROOT,"config/world/", ConfigName ,".config"]).

get_map_info_config() ->
    ConfigFile = lists:concat([?MGE_ROOT, "config/map_info.config"]),
    {ok, List} = file:consult(ConfigFile),
    List.

get_mission_setting() ->
    MissionDataDir = get_mission_file_path(),
    {ok, DataList} = file:consult(MissionDataDir ++ "mission_setting.config"),
    DataList.

is_client_stat_open()->
	case common_config_dyn:find(stat,button) of
		[true]->true;
		_->false
	end.
		
