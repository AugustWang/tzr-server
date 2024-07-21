%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created :  3 Nov 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(config_warofcity).

%% API
-export([
         get_apply_level/1,
         get_apply_money/1,
         get_reward_id/2
        ]).

get_apply_level(11000) ->
    1;
get_apply_level(11001) ->
    1;
get_apply_level(11101) ->
    2;
get_apply_level(11103) ->
    2;
get_apply_level(11102) ->
    3;
get_apply_level(11104) ->
    3;
get_apply_level(11100) ->
    4;
get_apply_level(12000) ->
    1;
get_apply_level(12001) ->
    1;
get_apply_level(12101) ->
    2;
get_apply_level(12103) ->
    2;
get_apply_level(12102) ->
    3;
get_apply_level(12104) ->
    3;
get_apply_level(12100) ->
    4;
get_apply_level(13000) ->
    1;
get_apply_level(13001) ->
    1;
get_apply_level(13101) ->
    2;
get_apply_level(13103) ->
    2;
get_apply_level(13102) ->
    3;
get_apply_level(13104) ->
    3;
get_apply_level(13100) ->
    4;
get_apply_level(_) ->
    error.


get_apply_money(11000) ->
    50 * 100;
get_apply_money(11001) ->
    80 * 100;
get_apply_money(11101) ->
    100 * 100;
get_apply_money(11103) ->
    200 * 100;
get_apply_money(11102) ->
    300 * 100;
get_apply_money(11104) ->
    300 * 100;
get_apply_money(11100) ->
    400 * 100;
get_apply_money(12000) ->
    50 * 100;
get_apply_money(12001) ->
    80 * 100;
get_apply_money(12101) ->
    100 * 100;
get_apply_money(12103) ->
    200 * 100;
get_apply_money(12102) ->
    300 * 100;
get_apply_money(12104) ->
    300 * 100;
get_apply_money(12100) ->
    400 * 100;
get_apply_money(13000) ->
    50 * 100;
get_apply_money(13001) ->
    80 * 100;
get_apply_money(13101) ->
    100 * 100;
get_apply_money(13103) ->
    200 * 100;
get_apply_money(13102) ->
    300 * 100;
get_apply_money(13104) ->
    300 * 100;
get_apply_money(13100) ->
    400 * 100;
get_apply_money(_) ->
    error.


%% 获取连续占领奖励

%% 太平村
get_reward_id(0, 7) ->
    1;
get_reward_id(0, 14) ->
    1;
get_reward_id(0, 21) ->
    1;
get_reward_id(0, 28) ->
    1;
get_reward_id(0, 56) ->
    1;

%% 横涧山
get_reward_id(1, 7) ->
    1;
get_reward_id(1, 14) ->
    1;
get_reward_id(1, 21) ->
    1;
get_reward_id(1, 28) ->
    1;
get_reward_id(1, 56) ->
    1;


%% 王都
get_reward_id(100, 7) ->
    1;
get_reward_id(100, 14) ->
    1;
get_reward_id(100, 21) ->
    1;
get_reward_id(100, 28) ->
    1;
get_reward_id(100, 56) ->
    1;

%% 鄱阳湖
get_reward_id(101, 7) ->
    1;
get_reward_id(101, 14) ->
    1;
get_reward_id(101, 21) ->
    1;
get_reward_id(101, 28) ->
    1;
get_reward_id(101, 56) ->
    1;

%% 平江
get_reward_id(102, 7) ->
    1;
get_reward_id(102, 14) ->
    1;
get_reward_id(102, 21) ->
    1;
get_reward_id(102, 28) ->
    1;
get_reward_id(102, 56) ->
    1;

%% 杏花岭
get_reward_id(103, 7) ->
    1;
get_reward_id(103, 14) ->
    1;
get_reward_id(103, 21) ->
    1;
get_reward_id(103, 28) ->
    1;
get_reward_id(103, 56) ->
    1;


%% 西凉
get_reward_id(104, 7) ->
    1;
get_reward_id(104, 14) ->
    1;
get_reward_id(104, 21) ->
    1;
get_reward_id(104, 28) ->
    1;
get_reward_id(104, 56) ->
    1;


get_reward_id(_, _) ->
    throw({error, wrong_get_reward_config_param}).    
