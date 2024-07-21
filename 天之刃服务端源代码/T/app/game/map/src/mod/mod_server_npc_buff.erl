%% Author: liuwei
%% Created: 2010-12-30
%% Description: TODO: Add description to mod_server_npc_buff
-module(mod_server_npc_buff).

-include("mgeem.hrl").

-export([
         add_buff/5,
         remove_buff/5,
         remove_buff/6
        ]).

-export([
         burning/5, 
         poisoning/5
        ]).

%%
%% API Functions
%%
-define(TYPE_ABSOLUTE, 0).
-define(TYPE_PERCENT, 1).

add_buff(_, _, [], _, ServerNpcState) ->
    ServerNpcState;

add_buff(SrcActorID, SrcActorType, AddBuffs, ServerNpcID, ServerNpcState) when is_list(AddBuffs) ->
    #server_npc_state{server_npc_info=ServerNpcInfo, buf_timer_ref=BuffTimerRef} = ServerNpcState,
    #p_server_npc{state=State, buffs=Buffs} = ServerNpcInfo,

    %%如果挂了就没有必要加了。。
    case State =:= ?DEAD_STATE of
        true ->
            ServerNpcState;

        _ ->

            {Buffs2, BuffTimerRef2} =
                lists:foldl(
                  fun(BuffDetail, {BuffsTmp, BuffTimerRefTmp}) ->
                          case get_add_buff_method(BuffDetail, Buffs) of
                              {ok, add_buff} ->
                                  add_buff2(SrcActorID, SrcActorType, ServerNpcID, BuffDetail, BuffsTmp, BuffTimerRefTmp);

                              {ok, replace_buff} ->
                                  replace_buff(SrcActorID, SrcActorType, ServerNpcID, BuffDetail, BuffsTmp, BuffTimerRefTmp);

                              _ ->
                                  {BuffsTmp, BuffTimerRefTmp}
                          end
                  end, {Buffs, BuffTimerRef}, AddBuffs),
            ?DEBUG("add_buff, buffs: ~w, bufftimerref: ~w, buffs2: ~w, bufftimerref2: ~w",
                   [Buffs, BuffTimerRef, Buffs2, BuffTimerRef2]),

            ServerNpcInfo2 = ServerNpcInfo#p_server_npc{buffs=Buffs2},

            %%重新计划怪物属性
            case calc_attr_after_attr_update(ServerNpcInfo2, Buffs2) of
                {ok, ServerNpcInfo3} ->
                    ServerNpcState#server_npc_state{server_npc_info=ServerNpcInfo3, buf_timer_ref=BuffTimerRef2};
                _ ->
                    ServerNpcState#server_npc_state{buf_timer_ref=BuffTimerRef2}
            end
    end;

add_buff(SrcActorID, SrcActorType, AddBuff, ServerNpcID, ServerNpcState) ->
    add_buff(SrcActorID, SrcActorType, [AddBuff], ServerNpcID, ServerNpcState).

add_buff2(SrcActorID, SrcActorType, ServerNpcID, BuffDetail, Buffs, BuffTimerRef) ->

    ActorBuff = get_actor_buf_by_id(SrcActorID, SrcActorType, ServerNpcID, BuffDetail),

    %%获取BUFF相应的处理函数
    BuffType = BuffDetail#p_buf.buff_type,
    {ok, BuffFunc} = mod_skill_manager:get_buff_func_by_type(BuffType),
    
    %%定时
    Args = [ActorBuff, BuffDetail, SrcActorID, SrcActorType],
    TimerRef = setup_buf_timer(BuffType, BuffFunc, BuffDetail, Args),

    {[ActorBuff|Buffs], [{BuffType, TimerRef}|BuffTimerRef]}.

