%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 24 Nov 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_npc).

%% API
-export([
         get_family_ybc_npc_pos/0,
         get_family_publish_npc_pos/0
        ]).


%% 获取门派拉镖交镖NPC的坐标：边城 蓝玉
get_family_ybc_npc_pos() ->
    [NpcPos] = common_config_dyn:find(server_pos,family_ybc_commiter),
    NpcPos.


%% 获取门派接镖的NPC的位置
get_family_publish_npc_pos() ->
    [NpcPos] = common_config_dyn:find(server_pos,family_ybc_publisher),
    NpcPos.