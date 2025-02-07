%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com(C) 2010, 
%%% @doc
%%% Server NPC 模块
%%% 只在地图进程中使用
%%% @end
%%% Created : 17 Nov 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_server_npc).

-include("mgeem.hrl").

-export([
         attack_server_npc/2,
         get_server_npc_state/1,
         set_server_npc_state/2,
         get_server_npc_id_list/0,  
         init_server_npc_id_list/0, 
         set_next_work/3,
         set_next_work/4,
         update_next_work/3,
         update_next_work/4,
         init/1,
         reduce_hp/4,
         do_server_npc_recover/1,
         delete_role_from_server_npc_enemy_list/2,
         update_server_npc_mapinfo/1,
         server_npc_attr_change/3,
         init_map_server_npc/4,
         init_map_server_npc/2,
         delete_server_npc/1,
         server_npc_transfer/4,
         get_map_server_npc_data/2,
         dirty_get_server_npc_persistent_info/1,
         handle/2,
         loop/0,
         work/0,
         check_enemy_can_attack/2
        ]).


-define(server_npc_id_list,server_npc_id_list).

set_next_work(ServerNpcID,AddTick,Msg) ->
    Now = common_tool:now2(),
    State = get_server_npc_state(ServerNpcID),
    LastWorkTick =  State#server_npc_state.next_work_tick,
    case Now - LastWorkTick < ?MIN_MONSTER_WORK_TICK of
        true ->
            NewTick = LastWorkTick + AddTick;
        false ->
            NewTick = Now + AddTick
    end,
    set_server_npc_state(ServerNpcID,State#server_npc_state{next_work_tick = NewTick,next_work_truple = Msg}).


set_next_work(ServerNpcID,AddTick,Msg,State) ->
    Now = common_tool:now2(),
    LastWorkTick = State#server_npc_state.next_work_tick,
    case Now - LastWorkTick < ?MIN_MONSTER_WORK_TICK of
        true ->
            NewTick = LastWorkTick + AddTick;
        false ->
            NewTick = Now + AddTick
    end,
    set_server_npc_state(ServerNpcID,State#server_npc_state{next_work_tick = NewTick,next_work_truple = Msg}).

update_next_work(ServerNpcID,NewTick,Msg) ->
    State = get_server_npc_state(ServerNpcID),
    set_server_npc_state(ServerNpcID,State#server_npc_state{next_work_tick = NewTick,next_work_truple = Msg}).


update_next_work(ServerNpcID,NewTick,Msg,State) ->
    set_server_npc_state(ServerNpcID,State#server_npc_state{next_work_tick = NewTick,next_work_truple = Msg}).


set_server_npc_state(ServerNpcID,State) ->
    put({server_npc_state,ServerNpcID},State).

get_server_npc_state(ServerNpcID) ->
    get({server_npc_state,ServerNpcID}).

get_server_npc_id_list() ->
    erlang:get(?server_npc_id_list).

init_server_npc_id_list() ->
    erlang:put(?server_npc_id_list,[]).


%% ServerNpcList结构为[p_server_npc,..]
init_map_server_npc(MapProcessName, MapId, ServerNpcList, CreateType) ->
    lists:foreach(
      fun(ServerNpcInfo) ->
              ServerNpcParam = #r_server_npc_param{
                                                   server_npc = ServerNpcInfo, 
                                                   create_type = CreateType, 
                                                   map_id = MapId, map_name = MapProcessName, 
                                                   state = ?FIRST_BORN_STATE},
              init(ServerNpcParam)
      end,ServerNpcList),
    ?DEBUG("~ts",["初始化Server NPC 数据完成"]),
    ok.


%%开启地图时出生该地图玩家召唤出的NPC和默认的设施和战斗NPC
init_map_server_npc(MapId,MapProcessName) ->
     init_persistent_server_npc(MapProcessName,MapId),
     init_server_npc(MapProcessName,MapId,?SERVER_NPC_TYPE_UNMOVE),
     init_server_npc(MapProcessName,MapId,?SERVER_NPC_TYPE_FIGHT).


%%开启地图时出生该地图默认的某种NPC
init_server_npc(MapProcessName,MapID,NpcType) ->
    case get_map_server_npc_data(MapID,NpcType) of
        [] ->
            ignore;
        ServerNpcList ->
            %% ?ERROR_MSG("############# mapid=~w  ~w",[MapID, ServerNpcList]),
            init_map_server_npc(MapProcessName, MapID, ServerNpcList, ?SERVER_NPC_CREATE_TYPE_NORMAL)
    end.



%%重新启动地图的时候重新召唤当前地图之前召唤出来还未死亡的召唤的NPC
init_persistent_server_npc(_MapName,_MapID) ->
    ok.

%% 添加Server NPC 初始化处理
init(ServerNpcParam) when erlang:is_record(ServerNpcParam,r_server_npc_param)->
    #r_server_npc_param{server_npc = ServerNpcInfo, 
                        create_type = CreateType, 
                        map_id = MapID,
                        map_name = MapName,
                        dead_call_back_fun = DeadCallBackFunc , 
                        state = ParamState, 
                        special_data = SpecialData} = ServerNpcParam,
    #p_server_npc{npc_id = ServerNpcId} = ServerNpcInfo,
    case is_server_npc_in_map(ServerNpcId) of
        true ->
            nil;
        false ->
            ServerNpcInfo2 =  ServerNpcInfo#p_server_npc{state = ParamState},
            ServerNpcState = #server_npc_state{
                                               next_work_tick = 0,
                                               special_data = SpecialData,
                                               server_npc_info = ServerNpcInfo2,
                                               map_id = MapID,
                                               mapname = MapName,
                                               create_type = CreateType,
                                               created_time = erlang:now(),
                                               dead_call_back_fun = DeadCallBackFunc
                                              },
            erlang:put(?server_npc_id_list,[ServerNpcId|get_server_npc_id_list()]),
            case ServerNpcInfo#p_server_npc.npc_type of
                ?SERVER_NPC_TYPE_VWF ->
                    set_next_work(ServerNpcId,?INFINITY_TICK,loop,ServerNpcState);
                _ ->
                    set_next_work(ServerNpcId,1000,loop,ServerNpcState)
            end
    end;
init(ServerNpcParam) ->
    ?ERROR_MSG("~ts,ServerNpcParam=~w",["无法处理此消息",ServerNpcParam]),
    nil.


dirty_get_server_npc_persistent_info({TypeID,Key}) ->
    db:dirty_match_object(?DB_SERVER_NPC_PERSISTENT_INFO,#r_server_npc_persistent_info{type_id=TypeID, key=Key, _='_'});
dirty_get_server_npc_persistent_info(ServerNpcID) ->
    db:dirty_read(?DB_SERVER_NPC_PERSISTENT_INFO, ServerNpcID).


reduce_hp(ServerNpcID, FinalValue, SrcID, SrcType) ->
    State = get_server_npc_state(ServerNpcID),
    attack_server_npc(State,{SrcID,SrcType,FinalValue}).


delete_role_from_server_npc_enemy_list(ServerNpcID,RoleID) ->
    State = get_server_npc_state(ServerNpcID),
    #server_npc_state{server_npc_info = ServerNpcInfo} = State,
    Key = {RoleID,role},
    case get({enemy_level,ServerNpcID,Key}) of
        undefined ->
            NewServerNpcInfo =  ServerNpcInfo;
        ?FIRST_ENEMY_LEVEL ->
            First_Enemies = ServerNpcInfo#p_server_npc.first_enemies,
            NewEnemies = lists:keydelete(Key, 2, First_Enemies),
            NewServerNpcInfo =  ServerNpcInfo#p_server_npc{first_enemies = NewEnemies};
        ?SECOND_ENEMY_LEVEL ->
            Second_Enemies = ServerNpcInfo#p_server_npc.second_enemies,
            NewEnemies = lists:keydelete(Key, 2, Second_Enemies),
            NewServerNpcInfo =  ServerNpcInfo#p_server_npc{second_enemies = NewEnemies};
        ?THIRD_ENEMY_LEVEL ->
            Third_Enemies = ServerNpcInfo#p_server_npc.third_enemies,
            NewEnemies = lists:keydelete(Key, 2, Third_Enemies),
            NewServerNpcInfo =  ServerNpcInfo#p_server_npc{third_enemies = NewEnemies}
    end,
    erase_server_npc_enemy(ServerNpcID,Key),
    set_server_npc_state(ServerNpcID,State#server_npc_state{server_npc_info = NewServerNpcInfo}).


server_npc_attr_change(ServerNpcID, Type, NewValue) ->
    case mod_map_actor:get_actor_mapinfo(ServerNpcID, server_npc) of
    undefined ->
            nil;
    ServerNpcMapInfo ->
            case Type of
                1 ->   
                    %%HP
                    NewServerNpcMapInfo = ServerNpcMapInfo#p_map_server_npc{hp = NewValue};
                _ ->
                    NewServerNpcMapInfo = ServerNpcMapInfo
            end,
            ?DEV("=======~ts====~w====", ["准备写入玩家地图信息", NewServerNpcMapInfo]),
            mod_map_actor:set_actor_mapinfo(ServerNpcID, server_npc, NewServerNpcMapInfo)
    end.       


update_server_npc_mapinfo(ServerNpcInfo) ->
    #p_server_npc{
                buffs = Buffs,
                hp = Hp,
                max_hp = MaxHp,
                mp = Mp,
                max_mp = MaxMp,
                state = ServerNpcState,
                npc_id = ServerNpcID
              } = ServerNpcInfo,
    case mod_map_actor:get_actor_mapinfo(ServerNpcID,server_npc) of
        undefined ->
            nil;
        ServerNpcMapInfo ->
            NewMapInfo = ServerNpcMapInfo#p_map_server_npc{
                           state_buffs = Buffs,
                           hp = Hp,
                           max_hp = MaxHp,
                           mp = Mp,
                           max_mp = MaxMp,
                           state = ServerNpcState},
            ?DEV("=======~ts====~w====", ["准备写入玩家地图信息", NewMapInfo]),
            mod_map_actor:set_actor_mapinfo(ServerNpcID,server_npc, NewMapInfo)
    end.

server_npc_transfer(_ServerNpcPos,DestPos,ServerNpcID,ServerNpcState) ->
    #p_pos{tx=NewTX, ty=NewTY, dir=NewDIR} = DestPos,
    mod_map_actor:update_slice_by_txty(ServerNpcID, server_npc, NewTX, NewTY, NewDIR),
    set_next_work(ServerNpcID,0,loop,ServerNpcState).

%%广播消息给怪物周围玩家
handle({server_npc_broadcast, ServerNpcID, Module, Method, DataRecord}, State) ->
    mgeem_map:do_broadcast_insence_include([{server_npc,ServerNpcID}], Module, Method, DataRecord, State);
handle({timeout,ServerNpcID}, _) ->
     server_npc_delete(ServerNpcID);
handle({buff_loop, ServerNpcID, Module, Method, Args, LastTime, LastInterval}, _) ->
    ServerNpcState =  get_server_npc_state(ServerNpcID),
    case ServerNpcState =:= undefined of
        true ->
            ignore;
        _ ->
            apply(Module, Method, [ServerNpcState|Args]),

            ServerNpcState2 =  get_server_npc_state(ServerNpcID),
            #server_npc_state{server_npc_info=ServerNpcInfo} = ServerNpcState2,
            #p_server_npc{state=State} = ServerNpcInfo,
            [ActorBuff|_] = Args,
            case LastTime - LastInterval =< 0 orelse State =:= ?DEAD_STATE of
                true ->
                    case mod_server_npc_buff:remove_buff(ServerNpcID, server_npc, [ActorBuff], ServerNpcID, ServerNpcState2) of
                        ignore ->
                            ignore;
                        ServerNpcState3 ->
                             set_server_npc_state(ServerNpcID, ServerNpcState3)
                    end;
                _ ->
                    TimerRef = erlang:send_after(LastInterval*1000, self(), 
                                                 {mod_server_npc, {buff_loop, ServerNpcID, Module, Method, Args, LastTime-LastInterval, LastInterval}}),
                    #server_npc_state{buf_timer_ref=BuffTimerRef} = ServerNpcState2,

                    BuffType = ActorBuff#p_actor_buf.buff_type,
                    BuffTimerRef2 = [{BuffType, TimerRef}|lists:keydelete(BuffType, 1, BuffTimerRef)],
                    ServerNpcState3 = ServerNpcState2#server_npc_state{buf_timer_ref=BuffTimerRef2},
                    
                     set_server_npc_state(ServerNpcID, ServerNpcState3)
            end
    end;
handle({add_buff, SrcActorID, SrcActorType, BuffDetail, ServerNpcID}, _State) ->
    ServerNpcState =  get_server_npc_state(ServerNpcID),
    case ServerNpcState of
        undefined ->
            ignore;
        _ ->
            NewServerNpcState = mod_server_npc_buff:add_buff(SrcActorID, SrcActorType, BuffDetail, ServerNpcID, ServerNpcState),
             set_server_npc_state(ServerNpcID, NewServerNpcState)
    end;
handle({remove_buff, SrcActorID, SrcActorType, RemoveList, ServerNpcID}, _State) ->
    ServerNpcState =  get_server_npc_state(ServerNpcID),
    case ServerNpcState of
        undefined ->
            ignore;
        _ ->
            NewServerNpcState = mod_server_npc_buff:remove_buff(SrcActorID, SrcActorType, RemoveList, ServerNpcID, ServerNpcState),
             set_server_npc_state(ServerNpcID,NewServerNpcState)
    end;
handle({remove_buff, SrcActorID, SrcActorType, RemoveList, ServerNpcID, TimerRef}, _State) ->
    ServerNpcState =  get_server_npc_state(ServerNpcID),
    case ServerNpcState of
        undefined ->
            ignore;
        _ ->
            NewServerNpcState = mod_server_npc_buff:remove_buff(SrcActorID, SrcActorType, RemoveList, ServerNpcID, ServerNpcState, TimerRef),
             set_server_npc_state(ServerNpcID,NewServerNpcState)
    end;
handle(Msg,_State) ->
    ?ERROR_MSG("uexcept msg = ~w",[Msg]).

work() ->
    %?ERROR_MSG("npc  eork loop $$$$$$$$$$$$$$$$$",[]),
    Now = common_tool:now2(),
    lists:foreach(
        fun(ServerNpcID) ->
            work(ServerNpcID, Now)
    end, get_server_npc_id_list()).
work(ServerNpcID,NowTime) ->
    State = get_server_npc_state(ServerNpcID),
    %?ERROR_MSG("npc work  state=~w %%%%%%%%%%%%%%%%%%%",[State]),
    case judge_time_to_work(NowTime,State) of
        true ->
            case State#server_npc_state.next_work_truple of
                loop ->
                    server_npc_loop(State);
                _ ->
                    nil
            end;
        false ->
            %%如果本次怪物不进行任何操作，则下个怪物直接继续使用NowTime,减少now函数的调用
            ignore
    end.

judge_time_to_work(NowTime,State) ->
    NextTick = State#server_npc_state.next_work_tick,
    NowTime >= NextTick.

server_npc_loop(State) ->  
                                                %?ERROR_MSG("@@@@@@@@@@@@@@@@,~w",[State]),
    ServerNpcInfo = State#server_npc_state.server_npc_info,          
    CreateType = State#server_npc_state.create_type,
    #p_server_npc{npc_id=NpcID, state=ServerNpcState, move_speed=MoveSpeed, attack_speed=AttackSpeed} = ServerNpcInfo,
    case (AttackSpeed =:= 0 orelse (ServerNpcState =/= ?FIGHT_STATE andalso MoveSpeed =:= 0))
        andalso ServerNpcState =/= ?FIRST_BORN_STATE andalso ServerNpcState =/= ?DEAD_STATE of
        true ->
            set_next_work(NpcID, 1000, loop, State);
        _ ->
            case ServerNpcState of
                ?GUARD_STATE ->
                    guard(State);
                ?FIGHT_STATE ->
                    fight(State);
                ?DEAD_STATE when CreateType =:= ?SERVER_NPC_CREATE_TYPE_NORMAL->
                    reborn(State);
                ?RETURN_STATE ->
                    return(State);
                ?FIRST_BORN_STATE ->
                    reborn(State);
                _ ->
                    server_npc_delete(ServerNpcInfo#p_server_npc.npc_id)
            end
    end.


guard(State) ->
    #server_npc_state{server_npc_info=ServerNpcInfo} = State,
    #p_server_npc{type_id=TypeID} = ServerNpcInfo,
    [BaseInfo] = common_config_dyn:find(server_npc, TypeID),
    NpcType = BaseInfo#p_server_npc_base_info.npc_type,
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    case NpcType of
        ?SERVER_NPC_TYPE_FIGHT ->
            AroundRoles = get_server_npc_9_slice_roles(ServerNpcID),
            GuardRadius = BaseInfo#p_server_npc_base_info.guard_radius,
            case AroundRoles of
                [] ->
                    set_next_work(ServerNpcID,3000,loop,State);
                SliceRoleList ->
                    case find_in_guardradius_enemy_list(SliceRoleList,ServerNpcInfo,GuardRadius) of
                        {[],_} ->
                            set_next_work(ServerNpcID,1000,loop,State);
                        {RoleList,_} ->
                            begin_to_fight(ServerNpcID,State,RoleList)
                    end
            end;
        _ ->
            set_next_work(ServerNpcID,?INFINITY_TICK,loop,State)
    end.


get_server_npc_9_slice_roles(ServerNpcID) ->
    Slices =  mgeem_map:get_9_slice_by_actorid_list([{server_npc,ServerNpcID}],mgeem_map:get_state()),
    mgeem_map:get_all_in_sence_user_by_slice_list(Slices).


%%找出是否有在警戒范围内的其他阵营玩家或者红名玩家
find_in_guardradius_enemy_list(SenceActorList,ServerNpcInfo,GuardRadius) ->
   % ?DEV("~w ~w",[SenceActorList,ServerNpcID]),
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    ServerNpcCountry = ServerNpcInfo#p_server_npc.npc_country,
    ServerNpcPos = mod_map_actor:get_actor_pos(ServerNpcID,server_npc),
    lists:foldr(
      fun(ActorID, {Acc,Acc2}) ->
              case mod_map_actor:get_actor_mapinfo(ActorID,role) of
                  undefined ->
                      {Acc,Acc2};
                  RoleMapInfo ->  
                      case judge_in_distance(ServerNpcPos,RoleMapInfo#p_map_role.pos,GuardRadius) 
                          andalso check_is_enemy(RoleMapInfo,ServerNpcCountry) of
                          false ->
                              {Acc,[ActorID|Acc2]};
                          true ->
                              {[ActorID|Acc],Acc2}
                      end

              end
      end, {[],[]}, SenceActorList).


%%判断是否其他阵营玩家或者红名玩家
check_is_enemy(RoleMapInfo,0) ->
    %%中立NPC只攻击红名玩家
    #p_map_role{pk_point=PKPoint, gray_name=GrayName, state=RoleState} = RoleMapInfo,
    (PKPoint >= 18 orelse GrayName) 
        andalso RoleState =/= ?ROLE_STATE_DEAD 
        andalso RoleState =/= ?ROLE_STATE_STALL;
check_is_enemy(RoleMapInfo, ServerNpcCountry) ->
    #p_map_role{faction_id=FactionID, pk_point=PKPoint, gray_name=GrayName, state=RoleState} = RoleMapInfo,
    (FactionID =/= ServerNpcCountry orelse (not mod_map_role:is_in_waroffaction(FactionID) andalso (PKPoint >= 18 orelse GrayName)))
        andalso RoleState =/= ?ROLE_STATE_STALL andalso RoleState =/= ?ROLE_STATE_DEAD.


fight(State)->
    #server_npc_state{server_npc_info = ServerNpcInfo, 
                      create_type = _CreateType} = State,
    #p_server_npc{type_id=TypeID} = ServerNpcInfo,
    [BaseInfo] = common_config_dyn:find(server_npc, TypeID),
    NpcType = BaseInfo#p_server_npc_base_info.npc_type,
    #p_server_npc{reborn_pos = BornPos,  npc_id = ServerNpcID} = ServerNpcInfo,
    case NpcType of
        ?SERVER_NPC_TYPE_FIGHT ->
            ActivityRadius = BaseInfo#p_server_npc_base_info.activity_radius,
            ServerNpcPos = mod_map_actor:get_actor_pos(ServerNpcID,server_npc),
            case judge_in_distance(ServerNpcPos, BornPos, ActivityRadius) of
                true ->
                    fight2(ServerNpcPos,ServerNpcInfo,State);
                false ->
                    return_born_pos(BornPos,ServerNpcPos,ServerNpcInfo,State)
            end;
        _ ->
            set_next_work(ServerNpcID,5000,loop,State)
    end.

fight2(ServerNpcPos,ServerNpcInfo,State) ->
    case judge_touch_off_boss_ai(ServerNpcInfo,State) of
        [] ->
            fight3(ServerNpcPos,ServerNpcInfo,normal,State#server_npc_state{touched_ai_condition_list = []});
        SkillList ->
            execute_boss_ai(SkillList,ServerNpcInfo,ServerNpcPos,State#server_npc_state{touched_ai_condition_list = []})
    end.

fight3(ServerNpcPos,ServerNpcInfo,Parm,State) ->
    #p_server_npc{type_id=TypeID} = ServerNpcInfo,
    [BaseInfo] = common_config_dyn:find(server_npc, TypeID),
    GuardRadius =  BaseInfo#p_server_npc_base_info.guard_radius,
    AttentionRadius = BaseInfo#p_server_npc_base_info.attention_radius,
    AttackType = BaseInfo#p_server_npc_base_info.attack_type,
    BornPos = ServerNpcInfo#p_server_npc.reborn_pos, 
    NewServerNpcInfo1 = update_enemies_lists(ServerNpcInfo,AttentionRadius),
    #p_server_npc{
                npc_id = ServerNpcID,
                first_enemies = Fir_Enemies,
                second_enemies = Sec_Enemies,
                third_enemies = Thr_Enemies,
                move_speed = MoveSpeed,
                attack_speed = AttackSpeed
              } = NewServerNpcInfo1,
    case get_enemy_role(ServerNpcID,[Fir_Enemies,Sec_Enemies,Thr_Enemies], [], NewServerNpcInfo1) of
        {no, Enemy} ->
            [Thr_Enemies2, Sec_Enemies2, Fir_Enemies2] = Enemy,
            ServerNpcInfoTmp = NewServerNpcInfo1#p_server_npc{first_enemies=Fir_Enemies2,
                                                       second_enemies=Sec_Enemies2,
                                                       third_enemies=Thr_Enemies2},
            case judge_in_distance(BornPos,ServerNpcPos,GuardRadius) of
                false ->
                    return_born_pos(BornPos,ServerNpcPos,ServerNpcInfoTmp,State);
                true ->
                    NewServerNpcInfo2 = ServerNpcInfoTmp#p_server_npc{state = ?GUARD_STATE},
                    set_next_work(ServerNpcID,0,loop,State#server_npc_state{server_npc_info = NewServerNpcInfo2})
            end;
        {Role, _} ->
            {DestActorID,DestActorType} =  Role#p_enemy.actor_key,
            DestActorPos =  mod_map_actor:get_actor_pos(DestActorID,DestActorType),
            Now = common_tool:now(),
            case Parm of
                transfer ->
                    server_npc_transfer(ServerNpcPos,DestActorPos,ServerNpcID,
                                                     State#server_npc_state{server_npc_info = NewServerNpcInfo1,last_attack_time = Now});
                normal ->
                    case AttackType of
                        ?ACTOR_ATTACK_TYPE_PHY ->
                            SkillID = 1,
                            AttAckDis = 1;
                        ?ACTOR_ATTACK_TYPE_PHY_FAR ->
                            SkillID = 2,
                            AttAckDis = 10;
                        ?ACTOR_ATTACK_TYPE_MAGIC ->
                            SkillID = 3,
                            AttAckDis = 1;
                        ?ACTOR_ATTACK_TYPE_MAGIC_FAR ->
                            SkillID = 4,
                            AttAckDis = 10
                    end,
                    SkillLevel = 1,
                    case judge_in_distance(ServerNpcPos, DestActorPos, AttAckDis) of
                        true ->
                            attack_enemy(State#server_npc_state{server_npc_info = NewServerNpcInfo1,last_attack_time = Now}, 
                                        ServerNpcID, DestActorID,DestActorType, AttackSpeed,{SkillID,SkillLevel});
                        false ->
                            case MoveSpeed =:= 0 of
                                true ->
                                    set_next_work(ServerNpcID, 1000, loop, State#server_npc_state{server_npc_info = NewServerNpcInfo1});
                                _ ->
                                    do_start_walk(ServerNpcPos,DestActorPos,ServerNpcID,MoveSpeed,State#server_npc_state{server_npc_info = NewServerNpcInfo1})
                            end
                    end;
                {SkillID,SkillLevel,ResetAttackTime} ->
                    case ResetAttackTime of
                        true -> 
                            attack_enemy(State#server_npc_state{server_npc_info = NewServerNpcInfo1,last_attack_time = Now}, 
                                        ServerNpcID, DestActorID,DestActorType, AttackSpeed,{SkillID,SkillLevel});
                        false ->
                            ?DEBUG("~w",[Now]),
                            NewLastAttackTime = State#server_npc_state.last_attack_time - 1,
                            attack_enemy(State#server_npc_state{server_npc_info = NewServerNpcInfo1,last_attack_time = NewLastAttackTime}, 
                                        ServerNpcID, DestActorID,DestActorType, AttackSpeed,{SkillID,SkillLevel})
                    end
            end
    end.


judge_touch_off_boss_ai(_ServerNpcInfo,State) ->
    AIInfo = State#server_npc_state.ai_info,
    case AIInfo of
       undefined ->
            [];
        _ ->
            ConditionList = AIInfo#p_boss_ai_plan.conditions,
            lists:foldr(
              fun(Condition,Acc) ->
                      ConditionID = Condition#p_boss_ai_condition.condition_id,
                      case ConditionID of
                          1 ->             %%血量上限少于XX时出发条件
                              TouchedAiConditionList = State#server_npc_state.touched_ai_condition_list,
                              case lists:keyfind(1,2,TouchedAiConditionList) of
                                  false ->
                                      Acc;
                                  _ ->
                                      ?DEV("hp lower than half   ~w",[TouchedAiConditionList]),
                                      judge_touch_off_boss_ai2(Acc,Condition)
                              end;
                          2 ->             %%X秒内无法进行正常攻击
                              case State#server_npc_state.last_attack_time of
                                  undefined ->
                                      Acc;
                                  LastAttackTime ->
                                      Now = common_tool:now(),
                                      {TimeInterval} =  Condition#p_boss_ai_condition.parm,
                                      ?DEV("now =~w,  lastattacktime=~w, interval=~w",[Now,LastAttackTime,TimeInterval]),
                                      case Now - LastAttackTime >= TimeInterval  andalso Now - LastAttackTime - TimeInterval =< 1 of
                                          true ->
                                              judge_touch_off_boss_ai2(Acc,Condition);
                                          false ->
                                              Acc
                                      end
                              end;
                          3 ->             %%寻路异常
                              LastEnemyPos = State#server_npc_state.last_enemy_pos,
                              WalkPath =  State#server_npc_state.walk_path,
                              case WalkPath =:= [] andalso LastEnemyPos =/= undefined of
                                  true ->
                                      judge_touch_off_boss_ai2(Acc,Condition);
                                  false ->
                                      Acc
                              end;
                          _ ->
                              Acc
                      end
              end,[],ConditionList)
    end.
  

judge_touch_off_boss_ai2(Acc,Condition) ->
    Rate = Condition#p_boss_ai_condition.rate,
    Rand = common_tool:random(1,10000),
    case Rand =< Rate of
        true ->
            Skills = Condition#p_boss_ai_condition.skills,
            TotalWeight = Condition#p_boss_ai_condition.total_weight,
            Rand2 = common_tool:random(1,TotalWeight),
            Ret = lists:foldr(
                    fun(Skill,{Flag,Acc2}) ->
                            case Flag =:= undefined of
                                true ->
                                    Weight = Skill#p_boss_ai_skill.weight,
                                    NewWeight = Acc2+Weight,
                                    case NewWeight >= Rand2 of
                                        true ->
                                            #p_boss_ai_skill{skill_id = SkillID,skill_level = SkillLevel,
                                                             parm = Parm,reset_attacktime = ResetAttackTime} = Skill,
                                            {{SkillID,SkillLevel,Parm,ResetAttackTime},NewWeight};
                                        false ->
                                            {Flag,NewWeight}
                                    end;
                                false ->
                                    {Flag,Acc2}
                            end
                    end,{undefined,0},Skills),
            case Ret of
                {undefined,_} ->
                    Acc;
                {SkillInfo,_} ->
                    lists:append(Acc,[SkillInfo])
            end;
        false ->
            Acc
    end.

execute_boss_ai([],_,_,State) ->
    State;
execute_boss_ai([SkillInfo|_NewSkillList],ServerNpcInfo,ServerNpcPos,State) ->
    {SkillID,SkillLevel,_Parm,ResetAttackTime} = SkillInfo,
    ?DEBUG("execute_boss_ai ~w",[SkillInfo]),
    case SkillID of
        ?SKILL_TRANSFER ->
            fight3(ServerNpcPos,ServerNpcInfo,transfer,State);
        _ ->
            fight3(ServerNpcPos,ServerNpcInfo,{SkillID,SkillLevel,ResetAttackTime},State)
    end.

    

reborn(State)->
    #server_npc_state{       
        deadtime = DeadTime,
        server_npc_info = ServerNpcInfo} = State,
    #p_server_npc{type_id=TypeID} = ServerNpcInfo,
    [BaseInfo] = common_config_dyn:find(server_npc, TypeID),
    case judge_can_reborn(BaseInfo,ServerNpcInfo,DeadTime) of
        true ->
            reborn_server_npc(State);
        false ->
            nil 
    end.


%%判断怪物能否出生
judge_can_reborn(BaseInfo,ServerNpcInfo,DeadTime) ->
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    RefreshInfo = BaseInfo#p_server_npc_base_info.refresh,
    RefreshType = RefreshInfo#p_refresh_info.refresh_type,
    case RefreshType of
        ?REFRESH_BY_INTERVAL ->
            Interval = RefreshInfo#p_refresh_info.refresh_interval,
            Now = common_tool:now(),
            ?DEBUG("judge_can_reborn ~w ~w ~w ~w ",[Now,DeadTime,Interval,ServerNpcID]),
            case DeadTime of
                undefined ->
                    true;
                _ ->
                    case Now - DeadTime >= Interval of
                        true ->
                            true;
                        false ->
                            set_next_work(ServerNpcID,(Interval-Now+DeadTime)*1000,loop),
                            false
                    end
            end;
       ?REFRESH_BY_TIMEBUCKET ->
            case judge_in_timebucket(BaseInfo,ServerNpcInfo,DeadTime,RefreshInfo) of
                true ->
                    true;
                false ->
                    set_next_work(ServerNpcID,5000,loop),
                    false
            end;
        _ ->
            %%TODO judge can reborn with other reborn kind
            set_next_work(ServerNpcID,5000,loop),
            false
    end.

judge_in_timebucket(_BaseInfo,_ServerNpcInfo,DeadTime,RefreshInfo) ->
    Interval = RefreshInfo#p_refresh_info.refresh_interval,
    _RefreshStartYear = RefreshInfo#p_refresh_info.refresh_start_year,
    _RefreshEndYear = RefreshInfo#p_refresh_info.refresh_end_year,
    RefreshStartMonth = RefreshInfo#p_refresh_info.refresh_start_month,
    RefreshEndMonth = RefreshInfo#p_refresh_info.refresh_end_month,
    RefreshStartDay = RefreshInfo#p_refresh_info.refresh_start_day,
    RefreshEndDay = RefreshInfo#p_refresh_info.refresh_end_day,
    RefreshStartWeekDay = RefreshInfo#p_refresh_info.refresh_start_weekday,
    RefreshEndWeekDay = RefreshInfo#p_refresh_info.refresh_end_weekday,
    RefreshStartHour = RefreshInfo#p_refresh_info.refresh_start_hour,
    RefreshEndHour = RefreshInfo#p_refresh_info.refresh_end_hour,
    RefreshStartMinute = RefreshInfo#p_refresh_info.refresh_start_minute,
    RefreshEndMinute = RefreshInfo#p_refresh_info.refresh_end_minute,
    _RefreshStartTime = RefreshInfo#p_refresh_info.active_time,
    _RefreshEndTime = RefreshInfo#p_refresh_info.start_time,
    _ActivTime = RefreshInfo#p_refresh_info.active_time,
    {Year,Month,Day} = erlang:date(),
    {Hour,Minute,_Second}= erlang:time(),
    WeekDay = calendar:day_of_the_week(Year, Month, Day),
    case RefreshStartMonth =< Month andalso RefreshEndMonth >= Month andalso
             RefreshStartDay =< Day andalso RefreshEndDay >= Day andalso
             RefreshStartWeekDay =< WeekDay andalso RefreshEndWeekDay >= WeekDay andalso
             RefreshStartHour =< Hour andalso RefreshEndHour >= Hour andalso
             RefreshStartMinute =< Minute andalso RefreshEndMinute >= Minute of
        true ->
            case Interval of
                0 ->
                    DeadTime =:= undefined;
                _ ->
                    Now = common_tool:now(),
                    case DeadTime of
                        undefined ->
                            true;
                        _ ->
                            Now - DeadTime >= Interval
                    end
            end;
        false ->
            false 
    end.


%%怪物出生
reborn_server_npc(State) ->
    ?DEV("reborn begin",[]),
    #server_npc_state{
                   server_npc_info = ServerNpcInfo} = State,
    #p_server_npc{type_id=TypeID} = ServerNpcInfo,
    [BaseInfo] = common_config_dyn:find(server_npc, TypeID),
    
    #p_server_npc_base_info{
                             npc_country = NpcCountry,
                             npc_type = NpcType,
                             npc_name = ServerNpcName,
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
                             magic_anti=MagicAnti,
                             poisoning_resist=PoiResist,
                             dizzy_resist=DizResist,
                             is_undead = IsUndead,
                             freeze_resist=FreResist,
                             equip_score=EquipScore,
                             spec_score_one=SpecScoreOne,
                             spec_score_two=SpecScoreTwo,
                             hit_rate=HitRate} = BaseInfo,
    
    #p_server_npc{map_id = MapID, type_id = Type, npc_id = ServerNpcID, reborn_pos = Pos} = ServerNpcInfo,
    case Pos#p_pos.dir of
        undefined ->
            RandDirPos = Pos#p_pos{dir = random:uniform(8)-1};
        _ ->
            RandDirPos = Pos
    end,
    
    NewServerNpcMapInfo = #p_map_server_npc{
                                            npc_country = NpcCountry,
                                            npc_name = ServerNpcName,
                                            npc_type =  NpcType,  
                                            npc_id = ServerNpcID, 
                                            max_hp = MaxHp, 
                                            max_mp = MaxMp, 
                                            map_id = MapID, 
                                            move_speed = MoveSpeed, 
                                            hp = MaxHp, 
                                            mp = MaxMp, 
                                            pos = RandDirPos,
                                            type_id = Type,
                                            is_undead = IsUndead,
                                            state = ?GUARD_STATE
                                           },
    
    ?DEV("server_npc_reborn ~w",[ServerNpcID]),
    case server_npc_reborn(ServerNpcID, NewServerNpcMapInfo) of
        ok ->
            % ?DEBUG("reborn ok",[]),
            NewServerNpcInfo = 
                ServerNpcInfo#p_server_npc{npc_country = NpcCountry,
                                           npc_name = ServerNpcName,
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
                                           hp = MaxHp,
                                           mp = MaxMp,
                                           max_hp = MaxHp,
                                           max_mp = MaxMp,
                                           phy_anti=PhyAnti,
                                           magic_anti=MagicAnti,
                                           first_enemies = [],
                                           second_enemies = [],
                                           third_enemies = [],
                                           buffs = [],
                                           state =?GUARD_STATE,
                                           poisoning_resist=PoiResist,
                                           dizzy_resist=DizResist,
                                           freeze_resist=FreResist,
                                           equip_score=EquipScore,
                                           spec_score_one=SpecScoreOne,
                                           spec_score_two=SpecScoreTwo,
                                           hit_rate=HitRate
                                     },
            NewState = State#server_npc_state{
                                           server_npc_info = NewServerNpcInfo,
                                           buf_timer_ref = [],
                                           walk_path = [],
                                           touched_ai_condition_list = [],
                                           last_enemy_pos = undefined,
                                           last_attack_time = undefined},
            ?DEV(" reborn ok",[]),
            erase_server_npc_enemy(ServerNpcID),
            set_next_work(ServerNpcID,?MIN_MONSTER_WORK_TICK,loop,NewState);
        _ ->
            set_next_work(ServerNpcID,1000,loop,State)
    end.

