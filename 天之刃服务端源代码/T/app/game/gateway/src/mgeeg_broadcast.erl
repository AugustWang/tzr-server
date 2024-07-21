%%% -------------------------------------------------------------------
%%% Author  : QingliangCn
%%% Description :
%%%
%%% Created : 2010-3-11
%%% -------------------------------------------------------------------
-module(mgeeg_broadcast).

-behaviour(gen_server).
-include("mgeeg.hrl").

%% --------------------------------------------------------------------
-export([
         start_link/1,
         start/1,
         process_name/1
        ]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================

start(Line) ->
    {ok, _} = supervisor:start_child(mgeeg_sup, 
                                     {?MODULE,
                                      {?MODULE, start_link, [Line]},
                                      transient, 10000, worker, [?MODULE]}).

start_link(Line) ->
    Name = process_name(Line),
    %%statistics:register_as_key_process(Name),
    gen_server:start_link({global, Name}, ?MODULE, [], []).

%% ====================================================================


%% --------------------------------------------------------------------
init([]) ->
    %%注册本地名字
    erlang:register(?MODULE, self()),
    
    erlang:process_flag(trap_exit, true),
    {ok, #state{}}.

%% --------------------------------------------------------------------


handle_call(Request, From, State) ->
    ?ERROR_MSG("unexpected call ~w from ~w", [Request, From]),
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    ?INFO_MSG("unexpected cast ~w", [Msg]),
    {noreply, State}.

%% --------------------------------------------------------------------
handle_info({send, RoleIDList, Unique, Module, Method, DataRecord}, State) ->
    ?DEBUG("~ts: ~w", ["不分优先级的广播", RoleIDList]),
    broadcast(RoleIDList, Unique, Module, Method, DataRecord),
    {noreply, State};


handle_info({send, RoleIDListPrior, RoleIDList2, Unique, Module, Method, DataRecord}, State) ->
    ?DEBUG("~ts: ~w ~w", ["分优先级的广播", RoleIDListPrior, RoleIDList2]),
    broadcast(RoleIDListPrior, Unique, Module, Method, DataRecord),
    broadcast(RoleIDList2, Unique, Module, Method, DataRecord),
    {noreply, State};


handle_info({inet_reply, _Sock, Error}, State) ->
    ?INFO_MSG("~ts: ~w", ["消息发送结果", Error]),
    {noreply, State};

handle_info({erase, RoleID, _PID}, State) ->
    erlang:erase(RoleID),
    %%erase(PID),
    {noreply, State};


handle_info({role, RoleID, Pid, Socket}, State) ->
    erlang:put(RoleID, {Pid, Socket}),
    {noreply, State};


handle_info({message, RoleID, Unique, Module, Method, DataRecord}, State) ->
    Pid = erlang:get(RoleID),
    catch Pid ! {message, Unique, Module, Method, DataRecord},
    {noreply, State};


handle_info({send_single, RoleID, Unique, Module, Method, DataRecord}, State) ->
    Pid = erlang:get(RoleID),
    catch Pid ! {message, Unique, Module, Method, DataRecord},
    {noreply, State};

handle_info({kick_role, RoleID, Reason}, State) ->
    case erlang:get(RoleID) of
        undefined ->
            ignore;
        Pid ->
            catch erlang:exit(Pid, Reason)
    end,
    {noreply, State};


handle_info({send_multi, UnicastList}, State) when is_list(UnicastList) ->
    lists:foreach(
        fun(Record) ->
            #r_unicast{unique=Unique, module=Module, method=Method, roleid=RoleID, record=DataRecord} = Record,
                Pid = get(RoleID),
                catch Pid ! {message, Unique, Module, Method, DataRecord}
        end,
        UnicastList
    ),
    {noreply, State};


handle_info(Info, State) ->
    ?INFO_MSG("unexpected info ~w", [Info]),
    {noreply, State}.

%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ?ERROR_MSG("~w terminate : ~w, ~w", [self(), Reason, State]),
    ok.

%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------

process_name(Line) ->
    lists:concat([broadcast_server_, Line]).

broadcast(List, Unique, Module, Method, DataRecord) 
  when is_list(List) andalso erlang:length(List) > 0 ->
    ?DEBUG("~ts:~w ~ts:~w ~ts:~w", ["分线广播, 模块", Module, "方法", Method, "数据", DataRecord]),
    case catch mgeeg_packet:packet_encode(Unique, Module, Method, DataRecord) of
        {'EXIT', Reason} ->
            ?ERROR_MSG("~ts ~w", ["分线编码包出错", {DataRecord, Reason}]);
        Binary ->
            lists:foreach(
              fun(RoleID) ->
                      case get(RoleID) of
                          {PID, Socket} when erlang:is_pid(PID) andalso erlang:is_port(Socket) ->  
                              catch PID ! {binary, Binary};
                          _ ->
                              ?DEBUG("~ts:~w", ["分线广播遇到无效socket", RoleID]),
                              ignore
                      end
              end, List)
    end;

broadcast(List, Unique, Module, Method, DataRecord) ->
    ?DEBUG("~ts: ~w ~w ~w ~w ~w", ["！！！忽略的广播", List, Unique, Module, Method, DataRecord]),
    ignore.
