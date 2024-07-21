%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     test_mod_exchange
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------

-module(test_mod_exchange).

%%
%% Include files
%%
 
 
-define( INFO(F,D),io:format(F, D) ).
-compile(export_all).
-include("common.hrl").

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%

test_suite()->
    ok = test_gen_json_goods_list(),
    ok.


test_gen_json_goods_list()->
    GoodsList = [
                 #p_goods{typeid=10001,current_num=2},
                 #p_goods{typeid=10002,current_num=4}
                 ],
    R = mod_exchange:gen_json_goods_list(GoodsList),
    ?INFO("~s",[R]).

test_npc_deal(RoleID)->
    DataIn = #m_exchange_npc_deal_tos{deal_id=3,sub_id=1},
    Msg = {0,?EXCHANGE,?EXCHANGE_NPC_DEAL,DataIn,RoleID,pid,1},
    common_misc:send_to_rolemap(1,Msg).



  
  
  
  