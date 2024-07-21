%% Author: liuwei
%% Created: 2010-9-15
%% Description: TODO: Add description to mod_map_drop
-module(mod_map_family).

-include("mgeem.hrl").

-export([
         handle/2
        ]).

%%
%% API Functions
%%

handle({Unique, ?FAMILY, ?FAMILY_DONATE, Record, RoleID, PID, _Line},_State)->
    do_family_donate(Unique,Record,RoleID,PID);

handle({reborn_family_uplevel_boss, FamilyID, MonsterType}, _State) ->
    Fun = fun() -> ?DEBUG("~ts", ["重生门派升级boss成功"]) end,
    mod_map_monster:create_family_boss(uplevel, FamilyID, MonsterType, Fun);

handle({reborn_family_common_boss, FamilyID, MonsterType}, _State) ->
    Fun = fun() -> ?DEBUG("~ts", ["重生门派boss成功"]) end,
    mod_map_monster:create_family_boss(common, FamilyID, MonsterType, Fun);

handle({call_family_common_boss, Unique, Module, Method, {FamilyID, MonsterType}, RoleID, Line}, _State) ->
    Fun = fun() ->
                  ?DEBUG("~ts", ["召唤门派boss成功"]),
                  R = #m_family_call_commonboss_toc{},
                  common_misc:unicast(Line, RoleID, Unique, Module, Method, R)
          end,
    mod_map_monster:create_family_boss(common, FamilyID, MonsterType, Fun);

handle({call_family_uplevel_boss, Unique, Module, Method, {FamilyID, MonsterType}, RoleID, Line}, _State) ->
    Fun = fun() ->
                  ?DEBUG("~ts", ["召唤门派升级boss成功"]),
                  R = #m_family_call_uplevelboss_toc{},
                  common_misc:unicast(Line, RoleID, Unique, Module, Method, R)
          end,
    mod_map_monster:create_family_boss(uplevel, FamilyID, MonsterType, Fun);
%% 退出门派
handle({cancel_role_family_info, RoleID,cancel_family}, State) ->
    do_cancel_role_family_info(RoleID, State);
%% 门派贡献度
handle({update_role_family_info, RoleID, family_contribute,NewFC}, State) ->
    do_update_role_family_contribute(RoleID, NewFC, State);
%% 加入门派
handle({update_role_family_info, RoleID, join_family,FamilyId,FamilyName,FamilyLevel}, State) ->
    do_update_role_family_info(RoleID, FamilyId,FamilyName,FamilyLevel,State);
%% 清除门派技能
handle({clear_role_family_skill, RoleID}, _State) ->
    do_clear_role_family_skill(RoleID);
%% 
handle({fetch_family_buff,From,RoleID,FmlBuffID,BuffLevel}, _State) ->
    do_fetch_family_buff(From,RoleID,FmlBuffID,BuffLevel);

handle({family_map_roles,From,CombineTerm}, _State) ->
   	MapRoles = mod_map_actor:get_in_map_role(),
	From ! {family_map_roles,MapRoles,CombineTerm};

%%关闭门派地图
handle(kill_family_map,_State)->
    erlang:send_after(60000,self(),maintain_family_fail);

handle({broadcast_to_all_inmap_member, Module, Method, Record}, _State) ->
    do_broadcast_to_all_inmap_member(Module, Method, Record);

handle({broadcast_to_all_inmap_member_except, Module, Method, Record, RoleID}, _State) ->
    do_broadcast_to_all_inmap_member_except(Module, Method, Record, RoleID);

handle({kick_role, RoleID}, _State) ->
    do_kick_role(RoleID);

handle(kick_all_role, _State) ->
    do_kick_all_role();

handle(maintain_family_fail, _State)->
    common_map:exit(kill_family_map_exit);

handle(Msg,_State) ->
    ?ERROR_MSG("uexcept msg = ~w",[Msg]).


%%
%% Local Functions
%%
%% 踢掉当前地图的所有玩家
do_kick_all_role() ->    
    [begin
         do_kick_role(RoleID)
     end || RoleID <- mgeem_map:get_all_roleid()],
    ok.

do_kick_role(RoleID) ->
    case mod_map_role:get_role_base(RoleID) of
        {ok, #p_role_base{faction_id=FactionID}} ->
            MapID = common_misc:get_home_map_id(FactionID),
            {MapID, TX, TY} = common_misc:get_born_info_by_map(MapID),
            mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, MapID, TX, TY);
        _ ->
            ignore
    end.

