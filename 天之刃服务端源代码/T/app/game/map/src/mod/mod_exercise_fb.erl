%% Author: 
%% Created: 2011-10-13
%% Description: TODO: 练功房副本  
-module(mod_exercise_fb).

%%
%% Include files
%%
-include("mgeem.hrl").
-include("exercise_fb.hrl").
%%
%% Exported Functions
%%

-export([loop/2,
         hook_role_enter_map/2,
         hook_role_online/1,
         hook_role_offline/1,
         hook_monster_dead/0,
         hook_quit_team/1]).

-export([handle/1,
         get_role_exe_fb_map_name/2,
         erase_role_exe_fb_map_name/2,
         assert_valid_map_id/1,
         is_exercise_fb_map_id/1,
         get_exe_fb_exp_rate/2,
         get_monster_type_list/1]).

%% ===============================================================
%% API Functions
%% ===============================================================

get_monster_type_list(MapID)->
    case get_exe_fb_dict(MapID) of
        undefined ->
            {ok,[]};
        #r_exe_fb_map_info{monster_type_list=MonsterTypeList}->
            {ok,[MonsterType||{_,MonsterType}<-MonsterTypeList]}
    end.

put_role_exe_fb_map_name(MapID,RoleID,FbMapProcessName)->
    erlang:put({?exe_fb_map_processname,MapID,RoleID}, FbMapProcessName).

get_role_exe_fb_map_name(MapID,RoleID)->
    erlang:get({?exe_fb_map_processname,MapID,RoleID}).

erase_role_exe_fb_map_name(MapID,RoleID)->
    erlang:erase({?exe_fb_map_processname,MapID,RoleID}).

assert_valid_map_id(MapID)->
    case is_exercise_fb_map_id(MapID) of
        true->
            ok;
        _ ->
            ?ERROR_MSG("严重，试图进入错误的地图,DestMapID=~w",[MapID]),
            throw({error,error_map_id,MapID})
    end.

is_exercise_fb_map_id(MapID)->
    case common_config_dyn:find(exercise_fb,exe_fb_map_list) of
        []-> 0;
        [ExeFbMapList]->
            lists:any(fun(FbMapID)-> FbMapID =:=MapID end, ExeFbMapList)
    end.


loop(MapID, Now)->
    case get_exe_fb_dict(MapID) of
        undefined ->
            ignore;
        ExeFbMapInfo->
            loop2(MapID,ExeFbMapInfo,Now)
    end.

loop2(MapID,ExeFbMapInfo,Now)->
    case ExeFbMapInfo#r_exe_fb_map_info.status of
        ?exe_fb_status_create->
            case ExeFbMapInfo#r_exe_fb_map_info.end_time<Now orelse ExeFbMapInfo#r_exe_fb_map_info.in_roles_info=:=[] of
                true->
                    common_map:exit(exercise_fb_close_1);
                false->
                    ignore
            end;
        ?exe_fb_status_running->
            #r_exe_fb_map_info{roles_offline_info=RoleOfflineInfoList} = ExeFbMapInfo,
            %% 下线保护处理  玩家上线时在分线已处理
            RoleOfflineInfoList2 = 
                lists:foldl(
                  fun({OfflineRoleID,OfflineEndTime},Acc)->
                          case Now>OfflineEndTime of
                              true->
                                  %% 只是记录日志
                                  ?TRY_CATCH(do_exe_fb_role_quit_log([OfflineRoleID]),Err),
                                  Acc;
                              false->
                                  [{OfflineRoleID,OfflineEndTime}|Acc]
                          end
                  end, [], RoleOfflineInfoList),
            case RoleOfflineInfoList2=/=RoleOfflineInfoList of
                true->
                    NewExeFBMapInfo =ExeFbMapInfo#r_exe_fb_map_info{roles_offline_info=RoleOfflineInfoList2},
                    set_exe_fb_dict(MapID,NewExeFBMapInfo);
                false->
                    NewExeFBMapInfo = ExeFbMapInfo,
                    ignore
            end,
            %% 1.下线列表没人且当前副本没人
            %% 2.结束时间到
            %% 3.怪物死光了
            RoleIDList = mod_map_actor:get_in_map_role(),
            case (RoleOfflineInfoList2=:=[] andalso RoleIDList=:=[]) 
                orelse ExeFbMapInfo#r_exe_fb_map_info.end_time<Now 
                orelse ExeFbMapInfo#r_exe_fb_map_info.monster_dead_num >=ExeFbMapInfo#r_exe_fb_map_info.monster_total_num of
                true->
                    set_exe_fb_dict(MapID,NewExeFBMapInfo#r_exe_fb_map_info{status=?exe_fb_status_close});
                false->
                    loop3(NewExeFBMapInfo,MapID,RoleIDList)
            end;
        ?exe_fb_status_close->
            do_exe_fb_close();
        _->
            ignore
    end.

loop3(ExeFbMapInfo,MapID,RoleIDList)->
    case mod_map_monster:get_monster_id_list() of
        []->
            #r_exe_fb_map_info{create_list = CreateList} = ExeFbMapInfo,
            case is_list(CreateList) andalso CreateList=/=[] of
                true->
                    [H|RestCreateList] = CreateList,
                    #r_exe_fb_pass_info{monster_type = MonsterType,pos_list=PosList} = H,
                    MonsterInfoList = [#p_monster{monsterid=mod_map_monster:get_max_monster_id_form_process_dict(),
                                                  reborn_pos=#p_pos{tx=Tx, ty=Ty, dir=1},
                                                  typeid=MonsterType,
                                                  mapid=MapID}||{Tx,Ty}<-PosList],
                    case MonsterInfoList =/= [] of
                        true->
                             #map_state{map_name=MapProcessName} = mgeem_map:get_state(),
                             mod_map_monster:init_common_fb_monster(MapProcessName, MapID, MonsterInfoList);
                        false->
                            ignore
                    end,
                    {Tx,Ty} = H#r_exe_fb_pass_info.center_pos,
                    #r_exe_fb_map_info{fb_type = FbType,monster_born_num=MonsterBornNum,cur_born_times=CurBornTimes} = ExeFbMapInfo,
                    set_exe_fb_dict(MapID,ExeFbMapInfo#r_exe_fb_map_info{create_list=RestCreateList,
                                                                         cur_pass_id = H#r_exe_fb_pass_info.pass_id,
                                                                         cur_pos = {Tx,Ty},
                                                                         monster_born_num=MonsterBornNum+erlang:length(MonsterInfoList),
                                                                         cur_born_times = CurBornTimes+1}),
                    R = #m_exercise_fb_request_toc{op_type = ?find_path_exercise_fb,
                                                   fb_type = FbType,
                                                   map_id = MapID,
                                                   tx = Tx,
                                                   ty = Ty},
                    common_misc:broadcast(RoleIDList, ?DEFAULT_UNIQUE, ?EXERCISE_FB, ?EXERCISE_FB_REQUEST,R);
