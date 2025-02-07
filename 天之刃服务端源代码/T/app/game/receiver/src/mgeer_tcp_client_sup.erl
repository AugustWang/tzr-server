%%% -------------------------------------------------------------------
%%% Author  : QingliangCn
%%% Description :
%%%
%%% Created : 2010-3-12
%%% -------------------------------------------------------------------
-module(mgeer_tcp_client_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/0]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1
        ]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------
-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
init([]) ->
    AChild = {mgeer_tcp_client,{mgeer_tcp_client,start_link,[]},
	      transient,2000,worker,[mgeer_tcp_client]},
    {ok,{{simple_one_for_one,10,10}, [AChild]}}.