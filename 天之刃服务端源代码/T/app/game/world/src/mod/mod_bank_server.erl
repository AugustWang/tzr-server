%%% -------------------------------------------------------------------
%%% Author  : Luo.JCheng
%%% Description :
%%%
%%% Created : 2010-7-9
%%% -------------------------------------------------------------------
-module(mod_bank_server).

-behaviour(gen_server).

-include("mgeew.hrl").  
-include("bank_server.hrl").

-export([
         start_link/0, 
         start/0,
         get_seller_notice/4
        ]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([do_undo_after_reply/3,
         do_buy_after_map_reply/3,
         do_buyed_after_reply/3,
         do_sell_after_map_reply/3,
         do_selled_after_reply/3,
         do_time_over_after_reply/3]).

-record(bank_state, {}).

%% 金钱操作计数
-define(MONEY_OPERATE_COUNTER, money_operate_counter).
%% 聊天频道消息广播
-define(BUY_REQUEST_BROADCAST, "<font color=\"#ffffff\">有人在钱庄挂单以（~w两银子/每元宝）价格求购元宝，需要银子的人可以到钱庄去看看！</font>").
-define(SELL_REQUEST_BROADCAST, "<font color=\"#ffffff\">有人在钱庄挂单以（~w两银子/每元宝）价格出售元宝，需要元宝的人可以到钱庄去看看！</font>").

start() ->
    {ok, _} = supervisor:start_child(mgeew_sup, 
                                     {?MODULE,
                                      {?MODULE, start_link, []},
                                      transient, brutal_kill, worker, [?MODULE]
                                     }).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({global, ?SERVER}, ?MODULE, [], []).

init([]) ->
    %% 重置金钱操作计数
    put(?MONEY_OPERATE_COUNTER, 1),
    %% 钱庄1秒循环
    erlang:send_after(1000, self(), bank_loop),
    %% 钱庄初始化
    init_bank_server(),
    {ok, #bank_state{}}.

handle_call(_Request, _From, State) ->
    Reply = ok,

    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(Info, State) ->
    ?DO_HANDLE_INFO(Info,State),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%%===================================================================

do_handle_info({Unique, Module, ?BANK_INIT, DataIn, RoleID, _PID, Line}) ->
    do_init(Unique, Module, ?BANK_INIT, DataIn, RoleID, Line);
do_handle_info({Unique, Module, ?BANK_BUY, DataIn, RoleID, _PID, Line}) ->
    do_buy(Unique, Module, ?BANK_BUY, DataIn, RoleID, Line);
do_handle_info({Unique, Module, ?BANK_SELL, DataIn, RoleID, _PID, Line}) ->
    do_sell(Unique, Module, ?BANK_SELL, DataIn, RoleID, Line);
do_handle_info({Unique, Module, ?BANK_UNDO, DataIn, RoleID, _PID, Line}) ->
    do_undo(Unique, Module, ?BANK_UNDO, DataIn, RoleID, Line);

%% 挂单到期
do_handle_info({sheet_time_over, SheetID}) ->
    sheet_time_over(SheetID);
%% 金钱变动成功返回
do_handle_info({?CHANGE_ROLE_MONEY_SUCC, RoleID, EventID,  RoleAttr, OperateID}) ->
    case get({money_operate, RoleID, OperateID}) of
        undefined ->
            ignore;
        {Method, Args} ->
            erase({money_operate, RoleID, OperateID}),
            ?MODULE:Method(Args, EventID, RoleAttr)
    end;
%% 金钱变动失败返回
do_handle_info({?CHANGE_ROLE_MONEY_FAILED, RoleID, EventID, Reason, OperateID}) ->
    %% 清掉日志
    common_role_money:erase_event(EventID),
    case get({money_operate, RoleID, OperateID}) of
        undefined ->
            ignore;
        {Method, Args} ->
            erase({money_operate, RoleID, OperateID}),
            ?MODULE:Method(Args, Reason, EventID)
    end;
%% 解锁挂单
do_handle_info({unlock_sheet, Type, Price}) ->
    unlock_sheet_and_get_next_request(Type, Price);
%% 1S循环
do_handle_info(bank_loop) ->
    erlang:send_after(1000, self(), bank_loop),
    %% 检查是否有请求超时了
    check_request_timeout();

do_handle_info(Info) ->
    ?ERROR_MSG("mod_bank_server, unknow info: ~w", [Info]).

%% @doc 初始化钱庄列表，客户端亦会定时请求
do_init(Unique, Module, Method, _DataIn, RoleID, Line) ->
    %% 个人列表
    {ok, SelfBuy, SelfSell} = get_bank_self_list(RoleID),
    %% 总列表
    {ok, BuyList, SellList} = get_bank_list(),
    %% 返回
    DataRecord = #m_bank_init_toc{
      succ = true,
      bank_sell = SellList,
      bank_buy = BuyList,
      self_sell = SelfSell,
      self_buy = SelfBuy
     },
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

%% @doc 购买元宝
do_buy(Unique, Module, Method, DataIn, RoleID, Line) ->
    #m_bank_buy_tos{price=Price} = DataIn,
    %% 判断挂单是否被锁住了、等待队伍不为空，是的话排队
    case if_sheet_lock(buy, Price) orelse (not if_waiting_queue_empty(buy, Price)) of
        true ->
            %% 插入等待队列
            insert_into_waiting_queue(buy, buy, Price, {Unique, Module, Method, DataIn, RoleID, Line});
        _ ->
            do_buy2({Unique, Module, Method, DataIn, RoleID, Line})
    end.

do_buy2({Unique, Module, Method, DataIn, RoleID, Line}) ->
    #m_bank_buy_tos{price=Price, num=Num} = DataIn,
    %% 安全过滤
    Price2 = abs(Price),
    Num2 = abs(Num),
    case Price2 =:= 0 orelse Num2 =:= 0 of
        true ->
            do_buy_error(Unique, Module, Method, RoleID, ?_LANG_BANK_ILLEGAL_INPUT, Line);
        _ ->
            %% 先购买钱庄已有的，有不足的话则挂单
            case db:dirty_read(?DB_BANK_SELL, Price2) of
                [] ->
                    do_buy3(Unique, Module, Method, RoleID, Price, 0, Num, undefined, Line);
                [#r_bank_sell{num=TotalNum}=BankSell] ->
                    case TotalNum >= Num of
                        true ->
                            do_buy3(Unique, Module, Method, RoleID, Price, Num, 0, BankSell, Line);
                        _ ->
                            do_buy3(Unique, Module, Method, RoleID, Price, TotalNum, Num-TotalNum, BankSell, Line)
                    end
            end
    end.

%% BuyNum: 钱庄当前能够买的数量，RestNum: 不足的量
do_buy3(Unique, Module, Method, RoleID, Price, BuyNum, RestNum, BankSell, Line) ->
    case check_can_request(RoleID, RestNum, true) of
        ok ->
            %% 把该价格锁住
            lock_sheet(buy, Price),
            %% 发消息到地图做钱操作
            {ok, OperateID} = get_money_operate_id(),
            ChangeList = [{reduce_silver, common_tool:ceil(Price*(BuyNum+RestNum)), ?CONSUME_TYPE_SILVER_BUY_GOLD_FROM_BANK, ""},
                          {reduce_silver, common_tool:ceil(Price*(BuyNum+RestNum)*?RATES), ?CONSUME_TYPE_SILVER_FEE_BUY_GOLD_FROM_BANK, ""},
                          {add_gold, BuyNum, ?GAIN_TYPE_GOLD_BUY_FROM_BANK, ""}],
            common_role_money:change(RoleID, {buy, Price, BuyNum, RestNum}, ChangeList, OperateID, OperateID),
            %% 将相关参数压到进程字典
            put({money_operate, RoleID, OperateID}, {do_buy_after_map_reply,
                                                     {Unique, Module, Method, RoleID, Price, BuyNum, RestNum, BankSell, Line}});
        {error, Reason} ->
            do_buy_error(Unique, Module, Method, RoleID, Reason, Line)
    end.

do_buy_after_map_reply({Unique, Module, Method, RoleID, Price, BuyNum, RestNum, BankSell, Line}, EventID, RoleAttr) when is_integer(EventID) ->
    case get_sheet_used_buy(BankSell, BuyNum) of
        {ok, SheetUse} ->
            do_buy_after_map_reply2(Unique, Module, Method, RoleID, Price, BuyNum, RestNum, SheetUse, Line, EventID, RoleAttr);
        {error, Reason} ->
            do_buy_error(Unique, Module, Method, RoleID, Reason, Line)
    end,
    %% 取出下一个请求
    unlock_sheet_and_get_next_request(buy, Price);
do_buy_after_map_reply({Unique, Module, Method, RoleID, Price, _BuyNum, _RestNum, _BankSell, Line}, _EventID, Reason) ->
    do_buy_error(Unique, Module, Method, RoleID, Reason, Line),
    unlock_sheet_and_get_next_request(buy, Price).

do_buy_after_map_reply2(Unique, Module, Method, RoleID, Price, BuyNum, RestNum, SheetUse, Line, EventID, RoleAttr) ->
    case db:transaction(
           fun() ->
                   t_do_buy(RoleID, Price, RestNum, SheetUse)
           end)
    of
        {atomic, {ok, Sheet}} ->
            %% 删掉事件
            common_role_money:erase_event(EventID),
            %% 给相应的单给钱
            lists:foreach(
              fun({SheetInfo, UseNum}) ->
                      #p_bank_sheet{roleid=TargetID, sheet_id=SheetID, num=Num} = SheetInfo,
                      {ok, OperateID} = get_money_operate_id(),
                      %% 给挂单的玩家银两
                      ChangeList = [{add_silver, common_tool:ceil(Price*UseNum), ?GAIN_TYPE_SILVER_FROM_BANK, ""},
                                    {reduce_silver, common_tool:ceil(Price*UseNum*?RATES), ?CONSUME_TYPE_SILVER_FEE_BUY_GOLD_FROM_BANK,
                                     ""}],
                      common_role_money:change(TargetID, {buyed, SheetInfo, UseNum}, ChangeList, OperateID, OperateID),
                      put({money_operate, TargetID, OperateID}, {do_buyed_after_reply, {SheetInfo, UseNum}}),
                      %% 去掉单过期的定时
                      case get({time_over_ref, SheetID}) of
                          undefined ->
                              ok;
                          TimerRef ->
                              erlang:cancel_timer(TimerRef)
                      end,
                      %% 交易日志
                      catch global:send(mgeew_bank_sheet_log_server, {log_band_sheet_trade,
                                                                      {SheetID, Price, Num-UseNum, UseNum, TargetID, true, Num=:=UseNum}})
              end, SheetUse),
            %% 如果有挂单的话
            case Sheet of
                undefined ->
                    ignore;
                _ ->
                    %% 定时挂单过期
                    #p_bank_sheet{sheet_id=SheetID} = Sheet,
                    TimerRef = erlang:send_after(?TIME_DIFF*1000, self(), {sheet_time_over, SheetID}),
                    put({time_over_ref, SheetID}, TimerRef),

                    %% 如果挂单数量超过了100，则在世界频道广播
                    case RestNum >= 100 of
                        true ->
                            Msg = lists:flatten(io_lib:format(?BUY_REQUEST_BROADCAST, [Price div 100])),
                            common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT, ?BC_MSG_TYPE_CHAT_WORLD, Msg),
                            ok;
                        _ ->
                            ignore
                    end,
                    
                    %% 挂单日志
                    catch global:send(mgeew_bank_sheet_log_server, {log_band_sheet_new, {SheetID, RoleID, Price, RestNum, true}})
            end,
            %%
            #p_role_attr{silver=Silver, gold=Gold} = RoleAttr,
            DataRecord = #m_bank_buy_toc{num=BuyNum, price=Price, silver=Silver, gold=Gold, sheet=Sheet},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord),
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("do_buy_after_map_reply2, error: ~w", [Error]),
            do_buy_error(Unique, Module, Method, RoleID, ?_LANG_SYSTEM_ERROR, Line)
    end.

t_do_buy(RoleID, Price, RestNum, SheetUse) ->
    case RestNum > 0 of
        true ->
            %% 创建一个新的单
            SheetID = t_get_last_sheet_id(),
            Sheet = #p_bank_sheet{sheet_id=SheetID, roleid=RoleID, price=Price, num=RestNum,
                                  type=true, time=common_tool:now()},
            db:write(?DB_BANK_SHEETS, Sheet, write),
            %% 更新求购表
            case db:read(?DB_BANK_BUY, Price, read) of
                [] ->
                    BankBuy = #r_bank_buy{price=Price, sheet_id=[SheetID], num=RestNum},
                    db:write(?DB_BANK_BUY, BankBuy, write);

                [BankBuy] ->
                    #r_bank_buy{sheet_id=BuySheetList, num=TotalBuyNum} = BankBuy,

                    BankBuy2 = BankBuy#r_bank_buy{sheet_id=[SheetID|BuySheetList], num=TotalBuyNum+RestNum},
                    db:write(?DB_BANK_BUY, BankBuy2, write)
            end;
        _ ->
            Sheet = undefined
    end,
    %% 更新求售表
    lists:foreach(
      fun({SheetBuy, UseNum}) ->
              t_update_sheet(sell, SheetBuy, Price, UseNum)
      end, SheetUse),
    
    {ok, Sheet}.

