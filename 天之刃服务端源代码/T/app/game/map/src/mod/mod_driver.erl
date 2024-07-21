%%% -------------------------------------------------------------------
%%% Author  : xiaosheng
%%% Description :
%%%
%%% Created : 2010-8-20
%%% -------------------------------------------------------------------
-module(mod_driver).

-include("mgeem.hrl").

-export([handle/1]).

-record(driver_rule, {min_lv, max_lv, cost, enable}).
-record(driver_config, {id, tx, ty, map_id, rule_list}).

-define(DRIVER_TYPE_AUTO, 0).
-define(DRIVER_TYPE_BIND_SILVER, 1).
-define(DRIVER_TYPE_SILVER, 2).


handle({Unique, _Module, Method, DataRecord, RoleID, Line, _State}) ->

    case Method of
        ?DRIVER_GO ->
            do_handle({go, Unique, Line, DataRecord, RoleID});
        Other ->
            ?ERROR_MSG("~ts:~w", ["未知的车夫消息", Other])
    end.

do_handle({go, Unique, Line, DataRecord, RoleID}) ->
    %%暂时全部成功
    
    #m_driver_go_tos{id=ID, type=_TypeTrue} = DataRecord,
    %%Type 不同支付类型 ?DRIVER_TYPE_AUTO为先扣绑定 再扣不绑定
    Type = ?DRIVER_TYPE_AUTO,

    case common_config_dyn:find(driver, ID) of
        [Config] ->
            do_go({Config, Unique, Line, Type, RoleID});
        _ ->
            DriverTocDataRecord = #m_driver_go_toc{succ=false, reason=?_LANG_SYSTEM_ERROR, id=ID},
            common_misc:unicast(Line, RoleID, Unique, ?DRIVER, ?DRIVER_GO, DriverTocDataRecord)  
    end,

    ok.

