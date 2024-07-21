-module(mod_warofcity).

-include("mgeem.hrl").

%% API
-export([
         handle/1
        ]).

%%只能由mgeem_map直接或者间接调用
-export([
         is_in_safetime/0,
         add_mark/2,
         loop_check/0,
         break/1,
         is_in_wartime/0,
         init/0,
         is_war_map/0
        ]).

-define(WAROFCITY_WARTIME_FLAG, warofcity_wartime_flag).

-define(warofcity_allow_family_list, warofcity_allow_family_list).

-define(warofcity_safetime_flag, warofcity_safetime_flag).

-define(warofking_join_role_list, warofking_join_role_list).

-define(family_base_list, family_base_list).

-define(family_mark_list, family_mark_list).

-define(role_mark_list, role_mark_list).

-define(warofcity_flag, warofcity_flag).

-define(warofcity_flag_holding_family, warofcity_flag_holding_family).

-define(WAROFCITY_WINNER_ADD_AC, 10).

-define(WAROFCITY_JOIN_ADD_AC, 5).

%% 读条10秒钟
-define(WAROFCITY_HOLD_TIME, 10).

%% 占领图腾后积分倍数
-define(WAROFCITY_BASE, 2).

-define(warofcity_cityid, warofcity_cityid).

-define(warofcity_hold_time, warofcity_hold_time).


is_war_map() ->
    MapID = mgeem_map:get_mapid(),
    MapID =:= 10301.


init() ->
    set_in_wartime(false),
    init_safetime_flag(),
    ok.

%% 增加积分:个人积分以及门派积分
add_mark(RoleID, FamilyID) ->
    case get_hold_familyid() =:= FamilyID of
        true ->
            Mark = ?WAROFCITY_BASE;
        false ->
            Mark = 1
    end,
    add_role_mark(RoleID, Mark),
    add_family_mark(FamilyID, Mark).

%%判断是否处在地图争夺战中
is_in_wartime() ->
    get_in_wartime() andalso not get_safetime_flag().

%%判断是否能够战斗
is_in_safetime() ->
    get_in_wartime() andalso get_safetime_flag().


%% 有一系列的行为都可以会触发中断占领图腾
break(RoleID) ->
    case get_in_wartime() of
        true ->
            case info_hold() of
                {RoleID, _Time} ->
                    {ok, #p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
                    break_hold(FamilyID);
                _ ->
                    ignore
            end;
        _ ->
            ignore
    end.
    

%%每秒检查一次是否有人占领图腾的时间到了
loop_check() ->
    case get_in_wartime() of
        true ->
            case info_hold() of
                {RoleID, Time} ->
                    NewTime = Time + 1,
                    %%成功占领该图腾，门派积分基数变化
                    {ok, #p_role_base{family_id=FamilyID, 
                                  family_name=FamilyName, 
                                  role_name=RoleName}} = mod_map_role:get_role_base(RoleID),
                    case NewTime >= ?WAROFCITY_HOLD_TIME of
                        true ->
                            
                            case FamilyID > 0 of
                                true ->
                                    succ_hold(FamilyID, FamilyName, RoleName);
                                false ->
                                    break_hold_no_family()
                            end;
                        false ->
                            update_hold(RoleID,FamilyID,  NewTime, false)
                    end;
                _ ->
                    ignore
            end;
        fasle ->
            ignore
    end.

%%------------------------------------------------------------------
%%外部消息处理
%%------------------------------------------------------------------
handle(Info) ->
    do_handle_info(Info).

do_handle_info({Unique, Module, Method, Record, RoleID, PID, Line}) ->
    case Method of
        ?WAROFCITY_APPLY ->
            do_apply(Unique, Module, Method, Record, RoleID, Line);
        ?WAROFCITY_AGREE_ENTER ->
            do_agree_enter(Unique, Module, Method, Record, RoleID, Line);
        ?WAROFCITY_HOLD ->
            do_hold(Unique, Module, Method, Record, RoleID, Line);
        ?WAROFCITY_GET_MARK ->
            do_get_mark(Unique, Module, Method, Record, RoleID, PID, Line);
        ?WAROFCITY_PANEL ->
            do_panel(Unique, Module, Method, Record, RoleID, PID, Line);
        ?WAROFCITY_GET_REWARD ->
            do_get_reward(Unique, Module, Method, Record, RoleID, PID)
    end;
do_handle_info({agree_enter, RoleID, FamilyID}) ->
    do_redirect_agree_enter(RoleID, FamilyID);

do_handle_info(clear_city) ->
    clear_city();

%%这里消息由mgeew_event来触发
do_handle_info({begin_collect, CityID}) ->
    do_begin_collect(CityID);
