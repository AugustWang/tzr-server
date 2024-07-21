%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2011, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created :  7 Jul 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_shop_service).

-export([get/3]).

-include("mgeeweb.hrl").

get("/get_cuxiao_item_list" ++ _, Req, _) ->
    do_get_cuxiao_item_list(Req);
get("/set_cuxiao_item" ++ _, Req, _) ->
    do_set_cuxiao_item(Req);
get(Path, Req, DocRoot) ->
    ?ERROR_MSG("~ts : ~w ~w", ["未知的请求", Path, DocRoot]),
    mgeeweb_tool:return_json_error(Req).

do_get_cuxiao_item_list(Req) ->
    Result = db:dirty_match_object(?DB_SHOP_CUXIAO, #p_shop_cuxiao_item{_='_'}),
    Result2 = lists:foldl(
                fun(#p_shop_cuxiao_item{begin_time=BeginTime, end_time=EndTime} = R, Acc) ->
                        Now = common_tool:now(),
                        if
                            EndTime >= Now andalso BeginTime =:= 0 ->
                                [R | Acc];
                            EndTime < Now andalso BeginTime =:= 0 ->
                                Acc;
                            BeginTime < Now andalso EndTime =:= 0 ->
                                [R | Acc];
                            BeginTime >= Now andalso EndTime =:= 0 ->
                                Acc;
                            true ->
                                Acc
                    end
                end, [], Result),
    List = lists:foldl(
             fun(R, Acc) ->
                     [mgeeweb_tool:transfer_to_json(R) | Acc]
             end, [], Result2),
    Json = [{result, ok}, {list, List}],
    mgeeweb_tool:return_json(Json, Req).

do_set_cuxiao_item(Req) ->
    QueryString = Req:parse_qs(),
    Num = mgeeweb_tool:get_int_param("num", QueryString),
    Price = mgeeweb_tool:get_int_param("price", QueryString),
    Key = mgeeweb_tool:get_string_param("key", QueryString),
    case db:dirty_read(?DB_SHOP_CUXIAO, Key) of
        [] ->
            mgeeweb_tool:return_json_error(Req);
        [#p_shop_cuxiao_item{price=OldPrice}=R] ->
            [C] = OldPrice#p_shop_price.currency,
            NewPrice = OldPrice#p_shop_price{currency=[C#p_shop_currency{amount=Price}]},
            db:dirty_write(?DB_SHOP_CUXIAO, R#p_shop_cuxiao_item{num=Num, price=NewPrice}),
            mgeeweb_tool:return_json_ok(Req)
    end.


