%%% @author bisonwu <wuzesen@mingchao.com>
%% Created: 2011-6-22
%% Description: 特殊事件的侦听器 - 3次对话 - 中间状态去完成事件
%%      model_status: 必须是3个Status
%%      listener：必须是特殊事件的侦听器
-module(mission_model_13, [RoleID, MissionID, MissionBaseInfo]).
-behaviour(b_mission_model).

%%
%% Include files
%%

-include("mission.hrl").  
%%特殊事件模型的第二个状态
-define(MISSION_MODEL_13_STATUS_DOING, 1).


%%
%% Exported Functions
%%
-export([
     auth_accept/1,
     auth_show/1,
     do/2,
     cancel/2,
     listener_trigger/2,
     init_pinfo/1]).

%%
%% API Functions
%%
%%@doc 验证是否可接
auth_accept(_PInfo) -> 
        mod_mission_auth:auth_accept(RoleID, MissionBaseInfo).

%%@doc 验证是否可以出现在任务列表
auth_show(_PInfo) -> 
        mod_mission_auth:auth_show(RoleID, MissionBaseInfo).

%%@doc 执行任务 接-做-交
do(PInfo, RequestRecord) ->
    TransFun = 
        fun() ->
                case i_deal_listener(PInfo, RequestRecord) of
                    ignore ->
                        #m_mission_do_toc{
                            id=MissionID,
                            current_status=PInfo#p_mission_info.current_status,
                            pre_status=PInfo#p_mission_info.pre_status,
                            current_model_status=PInfo#p_mission_info.current_model_status,
                            pre_model_status=PInfo#p_mission_info.pre_model_status,
                            code=?MISSION_CODE_SUCC,
                            code_data=[]};
                    NewPInfo ->
                        mission_model_common:common_do(RoleID, MissionID,MissionBaseInfo,RequestRecord, NewPInfo)
                end
        end,
    TransResult = ?DO_TRANS_FUN( TransFun ),
    case TransResult of
        {atomic, _}->
            case lists:foldl(
                   fun(ListenerData,AccAutoDoListenerFlag) ->
                           case ListenerData#mission_listener_data.value =:= ?MISSON_EVENT_JOIN_FAMILY 
                                andalso ListenerData#mission_listener_data.type =:= ?MISSION_LISTENER_TYPE_SPECIAL_EVENT
                                andalso AccAutoDoListenerFlag =:= false of
                               true ->
                                   case mod_map_role:get_role_base(RoleID) of
                                       {ok,#p_role_base{family_id = FamilyId}} ->
                                           case FamilyId > 0 of
                                               true ->
                                                   true;
                                               _ ->
                                                   AccAutoDoListenerFlag
                                           end;
                                       _ ->
                                           AccAutoDoListenerFlag
                                   end;
                               _ ->
                                   AccAutoDoListenerFlag
                           end
                   end, false, MissionBaseInfo#mission_base_info.listener_list) of
                true -> %% 需要自动处理
                    catch common_misc:send_to_rolemap(RoleID,{hook_mission_event,{special_event,RoleID,?MISSON_EVENT_JOIN_FAMILY}});
                _ ->
                    ignore
            end;
        _ ->
            ignore
    end,
    TransResult.


%%@doc 取消任务
cancel(PInfo, RequestRecord) ->
    TransFun = 
        fun() ->
                Result = mission_model_common:common_cancel(RoleID, MissionID, MissionBaseInfo, RequestRecord, PInfo),
                
                %%@doc 删除侦听器
                ListenerList = PInfo#p_mission_info.listener_list,
                i_remove_all_listener(ListenerList),
                
                Result
        end,
    ?DO_TRANS_FUN( TransFun ).

%%@doc 侦听器触发
listener_trigger(ListenerData, PInfo) -> 
    TransFun = fun() ->
                       ListenerList = PInfo#p_mission_info.listener_list,
                       ListenerVal = ListenerData#mission_listener_trigger_data.value,
                       i_trigger_event(ListenerList, PInfo, ListenerVal)
               end,
    TransResult = ?DO_TRANS_FUN( TransFun ),
    case TransResult of
        {atomic, _}->
            case ListenerData#mission_listener_trigger_data.value =:= ?MISSON_EVENT_JOIN_FAMILY 
                 orelse ListenerData#mission_listener_trigger_data.value =:= ?MISSON_EVENT_ADD_FRIEND of
                true -> %% 加入门派和加好友特殊事件自动完成任务处理，此任务不可以配置道具奖励
                    Line = common_role_line_map:get_role_line(RoleID),
                    DataIn = #m_mission_do_tos{id = PInfo#p_mission_info.id,
                                               npc_id = 0,
                                               prop_choose = (MissionBaseInfo#mission_base_info.reward_data)#mission_reward_data.prop_reward_formula,
                                               int_list_1 = [],int_list_2 = []},
                    common_misc:send_to_rolemap(RoleID,{mod_mission_handler,{?MISSION_DO, ?DEFAULT_UNIQUE, RoleID, Line, DataIn}});
                _ ->
                    ignore
            end;
        _ ->
            ignore
    end,
    TransResult.


%%@doc 如果是刚接任务 加侦听器
i_deal_listener(PInfo, _RequestRecord) ->
	CurrentModelStatus = PInfo#p_mission_info.current_model_status,
	MaxModelStatus = MissionBaseInfo#mission_base_info.max_model_status,
	
	if
		CurrentModelStatus =:= ?MISSION_MODEL_STATUS_FIRST ->
			ListenerListConfig = MissionBaseInfo#mission_base_info.listener_list,
			ListenerList = 
				lists:map(fun(ListenerDataConfig) ->
								  #mission_listener_data{type=ListenerType,value=ListenerValue,
														 need_num=NeedNum,int_list=IntList} = ListenerDataConfig,
								  %%道具侦听器
								  mod_mission_data:join_to_listener(RoleID, MissionID, ListenerType, ListenerValue),
								  %%直接将玩家侦听器数据设置为已经满足要求
								  #p_mission_listener{type=ListenerType,
													  value=ListenerValue,
													  int_list=IntList,
													  need_num=NeedNum,
													  current_num=0}
						  end, ListenerListConfig),
			%%怪物ID/怪物当前数量/所需数量
			PInfo#p_mission_info{listener_list=ListenerList};
		CurrentModelStatus =:= MaxModelStatus ->
			%%任务即将提交 删除侦听器
			ListenerList = PInfo#p_mission_info.listener_list,
			i_remove_all_listener(ListenerList),
			PInfo;
		true ->
			PInfo
	end.

