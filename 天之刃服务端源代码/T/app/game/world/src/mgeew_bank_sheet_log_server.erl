%%%-------------------------------------------------------------------
%%% @author LinRuirong <linruirong@mingchao.com>
%%% @copyright (C) 2011, mingchao.com
%%% @doc
%%%     记录玩家的挂单日日志
%%% @end
%%% Created : 2011-1-26
%%%-------------------------------------------------------------------
-module(mgeew_bank_sheet_log_server).
-behaviour(gen_server).


-export([start/0,
         start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeew.hrl").

%%任务状态:
-define(LOG_STATE_TRADING, 1). %%挂单中
-define(LOG_STATE_FINISH, 2). %%已经完成交易
-define(LOG_STATE_CANCEL, 3). %%已经撤单

%%挂单类型：
-define(LOG_BAND_SHEET_TYPE_SELL, 0).  %%卖单
-define(LOG_BAND_SHEET_TYPE_BUY, 1). %%求购单

%%定时发消息进行持久化
-define(DUMP_INTERVAL, 15 * 1000).
-define(LOG_QUEUE, log_queue).
-define(MSG_DUMP_LOG, dump_bank_sheet_log).



%% ====================================================================
%% API functions
%% ====================================================================



%% ====================================================================
%% External functions
%% ====================================================================

start() ->
    {ok,_} = supervisor:start_child(mgeew_sup, 
                           {?MODULE, 
                            {?MODULE, start_link,[]},
                            permanent, brutal_kill, worker, [?MODULE]}).
    

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [],[]).

init([]) ->
    erlang:send_after(?DUMP_INTERVAL, self(), ?MSG_DUMP_LOG),
    {ok, []}.
 
 
%% ====================================================================
%% Server functions
%%      gen_server callbacks
%% ====================================================================
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


%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

%%新挂单记录
do_handle_info({log_band_sheet_new,{SheetID,RoleID,Price,Num,Type}})->
	Silver = Price * Num,
	CurrentNum = Num,
	CurrentSilver = Silver,
	State = ?LOG_STATE_TRADING,
	CreateTime = common_tool:now(),
	UpdateTime = common_tool:now(),
	Sql = io_lib:format(" INSERT INTO t_log_bank_sheet(`sheet_id`,`role_id`,`price`,`num`,`silver`,`current_num`,`current_silver`,`type`,`state`,`create_time`,`update_time`)VALUES(~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w); ",[SheetID,RoleID,Price,Num,Silver,CurrentNum,CurrentSilver,Type,State,CreateTime,UpdateTime]),
	do_write_queue(Sql),
	ok;

%%挂单交易记录
do_handle_info({log_band_sheet_trade,{SheetID,Price,CurrentNum,TradeNum,RoleID,Type,IsFinished}})->
	if
		IsFinished =:= true ->
			State = ?LOG_STATE_FINISH;
		true ->
	  		State = ?LOG_STATE_TRADING
	end,
	CurrentSilver = Price * CurrentNum,
	TradeSilver = Price * TradeNum,
	Time = common_tool:now(),
	Sql = io_lib:format(" UPDATE t_log_bank_sheet set `current_num`=~w, `current_silver`=~w, `state`=~w, `update_time`=~w where `sheet_id`=~w; ",[CurrentNum,CurrentSilver,State,Time,SheetID]),
	do_write_queue(Sql),
	Sql2 = io_lib:format(" INSERT INTO t_log_bank_sheet_deal(`sheet_id`, `type`, `role_id`, `price`, `num`, `silver`, `mtime`)VALUES(~w, ~w, ~w, ~w, ~w, ~w, ~w);",[SheetID, Type, RoleID, Price, TradeNum, TradeSilver, Time]),
	do_write_queue(Sql2),
	ok;

%%撤消挂单交易记录
do_handle_info({log_band_sheet_cancel,SheetID})->
	Sql = io_lib:format(" UPDATE t_log_bank_sheet set `state`=~w where `sheet_id`=~w; ",[?LOG_STATE_CANCEL,SheetID]),
	do_write_queue(Sql),
	ok;

do_handle_info(?MSG_DUMP_LOG)->
    case get(?LOG_QUEUE) of
        undefined-> ignore;
        [] -> ignore;
        Queues ->
            do_dump_bank_sheet_logs( lists:reverse(Queues) )
    end,
    erlang:send_after(?DUMP_INTERVAL, self(), ?MSG_DUMP_LOG);


do_handle_info(Info)->
    ?ERROR_MSG("receive unknown message,Info=~w",[Info]),
    ignore.


do_write_queue(Sql) ->
	?DEBUG("reaven haha======= do_write_queue , SQL==~s",[Sql]),
	case get(?LOG_QUEUE) of
     	undefined->
           	put( ?LOG_QUEUE,[ Sql ] );
       	Queues->
        	put( ?LOG_QUEUE,[ Sql|Queues ] )
    end.

do_dump_bank_sheet_logs(Queues)->
	?DEBUG("Queues === ~w",[Queues]),
    %%批量插入的数据，目前最大不能超过3M
    [ do_insert(SQL) || SQL <- Queues ],
    %%插入成功之后，再修改进程字典
    put(?LOG_QUEUE,[]).

	
do_insert(SQL)->
	?DEBUG("reaven haha======= log_bank_sheet do_insert SQL==~s",[SQL]),
	try
        case mod_mysql:insert(SQL) of
            {error,Error}->
                erlang:throw({error,Error});
            _ -> ok
        end
    catch
        _:Reason->
            ?ERROR_MSG("持久化挂单日志出错,Reason=~w,SQL=~s    stacktrace=~w",[Reason,SQL,erlang:get_stacktrace()])
    end.
	

    
    
    
 


