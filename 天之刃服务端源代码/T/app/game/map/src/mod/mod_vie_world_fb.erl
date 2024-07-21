%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2010, 
%%% @doc
%%% 逐鹿天下副本模块代码
%%% @end
%%% Created : 16 Nov 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_vie_world_fb).

-include("mgeem.hrl").
-include("vie_world_fb.hrl").

-export([
         %% 初始化相关数据
         init_ets/0,
         %% 初始化地图数据
         init_map_data/2,
         %% 处理副本请求消息
         do_handle_info/1,handle/1,
         %% 获取逐鹿天下副本Server NPC id
         get_vwf_server_npc_ids/0,
         %% 判断当前时间是否需要显示Server NPC 
         %% 判断当前时间是否需要隐藏Server NPC
         %% 返回true需要显示，返回false即不需要显示
         is_now_time_vwf_show/1,
         %% 逐鹿天下副本地图入口信息
         get_vwf_map_enter_info/0,
         %% 玩家在副本下线，当副本地图关闭时重新登录处理
         do_role_re_login_vwf/1,
         %% 当玩家退出队伍时，或掉线重新上线时已经不在队伍中时处理
         do_hook_team_change/2,
         %% 根据当前时间判断是否需要显示讨伐敌营副本Server Npc
         %% 返回结果 true,开启，false
         check_now_open_vie_world_fb/0
        ]).

%%%===================================================================
%%% API
%%%===================================================================
handle(Info) ->
    do_handle_info(Info).


init_ets() ->
    ets:new(?ETS_SERVER_NPC_BORN, [protected, named_table, bag]),
    ServerNpcBornFile = common_config:get_map_config_file_path(server_npc_born),
    case file:consult(ServerNpcBornFile) of
        {ok, ServerNpcBornList} ->
            ets:insert(?ETS_SERVER_NPC_BORN, ServerNpcBornList);
        _ ->
            ?ERROR_MSG("~ts ConfigFile=~w",["读取Server NPC 出生点配置文件出错",ServerNpcBornFile])
    end,
    
    ets:new(?ETS_VIE_WORLD_FB_MONSTER, [protected, named_table, set,{keypos, 2}]),
    VWFMonsterFile = common_config:get_map_config_file_path(vwf_monster),
    case file:consult(VWFMonsterFile) of
        {ok, VWFMonsterList} ->
            ets:insert(?ETS_VIE_WORLD_FB_MONSTER, VWFMonsterList);
        _ ->
            ?ERROR_MSG("~ts ConfigFile=~w",["读取逐鹿天下怪物出生点配置文件出错",VWFMonsterFile])
    end.

%% 初始化地图数据
init_map_data(MapId,MapProcessName) ->
    [IsOpenVWF] = common_config_dyn:find(etc,is_open_vie_world_fb),
    case IsOpenVWF of
        true ->
            VWFMapIds = get_vwf_show_server_npc_map(),
            ?DEBUG("~ts,MapId=~w,VWFMapIds=~w",["需要被始化讨伐敌营入口副本的地图",MapId,VWFMapIds]),
            case lists:member(MapId,VWFMapIds) of
                true ->
                    init_map_data2(MapId,MapProcessName);
                false ->
                    ?DEV("~ts,MapId=~w",["不属于讨伐敌营副本入口地图",MapId]),
                    ignore
            end;
        _ ->
            ?INFO_MSG("~ts",["配置文件中设置不开启讨伐敌营副本"]),
            ignore
    end.
init_map_data2(MapId,MapProcessName) ->
    ServerNpcList = mod_server_npc:get_map_server_npc_data(MapId,?SERVER_NPC_TYPE_VWF),
    ?DEBUG("~ts,MapId=~w,ServerNpcList=~w",["调试信息获取此地图的ServerNPCData",MapId,ServerNpcList]),
    mod_server_npc:init_map_server_npc(MapProcessName, MapId, ServerNpcList, ?SERVER_NPC_CREATE_TYPE_NORMAL),
    set_vie_world_fb_init_status().

%% 设置地图已经初始化逐鹿天下副本Server NPC数据
set_vie_world_fb_init_status() ->
    erlang:put(vie_world_fb_status,?VIE_WORLD_FB_STATUS_INIT).

%% 显示Server NPC 操作消息处理
do_handle_info({show_vwf_server_npc}) ->
    do_show_vwf_server_npc();

%% 消失Server NPC 操作消息处理
do_handle_info({hide_vwf_server_npc}) ->
    do_hide_vwf_server_npc();

%% 逐鹿天下副本Server NPC定时消息处理
do_handle_info({work}) ->
    do_work();

%% 逐鹿天下副本怪物初始化消息处理
do_handle_info({init_vwf_monster,MonsterList,MonsterType,MonsterLevel}) ->
    %% ?DEBUG("~ts,MonsterList=~w,MonsterType=~w,MonsterLevel=~w",["接收到初始化逐鹿天下副本地图怪物数据",MonsterList,MonsterType,MonsterLevel]),
    %% Length = erlang:length(MonsterList),
    %% ?ERROR_MSG("~ts,MonsterType=~w,MonsterLevel=~w,MonsterNumber=~w",["接收到初始化讨伐敌营副本怪物的消息",MonsterType,MonsterLevel,Length]),
    do_init_vwf_monster(MonsterList,MonsterType,MonsterLevel);

%% 普通怪物死亡
do_handle_info({normal_monster_dead,MonsterLevel}) ->
    do_normal_monster_dead(MonsterLevel);
%% 精英怪物死亡
do_handle_info({other_monster_dead}) ->
    other_monster_dead();

%% 关闭副本消息处理
do_handle_info({vwf_close,MaxInterval}) ->
    do_vwf_close(MaxInterval);

%% 副本开启前或副本结束前发送的消息处理
%% Type 为 start副本开启,stop 副本结束
%% Time 结构为 erlang:time
%% BeforeSeconds 提前时间，单位为秒
do_handle_info({vwf_message_broadcast,Type,BeforeSeconds,Time}) ->
    do_vwf_message_broadcast(Type,BeforeSeconds,Time);

%% 记录创建此副本地图的地图信息
do_handle_info({create_vwf_map_parent_map_id,ParentMapId,NpcTypeId,LeaderRoleId,VWFRoleList,MonsterLevel}) ->
    do_create_vwf_map_parent_map_id(ParentMapId,NpcTypeId,LeaderRoleId,VWFRoleList,MonsterLevel);

%% 退出副本进程消息处理
do_handle_info({vwf_exit}) ->
    do_vwf_exit();
do_handle_info({kill_vwf_map}) ->
    common_map:exit( vwf_map_close );

%% 副本最长时间关闭处理
do_handle_info({max_hold_time}) ->
    ?INFO_MSG("~ts",["接收到关闭副本的消息"]),
    do_max_hold_time();

%% 副本延迟发送的消息
do_handle_info({vwf_delay_send_message,RoleId}) ->
    ?INFO_MSG("~ts",["副本延迟发送的消息处理"]),
    do_vwf_delay_send_message(RoleId);

%% 玩家请求进入逐鹿天下副本
do_handle_info({Unique, ?VIE_WORLD_FB, ?VIE_WORLD_FB_ENTER, DataRecord, RoleId, Line}) 
  when erlang:is_record(DataRecord,m_vie_world_fb_enter_tos)->
    do_vwf_enter({Unique, ?VIE_WORLD_FB, ?VIE_WORLD_FB_ENTER, DataRecord, RoleId, Line});

%% 异步创建地图处理
do_handle_info({create_map_succ, Key}) ->
    do_create_fb_succ(Key);

%% 玩家请求从逐鹿天下副本退出
do_handle_info({Unique, ?VIE_WORLD_FB, ?VIE_WORLD_FB_QUIT, DataRecord, RoleId, Line})->
    do_vwf_quit({Unique, ?VIE_WORLD_FB, ?VIE_WORLD_FB_QUIT, DataRecord, RoleId, Line});

%% 后台管理 显示Server NPC 操作消息处理
%% 间隔时间 Interval 分钟
do_handle_info({admin_show_vwf_server_npc,Interval}) ->
    do_admin_show_vwf_server_npc(Interval);

%% 后台管理 消失Server NPC 操作消息处理
do_handle_info({admin_hide_vwf_server_npc}) ->
    do_admin_hide_vwf_server_npc();

do_handle_info(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["逐鹿天下副本模块无法处整此消息",Info]),
    error.





%% 显示Server NPC 操作消息处理
do_show_vwf_server_npc() ->
    ServerNpcIds = mod_server_npc:get_server_npc_id_list(),
    do_show_vwf_server_npc2(ServerNpcIds).

do_show_vwf_server_npc2(ServerNpcIds) ->
    VieWorldServerNpcIds = get_vwf_server_npc_ids(),
    ServerNpcStateList = 
        lists:foldl(
          fun(ServerNpcId,Acc) ->
                  case mod_server_npc:get_server_npc_state(ServerNpcId) of
                      undefined ->
                          Acc;
                      ServerNpcState ->
                          [ServerNpcState|Acc]
                  end
          end,[],ServerNpcIds),
    ServerNpcStateList2 = 
        lists:foldl(
          fun(RState,Acc) ->
                  RNpc = RState#server_npc_state.server_npc_info,
                  RTypeId = RNpc#p_server_npc.type_id,
                  case lists:member(RTypeId,VieWorldServerNpcIds) of
                      true ->
                          [RState| Acc];
                      false ->
                          Acc
                  end
          end,[],ServerNpcStateList),
    ServerNpcStateList3 = get_show_npc_id_by_online_num(ServerNpcStateList2),
    if erlang:length(ServerNpcStateList3) > 0 ->
            do_show_vwf_server_npc3(ServerNpcStateList3);
       true ->
            ?DEBUG("~ts,VieWorldServerNpcId=~w,ServerNpcStateList=~w",["没有逐鹿天下副本的ServerNPC需要处理",VieWorldServerNpcIds,ServerNpcStateList]),
            ignore
    end.
