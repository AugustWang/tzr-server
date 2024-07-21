%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2011, 
%%% @doc
%%% 师门同心副本模块代码
%%% @end
%%% Created : 15 Feb 2011 by  <caochuncheng>
%%%-------------------------------------------------------------------
-module(mod_educate_fb).

-include("mgeem.hrl").
-include("educate_fb.hrl").

%% API
-export([
         %% 地图初始化时，大明宝藏初始化
         init/2,
         %% 地图循环处理函数，即一秒循环
         loop/1
        ]).

%% API
-export([
         do_handle_info/1,handle/1,
         get_educate_fb_map_id/0,
         hook_role_dead/2,
         hook_role_enter_map/2,
         hook_team_change/2,
         hook_role_offline/1,
         hook_role_online/1,
         hook_role_drop_goods/2,
         do_cancel_role_educate_fb/1
        ]).

-export([
         init_educate_fb_dict/0,
         put_educate_fb_dict/1,
         get_educate_fb_dict/0,
         get_educate_fb_map_state/2,
         erase_educate_fb_map_state/2
        ]).


%%%===================================================================
%%% API
%%%===================================================================
handle(Info) ->
    do_handle_info(Info).

init_educate_fb_dict() ->
    %% MapId = get_educate_fb_map_id(),
    ok.
put_educate_fb_dict(Record) ->
    MapId = get_educate_fb_map_id(),
    erlang:put({?EDUCATE_FB_RECORD_DICT_PREFIX,MapId},Record).
get_educate_fb_dict() ->
    MapId = get_educate_fb_map_id(),
    erlang:get({?EDUCATE_FB_RECORD_DICT_PREFIX,MapId}).

put_educate_fb_map_state(MapId,FbMapProcessName,RoleId) ->
    erlang:put({?EDUCATE_FB_MAP_STATE_DICT_PREFIX,MapId,RoleId},FbMapProcessName).
get_educate_fb_map_state(MapId,RoleId) ->
    erlang:get({?EDUCATE_FB_MAP_STATE_DICT_PREFIX,MapId,RoleId}).
erase_educate_fb_map_state(MapId,RoleId) ->
    erlang:erase({?EDUCATE_FB_MAP_STATE_DICT_PREFIX,MapId,RoleId}).




%% 地图初始化时，大明宝藏初始化
%% 参数：
%% MapId 地图id
%% MapName 地图进程名称
init(_MapId, _MapName) ->
    
    ok.

%% 地图循环处理函数，即一秒循环
%% 参数
%% MapId 地图id
loop(MapId) ->
    case get_educate_fb_map_id() of
        MapId ->
            loop2(MapId);
        _ ->
            ignore
    end.
loop2(MapId) ->
    case get_educate_fb_dict() of
        undefined ->
            ignore;
        EducateFbRecord ->
            loop3(MapId,EducateFbRecord)
    end.
loop3(_MapId,EducateFbRecord) ->
    #r_educate_fb_dict{
       parent_map_role = ParentMapRoleList,
       end_time = EndTime,
       fb_close_flag = FbCloseFlag,
       leader_role_id = LeaderRoleId,
       fb_offline_roles = FbOfflineRoleList} = EducateFbRecord,
    NowSeconds = common_tool:now(),
    %% 副本队员下线，超过两分种不上线处理
    FbOfflineRoleList2 = 
        lists:foldl(
          fun({OfflineRoleId,OfflineStartTime,OfflineEndTime},AccFbOfflineRoleList) ->
                  if NowSeconds > OfflineEndTime ->
                          case mod_map_actor:get_actor_mapinfo(OfflineRoleId, role) of
                              undefined ->
                                  ?DEBUG("~ts,OfflineRoleId=~w",["玩家已经不在师徒副本中，需要处理",OfflineRoleId]),
                                  %% 玩家在师徒副本中下线，上线时进入不了副本的处理，记录日志
                                  do_role_offline_in_educate_fb(OfflineRoleId,NowSeconds,EducateFbRecord),
                                  catch do_educate_fb_item_bc_leader(LeaderRoleId,OfflineRoleId);
                              _ ->
                                  ignore
                          end,
                          AccFbOfflineRoleList;
                     true ->
                          [{OfflineRoleId,OfflineStartTime,OfflineEndTime}|AccFbOfflineRoleList]
                  end
          end,[],FbOfflineRoleList),
    IsCloseFbFlag = 
        lists:foldl(
          fun(#p_map_role{role_id = VRoleId},Acc) ->
                  case mod_map_actor:get_actor_mapinfo(VRoleId, role) of
                      undefined ->
                          Acc;
                      _ ->
                          false
                  end
          end,true,ParentMapRoleList),
    if  FbCloseFlag =:= ?EDUCATE_FB_MAP_STATUS_RUNNING
        andalso IsCloseFbFlag =:= true 
        andalso FbOfflineRoleList2 =:= [] ->
            %% 副本可以关闭了，记录副本日志，关闭即可
            do_educate_fb_close_log([],NowSeconds,2),
            self() ! {mod_educate_fb,{kill_educate_fb_map}},
            ok;
        true ->
            next
    end,       
            
    EducateFbRecord2 = EducateFbRecord#r_educate_fb_dict{fb_offline_roles = FbOfflineRoleList2},
    %% 副本结束前30秒，消息广播，并最终退出
    if NowSeconds + 30 >= EndTime
       andalso FbCloseFlag =:= ?EDUCATE_FB_MAP_STATUS_RUNNING ->
            put_educate_fb_dict(EducateFbRecord2#r_educate_fb_dict{fb_close_flag = ?EDUCATE_FB_MAP_STATUS_CLOSE}),
            %% 副本时间到了，跟队员出副本，并记录日志
            ?DEBUG("~ts,EducateFbRecord=~w",["副本时间到了，踢人出副本",EducateFbRecord]),
            do_educate_fb_close_and_bc(30);
       true ->
            put_educate_fb_dict(EducateFbRecord2)
    end,
    ok.
%% 获取师门同心副本地图id
get_educate_fb_map_id() ->
    10600.
%% 获取师门同心副本地图进程名称
get_educate_fb_map_process_name(RoleId) ->
    lists:concat(["map_educate_", RoleId, common_tool:now()]).
    
hook_role_dead(RoleId,MapRoleInfo) ->
    self() ! {mod_educate_fb,{role_dead,RoleId,MapRoleInfo}}.

hook_role_enter_map(RoleId,MapId) ->
    FBMapId = get_educate_fb_map_id(),
    if MapId =:= FBMapId ->
            hook_role_enter_map2(RoleId,MapId);
       true ->
            ignore
    end.
hook_role_enter_map2(RoleId,_MapId) ->
    EducateFbDictRecord =  get_educate_fb_dict(),
    #r_educate_fb_dict{fb_close_flag = FbCloseFlag,
                        end_time = EndTime} = EducateFbDictRecord,
    if FbCloseFlag =:= ?EDUCATE_FB_MAP_STATUS_CREATE ->
            put_educate_fb_dict(EducateFbDictRecord#r_educate_fb_dict{
                                  fb_close_flag = ?EDUCATE_FB_MAP_STATUS_RUNNING});
       true ->
            next
    end,
    {_NowDate,{H,M,S}} =
        common_tool:seconds_to_datetime(EndTime),
    StrM = if M >= 10 -> common_tool:to_list(M);true -> lists:concat(["0",M]) end,
    StrS = if S >= 10 -> common_tool:to_list(S);true -> lists:concat(["0",S]) end,
    EnterMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_BROADCAST_ENTER_FB,[common_tool:to_list(H),StrM,StrS])),
    catch common_broadcast:bc_send_msg_role([RoleId],?BC_MSG_TYPE_SYSTEM,EnterMessage).
hook_team_change(RoleId,TeamId) ->
    if TeamId =:= 0 ->
            MapState = mgeem_map:get_state(),
            #map_state{mapid = MapId} = MapState,
            FBMapId = get_educate_fb_map_id(),
            %% 还必须判断当前玩家是否在线，如果不在线此不需要处理
            Flag = common_misc:is_role_online(RoleId),
            if FBMapId =:= MapId andalso Flag =:= true ->
                    hook_team_change2(RoleId,TeamId);
               true ->
                    ignore
            end;
       true ->
            ignore
    end,
    ok.
hook_team_change2(RoleId,_TeamId) ->
    case db:transaction(
           fun() -> 
                   do_t_educate_fb_quit(RoleId)
           end) of
        {atomic,{ok,EducateFbRole,DeleteItemId,UpdateGoodsList,DeleteGoodsList}} ->
            do_educate_fb_role_log(RoleId,EducateFbRole#r_educate_fb.end_time),
            Line = Line = common_role_line_map:get_role_line(RoleId),
            UnicastArg = {line, Line, RoleId},
            if UpdateGoodsList =/= [] ->
                    common_misc:update_goods_notify(UnicastArg,UpdateGoodsList);
               true ->
                    next
            end,
            if DeleteGoodsList =/= [] ->
                    common_misc:del_goods_notify(UnicastArg, DeleteGoodsList);
               true ->
                    next
            end,
            if DeleteItemId =/= 0 ->
                    common_item_logger:log(RoleId, DeleteItemId,1,undefined,?LOG_ITEM_TYPE_QUIT_EDUCATE_FB);
               true ->
                    next
            end;
        {aborted, Reason} ->
            ?ERROR_MSG("~ts,Reason=~w",["玩家离开队伍系统自动退出出副本处理出错",Reason])
    end,
    EducateFbDictRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{parent_map_id = ParentMapId,
                       leader_role_id = LeaderRoleId,
                       parent_map_role = ParentMapRoleList} = EducateFbDictRecord,
    #p_map_role{pos = #p_pos{tx = Tx,ty = Ty}} = 
        lists:keyfind(RoleId,#p_map_role.role_id,ParentMapRoleList),
    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleId, ParentMapId, Tx, Ty),
    catch do_educate_fb_item_bc_leader(LeaderRoleId,RoleId),
    RoleIdList = mod_map_actor:get_in_map_role(),
    if RoleIdList =:= [] ->
            %% 发送消息关闭地图 120000
            erlang:send_after(600000,self(),{mod_educate_fb,{kill_educate_fb_map}});
       true ->
            ignore
    end,
    ok.
%% 玩家下线
hook_role_offline(RoleId) ->
    FBMapId = get_educate_fb_map_id(),
    CurMapId = mgeem_map:get_mapid(),
    if FBMapId =:= CurMapId ->
            hook_role_offline2(RoleId);
       true ->
            ignore
    end.
hook_role_offline2(RoleId) ->
    EducateFbDictRecord = get_educate_fb_dict(),
    StartTime = common_tool:now(),
    EndTime = StartTime + 120,
    #r_educate_fb_dict{parent_map_role = ParentMapRoleList,
                       fb_offline_roles = FbOfflineRoleList}= EducateFbDictRecord,
    case lists:keyfind(RoleId,#p_map_role.role_id,ParentMapRoleList) of
        false ->
            ignore;
        _ ->
            EducateFbDictRecord2 = 
                case lists:keyfind(RoleId,1,FbOfflineRoleList) of
                    false ->
                        EducateFbDictRecord#r_educate_fb_dict{
                          fb_offline_roles = [{RoleId,StartTime,EndTime}|FbOfflineRoleList]};
                    _ ->
                        FbOfflineRoleList2 = lists:keydelete(RoleId,1,FbOfflineRoleList),
                        EducateFbDictRecord#r_educate_fb_dict{
                          fb_offline_roles = [{RoleId,StartTime,EndTime}|FbOfflineRoleList2]}
                end,
            put_educate_fb_dict(EducateFbDictRecord2)
    end,
    ok.
%% 玩家上线
hook_role_online(RoleId) ->
    FBMapId = get_educate_fb_map_id(),
    CurMapId = mgeem_map:get_mapid(),
    if FBMapId =:= CurMapId ->
            hook_role_online2(RoleId);
       true ->
            ignore
    end.
hook_role_online2(RoleId) ->
    EducateFbDictRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{parent_map_role = ParentMapRoleList,
                       fb_offline_roles = FbOfflineRoleList}= EducateFbDictRecord,
    case lists:keyfind(RoleId,#p_map_role.role_id,ParentMapRoleList) of
        false ->
            ignore;
        _ ->
            case lists:keyfind(RoleId,1,FbOfflineRoleList) of
                false ->
                     ignore;
                _ ->
                    FbOfflineRoleList2 = lists:keydelete(RoleId,1,FbOfflineRoleList),
                    EducateFbDictRecord2 = EducateFbDictRecord#r_educate_fb_dict{
                                             fb_offline_roles = FbOfflineRoleList2},
                    put_educate_fb_dict(EducateFbDictRecord2)
            end
    end,
    ok.

