%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com(C) 2011, 
%%% @doc
%%% 大明宝藏副本模块
%%% @end
%%% Created : 25 Jan 2011 by  <caochuncheng>
%%%-------------------------------------------------------------------
-module(mod_country_treasure).

-include("mgeem.hrl").
-include("country_treasure.hrl").
%% API
-export([
         %% 地图初始化时，大明宝藏初始化
         init/2,
         %% 地图循环处理函数，即一秒循环
         loop/1
        ]).

-export([
         do_handle_info/1,handle/1,
         hook_role_map_enter/2,
         hook_role_quit/1,
         get_default_map_id/0,
         add_country_points/2,
         get_collect_broadcast_msg/5,
         get_country_treasure_fb_map_id/0,
         get_country_treasure_fb_born_points/1
        ]).

-export([
         init_country_treasure_dict/1,
         put_country_treasure_dict/2,
         get_country_treasure_dict/1,
         put_country_treasure_role_number/2,
         get_country_treasure_role_number/1
        ]).

%% 国家积分
-define(country_points, country_points).
%% 各国ID
-define(faction_hongwu, 1).
-define(faction_yongle, 2).
-define(faction_wanli, 3).
%% 加经验间隔
-define(EXP_ADD_INTERVAL, 15).
-define(INTERVAL_EXP_LIST, interval_exp_list).

%%%===================================================================
%%% API
%%%===================================================================
handle(Info) ->
    do_handle_info(Info).

%%@doc 获取默认的大明宝藏的地图ID
get_default_map_id()->
    10500.
%% 进入明宝藏地图入口NPC所在的地图
get_enter_fb_map_ids() ->
    [11100,12100,13100].

init_country_treasure_dict(MapId) ->
    NowSeconds = common_tool:now(),
    {NowDate,_NowTime} = common_tool:seconds_to_datetime(NowSeconds),
    TodayWeek = calendar:day_of_the_week(NowDate),
    Record = #r_country_treasure_dict{
      week = TodayWeek,
      start_time = 0,
      end_time = 0,
      next_bc_start_time = 0,
      next_bc_end_time = 0,
      next_bc_process_time = 0,
      before_interval = 0,
      close_interval = 0,
      process_interval = 0,
      min_role_level = 20},
    erlang:put({?COUNTRY_TREASURE_RECORD_DICT_PREFIX,MapId},Record).
put_country_treasure_dict(MapId,Record) ->
    erlang:put({?COUNTRY_TREASURE_RECORD_DICT_PREFIX,MapId},Record).
get_country_treasure_dict(MapId) ->
    erlang:get({?COUNTRY_TREASURE_RECORD_DICT_PREFIX,MapId}).
    

put_country_treasure_role_number(MapId,Number) ->
    erlang:put({country_treasure_role_number,MapId},Number).
get_country_treasure_role_number(MapId) ->
    erlang:get({country_treasure_role_number,MapId}).

syn_country_treasure_role_number(Type,Number) ->
    EnterFbMapIdList = get_enter_fb_map_ids(),
    lists:foreach(
      fun(MapId) ->
              MapProcessName = common_map:get_common_map_name(MapId),
              catch global:send(MapProcessName,{mod_country_treasure,{enter_ct_fb_number,Type,MapId,Number}})
      end,EnterFbMapIdList).
%% 地图初始化时，大明宝藏初始化
%% 参数：
%% MapId 地图id
%% MapName 地图进程名称
init(MapId, MapName) ->
    FBMapId = get_country_treasure_fb_map_id(),
    [IsOpenCountryTreasure] = common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,is_open_country_treasure),
    case FBMapId =:= MapId andalso IsOpenCountryTreasure =:= true of
        true ->
            init2(MapId, MapName);
        _ ->
            ignore
    end,
    %% 在三个王都地图初始化大明宝藏当前的人数
    EnterFbMapIdList = get_enter_fb_map_ids(),
    case lists:member(MapId,EnterFbMapIdList) of 
        true ->
            put_country_treasure_role_number(MapId,0);
        false ->
            ignore
    end.
            
init2(MapId, _MapName) ->
    NowSeconds = common_tool:now(),
    Record = get_country_treasure_dict_record(NowSeconds),
    put_country_treasure_dict(MapId,Record),
    %% 重置积分
    reset_country_points().

%% 地图循环处理函数，即一秒循环
%% 参数
%% MapId 地图id
loop(MapId) ->
    FBMapId = get_country_treasure_fb_map_id(),
    [IsOpenCountryTreasure] = common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,is_open_country_treasure),
    case FBMapId =:= MapId andalso IsOpenCountryTreasure =:= true of
        true ->
            NowSeconds = common_tool:now(),
            loop2(MapId,NowSeconds);
        _ ->
            ignore
    end.
loop2(MapId,NowSeconds) ->
    Record = get_country_treasure_dict(MapId),
    #r_country_treasure_dict{week = Week,kick_role_time = KickRoleTime} = Record,
    %% 当关闭时，有玩家进入副本时，不能正常被踢回王都
    Record2 = 
        if KickRoleTime =/= 0 andalso NowSeconds > (KickRoleTime - 65)  ->
                if KickRoleTime > NowSeconds  ->
                        catch kick_all_role_from_fb_map(),
                        Record;
                   true ->
                        catch kick_all_role_from_fb_map(),
                        NewRecord = Record#r_country_treasure_dict{kick_role_time = 0},
                        put_country_treasure_dict(MapId,NewRecord),
                        NewRecord
                end;
           true ->
                Record
        end,
    {NowDate,_NowTime} = common_tool:seconds_to_datetime(NowSeconds),
    TodayWeek = calendar:day_of_the_week(NowDate),
    if Week =:= TodayWeek ->
            loop3(MapId,NowSeconds,Record2);
       true ->
            next
    end,
    %% 加经验循环
    do_add_exp_interval(NowSeconds).
loop3(MapId,NowSeconds,Record) ->
    #r_country_treasure_dict{end_time = EndTime} = Record,
    %% 副本开起提前广播开始消息
    Record2 = do_fb_open_before_broadcast(MapId,NowSeconds,Record),
    %% 副本开启过程中广播处理
    Record3 = do_fb_open_process_broadcast(MapId,NowSeconds,Record2),
    %% 副本开起过程中，需要提前广播副本关闭信息
    Record4 = do_fb_open_close_broadcast(MapId,NowSeconds,Record3),
    put_country_treasure_dict(MapId,Record4),
    
    if EndTime =/= 0
       andalso NowSeconds > EndTime ->
            %% 本次副本结束处理，计算下次开启时间，还有副本结束广播
            NewRecord = get_country_treasure_dict_record(NowSeconds),
            put_country_treasure_dict(MapId,NewRecord#r_country_treasure_dict{kick_role_time = NowSeconds + 80}),
            %% 结束广播以及BUFF加成
            end_broadcast_and_buff(),
            catch kick_all_role_from_fb_map(),
            %% 重置积分
            reset_country_points(),
            syn_country_treasure_role_number(reset,0),
            NextStartTime = NewRecord#r_country_treasure_dict.start_time,
            EndMessageF = 
                if NextStartTime > 0 ->
                        {{NextY,NextM,NextD},{NextHH,NextMM,_NextSS}} = common_tool:seconds_to_datetime(NextStartTime), 
                        NextStartTimeStr = 
                            if NextMM < 10 ->
                                    lists:flatten(io_lib:format("~w-~w-~w ~w:0~w",[NextY,NextM,NextD,NextHH,NextMM]));
                               true ->
                                    lists:flatten(io_lib:format("~w-~w-~w ~w:~w",[NextY,NextM,NextD,NextHH,NextMM]))
                            end,
                        lists:flatten(io_lib:format(?_LANG_COUNTRY_TREASURE_E_CHAT,[NextStartTimeStr]));
                   true ->
                        ?_LANG_COUNTRY_TREASURE_E_CHAT_F
                end,
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,EndMessageF);
       true ->
            next
    end,    
    ok.


