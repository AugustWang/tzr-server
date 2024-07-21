%% Author: liuwei
%% Created: 2011-2-20
%% Description: TODO: Add description to mod_monster_buff
-module(mod_pet_buff).

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

add_buff(_, _, [], _, PetInfo) ->
    PetInfo;

add_buff(SrcActorID, SrcActorType, AddBuffs, PetID, PetInfo) when is_list(AddBuffs) ->
    case get({?PET_BUFF_TIMER_REF,PetID}) of
        
        undefined ->
            BuffTimerRef = [];
        List ->
            BuffTimerRef = List
    end,
    
    #p_pet{buffs=Buffs} = PetInfo,
    
    {Buffs2, BuffTimerRef2} =
        lists:foldl(
          fun(BuffDetail, {BuffsTmp, BuffTimerRefTmp}) ->
                  case get_add_buff_method(BuffDetail, Buffs) of
                      {ok, add_buff} ->
                          add_buff2(SrcActorID, SrcActorType, PetID, BuffDetail, BuffsTmp, BuffTimerRefTmp);
                      
                      {ok, replace_buff} ->
                          replace_buff(SrcActorID, SrcActorType, PetID, BuffDetail, BuffsTmp, BuffTimerRefTmp);
                      
                      _ ->
                          {BuffsTmp, BuffTimerRefTmp}
                  end
          end, {Buffs, BuffTimerRef}, AddBuffs),
    ?DEV("add_buff, buffs: ~w, bufftimerref: ~w, buffs2: ~w, bufftimerref2: ~w",
         [Buffs, BuffTimerRef, Buffs2, BuffTimerRef2]),
    put({?PET_BUFF_TIMER_REF,PetID},BuffTimerRef2),
    PetInfo2 = PetInfo#p_pet{buffs=Buffs2},
    mod_map_pet:calc_pet_attr(PetInfo2);

add_buff(SrcActorID, SrcActorType, AddBuff, PetID, PetInfo) ->
    add_buff(SrcActorID, SrcActorType, [AddBuff], PetID, PetInfo).

add_buff2(SrcActorID, SrcActorType, PetID, BuffDetail, Buffs, BuffTimerRef) ->

    ActorBuff = get_actor_buf_by_id(SrcActorID, SrcActorType, PetID, BuffDetail),

    %%获取BUFF相应的处理函数
    BuffType = BuffDetail#p_buf.buff_type,
    {ok, BuffFunc} = mod_skill_manager:get_buff_func_by_type(BuffType),
    
    %%定时
    Args = [ActorBuff, BuffDetail, SrcActorID, SrcActorType],
    TimerRef = setup_buf_timer(BuffType, BuffFunc, BuffDetail, Args),

    {[ActorBuff|Buffs], [{BuffType, TimerRef}|BuffTimerRef]}.

