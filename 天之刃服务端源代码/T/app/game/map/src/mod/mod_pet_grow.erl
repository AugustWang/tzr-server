%% Author: liuwei
%% Created: 2011-3-23
%% Description:  宠物驯养
-module(mod_pet_grow).

%%
%% Include files
%%
-include("mgeem.hrl").

%%
%% Exported Functions
%%
-export([
         init/0,
         clear_role_pet_grow_info/1,
         init_map_role_pet_grow_info/2,
         get_role_pet_grow_info/1,
         check_grow_over/0,
         do_pet_grow_info/5,
         do_pet_grow_begin/5,
         do_pet_grow_commit/5,
         do_pet_grow_give_up/5,
         calc_pet_grow_add/1
        ]).

-define(ROLE_PET_GROW_LIST,role_pet_grow_list).
-define(ROLE_PET_GROW_INFO,role_pet_grow_info).

   
-define(GROW_TYPE_PHY_ATTACK,1).    
-define(GROW_TYPE_MAGIC_ATTACK,2).         
-define(GROW_TYPE_PHY_DEFENCE,3).     
-define(GROW_TYPE_MAGIC_DEFENCE,4).  
-define(GROW_TYPE_CON,5).

-define(MAX_GROW_LEVEL,40).

-record(r_pet_grow,{key,need_pet_level,need_silver,need_tick,add_value}). 

%%
%% API Functions
%%
init() ->
    put(?ROLE_PET_GROW_LIST,[]).


clear_role_pet_grow_info(RoleID) ->
    erase({?ROLE_PET_GROW_INFO,RoleID}),
    put(?ROLE_PET_GROW_LIST,lists:delete(RoleID, get(?ROLE_PET_GROW_LIST))).


get_role_pet_grow_info(RoleID) ->
    case get({?ROLE_PET_GROW_INFO,RoleID}) of
        undefined ->
            {undefined,undefined};
        GrowInfo ->
            case GrowInfo#p_role_pet_grow.state =:= ?PET_GROW_STATE of
                true ->
                    {GrowInfo,GrowInfo#p_role_pet_grow.grow_over_tick};
                false ->
                    {GrowInfo,undefined}
            end
    end.


init_map_role_pet_grow_info(RoleID,{GrowInfo,OverTick}) ->
    case OverTick of
        undefined ->
             put({?ROLE_PET_GROW_INFO,RoleID},GrowInfo);
        _ ->
            Now = common_tool:now(),
            case OverTick =< Now of
                true ->
                    NewGrowInfo = get_update_grow_info(GrowInfo),
                    put({?ROLE_PET_GROW_INFO,RoleID},NewGrowInfo),
                    spawn(fun() -> db:transaction(fun()-> db:write(?DB_ROLE_PET_GROW,NewGrowInfo,write) end) end);
                false ->
                    put({?ROLE_PET_GROW_INFO,RoleID},GrowInfo),
                    put(?ROLE_PET_GROW_LIST,[RoleID|get(?ROLE_PET_GROW_LIST)])
            end
    end.


do_pet_grow_info(Unique, _DataIn, RoleID, Line, _State) ->
    case get({?ROLE_PET_GROW_INFO,RoleID}) of
        undefined ->
            do_pet_grow_info_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR);
        GrowInfo ->
            {Configs,GrowInfo2} = get_grow_config_infos_to_client(GrowInfo),
            Record = #m_pet_grow_info_toc{succ=true,grow_info=GrowInfo2,info_configs=Configs},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_GROW_INFO, Record)
    end.
           


do_pet_grow_info_error(Unique, RoleID, Line, Reason) ->
%%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_grow_info_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_GROW_INFO, Record).