%% 副本开起提前广播开始消息
%% Record 结构为 r_country_treasure_dict
%% 返回 new r_country_treasure_dict
do_fb_open_before_broadcast(_MapId,NowSeconds,Record) ->
    #r_country_treasure_dict{
                             start_time = StartTime,
                             end_time = EndTime,
                             next_bc_start_time = NextBCStartTime,
                             before_interval = BeforeInterval,
                             min_role_level = MinRoleLevel} = Record,
    if StartTime =/= 0 
       andalso EndTime =/= 0 
       andalso NextBCStartTime =/= 0
       andalso NowSeconds >= NextBCStartTime 
       andalso NowSeconds < StartTime->
            %% 副本开起提前广播开始消息
            ?DEBUG("~ts,NowSeconds=~w,StartTime=~w,NextBCStartTime=~w",["副本开起提前广播开始消息",NowSeconds,StartTime,NextBCStartTime]),
            BeforeSeconds = if (StartTime - NowSeconds) < 0 -> 0; true -> (StartTime - NowSeconds) end,
            BeforeMessage = 
                if BeforeSeconds > 0 ->
                        {_Date,{H,M,_S}} = common_tool:seconds_to_datetime(StartTime),
                        StartTimeStr = 
                            if M < 10 ->
                                    lists:flatten(io_lib:format("~w:0~w",[H,M]));
                               true ->
                                    lists:flatten(io_lib:format("~w:~w",[H,M]))
                            end,
                        lists:flatten(io_lib:format(?_LANG_COUNTRY_TREASURE_B_CHAT,[StartTimeStr,common_tool:to_list(MinRoleLevel)]));
                   true ->
                        lists:flatten(io_lib:format(?_LANG_COUNTRY_TREASURE_B_CHAT_OK,[common_tool:to_list(MinRoleLevel)]))
                end,
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,BeforeMessage),
            Record#r_country_treasure_dict{
              next_bc_start_time = NowSeconds + BeforeInterval};
       true ->
            Record
    end.
%% 副本开启过程中广播处理
%% Record 结构为 r_country_treasure_dict
%% 返回
do_fb_open_process_broadcast(_MapId,NowSeconds,Record) ->
    #r_country_treasure_dict{
                              start_time = StartTime,
                              end_time = EndTime,
                              next_bc_process_time = NextBCProcessTime,
                              process_interval = ProcessInterval,
                              min_role_level = MinRoleLevel} = Record,
    ?DEV("NowSeconds=~w,NextBCProcessTime=~w,tttt=~w",[NowSeconds,NextBCProcessTime,NowSeconds-NextBCProcessTime]),
    if StartTime =/= 0 
       andalso EndTime =/= 0 
       andalso NowSeconds >= StartTime
       andalso EndTime >= NowSeconds 
       andalso NextBCProcessTime =/= 0
       andalso NowSeconds >= NextBCProcessTime ->
            %% 副本开起过程中广播时间到
            ?DEBUG("~ts,NowSeconds=~w,NextBCProcessTime=~w",["副本开起过程中广播时间到",NowSeconds,NextBCProcessTime]),
            ProcessMessage = lists:flatten(io_lib:format(?_LANG_COUNTRY_TREASURE_P_CHAT,[common_tool:to_list(MinRoleLevel)])),
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,ProcessMessage),
            Record#r_country_treasure_dict{
              next_bc_process_time = NowSeconds + ProcessInterval};
       true ->
            Record
    end.
%% 副本开起过程中，需要提前广播副本关闭信息
%% Record 结构为 r_country_treasure_dict
do_fb_open_close_broadcast(_MapId,NowSeconds,Record) ->
    #r_country_treasure_dict{
                            start_time = StartTime,
                            end_time = EndTime,
                            next_bc_end_time = NextBCEndTime,
                            close_interval = CloseInterval} = Record,
    if StartTime =/= 0 
       andalso EndTime =/= 0 
       andalso NowSeconds >= StartTime
       andalso EndTime >= NowSeconds
       andalso NextBCEndTime =/= 0
       andalso NowSeconds >= NextBCEndTime ->
            %% 副本开起过程中，需要提前广播副本关闭信息
            ?DEBUG("~ts,NowSeconds=~w,NextBCProcessTime=~w",["副本开起过程中，需要提前广播副本关闭信息",NowSeconds,NextBCEndTime]),
            if (EndTime - NowSeconds) < 0 ->
                    next;
               true ->
                    {_Date,{H,M,_S}} = common_tool:seconds_to_datetime(EndTime),
                    EndTimeStr = 
                        if M < 10 ->
                                lists:flatten(io_lib:format("~w:0~w",[H,M]));
                           true ->
                                lists:flatten(io_lib:format("~w:~w",[H,M]))
                        end,
                    EndMessage = lists:flatten(io_lib:format(?_LANG_COUNTRY_TREASURE_E_CENTER,[EndTimeStr])),
                    catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,EndMessage)
            end,
            Record#r_country_treasure_dict{
              next_bc_end_time = NowSeconds + CloseInterval};
       true ->
            Record
    end.


%% 进入大明宝藏副本
do_handle_info({Unique, ?COUNTRY_TREASURE, ?COUNTRY_TREASURE_ENTER, DataRecord, RoleId, PId, Line})
  when erlang:is_record(DataRecord,m_country_treasure_enter_tos)->
    do_country_treasure_enter({Unique, ?COUNTRY_TREASURE, ?COUNTRY_TREASURE_ENTER, DataRecord, RoleId, PId, Line});

%% 退出大明宝藏副本
do_handle_info({Unique, ?COUNTRY_TREASURE, ?COUNTRY_TREASURE_QUIT, DataRecord, RoleId, PId, Line})
  when erlang:is_record(DataRecord,m_country_treasure_quit_tos)->
    do_country_treasure_quit({Unique, ?COUNTRY_TREASURE, ?COUNTRY_TREASURE_QUIT, DataRecord, RoleId, PId, Line});