server_npc_reborn(ServerNpcID, ServerNpcMapInfo) ->
    MapState = mgeem_map:get_state(),
    NewPos = mod_map_actor:get_unref_pos(ServerNpcMapInfo#p_map_server_npc.pos,0,7,4),
    NewServerNpcMapInfo = ServerNpcMapInfo#p_map_server_npc{pos = NewPos},
    mod_map_actor:enter(0, ServerNpcID, ServerNpcID, server_npc, NewServerNpcMapInfo, 0, MapState).


erase_server_npc_enemy(ServerNpcID) ->
    case get({server_npc_enemy,ServerNpcID}) of
        undefined ->
            nil;
        List ->
            lists:foreach(fun(Key)-> erase({enemy_level,ServerNpcID,Key}) end,List)
    end,
    put({server_npc_enemy,ServerNpcID},[]).

erase_server_npc_enemy(ServerNpcID,Key) ->
    case get({server_npc_enemy,ServerNpcID}) of
        undefined ->
            nil;
        List ->
            
            put({server_npc_enemy,ServerNpcID},lists:delete(Key,List))
    end,
    erase({enemy_level,ServerNpcID,Key}).

set_server_npc_enemy(ServerNpcID,Key,Level) ->
    case get({server_npc_enemy,ServerNpcID}) of
        undefined ->
            put({server_npc_enemy,ServerNpcID},[Key]),
            put({enemy_level,ServerNpcID,Key},Level);
        List ->
            case lists:member(Key,List) of
                true ->
                    nil;
                false ->
                    put({server_npc_enemy,ServerNpcID},[Key|List])
            end,
            put({enemy_level,ServerNpcID,Key},Level)
    end.


%%开始攻击
begin_to_fight(ServerNpcID,State,RoleList) ->
    #server_npc_state{server_npc_info = ServerNpcInfo} = State,
    NewServerNpcInfo = init_enemies_lists(ServerNpcInfo,RoleList),
    Now = common_tool:now(),
    NewState = State#server_npc_state{server_npc_info = NewServerNpcInfo,last_attack_time = Now},
    set_next_work(ServerNpcID,?MIN_MONSTER_WORK_TICK,loop,NewState).

%%主动怪检测到周围有玩家时初始化怪物仇恨列表
init_enemies_lists(ServerNpcInfo,RoleList) ->
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    NewEnemies =
        lists:foldl(
          fun(RoleID,Third_Enemies) -> 
                  Enemy = #p_enemy{
                                           actor_key = {RoleID,role},
                                           total_hurt = 0,
                                           last_att_time = common_tool:now()
                                          },
                  set_server_npc_enemy(ServerNpcID, RoleID, ?THIRD_ENEMY_LEVEL),
                  [Enemy|Third_Enemies]
          end, [], RoleList),
    ServerNpcInfo#p_server_npc{third_enemies = NewEnemies,state = ?FIGHT_STATE}.



