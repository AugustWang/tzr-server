%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2011, 
%%% @doc
%%%
%%% @end
%%% Created : 21 Jan 2011 by  <>
%%%-------------------------------------------------------------------
-module(hook_refining_compose).

-include("mgeem.hrl").

-export([hook/1]).

hook({RoleID,NextLevelID}) ->
    hook_achievement(RoleID,NextLevelID),
    ok.


%% 成就 add by caochuncheng 2011-03-07
%% TypeId 合成成就的物品类型id
hook_achievement(RoleId,TypeId) ->
    EventIdList = [304007],
    %% 六级附加材料类型id
    AddGoodsTypeIdList = [10402126,10402226,10402326,10402426,10402526],
    EventIdList2 = 
        case lists:member(TypeId,AddGoodsTypeIdList) of
            true ->
                [304008|EventIdList];
            false ->
                EventIdList
        end,
    %% 六级宝石类型id
    StoneTypeIdList = [20100006,20200006,20300006,20400006,20500006,20600006,20700006,20800006,20900006,
                       21000006,21100006,21200006,21300006,21400006,21500006,21600006,21700006,21800006],
    EventIdList3 = 
        case lists:member(TypeId,StoneTypeIdList) of
            true ->
                [304009|EventIdList2];
            false ->
                EventIdList2
        end,
    if EventIdList3 =/= [] ->
            catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = EventIdList3});
       true ->
            ignore
    end,
    ok.
