%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     记录游戏中的消费日志
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(mgeew_consume_log_server).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeew.hrl").

%% API
-export([start/0,
         start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).
-record(state, {}).

%% 需要合并的银两使用记录类型
%% 普通任务/升级技能的扣银两
-define(COMBINE_SILVER_TYPE_LIST,[?GAIN_TYPE_SILVER_MISSION_NORMAL,?CONSUME_TYPE_SILVER_UP_SKILL]).

%% 默认30秒钟将数据转存到MySQL中
-define(DUMP_INTERVAL, 30*1000).
-define(MINUTE,60*1000). %%一分钟
%%-define(MINUTE,2*1000). %%test
-define(MSG_DUMP_LOG, dump_consume_log).
-define(MSG_DUMP_COMBINE_SILVER_LOG, dump_combine_silver_log).
-define(COMBINE_KEY,combine_key).

%% 合并的银两使用记录，只针对普通任务、升级技能的特殊处理
-define(COMBINE_SILVER_LOG_QUEUE,combine_silver_log_queue).
-define(SILVER_LOG_QUEUE,silver_log_queue).
-define(GOLD_LOG_QUEUE,gold_log_queue).
-define(CONSUME_RECORD_QUEUE,consume_record_queue).

%%%===================================================================
start() ->
    {ok, _} = supervisor:start_child(mgeew_sup, {?MODULE, {?MODULE, start_link, []},
                                                 permanent, 30000, worker, [?MODULE]}).

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).


%% ====================================================================
%% Server functions
%% 		gen_server callbacks
%% ====================================================================
%%--------------------------------------------------------------------
init([]) ->
    erlang:process_flag(trap_exit, true),
    
	erlang:send_after(?DUMP_INTERVAL,self(),?MSG_DUMP_LOG),
    [CombineSilverInterval] = common_config_dyn:find(logs,combine_silver_log_interval),
    erlang:send_after(CombineSilverInterval*?MINUTE,self(),?MSG_DUMP_COMBINE_SILVER_LOG),
    
    put(?COMBINE_KEY,get_now_combine_key()),
    put(?COMBINE_SILVER_LOG_QUEUE,[]),
    put(?CONSUME_RECORD_QUEUE,[]),
    
    put(?SILVER_LOG_QUEUE,[]),
    put(?GOLD_LOG_QUEUE,[]),
    
    {ok, #state{}}.

    
    
%%--------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.
%%--------------------------------------------------------------------
handle_info(Info, State) ->
    ?DO_HANDLE_INFO(Info,State),
    {noreply, State}.
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ?ERROR_MSG("等待将消费日志的临时数据 写入到db中",[]),
    do_dump_consume_logs(),
    do_dump_combine_silver_logs(),
    ok.
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================


%% ====================================================================
%% Local Functions
%% ====================================================================

do_handle_info(?MSG_DUMP_LOG)->
    do_dump_consume_logs(),
    erlang:send_after(?DUMP_INTERVAL, self(), ?MSG_DUMP_LOG);

do_handle_info(?MSG_DUMP_COMBINE_SILVER_LOG)->
    do_dump_combine_silver_logs(),
    
    [CombineSilverInterval] = common_config_dyn:find(logs,combine_silver_log_interval),
    erlang:send_after(CombineSilverInterval*?MINUTE, self(), ?MSG_DUMP_COMBINE_SILVER_LOG);

%% 消息从common_consume_logger模块发送过来，LogList由 {Table, Record}组成
do_handle_info({consume_logs, RecList}) when is_list(RecList) ->
    %%?ERROR_MSG("RecList=~w",[RecList]),
    case get(?CONSUME_RECORD_QUEUE) of
        undefined->
            put(?CONSUME_RECORD_QUEUE,RecList);
        [] ->
            put(?CONSUME_RECORD_QUEUE,RecList);
        OldList ->
            put(?CONSUME_RECORD_QUEUE,lists:concat([RecList,OldList]))
    end;

do_handle_info(Info)->
    ?ERROR_MSG("receive unknown message,Info=~w",[Info]),
    ignore.
            

%%@doc 持久化未分类的消费日志
do_dump_consume_logs()->
    %%?INFO_MSG("do_dump_consume_logs",[]),
    try
        case get(?CONSUME_RECORD_QUEUE) of
            undefined-> ignore;
            [] -> ignore;
            RecList ->
                save_record_list(RecList)
        end,
        put(?CONSUME_RECORD_QUEUE,[])
    catch
        _:Reason->
            ?ERROR_MSG("do_save_consume_log error,Reason=~w,Stacktrace=~w",[Reason,erlang:get_stacktrace()])
    end.

%%@doc 持久化已合并的银两消费日志
do_dump_combine_silver_logs()->
    %%?INFO_MSG("do_dump_combine_silver_logs",[]),
    try
        CurrentCombineKey = get(?COMBINE_KEY),
        save_combine_records_to_mysql(CurrentCombineKey),
        
        %%生成下一次的合并Key
        NewKey = get_now_combine_key(),
        put(?COMBINE_KEY,NewKey)

    catch
        _:Reason->
            ?ERROR_MSG("持久化合并的银两消费日志出错,Reason=~w,stacktrace=~w",[Reason,erlang:get_stacktrace()])
    end.

get_now_combine_key()->
    %%通过整点的时间点来明显标识是否为合并数据
    {H,_M,_S} = erlang:time(),
    NowDateTime = {erlang:date(),{H,0,0}},
    common_tool:datetime_to_seconds(NowDateTime).

save_record_list([])->
    ignore;
save_record_list(RecList)-> 
    {CombineSilverRecords,SilverRecords,GoldRecords}  = classify_records(RecList),
    %%?INFO_MSG("CombineSilverRecords=~w",[CombineSilverRecords]),
    merge_combine_log_queue(?COMBINE_SILVER_LOG_QUEUE,CombineSilverRecords),
    %%do not save_to_mysql
    
    merge_log_queue(?SILVER_LOG_QUEUE,SilverRecords),
    save_to_mysql(?SILVER_LOG_QUEUE),

    merge_log_queue(?GOLD_LOG_QUEUE,GoldRecords),
    save_to_mysql(?GOLD_LOG_QUEUE),
    ok.

merge_log_queue(Key,NewList)->
    case erlang:get(Key) of
        undefined-> erlang:put(Key,NewList);
        [] -> erlang:put(Key,NewList);
        OldList -> erlang:put( Key,lists:concat([NewList,OldList]) )
    end.

merge_combine_log_queue(Key,CombineSilverRecords)->
    %%?INFO_MSG("CombineSilverRecords=~w",[CombineSilverRecords]),
    Val = merge_combine_log_queue2( get(Key),CombineSilverRecords),
    put(Key,Val).

%%@doc 将更新的record合并到Queues中
%% 目前的实现，有可能将今天凌晨1点的记录合并到昨天的数据中
%% [{RoleID,MType},Bind,UnBind}] = Queues
merge_combine_log_queue2(Queues,[])->
    Queues;