do_show_vwf_server_npc3(ServerNpcStateList) ->
    NowDate = erlang:date(),
    NowTime = erlang:time(),
    MapState = mgeem_map:get_state(),
    lists:foreach(
      fun(ServerNpcState) ->
              #server_npc_state{server_npc_info = ServerNpcInfo} = ServerNpcState,
              MapServerNpc = #p_map_server_npc{
                npc_id = ServerNpcInfo#p_server_npc.npc_id,
                type_id = ServerNpcInfo#p_server_npc.type_id,
                npc_name = ServerNpcInfo#p_server_npc.npc_name,
                npc_type = ServerNpcInfo#p_server_npc.npc_type,
                state = ?GUARD_STATE,
                max_mp= ServerNpcInfo#p_server_npc.max_mp,
                max_hp = ServerNpcInfo#p_server_npc.max_hp,
                map_id = ServerNpcInfo#p_server_npc.map_id,
                pos = ServerNpcInfo#p_server_npc.reborn_pos,
                mp= ServerNpcInfo#p_server_npc.max_mp,
                hp = ServerNpcInfo#p_server_npc.max_hp,
                npc_country = ServerNpcInfo#p_server_npc.npc_country,
                is_undead = ServerNpcInfo#p_server_npc.is_undead,
                move_speed = ServerNpcInfo#p_server_npc.move_speed
               },
              ServerNpcInfo2 = ServerNpcInfo#p_server_npc{state = ?GUARD_STATE},
              ServerNpcState2 = ServerNpcState#server_npc_state{server_npc_info = ServerNpcInfo2},
              MapServerNpcId = MapServerNpc#p_map_server_npc.npc_id,
              case mod_map_actor:enter(?DEFAULT_UNIQUE, MapServerNpcId, MapServerNpcId, 
                                       server_npc, MapServerNpc, 0, MapState) of
                  ok ->
                      put({server_npc_state,MapServerNpcId},ServerNpcState2);
                  _ ->
                      ?INFO_MSG("~ts,MapServerNpc=~w",["此逐鹿天下副本无法在地图显示",MapServerNpc]),
                      ignore
              end
      end,ServerNpcStateList),
    {stop,StopInterval,_StopTime} = get_next_do_work_interval(stop,NowDate,NowTime),
    erlang:send_after(StopInterval,self(),{mod_vie_world_fb,{hide_vwf_server_npc}}),
    #map_state{mapid = MapId} = MapState,
    SendMsgMapIds = get_random_vwf_show_server_npc_map_id(),
    case lists:member(MapId,SendMsgMapIds) of
        true ->
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,?_LANG_VIE_WORLD_FB_BC_MSG_START_CENTER),
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,?_LANG_VIE_WORLD_FB_BC_MSG_START_LEFT);
        false ->
            ignore
    end,
    ok.

%% 消失Server NPC 操作消息处理
do_hide_vwf_server_npc() ->
    ServerNpcIds = mod_server_npc:get_server_npc_id_list(),
    do_hide_vwf_server_npc2(ServerNpcIds).

do_hide_vwf_server_npc2(ServerNpcIds) ->
    VieWorldServerNpcIds = get_vwf_server_npc_ids(),
    ServerNpcStateList = 
        lists:foldl(
          fun(ServerNpcId,Acc) ->
                  case mod_server_npc:get_server_npc_state(ServerNpcId) of
                      undefined ->
                          Acc;
                      ServerNpcState ->
                          [ServerNpcState|Acc]
                  end
          end,[],ServerNpcIds),
    ServerNpcStateList2 = 
        lists:foldl(
          fun(RState,Acc) ->
                  RNpc = RState#server_npc_state.server_npc_info,
                  RTypeId = RNpc#p_server_npc.type_id,
                  case lists:member(RTypeId,VieWorldServerNpcIds) of
                      true ->
                          [RState| Acc];
                      false ->
                          Acc
                  end
          end,[],ServerNpcStateList),
    if erlang:length(ServerNpcStateList2) > 0 ->
            do_hide_vwf_server_npc3(ServerNpcStateList2);
       true ->
            ?DEBUG("~ts,VieWorldServerNpcId=~w,ServerNpcStateList=~w",["没有逐鹿天下副本的ServerNPC需要处理",VieWorldServerNpcIds,ServerNpcStateList]),
            ignore
    end.
do_hide_vwf_server_npc3(ServerNpcStateList) ->
    NowDate = erlang:date(),
    NowTime = erlang:time(),
    MapState = mgeem_map:get_state(),
    lists:foreach(
      fun(ServerNpcState) ->
              #server_npc_state{server_npc_info = ServerNpcInfo} = ServerNpcState,
              MapServerNpc = #p_map_server_npc{
                npc_id = ServerNpcInfo#p_server_npc.npc_id,
                type_id = ServerNpcInfo#p_server_npc.type_id,
                npc_name = ServerNpcInfo#p_server_npc.npc_name,
                npc_type = ServerNpcInfo#p_server_npc.npc_type,
                state = ?DEAD_STATE,
                max_mp= ServerNpcInfo#p_server_npc.max_mp,
                max_hp = ServerNpcInfo#p_server_npc.max_hp,
                map_id = ServerNpcInfo#p_server_npc.map_id,
                pos = ServerNpcInfo#p_server_npc.reborn_pos,
                mp= ServerNpcInfo#p_server_npc.max_mp,
                hp = ServerNpcInfo#p_server_npc.max_hp,
                npc_country = ServerNpcInfo#p_server_npc.npc_country,
                is_undead = ServerNpcInfo#p_server_npc.is_undead,
                move_speed = ServerNpcInfo#p_server_npc.move_speed
               },
              ServerNpcInfo2 = ServerNpcInfo#p_server_npc{state = ?DEAD_STATE},
              ServerNpcState2 = ServerNpcState#server_npc_state{server_npc_info = ServerNpcInfo2},
              MapServerNpcId = MapServerNpc#p_map_server_npc.npc_id,
              mod_map_actor:do_quit(MapServerNpcId, server_npc, MapState),
              put({server_npc_state,MapServerNpcId},ServerNpcState2)
      end,ServerNpcStateList),
    {start,StartInterval,StartTime} = get_next_do_work_interval(start,NowDate,NowTime),
    BeforeInterval = get_vwf_start_before_broadcast_seconds(),
    BeforeInterval2 = 
        if StartInterval - (BeforeInterval * 1000) > 0->
                StartInterval - (BeforeInterval * 1000);
           true ->
                1000
        end,
    erlang:send_after(StartInterval,self(),{mod_vie_world_fb,{show_vwf_server_npc}}),
    #map_state{mapid = MapId} = MapState,
    SendMsgMapIds = get_random_vwf_show_server_npc_map_id(),
    case lists:member(MapId,SendMsgMapIds) of
        true ->
            erlang:send_after(BeforeInterval2,self(),{mod_vie_world_fb,{vwf_message_broadcast,start,BeforeInterval,StartTime}}),
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,?_LANG_VIE_WORLD_FB_BC_MSG_END_CENTER),
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,?_LANG_VIE_WORLD_FB_BC_MSG_END_LEFT);
        false ->
            ignore
    end,
    ok.
%% 处理逐鹿天下副本定时循环消息
do_work() ->
    case get(vie_world_fb_status) of
        undefined ->
            ?DEV("~ts",["此地图中没有ServerNPC的数据，不需要处理A"]),
            ignore;
        ?VIE_WORLD_FB_STATUS_INIT ->
            case check_now_open_vie_world_fb() of
                true ->
                    %% 需要处理
                    ?DEBUG("~ts",["此地图需要初始过ServerNPC的处理数据1"]),
                    put(vie_world_fb_status,?VIE_WORLD_FB_STATUS_RUNNING),
                    do_work2();
                false ->
                    ?DEV("~ts",["当前时间讨伐副本不需要处理，没有到时间开放"]),
                    ignore
            end;
        ?VIE_WORLD_FB_STATUS_RUNNING ->
            %% 已经处理过，不需要再处理
            ?DEV("~ts",["此地图已经初始过ServerNPC的数据，不需要处理B"]),
            ignore
    end.
do_work2() ->
    ServerNpcIds = mod_server_npc:get_server_npc_id_list(),
    do_work3(ServerNpcIds).

do_work3(ServerNpcIds) ->
    ?DEBUG("server_npc,~ts,ServerNpcIds=~w",["ServerNPC 调试",ServerNpcIds]),
    VieWorldServerNpcIds = get_vwf_server_npc_ids(),
    ?DEBUG("~ts,VieWorldServerNpcIds=~w",["ServerNPC 调试",VieWorldServerNpcIds]),
    ServerNpcStateList = 
        lists:foldl(
          fun(ServerNpcId,Acc) ->
                  case mod_server_npc:get_server_npc_state(ServerNpcId) of
                      undefined ->
                          Acc;
                      ServerNpcState ->
                          [ServerNpcState|Acc]
                  end
          end,[],ServerNpcIds),
    VieServerNpcList = 
        lists:foldl(
          fun(RState,Acc) ->
                  RNpc = RState#server_npc_state.server_npc_info,
                  RTypeId = RNpc#p_server_npc.type_id,
                  case lists:member(RTypeId,VieWorldServerNpcIds) of
                      true ->
                          [RState| Acc];
                      false ->
                          Acc
                  end
          end,[],ServerNpcStateList),
    if erlang:length(VieServerNpcList) > 0 ->
            do_work4(VieServerNpcList);
       true ->
            ?DEBUG("~ts,VieWorldServerNpcId=~w,ServerNpcStateList=~w",
                   ["没有逐鹿天下副本的ServerNPC需要处理",VieWorldServerNpcIds,ServerNpcStateList]),
            ignore
    end.
do_work4(VieServerNpcList) ->
    ?DEBUG("~ts,VieServerNpcList=~w",["ServerNPC 调试",VieServerNpcList]),
    NowDate = erlang:date(),
    NowTime = erlang:time(),
    case is_now_time_vwf_show(NowTime) of
        true ->
            ?DEBUG("~ts",["此次重起需要处理Server NPC 显示"]),
            %% 显示处理，并计算下次处理时间
            MapState = mgeem_map:get_state(),
            lists:foreach(
              fun(ServerNpcState) ->
                      #server_npc_state{server_npc_info = ServerNpcInfo} = ServerNpcState,
                      MapServerNpc = #p_map_server_npc{
                        npc_id = ServerNpcInfo#p_server_npc.npc_id,
                        type_id = ServerNpcInfo#p_server_npc.type_id,
                        npc_name = ServerNpcInfo#p_server_npc.npc_name,
                        npc_type = ServerNpcInfo#p_server_npc.npc_type,
                        state = ?GUARD_STATE,
                        max_mp= ServerNpcInfo#p_server_npc.max_mp,
                        max_hp = ServerNpcInfo#p_server_npc.max_hp,
                        map_id = ServerNpcInfo#p_server_npc.map_id,
                        pos = ServerNpcInfo#p_server_npc.reborn_pos,
                        mp= ServerNpcInfo#p_server_npc.max_mp,
                        hp = ServerNpcInfo#p_server_npc.max_hp,
                        npc_country = ServerNpcInfo#p_server_npc.npc_country,
                        is_undead = ServerNpcInfo#p_server_npc.is_undead,
                        move_speed = ServerNpcInfo#p_server_npc.move_speed
                       },
                      ServerNpcInfo2 = ServerNpcInfo#p_server_npc{state = ?GUARD_STATE},
                      ServerNpcState2 = ServerNpcState#server_npc_state{server_npc_info = ServerNpcInfo2},
                      MapServerNpcId = MapServerNpc#p_map_server_npc.npc_id,
                      case mod_map_actor:enter(?DEFAULT_UNIQUE, MapServerNpcId, MapServerNpcId, 
                                               server_npc, MapServerNpc, 0, MapState) of
                          ok ->
                              put({server_npc_state,MapServerNpcId},ServerNpcState2);
                          _ ->
                              ?INFO_MSG("~ts,MapServerNpc=~w",["此逐鹿天下副本无法在地图显示",MapServerNpc]),
                              ignore
                      end
              end,VieServerNpcList),
            {stop,StopInterval,_StopTime} = get_next_do_work_interval(stop,NowDate,NowTime),
            erlang:send_after(StopInterval,self(),{mod_vie_world_fb,{hide_vwf_server_npc}}),
            #map_state{mapid = MapId} = MapState,
            SendMsgMapIds = get_random_vwf_show_server_npc_map_id(),
            case lists:member(MapId,SendMsgMapIds) of
                true ->
                    %% 发送广播消息
                    catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,?_LANG_VIE_WORLD_FB_BC_MSG_START_CENTER),
                    catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,?_LANG_VIE_WORLD_FB_BC_MSG_START_LEFT);
                false ->
                    ignore
            end,
            ok;
        false ->
            %% 不需要处理，但需要计算下次处理时间
            ?DEBUG("~ts",["此次重起不需要处理Server NPC 显示"]),
            {start,StartInterval,StartTime} = get_next_do_work_interval(start,NowDate,NowTime),
            BeforeInterval = get_vwf_start_before_broadcast_seconds(),
            BeforeInterval2 = 
                if StartInterval - (BeforeInterval * 1000) > 0->
                        StartInterval - (BeforeInterval * 1000);
                   true ->
                        1000
                end,
            MapState = mgeem_map:get_state(),
            #map_state{mapid = MapId} = MapState,
            SendMsgMapIds = get_random_vwf_show_server_npc_map_id(),
            case lists:member(MapId,SendMsgMapIds) of
                true ->
                    erlang:send_after(BeforeInterval2,self(),{mod_vie_world_fb,{vwf_message_broadcast,start,BeforeInterval,StartTime}});
                false ->
                    ignore
            end,
            erlang:send_after(StartInterval,self(),{mod_vie_world_fb,{show_vwf_server_npc}}),
            ignore
    end.
