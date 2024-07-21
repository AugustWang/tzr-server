%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     对坐骑模块的单元测试
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------

-module(test_mod_equip_mount).

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

test_change(RoleID)->
    DataIn = #m_equip_mount_changecolor_tos{ mountid=3},
    Msg = {0,?EQUIP,?EQUIP_MOUNT_CHANGECOLOR,DataIn,RoleID,pid,1},
    common_misc:send_to_rolemap(1,Msg),
    ok.


test_suite()->
    ok.

test_mountup(RoleID)->
    DataIn = #m_equip_mountup_tos{ mountid=32310101},
    Msg = {0,?EQUIP,?EQUIP_MOUNTUP,DataIn,RoleID,pid,1},
    common_misc:send_to_rolemap(1,Msg),
    ok.

test_mountdown(RoleID)->
    DataIn = #m_equip_mountdown_tos{ mountid=32310101},
    Msg = {0,?EQUIP,?EQUIP_MOUNTDOWN,DataIn,RoleID,pid,1},
    common_misc:send_to_rolemap(1,Msg),
    ok.


