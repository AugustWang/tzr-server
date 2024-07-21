%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2011, 
%%% @doc
%%% 组队模块功能代码
%%% @end
%%% Created : 10 Jan 2011 by  <caochuncheng>
%%%-------------------------------------------------------------------
-module(mod_map_team).

-include("mgeem.hrl").

%% API
-export([
         do_handle_info/1,
         loop/0,
         get_team_leader_role_id/1
        ]).

-export([init_role_team_info/2,
         get_role_team_info/1,
         erase_role_team_info/1,
         t_set_role_team_info/2,
         set_role_team_info/2]).

%% @doc 初始化角色team信息
init_role_team_info(RoleId, TeamInfo) ->
    case TeamInfo of
        undefined ->
            ignore;
        _ ->
            erlang:put({?role_team, RoleId}, TeamInfo)
    end.
%% @doc 获取角色team信息
get_role_team_info(RoleId) ->
    case erlang:get({?role_team, RoleId}) of
        undefined ->
            {error, not_found};
        TeamInfo ->
            {ok,TeamInfo}
    end.
%% @doc 清除角色team信息
erase_role_team_info(RoleId) ->
    case get_role_team_info(RoleId) of
        {ok, _TeamInfo} ->
            erlang:erase({?role_team, RoleId});
        _ ->
            ignore
    end.

%% @doc 设置角色team信息
t_set_role_team_info(RoleId, TeamInfo) ->
    mod_map_role:update_role_id_list_in_transaction(RoleId, ?role_team, ?role_team_copy),
    erlang:put({?role_team, RoleId}, TeamInfo).

%% @doc 设置角色team信息
set_role_team_info(RoleId, TeamInfo) ->
    case common_transaction:transaction(
           fun() ->
                   t_set_role_team_info(RoleId,TeamInfo)
           end)
    of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("set_role_team_info, error: ~w", [Error]),
            error
    end.
%% 地图每秒循环
loop() ->
    [Interval] = common_config_dyn:find(team,map_proccess_sync_team_data_interval),
    case common_tool:now() rem Interval of
        0 ->
            MapRoleIdList = 
                case common_config_dyn:find(team,get_map_role_type) of
                    [dict] ->
                        case erlang:get(in_map_role) of
                            undefined-> [];
                            L -> L
                        end;
                    _ ->
                        mgeem_map:get_all_roleid()
                end,
            case MapRoleIdList =/= [] of
                true ->
                    loop2(MapRoleIdList);
                _ ->
                    ignore
            end;
        _ ->
            ignore
    end.