%% 初始化逐鹿天下副本怪物数据
%% MonsterList 结构为[p_monster,p_monster,..]
do_init_vwf_monster(MonsterList,MonsterType,MonsterLevel) ->
    MapState = mgeem_map:get_state(),
    #map_state{mapid = MapId, map_name = MapProcessName} = MapState,
    MonsterNumber = erlang:length(mod_map_monster:get_monster_id_list()),
    if MonsterNumber > 0 andalso MonsterType =:= ?NORMAL ->
           ignore;
       true ->
           mod_map_monster:init_vwf_map_monster(MapProcessName, MapId, MonsterList, MonsterType, MonsterLevel),
           %% 发一个触发消息，以便定时处理超过多长时间没有人的副本图
           MaxHoldTime = get_vwf_max_hold_time(),
           if MonsterType =:= ?NORMAL ->
                  ?INFO_MSG("~ts,MaxHoldTime=~w",["讨伐敌营副本初始化普通怪物，并设置30分钟后关闭副本",MaxHoldTime]),
                  erlang:send_after(MaxHoldTime * 1000,self(),{mod_vie_world_fb,{max_hold_time}});
              true ->
                  ignore
           end
    end,
    ok.
%% 普通怪物死亡
do_normal_monster_dead(MonsterLevel) ->
    %% 需要广播当前打死的怪物数
    RoleIdList = mod_map_actor:get_in_map_role(),
    MonsterNumber = erlang:length(mod_map_monster:get_monster_id_list()),
    Content = erlang:integer_to_list(30 - MonsterNumber),
    Message = lists:flatten(io_lib:format(?_LANG_VIE_WORLD_FB_BC_MSG_RUNNING,[Content])),
    common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,Message),
    if MonsterNumber =:= 0 ->
            do_normal_monster_dead2(MonsterLevel);
       true ->
            ignore
    end,
    ok.
do_normal_monster_dead2(MonsterLevel) ->
    %% 初始化精英怪
    VWFMonsterList = get_vwf_monster(MonsterLevel,?ELITE),
    ?DEBUG("~ts,VWFMonsterList=~w",["初始化精英怪",VWFMonsterList]),
    {MapId,_EnterPosList} = get_vwf_map_enter_info(),
    MonsterList = lists:foldl(
                    fun(VWFMonster,Acc) ->
                            #r_vwf_monster{monster_id = TypeId,bron_list = BronList} = VWFMonster,
                            MonsterList = 
                                lists:map(
                                  fun(MonsterBronRecord) ->
                                          #r_vwf_monster_bron{tx = Tx,ty = Ty} = MonsterBronRecord,
                                          Pos = #p_pos{tx = Tx,ty = Ty,dir = 1},
                                          #p_monster{reborn_pos = Pos,
                                                     monsterid = mod_map_monster:get_max_monster_id_form_process_dict(),
                                                     typeid = TypeId,
                                                     mapid = MapId}
                                  end,BronList),
                            lists:append([MonsterList,Acc])
                    end,[],VWFMonsterList),
    MapState = mgeem_map:get_state(),
    #map_state{mapid = MapId, map_name = MapProcessName} = MapState,
    mod_map_monster:init_vwf_map_monster(MapProcessName, MapId, MonsterList, ?ELITE, MonsterLevel),
    %% 添加精英怪出生广播
    RoleIDList = mod_map_actor:get_in_map_role(),
    catch common_broadcast:bc_send_msg_role(RoleIDList,?BC_MSG_TYPE_CENTER,?_LANG_VIE_WORLD_BOSS_BRON),
    ok.
%% 精英怪物死亡
other_monster_dead() ->
    %% 副本完成
    RoleIdList = mod_map_actor:get_in_map_role(),
    MonsterNumber = erlang:length(mod_map_monster:get_monster_id_list()),
    Content = erlang:integer_to_list(1 - MonsterNumber),
    Message = lists:flatten(io_lib:format(?_LANG_VIE_WORLD_FB_BC_MSG_RUNNING_ELITE,[Content])),
    catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,Message),
    %% 队员通知任务完成
    Message2 = ?_LANG_VIE_WORLD_FB_BC_MSG_END_MEMBER,
    catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_SYSTEM,Message2),
    %% 世界聊天频道广播谁完成此任务
    [RoleId|_T] = RoleIdList,
    LeaderName = get_team_leader_role_name(RoleId),
    LeaderName2 = lists:append(["[",common_tool:to_list(LeaderName),"]"]),
    %% 获取玩家是从那一张地图进入副本的
    MapName = get_role_enter_vwf_map_name(RoleId),
    Message3 = lists:flatten(io_lib:format(?_LANG_VIE_WORLD_FB_BC_MSG_END_LEADER,[LeaderName2,MapName])),
    catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,Message3),
    EndTime = common_tool:now(),
    %% 添加本次成功完成副本的相关信息处理
    catch do_vwf_hook(RoleIdList,EndTime),
    %% 记录日志
    catch do_write_vwf_log(2,EndTime),
    %% 成就 讨伐敌营副本 add by caochuncheng 2011-03-08
    common_hook_achievement:hook({mod_fb,{vwf_complete,RoleIdList}}),
    %% 循环广播副本关闭消息处理
    MaxInterval = get_vwf_max_close_seconds(),
    do_vwf_close(MaxInterval),
    ok.
%% 获取玩家进入副本的地图名称信息
get_role_enter_vwf_map_name(RoleId) ->
    ParentMapId = erlang:get(parent_map_id),
    MapName = common_map:get_map_str_name(ParentMapId),
    case mod_map_actor:get_actor_mapinfo(RoleId,role) of
        undefined ->
            MapName;
        RoleMapInfo ->
            FactionId = RoleMapInfo#p_map_role.faction_id,
            if FactionId =:= 1 ->
                    lists:append(["<font color=\"#00FF00\">",MapName,"</font>"]);
               FactionId =:= 2 ->
                    lists:append(["<font color=\"#F600FF\">",MapName,"</font>"]);
               FactionId =:= 3 ->
                    lists:append(["<font color=\"#00CCFF\">",MapName,"</font>"]);
               true ->
                    MapName
            end
    end.

%% 关闭副本消息处理
do_vwf_close(MaxInterval) ->
    if MaxInterval =:= 0 ->
            do_vwf_close2();
       true ->
            StrInterval = erlang:integer_to_list(MaxInterval),
            Message = lists:flatten(io_lib:format(?_LANG_VIE_WORLD_CLOSE_FB,[StrInterval])),
            RoleIdList = mod_map_actor:get_in_map_role(),
            catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,Message),
            if MaxInterval - 5 >= 5 ->
                    erlang:send_after(5000,self(),{mod_vie_world_fb,{vwf_close,MaxInterval - 5}});
               true ->
                    erlang:send_after(MaxInterval * 1000,self(),{mod_vie_world_fb,{vwf_close, 0}})
            end
    end.

do_vwf_close2() ->
    %% 记录日志
    EndTime = common_tool:now(),
    catch do_write_vwf_log(3,EndTime),
    RoleIdList = mod_map_actor:get_in_map_role(),
    %% 处理这批玩家自动离开副本
    lists:foreach(
      fun(RoleId) ->
              {MapId,Tx,Ty} = get_role_enter_vwf_map_info(RoleId),
              db:dirty_delete(?DB_VIE_WORLD_FB_LOG, RoleId),
              mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleId, MapId, Tx, Ty),
              ok
         end,RoleIdList),
    erlang:send_after(120000,self(),{mod_vie_world_fb,{vwf_exit}}),
    ok.
    

%% 退出副本进程消息处理
do_vwf_exit() ->
    %% 保留上次进入副本的地图的记灵信息出错，将玩家传送至王都
    RoleIdList = mod_map_actor:get_in_map_role(),
    if erlang:length(RoleIdList) > 0 ->
            do_vwf_exit2(RoleIdList);
       true ->
            %% 发送消息关闭地图
            self() ! {mod_vie_world_fb,{kill_vwf_map}}
    end.
do_vwf_exit2(RoleIdList) ->
    lists:foreach(
      fun(RoleId) ->
              {MapId,Tx,Ty} = get_role_enter_vwf_map_info(RoleId),
              db:dirty_delete(?DB_VIE_WORLD_FB_LOG, RoleId),
              mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleId, MapId, Tx, Ty),
              ok
      end,RoleIdList),
    erlang:send_after(120000,self(),{mod_vie_world_fb,{vwf_exit}}),
    ok.

%% 副本最长时间关闭处理
do_max_hold_time() ->
    MaxInterval = get_vwf_max_close_seconds(),
    do_vwf_close(MaxInterval).

%% 副本延迟发送的消息，处理玩家进入讨伐敌营副本时发送相关的提示消息
%% erlang:send_after(10000,self(),{mod_vie_world_fb,{vwf_delay_send_message}}),
do_vwf_delay_send_message(RoleId) ->
    MapState = mgeem_map:get_state(),
    #map_state{mapid=MapId} = MapState,
    {VWFMapId,_EnterPosList} = get_vwf_map_enter_info(),
    if VWFMapId =:= MapId ->
            MaxHoldTime = get_vwf_max_hold_time(),
            MaxHoldTime2 = MaxHoldTime div 60,
            Content = erlang:integer_to_list(MaxHoldTime2),
            Message = lists:flatten(io_lib:format(?_LANG_VIE_WORLD_HOLD_TIME,[Content])),
            catch common_broadcast:bc_send_msg_role([RoleId],?BC_MSG_TYPE_SYSTEM,Message);
       true ->
            ignore
    end,
    ok.

