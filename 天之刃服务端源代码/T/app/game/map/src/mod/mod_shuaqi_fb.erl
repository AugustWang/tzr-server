%% Author: 
%% Created: 2011-9-5
%% Description: TODO: Add description to mod_shuaqi_fb
-module(mod_shuaqi_fb).

%%
%% Include files
%%
-include("mgeem.hrl").
-include("shuaqi_fb.hrl").

-define(sq_fb_map_processname,sq_fb_map_processname).
-define(sq_fb_dict,sq_fb_dict).
%%
%% Exported Functions
%%
-export([loop/2,
         hook_role_online/1,
         hook_role_offline/1,
         hook_role_enter_map/2,
         hook_role_dead/1,
         hook_monster_dead/0,
         hook_quit_team/1,
         hook_monster_change/0]).

-export([handle/1,
         is_shuaqi_fb_map_id/1,
         assert_valid_map_id/1,
         get_role_sq_fb_map_name/2,
         erase_role_sq_fb_map_name/2,
         get_sq_fb_exp_rate/2]).
%% ===============================================================
%% API Functions
%% ===============================================================


put_role_sq_fb_map_name(MapID,RoleID,FbMapProcessName)->
    erlang:put({?sq_fb_map_processname,MapID,RoleID}, FbMapProcessName).

get_role_sq_fb_map_name(MapID,RoleID)->
    erlang:get({?sq_fb_map_processname,MapID,RoleID}).

erase_role_sq_fb_map_name(MapID,RoleID)->
    erlang:erase({?sq_fb_map_processname,MapID,RoleID}).

assert_valid_map_id(MapID)->
    case is_shuaqi_fb_map_id(MapID) of
        true->
            ok;
        _ ->
            ?ERROR_MSG("严重，试图进入错误的地图,DestMapID=~w",[MapID]),
            throw({error,error_map_id,MapID})
    end.

is_shuaqi_fb_map_id(MapID)->
    case common_config_dyn:find(shuaqi_fb,sq_fb_map_list) of
        []-> 0;
        [SqFbMapList]->
            lists:any(fun(FbMapID)-> FbMapID =:=MapID end, SqFbMapList)
    end.

loop(MapID,Now)->
    case get_sq_fb_dict(MapID) of
        undefined->
            ignore;
        SqFbMapInfo->
            loop2(MapID,SqFbMapInfo,Now)
    end.