do_handle_info(begin_war) ->
    do_begin_war();
do_handle_info(end_war) ->
    do_end_war();
do_handle_info({apply_func, F}) ->
    do_apply_func(F);
do_handle_info(Info) ->
    ?ERROR_MSG("~ts:~w", ["未知的消息", Info]).

%%------------------------------------------------------------------
%% 内部函数
%%------------------------------------------------------------------


%% 领取连续占领奖励
do_get_reward(Unique, Module, Method, Record, RoleID, PID) ->
    %% 领奖只能在当前地图领奖
    #m_warofcity_get_reward_toc{type=Type} = Record,
    MapID = mgeem_map:get_mapid(),
    case db:transaction(fun() -> t_get_reward(RoleID, MapID, Type) end) of
        {atomic, GoodsInfo} ->
            common_misc:update_goods_notify({role, RoleID}, GoodsInfo),
            R = #m_warofcity_get_reward_toc{type=Type},
            common_misc:unicast2(PID, Unique, Module, Method, R),
            ok;
        {aborted, Error} ->
            case erlang:is_binary(Error) of
                true ->
                    Reason = Error,
                    ok;
                false ->
                    ?ERROR_MSG("~ts:~w", ["检查门派是否能够领取连续占领奖励时出错", Error]),
                    Reason = ?_LANG_WAROFCITY_SYSTEM_ERROR_WHEN_GET_REWARD
            end,
            do_get_reward_error(Unique, Module, Method, Reason, PID)
    end,
    %% 检查
    %% 判断是否已经领奖
    ok.