%% 玩家在师徒副本中下线，上线时进入不了副本的处理，记录日志
do_role_offline_in_educate_fb(RoleId,NowSeconds,EducateFbRecord) ->
    #r_educate_fb_dict{educate_fb_role = EducateFbRoleList,
                       fb_count = FbCount} = EducateFbRecord,
    EducateFbRole = lists:keyfind(RoleId,#r_educate_fb.role_id,EducateFbRoleList),
    FbCount2 = if FbCount < 0 -> 0; true -> FbCount end,
    {AwardList,BcList} = calc_award_p_goods_by_sum_count(RoleId,FbCount2 + EducateFbRole#r_educate_fb.lucky_count),
    EducateFbRole2 = EducateFbRole#r_educate_fb{
                       end_time = NowSeconds,
                       status = ?EDUCATE_FB_STATUS_COMPLETE,
                       bc_list = BcList,
                       award_list = AwardList,
                       count = FbCount2},
    db:dirty_write(?DB_EDUCATE_FB,EducateFbRole2),
    do_educate_fb_role_log(RoleId,NowSeconds),
    ok.

%% 进入师门同心副本
do_handle_info({Unique, ?EDUCATE_FB, ?EDUCATE_FB_ENTER, DataRecord, RoleId, PId, Line})
  when erlang:is_record(DataRecord,m_educate_fb_enter_tos)->
    do_educate_fb_enter({Unique, ?EDUCATE_FB, ?EDUCATE_FB_ENTER, DataRecord, RoleId, PId, Line});

%% 退出师门同心副本
do_handle_info({Unique, ?EDUCATE_FB, ?EDUCATE_FB_QUIT, DataRecord, RoleId, PId, Line})
  when erlang:is_record(DataRecord,m_educate_fb_quit_tos)->
    do_educate_fb_quit({Unique, ?EDUCATE_FB, ?EDUCATE_FB_QUIT, DataRecord, RoleId, PId, Line});

%% 使用副本道具
do_handle_info({Unique, ?EDUCATE_FB, ?EDUCATE_FB_ITEM, DataRecord, RoleId, PId, Line})
  when erlang:is_record(DataRecord,m_educate_fb_item_tos)->
    do_educate_fb_item({Unique, ?EDUCATE_FB, ?EDUCATE_FB_ITEM, DataRecord, RoleId, PId, Line});

%% 获取师门同心副本奖励
do_handle_info({Unique, ?EDUCATE_FB, ?EDUCATE_FB_AWARD, DataRecord, RoleId, PId, Line})
  when erlang:is_record(DataRecord,m_educate_fb_award_tos)->
    do_educate_fb_award({Unique, ?EDUCATE_FB, ?EDUCATE_FB_AWARD, DataRecord, RoleId, PId, Line});

%% 查询师门同心副本信息
do_handle_info({Unique, ?EDUCATE_FB, ?EDUCATE_FB_QUERY, DataRecord, RoleId, PId, Line})
  when erlang:is_record(DataRecord,m_educate_fb_query_tos)->
    do_educate_fb_query({Unique, ?EDUCATE_FB, ?EDUCATE_FB_QUERY, DataRecord, RoleId, PId, Line});
%% 刷新幸运积分
do_handle_info({Unique, ?EDUCATE_FB, ?EDUCATE_FB_GAMBLING, DataRecord, RoleId, PId, Line})
  when erlang:is_record(DataRecord,m_educate_fb_gambling_tos)->
    do_educate_fb_gambling({Unique, ?EDUCATE_FB, ?EDUCATE_FB_GAMBLING, DataRecord, RoleId, PId, Line});

%% 后台管理手工开起大明宝藏副本
%% IntervalSeconds 多少秒之后开启
%% global:send(MapProcessName,{mod_educate_fb,{}})

%% 副本初始化相关信息如下
%% global:send(FbMapProcessName, {mod_educate_fb,{enter_educate_info,EducateFbRecord}}),
do_handle_info({enter_educate_info,EducateFbRecord})
  when erlang:is_record(EducateFbRecord,r_educate_fb_dict) ->
    do_enter_educate_info(EducateFbRecord);

%% 普通怪物死亡
do_handle_info({monster_dead,MonsterType}) ->
    do_monster_dead(MonsterType);

do_handle_info({role_dead,RoleId,MapRoleInfo}) ->
    do_role_dead(RoleId,MapRoleInfo);

%% 副本关闭消息处理
do_handle_info({educate_fb_close}) ->
    do_educate_fb_close();

do_handle_info({educate_fb_close_and_bc,MaxInterval}) ->
    do_educate_fb_close_and_bc(MaxInterval);

%% 玩家在师徒副本中通过其它方式传送到其它地图时的处理
%% 门派召集，门派令，国王令等操作
%% global:send(FbMapProcessName, {mod_educate_fb,{cancel_role_educate_fb,RoleId}}),
do_handle_info({cancel_role_educate_fb,RoleId}) ->
    do_cancel_role_educate_fb(RoleId);

do_handle_info({kill_educate_fb_map}) ->
    common_map:exit( educate_fb_map_exit );

%% 异步创建地图处理
do_handle_info({create_map_succ, Key}) ->
    do_create_fb_succ(Key);

do_handle_info(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["师门同心副本无法处理此消息",Info]),
    error.



%% 进入师门同心副本
%% DataRecord 结构为 m_educate_fb_enter_tos
do_educate_fb_enter({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_educate_fb_enter2(RoleId,DataRecord) of
        {error,Reason} ->
            do_educate_fb_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason);
        {throw,Error} ->
            do_do_educate_fb_enter_error2({Unique, Module, Method, DataRecord, RoleId, PId, Line},{throw,Error});
        {ok,RoleMapInfo,MapRoleInfoList} ->
            do_educate_fb_enter3({Unique, Module, Method, DataRecord, RoleId, PId, Line},RoleMapInfo,MapRoleInfoList)
    end.
do_educate_fb_enter2(RoleId,DataRecord) ->
    NpcId = DataRecord#m_educate_fb_enter_tos.npc_id,
    MapId = DataRecord#m_educate_fb_enter_tos.map_id,
    CurMapId = mgeem_map:get_mapid(),
    if MapId =:= CurMapId ->
            next;
       true ->
            ?DEBUG("~ts",["玩家不在可以进入师门同心副本的地图"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_ENTER_PARAM_ERROR})
    end,
    RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                ?DEBUG("~ts",["在本地图获取不到玩家的地图信息"]),
                erlang:throw({error,?_LANG_EDUCATE_FB_ENTER_PARAM_ERROR});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    %% 当前点击的玩家是否有师门关系
    case if_has_homegate(RoleId) of
        true ->
            next;
        false ->
            %% ?DEBUG("~ts",["没师门关系不能进入副本"]),
            next
            %% erlang:throw({error,?_LANG_EDUCATE_FB_ENTER_LEADER_NO_EDUCATE})
    end,
    %% 检查玩家是否在NPC附近
    case check_valid_distance(NpcId,RoleMapInfo) of
        true ->
            next;
        false ->
            ?DEBUG("~ts",["玩家不在NPC附近，无法操作"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_NOT_VALID_DISTANCE})
    end,
    %% 是否是本国国民
    MapFactionId = MapId rem 10000 div 1000,
    if RoleMapInfo#p_map_role.team_id =:= 0 ->
            ?DEBUG("~ts",["玩家当前没有队伍"]),
            erlang:throw({error,get_error_desc_for_not_team()});
       RoleMapInfo#p_map_role.faction_id =/= MapFactionId ->
            ?DEBUG("~ts",["不是本国国民不可以进入副本"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_ENTER_FACTION});
       true ->
            next
    end,
    %% 队伍检查
    MapTeamInfo = 
        case mod_map_team:get_role_team_info(RoleId) of
            {ok,MapTeamInfoT} ->
                
                MapTeamInfoT;
            _ ->
                erlang:throw({error,get_error_desc_for_not_team()})
        end,
    case MapTeamInfo#r_role_team.team_id =:= 0 of
        true ->
            erlang:throw({error,get_error_desc_for_not_team()});
        _ ->
            next
    end,
    %% 队伍人数检查
    MinRoleNumber = get_min_enter_fb_role_number(),
    case erlang:length(MapTeamInfo#r_role_team.role_list) < MinRoleNumber of
        true ->
            erlang:throw({error,get_error_desc_for_not_team()});
        _ ->
            next
    end,
    %% 队长检查
    case RoleId =:= mod_map_team:get_team_leader_role_id(MapTeamInfo#r_role_team.role_list) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_EDUCATE_FB_ENTER_NOT_LEADER})
    end,
    %% 队员是否在同一张地图
    MapRoleInfoList = 
        case lists:foldl(
               fun(TeamRoleInfo,AccMapRoleInfoList) ->
                       case mod_map_actor:get_actor_mapinfo(TeamRoleInfo#p_team_role.role_id,role) of
                           undefined ->
                               AccMapRoleInfoList;
                           MapRoleInfoT ->
                               [MapRoleInfoT|AccMapRoleInfoList]
                       end
               end,[],MapTeamInfo#r_role_team.role_list) of
            MapRoleInfoListT when erlang:is_list(MapRoleInfoListT),
                                  erlang:length(MapRoleInfoListT) =:= erlang:length(MapTeamInfo#r_role_team.role_list) ->
                MapRoleInfoListT;
            _ ->
                erlang:throw({error,?_LANG_EDUCATE_FB_ENTER_NOT_RANGE})
        end,
    %% 检查队员状态
    case lists:foldl(
           fun(SMapRole,{SAccFlag,SAccList}) ->
                   case SMapRole#p_map_role.state =:= ?ROLE_STATE_STALL_SELF
                       orelse SMapRole#p_map_role.state =:= ?ROLE_STATE_DEAD of
                       true ->
                           {false,[SMapRole | SAccList]};
                       _ ->
                           {SAccFlag,SAccList}
                   end
           end,{true,[]},MapRoleInfoList) of
        {false,StateList} ->
            erlang:throw({throw,{error,role_state,StateList}});
        _ ->
            next
    end,
    %% 检查队员级别
    MinRoleLevel = get_min_enter_fb_role_level(),
    case lists:foldl(
           fun(LMapRole,{LAccFlag,LAccList}) ->
                   case LMapRole#p_map_role.level < MinRoleLevel of
                       true ->
                           {false,[LMapRole|LAccList]};
                       _ ->
                           {LAccFlag,LAccList}
                   end
           end,{true,[]},MapRoleInfoList) of
        {false,LevelList} ->
            erlang:throw({throw,{error,role_level,MinRoleLevel,LevelList}});
        _ ->
            next
    end,
    %% 检查NPC位置
    case lists:foldl(
           fun(PMapRole,{PAccFlag,PAccList}) ->
                   %% 检查玩家是否在NPC附近
                   case check_valid_distance(DataRecord#m_educate_fb_enter_tos.npc_id,PMapRole) of
                       true ->
                           {PAccFlag,PAccList};
                       false ->
                           {false,[PMapRole|PAccList]}
                   end
           end,{true,[]},MapRoleInfoList) of
        {false,PosList} ->
            erlang:throw({throw,{error,role_pos,PosList}});
        _ ->
            next
    end,

    %% 判断是不是同一个师门关系的
    %% 根据队长id和队员id列表，判断是否跟队长是属于同门
    %% 返回 ok or {error,Diff, NoHomeGate}
    TargetList = [TargetMapRole#p_map_role.role_id 
                  || TargetMapRole <- MapRoleInfoList,
                     TargetMapRole#p_map_role.role_id =/= RoleId],
    %%case check_in_same_homegate(RoleId, TargetList) of
    case check_in_same_homegate([RoleId|TargetList]) of
        ok ->
            next;
        {error,_DiffRoleIdList,_NoHomeGateRoleIdList} ->
            next
            %% 系统当前没有师徒接口，师徒副本暂时不需要处理师徒关系
            %% erlang:throw({error,educate_home,
            %%               lists:foldl(
            %%                 fun(DiffRoleId,AccDiff) -> 
            %%                         [lists:keyfind(DiffRoleId,#p_map_role.role_id,MapRoleList)|AccDiff]
            %%                 end,[],DiffRoleIdList),
            %%               lists:foldl(
            %%                 fun(NoHomeGateRoleId,AccNo) -> 
            %%                         [lists:keyfind(NoHomeGateRoleId,#p_map_role.role_id,MapRoleList)|AccNo]
            %%                 end,[],NoHomeGateRoleIdList)})
    end,
    {ok,RoleMapInfo,MapRoleInfoList}.
do_educate_fb_enter3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                     RoleMapInfo,MapRoleInfoList) ->
    NowSeconds = common_tool:now(),
    FbMapId = get_educate_fb_map_id(),
    FbMapProcessName = get_educate_fb_map_process_name(RoleId),
    case global:whereis_name(FbMapProcessName) of
        undefined ->
            %% 异步创建师徒地图进程，先创建再判断是否进入成功，不成功即需要处理退出
            log_async_create_map({RoleId,FbMapId,FbMapProcessName},
                                 {{Unique,Module, Method,DataRecord,RoleId,PId,Line},RoleMapInfo,MapRoleInfoList,NowSeconds}),
            mod_map_copy:async_create_copy(FbMapId,FbMapProcessName,?MODULE,{RoleId,FbMapId,FbMapProcessName});
        _ ->
            do_educate_fb_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_EDUCATE_FB_ENTER_PARAM_ERROR)
    end.
log_async_create_map(Key, Info) ->
    erlang:put({mod_educate_fb, Key}, Info).
get_async_create_map_info(Key) ->
    erlang:get({mod_educate_fb, Key}).
do_create_fb_succ(Key) ->
    case get_async_create_map_info(Key) of
        undefined ->
            ignore;
        {{Unique,Module,Method,DataRecord,RoleId,PId,Line},RoleMapInfo,MapRoleInfoList,NowSeconds} ->
            {RoleId,FbMapId,FbMapProcessName} = Key,
            do_educate_fb_enter4({Unique,Module,Method,DataRecord,RoleId,PId,Line},
                                 RoleMapInfo,MapRoleInfoList,NowSeconds,FbMapId,FbMapProcessName)
    end.
do_educate_fb_enter4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                     RoleMapInfo,MapRoleInfoList,NowSeconds,FbMapId,FbMapProcessName) ->
    case db:transaction(
           fun() -> 
                   do_t_educate_fb_enter(RoleId,DataRecord,MapRoleInfoList,NowSeconds,FbMapId,FbMapProcessName)
           end) of
        {atomic,{ok,RoleEducateFbList,GoodsList}} ->
            do_educate_fb_enter5({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                 RoleMapInfo,MapRoleInfoList,RoleEducateFbList,GoodsList,FbMapProcessName,NowSeconds);
        {aborted, Reason} ->
            case global:whereis_name(FbMapProcessName) of
                undefined ->
                    ignore;
                FbMapProcessPid ->
                    catch FbMapProcessPid ! {mod_educate_fb,{kill_educate_fb_map}}
            end,
            do_do_educate_fb_enter_error2({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason)
    end.
do_educate_fb_enter5({Unique, Module, Method, _DataRecord, RoleId, PId, _Line},
                     RoleMapInfo,MapRoleList,RoleEducateFbList,GoodsList,FbMapProcessName,NowSeconds) ->
    MonsterLevel = get_fb_monster_level(MapRoleList),
    MonsterTypeIds = get_fb_monster_type_id(MonsterLevel),
    SendSelf = #m_educate_fb_enter_toc{succ = true,return_self = true,monster_type_ids = MonsterTypeIds},
    ?DEBUG("~ts,SendSelf=~w",["进入师门同心副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    SendMember = #m_educate_fb_enter_toc{succ = true,return_self = false,monster_type_ids = MonsterTypeIds},
    lists:foreach(
      fun(#p_map_role{role_id=VRoleId})->
              if VRoleId =/= RoleId ->
                      common_misc:unicast({role,VRoleId}, ?DEFAULT_UNIQUE, Module, Method, SendMember);
                 true ->
                      ignore
              end
      end,MapRoleList),
    %% 向副本地图发送相关的消息
    do_educate_fb_enter_to_fb_map(RoleId,RoleMapInfo,MapRoleList,FbMapProcessName,
                                  RoleEducateFbList,GoodsList,MonsterLevel,NowSeconds),
    %% 通知背包物品变化
    do_educate_fb_enter_other(GoodsList),
    %% 将玩家传入副本地图
    FBBornPointList = get_fb_map_born(),
    MaxRandomNum = erlang:length(FBBornPointList),
    FBMapId = get_educate_fb_map_id(),
    lists:foreach(
      fun(MapRole) ->
              RandomNumber = random:uniform(MaxRandomNum),
              {Tx, Ty} = lists:nth(RandomNumber,FBBornPointList),
              put_educate_fb_map_state(FBMapId,FbMapProcessName,MapRole#p_map_role.role_id),
              catch mod_map_role:clear_role_spec_state(MapRole#p_map_role.role_id),
              mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_EDUCATE_FB, MapRole#p_map_role.role_id, FBMapId, Tx, Ty)
      end,MapRoleList).

%% 向副本地图发送相关的消息
do_educate_fb_enter_to_fb_map(RoleId,RoleMapInfo,MapRoleList,FbMapProcessName,
                              RoleEducateFbList,GoodsList,MonsterLevel,NowSeconds) ->
    EndTime = NowSeconds + get_max_fb_online_seconds(),
    EducateFbRecord = #r_educate_fb_dict{
      faction_id = RoleMapInfo#p_map_role.faction_id,
      parent_map_id = mgeem_map:get_mapid(),
      parent_map_role = MapRoleList,
      educate_fb_role = RoleEducateFbList,
      fb_count = 0,
      leader_role_id = RoleId,
      leader_role_name = RoleMapInfo#p_map_role.role_name,
      goods = GoodsList,
      item_use_pos = get_random_fb_item_use_pos(),
      start_time = NowSeconds,
      end_time = EndTime,
      monster_level = MonsterLevel,
      fb_map_name = FbMapProcessName,
      fb_dead_roles = [{DeadRoleId,0}||#p_map_role{role_id = DeadRoleId} <- MapRoleList],
      fb_role_dead_times = 0},
    global:send(FbMapProcessName, {mod_educate_fb,{enter_educate_info,EducateFbRecord}}).
do_educate_fb_enter_other(GoodsList) ->
    %% 记录道具日志和通知前端玩家背包
    lists:foreach(
      fun(Goods) ->
              RoleId = Goods#p_goods.roleid,
              Line = common_role_line_map:get_role_line(RoleId),
              catch common_misc:update_goods_notify({line, Line, RoleId},[Goods]),
              common_item_logger:log(RoleId,Goods,1,?LOG_ITEM_TYPE_ENTER_EDUCATE_FB)
      end,GoodsList).

%% 取消玩家的在线挂机，还少玩家是否在摆摊
do_educate_fb_enter_error({Unique, Module, Method, _DataRecord, _RoleId, PId, _Line},Reason) ->
    SendSelf = #m_educate_fb_enter_toc{succ = false,return_self = true,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["进入师门同心副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).
do_do_educate_fb_enter_error2({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason) ->
    case Reason of
        {throw,{error,R}} ->
            do_educate_fb_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},R);
        {throw,{error,educate_home,DiffEducateMapRoleList,NoEducateMapRoleList}} ->
            ?DEBUG("~ts,DiffEducateMapRoleList=~w,NoEducateMapRoleList=~w",["不同师门问列表",DiffEducateMapRoleList,NoEducateMapRoleList]),
            DiffEducateNames = 
                lists:foldl(
                  fun(DiffEducateMapRole,DiffEducateAcc) ->
                          lists:append(["[",common_tool:to_list(DiffEducateMapRole#p_map_role.role_name), "] ", DiffEducateAcc])
                  end,"",DiffEducateMapRoleList),
            catch common_broadcast:bc_send_msg_role([DiffEducateMapRole#p_map_role.role_id || DiffEducateMapRole <- DiffEducateMapRoleList],
                                               ?BC_MSG_TYPE_SYSTEM,?_LANG_EDUCATE_FB_ENTER_DIFF_EDUCATE_ONE),
            NoEducateNames = 
                lists:foldl(
                  fun(NoEducateMapRole,NoEducateAcc) ->
                          lists:append(["[",common_tool:to_list(NoEducateMapRole#p_map_role.role_name), "] ", NoEducateAcc])
                  end,"",NoEducateMapRoleList),
            catch common_broadcast:bc_send_msg_role([NoEducateMapRole#p_map_role.role_id || NoEducateMapRole <- NoEducateMapRoleList],
                                               ?BC_MSG_TYPE_SYSTEM,?_LANG_EDUCATE_FB_ENTER_NO_EDUCATE_ONE),
            DiffEducateMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_DIFF_EDUCATE,[DiffEducateNames])),
            NoEducateMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_NO_EDUCATE,[NoEducateNames])),
            EducateHomeMessage = 
                if DiffEducateMapRoleList =/= [] andalso NoEducateMapRoleList =/= [] ->
                        lists:append([DiffEducateMessage,"\n",NoEducateMessage]);
                   DiffEducateMapRoleList =/= [] ->
                        DiffEducateMessage;
                   NoEducateMapRoleList =/= [] ->
                        NoEducateMessage;
                   true ->
                        ?_LANG_EDUCATE_FB_ENTER_EDUCATE_HOME_ERROR
                end,
            do_educate_fb_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},EducateHomeMessage);
        {throw,{error,role_level,MinRoleLevel,LevelMapRoleList}} ->
            %% 某些玩家不足15级的错误提示
            LevelNames = 
                lists:foldl(
                  fun(LevelMapRole,LevelAcc) ->
                          lists:append(["[",common_tool:to_list(LevelMapRole#p_map_role.role_name), "] ", LevelAcc])
                  end,"",LevelMapRoleList),
            LevelMessageOther = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_ROLE_LEVEL_ONE,[common_tool:to_list(MinRoleLevel)])),
            catch common_broadcast:bc_send_msg_role([LMapRole#p_map_role.role_id || LMapRole <- LevelMapRoleList],
                                               ?BC_MSG_TYPE_SYSTEM,LevelMessageOther),
            LevelMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_ROLE_LEVEL,[LevelNames,common_tool:to_list(MinRoleLevel)])),
            do_educate_fb_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},LevelMessage);
        {throw,{error,role_state,StateMapRoleList}} ->
            StateNames = 
                lists:foldl(
                  fun(StateMapRole,StateAcc) ->
                          lists:append(["[",common_tool:to_list(StateMapRole#p_map_role.role_name), "] ", StateAcc])
                  end,"",StateMapRoleList),
            catch common_broadcast:bc_send_msg_role([SMapRole#p_map_role.role_id || SMapRole <- StateMapRoleList],
                                               ?BC_MSG_TYPE_SYSTEM,?_LANG_EDUCATE_FB_ENTER_ROLE_STATE_ONE),
            StateMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_ROLE_STATE,[StateNames])),
            do_educate_fb_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},StateMessage);
        {throw,{error,role_pos,PosMapRoleList}} ->
            PosNames = 
                lists:foldl(
                  fun(PosMapRole,PosAcc) ->
                          lists:append(["[",common_tool:to_list(PosMapRole#p_map_role.role_name), "] ", PosAcc])
                  end,"",PosMapRoleList),
            PosMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_ROLE_POS,[PosNames])),
            do_educate_fb_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},PosMessage);
        {throw,{error,fb_item,ItemMapRoleList}} ->
            ItemNames = 
                lists:foldl(
                  fun(ItemMapRole,ItemAcc) ->
                          lists:append(["[",common_tool:to_list(ItemMapRole#p_map_role.role_name), "] ", ItemAcc])
                  end,"",ItemMapRoleList),
            catch common_broadcast:bc_send_msg_role([IMapRole#p_map_role.role_id || IMapRole <- ItemMapRoleList],
                                               ?BC_MSG_TYPE_SYSTEM,?_LANG_EDUCATE_FB_ENTER_ROLE_ITEM_ONE),
            PosMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_ROLE_ITEM,[ItemNames])),
            do_educate_fb_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},PosMessage);
        {throw,{error,educate_fb_status_times,MaxTimes,TimesMapRoleList,StatusMapRoleList}} ->
            TimesNames = 
                lists:foldl(
                  fun(TimesMapRole,TimesAcc) ->
                          lists:append(["[",common_tool:to_list(TimesMapRole#p_map_role.role_name), "] ", TimesAcc])
                  end,"",TimesMapRoleList),
            TimesMessageOther = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_ROLE_TIMES_ONE,[common_tool:to_list(MaxTimes)])),
            catch common_broadcast:bc_send_msg_role([TMapRole#p_map_role.role_id || TMapRole <- TimesMapRoleList],
                                               ?BC_MSG_TYPE_SYSTEM,TimesMessageOther),
            TimesMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_ROLE_TIMES,[TimesNames,common_tool:to_list(MaxTimes)])),
            StatusNames = 
                lists:foldl(
                  fun(StatusMapRole,StatusAcc) ->
                          lists:append(["[",common_tool:to_list(StatusMapRole#p_map_role.role_name), "] ", StatusAcc])
                  end,"",StatusMapRoleList),
            catch common_broadcast:bc_send_msg_role([STMapRole#p_map_role.role_id || STMapRole <- StatusMapRoleList],
                                               ?BC_MSG_TYPE_SYSTEM,?_LANG_EDUCATE_FB_ENTER_ROLE_COMPLETE_ONE),
            StatusMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_ROLE_COMPLETE,[StatusNames])),
            TimesStatusMessage = 
                if TimesMapRoleList =/= [] andalso StatusMapRoleList =/= [] ->
                        lists:append([TimesMessage,"\n",StatusMessage]);
                   TimesMapRoleList =/= [] ->
                        TimesMessage;
                   StatusMapRoleList =/= [] ->
                        StatusMessage;
                   true ->
                        ?_LANG_EDUCATE_FB_ENTER_ROLE_TIMES_COMPLETE
                end,
            do_educate_fb_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},TimesStatusMessage); 
        _ ->
            ?DEBUG("~ts,Reason=~w",["进入师门同心副本出错",Reason]),
            Error = ?_LANG_EDUCATE_FB_ENTER_PARAM_ERROR,
            do_educate_fb_enter_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Error)
    end.

do_t_educate_fb_enter(RoleId,DataRecord,MapRoleList,NowSeconds,FbMapId,FbMapProcessName) ->
    {NowDate,_NowTime} =
        common_tool:seconds_to_datetime(NowSeconds),
    TodaySeconds = common_tool:datetime_to_seconds({NowDate,{0,0,0}}),
    MaxTimes = get_max_enter_fb_times(),
    MapId = mgeem_map:get_mapid(),
    {Flag,RoleEducateFbList,TimesList,StatusList} = 
        lists:foldl(
          fun(EMapRole,EAcc) ->
                  {AccFlag,AccEFList,AccTimesList,AccStatusList} = EAcc,
                  ERoleId = EMapRole#p_map_role.role_id,
                  {Times,Status} = 
                      case db:read(?DB_EDUCATE_FB,ERoleId) of
                          [] ->
                              {0,0};
                          [RoleEducateRecord] ->
                              StartTime = RoleEducateRecord#r_educate_fb.start_time,
                              if StartTime > TodaySeconds ->
                                      {RoleEducateRecord#r_educate_fb.times,
                                       RoleEducateRecord#r_educate_fb.status};
                                 true ->
                                      {0,RoleEducateRecord#r_educate_fb.status}
                              end
                      end,
                  if Times >= MaxTimes ->
                          {false,AccEFList,[EMapRole | AccTimesList],AccStatusList};
                     Status =:= ?EDUCATE_FB_STATUS_COMPLETE ->
                          {false,AccEFList,AccTimesList,[EMapRole | AccStatusList]};
                     true ->
                          RoleEducateFb = #r_educate_fb{
                            role_id = EMapRole#p_map_role.role_id,
                            role_name = EMapRole#p_map_role.role_name,
                            faction_id = EMapRole#p_map_role.faction_id,
                            level = EMapRole#p_map_role.level,
                            status = ?EDUCATE_FB_STATUS_RUNNING,
                            times = Times + 1,
                            start_time = NowSeconds,
                            map_id = MapId,
                            pos = EMapRole#p_map_role.pos},
                          {AccFlag,[RoleEducateFb|AccEFList],AccTimesList,AccStatusList}
                  end
          end,{true,[],[],[]},MapRoleList),
    case Flag of
        false ->
            ?DEBUG("~ts,TimesList=~w,StatusList=~w",["玩家不合法，副本次数，或没有领取奖励",TimesList,StatusList]),
            erlang:throw({error,educate_fb_status_times,MaxTimes,TimesList,StatusList});
        true ->
            next
    end,
    do_t_educate_fb_enter2(RoleId,DataRecord,MapRoleList,RoleEducateFbList,NowSeconds,FbMapId,FbMapProcessName).

do_t_educate_fb_enter2(RoleId,_DataRecord,MapRoleList,RoleEducateFbList,NowSeconds,FbMapId,FbMapProcessName) ->
    %% TODO 发布副本道具
    EndTime = NowSeconds + get_max_fb_online_seconds(),
    MemberItemIdList = get_fb_item_member(),
    LeaderItemId = get_fb_item_leader(),
    {ItemFlag,ItemList,GoodsList,_AccMemberItemIdList} = 
        lists:foldl(
          fun(ItemMapRole,ItemAcc) ->
                  {IAccFlag,IAccList,IAccItemList,IAccItemIdList} = ItemAcc,
                  if ItemMapRole#p_map_role.role_id =:= RoleId ->
                          IAccItemIdList2 = IAccItemIdList,
                          CreateItemInfo = #r_goods_create_info{
                            type=?TYPE_ITEM, type_id=LeaderItemId,
                            num=1,bind=true,start_time= NowSeconds,end_time=EndTime};%% start_time= NowSeconds,
                     true ->
                          RandomNumber = random:uniform(erlang:length(IAccItemIdList)),
                          MemberItemId = lists:nth(RandomNumber,IAccItemIdList),
                          IAccItemIdList2 = lists:delete(MemberItemId,IAccItemIdList),
                          CreateItemInfo = #r_goods_create_info{
                            type=?TYPE_ITEM, type_id=MemberItemId,
                            num=1, bind=true, start_time= NowSeconds,end_time=EndTime} %% start_time= NowSeconds,
                  end,
                  case catch mod_bag:create_goods(ItemMapRole#p_map_role.role_id,CreateItemInfo) of
                      {ok,ItemGoods} ->
                          {IAccFlag,IAccList,lists:append([ItemGoods,IAccItemList]),IAccItemIdList2};
                      _ ->
                          {false,[ItemMapRole|IAccList],IAccItemList,IAccItemIdList2}
                  end
          end,{true,[],[],MemberItemIdList},MapRoleList),
    case ItemFlag of
        false ->
            ?DEBUG("~ts",["创建副本道具出错"]),
            erlang:throw({error,fb_item,ItemList});
        true ->
            next
    end,
    case mod_map_copy:create_educate_map_copy(FbMapId,FbMapProcessName) of
        ok ->
            next;
        error ->
            ?ERROR_MSG("~ts,FbMapProcessName=~w",["创建师门同心副本地图进程出错",FbMapProcessName]),
            erlang:throw({error,?_LANG_EDUCATE_FB_ENTER_CREATE_MAP})
    end,
    RoleEducateFbList2 = 
        lists:foldl(
          fun(RoleEducateFb,AccRoleEducateFbList) ->
                  LuckyCount = calc_default_lucky_count(),
                  RoleEducateFb2 = RoleEducateFb#r_educate_fb{
                                     fb_map_name =FbMapProcessName,
                                     lucky_count = LuckyCount},
                  db:write(?DB_EDUCATE_FB,RoleEducateFb2,write),
                  [RoleEducateFb2|AccRoleEducateFbList]
          end,[],RoleEducateFbList),
    {ok,RoleEducateFbList2,GoodsList}.


%% 退出师门同心副本
%% DataRecord 结构为 m_educate_fb_quit_tos
do_educate_fb_quit({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_educate_fb_quit2(RoleId,DataRecord) of
        {error,Reason} ->
            do_educate_fb_quit_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason);
        {ok,RoleMapInfo} ->
            do_educate_fb_quit3({Unique, Module, Method, DataRecord, RoleId, PId, Line},RoleMapInfo)
    end.
do_educate_fb_quit2(RoleId,DataRecord) ->
    MapId = DataRecord#m_educate_fb_quit_tos.map_id,
    NpcId = DataRecord#m_educate_fb_quit_tos.npc_id,
    FBMapId = get_educate_fb_map_id(),
    CurMapId = mgeem_map:get_mapid(),
    if MapId =:= CurMapId 
       andalso MapId =:= FBMapId ->
            next;
       true ->
            ?DEBUG("~ts",["玩家不在可以退出师门同心副本的地图"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_QUIT_PARAM_ERROR})
    end,
    RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                ?DEBUG("~ts",["在本地图获取不到玩家的地图信息"]),
                erlang:throw({error,?_LANG_EDUCATE_FB_QUIT_PARAM_ERROR});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    %% 检查玩家是否在NPC附近
    case check_valid_distance(NpcId,RoleMapInfo) of
        true ->
            next;
        false ->
            ?DEBUG("~ts",["玩家不在NPC附近，无法操作"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_NOT_VALID_DISTANCE})
    end,
    {ok,RoleMapInfo}.

do_educate_fb_quit3({Unique, Module, Method, DataRecord, RoleId, PId, Line},RoleMapInfo) ->
    case db:transaction(
           fun() -> 
                   do_t_educate_fb_quit(RoleId)
           end) of
        {atomic,{ok,EducateFbRole,DeleteItemId,UpdateGoodsList,DeleteGoodsList}} ->
            do_educate_fb_quit4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                RoleMapInfo,EducateFbRole,DeleteItemId,UpdateGoodsList,DeleteGoodsList);
        {aborted, Reason} ->
            Reason2 = 
                case Reason of
                    {throw,{error,R}} ->
                        R;
                    _ ->
                        ?DEBUG("~ts,Reason=~w",["",Reason]),
                        ?_LANG_EDUCATE_FB_QUIT_PARAM_ERROR
                end,
            do_educate_fb_quit_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2)
    end.
do_educate_fb_quit4({Unique, Module, Method, _DataRecord, RoleId, PId, Line},
                    _RoleMapInfo,EducateFbRole,DeleteItemId,UpdateGoodsList,DeleteGoodsList) ->
    SendSelf = #m_educate_fb_quit_toc{succ = true},
    ?DEBUG("~ts,SendSelf=~w",["退出师门同心副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    do_educate_fb_role_log(RoleId,EducateFbRole#r_educate_fb.end_time),
    do_educate_fb_quit_other(RoleId,Line,DeleteItemId,UpdateGoodsList,DeleteGoodsList),
    EducateFbDictRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{parent_map_id = ParentMapId,
                       leader_role_id = LeaderRoleId,
                       parent_map_role = ParentMapRoleList} = EducateFbDictRecord,
    #p_map_role{pos = #p_pos{tx = Tx,ty = Ty}} = 
        lists:keyfind(RoleId,#p_map_role.role_id,ParentMapRoleList),
    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleId, ParentMapId, Tx, Ty),
    catch do_educate_fb_item_bc_leader(LeaderRoleId,RoleId).


do_educate_fb_quit_other(RoleId,Line,DeleteItemId,UpdateGoodsList,DeleteGoodsList) ->
    UnicastArg = {line, Line, RoleId},
    if UpdateGoodsList =/= [] ->
            common_misc:update_goods_notify(UnicastArg,UpdateGoodsList);
       true ->
            next
    end,
    if DeleteGoodsList =/= [] ->
            common_misc:del_goods_notify(UnicastArg, DeleteGoodsList);
       true ->
            next
    end,
    if DeleteItemId =/= 0 ->
            common_item_logger:log(RoleId, DeleteItemId,1,undefined,?LOG_ITEM_TYPE_QUIT_EDUCATE_FB);
       true ->
            next
    end,
    ok.
do_educate_fb_role_log(RoleId,NowSeconds) ->
    EducateFbDictRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{parent_map_role = ParentMapRoleList,
                       educate_fb_role = EducateFbRoleList,
                       leader_role_id = LeaderRoleId,
                       leader_role_name = LeaderRoleName,
                       monster_level = MonsterLevel,
                       fb_count = FbCount,
                       start_time = StartTime,
                       faction_id = FactionId,
                       fb_status = FBStatus,
                       fb_dead_roles = FbDeadRoleList} = EducateFbDictRecord,
    if FBStatus =/= 1 ->
            RoleMapInfo = lists:keyfind(RoleId,#p_map_role.role_id,ParentMapRoleList),
            EducateFbRole = lists:keyfind(RoleId,#r_educate_fb.role_id,EducateFbRoleList),
            {RoleId,RoleDeadTimes} = lists:keyfind(RoleId,1,FbDeadRoleList),
            EducateFbRoleLog = #r_educate_fb_role_log{
              faction_id = FactionId,
              role_id = RoleId,
              role_name = RoleMapInfo#p_map_role.role_name,
              leader_role_id = LeaderRoleId,
              leader_role_name = LeaderRoleName,
              monster_level = MonsterLevel,
              start_time = StartTime,
              status = ?EDUCATE_FB_STATUS_COMPLETE,
              end_time = NowSeconds,
              count = FbCount, 
              times = EducateFbRole#r_educate_fb.times,
              dead_times = RoleDeadTimes},
            catch common_general_log_server:log_educate(EducateFbRoleLog);
       true ->
            ignore
    end.

do_educate_fb_quit_error({Unique, Module, Method, _DataRecord, _RoleId, PId, _Line},Reason) ->
    SendSelf = #m_educate_fb_quit_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["退出师门同心副本返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

do_t_educate_fb_quit(RoleId) ->
    EducateFbDictRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{educate_fb_role = EducateFbRoleList,
                       leader_role_id = LeaderRoleId,
                       used_item_role_ids = UsedItemRoleIds,
                       goods = ItemList,
                       drop_item_role_ids = DropItemRoleIdList,
                       fb_count = FbCount} = EducateFbDictRecord,
    ?DEBUG("~p",[EducateFbDictRecord]),
    %% 删除副本道具
    DeleteItemId = 
        case lists:member(RoleId,DropItemRoleIdList) of
            true ->
                0;
            false ->
                if RoleId =:= LeaderRoleId ->
                        %%是队长需要删除队长道具
                        get_fb_item_leader();
                   true ->
                        case lists:member(RoleId,UsedItemRoleIds) of
                            false ->
                                case lists:keyfind(RoleId,#p_goods.roleid,ItemList) of
                                    false ->
                                        0;
                                    #p_goods{typeid=MemberItemId} ->
                                        MemberItemId
                                end;
                            true ->
                                0
                        end
                end
        end,
    {UpdateGoodsList,DeleteGoodsList} = 
        if DeleteItemId =/= 0 ->
                {ok,UpdateGoodsListT,DeleteGoodsListT} = 
                    mod_bag:decrease_goods_by_typeid(RoleId,[1,2,3,4,5],DeleteItemId,1),
                {UpdateGoodsListT,DeleteGoodsListT};
           true ->
                {[],[]}
        end,
    %% 记录日志，判断是否完成副本
    EducateFbRole = lists:keyfind(RoleId,#r_educate_fb.role_id,EducateFbRoleList),
    EndTime = common_tool:now(),
    FbCount2 = if FbCount < 0 -> 0; true-> FbCount end,
    {AwardList,BcList} = calc_award_p_goods_by_sum_count(RoleId,FbCount2 + EducateFbRole#r_educate_fb.lucky_count),
    EducateFbRole2 = EducateFbRole#r_educate_fb{
                       end_time = EndTime,
                       status = ?EDUCATE_FB_STATUS_COMPLETE,
                       award_list = AwardList,
                       bc_list = BcList,
                       count = FbCount2},
    db:write(?DB_EDUCATE_FB,EducateFbRole2,write),
    {ok,EducateFbRole2,DeleteItemId,UpdateGoodsList,DeleteGoodsList}.


%% 使用副本道具，只处理召唤怪物的道具
%% DataRecord 结构为 m_educate_fb_item_tos
do_educate_fb_item({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_educate_fb_item2(RoleId,DataRecord) of
        {error,Reason} ->
            do_educate_fb_item_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason);
        {ok,RoleMapInfo} ->
            do_educate_fb_item3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                RoleMapInfo)
    end.
do_educate_fb_item2(RoleId,DataRecord) ->
    ItemId = DataRecord#m_educate_fb_item_tos.item_id,
    GoodsId = DataRecord#m_educate_fb_item_tos.goods_id,
    FBMapId = get_educate_fb_map_id(),
    CurMapId = mgeem_map:get_mapid(),
    if CurMapId =:= FBMapId ->
            next;
       true ->
            ?DEBUG("~ts",["玩家在此地图不可以使用此道具"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_FB_MAP_ID})
    end,
     UseGoodsItem = 
        case mod_bag:check_inbag(RoleId,GoodsId) of
            {error,BagError} ->
                ?DEBUG("~ts,BagError=~w",["背包中没有此物品，不可以使用",BagError]),
                erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_NOT_GOODS});
            {ok,UseGoodsItemT} ->
                UseGoodsItemT
        end,
    NowSeconds = common_tool:now(),
    if NowSeconds >= UseGoodsItem#p_goods.start_time 
       andalso UseGoodsItem#p_goods.end_time >= NowSeconds ->
            next;
       true ->
            ?DEBUG("~ts",["此物品已经过期，不可以使用"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_GOODS_EXPIRED})
    end,
    %% {ok,GoodsList} = mod_bag:get_goods_by_typeid(RoleId,ItemId,[1,2,3,4]),
    %% if GoodsList =:= [] ->
    %%         ?DEBUG("~ts",["玩家背包没有此物品"]),
    %%         erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_NOT_GOODS});
    %%    true ->
    %%         next
    %% end,
    RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                ?DEBUG("~ts",["在本地图获取不到玩家的地图信息"]),
                erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_PARAM_ERROR});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    MemberItemIdList = get_fb_item_member(),
    case lists:member(ItemId,MemberItemIdList) of
        false ->
            ?DEBUG("~ts,ItemId=~w",["不是师门副本召唤怪物道具",ItemId]),
            erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_PARAM_ERROR});
        true ->
            next
    end,
    MonsterIdList = mod_map_monster:get_monster_id_list(),
    if MonsterIdList =/= [] ->
            erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_MONSTER});
       true ->
            next
    end,
    #r_educate_fb_dict{
      parent_map_role=ParentMapRoleList,
      leader_role_id=LeaderRoleId,
      goods=FBGoodsList,
      used_item_role_ids = UsedItemRoleIdList,
      drop_item_role_ids = DropItemRoleIdList,
      fb_offline_roles = FbOfflineRoleList,
      item_use_pos=ItemUsePosList}=get_educate_fb_dict(),
    case lists:keyfind(GoodsId,#p_goods.id,FBGoodsList) of
        false ->
            ?DEBUG("~ts",["此副本道具不是本次副本的物品，不可以使用"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_CUR_GOODS_EXPIRED});
        _ ->
            next
    end,
    ItemUsePos = 
        case lists:keyfind(ItemId,#r_educate_fb_item_use_pos.item_id,ItemUsePosList) of
            false ->
                ?DEBUG("~ts,ItemId=~w,ItemUsePosList=~w",["此道具查询不到位置",ItemId,ItemUsePosList]),
                erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_PARAM_ERROR});
            ItemUsePosT ->
                ItemUsePosT
        end,
    %% 道具使用必须安排顺序使用，如查有人下线，放弃
    FBGoodsList2 = lists:keydelete(LeaderRoleId,#p_goods.roleid,FBGoodsList),
    SortFBGoodsList = lists:sort(
                      fun(#p_goods{typeid = SortGoodsTypeIdA},#p_goods{typeid = SortGoodsTypeIdB}) ->
                              SortGoodsTypeIdA < SortGoodsTypeIdB 
                      end,FBGoodsList2),
    {CurUseFlag,CurUseRoleId,CurCanUseItemId} =
        lists:foldl(
          fun(#p_goods{roleid = GoodsRoleId,typeid=GoodsItemId},{AccUseFlag,AccUseRoleId,AccUseItemId}) ->
                  case AccUseFlag of
                      false ->
                          InMapFlag = 
                              case mod_map_actor:get_actor_mapinfo(GoodsRoleId,role) of
                                  undefined ->
                                      false;
                                  _ ->
                                      true
                              end,
                          InTeamFlag = 
                              case lists:keyfind(GoodsRoleId,1,FbOfflineRoleList) of
                                  false ->
                                      false;
                                  _ ->
                                      true
                              end,
                          IsDropItemFlag = lists:member(GoodsRoleId,DropItemRoleIdList),
                          %% 下线并离队
                          if IsDropItemFlag =:= true orelse 
                             (InMapFlag =:= false andalso InTeamFlag =:= false) ->
                                  {AccUseFlag,AccUseRoleId,AccUseItemId};
                             true -> 
                                  case lists:member(GoodsRoleId,UsedItemRoleIdList) of
                                      false ->
                                          {true,GoodsRoleId,GoodsItemId};
                                      true ->
                                          {AccUseFlag,AccUseRoleId,AccUseItemId}
                                  end
                          end;
                      true ->
                          {AccUseFlag,AccUseRoleId,AccUseItemId}
                  end
          end,{false,0,0},SortFBGoodsList),
    if CurUseFlag =:= true 
       andalso CurUseRoleId =:= RoleId 
       andalso CurCanUseItemId =:= ItemId ->
            next;
       true ->
            if CurUseRoleId =/= 0 ->
                    #p_map_role{role_name = CurUseRoleName} = 
                        lists:keyfind(CurUseRoleId,#p_map_role.role_id,ParentMapRoleList),
                    UserMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ITEM_USE_ORDER,[common_tool:to_list(CurUseRoleName)])),
                    erlang:throw({error,UserMessage});
               true ->
                    erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_USE_ORDER_ERROR})
            end
    end,
    case check_use_item_valid_distance(RoleMapInfo,ItemUsePos) of
        true ->
            next;
        false ->
            ?DEBUG("~ts",["不在有效的位置不可以使用此道具"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_USE_NOT_IN_VALID_DISTANCE})
    end,
    RoleIdList = [PMapRole#p_map_role.role_id || PMapRole <- ParentMapRoleList],
    MapRoleList = 
        lists:foldl(
          fun(VRoleId,VAcc) ->
                  case mod_map_actor:get_actor_mapinfo(VRoleId,role) of
                      undefined ->
                          VAcc;
                      VMapRole ->
                          [VMapRole | VAcc]
                  end
          end,[],RoleIdList),
    {DistanceFlag,_DistanceMapRoleList} =
        lists:foldl(
          fun(DMapRole,DAcc) ->
                  {_DAccFlag,DAccList} = DAcc,
                  case check_use_item_valid_distance(DMapRole,ItemUsePos) of
                      false ->
                          {false,[DMapRole|DAccList]};
                      true ->
                          DAcc
                  end
          end,{true,[]},MapRoleList),
    case DistanceFlag of 
        false ->
            ?DEBUG("~ts",["存在队员不在此道具的使用范围内"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_NOT_VALID_DISTANCE});
        true ->
            next
    end,
    {ok,RoleMapInfo}.
do_educate_fb_item3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                    RoleMapInfo) ->
    case db:transaction(
           fun() -> 
                   do_t_educate_fb_item(RoleId,DataRecord)
           end) of
        {atomic,{ok,UpdateGoodsList,DeleteGoodsList}} ->
            do_educate_fb_item4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                RoleMapInfo,UpdateGoodsList,DeleteGoodsList);
        {aborted, Reason} ->
            Reason2 = 
                case Reason of
                    {throw,{error,R}} ->
                        R;
                    _ ->
                        ?_LANG_EDUCATE_FB_ITEM_PARAM_ERROR
                end,
            do_educate_fb_item_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2)
    end.
do_educate_fb_item4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                    _RoleMapInfo,UpdateGoodsList,DeleteGoodsList) ->
    SendSelf = #m_educate_fb_item_toc{succ = true},
    ?DEBUG("~ts,SendSelf=~w",["使用副本道具返回",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    EducateFbRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{fb_map_name = FbMapProcessName,
                       monster_level = MonsterLevel,
                       item_use_pos = ItemUsePosList,
                       leader_role_id = LeaderRoleId,
                       used_item_role_ids = UsedItemRoleIdList} = EducateFbRecord,
    put_educate_fb_dict(EducateFbRecord#r_educate_fb_dict{used_item_role_ids = [RoleId | UsedItemRoleIdList]}),
    %% 召唤怪物
    FBMapId = get_educate_fb_map_id(),
    ItemId = DataRecord#m_educate_fb_item_tos.item_id,
    #r_educate_fb_item_use_pos{tx = UseTx,ty = UseTy} = 
        lists:keyfind(ItemId,#r_educate_fb_item_use_pos.item_id,ItemUsePosList),
    MonsterList = get_fb_p_monster(MonsterLevel,{UseTx,UseTy}),
    lists:foreach(
      fun({MonsterType,Monsters}) ->
              mod_map_monster:init_educate_fb_map_monster(FbMapProcessName, FBMapId, Monsters, MonsterType)
      end,MonsterList),
    do_educate_fb_item_other(RoleId,Line,DataRecord,UpdateGoodsList,DeleteGoodsList),
    %% 使用道具不需要过滤此用户
    catch do_educate_fb_item_bc_leader(LeaderRoleId,0).

do_educate_fb_item_other(RoleId,Line,DataRecord,UpdateGoodsList,DeleteGoodsList) ->
    DeleteItemId = DataRecord#m_educate_fb_item_tos.item_id,
    UnicastArg = {line, Line, RoleId},
    if UpdateGoodsList =/= [] ->
            common_misc:update_goods_notify(UnicastArg,UpdateGoodsList);
       true ->
            next
    end,
    if DeleteGoodsList =/= [] ->
            common_misc:del_goods_notify(UnicastArg, DeleteGoodsList);
       true ->
            next
    end,
    if DeleteItemId =/= 0 ->
            common_item_logger:log(RoleId, DeleteItemId,1,undefined,?LOG_ITEM_TYPE_QUIT_EDUCATE_FB);
       true ->
            next
    end,
    ok.
do_educate_fb_item_bc_leader(LeaderRoleId,LeaveRoleId) ->
    if LeaderRoleId =/= LeaveRoleId ->
            case mod_map_actor:get_actor_mapinfo(LeaderRoleId,role) of
                undefined ->
                    ignore;
                _ ->
                    EducateFbDictRecord = get_educate_fb_dict(),
                    SendSelf = get_educate_fb_query_toc_by_dict(
                                 LeaderRoleId,
                                 ?EDUCATE_FB_QUERY_TYPE_USE_LEADER_ITEM,
                                 EducateFbDictRecord),
                    FbItemList = SendSelf#m_educate_fb_query_toc.fb_items,
                    FbItemList2 = lists:keydelete(LeaveRoleId,#p_educate_fb_item.role_id,FbItemList),
                    SendSelf2 = SendSelf#m_educate_fb_query_toc{fb_items = FbItemList2},
                    Line = common_role_line_map:get_role_line(LeaderRoleId),
                    ?DEBUG("~ts,SendSelf=~w",["队员使用道具，发消息通知队长更新帮助界面",SendSelf2]),
                    common_misc:unicast(Line, LeaderRoleId, ?DEFAULT_UNIQUE, ?EDUCATE_FB, ?EDUCATE_FB_QUERY, SendSelf2)
            end;
       true ->
            ignore
    end.
    

do_educate_fb_item_error({Unique, Module, Method, _DataRecord, _RoleId, PId, _Line},Reason) ->
    SendSelf = #m_educate_fb_item_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["使用副本道具返回",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).                                             
do_t_educate_fb_item(RoleId,DataRecord) ->
    %% 扣除道具
    DeleteItemId = DataRecord#m_educate_fb_item_tos.item_id,
    {ok,UpdateGoodsList,DeleteGoodsList} = 
        mod_bag:decrease_goods_by_typeid(RoleId,[1,2,3,4],DeleteItemId,1),
    {ok,UpdateGoodsList,DeleteGoodsList}.

%% 获取师门同心副本奖励
%% DataRecord 结构为 m_educate_fb_award_tos
do_educate_fb_award({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_educate_fb_award2(RoleId,DataRecord) of
        {error,Reason} ->
            do_educate_fb_award_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason);
        {ok,RoleMapInfo,EducateFbRecord} ->
            do_educate_fb_award3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                 RoleMapInfo,EducateFbRecord)
    end.
do_educate_fb_award2(RoleId,DataRecord) ->
    MapId = DataRecord#m_educate_fb_award_tos.map_id,
    NpcId = DataRecord#m_educate_fb_award_tos.npc_id,
    CurMapId = mgeem_map:get_mapid(),
    if MapId =:= CurMapId ->
            next;
       true ->
            ?DEBUG("~ts",["玩家不在可以退出师门同心副本的地图"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_AWARD_PARAM_ERROR})
    end,
    RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                ?DEBUG("~ts",["在本地图获取不到玩家的地图信息"]),
                erlang:throw({error,?_LANG_EDUCATE_FB_AWARD_PARAM_ERROR});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    MapFactionId = MapId rem 10000 div 1000,
    if RoleMapInfo#p_map_role.faction_id =/= MapFactionId ->
            ?DEBUG("~ts",["不是本国国民不能操作"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_AWARD_NOT_FACTION});
       true ->
            next
    end,
    %% 检查玩家是否在NPC附近
    case check_valid_distance(NpcId,RoleMapInfo) of
        true ->
            next;
        false ->
            ?DEBUG("~ts",["玩家不在NPC附近，无法操作"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_NOT_VALID_DISTANCE})
    end,
    %% 查询是否有已经完成的副本可以领取奖励
    EducateFbRecord = 
        case db:dirty_read(?DB_EDUCATE_FB,RoleId) of
            [] ->
                ?DEBUG("~ts",["玩家没有可以领取的副本"]),
                erlang:throw({error,?_LANG_EDUCATE_FB_AWARD_NOT_AWARD});
            [EducateFbRecordT] ->
                EducateFbRecordT
        end,
    if EducateFbRecord#r_educate_fb.status =:= ?EDUCATE_FB_STATUS_AWARD ->
            ?DEBUG("~ts",["上次的奖励已经领取了"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_AWARD_NOT_AWARD});
       EducateFbRecord#r_educate_fb.status =:= ?EDUCATE_FB_STATUS_COMPLETE ->
            next;
       true ->
            erlang:throw({error,?_LANG_EDUCATE_FB_AWARD_NOT_AWARD})
    end,
    case erlang:is_list( EducateFbRecord#r_educate_fb.award_list) 
        andalso EducateFbRecord#r_educate_fb.award_list =/= [] of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_EDUCATE_FB_AWARD_NOT_AWARD})
    end,
    {ok,RoleMapInfo,EducateFbRecord}.

do_educate_fb_award3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                     RoleMapInfo,EducateFbRecord) ->
    case db:transaction(
           fun() -> 
                   do_t_educate_fb_award(RoleId,EducateFbRecord)
           end) of
        {atomic,{ok,GoodsList}} ->
            do_educate_fb_award4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                 RoleMapInfo,EducateFbRecord,GoodsList);
        {aborted, Reason} ->
            Reason2 = 
                case Reason of
                    {throw,{bag_error,BR}} ->
                        case BR of
                            not_enough_pos ->
                                ?_LANG_EDUCATE_FB_AWARD_BAG_POS;
                            _ ->
                                ?_LANG_EDUCATE_FB_AWARD_PARAM_ERROR
                        end;
                    {throw,{error,R}} ->
                        R;
                    _ ->
                        ?ERROR_MSG("~ts,Reason=~w",["领取师徒副本奖励出错",Reason]),
                        ?_LANG_EDUCATE_FB_AWARD_PARAM_ERROR
                end,
            do_educate_fb_award_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2)
    end.
do_educate_fb_award4({Unique, Module, Method, _DataRecord, RoleId, PId, Line},
                     _RoleMapInfo,EducateFbRecord,GoodsList) ->
    GoodsLogList = 
        lists:foldl(
          fun(GoodsLog,AccGoodsLogList) ->
                  GoodsLogNumber = 
                      case GoodsLog#p_goods.type =:= ?TYPE_EQUIP of
                          true ->
                              1;
                          _ ->
                              case lists:keyfind(GoodsLog#p_goods.typeid,#p_goods.typeid,AccGoodsLogList) of
                                  false ->
                                      lists:foldl(
                                        fun(#p_goods{typeid = GoodsLogTypeId,current_num = GoodsLogNum},AccGoodsLogNumber) ->
                                                if GoodsLog#p_goods.typeid =:= GoodsLogTypeId ->
                                                        GoodsLogNum + AccGoodsLogNumber;
                                                   true ->
                                                        AccGoodsLogNumber
                                                end
                                        end,0,EducateFbRecord#r_educate_fb.award_list);
                                  _ ->
                                      0
                              end
                      end,
                  if GoodsLogNumber > 0 ->
                          catch common_item_logger:log(RoleId,GoodsLog#p_goods{current_num = GoodsLogNumber},?LOG_ITEM_TYPE_ENTER_EDUCATE_FB),
                          [GoodsLog#p_goods{current_num = GoodsLogNumber}|AccGoodsLogList];
                     true ->
                          AccGoodsLogList
                  end
          end,[],GoodsList),
    SendSelf = #m_educate_fb_award_toc{succ = true,award_goods = GoodsLogList},
    ?DEBUG("~ts,SendSelf=~w",["获得师门同心副本奖励返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    if GoodsList =/= [] ->
            Line = common_role_line_map:get_role_line(RoleId),
            common_misc:update_goods_notify({line, Line, RoleId},GoodsList);
       true ->
            next
    end,
    catch do_educate_fb_award_notify(RoleId,EducateFbRecord).
do_educate_fb_award_notify(RoleId,EducateFbRecord) ->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    {BcGoodsList,_Index} = 
        lists:foldl(
          fun(BcType,{AccBcGoodsList,AccIndex}) ->
                  if BcType =:= 1 ->
                          {[lists:nth(AccIndex,EducateFbRecord#r_educate_fb.award_list) | AccBcGoodsList],AccIndex + 1};
                     true ->
                          {AccBcGoodsList,AccIndex + 1}
                  end
          end,{[],1},EducateFbRecord#r_educate_fb.bc_list),
    if BcGoodsList =/= [] ->
            FactionName = 
                if RoleBase#p_role_base.faction_id =:= 1 ->
                        ?_LANG_COLOR_FACTION_1;
                   RoleBase#p_role_base.faction_id =:= 2 ->
                        ?_LANG_COLOR_FACTION_2;
                   true ->
                        ?_LANG_COLOR_FACTION_3
                end,
            BCLeftMessage = common_tool:get_format_lang_resources(?_LANG_EDUCATE_FB_AWARD_SUCC_BC,[FactionName,RoleBase#p_role_base.role_name]),
            catch common_broadcast:bc_send_msg_faction_include_goods(RoleBase#p_role_base.faction_id,
                                                                     [?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_COUNTRY,
                                                                     BCLeftMessage,
                                                                     RoleId,common_tool:to_list(RoleBase#p_role_base.role_name),
                                                                     RoleBase#p_role_base.sex, BcGoodsList),
            ok;
       true ->
            ok
    end.
            
         
do_educate_fb_award_error({Unique, Module, Method, _DataRecord, _RoleId, PId, _Line},Reason) ->
    SendSelf = #m_educate_fb_award_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["获得师门同心副本奖励返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).
%% EducateFbRecord 结构的 r_educate_fb
%% AwardItemRecord 结构的 r_educate_fb_award
do_t_educate_fb_award(RoleId,EducateFbRecord) ->
    {ok,GoodsList} = 
        mod_bag:create_goods_by_p_goods(RoleId,EducateFbRecord#r_educate_fb.award_list),
    %% 创建物品，设置状态
    EducateFbRecord2 =  EducateFbRecord#r_educate_fb{
                          status = ?EDUCATE_FB_STATUS_AWARD,
                          award_time = common_tool:now(),
                          award_list = [],
                          bc_list = []},
    db:write(?DB_EDUCATE_FB,EducateFbRecord2,write),
    {ok,GoodsList}.

%% 查询师门同心副本信息
%% DataRecord 结构为 m_educate_fb_query_tos
do_educate_fb_query({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_educate_fb_query2(RoleId,DataRecord) of
        {error,Reason} ->
            do_educate_fb_query_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason);
        {ok,RoleMapInfo,CurMapId} ->
            do_educate_fb_query3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                 RoleMapInfo,CurMapId)
    end.
do_educate_fb_query2(RoleId,DataRecord) ->
    CurMapId = mgeem_map:get_mapid(),
    FBMapId = get_educate_fb_map_id(),
    RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                ?DEBUG("~ts",["在本地图获取不到玩家的地图信息"]),
                erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_PARAM_ERROR});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    OpType = DataRecord#m_educate_fb_query_tos.op_type,
    if OpType =:= ?EDUCATE_FB_QUERY_TYPE_USE_LEADER_ITEM_INIT
       orelse OpType =:= ?EDUCATE_FB_QUERY_TYPE_USE_LEADER_ITEM ->
            LeaderItemId = DataRecord#m_educate_fb_query_tos.item_id,
            LeaderGoodsId =  DataRecord#m_educate_fb_query_tos.goods_id,
            FBLeaderItemId = get_fb_item_leader(),
            if FBMapId =:= CurMapId 
               andalso FBLeaderItemId =:= LeaderItemId ->
                    next;
               true ->
                    erlang:throw({error,?_LANG_EDUCATE_FB_ITEM_USE_LEADER_ITEM})
            end,
            UseGoodsItem = 
                case mod_bag:check_inbag(RoleId,LeaderGoodsId) of
                    {error,BagError} ->
                        ?DEBUG("~ts,BagError=~w",["背包中没有此物品，不可以使用",BagError]),
                        erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_NOT_GOODS});
                    {ok,UseGoodsItemT} ->
                        UseGoodsItemT
                end,
            NowSeconds = common_tool:now(),
            if NowSeconds >= UseGoodsItem#p_goods.start_time 
               andalso UseGoodsItem#p_goods.end_time >= NowSeconds ->
                    next;
               true ->
                    ?DEBUG("~ts",["此物品已经过期，不可以使用"]),
                    erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_GOODS_EXPIRED})
            end,
            #r_educate_fb_dict{goods=FBGoodsList,
                               leader_role_id = LeaderRoleId}=get_educate_fb_dict(),
            if RoleId =:= LeaderRoleId ->
                    next;
               true ->
                    ?DEBUG("~ts",["不是本次副本的合法队长，不可以使用"]),
                    erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_ONLY_LEADER_USE})
            end,
            case lists:keyfind(LeaderGoodsId,#p_goods.id,FBGoodsList) of
                false ->
                    ?DEBUG("~ts",["此副本道具不是本次副本的物品，不可以使用"]),
                    erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_CUR_GOODS_EXPIRED});
                _ ->
                    next
            end,
            next;
       OpType =:= ?EDUCATE_FB_QUERY_TYPE_NOTICE ->
            ItemId = DataRecord#m_educate_fb_query_tos.item_id,
            UseRoleId = DataRecord#m_educate_fb_query_tos.use_role_id,
            if FBMapId =:= CurMapId ->
                    next;
               true ->
                    erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_NOT_EDUCATE_FB})
            end,
            EducateFbDictRecord = get_educate_fb_dict(),
            #r_educate_fb_dict{goods = GoodsList,
                               leader_role_id = LeaderRoleId,
                               drop_item_role_ids = DropItemRoleIdList} = EducateFbDictRecord,
            if RoleId =:= LeaderRoleId ->
                    next;
               true ->
                    erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_ONLY_LEADER_USE})
            end,
            MonsterIdList = mod_map_monster:get_monster_id_list(),
            if MonsterIdList =/= [] ->
                    erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_MONSTER});
               true ->
                    next
            end,
            %%GoodsList2 = lists:keydelete(get_fb_item_leader(),#p_goods.typeid,GoodsList),
            case lists:keyfind(ItemId,#p_goods.typeid,GoodsList) of
                #p_goods{roleid = UseRoleId,typeid = ItemId} ->
                    next;
                _ ->
                    erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_CUR_GOODS_EXPIRED})
            end,
            FbItemList = get_fb_item_use_list_by_dict(OpType,EducateFbDictRecord),
            CurItemId = 
                lists:foldl(
                  fun(#p_educate_fb_item{item_id = CurItemId,status = ItemStatus},CurItemIdAcc) ->
                          if CurItemIdAcc =:= 0 ->
                                  if ItemStatus =:= 1
                                     orelse ItemStatus =:= 2 ->
                                          CurItemIdAcc;
                                     true ->
                                          CurItemId
                                  end;
                             true ->
                                  CurItemIdAcc
                          end
                  end,0,FbItemList),
            ?DEBUG("~ts,FbItemList=~w,CurItemId=~w",["使用道具顺序为",FbItemList,CurItemId]),
            if ItemId =:= CurItemId ->
                    next;
               true ->
                    erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_NOT_CUR_USE})
            end,
            FbLeaderItemId = get_fb_item_leader(),
            if ItemId =:= FbLeaderItemId ->
                    case lists:member(RoleId,DropItemRoleIdList) of
                        true -> %% 队长已经丢弃队长令牌，无法召唤BOSS
                            erlang:throw({error,?_LANG_EDUCATE_FB_QUERY_CALL_ITEM_ERROR});
                        false ->
                            next
                    end;
               true ->
                    next
            end,
            next;
       true ->
            next
    end,   
    {ok,RoleMapInfo,CurMapId}.
do_educate_fb_query3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                    RoleMapInfo,CurMapId) ->
    OpType = DataRecord#m_educate_fb_query_tos.op_type,
    if  OpType =:= ?EDUCATE_FB_QUERY_TYPE_NOTICE ->
            do_educate_fb_query_for_notice({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                           RoleMapInfo,CurMapId);
        true ->
            FBMapId = get_educate_fb_map_id(),
            if CurMapId =:= FBMapId ->
                    OpType = DataRecord#m_educate_fb_query_tos.op_type,
                    EducateFbDictRecord = get_educate_fb_dict(),
                    SendSelf = get_educate_fb_query_toc_by_dict(RoleId,OpType,EducateFbDictRecord),
                    ?DEBUG("~ts,SendSelf=~w",["查询师门同心副本信息返回结果",SendSelf]),
                    common_misc:unicast2(PId, Unique, Module, Method, SendSelf);
               true ->
                    do_educate_fb_query4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                         RoleMapInfo,CurMapId)
            end
    end.
do_educate_fb_query4({Unique, Module, Method, DataRecord, RoleId, PId, _Line},
                    _RoleMapInfo,_CurMapId) ->
    OpType = DataRecord#m_educate_fb_query_tos.op_type,
    [MaxLuckyCount] = common_config_dyn:find(?EDUCATE_FB_CONFIG,max_fb_lucky_count),
    SendSelf = 
        case db:dirty_read(?DB_EDUCATE_FB,RoleId) of
            [] ->
                #m_educate_fb_query_toc{succ = true, op_type = OpType,times =0,start_time = 0, 
                                        end_time = 0,status = 0, count = 0,
                                        award_goods = [],
                                        fb_award_config = get_educate_fb_award_config(),
                                        max_lucky_count = MaxLuckyCount,
                                        fb_items = []};
            [EducateFbRole] ->
                NowSeconds = common_tool:now(),
                {NowDate,_NowTime} =
                    common_tool:seconds_to_datetime(NowSeconds),
                TodaySeconds = common_tool:datetime_to_seconds({NowDate,{0,0,0}}),
                Times = 
                    if EducateFbRole#r_educate_fb.status =:= ?EDUCATE_FB_STATUS_COMPLETE ->
                            EducateFbRole#r_educate_fb.times;
                       true ->
                            if TodaySeconds > EducateFbRole#r_educate_fb.start_time ->
                                    EducateFbRole#r_educate_fb.times;
                               true ->
                                    0
                            end
                    end,
                %% 处理玩家在3.1.7版本之前完成师徒副本，但没有领取奖励时，需要初始化奖励
                EducateFbRole2 = 
                    case EducateFbRole#r_educate_fb.status =:= ?EDUCATE_FB_STATUS_COMPLETE 
                        andalso (EducateFbRole#r_educate_fb.award_list =:= [] orelse EducateFbRole#r_educate_fb.award_list =:= undefined) of
                        true ->
                            {AwardList,BcList} = 
                                calc_award_p_goods_by_sum_count(RoleId,EducateFbRole#r_educate_fb.count + EducateFbRole#r_educate_fb.lucky_count),
                            EducateFbRole2T = EducateFbRole#r_educate_fb{award_list = AwardList,bc_list = BcList},
                            case db:transaction(
                                   fun() -> 
                                           db:write(?DB_EDUCATE_FB,EducateFbRole2T,write),
                                           {ok}
                                   end) of
                                {atomic,{ok}} ->
                                    ok;
                                {aborted, _} ->
                                    db:dirty_write(?DB_EDUCATE_FB,EducateFbRole2T)
                            end,
                            EducateFbRole2T;
                        _ ->
                            EducateFbRole
                    end,
                #m_educate_fb_query_toc{succ = true,
                                        op_type = OpType,
                                        times = Times,
                                        start_time = EducateFbRole2#r_educate_fb.start_time,
                                        end_time = EducateFbRole2#r_educate_fb.end_time,
                                        status = EducateFbRole2#r_educate_fb.status,
                                        count = EducateFbRole2#r_educate_fb.count,
                                        lucky_count = EducateFbRole2#r_educate_fb.lucky_count,
                                        award_goods = EducateFbRole2#r_educate_fb.award_list,
                                        fb_award_config = get_educate_fb_award_config(),
                                        fb_items = [],
                                        all_fb_items = [],
                                        max_lucky_count = MaxLuckyCount
                                       }
        end,
    ?DEBUG("~ts,SendSelf=~w",["查询师门同心副本信息返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

do_educate_fb_query_for_notice({Unique, Module, Method, DataRecord, _RoleId, PId, _Line},
                                           _RoleMapInfo,CurMapId) ->
    OpType = DataRecord#m_educate_fb_query_tos.op_type,
    ItemId = DataRecord#m_educate_fb_query_tos.item_id,
    UseRoleId = DataRecord#m_educate_fb_query_tos.use_role_id,
    EducateFbDictRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{item_use_pos = ItemUsePosList,
                       leader_role_id = LeaderRoleId,
                       monster_level = MonsterLevel,
                       fb_map_name = FbMapProcessName,
                       used_item_role_ids = UsedItemRoleIdList,
                       parent_map_role = ParentMapRoleList} = EducateFbDictRecord,
    #p_map_role{role_name = CurUseRoleName} = 
        lists:keyfind(UseRoleId,#p_map_role.role_id,ParentMapRoleList),
    #r_educate_fb_item_use_pos{tx = Tx,ty = Ty,max_tx = MaxTx,max_ty = MaxTy} = 
        lists:keyfind(ItemId,#r_educate_fb_item_use_pos.item_id,ItemUsePosList),
    {CurMapRoleList,CurRoleIdList} = 
        lists:foldl(
          fun(#p_map_role{role_id = VRoleId},{AccCurMapRoleList,AccCurRoleIdList}) ->
                  case mod_map_actor:get_actor_mapinfo(VRoleId,role) of
                      undefined ->
                          {AccCurMapRoleList,AccCurRoleIdList};
                      CurMapRoleInfo ->
                          #p_map_role{pos = #p_pos{tx = CurTx,ty = CurTy}} = CurMapRoleInfo,
                          TxDiff = erlang:abs(CurTx - Tx),
                          TyDiff = erlang:abs(CurTy - Ty),
                          if  TxDiff < MaxTx  andalso TyDiff < MaxTy ->
                                  {AccCurMapRoleList,[VRoleId|AccCurRoleIdList]};
                              true ->
                                  {[CurMapRoleInfo|AccCurMapRoleList],[VRoleId|AccCurRoleIdList]}
                          end
                  end
          end,{[],[]},ParentMapRoleList),
    MemberMapRoleList = lists:keydelete(LeaderRoleId,#p_map_role.role_id,CurMapRoleList),
    AllRoleNameList = [lists:append(["[",common_tool:to_list(CurRoleName),"]"])
                       ||#p_map_role{role_name = CurRoleName} <- MemberMapRoleList],
    if CurMapRoleList =:= [] andalso UseRoleId =:= LeaderRoleId ->
            %% 当前是队长召唤boss操作，并广播
            MonsterIdList = mod_map_monster:get_monster_id_list(),
            if MonsterIdList =/= [] -> %% 地图上的其它怪物还没有被杀死
                    LeaderMessage = ?_LANG_EDUCATE_FB_QUERY_CALL_BOSS_ERROR;
               true ->
                    {BossMonsterType,BossMonsterList} = get_fb_boss_p_monster(MonsterLevel),
                    put_educate_fb_dict(EducateFbDictRecord#r_educate_fb_dict{used_item_role_ids = [UseRoleId|UsedItemRoleIdList]}),
                    mod_map_monster:init_educate_fb_map_monster(FbMapProcessName, CurMapId, BossMonsterList, BossMonsterType),
                    LeaderMessage = ?_LANG_EDUCATE_FB_QUERY_CALL_BOSS_SUCC,
                    lists:foreach(
                      fun(CurRoleId) ->
                              common_broadcast:bc_send_msg_role(CurRoleId,
                                                                [?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_SYSTEM], 
                                                                ?BC_MSG_SUB_TYPE, ?_LANG_EDUCATE_FB_QUERY_CALL_BOSS_SUCC_BC)
                      end,CurRoleIdList),
                    %% 使用道具不需要过滤此用户
                    catch do_educate_fb_item_bc_leader(LeaderRoleId,0)
            end;
       CurMapRoleList =:= [] ->
            %% 所有人已经到达此道具使用区域
            UseSendMember = #m_educate_fb_query_toc{
              succ = true,
              op_type = ?EDUCATE_FB_QUERY_TYPE_NOTICE_USE,
              item_id = ItemId, use_role_id = UseRoleId, 
              use_role_name = CurUseRoleName,
              use_tx = Tx,use_ty = Ty,return_self = false,
              all_fb_items = get_all_fb_item_use_list_by_dict(EducateFbDictRecord),
              leader_role_id = LeaderRoleId},
            case mod_map_actor:get_actor_mapinfo(UseRoleId,role) of
                undefined ->
                    LeaderMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_QUERY_WAIT_USE_OFFLINE,[common_tool:to_list(CurUseRoleName)]));
                _ ->
                    LeaderMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_QUERY_WAIT_USE,[common_tool:to_list(CurUseRoleName)])),
                    UseLine = common_role_line_map:get_role_line(UseRoleId),
                    common_misc:unicast(UseLine, UseRoleId,?DEFAULT_UNIQUE, Module, Method, UseSendMember)
            end;
       true ->
            %% 还需等待某人到达道具使用区域
            if MemberMapRoleList =/= [] ->
                    LeaderMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_QUERY_WAIT_FOCUS,[common_tool:to_list(AllRoleNameList)])),
                    SendMember = #m_educate_fb_query_toc{
                      succ = true,
                      op_type = ?EDUCATE_FB_QUERY_TYPE_NOTICE,
                      item_id = ItemId,use_role_id = UseRoleId, 
                      use_role_name = CurUseRoleName,
                      use_tx = Tx,use_ty = Ty,return_self = false,
                      all_fb_items = get_all_fb_item_use_list_by_dict(EducateFbDictRecord),
                      leader_role_id = LeaderRoleId},
                    lists:foreach(
                      fun(#p_map_role{role_id = CurRoleId}) ->
                              CurLine = common_role_line_map:get_role_line(CurRoleId),
                              common_misc:unicast(CurLine, CurRoleId,?DEFAULT_UNIQUE, Module, Method, SendMember)
                      end,MemberMapRoleList);
               true ->
                    LeaderMessage = ?_LANG_EDUCATE_FB_QUERY_WAIT_FOCUS_LEADER
            end
    end,
    OpType = DataRecord#m_educate_fb_query_tos.op_type,
    SendSelf = #m_educate_fb_query_toc{
      succ = true,op_type = OpType,reason = LeaderMessage,leader_role_id = LeaderRoleId},
    ?DEBUG("~ts,SendSelf=~w",["查询师门同心副本信息返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

do_educate_fb_query_error({Unique, Module, Method, DataRecord, _RoleId, PId, _Line},Reason) ->
    OpType = DataRecord#m_educate_fb_query_tos.op_type,
    LeaderRoleId = 
        case get_educate_fb_dict() of
            undefined ->
                0;
            #r_educate_fb_dict{leader_role_id = LeaderRoleIdT} ->
                LeaderRoleIdT
        end,
    SendSelf = #m_educate_fb_query_toc{succ = false,op_type = OpType,
                                       reason = Reason,leader_role_id = LeaderRoleId},
    ?DEBUG("~ts,SendSelf=~w",["查询师门同心副本信息返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).


get_educate_fb_query_toc_by_dict(RoleId,OpType,EducateFbDictRecord) ->
    #r_educate_fb_dict{educate_fb_role = EducateFbRoleList,
                      leader_role_id = LeaderRoleId} = EducateFbDictRecord,
    FbItemsList = get_fb_item_use_list_by_dict(OpType,EducateFbDictRecord),
    EducateFbRole = lists:keyfind(RoleId,#r_educate_fb.role_id,EducateFbRoleList),
    #m_educate_fb_query_toc{
                             succ = true,
                             op_type = OpType,
                             times = EducateFbRole#r_educate_fb.times,
                             start_time = EducateFbRole#r_educate_fb.start_time,
                             end_time = EducateFbRole#r_educate_fb.end_time,
                             status = EducateFbRole#r_educate_fb.status,
                             count = EducateFbRole#r_educate_fb.count,
                             lucky_count = EducateFbRole#r_educate_fb.lucky_count,
                             award_goods = EducateFbRole#r_educate_fb.award_list,
                             fb_award_config = get_educate_fb_award_config(),
                             fb_items = FbItemsList,
                             all_fb_items = get_all_fb_item_use_list_by_dict(EducateFbDictRecord),
                             leader_role_id = LeaderRoleId
                           }.
%% 返回所有副本道具信息
%% 返回 [] or [p_educate_fb_item ...]
get_all_fb_item_use_list_by_dict(EducateFbDictRecord) ->
    #r_educate_fb_dict{item_use_pos = ItemUsePosList} = EducateFbDictRecord,
    LeaderItemId = get_fb_item_leader(),
    AllFbItemList = 
        lists:foldl(
          fun(#r_educate_fb_item_use_pos{item_id = ItemId,tx = Tx,ty = Ty},Acc) ->
                  if LeaderItemId =:= ItemId ->
                          Acc;
                     true ->
                          PEducateFbItem = #p_educate_fb_item{ 
                            item_id = ItemId,
                            use_tx = Tx,
                            use_ty = Ty,
                            role_id = 0,
                            role_name = "",
                            status = 0
                           },
                          [PEducateFbItem|Acc]
                  end
          end,[],ItemUsePosList),
    %% 排序
    lists:sort(
      fun(#p_educate_fb_item{item_id = AItemId},#p_educate_fb_item{item_id = BItemId}) ->
              AItemId < BItemId 
      end,AllFbItemList).
%% 根据进程字典的数据，获取当前副本道具使用顺序列表
%% 返回 [] or [p_educate_fb_item ...]
get_fb_item_use_list_by_dict(OpType,EducateFbDictRecord) ->
    #r_educate_fb_dict{item_use_pos = ItemUsePosList,
                       parent_map_role = ParentMapRoleList,
                       used_item_role_ids = UsedItemRoleIdList,
                       fb_offline_roles = FbOfflineRoleList,
                       drop_item_role_ids = DropItemRoleIdList,
                       goods = GoodsList} = EducateFbDictRecord,
    FbItemList = 
        lists:foldl(
          fun(#p_goods{roleid = VRoleId,typeid = ItemId},AccFbItemsList) ->
                  InMapFlag = 
                      case mod_map_actor:get_actor_mapinfo(VRoleId,role) of
                          undefined ->
                              false;
                          _ ->
                              true
                      end,
                  InTeamFlag = 
                      case lists:keyfind(VRoleId,1,FbOfflineRoleList) of
                          false ->
                              false;
                          _ ->
                              true
                      end,
                  %% 下线并离队
                  ?DEBUG("~ts,InMapFlag=~w,InTeamFlag=~w",["判断是否玩家还在副本中",InMapFlag,InTeamFlag]),
                  if (OpType =:= ?EDUCATE_FB_QUERY_TYPE_USE_LEADER_ITEM 
                      orelse OpType =:= ?EDUCATE_FB_QUERY_TYPE_NOTICE
                      orelse OpType =:= ?EDUCATE_FB_QUERY_TYPE_NOTICE_USE)
                     andalso InMapFlag =:= false andalso InTeamFlag =:= false ->
                          AccFbItemsList;
                     true ->
                          VMapRoleInfo = lists:keyfind(VRoleId,#p_map_role.role_id,ParentMapRoleList),
                          ItemStatus = 
                              case lists:member(VRoleId,UsedItemRoleIdList) of
                                  true ->
                                      1;
                                  false ->
                                      0
                              end,
                          ItemStatus2 = 
                              case lists:member(VRoleId,DropItemRoleIdList) of
                                  true ->
                                      2;
                                  false ->
                                      ItemStatus
                              end,
                          ItemUsePos = lists:keyfind(ItemId,#r_educate_fb_item_use_pos.item_id,ItemUsePosList),
                          PEducateFbItem = #p_educate_fb_item{ 
                            item_id = ItemId,
                            use_tx = ItemUsePos#r_educate_fb_item_use_pos.tx,
                            use_ty = ItemUsePos#r_educate_fb_item_use_pos.ty,
                            role_id = VRoleId,
                            role_name = VMapRoleInfo#p_map_role.role_name,
                            status = ItemStatus2
                           },
                          [PEducateFbItem|AccFbItemsList]
                  end
          end,[],GoodsList),
    %% 排序
    lists:sort(
      fun(#p_educate_fb_item{item_id = AItemId},#p_educate_fb_item{item_id = BItemId}) ->
              AItemId < BItemId 
      end,FbItemList).
%% 刷新幸运积分
%% DataRecord 结构为 m_educate_fb_gambling_tos
do_educate_fb_gambling({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_educate_fb_gambling2(RoleId,DataRecord) of
        {error,Reason} ->
            do_educate_fb_gambling_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason);
        {ok,RoleMapInfo,EducateFbRecord,IsSumCountType} ->
            do_educate_fb_gambling3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                    RoleMapInfo,EducateFbRecord,IsSumCountType)
    end.
do_educate_fb_gambling2(RoleId,DataRecord) ->
    MapId = DataRecord#m_educate_fb_gambling_tos.map_id,
    NpcId = DataRecord#m_educate_fb_gambling_tos.npc_id,
    CurMapId = mgeem_map:get_mapid(),
    if MapId =:= CurMapId ->
            next;
       true ->
            ?DEBUG("~ts",["玩家不在本地图操作"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_GAMBLING_PARAM_ERROR})
    end,
    RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                ?DEBUG("~ts",["在本地图获取不到玩家的地图信息"]),
                erlang:throw({error,?_LANG_EDUCATE_FB_GAMBLING_PARAM_ERROR});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    MapFactionId = MapId rem 10000 div 1000,
    if RoleMapInfo#p_map_role.faction_id =/= MapFactionId ->
            ?DEBUG("~ts",["不是本国国民不能操作"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_GAMBLING_NOT_FACTION});
       true ->
            next
    end,
    %% 检查玩家是否在NPC附近
    case check_valid_distance(NpcId,RoleMapInfo) of
        true ->
            next;
        false ->
            ?DEBUG("~ts",["玩家不在NPC附近，无法操作"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_NOT_VALID_DISTANCE})
    end,
    %% 查询是否有已经完成的副本可以领取奖励
    EducateFbRecord = 
        case db:dirty_read(?DB_EDUCATE_FB,RoleId) of
            [] ->
                ?DEBUG("~ts",["玩家没有可以领取的副本"]),
                erlang:throw({error,?_LANG_EDUCATE_FB_GAMBLING_NOT_AWARD});
            [EducateFbRecordT] ->
                EducateFbRecordT
        end,
    if EducateFbRecord#r_educate_fb.status =:= ?EDUCATE_FB_STATUS_AWARD ->
            ?DEBUG("~ts",["上次的奖励已经领取了"]),
            erlang:throw({error,?_LANG_EDUCATE_FB_GAMBLING_NOT_AWARD});
       EducateFbRecord#r_educate_fb.status =:= ?EDUCATE_FB_STATUS_COMPLETE ->
            next;
       true ->
            erlang:throw({error,?_LANG_EDUCATE_FB_GAMBLING_NOT_AWARD})
    end,
    FbLuckyCount = EducateFbRecord#r_educate_fb.lucky_count,
    FbSumCount = FbLuckyCount + EducateFbRecord#r_educate_fb.count,
    [MaxFbLuckyCount] = common_config_dyn:find(?EDUCATE_FB_CONFIG,max_fb_lucky_count),
    [MaxFbSumCount] = common_config_dyn:find(?EDUCATE_FB_CONFIG,max_fb_sum_count),
    [FbAwardList] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_award),
    RoleGetMaxCount = MaxFbLuckyCount + EducateFbRecord#r_educate_fb.count,
    RoleGetMaxAwardCount = 
        lists:foldl(
          fun(#r_educate_fb_award{min_count = MinCount,max_count = MaxCount},AccCount) ->
                  if AccCount =/= 0 ->
                          AccCount;
                     true ->
                          if RoleGetMaxCount >= MinCount
                             andalso MaxCount >= RoleGetMaxCount ->
                                  MinCount;
                             true ->
                                  AccCount
                          end
                  end
          end,0,FbAwardList),
    IsSumCountType = %% 0不需要再刷积分 1还可以刷积分
        if FbSumCount >= RoleGetMaxAwardCount->
                0;
           FbLuckyCount >= MaxFbLuckyCount ->
                0;
           FbSumCount >= MaxFbSumCount ->
                0;
           true ->
                1
        end,
    {ok,RoleMapInfo,EducateFbRecord,IsSumCountType}.

do_educate_fb_gambling3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                        RoleMapInfo,EducateFbRecord,IsSumCountType) ->
    [Fee] = common_config_dyn:find(?EDUCATE_FB_CONFIG,refresh_lucky_count_fee),
    case db:transaction(
           fun() -> 
                   do_t_educate_fb_gambling(RoleId,EducateFbRecord,IsSumCountType,Fee)
           end) of
        {atomic,{ok,EducateFbRecord2,RoleAttr}} ->
            do_educate_fb_gambling4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                    RoleMapInfo,EducateFbRecord2,RoleAttr,Fee);
        {aborted, Reason} ->
            Reason2 = 
                case Reason of
                    {throw,{error,R}} ->
                        R;
                    _ ->
                        ?ERROR_MSG("~ts,Reason=~w",["刷新幸运积分出错",Reason]),
                        ?_LANG_EDUCATE_FB_GAMBLING_PARAM_ERROR
                end,
            do_educate_fb_gambling_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2)
    end.

do_educate_fb_gambling4({Unique, Module, Method, _DataRecord, RoleId, PId, _Line},
                        _RoleMapInfo,EducateFbRecord,RoleAttr,Fee) ->
    #r_educate_fb{lucky_count = LuckyCount} = EducateFbRecord,
    SendSelf = #m_educate_fb_gambling_toc{succ = true,lucky_count = LuckyCount,fee = Fee,
                                          award_goods = EducateFbRecord#r_educate_fb.award_list},
    ?DEBUG("~ts,SendSelf=~w",["刷新幸运积分返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    UnicastArg = {role, RoleId},
    AttrChangeList = [#p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value = RoleAttr#p_role_attr.gold},
                      #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value = RoleAttr#p_role_attr.gold_bind}],
    common_misc:role_attr_change_notify(UnicastArg,RoleId,AttrChangeList).

do_educate_fb_gambling_error({Unique, Module, Method, _DataRecord, _RoleId, PId, _Line},Reason) ->
    SendSelf = #m_educate_fb_gambling_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["刷新幸运积分返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

do_t_educate_fb_gambling(RoleId,EducateFbRecord,IsSumCountType,Fee) ->
    #r_educate_fb{income_item_count = IncomeItemCount,count = FbCount} = EducateFbRecord,
    case IsSumCountType =:= 0 of
        true ->
            NewLuckyCount = EducateFbRecord#r_educate_fb.lucky_count;
        _ ->
            NewLuckyCount = calc_lucky_count(IncomeItemCount)
    end,
    %% 重算物品
    {AwardList,BcList} = calc_award_p_goods_by_sum_count(RoleId,FbCount + NewLuckyCount),
    EducateFbRecord2 = EducateFbRecord#r_educate_fb{
                         lucky_count = NewLuckyCount,
                         income_item_count = IncomeItemCount + 1,
                         award_list = AwardList,
                         bc_list = BcList},
    LogGamblingStr = common_tool:to_list(FbCount + NewLuckyCount),
    db:write(?DB_EDUCATE_FB,EducateFbRecord2,write),
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleId),
    #p_role_attr{gold = Gold,gold_bind = GoldBind} = RoleAttr,
    NewRoleAttr = 
        if GoldBind < Fee ->
                NewGold = Gold - (Fee - GoldBind),
                if NewGold < 0 ->
                        erlang:throw({error,?_LANG_EDUCATE_FB_GAMBLING_NOT_GOLD});
                   true ->
                        RoleAttr2 = RoleAttr#p_role_attr{gold= NewGold,gold_bind=0 },
                        mod_map_role:set_role_attr(RoleId,RoleAttr2),
                        common_consume_logger:use_gold({RoleId, GoldBind, (Fee - GoldBind), ?CONSUME_TYPE_GOLD_EDUCATE_FB_LUCKY_COUNT, LogGamblingStr}),
                        RoleAttr2
                end;
           true ->
                NewGoldBind = GoldBind - Fee,
                RoleAttr2 = RoleAttr#p_role_attr{gold_bind=NewGoldBind},
                mod_map_role:set_role_attr(RoleId, RoleAttr2),
                common_consume_logger:use_gold({RoleId, Fee, 0, ?CONSUME_TYPE_GOLD_EDUCATE_FB_LUCKY_COUNT, LogGamblingStr}),
                RoleAttr2
        end,
    {ok,EducateFbRecord2,NewRoleAttr}.
%% 重算刷新积分获得的物品
%% 返回 {AwardGoodsList,BcList} or {[],[]}
calc_award_p_goods_by_sum_count(RoleId,SumCount) ->
    [FbAwardList] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_award),
    AwardNumber = 
        lists:foldl(
          fun(FbAwardRecord,AccAwardNumber) ->
                  if AccAwardNumber =/= 0 ->
                          AccAwardNumber;
                     true ->
                          case SumCount  >= FbAwardRecord#r_educate_fb_award.min_count
                              andalso FbAwardRecord#r_educate_fb_award.max_count >= SumCount of
                              true->
                                  FbAwardRecord#r_educate_fb_award.award_number;
                              _ ->
                                  AccAwardNumber 
                          end
                  end
          end,0,FbAwardList),
    if AwardNumber > 0 ->
            calc_award_p_goods_by_sum_count2(RoleId,SumCount,AwardNumber);
       true ->
            {[],[]}
    end.
calc_award_p_goods_by_sum_count2(RoleId,_SumCount,AwardNumber) ->
    lists:foldl(
      fun(Index,{AccGoodsList,AccBcList}) ->
              [FbAwardIndexList] = common_config_dyn:find(?EDUCATE_FB_CONFIG,{fb_award,Index}),
              WeightList = [FbAwardIndexRecordT#r_educate_fb_sub_award.weight || FbAwardIndexRecordT <- FbAwardIndexList],
              case mod_refining:get_random_number(WeightList,0,0) of
                  0 ->
                      {AccGoodsList,AccBcList};
                  ItemIndex ->
                      FbAwardIndexRecord = lists:nth(ItemIndex,FbAwardIndexList),
                      {ok,GoodsList} = 
                          mod_refining_tool:get_p_goods_by_special(RoleId,FbAwardIndexRecord#r_educate_fb_sub_award.goods_create_special),
                      {lists:append([AccGoodsList,[Goods#p_goods{id = 99999999,
                                                                 roleid =RoleId, 
                                                                 bagid = 0,
                                                                 bagposition = 0 }||Goods <- GoodsList]]),
                       lists:append([AccBcList,[FbAwardIndexRecord#r_educate_fb_sub_award.bc_type]])}
              end
      end,{[],[]},lists:seq(1,AwardNumber,1)).
    
%% 副本初始化相关信息如下
%% global:send(FbMapProcessName, {mod_educate_fb,{enter_educate_info,EducateFbRecord}}),
%% EducateFbRecord 结构为 r_educate_fb_dict
do_enter_educate_info(EducateFbRecord) ->
    put_educate_fb_dict(EducateFbRecord),
    ok.
               
%% 怪物死亡
do_monster_dead(MonsterType) ->
    RoleIdList =  mod_map_actor:get_in_map_role(),
    EducateFbRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{fb_count = FBCount,
                       educate_fb_role = EducateFbRoleList} = EducateFbRecord,
    [{_RoleGainCount,MonsterGainCount,EliteMonsterGainCount,BossMonsterGainCount}] = 
        common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_gain_count_unit),
    AddCount = 
        case MonsterType of
            1 ->
                MonsterGainCount;
            2 ->
                EliteMonsterGainCount;
            3 ->
                BossMonsterGainCount;
            _ ->
                MonsterGainCount
        end,
    NewCount = FBCount + AddCount,
    EducateFbRecord2 = EducateFbRecord#r_educate_fb_dict{fb_count = NewCount},
    
    do_broadcast_count_for_monster_dead(RoleIdList,NewCount),
    case check_educate_fb_complete(RoleIdList,EducateFbRecord2) of
        true ->
            %% 副本完成，记录日志，广播,踢人出副本
            EndTime = common_tool:now(),
            lists:foreach(
              fun(RoleId) ->
                      EducateFbRole = lists:keyfind(RoleId,#r_educate_fb.role_id,EducateFbRoleList),
                      NewCount2 = if NewCount < 0 -> 0; true-> NewCount end,
                      {AwardList,BcList} = calc_award_p_goods_by_sum_count(RoleId,NewCount2 + EducateFbRole#r_educate_fb.lucky_count),
                      db:dirty_write(?DB_EDUCATE_FB,EducateFbRole#r_educate_fb{
                                                      status = ?EDUCATE_FB_STATUS_COMPLETE,
                                                      end_time =EndTime,
                                                      award_list = AwardList,
                                                      bc_list = BcList,
                                                      count=NewCount2})
              end,RoleIdList),
            put_educate_fb_dict(EducateFbRecord2),
            do_educate_fb_close_log(RoleIdList,EndTime,1),
            EducateFbRecord3 = EducateFbRecord2#r_educate_fb_dict{fb_status = 1},
            put_educate_fb_dict(EducateFbRecord3),
            %% 成就 add by caochuncheng 2011-03-04 
            common_hook_achievement:hook({mod_fb,{educate_fb_complete,RoleIdList,NewCount}}),
            lists:foreach(fun(RoleId)-> 
                                  hook_activity_task:done_task(RoleId,?ACTIVITY_TASK_EDUCATE_FB)
                          end,RoleIdList),
            catch do_educate_fb_complete_bc(EducateFbRecord3),
            
            MaxInterval = 30,
            erlang:send_after(5 * 1000,self(),{mod_educate_fb,{educate_fb_close_and_bc, MaxInterval}});
        false ->
            put_educate_fb_dict(EducateFbRecord2)
    end.
%% 判断是否副本完成
check_educate_fb_complete(RoleIdList,EducateFbRecord) ->
    MonsterIdList = mod_map_monster:get_monster_id_list(),
    if MonsterIdList =/= [] ->
            false;
       true ->
            check_educate_fb_complete2(RoleIdList,EducateFbRecord)
    end.
check_educate_fb_complete2(RoleIdList,EducateFbRecord) ->
    #r_educate_fb_dict{used_item_role_ids = UsedItemRoleIdList,
                       drop_item_role_ids = DropItemRoleIdList
                      } = EducateFbRecord,
    %%RoleIdList2 = lists:delete(LeaderRoleId,RoleIdList),
    %%leader_role_id = LeaderRoleId,
    lists:foldl(
      fun(RoleId,Acc) ->
              IsUsedItemFlag = lists:member(RoleId,UsedItemRoleIdList),
              IsDropItemFlag = lists:member(RoleId,DropItemRoleIdList),
              if IsUsedItemFlag =:= true orelse IsDropItemFlag =:= true ->
                      Acc;
                 true ->
                      false
              end
      end,true,RoleIdList).

do_educate_fb_complete_bc(EducateFbRecord) ->
    #r_educate_fb_dict{faction_id = FactionId,
                       parent_map_role = ParentMapRoleList,
                       leader_role_id = LeaderRoleId,
                       leader_role_name = LeaderRoleName,
                       used_item_role_ids = UsedItemRoleIdList
                      } = EducateFbRecord,
    MemberRoleIdList = [RoleId 
                        || #p_map_role{role_id = RoleId} <- ParentMapRoleList,
                           LeaderRoleId =/= RoleId],
    case lists:foldl(
           fun(MemberRoleId,AccFlag) ->
                   case lists:member(MemberRoleId,UsedItemRoleIdList) of 
                       true ->
                           AccFlag;
                       false ->
                           false
                   end
           end,true,MemberRoleIdList) of
        true -> %% 消息广播
            FactionMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_BROADCAST_COMPLETE_FB,[common_tool:to_list(LeaderRoleName)])),
            catch common_broadcast:bc_send_msg_faction(FactionId,?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_COUNTRY,FactionMessage);
        false ->
            ignore
    end.
    
    
do_broadcast_count_for_monster_dead(RoleIdList,NewCount) ->
    ?DEBUG("~ts,NewCount=~w",["副本积分为",NewCount]),
    CountMessage = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_BROADCAST_COUNT_CHANGE,[common_tool:to_list(NewCount)])),
    catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,CountMessage).

do_role_dead(RoleId,MapRoleInfo) ->
    RoleIdList =  mod_map_actor:get_in_map_role(),
    EducateFbRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{fb_count = FBCount,
                       fb_role_dead_times=FbRoleDeadTimes,
                       fb_dead_roles=FbDeadRoleList} = EducateFbRecord,
    {RoleId,RoleDeadTimes} = lists:keyfind(RoleId,1,FbDeadRoleList),
    FbDeadRoleList2 = lists:keydelete(RoleId,1,FbDeadRoleList),
    [{RoleGainCount,_MonsterGainCount,_EliteMonsterGainCount,_BossMonsterGainCount}] = 
        common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_gain_count_unit),
    NewCount = FBCount + RoleGainCount,
    EducateFbRecord2 = EducateFbRecord#r_educate_fb_dict{
                         fb_count = NewCount,
                         fb_role_dead_times = FbRoleDeadTimes + 1,
                         fb_dead_roles =[{RoleId,RoleDeadTimes + 1}|FbDeadRoleList2] 
                        },
    put_educate_fb_dict(EducateFbRecord2),
    CountMessage = lists:flatten(io_lib:format(
                                   ?_LANG_EDUCATE_FB_BROADCAST_COUNT_CHANGE_ROLE_DEAD,
                                   [common_tool:to_list(NewCount),
                                    common_tool:to_list(MapRoleInfo#p_map_role.role_name),
                                    common_tool:to_list(erlang:abs(RoleGainCount))])),
    catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,CountMessage).
    

do_educate_fb_close_and_bc(MaxInterval) ->
    if MaxInterval =:= 0 ->
            do_educate_fb_close();
       true ->
            Message = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_BROADCAST_CLOSE_FB,[common_tool:to_list(MaxInterval)])),
            RoleIdList = mod_map_actor:get_in_map_role(),
            catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,Message),
            if MaxInterval - 5 >= 5 ->
                    erlang:send_after(5000,self(),{mod_educate_fb,{educate_fb_close_and_bc,MaxInterval - 5}});
               true ->
                    erlang:send_after(MaxInterval * 1000,self(),{mod_educate_fb,{educate_fb_close_and_bc, 0}})
            end
    end.