%% 副本开启前或副本结束前发送的消息处理
%% Type 为 start副本开启,stop 副本结束
%% Time 结构为 erlang:time
%% BeforeSeconds 提前时间，单位为秒
do_vwf_message_broadcast(Type,BeforeSeconds,Time) ->
    {H,M,S} = Time,
    HStr = erlang:integer_to_list(H),
    BeforeStr = erlang:integer_to_list(BeforeSeconds div 60),
    MStr = 
        if M < 10 ->
                lists:concat(["0",erlang:integer_to_list(M)]);
           true ->
                erlang:integer_to_list(M)
        end,
    SStr = 
        if S < 10 ->
                lists:concat(["0",erlang:integer_to_list(S)]);
           true ->
                erlang:integer_to_list(S)
        end,
    case Type of
        start ->
            CMessage = lists:flatten(io_lib:format(?_LANG_VIE_WORLD_FB_BC_MSG_BEFORE_S_CENTER,[HStr,MStr,SStr])),
            LMessage = lists:flatten(io_lib:format(?_LANG_VIE_WORLD_FB_BC_MSG_BEFORE_S_LEFT,[BeforeStr])),
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,CMessage),
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,LMessage),
            if BeforeSeconds - 60 >= 60 ->
                    BeforeSeconds2 = BeforeSeconds - 60,
                    erlang:send_after(60 * 1000, self(),{mod_vie_world_fb,{vwf_message_broadcast,Type,BeforeSeconds2,Time}});
               true ->
                    ignore
            end;
        _ ->
            ignore
    end,
    ok.

