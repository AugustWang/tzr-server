%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @doc 传奇目标
%%%
%%% @end
%%% Created :  8 Jun 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_goal).

%% API
-export([
         handle/1,
         init_check/0
        ]).

-include("mgeem.hrl").

%%%===================================================================
%%% API
%%%===================================================================

%% 启动时检查配置文件
init_check() ->
    List = common_config_dyn:list(goal),
    lists:foreach(
      fun(#p_goal_config{}) ->
              ok
      end, List).
    

handle({Unique, Module, Method, DataRecord, RoleID, PID, Line}) ->
    case Method of
        ?GOAL_INFO ->
            do_info(Unique, Module, Method, RoleID, PID);
        ?GOAL_FETCH ->
            do_fetch(Unique, Module, Method, DataRecord, RoleID, PID);
        _ ->
            ?ERROR_MSG("~ts:~p", ["未知的消息", {Unique, Module, Method, DataRecord, RoleID, PID, Line}])
    end;
handle({hook_goal_event, RoleID, GoalID}) ->
    do_hook_goal_event(RoleID, GoalID);
handle({hook_goal_event_process, RoleID, GoalID, Process}) ->
    do_hook_goal_event_process(RoleID, GoalID, Process);
%% GM测试接口，用于设置玩家登录天数
handle({set_role_days, RoleID, Days}) ->
    do_set_role_days(RoleID, Days);
handle(Info) ->
    ?ERROR_MSG("~ts:~w", ["未知消息", Info]).

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% 设置玩家登录天数
do_set_role_days(RoleID, Days) ->
    case mod_map_role:get_role_goal(RoleID) of
        {ok, RoleGoalInfo} ->
            common_transaction:t(fun() -> mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{days=Days}) end);
        {error, _} ->
            erlang:spawn(fun() ->
            db:transaction(fun() ->
                                   [RoleGoalInfo] = db:read(?DB_ROLE_GOAL_P, RoleID, write),
                                   db:write(?DB_ROLE_GOAL_P, RoleGoalInfo#p_role_goal{days=Days}, write)
                           end) end)
    end.                                         
    

do_hook_goal_event_process(RoleID, GoalID, Process) ->
    %% 更新玩家的目标的进度
    case common_transaction:t(fun() -> t_update_role_goal_process(RoleID, GoalID, Process) end) of
        {atomic, Result} ->
            %% 根据返回值来判断是否需要通知玩家目标状态已更新
            case Result of
                ignore ->
                    ignore;
                NewRoleGoalItem ->
                    R = #m_goal_update_toc{goal_item=NewRoleGoalItem},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?GOAL, ?GOAL_UPDATE, R)
            end,
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w", ["更新玩家目标状态时发生系统错误", Error])
    end, 
    ok.

t_update_role_goal_process(RoleID, GoalID, Process) ->
    {ok, #p_role_goal{goals=RoleGoals} = RoleGoalInfo} = mod_map_role:get_role_goal(RoleID),
    case lists:keyfind(GoalID, #p_role_goal_item.goal_id, RoleGoals) of
        false ->
            [#p_goal_config{num=MaxNum}] = get_goal_config(GoalID),
            case MaxNum =:= 0 orelse MaxNum =:= 1 orelse MaxNum =:= Process of
                true ->
                    %% 这种情况表示该目标完成了
                    NewRoleGoalItem = #p_role_goal_item{goal_id=GoalID, finished=true, process_num=1}, 
                    NewRoleGoals = [NewRoleGoalItem | RoleGoals],
                    mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{goals=NewRoleGoals}),
                    NewRoleGoalItem;
                false ->
                    %% 更新进度
                    NewRoleGoalItem = #p_role_goal_item{goal_id=GoalID, process_num=Process},
                    NewRoleGoals = [NewRoleGoalItem | RoleGoals],
                    mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{goals=NewRoleGoals}),
                    NewRoleGoalItem
            end;
        #p_role_goal_item{finished=Finished, fetched=Fetched} = RoleGoalItem ->
            case Fetched =:= true orelse Finished =:= true of
                true ->
                    %% 不需要更新状态
                    ignore;
                false ->
                    [#p_goal_config{num=MaxNum}] = get_goal_config(GoalID),
                    case MaxNum =:= 0 orelse MaxNum =:= 1 orelse (MaxNum =:= Process) of
                        true ->
                            %% 这种情况表示该目标完成了
                            NewRoleGoalItem = RoleGoalItem#p_role_goal_item{finished=true, process_num=Process}, 
                            NewRoleGoals = lists:keyreplace(GoalID, #p_role_goal_item.goal_id, 
                                                            RoleGoals, NewRoleGoalItem),
                            mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{goals=NewRoleGoals}),
                            NewRoleGoalItem;
                        false ->
                            %% 更新进度
                            NewRoleGoalItem = RoleGoalItem#p_role_goal_item{process_num=Process},
                            NewRoleGoals = lists:keyreplace(GoalID, #p_role_goal_item.goal_id, 
                                                            RoleGoals, NewRoleGoalItem),
                            mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{goals=NewRoleGoals}),
                            NewRoleGoalItem
                    end
            end
    end.
    

%% 玩家触发了一个目标
do_hook_goal_event(RoleID, GoalID) ->
    %% 更新玩家的目标的进度
    case common_transaction:t(fun() -> t_update_role_goal(RoleID, GoalID) end) of
        {atomic, Result} ->
            %% 根据返回值来判断是否需要通知玩家目标状态已更新
            %?ERROR_MSG("~p", [Result]),
            case Result of
                ignore ->
                    ignore;
                NewRoleGoalItem ->
                    R = #m_goal_update_toc{goal_item=NewRoleGoalItem},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?GOAL, ?GOAL_UPDATE, R)
            end,
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w", ["更新玩家目标状态时发生系统错误", Error])
    end, 
    ok.

%% 更新玩家某个goal的进度和状态情况
t_update_role_goal(RoleID, GoalID) ->
    {ok, #p_role_goal{goals=RoleGoals} = RoleGoalInfo} = mod_map_role:get_role_goal(RoleID),
    case lists:keyfind(GoalID, #p_role_goal_item.goal_id, RoleGoals) of
        false ->
            [#p_goal_config{num=MaxNum}] = get_goal_config(GoalID),
            case MaxNum =:= 0 orelse MaxNum =:= 1 of
                true ->
                    %% 这种情况表示该目标完成了
                    NewRoleGoalItem = #p_role_goal_item{goal_id=GoalID, finished=true, process_num=1}, 
                    NewRoleGoals = [NewRoleGoalItem | RoleGoals],
                    mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{goals=NewRoleGoals}),
                    NewRoleGoalItem;
                false ->
                    %% 更新进度
                    NewRoleGoalItem = #p_role_goal_item{goal_id=GoalID, process_num=1},
                    NewRoleGoals = [NewRoleGoalItem | RoleGoals],
                    mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{goals=NewRoleGoals}),
                    NewRoleGoalItem
            end;
        #p_role_goal_item{finished=Finished, process_num=ProcessNum, fetched=Fetched} = RoleGoalItem ->
            case Fetched =:= true orelse Finished =:= true of
                true ->
                    %% 不需要更新状态
                    ignore;
                false ->
                    [#p_goal_config{num=MaxNum}] = get_goal_config(GoalID),
                    case MaxNum =:= 0 orelse MaxNum =:= 1 orelse (MaxNum =:= ProcessNum + 1) of
                        true ->
                            %% 这种情况表示该目标完成了
                            NewRoleGoalItem = RoleGoalItem#p_role_goal_item{finished=true, process_num=ProcessNum+1}, 
                            NewRoleGoals = lists:keyreplace(GoalID, #p_role_goal_item.goal_id, 
                                                            RoleGoals, NewRoleGoalItem),
                            mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{goals=NewRoleGoals}),
                            NewRoleGoalItem;
                        false ->
                            %% 更新进度
                            NewRoleGoalItem = RoleGoalItem#p_role_goal_item{process_num=ProcessNum+1},
                            NewRoleGoals = lists:keyreplace(GoalID, #p_role_goal_item.goal_id, 
                                                            RoleGoals, NewRoleGoalItem),
                            mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{goals=NewRoleGoals}),
                            NewRoleGoalItem
                    end
            end
    end.


%% 获取玩家的目标完成情况
do_info(Unique, Module, Method, RoleID, PID) ->
    Info = get_role_goal_info(RoleID),
    R = #m_goal_info_toc{info=Info},
    common_misc:unicast2(PID, Unique, Module, Method, R),
    ok.


%% 获取角色的目标完成进度情况，从进程字典读取，返回的record为#p_role_goal
get_role_goal_info(RoleID) ->
    {ok, GoalInfo} = mod_map_role:get_role_goal(RoleID),
    GoalInfo.


%% 目标完成后，领取奖励
do_fetch(Unique, Module, Method, DataRecord, RoleID, PID) ->
    #m_goal_fetch_tos{goal_id=GoalID} = DataRecord, 
    case catch do_check_goal_fetch(RoleID, GoalID) of
        ok ->
            %% 准备实际的给奖励了
            case common_transaction:transaction(fun() -> t_do_fetch(RoleID, GoalID) end) of
                {atomic, {ItemList, _NewRoleAttr}} ->
                    R = #m_goal_fetch_toc{goal_id=GoalID},
                    common_misc:unicast2(PID, Unique, Module, Method, R),
                    %%common_misc:unicast2(PID, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_RELOAD, #m_role2_reload_toc{role_attr=NewRoleAttr}),
                    common_misc:update_goods_notify({role,RoleID}, ItemList),
                    lists:foreach(
                      fun(GoodsInfo) ->
                              common_item_logger:log(RoleID, GoodsInfo, ?LOG_ITEM_TYPE_GAIN_GOAL)
                      end, ItemList),
                    ok;
                {aborted, {bag_error,not_enough_pos}} ->
                    do_fetch_error(Unique, Module, Method, ?_LANG_GOAL_NOT_ENOUGH_POS_WHEN_FETCH, PID);
                {aborted, Error} ->
                    case erlang:is_binary(Error) of
                        true ->
                            do_fetch_error(Unique, Module, Method, Error, PID);
                        false ->
                            ?ERROR_MSG("~ts:~w", ["领取目标奖励时发生系统错误", Error]),
                            do_fetch_error(Unique, Module, Method, ?_LANG_GOAL_SYSTEM_ERROR_WHEN_FETCH, PID)
                    end
            end,
            ok;
        {error, Reason} ->
            do_fetch_error(Unique, Module, Method, Reason, PID)
    end,
    ok.


%% 内存事务:给玩家目标奖励
t_do_fetch(RoleID, GoalID) ->
    RoleGoalInfo = get_role_goal_info(RoleID),
    #p_role_goal{goals=RoleGoals} = RoleGoalInfo,
    case lists:keyfind(GoalID, #p_role_goal_item.goal_id, RoleGoals) of
        false ->
            %% 玩家的数据库记录里面没有这个目标的信息，则直接写入
            NewRoleGoals = [#p_role_goal_item{goal_id=GoalID, finished=true, fetched=true} | RoleGoals],
            NewRoleGoalInfo = RoleGoalInfo#p_role_goal{goals=NewRoleGoals},
            ok;
        RoleGoalItem ->
            NewRoleGoalItem = RoleGoalItem#p_role_goal_item{fetched=true},
            NewGoalItems = lists:keyreplace(GoalID, #p_role_goal_item.goal_id, RoleGoals, NewRoleGoalItem),
            NewRoleGoalInfo = RoleGoalInfo#p_role_goal{goals=NewGoalItems}
    end,
    mod_map_role:set_role_goal(RoleID, NewRoleGoalInfo),
    %% 接下来是给奖励
    do_give_award(RoleID, GoalID).
    

%% 获得传奇目标的配置信息
get_goal_config(GoalID) ->
    common_config_dyn:find(goal, GoalID).

%% 根据目标的ID给玩家奖励
do_give_award(RoleID, GoalID) ->
    [GoalConfig] = get_goal_config(GoalID),
    #p_goal_config{gold_bind=GoldBind, gold=Gold, silver_bind=SilverBind, silver=Silver, exp=Exp, items=Items} = GoalConfig,
    {ok, #p_role_attr{gold_bind=OldGoldBind, gold=OldGold, silver_bind=OldSilverBind, silver=OldSilver} = RoleAttr} 
        = mod_map_role:get_role_attr(RoleID),
    %% 给元宝和银两
    NewRoleAttr = RoleAttr#p_role_attr{gold_bind=OldGoldBind+GoldBind,
                                       gold=OldGold + Gold,
                                       silver_bind=SilverBind + OldSilverBind,
                                       silver=Silver + OldSilver},
    %% 记录银两和元宝的获取记录
    t_log_gold(RoleID, GoldBind, Gold),
    t_log_silver(RoleID, SilverBind, Silver),
    mod_map_role:set_role_attr(RoleID, NewRoleAttr),
    %% 给道具
    ItemList = lists:foldl(
                 fun(#p_goal_item{item_id=ItemID, item_type=ItemType, color=Color, quality=Quality, bind=Bind, end_time=EndTime, num=Num}, Acc) ->
                         case EndTime =:= 0 orelse EndTime =:= undefined of
                             true ->
                                 End = 0,
                                 Start = 0;
                             false ->
                                 Start = common_tool:now(),
                                 End = Start + EndTime
                         end,
                         GoodsCreateInfo = #r_goods_create_info{bag_id=0, num=Num, type_id=ItemID, bind=Bind, color=Color, quality=Quality,
                                                                start_time=Start, end_time=End, type=ItemType},
                         {ok, [GoodsInfo]} = mod_bag:create_goods(RoleID, GoodsCreateInfo),
                         %% 记录道具获取日志
                         [GoodsInfo | Acc]
                 end, [], Items),
    case Exp > 0 of
        true ->
            mod_map_role:t_add_exp(RoleID, Exp, ?EXP_ADD_TYPE_NORMAL);
        false ->
            ignore
    end,
    {ItemList, NewRoleAttr}.

t_log_gold(RoleID, GoldBind, Gold) ->
    case GoldBind > 0 orelse Gold > 0 of
        true ->
            common_consume_logger:gain_gold({RoleID, GoldBind, Gold, ?GAIN_TYPE_GOLD_FROM_GOAL, ""});
        false ->
            ignore
    end.

t_log_silver(RoleID, SilverBind, Silver) ->
    case SilverBind > 0 orelse Silver > 0 of
        true ->
            common_consume_logger:gain_silver({RoleID, SilverBind, Silver, ?GAIN_TYPE_SILVER_FROM_GOAL, ""});
        false ->
            ignore
    end.


%% 检查玩家是否能否领取对应的目标奖励
do_check_goal_fetch(RoleID, GoalID) ->
    RoleGoalInfo = get_role_goal_info(RoleID),
    #p_role_goal{days=LoginDays, goals=RoleGoals} = RoleGoalInfo,
    [#p_goal_config{day=Day}] = get_goal_config(GoalID),
    case Day > LoginDays of
        true ->
            Info = common_tool:to_binary(io_lib:format(?_LANG_GOAL_CANNT_FETCH_BECAUSE_DAY, [Day, LoginDays])),
            erlang:throw({error, Info});
        false ->
            ok
    end,
    case lists:keyfind(GoalID, #p_role_goal_item.goal_id, RoleGoals) of
        false ->
            erlang:throw({error, ?_LANG_GOAL_NOT_FINISH});
        #p_role_goal_item{finished=Finished, fetched=Fetched} ->
            case Finished of
                true ->
                    case Fetched of
                        true ->
                            erlang:throw({error, ?_LANG_GOAL_HAS_FETCHED});
                        false ->
                            ok
                    end,
                    ok;
                false ->
                    erlang:throw({error, ?_LANG_GOAL_NOT_FINISH})
            end
    end,
    ok.

do_fetch_error(Unique, Module, Method, Reason, PID) ->
    R = #m_goal_fetch_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, R).