%%跟新怪物仇恨列表
update_enemies_lists(ServerNpcInfo,AttentionRadius) ->
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    ServerNpcPos = mod_map_actor:get_actor_pos(ServerNpcID,server_npc),  
    ServerNpcInfo2 = update_first_enemy_list(ServerNpcInfo,AttentionRadius,ServerNpcID,ServerNpcPos),
    ServerNpcInfo3 = update_second_enemy_list(ServerNpcInfo2,AttentionRadius,ServerNpcID,ServerNpcPos),
    update_third_enemy_list(ServerNpcInfo3,AttentionRadius,ServerNpcID,ServerNpcPos).


%%跟新1级仇恨列表
update_first_enemy_list(ServerNpcInfo,AttentionRadius,_ServerNpcID,ServerNpcPos) ->
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    First_Enemies = ServerNpcInfo#p_server_npc.first_enemies,
    SecondEnemies =  ServerNpcInfo#p_server_npc.second_enemies,                              
    case First_Enemies of
        [] ->
            ServerNpcInfo;
        _List ->
            {NewFirstList,NewSecondList} = 
                lists:foldl(
                  fun(Info,{Acc,Acc2}) ->
                          #p_enemy{actor_key = Key} = Info,
                          {ActorID,ActorType} = Key,
                          ActorPos = mod_map_actor:get_actor_pos(ActorID,ActorType),
                          case judge_in_distance(ServerNpcPos,ActorPos,AttentionRadius) andalso
                              check_enemy_can_attack(ActorID,ActorType) of
                              false ->
                                  erase_server_npc_enemy(ServerNpcID,Key),
                                  {lists:delete(Info, Acc),Acc2};
                              true ->
                                  Now =  common_tool:now(),
                                  LastAttackTime =  Info#p_enemy.last_att_time,
                                  case Now - LastAttackTime > 10 of
                                      true ->
                                          set_server_npc_enemy(ServerNpcID, Key, ?SECOND_ENEMY_LEVEL),
                                          NewAcc = lists:delete(Info, Acc),
                                          NewAcc2 = [Info|Acc2],
                                          {NewAcc,NewAcc2};
                                      false ->
                                          {Acc,Acc2}
                                  end
                          end
                  end, {First_Enemies,SecondEnemies}, First_Enemies),
            %%TODO sort with total_hurt
            ServerNpcInfo#p_server_npc{first_enemies = NewFirstList,second_enemies = NewSecondList}
    end.