change_status_for_trigger(Listener,PInfo,AddStep) when is_integer(AddStep)->
	ListenerList2=[Listener#p_mission_listener{current_num=1}],
	NewPInfo = PInfo#p_mission_info{listener_list=ListenerList2},
	mission_model_common:change_model_status(RoleID, MissionID, MissionBaseInfo, NewPInfo, AddStep).

i_trigger_event([], _PInfo, _SpecialEventId) ->
	ignore;
i_trigger_event([Listener], PInfo, _SpecialEventId) ->
	MaxModelStauts = MissionBaseInfo#mission_base_info.max_model_status,
	CurrentModelStatus = PInfo#p_mission_info.current_model_status,
	
	if
		MaxModelStauts =:= CurrentModelStatus->
			ignore;
		true->
			change_status_for_trigger(Listener,PInfo,+1)
	end.

%%@doc 删除所有侦听器
i_remove_all_listener(ListenerList) ->
	lists:foreach(
	  fun(ListenerData) ->
			  ListenerType = ListenerData#p_mission_listener.type,
			  ListenerValue = ListenerData#p_mission_listener.value,
			  
			  mod_mission_data:remove_from_listener(
				RoleID, MissionID, 
				ListenerType, ListenerValue)
	  
	  end, ListenerList).
    
%%@doc 初始化任务pinfo
%%@return #p_mission_info{} | false
init_pinfo(OldPInfo) -> 
    NewPInfo = mission_model_common:init_pinfo(RoleID, OldPInfo, MissionBaseInfo),
    CurrentStatus = NewPInfo#p_mission_info.current_model_status,
    if
        CurrentStatus =/= ?MISSION_MODEL_STATUS_FIRST ->
            NewPInfo;
        true ->
            case auth_show(NewPInfo) of
                true->
                    NewPInfo;
                _ ->
                    false
           end
    end.