%%% -------------------------------------------------------------------
%%% Author  : xiaosheng
%%% Description : 等级变更通知
%%%
%%% Created : 2010-6-4
%%% -------------------------------------------------------------------
-module(hook_level_change).
-export([
         hook/1,
         hook_mission/2
        ]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeem.hrl").

%% --------------------------------------------------------------------
%% Function: hook/1
%% Description: hook检查口
%% Parameter: int() RoleId 角色id
%% Parameter: int() OldLevel 旧等级
%% Parameter: int() NewLevel 新等级
%% Returns: ok
%% --------------------------------------------------------------------
%%检查
hook({RoleId, OldLevel, NewLevel, FactionID}) ->
    hook_log_level(RoleId, NewLevel, FactionID),
    hook_chat(RoleId, OldLevel, NewLevel, FactionID),
    hook_behavior(RoleId, NewLevel),
    hook_mission(RoleId,NewLevel),
    hook_educate(RoleId,OldLevel,NewLevel),
    hook_friend(RoleId,OldLevel,NewLevel),
    hook_family(RoleId,OldLevel,NewLevel),
    hook_achievement(RoleId,OldLevel,NewLevel),
    hook_level_gift(RoleId),
    hook_accumulate_exp(RoleId,NewLevel),
    hook_goal(RoleId,NewLevel),
    mod_conlogin:role_level_up(RoleId, NewLevel),
    mod_pet_feed:change_feed_exp(RoleId,NewLevel),
    %% 当前国家玩家在线榜
    case common_config_dyn:find(etc,do_faction_online_role_rank_map_id) of
        [FactionOnlineRoleRankMapId] ->
            #p_map_role{role_name = RoleName} = mod_map_actor:get_actor_mapinfo(RoleId,role),
            catch global:send(common_map:get_common_map_name(FactionOnlineRoleRankMapId),
                              {mod_role2,{admin_uplevel_faction_online_rank,
                                          {RoleId,RoleName,FactionID,NewLevel,FactionOnlineRoleRankMapId}}});
        _ ->
            ignore
    end,
    ok.


%% ====================================================================
%% 第三方hook代码放置在此
%% ====================================================================

%%传奇目标
hook_goal(RoleId,NewLevel)->
    ?TRY_CATCH( common_mod_goal:hook_level_up(RoleId, NewLevel)).

%%累积经验
hook_accumulate_exp(RoleId,NewLevel)->
    case NewLevel>19 of
        true ->
            ?TRY_CATCH( mod_accumulate_exp:do_update_lv(RoleId,NewLevel));
        false ->
            ignore
    end.

%%记录玩家的级别更新日志
hook_log_level(RoleId, NewLevel, FactionID)->
    Now = common_tool:now(),
    R2 = #r_role_level_log{role_id=RoleId,faction_id=FactionID,level=NewLevel,log_time=Now},
    common_general_log_server:log_role_level(R2).

%%触发任务更新
hook_mission(RoleID,NewLevel) ->
   Msg =  {mod_mission_handler, {listener_dispatch, role_level_up, RoleID, NewLevel}},
   common_misc:send_to_rolemap(RoleID, Msg).

%%行为日志
hook_behavior(RoleId, RoleLevel) ->
    common_behavior:send({role_level, RoleId, RoleLevel}).

%%同等级聊天频道变化
hook_chat(RoleId, OldLevel, NewLevel, FactionID) ->
    RouterData = {level_change, OldLevel, NewLevel, FactionID},
    common_misc:chat_cast_role_router(RoleId, RouterData).

hook_educate(RoleId,OldLevel,NewLevel) ->
    gen_server:cast({global,mgeew_educate_server},{upgrade,RoleId,OldLevel,NewLevel}).

hook_friend(RoleID,OldLevel,NewLevel) ->
    gen_server:cast({global, mod_friend_server}, {upgrade_notice, RoleID, OldLevel, NewLevel}).

hook_family(RoleId,_OldLevel,NewLevel)->
    {ok, RoleBase} = mod_map_role:get_role_base(RoleId),
    FamilyId = RoleBase#p_role_base.family_id,
    if FamilyId > 0 ->
	    ?DEBUG("memberuplevelhookfamily2 ",[]),
	    global:send(mod_family_manager,{member_levelup,FamilyId,RoleId,NewLevel});
       true ->
	    ignore
    end.
	
hook_achievement(RoleId,OldLevel,NewLevel) ->
    common_hook_achievement:hook({mod_role2,{level_change,RoleId,OldLevel,NewLevel}}).

hook_level_gift(RoleId) ->
    mod_level_gift:send_role_level_gift(RoleId).
