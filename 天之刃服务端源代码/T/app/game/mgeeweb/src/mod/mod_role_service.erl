%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2011, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created :  1 Mar 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_role_service).

-include("mgeeweb.hrl").

%% API
-export([
         get/3
        ]).

get("/set_conlogin/" ++ _, Req, _) ->
    do_set_conlogin(Req);
get("/set_activepoint/" ++ _, Req, _)->
    do_set_activepoint(Req);
get("/clear_person_ybc" ++ _, Req, _) ->
    do_clear_person_ybc(Req);
get("/clear_item_stall_state" ++ _, Req, _) ->
    do_clear_item_stall_state(Req);
get("/clear_exchange_state" ++ _, Req, _) ->
    do_clear_exchange_state(Req);
get(_, Req, _) ->
    Req:not_found().

%% 清理交易状态异常
do_clear_exchange_state(Req) ->
    Get = Req:parse_qs(),
    RoleId = common_tool:to_integer(proplists:get_value("role_id", Get)),
    case db:dirty_read(?DB_ROLE_STATE, RoleId) of
        [] ->
            mgeeweb_tool:return_json_error(Req);
        [RoleState] ->
            db:dirty_write(?DB_ROLE_STATE, RoleState#r_role_state{exchange=false}),
            mgeeweb_tool:return_json_ok(Req)
    end.

%% 清理道具摆摊状态异常
do_clear_item_stall_state(Req) ->
    Get = Req:parse_qs(),
    RoleId = common_tool:to_integer(proplists:get_value("role_id", Get)),
    case common_misc:send_to_rolemap(RoleId, {mod_stall, {clear_item_stall_state, RoleId}}) of
        ignore ->
            mgeeweb_tool:return_json_error(Req);
        _ ->
            mgeeweb_tool:return_json_ok(Req)
    end.

%% 清理玩家个人拉镖状态
do_clear_person_ybc(Req) ->
    Get= Req:parse_qs(),
    RoleID = common_tool:to_integer(proplists:get_value("role_id", Get)),
    case db:dirty_read(?DB_YBC_UNIQUE, {0,1, RoleID}) of
        [] ->
            ignore;
        [#r_ybc_unique{id=YbcID}] ->
            db:dirty_delete(?DB_YBC_UNIQUE, {0,1,RoleID}),
            db:dirty_delete(?DB_YBC, YbcID),
            db:transaction(
              fun() -> 
                      [RoleState] = db:read(?DB_ROLE_STATE, RoleID, write), 
                      db:write(?DB_ROLE_STATE, RoleState#r_role_state{ybc=0}, write) 
              end)            
    end,
    mgeeweb_tool:return_json_ok(Req).
    

do_set_conlogin(Req) ->
    Get= Req:parse_qs(),
    Day = common_tool:to_integer(proplists:get_value("day", Get)),
    RoleID = common_tool:to_integer(proplists:get_value("role_id", Get)),
    case common_misc:is_role_online(RoleID) of
        false->
            {Date, _} = erlang:localtime(),
            %% 角色不在线，直接修改数据库记录
            case db:dirty_read(?DB_ROLE_CONLOGIN_P, RoleID) of
                [] ->
                    mgeeweb_tool:return_json_error(Req);                
                [R] ->
                    db:dirty_write(?DB_ROLE_CONLOGIN_P, R#r_role_conlogin{con_day=Day, last_con_refresh_date=Date}),
                    mgeeweb_tool:return_json_ok(Req)
            end;
        _ ->
            %% 角色在线，发送消息到地图
            common_misc:send_to_rolemap(RoleID, {mod_conlogin, {set_conlogin_day, erlang:self(), RoleID, Day}}),
            receive
                ok ->
                    mgeeweb_tool:return_json_ok(Req);
                error ->
                    mgeeweb_tool:return_json_error(Req)
            end
    end.
            
do_set_activepoint(Req)->
    Get= Req:parse_qs(),
    AP = common_tool:to_integer(proplists:get_value("ap", Get)),
    RoleID = common_tool:to_integer(proplists:get_value("role_id", Get)),
    case common_misc:is_role_online(RoleID) of
        false->
            mgeeweb_tool:return_json_error(Req); 
        _->
           case common_misc:send_to_rolemap_mod(RoleID,hook_activity_task,{set_ap,{RoleID,AP}}) of
               ok-> mgeeweb_tool:return_json_ok(Req);
               _->mgeeweb_tool:return_json_error(Req)
           end 
    end.
            

    
    
    