%%跟新2级仇恨列表
update_second_enemy_list(ServerNpcInfo,AttentionRadius,_ServerNpcID,ServerNpcPos)->
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    SecondEnemies =  ServerNpcInfo#p_server_npc.second_enemies,
    case SecondEnemies of
        [] ->
            ServerNpcInfo;
        _List ->
            NewList = 
                lists:foldl(
                  fun(Info,Acc) ->
                          #p_enemy{actor_key = Key} = Info,
                          {ActorID,ActorType} = Key,
                          ActorPos = mod_map_actor:get_actor_pos(ActorID,ActorType),
                          case judge_in_distance(ServerNpcPos,ActorPos,AttentionRadius) andalso
                              check_enemy_can_attack(ActorID,ActorType) of
                              false ->
                                  erase_server_npc_enemy(ServerNpcID,Key),
                                  lists:delete(Info, Acc);
                              true ->
                                  Acc
                          end
                  end, SecondEnemies, SecondEnemies),
            %%TODO sort with total_hurt
            ServerNpcInfo#p_server_npc{second_enemies = NewList}
    end.
%%跟新3级仇恨列表
update_third_enemy_list(ServerNpcInfo,AttentionRadius,_ServerNpcID,ServerNpcPos)->
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    ThirdEnemies =  ServerNpcInfo#p_server_npc.third_enemies,
    case ThirdEnemies of
        [] ->
            ServerNpcInfo;
        _List ->
            NewList = 
                lists:foldl(
                  fun(Info,Acc) ->
                          #p_enemy{actor_key = Key} = Info,
                          {ActorID,ActorType} = Key,
                          ActorPos = mod_map_actor:get_actor_pos(ActorID,ActorType),
                          case judge_in_distance(ServerNpcPos,ActorPos,AttentionRadius) andalso
                              check_enemy_can_attack(ActorID,ActorType) of
                              false ->
                                  erase_server_npc_enemy(ServerNpcID,Key),
                                  lists:delete(Info, Acc);
                              true ->
                                  Acc
                          end
                  end, ThirdEnemies, ThirdEnemies),
            %%TODO sort with total_hurt
            ServerNpcInfo#p_server_npc{third_enemies = NewList}
    end.


