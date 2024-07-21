%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2011, 
%%% @doc
%%% 玩家礼包模块
%%% @end
%%% Created : 20 Apr 2011 by  <caochuncheng2002@gmail.com>
%%%-------------------------------------------------------------------
-module(mod_gift).

%% INCLUDE
-include("mgeem.hrl").
-include("gift.hrl").
-include("equip.hrl").

%% API
-export([
         handle/1,
         do_handle_info/1,
         hook_category_change/3,
         get_p_goods_by_item_gift_base_record/1
        ]).

%%%===================================================================
%%% API
%%%===================================================================

handle(Info) ->
    do_handle_info(Info).

%% 道具礼包查询
do_handle_info({Unique, ?GIFT, ?GIFT_ITEM_QUERY, DataRecord, RoleId, PId, _Line}) ->
    do_gift_item_query({Unique, ?GIFT, ?GIFT_ITEM_QUERY, DataRecord, RoleId, PId});
%% 道具礼包领奖
do_handle_info({Unique, ?GIFT, ?GIFT_ITEM_AWARD, DataRecord, RoleId, PId, _Line}) ->
    do_gift_item_award({Unique, ?GIFT, ?GIFT_ITEM_AWARD, DataRecord, RoleId, PId});


do_handle_info(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["礼包模块无法处理此消息",Info]),
    error.
