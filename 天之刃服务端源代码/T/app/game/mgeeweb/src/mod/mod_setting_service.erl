%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2011, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 28 Feb 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_setting_service).

-include("mgeeweb.hrl").

%% API
-export([
         get/3
        ]).

get("/system_notice" ++ _, Req, _) ->
    do_set_system_notice(Req);
get(_, Req, _) ->
    Req:not_found().

%% 设置系统公告
do_set_system_notice(Req) ->
    Get = Req:parse_qs(),
    Content = base64:decode_to_string(base64:decode_to_string(proplists:get_value("content", Get))),
    db:dirty_write(?DB_SYSTEM_NOTICE_P, #r_system_notice{id=1, notice=Content}),
    lists:foreach(
      fun(PName) ->
              global:send(PName,  {mod_system_notice, {update_notice, Content}})
      end, common_debugger:get_all_map_pid()),
     mgeeweb_tool:return_json_ok(Req).