%%被攻击时刷新仇恨列表
addto_enemies_lists(ServerNpcInfo,Key,ReduceHP) ->
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    ?DEV("addto_enemies_lists",[]),
    case get({enemy_level,ServerNpcID,Key}) of
        undefined ->
            addto_enemylist(Key,ReduceHP,ServerNpcInfo);
        ?FIRST_ENEMY_LEVEL ->
            addto_enemylist2(Key,ReduceHP,ServerNpcInfo);
        ?SECOND_ENEMY_LEVEL ->
            addto_enemylist3(Key,ReduceHP,ServerNpcInfo);
        ?THIRD_ENEMY_LEVEL ->
            addto_enemylist4(Key,ReduceHP,ServerNpcInfo)
    end.  
%%添加到1级仇恨列表
addto_enemylist(Key,ReduceHP,ServerNpcInfo) ->
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    EnemyInfo = #p_enemy{
                                 actor_key = Key,
                                 total_hurt = ReduceHP,
                                 last_att_time =  common_tool:now()},
    FirstEnemies = ServerNpcInfo#p_server_npc.first_enemies,
    NewFirstEnemines = lists:append(FirstEnemies,[EnemyInfo]),
    set_server_npc_enemy(ServerNpcID, Key,?FIRST_ENEMY_LEVEL),
    ServerNpcInfo#p_server_npc{first_enemies = NewFirstEnemines}.
