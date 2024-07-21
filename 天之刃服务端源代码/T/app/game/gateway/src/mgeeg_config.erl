%%% -------------------------------------------------------------------
%%% Author  : QingliangCn
%%% Description :
%%%
%%% Created : 2010-3-11
%%% -------------------------------------------------------------------
-module(mgeeg_config).

-behaviour(gen_server).
%% --------------------------------------------------------------------
-include("mgeeg.hrl").

%% --------------------------------------------------------------------
-export([
         start/0,
         start_link/0,
         set/2,
         get/1,
         handle/1
        ]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

-define(ETS_CONFIG, ets_config).

start() ->
    {ok, _} = supervisor:start_child(
                mgeeg_sup, 
                {?MODULE, {?MODULE, start_link, []}, transient, 10000, worker, [?MODULE]}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


handle({_}) ->
%%     case Method of
%%         ?CONFIG_GETSKILLS ->
%%             case ets:lookup(?ETS_CONFIG, skills) of
%%                 [{skills, Result}] ->
%%                     common_misc:unicast(Line, RoleID, Unique, Module, Method, Result);
%%                 _ ->
%%                     Result = #m_config_getskills_toc{succ=false, reason=?_LANG_SYSTEM_ERROR},
%%                     common_misc:unicast(Line, RoleID, Unique, Module, Method, Result)
%%             end;
%%         ?CONFIG_GETBUFFS ->
%%             case ets:lookup(?ETS_CONFIG, buffs) of
%%                 [{skills, Result}] ->
%%                     common_misc:unicast(Line, RoleID, Unique, Module, Method, Result);
%%                 _ ->
%%                     Result = #m_config_getskills_toc{succ=false, reason=?_LANG_SYSTEM_ERROR},
%%                     common_misc:unicast(Line, RoleID, Unique, Module, Method, Result)
%%             end;
%%         _ ->
%%             ignore
%%     end,
    ok.

%% ====================================================================

set(Key, Value) ->
    gen_server:call(?MODULE, {set, Key, Value}).

%% return value or undefined when not found
-spec(get(Key :: term()) -> term() | undefined).
get(Key) ->
    gen_server:call(?MODULE, {get, Key}).

%% --------------------------------------------------------------------
init([]) ->
    ets:new(?ETS_CONFIG, [protected, named_table, set]),
%%     init_skills(),
%%     init_buffs(),
    {ok, #state{}}.

%% --------------------------------------------------------------------
handle_call({set, Key, Value}, _From, State) ->
    ets:insert(?ETS_CONFIG, {Key, Value}),
    {reply, ok, State};


handle_call({get, Key}, _From, State) ->
    case ets:lookup(?ETS_CONFIG, Key) of
        [{Key, Value}] ->
            Reply = Value;
        _ ->
            Reply = undefined
    end,
    {reply, Reply, State};


handle_call(Request, From, State) ->
    ?ERROR_MSG("unexpected call ~w from ~w", [Request, From]),
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    ?INFO_MSG("unexpected cast ~w", [Msg]),
    {noreply, State}.

%% --------------------------------------------------------------------
handle_info(Info, State) ->
    ?INFO_MSG("unexpected info ~w", [Info]),
    {noreply, State}.

%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ?INFO_MSG("~w terminate : ~w, ~w", [self(), Reason, State]),
    ok.

%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------

%% init_skills() ->
%% %%     {ok, SkillFile} = application:get_env(skills_config_path),
%% %%     {ok, [Skills]} = file:consult(SkillFile),
%% %%     Lists =
%% %%         lists:foldl(
%% %%           fun(Skill, Acc) when is_record(Skill, p_skill) ->
%% %%                   [Skill | Acc]
%% %%           end,
%% %%           <<>>,
%% %%           Skills),
%% %%     Record = #m_config_getskills_toc{skills=Lists},
%% %%     ets:insert(?ETS_CONFIG, {skills, Record}).
%%     ok.

%% init_buffs() ->
%%     {ok, BuffFile} = application:get_env(buffs_config_path),
%%     {ok, [Buffs]} = file:consult(BuffFile),
%%     Lists =
%%         lists:foldl(
%%           fun(Buff, Acc) when is_record(Buff, p_buf) ->
%%                   [Buff | Acc]
%%           end,
%%           [],
%%           Buffs),
%%     Record = #m_config_getbuffs_toc{buffs=Lists},
%%     ets:insert(?ETS_CONFIG, {buffs, Record}).
