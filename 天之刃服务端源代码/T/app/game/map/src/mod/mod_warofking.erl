%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc 抢国王模块
%%%
%%% @end
%%% Created :  7 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_warofking).

%% API
-export([
         handle/2, do_handle_info/2,
         init_map_data/2,
         break_holding/1,
         add_family_mark/1,
         check_end_of_war/0,
         is_in_safetime/0,
         if_begin_warofking/0,
         get_warofking_born_info/2,
         is_warofking_map/0
        ]).

-include("mgeem.hrl").


%%进程字典键值，值形式为{roleid, time} 表示谁占领了多久王座
-define(roleid_get_king_flag, roleid_get_king_flag).

%%国王争霸战是否开始了
-define(if_begin_war_of_king, if_begin_war_of_king).

%%哪些门派参与了国王争霸战
-define(join_family_for_king, join_family_for_king).

-define(role_mark_list, role_mark_list).

-define(family_mark_list, family_mark_list).

-define(endtime_of_warofking, endtime_of_warofking).

-define(WAROFKING_NOT_SAFE, warofking_not_safe).

-define(WAROFKING_SAFETIME_END, warofking_safetime_end).

%%标示能否开始占领王座
-define(warofking_can_hold_flag, warofking_can_hold_flag).

-define(set_can_hold, set_can_hold).

-define(warofking_can_hold_ref, warofking_can_hold_ref).

-define(WAROFKING_TIME_AFTER_SAFE, 240 * 1000).

-define(warofking_all_roleid_list, warofking_all_roleid_list).

-define(warofking_role_can_enter_flag, warofking_role_can_enter_flag).

-define(warofking_family_allow_list, warofking_family_allow_list).


%%初始化一些数据
init_map_data(MapID, _MapName) 
  when MapID =:= 11111 orelse MapID =:= 12111 orelse MapID =:= 13111 ->
    %%读取数据库记录以防止地图重启后导致所有的记录全部被删除
    %%抢国王是否已经开始 
    erlang:put(?if_begin_war_of_king, false),
    %%参与抢国王的门派列表
    erlang:put(?join_family_for_king, []),
    %%当前由谁占领了王座多长时间，为0代表没有占领王座
    erlang:put(?roleid_get_king_flag, {0, 0}),
    %%角色获取的积分列表 格式为 {roleid, role_name, family_id, family_name, marks}
    erlang:put(?role_mark_list, []),
    %%门派获取的积分列表, 格式为 {family_id, family_name, marks, condition_rankno}
    %% condition_rankno 表示进入战场时的入选条件排名
    %% 国王争霸战开始之前需要重新初始化一次，按照国王争霸战的选拔资格来排序
    erlang:put(?family_mark_list, []),
    init_all_roleid_list(),
    set_cannot_hold(),
    %% 获得四个出生点,如果没有，则随机四个
    BornList = ets:lookup(?ETS_IN_MAP_DATA, {born_point, MapID}),
    {_, BornList2} = lists:foldl(
                       fun({_, {TX, TY}}, {Index, Acc}) ->
                               {Index + 1, [{Index+1, {TX, TY}} | Acc]}
                       end, {0, []}, BornList),
    erlang:put(warofking_born_list, BornList2),
    ok;
init_map_data(_MapID, _MapName) ->
    ok.

get_warofking_born_info(RoleMapInfo, MapID) ->
    #p_map_role{family_id=FamilyID} = RoleMapInfo,
    {TX, TY} = get_family_relive_point(FamilyID),
    {MapID, TX, TY}.


is_warofking_map() ->
    MapID = mgeem_map:get_mapid(),
    MapID =:= 11111 orelse MapID =:= 12111 orelse MapID =:= 13111.

clear_map() ->
    put(?if_begin_war_of_king, false),
    put(?join_family_for_king, []),
    put(?roleid_get_king_flag, {0, 0}),
    put(?role_mark_list, []),
    put(?family_mark_list, []),
    set_cannot_hold(),
    RoleIDList = get_all_roleid_list(),
    lists:foreach(
      fun(RoleID) ->
              erlang:erase({?warofking_role_can_enter_flag, RoleID})
      end, RoleIDList),
    clear_all_roleid_list(),
    ok.


%%是否处于抢国王的安全期内
is_in_safetime() ->
    case get(?if_begin_war_of_king) of
        true ->
            case get(?WAROFKING_NOT_SAFE) of
                true ->
                    false;
                _ ->
                    true
            end;
        _ ->
            false
    end.

