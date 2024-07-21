%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2011, 
%%% @doc
%%%
%%% @end
%%% Created : 12 Mar 2011 by  <>
%%%-------------------------------------------------------------------
-module(mod_map_trap).

-include("mgeem.hrl").

-export([set_trap_on_map/1,
         init_map_trap_list/0,
         init_slice_trap_list/1,
         get_slice_trap_list/1,
         get_trap_id/0]).

-export([hook_map_loop_ms/0]).

-define(map_trap_list, map_trap_list).
-define(slice_trap_list, slice_trap_list).

%% 地图毫秒循环
hook_map_loop_ms() ->
    case get_map_trap_list() of
        [] ->
            ignore;
        TrapList ->
            MapID = mgeem_map:get_mapid(),
            Now = common_tool:now(),
            hook_map_loop_ms2(TrapList, Now, MapID)
    end.

hook_map_loop_ms2([], _Now, _MapID) ->
    ignore;
hook_map_loop_ms2([Trap|T], Now, MapID) ->
    #p_map_trap{pos=#p_pos{tx=TX, ty=TY}, remove_time=RemoveTime} = Trap,
    
    case Now >= RemoveTime of
        true ->
            remove_trap(Trap);
        _ ->
            case get({ref, TX, TY}) of
                undefined ->
                    ignore;
                [] ->
                    ignore;
                [{ActorType, ActorID}|_] ->
                    step_on_trap(ActorType, ActorID, Trap, MapID, Now)
            end
    end,
    hook_map_loop_ms2(T, Now, MapID).

%% @doc 在地图中设置陷阱
set_trap_on_map(MapTrap) ->
    SetTrapList = get_set_trap_list(MapTrap),
    %% 在地图列表中添加，有点冗余，不过数据不大
    MapTrapList = get_map_trap_list(),
    update_map_trap_list(lists:append(SetTrapList, MapTrapList)),
    %% 广播
    #p_map_trap{pos=#p_pos{tx=TX, ty=TY}} = MapTrap,
    DataRecord = #m_trap_enter_toc{trap_list=SetTrapList},
    mgeem_map:do_broadcast_insence_by_txty(TX, TY, ?TRAP, ?TRAP_ENTER, DataRecord, mgeem_map:get_state()),
    %% 5个陷阱有可能在不同的slice
    set_trap_on_map2(SetTrapList).

set_trap_on_map2([]) ->
    ignore;
set_trap_on_map2([MapTrap|T]) ->
    %% 在slice列表中添加
    #p_map_trap{pos=#p_pos{tx=TX, ty=TY}} = MapTrap,
    SliceName = get_slice_name_by_txty(TX, TY),
    SliceTrapList = get_slice_trap_list(SliceName),
    update_slice_trap_list(SliceName, [MapTrap|SliceTrapList]),
    set_trap_on_map2(T).

-define(trap_type_once, 1).
-define(trap_type_last, 2).

%% @doc 部分陷阱特殊处理，放一个陷阱在周围四个位置都要放一个
get_set_trap_list(MapTrap) ->
    #p_map_trap{pos=#p_pos{tx=TX, ty=TY}, trap_type=TrapType} = MapTrap,

    case TrapType of
        ?trap_type_once ->
            [MapTrap];
        _ ->
            PosList = get_around_five_tile(TX, TY),
            lists:map(
              fun({TX2, TY2}) ->
                      Pos = #p_pos{tx=TX2, ty=TY2},
                      MapTrap#p_map_trap{trap_id=get_trap_id(), pos=Pos}
              end, PosList)
    end.

%% @doc 获取周围5个格子
%% * 4 *
%% 2 1 3
%% * 5 *
get_around_five_tile(TX, TY) ->
    lists:foldl(
      fun(TX2, Acc) ->
              lists:foldl(
                fun(TY2, Acc2) ->
                        case get({TX2, TY2}) of
                            undefined ->
                                Acc2;
                            _ ->
                                if abs(TX2-TX) =:= 1 andalso abs(TY2-TY) =:= 1 ->
                                        Acc2;
                                   true -> [{TX2, TY2}|Acc2]
                                end
                        end
                end, Acc, [TY-1, TY, TY+1])
      end, [], [TX-1, TX, TX+1]).

