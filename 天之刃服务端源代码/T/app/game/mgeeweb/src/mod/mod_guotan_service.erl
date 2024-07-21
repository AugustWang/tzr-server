%%%-------------------------------------------------
%%% @author <linruirong@mingchao.com>   
%%% @copyright (C) 2010, mingchao.com        
%%% @doc                                     
%%%     mod_guotan                 
%%% @end                                     
%%% Created : 2011-03-21                     
%%%-------------------------------------------------

-module(mod_guotan_service).

-include("mgeeweb.hrl").


%%API

-export([get/3,do_get/3]).

get(Path,Req,DocRoot)->
    try
        do_get(Path,Req,DocRoot)
    catch
        _:Reason->
            ?ERROR_MSG("do_get error,Reason=~w,stacktrace=~w",[Reason,erlang:get_stacktrace()]),
            mgeeweb_tool:return_json_error(Req)
    end.

%%开启国探
do_get("/admin_start_guotan/", Req, _DocRoot) ->
    admin_start_guotan(Req);

do_get(Path, Req, _DocRoot) ->
	QueryString = Req:parse_qs(),
	?DEBUG("error mod_guotan no match path=~w, QueryString=~w ",[Path,QueryString]).


admin_start_guotan(Req)->
	QueryString = Req:parse_qs(),
	FactionId = mgeeweb_tool:get_int_param("factionId", QueryString),
    StartH = mgeeweb_tool:get_int_param("startH", QueryString),
    StartM = mgeeweb_tool:get_int_param("startM", QueryString),
    
	case FactionId of
        1 ->
            MapId = 11100;
		2 ->
			MapId = 12100;
		3 -> 
			MapId = 13100;
        _ ->
            MapId = 0
    end,	 
    ?DEBUG("0000 FactionId=~w, StartH=~w ,StartM=~w",[FactionId,StartH,StartM]),
	MapName = common_misc:get_common_map_name(MapId),
    ?DEBUG("9999 FactionId=~w, StartH=~w ,StartM=~w",[FactionId,StartH,StartM]),
	case global:whereis_name(MapName) of 
		undefind ->
            ?DEBUG("111 FactionId=~w, StartH=~w ,StartM=~w",[FactionId,StartH,StartM]),     
			ignore;
		_ ->
            ?DEBUG("222 FactionId=~w, StartH=~w ,StartM=~w",[FactionId,StartH,StartM]),     
			global:send(MapName,{mod_spy,{admin_set_spy_faction_time,FactionId,StartH,StartM}}),
			mgeeweb_tool:return_json_ok(Req)
	end.
                     
