%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     mod_web_db
%%% @end
%%% Created : 2010-11-17
%%%-------------------------------------------------------------------
-module(mod_web_db_service).
-include("mgeeweb.hrl").


%% API
-export([
         start/0
        ]). 

start()->
    mod_item_service:load_item_list(),
    mod_item_service:load_map_list(),
    ok.