%% 副本关闭消息处理
do_educate_fb_close() ->
    RoleIdList = mod_map_actor:get_in_map_role(),
    if erlang:length(RoleIdList) > 0 ->
            do_educate_fb_close2(RoleIdList);
       true ->
            %% 发送消息关闭地图
            self() ! {mod_educate_fb,{kill_educate_fb_map}}
    end.
do_educate_fb_close2(RoleIdList) ->
    EducateFbRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{parent_map_id = ParentMapId,
                       parent_map_role = ParentMapRoleList} = EducateFbRecord,
    NowSeconds = common_tool:now(),
    %% 销毁副本道具
    do_educate_fb_close_delete_fb_item(RoleIdList,NowSeconds,EducateFbRecord),
    do_educate_fb_close_log(RoleIdList,NowSeconds,1),
    lists:foreach(
      fun(RoleId) ->
              {DMapId,DTx,DTy} = 
                  case lists:keyfind(RoleId,#p_map_role.role_id,ParentMapRoleList) of
                      false ->
                          get_home_born_info(RoleId);
                      #p_map_role{pos = #p_pos{tx = TxT,ty = TyT}} ->
                          {ParentMapId,TxT,TyT}
                  end,
              mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleId, DMapId, DTx, DTy)
      end,RoleIdList),
    ok.
