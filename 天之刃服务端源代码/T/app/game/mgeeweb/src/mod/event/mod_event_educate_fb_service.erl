%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2011, 
%%% @doc
%%% 师徒副本玩家管理
%%% @end
%%% Created : 22 Mar 2011 by  <caochuncheng2002@gmail.com>
%%%-------------------------------------------------------------------
-module(mod_event_educate_fb_service).

-include("mgeeweb.hrl").

%% op_type 1:查无些人 2:未玩过副本,3:查询成功 4:重置次数出错，只能[0,1,2]的整数 5:不需要重置 6:重置成功
-record(r_event_educate_fb,{op_code,
                            role_id = 0,role_name = "",
                            account_name = "",
                            faction_id = 0,level = 0,
                            times = 0,start_time = 0,
                            end_time = 0,award_time=0}).

-define(RFC4627_FROM_RECORD(RName, R),
    rfc4627:from_record(R, RName, record_info(fields, RName))).

-define(RFC4627_TO_RECORD(RName, R),
    rfc4627:to_record(R, #RName{}, record_info(fields, RName))).

%% API
-export([
         handle/3
        ]).
%%%===================================================================
%%% API
%%%===================================================================
handle("/list" ++ _RemainPath,Req, DocRoot) ->
    do_list(Req, DocRoot);
handle("/query" ++ _RemainPath,Req, DocRoot) ->
    do_query(Req, DocRoot);
handle("/reset_times" ++ _RemainPath,Req, DocRoot) ->
    do_reset_times(Req, DocRoot);
handle(RemainPath, Req, DocRoot) ->
    ?ERROR_MSG("~ts,RemainPath=~w, Req=~w, DocRoot=~w",["无法处理此消息", RemainPath, Req, DocRoot]),
    Req:not_found().


do_list(Req, _DocRoot) ->
    EventEducateFb = #r_event_educate_fb{op_code = 0},
    Result = record_to_json(EventEducateFb),
    Req:ok({"text/html; charset=utf-8", [{"Server","Mochiweb-Test"}],Result}).

do_query(Req, _DocRoot) ->
    QueryString = Req:parse_qs(),
    RoleAccount = proplists:get_value("roleAccount", QueryString),
    Result = get_role_educate_fb_info(RoleAccount),
    Req:ok({"text/html; charset=utf-8", [{"Server","Mochiweb-Test"}],Result}).
do_reset_times(Req, _DocRoot) ->
    QueryString = Req:parse_qs(),
    RoleId = proplists:get_value("roleId", QueryString),
    NewTimes = proplists:get_value("newTimes", QueryString),
    RoleAccount = proplists:get_value("roleAccount", QueryString),
    NRoleId = common_tool:to_integer(RoleId),
    NNewTimes = common_tool:to_integer(NewTimes),
    EventEducateFb = 
        if NNewTimes =:= 0 orelse  NNewTimes =:= 1 orelse  NNewTimes =:= 2 ->
                case db:dirty_match_object(db_educate_fb,  #r_educate_fb{role_id= NRoleId ,_='_'}) of
                    [] ->
                        #r_event_educate_fb{op_code = 5,role_id = NRoleId,account_name = RoleAccount};
                    [RoleEducateRecord] ->
                        db:dirty_write(db_educate_fb,RoleEducateRecord#r_educate_fb{
                                                       start_time = common_tool:now(),
                                                       times = NNewTimes}),
                        #r_event_educate_fb{
                                        op_code = 6, role_id = NRoleId,
                                        account_name = RoleAccount,
                                        role_name = RoleEducateRecord#r_educate_fb.role_name,
                                        faction_id = RoleEducateRecord#r_educate_fb.faction_id,
                                        level = RoleEducateRecord#r_educate_fb.level,
                                        times = NNewTimes,
                                        start_time = RoleEducateRecord#r_educate_fb.start_time,
                                        end_time = RoleEducateRecord#r_educate_fb.end_time,
                                        award_time= RoleEducateRecord#r_educate_fb.award_time}
                end;
           true ->
                #r_event_educate_fb{op_code = 4}
        end,
    Result = record_to_json(EventEducateFb),
    Req:ok({"text/html; charset=utf-8", [{"Server","Mochiweb-Test"}],Result}).

get_role_educate_fb_info(RoleAccount)->
    BRoleAccount = common_tool:to_binary(RoleAccount),
    EventEducateFb = 
        case db:dirty_match_object(db_role_base, #p_role_base{account_name = BRoleAccount, _='_' }) of
            [] ->
                #r_event_educate_fb{op_code = 1,role_id = 0,account_name = RoleAccount};
            [#p_role_base{role_id = RoleId}] ->
                case db:dirty_match_object(db_educate_fb,  #r_educate_fb{role_id= RoleId ,_='_'}) of
                    [] ->
                        #r_event_educate_fb{op_code = 2,role_id = RoleId,account_name = RoleAccount};
                    [RoleEducateRecord] ->
                        NowSeconds = common_tool:now(),
                        {NowDate,_NowTime} =
                            common_tool:seconds_to_datetime(NowSeconds),
                        TodaySeconds = common_tool:datetime_to_seconds({NowDate,{0,0,0}}),
                        StartTime = RoleEducateRecord#r_educate_fb.start_time,
                        Times = 
                            if StartTime > TodaySeconds ->
                                    RoleEducateRecord#r_educate_fb.times;
                               true ->
                                    0
                            end,
                        #r_event_educate_fb{
                              op_code = 3,
                              role_id = RoleId,
                              account_name = RoleAccount,
                              role_name = RoleEducateRecord#r_educate_fb.role_name,
                              faction_id = RoleEducateRecord#r_educate_fb.faction_id,
                              level = RoleEducateRecord#r_educate_fb.level,
                              times = Times,
                              start_time = StartTime,
                              end_time = RoleEducateRecord#r_educate_fb.end_time,
                              award_time= RoleEducateRecord#r_educate_fb.award_time}
                end
        end,
    record_to_json(EventEducateFb).


%% 将单个记录结果转换成jsno格式数据
%% {r_xxx_xxx,X,Y,Z,...} -> [{"X":1,"Y":"xxx",...}] or []
record_to_json(Record) ->
    {obj,Json} = ?RFC4627_FROM_RECORD(r_event_educate_fb,Record),
    Length = erlang:length(Json),
    {JsonStr,_} = 
        lists:foldl(
          fun({Key,Value},Acc) ->
                  {AccStr,Index} = Acc,
                  Value2 = value_to_json(Value),
                  AccStr2 = 
                      if (Index + 1) < Length ->
                              lists:concat([AccStr,"\"",Key,"\"",":",Value2,","]);
                         true ->
                              lists:concat([AccStr,"\"",Key,"\"",":",Value2])
                      end,
                  {AccStr2,Index + 1}
          end,{"",0},Json),
    if JsonStr =/= "" ->
            lists:concat(["{",JsonStr,"}"]);
       true ->
            lists:concat(["{",JsonStr,"}"])
    end.

value_to_json(Value)when erlang:is_integer(Value) ->
    lists:concat([Value]);
value_to_json(Value)when erlang:is_number(Value) ->
    lists:concat([Value]);
value_to_json(Value) ->
    lists:concat(["\"",common_tool:to_list(Value),"\""]).
