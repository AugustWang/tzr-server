%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2011, 
%%% @doc
%%%
%%% @end
%%% Created : 16 Jun 2011 by  <>
%%%-------------------------------------------------------------------
-module(mod_role_buff).

-include("mgeem.hrl").

-export([
        add_buff/2,
        add_buff/4,
        remove_buff/2,
        remove_buff/4,
        get_buff_map_trans_data/1,
        set_buff_map_trans_data/1,
        t_add_buff2/6,
        get_trans_func_list/0,
        clear_trans_func_list/0]).

-export([
         hook_map_loop_sec/0,
         hook_role_online/1,
         hook_role_offline/1]).

-export([
         t_add_buff_add/6,
         t_add_buff_sum/6,
         t_add_buff_replace/6]).

-export([
         burning/4,
         poisoning/4,
         add_hp/4,
         add_drunk_exp/4]).

-define(ROLE_BUFF_LIST, role_buff_list).
-define(TRANSACTION_FUNC_LIST, transaction_func_list).

-define(MULTI_EXP_BUFF_TYPE, 1000).
-define(DRUNK_BUFF_TYPE, 1035).
-define(TYPE_ABSOLUTE, 0).
-define(TYPE_PERCENT, 1).
-define(BUFF_KIND_FIGHT, 3).

%% key: {role_id, buff_type}
-record(r_role_buff, {key, role_id, buff_id, buff_type, last_type, last_interval, src_actor_id, src_actor_type, last_effect_time, end_time}).

%% ==============================================
%% API func
%% ==============================================

%% @doc 添加BUFF
add_buff(RoleID, BuffID) when is_integer(BuffID) ->
    add_buff(RoleID, [BuffID]);
add_buff(RoleID, BuffIDList) ->
    add_buff(RoleID, RoleID, role, BuffIDList).

add_buff(RoleID, SActorID, SActorType, AddBuffID) when is_integer(AddBuffID) ->
    add_buff(RoleID, SActorID, SActorType, [AddBuffID]);
add_buff(RoleID, SActorID, SActorType, AddBuffDetail) when is_record(AddBuffDetail, p_buf) ->
    add_buff(RoleID, SActorID, SActorType, [AddBuffDetail]);
add_buff(RoleID, SActorID, SActorType, [BuffID|_]=AddBuffIDList) when is_integer(BuffID) ->
    AddBuffDetailList =
        lists:map(
          fun(ID) ->
                  {ok, BuffDetail} = mod_skill_manager:get_buf_detail(ID),
                  BuffDetail
          end, AddBuffIDList),
    add_buff(RoleID, SActorID, SActorType, AddBuffDetailList);
add_buff(RoleID, SActorID, SActorType, AddBuffDetailList) ->
    add_buff2(RoleID, SActorID, SActorType, AddBuffDetailList).

add_buff2(RoleID, SActorID, SActorType, AddBuffList) ->
    case catch check_can_add_buff(RoleID) of
        {ok, RoleMapInfo} ->
            add_buff3(RoleID, SActorID, SActorType, AddBuffList, RoleMapInfo);
        {error, _} ->
            ignore;
        R ->
            ?ERROR_MSG("add_buff2, error: ~w", [R]),
            ignore
    end.

add_buff3(RoleID, SActorID, SActorType, AddBuffList, _RoleMapInfo) ->
    case common_transaction:t(
           fun() ->
                   t_add_buff(RoleID, SActorID, SActorType, AddBuffList)
           end)
    of 
        {atomic, _} ->
            %% 事务外执行函数
            exec_trans_func();
        {aborted, Reason} ->
            ?ERROR_MSG("add_buff, error: ~w", [Reason])
    end.

t_add_buff(RoleID, SActorID, SActorType, AddBuffList) ->
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    t_add_buff2(RoleID, SActorID, SActorType, AddBuffList, RoleBase, RoleAttr).

