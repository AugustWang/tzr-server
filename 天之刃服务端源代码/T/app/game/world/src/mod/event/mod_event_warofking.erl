%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created :  7 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_event_warofking).

%%-behaviour(mod_event).

-include("mgeew.hrl").

%% Corba callbacks
-export([
         init_config/0,
         test_config_api/4,
         handle_info/1,
         handle_call/1,
         handle_msg/1,
         reload_config/1
        ]).
%%广播报名的时间间隔
-define(WAROFKING_BROADCAST_INTERVAL, 3600).

%%星期几打王座争霸战
-define(WAROFKING_WEEKDAY, 6).

%%门派站开始的timer ref
-define(WAROFKING_BEGIN_TIME_REF, warofking_begin_time_ref).

-define(WAROFKING_INIT_FAMILY_LIST_TIME_REF, warofking_init_family_list_time_ref).

-define(WAROFKING_SAFE_TIME, warofking_safe_time).

%%进程字典key名称，用于保存战斗的正常时长
-define(WAROFKING_WAR_TIME, warofking_war_time).

-define(WAROFKING_PREPARE_TIME, warofking_prepare_time).

-define(warofking_family_list, warofking_family_list).

-define(PREPARE_FAMILY_LIST, prepare_family_list).

-define(WAROFKING_BEGIN_WAR_REF, warofking_begin_war_ref).

-define(WAROFKING_END_WAR_REF, warofking_end_war_ref).

%%是否可以开始申请王座争霸战了
-define(warofking_begin_prepare, warofking_begin_prepare).

%%王座争霸战是否已经开始了
-define(warofking_has_begin, warofking_has_begin).

-define(warofking_prepare_family_list, warofking_prepare_family_list).


%%王座争霸战尚未开始报名
-define(WAROFKING_STATUS_NOT_BEGIN, 0).
%%王座争霸战开始报名
-define(WAROFKING_STATUS_BEGIN_PREPARE, 1).
%%王座争霸战正在进行中
-define(WAROFKING_STATUS_BEGIN_WAR, 2).

-define(ISOPEN_WAROFKING_LETTRE,false).

-define(COMMON_WAROFKING_LETTER(RoleID, Content, Title, Day),
        case ?ISOPEN_WAROFKING_LETTRE of
            true->
               common_letter:sys2p(RoleID, Content, Title, Day);
            _->
               ignore
        end).
-define(ISOPEN_WAROFKING_BROADCAST,false).
-define(COMMON_BROADCAST_WAROFKING(Fun),
        case ?ISOPEN_WAROFKING_BROADCAST of
            true->
                Fun;
            _->
                ignore
        end).

%%发送测试配置给抢国王模块
%% BeginAfterMin 几分钟之后开始
test_config_api(BeginAfterSecond, PrepareTime, SafeTime, WarTime) ->
    global:send(mgeew_event, {?MODULE, {set_next_time, {BeginAfterSecond, PrepareTime, SafeTime, WarTime}}}),
    ok.

%%--------------------------------------------------------------------
init_config() ->   
    Config = common_config:get_warofking_config(),
    do_calc_next_war_time(Config),
    ok.

handle_info(Info) ->
    do_handle_info(Info),
    ok.

handle_call(Request) ->
    do_handle_call(Request).

handle_msg(_Msg) ->
    ok.

reload_config(Config) ->
    do_calc_next_war_time(Config),
    ok.


%% 管理后台接口
do_handle_call(get_info) ->
    do_get_info();
do_handle_call(begin_now) ->
    force_end(),    
    do_set_next_time(0, 30, 60, 600),
    do_get_info();
do_handle_call(begin_after_30s) ->
    force_end(),    
    do_set_next_time(30, 30, 60, 600),
    do_get_info();
do_handle_call(begin_after_60s) ->
    force_end(),    
    do_set_next_time(60, 30, 60, 600),
    do_get_info();
do_handle_call(end_now) ->
    force_end(),
    init_config(),
    do_get_info();
do_handle_call(reset) ->
    force_end(),
    init_config(),
    ok;
do_handle_call(Request) ->
    ?ERROR_MSG("~ts:~w", ["未知的CALL调用", Request]).