%%                     [begin
%%                      ?ERROR_MSG("================role_id:~w",[RoleID]),
%%                      common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?EXERCISE_FB, ?EXERCISE_FB_REQUEST,R)
%%                      end
%%                     ||RoleID<-RoleIDList];
                false->
                    ignore
            end;
        _->
            ignore
    end.


handle({Unique, ?EXERCISE_FB, ?EXERCISE_FB_REQUEST, DataIn, RoleID, PID, _Line})->
    case DataIn#m_exercise_fb_request_tos.op_type of
        ?query_exercise_fb->
            do_query({Unique,DataIn,RoleID,PID});
        ?enter_exercise_fb->
            do_enter(Unique,DataIn,RoleID,PID);
        ?quit_exercise_fb->
            do_quit(Unique,DataIn,RoleID,PID);
        _->
            ?ERROR_MSG("UNKNOW INFO :~w",[DataIn])
    end;

handle({init_fb_map_info,MapInfo})->
    init_fb_map_info(MapInfo);

handle({create_map_succ,Key}) ->
    do_async_create_map(Key);

handle({exe_fb_close, Seconds})->
    do_exe_fb_close(Seconds);

handle({exe_fb_process_kill})->
    common_map:exit(exercise_fb_map_exit);

handle(Info)->
    ?ERROR_MSG("unknow info :~w",[Info]).

%% 首个进入副本的人改变副本状态  
%% 所有进入副本的人通知关闭时间
hook_role_enter_map(RoleID,MapID)->
    case get_exe_fb_dict(MapID) of
        ExeFbMapInfo when is_record(ExeFbMapInfo,r_exe_fb_map_info)->
            #r_exe_fb_map_info{status = FbStatus,end_time = EndTime,
                               fb_type = FbType,
                               cur_pos=CurPos} = ExeFbMapInfo,
            if FbStatus =:= ?exe_fb_status_create ->
                    set_exe_fb_dict(MapID,ExeFbMapInfo#r_exe_fb_map_info{status = ?exe_fb_status_running});
               true ->
                    next
            end,
            {_NowDate,{H,M,S}} =
                common_tool:seconds_to_datetime(EndTime),
            StrM = if M >= 10 -> common_tool:to_list(M);true -> lists:concat(["0",M]) end,
            StrS = if S >= 10 -> common_tool:to_list(S);true -> lists:concat(["0",S]) end,
            EnterMessage = common_tool:get_format_lang_resources(?_LANG_EXE_FB_BROADCAST_ENTER_FB,[H,StrM,StrS]),
            ?TRY_CATCH(common_broadcast:bc_send_msg_role(RoleID,?BC_MSG_TYPE_CENTER,EnterMessage),Err),
            case CurPos of
                {Tx,Ty}->
                    R = #m_exercise_fb_request_toc{op_type = ?find_path_exercise_fb,
                                                   fb_type = FbType,
                                                   map_id = MapID,
                                                   tx = Tx,
                                                   ty = Ty},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?EXERCISE_FB, ?EXERCISE_FB_REQUEST,R);
                _->
                    ignore
            end;
        _ ->
            ignore
    end.