do_go({Config, Unique, Line, Type, RoleID}) ->
    
    #driver_config{id=ID, tx=TX, ty=TY, map_id=MapID, rule_list=RuleList} = Config,
    
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),

    Auth = do_go_auth(Config, Type, TX, TY, MapID, RuleList, RoleBase, RoleAttr),

    ResultTOC = 
        case Auth of
            {false, distance} ->
                %%?DEBUG("~ts", ["车夫传送非法，玩家与车夫距离不满足"]),
                #m_driver_go_toc{succ=false, reason=?_LANG_DRIVER_DISTANCE_ERROR, id=ID};

            {false, level} ->
                %%?DEBUG("~ts", ["车夫传送非法，玩家等级不满足"]),
                #m_driver_go_toc{succ=false, reason=?_LANG_DRIVER_LEVEL_NOT_MATCH, id=ID};

            {false, money} ->
                %%?DEBUG("~ts", ["车夫传送非法，玩家金钱不满足"]),
                #m_driver_go_toc{succ=false, reason=?_LANG_DRIVER_MONEY_NOT_ENOUGH, id=ID};

            {false, doing_ybc_mission} ->
                ?DEBUG("~ts", ["车夫传送非法，玩家正在做押镖任务"]),
                #m_driver_go_toc{succ=false, reason=?_LANG_DRIVER_DOING_YBC_MISSION, id=ID};
            {false, doing_role_trading} ->
                #m_driver_go_toc{succ=false, reason=?_LANG_DRIVER_DOING_ROLE_TRADING, id=ID};
            {false, map_faction_doing_personybc_faction} ->
                #m_driver_go_toc{succ=false, reason=?_LANG_DRIVER_MAP_FACTION_DOING_PERSONYBC_FACTION, id=ID};
            {false, red_name} ->
                #m_driver_go_toc{succ=false, reason=?_LANG_DRIVER_RED_NAME, id=ID};
            Rule ->
                #driver_rule{cost=CostTmp} = Rule,
                case check_waroffaction_driver(RoleBase#p_role_base.faction_id,MapID) of
                         true ->
                             Cost = 0;
                         false ->
                             Cost = CostTmp
                end,
                Result = 
                    common_transaction:transaction(
                      fun() ->
                              {ok, TrueRoleAttr} = mod_map_role:get_role_attr(RoleID),
                              t_cost_money(Type, Cost, TrueRoleAttr)
                      end),

                case Result of

                    {aborted, {man, not_enough_silver}} ->
                        #m_driver_go_toc{succ=false, reason=?_LANG_DRIVER_MONEY_NOT_ENOUGH, id=ID};

                    {aborted, Reason} ->
                        ?ERROR_MSG("~ts:~w", ["扣取玩家车夫传送银两失败了", Reason]),
                        #m_driver_go_toc{succ=false, reason=?_LANG_SYSTEM_ERROR, id=ID};

                    {atomic, {silver_both, NewSilverBind, NewSilver}} ->
                        ?DEBUG("~ts:~w", ["扣除不绑定银两级绑定银两成功", NewSilver]),
                        AttrChangeList = 
                            [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, 
                                                 new_value =NewSilver},
                             #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, 
                                                 new_value =NewSilverBind}],
                        do_notify_go_succ(Line, RoleID, MapID, TX, TY, AttrChangeList),
                        
                        #m_driver_go_toc{succ=true, id=ID, type=Type};

                    {atomic, {silver, NewSilver}} ->
                        ?DEBUG("~ts:~w", ["扣除不绑定银两成功", NewSilver]),
                        AttrChangeList = 
                            [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, 
                                                 new_value =NewSilver}],
                        do_notify_go_succ(Line, RoleID, MapID, TX, TY, AttrChangeList),
                        
                        #m_driver_go_toc{succ=true, id=ID, type=Type};

                    {atomic, {silver_bind, NewSilverBind}} ->

                        ?DEBUG("~ts:~w", ["扣除绑定银两成功", NewSilverBind]),
                        AttrChangeList = 
                            [#p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, 
                                                 new_value =NewSilverBind}],
                        do_notify_go_succ(Line, RoleID, MapID, TX, TY, AttrChangeList),
                        
                        #m_driver_go_toc{succ=true, id=ID, type=Type}

                end

        end,

    common_misc:unicast(Line, RoleID, Unique, ?DRIVER, ?DRIVER_GO, ResultTOC),

    ok.

do_notify_go_succ(Line, RoleID, MapID, TX, TY, AttrChangeList) ->
    %%强制玩家下马
    %%catch mod_equip_mount:force_mountdown(RoleID),
    
    common_misc:send_to_rolemap(RoleID, {mod_map_role, {change_map, RoleID, MapID, TX, TY, ?CHANGE_MAP_TYPE_DRIVER}}),

    MapChangeTocDataRecord = 
        #m_map_change_map_toc{succ=true, 
                              mapid=MapID, 
                              tx=TX, 
                              ty=TY},
    common_misc:role_attr_change_notify({line, Line, RoleID},RoleID, AttrChangeList),
    common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE, ?MAP, ?MAP_CHANGE_MAP, MapChangeTocDataRecord).
              
t_cost_money(?DRIVER_TYPE_AUTO, Cost, RoleAttr) ->
    #p_role_attr{role_id=RoleID, silver=Silver, silver_bind=SilverBind} = RoleAttr,
    SilverCheck = SilverBind + Silver - Cost,
    if
        SilverCheck < 0 ->
            common_transaction:abort({man, not_enough_silver});
        true ->
            ok
    end,
    SilverBind2 = SilverBind - Cost,
    Result = 
        if
            SilverBind2 < 0 ->
                Silver2 = Silver+SilverBind2,
                SilverBind3 = 0,
                common_consume_logger:use_silver({RoleAttr#p_role_attr.role_id, 
                                                  SilverBind, Cost-SilverBind, ?CONSUME_TYPE_SILVER_CHEFU, ""}),
                {silver_both, SilverBind3, Silver2};
            true ->
                Silver2 = Silver,
                SilverBind3 = SilverBind2,
                common_consume_logger:use_silver({RoleAttr#p_role_attr.role_id, 
                                    Cost, 0, ?CONSUME_TYPE_SILVER_CHEFU, ""}),
                {silver_bind, SilverBind3}
        end,
    NewRoleAttr =  RoleAttr#p_role_attr{silver_bind=SilverBind3, silver=Silver2},
    mod_map_role:set_role_attr(RoleID, NewRoleAttr),
    Result;