t_add_buff2(RoleID, SActorID, SActorType, AddBuffList, RoleBase, RoleAttr) ->
    Now = common_tool:now(),
    #p_role_base{buffs=RoleBuffList} = RoleBase,
    {RoleBuffList2, CalcAttr} =
        lists:foldl(
          fun(AddBuff, {RBL, CA}) ->
                  #p_buf{buff_type=BuffType, kind=BuffKind, level=BuffLevel} = AddBuff,
                  case get_buff_add_func(RBL, BuffType, BuffKind, BuffLevel) of
                      {ok, ignore} ->
                          {RBL, CA};
                      {ok, Func} ->
                          case is_need_recalc_attr(BuffType) of
                              true ->
                                  CA2 = true;
                              _ ->
                                  CA2 = CA
                          end,
                          {?MODULE:Func(RoleID, SActorID, SActorType, Now, RBL, AddBuff),
                           CA2}
                  end 
          end, {RoleBuffList, false}, AddBuffList),
    RoleBase2 = RoleBase#p_role_base{buffs=RoleBuffList2},
    {RoleBase3, RoleAttr3} =
        case CalcAttr of
            false ->
                {RoleBase2, RoleAttr};
            _ ->
                {ok, RA, RB} = mod_map_role:calc_attr(RoleAttr, RoleBase2),
                {RB, RA}
        end,
    mod_map_role:set_role_base(RoleID, RoleBase3),
    mod_map_role:set_role_attr(RoleID, RoleAttr3),
    Fun = fun() ->
                  DataRecord = #m_role2_reload_toc{role_base=RoleBase3, role_attr=RoleAttr3},
                  common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_RELOAD, DataRecord)
          end,
    trans_func_list_insert({func, Fun}),
    {ok, RoleBase3, RoleAttr3}.

%% -record(r_role_buff, {key, role_id, buff_id, buff_type, last_type, last_interval, last_effect_type, end_time}).
t_add_buff_add(RoleID, SActorID, SActorType, Now, RoleBuffList, AddBuff) ->
    ActorBuff = common_skill:get_actor_buf_by_id(RoleID, SActorID, SActorType, AddBuff),
    RoleBuffList2 = [ActorBuff|RoleBuffList],
    {ok, RoleBuff} = get_role_buff_by_detail(RoleID, SActorID, SActorType, AddBuff, Now),
    case RoleBuff of
        undefined ->
            ignore;
        _ ->
            trans_func_list_insert({func, fun() -> role_buff_list_insert(RoleBuff) end})
    end,
    RoleBuffList2.