%% 查询大明宝藏副本信息
do_handle_info({Unique, ?COUNTRY_TREASURE, ?COUNTRY_TREASURE_QUERY, DataRecord, RoleId, PId, Line})
  when erlang:is_record(DataRecord,m_country_treasure_query_tos)->
    do_country_treasure_query({Unique, ?COUNTRY_TREASURE, ?COUNTRY_TREASURE_QUERY, DataRecord, RoleId, PId, Line});

%% 后台管理手工开起大明宝藏副本
%% IntervalSeconds 多少秒之后开启
%% global:send(MapProcessName,{mod_country_treasure,{admin_open_fb}})
do_handle_info({admin_open_fb}) ->
    do_admin_open_fb();
do_handle_info({enter_ct_fb_number,Type,MapId,Number}) ->
    do_enter_ct_fb_number(Type,MapId,Number);

do_handle_info({country_treasure_query,{Unique, Module, Method, DataRecord, RoleId, PId, Line}}) ->
    do_country_treasure_query({Unique, Module, Method, DataRecord, RoleId, PId, Line});

do_handle_info(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["商贸活动模块无法处理此消息",Info]),
    error.


%% 进入大明宝藏副本
%% DataRecord 结构为 m_country_treasure_enter_tos
do_country_treasure_enter({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_country_treasure_enter2({Unique, Module, Method, DataRecord, RoleId, PId, Line}) of
        {error,Reason} ->
            do_country_treasure_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason);
        {ok,RoleMapInfo} ->
            do_country_treasure_enter3({Unique, Module, Method, DataRecord, RoleId, PId, Line},RoleMapInfo)
    end.
do_country_treasure_enter2({_Unique, _Module, _Method, DataRecord, RoleId, _PId, _Line}) ->
    case common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,is_open_country_treasure) of
        [true] ->
            next;
        _ ->
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_NOT_OPEN})
    end,
    MapId = DataRecord#m_country_treasure_enter_tos.map_id,
    NpcId = DataRecord#m_country_treasure_enter_tos.npc_id,
    CurMapId = mgeem_map:get_mapid(),
    if MapId =:= CurMapId ->
            next;
       true ->
            ?DEBUG("~ts",["玩家不在可以进入大明宝藏副本的地图"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_ENTER_PARAM_ERROR})
    end,
    %% 检查玩家是否在NPC附近
    case check_valid_distance(RoleId,NpcId) of
        true ->
            next;
        false ->
            ?DEBUG("~ts",["玩家不在NPC附近，无法操作"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_NOT_VALID_DISTANCE})
    end,
    RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                ?DEBUG("~ts",["在本地图获取不到玩家的地图信息"]),
                erlang:throw({error,?_LANG_COUNTRY_TREASURE_ENTER_PARAM_ERROR});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    CheckLevel = 
        case common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,enter_fb_role_level) of
            [CheckLevelT] ->
                CheckLevelT;
            _ ->
                20
        end,
    if RoleMapInfo#p_map_role.level >= CheckLevel ->
            next;
       true ->
            ?DEBUG("~ts",["级别不够，无法进入副本"]),
            Reason = lists:flatten(io_lib:format(?_LANG_COUNTRY_TREASURE_ENTER_LEVEL,[common_tool:to_list(CheckLevel)])),
            erlang:throw({error,Reason})
    end,
    %% 检查参数Npc是否合法
    case check_valid_npc_id(MapId,NpcId) of
        true ->
            next;
        false ->
            ?DEBUG("~ts",["玩家请求的NPC ID 出错"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_ENTER_PARAM_ERROR})
    end,
    %% 检查当前是不是合法的时间进入大明宝藏副本
    case check_valid_enter_fb_time() of
        true ->
            next;
        false ->
            ?DEBUG("~ts",["当前不是大明宝藏副本的时间"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_NOT_OPEN_TIME})
    end,
    [{MaxEnterFbNumber,ViewEnterFbNumber}] = 
        common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,enter_fb_role_number),
    case get_country_treasure_role_number(MapId) of
        undefined ->
            next;
        FbRoleNumber ->
            if FbRoleNumber >= MaxEnterFbNumber ->
                    ?DEBUG("~ts,FbRoleNumber=~w",["当前副本的人数为",FbRoleNumber]),
                    FbRoleNumberError = lists:flatten(io_lib:format(?_LANG_COUNTRY_TREASURE_ENTER_FB_MAX_NUMBER,[common_tool:to_list(ViewEnterFbNumber)])),
                    erlang:throw({error,FbRoleNumberError});
               true ->
                    next
            end
    end,
    {ok,RoleMapInfo}.

do_country_treasure_enter3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                           RoleMapInfo) ->
    [Fee] = common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,enter_fb_fee),
    case catch common_transaction:transaction(
                 fun() ->  
                         deduct_enter_country_treasure_fee(RoleMapInfo,Fee)  
                 end) of
        {atomic, {ok, RoleAttr}} ->
            do_country_treasure_enter4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                       RoleMapInfo,RoleAttr);
        {aborted, Reason} ->
            ?DEBUG("~ts,Reason=~w",["进入大明宝藏副本出错",Reason]),
            Reason2 =
                if erlang:is_binary(Reason) ->
                        Reason;
                   true ->
                        ?_LANG_COUNTRY_TREASURE_ENTER_PARAM_ERROR
                end,
            do_country_treasure_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2)
    end.
