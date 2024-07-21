%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 20 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_distribution_service).

%% API
-export([
         join_db_group/0,
         join_erlang_group/0
        ]).


%%加入到mnesia集群中
join_db_group() ->
    common_db:join_group(),
    timer:sleep(300),
    ok.

%%加入到erlang集群中
join_erlang_group() ->
    ok.