t_add_buff_replace(RoleID, SActorID, SActorType, Now, RoleBuffList, AddBuff) ->
    #p_buf{buff_type=BuffType} = AddBuff,
    ActorBuff = common_skill:get_actor_buf_by_id(RoleID, SActorID, SActorType, AddBuff),
    RoleBuffList2 = [ActorBuff|lists:keydelete(BuffType, #p_actor_buf.buff_type, RoleBuffList)],
    {ok, RoleBuff} = get_role_buff_by_detail(RoleID, SActorID, SActorType, AddBuff, Now),
    case RoleBuff of
        undefined ->
            ignore;
        _ ->
            trans_func_list_insert({func, fun() -> role_buff_list_update(RoleBuff) end})
    end,
    RoleBuffList2.

t_add_buff_sum(RoleID, SActorID, SActorType, Now, RoleBuffList, AddBuff) ->
    #p_buf{buff_type=BuffType, last_value=LastTime} = AddBuff,
    ActorBuff = lists:keyfind(BuffType, #p_actor_buf.buff_type, RoleBuffList),
    #p_actor_buf{end_time=EndTime} = ActorBuff,
    RemainTime = EndTime - Now + LastTime,
    ActorBuff2 = ActorBuff#p_actor_buf{start_time=Now, remain_time=RemainTime, end_time=Now+RemainTime},
    RoleBuffList2 = [ActorBuff2|lists:keydelete(BuffType, #p_actor_buf.buff_type, RoleBuffList)],
    AddBuff2 = AddBuff#p_buf{last_value=RemainTime},
    {ok, RoleBuff} = get_role_buff_by_detail(RoleID, SActorID, SActorType, AddBuff2, Now),
    case RoleBuff of
        undefined ->
            ignore;
        _ ->
            trans_func_list_insert({func, fun() -> role_buff_list_update(RoleBuff) end})
    end,
    RoleBuffList2.
 
%% @doc 移除BUFF
remove_buff(RoleID, BuffType) when is_integer(BuffType) ->
    remove_buff(RoleID, [BuffType]);
remove_buff(RoleID, BuffTypeList) ->
    remove_buff(RoleID, RoleID, role, BuffTypeList).

remove_buff(RoleID, SActorID, SActorType, BuffType) when is_integer(BuffType) ->
    remove_buff(RoleID, SActorID, SActorType, [BuffType]);
remove_buff(RoleID, SActorID, SActorType, BuffTypeList) ->
    case catch check_can_remove_buff(RoleID) of
        {ok, RoleMapInfo} ->
            remove_buff2(RoleID, SActorID, SActorType, BuffTypeList, RoleMapInfo);
        {error, _} ->
            ignore;
        R ->
            ?ERROR_MSG("remove_buff, error: ~w", [R]),
            ignore
    end.

remove_buff2(RoleID, _SActorID, _SActorType, BuffTypeList, _RoleMapInfo) ->
    case common_transaction:t(
           fun() ->
                   t_remove_buff(RoleID, BuffTypeList)
           end)
    of 
        {atomic, _} ->
            %% 事务外执行函数
            exec_trans_func();
        {aborted, Reason} ->
            ?ERROR_MSG("remove_buff2, reason: ~w", [Reason]),
            ignore
    end.

t_remove_buff(RoleID, BuffTypeList) ->
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_base{buffs=RoleBuffList} = RoleBase,
    {RoleBuffList2, CalcAttr} =
        lists:foldl(
          fun(ActorBuff, {RBL, CA}) ->
                  #p_actor_buf{buff_type=BuffType, buff_id=BuffID} = ActorBuff,
                  IsMember = lists:member(BuffType, BuffTypeList),
                  if
                      IsMember ->
                          {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
                          IsRemove = true;
                      BuffTypeList =:= [0] ->   %%驱散所有BUFF
                          {ok, #p_buf{can_remove=CanRemove}=BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
                          if CanRemove -> IsRemove = true;
                             true -> IsRemove = false
                          end;
                      BuffTypeList =:= [-1] ->    %%驱散debuff
                          {ok, #p_buf{can_remove=CanRemove,is_debuff=IsDebuff}=BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
                          if CanRemove andalso IsDebuff-> IsRemove = true;
                             true -> IsRemove = false
                          end;
                      BuffTypeList =:= [-2] ->    %%驱散有用的buff
                          {ok, #p_buf{can_remove=CanRemove, is_debuff=IsDebuff}=BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
                          if CanRemove andalso (not IsDebuff)-> IsRemove = true;
                             true -> IsRemove = false
                          end;
                      true ->
                          BuffDetail = undefined,
                          IsRemove = false
                  end,
                  case IsRemove of
                      false ->
                          {RBL, CA};
                      _ ->
                          RBL2 = lists:keydelete(BuffType, #p_actor_buf.buff_type, RBL),
                          #p_buf{last_type=LastType} = BuffDetail,
                          if
                              LastType =:= ?BUFF_LAST_TYPE_FOREVER_TIME orelse
                              LastType =:= ?BUFF_LAST_TYPE_SUMMONED_PET ->
                                  ignore;
                              true ->
                                  Fun = fun() -> role_buff_list_delete({RoleID, BuffType}) end,
                                  trans_func_list_insert({func, Fun})
                          end,
                          case is_need_recalc_attr(BuffType) of
                              true ->
                                  CA2 = true;
                              _ ->
                                  CA2 = CA
                          end,
                          {RBL2, CA2}
                  end
          end, {RoleBuffList, false}, RoleBuffList),
    RoleBase2 = RoleBase#p_role_base{buffs=RoleBuffList2},
    {RoleBase3, RoleAttr3} =
        case CalcAttr of
            true ->
                {ok, RA, RB} = mod_map_role:calc_attr(RoleAttr, RoleBase2),
                {RB, RA};
            _ ->
                {RoleBase2, RoleAttr}
        end,
    mod_map_role:set_role_base(RoleID, RoleBase3),
    mod_map_role:set_role_attr(RoleID, RoleAttr3),
    case erlang:length(RoleBuffList) =:= erlang:length(RoleBuffList2) of
        true ->
            ignore;
        _ ->
            Fun = fun() ->
                          DataRecord = #m_role2_reload_toc{role_base=RoleBase3, role_attr=RoleAttr3},
                          common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_RELOAD, DataRecord)
                  end,
            trans_func_list_insert({func, Fun})
    end,
    {ok, RoleBase3, RoleAttr3}.

%% @doc 获取地图跳转需要传送的数据
get_buff_map_trans_data(RoleID) ->
    lists:foldl(
      fun(#r_role_buff{role_id=ID}=RoleBuff, Acc) ->
              case RoleID =:= ID of
                  true ->
                      [RoleBuff|Acc];
                  _ ->
                      Acc
              end
      end, [], get_role_buff_list()).

%% @doc 设置地图跳转数据
set_buff_map_trans_data(RoleBuffList) ->
    lists:foreach(
      fun(RoleBuff) ->
              role_buff_list_insert(RoleBuff)
      end, RoleBuffList).

%% @doc 地图循环
hook_map_loop_sec() ->
    Now = common_tool:now(),
    RoleBuffList =
        lists:foldl(
          fun(RoleBuff, L) ->
                  case mod_map_actor:get_actor_mapinfo(RoleBuff#r_role_buff.role_id, role) of
                      undefined ->
                          L;
                      _ ->
                          hook_map_loop_sec2(Now, RoleBuff, L)
                  end
          end, [], get_role_buff_list()),
    set_role_buff_list(RoleBuffList).

hook_map_loop_sec2(Now, RoleBuff, L) ->
    #r_role_buff{role_id=RoleID, buff_id=BuffID, buff_type=BuffType, end_time=EndTime, last_type=LastType, 
                 last_interval=LastInterval, last_effect_time=LastEffectTime,
                 src_actor_id=SActorID, src_actor_type=SActorType} = RoleBuff,
    RoleBuff2 =
        case LastType of
            ?BUFF_LAST_TYPE_REAL_INTERVAL_TIME ->
                case Now - LastEffectTime >= LastInterval of
                    true ->
                        {ok, Func} = mod_skill_manager:get_buff_func_by_type(BuffType),
                        ?MODULE:Func(RoleID, SActorID, SActorType, BuffID),
                        RoleBuff#r_role_buff{last_effect_time=Now};
                    _ ->
                        RoleBuff
                end;
            _ ->
                RoleBuff
        end,
    %% 判断BUFF是否到
    case Now >= EndTime of
        true ->
            remove_buff(RoleID, BuffType),
            L;
        _ ->
            [RoleBuff2|L]
    end.

%% @doc 下线hook
hook_role_offline(RoleID) ->
    Now = common_tool:now(),
    {ok, #p_role_base{buffs=BuffList}=RoleBase} = mod_map_role:get_role_base(RoleID),
    BuffList2 =
        lists:foldl(
          fun(ActorBuff, BL) ->
                  #p_actor_buf{buff_id=BuffID, end_time=EndTime} = ActorBuff,
                  {ok, #p_buf{last_type=LastType}} = mod_skill_manager:get_buf_detail(BuffID),
                  if LastType =:= ?BUFF_LAST_TYPE_ONLINE_TIME ->
                          [ActorBuff#p_actor_buf{remain_time=EndTime-Now}|BL];
                     LastType =:= ?BUFF_LAST_TYPE_REAL_INTERVAL_TIME ->
                          [ActorBuff#p_actor_buf{remain_time=EndTime-Now}|BL];
                     true -> [ActorBuff|BL]
                  end
          end, [], BuffList),
    {atomic, _} = common_transaction:t(
                    fun() ->
                            mod_map_role:set_role_base(RoleID, RoleBase#p_role_base{buffs=BuffList2})
                    end).

%% @doc 上线hook
hook_role_online(RoleID) ->
    {ok, #p_role_base{buffs=Buffs}=RoleBase} = mod_map_role:get_role_base(RoleID),
    case Buffs of
        [] ->
            ignore;
        _ ->
            hook_role_online2(RoleBase)
    end.

hook_role_online2(RoleBase) ->
    #p_role_base{role_id=RoleID, buffs=BuffList} = RoleBase,
    Now = common_tool:now(),
    {BuffList2, RemoveList} =
        lists:foldl(
          fun(ActorBuff, {BL, RL}) ->
                  #p_actor_buf{buff_id=BuffID, buff_type=BuffType} = ActorBuff,
                  {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
                  #p_buf{last_type=LastType} = BuffDetail,
                  case LastType of
                      ?BUFF_LAST_TYPE_REAL_TIME ->
                          hook_role_online_real_time(ActorBuff, BuffDetail, Now, BL, RL);
                      ?BUFF_LAST_TYPE_ONLINE_TIME ->
                          hook_role_online_online_time(ActorBuff, BuffDetail, Now, BL, RL);
                      ?BUFF_LAST_TYPE_REAL_INTERVAL_TIME ->
                          hook_role_online_real_interval_time(ActorBuff, BuffDetail, Now, BL, RL);
                      ?BUFF_LAST_TYPE_FOREVER_TIME ->
                          {[ActorBuff|BL], RL};
                      _ ->
                          {BL, [BuffType|RL]}
                  end
          end, {[], []}, BuffList),
    {atomic, _} = common_transaction:t(fun() -> mod_map_role:set_role_base(RoleID, RoleBase#p_role_base{buffs=BuffList2}) end),
    case RemoveList of
        [] ->
            ignore;
        _ ->
            mod_map_role:do_attr_change(RoleID)
    end.

hook_role_online_real_time(ActorBuff, BuffDetail, Now, BuffList, RemoveList) ->
    #p_actor_buf{end_time=EndTime, buff_type=BuffType, actor_id=RoleID, from_actor_id=SActorID, from_actor_type=SActorType} = ActorBuff,
    case Now >= EndTime of
        true ->
            {BuffList, [BuffType|RemoveList]};
        _ ->
            ActorBuff2 = ActorBuff#p_actor_buf{start_time=Now, remain_time=EndTime-Now},
            BuffDetail2 = BuffDetail#p_buf{last_value=EndTime-Now},
            {ok, RoleBuff} = get_role_buff_by_detail(RoleID, SActorID, SActorType, BuffDetail2, Now),
            role_buff_list_insert(RoleBuff),
            {[ActorBuff2|BuffList], RemoveList}
    end.

hook_role_online_online_time(ActorBuff, BuffDetail, Now, BuffList, RemoveList) ->
    #p_actor_buf{remain_time=RemainTime, buff_type=BuffType, actor_id=RoleID, from_actor_id=SActorID, from_actor_type=SActorType} = ActorBuff,
    case RemainTime =< 0 of
        true ->
            {BuffList, [BuffType|RemoveList]};
        _ ->
            ActorBuff2 = ActorBuff#p_actor_buf{start_time=Now, remain_time=RemainTime, end_time=Now+RemainTime},
            BuffDetail2 = BuffDetail#p_buf{last_value=RemainTime},
            {ok, RoleBuff} = get_role_buff_by_detail(RoleID, SActorID, SActorType, BuffDetail2, Now),
            role_buff_list_insert(RoleBuff),
            {[ActorBuff2|BuffList], RemoveList}
    end.  

hook_role_online_real_interval_time(ActorBuff, BuffDetail, Now, BuffList, RemoveList) ->
    #p_actor_buf{remain_time=RemainTime, buff_type=BuffType, actor_id=RoleID, from_actor_id=SActorID, from_actor_type=SActorType} = ActorBuff,
    case RemainTime =< 0 of
        true ->
            {BuffList, [BuffType|RemoveList]};
        _ ->
            ActorBuff2 = ActorBuff#p_actor_buf{start_time=Now, remain_time=RemainTime, end_time=Now+RemainTime},
            BuffDetail2 = BuffDetail#p_buf{last_value=RemainTime},
            {ok, RoleBuff} = get_role_buff_by_detail(RoleID, SActorID, SActorType, BuffDetail2, Now),
            role_buff_list_insert(RoleBuff),
            {[ActorBuff2|BuffList], RemoveList}
    end.
    

%% @doc 燃烧掉血
burning(RoleID, SActorID, SActorType, BuffID) -> 
    {ok, #p_role_base{max_hp=MaxHP}} = mod_map_role:get_role_base(RoleID),
    {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
    #p_buf{buff_type=BuffType, absolute_or_rate=AOR, value=Value} = BuffDetail,
    %%计算伤害值
    case AOR of 
        ?TYPE_ABSOLUTE -> 
            EffectValue = Value;
        ?TYPE_PERCENT -> 
            EffectValue = common_tool:ceil(MaxHP * Value / 10000)
    end,
    %%广播伤害
    broad_cast_buff_interval_effect(RoleID,
                                    ?BUFF_INTERVAL_EFFECT_REDUCE_HP,
                                    EffectValue,
                                    BuffType,
                                    SActorID,
                                    SActorType),
    mod_map_role:do_role_reduce_hp(RoleID, EffectValue, "", SActorID, SActorType, mgeem_map:get_state()).

%% @doc 中毒掉血
poisoning(RoleID, SActorID, SActorType, BuffID) ->
    {ok, #p_role_base{max_hp=MaxHP}} = mod_map_role:get_role_base(RoleID),
    {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
    #p_buf{buff_type=BuffType, absolute_or_rate=AOR, value=Value} = BuffDetail,
    case AOR of 
        ?TYPE_ABSOLUTE -> 
            EffectValue = Value;
        ?TYPE_PERCENT -> 
            EffectValue = common_tool:ceil(MaxHP * Value / 10000) 
    end,
    broad_cast_buff_interval_effect(RoleID,
                                    ?BUFF_INTERVAL_EFFECT_REDUCE_HP,
                                    EffectValue,
                                    BuffType,
                                    SActorID,
                                    SActorType),
    mod_map_role:do_role_reduce_hp(RoleID, EffectValue, "", SActorID, SActorType, mgeem_map:get_state()).


%% @doc 掉血
add_hp(RoleID, SActorID, SActorType, BuffID) ->
    {ok, #p_role_base{max_hp=MaxHP}} = mod_map_role:get_role_base(RoleID),
    {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
    #p_buf{buff_type=BuffType, absolute_or_rate=AOR, value=Value} = BuffDetail,
    case AOR of 
        ?TYPE_ABSOLUTE -> 
            Increment = Value;
        ?TYPE_PERCENT ->
            Increment = common_tool:ceil(MaxHP * Value / 10000)
    end,
    broad_cast_buff_interval_effect(RoleID,
                                    ?BUFF_INTERVAL_EFFECT_ADD_HP,
                                    Increment,
                                    BuffType,
                                    SActorID,
                                    SActorType
                                   ),
    mod_map_role:do_role_add_hp(RoleID, Increment, SActorID).

%% @doc 醉酒加经验
add_drunk_exp(RoleID, _SActorID, _SActorType, BuffID) ->
    #p_map_role{state=RoleState, level=RoleLevel} =  mod_map_actor:get_actor_mapinfo(RoleID, role),
    {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
    case RoleState of
        ?ROLE_STATE_ZAZEN ->
            AddExp = mod_map_bonfire:get_bonfire_add_exp(RoleID, RoleLevel, BuffDetail#p_buf.value),
            mod_map_role:do_add_exp(RoleID,AddExp);
        _ ->
            mod_map_bonfire:del_range_role(RoleID),
            ignore
    end.


%% ================================================
%% Interval func
%% ================================================

%%广播间隔作用BUFF效果
broad_cast_buff_interval_effect(RoleID, EffectType, Value, BuffType, SActorID, SActorType) ->
    Effect = #p_buff_effect{effect_type=EffectType, effect_value=Value, buff_type=BuffType},
    Record = #m_fight_buff_effect_toc{
      actor_id=RoleID,
      actor_type=?TYPE_ROLE,
      buff_effect=[Effect],
      src_id=SActorID,
      src_type=mod_fight:get_dest_type(SActorType)},
    mgeem_map:do_broadcast_insence_include([{role, RoleID}], ?FIGHT, ?FIGHT_BUFF_EFFECT, Record, mgeem_map:get_state()).

%% @doc 
get_role_buff_by_detail(RoleID, SActorID, SActorType, BuffDetail, Now) ->
    #p_buf{buff_id=BuffID, buff_type=BuffType, last_type=LastType, last_value=LastTime, last_interval=LastInterval} = BuffDetail,
    if LastType =:= ?BUFF_LAST_TYPE_FOREVER_TIME orelse LastType =:= ?BUFF_LAST_TYPE_SUMMONED_PET ->
            RoleBuff = undefined;
       LastType =:= ?BUFF_LAST_TYPE_REAL_INTERVAL_TIME ->
            RoleBuff = #r_role_buff{key={RoleID, BuffType}, role_id=RoleID, buff_id=BuffID, buff_type=BuffType,
                                    last_type=LastType, last_interval=LastInterval, last_effect_time=Now,
                                    end_time=Now+LastTime, src_actor_id=SActorID, src_actor_type=SActorType};
       true ->
            RoleBuff = #r_role_buff{key={RoleID, BuffType}, role_id=RoleID, buff_type=BuffType, end_time=Now+LastTime}
    end,
    {ok, RoleBuff}.

%% @doc 是否可以移除BUFF
check_can_remove_buff(RoleID) ->
    RoleMapInfo =
        case mod_map_actor:get_actor_mapinfo(RoleID, role) of
            undefined ->
                erlang:throw({error, system_error});
            RMI ->
                RMI
        end,
    {ok, RoleMapInfo}.

%% @doc 是否可以加BUFF
check_can_add_buff(RoleID) ->
    RoleMapInfo =
        case mod_map_actor:get_actor_mapinfo(RoleID, role) of
            undefined ->
                erlang:throw({error, system_error});
            RMI ->
                RMI
        end,
    {ok, RoleMapInfo}.

%% @doc 是否需要重算属性，部分BUFF类型不用重算属性
is_need_recalc_attr(_BuffType) ->
    true.

%% @doc 获取BUFF添加类型
%% @desc 同一类型的BUFF角色身上只能有一个，通常高级的BUFF会替代低级BUFF，同一等级的战斗BUFF会互相替换，同一等级的其它BUFF时间会叠加
%%       特殊情况：永久性BUFF不会被替换，不同等级的经验、醉酒BUFF会相互替换
get_buff_add_func(RoleBuffs, BuffType, BuffKind, BuffLevel) ->
    case lists:keyfind(BuffType, #p_actor_buf.buff_type, RoleBuffs) of
        false ->
            {ok, t_add_buff_add};
        #p_actor_buf{buff_id=BuffID} ->
            {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
            #p_buf{level=BuffLevelOld, last_type=LastType} = BuffDetail,
            if
                BuffType =:= ?MULTI_EXP_BUFF_TYPE andalso BuffLevel =/= BuffLevelOld ->
                    {ok, t_add_buff_replace};
                BuffType =:= ?DRUNK_BUFF_TYPE andalso BuffLevel =/= BuffLevelOld ->
                    {ok, t_add_buff_replace};
                BuffLevel > BuffLevelOld ->
                    {ok, t_add_buff_replace};
                BuffLevel =:= BuffLevelOld ->
                    case LastType =:= ?BUFF_LAST_TYPE_FOREVER_TIME of
                        true ->
                            {ok, ignore};
                        _ ->
                            case BuffKind =:= ?BUFF_KIND_FIGHT of
                                true ->
                                    {ok, t_add_buff_replace};
                                _ ->
                                    {ok, t_add_buff_sum}
                            end
                    end;
                true ->
                    {ok, ignore}
            end
    end.

%% @doc 执行事务外函数
exec_trans_func() ->
    FuncList = get_trans_func_list(),
    case FuncList of
        undefined ->
            ignore;
        _ ->
            lists:foreach(
              fun({func, Fun}) ->
                      Fun()
              end, FuncList)
    end,
    clear_trans_func_list().

%% ================================================
%% dict tool func
%% ================================================

%% @doc 获取地图BUFF列表
get_role_buff_list() ->
    case erlang:get(?ROLE_BUFF_LIST) of
        undefined ->
            [];
        L ->
            L
    end.

%% @doc 设置地图BUFF列表
set_role_buff_list(BuffList) ->
    erlang:put(?ROLE_BUFF_LIST, BuffList).

%% @doc 插入地图BUFF列表
role_buff_list_insert(RoleBuff) ->
    BuffList = get_role_buff_list(),
    case lists:keyfind(RoleBuff#r_role_buff.key, #r_role_buff.key, BuffList) of
        false ->
            set_role_buff_list([RoleBuff|BuffList]);
        _ ->
            ignore
    end.

%% @doc 删除地图BUFF列表某元素
role_buff_list_delete({RoleID, BuffType}) ->
    BuffList = get_role_buff_list(),
    set_role_buff_list(lists:keydelete({RoleID, BuffType}, #r_role_buff.key, BuffList)).

%% @doc 更新地图BUFF列表某元素
role_buff_list_update(RoleBuff) ->
    #r_role_buff{key=Key} = RoleBuff,
    BuffList = get_role_buff_list(),
    set_role_buff_list([RoleBuff|lists:keydelete(Key, #r_role_buff.key, BuffList)]).

%% @doc 设置事务外函数列表
set_trans_func_list(FuncList) ->
    erlang:put(?TRANSACTION_FUNC_LIST, FuncList).

%% @doc 清除事务外函数列表
clear_trans_func_list() ->
    erlang:erase(?TRANSACTION_FUNC_LIST).

%% @doc 获取事务外函数列表
get_trans_func_list() ->
    erlang:get(?TRANSACTION_FUNC_LIST).

%% @doc 插入事务外函数列表
trans_func_list_insert(Func) ->
    FuncList = get_trans_func_list(),
    case FuncList of
        undefined ->
            set_trans_func_list([Func]);
        _ ->
            set_trans_func_list([Func|FuncList])
    end.