loop2(MapRoleIdList) ->
    MapId = mgeem_map:get_mapid(),
    [MapName] = common_config_dyn:find(map_info,MapId),
    %% SyncDataList 结构为[{TeamId,[r_role_team_sync_data,...]},...]
    SyncDataList = 
        lists:foldl(
         fun(RoleId,AccSyncDataList) ->
                 case mod_map_actor:get_actor_mapinfo(RoleId,role) of
                     undefined ->
                         AccSyncDataList;
                     MapRoleInfo ->
                         {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
                         case RoleBase#p_role_base.team_id =/= 0 of
                             true ->
                                 {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
                                 TeamSyncData = #r_role_team_sync_data{
                                   role_id = RoleId,
                                   map_id = MapId,
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
                                 case lists:keyfind(RoleBase#p_role_base.team_id,1,AccSyncDataList) of
                                     false ->
                                         [{RoleBase#p_role_base.team_id,[TeamSyncData]}|AccSyncDataList];
                                     {TeamIdT,AccSubSyncDataList} ->
                                         [{TeamIdT,[TeamSyncData|AccSubSyncDataList]}|
                                          lists:keydelete(TeamIdT,1,AccSyncDataList)]
                                 end;
                             _ ->
                                 AccSyncDataList
                         end
                 end
         end,[],MapRoleIdList),
    lists:foreach(
      fun({TeamId,TeamSyncDataList}) ->
              case global:whereis_name(common_misc:get_team_proccess_name(TeamId)) of
                  undefined ->
                      ignore;
                  PId ->
                      PId ! {sync_team_data,{TeamSyncDataList}}
              end
     end,SyncDataList),
    ok.
%%%===================================================================
%%% API
%%%===================================================================
%% 队长设置拾取队伍的拾取模式变化时，地图相应的变化处理
%% TeamId 队长id
%% PickType 队伍拾取模式
do_handle_info({admin_update_pick_type,Msg}) ->
    do_admin_update_pick_type(Msg);
%% 队伍进程同步队伍信息
do_handle_info({team_proccess_update_data,Msg}) ->
    do_team_proccess_update_data(Msg);
%% 设置玩家组队状态
do_handle_info({admin_update_do_status,Msg}) ->
    do_admin_update_do_status(Msg);

%% 邀请玩家加入队伍请求处理
do_handle_info({Unique, ?TEAM, ?TEAM_INVITE, DataRecord, RoleId, PId}) ->
    do_client_invite({Unique, ?TEAM, ?TEAM_INVITE, DataRecord, RoleId, PId});
do_handle_info({admin_invite,Msg}) ->
    do_admin_invite(Msg);
%% 队员邀请处理
do_handle_info({Unique, ?TEAM, ?TEAM_MEMBER_INVITE, DataRecord, RoleId, PId}) ->
    do_client_member_invite({Unique, ?TEAM, ?TEAM_MEMBER_INVITE, DataRecord, RoleId, PId});
do_handle_info({admin_member_invite,Msg}) ->
    do_admin_member_invite(Msg);
%% 同意邀请加入队伍请求处理
do_handle_info({Unique, ?TEAM, ?TEAM_ACCEPT, DataRecord, RoleId, PId}) ->
    do_client_accept({Unique, ?TEAM, ?TEAM_ACCEPT, DataRecord, RoleId, PId});
do_handle_info({admin_accept,Msg}) ->
    do_admin_accept(Msg);
%% 拒绝加入队伍请求处理
do_handle_info({Unique, ?TEAM, ?TEAM_REFUSE, DataRecord, RoleId, PId}) ->
    do_client_refuse({Unique, ?TEAM, ?TEAM_REFUSE, DataRecord, RoleId, PId});
do_handle_info({admin_refuse,Msg}) ->
    do_admin_refuse(Msg);
%% 玩家离开队伍消息处理
do_handle_info({Unique, ?TEAM, ?TEAM_LEAVE, DataRecord, RoleId, PId}) ->
    do_client_leave({Unique, ?TEAM, ?TEAM_LEAVE, DataRecord, RoleId, PId});
%% 设置玩家组队模式
do_handle_info({Unique, ?TEAM, ?TEAM_PICK, DataRecord, RoleId, PId}) ->
    do_client_pick({Unique, ?TEAM, ?TEAM_PICK, DataRecord, RoleId, PId});
%% 请离队员消息处理
do_handle_info({Unique, ?TEAM, ?TEAM_KICK, DataRecord, RoleId, PId}) ->
    do_client_kick({Unique, ?TEAM, ?TEAM_KICK, DataRecord, RoleId, PId});
%% 移交队长
do_handle_info({Unique, ?TEAM, ?TEAM_CHANGE_LEADER, DataRecord, RoleId, PId}) ->
    do_client_change_leader({Unique, ?TEAM, ?TEAM_CHANGE_LEADER, DataRecord, RoleId, PId});
%% 队长解散队伍请求处理
do_handle_info({Unique, ?TEAM, ?TEAM_DISBAND, DataRecord, RoleId, PId}) ->
    do_client_disband({Unique, ?TEAM, ?TEAM_DISBAND, DataRecord, RoleId, PId});

%% 申请入队消息处理
do_handle_info({Unique, ?TEAM, ?TEAM_APPLY, DataRecord, RoleId, PId}) ->
    do_client_apply({Unique, ?TEAM, ?TEAM_APPLY, DataRecord, RoleId, PId});
do_handle_info({admin_apply,Msg}) ->
    do_admin_apply(Msg);
do_handle_info({admin_apply_accept,Msg})->
    do_admin_apply_accept(Msg);

%% 创建队伍消息处理
do_handle_info({Unique, ?TEAM, ?TEAM_CREATE, DataRecord, RoleId, PId}) ->
    do_client_create({Unique, ?TEAM, ?TEAM_CREATE, DataRecord, RoleId, PId});
    
%% 队伍查询接口
do_handle_info({Unique, ?TEAM, ?TEAM_QUERY, DataRecord, RoleId, PId}) ->
    do_client_query({Unique, ?TEAM, ?TEAM_QUERY, DataRecord, RoleId, PId});

do_handle_info(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["地图队伍模块无法处理此消息",Info]),
    error.
%% 队长设置拾取队伍的拾取模式变化时，地图相应的变化处理
do_admin_update_pick_type({RoleId,LeaderRoleId,PickType}) ->
    case get_role_team_info(RoleId) of
        {ok,MapTeamInfo} ->
            ?DEBUG("~ts.OldPickType=~w,NewPickType=~w",["同步玩家组队拾取模式",MapTeamInfo#r_role_team.pick_type,PickType]),
            if RoleId =:= LeaderRoleId ->
                    set_role_team_info(RoleId,MapTeamInfo#r_role_team{pick_type = PickType,do_status = ?TEAM_DO_STATUS_NORMAL});
               true ->
                    set_role_team_info(RoleId,MapTeamInfo#r_role_team{pick_type = PickType})
            end;
        _ ->
            ?DEBUG("~ts",["要同步玩家的组队状态机，发现玩家没有设置组队信息，信息多的话要极度引起重视"]),
            ignore
    end.
%% 队伍进程同步队伍信息
do_team_proccess_update_data({RoleId,TeamId,TeamProccesName,PickType,TeamRoleList}) ->
    case get_role_team_info(RoleId) of
        {ok,MapTeamInfo} ->
            {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
            case common_transaction:transaction(
                   fun() ->
                           t_set_role_team_info(RoleId,MapTeamInfo#r_role_team{
                                                         team_id = TeamId,
                                                         proccess_name = TeamProccesName,
                                                         pick_type = PickType,
                                                         role_list = TeamRoleList,
                                                         next_bc_time = common_tool:now() + 5,
                                                         do_status = ?TEAM_DO_STATUS_NORMAL}),
                           %% ?DEBUG("~ts,OldTeamId=~w,NewTeamId=~w",["玩家队伍Id变化同步处理",RoleBase#p_role_base.team_id,TeamId]),
                           case RoleBase#p_role_base.team_id =:= TeamId of
                               true ->
                                   ignore;
                               _ ->
                                   mod_map_role:set_role_base(RoleId,RoleBase#p_role_base{team_id = TeamId})
                           end
                   end)
            of
                {atomic, _} ->
                    ok;
                {aborted, Error} ->
                    ?ERROR_MSG("set_role_team_info, error: ~w", [Error]),
                    error
            end,
            %% 设置MapRoleInfo队伍Id变化，并通知前端
            case RoleBase#p_role_base.team_id =:= TeamId of
                true ->
                    ignore;
                _ ->
                    case mod_map_actor:get_actor_mapinfo(RoleId,role) of
                        undefined ->
                            ignore;
                        MapRoleInfo ->
                            mod_map_actor:set_actor_mapinfo(RoleId,role,MapRoleInfo#p_map_role{team_id = TeamId}),
                            R = #m_map_update_actor_mapinfo_toc{actor_id=RoleId, actor_type=?TYPE_ROLE, role_info=MapRoleInfo#p_map_role{team_id = TeamId}},
                            catch mgeem_map:do_broadcast_insence_include([{role, RoleId}], ?MAP, ?MAP_UPDATE_ACTOR_MAPINFO, R, mgeem_map:get_state())
                    end
            end,
            %% 添加处理玩家五行加成功能
            catch do_team_proccess_update_data2({RoleId,TeamId,TeamRoleList,MapTeamInfo}),
            %% 玩家组队状态变化hook
            case TeamId =/= 0 andalso MapTeamInfo#r_role_team.team_id =:= 0 of
                true ->
                    catch hook_map_team:role_enter_team({RoleId,TeamId,RoleBase#p_role_base.role_name});
                _ ->
                    ignore
            end,
            case TeamId =:= 0 andalso MapTeamInfo#r_role_team.team_id =/= 0 of
                true ->
                    catch hook_map_team:role_quit_team({RoleId,MapTeamInfo#r_role_team.team_id,RoleBase#p_role_base.role_name});
                _ ->
                    ignore
            end,
            ok;
        _ ->
            ?ERROR_MSG("~ts,TeamId=~w",["严重问题组队同步不成功",TeamId]),
            ignore
    end.
%% 添加处理玩家五行加成功能
do_team_proccess_update_data2({RoleId,TeamId,TeamRoleList,MapTeamInfo}) ->
    case TeamId =:= 0 andalso MapTeamInfo#r_role_team.team_id =/= 0 of
        true -> %% 玩家退出队伍，删除组队状态
            do_del_role_team_buff(RoleId);
        _ ->
            ignore
    end,
    NewTeamRoleInfo = 
        case lists:keyfind(RoleId,#p_team_role.role_id,TeamRoleList) of
            false ->
                #p_team_role{role_id = RoleId};
            NewTeamRoleInfoT ->
                NewTeamRoleInfoT
        end,
    OldTeamRoleInfo = 
        case lists:keyfind(RoleId,#p_team_role.role_id,MapTeamInfo#r_role_team.role_list) of
            false ->
                #p_team_role{role_id = RoleId};
            OldTeamRoleInfoT ->
                OldTeamRoleInfoT
        end,
    case OldTeamRoleInfo#p_team_role.five_ele_attr =:= NewTeamRoleInfo#p_team_role.five_ele_attr
        andalso OldTeamRoleInfo#p_team_role.five_ele_attr_level =:= NewTeamRoleInfo#p_team_role.five_ele_attr_level
        andalso OldTeamRoleInfo#p_team_role.add_hp =:= NewTeamRoleInfo#p_team_role.add_hp
        andalso OldTeamRoleInfo#p_team_role.add_mp =:= NewTeamRoleInfo#p_team_role.add_mp
        andalso OldTeamRoleInfo#p_team_role.add_phy_attack =:= NewTeamRoleInfo#p_team_role.add_phy_attack
        andalso OldTeamRoleInfo#p_team_role.add_magic_attack =:= NewTeamRoleInfo#p_team_role.add_magic_attack of
        true -> %% 组队状态不变化
            ignore;
        _ ->
            %% 先删除原来的组队状态
            do_del_role_team_buff(RoleId),
            %% 添加新的组队状态
            do_add_role_team_buff(RoleId,NewTeamRoleInfo)
    end.
do_del_role_team_buff(RoleId) ->
    case mod_map_role:get_role_base(RoleId) of
        {ok,RoleBase} ->
            [FiveEleAttrBufTypeList] = common_config_dyn:find(team,five_ele_attr_buf_type_list),
            DelBufTypeList = [PActorBuf#p_actor_buf.buff_type || PActorBuf <- RoleBase#p_role_base.buffs,
                                                                 lists:member(PActorBuf#p_actor_buf.buff_type,FiveEleAttrBufTypeList) =:= true],
            if DelBufTypeList =/= [] ->
                    mod_role_buff:remove_buff(RoleId,DelBufTypeList);
               true ->
                    ignore
            end;
        _ ->
            ignore
    end,
    ok.
do_add_role_team_buff(RoleId,TeamRoleInfo) ->
    [FiveEleAttrBufTypeList] = common_config_dyn:find(team,five_ele_attr_buf_type_list),
    {_Index,AddBufIdList} = 
        lists:foldl(
          fun(Value,{AccIndex,AccAddBufIdList}) ->
                  case Value =/= 0 of
                      true ->
                          AddBufId = 10000 + lists:nth(AccIndex,FiveEleAttrBufTypeList) * 10 + TeamRoleInfo#p_team_role.five_ele_attr_level,
                          {AccIndex + 1,[AddBufId | AccAddBufIdList]};
                      _ ->
                          {AccIndex + 1,AccAddBufIdList}
                  end
          end,{1,[]},[TeamRoleInfo#p_team_role.add_hp,TeamRoleInfo#p_team_role.add_mp,
                      TeamRoleInfo#p_team_role.add_phy_attack,TeamRoleInfo#p_team_role.add_magic_attack]),
    mod_role_buff:add_buff(RoleId,AddBufIdList),
    ok.


%% 设置玩家组队状态
do_admin_update_do_status({RoleId,DoStatus}) ->
    case get_role_team_info(RoleId) of
        {ok,MapTeamInfo} ->
            ?DEBUG("~ts.OldDoStatus=~w,NewDoStatus=~w",["同步玩家组队状态",MapTeamInfo#r_role_team.do_status,DoStatus]),
            set_role_team_info(RoleId, MapTeamInfo#r_role_team{do_status = DoStatus});
        _ ->
            ?DEBUG("~ts",["要同步玩家的组队状态机，发现玩家没有设置组队信息，信息多的话要极度引起重视"]),
            ignore
    end.

%% 邀请玩家加入队伍请求处理
do_client_invite({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_invite2(RoleId,DataRecord) of
        {error,Reason} ->
            do_client_invite_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,MapTeamInfo,RoleTeamInfo,DataRecord2,LeaderRoleId,PickType} ->
            do_client_invite3({Unique, Module, Method, DataRecord2, RoleId, PId},
                              MapTeamInfo,RoleTeamInfo,LeaderRoleId,PickType)
    end.
%% DataRecord 结构为 m_team_invite_tos
do_client_invite2(RoleId,DataRecord) ->
    #m_team_invite_tos{role_id = InviteRoleId} = DataRecord,
    case RoleId =:= InviteRoleId of
        true ->
            erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_SELF});
        _ ->
            next
    end,
    MapRoleInfo =
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_TEAM_INVITE_FAIL});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(InviteRoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_OFFLINE})
    end,
    [MaxMemberCount] = common_config_dyn:find(team,max_member_count),
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    MapTeamInfo = 
        case get_role_team_info(RoleId) of
            {ok,MapTeamInfoT} ->
                case RoleBase#p_role_base.team_id =/= 0 andalso erlang:length(MapTeamInfoT#r_role_team.role_list) >= MaxMemberCount of
                    true ->
                        erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_MAX_LIMIT});
                    _ ->
                        next
                end,
                case lists:keyfind(InviteRoleId,#p_team_role.role_id,MapTeamInfoT#r_role_team.role_list) of
                    false ->
                        next;
                    _ ->
                        erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_IN_SAME_TEAM})
                end,
                MapTeamInfoT;
            _ ->
                #r_role_team{role_id = RoleId}
        end,
    if MapTeamInfo#r_role_team.do_status =:= ?TEAM_DO_STATUS_NORMAL
       orelse MapTeamInfo#r_role_team.do_status =:= ?TEAM_DO_STATUS_INVITE ->
            next;
       true ->
            erlang:throw({error,?_LANG_TEAM_SYSTEM_BUSY})
    end,
    LeaderRoleId = 
        case MapTeamInfo of
            undefined ->
                PickType = 1,
                0;
            _ ->
                PickType = MapTeamInfo#r_role_team.pick_type,
                get_team_leader_role_id(MapTeamInfo#r_role_team.role_list)
        end,
    [MapName] = common_config_dyn:find(map_info,mgeem_map:get_mapid()),
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
    RoleTeamInfo = #p_team_role{
      role_id =  RoleId,
      role_name = RoleBase#p_role_base.role_name,
      faction_id = MapRoleInfo#p_map_role.faction_id,
      sex = RoleBase#p_role_base.sex,
      skin = RoleAttr#p_role_attr.skin,
      map_id = mgeem_map:get_mapid(),
      map_name = MapName,
      tx = (MapRoleInfo#p_map_role.pos)#p_pos.tx,
      ty = (MapRoleInfo#p_map_role.pos)#p_pos.ty,
      hp = MapRoleInfo#p_map_role.hp,
      mp = MapRoleInfo#p_map_role.mp,
      max_hp = MapRoleInfo#p_map_role.max_hp,
      max_mp = MapRoleInfo#p_map_role.max_mp,
      level = RoleAttr#p_role_attr.level,
      is_leader = false,
      is_follow = false,
      is_offline = false,
      offline_time = 0,
      five_ele_attr = RoleAttr#p_role_attr.five_ele_attr,
      five_ele_attr_level = 0,
      add_hp = 0,
      add_mp = 0,
      add_phy_attack = 0,
      add_magic_attack = 0,
      category = RoleAttr#p_role_attr.category
     },
    case RoleBase#p_role_base.team_id =/= 0 andalso 
        MapTeamInfo =/= undefined andalso RoleId =/= LeaderRoleId andalso LeaderRoleId =/= 0 of
        true -> %% 队员邀请处理
            {ok,MapTeamInfo,RoleTeamInfo,DataRecord#m_team_invite_tos{team_id = RoleBase#p_role_base.team_id},LeaderRoleId,PickType};
        _ ->
            {ok,MapTeamInfo,RoleTeamInfo,DataRecord#m_team_invite_tos{team_id = RoleBase#p_role_base.team_id},0,PickType}
    end.
            
    
do_client_invite3({Unique, Module, Method, DataRecord, RoleId, PId},
                  MapTeamInfo,RoleTeamInfo,LeaderRoleId,PickType) ->
    #m_team_invite_tos{role_id = InviteRoleId} = DataRecord,
    set_role_team_info(RoleId,MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_INVITE}),
    common_misc:send_to_rolemap(InviteRoleId, {mod_map_team, 
                                               {admin_invite,{Unique,Module,Method,DataRecord,RoleId,PId,RoleTeamInfo,LeaderRoleId,PickType}}}),
    ok.
do_admin_invite({Unique,Module,Method,DataRecord,RoleId,PId,RoleTeamInfo,LeaderRoleId,PickType}) ->
    ?DEBUG("~ts,DataRecord=~w,RoleId=~w",["Admin Invite处理",DataRecord,RoleId]),
    %% 此时已经切换到被邀请的玩家地图进程
    case catch do_admin_invite2(RoleId,DataRecord,RoleTeamInfo) of
        {error,Reason} ->
            common_misc:send_to_rolemap(RoleId, {mod_map_team,{admin_update_do_status,{RoleId,?TEAM_DO_STATUS_NORMAL}}}),
            do_client_invite_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,InviteMapRoleInfo} ->
            do_admin_invite3({Unique, Module, Method, DataRecord, RoleId, PId,
                              RoleTeamInfo,LeaderRoleId,PickType,InviteMapRoleInfo})
    end.
do_admin_invite2(RoleId,DataRecord,RoleTeamInfo) ->
    #m_team_invite_tos{role_id = InviteRoleId,team_id = TeamId} = DataRecord,
    InviteMapRoleInfo =
        case mod_map_actor:get_actor_mapinfo(InviteRoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_OFFLINE});
            InviteMapRoleInfoT ->
                InviteMapRoleInfoT
        end,
    case InviteMapRoleInfo#p_map_role.faction_id =:= RoleTeamInfo#p_team_role.faction_id of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_COUNTRY})
    end,
    {ok,InviteRoleBase} = mod_map_role:get_role_base(InviteRoleId),
    if TeamId =/= 0 andalso InviteRoleBase#p_role_base.team_id =:= TeamId ->
            erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_IN_SAME_TEAM});
       TeamId =:= 0 andalso InviteRoleBase#p_role_base.team_id =/= 0 ->
            erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_EXIST});
       true ->
            next
    end,
    _MapTeamInfo = 
        case get_role_team_info(InviteRoleId) of
            {ok,MapTeamInfoT} ->
                case lists:keyfind(RoleId,#r_role_team_invite.role_id,MapTeamInfoT#r_role_team.invite_list) of
                    false ->
                        next;
                    _ ->
                        erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_REPEAT})
                end;
            _ ->
                undefined
        end,
    {ok,InviteMapRoleInfo}.
do_admin_invite3({Unique, Module, Method, DataRecord, RoleId, PId,
                  RoleTeamInfo,LeaderRoleId,PickType,InviteMapRoleInfo}) ->
    case LeaderRoleId =/= 0 of
        true -> %% 队员邀请 直接发消息给队长
            LeaderLine = common_misc:get_role_line_by_id(LeaderRoleId),
            SendLeader = #m_team_member_invite_toc{
              op_status = 1,
              member_id = RoleTeamInfo#p_team_role.role_id,
              member_name = RoleTeamInfo#p_team_role.role_name,
              role_id = InviteMapRoleInfo#p_map_role.role_id,
              role_name = InviteMapRoleInfo#p_map_role.role_name},
            ?DEBUG("~ts,SendLeader=~w",["组队模块Invite",SendLeader]),
            common_misc:send_to_rolemap(RoleId, {mod_map_team,{admin_update_do_status,{RoleId,?TEAM_DO_STATUS_NORMAL}}}),
            common_misc:unicast(LeaderLine, LeaderRoleId, ?DEFAULT_UNIQUE, ?TEAM, ?TEAM_MEMBER_INVITE, SendLeader);
        _ ->
            %% @doc 设置角色team信息
            InviteMapTeamInfo = 
                case get_role_team_info(InviteMapRoleInfo#p_map_role.role_id) of
                    {ok,InviteMapTeamInfoT} ->
                        InviteMapTeamInfoT#r_role_team{invite_list = [#r_role_team_invite{
                                                                         role_id = RoleId,
                                                                         invite_id = InviteMapRoleInfo#p_map_role.role_id,
                                                                         invite_type = 0,
                                                                         team_id = DataRecord#m_team_invite_tos.team_id,
                                                                         invite_time = common_tool:now(),
                                                                         invite_status = 0}|InviteMapTeamInfoT#r_role_team.invite_list]};
                    _ ->
                        #r_role_team{role_id = InviteMapRoleInfo#p_map_role.role_id,team_id = 0,
                                     proccess_name = undefined,role_list = [],next_bc_time = 0,
                                     pick_type = 1,
                                     invite_list = [#r_role_team_invite{
                                                       role_id = RoleId,
                                                       invite_id = InviteMapRoleInfo#p_map_role.role_id,
                                                       invite_type = 0,
                                                       team_id = DataRecord#m_team_invite_tos.team_id,
                                                       invite_time = common_tool:now(),
                                                       invite_status = 0}]}
                end,
            set_role_team_info(InviteMapRoleInfo#p_map_role.role_id,InviteMapTeamInfo),
            SendSelf=#m_team_invite_toc{
              succ = true,return_self = true,
              role_id = InviteMapRoleInfo#p_map_role.role_id,
              role_name =InviteMapRoleInfo#p_map_role.role_name,
              type_id= DataRecord#m_team_invite_tos.type,
              team_id = DataRecord#m_team_invite_tos.team_id, 
              pick_type = PickType},
            ?DEBUG("~ts,SendSelf=~w",["组队模块Invite",SendSelf]),
            common_misc:send_to_rolemap(RoleId, {mod_map_team,{admin_update_do_status,{RoleId,?TEAM_DO_STATUS_NORMAL}}}),
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
            SendInvite = #m_team_invite_toc{
              succ = true,return_self = false,
              role_id = RoleTeamInfo#p_team_role.role_id,
              role_name = RoleTeamInfo#p_team_role.role_name,
              type_id= DataRecord#m_team_invite_tos.type,
              team_id = DataRecord#m_team_invite_tos.team_id, 
              pick_type = PickType },
            InviteLine = common_misc:get_role_line_by_id(InviteMapRoleInfo#p_map_role.role_id),
            ?DEBUG("~ts,SendInvite=~w",["组队模块Invite",SendInvite]),
            common_misc:unicast(InviteLine, InviteMapRoleInfo#p_map_role.role_id, ?DEFAULT_UNIQUE, Module, Method, SendInvite)
    end.
do_client_invite_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf=#m_team_invite_toc{succ = false, reason=Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Invite",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

%% 队员邀请处理
do_client_member_invite({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_member_invite2(RoleId,DataRecord) of
        {error,Reason} ->
            do_client_member_invite_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,RoleBase,MapTeamInfo} ->
            do_client_member_invite3({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase,MapTeamInfo)
    end.
do_client_member_invite2(RoleId,DataRecord) ->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case RoleBase#p_role_base.team_id =:= 0 of
        true ->
            erlang:throw({error,?_LANG_TEAM_NOT_IN});
        _ ->
            next
    end,
    MapTeamInfo = 
        case get_role_team_info(RoleId) of
            {ok,MapTeamInfoT} ->
                MapTeamInfoT;
            _ ->
                erlang:throw({error,?_LANG_TEAM_NOT_IN})
        end,
    case RoleId =:= get_team_leader_role_id(MapTeamInfo#r_role_team.role_list) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_LEADER_AUTHORITY})
    end,
    case DataRecord#m_team_member_invite_tos.op_type =:= 1 orelse DataRecord#m_team_member_invite_tos.op_type =:= 2 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_MEMBER_INVITE_PARAM})
    end,
    case common_misc:is_role_online(DataRecord#m_team_member_invite_tos.role_id) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_OFFLINE})
    end,
    case lists:keyfind(DataRecord#m_team_member_invite_tos.role_id,#p_team_role.role_id,MapTeamInfo#r_role_team.role_list) of
        false ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_IN_SAME_TEAM})
    end,
    {ok,RoleBase,MapTeamInfo}.
do_client_member_invite3({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase,MapTeamInfo) ->
    case DataRecord#m_team_member_invite_tos.op_type =:= 2 of
        true -> %% 拒绝队员邀请玩家入队请求处理
            SendSelf = #m_team_member_invite_toc{
              op_status = 2,
              member_id = DataRecord#m_team_member_invite_tos.member_id,
              member_name = DataRecord#m_team_member_invite_tos.member_name,
              role_id = DataRecord#m_team_member_invite_tos.role_id,
              role_name = DataRecord#m_team_member_invite_tos.role_name,
              succ = true,
              return_self= true,
              reason=?_LANG_TEAM_MEMBER_INVITE_REFUSE_L},
            ?DEBUG("~ts,SendSelf=~w",["组队模块Member Invite",SendSelf]),
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
            SendMember = #m_team_member_invite_toc{
              op_status = 2,
              member_id = DataRecord#m_team_member_invite_tos.member_id,
              member_name = DataRecord#m_team_member_invite_tos.member_name,
              role_id = DataRecord#m_team_member_invite_tos.role_id,
              role_name = DataRecord#m_team_member_invite_tos.role_name,
              succ = true,
              op_type = DataRecord#m_team_member_invite_tos.op_type,
              return_self= false,
              reason=?_LANG_TEAM_MEMBER_INVITE_REFUSE_M},
            catch common_misc:unicast({role,DataRecord#m_team_member_invite_tos.member_id}, ?DEFAULT_UNIQUE, Module, Method, SendMember);
        _ -> %% 同意队员邀请玩家入队请求处理
            set_role_team_info(RoleId,MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_MEMBER_INVITE}),
            common_misc:send_to_rolemap(DataRecord#m_team_member_invite_tos.role_id, 
                                        {mod_map_team, 
                                         {admin_member_invite,
                                          {Unique,Module,Method,DataRecord,RoleId,PId,
                                           MapTeamInfo#r_role_team.team_id,RoleBase#p_role_base.faction_id,MapTeamInfo#r_role_team.pick_type}}})
    end.
do_admin_member_invite({Unique,Module,Method,DataRecord,RoleId,PId,TeamId,FactionId,PickType}) ->
    case catch do_admin_member_invite2(RoleId,DataRecord,FactionId) of
        {error,Reason} ->
            common_misc:send_to_rolemap(RoleId, {mod_map_team,{admin_update_do_status,{RoleId,?TEAM_DO_STATUS_NORMAL}}}),
            do_client_member_invite_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok} ->
            do_admin_member_invite3({Unique,Module,Method,DataRecord,RoleId,PId,TeamId,FactionId,PickType})
    end.
do_admin_member_invite2(_RoleId,DataRecord,FactionId) ->
    case DataRecord#m_team_member_invite_tos.op_type =:= 1 orelse DataRecord#m_team_member_invite_tos.op_type =:= 2 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_MEMBER_INVITE_PARAM})
    end,
    InviteMapRoleInfo =
        case mod_map_actor:get_actor_mapinfo(DataRecord#m_team_member_invite_tos.role_id,role) of
            undefined ->
                erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_OFFLINE});
            InviteMapRoleInfoT ->
                InviteMapRoleInfoT
        end,
    case InviteMapRoleInfo#p_map_role.faction_id =:= FactionId of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_COUNTRY})
    end,
    {ok,RoleBase} = mod_map_role:get_role_base(DataRecord#m_team_member_invite_tos.role_id),
    case RoleBase#p_role_base.team_id =/= 0 of
        true ->
            erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_EXIST});
        _ ->
            next
    end,
    _MapTeamInfo = 
        case get_role_team_info(DataRecord#m_team_member_invite_tos.role_id) of
            {ok,MapTeamInfoT} ->
                case lists:keyfind(DataRecord#m_team_member_invite_tos.member_id,#r_role_team_invite.role_id,MapTeamInfoT#r_role_team.invite_list) of
                    false ->
                        next;
                    _ ->
                        erlang:throw({error,?_LANG_TEAM_INVITE_FAIL_REPEAT})
                end;
            _ ->
                undefined
        end,
    {ok}.
do_admin_member_invite3({Unique,Module,Method,DataRecord,RoleId,PId,TeamId,_FactionId,PickType}) ->
    InviteMapTeamInfo = 
        case get_role_team_info(DataRecord#m_team_member_invite_tos.role_id) of
            {ok,InviteMapTeamInfoT} ->
                InviteMapTeamInfoT#r_role_team{invite_list = 
                                                   [#r_role_team_invite{
                                                       role_id = DataRecord#m_team_member_invite_tos.member_id,
                                                       invite_id = DataRecord#m_team_member_invite_tos.role_id,
                                                       invite_type = 0,
                                                       team_id = TeamId,
                                                       invite_time = common_tool:now(),
                                                       invite_status = 0}|InviteMapTeamInfoT#r_role_team.invite_list]};
            _ ->
                #r_role_team{role_id = DataRecord#m_team_member_invite_tos.role_id,team_id = 0,
                             proccess_name = undefined,role_list = [],next_bc_time = 0,
                             pick_type = 1,
                             invite_list = [#r_role_team_invite{
                                               role_id = DataRecord#m_team_member_invite_tos.member_id,
                                               invite_id = DataRecord#m_team_member_invite_tos.role_id,
                                               invite_type = 0,
                                               team_id = TeamId,
                                               invite_time = common_tool:now(),
                                               invite_status = 0}]}
        end,
    set_role_team_info(DataRecord#m_team_member_invite_tos.role_id,InviteMapTeamInfo),
    SendInvite = #m_team_invite_toc{
      succ = true,
      return_self = false,
      role_id = DataRecord#m_team_member_invite_tos.member_id,
      role_name = DataRecord#m_team_member_invite_tos.member_name,
      team_id = TeamId,
      pick_type = PickType,
      leader_id = RoleId},
    catch common_misc:unicast({role,DataRecord#m_team_member_invite_tos.role_id}, ?DEFAULT_UNIQUE, ?TEAM, ?TEAM_INVITE, SendInvite),
    SendSelf = #m_team_member_invite_toc{
      op_status = 2,
      member_id = DataRecord#m_team_member_invite_tos.member_id,
      member_name = DataRecord#m_team_member_invite_tos.member_name,
      role_id = DataRecord#m_team_member_invite_tos.role_id,
      role_name = DataRecord#m_team_member_invite_tos.role_name,
      succ = true,
      op_type = DataRecord#m_team_member_invite_tos.op_type,
      return_self= true,
      reason=?_LANG_TEAM_MEMBER_INVITE_ACCEPT_L},
    common_misc:send_to_rolemap(RoleId, {mod_map_team,{admin_update_do_status,{RoleId,?TEAM_DO_STATUS_NORMAL}}}),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    SendMember = #m_team_member_invite_toc{
      op_status = 2,
      member_id = DataRecord#m_team_member_invite_tos.member_id,
      member_name = DataRecord#m_team_member_invite_tos.member_name,
      role_id = DataRecord#m_team_member_invite_tos.role_id,
      role_name = DataRecord#m_team_member_invite_tos.role_name,
      succ = true,
      op_type = DataRecord#m_team_member_invite_tos.op_type,
      return_self= false,
      reason=?_LANG_TEAM_MEMBER_INVITE_ACCEPT_M},
    catch common_misc:unicast({role,DataRecord#m_team_member_invite_tos.member_id}, ?DEFAULT_UNIQUE, Module, Method, SendMember),
    ok.
do_client_member_invite_error({Unique, Module, Method, DataRecord, _RoleId, PId},Reason) ->
    SendSelf = #m_team_member_invite_toc{
      op_status = 2,succ = false,
      op_type = DataRecord#m_team_member_invite_tos.op_type,
      return_self= true,reason=Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Member Invite",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

%% 同意邀请加入队伍请求处理
do_client_accept({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_accept2(RoleId,DataRecord) of
        {error,Reason} ->
            do_client_accept_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,RoleTeamInfo} ->
            do_client_accept3({Unique, Module, Method, DataRecord, RoleId, PId},RoleTeamInfo)
    end.
%% DataRecord 结构为 m_team_accept_tos
do_client_accept2(RoleId,DataRecord) ->
    #m_team_accept_tos{role_id = InvitedRoleId} = DataRecord,
    case RoleId =:= InvitedRoleId of
        true ->
            erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL});
        _ ->
            next
    end,
    MapRoleInfo =
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(InvitedRoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL_INVITED_OFFLINE})
    end,
    MapTeamInfo = 
        case get_role_team_info(RoleId) of
            {ok,MapTeamInfoT} ->
                case lists:keyfind(RoleId,#p_team_role.role_id,MapTeamInfoT#r_role_team.role_list) of
                    false ->
                        next;
                    _ ->
                        erlang:throw({error,?_LANG_TEAM_ACCEPT_REPEAT})
                end,
                if MapTeamInfoT#r_role_team.do_status =:= ?TEAM_DO_STATUS_ACCEPT  ->
                        %% 上一条同意的消息未处理完成，玩家操作过快
                        erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL_DO_DO});
                   MapTeamInfoT#r_role_team.do_status =:= ?TEAM_DO_STATUS_CREATE ->
                        erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL_DO_DO});
                   true ->
                        next
                end,
                MapTeamInfoT;
            _ ->
                erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL})
        end,
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case RoleBase#p_role_base.team_id =/= 0 of
        true ->
            erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL_JOIN_TEAM});
        _ ->
            next
    end,
    case lists:keyfind(InvitedRoleId,#r_role_team_invite.role_id,MapTeamInfo#r_role_team.invite_list) of
        false ->
            erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL});
        _ ->
            next
    end,
    %% 设置玩家正在同意组队
    InviteList = lists:keydelete(InvitedRoleId,#r_role_team_invite.role_id,MapTeamInfo#r_role_team.invite_list),
    set_role_team_info(RoleId, MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_ACCEPT,invite_list = InviteList}),
    [MapName] = common_config_dyn:find(map_info,mgeem_map:get_mapid()),
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
    RoleTeamInfo = #p_team_role{
      role_id =  RoleId,
      role_name = RoleBase#p_role_base.role_name,
      faction_id = MapRoleInfo#p_map_role.faction_id,
      sex = RoleBase#p_role_base.sex,
      skin = RoleAttr#p_role_attr.skin,
      map_id = mgeem_map:get_mapid(),
      map_name = MapName,
      tx = (MapRoleInfo#p_map_role.pos)#p_pos.tx,
      ty = (MapRoleInfo#p_map_role.pos)#p_pos.ty,
      hp = MapRoleInfo#p_map_role.hp,
      mp = MapRoleInfo#p_map_role.mp,
      max_hp = MapRoleInfo#p_map_role.max_hp,
      max_mp = MapRoleInfo#p_map_role.max_mp,
      level = RoleAttr#p_role_attr.level,
      is_leader = false,
      is_follow = false,
      is_offline = false,
      offline_time = 0,
      five_ele_attr = RoleAttr#p_role_attr.five_ele_attr,
      five_ele_attr_level = 0,
      add_hp = 0,
      add_mp = 0,
      add_phy_attack = 0,
      add_magic_attack = 0,
      category = RoleAttr#p_role_attr.category
     },
    {ok,RoleTeamInfo}.

do_client_accept3({Unique, Module, Method, DataRecord, RoleId, PId},RoleTeamInfo) ->
    common_misc:send_to_rolemap(DataRecord#m_team_accept_tos.role_id, 
                                {mod_map_team,{admin_accept,{Unique,Module,Method,DataRecord,RoleId,PId,RoleTeamInfo}}}),
    ok.
do_admin_accept({Unique,Module,Method,DataRecord,RoleId,PId,RoleTeamInfo}) ->
    case catch do_admin_accept2(RoleId,DataRecord) of
        {error,Reason} ->
            common_misc:send_to_rolemap(RoleId, {mod_map_team,{admin_update_do_status,{RoleId,?TEAM_DO_STATUS_NORMAL}}}),
            do_client_accept_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,TeamPid,InvitedRoleTeamInfo} ->
            do_admin_accept3({Unique, Module, Method, DataRecord, RoleId, PId},
                             RoleTeamInfo,TeamPid,InvitedRoleTeamInfo)
    end.
do_admin_accept2(_RoleId,DataRecord) ->
    #m_team_accept_tos{role_id = InvitedRoleId} = DataRecord,
    MapRoleInfo =
        case mod_map_actor:get_actor_mapinfo(InvitedRoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL_INVITED_OFFLINE});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(InvitedRoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL_INVITED_OFFLINE})
    end,
    MapTeamInfo = 
        case get_role_team_info(InvitedRoleId) of
            {ok,MapTeamInfoT} ->
                case MapTeamInfoT#r_role_team.do_status =:= ?TEAM_DO_STATUS_NORMAL of
                    true -> %% 上一条同意的消息未处理完成，玩家操作过快
                        next;
                    _ ->
                        erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL_JOIN_TEAM})
                end,
                MapTeamInfoT;
            _ ->
                erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL})
        end,
    {ok,RoleBase} = mod_map_role:get_role_base(InvitedRoleId),
    [MapName] = common_config_dyn:find(map_info,mgeem_map:get_mapid()),
    {ok,RoleAttr} = mod_map_role:get_role_attr(InvitedRoleId),
    RoleTeamInfo = #p_team_role{
      role_id =  InvitedRoleId,
      role_name = RoleBase#p_role_base.role_name,
      faction_id = MapRoleInfo#p_map_role.faction_id,
      sex = RoleBase#p_role_base.sex,
      skin = RoleAttr#p_role_attr.skin,
      map_id = mgeem_map:get_mapid(),
      map_name = MapName,
      tx = (MapRoleInfo#p_map_role.pos)#p_pos.tx,
      ty = (MapRoleInfo#p_map_role.pos)#p_pos.ty,
      hp = MapRoleInfo#p_map_role.hp,
      mp = MapRoleInfo#p_map_role.mp,
      max_hp = MapRoleInfo#p_map_role.max_hp,
      max_mp = MapRoleInfo#p_map_role.max_mp,
      level = RoleAttr#p_role_attr.level,
      is_leader = false,
      is_follow = false,
      is_offline = false,
      offline_time = 0,
      five_ele_attr = RoleAttr#p_role_attr.five_ele_attr,
      five_ele_attr_level = 0,
      add_hp = 0,
      add_mp = 0,
      add_phy_attack = 0,
      add_magic_attack = 0,
      category = RoleAttr#p_role_attr.category
     },
    %% 是加入队伍，还是创建队伍
    TeamPid = 
        case RoleBase#p_role_base.team_id =/= 0 andalso MapTeamInfo =/= undefined
            andalso MapTeamInfo#r_role_team.team_id =/= 0
            andalso MapTeamInfo#r_role_team.team_id =:= RoleBase#p_role_base.team_id of
            true ->
                case global:whereis_name(MapTeamInfo#r_role_team.proccess_name) of
                    undefined ->
                        erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL_NOT_INVITE});
                    TeamPidT ->
                        TeamPidT
                end;
            _ ->
                case RoleBase#p_role_base.team_id =/= 0 of
                    true ->
                        erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL_NOT_INVITE});
                    _ -> %% 创建新队伍
                        case global:whereis_name(mod_team_server) of
                            undefined ->
                                erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL});
                            _ ->
                                undefined
                        end
                end
        end,       
    {ok,TeamPid,RoleTeamInfo}.
do_admin_accept3({Unique,Module,Method,DataRecord,RoleId,PId},
                 RoleTeamInfo,TeamPid,InvitedRoleTeamInfo) ->
    case TeamPid of
        undefined -> %% 创建队伍
            global:send(mod_team_server,{create_team_procces_by_accept,{RoleId,Unique,Module,Method,DataRecord,InvitedRoleTeamInfo,RoleTeamInfo}});
        _ -> %% 加入队伍
            TeamPid ! {accept,{Unique,Module,Method,DataRecord,RoleId,PId,RoleTeamInfo}}
    end.

do_client_accept_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf=#m_team_accept_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Accept",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).


%% 拒绝加入队伍请求处理
do_client_refuse({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_refuse2(RoleId,DataRecord) of
        {ok,ignore} ->
            ignore;
        {ok,RoleName} ->
            do_client_refuse3({Unique, Module, Method, DataRecord, RoleId, PId},RoleName)
    end.
%% DataRecord结构为 m_team_refuse_tos
do_client_refuse2(RoleId,DataRecord) ->
    case mod_map_actor:get_actor_mapinfo(RoleId,role) of
        undefined ->
            RoleName = "";
        MapRoleInfo ->
            RoleName = MapRoleInfo#p_map_role.role_name
    end,
    #m_team_refuse_tos{role_id = InviteRoleId } = DataRecord,
    case get_role_team_info(RoleId) of
        {ok,MapTeamInfo} ->
            InviteList = lists:keydelete(InviteRoleId,#r_role_team_invite.role_id,MapTeamInfo#r_role_team.invite_list),
            set_role_team_info(RoleId,MapTeamInfo#r_role_team{invite_list = InviteList}),
            ok;
        _ ->
            next
    end,
    case common_misc:is_role_online(InviteRoleId) of
        true ->
            {ok,RoleName};
        _ ->
            {ok,ignore}
    end.
do_client_refuse3({Unique, Module, Method, DataRecord, RoleId, PId},RoleName) ->
    common_misc:send_to_rolemap(DataRecord#m_team_refuse_tos.role_id, 
                                {mod_map_team,{admin_refuse,{Unique,Module,Method,DataRecord,RoleId,PId,RoleName}}}),
    ok.
do_admin_refuse({_Unique,Module,Method,DataRecord,RoleId,_PId,RoleName}) ->
    SendInvite = #m_team_refuse_toc{
      role_id = RoleId,
      role_name = RoleName, 
      team_id = DataRecord#m_team_refuse_tos.team_id, 
      type_id=DataRecord#m_team_refuse_tos.type_id},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Refuse",SendInvite]),
    common_misc:unicast({role,DataRecord#m_team_refuse_tos.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendInvite),
    case DataRecord#m_team_refuse_tos.leader_id =/= 0 
        andalso common_misc:is_role_online(DataRecord#m_team_refuse_tos.leader_id) of
        true ->
            common_misc:unicast({role,DataRecord#m_team_refuse_tos.leader_id}, ?DEFAULT_UNIQUE, Module, Method, SendInvite);
        _ ->
            ignore
    end.
    

%% 玩家离开队伍消息处理
do_client_leave({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_leave2(RoleId,DataRecord) of
        {error,Reason} ->
            do_client_leave_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,not_team_proccess,RoleBase,DataRecord2} ->
            do_client_leave4({Unique, Module, Method, DataRecord2, RoleId, PId},RoleBase);
        {ok,DataRecord3,MapTeamInfo} ->
            do_client_leave3({Unique, Module, Method, DataRecord3, RoleId, PId},MapTeamInfo)
    end.
do_client_leave2(RoleId,DataRecord) ->
    _MapRoleInfo =
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_TEAM_NOT_IN});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(RoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_NOT_IN})
    end,
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case RoleBase#p_role_base.team_id =/= 0 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_NOT_IN})
    end,
    case RoleBase#p_role_base.team_id =:= DataRecord#m_team_leave_tos.team_id
        andalso DataRecord#m_team_leave_tos.team_id =/= 0 of
        true ->
            DataRecord2 = DataRecord;
        _ ->
            DataRecord2 = DataRecord#m_team_leave_tos{team_id = RoleBase#p_role_base.team_id}
    end,
    MapTeamInfo =
        case get_role_team_info(RoleId) of
            {ok,MapTeamInfoT} ->
                case global:whereis_name(MapTeamInfoT#r_role_team.proccess_name) of
                    undefined -> %% 玩家所在的队伍进程已经不存在
                        erlang:throw({ok,not_team_proccess,RoleBase,DataRecord2});
                    _ ->
                        MapTeamInfoT
                end;
            _->
                erlang:throw({ok,not_team_proccess,RoleBase,DataRecord2})
        end, 
    {ok,DataRecord2,MapTeamInfo}.
do_client_leave3({Unique, Module, Method, DataRecord, RoleId, PId},MapTeamInfo) ->
    set_role_team_info(RoleId,MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_LEAVE}),
    global:send(MapTeamInfo#r_role_team.proccess_name,{leave,{Unique, Module, Method, DataRecord, RoleId, PId}}).

do_client_leave4({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase) ->
    case common_transaction:transaction(
           fun() ->
                   case RoleBase#p_role_base.team_id =/= 0 of
                       true ->
                           mod_map_role:set_role_base(RoleId,RoleBase#p_role_base{team_id = 0});
                       _ ->
                           ignore
                   end,
                   t_set_role_team_info(RoleId,#r_role_team{role_id = RoleId})
           end)
    of
        {atomic, _} ->
            SendSelf=#m_team_leave_toc{succ = true},
            ?DEBUG("~ts,SendSelf=~w",["组队模块Leave",SendSelf]),
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf);
        {aborted, Error} ->
            ?ERROR_MSG("set_role_team_info, error: ~w", [Error]),
            do_client_leave_error({Unique, Module, Method, DataRecord, RoleId, PId},?_LANG_TEAM_NOT_IN)
    end.
do_client_leave_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf=#m_team_leave_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Leave",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

%% 设置玩家组队模式
do_client_pick({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_pick2(RoleId,DataRecord) of
        {error,Reason} ->
            do_client_pick_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,not_team_proccess,RoleBase} ->
            do_client_pidk4({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase);
        {ok,MapTeamInfo} ->
            do_client_pidk3({Unique, Module, Method, DataRecord, RoleId, PId},MapTeamInfo)
    end.
do_client_pick2(RoleId,DataRecord) ->
    case DataRecord#m_team_pick_tos.pick_type =:= 1
        orelse DataRecord#m_team_pick_tos.pick_type =:= 2 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_PICK_TYPE_NOT_VALID})
    end,
    _MapRoleInfo =
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_TEAM_NOT_IN});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(RoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_NOT_IN})
    end,
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case RoleBase#p_role_base.team_id =/= 0 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_NOT_IN})
    end,
    MapTeamInfo =
        case get_role_team_info(RoleId) of
            {ok,MapTeamInfoT} ->
                case global:whereis_name(MapTeamInfoT#r_role_team.proccess_name) of
                    undefined -> %% 玩家所在的队伍进程已经不存在
                        erlang:throw({ok,not_team_proccess,RoleBase});
                    _ ->
                        MapTeamInfoT
                end;
            _->
                erlang:throw({ok,not_team_proccess,RoleBase})
        end,
    case RoleId =:= get_team_leader_role_id(MapTeamInfo#r_role_team.role_list) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_LEADER_AUTHORITY})
    end,
    case DataRecord#m_team_pick_tos.pick_type =:= MapTeamInfo#r_role_team.pick_type of
        true ->
            erlang:throw({error,?_LANG_TEAM_PICK_TYPE_REPEAT});
        _ ->
            next
    end,
    {ok,MapTeamInfo}.
do_client_pidk3({Unique, Module, Method, DataRecord, RoleId, PId},MapTeamInfo) ->
    set_role_team_info(RoleId,MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_PICK}),
    global:send(MapTeamInfo#r_role_team.proccess_name,{pick,{Unique, Module, Method, DataRecord, RoleId, PId}}).

do_client_pidk4({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase) ->
    case common_transaction:transaction(
           fun() ->
                   case RoleBase#p_role_base.team_id =/= 0 of
                       true ->
                           mod_map_role:set_role_base(RoleId,RoleBase#p_role_base{team_id = 0});
                       _ ->
                           ignore
                   end,
                   t_set_role_team_info(RoleId,#r_role_team{role_id = RoleId})
           end)
    of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("set_role_team_info, error: ~w", [Error])
    end,
    do_client_leave_error({Unique, Module, Method, DataRecord, RoleId, PId},?_LANG_TEAM_NOT_EXIST).
do_client_pick_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf=#m_team_pick_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Pick",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

%% 请离队员消息处理
do_client_kick({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_kick2(RoleId,DataRecord) of
        {error,Reason} ->
            do_client_kick_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,RoleBase,MapTeamInfo} ->
            do_client_kick3({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase,MapTeamInfo)
    end.
do_client_kick2(RoleId,DataRecord) ->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case RoleBase#p_role_base.team_id =/= 0 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_NOT_IN})
    end,
    MapTeamInfo = 
        case get_role_team_info(RoleId) of
            {ok,MapTeamInfoT} ->
                MapTeamInfoT;
            _ ->
                ?DEBUG("~ts,RoleBase_TeamId=~w",["玩家组队数据不同步",RoleBase#p_role_base.team_id]),
                erlang:throw({error,?_LANG_TEAM_NOT_IN})
        end,
    if RoleId =:= DataRecord#m_team_kick_tos.role_id ->
            erlang:throw({error,?_LANG_TEAM_KICK_FAIL_SELF});
       true ->
            next
    end,
    case RoleId =:= get_team_leader_role_id(MapTeamInfo#r_role_team.role_list) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_LEADER_AUTHORITY})
    end,
    case lists:keyfind(DataRecord#m_team_kick_tos.role_id,#p_team_role.role_id,MapTeamInfo#r_role_team.role_list) of
        false ->
            erlang:throw({error,?_LANG_TEAM_KICK_FAIL_NOT_IN});
        _ ->
            next
    end,
    {ok,RoleBase,MapTeamInfo}.
do_client_kick3({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase,MapTeamInfo) ->
    case global:whereis_name(MapTeamInfo#r_role_team.proccess_name) of
        undefined -> %% 队伍进程已经不存在处理
            case common_transaction:transaction(
                   fun() ->
                           case RoleBase#p_role_base.team_id =/= 0 of
                               true ->
                                   mod_map_role:set_role_base(RoleId,RoleBase#p_role_base{team_id = 0});
                               _ ->
                                   ignore
                           end,
                           t_set_role_team_info(RoleId,#r_role_team{role_id = RoleId})
                   end)
            of
                {atomic, _} ->
                    ok;
                {aborted, Error} ->
                    ?ERROR_MSG("set_role_team_info, error: ~w", [Error])
            end,
            KickTeamRoleInfo = lists:keyfind(DataRecord#m_team_kick_tos.role_id,#p_team_role.role_id,MapTeamInfo#r_role_team.role_list),
            SendSelf =  #m_team_kick_toc{succ = true, role_list = [],
                                         role_id = KickTeamRoleInfo#p_team_role.role_id,
                                         role_name = KickTeamRoleInfo#p_team_role.role_name, 
                                         team_id = MapTeamInfo#r_role_team.team_id},
            ?DEBUG("~ts,SendSelf=~w",["组队模块Kick",SendSelf]),
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
            SendAutoDisband = #m_team_auto_disband_toc{reason = ?_LANG_TEAM_AUTO_DISBAND},
            common_misc:unicast2(PId, ?DEFAULT_UNIQUE, ?TEAM, ?TEAM_AUTO_DISBAND, SendAutoDisband);
        _ ->
            set_role_team_info(RoleId,MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_KICK}),
            global:send(MapTeamInfo#r_role_team.proccess_name,{kick,{Unique, Module, Method, DataRecord, RoleId, PId}})
    end.

do_client_kick_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf = #m_team_kick_toc{succ = false, reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Kick",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).
    
%% 移交队长
do_client_change_leader({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_change_leader2(RoleId,DataRecord) of
        {error,Reason} ->
            do_client_change_leader_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,RoleBase,MapTeamInfo} ->
            do_client_change_leader3({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase,MapTeamInfo)
    end.
do_client_change_leader2(RoleId,DataRecord) ->
    case RoleId =:= DataRecord#m_team_change_leader_tos.role_id of
        true ->
            erlang:throw({error,?_LANG_TEAM_CHANGE_LEADER_FAIL_TO_SELF});
        _ ->
            next
    end,
    case common_misc:is_role_online(DataRecord#m_team_change_leader_tos.role_id) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_CHANGE_LEADER_FAIL_TO_OFFLINE})
    end,
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case RoleBase#p_role_base.team_id =/= 0 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_NOT_IN})
    end,
    MapTeamInfo = 
        case get_role_team_info(RoleId) of
            {ok,MapTeamInfoT} ->
                MapTeamInfoT;
            _ ->
                ?DEBUG("~ts,RoleBase_TeamId=~w",["玩家组队数据不同步",RoleBase#p_role_base.team_id]),
                erlang:throw({error,?_LANG_TEAM_NOT_IN})
        end,
    case lists:keyfind(DataRecord#m_team_change_leader_tos.role_id,#p_team_role.role_id,MapTeamInfo#r_role_team.role_list) of
        false ->
            erlang:throw({error,?_LANG_TEAM_CHANGE_LEADER_FAIL_NOT_IN2});
        _ ->
            next
    end,
    case RoleId =:= get_team_leader_role_id(MapTeamInfo#r_role_team.role_list) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_LEADER_AUTHORITY})
    end,
    {ok,RoleBase,MapTeamInfo}.
do_client_change_leader3({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase,MapTeamInfo) ->
    case global:whereis_name(MapTeamInfo#r_role_team.proccess_name) of
        undefined -> %% 队伍进程已经不存在处理
            case common_transaction:transaction(
                   fun() ->
                           case RoleBase#p_role_base.team_id =/= 0 of
                               true ->
                                   mod_map_role:set_role_base(RoleId,RoleBase#p_role_base{team_id = 0});
                               _ ->
                                   ignore
                           end,
                           t_set_role_team_info(RoleId,#r_role_team{role_id = RoleId})
                   end)
            of
                {atomic, _} ->
                    ok;
                {aborted, Error} ->
                    ?ERROR_MSG("set_role_team_info, error: ~w", [Error])
            end,
            SendAutoDisband = #m_team_auto_disband_toc{reason = ?_LANG_TEAM_AUTO_DISBAND},
            common_misc:unicast2(PId, ?DEFAULT_UNIQUE, ?TEAM, ?TEAM_AUTO_DISBAND, SendAutoDisband);
        _ ->
            set_role_team_info(RoleId,MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_CHANGE_LEADER}),
            global:send(MapTeamInfo#r_role_team.proccess_name,
                        {change_leader,{Unique, Module, Method, DataRecord, RoleId, PId}})
    end.

do_client_change_leader_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf = #m_team_change_leader_toc{succ = false, reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Change Leader",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

%% 队长解散队伍请求处理
do_client_disband({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_disband2(RoleId,DataRecord) of
        {error,Reason} ->
            do_client_disband_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,RoleBase,MapTeamInfo} ->
            do_client_disband3({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase,MapTeamInfo)
    end.
do_client_disband2(RoleId,DataRecord) ->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case RoleBase#p_role_base.team_id =/= 0 
        andalso RoleBase#p_role_base.team_id =:= DataRecord#m_team_disband_tos.team_id of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_NOT_IN})
    end,
    MapTeamInfo = 
        case get_role_team_info(RoleId) of
            {ok,MapTeamInfoT} ->
                MapTeamInfoT;
            _ ->
                ?DEBUG("~ts,RoleBase_TeamId=~w",["玩家组队数据不同步",RoleBase#p_role_base.team_id]),
                erlang:throw({error,?_LANG_TEAM_NOT_IN})
        end,
    case RoleId =:= get_team_leader_role_id(MapTeamInfo#r_role_team.role_list) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_LEADER_AUTHORITY})
    end,
    {ok,RoleBase,MapTeamInfo}.
do_client_disband3({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase,MapTeamInfo) ->
    case global:whereis_name(MapTeamInfo#r_role_team.proccess_name) of
        undefined -> %% 队伍进程已经不存在处理
            case common_transaction:transaction(
                   fun() ->
                           case RoleBase#p_role_base.team_id =/= 0 of
                               true ->
                                   mod_map_role:set_role_base(RoleId,RoleBase#p_role_base{team_id = 0});
                               _ ->
                                   ignore
                           end,
                           t_set_role_team_info(RoleId,#r_role_team{role_id = RoleId})
                   end)
            of
                {atomic, _} ->
                    ok;
                {aborted, Error} ->
                    ?ERROR_MSG("set_role_team_info, error: ~w", [Error])
            end,
            SendAutoDisband = #m_team_auto_disband_toc{reason = ?_LANG_TEAM_AUTO_DISBAND},
            common_misc:unicast2(PId, ?DEFAULT_UNIQUE, ?TEAM, ?TEAM_AUTO_DISBAND, SendAutoDisband);
        _ ->
            set_role_team_info(RoleId,MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_DISBAND}),
            global:send(MapTeamInfo#r_role_team.proccess_name,
                        {disband,{Unique, Module, Method, DataRecord, RoleId, PId}})
    end.

do_client_disband_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf = #m_team_disband_toc{succ = false, reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Disband",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

%% 申请入队消息处理
do_client_apply({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_apply2(RoleId,DataRecord) of
        {error,Reason} ->
            do_client_apply_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,RoleBase,MapTeamInfo} ->
            do_client_apply3({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase,MapTeamInfo)
    end.
%% OpType,1队员申请入队,2队长同意入队 3队长不同意入队 
do_client_apply2(RoleId,DataRecord) ->
    #m_team_apply_tos{role_id = ApplyRoleId,op_type = OpType} = DataRecord,
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    if OpType =:= 1 ->
            case ApplyRoleId =:= RoleId of
                true ->
                    erlang:throw({error,?_LANG_TEAM_APPLY_SELF});
                _ ->
                    next
            end,
            case RoleBase#p_role_base.team_id =/= 0 of
                true ->
                    erlang:throw({error,?_LANG_TEAM_APPLY_ROLE_IN_TEAM});
                _ ->
                    next
            end,
            MapTeamInfo = 
                case get_role_team_info(RoleId) of
                    {ok,MapTeamInfoT} ->
                        MapTeamInfoT;
                    _ ->
                        #r_role_team{role_id = RoleId}
                end,
            case common_misc:is_role_online(ApplyRoleId) of
                true ->
                    next;
                _ ->
                    erlang:throw({error,?_LANG_TEAM_APPLY_ROLE_OFF_LINE})
            end,
            next;
       OpType =:= 2 ->
            case RoleBase#p_role_base.team_id =/= 0 of
                true ->
                    next;
                _ ->
                   erlang:throw({error,?_LANG_TEAM_APPLY_TEAMLEADER_ON_TEAM}) 
            end,
            MapTeamInfo = 
                case get_role_team_info(RoleId) of
                    {ok,MapTeamInfoT} ->
                        MapTeamInfoT;
                    _ ->
                        erlang:throw({error,?_LANG_TEAM_APPLY_TEAMLEADER_ON_TEAM}) 
                end,
            case RoleId =:= get_team_leader_role_id(MapTeamInfo#r_role_team.role_list) of
                true ->
                    next;
                _ ->
                    erlang:throw({error,?_LANG_TEAM_APPLY_TEAMLEADER_NO_LEADER}) 
            end,
            [MaxMemberCount] = common_config_dyn:find(team,max_member_count),
            case erlang:length(MapTeamInfo#r_role_team.role_list) >= MaxMemberCount of
                true ->
                    erlang:throw({error,?_LANG_TEAM_APPLY_ROLE_MAX_MEMBER});
                _ ->
                    next
            end,
            case common_misc:is_role_online(DataRecord#m_team_apply_tos.apply_id) of
                true ->
                    next;
                _ ->
                    erlang:throw({error,?_LANG_TEAM_APPLY_TEAMLEADER_ROLE_OFF_LINE})
            end,
            next;
       OpType =:= 3 ->
            MapTeamInfo = undefined,
            next;
       true ->
            MapTeamInfo = undefined,
            erlang:throw({error,?_LANG_TEAM_APPLY_ERROR})
    end,
    {ok,RoleBase,MapTeamInfo}.

do_client_apply3({Unique, Module, Method, DataRecord, RoleId, PId},RoleBase,MapTeamInfo) ->
    if DataRecord#m_team_apply_tos.op_type =:= 3  -> %% 队长拒绝玩家申请入队
            SendSelf = #m_team_apply_toc{
              succ = true,
              return_self = true,
              role_id = DataRecord#m_team_apply_tos.role_id,
              op_type = DataRecord#m_team_apply_tos.op_type,
              apply_id = DataRecord#m_team_apply_tos.apply_id,
              apply_name = RoleBase#p_role_base.role_name},
            ?DEBUG("~ts,SendSelf=~w",["组队模块Apply",SendSelf]),
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
            SendApply = #m_team_apply_toc{
              succ = false,
              return_self = true,
              role_id = DataRecord#m_team_apply_tos.role_id,
              op_type = DataRecord#m_team_apply_tos.op_type,
              apply_id = DataRecord#m_team_apply_tos.apply_id,
              apply_name =RoleBase#p_role_base.role_name,
              reason = ?_LANG_TEAM_APPLY_TEAMLEADER_REFUSE},
            catch common_misc:unicast({role,DataRecord#m_team_apply_tos.apply_id},?DEFAULT_UNIQUE, Module, Method, SendApply),
            ok;
        DataRecord#m_team_apply_tos.op_type =:= 2 -> %% 同意入队，先转申请人进程，再到队伍进程处理
            set_role_team_info(RoleId,MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_APPLY}),
            common_misc:send_to_rolemap(DataRecord#m_team_apply_tos.apply_id, 
                                        {mod_map_team,
                                         {admin_apply_accept,
                                          {Unique,Module,Method,DataRecord,RoleId,PId,
                                           MapTeamInfo#r_role_team.proccess_name}}}),
            ok;
        DataRecord#m_team_apply_tos.op_type =:= 1 -> %% 转到被申请人的地图进程处理
            set_role_team_info(RoleId,MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_APPLY}),
            common_misc:send_to_rolemap(DataRecord#m_team_apply_tos.role_id, 
                                        {mod_map_team,
                                         {admin_apply,
                                          {Unique,Module,Method,DataRecord,RoleId,PId,
                                           RoleBase#p_role_base.role_name,RoleBase#p_role_base.faction_id}}});
       true ->
            do_client_apply_error({Unique, Module, Method, DataRecord, RoleId, PId},?_LANG_TEAM_APPLY_ERROR)
    end.
do_admin_apply({Unique,Module,Method,DataRecord,RoleId,PId,RoleName,FactionId}) ->
    case catch do_admin_apply2(RoleId,DataRecord,FactionId) of
        {error,Reason} ->
            common_misc:send_to_rolemap(RoleId, {mod_map_team,{admin_update_do_status,{RoleId,?TEAM_DO_STATUS_NORMAL}}}),
            do_client_apply_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,ApplyMapTeamInfo} ->
            do_admin_apply3({Unique,Module,Method,DataRecord,RoleId,PId,RoleName,FactionId,ApplyMapTeamInfo})
    end.
do_admin_apply2(_RoleId,DataRecord,FactionId) ->
    #m_team_apply_tos{role_id = ApplyRoleId,op_type = OpType} = DataRecord,
    case OpType =:= 1 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_APPLY_ERROR})
    end,
    {ok,ApplyRoleBase} = mod_map_role:get_role_base(ApplyRoleId),
    case ApplyRoleBase#p_role_base.faction_id =:= FactionId of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_APPLY_FAIL_COUNTRY})
    end,
    case ApplyRoleBase#p_role_base.team_id =/= 0 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_APPLY_ROLE_ON_TEAM})
    end,
    ApplyMapTeamInfo = 
        case get_role_team_info(ApplyRoleId) of
            {ok,ApplyMapTeamInfoT} ->
                ApplyMapTeamInfoT;
            _ ->
                erlang:throw({error,?_LANG_TEAM_APPLY_ROLE_ON_TEAM})
        end,
    [MaxMemberCount] = common_config_dyn:find(team,max_member_count),
    case erlang:length(ApplyMapTeamInfo#r_role_team.role_list) >= MaxMemberCount of
        true ->
            erlang:throw({error,?_LANG_TEAM_APPLY_ROLE_MAX_MEMBER});
        _ ->
            next
    end,
    case global:whereis_name(ApplyMapTeamInfo#r_role_team.proccess_name) of
        undefined ->
            erlang:throw({error,?_LANG_TEAM_APPLY_ROLE_ON_TEAM_ERROR});
        _ ->
            next
    end,
    {ok,ApplyMapTeamInfo}.
do_admin_apply3({Unique,Module,Method,DataRecord,RoleId,PId,RoleName,_FactionId,ApplyMapTeamInfo}) ->
    common_misc:send_to_rolemap(RoleId, {mod_map_team,{admin_update_do_status,{RoleId,?TEAM_DO_STATUS_NORMAL}}}),
    SendSelf = #m_team_apply_toc{
      succ = true,
      return_self = true,
      role_id = DataRecord#m_team_apply_tos.role_id,
      op_type = DataRecord#m_team_apply_tos.op_type,
      apply_id = DataRecord#m_team_apply_tos.apply_id},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Apply",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    LeaderRoleId = get_team_leader_role_id(ApplyMapTeamInfo#r_role_team.role_list),
    LeaderSelf = #m_team_apply_toc{
      succ = true,
      return_self = false,
      role_id = DataRecord#m_team_apply_tos.role_id,
      op_type = DataRecord#m_team_apply_tos.op_type,
      apply_id = DataRecord#m_team_apply_tos.apply_id,
      apply_name = RoleName},
    catch common_misc:unicast({role,LeaderRoleId}, ?DEFAULT_UNIQUE, Module, Method, LeaderSelf),
    ok.
%% 队长同意申请入队
do_admin_apply_accept({Unique,Module,Method,DataRecord,RoleId,PId,ProccessName}) ->
    case catch do_admin_apply_accept2(RoleId,DataRecord,ProccessName) of
        {error,Reason} ->
            common_misc:send_to_rolemap(RoleId, {mod_map_team,{admin_update_do_status,{RoleId,?TEAM_DO_STATUS_NORMAL}}}),
            do_client_apply_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,RoleTeamInfo} ->
            do_admin_apply_accept3({Unique,Module,Method,DataRecord,RoleId,PId,ProccessName},RoleTeamInfo)
    end.
do_admin_apply_accept2(_RoleId,DataRecord,ProccessName) ->
    MapRoleInfo =
        case mod_map_actor:get_actor_mapinfo(DataRecord#m_team_apply_tos.apply_id,role) of
            undefined ->
                erlang:throw({error,?_LANG_TEAM_APPLY_TEAMLEADER_ROLE_OFF_LINE});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    {ok,RoleBase} = mod_map_role:get_role_base(DataRecord#m_team_apply_tos.apply_id),
    case RoleBase#p_role_base.team_id =:= 0 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_APPLY_TEAMLEADER_ROLE_IN_TEAM})
    end,
    [MapName] = common_config_dyn:find(map_info,mgeem_map:get_mapid()),
    {ok,RoleAttr} = mod_map_role:get_role_attr(DataRecord#m_team_apply_tos.apply_id),
    RoleTeamInfo = #p_team_role{
      role_id =  DataRecord#m_team_apply_tos.apply_id,
      role_name = RoleBase#p_role_base.role_name,
      faction_id = MapRoleInfo#p_map_role.faction_id,
      sex = RoleBase#p_role_base.sex,
      skin = RoleAttr#p_role_attr.skin,
      map_id = mgeem_map:get_mapid(),
      map_name = MapName,
      tx = (MapRoleInfo#p_map_role.pos)#p_pos.tx,
      ty = (MapRoleInfo#p_map_role.pos)#p_pos.ty,
      hp = MapRoleInfo#p_map_role.hp,
      mp = MapRoleInfo#p_map_role.mp,
      max_hp = MapRoleInfo#p_map_role.max_hp,
      max_mp = MapRoleInfo#p_map_role.max_mp,
      level = RoleAttr#p_role_attr.level,
      is_leader = false,
      is_follow = false,
      is_offline = false,
      offline_time = 0,
      five_ele_attr = RoleAttr#p_role_attr.five_ele_attr,
      five_ele_attr_level = 0,
      add_hp = 0,
      add_mp = 0,
      add_phy_attack = 0,
      add_magic_attack = 0,
      category = RoleAttr#p_role_attr.category
     },
    case global:whereis_name(ProccessName) of
        undefined ->
            erlang:throw({error,?_LANG_TEAM_APPLY_TEAMLEADER_TEAM_ERROR});
        _ ->
            next
    end,
    {ok,RoleTeamInfo}.
do_admin_apply_accept3({Unique,Module,Method,DataRecord,RoleId,PId,ProccessName},RoleTeamInfo) ->
    %% 转移到队伍进程处理
    global:send(ProccessName,{apply,{Unique, Module, Method, DataRecord, RoleId, PId, RoleTeamInfo}}),
    ok.

do_client_apply_error({Unique, Module, Method, DataRecord, _RoleId, PId},Reason) ->
    SendSelf = #m_team_apply_toc{
      succ = false,
      return_self = true,
      role_id = DataRecord#m_team_apply_tos.role_id,
      op_type = DataRecord#m_team_apply_tos.op_type,
      apply_id = DataRecord#m_team_apply_tos.apply_id,
      reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Apply",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

%% 创建队伍消息处理
do_client_create({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_create2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_client_create_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason,ReasonCode);
        {ok,MapTeamInfo,RoleTeamInfo} ->
            do_client_create3({Unique, Module, Method, DataRecord, RoleId, PId},
                              MapTeamInfo,RoleTeamInfo)
    end.

do_client_create2(RoleId,DataRecord) ->
    case RoleId =:= DataRecord#m_team_create_tos.role_id of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_CREATE_ERROR,0})
    end,
    MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_TEAM_CREATE_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case RoleBase#p_role_base.team_id =:= 0 of 
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_CREATE_HAS_TEAM,0})
    end,
    case get_role_team_info(RoleId) of
        {ok,MapTeamInfo} ->
            case lists:keyfind(RoleId,#p_team_role.role_id,MapTeamInfo#r_role_team.role_list) of
                false ->
                    next;
                _ ->
                    erlang:throw({error,?_LANG_TEAM_CREATE_HAS_TEAM,0})
            end,
            if MapTeamInfo#r_role_team.do_status =:= ?TEAM_DO_STATUS_ACCEPT ->
                    %% 上一条同意的消息未处理完成，玩家操作过快
                    erlang:throw({error,?_LANG_TEAM_CREATE_DO_DO_DO,0});
               MapTeamInfo#r_role_team.do_status =:= ?TEAM_DO_STATUS_CREATE ->
                    erlang:throw({error,?_LANG_TEAM_CREATE_DO_DO_DO,0});
               true ->
                    next
            end,
            next;
        _ ->
            MapTeamInfo = #r_role_team{
              role_id = RoleId,team_id = 0,proccess_name = undefined,role_list = [],next_bc_time = 0,
              pick_type = 1,invite_list = [],do_status = 0}
    end,
    [MapName] = common_config_dyn:find(map_info,mgeem_map:get_mapid()),
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
    RoleTeamInfo = #p_team_role{
      role_id =  RoleId,
      role_name = RoleBase#p_role_base.role_name,
      faction_id = RoleBase#p_role_base.faction_id,
      sex = RoleBase#p_role_base.sex,
      skin = RoleAttr#p_role_attr.skin,
      map_id = mgeem_map:get_mapid(),
      map_name = MapName,
      tx = (MapRoleInfo#p_map_role.pos)#p_pos.tx,
      ty = (MapRoleInfo#p_map_role.pos)#p_pos.ty,
      hp = MapRoleInfo#p_map_role.hp,
      mp = MapRoleInfo#p_map_role.mp,
      max_hp = MapRoleInfo#p_map_role.max_hp,
      max_mp = MapRoleInfo#p_map_role.max_mp,
      level = RoleAttr#p_role_attr.level,
      is_leader = false,
      is_follow = false,
      is_offline = false,
      offline_time = 0,
      five_ele_attr = RoleAttr#p_role_attr.five_ele_attr,
      five_ele_attr_level = 0,
      add_hp = 0,
      add_mp = 0,
      add_phy_attack = 0,
      add_magic_attack = 0,
      category = RoleAttr#p_role_attr.category
     },
    {ok,MapTeamInfo,RoleTeamInfo}.

do_client_create3({Unique, Module, Method, DataRecord, RoleId, _PId},
                  MapTeamInfo,RoleTeamInfo) ->
    set_role_team_info(RoleId, MapTeamInfo#r_role_team{do_status = ?TEAM_DO_STATUS_CREATE}),
    global:send(mod_team_server,{create_team_procces_by_create,{RoleId,Unique,Module,Method,DataRecord,RoleTeamInfo}}),
    ok.

do_client_create_error({Unique, Module, Method, DataRecord, _RoleId, PId},Reason,ReasonCode) ->
    SendSelf = #m_team_create_toc{
      role_id = DataRecord#m_team_create_tos.role_id,
       succ = false,
       reason = Reason,
       reason_code = ReasonCode,
       role_list = [],
       team_id = 0,
       pick_type = 1},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Create",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).


%% 队伍查询接口
do_client_query({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_client_query2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_client_query_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason,ReasonCode);
        {ok,RoleTeamId,NearbyRoleIdList} ->
            do_client_query3({Unique, Module, Method, DataRecord, RoleId, PId},RoleTeamId,NearbyRoleIdList)
    end.
do_client_query2(RoleId,DataRecord) ->
    case DataRecord#m_team_query_tos.op_type =:= 1 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_QUERY_OP_TYPE_ERROR,0})
    end,
    _MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_TEAM_QUERY_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    RoleTeamId = 
        case mod_map_role:get_role_base(RoleId) of
            {ok,#p_role_base{team_id = RoleTeamIdT}} ->
                RoleTeamIdT;
            _ ->
                0
        end,
    #map_state{offsetx = OffsetX,offsety = OffsetY} = mgeem_map:get_state(),
    NearbyRoleIdList = 
        case mod_map_actor:get_actor_txty_by_id(RoleId, role) of
            {TX, TY} -> 
                case mgeem_map:get_9_slice_by_txty(TX, TY, OffsetX, OffsetY) of
                    undefined ->
                        [];
                    SliceNameList ->
                        mgeem_map:get_all_in_sence_user_by_slice_list(SliceNameList)
                end;
            undefined ->
                []
        end,
    ?DEBUG("NearbyRoleIdList=~w",[NearbyRoleIdList]),
    {ok,RoleTeamId,NearbyRoleIdList}.
do_client_query3({Unique, Module, Method, DataRecord, RoleId, PId},RoleTeamId,NearbyRoleIdList) ->
    case DataRecord#m_team_query_tos.op_type =:= 1 of
        true ->
            NearbyList = get_nearby_team_list(RoleTeamId,NearbyRoleIdList),
            SendSelf = #m_team_query_toc{
              succ = true,
              op_type = DataRecord#m_team_query_tos.op_type,
              nearby_list = NearbyList},
            ?DEBUG("~ts,SendSelf=~w",["组队模块Query",SendSelf]),
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf);
        _ ->
            do_client_query_error({Unique, Module, Method, DataRecord, RoleId, PId},?_LANG_TEAM_QUERY_OP_TYPE_ERROR,0)
    end.
do_client_query_error({Unique, Module, Method, DataRecord, _RoleId, PId},Reason,ReasonCode) ->
    SendSelf = #m_team_query_toc{
      succ = false,
      op_type = DataRecord#m_team_query_tos.op_type,
      reason = Reason,
      reason_code = ReasonCode,
      nearby_list = []},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Query",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).
get_nearby_team_list(_RoleTeamId,[]) ->
    [];
get_nearby_team_list(RoleTeamId,NearbyRoleIdList) ->
    [MaxMemberCount] = common_config_dyn:find(team,max_member_count),
    [MinMemberCount] = common_config_dyn:find(team,min_member_count),
    lists:foldl(
      fun(NearbyRoleId,AccNearbyList) ->
              case get_role_team_info(NearbyRoleId) of
                  {ok,RoleTeamInfo} ->
                      IsExist = 
                          case lists:keyfind(RoleTeamInfo#r_role_team.team_id,#p_team_nearby.team_id,AccNearbyList) of
                              false ->
                                  false;
                              _ ->
                                  true
                          end,
                      case IsExist =:= false andalso RoleTeamInfo#r_role_team.team_id =/= 0 
                          andalso (RoleTeamId =:= 0 orelse (RoleTeamId =/= 0 andalso RoleTeamInfo#r_role_team.team_id =/= RoleTeamId))
                          andalso RoleTeamInfo#r_role_team.role_list =/= []
                          andalso erlang:length(RoleTeamInfo#r_role_team.role_list) >= MinMemberCount
                          andalso erlang:length(RoleTeamInfo#r_role_team.role_list) < MaxMemberCount of
                          true ->
                              TeamRoleInfo = lists:nth(1,RoleTeamInfo#r_role_team.role_list),
                              case TeamRoleInfo#p_team_role.is_offline =:= false of
                                  true ->
                                      [get_p_team_nearby(RoleTeamInfo,TeamRoleInfo,MaxMemberCount)|AccNearbyList];
                                  _ ->
                                      AccNearbyList
                              end;
                          _ ->
                              AccNearbyList
                      end;
                  _ ->
                      AccNearbyList
              end
      end,[],NearbyRoleIdList).
get_p_team_nearby(RoleTeamInfo,TeamRoleInfo,MaxMemberCount) ->
    AutoAcceptTeam = 
        case db:dirty_read(?DB_SYSTEM_CONFIG,TeamRoleInfo#p_team_role.role_id) of
            [#r_sys_config{sys_config=#p_sys_config{auto_team = AutoAcceptTeamT}}] ->
                AutoAcceptTeamT;
            _ ->
                false
        end,
    #p_team_nearby{
          team_id = RoleTeamInfo#r_role_team.team_id,
          cur_team_number = erlang:length(RoleTeamInfo#r_role_team.role_list),
          sum_team_number = MaxMemberCount,
          role_id = TeamRoleInfo#p_team_role.role_id,
          sex = TeamRoleInfo#p_team_role.sex,
          faction_id = TeamRoleInfo#p_team_role.faction_id,
          level = TeamRoleInfo#p_team_role.level,
          category = TeamRoleInfo#p_team_role.category,
          skinid = (TeamRoleInfo#p_team_role.skin)#p_skin.skinid,
          role_name = TeamRoleInfo#p_team_role.role_name,
          auto_accept_team = AutoAcceptTeam}.

%% 获得队长role_id 查找不到返回 0
get_team_leader_role_id(TeamRoleList) ->
    lists:foldl(
      fun(TeamRoleInfo,AccLeaderRoleId) ->
              case AccLeaderRoleId =:= 0 andalso TeamRoleInfo#p_team_role.is_leader =:= true of
                  true ->
                      TeamRoleInfo#p_team_role.role_id;
                  _ ->
                      AccLeaderRoleId
              end
      end,0,TeamRoleList).

