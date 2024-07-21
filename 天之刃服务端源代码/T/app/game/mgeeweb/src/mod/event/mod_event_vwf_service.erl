%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2010, 
%%% @doc
%%% 讨伐敌营副本后台管理处理
%%% @end
%%% Created :  3 Dec 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_event_vwf_service).

-include("mgeeweb.hrl").

-record(r_vwf_admin_message,{open_date,is_open_vwf,open_after_days,vw_opne_time}).

-define(RFC4627_FROM_RECORD(RName, R),
    rfc4627:from_record(R, RName, record_info(fields, RName))).

-define(RFC4627_TO_RECORD(RName, R),
    rfc4627:to_record(R, #RName{}, record_info(fields, RName))).

%% API
-export([
         handle/3
        ]).


handle("/list" ++ _RemainPath,Req, DocRoot) ->
    do_list(Req, DocRoot);
handle("/start" ++ _RemainPath,Req, DocRoot) ->
    do_start(Req, DocRoot);
handle("/stop" ++ _RemainPath,Req, DocRoot) ->
    do_stop(Req, DocRoot);
handle(RemainPath, Req, DocRoot) ->
    ?ERROR_MSG("~ts,RemainPath=~w, Req=~w, DocRoot=~w",["无法处理此消息", RemainPath, Req, DocRoot]),
    Req:not_found().

do_list(Req, _DocRoot)->
    Result = get_vwf_base_info(),
    Req:ok({"text/html; charset=utf-8", [{"Server","Mochiweb-Test"}],Result}).

get_vwf_base_info() ->
    {{Year, Month, Day}, _} = common_config:get_open_day(),
    [FbDays] = common_config_dyn:find(etc,open_vie_world_fb_day),
    [IsOpenVWF] = common_config_dyn:find(etc,is_open_vie_world_fb),
    OpenDate = lists:concat(["" , erlang:integer_to_list(Year),"-", erlang:integer_to_list(Month), "-",erlang:integer_to_list(Day)]),
    VWFOpenTime = 
        case common_config_dyn:find(vie_world_fb,vwf_open_time) of
            [TList] ->
                VWFOpenTimeT = 
                    lists:foldl(
                      fun({{Sh,Sm,Ss},{Eh,Em,Es}},Acc) ->
                              S = lists:concat(["" , get_format_value(Sh),":",get_format_value(Sm), ":",get_format_value(Ss)]),
                              E = lists:concat(["" , get_format_value(Eh),":",get_format_value(Em), ":",get_format_value(Es)]),
                              SE = lists:concat(["<li>",S,"--",E,"</li>"]),
                              lists:concat([Acc, SE])
                      end,"",TList),
                VWFOpenTimeT;
            _ ->
                ""
        end,
    Record = #r_vwf_admin_message{
      open_date = OpenDate,
      is_open_vwf = IsOpenVWF,
      open_after_days = FbDays,
      vw_opne_time = VWFOpenTime},
    ?DEBUG("Record=~w",[Record]),
    record_to_json(Record).

get_format_value(Number) ->
    if Number < 10 ->
            lists:concat(["0",erlang:integer_to_list(Number)]);
       true ->
            erlang:integer_to_list(Number)
    end.
    

do_start(Req, _DocRoot)->
    QueryString = Req:parse_qs(),
    Interval = proplists:get_value("interval", QueryString),
    NumberInterval = common_tool:to_integer(Interval),
    MapIds = 
        case common_config_dyn:find(vie_world_fb,vwf_server_npc_map_ids) of
            [MapIdsT] ->
                MapIdsT;
            _ ->
                []
        end,
    lists:foreach(
      fun(MapId) ->
              MapName = common_misc:get_common_map_name(MapId),
              catch global:send(MapName,{mod_vie_world_fb,{admin_show_vwf_server_npc,NumberInterval}})
      end,MapIds),
    Result = get_vwf_base_info(),
    Req:ok({"text/html; charset=utf-8", [{"Server","Mochiweb-Test"}],Result}).

do_stop(Req, _DocRoot)->
    MapIds = 
        case common_config_dyn:find(vie_world_fb,vwf_server_npc_map_ids) of
            [MapIdsT] ->
                MapIdsT;
            _ ->
                []
        end,
    ?DEBUG("MapIds=~w",[MapIds]),
    lists:foreach(
      fun(MapId) ->
              MapName = common_misc:get_common_map_name(MapId),
              catch global:send(MapName,{mod_vie_world_fb,{admin_hide_vwf_server_npc}})
      end,MapIds),
    Result = get_vwf_base_info(),
    Req:ok({"text/html; charset=utf-8", [{"Server","Mochiweb-Test"}],Result}).


%% 将单个记录结果转换成jsno格式数据
%% {r_xxx_xxx,X,Y,Z,...} -> [{"X":1,"Y":"xxx",...}] or []
record_to_json(Record) ->
    {obj,Json} = ?RFC4627_FROM_RECORD(r_vwf_admin_message,Record),
    Length = erlang:length(Json),
    {JsonStr,_} = 
        lists:foldl(fun({Key,Value},Acc) ->
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
    lists:concat(["\"",Value,"\""]).
