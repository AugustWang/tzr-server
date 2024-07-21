%%% -------------------------------------------------------------------
%%% Author  : lenovo
%%% Description :
%%%
%%% Created : 2011-1-10
%%% -------------------------------------------------------------------
-module(mgeec_reconnect_server).

-behaviour(gen_server).
-include("mgeec.hrl").

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([]).

%% gen_server callbacks
-export([init/1, 
         handle_call/3, 
         handle_cast/2, 
         handle_info/2, 
         terminate/2, 
         code_change/3,
         start/0,
         start_link/0]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================


%% ====================================================================
%% Server functions
%% ====================================================================
start() ->
    {ok, _} = supervisor:start_child(
                mgeec_sup, 
                {?MODULE, 
                 {?MODULE, start_link, []}, 
                 transient, 10000, worker, [?MODULE]}).

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(Info, State) ->
    try 
        do_handle_info(Info)
    catch
        T:R ->
            ?ERROR_MSG("module: ~w, line: ~w, Info:~w, type: ~w, reason: ~w,stactraceo: ~w",
                       [?MODULE, ?LINE, Info, T, R, erlang:get_stacktrace()])
    end,
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

do_handle_info({reconnect, Unique, RoleID, Line}) ->
    do_old_reconnect(Unique, RoleID, Line);

do_handle_info({new_reconnect, Unique, Module, Method, DataRecord, RoleId, Pid}) ->
    do_reconnect({Unique, Module, Method, DataRecord, RoleId, Pid});

do_handle_info({func, Fun, Args}) ->
    Ret =(catch apply(Fun,Args)),
    ?ERROR_MSG("~w",[Ret]);
do_handle_info(Info) ->
    ?ERROR_MSG("无法处理此消息 Info=~w",[Info]),
    ok.


%% 旧版本的聊天重连
do_old_reconnect(Unique, RoleID, Line) ->
    RolePname = common_misc:chat_get_role_pname(RoleID),
    case global:whereis_name(RolePname) of
        Pid when is_pid(Pid) ->
            exit(Pid, normal),
            DataRecord = #m_chat_reconnect_toc{succ = false},
            common_misc:unicast(Line, RoleID, Unique, ?CHAT, ?CHAT_RECONNECT, DataRecord);
        undefined ->
            {ok, RoleBase} = common_misc:get_dirty_role_base(RoleID),
            AccounutName = RoleBase#p_role_base.account_name,
            AccounutName2 = common_tool:to_list(AccounutName),
            [{Time, Key}|_]  = gen_server:call({global, mgeel_key_server}, {gen_key, AccounutName, RoleID}),
            DataRecord = #m_chat_reconnect_toc{succ = true, 
                                               account = AccounutName2, 
                                               roleid = RoleID,
                                               timestamp = Time,
                                               key = Key},
            common_misc:unicast(Line, RoleID, Unique, ?CHAT, ?CHAT_RECONNECT, DataRecord)
    end.
%% 新版本的聊天重连
%% DataRecord 结构为 m_auth_chat_key_tos
do_reconnect({Unique, Module, Method, DataRecord, RoleId, Pid}) ->
    #m_auth_chat_key_tos{times = Times} = DataRecord,
    RolePname = common_misc:chat_get_role_pname(RoleId),
    case global:whereis_name(RolePname) of
        Pid when is_pid(Pid) ->
            exit(Pid, normal),
            SendSelf = #m_auth_chat_key_toc{succ = false,times = Times};
        undefined ->
            {ok, RoleBase} = common_misc:get_dirty_role_base(RoleId),
            AccounutName = RoleBase#p_role_base.account_name,
            AccounutName2 = common_tool:to_list(AccounutName),
            [{Time, Key}|_]  = gen_server:call({global, mgeel_key_server}, {gen_key, AccounutName, RoleId}),
            SendSelf = #m_auth_chat_key_toc{
              succ = true, 
              account = AccounutName2, 
              roleid = RoleId,
              timestamp = Time,
              times = Times,
              key = Key}
    end,
    common_misc:unicast2(Pid, Unique, Module, Method, SendSelf).
