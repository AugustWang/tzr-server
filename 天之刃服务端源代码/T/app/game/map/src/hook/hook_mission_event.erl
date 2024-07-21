%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     特殊任务事件的hook
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(hook_mission_event).
-export([
         handle/1,
         hook_special_event/2
        ]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeem.hrl").

handle({special_event,RoleId,SpecialEventId}) ->
    mod_mission_handler:handle({listener_dispatch, special_event, RoleId, SpecialEventId});
handle(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["特殊任务事件数据出错",Info]).
%% SpecialEventId 请参考mission_event.hrl
hook_special_event(RoleId,SpecialEventId)->
	mod_mission_handler:handle({listener_dispatch, special_event, RoleId, SpecialEventId}).