do_country_treasure_enter4({Unique, Module, Method, DataRecord, RoleId, PId, _Line},
                           _RoleMapInfo,RoleAttr) ->
    SendSelf = #m_country_treasure_enter_toc{succ = true},
    ?DEBUG("~ts,SendSelf=~w",["进入大明宝藏副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    UnicastArg = {role, RoleId},
    AttrChangeList = [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value = RoleAttr#p_role_attr.silver},
                      #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value = RoleAttr#p_role_attr.silver_bind}],
    common_misc:role_attr_change_notify(UnicastArg,RoleId,AttrChangeList),
    syn_country_treasure_role_number(update,1),
    %% 根据玩家的国家信息查找大明宝藏副本的出生点
    MapId = DataRecord#m_country_treasure_enter_tos.map_id,
    FBMapId = get_country_treasure_fb_map_id(),
    {Tx,Ty} = get_country_treasure_fb_born_points(MapId),
    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_COUNTRY_TREASURE, RoleId, FBMapId, Tx, Ty),
    %% 成就 进入大明宝藏地图:303001 add by caochuncheng 2011-03-04
    common_hook_achievement:hook({mod_fb,{country_treasure_enter,RoleId}}),
    %%===记录玩家进入大明宝藏的日志===
    global:send(mgeew_country_treasure_log_server,{RoleId,RoleAttr#p_role_attr.level}),
	
    ok.

do_country_treasure_enter_error({Unique, Module, Method, _DataRecord, _RoleId, PId, _Line},Reason) ->
    SendSelf = #m_country_treasure_enter_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["进入大明宝藏副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).
%% 扣除手续费
deduct_enter_country_treasure_fee(RoleMapInfo,MsgFee) ->
    RoleId = RoleMapInfo#p_map_role.role_id,
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleId),
    SilverBind = RoleAttr#p_role_attr.silver_bind,
    Silver = RoleAttr#p_role_attr.silver,
    if (SilverBind + Silver) < MsgFee ->
            db:abort(?_LANG_COUNTRY_TREASURE_ENTER_ENOUGH_MONEY);
       true ->
            next
    end,
    if SilverBind < MsgFee ->
            NewSilver = Silver - (MsgFee - SilverBind),
            if NewSilver < 0 ->
                    db:abort(?_LANG_COUNTRY_TREASURE_ENTER_ENOUGH_MONEY);
               true ->
                    NewRoleAttr = RoleAttr#p_role_attr{silver_bind=0,silver=NewSilver },
                    mod_map_role:set_role_attr(RoleId, NewRoleAttr),
                    common_consume_logger:use_silver({RoleId, SilverBind, (MsgFee - SilverBind), ?CONSUME_TYPE_SILVER_COUNTER_TREASURE, ""}),
                    {ok, NewRoleAttr}
            end;
       true ->
            NewSilverBind = SilverBind - MsgFee,
            NewRoleAttr = RoleAttr#p_role_attr{silver_bind=NewSilverBind},
            mod_map_role:set_role_attr(RoleId, NewRoleAttr),
            common_consume_logger:use_silver({RoleId, MsgFee, 0, ?CONSUME_TYPE_SILVER_COUNTER_TREASURE, ""}),
            {ok, NewRoleAttr}
    end.
%% 退出大明宝藏副本
%% DataRecord 结构为 m_country_treasure_quit_tos
do_country_treasure_quit({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_country_treasure_quit2({Unique, Module, Method, DataRecord, RoleId, PId, Line}) of
        {error,Reason} ->
            do_country_treasure_quit_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason);
        {ok,RoleMapInfo} ->
            do_country_treasure_quit3({Unique, Module, Method, DataRecord, RoleId, PId, Line},RoleMapInfo)
    end.
do_country_treasure_quit2({_Unique, _Module, _Method, DataRecord, RoleId, _PId, _Line}) ->
    MapId = DataRecord#m_country_treasure_quit_tos.map_id,
    FBMapId = get_country_treasure_fb_map_id(),
    CurMapId = mgeem_map:get_mapid(),
    if MapId =:= CurMapId 
       andalso MapId =:= FBMapId ->
            next;
       true ->
            ?DEBUG("~ts",["玩家不在可以退出大明宝藏副本的地图"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_QUIT_PARAM_ERROR})
    end,
    RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                ?DEBUG("~ts",["在本地图获取不到玩家的地图信息"]),
                erlang:throw({error,?_LANG_COUNTRY_TREASURE_QUIT_PARAM_ERROR});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    {ok,RoleMapInfo}.

do_country_treasure_quit3({Unique, Module, Method, _DataRecord, RoleId, PId, _Line},
                          RoleMapInfo) ->
    SendSelf = #m_country_treasure_quit_toc{succ = true},
    ?DEBUG("~ts,SendSelf=~w",["退出大明宝藏副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    FactionId = RoleMapInfo#p_map_role.faction_id,
    %% 查找玩家所在的国家的王都的出生点
    MapId = common_misc:get_home_map_id(FactionId),
    {MapId,Tx,Ty} = common_misc:get_born_info_by_map(MapId),
    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleId, MapId, Tx, Ty),
    ok.

do_country_treasure_quit_error({Unique, Module, Method, _DataRecord, _RoleId, PId, _Line},Reason) ->
    SendSelf = #m_country_treasure_quit_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["退出大明宝藏副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

do_country_treasure_query({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    if DataRecord#m_country_treasure_query_tos.op_type =:= 1 ->
            FbMapId = get_default_map_id(),
            CurMapId = mgeem_map:get_mapid(),
            if FbMapId =:= CurMapId ->
                    do_country_treasure_query2({Unique, Module, Method, DataRecord, RoleId, PId, Line});
               true ->
                    case global:whereis_name(common_map:get_common_map_name(FbMapId)) of 
                        undefined ->
                            SendSelf = #m_country_treasure_query_toc{succ = false,op_type = 1},
                            ?DEBUG("~ts,SendSelf=~w",["查询大明宝藏副本返回结果",SendSelf]),
                            common_misc:unicast2(PId, Unique, Module, Method, SendSelf);
                        Pid ->
                            Pid ! {mod_country_treasure,{country_treasure_query,{Unique, Module, Method, DataRecord, RoleId, PId, Line}}}
                    end
            end;
       true ->
            do_country_treasure_query3({Unique, Module, Method, DataRecord, RoleId, PId, Line})
    end.
do_country_treasure_query2({Unique, Module, Method, _DataRecord, _RoleId, PId, _Line}) ->
    MapId = mgeem_map:get_mapid(),
    DictRecord = get_country_treasure_dict(MapId),
    #r_country_treasure_dict{end_time = EndTime,start_time = StartTime} = DictRecord,
    NowSeconds = common_tool:now(),
    [{NpcId,SeedFee}] = common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,bc_all_role_join),
    SendSelf = 
        if NowSeconds >= StartTime andalso NowSeconds < EndTime ->
                #m_country_treasure_query_toc{succ = true,op_type = 1,fb_start_time = StartTime,
                                              fb_end_time = EndTime,npc_id = NpcId, fee = SeedFee};
           true ->
                #m_country_treasure_query_toc{succ = false,op_type = 1}
        end,
    ?DEBUG("~ts,SendSelf=~w",["查询大明宝藏副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).
%% 处理玩家传送
do_country_treasure_query3({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_country_treasure_query4(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_country_treasure_query_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,RoleMapInfo} ->
            do_country_treasure_query5({Unique, Module, Method, DataRecord, RoleId, PId, Line},RoleMapInfo)
    end.
do_country_treasure_query4(RoleId,_DataRecord) ->
    RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_COUNTRY_TREASURE_QUERY_ERROR,0});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    [CheckLevel] = common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,enter_fb_role_level),
    if RoleMapInfo#p_map_role.level >= CheckLevel ->
            next;
       true ->
            ?DEBUG("~ts",["级别不够，无法进入副本"]),
            Reason = lists:flatten(io_lib:format(?_LANG_COUNTRY_TREASURE_ENTER_LEVEL,[common_tool:to_list(CheckLevel)])),
            erlang:throw({error,Reason,0})
    end,
    case mod_map_role:is_role_fighting(RoleId) of
        true ->
            ?DEBUG("~ts",["玩家处于战斗状态"]),
             erlang:throw({error,?_LANG_COUNTRY_TREASURE_IN_FIGHTING_STATUS,0});
        false ->
            next
    end,
    if RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_STALL 
       orelse RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_STALL_AUTO
       orelse RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_STALL_SELF ->
            ?DEBUG("~ts",["玩家处理摆摊状态"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_IN_STALL_STATUS,0});
       RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_DEAD ->
            ?DEBUG("~ts",["玩家处于死亡状态"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_IN_DEAD_STATUS,0});
       RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_FIGHT ->
            ?DEBUG("~ts",["玩家处于战斗状态"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_IN_FIGHTING_STATUS,0});
       RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_EXCHANGE ->
            ?DEBUG("~ts",["玩家处于交易状态"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_IN_EXCHANGE_STATUS,0});
       RoleMapInfo#p_map_role.state =:= ?ROLE_STATE_TRAINING ->
            ?DEBUG("~ts",["玩家处于离线挂机状态"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_IN_TRAINING_STATUS,0});
       true ->
            next
    end,
    %% 商贸状态
    [RoleState] = db:dirty_read(?DB_ROLE_STATE, RoleId),
    if RoleState#r_role_state.trading =:= 1 ->
            ?DEBUG("~ts",["玩家处于商贸状态"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_IN_TRADING_STATUS,0});
       RoleState#r_role_state.exchange =:= true ->
            ?DEBUG("~ts",["玩家处于交易状态"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_IN_EXCHANGE_STATUS,0});
       true ->
            next
    end,
    CurMapId = mgeem_map:get_mapid(),
    case CurMapId rem 10000 div 1000 of
        0 ->
            case CurMapId rem 10000 rem 1000 div 100 of
                2 ->
                    next;
                3 ->
                    next;
                _ ->
                    ?DEBUG("~ts,CurMapId=~w",["玩家处于副本",CurMapId]),
                    erlang:throw({error,?_LANG_COUNTRY_TREASURE_IN_FB_MAP,0})
            end;
        1 ->
            next;
        2 ->
            next;
        3 ->
            next;
        _ ->
            ?DEBUG("~ts,CurMapId=~w",["玩家处于特殊地图",CurMapId]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_IN_SPECIAL_MAP,0})
    end,
    %% 检查当前是不是合法的时间进入大明宝藏副本
    case check_valid_enter_fb_time() of
        true ->
            next;
        false ->
            ?DEBUG("~ts",["当前不是大明宝藏副本的时间"]),
            erlang:throw({error,?_LANG_COUNTRY_TREASURE_NOT_OPEN_TIME,0})
    end,
    {ok,RoleMapInfo}.

do_country_treasure_query5({Unique, Module, Method, DataRecord, RoleId, PId, Line},RoleMapInfo) ->
    [{NpcId,Fee}] = common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,bc_all_role_join),
    NpcId2 = NpcId + RoleMapInfo#p_map_role.faction_id * 1000000,
    case catch common_transaction:transaction(
                 fun() ->  
                         deduct_enter_country_treasure_fee(RoleMapInfo,Fee)  
                 end) of
        {atomic, {ok, RoleAttr}} ->
            do_country_treasure_query6({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                       RoleMapInfo,RoleAttr,NpcId2,Fee);
        {aborted, Reason} ->
            ?DEBUG("~ts,Reason=~w",["传送到大明宝藏副本入口出错",Reason]),
            Reason2 =
                if erlang:is_binary(Reason) ->
                        Reason;
                   true ->
                        ?_LANG_COUNTRY_TREASURE_QUERY_ERROR
                end,
            do_country_treasure_query_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
    end.
do_country_treasure_query6({Unique, Module, Method, DataRecord, RoleId, PId, _Line},
                           _RoleMapInfo,RoleAttr,NpcId,Fee) ->
    SendSelf = #m_country_treasure_query_toc{
      succ = true,
      op_type = DataRecord#m_country_treasure_query_tos.op_type,
      fee = Fee
     },
    ?DEBUG("~ts,SendSelf=~w",["查询大明宝藏副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    UnicastArg = {role, RoleId},
    AttrChangeList = [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value = RoleAttr#p_role_attr.silver},
                      #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value = RoleAttr#p_role_attr.silver_bind}],
    common_misc:role_attr_change_notify(UnicastArg,RoleId,AttrChangeList),
    [{NpcId, {NpcMapId, _NpcTx, _NpcTy}}] = ets:lookup(?ETS_MAP_NPC, NpcId),
    {DestTx,DestTy} = get_country_treasure_fb_born_points(NpcMapId),
    DestMapId = get_default_map_id(),
    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_COUNTRY_TREASURE, RoleId, DestMapId, DestTx, DestTy),
    %% 成就 进入大明宝藏地图:303001 add by caochuncheng 2011-03-04
    common_hook_achievement:hook({mod_fb,{country_treasure_enter,RoleId}}),
    %%===记录玩家进入大明宝藏的日志===
    global:send(mgeew_country_treasure_log_server,{RoleId,RoleAttr#p_role_attr.level}),
    ok.
do_country_treasure_query_error({Unique, Module, Method, DataRecord, _RoleId, PId, _Line},Reason,ReasonCode) ->
    SendSelf = #m_country_treasure_query_toc{
      succ = false,
      op_type = DataRecord#m_country_treasure_query_tos.op_type,
      reason = Reason,
      reason_code = ReasonCode},
    ?DEBUG("~ts,SendSelf=~w",["查询大明宝藏副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).
%% 后台管理手工开起大明宝藏副本
%% IntervalSeconds 多少秒之后开启
%% global:send(MapProcessName,{mod_country_treasure,{admin_open_fb}})
do_admin_open_fb() ->
    MapId = mgeem_map:get_mapid(),
    NowSeconds = common_tool:now(),
    Record = get_country_treasure_dict_record(NowSeconds),
    put_country_treasure_dict(MapId,Record).
    
do_enter_ct_fb_number(Type,MapId,Number) ->
    EnterFbMapIdList = get_enter_fb_map_ids(),
    case lists:member(MapId,EnterFbMapIdList) of
        true ->
            OldNumber = get_country_treasure_role_number(MapId),
            case Type of
                reset ->
                    put_country_treasure_role_number(MapId,0);
                update ->
                    NewNumber = if (OldNumber + Number) < 0 -> 0;true -> OldNumber + Number end,
                    put_country_treasure_role_number(MapId,NewNumber)
            end;
        false ->
            ignore
    end.

%% 获取大明宝藏副本地图
get_country_treasure_fb_map_id() ->
    case common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,fb_map_id) of
        [Value] ->
            Value;
        _ ->
            10500
    end.

%% 获取玩家的信息查找大明宝藏副本地图的出生点
%% 返回 {tx,ty}
get_country_treasure_fb_born_points(MapId) ->
    case common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,fb_born_points) of
        [DataList] ->
            case lists:keyfind(MapId,#r_country_treasure_born.map_id,DataList) of
                false ->
                    {90,90};
                #r_country_treasure_born{born_points = PointList} ->
                    Length = erlang:length(PointList),
                    RandomNumber = common_tool:random(1,Length),
                    lists:nth(RandomNumber,PointList)
            end;
        _ ->
            {90,90}
    end.
%% 检查参数Npc是否合法
%% 返回 true or false
check_valid_npc_id(MapId,NpcId) ->
    case common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,fb_born_points) of
        [DataList] ->
            case lists:keyfind(MapId,#r_country_treasure_born.map_id,DataList) of
                false ->
                    false;
                Record ->
                    if Record#r_country_treasure_born.map_id =:= MapId
                       andalso Record#r_country_treasure_born.npc_id =:= NpcId ->
                            true;
                       true ->
                            false
                    end
            end;
        _ ->
            false
    end.

%% 根据副本时间和当前时间计算相应的广播时间
%% 返回 {NextBCStartTime,NextBCEndTime,NextBCProcessTime}
get_next_bc_times(NowSeconds,StartTime,EndTime) ->
    [{BeforeSeconds,BeforeInterval}] =  common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,fb_open_before_msg_bc),
    [{CloseSeconds,CloseInterval}] =  common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,fb_open_close_msg_bc),
    [{ProcessInterval}] =  common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,fb_open_process_msg_bc),
    NextBCStartTime = 
        if NowSeconds >= StartTime ->
                0;
           true ->
                if (StartTime - NowSeconds) >= BeforeSeconds ->
                        StartTime - BeforeSeconds;
                   true ->
                        NowSeconds
                end
        end,
    NextBCEndTime = 
        if NowSeconds >= EndTime ->
                0;
           true ->
                if (EndTime - NowSeconds) >= CloseSeconds ->
                        EndTime - CloseSeconds;
                   true ->
                        NowSeconds
                end
        end,
    NextBCProcessTime =
        if NowSeconds > StartTime 
           andalso EndTime > NowSeconds ->
                NowSeconds;
           true ->
                if StartTime =/= 0 ->
                        StartTime;
                   true ->
                        0
                end
        end,
    {NextBCStartTime,NextBCEndTime,NextBCProcessTime,
     BeforeInterval,CloseInterval,ProcessInterval}.

%% 获取大明宝藏开启结束相关进程字典信息
%% 返回 r_country_treasure_dict
get_country_treasure_dict_record(NowSeconds) ->
    %% 根据当前时间获取开始下次大明宝藏副本的时间
    %% 返回 {ok,Week,StartTime,EndTime} or {error,not_found)
    case get_next_time_open_country_treasure(7,NowSeconds) of
        {error,not_found} ->
            #r_country_treasure_dict{
          week = 0,
          start_time = 0,
          end_time = 0,
          next_bc_start_time = 0,
          next_bc_end_time = 0,
          next_bc_process_time = 0,
          before_interval = 0,
          close_interval = 0,
          process_interval = 0,
          min_role_level = 20};
        {ok,Week,StartTime,EndTime} ->
            {NextBCStartTime,NextBCEndTime,NextBCProcessTime,
             BeforeInterval,CloseInterval,ProcessInterval} =
                get_next_bc_times(NowSeconds,StartTime,EndTime),
            [MinRoleLevel] = common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,enter_fb_role_level),
            #r_country_treasure_dict{
                                      week = Week,
                                      start_time = StartTime,
                                      end_time = EndTime,
                                      next_bc_start_time = NextBCStartTime,
                                      next_bc_end_time = NextBCEndTime,
                                      next_bc_process_time = NextBCProcessTime,
                                      before_interval = BeforeInterval,
                                      close_interval = CloseInterval,
                                      process_interval = ProcessInterval,
                                      min_role_level = MinRoleLevel}
    end.


%% 根据当前时间获取开始下次大明宝藏副本的时间
%% NextDays 查询范围，下几天的开始时间，
%% NowSeconds 当前时间秒数 
%% 返回 {ok,Week,StartTime,EndTime} or {error,not_found)
get_next_time_open_country_treasure(NextDays,NowSeconds) ->
    {NowDate,_NowTime} = common_tool:seconds_to_datetime(NowSeconds),
    {Week,OpenTimeList} = get_country_treasure_open_times(NowSeconds),
    case get_next_time_open_country_treasure1(NowDate,NowSeconds,OpenTimeList) of
        {false,_,_} ->
            if NextDays < 0 ->
                    {error,not_found};
               true ->
                    NextSeconds = common_tool:datetime_to_seconds({NowDate,{0,0,0}}) + 24 * 60 * 60,
                    get_next_time_open_country_treasure(NextDays -1,NextSeconds)
            end;
        {true,StartTime,EndTime} ->
            {ok,Week,StartTime,EndTime}
    end.
get_next_time_open_country_treasure1(NowDate,NowSeconds,OpenTimeList) ->
    lists:foldl(
      fun({StartTime,EndTime},Acc) ->
              {Flag,_AccS,_AccE} = Acc,
              case Flag of
                  true ->
                      Acc;
                  false ->
                      StartSeconds = common_tool:datetime_to_seconds({NowDate,StartTime}),
                      EndSeconds = common_tool:datetime_to_seconds({NowDate,EndTime}),
                      if NowSeconds >= StartSeconds andalso NowSeconds < EndSeconds ->
                              {true,StartSeconds,EndSeconds};
                         NowSeconds >= EndSeconds ->
                              Acc;
                         StartSeconds >=  NowSeconds ->
                              {true,StartSeconds,EndSeconds};
                         true ->
                              Acc
                      end
              end
      end,{false,0,0},OpenTimeList).

%% 获取今天大明宝藏副本开启起的时间配置
%% 返回 {Week,[]},or {Week,[{StartTime,EndTime},...]}
get_country_treasure_open_times(NowSeconds) ->
    {NowDate,_NowTime} = common_tool:seconds_to_datetime(NowSeconds),
    TodayWeek = calendar:day_of_the_week(NowDate),
    case common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,open_times) of
        [DataList] ->
            case lists:keyfind(TodayWeek,1,DataList) of
                false ->
                    {TodayWeek,[]};
                {TodayWeek,TimeList} ->
                    {TodayWeek,TimeList}
            end;
        _ ->
            {TodayWeek,[]}
    end.

%% 检查当前是不是合法的时间进入大明宝藏副本
%% 返回 true or false
check_valid_enter_fb_time() ->
    case common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,open_times) of
        [DataList] ->
            check_valid_enter_fb_time2(DataList);
        _ ->
            false
    end.