do_get_info() ->
    Index = get_index(),
    RCur = db:dirty_read(?DB_WAROFKING_HISTORY, Index),
    RLast = db:dirty_read(?DB_WAROFKING_HISTORY, Index-1),
    case erlang:length(RCur) > 0 of
        true ->
            R = erlang:hd(RCur);
        false ->
            R = []
    end,
    case erlang:length(RLast) > 0 of
        true ->
            RL = erlang:hd(RLast);
        false ->
            RL = []
    end,
    {R, RL}.


%%在一切状态下强制结束本次抢国王
%%需要清理的信息: TimeRef
force_end() ->
    set_worofking_status(false),
    notfiy_map_endofwar(),
    clear_faction_can_war_flag(1),
    clear_faction_can_war_flag(2),
    clear_faction_can_war_flag(3),
    clear_all_ref().

%%时间到了之后立刻开始初始化本次参战的门派名单
do_handle_info(init_family_list) ->
    do_init_family_list();

do_handle_info(begin_war) ->
    do_begin_war();

do_handle_info(end_war) ->
    do_end_war();

do_handle_info({config, Config}) ->
    do_calc_next_war_time(Config);

do_handle_info({result, FactionID, FamilyInfo}) ->
    clear_faction_can_war_flag(FactionID),
    do_result(FactionID, FamilyInfo);

do_handle_info({set_next_time, {BeginAfterSecond, PrepareTime, SafeTime, WarTime}}) ->
    do_set_next_time(BeginAfterSecond, PrepareTime, SafeTime, WarTime);


do_handle_info({Unique, Module, ?WAROFKING_AGREE_ENTER, _, RoleID, _PID, Line}) ->
    do_agree_enter(Unique, Module, ?WAROFKING_AGREE_ENTER, RoleID, Line);
do_handle_info(Info) ->
    ?ERROR_MSG("~ts:~w", ["未知得消息", Info]).


do_result(1, FamilyInfo) ->
    Index = get_index(),
    [R] = db:dirty_read(?DB_WAROFKING_HISTORY, Index),
    NewR = R#r_warofking_history{winner_family_1=FamilyInfo},
    db:dirty_write(?DB_WAROFKING_HISTORY, NewR);
do_result(2, FamilyInfo) ->
    Index = get_index(),
    [R] = db:dirty_read(?DB_WAROFKING_HISTORY, Index),
    NewR = R#r_warofking_history{winner_family_2=FamilyInfo},
    db:dirty_write(?DB_WAROFKING_HISTORY, NewR);
do_result(3, FamilyInfo) ->
    Index = get_index(),
    [R] = db:dirty_read(?DB_WAROFKING_HISTORY, Index),
    NewR = R#r_warofking_history{winner_family_3=FamilyInfo},
    db:dirty_write(?DB_WAROFKING_HISTORY, NewR).


