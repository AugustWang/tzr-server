%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright (C) www.mingchao.com 2011, 
%%% @doc
%%% 组队进程
%%% @end
%%% Created :  6 Jul 2011 by  <caochuncheng2002@gmail.com>
%%%-------------------------------------------------------------------
-module(mod_team).

-behaviour(gen_server).

-include("mgeew.hrl").

%% API
-export([start_link/1,
         check_valid_distance/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {}).

%% r_team_state
-define(team_state_dict,team_state_dict).
get_team_state() ->
    erlang:get(?team_state_dict).

set_team_state(TeamState) ->
    erlang:put(?team_state_dict,TeamState).

%%%===================================================================
%%% API
%%%===================================================================
start_link({create,RoleId,Unique,Module,Method,DataRecord,TeamId,TeamProccess,CreateTeamInfo}) ->
    gen_server:start_link({global,TeamProccess},?MODULE,
                          {create,RoleId,Unique,Module,Method,DataRecord,TeamId,TeamProccess,CreateTeamInfo},[]);
start_link({accept,RoleId,Unique,Module,Method,DataRecord,TeamId,TeamProccess,CreateTeamInfo,MemberTeamInfo}) ->
    gen_server:start_link({global,TeamProccess},?MODULE,
                          {accept,RoleId,Unique,Module,Method,DataRecord,TeamId,TeamProccess,CreateTeamInfo,MemberTeamInfo},[]).

init({create,RoleId,Unique,Module,Method,DataRecord,TeamId,TeamProccess,CreateTeamInfo}) ->
    case CreateTeamInfo =/= undefined 
        andalso common_misc:is_role_online(CreateTeamInfo#p_team_role.role_id) of
        true ->
            init2(create,{RoleId,Unique,Module,Method,DataRecord,TeamId,TeamProccess,CreateTeamInfo});
        _ ->
            ?ERROR_MSG(" ~ts ",["在创建队伍时,玩家突然不在线,无法创建队伍"]),
            {error,?_LANG_TEAM_CREATE_FAIL_OFFLINE}
    end;
init({accept,RoleId,Unique,Module,Method,DataRecord,TeamId,TeamProccess,CreateTeamInfo,MemberTeamInfo}) ->
    case CreateTeamInfo =/= undefined 
        andalso common_misc:is_role_online(CreateTeamInfo#p_team_role.role_id) of
        true ->
            init2(accept,{RoleId,Unique,Module,Method,DataRecord,TeamId,TeamProccess,CreateTeamInfo,MemberTeamInfo});
        _ ->
            ?ERROR_MSG(" ~ts ",["在创建队伍时,玩家突然不在线,无法创建队伍"]),
            {error,?_LANG_TEAM_CREATE_FAIL_OFFLINE}
    end.
init2(create,{_RoleId,Unique,Module,Method,DataRecord,TeamId,TeamProccess,CreateTeamInfo}) ->
    TeamRoleList = [CreateTeamInfo#p_team_role{is_leader = true}],
    TeamState = #r_team_state{
      team_id = TeamId,
      proccess_name = TeamProccess, 
      pick_type = 1, 
      exp_type = 1, 
      leader_role_id = CreateTeamInfo#p_team_role.role_id, 
      team_role_list = TeamRoleList, create_time = common_tool:now()},
    set_team_state(TeamState),
    update_map_role_team_data({CreateTeamInfo#p_team_role.role_id,TeamId,TeamProccess,1,TeamRoleList}),
    SendCreate=#m_team_create_toc{
      role_id = DataRecord#m_team_create_tos.role_id,
      succ = true,
      role_list = TeamRoleList,
      pick_type = 1,
      team_id = TeamId
     },
    ?DEBUG("~ts,RoleId=~w,SendSelf=~w",["组队模块 Create",CreateTeamInfo#p_team_role.role_id,SendCreate]),
    common_misc:unicast({role, CreateTeamInfo#p_team_role.role_id}, Unique, Module, Method, SendCreate),
    %% 开始循环
    [Interval] = common_config_dyn:find(team,team_proccess_loop_interval),
    erlang:send_after(Interval, self(), {team_procces_loop}),
    {ok, #state{}};
init2(accept,{RoleId,Unique,Module,Method,DataRecord,TeamId,TeamProccess,CreateTeamInfo,MemberTeamInfo}) ->
    TeamRoleList = 
        case MemberTeamInfo of
            undefined ->
                [CreateTeamInfo#p_team_role{is_leader = true}];
            _ ->
                [CreateTeamInfo#p_team_role{is_leader = true},MemberTeamInfo#p_team_role{is_leader = false}]
        end,
    TeamState = #r_team_state{
      team_id = TeamId,
      proccess_name = TeamProccess, 
      pick_type = 1, 
      exp_type = 1, 
      leader_role_id = CreateTeamInfo#p_team_role.role_id, 
      team_role_list = TeamRoleList, create_time = common_tool:now()},
    set_team_state(TeamState),
    %% 创建队伍成功，通知玩家地图进程消息
    case MemberTeamInfo =/= undefined andalso  RoleId =:= MemberTeamInfo#p_team_role.role_id of
        true -> %% 邀请时创建队伍
            update_map_role_team_data({MemberTeamInfo#p_team_role.role_id,TeamId,TeamProccess,1,TeamRoleList}),
            SendMember=#m_team_accept_toc{succ=true,
                                          return_self = true,
                                          role_list = TeamRoleList,
                                          team_id= TeamId,
                                          pick_type = 1, 
                                          type_id=DataRecord#m_team_accept_tos.type_id},
            ?DEBUG("~ts,RoleId=~w,SendSelf=~w",["组队模块Accept",RoleId,SendMember]),
            common_misc:unicast({role, RoleId}, Unique, Module, Method, SendMember),
            ok;
        _ -> %% 独立创建队伍，未支持
            ignore
    end,
    update_map_role_team_data({CreateTeamInfo#p_team_role.role_id,TeamId,TeamProccess,1,TeamRoleList}),
    SendCreate=#m_team_accept_toc{succ=true,
                                  return_self = false,
                                  role_list = TeamRoleList,
                                  team_id= TeamId,
                                  pick_type = 1, 
                                  role_id = RoleId,
                                  role_name = MemberTeamInfo#p_team_role.role_name, 
                                  type_id=DataRecord#m_team_accept_tos.type_id},
    ?DEBUG("~ts,RoleId=~w,SendSelf=~w",["组队模块Accept",CreateTeamInfo#p_team_role.role_id,SendCreate]),
    common_misc:unicast({role, CreateTeamInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendCreate),
    %% 开始循环
    [Interval] = common_config_dyn:find(team,team_proccess_loop_interval),
    case MemberTeamInfo =/= undefined andalso DataRecord#m_team_accept_tos.type_id > 0 
        andalso RoleId =:= MemberTeamInfo#p_team_role.role_id of
        true ->
            catch common_misc:send_to_rolemap(RoleId, {mod_educate, {set_can_jump, RoleId}}),
            catch common_misc:send_to_rolemap(DataRecord#m_team_accept_tos.role_id, {mod_educate, {set_can_jump, DataRecord#m_team_accept_tos.role_id}});
        _ ->
            ignore
    end,
    erlang:send_after(Interval, self(), {team_procces_loop}),
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({kill_team_proccess,Reason},State) ->
    ?DEBUG("~ts,Reason=~w,State=~w",["队伍进程退出",Reason,State]),
    {stop, normal, State};

handle_info(Info, State) ->
    try 
        do_handle_info(Info)
    catch
        T:R ->
            ?ERROR_MSG("module: ~w, line: ~w, Info:~w, type: ~w, reason: ~w,stactraceo: ~w",
                       [?MODULE, ?LINE, Info, T, R, erlang:get_stacktrace()])
    end,
    {noreply, State}.
terminate(_Reason, _State) ->
    ok.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% 同步玩家地图进程中的玩家组队信息
update_map_role_team_data({RoleId,TeamId,ProccessName,PickType,TeamRoleList})->
    catch common_misc:send_to_rolemap(
      RoleId,{mod_map_team,{team_proccess_update_data,
                            {RoleId,TeamId,ProccessName,PickType,TeamRoleList}}}).
%% 同步玩家地图进程中玩家组队操作状态
update_map_role_team_do_status({RoleId,DoStatus}) ->
    catch common_misc:send_to_rolemap(RoleId,{mod_map_team,{admin_update_do_status,{RoleId,DoStatus}}}).

update_map_role_team_pick_type({RoleId,LeaderRoleId,PickType}) ->
    catch common_misc:send_to_rolemap(RoleId,{mod_map_team,{admin_update_pick_type,{RoleId,LeaderRoleId,PickType}}}).

do_handle_info({team_procces_loop}) ->
    [Interval] = common_config_dyn:find(team,team_proccess_loop_interval),
    erlang:send_after(Interval, self(), {team_procces_loop}),
    do_team_procces_loop();

%% 地图进程向队伍进程发送队员信息数据
do_handle_info({sync_team_data,Msg}) ->
    do_sync_team_data(Msg);

%% 添加外部操作本进程内部执行接口
do_handle_info({func, Fun, Args}) ->
    Ret =(catch apply(Fun,Args)),
    ?ERROR_MSG("~w",[Ret]);
%% 加入队伍
do_handle_info({accept,Msg}) ->
    do_accept(Msg);
%% 离开队伍
do_handle_info({leave,Msg}) ->
    do_leave(Msg);
%% 设置队伍拾取模式
do_handle_info({pick,Msg}) ->
    do_pick(Msg);
%% 请离队员
do_handle_info({kick,Msg}) ->
    do_kick(Msg);
%% 移交队长
do_handle_info({change_leader,Msg}) ->
    do_change_leader(Msg);
%% 解散队伍
do_handle_info({disband,Msg}) ->
    do_disband(Msg);
%% 队长同意队员入队消息处理
do_handle_info({apply,Msg}) ->
    do_apply(Msg);

%% 玩家下线
do_handle_info({offline,Msg}) ->
    do_offline(Msg);
%% 玩家上线
do_handle_info({online,Msg}) ->
    do_online(Msg);

do_handle_info(Info) ->
    ?ERROR_MSG("组队进程无法处理此消息 Info=~w",[Info]),
    ok.

%% 地图进程向队伍进程发送队员信息数据
%% TeamSyncDataList结构为 [r_role_team_sync_data,...]
do_sync_team_data({[]}) ->
    ok;
do_sync_team_data({TeamSyncDataList}) ->
    TeamState = get_team_state(),
    TeamRoleList = 
        lists:map(
          fun(TeamRoleInfo) ->
                  case lists:keyfind(TeamRoleInfo#p_team_role.role_id,#r_role_team_sync_data.role_id,TeamSyncDataList) of
                      false ->
                          TeamRoleInfo; 
                      TeamSyncData ->
                          get_team_role_info_by_sync_data(TeamRoleInfo,TeamSyncData)
                  end
          end,TeamState#r_team_state.team_role_list),
    set_team_state(TeamState#r_team_state{team_role_list = TeamRoleList}),
    ok.

%% 队伍进程大循环消息处理
do_team_procces_loop() ->
    TeamState = get_team_state(),
    %%?DEBUG("TeamState=~w",[TeamState]),
    NowSeconds = common_tool:now(),
    %% 玩家下线缓存处理
    {OfflineRoleList,TeamRoleList} = 
        lists:foldl(
          fun(TeamRoleInfo,{AccOfflineRoleList,AccTeamRoleList}) ->
                  case TeamRoleInfo#p_team_role.is_offline =:= true 
                      andalso common_misc:is_role_online(TeamRoleInfo#p_team_role.role_id) =:= false
                      andalso NowSeconds > TeamRoleInfo#p_team_role.offline_time of 
                      true ->
                          {[TeamRoleInfo|AccOfflineRoleList],AccTeamRoleList};
                      _ ->
                          {AccOfflineRoleList,lists:append([AccTeamRoleList,[TeamRoleInfo]])}
                  end
          end,{[],[]},TeamState#r_team_state.team_role_list),
    %% 判断是否队长离线时间到了
    IsLeaderOffline = 
        lists:foldl(
          fun(OfflineRoleInfoT,AccIsLeaderOffline) ->
                  if OfflineRoleInfoT#p_team_role.role_id =:= TeamState#r_team_state.leader_role_id ->
                          true;
                     true ->
                          AccIsLeaderOffline
                  end
          end,false,OfflineRoleList),
    [MinTeamMemberCount] = common_config_dyn:find(team,min_member_count),
    %% 新队长处理
    TeamRoleList2 = 
        case IsLeaderOffline =:= true andalso erlang:length(TeamRoleList) >= MinTeamMemberCount of
            true ->
                [HTeamRoleInfo|TTeamRoleInfoList] = TeamRoleList,
                NewLeaderRoleId = HTeamRoleInfo#p_team_role.role_id,
                [HTeamRoleInfo#p_team_role{is_leader = true}|TTeamRoleInfoList];
            _ ->
                NewLeaderRoleId = TeamState#r_team_state.leader_role_id,
                TeamRoleList
        end,
    %% 判断是否还有离线的玩家需要处理
    [OfflineCacheTime] = common_config_dyn:find(team,offline_cache_time),
    TeamRoleList3 = 
        lists:foldl(
          fun(TeamRoleInfoT,AccTeamRoleList3) ->
                  case TeamRoleInfoT#p_team_role.is_offline =:= false
                      andalso common_misc:is_role_online(TeamRoleInfoT#p_team_role.role_id) =:= false of
                      true ->
                          lists:append([AccTeamRoleList3,[TeamRoleInfoT#p_team_role{is_offline = true,offline_time = NowSeconds + OfflineCacheTime}]]);
                      _ ->
                          lists:append([AccTeamRoleList3,[TeamRoleInfoT]])
                  end
          end,[],TeamRoleList2),
    %% 通知当前队伍玩家下线离队玩家信息，同步在线玩家
    %% 计算五行属性，
    TeamRoleList4 = calc_team_five_ele_attr(TeamRoleList3),
    lists:foreach(
      fun(#p_team_role{role_id = SyncMapRoleId,is_offline = SyncMapIsOffline}) ->
              if SyncMapIsOffline =/= true ->
                      catch update_map_role_team_data({SyncMapRoleId,TeamState#r_team_state.team_id,
                                                       TeamState#r_team_state.proccess_name,
                                                       TeamState#r_team_state.pick_type,TeamRoleList4});
                 true ->
                      ignore
              end
      end,TeamRoleList4),
    %% 处理下线缓存时间到了的玩家
    lists:foreach(
      fun(OfflineRoleInfo) ->
              SendOffline = #m_team_offline_toc{
                role_list = TeamRoleList4,
                role_id = OfflineRoleInfo#p_team_role.role_id,
                role_name = OfflineRoleInfo#p_team_role.role_name,
                team_id = TeamState#r_team_state.team_id},
              lists:foreach(
                fun(#p_team_role{role_id = OnlineRoleId,is_offline = OnlineIsOffline}) ->
                        if OnlineIsOffline =/= true ->
                                catch common_misc:unicast({role,OnlineRoleId},?DEFAULT_UNIQUE,?TEAM,?TEAM_OFFLINE,SendOffline);
                           true ->
                                ignore
                        end
                end,TeamRoleList4),
              catch do_leave_team_by_offline(OfflineRoleInfo#p_team_role.role_id),
              %% 玩家已经下线，不需要处理
              %% catch mod_team_buff:handle({delete_role_team_buff,OfflineRoleInfo#p_team_role.role_id}),
              ok
      end,OfflineRoleList),
    %% 计算可见列表
    lists:foreach(
      fun(TeamRoleInfoTT) ->
              case TeamRoleInfoTT#p_team_role.is_offline =:= true of
                  true -> 
                      ignore;
                  _ ->
                      SendAll = #m_team_auto_list_toc{
                        return_self = false, 
                        team_id = TeamState#r_team_state.team_id, 
                        role_list = TeamRoleList4, 
                        pick_type = TeamState#r_team_state.pick_type, 
                        visible_role_list= calc_team_visible_role_list(TeamRoleInfoTT#p_team_role.role_id,TeamRoleList4)},
                      common_misc:unicast({role,TeamRoleInfoTT#p_team_role.role_id},?DEFAULT_UNIQUE, ?TEAM,?TEAM_AUTO_LIST,SendAll)
              end
      end,TeamRoleList4),
    %% 判断是否需要结束此队伍进程
    case erlang:length(TeamRoleList4) < MinTeamMemberCount of
        true ->
            SendAutoDisband = #m_team_auto_disband_toc{succ = true,reason = ?_LANG_TEAM_AUTO_DISBAND},
            lists:foreach(
              fun(TeamRoleInfoTTT) ->
                      case TeamRoleInfoTTT#p_team_role.is_offline =:= false of
                          true ->
                              update_map_role_team_data({TeamRoleInfoTTT#p_team_role.role_id,0,undefined,1,[]}),
                              catch mod_team_buff:handle({delete_role_team_buff,TeamRoleInfoTTT#p_team_role.role_id}),
                              catch common_misc:unicast({role,TeamRoleInfoTTT#p_team_role.role_id}, ?DEFAULT_UNIQUE, ?TEAM, ?TEAM_AUTO_DISBAND, SendAutoDisband);
                          _ ->
                              catch do_leave_team_by_offline(TeamRoleInfoTTT#p_team_role.role_id)
                              %% catch mod_team_buff:handle({delete_role_team_buff,TeamRoleInfoTTT#p_team_role.role_id})
                      end
              end,TeamRoleList4),
            erlang:send(self(),{kill_team_proccess,<<"有人离开队伍，队伍人数不够人即自动散落队伍">>});
        _ ->
            ignore
    end,
    case TeamRoleList4 =/= [] of
        true ->
            case erlang:length(TeamRoleList4) =:= 1 of
                true -> %% 当队伍成员只有一个人时，需要删除buff
                    [TeamRoleInfoTTTT] = TeamRoleList4,
                    catch mod_team_buff:handle({delete_role_team_buff,TeamRoleInfoTTTT#p_team_role.role_id});
                _ -> %% 组队相关状态处理
                    catch mod_team_buff:handle({TeamRoleList4})
            end;
        _ ->
            ignore
    end,
    set_team_state(TeamState#r_team_state{team_role_list = TeamRoleList4,leader_role_id = NewLeaderRoleId}),
    ok.

%% 当玩家不在线并且离队时需要处理，重置玩家队伍id,删除玩家组队状态
do_leave_team_by_offline(RoleId) ->
    case common_misc:get_dirty_role_base(RoleId) of
        {ok,RoleBase} ->
            do_leave_team_by_offline2(RoleId,RoleBase);
        _ ->
            ignore
    end.
do_leave_team_by_offline2(RoleId,RoleBase) ->
    case common_misc:is_role_online(RoleId) of
        true ->
            update_map_role_team_data({RoleId,0,undefined,1,[]});
        _ ->
            [TeamBuffTypeList] = common_config_dyn:find(team, team_buff_type_list),
            NewBuffList = [PActorBuf || PActorBuf <- RoleBase#p_role_base.buffs,
                                        lists:member(PActorBuf#p_actor_buf.buff_type,TeamBuffTypeList) =:= false],
            db:dirty_write(?DB_ROLE_BASE,RoleBase#p_role_base{buffs = NewBuffList,team_id = 0})
    end.

%% 玩家加入队伍处理
do_accept({Unique,Module,Method,DataRecord,RoleId,PId,RoleTeamInfo}) ->
    case catch do_accept2(RoleId,DataRecord) of
        {error,Reason} ->
            update_map_role_team_do_status({RoleId,?TEAM_DO_STATUS_NORMAL}),
            do_accept_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok} ->
            do_accept3({Unique, Module, Method, DataRecord, RoleId, PId},RoleTeamInfo)
    end.
do_accept2(RoleId,_DataRecord) ->
    #r_team_state{team_role_list = TeamRoleList} = get_team_state(),
    [MaxMemberCount] = common_config_dyn:find(team,max_member_count),
    case erlang:length(TeamRoleList) >= MaxMemberCount of
        true ->
            erlang:throw({error,?_LANG_TEAM_ACCEPT_FAIL_MAX_LIMIT});
        _ ->
            next
    end,
    case lists:keyfind(RoleId,#p_team_role.role_id,TeamRoleList) of
        false ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_ACCEPT_REPEAT})
    end,
    {ok}.
do_accept3({Unique, Module, Method, DataRecord, RoleId, PId},RoleTeamInfo) ->
    TeamState = get_team_state(),
    TeamRoleList = lists:append([TeamState#r_team_state.team_role_list,[RoleTeamInfo]]),
    set_team_state(TeamState#r_team_state{team_role_list = TeamRoleList}),
    update_map_role_team_data({RoleId,TeamState#r_team_state.team_id,
                              TeamState#r_team_state.proccess_name,
                              TeamState#r_team_state.pick_type,TeamRoleList}),
    SendSelf=#m_team_accept_toc{succ=true,
                                return_self = true,
                                role_list = TeamRoleList,
                                team_id= TeamState#r_team_state.team_id,
                                pick_type = TeamState#r_team_state.pick_type, 
                                type_id= DataRecord#m_team_accept_tos.type_id},
    ?DEBUG("~ts,RoleId=~w,SendSelf=~w",["组队模块Accept",RoleId,SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    %% 通知其它队员有玩家加入队伍
    SendMember=#m_team_accept_toc{succ=true,
                                  return_self = false,
                                  role_list = TeamRoleList,
                                  team_id= TeamState#r_team_state.team_id,
                                  pick_type = TeamState#r_team_state.pick_type, 
                                  role_id = RoleId,
                                  role_name = RoleTeamInfo#p_team_role.role_name, 
                                  type_id=DataRecord#m_team_accept_tos.type_id},
    lists:foreach(
      fun(MTeamInfo) ->
              case MTeamInfo#p_team_role.is_offline =:= false of
                  true ->
                      update_map_role_team_data({MTeamInfo#p_team_role.role_id,TeamState#r_team_state.team_id,
                                                 TeamState#r_team_state.proccess_name,
                                                 TeamState#r_team_state.pick_type,TeamRoleList}),
                      common_misc:unicast({role,MTeamInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendMember);
                  _ ->
                      ignore
              end
      end,TeamState#r_team_state.team_role_list),
    ok.

do_accept_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf=#m_team_accept_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Accept",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

do_leave({Unique,Module,Method,DataRecord,RoleId,PId}) ->
    #r_team_state{team_role_list = TeamRoleList} = TeamState = get_team_state(),
    case lists:keyfind(RoleId,#p_team_role.role_id,TeamRoleList) of
        false ->
            update_map_role_team_do_status({RoleId,?TEAM_DO_STATUS_NORMAL}),
            SendSelf=#m_team_leave_toc{succ = false,reason = ?_LANG_TEAM_NOT_IN},
            ?DEBUG("~ts,SendSelf=~w",["组队模块Leave",SendSelf]),
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf);
        _ ->
            [MinTeamMemberCount] = common_config_dyn:find(team,min_member_count),
            case erlang:length(TeamRoleList) < (MinTeamMemberCount + 1) of
                true -> %% 必须解散队伍
                    do_leave_disband({Unique,Module,Method,DataRecord,RoleId,PId},TeamState);
                _ ->
                    do_leave({Unique,Module,Method,DataRecord,RoleId,PId},TeamState)
            end
    end.
do_leave({Unique,Module,Method,_DataRecord,RoleId,PId},TeamState) ->  
    update_map_role_team_data({RoleId,0,undefined,1,[]}),
    TeamRoleInfo = lists:keyfind(RoleId,#p_team_role.role_id,TeamState#r_team_state.team_role_list),
    TeamRoleList = lists:keydelete(RoleId,#p_team_role.role_id,TeamState#r_team_state.team_role_list),
    update_map_role_team_data({RoleId,0,undefined,1,[]}),
    SendSelf=#m_team_leave_toc{succ = true},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Leave",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    catch mod_team_buff:handle({delete_role_team_buff,RoleId}),
    if RoleId =:= TeamState#r_team_state.leader_role_id -> %% 队长离队
            LeaderTeamRoleInfo = lists:nth(1,TeamRoleList),
            LeaderTeamRoleInfo2 = LeaderTeamRoleInfo#p_team_role{is_leader = true}, 
            LeaderRoleId = LeaderTeamRoleInfo2#p_team_role.role_id,
            TeamRoleList2 = lists:append([[LeaderTeamRoleInfo2],
                                          lists:keydelete(LeaderTeamRoleInfo2#p_team_role.role_id,#p_team_role.role_id,TeamRoleList)]);
       true ->
            LeaderRoleId = TeamState#r_team_state.leader_role_id,
            TeamRoleList2 = TeamRoleList
    end,
    set_team_state(TeamState#r_team_state{leader_role_id = LeaderRoleId, team_role_list = TeamRoleList2}),
    SendMember = #m_team_leave_toc{
      return_self = false, 
      role_list =TeamRoleList2, 
      role_id = RoleId,
      role_name = TeamRoleInfo#p_team_role.role_name, 
      team_id = TeamState#r_team_state.team_id},
    lists:foreach(
      fun(PTeamRoleInfo) ->
              case PTeamRoleInfo#p_team_role.is_offline =:= false of
                  true ->
                      update_map_role_team_data({PTeamRoleInfo#p_team_role.role_id,
                                                 TeamState#r_team_state.team_id,
                                                 TeamState#r_team_state.proccess_name,
                                                 TeamState#r_team_state.pick_type,TeamRoleList2}),
                      catch common_misc:unicast({role,PTeamRoleInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendMember);
                  _ ->
                      ignore
              end
      end,TeamRoleList2),
    ok.
do_leave_disband({Unique,Module,Method,_DataRecord,RoleId,PId},TeamState) -> 
    update_map_role_team_data({RoleId,0,undefined,1,[]}),
    SendSelf=#m_team_leave_toc{succ = true},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Leave",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    TeamRoleInfo = lists:keyfind(RoleId,#p_team_role.role_id,TeamState#r_team_state.team_role_list),
    TeamRoleList = lists:keydelete(RoleId,#p_team_role.role_id,TeamState#r_team_state.team_role_list),
    SendMember = #m_team_leave_toc{
      return_self = false, 
      role_list =TeamRoleList, 
      role_id = RoleId,
      role_name = TeamRoleInfo#p_team_role.role_name, 
      team_id = TeamState#r_team_state.team_id},
    SendAutoDisband = #m_team_auto_disband_toc{succ = true,reason = ?_LANG_TEAM_AUTO_DISBAND},
    lists:foreach(
      fun(PTeamRoleInfo) ->
              case PTeamRoleInfo#p_team_role.is_offline =:= true of
                  true ->
                      catch do_leave_team_by_offline(PTeamRoleInfo#p_team_role.role_id);
                      %% catch mod_team_buff:handle({delete_role_team_buff,PTeamRoleInfo#p_team_role.role_id});
                  _ ->
                      update_map_role_team_data({PTeamRoleInfo#p_team_role.role_id,0,undefined,1,[]}),
                      catch mod_team_buff:handle({delete_role_team_buff,PTeamRoleInfo#p_team_role.role_id}),
                      common_misc:unicast({role,PTeamRoleInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendMember),
                      common_misc:unicast({role,PTeamRoleInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, ?TEAM_AUTO_DISBAND, SendAutoDisband)
              end
      end,TeamRoleList),
    erlang:send(self(),{kill_team_proccess,<<"有人离开队伍，队伍人数不够人即自动散落队伍">>}),
    ok.
%% 设置队伍拾取模式
do_pick({Unique,Module,Method,DataRecord,RoleId,PId}) ->
    case catch do_pick2(RoleId,DataRecord) of
        {error,Reason} ->
            update_map_role_team_do_status({RoleId,?TEAM_DO_STATUS_NORMAL}),
            do_pick_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,TeamState} ->
            do_pick3({Unique, Module, Method, DataRecord, RoleId, PId},TeamState)
    end.
do_pick2(RoleId,DataRecord) ->
    #r_team_state{leader_role_id = LeaderRoleId,
                  pick_type = PickType} = TeamState = get_team_state(),
    case DataRecord#m_team_pick_tos.pick_type =:= 1
        orelse DataRecord#m_team_pick_tos.pick_type =:= 2 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_PICK_TYPE_NOT_VALID})
    end,
    case RoleId =:= LeaderRoleId of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_LEADER_AUTHORITY})
    end,
    case DataRecord#m_team_pick_tos.pick_type =:= PickType of
        true ->
            erlang:throw({error,?_LANG_TEAM_PICK_TYPE_REPEAT});
        _ ->
            next
    end,
    {ok,TeamState}.
do_pick3({Unique, Module, Method, DataRecord, RoleId, PId},TeamState) ->
    set_team_state(TeamState#r_team_state{pick_type = DataRecord#m_team_pick_tos.pick_type }),
    update_map_role_team_pick_type({RoleId,TeamState#r_team_state.leader_role_id,DataRecord#m_team_pick_tos.pick_type}),
    SendSelf = #m_team_pick_toc{succ = true, pick_type= DataRecord#m_team_pick_tos.pick_type},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Pick",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    %% 广播
    SendMember = #m_team_pick_toc{return_self = false, pick_type= DataRecord#m_team_pick_tos.pick_type},
    lists:foreach(
      fun(TeamRoleInfo) ->
              if TeamRoleInfo#p_team_role.role_id =/= RoleId ->
                      catch update_map_role_team_pick_type({TeamRoleInfo#p_team_role.role_id,
                                                            TeamState#r_team_state.leader_role_id,DataRecord#m_team_pick_tos.pick_type}),
                      catch common_misc:unicast({role,TeamRoleInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendMember);
                 true->
                      next
              end
      end,TeamState#r_team_state.team_role_list),
    ok.

do_pick_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf=#m_team_pick_toc{succ = false,reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Pick",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

do_kick({Unique,Module,Method,DataRecord,RoleId,PId}) ->
    case catch do_kick2(RoleId,DataRecord) of
        {error,Reason} ->
            update_map_role_team_do_status({RoleId,?TEAM_DO_STATUS_NORMAL}),
            do_kick_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,TeamState} ->
            do_kick3({Unique,Module,Method,DataRecord,RoleId,PId},TeamState)
    end.
do_kick2(RoleId,DataRecord) ->
    #r_team_state{team_role_list = TeamRoleList,
                  leader_role_id = LeaderRoleId} = TeamState = get_team_state(),
    if RoleId =:= DataRecord#m_team_kick_tos.role_id ->
            erlang:throw({error,?_LANG_TEAM_KICK_FAIL_SELF});
       true ->
            next
    end,
    case RoleId =:= LeaderRoleId of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_LEADER_AUTHORITY})
    end,
    case lists:keyfind(DataRecord#m_team_kick_tos.role_id,#p_team_role.role_id,TeamRoleList) of
        false ->
            erlang:throw({error,?_LANG_TEAM_KICK_FAIL_NOT_IN});
        _ ->
            next
    end,
    {ok,TeamState}.

do_kick3({Unique,Module,Method,DataRecord,RoleId,PId},TeamState) ->
    %% 被踢玩家
    KickTeamRoleInfo = lists:keyfind(DataRecord#m_team_kick_tos.role_id,#p_team_role.role_id,TeamState#r_team_state.team_role_list),
    TeamRoleList = lists:keydelete(DataRecord#m_team_kick_tos.role_id,#p_team_role.role_id,TeamState#r_team_state.team_role_list),
    SendKick = #m_team_kick_toc{return_self = false, reason = ?_LANG_TEAM_KICK_SUCC,
                                role_id = KickTeamRoleInfo#p_team_role.role_id,
                                role_name = KickTeamRoleInfo#p_team_role.role_name, 
                                team_id = TeamState#r_team_state.team_id},
    set_team_state(TeamState#r_team_state{team_role_list = TeamRoleList}),
    catch do_leave_team_by_offline(KickTeamRoleInfo#p_team_role.role_id),
    catch common_misc:unicast({role,KickTeamRoleInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendKick),
    catch mod_team_buff:handle({delete_role_team_buff,KickTeamRoleInfo#p_team_role.role_id}),
    %% 队长通知
    SendSelf =  #m_team_kick_toc{succ = true, role_list = TeamRoleList,
                                 role_id = KickTeamRoleInfo#p_team_role.role_id,
                                 role_name = KickTeamRoleInfo#p_team_role.role_name,
                                 team_id = TeamState#r_team_state.team_id},
    update_map_role_team_data({RoleId,TeamState#r_team_state.team_id,TeamState#r_team_state.proccess_name,TeamState#r_team_state.pick_type,TeamRoleList}),
    ?DEBUG("~ts,SendSelf=~w",["组队模块Kick",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    %% 队员通知
    SendMember = #m_team_kick_toc{return_self = false, role_list = TeamRoleList,
                                  role_id = KickTeamRoleInfo#p_team_role.role_id,
                                  role_name = KickTeamRoleInfo#p_team_role.role_name,
                                  team_id = TeamState#r_team_state.team_id},
    lists:foreach(
      fun(PTeamRoleInfo) ->
              if PTeamRoleInfo#p_team_role.role_id =/= RoleId andalso PTeamRoleInfo#p_team_role.is_offline =:= false ->
                      update_map_role_team_data({PTeamRoleInfo#p_team_role.role_id,TeamState#r_team_state.team_id,
                                                 TeamState#r_team_state.proccess_name,TeamState#r_team_state.pick_type,TeamRoleList}),
                      common_misc:unicast({role,PTeamRoleInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendMember);
                 true ->
                      ignore
              end
      end,TeamRoleList),
    do_kick4(TeamState#r_team_state{team_role_list = TeamRoleList}).
do_kick4(TeamState) ->
    [MinTeamMemberCount] = common_config_dyn:find(team,min_member_count),
    case erlang:length(TeamState#r_team_state.team_role_list) < MinTeamMemberCount of
        true -> %% 解散队伍
            SendAutoDisband = #m_team_auto_disband_toc{reason = ?_LANG_TEAM_AUTO_DISBAND},
            lists:foreach(
              fun(TeamRoleInfo) ->
                      case TeamRoleInfo#p_team_role.is_offline =:= true of
                          true ->
                              catch do_leave_team_by_offline(TeamRoleInfo#p_team_role.role_id);
                          _ ->
                              catch do_leave_team_by_offline(TeamRoleInfo#p_team_role.role_id),
                              catch mod_team_buff:handle({delete_role_team_buff,TeamRoleInfo#p_team_role.role_id}),
                              catch common_misc:unicast({role,TeamRoleInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, ?TEAM, ?TEAM_AUTO_DISBAND, SendAutoDisband)
                      end
              end,TeamState#r_team_state.team_role_list),
            erlang:send(self(),{kill_team_proccess,<<"请离队员时，队伍人数不够人即自动散落队伍">>});
        _ ->
            ignore
    end.

do_kick_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf = #m_team_kick_toc{succ = false, reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Kick",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

%% 移交队长
do_change_leader({Unique,Module,Method,DataRecord,RoleId,PId}) ->
    case catch do_change_leader2(RoleId,DataRecord) of
        {error,Reason} ->
            update_map_role_team_do_status({RoleId,?TEAM_DO_STATUS_NORMAL}),
            do_change_leader_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,TeamState} ->
            do_change_leader3({Unique,Module,Method,DataRecord,RoleId,PId},TeamState)
    end.
do_change_leader2(RoleId,DataRecord) ->
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
    #r_team_state{team_role_list = TeamRoleList,
                  leader_role_id = LeaderRoleId} = TeamState = get_team_state(),
    case lists:keyfind(DataRecord#m_team_change_leader_tos.role_id,#p_team_role.role_id,TeamRoleList) of
        false ->
            erlang:throw({error,?_LANG_TEAM_CHANGE_LEADER_FAIL_NOT_IN2});
        _ ->
            next
    end,
    case RoleId =:= LeaderRoleId of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_LEADER_AUTHORITY})
    end,
    {ok,TeamState}.
do_change_leader3({Unique,Module,Method,DataRecord,RoleId,PId},TeamState) ->
    #r_team_state{team_role_list = TeamRoleList} = TeamState,
    OldLeaderTeamRoleInfo = lists:keyfind(RoleId,#p_team_role.role_id,TeamRoleList),
    NewLeaderTeamRoleInfo = lists:keyfind(DataRecord#m_team_change_leader_tos.role_id,#p_team_role.role_id,TeamRoleList),
    TeamRoleList2 = lists:keydelete(DataRecord#m_team_change_leader_tos.role_id,#p_team_role.role_id,TeamRoleList),
    TeamRoleList3 = lists:keydelete(RoleId,#p_team_role.role_id,TeamRoleList2),
    TeamRoleList4 = lists:append([[NewLeaderTeamRoleInfo#p_team_role{is_leader = true},
                                   OldLeaderTeamRoleInfo#p_team_role{is_leader = false}],TeamRoleList3]),
    set_team_state(TeamState#r_team_state{leader_role_id = NewLeaderTeamRoleInfo#p_team_role.role_id,
                                          team_role_list = TeamRoleList4}),
    SendSelf = #m_team_change_leader_toc{
      succ = true, role_list = TeamRoleList4, 
      role_id = NewLeaderTeamRoleInfo#p_team_role.role_id,
      role_name = NewLeaderTeamRoleInfo#p_team_role.role_name, 
      team_id = TeamState#r_team_state.team_id },
    update_map_role_team_data({RoleId,TeamState#r_team_state.team_id,TeamState#r_team_state.proccess_name,TeamState#r_team_state.pick_type,TeamRoleList4}),
    ?DEBUG("~ts,SendSelf=~w",["组队模块Change Leader",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    SendMember = #m_team_change_leader_toc{
      return_self = false, role_list = TeamRoleList4, 
      role_id = NewLeaderTeamRoleInfo#p_team_role.role_id,
      role_name = NewLeaderTeamRoleInfo#p_team_role.role_name, 
      team_id =TeamState#r_team_state.team_id},
    lists:foreach(
      fun(PTeamRoleInfo) -> 
              if PTeamRoleInfo#p_team_role.role_id =/= RoleId ->
                      update_map_role_team_data({PTeamRoleInfo#p_team_role.role_id,TeamState#r_team_state.team_id,
                                                 TeamState#r_team_state.proccess_name,TeamState#r_team_state.pick_type,TeamRoleList4}),
                      common_misc:unicast({role,PTeamRoleInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendMember);
                 true ->
                      ignore
              end
      end,TeamRoleList4),
    ok.

do_change_leader_error({Unique, Module, Method, _DataRecord, _RoleId, PId},Reason) ->
    SendSelf = #m_team_change_leader_toc{succ = false, reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Change Leader",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

%% 解散队伍
do_disband({Unique,Module,Method,DataRecord,RoleId,PId}) ->
    case catch do_disband2(RoleId,DataRecord) of
        {error,Reason} ->
            update_map_role_team_do_status({RoleId,?TEAM_DO_STATUS_NORMAL}),
            do_disband_error({Unique,Module,Method,DataRecord,RoleId,PId},Reason);
        {ok,TeamState} ->
            do_disband3({Unique,Module,Method,DataRecord,RoleId,PId},TeamState)
    end.
do_disband2(RoleId,DataRecord) ->
    TeamState = get_team_state(),
    case DataRecord#m_team_disband_tos.team_id =:= TeamState#r_team_state.team_id of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_NOT_IN})
    end,
    case RoleId =:= TeamState#r_team_state.leader_role_id of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_LEADER_AUTHORITY})
    end,
    {ok,TeamState}.
do_disband3({Unique,Module,Method,_DataRecord,RoleId,PId},TeamState) ->
    SendSelf = #m_team_disband_toc{succ = true,team_id = TeamState#r_team_state.team_id, reason = ?_LANG_TEAM_LEADER_DISBAND},
    update_map_role_team_data({RoleId,0,undefined,1,[]}),
    ?DEBUG("~ts,SendSelf=~w",["组队模块Disband",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    SendMember = #m_team_disband_toc{return_self = false,team_id = TeamState#r_team_state.team_id, reason = ?_LANG_TEAM_LEADER_DISBAND},
    lists:foreach(
      fun(PTeamRoleInfo) ->
              if PTeamRoleInfo#p_team_role.role_id =/= RoleId andalso PTeamRoleInfo#p_team_role.is_offline =:= false ->
                      update_map_role_team_data({PTeamRoleInfo#p_team_role.role_id,0,undefined,1,[]}),
                      common_misc:unicast({role,PTeamRoleInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendMember),
                      catch mod_team_buff:handle({delete_role_team_buff,PTeamRoleInfo#p_team_role.role_id});
                 true ->
                      catch do_leave_team_by_offline(PTeamRoleInfo#p_team_role.role_id)
                      %% catch mod_team_buff:handle({delete_role_team_buff,PTeamRoleInfo#p_team_role.role_id})
              end
      end,TeamState#r_team_state.team_role_list),
    erlang:send(self(),{kill_team_proccess,<<"队长解散时，自动散落队伍">>}),
    ok.
do_disband_error({Unique,Module,Method,_DataRecord,_RoleId,PId},Reason) ->
    SendSelf = #m_team_disband_toc{succ = false, reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Disband",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

do_apply({Unique, Module, Method, DataRecord, RoleId, PId, RoleTeamInfo}) ->
    case catch do_apply2(RoleId,DataRecord) of
        {error,Reason} ->
            common_misc:send_to_rolemap(RoleId, {mod_map_team,{admin_update_do_status,{RoleId,?TEAM_DO_STATUS_NORMAL}}}),
            do_apply_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason);
        {ok,TeamState} ->
            do_apply3({Unique, Module, Method, DataRecord, RoleId, PId, RoleTeamInfo},TeamState)
    end.
do_apply2(RoleId,DataRecord) ->
    TeamState = get_team_state(),
    [MaxMemberCount] = common_config_dyn:find(team,max_member_count),
    case erlang:length(TeamState#r_team_state.team_role_list) >= MaxMemberCount of
        true ->
            erlang:throw({error,?_LANG_TEAM_APPLY_ROLE_MAX_MEMBER});
        _ ->
            next
    end,
    case RoleId =:= TeamState#r_team_state.leader_role_id of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_APPLY_TEAMLEADER_NO_LEADER})
    end,
    case lists:keyfind(DataRecord#m_team_apply_tos.apply_id,#p_team_role.role_id,TeamState#r_team_state.team_role_list) of
        false ->
            next;
        _ ->
            erlang:throw({error,?_LANG_TEAM_APPLY_TEAMLEADER_ROLE_IN_TEAM})
    end,
    {ok,TeamState}.

do_apply3({Unique, Module, Method, DataRecord, RoleId, PId, RoleTeamInfo},TeamState) ->
    TeamRoleList = lists:append([TeamState#r_team_state.team_role_list,[RoleTeamInfo]]),
    set_team_state(TeamState#r_team_state{team_role_list = TeamRoleList}),
    update_map_role_team_data({RoleId,TeamState#r_team_state.team_id,
                               TeamState#r_team_state.proccess_name,
                               TeamState#r_team_state.pick_type,TeamRoleList}),
    SendLeader = #m_team_apply_toc{
      succ = true,
      return_self = true,
      role_id = DataRecord#m_team_apply_tos.role_id,
      op_type = DataRecord#m_team_apply_tos.op_type,
      apply_id = DataRecord#m_team_apply_tos.apply_id,
      apply_name = RoleTeamInfo#p_team_role.role_name},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Apply",SendLeader]),
    common_misc:unicast2(PId, Unique, Module, Method, SendLeader),
    SendMember = #m_team_apply_toc{
      succ = true,
      return_self = false,
      role_id = DataRecord#m_team_apply_tos.role_id,
      op_type = DataRecord#m_team_apply_tos.op_type,
      apply_id = DataRecord#m_team_apply_tos.apply_id,
      apply_name = RoleTeamInfo#p_team_role.role_name,
      team_id = TeamState#r_team_state.team_id,
      pick_type = TeamState#r_team_state.pick_type,
      role_list = TeamRoleList
     },
    lists:foreach(
      fun(PTeamRoleInfo) ->
              if PTeamRoleInfo#p_team_role.role_id =/= RoleId ->
                      update_map_role_team_data({PTeamRoleInfo#p_team_role.role_id,TeamState#r_team_state.team_id,
                                                 TeamState#r_team_state.proccess_name,
                                                 TeamState#r_team_state.pick_type,TeamRoleList}),
                      common_misc:unicast({role,PTeamRoleInfo#p_team_role.role_id}, ?DEFAULT_UNIQUE, Module, Method, SendMember);
                 true ->
                      next
              end
      end,TeamRoleList),
    ok.
do_apply_error({Unique, Module, Method, DataRecord, _RoleId, PId},Reason) ->
    SendSelf = #m_team_apply_toc{
      succ = false,
      return_self = true,
      role_id = DataRecord#m_team_apply_tos.role_id,
      op_type = DataRecord#m_team_apply_tos.op_type,
      apply_id = DataRecord#m_team_apply_tos.apply_id,
      reason = Reason},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Apply",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).


%% 玩家下线
do_offline({RoleId,TeamId}) ->
    %%?DEBUG("~ts,RoleId=~w,TeamId=~w",["玩家下线队伍进程处理",RoleId,TeamId]),
    case catch do_offline2({RoleId,TeamId}) of
        {error} ->
            ?DEBUG("~ts,RoleId=~w,TeamId=~w",["玩家存在错误的队伍id",RoleId,TeamId]),
            case db:dirty_read(?DB_ROLE_BASE,RoleId) of
                [RoleBase] ->
                    db:dirty_write(?DB_ROLE_BASE,RoleBase#p_role_base{team_id = 0});
                _ ->
                    ignore
            end,
            ignore;
        {ok,TeamState,TeamRoleInfo} ->
            do_offline3({RoleId,TeamId},TeamState,TeamRoleInfo)
    end.
do_offline2({RoleId,TeamId}) ->
    TeamState = get_team_state(),
    case TeamId =:= TeamState#r_team_state.team_id of
        true ->
            ok;
        _ ->
            erlang:throw({error})
    end,
    TeamRoleInfo = 
        case lists:keyfind(RoleId,#p_team_role.role_id,TeamState#r_team_state.team_role_list) of
            false ->
                erlang:throw({error});
            TeamRoleInfoT ->
                TeamRoleInfoT
        end,
    [OfflineCacheTime] = common_config_dyn:find(team,offline_cache_time),
    {ok,TeamState,TeamRoleInfo#p_team_role{is_offline = true,offline_time = common_tool:now() + OfflineCacheTime }}.
do_offline3({RoleId,_TeamId},TeamState,TeamRoleInfo) ->
    TeamRoleList = 
        lists:foldl(
          fun(PTeamRoleInfo,AccTeamRoleList) ->
                  case PTeamRoleInfo#p_team_role.role_id =:= RoleId of
                      true ->
                          lists:append([AccTeamRoleList,[TeamRoleInfo]]);
                      _ ->
                          lists:append([AccTeamRoleList,[PTeamRoleInfo]])
                  end
          end,[],TeamState#r_team_state.team_role_list),
    set_team_state(TeamState#r_team_state{team_role_list = TeamRoleList}),
    lists:foreach(
      fun(PTeamRoleInfoT) ->
              case PTeamRoleInfoT#p_team_role.is_offline =:= true  orelse PTeamRoleInfoT#p_team_role.role_id =:= RoleId of
                  true -> 
                      ignore;
                  _ ->
                      SendMember = #m_team_auto_list_toc{
                        return_self = false, 
                        team_id = TeamState#r_team_state.team_id, 
                        role_list = TeamRoleList, 
                        pick_type = TeamState#r_team_state.pick_type, 
                        visible_role_list= calc_team_visible_role_list(PTeamRoleInfoT#p_team_role.role_id,TeamRoleList)},
                      common_misc:unicast({role,PTeamRoleInfoT#p_team_role.role_id},?DEFAULT_UNIQUE, ?TEAM,?TEAM_AUTO_LIST,SendMember)
              end
      end,TeamRoleList),
    ok.

%% 玩家上线
do_online({RoleId,TeamId,TeamSyncData}) ->
    %%?DEBUG("~ts,RoleId=~w,TeamId=~w",["玩家上线线队伍进程处理",RoleId,TeamId]),
    case catch do_online2({RoleId,TeamId,TeamSyncData}) of
        {error} ->
            update_map_role_team_data({RoleId,0,undefined,1,[]}),
            common_misc:unicast({role,RoleId}, ?DEFAULT_UNIQUE, ?TEAM, ?TEAM_LEAVE, #m_team_leave_toc{succ = true});
        {ok,TeamState,TeamRoleInfo} ->
            do_online3({RoleId,TeamId},TeamState,TeamRoleInfo)
    end.
do_online2({RoleId,TeamId,TeamSyncData}) ->
    TeamState = get_team_state(),
    case TeamId =:= TeamState#r_team_state.team_id of
        true ->
            ok;
        _ ->
            erlang:throw({error})
    end,
    TeamRoleInfo = 
        case lists:keyfind(RoleId,#p_team_role.role_id,TeamState#r_team_state.team_role_list) of
            false ->
                erlang:throw({error});
            TeamRoleInfoT ->
                TeamRoleInfoT
        end,
    {ok,TeamState,
     get_team_role_info_by_sync_data(TeamRoleInfo#p_team_role{is_offline = false,offline_time = 0},TeamSyncData)}.
do_online3({RoleId,_TeamId},TeamState,TeamRoleInfo) ->
    TeamRoleList = 
        lists:foldl(
          fun(PTeamRoleInfo,AccTeamRoleList) ->
                  case PTeamRoleInfo#p_team_role.role_id =:= RoleId of
                      true ->
                          lists:append([AccTeamRoleList,[TeamRoleInfo]]);
                      _ ->
                          lists:append([AccTeamRoleList,[PTeamRoleInfo]])
                  end
          end,[],TeamState#r_team_state.team_role_list),
    update_map_role_team_data({RoleId,TeamState#r_team_state.team_id,
                               TeamState#r_team_state.proccess_name,
                               TeamState#r_team_state.pick_type,TeamRoleList}),
    set_team_state(TeamState#r_team_state{team_role_list = TeamRoleList}),
    %% 通知刚上线玩家队伍信息
    SendSelf = #m_team_auto_list_toc{
      team_id = TeamState#r_team_state.team_id,
      role_list = TeamRoleList, 
      pick_type = TeamState#r_team_state.pick_type,
      visible_role_list= calc_team_visible_role_list(RoleId,TeamRoleList)},
    ?DEBUG("~ts,SendSelf=~w",["组队模块Online",SendSelf]),
    common_misc:unicast({role,RoleId}, ?DEFAULT_UNIQUE, ?TEAM, ?TEAM_AUTO_LIST, SendSelf),
    lists:foreach(
      fun(PTeamRoleInfoT) ->
              case PTeamRoleInfoT#p_team_role.is_offline =:= true  orelse PTeamRoleInfoT#p_team_role.role_id =:= RoleId of
                  true -> 
                      ignore;
                  _ ->
                      SendMember = #m_team_auto_list_toc{
                        return_self = false, 
                        team_id = TeamState#r_team_state.team_id, 
                        role_list = TeamRoleList, 
                        pick_type = TeamState#r_team_state.pick_type, 
                        visible_role_list= calc_team_visible_role_list(PTeamRoleInfoT#p_team_role.role_id,TeamRoleList)},
                      common_misc:unicast({role,PTeamRoleInfoT#p_team_role.role_id},?DEFAULT_UNIQUE, ?TEAM,?TEAM_AUTO_LIST,SendMember)
              end
      end,TeamRoleList),
    ok.
%% 从地图的同步数据赋值到p_team_role并返回
get_team_role_info_by_sync_data(TeamRoleInfo,TeamSyncData) ->
    TeamRoleInfo#p_team_role{
      map_id = TeamSyncData#r_role_team_sync_data.map_id,
      map_name = TeamSyncData#r_role_team_sync_data.map_name,
      tx = TeamSyncData#r_role_team_sync_data.tx,
      ty = TeamSyncData#r_role_team_sync_data.ty,
      hp = TeamSyncData#r_role_team_sync_data.hp,
      mp = TeamSyncData#r_role_team_sync_data.mp,
      max_hp = TeamSyncData#r_role_team_sync_data.max_hp,
      max_mp = TeamSyncData#r_role_team_sync_data.max_mp,
      level = TeamSyncData#r_role_team_sync_data.level,
      five_ele_attr = TeamSyncData#r_role_team_sync_data.five_ele_attr,
      category = TeamSyncData#r_role_team_sync_data.category,
      skin = TeamSyncData#r_role_team_sync_data.skin
     }.
%% 计算队员之间的五行属性情况
%% 返回 [p_team_role,...]
calc_team_five_ele_attr([]) ->
    [];
calc_team_five_ele_attr(TeamRoleList) ->
    [FiveEleAttrLevelRule] = common_config_dyn:find(team,five_ele_attr_level_rule),
    %% 初始化信息
    TeamRoleList2 = 
        lists:map(
          fun(TeamRoleInfo) ->
                  FiveEleAttrLevel = 
                      lists:foldl(
                        fun({RuleLevel,MinLevel,MaxLevel},AccFiveEleAttrLevel) ->
                                case AccFiveEleAttrLevel =:= 0 
                                    andalso TeamRoleInfo#p_team_role.level >= MinLevel
                                    andalso MaxLevel >= TeamRoleInfo#p_team_role.level of
                                    true ->
                                        RuleLevel;
                                    _ ->
                                        AccFiveEleAttrLevel
                                end
                        end,0,FiveEleAttrLevelRule),
                  TeamRoleInfo#p_team_role{five_ele_attr_level = FiveEleAttrLevel,
                                           add_hp = 0,add_mp = 0,add_phy_attack = 0,add_magic_attack = 0}
          end,TeamRoleList),
    case common_config_dyn:find(team, is_five_ele_attr) of
        [true] ->
            calc_team_five_ele_attr2(TeamRoleList2);
        _ ->
            TeamRoleList2
    end.
calc_team_five_ele_attr2(TeamRoleList) ->
    %% 相克属性
    [FiveEleAttrAttackRule] =  common_config_dyn:find(team,five_ele_attr_attack_rule),
    %% 相生属性
    [FiveEleAttrMpHpRule] = common_config_dyn:find(team,five_ele_attr_mphp_rule),
    %% 五行级别加成值
    [FiveEleAttrRule] = common_config_dyn:find(team,five_ele_attr_rule),
    lists:foldl(
      fun(TeamRoleInfo,AccTeamRoleList2) ->
              case TeamRoleInfo#p_team_role.five_ele_attr =/= 0 andalso TeamRoleInfo#p_team_role.five_ele_attr_level =/= 0  of
                  true ->
                      VisibleList = calc_team_visible_role_list(TeamRoleInfo#p_team_role.role_id,TeamRoleList),
                      case VisibleList of
                          [] ->
                              lists:append([AccTeamRoleList2,[TeamRoleInfo]]);
                          _ ->
                              {_FiveEleAttrLevel,AddPhyAttack,AddMagicAttack,AddHp,AddMp} = 
                                  lists:keyfind(TeamRoleInfo#p_team_role.five_ele_attr_level,1,FiveEleAttrRule),
                              TeamRoleInfo2 = 
                                  lists:foldl(
                                    fun(RoleId,TeamRoleInfoA) ->
                                            TeamRoleInfoB = lists:keyfind(RoleId,#p_team_role.role_id,TeamRoleList),
                                            case TeamRoleInfoB#p_team_role.five_ele_attr =/= 0 of
                                                true ->
                                                    Key = TeamRoleInfoB#p_team_role.five_ele_attr * 10 + TeamRoleInfoA#p_team_role.five_ele_attr,
                                                    %% 找出相克属性
                                                    TeamRoleInfoA2 = 
                                                        case lists:keyfind(Key,1,FiveEleAttrAttackRule) of
                                                            false ->
                                                                TeamRoleInfoA;
                                                            _ ->
                                                                TeamRoleInfoA#p_team_role{add_phy_attack = AddPhyAttack,add_magic_attack = AddMagicAttack}
                                                        end,
                                                    case lists:keyfind(Key,1,FiveEleAttrMpHpRule) of
                                                        false ->
                                                            TeamRoleInfoA2;
                                                        _ ->
                                                            TeamRoleInfoA2#p_team_role{add_hp = AddHp,add_mp = AddMp}
                                                    end;
                                                _ ->
                                                    TeamRoleInfo
                                            end
                                    end,TeamRoleInfo,VisibleList),
                              lists:append([AccTeamRoleList2,[TeamRoleInfo2]])
                      end;
                  _ ->
                      lists:append([AccTeamRoleList2,[TeamRoleInfo]])
              end
      end,[],TeamRoleList).
%% 计逄玩家之间是否相到可见
%% 返回可以队员列表 [RoleId,...] or []
calc_team_visible_role_list(RoleId,TeamRoleList) ->
    case lists:keyfind(RoleId,#p_team_role.role_id,TeamRoleList) of
        false ->
            [];
        TeamRoleInfo ->
            lists:foldl(
              fun(PTeamRoleInfo,AccVisibleList) ->
                      case check_valid_distance(TeamRoleInfo,PTeamRoleInfo) of
                          true ->
                              [PTeamRoleInfo#p_team_role.role_id|AccVisibleList];
                          _ ->
                              AccVisibleList
                      end
              end,[],lists:keydelete(RoleId,#p_team_role.role_id,TeamRoleList))
    end.
%% 可见返回true 其它返回false
check_valid_distance(TeamRoleInfoA,TeamRoleInfoB) ->
    case TeamRoleInfoA#p_team_role.map_id =:= TeamRoleInfoB#p_team_role.map_id of
        true ->
            [{MaxPx,MaxPy}] = common_config_dyn:find(team, max_pixels),
            {Px1,Py1} = common_misc:get_iso_index_mid_vertex(TeamRoleInfoA#p_team_role.tx, 0, TeamRoleInfoA#p_team_role.ty),
            {Px2,Py2} = common_misc:get_iso_index_mid_vertex(TeamRoleInfoB#p_team_role.tx, 0, TeamRoleInfoB#p_team_role.ty),
            erlang:abs(Px1 - Px2) < MaxPx andalso erlang:abs(Py1 - Py2) < MaxPy;
        _ ->
            false
    end.