%% 销毁副本道具
do_educate_fb_close_delete_fb_item(RoleIdList,NowSeconds,EducateFbRecord) ->
    #r_educate_fb_dict{used_item_role_ids = UsedItemRoleIdList,
                       drop_item_role_ids = DropItemRoleIdList,
                       leader_role_id = LeaderRoleId} = EducateFbRecord,
    ?DEBUG("~ts,UsedItemRoleIdList=~w",["已经使用过道具的玩家",UsedItemRoleIdList]),
    RoleIdList2 = 
        lists:foldl(
          fun(RoleId,Acc) ->
                  IsDropItemFlag = lists:member(RoleId,DropItemRoleIdList),
                  IsUseItemFlag = lists:member(RoleId,UsedItemRoleIdList),
                  if LeaderRoleId =:= RoleId andalso IsDropItemFlag =:= false ->
                          [RoleId | Acc];
                     true ->
                          if IsDropItemFlag =:= false andalso
                             IsUseItemFlag =:= false ->
                                  [RoleId | Acc];
                             true ->
                                  Acc
                          end
                  end
          end,[],RoleIdList),
    if RoleIdList2 =:= [] ->
            ignore;
       true ->
            do_educate_fb_close_delete_fb_item2(RoleIdList2,NowSeconds,EducateFbRecord)
    end.
