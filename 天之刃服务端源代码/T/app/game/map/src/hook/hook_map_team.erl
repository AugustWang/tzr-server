%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright (C) www.mingchao.com 2011, 
%%% @doc
%%% 组队hook处理
%%% @end
%%% Created :  8 Jul 2011 by  <caochuncheng2002@gmail.com>
%%%-------------------------------------------------------------------
-module(hook_map_team).

-include("mgeem.hrl").

%% API
-export([
         role_offline/1,
         role_online/2,
         role_enter_team/1,
         role_quit_team/1
        ]).

%%%===================================================================
%%% API
%%%===================================================================
%% 玩家加入队伍hook
role_enter_team({RoleId,TeamId,RoleName}) ->
    ?DEBUG("~ts,RoleId=~w,TeamId=~w",["玩家加入队伍",RoleId,TeamId]),
    common_misc:chat_join_team_channel(RoleName, TeamId),
    %% 成就 add by caochuncheng 201-03-08
    catch common_hook_achievement:hook({mod_map_role,{team_id,RoleId,TeamId,mod_map_actor:get_actor_mapinfo(RoleId,role)}}),
    ok.
%% 玩家退出队伍hook
role_quit_team({RoleId,TeamId,RoleName}) ->
    ?DEBUG("~ts,RoleId=~w,TeamId=~w",["玩家退出队伍",RoleId,TeamId]),
    catch mod_vie_world_fb:do_hook_team_change(RoleId,0),
    catch mod_educate_fb:hook_team_change(RoleId,0),
    catch common_misc:chat_leave_team_channel(RoleName, TeamId),
    catch mod_scene_war_fb:do_hook_quit_team(RoleId),
    catch mod_shuaqi_fb:hook_quit_team(RoleId),
    catch mod_exercise_fb:hook_quit_team(RoleId),
    %% 成就 add by caochuncheng 201-03-08
    catch common_hook_achievement:hook({mod_map_role,{team_id,RoleId,TeamId,mod_map_actor:get_actor_mapinfo(RoleId,role)}}),
    ok.

%% 玩家下线
role_offline(RoleId) ->
    case mod_map_role:get_role_base(RoleId) of
        {ok,RoleBase} ->
            case RoleBase#p_role_base.team_id =/= 0 of
                true ->
                    case global:whereis_name(common_misc:get_team_proccess_name(RoleBase#p_role_base.team_id)) of
                        undefined ->
                            case common_transaction:transaction(
                                   fun() ->
                                           mod_map_role:set_role_base(RoleId,RoleBase#p_role_base{team_id = 0})
                                   end)
                            of
                                {atomic, _} ->
                                    ok;
                                {aborted, Error} ->
                                    ?ERROR_MSG("~ts,error: ~w", ["玩家下线，玩家有队伍但是队伍进程不存在，重设玩家RoleBase.team_id为0出错",Error])
                            end;
                        PId ->
                            PId ! {offline,{RoleId,RoleBase#p_role_base.team_id}}
                    end;
                _ ->
                    ignore
            end;
        _ ->
            ignore
    end.
%% 玩家上线处理
role_online(RoleId,TeamId) ->
    %%catch global:send(mod_team_server, {role_login_again, RoleID, Line, TeamID}),
    case TeamId =/= 0 of
        true ->
            {ok,RoleBase} =  mod_map_role:get_role_base(RoleId),
            case global:whereis_name(common_misc:get_team_proccess_name(TeamId)) of
                undefined ->
                    case common_transaction:transaction(
                           fun() ->
                                   mod_map_role:set_role_base(RoleId,RoleBase#p_role_base{team_id = 0}),
                                   mod_map_team:t_set_role_team_info(RoleId,#r_role_team{role_id = RoleId})
                           end)
                    of
                        {atomic, _} ->
                            ok;
                        {aborted, Error} ->
                            ?ERROR_MSG("~ts,error: ~w", ["玩家上线，玩家有队伍但是队伍进程不存在，重设玩家RoleBase.team_id为0出错",Error])
                    end;
                PId ->
                    MapRoleInfo = mod_map_actor:get_actor_mapinfo(RoleId,role),
                    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
                    [MapName] = common_config_dyn:find(map_info,mgeem_map:get_mapid()),
                    TeamSyncData = #r_role_team_sync_data{
                      role_id = RoleId,
                      map_id = mgeem_map:get_mapid(),
                      map_name = MapName,
                      tx = (MapRoleInfo#p_map_role.pos)#p_pos.tx,
                      ty = (MapRoleInfo#p_map_role.pos)#p_pos.ty,
                      hp = MapRoleInfo#p_map_role.hp,
                      mp = MapRoleInfo#p_map_role.mp,
                      max_hp = MapRoleInfo#p_map_role.max_hp,
                      max_mp = MapRoleInfo#p_map_role.max_mp,
                      level = RoleAttr#p_role_attr.level,
                      five_ele_attr = RoleAttr#p_role_attr.five_ele_attr,
                      category = RoleAttr#p_role_attr.category,
                      skin = RoleAttr#p_role_attr.skin},
                    PId ! {online,{RoleId,TeamId,TeamSyncData}}
            end;
        _ ->
            ignore
    end.
