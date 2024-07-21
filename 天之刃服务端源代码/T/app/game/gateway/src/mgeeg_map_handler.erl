%% Author: 
%% Created: 2011-9-5
%% Description: TODO: Add description to mgeeg_map_handler
-module(mgeeg_map_handler).

-include("mgeeg.hrl"). 

-export([update_map_info/4]).
%% ====================================================================
%% API functions
%% ====================================================================

update_map_info(RoleId,RoleBase1,RoleAttr1,RolePos1)->
    RolePos2 = do_update_map_info_of_fb(RoleId,RoleBase1,RolePos1),
    do_check_map_info(RoleId, RoleBase1, RoleAttr1, RolePos2).


%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------



%% add by caochuncheng
%% 在副本中下线的处理，只处理在讨伐敌营副本中下线的
%% 返回新的RolePos
do_update_map_info_of_fb(RoleId,RoleBase,RolePos) ->
    #p_role_pos{map_id = MapId} = RolePos,
    [SwFbMapIdList] = common_config_dyn:find(scene_war_fb,sw_fb_mcm),
    IsSceneFbMapId = 
        case lists:keyfind(MapId,#r_sw_fb_mcm.fb_map_id,SwFbMapIdList) of
            false ->
                false;
            #r_sw_fb_mcm{fb_map_id = MapId} ->
                true;
            _ ->
                false
        end,
    [HeroFBMapIdList] = common_config_dyn:find(hero_fb, fb_map_id_list),
    IsHeroFBMapId = lists:member(MapId, HeroFBMapIdList),
    [SqFBMapIdList] = common_config_dyn:find(shuaqi_fb,sq_fb_map_list),
    IsSqFBMapId = lists:member(MapId,SqFBMapIdList),
    [ExeFBMapIDList] = common_config_dyn:find(exercise_fb,exe_fb_map_list),
    IsExeFbMapId = lists:member(MapId, ExeFBMapIDList),
    [MissionFbMapIdList] = common_config_dyn:find(mission_fb,fb_map_id_list),
    IsMissionFbMapId = lists:member(MapId,MissionFbMapIdList),
    if MapId =:= 10400 ->
           do_update_map_info_of_vwf2(RoleId,RoleBase,RolePos);
       MapId =:= 10500 ->
           do_update_map_info_of_10500(RoleId,RoleBase,RolePos);
       MapId =:= 10600 ->
           do_update_map_info_of_10600(RoleId,RoleBase,RolePos);
       MapId =:= 10300 ->
           RolePos;
       IsSceneFbMapId =:= true ->
           do_update_map_info_of_sw_fb(RoleId, RoleBase, RolePos);
       IsHeroFBMapId =:=true->
           do_update_map_info_of_hero_fb(RoleId,RoleBase,RolePos);
       IsSqFBMapId =:= true->
           do_update_map_info_of_sq_fb(RoleId,RoleBase,RolePos);
       IsExeFbMapId =:= true->
           do_update_map_info_of_exe_fb(RoleId,RoleBase,RolePos);
       IsMissionFbMapId =:= true ->
           do_update_map_info_of_mission_fb(RoleId,RoleBase,RolePos,MapId);
       true ->
           do_update_map_info_other(RoleId, RoleBase, RolePos, MapId)
    end.
do_update_map_info_of_vwf2(RoleId,RoleBase,RolePos) ->
    %% 从副本记录中获取玩家上次进入副本的记录
    case common_misc:get_role_map_process_name(RoleId) of
        {error,Error} ->
            ?ERROR_MSG("~ts,Error=~w",["获取玩家上次退出游戏时的地图进程名称出错",Error]),
            RolePos;
        {ok,MapProcessName} ->
            if RoleBase#p_role_base.team_id =:= 0 ->
                    do_update_map_info_of_vwf3(RoleId,RoleBase,RolePos);
               true ->
                    case global:whereis_name(MapProcessName) of
                        undefined ->
                            do_update_map_info_of_vwf3(RoleId,RoleBase,RolePos);
                        _ ->
                            RolePos
                    end
            end
    end.
do_update_map_info_of_vwf3(RoleId,RoleBase,RolePos) ->
    case db:dirty_read(?DB_VIE_WORLD_FB_LOG, RoleId) of
        {'EXIT', Error} ->
            ?ERROR_MSG("~ts,Error=~w",["获取玩家上次进入副本地图的记录出错",Error]),
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos);
        [] ->
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos);
        [VWFLog] when erlang:is_record(VWFLog,r_vie_world_fb_log) ->
            db:dirty_delete(?DB_VIE_WORLD_FB_LOG, RoleId),
            #r_vie_world_fb_log{map_id = MapId,pos = Pos} = VWFLog,
            MapProcessName = common_misc:get_common_map_name(MapId),
            NewRolePos = RolePos#p_role_pos{map_id = MapId,pos = Pos},
            do_t_update_map_info_of_vwf(RoleId,NewRolePos,MapProcessName,RolePos);
        _Other ->
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos)
    end.
