%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 11 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_buff).

-include("common.hrl").

%% API
-export([
         add_family_double_exp/2,
         add_faction_multiple_exp/3
        ]).


%%  ID号定义在buffs.config 中，type(91)定义在buff_type.config文件中
-define(WAROFKING_DOUBLE_EXP_BUFFID, 10542).


%%增加双倍buff
add_family_double_exp(family, FamilyID) -> 
    case global:whereis_name(mgeew_system_buff) of
        undefined ->
            ignore;
        PID ->
            PID ! {add_family_exp_buff, FamilyID, 2, 7200}
    end.

%% @doc 增加双倍buff
add_faction_multiple_exp(FactionID, Multiple, LastTime) ->
    case global:whereis_name(mgeew_system_buff) of
        undefined ->
            ignore;
        PID ->
            PID ! {add_faction_exp_buff, FactionID, Multiple, LastTime}
    end.