do_educate_fb_close_delete_fb_item2(RoleIdList,NowSeconds,EducateFbRecord) ->
    #r_educate_fb_dict{goods = GoodsList,
                       educate_fb_role = EducateFbRoleList,
                       fb_count = FbCount} = EducateFbRecord,
    lists:foreach(
      fun(RoleId) ->
              Goods = lists:keyfind(RoleId,#p_goods.roleid,GoodsList),
              DeleteItemId = Goods#p_goods.typeid,
              case db:transaction(
                     fun() -> 
                             {ok,UpdateGoodsList,DeleteGoodsList} = 
                                 mod_bag:decrease_goods_by_typeid(RoleId,[1,2,3,4,5],DeleteItemId,1),
                             %% 记录日志，判断是否完成副本
                             EducateFbRole = lists:keyfind(RoleId,#r_educate_fb.role_id,EducateFbRoleList),
                             FbCount2 = if FbCount < 0 -> 0; true -> FbCount end,
                             {AwardList,BcList} = calc_award_p_goods_by_sum_count(RoleId,FbCount2 + EducateFbRole#r_educate_fb.lucky_count),
                             EducateFbRole2 = EducateFbRole#r_educate_fb{
                                                end_time = NowSeconds,
                                                status = ?EDUCATE_FB_STATUS_COMPLETE,
                                                award_list = AwardList,
                                                bc_list = BcList,
                                                count = FbCount2},
                             db:write(?DB_EDUCATE_FB,EducateFbRole2,write),
                             {ok,UpdateGoodsList,DeleteGoodsList}
                     end) of
                  {atomic,{ok,UpdateGoodsList,DeleteGoodsList}} ->
                      Line = common_role_line_map:get_role_line(RoleId),
                      UnicastArg = {line, Line, RoleId},
                      if UpdateGoodsList =/= [] ->
                              common_misc:update_goods_notify(UnicastArg,UpdateGoodsList);
                         true ->
                              next
                      end,
                      if DeleteGoodsList =/= [] ->
                              common_misc:del_goods_notify(UnicastArg, DeleteGoodsList);
                         true ->
                              next
                      end,
                      if DeleteItemId =/= 0 ->
                              common_item_logger:log(RoleId, DeleteItemId,1,undefined,?LOG_ITEM_TYPE_QUIT_EDUCATE_FB);
                         true ->
                              next
                      end;
                  {aborted, Reason} ->
                      ?ERROR_MSG("~ts,Reason=~w",["玩家被系统踢出师门同心副本时删除副本道具出错",Reason])
              end
      end,RoleIdList).
hook_role_drop_goods(RoleId,GoodsInfo)->
    MapId = mgeem_map:get_mapid(),
    FBMapId = get_educate_fb_map_id(),
    if MapId =:= FBMapId ->
            hook_role_drop_goods2(RoleId,GoodsInfo);
       true ->
            ignore
    end.
hook_role_drop_goods2(RoleId,GoodsInfo) ->
    case get_educate_fb_dict() of
        undefined ->
            ignore;
        EducateFbDictRecord ->
            #r_educate_fb_dict{leader_role_id = LeaderRoleId,
                               parent_map_role = ParentMapRoleList,
                               educate_fb_role = EducateFbRoleList,
                               drop_item_role_ids = DropItemRoleIdList,
                               fb_count = FbCount,
                               goods = GoodsList} = EducateFbDictRecord,
            #p_goods{id = GoodsId,typeid = TypeId} = 
                lists:keyfind(RoleId,#p_goods.roleid,GoodsList),
            if GoodsInfo#p_goods.id =:= GoodsId
               andalso  GoodsInfo#p_goods.typeid =:= TypeId ->
                    %% 广播一下，队员把道具销毁了
                    #p_map_role{role_name = RoleName} = 
                        lists:keyfind(RoleId,#p_map_role.role_id,ParentMapRoleList),
                    put_educate_fb_dict(EducateFbDictRecord#r_educate_fb_dict{drop_item_role_ids = [RoleId|DropItemRoleIdList]}),
                    Message = lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ITEM_DROP_MEMBER_ITEM,[common_tool:to_list(RoleName)])),
                    RoleIdList = mod_map_actor:get_in_map_role(),
                    catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,Message),
                    catch do_educate_fb_item_bc_leader(LeaderRoleId,0),
                    %% 检查是否已经无法完成副本了，需要踢人出副本，记录日志
                    MonsterIdList = mod_map_monster:get_monster_id_list(),
                    if LeaderRoleId =:= RoleId 
                       andalso MonsterIdList =:= [] ->
                            EndTime = common_tool:now(),
                            lists:foreach(
                              fun(VRoleId) ->
                                      EducateFbRole = lists:keyfind(VRoleId,#r_educate_fb.role_id,EducateFbRoleList),
                                      FbCount2 = if FbCount < 0 -> 0; true-> FbCount end,
                                      {AwardList,BcList} = calc_award_p_goods_by_sum_count(RoleId,FbCount2 + EducateFbRole#r_educate_fb.lucky_count),
                                      db:dirty_write(?DB_EDUCATE_FB,EducateFbRole#r_educate_fb{
                                                                      status = ?EDUCATE_FB_STATUS_COMPLETE,
                                                                      award_list = AwardList,
                                                                      bc_list = BcList,
                                                                      end_time =EndTime,
                                                                      count=FbCount2})
                              end,RoleIdList),
                            do_educate_fb_close_log(RoleIdList,EndTime,1),
                            EducateFbDictRecord2 = EducateFbDictRecord#r_educate_fb_dict{fb_status = 1},
                            put_educate_fb_dict(EducateFbDictRecord2),
                            catch common_broadcast:bc_send_msg_role(RoleIdList,?BC_MSG_TYPE_CENTER,?_LANG_EDUCATE_FB_ITEM_DROP_LEADER_ITEM),
                            do_educate_fb_close_and_bc(30);
                       true ->
                            next
                    end;
               true ->
                    ignore
            end
    end.
            
%% 玩家在师徒副本中通过其它方式传送到其它地图时的处理
%% 门派召集，门派令，国王令等操作
%% global:send(FbMapProcessName, {mod_educate_fb,{cancel_role_educate_fb,RoleId}}),
do_cancel_role_educate_fb(RoleId) ->
    MapId = mgeem_map:get_mapid(),
    FBMapId = get_educate_fb_map_id(),
    if MapId =:= FBMapId ->
            do_cancel_role_educate_fb2(RoleId);
       true ->
            ignore
    end.
do_cancel_role_educate_fb2(RoleId) ->
    case get_educate_fb_dict() of
        undefined ->
            ignore;
        EducateFbDictRecord ->
            NowSeconds = common_tool:now(),
            %% 销毁副本道具
            #r_educate_fb_dict{leader_role_id = LeaderRoleId,
                               educate_fb_role = EducateFbRoleList,
                               used_item_role_ids = UsedItemRoleIdList,
                               drop_item_role_ids = DropItemRoleIdList,
                               fb_count = FbCount} = EducateFbDictRecord,
            IsDropItemFlag = lists:member(RoleId,DropItemRoleIdList),
            IsUseItemFlag = lists:member(RoleId,UsedItemRoleIdList),
            if LeaderRoleId =:= RoleId andalso IsDropItemFlag =:= false ->
                    do_educate_fb_close_delete_fb_item([RoleId],NowSeconds,EducateFbDictRecord);
               IsDropItemFlag =:= false andalso IsUseItemFlag =:= false ->
                    do_educate_fb_close_delete_fb_item([RoleId],NowSeconds,EducateFbDictRecord);
               true ->
                    EducateFbRole = lists:keyfind(RoleId,#r_educate_fb.role_id,EducateFbRoleList),
                    FbCount2 = if FbCount < 0 -> 0; true-> FbCount end,
                    {AwardList,BcList} = calc_award_p_goods_by_sum_count(RoleId,FbCount2 + EducateFbRole#r_educate_fb.lucky_count),
                    EducateFbRole2 = EducateFbRole#r_educate_fb{
                                       end_time = NowSeconds,
                                       status = ?EDUCATE_FB_STATUS_COMPLETE,
                                       award_list = AwardList,
                                       bc_list = BcList,
                                       count = FbCount2},
                    db:dirty_write(?DB_EDUCATE_FB,EducateFbRole2)
            end,
            do_educate_fb_role_log(RoleId,NowSeconds),
            catch do_educate_fb_item_bc_leader(LeaderRoleId,RoleId)
    end.


%% 返回 {MapId,Tx,Ty}
get_home_born_info(RoleId) ->
    FactionId = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                {ok, RoleBase} = mod_map_role:get_role_base(RoleId),
                RoleBase#p_role_base.faction_id;
            MapRoleInfo ->
                MapRoleInfo#p_map_role.faction_id
        end,
    MapId = common_misc:get_home_map_id(FactionId),
    {MapId,Tx,Ty} = common_misc:get_born_info_by_map(MapId),
    {MapId,Tx,Ty}.

get_error_desc_for_not_team() ->
    MinRoleNumber = get_min_enter_fb_role_number(),
    lists:flatten(io_lib:format(?_LANG_EDUCATE_FB_ENTER_NOT_TEAM,[common_tool:to_list(MinRoleNumber)])).

%% 返回 [p_educate_fb_award]
get_educate_fb_award_config() ->
    case common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_award) of
        [FbAwardList] ->
            [#p_educate_fb_award{min_count = FbAward#r_educate_fb_award.min_count,
                                 max_count = FbAward#r_educate_fb_award.max_count,
                                 award_number = FbAward#r_educate_fb_award.award_number}||FbAward <- FbAwardList];
        _ ->
            []
    end.
    

%% 检查玩家是否在有效的距离内
%% 参数
%% NpcId NPC ID
%% RoleMapInfo 结构为 p_nap_role
%% 返回 true or false
check_valid_distance(NpcId,RoleMapInfo) ->
    [{NpcId, {MapId, Tx, Ty}}] = ets:lookup(?ETS_MAP_NPC, NpcId),
    {MaxTx,MaxTy} = get_npc_valid_distance(),
    InMapId = mgeem_map:get_mapid(),
    #p_map_role{pos = #p_pos{tx = InTx,ty = InTy}} = RoleMapInfo,
    TxDiff = erlang:abs(InTx - Tx),
    TyDiff = erlang:abs(InTy - Ty),
    if InMapId =:= MapId
       andalso TxDiff < MaxTx  
       andalso TyDiff < MaxTy ->
            true;
       true ->
            false
    end.
%% 根据玩家的位置判断是否在有效的使用道具距离中
check_use_item_valid_distance(MapRoleInfo,ItemUsePos) ->
    #r_educate_fb_item_use_pos{tx = Tx,ty = Ty,
                               max_tx = MaxTx,
                               max_ty = MaxTy} = ItemUsePos,
    #p_pos{tx = RoleTx,ty = RoleTy} = MapRoleInfo#p_map_role.pos,
    TxDiff = erlang:abs(RoleTx - Tx),
    TyDiff = erlang:abs(RoleTy - Ty),
    if TxDiff < MaxTx  andalso TyDiff < MaxTy ->
            true;
       true ->
            false
    end.

%% 商贸活动玩家与NPC的有效距离 {tx,ty}
get_npc_valid_distance() ->
    case common_config_dyn:find(?EDUCATE_FB_CONFIG,npc_valid_distance) of
        [Value] ->
            Value;
        _ ->
            {10,10}
    end.
%% 进入副本的玩家最小级别
get_min_enter_fb_role_level() ->
    case common_config_dyn:find(?EDUCATE_FB_CONFIG,min_enter_fb_role_level) of
        [Value] ->
            Value;
        _ ->
            15
    end.
get_min_enter_fb_role_number() ->
    case common_config_dyn:find(?EDUCATE_FB_CONFIG,min_enter_fb_role_number) of
        [Value] ->
            Value;
        _ ->
            2
    end.
get_max_enter_fb_times() ->
    case common_config_dyn:find(?EDUCATE_FB_CONFIG,max_enter_fb_times) of
        [Value] ->
            Value;
        _ ->
            2
    end.

get_fb_map_born() ->
    case common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_map_born) of
        [Value] ->
            Value;
        _ ->
            [{111,46},{107,51},{112,51},{108,56},{112,55}]
    end.

