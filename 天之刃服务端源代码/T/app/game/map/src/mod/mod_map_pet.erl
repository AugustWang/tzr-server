%% Author: liuwei
%% Created: 2011-2-10
%% Description: TODO: Add description to mod_map_pet
-module(mod_map_pet).

%%
%% Include files
%%
-include("mgeem.hrl").
%%
%% Exported Functions
%%
-export([
         init/0,
         handle/2,
         send_role_pet_bag_info/1,
         get_pet_pos_from_owner/1,
         t_get_new_pet/6,
         update_role_pet_slice/4,
         get_role_pet_map_info_list/1,
         get_pet_transfer_info/1,
         role_pet_enter/2,
         role_pet_quit/1,
         get_summoned_pet_info/1,
         loop/1,
         calc_pet_attr/1,
         pet_add_hp/2,
         pet_reduce_hp/4,
         set_pet_pk_mode/2,
         add_pet_exp/3,
         get_pet_buff_final_value/3,
         hook_role_pk_mode_change/2,
         reset_pet_attr/1,
         auto_summon_role_pet/1,
         reduce_role_pet_hp_on_pet_wall/4,
         check_pet_can_relive_owner/1,
         t_deduct_item/2,
         t_add_pet_exp/3,
         t_deduct_silver/3,
         t_common_add_pet_exp/3,
         check_role_has_pet/2,
         t_add_pet_room/1
        ]).

-export([
         test_t_get_new_pet/3,
         test_summon/1,
         test_call_back/1,
         test_throw/1,
         test_info/1,
         test_attr_assign/2,
         test_learn_skill/2,
         test_add_life/1,
         test_add_understanding/2,
         test_refresh_aptitude/1,
         test_change_name/2
        ]).

%%默认宠物背包容量
-define(DEFAULT_PET_BAG_CONTENT,3).
-define(MAX_PET_BAG_CONTENT,5).
-define(DEFAULT_PET_UNDERSTANDING,0).
-define(DEFAULT_PET_LIFE,1000).
-define(DEFAULT_PET_ATTACK_SPEED,1000).

-define(PET_ATTACK_TYPE_PHY,1).
-define(PET_ATTACK_TYPE_MAGIC,2).

-define(PET_LIFE_ATTR_CHANGE,10).
-define(PET_EXP_CHANGE,11).
-define(PET_HP_CHANGE,12).
-define(PET_MAX_HP_CHANGE,13).

%%宠物与主人的位置距离
-define(ROLE_PET_DISTANCE,2).

%%宠物BUFF效果值的计算公式类型
-define(PET_BUFF_FIRST_EXPRESSION,1).
-define(PET_BUFF_SECOND_EXPRESSION,2).
-define(PET_BUFF_THIRD_EXPRESSION,3).
-define(PET_BUFF_FOURTH_EXPRESSION_WITH_PET_HP,4).  %%根据宠物血量加百分比

%%宠物一级属性
-define(ATTR_STR, 1).  %%力量
-define(ATTR_INT, 2).  %%智力
-define(ATTR_DEX, 3).  %%敏捷
-define(ATTR_MEN, 4).  %%精神
-define(ATTR_CON, 5).  %%体质





%%宠物初始资质的随机配置文件
-record(r_pet_section_rate,{section_rate,min,max}).
-record(r_pet_aptitude_config,{carry_level_and_period,max_aptitude,total_rate,section_rates}).
-record(pet_level,{level,next_level_exp,total_exp}).
-record(r_pet_skill,{skill_id,skill_type, expression}).

%%
%% API Functions
%%
%%宠物模块初始化
init() ->
    put(?PET_ID_LIST,[]).

handle({Unique, ?PET, ?PET_SUMMON, DataIn, RoleID, _PID, Line}, State) -> 
    do_summon(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_CALL_BACK, DataIn, RoleID, _PID, Line}, State) -> 
    do_call_back(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_THROW, DataIn, RoleID, _PID, Line}, State) -> 
    do_throw({Unique, DataIn, RoleID, Line}, State);

handle({Unique, ?PET, ?PET_LEARN_SKILL, DataIn, RoleID, _PID, Line}, State) -> 
    do_learn_skill(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_INFO, DataIn, RoleID, _PID, Line}, _State) -> 
    do_info(Unique, DataIn, RoleID, Line);

handle({_Unique, ?PET, ?PET_BAG_INFO, _DataIn, RoleID, _PID, _Line}, _State) -> 
    send_role_pet_bag_info(RoleID);

handle({Unique, ?PET, ?PET_ADD_BAG, DataIn, RoleID, _PID, Line}, State) -> 
    do_add_pet_bag(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_ATTR_ASSIGN, DataIn, RoleID, _PID, Line}, State) -> 
    do_attr_assign(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_ADD_LIFE, DataIn, RoleID, _PID, Line}, State) -> 
    do_add_life(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_REFRESH_APTITUDE, DataIn, RoleID, _PID, Line}, State) -> 
    do_refresh_aptitude(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_ADD_UNDERSTANDING, DataIn, RoleID, _PID, Line}, State) -> 
    do_add_understanding(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_CHANGE_NAME, DataIn, RoleID, _PID, Line}, State) -> 
    do_change_name(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_FEED_INFO, DataIn, RoleID, _PID, Line}, State) -> 
    mod_pet_feed:do_pet_feed_info(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_FEED_BEGIN, DataIn, RoleID, _PID, Line}, State) -> 
    mod_pet_feed:do_pet_feed_begin(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_FEED_COMMIT, DataIn, RoleID, PID, Line}, State) -> 
    mod_pet_feed:do_pet_feed_commit(Unique, DataIn, RoleID, PID, Line, State);

handle({Unique, ?PET, ?PET_FEED_GIVE_UP, DataIn, RoleID, _PID, Line}, State) -> 
    mod_pet_feed:do_pet_feed_give_up(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_FEED_STAR_UP, DataIn, RoleID, _PID, Line}, State) -> 
    mod_pet_feed:do_pet_feed_star_up(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID, Line}, State)->
    mod_pet_training:handle({Unique, DataIn, RoleID, PID, Line, State});

handle({Unique, ?PET, ?PET_GROW_INFO, DataIn, RoleID, _PID, Line}, State) -> 
    mod_pet_grow:do_pet_grow_info(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_GROW_BEGIN, DataIn, RoleID, _PID, Line}, State) -> 
    mod_pet_grow:do_pet_grow_begin(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_GROW_COMMIT, DataIn, RoleID, _PID, Line}, State) -> 
    mod_pet_grow:do_pet_grow_commit(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_GROW_GIVE_UP, DataIn, RoleID, _PID, Line}, State) -> 
    mod_pet_grow:do_pet_grow_give_up(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_ADD_SKILL_GRID, DataIn, RoleID, _PID, Line}, State) -> 
    do_pet_add_skill_grid(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_FORGET_SKILL, DataIn, RoleID, _PID, Line}, State) -> 
    do_pet_forget_skill(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_CHANGE_POS, DataIn, RoleID, _PID, Line}, State) -> 
    do_pet_change_pos(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_REFINING, DataIn, RoleID, _PID, Line}, State) -> 
    do_pet_refining(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_REFINING_EXP, DataIn, RoleID, _PID, Line}, State) -> 
    do_pet_refining_exp(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_EGG_USE, DataIn, RoleID, _PID, Line}, State) -> 
    do_pet_egg_use(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_EGG_REFRESH, DataIn, RoleID, _PID, Line}, State) -> 
    do_pet_egg_refresh(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_EGG_ADOPT, DataIn, RoleID, _PID, Line}, State) -> 
    do_pet_egg_adopt(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_TRICK_LEARN, DataIn, RoleID, _PID, Line}, State) -> 
    do_pet_trick_learn(Unique, DataIn, RoleID, Line, State);

handle({Unique, ?PET, ?PET_TRICK_UPGRADE, DataIn, RoleID, _PID, Line}, State) -> 
    do_pet_trick_upgrade(Unique, DataIn, RoleID, Line, State);

handle({add_exp,RoleID,Exp}, _State) ->
    do_add_exp(RoleID,Exp,true);

handle({quit,RoleID,PetID}, State) ->
    pet_quit(RoleID, PetID,State);


handle({pet_color_goal,RoleID,Color},_State) ->
    common_mod_goal:hook_pet_color_change(RoleID, Color);

handle({buff_loop, PetID, Module, Method, Args, LastTime, LastInterval}, _) ->
    do_buff_loop(PetID, Module, Method, Args, LastTime, LastInterval);

handle({add_buff, SrcActorID, SrcActorType, BuffDetail, PetID}, _State) ->
    do_add_buff(SrcActorID, SrcActorType, BuffDetail, PetID);

handle({remove_buff, SrcActorID, SrcActorType, RemoveList, PetID}, _State) ->
    do_remove_buff(SrcActorID, SrcActorType, RemoveList, PetID);

handle({remove_buff, SrcActorID, SrcActorType, RemoveList, PetID, TimerRef}, _State) ->
     do_remove_buff(SrcActorID, SrcActorType, RemoveList, PetID, TimerRef);

handle(Msg,_State) ->
    ?ERROR_MSG("uexcept msg = ~w",[Msg]).