%%%===================================================================
%%% Internal functions
%%%===================================================================
%% 道具礼包查询
do_gift_item_query({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_gift_item_query2(RoleId) of
        {ok,gift_created,RoleGiftInfoRecord} ->
            SendSelf = #m_gift_item_query_toc{
              succ = true,
              cur_goods = RoleGiftInfoRecord#r_role_gift_info.cur_gift,
              award_role_level = (RoleGiftInfoRecord#r_role_gift_info.expand_field)#r_item_gift_base.role_level},
            ?DEBUG("~ts,SendSelf=~w",["查询道具礼包返回结果",SendSelf]),
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf);
        {ok,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList} ->
            do_gift_item_query3({Unique, Module, Method, DataRecord, RoleId, PId},
                                RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList);
        {error, Reason, ReasonCode} ->
            do_gift_item_query_error({Unique, Module, Method, DataRecord, PId},Reason,ReasonCode)
    end.
do_gift_item_query2(RoleId) ->
    _RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_GIFT_ITEM_QUERY_ERROR,0});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    {ok,#p_role_attr{category = CategoryT}} = mod_map_role:get_role_attr(RoleId),
    Category =   if CategoryT =:= 0 -> 1; true -> CategoryT end,
    ItemGiftBaseList = 
        case common_config_dyn:find(?GIFT_ITEM_CONFIG,item_gift_base) of
            [] ->
                erlang:throw({error,?_LANG_GIFT_ITEM_QUERY_GIFT_NOT_CONFIG,0});
            [ItemGiftBaseListT] ->
                ItemGiftBaseListT2 = [ItemGiftBaseRecordT || ItemGiftBaseRecordT <- ItemGiftBaseListT,
                                         ItemGiftBaseRecordT#r_item_gift_base.category =:= Category],
                lists:sort(fun(#r_item_gift_base{role_level = RoleLevelA},#r_item_gift_base{role_level = RoleLevelB}) ->
                                   RoleLevelA < RoleLevelB
                           end,ItemGiftBaseListT2)
        end,
    if ItemGiftBaseList =:= [] ->
            erlang:throw({error,?_LANG_GIFT_ITEM_QUERY_GIFT_NOT_CONFIG,0});
       true ->
            next
    end,
    {RoleGiftRecord,RoleGiftInfoRecord}= 
        case db:dirty_read(?DB_ROLE_GIFT,RoleId) of
            [] ->
                {undefined,#r_role_gift_info{gift_type = ?GIFT_TYPE_ITEM,status =?GIFT_ITEM_STATUS_INIT}};
            [RoleGiftRecordT] ->
                case lists:keyfind(?GIFT_TYPE_ITEM,#r_role_gift_info.gift_type,RoleGiftRecordT#r_role_gift.gifts) of
                    false ->
                        {RoleGiftRecordT,#r_role_gift_info{gift_type = ?GIFT_TYPE_ITEM,status =?GIFT_ITEM_STATUS_INIT}};
                    RoleGiftInfoRecordT ->
                        {RoleGiftRecordT,RoleGiftInfoRecordT}
                end
        end,
    ItemGiftBase = 
        if RoleGiftInfoRecord#r_role_gift_info.status =:= ?GIFT_ITEM_STATUS_INIT ->
                lists:nth(1,ItemGiftBaseList);
           true ->
                MaxRoleLevelItemGift = lists:nth(erlang:length(ItemGiftBaseList),ItemGiftBaseList),
                case ((((RoleGiftInfoRecord#r_role_gift_info.expand_field)#r_item_gift_base.id div 10) =:= (MaxRoleLevelItemGift#r_item_gift_base.id div 10)
                       orelse (RoleGiftInfoRecord#r_role_gift_info.expand_field)#r_item_gift_base.role_level 
                       >= MaxRoleLevelItemGift#r_item_gift_base.role_level )
                      andalso RoleGiftInfoRecord#r_role_gift_info.status =:= ?GIFT_ITEM_STATUS_AWARD) of
                    true ->
                        erlang:throw({error,?_LANG_GIFT_ITEM_QUERY_NOT_GIFT,0});
                    false ->
                        erlang:throw({ok,gift_created,RoleGiftInfoRecord})
                end
        end,
    if ItemGiftBase#r_item_gift_base.item_type =:= ?TYPE_EQUIP 
       orelse ItemGiftBase#r_item_gift_base.item_type =:= ?TYPE_STONE 
       orelse ItemGiftBase#r_item_gift_base.item_type =:= ?TYPE_ITEM ->
            next;
       true ->
            erlang:throw({error,?_LANG_GIFT_ITEM_QUERY_GIFT_CONFIG_ERROR,0})
    end,
    %% 返回 {ok,GoodsList} or {error,Reason}
    GoodsList = 
        case get_p_goods_by_item_gift_base_record(ItemGiftBase) of
            {ok,GoodsListT} ->
                GoodsListT;
            {error,GoodsError} ->
                ?DEBUG("~ts,GoodsError=~w",["生成道具p_goods出错",GoodsError]),
                erlang:throw({error,?_LANG_GIFT_ITEM_QUERY_GIFT_CONFIG_ERROR,0})
        end,
    GoodsList2 = [Goods#p_goods{id = ?GIFT_ITEM_GOODS_ID,roleid = RoleId,bagid = 0,bagposition = 0}|| Goods <- GoodsList],
    {ok,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList2}.

do_gift_item_query3({Unique, Module, Method, DataRecord, RoleId, PId},
                    RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList) ->
    if RoleGiftInfoRecord#r_role_gift_info.status =:= ?GIFT_ITEM_STATUS_INIT ->
            %%第一次创建道具礼包
            case db:transaction(
                   fun() -> 
                           do_t_gift_item_query(RoleId,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList)
                   end) of
                {atomic,{ok,RoleGiftRecord2,RoleGiftInfoRecord2}} ->
                    do_gift_item_query4({Unique, Module, Method, DataRecord, RoleId, PId},
                                        RoleGiftRecord2,RoleGiftInfoRecord2,ItemGiftBase,GoodsList);
                {aborted, Error} ->
                    case Error of
                        {Reason, ReasonCode} ->
                            do_gift_item_query_error({Unique, Module, Method, DataRecord, PId},Reason,ReasonCode);
                        _ ->
                            ?ERROR_MSG("~ts,RoleId=~w,Error=~w",["查询道具礼包出错",RoleId,Error]),
                            Reason2 = ?_LANG_GIFT_ITEM_QUERY_ERROR,
                            do_gift_item_query_error({Unique, Module, Method, DataRecord, PId},Reason2,0)
                    end
            end;
       true ->
            ?DEBUG("~ts,RoleId=~w,RoleGiftInfoRecord=~w",["这里只处理第一次创建道具礼包操作",RoleId,RoleGiftInfoRecord]),
            Reason = ?_LANG_GIFT_ITEM_QUERY_ERROR,
            ReasonCode = 0,
            do_gift_item_query_error({Unique, Module, Method, DataRecord, PId},Reason,ReasonCode)
    end.
do_gift_item_query4({Unique, Module, Method, _DataRecord, _RoleId, PId},
                    _RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,_GoodsList) ->
    SendSelf = #m_gift_item_query_toc{
      succ = true,
      cur_goods = RoleGiftInfoRecord#r_role_gift_info.cur_gift,
      award_role_level = ItemGiftBase#r_item_gift_base.role_level},
    ?DEBUG("~ts,SendSelf=~w",["查询道具礼包返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

do_gift_item_query_error({Unique, Module, Method, _DataRecord, PId},Reason,ReasonCode) ->
    SendSelf = #m_gift_item_query_toc{
      succ = false,
      reason = Reason,
      reason_code = ReasonCode},
    ?DEBUG("~ts,SendSelf=~w",["查询道具礼包返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).
do_t_gift_item_query(RoleId,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList) ->
    RoleGiftInfoRecord2 = RoleGiftInfoRecord#r_role_gift_info{cur_gift = GoodsList,expand_field = ItemGiftBase},
    RoleGiftRecord2 = 
        case RoleGiftRecord of
            undefined ->
                #r_role_gift{role_id = RoleId,gifts = [RoleGiftInfoRecord2]};
            _ ->
                GiftsList = lists:keydelete(?GIFT_TYPE_ITEM,#r_role_gift_info.gift_type,RoleGiftRecord#r_role_gift.gifts),
                RoleGiftRecord#r_role_gift{gifts = [RoleGiftInfoRecord2|GiftsList]}
        end,
    db:write(?DB_ROLE_GIFT,RoleGiftRecord2,write),
    {ok,RoleGiftRecord2,RoleGiftInfoRecord2}.
%% 道具礼包领奖
do_gift_item_award({Unique, Module, Method, DataRecord, RoleId, PId}) ->
    case catch do_gift_item_award2(RoleId) of
        {error, Reason, ReasonCode} ->
            do_gift_item_award_error({Unique, Module, Method, DataRecord, PId},Reason,ReasonCode);
        {ok,RoleMapInfo,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList} ->
            do_gift_item_award3({Unique, Module, Method, DataRecord, RoleId, PId},
                                RoleMapInfo,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList)
    end.

do_gift_item_award2(RoleId) ->
    RoleMapInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_GIFT_ITEM_AWARD_ERROR,0});
            RoleMapInfoT ->
                RoleMapInfoT
        end,
    {ok,#p_role_attr{category = CategoryT}} = mod_map_role:get_role_attr(RoleId),
    Category =   if CategoryT =:= 0 -> 1; true -> CategoryT end,
    ItemGiftBaseList = 
        case common_config_dyn:find(?GIFT_ITEM_CONFIG,item_gift_base) of
            [] ->
                erlang:throw({error,?_LANG_GIFT_ITEM_QUERY_GIFT_NOT_CONFIG,0});
            [ItemGiftBaseListT] ->
                ItemGiftBaseListT2 = [ItemGiftBaseRecordT|| ItemGiftBaseRecordT <- ItemGiftBaseListT,
                                         ItemGiftBaseRecordT#r_item_gift_base.category =:= Category],
                lists:sort(fun(#r_item_gift_base{role_level = RoleLevelA},#r_item_gift_base{role_level = RoleLevelB}) ->
                                   RoleLevelA < RoleLevelB
                           end,ItemGiftBaseListT2)
        end,
    if ItemGiftBaseList =:= [] ->
            erlang:throw({error,?_LANG_GIFT_ITEM_QUERY_GIFT_NOT_CONFIG,0});
       true ->
            next
    end,
    {RoleGiftRecord,RoleGiftInfoRecord}= 
        case db:dirty_read(?DB_ROLE_GIFT,RoleId) of
            [] ->
                erlang:throw({error,?_LANG_GIFT_ITEM_AWARD_NOT_GIFT,0});
            [RoleGiftRecordT] ->
                case lists:keyfind(?GIFT_TYPE_ITEM,#r_role_gift_info.gift_type,RoleGiftRecordT#r_role_gift.gifts) of
                    false ->
                        erlang:throw({error,?_LANG_GIFT_ITEM_AWARD_NOT_GIFT,0});
                    RoleGiftInfoRecordT ->
                        {RoleGiftRecordT,RoleGiftInfoRecordT}
                end
        end,
    if RoleGiftInfoRecord#r_role_gift_info.status =:= ?GIFT_ITEM_STATUS_AWARD ->
            erlang:throw({error,?_LANG_GIFT_ITEM_AWARD_DONE_GET,0});
       true ->
            next
    end,
    AwardRoleLevel = (RoleGiftInfoRecord#r_role_gift_info.expand_field)#r_item_gift_base.role_level,
    if RoleMapInfo#p_map_role.level >= AwardRoleLevel ->
            next;
       true ->
            erlang:throw({error,common_tool:get_format_lang_resources(?_LANG_GIFT_ITEM_AWARD_AWARD_ROLE_LEVEL,[AwardRoleLevel]),0})
    end,
    ItemGiftBaseId = (RoleGiftInfoRecord#r_role_gift_info.expand_field)#r_item_gift_base.id,
    ItemGiftBaseRoleLevel = (RoleGiftInfoRecord#r_role_gift_info.expand_field)#r_item_gift_base.role_level,
    {_,ItemGiftBaseIndex} = 
        lists:foldl(
          fun(ItemGiftBaseRecordTT,{AccIndexFlag,AccIndex}) ->
                  case (AccIndexFlag =:= false 
                        andalso (ItemGiftBaseRecordTT#r_item_gift_base.id =:= ItemGiftBaseId
                                 orelse ItemGiftBaseRecordTT#r_item_gift_base.role_level >= ItemGiftBaseRoleLevel)) of
                      true ->
                          {true,AccIndex + 1};
                      false ->
                          if AccIndexFlag =:= false ->
                                  {AccIndexFlag,AccIndex + 1};
                             true ->
                                  {AccIndexFlag,AccIndex}
                          end
                  end
          end,{false,0},ItemGiftBaseList),
    ItemGiftBase = 
        case (ItemGiftBaseIndex =/= 0 andalso (ItemGiftBaseIndex + 1) =< erlang:length(ItemGiftBaseList)) of
            true ->
                lists:nth(ItemGiftBaseIndex + 1,ItemGiftBaseList);
            false ->
                undefined
        end,
    GoodsList = 
        if ItemGiftBase =/= undefined ->
                case get_p_goods_by_item_gift_base_record(ItemGiftBase) of
                    {ok,GoodsListT} ->
                        [Goods#p_goods{id= ?GIFT_ITEM_GOODS_ID,roleid = RoleId,bagid = 0,bagposition = 0}|| Goods <- GoodsListT];
                    {error,GoodsError} ->
                        ?DEBUG("~ts,GoodsError=~w",["生成下一次的道具p_goods出错",GoodsError]),
                        erlang:throw({error,?_LANG_GIFT_ITEM_QUERY_GIFT_CONFIG_ERROR,0})
                end;
           true ->
                undefined
        end,
    {ok,RoleMapInfo,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList}.

do_gift_item_award3({Unique, Module, Method, DataRecord, RoleId, PId},
                    RoleMapInfo,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList) ->
    case db:transaction(
           fun() -> 
                   do_t_gift_item_award(RoleId,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList)
           end) of
        {atomic,{ok,RoleGiftRecord2,RoleGiftInfoRecord2,AwardGoodsList,AwardItemGiftBase}} ->
            do_gift_item_award4({Unique, Module, Method, DataRecord, RoleId, PId},
                                RoleMapInfo,RoleGiftRecord2,RoleGiftInfoRecord2,AwardGoodsList,AwardItemGiftBase);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_gift_item_award_error({Unique, Module, Method, DataRecord, PId},?_LANG_GIFT_ITEM_AWARD_NOT_BAG_POS,0);
                {Reason, ReasonCode} ->
                    do_gift_item_award_error({Unique, Module, Method, DataRecord, PId},Reason,ReasonCode);
                _ ->
                    ?ERROR_MSG("~ts,RoleId=~w,Error=~w",["领取道具礼包出错",RoleId,Error]),
                    Reason2 = ?_LANG_GIFT_ITEM_AWARD_ERROR,
                    do_gift_item_award_error({Unique, Module, Method, DataRecord, PId},Reason2,0)
            end
    end.
do_gift_item_award4({Unique, Module, Method, _DataRecord, RoleId, PId},
                    _RoleMapInfo,_RoleGiftRecord,RoleGiftInfoRecord,AwardGoodsList,AwardItemGiftBase) ->
    SendSelf = 
        if RoleGiftInfoRecord#r_role_gift_info.status =:= ?GIFT_ITEM_STATUS_CREATE ->
                #m_gift_item_award_toc{succ = true,
                                       award_goods = AwardGoodsList,
                                       next_goods= RoleGiftInfoRecord#r_role_gift_info.cur_gift,
                                       award_role_level = (RoleGiftInfoRecord#r_role_gift_info.expand_field)#r_item_gift_base.role_level};
           true ->
                #m_gift_item_award_toc{succ = true,award_goods = AwardGoodsList, next_goods = []}
        end,
    ?DEBUG("~ts,SendSelf=~w",["领取奖励道具礼包返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    %% 记录道具奖励日志
    if AwardGoodsList =/= [] ->    
            Line = common_role_line_map:get_role_line(RoleId),
            UnicastArg = {line, Line, RoleId},
            [HGoods|_T] = AwardGoodsList,
            catch common_item_logger:log(RoleId,HGoods#p_goods{current_num = AwardItemGiftBase#r_item_gift_base.item_number},?LOG_ITEM_TYPE_GIFT_ITEM_AWARD),
            catch common_misc:update_goods_notify(UnicastArg,AwardGoodsList),
            NGoodsName = common_goods:get_notify_goods_name(HGoods#p_goods{current_num = AwardItemGiftBase#r_item_gift_base.item_number}),
            catch common_broadcast:bc_send_msg_role(
                    RoleId,?BC_MSG_TYPE_SYSTEM,
                    common_tool:get_format_lang_resources(?_LANG_GIFT_ITEM_AWARD_BC_MONSTER_GOODS,[NGoodsName]));
       true ->
            ignore
    end.
do_gift_item_award_error({Unique, Module, Method, _DataRecord, PId},Reason,ReasonCode) ->
    SendSelf = #m_gift_item_award_toc{
      succ = false,
      reason = Reason,
      reason_code = ReasonCode},
    ?DEBUG("~ts,SendSelf=~w",["领取奖励道具礼包返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

do_t_gift_item_award(RoleId,RoleGiftRecord,RoleGiftInfoRecord,NewItemGiftBaseRecord,NewGoodsList) ->
    #r_role_gift_info{cur_gift = CurGoodsList,expand_field = ItemGiftBaseRecord} = RoleGiftInfoRecord,
    {ok,AwardGoodsList} = mod_bag:create_goods_by_p_goods(RoleId,CurGoodsList),
    RoleGiftInfoRecord2 = 
        case NewItemGiftBaseRecord of
            undefined ->
                RoleGiftInfoRecord#r_role_gift_info{status = ?GIFT_ITEM_STATUS_AWARD};
            _ ->
                RoleGiftInfoRecord#r_role_gift_info{
                  status = ?GIFT_ITEM_STATUS_CREATE,
                  cur_gift = NewGoodsList,
                  expand_field = NewItemGiftBaseRecord}
        end,
    Gifts = lists:keydelete(RoleGiftInfoRecord2#r_role_gift_info.gift_type,#r_role_gift_info.gift_type,RoleGiftRecord#r_role_gift.gifts),
    RoleGiftRecord2 = RoleGiftRecord#r_role_gift{gifts = [RoleGiftInfoRecord2|Gifts]},
    db:write(?DB_ROLE_GIFT,RoleGiftRecord2,write),
    {ok,RoleGiftRecord2,RoleGiftInfoRecord2,AwardGoodsList,ItemGiftBaseRecord}.




%% 根据道具礼包配置生成p_goods
%% ItemGiftBase 结构 r_item_gift_base
%% 返回 {ok,GoodsList} or {error,Reason}
get_p_goods_by_item_gift_base_record(ItemGiftBase) ->
    #r_item_gift_base{item_type = ItemType,item_id = ItemId,item_number = ItemNumber,
                      bind = ItemBind,
                      start_time = PStartTime,end_time = PEndTime,days = PDays,
                      color = ColorList,quality = QualityList,sub_quality = SubQualityList,
                      punch_num = PunchNum,
                      reinforce = ReinforceList} = ItemGiftBase,
    Bind = if ItemBind =:= 0 ->
                   false;
              ItemBind =:= 100 ->
                   true;
              true ->
                   RandomNumber = random:uniform(100),
                   if ItemBind >= RandomNumber ->
                           true;
                      true ->
                           false
                   end
           end,
    NowSeconds = common_tool:now(),
    {StartTime,EndTime} = 
        if PStartTime =:= 0 andalso PEndTime =:= 0 andalso PDays =/= 0 ->
                {NowSeconds - 5, NowSeconds + 24*60*60 * PDays};
           PStartTime =/= 0 andalso PEndTime =/= 0 andalso PDays =:= 0 ->
                {PStartTime,PEndTime};
           PStartTime =:= 0 andalso PEndTime =/= 0 andalso PDays =:= 0 ->
                {NowSeconds - 5,PEndTime};
           true ->
                {0,0}
        end,
    CreateInfo =
        if ItemType =:= ?TYPE_EQUIP ->
                [EquipBaseInfo] = common_config_dyn:find_equip(ItemId),
                case EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT of
                    true ->
                        Color = 1,Quality = 0,SubQuality = 0;
                    _ ->
                        Color = mod_refining:get_random_number(ColorList,0,1),
                        Quality = mod_refining:get_random_number(QualityList,0,1),
                        SubQuality = mod_refining:get_random_number(SubQualityList,0,1)
                end,
                if ReinforceList =:= [] ->
                        ReinforceResult = 0,
                        ReinforceRate = 0;
                   true ->
                        ReinforceResult = lists:max(ReinforceList),
                        ReinforceLevel = ReinforceResult div 10,
                        ReinforceGrade = ReinforceResult rem 10,
                        [ReinforceRateList] = common_config_dyn:find(refining,reinforce_rate),
                        {_,ReinforceRate} = lists:keyfind({ReinforceLevel,ReinforceGrade},1,ReinforceRateList)
                end,
                #r_equip_create_info{num=ItemNumber,typeid = ItemId,bind=Bind,start_time = StartTime,
                                     end_time = EndTime,color=Color,quality=Quality,sub_quality = SubQuality,
                                     punch_num=PunchNum,rate=ReinforceRate,result=ReinforceResult,result_list=ReinforceList};
           ItemType =:= ?TYPE_STONE ->
                #r_stone_create_info{num=ItemNumber,typeid = ItemId,bind=Bind,start_time = StartTime,end_time = EndTime};
           true ->
                Color = mod_refining:get_random_number(ColorList,0,1),
                #r_item_create_info{num = ItemNumber,typeid = ItemId,bind=Bind,start_time = StartTime,end_time = EndTime, color=Color}
        end,
    ?DEBUG("~ts,CreateInfo=~w",["创建奖励道具",CreateInfo]),
    if ItemType =:= ?TYPE_EQUIP ->
            ?DEBUG("~w",[common_bag2:creat_equip_without_expand(CreateInfo)]),
            case common_bag2:creat_equip_without_expand(CreateInfo) of
                {ok,EquipGoodsList} ->
                    [EquipBaseInfo2] = common_config_dyn:find_equip(ItemId),
                    case EquipBaseInfo2#p_equip_base_info.slot_num =:= ?PUT_MOUNT
                        orelse EquipBaseInfo2#p_equip_base_info.slot_num =:= ?PUT_FASHION of
                        true ->
                            {ok,EquipGoodsList};
                        _ ->
                            get_p_goods_by_item_gift_base_record2(ItemGiftBase,EquipGoodsList)
                    end;
                {error,EquipError} ->
                    {error,EquipError}
            end;
       ItemType =:= ?TYPE_STONE ->
            common_bag2:creat_stone(CreateInfo);
       ItemType =:= ?TYPE_ITEM ->
            common_bag2:create_item(CreateInfo);
        true ->
            {error,item_type_error}
    end.
%% AddAttrList 结构为装备绑定属性的[{code,level},...]
get_p_goods_by_item_gift_base_record2(ItemGiftBase,EquipGoodsList) ->
    #r_item_gift_base{item_id = ItemId,add_attr = AddAttrList} = ItemGiftBase,
    [EquipBaseInfo] = common_config_dyn:find_equip(ItemId),
    EquipGoodsList2 = 
        lists:map(
          fun(Goods) ->
                  %% 颜色品质处理
                  Goods2 = mod_refining:equip_colour_quality_add(new,Goods,1,1,1),
                  %% 强化处理
                  Goods3 = mod_equip_change:equip_reinforce_property_add(Goods2,EquipBaseInfo),
                  %% 绑定属性
                  Goods4 = mod_refining_bind:do_equip_bind_for_item_gift(Goods3,EquipBaseInfo,AddAttrList),
                  %% 精炼系数处理
                  Goods5 = 
                      case common_misc:do_calculate_equip_refining_index(Goods4) of
                          {ok,Goods4T} ->
                              Goods4T;
                          {error,_RefiningIndexError} ->
                              Goods4
                      end,
                  Goods5#p_goods{stones = []}
          end,EquipGoodsList),
    {ok,EquipGoodsList2}.

%% 玩家职业信息需要重新更新道具奖励
hook_category_change(RoleId,RoleLevel,Category) ->
    {RoleGiftRecord,RoleGiftInfoRecord}= 
        case db:dirty_read(?DB_ROLE_GIFT,RoleId) of
            [] ->
                {undefined,undefined};
            [RoleGiftRecordT] ->
                case lists:keyfind(?GIFT_TYPE_ITEM,#r_role_gift_info.gift_type,RoleGiftRecordT#r_role_gift.gifts) of
                    false ->
                        {RoleGiftRecordT,undefined};
                    RoleGiftInfoRecordT ->
                        {RoleGiftRecordT,RoleGiftInfoRecordT}
                end
        end,
    case (RoleGiftRecord =:= undefined orelse RoleGiftInfoRecord =:= undefined) of
        true ->
            ignore;
        false ->
            GiftCategory = (RoleGiftInfoRecord#r_role_gift_info.expand_field)#r_item_gift_base.category,
            RoleCategory = if Category =:= 0 -> 1; true -> Category end,
            case  (GiftCategory =:= RoleCategory 
                   orelse RoleGiftInfoRecord#r_role_gift_info.status =:= ?GIFT_ITEM_STATUS_AWARD) of
                true ->
                    ignore;
                false ->
                    hook_category_change2(RoleId,RoleLevel,RoleCategory,GiftCategory,RoleGiftRecord,RoleGiftInfoRecord)
            end
    end.
hook_category_change2(RoleId,_RoleLevel,NewCategory,OldCategory,RoleGiftRecord,RoleGiftInfoRecord) ->
    [AllItemGiftBaseList] = common_config_dyn:find(?GIFT_ITEM_CONFIG,item_gift_base),
    OldItemGiftBaseListT = [OldItemGiftBaseRecord
                           || OldItemGiftBaseRecord <- AllItemGiftBaseList,
                              OldItemGiftBaseRecord#r_item_gift_base.category =:= OldCategory],
    OldItemGiftBaseList = 
        lists:sort(fun(#r_item_gift_base{role_level = OldRoleLevelA},#r_item_gift_base{role_level = OldRoleLevelB}) ->
                           OldRoleLevelA < OldRoleLevelB
                   end,OldItemGiftBaseListT),
    NewItemGiftBaseListT = [NewItemGiftBaseRecord
                            || NewItemGiftBaseRecord <- AllItemGiftBaseList,
                               NewItemGiftBaseRecord#r_item_gift_base.category =:= NewCategory],
    NewItemGiftBaseList = 
        lists:sort(fun(#r_item_gift_base{role_level = NewRoleLevelA},#r_item_gift_base{role_level = NewRoleLevelB}) ->
                           NewRoleLevelA < NewRoleLevelB
                   end,NewItemGiftBaseListT),
    OldItemGiftBaseId = (RoleGiftInfoRecord#r_role_gift_info.expand_field)#r_item_gift_base.id,
    {_,OldItemGiftBaseIndex} = 
        lists:foldl(
          fun(OldItemGiftBaseRecordT,{AccOldIndexFlag,AccOldIndex}) ->
                  case (AccOldIndexFlag =:= false andalso OldItemGiftBaseRecordT#r_item_gift_base.id =:= OldItemGiftBaseId) of
                      true ->
                          {true,AccOldIndex + 1};
                      false ->
                          if AccOldIndexFlag =:= false ->
                                  {AccOldIndexFlag,AccOldIndex + 1};
                             true ->
                                  {AccOldIndexFlag,AccOldIndex}
                          end
                  end
          end,{false,0},OldItemGiftBaseList),
    NewItemGiftBase = 
        case (OldItemGiftBaseIndex =/= 0 andalso OldItemGiftBaseIndex =< erlang:length(NewItemGiftBaseList)) of
            true ->
                lists:nth(OldItemGiftBaseIndex,NewItemGiftBaseList);
            false ->
                undefined
        end,
    case NewItemGiftBase of
        undefined ->
            ignore;
        _ ->
            case get_p_goods_by_item_gift_base_record(NewItemGiftBase) of
                {ok,GoodsListT} ->
                    NewGoodsList = [Goods#p_goods{id = ?GIFT_ITEM_GOODS_ID,roleid = RoleId,bagid = 0,bagposition = 0}|| Goods <- GoodsListT],
                    RoleGiftInfoRecord2 = RoleGiftInfoRecord#r_role_gift_info{gift_type = ?GIFT_TYPE_ITEM,status =?GIFT_ITEM_STATUS_INIT},
                    hook_category_change3(RoleId,RoleGiftRecord,RoleGiftInfoRecord2,NewItemGiftBase,NewGoodsList);
                {error,GoodsError} ->
                    ?DEBUG("~ts,GoodsError=~w",["玩家职业改变时生成道具奖励p_goods出错",GoodsError]),
                    ignore
            end
    end.
hook_category_change3(RoleId,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList) ->
    case db:transaction(
           fun() -> 
                   do_t_gift_item_query(RoleId,RoleGiftRecord,RoleGiftInfoRecord,ItemGiftBase,GoodsList)
           end) of
        {atomic,{ok,_RoleGiftRecord2,RoleGiftInfoRecord2}} ->
            SendSelf = #m_gift_item_query_toc{
              succ = true,
              cur_goods = RoleGiftInfoRecord2#r_role_gift_info.cur_gift,
              award_role_level = ItemGiftBase#r_item_gift_base.role_level},
            ?DEBUG("~ts,SendSelf=~w",["玩家职业改变时生成新的道具返回结果",SendSelf]),
            common_misc:unicast(common_role_line_map:get_role_line(RoleId), 
                                RoleId, ?DEFAULT_UNIQUE, ?GIFT, ?GIFT_ITEM_QUERY,SendSelf);
        {aborted, Error} ->
            ?ERROR_MSG("~ts,RoleId=~w,Error=~w",["玩家职业改变时生成道具奖励,生成新的道具礼包出错",RoleId,Error])
    end.
