%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     任务更新的hook
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(hook_mission_update).
-export([hook/3]).

%%
%% Include files
%%
-include("mission.hrl"). 


%% ====================================================================
%% API functions
%% ====================================================================

%%@doc 任务的hook入口
hook(HookType,RoleID,MissionBaseInfo) ->
    #mission_base_info{id=MissionID,type=MissionType,max_do_times=MaxDoTimes} = MissionBaseInfo,
    {ok,#p_role_attr{level=RoleLevel}} = mod_map_role:get_role_attr(RoleID),
    case MissionType =:= ?MISSION_TYPE_MAIN andalso HookType =:= mission_commit of
        true -> %% 玩家完成主线任务
            ?TRY_CATCH(mod_mission_fb:hook_mission_complete(MissionID),MissionFbHookError);
         _ ->
             ignore
    end,  
    do_hook(HookType,{RoleID,RoleLevel,MissionID,MissionType,MaxDoTimes}).
        

%%call backs
%%任务已接受：
do_hook(mission_accept,MissionLogArgs) ->
    common_mission_logger:log_accept(MissionLogArgs);

%%任务已取消：
do_hook(mission_cancel,MissionLogArgs)->
    common_mission_logger:log_cancel(MissionLogArgs);

%%任务已完成(处于可提交状态，但未提交)：
do_hook(mission_finish, MissionLogArgs) ->
    common_mission_logger:log_finish(MissionLogArgs);

%%任务已提交，即领奖
do_hook(mission_commit,{RoleID,_RoleLevel,MissionID,?MISSION_TYPE_LOOP,_}) ->
    %% 循环任务只处理活动奖励，不记录日志啦
    ?TRY_CATCH( do_hook_commit_loop_mission(RoleID, MissionID) );
do_hook(mission_commit, MissionLogArgs) ->
    %% 只记录非循环任务
    common_mission_logger:log_commit(MissionLogArgs).



%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

%%@doc 完 成循环任务之后，增加相应活跃度
do_hook_commit_loop_mission(RoleID, MissionID)->
    %% 20001 除恶令
    %% 20002 守边 
    %% 20003 刺探
    SpecialActIDList = [?ACTIVITY_TASK_CHUELING,
                        ?ACTIVITY_TASK_SHOUBIAN,
                        ?ACTIVITY_TASK_SPY],
    do_hook_commit_loop_mission_2(RoleID,MissionID,SpecialActIDList).

%%@param RoleID::integer()
%%@param MissionID::integer()
%%@param SpecialActIDList::list()
do_hook_commit_loop_mission_2(_RoleID,_MissionID,[])->
    ok;
do_hook_commit_loop_mission_2(RoleID,MissionID,[SpecialActTaskID|T])->
    case lists:member(MissionID, get_missn_id_list(SpecialActTaskID)) of
        true->  
            hook_activity_task:done_task(RoleID,SpecialActTaskID),
            hook_activity_map:hook_mission(RoleID,SpecialActTaskID),
            ok;
        _ ->
            do_hook_commit_loop_mission_2(RoleID,MissionID,T)
    end.

%%@doc 从任务配置中获取对应的任务ID列表
%%     任务对应的key配置在activity_mission.config中
get_missn_id_list(Key)->
    case common_config_dyn:find(activity_mission,Key) of
        [#r_activity_mission{mission_id_list=MissionIDList}] ->
            MissionIDList;
        _ ->
            []
    end.