do_pet_grow_begin(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_grow_begin_tos{grow_type=GrowType} = DataIn,
    case get({?ROLE_PET_GROW_INFO,RoleID}) of
        undefined ->
            do_pet_grow_begin_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR);
        GrowInfo ->
            case GrowInfo#p_role_pet_grow.state =:= ?PET_GROW_STATE of
                true ->
                    do_pet_grow_begin_error(Unique, RoleID, Line, ?_LANG_PET_GROW_NOT_OVER);
                false ->
                    case check_grow_level_full(GrowInfo,GrowType) of
                        {true,_} ->
                            do_pet_grow_begin_error(Unique, RoleID, Line, ?_LANG_PET_GROW_LEVEL_FULL);
                        {false,GrowLevel} ->
                            case check_grow_pre_skill_level(GrowInfo,GrowType) of
                                true ->
                                    grow_begin(GrowType,GrowInfo,GrowLevel,Unique, RoleID, Line);
                                false ->
                                    do_pet_grow_begin_error(Unique, RoleID, Line, ?_LANG_PET_GROW_PRE_SKILL_NOT_LEARN)
                            end
                    end
            end
    end.


grow_begin(GrowType,GrowInfo,GrowLevel,Unique, RoleID, Line) ->
    Config = get_config_info(GrowLevel,GrowType),
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    case RoleAttr#p_role_attr.level < Config#p_grow_info.need_level of
        true ->
            do_pet_grow_begin_error(Unique, RoleID, Line, ?_LANG_PET_GROW_LEVEL_NOT_ENOUGH);
        false ->
            case RoleAttr#p_role_attr.silver + RoleAttr#p_role_attr.silver_bind >= Config#p_grow_info.need_silver of
                false ->
                    do_pet_grow_begin_error(Unique, RoleID, Line, ?_LANG_PET_GROW_SILVER_NOT_ENOUGH);
                true ->
                    grow_begin_2(GrowType,GrowInfo,GrowLevel,Config,RoleAttr,Unique, RoleID, Line)
            end
    end.


grow_begin_2(GrowType,GrowInfo,_GrowLevel,Config,RoleAttr,Unique, RoleID, Line) ->
    Now = common_tool:now(),
    NeedTick = Config#p_grow_info.need_tick,
    NewGrowInfo = GrowInfo#p_role_pet_grow{state=?PET_GROW_STATE,
                                           grow_type=GrowType,
                                           grow_over_tick=Now + NeedTick,
                                           grow_tick=NeedTick},
    Fun = fun() ->
                  NewRoleAttr = mod_map_pet:t_deduct_silver(RoleAttr,Config#p_grow_info.need_silver,?CONSUME_TYPE_SILVER_PET_GROW),
                  mod_map_role:set_role_attr(RoleID, NewRoleAttr),
                  db:write(?DB_ROLE_PET_GROW,NewGrowInfo,write),
                  put(?ROLE_PET_GROW_LIST,[RoleID|get(?ROLE_PET_GROW_LIST)]),
                  put({?ROLE_PET_GROW_INFO,RoleID},NewGrowInfo),
                  {ok,NewRoleAttr,NewGrowInfo}
          end,
    case db:transaction(Fun) of
        {aborted,Reason} ->
            do_pet_grow_begin_error(Unique, RoleID, Line, Reason);
        {atomic, {ok,NewRoleAttr,NewGrowInfo2}} ->
            ChangeList = [
                          #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=NewRoleAttr#p_role_attr.silver},
                          #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.silver_bind}],
            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList),

            {Configs,NewGrowInfo3} = get_grow_config_infos_to_client(NewGrowInfo2),
            Record = #m_pet_grow_begin_toc{succ=true,grow_info=NewGrowInfo3,info_configs=Configs},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_GROW_BEGIN, Record)
    end.



do_pet_grow_begin_error(Unique, RoleID, Line, Reason) ->
%%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_grow_begin_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_GROW_BEGIN, Record).


do_pet_grow_commit(Unique, _DataIn, RoleID, Line, _State) ->
    case get({?ROLE_PET_GROW_INFO,RoleID}) of
        undefined ->
            do_pet_grow_commit_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR);
        GrowInfo ->
            case GrowInfo#p_role_pet_grow.state =:= ?PET_GROW_STATE of
                false ->
                    do_pet_grow_begin_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR);
                true ->
                    OverTick = GrowInfo#p_role_pet_grow.grow_over_tick,
                    Now =common_tool:now(),
                    case Now >= OverTick of
                        true ->
                            NeedGold = 0;
                        false ->
                            NeedGold = common_tool:ceil((OverTick - Now)/300)
                    end,
                    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                    case RoleAttr#p_role_attr.gold + RoleAttr#p_role_attr.gold_bind >= NeedGold of
                        false ->
                            do_pet_grow_commit_error(Unique, RoleID, Line, ?_LANG_PET_GROW_GOLD_NOT_ENOUGH);
                        true ->
                            grow_commit(RoleAttr,RoleID,GrowInfo,NeedGold,Unique,Line)
                    end
            end
    end.
                            