%% 上线清除离线数据 
hook_role_online(RoleID)->
    MapID = mgeem_map:get_mapid(),
    case get_exe_fb_dict(MapID) of
        ExeFBMapInfo when is_record(ExeFBMapInfo,r_exe_fb_map_info) ->
            #r_exe_fb_map_info{roles_offline_info = RolesOfflineInfoList} = ExeFBMapInfo,
            case lists:keyfind(RoleID,1,RolesOfflineInfoList) of
                false ->
                    ignore;
                {RoleID,_} ->
                    set_exe_fb_dict(MapID,ExeFBMapInfo#r_exe_fb_map_info{roles_offline_info = lists:keydelete(RoleID,1,RolesOfflineInfoList)})
            end;
        _->
            ignore
    end.

%% 记录离线玩家信息
hook_role_offline(RoleID)->
    MapID = mgeem_map:get_mapid(),
    NowSeconds = common_tool:now(),
    case get_exe_fb_dict(MapID) of
            ExeFBMapInfo when is_record(ExeFBMapInfo,r_exe_fb_map_info) ->
            [KeepSeconds] = common_config_dyn:find(exercise_fb,exe_fb_keep_offline_seconds),
            #r_exe_fb_map_info{roles_offline_info = RolesOfflineInfoList} = ExeFBMapInfo,
            set_exe_fb_dict(MapID,ExeFBMapInfo#r_exe_fb_map_info{roles_offline_info = [{RoleID,NowSeconds + KeepSeconds}|RolesOfflineInfoList]});
        _->
            ignore
    end.

hook_monster_dead()->
    MapID = mgeem_map:get_mapid(),
    case get_exe_fb_dict(MapID) of
        ExeFBMapInfo when is_record(ExeFBMapInfo,r_exe_fb_map_info)->
            #r_exe_fb_map_info{monster_dead_num=MonsterDeadNum,monster_total_num=MonsterTotalNum} = ExeFBMapInfo,
            %% 可能需要广播
            NewMonsterDeadNum=MonsterDeadNum+1,
            set_exe_fb_dict(MapID,ExeFBMapInfo#r_exe_fb_map_info{monster_dead_num=NewMonsterDeadNum}),
            RoleIdList = mod_map_actor:get_in_map_role(),
             CenterMessage = common_tool:get_format_lang_resources(?_LANG_SCENE_WAR_FB_BC_MONSTER,[NewMonsterDeadNum,MonsterTotalNum]),
            (catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,CenterMessage));
        _ ->
            ignore
    end.

hook_quit_team(RoleID)->
    case get_exe_fb_dict(mgeem_map:get_mapid()) of
        ExeFBMapInfo when is_record(ExeFBMapInfo,r_exe_fb_map_info)->
            ?TRY_CATCH(do_exe_fb_role_quit_log([RoleID]),Err),
            case db:dirty_read(?DB_ROLE_EXE_FB_INFO, RoleID) of
                  [#r_role_exe_fb_info{enter_map_id=EnterMapID,enter_pos=EnterPos}]->
                      #p_pos{tx=EnterTx,ty = EnterTy} = EnterPos,
                      mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID,EnterMapID,EnterTx,EnterTy);
                  _->
                      RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID,role),
                      HomeMapId = common_misc:get_home_map_id(RoleMapInfo#p_map_role.faction_id),
                      {HomeMapId,HomeTx,HomeTy} = common_misc:get_born_info_by_map(HomeMapId),
                      mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, HomeMapId, HomeTx, HomeTy)
             end;
        _ ->
            ignore
    end.

get_exe_fb_exp_rate(MemberCount,MapID)->
    case common_config_dyn:find(exercise_fb, {exe_fb_exp,MapID}) of
        []->
            100;
        [FbList]->
            get_exe_fb_exp_rate2(MemberCount, FbList)
   end.

get_exe_fb_exp_rate2(_RoleNum, []) ->
    100;
get_exe_fb_exp_rate2(RoleNum, [ExeFbExpRecord|TFbList]) ->
    if RoleNum >= ExeFbExpRecord#r_exe_fb_exp.min_num andalso
       RoleNum =< ExeFbExpRecord#r_exe_fb_exp.max_num ->
            ExeFbExpRecord#r_exe_fb_exp.exp_rate;
       true ->
            get_exe_fb_exp_rate2(RoleNum, TFbList)
    end.

%% =====================================================
%% Local Functions
%% =====================================================
do_exe_fb_close()->
    MapID = mgeem_map:get_mapid(),
    case get_exe_fb_dict(MapID) of
        ExeFbMapInfo when is_record(ExeFbMapInfo,r_exe_fb_map_info)->
            RoleIDList=mod_map_actor:get_in_map_role(),
            case RoleIDList=:=[] of
                true->
                    do_exe_fb_close(0);
                false->
                    [CloseSeconds]=common_config_dyn:find(exercise_fb,exe_fb_close_second),
                    do_exe_fb_close(CloseSeconds)
            end,
            set_exe_fb_dict(MapID,ExeFbMapInfo#r_exe_fb_map_info{status = ?exe_fb_status_ignore});
        _ ->
            ignore
    end.

do_exe_fb_close(0)->
    RoleIDList=mod_map_actor:get_in_map_role(),
    ?TRY_CATCH(do_exe_fb_role_quit_log(RoleIDList),Err),
     lists:foreach(
      fun(RoleID) ->
              case db:dirty_read(?DB_ROLE_EXE_FB_INFO, RoleID) of
                  [#r_role_exe_fb_info{enter_map_id=EnterMapID,enter_pos=EnterPos}]->
                      #p_pos{tx=EnterTx,ty = EnterTy} = EnterPos,
                      mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID,EnterMapID,EnterTx,EnterTy);
                  _->
                      RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID,role),
                      HomeMapId = common_misc:get_home_map_id(RoleMapInfo#p_map_role.faction_id),
                      {HomeMapId,HomeTx,HomeTy} = common_misc:get_born_info_by_map(HomeMapId),
                      mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, HomeMapId, HomeTx, HomeTy)
              end
      end,RoleIDList),
    erlang:send_after(10000, self(), {mod_exercise_fb,{exe_fb_process_kill}});
do_exe_fb_close(Seconds) when Seconds>0 ->
    case get_exe_fb_dict(mgeem_map:get_mapid()) of
        ExeFbMapInfo when is_record(ExeFbMapInfo,r_exe_fb_map_info)->
            Message = lists:flatten(io_lib:format(?_LANG_EXE_FB_BROADCAST_CLOSE_FB,[common_tool:to_list(Seconds)])),
            RoleIdList = mod_map_actor:get_in_map_role(),
            (catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,Message)),
            if Seconds - 5 >= 5 ->
                   erlang:send_after(5000,self(),{mod_exercise_fb,{exe_fb_close,Seconds - 5}});
               true ->
                   erlang:send_after(Seconds * 1000,self(),{mod_exercise_fb,{exe_fb_close, 0}})
            end;
        undefined ->
            ignore
    end.



