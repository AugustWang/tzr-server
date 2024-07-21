%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2010, 
%%% @doc
%%%
%%% @end
%%% Created : 22 Oct 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_training).

-include("mgeem.hrl").  

%% API Func
-export([handle/1,
         role_online/2,
         role_offline/1]).

-define(SYSTEMLETTER, 2).
-define(TRAININGPOINT_PER_GOLD, 10).
-define(zhangsanfeng_pos, {117, 43}).
-define(max_dis, 7).

%%%===================================================================
%%% API
%%%===================================================================

%% @doc 角色上线，如果训练时间到则停止训练，没有则继续
role_online(RoleID, MapID) ->
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    #p_role_base{status=Status} = RoleBase,
    
    case Status =:= ?ROLE_STATE_TRAINING of
        true ->
            [TrainingInfo] = db:dirty_read(?DB_TRAINING_CAMP, RoleID),
            #r_training_camp{start_time=StartTime, last_time=LastTime} = TrainingInfo,
            case common_tool:now()-StartTime >= LastTime*60 of
                true ->
                    do_training_stop(RoleID);
                _ ->
                    RemainTime = LastTime*60-(common_tool:now()-StartTime),
                    TimerRef = erlang:send_after(RemainTime*1000, self(), {mod_training, {training_stop, RoleID}}),
                    {ok, RoleState} = mod_map_role:get_role_state(RoleID),
                    mod_map_role:set_role_state(RoleID, RoleState#r_role_state2{training_timer_ref=TimerRef}),
                    role_online2(RoleID, MapID)
            end,
            ok;
        _ ->
            ignore
    end.

role_online2(RoleID, MapID) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            ignore;
        RoleMapInfo ->
            case check_role_npc_distance(RoleMapInfo, MapID) of
                ok ->
                    ok;
                {error, MapID2} ->
                    {TX, TY} = ?zhangsanfeng_pos,
                    role_change_pos(RoleID, MapID2, TX, TY, mgeem_map:get_state())
            end
    end.

%% @doc 角色下线
role_offline(RoleID) ->
    {ok, #r_role_state2{training_timer_ref=TimerRef}} = mod_map_role:get_role_state(RoleID),
    TimerRef =/= undefined andalso erlang:cancel_timer(TimerRef).

handle(Info) ->
    do_handle(Info).

%%%===================================================================
%%% interal function
%%%===================================================================

do_handle({Unique, Module, ?TRAININGCAMP_REMAIN_POINT, DataIn, RoleID, _PID, Line, _MapState}) ->
    do_remain_point(Unique, Module, ?TRAININGCAMP_REMAIN_POINT, DataIn, RoleID, Line);
do_handle({Unique, Module, ?TRAININGCAMP_EXCHANGE, DataIn, RoleID, _PID, Line, _MapState}) ->
    do_exchange(Unique, Module, ?TRAININGCAMP_EXCHANGE, DataIn, RoleID, Line);
do_handle({Unique, Module, ?TRAININGCAMP_START, DataIn, RoleID, _PID, Line, MapState}) ->
    do_start(Unique, Module, ?TRAININGCAMP_START, DataIn, RoleID, Line, MapState);
do_handle({Unique, Module, ?TRAININGCAMP_STOP, _DataIn, RoleID, _PID, Line, _MapState}) ->
    do_stop(Unique, Module, ?TRAININGCAMP_STOP, RoleID, Line, 1);
do_handle({Unique, Module, ?TRAININGCAMP_STATE, _DataIn, RoleID, _PID, Line, _MapState}) ->
    do_state(Unique, Module, ?TRAININGCAMP_STATE, RoleID, Line);

do_handle({training_stop, RoleID}) ->
    do_training_stop(RoleID);

do_handle(Info) ->
    ?ERROR_MSG("do_handle_info, unkonw msg: ~w", [Info]),
    ok.

%%获取当前经验点
do_remain_point(Unique, Module, Method, _DataIn, RoleID, Line) ->
    try
        case db:dirty_read(?DB_TRAINING_CAMP, RoleID) of
            [] ->
                TrainingPoint = 0,
                
                %%这个表只有在这个进程处理，赃操作就可以了。。。
                db:dirty_write(?DB_TRAINING_CAMP, #r_training_camp{role_id=RoleID, training_point=0, in_training=false});
            [TrainingInfo] ->
                TrainingPoint = TrainingInfo#r_training_camp.training_point
        end,
        
        DataRecord = #m_trainingcamp_remain_point_toc{training_point=TrainingPoint},
        common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord)
    catch
        _:R ->
            ?ERROR_MSG("do_remain_point, r: ~w", [R]),

            Record = #m_trainingcamp_remain_point_toc{succ=false, reason=?_LANG_SYSTEM_ERROR},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Record)
    end.

%%元宝兑换训练值
do_exchange(Unique, Module, Method, DataIn, RoleID, Line) ->
    ExchangePoint = DataIn#m_trainingcamp_exchange_tos.training_point,

    case ExchangePoint =< 0 of
        true ->
            DataRecord = #m_trainingcamp_exchange_toc{succ=false, reason=?_LANG_TRAINING_TRAINING_POINT_ILLEGAL},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord);

        _ ->
            do_exchange2(Unique, Module, Method, ExchangePoint, RoleID, Line)
    end.

do_exchange2(Unique, Module, Method, ExchangePoint, RoleID, Line) ->
    case db:transaction(
           fun() ->
                   t_do_exchange(RoleID, ExchangePoint)
           end)
    of
        {atomic, {Gold, GoldBind}} ->
            DataRecord = #m_trainingcamp_exchange_toc{gold=Gold, gold_bind=GoldBind};

        {aborted, R} when is_binary(R) ->
            DataRecord = #m_trainingcamp_exchange_toc{succ=false, reason=R};
        
        {aborted, R} ->
            ?ERROR_MSG("do_exchange, r: ~w", [R]),
            
            DataRecord = #m_trainingcamp_exchange_toc{succ=false, reason=?_LANG_SYSTEM_ERROR}
    end,
    
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

%% @doc 开始训练
do_start(Unique, Module, Method, DataIn, RoleID, Line, MapState) ->
    LastTime = DataIn#m_trainingcamp_start_tos.time,
    case catch check_can_start(RoleID, LastTime, MapState#map_state.mapid) of
        {ok, RoleAttr, RoleMapInfo} ->
            do_start2(Unique, Module, Method, LastTime, RoleID, RoleAttr, RoleMapInfo, Line, MapState);
        {error, Reason} ->
            do_start_error(Unique, Module, Method, RoleID, Reason, Line)
    end.

%% @doc 是否可开始挑战
check_can_start(RoleID, LastTime, MapID) ->
    case mod_jail:check_in_jail(MapID) of
        true ->
            erlang:throw({error, ?_LANG_TRAINING_START_IN_JAIL});
        _ ->
            ok
    end,
    %%单位：小时，最长的训练时间不超过24小时
    case LastTime =< 0 orelse LastTime > 24 of
        true ->
            erlang:throw({error, ?_LANG_TRAINING_TIME_ILLEGAL});
        _ ->
            ok
    end,
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{exp=Exp, next_level_exp=NextLevelExp} = RoleAttr,
    %% 当前经验超过升级经验的3倍，不给训练
    case Exp >= NextLevelExp*3 of
        true ->
            erlang:throw({error, ?_LANG_ROLE2_ADD_EXP_EXP_FULL});
        _ ->
            ok
    end,
    %% 角色状态检测
    RoleMapInfo =
        case mod_map_actor:get_actor_mapinfo(RoleID, role) of
            undefined ->
                erlang:throw({error, ?_LANG_TRAINING_START_SYSTEM_ERROR});
            RMI ->
                RMI
        end,
    #p_map_role{state=RoleState} = RoleMapInfo,
    case RoleState of
        ?ROLE_STATE_DEAD ->
            erlang:throw({error, ?_LANG_TRAINING_START_ROLE_DEAD});
        ?ROLE_STATE_STALL ->
            erlang:throw({error, ?_LANG_TRAINING_START_ROLE_STALL});
        _ ->
            ok
    end,
    case mod_map_role:is_role_fighting(RoleID) of
        true ->
            erlang:throw({error, ?_LANG_TRAINING_START_ROLE_FIGHT});
        _ ->
            ok
    end,
    [RoleState2] = db:dirty_read(?DB_ROLE_STATE, RoleID),
    #r_role_state{exchange=Exchange, trading=Trading} = RoleState2,
    if
        Exchange ->
            erlang:throw({error, ?_LANG_TRAINING_START_ROLE_EXCHANGE});
        Trading =:= 1 ->
            erlang:throw({error, ?_LANG_TRAINING_START_ROLE_TRADING});
        true ->
            ok
    end,
    {ok, RoleAttr, RoleMapInfo}.

do_start2(Unique, Module, Method, LastTime, RoleID, RoleAttr, RoleMapInfo, Line, MapState) ->
    case db:transaction(
           fun() ->
                   t_do_start(RoleID, RoleAttr, LastTime)
           end)
    of
        {atomic, LastTime2} ->
            do_start3(Unique, Module, Method, RoleID, RoleMapInfo, LastTime, LastTime2, Line, MapState);
        {aborted, R} when is_binary(R) ->
            do_start_error(Unique, Module, Method, RoleID, R, Line);
        {aborted, R} ->
            ?ERROR_MSG("do_start2, r: ~w", [R]),
            do_start_error(Unique, Module, Method, RoleID, ?_LANG_SYSTEM_ERROR, Line)
    end.

do_start3(Unique, Module, Method, RoleID, RoleMapInfo, LastTime, LastTime2, Line, MapState) ->
    %%强制玩家下马
    mod_equip_mount:force_mountdown(RoleID),
    %% 成就 add by caochuncheng 2011-03-08
    common_hook_achievement:hook({mod_training,{start,RoleID}}),
    %%将地图角色的状态改成训练
    mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.state, ?ROLE_STATE_TRAINING}], MapState),
    %% 相等则表示不会因经验满而提前停止训练
    case LastTime*60 =:= LastTime2 of
        true ->
            LastTime3 = 0;
        _ ->
            LastTime3 = LastTime2
    end,
    DataRecord = #m_trainingcamp_start_toc{last_time=LastTime3},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord),
    %% 如果玩家不在张三丰处，则强制传送到张三丰处，坐标暂时写死
    #map_state{mapid=MapID} = MapState,
    case check_role_npc_distance(RoleMapInfo, MapID) of
        ok ->
            ok;
        {error, MapID2} ->
            {TX, TY} = ?zhangsanfeng_pos,
            role_change_pos(RoleID, MapID2, TX, TY, MapState)
    end,
    %%定时取消训练状态
    TimerRef = erlang:send_after(LastTime2*60*1000, self(), {mod_training, {training_stop, RoleID}}),
    {ok, RoleState} = mod_map_role:get_role_state(RoleID),
    RoleState2 = RoleState#r_role_state2{training_timer_ref=TimerRef},
    mod_map_role:set_role_state(RoleID, RoleState2).

