%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     处理活动子模块（包括今日活动、活动福利等）
%%% @end
%%% Created : 2010-12-17
%%%-------------------------------------------------------------------
-module(mod_activity).

-include("mgeem.hrl").
-include("dynamic_monster.hrl").

%% API
-export([
         handle/1,
         do_finish_task/2
         ]).

-define(DEFAULT_ACTIVITY_TYPE,1).

-define(ACTPOINT_REWARD_LIMIT_TIME_START,{0,0,0}).
-define(ACTPOINT_REWARD_LIMIT_TIME_END,{0,10,0}).



%%%===================================================================
%%% API
%%%===================================================================

handle({Unique, Module, ?ACTIVITY_TODAY, DataIn, RoleID, PID,Line})->
    do_today({Unique, Module, ?ACTIVITY_TODAY, DataIn, RoleID, PID, Line});
handle({Unique, Module, ?ACTIVITY_BENEFIT_LIST, DataIn, RoleID, PID,Line})->
    do_benefit_list({Unique, Module, ?ACTIVITY_BENEFIT_LIST, DataIn, RoleID, PID, Line});
handle({Unique, Module, ?ACTIVITY_BENEFIT_REWARD, DataIn, RoleID, PID,Line})->
    do_benefit_reward({Unique, Module, ?ACTIVITY_BENEFIT_REWARD, DataIn, RoleID, PID, Line});
handle({Unique, Module, ?ACTIVITY_BENEFIT_BUY, DataIn, RoleID, PID, Line})->
    do_benefit_buy({Unique, Module, ?ACTIVITY_BENEFIT_BUY, DataIn, RoleID, PID, Line});
handle({Unique, Module, ?ACTIVITY_GETGIFT, DataIn, RoleID, PID, _Line}) ->
    do_getgift(Unique, Module, ?ACTIVITY_GETGIFT, DataIn, RoleID, PID);
handle({Unique, Module, ?ACTIVITY_PAY_GIFT_INFO, _DataIn, RoleID, PID, _Line}) ->
    do_pay_gift_info(Unique, Module, ?ACTIVITY_PAY_GIFT_INFO, RoleID, PID);
handle({Unique, Module, ?ACTIVITY_BOSS_GROUP, DataIn, RoleID, PID, Line}) ->
    do_boss_group(Unique,Module,?ACTIVITY_BOSS_GROUP,DataIn,RoleID,PID,Line);
handle({handle,FactionID,MapPID,Request})->
    do_handle_boss_group(FactionID,MapPID,Request);

handle(Args) ->
    ?ERROR_MSG("~w, unknow args: ~w", [?MODULE,Args]),
    ok. 

%% boss群请求,现在玩家所在进程获取国家信息，然后路由到监狱
do_boss_group(Unique,Module,Method,DataIn,RoleID,PID,Line)->
    {ok,#p_role_base{faction_id=FactionID}} = mod_map_role:get_role_base(RoleID),
    MapProcessName = common_misc:get_map_name(?DEFAULT_MAPID),
    case global:whereis_name(MapProcessName) of
        undefined->
            DataRecord = #m_activity_boss_group_toc{succ=false, reason=?_LANG_BOSS_GROUP_BUSY},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord);
        MapPID->
            MapPID ! {mod_activity,{handle,FactionID,self(),{Unique, Module, Method, DataIn, RoleID, PID, Line}}}
    end.

%% 监狱处理消息
do_handle_boss_group(FactionID,MapPID,{Unique,Module,Method,DataIn,RoleID,PID,Line})->
    Date = date(),
    {DateTime,ViewList}=mod_dynamic_monster:get_boss_group_view_list(),
    {_NewDateTime,NewViewList} =
    case common_tool:datetime_to_seconds({Date,{0,0,0}})>DateTime of
        true->
            ConfigList=
            case common_config_dyn:find(mccq_activity,?BOSS_GROUP_KEY) of
                []->[];
                [_ConfigList]->_ConfigList
            end,
            mod_dynamic_monster:boss_group_view_init(ConfigList,{Date,{0,0,0}});
         false->{DateTime,ViewList}
    end,
    case DataIn#m_activity_boss_group_tos.op_type of
        ?BOSS_GROUP_GET_LIST->
            do_get_boss_group_list({Unique,Module,Method,DataIn,RoleID,PID,Line},NewViewList,FactionID,Date);
        ?BOSS_GROUP_GET_DETAIL->
            do_get_boss_group_detail({Unique,Module,Method,DataIn,RoleID,PID,Line},NewViewList,FactionID);
        ?BOSS_GROUP_TRANSFER->
            do_boss_group_transfer({Unique,Module,Method,DataIn,RoleID,PID,Line},MapPID,NewViewList,FactionID)
    end.
%% 获取列表
do_get_boss_group_list({Unique,Module,Method,DataIn,_RoleID,PID,_Line},ViewList,FactionID,Date)->
    R = #m_activity_boss_group_toc{op_type= DataIn#m_activity_boss_group_tos.op_type,
                          boss_group_list =
                              [begin
                                   {MapID,TX,TY} = get_map_born_info(FactionID,List),
                                   #p_boss_group{boss_id=ID,
                                                 start_time=common_tool:datetime_to_seconds({Date,StartTime}),
                                                 end_time = common_tool:datetime_to_seconds({Date,EndTime}),
                                                 last_time=LastTime,
                                                 space_time=SpaceTime,
                                                 map_id=MapID,
                                                 tx=TX,
                                                 ty=TY}
                               end||{ID,StartTime,EndTime,LastTime,SpaceTime,List}<-ViewList]
                         },
    common_misc:unicast2(PID, Unique, Module, Method, R).