init_fb_map_info(MapInfo)->
    set_exe_fb_dict(mgeem_map:get_mapid(), MapInfo).

set_exe_fb_dict(MapID,MapInfo)->
    erlang:put({?exe_fb_dict,MapID},MapInfo).

get_exe_fb_dict(MapID)->
    erlang:get({?exe_fb_dict,MapID}).

%% ===================退出==============================

do_quit(Unique,DataIn,RoleID,PID)->
    case catch check_can_quit(RoleID) of
        {ok,RoleMapInfo}->
            do_quit2(RoleMapInfo,RoleID);
        {error,ErrCode,Reason}->
            do_exercise_fb_error(Unique,DataIn,RoleID,PID,ErrCode,Reason)
    end.

do_quit2(RoleMapInfo,RoleID)->
    ?TRY_CATCH(do_exe_fb_role_quit_log([RoleID]),Err),
    case db:dirty_read(?DB_ROLE_EXE_FB_INFO, RoleID) of
        [#r_role_exe_fb_info{enter_map_id=EnterMapID,enter_pos=EnterPos}]->
            #p_pos{tx=EnterTx,ty = EnterTy} = EnterPos,
            mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID,EnterMapID,EnterTx,EnterTy);
        _->
            RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID,role),
            HomeMapId = common_misc:get_home_map_id(RoleMapInfo#p_map_role.faction_id),
            {HomeMapId,HomeTx,HomeTy} = common_misc:get_born_info_by_map(HomeMapId),
            mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, HomeMapId, HomeTx, HomeTy)
    end.

check_can_quit(RoleID)->
    case get_exe_fb_dict(mgeem_map:get_mapid()) of
        ExeFBMapInfo when is_record(ExeFBMapInfo,r_exe_fb_map_info)->
            next;
        _->
            erlang:throw({error,?err_not_exercise_fb,""})
    end,
    case mod_map_actor:get_actor_mapinfo(RoleID,role) of
        RoleMapInfo when is_record(RoleMapInfo,p_map_role)->
            next;
        _->
            RoleMapInfo=undefined,
            erlang:throw({error,?ERR_SYS_ERR,""})
    end,
    {ok,RoleMapInfo}.


%% ==================查询=====================
do_query({Unique,DataIn,RoleID,PID})->
    FbType = DataIn#m_exercise_fb_request_tos.fb_type,
    case check_can_query(FbType,RoleID) of
        ok->
            do_query2(Unique,FbType,RoleID,PID);
        {error,ErrCode,Reason}->
            do_exercise_fb_error(Unique,DataIn,RoleID,PID,ErrCode,Reason)
    end.

check_can_query(_FbType,_RoleID)->
    ok.

do_query2(Unique,FbType,RoleID,PID)->
    DateZeroTime = common_tool:datetime_to_seconds({date(),{0,0,0}}),
    FightTimes = get_fight_times(RoleID,FbType,DateZeroTime),
    R= #m_exercise_fb_request_toc{op_type=?query_exercise_fb,
                                  fight_times=FightTimes,
                                  fb_type = FbType},
    common_misc:unicast2(PID,Unique,?EXERCISE_FB,?EXERCISE_FB_REQUEST,R).