check_valid_enter_fb_time2(DataList) ->
    NowSeconds = common_tool:now(),
    {NowDate,_NowTime} = common_tool:seconds_to_datetime(NowSeconds),
    TodayWeek = calendar:day_of_the_week(NowDate),
    case lists:keyfind(TodayWeek,1,DataList) of
        false ->
            false;
        {TodayWeek,TimeList} ->
            check_valid_enter_fb_time3(NowSeconds,NowDate,TodayWeek,TimeList)
    end.
check_valid_enter_fb_time3(NowSeconds,NowDate,_TodayWeek,TimeList) ->
    lists:foldl(
      fun({{SH,SM,SS},{EH,EM,ES}},Acc) ->
              case Acc of
                  true ->
                      Acc;
                  false ->
                      StartSeconds = common_tool:datetime_to_seconds({NowDate,{SH,SM,SS}}),
                      EndSeconds = common_tool:datetime_to_seconds({NowDate,{EH,EM,ES}}),
                      if NowSeconds >= StartSeconds
                         andalso EndSeconds >= NowSeconds ->
                              true;
                         true ->
                              Acc
                      end
              end
      end,false,TimeList).


%% 检查玩家是否在有效的距离内
%% 参数
%% RoleId 玩家 id
%% NpcId 商贸商店NPC ID
%% 返回 true or false
check_valid_distance(RoleId,NpcId) ->
    [{NpcId, {MapId, Tx, Ty}}] = ets:lookup(?ETS_MAP_NPC, NpcId),
    {MaxTx,MaxTy} = get_npc_valid_distance(),
    InMapId = mgeem_map:get_mapid(),
    case mod_map_actor:get_actor_pos(RoleId, role) of
        undefined ->
            ?DEBUG("~ts", ["获取玩家位置信息出错"]),
            false;
        _ when MapId =/= InMapId ->
            ?DEBUG("~ts,InMapId=~w,MapId=~w", ["此NPC所在的地图与玩家地图不一致",InMapId,MapId]),
            false;
        Pos ->
            #p_pos{tx=InTx, ty=InTy} = Pos,
            TxDiff = erlang:abs(InTx - Tx),
            TyDiff = erlang:abs(InTy - Ty),
            if TxDiff < MaxTx  andalso TyDiff < MaxTy ->
                    true;
               true ->
                    false
            end
    end. 