%%跟新1级仇恨列表
addto_enemylist2(Key,ReduceHP,ServerNpcInfo) ->
    FirstEnemies = ServerNpcInfo#p_server_npc.first_enemies,
    NewEnemies = 
        case lists:keyfind(Key, 2, FirstEnemies) of
            false ->
                ?INFO_MSG("unexcept! ~w ~w",[FirstEnemies,Key]),
                FirstEnemies;
            EnemyInfo ->
                ?DEV("keyfind ok , ~w",[EnemyInfo]),
                Hurt = EnemyInfo#p_enemy.total_hurt,
                NewEnemyInfo = 
                    EnemyInfo#p_enemy{
                                              total_hurt = ReduceHP + Hurt,
                                              last_att_time = common_tool:now()},
                lists:keyreplace(Key, 2, FirstEnemies, NewEnemyInfo)
        end,
    ServerNpcInfo#p_server_npc{first_enemies = NewEnemies}.
%%从2级仇恨列表添加到1级仇恨列表
addto_enemylist3(Key,ReduceHP,ServerNpcInfo) ->
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    FirstEnemies = ServerNpcInfo#p_server_npc.first_enemies,
    SecondEnemies = ServerNpcInfo#p_server_npc.second_enemies,
    case lists:keyfind(Key, 2,SecondEnemies) of
        false ->
            ?INFO_MSG("unexcept!~w ~w",[SecondEnemies,Key]),
            NewFirstEnemines = FirstEnemies;
        EnemyInfo ->
            ?DEV("keyfind ok , ~w",[EnemyInfo]),
            Hurt = EnemyInfo#p_enemy.total_hurt,
            NewEnemyInfo = EnemyInfo#p_enemy{total_hurt = ReduceHP + Hurt,last_att_time = common_tool:now()},           
            NewFirstEnemines = lists:append(FirstEnemies,[NewEnemyInfo])
    end,
    NewSecondEnemies = lists:keydelete(Key, 2, SecondEnemies),
    set_server_npc_enemy(ServerNpcID, Key, ?FIRST_ENEMY_LEVEL),
    ServerNpcInfo#p_server_npc{first_enemies = NewFirstEnemines,second_enemies = NewSecondEnemies}.
%%从3级仇恨列表添加到1级仇恨列表
addto_enemylist4(Key,ReduceHP,ServerNpcInfo) ->
    ServerNpcID = ServerNpcInfo#p_server_npc.npc_id,
    FirstEnemies = ServerNpcInfo#p_server_npc.first_enemies,
    ThirdEnemies = ServerNpcInfo#p_server_npc.third_enemies,
    case lists:keyfind(Key, 2,ThirdEnemies) of
        false ->
            ?INFO_MSG("unexcept! ~w ~w",[ThirdEnemies,Key]),
            NewFirstEnemines = FirstEnemies;
        EnemyInfo ->
            ?DEV("keyfind ok , ~w",[EnemyInfo]),
            Hurt = EnemyInfo#p_enemy.total_hurt,
            NewEnemyInfo = EnemyInfo#p_enemy{total_hurt = ReduceHP + Hurt,last_att_time = common_tool:now()},
            NewFirstEnemines = lists:append(FirstEnemies,[NewEnemyInfo])
    end,
    NewThirdEnemies = lists:keydelete(Key, 2, ThirdEnemies),
    set_server_npc_enemy(ServerNpcID, Key, ?FIRST_ENEMY_LEVEL),
    ServerNpcInfo#p_server_npc{first_enemies = NewFirstEnemines,third_enemies = NewThirdEnemies}.


%%获取一个仇恨列表里的攻击目标
get_enemy_role(_ServerNpcID,[], Acc, _ServerNpcInfo) ->
    {no, Acc};
get_enemy_role(ServerNpcID,[Enemies|T], Acc, ServerNpcInfo) ->
    case Enemies of
        [] ->
            get_enemy_role(ServerNpcID,T, [[]|Acc], ServerNpcInfo);
        List ->
            [Role|_] = List,
            {Role, Acc}
    end.

%% @doc 判断玩家是否可攻击
check_enemy_can_attack(PetID,pet) ->
     case mod_map_actor:get_actor_mapinfo(PetID,pet) of
        undefined ->
            false;
        _ ->
            true
    end;
check_enemy_can_attack(RoleID,role) ->
    case mod_map_actor:get_actor_mapinfo(RoleID,role) of
        undefined ->
            false;
        #p_map_role{state=RoleState, state_buffs=Buffs} ->
            %% 不能攻击死亡、摆摊以及隐身的玩家
            case RoleState =:= ?ROLE_STATE_DEAD 
                orelse RoleState =:= ?ROLE_STATE_STALL 
            of
                true ->
                    false;
                _ ->
                    lists:foldl(
                      fun(ActorBuff, Acc) ->
                              BuffType = ActorBuff#p_actor_buf.buff_type,

                              %%隐身
                              case BuffType =:= 36 of
                                  true ->
                                      false;
                                  _ ->
                                      Acc
                              end
                      end, true, Buffs)
            end
    end.

