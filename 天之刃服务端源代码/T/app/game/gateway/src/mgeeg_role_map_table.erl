%%% -------------------------------------------------------------------
%%% Author  : QingliangCn
%%% Description :
%%%
%%% Created : 2010-3-15
%%% -------------------------------------------------------------------
-module(mgeeg_role_map_table).

-behaviour(gen_server).

-include("mgeeg.hrl").

-define(ETS_ROLE_VW_MAP, ets_role_vw_map).

-export([
            start/1, 
            start_link/1, 
            get_vwid/1,
            process_name/1
        ]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%%------------------------------------------------------------------------------

start(Line) ->
    {ok, _} = supervisor:start_child(mgeeg_sup, 
                                     {?MODULE,
                                      {?MODULE, start_link, [Line]},
                                       transient, 1000, worker, 
                                      [?MODULE]}).

start_link(Line) ->
    Name = process_name(Line),
    gen_server:start_link({global, Name}, ?MODULE, [], []).

get_vwid(RoleID) ->
    case ets:lookup(?ETS_ROLE_VW_MAP, RoleID) of
    [{RoleID, VwID}] ->
        VwID;
    _ ->
        undefined
    end.

%%------------------------------------------------------------------------------

init([]) ->
    erlang:register(?MODULE, self()),
    ets:new(?ETS_ROLE_VW_MAP, [set, protected, named_table]),
    {ok, #state{}}.

%%------------------------------------------------------------------------------

handle_call({update, RoleID, VwID}, _From, State) ->
    ets:insert(?ETS_ROLE_VW_MAP, {RoleID, VwID}),
    {reply, ok, State};

handle_call(Request, From, State) ->
	?ERROR_MSG("unexpected call ~w from ~w", [Request, From]),
    Reply = ok,
    {reply, Reply, State}.


handle_cast({update, RoleID, VwID}, State) ->
    ets:insert(?ETS_ROLE_VW_MAP, {RoleID, VwID}),
    reply_global_vw_router(RoleID, VwID),
    {noreply, State};

handle_cast({delete, RoleID}, State) ->
    ets:delete(?ETS_ROLE_VW_MAP, RoleID),
    {noreply, State};

    
handle_cast(Msg, State) ->
	?INFO_MSG("unexpected cast ~w", [Msg]),
    
    {noreply, State}.

handle_info(Info, State) ->
	?INFO_MSG("unexpected info ~w", [Info]),
    {noreply, State}.

terminate(Reason, State) ->
	?INFO_MSG("~w terminate : ~w, ~w", [self(), Reason, State]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%------------------------------------------------------------------------------
reply_global_vw_router(RoleID, VwID) ->
    global:send(mgeev_router, {sure_enter, RoleID, VwID}).

process_name(Line) ->
    lists:concat([mgeeg_role_map_table_, Line]).