%% @doc 移除陷阱
remove_trap(MapTrap) ->
    #p_map_trap{trap_id=TrapID, pos=#p_pos{tx=TX, ty=TY}} = MapTrap,
    %% 删除在地图列表中的信息
    MapTrapList = get_map_trap_list(),
    update_map_trap_list(lists:keydelete(TrapID, #p_map_trap.trap_id, MapTrapList)),
    %% 删除在slice列表中的信息
    SliceName = get_slice_name_by_txty(TX, TY),
    SliceTrapList = get_slice_trap_list(SliceName),
    update_slice_trap_list(SliceName, lists:keydelete(TrapID, #p_map_trap.trap_id, SliceTrapList)),
    %% 广播
    DataRecord = #m_trap_quit_toc{trap_id=[TrapID]},
    mgeem_map:do_broadcast_insence_by_txty(TX, TY, ?TRAP, ?TRAP_QUIT, DataRecord, mgeem_map:get_state()),
    ok.

%% @doc 踩中陷阱
step_on_trap(DActorType, DActorID, Trap, MapID, Now) ->
    case check_can_take_effect(DActorID, DActorType, Trap, Now) of
        {ok, SActorMapInfo} ->
            update_last_time_step(DActorID, DActorType, Now),
            step_on_trap2(SActorMapInfo, DActorID, DActorType, Trap, MapID);
        _ ->
            ignore
    end.

step_on_trap2(SActorMapInfo, _DActorID, _DActorType, Trap, MapID) ->
    #p_map_trap{pos=#p_pos{tx=TX, ty=TY}, 
                target_area=TargetArea, 
                pk_mode=SPKMode,
                owner_id=SActorID,
                owner_type=OwnerType,
                owner_name=SActorName,
                trap_type=TrapType,
                effects=Effects,
                buffs=Buffs} = Trap,
    
    case OwnerType of
        ?TYPE_ROLE ->
            SActorType = role;
        _ ->
            SActorType = monster
    end,

    %% 作用的ACTOR列表
    EffectActorList = mod_fight:get_effect_actor(TX, TY, TargetArea, ?SKILL_EFFECT_TYPE_ENEMY, SActorID, SActorType, SPKMode, MapID, SActorMapInfo),
    %%
    _ResultList =
        lists:foldl(
          fun({DActorID, DActorType}, RL) ->
                  case Effects of
                      [] ->
                          ResultValue = 0;
                      _ ->
                          Effects2 = mod_skill_manager:get_skill_level_effects(Effects),

                          ResultValue =
                              lists:foldl(
                                fun(Effect, Acc) ->
                                        #p_effect{value=Value} = Effect,
                                        Acc + Value
                                end, 0, Effects2),
                          mod_effect:reduce_hp(ResultValue, DActorType, DActorID, SActorName, SActorID, role),
                          mod_effect:broadcast_skill_effect(DActorID, DActorType, SActorID, SActorType, ResultValue, mgeem_map:get_state())
                  end,

                  case Buffs =:= [] of
                      true ->
                          Buffs2 = [];
                      _ ->
                          Buffs2 = mod_skill_manager:get_skill_level_buffs(Buffs)
                  end,
                  mod_buff:add_buff_to_actor2(SActorID, role, Buffs2, DActorID, DActorType),

                  [{DActorID, DActorType, ?RESULT_TYPE_REDUCE_HP, ResultValue, mod_fight:detail_to_actorbuff(SActorID, SActorType, DActorID, DActorType, Buffs2)}|RL]
          end, [],  EffectActorList),
    %% 如果是一次性陷阱，要删掉陷阱
    case TrapType of
        ?trap_type_once ->
            remove_trap(Trap);
        _ ->
            ignore
    end.

%% @doc 陷阱是否能起作用，暂时只考虑玩家用陷阱技能的情况
check_can_take_effect(DActorID, DActorType, Trap, Now) ->
    #p_map_trap{owner_type=OwnerType,
                owner_id=SActorID,
                faction_id=SFactionID, 
                family_id=SFamilyID, 
                team_id=STeamID, 
                pos=#p_pos{tx=TX, ty=TY}} = Trap,

    case OwnerType of
        ?TYPE_ROLE ->
            SActorType = role;
        _ ->
            SActorType = monster
    end,

    SMapInfo = #p_map_role{faction_id=SFactionID, family_id=SFamilyID, team_id=STeamID, pos=#p_pos{tx=TX, ty=TY}},

    LastTimeStep = get_last_time_step(DActorID, DActorType),

    if
        Now - LastTimeStep < 3 ->
            error;
        SActorType =/= DActorType ->
            {ok, SMapInfo};
        SActorType =:= monster ->
            error;
        SActorID =:= DActorID ->
            error;
        SActorType =:= role ->
            check_can_take_effect2(SMapInfo, DActorID, DActorType, Trap);
        true ->
            error
    end.

check_can_take_effect2(SMapInfo, DRoleID, role, Trap) ->
    case mod_map_actor:get_actor_mapinfo(DRoleID, role) of
        undefined ->
            error;
        DMapInfo ->
            %% pk模式判断
            #p_map_trap{pk_mode=SPKMode} = Trap,
            case catch mod_fight:judge_pk_mode_enemy3(SPKMode, SMapInfo, DMapInfo) of
                {true, _} ->
                    {ok, SMapInfo};
                _ ->
                    error
            end
    end.

%% @doc 获取地图所有陷阱列表
get_map_trap_list() ->
    get(?map_trap_list).

%% @doc 初始化地图陷阱列表
init_map_trap_list() ->
    put(?map_trap_list, []).

%% @doc 更新地图陷阱列表
update_map_trap_list(TrapList) ->
    put(?map_trap_list, TrapList).

%% @doc 获取slice陷阱列表
get_slice_trap_list(SliceName) ->
    get({?slice_trap_list, SliceName}).

%% @doc 初始化slice陷阱列表
init_slice_trap_list(SliceName) ->
    put({?slice_trap_list, SliceName}, []).

%% @doc 更新slice陷阱列表
update_slice_trap_list(SliceName, TrapList) ->
    put({?slice_trap_list, SliceName}, TrapList).

%% @doc 根据txty获取slicename
get_slice_name_by_txty(TX, TY) ->
    {SX, SY} = mgeem_map:get_sxsy_by_txty(TX, TY),
    mgeem_map:get_slice_name(SX, SY).

%% @doc 获取陷阱ID
get_trap_id() ->
    case get(trap_id) of
        undefined ->
            put(trap_id, 1),
            1;
        TrapID ->
            put(trap_id, TrapID+1),
            TrapID + 1
    end.

%% @doc 上一次踩陷阱时间
get_last_time_step(ActorID, ActorType) ->
    case get({last_time_step_trap, ActorID, ActorType}) of
        undefined ->
            0;
        T ->
            T
    end.

%% @doc 更新上一次踩陷阱时间
update_last_time_step(ActorID, ActorType, Now) ->
    put({last_time_step_trap, ActorID, ActorType}, Now).