do_start_error(Unique, Module, Method, RoleID, Reason, Line) ->
    DataRecord = #m_trainingcamp_start_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

%%停止训练，stoptype: 0 -> 系统停止 1 -> 手动停止
do_stop(Unique, Module, Method, RoleID, Line, StopType) ->
    case db:transaction(
           fun() ->
                   t_do_stop(RoleID, StopType)
           end)
    of
        {atomic, {TrainingPoint, ExpGet, AddExp, TrainingTime, _RoleName}} ->
            %%手动取消的话还要取消定时
            {ok, #r_role_state2{training_timer_ref=TimerRef}} = mod_map_role:get_role_state(RoleID),
            TimerRef =/= undefined andalso erlang:cancel_timer(TimerRef),
            %%分线等于0的话角色应该是不在线的，一些通知就没必要了
            case Line =:= 0 of
                true ->
                    ignore;
                _ ->
                    %%更换地图角色状态
                    mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.state, ?ROLE_STATE_NORMAL}], mgeem_map:get_state()),

                    DataRecord = #m_trainingcamp_stop_toc{training_point=TrainingPoint, exp_get=ExpGet},
                    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord)
            end,
            case AddExp of
                {exp_change, Exp} ->
                    case Line =:= 0 of
                        true ->
                            ignore;
                        _ ->
                            ExpChange = #p_role_attr_change{change_type=?ROLE_EXP_CHANGE, new_value=Exp},
                            Record = #m_role2_attr_change_toc{roleid=RoleID, changes=[ExpChange]},
                            common_misc:unicast(Line, RoleID, Unique, ?ROLE2, ?ROLE2_ATTR_CHANGE, Record)
                    end;

                {level_up, Level, RoleAttr, RoleBase} ->
                    case Line =:= 0 of
                        true ->
                            Online = false;
                        _ ->
                            Online = true
                    end,
                    mod_map_role:do_after_level_up(Level, RoleAttr, RoleBase, ExpGet, Unique, Online);
                _ ->
                    ignore
            end,
            %%正常结束的话还要发信件
            case StopType of
                0 ->
                    time_over_notice(RoleID, TrainingTime, ExpGet);
                _ ->
                    ok
            end;
        {aborted, R} when is_binary(R) ->
            do_stop_error(Unique, Module, Method, RoleID, R, Line);
        {aborted, R}  ->
            ?ERROR_MSG("do_stop, r: ~w", [R]),

            do_stop_error(Unique, Module, Method, RoleID, ?_LANG_SYSTEM_ERROR, Line)
    end.

