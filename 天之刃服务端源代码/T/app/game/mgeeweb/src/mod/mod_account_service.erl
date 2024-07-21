%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 18 Dec 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_account_service).

%% API
-export([
         get/3
        ]).

-include("mgeeweb.hrl").

get("/has_role" ++ _, Req, _) ->
    do_has_role(Req);
get("/get_all_no_role_id" ++ _, Req, _) ->
    do_get_all_no_role_id(Req);
get("/get_all" ++ _, Req, _) ->
    do_get_all(Req);
get("/get_role_id" ++ _, Req, _) ->
    do_get_role_id(Req);    
get("/get_role_base_info/" ++ _, Req, _) ->
    do_get_role_base_info(Req);
get("/get_role" ++ _, Req, _) ->
    do_get_role(Req);
get("/create_role" ++ _, Req, _) ->
    do_create_role(Req);
get("/pass_fcm" ++ _, Req, _) ->
    do_pass_fcm(Req);
get("/kick_stall/"++RoleId,Req,_)->
    do_kick_stall(RoleId,Req);
get("/reset_energy/" ++ RoleId, Req, _) ->
    do_reset_role_energy(RoleId, Req);
get("/skill_return_exp/" ++ RoleID, Req, _) ->
    do_skill_return_exp(RoleID, Req);

get(_, Req, _) ->
    Req:not_found().