merge_combine_log_queue2(Queues,[H|Recs])->
    [RoleID, Bind, UnBind, _LogTime, MType, _MDetail,_ItemId,_ItemAmount ] = H,
    Key = {RoleID,MType},
    case lists:keyfind(Key, 1, Queues) of
        false->
            merge_combine_log_queue2([{Key,Bind,UnBind}|Queues],Recs);
        {Key,OldBind,OldUnBind}->
            Q2 = lists:keystore(Key, 1, Queues, {Key,Bind+OldBind,UnBind+OldUnBind}),
            merge_combine_log_queue2(Q2,Recs)
    end.


%%@doc 将合并记录更新到mysql中
save_combine_records_to_mysql(CurrentMTime)->
    case get(?COMBINE_SILVER_LOG_QUEUE) of
        []->ignore;
        undefined->ignore;
        Queues->
            %%?INFO_MSG("save_combine_records_to_mysql,CurrentMTime=~w,Queues=~w",[CurrentMTime,Queues]),
            TabName = get_silver_log_tab_name(),
            %%批量插入
            FieldNames = [user_id, silver_bind, silver_unbind, mtime, mtype, mdetail, itemid, amount],
            BatchFieldValues = 
                lists:map(fun( {{RoleID,MType},Bind,UnBind} )-> 
                                  case MType of
                                      ?GAIN_TYPE_SILVER_MISSION_NORMAL ->
                                          [RoleID,Bind,UnBind,CurrentMTime,MType,?_LANG_MISSION_GAIN_SILVER,0,0];
                                      ?CONSUME_TYPE_SILVER_UP_SKILL->
                                          [RoleID,Bind,UnBind,CurrentMTime,MType,"",0,0]
                                  end
                          end,Queues),
            
            %%每次批量插入3000条
            mod_mysql:batch_insert(TabName,FieldNames,BatchFieldValues,3000),
            put(?COMBINE_SILVER_LOG_QUEUE,[])
    end.


