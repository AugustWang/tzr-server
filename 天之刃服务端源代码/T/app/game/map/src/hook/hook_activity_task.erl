%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     hook_activity_task 跟日常活动、日常福利、玩家的活跃度有关的Hook
%%% @end
%%% Created : 2010-11-17
%%%-------------------------------------------------------------------
-module(hook_activity_task).
-include("mgeem.hrl").

-define(MAX_ROLE_ACTPOINT,27).  %%玩家的最高活跃度

%% API
-export([
         handle/2,
         done_task/2,
         reset_all_online_actpoint/1
        ]). 

handle({done_task,{RoleID,ActivityKey}},_State)->
    done_task(RoleID,ActivityKey);
handle({set_ap,{RoleID,NewActivePt}},_State)->
    set_ap(RoleID,NewActivePt);
handle(Msg,_State)->
    ?ERROR_MSG("unknown message,Msg=~w",[Msg]),
    ignore.

%%%===================================================================
%%% API
%%%===================================================================

%%@doc 每天凌晨重置在线玩家的活跃度
reset_all_online_actpoint( MapRoleIDList ) when is_list(MapRoleIDList)->
    lists:foreach(fun(RoleID)-> 
                          db:dirty_delete(?DB_ROLE_ACTIVITY_BENEFIT,RoleID),
                          db:dirty_delete(?DB_ROLE_ACTIVITY_TASK,RoleID),
                          TransFun = fun()-> 
                                             case mod_map_role:get_role_attr(RoleID) of
                                                 {ok,RoleAttr} ->
                                                     RoleAttr2 = RoleAttr#p_role_attr{active_points=0},
                                                     mod_map_role:set_role_attr(RoleID,RoleAttr2);
                                                 _ ->
                                                     ignore
                                             end
                                     end,
                          case common_transaction:transaction( TransFun ) of
                              {atomic, _} ->
                                  notify_ap_change(RoleID,0);
                              {aborted, Error} ->
                                  ?ERROR_MSG_STACK("reset_all_online_actpoint error",Error)
                          end  
                  end, MapRoleIDList).

%%@doc 玩家完成相应的任务
%%   增加活跃度，设置任务的完成次数、日常任务福利
%%   注：讨伐敌营、大明宝藏是不增加玩家活跃度的和任务次数的！！
done_task(RoleID,ActTaskID) when is_integer(RoleID) andalso is_integer(ActTaskID)->   
    try
        case common_config_dyn:find(activity_today,ActTaskID) of
            []-> 
                ignore;
            [#r_activity_today{add_ap=0}]->
                mod_activity:do_finish_task(RoleID,ActTaskID);
            [#r_activity_today{add_ap=Apt}]->
                do_add_actpoint(RoleID,Apt),
                mod_activity:do_finish_task(RoleID,ActTaskID)
        end
    catch
        _:Reason->
            ?ERROR_MSG_STACK("done_task",Reason)
    end.

%% ====================================================================
%% Internal functions
%% ====================================================================

%%@doc 重新设置活跃度，GM专用
set_ap(RoleID,NewActivePt) when is_integer(NewActivePt) ->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    do_set_actpoint(RoleID,RoleAttr,NewActivePt).

%%@doc 事务性增加活跃度
do_add_actpoint(RoleID,AddActivePt) when is_integer(RoleID)->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{active_points=OldActivePt} = RoleAttr,
    NewActivePt = if
                      OldActivePt+AddActivePt>?MAX_ROLE_ACTPOINT->
                          ?MAX_ROLE_ACTPOINT;
                      true->
                          OldActivePt+AddActivePt
                  end,
    TransFun = fun()-> 
                       RoleAttr2 = RoleAttr#p_role_attr{active_points=NewActivePt},
                       mod_map_role:set_role_attr(RoleID,RoleAttr2)
               end,
    case catch common_transaction:transaction( TransFun ) of
        {atomic, _ } ->
            notify_ap_change(RoleID,NewActivePt);
        {aborted, Reason} ->
            ?ERROR_MSG_STACK("do_add_actpoint,Error,Reason=~w",Reason)
    end.

%%@doc 事务性修改活跃度
do_set_actpoint(RoleID,RoleAttr,NewActivePt)->
    Rec = RoleAttr#p_role_attr{active_points=NewActivePt},
    case catch common_transaction:transaction( 
           fun()-> mod_map_role:set_role_attr(RoleID,Rec) end ) of
        {atomic, _ } ->
            notify_ap_change(RoleID,NewActivePt);
        {aborted, Reason} ->
            ?ERROR_MSG("do_set_actpoint,Error,Reason=~w",[Reason])
    end.

%%@doc 通知前端更新活跃度
notify_ap_change(RoleID,NewActivePt)->
    ChangeAttList = [#p_role_attr_change{change_type=?ROLE_ACTIVE_POINTS_CHANGE,new_value=NewActivePt} ],
    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttList).

 
