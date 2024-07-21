%%% -------------------------------------------------------------------
%%% Author  : xiaosheng
%%% Description : 学习技能
%%%
%%% Created : 2010-9-5
%%% -------------------------------------------------------------------
-module(hook_skill_learn).
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
%% Parameter: int() RoleID 角色id
%% Parameter: int() SkillID 技能ID
%% Parameter: int() CurLevel 当前等级
%% Returns: ok
%% --------------------------------------------------------------------
%%检查
hook({RoleID, SkillID, CurLevel}) ->
    hook_achievement(RoleID,SkillID,CurLevel),
    common_mod_goal:hook_skill_level_up(RoleID, SkillID, CurLevel),
    ok.

%% 成就系统添加hook
hook_achievement(RoleID,_SkillID,CurLevel) ->
    EventIdList = [303001],
    EventIdList2 = 
        if CurLevel >= 12 ->
                [303002|EventIdList];
           true ->
                EventIdList
        end,
    SkillList = mod_skill:get_role_skill_list(RoleID),
    ReturnPoint = 
        lists:foldl(
          fun(RoleSkill, Acc) ->
                  Acc + RoleSkill#r_role_skill_info.cur_level
          end, 0, SkillList),
    EventIdList3 = 
        if ReturnPoint >= 35 ->
                [100009|EventIdList2];
           true ->
                EventIdList2
        end,
    if EventIdList3 =/= [] ->
            catch common_achievement:hook(#r_achievement_hook{role_id = RoleID,event_ids = EventIdList3});
       true ->
            ignore
    end,
    ok.
       
