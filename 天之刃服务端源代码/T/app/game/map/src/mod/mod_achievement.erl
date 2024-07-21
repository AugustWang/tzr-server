%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2010, 
%%% @doc
%%% 成就系统处理模块
%%% @end
%%% Created : 10 Nov 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_achievement).

-include("mgeem.hrl").

-define(ACHIEVEMENT_QUERY_OP_TYPE_EVENT_ID_LIST,1).%% 根据成就id列表查询成就信息
-define(ACHIEVEMENT_QUERY_OP_TYPE_GROUP_ID,2).%% 根据成就组id查询
-define(ACHIEVEMENT_QUERY_OP_TYPE_OVERVIEW,3).%% 查询成就总览
-define(ACHIEVEMENT_QUERY_OP_TYPE_LATELY,4).%% 查询最近完成就
-define(ACHIEVEMENT_QUERY_OP_TYPE_RANK,5).%% 全服成就查询

%% achieve_type 成就类型 0一般成就 1组成就 2 全服成就
-define(ACHIEVEMENT_ACHIEVE_TYPE_GENERAL,0).%% 一般成就
-define(ACHIEVEMENT_ACHIEVE_TYPE_GROUP,1).%% 组成就
-define(ACHIEVEMENT_ACHIEVE_TYPE_RANK,2).%% 全服成就

-define(ACHIEVEMENT_IS_OPEN_CLOSE,0).
-define(ACHIEVEMENT_IS_OPEN_OPEN,1).

-export([
         do_handle_info/1,
         init/1
        ]).

-export([init_role_achievement_info/2,
         get_role_achievement_info/1,
         erase_role_achievement_info/1]).

%% @doc 初始化角色achievement信息
init_role_achievement_info(RoleId, AchievementInfo) ->
    case AchievementInfo of
        undefined ->
            ignore;
        _ ->
            erlang:put({?role_achievement, RoleId}, AchievementInfo)
    end.
%% @doc 获取角色achievement信息
get_role_achievement_info(RoleId) ->
    case erlang:get({?role_achievement, RoleId}) of
        undefined ->
            {error, not_found};
        AchievementInfo ->
            {ok,AchievementInfo}
    end.
%% @doc 清除角色achievement信息
erase_role_achievement_info(RoleId) ->
    case get_role_achievement_info(RoleId) of
        {ok, AchievementInfo} ->
            mgeem_persistent:role_achievement_persistent(AchievementInfo),
            erlang:erase({?role_achievement, RoleId});
        _ ->
            ignore
    end.

%% @doc 设置角色achievement信息
t_set_role_achievement_info(RoleId, AchievementInfo) ->
    mod_map_role:update_role_id_list_in_transaction(RoleId, ?role_achievement, ?role_achievement_copy),
    erlang:put({?role_achievement, RoleId}, AchievementInfo).

%% 全服成就进程字典
put_achievement_rank_dict(MapId,AchievementRankList) ->
    erlang:put({achievement_rank,MapId},AchievementRankList).
get_achievement_rank_dict(MapId) ->
    erlang:get({achievement_rank,MapId}).

