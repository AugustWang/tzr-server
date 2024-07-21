%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com(C) 2010, 
%%% @doc
%%% 公用的成就监听处理
%%% @end
%%% Created : 11 Nov 2010 by  <>
%%%-------------------------------------------------------------------
-module(common_achievement).

-include("common.hrl").
-include("common_server.hrl").

-export([
         hook/1
        ]).

hook(HookRecord) 
  when erlang:is_record(HookRecord,r_achievement_hook) ->
    ?DEBUG("~ts,HookRecord=~w",["接收到的数据为",HookRecord]),
    do_hook(HookRecord);

hook(Info) ->
    ?INFO_MSG("~ts,Info=~w",["此消息成就模块不处理",Info]),
    ok.
do_hook(RAHookRecord) ->
    ConfigEventIdList = common_config_dyn:list(achievement_event),
    {EventIdList,RankEventIdList} =
        lists:foldl(
          fun(EventId,{AccEventIdList,AccRankEventIdList}) ->
                  case lists:keyfind(EventId,#r_achievement_event.event_id,ConfigEventIdList) of
                      false ->
                          ?INFO_MSG("~ts,EventId=~w",["发现不合法的成就事件id",EventId]),
                          {AccEventIdList,AccRankEventIdList};
                      #r_achievement_event{event_type = EventType}  ->
                          if EventType =:= 1 ->
                                  {[EventId|AccEventIdList],AccRankEventIdList};
                             EventType =:= 2 ->
                                  {AccEventIdList,[EventId|AccRankEventIdList]};
                             true ->
                                  {AccEventIdList,AccRankEventIdList}
                          end
                  end
          end,{[],[]},RAHookRecord#r_achievement_hook.event_ids),
    if EventIdList =/= [] -> %% 一般成就处理
            do_hook3(RAHookRecord#r_achievement_hook{event_ids = EventIdList});
       true ->
            ignore
    end,
    if RankEventIdList =/= [] ->
            [AchievementRankMapId] = common_config_dyn:find(achievement_hook,achievement_rank_map_id),
            global:send(common_map:get_common_map_name(AchievementRankMapId),
                        {mod_achievement,
                         {achievement_rank_event,
                          {RAHookRecord#r_achievement_hook.role_id,RankEventIdList,AchievementRankMapId}}});
       true ->
            ignore
    end,
    ok.
do_hook3(RAHookRecord) ->
    #r_achievement_hook{role_id = RoleId,
                        event_ids = EventIds,
                        add_progress = AddProgress} = RAHookRecord,
    DataRecord = #m_achievement_notice_tos{event_ids = EventIds,add_progress = AddProgress},
    common_misc:send_to_rolemap(RoleId,{mod_achievement,{system_achievement_event_notic,RoleId,DataRecord}}).
