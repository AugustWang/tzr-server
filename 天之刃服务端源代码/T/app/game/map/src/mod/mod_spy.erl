%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2011, 
%%% @doc
%%%
%%% @end
%%% Created : 14 Feb 2011 by  <>
%%%-------------------------------------------------------------------
-module(mod_spy).

-include("mgeem.hrl").
-include("office.hrl").

-export([
         handle/1,
         get_spy_faction_state/1,
         role_online/3
        ]).

-export([
         hook_map_init/1,
         hook_map_loop_s/1,
         can_use_spy_time/5
        ]).

-define(request_type_get, 1).
%% 各国王都ID
-define(hongwu_jingcheng_mapid, 11100).
-define(yongle_jingcheng_mapid, 12100).
-define(wanli_jingcheng_mapid, 13100).
%% 各国国家ID
-define(hongwu_faction_id, 1).
-define(yongle_faction_id, 2).
-define(wanli_faction_id, 3).

-define(dict_spy_faction, dict_spy_faction).

%% start_hour: 开启时，start_min: 开启分，is_publish: 是否已开启，last_publish_date: 上次国探发布时间
%% is_broadcast_15min: 15分钟前广播是否已广播
-record(r_spy_faction, {faction_id, start_hour, start_min, is_publish, last_publish_date, is_broadcast_15min=false, is_broadcast_5min=false,
                        is_waroffaction_con}).

handle({Unique, Module, ?SPY_FACTION, DataIn, RoleID, PID, _Line, MapState}) ->
    do_spy_faction(Unique, Module, ?SPY_FACTION, DataIn, RoleID, PID, MapState);
handle({Unique, Module, ?SPY_TIME, DataIn, RoleID, PID, _Line, MapState}) ->
    do_spy_time(Unique, Module, ?SPY_TIME, DataIn, RoleID, PID, MapState);

handle({admin_set_spy_faction_time, FactionID, StartH, StartM}) ->
    do_admin_set_spy_faction_time(FactionID, StartH, StartM);

handle(Info) ->
    ?ERROR_MSG("mod_spy, unknow info: ~w", [Info]).