%% 广播通知地图内的所有玩家
do_broadcast_to_all_inmap_member(Module, Method, Record) ->
    Binary = mgeeg_packet:packet_encode(?DEFAULT_UNIQUE, Module, Method, Record),
    [begin
         common_misc:unicast(RoleID, Binary)
     end || RoleID <- mgeem_map:get_all_roleid()],
    ok.

do_broadcast_to_all_inmap_member_except(Module, Method, Record, RoleID) ->
    Binary = mgeeg_packet:packet_encode(?DEFAULT_UNIQUE, Module, Method, Record),
    [begin
         common_misc:unicast(RID, Binary)
     end || RID <- lists:delete(RoleID, mgeem_map:get_all_roleid())],
    ok.
do_fetch_family_buff(From,RoleID,FmlBuffID,BuffLevel)->
    [FmlBuffList] = common_config_dyn:find(family_buff,FmlBuffID),
    #r_family_buff{buff_id=BuffID} = lists:keyfind(BuffLevel,#r_family_buff.buff_level,FmlBuffList),
    
    %%设置BUFF
    try
        {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
        mod_role_buff:add_buff(RoleID, RoleID, role, BuffDetail),
        From ! {fetch_family_buff_result,true,{RoleID,FmlBuffID}}
    catch
        _:Reason->
            From ! {fetch_family_buff_result,false,{RoleID,Reason,FmlBuffID,BuffLevel}}
    end.
    

%%@doc 清空玩家的门派技能（在离开门派之后）
do_clear_role_family_skill(RoleID)->
    mod_skill:clear_family_skill(RoleID).

%%@doc 清除个人的门派信息，包括清空门派技能
do_cancel_role_family_info(RoleID, State) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            nil;
        MapRoleInfo ->
            mod_mission_handler:handle({listener_dispatch, family_changed, RoleID, 0, MapRoleInfo#p_map_role.family_id}),
            mod_skill:clear_family_skill(RoleID),
            NewMapRoleInfo = MapRoleInfo#p_map_role{family_id=0, family_name=[]},
            mod_map_actor:set_actor_mapinfo(RoleID, role, NewMapRoleInfo),
            {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
            RoleBase2 = RoleBase#p_role_base{family_id=0, family_name=[]},
            common_transaction:transaction(fun() -> mod_map_role:set_role_base(RoleID, RoleBase2) end),
            %%广播通知
            Record = #m_map_update_actor_mapinfo_toc{actor_id = RoleID,actor_type = ?TYPE_ROLE,role_info = NewMapRoleInfo},
            mgeem_map:do_broadcast_insence_include([{role,RoleID}],?MAP,?MAP_UPDATE_ACTOR_MAPINFO,Record,State)
    end. 

%% 同步更新地图进程字典中，玩家的门派ID、门派名称
%%do_update_role_family_info(RoleID, FamilyInfo, State) ->
do_update_role_family_info(RoleID, FamilyId,FamilyName, FamilyLevel,State) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            nil;
        MapRoleInfo ->
            hook_mission_event:hook_special_event(RoleID,?MISSON_EVENT_JOIN_FAMILY),
            common_mod_goal:hook_family_change(RoleID, FamilyId),
            case FamilyId > 0 of
                true ->
                    common_mod_goal:family_level_up([RoleID],FamilyLevel);
                _ ->
                    ignore
            end,
            mod_mission_handler:handle({listener_dispatch, family_changed, RoleID, FamilyId, MapRoleInfo#p_map_role.family_id}),
            case FamilyId =:= 0 of
                true ->
                    mod_accumulate_exp:role_exit_family(RoleID);
                false ->
                    ignore
            end,
            NewMapRoleInfo = MapRoleInfo#p_map_role{family_id=FamilyId, family_name=FamilyName},
            mod_map_actor:set_actor_mapinfo(RoleID, role, NewMapRoleInfo),
            {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
            RoleBase2 = RoleBase#p_role_base{family_id=FamilyId, family_name=FamilyName},
            common_transaction:transaction(fun() -> mod_map_role:set_role_base(RoleID, RoleBase2) end),
            Record = #m_map_update_actor_mapinfo_toc{actor_id = RoleID,actor_type = ?TYPE_ROLE,role_info = NewMapRoleInfo},
            mgeem_map:do_broadcast_insence_include([{role,RoleID}],?MAP,?MAP_UPDATE_ACTOR_MAPINFO,Record,State)
    end.

%% 同步更新地图进程字典中，玩家的门派贡献度
do_update_role_family_contribute(RoleID, NewFC, _State) ->
	NewFC2 = if NewFC < 0 -> 0; true -> NewFC end,
	case mod_map_role:get_role_attr(RoleID) of
		{ok, RoleAttr} ->
			RoleAttr2 = RoleAttr#p_role_attr{family_contribute = NewFC2},
			common_transaction:transaction(
			  fun() ->
					  mod_map_role:set_role_attr(RoleID, RoleAttr2) 
			  end);
		_Error ->
			?DEBUG("玩家:~w已经下线",[RoleID]),
			ignore
	end.

do_family_donate(Unique,DataIn,RoleID,PID)->
    case catch check_can_donate(DataIn,RoleID) of
        {ok,FamilyID}->
            do_family_donate2(Unique,DataIn,RoleID,PID,FamilyID);
        {error,Reason,ReasonCode}->
            do_donate_error({Unique,DataIn,RoleID,PID},Reason,ReasonCode)
    end.

-define(donate_gold,1).
-define(donate_silver,2).

do_family_donate2(Unique,DataIn,RoleID,PID,FamilyID)->
    #m_family_donate_tos{donate_type=DonateType,
                         donate_value=DonateValue}=DataIn,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    case common_transaction:transaction(
           fun()->
                   case DonateType of
                       ?donate_gold->
                           case RoleAttr#p_role_attr.gold>= DonateValue of
                               true->
                                   NewRoleAttr = RoleAttr#p_role_attr{gold=RoleAttr#p_role_attr.gold-DonateValue},
                                   mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                                   common_consume_logger:use_gold({RoleID,0,DonateValue,
                                                                   ?CONSUME_TYPE_GOLD_FAMILY_DONATE,
                                                                   common_tool:to_list(NewRoleAttr#p_role_attr.family_contribute)});
                               false->
                                   NewRoleAttr = RoleAttr,
                                   common_transaction:abort({?_LANG_FAMILY_DOANTE_NO_ENOUGH_GOLD,0})
                           end;
                       ?donate_silver->
                           case RoleAttr#p_role_attr.silver>= DonateValue of
                               true->
                                   NewRoleAttr = RoleAttr#p_role_attr{silver=RoleAttr#p_role_attr.silver-DonateValue},
                                   mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                                   common_consume_logger:use_silver({RoleID,0,DonateValue,
                                                                     ?CONSUME_TYPE_SIVLER_FAMILY_DONATE,
                                                                     common_tool:to_list(NewRoleAttr#p_role_attr.family_contribute)});
                               false->
                                   NewRoleAttr = RoleAttr,
                                   common_transaction:abort({?_LANG_FAMILY_DOANTE_NO_ENOUGH_SILVER,0})
                           end
                   end,
                   NewRoleAttr
           end) of
        {abort,{Reason,ReasonCode}}->
            do_donate_error({Unique,DataIn,RoleID,PID},Reason,ReasonCode);
        {atomic,NewRoleAttr}->
            case DonateType of
                ?donate_gold->
                    common_misc:send_role_gold_change(RoleID, NewRoleAttr);
                ?donate_silver->
                    common_misc:send_role_silver_change(RoleID,NewRoleAttr)
            end,
             case global:whereis_name(mod_family_manager) of
                undefined ->
                    ignore;
                GPID ->
                    GPID ! {family_donate,FamilyID,RoleAttr#p_role_attr.role_name,{Unique,DataIn,RoleID,PID}}
            end
    end.


check_can_donate(DataIn,RoleID)->
    {ok,#p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    case FamilyID>0 of
        true->
            next;
        false->
            erlang:throw({error,?_LANG_FAMILY_NO_FAMILY,0})
    end,
    case DataIn#m_family_donate_tos.donate_type=:=?donate_gold 
                                    orelse DataIn#m_family_donate_tos.donate_type=:=?donate_silver of
        true->
            next;
        false->
            erlang:throw({error,?_LANG_FAMILY_DOANTE_TYPE_ERROR,0})
    end,
    case DataIn#m_family_donate_tos.donate_value>0 of
        true->
            {ok,FamilyID};
        false->
            {error,?_LANG_FAMILY_DOANTE_MONEY_ERROR,0}
    end. 
    
    
do_donate_error({Unique,_Record,_RoleID,PID},Reason,ReasonCode)->
    ?ERROR_MSG("Reason:~w~n",[Reason]),
    R=#m_family_donate_toc{succ=false,
                           reason=Reason,
                           reason_code=ReasonCode},
    common_misc:unicast2(PID, Unique, ?FAMILY, ?FAMILY_DONATE, R).