send_role_pet_bag_info(RoleID) ->
    case db:dirty_read(?DB_ROLE_PET_BAG,RoleID) of
        [] ->
            BagInfo = #p_role_pet_bag{content=?DEFAULT_PET_BAG_CONTENT,role_id=RoleID,pets=[]};
        [Info] ->
            NewPets = [begin {Exp,NextLevelExp}=get_simple_pet_info(RoleID,Pet#p_pet_id_name.pet_id),
                             Pet#p_pet_id_name{exp=Exp,next_level_exp=NextLevelExp} end||Pet<-Info#p_role_pet_bag.pets],
            BagInfo = Info#p_role_pet_bag{pets=NewPets}
    end,
    Record = #m_pet_bag_info_toc{info=BagInfo},
    common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_BAG_INFO, Record),
    {ok,BagInfo}.

get_simple_pet_info(RoleID,PetID)->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        PetID->
            PetInfo = get({?ROLE_PET_INFO,PetID}),
            {PetInfo#p_pet.exp,PetInfo#p_pet.next_level_exp};
        _->
            case db:dirty_read(?DB_PET,PetID) of
                [PetInfo]->
                    {PetInfo#p_pet.exp,PetInfo#p_pet.next_level_exp};
                _->
                    {0,0}
            end
    end.

auto_summon_role_pet(RoleID) ->
    {ok,BagInfo} = send_role_pet_bag_info(RoleID),
    Pets = BagInfo#p_role_pet_bag.pets,
    case lists:keyfind(0, #p_pet_id_name.index, Pets) of
        false ->
            ignore;
        #p_pet_id_name{pet_id=PetID} ->
            case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
                undefined ->
                    case common_misc:get_role_line_by_id(RoleID) of
                        false ->
                            ignore;
                        Line ->
                            self()! {mod_map_pet,{?DEFAULT_UNIQUE, ?PET, ?PET_SUMMON, #m_pet_summon_tos{pet_id=PetID}, RoleID, self(), Line}}
                    end;     
                _ ->
                    ignore
            end
    end.   


%%宠物肉墙帮主人承受伤害
reduce_role_pet_hp_on_pet_wall(RoleID,ReduceHp,SrcActorID, SrcActorType) ->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            ignore;
        PetID ->
            
            pet_reduce_hp(PetID,ReduceHp, SrcActorID, SrcActorType)
    end.


%%检查是否有宠物复活主人的BUFF，有的话自动复活主人
-define(PET_RELIVE_OWNER_BUFF_TYPE,97).
check_pet_can_relive_owner(#p_role_base{role_id=RoleID,buffs=Buffs, max_hp=MaxHp}) ->
    case lists:keyfind(?PET_RELIVE_OWNER_BUFF_TYPE, #p_actor_buf.buff_type, Buffs) of
        false ->
            ignore;
        #p_buf{value=Value} ->
            case get_summoned_pet_info(RoleID) of
                undefined ->
                    ignore;
                {_PetID,_PetInfo} ->
                    Hp = trunc(MaxHp * Value /10000),
                    case Hp > MaxHp of
                        true ->
                            Hp2 = MaxHp;
                        false ->
                            Hp2 = Hp
                    end,
                    Hp2
            end
    end.


%%根据主人的位置和方向确定宠物的位置和方向
get_pet_pos_from_owner(RoleID) ->
    RolePos = mod_map_actor:get_actor_pos(RoleID,role),
    #p_pos{tx=Tx,ty=Ty,dir=Dir} = RolePos,
    Dis = ?ROLE_PET_DISTANCE,
    case Dir of
        0 ->
            #p_pos{tx=Tx+Dis, ty=Ty, dir=Dir};          % pet=new Pt(pt.x + dis, 0, pt.z);
        1 ->
            #p_pos{tx=Tx+Dis, ty=Ty+Dis-2, dir=Dir};      % pet=new Pt(pt.x + dis, 0, pt.z + dis-2);
        2 ->
            #p_pos{tx=Tx, ty=Ty+Dis, dir=Dir};      % pet=new Pt(pt.x, 0, pt.z + dis);
        3 ->
            #p_pos{tx=Tx+1-Dis, ty=Ty-1+Dis, dir=Dir};  % pet=new Pt(pt.x - (dis-1), 0, pt.z + (dis-1));
        4 ->
            #p_pos{tx=Tx-Dis, ty=Ty, dir=Dir};          % pet=new Pt(pt.x - dis, 0, pt.z);
        5 ->
            #p_pos{tx=Tx-Dis, ty=Ty+2-Dis, dir=Dir};  % pet=new Pt(pt.x - dis, 0, pt.z - (dis-2));
        6 ->
            #p_pos{tx=Tx, ty=Ty-Dis, dir=Dir};      % pet=new Pt(pt.x, 0, pt.z - dis);
        7 ->
            #p_pos{tx=Tx+Dis-1, ty=Ty+1-Dis, dir=Dir};  % pet=new Pt(pt.x + (dis-1), 0, pt.z - (dis-1));
        _ ->
            #p_pos{tx=Tx, ty=Ty, dir=Dir}
    end.


t_get_new_pet(RoleID,TypeID,RoleLevel,RoleName,Bind,RoleFaction) ->
    get_new_pet(RoleID,TypeID,RoleLevel,RoleName,Bind,RoleFaction).

%%跟新玩家出战的宠物的slice
update_role_pet_slice(RoleID, TX, TY, DIR) ->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            ignore;
        PetID when is_integer(PetID)->
            mod_map_actor:update_slice_by_txty(PetID, pet, TX, TY, DIR);
        _ ->
            ignore
    end.
     

%%宠物进入地图时设置相应的信息到进程字典中
set_pet_info_in_process(RoleID,PetID,PetInfo) ->
    put({?LAST_REDUCE_LIFE_TICK,PetID},common_tool:now()),
    put({?ROLE_PET_INFO,PetID},PetInfo),
    put({?ROLE_SUMMONED_PET_ID,RoleID},PetID),
    put(?PET_ID_LIST,[PetID|get(?PET_ID_LIST)]),
    put({?PET_BUFF_TIMER_REF,PetID},[]).
    

%%宠物退出地图后清除宠物相应的进程字典里的信息
clear_pet_info_in_process(RoleID,PetID,HP) -> 
    erase({?LAST_REDUCE_LIFE_TICK,PetID}),
    case get({?ROLE_PET_INFO,PetID}) of
        undefined ->
            ignore;
        PetInfo -> 
            remove_pet_buff_add_to_owner(PetInfo),
            erase({?ROLE_PET_INFO,PetID}),
            Fun = fun() -> db:transaction(fun()-> db:write(?DB_PET,PetInfo#p_pet{hp=HP},write) end) end,
            spawn(Fun)
    end,
    erase({?ROLE_SUMMONED_PET_ID,RoleID}),
    erase({?PET_BUFF_TIMER_REF,PetID}),
    put(?PET_ID_LIST,lists:delete(PetID, get(?PET_ID_LIST))).
    

%%获取玩家出战的宠物的ID和map_pet的列表
get_role_pet_map_info_list(RoleID) ->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            {[], []};
        PetID ->
            case mod_map_actor:get_actor_mapinfo(PetID, pet) of
                undefined ->
                    {[], []};
                MapPetInfo ->
                    {[PetID],[MapPetInfo]}
            end
    end.  

%%获取宠物地图切换时需要传送的相关信息
get_pet_transfer_info(RoleID) ->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            [];
        PetID ->
            PetInfo = get({?ROLE_PET_INFO,PetID}),
            LastReduceTime = get({?LAST_REDUCE_LIFE_TICK,PetID}),
            MapPetInfo = mod_map_actor:get_actor_mapinfo(PetID,pet),
            BuffTimerRef = get({?PET_BUFF_TIMER_REF,PetID}),
            [{pet_transfer_info,[{{?ROLE_SUMMONED_PET_ID,RoleID},PetID},{{?ROLE_PET_INFO,PetID},PetInfo},
                                 {{?LAST_REDUCE_LIFE_TICK,PetID},LastReduceTime},{{map_pet_info,PetID},MapPetInfo},
                                 {{?PET_BUFF_TIMER_REF,PetID},BuffTimerRef}]}]
    end.

%%宠物在玩家切换地图时进入新的地图
role_pet_enter(RoleID,RolePos) ->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            ignore;
        PetID ->
            MapPetInfo = mod_map_actor:get_actor_mapinfo(PetID,pet),
            State = mgeem_map:get_state(),
            case mod_map_actor:enter(0, PetID, PetID, pet, MapPetInfo#p_map_pet{pos=RolePos}, 0, State) of
                        ok ->
                            put(?PET_ID_LIST,[PetID|get(?PET_ID_LIST)]);
                _ ->
                    ?ERROR_MSG("宠物跟随玩家进入地图失败  ~w",[MapPetInfo])
            end
    end.


%%宠物在玩家切换地图时退出老的地图
role_pet_quit(RoleID) ->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            ignore;
        PetID ->
            State = mgeem_map:get_state(),
            pet_quit(RoleID, PetID, State)
    end.


%%获取玩家被召唤出战的宠物的信息
get_summoned_pet_info(RoleID) ->
     case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            undefined;
        PetID ->
            {PetID,get({?ROLE_PET_INFO,PetID})}
    end.


%%宠物每秒钟的一个LOOP
loop(_MapID) ->
    List = get(?PET_ID_LIST),
    Now = common_tool:now(),
    reduce_pet_life_and_persistent(List,Now),
    random_pet_egg().


%%宠物加血
pet_add_hp(RoleID,AddValue) ->
    case get_role_pet_map_info_list(RoleID) of
        {[],[]} ->
            {error,?_LANG_PET_NOT_SUMMONED};
        {[PetID],[MapPetInfo]} ->
            MaxHp = MapPetInfo#p_map_pet.max_hp,
            Hp = MapPetInfo#p_map_pet.hp,
            case MaxHp =:= Hp of
                true ->
                    {error,?_LANG_PET_ADD_HP_FAIL_HP_FULL};
                false ->
                    case Hp + AddValue > MaxHp of
                        true ->
                            NewHp = MaxHp;
                        false ->
                            NewHp = Hp + AddValue
                    end,
                    %% 此函数只在处理道具的时候调用，使用道具是事务的，不可以在事务中发消息
                    %% del by caochuncheng 2011-10-18 
                    %% Record = #m_pet_attr_change_toc{pet_id=PetID,change_type=?PET_HP_CHANGE,value=NewHp},
                    %% common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_ATTR_CHANGE, Record),
                    mod_map_actor:set_actor_mapinfo(PetID,pet,MapPetInfo#p_map_pet{hp=NewHp}),
                    {ok,PetID,NewHp}
            end                           
    end.

%% 宠物扣血
pet_reduce_hp(PetID,ReduceValue, SrcActorID, SrcActorType) ->
    case mod_map_actor:get_actor_mapinfo(PetID,pet) of
        undefined ->
            ignore;
        PetMapInfo ->
            catch hook_map_pet:be_attacked(PetMapInfo, SrcActorID, SrcActorType),
            #p_map_pet{hp=HP,role_id=RoleID} = PetMapInfo,
            case HP =< 0 of
                true ->
                    pet_dead(PetID,PetMapInfo#p_map_pet{hp=0},RoleID);
                false ->
                    NewHP = HP - ReduceValue,
                    %%%%?ERROR_MSG("pet redece hp ,NewHP = ~w",[NewHP]),
                    case NewHP =< 0 of
                        true ->
                            pet_dead(PetID,PetMapInfo#p_map_pet{hp=0},RoleID);
                        false ->
                            mod_map_actor:set_actor_mapinfo(PetID,pet,PetMapInfo#p_map_pet{hp=NewHP}),
                            Record = #m_pet_attr_change_toc{pet_id=PetID,change_type=?PET_HP_CHANGE,value=NewHP},
                            common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_ATTR_CHANGE, Record)
                    end
            end
    end.


%%设置宠物的攻击模式，始终与主人的攻击模式保持一致
set_pet_pk_mode(RoleID, PkMode) ->
    case get_summoned_pet_info(RoleID) of
        undefined ->
            ignore;
        {PetID,PetInfo} ->
            put({?ROLE_PET_INFO,PetID},PetInfo#p_pet{pk_mode=PkMode})
    end.


add_pet_exp(RoleID,AddExp,IsNotice) ->
    do_add_exp(RoleID,AddExp,IsNotice).


get_pet_buff_final_value(RoleID,BuffID,Value) when is_integer(RoleID)->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            0;
        PetID ->
            case get({?ROLE_PET_INFO,PetID}) of
                undefined ->
                    0;
                PetInfo ->
                  get_pet_buff_final_value(PetInfo,BuffID,Value)
            end
    end;
get_pet_buff_final_value(PetInfo,BuffID,Value) ->
    #p_pet{skills=Skills,level=Level,max_hp=MaxHp} =PetInfo,
    SkillID = lists:foldr(
                fun(#p_pet_skill{skill_id=TmpSkillID},Acc) ->
                        case Acc of
                            0 ->
                                {ok, #p_skill_level{buffs=Buffs}} = mod_skill_manager:get_skill_level_info(TmpSkillID, 1),
                                case lists:keyfind(BuffID, #p_buf.buff_id, Buffs) of
                                    false ->
                                        Acc;
                                    _ ->
                                        TmpSkillID
                                end;
                            _ ->
                                Acc
                        end
                end, 0, Skills),
    case common_config_dyn:find(pet_skill,SkillID) of
        [] ->
            ?ERROR_MSG("宠物技能配置文件错误,SkilllID=~w",[SkillID]),
            0;
        [#r_pet_skill{expression=Expression}] ->
            case Expression of
                ?PET_BUFF_FIRST_EXPRESSION ->
                    (trunc(Level/50) + 1) * Value;
                ?PET_BUFF_SECOND_EXPRESSION ->
                    (trunc(Level/50) + 2) * Value;
                ?PET_BUFF_THIRD_EXPRESSION ->
                    (trunc(Level/50) + 3) * Value;
                ?PET_BUFF_FOURTH_EXPRESSION_WITH_PET_HP ->
                    trunc(MaxHp*Value/10000);
                _ ->
                    ?ERROR_MSG("宠物技能配置文件错误,SkilllID=~w",[SkillID]),
                    0
            end
    end.


%%玩家攻击模式改变时宠物的攻击模式也要改变
hook_role_pk_mode_change(RoleID,PKMode) ->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            ignore;
        PetID ->
            case get({?ROLE_PET_INFO,PetID}) of
                undefined ->
                    ignore;
                PetInfo ->
                    put({?ROLE_PET_INFO,PetID},PetInfo#p_pet{pk_mode=PKMode})
            end
    end.
    

%%宠物重置属性
reset_pet_attr(RoleID) ->
    case get_summoned_pet_info(RoleID) of
        undefined ->
            {error,?_LANG_PET_RESET_ATTR_ITEM_USE_FAIL_NO_SUMMONED_PET};
        {PetID,PetInfo} ->
            Level = PetInfo#p_pet.level,
            RemainAttrPoints = get_remain_attr_point_by_level(Level),
            PetInfo2 = PetInfo#p_pet{base_str=0, base_int2=0, base_con=0, base_dex=0, base_men=0, remain_attr_points=RemainAttrPoints},
            NewPetInfo = calc_pet_attr(PetInfo2),
            MaxHP = NewPetInfo#p_pet.max_hp,
            HP = NewPetInfo#p_pet.hp,
            case HP > MaxHP of
                true -> 
                    HP2 = MaxHP;
                false ->
                    HP2 = HP
            end,
            NewPetInfo2 = NewPetInfo#p_pet{hp=HP2},
            put({?ROLE_PET_INFO,PetID},NewPetInfo2),
            %% 此函数只在处理道具的时候调用，使用道具是事务的，不可以在事务中发消息
            %% del by caochuncheng 2011-10-18 
            %%Record = #m_pet_info_toc{succ=true,pet_info=NewPetInfo2},
            %%common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_INFO, Record),
            write_pet_action_log(NewPetInfo2,RoleID,?PET_ACTION_TYPE_REFRESH_ATTR,"宠物洗髓",0,""), 
            {ok,NewPetInfo2}                 
    end.

%% 只给训练的时候用啊..
t_add_pet_exp(PetID, AddExp,IsNotice) ->
    case db:read(?DB_PET,PetID) of
        [] ->
            PetInfo = undefined,
            db:abort(?_LANG_PET_NOT_EXIST);
        [PetInfo] ->
            next
    end,
    #p_pet{exp=Exp,level=Level} = PetInfo,
    NewExp = Exp + AddExp,
    case common_config_dyn:find(pet_level,Level) of
        [] ->LevelExpInfo= undefined,
             db:abort(?_LANG_PET_CONFIG_ERROR);
        [LevelExpInfo] ->
            next
    end,
    NextLevelExp = LevelExpInfo#pet_level.next_level_exp,
    {ok,RoleAttr} = mod_map_role:get_role_attr(PetInfo#p_pet.role_id),
    RoleLevel = RoleAttr#p_role_attr.level,
    {NewPetInfo,RealAddExp} = 
        case NewExp >= NextLevelExp of
            true ->
                case Level < RoleLevel of
                    true ->
                        NewPetInfo2 = calc_pet_attr(auto_add_pet_remain_point(level_up(NewExp,Level,PetInfo,RoleLevel))),
                        NewPetInfo3 =NewPetInfo2#p_pet{hp=NewPetInfo2#p_pet.max_hp},
                        db:write(?DB_PET,NewPetInfo3,write),
                        case IsNotice of
                            true->
                                Record = #m_pet_level_up_toc{pet_info=NewPetInfo3},
                                common_misc:unicast({role,PetInfo#p_pet.role_id}, ?DEFAULT_UNIQUE, ?PET, ?PET_LEVEL_UP, Record);
                            false->
                                ignore
                        end,
                        {NewPetInfo3,AddExp};
                    false ->
                        case Exp >= NextLevelExp of
                            true ->
                                {PetInfo,0};
                            false ->
                                
                                db:write(?DB_PET,PetInfo#p_pet{exp=NextLevelExp},write),
                                case IsNotice of
                                    true->   
                                        Record = #m_pet_attr_change_toc{pet_id=PetID,change_type=?PET_EXP_CHANGE,value=NewExp},
                                        common_misc:unicast({role,PetInfo#p_pet.role_id}, ?DEFAULT_UNIQUE, ?PET, ?PET_ATTR_CHANGE, Record);
                                    false->
                                        ignore
                                end,
                                {PetInfo#p_pet{exp=NextLevelExp},NextLevelExp-Exp}
                        end
                end;
            false ->
                db:write(?DB_PET,PetInfo#p_pet{exp=NewExp},write),
                case IsNotice of
                    true->
                        Record = #m_pet_attr_change_toc{pet_id=PetID,change_type=?PET_EXP_CHANGE,value=NewExp},
                        common_misc:unicast({role,PetInfo#p_pet.role_id}, ?DEFAULT_UNIQUE, ?PET, ?PET_ATTR_CHANGE, Record);
                    false->
                        ignore
                end,
                {PetInfo#p_pet{exp=NewExp},AddExp}
        end,
    {ok,NewPetInfo,RealAddExp}.

%% 无论宠物是否出战都会给他加经验
t_common_add_pet_exp(RoleID,PetID,AddExp)->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        PetID->
            PetInfo = get({?ROLE_PET_INFO,PetID}),
            {NewPetInfo,NoticeType,RealAddExp} = calculate_add_pet_exp(PetInfo,AddExp),
            MapInfo = mod_map_actor:get_actor_mapinfo(PetID,pet),
            case NoticeType of 
                levelup->
                    #p_pet{max_hp=MaxHp,level=NewLevel} = NewPetInfo,
                    mod_map_actor:set_actor_mapinfo(PetID,pet,MapInfo#p_map_pet{hp=MaxHp,max_hp=MaxHp,level=NewLevel});
                _->
                    ignore
            end,
            put({?ROLE_PET_INFO,PetID},NewPetInfo);
        _ ->
            case db:read(?DB_PET,PetID) of
                [] ->
                    PetInfo = undefined,
                    db:abort(?_LANG_PET_NOT_EXIST);
                [PetInfo] ->
                    next
            end,
            {NewPetInfo,NoticeType,RealAddExp} = calculate_add_pet_exp(PetInfo,AddExp),
            db:write(?DB_PET,NewPetInfo,write)
    end,
    {ok,NewPetInfo,RealAddExp,NoticeType}.

calculate_add_pet_exp(PetInfo,AddExp)->
    #p_pet{exp=Exp,level=Level} = PetInfo,
    NewExp = Exp + AddExp,
    case common_config_dyn:find(pet_level,Level) of
        [] ->
            LevelExpInfo = undefined,
            db:abort(?_LANG_PET_CONFIG_ERROR);
        [LevelExpInfo] ->
            next
    end,
    NextLevelExp = LevelExpInfo#pet_level.next_level_exp,
    {ok,#p_role_attr{level=RoleLevel}} = mod_map_role:get_role_attr(PetInfo#p_pet.role_id),
    case NewExp >=NextLevelExp of
        true->
            case Level <RoleLevel of
                true->
                    PetInfo1=calc_pet_attr(auto_add_pet_remain_point(level_up(NewExp,Level,PetInfo,RoleLevel))),
                    #p_pet{max_hp=MaxHp} = PetInfo1,
                    PetInfo2 = PetInfo1#p_pet{hp=MaxHp},
                    {PetInfo2,levelup,AddExp};
                false->
                    if NextLevelExp-Exp > 0->
                           DiffExp = NextLevelExp-Exp;
                       true->
                           DiffExp = 0
                    end,
                    {PetInfo#p_pet{exp=NextLevelExp},attrchange,DiffExp}
            end;
        false->
            {PetInfo#p_pet{exp=NewExp},attrchange,AddExp}
    end.
%%
%% Local Functions
%%
%%让宠物出战
do_summon(Unique, DataIn, RoleID, Line, State) ->
    #m_pet_summon_tos{pet_id=PetID}=DataIn,
    case check_has_summon_other_pet(RoleID) of
        true ->
            do_summon_error(Unique,RoleID, Line, PetID, ?_LANG_OTHER_PET_SUMMONED);
        false ->
            case check_role_has_pet(RoleID,PetID) of
                {ok,PetInfo} ->
                    case mod_map_role:get_role_base(RoleID) of
                        {error, _} ->
                            do_summon_error(Unique,RoleID, Line, PetID, ?_LANG_SYSTEM_ERROR);
                        {ok, RoleBase} ->
                            PkMode = RoleBase#p_role_base.pk_mode,
                            do_summon2(Unique, RoleID, Line, PetID, PetInfo#p_pet{pk_mode=PkMode,buffs=[]}, State)
                    end;
                error ->
                    do_summon_error(Unique,RoleID, Line, PetID, ?_LANG_SYSTEM_ERROR)
            end
    end.


do_summon2(Unique, RoleID, Line, PetID, PetInfo, State) ->
    #p_pet{type_id=TypeID,
           pet_name=Name,
           level=Level,
           life=Life,
           hp=HP,
           title=Title,
           color=Color
          } = PetInfo,
    case Life > 0 of
        true ->
            PetInfo2 = add_pet_buff_when_summon(PetInfo),
            NewPetInfo = calc_pet_attr(PetInfo2),
            AttackSpeed = NewPetInfo#p_pet.attack_speed,
            MaxHP = NewPetInfo#p_pet.max_hp,
            case HP > MaxHP orelse HP =:= 0 of
                true -> 
                    HP2 = MaxHP;
                false ->
                    HP2 = HP
            end,
            case mod_map_actor:get_actor_pos(RoleID,role) of
                undefined ->
                    do_summon_error(Unique,RoleID, Line, PetID, ?_LANG_SYSTEM_ERROR);
                Pos ->
                    MapPetInfo = #p_map_pet{pet_id=PetID,type_id=TypeID,pet_name=Name,role_id=RoleID,attack_speed=AttackSpeed,
                                            hp=HP2,max_hp=MaxHP,level=Level,state_buffs=[],pos=Pos,state=1,title=Title,color=Color},
                    case mod_map_actor:enter(0, PetID, PetID, pet, MapPetInfo, 0, State) of
                        ok ->
                            NewPetInfo2=NewPetInfo#p_pet{life=Life-1,hp=HP2},
                            set_pet_info_in_process(RoleID,PetID,NewPetInfo2),
                            Record = #m_pet_summon_toc{succ=true, pet_info=NewPetInfo2},
                            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_SUMMON, Record);
                        _ ->
                            do_summon_error(Unique,RoleID, Line, PetID, ?_LANG_SYSTEM_ERROR)
                    end
            end;
        false ->
            do_summon_error(Unique,RoleID, Line, PetID, ?_LANG_PET_LIFE_NOT_ENOUGH_TO_SUMMON)
    end.


            
    
%%检查玩家是否有某个宠物
check_role_has_pet(RoleID,PetID) ->
    case db:dirty_read(?DB_PET,PetID) of
        [] ->
            error;
        [Info] ->
            case Info#p_pet.role_id of
                RoleID ->
                    {ok,Info};
                _ ->
                    error
            end
    end.
    
%%判断该玩家是不是已经召唤过宠物了
check_has_summon_other_pet(RoleID) ->
    case erlang:get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            false;
        _ ->
            true
    end.

do_summon_error(Unique, RoleID, Line, _PetID, Reason) ->
    Record = #m_pet_summon_toc{succ=false, reason=Reason},
    %%%%?ERROR_MSG("111111111111,reason=~w",[Reason]),
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_SUMMON, Record).

%%收回出战中的宠物
do_call_back(Unique, DataIn, RoleID, Line, State) ->
    #m_pet_call_back_tos{pet_id=PetID} = DataIn,
    case check_pet_is_summoned(RoleID,PetID) of
        true ->
             %%%%?ERROR_MSG("2222222222",[]),
            pet_quit(RoleID, PetID, State),
               %%%%?ERROR_MSG("3333333333333",[]),
            Record = #m_pet_call_back_toc{succ=true, pet_id=PetID},
            common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE, ?PET, ?PET_CALL_BACK, Record);
        false ->
            do_call_back_error(Unique, RoleID, Line, PetID, ?_LANG_PET_NOT_SUMMONED)
    end.

%%检查被召唤出来的宠物ID
check_pet_is_summoned(RoleID,PetID) ->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        PetID ->
            true;
        _ ->
            false
    end.

do_call_back_error(Unique, RoleID, Line, PetID, Reason) ->
     Record = #m_pet_call_back_toc{succ=false, reason=Reason, pet_id=PetID},
      %%%%?ERROR_MSG("call_back error  ~w",[Reason]),
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_CALL_BACK, Record).

%%宠物退出地图（战斗死亡，寿命用完，被收回或玩家下线）
pet_quit(RoleID, PetID, State) ->
    case mod_map_actor:get_actor_mapinfo(PetID,pet) of
        undefined ->
            HP = 0;
        #p_map_pet{hp=Hp} ->
            HP = Hp
    end,
    mod_map_actor:do_quit(PetID,pet,State),
    clear_pet_info_in_process(RoleID,PetID,HP).
   


%%丢弃宠物
do_throw({Unique, DataIn, RoleID, Line}, _State) ->
    #m_pet_throw_tos{pet_id=PetID} = DataIn,
    case check_pet_is_summoned(RoleID,PetID) of
        false ->
            case db:transaction(fun() -> t_throw_pet(RoleID,PetID) end) of
                {atomic, {ok,NewPetBagInfo,PetInfo}} ->
                      %%%%?ERROR_MSG("2222222222",[]),
                    write_pet_action_log(PetInfo,RoleID,?PET_ACTION_TYPE_THROW,"放生宠物",0,""),
                    Record = #m_pet_throw_toc{succ=true, bag_info=NewPetBagInfo},
                    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_THROW, Record);
                {aborted,Reason} ->
                    do_throw_error(Unique, RoleID, Line, PetID, Reason)
            end;
        true ->
            do_throw_error(Unique, RoleID, Line, PetID, ?_LANG_CAN_NOT_THROW_SUMMONED_PET)
    end.

t_throw_pet(RoleID,PetID) ->
    case db:read(?DB_ROLE_PET_BAG,RoleID,read) of
        [] ->
            db:abort(?_LANG_PET_NOT_EXIST);
        [PetBagInfo] ->
            #p_role_pet_bag{pets=Pets}=PetBagInfo,
            {Ret,NewPets} = lists:foldr(
              fun(PetIDName,{Flag,Acc}) ->
                      case PetIDName#p_pet_id_name.pet_id of
                          PetID ->
                              {ok,Acc};
                          _ ->
                              {Flag,[PetIDName|Acc]}
                      end
              end, {error,[]}, Pets),
            case Ret of
                error ->
                    db:abort(?_LANG_PET_NOT_EXIST);
                ok ->
                    {NewPets2,_} = lists:foldr(
                                 fun(PetIDName,{Acc2,Acc3}) ->
                                         {[PetIDName#p_pet_id_name{index=Acc3-1}|Acc2],Acc3-1}
                                 end, {[],length(NewPets)}, NewPets),
                    NewPetBagInfo=PetBagInfo#p_role_pet_bag{pets=NewPets2},
                    [PetInfo] = db:dirty_read(?DB_PET,PetID),
%%                     case PetInfo#p_pet.state =:= ?PET_FEED_STATE of
%%                         true ->
%%                             db:abort(?_LANG_PET_ALREADLY_FEEDED);
%%                         false ->
%%                             ignore
%%                     end,
                    case mod_pet_training:check_pet_is_training(RoleID,PetID) of
                        true->
                            db:abort(?_LANG_PET_ALREADLY_FEEDED);
                        false->
                            ignore
                    end,
                    
                    db:delete(?DB_PET,PetID,write),
                    db:write(?DB_ROLE_PET_BAG,NewPetBagInfo,write),
                    {ok,NewPetBagInfo,PetInfo}
            end
    end.
            
            

do_throw_error(Unique, RoleID, Line, _PetID, Reason) ->
     Record = #m_pet_throw_toc{succ=false, reason=Reason},
       %%%%?ERROR_MSG("throw error  ~w" ,[Reason]),
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_THROW, Record).


%%学习宠物技能
%%先判断是否有该宠物
do_learn_skill(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_learn_skill_tos{pet_id=PetID, skill_id=SkillID}=DataIn,
    case erlang:get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        PetID ->
             %%%%?ERROR_MSG("333333333  _LANG_PET_SUMMONED_CAN_NOT_LEARN_SKILL",[]),
            do_learn_skill_error(Unique, RoleID, Line, PetID, ?_LANG_PET_SUMMONED_CAN_NOT_LEARN_SKILL);
        _ ->
            case mod_skill_manager:get_skill_level_info(SkillID,1) of
                {ok, SkillLevelInfo} ->
                    do_learn_skill2(Unique,PetID,SkillID,SkillLevelInfo,RoleID,Line);
                {error,Reason} ->
                    do_learn_skill_error(Unique, RoleID, Line, PetID, Reason)
            end
    end.


do_learn_skill2(Unique,PetID,SkillID,SkillLevelInfo,RoleID,Line) ->
    TypeID = SkillLevelInfo#p_skill_level.need_item,
    case TypeID > 0 of
        true ->
            case mod_bag:check_inbag_by_typeid(RoleID, TypeID) of
                {ok, _} ->
                    NeedSilver = SkillLevelInfo#p_skill_level.need_silver,
                    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                    #p_role_attr{silver_bind = BindSilver,silver = Silver} = RoleAttr,
                    case BindSilver + Silver >= NeedSilver of 
                        true ->
                            do_learn_skill3(Unique,PetID,SkillID,SkillLevelInfo,RoleID,RoleAttr,Line);
                        false ->
                            do_learn_skill_error(Unique, RoleID, Line, PetID, ?_LANG_NOT_ENOUGH_SILVER)
                    end;
                false ->
                    do_learn_skill_error(Unique, RoleID, Line, PetID, ?_LANG_SKILL_ITEM_NOT_EXIST)
            end;
        false ->
            do_learn_skill_error(Unique, RoleID, Line, PetID, ?_LANG_SYSTEM_ERROR)
    end.


do_learn_skill3(Unique,PetID,SkillID,SkillLevelInfo,RoleID,RoleAttr,Line) ->
    case common_config_dyn:find(pet_skill, SkillID) of
        [] ->
            do_learn_skill_error(Unique, RoleID, Line, PetID, ?_LANG_SYSTEM_ERROR);
        [#r_pet_skill{skill_type=SkillType}] ->  
            Fun = 
                fun() ->
                        case db:read(?DB_PET,PetID,read) of
                            [] ->
                                db:abort(?_LANG_PET_NOT_EXIST);
                            [PetInfo] ->
                                case PetInfo#p_pet.role_id of
                                    RoleID ->                                        
                                        Skills = PetInfo#p_pet.skills,                                            
                                        Rate = get_skill_learn_rate(Skills,SkillType),
                                        case random:uniform(10000) =< Rate of
                                            true ->
                                                Skills2 = lists:keydelete(SkillType, #p_pet_skill.skill_type, Skills),
                                                NewSkills = [#p_pet_skill{skill_id=SkillID,skill_type=SkillType}|Skills2],
                                                NewPetInfo = PetInfo#p_pet{skills=NewSkills},
                                                db:write(?DB_PET,NewPetInfo,write),
                                                Ret = ok;
                                            false ->
                                                NewSkills = Skills,
                                                Ret = fail
                                        end,
                                        NewRoleAttr = t_deduct_silver(RoleAttr,SkillLevelInfo#p_skill_level.need_silver,
                                                                      ?CONSUME_TYPE_SILVER_PET_LEARN_SKILL),
                                        mod_map_role:set_role_attr(RoleID, NewRoleAttr),
                                        {ok, ChangeList, DelList} = t_deduct_item(SkillLevelInfo#p_skill_level.need_item,RoleID),
                                        {Ret,NewRoleAttr,ChangeList, DelList, NewSkills,PetInfo};
                                    _ ->
                                        db:abort(?_LANG_PET_NOT_EXIST)
                                end
                        end
                end,
            case db:transaction(Fun) of
                {aborted, Reason} ->
                    do_learn_skill_error(Unique, RoleID, Line, PetID, Reason);
                {atomic,  {Ret2,NewRoleAttr,ChangeList, DelList,NewSkills2,PetInfo}} ->
                    %%通知客户端本次技能学习结果
                    [#p_skill{name=SkillName}] = common_config_dyn:find(skill,SkillID),
                    write_pet_action_log(PetInfo,RoleID,?PET_ACTION_TYPE_LEARN_SKILL,"宠物学技能",SkillID,SkillName), 
                    %% 通知客户端角色属性变动
                    ChangeList2 = [
                                  #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=NewRoleAttr#p_role_attr.silver},
                                  #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.silver_bind}],
                    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList2),
                    common_mod_goal:hook_pet_learn_skill(RoleID, erlang:length(NewSkills2)),
                    %% 通知客户端物品变动
                    case ChangeList of
                        [] ->
                            ignore;
                        [Goods] ->
                            common_item_logger:log(RoleID,Goods,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                            common_misc:update_goods_notify({line, Line, RoleID}, Goods)
                    end,
                    
                    case DelList of
                        [] ->
                            ignore;
                        [Goods2] ->
                            common_item_logger:log(RoleID,Goods2,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                            common_misc:del_goods_notify({line, Line, RoleID}, Goods2)
                    end,
            
                    case Ret2 of
                        ok ->
                            DataRecord = #m_pet_learn_skill_toc{succ=true,succ2=true,pet_id=PetID,skills=NewSkills2};
                        fail ->
                            DataRecord = #m_pet_learn_skill_toc{succ=true,succ2=false,pet_id=PetID,skills=NewSkills2}
                      end,
                    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_LEARN_SKILL, DataRecord)   
            
            end
    end.


%%根据宠物已学技能和要学的技能的类型获取技能学习成功的概率
get_skill_learn_rate(Skills, SkillType) ->
    case SkillType < 10 
             orelse lists:keyfind(SkillType, #p_pet_skill.skill_type, Skills) =/= false of
        true ->
            10000;
        false ->
            Len = lists:foldl(
                    fun(Skill,Acc) ->
                            case Skill#p_pet_skill.skill_type < 10 of
                                true ->
                                    Acc;
                                false ->
                                    Acc+1
                            end
                    end, 0, Skills),
            case common_config_dyn:find(pet_etc,{pet_learn_skill_rate,Len}) of
                [] ->
                    0;
                [Rate] ->
                    Rate
            end
    end.

t_deduct_item(NeedItemID,RoleID) ->
    case catch mod_bag:decrease_goods_by_typeid(RoleID, [1, 2, 3], NeedItemID, 1) of
        {bag_error,num_not_enough} ->
            db:abort(?_LANG_GOODS_NUM_NOT_ENOUGH);
        Other ->
            Other
    end.

t_deduct_item(NeedItemID,RoleID,Num) when is_integer(Num)->
    case catch mod_bag:decrease_goods_by_typeid(RoleID, [1, 2, 3], NeedItemID, Num) of
        {bag_error,num_not_enough} ->
            db:abort(?_LANG_GOODS_NUM_NOT_ENOUGH);
        Other ->
            Other
    end;
t_deduct_item(NeedItemID,RoleID,Bind) ->
    case catch mod_bag:decrease_goods_by_typeid(RoleID, [1, 2, 3], NeedItemID, 1, Bind) of
        {bag_error,num_not_enough} ->
            db:abort(?_LANG_GOODS_NUM_NOT_ENOUGH);
        Other ->
            Other
    end.

t_deduct_silver(Attr,NeedSilver,DeduceLog) ->
    #p_role_attr{role_id=RoleID, silver_bind=BindSilver, silver=Silver} = Attr,

    case BindSilver >= NeedSilver of
        true ->
            common_consume_logger:use_silver({RoleID, NeedSilver, 0, DeduceLog,
                                              ""}),

            Attr#p_role_attr{silver_bind=BindSilver-NeedSilver};
        false ->
            common_consume_logger:use_silver({RoleID, BindSilver, NeedSilver-BindSilver, DeduceLog,
                                              ""}),

            Attr#p_role_attr{silver_bind=0, silver=Silver+BindSilver-NeedSilver}
    end.


do_learn_skill_error(Unique, RoleID, Line, PetID, Reason) ->
    %%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_learn_skill_toc{succ=false, reason=Reason, pet_id=PetID},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_LEARN_SKILL, Record).


%%获取宠物的详细信息
do_info(Unique, DataIn, RoleID, Line) ->
    #m_pet_info_tos{pet_id=PetID} = DataIn,
    case get({?ROLE_PET_INFO,PetID}) of
        undefined ->
            case db:dirty_read(?DB_PET,PetID) of
                [] ->
                    do_info_error(Unique, RoleID, Line, ?_LANG_PET_NOT_EXIST);
                [PetInfo] ->
                    Record = #m_pet_info_toc{succ=true, pet_info=PetInfo},
                    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_INFO, Record)
            end;
        PetInfo2 ->
            Record = #m_pet_info_toc{succ=true, pet_info=PetInfo2},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_INFO, Record)
    end.

do_info_error(Unique, RoleID, Line, Reason) ->
     Record = #m_pet_info_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_INFO, Record).

-define(ADD_PET_BAG_ITEM,12300131).
do_add_pet_bag(Unique, _DataIn, RoleID, Line, _State) ->
    Fun = 
        fun() ->
                case db:read(?DB_ROLE_PET_BAG,RoleID) of
                    [] ->
                        db:abort(?_LANG_PET_BAG_NO_PET);
                    [BagInfo] ->
                        Content = BagInfo#p_role_pet_bag.content,
                        case Content >= ?MAX_PET_BAG_CONTENT of
                            true ->
                                db:abort(?_LANG_PET_BAG_IS_FULL);
                            false ->
                                ignore
                        end,
                        {ok, ChangeList, DelList} = t_deduct_item(?ADD_PET_BAG_ITEM,RoleID),
                        db:write(?DB_ROLE_PET_BAG,BagInfo#p_role_pet_bag{content=Content+1},write),
                        {ok, ChangeList, DelList,BagInfo#p_role_pet_bag{content=Content+1}}
                end
        end,
    case db:transaction(Fun) of
        {atomic,{ok, ChangeList, DelList,PetBagInfo}} ->
            Record = #m_pet_add_bag_toc{info=PetBagInfo},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ADD_BAG, Record),
            
              case ChangeList of
                [] ->
                    ignore;
                [Goods] ->
                    common_item_logger:log(RoleID,Goods,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                    common_misc:update_goods_notify({line, Line, RoleID}, Goods)
            end,
            
            case DelList of
                [] ->
                    ignore;
                [Goods2] ->
                    common_item_logger:log(RoleID,Goods2,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                    common_misc:del_goods_notify({line, Line, RoleID}, Goods2)
            end;
        {aborted,Reason} ->
            do_add_pet_bag_error(Unique, RoleID, Line, Reason)
    end.


t_add_pet_room(RoleID)->
    case db:read(?DB_ROLE_PET_BAG,RoleID) of
        [] ->
            db:abort(?_LANG_PET_BAG_NO_PET);
        [BagInfo] ->
            Content = BagInfo#p_role_pet_bag.content,
            case Content >= ?MAX_PET_BAG_CONTENT of
                true ->
                    db:abort(?_LANG_PET_BAG_IS_FULL);
                false ->
                    ignore
            end,
            db:write(?DB_ROLE_PET_BAG,BagInfo#p_role_pet_bag{content=Content+1},write),
            {ok, BagInfo#p_role_pet_bag{content=Content+1}}
    end.

do_add_pet_bag_error(Unique, RoleID, Line, Reason) ->
     Record = #m_pet_add_bag_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ADD_BAG, Record).

%%宠物分配一级属性点
do_attr_assign(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_attr_assign_tos{pet_id=PetID,assign_info=AssignInfo} = DataIn,
    Fun = 
        fun() ->
            case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
                PetID ->
                    PetInfo = get({?ROLE_PET_INFO,PetID}),
                    case attr_assign(AssignInfo,PetInfo) of
                        {error,Reason} ->
                            db:abort({Reason,PetInfo});
                        {ok,NewPetInfo} ->
                            put({?ROLE_PET_INFO,PetID},NewPetInfo),
                            case PetInfo#p_pet.max_hp =:= NewPetInfo#p_pet.max_hp of
                                true ->
                                    PetMapInfo = mod_map_actor:get_actor_mapinfo(PetID,pet),
                                    mod_map_actor:set_actor_mapinfo(PetID,pet,PetMapInfo#p_map_pet{max_hp=NewPetInfo#p_pet.max_hp});
                                false ->
                                    ignore
                            end,
                            {ok,NewPetInfo}
                    end;
                _ ->
                    case db:read(?DB_PET,PetID) of
                        [] ->
                            db:abort({?_LANG_PET_NOT_EXIST,undeined});
                        [PetInfo] ->
                            %%%%?ERROR_MSG("2222222222 ~w",[PetInfo]),
                            case PetInfo#p_pet.role_id =:= RoleID of
                                true ->
                                    case attr_assign(AssignInfo,PetInfo) of
                                        {error,Reason} ->
                                            db:abort({Reason,PetInfo});
                                        {ok,NewPetInfo} ->
                                            db:write(?DB_PET,NewPetInfo,write),
                                             {ok,NewPetInfo}
                                    end;
                                false ->
                                    db:abort({?_LANG_PET_NOT_EXIST,undefined})
                            end
                    end
            end
        end,
    case db:transaction(Fun) of
        {atomic,{ok,NewPetInfo}} ->
            %%%%?ERROR_MSG("66666666666 ~w",[NewPetInfo]),
                Record = #m_pet_attr_assign_toc{succ=true,pet_info=NewPetInfo},
                 common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ATTR_ASSIGN, Record);
        {aborted,{Reason,OldPetinfo}} ->
            %%%%?ERROR_MSG("555555555555 ~w ~w",[Reason, OldPetinfo]),
                Record = #m_pet_attr_assign_toc{succ=false,reason=Reason,pet_info=OldPetinfo},
                 common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ATTR_ASSIGN, Record)
    end.



attr_assign(AssignInfo,PetInfo) ->
    AddPoints = lists:foldl(
                  fun(Info,Acc)-> 
                          Acc+Info#p_pet_attr_assign.assign_value 
                  end, 0, AssignInfo),
    RemainPoints = PetInfo#p_pet.remain_attr_points,
    case AddPoints > RemainPoints of
        true ->
            {error,?_LANG_PET_REMAIN_ATTR_POINT_NOT_ENOUGH};
        false ->
            NewPetInfo=lists:foldl(
                         fun(Assign,TmpPetInfo) ->
                                 #p_pet_attr_assign{assign_type=Type,assign_value=Value}=Assign,
                                 case Value >= 0 of
                                     true ->
                                         case Type of
                                             ?ATTR_STR ->
                                                 BaseStr=TmpPetInfo#p_pet.base_str,
                                                 TmpPetInfo#p_pet{base_str=BaseStr+Value};
                                             ?ATTR_INT ->
                                                 BaseInt=TmpPetInfo#p_pet.base_int2,
                                                 TmpPetInfo#p_pet{base_int2=BaseInt+Value};
                                             ?ATTR_DEX ->
                                                 BaseDex=TmpPetInfo#p_pet.base_dex,
                                                 TmpPetInfo#p_pet{base_dex=BaseDex+Value};
                                             ?ATTR_MEN ->
                                                 BaseMen=TmpPetInfo#p_pet.base_men,
                                                 TmpPetInfo#p_pet{base_men=BaseMen+Value};
                                             ?ATTR_CON ->
                                                 BaseCon=TmpPetInfo#p_pet.base_con,
                                                 TmpPetInfo#p_pet{base_con=BaseCon+Value}
                                         end;
                                     false ->
                                         db:abort({?_LANG_SYSTEM_ERROR,undefined})
                                 end
                         end, PetInfo, AssignInfo),
            NewPetInfo2 = calc_pet_attr(NewPetInfo),
            {ok,NewPetInfo2#p_pet{remain_attr_points=RemainPoints-AddPoints}}
    end.

%%宠物延寿
do_add_life(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_add_life_tos{pet_id=PetID,add_type=AddType} = DataIn,
    Fun = 
        fun() ->
                AddLife = get_life_by_item_type(AddType),
                case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
                    PetID ->
                        PetInfo = get({?ROLE_PET_INFO,PetID}),
                        Life = PetInfo#p_pet.life,
                        NewPetInfo = PetInfo#p_pet{life=Life + AddLife},
                       %% ?ERROR_MSG("$$$$$$$$$$$$$$$$$$~w",[AddType]),
                        case AddType =:= 0 of
                            true ->
                                {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                                #p_role_attr{gold_bind = BindGold, gold = Gold} = RoleAttr,
                                case BindGold + Gold >= 1 of
                                    false ->
                                        db:abort(?_LANG_NOT_ENOUGH_GOLD);
                                    true ->
                                        {NewRoleAttr,_,_} = mod_pet_feed:t_deduct_gold(RoleAttr,1,?CONSUME_TYPE_GOLD_PET_ADD_LIFE),
                                        mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                                        put({?ROLE_PET_INFO,PetID},NewPetInfo),
                                        {ok,NewPetInfo,NewRoleAttr}
                                end;
                            false ->
                                {ok, ChangeList, DelList} = t_deduct_item(AddType,RoleID),
                                put({?ROLE_PET_INFO,PetID},NewPetInfo),
                                {ok,NewPetInfo,ChangeList,DelList}
                        end;
                    _ ->
                        case db:read(?DB_PET,PetID) of
                            [] ->
                                db:abort(?_LANG_PET_NOT_EXIST);
                            [PetInfo] ->
                                case PetInfo#p_pet.role_id =:= RoleID of
                                    true ->
                                        Life = PetInfo#p_pet.life,
                                        NewPetInfo = PetInfo#p_pet{life=Life + AddLife},
                                        db:write(?DB_PET,NewPetInfo,write),
                                        case AddType =:= 0 of
                                            true ->
                                                {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                                                 #p_role_attr{gold_bind = BindGold, gold = Gold} = RoleAttr,
                                                 case BindGold + Gold >= 1 of
                                                    false ->
                                                        db:abort(?_LANG_NOT_ENOUGH_GOLD);
                                                    true ->
                                                        {NewRoleAttr,_,_} = mod_pet_feed:t_deduct_gold(RoleAttr,1,?CONSUME_TYPE_GOLD_PET_ADD_LIFE),
                                                        mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                                                        {ok,NewPetInfo,NewRoleAttr}
                                                end;
                                            false ->
                                                
                                                {ok, ChangeList, DelList} = t_deduct_item(AddType,RoleID),
                                                
                                                {ok,NewPetInfo,ChangeList, DelList}
                                        end;
                                    false ->
                                        db:abort(?_LANG_PET_NOT_EXIST)
                                end
                        end
                end
        end,
    case db:transaction(Fun) of
        {atomic,{ok,NewPetInfo,ChangeList, DelList}} ->
            write_pet_action_log(NewPetInfo,RoleID,?PET_ACTION_TYPE_ADD_LIFE,"宠物延寿",0,""), 
            
            case ChangeList of
                [] ->
                    ignore;
                [Goods] ->
                    common_item_logger:log(RoleID,Goods,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                    common_misc:update_goods_notify({line, Line, RoleID}, Goods)
            end,
            
            case DelList of
                [] ->
                    ignore;
                [Goods2] ->
                    common_item_logger:log(RoleID,Goods2,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                    common_misc:del_goods_notify({line, Line, RoleID}, Goods2)
            end,
            
            Record = #m_pet_add_life_toc{succ=true,pet_id=PetID,life=NewPetInfo#p_pet.life},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ADD_LIFE, Record);
        {atomic,  {ok,NewPetInfo,NewRoleAttr}} ->
            write_pet_action_log(NewPetInfo,RoleID,?PET_ACTION_TYPE_ADD_LIFE,"宠物延寿",0,""),
            ChangeList = [
                          #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=NewRoleAttr#p_role_attr.gold},
                          #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.gold_bind}],
            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList),
            
            Record = #m_pet_add_life_toc{succ=true,pet_id=PetID,life=NewPetInfo#p_pet.life},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ADD_LIFE, Record);
        {aborted,Reason} ->
            Record = #m_pet_add_life_toc{succ=false, reason=Reason, pet_id=PetID},
%%%%?ERROR_MSG("add life  error  ~w" ,[Reason]),
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ADD_LIFE, Record)
    end.


%%获取宠物延寿的具体数值
get_life_by_item_type(ItemType) ->
    case ItemType of
        12300105 ->
            200;
        12300106 ->
            500;
        12300107 ->
            1200;
        0 ->
            200;
        _ ->
            db:abort(?_LANG_ADD_PET_LIFE_ITEM_TYPE_ERROR)
    end.


%%宠物洗灵手续费10两
-define(PET_REFRESH_APTITUDE_DEDUCT_SILVER,50).
%%宠物洗灵
do_refresh_aptitude(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_refresh_aptitude_tos{pet_id=PetID,item_type=ItemType,bind = Bind} = DataIn,
    case erlang:get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        PetID ->
            do_refresh_aptitude_error(Unique, RoleID, Line, ?_LANG_PET_SUMMONED_CAN_NOT_REFRESH_APTITUDE);
        _ ->
            {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
            #p_role_attr{silver_bind = BindSilver,silver = Silver} = RoleAttr,
            case BindSilver + Silver >= ?PET_REFRESH_APTITUDE_DEDUCT_SILVER of
                false ->
                    do_refresh_aptitude_error(Unique, RoleID, Line, ?_LANG_NOT_ENOUGH_SILVER);
                true ->
                    Fun = fun() -> refresh_aptitude(PetID,RoleID,RoleAttr,ItemType,Bind) end,
                    case db:transaction(Fun) of
                        {aborted, Reason} ->
                            do_refresh_aptitude_error(Unique, RoleID, Line, Reason);
                        {atomic, {ok, ChangeList, DelList,NewPetInfo,NewRoleAttr}} ->
                            write_pet_action_log(NewPetInfo,RoleID,?PET_ACTION_TYPE_REFRESH_APTITUDE,"宠物洗灵",0,""),
                            DataRecord = #m_pet_refresh_aptitude_toc{succ=true,pet_info=NewPetInfo},
                            %% 通知客户端角色属性变动
                            ChangeList2 = [
                                  #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=NewRoleAttr#p_role_attr.silver},
                                  #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.silver_bind}],
                            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList2),
                            
                            %% 通知客户端物品变动
                            case ChangeList of
                                [] ->
                                    ignore;
                                [Goods] ->
                                    common_item_logger:log(RoleID,Goods,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                                    common_misc:update_goods_notify({line, Line, RoleID}, Goods)
                            end,
                            
                            case DelList of
                                [] ->
                                    ignore;
                                [Goods2] ->
                                    common_item_logger:log(RoleID,Goods2,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                                    common_misc:del_goods_notify({line, Line, RoleID}, Goods2)
                            end,
                            %% add by caochuncheng 2011-10-17 
                            ?TRY_CATCH( common_mod_goal:hook_pet_refresh_aptitude(RoleID),RefreshAptitudeErr),
                            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_REFRESH_APTITUDE, DataRecord)
                    end
            end
    end.


refresh_aptitude(PetID,RoleID,RoleAttr,ItemType,Bind) ->
    case db:read(?DB_PET,PetID) of
        [] ->
            db:abort(?_LANG_PET_NOT_EXIST);
        [PetInfo] ->
            %%?ERROR_MSG("2222222222 ~w",[PetInfo]),
            case PetInfo#p_pet.role_id =:= RoleID of
                false ->
                    db:abort(?_LANG_PET_NOT_EXIST);
                true ->
                    TypeID = PetInfo#p_pet.type_id,
                    AttackType = PetInfo#p_pet.attack_type,
                    [#p_pet_base_info{carry_level=CarryLevel}] = common_config_dyn:find(pet,TypeID),
                    NewRoleAttr = t_deduct_silver(RoleAttr,?PET_REFRESH_APTITUDE_DEDUCT_SILVER,?CONSUME_TYPE_SILVER_PET_REFRESH_APTITUDE),
                    mod_map_role:set_role_attr(RoleID, NewRoleAttr),
                    case check_item_can_use_on_refresh_aptitude(CarryLevel,ItemType) of
                        false ->
                            db:abort(?_LANG_PET_REFRESH_APTITUDE_ITEM_ERROR);
                        _ ->
                            {ok, ChangeList, DelList} = t_deduct_item(ItemType, RoleID,Bind),
                            {HPAptitude, PDAptitude, MDAptitude, PAAptitude, MAAptitude, DoubleAptitude} = get_refresh_all_aptitudes(TypeID, AttackType),
                            UnderStanding = PetInfo#p_pet.understanding,
                            {Color,Title} = get_pet_color_and_title(PAAptitude, MAAptitude, CarryLevel, UnderStanding),
                            check_pet_bag_color_change(RoleID,PetID,Color,PetInfo#p_pet.color),
                            NewBind = PetInfo#p_pet.bind or Bind,
                            NewPetInfo = PetInfo#p_pet{color=Color, hp=0,title=Title,bind=NewBind,
                                                       max_hp_aptitude=HPAptitude, phy_defence_aptitude=PDAptitude, magic_defence_aptitude=MDAptitude,
                                                       phy_attack_aptitude=PAAptitude, magic_attack_aptitude=MAAptitude, double_attack_aptitude=DoubleAptitude},
                            NewPetInfo2 = calc_pet_attr(NewPetInfo),
                            db:write(?DB_PET,NewPetInfo2,write),
                            
                            case check_is_prefect_pet([HPAptitude, PDAptitude, MDAptitude, PAAptitude, MAAptitude, DoubleAptitude],TypeID) of
                                true ->
                                    Content = io_lib:format(?_LANG_PET_REFRESH_APTITUDE_GET_GOOD_PET,[RoleAttr#p_role_attr.role_name]),
                                    catch common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_WORLD,common_tool:to_list(Content));
                                false ->
                                    ignore
                            end,
                            {ok, ChangeList, DelList,NewPetInfo2,NewRoleAttr}
                    end
            end
    end.


%%根据宠物原始资质判断是否是极品
check_is_prefect_pet(List, TypeID) ->
     case common_config_dyn:find(pet_aptitude,{TypeID,2})  of
        [] ->
            false;
        [Info] ->
            MaxAptitude = Info#r_pet_aptitude_config.max_aptitude,
            check_is_prefect_pet_2(List,MaxAptitude)
     end.

check_is_prefect_pet_2([], _TypeID) ->
    false;
check_is_prefect_pet_2([Aptitude|List], MaxAptitude) ->
     case MaxAptitude -  Aptitude =< 200 of
        true ->
            true;
       false ->
             check_is_prefect_pet_2(List,MaxAptitude)
     end.

%%根据宠物的宠物类型和攻击类型获取宠物洗灵后的新资质
get_refresh_all_aptitudes(TypeID, AttackType) ->
    case AttackType of
        ?PET_ATTACK_TYPE_PHY ->
            PAAptitude = random_get_aptitude_by_type(TypeID,2),
            MAAptitude = trunc(PAAptitude/5) + 100 + random:uniform(200);
        ?PET_ATTACK_TYPE_MAGIC ->
            MAAptitude = random_get_aptitude_by_type(TypeID,2),
            PAAptitude = trunc(MAAptitude/5) + 100 + random:uniform(200)
    end,
    HPAptitude = random_get_aptitude_by_type(TypeID,2),
    PDAptitude = random_get_aptitude_by_type(TypeID,2),
    MDAptitude = random_get_aptitude_by_type(TypeID,2),
    DoubleAptitude = random_get_aptitude_by_type(TypeID,2),
     {HPAptitude, PDAptitude, MDAptitude, PAAptitude, MAAptitude, DoubleAptitude}.


%%检查宠物洗灵用的洗灵丹类型是否正确
%% 12300118 初级洗灵丹  12300119 中级洗灵丹   12300120 高级洗灵丹
check_item_can_use_on_refresh_aptitude(CarryLevel,ItemType) ->
    case common_config_dyn:find(pet_etc,{pet_refresh_aptitude_item,CarryLevel}) of
        [ItemList]->
            lists:member(ItemType, ItemList);
        []->
            []
    end.

        

do_refresh_aptitude_error(Unique, RoleID, Line, Reason) ->
    %%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_refresh_aptitude_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_REFRESH_APTITUDE, Record).

%%提悟保护符的ID
-define(UnderStandingProtectItemType,12300124).
-define(UnderStandingDeductSilver,1000).
%%宠物提悟
do_add_understanding(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_add_understanding_tos{pet_id=PetID,item_type=ItemType,use_protect=UsePeotect,bind=Bind} = DataIn,
    %%%%?ERROR_MSG("88888888  ~w  ~w  ~w",[PetID,ItemType,UsePeotect]),
    case erlang:get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        PetID ->
            do_add_understanding_error(Unique, RoleID, Line, ?_LANG_PET_SUMMONED_CAN_NOT_ADD_UNDERSTANDING);
        _ ->
            {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
            #p_role_attr{silver_bind = BindSilver,silver = Silver} = RoleAttr,
            %%%%?ERROR_MSG("111111111 ~w  ~w",[BindSilver,Silver]),
            case BindSilver + Silver >= ?UnderStandingDeductSilver of 
                true ->
                    Fun = fun() -> add_understanding(PetID,ItemType,Bind,UsePeotect,RoleID,RoleAttr) end,
                    case db:transaction(Fun) of
                        {aborted, Reason} ->
                            do_add_understanding_error(Unique, RoleID, Line, Reason);
                        {atomic, {Ret,ChangeList, DelList,NewPetInfo,NewRoleAttr,OldUnderStanding}} ->
                            DetailStr = io_lib:format("提悟前悟性=~w, 提悟后悟性=~w",[OldUnderStanding,NewPetInfo#p_pet.understanding]),
                            write_pet_action_log(NewPetInfo,RoleID,?PET_ACTION_TYPE_ADD_UNDERSTANDING,"宠物提悟",0,DetailStr),
                            DataRecord = #m_pet_add_understanding_toc{succ=true,succ2=Ret,pet_info=NewPetInfo},
                            %% 通知客户端角色属性变动
                            AttrChangeList = [
                                          #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=NewRoleAttr#p_role_attr.silver},
                                          #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.silver_bind}],
                            common_misc:role_attr_change_notify({role, RoleID}, RoleID, AttrChangeList),
                            
                            %% 通知客户端物品变动
                            case ChangeList of
                                [] ->
                                    ignore;
                                GoodsList ->
                                    lists:foreach( 
                                      fun(Goods) ->
                                              common_item_logger:log(RoleID,Goods,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                                              common_misc:update_goods_notify({line, Line, RoleID}, Goods)
                                      end,GoodsList)
                            end,
                            
                            case DelList of
                                [] ->
                                    ignore;
                                GoodsList2 ->
                                    lists:foreach( 
                                      fun(Goods2) ->
                                              common_item_logger:log(RoleID,Goods2,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                                              common_misc:del_goods_notify({line, Line, RoleID}, Goods2)
                                      end,GoodsList2)
                            end,
                            %?ERROR_MSG("$$$$$$$$$$$$  ~w",[DataRecord]),
                            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ADD_UNDERSTANDING, DataRecord)
                    end;
                false ->
                    do_add_understanding_error(Unique, RoleID, Line, ?_LANG_NOT_ENOUGH_SILVER)
            end
    end.


add_understanding(PetID,ItemType,Bind,UsePeotect,RoleID,RoleAttr)  ->
     %%%%?ERROR_MSG("77777777777777",[]),
    case db:read(?DB_PET,PetID) of
        [] ->
            db:abort(?_LANG_PET_NOT_EXIST);
        [PetInfo] ->
            %%%%?ERROR_MSG("2222222222 ~w",[PetInfo]),
            case PetInfo#p_pet.role_id =:= RoleID of
                true ->
                    UnderStanding = PetInfo#p_pet.understanding,
                    NewBind = PetInfo#p_pet.bind or Bind,
                    case UnderStanding >= 15 of
                        true ->
                            db:abort(?_LANG_PET_UNDERSTANDING_IS_FULL);
                        false ->
                            {Rand,FailUnderStanding,ItemTypeList} = get_add_understanding_info(UnderStanding),
                            case lists:member(ItemType, ItemTypeList) of
                                false ->
                                    db:abort(?_LANG_PET_ADD_UNDERSTANDING_ITEM_ERROR);
                                _ ->
                                     %%%%?ERROR_MSG("66666666666",[]),
                                     #p_pet{type_id=TypeID,phy_attack_aptitude=PAAptitude,magic_attack_aptitude=MAAptitude} = PetInfo,
                                    
                                    [#p_pet_base_info{carry_level=CarryLevel}] = common_config_dyn:find(pet,TypeID),
                                    NewRoleAttr = t_deduct_silver(RoleAttr,?UnderStandingDeductSilver,?CONSUME_TYPE_SILVER_PET_ADD_UNDERSTANDING),
                                    mod_map_role:set_role_attr(RoleID, NewRoleAttr),
                                    {ok, ChangeList, DelList} = t_deduct_item(ItemType, RoleID,Bind),
                                    case UsePeotect of
                                        true ->
                                            {ok, ChangeList2, DelList2} = t_deduct_item(?UnderStandingProtectItemType, RoleID);
                                        false ->
                                            {ChangeList2, DelList2} = {[],[]}
                                    end,
                                     %%%%?ERROR_MSG("3333333333333",[]),
                                    {ChangeList3, DelList3} = {lists:append(ChangeList,ChangeList2),lists:append(DelList,DelList2)},
                                    Rate = random:uniform(10000),
                                    Rate2 = Rate + mod_vip:get_vip_pet_understand_rate(RoleID),
                                    case Rate2 =< Rand of
                                        true ->
                                            NewUnderStanding = UnderStanding+1;
                                        false ->
                                            case UsePeotect of
                                                true ->
                                                    NewUnderStanding = UnderStanding;
                                                false ->
                                                    NewUnderStanding = FailUnderStanding
                                            end
                                    end,
                                     %?ERROR_MSG("444444444444 ~w  ~w   ~w   ~w",[Rate , Rand, NewUnderStanding, UnderStanding]),
                                    case NewUnderStanding > UnderStanding of
                                        false ->
                                            case NewUnderStanding =:= UnderStanding of
                                                true ->
                                                    NewPetInfo = PetInfo;
                                                false ->
                                                     {Color,Title} = get_pet_color_and_title(PAAptitude, MAAptitude, CarryLevel, NewUnderStanding),
                                                     check_pet_bag_color_change(RoleID,PetID,Color,PetInfo#p_pet.color),
                                                     NewPetInfo = calc_pet_second_attr(PetInfo#p_pet{understanding=NewUnderStanding,title=Title,color=Color,bind=NewBind}),
                                                     db:write(?DB_PET,NewPetInfo,write)
                                            end,
                                             {false,ChangeList3, DelList3,NewPetInfo,NewRoleAttr,UnderStanding};
                                        true ->
                                           
                                            {Color,Title} = get_pet_color_and_title(PAAptitude, MAAptitude, CarryLevel, NewUnderStanding),
                                            check_pet_bag_color_change(RoleID,PetID,Color,PetInfo#p_pet.color),
                                            NewPetInfo = calc_pet_second_attr(PetInfo#p_pet{understanding=NewUnderStanding,title=Title,color=Color,bind=NewBind}),
                                            db:write(?DB_PET,NewPetInfo,write),
                                            case NewUnderStanding =:= 6 orelse NewUnderStanding=:= 9 orelse NewUnderStanding >= 12 of
                                                true ->
                                                    Content = io_lib:format(?_LANG_PET_ADD_UNDERSTANDING_MORE_THAN_SIX,[RoleAttr#p_role_attr.role_name,NewUnderStanding]),
                                                    %%?ERROR_MSG("######### ~w",Content),
                                                    catch common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_WORLD,common_tool:to_list(Content));
                                                false ->
                                                    ignore
                                            end,
                                            {true,ChangeList3, DelList3,NewPetInfo,NewRoleAttr,UnderStanding}
                                    end      
                            end
                    end;
                false ->
                    db:abort(?_LANG_PET_NOT_EXIST)
            end
    end.


-record(r_pet_understanding,{understanding,info}).
%%12300121 初级提悟符  12300122 中级提悟符   12300123 高级提悟符
get_add_understanding_info(UnderStanding) ->
    case common_config_dyn:find(pet_understanding,UnderStanding) of
        [] ->
             {0,9,[]};
        [#r_pet_understanding{info=Info}] ->
            Info
    end.

            
do_add_understanding_error(Unique, RoleID, Line, Reason) ->
    %%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_add_understanding_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ADD_UNDERSTANDING, Record).


%%宠物改名
do_change_name(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_change_name_tos{pet_id=PetID, pet_name=PetName} = DataIn,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{gold_bind = BindGold,gold = Gold} = RoleAttr,
    case BindGold > 0 orelse Gold > 0 of
        false ->
            do_change_name_error(Unique, RoleID, Line, PetID, PetName, ?_LANG_NOT_ENOUGH_GOLD);
        true ->
            case erlang:get({?ROLE_SUMMONED_PET_ID,RoleID}) of
                PetID ->
                    do_change_name_error(Unique, RoleID, Line, PetID, PetName, ?_LANG_PET_SUMMONED_CAN_NOT_CHANGE_NAME);
                _ -> 
                    Fun = fun() -> change_name(RoleID,PetID, PetName, RoleAttr) end,
                    case db:transaction(Fun) of
                        {aborted, {Reason,OldName}} ->
                            do_change_name_error(Unique, RoleID, Line, PetID, OldName, Reason);
                        {atomic, {ok,NewRoleAttr,NewBagInfo}} ->
                            Record = #m_pet_change_name_toc{succ=true, pet_id=PetID, pet_name=PetName},
                            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_CHANGE_NAME, Record),
                            ChangeList = [
                                           #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=NewRoleAttr#p_role_attr.gold},
                                           #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.gold_bind}],
                            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList),
                            %%以下为了方便客户端跟新信息，特意加的，不符合服务器端开发习惯
                            Record3 = #m_pet_bag_info_toc{info=NewBagInfo},
                            common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE, ?PET, ?PET_BAG_INFO, Record3)
                    
                    end
            end
    end.


%%宠物改名手续费1元宝
-define(PET_CHANGE_NAME_DEDUCT_GOLD,1).


change_name(RoleID,PetID, PetName, RoleAttr) ->
    case db:read(?DB_PET,PetID) of
        [] ->
            db:abort({?_LANG_PET_NOT_EXIST,undefined});
        [PetInfo] ->
            %%%%?ERROR_MSG("2222222222 ~w",[PetInfo]),
            case PetInfo#p_pet.role_id =:= RoleID of
                false ->
                    db:abort({?_LANG_PET_NOT_EXIST,undefined});
                true ->
                    [BagInfo] = db:read(?DB_ROLE_PET_BAG,RoleID),
                    Pets = BagInfo#p_role_pet_bag.pets,
                    NewPets = lists:foldr(
                                fun(IDName,Acc) -> 
                                        case IDName#p_pet_id_name.pet_id =:= PetID of
                                            true ->
                                                [IDName#p_pet_id_name{name=PetName}|Acc];
                                            false ->
                                                [IDName|Acc]
                                        end
                                end,[],Pets),
                    NewRoleAttr = deduct_gold(RoleAttr,?PET_CHANGE_NAME_DEDUCT_GOLD,?CONSUME_TYPE_GOLD_PET_CHANGE_NAME),
                    mod_map_role:set_role_attr(RoleID, NewRoleAttr),
                    db:write(?DB_ROLE_PET_BAG,BagInfo#p_role_pet_bag{pets=NewPets},write),
                    db:write(?DB_PET,PetInfo#p_pet{pet_name=PetName},write),
                    {ok,NewRoleAttr,BagInfo#p_role_pet_bag{pets=NewPets}}
            end
    end.


deduct_gold(Attr,NeedGold,DeduceLog) ->
    #p_role_attr{role_id=RoleID, gold_bind=BindGold, gold=Gold} = Attr,

    case BindGold >= NeedGold of
        true ->
            common_consume_logger:use_gold({RoleID, NeedGold, 0, DeduceLog,
                                              ""}),

            Attr#p_role_attr{gold_bind=BindGold-NeedGold};
        false ->
            common_consume_logger:use_gold({RoleID, BindGold, NeedGold-BindGold, DeduceLog,
                                              ""}),

            Attr#p_role_attr{gold_bind=0, gold=Gold+BindGold-NeedGold}
    end.


do_change_name_error(Unique, RoleID, Line, PetID, PetName, Reason) ->
    %%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_change_name_toc{succ=false, reason=Reason, pet_id=PetID, pet_name=PetName},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_CHANGE_NAME, Record).


do_pet_add_skill_grid(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_add_skill_grid_tos{pet_id=PetID} = DataIn,
    Fun = 
        fun() ->   
                {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                #p_role_attr{gold_bind = BindGold, gold = Gold} = RoleAttr,
                case erlang:get({?ROLE_SUMMONED_PET_ID,RoleID}) of
                    PetID ->
                        PetInfo = get({?ROLE_PET_INFO,PetID}), 
                        MaxSkillGrid = PetInfo#p_pet.max_skill_grid,
                        NeedGold = get_add_skill_grid_gold(MaxSkillGrid),
                        NewPetInfo = PetInfo#p_pet{max_skill_grid=MaxSkillGrid + 1},
                        case BindGold + Gold >= NeedGold of
                            false ->
                                db:abort(?_LANG_NOT_ENOUGH_GOLD);
                            true ->
                                {NewRoleAttr,_,_} = mod_pet_feed:t_deduct_gold(RoleAttr,NeedGold,?CONSUME_TYPE_GOLD_PET_ADD_SKILL_GRID),
                                mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                                put({?ROLE_PET_INFO,PetID},NewPetInfo),
                                {ok,NewPetInfo,NewRoleAttr}
                        end;
                    _ ->
                        case db:read(?DB_PET,PetID) of
                            [] ->
                                db:abort(?_LANG_PET_NOT_EXIST);
                            [PetInfo] ->
                                MaxSkillGrid = PetInfo#p_pet.max_skill_grid,
                                NeedGold = get_add_skill_grid_gold(MaxSkillGrid),
                                NewPetInfo = PetInfo#p_pet{max_skill_grid=MaxSkillGrid + 1}, 
                                case BindGold + Gold >= NeedGold of
                                    false ->
                                        db:abort(?_LANG_NOT_ENOUGH_GOLD);
                                    true ->
                                        {NewRoleAttr,_,_} = mod_pet_feed:t_deduct_gold(RoleAttr,NeedGold,?CONSUME_TYPE_GOLD_PET_ADD_SKILL_GRID),
                                        mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                                        db:write(?DB_PET,NewPetInfo,write),
                                        {ok,NewPetInfo,NewRoleAttr}
                                end
                        end
                end
        end, 
    case db:transaction(Fun) of
        {aborted, Reason} ->
            do_pet_add_skill_grid_error(Unique, RoleID, Line, Reason);
        {atomic, {ok, NewPetInfo,NewRoleAttr}} ->
            write_pet_action_log(NewPetInfo,RoleID,?PET_ACTION_TYPE_ADD_SKILL_GRID,"宠物增加技能栏",0,""),
            DataRecord = #m_pet_add_skill_grid_toc{succ=true,pet_info=NewPetInfo},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ADD_SKILL_GRID, DataRecord),
            ChangeList = [
                          #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=NewRoleAttr#p_role_attr.gold},
                          #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.gold_bind}],
            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList)
    end.


get_add_skill_grid_gold(MaxSkillGrid) ->
    case common_config_dyn:find(pet_etc,{pet_add_skill_grid,MaxSkillGrid}) of
        [] ->
            1000000;    %%哥们愿意花钱你管得着啊
        [Gold] ->
            Gold
    end.




do_pet_add_skill_grid_error(Unique, RoleID, Line, Reason) ->
    %%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_add_skill_grid_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_ADD_SKILL_GRID, Record).

do_pet_forget_skill(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_forget_skill_tos{pet_id=PetID,skill_id=SkillID} = DataIn,
    case erlang:get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        PetID ->
            do_pet_forget_skill_error(Unique, RoleID, Line, ?_LANG_PET_SUMMONED_CAN_NOT_FORGET_SKILL);
        _ ->
            Fun = fun() ->
                          case db:read(?DB_PET,PetID) of
                              [] ->
                                  db:abort(?_LANG_PET_NOT_EXIST);
                              [PetInfo] ->
                                  case SkillID of
                                      0 ->
                                          forget_all_skills(PetInfo,RoleID);
                                      _ ->
                                          forget_single_skill(PetInfo,SkillID,RoleID)
                                  end
                          end
                  end,
            case db:transaction(Fun) of
                {aborted, Reason} ->
                    do_pet_add_skill_grid_error(Unique, RoleID, Line, Reason);
                {atomic, {ok, NewPetInfo,NewRoleAttr}} -> 
                    write_pet_action_log(NewPetInfo,RoleID,?PET_ACTION_TYPE_FORGET_SKILL,"宠物遗忘技能",0,""),
                    DataRecord = #m_pet_forget_skill_toc{succ=true,pet_info=NewPetInfo},
                    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FORGET_SKILL, DataRecord),
                    ChangeList = [
                                  #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=NewRoleAttr#p_role_attr.silver},
                                  #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.silver_bind}],
                    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList)
            end
    end.



forget_all_skills(PetInfo,RoleID) ->
    NewPetInfo = PetInfo#p_pet{skills=[]},
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{silver_bind = BindSilver,silver = Silver} = RoleAttr,
    case BindSilver + Silver >= 30000 of 
        true ->
            NewRoleAttr = t_deduct_silver(RoleAttr,30000,?CONSUME_TYPE_SILVER_PET_FORGET_SKILL),
            mod_map_role:set_role_attr(RoleID,NewRoleAttr),
            db:write(?DB_PET,NewPetInfo,write),
            {ok,NewPetInfo,NewRoleAttr};
        false ->
           db:abort(?_LANG_NOT_ENOUGH_SILVER)
    end.

forget_single_skill(PetInfo,SkillID,RoleID) ->
    OldSkills = PetInfo#p_pet.skills,
    case lists:keyfind(SkillID, #p_pet_skill.skill_id, OldSkills) of
        false ->
            db:abort(?_LANG_PET_SKILL_NOT_EXIST); 
        _ ->
            NewSkills = lists:keydelete(SkillID, #p_pet_skill.skill_id, OldSkills),
            NewPetInfo = PetInfo#p_pet{skills=NewSkills},
            {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
            #p_role_attr{silver_bind = BindSilver,silver = Silver} = RoleAttr,
            case BindSilver + Silver >= 12000 of 
                true ->
                    NewRoleAttr = t_deduct_silver(RoleAttr,12000,?CONSUME_TYPE_SILVER_PET_FORGET_SKILL),
                    mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                    db:write(?DB_PET,NewPetInfo,write),
                    {ok,NewPetInfo,NewRoleAttr};
                false ->
                    db:abort(?_LANG_NOT_ENOUGH_SILVER)
            end
    end.


do_pet_forget_skill_error(Unique, RoleID, Line, Reason) ->
    %%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_forget_skill_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FORGET_SKILL, Record).


do_pet_change_pos(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_change_pos_tos{pet_id=PetID,pos=DestPos} = DataIn,
    case db:dirty_read(?DB_ROLE_PET_BAG,RoleID) of
        [] ->
            do_pet_change_pos_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR,undefined);
        [BagInfo] ->
            #p_role_pet_bag{pets=Pets} = BagInfo,
            case DestPos < 0 orelse DestPos >= length(Pets) of
                true ->
                    do_pet_change_pos_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR,BagInfo);
                false ->
                    case lists:keyfind(PetID, #p_pet_id_name.pet_id, Pets) of
                        false ->
                            do_pet_change_pos_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR,BagInfo);
                        #p_pet_id_name{index=OldPos} ->
                            NewPets = lists:foldr(
                                        fun(IDName,Acc) ->
                                                CurPos = IDName#p_pet_id_name.index,
                                                NewPos = get_new_pos(CurPos,OldPos,DestPos),
                                                [IDName#p_pet_id_name{index=NewPos}|Acc]
                                        end, [], Pets),
                            NewBagInfo = BagInfo#p_role_pet_bag{pets=NewPets},
                            db:dirty_write(?DB_ROLE_PET_BAG,NewBagInfo),
                            Record = #m_pet_change_pos_toc{succ=true, info=NewBagInfo},
                            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_CHANGE_POS, Record)
                    end
            end
    end,
    ok.

get_new_pos(CurPos,OldPos,DestPos) when OldPos > DestPos ->
    get_new_pos_up(CurPos,OldPos,DestPos);
get_new_pos(CurPos,OldPos,DestPos) when OldPos =:= DestPos ->
    CurPos;
get_new_pos(CurPos,OldPos,DestPos) when OldPos < DestPos ->
    get_new_pos_down(CurPos,OldPos,DestPos).


get_new_pos_up(CurPos,OldPos,DestPos) when CurPos =:= OldPos->
    DestPos;
get_new_pos_up(CurPos,OldPos,_DestPos) when CurPos > OldPos ->
    CurPos;
get_new_pos_up(CurPos,_OldPos,DestPos) when CurPos < DestPos ->
    CurPos;
get_new_pos_up(CurPos,OldPos,DestPos) when CurPos >= DestPos andalso CurPos < OldPos ->
    CurPos + 1.

get_new_pos_down(CurPos,OldPos,DestPos) when CurPos =:= OldPos->
    DestPos;
get_new_pos_down(CurPos,OldPos,_DestPos) when CurPos < OldPos ->
    CurPos;
get_new_pos_down(CurPos,_OldPos,DestPos) when CurPos > DestPos ->
    CurPos;
get_new_pos_down(CurPos,OldPos,DestPos) when CurPos =< DestPos andalso CurPos > OldPos ->
    CurPos - 1.


do_pet_change_pos_error(Unique, RoleID, Line, Reason, BagInfo) ->
    Record = #m_pet_change_pos_toc{succ=false, reason=Reason, info=BagInfo},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_CHANGE_POS, Record).
%% 宠物退役  擦..
do_pet_refining(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_refining_tos{pet_id=PetID} = DataIn,
    case erlang:get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        PetID ->
            do_pet_refining_error(Unique, RoleID, Line, ?_LANG_PET_SUMMONED_CAN_NOT_REFINING, undefined);
        _ ->
            Fun = fun() -> refining(PetID,RoleID) end,
            case db:transaction(Fun) of
                {aborted, {bag_error,not_enough_pos}} ->
                    do_pet_refining_error(Unique, RoleID, Line, ?_LANG_GOODS_BAG_NOT_ENOUGH, undefined);
                {aborted, Reason} ->
                    do_pet_refining_error(Unique, RoleID, Line, Reason, undefined);
                {atomic, {ok, GoodsInfo,NewPetBagInfo,NewRoleAttr,OldPetInfo}} ->
                    write_pet_action_log(OldPetInfo,RoleID,?PET_ACTION_TYPE_REFINING,"宠物炼制",0,""),
                    %% 通知客户端角色属性变动 
                    ChangeList = [
                                  #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=NewRoleAttr#p_role_attr.silver},
                                  #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.silver_bind}],
                    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList),
                    
                    %% 通知客户端物品变动
                    common_item_logger:log(RoleID,GoodsInfo,1,?LOG_ITEM_TYPE_PET_REFINING_HUO_DE),
                    common_misc:update_goods_notify({line, Line, RoleID}, GoodsInfo),
                    
                     Record = #m_pet_refining_toc{succ=true, info=NewPetBagInfo},
                    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_REFINING, Record)
            end
    end.


refining(PetID,RoleID) ->
    case db:read(?DB_PET,PetID) of
        [] ->
            db:abort(?_LANG_PET_NOT_EXIST);
        [PetInfo] ->
            case PetInfo#p_pet.role_id =:= RoleID of
                true ->
                    NeedSilver = get_refining_silver(PetInfo#p_pet.level),
                    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                    #p_role_attr{silver_bind = BindSilver,silver = Silver} = RoleAttr,
                    case BindSilver + Silver >= NeedSilver of 
                        true ->
                            NewRoleAttr = t_deduct_silver(RoleAttr,NeedSilver,?CONSUME_TYPE_SILVER_PET_REFINING),
                            mod_map_role:set_role_attr(RoleID, NewRoleAttr);
                        false ->
                            NewRoleAttr = RoleAttr,
                            db:abort(?_LANG_NOT_ENOUGH_SILVER)
                    end;
                false ->
                    NewRoleAttr = undefined,
                    db:abort(?_LANG_PET_NOT_EXIST)
            end,
            case mod_pet_training:check_pet_is_training(RoleID,PetID) of
                true->
                    db:abort(?_LANG_PET_ALREADLY_FEEDED);
                false->
                    ignore
            end,
            
%%             case PetInfo#p_pet.state =:= ?PET_FEED_STATE of
%%                         true ->
%%                             db:abort(?_LANG_PET_ALREADLY_FEEDED);
%%                         false ->
%%                             ignore
%%                     end,
            [BagInfo] = db:read(?DB_ROLE_PET_BAG,RoleID),
            Pets = BagInfo#p_role_pet_bag.pets,
            NewPets = lists:foldr(
                        fun(IDName,Acc) -> 
                                case IDName#p_pet_id_name.pet_id =:= PetID of
                                    true ->
                                        Acc;
                                    false ->
                                        [IDName|Acc]
                                end
                        end,[],Pets),
            {NewPets2,_} = lists:foldr(
                             fun(PetIDName,{Acc2,Acc3}) ->
                                     {[PetIDName#p_pet_id_name{index=Acc3-1}|Acc2],Acc3-1}
                             end, {[],length(NewPets)}, NewPets),
            {Exp1,Exp2} = get_refining_exp(PetInfo),
            CreateInfo = #r_goods_create_info{bind=false, type=?TYPE_ITEM, type_id=12300135, num=1},
            {ok,[GoodsInfo]} = mod_bag:create_goods(RoleID,CreateInfo),
        
            %%特殊处理，level表示高于1000000000的部分，quality表示小与1000000000的部分
            NewGoodsInfo = GoodsInfo#p_goods{level=Exp1,quality=Exp2},
            {ok,_} = mod_bag:update_goods(RoleID,NewGoodsInfo),
            db:write(?DB_ROLE_PET_BAG,BagInfo#p_role_pet_bag{pets=NewPets2},write),
            db:delete(?DB_PET,PetID,write),
            {ok,NewGoodsInfo,BagInfo#p_role_pet_bag{pets=NewPets2},NewRoleAttr,PetInfo}
    end.

%%获取宠物
get_refining_silver(Level) ->
    trunc(math:pow(Level,1.5)*10).

get_refining_exp(PetInfo) ->
    ReExp = get_refining_exp_2(PetInfo),
    {trunc(ReExp/1000000000),ReExp rem 1000000000}.

get_refining_exp_2(PetInfo) ->
     #p_pet{level=Level, exp=Exp, understanding=UnderStanding,max_hp_aptitude=HPAptitude, phy_defence_aptitude=PDAptitude, magic_defence_aptitude=MDAptitude,
           phy_attack_aptitude=PAAptitude, magic_attack_aptitude=MAAptitude, double_attack_aptitude=DoubleAptitude}  = PetInfo,
    List = [HPAptitude, PDAptitude, MDAptitude, PAAptitude, MAAptitude, DoubleAptitude],
    MaxAptitude = lists:max(List) + get_understanding_add_rate(UnderStanding),
    [#pet_level{total_exp=TotalExp}] = common_config_dyn:find(pet_level,Level),
    TotalExp2 = TotalExp + Exp,
    ReExp = trunc(TotalExp2 * math:pow(160/Level,0.25) * math:pow(MaxAptitude/100000,0.65)),
     case ReExp > 0 of
         true ->
             ReExp;
         false ->
             1
     end.


do_pet_refining_error(Unique, RoleID, Line, Reason, BagInfo) ->
    Record = #m_pet_refining_toc{succ=false, reason=Reason, info=BagInfo},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_REFINING, Record).
     

do_pet_refining_exp(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_refining_exp_tos{pet_id=PetID} = DataIn,
    case get({?ROLE_PET_INFO,PetID}) of
        undefined ->
            case db:dirty_read(?DB_PET,PetID) of
                [] ->
                    do_pet_refining_exp_error(Unique, RoleID, Line, ?_LANG_PET_NOT_EXIST);
                [PetInfo] ->
                    do_pet_refining_exp_2(PetInfo,PetID,RoleID,Line,Unique)
            end;
        PetInfo ->
             do_pet_refining_exp_2(PetInfo,PetID,RoleID,Line,Unique)
    end.


do_pet_refining_exp_2(PetInfo,PetID,RoleID,Line,Unique) ->
    Exp = get_refining_exp_2(PetInfo),
    Silver = get_refining_silver(PetInfo#p_pet.level),
    Record = #m_pet_refining_exp_toc{succ=true, pet_id=PetID,pet_name=PetInfo#p_pet.pet_name,pet_color=PetInfo#p_pet.color,
                                     silver=Silver,exp=Exp},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_REFINING_EXP, Record).

do_pet_refining_exp_error(Unique, RoleID, Line, Reason) ->
    Record = #m_pet_refining_exp_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_REFINING_EXP, Record).

%%神宠蛋。。。挺蛋疼的名字
-define(ITEM_PET_EGG,12300139).
do_pet_egg_use(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_egg_use_tos{goods_id=GoodsID} = DataIn,
    case mod_bag:get_goods_by_id(RoleID,GoodsID) of
        {error,_} ->
            do_pet_egg_use_error(Unique, RoleID, Line, ?_LANG_PET_EGG_ITEM_NOT_EXIST);
        {ok,GoodsInfo} ->
            case GoodsInfo#p_goods.typeid =:= ?ITEM_PET_EGG of
                true ->
                    Now = common_tool:now(),
                    EggLeftTick = GoodsInfo#p_goods.end_time-Now,
                    %EggLeftTick = 60 * 60 * 15,
                    case EggLeftTick > 0 of
                        true ->
                            Fun = fun() -> egg_use(RoleID) end,
                            case db:transaction(Fun) of
                                {aborted, Reason} ->
                                    do_pet_egg_use_error(Unique, RoleID, Line, Reason);
                                {atomic, {ok, TypeList,Tick}} ->
                                    Record = #m_pet_egg_use_toc{succ=true, type_id_list=TypeList,refresh_tick=Tick,goods_id=GoodsID,egg_left_tick=EggLeftTick},
                                    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_EGG_USE, Record)
                            end;
                        false ->
                            do_pet_egg_use_error(Unique, RoleID, Line, ?_LANG_PET_EGG_OUT_OF_USE_TIME)
                    end;
                false ->
                    do_pet_egg_use_error(Unique, RoleID, Line, ?_LANG_PET_EGG_ITEM_NOT_EXIST)
            end
    end.


egg_use(RoleID) ->
    case db:read(?DB_PET_EGG,RoleID,read) of
        [] ->
            List = get_normal_typeid_list(),
            Info = #p_role_pet_egg_type_list{role_id=RoleID,type_id_list=List},
            db:write(?DB_PET_EGG,Info,write),
            {H,M,S} = erlang:time(),
            Tick = 7200 - (H rem 2) * 3600 - M * 60 - S,
            {ok,List,Tick};
        [#p_role_pet_egg_type_list{refresh_num=RefreshNum,type_id_list=List}] -> 
            case RefreshNum > 0 of
                true ->
                    {ok,List,0};
                false ->
                    {H,M,S} = erlang:time(),
                    Tick = 7200 - (H rem 2) * 3600 - M * 60 - S,
                    {ok,List,Tick}
            end
    end.


%%获取普通的宠物的列表
get_normal_typeid_list() ->
    case common_config_dyn:find(pet_etc,pet_egg_normal) of
        [{TotalRate,TypeList}] ->
            get_typeid_list(TotalRate,TypeList);
        _ ->
            db:abort(?_LANG_PET_EGG_CONFIG_FILE_ERROR)
    end.


%%获取用元宝刷新的宠物的列表
get_use_gold_typeid_list(Num) ->
    RandomType = get_random_type_by_refresh_num(Num),
    case common_config_dyn:find(pet_etc,{pet_egg_use_gold,RandomType}) of
        [{TotalRate,TypeList}] ->
            get_typeid_list(TotalRate,TypeList);
        _ ->
            db:abort(?_LANG_PET_EGG_CONFIG_FILE_ERROR)
    end.


get_random_type_by_refresh_num(Num) when Num =< 5 ->
    1;
get_random_type_by_refresh_num(Num) when Num =< 15 ->
    2;
get_random_type_by_refresh_num(Num) when Num =< 30 ->
    3;
get_random_type_by_refresh_num(Num) when Num =< 45 ->
    4;
get_random_type_by_refresh_num(Num) when Num =< 60 ->
    5;
get_random_type_by_refresh_num(_Num)  ->
    6.


get_typeid_list(TotalRate,TypeList) ->
    RateList = lists:map(fun(_) -> random:uniform(TotalRate) end, [1,2,3,4]),
    lists:map(
      fun(Rate) -> 
              Ret = lists:foldl(
                      fun({TypeID,R},{Flag,Acc}) ->
                              case Flag of
                                  false ->
                                      case Rate =< R+Acc of
                                          true ->
                                              {true,TypeID};
                                          false ->
                                              {false,R+Acc}
                                      end;
                                  true ->
                                      {true,Acc}
                              end
                      end, {false,0}, TypeList),
              case Ret of
                  {false,_} ->
                      db:abort(?_LANG_PET_EGG_CONFIG_FILE_ERROR);
                  {true,ID} ->
                      ID
              end
      end,RateList).


do_pet_egg_use_error(Unique, RoleID, Line, Reason) ->
    Record = #m_pet_egg_use_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_EGG_USE, Record).

do_pet_egg_refresh(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_egg_refresh_tos{goods_id=GoodsID} = DataIn,
    case mod_bag:get_goods_by_id(RoleID,GoodsID) of
        {error,_} ->
            do_pet_egg_refresh_error(Unique, RoleID, Line, ?_LANG_PET_EGG_ITEM_NOT_EXIST);
        {ok,GoodsInfo} ->
            case GoodsInfo#p_goods.typeid =:= ?ITEM_PET_EGG of
                true ->
                    Now = common_tool:now(),
                    EggLeftTick = GoodsInfo#p_goods.end_time-Now,
                    %EggLeftTick = 60 * 60 * 15,
                    case EggLeftTick > 0 of
                        true ->
                            Fun = fun() -> egg_refresh(RoleID) end,
                            case db:transaction(Fun) of
                                {aborted, Reason} ->
                                    do_pet_egg_use_error(Unique, RoleID, Line, Reason);
                                {atomic,  {ok,List,NewRoleAttr}} ->
                                    Record = #m_pet_egg_refresh_toc{succ=true, type_id_list=List, goods_id=GoodsID, egg_left_tick=EggLeftTick},
                                    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_EGG_REFRESH, Record),
                                    
                                    ChangeList = [
                                                  #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=NewRoleAttr#p_role_attr.gold},
                                                  #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.gold_bind}],
                                    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList)
                            end;
                        false ->
                            do_pet_egg_refresh_error(Unique, RoleID, Line, ?_LANG_PET_EGG_OUT_OF_USE_TIME)
                    end;
                false ->
                    do_pet_egg_refresh_error(Unique, RoleID, Line, ?_LANG_PET_EGG_ITEM_NOT_EXIST)
            end        
    end.


-define(PET_EGG_REFRESH_GOLD,10).
egg_refresh(RoleID) -> 
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{gold_bind = BindGold, gold = Gold} = RoleAttr,
    case BindGold + Gold >= ?PET_EGG_REFRESH_GOLD of
        false ->
            db:abort(?_LANG_NOT_ENOUGH_GOLD);
        true ->
            case db:read(?DB_PET_EGG,RoleID,read) of
                [] ->
                    db:abort(?_LANG_SYSTEM_ERROR);
                [#p_role_pet_egg_type_list{refresh_num=RefreshNum}=Info] -> 
                     List = get_use_gold_typeid_list(RefreshNum),
                     db:write(?DB_PET_EGG,Info#p_role_pet_egg_type_list{refresh_num=RefreshNum+1,type_id_list=List},write),
                     {NewRoleAttr,_,_} = mod_pet_feed:t_deduct_gold(RoleAttr,?PET_EGG_REFRESH_GOLD,?CONSUME_TYPE_GOLD_PET_EGG_REFRESH),  
                     mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                     {ok,List,NewRoleAttr}
            end
    end.

do_pet_egg_refresh_error(Unique, RoleID, Line, Reason) ->
    Record = #m_pet_egg_refresh_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_EGG_REFRESH, Record).

do_pet_egg_adopt(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_egg_adopt_tos{type_id=PetTypeID,goods_id=GoodsID} = DataIn,
    case mod_bag:get_goods_by_id(RoleID,GoodsID) of
        {error,_} ->
            do_pet_egg_adopt_error(Unique, RoleID, Line, ?_LANG_PET_EGG_ITEM_NOT_EXIST,PetTypeID);
        {ok,GoodsInfo} ->
            case GoodsInfo#p_goods.typeid =:= ?ITEM_PET_EGG of
                true ->
                    Now = common_tool:now(),
                    EggLeftTick = GoodsInfo#p_goods.end_time-Now,
                    %EggLeftTick = 60 * 60 * 15,
                    case EggLeftTick > 0 of
                        true ->
                            Fun = fun() ->
                                          case db:read(?DB_PET_EGG,RoleID,read) of
                                              [] ->
                                                  db:abort(?_LANG_PET_EGG_NO_PET_IN_TYPE);
                                              [#p_role_pet_egg_type_list{type_id_list=List}] ->
                                                  case lists:member(PetTypeID, List) of
                                                      false ->
                                                          db:abort(?_LANG_PET_EGG_NO_PET_IN_TYPE);
                                                      true ->
                                                          db:delete(?DB_PET_EGG,RoleID,write)
                                                  end
                                          end,
                                          {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                                          #p_role_attr{level = RoleLevel} = RoleAttr,
                                          {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
                                          #p_role_base{faction_id=RoleFaction,role_name=RoleName} = RoleBase,
                                          case get_new_pet(RoleID,PetTypeID,RoleLevel,RoleName,false,RoleFaction) of
                                              {error,R} ->
                                                  db:abort(R);
                                              _ ->
                                                  ignore
                                          end,
                                          mod_bag:delete_goods(RoleID,GoodsID)
                                  end,
                            case db:transaction(Fun) of
                                {aborted, Reason} ->
                                    do_pet_egg_use_error(Unique, RoleID, Line, Reason);
                                {atomic,   {ok, [OldGoodsInfo] }} ->
                                    Record = #m_pet_egg_adopt_toc{succ=true, type_id=PetTypeID},
                                    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_EGG_ADOPT, Record),
                                    
                                    %% 通知客户端物品变动
                                    common_item_logger:log(RoleID,OldGoodsInfo,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                                    common_misc:del_goods_notify({line, Line, RoleID}, OldGoodsInfo)
                            end;
                        false ->
                            do_pet_egg_adopt_error(Unique, RoleID, Line, ?_LANG_PET_EGG_OUT_OF_USE_TIME,PetTypeID)
                    end;
                false ->
                    do_pet_egg_adopt_error(Unique, RoleID, Line, ?_LANG_PET_EGG_ITEM_NOT_EXIST,PetTypeID)
            end             
    end.

do_pet_egg_adopt_error(Unique, RoleID, Line, Reason, TypeID) ->
    Record = #m_pet_egg_adopt_toc{succ=false, reason=Reason, type_id=TypeID},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_EGG_ADOPT, Record).


%%宠物学习新的特技
-define(PET_TRICK_LEARN_SILVER,10000).
do_pet_trick_learn(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_trick_learn_tos{pet_id=PetID,type=LearnType} = DataIn,
    Fun = 
        fun() ->   
                {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                #p_role_attr{silver_bind = BindSilver, silver = Silver} = RoleAttr,
                case common_config_dyn:find(pet_etc,{pet_trick_level,LearnType}) of
                    [] ->
                        NeedLevel = 200,
                        db:abort(?_LANG_PET_TRICK_CONFIG_FILE_ERROR);
                    [NeedLevel2] ->
                        NeedLevel = NeedLevel2
                end,
                case erlang:get({?ROLE_SUMMONED_PET_ID,RoleID}) of
                    PetID ->
                        PetInfo = get({?ROLE_PET_INFO,PetID}), 
                        Skills = PetInfo#p_pet.skills,
                        Skills2 = lists:keydelete(LearnType, #p_pet_skill.skill_type, Skills),
                        SkillID = get_new_trick_skill(LearnType),
                        Skills3 = lists:append(Skills2,[#p_pet_skill{skill_id=SkillID,skill_type=LearnType}]),
                        NewPetInfo = PetInfo#p_pet{skills=Skills3}, 
                        case PetInfo#p_pet.level >= NeedLevel of
                            true ->
                                case BindSilver + Silver >= ?PET_TRICK_LEARN_SILVER of 
                                    false ->
                                        db:abort(?_LANG_NOT_ENOUGH_SILVER);
                                    true ->
                                        NewRoleAttr = t_deduct_silver(RoleAttr,?PET_TRICK_LEARN_SILVER,?CONSUME_TYPE_SILVER_PET_TRICK_LEARN),
                                        mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                                        put({?ROLE_PET_INFO,PetID},NewPetInfo),
                                        {ok,NewPetInfo,NewRoleAttr,SkillID}
                                end;
                            false ->
                                db:abort(?_LANG_PET_TRICK_LEARN_ROLE_LEVELL_NOE_ENOUGH)
                        end;
                    _ ->
                        case db:read(?DB_PET,PetID) of
                            [] ->
                                db:abort(?_LANG_PET_NOT_EXIST);
                            [PetInfo] ->
                                Skills = PetInfo#p_pet.skills,
                                Skills2 = lists:keydelete(LearnType, #p_pet_skill.skill_type, Skills),
                                SkillID = get_new_trick_skill(LearnType),
                                Skills3 = lists:append(Skills2,[#p_pet_skill{skill_id=SkillID,skill_type=LearnType}]),
                                NewPetInfo = PetInfo#p_pet{skills=Skills3}, 
                                case PetInfo#p_pet.level >= NeedLevel of
                                    true ->
                                        case BindSilver + Silver >= ?PET_TRICK_LEARN_SILVER of 
                                            false ->
                                                db:abort(?_LANG_NOT_ENOUGH_SILVER);
                                            true ->
                                                NewRoleAttr = t_deduct_silver(RoleAttr,?PET_TRICK_LEARN_SILVER,?CONSUME_TYPE_SILVER_PET_TRICK_LEARN),
                                                mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                                                db:write(?DB_PET,NewPetInfo,write),
                                                {ok,NewPetInfo,NewRoleAttr,SkillID}
                                        end;
                                    false ->
                                        db:abort(?_LANG_PET_TRICK_LEARN_ROLE_LEVELL_NOE_ENOUGH)
                                end
                        end
                end
        end, 
    case db:transaction(Fun) of
        {aborted, Reason} ->
            do_pet_trick_learn_error(Unique, RoleID, Line, Reason);
        {atomic, {ok, NewPetInfo,NewRoleAttr,SkillID}} ->
            write_pet_action_log(NewPetInfo,RoleID,?PET_ACTION_TYPE_ADD_SKILL_GRID,"宠物学习特殊技能",SkillID,""),
            DataRecord = #m_pet_trick_learn_toc{succ=true,pet_info=NewPetInfo}, 
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_TRICK_LEARN, DataRecord),
            ChangeList = [
                          #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=NewRoleAttr#p_role_attr.silver},
                          #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.silver_bind}],
            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList)
    end.


%%获取宠物新特技的技能ID
get_new_trick_skill(LearnType) ->
    case common_config_dyn:find(pet_etc,{pet_trick_type,LearnType}) of
        [{TotalRate,SkillList}] ->
            Rate = random:uniform(TotalRate),
            Ret = lists:foldl(
                    fun({SkillID,R},{Flag,Acc}) ->
                            case Flag of
                                false ->
                                    case Rate =< R+Acc of
                                        true ->
                                            {true,SkillID};
                                        false ->
                                            {false,R+Acc}
                                    end;
                                true ->
                                    {true,Acc}
                            end
                    end, {false,0}, SkillList),
            case Ret of
                {false,_} ->
                    db:abort(?_LANG_PET_TRICK_CONFIG_FILE_ERROR);
                {true,ID} ->
                    ID
            end;
        _ ->
            db:abort(?_LANG_PET_TRICK_CONFIG_FILE_ERROR)
    end.
   


do_pet_trick_learn_error(Unique, RoleID, Line, Reason) ->
    Record = #m_pet_trick_learn_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_TRICK_LEARN, Record).


%%宠物升级特技
do_pet_trick_upgrade(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_trick_upgrade_tos{pet_id=PetID,skill_id=SkillID} = DataIn,
    Fun = 
        fun() ->   
                case erlang:get({?ROLE_SUMMONED_PET_ID,RoleID}) of
                    PetID ->
                        PetInfo = get({?ROLE_PET_INFO,PetID}), 
                        Skills = PetInfo#p_pet.skills,
                        case lists:keyfind(SkillID, #p_pet_skill.skill_id, Skills) of
                            false ->
                                db:abort(?_LANG_PET_TRICK_UPGRADE_SKILL_NOT_LEARN); 
                            Skill ->
                                Level = Skill#p_pet_skill.skill_level + 1,
                                case  mod_skill_manager:get_skill_level_info(SkillID, Level) of
                                    {ok,_} ->
                                        Skills3 = lists:keyreplace(SkillID, #p_pet_skill.skill_id, Skills, Skill#p_pet_skill{skill_level=Level}),
                                        NewPetInfo = PetInfo#p_pet{skills=Skills3}, 
                                        [NeedItem] = common_config_dyn:find(pet_etc,{pet_trick_upgrade_item,Level}),
                                        {ok, ChangeList, DelList} = t_deduct_item(NeedItem,RoleID),
                                        put({?ROLE_PET_INFO,PetID},NewPetInfo),
                                        {ok,NewPetInfo,SkillID,ChangeList, DelList};
                                    _ ->
                                        db:abort(?_LANG_PET_TRICK_SKILL_LEVEL_FULL)
                                end
                        end;
                    _ ->
                        case db:read(?DB_PET,PetID) of
                            [] ->
                                db:abort(?_LANG_PET_NOT_EXIST);
                            [PetInfo] ->
                                Skills = PetInfo#p_pet.skills,
                                case lists:keyfind(SkillID, #p_pet_skill.skill_id, Skills) of
                                    false ->
                                        db:abort(?_LANG_PET_TRICK_UPGRADE_SKILL_NOT_LEARN);
                                    Skill ->
                                        Level = Skill#p_pet_skill.skill_level + 1,
                                        case  mod_skill_manager:get_skill_level_info(SkillID, Level) of
                                            {ok,_} ->
                                                Skills3 = lists:keyreplace(SkillID, #p_pet_skill.skill_id, Skills, Skill#p_pet_skill{skill_level=Level}),
                                                NewPetInfo = PetInfo#p_pet{skills=Skills3}, 
                                                [NeedItem] = common_config_dyn:find(pet_etc,{pet_trick_upgrade_item,Level}),
                                                {ok, ChangeList, DelList} = t_deduct_item(NeedItem,RoleID),
                                                db:write(?DB_PET,NewPetInfo,write),
                                                {ok,NewPetInfo,SkillID,ChangeList, DelList};
                                            _ ->
                                                db:abort(?_LANG_PET_TRICK_SKILL_LEVEL_FULL)
                                        end
                                end
                        end
                end
        end, 
    case db:transaction(Fun) of
        {aborted, Reason} ->
            do_pet_trick_upgrade_error(Unique, RoleID, Line, Reason);
        {atomic, {ok, NewPetInfo,SkillID,ChangeList, DelList}} ->
            write_pet_action_log(NewPetInfo,RoleID,?PET_ACTION_TYPE_TRICK_UPGRADE,"宠物升级特殊技能",SkillID,""),
            DataRecord = #m_pet_trick_upgrade_toc{succ=true,pet_info=NewPetInfo}, 
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_TRICK_UPGRADE, DataRecord),
            
            %% 通知客户端物品变动
            case ChangeList of
                [] ->
                    ignore;
                [Goods] ->
                    common_item_logger:log(RoleID,Goods,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                    common_misc:update_goods_notify({line, Line, RoleID}, Goods)
            end,
            
            case DelList of
                [] ->
                    ignore;
                [Goods2] ->
                    common_item_logger:log(RoleID,Goods2,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                    common_misc:del_goods_notify({line, Line, RoleID}, Goods2)
            end
    end.


do_pet_trick_upgrade_error(Unique, RoleID, Line, Reason) ->
    Record = #m_pet_trick_upgrade_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_TRICK_UPGRADE, Record).


%%每两个小时刷新一次宠物蛋的宠物类型
random_pet_egg() ->
    MapID = mgeem_map:get_mapid(),
    case MapID of
        10210 ->
            {H,M,S} = erlang:time(),
            case (H rem 2) == 0 andalso M == 0 andalso S == 0 of
                true ->
                    Fun = fun()-> 
                                  List = get_normal_typeid_list(),
                                  RoleIDList = db:all_keys(?DB_PET_EGG),
                                  lists:map(
                                    fun(RoleID) ->
                                            [Info] = db:read(?DB_PET_EGG,RoleID),
                                            case Info#p_role_pet_egg_type_list.refresh_num == 0 of
                                                true ->
                                                    Record = #m_pet_egg_use_toc{succ=true, type_id_list=List,refresh_tick=7200},
                                                    common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_EGG_USE, Record),
                                                    db:write(?DB_PET_EGG,Info#p_role_pet_egg_type_list{type_id_list=List},write);
                                                false ->
                                                    ignore
                                            end
                                    end,RoleIDList)
                          end,
                    db:transaction(Fun);
                false ->
                    ignore
            end;
        _ ->
            ignore
    end.

do_add_exp(RoleID,AddExp,IsNotice) ->
    case catch do_add_exp2(RoleID,AddExp,IsNotice) of
        {error,Reason} ->
            {error,Reason};
        {ok,NewPetInfo,NoticeType} ->
            {ok,NewPetInfo,NoticeType}
    end.
do_add_exp2(RoleID,AddExp,IsNotice) ->
    {PetID,PetInfo} = 
        case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
            undefined ->
                erlang:throw({error,?_LANG_PET_NOT_SUMMONED});
            PetIDT ->
                {PetIDT,get({?ROLE_PET_INFO,PetIDT})}
        end,
    Exp = PetInfo#p_pet.exp,
    Level = PetInfo#p_pet.level,
    NewExp = Exp + AddExp,
            % TypeID = PetInfo#p_pet.type_id,
    LevelExpInfo = 
        case common_config_dyn:find(pet_level,Level) of
            [] ->
                erlang:throw({error,?_LANG_PET_CONFIG_ERROR});
            [LevelExpInfoT] ->
                LevelExpInfoT
        end,
    NextLevelExp = LevelExpInfo#pet_level.next_level_exp,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    RoleLevel = RoleAttr#p_role_attr.level,
    case NewExp >= NextLevelExp of
        true ->
            case Level < RoleLevel of
                true ->
                    NewPetInfo = level_up(NewExp,Level,PetInfo,RoleLevel),
                    NewPetInfo2 = auto_add_pet_remain_point(NewPetInfo),
                    NewPetInfo3 = calc_pet_attr(NewPetInfo2),
                    MaxHp = NewPetInfo3#p_pet.max_hp,
                    NewLevel = NewPetInfo3#p_pet.level,
                    NewPetInfo4 = NewPetInfo3#p_pet{hp=MaxHp},
                    MapInfo = mod_map_actor:get_actor_mapinfo(PetID,pet),
                    mod_map_actor:set_actor_mapinfo(PetID,pet,MapInfo#p_map_pet{hp=MaxHp,max_hp=MaxHp,level=NewLevel}),
                    put({?ROLE_PET_INFO,PetID},NewPetInfo4),
                    NoticeType = levelup,
                    ok;
                _ ->
                    case Exp >= NextLevelExp of
                        true ->
                            NewPetInfo4 = PetInfo,NoticeType = undefined,
                            erlang:throw({error,?_LANG_PET_ADD_EXP_FAIL_HP_FULL});
                        _ ->
                            NewPetInfo4 = PetInfo#p_pet{exp=NextLevelExp},
                            put({?ROLE_PET_INFO,PetID},NewPetInfo4),
                            NoticeType = attrchange
                    end
            end;
        _ ->
            NewPetInfo4 = PetInfo#p_pet{exp=NewExp},
            put({?ROLE_PET_INFO,PetID},NewPetInfo4),
            NoticeType = attrchange
    end,
    case IsNotice of
        true ->
            case NoticeType of
                levelup ->
                    common_mod_goal:hook_pet_level_up(RoleID, NewPetInfo4#p_pet.level),
                    Record = #m_pet_level_up_toc{pet_info=NewPetInfo4},
                    common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_LEVEL_UP, Record);
                attrchange ->
                    Record = #m_pet_attr_change_toc{pet_id=PetID,change_type=?PET_EXP_CHANGE,value=NewPetInfo4#p_pet.exp},
                    common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_ATTR_CHANGE, Record);
                _ ->
                    ignore
            end;
        _ ->
            ignore
    end,
    {ok,NewPetInfo4,NoticeType}.


%%宠物升级
level_up(Exp, Level, PetInfo,RoleLevel) ->
    [LevelExpInfo] = common_config_dyn:find(pet_level,Level),
    NextLevelExp = LevelExpInfo#pet_level.next_level_exp,
    case Exp >= NextLevelExp of
        true ->
            case Level < RoleLevel of
                true ->
                    RemainPoints = PetInfo#p_pet.remain_attr_points,
                    case Level < 50 of
                        true ->
                            NewRemainPoints = RemainPoints + 3;
                        false ->
                             NewRemainPoints = RemainPoints + 4
                    end,
                    level_up(Exp-NextLevelExp,Level+1,PetInfo#p_pet{remain_attr_points=NewRemainPoints},RoleLevel);
                false ->
                    PetInfo#p_pet{exp=NextLevelExp,level=Level,next_level_exp=NextLevelExp}
            end;
        false ->
             PetInfo#p_pet{exp=Exp,level=Level,next_level_exp=NextLevelExp}
    end.
            

get_new_pet(RoleID,TypeID,RoleLevel,RoleName,Bind,RoleFaction) ->
    case common_config_dyn:find(pet, TypeID) of
        [] ->
            %%%%%%?ERROR_MSG("1111111111111  ~w",[TypeID]),
            {error,?_LANG_PET_CONFIG_ERROR};
        [BaseInfo] ->
            case BaseInfo#p_pet_base_info.carry_level > RoleLevel of
                true ->
                     %%%%%%?ERROR_MSG("222222222222222",[]),
                    {error,?_LANG_ROLE_LEVEL_NOT_ENOUGH_TO_GET_PET};
                false ->
                    case db:read(?DB_ROLE_PET_BAG,RoleID,read) of
                        [] ->
                             %%%%%%?ERROR_MSG("33333333333333",[]),
                            NewPetBaseInfo = #p_role_pet_bag{content=?DEFAULT_PET_BAG_CONTENT,role_id=RoleID,pets=[]},
                            get_new_pet_2(RoleID,BaseInfo,NewPetBaseInfo,[],RoleName,Bind,RoleLevel,RoleFaction);
                        [PetBagInfo] ->
                             %%%%%%?ERROR_MSG("444444444444444",[]),
                            Content = PetBagInfo#p_role_pet_bag.content,
                            Pets = PetBagInfo#p_role_pet_bag.pets,
                            case length(Pets) < Content of
                                true ->
                                    get_new_pet_2(RoleID,BaseInfo,PetBagInfo,Pets,RoleName,Bind,RoleLevel,RoleFaction);
                                false ->
                                    {error,?_LANG_PET_BAG_NOT_ENOUGH}
                            end
                    end
            end
    end.


get_new_pet_2(RoleID,BaseInfo,PetBagInfo,Pets,RoleName,Bind,RoleLevel,RoleFaction) ->
    case init_pet_info(BaseInfo,RoleID,RoleName,Bind) of
        {ok,PetInfo} ->
            PetIDName=#p_pet_id_name{pet_id=PetInfo#p_pet.pet_id, name=PetInfo#p_pet.pet_name, color=PetInfo#p_pet.color,
                                     type_id=PetInfo#p_pet.type_id,index=length(Pets)},
            NewPets = lists:append(Pets,[PetIDName]),
            NewPetBagInfo = PetBagInfo#p_role_pet_bag{pets=NewPets},
            db:write(?DB_ROLE_PET_BAG,NewPetBagInfo,write),
            db:write(?DB_PET,PetInfo,write),
            Record = #m_pet_bag_info_toc{info=NewPetBagInfo},
            common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_BAG_INFO, Record),
            write_pet_get_log(PetInfo,RoleID,RoleFaction,RoleLevel,?PET_GET_TYPE_USE_ITEM,"使用宠物召唤符或者宠物蛋获得"),
            %%商店购买的宠物需要广播
            [List] = common_config_dyn:find(pet_etc,get_new_pet_broadcast),
            case lists:keyfind(PetInfo#p_pet.type_id, 1, List) of
                false ->
                    ignore;
                {_,shop_pet} ->
                    RGB = get_rgb_by_color(PetInfo#p_pet.color),
                    Content = io_lib:format(?_LANG_PET_ROLE_GET_NEW_PET, [RoleName,PetInfo#p_pet.pet_id,RGB,PetInfo#p_pet.pet_name]),
                    catch common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_WORLD,common_tool:to_list(Content));
                {_,egg_pet} ->
                    RGB = get_rgb_by_color(PetInfo#p_pet.color),
                    Content = io_lib:format(?_LANG_PET_ROLE_GET_EGG_PET, [RoleName,PetInfo#p_pet.pet_id,RGB,PetInfo#p_pet.pet_name]),
                    catch common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_WORLD,common_tool:to_list(Content))
            end,
            
            %% self() ! {mod_map_pet,{pet_color_goal,RoleID,PetInfo#p_pet.color}}, 
            
            ok;
        
        {error,Reason} ->
            %%%%%%?ERROR_MSG("66666666666  ~w",[Reason]),
            {error,Reason}
    end.


get_rgb_by_color(Color) ->
    case Color of
        2 ->
            "#00CC99";
        3 ->
            "#0d79ff";
        4 ->
            "#FE00E9";
        5 ->
            "#FF9000";
        6 ->
            "#FFFF00";
        _ ->
            "#FFFFFF"
    end.

    
%%获取宠物宝宝的初始化信息
init_pet_info(BaseInfo,RoleID,RoleName,Bind) ->
    #p_pet_base_info{
                     type_id = TypeID,
                     pet_name = Name,
                     attack_type = AttackType,
                     carry_level = CarryLevel
                     } = BaseInfo,
    [LevelExpInfo] = common_config_dyn:find(pet_level,1),
    NextLevelExp = LevelExpInfo#pet_level.next_level_exp,
    PetID = common_tool:t_new_id(pet),
    
    {HPAptitude, PDAptitude, MDAptitude, PAAptitude, MAAptitude, DoubleAptitude} = get_new_all_aptitudes(TypeID, AttackType),

    UnderStanding = ?DEFAULT_PET_UNDERSTANDING,
    {Color,Title} = get_pet_color_and_title(PAAptitude, MAAptitude, CarryLevel, UnderStanding),
    Sex = random:uniform(2),
    %Life = get_max_life_by_carry_level(CarryLevel),
    PetInfo = #p_pet{type_id=TypeID, role_id=RoleID, pet_id=PetID, pet_name=Name, role_name=RoleName,
                     level=1, exp=0, life=?DEFAULT_PET_LIFE, sex=Sex,attack_type=AttackType,
                     color=Color, period=1, understanding=UnderStanding,title=Title,
                     max_hp_aptitude=HPAptitude, phy_defence_aptitude=PDAptitude, magic_defence_aptitude=MDAptitude,
                     phy_attack_aptitude=PAAptitude, magic_attack_aptitude=MAAptitude, double_attack_aptitude=DoubleAptitude,
                     base_str=0, base_int2=0, base_con=0, base_dex=0, base_men=0,next_level_exp=NextLevelExp,
                     bind=Bind, remain_attr_points=3, buffs=[], skills=[]},
    NewPetInfo = calc_pet_attr(PetInfo),
    MaxHp = NewPetInfo#p_pet.max_hp,
    {ok,NewPetInfo#p_pet{hp=MaxHp}}.
    
%%根据宠物的变异等级，携带等级和攻击类型获取宠物所有的初始化资质
get_new_all_aptitudes(TypeID, AttackType) ->
    case AttackType of
        ?PET_ATTACK_TYPE_PHY ->
            PAAptitude = random_get_aptitude_by_type(TypeID,1),
            MAAptitude = trunc(PAAptitude/5) + 100 + random:uniform(200);
        ?PET_ATTACK_TYPE_MAGIC ->
            MAAptitude = random_get_aptitude_by_type(TypeID,1),
            PAAptitude = trunc(MAAptitude/5) + 100 + random:uniform(200)
    end,
    HPAptitude = random_get_aptitude_by_type(TypeID,1),
    PDAptitude = random_get_aptitude_by_type(TypeID,1),
    MDAptitude = random_get_aptitude_by_type(TypeID,1),
    DoubleAptitude = random_get_aptitude_by_type(TypeID,1),
     {HPAptitude, PDAptitude, MDAptitude, PAAptitude, MAAptitude, DoubleAptitude}.
    


%%根据宠物的携带等级和变异等级随机获取宠物单项资质    
random_get_aptitude_by_type(TypeID,Key) ->
    %%%%%%?ERROR_MSG("777777777777 ~w",[TypeID]),
    case common_config_dyn:find(pet_aptitude,{TypeID,Key})  of
        [] ->
            %%%%%%?ERROR_MSG("888888888888~w",[ TypeID]),
            500;
        [Info] ->
            TotalRate = Info#r_pet_aptitude_config.total_rate,
            Secions = Info#r_pet_aptitude_config.section_rates,
            Rate1 = random:uniform(TotalRate),
            Rate2 = lists:foldl(
                      fun(SecionInfo,Acc) ->
                              case Acc =:= undefined andalso SecionInfo#r_pet_section_rate.section_rate >= Rate1 of
                                  true ->
                                      Min = SecionInfo#r_pet_section_rate.min,
                                      Max = SecionInfo#r_pet_section_rate.max,
                                      random:uniform(Max-Min) + Min;
                                  false ->
                                      Acc
                              end
                      end, undefined, Secions),
            case Rate2 of
                undefined -> 500;
                _ -> Rate2
            end
    end.
                    

%% %%根据宠物的携带等级获取宠物最大寿命    
%% get_max_life_by_carry_level(5) ->
%%     5000;
%% get_max_life_by_carry_level(25) ->
%%     6000;
%% get_max_life_by_carry_level(50) ->
%%     7000;
%% get_max_life_by_carry_level(85) ->
%%     8000;
%% get_max_life_by_carry_level(105) ->
%%     1000.
            

%%根据宠物的资质和携带等级确定宠物的颜色
get_pet_color_and_title(StrAptitude, Int2Aptitude, _CarryLevel, UnderStanding) ->
    Rate = get_understanding_add_rate(UnderStanding),
    case StrAptitude > Int2Aptitude of
        true ->
            Aptitude = StrAptitude + Rate;
        false ->
            Aptitude = Int2Aptitude + Rate
    end,
    ColorPoint = Aptitude,
    [ColorPointTitleList] = common_config_dyn:find(title,{pet_title,color_point}),
    [UnderStandingTitleList] = common_config_dyn:find(title,{pet_title,under_standing}),
    case ColorPoint =< 1000 of
        true ->
            lists:keyfind(2,1,ColorPointTitleList);
        false ->
            case ColorPoint =< 1500 of
                true ->
                    lists:keyfind(3,1,ColorPointTitleList);
                false ->
                    case ColorPoint =< 2000 of
                        true ->
                            lists:keyfind(4,1,ColorPointTitleList);
                        false ->
                            case ColorPoint =< 3000 of
                                true ->
                                    lists:keyfind(5,1,ColorPointTitleList);
                                false ->
                                    case UnderStanding < 15 of
                                        true ->
                                            lists:keyfind(6,1,ColorPointTitleList);
                                        false ->
                                            lists:keyfind(6,1,UnderStandingTitleList)
                                    end
                            end
                    end
            end
    end.

%%根据宠物的悟性返回对资质的加成
get_understanding_add_rate(UnderStanding) ->
    case UnderStanding of
        0 -> 0;
        1 -> 50;
        2 -> 100;
        3 -> 150;
        4 -> 250;
        5 -> 350;
        6 -> 450;
        7 -> 600;
        8 -> 750;
        9 -> 900;
        10 ->1050;
        11 -> 1200;
        12 -> 1400;
        13 -> 1600;
        14 -> 1800;
        15 -> 2000;
        _ -> 0
    end.
            
       
%%计算宠物的总的一级战斗属性和对应的二级战斗属性
calc_pet_attr(RoleID) when is_integer(RoleID) ->
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        undefined ->
            ignore;
        PetID ->
            case get({?ROLE_PET_INFO,PetID}) of
                undefined ->
                    ignore;
                PetInfo ->
                    NewPetInfo = calc_pet_attr(PetInfo),
                    put({?ROLE_PET_INFO,PetID},NewPetInfo),
                    
                    PetRecord = #m_pet_info_toc{succ=true, pet_info=NewPetInfo},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_INFO, PetRecord),
                    case PetInfo#p_pet.max_hp =:= NewPetInfo#p_pet.max_hp of
                        true ->
                            ignore;
                        false ->
                            case mod_map_actor:get_actor_mapinfo(PetID,pet) of
                                undefined ->
                                    ignore;
                                MapPetinfo ->
                                    mod_map_actor:set_actor_mapinfo(PetID,pet,MapPetinfo#p_map_pet{max_hp=NewPetInfo#p_pet.max_hp})
                            end,
                            Record = #m_pet_attr_change_toc{pet_id=PetID,change_type=?PET_MAX_HP_CHANGE,value=NewPetInfo#p_pet.max_hp},
                            common_misc:unicast({role,RoleID},?DEFAULT_UNIQUE,?PET,?PET_ATTR_CHANGE,Record)
                    end
            end
    end;
calc_pet_attr(PetInfo) ->
    NewPetInfo = calc_pet_first_attr(PetInfo),
    NewPetInfo2 = mod_pet_grow:calc_pet_grow_add(NewPetInfo),
    calc_pet_second_attr(NewPetInfo2).


%%计算宠物的一级战斗属性
calc_pet_first_attr(PetInfo) ->
    %%%%%%?ERROR_MSG("444444444444 ~w",[PetInfo]),
    #p_pet{base_str=Str1, base_int2=Int1, base_con=Con1, base_dex=Dex1, base_men=Men1,buffs=Buffs} = PetInfo,
    %%%%%%?ERROR_MSG("#########  ~w",[Buffs]),
    {Str2,Int2,Con2,Dex2,Men2} = 
        lists:foldl(
          fun(Buf, {Acc1,Acc2,Acc3,Acc4,Acc5}) ->
                  #p_actor_buf{buff_id=BuffID, buff_type=Type} = Buf,
                  {ok, Detail} = mod_skill_manager:get_buf_detail(BuffID),
                  {ok, Func} = mod_skill_manager:get_buff_func_by_type(Type),
                  %%%%%%?ERROR_MSG("55555555555",[]),
                  #p_buf{value=Value, absolute_or_rate=ValueType} = Detail,
                  case Func of
                      add_first_level_attr ->
                          
                          {Acc1+Value, Acc2+Value, Acc3+Value, Acc4+Value, Acc5+Value};
                      add_mem ->
                          NewValue = Value,
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5+NewValue};
                              1 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5+common_tool:ceil(Men1*NewValue/10000)}
                          end;
                      add_str ->
                          NewValue = Value,
                            case ValueType of
                              0 ->
                                  {Acc1+NewValue,Acc2,Acc3,Acc4,Acc5};
                              1 ->
                                  {Acc1+common_tool:ceil(Str1*NewValue/10000),Acc2,Acc3,Acc4,Acc5}
                          end;
                      add_int ->
                          NewValue = Value,
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2+NewValue,Acc3,Acc4,Acc5};
                              1 ->
                                  {Acc1,Acc2+common_tool:ceil(Int1*NewValue/10000),Acc3,Acc4,Acc5}
                          end;
                      add_dex ->
                           NewValue = Value,
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3,Acc4+NewValue,Acc5};
                              1 ->
                                  {Acc1,Acc2,Acc3,Acc4+common_tool:ceil(Dex1*NewValue/10000),Acc5}
                          end;
                      add_con ->
                          NewValue = Value,
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3+NewValue,Acc4,Acc5};
                              1 ->
                                  {Acc1,Acc2,Acc3+common_tool:ceil(Con1*NewValue/10000),Acc4,Acc5}
                          end;
                      pet_add_men ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5+NewValue};
                              1 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5+common_tool:ceil(Men1*NewValue/10000)}
                          end;
                      pet_add_str ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1+NewValue,Acc2,Acc3,Acc4,Acc5};
                              1 ->
                                  {Acc1+common_tool:ceil(Str1*NewValue/10000),Acc2,Acc3,Acc4,Acc5}
                          end;
                      pet_add_int ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2+NewValue,Acc3,Acc4,Acc5};
                              1 ->
                                  {Acc1,Acc2+common_tool:ceil(Int1*NewValue/10000),Acc3,Acc4,Acc5}
                          end;
                      pet_add_dex ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3,Acc4+NewValue,Acc5};
                              1 ->
                                  {Acc1,Acc2,Acc3,Acc4+common_tool:ceil(Dex1*NewValue/10000),Acc5}
                          end;
                      pet_add_con ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3+NewValue,Acc4,Acc5};
                              1 ->
                                  {Acc1,Acc2,Acc3+common_tool:ceil(Con1*NewValue/10000),Acc4,Acc5}
                          end;
                      _ ->
                          {Acc1,Acc2,Acc3,Acc4,Acc5}
                  end
          end, {0,0,0,0,0}, Buffs),
    %%%%%%?ERROR_MSG("6666666666666",[]),
    PetInfo#p_pet{str=Str1+Str2, int2=Int1+Int2, con=Con1+Con2, dex=Dex1+Dex2, men=Men1+Men2}.

    
%%计算宠物的二级战斗属性
calc_pet_second_attr(PetInfo) ->
    #p_pet{str=Str, int2=Int, con=Con, dex=Dex, men=_Men,buffs=Buffs,
           max_hp_aptitude=HPAptitude, phy_defence_aptitude=PDAptitude, magic_defence_aptitude=MDAptitude,
           phy_attack_aptitude=PAAptitude, magic_attack_aptitude=MAAptitude, double_attack_aptitude=DoubleAptitude,
           understanding=UnderStanding,level=Level,max_hp_grow_add=MaxHpAdd,phy_defence_grow_add=PhyDefenceAdd,
           magic_defence_grow_add=MagicDefenceAdd,phy_attack_grow_add=PhyAttackAdd,magic_attack_grow_add=MagicAttackAdd} = PetInfo,
    UnderStandingAddAptitude = get_understanding_add_rate(UnderStanding),
     %%物理攻击力={1+（宠物法攻资质-500）/1000 }*1级力量属性点+lv*2
    PhyAttack1 = trunc( (PAAptitude+UnderStandingAddAptitude)/400 * math:pow(Str,0.85) + Level*3.5 ),
     %%法力攻击力={1+（宠物物攻资质-500）/1000 }*1级智力属性点+lv*2
    MagicAttack1 = trunc( (MAAptitude+UnderStandingAddAptitude)/400 * math:pow(Int,0.85) + Level*3.5 ),
    PhyDefence1 = trunc( (1.2 + (PDAptitude+UnderStandingAddAptitude-500)/1000) * Dex  + Level*3),
    MagicDefence1 = trunc( (1.2 + (MDAptitude+UnderStandingAddAptitude-500)/1000) * Dex + Level*3),
    MaxHP1 = Level*20 + trunc((HPAptitude+UnderStandingAddAptitude-500)/50 * Con),
    DoubleAttack1 = 100 + trunc((DoubleAptitude+UnderStandingAddAptitude-500)/1000 * Con),
    AttackSpeed1=?DEFAULT_PET_ATTACK_SPEED,
     {PhyAttack2,MagicAttack2,PhyDefence2,MagicDefence2,MaxHP2,DoubleAttack2,AttackSpeed2} = 
        lists:foldl(
          fun(Buf, {Acc1,Acc2,Acc3,Acc4,Acc5,Acc6,Acc7}) ->
                  #p_actor_buf{buff_id=BuffID, buff_type=Type} = Buf,
                  {ok, Detail} = mod_skill_manager:get_buf_detail(BuffID),
                  {ok, Func} = mod_skill_manager:get_buff_func_by_type(Type),
                  
                  #p_buf{value=Value, absolute_or_rate=ValueType} = Detail,
                  case Func of
                      %%TODO  对宠物二级属性有影响的技能
                      pet_add_phy_attack ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1+NewValue,Acc2,Acc3,Acc4,Acc5,Acc6,Acc7};
                              1 ->
                                  {Acc1+common_tool:ceil(PhyAttack1*NewValue/10000),Acc2,Acc3,Acc4,Acc5,Acc6,Acc7}
                          end;
                         pet_add_magic_attack ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2+NewValue,Acc3,Acc4,Acc5,Acc6,Acc7};
                              1 ->
                                  {Acc1,Acc2+common_tool:ceil(MagicAttack1*NewValue/10000),Acc3,Acc4,Acc5,Acc6,Acc7}
                          end;
                        pet_add_phy_defence ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3+NewValue,Acc4,Acc5,Acc6,Acc7};
                              1 ->
                                  {Acc1,Acc2,Acc3+common_tool:ceil(PhyDefence1*NewValue/10000),Acc4,Acc5,Acc6,Acc7}
                          end;
                         pet_add_magic_defence ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3,Acc4+NewValue,Acc5,Acc6,Acc7};
                              1 ->
                                  {Acc1,Acc2,Acc3,Acc4+common_tool:ceil(MagicDefence1*NewValue/10000),Acc5,Acc6,Acc7}
                          end;
                         pet_add_max_hp ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5+NewValue,Acc6,Acc7};
                              1 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5+common_tool:ceil(MaxHP1*NewValue/10000),Acc6,Acc7}
                          end;
                         pet_add_double_attack ->
                          NewValue = get_pet_buff_final_value(PetInfo,BuffID,Value),
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5,Acc6+NewValue,Acc7};
                              1 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5,Acc6+common_tool:ceil(DoubleAttack1*NewValue/10000),Acc7}
                          end;
                        add_phy_attack ->
                            case ValueType of
                              0 ->
                                  {Acc1+Value,Acc2,Acc3,Acc4,Acc5,Acc6,Acc7};
                              1 ->
                                  {Acc1+common_tool:ceil(PhyAttack1*Value/10000),Acc2,Acc3,Acc4,Acc5,Acc6,Acc7}
                          end;
                         add_magic_attack ->
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2+Value,Acc3,Acc4,Acc5,Acc6,Acc7};
                              1 ->
                                  {Acc1,Acc2+common_tool:ceil(MagicAttack1*Value/10000),Acc3,Acc4,Acc5,Acc6,Acc7}
                          end;
                        add_phy_defence ->
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3+Value,Acc4,Acc5,Acc6,Acc7};
                              1 ->
                                  {Acc1,Acc2,Acc3+common_tool:ceil(PhyDefence1*Value/10000),Acc4,Acc5,Acc6,Acc7}
                          end;
                         add_magic_defence ->
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3,Acc4+Value,Acc5,Acc6,Acc7};
                              1 ->
                                  {Acc1,Acc2,Acc3,Acc4+common_tool:ceil(MagicDefence1*Value/10000),Acc5,Acc6,Acc7}
                          end;
                         add_max_hp ->
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5+Value,Acc6,Acc7};
                              1 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5+common_tool:ceil(MaxHP1*Value/10000),Acc6,Acc7}
                          end;
                         add_double_attack ->
                            case ValueType of
                              0 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5,Acc6+Value,Acc7};
                              1 ->
                                  {Acc1,Acc2,Acc3,Acc4,Acc5,Acc6+common_tool:ceil(DoubleAttack1*Value/10000),Acc7}
                          end;
                      _ ->
                          {Acc1,Acc2,Acc3,Acc4,Acc5,Acc6,Acc7}
                  end
          end, {0,0,0,0,0,0,0}, Buffs),
    
    PetInfo#p_pet{max_hp=MaxHP1+MaxHP2+MaxHpAdd, 
                  attack_speed=AttackSpeed1+AttackSpeed2,
                  double_attack=DoubleAttack1+DoubleAttack2, 
                  phy_defence=PhyDefence1+PhyDefence2+PhyDefenceAdd,
                  magic_defence=MagicDefence1+MagicDefence2+MagicDefenceAdd,
                  phy_attack=PhyAttack1+PhyAttack2+PhyAttackAdd, 
                  magic_attack=MagicAttack1+MagicAttack2+MagicAttackAdd}.


%%每5分钟扣一点宠物的寿命
reduce_pet_life_and_persistent(List, Now) ->
    lists:foreach(
      fun(PetID) ->
              LastTick = get({?LAST_REDUCE_LIFE_TICK,PetID}),
              case LastTick =:= undefined orelse Now - LastTick >= 300 of
                  true ->
                      put({?LAST_REDUCE_LIFE_TICK,PetID},Now),
                      case get({?ROLE_PET_INFO,PetID}) of
                          undefined ->
                              ignore;
                          PetInfo ->
                              Life = PetInfo#p_pet.life,
                               RoleID = PetInfo#p_pet.role_id,
                              case Life > 1 of
                                  true ->
                                      NewPetInfo = PetInfo#p_pet{life=Life-1},
                                      put({?ROLE_PET_INFO,PetID},NewPetInfo),
                                      spawn(fun() -> db:transaction(fun() -> db:write(?DB_PET,NewPetInfo,write) end) end),
                                      Record = #m_pet_attr_change_toc{pet_id=PetID,change_type=?PET_LIFE_ATTR_CHANGE,value=Life-1},
                                      common_misc:unicast({role,RoleID},?DEFAULT_UNIQUE,?PET,?PET_ATTR_CHANGE,Record);
                                  false ->
                                      put({?ROLE_PET_INFO,PetID},PetInfo#p_pet{life=0}),
                                      State = mgeem_map:get_state(),
                                      pet_quit(RoleID, PetID, State),
                                      common_broadcast:bc_send_msg_role(RoleID,?BC_MSG_TYPE_SYSTEM,?_LANG_PET_CALL_BACK_FOR_LIFE_OVER)
                              end
                      end;
                  false ->
                      ignore
              end
      end,List).


%%宠物死亡
pet_dead(PetID,PetMapInfo,RoleID) ->
    mod_map_actor:set_actor_mapinfo(PetID,pet,PetMapInfo),
    PetInfo = get({?ROLE_PET_INFO,PetID}),
    Life = PetInfo#p_pet.life,
    case Life > 20 of
        true ->
            NewLife = Life - 20;
        false ->
            NewLife = 0
    end,
    put({?ROLE_PET_INFO,PetID},PetInfo#p_pet{life=NewLife}),
    write_pet_action_log(PetInfo,RoleID,?PET_ACTION_TYPE_DEAD,"宠物死亡",0,""), 
    Record = #m_pet_dead_toc{pet_id=PetID,life=NewLife},
    State = mgeem_map:get_state(),
    mgeem_map:do_broadcast_insence_include([{role,RoleID}],?PET,?PET_DEAD,Record,State),
    self() ! {mod_map_pet,{quit,RoleID, PetID}},
    %%%%%%?ERROR_MSG("4444444  pet dead",[]),
    ok.


do_buff_loop(PetID, Module, Method, Args, LastTime, LastInterval) ->
    case get({?ROLE_PET_INFO,PetID}) of
        undefined ->
            ignore;
        PetInfo ->
            apply(Module, Method, [PetInfo|Args]),
            
            case get({?ROLE_PET_INFO,PetID}) of
                undefined ->
                    ignore;
                PetInfo2 ->
                    [ActorBuff|_] = Args,
                    case LastTime - LastInterval =< 0 of
                        true ->
                            case mod_pet_buff:remove_buff(PetID, pet, [ActorBuff], PetID, PetInfo2) of
                                ignore ->
                                    ignore;
                                PetInfo3 ->
                                    put({?ROLE_PET_INFO,PetID},PetInfo3)
                            end;
                        _ ->
                            
                            TimerRef = erlang:send_after(LastInterval*1000, self(), 
                                                         {mod_map_pet, {buff_loop, PetID, Module, Method, Args, LastTime-LastInterval, LastInterval}}),
                            case get({?PET_BUFF_TIMER_REF,PetID}) of
                                
                                undefined ->
                                    BuffTimerRef = [];
                                List ->
                                    BuffTimerRef = List
                            end,

                            BuffType = ActorBuff#p_actor_buf.buff_type,
                            BuffTimerRef2 = [{BuffType, TimerRef}|lists:keydelete(BuffType, 1, BuffTimerRef)],

                            put({?PET_BUFF_TIMER_REF,PetID},BuffTimerRef2)
                    end
            end
    end.

%%给宠物加BUFF
do_add_buff(SrcActorID, SrcActorType, BuffDetail, PetID) ->
     case get({?ROLE_PET_INFO,PetID}) of
        undefined ->
            ignore;
        PetInfo ->
             NewPetInfo = mod_pet_buff:add_buff(SrcActorID, SrcActorType, BuffDetail, PetID, PetInfo),
             put({?ROLE_PET_INFO,PetID},NewPetInfo)
    end.


do_remove_buff(SrcActorID, SrcActorType, RemoveList, PetID) ->
    case get({?ROLE_PET_INFO,PetID}) of
        undefined ->
            ignore;
        PetInfo ->
            NewPetInfo = mod_pet_buff:remove_buff(SrcActorID, SrcActorType, RemoveList, PetID, PetInfo),
            put({?ROLE_PET_INFO,PetID},NewPetInfo)
    end.


do_remove_buff(SrcActorID, SrcActorType, RemoveList, PetID, TimerRef) ->
    case get({?ROLE_PET_INFO,PetID}) of
        undefined ->
            ignore;
        PetInfo ->
            NewPetInfo = mod_monster_buff:remove_buff(SrcActorID, SrcActorType, RemoveList, PetID, PetInfo, TimerRef),
            put({?ROLE_PET_INFO,PetID},NewPetInfo)
    end.


%%宠物召唤出来后添加被动BUFF技能给自己和主人
add_pet_buff_when_summon(PetInfo) ->
    Skills = PetInfo#p_pet.skills,
    lists:foldr(
      fun(#p_pet_skill{skill_id=SkillID,skill_type=SkillType},PetInfoAcc) ->
              case common_config_dyn:find(pet_etc,{pet_skill_type,SkillType}) of
                  [add_buff_to_role] ->
                      add_buff_to_owner(PetInfoAcc,SkillID),
                      PetInfoAcc;
                  [add_buff_to_pet] ->
                      add_buff_to_self(PetInfoAcc,SkillID);
                  _ ->
                      case common_config_dyn:find(pet_etc,{pet_trick_skill_type,SkillID}) of
                          [add_buff_to_role] ->
                              add_buff_to_owner(PetInfoAcc,SkillID),
                              PetInfoAcc;
                          [add_buff_to_pet] ->
                              add_buff_to_self(PetInfoAcc,SkillID);
                          _ ->
                              PetInfoAcc
                      end
              end
      end, PetInfo, Skills).


%%给宠物的主人添加宠物BUFF
add_buff_to_owner(PetInfo,SkillID) ->
     {ok, SkillLevelInfo} = mod_skill_manager:get_skill_level_info(SkillID, 1),
     SkillBuffs = SkillLevelInfo#p_skill_level.buffs,
     self() ! {mod_map_role,{add_buff,PetInfo#p_pet.role_id, PetInfo#p_pet.pet_id, pet, SkillBuffs}},
     ok.


%%宠物自己给自己添加buff
add_buff_to_self(PetInfo,SkillID) ->
     {ok, SkillLevelInfo} = mod_skill_manager:get_skill_level_info(SkillID, 1),
     SkillBuffs = SkillLevelInfo#p_skill_level.buffs,
     mod_pet_buff:add_buff(PetInfo#p_pet.pet_id, pet, SkillBuffs, PetInfo#p_pet.pet_id, PetInfo).


%%宠物招回或者死亡时去除宠物加给主人的buff
remove_pet_buff_add_to_owner(PetInfo) ->
    Skills = PetInfo#p_pet.skills,
    lists:foldr(
      fun(#p_pet_skill{skill_id=SkillID,skill_type=SkillType},PetInfoAcc) ->
              case common_config_dyn:find(pet_etc,{pet_skill_type,SkillType}) of
                  [add_buff_to_role] ->
                      remove_buff_to_owner(PetInfoAcc,SkillID),
                      PetInfoAcc;
                  _ ->
                      case common_config_dyn:find(pet_etc,{pet_trick_skill_type,SkillID}) of
                          [add_buff_to_role] ->
                              remove_buff_to_owner(PetInfoAcc,SkillID),
                              PetInfoAcc;
                          _ ->
                              PetInfoAcc
                      end
              end
      end, PetInfo, Skills).


%%给宠物的主人添加宠物BUFF
remove_buff_to_owner(PetInfo,SkillID) ->
     {ok, SkillLevelInfo} = mod_skill_manager:get_skill_level_info(SkillID, 1),
     SkillBuffs = SkillLevelInfo#p_skill_level.buffs,
     %%%%%%?ERROR_MSG("%%%%%%%%%    ~w  ~w   ~w",[PetInfo,SkillID,SkillBuffs]),
     lists:foreach(
       fun(#p_buf{buff_type=BuffType}) ->
               mod_role_buff:remove_buff(PetInfo#p_pet.role_id, PetInfo#p_pet.pet_id, pet, BuffType)
       end,SkillBuffs),
     ok.


get_remain_attr_point_by_level(Level) ->
    case Level =< 50 of
        true ->
            Level * 3 ;
        false ->
            Level * 4 - 50
    end.


write_pet_action_log(PetInfo,RoleID,ActionType,ActionTypeStr,ActionDetail,ActionDetailStr) ->
    #p_pet{pet_id=PetID,pet_name=PetName,type_id=TypeID} = PetInfo,
    [#p_pet_base_info{pet_name=Name}] = common_config_dyn:find(pet,TypeID),
    catch global:send(mgeew_pet_log_server,{log_pet_action,{PetID, PetName, TypeID, RoleID, ActionType, ActionDetail, Name, ActionTypeStr, ActionDetailStr}}).


write_pet_get_log(PetInfo,RoleID,RoleFaction,RoleLevel,GetWay,GetWayStr) ->
    #p_pet{pet_id=PetID,pet_name=PetName,type_id=TypeID,level=PetLevel} = PetInfo,
    [#p_pet_base_info{pet_name=Name}] = common_config_dyn:find(pet,TypeID),
    catch global:send(mgeew_pet_log_server,{log_get_pet,{PetID, PetName, TypeID, PetLevel, GetWay, RoleID, RoleLevel,RoleFaction, Name, GetWayStr}}).


%%检查宠物的颜色是否变化，变化修改背包信息并通知前端
check_pet_bag_color_change(RoleID,PetID,Color,OldColor) ->
    case Color =:= OldColor of
        true ->
            ignore;
        false ->
            [PetBag] = db:read(?DB_ROLE_PET_BAG,RoleID),
            Pets = PetBag#p_role_pet_bag.pets,
            NewPets = lists:foldr(
              fun(IDName,Acc) ->
                      case IDName#p_pet_id_name.pet_id of
                          PetID ->
                              [IDName#p_pet_id_name{color=Color}|Acc];
                          _ ->
                              [IDName|Acc]
                      end
              end,[],Pets),
            NewBagInfo = PetBag#p_role_pet_bag{pets=NewPets},
            %% self() ! {mod_map_pet,{pet_color_goal,RoleID,Color}}, 
            db:write(?DB_ROLE_PET_BAG,NewBagInfo,write),
            Record = #m_pet_bag_info_toc{info=NewBagInfo},
            common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_BAG_INFO, Record)
    end.
                    

%%========================宠物测试代码==================
test_t_get_new_pet(RoleID,TypeID,RoleLevel) ->
    _Ret = db:transaction( fun()-> t_get_new_pet(RoleID,TypeID,RoleLevel,"TEST",false,1) end).
    %%%%%%?ERROR_MSG("!!!!!!!!!!!!!!!!  test_t_get_new_pet,Ret=  ~w",[Ret]).

test_summon(RoleID) ->
    PetID = get_role_pet_id(RoleID),
    common_misc:send_to_rolemap(RoleID,{13432, ?PET, ?PET_SUMMON, #m_pet_summon_tos{pet_id=PetID}, RoleID, self(),6001}).

test_call_back(RoleID) ->
    PetID = get_role_pet_id(RoleID),
    common_misc:send_to_rolemap(RoleID,{13432, ?PET, ?PET_CALL_BACK, #m_pet_call_back_tos{pet_id=PetID}, RoleID, self(),6001}).

test_throw(RoleID) ->
    PetID = get_role_pet_id(RoleID),
    common_misc:send_to_rolemap(RoleID,{13432, ?PET, ?PET_THROW, #m_pet_throw_tos{pet_id=PetID}, RoleID, self(),6001}).

test_info(RoleID) ->
    PetID = get_role_pet_id(RoleID),
    common_misc:send_to_rolemap(RoleID,{13432, ?PET, ?PET_INFO, #m_pet_info_tos{pet_id=PetID}, RoleID, self(),6001}).


test_attr_assign(RoleID,Value) ->
    PetID = get_role_pet_id(RoleID),
    Assign = [#p_pet_attr_assign{assign_type=?ATTR_STR,assign_value=Value},#p_pet_attr_assign{assign_type=?ATTR_MEN,assign_value=Value}],
    common_misc:send_to_rolemap(RoleID,{13432, ?PET, ?PET_ATTR_ASSIGN, #m_pet_attr_assign_tos{pet_id=PetID,assign_info=Assign}, RoleID, self(),6001}).

test_learn_skill(RoleID,SkillID) when SkillID =:= 0 ->
    test_learn_skill(RoleID,62123103);
test_learn_skill(RoleID,SkillID) ->
    PetID = get_role_pet_id(RoleID),
    common_misc:send_to_rolemap(RoleID,{13432, ?PET, ?PET_LEARN_SKILL, #m_pet_learn_skill_tos{pet_id=PetID,skill_id=SkillID}, RoleID, self(),6001}).

test_add_life(RoleID) ->
    PetID = get_role_pet_id(RoleID),
    common_misc:send_to_rolemap(RoleID,{13432, ?PET, ?PET_ADD_LIFE, #m_pet_add_life_tos{pet_id=PetID,add_type=1}, RoleID, self(),6001}).

test_add_understanding(RoleID,Pro) ->
    PetID = get_role_pet_id(RoleID),
    common_misc:send_to_rolemap(RoleID,{13432, ?PET, ?PET_ADD_UNDERSTANDING, #m_pet_add_understanding_tos{pet_id=PetID,item_type=12300123,use_protect=Pro}, RoleID, self(),6001}).

test_refresh_aptitude(RoleID) ->
    PetID = get_role_pet_id(RoleID),
    common_misc:send_to_rolemap(RoleID,{13432, ?PET, ?PET_REFRESH_APTITUDE, #m_pet_refresh_aptitude_tos{pet_id=PetID,item_type=12300120}, RoleID, self(),6001}).


test_change_name(RoleID,Name) ->
    PetID = get_role_pet_id(RoleID),
    common_misc:send_to_rolemap(RoleID,{13432, ?PET, ?PET_CHANGE_NAME, #m_pet_change_name_tos{pet_id=PetID,pet_name=common_tool:to_list(Name)}, RoleID, self(),6001}).



get_role_pet_id(RoleID) ->
    case db:dirty_read(db_role_pet_bag,RoleID) of
        [] ->
            1;
        [Info] ->
             Info#p_role_pet_bag.pets,
            case Info#p_role_pet_bag.pets of
                [] ->
                    1;
                [IDName|_] ->
                    IDName#p_pet_id_name.pet_id
             end
    end.


auto_add_pet_remain_point(PetInfo) ->
    case PetInfo#p_pet.level > 30 of
        false ->
            RemainPoint = PetInfo#p_pet.remain_attr_points,
            case PetInfo#p_pet.attack_type of
                ?PET_ATTACK_TYPE_PHY ->
                    BaseStr = PetInfo#p_pet.base_str,
                    PetInfo#p_pet{base_str=BaseStr+RemainPoint,remain_attr_points=0};
                ?PET_ATTACK_TYPE_MAGIC ->
                    BaseInt = PetInfo#p_pet.base_int2,
                    PetInfo#p_pet{base_int2=BaseInt+RemainPoint,remain_attr_points=0}
            end;
        true ->
            PetInfo
    end.


                
    
