%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 22 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_event_service).

%% API
-export([
         get/3
        ]).


get("/warofking" ++ RemainPath, Req, DocRoot) ->
    mod_event_warofking_service:get(RemainPath, Req, DocRoot);
get("/waroffaction" ++ RemainPath, Req, DocRoot) ->
    mod_event_waroffaction_service:get(RemainPath, Req, DocRoot);
get("/office" ++ RemainPath, Req, DocRoot) ->
    mod_office_service:get(RemainPath, Req, DocRoot);
get("/vwf" ++ RemainPath, Req, DocRoot) ->
    mod_event_vwf_service:handle(RemainPath, Req, DocRoot);
get("/country_treasure" ++ RemainPath, Req, DocRoot) ->
    mod_event_country_treasure_service:handle(RemainPath, Req, DocRoot);
get("/refining_box" ++ RemainPath, Req, DocRoot) ->
    mod_event_refining_box_service:handle(RemainPath, Req, DocRoot);
get("/educate_fb" ++ RemainPath, Req, DocRoot) ->
    mod_event_educate_fb_service:handle(RemainPath, Req, DocRoot);
get("/pay_first" ++ RemainPath, Req, DocRoot) ->
    mod_pay_first_service:get(RemainPath, Req, DocRoot);
get("/family_collect" ++ RemainPath, Req, DocRoot) ->
    mod_family_collect_service_service:get(RemainPath, Req, DocRoot);
get(_RemainPath, Req, _DocRoot) ->
    Req:not_found().
