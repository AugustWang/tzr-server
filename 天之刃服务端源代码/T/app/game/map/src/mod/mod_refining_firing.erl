%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2011, 
%%% @doc
%%% 天工炉模块功能
%%% @end
%%% Created : 29 Apr 2011 by  <caochuncheng2002@gmail.com>
%%%-------------------------------------------------------------------
-module(mod_refining_firing).

%% INCLUDE
-include("mgeem.hrl").
-include("refining.hrl").
-include("equip.hrl").

%% API
-export([
         do_handle_info/1
        ]).

%%%===================================================================
%%% API
%%%===================================================================

%% 天工炉功能处理
do_handle_info({Unique, ?REFINING, ?REFINING_FIRING, DataRecord, RoleId, PId, Line}) ->
    do_refining_firing({Unique, ?REFINING, ?REFINING_FIRING, DataRecord, RoleId, PId, Line});

do_handle_info(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["天工炉模块无法处理此消息",Info]),
    error.

format_value(Value,DefaultValue)->
    case erlang:is_integer(Value) andalso Value =:= 0 of 
        true ->
            DefaultValue;
        _ ->
            Value
    end.


%% DataRecord 结构为 m_refining_firing_tos
do_refining_firing({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    #m_refining_firing_tos{op_type = OpType} = DataRecord,
    case OpType of
        ?FIRING_OP_TYPE_PUNCH -> %% 开孔
            do_refining_firing_punch({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_INLAY -> %% 镶嵌
            do_refining_firing_inlay({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_UNLOAD -> %% 折卸
            do_refining_firing_unload({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_REINFORCE -> %% 强化
            do_refining_firing_reinforce({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_COMPOSE -> %% 合成 
            do_refining_firing_compose({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_FORGING -> %% 炼制
            do_refining_firing_forging({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_ADDPROP -> %% 附加，绑定
            do_refining_firing_addprop({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_UPPROP -> %% 提升
            do_refining_firing_upprop({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_UPCOLOR -> %% 提升装备颜色
            mod_equip_color:do_up_equip_color({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_RETAKE -> %% 取回天工炉物品接口
            do_refining_firing_retake({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_UPEQUIP -> %% 装备升级
            mod_equip_upgrade:do_equip_upgrade({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_UPQUALITY -> %% 装备品质改造
            mod_equip_quality:do_up_equip_quality({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?FIRING_OP_TYPE_ADD_MAGIC -> %% 装备附魔 
            mod_equip_add_magic:do_equip_add_magic({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        _ ->
            Reason = ?_LANG_REFINING_OP_TYPE_ERROR,
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason,0)
    end.
do_refining_firing_error({Unique, Module, Method, DataRecord, _RoleId, PId, _Line},Reason,ReasonCode) ->
    SendSelf = #m_refining_firing_toc{
      succ = false,
      reason = Reason,
      reason_code = ReasonCode,
      op_type = DataRecord#m_refining_firing_tos.op_type,
      sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
      firing_list = DataRecord#m_refining_firing_tos.firing_list},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).
%% 开孔
do_refining_firing_punch({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_firing_punch2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,EquipGoods,PunchGoods,PunchLevel,PunchFee} ->
            do_refining_firing_punch3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                      EquipGoods,PunchGoods,PunchLevel,PunchFee)
    end.
do_refining_firing_punch2(RoleId,DataRecord) ->
    #m_refining_firing_tos{firing_list = FiringList} = DataRecord,
    %% 材料是否足够合法
    case (erlang:length(FiringList) =:= 2) of
        true ->
            next;
        false ->
            erlang:throw({error,?_LANG_PUNCH_NOT_ENOUGH_GOODS,0})
    end,
    %% 检查是否有要开孔的装备
    EquipGoods = 
        case lists:foldl(
               fun(EquipPRefiningT,AccEquipPRefiningT) ->
                       case ( AccEquipPRefiningT =:= undefined
                              andalso EquipPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_TARGET
                              andalso EquipPRefiningT#p_refining.goods_type =:= ?TYPE_EQUIP) of
                           true ->
                               EquipPRefiningT;
                           false ->
                               AccEquipPRefiningT
                       end 
               end,undefined,FiringList) of
            undefined ->
                erlang:throw({error,?_LANG_PUNCH_NO_EQUIP,0});
            EquipPRefiningTT ->
                case mod_bag:check_inbag(RoleId,EquipPRefiningTT#p_refining.goods_id) of
                    {ok,EquipGoodsT} ->
                        EquipGoodsT;
                    _  ->
                        erlang:throw({error,?_LANG_PUNCH_NO_EQUIP,0})
                end
        end,
    [EquipBaseInfo] = common_config_dyn:find_equip(EquipGoods#p_goods.typeid),
    if EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT ->
            erlang:throw({error,?_LANG_PUNCH_MOUNT_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_FASHION ->
            erlang:throw({error,?_LANG_PUNCH_FASHION_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_ADORN ->
            erlang:throw({error,?_LANG_PUNCH_ADORN_ERROR,0});
       true ->
            next
    end,
    [SpecialEquipList] = common_config_dyn:find(refining,special_equip_list),
    case lists:member(EquipGoods#p_goods.typeid,SpecialEquipList) of
        true ->
            erlang:throw({error,?_LANG_PUNCH_ADORN_ERROR,0});
        _ ->
            next
    end,
    if EquipGoods#p_goods.punch_num >= ?MAX_PUNCH_NUM ->
            erlang:throw({error,?_LANG_PUNCH_MAX_HOLE,0});
       true ->
            next
    end,
    [PunchKindList] = common_config_dyn:find(refining,punch_kind_list),
    case lists:member(EquipBaseInfo#p_equip_base_info.kind,PunchKindList) of
        true ->
            next;
        false ->
            erlang:throw({error,?_LANG_PUNCH_CANT_PUNCH,0})
    end,
    %% 检查是否有有开孔符
    PunchGoods = 
        case lists:foldl(
               fun(PunchPRefiningT,AccPunchPRefiningT) ->
                       case ( AccPunchPRefiningT =:= undefined
                              andalso PunchPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL
                              andalso PunchPRefiningT#p_refining.goods_type =:= ?TYPE_ITEM) of
                           true ->
                               PunchPRefiningT;
                           false ->
                               AccPunchPRefiningT
                       end
               end,undefined,FiringList) of
            undefined ->
                erlang:throw({error,?_LANG_PUNCH_NOT_ENOUGH_GOODS,0});
            PunchPRefiningTT ->
                case mod_bag:check_inbag(RoleId,PunchPRefiningTT#p_refining.goods_id) of
                    {ok,PunchGoodsT} ->
                        PunchGoodsT;
                    _  ->
                        erlang:throw({error,?_LANG_PUNCH_NOT_ENOUGH_GOODS,0})
                end
        end,
    %% 检查开孔符是否合法
    [RuneSymlolList] = common_config_dyn:find(refining,rune_symbol),
    PunchLevel = 
        case lists:keyfind(PunchGoods#p_goods.typeid,1,RuneSymlolList) of
            false ->
                erlang:throw({error,?_LANG_PUNCH_CANT_PUNCH,0});
            {_,PunchLevelT} ->
                PunchLevelT
        end,
    case PunchLevel < (EquipGoods#p_goods.punch_num + 1) of
        true ->
            erlang:throw({error,?_LANG_PUNCH_CANT_PUNCH,0});
        _ ->
            next
    end,
    RefiningFeeRecord =#r_refining_fee{type = equip_punch_fee,
                                 equip_level = EquipGoods#p_goods.level,
                                 material_level = PunchLevel,
                                 material_number = 1,
                                 refining_index = format_value(EquipGoods#p_goods.refining_index,1),
                                 punch_num = format_value(EquipGoods#p_goods.punch_num,1),
                                 stone_num = format_value(EquipGoods#p_goods.stone_num,1),
                                 equip_color = format_value(EquipGoods#p_goods.current_colour,1),
                                 equip_quality = format_value(EquipGoods#p_goods.quality,1)},
    PunchFee = 
        case mod_refining:get_refining_fee(RefiningFeeRecord) of
            {ok,PunchFeeT} ->
                PunchFeeT;
            {error,Error} ->
                erlang:throw({error,Error,0})
        end,
    ?DEBUG("",[]),
    {ok,EquipGoods,PunchGoods,PunchLevel,PunchFee}.
do_refining_firing_punch3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                          EquipGoods,PunchGoods,PunchLevel,PunchFee) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_firing_punch(RoleId,EquipGoods,PunchGoods,PunchLevel,PunchFee)
           end) of
        {atomic,{ok,IsPunchSucc,EquipGoods2,DelList,UpdateList}} ->
            do_refining_firing_punch4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                      IsPunchSucc,EquipGoods2,PunchGoods,PunchLevel,PunchFee,DelList,UpdateList);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_REFINING_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_PUNCH_ERROR,
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.

do_refining_firing_punch4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                          IsPunchSucc,EquipGoods,PunchGoods,_PunchLevel,_PunchFee,DelList,UpdateList) ->
    case IsPunchSucc =:= true of
        true ->
            Reason = common_tool:get_format_lang_resources(?_LANG_PUNCH_SUCC,[EquipGoods#p_goods.punch_num]),
            ReasonCode = 0;
        _ ->
            Reason = ?_LANG_PUNCH_FAIL,
            ReasonCode = 1
    end,
    SendSelf = #m_refining_firing_toc{
      succ = true,
      reason = Reason,
      reason_code = ReasonCode,
      op_type = DataRecord#m_refining_firing_tos.op_type,
      sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
      firing_list = DataRecord#m_refining_firing_tos.firing_list,
      update_list = [EquipGoods | UpdateList],
      del_list = DelList,
      new_list = []},
    %% 道具变化通知
    if UpdateList =/= [] ->
            catch common_misc:update_goods_notify({line, Line, RoleId},[EquipGoods | UpdateList]);
       true ->
            catch common_misc:update_goods_notify({line, Line, RoleId},[EquipGoods])
    end,
    if DelList =/= [] ->
            catch common_misc:del_goods_notify({line, Line, RoleId},DelList);
       true ->
            next
    end,
    %% 银子变化通知
    catch mod_refining:do_refining_deduct_fee_notify(RoleId,{line, Line, RoleId}),
    %% 道具消费日志
    catch common_item_logger:log(RoleId,PunchGoods,1,?LOG_ITEM_TYPE_KAI_KONG_SHI_QU),
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.

do_t_refining_firing_punch(RoleId,EquipGoods,PunchGoods,_PunchLevel,PunchFee) ->
    %% 扣费
    EquipConsume = #r_equip_consume{
      type = punch,consume_type = ?CONSUME_TYPE_SILVER_EQUIP_PUNCH,consume_desc = ""},
    case catch mod_refining:do_refining_deduct_fee(RoleId,PunchFee,EquipConsume) of
        {error,Error} ->
            common_transaction:abort({Error,0});
        _ ->
            next
    end,
    %% 扣除物品
    {DelList,UpdateList} = 
        case catch mod_equip_build:do_transaction_dedcut_goods(RoleId,[PunchGoods],1) of
            {error,GoodsError} ->
                common_transaction:abort({GoodsError,0});
            {ok,DelListT,UpdateListT} ->
                DelListT2  = 
                    lists:foldl(
                      fun(DelGoods,AccDelListT2) -> 
                              case lists:keyfind(DelGoods#p_goods.id,#p_goods.id,UpdateListT) of
                                  false ->
                                      [DelGoods | AccDelListT2];
                                  _ ->
                                      AccDelListT2
                              end
                      end,[],DelListT),
                {DelListT2,UpdateListT}
        end,
    %% 开孔概率配置
    [RuneSymbolProbabilityList] = common_config_dyn:find(refining,rune_symbol_probability),
    {_,RuneSymbolProbability} = lists:keyfind(EquipGoods#p_goods.punch_num + 1, 1,RuneSymbolProbabilityList),
    IsPunchSucc = 
        case RuneSymbolProbability =:= 100 of
            true ->
                NewPunchNum = EquipGoods#p_goods.punch_num  + 1,
                true;
            _ ->
                case RuneSymbolProbability >= common_tool:random(1,100) of
                    true ->
                        NewPunchNum = EquipGoods#p_goods.punch_num  + 1,
                        true;
                    _ ->
                        NewPunchNum = EquipGoods#p_goods.punch_num,
                        false
                end
        end,
        
    %% 材料是否绑定，装备是否已经绑定
    EquipGoods2 = EquipGoods#p_goods{punch_num = NewPunchNum},
    EquipGoods3 = 
        case (EquipGoods#p_goods.bind =:= false andalso PunchGoods#p_goods.bind =:= true) of
            true ->
                case mod_refining_bind:do_equip_bind_for_punch(EquipGoods2) of
                    {error,_ErrorBindCode} ->
                        EquipGoods2#p_goods{bind = true};
                    {ok,BindGoods} ->
                        BindGoods
                end;
            false ->
                EquipGoods2
        end,
    
    %% 计算装备精炼系数
    EquipGoods4 = 
        case common_misc:do_calculate_equip_refining_index(EquipGoods3) of
            {error,_ErrorIndexCode} ->
                EquipGoods3;
            {ok, EquipGoods4T} ->
                EquipGoods4T
        end,
    mod_bag:update_goods(RoleId,EquipGoods4),
    {ok,IsPunchSucc,EquipGoods4,DelList,UpdateList}.

%% 镶嵌
do_refining_firing_inlay({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_firing_inlay2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,EquipGoods,StoneGoods,SymbolGoods,SymbolLevel,InlayFee} ->
            do_refining_firing_inlay3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                      EquipGoods,StoneGoods,SymbolGoods,SymbolLevel,InlayFee)
    end.

do_refining_firing_inlay2(RoleId,DataRecord) ->
    #m_refining_firing_tos{firing_list = FiringList} = DataRecord,
    %% 材料是否足够合法
    case (erlang:length(FiringList) =:= 3) of
        true ->
            next;
        false ->
            erlang:throw({error,?_LANG_INLAY_ERROR,0})
    end,
    %% 检查是否有要镶嵌的装备
    EquipGoods = 
        case lists:foldl(
               fun(EquipPRefiningT,AccEquipPRefiningT) ->
                       case ( AccEquipPRefiningT =:= undefined
                              andalso EquipPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_TARGET
                              andalso EquipPRefiningT#p_refining.goods_type =:= ?TYPE_EQUIP) of
                           true ->
                               EquipPRefiningT;
                           false ->
                               AccEquipPRefiningT
                       end 
               end,undefined,FiringList) of
            undefined ->
                erlang:throw({error,?_LANG_INLAY_NO_EQUIP,0});
            EquipPRefiningTT ->
                case mod_bag:check_inbag(RoleId,EquipPRefiningTT#p_refining.goods_id) of
                    {ok,EquipGoodsT} ->
                        case EquipGoodsT#p_goods.stone_num =:= undefined of
                            true ->
                                EquipGoodsT#p_goods{stone_num = 0};
                            false ->
                                EquipGoodsT
                        end;
                    _  ->
                        erlang:throw({error,?_LANG_INLAY_NO_EQUIP,0})
                end
        end,
    [EquipBaseInfo] = common_config_dyn:find_equip(EquipGoods#p_goods.typeid),
    if EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT ->
            erlang:throw({error,?_LANG_INLAY_MOUNT_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_FASHION ->
            erlang:throw({error,?_LANG_INLAY_FASHION_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_ADORN ->
            erlang:throw({error,?_LANG_INLAY_ADORN_ERROR,0});
       true ->
            next
    end,
    [SpecialEquipList] = common_config_dyn:find(refining,special_equip_list),
    case lists:member(EquipGoods#p_goods.typeid,SpecialEquipList) of
        true ->
            erlang:throw({error,?_LANG_INLAY_ADORN_ERROR,0});
        _ ->
            next
    end,
    if EquipGoods#p_goods.punch_num =:= undefined ->
            erlang:throw({error,?_LANG_INLAY_HOLE_FULL,0});
       EquipGoods#p_goods.stone_num >= ?MAX_PUNCH_NUM ->
            erlang:throw({error,?_LANG_INLAY_MAX_STONE,0});
       EquipGoods#p_goods.punch_num =< EquipGoods#p_goods.stone_num ->
            erlang:throw({error,?_LANG_INLAY_HOLE_FULL,0});
       true ->
            next
    end,
    %% 镶嵌材料，宝石
    StoneGoods = 
        case lists:foldl(
               fun(StonePRefiningT,AccStonePRefiningT) ->
                       case ( AccStonePRefiningT =:= undefined
                              andalso StonePRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL
                              andalso StonePRefiningT#p_refining.goods_type =:= ?TYPE_STONE) of
                           true ->
                               StonePRefiningT;
                           false ->
                               AccStonePRefiningT
                       end 
               end,undefined,FiringList) of
            undefined ->
                erlang:throw({error,?_LANG_INLAY_NO_STONE,0});
            StonePRefiningTT ->
                case mod_bag:check_inbag(RoleId,StonePRefiningTT#p_refining.goods_id) of
                    {ok,StoneGoodsT} ->
                        StoneGoodsT;
                    _  ->
                        erlang:throw({error,?_LANG_INLAY_NO_STONE,0})
                end
        end,
    %% 检查当前此装备是否可以镶嵌此宝石
    [StoneBaseInfo] = common_config_dyn:find_stone(StoneGoods#p_goods.typeid),
    case lists:member(EquipBaseInfo#p_equip_base_info.slot_num,StoneBaseInfo#p_stone_base_info.embe_equip_list) of
        false ->
            erlang:throw({error,?_LANG_INLAY_STONE_NOT_CAN_INLAY,0});
        true -> 
            next
    end,  
    EquipStoneList = 
        case EquipGoods#p_goods.stones =:= undefined of
            true ->
                [];
            false ->
                EquipGoods#p_goods.stones
        end,
    case lists:foldl(
           fun(EquipStone,AccEquipStoneFlag) ->
                   [EquipStoneBaseInfo] = common_config_dyn:find_stone(EquipStone#p_goods.typeid),
                   case (AccEquipStoneFlag =:= false 
                         andalso StoneBaseInfo#p_stone_base_info.kind =:= EquipStoneBaseInfo#p_stone_base_info.kind) of
                       true ->
                           true;
                       false ->
                           AccEquipStoneFlag
                   end
           end,false,EquipStoneList) of
        true ->
            erlang:throw({error,?_LANG_INLAY_WITH_TYPE,0});
        false ->
            next
    end,     
    %% 镶嵌材料 镶嵌符
    SymbolGoods = 
        case lists:foldl(
               fun(SymbolPRefiningT,AccSymbolPRefiningT) ->
                       case ( AccSymbolPRefiningT =:= undefined
                              andalso SymbolPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL
                              andalso SymbolPRefiningT#p_refining.goods_type =:= ?TYPE_ITEM) of
                           true ->
                               SymbolPRefiningT;
                           false ->
                               AccSymbolPRefiningT
                       end 
               end,undefined,FiringList) of
            undefined ->
                erlang:throw({error,?_LANG_INLAY_NOT_SYMBOL,0});
            SymbolPRefiningTT ->
                case mod_bag:check_inbag(RoleId,SymbolPRefiningTT#p_refining.goods_id) of
                    {ok,SymbolGoodsT} ->
                        SymbolGoodsT;
                    _  ->
                        erlang:throw({error,?_LANG_INLAY_NOT_SYMBOL,0})
                end
        end,
    %%　检查镶嵌符是否合法
    [SymbolLevelList] = common_config_dyn:find(refining,inlay_symbol),
    SymbolLevel = 
        case lists:keyfind(SymbolGoods#p_goods.typeid,1,SymbolLevelList) of
            false ->
                erlang:throw({error,?_LANG_INLAY_NOT_SYMBOL,0});
            {_,SymbolLevelT} ->
                SymbolLevelT
        end,
    case EquipGoods#p_goods.stone_num + 1 > SymbolLevel of
        false ->
            next;
        true ->
            erlang:throw({error,?_LANG_INLAY_HAS_OTHER_SYMBOL,0})
    end,
    %% 镶嵌费用
    RefiningFee =#r_refining_fee{
      type = equip_inlay_fee,
      equip_level = EquipGoods#p_goods.level,
      refining_index = EquipGoods#p_goods.refining_index,
      punch_num = format_value(EquipGoods#p_goods.punch_num,1),
      stone_num = format_value(EquipGoods#p_goods.stone_num,1),
      equip_color = format_value(EquipGoods#p_goods.current_colour,1),
      equip_quality = format_value(EquipGoods#p_goods.quality,1)},
    InlayFee = 
        case mod_refining:get_refining_fee(RefiningFee) of
            {ok,InlayFeeT} ->
                InlayFeeT;
            {error,Error} ->
                erlang:throw({error,Error,0})
        end,
    {ok,EquipGoods,StoneGoods,SymbolGoods,SymbolLevel,InlayFee}.
do_refining_firing_inlay3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                          EquipGoods,StoneGoods,SymbolGoods,_SymbolLevel,InlayFee) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_firing_inlay(RoleId,EquipGoods,StoneGoods,SymbolGoods,InlayFee)
           end) of
        {atomic,{ok,EquipGoods2,DelList,UpdateList,DelStoneList,UpdateStoneList}} ->
            do_refining_firing_inlay4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                      EquipGoods2,StoneGoods,SymbolGoods,DelList,UpdateList,DelStoneList,UpdateStoneList);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_REFINING_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_INLAY_ERROR,
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_firing_inlay4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                          EquipGoods,StoneGoods,SymbolGoods,DelList,UpdateList,DelStoneList,UpdateStoneList) ->
    SendUpdateList = lists:append([[EquipGoods],UpdateList,UpdateStoneList]),
    SendDelList = lists:append([DelList,DelStoneList]),
    SendSelf = #m_refining_firing_toc{
      succ = true,
      op_type = DataRecord#m_refining_firing_tos.op_type,
      sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
      firing_list = DataRecord#m_refining_firing_tos.firing_list,
      update_list = SendUpdateList,
      del_list = SendDelList,
      new_list = []},
    %% 道具变化通知
    catch common_misc:update_goods_notify({line, Line, RoleId},SendUpdateList),
    if SendDelList =/= [] ->
            catch common_misc:del_goods_notify({line, Line, RoleId},SendDelList);
       true ->
            next
    end,
    %% 道具消费日志
    catch common_item_logger:log(RoleId,StoneGoods,1,?LOG_ITEM_TYPE_XIANG_QIAN_SHI_QU),
    catch common_item_logger:log(RoleId,SymbolGoods,1,?LOG_ITEM_TYPE_XIANG_QIAN_SHI_QU),
    catch common_item_logger:log(RoleId,EquipGoods,1,?LOG_ITEM_TYPE_XIANG_QIAN_HUO_DE),
    %% 成就系统添加hook
    catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [100007]}),
    %% 银子变化通知
    catch mod_refining:do_refining_deduct_fee_notify(RoleId,{line, Line, RoleId}),
    common_mod_goal:hook_equip_inlay(RoleId),
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
do_t_refining_firing_inlay(RoleId,EquipGoods,StoneGoods,SymbolGoods,InlayFee) ->
    %% 扣费用
    EquipConsume = #r_equip_consume{
      type = inlay,consume_type = ?CONSUME_TYPE_SILVER_EQUIP_INLAY,consume_desc = ""},
    case catch mod_refining:do_refining_deduct_fee(RoleId,InlayFee,EquipConsume) of
        {error,InlayFeeError} ->
            common_transaction:abort({InlayFeeError,0});
        _ ->
            next
    end,
    %% 扣物品 镶嵌符
    {DelList,UpdateList} = 
        case catch mod_equip_build:do_transaction_dedcut_goods(RoleId,[SymbolGoods],1) of
            {error,GoodsError} ->
                common_transaction:abort({GoodsError,0});
            {ok,DelListT,UpdateListT} ->
                DelListT2  = 
                    lists:foldl(
                      fun(DelGoods,AccDelListT2) -> 
                              case lists:keyfind(DelGoods#p_goods.id,#p_goods.id,UpdateListT) of
                                  false ->
                                      [DelGoods | AccDelListT2];
                                  _ ->
                                      AccDelListT2
                              end
                      end,[],DelListT),
                {DelListT2,UpdateListT}
        end,
    %% 删除宝石
    {DelStoneList,UpdateStoneList} = 
        case catch mod_equip_build:do_transaction_dedcut_goods(RoleId,[StoneGoods],1) of
            {error,StoneGoodsError} ->
                common_transaction:abort({StoneGoodsError,0});
            {ok,DelStoneListT,UpdateStoneListT} ->
                DelStoneListT2  = 
                    lists:foldl(
                      fun(DelStoneGoods,AccDelStoneListT2) -> 
                              case lists:keyfind(DelStoneGoods#p_goods.id,#p_goods.id,UpdateStoneListT) of
                                  false ->
                                      [DelStoneGoods | AccDelStoneListT2];
                                  _ ->
                                      AccDelStoneListT2
                              end
                      end,[],DelStoneListT),
                {DelStoneListT2,UpdateStoneListT}
        end,
    %% 装备属性计算
    StoneGoods2 = StoneGoods#p_goods{
                    current_num = 1,
                    roleid = EquipGoods#p_goods.roleid,
                    embe_pos = EquipGoods#p_goods.stone_num + 1,
                    embe_equipid = EquipGoods#p_goods.id},
    EquipStonesList = 
        case erlang:is_list(EquipGoods#p_goods.stones)  of
            true ->
                EquipGoods#p_goods.stones;
            _ ->
                []
        end,
    EquipGoods2 = EquipGoods#p_goods{
                    stone_num = EquipGoods#p_goods.stone_num + 1,
                    stones = lists:reverse([StoneGoods2|lists:reverse(EquipStonesList)])},
    [StoneBaseInfo] = common_config_dyn:find_stone(StoneGoods#p_goods.typeid),
    [MainPropertyList] = common_config_dyn:find(refining,main_property),
    EquipMainProperty = (StoneBaseInfo#p_stone_base_info.level_prop)#p_property_add.main_property,
    MainPropertySeatList = 
        case lists:keyfind(EquipMainProperty,1,MainPropertyList) of
            false ->
                common_transaction:abort({?_LANG_INLAY_ERROR,0});
            {_,SeatList} ->
                case erlang:is_list(SeatList) of
                    true ->
                        SeatList;
                    false ->
                        [SeatList]
                end
        end,
    EquipPro = 
        lists:foldl(
          fun(MainPropertySeat,AccEquipPro) ->
                  NewPropertyValue = erlang:element(MainPropertySeat, AccEquipPro) 
                      + erlang:element(MainPropertySeat,StoneBaseInfo#p_stone_base_info.level_prop),
                  erlang:setelement(MainPropertySeat, AccEquipPro, NewPropertyValue)
          end,EquipGoods2#p_goods.add_property,MainPropertySeatList),
    EquipGoods3 = EquipGoods2#p_goods{add_property = EquipPro},
    %% 绑定处理，重算精炼系数
    EquipGoods4 = 
        case (EquipGoods3#p_goods.bind =:= false 
              andalso (StoneGoods#p_goods.bind =:= true orelse SymbolGoods#p_goods.bind =:= true)) of
            true ->
                case mod_refining_bind:do_equip_bind_for_inlay(EquipGoods3) of
                    {error,_BindErrorCode} ->
                        EquipGoods3#p_goods{bind = true};
                    {ok,BindGoodsT} ->
                        BindGoodsT
                end;
            false ->
                EquipGoods3
        end,
    EquipGoods5 = 
        case common_misc:do_calculate_equip_refining_index(EquipGoods4) of
            {error,_ErrorIndexCode} ->
                EquipGoods4;
            {ok, EquipGoods4T} ->
                EquipGoods4T
        end,
    mod_bag:update_goods(RoleId,[EquipGoods5]),
    {ok,EquipGoods5,DelList,UpdateList,DelStoneList,UpdateStoneList}.

%% 折卸
do_refining_firing_unload({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_firing_unload2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,EquipGoods,SymbolGoodsList,SymbolNumber,IsUnloadRate,UnloadFee} ->
            do_refining_firing_unload3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                       EquipGoods,SymbolGoodsList,SymbolNumber,IsUnloadRate,UnloadFee)
    end.
do_refining_firing_unload2(RoleId,DataRecord) ->
    #m_refining_firing_tos{firing_list = FiringList} = DataRecord,
    %% 材料是否足够合法
    case (erlang:length(FiringList) >= 1) of
        true ->
            next;
        false ->
            erlang:throw({error,?_LANG_UNLOAD_ERROR,0})
    end,
    %% 检查是否有要折卸宝石的装备
    EquipGoods = 
        case lists:foldl(
               fun(EquipPRefiningT,AccEquipPRefiningT) ->
                       case ( AccEquipPRefiningT =:= undefined
                              andalso EquipPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_TARGET
                              andalso EquipPRefiningT#p_refining.goods_type =:= ?TYPE_EQUIP) of
                           true ->
                               EquipPRefiningT;
                           false ->
                               AccEquipPRefiningT
                       end 
               end,undefined,FiringList) of
            undefined ->
                erlang:throw({error,?_LANG_UNLOAD_NO_EQUIP,0});
            EquipPRefiningTT ->
                case mod_bag:check_inbag(RoleId,EquipPRefiningTT#p_refining.goods_id) of
                    {ok,EquipGoodsT} ->
                        case EquipGoodsT#p_goods.stone_num =:= undefined of
                            true ->
                                EquipGoodsT#p_goods{stone_num = 0};
                            false ->
                                EquipGoodsT
                        end;
                    _  ->
                        erlang:throw({error,?_LANG_UNLOAD_NO_EQUIP,0})
                end
        end,
    [EquipBaseInfo] = common_config_dyn:find_equip(EquipGoods#p_goods.typeid),
    if EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT ->
            erlang:throw({error,?_LANG_UNLOAD_MOUNT_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_FASHION ->
            erlang:throw({error,?_LANG_UNLOAD_FASHION_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_ADORN ->
            erlang:throw({error,?_LANG_UNLOAD_ADORN_ERROR,0});
       true ->
            next
    end,
    [SpecialEquipList] = common_config_dyn:find(refining,special_equip_list),
    case lists:member(EquipGoods#p_goods.typeid,SpecialEquipList) of
        true ->
            erlang:throw({error,?_LANG_UNLOAD_ADORN_ERROR,0});
        _ ->
            next
    end,
    %% 装备是否有宝石
    case (EquipGoods#p_goods.stones =:= undefined orelse EquipGoods#p_goods.stones =:= []) of
        true ->
            erlang:throw({error,?_LANG_UNLOAD_DO_NOT_UNLOAD,0});
        false ->
            next
    end,
    SymbolPRefiningTList = 
        lists:foldl(
          fun(SymbolPRefiningT,AccSymbolPRefiningTList) ->
                  case (SymbolPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL
                        andalso SymbolPRefiningT#p_refining.goods_type =:= ?TYPE_ITEM
                        andalso SymbolPRefiningT#p_refining.goods_type_id =:= ?REFINING_UNLOAD_SYMBOL ) of
                      true ->
                          [SymbolPRefiningT|AccSymbolPRefiningTList];
                      false ->
                          AccSymbolPRefiningTList
                  end
          end,[],FiringList),
    case (erlang:length(SymbolPRefiningTList) + 1) =:= erlang:length(FiringList) of
        true ->
            next;
        false ->
            erlang:throw({error,?_LANG_UNLOAD_HAS_OTHER,0})
    end,
    {SymbolGoodsList,SymbolNumber} = 
        lists:foldl(
          fun(SymbolPRefiningTT,{AccSymbolGoodsList,AccSymbolNumber}) ->
                  case mod_bag:check_inbag(RoleId,SymbolPRefiningTT#p_refining.goods_id) of
                      {ok,SymbolGoodsT} ->
                          {[SymbolGoodsT|AccSymbolGoodsList],AccSymbolNumber + SymbolPRefiningTT#p_refining.goods_number};
                      _  ->
                          erlang:throw({error,?_LANG_UNLOAD_ERROR,0})
                  end
          end,{[],0},SymbolPRefiningTList),
    %% 折卸概率
    IsUnloadRate = 
        if SymbolNumber =:= 4 ->
                true;
           SymbolNumber > 4 ->
                erlang:throw({error,?_LANG_UNLOAD_MAX_SYMBOL,0});
           true ->
                [RandomRateSymbolList] = common_config_dyn:find(refining,random_rate_symbol),
                {_,UnloadRandomRate} = lists:keyfind(SymbolNumber,1,RandomRateSymbolList),
                common_tool:random(1,100) < UnloadRandomRate
        end,
    RefiningFee =#r_refining_fee{type = equip_unload_fee,
                                 equip_level = EquipGoods#p_goods.level,
                                 refining_index = EquipGoods#p_goods.refining_index,
                                 punch_num = format_value(EquipGoods#p_goods.punch_num,1),
                                 stone_num = format_value(EquipGoods#p_goods.stone_num,1),
                                 equip_color = format_value(EquipGoods#p_goods.current_colour,1),
                                 equip_quality = format_value(EquipGoods#p_goods.quality,1)},
    UnloadFee = 
        case mod_refining:get_refining_fee(RefiningFee) of
            {ok,UnloadFeeT} ->
                UnloadFeeT;
            {error,UnloadFeeError} ->
                erlang:throw({error,UnloadFeeError,0})
        end,
    {ok,EquipGoods,SymbolGoodsList,SymbolNumber,IsUnloadRate,UnloadFee}.
do_refining_firing_unload3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                           EquipGoods,SymbolGoodsList,SymbolNumber,IsUnloadRate,UnloadFee) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_firing_unload(RoleId,EquipGoods,SymbolGoodsList,SymbolNumber,IsUnloadRate,UnloadFee)
           end) of
        {atomic,{ok,EquipGoods2,DelList,UpdateList,StoneGoodsList,DelStoneGoodsList}} ->
            do_refining_firing_unload4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                       EquipGoods2,SymbolGoodsList,SymbolNumber,IsUnloadRate,
                                       DelList,UpdateList,StoneGoodsList,DelStoneGoodsList);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_REFINING_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_UNLOAD_ERROR,
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_firing_unload4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                           EquipGoods,SymbolGoodsList,SymbolNumber,IsUnloadRate,
                           DelList,UpdateList,StoneGoodsList,DelStoneGoodsList) ->
    ReasonCode = case IsUnloadRate =:= true of true -> 0; _ -> 1 end,
    SendUpdateList = lists:append([StoneGoodsList,[EquipGoods], UpdateList]),
    SendSelf = #m_refining_firing_toc{
      succ = true,
      reason_code = ReasonCode, %% 折卸成功但宝石降级
      op_type = DataRecord#m_refining_firing_tos.op_type,
      sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
      firing_list = DataRecord#m_refining_firing_tos.firing_list,
      update_list = [EquipGoods|UpdateList],
      del_list = DelList,
      new_list = StoneGoodsList},
    %% 道具变化通知
    catch common_misc:update_goods_notify({line, Line, RoleId},SendUpdateList),
    if DelList =/= [] ->
            catch common_misc:del_goods_notify({line, Line, RoleId},DelList);
       true ->
            next
    end,
    %% 道具消费日志
    if SymbolNumber > 0 ->
            [HSymbolGoods|_TSymbolGoods] = SymbolGoodsList,
            catch common_item_logger:log(RoleId,HSymbolGoods,SymbolNumber,?LOG_ITEM_TYPE_CHAI_XIE_SHI_QU);
       true ->
            next
    end,
    lists:foreach(
      fun(DelStoneGoods) ->
              catch common_item_logger:log(RoleId,DelStoneGoods,1,?LOG_ITEM_TYPE_CHAI_XIE_SHI_QU)
      end,DelStoneGoodsList),
    catch common_item_logger:log(RoleId,EquipGoods,1,?LOG_ITEM_TYPE_CHAI_XIE_HUO_DE),
    lists:foreach(
      fun(AddStoneGoods) ->
              catch common_item_logger:log(RoleId,AddStoneGoods,1,?LOG_ITEM_TYPE_CHAI_XIE_HUO_DE)
      end,StoneGoodsList),
    %% 银子变化通知
    catch mod_refining:do_refining_deduct_fee_notify(RoleId,{line, Line, RoleId}),
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
do_t_refining_firing_unload(RoleId,EquipGoods,SymbolGoodsList,SymbolNumber,IsUnloadRate,UnloadFee) ->
    %% 扣费
    EquipConsume = #r_equip_consume{
      type = unload,consume_type = ?CONSUME_TYPE_SILVER_EQUIP_UNLOAD,consume_desc = ""},
    case catch mod_refining:do_refining_deduct_fee(RoleId,UnloadFee,EquipConsume) of
        {error,UnloadFeeError} ->
            common_transaction:abort({UnloadFeeError,0});
        _ ->
            next
    end,
    %% 扣折卸符
    {DelList,UpdateList} = 
        if SymbolNumber > 0 ->
                case catch mod_equip_build:do_transaction_dedcut_goods(RoleId,SymbolGoodsList,SymbolNumber) of
                    {error,GoodsError} ->
                        common_transaction:abort({GoodsError,0});
                    {ok,DelListT,UpdateListT} ->
                        DelListT2  = 
                            lists:foldl(
                              fun(DelGoods,AccDelListT2) -> 
                                      case lists:keyfind(DelGoods#p_goods.id,#p_goods.id,UpdateListT) of
                                          false ->
                                              [DelGoods | AccDelListT2];
                                          _ ->
                                              AccDelListT2
                                      end
                              end,[],DelListT),
                        {DelListT2,UpdateListT}
                end;
           true ->
                {[],[]}
        end,
    %% 装备宝石处理，装备属性处理
    EquipStoneList = [REquipStone#p_goods{
                        embe_pos = 0,
                        embe_equipid = 0,
                        stone_num = 0} || REquipStone <- EquipGoods#p_goods.stones],
    [MainPropertyList] = common_config_dyn:find(refining,main_property),
    EquipGoods2 = 
        lists:foldl(
          fun(EquipStoneGoods,AccEquipGoods) ->
                  [EquipStoneBaseInfo] = common_config_dyn:find_stone(EquipStoneGoods#p_goods.typeid),
                  EquipMainProperty = (EquipStoneBaseInfo#p_stone_base_info.level_prop)#p_property_add.main_property,
                  MainPropertySeatList = 
                      case lists:keyfind(EquipMainProperty,1,MainPropertyList) of
                          false ->
                              common_transaction:abort({?_LANG_UNLOAD_ERROR,0});
                          {_,SeatList} ->
                              case erlang:is_list(SeatList) of
                                  true ->
                                      SeatList;
                                  false ->
                                      [SeatList]
                              end
                      end,
                  EquipPro = 
                      lists:foldl(
                        fun(MainPropertySeat,AccEquipPro) ->
                                NewPropertyValue = erlang:element(MainPropertySeat, AccEquipPro) 
                                    - erlang:element(MainPropertySeat,EquipStoneBaseInfo#p_stone_base_info.level_prop),
                                erlang:setelement(MainPropertySeat, AccEquipPro, NewPropertyValue)
                        end,AccEquipGoods#p_goods.add_property,MainPropertySeatList),
                  AccEquipGoods#p_goods{add_property = EquipPro}
          end,EquipGoods#p_goods{stone_num=0,stones=[]},EquipStoneList),
    mod_bag:update_goods(RoleId,EquipGoods2),
    %% 生成宝石处理
    StoneGoodsList = 
        case IsUnloadRate of
            true -> %% 正常折卸宝石
                {ok,StoneGoodsListT} = mod_bag:create_goods_by_p_goods(RoleId,EquipStoneList),
                DelStoneGoodsList = [],
                StoneGoodsListT;
            false -> %% 降级折卸宝石
                [StoneLevelLinkList] = common_config_dyn:find(refining,stone_level_link),
                PreStoneCreateInfoList = 
                    lists:foldl(
                      fun(EquipStoneGoods,AccPreStoneCreateInfoList) ->
                              PreStoneTypeId = get_pre_stone_type_id(
                                                 EquipStoneGoods#p_goods.typeid,EquipStoneGoods#p_goods.level,StoneLevelLinkList),
                              case common_config_dyn:find_stone(PreStoneTypeId) of
                                  [PreEquipStoneBaseInfo] ->
                                      [#r_goods_create_info{
                                          type = ?TYPE_STONE,
                                          num=1,type_id = PreEquipStoneBaseInfo#p_stone_base_info.typeid,
                                          bind=EquipStoneGoods#p_goods.bind,
                                          start_time = EquipStoneGoods#p_goods.start_time,
                                          end_time = EquipStoneGoods#p_goods.end_time} | AccPreStoneCreateInfoList];
                                  _ ->
                                      AccPreStoneCreateInfoList
                              end
                      end,[],EquipStoneList),
                StoneGoodsListT = 
                    case PreStoneCreateInfoList =:= [] of
                        true ->
                            [];
                        _ ->
                            {ok,StoneGoodsListTT} = mod_bag:create_goods(RoleId,PreStoneCreateInfoList),
                            StoneGoodsListTT
                    end,
                DelStoneGoodsList = EquipStoneList,
                StoneGoodsListT
        end,
    {ok,EquipGoods2,DelList,UpdateList,StoneGoodsList,DelStoneGoodsList}.

%% 根据当前灵石的typeid查找基本上一级灵石的typeid
%% 查找不到返回 0
get_pre_stone_type_id(TypeId,Level,StoneLevelLinkList) ->
    lists:foldl(
      fun(SubStoneLevelLinkList,AccPreTypeId) ->
              case ( AccPreTypeId =:= -1
                     andalso lists:member(TypeId,SubStoneLevelLinkList) ) of
                  true ->
                      case Level - 1 > 0 of
                          true ->
                              lists:nth(Level - 1,SubStoneLevelLinkList);
                          false ->
                              0
                      end;
                  false->
                      AccPreTypeId
              end
      end,-1,StoneLevelLinkList).
%% 强化
do_refining_firing_reinforce({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_firing_reinforce2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,EquipGoods,ReinforceStuffGoodsList,ReinforceStuffLevel,ReinforceFee,NewReinforceResult,ReinforceStuffNeedNum} ->
            do_refining_firing_reinforce3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                          EquipGoods,ReinforceStuffGoodsList,ReinforceStuffLevel,
                                          ReinforceFee,NewReinforceResult,ReinforceStuffNeedNum)
    end.
do_refining_firing_reinforce2(RoleId,DataRecord) ->
    #m_refining_firing_tos{firing_list = FiringList} = DataRecord,
    %% 材料是否足够合法
    case (erlang:length(FiringList) >= 2) of
        true ->
            next;
        false ->
            erlang:throw({error,?_LANG_REINFORCE_PLACED,0})
    end,
    %% 检查是否有要强化的装备
    EquipGoods = 
        case lists:foldl(
               fun(EquipPRefiningT,AccEquipPRefiningT) ->
                       case ( AccEquipPRefiningT =:= undefined
                              andalso EquipPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_TARGET
                              andalso EquipPRefiningT#p_refining.goods_type =:= ?TYPE_EQUIP) of
                           true ->
                               EquipPRefiningT;
                           false ->
                               AccEquipPRefiningT
                       end 
               end,undefined,FiringList) of
            undefined ->
                erlang:throw({error,?_LANG_REINFORCE_CAN_NOT_MANY_EQUIP,0});
            EquipPRefiningTT ->
                case mod_bag:check_inbag(RoleId,EquipPRefiningTT#p_refining.goods_id) of
                    {ok,EquipGoodsT} ->
                        EquipGoodsT;
                    _  ->
                        erlang:throw({error,?_LANG_REINFORCE_CAN_NOT_MANY_EQUIP,0})
                end
        end,
    [EquipBaseInfo] = common_config_dyn:find_equip(EquipGoods#p_goods.typeid),
    if EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT ->
            erlang:throw({error,?_LANG_REINFORCE_MOUNT_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_FASHION ->
            erlang:throw({error,?_LANG_REINFORCE_FASHION_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_ADORN ->
            erlang:throw({error,?_LANG_REINFORCE_ADORN_ERROR,0});
       true ->
            next
    end,
    [SpecialEquipList] = common_config_dyn:find(refining,special_equip_list),
    case lists:member(EquipGoods#p_goods.typeid,SpecialEquipList) of
        true ->
            erlang:throw({error,?_LANG_REINFORCE_ADORN_ERROR,0});
        _ ->
            next
    end,
    EquipReinforceLevel = EquipGoods#p_goods.reinforce_result div 10,
    EquipReinforceGrade = EquipGoods#p_goods.reinforce_result rem 10,
    case (EquipReinforceLevel =:= ?REINFORCE_MAX_LEVEL andalso EquipReinforceGrade =:= ?REINFORCE_MAX_GRADE) of
        true ->
            erlang:throw({error,?_LANG_REINFORCE_NO_UPGRADE,0});
        _ ->
            next
    end,
    %% 查找出当前强化装备需要的材料配置
    [ReinforceStuffLevelList] = common_config_dyn:find(refining,reinforce_stuff),
    case EquipReinforceLevel =:= 0 of
        true ->
            ParamEquipReinforceLevel = 1;
        _ ->
            ParamEquipReinforceLevel = EquipReinforceLevel
    end,
    case EquipReinforceGrade =:= ?REINFORCE_MAX_GRADE of
        true ->
            {ReinforceStuffTypeId,ReinforceStuffLevel,ReinforceStuffNeedNum} = lists:keyfind(ParamEquipReinforceLevel + 1,2,ReinforceStuffLevelList);
        _ ->
            {ReinforceStuffTypeId,ReinforceStuffLevel,ReinforceStuffNeedNum} = lists:keyfind(ParamEquipReinforceLevel,2,ReinforceStuffLevelList)
    end,
    %% 检查是否有强化材料
    {ReinforceStuffGoodsList,ReinforceStuffGoodsNumber} = 
        lists:foldl(
          fun(ReinforceStuffPRefiningT,{AccReinforceStuffGoodsList,AccReinforceStuffGoodsNumber}) ->
                  case ReinforceStuffPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL
                      andalso ReinforceStuffPRefiningT#p_refining.goods_type =:= ?TYPE_ITEM
                      andalso ReinforceStuffPRefiningT#p_refining.goods_type_id =:= ReinforceStuffTypeId of
                      true ->
                          case mod_bag:check_inbag(RoleId,ReinforceStuffPRefiningT#p_refining.goods_id) of
                              {ok,ReinforceStuffGoodsT} ->
                                  {[ReinforceStuffGoodsT|AccReinforceStuffGoodsList],
                                   AccReinforceStuffGoodsNumber + ReinforceStuffPRefiningT#p_refining.goods_number};
                              _ ->
                                  erlang:throw({error,?_LANG_REINFORCE_CAN_NOT_STUFF,0})
                          end;                           
                      false ->
                          {AccReinforceStuffGoodsList,AccReinforceStuffGoodsNumber}
                  end
          end,{[],0},FiringList),
    [ReinforceStuffBaseInfo] = common_config_dyn:find_item(ReinforceStuffTypeId),
    case ReinforceStuffGoodsList =:= [] 
        orelse (erlang:length(ReinforceStuffGoodsList) =/= erlang:length(FiringList) - 1)
        orelse ReinforceStuffNeedNum =/= ReinforceStuffGoodsNumber of
        true ->
            erlang:throw({error,
                          common_tool:get_format_lang_resources(
                            ?_LANG_REINFORCE_STUFF_ERROR,[ReinforceStuffNeedNum,ReinforceStuffBaseInfo#p_item_base_info.itemname]),
                          0});
        _ ->
            next
    end,
    %% 计算本次强化可获得的效果
    NewReinforceResult = ReinforceStuffLevel * 10 + mod_refining:get_equip_reinforce_new_grade(EquipGoods,ReinforceStuffLevel),
    RefiningFee =#r_refining_fee{type = equip_reinforce_fee,
                                 equip_level = EquipGoods#p_goods.level,
                                 material_level = ReinforceStuffLevel,
                                 refining_index = EquipGoods#p_goods.refining_index,
                                 punch_num = format_value(EquipGoods#p_goods.punch_num,1),
                                 stone_num = format_value(EquipGoods#p_goods.stone_num,1),
                                 equip_color = format_value(EquipGoods#p_goods.current_colour,1),
                                 equip_quality = format_value(EquipGoods#p_goods.quality,1)},
    ReinforceFee = 
        case mod_refining:get_refining_fee(RefiningFee) of
            {ok,ReinforceFeeT} ->
                ReinforceFeeT;
            {error,ReinforceFeeError} ->
                erlang:throw({error,ReinforceFeeError,0})
        end,
    {ok,EquipGoods,ReinforceStuffGoodsList,ReinforceStuffLevel,ReinforceFee,NewReinforceResult,ReinforceStuffNeedNum}.

do_refining_firing_reinforce3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                              EquipGoods,ReinforceStuffGoodsList,ReinforceStuffLevel,
                              ReinforceFee,NewReinforceResult,ReinforceStuffNeedNum) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_firing_reinforce(RoleId,EquipGoods,ReinforceStuffGoodsList,ReinforceStuffLevel,
                                                  ReinforceFee,NewReinforceResult,ReinforceStuffNeedNum)
           end) of
        {atomic,{ok,EquipGoods2,DelList,UpdateList}} ->
            do_refining_firing_reinforce4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                          EquipGoods,EquipGoods2,DelList,UpdateList,
                                          ReinforceStuffGoodsList,ReinforceStuffNeedNum);
        {aborted, Error} ->
            ?DEBUG("Error=~w",[Error]),
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_REFINING_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_REINFORCE_ERROR,
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_firing_reinforce4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                              OldEquipGoods,NewEquipGoods,DelList,UpdateList,
                              ReinforceStuffGoodsList,ReinforceStuffNeedNum) ->
    SendSelf = 
        case OldEquipGoods#p_goods.reinforce_result >= NewEquipGoods#p_goods.reinforce_result of
            true ->
                #m_refining_firing_toc{
              succ = true,
              reason = ?_LANG_REINFORCE_USED_PROTECT, %% 星级不变
              reason_code = 1,
              op_type = DataRecord#m_refining_firing_tos.op_type,
              sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
              firing_list = DataRecord#m_refining_firing_tos.firing_list,
              update_list = [NewEquipGoods| UpdateList],
              del_list = DelList,
              new_list = []};
            false ->
                ReinforceLevel = NewEquipGoods#p_goods.reinforce_result div 10,
                ReinforceGrade = NewEquipGoods#p_goods.reinforce_result rem 10,
                SuccReason = common_tool:get_format_lang_resources(?_LANG_REINFORCE_SUCC,[NewEquipGoods#p_goods.name,ReinforceLevel,ReinforceGrade]),
                #m_refining_firing_toc{ succ = true, %% 星级提升
                                        reason = SuccReason,
                                        reason_code = 0,
                                        op_type = DataRecord#m_refining_firing_tos.op_type,
                                        sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
                                        firing_list = DataRecord#m_refining_firing_tos.firing_list,
                                        update_list = [NewEquipGoods| UpdateList],
                                        del_list = DelList,
                                        new_list = []}
        end,
    %% 道具变化通知
    catch common_misc:update_goods_notify({line, Line, RoleId},[NewEquipGoods| UpdateList]),
    if DelList =/= [] ->
            catch common_misc:del_goods_notify({line, Line, RoleId},DelList);
       true ->
            next
    end,
    %% 银子变化通知
    catch mod_refining:do_refining_deduct_fee_notify(RoleId,{line, Line, RoleId}),
    %% 道具消费日志
    [ReinforceStuffGoods|_TReinforceStuffGoods] =ReinforceStuffGoodsList,
    catch common_item_logger:log(RoleId,ReinforceStuffGoods,ReinforceStuffNeedNum,?LOG_ITEM_TYPE_QIANG_HUA_SHI_QU),
    catch common_item_logger:log(RoleId,NewEquipGoods,1,?LOG_ITEM_TYPE_QIANG_HUA_HUO_DE),
    
    %% 成就 add by caochuncheng 2011-03-07
    [#p_equip_base_info{slot_num = SlotNum}]=common_config_dyn:find_equip(NewEquipGoods#p_goods.typeid),
    AchEventIdList = 
        if NewEquipGoods#p_goods.reinforce_result >= 66 ->
                if SlotNum =:= 1 ->
                        [304002,304004,304003];
                   true ->
                        [304002,304004]
                end;
           NewEquipGoods#p_goods.reinforce_result >= 40 ->
                if SlotNum =:= 1 ->
                        [304002,304003];
                   true ->
                        [304002]
                end;
           true ->
                [304002]
        end,
    catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = AchEventIdList}),
    %% 特殊任务事件
    ?TRY_CATCH(hook_mission_event:hook_special_event(RoleId,?MISSON_EVENT_REINFORCE),MissionEventErr),
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.

do_t_refining_firing_reinforce(RoleId,EquipGoods,ReinforceStuffGoodsList,_ReinforceStuffLevel,
                               ReinforceFee,NewReinforceResult,ReinforceStuffNeedNum) ->
    %% 扣费
    EquipConsume = #r_equip_consume{
      type = reinforce,consume_type = ?CONSUME_TYPE_SILVER_EQUIP_REINFORCE,consume_desc = ""},
    case catch mod_refining:do_refining_deduct_fee(RoleId,ReinforceFee,EquipConsume) of
        {error,ReinforceFeeError} ->
            common_transaction:abort({ReinforceFeeError,0});
        _ ->
            next
    end,
    %% 扣强化材料
    {DelList,UpdateList} = 
        case catch mod_equip_build:do_transaction_dedcut_goods(RoleId,ReinforceStuffGoodsList,ReinforceStuffNeedNum) of
            {error,GoodsError} ->
                common_transaction:abort({GoodsError,0});
            {ok,DelListT,UpdateListT} ->
                DelListT2  = 
                    lists:foldl(
                      fun(DelGoods,AccDelListT2) -> 
                              case lists:keyfind(DelGoods#p_goods.id,#p_goods.id,UpdateListT) of
                                  false ->
                                      [DelGoods | AccDelListT2];
                                  _ ->
                                      AccDelListT2
                              end
                      end,[],DelListT),
                {DelListT2,UpdateListT}
        end,
    %% 要所获得的新的强化结果处理装备属性
    EquipGoods2 = 
        case EquipGoods#p_goods.bind =/= true 
            andalso lists:member(true,[ReinforceStuffGoods#p_goods.bind || ReinforceStuffGoods <- ReinforceStuffGoodsList]) of
            true ->
                case mod_refining_bind:do_equip_bind_for_reinforce(EquipGoods) of
                    {error,_IndexErrorCode} ->
                        EquipGoods#p_goods{bind=true};
                    {ok,BindGoods} ->
                        BindGoods
                end;
            _ ->
                EquipGoods
        end, 
    case EquipGoods2#p_goods.reinforce_result >= NewReinforceResult of
        true ->
            mod_bag:update_goods(RoleId,EquipGoods2),
            {ok,EquipGoods2,DelList,UpdateList};
        false ->
            do_t_refining_firing_reinforce2(RoleId,EquipGoods2,NewReinforceResult,DelList,UpdateList)
    end.
do_t_refining_firing_reinforce2(RoleId,EquipGoods,NewReinforceResult,DelList,UpdateList) ->
    OldReinforceResult = EquipGoods#p_goods.reinforce_result,
    EquipGoods2 = 
        if erlang:is_list(EquipGoods#p_goods.reinforce_result_list) 
           andalso erlang:is_integer(OldReinforceResult) ->
                EquipGoods#p_goods{reinforce_result = NewReinforceResult,
                                  reinforce_result_list = [OldReinforceResult|EquipGoods#p_goods.reinforce_result_list]};
           erlang:is_integer(OldReinforceResult) ->
                EquipGoods#p_goods{reinforce_result = NewReinforceResult,
                                   reinforce_result_list = [OldReinforceResult]};
           true ->
                EquipGoods#p_goods{reinforce_result = NewReinforceResult,
                                   reinforce_result_list = []}
        end,
    [ReinforceRateList]=common_config_dyn:find(refining,reinforce_rate),
    OldReinforceLevel = OldReinforceResult div 10,
    OldReinforceGrade = OldReinforceResult rem 10,
    OldReinforceRate = EquipGoods#p_goods.reinforce_rate,
    {_,OldReinforceGradeRate} = lists:keyfind({OldReinforceLevel,OldReinforceGrade},1,ReinforceRateList),
    NewReinforceLevel = NewReinforceResult div 10,
    NewReinforceGrade = NewReinforceResult rem 10,
    {_,NewReinforceGradeRate} = lists:keyfind({NewReinforceLevel,NewReinforceGrade},1,ReinforceRateList),
    [EquipBaseInfo] = common_config_dyn:find_equip(EquipGoods2#p_goods.typeid),
    EquipMainProperty = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.main_property,
    EquipGoods3 = 
        case (OldReinforceRate =:= 0 orelse OldReinforceRate =:= undefined) of
            true ->
                NewEquipPro=mod_refining:change_main_property(
                              EquipMainProperty,EquipGoods2#p_goods.add_property,
                              EquipBaseInfo#p_equip_base_info.property,0,NewReinforceGradeRate),
                EquipGoods2#p_goods{reinforce_rate = NewReinforceGradeRate,add_property = NewEquipPro};
            _ ->
                NewEquipPro=mod_refining:change_main_property(
                              EquipMainProperty,EquipGoods2#p_goods.add_property,
                              EquipBaseInfo#p_equip_base_info.property,OldReinforceGradeRate,NewReinforceGradeRate),
                EquipGoods2#p_goods{reinforce_rate = NewReinforceGradeRate,add_property = NewEquipPro}
        end,
    EquipGoods4 = 
        case common_misc:do_calculate_equip_refining_index(EquipGoods3) of
            {error,_IndexError} ->
                EquipGoods3;
            {ok,IndexGoods} ->
                IndexGoods
        end,
    mod_bag:update_goods(RoleId,EquipGoods4),
    {ok,EquipGoods4,DelList,UpdateList}.


%% 合成 
do_refining_firing_compose({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_firing_compose2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,GoodsList,NextGoodsTypeId,NextGoodsType,PRefiningNumber,GoodsSumNumber,GoodsNotBindNumber,GoodsBindNumber} ->
            do_refining_firing_compose3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                        GoodsList,NextGoodsTypeId,NextGoodsType,PRefiningNumber,
                                        GoodsSumNumber,GoodsNotBindNumber,GoodsBindNumber)
    end.
do_refining_firing_compose2(RoleId,DataRecord) ->
    #m_refining_firing_tos{firing_list = FiringList,sub_op_type = SubOpType} = DataRecord,
    case (SubOpType =:= ?FIRING_OP_TYPE_COMPOSE_3 
          orelse SubOpType =:= ?FIRING_OP_TYPE_COMPOSE_4
          orelse SubOpType =:= ?FIRING_OP_TYPE_COMPOSE_5) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_COMPOSE_ERROR_TYPE,0})
    end,
    case erlang:length(FiringList) > 0 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_COMPOSE_NO_GOODS,0})
    end,
    %% 检查参数是否是同一材料
    {GoodsPRefiningTList,PRefiningNumber} = 
        case 
            lists:foldl(
              fun(GoodsPRefiningT,{AccPRefiningTypeId,AccPRefiningNumber,AccGoodsPRefiningTList}) ->
                      case AccPRefiningTypeId =:= 0 of
                          true ->
                              AccPRefiningTypeId2 = GoodsPRefiningT#p_refining.goods_type_id;
                          false ->
                              AccPRefiningTypeId2 = AccPRefiningTypeId
                      end,
                      case common_config_dyn:find(compose,AccPRefiningTypeId2) of
                          [NextGoodsTypeIdT] ->
                              NextGoodsTypeIdT;
                          _ ->
                              erlang:throw({error, ?_LANG_COMPOSE_CANT_COMPOSE,0})
                      end,
                      case (GoodsPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL
                            andalso AccPRefiningTypeId2 =:= GoodsPRefiningT#p_refining.goods_type_id) of
                          true ->
                              AccPRefiningNumber2 = AccPRefiningNumber + GoodsPRefiningT#p_refining.goods_number,
                              {AccPRefiningTypeId2,AccPRefiningNumber2,[GoodsPRefiningT|AccGoodsPRefiningTList]};
                          false ->
                              {AccPRefiningTypeId2,AccPRefiningNumber,AccGoodsPRefiningTList}
                      end
              end,{0,0,[]},FiringList) of
            {_AccPRefiningTypeId,PRefiningNumberT,GoodsPRefiningTListT} ->
                {GoodsPRefiningTListT,PRefiningNumberT};
            _ ->
                erlang:throw({error,?_LANG_COMPOSE_MORE_THAN_ONE_KIND,0})
        end,
    case (erlang:length(GoodsPRefiningTList) =:= erlang:length(FiringList)) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_COMPOSE_MORE_THAN_ONE_KIND,0})
    end,
    case (SubOpType =:= ?FIRING_OP_TYPE_COMPOSE_3  andalso PRefiningNumber >= ?FIRING_OP_TYPE_COMPOSE_3)
        orelse (SubOpType =:= ?FIRING_OP_TYPE_COMPOSE_4  andalso PRefiningNumber >= ?FIRING_OP_TYPE_COMPOSE_4)
        orelse (SubOpType =:= ?FIRING_OP_TYPE_COMPOSE_5  andalso PRefiningNumber >= ?FIRING_OP_TYPE_COMPOSE_5) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_COMPOSE_NOT_ENOUGH_NUM,0})
    end,
    {GoodsList,GoodsBindNumber,GoodsNotBindNumber} = 
        lists:foldl(
          fun(GoodsPRefiningTT,{AccGoodsList,AccGoodsBindNumber,AccGoodsNotBindNumber}) ->
                  case mod_bag:check_inbag(RoleId,GoodsPRefiningTT#p_refining.goods_id) of
                      {ok,GoodsT} ->
                          case GoodsT#p_goods.bind of
                              true ->
                                  AccGoodsBindNumber2 = AccGoodsBindNumber + GoodsPRefiningTT#p_refining.goods_number,
                                  AccGoodsNotBindNumber2 = AccGoodsNotBindNumber;
                              false ->
                                  AccGoodsBindNumber2 = AccGoodsBindNumber,
                                  AccGoodsNotBindNumber2 = AccGoodsNotBindNumber + GoodsPRefiningTT#p_refining.goods_number
                          end,
                          {[GoodsT|AccGoodsList],AccGoodsBindNumber2,AccGoodsNotBindNumber2};
                      _ ->
                          erlang:throw({error,?_LANG_COMPOSE_GOODS_NUMBER_DIFF,0})
                  end
          end,{[],0,0},GoodsPRefiningTList),
    GoodsSumNumber = lists:sum([GoodsRecord#p_goods.current_num  || GoodsRecord <-  GoodsList]),
    case GoodsSumNumber >= PRefiningNumber of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_COMPOSE_GOODS_NUMBER_DIFF,0})
    end,
    [HGoods|_TGoods] = GoodsList,
    %% 生成材料的类型
    [NextGoodsTypeId] = common_config_dyn:find(compose,HGoods#p_goods.typeid),
    NextGoodsType = 
        case common_config_dyn:find_item(NextGoodsTypeId) of
            [_NextGoodsItemBaseInfo] ->
                ?TYPE_ITEM;
            _ ->
                case common_config_dyn:find_stone(NextGoodsTypeId) of
                    [_NextGoodsStoneBaseInfo] ->
                        ?TYPE_STONE;
                    _ ->
                        erlang:throw({error,?_LANG_COMPOSE_CANT_COMPOSE,0})
                end
        end,
    {ok,GoodsList,NextGoodsTypeId,NextGoodsType,PRefiningNumber,GoodsSumNumber,GoodsNotBindNumber,GoodsBindNumber}.
%% 根据合成的的类型计算生成的新的物品
get_goods_compose(TotalNumber,NotBindNumber,BindNumber,ComposeType) ->
    %% 根据合成的的类型计算生成的新的物品
    %% 剩下的物品数量 不绑定和绑定 RestNotBindNumber,RestBindNumber
    %% 实际使用的物品数量 不绑定和绑定 DelNotBindNumber,DelBindNumber
    {RestNotBindNumber, RestBindNumber, DelNotBindNumber, DelBindNumber} = 
        case TotalNumber rem ComposeType of
            0 ->
                {0, 0, NotBindNumber, BindNumber};
            Mod ->
                case BindNumber > TotalNumber  - Mod of
                    false ->
                        {Mod, 0, TotalNumber - BindNumber - Mod, BindNumber};
                    true ->
                        {TotalNumber - BindNumber, BindNumber - (TotalNumber - Mod),0,TotalNumber - Mod}
                end
        end,
    %% 实际合成的物品的不绑定和绑定 GoodsNotBindNumber2,GoodsBindNumber2
    GoodsNotBindNumber = DelNotBindNumber div ComposeType,
    GoodsBindNumber = ((DelNotBindNumber rem ComposeType)  + DelBindNumber) div ComposeType,
    GoodsNotBindNumber2 = 
        lists:foldl(
          fun(_NotBindIndex,AccGoodsNotBindNumber2) -> 
                  case is_goods_compose_success(ComposeType) of
                      true ->
                          AccGoodsNotBindNumber2 + 1;
                      _ ->
                          AccGoodsNotBindNumber2
                  end
          end,0,lists:seq(1,GoodsNotBindNumber,1)),
    GoodsBindNumber2 = 
        lists:foldl(
          fun(_BindIndex,AccGoodsBindNumber2) ->
                  case is_goods_compose_success(ComposeType) of
                      true ->
                          AccGoodsBindNumber2 + 1;
                      _ ->
                          AccGoodsBindNumber2
                  end
          end,0,lists:seq(1,GoodsBindNumber,1)),
    ?DEV("RestNotBindNumber=~w,RestBindNumber=~w,DelNotBindNumber=~w,DelBindNumber=~w,GoodsNotBindNumber=~w,GoodsBindNumber=~w",
           [RestNotBindNumber, RestBindNumber, DelNotBindNumber, DelBindNumber,GoodsNotBindNumber2,GoodsBindNumber2]),
    {ok,RestNotBindNumber, RestBindNumber, DelNotBindNumber, DelBindNumber,GoodsNotBindNumber2,GoodsBindNumber2}.
%% 根据合成的类型计算单次合成的概率
%% 返回 true or false
is_goods_compose_success(ComposeType) ->
    case ComposeType of
        ?FIRING_OP_TYPE_COMPOSE_5 ->
            true;
        ?FIRING_OP_TYPE_COMPOSE_4 ->
            random:uniform(100) =< 75;
        ?FIRING_OP_TYPE_COMPOSE_3 ->
            random:uniform(100) =< 50;
        _ ->
            false
    end.
do_refining_firing_compose3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                            GoodsList,NextGoodsTypeId,NextGoodsType,PRefiningNumber,
                            GoodsSumNumber,GoodsNotBindNumber,GoodsBindNumber) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_firing_compose(RoleId,DataRecord,GoodsList,NextGoodsTypeId,NextGoodsType,
                                                PRefiningNumber,GoodsSumNumber,GoodsNotBindNumber,GoodsBindNumber)
           end) of
        {atomic,{ok,OldNotBindGoodsList,OldBindGoodsList,NewNotBindGoodsList,NewBindGoodsList,
                 OldNotBindNumber,OldBindNumber,NewNotBindNumber,NewBindNumber,DelGoodsNumber}} ->
            do_refining_firing_compose4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                        GoodsList,NextGoodsTypeId,PRefiningNumber,
                                        OldNotBindGoodsList,OldBindGoodsList,NewNotBindGoodsList,NewBindGoodsList,
                                        OldNotBindNumber,OldBindNumber,NewNotBindNumber,NewBindNumber,DelGoodsNumber);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_REFINING_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_COMPOSE_ERROR,
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_firing_compose4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                            GoodsList, NextGoodsTypeId,PRefiningNumber,
                            OldNotBindGoodsList,OldBindGoodsList,NewNotBindGoodsList,NewBindGoodsList,
                            OldNotBindNumber,OldBindNumber,NewNotBindNumber,NewBindNumber,DelGoodsNumber) ->
    
    case NewNotBindGoodsList=:= [] andalso NewBindGoodsList =:= [] of
        true ->
            Reason = ?_LANG_COMPOSE_COMPOSE_ERROR,
            ReasonCode = 1,
            NewCreateList = [];
        _ ->
            NewNextGoods = lists:keyfind(NextGoodsTypeId,#p_goods.typeid,lists:append([NewNotBindGoodsList,NewBindGoodsList])),
            NewNextGoodsName = common_goods:get_notify_goods_name(NewNextGoods#p_goods{current_num = NewNotBindNumber + NewBindNumber}),
            Reason = common_tool:get_format_lang_resources(?_LANG_COMPOSE_COMPOSE_SUCC,[NewNextGoodsName]), 
            ReasonCode = 0,
            NewCreateList = [NewNextGoods#p_goods{current_num = NewNotBindNumber + NewBindNumber}]
    end,
    case (OldNotBindGoodsList =/= [] orelse OldBindGoodsList =/= []) andalso (PRefiningNumber - DelGoodsNumber) > 0 of
        true ->
            [OldCreateGoods|_TOldCreateGoods] = lists:append([OldNotBindGoodsList,OldBindGoodsList]),
            OldCreateList = [OldCreateGoods#p_goods{current_num = PRefiningNumber - DelGoodsNumber}];
        _ ->
            OldCreateList = []
    end,
            
    NewList = lists:append([OldNotBindGoodsList,OldBindGoodsList,NewNotBindGoodsList,NewBindGoodsList]),
    SendSelf = #m_refining_firing_toc{
      succ = true,
      reason = Reason,
      reason_code = ReasonCode,
      op_type = DataRecord#m_refining_firing_tos.op_type,
      sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
      firing_list = DataRecord#m_refining_firing_tos.firing_list,
      update_list = [],
      del_list = GoodsList,
      new_list = lists:append([OldCreateList,NewCreateList])},
    %% 道具变化通知
    if NewList =/= [] ->
            catch common_misc:update_goods_notify({line, Line, RoleId},NewList);
       true ->
            ignore
    end,
    if GoodsList =/= [] ->
            catch common_misc:del_goods_notify({line, Line, RoleId},GoodsList);
       true ->
            next
    end,
    %% 成就 add by caochuncheng 2011-03-07
    case NewNotBindGoodsList=:= [] andalso NewBindGoodsList =:= [] of
        true ->
            catch hook_refining_compose:hook({RoleId,NextGoodsTypeId});
        _ ->
            next
    end,
    %% 道具消费日志
    lists:foreach(
      fun(OldGoods) ->
              catch common_item_logger:log(RoleId,OldGoods,?LOG_ITEM_TYPE_HE_CHENG_SHI_QU)
      end,GoodsList),
    case NewNotBindGoodsList=:= [] andalso NewBindGoodsList =:= [] of
        true ->
            ignore;
        _ ->
            [NewNextGoodsLog|_TNewNextGoodsLog] = lists:append([NewNotBindGoodsList,NewBindGoodsList]),
            catch common_item_logger:log(RoleId,NewNextGoodsLog,NewNotBindNumber + NewBindNumber,?LOG_ITEM_TYPE_HE_CHENG_HUO_DE)
    end,
    case OldNotBindGoodsList =:= [] andalso OldBindGoodsList =:= [] of
        true ->
            ignore;
        _ ->
            [OldGoodsLog|_TOldGoodsLog] = lists:append([OldNotBindGoodsList,OldBindGoodsList]),
            catch common_item_logger:log(RoleId,OldGoodsLog,OldNotBindNumber + OldBindNumber,?LOG_ITEM_TYPE_HE_CHENG_HUO_DE)
    end,
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
do_t_refining_firing_compose(RoleId,DataRecord,GoodsList,NextGoodsTypeId,NextGoodsType,
                             PRefiningNumber, _GoodsSumNumber,GoodsNotBindNumber,GoodsBindNumber) ->
    #m_refining_firing_tos{sub_op_type = SubOpType} = DataRecord,
    %% 计算本居合成想关的材料数量
    %% 剩余的不绑定和绑定，删除的不绑定和绑定，合成的不绑定和绑定
    {ok,_RestNotBindNumber,_RestBindNumber,DelNotBindNumber,DelBindNumber,NewNotBindNumber,NewBindNumber} = 
        get_goods_compose(PRefiningNumber,GoodsNotBindNumber,GoodsBindNumber,SubOpType),
    %% 删除材料
    [HGoods|_TGoods] = GoodsList,
    {DelGoodsNotBindNumber,DelGoodsBindNumber} = 
        lists:foldl(
          fun(OldGoods,{AccDelGoodsNotBindNumber,AccDelGoodsBindNumber}) ->
                  case OldGoods#p_goods.bind of
                      true ->
                          {AccDelGoodsNotBindNumber,AccDelGoodsBindNumber + OldGoods#p_goods.current_num};
                      _ ->
                          {AccDelGoodsNotBindNumber + OldGoods#p_goods.current_num,AccDelGoodsBindNumber}
                  end
          end,{0,0},GoodsList),
    mod_bag:delete_goods(RoleId,[OldGoodsId || #p_goods{id = OldGoodsId} <- GoodsList]),
    {OldNotBindGoodsList,OldNotBindNumber} = 
        case  DelGoodsNotBindNumber - DelNotBindNumber > 0 of
            true ->
                OldNotBindCreateInfo = #r_goods_create_info{
                  type = HGoods#p_goods.type,type_id = HGoods#p_goods.typeid,num = DelGoodsNotBindNumber - DelNotBindNumber,
                  bind = false},
                {ok,OldNotBindGoodsListT} = mod_bag:create_goods(RoleId,OldNotBindCreateInfo),
                {OldNotBindGoodsListT,DelGoodsNotBindNumber - DelNotBindNumber};
            false ->
                {[],0}
        end,
    {OldBindGoodsList,OldBindNumber} = 
        case  DelGoodsBindNumber - DelBindNumber > 0 of
            true ->
                OldBindCreateInfo = #r_goods_create_info{
                  type = HGoods#p_goods.type,type_id = HGoods#p_goods.typeid,num = DelGoodsBindNumber - DelBindNumber,
                  bind = true},
                {ok,OldBindGoodsListT} = mod_bag:create_goods(RoleId,OldBindCreateInfo),
                {OldBindGoodsListT,DelGoodsBindNumber - DelBindNumber};
            false ->
                {[],0}
        end,
    %% 生成合成材料
    NewNotBindGoodsList = 
        case NewNotBindNumber > 0 of
            true ->
                NewNotBindCreateInfo = #r_goods_create_info{
                  type = NextGoodsType,type_id = NextGoodsTypeId,num = NewNotBindNumber,bind = false},
                {ok,NewNotBindGoodsListT} = mod_bag:create_goods(RoleId,NewNotBindCreateInfo),
                NewNotBindGoodsListT;
            false ->
                []
        end,
    NewBindGoodsList = 
        case NewBindNumber > 0 of
            true ->
                NewBindGreateInfo = #r_goods_create_info{
                  type = NextGoodsType,type_id = NextGoodsTypeId,num = NewBindNumber,bind = true},
                {ok,NewBindGoodsListT} = mod_bag:create_goods(RoleId,NewBindGreateInfo),
                NewBindGoodsListT;
            false ->
                []
        end,
    {ok,OldNotBindGoodsList,OldBindGoodsList,NewNotBindGoodsList,NewBindGoodsList,
     OldNotBindNumber,OldBindNumber,NewNotBindNumber,NewBindNumber,DelNotBindNumber + DelBindNumber}.
%% 附加
do_refining_firing_addprop({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_firing_addprop2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,EquipGoods,BindGoods,BindItemRecord,AddPropFee} ->
            do_refining_firing_addprop3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                        EquipGoods,BindGoods,BindItemRecord,AddPropFee)
    end.
do_refining_firing_addprop2(RoleId,DataRecord) ->
    #m_refining_firing_tos{firing_list = FiringList,sub_op_type = SubOpType } = DataRecord,
    case SubOpType =:= ?EQUIP_BIND_TYPE_FIRST
        orelse SubOpType =:= ?EQUIP_BIND_TYPE_REBIND of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_EQUIP_BIND_TYPE_ERROR,0})
    end,
    %% 材料是否足够合法
    case (erlang:length(FiringList) =:= 2) of
        true ->
            next;
        false ->
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ERROR,0})
    end,
    %% 检查是否有要开孔的装备
    EquipGoods = 
        case lists:foldl(
               fun(EquipPRefiningT,AccEquipPRefiningT) ->
                       case ( AccEquipPRefiningT =:= undefined
                              andalso EquipPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_TARGET
                              andalso EquipPRefiningT#p_refining.goods_type =:= ?TYPE_EQUIP) of
                           true ->
                               EquipPRefiningT;
                           false ->
                               AccEquipPRefiningT
                       end 
               end,undefined,FiringList) of
            undefined ->
                erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_ID_ERROR,0});
            EquipPRefiningTT ->
                case mod_bag:check_inbag(RoleId,EquipPRefiningTT#p_refining.goods_id) of
                    {ok,EquipGoodsT} ->
                        EquipGoodsT;
                    _  ->
                        erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_ID_ERROR,0})
                end
        end,
    [EquipBaseInfo] = common_config_dyn:find_equip(EquipGoods#p_goods.typeid),
    if EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT ->
            erlang:throw({error,?_LANG_EQUIP_BIND_MOUNT_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_FASHION ->
            erlang:throw({error,?_LANG_EQUIP_BIND_FASHION_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_ADORN ->
            erlang:throw({error,?_LANG_EQUIP_BIND_ADORN_ERROR,0});
       true ->
            next
    end,
    [SpecialEquipList] = common_config_dyn:find(refining,special_equip_list),
    case lists:member(EquipGoods#p_goods.typeid,SpecialEquipList) of
        true ->
            erlang:throw({error,?_LANG_EQUIP_BIND_ADORN_ERROR,0});
        _ ->
            next
    end,
    %% 检查是否有绑定材料
    BindGoods = 
        case lists:foldl(
               fun(BindPRefiningT,AccBindPRefiningT) ->
                       case ( AccBindPRefiningT =:= undefined
                              andalso BindPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL) of
                           true ->
                               BindPRefiningT;
                           false ->
                               AccBindPRefiningT
                       end
               end,undefined,FiringList) of
            undefined ->
                erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ERROR,0});
            BindPRefiningTT ->
                case mod_bag:check_inbag(RoleId,BindPRefiningTT#p_refining.goods_id) of
                    {ok,BindGoodsT} ->
                        BindGoodsT;
                    _  ->
                        erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ERROR,0})
                end
        end,
    [BindEquipList] = common_config_dyn:find(equip_bind,equip_bind_equip),
    _BindEquipRecord = 
        case [BindEquipRecordT || 
                 BindEquipRecordT <- BindEquipList, 
                 BindEquipRecordT#r_equip_bind_equip.equip_code =:= EquipBaseInfo#p_equip_base_info.slot_num,
                 BindEquipRecordT#r_equip_bind_equip.protype =:= EquipBaseInfo#p_equip_base_info.protype ] of
            [BindEquipRecordTT] ->
                BindEquipRecordTT;
            _ ->
                erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_CODE_ERROR,0})
        end,
    [BindItemList] = common_config_dyn:find(equip_bind,equip_bind_item),
    BindItemRecord = 
        case [BindItemRecordT ||
                 BindItemRecordT <- BindItemList, 
                 BindItemRecordT#r_equip_bind_item.item_id =:= BindGoods#p_goods.typeid] of
            [BindItmeRecordTT] ->
                BindItmeRecordTT;
            _ ->
                erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR,0})
        end,
    if BindItemRecord#r_equip_bind_item.type =/= 1->
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR,0});
       BindGoods#p_goods.current_num < BindItemRecord#r_equip_bind_item.item_num ->
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_NUM_ERROR,0});
       true ->
            next
    end,
    %% 第一次绑定
    case SubOpType =:= ?EQUIP_BIND_TYPE_FIRST of
        true ->
            case EquipGoods#p_goods.bind =:= false of
                true ->
                    next;
                _ ->
                    erlang:throw({error,?_LANG_EQUIP_BIND_FIRST_EQUIP_BIND,0})
            end,
            ok;
        _ ->
            next
    end,
    %% 重新绑定
    case  SubOpType =:= ?EQUIP_BIND_TYPE_REBIND of
        true ->
            case EquipGoods#p_goods.bind =:= true of
                true ->
                    next;
                _ ->
                    erlang:throw({error,?_LANG_EQUIP_BIND_REBIND_EQUIP_BIND,0})
            end,
            ok;
        _ ->
            next
    end,
    RefiningFee =#r_refining_fee{
      type = equip_bind_fee,
      equip_level = EquipGoods#p_goods.level,
      refining_index = EquipGoods#p_goods.refining_index,
      punch_num = format_value(EquipGoods#p_goods.punch_num,1),
      stone_num = format_value(EquipGoods#p_goods.stone_num,1),
      equip_color = format_value(EquipGoods#p_goods.current_colour,1),
      equip_quality = format_value(EquipGoods#p_goods.quality,1)},
    AddPropFee = 
        case mod_refining:get_refining_fee(RefiningFee) of
            {ok,AddPropFeeT} ->
                AddPropFeeT;
            {error,AddPropError} ->
                erlang:throw({error,AddPropError,0})
        end,
    {ok,EquipGoods,BindGoods,BindItemRecord,AddPropFee}.
do_refining_firing_addprop3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                            EquipGoods,BindGoods,BindItemRecord,AddPropFee) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_firing_addprop(RoleId,EquipGoods,BindGoods,BindItemRecord,AddPropFee)
           end) of
        {atomic,{ok,EquipGoods2,DelList,UpdateList}} ->
            do_refining_firing_addprop4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                        EquipGoods2,BindGoods,BindItemRecord,AddPropFee,DelList,UpdateList);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_REFINING_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_EQUIP_BIND_ERROR,
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_firing_addprop4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                            EquipGoods,BindGoods,BindItemRecord,_AddPropFee,DelList,UpdateList) ->
    SendSelf = #m_refining_firing_toc{
      succ = true,
      op_type = DataRecord#m_refining_firing_tos.op_type,
      sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
      firing_list = DataRecord#m_refining_firing_tos.firing_list,
      update_list = [EquipGoods|UpdateList],
      del_list = DelList,
      new_list = []},
    %% 道具变化通知
    if UpdateList =/= [] ->
            catch common_misc:update_goods_notify({line, Line, RoleId},[EquipGoods | UpdateList]);
       true ->
            catch common_misc:update_goods_notify({line, Line, RoleId},[EquipGoods])
    end,
    if DelList =/= [] ->
            catch common_misc:del_goods_notify({line, Line, RoleId},DelList);
       true ->
            next
    end,
    %% 银子变化通知
    catch mod_refining:do_refining_deduct_fee_notify(RoleId,{line, Line, RoleId}),
    %% 道具消费日志
    catch common_item_logger:log(RoleId,BindGoods,BindItemRecord#r_equip_bind_item.item_num,
                                 ?LOG_ITEM_TYPE_ZHONG_XIN_BANG_DING_SHI_QU),
    %% common_mod_goal:hook_equip_bind(RoleId),
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
do_t_refining_firing_addprop(RoleId,EquipGoods,BindGoods,BindItemRecord,AddPropFee) ->
    %% 扣费
    EquipConsume = #r_equip_consume{
      type = bind,consume_type = ?CONSUME_TYPE_SILVER_EQUIP_BIND,consume_desc = ""},
    case catch mod_refining:do_refining_deduct_fee(RoleId,AddPropFee,EquipConsume) of
        {error,AddPropFeeError} ->
            common_transaction:abort({AddPropFeeError,0});
        _ ->
            next
    end,
    %% 扣绑定材料
    {DelList,UpdateList} = 
        case catch mod_equip_build:do_transaction_dedcut_goods(RoleId,[BindGoods],BindItemRecord#r_equip_bind_item.item_num) of
            {error,GoodsError} ->
                common_transaction:abort({GoodsError,0});
            {ok,DelListT,UpdateListT} ->
                DelListT2  = 
                    lists:foldl(
                      fun(DelGoods,AccDelListT2) -> 
                              case lists:keyfind(DelGoods#p_goods.id,#p_goods.id,UpdateListT) of
                                  false ->
                                      [DelGoods | AccDelListT2];
                                  _ ->
                                      AccDelListT2
                              end
                      end,[],DelListT),
                {DelListT2,UpdateListT}
        end,
    %% 绑定属性
    EquipGoods2 = 
        case mod_refining_bind:do_equip_bind_for_equip_bind(EquipGoods) of
            {error,_BindErrorCode} ->
                EquipGoods#p_goods{bind=true};
            {ok,EquipGoods2T} ->
                EquipGoods2T
        end,
    %% 计算装备精炼系数
    EquipGoods3 = 
        case common_misc:do_calculate_equip_refining_index(EquipGoods2) of
            {error,_ErrorIndexCode} ->
                EquipGoods2;
            {ok, EquipGoods3T} ->
                EquipGoods3T
        end,
    mod_bag:update_goods(RoleId,EquipGoods3),
    {ok,EquipGoods3,DelList,UpdateList}.

%% 提升
do_refining_firing_upprop({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_firing_upprop2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,EquipGoods,BindGoodsList,BindItemRecord,MaxPossibleLevel,UpPropFee} ->
            do_refining_firing_upprop3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                       EquipGoods,BindGoodsList,BindItemRecord,MaxPossibleLevel,UpPropFee)
    end.
do_refining_firing_upprop2(RoleId,DataRecord) ->
    #m_refining_firing_tos{firing_list = FiringList,sub_op_type = SubOpType } = DataRecord,
    case SubOpType =:= ?EQUIP_BIND_TYPE_UPGRADE of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_EQUIP_BIND_TYPE_ERROR,0})
    end,
    %% 材料是否足够合法
    case (erlang:length(FiringList) >= 2) of
        true ->
            next;
        false ->
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ERROR,0})
    end,
    %% 检查是否是要提升绑定属性的装备
    EquipGoods = 
        case lists:foldl(
               fun(EquipPRefiningT,AccEquipPRefiningT) ->
                       case ( AccEquipPRefiningT =:= undefined
                              andalso EquipPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_TARGET
                              andalso EquipPRefiningT#p_refining.goods_type =:= ?TYPE_EQUIP) of
                           true ->
                               EquipPRefiningT;
                           false ->
                               AccEquipPRefiningT
                       end 
               end,undefined,FiringList) of
            undefined ->
                erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_ID_ERROR,0});
            EquipPRefiningTT ->
                case mod_bag:check_inbag(RoleId,EquipPRefiningTT#p_refining.goods_id) of
                    {ok,EquipGoodsT} ->
                        EquipGoodsT;
                    _  ->
                        erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_ID_ERROR,0})
                end
        end,
    [EquipBaseInfo] = common_config_dyn:find_equip(EquipGoods#p_goods.typeid),
    if EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT ->
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_MOUNT_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_FASHION ->
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_FASHION_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_ADORN ->
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_ADORN_ERROR,0});
       true ->
            next
    end,
    [SpecialEquipList] = common_config_dyn:find(refining,special_equip_list),
    case lists:member(EquipGoods#p_goods.typeid,SpecialEquipList) of
        true ->
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_ADORN_ERROR,0});
        _ ->
            next
    end,
    case EquipGoods#p_goods.bind =:= true of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_EQUIP_BIND,0})
    end,
    case  EquipGoods#p_goods.equip_bind_attr =/= undefined
        andalso EquipGoods#p_goods.equip_bind_attr =/= [] of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_EQUIP_BIND_ATTR,0})
    end,
    %% 检查装备绑定属性是不是满级
    [EquipBindAttrList] =  common_config_dyn:find(equip_bind,equip_bind_attr),
    CheckEquipBindAttrList = 
        lists:map(
          fun(AttrRecord) ->
                  MaxBindAttrLevel = lists:max(
                                       [R2#r_equip_bind_attr.level || 
                                           R2 <- EquipBindAttrList, 
                                           R2#r_equip_bind_attr.attr_code =:= AttrRecord#p_equip_bind_attr.attr_code]),
                  case MaxBindAttrLevel =:= AttrRecord#p_equip_bind_attr.attr_level of
                      true ->
                          1;
                      _ ->
                          2
                  end
          end,EquipGoods#p_goods.equip_bind_attr),
    case lists:member(2,CheckEquipBindAttrList) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_FULL,0})
    end,
    %% 必须一级一级的提升，当前装备的最低
    MinBindAttrLevel = lists:min([MinBindAttrLevelT || #p_equip_bind_attr{attr_level = MinBindAttrLevelT} <- EquipGoods#p_goods.equip_bind_attr]),
    [BindItemList] = common_config_dyn:find(equip_bind,equip_bind_item),
    %% 当前必须使用的提升材料配置记录
    BindItemRecord = 
        case [BindItemRecordT ||
                 BindItemRecordT <- BindItemList, 
                 BindItemRecordT#r_equip_bind_item.item_level =:= MinBindAttrLevel] of
            [BindItmeRecordTT] ->
                BindItmeRecordTT;
            _ ->
                erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR,0})
        end,
    {BindGoodsList,BindGoodsNeedNumber} = 
        lists:foldl(
          fun(BindPRefiningT,{AccBindGoodsList,AccBindGoodsNeedNumber}) ->
                  case BindPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL
                      andalso BindPRefiningT#p_refining.goods_type =:= ?TYPE_ITEM 
                      andalso BindPRefiningT#p_refining.goods_type_id =:= BindItemRecord#r_equip_bind_item.item_id of
                      true ->
                          case mod_bag:check_inbag(RoleId,BindPRefiningT#p_refining.goods_id) of
                              {ok,BindGoodsT} ->
                                  {[BindGoodsT|AccBindGoodsList],
                                   AccBindGoodsNeedNumber + BindPRefiningT#p_refining.goods_number};
                              _  ->
                                  erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ERROR,0})
                          end;
                      _ ->
                          {AccBindGoodsList,AccBindGoodsNeedNumber}
                  end
          end,{[],0},FiringList),
    [BindGoodsBaseInfo] = common_config_dyn:find_item(BindItemRecord#r_equip_bind_item.item_id),
    case BindGoodsList =:= []
        orelse (erlang:length(BindGoodsList) =/= erlang:length(FiringList) - 1)
        orelse BindItemRecord#r_equip_bind_item.item_num =/= BindGoodsNeedNumber of
        true ->
            erlang:throw({error,
                          common_tool:get_format_lang_resources(?_LANG_EQUIP_BIND_GOODS_VALID_ERROR,
                                                                [BindItemRecord#r_equip_bind_item.item_num,
                                                                 BindGoodsBaseInfo#p_item_base_info.itemname]),
                          0});
        _ ->
            next
    end,
    [BindEquipList] = common_config_dyn:find(equip_bind,equip_bind_equip),
    _BindEquipRecord = 
        case [BindEquipRecordT || 
                 BindEquipRecordT <- BindEquipList, 
                 BindEquipRecordT#r_equip_bind_equip.equip_code =:= EquipBaseInfo#p_equip_base_info.slot_num,
                 BindEquipRecordT#r_equip_bind_equip.protype =:= EquipBaseInfo#p_equip_base_info.protype ] of
            [BindEquipRecordTT] ->
                BindEquipRecordTT;
            _ ->
                erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_CODE_ERROR,0})
        end,
    case BindItemRecord#r_equip_bind_item.type =/= 2 of
        true ->
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR,0});
        _ ->
            next
    end,
    %% 提升属性材料最高可能达到的级别
    [BindAddLevelList] = common_config_dyn:find(equip_bind,equip_bind_add_level),
    MaxPossibleLevel = 
        lists:max([R3#r_equip_bind_add_level.attr_level || 
                      R3 <- BindAddLevelList, 
                      R3#r_equip_bind_add_level.material_level =:= BindItemRecord#r_equip_bind_item.item_level]),
    case MinBindAttrLevel >= MaxPossibleLevel of
        true ->
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_ITEM_LEVEL,0});
        _ ->
            next
    end,
    RefiningFee =#r_refining_fee{type = equip_bind_upgrade_fee,
                                 equip_level = EquipGoods#p_goods.level,
                                 material_level = BindItemRecord#r_equip_bind_item.item_level,
                                 refining_index = EquipGoods#p_goods.refining_index,
                                 punch_num = format_value(EquipGoods#p_goods.punch_num,1),
                                 stone_num = format_value(EquipGoods#p_goods.stone_num,1),
                                 equip_color = format_value(EquipGoods#p_goods.current_colour,1),
                                 equip_quality = format_value(EquipGoods#p_goods.quality,1)},
    UpPropFee = 
        case mod_refining:get_refining_fee(RefiningFee) of
            {ok,UpPropFeeT} ->
                UpPropFeeT;
            {error,UpPropFeeError} ->
                erlang:throw({error,UpPropFeeError,0})
        end,
    {ok,EquipGoods,BindGoodsList,BindItemRecord,MaxPossibleLevel,UpPropFee}.
do_refining_firing_upprop3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                           EquipGoods,BindGoodsList,BindItemRecord,MaxPossibleLevel,UpPropFee) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_firing_upprop(RoleId,EquipGoods,BindGoodsList,BindItemRecord,MaxPossibleLevel,UpPropFee)
           end) of
        {atomic,{ok,NewEquipGoods,DelList,UpdateList,IsUpProp}} ->
            do_refining_firing_upprop4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                       NewEquipGoods,BindGoodsList,BindItemRecord,DelList,UpdateList,IsUpProp);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_REFINING_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_EQUIP_BIND_ERROR,
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_firing_upprop4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                           EquipGoods,BindGoodsList,BindItemRecord,DelList,UpdateList,IsUpProp) ->
    case IsUpProp =:= 1 of
        true ->
            Reason = ?_LANG_EQUIP_BIND_UPGRADE_SUCC,ReasonCode = 0;
        _ ->
            Reason =?_LANG_EQUIP_BIND_UPGRADE_ERROR,ReasonCode = 1
    end,
    SendSelf = #m_refining_firing_toc{
      succ = true,
      reason = Reason,reason_code = ReasonCode,
      op_type = DataRecord#m_refining_firing_tos.op_type,
      sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
      firing_list = DataRecord#m_refining_firing_tos.firing_list,
      update_list = [EquipGoods|UpdateList],
      del_list = DelList,
      new_list = []},
    %% 道具变化通知
    catch common_misc:update_goods_notify({line, Line, RoleId},[EquipGoods | UpdateList]),
    if DelList =/= [] ->
            catch common_misc:del_goods_notify({line, Line, RoleId},DelList);
       true ->
            next
    end,
    %% 银子变化通知
    catch mod_refining:do_refining_deduct_fee_notify(RoleId,{line, Line, RoleId}),
    %% 道具消费日志
    [BindGoods | _TBindGoods] = BindGoodsList,
    catch common_item_logger:log(RoleId,BindGoods,BindItemRecord#r_equip_bind_item.item_num,
                                 ?LOG_ITEM_TYPE_ZHONG_XIN_BANG_DING_SHI_QU),
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
do_t_refining_firing_upprop(RoleId,EquipGoods,BindGoodsList,BindItemRecord,MaxPossibleLevel,UpPropFee) ->
    %% 扣费
    EquipConsume = #r_equip_consume{
      type = bind,consume_type = ?CONSUME_TYPE_SILVER_EQUIP_BIND,consume_desc = ""},
    case catch mod_refining:do_refining_deduct_fee(RoleId,UpPropFee,EquipConsume) of
        {error,UpPropFeeError} ->
            common_transaction:abort({UpPropFeeError,0});
        _ ->
            next
    end,
    %% 扣绑定材料
    {DelList,UpdateList} = 
        case catch mod_equip_build:do_transaction_dedcut_goods(RoleId,BindGoodsList,BindItemRecord#r_equip_bind_item.item_num) of
            {error,GoodsError} ->
                common_transaction:abort({GoodsError,0});
            {ok,DelListT,UpdateListT} ->
                DelListT2  = 
                    lists:foldl(
                      fun(DelGoods,AccDelListT2) -> 
                              case lists:keyfind(DelGoods#p_goods.id,#p_goods.id,UpdateListT) of
                                  false ->
                                      [DelGoods | AccDelListT2];
                                  _ ->
                                      AccDelListT2
                              end
                      end,[],DelListT),
                {DelListT2,UpdateListT}
        end,
    %% 提升概率处理
    %% 将附加的绑定的属性级别为最高级的去掉，只随机没有达到满级的附加属性
    EquipBindAttrList = 
        lists:filter(
          fun(R1) -> 
                 case R1#p_equip_bind_attr.attr_level >= MaxPossibleLevel of
                     true ->
                         false;
                     _ ->
                         true
                 end
          end,EquipGoods#p_goods.equip_bind_attr),
    Len = erlang:length(EquipBindAttrList),
    RandomNumber = random:uniform(Len),
    AttrRecord = lists:nth(RandomNumber,EquipBindAttrList),
    
    [AddLevelList] = common_config_dyn:find(equip_bind,equip_bind_add_level),
    AddLevelList2 = [R2 || 
                        R2 <- AddLevelList, 
                        R2#r_equip_bind_add_level.material_level =:= BindItemRecord#r_equip_bind_item.item_level],
    AddLevelList3 = lists:sort(
                      fun(RA,RB) -> 
                              RA#r_equip_bind_add_level.attr_level =< RB#r_equip_bind_add_level.attr_level
                      end,AddLevelList2),
    ProbabilityList = [R3#r_equip_bind_add_level.probability || R3 <- AddLevelList3],
    ProbabilityIndex = mod_refining:get_random_number(ProbabilityList,0,?DEFAULT_EQUIP_BIND_UPGRADE_ATTR_LEVEL),
    NewLevelRecord = lists:nth(ProbabilityIndex,AddLevelList3),
    NewLevel = NewLevelRecord#r_equip_bind_add_level.attr_level,
    NewEquipGoods = 
        case NewLevel > AttrRecord#p_equip_bind_attr.attr_level of
            true ->%% 属性提升
                [ConfigEquipBindAttrList] = common_config_dyn:find(equip_bind,equip_bind_attr),
                [ConfigAttrRecord] = [ConfigAttrRecordT || 
                                         ConfigAttrRecordT <- ConfigEquipBindAttrList,
                                         ConfigAttrRecordT#r_equip_bind_attr.attr_code =:= AttrRecord#p_equip_bind_attr.attr_code,
                                         ConfigAttrRecordT#r_equip_bind_attr.level =:= NewLevel],
                IsUpProp = 1,
                NewEquipBindAttrListT = lists:keydelete(AttrRecord#p_equip_bind_attr.attr_code,
                                                        #p_equip_bind_attr.attr_code,
                                                        EquipGoods#p_goods.equip_bind_attr),
                NewEquipBindAttrList = [AttrRecord#p_equip_bind_attr{
                                          attr_level = NewLevel,
                                          type =  ConfigAttrRecord#r_equip_bind_attr.add_type,
                                          value = ConfigAttrRecord#r_equip_bind_attr.value}|NewEquipBindAttrListT],
                EquipGoods2 = 
                    case mod_refining_bind:do_equip_bind_for_equip_bind_up_attr(EquipGoods,NewEquipBindAttrList) of
                        {error,_BindErrorCode} ->
                            EquipGoods;
                        {ok,EquipGoods2T} ->
                            EquipGoods2T
                    end,
                %% 计算装备精炼系数
                case common_misc:do_calculate_equip_refining_index(EquipGoods2) of
                    {error,_ErrorIndexCode} ->
                        EquipGoods2;
                    {ok, EquipGoods3} ->
                        EquipGoods3
                end;
            _ -> %% 属性提升失败没有变化
                IsUpProp = 2,
                EquipGoods
        end,
    mod_bag:update_goods(RoleId,NewEquipGoods),
    {ok,NewEquipGoods,DelList,UpdateList,IsUpProp}.

%% 炼制
do_refining_firing_forging({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_firing_forging2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,GoodsList,ForgingGoodsList,FFRecord} ->
            do_refining_firing_forging3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                        GoodsList,ForgingGoodsList,FFRecord)
    end.
do_refining_firing_forging2(RoleId,DataRecord) ->
    #m_refining_firing_tos{firing_list = FiringList} = DataRecord,
    [IsOpenForging] = common_config_dyn:find(etc,open_refining_forging),
    case IsOpenForging of
        true ->
            next;
        false ->
            erlang:throw({error,?_LANG_REINFORCE_FORGING_NOT_OPEN,0})
    end,
    MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_REINFORCE_FORGING_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    %% 炼制的所有物品
    {GoodsList,GoodsSunNumber,PRefiningNumber} = 
        case lists:foldl(
               fun(PRefiningT,{AccPRefiningT,AccPRefiningNumber}) ->
                       case PRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL of
                           true ->
                               {[PRefiningT|AccPRefiningT],AccPRefiningNumber + PRefiningT#p_refining.goods_number};
                           false ->
                               {AccPRefiningT,AccPRefiningNumber}
                       end 
               end,{[],0},FiringList) of
            {[],_AccPRefiningNumber} ->
                erlang:throw({error,?_LANG_REINFORCE_FORGING_EMPTY,0});
            {PRefiningList,PRefiningNumberT} ->
                case lists:foldl(
                       fun(PRefiningTT,{AccGoodsList,AccGoodsSunNumber}) ->
                               case mod_bag:check_inbag(RoleId,PRefiningTT#p_refining.goods_id) of
                                   {ok,GoodsT} ->
                                       {[GoodsT|AccGoodsList],AccGoodsSunNumber + GoodsT#p_goods.current_num};
                                   _  ->
                                       {AccGoodsList,AccGoodsSunNumber}
                               end
                       end,{[],0},PRefiningList) of
                    {[],_AccGoodsSunNumber} ->
                        erlang:throw({error,?_LANG_REINFORCE_FORGING_EMPTY,0});
                    {GoodsListT,GoodsSunNumberT} ->
                        {GoodsListT,GoodsSunNumberT,PRefiningNumberT}
                end
        end,
    %% 特殊装备不可以当材料
    [SpecialEquipList] = common_config_dyn:find(refining,special_equip_list),
    lists:foreach(
      fun(SpecialColorGoods) ->
              case lists:member(SpecialColorGoods#p_goods.typeid,SpecialEquipList) of
                  true ->
                      erlang:throw({error,common_tool:get_format_lang_resources(?_LANG_REINFORCE_FORGING_ADORN_ERROR,[SpecialColorGoods#p_goods.name]),0});
                  _ ->
                      next
              end
      end,GoodsList),
    case GoodsSunNumber >= PRefiningNumber andalso GoodsList =/= [] of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_REINFORCE_FORGING_ERROR,0})
    end,
    ForgingGoodsList = 
        case GoodsSunNumber =:= PRefiningNumber of
            true ->
                GoodsList;
            _ ->
                lists:foldl(
                  fun(ForgingGoods,AccForgingGoodsList) ->
                          #p_refining{goods_number = ForgingGoodsNumber} = 
                              lists:keyfind(ForgingGoods#p_goods.id,#p_refining.goods_id,FiringList),
                          [ForgingGoods#p_goods{current_num = ForgingGoodsNumber}|AccForgingGoodsList]
                  end,[],GoodsList)
        end,
    FFRecord = 
        case mod_refining_forging:get_refining_forging_by_goods(MapRoleInfo,ForgingGoodsList) of
            {ok,FFRecordT} ->
                FFRecordT;
            {error,Reason} ->
                ?DEBUG("~ts,Reason=~w",["此物品无法获取合法的炼制方案",Reason]),
                erlang:throw({error,?_LANG_REINFORCE_FORGING_ERROR,0})
        end,
    {ok,GoodsList,ForgingGoodsList,FFRecord}.

do_refining_firing_forging3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                            GoodsList,ForgingGoodsList,FFRecord) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_firing_forging(RoleId,GoodsList,ForgingGoodsList,FFRecord)
           end) of
        {atomic,{ok,NewGoodsList,FFProduct,DelList,UpdateList}} ->
            do_refining_firing_forging4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                        GoodsList,ForgingGoodsList,FFRecord,NewGoodsList,FFProduct,
                                        DelList,UpdateList);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_REFINING_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_REINFORCE_FORGING_ERROR,
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_firing_forging4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                            GoodsList,ForgingGoodsList,_FFRecord,NewGoodsList,FFProduct,
                            DelList,UpdateList) ->
    case NewGoodsList =:= [] andalso FFProduct =:= undefined of
        true -> %% 炮制操作成功，但没有生成物品
            Reason = ?_LANG_REINFORCE_FORGING_FAIL,
            ReasonCode = 1,
            NewList = [];
        _ ->
            Reason ="",
            ReasonCode = 0,
            [HNewGoods|_TTNewGoods] = NewGoodsList,
            NewList = [HNewGoods#p_goods{current_num = FFProduct#r_forging_formula_item.item_num}]
            
    end,
    SendSelf = #m_refining_firing_toc{
      succ = true,
      reason = Reason,reason_code = ReasonCode,
      op_type = DataRecord#m_refining_firing_tos.op_type,
      sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
      firing_list = DataRecord#m_refining_firing_tos.firing_list,
      update_list = UpdateList,
      del_list = DelList,
      new_list = NewList},
    %% 道具变化通知
    catch common_misc:update_goods_notify({line, Line, RoleId},lists:append([NewGoodsList,UpdateList])),
    if DelList =/= [] ->
            catch common_misc:del_goods_notify({line, Line, RoleId},DelList);
       true->
            next
    end,
    %% 道具消费日志
    lists:foreach(
      fun(DelGoods) ->
              catch common_item_logger:log(RoleId,DelGoods,?LOG_ITEM_TYPE_LIAN_ZHI_SHI_QU)
      end,ForgingGoodsList),
    if NewGoodsList =/= [] ->
            [NewGoods|_TNewGoods] = NewGoodsList,
            catch common_item_logger:log(RoleId,NewGoods,FFProduct#r_forging_formula_item.item_num,?LOG_ITEM_TYPE_LIAN_ZHI_HUO_DE);
       true ->
            next
    end,
    %% 炼制消息广播
    catch mod_refining_forging:do_refining_forging_notify(RoleId,FFProduct,GoodsList,NewList),
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
do_t_refining_firing_forging(RoleId,GoodsList,ForgingGoodsList,FFRecord) ->
    %% mod_bag:delete_goods(RoleId,[DelGoodsId || #p_goods{id = DelGoodsId} <- GoodsList]),
    %% 扣绑定材料
    {DelList,UpdateList} = 
        lists:foldl(
          fun(DelGoods,{AccDelList,AccUpdateList}) ->
                  #p_goods{current_num = ForgingGoodsNumber} = 
                      lists:keyfind(DelGoods#p_goods.id,#p_goods.id,ForgingGoodsList),
                  case ForgingGoodsNumber =:= DelGoods#p_goods.current_num of
                      true ->
                          mod_bag:delete_goods(RoleId,[DelGoods#p_goods.id]),
                          {[DelGoods|AccDelList],AccUpdateList};
                      _ ->
                          case catch mod_equip_build:do_transaction_dedcut_goods(RoleId,[DelGoods],ForgingGoodsNumber) of
                              {error,DelGoodsError} ->
                                  common_transaction:abort({DelGoodsError,0});
                              {ok,DelListT,UpdateListT} ->
                                  DelListT2  = 
                                      lists:foldl(
                                        fun(DelGoodsT,AccDelListT2) -> 
                                                case lists:keyfind(DelGoodsT#p_goods.id,#p_goods.id,UpdateListT) of
                                                    false ->
                                                        [DelGoodsT | AccDelListT2];
                                                    _ ->
                                                        AccDelListT2
                                                end
                                        end,[],DelListT),
                                  {lists:append([DelListT2,AccDelList]),lists:append([UpdateListT,AccUpdateList])}
                          end

                  end
          end,{[],[]},GoodsList),
    FFProductList = FFRecord#r_forging_formula.products,
    if FFProductList =:= [] ->
            {ok,[],undefined};
       erlang:length(FFProductList) =:= 1 ->
            [FFProduct] = FFProductList,
            do_t_refining_firing_forging2(RoleId,GoodsList,FFRecord,FFProduct,DelList,UpdateList);
       true ->
            do_t_refining_firing_forging2(RoleId,GoodsList,FFRecord,FFProductList,DelList,UpdateList)
    end.
do_t_refining_firing_forging2(RoleId,GoodsList,FFRecord,FFProductList,DelList,UpdateList) 
  when erlang:is_list(FFProductList) ->
    %% 炼制方案炼制获得的物品配置有多个处理
    PDataList = [FFR#r_forging_formula_item.succ_probability || FFR <- FFProductList],
    [HFFProduct|_T] = FFProductList,
    ResultWeight = HFFProduct#r_forging_formula_item.result_weight,
    Index = mod_refining:get_random_number(PDataList,ResultWeight,-1),
    if Index > 0 andalso Index =< erlang:length(PDataList) ->
            FFProduct = lists:nth(Index,FFProductList),
            do_t_refining_firing_forging3(RoleId,GoodsList,FFRecord,FFProduct,DelList,UpdateList);
       true ->
            ?DEBUG("~ts",["炼制创建物品时，根据多个物品生成配置结果计算不需要创建物品，即炼制失败，扣除物品"]),
            {ok, [], undefined,DelList,UpdateList}
    end;
do_t_refining_firing_forging2(RoleId,GoodsList,FFRecord,FFProduct,DelList,UpdateList) 
  when erlang:is_record(FFProduct,r_forging_formula_item)->
    Type = FFProduct#r_forging_formula_item.type,
    if Type =:= ?REFINING_FORGING_MATERIAL_TYPE_ITEM ->
            ResultWeight = FFProduct#r_forging_formula_item.result_weight,
            SuccProbability = FFProduct#r_forging_formula_item.succ_probability,
            RandomNumber = random:uniform(ResultWeight),
            case RandomNumber =< SuccProbability of
                true ->
                    do_t_refining_firing_forging3(RoleId,GoodsList,FFRecord,FFProduct,DelList,UpdateList);
                _ ->
                    ?DEBUG("~ts",["炼制创建物品时，根据结果计算不需要创建物品，即炼制失败，扣除物品"]),
                    {ok, [],undefined,DelList,UpdateList}
            end;
       true ->
            ?DEBUG("~ts,RoleId=~w,FFProduct=~w",["炼制创建物品失败，物品配置方案中类型出错",RoleId,FFProduct]),
            common_transaction:abort({?_LANG_REINFORCE_FORGING_ERROR,0})
    end;
do_t_refining_firing_forging2(RoleId,_GoodsList,FFRecord,_FFProducts,_DelList,_UpdateList) ->
    ?DEBUG("~ts,RoleId=~w,FFRecord=~w",["炼制创建物品参数错误，炼制失败",RoleId,FFRecord]),
    common_transaction:abort({?_LANG_REINFORCE_FORGING_ERROR,0}).

%% 创建物品
do_t_refining_firing_forging3(RoleId,GoodsList,_FFRecord,FFProduct,DelList,UpdateList) ->
    TypeValue = FFProduct#r_forging_formula_item.type_value,
    ItemType = 
        case common_config_dyn:find_item(TypeValue) of
            [_ItemBaseInfo] ->
                ?TYPE_ITEM;
            _ ->
                case common_config_dyn:find_stone(TypeValue) of
                    [_StoneBaseInfo] ->
                        ?TYPE_STONE;
                    _ ->
                        case common_config_dyn:find_equip(TypeValue) of
                            [_EquipBaseInfo] ->
                                ?TYPE_EQUIP;
                            _ ->
                                common_transaction:abort({?_LANG_REINFORCE_FORGING_ERROR,0})
                        end
                end
        end,
    Bind = 
        if FFProduct#r_forging_formula_item.bind =:= 1 ->
                true;
           FFProduct#r_forging_formula_item.bind =:= 2 ->
                false;
           true ->
                lists:foldl(
                  fun(Goods,AccBind) ->
                          case AccBind of
                              true ->
                                  AccBind;
                              false ->
                                  Goods#p_goods.bind
                          end
                  end,false,GoodsList)
        end,
    CreateInfo = 
        if ItemType =:= ?TYPE_EQUIP ->
                Color = mod_refining:get_random_number(FFProduct#r_forging_formula_item.color,0,1),
                Quality = mod_refining:get_random_number(FFProduct#r_forging_formula_item.quality,0,1),
                #r_goods_create_info{
                           type = ItemType,
                           type_id = FFProduct#r_forging_formula_item.type_value,
                           num = FFProduct#r_forging_formula_item.item_num,
                           bind = Bind,
                           color = Color,
                           quality = Quality,
                           interface_type = refining_forging};
           true ->
                #r_goods_create_info{
             type = ItemType,
             type_id = FFProduct#r_forging_formula_item.type_value,
             num = FFProduct #r_forging_formula_item.item_num,
             bind = Bind}
        end,
    {ok, NewGoodsList} = mod_bag:create_goods(RoleId,CreateInfo),
    {ok, NewGoodsList, FFProduct, DelList, UpdateList}.

%% 取回天工炉物品接口
do_refining_firing_retake({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_firing_retake2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,GoodsList} ->
            do_refining_firing_retake3({Unique, Module, Method, DataRecord, RoleId, PId, Line},GoodsList)
    end.
do_refining_firing_retake2(RoleId,DataRecord) ->
    #m_refining_firing_tos{sub_op_type = SubOpType} = DataRecord,
    case SubOpType =:= ?FIRING_OP_TYPE_RETAKE_1 orelse SubOpType =:= ?FIRING_OP_TYPE_RETAKE_2 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_RETAKE_ERROR,0})
    end,
    GoodsList = mod_refining_bag:get_goods_by_bag_id(RoleId,?REFINING_BAGID),
    case GoodsList =/= [] of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_RETAKE_NO_GOODS,0})
    end,
    {ok,GoodsList}.
do_refining_firing_retake3({Unique, Module, Method, DataRecord, RoleId, PId, Line},GoodsList) ->
    case DataRecord#m_refining_firing_tos.sub_op_type =:= ?FIRING_OP_TYPE_RETAKE_1 of
        true ->
            SendSelf = #m_refining_firing_toc{
              succ = true,
              op_type = DataRecord#m_refining_firing_tos.op_type,
              sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
              firing_list = DataRecord#m_refining_firing_tos.firing_list,
              new_list=GoodsList,del_list=[],update_list=[]},
            ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf);
        _ ->
            case common_transaction:transaction(
                   fun() ->
                           do_t_refining_firing_retake(RoleId,GoodsList)
                   end) of
                {atomic,{ok,NewGoodsList}} ->
                    do_refining_firing_retake4({Unique, Module, Method, DataRecord, RoleId, PId, Line},GoodsList,NewGoodsList);
                {aborted, Error} ->
                    case Error of
                        {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                            NotBagPosMessage = common_tool:get_format_lang_resources(?_LANG_RETAKE_NOT_BAG_POS,[erlang:length(GoodsList)]),
                            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},NotBagPosMessage,1);
                        {Reason, ReasonCode} ->
                            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                        _ ->
                            Reason2 = ?_LANG_RETAKE_ERROR,
                            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
                    end
            end
    end.
do_refining_firing_retake4({Unique, Module, Method, DataRecord, RoleId, PId, Line},GoodsList,NewGoodsList) ->
    SendSelf = #m_refining_firing_toc{
      succ = true,
      op_type = DataRecord#m_refining_firing_tos.op_type,
      sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
      firing_list = DataRecord#m_refining_firing_tos.firing_list,
      new_list = NewGoodsList,
      del_list = [],
      update_list = []},
    %% 道具变化通知
    catch common_misc:update_goods_notify({line, Line, RoleId},NewGoodsList),
    catch common_misc:del_goods_notify({line, Line, RoleId},GoodsList),
    %% 道具消费日志
    lists:foreach(
      fun(DelGoods) ->
              catch common_item_logger:log(RoleId,DelGoods,?LOG_ITEM_TYPE_RETAKE_SHI_QU)
      end,GoodsList),
    lists:foreach(
      fun(NewGoods) ->
              catch common_item_logger:log(RoleId,NewGoods,?LOG_ITEM_TYPE_RETAKE_HUO_DE)
      end,NewGoodsList),
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.

do_t_refining_firing_retake(RoleId,GoodsList) ->
    mod_bag:delete_goods(RoleId,[DelGoods#p_goods.id || DelGoods <- GoodsList]),
    NewGoodsListT = [NewGoods#p_goods{id = 0,bagposition = 0,bagid = 0}|| NewGoods <- GoodsList],
    {ok,NewGoodsList} = mod_bag:create_goods_by_p_goods(RoleId,NewGoodsListT),
    {ok,NewGoodsList}.