%%npc攻击宠物
attack_enemy(State,ServerNpcID,_PetID,pet,AttackSpeed,{_SkillID,_SkillLevel}) ->
    set_next_work(ServerNpcID,round(1360000/AttackSpeed), loop,State#server_npc_state{walk_path = []});
%%npc攻击玩家
attack_enemy(State,ServerNpcID,RoleID,role,AttackSpeed,{SkillID,SkillLevel}) ->
    DataIn = {RoleID,{SkillID,SkillLevel},role},  
    self() ! {mod_fight,{server_npc_attack, ?FIGHT, ?FIGHT_ATTACK, DataIn, ServerNpcID}},
    set_next_work(ServerNpcID,round(1360000/AttackSpeed), loop,State#server_npc_state{walk_path = []}).


%%宠物攻击NPC的时候当成是玩家在攻击NPC
attack_server_npc(State,{PetID,pet,ReduceHP}) ->
    case mod_map_actor:get_actor_mapinfo(PetID,pet) of
        undefined ->
            ignore;
        PetMapInfo ->
            RoleID = PetMapInfo#p_map_pet.role_id,
            attack_server_npc(State,{RoleID,role,ReduceHP})
    end;
%%玩家攻击NPC
attack_server_npc(State,{RoleID,role,ReduceHP}) ->
    #server_npc_state{
                   ai_info = AIInfo,
                   last_attack_time = LastAttackTime,
                   touched_ai_condition_list = AiConditionList,
                   server_npc_info = ServerNpcInfo
                  } = State,
    #p_server_npc{
               state = ServerNpcState,
               npc_id = ServerNpcID,
               hp = HP
              } = ServerNpcInfo,
    %% 灰名
    catch hook_map_server_npc:be_attacked(ServerNpcID, RoleID, role),
    case HP =< 0 orelse ServerNpcState =:= ?DEAD_STATE of
        false ->
            NewHp = HP - ReduceHP,
            ServerNpcInfo2 = addto_enemies_lists(ServerNpcInfo,{RoleID,role},ReduceHP),
            ?DEV("~w ~w",[AiConditionList,AIInfo]),
            case AIInfo of
                undefined ->
                    NewAiCondition = AiConditionList;
                _ ->
                    ConditionList = AIInfo#p_boss_ai_plan.conditions,
                    Index = #p_boss_ai_condition.condition_id,
                    case lists:keyfind(1,Index,ConditionList) of
                        false ->
                            NewAiCondition = AiConditionList;
                        Condition ->
                            MaxHP = ServerNpcInfo#p_server_npc.max_hp,
                            {Percent} =  Condition#p_boss_ai_condition.parm,
                            TouchHP = MaxHP*Percent/10000,
                            case NewHp < TouchHP andalso HP >= TouchHP of
                                true ->
                                    NewAiCondition = [{condition,1}|AiConditionList];
                                false ->
                                    NewAiCondition = AiConditionList
                            end
                    end
            end,
            case NewHp =< 0 of
                true ->
                    server_npc_attr_change(ServerNpcID,?BLOOD,0),
                    
                    ServerNpcInfo3 = ServerNpcInfo2#p_server_npc{state= ?DEAD_STATE},
                    server_npc_dead(RoleID, State#server_npc_state{server_npc_info = ServerNpcInfo3});
                false ->
                    mod_server_npc:server_npc_attr_change(ServerNpcID,?BLOOD,NewHp),
                    case ServerNpcState of
                        ?RETURN_STATE ->
                            NewServerNpcState = ?RETURN_STATE,
                            NextWorkTick = State#server_npc_state.next_work_tick;
                        ?GUARD_STATE ->
                            NewServerNpcState = ?FIGHT_STATE,
                            NextWorkTick = common_tool:now2() + 200;
                        ?PATROL_STATE ->
                            NewServerNpcState = ?FIGHT_STATE,
                            NextWorkTick = common_tool:now2() + 200;
                        _ ->
                            NewServerNpcState = ?FIGHT_STATE,
                            NextWorkTick = State#server_npc_state.next_work_tick
                    end,
                    ServerNpcInfo3 = ServerNpcInfo2#p_server_npc{hp = NewHp, state = NewServerNpcState},
                    case LastAttackTime of
                        undefined ->
                            NewLastAttackTime = common_tool:now();
                        _ ->
                            NewLastAttackTime = LastAttackTime
                    end,
                    NewState = State#server_npc_state{server_npc_info = ServerNpcInfo3, 
                                                   touched_ai_condition_list = NewAiCondition, 
                                                   last_attack_time = NewLastAttackTime},
                    update_next_work(ServerNpcID,NextWorkTick,loop,NewState)
            end;
        true ->
            ?DEV("server_npc already dead!",[])
    end;
attack_server_npc(_,{_,_,_}) ->
    ignore.


%%怪物死亡
server_npc_dead(RoleID, State) ->
    ?DEV("server_npc_dead",[]),
    #server_npc_state{
                   server_npc_info = ServerNpcInfo,
                   buf_timer_ref = RefList,
                   dead_call_back_fun=_PostDeadFun,
                   create_type=CreateType
                  } = State,
    #p_server_npc{npc_id = ServerNpcID,max_hp = _MaxHP, type_id = ServerNpcTypeID} = ServerNpcInfo,

    lists:foreach(
      fun({_, Ref}) ->
              erlang:cancel_timer(Ref)
      end,RefList),
    
    DataRecord = #m_server_npc_dead_toc{npc_id = ServerNpcID},
    
    MapState = mgeem_map:get_state(),
    mgeem_map:do_broadcast_insence_include([{server_npc, ServerNpcID}], ?SERVER_NPC, ?SERVER_NPC_DEAD, DataRecord, MapState),
 
    %%国战期间死亡的NPC的处理
    mod_map_actor:do_dead(ServerNpcID, server_npc, MapState),
     case mod_waroffaction:check_in_waroffaction_time() of
         true ->
              catch mod_waroffaction:waroffaction_npc_dead(ServerNpcTypeID,ServerNpcID,RoleID),
              catch mod_waroffaction:add_waroffaction_npc_gongxun(RoleID, ServerNpcTypeID);
         false ->
             ignore
     end,

    NowTime = common_tool:now(),
    case CreateType of
        ?SERVER_NPC_CREATE_TYPE_MANUAL ->
            server_npc_delete(ServerNpcID);
        ?SERVER_NPC_CREATE_TYPE_NORMAL->
            NewState = State#server_npc_state{server_npc_info = ServerNpcInfo,deadtime = NowTime, buf_timer_ref = []},
            mod_map_actor:do_quit(ServerNpcID, server_npc, MapState),
            set_next_work(ServerNpcID, 1000, loop,NewState)
    end.


server_npc_delete(ServerNpcID) ->
    mod_map_actor:do_quit(ServerNpcID, server_npc, mgeem_map:get_state()),
    erlang:put(?server_npc_id_list,lists:delete(ServerNpcID,get_server_npc_id_list())),
    case get({server_npc_enemy,ServerNpcID}) of
        undefined ->
            nil;
        List2 ->
            erase({server_npc_enemy,ServerNpcID}),
            lists:foreach(fun(RoleID) -> erase({enemy_level,ServerNpcID,RoleID}) end,List2)
        end,
    erase({server_npc_state,ServerNpcID}).


%%判断是否在范围内
judge_in_distance(ServerNpcPos, RolePos, Distance) ->
    case ServerNpcPos =:= undefined orelse RolePos =:= undefined of
        false ->
            #p_pos{tx = Tx1, ty = Ty1} = ServerNpcPos,
            #p_pos{tx = Tx2, ty = Ty2} = RolePos,
            X = abs(Tx1 - Tx2),
            Y = abs(Ty1 - Ty2),
            X =< Distance andalso Y =< Distance;
        true ->
            true
    end.



%%NPC走路，和BOSS一样，返回时走直线，否则都是直接高级寻路
do_start_walk(ServerNpcPos,RolePos,ServerNpcID,Speed,State) ->
    #server_npc_state{walk_path=WalkPath, server_npc_info=ServerNpcInfo, last_enemy_pos=LastEnemyPos} = State,
    ServerNpcInfo = State#server_npc_state.server_npc_info,
    ServerNpcState = ServerNpcInfo#p_server_npc.state,
    case ServerNpcState of
        ?RETURN_STATE ->
            do_start_walk2(WalkPath,ServerNpcPos,RolePos,ServerNpcID,Speed,State,normal);
        _ ->
            case RolePos =:= LastEnemyPos of
                true ->
                    do_start_walk2(WalkPath,ServerNpcPos,RolePos,ServerNpcID,Speed,State,boss);
                false ->
                    do_start_walk2([],ServerNpcPos,RolePos,ServerNpcID,Speed,State,boss)
            end
    end.
      


do_start_walk2(WalkPath,ServerNpcPos,RolePos,ServerNpcID,Speed,ServerNpcState,boss) ->
    case WalkPath of
        [] ->
            mod_server_npc_walk:first_level_walk(ServerNpcPos, RolePos, ServerNpcID,Speed, ServerNpcState);
        [WalkPos|NewWalkPath] when is_list(NewWalkPath)->
            mod_server_npc_walk:walk_inpath(ServerNpcPos,WalkPos,NewWalkPath, ServerNpcID, Speed, RolePos, ServerNpcState)   
    end;
