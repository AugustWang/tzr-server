%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2011, 
%%% @doc
%%%     节日活动跟讨伐敌营副本
%%% @end
%%% Created : 22 Jan 2011 by  <caochuncheng>
%%%-------------------------------------------------------------------
-module(hook_activity_vwf).

-include("mgeem.hrl").

%% API
-export([
         hook/1
        ]).

%%%===================================================================
%%% API
%%%===================================================================
%% 讨伐敌营副本活动处理
%% VWFRoleLogList 结构为 [r_vwf_role_log,..]
hook({vwf_activity_hook,StartTime,EndTime,VWFRoleLogList}) ->
    ?DEV("~ts,VWFRoleLogList=~w",["本次完成副本的成员信息",VWFRoleLogList]),
    do_vwf_activity_hook(StartTime,EndTime,VWFRoleLogList);
hook(Msg) ->
    ?DEBUG("~ts,Msg=~w",["讨伐敌营副本收到的消息为",Msg]),
    ok.

get_vwf_activity_key()->
    case common_config_dyn:find(mccq_activity,activity_vwf) of 
        [[ActKey|_T]]when is_integer(ActKey)-> 
            ActKey;
        _ ->
            0
    end.


%% 讨伐敌营副本活动处理
%% VWFRoleLogList 结构为 [r_vwf_role_log,..]
do_vwf_activity_hook(StartTime,EndTime,VWFRoleLogList) ->
    case common_activity:get_activity_config_by_name(activity_vwf) of
        [ActivityVwf] when is_record(ActivityVwf,r_role_activity_vwf)->
            do_vwf_activity_hook2(StartTime,EndTime,VWFRoleLogList,ActivityVwf);
        _ ->
            ignore
    end.

%% VWFRoleLogList 结构为 [r_vwf_role_log,..]
%% ActivityVwf 结构为 r_role_activity_vwf
do_vwf_activity_hook2(StartTime,EndTime,VWFRoleLogList,ActivityVwf) ->
    ?DEV("~ts,ActivityVwf=~w",["本次活动信息",ActivityVwf]),
    #r_role_activity_vwf{complete_seconds = CompleteSeconds} = ActivityVwf,
    if StartTime =/= 0 andalso EndTime =/= 0
       andalso (EndTime - StartTime) =< CompleteSeconds  ->
            do_vwf_activity_hook3(StartTime,EndTime,VWFRoleLogList,ActivityVwf);
       true ->
            ignore
    end.
do_vwf_activity_hook3(StartTime,EndTime,VWFRoleLogList,ActivityVwf) ->
    [LeaderRecord|_T] = VWFRoleLogList,
    #r_vwf_role_log{faction_id = FactionId,
                    map_name = MapName,
                    leader_role_name = LeaderRoleName} = LeaderRecord,
    MapName2 = 
        if FactionId =:= 1 ->
                lists:append(["<font color=\"#00FF00\">",MapName,"</font>"]);
           FactionId =:= 2 ->
                lists:append(["<font color=\"#F600FF\">",MapName,"</font>"]);
           FactionId =:= 3 ->
                lists:append(["<font color=\"#00CCFF\">",MapName,"</font>"]);
           true ->
                MapName
        end,
    CenterMessage = lists:flatten(io_lib:format(?_LANG_ACTIVITY_VWF_CENTER,[ common_tool:to_list(LeaderRoleName),MapName2])),
    ChatMessage = lists:flatten(io_lib:format(?_LANG_ACTIVITY_VWF_CHAT,[ common_tool:to_list(LeaderRoleName),MapName2])),
    catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,CenterMessage),
    catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,ChatMessage),
    do_vwf_activity_hook4(StartTime,EndTime,VWFRoleLogList,ActivityVwf).
%% 处理是否需要需要奖励
do_vwf_activity_hook4(StartTime,EndTime,VWFRoleLogList,ActivityVwf) ->
    NowStartTime = common_tool:datetime_to_seconds({erlang:date(),{0,0,0}}),
    VWFRoleLogList2 = 
        lists:foldl(
          fun(VWFRoleLog,Acc) ->
                  RoleId = VWFRoleLog#r_vwf_role_log.role_id,
                  ActEventVwf = get_vwf_activity_key(),
                  case common_activity:get_dirty_role_activity_info_by_key(RoleId,ActEventVwf) of
                      {ok,ActivityInfo} ->
                          AwardTime = ActivityInfo#r_role_activity_info.award_time,
                          if AwardTime >= NowStartTime
                             andalso AwardTime < (NowStartTime + 24 * 60 * 60) ->
                                  Acc;
                             true ->
                                  [VWFRoleLog | Acc]
                          end;
                      {error,_Reason} ->
                          [VWFRoleLog | Acc]
                  end
          end,[],VWFRoleLogList),
    ?DEV("~ts,VWFRoleLogList=~w",["需要给奖励的玩家有",VWFRoleLogList2]),
    do_vwf_activity_hook5(StartTime,EndTime,VWFRoleLogList2,ActivityVwf).