%% 商贸活动玩家与NPC的有效距离 {tx,ty}
get_npc_valid_distance() ->
    case common_config_dyn:find(?COUNTRY_TREASURE_CONFIG,npc_valid_distance) of
        [Value] ->
            Value;
        _ ->
            {10,10}
    end.

%% 副本结束，将还在地图的所有人踢出副本地图
kick_all_role_from_fb_map() ->
    RoleIdList = mod_map_actor:get_in_map_role(),
    lists:foreach(
      fun(RoleId) ->
              %% 退出大明宝藏地图时，需要取消采集状态
              catch mod_map_collect:stop_collect(RoleId, ?_LANG_COLLECT_BREAK),
              FactionId = 
                  case mod_map_actor:get_actor_mapinfo(RoleId,role) of
                      undefined ->
                          case common_misc:get_dirty_role_base(RoleId) of
                              {ok,RoleBase} ->
                                  RoleBase#p_role_base.faction_id;
                              {error,_Reason} ->
                                  RandomNumber = common_tool:random(1,3),
                                  lists:nth(RandomNumber,[1,2,3])
                          end;
                      RoleMapInfo ->
                          RoleMapInfo#p_map_role.faction_id
                  end,
              %% 查找玩家所在的国家的王都的出生点
              MapId = common_misc:get_home_map_id(FactionId),
              {MapId,Tx,Ty} = common_misc:get_born_info_by_map(MapId),
              mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleId, MapId, Tx, Ty)
      end,RoleIdList).

