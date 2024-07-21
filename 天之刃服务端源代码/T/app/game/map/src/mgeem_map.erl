%%%----------------------------------------------------------------------
%%% File    : mgeem_virtual_world.erl
%%% Author  : Qingliang
%%% Created : 2010-03-10
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------
-module(mgeem_map).

-behaviour(gen_server).

-include("mgeem.hrl").

-define(MAP_STATE_KEY, map_state_key).
-define(DEFAULT_MAP_DEBUG_MODE,false).


%% --------------------------------------------------------------------
%% API For Extenal Call
%% --------------------------------------------------------------------
-export([
         start_link/1,
         broad_in_sence/5,
         broad_in_sence_include/5,
         get_9_slice_by_txty/4,
         get_slice_by_txty/4,
         get_all_in_sence_user_by_slice_list/1,
         get_new_around_slice/6,
         get_9_slice_by_actorid_list/2,
         get_all_roleid/0,
         func/2,
         flush_all_role_msg_queue/0,
         broadcast/6,
         broadcast/5,
         broadcast/4,
         update_role_msg_queue/2
        ]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% --------------------------------------------------------------------
%% API 子模块专用
%% --------------------------------------------------------------------
-export([
         get_slice_name/2,
         get_slice_trap/1,
         add_slice_trap/3,
         remove_slice_trap/3,
         do_broadcast_insence/5,
         do_broadcast_insence_include/5,
         get_sxsy_by_txty/2,
         get_slice_stalls/1,
         add_slice_stall/3,
         remove_slice_stall/3,
         get_state/0,
         do_broadcast_insence_by_txty/6,
         broadcast_to_whole_map/3,
         get_mapid/0,
         get_mapname/0,
         get_now/0,
         get_now2/0
        ]).


%% --------------------------------------------------------------------

get_now() ->
    erlang:get(now).

get_now2() ->
    erlang:get(now2).

func(MapName, Fun) ->
    global:send(MapName, {func, Fun}).

-spec(broad_in_sence(MAP::integer() | list(), RoleIdList::list(), Module::integer(), 
                     Method::integer(), DataRecord::tuple()) -> ok).
broad_in_sence(MAP, RoleIdList, Module, Method, DataRecord) 
  when is_list(RoleIdList) andalso is_integer(MAP) ->
    MapName = common_map:get_common_map_name(MAP),
    case global:whereis_name(MapName) of
        undefined ->
            ?ERROR_MSG("map ~w not started !!!", [MAP]);
        PID ->
            PID !  {broadcast_in_sence, RoleIdList, Module, Method, DataRecord}
    end,
    ok;
broad_in_sence(MAP, RoleIdList, Module, Method, DataRecord) 
  when is_list(RoleIdList) andalso is_list(MAP) ->
    case global:whereis_name(MAP) of
        undefined ->
            ?ERROR_MSG("map ~w not started !!!", [MAP]);
        PID ->
            PID ! {broadcast_in_sence, RoleIdList, Module, Method, DataRecord}
    end,
    ok;
broad_in_sence(MAP, RoleIdList, Module, Method, DataRecord) ->
    ?ERROR_MSG("wrong broad_in_sence all ~w ~w ~w ~w ~w", 
               [MAP, RoleIdList, Module, Method, DataRecord]),
    ok.


-spec(broad_in_sence_include(MAP::integer()|list(), RoleIDList::list(), Module::integer(), 
                             Method::integer(), DataRecord::tuple()) -> ok).
broad_in_sence_include(MAP, RoleIDList, Module, Method, DataRecord) 
  when is_list(RoleIDList) andalso is_integer(MAP) ->
    MapName = common_map:get_common_map_name(MAP),
    case global:whereis_name(MapName) of
        undefined ->
            ?ERROR_MSG("map ~w not started !!!", [MAP]);
        _ ->
            global:send(MapName, {broadcast_in_sence_include, RoleIDList, Module, Method, DataRecord})
    end,
    ok;
broad_in_sence_include(MAP, RoleIDList, Module, Method, DataRecord) 
  when is_list(RoleIDList) andalso is_list(MAP) ->
    case global:whereis_name(MAP) of
        undefined ->
            ?ERROR_MSG("map ~w not started !!!", [MAP]);
        _ ->
            global:send(MAP, {broadcast_in_sence_include, RoleIDList, Module, Method, DataRecord})
    end,
    ok;
broad_in_sence_include(MAP, RoleIDList, Module, Method, DataRecord) ->
    ?ERROR_MSG("wrong broad_in_sence all ~w ~w ~w ~w ~w", 
               [MAP, RoleIDList, Module, Method, DataRecord]),
    ok.

broadcast_to_whole_map(Module, Method, Record) ->
    State = get_state(),
    Pg2 = State#map_state.pg2_name,
    lists:foreach(
      fun(PID) ->
              PID ! {message, ?DEFAULT_UNIQUE, Module, Method, Record}
      end, pg22:get_members(Pg2)).

%%获取当前地图中所有玩家的ID，绝对不要乱用
get_all_roleid() ->
    mod_map_actor:get_in_map_role().
get_all_roleid(_State) ->
    mod_map_actor:get_in_map_role().
    

%% --------------------------------------------------------------------
%% API : start_link
%% --------------------------------------------------------------------

start_link({MapProcessName, MapID}) ->
    case ets:lookup(?ETS_MAPS, MapID) of
        [{MapID, 1}] ->
            gen_server:start_link(?MODULE, [MapProcessName, MapID], [{spawn_opt, [{min_heap_size, 10*1024}, {min_bin_vheap_size, 10*1024}]}]);
        _ ->
            gen_server:start_link(?MODULE, [MapProcessName, MapID], [{spawn_opt, [{min_heap_size, 1024}, {min_bin_vheap_size, 1024}]}])
    end.

%% --------------------------------------------------------------------
%% API for state lookup
%% --------------------------------------------------------------------


init([MapProcessName, MAPIdIn]) ->
    MAPID = common_tool:to_integer(MAPIdIn),
    yes = global:register_name(MapProcessName, erlang:self()),
    erlang:put(is_map_process, true),
    erlang:process_flag(trap_exit, true),
    %%读取地图数据
    case ets:lookup(?ETS_IN_MAP_DATA, MAPID) of
        [{MAPID, {MAPID, GridWidth, GridHeight, OffsetX, OffsetY, _MaxTX, _MaxTY, Data}}] ->
            random:seed(now()),
            %%用于保存在该地图中的玩家
            Name = lists:concat(["pg22_virtual_world_client_list_", MapProcessName]),
            pg22:create(Name),
            %%初始化进程字典的一些信息
            lists:foreach(
              fun({{TX, TY}, PassType}) ->
                      erlang:put({ref, TX, TY}, []),
                      erlang:put({TX, TY}, PassType)
              end, Data),
            %%摆摊区
            [{{stall, MAPID}, DataStall}] = ets:lookup(?ETS_IN_MAP_DATA, {stall, MAPID}),
            lists:foreach(
              fun({TX, TY}) ->
                      put({can_stall, TX, TY}, true)
              end, DataStall),
            
            %%竞技区
            [{{reado, MAPID}, DataRedo}] = ets:lookup(?ETS_IN_MAP_DATA, {reado, MAPID}),
            lists:foreach(
              fun({TX, TY}) ->
                      put({reado_area, TX, TY}, true)
              end, DataRedo),
            
            %%初始化九宫格的slice
            init_slice_lists(MapProcessName, GridWidth,GridHeight),
            
            State = #map_state{mapid=MAPID, pg2_name=Name, offsetx=OffsetX, offsety=OffsetY,  map_name=MapProcessName, 
                               grid_width=GridWidth, grid_height=GridHeight},
            init_state(State),
            erlang:self() ! loop,
            erlang:self() ! loop_ms,
            mod_map_collect:init(MAPID,OffsetX,OffsetY),
            hook_map:init(MAPID, MapProcessName),
            mod_map_actor:init_in_map_role(),
            %%地图陷阱列表
            erlang:put(map_trap_list, []),
            %%零点精力值恢复
            erlang:send_after(common_time:diff_next_daytime(0, 0)*1000, self(), do_at_oclock),
            common_map:set_map_family_id(MapProcessName,MAPID),
            catch db:dirty_write(?DB_MAP_ONLINE, #r_map_online{map_name=MapProcessName, map_id=MAPID, online=0, node=node()}),
            {ok, State};
        [] ->
            {stop, can_not_read_map_data}
    end.


%% --------------------------------------------------------------------

handle_call(Request, _From, State) ->
    Reply = do_handle_call(Request, State),
    {reply, Reply, State}.

handle_cast({map_chat, Content}, #map_state{pg2_name=Pg22} = State) ->
    catch lists:foreach(fun(ClientPid) -> ClientPid ! {map_chat, Content} end, pg22:get_members(Pg22)),
    {noreply, State};
handle_cast(Msg, State) ->
    ?DEBUG("unexpected msg ~w ~w", [Msg, State]),
    {noreply, State}.


handle_info({'EXIT', PID, Reason}, State) ->
    MapID = get_mapid(),
    case ets:lookup(?ETS_MAPS, MapID) of
        [{_, 1}] ->
            ignore;
        _ ->
            %%这里是为了记录副本地图挂掉的原因
            ?ERROR_MSG("严重！！ map exit: MapID=~w,Reason=~w,PID=~w,State=~w", [MapID,Reason,PID,State])
    end,
    {stop, normal, State};

handle_info(Info, State) ->
    try 
        do_handle_info(Info, State) 
    catch
        T:R ->
            case Info of
                {_Unique, _Module, _Method, DataRecord, RoleID, _Pid, _Line}->
                    ?ERROR_MSG("module: ~w, line: ~w, Info:~w, type: ~w, reason: ~w,DataRecord=~w,RoleID=~w,stactraceo: ~w",
                               [?MODULE, ?LINE, Info, T, R,DataRecord,RoleID,erlang:get_stacktrace()]);
                _ ->
                    ?ERROR_MSG("module: ~w, line: ~w, Info:~w, type: ~w, reason: ~w,stactraceo: ~w",
                               [?MODULE, ?LINE, Info, T, R,erlang:get_stacktrace()])
            end
    end,
    {noreply, State}.


terminate(Reason, State) ->
    hook_map:terminate(),
    %%从DB_MAP_ONLINE中删除
    MapName = State#map_state.map_name, 
    catch db:dirty_delete(?DB_MAP_ONLINE,MapName),
    case Reason =:= normal of
        true ->
            ignore;
        false ->
            ?ERROR_MSG("map terminate : ~w , state: ~w", [Reason, State])
    end,
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------

%% 断开连接
do_handle_call({client_exit, RoleID, PID}, State) ->
    catch mod_map_role:handle({client_exit, RoleID, PID}, State),
    ok;
%% 踢摊位下线
do_handle_call({kick_role_stall, RoleID}, _State) ->
    catch mod_stall:handle({kick_role_stall, RoleID});
do_handle_call(_Request, _State) ->
    {error, unknow_call}.

%% ---------------- Macro -------------------------------------
%% 调用handle/2 的缩写
-define(MODULE_HANDLE_TWO(Module,HandleModule),
    do_handle_info({Unique, Module, Method, DataIn, RoleID, PID, Line}, State) ->
    HandleModule:handle({Unique, Module, Method, DataIn, RoleID, PID, Line}, State)).
%% 调用handle/1 的缩写
-define(MODULE_HANDLE_ONE(Module,HandleModule),
    do_handle_info({Unique, Module, Method, DataIn, RoleID, PID, Line}, _State) ->
    HandleModule:handle({Unique, Module, Method, DataIn, RoleID, PID, Line})).
%% 调用handle/1 同时带上State参数的缩写
-define(MODULE_HANDLE_ONE_STATE(Module,HandleModule),
    do_handle_info({Unique, Module, Method, DataIn, RoleID, PID, Line}, State) ->
    HandleModule:handle({Unique, Module, Method, DataIn, RoleID, PID, Line, State})).

%%对指定的模块发送消息，通用，建议使用
do_handle_info({mod,Module,Msg}, State) ->
    Module:handle(Msg,State);
%%对在线玩家发送指定的消息
do_handle_info({unicast,RoleID,Module,Method,Record}, _State) 
  when is_integer(RoleID),is_integer(Module),is_integer(Method) ->
    common_misc:unicast({role,RoleID},?DEFAULT_UNIQUE,Module,Method,Record);
do_handle_info({mod_conlogin, Msg}, _State) ->
    mod_conlogin:handle(Msg);
do_handle_info({mod_map_actor,Msg}, State) ->
    mod_map_actor:handle(Msg,State);
do_handle_info({mod_map_monster,Msg}, State) ->
    mod_map_monster:handle(Msg,State);
%%怪物，角色和其他精灵共有的信息
do_handle_info({mod_map_role,Msg}, State) ->
    mod_map_role:handle(Msg,State);
do_handle_info({mod_stall, Msg}, _State) ->
    mod_stall:handle(Msg);
do_handle_info({mod_stall_list, Msg}, _State) ->
    mod_stall_list:handle(Msg);
do_handle_info({mod_system_notice, Msg}, _State) ->
    mod_system_notice:handle(Msg);
do_handle_info({mod_exchange, Msg}, State) ->
    mod_exchange:handle(Msg,State);
do_handle_info({mod_training, Msg}, _State) ->
    mod_training:handle(Msg);
do_handle_info({mod_team_exp, Msg}, _State) ->
    mod_team_exp:handle(Msg);
do_handle_info({mod_goods, Msg}, _State) ->
    mod_goods:handle(Msg);
do_handle_info({mod_map_drop,Msg}, State) ->
    mod_map_drop:handle(Msg,State);
do_handle_info({mod_accumulate_exp, Msg}, _State) ->
    mod_accumulate_exp:handle(Msg);
do_handle_info({mod_fight,Msg}, State) ->
    mod_fight:handle(Msg,State);
do_handle_info({mod_map_family,Msg}, State) ->
    mod_map_family:handle(Msg,State);
do_handle_info({mod_warofking, Msg}, State) ->
    mod_warofking:handle(Msg, State);
do_handle_info({mod_map_ybc,Msg}, State) ->
    mod_map_ybc:handle(Msg,State);
do_handle_info({mod_educate, Msg}, _State) ->
    mod_educate:handle(Msg);
do_handle_info({mod_ybc_family, Msg}, State) ->
    mod_ybc_family:handle(Msg, State);
do_handle_info({mod_map_admin,Msg}, State) ->
    mod_map_admin:handle(Msg,State);
do_handle_info({mod_bag_handler,Msg}, State) ->
    mod_bag_handler:handle(Msg,State);
do_handle_info({mod_waroffaction, Msg}, State) ->
    mod_waroffaction:handle(Msg, State);
do_handle_info({mod_map_collect,Msg},State) ->
    mod_map_collect:handle({Msg,State});
do_handle_info({mod_gm,Msg}, State) ->
    mod_gm:handle(Msg,State);
do_handle_info({mod_flowers,Msg},State) ->
    mod_flowers:handle({Msg,State});
do_handle_info({mod_server_npc, Msg}, State) ->
    mod_server_npc:handle(Msg, State);
do_handle_info({mod_map_pet, Msg}, State) ->
    mod_map_pet:handle(Msg, State);
do_handle_info({mod_map_office,Msg},State) ->
    mod_map_office:handle(Msg,State);
%% 信件处理
do_handle_info({mod_letter,Msg},_State)->
    mod_letter:handle(Msg);
%% 英雄副本
do_handle_info({mod_hero_fb, Msg}, _State) ->
    mod_hero_fb:handle(Msg);
%% VIP
do_handle_info({mod_vip, Msg}, _State) ->
    mod_vip:handle(Msg);
do_handle_info({mod_skill, Msg}, _State) ->
    mod_skill:handle(Msg);
do_handle_info({mod_pk, Msg}, MapState) ->
    mod_pk:handle(Msg, MapState);
do_handle_info({mod_equip, Msg}, _MapState) ->
    mod_equip:handle(Msg);

do_handle_info({mod_goal, Msg}, _State) ->
    mod_goal:handle(Msg);
do_handle_info({mod_activity, Msg}, _State) ->
    mod_activity:handle(Msg);
%% 刷棋副本
do_handle_info({mod_shuaqi_fb,Msg},_State)->
    mod_shuaqi_fb:handle(Msg);
%% 练功房
do_handle_info({mod_exercise_fb,Msg},_State)->
    mod_exercise_fb:handle(Msg);
%% 组队前端请求消息处理
%%推荐队友。。悲剧的放到这里
do_handle_info({Unique, ?TEAM, ?TEAM_MEMBER_RECOMMEND, _DataRecord, RoleID, _PID, Line}, State) ->
    #map_state{pg2_name=PG2} = State,
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            do_team_recommend_error(Unique, ?TEAM, ?TEAM_MEMBER_RECOMMEND, RoleID, ?_LANG_SYSTEM_ERROR, Line);
        RoleMapInfo ->
            #p_map_role{faction_id=FactionID} = RoleMapInfo,
            do_team_recommend(Unique, ?TEAM, ?TEAM_MEMBER_RECOMMEND, RoleID, FactionID, Line, pg22:get_members(PG2), [], 0)
    end;

do_handle_info({Unique, ?TEAM, Method, DataIn, RoleID, Pid, _Line}, _State) ->
    mod_map_team:do_handle_info({Unique, ?TEAM, Method, DataIn, RoleID, Pid});

%% 组队服务端各节点通信消息处理
do_handle_info({mod_map_team, Msg}, _State) ->
    mod_map_team:do_handle_info(Msg);

%% 声望兑换功能
do_handle_info({Unique, ?PRESTIGE, Method, DataIn, RoleID, Pid, _Line}, _State) ->
    mod_prestige:do_handle_info({Unique, ?PRESTIGE, Method, DataIn, RoleID, Pid});
%% 组队服务端各节点通信消息处理
do_handle_info({mod_prestige, Msg}, _State) ->
    mod_prestige:do_handle_info(Msg);
    
do_handle_info({mod_special_activity,Msg},_State) ->
    mod_special_activity:handle(Msg);
    
%% 门派采集TD
do_handle_info({mod_family_collect, Msg}, State) ->
    mod_family_collect:handle(Msg, State);

do_handle_info({'DOWN', _, _, PID, _}, State) ->
    mod_map_role:handle({role_exit, PID}, State);

%%客户端发来的消息以及剩余的直接在map模块中处理的消息
do_handle_info({Unique, ?BUBBLE, ?BUBBLE_SEND, DataRecord, RoleID, _Pid, Line}, State) ->
    ReturnDataRecord = #m_bubble_send_toc{succ=true},
    common_misc:unicast(Line, RoleID, Unique, ?BUBBLE, ?BUBBLE_SEND, ReturnDataRecord),
    mod_map_role:handle({bubble_msg, RoleID, Line, DataRecord}, State);
%%掉落物处理
do_handle_info({Unique, ?MAP, ?MAP_DROPTHING_PICK, DataIn, RoleID, Pid, _Line}, State) ->
    mod_map_drop:handle({Unique, ?MAP, ?MAP_DROPTHING_PICK, DataIn, RoleID, Pid}, State);
%%处理获取目标地图信息请求
do_handle_info({Unique, ?MAP, ?MAP_UPDATE_ACTOR_MAPINFO, DataIn, RoleID, _PID, _Line}, State) ->
    mod_map_actor:handle({Unique, ?MAP, ?MAP_UPDATE_ACTOR_MAPINFO, DataIn, RoleID}, State);
%%战斗模块
do_handle_info({Unique, ?FIGHT, Method, DataIn, RoleID, PID, Line}, State) ->
    %%一旦战斗就代表玩家停止下来了，所以就需要清楚玩家的最后移动路径了
    mod_map_actor:erase_actor_pid_lastwalkpath(RoleID,role),
    mod_map_actor:erase_actor_pid_lastkeypath(RoleID,role),
    mod_fight:handle({Unique, ?FIGHT, Method, DataIn, RoleID, PID, Line}, State);

do_handle_info({Unique, ?SYSTEM, Method, DataIn, RoleID, _PID, Line}, _State) ->
    mod_system:handle({Unique, ?SYSTEM, Method, DataIn, RoleID, Line});

%%玩家走路模块处理
?MODULE_HANDLE_TWO(?MOVE,mod_map_role);
?MODULE_HANDLE_TWO(?WAROFKING,mod_warofking);
?MODULE_HANDLE_TWO(?WAROFFACTION,mod_waroffaction);
?MODULE_HANDLE_TWO(?EQUIP_BUILD,mod_equip_build);
?MODULE_HANDLE_TWO(?EXCHANGE,mod_exchange);
?MODULE_HANDLE_TWO(?PET,mod_map_pet);
?MODULE_HANDLE_TWO(?FAMILY_COLLECT,mod_family_collect);
?MODULE_HANDLE_TWO(?FAMILY,mod_map_family);
?MODULE_HANDLE_TWO(?MONSTER,mod_map_monster);  %% 给进入副本请求怪物类型

?MODULE_HANDLE_ONE(?WAROFCITY,mod_warofcity);
?MODULE_HANDLE_ONE(?STALL,mod_stall);
?MODULE_HANDLE_ONE(?GOODS,mod_goods);
?MODULE_HANDLE_ONE(?STONE,mod_stone);
?MODULE_HANDLE_ONE(?CONLOGIN,mod_conlogin);

?MODULE_HANDLE_ONE(?PRESENT,mod_present);
?MODULE_HANDLE_ONE(?ACCUMULATE_EXP,mod_accumulate_exp);
?MODULE_HANDLE_ONE(?ACTIVITY,mod_activity);
?MODULE_HANDLE_ONE(?NEWCOMER,mod_newcomer);
?MODULE_HANDLE_ONE(?FMLDEPOT,mod_map_fmldepot);
?MODULE_HANDLE_ONE(?GIFT,mod_gift);
?MODULE_HANDLE_ONE(?TRADING,mod_trading);
?MODULE_HANDLE_ONE(?COUNTRY_TREASURE,mod_country_treasure);
?MODULE_HANDLE_ONE(?EDUCATE_FB,mod_educate_fb);
?MODULE_HANDLE_ONE(?SCENE_WAR_FB,mod_scene_war_fb);
?MODULE_HANDLE_ONE(?GOAL, mod_goal);
?MODULE_HANDLE_ONE(?EXERCISE_FB, mod_exercise_fb);
%% 活动
?MODULE_HANDLE_ONE(?SPECIAL_ACTIVITY,mod_special_activity);

?MODULE_HANDLE_ONE_STATE(?FLOWERS,mod_flowers);
?MODULE_HANDLE_ONE_STATE(?EQUIP,mod_equip);
?MODULE_HANDLE_ONE_STATE(?ITEM,mod_item);
?MODULE_HANDLE_ONE_STATE(?REFINING,mod_refining);
?MODULE_HANDLE_ONE_STATE(?SHOP,mod_shop);
?MODULE_HANDLE_ONE_STATE(?DEPOT,mod_depot);
?MODULE_HANDLE_ONE(?SKILL,mod_skill);
?MODULE_HANDLE_ONE_STATE(?LETTER,mod_letter);
?MODULE_HANDLE_ONE_STATE(?PLANT,mod_map_family_plant);
?MODULE_HANDLE_ONE_STATE(?LEVEL_GIFT,mod_level_gift);
?MODULE_HANDLE_ONE_STATE(?SHUAQI_FB,mod_shuaqi_fb);

%% 第一次进入地图
do_handle_info({first_enter, Info}, State) ->
    mod_map_actor:handle({first_enter, Info}, State);

%%传送卷
do_handle_info({Unique, ?MAP, ?MAP_TRANSFER, DataIn, RoleID, _PID, Line}, State) ->
    mod_map_transfer:handle({Unique, ?MAP, ?MAP_TRANSFER, DataIn, RoleID, _PID, Line}, State);

do_handle_info({Unique, ?MAP, ?MAP_ENTER, DataIn, RoleID, PID, Line}, State) ->
    do_map_enter(Unique, ?MAP, ?MAP_ENTER, DataIn, RoleID, PID, Line, State);

do_handle_info({Unique, ?MAP, ?MAP_CHANGE_MAP, DataIn, RoleID, PID, _Line}, _State) ->
    do_change_map(Unique, ?MAP, ?MAP_CHANGE_MAP, DataIn, RoleID, PID);

do_handle_info({Unique, ?MISSION, Method, DataIn, RoleID, _PID, Line}, _State) ->
    mod_mission_handler:handle({Method, Unique, RoleID, Line, DataIn});

do_handle_info({Unique, ?DRIVER, Method, DataIn, RoleID, _PID, Line}, State) ->
    mod_driver:handle({Unique, ?DRIVER, Method, DataIn, RoleID, Line, State});

do_handle_info({Unique, ?TITLE, Method, DataIn, RoleID, _PID, Line}, _State) ->
    mod_title:handle({Unique, ?TITLE, Method, DataIn, RoleID, Line});

do_handle_info({Unique, ?SHORTCUT, Method, DataIn, RoleID, _PID, Line}, _State) ->
    mod_shortcut:handle({Unique, ?SHORTCUT, Method, DataIn, RoleID, Line});

%% 排行榜
do_handle_info({Unique, ?RANKING, ?RANKING_EQUIP_JOIN_RANK, DataIn, RoleID, Pid, Line}, _State) ->
    do_ranking_equip_join_rank(Unique, ?RANKING, ?RANKING_EQUIP_JOIN_RANK, DataIn, RoleID, Pid, Line);

%% 国探开启
do_handle_info({mod_spy, Msg}, _MapState) ->
    mod_spy:handle(Msg);
%% 采集
?MODULE_HANDLE_ONE_STATE(?COLLECT,mod_map_collect);
%% Role2
?MODULE_HANDLE_ONE_STATE(?ROLE2,mod_role2);

do_handle_info({mod_role2, Msg}, _MapState) ->
    mod_role2:handle(Msg);
%% 一键换装
?MODULE_HANDLE_ONE_STATE(?EQUIPONEKEY,mod_equip_onekey);
%% 训练营
?MODULE_HANDLE_ONE_STATE(?TRAININGCAMP,mod_training);
%% 喇叭
?MODULE_HANDLE_ONE_STATE(?BROADCAST,mod_broadcast);
%% 刺探
?MODULE_HANDLE_ONE_STATE(?SPY,mod_spy);
%% 监狱
?MODULE_HANDLE_ONE_STATE(?JAIL,mod_jail);
%% VIP
?MODULE_HANDLE_ONE_STATE(?VIP,mod_vip);
%% 英雄副本
?MODULE_HANDLE_ONE_STATE(?HERO_FB,mod_hero_fb);
%% 任务个人副本
?MODULE_HANDLE_ONE_STATE(?MISSION_FB,mod_mission_fb);
%% 篝火
?MODULE_HANDLE_ONE_STATE(?BONFIRE,mod_map_bonfire);

%% 成就系统处理模块
do_handle_info({Unique, ?ACHIEVEMENT, ?ACHIEVEMENT_NOTICE, DataRecord, RoleID, Line}, _State) ->
    %% ?DEBUG("~ts,DataRecord=~w",["接收到的消息为",DataRecord]),
    mod_achievement:do_handle_info({Unique, ?ACHIEVEMENT, ?ACHIEVEMENT_NOTICE, DataRecord, RoleID, Line});
do_handle_info({Unique, ?ACHIEVEMENT, Method, DataRecord, RoleID, _PID, Line}, _State) ->
    %% ?DEBUG("~ts,Method=~w,DataRecord=~w",["接收到的消息为",Method,DataRecord]),
    mod_achievement:do_handle_info({Unique, ?ACHIEVEMENT, Method, DataRecord, RoleID, Line});
do_handle_info({mod_achievement,Msg}, _State) ->
    mod_achievement:do_handle_info(Msg);

do_handle_info({Unique, ?PERSONYBC, Method, DataIn, RoleID, _PID, Line}, State) ->
    mod_ybc_person:handle({Unique, ?PERSONYBC, Method, DataIn, RoleID, _PID,Line, State});

%%处理管理后台开启国运
do_handle_info({mod_ybc_person,Msg},_State) ->
    mod_ybc_person:handle(Msg);
do_handle_info({mod_mission_fb, Msg}, _State) ->
    mod_mission_fb:handle(Msg);

%% 逐鹿天下副本模块处理
do_handle_info({Unique, ?VIE_WORLD_FB, Method, DataRecord, RoleID, _PID, Line}, _State) ->
    mod_vie_world_fb:do_handle_info({Unique, ?VIE_WORLD_FB, Method, DataRecord, RoleID, Line});
do_handle_info({mod_vie_world_fb,Msg}, _State) ->
    mod_vie_world_fb:do_handle_info(Msg);

%% 天工炉炼制模块处理，主要用于内部消息处理
do_handle_info({mod_refining_forging,Msg},_State) ->
    mod_refining_forging:do_handle_info(Msg);
%% 天工炉天工开物，主要用于内部消息处理
do_handle_info({mod_refining_box,Msg},_State) ->
    mod_refining_box:do_handle_info(Msg);

%% 商贸活动
do_handle_info({mod_trading,Msg},_State) ->
    mod_trading:do_handle_info(Msg);

%% 大明宝藏副本
do_handle_info({mod_country_treasure,Msg},_State) ->
    mod_country_treasure:do_handle_info(Msg);

%% 师门同心副本
do_handle_info({mod_educate_fb,Msg},_State) ->
    mod_educate_fb:do_handle_info(Msg);

%% 场景大战副本
do_handle_info({mod_scene_war_fb,Msg},_State) ->
    mod_scene_war_fb:do_handle_info(Msg);

%% 礼包模块
do_handle_info({mod_gift,Msg},_State) ->
    mod_gift:do_handle_info(Msg);

%%篝火
do_handle_info({mod_map_bonfire,Msg}, _State) ->
    mod_map_bonfire:handle(Msg);

%%调用任务handler
do_handle_info({mod_mission_handler, Msg},_State) ->
    mod_mission_handler:handle(Msg);
do_handle_info({hook_mission_event,Msg},_State) ->
    hook_mission_event:handle(Msg);

do_handle_info(loop_ms, State) -> 
    %%modified by zesen,修改为200ms
    erlang:send_after(200, self(), loop_ms),
    erlang:put(now2, common_tool:now2()),
    hook_map:loop_ms(),
    mod_map_monster:do_work(),
    {noreply, State};
%%地图每秒大循环
do_handle_info(loop, State) ->
    erlang:send_after(1000, self(), loop),
    erlang:put(now, common_tool:now()),
    MapID = State#map_state.mapid,
    hook_map:loop(MapID),
    {noreply, State};
%%slice内广播
do_handle_info({broadcast_in_sence, RoleIDList, Module, Method, DataRecord}, State) 
  when is_list(RoleIDList) ->
    %%转换格式，这个接口本身只提供给role用
    ActorList = lists:foldl(fun(ID, Acc0) -> [{role, ID} | Acc0] end, [], RoleIDList),
    do_broadcast_insence(ActorList, Module, Method, DataRecord, State);
%%可视范围广播 
do_handle_info({broadcast_in_sence_include, RoleIDList, Module, Method, DataRecord}, State) ->
    ActorList = lists:foldl(fun(ID, Acc0) -> [{role, ID} | Acc0] end, [], RoleIDList),
    do_broadcast_insence_include(ActorList, Module, Method, DataRecord, State);

%%@doc 每天零点处理的事情
do_handle_info(do_at_oclock, State) ->
    erlang:send_after(common_time:diff_next_daytime(0, 0)*1000, self(), do_at_oclock),    
    hook_at_oclock:hook( get_all_roleid(State) ),
    ok;

do_handle_info({change_attr,family_contribute,RoleID,Value},_State) ->
    mod_map_role:update_role_attr({family_contribute,Value},RoleID),
    ok;    

do_handle_info({enter_family_map, Unique, RoleID, FamilyID, Line, BonfireBurnTime}, _State) ->
    
    IsDoingYbc = common_map:is_doing_ybc(RoleID),
    Module = ?MAP,Method = ?MAP_CHANGE_MAP,
    if
        IsDoingYbc =:= true ->
            ?SEND_ERR_TOC(m_map_change_map_toc,?_LANG_FAMILY_DOING_YBC_CAN_NOT_CHANGE);
        true ->
            MapName = common_map:get_family_map_name(FamilyID),
            case global:whereis_name(MapName) of
                undefined ->
                    ?SEND_ERR_TOC(m_map_change_map_toc,?_LANG_FAMILY_MAP_NOT_STARTED),
                    mod_map_copy:create_family_map_copy(FamilyID, BonfireBurnTime);
                _ ->
                    MapID = 10300,
                    {MapID, TX, TY} = common_misc:get_born_info_by_map(MapID),
                    R = #m_map_change_map_toc{mapid=MapID, tx=TX, ty=TY},
                    common_misc:unicast(Line, RoleID, Unique, ?MAP, ?MAP_CHANGE_MAP, R)
            end
    end;

do_handle_info({func, Fun, Args}, State) ->
    Ret = (catch apply(Fun,Args)),
    ?ERROR_MSG("~w",[Ret]),
    {noreply, State};

do_handle_info(Info, State) ->
    if is_tuple(Info) ->
            ?DEBUG("~w: info=~w",[?DEPOT,erlang:element(2,Info)]),
            ok; 
       true ->
            ?DEBUG("~ts: ~w, ~w", ["未知信息", Info, State]),
            ok
    end.


get_slice_name(SX, SY) -> 
    get({slice_name, SX, SY}).


%%根据txty获得sxsy
get_sxsy_by_txty(TX, TY) ->
    State = get_state(),
    #map_state{offsetx=OffsetX, offsety=OffsetY} = State,
    {PX, PY} = common_misc:get_iso_index_mid_vertex(TX, 0, TY),
    PXC = PX + OffsetX,
    PYC = PY + OffsetY,
    SX = common_tool:floor(PXC/?MAP_SLICE_WIDTH),
    SY = common_tool:floor(PYC/?MAP_SLICE_HEIGHT),
    {SX, SY}.
    

%%根据SXSY获得摊位列表
get_slice_stalls(SliceName) ->
    get({slice_stalls, SliceName}).
add_slice_stall(TX, TY, Stall) ->
    {SX, SY} = get_sxsy_by_txty(TX, TY),
    ?DEBUG("~w ~w ~w ~w", [TX, TY, SX, SY]),
    SliceName = get_slice_name(SX, SY),
    Old = get_slice_stalls(SliceName),
    ?DEBUG("~w ~w", [SliceName, Old]),
    case lists:member(Stall, Old) of
        true ->
            ignore;
        false ->
            put({slice_stalls, SliceName}, [Stall | Old])
    end.
remove_slice_stall(TX, TY, Stall) ->
    {SX, SY} = get_sxsy_by_txty(TX, TY),
    case get_slice_name(SX, SY) of
        undefined ->
            ignore;
        SliceName ->
            Old = get_slice_stalls(SliceName),
            put({slice_stalls, SliceName}, lists:delete(Stall, Old))
    end.

%%根据SXSY获取陷阱列表
get_slice_trap(SliceName) ->
    get({slice_trap, SliceName}).

add_slice_trap(TX, TY, MapTrap) ->
    {SX, SY} = get_sxsy_by_txty(TX, TY),
    SliceName = get_slice_name(SX, SY),
    TrapList = get_slice_trap(SliceName),

    case lists:member(MapTrap, TrapList) of
        true ->
            ignore;
        _ ->
            put({slice_trap, SliceName}, [MapTrap|TrapList])
    end,
    
    MapTrapList = get(map_trap_list),
    case lists:member(MapTrap, MapTrapList) of
        true ->
            ignore;
        _ ->
            put(map_trap_list, [MapTrap|MapTrapList])
    end.

remove_slice_trap(TX, TY, TrapID) ->
    {SX, SY} = get_sxsy_by_txty(TX, TY),
    SliceName = get_slice_name(SX, SY),
    TrapList = get_slice_trap(SliceName),
    MapTrapList = get(map_trap_list),
    
    put({slice_trap, SliceName}, lists:keydelete(TrapID, #p_map_trap.trap_id, TrapList)),
    put(map_trap_list, lists:keydelete(TrapID, #p_map_trap.trap_id, MapTrapList)).

%%拼凑一个slice的名字
concat_slice_name(MAPID, SX, SY) ->
    lists:concat(["pg22_map_slice_", MAPID, "_", SX, "_", SY]).


%%初始化每个slice对应的九宫格，避免之后的重复计算 
init_slice_lists(MapPName, GridWidth,GridHeight) ->
    X = common_tool:ceil(GridWidth/?MAP_SLICE_WIDTH) - 1,
    Y = common_tool:ceil(GridHeight/?MAP_SLICE_HEIGHT) - 1,
    %%为每个slice创建一个pg2，同初始化2每2个slice中的摊位信息为[]
    lists:foreach(
      fun(SX) ->
              lists:foreach(
                fun(SY) ->
                        SliceName = concat_slice_name(MapPName, SX, SY),
                        erlang:put({slice_name, SX, SY}, SliceName),
                        erlang:put({slice_stalls, SliceName}, []),
                        erlang:put({slice_ybc, SliceName}, []),
                        erlang:put({slice_role, SliceName}, []),
                        erlang:put({slice_monster, SliceName}, []),
                        erlang:put({slice_server_npc, SliceName}, []),
                        erlang:put({slice_pet, SliceName}, []),
                        mod_map_trap:init_slice_trap_list(SliceName),
                        pg22:create(SliceName)
                end, lists:seq(0, Y))
      end, lists:seq(0, X)),
    lists:foreach(
      fun(SX) ->
              lists:foreach(
                fun(SY) ->
                        Slices9 = get_9slices(X, Y, SX, SY),
                        put({slices, SX, SY}, Slices9)
                end, lists:seq(0, Y))
      end, lists:seq(0, X)).


get_9slices(SliceWidthMaxValue, SliceHeightMaxValue, SX, SY) ->
    if 
        SX > 0 ->
            BeginX = SX - 1;
        true ->
            BeginX = 0
    end,
    if
        SY > 0 ->
            BeginY = SY - 1;
        true ->
            BeginY = 0
    end,
    if 
        SX >= SliceWidthMaxValue ->
            EndX = SliceWidthMaxValue;
        true ->
            EndX = SX + 1
    end,
    if 
        SY >= SliceHeightMaxValue ->
            EndY = SliceHeightMaxValue;
        true ->
            EndY = SY + 1
    end,
    get_9_slice_by_tile_2(BeginX, BeginY, EndX, EndY).
get_9_slice_by_tile_2(BeginX, BeginY, EndX, EndY) ->
    lists:foldl(
      fun(TempSX, Acc) ->
              lists:foldl(
                fun(TempSY, AccSub) ->
                        Temp = get_slice_name(TempSX, TempSY),
                        [Temp|AccSub]
                end,
                Acc,
                lists:seq(BeginY, EndY)
               )
      end, [], lists:seq(BeginX, EndX)).


%%获得所有在slice list中的玩家
get_all_in_sence_user_by_slice_list(SliceList) ->
    lists:foldl(
      fun(SliceName, Acc) ->
			lists:merge(mod_map_actor:slice_get_roles(SliceName), Acc)
      end, [], SliceList).


%%slice变化时获得新的slice
get_new_around_slice(NewTX, NewTY, OldTX, OldTY, OffsetX, OffsetY) ->
    case get_9_slice_by_txty(NewTX, NewTY, OffsetX, OffsetY) of
        undefined ->
            [];
        TNew ->
            TOld = get_9_slice_by_txty(OldTX, OldTY, OffsetX, OffsetY),
            lists:filter(
              fun(T) -> 
                      case lists:member(T, TOld) of
                          true ->
                              false;
                          false ->
                              true
                      end
              end, TNew)
    end.


%%在actor列表可视范围内广播消息,不包括列表中actor
do_broadcast_insence(ActorList, Module, Method, DataRecord, State) when is_list(ActorList) ->
    AllSlice = get_9_slice_by_actorid_list(ActorList, State),
    ?DEBUG("AllSlice ~w", [AllSlice]),
    AllInSenceRole = get_all_in_sence_user_by_slice_list(AllSlice),
    %% remove them self
    ?DEBUG("AllInSenceUser ~w", [AllInSenceRole]),
    AllInSenceRole2 = 
        lists:foldl(
          fun({Type, RoleID}, Acc) ->
                  case Type of
                      role ->
                          lists:delete(RoleID, Acc);
                      _ ->
                          Acc
                  end
          end, AllInSenceRole, ActorList),
    ?DEBUG("AllInSenceUser2 ~w", [AllInSenceRole2]),
    broadcast(AllInSenceRole2, ?DEFAULT_UNIQUE, Module, Method, DataRecord);
do_broadcast_insence(ActorList, Module, Method, DataRecord, _) ->
    ?ERROR_MSG("do_broadcast_insence wrong args ~w ~w ~w ~w", 
               [ActorList, Module, Method, DataRecord]),
    ok.

%%用于特殊情况，托管摆摊时角色不在线
do_broadcast_insence_by_txty(TX, TY, Module, Method, DataRecord, State) ->
    OffsetX = State#map_state.offsetx,
    OffsetY = State#map_state.offsety,
    case get_9_slice_by_txty(TX, TY, OffsetX, OffsetY) of
        undefined ->
            ignore;
        Slices ->
            AllInSenceRole = get_all_in_sence_user_by_slice_list(Slices),
            broadcast(AllInSenceRole, ?DEFAULT_UNIQUE, Module, Method, DataRecord)
    end.

%%广播在actor列表中的所有actor的可视范围内的玩家，包括这些actor自己
do_broadcast_insence_include(ActorList, Module, Method, DataRecord, State) when is_list(ActorList) ->
    %% 获取列表中所有玩家所在九宫格
    AllSlice = get_9_slice_by_actorid_list(ActorList, State),
    %% 所有所有的视野范围内玩家
    AllInSenceRole = get_all_in_sence_user_by_slice_list(AllSlice),
    broadcast(AllInSenceRole, ?DEFAULT_UNIQUE, Module, Method, DataRecord);
do_broadcast_insence_include(ActorList, Module, Method, DataRecord, _) ->
    ?ERROR_MSG("do_broadcast_insence_include ~ts: ~w ~w ~w ~w", ["出错", ActorList, Module, Method, DataRecord]).

update_role_msg_queue(PID, Binary) ->
    erlang:put({role_msg_queue, PID}, [Binary | erlang:get({role_msg_queue, PID})]).

broadcast(RoleIDList, _Module, _Method, _DataRecord)
  when erlang:length(RoleIDList) =:= 0 ->
    ignore;
broadcast(RoleIDList, Module, Method, DataRecord)
  when is_list(RoleIDList) andalso is_integer(Module) andalso is_integer(Method) ->
    Binary = mgeeg_packet:packet_encode(?DEFAULT_UNIQUE, Module, Method, DataRecord),
    lists:foreach(
      fun(RoleID) ->
              case get({roleid_to_pid,RoleID}) of
                  undefined ->
                      ignore;
                  PID ->
                      update_role_msg_queue(PID, Binary)
              end
      end, RoleIDList),
    ok.

broadcast(RoleIDList, RoleIDList2, _Unique, Module, Method, DataRecord) ->
    broadcast(RoleIDList, Module, Method, DataRecord),
    broadcast(RoleIDList2, Module, Method, DataRecord),
    ok.

broadcast(RoleIDList, _Unique, Module, Method, DataRecord)
  when is_list(RoleIDList) andalso is_integer(Module) andalso is_integer(Method) ->
    broadcast(RoleIDList, Module, Method, DataRecord),
    ok.

flush_all_role_msg_queue() ->
    lists:foreach(
      fun(RoleID) ->
              case get({roleid_to_pid,RoleID}) of
                  undefined ->
                      ignore;
                  PID ->                      
                      case erlang:get({role_msg_queue, PID}) of
                          [] ->
                              ignore;
                          List ->                              
                              PID ! {binaries, lists:reverse(List)},
                              erlang:put({role_msg_queue, PID}, [])
                      end
              end
      end, mgeem_map:get_all_roleid()).  


%%根据格子或者像素位置获得所在的slice名称
get_slice_by_txty(TX, TY, OffsetX, OffsetY) ->
    {PX, PY} = common_misc:get_iso_index_mid_vertex(TX, 0, TY),
    PXC = PX + OffsetX,
    PYC = PY + OffsetY,
    get_slice_by_pxpy(PXC, PYC).
get_slice_by_pxpy(PX, PY) ->
    SX = common_tool:floor(PX/?MAP_SLICE_WIDTH),
    SY = common_tool:floor(PY/?MAP_SLICE_HEIGHT),
    get_slice_name(SX, SY).


%%根据格子所在位置获得九宫格slice
get_9_slice_by_txty(TX, TY, OffsetX, OffsetY) ->
    {PX, PY} = common_misc:get_iso_index_mid_vertex(TX, 0, TY),
    PXC = PX + OffsetX,
    PYC = PY + OffsetY,
    SX = common_tool:floor(PXC/?MAP_SLICE_WIDTH),
    SY = common_tool:floor(PYC/?MAP_SLICE_HEIGHT),
   %% ?DEBUG("get_9_slice_by_pxpy(~w, ~w)", [SX, SY]),
    get({slices, SX, SY}).


%%获得actorid列表中actor所在的所有slice
%% 形式为 [{role, 1}, {monster, 2}, {pet, 2}]
%%actor包括role pet monster
get_9_slice_by_actorid_list(ActorIdList, State) ->
    OffsetX = State#map_state.offsetx,
    OffsetY = State#map_state.offsety,
    lists:foldl(
      fun({ActorType, ActorID}, Acc) ->
              case mod_map_actor:get_actor_txty_by_id(ActorID, ActorType) of
                  {TX, TY} ->
                     % ?DEBUG("monster [~w] tx ~w ty ~w", [ActorID, TX, TY]),
                      case mgeem_map:get_9_slice_by_txty(TX, TY, OffsetX, OffsetY) of
                          undefined ->
                              Acc;
                          Slices ->
                              common_tool:combine_lists(Acc, Slices)
                      end;
                  undefined ->
                      Acc
              end
      end, [], ActorIdList).


%%方便获得state
get_state() ->
    get(?MAP_STATE_KEY).
init_state(State) ->
    put(?MAP_STATE_KEY, State).

get_mapid() ->
    State = get_state(),
    State#map_state.mapid.

get_mapname() ->
    State = get_state(),
    State#map_state.map_name.

do_map_enter(Unique, Module, Method, DataIn, RoleID, PID, Line, State) ->
    %%找不到地角色的地图信息的话直接踢掉。。。
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            mgeem_router:kick_role(RoleID, Line, cant_find_mapinfo);
        RoleMapInfo ->
            MapID = State#map_state.mapid,
            #m_map_enter_tos{map_id=DestMapID} = DataIn,
            %%[{_, Type}], Type =:= 0 -> 普通的地图跳转; Type =:= 1 -> 副本地图
            case ets:lookup(?ETS_MAPS, DestMapID) of
                [{_, 0}] ->
                    do_map_enter_normal(Unique, Module, Method, RoleID, PID, RoleMapInfo, MapID, DestMapID, Line, State);
                [{_, 1}] ->
                    do_map_enter_copy(Unique, Module, Method, RoleID, PID, RoleMapInfo, MapID, DestMapID, Line, State);
                _ ->
                    %% 地图ID错误
                    mgeem_router:kick_role(RoleID, Line, wrong_map_id)
            end
    end.

do_map_enter_normal(Unique, Module, Method, RoleID, PID, RoleMapInfo, MapID, DestMapID, Line, State) ->
    #p_pos{tx=TX, ty=TY} = RoleMapInfo#p_map_role.pos,
    %%是否可以跳转，站在跳转点上，或者使用了某些特定的方法，如回城卷才能完成跳转，否则踢掉
    case if_can_jump(MapID, DestMapID, TX, TY) of
        {true, IndexTX, IndexTY} ->
            {IndexTX2, IndexTY2} = get_jump_point(MapID, DestMapID, IndexTX, IndexTY),
            do_map_enter_normal2(Unique, Module, Method, RoleID, PID, RoleMapInfo, IndexTX2, IndexTY2,
                                 MapID, DestMapID, Line, State);
        _ ->
            case get({enter, RoleID}) of
                {DestMapID, DestTX, DestTY} ->
                    erase({enter, RoleID}),
                    ChangeMapType = get({change_map_type, RoleID}),

                    if ChangeMapType =:= ?CHANGE_MAP_TYPE_DRIVER ->
                            {DestTX2, DestTY2} = get_jump_point(MapID, DestMapID, DestTX, DestTY);
                       true ->
                            {DestTX2, DestTY2} = {DestTX, DestTY}
                    end,
                    do_map_enter_normal2(Unique, Module, Method, RoleID, PID, RoleMapInfo, DestTX2, DestTY2,
                                         MapID, DestMapID, Line, State);
                _ ->
                    DataRecord = #m_map_enter_toc{succ=false, reason=?_LANG_MAP_ENTER_NOT_IN_JUMP_POINT},
                    common_misc:unicast2(PID, Unique, Module, Method, DataRecord)
            end
    end.

do_map_enter_normal2(Unique, _Module, _Method, RoleID, PID, RoleMapInfo, DestTX, DestTY,
                     MapID, DestMapID, Line, MapState) ->
    DestMapPName = common_map:get_common_map_name(DestMapID),
    case global:whereis_name(DestMapPName) of
        undefined ->
            ?ERROR_MSG("跳转地图，目标地图地程（~w）不存在！！！", [DestMapID]),
            %% 跳回原点
            do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, MapID);
        MPID ->
            common_map_enter(PID, RoleMapInfo, DestMapID, MPID, DestMapPName, DestTX, DestTY, Unique, Line, MapState)
    end.

-define(IF_THEN_ELSE(Condition,DoTrue,DoFalse),
        case Condition of
            true->
                DoTrue;
            _ ->
                DoFalse
        end
       ).

%%进入副本地图。。10300是门派副本
do_map_enter_copy(Unique, Module, Method, RoleID, PID, RoleMapInfo, MapID, DestMapID, Line, State) ->
    %% add by caochuncheng 添加逐鹿天下副进入处理
    {VWFMapId,_EnterPosList} = mod_vie_world_fb:get_vwf_map_enter_info(),
    case DestMapID of
        10300 ->
            do_map_enter_family(Unique, RoleID, PID, RoleMapInfo, Line, State);
        VWFMapId ->
            do_map_enter_vwf(Unique, RoleID, PID, RoleMapInfo, Line, State);
        10500 ->
            do_map_enter_10500(Unique, RoleID, PID, RoleMapInfo, Line, State);
        10700 ->
            do_map_enter_normal(Unique, Module, Method, RoleID, PID, RoleMapInfo, MapID, DestMapID, Line, State);
        10600 ->
            do_map_enter_10600(Unique, RoleID, PID, RoleMapInfo, Line, State);
        _ ->
            ?IF_THEN_ELSE( mod_hero_fb:is_hero_fb_map_id(DestMapID),
            do_map_enter_hero_fb(Unique, RoleID, PID, RoleMapInfo, Line, State),

            ?IF_THEN_ELSE( mod_exercise_fb:is_exercise_fb_map_id(DestMapID),
            do_map_enter_exercise_fb(Unique, RoleID, PID, RoleMapInfo, Line, State),

            ?IF_THEN_ELSE( mod_shuaqi_fb:is_shuaqi_fb_map_id(DestMapID),
            do_map_enter_shuaqi_fb(Unique, RoleID, PID, RoleMapInfo, Line, State),
                           
            ?IF_THEN_ELSE( mod_scene_war_fb:is_scene_war_fb_map_id(DestMapID),
            do_map_enter_sw_fb(Unique, RoleID, PID, RoleMapInfo, Line, State),

            ?IF_THEN_ELSE( mod_mission_fb:is_mission_fb_map_id(DestMapID),
            do_map_enter_mission_fb(Unique, RoleID, PID, RoleMapInfo, Line, State),

            mgeem_router:kick_role(RoleID, Line, hack_attemp)
            )
            )
            )
            )
            )
    end.

do_map_enter_exercise_fb(Unique, RoleID, PID, RoleMapInfo, Line, State)->
    {DestMapID, TX, TY} = get({enter, RoleID}),
    erlang:erase({enter, RoleID}),
    mod_exercise_fb:assert_valid_map_id(DestMapID),
    CurMapID = mgeem_map:get_mapid(),
    MapProcessName = mod_exercise_fb:get_role_exe_fb_map_name(CurMapID, RoleID),
    mod_exercise_fb:erase_role_exe_fb_map_name(CurMapID, RoleID),
    case global:whereis_name(MapProcessName) of 
        undefined ->
            ?ERROR_MSG("跳转地图，目标地图地程（~w）不存在！！！", [DestMapID]),
            %% 跳回原点
            do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, get_mapid());
        MapPID ->
            common_map_enter(PID, RoleMapInfo, DestMapID, MapPID, MapProcessName, TX, TY, Unique, Line, State)
    end.

do_map_enter_shuaqi_fb(Unique, RoleID, PID, RoleMapInfo, Line, State)->
    {DestMapID, TX, TY} = get({enter, RoleID}),
    erlang:erase({enter, RoleID}),
    mod_shuaqi_fb:assert_valid_map_id(DestMapID),
    CurMapID = mgeem_map:get_mapid(),
    MapProcessName = mod_shuaqi_fb:get_role_sq_fb_map_name(CurMapID, RoleID),
    mod_shuaqi_fb:erase_role_sq_fb_map_name(CurMapID, RoleID),
    case global:whereis_name(MapProcessName) of 
        undefined ->
            ?ERROR_MSG("跳转地图，目标地图地程（~w）不存在！！！", [DestMapID]),
            %% 跳回原点
            do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, get_mapid());
        MapPID ->
            common_map_enter(PID, RoleMapInfo, DestMapID, MapPID, MapProcessName, TX, TY, Unique, Line, State)
    end.

do_map_enter_mission_fb(Unique, RoleID, PID, RoleMapInfo, Line, State) ->
    {DestMapID, TX, TY} = get({enter, RoleID}),
    mod_mission_fb:assert_valid_map_id(DestMapID),
    MapProcessName = common_map:get_mission_fb_map_name(DestMapID, RoleID),
    
    case global:whereis_name(MapProcessName) of
        undefined ->
            ?ERROR_MSG("跳转地图，目标地图地程（~w）不存在！！！", [DestMapID]),
            %% 跳回原点
            do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, get_mapid());
        MapPID ->
            common_map_enter(PID, RoleMapInfo, DestMapID, MapPID, MapProcessName, TX, TY, Unique, Line, State)
    end.

do_map_enter_hero_fb(Unique, RoleID, PID, RoleMapInfo, Line, State) ->
    {DestMapID, TX, TY} = get({enter, RoleID}),
    mod_hero_fb:assert_valid_map_id(DestMapID),
    MapProcessName = mod_hero_fb:get_hero_fb_map_name(DestMapID, RoleID),
    case global:whereis_name(MapProcessName) of 
        undefined ->
            ?ERROR_MSG("跳转地图，目标地图地程（~w）不存在！！！", [DestMapID]),
            %% 跳回原点
            #p_role_hero_fb_info{enter_mapid =EnterMapID,enter_pos=EnterPos}=mod_hero_fb:get_role_hero_fb_info(RoleID),
            case erlang:is_integer(EnterMapID) 
                andalso EnterMapID>0 
                andalso erlang:is_record(EnterPos,p_pos) of
                true->
                    EnterMapPName = common_map:get_common_map_name(EnterMapID),
                    case global:whereis_name(EnterMapPName) of
                        undefined ->
                            do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, get_mapid());
                        EnterMapPID->
                            #p_pos{tx = EnterTx,ty=EnterTy}=EnterPos,
                            common_map_enter(PID, RoleMapInfo, DestMapID, EnterMapPID, EnterMapPName, EnterTx, EnterTy, Unique, Line, State)
                    end;
                false->
                    do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, get_mapid())
            end;
        MapPID ->
            common_map_enter(PID, RoleMapInfo, DestMapID, MapPID, MapProcessName, TX, TY, Unique, Line, State)
    end.
    
