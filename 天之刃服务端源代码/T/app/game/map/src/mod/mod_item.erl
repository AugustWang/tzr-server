%% Author: liuwei
%% Created: 2010-4-12
%% Description: TODO: Add description to mod_item
-module(mod_item).

-include("mgeem.hrl").

-export([init/1,
         loop/2]).
-export([handle/1,
         create_item/1,
         get_item_baseinfo/1,
         check_item_use_log/0,
         add_role_drunk_count/1,
         get_role_drunk_count/1,
         put_role_drunk_count/2,
         stop_use_special_item/1
         ]).

-define(SEND_SYMBOL,10100001).
-define(BACK_SYMBOL,10100005).
-define(RANDOM_SYMBOL,10100006).

-define(CAN_OVERLAP,1).
-define(NOT_OVERLAP,2).
-define(USED_ITEM_LIST,used_item_list).
-define(USED_ITEM_LIST_LAST_TIME,used_item_list_last_time).

init(MapId) ->
    init_use_special_item_list(MapId),
    ok.
loop(MapId,NowSeconds) ->
    loop_do_use_special_item(MapId,NowSeconds),
    ok.

handle({Unique, Module, ?ITEM_USE, DataIn, RoleID, PID, _Line, State}) ->
    %% 道具使用hook
    hook_map_role:use_item(RoleID),
    do_use(Unique, Module, ?ITEM_USE, DataIn, RoleID, PID, State);
handle({Unique, Module, ?ITEM_USE_SPECIAL, DataIn, RoleID, PID, _Line, _State}) ->
    hook_map_role:use_item(RoleID),
    do_use_special(Unique, Module, ?ITEM_USE_SPECIAL, DataIn, RoleID, PID);
handle({Unique, Module, ?ITEM_SHRINK_BAG, DataIn, RoleID, _PID, Line, _State}) ->
    do_shrink(Unique, Module, ?ITEM_SHRINK_BAG, DataIn, RoleID, Line);
handle({Unqiue, Module, ?ITEM_BATCH_SELL, DataIn, RoleID, PID, _Line, _State}) ->
    do_batch_sell(Unqiue, Module, ?ITEM_BATCH_SELL, DataIn, RoleID, PID);
handle({Unique, Module, ?ITEM_TRACE, DataIn, RoleID, PID, _Line, _State}) ->
    do_trace(Unique, Module, ?ITEM_TRACE, DataIn, RoleID, PID);

handle(Info) ->
    ?ERROR_MSG("~ts: ~s", ["道具模块接收到未知的消息：", Info]).