%% 玩家进入大明宝藏地图需要处理的
hook_role_map_enter(RoleId,MapId) ->
    if MapId =:= 10500 ->
            ?DEBUG("~ts",["玩家进入大明宝藏地图需要设置PK模式"]),
            mod_role2:do_pk_mode_modify_for_10500(RoleId,?PK_FACTION),
            %% 插入加经验列表
            insert_interval_exp_list(RoleId),
            %% 推积分
            DataRecord = get_country_points_record(),
            common_misc:unicast({role, RoleId}, ?DEFAULT_UNIQUE, ?COUNTRY_TREASURE, ?COUNTRY_TREASURE_POINTS, DataRecord);
       true ->
            ignore
    end.

hook_role_quit(RoleId) ->
    MapId = mgeem_map:get_mapid(),
    FBMapId = get_default_map_id(),
    if FBMapId =:= MapId ->
            syn_country_treasure_role_number(update,-1),
            %% 移出加经验列表
            delete_interval_exp_list(RoleId);
       true ->
            ignore
    end.
%% @doc 重置积分
reset_country_points() ->
    [DefaultPoints] = common_config_dyn:find(country_treasure, default_country_points),
    %% 依次为云州、沧州、幽州
    put(?country_points, [DefaultPoints, DefaultPoints, DefaultPoints]).

%% @doc 增加国家积分，返回其它两个国家减少积分
add_country_points(FactionID, AddPoints) ->
    [HongWu, YongLe, WanLi] = get(?country_points),
    
    if
        FactionID =:= ?faction_hongwu ->
            YongLe2 = num_reduce(YongLe, AddPoints),
            WanLi2 = num_reduce(WanLi, AddPoints),
            AddPoints2 = YongLe + WanLi - YongLe2 - WanLi2,
            HongWu2 = HongWu + AddPoints2,
            put(?country_points, [HongWu2, YongLe2, WanLi2]),
            {{?faction_yongle, YongLe-YongLe2}, {?faction_wanli, WanLi-WanLi2}};
        
        FactionID =:= ?faction_yongle ->
            HongWu2 = num_reduce(HongWu, AddPoints),
            WanLi2 = num_reduce(WanLi, AddPoints),
            AddPoints2 = HongWu + WanLi - HongWu2 - WanLi2,
            YongLe2 = YongLe + AddPoints2,
            put(?country_points, [HongWu2, YongLe2, WanLi2]),
            {{?faction_hongwu, HongWu-HongWu2}, {?faction_wanli, WanLi-WanLi2}};

        true ->
            HongWu2 = num_reduce(HongWu, AddPoints),
            YongLe2 = num_reduce(YongLe, AddPoints),
            AddPoints2 = HongWu + YongLe - HongWu2 - YongLe2,
            WanLi2 = WanLi + AddPoints2,
            put(?country_points, [HongWu2, YongLe2, WanLi2]),
            {{?faction_hongwu, HongWu-HongWu2}, {?faction_yongle, YongLe-YongLe2}}
    end.

%% @doc 减
num_reduce(Num, Reduce) ->
    case Num - Reduce >= 0 of 
        true ->
            Num - Reduce;
        _ ->
            0
    end.