grow_commit(RoleAttr,RoleID,GrowInfo,NeedGold,Unique,Line) ->
    Fun = fun() ->
                  NewGrowInfo = get_update_grow_info(GrowInfo),
                  {NewRoleAttr,_,_} = mod_pet_feed:t_deduct_gold(RoleAttr,NeedGold,?CONSUME_TYPE_GOLD_PET_GROW_SPEED_UP),
                  mod_map_role:set_role_attr(RoleID, NewRoleAttr),
                  db:write(?DB_ROLE_PET_GROW,NewGrowInfo,write),
                  put(?ROLE_PET_GROW_LIST,lists:delete(RoleID, get(?ROLE_PET_GROW_LIST))),
                  put({?ROLE_PET_GROW_INFO,RoleID},NewGrowInfo),
                  mod_map_pet:calc_pet_attr(RoleID),
                  {ok,NewRoleAttr,NewGrowInfo}
          end,
    case db:transaction(Fun) of
        {aborted,Reason} ->
            do_pet_grow_commit_error(Unique, RoleID, Line, Reason);
        {atomic, {ok,NewRoleAttr2,NewGrowInfo2}} ->
            ChangeList = [
                          #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=NewRoleAttr2#p_role_attr.gold},
                          #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=NewRoleAttr2#p_role_attr.gold_bind}],
            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList),

            {Configs,NewGrowInfo3} = get_grow_config_infos_to_client(NewGrowInfo2),
            Record = #m_pet_grow_commit_toc{succ=true, use_gold=NeedGold, grow_info=NewGrowInfo3,info_configs=Configs},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_GROW_COMMIT, Record),

            {_GrowStr,Level} = get_grow_type_str_and_level(GrowInfo),
            hook_map_pet:on_grow_update(RoleID, Level, 0)
            %%case NeedGold > 10 of
            %%    true ->
            %%        Content = io_lib:format(?_LANG_PET_GROW_BROADCAST,[RoleAttr#p_role_attr.role_name,NeedGold,GrowStr,Level]),
            %%        catch common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_WORLD,common_tool:to_list(Content));
            %%    false ->
            %%        ignore
            %%end                
    end.


do_pet_grow_commit_error(Unique, RoleID, Line, Reason) ->
%%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_grow_commit_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_GROW_COMMIT, Record).


do_pet_grow_give_up(Unique, _DataIn, RoleID, Line, _State) ->
    case get({?ROLE_PET_GROW_INFO,RoleID}) of
        undefined ->
            do_pet_grow_give_up_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR);
        GrowInfo ->
            case GrowInfo#p_role_pet_grow.state =:= ?PET_GROW_STATE of
                false ->
                    do_pet_grow_begin_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR);
                true ->
                    NewGrowInfo = GrowInfo#p_role_pet_grow{state=?PET_NORMAL_STATE},
                    put({?ROLE_PET_GROW_INFO,RoleID},NewGrowInfo),
                    put(?ROLE_PET_GROW_LIST,lists:delete(RoleID, get(?ROLE_PET_GROW_LIST))),
                    spawn(fun() -> db:transaction(fun()-> db:write(?DB_ROLE_PET_GROW,NewGrowInfo,write) end) end),
                    {Configs,NewGrowInfo2} = get_grow_config_infos_to_client(NewGrowInfo),
                    Record = #m_pet_grow_give_up_toc{succ=true,grow_info=NewGrowInfo2,info_configs=Configs},
                    common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_GROW_GIVE_UP, Record)
            end
    end.


do_pet_grow_give_up_error(Unique, RoleID, Line, Reason) ->
%%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_grow_give_up_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_GROW_GIVE_UP, Record).


check_grow_over() ->
    Now=common_tool:now(),
    lists:foreach(
      fun(RoleID) ->
              check_grow_over(RoleID,Now)
      end, get(?ROLE_PET_GROW_LIST)).