%% @doc 获取国探状态
get_spy_faction_state(FactionID) ->
    case common_misc:get_event_state({spy_faction, FactionID}) of
        {false, _} ->
            {ok, no_publish_today};
        {ok, #r_event_state{data=EventDate}} ->
            {{PublicDate, _}, StopTime} = EventDate,
            NowTime = common_tool:now(),
            {NowDate, _} = calendar:local_time(),

            if
                StopTime >= NowTime ->
                    {ok, in_spy_faction};
                PublicDate =:= NowDate ->
                    {ok, has_published};
                true ->
                    {ok, no_publish_today}
            end
    end.

%% @doc 角色上线
role_online(_RoleID, PID, FactionID) ->
    case common_misc:get_event_state({spy_faction, FactionID}) of
        {false, _} ->
            ignore;
        {ok, #r_event_state{data=EventData}} ->
            {_, StopTime} = EventData,
            NowTime = common_tool:now(),

            case StopTime > NowTime of
                true ->
                    DataRecord = #m_spy_faction_time_toc{remain_time=StopTime-NowTime},
                    common_misc:unicast2(PID, ?DEFAULT_UNIQUE, ?SPY, ?SPY_FACTION_TIME, DataRecord);
                _ ->
                    ignore
            end
    end.

%% @doc 地图初始化，仅作用于王都的地图进程
hook_map_init(MapID) ->
    case MapID of
        ?hongwu_jingcheng_mapid ->
            hook_map_init2(?hongwu_faction_id);
        ?yongle_jingcheng_mapid ->
            hook_map_init2(?yongle_faction_id);
        ?wanli_jingcheng_mapid ->
            hook_map_init2(?wanli_faction_id);
        _ ->
            ignore
    end.

hook_map_init2(FactionID) ->
    {ok, {StartHour, StartMin}} = get_spy_faction_start_time(FactionID),
    %% 获取国探状态
    SpyFactionState = get_spy_faction_state(FactionID),
    case SpyFactionState of
        {ok, no_publish_today} ->
            IsPublish = false;
        _ ->
            IsPublish = true
    end,
    %% 是否与国战冲突
    LocalTime = calendar:local_time(),
    case check_spy_time_waroffaction(FactionID, StartHour, StartMin, LocalTime, SpyFactionState) of
        ok ->
            IsWarOfFactionCon = false;
        _ ->
            IsWarOfFactionCon = true
    end,
    put(?dict_spy_faction, #r_spy_faction{faction_id=FactionID, start_hour=StartHour, start_min=StartMin, is_publish=IsPublish,
                                          is_waroffaction_con=IsWarOfFactionCon}).

-define(broadcast_15min, -15).
-define(broadcast_5min, -5).

%% @doc 地图每秒循环
hook_map_loop_s(MapID) when MapID =/= ?hongwu_jingcheng_mapid andalso MapID =/= ?yongle_jingcheng_mapid andalso MapID =/= ?wanli_jingcheng_mapid ->
    ignore;
hook_map_loop_s(_MapID) ->
    SpyFaction = get_spy_faction_info(),
    #r_spy_faction{faction_id=FactionID, start_hour=StartH, start_min=StartM, is_publish=IsPublish, last_publish_date=LastDate,
                   is_broadcast_15min=IsBroadcast15Min, is_broadcast_5min=IsBroadcast5Min, is_waroffaction_con=IsWarOfFactionCon} = SpyFaction,
    %% 开服第几天后开启开探
    [StartDiff] = common_config_dyn:find(spy, spy_faction_start_day),
    [IsOpenSpyFaction] = common_config_dyn:find(spy,is_open_spy_faction),
    LocalTime = calendar:local_time(),
    {NowDate, {H, M, _}} = LocalTime,
    TimeDiffMin = time_diff_min(H, M, StartH, StartM),
    OpenedDays = common_config:get_opened_days(),
    if  IsOpenSpyFaction =:= false ->
            ignore;
        OpenedDays < StartDiff ->
            ignore;            
        LastDate =:= NowDate andalso IsPublish ->
            ignore;
        IsWarOfFactionCon ->
            ignore;
        TimeDiffMin < ?broadcast_15min orelse TimeDiffMin > 0 ->
            ignore;
        TimeDiffMin >= ?broadcast_15min andalso TimeDiffMin =< ?broadcast_15min + 1 andalso IsBroadcast15Min =:= false ->
            set_spy_faction_info(SpyFaction#r_spy_faction{is_broadcast_15min=true}),
            %% 全国广播
            common_broadcast:bc_send_msg_faction(FactionID, [?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], 
                                                 ?BC_MSG_TYPE_CHAT_WORLD, 
                                                 ?_LANG_SPY_FACTION_START_15_MIN_BEFORE);

        TimeDiffMin >= ?broadcast_5min andalso TimeDiffMin =< ?broadcast_5min + 1 andalso IsBroadcast5Min =:= false ->
            set_spy_faction_info(SpyFaction#r_spy_faction{is_broadcast_5min=true}),
            %% 全国广播
            common_broadcast:bc_send_msg_faction(FactionID, [?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], 
                                                 ?BC_MSG_TYPE_CHAT_WORLD, 
                                                 ?_LANG_SPY_FACTION_START_5_MIN_BEFORE);

        TimeDiffMin >= 0 andalso TimeDiffMin =< 1 ->
            spy_faction_start(SpyFaction, LocalTime);

        true ->
            ignore
    end.

%% @doc 国探开启
spy_faction_start(SpyFaction, LocalTime) ->
    #r_spy_faction{faction_id=FactionID} = SpyFaction,

    case catch check_can_start_spy_faction(SpyFaction) of
        ok ->
            spy_faction_start2(SpyFaction, LocalTime);

        {error, Reason} ->
            common_broadcast:bc_send_msg_faction(FactionID, [?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], 
                                                         ?BC_MSG_TYPE_CHAT_WORLD, Reason)
    end.

spy_faction_start2(SpyFaction, LocalTime) ->
    {NowDate, _} = LocalTime,
    #r_spy_faction{faction_id=FactionID, start_hour=StartH, start_min=StartM} = SpyFaction,
    case check_spy_time_waroffaction(FactionID, StartH, StartM, LocalTime, in_spy_faction) of
        ok ->
            IsWarOfFactionCon = false;
        _ ->
            IsWarOfFactionCon = true
    end,
    set_spy_faction_info(SpyFaction#r_spy_faction{is_publish=true, last_publish_date=NowDate, is_waroffaction_con=IsWarOfFactionCon}),
    
    [SpyFactionLastTime] = common_config_dyn:find(spy, spy_last_time),
    SpyFactionStopTime = common_tool:now() + SpyFactionLastTime,

    %% 插入发布纪录
    common_misc:set_event_state({spy_faction, FactionID}, {LocalTime, SpyFactionStopTime}),
    %% 广播
    [{NpcMapID, NpcID, TX, TY}] = common_config_dyn:find(spy, {spy_mission_npc, FactionID}),

    DataRecord = #m_spy_faction_toc{
      return_self=false, 
      map_id=NpcMapID, 
      npc_id=NpcID,
      tx=TX,
      ty=TY,
      remain_time=SpyFactionLastTime
     },

    common_misc:chat_broadcast_to_faction(FactionID, ?SPY, ?SPY_FACTION, DataRecord).

%% @doc 后台设置国探时间
do_admin_set_spy_faction_time(FactionID, StartH, StartM) ->
    SpyFaction = get_spy_faction_info(),
    case SpyFaction of
        undefined ->
            ignore;
        _ ->
            common_misc:set_event_state({spy_time, FactionID}, {calendar:local_time(), {StartH, StartM}}),

            SpyFaction2 = SpyFaction#r_spy_faction{start_hour=StartH, start_min=StartM, is_publish=false,
                                                   is_broadcast_15min=false, is_broadcast_5min=false, is_waroffaction_con=false},
            set_spy_faction_info(SpyFaction2)
    end.  

%% @doc 设置国探时间
do_spy_time(Unique, Module, Method, DataIn, RoleID, PID, MapState) ->
    #m_spy_time_tos{request_type=RequestType} = DataIn,
    case RequestType of
        ?request_type_get ->
            do_spy_time_get(Unique, Module, Method, RoleID, PID, MapState);
        _ ->
            do_spy_time_set(Unique, Module, Method, DataIn, RoleID, PID, MapState)
    end.

do_spy_time_get(Unique, Module, Method, RoleID, PID, #map_state{mapid=MapID}) ->
    case get_spy_faction_start_time() of
        {ok, {StartHour, StartMin}} ->
            case catch check_can_spy_faction(RoleID, MapID) of
                {ok, SpyFaction} ->
                    HasPublish = SpyFaction#r_spy_faction.is_publish, 
                    CanStartNow = true;
                {error, ?_LANG_SPY_FACTION_HAS_PUBLISHED} ->
                    HasPublish = true,
                    CanStartNow = false;
                _ ->
                    HasPublish = false,
                    CanStartNow = false
            end,
            DataRecord = #m_spy_time_toc{start_hour=StartHour, start_min=StartMin, can_start_now=CanStartNow, has_publish=HasPublish};
        _ ->
            DataRecord = #m_spy_time_toc{succ=false, reason=?_LANG_SPY_TIME_GET_SYSTEM_ERROR}
    end,
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

do_spy_time_set(Unique, Module, Method, DataIn, RoleID, PID, #map_state{mapid=MapID}) ->
    case catch check_can_set_time(RoleID, MapID, DataIn) of
        {ok, RoleName, FactionID, OfficeID, SpyFaction} ->
            do_spy_time_set2(Unique, Module, Method, DataIn, RoleID, PID, RoleName, FactionID, OfficeID, SpyFaction);
        {error, Reason} when is_binary(Reason) ->
            do_spy_time_error(Unique, Module, Method, PID, Reason);
        Error ->
            ?ERROR_MSG("do_spy_time, system error: ~w", [Error]),
            do_spy_time_error(Unique, Module, Method, PID, ?_LANG_SPY_TIME_SYSTEM_ERROR)
    end.

do_spy_time_set2(Unique, Module, Method, DataIn, _RoleID, PID, RoleName, FactionID, OfficeID, SpyFaction) ->
    #m_spy_time_tos{start_hour=StartHour, start_min=StartMin} = DataIn,
    %% 纪录设置的时间
    common_misc:set_event_state({spy_time, FactionID}, {calendar:local_time(), {StartHour, StartMin}}),
    %% 设置国探开启时间
    set_spy_faction_info(SpyFaction#r_spy_faction{start_hour=StartHour, start_min=StartMin, is_waroffaction_con=false}),
    
    common_misc:unicast2(PID, Unique, Module, Method, #m_spy_time_toc{start_hour=StartHour, start_min=StartMin}),
    %% 广播
    OfficeName = ?OFFICE_NAME(OfficeID),
    Msg = lists:flatten(io_lib:format(?_LANG_SPY_TIME_SET_BROADCAST, [OfficeName, RoleName, StartHour, min2str(StartMin)])),
    common_broadcast:bc_send_msg_faction(FactionID, [?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], ?BC_MSG_TYPE_CHAT_WORLD, Msg).

do_spy_time_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_spy_time_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 发布国探
do_spy_faction(Unique, Module, Method, _DataIn, RoleID, PID, #map_state{mapid=MapID}) ->
    case catch check_can_spy_faction(RoleID, MapID) of
        {ok, SpyFaction} ->
            spy_faction_start2(SpyFaction, calendar:local_time());
        {error, Reason} ->
            do_spy_faction_error(Unique, Module, Method, RoleID, Reason, PID)
    end.
                  
do_spy_faction_error(Unique, Module, Method, _RoleID, Reason, PID) ->
    DataRecord = #m_spy_faction_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 是否可开启国探
check_can_start_spy_faction(SpyFaction) ->
    #r_spy_faction{faction_id=FactionID} = SpyFaction,
    [SpyFee] = common_config_dyn:find(office, spy_faction_fee),
    [#p_faction{silver=Silver}] = db:dirty_read(?DB_FACTION, FactionID),
    case Silver < SpyFee of
        false ->
            ok;
        _ ->
            throw({error, ?_LANG_SPY_FACTION_SILVER_NOT_ENOUGH})
    end.

%% @doc 是否可以发布国探
check_can_spy_faction(RoleID, MapID) ->
    SpyFaction =
        case get_spy_faction_info() of
            undefined ->
                throw({error, ?_LANG_SPY_TIME_NPC_POS_TOO_FAR});
            SF ->
                SF
        end,
    %% 是否发布过国探
    #r_spy_faction{is_publish=IsPublish} = SpyFaction,
    case IsPublish of
        true ->
            throw({error, ?_LANG_SPY_FACTION_HAS_PUBLISHED});
        _ ->
            ok
    end,
    %% 只有国王跟大将军才能发布国探
    {ok, #p_role_attr{office_id=OfficeID}} = common_misc:get_dirty_role_attr(RoleID),
    {ok, #p_role_base{faction_id=FactionID}} = mod_map_role:get_role_base(RoleID),
    case OfficeID =:= ?OFFICE_ID_KING orelse OfficeID =:= ?OFFICE_ID_JINYIWEI of
        true ->
            ok;
        _ ->
            throw({error, ?_LANG_SPY_FACTION_ONLY_KING_AND_GENERAL_CAN_PUBLISH})
    end,
    %% 检查发布时间是否合法
    [{StartH, EndH}] = common_config_dyn:find(spy, spy_faction_time),
    {_, {H, _, _}} = calendar:local_time(),
    case H >= StartH andalso H =< EndH of
        true ->
            ok;
        _ ->
            throw({error, ?_LANG_SPY_FACTION_PUBLISH_TIME_ILLEGAL})
    end,
    %% 检测与NPC距离
    case check_role_npc_distance(RoleID, FactionID, MapID) of
        ok ->
            ok;
        {error, Reason} ->
            throw(Reason)
    end,
    %% 国战期间不能发布国探
    case mod_waroffaction:get_waroffaction_stage() of
        undefined ->
            ok;
        _ ->
            throw({error, ?_LANG_SPY_FACTION_IN_WAR_OF_FACTION})
    end,
    %% 国运期间不能发布国探
    case mod_ybc_person:faction_ybc_status(FactionID) of
        {activing, _} ->
            throw({error, ?_LANG_SPY_FACTION_IN_PERSONYBC_FACTION});
        _ ->
            ok
    end,
    %% 国库银两是否足够
    [SpyFee] = common_config_dyn:find(office, spy_faction_fee),
    [#p_faction{silver=Silver}] = db:dirty_read(?DB_FACTION, FactionID),
    case Silver < SpyFee of
        false ->
            ok;
        _ ->
            throw({error, ?_LANG_SPY_FACTION_SILVER_NOT_ENOUGH})
    end,
    
    {ok, SpyFaction}.

%% @doc 角色NPC距离判定
check_role_npc_distance(_RoleID, _FactionID, _MapID) ->
    ok.

%% @doc 是否可以设置国探时间
check_can_set_time(RoleID, MapID, DataIn) ->
    #m_spy_time_tos{start_hour=StartHour, start_min=StartMin} = DataIn,
    SpyFaction =
        case get_spy_faction_info() of
            undefined ->
                throw({error, ?_LANG_SPY_TIME_NPC_POS_TOO_FAR});
            SF ->
                SF
        end,
    %% 输入是否合法
    case check_spy_time_input(StartHour, StartMin) of
        ok ->
            ok;
        {error, Reason} ->
            throw({error, Reason})
    end,
    %% 输入的时间是否合法
    case check_spy_time_illegal(StartHour, StartMin) of
        ok ->
            ok;
        {error, Reason2} ->
            throw({error, Reason2})
    end,
    {ok, RoleAttr} = common_misc:get_dirty_role_attr(RoleID),
    #p_role_attr{role_name=RoleName, office_id=OfficeID} = RoleAttr,
    %% 只有国王跟锦衣卫指挥使才能够设置国探时间
    case OfficeID =:= ?OFFICE_ID_KING orelse OfficeID =:= ?OFFICE_ID_JINYIWEI of
        true ->
            ok;
        _ ->
            throw({error, ?_LANG_SPY_TIME_ONLY_KING_AND_JINYIWEI})
    end,
    %% 与NPC距离判断
    RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID, role),
    #p_map_role{faction_id=FactionID, pos=Pos} = RoleMapInfo,
    case check_spy_time_npc_pos(MapID, Pos) of
        ok ->
            ok;
        {error, Reason3} ->
            throw({error, Reason3})
    end,
    LocalTime = calendar:local_time(),
    %% 今日修改次数判断
    case check_spy_time_today_count(FactionID, LocalTime) of
        ok ->
            ok;
        {error, Reason4} ->
            throw({error, Reason4}) 
    end,
    %% 国运时间判断
    case check_spy_time_ybc_faction(FactionID, StartHour, StartMin) of
        ok ->
            ok;
        {error, Reason5} ->
            throw({error, Reason5})
    end,
    %% 国探时间判断
    {ok, SpyFactionState} = get_spy_faction_state(FactionID),
    case check_spy_time_waroffaction(FactionID, StartHour, StartMin, LocalTime, SpyFactionState) of
        ok ->
            ok;
        {error, Reason6} ->
            throw({error, Reason6})
    end,
    
    {ok, RoleName, FactionID, OfficeID, SpyFaction}.

%% @doc 国探时间修改，输入合法性检测
check_spy_time_input(StartHour, StartMin) ->
    case StartHour < 0 orelse StartHour >= 24 of
        true ->
            {error, ?_LANG_SPY_TIME_INPUT_HOUR_ILLEGAL};
        _  ->
            case StartMin < 0 orelse StartMin >= 60 of
                true ->
                    {error, ?_LANG_SPY_TIME_INPUT_MIN_ILLEGAL};
                _ ->
                    ok
            end
    end.

%% @doc 国探时间修改，是否能够设置这个时间
check_spy_time_illegal(StartHour, _StartMin) ->
    [{SH, EH}] = common_config_dyn:find(spy, spy_faction_time),
    case StartHour < SH orelse StartHour > EH of
        true ->
            {error, ?_LANG_SPY_TIME_ILLEGAL};
        _ ->
            ok
    end.

%% @doc 国探时间修改，与NPC距离判断
check_spy_time_npc_pos(_MapID, _Pos) ->
    case get_spy_faction_start_time() of
        {error, _} ->
            {error, ?_LANG_SPY_TIME_NPC_POS_TOO_FAR};
        _ ->
            ok
    end.

%% @doc 国探时间修改，判断今日修改次数
check_spy_time_today_count(FactionID, LocalTime) ->
    case common_misc:get_event_state({spy_time, FactionID}) of
        {false, _} ->
            ok;
        {ok, #r_event_state{data=Data}} ->
            {{ModifyDate, _}, _} = Data,
            {NowDate, _} = LocalTime,
            
            case ModifyDate =:= NowDate of
                true ->
                    {error, ?_LANG_SPY_TIME_TODAY_COUNT_LIMITED};
                _ ->
                    ok
            end
    end.

%% @doc 国探时间修改，判断与国运时间是否冲突
check_spy_time_ybc_faction(FactionID, StartHour, StartMin) ->
    {EndH, EndM} = common_misc:get_end_time(StartHour, StartMin, 3600),
    Check = mod_ybc_person:can_use_ybc_faction_time(FactionID, 
                                                    StartHour, 
                                                    StartMin, 
                                                    EndH, 
                                                    EndM),
    if
        Check =:= true ->
            ok;
        true ->
            {error, ?_LANG_SPY_TIME_FACTION_YBC_SAME}
    end.
    
%% @doc 国探时间修改，判断与国战时间是否冲突
check_spy_time_waroffaction(FactionID, StartHour, StartMin, LocalTime, SpyFactionState) ->
    case mod_waroffaction:get_waroffaction_declare_info(FactionID) of
        {ok, no_declare} ->
            ok;
        {ok, {_, _, {Date, _}}} ->
            {NowDate, _} = LocalTime,
            [{{WarStartHour, WarStartMin}, WarLastMin}] = common_config_dyn:find(spy, waroffaction_time),
            TimeConflict = common_misc:check_time_conflict(WarStartHour, WarStartMin, WarLastMin, StartHour, StartMin),
            if
                %% 今天宣战了，明天有国战，国探已发布
                NowDate =:= Date andalso (SpyFactionState =:= has_published orelse SpyFactionState =:= in_spy_faction)
                andalso TimeConflict =:= error ->
                    
                    {error, ?_LANG_SPY_TIME_WAROFFACTION_TIME_CONFLICT_TOMORROW};
                %% 昨天宣战，今天有国战，国探未发布
                NowDate =/= Date andalso SpyFactionState =:= no_publish_today andalso TimeConflict =:= error ->
                    {error, ?_LANG_SPY_TIME_WAROFFACTION_TIME_CONFLICT_TODAY};
                
                true ->
                    ok
            end
    end.
        
%% @doc 获取国探开启时间，没有设置则取默认时间
get_spy_faction_start_time(FactionID) ->
    case common_misc:get_event_state({spy_time, FactionID}) of
        {false, _} ->
            [{StartHour, StartMin}] = common_config_dyn:find(spy, spy_start_time);
        {ok, #r_event_state{data=Data}} ->
            {_, {StartHour, StartMin}} = Data
    end,
    
    {ok, {StartHour, StartMin}}.

%% @doc 获取国探开启时间，从进程字典中获取
get_spy_faction_start_time() ->
    case get(?dict_spy_faction) of
        undefined ->
            {error, system_error};
        SpyFaction ->
            #r_spy_faction{start_hour=StartH, start_min=StartM} = SpyFaction,
            {ok, {StartH, StartM}}
    end.

%% @doc 获取国探信息
get_spy_faction_info() ->
    get(?dict_spy_faction).

%% @doc 设置国探信息
set_spy_faction_info(SpyFaction) ->
    put(?dict_spy_faction, SpyFaction).


%% @doc 
time_diff_min(H1, M1, H2, M2) ->
    H1 * 60 + M1 - (H2 * 60 + M2).

%% @doc min2str
min2str(Min) ->
    if Min < 10 ->
            io_lib:format("0~w", [Min]);
       true ->
            common_tool:to_list(Min)
    end.

can_use_spy_time(FactionID, StartH, StartM, EndH, EndM) ->
    EventData = common_misc:get_event_state({spy_time, FactionID}),
    case EventData of
        {false, _} ->
            true;
        {ok, Data} ->
            {_, {H,M}} =  Data#r_event_state.data,
            StartCheck = common_misc:check_time_conflict(H, M, 60, StartH, StartM),
            EndCheck = common_misc:check_time_conflict(H, M, 60, EndH, EndM),
            StartCheck =:= ok andalso EndCheck =:= ok
    end.