%% @doc 采集HOOK
get_collect_broadcast_msg(RoleName, FactionID, FactionName, Addr, GoodsName) ->
    [DefaultAdd] = common_config_dyn:find(country_treasure, default_points_add),
    %% 增加国家积分
    {{ReduceF1, ReduceP1}, {ReduceF2, ReduceP2}} = add_country_points(FactionID, DefaultAdd),
    %% 地图广播积分变动
    broadcast_points_change(),
    %% 获取广播内容
    Msg = io_lib:format(?_LANG_COLLECT_CHAT_BROADCAST_2_10500, [FactionName, RoleName, Addr, GoodsName]),
    
    if
        ReduceP1 =/= 0 andalso ReduceP2 =/= 0 ->
            MsgTail = io_lib:format(?_LANG_COLLECT_CENTER_BROADCAST_2_10500_TAIL_1, 
                                  [get_faction_name(ReduceF1), get_faction_name(ReduceF2), FactionName]);

        ReduceP1 =/= 0 orelse ReduceP2 =/= 0 ->
            case ReduceP1 of
                0 ->
                    ReduceFaction = ReduceP1;
                _ ->
                    ReduceFaction = ReduceP2 
            end,
            
            MsgTail = io_lib:format(?_LANG_COLLECT_CENTER_BROADCAST_2_10500_TAIL_2, 
                                  [get_faction_name(ReduceFaction), FactionName]);

        true ->
            MsgTail = io_lib:format(?_LANG_COLLECT_CENTER_BROADCAST_2_10500_TAIL_3,
                                  [get_faction_name(ReduceF1), get_faction_name(ReduceF2), FactionName])
    end,
    
    lists:flatten(lists:append(Msg, MsgTail)).

%% @doc 获取国家名称
get_faction_name(FactionID) ->
    case FactionID of
        ?faction_hongwu ->
            ?_LANG_COLLECT_HONGWU_COLOR;
        ?faction_yongle ->
            ?_LANG_COLLECT_YONGLE_COLOR;
        _ ->
            ?_LANG_COLLECT_WANLI_COLOR
    end.
                                    
%% @doc 获取积分
get_country_points_record() ->
    {_, AllPoints} =
        lists:foldl(
          fun(Points, {FactionID, Acc}) ->
                  {FactionID+1, [#p_country_points{faction_id=FactionID,
                                                   points=Points}|Acc]}
          end, {1, []}, get(?country_points)),              
    
    #m_country_treasure_points_toc{points=AllPoints}.

%% @doc 广播积分变动
broadcast_points_change() ->
    DataRecord = get_country_points_record(),

    lists:foreach(
      fun(RoleID) ->
              common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?COUNTRY_TREASURE, ?COUNTRY_TREASURE_POINTS, DataRecord)
      end, mod_map_actor:get_in_map_role()). 

%% @doc 计算排名
country_points_rank() ->
    PointsList = get(?country_points),
    {_, PointsList2} = 
        lists:foldl(
          fun(Points, {FactionID, Acc}) ->
                  {FactionID+1, [{FactionID, Points}|Acc]}
          end, {1, []}, PointsList),
    PointsList3 = lists:reverse(lists:keysort(2, PointsList2)),
    [{_, Max}|_] = PointsList3,
    
    {_, RankList, WinList, _} =
        lists:foldl(
          fun({FactionID, Points}, {RankID, Acc, Acc2, LastPoints}) ->
                  case Points =:= LastPoints of
                      true ->
                          case RankID of
                              1 ->
                                  {RankID, [{FactionID, RankID}|Acc], [FactionID|Acc2], Points};
                              _ ->
                                  {RankID, [{FactionID, RankID}|Acc], Acc2, Points}
                          end;
                      _ ->
                          {RankID+1, [{FactionID, RankID+1}|Acc], Acc2, Points}
                  end
          end, {1, [], [], Max}, PointsList3),
    
    {RankList, WinList}.

%% @doc 结束广播
get_fb_end_broadcast(WinList) ->
    Msg = 
        case WinList of
            [F1] ->
                io_lib:format(?_LANG_COUNTRY_TREASURE_QUIT_BROADCAST_1, [get_faction_name(F1), get_faction_name(F1)]);

            [F1, F2] ->
                io_lib:format(?_LANG_COUNTRY_TREASURE_QUIT_BROADCAST_2, [get_faction_name(F1), get_faction_name(F2),
                                                                         get_faction_name(F1), get_faction_name(F2)]);

            _ ->
                ?_LANG_COUNTRY_TREASURE_QUIT_BROADCAST_3
        end,

    lists:flatten(Msg).

%% @doc 结束广播
end_broadcast_and_buff() ->
    {RankList, WinList} = country_points_rank(),
    
    lists:foreach(
      fun(RoleID) ->
              case mod_map_actor:get_actor_mapinfo(RoleID, role) of
                  undefined ->
                      ignore;

                  #p_map_role{faction_id=FID} ->
                      {_FID, RankID} = lists:keyfind(FID, 1, RankList),

                      if
                          RankID =:= 1 ->
                              [BuffList] = common_config_dyn:find(country_treasure, faction_first_buff),
                              Random = random:uniform(length(BuffList)-1),
                              AddBuff = lists:sublist(BuffList, Random, 2),
                              add_buff(RoleID, AddBuff);
                          RankID =:= 2 ->
                              [BuffList] = common_config_dyn:find(country_treasure, faction_second_buff),
                              Random = random:uniform(length(BuffList)),
                              AddBuff = lists:nth(Random, BuffList),
                              add_buff(RoleID, [AddBuff]);
                          true ->
                              ignore
                      end
              end
      end, mod_map_actor:get_in_map_role()),
    
    Msg = get_fb_end_broadcast(WinList),
    common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], ?BC_MSG_TYPE_CHAT_WORLD, Msg).

%% @doc 加BUFF
add_buff(RoleID, BuffIDList) ->
    AddBuffs =
        lists:map(
          fun(ID) ->
                  {ok, BuffDetail} = mod_skill_manager:get_buf_detail(ID),
                  BuffDetail
          end, BuffIDList),
    
    mod_role_buff:add_buff(RoleID, RoleID, role, AddBuffs).

%% @doc 获取每次间隔加的经验
get_interval_exp_add(FactionID, Level) ->
    CountryPointsList = get(?country_points),
    (lists:nth(FactionID, CountryPointsList) + 200) * Level / 15.

do_add_exp_interval(Now) ->
    RoleIDList = get_interval_exp_list(Now),
    lists:foreach(
      fun(RoleID) ->
              case mod_map_actor:get_actor_mapinfo(RoleID, role) of
                  undefined ->
                      delete_interval_exp_list(RoleID);
                  #p_map_role{faction_id=FactionID, level=Level} ->
                      ExpAdd = get_interval_exp_add(FactionID, Level),
                      mod_map_role:do_add_exp(RoleID, ExpAdd)
              end
      end, RoleIDList).

%% @doc 插入加经验列表
insert_interval_exp_list(RoleID) ->
    List = get_interval_exp_list(RoleID),
    set_interval_exp_list(RoleID, [RoleID|List]).

delete_interval_exp_list(RoleID) ->
    List = get_interval_exp_list(RoleID),
    set_interval_exp_list(RoleID, lists:delete(RoleID, List)).

get_interval_exp_list(RoleID) ->
    Key = RoleID rem ?EXP_ADD_INTERVAL,
    case get({?INTERVAL_EXP_LIST, Key}) of
        undefined ->
            put({?INTERVAL_EXP_LIST, Key}, []),
            [];
        List ->
            List
    end.

set_interval_exp_list(RoleID, List) ->
    Key = RoleID rem ?EXP_ADD_INTERVAL,
    put({?INTERVAL_EXP_LIST, Key}, List).