do_buy_error(Unique, Module, Method, RoleID, Reason, Line) ->
    DataRecord = #m_bank_buy_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

do_buyed_after_reply({SheetInfo, UseNum}, EventID, RoleAttr) when is_integer(EventID) ->
    common_role_money:erase_event(EventID),
    %% 通知挂单玩家
    notice_seller(RoleAttr#p_role_attr.role_id, {SheetInfo, UseNum}, true, true);
do_buyed_after_reply(_, Reason, _EventID) ->
    ?ERROR_MSG("do_buyed_after_reply, reaosn: ~w", [Reason]).

%% @doc 出售元宝
do_sell(Unique, Module, Method, DataIn, RoleID, Line) ->
    #m_bank_sell_tos{price=Price} = DataIn,
    %% 判断挂单是否被锁住了、等待队伍不为空，是的话排队
    case if_sheet_lock(sell, Price) orelse (not if_waiting_queue_empty(sell, Price)) of
        true ->
            insert_into_waiting_queue(sell, sell, Price, {Unique, Module, Method, DataIn, RoleID, Line});
        _ ->
            do_sell2({Unique, Module, Method, DataIn, RoleID, Line})
    end.
do_sell2({Unique, Module, Method, DataIn, RoleID, Line}) ->
    #m_bank_sell_tos{price=Price, num=Num} = DataIn,
    %% 输入过滤
    Price2 = abs(Price),
    Num2 = abs(Num),
    case Price2 =:= 0 orelse Num2 =:= 0 of
        true ->
            do_sell_error(Unique, Module, Method, RoleID, ?_LANG_BANK_ILLEGAL_INPUT, Line);
        _ ->
            case db:dirty_read(?DB_BANK_BUY, Price) of
                [] ->
                    do_sell3(Unique, Module, Method, RoleID, Price, 0, Num, undefined, Line);
                [#r_bank_buy{num=TotalNum}=BankBuy] ->
                    case TotalNum >= Num of
                        true ->
                            do_sell3(Unique, Module, Method, RoleID, Price, Num, 0, BankBuy, Line);
                        _ ->
                            do_sell3(Unique, Module, Method, RoleID, Price, TotalNum, Num-TotalNum, BankBuy, Line)
                    end
            end
    end.
do_sell3(Unique, Module, Method, RoleID, Price, SellNum, RestNum, BankSell, Line) ->
    %% 判断是否能够挂单
    case check_can_request(RoleID, RestNum, false) of
        ok ->
            %% 锁住价格
            lock_sheet(sell, Price),
            %% 发消息到地图做钱操作
            {ok, OperateID} = get_money_operate_id(),
            ChangeList = [{add_silver, common_tool:ceil(Price*SellNum), ?GAIN_TYPE_SILVER_FROM_BANK, ""},
                          {reduce_silver, common_tool:ceil(Price*SellNum*?RATES), ?CONSUME_TYPE_SILVER_FEE_BUY_GOLD_FROM_BANK, 
                           ""},
                          {reduce_gold, SellNum+RestNum, ?CONSUME_TYPE_GOLD_SELL_FROM_BANK, ""}],
            common_role_money:change(RoleID, {sell, Price, SellNum, RestNum}, ChangeList, OperateID, OperateID),
            %% 将相关参数压到进程字典
            put({money_operate, RoleID, OperateID}, {do_sell_after_map_reply,
                                                     {Unique, Module, Method, RoleID, Price, SellNum, RestNum, BankSell, Line}});
        {error, Reason} ->
            do_sell_error(Unique, Module, Method, RoleID, Reason, Line)
    end.

do_sell_after_map_reply({Unique, Module, Method, RoleID, Price, SellNum, RestNum, BankBuy, Line}, EventID, RoleAttr) when is_integer(EventID) ->
    case get_sheet_used_sell(BankBuy, SellNum) of
        {ok, SheetUse} ->
            do_sell_after_map_reply2(Unique, Module, Method, RoleID, Price, SellNum, RestNum, SheetUse, Line, EventID, RoleAttr);
        {error, Reason} ->
            do_sell_error(Unique, Module, Method, RoleID, Reason, Line)
    end,
    %% 取出下一个请求
    unlock_sheet_and_get_next_request(sell, Price);
do_sell_after_map_reply({Unique, Module, Method, RoleID, Price, _SellNum, _RestNum, _BankBuy, Line}, Reason, _EventID) ->
    do_sell_error(Unique, Module, Method, RoleID, Reason, Line),
    unlock_sheet_and_get_next_request(sell, Price).
        
do_sell_after_map_reply2(Unique, Module, Method, RoleID, Price, SellNum, RestNum, SheetUse, Line, EventID, RoleAttr) ->
    case db:transaction(
           fun() ->
                   t_do_sell(RoleID, Price, RestNum, SheetUse)
           end)
    of
        {atomic, {ok, Sheet}} ->
            common_role_money:erase_event(EventID),
            lists:foreach(
              fun({SheetInfo, UseNum}) ->
                      #p_bank_sheet{roleid=TargetID, sheet_id=SheetID, num=Num} = SheetInfo,
                      {ok, OperateID} = get_money_operate_id(),
                      %% 给挂单的玩家银两
                      ChangeList = [{add_gold, UseNum, ?GAIN_TYPE_GOLD_BUY_FROM_BANK, ""}],
                      common_role_money:change(TargetID, {selled, SheetInfo, UseNum}, ChangeList, OperateID, OperateID),
                      put({money_operate, TargetID, OperateID}, {do_selled_after_reply, {SheetInfo, UseNum}}),
                      %% 清掉过期定时
                      case get({time_over_ref, SheetID}) of
                          undefined ->
                              ok;
                          TimerRef ->
                              erlang:cancel_timer(TimerRef)
                      end,
                      %% 交易日志
                      catch global:send(mgeew_bank_sheet_log_server, {log_band_sheet_trade,
                                                                      {SheetID, Price, Num-UseNum, UseNum, TargetID, false, Num=:=UseNum}})
              end, SheetUse),
            %% 如果有挂单
            case RestNum > 0 of
                true ->
                    %% 挂单定时过期
                    #p_bank_sheet{sheet_id=SheetID} = Sheet,
                    TimerRef = erlang:send_after(?TIME_DIFF*1000, self(), {sheet_time_over, SheetID}),
                    put({time_over_ref, SheetID}, TimerRef),
                    %% 如果挂单数量超过了100，则在世界频道广播
                    case RestNum >= 100 of
                        true ->
                            Msg = lists:flatten(io_lib:format(?SELL_REQUEST_BROADCAST, [Price div 100])),
                            common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT, ?BC_MSG_TYPE_CHAT_WORLD, Msg),
                            ok;
                        _ ->
                            ignore
                    end,
                    %% 挂单日志
                    catch global:send(mgeew_bank_sheet_log_server, {log_band_sheet_new, {SheetID, RoleID, Price, RestNum, false}});
                _ ->
                    ignore
            end,
            %%
            #p_role_attr{silver=Silver, gold=Gold} = RoleAttr,
            DataRecord = #m_bank_sell_toc{num=SellNum, price=Price, silver=Silver, gold=Gold, sheet=Sheet},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord),
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("do_sell_after_map_reply2, error: ~w", [Error]),
            do_sell_error(Unique, Module, Method, RoleID, ?_LANG_SYSTEM_ERROR, Line)
    end.

t_do_sell(RoleID, Price, RestNum, SheetUse) ->
    %% 创建一个新的单
    case RestNum > 0 of
        true ->
            SheetID = t_get_last_sheet_id(),
            Sheet = #p_bank_sheet{sheet_id=SheetID, roleid=RoleID, price=Price, num=RestNum,
                                  type=false, time=common_tool:now()},
            db:write(?DB_BANK_SHEETS, Sheet, write),
            %% 更新求售表
            case db:read(?DB_BANK_SELL, Price, read) of
                [] ->
                    SheetSell = #r_bank_sell{price=Price, sheet_id=[SheetID], num=RestNum},
                    db:write(?DB_BANK_SELL, SheetSell, write);

                [SheetSell] ->
                    #r_bank_sell{sheet_id=SheetList, num=TotalNum} = SheetSell,
                    SheetSell2 = SheetSell#r_bank_sell{sheet_id=[SheetID|SheetList], num=TotalNum+RestNum},
                    db:write(?DB_BANK_SELL, SheetSell2, write)
            end;
        _ ->
            Sheet = undefined
    end,
    %% 更新求购表
    lists:foreach(
      fun({SheetInfo, UseNum}) ->
              t_update_sheet(buy, SheetInfo, Price, UseNum)
      end, SheetUse),

    {ok, Sheet}.

