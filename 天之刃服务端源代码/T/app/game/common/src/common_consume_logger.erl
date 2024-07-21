%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     记录游戏中的消费日志，该接口必须是事务内调用
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(common_consume_logger).


%% API
-export([use_silver/1,use_gold/1,gain_silver/1,gain_gold/1]).

-export([on_transaction_begin/0, on_transaction_commit/0, on_transaction_rollback/0]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common.hrl").
-include("activity.hrl").
-define(CONSUME_LOG_LIST, consume_log_list).


%% ====================================================================
%% API Functions
%% ====================================================================

on_transaction_begin() ->
    case erlang:get(?CONSUME_LOG_LIST) of
        undefined ->
            erlang:put(?CONSUME_LOG_LIST, []);
        _ ->
            %% 防止重复调用这个方法，也能防止这个模块的三个事务接口没有一起调用
            erlang:throw(consume_log_transaction_error)
    end.

on_transaction_commit() ->
    case erlang:get(?CONSUME_LOG_LIST) of
        undefined->
            ignore;
        []->
            ignore;
        Val ->
            send_spend_activity(Val),
            catch global:send(mgeew_consume_log_server, {consume_logs, Val})
    end,
    erlang:erase(?CONSUME_LOG_LIST),
    ok.

on_transaction_rollback() ->
    erlang:erase(?CONSUME_LOG_LIST),
    ok.

send_spend_activity(RecList)->
    case catch common_activity:get_config(?SPEND_USE_GOLD_KEY,spend_activity) of
        {ok,Config}->
            case catch common_activity:check_config_time(spend_activity,activity,Config) of
                {ok,_,_}->
                    lists:foreach(
                      fun(Rec)->
                              #r_consume_log{type=Type,user_id=UserID,use_unbind=UseGoldUnbind,mtype=MType}=Rec,
                              case Type=:=gold andalso  UseGoldUnbind>0 andalso MType=:=?CONSUME_TYPE_GOLD_BUY_ITEM_FROM_SHOP of
                                  true->common_activity:send_special_activity({stat_pay,{?SPEND_USE_GOLD_KEY,{UserID,UseGoldUnbind}}});
                                  _->ignore
                              end
                      end,RecList);
                _->
                    ignore
            end;
        _->
            ignore
    end.

%% @doc 使用银两 
%% @param UserId::integer() 玩家ID 
%% @param UseSilverBind::integer() 花费绑定银两的数量（单位：文） 
%% @param UseSilverUnbind::integer() 花费不绑定银两的数量（单位：文） 
%% @param MType::integer() 操作类型, 请使用log_consume_type.hrl中定义的CONSUME_TYPE_**
%% @param MDetail::string() 操作内容 ,建议使用global_lang.hrl中定义的字符串
%% @param ItemId::integer() 道具ID,可选 
%% @param ItemAmount::integer() 道具数量,可选 
use_silver({UserId, UseSilverBind, UseSilverUnbind, MType, MDetail}) ->
    InitRecord = get_consume_log(silver),
    Record = InitRecord#r_consume_log{ user_id=UserId, use_bind=UseSilverBind, use_unbind=UseSilverUnbind, mtype=MType, mdetail=MDetail},
	do_write_record(Record);
use_silver({UserId, UseSilverBind, UseSilverUnbind, MType, MDetail,ItemId,ItemAmount}) ->
    InitRecord = get_consume_log(silver),
    Record = InitRecord#r_consume_log{ user_id=UserId, use_bind=UseSilverBind, use_unbind=UseSilverUnbind, mtype=MType, mdetail=MDetail, item_id=ItemId, item_amount=ItemAmount},
    do_write_record(Record).


%% @doc 获得银两
%% @param 参数请参考use_silver
gain_silver({UserId, UseSilverBind, UseSilverUnbind, MType, MDetail}) ->
    use_silver({UserId, get_gain_use(UseSilverBind), get_gain_use(UseSilverUnbind), MType, MDetail});
gain_silver({UserId, UseSilverBind, UseSilverUnbind, MType, MDetail,ItemId,ItemAmount}) ->
    use_silver({UserId, get_gain_use(UseSilverBind), get_gain_use(UseSilverUnbind), MType, MDetail,ItemId,ItemAmount}).

        
%% @doc 使用元宝
%% @param UserId::integer() 玩家ID 
%% @param UseGoldBind::integer() 花费绑定元宝的数量 
%% @param UseGoldUnbind::integer() 花费元宝的数量 
%% @param BindType::integer() 绑定类型 ,请使用common.hrl中定义的CONSUME_BIND_TYPE_*
%% @param MType::integer() 操作类型, 请使用common.hrl中定义的CONSUME_TYPE_**
%% @param MDetail::string() 操作内容 ,可以使用global_lang.hrl中定义的字符串
%% @param ItemId::integer() 道具ID,可选 
%% @param ItemAmount::integer() 道具数量,可选 
use_gold({UserId, UseGoldBind, UseGoldUnbind, MType, MDetail}) ->
    InitRecord = get_consume_log(gold),
    Record = InitRecord#r_consume_log{ user_id=UserId, use_bind=UseGoldBind, use_unbind=UseGoldUnbind, mtype=MType, mdetail=MDetail},
	do_write_record(Record);
use_gold({UserId, UseGoldBind, UseGoldUnbind, MType, MDetail,ItemId,ItemAmount}) ->
    InitRecord = get_consume_log(gold),
    Record = InitRecord#r_consume_log{ user_id=UserId, use_bind=UseGoldBind, use_unbind=UseGoldUnbind, mtype=MType, mdetail=MDetail, item_id=ItemId, item_amount=ItemAmount},
    do_write_record(Record).

%% @doc 获得元宝
%% @param 参数请参考use_gold
gain_gold({UserId, UseGoldBind, UseGoldUnbind, MType, MDetail}) ->
    use_gold({UserId, get_gain_use(UseGoldBind), get_gain_use(UseGoldUnbind), MType, MDetail});
gain_gold({UserId, UseGoldBind, UseGoldUnbind, MType, MDetail,ItemId,ItemAmount}) ->
    use_gold({UserId, get_gain_use(UseGoldBind), get_gain_use(UseGoldUnbind), MType, MDetail,ItemId,ItemAmount}). 


%% ====================================================================
%% Local Functions
%% ====================================================================
%%@spec do_write_record/1
do_write_record(Record)->
    IsInTransaction = is_in_transaction(),
    if
        IsInTransaction ->
            next;
        true->
            throw(no_consume_log_transaction)
    end,
	#r_consume_log{ use_bind=UseBind, use_unbind=UseUnBind } = Record,
	case (UseBind=:=0) andalso(UseUnBind=:=0) of
		true->
			ignore;
		false->
            common_misc:update_dict_queue(?CONSUME_LOG_LIST,Record)
	end.


get_consume_log(Type)->
    LogTime = common_tool:now(), %% now_seconds
    LogId = common_tool:now_microseconds(),
    #r_consume_log{type=Type,log_id=LogId,mtime=LogTime,item_id=0, item_amount=0}.

get_gain_use(UseAmount) when (UseAmount>0) ->
	-UseAmount;
get_gain_use(UseAmount) ->
	UseAmount.

is_in_transaction()->
   erlang:get(?CONSUME_LOG_LIST) =/= ?CONSUME_LOG_LIST.




