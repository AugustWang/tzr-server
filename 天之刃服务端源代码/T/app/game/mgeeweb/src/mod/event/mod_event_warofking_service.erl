%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%% Created : 22 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_event_warofking_service).

%% API
-export([get/3]).

-include("mgeeweb.hrl").

get("/get_info", Req, _DocRoot) ->
    do_get_info(Req);
get("/begin_now", Req, _) ->
    do_begin_now(Req);
get("/begin_after_60s", Req, _) ->
    gen_server:call({global, mgeew_event}, {mod_event_warofking, begin_after_60s}),
    Req:ok();
get("/end_now", Req, _) ->
    do_end_now(Req);
get("/reset", Req, _) ->
    do_reset(Req);
get(_, Req, _DocRoot) ->
    Req:not_found().


do_end_now(Req) ->
    case global:whereis_name(mgeew_event) of
        undefined ->
            Req:not_found();
        _PID ->
            {Cur, _Last} = gen_server:call({global, mgeew_event}, {mod_event_warofking, end_now}),
            #r_warofking_history{index=Index, begin_time=BeginTime, end_time=EndTime, condition_families=_CFamilies,
                                 join_families=_JFamilies, winner_family_1=_WFamily1, winner_family_2=_WFamily2,
                                 winner_family_3=_WFamily3} = Cur,
            Rtn = [{index, Index}, {begin_time, BeginTime}, {end_time, EndTime}],
            mgeeweb_tool:return_json(Rtn, Req)                    
    end.


do_get_info(Req) ->
    case global:whereis_name(mgeew_event) of
        undefined ->
            Req:not_found();
        _PID ->
            {Cur, _Last} = gen_server:call({global, mgeew_event}, {mod_event_warofking, get_info}),
            #r_warofking_history{index=Index, begin_time=BeginTime, end_time=EndTime, condition_families=_CFamilies,
                                 join_families=_JFamilies, winner_family_1=_WFamily1, winner_family_2=_WFamily2,
                                 winner_family_3=_WFamily3} = Cur,
            Rtn = [{index, Index}, {begin_time, BeginTime}, {end_time, EndTime}],
            mgeeweb_tool:return_json(Rtn, Req)         
    end.


do_begin_now(Req) ->
    case global:whereis_name(mgeew_event) of
        undefined ->
            Req:not_found();
        _PID ->
            {Cur, _Last} = gen_server:call({global, mgeew_event}, {mod_event_warofking, begin_now}),
            #r_warofking_history{index=Index, begin_time=BeginTime, end_time=EndTime, condition_families=_CFamilies,
                                 join_families=_JFamilies, winner_family_1=_WFamily1, winner_family_2=_WFamily2,
                                 winner_family_3=_WFamily3} = Cur,
            Rtn = [{index, Index}, {begin_time, BeginTime}, {end_time, EndTime}],
            mgeeweb_tool:return_json(Rtn, Req)      
    end.

do_reset(Req) ->
    case global:whereis_name(mgeew_event) of
        undefined ->
            Req:not_found();
        _PID ->
            gen_server:call({global, mgeew_event}, {mod_event_warofking, reset}),                
            mgeeweb_tool:return_json_ok(Req)
    end.

    