init(MapId) ->
    [AchievementRankMapId] = common_config_dyn:find(achievement_hook,achievement_rank_map_id),
    case AchievementRankMapId =:= MapId of
        true ->
            AchievementRankList = db:dirty_match_object(?DB_ACHIEVEMENT_RANK_P,#r_achievement_rank{_ = '_' }),
            put_achievement_rank_dict(MapId,AchievementRankList);
        _ ->
            ignore
    end.

%% 完成某个成就的通知
do_handle_info({Unique, ?ACHIEVEMENT, ?ACHIEVEMENT_NOTICE, DataRecord, RoleId, Line}) 
  when erlang:is_record(DataRecord,m_achievement_notice_tos)->
    do_achievement_notice({Unique, ?ACHIEVEMENT, ?ACHIEVEMENT_NOTICE, DataRecord, RoleId, Line});

%% 领取奖励
do_handle_info({Unique, ?ACHIEVEMENT, ?ACHIEVEMENT_AWARD, DataRecord, RoleId, Line})
  when erlang:is_record(DataRecord,m_achievement_award_tos)->
    do_achievement_award({Unique, ?ACHIEVEMENT, ?ACHIEVEMENT_AWARD, DataRecord, RoleId, Line});

%% 查询成就状态
do_handle_info({Unique, ?ACHIEVEMENT, ?ACHIEVEMENT_QUERY, DataRecord, RoleId, Line})
  when erlang:is_record(DataRecord,m_achievement_query_tos)->
    do_achievement_query({Unique, ?ACHIEVEMENT, ?ACHIEVEMENT_QUERY, DataRecord, RoleId, Line});

do_handle_info({system_achievement_event_notic,RoleId,DataRecord})
  when erlang:is_record(DataRecord,m_achievement_notice_tos) ->
    do_system_achievement_event_notic(RoleId,DataRecord);

%% 查询成就榜
do_handle_info({query_achievement_rank,Msg}) ->
    do_query_achievement_rank(Msg);
do_handle_info({update_achievement_award_status,Msg}) ->
    do_update_achievement_award_status(Msg);
do_handle_info({achievement_rank_event,Msg}) ->
    do_achievement_rank_event(Msg);
do_handle_info({update_complete_achievement_rank,Msg}) ->
    do_update_complete_achievement_rank(Msg);

do_handle_info(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["成就模块无法处整此消息",Info]),
    error.

do_system_achievement_event_notic(RoleId,DataRecord) ->
    Line = common_misc:get_role_line_by_id(RoleId),
    do_achievement_notice({?DEFAULT_UNIQUE, ?ACHIEVEMENT, ?ACHIEVEMENT_NOTICE, DataRecord, RoleId, Line}).
   
%% 玩家领取成就榜成就之后更新成就榜数据状态
do_update_achievement_award_status({RoleId,AchieveId,MapId}) ->
    case get_achievement_rank_dict(MapId) of
        undefined ->
            ?ERROR_MSG("~ts,RoleId=~w,AchieveId=~w,MapId=~w",["严重错误，玩家没有完成此成就榜的成就，即领取了奖励",RoleId,AchieveId,MapId]),
            ignore;
        AchievementRankList ->
            case lists:keyfind(AchieveId,#r_achievement_rank.achieve_id,AchievementRankList) of
                false ->
                    ?ERROR_MSG("~ts,RoleId=~w,AchieveId=~w,MapId=~w",["严重错误，玩家没有完成此成就榜的成就，即领取了奖励",RoleId,AchieveId,MapId]),
                    ignore;
                AchievementRank ->
                    case AchievementRank#r_achievement_rank.role_id =/= 0 
                        andalso AchievementRank#r_achievement_rank.status =:= 2
                        andalso AchievementRank#r_achievement_rank.role_id =:= RoleId of
                        true ->
                            AchievementRank2 = AchievementRank#r_achievement_rank{status = 3,award_time = common_tool:now()},
                            put_achievement_rank_dict(MapId,[AchievementRank2|lists:keydelete(AchieveId,#r_achievement_rank.achieve_id,AchievementRankList)]),
                            db:dirty_write(?DB_ACHIEVEMENT_RANK_P,AchievementRank2);
                        _ ->
                            ?ERROR_MSG("~ts,RoleId=~w,AchieveId=~w,MapId=~w",["严重错误，玩家没有完成此成就榜的成就，即领取了奖励",RoleId,AchieveId,MapId]),
                            ignore
                    end
            end
    end,          
    ok.
%% 玩家完成成就榜成就事件，更新
do_achievement_rank_event({RoleId,RankEventIdList,MapId}) ->
    case get_achievement_rank_dict(MapId) of
        undefined ->
            AchievementRankList = [];
        AchievementRankList ->
            ignore
    end,
    %% 判断此成就是不是已经被其它玩家先完成了
    RankEventIdList2 = 
        lists:foldl(
          fun(AchievementRank,AccRankEventIdList2) ->
                  case AchievementRank#r_achievement_rank.event =:= 2
                      andalso AchievementRank#r_achievement_rank.event =:= 3 of
                      true ->
                          lists:foldl(
                            fun(CheckRankEventId,AccRankEventIdList2T) ->
                                    lists:delete(CheckRankEventId,AccRankEventIdList2T)
                            end,AccRankEventIdList2,AchievementRank#r_achievement_rank.event);
                      _ ->
                          AccRankEventIdList2
                  end
          end,RankEventIdList,AchievementRankList),
    case RankEventIdList2 =/= [] of
        true ->
            %%?DEBUG("~ts,RoleId=~w,RankEventIdList=~w",["需要处理的成就榜成就事件列表",RoleId,RankEventIdList2]),
            do_achievement_rank_event2({RoleId,RankEventIdList2,MapId},AchievementRankList);
        _ ->
            ignore
    end.
do_achievement_rank_event2({RoleId,RankEventIdList,MapId},AchievementRankList) ->
    %% 当前完成的成就榜成就
    AchievementConfigList = 
        lists:foldl(
          fun(AchievementConfigA,AccAchievementConfigList) ->
                  AchievementConfigAEventId = lists:nth(1,AchievementConfigA#r_achievement_config.event),
                  case AchievementConfigA#r_achievement_config.is_open =:= ?ACHIEVEMENT_IS_OPEN_OPEN
                      andalso AchievementConfigA#r_achievement_config.achieve_type =:= ?ACHIEVEMENT_ACHIEVE_TYPE_RANK 
                      andalso lists:member(AchievementConfigAEventId,RankEventIdList) of
                      true ->
                          [AchievementConfigA|AccAchievementConfigList];
                      _ ->
                          AccAchievementConfigList
                  end
          end,[],common_config_dyn:list(achievement)),
    NowSecords = common_tool:now(),
    {ok,#p_role_base{role_name = RoleName,faction_id = FactionId}} = common_misc:get_dirty_role_base(RoleId),
    {AchievementRankList2,RoleAchievementList}= 
        lists:foldl(
          fun(AchievementConfigB,{AccAchievementRankList,AccRoleAchievementList}) ->
                  AchievementEventList = [#r_role_achievement_event{
                                             event_id = ConfigEventId,
                                             event_status = 1} 
                                          || ConfigEventId <- AchievementConfigB#r_achievement_config.event],
                  AchievementRankRecord = #r_achievement_rank{
                    achieve_id = AchievementConfigB#r_achievement_config.achieve_id,
                    class_id = AchievementConfigB#r_achievement_config.class_id,
                    group_id = AchievementConfigB#r_achievement_config.group_id,
                    achieve_type = AchievementConfigB#r_achievement_config.achieve_type,
                    status = 2,
                    event = AchievementEventList,
                    create_time = NowSecords,
                    complete_time = NowSecords,
                    award_time = 0,
                    cur_progress = 0,
                    total_progress = 0,
                    role_id= RoleId,
                    role_name = RoleName,
                    faction_id= FactionId},
                  db:dirty_write(?DB_ACHIEVEMENT_RANK_P,AchievementRankRecord),
                  {[AchievementRankRecord|AccAchievementRankList],
                   [#r_role_achievement{
                       achieve_id = AchievementConfigB#r_achievement_config.achieve_id,
                       class_id = AchievementConfigB#r_achievement_config.class_id,
                       group_id = AchievementConfigB#r_achievement_config.group_id,
                       achieve_type = AchievementConfigB#r_achievement_config.achieve_type,
                       status = 2,
                       event = AchievementEventList,
                       create_time = NowSecords,
                       complete_time = NowSecords,
                       award_time = 0,
                       cur_progress = 0,
                       total_progress = 0}|AccRoleAchievementList]}
          end,{AchievementRankList,[]},AchievementConfigList),
    put_achievement_rank_dict(MapId,AchievementRankList2),
    %% 发送消息同步数据
    common_misc:send_to_rolemap(RoleId,{mod_achievement,{update_complete_achievement_rank,{RoleId,RoleAchievementList}}}),
    ok.

do_update_complete_achievement_rank({RoleId,RoleAchievementRankList}) ->
    DBRoleAchievement = 
        case get_role_achievement_info(RoleId) of
            {ok,DBRoleAchievementT} ->
                DBRoleAchievementT;
            _ ->
                #r_db_role_achievement{role_id = RoleId,achievements = [],lately_achievements = [],stat_info = []}
        end,
    %% 需要处理成就称号和成就值奖励
    case common_transaction:transaction(
           fun() ->
                   [{MaxKeepNumber,_MaxViewNumber}] = common_config_dyn:find(achievement_hook,lately_achievement_number),
                   {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
                   TotalAchievePoint = 
                       lists:foldl(
                         fun(RoleAchievementRankA,AccAddAchievePoint) ->
                                 [AchievementConfigA] = common_config_dyn:find(achievement,RoleAchievementRankA#r_role_achievement.achieve_id),
                                 AccAddAchievePoint + AchievementConfigA#r_achievement_config.achieve_point
                         end,RoleBase#p_role_base.achievement,RoleAchievementRankList),
                   LatelyAchievements = 
                       lists:sublist(
                         lists:append([RoleAchievementRankList,DBRoleAchievement#r_db_role_achievement.lately_achievements]),
                         1,MaxKeepNumber),
                   mod_map_role:set_role_base(RoleId,RoleBase#p_role_base{achievement = TotalAchievePoint}),
                   Achievements = lists:append([DBRoleAchievement#r_db_role_achievement.achievements,RoleAchievementRankList]),
                   t_set_role_achievement_info(RoleId, DBRoleAchievement#r_db_role_achievement{
                                                         achievements = Achievements,
                                                         lately_achievements = LatelyAchievements}),
                   TotalAchievePoint
           end)
    of
        {atomic, TotalAchievePoint} ->
            #p_map_role{role_name = RoleName,faction_id = FactionId} = mod_map_actor:get_actor_mapinfo(RoleId,role),
            PAchievementList = 
                lists:foldl(
                  fun(RoleAchievementRankB,AccPAchievementList) ->
                          [AchievementConfigB] = common_config_dyn:find(achievement,RoleAchievementRankB#r_role_achievement.achieve_id),
                          %% 成就称号奖励处理
                          case RoleAchievementRankB#r_role_achievement.status =:= 2 
                              andalso AchievementConfigB#r_achievement_config.achieve_title_code =/= 0 of
                              true ->
                                  catch common_title:add_title(?TITLE_ROLE_ACHIEVEMENT,RoleId,AchievementConfigB#r_achievement_config.achieve_title_code);
                              _ ->
                                  ignore
                          end,
                          PAchievement = get_p_achievement_info(RoleAchievementRankB,AchievementConfigB),
                          [PAchievement#p_achievement_info{role_id = RoleId,role_name = RoleName,faction_id = FactionId }|AccPAchievementList]
                  end,[],RoleAchievementRankList),
            %% 通知前端
            SendSelf = #m_achievement_notice_toc{
              type = 0,
              achievements = PAchievementList,
              total_points = TotalAchievePoint
             },
            ?DEBUG("~ts,Result=~w",["成就榜完成自动通知结果为",SendSelf]),
            common_misc:unicast({role,RoleId}, ?DEFAULT_UNIQUE, ?ACHIEVEMENT, ?ACHIEVEMENT_NOTICE,SendSelf),
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("~ts,RoleId=~w,RoleAchievementRankList=~w,Error=~w",["玩家完成成就榜成就同步信息出错",RoleId,RoleAchievementRankList,Error]),
            error
    end.

%% 查询成就状态
%% DataRecord 结构 m_achievement_query_tos
do_achievement_query({Unique, Module, Method, DataRecord, RoleId, Line}) ->
    case catch do_achievement_query2(RoleId,DataRecord) of
        {error,Reason} ->
            do_achievement_query_error({Unique, Module, Method, DataRecord, RoleId, Line},Reason);
        {ok,query_rank} ->
            [AchievementRankMapId] = common_config_dyn:find(achievement_hook,achievement_rank_map_id),
            global:send(common_map:get_common_map_name(AchievementRankMapId),
                        {mod_achievement,{query_achievement_rank,{Unique, Module, Method, DataRecord, RoleId,AchievementRankMapId}}});
        {ok,AchievementConfigList} ->
            do_achievement_query3({Unique, Module, Method, DataRecord, RoleId, Line},
                                  AchievementConfigList)
    end.
do_achievement_query2(_RoleId,DataRecord) ->
    case DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_EVENT_ID_LIST
        orelse DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_GROUP_ID
        orelse DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_OVERVIEW 
        orelse DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_LATELY 
        orelse DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_RANK of
        true ->
            next;
        _ ->
            ?DEBUG("~ts",["查询类型不合法"]),
            erlang:throw({error,?_LANG_ACHIEVEMENT_QUERY_OP_TYPE})
    end,
    %% 从配置文件中查询出所需要的成就数据
    AchievementConfigList = [AchievementConfig 
                             || AchievementConfig <- common_config_dyn:list(achievement),
                                AchievementConfig#r_achievement_config.is_open =:= ?ACHIEVEMENT_IS_OPEN_OPEN],
    case DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_RANK of
        true ->
            case DataRecord#m_achievement_query_tos.group_id =/= 0 of
                true ->
                    case [AchievementRankConfig 
                          || AchievementRankConfig <- AchievementConfigList,
                             AchievementRankConfig#r_achievement_config.group_id =:= DataRecord#m_achievement_query_tos.group_id,
                             AchievementRankConfig#r_achievement_config.achieve_type =:= ?ACHIEVEMENT_ACHIEVE_TYPE_RANK] of
                        [] ->
                            erlang:throw({error,?_LANG_ACHIEVEMENT_QUERY_GROUP_ID});
                        _ ->
                            next
                    end;
                _ ->
                    erlang:throw({error,?_LANG_ACHIEVEMENT_QUERY_PARAM_ERROR})
            end, 
            erlang:throw({ok,query_rank});
        _ ->
            next
    end,
    if DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_EVENT_ID_LIST ->
            case DataRecord#m_achievement_query_tos.achieve_ids =/= undefined 
                andalso DataRecord#m_achievement_query_tos.achieve_ids =/= [] 
                andalso erlang:is_list(DataRecord#m_achievement_query_tos.achieve_ids) of
                true ->
                    next;
                _ ->
                    ?DEBUG("~ts",["参数出错无法查询"]),
                    erlang:throw({error,?_LANG_ACHIEVEMENT_QUERY_PARAM_ERROR})
            end,
            case 
                lists:foldl(
                  fun(VAchieveId,AccErrAchieveIdList) ->
                          case lists:keyfind(VAchieveId,#r_achievement_config.achieve_id,AchievementConfigList) of
                              false ->
                                  [VAchieveId | AccErrAchieveIdList];
                              _ ->
                                  AccErrAchieveIdList
                          end
                  end,[],DataRecord#m_achievement_query_tos.achieve_ids) of
                [] ->
                    next;
                ErrAchieveIdList ->
                    ?DEBUG("~ts,ErrAchieveIdList=~w",["查询参数中成就id不合法有",ErrAchieveIdList]),
                    erlang:throw({error,?_LANG_ACHIEVEMENT_QUERY_PARAM_ERROR})
            end,
            next;
       DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_GROUP_ID ->
            case DataRecord#m_achievement_query_tos.group_id =/= 0 of
                true ->
                    case [AchievementGroupConfig 
                          || AchievementGroupConfig <- AchievementConfigList,
                             AchievementGroupConfig#r_achievement_config.group_id =:= DataRecord#m_achievement_query_tos.group_id,
                             AchievementGroupConfig#r_achievement_config.achieve_type =:= ?ACHIEVEMENT_ACHIEVE_TYPE_GENERAL] of
                        [] ->
                            erlang:throw({error,?_LANG_ACHIEVEMENT_QUERY_GROUP_ID});
                        _ ->
                            next
                    end;
                _ ->
                    erlang:throw({error,?_LANG_ACHIEVEMENT_QUERY_PARAM_ERROR})
            end, 
            next;
       true ->
            next
    end,
    {ok,AchievementConfigList}.
do_achievement_query3({Unique, Module, Method, DataRecord, RoleId, Line},
                      AchievementConfigList) ->
    DBRoleAchievement = 
        case get_role_achievement_info(RoleId) of
            {ok,DBRoleAchievementT} ->
                DBRoleAchievementT;
            _ ->
                #r_db_role_achievement{role_id = RoleId,achievements = [],lately_achievements = [],stat_info = []}
        end,
    #p_map_role{role_name = RoleName,faction_id = FactionId} = mod_map_actor:get_actor_mapinfo(RoleId,role),
    %% 合并整理数据并返回
    [{_MaxKeepNumber,MaxViewNumber}] = common_config_dyn:find(achievement_hook,lately_achievement_number),
    if DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_EVENT_ID_LIST ->
            Achievements = 
                lists:foldl(
                  fun(AchieveId,AccA)->
                          AchieveConfigA = lists:keyfind(AchieveId,#r_achievement_config.achieve_id,AchievementConfigList),
                          RoleAchievementA = 
                              case lists:keyfind(AchieveId,#r_role_achievement.achieve_id,
                                                 DBRoleAchievement#r_db_role_achievement.achievements) of
                                  false ->
                                      get_r_role_achievement(AchieveConfigA);
                                  RoleAchievementAT ->
                                      RoleAchievementAT
                              end,
                          [get_p_achievement_info(RoleAchievementA,AchieveConfigA)|AccA]
                  end,[],DataRecord#m_achievement_query_tos.achieve_ids),
            LatelyAchievements = [],StatInfo = [],GroupAchievement = undefined,
            ok;
       DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_GROUP_ID ->
            Achievements = 
                lists:foldl(
                  fun(AchieveConfigB,AccB) ->
                          case AchieveConfigB#r_achievement_config.group_id =:= DataRecord#m_achievement_query_tos.group_id 
                              andalso AchieveConfigB#r_achievement_config.achieve_type =:= ?ACHIEVEMENT_ACHIEVE_TYPE_GENERAL of
                              true ->
                                  RoleAchievementB = 
                                      case lists:keyfind(AchieveConfigB#r_achievement_config.achieve_id,#r_role_achievement.achieve_id,
                                                         DBRoleAchievement#r_db_role_achievement.achievements) of
                                          false ->
                                              get_r_role_achievement(AchieveConfigB);
                                          RoleAchievementBT ->
                                              RoleAchievementBT
                                      end,
                                  [get_p_achievement_info(RoleAchievementB,AchieveConfigB)|AccB];
                              _ ->
                                  AccB
                          end
                  end,[],AchievementConfigList),
            case lists:keyfind(DataRecord#m_achievement_query_tos.group_id,#r_achievement_config.achieve_id,AchievementConfigList) of
                false ->
                    GroupAchievement = undefined;
                AchieveGroupConfig ->
                    GroupAchievement = 
                        case lists:keyfind(DataRecord#m_achievement_query_tos.group_id,
                                           #r_role_achievement.achieve_id,
                                           DBRoleAchievement#r_db_role_achievement.achievements) of
                            false ->
                                get_p_achievement_info(get_r_role_achievement(AchieveGroupConfig),AchieveGroupConfig);
                            GroupAchievementT ->
                                get_p_achievement_info(GroupAchievementT,AchieveGroupConfig)
                        end
            end,
            LatelyAchievements = [],StatInfo = [],
            ok;
       DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_LATELY ->
            Achievements = [],StatInfo = [],GroupAchievement = undefined,
            LatelyAchievements = 
                lists:map(
                  fun(RoleAchievementC) ->
                          AchieveConfigC = lists:keyfind(RoleAchievementC#r_role_achievement.achieve_id,
                                                         #r_achievement_config.achieve_id,AchievementConfigList),
                          case RoleAchievementC#r_role_achievement.achieve_type =:= ?ACHIEVEMENT_ACHIEVE_TYPE_RANK of
                              true ->
                                  LatelyAchievementRecordC = get_p_achievement_info(RoleAchievementC,AchieveConfigC),
                                  LatelyAchievementRecordC#p_achievement_info{role_id = RoleId,role_name = RoleName,faction_id = FactionId};
                              _ ->
                                  get_p_achievement_info(RoleAchievementC,AchieveConfigC)
                          end
                  end,lists:sublist(DBRoleAchievement#r_db_role_achievement.lately_achievements,1,MaxViewNumber)),
            ok;
       DataRecord#m_achievement_query_tos.op_type =:= ?ACHIEVEMENT_QUERY_OP_TYPE_OVERVIEW ->
            Achievements = [],GroupAchievement = undefined,
            LatelyAchievements = 
                lists:map(
                  fun(RoleAchievementD) ->
                          AchieveConfigD = lists:keyfind(RoleAchievementD#r_role_achievement.achieve_id,
                                                         #r_achievement_config.achieve_id,AchievementConfigList),
                          case RoleAchievementD#r_role_achievement.achieve_type =:= ?ACHIEVEMENT_ACHIEVE_TYPE_RANK of
                              true ->
                                  LatelyAchievementRecordD = get_p_achievement_info(RoleAchievementD,AchieveConfigD),
                                  LatelyAchievementRecordD#p_achievement_info{role_id = RoleId,role_name = RoleName,faction_id = FactionId};
                              _ ->
                                  get_p_achievement_info(RoleAchievementD,AchieveConfigD)
                          end
                  end,lists:sublist(DBRoleAchievement#r_db_role_achievement.lately_achievements,1,MaxViewNumber)),
            ClassIdList = 
                lists:foldl(
                  fun(#r_achievement_config{class_id = ClassIdA},AccClassIdList) ->
                          case lists:member(ClassIdA,AccClassIdList) of
                              true ->
                                  AccClassIdList;
                              _ ->
                                  [ClassIdA|AccClassIdList]
                          end
                  end,[],AchievementConfigList),
            StatInfo = 
                lists:map(
                  fun(ClassIdB) ->
                          case lists:keyfind(ClassIdB,#r_role_achievement_stat_info.type,DBRoleAchievement#r_db_role_achievement.stat_info) of
                              false ->
                                  StatInfoRecord = #r_role_achievement_stat_info{type = ClassIdB,cur_progress = 0,award_point = 0};
                              StatInfoRecord ->
                                  ignore
                          end,
                          get_p_achievement_stat_info(StatInfoRecord)
                  end,[0|ClassIdList]),
            ok;
       true ->
            Achievements = [],LatelyAchievements = [],StatInfo = [],GroupAchievement = undefined,
            ignore
    end,
    {ok,#p_role_base{achievement = AchievePoints}} = mod_map_role:get_role_base(RoleId),
    SendSelf = #m_achievement_query_toc{
      succ = true,
      op_type = DataRecord#m_achievement_query_tos.op_type,
      group_id = DataRecord#m_achievement_query_tos.group_id,
      achieve_ids = DataRecord#m_achievement_query_tos.achieve_ids,
      total_points = AchievePoints,
      achievements =Achievements,
      lately_achievements = LatelyAchievements,
      stat_info = StatInfo,
      group_achievement = GroupAchievement
     },
    ?DEBUG("~ts,RoleId=~w,Result=~w",["查询玩家成就状态返回结果",RoleId,SendSelf]),
    common_misc:unicast(Line,RoleId, Unique, Module, Method,SendSelf).

do_achievement_query_error({Unique, Module, Method, DataRecord, RoleId, Line},Reason) ->
    SendSelf = #m_achievement_query_toc{
      succ = false,reason = Reason,
      op_type = DataRecord#m_achievement_query_tos.op_type,
      group_id = DataRecord#m_achievement_query_tos.group_id,
      achieve_ids = DataRecord#m_achievement_query_tos.achieve_ids,
      total_points = 0,achievements =[]},
    ?DEBUG("~ts,RoleId=~w,Result=~w",["查询玩家成就状态返回结果",RoleId,SendSelf]),
    common_misc:unicast(Line,RoleId, Unique, Module, Method,SendSelf).

%% 查询成就榜
do_query_achievement_rank({Unique, Module, Method, DataRecord, RoleId,MapId}) ->
    case get_achievement_rank_dict(MapId) of
        undefined ->
            AchievementRankList = [];
        AchievementRankList ->
            ignore
    end,
    AchievementConfigList = 
        [AchievementConfigA 
         || AchievementConfigA <- common_config_dyn:list(achievement),
            AchievementConfigA#r_achievement_config.is_open =:= ?ACHIEVEMENT_IS_OPEN_OPEN,
            AchievementConfigA#r_achievement_config.group_id =:= DataRecord#m_achievement_query_tos.group_id,
            AchievementConfigA#r_achievement_config.achieve_type =:= ?ACHIEVEMENT_ACHIEVE_TYPE_RANK],
    PAchievementRankList = 
        lists:map(
          fun(AchievementConfig) ->
                  case lists:keyfind(AchievementConfig#r_achievement_config.achieve_id,#r_achievement_rank.achieve_id,AchievementRankList) of
                      false ->
                          AchievementRank = #r_achievement_rank{
                            achieve_id = AchievementConfig#r_achievement_config.achieve_id,
                            class_id = AchievementConfig#r_achievement_config.class_id,
                            group_id = AchievementConfig#r_achievement_config.group_id,
                            achieve_type = AchievementConfig#r_achievement_config.achieve_type,
                            status = 1,
                            event = [#r_role_achievement_event{
                                        event_id = ConfigEventId,
                                        event_status = 0} 
                                     || ConfigEventId <- AchievementConfig#r_achievement_config.event],
                            create_time = 0,
                            complete_time = 0,
                            award_time = 0,
                            cur_progress = 0,
                            total_progress = 0};
                      AchievementRank ->
                          ignore
                  end,
                  #p_achievement_info{
                    achieve_id = AchievementRank#r_achievement_rank.achieve_id,
                    status = AchievementRank#r_achievement_rank.status,
                    complete_time = AchievementRank#r_achievement_rank.complete_time,
                    cur_progress = 0,
                    total_progress = 0,
                    points = AchievementConfig#r_achievement_config.achieve_point,
                    pop_type = AchievementConfig#r_achievement_config.pop_type,
                    class_id = AchievementRank#r_achievement_rank.class_id,
                    group_id = AchievementRank#r_achievement_rank.group_id,
                    achieve_type = AchievementRank#r_achievement_rank.achieve_type,
                    role_id = AchievementRank#r_achievement_rank.role_id,
                    role_name = AchievementRank#r_achievement_rank.role_name,
                    faction_id = AchievementRank#r_achievement_rank.faction_id
                   }
          end,AchievementConfigList),
    SendSelf = #m_achievement_query_toc{
      succ = true,
      op_type = DataRecord#m_achievement_query_tos.op_type,
      group_id = DataRecord#m_achievement_query_tos.group_id,
      achieve_ids = DataRecord#m_achievement_query_tos.achieve_ids,
      rank_achievements = PAchievementRankList
     },
    ?DEBUG("~ts,RoleId=~w,Result=~w",["查询玩家成就状态返回结果",RoleId,SendSelf]),
    common_misc:unicast({role,RoleId}, Unique, Module, Method,SendSelf).

%% 完成成就事件通知
do_achievement_notice({Unique, Module, Method, DataRecord, RoleId, Line}) ->
    case catch do_achievement_notice2({Unique, Module, Method, DataRecord, RoleId, Line}) of 
        {error,Error} ->
            do_achievement_notice_error({Unique, Module, Method, DataRecord, RoleId, Line},Error);
        {ok, DBRoleAchievement} ->
            do_achievement_notice3({Unique, Module, Method, DataRecord, RoleId, Line},DBRoleAchievement)
    end.
do_achievement_notice2({_Unique, _Module, _Method, DataRecord, RoleId, _Line}) ->
    [IsOpenAchievementSystem] = common_config_dyn:find(etc,is_open_achievement_system),
    case IsOpenAchievementSystem of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_ACHIEVEMENT_NOT_OPEN})
    end,
    EventIds = DataRecord#m_achievement_notice_tos.event_ids,
    if erlang:is_list(EventIds) 
       andalso erlang:length(EventIds) > 0 ->
            next;
       true ->
            erlang:throw({error,?_LANG_ACHIEVEMENT_NOTICE_PARAM_ERROR})
    end,
    EventList = common_config_dyn:list(achievement_event),
    lists:foreach(
      fun(EventId) ->
              case lists:keyfind(EventId,#r_achievement_event.event_id,EventList) of
                  false ->
                      erlang:throw({error,?_LANG_ACHIEVEMENT_NOTICE_PARAM_ERROR});
                  _ ->
                      next
              end
      end,EventIds),
    DBRoleAchievement = 
        case get_role_achievement_info(RoleId) of
            {ok,DBRoleAchievementT} ->
                DBRoleAchievementT;
            _ ->
                #r_db_role_achievement{role_id = RoleId,achievements = [],lately_achievements = [],stat_info = []}
        end,
    AchievementConfigList = 
        lists:foldl(
          fun(ConfigRecord,AccAchievementConfigList) ->
                  case ConfigRecord#r_achievement_config.is_open =:= ?ACHIEVEMENT_IS_OPEN_OPEN
                      andalso ConfigRecord#r_achievement_config.achieve_type =:= ?ACHIEVEMENT_ACHIEVE_TYPE_GENERAL of
                      true ->
                          case lists:foldl(
                                 fun(ConfigEventId,AccAchievementConfigListFlag) ->
                                         case lists:member(ConfigEventId,EventIds) of
                                             true ->
                                                 true;
                                             _ ->
                                                 AccAchievementConfigListFlag
                                         end
                                 end,false,ConfigRecord#r_achievement_config.event) of
                              true ->
                                  [ConfigRecord|AccAchievementConfigList];
                              _ ->
                                  AccAchievementConfigList
                          end;
                      _ ->
                          AccAchievementConfigList
                  end
          end,[],common_config_dyn:list(achievement)),
    RoleAchievementList = 
        lists:foldl(
          fun(ConfigRecordT,AccRoleAchievementList) -> 
                  case lists:keyfind(ConfigRecordT#r_achievement_config.achieve_id, #r_role_achievement.achieve_id, AccRoleAchievementList) of
                      false ->
                          [get_r_role_achievement(ConfigRecordT)|AccRoleAchievementList];
                      _ ->
                          AccRoleAchievementList
                  end
          end,DBRoleAchievement#r_db_role_achievement.achievements,AchievementConfigList),
    {ok,DBRoleAchievement#r_db_role_achievement{achievements = RoleAchievementList}}.
do_achievement_notice3({Unique, Module, Method, DataRecord, RoleId, Line},DBRoleAchievement) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_achievement_notice(RoleId,DataRecord,DBRoleAchievement)
           end) of
        {atomic,{ok,CurRoleAchievementList}} ->
            do_achievement_notice4({Unique, Module, Method, DataRecord, RoleId, Line},CurRoleAchievementList);
        {aborted, Error} ->
            ?ERROR_MSG("~ts,Error=~w",["成就完成时更新成就状态出错",Error]),
            Reason = ?_LANG_ACHIEVEMENT_NOTICE_ERROR,
            do_achievement_notice_error({Unique, Module, Method, DataRecord, RoleId, Line},Reason)
    end.
do_achievement_notice4({Unique, Module, Method, _DataRecord, RoleId, Line},CurRoleAchievementList) ->
    case CurRoleAchievementList =/= [] of
        true ->
            %% 需要更新通知
            PAchievementList = 
                lists:foldl(
                  fun(RoleAchievement,AccPAchievementList) ->
                          [ConfigRecord] = common_config_dyn:find(achievement,RoleAchievement#r_role_achievement.achieve_id),
                          %% 成就称号奖励处理
                          case RoleAchievement#r_role_achievement.status =:= 2 
                              andalso ConfigRecord#r_achievement_config.achieve_title_code =/= 0 of
                              true ->
                                  catch common_title:add_title(?TITLE_ROLE_ACHIEVEMENT,RoleId,ConfigRecord#r_achievement_config.achieve_title_code);
                              _ ->
                                  ignore
                          end,
                          [get_p_achievement_info(RoleAchievement,ConfigRecord)|AccPAchievementList]
                  end,[],CurRoleAchievementList),
            AchievePoints = 
                case mod_map_role:get_role_base(RoleId) of
                    {ok,#p_role_base{achievement = AchievePointsT}} ->
                        AchievePointsT;
                    _ ->
                        0
                end,
            SendSelf = #m_achievement_notice_toc{
              type = 0,
              achievements = PAchievementList,
              total_points = AchievePoints
             },
            ?DEBUG("~ts,Result=~w",["成就完成自动通知结果为",SendSelf]),
            common_misc:unicast(Line,RoleId, Unique, Module, Method,SendSelf);
        _ ->
            %% 不需要更新通知
            next
    end.
        
do_achievement_notice_error({_Unique, _Module, _Method, DataRecord, RoleId, _Line},Reason) ->
    ?ERROR_MSG("~ts,,RoleId=~w,DataRecord=~w,Reason=~w",["完成某一成就事件出错",RoleId,DataRecord,Reason]),
    ok.
do_t_achievement_notice(RoleId,DataRecord,DBRoleAchievement) ->
    {RoleAchievementList, CurRoleAchievementList}= 
        lists:foldl(
          fun(RARecord,{AccRoleAchievementList,AccCurRoleAchievementList}) ->
                  case RARecord#r_role_achievement.status =:=2 orelse RARecord#r_role_achievement.status =:=3 of
                      true ->
                          {[RARecord|AccRoleAchievementList],AccCurRoleAchievementList};
                      _ ->
                          case lists:foldl(
                                 fun(RAREventRecord,AccRAREventRecord) ->
                                         case lists:member(RAREventRecord#r_role_achievement_event.event_id, 
                                                           DataRecord#m_achievement_notice_tos.event_ids) of
                                             true ->
                                                 true;
                                             _ ->
                                                 AccRAREventRecord
                                         end
                                 end,false,RARecord#r_role_achievement.event) of
                              true ->
                                  RARecord2 = do_t_achievement_notice2(RoleId,DataRecord,RARecord),
                                  {[RARecord2|AccRoleAchievementList],[RARecord2|AccCurRoleAchievementList]};
                              _ ->
                                  {[RARecord|AccRoleAchievementList],AccCurRoleAchievementList}
                          end
                  end
          end,{[],[]},DBRoleAchievement#r_db_role_achievement.achievements),
    case lists:foldl(
           fun(CurRoleAchievementRecord,AccAchievePoints) -> 
                   case CurRoleAchievementRecord#r_role_achievement.status =:= 2 of
                       true ->
                           [CurAchievementConfing] = common_config_dyn:find(achievement,CurRoleAchievementRecord#r_role_achievement.achieve_id),
                           AccAchievePoints +  CurAchievementConfing#r_achievement_config.achieve_point;
                       _ ->
                           AccAchievePoints
                   end
           end,0,CurRoleAchievementList) of
        0 ->
            AddTotalPoints = 0,
            ignore;
        AddTotalPoints ->
            {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
            mod_map_role:set_role_base(RoleId, RoleBase#p_role_base{achievement =  AddTotalPoints + RoleBase#p_role_base.achievement})
    end,
    %% 当前成就完成时需要处理成就组和成就总览数据更新
    CurCompleteAchievementList = [CurRoleAchievementRecordT 
                                  || CurRoleAchievementRecordT <- CurRoleAchievementList,
                                     CurRoleAchievementRecordT#r_role_achievement.status =:= 2],
    [{MaxKeepNumber,_MaxViewNumber}] = common_config_dyn:find(achievement_hook,lately_achievement_number),
    LatelyAchievements = lists:sublist(lists:append([CurCompleteAchievementList,DBRoleAchievement#r_db_role_achievement.lately_achievements]),1,MaxKeepNumber),
    StatInfoList= 
        lists:foldl(
          fun(CurRoleAchievementRecordB,AccStatInfoList) ->
                  [CurAchievementConfingB] = common_config_dyn:find(achievement,CurRoleAchievementRecordB#r_role_achievement.achieve_id),
                  case lists:keyfind(CurRoleAchievementRecordB#r_role_achievement.class_id,#r_role_achievement_stat_info.type,AccStatInfoList) of
                      false ->
                          [#r_role_achievement_stat_info{
                              type = CurRoleAchievementRecordB#r_role_achievement.class_id,
                              cur_progress = 1,
                              award_point = CurAchievementConfingB#r_achievement_config.achieve_point}|AccStatInfoList];
                      StatInfoRecord ->
                          [StatInfoRecord#r_role_achievement_stat_info{
                             cur_progress = StatInfoRecord#r_role_achievement_stat_info.cur_progress + 1,
                              award_point = StatInfoRecord#r_role_achievement_stat_info.award_point + 
                                 CurAchievementConfingB#r_achievement_config.achieve_point}|
                            lists:keydelete(CurRoleAchievementRecordB#r_role_achievement.class_id,#r_role_achievement_stat_info.type,AccStatInfoList)]
                  end
          end,DBRoleAchievement#r_db_role_achievement.stat_info,CurCompleteAchievementList),
    case lists:keyfind(0,#r_role_achievement_stat_info.type,StatInfoList) of
        false ->
            StatInfoList2 = [#r_role_achievement_stat_info{
                                type = 0,
                                cur_progress = erlang:length(CurCompleteAchievementList),
                                award_point = AddTotalPoints} | StatInfoList];
        OverviewStatInfoRecord ->
            StatInfoList2 = [OverviewStatInfoRecord#r_role_achievement_stat_info{
                               cur_progress = OverviewStatInfoRecord#r_role_achievement_stat_info.cur_progress + erlang:length(CurCompleteAchievementList),
                               award_point = OverviewStatInfoRecord#r_role_achievement_stat_info.award_point + AddTotalPoints} |
                             lists:keydelete(0,#r_role_achievement_stat_info.type,StatInfoList)]
    end,
    %% 判断成就组是否完成
    %% 查询出未完成的成就组列表数据
    CompleteGroupIdList =
        lists:foldl(
          fun(#r_role_achievement{group_id = GroupIdA},AccCompleteGroupIdList) ->
                  case lists:member(GroupIdA,AccCompleteGroupIdList) of
                      true ->
                          AccCompleteGroupIdList;
                      _ ->
                          case lists:keyfind(GroupIdA,#r_role_achievement.achieve_id,RoleAchievementList) of
                              false ->
                                  AccCompleteGroupIdList;
                              #r_role_achievement{status = GroupAchieveStatusA}->
                                  case GroupAchieveStatusA =:= 2 orelse GroupAchieveStatusA =:= 3 of
                                      true ->
                                          AccCompleteGroupIdList;
                                      _ ->
                                          [GroupIdA|AccCompleteGroupIdList]
                                  end
                          end
                  end
          end,[],CurCompleteAchievementList),
    %%?DEBUG("~ts,CompleteGroupIdList=~w",["可能需要处理的组成就id列表",CompleteGroupIdList]),
    CompleteGroupIdList2 = 
        lists:foldl(
          fun(GroupIdB,AccCompleteGroupIdList2) ->
                  case lists:foldl(
                         fun(CurRoleAchievementRecordC,IsCompleteGroupFlag) ->
                                 case CurRoleAchievementRecordC#r_role_achievement.group_id =:= GroupIdB of
                                     true ->
                                         case CurRoleAchievementRecordC#r_role_achievement.status =:= 2
                                             orelse CurRoleAchievementRecordC#r_role_achievement.status =:= 3 of
                                             true ->
                                                 IsCompleteGroupFlag;
                                             _ ->
                                                 false
                                         end;
                                     _ ->
                                         IsCompleteGroupFlag
                                 end 
                         end,true,RoleAchievementList) of
                      true -> %% 此组成就都完成
                          [GroupIdB|AccCompleteGroupIdList2];
                      _ ->
                          AccCompleteGroupIdList2
                  end
          end,[],CompleteGroupIdList),
    %% ?DEBUG("~ts,CompleteGroupIdList=~w",["已经完成的组成就id列表",CompleteGroupIdList2]),
    {RoleAchievementList2,CurRoleAchievementList2} =
        lists:foldl(
          fun(GroupIdC,{AccRoleAchievementList2,AccCurRoleAchievementList2}) ->
                  GroupRoleAchievementT = lists:keyfind(GroupIdC,#r_role_achievement.achieve_id,AccRoleAchievementList2),
                  GroupRoleAchievementT2 = GroupRoleAchievementT#r_role_achievement{
                                             status = 2,
                                             event = [EventRecord#r_role_achievement_event{event_status = 1}
                                                      || EventRecord <- GroupRoleAchievementT#r_role_achievement.event],
                                             complete_time = common_tool:now()},
                  {[GroupRoleAchievementT2|lists:keydelete(GroupIdC,#r_role_achievement.achieve_id,AccRoleAchievementList2)],
                   [GroupRoleAchievementT2|AccCurRoleAchievementList2]}
          end,{RoleAchievementList,CurRoleAchievementList},CompleteGroupIdList2),
    t_set_role_achievement_info(RoleId,DBRoleAchievement#r_db_role_achievement{
                                         achievements = RoleAchievementList2,
                                         lately_achievements = LatelyAchievements,
                                         stat_info = StatInfoList2
                                        }),	
    {ok,CurRoleAchievementList2}.
do_t_achievement_notice2(_RoleId,DataRecord,RARecord) ->
    EventIdList = DataRecord#m_achievement_notice_tos.event_ids,
    AddProgress = DataRecord#m_achievement_notice_tos.add_progress,
    #r_role_achievement{event = EventList,
                        cur_progress = CurProgress,
                        total_progress = TotalProgress} =  RARecord,
    if TotalProgress > 0 -> %% 按进度处理
            if (CurProgress + AddProgress) >= TotalProgress ->
                    %% 已经完成
                    RARecord#r_role_achievement{
                      cur_progress = TotalProgress,
                      total_progress = TotalProgress,
                      status = 2,
                      event = [EventRecord#r_role_achievement_event{event_status = 1}
                               || EventRecord <- EventList],
                      complete_time = common_tool:now()};
               true ->
                    %% 当前进度加1
                    RARecord#r_role_achievement{cur_progress = CurProgress + AddProgress}
            end;
       true -> %% 按事件完成处理
            EventList2 = 
                lists:foldl(
                  fun(EventId,Acc) ->
                          {AccEvent,_AccFlag} = 
                              lists:foldl(
                                fun(#r_role_achievement_event{event_id = SubEventId,event_status = EventStatus},{SubAcc,SubAccFlag})->
                                        if SubAccFlag =:= false andalso
                                           SubEventId =:= EventId andalso EventStatus =/= 1 ->
                                                {[#r_role_achievement_event{event_id = SubEventId,event_status = 1}|SubAcc],true};
                                           true ->
                                                {[#r_role_achievement_event{event_id = SubEventId,event_status = EventStatus}|SubAcc],SubAccFlag}
                                        end
                                end,{[],false},Acc),
                          AccEvent
                  end,EventList,EventIdList),
            %% 是否完成
            case  lists:foldl(
                    fun(ER,FlagAcc) ->
                            if ER#r_role_achievement_event.event_status =:= 0 ->
                                    false;  
                               true ->
                                    FlagAcc
                            end
                    end,true,EventList2) of
                true ->
                    RARecord#r_role_achievement{status = 2,event = EventList2,complete_time = common_tool:now()};
                false ->
                    RARecord#r_role_achievement{event = EventList2}
            end
    end.

%% 领取奖励
do_achievement_award({Unique, Module, Method, DataRecord, RoleId, Line}) ->
    case catch do_achievement_award2({Unique, Module, Method, DataRecord, RoleId, Line}) of 
        {error,Error} ->
            do_achievement_award_error({Unique, Module, Method, DataRecord, RoleId, Line},Error);
        {ok, DBRoleAchievement,RARecord,CARecord} ->
            do_achievement_award3({Unique, Module, Method, DataRecord, RoleId, Line},DBRoleAchievement,RARecord,CARecord)
    end.
do_achievement_award2({_Unique, _Module, _Method, DataRecord, RoleId, _Line}) ->
    [IsOpenAchievementSystem] = common_config_dyn:find(etc,is_open_achievement_system),
    case IsOpenAchievementSystem of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_ACHIEVEMENT_NOT_OPEN})
    end,
    AchieveId = DataRecord#m_achievement_award_tos.achieve_id,
    if AchieveId =/= 0 -> 
            next;
       true ->
            erlang:throw({error,?_LANG_ACHIEVEMENT_AWARD_PARAM_ERROR})
    end,
    CARecord = 
        case get_achievement_config(AchieveId) of
            {ok, CAR} ->
                CAR;
            {error,_CARError} ->
                erlang:throw({error,?_LANG_ACHIEVEMENT_AWARD_PARAM_ERROR})
        end,
    case CARecord#r_achievement_config.items of
        undefined ->
            erlang:throw({error,?_LANG_ACHIEVEMENT_AWARD_ITEM_EMPTY});
        [] ->
            erlang:throw({error,?_LANG_ACHIEVEMENT_AWARD_ITEM_EMPTY});
        _ ->
            next
    end,
    {DBRoleAchievement,RARecord} = 
        case get_role_achievement_info(RoleId) of
            {ok,DBRoleAchievementT} ->
                case lists:keyfind(AchieveId,#r_role_achievement.achieve_id,DBRoleAchievementT#r_db_role_achievement.achievements) of
                    false ->
                        erlang:throw({error,?_LANG_ACHIEVEMENT_AWARD_STATUS_1_ERROR});
                    RoleAchievementT ->
                        {DBRoleAchievementT,RoleAchievementT}
                end;
            _ ->
                erlang:throw({error,?_LANG_ACHIEVEMENT_AWARD_PARAM_ERROR})
        end,
    if RARecord#r_role_achievement.status =:= 3 ->
            erlang:throw({error,?_LANG_ACHIEVEMENT_AWARD_STATUS_3_ERROR});
       RARecord#r_role_achievement.status =:= 1 ->
            erlang:throw({error,?_LANG_ACHIEVEMENT_AWARD_STATUS_1_ERROR});
       RARecord#r_role_achievement.status =:= 2 ->
            next;
       true ->
            erlang:throw({error,?_LANG_ACHIEVEMENT_AWARD_STATUS_ERROR})
    end,
    {ok,DBRoleAchievement,RARecord,CARecord}.

do_achievement_award3({Unique, Module, Method, DataRecord, RoleId, Line},DBRoleAchievement,RARecord,CARecord) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_achievement_award(RoleId,DataRecord,DBRoleAchievement,RARecord,CARecord)
           end) of
        {atomic,{ok,GoodsList,LogGoodsList}} ->
            do_achievement_award4({Unique, Module, Method, DataRecord, RoleId, Line},
                                  CARecord,GoodsList,LogGoodsList);
        {aborted, Error} ->
            Reason = 
                case Error of 
                    {bag_error,BR} ->
                        case BR of
                            not_enough_pos ->
                                ?_LANG_ACHIEVEMENT_AWARD_BAG_ERROR;
                            _ ->
                                ?_LANG_ACHIEVEMENT_AWARD_ERROR
                        end;
                    {error,R} ->
                        R;
                    _ ->
                        ?_LANG_ACHIEVEMENT_AWARD_ERROR
                end,
            do_achievement_award_error({Unique, Module, Method, DataRecord, RoleId, Line},Reason)
    end.

do_achievement_award4({Unique, Module, Method, DataRecord, RoleId, Line},
                      CARecord,GoodsList,LogGoodsList) ->
    %% 通知背包道具变化
    %% ?DEBUG("~ts,GoodsList=~w",["获取奖励物品信息如下",GoodsList]),
    if erlang:length(GoodsList) > 0 ->
            %%记录道具奖励
            lists:foreach(
              fun(Goods)->
                      common_item_logger:log(RoleId,Goods,?LOG_ITEM_TYPE_XIN_SHOU_MU_BIAO_JIANG_PIN)
              end,LogGoodsList),
            common_misc:update_goods_notify({line, Line, RoleId},GoodsList);
       true ->
            next
    end,
    %% 判断是否是成就榜成就，需要更新成就榜成就状态
    case CARecord#r_achievement_config.achieve_type =:= ?ACHIEVEMENT_ACHIEVE_TYPE_RANK of
        true -> %% 需要更新
            [AchievementRankMapId] = common_config_dyn:find(achievement_hook,achievement_rank_map_id),
            catch global:send(common_map:get_common_map_name(AchievementRankMapId),
                              {mod_achievement,
                               {update_achievement_award_status,
                                {RoleId,CARecord#r_achievement_config.achieve_id,AchievementRankMapId}}});
        _ ->
            ignore
    end,  
    SendSelf = #m_achievement_award_toc{
      succ = true,
      achieve_id = DataRecord#m_achievement_award_tos.achieve_id,
      group_id = CARecord#r_achievement_config.group_id,
      class_id = CARecord#r_achievement_config.class_id},
    ?DEBUG("~ts,Result=~w",["返回结果为",SendSelf]),
    common_misc:unicast(Line,RoleId, Unique, Module, Method, SendSelf).

do_achievement_award_error({Unique, Module, Method, DataRecord, RoleId, Line},Reason) ->
    SendSelf = #m_achievement_award_toc{
      succ = false,
      reason = Reason,
      achieve_id = DataRecord#m_achievement_award_tos.achieve_id},
    ?DEBUG("~ts,Result=~w",["返回结果为",SendSelf]),
    common_misc:unicast(Line,RoleId, Unique, Module, Method,SendSelf).

do_t_achievement_award(RoleId,_DataRecord,DBRoleAchievement,RARecord,CARecord) ->
    RARecord2 = RARecord#r_role_achievement{status = 3,award_time = common_tool:now()},
    AchievementList = lists:keydelete(RARecord#r_role_achievement.achieve_id,#r_role_achievement.achieve_id,
                                      DBRoleAchievement#r_db_role_achievement.achievements),
    LatelyAchievementList = 
        case lists:keyfind(RARecord2#r_role_achievement.achieve_id,#r_role_achievement.achieve_id,
                           DBRoleAchievement#r_db_role_achievement.lately_achievements) of
            false ->
                DBRoleAchievement#r_db_role_achievement.lately_achievements;
            _ ->
                lists:keyreplace(RARecord2#r_role_achievement.achieve_id,#r_role_achievement.achieve_id,
                                 DBRoleAchievement#r_db_role_achievement.lately_achievements,RARecord2)
        end,
    t_set_role_achievement_info(RoleId,DBRoleAchievement#r_db_role_achievement{
                                         achievements = [RARecord2|AchievementList],
                                         lately_achievements = LatelyAchievementList
                                        }),
    %% 创建物品
    {GoodsList,LogGoodsList} = 
        lists:foldl(
          fun(RAchievementItem,Acc) ->
                  {CAccList,LAccList} = Acc,
                  CreateGoodsList = do_t_achievement_award2(RoleId,RAchievementItem),
                  [H|_T] = CreateGoodsList,
                  NewH = H#p_goods{current_num = RAchievementItem#r_achievement_item.number},
                  CAccList2 = lists:append([CreateGoodsList,CAccList]),
                  {CAccList2,[NewH|LAccList]}
          end,{[],[]},CARecord#r_achievement_config.items),
    {ok,GoodsList,LogGoodsList}.

do_t_achievement_award2(RoleId,RAchievementItem) ->
    Bind = if RAchievementItem#r_achievement_item.bind =:= 0 ->
                   false;
              RAchievementItem#r_achievement_item.bind =:= 100 ->
                   true;
              true ->
                   RandomNumber = random:uniform(100),
                   if  RAchievementItem#r_achievement_item.bind >= RandomNumber ->
                           true;
                       true ->
                           false
                   end
           end,
    ItemType = RAchievementItem#r_achievement_item.item_type,
    CreateInfo = 
        if ItemType =:= ?TYPE_EQUIP ->
                ColorList = RAchievementItem#r_achievement_item.color,
                Color = mod_refining:get_random_number(ColorList,0,1),
                QualityList = RAchievementItem#r_achievement_item.quality,
                Quality = mod_refining:get_random_number(QualityList,0,1),
                #r_goods_create_info{
                                      type=ItemType,
                                      type_id=RAchievementItem#r_achievement_item.item_id,
                                      num=RAchievementItem#r_achievement_item.number,
                                      bind=Bind,
                                      color = Color,
                                      quality = Quality,         
                                      interface_type=achievement};
           true ->
                #r_goods_create_info{
             type=ItemType,
             type_id=RAchievementItem#r_achievement_item.item_id,
             num=RAchievementItem#r_achievement_item.number,
             bind=Bind}
        end,
    {ok,GoodsList} = mod_bag:create_goods(RoleId,CreateInfo),
    GoodsList.

get_achievement_config(AchieveId) ->
    case common_config_dyn:find(achievement,AchieveId) of
        [ConfigRecord] ->
            {ok,ConfigRecord};
        _ ->
            {error,not_found}
    end.
get_r_role_achievement(ConfigRecord) ->
    Record = #r_role_achievement{
      achieve_id = ConfigRecord#r_achievement_config.achieve_id,
      class_id = ConfigRecord#r_achievement_config.class_id,
      group_id = ConfigRecord#r_achievement_config.group_id,
      achieve_type = ConfigRecord#r_achievement_config.achieve_type,
      status = 1,
      event = [],
      create_time = common_tool:now(),
      complete_time = 0,
      award_time = 0,
      cur_progress = 0,
      total_progress = ConfigRecord#r_achievement_config.total_progress
     },
    Events = ConfigRecord#r_achievement_config.event,
    if erlang:is_list(Events) 
       andalso erlang:length(Events) > 0 ->
            Events2 = [#r_role_achievement_event{
                          event_id = EventId,
                          event_status = 0}||EventId <- Events],
            Record#r_role_achievement{event = Events2};
       true ->
            Record
    end.
get_p_achievement_info(RoleAchievement,ConfigRecord) ->
    #p_achievement_info{
                        achieve_id = RoleAchievement#r_role_achievement.achieve_id,
                        status = RoleAchievement#r_role_achievement.status,
                        complete_time = RoleAchievement#r_role_achievement.complete_time,
                        cur_progress = RoleAchievement#r_role_achievement.cur_progress,
                        total_progress = RoleAchievement#r_role_achievement.total_progress,
                        points = ConfigRecord#r_achievement_config.achieve_point,
                        pop_type = ConfigRecord#r_achievement_config.pop_type,
                        class_id = ConfigRecord#r_achievement_config.class_id,
                        group_id = ConfigRecord#r_achievement_config.group_id,
                        achieve_type = ConfigRecord#r_achievement_config.achieve_type
                       }.
get_p_achievement_stat_info(StatInfoRecord) ->
    case common_config_dyn:find(achievement_hook,{achievement_number,StatInfoRecord#r_role_achievement_stat_info.type}) of
        [TotalProgress] when erlang:is_integer(TotalProgress) ->
            ignore;
        _ ->
            TotalProgress = 0
    end,
    #p_achievement_stat_info{
      type = StatInfoRecord#r_role_achievement_stat_info.type,
      cur_progress = StatInfoRecord#r_role_achievement_stat_info.cur_progress,
      total_progress = TotalProgress,
      award_point = StatInfoRecord#r_role_achievement_stat_info.award_point
     }.
