%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     任务副本
%%% @end
%%% Created : 2011-6-16
%%%-------------------------------------------------------------------
-module(mod_mission_fb).

-include("mission.hrl"). 

-export([
         handle/1,
         handle/2
        ]).

-export([is_mission_fb_map_id/1,
         assert_valid_map_id/1,
         get_mission_monster_create_type/1]).

-export([
         hook_role_quit/1,
         hook_role_before_quit/1,
         hook_role_enter/1,
         hook_monster_dead/1,
         hook_mission_complete/1,
         hook_role_online/1,
         get_mission_fb_quit_pos/2
        ]).


%% 任务副本地图信息
-record(r_mission_fb_map_info, {barrier_id, map_role_id, enter_time, first_enter=false,
                                complete_type = 0,is_complete=false,mission_id = 0}).

-define(MISSION_FB_COMPLETE_TYPE_MONSTER_DEAD,0).
-define(MISSION_FB_COMPLETE_TYPE_MISSION_ID,1).


-define(MISSION_FB_MAP_INFO, mission_fb_map_info).

%% 任务副本死亡退出
-define(MISSION_FB_QUIT_TYPE_NORMAL, 0).


handle(Info,_State) ->
    handle(Info).


handle({Unique, Module, ?MISSION_FB_ENTER, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_enter(Unique, Module, ?MISSION_FB_ENTER, DataIn, RoleID, PID);
handle({Unique, Module, ?MISSION_FB_QUIT, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_quit(Unique, Module, ?MISSION_FB_QUIT, DataIn, RoleID, PID);
handle({Unique, Module, ?MISSION_FB_PROP, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_prop(Unique, Module, ?MISSION_FB_PROP, DataIn, RoleID, PID);

handle({init_mission_fb_map_info, FbMapInfo}) ->
    set_mission_fb_map_info(FbMapInfo);
handle({offline_terminate}) ->
    do_offline_terminate();
handle({create_map_succ, Key}) ->
    do_create_copy_finish(Key);
handle({auto_complete_mission_id,RoleId,MissionId}) ->
    do_auto_complete_mission_id(RoleId,MissionId);

handle(Info) ->
    ?ERROR_MSG("~w, unrecognize msg: ~w", [?MODULE,Info]).


do_auto_complete_mission_id(RoleId,MissionId) ->
    erlang:put({auto_complete_mission_id,RoleId},MissionId).
hook_role_online(RoleId) ->
    case erlang:get({auto_complete_mission_id,RoleId}) of
        undefined ->
            ignore;
        MissionId ->
            catch common_misc:send_to_rolemap(RoleId, {mod_gm, {gm_set_mission, RoleId, MissionId,true}}),
            erlang:erase({auto_complete_mission_id,RoleId})
    end.

%% @doc 角色进入地图
hook_role_enter(_MapID) ->
    case get_mission_fb_map_info() of
        %% 第一次进入，进入后设置信息
        {ok, #r_mission_fb_map_info{map_role_id=_RoleID, first_enter=true}=FbMapInfo} ->
            Now = erlang:now(),
            FbMapInfo2 = FbMapInfo#r_mission_fb_map_info{ enter_time=Now, first_enter=false},
            set_mission_fb_map_info(FbMapInfo2),
            ok;
        _ ->
            ignore
    end.

%% @doc 
hook_role_before_quit(RoleID) ->
    case get_mission_fb_map_info() of
        {error, _} ->
            ignore;
        {ok, MissionFbMapInfo} ->
            #r_mission_fb_map_info{barrier_id=FbID} = MissionFbMapInfo,
            do_clear_prop_in_map(RoleID, FbID)
    end.

%% @doc 角色退出地图hook
hook_role_quit(RoleID) ->
    case get_mission_fb_map_info() of
        {error, _} ->
            ignore;
        {ok, MissionFbMapInfo} ->
            #r_mission_fb_map_info{barrier_id=FbID} = MissionFbMapInfo,
            do_clear_prop_in_map(RoleID, FbID),
            hook_role_quit2(RoleID, MissionFbMapInfo)
    end.

hook_role_quit2(RoleID, MissionFbMapInfo) ->
    #map_state{mapid=MapID, map_name=MapName} = mgeem_map:get_state(),
    case mod_map_actor:is_change_map_quit(RoleID) of
        {true, MapID} ->
            %% 删除所有怪物
            mod_map_monster:delete_all_monster(),
            %% 重新出生怪物
            mod_map_monster:init_monster_id_list(),
            mod_map_monster:init_map_monster(MapName, MapID);
        _ ->
            hook_role_quit3(RoleID, MissionFbMapInfo)
    end.

hook_role_quit3(_RoleID, MissionFbMapInfo) ->
    case MissionFbMapInfo of
        #r_mission_fb_map_info{is_complete=true}->
            common_map:exit( mission_fb_role_quit ),
            catch do_mission_fb_log(MissionFbMapInfo);
        _Val ->
            kill_map_offline_protect()
    end.

%%@doc 杀掉地图离线保护
kill_map_offline_protect()->
    %% 玩家在副本中退出地图，地图进程会保持一段时间(默认是1分钟)
    [ProtectTime] = common_config_dyn:find(mission_fb, offline_protect_time),
    erlang:send_after(ProtectTime*1000, self(), {mod, mod_mission_fb, {offline_terminate}}).


hook_monster_dead(MonsterBaseInfo) ->
    case get_mission_fb_map_info() of
        {ok, FbMapInfo} ->
            case FbMapInfo#r_mission_fb_map_info.complete_type =:= ?MISSION_FB_COMPLETE_TYPE_MONSTER_DEAD of
                true ->
                    #p_monster_base_info{rarity=MonsterRarity} = MonsterBaseInfo,
                    case (MonsterRarity=:=?ELITE) orelse (MonsterRarity=:=?BOSS) of
                        true->
                            %%标记BOSS/精英怪 已经死亡
                            FbMapInfo2 = FbMapInfo#r_mission_fb_map_info{is_complete=true},
                            set_mission_fb_map_info(FbMapInfo2);
                        _ ->
                            ignore
                    end;
                _ ->
                    ignore
            end;
        
        {error, _} ->
            ignore
    end.
hook_mission_complete(MissionId) ->
    case get_mission_fb_map_info() of
        {ok, FbMapInfo} ->
            case FbMapInfo#r_mission_fb_map_info.complete_type =:= ?MISSION_FB_COMPLETE_TYPE_MISSION_ID of
                true ->
                    case FbMapInfo#r_mission_fb_map_info.mission_id  =:= MissionId of
                        true ->
                            FbMapInfo2 = FbMapInfo#r_mission_fb_map_info{is_complete=true},
                            set_mission_fb_map_info(FbMapInfo2);
                        _ ->
                            ignore
                    end;
                _ ->
                    ignore
            end;
        {error, _} ->
            ignore
    end.
%%@doc 删除副本中的临时道具。强制从身上卸载下来，并删除之
do_clear_prop_in_map(RoleID,FbID)->
    #r_mission_fb_info{fb_prop_formula=PropFormula} = get_mission_fb_config(FbID),
    case PropFormula>0 of
        true->
            case db:dirty_read(?DB_ROLE_MISSION_FB,{RoleID,FbID}) of
                [#r_role_mission_fb{prop_id=PropID,prop_num=PropNum}]->
                    do_clear_prop_in_map_2(RoleID,FbID,PropID,PropNum);
                _ ->
                    ignore
            end;
        _ ->
            ignore
    end.

%%@return {ok,FuncList} | {error,Reason}
delete_equip_in_body(RoleID,PropID)->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    EquipList = RoleAttr#p_role_attr.equips,
    case lists:keyfind(PropID, #p_goods.typeid, EquipList) of
        false->
            ignore;
        #p_goods{loadposition=SlotNum} ->
            EquipList2 = lists:keydelete(PropID, #p_goods.typeid, EquipList),
            RoleAttr2 = RoleAttr#p_role_attr{equips=EquipList2},
            {ok, RoleAttr3, _} =
                mod_equip:get_role_skin_change_info(RoleAttr2, SlotNum, 0, 0),
            mod_map_role:set_role_attr(RoleID, RoleAttr3),
            {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
            RoleBase2 = mod_equip:cut_weapon_type(SlotNum, RoleBase),
            mod_map_role:set_role_base(RoleID, RoleBase2),
            ok
    end.

%%@doc 处理地主大院的副本道具
do_clear_prop_in_map_2(RoleID,FbID=101,PropID,PropNum)->
    TransFun =  fun() -> 
                    Step1 = delete_equip_in_body(RoleID,PropID),
                    _Step2 = t_log_mission_fb_prop(true,RoleID,FbID,undefined),
                    {ok,Step3GoodsList} = mod_bag:delete_goods_by_typeid(RoleID,PropID),
                    {ok,Step4GoodsList} = mod_bag:delete_depositroy_goods_by_typeid(RoleID,PropID),
                    
                    DelGoodsList = lists:merge(Step3GoodsList, Step4GoodsList),
                    {Step1, {ok,DelGoodsList} }
                end,
    case db:transaction( TransFun ) of
        {atomic, {IsDeleteInBody, {ok, DeleteGoodsList}}} ->
            common_item_logger:log(RoleID, PropID,PropNum,true,?LOG_ITEM_TYPE_GAIN_NPC_EXCHANGE_DEAL),
            common_misc:del_goods_notify({role, RoleID}, DeleteGoodsList),
            case IsDeleteInBody of
                ok ->
                    mod_map_role:do_attr_change(RoleID);
                _ ->
                    ignore
            end,
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("do_clear_prop_in_map_2，Error=~w",[Error])
    end;
do_clear_prop_in_map_2(_RoleID,FbID,PropID,_PropNum)->
    ?ERROR_MSG("UnExcepted Call,FbID=~w,PropID=~w",[FbID,PropID]).


%% @doc 副本中给予道具
do_prop(Unique, Module, Method, DataIn, RoleID, PID)->
    #m_mission_fb_prop_tos{barrier_id=FbID} = DataIn,
    #r_mission_fb_info{map_id=MapID, fb_prop_formula=PropFormula,fb_prop_list=PropList} = get_mission_fb_config(FbID),
    case PropFormula>0 andalso is_list(PropList) andalso length(PropList)>0 of
        true->
            case catch check_can_give_prop(MapID,FbID,RoleID) of
                ok ->
                    do_prop_2(Unique, Module, Method, DataIn, RoleID, PID, FbID);
                {error,Reason}->
                    do_prop_error(Unique, Module, Method, RoleID, PID, FbID, Reason)
            end;
        _ ->
            ignore
    end.
do_prop_2(Unique, Module, Method, DataIn, RoleID, PID, FbID)->
    case check_has_give_prop(FbID,RoleID) of
        {true,PropID,_PropNum}->
            R2 = #m_mission_fb_prop_toc{barrier_id=FbID, succ=true, prop_id=PropID},
            common_misc:unicast2(PID, Unique, Module, Method, R2);
        false->
            case do_prop_3(Unique, Module, Method, DataIn, RoleID, PID, FbID) of
                {ok,PropID}->
                    R2 = #m_mission_fb_prop_toc{barrier_id=FbID, succ=true, prop_id=PropID},
                    common_misc:unicast2(PID, Unique, Module, Method, R2);
                _ ->
                    ignore
            end
    end.

%%@doc 检查能否给予任务道具
%%@return ok | {error,Reason}
check_can_give_prop(MapID,FbID,RoleID)->
    #r_mission_fb_info{min_level=MinLevel,max_level=MaxLevel } = get_mission_fb_config(FbID),
    #p_map_role{level=RoleLevel} = mod_map_actor:get_actor_mapinfo(RoleID, role),
    case RoleLevel>=MinLevel andalso MaxLevel>=RoleLevel of
        true->
            #map_state{mapid=RoleMapID} = mgeem_map:get_state(),
            case RoleMapID of
                MapID->
                    ok;
                _ ->
                    {error,<<"你在非法的地图中">>}
            end;
        _ ->
            {error,<<"您的级别不符合要求">>}
    end.


%%@doc 检查是否已经给予任务副本的道具
%%@return {true,PropID,PropNum} | false
check_has_give_prop(FbID,RoleID) when is_integer(FbID),is_integer(RoleID)->
    case db:dirty_read(?DB_ROLE_MISSION_FB,{RoleID,FbID}) of
        [#r_role_mission_fb{has_fb_prop=HasFbProp,prop_id=PropID,prop_num=PropNum}]->
            case HasFbProp of
                true->
                    {true,PropID,PropNum};
                _ ->
                    false
            end;
        [] ->
            false
    end.
    
do_prop_3(Unique, Module, Method, _DataIn, RoleID, PID, FbID)->
    #r_mission_fb_info{fb_prop_formula=PropFormula,fb_prop_list=PropList} = get_mission_fb_config(FbID),
    %% 暂时只处理PropFormula=1
    {ok, #p_role_attr{category=CategoryID}} = mod_map_role:get_role_attr(RoleID),
    case PropFormula of
        1->
            PropReward = lists:nth(CategoryID, PropList);
        _ ->
            PropReward = undefined
    end,
    #r_goods_create_special{item_id=PropID,item_num=PropNum} = PropReward,
    TransFun = fun() -> 
                        t_log_mission_fb_prop(false,RoleID,FbID,PropReward),
                        t_add_prop(RoleID,PropReward)
               end,
    case db:transaction( TransFun ) of
        {atomic, {ok,AddGoodsList}} ->
            %%目前只是增加一种道具
            common_misc:update_goods_notify({role, RoleID}, AddGoodsList),
            [Goods|_] = AddGoodsList,
            common_item_logger:log(RoleID,Goods#p_goods{current_num=PropNum},?LOG_ITEM_TYPE_REN_WU_HUO_DE),
            {ok,PropID};
        {aborted, {bag_error,not_enough_pos}} ->
            do_prop_error(Unique, Module, Method, RoleID, PID, FbID, ?_LANG_DROPTHING_BAG_FULL);
        {aborted, {throw, {bag_error, not_enough_pos}}} ->
            do_prop_error(Unique, Module, Method, RoleID, PID, FbID, ?_LANG_DROPTHING_BAG_FULL);
        {aborted, {throw, Reason}}when is_binary(Reason) ->
            do_prop_error(Unique, Module, Method, RoleID, PID, FbID, Reason);
        {aborted, Error} when is_binary(Error) ->
            do_prop_error(Unique, Module, Method, RoleID, PID, FbID, Error);
        {aborted, Error} ->
            ?ERROR_MSG_STACK("do_prop_3 Error",Error),
            do_prop_error(Unique, Module, Method, RoleID, PID, FbID, ?_LANG_SYSTEM_ERROR)
    end.

t_log_mission_fb_prop(_IsGiveBack=true,RoleID,FbID,_)->
    FbKey = {RoleID,FbID},
    Now = common_tool:now(),
    case db:read(?DB_ROLE_MISSION_FB,FbKey)of
        []->
            ignore;
        [R1]->
            R2 = R1#r_role_mission_fb{has_fb_prop=false,back_prop_time=Now},
            db:write(?DB_ROLE_MISSION_FB,R2,write)
    end;
t_log_mission_fb_prop(_IsGiveBack=false,RoleID,FbID,PropReward)->
    FbKey = {RoleID,FbID},
    Now = common_tool:now(),

    #r_goods_create_special{item_id=PropID,item_num=PropNum} = PropReward,
    R1 = #r_role_mission_fb{fb_key=FbKey,has_fb_prop=true,prop_id=PropID,prop_num=PropNum,fetch_prop_time=Now},
    ok = db:write(?DB_ROLE_MISSION_FB,R1,write).

do_prop_error(Unique, Module, Method, _RoleID, PID, FbID, Reason)->
    R2 = #m_mission_fb_prop_toc{barrier_id=FbID, succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, R2).
    

%% @doc 进入副本
do_enter(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_mission_fb_enter_tos{barrier_id=FbID} = DataIn,
    case catch check_can_enter_mission_fb(RoleID, FbID) of
        {ok, MissionFbInfo,FactionId} ->
            do_enter2(Unique, Module, Method, RoleID, PID, MissionFbInfo,FbID,FactionId);
        {error,{error_code,ErrCode}}->
            do_enter_error(Unique, Module, Method, PID, FbID, ErrCode);
        {error, Reason} ->
            do_enter_error(Unique, Module, Method, PID, FbID, Reason)
    end.

do_enter2(Unique, Module, Method, RoleID, PID, MissionFbInfo,FbID,FactionId) ->
    %% 开启地图
    #r_mission_fb_info{map_id=BarrierMapID} = MissionFbInfo,
    [BarrierInfo] = common_config_dyn:find(mission_fb, {mission_fb, FbID}),
    #r_mission_fb_info{map_id=BarrierMapID} = BarrierInfo,
    #map_state{mapid=CurrentMapID, map_name=CurrentMapName} = mgeem_map:get_state(),
    %% 如果当前已经在该地图
    case CurrentMapID =:= BarrierMapID of
        true ->
            do_enter3(Unique, Module, Method, RoleID, PID, MissionFbInfo, FbID, FactionId, CurrentMapID, CurrentMapName);
        _ ->
            BarrierMapName = common_map:get_mission_fb_map_name(BarrierMapID, RoleID),
            case global:whereis_name(BarrierMapName) of
                undefined->
                    %% 异步创建副本地图
                    log_async_create_copy(RoleID, {Unique, Module, Method, RoleID, PID, MissionFbInfo, FbID,FactionId, BarrierMapID, BarrierMapName}),
                    mod_map_copy:async_create_copy(BarrierMapID, BarrierMapName, ?MODULE, RoleID);
                _PID->
                    do_enter3(Unique, Module, Method, RoleID, PID, MissionFbInfo, FbID,FactionId, BarrierMapID, BarrierMapName)
            end
    end.

do_create_copy_finish(Key) ->
    case get_async_create_copy_info(Key) of
        undefined ->
            ignore;
        Info ->
            do_enter3(Info)
    end.

log_async_create_copy(RoleID, Info) ->
    erlang:put({mission_fb_create_key, RoleID}, Info).
get_async_create_copy_info(RoleID) ->
    erlang:get({mission_fb_create_key, RoleID}).

do_enter3({Unique, Module, Method, RoleID, PID, MissionFbInfo, FbID, FactionId, BarrierMapID, BarrierMapName}) ->
    do_enter3(Unique, Module, Method, RoleID, PID, MissionFbInfo, FbID, FactionId, BarrierMapID, BarrierMapName).
do_enter3(Unique, Module, Method, RoleID, PID, MissionFbInfo, FbID, FactionId, BarrierMapID, BarrierMapName) ->
    common_misc:unicast2(PID, Unique, Module, Method, #m_mission_fb_enter_toc{barrier_id=FbID}),
    case MissionFbInfo#r_mission_fb_info.complete_type =:= ?MISSION_FB_COMPLETE_TYPE_MISSION_ID of
        true ->
            case lists:keyfind(FactionId,1,MissionFbInfo#r_mission_fb_info.complete_mission_id_list) of
                false ->
                    MissionId = 0;
                {_,MissionId} ->
                    ignore
            end;
        _ ->
            MissionId = 0
    end,
    %% 初始化任务副本地图信息
    FbMapInfo = #r_mission_fb_map_info{barrier_id=FbID, map_role_id=RoleID, first_enter=true,
                                       complete_type = MissionFbInfo#r_mission_fb_info.complete_type,
                                       mission_id = MissionId},
    global:send(BarrierMapName, {mod, mod_mission_fb, {init_mission_fb_map_info, FbMapInfo}}),
    %% 传送到新地图
    {_, TX, TY} = common_misc:get_born_info_by_map(BarrierMapID),
    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, BarrierMapID, TX, TY).

do_enter_error(Unique, Module, Method, PID, FbID, ErrCode) when is_integer(ErrCode)->
    DataRecord = #m_mission_fb_enter_toc{barrier_id=FbID, succ=false, error_code=ErrCode},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord);
do_enter_error(Unique, Module, Method, PID, FbID, Reason)->
    DataRecord = #m_mission_fb_enter_toc{barrier_id=FbID, succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 退出地图
do_quit(Unique, Module, Method, DataIn, RoleID, PID) ->
    case catch check_can_quit_mission_fb(RoleID) of
        {ok, RoleMapInfo} ->
            do_quit2(Unique, Module, Method, DataIn, RoleID, PID, RoleMapInfo);
        {error, Reason} ->
            do_quit_error(Unique, Module, Method, PID, Reason)
    end.

do_quit2(Unique, Module, Method, DataIn, RoleID, PID, RoleMapInfo) ->
    common_misc:unicast2(PID, Unique, Module, Method, #m_mission_fb_quit_toc{}),
    #m_mission_fb_quit_tos{quit_type=QuitType} = DataIn,
    case QuitType of
        %% 主动退出
        ?MISSION_FB_QUIT_TYPE_NORMAL ->
            #p_map_role{faction_id=FactionID} = RoleMapInfo,
            {MapID, TX, TY} = get_mission_fb_quit_pos(FactionID, mgeem_map:get_mapid()),
            mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, MapID, TX, TY);
        _ ->
            %%其他退出方式，采用重生来解决
            ?ERROR_MSG("预期之外的退出方式",[]),
            mod_role2:do_relive(?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_RELIVE, RoleID, ?RELIVE_TYPE_BACK_CITY)
    end.

do_quit_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_mission_fb_quit_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).
      

%% @doc 是否可以退出副本
check_can_quit_mission_fb(RoleID) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            RoleMapInfo = undefined,
            erlang:throw({error, ?_LANG_MISSION_FB_QUTI_SYSTEM_ERROR});
        RoleMapInfo ->
            ok
    end,
    case get_mission_fb_map_info() of
        {ok, FbMapInfo} ->
            case FbMapInfo#r_mission_fb_map_info.is_complete =:= true of
                true ->
                    next;
                _ ->
                    erlang:throw({error, ?_LANG_MISSION_FB_QUTI_NOT_COMPLETE})
            end;
        {error, _} ->
            ignore
    end,
    {ok, RoleMapInfo}.



%%@doc 获取任务副本的配置
get_mission_fb_config(FbID) when is_integer(FbID)->
    [BarrierInfo] = common_config_dyn:find(mission_fb, {mission_fb, FbID}),
    BarrierInfo.

assert_valid_map_id(DestMapID)->
    case is_mission_fb_map_id(DestMapID) of
        true->
            ok;
        _ ->
            ?ERROR_MSG("严重，试图进入错误的地图,DestMapID=~w",[DestMapID]),
            throw({error,error_map_id,DestMapID})
    end.

%%@doc 判断是否任务副本的地图ID
is_mission_fb_map_id(DestMapID)->
    [HeroFBMapIDList] = common_config_dyn:find(mission_fb, fb_map_id_list),
    lists:member(DestMapID, HeroFBMapIDList).
%% 获取任务副本的怪物创建类型
get_mission_monster_create_type(DestMapId) ->
    case lists:foldl(
           fun({_Key,Value},Acc) -> 
                   case Acc =:= undefined
                            andalso erlang:is_record(Value, r_mission_fb_info) 
                            andalso Value#r_mission_fb_info.map_id =:= DestMapId of
                       true ->
                           Value#r_mission_fb_info.monster_create_type;
                       _ ->
                           Acc
                   end
           
           end,undefined,common_config_dyn:list(mission_fb)) of
        undefined ->
            ?MONSTER_CREATE_TYPE_MANUAL_CALL;
        MonsterCreateType ->
            MonsterCreateType
    end.


%% @doc 是否可以进入任务副本
check_can_enter_mission_fb(RoleID, FbID) ->
    RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID, role),
    case RoleMapInfo of
        undefined ->
            erlang:throw({error, ?_LANG_MISSION_FB_ENTER_SYSTEM_ERROR});
        _ ->
            next
    end,
    %% 是否达到最小进入等级
    #r_mission_fb_info{mission_id_list=MissionList,min_level=MinLevel,max_level=MaxLevel} = MissionFbInfo = get_mission_fb_config(FbID), 
    #p_map_role{level=Level, state=RoleState, pos=_Pos} = RoleMapInfo,
    case (Level < MinLevel) orelse (Level>MaxLevel) of
        true ->
            erlang:throw({error, ?_LANG_MISSION_FB_ENTER_LEVEL_LIMITED});
        _ ->
            next
    end,
    %% 是否满足任务条件
    check_can_enter_mission_fb_2(RoleID,MissionList),
    
    %% 角色状态检测
    case RoleState of
        ?ROLE_STATE_DEAD ->
            erlang:throw({error, ?_LANG_MISSION_FB_ENTER_ROLE_DEAD});
        ?ROLE_STATE_STALL ->
            erlang:throw({error, ?_LANG_MISSION_FB_ENTER_ROLE_STALL});
        ?ROLE_STATE_TRAINING ->
            erlang:throw({error, ?_LANG_MISSION_FB_ENTER_ROLE_TRAINING});
        _ ->
            ok
    end,
    {ok,MissionFbInfo,RoleMapInfo#p_map_role.faction_id}.
check_can_enter_mission_fb_2(_RoleID,[])->
    next;
check_can_enter_mission_fb_2(RoleID,MissionList)->
    {ok,#p_role_base{faction_id=FactionId}} = mod_map_role:get_role_base(RoleID),
    case lists:keyfind(FactionId, 1, MissionList) of
        false->
            next;
        {_,MissionID} when is_integer(MissionID) ->
            case check_mission_status(RoleID,MissionID) of
                ok->
                    next;
                {error_code,Code}->
                    erlang:throw({error, {error_code,Code}})
            end;
        {_,MIDList} when is_list(MIDList) ->
            case lists:any(fun(ID)-> 
                               check_mission_status(RoleID,ID) =:= ok
                           end, MIDList) of
                true->
                    next;
                _ ->
                    erlang:throw({error, {error_code,10001}})
            end
    end.

%%@doc 检查是否已经接受了指定的任务
check_mission_status(RoleID,MissionID) when is_integer(MissionID)->
    case mod_mission_data:get_pinfo(RoleID, MissionID) of
        #p_mission_info{current_status=?MISSION_STATUS_DOING}->
            ok;
        #p_mission_info{current_status=?MISSION_STATUS_FINISH}->
            ok;
            %%{error_code,10002};
        _ ->
            {error_code,10001}
    end.
 

%% @doc 设置任务副本地图信息
set_mission_fb_map_info(FbMapInfo) ->
    erlang:put(?MISSION_FB_MAP_INFO, FbMapInfo).

%% @doc 获取任务副本地图信息
get_mission_fb_map_info() ->
    case erlang:get(?MISSION_FB_MAP_INFO) of
        undefined ->
            {error, not_found};
        FbMapInfo ->
            {ok, FbMapInfo}
    end.
 


%% @doc 获取跳转点位置
get_mission_fb_quit_pos(FactionID, MapID) ->
    [PosList] = common_config_dyn:find(mission_fb, {npc_pos, MapID}),
    {_, {QuitMapID, TX, TY}} = lists:keyfind(FactionID, 1, PosList),
    {QuitMapID, TX, TY}.

%% 各国ID
-define(faction_hongwu, 1).
-define(faction_yongle, 2).
-define(faction_wanli, 3).


%% @doc 下线保护时间到，如果角色不在副本中杀掉副本地图进程
do_offline_terminate() ->
    case get_mission_fb_map_info() of
        {ok, MapInfo} ->
            #r_mission_fb_map_info{map_role_id=RoleID} = MapInfo,
            case mod_map_actor:get_actor_mapinfo(RoleID, role) of
                undefined ->
                    common_map:exit( mission_fb_role_quit ),
                    catch do_mission_fb_log(MapInfo);
                _ ->
                    ignore
            end;
        _ ->
            common_map:exit( mission_fb_role_quit )
    end.

%% @doc 任务副本日志
do_mission_fb_log(_MissionFbMapInfo) ->
    todo.


%%@doc 增加道具
t_add_prop(RoleID,SpecialCreateConfig) when is_record(SpecialCreateConfig,r_goods_create_special)->
    Now = common_tool:now(),
    case common_config_dyn:find(mission_fb,equip_limit_minute) of
        []->
            StartTime=0,
            EndTime=0;
        [EquipLimitMinute]->
            StartTime = 0,
            EndTime = Now+EquipLimitMinute*60
    end,
    SpecialCreateConfig2= SpecialCreateConfig#r_goods_create_special{start_time = StartTime,end_time = EndTime},
    
    {ok,CreateGoodsList} = mod_refining_tool:get_p_goods_by_special(RoleID,SpecialCreateConfig2),
    mod_bag:create_goods_by_p_goods(RoleID,CreateGoodsList).
    