%%门派成员同意进入战场
do_agree_enter(Unique, Module, Method, RoleID, Line) ->
    %%检查是否有权利进入，可以则返回目标地图的ID
    [#p_role_base{family_id=FamilyID, faction_id=FactionID, status=Status}] = db:dirty_read(?DB_ROLE_BASE, RoleID),
    [#r_role_state{stall_self=StallSelf,trading = Trading}] = db:dirty_read(?DB_ROLE_STATE, RoleID),
    {ok, MapID} = common_misc:get_dirty_mapid_by_roleid(RoleID),
    [JailMapID] =  common_config_dyn:find(jail, jail_map_id),
    case Status =:= ?ROLE_STATE_TRAINING orelse Status =:= ?ROLE_STATE_DEAD 
        orelse StallSelf =:= true orelse Trading =:= 1 orelse MapID =:= JailMapID
    of
        true ->
            %% 商贸状态判断 add by caochuncheng 2011-01-14
            Reason =
                if
                    Trading =:= 1 ->
                        ?_LANG_WAROFKING_TRADING_STATUS_CANNT_ENTER;
                    MapID =:= JailMapID ->
                        ?_LANG_WAROFKING_IN_JAIL_CANNT_ENTER;
                    true ->
                        ?_LANG_WAROFKING_SPECIAL_STATUS_CANNT_ENTER
                end,
            do_agree_enter_error(Unique, Module, Method, Reason, RoleID, Line),
            ignore;
        false ->
            case get(?warofking_has_begin) of
                true ->
                    DoingYbc = common_map:is_doing_ybc(RoleID),
                    FamilyPrepareList = get_faction_condition_family_list(FactionID),
                    case lists:keymember(FamilyID, #p_family_info.family_id, FamilyPrepareList) of
                        true when DoingYbc =:= true ->
                            do_agree_enter_error(Unique, Module, Method, ?_LANG_YBC_CAN_NOT_TRANSFORM_TO_WAROFKING, RoleID, Line);
                        true ->
                            common_misc:send_to_rolemap(RoleID,{mod_map_actor,{change_map_by_call,?CHANGE_MAP_WAROFKING_CALL,RoleID}}),
                            MapIDMap = [{1, 11111}, {2, 12111}, {3, 13111}],
                            WarMapID = proplists:get_value(FactionID, MapIDMap),
                            catch global:send(common_misc:get_common_map_name(WarMapID), 
                                              {mod_warofking, {notify_role_enter, WarMapID, RoleID, Line}}),
                            ok;
                        false ->
                            do_agree_enter_error(Unique, Module, Method, ?_LANG_WAROFKING_NO_RIGHT_TO_ENTER, RoleID, Line)
                    end;
                _ ->
                    do_agree_enter_error(Unique, Module, Method, ?_LANG_WAROFKING_AGREE_ENTER_TIMEOUT, RoleID, Line)
            end
    end.


do_agree_enter_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_warofking_agree_enter_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).


set_faction_can_war_flag(FactionID) ->
    put({warofking_faction_can_war, FactionID}, true).
clear_faction_can_war_flag(FactionID) ->
    erlang:erase({warofking_faction_can_war, FactionID}).
get_faction_can_war_flag(FactionID) ->
    erlang:get({warofking_faction_can_war, FactionID}).


%%申请时间到后处理各个国家的申请初始化工作
process_faction_prepare(_, _, FactionID, []) ->
    clear_faction_can_war_flag(FactionID),
    ?ERROR_MSG("~ts", ["本届没有门派达到王座争霸战条件"]),
    Msg = lists:flatten(io_lib:format(?_LANG_WAROFKING_NO_JOIN_MESSAGE_STRING, [])),
    ?COMMON_BROADCAST_WAROFKING(common_broadcast:bc_send_msg_faction(FactionID, ?BC_MSG_TYPE_CHAT, ?BC_MSG_TYPE_CHAT_COUNTRY, Msg));
process_faction_prepare(BeginTime, EndTime, FactionID, FamilyList) ->
    set_faction_can_war_flag(FactionID),
    %%保存有权利抢国王的门派列表                                           
    KingName = proplists:get_value(FactionID, ?FACTION_KING_NAME),
    %%国家频道广播
    {{_, Month, Day}, _} = erlang:localtime(),
    FamilyNameList = lists:foldl(
                       fun(#p_family_info{family_name=FamilyName, second_owners=SecondOwners,
                                          owner_role_id=OwnerRoleID, owner_role_name=OwnerRoleName}, Acc) ->   
                               ContentMsg = common_letter:create_temp(?WAROFKING_BEGIN_LETTER2,[OwnerRoleName, KingName, KingName, Month, Day]),
                               ?COMMON_WAROFKING_LETTER(OwnerRoleID, ContentMsg,?_LANG_WAROFKING_LETTER_TITLE,3),
                               lists:foreach(
                                 fun(#p_family_second_owner{role_id=RID, role_name=RName}) ->
                                         ContentMsg2 = common_letter:create_temp(?WAROFKING_BEGIN_LETTER2,[RName, KingName, KingName, Month, Day]),
                                         ?COMMON_WAROFKING_LETTER(RID, ContentMsg2, ?_LANG_WAROFKING_LETTER_TITLE,3)
                                 end, SecondOwners),
                               [FamilyName | Acc]
                       end, [], FamilyList),              
    Content = lists:flatten(io_lib:format(?_LANG_WAROFKING_BEGIN_BROADCAST, [common_lists:implode(FamilyNameList, "，")])),
    ?COMMON_BROADCAST_WAROFKING(common_broadcast:bc_send_cycle_msg_faction(FactionID, ?BC_MSG_TYPE_CHAT, ?BC_MSG_TYPE_CHAT_COUNTRY, Content, BeginTime, EndTime, ?WAROFKING_BROADCAST_INTERVAL)).


%%事件通知开始王座争霸战的申请了
do_init_family_list() ->
    BeginTime = common_tool:now(),
    EndTime = common_tool:now() + get_prepare_time(),
    lists:foreach(
      fun(FactionID) ->
              %%统计哪几个门派有资格加入抢国王 {fid, fname, owner_role_id, owner_role_name}
              FamilyList = get_candidate_family(FactionID),
              set_faction_condition_family_list(FactionID, FamilyList),
              process_faction_prepare(BeginTime, EndTime, FactionID, FamilyList)     
      end, ?FACTIONID_LIST),       
    set_begin_and_end_time(),
    update_log_when_begin_prepare(),
    set_worofking_status(true),
    ok.


set_worofking_status(true) ->
    %%收回官员身上的装备
    common_office:retrieve_all_office_equip(),
    global:send(mgeew_office, {set_warofking_status, true});

set_worofking_status(false) ->
    global:send(mgeew_office, {set_warofking_status, false}).


%%真正的开始王座争霸战的战斗了
do_begin_war() ->
    ?ERROR_MSG("~ts", ["王座争霸战开始判断"]),
    set_begin(),
    MapIDMap = [{1, 11111}, {2, 12111}, {3, 13111}],
    SafeTime = get_safe_time(),
    %%获取各个国家参与报名的门派，向各个地图发消息通知
    lists:foreach(
      fun(FactionID) ->
              case get_faction_can_war_flag(FactionID) of
                  true ->
                      FamilyList = get_faction_condition_family_list(FactionID),
                      case  FamilyList =:= undefined orelse erlang:length(FamilyList) =:= 0 of
                          true ->                         
                              ok;
                          false ->                      
                              MapID = proplists:get_value(FactionID, MapIDMap),
                              MapName = common_misc:get_common_map_name(MapID),    
                              ?ERROR_MSG("~ts ~w ~ts ~w", ["达成王座争霸站条件的门派", FamilyList, "，通知地图", MapName]),
                              global:send(MapName, {mod_warofking, {begin_war, SafeTime, FamilyList}})
                      end;
                  _ ->
                      ignore
              end
      end, ?FACTIONID_LIST),
    update_log_when_begin_war().


%%通知地图，战斗结束了
do_end_war() ->
    notfiy_map_endofwar(),
    set_end(),
    init_config().

notfiy_map_endofwar() ->
    MapIDMap = [{1, 11111}, {2, 12111}, {3, 13111}],
    lists:foreach(
      fun(FactionID) ->
              case get_faction_can_war_flag(FactionID)  of
                  true ->
                      MapID = proplists:get_value(FactionID, MapIDMap),
                      MapName = common_misc:get_common_map_name(MapID),              
                      global:send(MapName, {mod_warofking, end_war});
                  _ ->
                      ignore
              end
      end, ?FACTIONID_LIST).


%%获取候选门派
get_candidate_family(FactionID) ->
    Sql = io_lib:format("select family_id from t_family_summary where faction_id=~w " ++ 
                            "order by gongxun desc, active_points desc, cur_members desc limit 3",
                        [FactionID]),
    {ok, FamilyIDListTmp} = mod_mysql:select(Sql),
    FamilyList = lists:foldl(
                   fun([FID], Acc) ->
                           case db:dirty_read(?DB_FAMILY, FID) of
                               [] ->
                                   Acc;                               
                               [FamilyInfo] ->
                                   [FamilyInfo | Acc]
                           end
                   end, [], FamilyIDListTmp),
    RoleID = common_office:get_king_roleid(FactionID),
    case RoleID > 0 of
        true ->
            case db:dirty_read(?DB_ROLE_BASE, RoleID) of
                [] ->
                    FamilyList2 = FamilyList;
                [#p_role_base{family_id=FamilyID}] ->
                    case FamilyID  > 0 of
                        true ->
                            case lists:keymember(FamilyID, #p_family_info.family_id, FamilyList) of
                                true ->
                                    FamilyList2 = FamilyList;
                                false ->
                                    [FamilyInfo2] = db:dirty_read(?DB_FAMILY, FamilyID),
                                    FamilyList2 = [FamilyInfo2 | FamilyList]
                            end;
                        false ->
                            FamilyList2 = FamilyList
                    end
            end;
        false ->
            FamilyList2 = FamilyList
    end,
    FamilyList2.


%%计算下次王座争霸战的时候，并做一些清理和初始化工作
do_calc_next_war_time(Config) ->
    {
      {prepare_begin_time, {PrepareBeginTimeHour, PrepareBeginTimeMin}},
      {prepare_time, PrepareTime}, {safe_time, SafeTime},{war_time, WarTime}} = Config,  
    set_prepare_time(PrepareTime),
    NextPrepareBeginTime = common_time:diff_next_weekdaytime(?WAROFKING_WEEKDAY, PrepareBeginTimeHour, PrepareBeginTimeMin),
    do_set_next_time(NextPrepareBeginTime, PrepareTime, SafeTime, WarTime).    

%% 设置下次开始的时间，发送了消息了
do_set_next_time(NextInitTime, PrepareTime, SafeTime, WarTime) ->
    set_init_family_list_timeref(NextInitTime),
    set_prepare_time(PrepareTime),
    set_safe_time(SafeTime),
    set_war_time(WarTime),
    log(NextInitTime, PrepareTime, SafeTime, WarTime).


log(NextPrepareBeginTime, PrepareTime, SafeTime, WarTime) ->
    NextBeginTime = NextPrepareBeginTime + PrepareTime + common_tool:now(),
    NextEndTime = NextBeginTime + SafeTime + WarTime,
    Index = get_new_index(),
    put_index(Index),
    R = #r_warofking_history{index=Index, begin_time=NextBeginTime, end_time=NextEndTime},
    %% 记录各个国家王座争霸战的状态
    lists:foreach(
      fun(FactionID) ->
              R2 = #db_warofking{faction_id=FactionID, begin_time=NextBeginTime, end_time=NextEndTime,
                                 status=?WAROFKING_STATUS_NOT_BEGIN, join_families=[], condition_families=[]},
              db:dirty_write(?DB_WAROFKING, R2)
      end, ?FACTIONID_LIST),
    db:dirty_write(?DB_WAROFKING_HISTORY, R).

get_index() ->
    get(warofking_index).

put_index(Index) ->
    put(warofking_index, Index).


update_log_when_begin_prepare() ->
    Index = get_index(),
    [R] = db:dirty_read(?DB_WAROFKING_HISTORY, Index),
    lists:foreach(
      fun(FactionID) ->
              CondFamilyList = get_faction_condition_family_list(FactionID),
              [Old] = db:dirty_read(?DB_WAROFKING, FactionID) ,
              db:dirty_write(?DB_WAROFKING, Old#db_warofking{condition_families=CondFamilyList,
                                                             status=?WAROFKING_STATUS_BEGIN_PREPARE})
      end, ?FACTIONID_LIST),
    CondFamilyList1 = get_faction_condition_family_list(1),
    CondFamilyList2 = get_faction_condition_family_list(2),
    CondFamilyList3 = get_faction_condition_family_list(3),    
    ConditionFamilyList = [{1, CondFamilyList1}, {2, CondFamilyList2}, {3, CondFamilyList3}],                                    
    NewR = R#r_warofking_history{condition_families=ConditionFamilyList},
    db:dirty_write(?DB_WAROFKING_HISTORY, NewR). 


update_log_when_begin_war() -> 
    Index = get_index(),
    [R] = db:dirty_read(?DB_WAROFKING_HISTORY, Index),
    lists:foreach(
      fun(FactionID) ->
              CondFamilyList = get_faction_condition_family_list(FactionID),
              [Old] = db:dirty_read(?DB_WAROFKING, FactionID) ,
              db:dirty_write(?DB_WAROFKING, Old#db_warofking{join_families=CondFamilyList,
                                                             status=?WAROFKING_STATUS_BEGIN_WAR})
      end, ?FACTIONID_LIST),
    PrepareList1 = get_faction_condition_family_list(1),
    PrepareList2 = get_faction_condition_family_list(2),
    PrepareList3 = get_faction_condition_family_list(3),
    PrepareList = [{1, PrepareList1}, {2, PrepareList2}, {3, PrepareList3}],
    NewR = R#r_warofking_history{join_families=PrepareList},
    db:dirty_write(?DB_WAROFKING_HISTORY, NewR).



%%获取当前是第几届的抢国王
get_new_index() ->
    case db:dirty_read(?DB_WAROFKING_HISTORY_INDEX, 1) of
        [#r_warofking_history_index{value=OldIndex}] ->
            NextIndex = OldIndex+1,
            db:dirty_write(?DB_WAROFKING_HISTORY_INDEX, #r_warofking_history_index{id=1, value=NextIndex}),
            NextIndex;
        [] ->
            db:dirty_write(?DB_WAROFKING_HISTORY_INDEX, #r_warofking_history_index{id=1, value=1}),
            1
    end.


%%设置本国有哪些门派有权利申请抢国王
set_faction_condition_family_list(FactionID, FamilyList) ->
    put({?warofking_family_list, FactionID}, FamilyList).
get_faction_condition_family_list(FactionID) ->
    erlang:get({?warofking_family_list, FactionID}).


set_begin_and_end_time() ->
    %%记录本次的时间
    set_begin_time(),
    set_end_time().


%% 产生消息通知王座争霸战的战斗
%% BeginTime 表示开始那一刻的具体时间，用于记录在数据库中
set_begin_time() ->
    PrepareTime = get_prepare_time(),
    ?ERROR_MSG("~p", [PrepareTime]),
    BeginWarRef = erlang:send_after(PrepareTime * 1000, self(), {?MODULE, begin_war}),
    case get_begin_timeref() of
        undefined ->
            ignore;
        Ref ->
            erlang:cancel_timer(Ref)
    end,
    set_begin_timeref(BeginWarRef).
set_begin_timeref(Ref) ->
    erlang:put(?WAROFKING_BEGIN_WAR_REF, Ref).
get_begin_timeref() ->
    erlang:get(?WAROFKING_BEGIN_WAR_REF).

%%发送消息通知结束
%% EndTime 表示结束那一刻的具体时间 
set_end_time() ->
    PrepareTime = get_prepare_time(),
    WarTime = get_war_time(),
    EndWarTime = WarTime + PrepareTime,
    EndTimeRef = erlang:send_after(EndWarTime * 1000, self(), {?MODULE, end_war}),
    case get_end_timeref() of
        undefined ->
            ignore;
        OldRef->
            erlang:cancel_timer(OldRef)
    end,
    set_end_timeref(EndTimeRef).
set_end_timeref(Ref) ->
    erlang:put(?WAROFKING_END_WAR_REF, Ref).
get_end_timeref() ->
    erlang:get(?WAROFKING_END_WAR_REF).

%%设置王座争霸战的战斗时长
get_war_time() ->
    erlang:get(?WAROFKING_WAR_TIME).
set_war_time(Time) ->
    erlang:put(?WAROFKING_WAR_TIME, Time).

set_prepare_time(Time) ->
    erlang:put(?WAROFKING_PREPARE_TIME, Time).
get_prepare_time() ->
    get(?WAROFKING_PREPARE_TIME).


%%设置战斗是否开始的标志
set_begin() ->
    erlang:put(?warofking_has_begin, true).
set_end() ->
    erlang:put(?warofking_has_begin, false).

%% 发送消息通知下次开始的时间
set_init_family_list_timeref(NextInitTime) ->
    clear_all_ref(),
    Ref = erlang:send_after(NextInitTime * 1000, self(), {?MODULE, init_family_list}),    
    put(?WAROFKING_INIT_FAMILY_LIST_TIME_REF, Ref).


clear_end_timeref() ->
    case get(?WAROFKING_END_WAR_REF) of
        undefined ->
            ignore;
        EndTimeRef ->
            erlang:cancel_timer(EndTimeRef)
    end.


set_safe_time(SafeTime) ->
    erlang:put(?WAROFKING_SAFE_TIME, SafeTime).
get_safe_time() ->
    erlang:get(?WAROFKING_SAFE_TIME).


clear_all_ref() ->
    %%需要取消旧的timer，因为有可能需要本地测试
    case get(?WAROFKING_BEGIN_TIME_REF) of
        undefined ->
            ignore;
        OldBeginRef ->
            erlang:cancel_timer(OldBeginRef)
    end,
    %%需要清理掉之前可能存在的 战斗开始ref 战斗结束ref
    case get(?WAROFKING_BEGIN_WAR_REF) of
        undefined ->
            ignore;
        OldBeginWarRef ->
            erlang:cancel_timer(OldBeginWarRef)
    end,
    clear_end_timeref().

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

test() ->
    ok.

%% 测试安全时间获取
safe_time_test() ->    
    ?assertEqual(undefined, get_safe_time()),
    set_safe_time(5000),
    ?assertEqual(5000, get_safe_time()).

-endif.
