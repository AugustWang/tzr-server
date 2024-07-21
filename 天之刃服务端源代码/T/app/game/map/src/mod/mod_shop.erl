-module(mod_shop).

-include("mgeem.hrl").
-include("shop.hrl").

-define(FREE_SHOP,999999999).

-export([
         init/0,
         handle/1,
         loop/0,
         init_cu_xiao/0,
         reload_cu_xiao/0
        ]).

-export([
         change_test/1,
         get_goods_price/2
        ]).

%% 固定时间刷新商店
loop() ->
    %% 固定由洪武王都来刷新促销商店
    case mgeem_map:get_mapid() =:= 11100 of
        true ->
            {Hour, Min, _} = get_cuxiao_refresh_time(),
            {_, {H, M, _}} = erlang:localtime(),
            %% 在指定时间内刷新，为防止服务器卡，在一分钟内都处理，init的过程会做防重复判断
            case Hour =:= H andalso M =:= Min of
                true ->
                    init_cu_xiao();
                false ->
                    ignore
            end;
        false ->
            ignore
    end.

handle({_,_,?SHOP_BUY,_,_,_,_,_State}=Msg) ->
    do_buy(Msg);
handle({_,_,?SHOP_SHOPS,_,_,_,_,_State}=Msg) ->
    do_get_shops(Msg);
handle({_,_,?SHOP_ALL_GOODS,_,_,_,_,_State}=Msg) ->
    do_get_goods(Msg);
handle({_,_,?SHOP_SEARCH,_,_,_,_,_State}=Msg) ->
    do_search(Msg);
handle({_,_,?SHOP_NPC,_,_,_,_,_State}=Msg) ->
    do_npc_shop(Msg);
handle({_,_,?SHOP_SALE,_,_,_,_,_State}=Msg) ->
    do_sale(Msg);
handle({_,_,?SHOP_ITEM,_,_,_,_,_State}=Msg) ->
    do_shop_item(Msg);
handle({_,_,?SHOP_BUY_BACK,_,_,_,_,_State}=Msg) ->
    do_shop_buy_back(Msg);
handle(force_reload_cuxiao) ->
    do_force_reload_cuxiao();
handle(Other) ->
    ?ERROR_MSG("~ts:~w",["未知消息", Other]).

