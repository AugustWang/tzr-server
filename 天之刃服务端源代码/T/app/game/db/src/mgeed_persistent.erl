%%% -------------------------------------------------------------------
%%% Author  : QingliangCn
%%% Description : 数据持久
%%%
%%% Created : 2010-07-14
%%% -------------------------------------------------------------------
-module(mgeed_persistent).

-behaviour(gen_server).

-include("mgeed.hrl").

%% API
-export([
         start/0,
         start_link/0
        ]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).


%%保存哪些表的哪些记录已经被加载了
-define(ETS_LOADED_MAP, ets_loaded_map).
-define(QTYPE_NORMAL,normal).
-define(QTYPE_SUBSCRIBER,subscriber).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    {ok, _} = supervisor:start_child(mgeed_sup, {?MODULE, 
                                                 {?MODULE, start_link, []},
                                                 transient, 90000000, worker, [?MODULE]}).

start_link() ->
    gen_server:start_link({global, db_persistent}, ?MODULE, [], []).



%%--------------------------------------------------------------------
init([]) ->
    erlang:process_flag(trap_exit, true),
    ets:new(?ETS_LOADED_MAP, [named_table, private, set]),
    ets:new(?ETS_TABLE_MAP, [named_table, private, set]),
    ets:new(ets_role_load_map, [named_table, private, set]),
    init_define_table_mapping(),
    {ok, #state{}}.


%%--------------------------------------------------------------------

handle_call(Call, _From, State) ->
    try 
        Reply = do_handle_call(Call),
        {reply, Reply, State}
    catch _:E ->
            ?ERROR_MSG("~p ~p", [Call, E]),
            {reply, error, State}
    end.

do_handle_call({load, SourceTable, TargetTable, Key}) ->
    do_load(SourceTable, TargetTable, Key);
do_handle_call({match_load, SourceTable, TargetTable, Pattern}) ->
    do_match_load(SourceTable, TargetTable, Pattern);
do_handle_call({load_role_data, AccountName, RoleID}) ->
    do_load_role_data(AccountName, RoleID);
do_handle_call({unload, SourceTable, TargetTable, Key}) ->
    do_unload(SourceTable, TargetTable, Key);
do_handle_call({match_unload, SourceTable, TargetTable, Key}) ->
    do_match_unload(SourceTable, TargetTable, Key);
do_handle_call({load_whole_table, SourceTable, TargetTable}) ->
    do_load_whole_table(SourceTable, TargetTable);
do_handle_call(_) ->
    error.


%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.


%%--------------------------------------------------------------------
handle_info({'EXIT', PID, shutdown}, State) ->
    List = erlang:pid_to_list(PID),
    case string:str(List, "<0.") of
        0 ->
            {noreply, State};
        _ ->
            {stop, normal, State}
    end;

handle_info(Info, State) ->
    ?DO_HANDLE_INFO(Info,State),
    {noreply, State}.


%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.


%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================

%% 获取内存表对应的P表
get_persist_table(Tab)->
    common_tool:list_to_atom(lists:concat([Tab, "_p"])).

%% 手工载入玩家数据
do_load_role_data(AccountName, RoleID) ->    
    case ets:lookup(ets_role_load_map, {AccountName, RoleID}) of
        [] ->
            lists:foreach(fun(RamTab)-> 
                                  DiskTab = get_persist_table(RamTab),
                                  case mnesia:transaction(
                                         fun() ->
                                                 R = mnesia:read(DiskTab, RoleID, write),
                                                 [mnesia:write(RamTab, R1, write) || R1 <- R]
                                         end)
                                  of
                                      {atomic, _} ->
                                          ets:insert(?ETS_TABLE_MAP, {RamTab, DiskTab}),
                                          ets:insert(?ETS_LOADED_MAP, {{DiskTab, RoleID}, true}),
                                          ok;
                                      {aborted, Error} ->
                                          ?CRITICAL_MSG("~ts:~p", ["加载数据发生系统错误", Error])
                                  end
                          end, lists:append(db_loader:delay_load_tables(), db_loader:delay_load_tables_with_offline())),
            ets:insert(ets_role_load_map, {{AccountName, RoleID}, true});
        _ ->
            ignore
    end,
    ok.

init_define_table_mapping()->
    Tabs = db_loader:define_table_mapping(),
    [ ets:insert(?ETS_TABLE_MAP, {RamTab, DbTab}) || {DbTab,RamTab} <- Tabs],
    ok.

%%db_local_cache_server 发送过来的数据变动信息

do_handle_info({cache_queue, L}) ->
    do_queues(?QTYPE_NORMAL,L);
do_handle_info({cache_subscriber_queue, L}) ->
    do_queues(?QTYPE_SUBSCRIBER,L);
do_handle_info({clear_table, Tab}) ->
    mnesia:clear_table(Tab);


do_handle_info(Info) ->
    ?ERROR_MSG("~ts:~w", ["未知的消息", Info]).

do_queues(_QType,[]) ->
    ok;
do_queues(QType,[H|T]) ->
    do_queue(QType,H),
    do_queues(QType,T).

do_queue(?QTYPE_NORMAL,Request)->
	do_mnesia_queue(Request);
do_queue(?QTYPE_SUBSCRIBER,Request)->
	do_mnesia_subscriber_queue(Request).

%% @spec do_mnesia_subscriber_queue/1
%% @doc 通过Mnesia方式处理 队列,新的方式
do_mnesia_subscriber_queue({write,DbTab, Record}) ->
	mnesia:dirty_write(DbTab, Record);
do_mnesia_subscriber_queue({insert,DbTab, Record}) ->
	mnesia:dirty_write(DbTab, Record);
do_mnesia_subscriber_queue({update,DbTab, Record}) ->
	mnesia:dirty_write(DbTab, Record);
do_mnesia_subscriber_queue({delete,DbTab, Key}) ->
	mnesia:dirty_delete(DbTab, Key);
do_mnesia_subscriber_queue({delete_object,DbTab, Object}) ->
	mnesia:dirty_delete_object(DbTab, Object).


%% @spec do_mnesia_queue/1
%% @doc 通过Mnesia方式处理 队列,原先的方式，只是保留代码
do_mnesia_queue({{Tab, _Key}, write, Record}) ->
    mnesia:dirty_write(get_local_tab(Tab), Record);
do_mnesia_queue({{Tab, Key}, delete}) ->
    mnesia:dirty_delete(get_local_tab(Tab), Key);
do_mnesia_queue({{Tab, Object}, delete_object}) ->
    mnesia:dirty_delete_object(get_local_tab(Tab), Object);

do_mnesia_queue({{Tab, _Key}, dirty_write, Record}) ->
    mnesia:dirty_write(get_local_tab(Tab), Record);
do_mnesia_queue({{Tab, Key}, dirty_delete}) ->
    mnesia:dirty_delete(get_local_tab(Tab), Key);
do_mnesia_queue({{Tab, Object}, dirty_delete_object}) ->
    mnesia:dirty_delete_object(get_local_tab(Tab), Object).



get_local_tab(Tab) ->
    case ets:lookup(?ETS_TABLE_MAP, Tab) of
        [{Tab, SourceTable}] ->
            SourceTable;
        [] ->
            throw({'EXIT', Tab, source_table_not_found})
    end.


do_match_load(SourceTable, TargetTable, Pattern) ->
    case ets:lookup(?ETS_LOADED_MAP, {SourceTable, Pattern}) of
        [] ->
            case mnesia:transaction(
                   fun() ->
                           R = mnesia:match_object(SourceTable, Pattern, write),
                           [mnesia:write(TargetTable, R1, write) || R1 <- R]
                   end)
            of 
                {atomic, _} ->
                    ets:insert(?ETS_TABLE_MAP, {TargetTable, SourceTable}),
                    ets:insert(?ETS_LOADED_MAP, {{SourceTable, Pattern}, true}),
                    ok;
                {aborted, Error} ->
                    {error, Error}
            end;
        _ ->
            ignore
    end.            


do_load(SourceTable, TargetTable, Key) ->
    %% 判断是否该条数据已经在内存中，或者正在等待持久化？
    case if_has_load(SourceTable, Key) of
        true ->
            ignore;
        false ->
            %%该表没有重复load
            case mnesia:transaction(
                   fun() ->
                           R = mnesia:read(SourceTable, Key, write),
                           [mnesia:write(TargetTable, R1, write) || R1 <- R]
                   end)
            of
                {atomic, _} ->
                    ets:insert(?ETS_TABLE_MAP, {TargetTable, SourceTable}),
                    ets:insert(?ETS_LOADED_MAP, {{SourceTable, Key}, true}),
                    ok;
                {aborted, Error} ->
                    {error, Error}
            end
    end.


%%检查是否该记录已经被加载了
if_has_load(SourceTable, Key) ->
    case ets:lookup(?ETS_LOADED_MAP, {SourceTable, Key}) of
        [] ->
            false;
        _ ->
            true
    end.


do_match_unload(SourceTable, _TargetTable, Pattern) ->
    ets:delete(?ETS_LOADED_MAP, {SourceTable, Pattern}).


do_unload(SourceTable, _TargetTable, Key) ->
    ets:delete(?ETS_LOADED_MAP, {SourceTable, Key}).


do_load_whole_table(SourceTable, TargetTable) ->
    TargetTableNode = mnesia:table_info(TargetTable, where_to_read),
    TargetTableSize = rpc:call(TargetTableNode, mnesia, table_info, [TargetTable, size]),
    SourceTableSize = mnesia:table_info(SourceTable, size),
    %% 这种情况不需要load
    case TargetTableSize =:= SourceTableSize of
        true ->
            ignore;
        false ->
            Pattern = get_whole_table_match_pattern(SourceTable),
            mnesia:clear_table(TargetTable),
            %%TODO 改为非事务
            A = mnesia:dirty_match_object(SourceTable, Pattern),
            [mnesia:dirty_write(TargetTable, R) || R <- A],
            ets:insert(?ETS_TABLE_MAP, {TargetTable, SourceTable})
    end.


%% case mnesia:transaction(
%%      fun() ->                   
%%            A = mnesia:match_object(SourceTable, Pattern, write),
%%          [mnesia:write(TargetTable, R, write) || R <- A]
%%end)
%%of
%%  {atomic, _} ->
%%    ets:insert(?ETS_TABLE_MAP, {TargetTable, SourceTable}),
%%  ok;
%%{aborted, Result} ->
%%  ?ERROR_MSG("~ts ~w", ["全表预加载出错", Result]),
%% error
%% end.

get_whole_table_match_pattern(SourceTable) ->
    A = mnesia:table_info(SourceTable, attributes),
    RecordName = mnesia:table_info(SourceTable, record_name),
    lists:foldl(
      fun(_, Acc) ->
              erlang:append_element(Acc, '_')
      end, {RecordName}, A).