%% ============================================
do_enter(Unique,DataIn,RoleID,PID)->
    case catch check_can_enter_fb(DataIn#m_exercise_fb_request_tos.fb_type,RoleID) of
        {ok,RoleMapInfoList,ExeFbMcm,TimeTuple,Now}->
            do_enter2({Unique,DataIn,RoleID,PID},RoleMapInfoList,ExeFbMcm,TimeTuple,Now);
        {error,ErrCode,Reason}->
            do_exercise_fb_error(Unique,DataIn,RoleID,PID,ErrCode,Reason)
    end.

check_can_enter_fb(FbType,RoleID)->
    case common_config_dyn:find(exercise_fb,{exe_fb_mcm,FbType}) of
        [ExeFbMcm] when is_record(ExeFbMcm,r_exe_fb_mcm) ->
            next;
        _->
            ExeFbMcm = undefined,
            erlang:throw({error,?ERR_SYS_ERR,""})
    end,
    %% 队伍
    case mod_map_team:get_role_team_info(RoleID) of
        {error,_}->
            RoleTeamInfo = undefined,
            throw({error,?err_no_team,""});
        {ok,RoleTeamInfo}->
            next
    end,
    TeamRoleIDList = [SingleTeamRoleInfo#p_team_role.role_id||SingleTeamRoleInfo<-RoleTeamInfo#r_role_team.role_list],
     if TeamRoleIDList =:= []->
           throw({error,?err_no_team,0});
       erlang:length(TeamRoleIDList)<ExeFbMcm#r_exe_fb_mcm.team_member->
           throw({error,?err_not_enough_team_member,""});
       true->
           next
    end,
    LeaderRoleID = mod_map_team:get_team_leader_role_id(RoleTeamInfo#r_role_team.role_list),
    if LeaderRoleID =/= RoleID ->
           throw({error,?err_not_team_leader,""});
       true->
           next
    end,
    case mod_map_actor:get_actor_mapinfo(RoleID,role) of
        RoleMapInfo when is_record(RoleMapInfo,p_map_role)->
            next;
        _->
            RoleMapInfo = undefined,
            throw({error,?ERR_SYS_ERR,""})
    end,
    #p_map_role{faction_id=FactionID,pos=RolePos,level=Level}=RoleMapInfo,
    %% 玩家等级
    case Level>=ExeFbMcm#r_exe_fb_mcm.min_level 
        andalso Level=<ExeFbMcm#r_exe_fb_mcm.max_level of
        true->
            next;
        false->
            throw({error,?err_level_limit,""})
    end,
    %% 找npc信息
    case common_config_dyn:find(exercise_fb, {exe_fb_npc,FbType}) of
        [ExeFbNpcList] when is_list(ExeFbNpcList)->
            next;
        _->
            ExeFbNpcList=[],
            throw({error,?ERR_SYS_ERR,""})
    end,
    case lists:keyfind(FactionID, #r_exe_fb_npc.faction_id, ExeFbNpcList) of
        ExeFbNpc when is_record(ExeFbNpc,r_exe_fb_npc)->
            next;
        _->
            ExeFbNpc=undefined,
            erlang:throw({error,?ERR_SYS_ERR,""})
    end,
    %% 检查有效范围
    case check_in_valid_range(RolePos,ExeFbNpc) of
        true->
            ok;
        false->
            throw({error,?err_too_far,""})
    end,
    %% 当前不能有这个进程
    Now = common_tool:now(),
    case global:whereis_name(get_exe_fb_map_name(FbType,Now)) of
        undefined->
            next;
        false->
            throw({error,?err_system_too_busy,""})
    end,
    DataZeroTime = common_tool:datetime_to_seconds({date(),{0,0,0}}),
    FightTimes = get_fight_times(RoleID,FbType,DataZeroTime),
    case FightTimes<ExeFbMcm#r_exe_fb_mcm.fight_times of
        true->
            next;
        false->
            throw({error,?err_fight_times_limit,""})
    end,
    MemberIDList = lists:delete(RoleID,TeamRoleIDList),
    %% 检查队员...
    {ok,RoleMapInfoList}=
        check_member_can_enter(MemberIDList,ExeFbMcm,ExeFbNpc,DataZeroTime,[RoleMapInfo]),
    {ok,RoleMapInfoList,ExeFbMcm,DataZeroTime,Now}.

%% 是否在npc附近
%% 攻击次数
%% 检查队友
check_member_can_enter([],_,_,_,RoleMapInfoList)->
    {ok,RoleMapInfoList};
check_member_can_enter([RoleID|Rest],ExeFbMcm,ExeFbNpc,DataZeroTime,RoleMapInfoList)->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        RoleMapInfo when is_record(RoleMapInfo,p_map_role)->
            next;
        _->
            RoleMapInfo=undefined,
            throw({error,?err_member_too_far,""})
    end,
    #p_map_role{pos=RolePos,level=Level,role_name=RoleName}=RoleMapInfo,
    case Level>=ExeFbMcm#r_exe_fb_mcm.min_level 
        andalso Level=<ExeFbMcm#r_exe_fb_mcm.max_level of
        true->
            next;
        false->
            throw({error,?err_member_level_limit,RoleName})
    end,
    case check_in_valid_range(RolePos,ExeFbNpc) of
        true->
            next;
        false->
            throw({error,?err_member_too_far,RoleName})
    end,
    FightTimes = get_fight_times(RoleID,ExeFbMcm#r_exe_fb_mcm.fb_type,DataZeroTime),
    case FightTimes< ExeFbMcm#r_exe_fb_mcm.fight_times of
        true->
            next;
        false->
            throw({error,?err_member_fight_times_limit,RoleName})
    end,
    check_member_can_enter(Rest,ExeFbMcm,ExeFbNpc,DataZeroTime,[RoleMapInfo|RoleMapInfoList]).
     
do_enter2({Unique,DataIn,RoleID,PID},RoleMapInfoList,ExeFbMcm,TimeTuple,Now)->
    #r_exe_fb_mcm{fb_type=FbType,fb_map_id=MapID} = ExeFbMcm,
    FbMapProcessName = get_exe_fb_map_name(FbType,Now),
    case global:whereis_name(FbMapProcessName) of
        undefined ->
            mod_map_copy:async_create_copy(MapID, FbMapProcessName, ?MODULE, {RoleID,FbType,Now}),
            log_async_create_map({RoleID,FbType,Now},{{Unique,DataIn,RoleID,PID},RoleMapInfoList,ExeFbMcm,FbMapProcessName,TimeTuple,Now});
        _PID->
            do_exercise_fb_error(Unique,DataIn,RoleID,PID,?err_system_too_busy,"")
    end.

do_async_create_map(Key)->
    case get_async_create_map_info(Key) of
        undefined->
            ignore;
        {{Unique,DataIn,RoleID,PID},RoleMapInfoList,ExeFbMcm,FbMapProcessName,TimeTuple,Now}->
            erase_async_create_map(Key),
            do_enter3({Unique,DataIn,RoleID,PID},RoleMapInfoList,ExeFbMcm,FbMapProcessName,TimeTuple,Now)
    end.

do_enter3({Unique,#m_exercise_fb_request_tos{fb_type=FbType}=DataIn,RoleID,PID},RoleMapInfoList,ExeFbMcm,FbMapProcessName,TimeTuple,Now)->
    case db:transaction(
           fun()->
                   t_do_enter(RoleMapInfoList,FbType,ExeFbMcm,FbMapProcessName,TimeTuple,Now)
           end) of
        {atomic,ok}->
            MonsterLevel = get_monster_level(RoleMapInfoList,FbType),
            MonsterTypeList = get_monster_type_info(FbType,MonsterLevel),
            PassPosInfoList = get_monster_pass_pos_info(FbType),
            InRolesInfoList = get_role_exe_fb_map_info(RoleMapInfoList),
            CreateList = create_monster_born_list(MonsterTypeList,PassPosInfoList,[]),
            [#r_exe_fb_pass_info{center_pos=CenterPos}|_] = CreateList,
            MapInfo = #r_exe_fb_map_info{fb_type = FbType,
                                         monster_level = MonsterLevel,
                                         monster_type_list = MonsterTypeList,
                                         start_time = Now,
                                         end_time = Now+ExeFbMcm#r_exe_fb_mcm.remain_seconds,
                                         monster_total_num=ExeFbMcm#r_exe_fb_mcm.monster_num,
                                         create_list = CreateList,
                                         cur_pos = CenterPos,
                                         in_roles_info=InRolesInfoList,
                                         status = ?exe_fb_status_create},
            global:send(FbMapProcessName, {mod_exercise_fb,{init_fb_map_info,MapInfo}}),
            DestMapID = ExeFbMcm#r_exe_fb_mcm.fb_map_id,
            {_, TX, TY} = common_misc:get_born_info_by_map(DestMapID),
            lists:foreach(fun(#p_map_role{role_id= MemberRoleID})->
                                  put_role_exe_fb_map_name(mgeem_map:get_mapid(),MemberRoleID,FbMapProcessName),
                                  case common_config_dyn:find(exercise_fb, {today_activity_id,FbType}) of
                                      []->
                                          ignore;
                                      [TodayActivityID]->
                                          hook_activity_task:done_task(MemberRoleID, TodayActivityID)
                                  end,
                                  mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, MemberRoleID, DestMapID, TX, TY)
                          end, RoleMapInfoList);
        {aborted,{error,ErrRoleID,ErrRoleName,_ErrType}}->
            case ErrRoleID =:=RoleID of
                true->
                    ErrCode = ?err_fight_times_limit;
                false->
                    ErrCode = ?err_member_fight_times_limit
            end,
            do_exercise_fb_error(Unique,DataIn,RoleID,PID,ErrCode,ErrRoleName)
    end.

t_do_enter([],_,_,_,_,_)->
    ok;
t_do_enter([RoleMapInfo|RestList],FbType,ExeFbMcm,FbMapProcessName,DataZeroTime,Now)->
    #p_map_role{role_id = RoleID}= RoleMapInfo,
    case db:read(?DB_ROLE_EXE_FB_INFO, RoleID) of
        [#r_role_exe_fb_info{fb_info=FbInfoList}] when is_list(FbInfoList)->
            case lists:keyfind(FbType, #r_role_exe_fb_detail.fb_type, FbInfoList) of
                false->
                    NewFbInfo = #r_role_exe_fb_detail{fb_type=FbType,last_enter_time=Now,fight_times=1},
                    NewFbInfoList = [NewFbInfo|FbInfoList];
                FbInfo->
                    LastEnterTime = FbInfo#r_role_exe_fb_detail.last_enter_time,
                    NewFightTimes = 
                        case DataZeroTime <LastEnterTime of
                            true->
                                FightTimes =FbInfo#r_role_exe_fb_detail.fight_times,
                                case FightTimes<ExeFbMcm#r_exe_fb_mcm.fight_times of
                                    true->
                                        FightTimes+1;
                                    false->
                                        db:abort({error,RoleID,RoleMapInfo#p_map_role.role_name,fight_times})
                                end;
                            false->1
                        end,
                    NewFbInfo = #r_role_exe_fb_detail{fb_type=FbType,last_enter_time=Now,fight_times = NewFightTimes},
                    NewFbInfoList= [NewFbInfo|lists:delete(FbInfo,FbInfoList)]
            end;
        _->
            NewFbInfoList = [#r_role_exe_fb_detail{fb_type=FbType,last_enter_time=Now,fight_times=1}]
    end,
    NewRoleExeFbInfo = #r_role_exe_fb_info{role_id= RoleID,
                                         enter_map_id=mgeem_map:get_mapid(),
                                         enter_pos = RoleMapInfo#p_map_role.pos,
                                         fb_map_name=FbMapProcessName,
                                         fb_info = NewFbInfoList},
    db:write(?DB_ROLE_EXE_FB_INFO,NewRoleExeFbInfo, write),
    t_do_enter(RestList,FbType,ExeFbMcm,FbMapProcessName,DataZeroTime,Now).


do_exercise_fb_error(Unique,DataIn,_RoleID,PID,ErrCode,Reason)->
    R = #m_exercise_fb_request_toc{op_type = DataIn#m_exercise_fb_request_tos.op_type,
                                   fb_type = DataIn#m_exercise_fb_request_tos.fb_type,
                                   err_code = ErrCode,
                                   reason = Reason},
    common_misc:unicast2(PID, Unique, ?EXERCISE_FB, ?EXERCISE_FB_REQUEST, R).


%% 记日志用
do_exe_fb_role_quit_log(RoleIDList) when is_list(RoleIDList)->
    MapID = mgeem_map:get_mapid(),
    Now = common_tool:now(),
    case get_exe_fb_dict(MapID) of
        ExeFbMapInfo when is_record(ExeFbMapInfo,r_exe_fb_map_info)->
            #r_exe_fb_map_info{fb_type = FbType,
                               monster_level = MonsterLevel,
                               monster_total_num = MonsterTotalNum,
                               monster_born_num = MonsterBornNum,
                               monster_dead_num =MonsterDeadNum,
                               start_time =StartTime,
                               status = Status,
                               in_roles_info = InRoleInfoList,
                               cur_pass_id = CurPassID,
                               cur_born_times=CurBornTimes
                              } = ExeFbMapInfo,
            {InRoleIDList,InRoleNameList} =
                lists:foldl(
                  fun(#r_role_exe_fb_map_info{role_id =RoleID,role_name = RoleName},{TmpInRoleIDList,TmpInRoleNameList})->
                          {[RoleID|TmpInRoleIDList],
                           if TmpInRoleNameList =:= "" ->
                                  lists:append([TmpInRoleNameList,common_tool:to_list(RoleName)]);
                              true ->
                                  lists:append([TmpInRoleNameList,",",common_tool:to_list(RoleName)])
                           end
                          }
                  end, {[],[]}, InRoleInfoList),
            lists:foreach(
              fun(RoleID)->
                      RoleExeFbMapInfo = lists:keyfind(RoleID, #r_role_exe_fb_map_info.role_id, InRoleInfoList),
                      [#r_role_exe_fb_info{fb_info=FbInfoList}] = db:dirty_read(?DB_ROLE_EXE_FB_INFO, RoleID),
                      #r_role_exe_fb_detail{fight_times=FightTimes} = lists:keyfind(FbType,#r_role_exe_fb_detail.fb_type,FbInfoList),
                      RoleExeFbLog = 
                          #r_exercise_fb_log{role_id = RoleID,
                                             role_name = RoleExeFbMapInfo#r_role_exe_fb_map_info.role_name,
                                             faction_id = RoleExeFbMapInfo#r_role_exe_fb_map_info.faction_id,
                                             level = RoleExeFbMapInfo#r_role_exe_fb_map_info.level,
                                             team_id = RoleExeFbMapInfo#r_role_exe_fb_map_info.team_id,
                                             status = Status,
                                             times = FightTimes,
                                             start_time = StartTime,
                                             end_time = Now,
                                             fb_type = FbType,
                                             monster_level= MonsterLevel,
                                             in_number = erlang:length(InRoleInfoList),
                                             in_role_ids =lists:flatten(io_lib:format("~w", [InRoleIDList])),
                                             in_role_names = InRoleNameList,
                                             monster_total_number =MonsterTotalNum,
                                             monster_born_number = MonsterBornNum,
                                             monster_dead_number =MonsterDeadNum,
                                             cur_pass_id=CurPassID,
                                             cur_born_times= CurBornTimes},
                      ?TRY_CATCH(common_general_log_server:log_exercise_fb(RoleExeFbLog),Err)
              end, RoleIDList);
        _->
            ?ERROR_MSG("刷棋副本记录日志错误，找不到副本信息 MapID~w, RoleID~w~n",[MapID,RoleIDList])
    end.



%%===================tool ================================

get_exe_fb_map_name(FbType,Now)->
    lists:concat(["mgee_exercise_fb_map_", FbType, "_", Now]).

log_async_create_map(Key,Value)->
    erlang:put({mod_exercise_fb,Key},Value).
get_async_create_map_info(Key)->
    erlang:get({mod_exercise_fb,Key}).
erase_async_create_map(Key)->
    erlang:erase(Key).

create_monster_born_list(_,[],CreateList)->
    lists:reverse(CreateList);
create_monster_born_list(PassMonsterTypeList,[PassPosInfo|RestList],CreateList)->
    #r_exe_fb_pass_info{pass_id = PassID,born_times = BornTimes}=PassPosInfo,
    {PassID,MonsterType}=lists:keyfind(PassID, 1, PassMonsterTypeList),
    NewCreateList = lists:foldl(fun(_,AccCreateList)->
                      [PassPosInfo#r_exe_fb_pass_info{monster_type=MonsterType}|AccCreateList]    
                end,CreateList,lists:seq(1, BornTimes)),
    create_monster_born_list(PassMonsterTypeList,RestList,NewCreateList).


%%检查是否在npc有效范围内   
check_in_valid_range(RolePos,ExeFbNpc)->
    #p_pos{tx=RoleTx,ty=RoleTy}=RolePos,
    #r_exe_fb_npc{npc_id=NpcID} = ExeFbNpc,
    [{NpcID, {MapID, Tx, Ty}}] = ets:lookup(?ETS_MAP_NPC, NpcID),
    [{MaxTx,MaxTy}]=common_config_dyn:find(exercise_fb,npc_valid_range),
    TxDiff = erlang:abs(RoleTx - Tx),
    TyDiff = erlang:abs(RoleTy - Ty),
    CurMapID = mgeem_map:get_mapid(),
    if MapID =:=CurMapID 
       andalso TxDiff < MaxTx  
       andalso TyDiff < MaxTy ->
            true;
       true ->
            false
    end.
  
get_fight_times(RoleID,FbType,DataZeroTime)->
    case db:dirty_read(?DB_ROLE_EXE_FB_INFO,RoleID) of
        []->0;
        [RoleExeFbInfo]->
            case lists:keyfind(FbType, #r_role_exe_fb_detail.fb_type, RoleExeFbInfo#r_role_exe_fb_info.fb_info) of
                RoleExeFbDetail when is_record(RoleExeFbDetail,r_role_exe_fb_detail)->
                    LastEnterTime =RoleExeFbDetail#r_role_exe_fb_detail.last_enter_time,
                    case DataZeroTime <LastEnterTime of
                        true->RoleExeFbDetail#r_role_exe_fb_detail.fight_times;
                        false->0
                    end;
                _->0
            end
    end.
  
%% 获取动态出生怪物等级
get_monster_level(RoleMapInfoList,FbType)->
    [ExeWeightList]=common_config_dyn:find(exercise_fb, {exe_born_monster_weight,FbType}),
    {SumLevel,SumWeight} = 
    lists:foldl(
      fun(RoleMapInfo,{_SumLevel,_SumWeight})->
              Level = RoleMapInfo#p_map_role.level,
              Weight = get_weight(ExeWeightList,Level),
              {_SumLevel+Level*Weight,_SumWeight+Weight}
       end, {0,0}, RoleMapInfoList),
    MonsterLevel=SumLevel div SumWeight,
    [MonsterMinLevel] = common_config_dyn:find(exercise_fb, exe_monster_min_level),
    if MonsterLevel<MonsterMinLevel ->MonsterMinLevel;
       true->MonsterLevel
    end.
%% 获取权重
get_weight([ExeWeight],_Level)->
    ExeWeight#r_exe_born_monster_weight.weight;
get_weight([ExeWeight|RestList],Level)->
    if Level =<ExeWeight#r_exe_born_monster_weight.max_level->
           ExeWeight#r_exe_born_monster_weight.weight;
       true->
           get_weight(RestList,Level)
    end.
       
get_monster_type_info(FbType,MonsterLevel)->
    [[H|RestList]] = common_config_dyn:find(exercise_fb,{exe_fb_monster,FbType}),
    get_cur_level_config(RestList,MonsterLevel,H).
  
%% 配置上容易理解一点 这里就小悲剧一点。。
get_cur_level_config([],_,{_,Config})->
    Config;
get_cur_level_config([{Level,NewConfig}|RestList],MonsterLevel,{_,Config})->
    case MonsterLevel >= Level of
        true->
            get_cur_level_config(RestList,MonsterLevel,{Level,NewConfig});
        false->
            Config
    end.
          
get_monster_pass_pos_info(FbType)->
    case common_config_dyn:find(exercise_fb,{exe_fb_pass,FbType}) of
        [PassPosInfoList]->
            PassPosInfoList;
        _->
            []
    end.

get_role_exe_fb_map_info(RoleMapInfoList)->
    [#r_role_exe_fb_map_info{role_id= RoleID,
                            role_name = RoleName,
                            faction_id = FactionID,
                            level = Level,
                            team_id = TeamID}
     ||#p_map_role{role_id =RoleID,
                   role_name = RoleName,
                   faction_id = FactionID,
                   level =Level,
                   team_id = TeamID}<-RoleMapInfoList].
  

