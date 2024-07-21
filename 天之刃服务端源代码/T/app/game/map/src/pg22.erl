%% Author: QingliangCn
%% Created: 2010-4-16
%% Description: 从rabbitmq中拷贝过来，实际上也是从Erlang的源码中copy过来
%%				主要为了解决 pg2 的大量网络IO消耗的问题
-module(pg22).

-export([create/1, join/2, leave/2, get_members/1]).
-export([sync/0]). 
-export([start/0,start_link/0,init/1,handle_call/3,handle_cast/2,handle_info/2,
         terminate/2]).
         

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

start() ->
    ensure_started().
	
create(_Name) ->
	ok.

join(Name, Pid) when is_pid(Pid) ->
    ensure_started(),
    gen_server:cast(?MODULE, {join, Name, Pid}).

leave(Name, Pid) when is_pid(Pid) ->
    ensure_started(),
    gen_server:cast(?MODULE, {leave, Name, Pid}).

get_members(Name) ->
    ensure_started(),
    group_members(Name).

sync() ->
    ensure_started(),
    gen_server:call(?MODULE, sync).

%%%
%%% Callback functions from gen_server
%%%

-record(state, {}).

init([]) ->
    pg_local_table = ets:new(pg_local_table, [ordered_set, protected, named_table]),
    {ok, #state{}}.

handle_call(sync, _From, S) ->
    {reply, ok, S};

handle_call(Request, From, S) ->
    error_logger:warning_msg("The pg_local server received an unexpected message:\n"
                             "handle_call(~w, ~w, _)\n", 
                             [Request, From]),
    {noreply, S}.

handle_cast({join, Name, Pid}, S) ->
    join_group(Name, Pid),
    {noreply, S};
handle_cast({leave, Name, Pid}, S) ->
    leave_group(Name, Pid),
    {noreply, S};
handle_cast(_, S) ->
    {noreply, S}.

handle_info({'DOWN', MonitorRef, process, _Pid, _Info}, S) ->
    member_died(MonitorRef),
    {noreply, S};
handle_info(_, S) ->
    {noreply, S}.

terminate(_Reason, _S) ->
    true = ets:delete(pg_local_table),
    ok.

%%%
%%% Local functions
%%%

member_died(Ref) ->
    [{{ref, Ref}, Pid}] = ets:lookup(pg_local_table, {ref, Ref}),
    Names = member_groups(Pid),
    _ = [leave_group(Name, P) || 
            Name <- Names,
            P <- member_in_group(Pid, Name)],
    ok.

join_group(Name, Pid) ->
    Ref_Pid = {ref, Pid}, 
    try _ = ets:update_counter(pg_local_table, Ref_Pid, {3, +1})
    catch _:_ ->
            Ref = erlang:monitor(process, Pid),
            true = ets:insert(pg_local_table, {Ref_Pid, Ref, 1}),
            true = ets:insert(pg_local_table, {{ref, Ref}, Pid})
    end,
    Member_Name_Pid = {member, Name, Pid},
    try _ = ets:update_counter(pg_local_table, Member_Name_Pid, {2, +1})
    catch _:_ ->
            true = ets:insert(pg_local_table, {Member_Name_Pid, 1}),
            true = ets:insert(pg_local_table, {{pid, Pid, Name}})
    end.

leave_group(Name, Pid) ->
    Member_Name_Pid = {member, Name, Pid},
    try ets:update_counter(pg_local_table, Member_Name_Pid, {2, -1}) of
        N ->
            if 
                N =:= 0 ->
                    true = ets:delete(pg_local_table, {pid, Pid, Name}),
                    true = ets:delete(pg_local_table, Member_Name_Pid);
                true ->
                    ok
            end,
            Ref_Pid = {ref, Pid}, 
            case ets:update_counter(pg_local_table, Ref_Pid, {3, -1}) of
                0 ->
                    [{Ref_Pid,Ref,0}] = ets:lookup(pg_local_table, Ref_Pid),
                    true = ets:delete(pg_local_table, {ref, Ref}),
                    true = ets:delete(pg_local_table, Ref_Pid),
                    true = erlang:demonitor(Ref, [flush]),
                    ok;
                _ ->
                    ok
            end
    catch _:_ ->
            ok
    end.

group_members(Name) ->
    [P || 
        [P, N] <- ets:match(pg_local_table, {{member, Name, '$1'},'$2'}),
        _ <- lists:seq(1, N)].

member_in_group(Pid, Name) ->
    [{{member, Name, Pid}, N}] = ets:lookup(pg_local_table, {member, Name, Pid}),
    lists:duplicate(N, Pid).

member_groups(Pid) ->
    [Name || [Name] <- ets:match(pg_local_table, {{pid, Pid, '$1'}})].

ensure_started() ->
    case whereis(?MODULE) of
        undefined ->
            C = {pg_local, {?MODULE, start_link, []}, permanent,
                 1000, worker, [?MODULE]},
            supervisor:start_child(kernel_safe_sup, C);
        PgLocalPid ->
            {ok, PgLocalPid}
    end.
