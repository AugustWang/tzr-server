%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     装备打造的hook
%%% @end
%%% Created : 2011-6-18
%%%-------------------------------------------------------------------
-module(hook_equip_build).

-export([hook/1]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeem.hrl").

%%%===================================================================
%%% API
%%%===================================================================
hook({RoleId, NewEquip}) ->
    hook_achievement(RoleId, NewEquip),
    %% common_mod_goal:hook_equip_build(RoleId, NewEquip),
    ok.


hook_achievement(RoleId, NewEquip)->
    %% 成就系统添加hook
    if NewEquip#p_goods.current_colour >= ?COLOUR_GREEN ->
            catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [100006,304001]});
       true ->
            catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [304001]})
    end,
    ok.
