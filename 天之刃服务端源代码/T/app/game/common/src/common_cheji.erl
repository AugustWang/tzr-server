%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @doc 撤机辅助工具
%%%
%%% @end
%%% Created : 10 Jul 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_cheji).

-include("common_server.hrl").

-include("common.hrl").

%% API
-export([
         reset_db_schema/0
        ]).

%%%===================================================================
%%% API
%%%===================================================================

%% 多台机器合并为一台机器时，schema文件必须重新生成
reset_db_schema() ->
    %% 首先需要启动mnesia
    io:format("~s~n", ["prepare to start..."]),
    mnesia:start(),
    common_loglevel:set(3),
    MnesiaDir = mnesia:system_info(directory),
    case MnesiaDir =:= "/data/database/tzr" of
        true ->
            io:format("~s~n", ["wrong mnesia dir /data/database/tzr "]),
            init:stop();
        false ->
            os:cmd(lists:flatten(lists:concat(["rm -rf ", MnesiaDir]))),
            ignore
    end,
    io:format("~s~n", ["prepare to init mnesia table"]),
    mgeed_mnesia:init(),
    mnesia:dump_log(),
    mnesia:stop(),
    R = os:cmd(lists:flatten(lists:concat(["mv -f ", MnesiaDir, "/schema.DAT /data/database/tzr/"]))),
    io:format("~p~n", [R]),
    case R of
        [] ->
            os:cmd(lists:flatten(lists:concat(["rm -rf ", MnesiaDir]))),
            io:format("cheji ok ~n");
        _ ->
            io:format("cheji error ~p~n", [R])
    end,
    init:stop().
    

