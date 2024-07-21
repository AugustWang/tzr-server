%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 28 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mgeew_pay_server).

-behaviour(gen_server).

-include("mgeew.hrl").

%% API
-export([start/0, start_link/0]).
-export([check_is_first_pay/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-define(ADD_GOLD_BY_PAY,pay_add_gold).

-define(PROCESS_FAILED_QUEUE_INTERVAL, 30000).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    {ok, _} = supervisor:start_child(mgeew_sup, {?MODULE, {?MODULE, start_link, []},
                                                 permanent, 30000, worker, [?MODULE]}).

%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({global, ?SERVER}, ?MODULE, [], []).

%%%===================================================================

%%--------------------------------------------------------------------
init([]) ->
    erlang:process_flag(trap_exit, true),
    init_pay_index_table(),
    ok = common_config_dyn:init(activity_pay_first),
    erlang:send_after(?PROCESS_FAILED_QUEUE_INTERVAL, erlang:self(), process_failed_queue),
    {ok, #state{}}.

%%--------------------------------------------------------------------
handle_call(Request, _From, State) ->
    Reply = do_handle_call(Request),
    {reply, Reply, State}.

%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(Info, State) ->
    ?DO_HANDLE_INFO(Info,State),
    {noreply, State}.

%%--------------------------------------------------------------------
terminate(Reason, _State) ->
    ?ERROR_MSG("~ts:~w", ["充值服务down掉", Reason]),
    ok.

%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================

do_handle_info({?ADD_ROLE_MONEY_SUCC, RoleID, RoleAttr, {?ADD_GOLD_BY_PAY,OrderID,PayGold}})->
    #p_role_attr{gold=CurrentGold}=RoleAttr,
    ?INFO_MSG("充值的元宝成功增加到玩家背包中,RoleID=~w,CurrentGold=~w",[RoleID,CurrentGold]),
    do_insert_pay_gold_log(true,OrderID,RoleID,PayGold,""),
    do_remove_failed_queue(OrderID),
    ok;
do_handle_info({?ADD_ROLE_MONEY_FAILED, RoleID, Reason, {?ADD_GOLD_BY_PAY,OrderID,PayGold}})->
    ?ERROR_MSG("充值的元宝增加失败！,RoleID=~w,Reason=~w",[RoleID,Reason]),
    do_insert_into_failed_queue(RoleID, OrderID, PayGold),
    do_insert_pay_gold_log(false,OrderID,RoleID,PayGold,Reason),
    ok;

do_handle_info(process_failed_queue) ->
    erlang:send_after(?PROCESS_FAILED_QUEUE_INTERVAL, erlang:self(), process_failed_queue),
    do_process_failed_queue();

do_handle_info(Info)->
    ?ERROR_MSG("receive unknown message,Info=~w",[Info]),
    ignore.

-define(IS_MONEY(M),(erlang:is_integer(M) orelse erlang:is_float(M))).

%%普通充值接口
do_handle_call({pay, OrderID, AcName, PayTime, PayGold, PayMoney, {Year, Month, Day, Hour}})
  when OrderID =/= undefined andalso AcName =/= undefined  andalso erlang:is_integer(PayTime) andalso erlang:is_integer(PayGold)
        andalso ?IS_MONEY(PayMoney) andalso erlang:is_integer(Year) andalso erlang:is_integer(Month)
       andalso erlang:is_integer(Month) andalso erlang:is_integer(Day) andalso erlang:is_integer(Hour) ->    
    do_pay(OrderID, AcName, PayTime, PayGold, PayMoney, {Year, Month, Day, Hour});
do_handle_call(Request) -> 
    ?ERROR_MSG("~ts:~w", ["未知的CALL", Request]).


do_pay(OrderID, AccountName, PayTime, PayGold, PayMoney, {Year, Month, Day, Hour}) ->
    ?ERROR_MSG("~ts: ~w", ["收到充值请求", {OrderID, AccountName, PayTime, PayGold, PayMoney, {Year, Month, Day, Hour}}]),
    
    BinAccountName = common_tool:to_binary(AccountName),
    IsFirst = check_is_first_pay(BinAccountName),
    case db:transaction(fun() -> 
                                t_do_pay(OrderID, BinAccountName, PayTime, PayGold, PayMoney, 
                                         {Year, Month, Day, Hour},IsFirst) end) of
        {atomic, {RoleID, NewGold,RoleName}} ->
            Content = common_letter:create_temp(?RECHARGE_SUCCESS_LETTER, [RoleName, PayGold]),
            common_letter:sys2p(RoleID,Content,"充值成功通知信件",14),
            case IsFirst of
                true ->
                    %%{{Year, Month, Day}, _} = erlang:localtime(),
                    Text = common_letter:create_temp(?PAY_FIRST_LETTER, [RoleName, Year, Month, Day]),
                    common_letter:sys2p(RoleID, Text, ?_LANG_PAY_FIRST_TITLE, 14);
                false ->
                    ignore
            end,
            RR = #m_role2_attr_change_toc{roleid=RoleID, 
                                          changes=[#p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, 
                                                                               new_value=NewGold}
                                                  ]},
            
            %% 发送到behavior
            {ok, #p_role_attr{level=Level} } = common_misc:get_dirty_role_attr(RoleID),
            
            PayDateTime = calendar:datetime_to_gregorian_seconds({{Year, Month, Day},{0,0,0}})-calendar:datetime_to_gregorian_seconds({{1970,1,1}, {8,0,0}}),
            {{OpenY,OpenM,OpenD}, _} = common_config:get_open_day(),
            OnlineDay = calendar:date_to_gregorian_days(erlang:date())-calendar:date_to_gregorian_days(OpenY,OpenM,OpenD),
            catch common_behavior:send({pay_log, {AccountName,RoleID,RoleName,OrderID,PayMoney,PayGold,PayTime,Year, Month, Day, Hour,Level,PayDateTime,OnlineDay} }),
            
            catch common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, RR),
            %%充值活动 
            catch common_activity:stat_special_activity(?SPEND_SUM_PAY_KEY,{RoleID,PayGold}),
            catch common_activity:stat_special_activity(?SPEND_ONCE_PAY_KEY,{RoleID,PayGold}),
            ok;
        {aborted, Reason} ->
            case erlang:is_binary(Reason) of
                true ->
                    ?ERROR_MSG("~ts:~w", ["充值出错", common_tool:to_list(Reason)]);
                false ->
                    ?ERROR_MSG("~ts:~w", ["充值出错", Reason])
            end,
            case Reason of
                ?_LANG_PAY_DUPLICATED ->
                    used;
                ?_LANG_PAY_ACCOUNT_NOT_FOUND->
                    not_found;
                _ ->
                    error
            end
    end.

%% @doc 检查是否首次充值
check_is_first_pay(AccountName)->
    Limit = 1,
    MatchHead = #r_pay_log{_='_', account_name=AccountName},
    Guard = [],
    Result = ['$_'],
    case ets:select(?DB_PAY_LOG,[{MatchHead, Guard, Result}],Limit) of
        {ExpRecordList,_Continuation} when length(ExpRecordList)>0->
            false;
        _ ->    %% '$end_of_table'
            true
    end.

t_do_pay(OrderID, AccountName, PayTime, PayGold, PayMoney, {Year, Month, Day, Hour},IsFirst) ->
    %%判断是否该订单已经处理过
    case db:match_object(?DB_PAY_LOG, #r_pay_log{order_id=OrderID, _='_'}, write) of
        [] ->
            case db:match_object(?DB_ROLE_BASE_P, #p_role_base{account_name=AccountName, _='_'}, write) of
                [] ->
                    db:abort(?_LANG_PAY_ACCOUNT_NOT_FOUND);
                [RoleBase] ->                    
                    t_do_pay2(OrderID, AccountName, RoleBase, PayTime, PayGold, PayMoney, {Year, Month, Day, Hour},IsFirst)
            end;
        _ ->
            db:abort(?_LANG_PAY_DUPLICATED)
    end.


%% 在线更新元宝
t_do_add_gold_online(OrderID, RoleID, PayGold)->
    AddMoneyList = [{gold, PayGold,?GAIN_TYPE_GOLD_FROM_PAY,""}],
    %%同时发送银两/元宝更新的通知
    common_role_money:add(RoleID, AddMoneyList,{?ADD_GOLD_BY_PAY,OrderID,PayGold},{?ADD_GOLD_BY_PAY,OrderID,PayGold}, false).

%% 离线更新元宝
t_do_add_gold_offline(RoleAttr,OldGold,PayGold)->
    NewRoleAttr = RoleAttr#p_role_attr{gold=OldGold + PayGold},
    db:write(?DB_ROLE_ATTR, NewRoleAttr, write).

t_do_pay2(OrderID, AccountName, RoleBase, PayTime, PayGold, PayMoney, {Year, Month, Day, Hour},IsFirst) ->
    #p_role_base{role_id=RoleID, role_name=RoleName} = RoleBase,
    [#p_role_attr{gold=OldGold,level=RoleLevel}=RoleAttr] = db:read(?DB_ROLE_ATTR, RoleID),
    [#r_pay_log_index{value=ID}] = db:read(?DB_PAY_LOG_INDEX, 1),
    RoleAttr2 = RoleAttr#p_role_attr{is_payed=true},
    %%记录日志
    %%给对应的玩家添加元宝，发信件通知玩家
    RLog = #r_pay_log{id=ID+1,order_id=OrderID, role_id=RoleID, role_name=RoleName,
                      account_name=AccountName, pay_time=PayTime, pay_gold=PayGold,
                      pay_money=PayMoney, year=Year, month=Month, day=Day, hour=Hour, is_first=IsFirst,role_level=RoleLevel},
    t_do_pay3(OrderID, PayGold, OldGold, RoleAttr2, RLog, 1 + ID).
        
    
%% 不满足首充
t_do_pay3(OrderID, PayGold, OldGold, RoleAttr, RLog, NewID) ->
    db:write(?DB_PAY_LOG, RLog, write),
    db:write(?DB_PAY_LOG_INDEX, #r_pay_log_index{id=1, value=NewID}, write),
    RoleID = RoleAttr#p_role_attr.role_id,
    case db:read(?DB_PAY_ACTIVITY_P, RoleID, write) of
        [] ->
            db:write(?DB_PAY_ACTIVITY_P, #r_pay_activity{role_id=RoleID, all_pay_gold=PayGold, get_first=false, 
                                                         accumulate_history=[]}, write);
        [#r_pay_activity{all_pay_gold=AllPayGold} = PayActivity] ->
            db:write(?DB_PAY_ACTIVITY_P, PayActivity#r_pay_activity{role_id=RoleID, all_pay_gold=AllPayGold+PayGold}, write)
    end,    
    case db:read(?DB_USER_ONLINE, RoleAttr#p_role_attr.role_id, read) of
        [] ->
            t_do_add_gold_offline(RoleAttr, OldGold,PayGold),
            common_consume_logger:gain_gold({RoleAttr#p_role_attr.role_id, 0, PayGold, ?GAIN_TYPE_GOLD_FROM_PAY, ""});
        _ ->
            db:write(?DB_ROLE_ATTR, RoleAttr, write),
            t_do_add_gold_online(OrderID, RoleAttr#p_role_attr.role_id, PayGold)
    end,    
    {RoleAttr#p_role_attr.role_id, OldGold+PayGold, RoleAttr#p_role_attr.role_name}.



%% 初始化充值记录表的数据
init_pay_index_table() ->
    case db:dirty_read(?DB_PAY_LOG_INDEX, 1) of
        [] ->
            db:dirty_write(?DB_PAY_LOG_INDEX, #r_pay_log_index{id=1, value=1});
        _ ->
            ignore
    end.
            
    
%%记录在线充值送元宝的日志表（不包括离线充值）
do_insert_pay_gold_log(IsSuccess,OrderID,RoleID,PayGold,_Reason)->
    try
        Now = common_tool:now(),
        StrReason = "",
        NSuccess = case IsSuccess of
                       true-> 1;
                       _-> 0
                   end,
        PayType = 1, %%'充值方式：1表示在线充值，2表示离线充值'
        FieldNames = [ order_id,role_id,is_succ,pay_type,pay_gold,mtime,reason ],
        FieldValues = [OrderID,RoleID,NSuccess,PayType,PayGold,Now,StrReason],
        
        SQL = mod_mysql:get_esql_insert(t_log_pay_gold,FieldNames,FieldValues),
        {ok,_} = mod_mysql:insert(SQL),
        common_misc:send_to_rolemap(RoleID, {mod_conlogin, {payed, RoleID}})
    catch
        _:Reason->
            ?ERROR_MSG("do_insert_pay_gold_log failed! reason: ~w, stack: ~w", [Reason, erlang:get_stacktrace()])
    end.    

    
%% 充值失败的记录插入到某个单独数据表中
do_insert_into_failed_queue(RoleID, OrderID, PayGold) ->
    case db:dirty_read(?DB_PAY_FAILED_P, OrderID) of
        [] ->
            db:dirty_write(?DB_PAY_FAILED_P, #r_pay_failed{order_id=OrderID, role_id=RoleID, pay_gold=PayGold});
        _ ->
            %% 已经记录了就不用处理了
            ignore
    end.

do_remove_failed_queue(OrderID) ->
    db:dirty_delete(?DB_PAY_FAILED_P, OrderID).

                                
do_process_failed_queue() ->
    lists:foreach(
      fun(#r_pay_failed{order_id=OrderID, role_id=RoleID, pay_gold=PayGold}) ->
              do_process_failed(OrderID, RoleID, PayGold)
      end, db:dirty_match_object(?DB_PAY_FAILED_P, #r_pay_failed{_='_'})).

do_process_failed(OrderID, RoleID, PayGold) ->
    Func = fun() ->
                   [RoleAttr] = db:read(?DB_ROLE_ATTR, RoleID, write),
                   case db:read(?DB_USER_ONLINE, RoleID, read) of
                       [] ->
                           t_do_add_gold_offline(RoleAttr#p_role_attr{is_payed=true}, RoleAttr#p_role_attr.gold, PayGold),
                           common_consume_logger:gain_gold({RoleID, 0, PayGold, ?GAIN_TYPE_GOLD_FROM_PAY, ""});
                       _ ->
                           db:write(?DB_ROLE_ATTR, RoleAttr#p_role_attr{is_payed=true}, write),
                           t_do_add_gold_online(OrderID, RoleID, PayGold)
                   end
           end,
    case db:transaction(Func) of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~p", ["补发玩家失败充值记录失败", Error])
    end.
    