replace_buff(SrcActorID, SrcActorType, ServerNpcID, BuffDetail, Buffs, BuffTimerRef) ->

    ActorBuff = get_actor_buf_by_id(SrcActorID, SrcActorType, ServerNpcID, BuffDetail),

    %%获取BUFF相应的处理函数
    BuffType = BuffDetail#p_buf.buff_type,
    {ok, BuffFunc} = mod_skill_manager:get_buff_func_by_type(BuffType),

    %%删除原来的计时
    {BuffType, TimerRef0} = lists:keyfind(BuffType, 1, BuffTimerRef),
    erlang:cancel_timer(TimerRef0),

    BuffTimerRef2 = lists:keydelete(BuffType, 1, BuffTimerRef),
    Buffs2 = lists:keydelete(BuffType, #p_actor_buf.buff_type, Buffs),

    %%定时
    Args = [ActorBuff, BuffDetail, SrcActorID, SrcActorType],
    TimerRef = setup_buf_timer(BuffType, BuffFunc, BuffDetail, Args),

    {[ActorBuff|Buffs2], [{BuffType, TimerRef}|BuffTimerRef2]}.    

get_actor_buf_by_id(SrcActorID, SrcActorType, ServerNpcID, BuffDetail) ->
    #p_buf{
            buff_id=BuffID,
            last_value=LastValue,
            value=Value,
            buff_type=BuffType
          } = BuffDetail,

    BeginTime = common_tool:now(),

    #p_actor_buf{
                  buff_id=BuffID,
                  buff_type=BuffType,
                  actor_id=ServerNpcID,
                  actor_type=?TYPE_SERVER_NPC,
                  from_actor_id=SrcActorID,
                  from_actor_type=mod_fight:get_dest_type(SrcActorType),
                  value=Value,
                  start_time=BeginTime,
                  end_time=BeginTime+LastValue,
                  remain_time=LastValue
                }.
                  
