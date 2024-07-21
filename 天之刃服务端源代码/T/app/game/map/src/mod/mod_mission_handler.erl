%% Author: chixiaosheng
%% Created: 2011-3-27
%% Description:  mod_mission_handler
-module(mod_mission_handler).

%%
%% Include files
%%
-include("mission.hrl").

%%
%% Exported Functions
%%
-export([handle/1,
         reload_pinfo_list/1]).

%%
%% API Functions
%%
%% --------------------------------------------------------------------
%% 请求任务列表
%% --------------------------------------------------------------------
handle({?MISSION_LIST, Unique, RoleID, Line, DataIn}) ->
    get_list({Unique, ?MISSION, ?MISSION_LIST, DataIn, RoleID, Line});

%% --------------------------------------------------------------------
%% 请求执行任务
%% --------------------------------------------------------------------
handle({?MISSION_DO, Unique, RoleID, Line, DataIn}) ->
    do({Unique, ?MISSION, ?MISSION_DO, DataIn, RoleID, Line});

%% --------------------------------------------------------------------
%% 请求取消任务
%% --------------------------------------------------------------------
handle({?MISSION_CANCEL, Unique, RoleID, Line, DataIn}) ->
    cancel({Unique, ?MISSION, ?MISSION_CANCEL, DataIn, RoleID, Line});

%% --------------------------------------------------------------------
%% 委托任务
%% --------------------------------------------------------------------
handle({?MISSION_LIST_AUTO=Method, Unique, RoleID, Line, DataIn}) ->
    mod_mission_auto:handle_list_auto({Unique, ?MISSION, Method, DataIn, RoleID, Line});
handle({?MISSION_DO_AUTO=Method, Unique, RoleID, Line, DataIn}) ->
    mod_mission_auto:handle_do_auto({Unique, ?MISSION, Method, DataIn, RoleID, Line});


%%怪物侦听器触发
handle({listener_dispatch, monster_dead, RoleID, MonsterType}) -> 
    case mod_mission_data:get_listener(RoleID, ?MISSION_LISTENER_TYPE_MONSTER, MonsterType) of
        false ->
            ignore;
        ListenerTrigger ->
            MissionList = ListenerTrigger#mission_listener_trigger_data.mission_id_list,
            Result = b_mission_model:dispatch_listener(RoleID, MissionList, ListenerTrigger),
            catch_listener_error(RoleID, Result)
    end;

%%道具侦听器触发
handle({listener_dispatch, prop_decreate, RoleID, PropTypeID}) ->
    do_trigger_prop_listener(RoleID, ?MISSION_LISTENER_TYPE_PROP, PropTypeID);
handle({listener_dispatch, prop_create, RoleID, PropTypeID}) ->
    do_trigger_prop_listener(RoleID, ?MISSION_LISTENER_TYPE_PROP, PropTypeID);
handle({listener_dispatch, prop_reinforce, RoleID, _PropTypeID,ReinforceResult}) ->
    do_trigger_reinforce_listener(RoleID, ?MISSION_LISTENER_TYPE_REINFORCE, ReinforceResult);
handle({listener_dispatch, prop_shop_buy, RoleID, PropTypeID}) ->
    do_trigger_prop_listener(RoleID, ?MISSION_LISTENER_TYPE_BUY_PROP, PropTypeID);
handle({listener_dispatch, special_event, RoleID, SpecialMissionEventId}) ->
    do_trigger_special_event_listener(RoleID, ?MISSION_LISTENER_TYPE_SPECIAL_EVENT, SpecialMissionEventId);
handle({listener_dispatch, prop_change_quality, RoleID, _PropTypeID,QualityResult}) ->
    do_trigger_reinforce_listener(RoleID, ?MISSION_LISTENER_TYPE_CHANGE_QUALITY, QualityResult);
handle({listener_dispatch, give_use_prop, RoleID, PropTypeID}) ->
    do_trigger_give_use_prop_listener(RoleID, ?MISSION_LISTENER_TYPE_GIVE_USE_PROP, PropTypeID);  
handle({listener_dispatch, role_level_up, RoleID, Level}) ->
    do_trigger_level_listener(RoleID, ?MISSION_LISTENER_TYPE_ROLE_LEVEL, Level),
    reload_pinfo_list(RoleID);

%%门派改变了
handle({listener_dispatch, family_changed, _RoleID, _NewFamilyID, _OldFamilyID}) ->
    ok;
    %%reload_pinfo_list(RoleID);
%%后台设置某个任务完成状态
handle({gm_complete_mission,RoleID,MissionID}) ->
    do_gm_complete_mission(RoleID,MissionID);