do_sell_error(Unique, Module, Method, RoleID, Reason, Line) ->
    DataRecord = #m_bank_sell_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

do_selled_after_reply({SheetInfo, UseNum}, EventID, RoleAttr) when is_integer(EventID) ->
    common_role_money:erase_event(EventID),
    %% 通知挂单玩家
    notice_buyer(RoleAttr#p_role_attr.role_id, {SheetInfo, UseNum}, true, true);
do_selled_after_reply(_, Reason, _EventID) ->
    ?ERROR_MSG("do_buyed_after_reply, reaosn: ~w", [Reason]).

%% @doc 撤消挂单
do_undo(Unique, Module, Method, DataIn, RoleID, Line) ->
    #m_bank_undo_tos{sheet_id=SheetID} = DataIn,
    case get_sheet_info(SheetID) of
        {error, Reason} ->
            do_undo_error(Unique, Module, Method, RoleID, Reason, Line);
        SheetInfo ->
            #p_bank_sheet{type=Type, price=Price} = SheetInfo,
            %% 判断价格是否被锁住了，如果是买单的话就锁卖的价格
            case Type of
                true ->
                    LockType = sell;
                _ ->
                    LockType = buy
            end,
            %%
            case if_sheet_lock(LockType, Price) orelse (not if_waiting_queue_empty(LockType, Price)) of
                true ->
                    insert_into_waiting_queue(LockType, undo, Price, {Unique, Module, Method, SheetInfo, RoleID, Line});
                _ ->
                    do_undo2({Unique, Module, Method, SheetInfo, RoleID, Line})
            end
    end.

do_undo2({Unique, Module, Method, SheetInfo, RoleID, Line}) ->
    #p_bank_sheet{sheet_id=SheetID, type=Type, price=Price, num=Num} = SheetInfo,

    case db:transaction(
           fun() ->
                   case Type of
                       true ->
                           t_update_sheet(buy, SheetInfo, Price, Num);
                       _ ->
                           t_update_sheet(sell, SheetInfo, Price, Num)
                   end
           end)
    of
        {atomic, _} ->
            %% 取消到期的计时
            case get({time_over_ref, SheetID}) of
                undefined ->
                    ok;
                TimerRef ->
                    erlang:cancel_timer(TimerRef)
            end,
            %% 发消息到地图返回银两或元宝
            %% 获取该操作的ID
            {ok, OperateID} = get_money_operate_id(),
            %% 发消息到地图，扣除银两
            case Type of
                true ->
                    ChangeList = [{add_silver, common_tool:ceil(Price*Num), ?GAIN_TYPE_SILVER_UNDO_BANK_BUY, ""}];
                _ ->
                    ChangeList = [{add_gold, Num, ?GAIN_TYPE_GOLD_UNDO_BANK_SELL, ""}]
            end,
            common_role_money:change(RoleID, {undo, SheetInfo}, ChangeList, OperateID, OperateID),
            %% 撤消日志
            catch global:send(mgeew_bank_sheet_log_server, {log_band_sheet_cancel, SheetID}),
            %% 把相关参数压到进入字典
            put({money_operate, RoleID, OperateID}, {do_undo_after_reply, {Unique, Module, Method, SheetInfo, RoleID, Line}});

        {aborted, R} ->
            ?ERROR_MSG("do_undo3, error: ~w", [R]),
            do_undo_error(Unique, Module, Method, RoleID, ?_LANG_SYSTEM_ERROR, Line)
    end.

do_undo_after_reply({Unique, Module, Method, SheetInfo, RoleID, Line}, EventID, _RoleAttr) when is_integer(EventID) ->
    common_role_money:erase_event(EventID),
    #p_bank_sheet{type=Type, price=Price, num=Num} = SheetInfo,

    case Type of
        true ->
            ReturnBack=Price*Num;
        false ->
            ReturnBack=Num
    end,

    DataRecord = #m_bank_undo_toc{succ=true, return_back=ReturnBack},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord);

do_undo_after_reply({Unique, Module, Method, _SI, RoleID, Line}, Reason, _EventID) ->
    do_undo_error(Unique, Module, Method, RoleID, Reason, Line).

do_undo_error(Unique, Module, Method, RoleID, Reason, Line) ->
    {ok, BuyList, SellList} = get_bank_self_list(RoleID),
    {ok, BankBuy, BankSell} = get_bank_list(),

    DataRecord = #m_bank_undo_toc{succ = false, reason = Reason, self_sell = SellList, self_buy = BuyList,
                                  bank_sell = BankSell, bank_buy = BankBuy},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