replace_buff(SrcActorID, SrcActorType, PetID, BuffDetail, Buffs, BuffTimerRef) ->
    %?ERROR_MSG("########### ~w",[{SrcActorID, SrcActorType, PetID, BuffDetail, Buffs, BuffTimerRef}]),
    ActorBuff = get_actor_buf_by_id(SrcActorID, SrcActorType, PetID, BuffDetail),

    %%获取BUFF相应的处理函数
    BuffType = BuffDetail#p_buf.buff_type,
    {ok, BuffFunc} = mod_skill_manager:get_buff_func_by_type(BuffType),
    %?ERROR_MSG("1111111111111  ~w     ~w",[BuffType,BuffTimerRef]),
    %%删除原来的计时
    {BuffType, TimerRef0} = lists:keyfind(BuffType, 1, BuffTimerRef),
    case TimerRef0 of
        nil->
            ignore;
        _->
            erlang:cancel_timer(TimerRef0)
    end,
    BuffTimerRef2 = lists:keydelete(BuffType, 1, BuffTimerRef),
    Buffs2 = lists:keydelete(BuffType, #p_actor_buf.buff_type, Buffs),
    %?ERROR_MSG("2222222222222",[]),
    %%定时
    Args = [ActorBuff, BuffDetail, SrcActorID, SrcActorType],
    TimerRef = setup_buf_timer(BuffType, BuffFunc, BuffDetail, Args),
    %?ERROR_MSG("33333333333",[]),
    {[ActorBuff|Buffs2], [{BuffType, TimerRef}|BuffTimerRef2]}.    

get_actor_buf_by_id(SrcActorID, SrcActorType, PetID, BuffDetail) ->
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
                  actor_id=PetID,
                  actor_type=?TYPE_PET,
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
remove_buff(_SrcActorID, _SrcActorType, [ActorBuff], PetID, PetInfo, TimerRef) ->
    case get({?PET_BUFF_TIMER_REF,PetID}) of
        
        undefined ->
            BuffTimerRef = [];
        List ->
            BuffTimerRef = List
    end,
    BuffType = ActorBuff#p_actor_buf.buff_type,

    case lists:keyfind(BuffType, 1, BuffTimerRef) of
        {BuffType, TimerRef} ->
            remove_buff(_SrcActorID, _SrcActorType, [ActorBuff], PetID, PetInfo);

        _ ->
            PetInfo
    end.

%%驱散所有可以驱散的BUFF
remove_buff(_SrcActorID, _SrcActorType, 0, _PetID, PetInfo) ->
    Buffs = PetInfo#p_pet.buffs,

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

    remove_buff2(RemoveList, PetInfo);

%%驱散指定类型的BUFF
remove_buff(_SrcActorID, _SrcActorType, BuffType, _PetID, PetInfo) when is_integer(BuffType) ->
    Buffs = PetInfo#p_pet.buffs,

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
    
    remove_buff2(RemoveList, PetInfo);

remove_buff(_SrcActorID, _SrcActorType, RemoveList, _PetID, PetInfo) when is_list(RemoveList) ->
    remove_buff2(RemoveList, PetInfo);

remove_buff(SrcActorID, SrcActorType, RemoveBuff, PetID, PetInfo) ->
    remove_buff(SrcActorID, SrcActorType, [RemoveBuff], PetID, PetInfo).

remove_buff2([], PetInfo) ->
    PetInfo;

remove_buff2(RemoveList, PetInfo) ->
    PetID = PetInfo#p_pet.pet_id,
    case get({?PET_BUFF_TIMER_REF,PetID}) of
        
        undefined ->
            BuffTimerRef = [];
        List ->
            BuffTimerRef = List
    end,
    Buffs = PetInfo#p_pet.buffs,
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
    put({?PET_BUFF_TIMER_REF,PetID},BuffTimerRef2),
    PetInfo2 = PetInfo#p_pet{buffs=Buffs2},
    mod_map_pet:calc_pet_attr(PetInfo2).

%%燃烧减血
burning(PetInfo, ActorBuff, BuffDetail, SrcActorID, SrcActorType) -> 

    case BuffDetail#p_buf.absolute_or_rate of 
        ?TYPE_ABSOLUTE -> 
            EffectValue = BuffDetail#p_buf.value; 
        ?TYPE_PERCENT -> 
            EffectValue = round(PetInfo#p_pet.max_hp*BuffDetail#p_buf.value / 10000)
    end,

    broad_cast_buff_interval_effect(PetInfo#p_pet.pet_id,PetInfo#p_pet.role_id,
                                    ?BUFF_INTERVAL_EFFECT_REDUCE_HP, EffectValue, BuffDetail#p_buf.buff_type,
                                    ActorBuff#p_actor_buf.from_actor_id,
                                    ActorBuff#p_actor_buf.from_actor_type),
    mod_pet_effect:reduce_hp(EffectValue, PetInfo, SrcActorID, SrcActorType).


%%中毒掉血
poisoning(PetInfo, ActorBuff, BuffDetail, SrcActorID, SrcActorType) ->

    case BuffDetail#p_buf.absolute_or_rate of 
        ?TYPE_ABSOLUTE -> 
            EffectValue = BuffDetail#p_buf.value; 
        ?TYPE_PERCENT -> 
            EffectValue = round(PetInfo#p_pet.max_hp*BuffDetail#p_buf.value / 10000)
    end,

    broad_cast_buff_interval_effect(PetInfo#p_pet.pet_id,PetInfo#p_pet.role_id,
                                    ?BUFF_INTERVAL_EFFECT_REDUCE_HP, EffectValue, BuffDetail#p_buf.buff_type,
                                    ActorBuff#p_actor_buf.from_actor_id,
                                    ActorBuff#p_actor_buf.from_actor_type),
    mod_pet_effect:reduce_hp(EffectValue, PetInfo, SrcActorID, SrcActorType).


%%=============================================================
%%=============LOCAL FUNCTION===================================
%%==============================================================

setup_buf_timer(BuffType, BuffFunc, BuffDetail, Args) ->
    #p_buf{last_type=LastType, last_value=LastTime, last_interval=LastInterval} = BuffDetail,
    EndTime = common_tool:now() + LastTime,
    ?DEBUG("setup_buf_timer, lasttime: ~w, last_interval: ~w", [LastTime, LastInterval]),

    [ActorBuf|_] = Args,
    PetID = ActorBuf#p_actor_buf.actor_id,

    case LastType of

        %%如果是每个ticket都掉血的buff
        ?BUFF_LAST_TYPE_REAL_INTERVAL_TIME ->
            put({buff, BuffType}, EndTime),
            TimerRef = erlang:send_after(LastInterval*1000, self(), {mod_map_pet, {buff_loop, PetID, ?MODULE, BuffFunc, Args, LastTime, LastInterval}});

        ?BUFF_LAST_TYPE_REAL_TIME ->
            put({buff, BuffType}, EndTime),
            TimerRef = erlang:send_after(LastTime*1000, self(), {mod_map_pet, {remove_buff, PetID, pet, [ActorBuf], PetID}});

        ?BUFF_LAST_TYPE_ONLINE_TIME ->
            put({buff, BuffType}, EndTime),
            TimerRef = erlang:send_after(LastTime*1000, self(), {mod_map_pet,{remove_buff, PetID, pet, [ActorBuf], PetID}});

        _ ->
            TimerRef = nil
    end,

    TimerRef.


broad_cast_buff_interval_effect(PetID,RoleID,EffectType,Value,BuffType, SActorID, SActorType) ->
    Effect = #p_buff_effect{effect_type=EffectType, effect_value=Value, buff_type=BuffType},

    Record = #m_fight_buff_effect_toc{
      actor_id=PetID,
      actor_type=?TYPE_PET,
      buff_effect=[Effect],
      src_id=SActorID,
      src_type=SActorType},   
    mgeem_map:do_broadcast_insence_include([{role,RoleID}], ?FIGHT, ?FIGHT_BUFF_EFFECT, Record, mgeem_map:get_state()). 
   
