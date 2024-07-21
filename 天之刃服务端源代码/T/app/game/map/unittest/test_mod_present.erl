%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     test_mod_activity
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------

-module(test_mod_present).

%%
%% Include files
%%
 
 
-define( INFO(F,D),io:format(F, D) ).
-compile(export_all).
-include("common.hrl").

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%


test_suite()->
    ok = test_get(1),
    ok.

test_get(RoleID)->
    DataIn = #m_present_get_tos{present_id=10001},
    Msg = {0,?PRESENT,?PRESENT_GET,DataIn,RoleID,pid,1},
    common_misc:send_to_rolemap(1,Msg),
    ok.
