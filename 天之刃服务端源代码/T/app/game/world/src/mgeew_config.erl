%%%----------------------------------------------------------------------
%%% @copyright 2010 mgeew (Ming Game Engine Erlang - World Server)
%%%
%%% @author odinxu, 2010-03-24
%%% @doc MGEE World Config
%%% @end
%%%----------------------------------------------------------------------
-module(mgeew_config).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeew.hrl").

%% --------------------------------------------------------------------
%% External exports
-export([
         start/0,
         start_link/0,
         set/2,
         get/1,
         get_relive_money/0,
         reload_gift/0
        ]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

-define(ETS_CONFIG, ets_config).

%% ====================================================================
%% External functions
%% ====================================================================

start() ->
    {ok, _} = supervisor:start_child(
                mgeew_sup, 
                {?MODULE, 
                 {?MODULE, start_link, []}, transient, 10000, worker, [?MODULE]}).

start_link() ->
    {ok, _} = gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).


%% ====================================================================
%% Server functions
%% ====================================================================

set(Key, Value) ->
    gen_server:call({global, ?MODULE}, {set, Key, Value}).

%% return value or undefined when not found
get(Key) ->
    gen_server:call({global, ?MODULE}, {get, Key}).


get_relive_money() ->
    case ets:lookup(?ETS_CONFIG, relive_money) of
        [{relive_money, Result}] ->
            {ok, Result};
        _ ->
            {error, not_found}
    end.

reload_gift() ->
    gen_server:call({global, ?MODULE}, reload_gift).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    ets:new(?ETS_CONFIG, [protected, named_table, set]),
    ReliveTypes = common_config:get_relive_config(),
    lists:foreach(
      fun(Type) ->
              case is_record(Type, relive_money) of
                  true ->
                      ets:insert(?ETS_CONFIG, {relive_money, Type});
                  false ->
                      ignore
              end
      end, ReliveTypes),
    %%-------------------------------------------------------------------------------


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
handle_call({set, Key, Value}, _From, State) ->
    ets:insert(?ETS_CONFIG, {Key, Value}),
    {reply, ok, State};

handle_call(reload_gift, _, State) ->
    common_config_dyn:reload(gift),
    {reply, ok, State};


handle_call({get, Key}, _From, State) ->
    case ets:lookup(?ETS_CONFIG, Key) of
        [{Key, Value}] ->
            Reply = Value;
        _ ->
            Reply = undefined
    end,
    {reply, Reply, State};


handle_call({register_line, Line}, _From, State) ->
    case ets:lookup(?ETS_CONFIG, lines) of
        [{lines, OldLines}] ->
            case lists:member(Line, OldLines) of
                true ->
                    ignore;
                false ->
                    ets:insert(?ETS_CONFIG, {lines, [Line|OldLines]})
            end;
        _ ->
            ets:insert(?ETS_CONFIG, {lines, [Line]})
    end,
    {reply, ok, State};


handle_call(Request, From, State) ->
    ?ERROR_MSG("unexpected call ~w from ~w", [Request, From]),
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    ?INFO_MSG("unexpected cast ~w", [Msg]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(Info, State) ->
    ?INFO_MSG("unexpected info ~w", [Info]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ?INFO_MSG("~w terminate : ~w, ~w", [self(), Reason, State]),
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