%% 记录创建此副本地图的地图信息
do_create_vwf_map_parent_map_id(ParentMapId,NpcTypeId,LeaderRoleId,VWFRoleList,MonsterLevel) ->
    erlang:put(parent_map_id, ParentMapId),
    %% -record(r_vwf_role_info,{role_id,role_name,account_name,level,faction_id,family_id,team_id,map_id,pos}).
    erlang:put(enter_vwf_map_role_list,VWFRoleList),
    %% 记录讨伐敌营进入副本时的信息日志，缓存在进程字典中，当玩家完成副本或即出副本时记录
    MapName = common_map:get_map_str_name(ParentMapId),
    {FactionId,Ids,Names,Number,LeaderRoleName} = 
        lists:foldl(
          fun(VWFRole,Acc) ->
                  {_A,B,C,D,E} = Acc,
                  E2 =  
                      if VWFRole#r_vwf_role_info.role_id =:= LeaderRoleId ->
                              common_tool:to_list(VWFRole#r_vwf_role_info.role_name);
                         true ->
                              E
                      end,
                  A2 = VWFRole#r_vwf_role_info.faction_id,
                  if D =:= 0 ->
                          B2 = erlang:integer_to_list(VWFRole#r_vwf_role_info.role_id),
                          C2 = common_tool:to_list(VWFRole#r_vwf_role_info.role_name);
                     true ->
                          B2 = lists:append([B,",",erlang:integer_to_list(VWFRole#r_vwf_role_info.role_id)]),
                          C2 = lists:append([C,",",common_tool:to_list(VWFRole#r_vwf_role_info.role_name)])
                  end,
                  {A2,B2,C2,D + 1,E2}
          end,{0,"","",0,""},VWFRoleList),
    VWFLog = #r_vwf_log{faction_id = FactionId,
                        map_id = ParentMapId,
                        map_name = MapName,
                        npc_id = NpcTypeId,
                        vwf_monster_level = MonsterLevel,
                        start_time = common_tool:now(),
                        status = 1,
                        in_vwf_role_ids = Ids,
                        in_vwf_role_names= Names,
                        in_vwf_number = Number,
                        leader_role_id = LeaderRoleId,
                        leader_role_name = LeaderRoleName,
                        deal_state = 0},
    erlang:put(vwf_log_record,VWFLog).
%% 添加本次成功完成副本的相关信息处理
do_vwf_hook(RoleIdList,EndTime) ->
    case erlang:get(vwf_log_record) of
        undefined ->
            ignore;
        VWFLog ->
            #r_vwf_log{faction_id = FactionId,
                       map_id = ParentMapId,
                       map_name = MapName,
                       npc_id = NpcTypeId,
                       vwf_monster_level = MonsterLevel,
                       start_time = StartTime,
                       leader_role_id = LeaderRoleId,
                       leader_role_name = LeaderRoleName} =VWFLog,          
            VWFRoleLogList = 
                lists:foldl(
                  fun(RoleId,Acc) ->
                          RoleName = 
                              case mod_map_actor:get_actor_mapinfo(RoleId,role) of
                                  undefined ->
                                      "";
                                  RoleMapInfo ->
                                      common_tool:to_list(RoleMapInfo#p_map_role.role_name)
                              end,
                          VWFRoleLog = #r_vwf_role_log{
                            faction_id = FactionId,
                            map_id = ParentMapId,
                            map_name = MapName,
                            npc_id = NpcTypeId,
                            vwf_monster_level = MonsterLevel,
                            start_time = StartTime,
                            role_id = RoleId,
                            role_name = RoleName,
                            end_time = EndTime,
                            leader_role_name = LeaderRoleName,
                            leader_role_id = LeaderRoleId},
                          [VWFRoleLog | Acc]
                  end,[],RoleIdList),
            hook_activity_vwf:hook({vwf_activity_hook,StartTime,EndTime,VWFRoleLogList})
    end,
    ok.
%% 调用此函数记录讨伐敌营日志
%% Status 记录状态 1 进入副本，2 完成副本，3 其它
do_write_vwf_log(Status,EndTime) ->
    case erlang:get(vwf_log_record) of
        undefined ->
            ignore;
         VWFLog ->
            %% 确保日志只记录一次
            erlang:erase(vwf_log_record),
            RoleIdList = mod_map_actor:get_in_map_role(),
            {Ids,Number} =
                lists:foldl(
                  fun(Id,Acc) ->
                          {A,B} = Acc,
                          if B =:= 0 ->
                                  A2 = erlang:integer_to_list(Id);
                             true ->
                                  A2 = lists:append([A , ",", erlang:integer_to_list(Id)])
                          end,
                          {A2,B + 1}
                  end,{"",0},RoleIdList),
            VWFLog2 = VWFLog#r_vwf_log{
                        end_time = EndTime,
                        status = Status,
                        out_vwf_role_ids = Ids,
                        out_vwf_number = Number,
                        deal_state = 1},
            if Status =:= 2 ->
                    do_write_vwf_role_log(VWFLog2,RoleIdList);
               true ->
                    next
            end,
           
            common_general_log_server:log_vwf(VWFLog2)
    end.
do_write_vwf_role_log(VWFLog,RoleIdList) ->        
    #r_vwf_log{faction_id = FactionId,
               map_id = ParentMapId,
               map_name = MapName,
               npc_id = NpcTypeId,
               vwf_monster_level = MonsterLevel,
               start_time = StartTime,
               leader_role_id = LeaderRoleId,
               leader_role_name = LeaderRoleName,
               end_time = EndTime} =VWFLog,
    lists:foreach(
      fun(RoleId) ->
              RoleName = 
                  case mod_map_actor:get_actor_mapinfo(RoleId,role) of
                      undefined ->
                          "";
                      RoleMapInfo ->
                          common_tool:to_list(RoleMapInfo#p_map_role.role_name)
                  end,
              VWFRoleLog = #r_vwf_role_log{
                faction_id = FactionId,
                map_id = ParentMapId,
                map_name = MapName,
                npc_id = NpcTypeId,
                vwf_monster_level = MonsterLevel,
                start_time = StartTime,
                role_id = RoleId,
                role_name = RoleName,
                end_time = EndTime,
                leader_role_name = LeaderRoleName,
                leader_role_id = LeaderRoleId},
              common_general_log_server:log_vwf(VWFRoleLog)
      end,RoleIdList).

%% 玩家在副本下线，当副本地图关闭时重新登录处理
do_role_re_login_vwf(RoleId) -> 
    {MapId,Tx,Ty} = get_role_enter_vwf_map_info(RoleId),
    db:dirty_delete(?DB_VIE_WORLD_FB_LOG, RoleId),
    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleId, MapId, Tx, Ty),
    RoleIdList = mod_map_actor:get_in_map_role(),
    if RoleIdList =:= [] ->
            %% 发送消息关闭地图 120000
            erlang:send_after(120000,self(),{mod_vie_world_fb,{kill_vwf_map}});
       true ->
            ignore
    end,
    ok.

%% 当玩家退出队伍时，或掉线重新上线时已经不在队伍中时处理
do_hook_team_change(RoleId,TeamId) ->
    %% 判断是不是在逐鹿天下副本离开的队伍
    ?DEBUG("~ts,RoleId=~w,TeamId=~w",["判断是不是在逐鹿天下副本离开的队伍",RoleId,TeamId]),
    if TeamId =:= 0 ->
            MapState = mgeem_map:get_state(),
            #map_state{mapid = MapId} = MapState,
            {VWFMapId,_EnterPosList} = get_vwf_map_enter_info(),
            %% 还必须判断当前玩家是否在线，如果不在线此不需要处理
            Flag = common_misc:is_role_online(RoleId),
            if VWFMapId =:= MapId andalso Flag =:= true ->
                    ?DEBUG("~ts,VWFMapId=~w,MapId=~w,Flag=~w",["判断是不是在逐鹿天下副本离开的队伍",VWFMapId,MapId,Flag]),
                    do_role_re_login_vwf(RoleId);
               true ->
                    ignore
            end;
       true ->
            ignore
    end,
    ok.

%% 玩家请求进入逐鹿天下副本
do_vwf_enter({Unique, Module, Method, DataRecord, RoleId, Line}) ->
    case catch do_vwf_enter2({Unique, Module, Method, DataRecord, RoleId, Line}) of 
        {error,Reason} ->
            do_vwf_enter_error({Unique, Module, Method, DataRecord, RoleId, Line},Reason);
        {ok,VWFRoleList} ->
            do_vwf_enter3({Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList)
    end.
do_vwf_enter2({_Unique, _Module, _Method, DataRecord, RoleId, _Line}) ->
    NpcId = DataRecord#m_vie_world_fb_enter_tos.npc_id,
    TypeId = DataRecord#m_vie_world_fb_enter_tos.type_id,
    if NpcId =:= 0 orelse TypeId =:= 0 ->
            ?DEBUG("~ts,DataRecord=~w",["参数不合法",DataRecord]),
            erlang:throw({error,?_LANG_VIE_WORLD_FB_PARAM_ERROR});
       true ->
            next
    end,
    %% 检查是否是合法的逐鹿天下的Server NPC 
    ServerNpcIds = get_vwf_server_npc_ids(),
    case lists:member(TypeId,ServerNpcIds) of
        true ->
            next;
        false ->
            ?DEBUG("~ts,TypeId=~w",["此Server NPC 类型id不合法",TypeId]),
            erlang:throw({error,?_LANG_VIE_WORLD_FB_TYPE_ID_ERROR})
    end,
    %% 判断此NPC 是不是在此地图已经消失了
    case mod_map_actor:get_actor_mapinfo(NpcId,server_npc) of
        undefined ->
            ?DEBUG("~ts,NpcId=~w",["此Server NPC已经在地图消失",NpcId]),
            erlang:throw({error,?_LANG_VIE_WORLD_FB_NPC_ID_ERROR});
        _ ->
            next
    end,
    %% 此Npc Id 必须是此地图的
    MapServerNpcIds = mod_server_npc:get_server_npc_id_list(),
    case lists:member(NpcId,MapServerNpcIds) of
        false ->
            ?DEBUG("~ts,NpcId=~w",["此地图没有Server NPC ID",NpcId]),
            erlang:throw({error,?_LANG_VIE_WORLD_FB_NPC_ID_ERROR});
        true ->
            next
    end,
    %% 是否是合法的NPC
    MapState = mgeem_map:get_state(),
    #map_state{mapid = MapId} = MapState,
    ServerNpcBronInfo = 
        case get_vwf_server_npc_bron_info(MapId,TypeId) of
            undefined ->
                ?DEBUG("~ts,MapId=~w,TypeId=~w",["此Server NPC 在配置文件中查找不到出生点配置信息",MapId,TypeId]),
                erlang:throw({error,?_LANG_VIE_WORLD_FB_NPC_ID_ERROR});
            NpcBron ->
                NpcBron
        end,
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case RoleBase#p_role_base.team_id =/= 0 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_VIE_WORLD_FB_NO_TEAM})
    end,
    MapTeamInfo = 
        case mod_map_team:get_role_team_info(RoleId) of
            {ok,MapTeamInfoT} ->
                MapTeamInfoT;
            _ ->
                erlang:throw({error,?_LANG_VIE_WORLD_FB_NO_TEAM})
        end,
    case MapTeamInfo#r_role_team.team_id =:= 0 orelse erlang:length(MapTeamInfo#r_role_team.role_list) =:= 0 of
        true ->
            erlang:throw({error,?_LANG_VIE_WORLD_FB_NO_TEAM});
        _ ->
            next
    end,
    case RoleId =:= mod_map_team:get_team_leader_role_id(MapTeamInfo#r_role_team.role_list) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_VIE_WORLD_NOT_LEADER})
    end,
    case erlang:length(MapTeamInfo#r_role_team.role_list) < 3 of
        true ->
            erlang:throw({error,?_LANG_VIE_WORLD_FB_NO_TEAM});
        _ ->
            next
    end,
    %% 同一地图检查
    {MapRoleInfoFlag,MapRoleInfoList} = 
        lists:foldl(
          fun(PTeamRoleInfo,{AccMapRoleInfoFlag,AccMapRoleInfoList}) ->
                  case AccMapRoleInfoFlag =:= true of
                      true ->
                          case mod_map_actor:get_actor_mapinfo(PTeamRoleInfo#p_team_role.role_id,role) of
                              undefined ->
                                  {false,[]};
                              MapRoleInfoT ->
                                  {AccMapRoleInfoFlag,[MapRoleInfoT|AccMapRoleInfoList]}
                          end;
                      _ ->
                          {AccMapRoleInfoFlag,AccMapRoleInfoList}
                  end
          end,{true,[]},MapTeamInfo#r_role_team.role_list),
    case MapRoleInfoFlag of
        false ->
            erlang:throw({error,?_LANG_VIE_WORLD_NOT_RANGE});
        true ->
            next
    end,
    %% 同一国家检查
    MapId =  mgeem_map:get_mapid(),
    MapFactionId = mgeem_map:get_mapid() rem 10000 div 1000,
    case lists:foldl(
           fun(PTeamRoleInfoT,AccFactionFlag) ->
                   case AccFactionFlag =:= true andalso PTeamRoleInfoT#p_team_role.faction_id =:= MapFactionId of
                       true ->
                           AccFactionFlag;
                       _ ->
                           false
                   end
           end,true,MapTeamInfo#r_role_team.role_list) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_VIE_WORLD_FACTION})
    end,
    %% 级别检查
    MinLevel = get_vwf_role_level(),
    case lists:foldl(
           fun(MapRoleInfoTT,AccRoleLevelFlag) ->
                   case AccRoleLevelFlag =:= true andalso MapRoleInfoTT#p_map_role.level >= MinLevel of
                       true ->
                           AccRoleLevelFlag;
                       _ ->
                           false
                   end
           end,true,MapRoleInfoList) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_VIE_WORLD_ROLE_LEVEL})
    end,
    %% 判断是否在同一范围
    NpcPosTx = ServerNpcBronInfo#r_server_npc_born_sub.tx,
    NpcPosTy = ServerNpcBronInfo#r_server_npc_born_sub.ty,
    {NpcPosPx, NpcPosPy} = common_misc:get_iso_index_mid_vertex(NpcPosTx, 0, NpcPosTy),
    {RangePx,RangePy} = get_vwf_role_enter_range(),
    case lists:foldl(
           fun(MapRoleInfoTTT,AccRoleRangeFlag) ->
                   case AccRoleRangeFlag =:= true of
                       true ->
                           {Px,Py} = common_misc:get_iso_index_mid_vertex((MapRoleInfoTTT#p_map_role.pos)#p_pos.tx, 0, 
                                                                          (MapRoleInfoTTT#p_map_role.pos)#p_pos.ty),
                           case erlang:abs(NpcPosPx - Px) < RangePx andalso erlang:abs(NpcPosPy - Py) < RangePy  of
                               true ->
                                   AccRoleRangeFlag;
                               _ ->
                                   false
                           end;
                       _ ->
                           AccRoleRangeFlag
                   end
           end,true,MapRoleInfoList) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_VIE_WORLD_NOT_RANGE})
    end,
    VWFRoleList = 
        lists:map(
          fun(PTeamRoleInfoTT) ->
                  get_vwf_role_info(PTeamRoleInfoTT#p_team_role.role_id,MapId,MapRoleInfoList)
          end,MapTeamInfo#r_role_team.role_list),
    {ok,VWFRoleList}.
%% VWFRoleList 结构为[r_vwf_role_info,r_vwf_role_info,...]
do_vwf_enter3({Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList) ->
    %% 判断是否此副本已经被人进入了，如果没有即有此组队员进入
    Reason = ?_LANG_VIE_WORLD_IN_ENTER,
    NpcId = DataRecord#m_vie_world_fb_enter_tos.npc_id,
    case mod_map_actor:get_actor_mapinfo(NpcId,server_npc) of
        undefined ->
            ?DEBUG("~ts,NpcId=~w",["此逐鹿天下副本已经被别的组员进入了",NpcId]),
            do_vwf_enter_error({Unique, Module, Method, DataRecord, RoleId, Line},Reason);
        MapServerNpcInfo ->
            NpcState = MapServerNpcInfo#p_map_server_npc.state,
            if NpcState =:= 1 ->
                    %% 可以进入
                    MapServerNpcInfo2 = MapServerNpcInfo#p_map_server_npc{state = ?HOLD_STATE},
                    mod_map_actor:set_actor_mapinfo(NpcId,server_npc,MapServerNpcInfo2),
                    do_vwf_enter4({Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList);
               true ->
                    ?DEBUG("~ts,NpcId=~w",["此逐鹿天下副本已经被别的队伍进入了【正在进入】",NpcId]),
                    do_vwf_enter_error({Unique, Module, Method, DataRecord, RoleId, Line},Reason)
            end
    end.
do_vwf_enter4({Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList) ->
    %% 通知ServerNpc 在地图消失
    NpcId = DataRecord#m_vie_world_fb_enter_tos.npc_id,
    MapState = mgeem_map:get_state(),
    NpcTypeId = 
        case erlang:get({server_npc_state,NpcId}) of
            undefined ->
                mod_map_actor:do_quit(NpcId, server_npc, MapState),
                0;
            ServerNpcState ->
                #server_npc_state{server_npc_info = ServerNpcInfo} = ServerNpcState,
                MapServerNpc = #p_map_server_npc{
                  npc_id = ServerNpcInfo#p_server_npc.npc_id,
                  type_id = ServerNpcInfo#p_server_npc.type_id,
                  npc_name = ServerNpcInfo#p_server_npc.npc_name,
                  npc_type = ServerNpcInfo#p_server_npc.npc_type,
                  state = ?DEAD_STATE,
                  max_mp= ServerNpcInfo#p_server_npc.max_mp,
                  max_hp = ServerNpcInfo#p_server_npc.max_hp,
                  map_id = ServerNpcInfo#p_server_npc.map_id,
                  pos = ServerNpcInfo#p_server_npc.reborn_pos},
                ServerNpcInfo2 = ServerNpcInfo#p_server_npc{state = ?DEAD_STATE},
                ServerNpcState2 = ServerNpcState#server_npc_state{server_npc_info = ServerNpcInfo2},
                MapServerNpcId = MapServerNpc#p_map_server_npc.npc_id,
                mod_map_actor:do_quit(NpcId, server_npc, MapState),
                put({server_npc_state,MapServerNpcId},ServerNpcState2),
                ServerNpcInfo#p_server_npc.type_id
        end,
    do_vwf_enter5({Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList,NpcTypeId).
do_vwf_enter5({Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList,NpcTypeId) ->
    %% 创建副本地图
    NpcId = DataRecord#m_vie_world_fb_enter_tos.npc_id,
    {FbMapId,_EnterPosList} = get_vwf_map_enter_info(),
    FbMapProcessName = mod_map_copy:get_vwf_common_map_name(mgeem_map:get_mapid(),NpcId),
    %% 异步创建讨伐敌营地图进程
    log_async_create_map({RoleId,FbMapId,FbMapProcessName},{{Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList,NpcTypeId}),
    case global:whereis_name(FbMapProcessName) of
        undefined ->
            mod_map_copy:async_create_copy(FbMapId,FbMapProcessName,?MODULE,{RoleId,FbMapId,FbMapProcessName});
        _ ->
            do_vwf_enter_error({Unique, Module, Method, DataRecord, RoleId, Line},?_LANG_VIE_WORLD_IN_ENTER)
    end.
log_async_create_map(Key, Info) ->
    erlang:put({mod_vie_world_fb, Key}, Info).
get_async_create_map_info(Key) ->
    erlang:get({mod_vie_world_fb, Key}).
do_create_fb_succ(Key) ->
    case get_async_create_map_info(Key) of
        undefined ->
            ignore;
        {{Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList,NpcTypeId} ->
            {RoleId,FbMapId,FbMapProcessName} = Key,
            do_vwf_enter6({Unique,Module,Method,DataRecord,RoleId,Line},VWFRoleList,NpcTypeId,FbMapId,FbMapProcessName)
    end.
do_vwf_enter6({Unique,Module,Method,DataRecord,RoleId,Line},VWFRoleList,NpcTypeId,FbMapId,FbMapProcessName) ->
    case mod_map_copy:create_vwf_map_copy(FbMapId,FbMapProcessName) of
        ok ->
            %% 发送消息让逐鹿副本根据条件初始化怪物
            %% VWFRoleList 结构为[r_vwf_role_info,r_vwf_role_info,...]
            {MonsterLevel,MonsterList} = get_vwf_map_monster(VWFRoleList,?NORMAL),
            %% MonsterList 结构为[p_monster,p_monster,...]
            ?DEBUG("~ts,MapProcessName=~w,self()=~w",["创建副本地图成功",FbMapProcessName,self()]),
            global:send(FbMapProcessName, {mod_vie_world_fb,{init_vwf_monster,MonsterList,?NORMAL,MonsterLevel}}),
            ParentMapId = mgeem_map:get_mapid(),
            global:send(FbMapProcessName, {mod_vie_world_fb,{create_vwf_map_parent_map_id,ParentMapId,NpcTypeId,RoleId,VWFRoleList,MonsterLevel}}),
            do_vwf_enter7({Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList);
        error ->
            case global:whereis_name(FbMapProcessName) of
                undefined ->
                    ignore;
                FbMapProcessPid ->
                    catch FbMapProcessPid ! {mod_vie_world_fb,{kill_vwf_map}}
            end,
            Reason = ?_LANG_VIE_WORLD_CREATE_FB,
            do_vwf_enter_error({Unique, Module, Method, DataRecord, RoleId, Line},Reason)
    end.
do_vwf_enter7({Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList) ->
    case db:transaction(
           fun() -> 
                   do_t_vwf_enter(RoleId,DataRecord,VWFRoleList)
           end) of
        {atomic,{ok}} ->
            do_vwf_enter8({Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList);
        {aborted, Error} ->
            Reason = 
                case Error of 
                    {throw,{error,R}} ->
                        R;
                    _ ->
                        ?_LANG_VIE_WORLD_FB_ERROR
                end,
            do_vwf_enter_error({Unique, Module, Method, DataRecord, RoleId, Line},Reason)
    end.
do_vwf_enter8({Unique, Module, Method, DataRecord, RoleId, Line},VWFRoleList) ->
    %% 跳转地图，进入副本地图
    NpcId = DataRecord#m_vie_world_fb_enter_tos.npc_id,
    {MapId,EnterPosList} = get_vwf_map_enter_info(),
    MonsterTypeIds = get_vwf_map_monster_type_ids(VWFRoleList),
    Message = #m_vie_world_fb_enter_toc{succ = true,monster_type_ids = MonsterTypeIds},
    ?DEBUG("~ts,Result=~w",["返回结果为",Message]),
    lists:foreach(
      fun(VWFRoleInfo) ->
              ChangeRoleId = VWFRoleInfo#r_vwf_role_info.role_id,
              if ChangeRoleId =:= RoleId ->
                      common_misc:unicast(Line, RoleId, Unique, Module, Method, Message);
                 true ->
                      common_misc:unicast(Line, ChangeRoleId, ?DEFAULT_UNIQUE, Module, Method, Message)
              end
      end,VWFRoleList),
    lists:foldl(
      fun(VWFRoleInfo,Index) ->
              ChangeRoleId = VWFRoleInfo#r_vwf_role_info.role_id,
              {Tx,Ty} = lists:nth(Index,EnterPosList),
              put({enter_vwf_map, ChangeRoleId}, NpcId),
              mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_VWF, ChangeRoleId, MapId, Tx, Ty),
              Index + 1
      end,1,VWFRoleList),
    ok.

do_vwf_enter_error({Unique, Module, Method, _DataRecord, RoleId, Line},Reason) ->
    SendSelf = #m_vie_world_fb_enter_toc{succ = false,reason = Reason,monster_type_ids = []},
    ?DEBUG("~ts,Result=~w",["返回结果为",SendSelf]),
    common_misc:unicast(Line, RoleId, Unique, Module, Method, SendSelf).

do_t_vwf_enter(_RoleId,DataRecord,VWFRoleList) ->
    TypeId = DataRecord#m_vie_world_fb_enter_tos.type_id,
    lists:foreach(
      fun(VWFRoleInfo) ->
              VWFLog = #r_vie_world_fb_log{
                role_id = VWFRoleInfo#r_vwf_role_info.role_id,
                role_name = VWFRoleInfo#r_vwf_role_info.role_name,
                account_name = VWFRoleInfo#r_vwf_role_info.account_name,
                faction_id = VWFRoleInfo#r_vwf_role_info.faction_id,
                npc_id = TypeId,
                map_id = VWFRoleInfo#r_vwf_role_info.map_id,
                pos = VWFRoleInfo#r_vwf_role_info.pos,
                in_time = common_tool:now(),
                status = 0},
              db:write(?DB_VIE_WORLD_FB_LOG,VWFLog,write)
      end,VWFRoleList),
    {ok}.


%% 玩家请求从逐鹿天下副本退出
do_vwf_quit({Unique, Module, Method, _DataRecord, RoleId, Line}) ->
    {MapId,Tx,Ty} = get_role_enter_vwf_map_info(RoleId),
    db:dirty_delete(?DB_VIE_WORLD_FB_LOG, RoleId),
    SendSelf = #m_vie_world_fb_quit_toc{succ = true},
    ?DEBUG("~ts,Result=~w",["返回结果为",SendSelf]),
    common_misc:unicast(Line, RoleId, Unique, Module, Method, SendSelf),
    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleId, MapId, Tx, Ty).

%% other api
%% 获取玩家的基本信息，国家，门派，级别，位置
get_vwf_role_info(RoleId,MapId,MapRoleList) ->
    case lists:keyfind(RoleId,#p_map_role.role_id,MapRoleList) of
        false ->
            {ok,RolePos} = mod_map_role:get_role_pos_detail(RoleId),
            {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
            {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
            #r_vwf_role_info{
                              role_id = RoleId,
                              role_name = RoleBase#p_role_base.role_name,
                              account_name = RoleBase#p_role_base.account_name,
                              level = RoleAttr#p_role_attr.level,
                              faction_id = RoleBase#p_role_base.faction_id,
                              family_id = RoleBase#p_role_base.family_id,
                              team_id = RoleBase#p_role_base.team_id,
                              map_id = MapId,
                              pos = RolePos#p_role_pos.pos
                            };
        MapRoleInfo ->
            #r_vwf_role_info{
          role_id = RoleId,
          role_name = MapRoleInfo#p_map_role.role_name,
          account_name = <<"">>,
          level = MapRoleInfo#p_map_role.level,
          faction_id = MapRoleInfo#p_map_role.faction_id,
          family_id = MapRoleInfo#p_map_role.family_id,
          team_id = MapRoleInfo#p_map_role.team_id,
          map_id = MapId,
          pos = MapRoleInfo#p_map_role.pos
         }
    end.
%% 获取队伍队长信息
get_team_leader_role_name(RoleId) ->
    case mod_map_team:get_role_team_info(RoleId) of
        {ok,MapTeamInfo} ->
            lists:foldl(
              fun(TeamRoleInfo,Acc) ->
                      case Acc =:= "" andalso TeamRoleInfo#p_team_role.is_leader =:= true of
                          true ->
                              TeamRoleInfo#p_team_role.role_name;
                          _ ->
                              Acc
                      end
              end,"",MapTeamInfo#r_role_team.role_list);
        _ ->
            ""
    end.
%% 根据队伍成员的信息获取
%% VWFRoleList 结构为[r_vwf_role_info,r_vwf_role_info,...]
%% 返回结果结构为[p_monster,p_monster,..]
get_vwf_map_monster(VWFRoleList,MonsterType) ->
    {SumLW,SumW} = 
        lists:foldl(
          fun(VWFRoleInfo,Acc) ->
                  {AccLW,AccW} = Acc,
                  RoleLevel = VWFRoleInfo#r_vwf_role_info.level,
                  Weight = get_vwf_role_weight(RoleLevel),
                  AccLW2 = AccLW + RoleLevel *  Weight,
                  AccW2 = AccW + Weight,
                  {AccLW2,AccW2}
          end,{0,0},VWFRoleList),
    Level = common_tool:floor(SumLW div SumW div 5) * 5,
    MonsterLevel = 
        if Level < 30 ->
                30;
           true ->
                Level
        end,
    VWFMonsterList = get_vwf_monster(MonsterLevel,MonsterType),
    {MapId,_EnterPosList} = get_vwf_map_enter_info(),
    MonsterList = lists:foldl(
                    fun(VWFMonster,Acc) ->
                            #r_vwf_monster{monster_id = TypeId,bron_list = BronList} = VWFMonster,
                            MonsterList = 
                                lists:map(
                                  fun(MonsterBronRecord) ->
                                          #r_vwf_monster_bron{tx = Tx,ty = Ty} = MonsterBronRecord,
                                          Pos = #p_pos{tx = Tx,ty = Ty,dir = 1},
                                          #p_monster{reborn_pos = Pos,
                                                     monsterid = mod_map_monster:get_max_monster_id_form_process_dict(),
                                                     typeid = TypeId,
                                                     mapid = MapId}
                                  end,BronList),
                            lists:append([MonsterList,Acc])
                    end,[],VWFMonsterList),
    {MonsterLevel,MonsterList}.
%% 获取讨伐敌营副本的所有怪物类型id
%% VWFRoleList 结构为 [r_vwf_role_info]
%% 返回 [] or [MonsterTypeId,...]
get_vwf_map_monster_type_ids(VWFRoleList) ->
    {SumLW,SumW} = 
        lists:foldl(
          fun(VWFRoleInfo,Acc) ->
                  {AccLW,AccW} = Acc,
                  RoleLevel = VWFRoleInfo#r_vwf_role_info.level,
                  Weight = get_vwf_role_weight(RoleLevel),
                  AccLW2 = AccLW + RoleLevel *  Weight,
                  AccW2 = AccW + Weight,
                  {AccLW2,AccW2}
          end,{0,0},VWFRoleList),
    Level = common_tool:floor(SumLW div SumW div 5) * 5,
    MonsterLevel = 
        if Level < 30 ->
                30;
           true ->
                Level
        end,
    MatchHead = #r_vwf_monster{level='$1',_='_' },
    Guard = [{'=:=', '$1', MonsterLevel}],
    Result = ['$_'],
    %% 结构为 [r_vwf_monster]
    VWFMonsterList = ets:select(?ETS_VIE_WORLD_FB_MONSTER,[{MatchHead, Guard, Result}]),
    [R#r_vwf_monster.monster_id || R <- VWFMonsterList].

%% 根据怪物级别获取怪物出生点配置信息
%% 返回的结果结构为[r_vwf_monster,r_vwf_monster,..]
get_vwf_monster(MonsterLevel,MonsterType) ->
    MatchHead = #r_vwf_monster{level='$1',type='$2',_='_' },
    Guard = [{'=:=', '$1', MonsterLevel},{'=:=','$2',MonsterType}],
    Result = ['$_'],
    ets:select(?ETS_VIE_WORLD_FB_MONSTER,[{MatchHead, Guard, Result}]).

%% 获取级别权重记录
get_vwf_role_weight(RoleLevel) ->
    case common_config_dyn:find(vie_world_fb,vwf_role_level_weight) of
        [ WeightList ] ->
            lists:foldl(
              fun(Record,Acc) ->
                      MinLevel = Record#r_vwf_role_level_weight.min_level,
                      MaxLevel = Record#r_vwf_role_level_weight.max_level,
                      if RoleLevel >= MinLevel 
                         andalso RoleLevel =< MaxLevel ->
                              Record#r_vwf_role_level_weight.weight;
                         true ->
                              Acc
                      end
              end,1,WeightList);
        _ ->
            1
    end.

%% 根据Server NPC TypeId 查询此NPC的出生点
%% 返回结构为r_server_npc_born_sub或undefined
get_vwf_server_npc_bron_info(MapId,NpcTypeId) ->
    MatchHead = #r_server_npc_born{npc_type='$1',map_id='$2', _='_' },
    Guard = [{'=:=', '$1', ?SERVER_NPC_TYPE_VWF},{'=:=', '$2', MapId}],
    Result = ['$_'],
    ?DEBUG("server_npc,~ts,MatchHead=~w,Guard=~w,Result=~w",["查询条件为:",MatchHead,Guard,Result]),
    ServerNpcList = ets:select(?ETS_SERVER_NPC_BORN, [{MatchHead, Guard, Result}]),
    if erlang:length(ServerNpcList) =:= 1 ->
            [ServerNpcBorn] = ServerNpcList,
            SubList = ServerNpcBorn#r_server_npc_born.sub_list,
            case lists:keyfind(NpcTypeId,#r_server_npc_born_sub.npc_type_id,SubList) of
                false ->
                    undefined;
                SubBorn ->
                    SubBorn
            end;
       true ->
            undefined
    end.


%% 逐鹿天下副本地图入口信息
get_vwf_map_enter_info() ->
    case common_config_dyn:find(vie_world_fb,vwf_map_id) of
        [ {MapId,EnterPosList}] ->
            {MapId,EnterPosList};
        _ ->
            {10400,[{43,7},{43,7},{43,7},{43,7},{43,7},{43,7}]}
    end.
        
            
%% 获取逐鹿天下副本最低的玩家级别
get_vwf_role_level() ->
    case common_config_dyn:find(vie_world_fb,vwf_role_level) of
        [ Level ] ->
            Level;
        _ ->
            30
    end.
%% 获取进入逐鹿天下副本有效范围
get_vwf_role_enter_range() ->
    case common_config_dyn:find(vie_world_fb,vwf_role_enter_range) of
        [ Range ] ->
            Range;
        _ ->
            {100,100}
    end.

%% 获取逐鹿天下副本Server NPC id
get_vwf_server_npc_ids() ->
    case common_config_dyn:find(vie_world_fb,vwf_server_npc_ids) of
        [ ServerNpcIds ] ->
            ServerNpcIds;
        _ ->
            []
    end.
%% 获取需要显示逐鹿天下副本Server NPC的地图id
get_vwf_show_server_npc_map() ->
    case common_config_dyn:find(vie_world_fb,vwf_server_npc_map_ids) of
        [  MapIds ] ->
            MapIds;
        _ ->
            []
    end.
%% 获需要显示的讨伐敌营副本中的一个地图id
%% 返回结果为[],或[map_id]：长度为1
get_random_vwf_show_server_npc_map_id() ->
    MapIds = get_vwf_show_server_npc_map(),
    if erlang:length(MapIds) > 0 ->
            MapId = lists:nth(1,MapIds),
            [MapId];
       true ->
            []
    end.
%% 获取副本关闭倒计时间,单位为秒
get_vwf_max_close_seconds() ->
    case common_config_dyn:find(vie_world_fb,vwf_max_close_seconds) of
        [ Seconds ] ->
            Seconds;
        _ ->
            30
    end.
%% 副本开启后多久之后没有人即关闭，时间单位为秒
get_vwf_max_hold_time() ->
    case common_config_dyn:find(vie_world_fb,vwf_max_hold_time) of
        [ Seconds ] ->
            Seconds;
        _ ->
            1800
    end.

%% 讨伐敌营副本提前多少时间广播开启副本,单位为秒,300
get_vwf_start_before_broadcast_seconds() ->
    case common_config_dyn:find(vie_world_fb,vwf_start_before_broadcast_seconds) of
        [Seconds] ->
            Seconds;
        _ ->
            300
    end.

%% 讨伐敌营副本入口地图的出生点配置
%% -record(r_vwf_enter_map_bron,{map_id,tx,ty,map_name}).
get_vwf_enter_map_bron() ->
    case common_config_dyn:find(vie_world_fb,vwf_enter_map_bron) of
        [EnterMapBronList] ->
            EnterMapBronList;
        _ ->
            []
    end.

%% 根据当前时间判断是否需要显示讨伐敌营副本Server Npc
%% 返回结果 true,开启，false
check_now_open_vie_world_fb() ->
    [FbDays] = common_config_dyn:find(etc, open_vie_world_fb_day),
    case common_config:get_opened_days() >= FbDays of
        true ->
            [IsOpenVWF] = common_config_dyn:find(etc, is_open_vie_world_fb),
            case IsOpenVWF of
                true ->
                    true;
                _ ->
                    ?DEBUG("~ts",["配置中设置讨伐敌营副本不开启"]),
                    false
            end;
       false ->
            false
    end.

%% 获取下一次处理逐鹿天下副与当前时间的间隔
%% 单位为毫秒
%% 参数 Type start 下次开户时间，stop下次结束时间
%% 返回值 {start,IntervalTime,StartTime} or {stop,IntervalTime,EndTime}
%% StartTime和EndTime 结构为erlang:time()
get_next_do_work_interval(Type,NowDate,NowTime) ->
    ?DEBUG("~ts,Type=~w,NowDate=~w,NowTime=~w",["获取下次定时的时间",Type,NowDate,NowTime]),
    NowSeconds = calendar:time_to_seconds(NowTime) * 1000,
    case Type of
        start ->
            %% 获取下一次开启时间
            StartTimes = get_one_day_show_vwf_times(),
            StartTimes2 = [ SR || SR <- StartTimes, SR > NowSeconds],
            StartTimes3 = lists:sort(StartTimes2),
            if erlang:length(StartTimes3) > 0 ->
                    STime = calendar:seconds_to_time(lists:nth(1,StartTimes3) div 1000),
                    {start,lists:nth(1,StartTimes3) - NowSeconds, STime};
               true ->
                    %% 下一天的开启时间计算
                    NowDays = calendar:date_to_gregorian_days(NowDate),
                    StartTimes4 = lists:sort(StartTimes),
                    NextTimes = lists:nth(1,StartTimes4) ,
                    NextDate = calendar:gregorian_days_to_date(NowDays + 1),
                    NextTime = calendar:seconds_to_time(NextTimes div 1000),
                    Seconds1 = calendar:datetime_to_gregorian_seconds({NowDate,NowTime}),
                    Seconds2 = calendar:datetime_to_gregorian_seconds({NextDate,NextTime}),
                    {start,(Seconds2 - Seconds1) * 1000, NextTime}
            end;
        stop ->
            EndTimes = get_one_day_hide_vwf_times(),
            EndTimes2 = [ER || ER <- EndTimes, ER > NowSeconds],
            EndTimes3 = lists:sort(EndTimes2),
            ETime = calendar:seconds_to_time(lists:nth(1,EndTimes3) div 1000),
            {stop,lists:nth(1,EndTimes3) - NowSeconds, ETime}
    end.
           
%% 计算每天的Server NPC显示通知的时间
%% 时间单位为毫秒
%% 返回的结构为：[times1,time2,...]
get_one_day_show_vwf_times() ->
    TimeList = 
        case common_config_dyn:find(vie_world_fb,vwf_open_time) of
            [ TList ] ->
                [ST || {ST,_ET} <- TList];
            _ ->
                []
        end,
    lists:map(fun(StartTime) ->
                      calendar:time_to_seconds(StartTime) * 1000
              end,TimeList).
%% 计算每天的Server NPC消失通知的时间
%% 时间单位为毫秒
%% 返回的结构为：[times1,time2,...]
get_one_day_hide_vwf_times() ->
    TimeList = 
        case common_config_dyn:find(vie_world_fb,vwf_open_time) of
            [ TList ] ->
                [ET || {_ST,ET} <- TList];
            _ ->
                []
        end,
    lists:map(fun(EndTime) ->
                      calendar:time_to_seconds(EndTime) * 1000
              end,TimeList).

%% 判断当前时间是否需要显示Server NPC 
%% 判断当前时间是否需要隐藏Server NPC
%% 返回true需要显示，返回false即不需要显示
is_now_time_vwf_show(NowTime) ->
     TimeList = 
        case common_config_dyn:find(vie_world_fb,vwf_open_time) of
            [ TList ] ->
                TList;
            _ ->
                []
        end,
    NowSeconds = calendar:time_to_seconds(NowTime),
    lists:foldl(fun({ST,ET},Acc) ->
                        STSeconds = calendar:time_to_seconds(ST),
                        ETSeconds = calendar:time_to_seconds(ET),
                        if NowSeconds >= STSeconds 
                           andalso ETSeconds >= NowSeconds ->
                                true;
                           true ->
                                Acc
                        end
              end,false,TimeList).



%% 后台管理 显示Server NPC 操作消息处理
%% 间隔时间 Interval 分钟
do_admin_show_vwf_server_npc(Interval) ->
    ServerNpcIds = mod_server_npc:get_server_npc_id_list(),
    do_admin_show_vwf_server_npc2(ServerNpcIds,Interval).

do_admin_show_vwf_server_npc2(ServerNpcIds,Interval) ->
    VieWorldServerNpcIds = get_vwf_server_npc_ids(),
    ServerNpcStateList = 
        lists:foldl(
          fun(ServerNpcId,Acc) ->
                  case mod_server_npc:get_server_npc_state(ServerNpcId) of
                      undefined ->
                          Acc;
                      ServerNpcState ->
                          [ServerNpcState|Acc]
                  end
          end,[],ServerNpcIds),
    ServerNpcStateList2 = 
        lists:foldl(
          fun(RState,Acc) ->
                  RNpc = RState#server_npc_state.server_npc_info,
                  RTypeId = RNpc#p_server_npc.type_id,
                  case lists:member(RTypeId,VieWorldServerNpcIds) of
                      true ->
                          [RState| Acc];
                      false ->
                          Acc
                  end
          end,[],ServerNpcStateList),
    ServerNpcStateList3 = get_show_npc_id_by_online_num(ServerNpcStateList2),
    if erlang:length(ServerNpcStateList3) > 0 ->
            do_admin_show_vwf_server_npc3(ServerNpcStateList3,Interval);
       true ->
            ?DEBUG("~ts,VieWorldServerNpcId=~w,ServerNpcStateList=~w",["没有逐鹿天下副本的ServerNPC需要处理",VieWorldServerNpcIds,ServerNpcStateList]),
            ignore
    end.
do_admin_show_vwf_server_npc3(ServerNpcStateList,Interval) ->
    MapState = mgeem_map:get_state(),
    lists:foreach(
      fun(ServerNpcState) ->
              #server_npc_state{server_npc_info = ServerNpcInfo} = ServerNpcState,
              MapServerNpc = #p_map_server_npc{
                npc_id = ServerNpcInfo#p_server_npc.npc_id,
                type_id = ServerNpcInfo#p_server_npc.type_id,
                npc_name = ServerNpcInfo#p_server_npc.npc_name,
                npc_type = ServerNpcInfo#p_server_npc.npc_type,
                state = ?GUARD_STATE,
                max_mp= ServerNpcInfo#p_server_npc.max_mp,
                max_hp = ServerNpcInfo#p_server_npc.max_hp,
                map_id = ServerNpcInfo#p_server_npc.map_id,
                pos = ServerNpcInfo#p_server_npc.reborn_pos,
                mp= ServerNpcInfo#p_server_npc.max_mp,
                hp = ServerNpcInfo#p_server_npc.max_hp,
                npc_country = ServerNpcInfo#p_server_npc.npc_country,
                is_undead = ServerNpcInfo#p_server_npc.is_undead,
                move_speed = ServerNpcInfo#p_server_npc.move_speed
               },
              ServerNpcInfo2 = ServerNpcInfo#p_server_npc{state = ?GUARD_STATE},
              ServerNpcState2 = ServerNpcState#server_npc_state{server_npc_info = ServerNpcInfo2},
              ServerNpcInfo3 = ServerNpcInfo#p_server_npc{state = ?DEAD_STATE},
              ServerNpcState3 = ServerNpcState#server_npc_state{server_npc_info = ServerNpcInfo3},
              MapServerNpcId = MapServerNpc#p_map_server_npc.npc_id,
              mod_map_actor:do_quit(MapServerNpcId, server_npc, MapState),
              put({server_npc_state,MapServerNpcId},ServerNpcState3),
              case mod_map_actor:enter(?DEFAULT_UNIQUE, MapServerNpcId, MapServerNpcId, 
                                       server_npc, MapServerNpc, 0, MapState) of
                  ok ->
                      put({server_npc_state,MapServerNpcId},ServerNpcState2);
                  _ ->
                      ?INFO_MSG("~ts,MapServerNpc=~w",["此逐鹿天下副本无法在地图显示",MapServerNpc]),
                      ignore
              end
      end,ServerNpcStateList),
    TimerRef = erlang:send_after(Interval * 60 * 1000,self(),{mod_vie_world_fb,{admin_hide_vwf_server_npc}}),
    #map_state{mapid = MapId} = MapState,
    case erlang:get({vwf_admin_timer_ref,MapId}) of
        undefined ->
            ignore;
        TR ->
            erlang:cancel_timer(TR),
            erlang:erase({vwf_admin_timer_ref,MapId})
    end,
    erlang:put({vwf_admin_timer_ref,MapId},TimerRef),
    SendMsgMapIds = get_random_vwf_show_server_npc_map_id(),
    case lists:member(MapId,SendMsgMapIds) of
        true ->
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,?_LANG_VIE_WORLD_FB_BC_MSG_START_CENTER),
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,?_LANG_VIE_WORLD_FB_BC_MSG_START_LEFT);
        false ->
            ignore
    end,
    ok.

%% 后台管理 消失Server NPC 操作消息处理
do_admin_hide_vwf_server_npc() ->
    ServerNpcIds = mod_server_npc:get_server_npc_id_list(),
    do_admin_hide_vwf_server_npc2(ServerNpcIds).

do_admin_hide_vwf_server_npc2(ServerNpcIds) ->
    VieWorldServerNpcIds = get_vwf_server_npc_ids(),
    ServerNpcStateList = 
        lists:foldl(
          fun(ServerNpcId,Acc) ->
                  case mod_server_npc:get_server_npc_state(ServerNpcId) of
                      undefined ->
                          Acc;
                      ServerNpcState ->
                          [ServerNpcState|Acc]
                  end
          end,[],ServerNpcIds),
    ServerNpcStateList2 = 
        lists:foldl(
          fun(RState,Acc) ->
                  RNpc = RState#server_npc_state.server_npc_info,
                  RTypeId = RNpc#p_server_npc.type_id,
                  case lists:member(RTypeId,VieWorldServerNpcIds) of
                      true ->
                          [RState| Acc];
                      false ->
                          Acc
                  end
          end,[],ServerNpcStateList),
    if erlang:length(ServerNpcStateList2) > 0 ->
            do_admin_hide_vwf_server_npc3(ServerNpcStateList2);
       true ->
            ?DEBUG("~ts,VieWorldServerNpcId=~w,ServerNpcStateList=~w",["没有逐鹿天下副本的ServerNPC需要处理",VieWorldServerNpcIds,ServerNpcStateList]),
            ignore
    end.
do_admin_hide_vwf_server_npc3(ServerNpcStateList) ->
    MapState = mgeem_map:get_state(),
    lists:foreach(
      fun(ServerNpcState) ->
              #server_npc_state{server_npc_info = ServerNpcInfo} = ServerNpcState,
              MapServerNpc = #p_map_server_npc{
                npc_id = ServerNpcInfo#p_server_npc.npc_id,
                type_id = ServerNpcInfo#p_server_npc.type_id,
                npc_name = ServerNpcInfo#p_server_npc.npc_name,
                npc_type = ServerNpcInfo#p_server_npc.npc_type,
                state = ?DEAD_STATE,
                max_mp= ServerNpcInfo#p_server_npc.max_mp,
                max_hp = ServerNpcInfo#p_server_npc.max_hp,
                map_id = ServerNpcInfo#p_server_npc.map_id,
                pos = ServerNpcInfo#p_server_npc.reborn_pos,
                mp= ServerNpcInfo#p_server_npc.max_mp,
                hp = ServerNpcInfo#p_server_npc.max_hp,
                npc_country = ServerNpcInfo#p_server_npc.npc_country,
                is_undead = ServerNpcInfo#p_server_npc.is_undead,
                move_speed = ServerNpcInfo#p_server_npc.move_speed
               },
              ServerNpcInfo2 = ServerNpcInfo#p_server_npc{state = ?DEAD_STATE},
              ServerNpcState2 = ServerNpcState#server_npc_state{server_npc_info = ServerNpcInfo2},
              MapServerNpcId = MapServerNpc#p_map_server_npc.npc_id,
              mod_map_actor:do_quit(MapServerNpcId, server_npc, MapState),
              put({server_npc_state,MapServerNpcId},ServerNpcState2)
      end,ServerNpcStateList),
    #map_state{mapid = MapId} = MapState,
    case erlang:get({vwf_admin_timer_ref,MapId}) of
        undefined ->
            ignore;
        TR ->
            erlang:cancel_timer(TR),
            erlang:erase({vwf_admin_timer_ref,MapId})
    end,
    SendMsgMapIds = get_random_vwf_show_server_npc_map_id(),
    case lists:member(MapId,SendMsgMapIds) of
        true ->
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,?_LANG_VIE_WORLD_FB_BC_MSG_END_CENTER),
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,?_LANG_VIE_WORLD_FB_BC_MSG_END_LEFT);
        false ->
            ignore
    end,
    ok.

%% 获取玩家的进入副本的地图信息，以便玩家可以退出副本地图
%% 返回结果为 {MapId,Tx,Ty}
%% 先通过进程字典查找，
%% 再通过DB_VIE_WORLD_FB_LOG表记录查找
%% 再通过进入副本的出生点查找
%% 最后获取玩家国家王都出生点
get_role_enter_vwf_map_info(RoleId) ->
    %% -record(r_vwf_role_info,{role_id,role_name,account_name,level,faction_id,family_id,team_id,map_id,pos}).
    VWFRoleList = 
        case erlang:get(enter_vwf_map_role_list) of
            undefined ->
                [];
            VWFRoleListT ->
                VWFRoleListT
        end,
    case lists:keyfind(RoleId,#r_vwf_role_info.role_id,VWFRoleList) of
        false ->
            get_role_enter_vwf_map_info2(RoleId);
        VWFRole ->
            #r_vwf_role_info{map_id = MapId, pos = Pos} = VWFRole,
            #p_pos{tx = Tx, ty = Ty} = Pos,
            {MapId,Tx,Ty}
    end.
get_role_enter_vwf_map_info2(RoleId) ->
    case catch db:dirty_read(?DB_VIE_WORLD_FB_LOG, RoleId) of
        {'EXIT', Error} ->
            ?ERROR_MSG("~ts,Error=~w",["玩家在讨伐敌营副本离开副本时出错",Error]),
            get_role_enter_vwf_map_info3(RoleId);
        [] ->
            ?ERROR_MSG("~ts,RoleId=~w",["玩家在讨伐敌营副本无法离开副本，查找不到此记录",RoleId]),
            get_role_enter_vwf_map_info3(RoleId);
        [VWFLog] ->
            #r_vie_world_fb_log{map_id = MapId,pos = Pos} = VWFLog,
            #p_pos{tx = Tx, ty = Ty} = Pos,
            {MapId,Tx,Ty};
        Other ->
            ?ERROR_MSG("~ts,Other=~w",["玩家在讨伐敌营副本无法离开副本，未错误",Other]),
            get_role_enter_vwf_map_info3(RoleId)
    end.
get_role_enter_vwf_map_info3(RoleId) ->
    ParentMapId = 
        case erlang:get(parent_map_id) of
            undefined ->
                0;
            ParentMapIdT ->
                ParentMapIdT
        end,
    EnterMapBronList = get_vwf_enter_map_bron(),
    if EnterMapBronList =:= [] ->
            get_role_enter_vwf_map_info4(RoleId);
       true ->
            case lists:keyfind(ParentMapId,#r_vwf_enter_map_bron.map_id,EnterMapBronList) of
                false ->
                    get_role_enter_vwf_map_info4(RoleId);
                EnterMapBron ->
                    ?ERROR_MSG("~ts,RoleId=~w,EnterMapBron=~w",
                              ["玩家退出副本失败，通过NPC退出失败，处理回进入副本的出生点",RoleId,EnterMapBron]),
                    #r_vwf_enter_map_bron{map_id = MapId,tx = Tx,ty = Ty} = EnterMapBron,
                    {MapId,Tx,Ty}
            end
    end.
get_role_enter_vwf_map_info4(RoleId) ->
    ?ERROR_MSG("~ts,RoleId=~w",["玩家退出副本失败，通过NPC退出失败，直接处理回王都",RoleId]),
    FactionId = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                {ok, RoleBase} = mod_map_role:get_role_base(RoleId),
                RoleBase#p_role_base.faction_id;
            MapRoleInfo ->
                MapRoleInfo#p_map_role.faction_id
        end,
    MapId = common_misc:get_home_map_id(FactionId),
    {MapId,Tx,Ty} = common_misc:get_born_info_by_map(MapId),
    {MapId,Tx,Ty}.

%% @doc 根据在线量获取出生的NPCID
get_show_npc_id_by_online_num(NpcList) ->
    MapID = mgeem_map:get_mapid(),
    case common_config_dyn:find(server_npc_born_num, MapID) of
        [] ->
            NpcList;

        [NumList] ->
            OnlineNum = length(db:dirty_match_object(?DB_USER_ONLINE, #r_role_online{_='_'})),
            DefaultNum = length(NpcList),
            BornNum = get_npc_born_num(OnlineNum, NumList),

            if
                BornNum =:= 0 ->
                    [];
                BornNum  >= DefaultNum ->
                    NpcList;
                true ->
                    Random = random:uniform(DefaultNum-BornNum+1),
                    lists:sublist(NpcList, Random, BornNum)
            end
    end.

get_npc_born_num(_OnlineNum, [{_Min, _Max, BornNum}]) ->
    BornNum;
get_npc_born_num(OnlineNum, [{Min, Max, BornNum}|T]) ->
    case Max =:= 0 orelse (OnlineNum >= Min andalso OnlineNum =< Max) of
        true ->
            BornNum;
        _ ->
            get_npc_born_num(OnlineNum, T)
    end.