get_fb_item_leader() ->
    case common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_item_leader) of
        [Value] ->
            Value;
        _ ->
            10100017
    end.
get_fb_item_member() ->
    case common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_item_member) of
        [Value] ->
            Value;
        _ ->
            [10100012,10100013,10100014,10100015,10100016]
    end.
get_max_fb_online_seconds() ->
    case common_config_dyn:find(?EDUCATE_FB_CONFIG,max_fb_online_seconds) of
        [Value] ->
            Value;
        _ ->
            1800
    end.
%% 返回 [r_educate_fb_item_use_pos ...]
get_random_fb_item_use_pos() ->
    [ItemUsePosList] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_item_use_pos),
    [{MaxTx,MaxTy}] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_item_use_rang),
    [MemberItemIdList] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_item_member),
    {Reasult,_} = 
        lists:foldl(
          fun(ItemId,Acc) ->
                  {AccResult,AccItemUsePosList} = Acc,
                  RandomNumber = random:uniform(erlang:length(AccItemUsePosList)),
                  PosT = lists:nth(RandomNumber,AccItemUsePosList),
                  AccItemUsePosList2 = lists:delete(PosT,AccItemUsePosList),
                  {Tx,Ty} = PosT,
                  Record = #r_educate_fb_item_use_pos{item_id= ItemId,tx = Tx,ty = Ty,max_tx = MaxTx,max_ty = MaxTy},
                  {[Record|AccResult],AccItemUsePosList2}
          end,{[],ItemUsePosList},MemberItemIdList),
    [{LeaderTx,LeaderTy}] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_boss_monster_born),
    LeaderRecord= #r_educate_fb_item_use_pos{item_id= get_fb_item_leader(),tx = LeaderTx,ty = LeaderTy,max_tx = MaxTx,max_ty = MaxTy},
    Reasult2 = [LeaderRecord | Reasult],
    ?DEBUG("~ts,ItemUsePos=~w",["本次进入师门同心副本，道具对应的使用位置如下",Reasult2]),
    Reasult2.