check_grow_over(RoleID,Now) ->
    case get({?ROLE_PET_GROW_INFO,RoleID}) of
        undefined ->
            put(?ROLE_PET_GROW_LIST,lists:delete(RoleID, get(?ROLE_PET_GROW_LIST)));
        GrowInfo ->
            case GrowInfo#p_role_pet_grow.grow_over_tick =< Now of
                true ->
                    change_grow_level(GrowInfo),
                    put(?ROLE_PET_GROW_LIST,lists:delete(RoleID, get(?ROLE_PET_GROW_LIST)));
                false ->
                    ignore
            end
    end.


calc_pet_grow_add(PetInfo) ->
    RoleID = PetInfo#p_pet.role_id,
    case get({?ROLE_PET_GROW_INFO,RoleID}) of
        undefined ->
            PetInfo;
        GrowInfo ->
            #p_role_pet_grow{con_level=ConLevel,
                             phy_attack_level=PhyAttackLevel,
                             magic_attack_level=MagicAttackLevel,
                             phy_defence_level=PhyDefenceLevel,
                             magic_defence_level=MagicDefenceLevel
                            } = GrowInfo,
            [#r_pet_grow{add_value=MaxHpAdd}] = get_grow_add_value(ConLevel,?GROW_TYPE_CON),
            [#r_pet_grow{add_value=PhyAttackAdd}] = get_grow_add_value(PhyAttackLevel,?GROW_TYPE_PHY_ATTACK),
            [#r_pet_grow{add_value=MagicAttackAdd}] = get_grow_add_value(MagicAttackLevel,?GROW_TYPE_MAGIC_ATTACK),
            [#r_pet_grow{add_value=PhyDefenceAdd}] = get_grow_add_value(PhyDefenceLevel,?GROW_TYPE_PHY_DEFENCE),
            [#r_pet_grow{add_value=MagicDefenceAdd}] = get_grow_add_value(MagicDefenceLevel,?GROW_TYPE_MAGIC_DEFENCE),
            PetInfo#p_pet{max_hp_grow_add=MaxHpAdd,
                          phy_defence_grow_add=PhyDefenceAdd,
                          magic_defence_grow_add=MagicDefenceAdd,
                          phy_attack_grow_add=PhyAttackAdd,
                          magic_attack_grow_add=MagicAttackAdd
                         }
    end.
            
%%      
%%LOCAL FUNCTIONS
%%
get_grow_add_value(0,_Type) ->
    [#r_pet_grow{add_value=0}];
get_grow_add_value(Level,Type) ->
    common_config_dyn:find(pet_grow,{Level,Type}).


get_grow_config_infos_to_client(GrowInfo) ->
    case GrowInfo#p_role_pet_grow.state =:= ?PET_GROW_STATE of
        true ->
            Now=common_tool:now(),
            OverTick = GrowInfo#p_role_pet_grow.grow_over_tick,
            case Now >= OverTick of
                true ->
                    GrowInfo2=GrowInfo#p_role_pet_grow{grow_over_tick=0};
                false ->
                    GrowInfo2 = GrowInfo#p_role_pet_grow{grow_over_tick=OverTick-Now}
            end;
        false ->
            GrowInfo2=GrowInfo
    end,
    ConInfo = get_config_info(GrowInfo#p_role_pet_grow.con_level,?GROW_TYPE_CON),
    ConInfo2 = get_config_info(GrowInfo#p_role_pet_grow.phy_defence_level,?GROW_TYPE_PHY_DEFENCE),
    ConInfo3 = get_config_info(GrowInfo#p_role_pet_grow.magic_defence_level,?GROW_TYPE_MAGIC_DEFENCE),
    ConInfo4 = get_config_info(GrowInfo#p_role_pet_grow.phy_attack_level,?GROW_TYPE_PHY_ATTACK),
    ConInfo5 = get_config_info(GrowInfo#p_role_pet_grow.magic_attack_level,?GROW_TYPE_MAGIC_ATTACK),
    {[get_config_add_value(GrowInfo,ConfigInfo)||ConfigInfo<-[ConInfo,ConInfo2,ConInfo3,ConInfo4,ConInfo5]],GrowInfo2}.
    
get_config_add_value(GrowInfo,#p_grow_info{type=?GROW_TYPE_PHY_ATTACK}=ConfigInfo)->
    get_config_add_value1(GrowInfo#p_role_pet_grow.phy_attack_level,ConfigInfo);
get_config_add_value(GrowInfo,#p_grow_info{type=?GROW_TYPE_MAGIC_ATTACK}=ConfigInfo)->
    get_config_add_value1(GrowInfo#p_role_pet_grow.magic_attack_level,ConfigInfo);
get_config_add_value(GrowInfo,#p_grow_info{type=?GROW_TYPE_PHY_DEFENCE}=ConfigInfo)->
    get_config_add_value1(GrowInfo#p_role_pet_grow.phy_defence_level,ConfigInfo);
get_config_add_value(GrowInfo,#p_grow_info{type=?GROW_TYPE_MAGIC_DEFENCE}=ConfigInfo)->
    get_config_add_value1(GrowInfo#p_role_pet_grow.magic_defence_level,ConfigInfo);
get_config_add_value(GrowInfo,#p_grow_info{type=?GROW_TYPE_CON}=ConfigInfo)->
    get_config_add_value1(GrowInfo#p_role_pet_grow.con_level,ConfigInfo).

get_config_add_value1(Level,#p_grow_info{type=Type}=ConfigInfo)->
    case common_config_dyn:find(pet_grow,{Level,Type}) of
        []->
            ConfigInfo;
        [#r_pet_grow{add_value=AddValue}]->
            ConfigInfo#p_grow_info{cur_add_value=AddValue}
    end.

get_config_info(Level,Type)->
    case common_config_dyn:find(pet_grow,{Level+1,Type}) of
        [] ->
            #p_grow_info{type=Type,level=Level+1};
        [#r_pet_grow{need_pet_level=NeedLevel,need_silver=NeedSilver,
                     need_tick=NeedTick,add_value=AddVaule}] ->
             #p_grow_info{type=Type,level=Level+1,need_level=NeedLevel,need_silver=NeedSilver,need_tick=NeedTick,add_value=AddVaule}
    end.

check_grow_level_full(GrowInfo,GrowType) ->
    case GrowType of 
        ?GROW_TYPE_CON ->
            Level = GrowInfo#p_role_pet_grow.con_level;
        ?GROW_TYPE_PHY_DEFENCE ->
            Level = GrowInfo#p_role_pet_grow.phy_defence_level;
         ?GROW_TYPE_MAGIC_DEFENCE ->
            Level = GrowInfo#p_role_pet_grow.magic_defence_level;
         ?GROW_TYPE_PHY_ATTACK ->
            Level = GrowInfo#p_role_pet_grow.phy_attack_level;
         ?GROW_TYPE_MAGIC_ATTACK ->
            Level = GrowInfo#p_role_pet_grow.magic_attack_level;
        _ ->
            Level = 40
    end,
    {Level >= 40, Level}.
        
change_grow_level(GrowInfo) ->
    case GrowInfo#p_role_pet_grow.state =:= ?PET_GROW_STATE of
        false ->
            ingnor;
        true ->
            NewGrowInfo = get_update_grow_info(GrowInfo),
            Level = lists:max([NewGrowInfo#p_role_pet_grow.con_level, NewGrowInfo#p_role_pet_grow.phy_defence_level,
                               NewGrowInfo#p_role_pet_grow.magic_defence_level, NewGrowInfo#p_role_pet_grow.phy_attack_level,
                               NewGrowInfo#p_role_pet_grow.magic_attack_level]),            
            RoleID = GrowInfo#p_role_pet_grow.role_id,
            hook_map_pet:on_grow_update(RoleID, Level, 0),
            put({?ROLE_PET_GROW_INFO,RoleID},NewGrowInfo),
            mod_map_pet:calc_pet_attr(RoleID),
            spawn(fun() -> db:transaction(fun()-> db:write(?DB_ROLE_PET_GROW,NewGrowInfo,write) end) end),            
            {Configs,NewGrowInfo2} = get_grow_config_infos_to_client(NewGrowInfo),
            Record = #m_pet_grow_over_toc{grow_type=GrowInfo#p_role_pet_grow.grow_type,grow_info=NewGrowInfo2,info_configs=Configs},
            common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_GROW_OVER, Record)
    end.


get_update_grow_info(GrowInfo) ->
    case GrowInfo#p_role_pet_grow.grow_type of
        ?GROW_TYPE_CON ->
            OldLevel =  GrowInfo#p_role_pet_grow.con_level,
            NewGrowInfo = GrowInfo#p_role_pet_grow{con_level=OldLevel+1,state=?PET_NORMAL_STATE};
        ?GROW_TYPE_PHY_DEFENCE ->
            OldLevel =  GrowInfo#p_role_pet_grow.phy_defence_level,
            NewGrowInfo = GrowInfo#p_role_pet_grow{phy_defence_level=OldLevel+1,state=?PET_NORMAL_STATE};
        ?GROW_TYPE_MAGIC_DEFENCE ->
            OldLevel =  GrowInfo#p_role_pet_grow.magic_defence_level,
            NewGrowInfo = GrowInfo#p_role_pet_grow{magic_defence_level=OldLevel+1,state=?PET_NORMAL_STATE};
        ?GROW_TYPE_PHY_ATTACK ->
            OldLevel =  GrowInfo#p_role_pet_grow.phy_attack_level,
            NewGrowInfo = GrowInfo#p_role_pet_grow{phy_attack_level=OldLevel+1,state=?PET_NORMAL_STATE};
        ?GROW_TYPE_MAGIC_ATTACK ->
            OldLevel =  GrowInfo#p_role_pet_grow.magic_attack_level,
            NewGrowInfo = GrowInfo#p_role_pet_grow{magic_attack_level=OldLevel+1,state=?PET_NORMAL_STATE}
    end,
    NewGrowInfo.

get_grow_type_str_and_level(GrowInfo) ->
    case GrowInfo#p_role_pet_grow.grow_type of
        ?GROW_TYPE_CON ->
            {"神功护体",GrowInfo#p_role_pet_grow.con_level+1};
        ?GROW_TYPE_PHY_DEFENCE ->
            {"刀枪不入",GrowInfo#p_role_pet_grow.phy_defence_level+1};
        ?GROW_TYPE_MAGIC_DEFENCE ->
            {"气运丹田",GrowInfo#p_role_pet_grow.magic_defence_level+1};
        ?GROW_TYPE_PHY_ATTACK ->
            {"力敌千钧",GrowInfo#p_role_pet_grow.phy_attack_level+1};
        ?GROW_TYPE_MAGIC_ATTACK ->
            {"以柔克刚",GrowInfo#p_role_pet_grow.magic_attack_level+1}
    end.

check_grow_pre_skill_level(GrowInfo,GrowType) ->
    case GrowType of
        ?GROW_TYPE_CON ->
            GrowInfo#p_role_pet_grow.con_level =< GrowInfo#p_role_pet_grow.phy_attack_level
                orelse  GrowInfo#p_role_pet_grow.con_level =< GrowInfo#p_role_pet_grow.magic_attack_level;
        ?GROW_TYPE_PHY_DEFENCE ->
            GrowInfo#p_role_pet_grow.phy_defence_level < GrowInfo#p_role_pet_grow.con_level;
        ?GROW_TYPE_MAGIC_DEFENCE ->
            GrowInfo#p_role_pet_grow.magic_defence_level < GrowInfo#p_role_pet_grow.con_level;
        ?GROW_TYPE_PHY_ATTACK ->
            GrowInfo#p_role_pet_grow.phy_attack_level < GrowInfo#p_role_pet_grow.phy_defence_level
                orelse GrowInfo#p_role_pet_grow.phy_attack_level < GrowInfo#p_role_pet_grow.magic_defence_level;
        ?GROW_TYPE_MAGIC_ATTACK ->
            GrowInfo#p_role_pet_grow.magic_attack_level < GrowInfo#p_role_pet_grow.magic_defence_level
                orelse GrowInfo#p_role_pet_grow.magic_attack_level < GrowInfo#p_role_pet_grow.phy_defence_level
    end.
    
