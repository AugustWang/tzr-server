%%%----------------------------------------------------------------------
%%% File    : mgeel_sup.erl
%%% Author  : Qingliang
%%% Created : 2010-03-10
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------
-module(mgeel_sup).

-behaviour(supervisor).

-include("mgeel.hrl").

-export([start_link/0]).


-export([
	 init/1
        ]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    {ok,{{one_for_one,10,10}, []}}.