if_begin_warofking() ->
    case get(?if_begin_war_of_king) of
        true ->
            true;
        _ ->
            false
    end.


%%增加门派的积分
add_family_mark(RoleID) ->
    case if_begin_warofking() of
        true ->
            {ok, #p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
            case FamilyID > 0 of
                true ->
                    FamilyMarkList = get(?family_mark_list),
                    case lists:keyfind(FamilyID, 1, FamilyMarkList) of
                        false ->
                            %% 这种情况是上次有人在这里面
                            ignore;                        
                        {FamilyID, FamilyName, OldMarks} ->
                            FamilyMarkList2 = lists:keydelete(FamilyID, 1, FamilyMarkList),
                            FamilyMarkList3 = [{FamilyID, FamilyName, OldMarks+1} | FamilyMarkList2],
                            put(?family_mark_list, FamilyMarkList3)
                    end;
                false ->
                    ignore
            end;
        false ->
            ignore
    end.


%%某些动作会导致玩家不能继续占领王座
break_holding(RoleID) ->
    case if_begin_warofking() of
        true ->
            {HoldingRoleID, _HoldingTime} = get(?roleid_get_king_flag),
            case HoldingRoleID =:= RoleID of
                true ->
                    R = #m_warofking_break_toc{role_id=RoleID},
                    State = mgeem_map:get_state(),
                    mgeem_map:do_broadcast_insence_include([{role, HoldingRoleID}], ?WAROFKING, ?WAROFKING_BREAK, R, State),
                    %%此时应该广播告诉大家，该角色失去对王座的占领
                    put(?roleid_get_king_flag, {0, 0});
                false ->
                    ignore
            end;
        false ->
            ignore
    end.


%%检查是否达成了抢国王完成的条件
check_end_of_war() ->
    case if_begin_warofking() of
        true ->    
            %%判断是否有人占领王座30秒以上
            {HoldingRoleID, HoldingTime} = get(?roleid_get_king_flag),
            ?DEBUG("~p", [{HoldingRoleID, HoldingTime}]),
            case HoldingRoleID > 0 of
                true ->
                    check_end_of_war2(HoldingRoleID, HoldingTime);                    
                false ->
                    ignore
            end;
        false ->
			ignore
    end.

check_end_of_war2(HoldingRoleID, HoldingTime) ->
    case HoldingTime >= 60 of
        true ->
            {ok, #p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(HoldingRoleID),
            case FamilyID > 0 of
                true ->
                    do_end_war(get_flag);
                false ->
                    break_holding(HoldingRoleID)
            end;
        false ->
            do_update_holding(HoldingRoleID, HoldingTime)
    end.

do_update_holding(HoldingRoleID, HoldingTime) ->
    put(?roleid_get_king_flag, {HoldingRoleID, HoldingTime+1}),
    %%广播给这个玩家的周围玩家
    R = #m_warofking_holding_toc{role_id=HoldingRoleID, time=HoldingTime+1, total_time=60},                  
    mgeem_map:do_broadcast_insence_include([{role, HoldingRoleID}], ?WAROFKING, ?WAROFKING_HOLDING, R, mgeem_map:get_state()).

handle(Info, State) ->
    do_handle_info(Info, State).


%%获取门派积分列表
do_handle_info({Unique, ?WAROFKING, ?WAROFKING_GETMARKS, _, RoleID, _PID, Line}, _State) ->
    case if_begin_warofking() of
        true ->
            FamilyMarkListTmp = get(?family_mark_list),
            FamilyMarkList = lists:foldl(
                               fun({FID, FName, Mark}, Acc) ->
                                       [#p_warofking_mark{family_id=FID, family_name=FName, mark=Mark, rankno=0} | Acc]
                               end, [], FamilyMarkListTmp);
        false ->
            FamilyMarkList = []
    end,
    R = #m_warofking_getmarks_toc{result=FamilyMarkList},
    common_misc:unicast(Line, RoleID, Unique, ?WAROFKING, ?WAROFKING_GETMARKS, R);


%%占领王座
do_handle_info({Unique, Module, ?WAROFKING_HOLD, _, RoleID, _PID, Line}, State) ->
    case if_begin_warofking() of
        true ->
            do_hold(Unique, Module, ?WAROFKING_HOLD, RoleID, Line, State);
        false ->
            do_hold_error(Unique, Module, ?WAROFKING_HOLD, ?_LANG_WAROFKING_NOT_BEGIN, RoleID, Line)
    end;

%%请求获取安全期剩余时间
do_handle_info({Unique, Module, ?WAROFKING_SAFETIME, _, RoleID, _PID, Line}, _State) ->
    case if_begin_warofking() of
        true ->
            do_get_safetime(Unique, Module, ?WAROFKING_SAFETIME, RoleID, Line);
        false ->
            do_get_safetime_error(Unique, Module, ?WAROFKING_SAFETIME, ?_LANG_WAROFKING_NOT_BEGIN, RoleID, Line)
    end;

%% 请求进入王座争霸战地图
do_handle_info({Unique, Module, ?WAROFKING_ENTER, _, RoleID, _PID, Line}, _State) ->
    {ok, #p_role_base{faction_id=FactionID}} = mod_map_role:get_role_base(RoleID),
    MapID = mgeem_map:get_mapid(),
    case FactionID of
        1 ->
            TMapID = 11111;
        2 ->
            TMapID = 12111;
        _ ->
            TMapID = 13111
    end,
    case MapID =:= TMapID of
        true ->
            R = #m_warofking_enter_toc{},
            common_misc:unicast(Line, RoleID, Unique, Module, ?WAROFKING_ENTER, R),
            ignore;
        false ->
            {ok, #p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
            global:send(common_misc:get_common_map_name(TMapID), {mod_warofking, {enter, Unique, RoleID, FamilyID, Line}})
    end;


%%通知玩家进入地图
do_handle_info({notify_role_enter, MapID, RoleID, Line}, _State) ->
    {Tx, Ty} = get_random_txty_by_mapid(MapID),
    R = #m_map_change_map_toc{mapid=MapID, tx=Tx, ty=Ty},
    common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE, ?MAP, ?MAP_CHANGE_MAP, R);   


%% 由其他地方转发过来的进入地图请求
do_handle_info({enter, Unique, RoleID, FamilyID, Line}, _State) -> 
    case if_begin_warofking() of
        true ->
            case if_role_can_enter(RoleID, FamilyID) of
                true ->
                    MapID = mgeem_map:get_mapid(),
                    {TX, TY} = get_random_txty_by_mapid(MapID),
                    R = #m_warofking_enter_toc{},
                    common_misc:unicast(Line, RoleID, Unique, ?WAROFKING, ?WAROFKING_ENTER, R),          
                    common_misc:send_to_rolemap(strict, RoleID, {mod_map_role, {change_map, RoleID, MapID, TX, TY, ?CHANGE_MAP_TYPE_WAROFKING}}),
                    DataRecord = #m_map_change_map_toc{mapid=MapID, tx=TX, ty=TY},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?MAP, ?MAP_CHANGE_MAP, DataRecord);
                false ->
                    R = #m_warofking_enter_toc{succ=false, reason=?_LANG_WAROFKING_NO_RIGHT_TO_ENTER},
                    common_misc:unicast(Line, RoleID, Unique, ?WAROFKING, ?WAROFKING_ENTER, R)
            end;
        false ->
            R = #m_warofking_enter_toc{succ=false, reason=?_LANG_WAROFKING_NOT_BEGIN},
            common_misc:unicast(Line, RoleID, Unique, ?WAROFKING, ?WAROFKING_ENTER, R)
    end;

%% mgeew_event发消息通知国王争霸战开始了，会附带上所有的有资格的门派的信息
%% 如果没有门派参战, mgeew_event会立刻宣布争国王结束，不会发消息过来的
%% FamilyInfo {family_info, rankno}
%% beginTime endTime {{Year, Month, Day}, {Hour, Min, Sec}}
do_handle_info({begin_war, SafeTime, FamilyInfoList}, State) ->
    case if_begin_warofking() of
        true ->
            ?ERROR_MSG("~ts", ["抢国王活动已经开始了，怎么会又有消息发送过来？world重启了?"]);
        false ->
            do_begin_war(FamilyInfoList, SafeTime, State)
    end;


do_handle_info(end_war, _State) ->
    case if_begin_warofking() of
        true ->
            do_end_war(timeout);
        false ->
            ?ERROR_MSG("~ts", ["抢国王已经结束了，怎么有重复消息发送过来"])
    end;

do_handle_info(set_not_safe, _State) ->
    do_set_not_safe();

do_handle_info(?set_can_hold, _State) ->
    do_set_can_hold();

    
do_handle_info(Info, _State) ->
    ?ERROR_MSG("~ts ~w", ["未知消息", Info]).


if_role_can_enter(_RoleID, FamilyID) ->
    chk_in_family_list(FamilyID).

%%安全期结束一段时间之后才能开始占领王座
do_set_can_hold() ->
    set_can_hold().

set_can_hold() ->
    put(?warofking_can_hold_flag, true).
set_cannot_hold() ->
    put(?warofking_can_hold_flag, false).
get_can_hold() ->
    get(?warofking_can_hold_flag).
    

do_get_safetime(Unique, Module, Method, RoleID, Line) ->
    SafeTimeEnd = get(?WAROFKING_SAFETIME_END),
    Remain = SafeTimeEnd - common_tool:now(),
    R = #m_warofking_safetime_toc{remain_time=Remain},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).


do_get_safetime_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_warofking_safetime_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).    


%% 结束战斗
do_end_war(Reason) ->
    case if_begin_warofking() of
        true ->
            %%战斗结束了
            put(?if_begin_war_of_king, false),
			global:send(mgeew_office, {set_warofking_status, false}),
            clear_family_list(),
            do_end_war2(Reason);
        false ->
            ignore
    end.


%%有人成功占领了王座
do_end_war2(get_flag) ->
    {HoldingRoleID, _HoldingTime} = get(?roleid_get_king_flag),
    %%获取门派ID
    {ok, #p_role_base{family_id=FamilyID, family_name=FamilyName, faction_id=FactionID}} = mod_map_role:get_role_base(HoldingRoleID),
    [#p_family_info{owner_role_id=KingRoleID, owner_role_name=KingRoleName}=FamilyInfo] = db:dirty_read(?DB_FAMILY, FamilyID),
    do_setking(FamilyID, FamilyName, KingRoleID, KingRoleName, FactionID, FamilyInfo, HoldingRoleID),
    ok;
%%国王争霸战时间到了
do_end_war2(timeout) ->
    %% 找出本次的战斗排名 #p_warofking_mark
    FamilyMarkList = get(?family_mark_list),
    SortFun = fun(A, B) ->
                      {_, _, MarkA} = A,
                      {_, _, MarkB} = B,
                      MarkA > MarkB
              end,
    FamilySortList = lists:sort(SortFun, FamilyMarkList),
    [KingFamily|_] = FamilySortList,
    {FamilyID, FamilyName, _} = KingFamily,
    [#p_family_info{owner_role_id=KingRoleID, 
                    owner_role_name=KingRoleName, 
                    faction_id=FactionID}=FamilyInfo] = db:dirty_read(?DB_FAMILY, FamilyID),
    do_setking(FamilyID, FamilyName, KingRoleID, KingRoleName, FactionID, FamilyInfo, 0).


-define(GET_KING_BROADCAST, "~s 门派掌门 ~s 在王座争霸战中带领帮众英勇奋战，夺得本期国王王座，当选为 ~s").


do_setking(FamilyID, FamilyName, KingRoleID, KingRoleName, FactionID, FamilyInfo, WhoHolding) ->
    %%取消上一节的本国国王，设置本届的国王
    common_office:set_king(KingRoleID, KingRoleName, FactionID),
    %%KingTitle = common_office:get_king_name(FactionID),
    
    %%本门派所有成员获取一个2小时双倍经验buff
    common_buff:add_family_double_exp(family, FamilyID),
    {_, {Hour, Min, _}} = calendar:local_time(),
    Hour2 = Hour + 2,
    case Hour2 >= 24 of
        true ->
            HourEnd = Hour2 - 24;
        false ->
            HourEnd = Hour2
    end,
    ContentMsg = lists:flatten(io_lib:format("本门派获得王座争霸战胜利，~p时~p分 --- ~p时~p分期间打怪获得双倍经验，使用经验符还有额外加成！", 
                                             [Hour, Min, HourEnd, Min])),
    common_broadcast:bc_send_cycle_msg_family(FamilyID, ?BC_MSG_TYPE_CHAT, ?BC_MSG_TYPE_CHAT_FAMILY, ContentMsg, common_tool:now(),
                                         common_tool:now()+ 7200, 600),
    RC = #m_chat_warofking_toc{family_name=FamilyName, role_name=KingRoleName},
    common_misc:chat_broadcast_to_faction(FactionID, ?CHAT, ?CHAT_WAROFKING, RC),
    %%通知抢国王地图中的每一个玩家本地的结果
    R = #m_warofking_end_toc{family_id=FamilyID, role_id=WhoHolding},
    mgeem_map:broadcast_to_whole_map(?WAROFKING, ?WAROFKING_END, R),
    clear_map(),
    global:send(mgeew_event, {mod_event_warofking, {result, FactionID, FamilyInfo}}),
    ok.


do_hold_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_warofking_hold_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).


do_hold(Unique, Module, Method, RoleID, Line, _State) ->
    %%判断是否有玩家在占领王座，其次判断是否是自己
    {HoldingRoleID, _HoldingTime} = get(?roleid_get_king_flag),
    case HoldingRoleID > 0 of
        true ->
            case HoldingRoleID =:= RoleID of
                true ->
                    %%玩家已经占领王座了
                    R = #m_warofking_hold_toc{succ=false, reason=?_LANG_WAROFKING_ALREADY_HOLD},
                    common_misc:unicast(Line, RoleID, Unique, Module, Method, R),
                    ok;
                false ->
                    %%已经有玩家占领王座了
                    R = #m_warofking_hold_toc{succ=false, reason=?_LANG_WAROFKING_BEEN_HOLDING_BY_SOMEONE},
                    common_misc:unicast(Line, RoleID, Unique, Module, Method, R)
            end;
        false ->
            %%判断是否到了能够占领的时间
            case get_can_hold() of
                true ->
                    %% 判断玩家有没有门派，有可能在这个过程中玩家被T了
                    {ok, #p_role_base{family_id=FamilyID, family_name=FamilyName, status=Status}} = mod_map_role:get_role_base(RoleID),
                    case Status =:= ?ROLE_STATE_DEAD of
                        true ->
                            R = #m_warofking_hold_toc{succ=false, reason=?_LANG_WAROKFING_CANNT_HOLD_WHEN_DEAD},
                            common_misc:unicast(Line, RoleID, Unique, Module, Method, R);
                        false ->
                            case FamilyID > 0 of
                                true ->                    
                                    %%没有人占领王座，可以占领
                                    put(?roleid_get_king_flag, {RoleID, 0}),
                                    %%通知玩家占领成功，广播告诉其他玩家有人已经占领了王座
                                    RSelf = #m_warofking_hold_toc{succ=true},            
                                    RB = #m_warofking_hold_toc{succ=true, return_self=false, role_id=RoleID, family_name=FamilyName},
                                    common_misc:unicast(Line, RoleID, Unique, Module, Method, RSelf),
                                    mgeem_map:broadcast_to_whole_map(Module, Method, RB);
                                false ->
                                    R = #m_warofking_hold_toc{succ=false, reason=?_LANG_WAROKFING_NO_FAMILY},
                                    common_misc:unicast(Line, RoleID, Unique, Module, Method, R)
                            end
                    end;
                _ ->
                    R = #m_warofking_hold_toc{succ=false, reason=?_LANG_WAROKFING_CANNT_HOLD_TIME_LIMIT},
                    common_misc:unicast(Line, RoleID, Unique, Module, Method, R)
            end                    
    end,
    ok.

do_set_not_safe() ->
    put(?WAROFKING_NOT_SAFE, true),
    %%产生一条消息用于通知5分钟之后才能占领王座    
    Ref = erlang:send_after(?WAROFKING_TIME_AFTER_SAFE, self(), {?MODULE, ?set_can_hold}),
    set_can_hold_ref(Ref).

set_can_hold_ref(Ref) ->
    case get_can_hold_ref() of
        undefined ->
            ignore;
        OldRef ->
            erlang:cancel_timer(OldRef)
    end,
    put(?warofking_can_hold_ref, Ref).

get_can_hold_ref() ->
    get(?warofking_can_hold_ref).
    

add_to_family_list(FamilyID) ->
    erlang:put(?warofking_family_allow_list, [FamilyID | erlang:get(?warofking_family_allow_list)]).
chk_in_family_list(FamilyID) ->
    lists:member(FamilyID, erlang:get(?warofking_family_allow_list)).
init_family_list() ->
    erlang:put(?warofking_family_allow_list,[]).
clear_family_list() ->
    erlang:put(?warofking_family_allow_list,[]).

%% 开始王座争霸战，需要初始化一些信息
do_begin_war(FamilyInfoList, SafeTime, State) ->
    init_family_list(),
    %%传递过来的FamilyInfoList可能是过期的
    %% 有一个或以上的门派参与抢国王
    {FamilyMarkList, RoleIDList} = lists:foldl(
                                     fun(#p_family_info{family_id=FamilyID}, {MarkList, RoleIDList}) ->
                                             [#p_family_info{family_id=FamilyID, 
                                                              family_name=FamilyName,
                                                             members=M}] = db:dirty_read(?DB_FAMILY, FamilyID),
                                             add_to_family_list(FamilyID),
                                             A = [MID || #p_family_member_info{role_id=MID} <- M],
                                             {[{FamilyID, FamilyName, 0} | MarkList], lists:append(A, RoleIDList)}
                                     end, {[], []}, FamilyInfoList),
    ?ERROR_MSG("~w ~w", [FamilyMarkList, RoleIDList]),
    %% 初始化门派积分
    put(?family_mark_list, FamilyMarkList),
    %% 初始化每个门派的死亡复活点
    init_family_dead_relive_point(FamilyMarkList),
    MapID = State#map_state.mapid,
    lists:foreach(
      fun(RoleID) ->
              {TX, TY} = get_random_txty_by_mapid(MapID) ,
              common_misc:send_to_rolemap(strict, {mod_map_role, {change_map, RoleID, MapID, TX, TY, ?CHANGE_MAP_TYPE_WAROFKING}})
      end, RoleIDList),
    put(?WAROFKING_NOT_SAFE, false),
    erlang:put(?if_begin_war_of_king, true),
    erlang:send_after(SafeTime * 1000, self(), {?MODULE, set_not_safe}),
    erlang:put(?WAROFKING_SAFETIME_END, common_tool:now() + SafeTime),
    %%广播给所有参战门派的所有成员，发送征集令
    RB = #m_warofking_collect_toc{},
    set_all_roleid_list(RoleIDList),
    %% 必须用common_misc的，而不能用mgeem_map的
    common_misc:broadcast(RoleIDList, ?DEFAULT_UNIQUE, ?WAROFKING, ?WAROFKING_COLLECT, RB),
    ok.

%% 初始化每个门派的死亡复活点
init_family_dead_relive_point(FamilyMarkList) ->
    BornPointList = erlang:get(warofking_born_list),
    ?ERROR_MSG("~p", [BornPointList]),
    lists:foreach(
      fun({Index, {TX, TY}}) ->
              case erlang:length(FamilyMarkList) < Index of
                  true ->
                      ignore;
                  false ->
                      {FamilyID, _FamilyName, _Mark} = lists:nth(Index, FamilyMarkList),
                      set_family_relive_point(FamilyID, {TX, TY})
              end
      end, BornPointList).

set_family_relive_point(FamilyID, {TX, TY}) ->
    erlang:put({family_relive_point, FamilyID}, {TX, TY}).

get_family_relive_point(FamilyID) ->
    erlang:get({family_relive_point, FamilyID}).

    
get_random_txty_by_mapid(MapID) ->
    [{MapID, {MapID, _TW, _TH, _OffsetX2, _OffsetY2, _MaxTX3, _MaxTY3, Data}}] = ets:lookup(?ETS_IN_MAP_DATA, MapID),
    Length = erlang:length(Data),
    Random = common_tool:random(1, Length),
    {{TX, TY}, _} = lists:nth(Random, Data),
    {TX, TY}.

set_all_roleid_list(RoleIDList) ->
    erlang:put(?warofking_all_roleid_list, RoleIDList).
clear_all_roleid_list() ->
    erlang:erase(?warofking_all_roleid_list).
get_all_roleid_list() ->
    erlang:get(?warofking_all_roleid_list).
init_all_roleid_list() ->
    erlang:put(?warofking_all_roleid_list, []).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

test() ->
    ok.

init_test() ->
    init_map_data(ignore, ignore),
    %% 测试是否处于安全期
    ?assertEqual(false, is_in_safetime()),
    ?assertEqual(false, if_begin_warofking()),
    ok.

%% 未完成
role_dead_test() ->
    init_map_data(ignore, ignore),
    ok.


-endif.