do_stop_error(Unique, Module, Method, RoleID, Reason, Line) ->
    DataRecord = #m_trainingcamp_stop_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

%%获取训练状态，返回总时间，消耗时间以及预计能达到的等级
do_state(Unique, Module, Method, RoleID, Line) ->
    try
        [TrainingInfo] = db:dirty_read(?DB_TRAINING_CAMP, RoleID),
        #r_training_camp{start_time=StartTime, last_time=LastTime} = TrainingInfo,
        
        {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
        #p_role_attr{exp=Exp, level=Level, next_level_exp=NextLevelExp} = RoleAttr,

        ExpireTime = common_tool:now() - StartTime,
        case ExpireTime > LastTime * 60 of
            true ->
                ExpireTime2 = LastTime * 60;
            _ ->
                ExpireTime2 = ExpireTime
        end,
        
        ExpGet = get_training_exp_get(ExpireTime, Level),
        case Exp+ExpGet >= NextLevelExp*3 of
            true ->
                ExpGet2 = NextLevelExp*3;
            _ ->
                ExpGet2 = Exp+ExpGet
        end,
        {ExpLevel, _} = mod_exp:get_new_level(ExpGet2, Level),

        TrainingPoint = get_training_point_need(ExpireTime, Level),
        
        DataRecord = #m_trainingcamp_state_toc{time_total=LastTime, time_expire=ExpireTime2 div 60, level_up=ExpLevel,
                                              training_point=TrainingPoint, exp_get=ExpGet},
        common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord)
    catch
        _:R ->
            ?ERROR_MSG("do_state, r: ~w", [R]),
            
            Record = #m_trainingcamp_state_toc{succ=false, reason=?_LANG_SYSTEM_ERROR},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Record)
    end.