do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos) ->
    #p_role_base{faction_id = FactionId} = RoleBase,
    MapId = common_misc:get_home_map_id(FactionId),
    {_MapId,Tx,Ty} = common_misc:get_born_info_by_map(MapId),
    Pos = #p_pos{tx = Tx, ty = Ty},
    MapProcessName = common_misc:get_common_map_name(MapId),
    NewRolePos = RolePos#p_role_pos{map_id = MapId,pos = Pos},
    do_t_update_map_info_of_vwf(RoleId,NewRolePos,MapProcessName,RolePos).

do_t_update_map_info_of_vwf(RoleId,RolePos,MapProcessName,OldRolePos) ->
    case db:transaction(
           fun() -> 
                   [#p_role_pos{map_process_name=OldName}] = db:read(?DB_ROLE_POS, RoleId, write),
                   R = RolePos#p_role_pos{role_id=RoleId, map_process_name=MapProcessName, old_map_process_name=OldName},
                   db:write(?DB_ROLE_POS, R, write)
           end) of
        {atomic, ok} ->
            RolePos;
        {aborted, Error} ->
            ?ERROR_MSG("update_role_map_process_name, error: ~w", [Error]),
            OldRolePos
    end.
do_update_map_info_of_10500(RoleID, FactionID, Level, RolePos) ->
    case Level < 10 of
        true ->
            MapID = 10000 + FactionID * 1000;
        _ ->
            MapID = common_misc:get_home_map_id(FactionID)
    end,
    {_,Tx,Ty} = common_misc:get_born_info_by_map(MapID),
    Pos = #p_pos{tx = Tx, ty = Ty},
    MapProcessName = common_misc:get_common_map_name(MapID),
    NewRolePos = RolePos#p_role_pos{map_id = MapID,pos = Pos},
    do_t_update_map_info_of_vwf(RoleID,NewRolePos,MapProcessName,RolePos).
%% 大明宝藏地图副本处理
do_update_map_info_of_10500(RoleId,RoleBase,RolePos) ->
    #p_role_base{faction_id = FactionId} = RoleBase,
    MapId = common_misc:get_home_map_id(FactionId),
    {_MapId,Tx,Ty} = common_misc:get_born_info_by_map(MapId),
    Pos = #p_pos{tx = Tx, ty = Ty},
    MapProcessName = common_misc:get_common_map_name(MapId),
    NewRolePos = RolePos#p_role_pos{map_id = MapId,pos = Pos},
    do_t_update_map_info_of_vwf(RoleId,NewRolePos,MapProcessName,RolePos).
%% 师门同心副本
do_update_map_info_of_10600(RoleId,RoleBase,RolePos) ->
    case common_misc:get_role_map_process_name(RoleId) of
        {error,Error} ->
            ?ERROR_MSG("~ts,Error=~w",["获取玩家上次退出游戏时的地图进程名称出错",Error]),
            RolePos;
        {ok,MapProcessName} ->
            ?ERROR_MSG("~ts,MapProcessName=~w,TeamId=~w",["玩家上次在10600地图下线",MapProcessName,RoleBase#p_role_base.team_id]),
            if RoleBase#p_role_base.team_id =:= 0 ->
                    do_update_map_info_of_10600_2(RoleId,RoleBase,RolePos);
               true ->
                    case global:whereis_name(MapProcessName) of
                        undefined ->
                            do_update_map_info_of_10600_2(RoleId,RoleBase,RolePos);
                        _ ->
                            RolePos
                    end
            end
    end.
do_update_map_info_of_10600_2(RoleId,RoleBase,RolePos) ->
    case db:dirty_read(?DB_EDUCATE_FB,RoleId) of
        [] ->
            ?ERROR_MSG("~ts",["查询不到玩家上次在师门副本地图信息离开"]),
            do_update_map_info_of_10500(RoleId,RoleBase,RolePos);
        [EducateFbRole] ->
            #r_educate_fb{map_id = MapId,pos = Pos} = EducateFbRole,
            MapProcessName = common_misc:get_common_map_name(MapId),
            NewRolePos = RolePos#p_role_pos{map_id = MapId,pos = Pos},
            do_t_update_map_info_of_vwf(RoleId,NewRolePos,MapProcessName,RolePos);
        _ ->
            do_update_map_info_of_10500(RoleId,RoleBase,RolePos)
    end.
%% 场景大战副本
do_update_map_info_of_sw_fb(RoleId, RoleBase, RolePos) ->
    case db:dirty_read(?DB_SCENE_WAR_FB, RoleId) of
        {'EXIT', Error} ->
            ?ERROR_MSG("~ts,Error=~w",["场景大战副本地图的记录出错",Error]),
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos);
        [] ->
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos);
        [SceneWarFbRecord] when erlang:is_record(SceneWarFbRecord,r_scene_war_fb) ->
            #r_scene_war_fb{map_id = MapId,pos = Pos,fb_map_name = FbMapProcessName} = SceneWarFbRecord,
            [#p_role_ext{last_offline_time = LastOfflineTime}] = db:dirty_read(?DB_ROLE_EXT,RoleId),
            IsFbMapProcess = 
                case global:whereis_name(FbMapProcessName) of
                    undefined ->
                        false;
                    _ ->
                        true
                end,
            [KeepOfflineSeconds] = common_config_dyn:find(scene_war_fb,sw_fb_keep_offline_seconds),
            NowSeconds = common_tool:now(),
            if RoleBase#p_role_base.team_id =/= 0 andalso IsFbMapProcess =:= true->
                    RolePos;
               (KeepOfflineSeconds + LastOfflineTime) >= NowSeconds andalso IsFbMapProcess =:= true->
                    RolePos;
               true ->
                    MapProcessName = common_misc:get_common_map_name(MapId),
                    NewRolePos = RolePos#p_role_pos{map_id = MapId,pos = Pos},
                    do_t_update_map_info_of_vwf(RoleId,NewRolePos,MapProcessName,RolePos)
            end;
        _Other ->
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos)
    end.                   

%% 个人英雄副本
do_update_map_info_of_hero_fb(RoleID,RoleBase,RolePos)->
    case db:dirty_read(?DB_ROLE_HERO_FB_P,RoleID) of
        [RoleHeroFbInfo] when erlang:is_record(RoleHeroFbInfo,p_role_hero_fb_info) ->
            #p_role_hero_fb_info{enter_pos=EnterPos,enter_mapid=EnterMapID} = RoleHeroFbInfo,
            FbMapProcessName = lists:concat(["mgee_personal_fb_map_", RolePos#p_role_pos.map_id, "_", RoleID]),
            case global:whereis_name(FbMapProcessName) of
                undefined ->
                    NewRolePos = RolePos#p_role_pos{map_id = EnterMapID,pos = EnterPos},
                    MapProcessName = common_misc:get_common_map_name(EnterMapID),
                    do_t_update_map_info_of_vwf(RoleID,NewRolePos,MapProcessName,RolePos);
                _ ->
                    RolePos
            end;
        _->
            do_update_map_info_of_vwf4(RoleID,RoleBase,RolePos)
    end.

%% 刷棋副本
do_update_map_info_of_sq_fb(RoleId,RoleBase,RolePos)->
    case db:dirty_read(?DB_ROLE_SQ_FB_INFO, RoleId) of
        {'EXIT', Error} ->
            ?ERROR_MSG("~ts,Error=~w",["刷棋副本地图的记录出错",Error]),
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos);
        [] ->
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos);
        [SceneWarFbRecord] when erlang:is_record(SceneWarFbRecord,r_role_sq_fb_info) ->
            #r_role_sq_fb_info{enter_map_id = MapId,enter_pos = Pos,fb_map_name = FbMapProcessName} = SceneWarFbRecord,
            [#p_role_ext{last_offline_time = LastOfflineTime}] = db:dirty_read(?DB_ROLE_EXT,RoleId),
            IsFbMapProcess = 
                case global:whereis_name(FbMapProcessName) of
                    undefined ->
                        false;
                    _ ->
                        true
                end,
            [KeepOfflineSeconds] = common_config_dyn:find(shuaqi_fb,sq_fb_keep_offline_seconds),
            NowSeconds = common_tool:now(),
            if RoleBase#p_role_base.team_id =/= 0 
                 andalso IsFbMapProcess =:= true 
                 andalso (KeepOfflineSeconds + LastOfflineTime) >= NowSeconds ->
                    RolePos;
               true ->
                    MapProcessName = common_misc:get_common_map_name(MapId),
                    NewRolePos = RolePos#p_role_pos{map_id = MapId,pos = Pos},
                    do_t_update_map_info_of_vwf(RoleId,NewRolePos,MapProcessName,RolePos)
            end;
        _Other ->
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos)
    end.                   

%% 练功房副本
do_update_map_info_of_exe_fb(RoleId,RoleBase,RolePos)->
    case db:dirty_read(?DB_ROLE_EXE_FB_INFO, RoleId) of
        {'EXIT', Error} ->
            ?ERROR_MSG("~ts,Error=~w",["刷棋副本地图的记录出错",Error]),
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos);
        [] ->
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos);
        [ExerciseFbRecord] when erlang:is_record(ExerciseFbRecord,r_role_exe_fb_info) ->
            #r_role_exe_fb_info{enter_map_id = MapId,enter_pos = Pos,fb_map_name = FbMapProcessName} = ExerciseFbRecord,
            [#p_role_ext{last_offline_time = LastOfflineTime}] = db:dirty_read(?DB_ROLE_EXT,RoleId),
            IsFbMapProcess = 
                case global:whereis_name(FbMapProcessName) of
                    undefined ->
                        false;
                    _ ->
                        true
                end,
            [KeepOfflineSeconds] = common_config_dyn:find(exercise_fb,exe_fb_keep_offline_seconds),
            NowSeconds = common_tool:now(),
            if RoleBase#p_role_base.team_id =/= 0 
                 andalso IsFbMapProcess =:= true 
                 andalso (KeepOfflineSeconds + LastOfflineTime) >= NowSeconds ->
                    RolePos;
               true ->
                    MapProcessName = common_misc:get_common_map_name(MapId),
                    NewRolePos = RolePos#p_role_pos{map_id = MapId,pos = Pos},
                    do_t_update_map_info_of_vwf(RoleId,NewRolePos,MapProcessName,RolePos)
            end;
        _Other ->
            do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos)
    end.                   