t_cost_money(?DRIVER_TYPE_BIND_SILVER, Cost, RoleAttr) ->
    SilverBind = RoleAttr#p_role_attr.silver_bind - Cost,
    if
        SilverBind =< 0 ->
            db:abort({man, not_enough_silver});
        true ->
            ok
    end,
    NewRoleAttr =  RoleAttr#p_role_attr{silver_bind=SilverBind},
    mod_map_role:set_role_attr(RoleAttr#p_map_role.role_id, NewRoleAttr),
    common_consume_logger:use_silver({RoleAttr#p_role_attr.role_id, 
                                      Cost, 0, ?CONSUME_TYPE_SILVER_CHEFU, ""}),
    {silver_bind, SilverBind};

t_cost_money(?DRIVER_TYPE_SILVER, Cost, RoleAttr) ->
    Silver = RoleAttr#p_role_attr.silver - Cost,
    if
        Silver =< 0 ->
            db:abort({man, not_enough_silver});
        true ->
            ok
    end,
    NewRoleAttr =  RoleAttr#p_role_attr{silver=Silver},
    mod_map_role:set_role_attr(RoleAttr#p_role_attr.role_id, NewRoleAttr),
    {silver, Silver};

t_cost_money(_, _, _) ->
    db:abort({man, not_match}).

do_go_auth(Config, Type, TX, TY, MapID, RuleList, RoleBase, RoleAttr) ->
    do_go_auth_2(Config, Type, TX, TY, MapID, RuleList, RoleBase, RoleAttr).

%%判断玩家与npc的距离
do_go_auth_2(Config, Type, _TX, _TY, _MapID, RuleList, RoleBase, RoleAttr) ->
    %%暂时直接跳过
    do_go_auth_3(Config, Type, RuleList, RoleBase, RoleAttr).

%%判断红名
do_go_auth_3(Config, Type, RuleList, RoleBase, RoleAttr) ->
    #p_role_base{pk_points=PkPoints} = RoleBase,
    case PkPoints >= ?RED_NAME_PKPOINT of
        true ->
            {false, red_name};
        _ ->
            do_go_auth_4(Config, Type, RuleList, RoleBase, RoleAttr)
    end.

%%判断等级
do_go_auth_4(Config, Type, RuleList, RoleBase, RoleAttr) ->
    RoleLevel = RoleAttr#p_role_attr.level,
    LevelMatchRule = match_level(RuleList, RoleLevel),
    if
        LevelMatchRule =:= false ->
            {false, level};
        true ->
            do_go_auth_5(Config, Type, LevelMatchRule, RoleBase, RoleAttr)
    end.

match_level([], _RoleLevel) ->
    false;
match_level([Rule|RuleList], RoleLevel) ->
    #driver_rule{min_lv=MinLv, max_lv=MaxLv, cost=_Cost, enable=Enable} = Rule,
    if
        (MinLv =:= 0 orelse RoleLevel >= MinLv) 
        andalso 
        (MaxLv =:= 0 orelse RoleLevel =< MaxLv) -> 
            if
                Enable =:= false ->
                    false;
                true ->
                    Rule
            end;
        true ->
            match_level(RuleList, RoleLevel)
    end.

%%判断金钱
do_go_auth_5(Config, Type, Rule, RoleBase, RoleAttr) ->
    #driver_rule{cost=Cost} = Rule,
    Silver = RoleAttr#p_role_attr.silver,
    SilverBind = RoleAttr#p_role_attr.silver_bind,
    Auth = 
        if
            ?DRIVER_TYPE_BIND_SILVER =:= Type ->
                SilverBind >= Cost;
            ?DRIVER_TYPE_SILVER =:= Type ->
                Silver >= Cost;
            ?DRIVER_TYPE_AUTO =:= Type ->
                Silver + SilverBind >= Cost;
            true ->
                false
        end,

    if
        Auth =:= true ->
            do_go_auth_7(Config, Type, Rule, RoleBase, RoleAttr);
        true ->
            {false, money}
    end.

%%判断拉镖任务
%% do_go_auth_6(Config, Type, Rule, RoleBase, RoleAttr) ->
%%     %%{false, doing_ybc_mission};
%%     RoleID = RoleBase#p_role_base.role_id,
%%     IsDoingYbcMission = common_map:is_doing_ybc(RoleID),
%%     if IsDoingYbcMission =:= true ->
%%             {false, doing_ybc_mission};
%%         true ->
%%             %% mod by caochuncheng 添加判断商贸状态不能使用车夫
%%             do_go_auth_7(Config, Type, Rule, RoleBase, RoleAttr)
%%     end.
do_go_auth_7(Config, Type, Rule, RoleBase, RoleAttr) ->
    RoleID = RoleBase#p_role_base.role_id,
    [RoleState] = db:dirty_read(?DB_ROLE_STATE, RoleID),
    #r_role_state{trading = Trading} = RoleState,
    ToMapId = Config#driver_config.map_id,
    MapId = mgeem_map:get_mapid(),
    AllowMapIDList = [10300, 11111, 12111, 13111],
    ToMapIsAllow = lists:member(ToMapId, AllowMapIDList),
    CurrentMapIsAllow = lists:member(MapId, AllowMapIDList),
    
    if 
       ToMapIsAllow =:= true 
         orelse
       CurrentMapIsAllow =:= true ->
            do_go_auth_8(Config, Type, Rule, RoleBase, RoleAttr);
       true ->
            if Trading =:= 1 ->
                    {false, doing_role_trading};
               true ->
                    do_go_auth_8(Config, Type, Rule, RoleBase, RoleAttr)
            end
    end.

do_go_auth_8(Config, _Type, Rule, RoleBase, _RoleAttr) ->
    #driver_config{map_id=MapID} = Config,
    RoleFaction=RoleBase#p_role_base.faction_id,
    case mod_map_role:get_map_faction_id(MapID) of
        {ok, MapFactionID} ->
            case mod_ybc_person:faction_ybc_status(MapFactionID) of
                {activing, {ContinueTime, _}} ->
                    if
                        ContinueTime < 600 andalso MapFactionID =/= RoleFaction ->
                            {false, map_faction_doing_personybc_faction};
                        true ->
                            Rule    
                    end;
                _ ->
                    Rule
            end;
        _ ->
            Rule
    end.
    

%%判断是否在国战期间攻击方传送到敌国的边境
check_waroffaction_driver(FactionID,MapID) ->
    List = [11105,12105,13105],
    case lists:member(MapID, List) of
        false ->
            false;
        _ ->
            case db:dirty_read(?DB_WAROFFACTION, 1) of
                [] ->
                    false;
                [#r_waroffaction{defence_faction_id=DefenceFactionID, attack_faction_id=AttackFactionID}] ->
                    case FactionID =:= AttackFactionID of
                        true ->
                            case DefenceFactionID of
                                1 ->
                                    MapID =:= 11105;
                                2 ->
                                    MapID =:= 12105;
                                3 ->
                                    MapID =:= 13105
                            end;
                        false ->
                            false
                    end;
                _ ->
                    false
            end
    end.