%% 计算副本怪物级别
get_fb_monster_level(MapRoleList) ->
    LevelList = [MapRole#p_map_role.level || MapRole <- MapRoleList],
    SumLevel = lists:sum(LevelList),
    RoleMember = erlang:length(MapRoleList),
    5 * ( SumLevel div RoleMember div 5).
%% 返回 [int32,...] or []
get_fb_monster_type_id(MonsterLevel) ->
    [FbMonster] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_monster),
    {MonsterLevel,MonsterList,_BossMonster} =  lists:keyfind(MonsterLevel,1,FbMonster),
    [TypeId || #r_educate_fb_monster{monster_id = TypeId} <- MonsterList].
%% 根据副本级别获取副本Boss信息 {MonsterType,PMonster}
get_fb_boss_p_monster(MonsterLevel) ->
    [FbMonster] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_monster),
    {MonsterLevel,_MonsterList,BossMonster} =  lists:keyfind(MonsterLevel,1,FbMonster),
    [{Tx,Ty}] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_boss_monster_born),
    FBMapId = get_educate_fb_map_id(),
    #r_educate_fb_monster{type = MonsterType,monster_id = TypeId} = BossMonster,
    PMonster = #p_monster{reborn_pos = #p_pos{tx = Tx,ty = Ty,dir = 1},
                          monsterid = mod_map_monster:get_max_monster_id_form_process_dict(),
                          typeid = TypeId,
                          mapid = FBMapId},
    {MonsterType,[PMonster]}.