t_get_reward(RoleID, MapID, Type) ->
    {ok, #p_role_base{family_id=FID}} = mod_map_role:get_role_base(RoleID),
    case FID > 0 of
        true ->
            ok;
        false ->
            db:abort(?_LANG_WAROFCITY_NO_RIGHT_TO_GET_REWARD)
    end,
    %% 只有掌门有权利领取奖励
    [#p_family_info{owner_role_id=ORoleID}] = db:read(?DB_FAMILY, FID, write),
    case ORoleID =:= RoleID of
        true ->
            ok;
        false ->
            db:abort(?_LANG_WAROFCITY_ONLY_OWNER_CAN_GET_REWARD)
    end,
    [#p_warofcity{last_day=LastDay, gained_rewards=GainedRewards} = WarOFCity] = db:read(?DB_WAROFCITY, MapID),
    %% 判断是否能够领奖
    NeedDay = get_need_day_of_reward(Type),
    case LastDay >= NeedDay of
        true ->
            ok;
        false ->
            db:abort(?_LANG_WAROFCITY_NOT_REACH_CONDITION_OF_GET_REWARD)
    end,    
    %% 判断是否已经领取了
    case lists:member(Type, GainedRewards) of
        true ->
            db:abort(?_LANG_WAROFCITY_ALREADY_GET_REWARD_OF_THIS_TYPE)
    end,
    %% 发送奖励
    ItemID = config_warofcity:get_reward_id(common_map:get_second_id(MapID), NeedDay),
    CreateInfo = #r_goods_create_info{type=?TYPE_ITEM,type_id=ItemID,num=1,bind=true,start_time=0,end_time=0},
    {ok,[Goods]} = mod_bag:create_goods(RoleID,CreateInfo),
    %% 记录该奖励已经领取
    db:write(?DB_WAROFCITY, WarOFCity#p_warofcity{gained_rewards=[Type | GainedRewards]}, write),
    Goods.
    

%% 获取对应类型的奖励需要多少天
get_need_day_of_reward(1) ->
    7;
get_need_day_of_reward(2) ->
    14;
get_need_day_of_reward(3) ->
    21;
get_need_day_of_reward(4) ->
    28;
get_need_day_of_reward(8) ->
    56;
get_need_day_of_reward(_) ->
    throw({error, wrong_reward_type}).


do_get_reward_error(Unique, Module, Method, Reason, PID) ->
    R = #m_warofcity_get_reward_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, R).
    
    
do_panel(Unique, Module, Method, _, _RoleID, PID, _Line) ->
    MapID = mgeem_map:get_mapid(),
    Result = db:dirty_read(?DB_WAROFCITY, MapID),
    R = #m_warofcity_panel_toc{cities=Result},
    common_misc:unicast2(PID, Unique, Module, Method, R).
    

%%清理掉地图里面的所有人，全部传送出去
clear_city() ->
    L = mod_map_actor:get_in_map_role(),
    {MapID, TX, TY} = get_back_city_pos(),
    lists:foreach(
      fun(RoleID) ->
              R = #m_map_change_map_toc{mapid=MapID, tx=TX, ty=TY},
              common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?MAP, ?MAP_CHANGE_MAP, R),
              mod_map_role:do_change_map(RoleID, MapID, TX, TY, common)
      end, L),
    ok.


get_back_city_pos() ->
    MapID = get_city_id(),
    common_misc:get_born_info_by_map(MapID).    

get_city_id() ->
    erlang:get(?warofcity_cityid).

set_city_id(CityID) ->
    erlang:put(?warofcity_cityid, CityID),
    ok.

do_apply_func(F) ->
    F().


%%获取当前积分情况
do_get_mark(Unique, Module, Method, _Record, RoleID, PID, Line) ->
    %% 判断战斗是否已经开始
    case is_in_wartime() of
        true ->
            FamilyMarkList = get_family_mark_list(),
            RoleMarkList = get_role_mark_list(),
            R = #m_warofcity_get_mark_toc{families=FamilyMarkList, roles=RoleMarkList},
            common_misc:unicast2(PID, Unique, Module, Method, R),
            ok;
        false ->
            do_get_mark_error(Unique, Module, Method, ?_LANG_WAROFCITY_NOT_BEGIN_OR_IN_SAFETIME, RoleID, Line)
    end.

do_get_mark_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_warofcity_get_mark_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

%%占领图腾
do_hold(Unique, Module, Method, _Record, RoleID, Line) ->
    %%#m_warofcity_hold_tos{} = Record,
    {ok, #p_role_base{family_name=FamilyName, family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    case catch do_hold_check(RoleID, FamilyID) of
        ok ->
            
            R = #m_warofcity_hold_toc{},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R),
            RB = #m_warofcity_hold_toc{return_self=false, role_id=RoleID, family_name=FamilyName},
            mgeem_map:broadcast_to_whole_map(?WAROFCITY, ?WAROFCITY_HOLD, RB),
            ok;
        {error, Reason} ->
            do_hold_error(Unique, Module, Method, Reason, RoleID, Line);
        {'EXIT', Error} ->
            ?ERROR_MSG("~ts:~w", ["占领图腾判断处理出错", Error]),
            do_hold_error(Unique, Module, Method, ?_LANG_WAROFCITY_HOLD_SYSTEM_ERROR, RoleID, Line)
    end.


do_hold_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_warofcity_hold_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).


do_hold_check(RoleID, FamilyID) ->
    case is_holding() of
        false ->
            begin_hold(RoleID, FamilyID);
        true ->
            throw({error, ?_LANG_WAROFCITY_FLAG_ALREADY_HOLD})
    end,
    ok.


%%收到消息，开始发送征集令
do_begin_collect(CityID) ->
    case get_in_wartime() of
        true ->
            ignore;
        false ->
            do_begin_collect2(CityID) 
    end.

do_begin_collect2(CityID) ->
    set_city_id(CityID),
    %%清理掉上次争夺战留下的信息
    clear_join_role(),
    %%一旦开始征集，那么不再允许报名，可以传送进来
    set_in_wartime(true),
    set_safetime_flag(true),
    %% 初始化允许参战的门派列表,[]
    init_allow_family(),
    %%判断是否需要发征集令：1 没有门派报名，则不需要 2 如果只有一个门派报名，且之前没有门派占领，则直接占领，无需征集
    MapID = mgeem_map:get_mapid(),
    [#p_warofcity{apply_family_list=ApplyFamilyList, family_id=FamilyID, family_name=FamilyName}] = db:dirty_read(?DB_WAROFCITY, MapID),
    case ApplyFamilyList =:= [] of
        true ->
            %% 广播给本地图
            end_war_without_fight(),
            ok;
        false ->
            %% 判断当前是否有人已经占领了本地图
            case FamilyID =:= 0 of
                true ->
                    case erlang:length(ApplyFamilyList) =:= 1 of
                        true ->
                            %%不用打了，直接占领地图了
                            do_set_city_owner(erlang:hd(ApplyFamilyList));
                        false ->
                            do_begin_collect3(ApplyFamilyList, FamilyID, FamilyName, MapID)
                    end;
                false ->               
                    do_begin_collect3(ApplyFamilyList, FamilyID, FamilyName, MapID)
            end
    end.

do_begin_collect3(ApplyFamilyList, FamilyID, FamilyName, MapID) ->
    %%发征集令给所有的参战门派的组员    
    [FamilyIDList2, RoleIDNameList2] = lists:foldl(
                                         fun({FID, FName}, [AccFID, AccRID]) ->
                                                 record_allow_family(FID),
                                                 RIDList = broadcast_collect(FID, FName, MapID),
                                                 FMark = #p_warofcity_family_mark{family_id=FID,
                                                                                  family_name=FName,
                                                                                  marks=0},
                                                 [[FMark | AccFID], lists:append(RIDList, AccRID)]
                                         end, [[], []], ApplyFamilyList),
    %% 判断当前地图是否有门派占领过了
    case FamilyID > 0 of
        true ->
            record_allow_family(FamilyID),
            RoleIDNameList = broadcast_collect(FamilyID, FamilyName, MapID),
            FamilyMark = #p_warofcity_family_mark{family_id=FamilyID, family_name=FamilyName,
                                                  marks=0},
            FamilyIDList3 = [FamilyMark | FamilyIDList2];
        false ->
            FamilyIDList3 = FamilyIDList2,
            RoleIDNameList = []
    end,
    RoleIDNameList3 = lists:append(RoleIDNameList, RoleIDNameList2),
    %%初始化玩家的个人积分
    init_role_mark(RoleIDNameList3),
    %% 初始化门派的积分
    init_family_mark(FamilyIDList3).


%% 广播征集令给某个门派的所有成员
broadcast_collect(FamilyID, FamilyName, MapID) ->
    [#p_family_info{members=M}] = db:dirty_read(?DB_FAMILY, FamilyID), 
    {RoleIDList, RoleIDNameList} = lists:foldl(
                                     fun(#p_family_member_info{role_id=RoleID, role_name=RoleName}, {RIDAcc, RIDNameAcc}) ->
                                             RoleMark = #p_warofcity_role_mark{role_id=RoleID,
                                                                               role_name=RoleName,
                                                                               family_id=FamilyID, 
                                                                               family_name=FamilyName,
                                                                               marks=0},
                                             {[RoleID | RIDAcc], [RoleMark | RIDNameAcc]}
                                     end, {[], []}, M),
    R = #m_warofcity_collect_toc{map_id=MapID},
    mgeem_map:broadcast(RoleIDList, ?WAROFCITY, ?WAROFCITY_COLLECT, R),
    RoleIDNameList.


%% 记录允许那些门派的成员进入战场
init_allow_family() ->
    erlang:put(?warofcity_allow_family_list, []).
record_allow_family(FamilyID) ->
    erlang:put(?warofcity_allow_family_list, [FamilyID | get_allow_family()]).
get_allow_family() ->
    erlang:get(?warofcity_allow_family_list).


%% 没有门派参与争夺
end_war_without_fight() ->
    MapID = mgeem_map:get_mapid(),
    %%添加一天的占领时间
    [#p_warofcity{family_id=OldFamilyID, last_day=LastDay} = City] = db:dirty_read(?DB_WAROFCITY, MapID),
    case OldFamilyID > 0 of
        true ->
            NewDay = LastDay + 1,
            db:dirty_write(?DB_WAROFCITY, City#p_warofcity{last_day=NewDay});
        false ->
            ignore
    end.


%%mgeew_event通知地图争夺战时间到了，该结束了
do_end_war() ->
    case get_in_wartime() of
        true ->
            do_end_war2();
        false ->
            ignore
    end.

do_end_war2() ->
    FamilyTopMarkList = get_top_mark_family_list(),
    RoleTopMarkList = get_top_mark_role_list(),
    %%只要能打起来，至少会有两个门派
    #p_warofcity_family_mark{family_id=FirstFID} = lists:sublist(FamilyTopMarkList, 1, 1),
    #p_warofcity_family_mark{family_id=SecondFID} = lists:sublist(FamilyTopMarkList, 2, 1),
    Third = lists:sublist(FamilyTopMarkList, 3, 1),
    [#p_family_info{family_name=FirstFamilyName}] = db:dirty_read(?DB_FAMILY, FirstFID),
    [#p_family_info{family_name=SecFamilyName}] = db:dirty_read(?DB_FAMILY, SecondFID),
    FirstFamily = #p_warofcity_family_winner{family_id=FirstFID, family_name=FirstFamilyName},
    SecFamily = #p_warofcity_family_winner{family_id=SecondFID, family_name=SecFamilyName},
    case Third of 
        [] ->
            Third2 = undefined;
        #p_warofcity_family_mark{family_id=TrdFamilyID, family_name=TrdFamilyName} ->
            Third2 = #p_warofcity_family_winner{family_id=TrdFamilyID, family_name=TrdFamilyName}
    end,    
    #p_warofcity_role_mark{role_id=FirstRoleID, 
                           role_name=FirstRoleName, 
                           family_id=FirstRoleFamilyID} = lists:sublist(RoleTopMarkList, 1, 1),
    #p_warofcity_role_mark{role_id=SecRoleID, 
                           role_name=SecRoleName, 
                           family_id=SecRoleFamilyID} = lists:sublist(RoleTopMarkList, 2, 1),
    ThirdRole = lists:sublist(RoleTopMarkList, 3, 1),
    FirstRole = #p_warofcity_role_winner{role_id=FirstRoleID, role_name=FirstRoleName},
    SecRole = #p_warofcity_role_winner{role_id=SecRoleID, role_name=SecRoleName},
    case ThirdRole of
        [] ->
            TrdRoleFamilyID = 0,
            ThirdRole2 = undefined;
        #p_warofcity_role_mark{role_id=TrdRoleID, role_name=TrdRoleName, family_id=TrdRoleFamilyID} ->
            ThirdRole2 = #p_warofcity_role_winner{role_id=TrdRoleID, role_name=TrdRoleName}
    end,
    MapID = mgeem_map:get_mapid(),
    %%发放奖励
    [#p_warofcity{sum_apply_cost=SumCost}] = db:dirty_read(?DB_WAROFCITY, MapID),
    common_family:info(FirstFID, {add_money_when_first_of_warofcity, common_tool:ceil(0.5 * SumCost)}),
    common_family:info(FirstFID, {add_ac_when_first_of_warofcity, ?WAROFCITY_WINNER_ADD_AC}),
    common_family:info(SecondFID, {add_money_when_sec_of_warofcity, common_tool:ceil(0.3 * SumCost)}),
    common_family:info(SecondFID, {add_money_when_sec_of_warofcity, ?WAROFCITY_WINNER_ADD_AC}),
    case Third of
        [] ->
            ignore;
        {TrdFID, _, _} ->     
            
            common_family:info(TrdFID, {add_money_when_third_of_warofcity, common_tool:ceil(0.1 * SumCost)}),
            common_family:info(TrdFID, {add_ac_when_third_of_warofcity, ?WAROFCITY_WINNER_ADD_AC})
    end,
    %%发放参与奖
    RemainFamilyList = lists:sublist(FamilyTopMarkList, 4, erlang:length(FamilyTopMarkList)),
    lists:foreach(
      fun(FID) ->
              common_family:info(FID, {add_ac_when_join_warofcity, ?WAROFCITY_JOIN_ADD_AC})
      end, RemainFamilyList),
    %% 发放个人奖励
    common_family:info(FirstRoleFamilyID, {add_contribution, FirstRoleID, 100}),
    common_family:info(SecRoleFamilyID, {add_contribution, SecRoleID, 80}),
    case ThirdRole2 of
        undefined ->
            ignore;
        _ ->
            common_family:info(TrdRoleFamilyID, {add_contribution, ThirdRole2, 60})
    end,
    %% 发放个人参与奖
    lists:foreach(
      fun(RID) ->
              {ok, #p_role_base{family_id=RoleFID}} = mod_map_role:get_role_baes(RID),
              common_family:info(RoleFID, {add_contribution, RID, 30})
      end, lists:sublist(RoleTopMarkList, 4, erlang:length(RoleTopMarkList))),
    
    %% 整个地图广播结果
    R = #m_warofcity_end_toc{first=FirstFamily, second=SecFamily, third=Third2,
                             first_role=FirstRole, second_role=SecRole,
                             third_role=ThirdRole2},
    mgeem_map:broadcast_to_whole_map(?WAROFCITY, ?WAROFCITY_END, R),
    do_set_city_owner({FirstFID, FirstFamilyName}),
    send_clear_city_info(),
    ok.


send_clear_city_info() ->
    erlang:send(self(), {?MODULE, clear_city}).


do_set_city_owner({FamilyID, FamilyName}) ->
    MapID = mgeem_map:get_mapid(),
    %% 这种情况下，只需要给门派发奖励
    [#p_warofcity{sum_apply_cost=SumCost}] = db:dirty_read(?DB_WAROFCITY, MapID),
    common_family:info(FamilyID, {add_money_when_first_of_warofcity, common_tool:ceil(0.5 * SumCost)}),
    common_family:info(FamilyID, {add_ac_when_first_of_warofcity, ?WAROFCITY_WINNER_ADD_AC}),
    %% 需要判断连续占领的情况
    MapID = mgeem_map:get_mapid(),
    [#p_warofcity{family_id=OldFamilyID, last_day=LastDay} = City] = db:dirty_read(?DB_WAROFCITY, MapID),
    case OldFamilyID =:= FamilyID of
        true ->
            NewDay = LastDay + 1,
            db:dirty_write(?DB_WAROFCITY, City#p_warofcity{family_id=FamilyID, 
                                                           family_name=FamilyName,
                                                           apply_family_list=[],
                                                           last_day=NewDay,
                                                           sum_apply_cost=0});
        false ->
            db:dirty_write(?DB_WAROFCITY, City#p_warofcity{family_id=FamilyID, 
                                                           family_name=FamilyName,
                                                           apply_family_list=[],
                                                           last_day=1,
                                                           sum_apply_cost=0})
    end.


get_top_mark_family_list() ->
    L = erlang:get(?family_mark_list),
    L2 = lists:sort(
           fun(#p_warofcity_family_mark{marks=AMark}, #p_warofcity_family_mark{marks=BMark}) ->
                   AMark < BMark
           end, L),
    lists:sublist(L2, 1, 3).

get_top_mark_role_list() ->
    L = erlang:get(?role_mark_list),
    L2 = lists:sort(
           fun(#p_warofcity_role_mark{marks=AMark}, #p_warofcity_role_mark{marks=BMark}) ->
                   AMark < BMark
           end, L),
    lists:sublist(L2, 1, 3).


init_role_mark(RoleMarkList) ->
    erlang:put(?role_mark_list, RoleMarkList).     
add_role_mark(RoleID, Add) ->
    L = get_role_mark_list(),
    case lists:keyfind(RoleID, 1, L) of
        false ->
            ignore;
        OldMark ->
            NewMark = OldMark#p_warofcity_role_mark{marks=OldMark#p_warofcity_role_mark.marks + Add},
            L2 = lists:keyreplace(RoleID, 1, L, NewMark),
            erlang:put(?role_mark_list, L2)
    end.
get_role_mark_list() ->
    erlang:get(?role_mark_list).


%%获取门派积分列表
get_family_mark_list() ->
    erlang:get(?family_mark_list).
init_family_mark(FamilyMarkList) ->
    erlang:put(?family_mark_list, FamilyMarkList).                           
add_family_mark(FamilyID, Add) ->
    L = get_family_mark_list(),
    %% 当前还没有限制在该副本地图中创建门派，所以还是要判断一下
    case lists:keyfind(FamilyID, 1, L) of
        false ->
            ignore;        
        OldMark ->
            NewMark = OldMark#p_warofcity_family_mark{marks=OldMark#p_warofcity_family_mark.marks + Add},
            L2 = lists:keyreplace(FamilyID, 1, L, NewMark),
            erlang:put(?family_mark_list, L2)
    end.
    

%%收到消息，战斗正式开始
do_begin_war() ->
    set_safetime_flag(false),
    [#p_warofcity{family_id=FamilyID}] = db:dirty_read(?DB_WAROFCITY, mgeem_map:get_mapid()),
    %%默认由上一届的占领者占有图腾
    set_hold_familyid(FamilyID),
    ok.

%%由其他地图转发过来的同意进入战斗请求，已经验证过权限了
do_redirect_agree_enter(RoleID, FamilyID) ->
    record_join_role(RoleID, FamilyID).


redirect_agree_enter(RoleID, FamilyID, MapID) ->
    MapPName = common_misc:get_common_map_name(MapID),
    case global:whereis_name(MapPName) of
        undefined ->
            ignore;
        PID ->
            PID ! {agree_enter, RoleID, FamilyID}
    end.


%%玩家同意进入战场
do_agree_enter(Unique, Module, Method, _Record, RoleID, Line) ->
    case catch do_agree_enter_check(RoleID) of
        {ok, FamilyID, MapID} ->
            State = mgeem_map:get_state(),
            CurMapID = State#map_state.mapid,
            case MapID =:= CurMapID of
                true ->
                    %%记录参战的玩家
                    record_join_role(RoleID, FamilyID);
                false ->
                    %%转发信息请求给对应的地图
                    redirect_agree_enter(RoleID, FamilyID, MapID)
            end,
            R = #m_warofcity_agree_enter_toc{},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R),
            MapPName = common_map:get_warofcity_mapname(MapID),
            common_map:info(MapPName, {role_change_map, RoleID});
        {error, Reason} ->
            do_agree_enter_error(Unique, Module, Method, Reason, RoleID, Line);
        {'EXIT', Error} ->
            ?ERROR_MSG("~ts:~w", ["处理玩家同意进入地图争夺战战场出错", Error]),
            do_agree_enter_error(Unique, Module, Method, ?_LANG_SYSTEM_ERROR, RoleID, Line)
    end.

do_agree_enter_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_warofcity_agree_enter_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

do_agree_enter_check(RoleID) ->
    {ok, #p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    case FamilyID > 0 of
        true ->
            ok;
        false ->
            throw({error, ?_LANG_WAROFCITY_NO_FAMILY_WHEN_AGREE_ENTER})
    end,
    case db:dirty_read(?DB_WAROFCITY_APPLY, FamilyID) of
        [] ->
            throw({error, ?_LANG_WAROFCITY_FAMILY_NOT_APPLY});
        [#r_warofcity_apply{map_id=MapID}] ->
            {ok, FamilyID, MapID}
    end.
    

%% 记录该玩家同意参加地图争霸战，用于最终发放参与奖
record_join_role(RoleID, FamilyID) ->
    erlang:put(?warofking_join_role_list, [{RoleID, FamilyID} | get_join_role()]).
get_join_role() ->
    erlang:get(?warofking_join_role_list).
clear_join_role() ->
    put(?warofking_join_role_list, []).


%%获取当前是否是安全期，需要先判断是否在战斗期间
get_safetime_flag() ->
    get(?warofcity_safetime_flag).
init_safetime_flag() ->
    put(?warofcity_safetime_flag, true).
set_safetime_flag(Flag) ->
    put(?warofcity_safetime_flag, Flag).
    

%%处理申请
do_apply(Unique, Module, Method, _Record, RoleID, Line) ->
    %% 只能申请当前所在地图的争夺战
    MapID = mgeem_map:get_mapid(),
    %%判断前提条件
    case catch do_apply_check(RoleID, MapID) of
        {ok, FamilyID, FamilyName} ->   
            SuccFunc = fun() ->
                               [#p_warofcity{apply_family_list=ApplyFamilyList}=WarOfCity] = db:dirty_read(?DB_WAROFCITY, MapID),
                               NewApplyFamily = #p_warofcity_apply_family{family_id=FamilyID, family_name=FamilyName},
                               db:dirty_write(?DB_WAROFCITY, WarOfCity#p_warofcity{
                                                               apply_family_list=[NewApplyFamily | ApplyFamilyList]}),
                               %%通知玩家结果
                               R = #m_warofcity_apply_toc{},
                               common_misc:unicast(Line, RoleID, Unique, Module, Method, R)
                       end,
            FailedFunc = fun() ->
                                 R = #m_warofcity_apply_toc{succ=false, reason=?_LANG_WAROFCITY_FAMILY_MONEY_NOT_ENOUGH},
                                 common_misc:unicast(Line, RoleID, Unique, Module, Method, R)
                         end,
            common_family:info(FamilyID, {reduce_money, 
                                          config_warofcity:get_apply_money(MapID), 
                                          self(), 
                                          {?MODULE, {apply_func, SuccFunc}}, 
                                          {?MODULE, {apply_func, FailedFunc}}
                                         }),            
            ok;
        {error, Reason} ->
            do_apply_error(Unique, Module, Method, Reason, RoleID, Line),
            ok;
        {'EXIT', Error} ->
            ?ERROR_MSG("~ts:~p", ["处理申请地图争夺战申请出错", Error]),
            do_apply_error(Unique, Module, Method, ?_LANG_SYSTEM_ERROR, RoleID, Line),
            ok
    end.

do_apply_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_warofcity_apply_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

do_apply_check_family_holded(FamilyID, MapID) ->
    case db:transaction(fun() -> db:match_object(?DB_WAROFCITY, #p_warofcity{family_id=FamilyID, _='_'}, write) end) of
        {atomic, Result} ->
            case Result of
                [] ->
                    ok;
                [#p_warofcity{map_id=MapID2}] ->
                    case MapID2 =:= MapID of
                        true ->
                            throw({error, ?_LANG_WAROFCITY_HOLD_CITY_NOT_NEED_TO_APPLY});
                        false ->                    
                            throw({error, ?_LANG_WAROFCITY_ALREADY_HOLD})
                    end
            end;
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w", ["检查门派是否占领地图时出错", Error]),
            throw({error, ?_LANG_WAROFCITY_SYSTEM_ERROR_WHEN_CHECH_FAMILY_HOLDED})
    end.
                                
do_apply_check_family_applyed(FamilyID) ->
    case db:transaction(fun() -> db:read(?DB_WAROFCITY_APPLY, FamilyID, write) end) of
        {atomic, Result} ->
            case Result of
                [] ->
                    ok;
                _ ->
                    throw({error, ?_LANG_WAROFCITY_ALREADY_APPLY})
            end;
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w", ["检查门派是否已申请地图争夺战出错", Error]),
            throw({error, ?_LANG_WAROFCITY_SYSTEM_ERROR_WHEN_FAMILY_APPLYED})
    end.

do_apply_check_without_family_money_check(RoleID, MapID) ->
    %%检查玩家是否有权利申请
    {ok, #p_role_base{family_id=FamilyID, family_name=FamilyName}} = mod_map_role:get_role_base(RoleID),
    case FamilyID > 0 of
        true ->
            ok;
        false ->
            throw({error, ?_LANG_WAROFCITY_MUST_HAS_A_FAMILY})
    end,
    %% 只有掌门或者长老才能申请
    [#p_family_info{owner_role_id=OwnerRoleID, 
                    second_owners=SecondOwners, 
                    faction_id=FactionID,
                    level=Level}] = db:dirty_read(?DB_FAMILY, FamilyID),
    case RoleID =:= OwnerRoleID orelse lists:keyfind(RoleID, #p_family_second_owner.role_id, SecondOwners) of
        true ->
            ok;
        false ->
            throw({error, ?_LANG_WAROFCITY_NO_RIGHT_TO_APPLY})
    end,
    
    %%检查是否在争夺战期间，为了方便测试，这里不使用时间直接进行判断
    case get_in_wartime() of
        true ->
            throw({error, ?_LANG_WAROFCITY_CANNT_APPLY_WHEN_WARTIME});
        false ->
            ok
    end,
    %%检查是否已经占领了城市了
    do_apply_check_family_holded(FamilyID, MapID),
    do_apply_check_family_applyed(FamilyID),
         
    %% 检查是否是本国门派
    case common_misc:get_map_faction_id(MapID) =:= FactionID of
        true ->
            ok;
        false ->
            throw({error, ?_LANG_WAROFCITY_CAN_ONLY_APPLY_SELF_FACTION_CITY})
    end,
    %% 检查当前地图升级需要的门派等级
    case Level < 1 of
        true ->
            throw({error, ?_LANG_WAROFCITY_AT_LEAST_ONE_LEVEL});
        false ->
            ok
    end,
    case Level >= config_warofcity:get_apply_level(MapID) of
        true ->
            ok;
        false ->
            throw({error, ?_LANG_WAROFCITY_LEVEL_NOT_ENOUGH})
    end,                  
    {ok, FamilyID, FamilyName}.


do_apply_check(RoleID, MapID) ->
    do_apply_check_without_family_money_check(RoleID, MapID),
    %%检查玩家是否有权利申请
    {ok, #p_role_base{family_id=FamilyID, family_name=FamilyName}} = mod_map_role:get_role_base(RoleID),
    %% 只有掌门或者长老才能申请
    [#p_family_info{money=Money}] = db:dirty_read(?DB_FAMILY, FamilyID),
    %%判断门派资金是否足够报名
    case Money >= config_warofcity:get_apply_money(MapID) of
        true ->
            ok;
        false ->
            throw({error, ?_LANG_WAROFCITY_FAMILY_MONEY_NOT_ENOUGH})
    end,
    {ok, FamilyID, FamilyName}.

    
get_in_wartime() ->
    get(?WAROFCITY_WARTIME_FLAG).
set_in_wartime(Flag) ->
    put(?WAROFCITY_WARTIME_FLAG, Flag).


%% 判断图腾当前是否被占领了
is_holding() ->
    case erlang:get(?warofcity_flag) of
        undefined ->
            false;
        _ ->
            true
    end.

break_hold_no_family() ->
    R = #m_warofcity_break_toc{},
    mgeem_map:broadcast_to_whole_map(?WAROFCITY, ?WAROFCITY_BREAK, R),
    erlang:erase(?warofcity_flag).
break_hold(_FamilyID) ->
    %%广播通知一下
    R = #m_warofcity_break_toc{},
    mgeem_map:broadcast_to_whole_map(?WAROFCITY, ?WAROFCITY_BREAK, R),
    erlang:erase(?warofcity_flag),
    erlang:erase(?warofcity_flag_holding_family).
%%开始占领
begin_hold(RoleID, FamilyID) ->
    erlang:put(warofcity_flag, {RoleID, FamilyID, 0, false}).

%% Flag为true时表示已经占领，
update_hold(RoleID, FamilyID, NewTime, Flag) ->
    erlang:put(?warofcity_flag, {RoleID, FamilyID, NewTime, Flag}).
info_hold() ->
    erlang:get(?warofcity_flag).
succ_hold(FamilyID, FamilyName, RoleName) ->
    set_hold_familyid(FamilyID),
    set_hold_time(FamilyID),
    R = #m_warofcity_hold_succ_toc{family_id=FamilyID, family_name=FamilyName, role_name=RoleName},
    mgeem_map:broadcast_to_whole_map(?WAROFCITY, ?WAROFCITY_HOLD_SUCC, R),
    ok.
get_hold_familyid() ->
    erlang:get(?warofcity_flag_holding_family).
set_hold_familyid(FamilyID) ->
    erlang:put(?warofcity_flag_holding_family, FamilyID).


set_hold_time(FamilyID) ->
    erlang:put(?warofcity_hold_time, {FamilyID, 0}).
%% get_hold_time() ->
%%     erlang:get(?warofcity_hold_time).
%% clear_hold_time() ->
%%     erlang:erase(?warofcity_hold_time).
