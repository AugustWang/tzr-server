%%%----------------------------------------------------------------------
%%% @copyright 2010 mcs (Ming Chao Server)
%%%
%%% @author bisonwu, 2011-4-7
%%% @doc bgp_serverlog
%%% @end
%%%----------------------------------------------------------------------

-module(bgp_serverlog).

-behaviour(gen_server2).

-include("common.hrl").
-include("mgeebgp_comm.hrl").

%% API
-export([
         start/0, 
         start_link/0
        ]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).


-record(state, {fd}).


start() ->
    {ok, _} = supervisor:start_child(mgeebgp_sup, {?MODULE, {?MODULE, start_link, []},
                                                 transient, brutal_kill, worker, [?MODULE]}).


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


%%%===================================================================
init([]) ->
    File = make_log_file(),
    trunk_at_next_date(),
    {ok, #state{fd=File}}.


%%--------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.


%%--------------------------------------------------------------------

handle_info({event, Event}, State) ->
    write_event(State#state.fd, {erlang:localtime(), Event}),
    {noreply, State};
handle_info(trunk_file, State) ->
    File = make_log_file(),
    trunk_at_next_date(),
    {noreply, State#state{fd=File}};
handle_info(Info, State) ->
    ?ERROR_MSG("~ts:~w", ["未知的消息", Info]),
    {noreply, State}.


%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.


%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

do_write(Fd, Time, Type, Format, Args) ->
    {{Y,Mo,D},{H,Mi,S}} = Time, 
    LBin = erlang:iolist_to_binary(Type),
    InfoMsg = unicode:characters_to_list(LBin),
    Time2 = io_lib:format("==== ~w-~.2.0w-~.2.0w ~.2.0w:~.2.0w:~.2.0w ===",
		  [Y, Mo, D, H, Mi, S]),
    L2 = lists:concat([InfoMsg, Time2]),
    B = unicode:characters_to_binary(L2),
    file:write_file(Fd, B, [append]),
    try 
        M = io_lib:format(Format, Args),
        file:write_file(Fd, M, [append])
    catch _:Error ->
            ?ERROR_MSG("log error ~p ~p ~p", [Error, Format, Args])
    end.

%%%===================================================================
%%% Internal functions
%%%===================================================================
% Copied from erlang_logger_file_h.erl
write_event(Fd, {Time, {error, _GL, {_Pid, Format, Args}}}) ->
    [L] = io_lib:format("~ts", ["错误报告"]),
    do_write(Fd, Time, L, Format, Args);


write_event(Fd, {Time, {emulator, _GL, Chars}}) ->
    T = write_time(Time),
    case catch io_lib:format(Chars, []) of
	S when is_list(S) ->
	    file:write_file(Fd, io_lib:format(T ++ S, []), [append]);
	_ ->
	    file:write_file(Fd, io_lib:format(T ++ "ERROR: ~p ~n", [Chars]), [append])
    end;


write_event(Fd, {Time, {info, _GL, {Pid, Info, _}}}) ->
    T = write_time(Time),
    file:write_file(Fd, io_lib:format(T ++ add_node("~p~n",Pid), [Info]), [append]);


write_event(Fd, {Time, {error_report, _GL, {Pid, std_error, Rep}}}) ->
    T = write_time(Time),
    S = format_report(Rep),
    file:write_file(Fd, io_lib:format(T ++ S ++ add_node("", Pid), []), [append]);


write_event(Fd, {Time, {info_report, _GL, {Pid, std_info, Rep}}}) ->
    T = write_time(Time, "INFO REPORT"),
    S = format_report(Rep),
    file:write_file(Fd, io_lib:format(T ++ S ++ add_node("", Pid), []), [append]);


write_event(Fd, {Time, {info_msg, _GL, {_Pid, Format, Args}}}) ->
    [L] = io_lib:format("~ts", ["信息报告"]),
    do_write(Fd, Time, L, Format, Args);


write_event(_, _) ->
    ok.

format_report(Rep) when is_list(Rep) ->
    case string_p(Rep) of
	true ->
	    io_lib:format("~s~n",[Rep]);
	_ ->
	    format_rep(Rep)
    end;
format_report(Rep) ->
    io_lib:format("~p~n",[Rep]).

format_rep([{Tag,Data}|Rep]) ->
    io_lib:format("    ~p: ~p~n",[Tag,Data]) ++ format_rep(Rep);


format_rep([Other|Rep]) ->
    io_lib:format("    ~p~n",[Other]) ++ format_rep(Rep);


format_rep(_) ->
    [].

add_node(X, Pid) when node(Pid) /= node() ->
    lists:concat([X,"** at node ",node(Pid)," **~n"]);
add_node(X, _) ->
    X.

string_p([]) ->
    false;
string_p(Term) ->
    string_p1(Term).

string_p1([H|T]) when is_integer(H), H >= $\s, H < 255 ->
    string_p1(T);
string_p1([$\n|T]) -> string_p1(T);
string_p1([$\r|T]) -> string_p1(T);
string_p1([$\t|T]) -> string_p1(T);
string_p1([$\v|T]) -> string_p1(T);
string_p1([$\b|T]) -> string_p1(T);
string_p1([$\f|T]) -> string_p1(T);
string_p1([$\e|T]) -> string_p1(T);
string_p1([H|T]) when is_list(H) ->
    case string_p1(H) of
	true -> string_p1(T);
	_    -> false
    end;
string_p1([]) -> true;
string_p1(_) ->  false.

write_time(Time) -> write_time(Time, "ERROR REPORT").

write_time({{Y,Mo,D},{H,Mi,S}}, Type) ->
    io_lib:format("~n=~s==== ~w-~.2.0w-~.2.0w ~.2.0w:~.2.0w:~.2.0w ===",
		  [Type, Y, Mo, D, H, Mi, S]).


%%生成日志文件名
make_log_file() ->
    {{Year, Month, Day},_} = erlang:localtime(),
    io_lib:format("/data/logs/ming2_bgp_~p_~p_~p.log", [Year, Month, Day]).


%%通知服务器在下一个整点刷新日志文件
trunk_at_next_date() ->
    {{_, _, _Day}, {H, I, S}} = erlang:localtime(),
    Time = ((59 - H) * 3600 +(59 - I) * 60 + (59 - S) + 2) * 1000,
    erlang:send_after(Time, self(), trunk_file).            