%% 返回 [{MonsterType,[p_monster ....],...]
get_fb_p_monster(MonsterLevel,UsePos) ->
    [FbMonsterBornList] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_monster_born),
    {UsePos,BornList} = lists:keyfind(UsePos,1,FbMonsterBornList),
    [FbMonster] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_monster),
    {MonsterLevel,MonsterList,_BossMonster} =  lists:keyfind(MonsterLevel,1,FbMonster),
    MonsterList2 = 
        lists:foldl(
          fun(Monster,MonsterAcc) ->
                  #r_educate_fb_monster{weight = Weight} = Monster,
                  lists:append([lists:map(fun(_Index) -> Monster end,lists:seq(1,Weight,1)),MonsterAcc])
          end,[],MonsterList),
    FBMapId = get_educate_fb_map_id(),
    {PMonsterList,_} = 
        lists:foldl(
          fun(Monster2,Acc) ->
                  {AccList,AccBornList} = Acc,
                  RandomNumber = random:uniform(erlang:length(AccBornList)),
                  PosT = lists:nth(RandomNumber,AccBornList),
                  {Tx,Ty} = PosT,
                  AccBornList2 = lists:delete(PosT,AccBornList),
                  #r_educate_fb_monster{type = MonsterType,monster_id = TypeId} = Monster2,
                  PMonster = #p_monster{reborn_pos = #p_pos{tx = Tx,ty = Ty,dir = 1},
                                        monsterid = mod_map_monster:get_max_monster_id_form_process_dict(),
                                        typeid = TypeId,
                                        mapid = FBMapId},
                  case lists:keyfind(MonsterType,1,AccList) of
                      false ->
                          {[{MonsterType,[PMonster]}|AccList],AccBornList2};
                      {MonsterType,AccSubList} ->
                          AccList2 = lists:keydelete(MonsterType,1,AccList),
                          {[{MonsterType,[PMonster|AccSubList]}|AccList2],AccBornList2}
                  end
          end,{[],BornList},MonsterList2),
    ?DEBUG("~ts,PMonsterList=~w",["使用道具召唤怪物的信息如下",PMonsterList]),
    PMonsterList.

%% 副本结束时记录日志
%% LogType 1 记录所有日志，2 只记录副本日志
do_educate_fb_close_log(RoleIdList,NowSeconds,LogType) ->
    EducateFbDictRecord = get_educate_fb_dict(),
    #r_educate_fb_dict{parent_map_role = ParentMapRoleList,
                       educate_fb_role = EducateFbRoleList,
                       leader_role_id = LeaderRoleId,
                       leader_role_name = LeaderRoleName,
                       monster_level = MonsterLevel,
                       fb_count = FbCount,
                       start_time = StartTime,
                       faction_id = FactionId,
                       fb_status = FBStatus,
                       fb_dead_roles = FbDeadRoleList,
                       fb_role_dead_times=FbRoleDeadTimes} = EducateFbDictRecord,
    if FBStatus =/= 1 ->
            %% 记录日志
            {OutRoleIds,OutNumber} =
                lists:foldl(
                  fun(OutRoleId,{AccOutId,AccOutIndex}) -> 
                          AccOutId2 = 
                              if AccOutIndex =:=  0 ->
                                      lists:concat(["{",OutRoleId,"}"]);
                                 true ->
                                      lists:concat([AccOutId,",{",OutRoleId,"}"])
                              end,
                          {AccOutId2,AccOutIndex + 1}
                  end,{"",0},RoleIdList),
            {InRoleIds,InRoleNames,InNumber} = 
                lists:foldl(
                  fun(#p_map_role{role_id = InRoleId,role_name = InRoleName},{AccInId,AccInName,AccInIndex}) ->
                          {AccInId2,AccInName2} = 
                              if AccInIndex =:= 0 ->
                                      {lists:concat(["{",InRoleId,"}"]),common_tool:to_list(InRoleName)};
                                 true ->
                                      {lists:concat([AccInId,",{",InRoleId,"}"]),
                                       lists:append([AccInName, ",",common_tool:to_list(InRoleName)])}
                              end,
                          {AccInId2,AccInName2,AccInIndex + 1}
                  end,{"","",0},ParentMapRoleList),
            EducateFbLog=#r_educate_fb_log{
              faction_id = FactionId,
              leader_role_id = LeaderRoleId,
              leader_role_name = LeaderRoleName,
              monster_level = MonsterLevel,
              start_time = StartTime,
              status = ?EDUCATE_FB_STATUS_COMPLETE,
              end_time = NowSeconds,
              count = FbCount,
              in_role_ids = InRoleIds,
              in_role_names = InRoleNames,
              out_role_ids = OutRoleIds,
              in_number = InNumber,
              out_number = OutNumber,
              dead_times = FbRoleDeadTimes},
            catch common_general_log_server:log_educate(EducateFbLog),
            if LogType =:= 1 ->
                    lists:foreach(
                      fun(RoleId) ->
                              RoleMapInfo = lists:keyfind(RoleId,#p_map_role.role_id,ParentMapRoleList),
                              EducateFbRole = lists:keyfind(RoleId,#r_educate_fb.role_id,EducateFbRoleList),
                              {RoleId,RoleDeadTimes} = lists:keyfind(RoleId,1,FbDeadRoleList),
                              EducateFbRoleLog = #r_educate_fb_role_log{
                                faction_id = FactionId,
                                role_id = RoleId,
                                role_name = RoleMapInfo#p_map_role.role_name,
                                leader_role_id = LeaderRoleId,
                                leader_role_name = LeaderRoleName,
                                monster_level = MonsterLevel,
                                start_time = StartTime,
                                status = ?EDUCATE_FB_STATUS_COMPLETE,
                                end_time = NowSeconds,
                                count = FbCount, 
                                times = EducateFbRole#r_educate_fb.times,
                                dead_times = RoleDeadTimes},
                              catch common_general_log_server:log_educate(EducateFbRoleLog)
                      end,RoleIdList);
               true ->
                    next
            end;
       true ->
            next
    end.
%% 根据最新的需求只需要队伍中有存在师门关系就合法，不需要全部队员是同一师门
%% 返回 ok or {error,Diff, NoHomeGate}
check_in_same_homegate(RoleIdList) ->
    {Flag,SameRoleList,Diff,NoHomeGate} = 
        lists:foldl(
          fun(RoleId,{AccFlag,AccRoleIdList,AccDiff,AccNoHomeGate}) ->
                  if AccFlag =:= false ->
                          RoleIdList2 = lists:delete(RoleId,RoleIdList),
                          case check_in_same_homegate(RoleId,RoleIdList2) of 
                              ok ->
                                  {true,[],[],[]};
                              {error,DiffT,NoHomeGateT} ->
                                  case (erlang:length(RoleIdList2) =:= erlang:length(lists:append([DiffT,NoHomeGateT]))) of 
                                      true ->
                                          {AccFlag,AccRoleIdList,[RoleId|AccDiff],lists:append([NoHomeGateT,AccNoHomeGate])};            
                                      false ->
                                          {AccFlag,[RoleId|AccRoleIdList],AccDiff,lists:append([NoHomeGateT,AccNoHomeGate])}
                                  end
                          end;          
                     true ->
                          {AccFlag,AccRoleIdList,AccDiff,AccNoHomeGate}
                  end
          end,{false,[],[],[]},RoleIdList),
    ?DEBUG("Flag=~w,SameRoleList=~w,Diff=~w,NoHomeGate=~w",[Flag,SameRoleList,Diff,NoHomeGate]),
    case (Flag =:= true orelse erlang:length(RoleIdList) =:=  erlang:length(SameRoleList)) of 
        true ->
            ok;
        false ->
            LastNoHomeGate = 
                lists:foldl(
                  fun(NoRoleId,AccNoHomeGate2) -> 
                          case lists:member(NoRoleId,AccNoHomeGate2) of true -> AccNoHomeGate2; false -> [NoRoleId|AccNoHomeGate2] end 
                  end,[],NoHomeGate),
            LastDiff = 
                lists:foldl(
                  fun(DiffRoleId,AccDiff2) ->
                          case (lists:member(DiffRoleId,AccDiff2) =:= false
                                andalso lists:member(DiffRoleId,LastNoHomeGate) =:= false) of 
                              true ->
                                  [DiffRoleId|AccDiff2];
                              false ->
                                  AccDiff2
                          end
                  end,[],Diff),
            {error,LastDiff,LastNoHomeGate}
    end.
%% 根据队长id和队员id列表，判断是否跟队长是属于同门
%% 返回 ok or {error,Diff, NoHomeGate}
check_in_same_homegate(RoleID, TargetList) ->
    [EducateInfo] = db:dirty_read(?DB_ROLE_EDUCATE, RoleID),
    #r_educate_role_info{teacher=TeacherID, students=StudentIDList} = EducateInfo,
    %% 师傅的师傅和师傅的徒弟，不包括自己
    case is_integer(TeacherID) andalso TeacherID>0 of
        false ->
            HomeGateIDList = [];
        _ ->
            %% 师门ID
            [#r_educate_role_info{teacher=FolkMasterID,students = FolkStudentID}] = db:dirty_read(?DB_ROLE_EDUCATE, TeacherID),
            HomeGateIDListT = 
                lists:foldl(
                  fun(AccList,AccHomeGateIDList) ->
                          case AccList of
                              undefined ->
                                  AccHomeGateIDList;
                              AccListT when erlang:is_list(AccListT) ->
                                  lists:append([AccHomeGateIDList,AccListT]);
                              _ ->
                                  lists:append([AccHomeGateIDList,[AccList]])
                          end
                  end,[],[TeacherID,FolkMasterID,FolkStudentID]),
            HomeGateIDList = lists:delete(RoleID,HomeGateIDListT)
    end,
    %% 徒弟
    case StudentIDList of
        undefined ->
            StudentIDList2 = [];
        _ ->
            StudentIDList2 = StudentIDList
    end,
    %% 徒弟的徒弟
    StudentStudentIdList = 
    lists:foldl(
      fun(StudentId,AccStudentStudentIdList) ->
              [#r_educate_role_info{students = StudentStudents}] = db:dirty_read(?DB_ROLE_EDUCATE, StudentId),
              case StudentStudents of
                  undefined ->
                      AccStudentStudentIdList;
                  StudentStudentsT when erlang:is_list(StudentStudentsT) ->
                      lists:append([AccStudentStudentIdList,StudentStudents]);
                  _ ->
                      lists:append([AccStudentStudentIdList,[StudentStudents]])
              end
      end,[],StudentIDList2),
    %% 所有的关系
    HomeGateIDList2 = lists:append([HomeGateIDList, StudentIDList2,StudentStudentIdList]),
    {Same, Diff, NoHomeGate} =
        lists:foldl(
          fun(TargetID, {S, D, N}) ->
                  case lists:member(TargetID, HomeGateIDList2) of
                      true ->
                          {[TargetID|S], D, N};
                      _ ->
                          case if_has_homegate(TargetID) of
                              true ->
                                  {S, [TargetID|D], N};
                              _ ->
                                  {S, D, [TargetID|N]}
                          end
                  end
          end, {[], [], []}, TargetList),
    ?DEBUG("Same=~w,TargetList=~w,Diff=~w, NoHomeGate=~w",[Same,TargetList,Diff, NoHomeGate]),
    case length(Same) =:= length(TargetList) of
        true ->
            ok;
        _ ->
            {error, Diff, NoHomeGate}
    end.
if_has_homegate(RoleID) ->
    [EducateInfo] = db:dirty_read(?DB_ROLE_EDUCATE, RoleID),
    #r_educate_role_info{teacher=TID, students=SIDList} = EducateInfo,
    Result =
        case TID of
            undefined ->
                false;
            _ ->
                true
        end,
    if Result =:= true ->
            true;
       true ->
            if  SIDList =/= [] ->
                    true;
                true ->
                    false
            end
    end.


%% 计算幸运积分
calc_default_lucky_count() ->
    [LuckyCountList] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_lucky_count),
    DefaultWeightList = [DefaultWeight || #r_educate_fb_lucky_count{default_weight = DefaultWeight} <- LuckyCountList],
    WeightIndex = mod_refining:get_random_number(DefaultWeightList,0,1),
    LuckyCountRecord = lists:nth(WeightIndex,LuckyCountList),
    #r_educate_fb_lucky_count{min_count = MinCount,max_count = MaxCount} = LuckyCountRecord,
    LuckyCount = common_tool:random(MinCount,MaxCount),
    ?DEBUG("~ts,LuckyCount=~w",["本次计算的幸运积分",LuckyCount]),
    LuckyCount.
%% 根据刷新积分的次数来计算幸运积分
calc_lucky_count(Times) ->
    [LuckyCountList] = common_config_dyn:find(?EDUCATE_FB_CONFIG,fb_lucky_count),
    WeightList = 
        lists:foldl(
          fun(#r_educate_fb_lucky_count{weight = Weight,less_weight = LessWeight},AccWeightList) ->
                  NewWeight =  Weight - (LessWeight * Times),
                  if NewWeight < 0 ->
                          lists:append([AccWeightList,[0]]);
                     true ->
                          lists:append([AccWeightList,[NewWeight]])
                  end
          end,[],LuckyCountList),
    ?DEBUG("~ts,WeightList=~w",["权重列表为：",WeightList]),
    WeightIndex = mod_refining:get_random_number(WeightList,0,1),
    LuckyCountRecord = lists:nth(WeightIndex,LuckyCountList),
    #r_educate_fb_lucky_count{min_count = MinCount,max_count = MaxCount} = LuckyCountRecord,
    LuckyCount = common_tool:random(MinCount,MaxCount),
    ?DEBUG("~ts,LuckyCount=~w,Times=~w",["本次计算的幸运积分",LuckyCount,Times]),
    LuckyCount.