%% 获取boss详情
do_get_boss_group_detail({Unique,Module,Method,DataIn,_RoleID,PID,_Line},ViewList,FactionID)->
    BossID = DataIn#m_activity_boss_group_tos.boss_id,
    R = 
        case lists:keyfind(BossID, 1, ViewList) of
            false->
                #m_activity_boss_group_toc{op_type=DataIn#m_activity_boss_group_tos.op_type,
                                  boss_id=BossID,
                                  succ=false,
                                  reason=?_LANG_BOSS_GROUP_CLOSE};
            {BossID,_,_,_,_,List}->
                {MapID,TX,TY} =get_map_born_info(FactionID,List),
                #m_activity_boss_group_toc{op_type=DataIn#m_activity_boss_group_tos.op_type,
                                  boss_id=BossID,
                                  map_id=MapID,
                                  tx=TX,
                                  ty=TY}
        end,
    common_misc:unicast2(PID, Unique, Module, Method, R).
%% 传送
do_boss_group_transfer({Unique,Module,Method,DataIn,RoleID,PID,Line},MapPID,ViewList,FactionID)->
    BossID = DataIn#m_activity_boss_group_tos.boss_id,
    case lists:keyfind(BossID, 1, ViewList) of
        false->
            R=
                #m_activity_boss_group_toc{op_type=DataIn#m_activity_boss_group_tos.op_type,
                                  boss_id=BossID,
                                  succ=false,
                                  reason=?_LANG_BOSS_GROUP_CLOSE},
            common_misc:unicast2(PID, Unique, Module, Method, R);
        {BossID,_,_,_,_,List}->
            {DestMapID,TX,TY} =get_map_born_info(FactionID,List),
            DestDataIn=#m_map_transfer_tos{mapid=DestMapID, tx=TX, ty=TY, change_type=0},
            MapPID!{Unique, ?MAP, ?MAP_TRANSFER, DestDataIn, RoleID, PID, Line}
    end.

get_map_born_info(FactionID,List) when is_list(List)->
    case lists:keyfind(FactionID, 1, List) of
        false->
            case List of 
                [{0,{_Map,_TX,_TY}}]->{_Map,_TX,_TY};
                _->{0,0,0}
            end;
        {FactionID,{_Map,_TX,_TY}}->{_Map,_TX,_TY}
    end;
get_map_born_info(_,_)->
    {0,0,0}.

