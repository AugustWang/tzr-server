%%% -------------------------------------------------------------------
%%% Author  : xiaosheng
%%% Description : 怪物死亡经验的hook
%%%     哥们，如果组队的队员打怪，那么都可以调用到这里的hook。所以任务计数器同时有效
%%%
%%%
%%% Created : 2010-6-5
%%% -------------------------------------------------------------------
-module(hook_monster_dead_exp).
-export([
         hook/1
        ]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeem.hrl").

%% --------------------------------------------------------------------
%% Function: hook/1
%% Description: hook检查口
%% Parameter: int() RoleId 角色id
%% Parameter: int() MonsterType 怪物类型 怪物类型是与怪物等级直接挂钩的
%% Returns: ok
%% --------------------------------------------------------------------
%%检查
hook({RoleId, MonsterType,_AddExp}) ->
    ?TRY_CATCH( common_mod_goal:hook_monster_dead(RoleId, MonsterType),Err ),
    hook_mission(RoleId, MonsterType),
    common_hook_achievement:hook({mod_monster,{monster_dead,RoleId,MonsterType}}).


%% ====================================================================
%% 第三方hook代码放置在此
%% ====================================================================

%%任务
hook_mission(RoleID, MonsterType) ->
    Msg =  {mod_mission_handler, {listener_dispatch, monster_dead, RoleID, MonsterType}},
    common_misc:send_to_rolemap(RoleID, Msg).