handle(UNMatchData) ->
    ?ERROR_MSG("~ts:~w", ["任务相关请求处理失败", UNMatchData]).


%%
%% Local Functions
%%

do_gm_complete_mission(RoleID,MissionID)->
	TransFun = fun() ->
					   do_complete_mission_2(RoleID,MissionID)
			   end,
	case common_transaction:transaction(TransFun) of
		{atomic,Result}->
			?ERROR_MSG("do_complete_mission success,RoleID=~w,MissionID=~w,Result=~w",[RoleID,MissionID,Result]),
			mod_mission_unicast:c_unicast(RoleID),
			mod_mission_misc:c_trans_func(RoleID),
			{atomic, Result};
		{aborted,{throw,{bag_error,not_enough_pos}=R2}}->
			?ERROR_MSG("do_complete_mission aborted,bag_error",[]),
			mod_mission_unicast:r_unicast(RoleID),
			mod_mission_misc:r_trans_func(RoleID),
			{aborted,R2};
		{aborted,{bag_error,not_enough_pos}=R3}->
			?ERROR_MSG("do_complete_mission aborted,not_enough_posr",[]),
			mod_mission_unicast:r_unicast(RoleID),
			mod_mission_misc:r_trans_func(RoleID),
			{aborted,R3};
		{aborted,Result}->
			?ERROR_MSG("transaction aborted,RoleID=~w,Result=~w,MissionID=~w",[RoleID,Result,MissionID]),
			mod_mission_unicast:r_unicast(RoleID),
			mod_mission_misc:r_trans_func(RoleID),
			{aborted,Result}
	end.