t_update_sheet(sell, SheetInfo, Price, N) ->
    #p_bank_sheet{num=Num, sheet_id=SheetID} = SheetInfo,

    case N =:= Num of
        true ->
            db:delete(?DB_BANK_SHEETS, SheetID, write),
            t_update_bank_sell(Price, SheetID, Num, true);
        false ->
            db:write(?DB_BANK_SHEETS, SheetInfo#p_bank_sheet{num=Num-N}, write),
            t_update_bank_sell(Price, SheetID, N, false)
    end;
t_update_sheet(buy, SheetInfo, Price, N) ->
    #p_bank_sheet{num=Num, sheet_id=SheetID} = SheetInfo,
    case N =:= Num of
        true ->
            db:delete(?DB_BANK_SHEETS, SheetID, write),
            t_update_bank_buy(Price, SheetID, Num, true);
        false ->
            db:write(?DB_BANK_SHEETS, SheetInfo#p_bank_sheet{num=Num-N}, write),
            t_update_bank_buy(Price, SheetID, N, false)
    end.

%%更新卖单，type, true, 删除, false, 减少
t_update_bank_sell(Price, SheetID, N, Type) ->
    [BankSell] = db:read(?DB_BANK_SELL, Price),

    SheetList = BankSell#r_bank_sell.sheet_id,
    Num = BankSell#r_bank_sell.num,

    case Num =:= N of
        true ->
            db:delete(?DB_BANK_SELL, Price, write);

        false ->
            case Type of
                false ->
                    BankSell2 = BankSell#r_bank_sell{num=Num-N};
                true ->
                    NewList = lists:delete(SheetID, SheetList),
                    BankSell2 = BankSell#r_bank_sell{sheet_id=NewList, num=Num-N}
            end,
            db:write(?DB_BANK_SELL, BankSell2, write)
    end.

t_update_bank_buy(Price, SheetID, Num, Type) ->
    [BankBuy] = db:read(?DB_BANK_BUY, Price),
    SheetList = BankBuy#r_bank_buy.sheet_id,
    N = BankBuy#r_bank_buy.num,
    case Num =:= N of
        true ->
            db:delete(?DB_BANK_BUY, Price, write);
        false ->
            NewRecord =
                case Type of
                    false ->
                        BankBuy#r_bank_buy{num = N - Num};
                    true ->
                        NewList = lists:delete(SheetID, SheetList),
                        BankBuy#r_bank_buy{sheet_id = NewList, num = N - Num}
                end,
            db:write(?DB_BANK_BUY, NewRecord, write)
    end.

%% @doc 获取个人挂单
get_bank_self_list(RoleID) ->
    Pattern = #p_bank_sheet{roleid=RoleID, _='_'},
    SheetList = db:dirty_match_object(?DB_BANK_SHEETS, Pattern),
    %% 按价格排序
    SheetList2 = lists:keysort(#p_bank_sheet.price, SheetList),

    lists:foldl(
      fun(Record, {ok, Buy, Sell}) ->
              %% type: true ->买单; false -> 卖单
              #p_bank_sheet{type=Type} = Record,
              case Type of
                  true ->
                      {ok, [Record|Buy], Sell};
                  false ->
                      {ok, Buy, [Record|Sell]}
              end
      end, {ok, [], []}, SheetList2).

%% @doc 获取钱庄右侧总列表
get_bank_list() ->
    %% 卖表
    SellList = get_bank_sell_list(),
    %% 买表
    BuyList = get_bank_buy_list(),

    {ok, lists:reverse(BuyList), SellList}.

%% @doc 获取钱庄卖表，价格最低的8个
get_bank_sell_list() ->
    get_bank_sell_list2(db:dirty_first(?DB_BANK_SELL), [], 1).

get_bank_sell_list2('$end_of_table', SellList, _N) ->
    get_bank_sell_list3(SellList);
get_bank_sell_list2(_Key, SellList, 8) ->
    get_bank_sell_list3(SellList);
get_bank_sell_list2(Key, SellList, N) ->
    case db:dirty_read(?DB_BANK_SELL, Key) of
        [] ->
            SellList;
        [Value] ->
            NextKey = db:dirty_next(?DB_BANK_SELL, Key),
            get_bank_sell_list2(NextKey, [Value|SellList], N+1)
    end.

get_bank_sell_list3(SellList) ->
    lists:map(
      fun(Record) ->
              #p_bank_simple_sheet{price=Record#r_bank_sell.price, num=Record#r_bank_sell.num}
      end, SellList).

%% @doc 获取钱庄买表，价格最高的8个
get_bank_buy_list() ->
    get_bank_buy_list2(db:dirty_last(?DB_BANK_BUY), [], 1).

get_bank_buy_list2('$end_of_table', BuyList, _N) ->
    get_bank_buy_list3(BuyList);
get_bank_buy_list2(_Key, BuyList, 8) ->
    get_bank_buy_list3(BuyList);
get_bank_buy_list2(Key, BuyList, N) ->
    case db:dirty_read(?DB_BANK_BUY, Key) of
        [] ->
            BuyList;
        [Value] ->
            NextKey = db:dirty_prev(?DB_BANK_BUY, Key),
            get_bank_buy_list2(NextKey, [Value|BuyList], N+1)
    end.

get_bank_buy_list3(BuyList) ->
    lists:map(
      fun(Record) ->
              #p_bank_simple_sheet{price=Record#r_bank_buy.price, num=Record#r_bank_buy.num}
      end, BuyList).

%%获取最新的定单ID
t_get_last_sheet_id() ->
    case db:read(?DB_SHEET_COUNTER, 1, read) of
        [] -> 
            NewInfo = #r_sheet_counter{id=1, last_sheet_id=1},
            db:write(?DB_SHEET_COUNTER, NewInfo, write),
            1;

        [Info] ->
            LastID = Info#r_sheet_counter.last_sheet_id,
            NewInfo = Info#r_sheet_counter{last_sheet_id=LastID+1},
            db:write(?DB_SHEET_COUNTER, NewInfo, write),

            LastID+1
    end.

%% @doc 购买，获取会利用到的卖单
get_sheet_used_buy(undefined, _Num) ->
    {ok, []};
get_sheet_used_buy(BankSell, Num) ->
    SheetList = BankSell#r_bank_sell.sheet_id,
    get_sheet_used(SheetList, Num, []).

%% @doc 出售，获取会利用到的买单
get_sheet_used_sell(undefined, _Num) ->
    {ok, []};
get_sheet_used_sell(BankBuy, Num) ->
    SheetList = BankBuy#r_bank_buy.sheet_id,
    get_sheet_used(SheetList, Num, []).

%% @doc 获取用到的单
get_sheet_used(SheetList, Num, List) ->
    %% 取列表最后的一个ID，时间最早。。。
    SheetID = lists:last(SheetList),
    %% 获取单信息
    case get_sheet_info(SheetID) of
        {error, Reason} ->
            {error, Reason};
        SheetInfo ->
            N = SheetInfo#p_bank_sheet.num,
            %% 该单是否数量足够，不够的话再取下个单
            case N >= Num of
                true ->
                    {ok, [{SheetInfo, Num}|List]};
                false ->
                    NewSheetList = lists:delete(SheetID, SheetList),
                    get_sheet_used(NewSheetList, Num-N, [{SheetInfo, N}|List])
            end
    end.

get_sheet_info(SheetID) ->
    case db:dirty_read(?DB_BANK_SHEETS, SheetID) of
        [SheetInfo] ->
            SheetInfo;
        _ ->
            {error, ?_LANG_BANK_SHEET_NOT_EXIST}
    end.

%%通知出售者
%%sendletter：是否发送信件，过期的话不发送信件
notice_seller(RoleID, Sheet, Type, SendLetter) ->
    {SheetInfo, N} = Sheet,
    #p_bank_sheet{sheet_id=SheetID, roleid=TargetID, price=Price, num=Num} = SheetInfo,

    %%是否发送信件，过期取消的不发送信息
    case SendLetter of
        true ->
            Price = SheetInfo#p_bank_sheet.price,
            send_letter(TargetID, Price, Num, N, false);
        false ->
            ok
    end,

    %%通知客户端，type：true，别人买了元宝、false：卖单过期，退回银两
    DataRecord = #m_bank_add_silver_toc{silver=common_tool:ceil(Price*N*(1-?RATES)), type=Type, sheet_id=SheetID, num=(Num-N), if_self=(RoleID=:=TargetID)},
    common_misc:unicast({role, TargetID}, ?DEFAULT_UNIQUE, ?BANK, ?BANK_ADD_SILVER, DataRecord).

notice_buyer(RoleID, Sheet, Type, SendLetter) ->
    ?DEBUG("notice_buyer, sheet: ~w", [Sheet]),
    {SheetInfo, N} = Sheet,
    #p_bank_sheet{sheet_id=SheetID, roleid=TargetID, num=Num} = SheetInfo,

    %%是否发送信件
    case SendLetter of
        true ->
            Price = SheetInfo#p_bank_sheet.price,
            send_letter(TargetID, Price, Num, N, true);
        false ->
            ok
    end,

    DataRecord = #m_bank_add_gold_toc{gold=N, type=Type, sheet_id=SheetID, num=(Num-N), if_self=(RoleID=:=TargetID)},
    common_misc:unicast({role, TargetID}, ?DEFAULT_UNIQUE, ?BANK, ?BANK_ADD_GOLD, DataRecord).

%%type：true：通知买方、false：通知卖方
send_letter(RoleID, Price, Num, N, Type) ->     
    case catch db:dirty_read(?DB_ROLE_BASE, RoleID) of
        [RoleBase] ->
            RoleName = RoleBase#p_role_base.role_name,

            %%被出售亦或购买提示不同
            Notice =
                case Type of
                    true ->
                        Title = "成功出售银子信息通知",
                        common_letter:create_temp(?BANK_BUY_GOLD_LETTER,[RoleName, Num, Price div 100, N]);
                    false ->
                        Title = "成功出售元宝信息通知",
                        get_seller_notice(RoleName, Num, Price, N)
                end,
            %%发送信件
            common_letter:sys2p(RoleID, Notice, Title, 14);
        _ ->
            ok
    end.

%%悲剧的处理，暂时先这样吧。。。
get_seller_notice(RoleName, Num, Price, N) ->
    Silver = common_tool:ceil(Price*N*(1-?RATES)),
    %%Notice = io_lib:format(?SELLERNOTICE, [RoleName, Num, Price div 100, N]),
    Notice = "",
    Notice2 =
    case Silver div 10000 =:= 0 of
        true ->
            Notice;
        _ ->
            lists:append(Notice, io_lib:format("~w锭", [Silver div 10000]))
    end,
    Notice3 = 
    case Silver div 100 rem 100 =:= 0 of
        true ->
            Notice2;
        _ ->
            lists:append(Notice2, io_lib:format("~w两", [Silver div 100 rem 100]))
    end,
    Notice4 =
    case Silver rem 100 =:= 0 of
        true ->
            Notice3;
        _ ->
            lists:append(Notice3, io_lib:format("~w文", [Silver rem 100]))
    end,
    common_letter:create_temp(?BANK_SELL_GOLD_LETTER,[RoleName, Num, Price div 100, N, Notice4]).

%%钱庄初始化
init_bank_server() ->
    Pattern = #p_bank_sheet{_='_'},
    SheetList = db:dirty_match_object(?DB_BANK_SHEETS, Pattern),

    TimeNow = common_tool:now(),
    
    lists:foreach(
      fun(SheetInfo) ->
              init_bank_server2(SheetInfo, TimeNow)
      end, SheetList).

init_bank_server2(SheetInfo, TimeNow) ->
    #p_bank_sheet{sheet_id=SheetID, type=_Type, price=_Price, num=_Num, time=Time, roleid=_RoleID} = SheetInfo,
    
    %%是否过期
    case TimeNow-Time >= ?TIME_DIFF of
        true ->
            sheet_time_over2(SheetInfo);
        false ->
            erlang:send_after((?TIME_DIFF-TimeNow+Time)*1000, self(), {sheet_time_over, SheetID})
    end.

%% @doc 挂单过期
sheet_time_over(SheetID) ->
    case db:dirty_read(?DB_BANK_SHEETS, SheetID) of
        [] ->
            ignore;
        [SheetInfo] ->
            #p_bank_sheet{type=Type, price=Price} = SheetInfo,
            %% 判断价格是否被锁住了，如果是买单的话就锁卖的价格
            case Type of
                true ->
                    LockType = sell;
                _ ->
                    LockType = buy
            end,
            %%
            case if_sheet_lock(LockType, Price) orelse (not if_waiting_queue_empty(LockType, Price)) of
                true ->
                    insert_into_waiting_queue(LockType, time_over, Price, SheetInfo);
                _ ->
                    sheet_time_over2(SheetInfo)
            end
    end.

sheet_time_over2(SheetInfo) ->
    #p_bank_sheet{roleid=RoleID, type=Type, price=Price, num=Num} = SheetInfo,
    case db:transaction(
           fun() ->
                   case Type of
                       true ->
                           t_update_sheet(buy, SheetInfo, Price, Num);
                       _ ->
                           t_update_sheet(sell, SheetInfo, Price, Num)
                   end
           end)
    of
        {atomic, _} ->
            %% 获取该操作的ID
            {ok, OperateID} = get_money_operate_id(),
            %% 发消息到地图，扣除银两
            case Type of
                true ->
                    ChangeList = [{add_silver, common_tool:ceil(Price*Num), ?GAIN_TYPE_SILVER_UNDO_BANK_BUY, ""}];
                _ ->
                    ChangeList = [{add_gold, Num, ?GAIN_TYPE_GOLD_UNDO_BANK_SELL, ""}]
            end,
            common_role_money:change(RoleID, {time_over, SheetInfo}, ChangeList, OperateID, OperateID),
            %% 把相关参数压到进入字典
            put({money_operate, RoleID, OperateID}, {do_time_over_after_reply, {SheetInfo}});
        {aborted, R} ->
            ?ERROR_MSG("sheet_time_over2, r: ~w", [R])
    end.

do_time_over_after_reply({SheetInfo}, EventID, RoleAttr) when is_integer(EventID) ->
    common_role_money:erase_event(EventID),
    #p_bank_sheet{type=Type, num=Num} = SheetInfo,
    case Type of
        true ->
            notice_seller(RoleAttr#p_role_attr.role_id, {SheetInfo, Num}, false, false);
        false ->
            notice_buyer(RoleAttr#p_role_attr.role_id, {SheetInfo, Num}, false, false)
    end;

do_time_over_after_reply({_S}, Reason, _EventID) ->
    ?ERROR_MSG("do_time_over_after_reply, reason: ~w", [Reason]).

%% @doc 获取金钱操作计数
get_money_operate_id() ->
    C = get(?MONEY_OPERATE_COUNTER),
    put(?MONEY_OPERATE_COUNTER, C+1),

    {ok, C}.

%% @doc 挂单是否锁住了
if_sheet_lock(Type, Price) ->
    case get({Type, Price}) of
        undefined ->
            false;
        _ ->
            true
    end.

%% @doc 锁住挂单
lock_sheet(Type, Price) ->
    %% 5秒之后解锁
    TimerRef = erlang:send_after(5000, self(), {unlock_sheet, Type, Price}),
    put({Type, Price}, TimerRef).

%% @doc 放入等待队列
insert_into_waiting_queue(Type, Label, Price, Info) ->
    case get({waiting_queue, Type}) of
        undefined ->
            put({waiting_queue, Type}, [{Label, Price, Info, common_tool:now()}]);
        Queue ->
            put({waiting_queue, Type}, [{Label, Price, Info, common_tool:now()}|Queue])
    end.

%% @doc 解锁挂单并取出下个请求
unlock_sheet_and_get_next_request(Type, Price) ->
    TimerRef = get({Type, Price}),
    erlang:cancel_timer(TimerRef),
    erase({Type, Price}),
    
    case get({waiting_queue, Type}) of
        undefined ->
            ignore;
        [] ->
            ignore;
        Queue ->
            Queue2 = lists:reverse(Queue),
            case lists:keyfind(Price, 1, Queue2) of
                false ->
                    ignore;
                {Label, Price, Request, T} ->
                    Queue3 = lists:delete({Label, Price, Request, T}, Queue),
                    put({waiting_queue, Type}, Queue3),

                    case Label of
                        buy ->
                            do_buy2(Request);
                        sell ->
                            do_sell2(Request);
                        undo ->
                            do_undo2(Request);
                        _ ->
                            sheet_time_over2(Request)
                    end
            end
    end.

%% @doc 等待队列是否为空
if_waiting_queue_empty(Type, Price) ->
    case get({waiting_queue, Type}) of
        undefined ->
            true;
        [] ->
            true;
        Queue ->
            Queue2 = lists:filter(fun({_, P, _, _}) -> P =:= Price end, Queue),
            length(Queue2) =:= 0
    end.

%% @doc 检测是否有单超时
check_request_timeout() ->
    Now = common_tool:now(),
    check_request_timeout(buy, Now),
    check_request_timeout(sell, Now).

check_request_timeout(Type, Now) ->
    case get({waiting_queue, Type}) of
        undefined ->
            ignore;
        [] ->
            ignore;
        Queue ->
            lists:foreach(
              fun({Label, P, Request, Time}) ->
                      case Now - Time > 3 of
                          true ->
                              {Unique, Module, Method, _DataIn, RoleID, Line} = Request,
                              case Label of
                                  buy ->
                                      do_buy_error(Unique, Module, Method, RoleID, ?_LANG_BANK_REQUEST_TIMEOUT, Line),
                                      ok;
                                  sell ->
                                      do_sell_error(Unique, Module, Method, RoleID, ?_LANG_BANK_REQUEST_TIMEOUT, Line),
                                      ok;
                                  undo ->
                                      do_undo_error(Unique, Module, Method, RoleID, ?_LANG_BANK_REQUEST_TIMEOUT, Line),
                                      ok;
                                  _ ->
                                      ok
                              end,
                              %% 从队列中删除
                              put({waiting_queue, Type}, lists:delete({Label, P, Request, Time}, Queue));
                          _ ->
                              ignore
                      end
              end, Queue)
    end.

-define(max_sheet_num, 5).

%% @doc 判断是否能挂单
check_can_request(RoleID, RequestNum, Type) ->
    case RequestNum > 0 of
        true ->
            SheetList = db:dirty_match_object(?DB_BANK_SHEETS, #p_bank_sheet{roleid=RoleID, type=Type, _='_'}),

            case length(SheetList) >= ?max_sheet_num of
                true ->
                    case Type of
                        true ->
                            {error, ?_LANG_BANK_BUY_MORE_THAN_FIVE};
                        _ ->
                            {error, ?_LANG_BANK_SELL_MORE_THAN_FIVE}
                    end;
                _ ->
                    ok
            end;
        _ ->
            ok
    end.
