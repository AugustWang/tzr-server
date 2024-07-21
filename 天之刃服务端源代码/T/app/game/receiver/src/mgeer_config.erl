%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     负责读取receiver的配置文件
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(mgeer_config).



%%
%% Include files
%%
-define(MGE_ROOT, "/data/tzr/server/").

%%
%% Exported Functions
%%
-export([get_mysql_config/0]).


%%
%% API Functions
%%

get_mysql_config() ->
    [Config]=common_config_dyn:find(receiver_server,mysql_config),
    %ConfigFile = lists:concat([?MGE_ROOT, "config/receiver/receiver_server.config"]),
    %{ok, Config} = file:consult(ConfigFile),
    %proplists:get_value(mysql_config, Config).
    Config.
    