%%@doc 将银两、元宝进行分类
%%@return   {CombineSilverLog,SilverLog,GoldLog}
classify_records(RecList)->
    %% {CombineSLog,SLog,GLog} 
    %%?INFO_MSG("RecList=~w",[RecList]),
    lists:foldr(
      fun(Rec,{CombineSilverAcc,SilverAcc,GoldAcc})-> 
              case Rec of
                  #r_consume_log{type=silver,mtype=MType}->
                      case lists:member(MType, ?COMBINE_SILVER_TYPE_LIST) of
                          true->
                              {[ transform_record(silver,Rec) |CombineSilverAcc],SilverAcc,GoldAcc};
                          _ ->
                              {CombineSilverAcc,[ transform_record(silver,Rec) |SilverAcc],GoldAcc}
                      end;
                  #r_consume_log{type=gold}->
                      {CombineSilverAcc,SilverAcc,[ transform_record(gold,Rec)|GoldAcc]}
              end
      end, {[],[],[]}, RecList).

%%@doc 将Record转换成插入mysql的值列表
transform_record(silver,Rec)->
    #r_consume_log{user_id=UserId, use_bind=UseSilverBind, use_unbind=UseSilverUnbind, 
                   mtime=LogTime, mtype=MType, mdetail=MDetail, item_id=ItemId, item_amount=ItemAmount} = Rec,
    [UserId, UseSilverBind, UseSilverUnbind, LogTime, MType, MDetail,ItemId,ItemAmount ];
transform_record(gold,Rec)->
    #r_consume_log{user_id=UserId, use_bind=UseGoldBind, use_unbind=UseGoldUnbind, 
                   mtime=LogTime, mtype=MType, mdetail=MDetail, item_id=ItemId, item_amount=ItemAmount} = Rec,
    {ok, RoleBase} = common_misc:get_dirty_role_base(UserId),
    {ok, RoleAttr} = common_misc:get_dirty_role_attr(UserId),
    #p_role_base{role_name=RoleName,account_name=AccountName} = RoleBase,
    #p_role_attr{level=Level} = RoleAttr,
    
    %%元宝需要发送中央的 behavior日志
    common_behavior:send({consume_gold, RoleName,AccountName,Level,Rec}),
    
    [UserId, RoleName, AccountName, Level, UseGoldBind, UseGoldUnbind, LogTime, MType, MDetail,ItemId,ItemAmount ].
                                                     


save_to_mysql(QueueType)->
    case get(QueueType) of
        []-> ignore;
        undefined-> ignore;
        Queues->
            %%?INFO_MSG("save_to_mysql,Queues=~w",[Queues]),
            save_to_mysql_2(QueueType,Queues) 
    end.
save_to_mysql_2(?SILVER_LOG_QUEUE=QueueType,Queues)->
    try
        %%批量插入
        TabName = get_silver_log_tab_name(),
        FieldNames = [user_id, silver_bind, silver_unbind, mtime, mtype, mdetail, itemid, amount],

        QueuesInsert = lists:reverse(Queues),
        mod_mysql:batch_insert(TabName,FieldNames,QueuesInsert,3000),
        
        %%插入成功后update
        put(QueueType,[])
    catch
        _:Reason->
            ?ERROR_MSG("持久化银两消费日志出错,Reason=~w,stacktrace=~w",[Reason,erlang:get_stacktrace()])
    end;
save_to_mysql_2(?GOLD_LOG_QUEUE=QueueType,Queues)->
    try
        %%批量插入
        FieldNames = [ user_id, user_name, account_name, level, gold_bind, gold_unbind, mtime, mtype, mdetail, itemid, amount],
        
        QueuesInsert = lists:reverse(Queues),
        mod_mysql:batch_insert(t_log_use_gold,FieldNames,QueuesInsert,3000),
        
        %%插入成功后update
         put(QueueType,[])
    catch
        _:Reason->
            ?ERROR_MSG("持久化元宝消费日志出错,Reason=~w,stacktrace=~w",[Reason,erlang:get_stacktrace()])
    end.

%%@doc 获取银两日志表名
get_silver_log_tab_name()->
    case common_config_dyn:find(logs,is_silver_log_partition) of
        [true]->
            format_log_tab_name();
        _ ->
            t_log_use_silver
    end.
            
format_log_tab_name()->
    {Y,M,_D} = erlang:date(),
    Month = lists:flatten( io_lib:format("_~2..0B", [M]) ) ,
    TabName = lists:concat([ t_log_use_silver_,Y,Month]),
    
    [DBName] = common_config_dyn:find_common(db_name_logs),
    {table,DBName,common_tool:to_atom( TabName )}.

 