do_map_enter_family(Unique, RoleID, PID, RoleMapInfo, Line, State) -> 
    FamilyID = RoleMapInfo#p_map_role.family_id,

    MapProcessName = common_map:get_family_map_name(FamilyID),
    ?ERROR_MSG("~p", [MapProcessName]),
    case global:whereis_name(MapProcessName) of
        undefined ->
            mod_map_copy:create_family_map_copy(FamilyID),
            ?ERROR_MSG("跳转地图，目标地图地程（门派地图）不存在！！！", []),
            %% 跳回原点
            do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, get_mapid());
        MapPID ->
            FamilyMapID = 10300,
            case get({enter, RoleID}) of
                undefined ->
                    [#r_born_point{tx=TX, ty=TY}] = common_config_dyn:find(born_point,FamilyMapID);
                {_, TX, TY} ->
                    ok
            end,

            common_map_enter(PID, RoleMapInfo, FamilyMapID, MapPID, MapProcessName, TX, TY, Unique, Line, State)
    end.
%% add by caochuncheng 添加逐鹿天下副进入处理
do_map_enter_vwf(Unique, RoleID, PID, RoleMapInfo, Line, State) ->
    ?DEV("vie_world_fb ~ts,RoleMapInfo=~w",["玩家登录要求进入逐鹿天下副本",RoleMapInfo]),
    {VWFMapId,_EnterPosList} = mod_vie_world_fb:get_vwf_map_enter_info(),
    NpcId = get({enter_vwf_map, RoleID}),
    erase({enter_vwf_map, RoleID}),
    ?DEV("vie_world_fb ~ts,NpcId=~w",["玩家登录要求进入逐鹿天下副本",NpcId]),
    MapProcessName = mod_map_copy:get_vwf_common_map_name(get_mapid(),NpcId),
    case global:whereis_name(MapProcessName) of
        undefined ->
            %% 玩家在副本中下线，之后副本已经关闭时重新进入游戏处理
            ?DEBUG("vie_world_fb,~ts",["玩家在副本中下线，之后副本已经关闭时重新进入游戏处理，关闭"]),
            mod_vie_world_fb:do_role_re_login_vwf(RoleID),
            error;
        MapPid ->
            ?DEV("vie_world_fb,~ts",["玩家在副本中下线，之后副本未关闭时重新进入游戏处理，存在"]),
            case get({enter, RoleID}) of
                {_DestMapID, TX, TY} ->
                    erase({enter, RoleID});
                _ ->
                    [#r_born_point{tx=TX, ty=TY}] = common_config_dyn:find(born_point,VWFMapId)
            end,

            common_map_enter(PID, RoleMapInfo, 10400, MapPid, MapProcessName, TX, TY, Unique, Line, State)
    end.
do_map_enter_10500(Unique, RoleID, PID, RoleMapInfo, Line, State) ->
    case erlang:get({enter, RoleID}) of
        {MapId, TX, TY} ->
            erlang:erase({enter, RoleID}),
            MapProcessName = common_map:get_common_map_name(MapId),
            case global:whereis_name(MapProcessName) of
                undefined ->
                    ?ERROR_MSG("跳转地图，目标地图地程不存在！！！", []),
                    %% 跳回原点
                    do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, get_mapid());
                MapPid ->
                    common_map_enter(PID, RoleMapInfo, 10500, MapPid, MapProcessName, TX, TY, Unique, Line, State)
            end;
        _ ->
            mgeem_router:kick_role(RoleID, Line, hack_attemp)
    end. 
do_map_enter_10600(Unique, RoleID, PID, RoleMapInfo, Line, State) ->
    case erlang:get({enter, RoleID}) of
        {MapId, TX, TY} ->
            erlang:erase({enter, RoleID}),
            MapProcessName = mod_educate_fb:get_educate_fb_map_state(MapId,RoleID),
            mod_educate_fb:erase_educate_fb_map_state(MapId,RoleID),
            case global:whereis_name(MapProcessName) of
                undefined ->
                    ?ERROR_MSG("跳转地图，目标地图地程不存在！！！", []),
                    %% 跳回原点
                    do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, get_mapid());
                MapPid ->
                    common_map_enter(PID, RoleMapInfo, 10600, MapPid, MapProcessName, TX, TY, Unique, Line, State)
            end;
        _ ->
            mgeem_router:kick_role(RoleID, Line, hack_attemp)
    end. 