%%时间到训练停止，找不到玩家分线玩家应该不在线，就不用通知什么的。。。
do_training_stop(RoleID) ->
    case common_misc:get_role_line_by_id(RoleID) of
        false ->
            do_stop(?DEFAULT_UNIQUE, ?TRAININGCAMP, ?TRAININGCAMP_STOP, RoleID, 0, 0);
        Line ->
            do_stop(?DEFAULT_UNIQUE, ?TRAININGCAMP, ?TRAININGCAMP_STOP, RoleID, Line, 0)
    end.

t_do_stop(RoleID, StopType) ->
    [TrainingInfo] = db:read(?DB_TRAINING_CAMP, RoleID, write),
    #r_training_camp{training_point=TrainingPoint,
                     start_time=StartTime, 
                     last_time=LastTime} = TrainingInfo,

    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    #p_role_base{status=RoleState} = RoleBase,

    case RoleState =:= ?ROLE_STATE_TRAINING of
        true ->
            ok;
        _ ->
            db:abort(?_LANG_TRAINING_NOT_IN_TRAINING)
    end,

    %%将角色状态设为正常
    mod_map_role:set_role_base(RoleID, RoleBase#p_role_base{status=?ROLE_STATE_NORMAL}),
    RoleName = RoleBase#p_role_base.role_name,
    
    case StopType of
        0 ->
            TrainingTime = LastTime * 60;
        _ ->
            case common_tool:now() - StartTime > LastTime * 60 of
                true ->
                    TrainingTime = LastTime * 60;
                _ ->
                    TrainingTime = common_tool:now() - StartTime
            end
    end,

    %%1分钟以内不给经验
    case TrainingTime =< 60 of
        true ->
            TrainingInfo2 = TrainingInfo#r_training_camp{in_training=false},
            db:write(?DB_TRAINING_CAMP, TrainingInfo2, write),

            {0, 0, ignore, 0, RoleName};
        _ ->
            {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
            #p_role_attr{level=Level, exp=Exp, next_level_exp=NextLevelExp} = RoleAttr,
            ExpGet = get_training_exp_get(TrainingTime, Level),

            case Exp + ExpGet >= 3 * NextLevelExp of
                true ->
                    ExpGet2 = 3 * NextLevelExp - Exp;
                _ ->
                    ExpGet2 = ExpGet
            end,

            AddExp = mod_map_role:t_add_exp(RoleID, ExpGet2, ?EXP_ADD_TYPE_TRAINING),
            %% bug，上面将角色状态设置成了正常，不过在加经验的时候，如果触发自动升级则会重算人物属性，在事务里面重新
            %% 获取base的时候，会取得旧的状态
            case AddExp of
                {level_up, L, RA, RoleBase2} ->
                    mod_map_role:set_role_base(RoleID, RoleBase2#p_role_base{status=?ROLE_STATE_NORMAL}),
                    AddExp2 = {level_up, L, RA, RoleBase2#p_role_base{status=?ROLE_STATE_NORMAL}};
                _ ->
                    AddExp2 = AddExp
            end,

            PointNeed = get_training_point_need(TrainingTime, Level),
            TrainingInfo2 = TrainingInfo#r_training_camp{
                              training_point=TrainingPoint-PointNeed,
                              in_training=false},
            db:write(?DB_TRAINING_CAMP, TrainingInfo2, write),

            {PointNeed, ExpGet2, AddExp2, TrainingTime, RoleName}
    end.

t_do_start(RoleID, RoleAttr, LastTime) ->
    {ok, #p_role_base{status=State}} = mod_map_role:get_role_base(RoleID),
    %% 是否已经在训练
    case State of
        ?ROLE_STATE_TRAINING ->
            db:abort(?_LANG_TRAINING_ALREADY_IN_TRAINING);
        _ ->
            ok
    end,
    #p_role_attr{level=Level, exp=Exp, next_level_exp=NextLevelExp} = RoleAttr,
    [TrainingInfo] = db:read(?DB_TRAINING_CAMP, RoleID, read),
    #r_training_camp{training_point=TrainingPoint} = TrainingInfo,
    %% 判断训练点是否足够
    PointNeed = get_training_point_need(LastTime*3600, Level),
    case TrainingPoint < PointNeed of
        true ->
            db:abort(?_LANG_TRAINING_NOT_ENOUGH_POINT);
        _ ->
            ok
    end,
    %% 经验满3倍后停止训练
    ExpGet = get_training_exp_get(LastTime*3600, Level),
    case Exp + ExpGet >= NextLevelExp * 3 of
        true ->
            LastTime2 = get_training_time(NextLevelExp*3-Exp, Level); 
        _ ->
            LastTime2 = LastTime * 60
    end,

    TrainingInfo2 = TrainingInfo#r_training_camp{
                      in_training=true,
                      start_time=common_tool:now(),
                      last_time=LastTime2
                     },
    db:write(?DB_TRAINING_CAMP, TrainingInfo2, write),

    %%放在角色状态里面处理要简单一点。。。
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    mod_map_role:set_role_base(RoleID, RoleBase#p_role_base{status=?ROLE_STATE_TRAINING}),
    
    LastTime2.

t_do_exchange(RoleID, ExchangePoint) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{gold=Gold, gold_bind=GoldBind} = RoleAttr,

    %%1元宝换10训练点，不满百的向上取百，先消耗绑定元宝
    GoldNeed = common_tool:ceil(ExchangePoint/?TRAININGPOINT_PER_GOLD),

    case Gold+GoldBind < GoldNeed of
        true ->
            db:abort(?_LANG_TRAINING_NOT_ENOUGH_GOLD);
        _ ->
            {RestGold, RestGoldBind} = calc_rest_gold(Gold, GoldBind, GoldNeed),

            common_consume_logger:use_gold({RoleID, GoldBind-RestGoldBind, Gold-RestGold, ?CONSUME_TYPE_GOLD_TRAINING_OFFLINE,
                                           ""}),
            
            RoleAttr2 = RoleAttr#p_role_attr{gold=RestGold, gold_bind=RestGoldBind},
            mod_map_role:set_role_attr(RoleID, RoleAttr2),

            [TrainingInfo] = db:read(?DB_TRAINING_CAMP, RoleID, write),
            TrainingPoint = TrainingInfo#r_training_camp.training_point,
            db:write(?DB_TRAINING_CAMP, TrainingInfo#r_training_camp{training_point=TrainingPoint+GoldNeed*?TRAININGPOINT_PER_GOLD}, write),
            
            {RestGold, RestGoldBind}
    end.

calc_rest_gold(Gold, GoldBind, GoldNeed) ->
    case GoldBind-GoldNeed >= 0 of
        true ->
            {Gold, GoldBind-GoldNeed};
        _ ->
            Tmp = GoldNeed - GoldBind,
            {Gold-Tmp, 0}
    end.

%%LastTime单位是秒
get_training_point_need(LastTime, Level) ->
    common_tool:ceil(LastTime/60/10) * get_point_need_every_ten_min(Level).

get_point_need_every_ten_min(Level) ->
    if
        Level < 30 ->
            1;
        Level < 40 ->
            2;
        Level < 50 ->
            3;
        Level < 70 ->
            4;
        Level < 90 ->
            5;
        Level < 110 ->
            6;
        Level < 130 ->
            7;
        Level < 150 ->
            8;
        true ->
            9
    end.

%%TrainTime单位是秒
get_training_exp_get(TrainingTime, Level) ->
    TrainingTime div 60 * get_training_exp_per_min(Level).

%%获得一定的经验需要多少分钟
get_training_time(ExpGet, Level) ->
    common_tool:ceil(ExpGet/get_training_exp_per_min(Level)).

get_training_exp_per_min(Level) ->
    [Exp] = common_config_dyn:find(training, Level),
    Exp.

time_over_notice(RoleID, TrainingTime, ExpGet) ->
    Text = common_letter:create_temp(?TRAINING_TIME_UP_LETTER, [TrainingTime div 60, ExpGet]),
    common_letter:sys2p(RoleID, Text, "来自训练营-张三丰的信件", 3).

%% @doc 角色传送
role_change_pos(RoleID, MapID2, TX, TY, MapState) ->
    #map_state{mapid=MapID} = MapState,
    case MapID =:= MapID2 of
        true ->
            mod_map_actor:same_map_change_pos(RoleID, role, TX, TY, ?CHANGE_POS_TYPE_NORMAL, MapState);
        _ ->
            mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_RETURN_HOME, RoleID, MapID2, TX, TY)
    end.

%% @doc 获取王都mapid
get_jingcheng_mapid(FactionID) ->
    10000 + FactionID * 1000 + 100.

%% @doc 角色NPC距离检测
check_role_npc_distance(RoleMapInfo, MapID) ->
    #p_map_role{faction_id=FactionID, pos=Pos} = RoleMapInfo,
    JingChengMapID = get_jingcheng_mapid(FactionID),
    case MapID =/= JingChengMapID of
        true ->
            {error, JingChengMapID};
        _ ->
            check_role_npc_distance2(JingChengMapID, Pos)
    end.

check_role_npc_distance2(JingChengMapID, Pos) ->
    #p_pos{tx=TX, ty=TY} = Pos,
    {TX2, TY2} = ?zhangsanfeng_pos,
    case erlang:abs(TX2-TX) =< ?max_dis andalso erlang:abs(TY2-TY) =< ?max_dis of
        true ->
            ok;
        _ ->
            {error, JingChengMapID}
    end.