%% @doc 获取道具价格
get_goods_price(ShopID, GoodsID) ->
    case common_config_dyn:find(shop_shops, ShopID) of
        [Shop] ->
            case lists:keyfind(GoodsID, #r_shop_goods.id, Shop#r_shop_shops.goods) of
                false ->
                    {error, goods_not_found};
                GoodsInfo ->
                    get_goods_price2(GoodsInfo)
            end;
        _ ->
            {error, shop_not_found}
    end.
get_goods_price2(GoodsInfo) ->
    #r_shop_goods{price=[ShopPrice]} = GoodsInfo,
    #p_shop_price{currency=[ShopCurrency]} = ShopPrice,
    #p_shop_currency{id=Type, amount=Num} = ShopCurrency,
    if Type =:= 1 ->
            {ok, {silver, Num}};
       true ->
            {ok, {gold, Num}}
    end.

%%@interface 获取某件物品的商品价格信息
do_shop_item({Unique, Module, Method, DataIn, RoleID, _Pid, Line, _State})->
    #m_shop_item_tos{shop_id=ShopID,item_type_id=ItemTypeID} = DataIn,
    case common_config_dyn:find(shop_shops, ShopID) of
        [R] -> 
            case lists:keyfind(ItemTypeID, #r_shop_goods.id,  R#r_shop_shops.goods) of
                false ->
                    ?SEND_ERR_TOC(m_shop_item_toc, ?_LANG_SHOP_CANNT_FIND_THIS_GOODS);
                Goods ->
                    ShopGoods = get_shop_goods(RoleID,ShopID,Goods),
                    R1 = #m_shop_item_toc{succ=true,shop_id=ShopID,goods=ShopGoods},
                    common_misc:unicast(Line, RoleID, Unique, Module, Method, R1)
            end;
        _  ->
            ?SEND_ERR_TOC(m_shop_item_toc, ?_LANG_SHOP_CANNT_FIND_THIS_SHOP)
    end.

%%购买商品----------------------------------------------------------------------------
do_buy({Unique, Module, Method, DataIn, RoleID, _Pid, Line, _State}) ->    
    R = do_buy2(DataIn, RoleID),
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

do_buy2(DataIn, RoleID) ->
    #m_shop_buy_tos{goods_id = TypeID, price_id = PriceID, goods_num = Num, shop_id = ShopID}=DataIn,
    case catch check_can_buy_goods(RoleID, DataIn) of
        {ok, RoleAttr, GoodsInfo,CuxiaoPrice,CuxiaoItem} ->
            do_buy3(RoleAttr, GoodsInfo, PriceID, Num, RoleID, ShopID, TypeID,CuxiaoPrice,CuxiaoItem);
        {error, Reason, Code} ->
            do_buy_error(Reason, Code);
        Error ->
            ?ERROR_MSG("do_buy2, error: ~w", [Error]),
            do_buy_error(?_LANG_SYSTEM_ERROR, 0)
    end.

%% 是否可以购买道具
check_can_buy_goods(RoleID, DataIn) ->
    #m_shop_buy_tos{goods_id=TypeID, goods_num=Num, shop_id=ShopID} = DataIn,
    %% 输入合法性检测
    case Num =< 0 of
        true ->
            erlang:throw({error, ?_LANG_SHOP_NUMBER_MUST_MORE_THAN_ZERO, 0});
        _ ->
            ok
    end,
    %% 道具是否在商店中
    GoodsInfo =
        case check_is_in_shop(ShopID, TypeID) of
            undefined ->
                throw({error, ?_LANG_SHOP_NOT_THIS_GOODS, 0});
            {error ,Reason1} ->
                throw({error, Reason1, 0});
            Goods ->
                Goods
        end,
    #r_shop_goods{modify=Modify} = GoodsInfo,
    case Modify of
        <<"VIP">> ->
            case mod_vip:is_role_vip(RoleID) of
                true ->
                    ok;
                _ ->
                    throw({error, ?_LANG_SHOP_BUY_ONLY_VIP, 0})
            end;
        _ ->
            ok
    end,
    %% 玩家等级判断
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    case check_role_grade(GoodsInfo, RoleAttr) of
        ok ->
            ok;
        {error, Reason2} ->
            throw({error, Reason2, 0})
    end,
    {CuxiaoPrice,CuxiaoItem} =
        case check_cu_xiao_shop(ShopID, GoodsInfo, Num) of
            {error, Reason3} ->
                throw({error, Reason3, 0});
            {ok,TCuxiaoPrice,TCuxiaoItem} ->
                {TCuxiaoPrice,TCuxiaoItem};
            undefined ->
                {undefined,undefined}
        end,
    {ok, RoleAttr, GoodsInfo,CuxiaoPrice,CuxiaoItem}.

do_buy3(RoleInfo, GoodsInfo,PriceID,Num,RoleID,ShopID,_TypeID,CuxiaoPrice,CuxiaoItem) ->
    IsShopCity = 
    case common_config_dyn:find(shop_npcs,shops) of
        []->false;
        [NpcShop]->
            lists:any(fun(#p_shop_info{id=ID})-> ID=:=ShopID end, NpcShop#r_shop_npc.shops)
    end,
    case common_transaction:transaction(
           fun() ->
                   case check_role_property(GoodsInfo, PriceID, Num, RoleInfo, CuxiaoPrice,IsShopCity) of
                       {error, Reason2, Code} ->
                           common_transaction:abort({Reason2,Code});
                       {ok,NewRoleInfo,{true,Num1},{false,Num2}} ->
                           {ok, GoodsList} = 
                               case GoodsInfo#r_shop_goods.bind of
                                   1 ->%%根据货币
                                       {ok,GoodsList1}=creat_goods(Num1,GoodsInfo,RoleID,true),
                                       {ok,GoodsList2}=creat_goods(Num2,GoodsInfo,RoleID,false),
                                       {ok,lists:append(GoodsList1,GoodsList2)};
                                   2 ->%%强制绑定
                                       creat_goods(Num,GoodsInfo,RoleID,true);
                                   3 ->%%强制不绑定
                                       creat_goods(Num,GoodsInfo,RoleID,false)
                               end,
                           use_consume_logger(RoleInfo,NewRoleInfo,GoodsList,Num),
                           mod_map_role:set_role_attr(RoleID, NewRoleInfo),
                           {#m_shop_buy_toc{succ=true,goods=GoodsList,property=new_property(NewRoleInfo)},GoodsList}
                   end
           end) 
    of
        {atomic, {Record,GoodsList}} ->
            hook_prop:hook(shop_buy, GoodsList),
            %% 成就 add by caochuncheng 2011-03-08
            common_hook_achievement:hook({mod_shop,{buy,RoleID,GoodsList}}),
            up_cuxiao_shop(CuxiaoItem),
            buy_goods_log(GoodsList,Num),
            Record;
        {aborted, {Reason,Code}}when is_integer(Code) ->
            do_buy_error(Reason,Code);
        {aborted, Reason} ->
            do_buy_error(Reason,0)
    end.

check_cu_xiao_shop(ShopID, GoodsInfo, Num) ->
    Key = get_cu_xiao_item_key(ShopID, GoodsInfo#r_shop_goods.id),
    case db:dirty_read(?DB_SHOP_CUXIAO, Key) of
        [] ->
            undefined;
        [#p_shop_cuxiao_item{num=RemainNum, price=Price} = CuxiaoItem] ->
            case RemainNum >= Num of
                true ->
                    case RemainNum > Num of
                        true ->
                            RemainNum2 = RemainNum - Num;
                        false ->
                            RemainNum2 = 0
                    end,
                    {ok,Price,CuxiaoItem#p_shop_cuxiao_item{num=RemainNum2}};
                false ->
                    {error,?_LANG_SHOP_NUM_NOT_ENOUGH}
            end
    end.

up_cuxiao_shop(#p_shop_cuxiao_item{}=CuxiaoItem) ->
    db:dirty_write(?DB_SHOP_CUXIAO,CuxiaoItem);
up_cuxiao_shop(_) ->
    ignore.

use_consume_logger(RoleAttr1,RoleAttr2,[Goods|_],Num) ->
    S = RoleAttr1#p_role_attr.silver-RoleAttr2#p_role_attr.silver,
    SB = RoleAttr1#p_role_attr.silver_bind-RoleAttr2#p_role_attr.silver_bind,
    G = RoleAttr1#p_role_attr.gold - RoleAttr2#p_role_attr.gold,
    GB = RoleAttr1#p_role_attr.gold_bind-RoleAttr2#p_role_attr.gold_bind,

    common_consume_logger:use_silver({RoleAttr1#p_role_attr.role_id, 
                                      SB, 
                                      S, 
                                      ?CONSUME_TYPE_SILVER_BUY_ITEM_FROM_SHOP,
                                      "",
                                      Goods#p_goods.typeid,
                                      Num}),
    common_consume_logger:use_gold({RoleAttr1#p_role_attr.role_id,
                                    GB,
                                    G, 
                                    ?CONSUME_TYPE_GOLD_BUY_ITEM_FROM_SHOP,
                                    "",
                                    Goods#p_goods.typeid,
                                    Num}).

%%为shop_id为0时，表示是挂机时直接购买物品
check_is_in_shop(0, TypeID) ->
    case common_config_dyn:find(shop_npcs,shops) of
        [] ->
            {error,?_LANG_SHOP_DOES_NOT_EXIST};
        [NpcShop] ->
            ShopIDs = lists:foldl(
                        fun(#p_shop_info{id=ID,branch_shop=ChildShopIDs}, Acc) ->
                                lists:append(ChildShopIDs, [ID|Acc])
                        end,[],NpcShop#r_shop_npc.shops),
            (catch lists:foldl(
                     fun(ShopID,Acc) when ShopID =/= 0 ->
                             case check_is_in_shop(ShopID, TypeID) of
                                 undefined -> Acc;
                                 Goods -> throw(Goods)
                             end;
                        (_, Acc) ->
                             Acc
                     end,undefined,ShopIDs))
    end;
check_is_in_shop(ShopID, TypeID) ->
    case common_config_dyn:find(shop_shops, ShopID) of
        [R] ->
            case lists:keyfind(TypeID, 2, R#r_shop_shops.goods) of
                false ->
                    undefined;
                Goods ->
                    Goods
            end;
        _ ->
            undefined
    end.

check_role_grade(GoodsInfo,RoleInfo) ->
    case GoodsInfo#r_shop_goods.role_grade of
        [0,0] ->
            ok;
        [G1,G2] 
          when is_integer(G1),
               is_integer(G2) ->
            check_role_grade2(RoleInfo,G1,G2);
        _ ->
            {error, ?_LANG_SYSTEM_ERROR}
    end.

check_role_grade2(Attr, G1,G2)  ->
    case Attr#p_role_attr.level of
	Level when is_integer(Level) -> 
            case (Level > G1-1) andalso (Level < G2+1) of
                true ->
                    ok;
                false ->
                    {error, ?_LANG_LEVEL_NOT_ENOUGH}
            end;
        _ ->
            {error, ?_LANG_LEVEL_NOT_ENOUGH}
    end.

check_role_property(GoodsInfo,PriceID,Num,RoleAttr, CuxiaoPrice, IsShopCity) ->
    case catch lists:keyfind(PriceID,2,GoodsInfo#r_shop_goods.price) of
        %% 检查商品价格
        Price when is_record(Price, p_shop_price) ->
            %% 检查货币绑定类型:1 不要求 2 一定绑定 3 一定不绑定
            PriceBind = GoodsInfo#r_shop_goods.price_bind,
            %% 一个商品可以用不同货币来出售
            PList = Price#p_shop_price.currency,
            {ok,RoleBase}= mod_map_role:get_role_base(RoleAttr#p_role_attr.role_id),
            %% 判断折扣类型
            {NPList,DisCount} = 
                if 
                    GoodsInfo#r_shop_goods.discount_type =:= 1 -> 
                        %% VIP 折扣类型
                        {PList,mod_vip:get_vip_shop_discount(RoleAttr#p_role_attr.role_id)};
                    GoodsInfo#r_shop_goods.discount_type =:= 0 -> 
                        %% 不打折
                        {PList,100};
                    true -> 
                        case erlang:is_record(CuxiaoPrice, p_shop_price) of
                            true ->
                                %% 如果是其他值，则说明是促销价，需要覆盖掉原价，这里设计的相当恶心，有时间一定要重写
                                {CuxiaoPrice#p_shop_price.currency,100};
                            _ ->
                                {[{A,B,GoodsInfo#r_shop_goods.discount_type} || {A,B,_} <- PList],100}
                        end		
                end,
            %% 红名购买商品有惩罚
            if RoleBase#p_role_base.pk_points > 18 ->
                    property_audit(NPList,RoleAttr,PriceBind,Num,1.2*DisCount/100,IsShopCity);
               true ->
                    property_audit(NPList,RoleAttr,PriceBind,Num,1*DisCount/100,IsShopCity)
            end;
        _ ->
            ?DEBUG("PriceID error",[]),
            {error, ?_LANG_SYSTEM_ERROR, 0}
    end.

property_audit(PriceL,Attr,PriceBind, Num,Multi,IsShopCity) ->
    catch lists:foldl(
            fun(_,{ok,AccAttr1,{true,AccNum1},{false,AccNum2}}) ->
                    case lists:foldl(
                           fun({p_shop_currency,?GOLD,Am},{_BindMark,AccAttr2}) ->
                                   #p_role_attr{gold=Gold, gold_bind=GoldBind, unbund=UnBind}=AccAttr2,
                                   {{unbind,NewGold},{bind,NewGoldBind},NewBindMark} =
                                       audit(IsShopCity,Gold,GoldBind,PriceBind,UnBind,Am,Multi,
                                             3,2,1
                                            ),
                                   {NewBindMark,AccAttr2#p_role_attr{gold=NewGold,gold_bind=NewGoldBind}};
                              ({p_shop_currency,?SILVER,Am},{_BindMark,AccAttr2}) ->
                                   #p_role_attr{silver=Silver, silver_bind=SilverBind, unbund=UnBind}=AccAttr2,
                                   {{unbind,NewSilver},{bind,NewSilverBind},NewBindMark} =
                                       audit(IsShopCity,Silver,SilverBind,PriceBind,UnBind,Am,Multi,
                                             6,5,4
                                            ),
                                   {NewBindMark,AccAttr2#p_role_attr{silver=NewSilver,silver_bind=NewSilverBind}}
                           end,{true,AccAttr1},PriceL)
                    of
                        {true,NewAccAttr1} ->
                            {ok,NewAccAttr1,{true,AccNum1+1},{false,AccNum2}};
                        {false,NewAccAttr1} ->
                            {ok,NewAccAttr1,{true,AccNum1},{false,AccNum2+1}}
                    end
            end,{ok,Attr,{true,0},{false,0}},lists:seq(1,Num)).

%% UnBindPr:int() 玩家目前不绑元宝数
%% BindPr:int() 玩家目前绑定元宝数
%% PBind:int() 物品绑定类型 1 不要求 2 一定绑定 3 一定不绑定
%% UnBind:bool() 是否不使用绑定的货币 true 使用不绑定货币
%% Am:int() 物品数量 -.-!
%% Multi:float() 价格倍数
%% Tips:int() 自己猜
%% 是否商城，消费规则，主要针对那个什么商店
audit(IsShopCity,UnBindPr,BindPr,PBind,UnBind,Am,Multi,EnoughTips,BindEnoughTips,UnbindEnoughTips) ->
    if (UnBind =:= true andalso IsShopCity =/=true) orelse PBind =:= 3 -> %%不绑定
            case UnBindPr-common_tool:ceil(Am*Multi) of
                R when R < 0 ->
                    throw({error, "",UnbindEnoughTips});
                R ->
                    {{unbind,R},{bind,BindPr},false}
            end;
       PBind =:= 2 -> %%绑定
            case BindPr-common_tool:ceil(Am*Multi) of
                R when R < 0 ->
                    throw({error, "",BindEnoughTips});
                R ->
                    {{unbind,UnBindPr},{bind,R},true}
            end;
       true -> %%不限制
            case BindPr-common_tool:ceil(Am*Multi) of
                R1 when R1 < 0 ->
                    case (UnBindPr - abs(R1)) of
                        R2 when R2 < 0 ->
                            throw({error, "",EnoughTips});
                        R2 when BindPr =:= 0 ->
                            {{unbind,R2},{bind,0},false};
                        R2 ->
                            {{unbind,R2},{bind,0},true}
                    end;
                R1  ->
                    {{unbind,UnBindPr},{bind,R1},true}
            end
    end.

creat_goods(0,_Goods,_RoleID,_Bind) ->
    {ok,[]};
creat_goods(N,Goods,RoleID,Bind) ->
    [StartTime,EndTime] = Goods#r_shop_goods.time,
    CreateInfo = #r_goods_create_info{bind=Bind, 
                                      type=Goods#r_shop_goods.type, 
                                      start_time=StartTime,
                                      end_time=EndTime,
                                      type_id=Goods#r_shop_goods.id,
                                      num=N * Goods#r_shop_goods.num,
                                      interface_type=buy
                                     },
    case catch mod_bag:create_goods(RoleID, CreateInfo) of
        {bag_error,not_enough_pos} ->
            db:abort(?_LANG_SHOP_BAG_NOT_ENOUGH);
        Other ->
            Other
    end.

do_buy_error(Reason, Code)when is_binary(Reason) ->
    #m_shop_buy_toc{succ=false, reason=Reason, error_code=Code};
do_buy_error(Reason, Code) ->
    ?ERROR_MSG("~ts:~w~n",["购买物品是出错，原因",Reason]),
    #m_shop_buy_toc{succ=false, reason=?_LANG_SYSTEM_ERROR, error_code=Code}.

buy_goods_log(GoodsList,Num) ->
    [Goods|_T] = GoodsList,
    #p_goods{roleid=RoleID}=Goods,
    common_item_logger:log(RoleID,Goods,Num,?LOG_ITEM_TYPE_SHANG_DIAN_GOU_MAI).

%%获取所有的商店列表------------------------------------------------------------------------
do_get_shops({Unique, Module, Method, _DataIn, _RoleID, Pid, _Line,_State}) ->
    R = case common_config_dyn:find(shop_npcs,shops) of
            [Record] ->
                Shops = [do_get_shops2(ShopInfo) || ShopInfo <- Record#r_shop_npc.shops],
                #m_shop_shops_toc{shops = Shops};
            [] ->
                #m_shop_shops_toc{shops=[]}
        end,
    ?DEBUG("~w~n",[R]),
    common_misc:unicast2(Pid, Unique, Module, Method, R).

do_get_shops2(#p_shop_info{branch_shop=CShopIDs} = ShopInfo) ->
    ShopInfo#p_shop_info{
      branch_shop= lists:reverse(lists:foldl(
                                   fun(ShopID, Acc) ->
                                           case common_config_dyn:find(shop_shops, ShopID) of
                                               [] ->
                                                   Acc;
                                               [#r_shop_shops{name=Name}] ->
                                                   [#p_shop_info{id=ShopID,name=Name,branch_shop=[]}|Acc]
                                           end
                                   end,[],CShopIDs))}.


%%获取指定商店的商品列表------------------------------------------------------------------------
do_get_goods({Unique, Module, Method, DataIn, RoleID, Pid, _Line,_State}) ->
    #m_shop_all_goods_tos{npc_id=NPCID,shop_id=ShopID}=DataIn,
    R =  case common_config_dyn:find(shop_npcs, convert_npc_id(NPCID)) of
             [_] ->

                 do_get_goods2(RoleID,NPCID,ShopID);
             [] ->
                 ?DEBUG("2 ERROR=============",[]),
                 #m_shop_all_goods_toc{npc_id = NPCID,shop_id = ShopID, all_goods = []}
         end,
    common_misc:unicast2(Pid, Unique, Module, Method, R).

do_get_goods2(RoleID,NPCID,ShopID) ->
    ?DEBUG("3=============NPCID:~w, SHOPS:~w~n",[NPCID,ShopID]),
    case common_config_dyn:find(shop_shops, ShopID) of
        [R] ->
            AllGoods = get_shop_goods(RoleID,ShopID,R#r_shop_shops.goods),
            ?INFO_MSG("AllGoods:~w~n",[AllGoods]),
            #m_shop_all_goods_toc{npc_id = NPCID,shop_id = ShopID, all_goods = lists:reverse(AllGoods)};
        [] ->
            ?DEBUG("3 ERROR=============",[]),
            #m_shop_all_goods_toc{npc_id = NPCID,shop_id = ShopID, all_goods = []}
    end.

%%搜索指定的商品----------------------------------------------------------------------
do_search({Unique, Module, Method, DataIn, RoleID, _Pid, Line,_State}) ->
    #m_shop_search_tos{search_goods_id=GoodsIDList, npc_id=NPCID} = DataIn,
    R = case common_config_dyn:find(shop_npcs, convert_npc_id(NPCID)) of
            [Re] ->
                do_search2(Re#r_shop_npc.shops,RoleID,GoodsIDList,[], 1);
            [] ->
                #m_shop_search_toc{search_all_goods = [],npc_id=NPCID}
        end,
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

do_search2([],_, _GoodsIDList,GoodsList, _Seat) ->
    ?DEBUG("GOODS:~w~n",[GoodsList]),
    #m_shop_search_toc{search_all_goods = GoodsList};
do_search2([Shop|T],RoleID,GoodsIDList,GoodsList, Seat) when is_integer(Shop) ->
    case common_config_dyn:find(shop_shops, Shop) of
        [R] ->
            {NewGoodsList, NewSeat} = 
                get_search_goods(GoodsIDList, RoleID, GoodsList, R#r_shop_shops.id,R#r_shop_shops.goods, Seat),
            do_search2(T,RoleID, GoodsIDList, NewGoodsList, NewSeat);
        [] ->
            do_search2(T,RoleID, GoodsIDList, GoodsList, Seat)
    end;
do_search2([Shop|T],RoleID,GoodsIDList,GoodsList, Seat) ->	   
    case Shop#p_shop_info.branch_shop of
        [] ->
            do_search2([Shop#p_shop_info.id|T],RoleID,GoodsIDList,GoodsList, Seat);
        BShops ->
            do_search2(lists:append(BShops,T),RoleID,GoodsIDList,GoodsList, Seat)
    end.

get_search_goods([], _, GoodsList, _, _, Seat) ->
    {GoodsList, Seat};
get_search_goods([H|T], RoleID, GoodsList,ShopID, RGoodsList, Seat) ->
    case lists:keyfind(H, 2, RGoodsList) of
        false ->
            get_search_goods(T,RoleID,GoodsList,ShopID,RGoodsList,Seat);
        Goods ->
            NewGoods = Goods#r_shop_goods{seat = Seat},
            case get_shop_goods(RoleID,ShopID,NewGoods) of
                undefined -> get_search_goods(T, RoleID, GoodsList,ShopID,RGoodsList,Seat);
                PGoods -> get_search_goods(T,RoleID, [PGoods|GoodsList],ShopID,RGoodsList,Seat+1)
            end
    end.

%%获取npc商店的信息------------------------------------------------------------------
do_npc_shop({Unique, Module, Method, DataIn, _RoleID, Pid, _Line,_State}) ->
    #m_shop_npc_tos{npc_id = NPCID} = DataIn,
    R = case common_config_dyn:find(shop_npcs, NPCID) of
            [Re] ->
                #m_shop_npc_toc{npc_id=NPCID,shops = Re#r_shop_npc.shops};
            _ ->
                #m_shop_npc_toc{npc_id=NPCID,shops=[]}
        end,
    common_misc:unicast2(Pid, Unique, Module, Method, R).

%%把物品卖给npc商店------------------------------------------------------------------
do_sale({Unique, Module, Method, DataIn, RoleID, _Pid, Line, _State}) ->
    #m_shop_sale_tos{goods = SaleList} = DataIn,
    R = do_sale2(RoleID,SaleList),
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

do_sale2(RoleID,SaleList) ->
    case db:transaction(fun() -> t_sale(SaleList, RoleID) end) of
        {atomic,{NewRoleAttr, GoodsList,GoodsPrizeList}} ->
            Property = new_property(NewRoleAttr),
            sale_goods_log(GoodsList),
            %%common_misc:del_goods_notify({role,RoleID}, GoodsList),
            hook_buy_back_sale(RoleID,GoodsPrizeList),
            #m_shop_sale_toc{succ=true, property=Property,ids=[SaleGoods#p_shop_sale_goods.id||SaleGoods<-SaleList]};
        {aborted, Reason} ->
            do_sale_error(Reason)
    end.

gain_consume_logger(RoleAttr1,RoleAttr2,[Goods|_]=GoodsList) ->
    S = RoleAttr2#p_role_attr.silver-RoleAttr1#p_role_attr.silver,
    SB = RoleAttr2#p_role_attr.silver_bind-RoleAttr1#p_role_attr.silver_bind,
    G = RoleAttr2#p_role_attr.gold - RoleAttr1#p_role_attr.gold,
    GB = RoleAttr2#p_role_attr.gold_bind-RoleAttr1#p_role_attr.gold_bind,

    Length = 
        if Goods#p_goods.typeid =:= ?TYPE_EQUIP ->
                erlang:length(GoodsList);
           true ->
                lists:foldl(fun(Gd,Sum) -> Sum+Gd#p_goods.current_num end,0,GoodsList)
        end,
    common_consume_logger:gain_silver({RoleAttr1#p_role_attr.role_id, 
                                       SB,
                                       S,
                                       ?GAIN_TYPE_SILVER_SALE_ITEM_FROM_SHOP,
                                       "",
                                       Goods#p_goods.typeid,
                                       Length}),
    common_consume_logger:gain_gold({RoleAttr1#p_role_attr.role_id,
                                     GB,
                                     G, 
                                     ?GAIN_TYPE_GOLD_SALE_ITEM_FROM_SHOP,
                                     "",
                                     Goods#p_goods.typeid,
                                     Length}).

get_goods_price(Goods) ->
    #p_goods{sell_price=SellPrice,
             current_endurance=CE,
             endurance=ES,
             refining_index=RI}=Goods,  
    common_tool:ceil(SellPrice*RI*CE/ES/10).

t_sale(SellList, RoleID) -> 
    {ok,#p_role_attr{silver=OldSilver, silver_bind=OldBindSilver} = RoleAttr}= mod_map_role:get_role_attr(RoleID),
    {AddSilver, AddBindSilver,NewGoodsPrizeList} = lists:foldl(
                                   fun(#p_shop_sale_goods{id = Id}, {Silver, BindSilver,GoodsPrizeList}) ->
                                           case mod_bag:get_goods_by_id(RoleID, Id) of
                                               {ok, Goods} ->
                                                   #p_goods{bind=Bind, type=Type, sell_price=SellPrice, 
                                                            sell_type=SellType, current_num=Num} = Goods,
                                                   case SellType of
                                                       ?UNAVAI ->
                                                           db:abort(?_LANG_SHOP_GOODS_CANT_SELL);
                                                       _ ->
                                                           ok
                                                   end,
                                                   case Type =:= ?TYPE_EQUIP of
                                                       true ->
                                                           NewPrice = get_goods_price(Goods),
                                                           case Bind of
                                                               true ->
                                                                   {Silver, BindSilver + NewPrice*Num,[Goods|GoodsPrizeList]};
                                                               false ->
                                                                   {Silver + NewPrice*Num, BindSilver,[Goods|GoodsPrizeList]}
                                                           end;
                                                       false  ->
                                                           NewPrice = SellPrice, 
                                                           case Bind of
                                                               true ->
                                                                   {Silver, BindSilver + NewPrice*Num,[Goods|GoodsPrizeList]};
                                                               false ->
                                                                   {Silver + NewPrice*Num, BindSilver,[Goods|GoodsPrizeList]}
                                                           end
                                                   end;
                                               {error, Reason} ->
                                                   db:abort(Reason)
                                           end
                                   end, {0, 0,[]}, SellList),
    GoodsIDList = [GID || #p_shop_sale_goods{id=GID} <- SellList],
    NewRoleAttr = RoleAttr#p_role_attr{silver=OldSilver + AddSilver, silver_bind=OldBindSilver + AddBindSilver},    
    {ok, GoodsList} = mod_bag:delete_goods(RoleID, GoodsIDList),
    mod_map_role:set_role_attr(RoleID, NewRoleAttr),    
    gain_consume_logger(RoleAttr,NewRoleAttr,GoodsList),
    {NewRoleAttr, GoodsList, NewGoodsPrizeList}.

do_sale_error(Reason)when is_binary(Reason) ->
    #m_shop_sale_toc{succ=false, property=[], ids=[], reason=Reason};
do_sale_error(Reason) ->
    ?ERROR_MSG("~ts:~w~n",["将物品卖个系统出错，原因",Reason]),
    #m_shop_sale_toc{succ=false, property=[], ids=[], reason=?_LANG_SYSTEM_ERROR}.

sale_goods_log(GoodsList) ->
    lists:foreach(
      fun(Goods) ->
              #p_goods{roleid=RoleID}=Goods,
              common_item_logger:log(RoleID,Goods,?LOG_ITEM_TYPE_CHU_SHOU_XI_TONG)
      end,GoodsList).

%%---------------------------------------------------------------------------------

get_cuxiao_item_by_id(ItemID, ShopID) ->
    case lists:keyfind(ShopID,1,common_config_dyn:list(shop_cu_xiao)) of
        false ->
            undefined;
        _ ->
            case db:dirty_read(?DB_SHOP_CUXIAO, get_cu_xiao_item_key(ShopID, ItemID)) of
                [] ->
                    {error, not_found};
                [#p_shop_cuxiao_item{begin_time=BeginTime, end_time=EndTime} = Info] ->
                    Now = common_tool:now(),
                    if
                        EndTime >= Now andalso BeginTime =:= 0 ->
                            {ok, Info};
                        EndTime < Now andalso BeginTime =:= 0 ->
                            {error, not_found};
                        BeginTime < Now andalso EndTime =:= 0 ->
                            {ok, Info};
                        BeginTime >= Now andalso EndTime =:= 0 ->
                            {error, not_found};
                        true ->
                            {error, not_found}
                    end
            end
    end.

get_shop_transform_fun(RoleID, ShopID)->
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),   
    Multi = 1.2,
    fun(R) ->
            case get_cuxiao_item_by_id(R#r_shop_goods.id, ShopID) of
                {error, _} -> 
                    undefined;
                Other ->
                    Num = case Other of
                              undefined ->
                                  R#r_shop_goods.num;
                              {ok,Info} -> 
                                  Info#p_shop_cuxiao_item.num
                          end,                	   
                    Price = 
                        if RoleBase#p_role_base.pk_points > 18 ->
                                get_red_name_price(R#r_shop_goods.price,Multi);
                           true ->
                                R#r_shop_goods.price
                        end,                                
                    Bind =
              		case R#r_shop_goods.bind of
                            1 ->
                        	false;
                            2 ->
                        	true;
                            3 ->
                        	false
                	end,
                    {Pro,Colour} = 
                	case R#r_shop_goods.type of
                            ?TYPE_ITEM ->
                        	get_item_pro_colour(R#r_shop_goods.id);
                            ?TYPE_STONE ->
                        	get_stone_pro_colour(R#r_shop_goods.id);
                            ?TYPE_EQUIP ->
                        	get_equip_pro_colour(R#r_shop_goods.id)
                	end,
                    %% r_shop_goods 中的 discount_type 为 0 表示无折扣， 为1表示VIP折扣，其他值表示折扣价格
                    %% 促销商品中的折扣价格特殊对待，配置在shop_cu_xiao.config中
                    DiscountType = 
                        case Other of
                            undefined ->
                                R#r_shop_goods.discount_type;
                            {ok, Info2} ->
                                [P] = (Info2#p_shop_cuxiao_item.price)#p_shop_price.currency,
                                P#p_shop_currency.amount
                        end,
                    #p_shop_goods_info{
                          goods_id = R#r_shop_goods.id,
                          seat_id = R#r_shop_goods.seat,
                          packe_num = Num,
                          time = R#r_shop_goods.time,
                          role_grade = R#r_shop_goods.role_grade,
                          goods_bind = Bind,
                          goods_modify = R#r_shop_goods.modify,
                          price = Price,
                          type = R#r_shop_goods.type,
                          colour = Colour,
                          property = Pro,
                          discount_type=DiscountType,
                          shop_id = ShopID,
                          price_bind = R#r_shop_goods.price_bind
                         }
            end
    end.
    

%%获取商店中的商品列表
get_shop_goods(RoleID,ShopID,ShopGoods) when is_record(ShopGoods,r_shop_goods) -> 
    F = get_shop_transform_fun(RoleID,ShopID),
    F(ShopGoods);
get_shop_goods(RoleID,ShopID,ShopGoodsList) when is_list(ShopGoodsList) -> 
    F = get_shop_transform_fun(RoleID,ShopID),
    lists:foldl(fun(G,Acc) -> 
                        case catch F(G) of
                            R when is_record(R,p_shop_goods_info) ->
                                [R|Acc];
                            _R ->
                                Acc
                        end
                end, [], ShopGoodsList).

%%红名价格
get_red_name_price(PriceList,Multi) ->
    lists:foldl(
      fun(Price,Acc1) ->
              [Price#p_shop_price{
                 currency=
                     lists:foldl(
                       fun({p_shop_currency,ID,Amount},Acc2) ->
                               [{p_shop_currency,ID,common_tool:ceil(Amount*Multi)}|Acc2]
                       end,[],Price#p_shop_price.currency)
                }|Acc1]
      end,[],PriceList).

%%构造玩家的财产列表
new_property(NewAttr) ->
    [    
         NewAttr#p_role_attr.silver, 
         NewAttr#p_role_attr.silver_bind,
         NewAttr#p_role_attr.gold,
         NewAttr#p_role_attr.gold_bind
    ].

%%
get_item_pro_colour(TypeID) ->
    [BaseInfo] = common_config_dyn:find_item(TypeID),
    {undefined,BaseInfo#p_item_base_info.colour}.   

get_stone_pro_colour(TypeID) ->
    [BaseInfo] = common_config_dyn:find_stone(TypeID),
    {BaseInfo#p_stone_base_info.level_prop,BaseInfo#p_stone_base_info.colour}.

get_equip_pro_colour(TypeID) ->
    [BaseInfo] = common_config_dyn:find_equip(TypeID),
    {BaseInfo#p_equip_base_info.property,BaseInfo#p_equip_base_info.colour}.


convert_npc_id(0) -> shops;
convert_npc_id(ShopID) -> ShopID.
%%==========================================
init() ->
    {ok,RecNpcList1} = 
        file:consult(common_config:get_map_config_file_path(shop_npcs)),
    {ok,RecShopsList1} = 
        file:consult(common_config:get_map_config_file_path(shop_shops)),
    {RecNpcList2,RecShopsList2} =
        case common_config:is_debug() of
            true ->
                {case lists:keyfind(shops,2,RecNpcList1) of
                     false ->
                         RecNpcList1;
                     #r_shop_npc{shops = Shops} = ShopInfo ->
                         [ShopInfo#r_shop_npc{shops=lists:reverse([{p_shop_info,?FREE_SHOP,"免费商店",[?FREE_SHOP]}|lists:reverse(Shops)])}|
                          lists:keydelete(shops,2,RecNpcList1)]
                 end,
                 [init_test_data(?FREE_SHOP)|RecShopsList1]};
            false ->
                {RecNpcList1,RecShopsList1}
        end,
    NpcKeyValues = 
        [ begin
              Key = element(2,Rec), {Key,Rec}
          end || Rec <- RecNpcList2 ],
    auth_shop_item(RecShopsList2),
    ShopsKeyValues =
        [ begin
              Key = element(2,Rec), {Key,Rec}
          end || Rec <- RecShopsList2 ],
    common_config_dyn:load_gen_src(shop_npcs,NpcKeyValues),
    common_config_dyn:load_gen_src(shop_shops,ShopsKeyValues),
    erlang:spawn(fun() -> spawn_init_cu_xiao() end).

%% 随机返回一个list中的N个元素
get_random_item_list(ItemList, N) ->
    {_, RtnList} = lists:foldl(
                     fun(_, {List, Result}) ->
                             Item = lists:nth(common_tool:random(1, erlang:length(List)), List),
                             {lists:delete(Item, List) , [Item|Result]}
                     end, {ItemList, []}, lists:seq(1, N)),
    RtnList.

%% h获取促销商品每天刷新的时间
get_cuxiao_refresh_time() ->
    [Val] = common_config_dyn:find(etc, shop_cuxiao_refresh_time),
    Val.

%% 是否初始化的标志放在进程字典
check_has_init(RefreshDate) ->
    case erlang:get({shop_cuxiao_flag, RefreshDate}) of
        undefined ->
            case db:dirty_read(?DB_SHOP_CUXIAO_FLAG_P, RefreshDate) of
                [] ->
                    false;
                _ ->
                    true
            end;
        Flag ->
            Flag
    end.

set_has_init(RefreshDate) ->
    erlang:put({shop_cuxiao_flag, RefreshDate}, true),
    db:dirty_write(?DB_SHOP_CUXIAO_FLAG_P, #r_shop_cuxiao_flag{time=RefreshDate, flag=true}).
dirty_clear_cu_xiao() ->
    case db:dirty_match_object(?DB_SHOP_CUXIAO, #p_shop_cuxiao_item{_='_'}) of
        [] ->
            ignore;
        ShopCuXiaoList when erlang:is_list(ShopCuXiaoList) ->
            lists:foreach(
              fun(ShopCuXiaoRecord) ->
                      db:dirty_delete(?DB_SHOP_CUXIAO, ShopCuXiaoRecord#p_shop_cuxiao_item.key)
              end,ShopCuXiaoList);
        _ ->
            ignore
    end,
    case db:dirty_match_object(?DB_SHOP_CUXIAO_FLAG_P, #r_shop_cuxiao_flag{_='_'}) of
        [] ->
            ignore;
        ShopCuXiaoFlagList when erlang:is_list(ShopCuXiaoFlagList) ->
            lists:foreach(
              fun(ShopCuXiaoFlagRecord) ->
                      db:dirty_delete(?DB_SHOP_CUXIAO_FLAG_P, ShopCuXiaoFlagRecord#r_shop_cuxiao_flag.time)
              end,ShopCuXiaoFlagList);
        _ ->
            ignore
    end.
    
reload_cu_xiao() ->
    dirty_clear_cu_xiao(),
    init_cu_xiao().
init_cu_xiao() ->
    RefreshTime = get_cuxiao_refresh_time(),
    {Date, _} = erlang:localtime(),
    RefreshDate = {Date, RefreshTime},
    %% 判断今天是否已经初始化过一次了
    case check_has_init(RefreshDate) of
        false ->
            %% 判断是否已有记录，如果已经有记录，开服前的三天内都不再初始化了
            case db:dirty_match_object(?DB_SHOP_CUXIAO, #p_shop_cuxiao_item{_='_'}) of
                [] ->          
                    init_cuxiao2(),
                    set_has_init(RefreshDate);
                _ ->
                    {OpenDate, _} = common_config:get_open_day(),
                    {NowDate, _} = erlang:localtime(),
                    case common_time:diff_date(OpenDate, NowDate) < 3 of
                        true ->
                            ignore;
                        false ->
                            %% 清空原有的记录
                            db:clear_table(?DB_SHOP_CUXIAO),
                            init_cuxiao2(),
                            set_has_init(RefreshDate)
                    end
            end;
        true ->
            ignore
    end.

init_cuxiao2() ->
    lists:foreach(
      fun({ShopID,{BeginItemList, AfterItemList}}) ->
              %% 开服前几天才有的道具，暂时为3
              BeginItemList2 = get_random_item_list(BeginItemList, 3),
              EndTime = common_time:date_to_time(common_time:add_days(common_config:get_open_day(), 3)),
              lists:foreach(
                fun(#p_shop_cuxiao_config{item_id=ItemID, num=Num, price=Price}) ->
                        R = #p_shop_cuxiao_item{key=get_cu_xiao_item_key(ShopID, ItemID), shop_id=ShopID,
                                                begin_time=0, end_time=EndTime, price=Price,
                                                item_id=ItemID, num=Num},
                        db:dirty_write(?DB_SHOP_CUXIAO, R)
                end, BeginItemList2),
              %% 开服几天后一直存在的道具，暂时为3
              AfterItemList2 = get_random_item_list(AfterItemList, 3),
              BeginTime = common_time:date_to_time(common_time:add_days(common_config:get_open_day(), 3)),
              lists:foreach(
                fun(#p_shop_cuxiao_config{item_id=ItemID, num=Num, price=Price}) ->
                        R = #p_shop_cuxiao_item{key=get_cu_xiao_item_key(ShopID, ItemID), shop_id=ShopID, num=Num,
                                                price=Price,
                                                begin_time=BeginTime, end_time=0, item_id=ItemID},
                        db:dirty_write(?DB_SHOP_CUXIAO, R)
                end, AfterItemList2)                      
      end,common_config_dyn:list(shop_cu_xiao)).

get_cu_xiao_item_key(ShopID, ItemID) ->
    lists:concat([ShopID, "__", ItemID]).

auth_shop_item([]) ->
    ok;
auth_shop_item([#r_shop_shops{goods=GoodsList}|T]) ->
    lists:foreach(
      fun(#r_shop_goods{id=TypeID,type=Type}) ->
              case Type of
                  ?TYPE_EQUIP ->
                      case common_config_dyn:find_equip(TypeID) of
                          [_] ->
                              ignore;
                          _ ->
                              throw({not_goods,TypeID})
                      end;
                  ?TYPE_STONE ->
                      case common_config_dyn:find_stone(TypeID) of
                          [_] ->
                              ignore;
                          _ ->
                              throw({not_goods,TypeID})
                      end;
                  ?TYPE_ITEM ->
                      case common_config_dyn:find_item(TypeID) of
                          [_] ->
                              ignore;
                          _ ->
                              throw({not_goods,TypeID})
                      end
              end
      end,GoodsList),
    auth_shop_item(T).

change_test(true) ->
    case common_config_dyn:find(shop_npcs,shops) of
        [] ->
            ignore;
        [#r_shop_npc{shops = Shops} = ShopInfo] ->
            case lists:keymember(?FREE_SHOP,2,Shops) of
                false ->
                    case common_config_dyn:find(shop_shops,?FREE_SHOP) of
                        [_] ->
                            ignore;
                        [] ->
                            {ok,RecShopsList1} = 
                                file:consult(common_config:get_map_config_file_path(shop_shops)),
                            RecShopsList2 = 
                                [init_test_data(?FREE_SHOP)|RecShopsList1],
                            ShopsKeyVlaues =
                                [ begin
                                      Key = element(2,Rec), {Key,Rec}
                                  end || Rec <- RecShopsList2 ],
                            common_config_dyn:load_gen_src(shop_shops,ShopsKeyVlaues)
                    end,
                    {ok,RecNpcList1} = 
                        file:consult(common_config:get_map_config_file_path(shop_npcs)),
                    NewShops = 
                        lists:reverse([{p_shop_info,?FREE_SHOP,"免费商店",[?FREE_SHOP]}
                                       |lists:reverse(ShopInfo#r_shop_npc.shops)]),
                    RecNpcList2 = 
                        [ShopInfo#r_shop_npc{shops=NewShops}|lists:keydelete(shops,2,RecNpcList1)],
                    NpcKeyValues = 
                        [ begin
                              Key = element(2,Rec), {Key,Rec}
                          end || Rec <- RecNpcList2 ],
                    common_config_dyn:load_gen_src(shop_npcs,NpcKeyValues);
                true ->
                    ok
            end
    end;
change_test(false) ->
    case common_config_dyn:find(shop_npcs,shops) of
        [] ->
            ignore;
        [#r_shop_npc{shops = Shops}] ->
            case lists:keymember(?FREE_SHOP,2,Shops) of
                false ->
                    ok;
                true ->
                    case common_config_dyn:find(shop_shops,?FREE_SHOP) of
                        [] ->
                            ignore;
                        [_] ->
                            {ok,RecShopsList} = 
                                file:consult(common_config:get_map_config_file_path(shop_shops)),
                            ShopsKeyVlaues =
                                [ begin
                                      Key = element(2,Rec), {Key,Rec}
                                  end || Rec <- RecShopsList ],
                            common_config_dyn:load_gen_src(shop_shops,ShopsKeyVlaues)
                    end,
                    {ok,RecNpcList} = 
                        file:consult(common_config:get_map_config_file_path(shop_npcs)),
                    NpcKeyVlaues = 
                        [ begin
                              Key = element(2,Rec), {Key,Rec}
                          end || Rec <- RecNpcList ],
                    common_config_dyn:load_gen_src(shop_npcs,NpcKeyVlaues)
            end
    end.

init_test_data(ShopID) ->
    StoneList = common_config_dyn:list_stone(),
    ItemList = common_config_dyn:list_item(),
    EquipList = common_config_dyn:list_equip(),
    {List1,S1} = 
        lists:foldl(
          fun(Goods1,{Acc1,Seat1}) ->
                  ?DEBUG("Goods1:~w",[Goods1]),
                  G1 = #r_shop_goods{
                    id = Goods1#p_stone_base_info.typeid, 
                    num = 1, 
                    bind = 3, 
                    modify = "",
                    price_bind = 1, 
                    price = [{p_shop_price,1,[{p_shop_currency, 1, 0}]}], 
                    fixed_price = [{p_shop_price,1,[{p_shop_currency, 1, 0}]}],
                    time = [0,0],
                    role_grade = [0,400],
                    type = 2,
                    seat = Seat1,
                    discount_type = 0},
                  {[G1|Acc1],Seat1+1}
          end,{[],1},StoneList),
    {List2,S2} =
        lists:foldl(
          fun(Goods2,{Acc2,Seat2}) ->
                  G2 = #r_shop_goods{
                    id = Goods2#p_item_base_info.typeid, 
                    num = 1, 
                    bind = 3, 
                    modify = "",
                    price_bind = 1, 
                    price =  [{p_shop_price,1,[{p_shop_currency, 1, 0}]}], 
                    fixed_price = [{p_shop_price,1,[{p_shop_currency, 1, 0}]}], 
                    time = [0,0],
                    role_grade = [0,400],
                    type = 1,
                    seat= Seat2,
                    discount_type = 0},
                  {[G2|Acc2],Seat2+1}
          end,{List1,S1},ItemList),
    {List3,_} =
        lists:foldl(
          fun(Goods3,{Acc3,Seat3}) ->
                  G3 = #r_shop_goods{
                    id = Goods3#p_equip_base_info.typeid, 
                    num = 1, 
                    bind = 3, 
                    modify = "",
                    price_bind = 1, 
                    price = [{p_shop_price,1,[{p_shop_currency, 1, 0}]}], 
                    fixed_price = [{p_shop_price,1,[{p_shop_currency, 1, 0}]}],
                    time = [0,0],
                    role_grade = [0, 400],
                    type = 3,
                    seat = Seat3,
                    discount_type = 0},
                  {[G3|Acc3],Seat3+1}
          end,{List2,S2},EquipList),
    #r_shop_shops{id=ShopID,name="免费商店",branchs=[],goods=lists:reverse(List3),time=[0,9999999999]}.

spawn_init_cu_xiao() ->
    case erlang:whereis(db_shop_cuxiao_subscriber) of
        undefined -> timer:sleep(1000),spawn_init_cu_xiao();
        _ -> init_cu_xiao()
    end.

%% 强制清理掉所有的记录
do_force_reload_cuxiao() ->
    ok.

%%----------- 买回物品 ----------------------

%% 卖出物品写入可买回物品列表
hook_buy_back_sale(RoleID,GoodsList)->
    case mod_map_role:get_role_map_ext_info(RoleID) of
        {error,not_found}->
            ?ERROR_MSG("数据丢失，严重！",[]);
        {ok,ExpInfo}->
            NewGoodsList = GoodsList++ExpInfo#r_role_map_ext.buy_back_goods,
            NewGoodsList1 = 
                case length(NewGoodsList)=< ?BUY_BACK_NUM of
                    true->
                        NewGoodsList;
                    false->
                        {List1,_List2}=lists:split(?BUY_BACK_NUM, NewGoodsList),
                        List1
                end,
            mod_map_role:set_role_map_ext_info(RoleID,ExpInfo#r_role_map_ext{buy_back_goods=NewGoodsList1}),
            case length(GoodsList)>1 of
                true->
                    DataRecord = #m_shop_buy_back_toc{op_type=?GET_LIST,goods=NewGoodsList1},
                    common:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?SHOP, ?SHOP_BUY_BACK, DataRecord);
                false->
                    ignore
            end
    end.

%% 玩家买回物品请求 包括1.获取可买回物品列表 2.买回某物品
do_shop_buy_back({Unique, Module, Method, DataIn, RoleID, _Pid, Line, _State}) -> 
    #m_shop_buy_back_tos{op_type=OpType} = DataIn,
    case OpType of
        ?GET_LIST->
            do_get_buy_back_list({Unique, Module, Method, DataIn, RoleID, _Pid, Line, _State});
        ?BUY_BACK->
            do_buy_back_goods({Unique, Module, Method, DataIn, RoleID, _Pid, Line, _State})
            
    end.

%% 获取玩家可买回物品列表
do_get_buy_back_list({Unique, Module, Method, _DataIn, RoleID, _Pid, Line, _State})->
    {ok,GoodsList} = 
    case mod_map_role:get_role_map_ext_info(RoleID) of
        {ok,ExpInfo} when is_record(ExpInfo,r_role_map_ext)->
            {ok,ExpInfo#r_role_map_ext.buy_back_goods};
        _->
            {ok,[]}
    end,
    TocRecord = #m_shop_buy_back_toc{op_type=?GET_LIST,
                                     goods=GoodsList},
    common_misc:unicast(Line,RoleID,Unique,Module,Method,TocRecord).

%% 买回物品
do_buy_back_goods({Unique, Module, Method, DataIn, RoleID, _Pid, Line, _State})->
    GoodsID =DataIn#m_shop_buy_back_tos.goods_id,
    case check_buy_back_goods(GoodsID,RoleID) of
        {error,Reason}->
            do_buy_back_goods_error({Unique, Module, Method, DataIn, RoleID, _Pid},{error,Reason});
        {ok,GoodsInfo}->
           case common_transaction:transaction(fun()-> t_buy_back_goods(RoleID,GoodsInfo) end) of
               {atomic,{NewSilverBind,NewSilver,NewGoodsList}}->
                   common_misc:new_goods_notify({line, Line, RoleID},NewGoodsList),
                   TocRecord = #m_shop_buy_back_toc{op_type=?BUY_BACK,
                                                    succ=true,
                                                    goods_id=GoodsID
                                                    },
                   common_misc:unicast(Line,RoleID,Unique,Module,Method,TocRecord),
                   ChangeMoneyToc = common_letter:get_change_money_toc(RoleID,NewSilverBind,NewSilver),
                   common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE,?ROLE2,?ROLE2_ATTR_CHANGE,ChangeMoneyToc);
               {aborted,Msg}->
                   ?ERROR_MSG("Msg ~w~n",[Msg]),
                   do_buy_back_goods_error({Unique, Module, Method, DataIn, RoleID, _Pid},Msg)
           end
    end.
     

%% 检查买回物品
check_buy_back_goods(GoodsID,RoleID)-> 
    case mod_map_role:get_role_map_ext_info(RoleID) of
        {error,not_found}->
            {error,?_LANG_SHOP_BUY_BACK_SYSTEM_ERROR};
         {ok,ExpInfo}->
            case lists:keyfind(GoodsID, 2, ExpInfo#r_role_map_ext.buy_back_goods) of
                GoodsInfo when erlang:is_record(GoodsInfo, p_goods)->
                    {ok,GoodsInfo};
                _Msg->{error,?_LANG_SHOP_BUY_BACK_NO_SUCH_GOODS}
            end
    end.
    
t_buy_back_goods(RoleID,GoodsInfo)->
    #p_goods{bind=Bind,sell_price=SellPrice,type=Type,current_num=Num}=GoodsInfo,
    NewSellPrize = 
        case Type of
            ?TYPE_EQUIP->get_goods_price(GoodsInfo)*Num;
            _->SellPrice*Num
        end,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    OldSilverBind = RoleAttr#p_role_attr.silver_bind,
    OldSilver = RoleAttr#p_role_attr.silver,
    %% 绑定的物品可以用不绑定银买，不绑物品必须用不绑银买，绑定属性不变
    {SilverBind,Silver}=
    case Bind of
        true-> 
            {SilverCut,NewSilverBind} = 
                if OldSilverBind < NewSellPrize ->
                       {NewSellPrize-OldSilverBind,0};
                   true->
                       {0,OldSilverBind-NewSellPrize}
                end,
            {RestCut,NewSilver}=
                if OldSilver<SilverCut ->
                       {SilverCut-OldSilver,0};
                   true->
                       {0,OldSilver-SilverCut}
                end,   
            case RestCut>0 of 
                true->common_transaction:abort({error,?_LANG_SHOP_BUY_BACK_NOT_ENOUGH_SILVER});
                false->{NewSilverBind,NewSilver}
            end;    
        false->
            case OldSilver< NewSellPrize of
                true->common_transaction:abort({error,?_LANG_SHOP_BUY_BACK_NOT_ENOUGH_UNBIND_SILVER});
                false->{OldSilverBind,OldSilver-NewSellPrize}
            end
    end,
    
    {ok,ExpInfo}=mod_map_role:get_role_map_ext_info(RoleID),
    NewGoodsInfo=lists:delete(GoodsInfo, ExpInfo#r_role_map_ext.buy_back_goods),
    mod_map_role:t_set_role_map_ext_info(RoleID, ExpInfo#r_role_map_ext{buy_back_goods=NewGoodsInfo}),
    NewRoleAttr = RoleAttr#p_role_attr{silver=Silver,silver_bind = SilverBind},
    mod_map_role:set_role_attr(RoleID,NewRoleAttr),
    common_consume_logger:use_silver({RoleID, OldSilverBind-SilverBind, OldSilver-Silver,
                                      ?CONSUME_TYPE_SILVER_BUY_BACK,
                                      ""}),
    {ok,GoodsList2} = mod_bag:create_goods_by_p_goods(RoleID,GoodsInfo),
    {SilverBind,Silver,GoodsList2}.

do_buy_back_goods_error({Unique, Module, Method, DataRecord, _RoleId, PId},Error)->
    Reason = 
        case Error of
            {error,_Reason}->_Reason;
            {bag_error,not_enough_pos}->?_LANG_SHOP_BUY_BACK_NOT_ENOUTH_POS;
            _ ->?_LANG_SHOP_BUY_BACK_SYSTEM_ERROR
                end,
    TocRecord = #m_shop_buy_back_toc{op_type=DataRecord#m_shop_buy_back_tos.op_type,
                                     succ= false,
                                     reason=Reason
                                     },
    common_misc:unicast2(PId, Unique, Module, Method, TocRecord).

    