loop2(MapID,SqFbMapInfo,Now)->
    case SqFbMapInfo#r_sq_fb_map_info.status of
        ?sq_fb_status_create->
            case SqFbMapInfo#r_sq_fb_map_info.end_time<Now orelse SqFbMapInfo#r_sq_fb_map_info.in_roles_info=:=[] of
                true->
                    common_map:exit(sq_fb_close_1);
                false->
                    ignore
            end;
        ?sq_fb_status_running->
            #r_sq_fb_map_info{roles_offline_info=RoleOfflineInfoList} = SqFbMapInfo,
            %% 下线保护处理  玩家上线时在分线已处理
            RoleOfflineInfoList2 = 
                lists:foldl(
                  fun({OfflineRoleID,OfflineEndTime},Acc)->
                          case Now>OfflineEndTime of
                              true->
                                  %% 只是记录日志
                                  ?TRY_CATCH(do_sq_fb_role_quit_log([OfflineRoleID]),Err),
                                  Acc;
                              false->
                                  [{OfflineRoleID,OfflineEndTime}|Acc]
                          end
                  end, [], RoleOfflineInfoList),
            case RoleOfflineInfoList2=/=RoleOfflineInfoList of
                true->
                    NewSqFBMapInfo =SqFbMapInfo#r_sq_fb_map_info{roles_offline_info=RoleOfflineInfoList2},
                    set_sq_fb_dict(MapID,NewSqFBMapInfo);
                false->
                    NewSqFBMapInfo = SqFbMapInfo,
                    ignore
            end,
            RoleIDList = mod_map_actor:get_in_map_role(),
            case NewSqFBMapInfo#r_sq_fb_map_info.end_time<Now  %% 倒计时时间到
                orelse (RoleOfflineInfoList2 =:=[] andalso RoleIDList=:=[]) 
                orelse NewSqFBMapInfo#r_sq_fb_map_info.monster_dead_num=:=NewSqFBMapInfo#r_sq_fb_map_info.monster_total_num of
                true->
                    set_sq_fb_dict(MapID,NewSqFBMapInfo#r_sq_fb_map_info{status=?sq_fb_status_close});
                false->
                    loop3(NewSqFBMapInfo#r_sq_fb_map_info.create_list,NewSqFBMapInfo,Now,MapID,RoleIDList)
            end;
        ?sq_fb_status_close->
            do_sq_fb_close();
        _->
            %%?ERROR_MSG("=====IGNORE",[]),
            ignore
    end.

%% ===== loop3 计算是否出生怪  或者广播
loop3([],_,_,_,_)->
    ignore;
%% tm的boss要等其他怪死光了才出生，这个是给boss用的
loop3([#r_sq_create_info{create_time=undefined}=CreateInfo],SqFBMapInfo,Now,MapID,RoleIDList)->
    case mod_map_monster:get_monster_id_list()=:=[] of
        true->
            [{Time,Message}]= common_config_dyn:find(shuaqi_fb,{boss_notice,SqFBMapInfo#r_sq_fb_map_info.fb_type}),
            catch common_broadcast:bc_send_msg_role(RoleIDList,?BC_MSG_TYPE_CENTER,Message),
            set_sq_fb_dict(MapID,SqFBMapInfo#r_sq_fb_map_info{create_list=[CreateInfo#r_sq_create_info{create_time = Now+Time}]});
        false->
            ignore
    end;
loop3([CreateInfo|RestCreateList],SqFBMapInfo,Now,MapID,RoleIDList)->
    case CreateInfo#r_sq_create_info.create_time =< Now of
        true->
            {MonsterList,NoticeID,NewCreateList} = get_monster_list([CreateInfo|RestCreateList],[],Now,MapID),
            #map_state{map_name=MapProcessName} = mgeem_map:get_state(),
            case MonsterList=/=[] of
                true->
                    mod_map_monster:init_common_fb_monster(MapProcessName, MapID, MonsterList);
                false->
                    ignore
            end,
            case NoticeID =/=0 of
                true->
                    do_bc_monster_born_notice(RoleIDList,NoticeID);
                false->
                    ignore
            end,         
            NewMonsterBornNum = erlang:length(MonsterList)+SqFBMapInfo#r_sq_fb_map_info.monster_born_num,
            set_sq_fb_dict(MapID,SqFBMapInfo#r_sq_fb_map_info{create_list=NewCreateList,monster_born_num=NewMonsterBornNum});
        false->
            case SqFBMapInfo#r_sq_fb_map_info.monster_born_num=:=0 of
                true->
                    %%?ERROR_MSG("==============================SqFBMapInfo:~w",[SqFBMapInfo]),
                    do_bc_monster_warning(RoleIDList,CreateInfo#r_sq_create_info.create_time-Now);
                false->
                    ignore
            end
    end.

get_monster_list([],MonsterList,_,_)->
    {MonsterList,0,[]};
get_monster_list([#r_sq_create_info{create_time=CreateTime}=CreateInfo|CreateList],MonsterList,Now,MapID)
  when Now>=CreateTime->
    #r_sq_create_info{born_pos={Tx,Ty},type_id=TypeID,notice_id=NoticeID}=CreateInfo,
    NewMonsterList= [#p_monster{monsterid=mod_map_monster:get_max_monster_id_form_process_dict(),
                                reborn_pos=#p_pos{tx=Tx, ty=Ty, dir=1},typeid=TypeID,mapid=MapID}|MonsterList],
    case NoticeID =:=0 of
        true->
            get_monster_list(CreateList,NewMonsterList,Now,MapID);
        false->
            {NewMonsterList,NoticeID,CreateList}
    end;
get_monster_list(CreateList,MonsterList,_,_)->
    {MonsterList,0,CreateList}.

%% 上线清除离线数据 
hook_role_online(RoleID)->
    MapID = mgeem_map:get_mapid(),
    case get_sq_fb_dict(MapID) of
        SqFBMapInfo when is_record(SqFBMapInfo,r_sq_fb_map_info) ->
            #r_sq_fb_map_info{roles_offline_info = RolesOfflineInfoList} = SqFBMapInfo,
            case lists:keyfind(RoleID,1,RolesOfflineInfoList) of
                false ->
                    ignore;
                {RoleID,_} ->
                    set_sq_fb_dict(MapID,SqFBMapInfo#r_sq_fb_map_info{roles_offline_info = lists:keydelete(RoleID,1,RolesOfflineInfoList)})
            end;
        _->
            ignore
    end.

%% 记录离线玩家信息
hook_role_offline(RoleID)->
    MapID = mgeem_map:get_mapid(),
    NowSeconds = common_tool:now(),
    case get_sq_fb_dict(MapID) of
        SqFBMapInfo when is_record(SqFBMapInfo,r_sq_fb_map_info) ->
            [KeepSeconds] = common_config_dyn:find(shuaqi_fb,sq_fb_keep_offline_seconds),
            #r_sq_fb_map_info{roles_offline_info = RolesOfflineInfoList} = SqFBMapInfo,
            set_sq_fb_dict(MapID,SqFBMapInfo#r_sq_fb_map_info{roles_offline_info = [{RoleID,NowSeconds + KeepSeconds}|RolesOfflineInfoList]});
        _->
            ignore
    end.

%% 首个进入副本的人改变副本状态  
%% 所有进入副本的人通知关闭时间
hook_role_enter_map(RoleID,MapID)->
    case get_sq_fb_dict(MapID) of
        SqFBMapInfo when is_record(SqFBMapInfo,r_sq_fb_map_info)->
            #r_sq_fb_map_info{status = FbStatus,end_time = EndTime} = SqFBMapInfo,
            if FbStatus =:= ?sq_fb_status_create ->
                    set_sq_fb_dict(MapID,SqFBMapInfo#r_sq_fb_map_info{status = ?sq_fb_status_running});
               true ->
                    next
            end,
            {_NowDate,{H,M,S}} =
                common_tool:seconds_to_datetime(EndTime),
            StrM = if M >= 10 -> common_tool:to_list(M);true -> lists:concat(["0",M]) end,
            StrS = if S >= 10 -> common_tool:to_list(S);true -> lists:concat(["0",S]) end,
            EnterMessage = common_tool:get_format_lang_resources(?_LANG_SQ_FB_BROADCAST_ENTER_FB,[H,StrM,StrS]),
            ?TRY_CATCH(common_broadcast:bc_send_msg_role(RoleID,?BC_MSG_TYPE_CENTER,EnterMessage),Err);
        _ ->
            ignore
    end.

%% 需要返回地图出生点
hook_role_dead(RoleID)->
    MapID = mgeem_map:get_mapid(),
    case get_sq_fb_dict(MapID) of
        #r_sq_fb_map_info{roles_dead_info=RolesDeadList}=SqFBMapInfo when is_list(RolesDeadList)->
            case lists:keyfind(RoleID, 1, RolesDeadList) of
                false->
                    NewRolesDeadList = [{RoleID,1}|RolesDeadList];
                {RoleID,DeadTimes}->
                    NewRolesDeadList = [{RoleID,DeadTimes+1}|lists:keydelete(RoleID,1, RolesDeadList)]
            end,
            set_sq_fb_dict(MapID,SqFBMapInfo#r_sq_fb_map_info{roles_dead_info=NewRolesDeadList});
        _->
            ignore 
    end.

hook_monster_dead()->
    MapID = mgeem_map:get_mapid(),
    case get_sq_fb_dict(MapID) of
        SqFBMapInfo when is_record(SqFBMapInfo,r_sq_fb_map_info)->
            #r_sq_fb_map_info{monster_dead_num=MonsterDeadNum,monster_total_num=MonsterTotalNum} = SqFBMapInfo,
            %% 可能需要广播
            NewMonsterDeadNum=MonsterDeadNum+1,
            set_sq_fb_dict(MapID,SqFBMapInfo#r_sq_fb_map_info{monster_dead_num=NewMonsterDeadNum}),
            RoleIdList = mod_map_actor:get_in_map_role(),
             CenterMessage = common_tool:get_format_lang_resources(?_LANG_SCENE_WAR_FB_BC_MONSTER,[NewMonsterDeadNum,MonsterTotalNum]),
            (catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,CenterMessage));
        _ ->
            ignore
    end.

hook_quit_team(RoleID)->
    case get_sq_fb_dict(mgeem_map:get_mapid()) of
        SqFBMapInfo when is_record(SqFBMapInfo,r_sq_fb_map_info)->
            ?TRY_CATCH(do_sq_fb_role_quit_log([RoleID]),Err),
            case db:dirty_read(?DB_ROLE_SQ_FB_INFO, RoleID) of
                  [#r_role_sq_fb_info{enter_map_id=EnterMapID,enter_pos=EnterPos}]->
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

hook_monster_change()->
    MapID = mgeem_map:get_mapid(),
    case get_sq_fb_dict(MapID) of
        SqFBMapInfo when is_record(SqFBMapInfo,r_sq_fb_map_info)->
            #r_sq_fb_map_info{monster_change_times=MonsterChangeTimes} = SqFBMapInfo,
            set_sq_fb_dict(MapID,SqFBMapInfo#r_sq_fb_map_info{monster_change_times=MonsterChangeTimes+1});
         _ ->
            ignore
    end.

get_sq_fb_exp_rate(MemberCount,MapID)->
    case common_config_dyn:find(shuaqi_fb, {sq_fb_exp,MapID}) of
        []->
            100;
        [FbList]->
            get_sq_fb_exp_rate2(MemberCount, FbList)
   end.

get_sq_fb_exp_rate2(_RoleNum, []) ->
    100;
get_sq_fb_exp_rate2(RoleNum, [SqFbExpRecord|TFbList]) ->
    if RoleNum >= SqFbExpRecord#r_sq_fb_exp.min_num andalso
       RoleNum =< SqFbExpRecord#r_sq_fb_exp.max_num ->
            SqFbExpRecord#r_sq_fb_exp.exp_rate;
       true ->
            get_sq_fb_exp_rate2(RoleNum, TFbList)
    end.
        
        
        
        
handle({Unique, ?SHUAQI_FB, ?SHUAQI_FB_REQUEST, DataIn, RoleID, PID, _Line, _MapState}) 
  when erlang:is_record(DataIn,m_shuaqi_fb_request_tos)->
    case DataIn#m_shuaqi_fb_request_tos.op_type of
        ?sq_fb_query->
            do_query({Unique,DataIn,RoleID,PID});
        ?sq_fb_enter->
            do_enter({Unique,DataIn,RoleID,PID});
        ?sq_fb_quit->
            do_quit({Unique,DataIn,RoleID,PID});
        _->
            do_sq_fb_error({Unique,DataIn,RoleID,PID},?_LANG_SQ_FB_SYSTEM_ERROR,0)
    end;
handle({create_map_succ,Key}) ->
    do_async_create_map(Key);

handle({init_fb_map_info,MapInfo})->
    init_fb_map_info(MapInfo);

handle({sq_fb_close, Seconds})->
    do_sq_fb_close(Seconds);

handle({sq_fb_process_kill})->
    common_map:exit(sq_fb_map_exit);

handle({bc_born_notice,RoleIDList,Message})->
    (catch common_broadcast:bc_send_msg_role(RoleIDList,?BC_MSG_TYPE_CENTER,Message));

handle(Info)->
    ?ERROR_MSG("unknow Info:~w~n",[Info]).

%% ===============================================================
%% Local Functions
%% ===============================================================

init_fb_map_info(MapInfo)->
    set_sq_fb_dict(mgeem_map:get_mapid(), MapInfo).

set_sq_fb_dict(MapID,MapInfo)->
    erlang:put({?sq_fb_dict,MapID},MapInfo).

get_sq_fb_dict(MapID)->
    erlang:get({?sq_fb_dict,MapID}).


%% 关闭副本  包括把玩家踢出副本和记录日志

do_sq_fb_close()->
    MapID = mgeem_map:get_mapid(),
    case get_sq_fb_dict(MapID) of
        SqFbMapInfo when is_record(SqFbMapInfo,r_sq_fb_map_info)->
            RoleIDList=mod_map_actor:get_in_map_role(),
            case RoleIDList=:=[] of
                true->
                    do_sq_fb_close(0);
                false->
                    [CloseSeconds]=common_config_dyn:find(shuaqi_fb,sq_fb_close_second),
                    do_sq_fb_close(CloseSeconds)
            end,
            set_sq_fb_dict(MapID,SqFbMapInfo#r_sq_fb_map_info{status = ?sq_fb_status_ignore});
        _ ->
            ignore
    end.

do_sq_fb_close(0)->
    RoleIDList=mod_map_actor:get_in_map_role(),
    ?TRY_CATCH(do_sq_fb_role_quit_log(RoleIDList),Err),
     lists:foreach(
      fun(RoleID) ->
              case db:dirty_read(?DB_ROLE_SQ_FB_INFO, RoleID) of
                  [#r_role_sq_fb_info{enter_map_id=EnterMapID,enter_pos=EnterPos}]->
                      #p_pos{tx=EnterTx,ty = EnterTy} = EnterPos,
                      mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID,EnterMapID,EnterTx,EnterTy);
                  _->
                      RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID,role),
                      HomeMapId = common_misc:get_home_map_id(RoleMapInfo#p_map_role.faction_id),
                      {HomeMapId,HomeTx,HomeTy} = common_misc:get_born_info_by_map(HomeMapId),
                      mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, HomeMapId, HomeTx, HomeTy)
              end
      end,RoleIDList),
    erlang:send_after(10000, self(), {mod_shuaqi_fb,{sq_fb_process_kill}});
do_sq_fb_close(Seconds) when Seconds>0 ->
    case get_sq_fb_dict(mgeem_map:get_mapid()) of
        undefined ->
            ignore;
        #r_sq_fb_map_info{fb_type=FbType} ->
            [QuitNpcName] = common_config_dyn:find(shuaqi_fb, {quit_npc_name, FbType}),
            Message = lists:flatten(io_lib:format(?_LANG_SQ_FB_BROADCAST_CLOSE_FB,[common_tool:to_list(Seconds), QuitNpcName])),
            RoleIdList = mod_map_actor:get_in_map_role(),
            (catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,Message)),
            if Seconds - 5 >= 5 ->
                   erlang:send_after(5000,self(),{mod_shuaqi_fb,{sq_fb_close,Seconds - 5}});
               true ->
                   erlang:send_after(Seconds * 1000,self(),{mod_shuaqi_fb,{sq_fb_close, 0}})
            end
    end.

%% ============
do_quit({Unique,DataIn,RoleID,PID})->
    case catch check_can_quit(RoleID) of
        {ok,RoleMapInfo}->
            do_quit2(RoleMapInfo,RoleID);
        {error,Reason,ReasonCode}->
            do_sq_fb_error({Unique,DataIn,RoleID,PID},Reason,ReasonCode)
    end.

do_quit2(RoleMapInfo,RoleID)->
    ?TRY_CATCH(do_sq_fb_role_quit_log([RoleID]),Err),
    case db:dirty_read(?DB_ROLE_SQ_FB_INFO, RoleID) of
        [#r_role_sq_fb_info{enter_map_id=EnterMapID,enter_pos=EnterPos}]->
            #p_pos{tx=EnterTx,ty = EnterTy} = EnterPos,
            mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID,EnterMapID,EnterTx,EnterTy);
        _->
            RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID,role),
            HomeMapId = common_misc:get_home_map_id(RoleMapInfo#p_map_role.faction_id),
            {HomeMapId,HomeTx,HomeTy} = common_misc:get_born_info_by_map(HomeMapId),
            mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, HomeMapId, HomeTx, HomeTy)
    end.

check_can_quit(RoleID)->
    case get_sq_fb_dict(mgeem_map:get_mapid()) of
        SqFBMapInfo when is_record(SqFBMapInfo,r_sq_fb_map_info)->
            next;
        _->
            erlang:throw({error,?_LANG_SQ_FB_NOT_FB_MAP,0})
    end,
    case mod_map_actor:get_actor_mapinfo(RoleID,role) of
        RoleMapInfo when is_record(RoleMapInfo,p_map_role)->
            next;
        _->
            RoleMapInfo=undefined,
            erlang:throw({error,?_LANG_SQ_FB_SYSTEM_ERROR,0})
    end,
    {ok,RoleMapInfo}.

%% ========点开面板====================
do_query({Unique,DataIn,RoleID,PID})->
    FbType = DataIn#m_shuaqi_fb_request_tos.fb_type,
    case catch check_can_query(FbType,RoleID) of
        ok->
            do_query2(Unique,FbType,RoleID,PID);
        {error,Reason,ReasonCode}->
            do_sq_fb_error({Unique,DataIn,RoleID,PID},Reason,ReasonCode)
    end.

check_can_query(FbType,RoleID)->
    %% 找npc信息
    case common_config_dyn:find(shuaqi_fb, {sq_fb_npc,FbType}) of
        [SqNpcList] when is_list(SqNpcList)->
            next;
        []->
            SqNpcList=[],
            erlang:throw({error,?_LANG_SQ_FB_NO_FB_NPC,0})
    end,
    RoleMapInfo =  mod_map_actor:get_actor_mapinfo(RoleID,role),
    #p_map_role{faction_id=FactionID,pos=RolePos}=RoleMapInfo,
    %% 检查npc信息
    case lists:keyfind(FactionID, #r_sq_fb_npc.faction_id, SqNpcList) of
        SqFbNpc when is_record(SqFbNpc,r_sq_fb_npc)->
            next;
        _->
            SqFbNpc=undefined,
            erlang:throw({error,?_LANG_SQ_FB_NO_FB_NPC,0})
    end,
    %% 是否在npc范围内
    case check_in_valid_range(RolePos,SqFbNpc) of
        true->
            ok;
        false->
            {error,?_LANG_SQ_FB_NOT_IN_NPC_VALID_RANGE,0}
    end.

do_query2(Unique,FbType,RoleID,PID)->
    %%Now = common_tool:now(),
    Date = date(),
    %%[OpenTimeList] = common_config_dyn:find(shuaqi_fb, {sq_fb_open_time,FbType}),
    FightTimes = get_fight_times(RoleID,FbType,common_tool:datetime_to_seconds({Date,{0,0,0}})),
    R= #m_shuaqi_fb_request_toc{op_type=?sq_fb_query,
                                fight_times=FightTimes,
                                fb_type = FbType},
    common_misc:unicast2(PID,Unique,?SHUAQI_FB,?SHUAQI_FB_REQUEST,R).

%% ================================
do_enter({Unique,DataIn,RoleID,PID})->
    FbType = DataIn#m_shuaqi_fb_request_tos.fb_type,
    case catch check_can_enter(FbType,RoleID) of
        {ok,RoleMapInfoList,SqFbMcm,TimeTuple,Now}->
            do_enter2({Unique,DataIn,RoleID,PID},RoleMapInfoList,SqFbMcm,TimeTuple,Now);
        {error,Reason,ReasonCode}->
            do_sq_fb_error({Unique,DataIn,RoleID,PID},Reason,ReasonCode)
    end.
%% 应该可以优化 
check_can_enter(FbType,RoleID)->
    %% 配置
    case common_config_dyn:find(shuaqi_fb,{sq_fb_mcm,FbType}) of
        [SqFbMcm] when is_record(SqFbMcm,r_sq_fb_mcm)->
            next;
        _-> 
            SqFbMcm=undefined,
            erlang:throw({error,?_LANG_SQ_FB_NO_FB_TYPE,0})
    end,
    %% 队伍
    case mod_map_team:get_role_team_info(RoleID) of
        {error,_}->
            RoleTeamInfo = undefined,
            throw({error,?_LANG_SQ_FB_NO_TEAM,1});
        {ok,RoleTeamInfo}->
            next
    end,
    TeamRoleIDList = [SingleTeamRoleInfo#p_team_role.role_id||SingleTeamRoleInfo<-RoleTeamInfo#r_role_team.role_list],
    if TeamRoleIDList =:= []->
           throw({error,?_LANG_SQ_FB_NO_TEAM,1});
       erlang:length(TeamRoleIDList)<SqFbMcm#r_sq_fb_mcm.team_member->
           throw({error,?_LANG_SQ_FB_NO_ENOUGH_TEAM_MEMBER,1});
       true->
           next
    end,
    LeaderRoleID = mod_map_team:get_team_leader_role_id(RoleTeamInfo#r_role_team.role_list),
    if LeaderRoleID =/= RoleID ->
           throw({error,?_LANG_SQ_FB_NOT_LEADER,0});
       true->
           next
    end,
    case mod_map_actor:get_actor_mapinfo(RoleID,role) of
        RoleMapInfo when is_record(RoleMapInfo,p_map_role)->
            next;
        _->
            RoleMapInfo = undefined,
            throw({error,?_LANG_SQ_FB_SYSTEM_ERROR,0})
    end,
    #p_map_role{faction_id=FactionID,pos=RolePos,level=Level}=RoleMapInfo,
    %% 玩家等级
    case Level>=SqFbMcm#r_sq_fb_mcm.min_level 
        andalso Level=<SqFbMcm#r_sq_fb_mcm.max_level of
        true->
            next;
        false->
            throw({error,?_LANG_SQ_FB_NOT_ENOUGH_LEVEL,0})
    end,
    %% 找npc信息
    case common_config_dyn:find(shuaqi_fb, {sq_fb_npc,FbType}) of
        [SqFbNpcList] when is_list(SqFbNpcList)->
            next;
        _->
            SqFbNpcList=[],
            throw({error,?_LANG_SQ_FB_NO_FB_NPC,0})
    end,
    case lists:keyfind(FactionID, #r_sq_fb_npc.faction_id, SqFbNpcList) of
        SqFbNpc when is_record(SqFbNpc,r_sq_fb_npc)->
            next;
        _->
            SqFbNpc=undefined,
            erlang:throw({error,?_LANG_SQ_FB_NO_FB_NPC,0})
    end,
    %% 检查有效范围
    case check_in_valid_range(RolePos,SqFbNpc) of
        true->
            ok;
        false->
            throw({error,?_LANG_SQ_FB_TOO_FAR,0})
    end,    
    %% 当前不能有这个进程
    Now = common_tool:now(),
    case global:whereis_name(get_sq_fb_map_name(FbType,Now)) of
        undefined->
            next;
        false->
            throw({error,?_LANG_SQ_FB_SYSTEM_ERROR,0})
    end,
    Date = date(),
    %% 是否进入副本有效时间
    [OpenTimeList] = common_config_dyn:find(shuaqi_fb, {sq_fb_open_time,FbType}),
    case check_now_in_open_time(OpenTimeList,Now,Date) of
        not_in->
            throw({error,?_LANG_SQ_FB_NOT_OPEN,0});
        {_StartTimeStamp,_EndTimeStamp}->
            next
    end,
    %% 当天凌晨时间戳
    DateZeroTimeStamp = common_tool:datetime_to_seconds({date(),{0,0,0}}),
    %% 攻击次数
    FightTimes = get_fight_times(RoleID,FbType,DateZeroTimeStamp),
    case FightTimes< SqFbMcm#r_sq_fb_mcm.fight_times of
        true->
            next;
        false->
            throw({error,?_LANG_SQ_FB_FIGHT_TIME_LIMIT,0})
    end,
    MemberIDList = lists:delete(RoleID, TeamRoleIDList),
    %% 检查队员...
    {ok,RoleMapInfoList}=
        check_member_can_enter(MemberIDList,FbType,SqFbMcm,SqFbNpc,DateZeroTimeStamp,[RoleMapInfo]),
    {ok,RoleMapInfoList,SqFbMcm,DateZeroTimeStamp,Now}.

%% 是否在npc附近
%% 攻击次数
%% 检查队友
check_member_can_enter([],_,_,_,_,RoleMapInfoList)->
    {ok,RoleMapInfoList};
check_member_can_enter([RoleID|Rest],FbType,SqFbMcm,SqFbNpc,DateZeroTimeStamp,RoleMapInfoList)->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        RoleMapInfo when is_record(RoleMapInfo,p_map_role)->
            next;
        _->
            RoleMapInfo=undefined,
            throw({error,?_LANG_SQ_FB_MEMBER_TOO_FAR,0})
    end,
    #p_map_role{pos=RolePos,level=Level,role_name=RoleName}=RoleMapInfo,
    case Level>=SqFbMcm#r_sq_fb_mcm.min_level 
        andalso Level=<SqFbMcm#r_sq_fb_mcm.max_level of
        true->
            next;
        false->
            throw({error,common_tool:get_format_lang_resources(?_LANG_SQ_FB_MEMBER_NOT_ENOUGH_LEVEL,[RoleName]),0})
    end,
    case check_in_valid_range(RolePos,SqFbNpc) of
        true->
            next;
        false->
            throw({error,common_tool:get_format_lang_resources(?_LANG_SQ_FB_MEMBER_TOO_FAR2,[RoleName]),0})
    end,
     FightTimes = get_fight_times(RoleID,FbType,DateZeroTimeStamp),
    case FightTimes< SqFbMcm#r_sq_fb_mcm.fight_times of
        true->
            next;
        false->
            throw({error,common_tool:get_format_lang_resources(?_LANG_SQ_FB_MEMBER_FIGHT_TIME_LIMIT,[RoleName]),0})
    end,
    check_member_can_enter(Rest,FbType,SqFbMcm,SqFbNpc,DateZeroTimeStamp,[RoleMapInfo|RoleMapInfoList]).
       

%% 检查那啥
do_enter2({Unique,#m_shuaqi_fb_request_tos{fb_type=FbType}=DataIn,RoleID,PID},RoleMapInfoList,SqFbMcm,TimeTuple,Now)->
    #r_sq_fb_mcm{map_id=MapID} = SqFbMcm,
    FbMapProcessName = get_sq_fb_map_name(FbType,Now),
    case global:whereis_name(FbMapProcessName) of
        undefined ->
            mod_map_copy:async_create_copy(MapID, FbMapProcessName, ?MODULE, {RoleID,FbType,Now}),
            log_async_create_map({RoleID,FbType,Now},{{Unique,DataIn,RoleID,PID},RoleMapInfoList,SqFbMcm,FbMapProcessName,TimeTuple,Now});
        _PID->
            do_sq_fb_error({Unique,DataIn,RoleID,PID},?_LANG_SQ_FB_SYSTEM_ERROR,0)
            %%do_enter3({Unique,DataIn,RoleID,PID},RoleMapInfoList,SqFbMcm,FbMapProcessName,TimeTuple,Now)
    end.

do_async_create_map(Key)->
    case get_async_create_map_info(Key) of
        undefined->
            ignore;
        {{Unique,DataIn,RoleID,PID},RoleMapInfoList,SqFbMcm,FbMapProcessName,TimeTuple,Now}->
            erase_async_create_map(Key),
            do_enter3({Unique,DataIn,RoleID,PID},RoleMapInfoList,SqFbMcm,FbMapProcessName,TimeTuple,Now)
    end.

do_enter3({Unique,#m_shuaqi_fb_request_tos{fb_type=FbType}=DataIn,RoleID,PID},RoleMapInfoList,SqFbMcm,FbMapProcessName,TimeTuple,Now)->
    case db:transaction(
           fun()->
                   t_do_enter(RoleMapInfoList,FbType,SqFbMcm,FbMapProcessName,TimeTuple,Now)
           end) of
        {atomic,ok}->
            InRolesInfoList = get_role_sq_fb_map_info(RoleMapInfoList),
            MonsterLevel = get_monster_level(RoleMapInfoList,FbType),
            BornPosList = get_monster_born_list(FbType,MonsterLevel),
            MonsterTypeConfig = get_monster_type(FbType,MonsterLevel),
            MonsterSpaceTimeList = get_monster_born_space_time(FbType,MonsterLevel),
            CreateList=create_info_list(BornPosList,MonsterTypeConfig,MonsterSpaceTimeList,Now+get_fb_prepare_time()),
            MapInfo = #r_sq_fb_map_info{fb_type=FbType,
                                        monster_level = MonsterLevel,
                                        monster_total_num = erlang:length(BornPosList),
                                        create_list = CreateList,
                                        start_time = Now,
                                        end_time= Now+SqFbMcm#r_sq_fb_mcm.max_second,
                                        in_roles_info = InRolesInfoList,
                                        status = ?sq_fb_status_create},    
            %%?ERROR_MSG("=========================shuaqi_fb_map_info:~w",[MapInfo]),
            global:send(FbMapProcessName, {mod_shuaqi_fb,{init_fb_map_info,MapInfo}}),
            DestMapID = SqFbMcm#r_sq_fb_mcm.map_id,
            {_, TX, TY} = common_misc:get_born_info_by_map(DestMapID),
            lists:foreach(fun(#p_map_role{role_id= MemberRoleID})->
                                  put_role_sq_fb_map_name(mgeem_map:get_mapid(),MemberRoleID,FbMapProcessName),
                                  case common_config_dyn:find(shuaqi_fb, {today_activity_id,FbType}) of
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
                    Reason = ?_LANG_SQ_FB_FIGHT_TIME_LIMIT;
                false->
                    Reason = common_tool:get_format_lang_resources(?_LANG_SQ_FB_MEMBER_FIGHT_TIME_LIMIT, [ErrRoleName])
            end,
            do_sq_fb_error({Unique,DataIn,RoleID,PID},Reason,0)
    end.


%% 判断了两次战斗次数 蛋疼
t_do_enter([],_,_,_,_,_)->
    ok;
t_do_enter([RoleMapInfo|RestList],FbType,SqFbMcm,FbMapProcessName,DateTimeStamp,Now)->
    #p_map_role{role_id = RoleID}= RoleMapInfo,
    case db:read(?DB_ROLE_SQ_FB_INFO, RoleID) of
        [#r_role_sq_fb_info{fb_info=FbInfoList}] when is_list(FbInfoList)->
            case lists:keyfind(FbType, #r_role_sq_fb_detail.fb_type, FbInfoList) of
                false->
                    NewFbInfo = #r_role_sq_fb_detail{fb_type=FbType,last_enter_time=Now,fight_times=1},
                    NewFbInfoList = [NewFbInfo|FbInfoList];
                FbInfo->
                    LastEnterTime = FbInfo#r_role_sq_fb_detail.last_enter_time,
                    NewFightTimes = 
                        case DateTimeStamp <LastEnterTime of
                            true->
                                FightTimes = FbInfo#r_role_sq_fb_detail.fight_times,
                                case FightTimes<SqFbMcm#r_sq_fb_mcm.fight_times of
                                    true->
                                        FightTimes+1;
                                    false->
                                        db:abort({error,RoleID,RoleMapInfo#p_map_role.role_name,fight_times})
                                end;
                            false->1
                        end, 
                    NewFbInfo = #r_role_sq_fb_detail{fb_type=FbType,last_enter_time=Now,fight_times = NewFightTimes},
                    NewFbInfoList= [NewFbInfo|lists:delete(FbInfo,FbInfoList)]
            end;
        _->
            NewFbInfoList = [#r_role_sq_fb_detail{fb_type=FbType,last_enter_time=Now,fight_times=1}]
    end,
    NewRoleSqFbInfo = #r_role_sq_fb_info{role_id= RoleID,
                                         enter_map_id=mgeem_map:get_mapid(),
                                         enter_pos = RoleMapInfo#p_map_role.pos,
                                         fb_map_name=FbMapProcessName,
                                         fb_info = NewFbInfoList},
    db:write(?DB_ROLE_SQ_FB_INFO,NewRoleSqFbInfo, write),
    t_do_enter(RestList,FbType,SqFbMcm,FbMapProcessName,DateTimeStamp,Now).


%% 记日志用
do_sq_fb_role_quit_log(RoleIDList) when is_list(RoleIDList)->
    MapID = mgeem_map:get_mapid(),
    Now = common_tool:now(),
    case get_sq_fb_dict(MapID) of
        SqFbMapInfo when is_record(SqFbMapInfo,r_sq_fb_map_info)->
            #r_sq_fb_map_info{fb_type = FbType,
                              monster_level = MonsterLevel,
                              monster_total_num = MonsterTotalNum,
                              monster_born_num = MonsterBornNum,
                              monster_dead_num =MonsterDeadNum,
                              start_time =StartTime,
                              status = Status,
                              in_roles_info = InRoleInfoList,
                              roles_dead_info =RoleDeadList,
                              monster_change_times = MonsterChangeTimes
                              } = SqFbMapInfo,
            {InRoleIDList,InRoleNameList} =
                lists:foldl(
                  fun(#r_role_sq_fb_map_info{role_id =RoleID,role_name = RoleName},{TmpInRoleIDList,TmpInRoleNameList})->
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
                      RoleSqFbMapInfo = lists:keyfind(RoleID, #r_role_sq_fb_map_info.role_id, InRoleInfoList),
                      [#r_role_sq_fb_info{fb_info=FbInfoList}] = db:dirty_read(?DB_ROLE_SQ_FB_INFO, RoleID),
                      #r_role_sq_fb_detail{fight_times=FightTimes} = lists:keyfind(FbType,#r_role_sq_fb_detail.fb_type,FbInfoList),
                      case lists:keyfind(RoleID, 1, RoleDeadList) of
                                  {RoleID,DeadTimes}->next;
                                  _->DeadTimes = 0
                              end,
                      RoleSqFbLog = 
                          #r_shuaqi_fb_log{role_id = RoleID,
                                           role_name = RoleSqFbMapInfo#r_role_sq_fb_map_info.role_name,
                                           faction_id = RoleSqFbMapInfo#r_role_sq_fb_map_info.faction_id,
                                           level = RoleSqFbMapInfo#r_role_sq_fb_map_info.level,
                                           team_id = RoleSqFbMapInfo#r_role_sq_fb_map_info.team_id,
                                           status = Status,
                                           times = FightTimes,
                                           start_time = StartTime,
                                           end_time = Now,
                                           fb_type = FbType,
                                           monster_level= MonsterLevel,
                                           dead_times = DeadTimes,
                                           in_number = erlang:length(InRoleInfoList),
                                           in_role_ids =lists:flatten(io_lib:format("~w", [InRoleIDList])),
                                           in_role_names = InRoleNameList,
                                           monster_total_number =MonsterTotalNum,
                                           monster_born_number = MonsterBornNum,
                                           monster_dead_number =MonsterDeadNum,
                                           monster_change_times = MonsterChangeTimes},
                            catch common_general_log_server:log_shuaqi_fb(RoleSqFbLog)
                       end, RoleIDList);
        _->
            ?ERROR_MSG("刷棋副本记录日志错误，找不到副本信息 MapID~w, RoleID~w~n",[MapID,RoleIDList])
    end.


%%===========================
%% 创建信息列表
create_info_list(PosList,MonsterTypeConfig,SpaceTimeList,BornTime)->
    #r_sq_monster_type{monster_type_list= NormalTypeList,
                       boss_type = BossType} = MonsterTypeConfig,
    {ok,{Tx,Ty},CreateInfoList} = create_info({PosList,[]},{NormalTypeList,NormalTypeList},{BornTime,SpaceTimeList}),
    lists:reverse([#r_sq_create_info{create_time=undefined,
                                    type=?create_monster,
                                    born_pos={Tx,Ty},
                                    type_id=BossType,
                                     notice_id=0}|CreateInfoList]).

%% 创建内容  广播和生成怪物
create_info({[{Tx,Ty}],CreateInfoList},_,_)->
    {ok,{Tx,Ty},CreateInfoList};
create_info({PosList,CreateInfoList},{[TypeList|TypeListList],NormalTypeList},{BornTime,SpaceTimeList})->
    {NewBornTime,NewPosList,NewCreateInfoList,NewSpaceTimeList}=
        create_monster_info({PosList,CreateInfoList},TypeList,{BornTime,SpaceTimeList}),
    case TypeListList =:=[] of
        true->
            create_info({NewPosList,NewCreateInfoList},{NormalTypeList,NormalTypeList},{NewBornTime,NewSpaceTimeList});
        false ->
            create_info({NewPosList,NewCreateInfoList},{TypeListList,NormalTypeList},{NewBornTime,NewSpaceTimeList})
    end.


%% 创建怪物
create_monster_info({[{Tx,Ty}],CreateInfoList},_,{_,_})->                                                
    {0,[{Tx,Ty}],CreateInfoList,[]};
create_monster_info({PosList,CreateInfoList},[],{BornTime,[SpaceTime]})->
    {BornTime+SpaceTime#r_sq_monster_born_space.space_seconds,PosList,CreateInfoList,[SpaceTime]};
create_monster_info({PosList,CreateInfoList},[],{BornTime,[SpaceTime|SpaceTimeList]})->
    Num = erlang:length(CreateInfoList),
    if Num=:=SpaceTime#r_sq_monster_born_space.end_num ->
           {BornTime+SpaceTime#r_sq_monster_born_space.rest_seconds,PosList,CreateInfoList,SpaceTimeList};
       Num < SpaceTime#r_sq_monster_born_space.end_num->
           {BornTime+SpaceTime#r_sq_monster_born_space.space_seconds,PosList,CreateInfoList,[SpaceTime|SpaceTimeList]};
       true->
           create_monster_info({PosList,CreateInfoList},[],{BornTime,SpaceTimeList})
    end;
create_monster_info({[{Tx,Ty}|PosList],CreateInfoList},[TypeID|TypeList],{BornTime,[SpaceTime|SpaceTimeList]})->
    #r_sq_monster_born_space{end_num = EndNum,
                             notice_id = NoticeID} = SpaceTime,
    Num = erlang:length(CreateInfoList),
    if Num+1=:=EndNum ->
            NewCreateInfoList = 
                [#r_sq_create_info{create_time=BornTime,
                                   born_pos={Tx,Ty},
                                   type_id=TypeID,
                                   notice_id=NoticeID}|CreateInfoList],
            create_monster_info({PosList,NewCreateInfoList},TypeList,{BornTime,[SpaceTime|SpaceTimeList]});
       true->
           NewCreateInfoList = 
                [#r_sq_create_info{create_time=BornTime,
                                   born_pos={Tx,Ty},
                                   type_id=TypeID,
                                   notice_id=0}|CreateInfoList],
           create_monster_info({PosList,NewCreateInfoList},TypeList,{BornTime,[SpaceTime|SpaceTimeList]})
    end.


get_role_sq_fb_map_info(RoleMapInfoList)->
    [#r_role_sq_fb_map_info{role_id= RoleID,
                            role_name = RoleName,
                            faction_id = FactionID,
                            level = Level,
                            team_id = TeamID}
     ||#p_map_role{role_id =RoleID,
                   role_name = RoleName,
                   faction_id = FactionID,
                   level =Level,
                   team_id = TeamID}<-RoleMapInfoList].



get_fb_prepare_time()->
    [PrepareSeconds]=common_config_dyn:find(shuaqi_fb,sq_fb_prepare_time),
    PrepareSeconds.

%% 获取怪物出生类型
get_monster_type(FbType,MonsterLevel)->
    [[H|RestList]] = common_config_dyn:find(shuaqi_fb,{sq_monster_type,FbType}),
    get_cur_level_config(RestList,MonsterLevel,H).
 %%怪物出生间隔时间
get_monster_born_space_time(FbType,MonsterLevel)->
    [[H|RestList]]=common_config_dyn:find(shuaqi_fb,{sq_monster_born_space,FbType}),
    get_cur_level_config(RestList,MonsterLevel,H).
%% 根据副本类型和动态出生怪物等级来获取所有出生点
%% 后加了随机出生方案
get_monster_born_list(FbType,MonsterLevel)->
    [[H|RestList]] = common_config_dyn:find(shuaqi_fb,{sq_monster_born_pos,FbType}),
    BornMethodIDList=get_cur_level_config(RestList,MonsterLevel,H),
    Length = erlang:length(BornMethodIDList),
    Num = common_tool:random(1, Length),
    MethodID=lists:nth(Num, BornMethodIDList),
    [PosList]=common_config_dyn:find(shuaqi_fb,{monster_born_pos_method,MethodID}),
    PosList.
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
                                           
    
%% 获取动态出生怪物等级
get_monster_level(RoleMapInfoList,FbType)->
    [SqWeightList]=common_config_dyn:find(shuaqi_fb, {sq_born_monster_weight,FbType}),
    {SumLevel,SumWeight} = 
    lists:foldl(
      fun(RoleMapInfo,{_SumLevel,_SumWeight})->
              Level = RoleMapInfo#p_map_role.level,
              Weight = get_weight(SqWeightList,Level),
              {_SumLevel+Level*Weight,_SumWeight+Weight}
       end, {0,0}, RoleMapInfoList),
    MonsterLevel=SumLevel div SumWeight,
    if MonsterLevel<30 ->30;
       true->MonsterLevel
    end.
%% 获取权重
get_weight([SqWeight],_Level)->
    SqWeight#r_sq_born_monster_weight.weight;
get_weight([SqWeight|RestList],Level)->
    if Level =<SqWeight#r_sq_born_monster_weight.max_level->
           SqWeight#r_sq_born_monster_weight.weight;
       true->
           get_weight(RestList,Level)
    end.
       
       
do_sq_fb_error({Unique,DataIn,_RoleID,PID},Reason,ReasonCode)->
    R=#m_shuaqi_fb_request_toc{op_type=DataIn#m_shuaqi_fb_request_tos.op_type,
                               succ=false,
                               reason=Reason,
                               reason_code = ReasonCode}, 
    common_misc:unicast2(PID, Unique, ?SHUAQI_FB, ?SHUAQI_FB_REQUEST, R).


get_sq_fb_map_name(FbType,Now)->
    lists:concat(["mgee_shuaqi_fb_map_", FbType, "_", Now]).

log_async_create_map(Key,Value)->
    erlang:put({mod_shuaqi_fb,Key},Value).
get_async_create_map_info(Key)->
    erlang:get({mod_shuaqi_fb,Key}).
erase_async_create_map(Key)->
    erlang:erase(Key).
        
get_fight_times(RoleID,FbType,DateZeroTimeStamp)->
    case db:dirty_read(?DB_ROLE_SQ_FB_INFO,RoleID) of
        []->0;
        [RoleSqFbInfo]->
            case lists:keyfind(FbType, #r_role_sq_fb_detail.fb_type, RoleSqFbInfo#r_role_sq_fb_info.fb_info) of
                RoleSqFbDetail when is_record(RoleSqFbDetail,r_role_sq_fb_detail)->
                    LastEnterTime =RoleSqFbDetail#r_role_sq_fb_detail.last_enter_time,
                    case DateZeroTimeStamp <LastEnterTime of
                        true->RoleSqFbDetail#r_role_sq_fb_detail.fight_times;
                        false->0
                    end;
                _->0
            end
    end.

check_now_in_open_time([],_Now,_Date)->
    not_in;
check_now_in_open_time([{StartTime,EndTime}|Rest],Now,Date)->
    StartTimeStamp = common_tool:datetime_to_seconds({Date,StartTime}),
    EndTimeStamp = common_tool:datetime_to_seconds({Date,EndTime}),
    if Now <StartTimeStamp ->
           not_in;
       Now > StartTimeStamp andalso Now< EndTimeStamp ->
           {StartTimeStamp,EndTimeStamp};
       true->
           check_now_in_open_time(Rest,Now,Date)
    end.

%%检查是否在npc有效范围内   
check_in_valid_range(RolePos,SqFbNpc)->
    #p_pos{tx=RoleTx,ty=RoleTy}=RolePos,
    #r_sq_fb_npc{npc_id=NpcID} = SqFbNpc,
    [{NpcID, {MapID, Tx, Ty}}] = ets:lookup(?ETS_MAP_NPC, NpcID),
    [{MaxTx,MaxTy}]=common_config_dyn:find(shuaqi_fb,npc_valid_range),
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



do_bc_monster_born_notice(RoleIDList,NoticeID)->
    case common_config_dyn:find(shuaqi_fb, {notice,NoticeID}) of
        []->
            ignore;
        [Message]->
            (catch common_broadcast:bc_send_msg_role(RoleIDList,?BC_MSG_TYPE_CENTER,Message))
    end.

do_bc_monster_warning(RoleIDList,Seconds)->
    if Seconds > 30 orelse Seconds =< 0 ->
           ignore;
       Seconds =< 10  ->
           Message  = common_tool:get_format_lang_resources(?_LANG_SQ_FB_BROADCAST_WARINING_BORN_MONSTER,[Seconds]),
           (catch common_broadcast:bc_send_msg_role(RoleIDList,?BC_MSG_TYPE_CENTER,Message));
       true ->
           ignore
    end.
           