%% 进入场景大战副本
do_map_enter_sw_fb(Unique, RoleID, PID, RoleMapInfo, Line, State) ->
    ?DEBUG("RoleMapInfo=~w",[RoleMapInfo]),
    case erlang:get({enter, RoleID}) of
        {MapId, TX, TY} ->
            erlang:erase({enter, RoleID}),
            CurMapId = mgeem_map:get_mapid(),
            FbMapProcessName = mod_scene_war_fb:get_sw_fb_map_dict(CurMapId,RoleID),
            mod_scene_war_fb:erase_sw_fb_map_dict(CurMapId,RoleID),
            case global:whereis_name(FbMapProcessName) of
                undefined ->
                    ?ERROR_MSG("跳转地图，目标地图地程不存在！！！", []),
                    %% 跳回原点
                    do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, get_mapid());
                MapPid ->
                    common_map_enter(PID, RoleMapInfo, MapId, MapPid, FbMapProcessName, TX, TY, Unique, Line, State)
            end;
        _ ->
            mgeem_router:kick_role(RoleID, Line, hack_attemp)
    end. 
    

common_map_enter(RolePID, RoleMapInfoOld, DestMapID, DestMapPID, DestMapPName, TX, TY, Unique, Line, State) ->
    #p_map_role{role_id=RoleID} = RoleMapInfoOld,
    catch hook_map_role:before_role_quit(RoleID, get_mapid(), DestMapID),
    RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID, role),
    %%先退出原来的地图
    ChangeMapType = get({change_map_type, RoleID}),
    erlang:erase({change_map_type, RoleID}),
    erlang:erase({enter, RoleID}),
    %% 取出要传输的数据
    Pos = #p_pos{tx=TX, ty=TY, dir=4},
    case ChangeMapType of
        ?CHANGE_MAP_TYPE_RELIVE ->
            RoleMapInfo2 = RoleMapInfo#p_map_role{state=?ROLE_STATE_NORMAL, pos=Pos, last_walk_path=undefined};
        _ ->
            RoleMapInfo2 = RoleMapInfo#p_map_role{pos=Pos, last_walk_path=undefined}
    end,
    %% 背包数据
    {ok, RoleBagInfo} = mod_bag:get_role_bag_transfer_info(RoleID),
    %% 信件的一些计数
    LetterCounter = mod_letter:get_send_count_data(RoleID),
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    {ok, RoleFight} = mod_map_role:get_role_fight(RoleID),
    RoleFight2 = RoleFight#p_role_fight{hp=RoleMapInfo#p_map_role.hp, mp=RoleMapInfo#p_map_role.mp},
    mod_map_role:set_role_fight(RoleID, RoleFight2),
    {ok, RoleConlogin} = mod_map_role:get_role_conlogin(RoleID),
    {ok, #p_role_pos{map_process_name=OldMapPName} = RolePos} = mod_map_role:get_role_pos_detail(RoleID),
    case mod_map_role:get_role_accumulate_exp(RoleID) of
		{ok, RoleAccumulateExpInfo} ->
			ok;
        _ ->
			RoleAccumulateExpInfo = undefined
    end,
    case mod_vip:get_role_vip_info(RoleID) of
        {ok, VipInfo} ->
            ok;
        _ ->
            VipInfo = undefined
    end,
    case mod_hero_fb:get_role_hero_fb_info(RoleID) of
        {ok, HeroFBInfo} ->
            ok;
        _ ->
            HeroFBInfo = undefined
    end,
    case mod_map_drop:get_role_monster_drop(RoleID) of
        {ok, DropInfo} ->
            ok;
        _ ->
            DropInfo = undefined
    end,
    case mod_refining_box:get_role_refining_box_info(RoleID) of
        {ok, RefiningBoxInfo} ->
            ok;
        _ ->
            RefiningBoxInfo = undefined
    end,
    case mod_achievement:get_role_achievement_info(RoleID) of
        {ok, AchievementInfo} ->
            ok;
        _ ->
            AchievementInfo = undefined
    end,
    case mod_map_team:get_role_team_info(RoleID) of
        {ok,TeamInfo} ->
            ok;
        _ ->
            TeamInfo = undefined
    end,
    case mod_map_role:get_role_map_ext_info(RoleID) of
        {ok,MapExtInfo}->
            ok;
        _->
            MapExtInfo=undefined
    end,
    SkillList = mod_skill:get_role_skill_list(RoleID),
    {ok, RoleGoal} = mod_map_role:get_role_goal(RoleID),
    RolePos2 = RolePos#p_role_pos{pos=Pos, map_id=DestMapID, map_process_name=DestMapPName, old_map_process_name=OldMapPName},
    RoleDetail = #r_role_map_detail{
      base = RoleBase,attr = RoleAttr,conlogin = RoleConlogin,accumulate_info = RoleAccumulateExpInfo,vip_info = VipInfo,
      hero_fb_info = HeroFBInfo,role_monster_drop = DropInfo,refining_box_info = RefiningBoxInfo, goal_info = RoleGoal, 
      achievement_info = AchievementInfo,team_info = TeamInfo,map_ext_info = MapExtInfo,skill_list = SkillList,pos=RolePos2,
      role_fight=RoleFight2},
    RoleBuffList = mod_role_buff:get_buff_map_trans_data(RoleID),
    {ok,RoleState} = mod_map_role:get_role_state(RoleID),
    {ok,TransferL1} = mod_map_role:clear_role_timer(RoleState),
    LastSkillTime = mod_fight:get_last_skill_time(role, RoleID),
    TransferL2 = [{last_skill_time,LastSkillTime}|TransferL1],
    TransferL3 = lists:append(mod_map_pet:get_pet_transfer_info(RoleID), TransferL2),

    MissionData = mod_mission_data:get_mission_data(RoleID),
    RolePetGrowInfo = mod_pet_grow:get_role_pet_grow_info(RoleID),
    DrunkCount = mod_item:get_role_drunk_count(RoleID),

    mod_map_actor:do_change_map_quit(role, ChangeMapType, RoleID, DestMapPName, DestMapID, Pos, State),

    MapDataTransfer = [{role_map_info, RoleMapInfo2}, 
                       {role_map_bag_info, RoleBagInfo}, 
                       {role_detail, RoleDetail},
                       {role_state,RoleState},
                       {pet_grow_info,RolePetGrowInfo},
                       {mission_data, MissionData},
                       {drunk_count,DrunkCount},
                       {role_buff, RoleBuffList}|TransferL3],
    DestMapPID ! {mod_map_actor, {enter, Unique, RolePID, RoleID, MapDataTransfer, Line, LetterCounter}}.