do_complete_mission_2(RoleID,MissionID)->
	case mod_mission_data:get_pinfo(RoleID, MissionID) of
		false->
			ignore;
		_ ->
			MissionBaseInfo = mod_mission_data:get_base_info(MissionID),
			#mission_base_info{reward_data=RewardData} = MissionBaseInfo,
			case is_record(RewardData,mission_reward_data) of
				true->
					#mission_reward_data{prop_reward=PropRewardList} = RewardData,
					case is_list(PropRewardList) andalso length(PropRewardList)>0 of
						true->
							[#p_mission_prop{prop_id=PropId}|_T] = PropRewardList,
							PropChoose=[PropId];
						_ ->
							PropChoose = []
					end;
				_ ->
					PropChoose = []
			end,
			RequestRecord = #m_mission_do_tos{id=MissionID,npc_id=0,prop_choose=PropChoose},
			mission_model_common:common_complete(RoleID, MissionID,MissionBaseInfo,RequestRecord)
	end.



-define(MISSION_UNICAST_TOC(DataRecordReturn),
        mod_mission_unicast:p_unicast(RoleID, Unique, Module, Method, DataRecordReturn),
        mod_mission_unicast:c_unicast(RoleID, Line)).

reload_pinfo_list(RoleID)->
    MissionData = mod_mission_data:get_mission_data(RoleID),
    case mod_mission_data:reload_role_pinfo_list(RoleID, MissionData) of
        {error,_}->
            ignore;
        NewPInfoList ->
            VS = mod_mission_data:get_vs(),
            TransFun = fun()-> 
                               mod_mission_data:set_pinfo_list(RoleID, NewPInfoList, VS)
                       end,
            case common_transaction:transaction( TransFun ) of
                {atomic,_} -> 
                    ok;
                {aborted,TransErr}->
                    throw(TransErr)
            end,
            
            DataRecordReturn = #m_mission_list_toc{code=?MISSION_CODE_SUCC, code_data=[], list=NewPInfoList},
            mod_mission_unicast:p_unicast(RoleID, ?DEFAULT_UNIQUE, ?MISSION, ?MISSION_LIST, DataRecordReturn),
            Line = common_misc:get_role_line_by_id(RoleID),
            mod_mission_unicast:c_unicast(RoleID, Line)
    end.

get_list({Unique, Module, Method, RequestRecord, RoleID, Line}) ->
    DataRecordReturn = 
        try
            MissionData = mod_mission_data:get_mission_data(RoleID),
            RoleMissionDataVS = MissionData#mission_data.data_version,
            VS = mod_mission_data:get_vs(),
                if
                RoleMissionDataVS =/= VS ->
                    NewPInfoList = mod_mission_data:reload_role_pinfo_list(RoleID, MissionData),
                        TransFun = fun()-> 
                                    mod_mission_data:set_pinfo_list(RoleID, NewPInfoList, VS) 
                                   end,
                        case common_transaction:transaction( TransFun ) of
                        {atomic, _} -> 
                            ok;
                            {aborted,TransErr}->
                                throw(TransErr)
                    end;
                    true ->
                    NewPInfoList = MissionData#mission_data.mission_list
                end,
            #m_mission_list_toc{code=?MISSION_CODE_SUCC,code_data=[], list=NewPInfoList}
        catch
            _:CError->
                catch_list_error(CError,RoleID,RequestRecord)
        
        end,
    ?MISSION_UNICAST_TOC(DataRecordReturn).

do({Unique, Module, Method, RequestRecord, RoleID, Line}) ->
    DataRecordReturn = 
        try
            case b_mission_model:do(RoleID, RequestRecord) of
                {atomic, DoSuccRecordReturn} ->
                    DoSuccRecordReturn;
                {aborted,AbortedError}->
                    catch_do_error(AbortedError,RoleID,RequestRecord)
            end
        catch
            _:CError->
                catch_do_error(CError,RoleID,RequestRecord)
        end,
    ?MISSION_UNICAST_TOC(DataRecordReturn).

cancel({Unique, Module, Method, RequestRecord, RoleID, Line}) ->
    DataRecordReturn = 
        try
            case b_mission_model:cancel(RoleID, RequestRecord) of
                {atomic, DoSuccRecordReturn} ->
                    DoSuccRecordReturn;
                {aborted,AbortedError}->
                    catch_cancel_error(AbortedError,RoleID,RequestRecord)
            end
        catch
            _:CError->
                catch_cancel_error(CError,RoleID,RequestRecord)
        end,
    ?MISSION_UNICAST_TOC(DataRecordReturn).


%%%===================================================================
%%% Internal functions
%%%===================================================================

catch_list_error({man, ReasonCode, ReasonCodeData},RoleID,RequestRecord)->
    ?ERROR_MSG("~ts-->~nRoleID:~w~n RequestRecord:~w~n ReasonCode:~w~n ReasonCodeData:~w~n StackTrace:~w~n<--", 
               ["玩家获取任务列表发生了逻辑错误", RoleID, RequestRecord, 
                ReasonCode, ReasonCodeData, erlang:get_stacktrace()]),
    #m_mission_list_toc{code=ReasonCode, code_data=ReasonCodeData};
catch_list_error(Error,RoleID,RequestRecord)->
    ?ERROR_MSG("~ts-->~nRoleID:~w~n RequestRecord:~w~n Error:~w~n StackTrace:~w~n<--", 
               ["玩家获取任务列表发生了系统级别错误", RoleID, RequestRecord, 
                Error, erlang:get_stacktrace()]),
    #m_mission_list_toc{code=?MISSION_CODE_FAIL_SYS, code_data=[]}.


catch_do_error({man, ReasonCode, ReasonCodeData},_RoleID,RequestRecord)->
%%     ?ERROR_MSG("玩家执行任务发生了逻辑错误-->~nRoleID:~w~n RequestRecord:~w~n ReasonCode:~w~n ReasonCodeData:~w~n StackTrace:~w~n<--", 
%%                [RoleID, RequestRecord,ReasonCode, ReasonCodeData, erlang:get_stacktrace()]),
    MissionID = RequestRecord#m_mission_do_tos.id,
    #m_mission_do_toc{id=MissionID, code=ReasonCode, code_data=ReasonCodeData};
catch_do_error({bag_error,not_enough_pos},RoleID,RequestRecord)->
    MissionID = RequestRecord#m_mission_do_tos.id,
    common_broadcast:bc_send_msg_role(RoleID,?BC_MSG_TYPE_SYSTEM,?_LANG_MISSION_BAG_FULL),
    #m_mission_do_toc{id=MissionID, code=?MISSION_CODE_FAIL_BAG_NOT_ENOUGH_POS, code_data=[]};
catch_do_error(Error,RoleID,RequestRecord)->
    ?ERROR_MSG("玩家执行任务发生了系统级别错误-->~nRoleID:~w~n RequestRecord:~w~n Error:~w~n StackTrace:~w~n<--", 
               [RoleID, RequestRecord,  Error, erlang:get_stacktrace()]),
    MissionID = RequestRecord#m_mission_do_tos.id,
    #m_mission_do_toc{id=MissionID, code=?MISSION_CODE_FAIL_SYS, code_data=[]}.


catch_cancel_error({man, ReasonCode, ReasonCodeData},_RoleID,RequestRecord)->
%%     ?ERROR_MSG("玩家取消任务发生了逻辑错误-->~nRoleID:~w~n RequestRecord:~w~n ReasonCode:~w~n ReasonCodeData:~w~n StackTrace:~w~n<--", 
%%                [RoleID, RequestRecord,ReasonCode, ReasonCodeData, erlang:get_stacktrace()]),
    MissionID = RequestRecord#m_mission_cancel_tos.id,
    #m_mission_cancel_toc{id=MissionID, code=ReasonCode, code_data=ReasonCodeData};
catch_cancel_error({bag_error,not_enough_pos},RoleID,RequestRecord)->
    MissionID = RequestRecord#m_mission_cancel_tos.id,
    common_broadcast:bc_send_msg_role(RoleID,?BC_MSG_TYPE_SYSTEM,?_LANG_MISSION_BAG_FULL),
    #m_mission_cancel_toc{id=MissionID, code=?MISSION_CODE_FAIL_BAG_NOT_ENOUGH_POS, code_data=[]};
catch_cancel_error(Error,RoleID,RequestRecord)->
    ?ERROR_MSG("玩家取消任务发生了系统级别错误-->~nRoleID:~w~n RequestRecord:~w~n Error:~w~n StackTrace:~w~n<--", 
               [RoleID, RequestRecord,  Error, erlang:get_stacktrace()]),
    MissionID = RequestRecord#m_mission_cancel_tos.id,
    #m_mission_cancel_toc{id=MissionID, code=?MISSION_CODE_FAIL_SYS, code_data=[]}.


catch_listener_error(RoleID, {aborted, {bag_error,not_enough_pos}}) ->
   Code = ?MISSION_CODE_FAIL_BAG_NOT_ENOUGH_POS,
   CodeData = [],
   do_notify_listener_error(RoleID, Code, CodeData);
catch_listener_error(RoleID, {aborted, {?MISSION_ERROR_MAN, Code, CodeData}}) ->
   do_notify_listener_error(RoleID, Code, CodeData);
catch_listener_error(_, _) ->
   ignore.

do_notify_listener_error(RoleID, Code, CodeData) ->
   DataRecord = #m_mission_listener_toc{code=Code, code_data=CodeData},
   mod_mission_unicast:p_unicast(RoleID, ?DEFAULT_UNIQUE, ?MISSION, ?MISSION_LISTENER, DataRecord),
   mod_mission_unicast:c_unicast(RoleID).

do_trigger_prop_listener(RoleID, ListenerType, PropTypeID) ->
    case mod_mission_data:get_listener(RoleID, ListenerType, PropTypeID) of
        false ->
            ignore;
        ListenerTrigger ->
            MissionList = ListenerTrigger#mission_listener_trigger_data.mission_id_list,
            Result = b_mission_model:dispatch_listener(RoleID, MissionList, ListenerTrigger),
            catch_listener_error(RoleID, Result)
    end.

do_trigger_reinforce_listener(RoleID,ListenerType, PropValue)->
    case mod_mission_data:get_listener_greate_than(RoleID, ListenerType, PropValue) of
        false ->
            ignore;
        ListenerTrigger ->
            MissionList = ListenerTrigger#mission_listener_trigger_data.mission_id_list,
            Result = b_mission_model:dispatch_listener(RoleID, MissionList, ListenerTrigger),
            catch_listener_error(RoleID, Result)
    end.

do_trigger_level_listener(RoleID, ListenerType, NewLevel) ->
    case mod_mission_data:get_listener_greate_than(RoleID, ListenerType, NewLevel) of
        false ->
            ignore;
        ListenerTrigger ->
            MissionList = ListenerTrigger#mission_listener_trigger_data.mission_id_list,
            Result = b_mission_model:dispatch_listener(RoleID, MissionList, ListenerTrigger),
            catch_listener_error(RoleID, Result)
    end.

do_trigger_special_event_listener(RoleID, ListenerType, SpecialMissionEventId)->
	case mod_mission_data:get_listener(RoleID, ListenerType, SpecialMissionEventId) of
		false ->
			ignore;
		ListenerTrigger ->
			MissionList = ListenerTrigger#mission_listener_trigger_data.mission_id_list,
			Result = b_mission_model:dispatch_listener(RoleID, MissionList, ListenerTrigger),
			catch_listener_error(RoleID, Result)
	end.

do_trigger_give_use_prop_listener(RoleID, ListenerType, PropTypeID) ->
    case mod_mission_data:get_listener(RoleID, ListenerType, PropTypeID) of
        false ->
            ignore;
        ListenerTrigger ->
            MissionList = ListenerTrigger#mission_listener_trigger_data.mission_id_list,
            Result = b_mission_model:dispatch_listener(RoleID, MissionList, ListenerTrigger),
            catch_listener_error(RoleID, Result)
    end.

  