%% 获取充值礼包的相关信息
do_pay_gift_info(Unique, Module, Method, RoleID, PID) ->
    case common_config_dyn:find(pay_gift, pay_first_gift_id) of
        [] ->
            do_pay_gift_info_error(Unique, Module, Method, ?_LANG_ACTIVITY_SYSTEM_ERROR_WHEN_GET_PAY_GIFT_INFO, PID);
        [PayFirstGiftID] ->
            [AccPayConfig] = common_config_dyn:find(pay_gift, accumulate_pay),
            %% 目前的版本只能
            {PayGold, GoodsConfigList} = erlang:hd(AccPayConfig),
            {ok, #p_role_attr{category=CategoryID}} = mod_map_role:get_role_attr(RoleID),
            %% 获取动态道具的信息，有可能会找不到，例如配置错误
            GoodsConfig = lists:foldl(
                            fun(#r_item_gift_base{category=CID} = GoodsRecord, Acc) ->
                                    case CID =:= CategoryID of
                                        true ->
                                            GoodsRecord;
                                        false ->
                                            Acc
                                    end
                            end, none, GoodsConfigList),
            case GoodsConfig =:= none of
                true ->
                    do_pay_gift_info_error(Unique, Module, Method, ?_LANG_ACTIVITY_SYSTEM_ERROR_WHEN_GET_PAY_GIFT_INFO, PID);
                false ->
                    {ok, [GoodsInfo]} = mod_gift:get_p_goods_by_item_gift_base_record(GoodsConfig),                    
                    [#r_pay_activity{get_first=GetFirst, accumulate_history=AccumulateHistory}] = db:dirty_read(?DB_PAY_ACTIVITY_P, RoleID),
                    case lists:keymember(PayGold, 1, AccumulateHistory) of
                        true ->
                            HasGetPaySingle = true;
                        false ->
                            HasGetPaySingle = false
                    end,
                    %% ！！开心礼包，默认用第一批次新手卡礼包
                    [#r_activate_code_info{gift_id=HappyGiftID}] = common_config_dyn:find(activate_code, 1),
                    [#r_gift{gift_list=PayFirstGoodsList}] = common_config_dyn:find(gift, PayFirstGiftID),
                    [#r_gift{gift_list=HappyGiftGoodsList}] = common_config_dyn:find(gift, HappyGiftID),
                    R = #m_activity_pay_gift_info_toc{succ=true, pay_first_type_id=PayFirstGiftID, 
                                                      pay_first_goods_list=PayFirstGoodsList,
                                                      has_get_pay_first_gift=GetFirst,
                                                      accumulate_pay_goods_info=GoodsInfo#p_goods{id=0, roleid=RoleID, bagposition=0, bagid=0},
                                                      has_get_accumulate_pay_gift=HasGetPaySingle,
                                                      happy_gift_goods_list=HappyGiftGoodsList},
                    common_misc:unicast2(PID, Unique, Module, Method, R)                        
            end
    end.

do_pay_gift_info_error(Unique, Module, Method, Reason, PID) ->
    R = #m_activity_pay_gift_info_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, R).


-define(BFN_ID_LIST,[10001,10003,10004,10006,10007,10008,
                     20001,20002,20003]).

%% 领取活动礼包
do_getgift(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_activity_getgift_tos{type=Type} = DataIn,
    case Type of 
        1 ->
            do_get_pay_first_gift(Unique, Module, Method, RoleID, PID);
        _ ->
            do_get_pay_single_gift(Unique, Module, Method, RoleID, PID)
    end.

%% 领取首充礼包
do_get_pay_first_gift(Unique, Module, Method, RoleID, PID) ->
    [TypeID] = common_config_dyn:find(pay_gift, pay_first_gift_id),
    case db:transaction(
           fun() ->
                   [#r_pay_activity{get_first=GetFirst, all_pay_gold=AllPayGold}=PayActivity] = db:read(?DB_PAY_ACTIVITY_P, RoleID, write),
                   case AllPayGold > 0 of
                       true ->                
                           case GetFirst of
                               false ->                                   
                                   GoodsCreateInfo = #r_goods_create_info{bag_id=0, num=1, type_id=TypeID, bind=true,
                                                                          start_time=0, end_time=0, type=?TYPE_ITEM},
                                   db:write(?DB_PAY_ACTIVITY_P, PayActivity#r_pay_activity{get_first=true}, write),
                                   mod_bag:create_goods(RoleID, GoodsCreateInfo);
                               true ->
                                   db:abort(?_LANG_ACTIVITY_HAS_GET_WHEN_GET_FIRST_PAY)
                           end;
                       false ->
                           db:abort(?_LANG_ACTIVITY_NOT_PAYED_WHEN_GET_FIRST_PAY)
                   end
           end)
    of
        {atomic, {ok, GoodsList}} ->
            common_misc:update_goods_notify({role,RoleID}, GoodsList),
            common_misc:unicast2(PID, Unique, Module, Method, #m_activity_getgift_toc{}),
            %% 道具消费日志
            lists:foreach(
              fun(LogGoods) ->
                      catch common_item_logger:log(RoleID,LogGoods,1,?LOG_ITEM_TYPE_PAY_FIRST_GIFT_HUO_DE)
              end,GoodsList),
            ok;
        {aborted, Error} ->
            case erlang:is_binary(Error) of
                true ->
                    common_misc:unicast2(PID, Unique, Module, Method, #m_activity_getgift_toc{succ=false, reason=Error});
                false ->                    
                    case Error of
                        {throw, {bag_error, not_enough_pos}} ->
                             common_misc:unicast2(PID, Unique, Module, Method, 
                                         #m_activity_getgift_toc{succ=false, reason=?_LANG_ACTIVITY_BAG_ENOUGH_WHEN_GET_PAY_FIRST_GIFT});
                        _ ->
                            ?ERROR_MSG("~ts:~w", ["领取首充礼包时发生系统错误", Error]),
                            common_misc:unicast2(PID, Unique, Module, Method, 
                                                 #m_activity_getgift_toc{succ=false, reason=?_LANG_ACTIVITY_SYSTEM_ERROR_WHEN_GET_PAY_FIRST_GIFT})
                    end
            end
    end,
    ok.


%% 领取单次充值礼包
do_get_pay_single_gift(Unique, Module, Method, RoleID, PID) ->
    [AccPayConfig] = common_config_dyn:find(pay_gift, accumulate_pay),
    %% 目前的版本只能
    {PayGold, GoodsConfigList} = erlang:hd(AccPayConfig),
    {ok, #p_role_attr{role_name=RoleName, category=CategoryID}} = mod_map_role:get_role_attr(RoleID),
    %% 获取动态道具的信息，有可能会找不到，例如配置错误
    GoodsConfig = lists:foldl(
                    fun(#r_item_gift_base{category=CID} = GoodsRecord, Acc) ->
                            case CID =:= CategoryID of
                                true ->
                                    GoodsRecord;
                                false ->
                                    Acc
                            end
                    end, none, GoodsConfigList),
    case GoodsConfig =:= none of
        true ->
            do_pay_gift_info_error(Unique, Module, Method, ?_LANG_ACTIVITY_SYSTEM_ERROR_WHEN_GET_PAY_GIFT_INFO, PID);
        false ->
            {ok, [GoodsInfo]} = mod_gift:get_p_goods_by_item_gift_base_record(GoodsConfig),
            case db:transaction(fun() -> t_get_accumulate_gift(RoleID, PayGold, GoodsInfo) end) of
                {atomic, {ok, GoodsList}} ->
                    common_misc:update_goods_notify({role,RoleID}, GoodsList),
                    common_misc:unicast2(PID, Unique, Module, Method, #m_activity_getgift_toc{}),
                    [#p_goods{current_colour=Color} = Goods] = GoodsList,
                    GoodsName = common_misc:format_goods_name_colour(Color,Goods#p_goods.name),
                    Content = io_lib:format("<font color='#FFFF00'>[~s]</font>领取了<u><a href='event:openShouchongWin'>~s</a></u>，实力得到了极大的提升！", [RoleName, GoodsName]),
                    common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], ?BC_MSG_TYPE_CHAT_WORLD, Content),
                    %% 道具消费日志
                    lists:foreach(
                      fun(LogGoods) ->
                              catch common_item_logger:log(RoleID,LogGoods,GoodsInfo#p_goods.current_num,?LOG_ITEM_TYPE_PAY_GIFT_HUO_DE)
                      end,GoodsList),
                    ok;
                {aborted, Error} ->
                    case erlang:is_binary(Error) of
                        true ->
                            common_misc:unicast2(PID, Unique, Module, Method, #m_activity_getgift_toc{succ=false, reason=Error});
                        false ->                    
                            case Error of
                                {throw, {bag_error, not_enough_pos}} ->
                                    common_misc:unicast2(PID, Unique, Module, Method, 
                                                         #m_activity_getgift_toc{succ=false, 
                                                                                 reason=?_LANG_ACTIVITY_BAG_ENOUGH_WHEN_GET_PAY_FIRST_GIFT});
                                _ ->
                                    ?ERROR_MSG("~ts:~w", ["领取首充礼包时发生系统错误", Error]),
                                    common_misc:unicast2(PID, Unique, Module, Method, 
                                                         #m_activity_getgift_toc{succ=false, 
                                                                                 reason=?_LANG_ACTIVITY_SYSTEM_ERROR_WHEN_GET_PAY_FIRST_GIFT})
                            end
                    end
            end
    end.

t_get_accumulate_gift(RoleID, PayGold, GoodsInfo) ->
    [#r_pay_activity{accumulate_history=AccHistory, all_pay_gold=AllPayGold} = PayActivity] = db:read(?DB_PAY_ACTIVITY_P, RoleID, write),  
    case lists:keymember(PayGold, 1, AccHistory) of
        true ->
            db:abort(?_LANG_ACTIVITY_HAS_GET_WHEN_FETCH);
        false ->
            case AllPayGold >= PayGold of
                true ->                    
                    db:write(?DB_PAY_ACTIVITY_P, PayActivity#r_pay_activity{accumulate_history=[{PayGold, true}|AccHistory]}, write),
                    mod_bag:create_goods_by_p_goods(RoleID, GoodsInfo);
                false ->
                    db:abort(common_tool:to_binary(io_lib:format("你的累计充值尚未达到~p元宝，还需充值~p元宝", [PayGold, PayGold - AllPayGold])))
            end
    end.

%%@doc 玩家完成活动任务,只是增加勋章，设置完成次数
do_finish_task(RoleID,ActTaskID)->
    Today = date(),
    case db:dirty_read(?DB_ROLE_ACTIVITY_TASK,RoleID) of
        []->
            R2_Task = #r_role_activity_task{role_id=RoleID,act_task_list=[{ActTaskID,Today,1}]};
        [#r_role_activity_task{act_task_list=ActTaskList1}=R1_Task] ->
            case lists:keyfind(ActTaskID, 1, ActTaskList1) of
                {_,Today,OldFinishTimes}-> 
                    TaskList2 = lists:keystore(ActTaskID, 1, ActTaskList1, {ActTaskID,Today,OldFinishTimes+1}),
                    R2_Task = R1_Task#r_role_activity_task{act_task_list=TaskList2};
                _ ->
                    TaskList2 = lists:keystore(ActTaskID, 1, ActTaskList1, {ActTaskID,Today,1}),
                    R2_Task = R1_Task#r_role_activity_task{act_task_list=TaskList2}
            end
    end,
    db:dirty_write(?DB_ROLE_ACTIVITY_TASK,R2_Task),
    
    case lists:member(ActTaskID, ?BFN_ID_LIST) of
        true->
            do_finish_task_2(RoleID,ActTaskID,Today);
        _ ->
            ignore
    end.

%% 修改任务的福利数据
do_finish_task_2(RoleID,ActTaskID,Today)->
    case db:dirty_read(?DB_ROLE_ACTIVITY_BENEFIT,RoleID) of
        []->
            R2_bnft = #r_role_activity_benefit{role_id=RoleID,act_bnft_list=[{ActTaskID,Today}]},
            db:dirty_write(?DB_ROLE_ACTIVITY_BENEFIT,R2_bnft);
        [#r_role_activity_benefit{act_bnft_list=ActBnftList1}=R1_bnft] ->
            case lists:keyfind(ActTaskID, 1, ActBnftList1) of
                {_,Today}-> ignore;
                _ ->
                    ActBnftList2 = lists:keystore(ActTaskID, 1, ActBnftList1, {ActTaskID,Today}),
                    R2_bnft = R1_bnft#r_role_activity_benefit{act_bnft_list=ActBnftList2},
                    db:dirty_write(?DB_ROLE_ACTIVITY_BENEFIT,R2_bnft)
            end
    end.

%% ====================================================================
%% Internal functions
%% ====================================================================

%%@interface 显示日常活动
do_today({Unique, Module, Method, DataIn, RoleID, _PID, Line})->
    {ok, #p_role_attr{level=Level}}  = mod_map_role:get_role_attr(RoleID),
    {ok, #p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    
    %%所有级别都开放显示
    do_today_2({Unique, Module, Method, DataIn, RoleID, _PID, Line},Level,FamilyID).

do_today_2({Unique, Module, Method, DataIn, RoleID, _PID, Line},Level,FamilyID)->
    #m_activity_today_tos{type=TypeIn} = DataIn,
    %%获取玩家的符合条件的活动列表
    ActivityTodayList = common_config_dyn:list(activity_today),
    
    {ServerOpenDay,_} = common_config:get_open_day(),
    OpenDateTime = {ServerOpenDay,{0,0,0}},
    NowDateTime = {date(),{0,0,0}},
    
    {DiffDays, _Time} = calendar:time_difference( OpenDateTime,NowDateTime),
    MatchedList = lists:filter(fun(R)->
                                       #r_activity_today{need_level=NeedLevel,delay_days=DelayDays,types=Types} = R,
                                       if
                                           (TypeIn =:= 0) orelse (TypeIn=:=Types)->
                                               IsMatchType=true;
                                           true->
                                               IsMatchType = is_list(Types) andalso lists:member(TypeIn, Types)
                                       end,
                                       
                                       IsMatchType andalso  (Level+30)>=NeedLevel andalso (DelayDays=:=0 orelse DiffDays>=DelayDays)
                               end, ActivityTodayList),
    case db:dirty_read(?DB_ROLE_ACTIVITY_TASK,RoleID) of
        []->
            ActTaskList = [];
        [#r_role_activity_task{act_task_list=ActTaskList}] ->
            next
    end,
    ResList = [ update_activity_status(RoleID,Rec,Level,FamilyID,ActTaskList)||Rec<-MatchedList ],
    
    Rec2 = #m_activity_today_toc{succ=true, activity_list=ResList},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, Rec2).

%%更新活动的对应任务状态
update_activity_status(RoleID,Rec,Level,FamilyID,ActTaskList)
  when is_record(Rec,r_activity_today) ,is_list(ActTaskList)->
    #r_activity_today{id=ID,order_id=OrderID,need_level=NeedLevel,need_family=IsNeedFamily,
                      total_times=TotalTimes} = Rec,
    CheckLevel = (Level >= NeedLevel),
    CheckFamiliy = ( IsNeedFamily=/=true orelse FamilyID>0 ),
    if
        CheckLevel andalso CheckFamiliy->
            Status=1,
            DoneTimes = get_mission_donetimes(ID,RoleID,ActTaskList);
        true->
            Status=0,
            DoneTimes = 0
    end,
    #p_activity_info{id=ID,order_id=OrderID,type=?DEFAULT_ACTIVITY_TYPE,status=Status,done_times=DoneTimes,total_times=TotalTimes}.

%%@param ActTaskList是玩家今日已完成的任务列表
%% 个人副本、师徒副本要特殊处理，进去副本地图，就算参加过一次！
get_mission_donetimes(?ACTIVITY_TASK_PERSON_FB,RoleID,_)->
    {ok, RoleHeroFB} =  mod_hero_fb:get_role_hero_fb_info(RoleID),
    #p_role_hero_fb_info{today_count=TodayCount} = RoleHeroFB,
    TodayCount;
get_mission_donetimes(?ACTIVITY_TASK_EDUCATE_FB,RoleID,_)->
    case db:dirty_read(?DB_EDUCATE_FB,RoleID) of
        [#r_educate_fb{start_time = StartTime,times=Times}]->
            get_done_times_today(StartTime,Times);
        _ -> 0
    end;
get_mission_donetimes(_ID,_RoleID,[])->
    0;
get_mission_donetimes(ID,_RoleID,ActTaskList) when is_list(ActTaskList)->
    case lists:keyfind(ID, 1, ActTaskList) of
        {_,FinishDate,FinishTimes}->
            case FinishDate =:= date() of
                true-> FinishTimes;
                _ -> 0
            end;
        _ ->
            0
    end.


%%@doc 根据StartTime判断当天的参加活动次数
get_done_times_today(LastTime,TodayCount) when is_integer(LastTime) andalso TodayCount>0 ->
    get_done_times_today( common_tool:seconds_to_datetime(LastTime) ,TodayCount);
get_done_times_today({StartDate,_Time},TodayCount) when TodayCount>0 ->
    case StartDate =:= erlang:date() of
        true-> TodayCount;
        %%如果并非今天开始参加副本任务，则计数清零
        _ -> 0
    end;
get_done_times_today(_StartTime,_Times)->
    0.


%%@interface 显示今日的日常福利列表
do_benefit_list({Unique, Module, Method, _DataIn, RoleID, _PID, Line})->
    {ok, #p_role_attr{level=RoleLevel}}  = mod_map_role:get_role_attr(RoleID),
    case db:dirty_read(?DB_ROLE_ACTIVITY_BENEFIT,RoleID) of
        []->
            R2 = #m_activity_benefit_list_toc{succ=true,is_rewarded=false,act_task_list=[]};
        [#r_role_activity_benefit{reward_date=RewardDate,act_bnft_list=BnftList1}] ->
            Today = date(),
            IsAwarded = RewardDate =:= Today,
            case is_list(BnftList1) of
                true->
                    BnftList2 = get_today_benefit_list(BnftList1,Today);
                _ ->
                    BnftList2 = []
            end,
            {BaseExpSum,ExtraExpSum,_} = calc_all_rewards(BnftList2,RoleLevel),
            R2 = #m_activity_benefit_list_toc{succ=true,is_rewarded=IsAwarded,act_task_list=BnftList2,
                                              base_exp=BaseExpSum,extra_exp=ExtraExpSum}
    end,
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2).

%%@interface 日常福利的领奖
do_benefit_reward({Unique, Module, Method, _DataIn, RoleID, _PID, Line})->
    {ok, #p_role_attr{level=RoleLevel}}  = mod_map_role:get_role_attr(RoleID),
    case db:dirty_read(?DB_ROLE_ACTIVITY_BENEFIT,RoleID) of
        []->
            ?SEND_ERR_TOC(m_activity_benefit_reward_toc,?_LANG_ACTIVITY_JOIN_AND_GET_AWARD);
        [#r_role_activity_benefit{reward_date=RewardDate,act_bnft_list=BnftList1}] ->
            Today = date(),
            if
                RewardDate =:= Today->
                    ?SEND_ERR_TOC(m_activity_benefit_reward_toc,?_LANG_ACTIVITY_REWARD_ONETIME_PERDAY_ERR);
                true->
                    case get_today_benefit_list(BnftList1,Today) of
                        []-> 
                            ?SEND_ERR_TOC(m_activity_benefit_reward_toc,?_LANG_ACTIVITY_JOIN_AND_GET_AWARD);
                        BnftList2 ->
                            RewardsList = calc_all_rewards(BnftList2,RoleLevel),
                            do_benefit_reward_2(Unique, Module, Method, RoleID, Line, RewardsList )
                    end
            end
    end.

%%给玩家增加经验后的处理
do_after_exp_add(RoleID,ExpAdd,ExpAddResult) when is_integer(ExpAdd)->
    case ExpAddResult of
        {max_level_exp}->
            common_broadcast:bc_send_msg_role(RoleID, ?BC_MSG_TYPE_SYSTEM, ?_LANG_ACTIVITY_MAX_LEVEL_MAX_EXP_ADD_EXP),
            ignore;
        {exp_change, Exp} ->
            ExpChange = #p_role_attr_change{change_type=?ROLE_EXP_CHANGE, new_value=Exp},
            DataRecord = #m_role2_attr_change_toc{roleid=RoleID, changes=[ExpChange]},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord);
        
        {level_up, Level, RoleAttr, RoleBase} ->
            mod_map_role:do_after_level_up(Level, RoleAttr, RoleBase, ExpAdd, ?DEFAULT_UNIQUE, true)
    end.

is_max_level_exp(RoleID)->
    {ok,#p_role_attr{exp=CurExp,level=RoleLevel,next_level_exp=NextLevelExp}} = mod_map_role:get_role_attr(RoleID),
    MaxNextLevelExp = 3*to_integer(NextLevelExp),
    [MaxLevel] = common_config_dyn:find(etc,max_level),
    (RoleLevel>=MaxLevel) andalso (CurExp >= MaxNextLevelExp).

do_benefit_reward_2(Unique, Module, Method, RoleID, Line, {BaseExpSum,ExtraExpSum,ExtraItemList})->
    ExpAdd = (BaseExpSum+ExtraExpSum),
    TransFun = fun() -> 
                       {ok,TaskCount,BuyCount} = t_benefit_reward(RoleID),
                       {ok,AddGoodsList} = t_add_item(RoleID,[],ExtraItemList),
                       ExpAddResult = case is_max_level_exp(RoleID) of
                                          true->
                                              {max_level_exp};
                                          _ ->
                                              mod_map_role:t_add_exp(RoleID, ExpAdd, ?EXP_ADD_TYPE_NORMAL)
                                      end,
                       {ok,AddGoodsList,TaskCount,BuyCount,ExpAddResult}
               end,
    case db:transaction( TransFun ) of
        {atomic, {ok,AddGoodsList,TaskCount,BuyCount,ExpAddResult}} ->
            %% 增加经验后的处理
            do_after_exp_add(RoleID,ExpAdd,ExpAddResult),
            
            lists:foreach(fun(RewardItem)-> 
                                  #r_item_reward{item_type_id=ItemTypeID,item_num=ItemNum,is_bind=IsBind} = RewardItem,
                                  common_item_logger:log(RoleID, ItemTypeID,ItemNum,IsBind,?LOG_ITEM_TYPE_ACTIVITY_BENEFIT_AWARD)
                          end,ExtraItemList),
            common_misc:update_goods_notify({role, RoleID}, AddGoodsList),
            
           
            R = #m_activity_benefit_reward_toc{succ=true},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R),
            [IsMinBcCompleteNumber] = common_config_dyn:find(activity_reward,is_min_bc_complete_number),
            case TaskCount > IsMinBcCompleteNumber of
                true ->
                    broadcast_world_reward(RoleID,TaskCount);
                false ->
                    ignore
            end,            
            Now = common_tool:now(),
            Log = #r_act_benefit_log{role_id=RoleID,reward_date=date_to_int(),reward_time=Now,task_num=TaskCount,buy_num=BuyCount},
            
            common_general_log_server:log_act_benefit(Log),
            ok;
        {aborted, ?_LANG_ROLE2_ADD_EXP_EXP_FULL} ->
            DataRecord = #m_role2_exp_full_toc{text=?_LANG_ROLE2_ADD_EXP_EXP_FULL},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_EXP_FULL, DataRecord),
            ?SEND_ERR_TOC(m_activity_benefit_reward_toc,?_LANG_ROLE2_ADD_EXP_EXP_FULL);
        {aborted, {bag_error,not_enough_pos}} ->
            ?SEND_ERR_TOC(m_activity_benefit_reward_toc,?_LANG_DROPTHING_BAG_FULL);
        {aborted, {throw, {bag_error, not_enough_pos}}} ->
            ?SEND_ERR_TOC(m_activity_benefit_reward_toc,?_LANG_DROPTHING_BAG_FULL);
        {aborted, {throw, Reason}}when is_binary(Reason) ->
            ?SEND_ERR_TOC(m_activity_benefit_reward_toc,Reason);
        {aborted, Error} when is_binary(Error) ->
            ?SEND_ERR_TOC(m_activity_benefit_reward_toc,Error);
        {aborted, Error} ->
            ?ERROR_MSG_STACK("do_benefit_reward Error",Error),
            ?SEND_ERR_TOC(m_activity_benefit_reward_toc,?_LANG_SYSTEM_ERROR)
    end.   


date_to_int()->
    {Y,M,D} = date(),
    Y*10000 + M*100 +D.

broadcast_world_reward(RoleID,TaskCount)->
    {ok,#p_role_base{faction_id=FactionID,role_name=RoleName}} = mod_map_role:get_role_base(RoleID),
    FactionName = common_misc:get_faction_color_name(FactionID),
    Content = common_misc:format_lang(?_LANG_ACTIVITY_BENEFIT_REWARD_BROADCAST,
                [FactionName,RoleName,TaskCount] ),
    common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_CHAT], ?BC_MSG_TYPE_CHAT_WORLD, Content).
    
t_benefit_reward(RoleID)->
    [#r_role_activity_benefit{act_bnft_list=List1,buy_count=BuyCount1,buy_date=BuyDate} = R1] = db:read(?DB_ROLE_ACTIVITY_BENEFIT,RoleID),
    Today = date(),
    List2 = lists:filter(fun({_ID,FinishDate})->
                                 FinishDate =:= Today
                         end, List1),
    R2 = R1#r_role_activity_benefit{reward_date=Today,act_bnft_list=List2},
    ok = db:write(?DB_ROLE_ACTIVITY_BENEFIT,R2,write),
    TaskCount = length(List2),
    BuyCount = case BuyDate=:=Today of
                   true-> BuyCount1;
                   _ -> 0
               end,
    {ok,TaskCount,BuyCount}.
  

%%@doc 给予道具
%%@return {ok,GoodsList}
t_add_item(_RoleID,GoodsList,[])->
    {ok,GoodsList};
t_add_item(RoleID,GoodsList,[RewardItem|T])->
    #r_item_reward{type=Type,item_type_id=ItemTypeID,item_num=Num,is_bind=IsBind} = RewardItem,
    CreateInfo = #r_goods_create_info{bind=IsBind,type=Type, type_id=ItemTypeID, start_time=0, end_time=0, 
                                      num=Num, color=?COLOUR_WHITE,quality=?QUALITY_GENERAL,
                                      punch_num=0,interface_type=present},
    {ok,NewGoodsList} = mod_bag:create_goods(RoleID,CreateInfo),
    t_add_item(RoleID, lists:concat([NewGoodsList,GoodsList]) ,T).
    
  
    
%%计算对应的所有奖励
calc_all_rewards([],_)->
    {0,0,[]};
calc_all_rewards(BnftList2,RoleLevel)->
    Size1 = length(BnftList2),
    [BaseRewardsList] = common_config_dyn:find(activity_reward,base_rewards),
    [ExtraRewardsList] = common_config_dyn:find(activity_reward,extra_rewards),
    BaseExpSum = lists:foldl(fun(TaskID,Acc)-> 
                                     case lists:keyfind(TaskID, #r_activity_base_reward.id, BaseRewardsList) of
                                         false-> Acc;
                                         #r_activity_base_reward{exp_plus=ExpPlus,exp_mult=ExpMult}->
                                             Acc+ (ExpMult*RoleLevel+ExpPlus)
                                     end
                             end, 0, BnftList2),
    MaxListSize = length(ExtraRewardsList),
    Size = case Size1>MaxListSize of
               true->
                   MaxListSize;
               _ ->
                   Size1
           end,
    {ExtraExpSum,ExtraItemList} = case lists:keyfind(Size, #r_activity_extra_reward.count, ExtraRewardsList) of
                                      false-> {0,[]};
                                      #r_activity_extra_reward{exp_plus=ExpPlus2,exp_mult=ExpMult2,reward_item_list=ItemList}->
                                          Rwd = (ExpMult2*RoleLevel+ExpPlus2),
                                          {Rwd,ItemList}
                                  end,
    {BaseExpSum,ExtraExpSum,ExtraItemList}.
                            
    

%%@return  list() [ActTaskId]
get_today_benefit_list(BnftList1,Today)->
    lists:foldl(fun(E,Acc)->
                        case E of
                            {ActTaskID,Today}->
                                [ActTaskID|Acc];
                            _ ->
                                Acc
                        end
                end, [], BnftList1).

%%@interface 处理购买活跃度 
do_benefit_buy({Unique, Module, Method, DataIn, RoleID, _PID, Line})->
    #m_activity_benefit_buy_tos{act_task_id=ActTaskID} = DataIn,
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    IsRewared = check_is_rewared(RoleID),
    if
        IsRewared ->
            ?SEND_ERR_TOC(m_activity_benefit_buy_toc,?_LANG_ACTIVITY_HAS_AWARD_ITEM_NOT_BUY);
        true->
            TransFun = fun() -> t_actpoint_buy(RoleID, RoleAttr,ActTaskID)  end,
            case db:transaction( TransFun )
                of
                {atomic, {ok,RoleAttr2}} ->
                    send_gold_change(RoleID,[gold],RoleAttr2),
                    
                    R = #m_activity_benefit_buy_toc{succ=true,act_task_id=ActTaskID},
                    common_misc:unicast(Line, RoleID, Unique, Module, Method, R);
                {aborted, Reason} when is_binary(Reason) ->
                    ?SEND_ERR_TOC(m_activity_benefit_buy_toc,Reason);
                {aborted, Error} ->
                    ?ERROR_MSG_STACK("BagError,Error=~w",[Error]),
                    ?SEND_ERR_TOC(m_activity_benefit_buy_toc,?_LANG_SYSTEM_ERROR)
            end
    end.

get_all_taskid_list()->
    [BaseRewardsList] = common_config_dyn:find(activity_reward,base_rewards),
    [ ID ||#r_activity_base_reward{id=ID}<-BaseRewardsList].

t_actpoint_buy(RoleID, RoleAttr,ActTaskID) when ActTaskID>=0 ->
    #p_role_attr{gold=Gold} = RoleAttr,
    AllTaskIDList = get_all_taskid_list(),
    
    
    DeductGold = case ActTaskID>0 of
                     true->
                         3; %%3元宝
                     _ ->
                         t_get_deduct_gold_for_tasklist(RoleID,AllTaskIDList)
                 end,
    
    case Gold < DeductGold of
        true ->
            db:abort(?_LANG_TRAINING_NOT_ENOUGH_GOLD);
        _ ->
            RestGold = Gold - DeductGold,
            common_consume_logger:use_gold({RoleID, 0, DeductGold, ?CONSUME_TYPE_GOLD_ACTIVITY_BENEFIT_BUY,""}),
            
            RoleAttr2 = RoleAttr#p_role_attr{gold=RestGold},
            mod_map_role:set_role_attr(RoleID, RoleAttr2),
            
            case ActTaskID==0 of
                true->
                    t_finish_activity_benefit(RoleID,AllTaskIDList);
                _ ->
                    t_finish_activity_benefit(RoleID,ActTaskID)
            end,
            {ok,RoleAttr2}
    end.

t_get_deduct_gold_for_tasklist(RoleID,AllTaskIDList) when is_list(AllTaskIDList)->
    Count = length(AllTaskIDList),
    case db:read(?DB_ROLE_ACTIVITY_BENEFIT,RoleID) of
        []->
            Count*3;
        [#r_role_activity_benefit{act_bnft_list=List1}] ->
            Today = date(),
            List2 = lists:filter(fun({_ID,FinishDate})->
                                         FinishDate =:= Today
                                 end, List1),
            (Count-length(List2))*3
    end.

to_integer(Num) when is_integer(Num)->
    Num;
to_integer(_Num)->
    0.

t_finish_activity_benefit(RoleID,AllTaskIDList) when is_list(AllTaskIDList)->
    Today = date(),
    List2 = [ {TaskID,Today} ||TaskID<-AllTaskIDList],
    case db:read(?DB_ROLE_ACTIVITY_BENEFIT,RoleID) of
        []->
            Cnt = length(List2),
            R2 = #r_role_activity_benefit{role_id=RoleID,buy_date=Today,buy_count=Cnt,act_bnft_list=List2};
        [#r_role_activity_benefit{buy_date=OldBuyDate,buy_count=OldBuyCount}=R1] ->
            case OldBuyDate of
                Today->
                    Cnt = length(List2),
                    R2 = R1#r_role_activity_benefit{act_bnft_list=List2,buy_date=Today,buy_count=Cnt};
                _ ->
                    Cnt = length(List2) - to_integer(OldBuyCount),
                    R2 = R1#r_role_activity_benefit{act_bnft_list=List2,buy_date=Today,buy_count=Cnt}
            end
    end,
    db:write(?DB_ROLE_ACTIVITY_BENEFIT,R2,write);
t_finish_activity_benefit(RoleID,ActTaskID) when is_integer(ActTaskID)->
    Today = date(),
    case db:read(?DB_ROLE_ACTIVITY_BENEFIT,RoleID) of
        []->
            R2 = #r_role_activity_benefit{role_id=RoleID,buy_date=Today,buy_count=1,act_bnft_list=[{ActTaskID,Today}]};
        [#r_role_activity_benefit{act_bnft_list=ActBnftList1,buy_date=OldBuyDate,buy_count=OldBuyCount}=R1] ->
            List2 = lists:keystore(ActTaskID, 1, ActBnftList1, {ActTaskID,Today}),
            case OldBuyDate of
                Today->
                    Cnt = to_integer(OldBuyCount)+1,
                    R2 = R1#r_role_activity_benefit{act_bnft_list=List2,buy_date=Today,buy_count=Cnt};
                _ ->
                    Cnt = to_integer(OldBuyCount)+1,
                    R2 = R1#r_role_activity_benefit{act_bnft_list=List2,buy_date=Today,buy_count=Cnt}
            end
    end,
    db:write(?DB_ROLE_ACTIVITY_BENEFIT,R2,write).

check_is_rewared(RoleID)->
    Today = date(),
    case db:dirty_read(?DB_ROLE_ACTIVITY_BENEFIT,RoleID) of
        [#r_role_activity_benefit{reward_date=Today}] ->
            true;
        _->
            false
    end.

%%@doc 通知元宝的变化
send_gold_change(_RoleID,[],_RoleAttr)->
    ignore;
send_gold_change(RoleID,GoldChangeList,RoleAttr) when is_list(GoldChangeList)->
    #p_role_attr{gold=Gold,gold_bind=GoldBind} = RoleAttr,
    ChangeAttList = lists:foldl(fun(GoldChange,AccIn)->
                                        case GoldChange of     
                                            gold_bind->
                                                [#p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE,new_value=GoldBind}|AccIn ];
                                            gold->
                                                [#p_role_attr_change{change_type=?ROLE_GOLD_CHANGE,new_value=Gold}|AccIn ]
                                        end
                                end,[],GoldChangeList),
    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttList).