do_vwf_activity_hook5(_StartTime,_EndTime,VWFRoleLogList,ActivityVwf) ->
    lists:foreach(
      fun(VWFRoleLog) ->
              case db:transaction(
                     fun() ->  
                             t_vwf_activity(VWFRoleLog,ActivityVwf)  
                     end) of
                  {atomic, {ok}} ->
                      catch send_vwf_activity_letter(VWFRoleLog,ActivityVwf);
                  {aborted, Reason} ->
                      ?ERROR_MSG("~ts,VWFRoleLog=~w,ActivityVwf=~w,Reason=~w",
                                 ["此玩家符合极速讨伐敌营系统给奖励时出错，需要运营跟进",VWFRoleLog,ActivityVwf,Reason])
              end
      end,VWFRoleLogList).

t_vwf_activity(VWFRoleLog,_ActivityVwf) ->
    RoleId = VWFRoleLog#r_vwf_role_log.role_id,
    ActivityInfo = #r_role_activity_info{
      key = get_vwf_activity_key(),
      complete_times = 1,
      complete_time = common_tool:now(),
      award_times = 1,
      award_time = common_tool:now()},
    RoleActivity =
        case db:read(?DB_ROLE_ACTIVITY,RoleId) of
            [] ->
                #r_role_activity{role_id = RoleId,activitys = []};
            RoleActivityT ->
                RoleActivityT
        end,
    ActivitysList = RoleActivity#r_role_activity.activitys,
    RoleActivity2 = 
        case lists:keyfind(ActivityInfo#r_role_activity_info.key,#r_role_activity_info.key,ActivitysList) of
            false ->
                RoleActivity#r_role_activity{activitys = [ActivityInfo|ActivitysList]};
            OldActivityInfo ->
                ActivitysList2 = lists:keydelete(ActivityInfo#r_role_activity_info.key,
                                                 #r_role_activity_info.key,
                                                 ActivitysList),
                ActivityInfo2 = ActivityInfo#r_role_activity_info{
                                  complete_times = 1 + OldActivityInfo#r_role_activity_info.complete_times,
                                  award_times = 1 + OldActivityInfo#r_role_activity_info.award_times},
                RoleActivity#r_role_activity{activitys = [ActivityInfo2|ActivitysList2]}
        end,
    db:write(?DB_ROLE_ACTIVITY,RoleActivity2,write),
    {ok}.
%% 发送信件
send_vwf_activity_letter(VWFRoleLog,ActivityVwf) ->
    RoleId = VWFRoleLog#r_vwf_role_log.role_id,
    #r_role_activity_vwf{item_type = ItemType,item_id = ItemId, item_bind = Bind,item_number = ItemNumber} = ActivityVwf,
    GoodsCreateInfo = #r_goods_create_info{
      bag_id=1, 
      position=1,
      bind=Bind,
      type=ItemType, 
      type_id= ItemId, 
      start_time=0, 
      end_time=0,
      num= ItemNumber},
    case mod_bag:create_p_goods(RoleId,GoodsCreateInfo) of
        {ok,GoodsList} ->
            GoodsList2 = [R#p_goods{id = 1} || R <- GoodsList],
            send_vwf_activity_letter2(VWFRoleLog,ActivityVwf,GoodsList2);
        {error,Reason}->
            ?ERROR_MSG("~ts,VWFRoleLog=~w,ActivityVwf=~w,Reason=~w",
                       ["此玩家符合极速讨伐敌营系统给奖励时出错，需要运营跟进，物品配置文件出错",VWFRoleLog,ActivityVwf,Reason])
    end.
send_vwf_activity_letter2(VWFRoleLog,ActivityVwf,GoodsList) ->
    RoleId = VWFRoleLog#r_vwf_role_log.role_id,
    Title = ?_LANG_ACTIVITY_VWF_LETTER_TITLE,
    ActivityDesc = ActivityVwf#r_role_activity_vwf.vwf_time_desc,
    GoodsNames = lists:append([lists:map(fun(Goods) -> common_goods:get_notify_goods_name(Goods) end,GoodsList)]),
    Text = common_letter:create_temp(?ACTIVITY_VWF_LETTER,[common_tool:to_list(ActivityDesc),GoodsNames]),
    common_letter:sys2p(Title,[RoleId],Text,GoodsList), 
    common_broadcast:bc_send_msg_role(RoleId, ?BC_MSG_TYPE_SYSTEM, ?_LANG_ACTIVITY_VWF_ROLE).
    
