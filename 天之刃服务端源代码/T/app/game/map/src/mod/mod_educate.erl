%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2011, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 10 Apr 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_educate).

-include("mgeem.hrl").

%% API
-export([
         handle/1,handle/2
        ]).
handle(Info,_State) ->
    handle(Info).

%% 结为师徒
handle({_Unique, _Module, ?EDUCATE_SWORN_MENTORING, _DataIn, _RoleID, _PID, _Line}=Info) ->
    do_educate_sworn_mentoring(Info);
handle({set_can_jump, RoleID}) ->
    set_can_jump(RoleID);
handle({sure_jump, RoleID}) ->
    sure_jump(RoleID);
handle(Info) ->
    ?ERROR_MSG("~ts:~w", ["未知的消息", Info]).

%% 结为师徒
do_educate_sworn_mentoring({Unique, Module, Method, DataIn, RoleID, PID, _Line}=Info)->
    #m_educate_sworn_mentoring_tos{roleid=RoleIDSec}= DataIn,
    [{X,Y}]=common_config_dyn:find(educate,range),    
    case mod_map_role:get_role_pos(RoleID) of
        {ok, #p_pos{tx=TX, ty=TY}} ->
            case mod_map_role:get_role_pos(RoleIDSec) of
                {ok, #p_pos{tx=TXSec, ty=TYSec}} ->
                    case common_misc:check_distance(TX, TY, TXSec, TYSec, X, Y) of
                        true ->
                            R2 = #m_educate_sworn_mentoring_toc{succ=false,reason=?_LANG_EDUCATE_NPC_RANGE},
                            common_misc:unicast2(PID, Unique, Module, Method, R2);
                        false ->                            
                            case common_misc:team_get_team_member(RoleID) of
                                [RoleID,RoleIDSec]->
                                    global:send(mgeew_educate_server, Info);
                                [RoleIDSec,RoleID]->
                                    global:send(mgeew_educate_server, Info);
                                _ ->
                                    R2 = #m_educate_sworn_mentoring_toc{succ=false,reason=?_LANG_EDUCATE_NOT_TEAM},
                                    common_misc:unicast2(PID, Unique, Module, Method, R2)
                            end
                    end;
                _ ->
                    R2 = #m_educate_sworn_mentoring_toc{succ=false,reason=?_LANG_EDUCATE_NPC_RANGE},
                    common_misc:unicast2(PID, Unique, Module, Method, R2)
            end;
        _ ->
            R2 = #m_educate_sworn_mentoring_toc{succ=false,reason=?_LANG_EDUCATE_NPC_RANGE},
            common_misc:unicast2(PID, Unique, Module, Method, R2)
    end.

%% 设置玩家可以免费传送, 专门传送到李梦阳那里
set_can_jump(RoleID) ->
    {ok, #p_role_base{faction_id=FactionID}} = mod_map_role:get_role_base(RoleID),
    MapID = common_tool:to_integer(lists:concat([1, FactionID, "100"])),
    erlang:put({enter, RoleID}, {MapID, 195, 131}),
    erlang:put({change_map_type, RoleID}, ?CHANGE_MAP_TYPE_EDUCATE).



%% 发送自mgeew_educate_server
sure_jump(RoleID) ->
    case check_role_state(RoleID) of
        {error, Reason} ->
            common_broadcast:bc_send_msg_role(RoleID,?BC_MSG_TYPE_SYSTEM, ?BC_MSG_SUB_TYPE, Reason);
        ok ->
            case erlang:get({enter, RoleID}) of
                undefined ->
                    ignore;
                {MapID, TX, TY} ->
                    erlang:put({change_map_type, RoleID}, ?CHANGE_MAP_TYPE_EDUCATE),
                    R = #m_map_change_map_toc{mapid=MapID, tx=TX, ty=TY},
                    hook_map_role:hook_change_map_by_call(?CHANGE_MAP_TYPE_EDUCATE, RoleID),
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?MAP, ?MAP_CHANGE_MAP, R)
            end
    end.

check_role_state(RoleID) ->
    try
        RoleMapInfo =  mod_map_actor:get_actor_mapinfo(RoleID, role),
        ?DEBUG("RoleID State:~w~n",[RoleMapInfo#p_map_role.state]),
        case mod_map_role:is_role_fighting(RoleID) of
            true -> throw({error,?_LANG_COUNTRY_TREASURE_IN_FIGHTING_STATUS});
            false -> next
        end,
        if RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_STALL 
           orelse RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_STALL_AUTO
           orelse RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_STALL_SELF ->
                ?DEBUG("~ts",["玩家处理摆摊状态"]),
                throw({error,?_LANG_COUNTRY_TREASURE_IN_STALL_STATUS});
           RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_DEAD ->
                ?DEBUG("~ts",["玩家处于死亡状态"]),
                throw({error,?_LANG_COUNTRY_TREASURE_IN_DEAD_STATUS});
           RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_FIGHT ->
                ?DEBUG("~ts",["玩家处于战斗状态"]),
                throw({error,?_LANG_COUNTRY_TREASURE_IN_FIGHTING_STATUS});
           RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_EXCHANGE ->
                ?DEBUG("~ts",["玩家处于交易状态"]),
                throw({error,?_LANG_COUNTRY_TREASURE_IN_EXCHANGE_STATUS});
           RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_TRAINING ->
                ?DEBUG("~ts",["玩家处于离线挂机状态"]),
                throw({error,?_LANG_COUNTRY_TREASURE_IN_TRAINING_STATUS});
           RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_COLLECT ->
                throw({error,?_LANG_COUNTRY_TREASURE_COLLECT_STATUS});
           RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_TRAINING ->
                throw({error,?_LANG_COUNTRY_TREASURE_TRAINING_STATUS});
           true ->
                next
        end,
        %% 商贸状态
        [RoleState] = db:dirty_read(?DB_ROLE_STATE, RoleID),
        if RoleState#r_role_state.trading =:= 1 ->
                ?DEBUG("~ts",["玩家处于商贸状态"]),
                throw({error,?_LANG_COUNTRY_TREASURE_IN_TRADING_STATUS});
           RoleState#r_role_state.exchange =:= true ->
                ?DEBUG("~ts",["玩家处于交易状态"]),
                throw({error,?_LANG_COUNTRY_TREASURE_IN_EXCHANGE_STATUS});
           true ->
                next
        end,
        CurMapId = mgeem_map:get_mapid(),
        case CurMapId rem 10000 div 1000 of
            0 ->
                case CurMapId rem 10000 rem 1000 div 100 of
                    2 ->
                        ok;
                    3 ->
                        ok;
                    _ ->
                        ?DEBUG("~ts,CurMapId=~w",["玩家处于副本",CurMapId]),
                        throw({error,?_LANG_COUNTRY_TREASURE_IN_FB_MAP})
                end;
            1 ->
                ok;
            2 ->
                ok;
            3 ->
                ok;
            _ ->
                ?DEBUG("~ts,CurMapId=~w",["玩家处于特殊地图",CurMapId]),
                throw({error,?_LANG_COUNTRY_TREASURE_IN_SPECIAL_MAP})
        end,
        ok
    catch
        throw:{error, Reason} ->
            {error, Reason};
        _:_ ->
            {error, ?_LANG_SYSTEM_ERROR}
    end.
                                      

    