do_start_walk2(WalkPath,ServerNpcPos,RolePos,ServerNpcID,Speed,ServerNpcState,_) ->
    case WalkPath of
        [] ->
            mod_server_npc_walk:first_level_walk(ServerNpcPos, RolePos, ServerNpcID,Speed, ServerNpcState);
        [WalkPos|NewWalkPath] ->
            mod_server_npc_walk:walk_inpath(ServerNpcPos,WalkPos,NewWalkPath, ServerNpcID, Speed, RolePos, ServerNpcState)   
    end.


%%怪物返回出生点
return(State)->
    #server_npc_state{server_npc_info = ServerNpcInfo} = State,
    #p_server_npc{reborn_pos = BornPos, npc_id = ServerNpcID, move_speed = MoveSpeed} = ServerNpcInfo,
    ServerNpcPos = mod_map_actor:get_actor_pos(ServerNpcID,server_npc),
    case judge_in_distance(ServerNpcPos,BornPos,1) of
        true ->
            %  MaxHp = ServerNpcInfo#p_server_npc.max_hp,
            NewServerNpcInfo = ServerNpcInfo#p_server_npc{
                                                   % hp = MaxHp, 
                                                   state = ?GUARD_STATE,
                                                   first_enemies = [],
                                                   second_enemies = [],
                                                   third_enemies = []},
            %  mod_server_npc:server_npc_attr_change(ServerNpcID,?BLOOD,MaxHp),
            erase_server_npc_enemy(ServerNpcID),
            NewState = State#server_npc_state{server_npc_info = NewServerNpcInfo,last_attack_time = undefined},
            set_next_work(ServerNpcID,0,loop,NewState);
        false ->
            do_start_walk(ServerNpcPos,BornPos,ServerNpcID,MoveSpeed,State)
    end.


%%怪物返回出生点
return_born_pos(BornPos,ServerNpcPos,ServerNpcInfo,State) ->
    #p_server_npc{
               npc_id = ServerNpcID,
               move_speed = MoveSpeed} = ServerNpcInfo,
    NewServerNpcInfo = ServerNpcInfo#p_server_npc{state = ?RETURN_STATE},
    do_start_walk(ServerNpcPos,BornPos,ServerNpcID,MoveSpeed,State#server_npc_state{server_npc_info = NewServerNpcInfo}).


do_server_npc_recover(ServerNpcID) ->
    case mod_map_actor:get_actor_mapinfo(ServerNpcID, server_npc) of
        undefined ->
            ignore;
        ServerNpcMapInfo ->
            case ServerNpcMapInfo#p_map_server_npc.npc_type =:= ?SERVER_NPC_TYPE_VWF of
                true ->
                    ignore;
                false ->
                    case get_server_npc_state(ServerNpcID) of
                        undefined ->
                            ignore;
                        ServerNpcState ->
                            #p_map_server_npc{hp=HP, mp=MP, max_hp=MaxHP, max_mp=MaxMP} = ServerNpcMapInfo,
                            #server_npc_state{server_npc_info=ServerNpcInfo} = ServerNpcState,
                            #p_server_npc{type_id=TypeID} = ServerNpcInfo,
                            [ServerNpcBaseInfo] = common_config_dyn:find(server_npc, TypeID),
                            #p_server_npc_base_info{blood_resume_speed=HPRecover, magic_resume_speed=MPRecover} = ServerNpcBaseInfo,
                            
                            case HP =:= MaxHP andalso MP =:= MaxMP of
                                true ->
                                    ignore;
                                _ ->
                                    HPRecover2 = mod_map_monster:get_hp_recover(HP, MaxHP, HPRecover),
                                    case HP + HPRecover2 >= MaxHP of
                                        true ->
                                            HP2 = MaxHP;
                                        _ ->
                                            HP2 = HP + HPRecover2
                                    end,
                                    
                                    case MP + MPRecover >= MaxMP of
                                        true ->
                                            MP2 = MaxMP;
                                        _ ->
                                            MP2 = MP + MPRecover
                                    end,
                                    
                                    ServerNpcMapInfo2 = ServerNpcMapInfo#p_map_server_npc{hp=HP2, mp=MP2},
                                    ServerNpcInfo2 = ServerNpcInfo#p_server_npc{hp=HP2, mp=MP2},
                                    ServerNpcState2 = ServerNpcState#server_npc_state{server_npc_info=ServerNpcInfo2},
                                    
                                    set_server_npc_state(ServerNpcID, ServerNpcState2),
                                    mod_map_actor:set_actor_mapinfo(ServerNpcID, server_npc, ServerNpcMapInfo2)
                            end
                    end
            end
    end.





















%% 删除多个Server NPC 
delete_server_npc(ServerNpcIds)
  when erlang:is_list(ServerNpcIds) ->
    case get(server_npc_idlist) of
        undefined ->
            nil;
        List when erlang:is_list(List) ->
            List2 = 
                lists:foldl(fun(ServerNpcId,Acc) ->
                                    mod_map_actor:do_quit(ServerNpcId, server_npc, mgeem_map:get_state()),
                                    lists:delete(ServerNpcId,Acc)
                            end,List,ServerNpcIds),
            put(server_npc_idlist,List2)
    end;
%% 删除一个Server NPC
delete_server_npc(ServerNpcId) ->
    mod_map_actor:do_quit(ServerNpcId, server_npc, mgeem_map:get_state()),
    case get(server_npc_idlist) of
        undefined ->
            nil;
        List when is_list(List) ->
            put(server_npc_idlist,lists:delete(ServerNpcId,List))
    end.
%% 是否已经在地图中
is_server_npc_in_map(ServerNpcId) ->
    case get(server_npc_idlist) of
        undefined ->
            false;
        List when is_list(List) ->
            lists:member(ServerNpcId,List)
    end.

%% 循环处理消息
loop() ->
    work(),
    %% 处理逐鹿天下副本循环消息
    mod_vie_world_fb:do_handle_info({work}),
    ok.


%% 根据地图id获取此地图配置的Server NPC 数据
%% 返回结果为[p_server_npc,..]
get_map_server_npc_data(MapId,NpcType) ->
    MatchHead = #r_server_npc_born{npc_type='$1',map_id='$2', _='_' },
    Guard = [{'=:=', '$1', NpcType},{'=:=', '$2', MapId}],
    Result = ['$_'],
    ?DEBUG("server_npc,~ts,MatchHead=~w,Guard=~w,Result=~w",["查询条件为:",MatchHead,Guard,Result]),
    ServerNpcList = ets:select(?ETS_SERVER_NPC_BORN, [{MatchHead, Guard, Result}]),
    if erlang:length(ServerNpcList) =:= 1 ->
            [ServerNpcBorn] = ServerNpcList,
            get_map_server_npc_data2(MapId,ServerNpcBorn);
       true ->
            []
    end.
    
get_map_server_npc_data2(MapId,ServerNpcBorn) ->         
    #r_server_npc_born{sub_list = SubList} = ServerNpcBorn,
    lists:foldl(fun(SubRecord,Acc) ->
                      #r_server_npc_born_sub{npc_type_id = TypeId,tx = Tx,ty = Ty, dir=Dir} = SubRecord,
                        case common_config_dyn:find(server_npc, TypeId) of
                             [] ->
                                ?DEBUG("~ts",["查询逐鹿天下副本Server NPC基本信息出错"]),
                                Acc;
                            [ServerNpcBaseInfo] ->
                                Pos = #p_pos{tx = Tx,ty = Ty,dir = Dir},
                                PServerNpc = #p_server_npc{
                                  %% 使用怪物的id
                                  npc_id = mod_map_monster:get_max_monster_id_form_process_dict(),
                                  type_id = ServerNpcBaseInfo#p_server_npc_base_info.type_id,
                                  npc_name = ServerNpcBaseInfo#p_server_npc_base_info.npc_name,
                                  npc_type = ServerNpcBaseInfo#p_server_npc_base_info.npc_type,
                                  max_mp= ServerNpcBaseInfo#p_server_npc_base_info.max_mp,
                                  state = ?DEAD_STATE,
                                  max_hp = ServerNpcBaseInfo#p_server_npc_base_info.max_hp,
                                  map_id = MapId,
                                  reborn_pos = Pos,
                                  level= ServerNpcBaseInfo#p_server_npc_base_info.level,
                                  npc_country = ServerNpcBaseInfo#p_server_npc_base_info.npc_country,
                                  is_undead = ServerNpcBaseInfo#p_server_npc_base_info.is_undead,
                                  move_speed = ServerNpcBaseInfo#p_server_npc_base_info.move_speed
                                 },
                                [PServerNpc|Acc]
                        end
                end,[],SubList).