%% 批量卖出物品
do_batch_sell(Unique, Module, Method, DataIn, RoleID, PID) ->
    ItemList = DataIn#m_item_batch_sell_tos.id_list,
    case erlang:length(ItemList) > 0 of
        true ->
            case common_transaction:t(fun() -> t_do_batch_sell(ItemList, RoleID) end) of
                {atomic, {NewRoleAttr, Silver, BindSilver}} ->
                    ChangeList = [
                                  #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=NewRoleAttr#p_role_attr.silver},
                                  #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.silver_bind}],
                    common_misc:role_attr_change_notify({pid, PID}, RoleID, ChangeList),
                    common_misc:unicast2(PID, Unique, Module, Method, #m_item_batch_sell_toc{silver=Silver, bind_silver=BindSilver}),
                    ok;
                {aborted, Error} ->
                    case erlang:is_binary(Error) of
                        true ->
                            do_batch_sell_error(Unique, Module, Method, Error, PID);
                        false ->
                            ?ERROR_MSG("~ts:~w", ["处理批量卖出时发生系统错误", Error]),
                            do_batch_sell_error(Unique, Module, Method, ?_LANG_ITEM_SYSTEM_ERROR_WHEN_BATCH_SELL, PID)
                    end
            end,
            ok;
        false ->
            do_batch_sell_error(Unique, Module, Method, ?_LANG_ITEM_LIST_IS_EMPTY_WHEN_BATCH_SELL, PID)
    end.

t_do_batch_sell(ItemList, RoleID) ->
    {S, BS} = lists:foldl(
                fun(GoodsID, {Silver, BindSilver}) ->
                        case mod_bag:get_goods_by_id(RoleID,GoodsID) of
                            {error, goods_not_found} ->
                                erlang:throw({error, ?_LANG_ITEM_GOODS_NOT_EXIST});
                            {ok, GoodsInfo} ->
                                case GoodsInfo#p_goods.sell_type =:= 0 of
                                    true ->
                                        erlang:throw({error, ?_LANG_ITEM_CANNT_SELL});
                                    false ->
                                        case GoodsInfo#p_goods.type of
                                            ?TYPE_EQUIP ->
                                                Add = get_goods_price(GoodsInfo),
                                                case GoodsInfo#p_goods.bind of
                                                    true ->
                                                        {Silver, BindSilver + GoodsInfo#p_goods.current_num * Add};
                                                    false ->
                                                        {Silver + GoodsInfo#p_goods.current_num * Add, BindSilver}
                                                end;
                                            _ ->
                                                case GoodsInfo#p_goods.bind of
                                                    true ->
                                                        {Silver, BindSilver + GoodsInfo#p_goods.current_num * GoodsInfo#p_goods.sell_price};
                                                    false ->
                                                        {Silver + GoodsInfo#p_goods.current_num * GoodsInfo#p_goods.sell_price, BindSilver}
                                                end
                                        end
                                end
                        end
                end, {0, 0}, ItemList),       
    mod_bag:delete_goods(RoleID, ItemList),
    {ok, #p_role_attr{silver=OldS, silver_bind=OldSB} = RoleAttr} = mod_map_role:get_role_attr(RoleID),
    NewAttr = RoleAttr#p_role_attr{silver=OldS + S, silver_bind=OldSB + BS},
    mod_map_role:set_role_attr(RoleID, NewAttr),
    {NewAttr, S, BS}.

get_goods_price(Goods) ->
    #p_goods{sell_price=SellPrice,
             current_endurance=CE,
             endurance=ES,
             refining_index=RI}=Goods,  
    common_tool:ceil(SellPrice*RI*CE/ES/10).
              

do_batch_sell_error(Unique, Module, Method, Reason, PID) ->
    common_misc:unicast2(PID, Unique, Module, Method, #m_item_batch_sell_toc{succ=false, reason=Reason}).
    

%%道具使用流程
do_use(Unique, Module, Method, DataIn, RoleId, PId, MapState) ->
    case catch check_can_use_item(RoleId, DataIn) of
        {ok, ItemBaseInfo, ItemGoods, TransModule} ->
            do_use2(Unique, Module, Method, DataIn, RoleId, PId, MapState, ItemBaseInfo, ItemGoods, TransModule);
        {error, Reason} when is_binary(Reason) ->
            do_use_error(Unique, Module, Method, PId, Reason);
        {error, Reason} ->
            ?ERROR_MSG("use item error, reason: ~w", [Reason]),
            do_use_error(Unique, Module, Method, PId, ?_LANG_SYSTEM_ERROR)
    end.

do_use2(Unique, Module, Method, DataIn, RoleID, PId, MapState, ItemBaseInfo, ItemGoods, TransModule) ->
    #m_item_use_tos{usenum=UseNum, effect_id=EffectID} = DataIn,
    case TransModule:transaction(
           fun() ->
                   {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
                   {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
                   %%使用道具的功能
                   #r_item_effect_result{item_info=NewItemInfo, role_base=NewRoleBase, role_attr=NewRoleAttr,
                                         msg_list=MsgList, prompt_list=PromptList} 
                       = apply_item_effect(ItemGoods, ItemBaseInfo, RoleBase, RoleAttr, EffectID, UseNum, MapState, TransModule),
                   %%更新玩家信息
                   mod_map_role:set_role_base(RoleID, NewRoleBase),
                   mod_map_role:set_role_attr(RoleID, NewRoleAttr), 
                   DataToc = #m_item_use_toc{succ = true,itemid = ItemGoods#p_goods.id, 
                                             rest = NewItemInfo#p_goods.current_num,reason=PromptList},
                   {NewItemInfo, MsgList, DataToc}
           end)
        of
        {aborted, {bag_error,not_enough_pos}} ->
            do_use_error(Unique,Module,Method, PId,?_LANG_GOODS_BAG_NOT_ENOUGH);
        {aborted, Reason} when erlang:is_binary(Reason) ->
            do_use_error(Unique, Module, Method, PId, Reason);
        {aborted, Reason} ->
            ?ERROR_MSG("Reason:~w~n",[Reason]),
            do_use_error(Unique,Module,Method,PId,Reason);
        {atomic, {NewItemInfo,MsgList,Data}} ->
            %%事务成功后把事务中要发送到客户的信息发送，发送的顺序按添加的顺序发送
            send_use_item_msg(MsgList),
            %%道具使用log
            item_use_log(RoleID,ItemGoods,NewItemInfo),
            %%更新道具使用cd时间
            updata_use_cd_time(ItemBaseInfo,RoleID),
            common_misc:unicast2(PId, Unique, Module, Method, Data)
    end.
                   

%%使用道具时的错误处理
do_use_error(Unique, Module, Method, PId, Reason) ->
    DataRecord = #m_item_use_toc{succ=false, reason=[Reason]},
    common_misc:unicast2(PId, Unique, Module, Method, DataRecord).

init_use_special_item_list(MapId) ->
    erlang:put({use_special_item_list,MapId},[]).
get_role_use_special_item_dict(MapId,RoleId)->
    case lists:keyfind(RoleId,#r_item_special_dict.role_id,erlang:get({use_special_item_list,MapId})) of
        false ->
            undefined;
        ItemSpecialDict ->
            ItemSpecialDict
    end.
set_role_use_special_item_dict(MapId,ItemSpecialDict) ->
    ItemSpecialDictList = erlang:get({use_special_item_list,MapId}),
    case lists:keyfind(ItemSpecialDict#r_item_special_dict.role_id, #r_item_special_dict.role_id, ItemSpecialDictList) of
        false ->
            ItemSpecialDictList2 = [ItemSpecialDict|ItemSpecialDictList];
        _ ->
            ItemSpecialDictList2 =[ItemSpecialDict|
                                       lists:keydelete(ItemSpecialDict#r_item_special_dict.role_id, 
                                                       #r_item_special_dict.role_id, ItemSpecialDictList)]
    end,
    erlang:put({use_special_item_list,MapId},ItemSpecialDictList2).
erase_role_use_special_item_dict(MapId,RoleId) ->
    UseMissionItemList = erlang:get({use_special_item_list,MapId}),
    case lists:keyfind(RoleId, #r_item_special_dict.role_id, UseMissionItemList) of
        false ->
            ignore;
        _ ->
            erlang:put({use_special_item_list,MapId},lists:keydelete(RoleId,#r_item_special_dict.role_id, UseMissionItemList))
    end.

%%地图进程大循环处理读条任务处理
loop_do_use_special_item(MapId,NowSeconds) ->
    ItemSpecialDictList = erlang:get({use_special_item_list,MapId}),
    case ItemSpecialDictList =/= [] of
        true ->
            loop_do_use_special_item2(MapId,ItemSpecialDictList,NowSeconds);
        _ ->
            ignore
    end.
loop_do_use_special_item2(MapId,ItemSpecialDictList,NowSeconds) ->
    ItemSpecialDictList2 = 
        lists:foldl(
          fun(ItemSpecialDict,AccItemSpecialDictList) -> 
                  case NowSeconds > ItemSpecialDict#r_item_special_dict.end_time of
                      true ->
                          %% 读条完成，需要处理
                          do_use_special_item_complete(ItemSpecialDict),
                          AccItemSpecialDictList;
                      _ ->
                          [ItemSpecialDict|AccItemSpecialDictList]
                  end
          end, [], ItemSpecialDictList),
    erlang:put({use_special_item_list,MapId},ItemSpecialDictList2),
    ok.
%% 读条完成，需要处理
%% UseMissionItemDict 结构 r_item_special_dict 
do_use_special_item_complete(ItemSpecialDict) ->
    #r_item_special_dict{role_id = RoleId,item_id = UseItemId} = ItemSpecialDict,
    case catch do_use_special_item_complete2(ItemSpecialDict) of
        {error,Reason,ReasonCode} ->
            do_use_special_item_fail(RoleId,UseItemId,Reason,ReasonCode);
        {ok,UseGoods,UseItemPointInfo} ->
            do_use_special3(?DEFAULT_UNIQUE, ?ITEM, ?ITEM_USE_SPECIAL, 
                            #m_item_use_special_tos{item_id = UseItemId}, RoleId, undefined,UseGoods,UseItemPointInfo)
    end.
do_use_special_item_complete2(ItemSpecialDict) ->
    #r_item_special_dict{role_id = RoleId,
                         item_id = UseItemId,
                         new_type_id = PNewTypeId,
                         total_progress = PTotalProgress,
                         new_number = PNewNumber,
                         progress_desc = PProgressDesc} = ItemSpecialDict,
    UseGoods = 
        case mod_bag:check_inbag_by_typeid(RoleId, UseItemId) of
            {ok,UseGoodsList} ->
                [UseGoodsT|_TUseGoodsT] = UseGoodsList,
                UseGoodsT;
            _ ->
                erlang:throw({error,?_LANG_ITEM_SPECIAL_NOT_FIND,0})
        end,
    {ok,UseGoods,{PTotalProgress,PNewTypeId,PNewNumber,PProgressDesc}}.
%% 玩家其它操作打断读条使用道具
stop_use_special_item(RoleId) ->
    MapId = mgeem_map:get_mapid(),
    case get_role_use_special_item_dict(MapId,RoleId) of
        undefined ->
            ignore;
        ItemSpecialDict ->
            erase_role_use_special_item_dict(MapId,RoleId),
            Reason = common_tool:get_format_lang_resources(?_LANG_ITEM_SPECIAL_USE_FAIL, [ItemSpecialDict#r_item_special_dict.progress_desc]),
            do_use_special_item_fail(RoleId,ItemSpecialDict,Reason,0)
    end.
%% 打断读条使用道具通知
do_use_special_item_fail(RoleId,ItemSpecialDict,Reason,ReasonCode) ->
    erase_role_use_special_item_dict(mgeem_map:get_mapid(),RoleId),
    SendSelf = #m_item_use_special_toc{item_id = ItemSpecialDict#r_item_special_dict.item_id,
                                       succ = false,
                                       use_status = 3,
                                       use_effect = if ItemSpecialDict#r_item_special_dict.total_progress > 0 -> 2; true -> 1 end,
                                       reason = Reason,reason_code = ReasonCode},
    ?DEBUG("~ts,SendSelf=~w",["使用特殊道具失败返回",SendSelf]),
    common_misc:unicast({role,RoleId}, ?DEFAULT_UNIQUE, ?ITEM, ?ITEM_USE_SPECIAL, SendSelf).
%%使用特殊的道具 此类弄的道具一般为任务道具，并且道具是不可叠加的
%%读条使用道具，直接使用道具
%%使用道具效果，直接消失，产生新的id
do_use_special(Unique, Module, Method, DataRecord, RoleId, PId) ->
    case catch do_use_special2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_use_special_error(Unique,Module,Method,DataRecord,RoleId,PId,Reason,ReasonCode);
        {ok,use_start,ItemSpecialDict} ->
            do_use_special_start(Unique,Module,Method,DataRecord,RoleId,PId,ItemSpecialDict);
        {ok,UseGoods, UseItemPointInfo} ->
            do_use_special3(Unique, Module, Method, DataRecord, RoleId, PId,UseGoods,UseItemPointInfo)
    end.
do_use_special2(RoleId,DataRecord) ->
    #m_item_use_special_tos{item_id = UseItemId} = DataRecord,
    RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleId,role),
    %% 检查玩家当前状态是否可以使用道具
    %%强制玩家下马
    mod_equip_mount:force_mountdown(RoleId),
    case RoleMapInfo#p_map_role.state of
        ?ROLE_STATE_NORMAL ->%%正常状态
            next;
        ?ROLE_STATE_DEAD ->%%死亡状态
            erlang:throw({error,?_LANG_ITEM_SPECIAL_ROLE_STATE_DEAD,0});
        ?ROLE_STATE_FIGHT ->%%战斗状态
            erlang:throw({error,?_LANG_ITEM_SPECIAL_ROLE_STATE_FIGHT,0});
        ?ROLE_STATE_EXCHANGE ->%%交易状态
            erlang:throw({error,?_LANG_ITEM_SPECIAL_ROLE_STATE_EXCHANGE,0});
        ?ROLE_STATE_ZAZEN ->%%打坐状态
            erlang:throw({error,?_LANG_ITEM_SPECIAL_ROLE_STATE_ZAZEN,20});
        ?ROLE_STATE_STALL ->%%摆摊状态
            erlang:throw({error,?_LANG_ITEM_SPECIAL_ROLE_STATE_STALL,0});
        ?ROLE_STATE_TRAINING ->%%训练状态
            erlang:throw({error,?_LANG_ITEM_SPECIAL_ROLE_STATE_TRAINING,0});
        ?ROLE_STATE_COLLECT -> %% 采集状态
            erlang:throw({error,?_LANG_ITEM_SPECIAL_ROLE_STATE_COLLECT,0});
        _ ->
            next
    end,
    %% 检查玩家是否有此道具
    UseGoods = 
        case mod_bag:check_inbag_by_typeid(RoleId, UseItemId) of
            {ok,UseGoodsList} ->
                [UseGoodsT|_TUseGoodsT] = UseGoodsList,
                UseGoodsT;
            _ ->
                erlang:throw({error,?_LANG_ITEM_SPECIAL_NOT_FIND,0})
        end,
    %% 从玩家当前的任务监听器查询此道具是否可以使用
    case mod_mission_data:get_listener(RoleId, 9, UseItemId) of
        false ->
            erlang:throw({error,?_LANG_ITEM_SPECIAL_NOT_MISSION,0});
        _ ->
            next
    end,
    %% 从玩家当前的任务数据获得使用道具完成的信息信息
    UseItemPointInfo=
        case mod_mission_data:get_mission_item_use_point(RoleId,UseItemId) of
            {ok,UseItemPointInfoT} ->
                UseItemPointInfoT;
            _ ->
                erlang:throw({error,?_LANG_ITEM_SPECIAL_NOT_MISSION,0})
        end,
    %% 检查玩家当前使用道具 的坐标
    CurMapId = mgeem_map:get_mapid(),
    {mission_status_data_use_item,_PItemId,PMapId,PTx,PTy,PTotalProgress,PNewTypeId,PNewNumber,_PShowName,PProgressDesc}=UseItemPointInfo,
    case CurMapId =:= PMapId 
        andalso erlang:abs((RoleMapInfo#p_map_role.pos)#p_pos.tx - PTx) =< 2
        andalso erlang:abs((RoleMapInfo#p_map_role.pos)#p_pos.ty - PTy) =< 2 of
        true ->
            next;
        _ ->
            [PMapName] = common_config_dyn:find(map_info,PMapId),
            erlang:throw({error,common_tool:get_format_lang_resources(?_LANG_ITEM_SPECIAL_USE_POS, [PMapName,PTx,PTy]),0})
    end,
    case PTotalProgress > 0 of
        true ->
            case get_role_use_special_item_dict(CurMapId,RoleId) of
                undefined ->
                    %% 使用些道具需要读条显示操作
                    NowSeconds = mgeem_map:get_now(),
                    ItemSpecialDict = #r_item_special_dict{role_id = RoleId,
                                                           item_id = UseItemId,
                                                           start_time = NowSeconds,
                                                           end_time = NowSeconds + PTotalProgress,
                                                           new_type_id = PNewTypeId,
                                                           new_number = PNewNumber,
                                                           total_progress = PTotalProgress,
                                                           progress_desc = PProgressDesc},
                    set_role_use_special_item_dict(CurMapId,ItemSpecialDict),
                    erlang:throw({ok,use_start,ItemSpecialDict});
                ItemSpecialDictInfo ->
                    case ItemSpecialDictInfo#r_item_special_dict.item_id =:= UseItemId of
                        true ->
                            erlang:throw({error,?_LANG_ITEM_SPECIAL_USE_DOING,0});
                        _ ->
                            erlang:throw({error,?_LANG_ITEM_SPECIAL_USE_DOING_OTHER,0})
                    end
            end;
        _ ->
            next
    end,
    {ok,UseGoods,{PTotalProgress,PNewTypeId,PNewNumber,PProgressDesc}}.
%% UseItemPointInfo 结构为 {PTotalProgress,PNewTypeId,PNewNumber,PProgressDesc}
do_use_special3(Unique,Module,Method,DataRecord,RoleId,PId,UseGoods,UseItemPointInfo) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_use_special(RoleId,UseGoods,UseItemPointInfo)
           end) of
        {atomic,{ok,NewGoodsList}} ->
            do_use_special4(Unique,Module,Method,DataRecord,RoleId,PId,UseGoods,UseItemPointInfo,NewGoodsList);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_use_special_error(Unique,Module,Method,DataRecord,RoleId,PId,?_LANG_ITEM_SPECIAL_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_use_special_error(Unique,Module,Method,DataRecord,RoleId,PId,Reason,ReasonCode);
                _ ->
                    do_use_special_error(Unique,Module,Method,DataRecord,RoleId,PId,?_LANG_ITEM_SPECIAL_ERROR,0)
            end
    end.
%% 开始读条使用道具
do_use_special_start(Unique,Module,Method,DataRecord,_RoleId,PId,ItemSpecialDict) ->
    UseItemId = DataRecord#m_item_use_special_tos.item_id,
    [#p_item_base_info{effects=Effects}]=common_config_dyn:find_item(UseItemId),
    SendSelf = #m_item_use_special_toc{item_id = UseItemId,
                                       succ = true,
                                       use_status = 1,
                                       total_progress = ItemSpecialDict#r_item_special_dict.total_progress,
                                       use_effect = if ItemSpecialDict#r_item_special_dict.total_progress > 0 -> 2; true -> 1 end,
                                       effects = Effects,
                                       new_goods_list = [],
                                       progress_desc = ItemSpecialDict#r_item_special_dict.progress_desc},
    ?DEBUG("~ts,SendSelf=~w",["使用特殊道具返回",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
do_use_special4(Unique,Module,Method,DataRecord,RoleId,PId,UseGoods,UseItemPointInfo,NewGoodsList) ->
    erase_role_use_special_item_dict(mgeem_map:get_mapid(),RoleId),
    UseItemId = DataRecord#m_item_use_special_tos.item_id,
    %% 道具日志，通知背包完成，通知任务事件完成，返回消息
    %% 道具变化通知
    catch common_misc:update_goods_notify({role, RoleId},NewGoodsList),
    catch common_misc:del_goods_notify({role, RoleId},[UseGoods]),
    common_item_logger:log(RoleId,UseGoods,1,?LOG_ITEM_TYPE_SPECIAL_USE_SHI_QU),
    mod_mission_handler:handle({listener_dispatch, give_use_prop, RoleId, UseItemId}),
    {PTotalProgress,_PNewTypeId,PNewNumber,PProgressDesc} = UseItemPointInfo,
    [#p_item_base_info{effects=Effects}]=common_config_dyn:find_item(UseItemId),
    SendSelf = #m_item_use_special_toc{item_id = UseItemId,
                                       succ = true,
                                       use_status = 2,
                                       total_progress = PTotalProgress,
                                       use_effect = if PTotalProgress > 0 -> 2; true -> 1 end,
                                       effects = Effects,
                                       new_goods_list = NewGoodsList,
                                       progress_desc = PProgressDesc},
    ?DEBUG("~ts,SendSelf=~w",["使用特殊道具返回",SendSelf]),
    %% 任务监听道具
    case NewGoodsList =/= [] of
        true ->
            [HNewGoods|_TNewGoods] = NewGoodsList,
            common_item_logger:log(RoleId,HNewGoods,PNewNumber,?LOG_ITEM_TYPE_SPECIAL_USE_HUO_DE),
            hook_prop:hook(create, NewGoodsList);
        _ ->
            ignore
    end,
    case PId of
        undefined ->
            common_misc:unicast({role,RoleId}, Unique, Module, Method, SendSelf);
        _ ->
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf)
    end.
do_t_use_special(RoleId,UseGoods,UseItemPointInfo) ->
    mod_bag:delete_goods(RoleId, [UseGoods#p_goods.id]),
    {_PTotalProgress,PNewTypeId,PNewNumber,_PProgressDesc} = UseItemPointInfo,
    case PNewTypeId > 0 of
        true -> %% 创建新的物品，只能创建道具
             CreateItemInfo = #r_goods_create_info{type=?TYPE_ITEM,type_id=PNewTypeId,num=PNewNumber,bind=true},
             {ok,NewGoodsList} = mod_bag:create_goods(RoleId,CreateItemInfo);
        _ ->
            NewGoodsList = []
    end,
    {ok,NewGoodsList}.
do_use_special_error(Unique,Module,Method,DataRecord,RoleId,PId,Reason,ReasonCode) ->
    SendSelf = #m_item_use_special_toc{item_id = DataRecord#m_item_use_special_tos.item_id,
                                       succ = false,reason = Reason, reason_code = ReasonCode,
                                       use_status = 0,total_progress = 0,use_effect = 0,effects = [],
                                       new_goods_list = []},
    ?DEBUG("~ts,SendSelf=~w",["使用特殊道具返回",SendSelf]),
    case PId of
        undefined ->
            common_misc:unicast({role,RoleId}, Unique, Module, Method, SendSelf);
        _ ->
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf)
    end.

%% @doc 判断某个数是否是正整数
assert_positive_int(Value, Reason) ->
    if Value > 0 ->
            ok;
       true ->
            erlang:throw({error, Reason})
    end.

check_can_use_item(RoleId, DataIn) ->
    #m_item_use_tos{itemid=ItemId, usenum=UseNum} = DataIn,
    assert_positive_int(UseNum, ?_LANG_ITEM_USE_ILLEGAL_NUM),
    RoleMapInfo =
        case mod_map_actor:get_actor_mapinfo(RoleId, role) of
            undefined ->
                erlang:throw({error, ?_LANG_SYSTEM_ERROR});
            TMapInfo ->
                TMapInfo
        end,
    {ItemInfo, ItemBaseInfo} =
        case get_item_info(RoleId, ItemId) of
            {ok, TInfo, TBaseInfo} ->
                {TInfo, TBaseInfo};
            {error, Reason} ->
                erlang:throw({error, Reason})
        end,
    check_if_can_use(RoleId, RoleMapInfo, ItemInfo, ItemBaseInfo, UseNum),
    TransModule =
        case get_transaction_module(ItemBaseInfo#p_item_base_info.effects, common_transaction) of
            {error, _} ->
                erlang:throw({error, ?_LANG_SYSTEM_ERROR});
            TModule ->
                TModule
        end,
    {ok, ItemBaseInfo, ItemInfo, TransModule}.


%%获取道具的物品信息和基础属性
%%返回结果{ok,道具物品信息,道具基础信息} | {error,Reason}
get_item_info(RoleID,ItemID) ->
    case mod_bag:check_inbag(RoleID,ItemID) of
         {ok,ItemInfo} ->
            case get_item_baseinfo(ItemInfo#p_goods.typeid) of
                {ok, ItemBaseInfo} ->
                    {ok, ItemInfo,ItemBaseInfo};
                _ ->
                    {error,?_LANG_ITEM_NO_TYPE_GOODS}
            end;
        false->
            {error,?_LANG_ITEM_NO_TYPE_GOODS};
        {error,Reason} ->
            {error,Reason}
    end.

%%在事务外，检查能检查的道具使用条件
check_if_can_use(RoleID, RoleMapInfo, ItemInfo, ItemBaseInfo, UsedNum) ->
    check_if_is_item(ItemInfo),
    check_in_use_time(ItemInfo),
    check_item_num(ItemInfo, UsedNum),
    check_item_use_interval(RoleID, ItemBaseInfo#p_item_base_info.cd_type),
    check_role_state(RoleMapInfo),
    check_item_use_requirement(ItemBaseInfo, RoleMapInfo).

%%检查是否是道具
check_if_is_item(ItemInfo) ->
    case ItemInfo#p_goods.type of
        ?TYPE_ITEM ->
            ok;
        _ ->
            throw({error,?_LANG_ITEM_NOT_CAN_USE})
    end.

%%检查道具是否到了可以使用的时间，或者过期了
check_in_use_time(ItemInfo) ->
    #p_goods{start_time = StartTime,
             end_time = EndTime} = ItemInfo,
    Now = common_tool:now(),         
    if StartTime =:= 0  orelse 
       StartTime =< Now ->
            next;
       true ->
            throw({error,?_LANG_GOODS_USE_TIME_NOT_ARRIVE})
    end,
    if EndTime =:= 0  orelse 
       EndTime >= Now ->
            ok;
       true ->
            throw({error,?_LANG_GOODS_USE_TIME_PASSED})
    end.

%%检查道具的个数是否够使用的个数
check_item_num(ItemInfo,UsedNum) ->
    case ItemInfo#p_goods.current_num >= UsedNum of
        true ->
            ok;
        false ->
            throw({error,?_LANG_GOODS_NUM_NOT_ENOUGH})
    end.

%%减少道具使用的cd时间
check_item_use_interval(RoleID,CDType) ->
    case get({effect_last_use_time, RoleID}) of
        undefined ->
            ok;
        TimeList ->
            case lists:keyfind(CDType, 1, TimeList) of
                {_, LastUseTime} ->
                    Now = common_tool:now2(),
                    CDTime = config_item:get_cd_time(CDType),
                    case Now - LastUseTime > CDTime - 100 of
                        true ->
                            ok;
                        _ ->
                            throw({error,?_LANG_ITEM_USE_TOO_FAST})
                    end;
                _ ->
                    ok
            end
    end.

%%在事务中检查玩家道具使用时的状态
check_role_state(#p_map_role{state=RoleState}) ->
    if RoleState =:= ?ROLE_STATE_DEAD ->
            erlang:throw({error, ?_LANG_ITEM_ROLE_DEAD});
       RoleState =:= ?ROLE_STATE_TRAINING ->
            erlang:throw({error, ?_LANG_ITEM_ROLE_TRAINING});
       true ->
            ok
    end.

%%在事务中检查道具的使用需求
check_item_use_requirement(ItemBaseInfo, #p_map_role{level=Level}) ->
    #p_item_base_info{requirement=Req}=ItemBaseInfo,
    MinLevel = Req#p_use_requirement.min_level,
    MaxLevel = Req#p_use_requirement.max_level,
    %%检查道具使用限制的等级
    if (is_integer(MinLevel) andalso
        is_integer(MaxLevel) andalso
        MinLevel-1 < Level andalso
        MaxLevel+1 > Level )orelse
       (MinLevel =:= 0 andalso
        MaxLevel =:= 0 ) ->
            ok;
       true ->
            erlang:throw({error, ?_LANG_ITEM_LEVEL_DO_NOT_MEET})
    end.

%%@return #r_item_effect_result()
get_item_effect_result({ItemInfo,RoleBase,RoleAttr,AccMsgList,AccPromptList})->
    #r_item_effect_result{item_info=ItemInfo,role_base=RoleBase,role_attr=RoleAttr,
                          msg_list=AccMsgList,prompt_list=AccPromptList};
get_item_effect_result(Rec) when is_record(Rec,r_item_effect_result)->
    Rec.

get_transaction_module([], Module) ->
    Module;
get_transaction_module([{p_item_effect, FunId, _}|TEffects], Module) ->
    case common_config_dyn:find(item_effect, FunId) of
        [] ->
            {error, not_found};
        [{_, _}] ->
            get_transaction_module(TEffects, Module);
        [{_, _, M}] ->
            if M =:= db ->
                    db;
               true ->
                    get_transaction_module(TEffects, Module)
            end
    end.

%%使用道具功能
apply_item_effect(ItemInfo, ItemBaseInfo, RoleBase, RoleAttr, EffectID, UseNum, State, TransModule) ->
    Acc0 = get_item_effect_result({ItemInfo, RoleBase, RoleAttr, [], []}),
    lists:foldl(
      fun({p_item_effect,FunID,Params},Acc)->
              #r_item_effect_result{item_info=AccItemInfo,role_base=AccRoleBase,role_attr=AccRoleAttr,
                                    msg_list=AccMsgList,prompt_list=AccPromptList} = Acc,
              case common_config_dyn:find(item_effect, FunID) of
                  [] ->
                      ?ERROR_MSG("~ts:~p, ~ts:~p",["玩家发送了一个不存在的item effect id", FunID, "角色ID", RoleBase#p_role_base.role_id]),
                      TransModule:abort(?_LANG_SYSTEM_ERROR);
                  [{M,F}] ->
                      Rt = M:F(AccItemInfo,ItemBaseInfo,AccRoleBase,AccRoleAttr,AccMsgList,AccPromptList,Params,EffectID,UseNum,State, TransModule),
                      get_item_effect_result(Rt);
                  [{M,F,_}] ->
                      Rt = M:F(AccItemInfo,ItemBaseInfo,AccRoleBase,AccRoleAttr,AccMsgList,AccPromptList,Params,EffectID,UseNum,State, TransModule),
                      get_item_effect_result(Rt)
              end
      end, Acc0, ItemBaseInfo#p_item_base_info.effects).

%%@doc 依放入的顺序发送在事务中带出来的消息  
%%  同时执行指定的func函数
send_use_item_msg(TocMsgList) ->
    lists:foreach(
      fun({RoleID, Module, Method, Data}) ->
              common_misc:unicast({role,RoleID},?DEFAULT_UNIQUE, Module, Method, Data);
         ({func,Fun})->
              Fun()
      end,lists:reverse(TocMsgList)).

%%更新道具使用的cd时间
updata_use_cd_time(ItemBase,RoleID) ->
    CDType = ItemBase#p_item_base_info.cd_type,
    case get({effect_last_use_time, RoleID}) of
        undefined ->
            put({effect_last_use_time, RoleID}, [{CDType, common_tool:now2()}]);
        TimeList ->
            case lists:keyfind(CDType, 1, TimeList) of
                false ->
                    put({effect_last_use_time, RoleID}, [{CDType, common_tool:now2()}|TimeList]);
                _ ->
                    put({effect_last_use_time, RoleID}, [{CDType, common_tool:now2()}|lists:keydelete(CDType, 1, TimeList)])
            end
    end.

%% 扩展背包
do_shrink(Unique, Module, Method, DataIn, RoleID, Line) ->
    case catch do_shrink2(RoleID,DataIn) of
        {error,Reason} ->
            do_shrink_error(RoleID, Unique, Module, Method, Line, Reason);
        {ok} ->
            do_shrink2(Unique, Module, Method, DataIn, RoleID, Line)
    end.
do_shrink2(_RoleID,DataIn) ->
    case DataIn#m_item_shrink_bag_tos.bagid > 1 andalso DataIn#m_item_shrink_bag_tos.bagid < 5 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_ITEM_ERROR_SHRINK_BAGID})
    end,
    {ok}.
do_shrink2(Unique, Module, Method, DataIn, RoleID, Line) ->
    case db:transaction(
           fun() ->
                   do_t_shrink(RoleID,DataIn)
           end)
    of
        {aborted, Reason} ->
            ?DEV("~ts:~w",["收起扩展背包失败了", Reason]),
            do_shrink_error(RoleID, Unique, Module, Method, Line, Reason);
        {atomic, {ok,Goods,MainRows,MainClowns,MainGridNumber}}->
            ?DEV("goods:~w~n",[Goods]),
            Data = #m_item_shrink_bag_toc{
              succ=true,
              item=Goods,
              bagid=DataIn#m_item_shrink_bag_tos.bagid,
              rows = MainRows,
              columns = MainClowns,
              grid_number = MainGridNumber
             },
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Data)
    end.

do_shrink_error(RoleID, Unique, Module, Method, Line, Reason)
  when is_binary(Reason) ->
    R = #m_item_shrink_bag_toc{succ=false,reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R);
do_shrink_error(RoleID, Unique, Module, Method, Line, _) ->
    R = #m_item_shrink_bag_toc{succ=false,reason=?_LANG_SYSTEM_ERROR},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

do_t_shrink(RoleID,DataIn) ->
    #m_item_shrink_bag_tos{bagid=BagID, bag=Bag, position=Pos} = DataIn,
    [BagBasicInfo]= db:read(?DB_ROLE_BAG_BASIC_P,RoleID),
    #r_role_bag_basic{bag_basic_list=BagBasicList} = BagBasicInfo,
    DelBagBasicInfo = 
        case lists:keyfind(BagID,1,BagBasicList) of
            false ->
                db:abort(?_LANG_ITEM_ERROR_SHRINK_NOT_BAGID);
            DelBagBasicInfoT ->
                DelBagBasicInfoT
        end,
    BagBasicList2 = lists:keydelete(BagID,1,BagBasicList),
    MainBagID = 1,
    BagBasicList3 = lists:keydelete(MainBagID,1,BagBasicList2),
    %% 判断当前是否有物品占用扩展背包的格子
    {BagID,DelBagTypeID,DelOutUseTime,_DelRows,_DelClowns,DelGridNumber} = DelBagBasicInfo,
    {MainBagID,MainBagTypeID,MainOutUseTime,_MainRows,MainClowns,MainGridNumber} = mod_bag:get_bag_info_by_id(RoleID,MainBagID),
    case Pos > (MainGridNumber - DelGridNumber) of
        true ->
            db:abort(?_LANG_ITEM_ERROR_SHRINK_BAG_ITEM_POS);
        _ ->
            next
    end,
    case (MainGridNumber - DelGridNumber) rem MainClowns of
        0 ->
            MainRows2 = (MainGridNumber - DelGridNumber) div MainClowns;
        _ ->
            MainRows2 = (MainGridNumber - DelGridNumber) div MainClowns + 1
    end,
    MainGoodsList = mod_refining_bag:get_goods_by_bag_id(RoleID,1),
    case lists:foldl(
           fun(MainGoods,AccFlag) ->
                   case MainGoods#p_goods.bagposition > (MainGridNumber - DelGridNumber) of
                       true ->
                           false;
                       _ ->
                           AccFlag
                   end
           end,true,MainGoodsList) of
        true ->
            next;
        _ ->
            db:abort(?_LANG_ITEM_ERROR_GOODS_IN_SHRINK)
    end,
    mod_bag:delete_bag(RoleID,MainBagID,MainRows2,MainClowns,MainGridNumber - DelGridNumber),
    NewBagBasicInfo = BagBasicInfo#r_role_bag_basic{
                        bag_basic_list=[{MainBagID,MainBagTypeID,MainOutUseTime,MainRows2,MainClowns,MainGridNumber - DelGridNumber}
                                        |BagBasicList3]},
    db:write(?DB_ROLE_BAG_BASIC_P,NewBagBasicInfo,write),
    StartTime = 
        if DelOutUseTime =:=0 -> 
                0;  %%若设为0且end_time!=0，在create的时候会让start_time=now, end_time=end_time+start_time
           true->
                1
        end,
    CreateInfo = #r_goods_create_info{
      type=?TYPE_ITEM,
      type_id=DelBagTypeID,
      num=1,
      bind=true,
      bag_id = Bag,
      position = Pos,
      start_time = StartTime,   
      end_time= DelOutUseTime},
    {ok,[Goods]} = mod_bag:create_goods(RoleID,CreateInfo),
    {ok,Goods,MainRows2,MainClowns,MainGridNumber - DelGridNumber}.

%% @doc 追踪符
do_trace(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_item_trace_tos{target_name=TargetName, goods_id=GoodsID} = DataIn,
    %% 是否能够使用
    case check_can_use_trace_rune(RoleID, GoodsID) of
        {ok, GoodsInfo} ->
            TargetID = common_misc:get_roleid(TargetName),
            %% 是否在线
            case common_misc:is_role_online(TargetID) of
                false ->
                    do_trace_error(Unique, Module, Method, PID, ?_LANG_ITEM_TRACE_ROLE_NOT_FOUND);
                _ ->
                    do_trace2(Unique, Module, Method, RoleID, TargetID, TargetName, GoodsInfo, PID)
            end;
        {error, Reason} ->
            do_trace_error(Unique, Module, Method, PID, Reason)
    end.

do_trace2(Unique, Module, Method, RoleID, TargetID, TargetName, GoodsInfo, PID) ->
    %% 暂时用脏读
    {ok, #p_role_pos{map_process_name=TargetMapPName, map_id=MapID, pos=#p_pos{tx=TX, ty=TY}}} = common_misc:get_dirty_role_pos(TargetID),
    %% 减的数量写死是1
    Fun = fun() -> mod_bag:decrease_goods(RoleID, [{GoodsInfo, 1}]) end,
    case common_transaction:transaction(Fun) of
        {atomic, {ok, [undefined]}} ->
            GoodsInfo2 = GoodsInfo#p_goods{current_num=0},
            do_trace3(Unique, Module, Method, RoleID, TargetID, TargetName, TargetMapPName, MapID, TX, TY, GoodsInfo, GoodsInfo2, PID);
        {atomic, {ok, [GoodsInfo2]}} ->
            do_trace3(Unique, Module, Method, RoleID, TargetID, TargetName, TargetMapPName, MapID, TX, TY, GoodsInfo, GoodsInfo2, PID);
        {aborted, Reason} ->
            ?ERROR_MSG("~ts: ~w", ["追踪符使用出错：", Reason]),
            do_trace_error(Unique, Module, Method, PID, ?_LANG_ITEM_TRACE_SYSTEM_ERROR)
    end.

do_trace3(Unique, Module, Method, RoleID, TargetID, TargetName, TargetMapPName, MapID, TX, TY, GoodsInfo, GoodsInfo2, PID) ->
    %% 道具使用日志
    item_use_log(RoleID, GoodsInfo, GoodsInfo2),
    %% 回复客户端
    #p_goods{id=GoodsID, current_num=Num} = GoodsInfo2,
    case global:whereis_name(TargetMapPName) of
        undefined ->
            DataRecord = #m_item_trace_toc{goods_id=GoodsID, goods_num=Num, target_name=TargetName,
                                           target_mapid=MapID, target_tx=TX, target_ty=TY},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord);
        MapPID ->
            MapPID ! {mod_map_role, {trace_role, Unique, Module, Method, PID, {TargetID, TargetName, GoodsID, Num}}}
    end.

do_trace_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_item_trace_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 是否能使用追踪符
check_can_use_trace_rune(RoleID, GoodsID) ->
    case mod_bag:get_goods_by_id(RoleID, GoodsID) of
        {ok, GoodsInfo} ->
            %% todo: 判断是否是追踪符
            {ok, GoodsInfo};
        _ ->
            {error, ?_LANG_ITEM_TRACE_GOODS_NOT_FOUND}
    end.

%%道具使用日志
item_use_log(RoleID,ItemInfo,NewItemInfo) ->
    if ItemInfo#p_goods.current_num =:= NewItemInfo#p_goods.current_num + 1 ->
           ?DEBUG("current_colour:~w,quality:~w~n",[ItemInfo#p_goods.current_colour,ItemInfo#p_goods.quality]),
           if ItemInfo#p_goods.current_colour>1 orelse ItemInfo#p_goods.quality>1 ->
                  common_item_logger:log(RoleID,ItemInfo,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU);
              true->
                  case get({used_item,RoleID,ItemInfo#p_goods.typeid}) of
                      undefined ->
                          List = case get(?USED_ITEM_LIST) of
                                     undefined ->
                                         [];
                                     ListTmp ->
                                         ListTmp
                                 end,
                          put(?USED_ITEM_LIST,[{used_item,RoleID,ItemInfo#p_goods.typeid}|List]),
                          put({used_item,RoleID,ItemInfo#p_goods.typeid},{1});
                      {Num} ->
                          put({used_item,RoleID,ItemInfo#p_goods.typeid},{Num+1})
                  end
           end;
       true ->
           ignore
    end.

do_insert_item_logs(UsedItemList,LogTime)->
    lists:foreach(fun({used_item,RoleID,TypeID}=Key)->
                          case get(Key) of
                              undefined->
                                  ignore;
                              {Num}->
                                  common_item_logger:log(RoleID, TypeID,Num,undefined,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                                  erlang:erase(Key)
                          end
                  end, UsedItemList),
    erlang:erase(?USED_ITEM_LIST),
    put(?USED_ITEM_LIST_LAST_TIME,LogTime).
    

%%@doc 检查是否发送缓存中的道具日志列表
check_item_use_log() ->
    case get(?USED_ITEM_LIST) of
        undefined ->
            ignore;
        List ->
            Now = common_tool:now(),
            [Interval] = common_config_dyn:find(logs,item_use_log_cache_interval),
            case get(?USED_ITEM_LIST_LAST_TIME) of
                undefined->
                    do_insert_item_logs(List,Now);
                Time->
                    case (Now - Time) > Interval*60 of
                        true ->
                            do_insert_item_logs(List,Now);
                        false ->
                            ignore
                    end 
            end
    end.
                      
  

%%创建物品
create_item(CreateInfo)when is_record(CreateInfo,r_item_create_info) ->
    common_bag2:create_item(CreateInfo).


%%获取道具的基础属性
get_item_baseinfo(TypeID) ->
    case common_config_dyn:find_item(TypeID) of
        [] ->
            error;
        [BaseInfo] -> 
            {ok,BaseInfo}
    end.

add_role_drunk_count(RoleID) ->
    ToDay = common_tool:today(0,0,0),
    case get({drunk_count,RoleID}) of
        undefined -> put({drunk_count,RoleID},{ToDay,1});
        {Day,OCount} ->
            if Day =/= ToDay ->
                    put({drunk_count,RoleID},{ToDay,1});
               Day =:= ToDay andalso OCount > 4 ->
                    db:abort(?_LANG_ITEM_USE_WINE_TO_MAX);
               true ->
                    put({drunk_count,RoleID},{ToDay,1+OCount})
            end
    end.

get_role_drunk_count(RoleID) ->
    get({drunk_count,RoleID}).

put_role_drunk_count(RoleID, {_,_} = Count) ->
    put({drunk_count,RoleID},Count);
put_role_drunk_count(_, _) ->
    ignore.
