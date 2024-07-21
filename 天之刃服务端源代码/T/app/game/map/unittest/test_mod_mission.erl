%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     test_mod_activity
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------

-module(test_mod_mission).

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
    

test_do_auto(RoleID)->
    DataIn = #m_mission_do_auto_tos{id=1},
    Msg = {0,?MISSION,?MISSION_DO_AUTO,DataIn,RoleID,pid,1},
    common_misc:send_to_rolemap(1,Msg),
    ok.
