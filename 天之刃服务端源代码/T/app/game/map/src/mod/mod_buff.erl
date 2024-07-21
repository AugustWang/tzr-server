-module(mod_buff).


-include("mgeem.hrl").


-export([
         add_buff_to_actor/6,
         dispel_actor_fight_buffs/4,
         dispel_actor_debuffs/4,
         add_buff_to_actor2/5
        ]).

-define(BUFF_DISPEL, 101).
-define(BUFF_KIND_FIGHT, 3).

%%===========================API FUNCTION================================

%%给ACTOR添加BUFF，这里只负责转发，不处理实际逻辑
%%没加啥的话就不用处理了
add_buff_to_actor(_SrcActorID, _SrcActorType, [], _DActorID, _DActorType, _DActorAttr) ->
    ok;

add_buff_to_actor(SrcActorID, SrcActorType, AddBuffs, DActorID, DActorType, DActorAttr) when is_list(AddBuffs) ->

    random:seed(now()),
    
    %%抗性过滤
    AddBuffs2 =
        lists:foldl(
          fun(Buff, Acc) ->
                  case if_actor_resist(Buff, DActorAttr) of
                      true ->
                          Acc;
                      
                      false ->
                          [Buff|Acc]
                  end
          end, [], AddBuffs),
    
    add_buff_to_actor2(SrcActorID, SrcActorType, AddBuffs2, DActorID, DActorType);

add_buff_to_actor(SrcActorID, SrcActorType, AddBuffs, DActorID, DActorType, DActorAttr) ->
    add_buff_to_actor(SrcActorID, SrcActorType, [AddBuffs], DActorID, DActorType, DActorAttr).

add_buff_to_actor2(SrcActorID, SrcActorType, AddBuffs, DActorID, monster) ->
    self() ! {mod_map_monster,{add_buff, SrcActorID, SrcActorType, AddBuffs, DActorID}};
add_buff_to_actor2(SrcActorID, SrcActorType, AddBuffs, DActorID, server_npc) ->
    self() ! {mod_server_npc,{add_buff, SrcActorID, SrcActorType, AddBuffs, DActorID}};
add_buff_to_actor2(SrcActorID, SrcActorType, AddBuffs, DActorID, ybc) ->
    mod_map_ybc:handle({add_buff,SrcActorID, SrcActorType, AddBuffs, DActorID},mgeem_map:get_state());
add_buff_to_actor2(SrcActorID, SrcActorType, AddBuffs, DActorID, pet) ->
    mod_map_pet:handle({add_buff,SrcActorID, SrcActorType, AddBuffs, DActorID},mgeem_map:get_state());
  
add_buff_to_actor2(SrcActorID, SrcActorType, AddBuffs, DActorID, role) ->
    %% 32 是击晕效果，见 config/buff_type.config，非常恶心的代码！！先这样实现吧
    case lists:keymember(32, #p_buf.buff_type, AddBuffs) of
        true ->
            hook_map_role:role_been_dizzy(DActorID, SrcActorID, SrcActorType);
        false ->
            case lists:keymember(85, #p_buf.buff_type, AddBuffs) of
                true ->
                    hook_map_role:role_been_dizzy(DActorID, SrcActorID, SrcActorType);
                false ->
                    ignore
            end
    end,
    
    mod_map_role:handle({add_buff, DActorID, SrcActorID, SrcActorType, AddBuffs}, mgeem_map:get_state()).

dispel_actor_fight_buffs(SrcActorID, SrcActorType, DActorID, role) ->
    mod_map_role:handle({remove_buff, DActorID, SrcActorID, SrcActorType, 0}, mgeem_map:get_state());

dispel_actor_fight_buffs(SrcActorID, SrcActorType, DActorID, monster) ->
    self() ! {mod_map_monster,{remove_buff, SrcActorID, SrcActorType, 0, DActorID}};
dispel_actor_fight_buffs(SrcActorID, SrcActorType, DActorID, server_npc) ->
    self() ! {mod_server_npc,{remove_buff, SrcActorID, SrcActorType, 0, DActorID}};
dispel_actor_fight_buffs(SrcActorID, SrcActorType, DActorID, ybc) ->
    mod_map_ybc:handle({remove_buff, SrcActorID, SrcActorType, 0, DActorID},mgeem_map:get_state());
dispel_actor_fight_buffs(SrcActorID, SrcActorType, DActorID, pet) ->
    mod_map_pet:handle({remove_buff, SrcActorID, SrcActorType, 0, DActorID},mgeem_map:get_state()).

dispel_actor_debuffs(SrcActorID, SrcActorType, DActorID, role) ->
      mod_map_role:handle({remove_buff, DActorID, SrcActorID, SrcActorType, -1}, mgeem_map:get_state());
dispel_actor_debuffs(_, _, _, _) ->
     ignore.

%%===========================LOCAL FUNCTION================================

if_actor_resist(BuffDetail, ActorAttr) ->

    %%获取actor各种抗性。。。
    #actor_fight_attr{poisoning_resist=PoisonResist, 
                      dizzy_resist=DizzyResist, 
                      freeze_resist=FreezeResist
                     } = ActorAttr,

    %%每种抗性针对一种效果
    #p_buf{buff_id=BuffID, buff_type=BuffType} = BuffDetail,

    %%如果是这三个BUFF的话就不用考虑抗性了，前面已经做了处理
    case BuffID =:= 10515 orelse BuffID =:= 10516 orelse BuffID =:= 10517 of
        true ->
            false;

        _ ->
            {ok, Func} = mod_skill_manager:get_buff_func_by_type(BuffType),  
            case Func of
                poisoning ->
                    if_active(PoisonResist);
                dizzy ->
                    if_active(DizzyResist);
                freeze ->
                    if_active(FreezeResist);
                _ ->
                    false
            end
    end.

if_active(Value) ->
    Rate = random:uniform(10000),
    Rate =< Value.