%%BUFF处理方式
get_add_buff_method(BuffDetail, Buffs) ->
    #p_buf{buff_type=BuffType, level=Level} = BuffDetail,

    %%没有的话就加上
    case lists:keyfind(BuffType, #p_actor_buf.buff_type, Buffs) of
        false ->
            {ok, add_buff};
        
        ActorBuff ->
            
            %%如果新加的BUFF等级较高则替换或则无操作
            BuffID = ActorBuff#p_actor_buf.buff_id,
            {ok, ActorBuffDetail} = mod_skill_manager:get_buf_detail(BuffID),

            ActorBuffLevel = ActorBuffDetail#p_buf.level,
            case ActorBuffLevel >= Level of
                true ->
                    {ok, replace_buff};
                
                _ ->
                    {ok, no_operate}
            end
    end.

%%仅间隔作用BUFF才会用到这个函数。。。
remove_buff(_SrcActorID, _SrcActorType, [ActorBuff], _ServerNpcID, ServerNpcState, TimerRef) ->
    BuffTimerRef = ServerNpcState#server_npc_state.buf_timer_ref,
    BuffType = ActorBuff#p_actor_buf.buff_type,

    case lists:keyfind(BuffType, 1, BuffTimerRef) of
        {BuffType, TimerRef} ->
            remove_buff(_SrcActorID, _SrcActorType, [ActorBuff], _ServerNpcID, ServerNpcState);

        _ ->
            ServerNpcState
    end.

%%驱散所有可以驱散的BUFF
remove_buff(_SrcActorID, _SrcActorType, 0, _ServerNpcID, ServerNpcState) ->
    ServerNpcInfo = ServerNpcState#server_npc_state.server_npc_info,
    Buffs = ServerNpcInfo#p_server_npc.buffs,

    RemoveList =
        lists:foldl(
          fun(ActorBuff, Acc) ->
                  BuffID = ActorBuff#p_actor_buf.buff_id,

                  {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),

                  CanRemove = BuffDetail#p_buf.can_remove,
                  case CanRemove of
                      true ->
                          [ActorBuff|Acc];

                      false ->
                          Acc
                  end
          end, [], Buffs),
    ?DEBUG("remove_buff, removelist: ~w", [RemoveList]),

    remove_buff2(RemoveList, ServerNpcState);

%%驱散指定类型的BUFF
remove_buff(_SrcActorID, _SrcActorType, BuffType, _ServerNpcID, ServerNpcState) when is_integer(BuffType) ->
    ServerNpcInfo = ServerNpcState#server_npc_state.server_npc_info,
    Buffs = ServerNpcInfo#p_server_npc.buffs,

    ?DEBUG("remove_buff, bufftype: ~w", [BuffType]),
    
    RemoveList =
        lists:foldl(
          fun(ActorBuff, Acc) ->
                  Type = ActorBuff#p_actor_buf.buff_type,

                  case Type =:= BuffType of
                      true ->
                          [ActorBuff|Acc];

                      false ->
                          Acc
                  end
          end, [], Buffs),
    
    remove_buff2(RemoveList, ServerNpcState);

remove_buff(_SrcActorID, _SrcActorType, RemoveList, _ServerNpcID, ServerNpcState) when is_list(RemoveList) ->
    remove_buff2(RemoveList, ServerNpcState);

remove_buff(SrcActorID, SrcActorType, RemoveBuff, ServerNpcID, ServerNpcState) ->
    remove_buff(SrcActorID, SrcActorType, [RemoveBuff], ServerNpcID, ServerNpcState).

remove_buff2([], ServerNpcState) ->
    ServerNpcState;

remove_buff2(RemoveList, ServerNpcState) ->
    #server_npc_state{server_npc_info=ServerNpcInfo, buf_timer_ref=BuffTimerRef} = ServerNpcState,
    Buffs = ServerNpcInfo#p_server_npc.buffs,
    ?DEBUG("remove_buff2, buffs: ~w, removelist: ~w, bufftimerref: ~w", [Buffs, RemoveList, BuffTimerRef]),

    {Buffs2, BuffTimerRef2} =
        lists:foldl(
          fun(ActorBuff, {BuffsTmp, BuffTimerRefTmp}) ->

                  BuffType = ActorBuff#p_actor_buf.buff_type,

                  %%删除原来的定时
                  case lists:keyfind(BuffType, 1, BuffTimerRefTmp) of
                      {BuffType, TimerRef} ->
                          erlang:cancel_timer(TimerRef);

                      _ ->
                          ok
                  end,

                  {lists:keydelete(BuffType, #p_actor_buf.buff_type, BuffsTmp),
                   lists:keydelete(BuffType, 1, BuffTimerRefTmp)}
          end, {Buffs, BuffTimerRef}, RemoveList),
    ?DEBUG("remove_buff2, buffstimerref: ~w, buffs2: ~w, buffstimerref2: ~w",
           [BuffTimerRef, Buffs2, BuffTimerRef2]),

    ServerNpcInfo2 = ServerNpcInfo#p_server_npc{buffs=Buffs2},

    %%重新计划怪物属性
    case calc_attr_after_attr_update(ServerNpcInfo2, Buffs2) of
        {ok, ServerNpcInfo3} ->
            ServerNpcState#server_npc_state{server_npc_info=ServerNpcInfo3, buf_timer_ref=BuffTimerRef2};
        _ ->
            ServerNpcState#server_npc_state{buf_timer_ref=BuffTimerRef2}
    end.

%%燃烧减血
burning(ServerNpcState, ActorBuff, BuffDetail, SrcActorID, SrcActorType) -> 
    ServerNpcInfo = ServerNpcState#server_npc_state.server_npc_info,
    MapName = ServerNpcState#server_npc_state.mapname,

    case BuffDetail#p_buf.absolute_or_rate of 
        ?TYPE_ABSOLUTE -> 
            EffectValue = BuffDetail#p_buf.value; 
        ?TYPE_PERCENT -> 
            EffectValue = round(ServerNpcInfo#p_server_npc.max_hp*BuffDetail#p_buf.value / 10000)
    end,

    broad_cast_buff_interval_effect(MapName, ServerNpcInfo#p_server_npc.npc_id,
                                    ?BUFF_INTERVAL_EFFECT_REDUCE_HP, EffectValue, BuffDetail#p_buf.buff_type,
                                    ActorBuff#p_actor_buf.from_actor_id,
                                    ActorBuff#p_actor_buf.from_actor_type),
    mod_server_npc_effect:reduce_hp(EffectValue, SrcActorID, SrcActorType, ServerNpcState).


%%中毒掉血
poisoning(ServerNpcState, ActorBuff, BuffDetail, SrcActorID, SrcActorType) ->
    ServerNpcInfo = ServerNpcState#server_npc_state.server_npc_info,
    MapName = ServerNpcState#server_npc_state.mapname,

    case BuffDetail#p_buf.absolute_or_rate of 
        ?TYPE_ABSOLUTE -> 
            EffectValue = BuffDetail#p_buf.value; 
        ?TYPE_PERCENT -> 
            EffectValue = round(ServerNpcInfo#p_server_npc.max_hp*BuffDetail#p_buf.value / 10000)
    end,

    broad_cast_buff_interval_effect(MapName, ServerNpcInfo#p_server_npc.npc_id,
                                    ?BUFF_INTERVAL_EFFECT_REDUCE_HP, EffectValue, BuffDetail#p_buf.buff_type,
                                    ActorBuff#p_actor_buf.from_actor_id,
                                    ActorBuff#p_actor_buf.from_actor_type),
    mod_server_npc_effect:reduce_hp(EffectValue, SrcActorID, SrcActorType, ServerNpcState).


%%=============================================================
%%=============LOCAL FUNCTION===================================
%%==============================================================

setup_buf_timer(BuffType, BuffFunc, BuffDetail, Args) ->
    #p_buf{last_type=LastType, last_value=LastTime, last_interval=LastInterval} = BuffDetail,
    EndTime = common_tool:now() + LastTime,
    ?DEBUG("setup_buf_timer, lasttime: ~w, last_interval: ~w", [LastTime, LastInterval]),

    [ActorBuf|_] = Args,
    ServerNpcID = ActorBuf#p_actor_buf.actor_id,

    case LastType of

        %%如果是每个ticket都掉血的buff
        ?BUFF_LAST_TYPE_REAL_INTERVAL_TIME ->
            put({buff, BuffType}, EndTime),
            TimerRef = erlang:send_after(LastInterval*1000, self(), {mod_server_npc, {buff_loop, ServerNpcID, ?MODULE, BuffFunc, Args, LastTime, LastInterval}});

        ?BUFF_LAST_TYPE_REAL_TIME ->
            put({buff, BuffType}, EndTime),
            TimerRef = erlang:send_after(LastTime*1000, self(), {mod_server_npc, {remove_buff, ServerNpcID, server_npc, [ActorBuf], ServerNpcID}});

        ?BUFF_LAST_TYPE_ONLINE_TIME ->
            put({buff, BuffType}, EndTime),
            TimerRef = erlang:send_after(LastTime*1000, self(), {mod_server_npc,{remove_buff, ServerNpcID, server_npc, [ActorBuf], ServerNpcID}});

        _ ->
            TimerRef = nil
    end,

    TimerRef.

calc_attr_after_attr_update(ServerNpcInfo, Buffs) ->
    #p_server_npc{type_id=TypeID} = ServerNpcInfo,
    [BaseInfo] = common_config_dyn:find(server_npc, TypeID),
    #p_server_npc_base_info{
                          min_attack = MinAttack,                                 
                          max_attack = MaxAttack,     
                          phy_defence = PhyDefence,                   
                          magic_defence = MagDefence,         
                          blood_resume_speed = HpResume,
                          magic_resume_speed = MpResume,
                          dead_attack = DeadAttack,            
                          lucky = Lucky,
                          move_speed = MoveSpeed,            
                          attack_speed = AttackSpeed,
                          miss = Dodge,                      
                          no_defence = NoDefence,                 
                          max_hp = MaxHp,
                          max_mp = MaxMp,
                          phy_anti=PhyAnti,
                          magic_anti=MagicAnti
                        } = BaseInfo,
    NewServerNpcInfo = 
        ServerNpcInfo#p_server_npc{
          min_attack = MinAttack,                                 
          max_attack = MaxAttack,     
          phy_defence = PhyDefence,                   
          magic_defence = MagDefence,         
          blood_resume_speed = HpResume,
          magic_resume_speed = MpResume,
          dead_attack = DeadAttack,            
          lucky = Lucky,
          move_speed = MoveSpeed,            
          attack_speed = AttackSpeed,
          miss = Dodge,                      
          no_defence = NoDefence,                 
          max_hp = MaxHp,
          max_mp = MaxMp,
          phy_anti=PhyAnti,
          magic_anti=MagicAnti
         },
    NewServerNpcInfo2 = 
        lists:foldl(
          fun(Buf, Acc0) ->
                  #p_actor_buf{buff_id=BuffID, buff_type=Type, from_actor_id=_FromRoleID} = Buf,
                  {ok, Detail} = mod_skill_manager:get_buf_detail(BuffID),
                  #p_buf{value=Value, absolute_or_rate=ValueType} = Detail,
                  {ok, Func} = mod_skill_manager:get_buff_func_by_type(Type),

                  case Func of
                      add_hp_recover ->
                          Old = Acc0#p_server_npc.blood_resume_speed,
                          Acc = Acc0#p_server_npc{blood_resume_speed=( Old + Value)};
                      add_mp_recover ->
                          Old = Acc0#p_server_npc.magic_resume_speed,
                          Acc = Acc0#p_server_npc{magic_resume_speed=( Old + Value)};
                      reduce_hp_recover ->
                          Old = Acc0#p_server_npc.blood_resume_speed,
                          Acc = Acc0#p_server_npc{blood_resume_speed=( Old - Value)};
                      reduce_mp_recover ->
                          Old = Acc0#p_server_npc.magic_resume_speed,
                          Acc = Acc0#p_server_npc{magic_resume_speed=( Old - Value)};
                      add_move_speed ->
                          Old = Acc0#p_server_npc.move_speed,
                          Acc = Acc0#p_server_npc{move_speed=( Old + Value)};
                      reduce_move_speed ->
                          Old = Acc0#p_server_npc.move_speed,
                          case ValueType of
                              0 ->
                                  Acc = Acc0#p_server_npc{move_speed=(Old-Value)};
                              1 ->
                                  Acc = Acc0#p_server_npc{move_speed=(Old-round(Old*Value/10000))}
                          end;
                      add_phy_attack ->
                          case ValueType of
                              0 ->
                                  OldMax = Acc0#p_server_npc.max_attack,
                                  OldMin = Acc0#p_server_npc.min_attack,
                                  Acc = Acc0#p_server_npc{
                                          max_attack=(OldMax+Value),
                                          min_attack=(OldMin+Value)
                                         };
                              1 ->
                                  OldMax = Acc0#p_server_npc.max_attack,
                                  OldMin = Acc0#p_server_npc.min_attack,
                                  AddValue =trunc(OldMax * Value / 10000),
                                  Acc = Acc0#p_server_npc{
                                          max_attack=(OldMax+AddValue),
                                          min_attack=(OldMin+AddValue)
                                         }
                          end;
                      add_attack ->
                          case ValueType of
                              0 ->
                                  OldMax = Acc0#p_server_npc.max_attack,
                                  OldMin = Acc0#p_server_npc.min_attack,
                                  Acc = Acc0#p_server_npc{
                                          max_attack=(OldMax+Value),
                                          min_attack=(OldMin+Value)
                                         };
                              1 ->
                                  OldMax = Acc0#p_server_npc.max_attack,
                                  OldMin = Acc0#p_server_npc.min_attack,
                                  AddValue =trunc(OldMax * Value / 10000),
                                  Acc = Acc0#p_server_npc{
                                          max_attack=(OldMax+AddValue),
                                          min_attack=(OldMin+AddValue)
                                         }
                          end;
                      reduce_phy_attack ->
                          case ValueType of
                              0 ->
                                  OldMax = Acc0#p_server_npc.max_attack,
                                  OldMin = Acc0#p_server_npc.min_attack,
                                  Acc = Acc0#p_server_npc{
                                          max_attack=(OldMax-Value),
                                          min_attack=(OldMin-Value)
                                         };
                              1 ->
                                  OldMax = Acc0#p_server_npc.max_attack,
                                  OldMin = Acc0#p_server_npc.min_attack,
                                  DeductValue =trunc(OldMin * Value / 10000),
                                  Acc = Acc0#p_server_npc{
                                          max_attack=(OldMax-DeductValue),
                                          min_attack=(OldMin-DeductValue)
                                         }
                          end;
                      add_magic_attack ->
                          case ValueType of
                              0 ->
                                  OldMax = Acc0#p_server_npc.max_attack,
                                  OldMin = Acc0#p_server_npc.min_attack,
                                  Acc = Acc0#p_server_npc{
                                          max_attack=(OldMax+Value),
                                          min_attack=(OldMin+Value)
                                         };
                              1 ->
                                  OldMax = Acc0#p_server_npc.max_attack,
                                  OldMin = Acc0#p_server_npc.min_attack,
                                  AddValue =trunc(OldMax * Value / 10000),
                                  Acc = Acc0#p_server_npc{
                                          max_attack=(OldMax+AddValue),
                                          min_attack=(OldMin+AddValue)
                                         }
                          end;
                      reduce_magic_attack ->
                          case ValueType of
                              0 ->
                                  OldMax = Acc0#p_server_npc.max_attack,
                                  OldMin = Acc0#p_server_npc.min_attack,
                                  Acc = Acc0#p_server_npc{
                                          max_attack=(OldMax-Value),
                                          min_attack=(OldMin-Value)
                                         };
                              1 ->
                                  OldMax = Acc0#p_server_npc.max_attack,
                                  OldMin = Acc0#p_server_npc.min_attack,
                                  DeductValue =trunc(OldMin * Value / 10000),
                                  Acc = Acc0#p_server_npc{
                                          max_attack=(OldMax-DeductValue),
                                          min_attack=(OldMin-DeductValue)
                                         }
                          end;
                      add_phy_defence ->
                          case ValueType of
                              0 ->
                                  Old = Acc0#p_server_npc.phy_defence,
                                  Acc = Acc0#p_server_npc{phy_defence=( Old + Value)};
                              1 ->
                                  Old = Acc0#p_server_npc.phy_defence,
                                  AddValue =trunc(Old * Value / 10000),
                                  Acc = Acc0#p_server_npc{phy_defence=( Old + AddValue)}
                          end;
                      reduce_phy_defence ->
                          case ValueType of
                              0 ->
                                  Old = Acc0#p_server_npc.phy_defence,
                                  Acc = Acc0#p_server_npc{phy_defence=( Old - Value)};
                              1 ->
                                  Old = Acc0#p_server_npc.phy_defence,
                                  AddValue =trunc(Old * Value / 10000),
                                  Acc = Acc0#p_server_npc{phy_defence=( Old - AddValue)}
                          end;
                      add_magic_defence ->
                          case ValueType of
                              0 ->
                                  Old = Acc0#p_server_npc.magic_defence,
                                  Acc = Acc0#p_server_npc{magic_defence=( Old + Value)};
                              1 ->
                                  Old = Acc0#p_server_npc.magic_defence,
                                  AddValue =trunc(Old * Value / 10000),
                                  Acc = Acc0#p_server_npc{magic_defence=( Old + AddValue)}
                          end;
                      reduce_magic_defence ->
                          case ValueType of
                              0 ->
                                  Old = Acc0#p_server_npc.magic_defence,
                                  Acc = Acc0#p_server_npc{magic_defence=( Old - Value)};
                              1 ->
                                  Old = Acc0#p_server_npc.magic_defence,
                                  AddValue =trunc(Old * Value / 10000),
                                  Acc = Acc0#p_server_npc{magic_defence=( Old - AddValue)}
                          end;
                      add_max_hp ->
                          case ValueType of
                              0 ->
                                  Old = Acc0#p_server_npc.max_hp,
                                  Acc = Acc0#p_server_npc{max_hp=( Old + Value)};
                              1 ->
                                  Old = Acc0#p_server_npc.max_hp,
                                  AddValue =trunc(Old * Value / 10000),
                                  Acc = Acc0#p_server_npc{max_hp=( Old + AddValue)}
                          end;
                      add_max_mp ->
                          case ValueType of
                              0 ->
                                  Old = Acc0#p_server_npc.max_mp,
                                  Acc = Acc0#p_server_npc{max_mp=( Old + Value)};
                              1 ->
                                  Old = Acc0#p_server_npc.max_mp,
                                  AddValue =trunc(Old * Value / 10000),
                                  Acc = Acc0#p_server_npc{max_mp=( Old + AddValue)}
                          end;
                      add_attack_speed ->
                          Old = Acc0#p_server_npc.attack_speed,
                          Acc = Acc0#p_server_npc{attack_speed=Old+Value};
                      reduce_attack_speed ->
                          Old = Acc0#p_server_npc.attack_speed,
                          Acc = Acc0#p_server_npc{attack_speed=Old-Value};
                      paralysis ->
                          Old = Acc0#p_server_npc.move_speed,
                          Acc = Acc0#p_server_npc{move_speed=Old-common_tool:ceil(Old*Value/10000)};
                      add_miss ->
                          Old =  Acc0#p_server_npc.miss,
                          Acc = Acc0#p_server_npc{miss=Old+Value};
                      reduce_miss ->
                          Old =  Acc0#p_server_npc.miss,
                          Acc = Acc0#p_server_npc{miss=Old-Value};
                      add_no_defence ->
                          Old =  Acc0#p_server_npc.no_defence,
                          Acc = Acc0#p_server_npc{no_defence=Old+Value};
                      reduce_no_defence ->
                          Old =  Acc0#p_server_npc.no_defence,
                          Acc = Acc0#p_server_npc{no_defence=Old-Value};
                      dizzy ->
                          Acc = Acc0#p_server_npc{move_speed=0, attack_speed=0};
                      stop_body ->
                          Acc = Acc0#p_server_npc{move_speed=0};
                      _ ->
                          Acc = Acc0
                  end,
                  Acc
          end, NewServerNpcInfo, Buffs),
    mod_server_npc:update_server_npc_mapinfo(NewServerNpcInfo2),
    {ok,NewServerNpcInfo2}.


broad_cast_buff_interval_effect(MapName,ServerNpcID,EffectType,Value,BuffType, SActorID, SActorType) ->
    Effect = #p_buff_effect{effect_type=EffectType, effect_value=Value, buff_type=BuffType},

    Record = #m_fight_buff_effect_toc{
      actor_id=ServerNpcID,
      actor_type=?TYPE_SERVER_NPC,
      buff_effect=[Effect],
      src_id=SActorID,
      src_type=SActorType},   
    global:send(MapName, {mod_server_npc,{server_npc_broadcast, ServerNpcID, ?FIGHT, ?FIGHT_BUFF_EFFECT, Record}}).
   