do_update_map_info_of_mission_fb(RoleId,RoleBase,RolePos,MapId) ->
    MapProcessName = common_map:get_mission_fb_map_name(MapId,RoleId),
    case global:whereis_name(MapProcessName) of
        undefined ->
            case common_config_dyn:find(mission_fb,{npc_pos, MapId}) of
                [MissionFbNpcPosList] ->
                    case lists:keyfind(RoleBase#p_role_base.faction_id,1,MissionFbNpcPosList) of
                        false ->
                            RolePos2 = do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos);
                        {_FactionId,{DestMapId,DestTx,DestTy}} ->
                            DestMapProcessName = common_misc:get_common_map_name(DestMapId),
                            Pos = RolePos#p_role_pos.pos,
                            NewRolePos = RolePos#p_role_pos{map_id = DestMapId,pos = Pos#p_pos{tx = DestTx,ty = DestTy}},
                            RolePos2 = do_t_update_map_info_of_vwf(RoleId,NewRolePos,DestMapProcessName,RolePos)
                    end;
                _ ->
                    RolePos2 = do_update_map_info_of_vwf4(RoleId,RoleBase,RolePos)
            end,
            %% 需要帮助玩家自动完成任务副本中的任务
            case get_mission_complete_mission_id(RoleBase#p_role_base.faction_id,MapId) of
                0 ->
                    ignore;
                MissionId ->
                    ?ERROR_MSG("RoleId=~w,MissionId=~w",[RoleId,MissionId]),
                    case global:whereis_name(common_map:get_common_map_name(RolePos2#p_role_pos.map_id))  of
                        undefined ->
                            ?ERROR_MSG("~ts,MapId=~w,RoleId=~w,MissionId=~w",["玩家在任务副本中异常即出，无法自动处理完成任务需要手工处理",MapId,RoleId,MissionId]);
                        AutoMissionIdPid ->
                            AutoMissionIdPid ! {mod_mission_fb,{auto_complete_mission_id,RoleId,MissionId}}
                    end
            end,
            RolePos2;
        _ ->
            RolePos
    end.

%% 获取任务副本最好的主线任务id
get_mission_complete_mission_id(FactionId,DestMapId) ->
    case lists:foldl(
           fun({_Key,Value},Acc) -> 
                   case Acc =:= undefined
                            andalso erlang:is_record(Value, r_mission_fb_info) 
                            andalso Value#r_mission_fb_info.map_id =:= DestMapId
                            andalso Value#r_mission_fb_info.complete_type =:= 1 of
                       true ->
                           case lists:keyfind(FactionId,1,Value#r_mission_fb_info.complete_mission_id_list) of
                               false ->
                                   0;
                               {_,PMisstionId} ->
                                   PMisstionId
                           end;
                       _ ->
                           Acc
                   end
           
           end,undefined,common_config_dyn:list(mission_fb)) of
        undefined ->
            0;
        MisstionId ->
            MisstionId
    end.

%% @doc 判断地图是否存在
do_check_map_info(RoleId, RoleBase, RoleAttr, RolePos) ->
    case db:transaction(
           fun() ->
                   [#p_role_pos{map_process_name=MapName}] = db:read(?DB_ROLE_POS, RoleId, write),
                   MapName
           end)
    of
        {atomic, MapName} ->
            %% 地图不在了的话，踢出副本
            case global:whereis_name(MapName) of
                undefined ->
                    do_update_map_info_of_10500(RoleId, RoleBase#p_role_base.faction_id, RoleAttr#p_role_attr.level, RolePos);
                _ ->
                    RolePos
            end;
        {aborted, Error} ->
            ?ERROR_MSG("do_update_map_info_of_default, error: ~w", [Error]),
            RolePos
    end.

%% @doc 获取边城出生点
get_biancheng_born_point(FactionID) ->
    MapID = 10000 + FactionID * 1000 + 105,
    common_misc:get_born_info_by_map(MapID).

%% 在外国出生则传送回边城
do_update_map_info_other(RoleId, RoleBase, RolePos, MapId) ->
    #p_role_base{faction_id=FactionID} = RoleBase,
    case common_misc:if_in_self_country(FactionID, MapId) of
        true ->
            RolePos;
        _ ->
            case if_in_neutral_area(MapId) of
                true ->
                    RolePos;
                _ ->
                    {DestMapID, TX, TY} = get_biancheng_born_point(FactionID),
                    Pos = #p_pos{tx=TX, ty=TY},
                    MapProcessName = common_misc:get_common_map_name(DestMapID),
                    NewRolePos = RolePos#p_role_pos{map_id=DestMapID,pos=Pos},
                    do_t_update_map_info_of_vwf(RoleId,NewRolePos,MapProcessName,RolePos)
            end
    end.

%% @doc 是否在中立区或副本
if_in_neutral_area(MapID) ->
    MapID div 1000 =:= 10.