if_can_jump(MapID, DestMapID, TX, TY) ->
    JumpPoints = ets:lookup(?ETS_IN_MAP_DATA, {MapID, DestMapID}),
    lists:foldl(
      fun({_, {X, Y, IndexTX, IndexTY}}, Acc) ->
              if erlang:abs(X-TX) =< 5 andalso erlang:abs(Y-TY) =< 5 ->
                      {true, IndexTX, IndexTY};
                 true ->
                      Acc
              end
      end, false, JumpPoints).

-define(waroffaction_ready_stage, waroffaction_ready_stage).
-define(jingcheng_and_pingjian_mapid, [11100, 11102, 12100, 12102, 13100, 13102]).
-define(db_waroffaction_key, 1).

%%客户端普通地图跳转流程: change_map_tos(服务端做些验证，现在暂时没有) -> change_map_toc -> map_enter_tos -> map_enter_toc
do_change_map(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_map_change_map_tos{mapid=DestMapID, tx=TX, ty=TY} = DataIn,
    case catch check_can_change_map(RoleID, DestMapID) of
        ok ->
            put({change_map_type, RoleID}, ?CHANGE_MAP_TYPE_NORMAL),
            DataRecord = #m_map_change_map_toc{mapid=DestMapID, tx=TX, ty=TY};
        {error, Reason} ->
            DataRecord = #m_map_change_map_toc{succ=false, reason=Reason};
        _ ->
            DataRecord = #m_map_change_map_toc{succ=false, reason=?_LANG_SYSTEM_ERROR}
    end,
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

check_can_change_map(RoleID, DestMapID) ->
    case get({change_map_type, RoleID}) of
        undefined ->
            ok;
        _ ->
            throw({error, ?_LANG_MAP_TRANSFER_TRANSFERING})
    end,
    [Level] = common_config_dyn:find(map_level_limit, DestMapID),
    RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID, role),
    #p_map_role{level=RoleLevel, faction_id=FactionID} = RoleMapInfo,
    %% 等级判断
    case RoleLevel >= Level of
        true ->
            ok;
        _ ->
            throw({error, list_to_binary(io_lib:format(?_LANG_MAP_TRANSFER_LEVEL_LIMIT, [Level]))})
    end,
    MapID = get_mapid(),
    case MapID =:= DestMapID of
        true ->
            throw({error, ?_LANG_MAP_TRANSFER_DEST_MAP_ALREADY});
        _ ->
            ok
    end,
    {ok, MapFactionID} = mod_map_role:get_map_faction_id(MapID),
    [SafeMapList] = common_config_dyn:find(etc, safe_map),
    IsSafeMap = lists:member(DestMapID, SafeMapList),
    %% 不能进入外国的安全地图
    case IsSafeMap andalso MapFactionID =/= FactionID of
        true ->
            throw({error, ?_LANG_MAP_TRANSFER_OTHER_FACTION_SAFE_MAP});
        _ ->
            ok
    end,
    case mod_ybc_person:faction_ybc_status(MapFactionID) of
        {activing, {PastTime, _}} ->
            if
                %%国运前10分钟T人
                PastTime =< 600 andalso MapFactionID =/= FactionID ->
                    HomeMapID = common_misc:get_home_mapid(FactionID, MapID),
                    {_, TX, TY} = common_misc:get_born_info_by_map(HomeMapID),
                    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_RETURN_HOME, RoleID, HomeMapID, TX, TY),
                    common_broadcast:bc_send_msg_role(RoleID, [?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_SYSTEM], ?_LANG_PERSON_YBC_CLEAR_OTHER_FACTION_ROLE),
                    throw({error, ?_LANG_DRIVER_MAP_FACTION_DOING_PERSONYBC_FACTION});
                true ->
                    ok
            end;
        _ ->
            ok
    end,
    %% 国战期间，王都、平江不允许第二方国家玩家进入
    case check_in_jingcheng_or_pingjian(DestMapID) of
        {ok, MFactionID} ->
            case db:dirty_read(?DB_WAROFFACTION, ?db_waroffaction_key) of
                [#r_waroffaction{defence_faction_id=MFactionID, war_status=?waroffaction_ready_stage}] ->
                    case common_misc:if_in_self_country(FactionID, DestMapID) of
                        true ->
                            ok;
                        _ ->
                            throw({error, ?_LANG_MAP_CHANGE_MAP_IN_WAROFFACTION})
                    end;
                _ ->
                    ok
            end;
        _ ->
            ok
    end.

%% @doc 是否在王都或平江
check_in_jingcheng_or_pingjian(MapID) ->
    case lists:member(MapID, ?jingcheng_and_pingjian_mapid) of
        true ->
            {ok, MapID rem 10000 div 1000};
        _ ->
            false
    end.

do_team_recommend(Unique, Module, Method, RoleID, _FactionID, Line, [], InfoList, _Counter) ->
    do_team_recommend2(Unique, Module, Method, RoleID, Line, InfoList);
do_team_recommend(Unique, Module, Method, RoleID, _FactionID, Line, _PIDList, InfoList, 5) ->
    do_team_recommend2(Unique, Module, Method, RoleID, Line, InfoList);
do_team_recommend(Unique, Module, Method, RoleID, FactionID, Line, [PID|T], InfoList, Counter) ->
    case get({role_id, PID}) of
        undefined ->
            do_team_recommend(Unique, Module, Method, RoleID, FactionID, Line, T, InfoList, Counter);
        TargetID ->
            case mod_map_actor:get_actor_mapinfo(TargetID, role) of
                undefined ->
                    do_team_recommend(Unique, Module, Method, RoleID, FactionID, Line, T, InfoList, Counter);
                TRoleMapInfo ->
                    #p_map_role{role_name=_TRoleName, faction_id=TFactionID, level=TLevel, team_id=TTeamID} = TRoleMapInfo,

                    case TLevel >= 18 andalso TTeamID =:= 0 andalso FactionID =:= TFactionID andalso TargetID =/= RoleID of
                        true ->
%%                             MissionID = get_mission_id(FactionID),
%%                             case mod_mission_data:get_completed_times(TargetID, 0, MissionID) of
%%                                 {0, _, _} ->
%%                                     do_team_recommend(Unique, Module, Method, RoleID, FactionID, Line, T,
%%                                                       [#p_recommend_member_info{role_id=TargetID, role_name=TRoleName, level=TLevel}|InfoList],
%%                                                       Counter+1);
%%                                 _ ->
%%                                     do_team_recommend(Unique, Module, Method, RoleID, FactionID, Line, T, InfoList, Counter)
%%                             end;
                            ok;%%TODO 任务重构备忘修改
                        _ ->
                            do_team_recommend(Unique, Module, Method, RoleID, FactionID, Line, T, InfoList, Counter)
                    end
            end
    end.

do_team_recommend2(Unique, Module, Method, RoleID, Line, InfoList) ->
    DataRecord = #m_team_member_recommend_toc{member_info=InfoList},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

do_team_recommend_error(Unique, Module, Method, RoleID, Reason, Line) ->
    DataRecord = #m_team_member_recommend_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

%% get_mission_id(FactionID) ->
%%     if
%%         FactionID =:= 1 ->
%%             684;
%%         FactionID =:= 2 ->
%%             685;
%%         true ->
%%             686
%%     end.

%% @doc 神兵排行榜在地图这边的处理，先获取到装备的信息再发到排行榜进程
do_ranking_equip_join_rank(Unique, Module, Method, DataIn, RoleID, Pid, Line) ->
    #m_ranking_equip_join_rank_tos{goods_id=GoodsID} = DataIn,

    case mod_bag:get_goods_by_id(RoleID, GoodsID) of
        {ok, GoodsInfo} ->
            do_ranking_equip_join_rank2(Unique, Module, Method, DataIn, GoodsInfo, RoleID, Pid, Line),
            ok;
        {error, _} ->
            case mod_goods:get_equip_by_id(RoleID, GoodsID) of
                {ok, GoodsInfo} ->
                    do_ranking_equip_join_rank2(Unique, Module, Method, DataIn, GoodsInfo, RoleID, Pid, Line),
                    ok;
                _ ->
                    DataRecord = #m_ranking_equip_join_rank_toc{succ=false, reason=?_LANG_RANKING_EQUIP_NOT_EXIST},
                    common_misc:unicast2(Pid, Unique, Module, Method, DataRecord)
            end
    end.

do_ranking_equip_join_rank2(Unique, Module, Method, DataIn, GoodsInfo, RoleID, Pid, Line) ->
    case global:whereis_name(mgeew_ranking) of
        undefined ->
            DataRecord = #m_ranking_equip_join_rank_toc{succ=false, reason=?_LANG_SYSTEM_ERROR},
            common_misc:unicast(Pid, Unique, Module, Method, DataRecord);
        RPID ->
            %% 将goods_id替换成goods_info，不大好的处理，暂时这样
            DataIn2 = DataIn#m_ranking_equip_join_rank_tos{goods_id=GoodsInfo},

            Info = {Unique, Module, Method, DataIn2, RoleID, Pid, Line},
            RPID ! Info
    end.

%% @doc 获取跳转点，国战期间一些地图随机取一个跳转点
get_jump_point(FromMapID, MapID, TX, TY) ->
    [MapJumpList] = common_config_dyn:find(etc, waroffaction_jump_point),
    case lists:keyfind({FromMapID, MapID}, 1, MapJumpList) of
        false ->
            {TX, TY};

        {_, JumpPointList} ->
            case db:dirty_read(?DB_WAROFFACTION, 1) of
                [] ->
                    {TX, TY};
                _ ->
                    lists:nth(random:uniform(length(JumpPointList)), JumpPointList)
            end
    end.

%% @doc 目标地图进程不存在，跳回原点    
do_dest_map_not_exist(Unique, PID, RoleID, RoleMapInfo, MapID) ->
    #p_map_role{pos=#p_pos{tx=DestTX2, ty=DestTY2}} = RoleMapInfo,
    DataRecord = #m_map_enter_toc{succ=false},
    common_misc:unicast2(PID, Unique, ?MAP, ?MAP_ENTER, DataRecord),
    PID ! {sure_enter_map, erlang:self()},
    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_RETURN_HOME, RoleID, MapID, DestTX2, DestTY2).