do_get_all_no_role_id(Req) ->
    Get = Req:parse_qs(),
    AccountName = common_tool:to_binary(proplists:get_value("account", Get)),
    case db:dirty_match_object(?DB_ROLE_BASE, #p_role_base{account_name=AccountName, _='_'}) of
        [] ->
            mgeeweb_tool:return_json_error(Req);
        [#p_role_base{role_id=RoleID}] ->
            {Host, Port, GatewayKey} = gen_server:call({global, mgeel_key_server}, {get_all_lines_and_key, AccountName, RoleID}),
            [#p_role_attr{level=Level}] = db:dirty_read(db_role_attr, RoleID),
            [#p_role_pos{map_id=MapID, pos=#p_pos{tx=TX, ty=TY}}] = db:dirty_read(db_role_pos, RoleID),
            Rtn = [{level, Level}, {map_id, MapID}, {tx, TX}, {ty, TY}, {result, ok}, 
                   {gateway_key, GatewayKey}, {role_id, RoleID},
                   {gateway_host, Host}, {gateway_port, Port}],
            mgeeweb_tool:return_json(Rtn, Req)
    end.
    

do_get_all(Req) ->
    Get = Req:parse_qs(),
    AccountName = common_tool:to_binary(proplists:get_value("account", Get)),
    RoleID = common_tool:to_integer(proplists:get_value("role_id", Get)),
    {Host, Port, GatewayKey} = gen_server:call({global, mgeel_key_server}, {get_all_lines_and_key, AccountName, RoleID}),
    [#p_role_attr{level=Level}] = db:dirty_read(db_role_attr, RoleID),
    [#p_role_pos{map_id=MapID, pos=#p_pos{tx=TX, ty=TY}}] = db:dirty_read(db_role_pos, RoleID),
    Rtn = [{level, Level}, {map_id, MapID}, {tx, TX}, {ty, TY}, {result, ok}, 
           {gateway_key, GatewayKey},
           {gateway_host, Host}, {gateway_port, Port}],
    mgeeweb_tool:return_json(Rtn, Req).
    

do_pass_fcm(Req) ->
    Get = Req:parse_qs(),
    AccountName = common_tool:to_binary(proplists:get_value("account", Get)),
    db:transaction(
      fun() ->
              case db:read(?DB_FCM_DATA, AccountName, write) of
                  [] ->
                      db:write(?DB_FCM_DATA, #r_fcm_data{account=AccountName, passed=true}, write);
                  [FcmData] ->
                      db:write(?DB_FCM_DATA, FcmData#r_fcm_data{passed=true}, write)
              end
      end),
    mgeeweb_tool:return_json_ok(Req).


do_kick_stall(RoleId,Req)->
    IntRoleId = common_tool:to_integer(RoleId),

    case db:dirty_read(?DB_STALL, IntRoleId) of
        [] ->
            Rtn = [{result, "角色不在摆摊中"}];

        [StallDetail] ->
            #r_stall{mode=Mode, remain_time=RemainTime, mapid=MapID} = StallDetail,
            case Mode =:= 1 andalso RemainTime =:= 0 of
                true ->
                    Rtn = [{result, "摊位已结束"}];
                _ ->
                    MapPName = common_misc:get_common_map_name(MapID),
                    case gen_server:call({global, MapPName}, {kick_role_stall, IntRoleId}) of
                        ok ->
                            Rtn = [{result,"踢摊位成功"}];
                        {error, Reason} ->
                            Rtn = [{result,lists:concat(["踢摊位失败,原因为:",common_tool:to_list(Reason)])}]
                    end
            end
    end,
    mgeeweb_tool:return_json(Rtn,Req).

do_get_role_base_info(Req) ->
    Get = Req:parse_qs(),
    AccountName = common_tool:to_binary(proplists:get_value("account", Get)),
    case db:dirty_match_object(?DB_ROLE_BASE, #p_role_base{account_name = AccountName, _='_'}) of
        [] ->
            Rtn = [{result, false}];
        [#p_role_base{role_id=RoleID}] ->
            [#p_role_attr{level=Level}] = db:dirty_read(?DB_ROLE_ATTR, RoleID),
            [#p_role_pos{map_id=MapID}] = db:dirty_read(?DB_ROLE_POS, RoleID),
            Rtn = [{result, true}, {map_id, MapID}, {level, Level}]
    end,
    mgeeweb_tool:return_json(Rtn, Req).
    

%% 获取账号下的角色
do_has_role(Req) ->
    Get = Req:parse_qs(),
    AccountName = common_tool:to_binary(proplists:get_value("account", Get)),
    db:match_load(?DB_ROLE_BASE_P, ?DB_ROLE_BASE, #p_role_base{account_name = AccountName, _='_'}),
    case db:dirty_match_object(?DB_ROLE_BASE, #p_role_base{account_name = AccountName, _='_'}) of
        [] ->
            Rtn = [{result, false}];
        [#p_role_base{role_id=RoleID}] ->
            Rtn = [{result, true}, {role_id,RoleID} ]
    end,
    mgeeweb_tool:return_json(Rtn, Req).

do_get_role(Req) ->    
    Get = Req:parse_qs(),
    AccountName = common_tool:to_binary(proplists:get_value("account", Get)),
    RoleID = common_misc:get_roleid_by_accountname(AccountName),
    case RoleID > 0 of
        true ->
            PRole = common_misc:get_role_detail(RoleID),
            Result = mgeeweb_tool:transfer_to_json(PRole),
            mgeeweb_tool:return_json(Result, Req);
        false ->
            mgeeweb_tool:return_json_error(Req)
    end.

do_get_role_id(Req) ->    
    Get = Req:parse_qs(),
    AccountName = common_tool:to_binary(proplists:get_value("account", Get)),
    db:match_load(?DB_ROLE_BASE_P, ?DB_ROLE_BASE, #p_role_base{account_name = AccountName, _='_'}),
    RoleID = common_misc:get_roleid_by_accountname(AccountName),
    case RoleID > 0 of
        true ->
            Result = [{result, RoleID}],
            mgeeweb_tool:return_json(Result, Req);
        false ->
            mgeeweb_tool:return_json_error(Req)
    end.


%% 创建新的角色，信息已经在PHP那边过滤，这边无需再次判断和过滤
do_create_role(Req) ->
    Get = Req:parse_qs(),
    AccountName = common_tool:to_binary(proplists:get_value("ac", Get)),
    Uname = common_tool:to_binary(proplists:get_value("uname", Get)),
    Sex = common_tool:to_integer(proplists:get_value("sex", Get)),
    FactionID = common_tool:to_integer(proplists:get_value("fid", Get)),
    Head = common_tool:to_integer(proplists:get_value("head", Get)),
    HairType = common_tool:to_integer(proplists:get_value("hair_type", Get)),
    HairColor = common_tool:to_binary(proplists:get_value("hair_color", Get)),
    Category = common_tool:to_integer(proplists:get_value("category", Get)),
    AccountType = common_tool:to_integer(proplists:get_value("account_type", Get, ?ACCOUNT_TYPE_NORMAL)),
    
    case catch gen_server:call({global, mgeel_account_server}, {add_role, AccountName, AccountType, Uname, Sex, FactionID,
                                                                Head, HairType, HairColor, Category}) of
        {ok, RoleID} ->
            Rtn = [{result, ok}, {role_id, RoleID}],
            mgeeweb_tool:return_json(Rtn, Req);
        {error, Reason} ->
            Rtn = [{result, Reason}],
            mgeeweb_tool:return_json(Rtn, Req);
        Error ->
            ?ERROR_MSG("~p", [Error]),
            Rtn = [{result, system_error}],
            mgeeweb_tool:return_json(Rtn, Req)
    end.

%% @doc 重置精力值
do_reset_role_energy(RoleIDStr, Req) ->
    RoleID = common_tool:to_integer(RoleIDStr),
    case common_misc:send_to_rolemap(RoleID, {mod_map_role, {reset_role_energy, RoleID}}) of
        ok ->
            mgeeweb_tool:return_json_ok(Req);
        _ ->
            mgeeweb_tool:return_json_error(Req)
    end.

%% @doc 技能返回经验
do_skill_return_exp(RoleIDStr, Req) ->                
    RoleID = common_tool:to_integer(RoleIDStr),
    case common_misc:send_to_rolemap(RoleID, {mod_map_role, {skill_return_exp, RoleID}}) of
        ok ->
            mgeeweb_tool:return_json_ok(Req);
        _ ->
            mgeeweb_tool:return_json_error(Req)
    end.
