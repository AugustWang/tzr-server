%% Author: caochuncheng
%% Created: 2011-10-1
%% Description: 装备附魔模块
-module(mod_equip_add_magic).

%% INCLUDE
-include("mgeem.hrl").
-include("refining.hrl").
-include("equip.hrl").

%% API
-export([do_equip_add_magic/1]).

do_equip_add_magic({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_equip_add_magic2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,EquipGoods,MaterialGoodsList,EquipAddMagicBaseInfo} ->
            do_equip_add_magic3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                EquipGoods,MaterialGoodsList,EquipAddMagicBaseInfo)
    end.
do_equip_add_magic2(RoleId,DataRecord) ->
    #m_refining_firing_tos{firing_list = FiringList,sub_op_type = ColorCode} = DataRecord,
    case (erlang:length(FiringList) >= 2) of
        true ->
            next;
        false ->
            erlang:throw({error,?_LANG_ADD_MAGIC_NOT_ENOUGH_GOODS,0})
    end,
    %% 检查是否有要附魔的装备
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
                erlang:throw({error,?_LANG_ADD_MAGIC_NO_EQUIP,0});
            EquipPRefiningTT ->
                case mod_bag:check_inbag(RoleId,EquipPRefiningTT#p_refining.goods_id) of
                    {ok,EquipGoodsT} ->
                        EquipGoodsT;
                    _  ->
                        erlang:throw({error,?_LANG_ADD_MAGIC_NO_EQUIP,0})
                end
        end,
    case EquipGoods#p_goods.light_code =:= ColorCode of
        true ->
            erlang:throw({error,?_LANG_ADD_MAGIC_THE_SAME_LIGHT_CODE,0});
        _ ->
            next
    end,
    [EquipBaseInfo] = common_config_dyn:find_equip(EquipGoods#p_goods.typeid),
    [CanEquipAddMagicList] = common_config_dyn:find(equip_add_magic,can_equip_add_magic_list),
    case lists:member(EquipBaseInfo#p_equip_base_info.kind, CanEquipAddMagicList) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_ADD_MAGIC_CAN_NOT_DO,0})
    end,
    if EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT ->
            erlang:throw({error,?_LANG_ADD_MAGIC_MOUNT_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_FASHION ->
            erlang:throw({error,?_LANG_ADD_MAGIC_FASHION_ERROR,0});
       EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_ADORN ->
            erlang:throw({error,?_LANG_ADD_MAGIC_ADORN_ERROR,0});
       true ->
            next
    end,
    [SpecialEquipList] = common_config_dyn:find(refining,special_equip_list),
    case lists:member(EquipGoods#p_goods.typeid,SpecialEquipList) of
        true ->
            erlang:throw({error,?_LANG_ADD_MAGIC_ADORN_ERROR,0});
        _ ->
            next
    end,
    [CanEquipAddMagicMaterialList] = common_config_dyn:find(equip_add_magic,can_equip_add_magic_material_list),
    %% 附魔材料
    {MaterialGoodsList,MaterialGoodsNumber,MaterialGoodsItemId} = 
        lists:foldl(
          fun(MaterialPRefiningT,{AccMaterialGoodsList,AccMaterialGoodsNumber,AccMaterialGoodsItemId}) ->
                  case MaterialPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL 
                       andalso MaterialPRefiningT#p_refining.goods_type =:= ?TYPE_ITEM
                       andalso AccMaterialGoodsItemId =:= 0 of
                      true ->
                          AccMaterialGoodsItemId2 = MaterialPRefiningT#p_refining.goods_type_id;
                      _ ->
                          AccMaterialGoodsItemId2 = AccMaterialGoodsItemId
                  end,
                  case MaterialPRefiningT#p_refining.firing_type =:= ?FIRING_TYPE_MATERIAL 
                       andalso MaterialPRefiningT#p_refining.goods_type =:= ?TYPE_ITEM
                       andalso AccMaterialGoodsItemId2 =:= MaterialPRefiningT#p_refining.goods_type_id
                       andalso lists:member(MaterialPRefiningT#p_refining.goods_type_id,CanEquipAddMagicMaterialList) =:= true of
                      true ->
                          case mod_bag:check_inbag(RoleId,MaterialPRefiningT#p_refining.goods_id) of
                              {ok,MaterialGoodsT} ->
                                  {[MaterialGoodsT|AccMaterialGoodsList],
                                   AccMaterialGoodsNumber + MaterialPRefiningT#p_refining.goods_number,
                                   AccMaterialGoodsItemId2};
                              _ ->
                                  erlang:throw({error,?_LANG_ADD_MAGIC_NO_VALID_GOODS,0})
                          end;                           
                      false ->
                          {AccMaterialGoodsList,AccMaterialGoodsNumber,AccMaterialGoodsItemId2}
                  end
          end,{[],0,0},FiringList),
    case erlang:length(FiringList) =:= erlang:length(MaterialGoodsList) + 1 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_ADD_MAGIC_NO_VALID_GOODS,0})
    end,
    [EquipAddMagicBaseInfoList] = common_config_dyn:find(equip_add_magic,equip_add_magic_base_info),
    EquipAddMagicBaseInfo = 
        case lists:keyfind(ColorCode,#r_equip_add_magic_base_info.color_code,EquipAddMagicBaseInfoList) of
            false ->
                erlang:throw({error,?_LANG_ADD_MAGIC_COLOR_CODE_ERROR,0});
            EquipAddMagicBaseInfoT ->
                EquipAddMagicBaseInfoT
        end,
    case MaterialGoodsItemId =:= EquipAddMagicBaseInfo#r_equip_add_magic_base_info.item_id of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_ADD_MAGIC_GOODS_ERROR,0})
    end,
    case MaterialGoodsNumber >= EquipAddMagicBaseInfo#r_equip_add_magic_base_info.item_number of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_ADD_MAGIC_NOT_ENOUGH_GOODS,0})
    end,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
    case RoleAttr#p_role_attr.silver + RoleAttr#p_role_attr.silver_bind >= EquipAddMagicBaseInfo#r_equip_add_magic_base_info.op_fee of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_ADD_MAGIC_NOT_ENOUGH_OP_FEE,0})
    end,
    {ok,EquipGoods,MaterialGoodsList,EquipAddMagicBaseInfo}.
do_equip_add_magic3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                    EquipGoods,MaterialGoodsList,EquipAddMagicBaseInfo) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_equip_add_magic(RoleId,EquipGoods,MaterialGoodsList,EquipAddMagicBaseInfo)
           end) of
        {atomic,{ok,NewEquipGoods,DelList,UpdateList}} ->
            do_equip_add_magic4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                NewEquipGoods,MaterialGoodsList,EquipAddMagicBaseInfo,DelList,UpdateList);
        {aborted, Error} ->
            case Error of
                {Reason, ReasonCode} ->
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_ADD_MAGIC_ERROR,
                    do_refining_firing_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_equip_add_magic4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                    NewEquipGoods,MaterialGoodsList,EquipAddMagicBaseInfo,DelList,UpdateList) ->
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
    [MaterialGoods|_TMaterialGoods] =MaterialGoodsList,
    catch common_item_logger:log(RoleId,MaterialGoods,EquipAddMagicBaseInfo#r_equip_add_magic_base_info.item_number,
                                 ?LOG_ITEM_TYPE_EQUIP_ADD_MAGIC_SHI_QU),
    catch common_item_logger:log(RoleId,NewEquipGoods,1,?LOG_ITEM_TYPE_EQUIP_ADD_MAGIC_HUO_DE),
    %% 信息返回
    SendSelf = #m_refining_firing_toc{
                                      succ = true,
                                      op_type = DataRecord#m_refining_firing_tos.op_type,
                                      sub_op_type = DataRecord#m_refining_firing_tos.sub_op_type,
                                      firing_list = DataRecord#m_refining_firing_tos.firing_list,
                                      update_list = [NewEquipGoods| UpdateList],
                                      del_list = DelList,
                                      new_list = []},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
do_t_equip_add_magic(RoleId,EquipGoods,MaterialGoodsList,EquipAddMagicBaseInfo) ->
    %% 扣材料，扣费用，记录日志，设置装备附魔效果
    EquipConsume = #r_equip_consume{type = add_magic,consume_type = ?CONSUME_TYPE_SIVLER_EQUIP_ADD_MAGIC,consume_desc = ""},
    case catch mod_refining:do_refining_deduct_fee(RoleId,EquipAddMagicBaseInfo#r_equip_add_magic_base_info.op_fee,EquipConsume) of
        {error,AddMagicFeeError} ->
            common_transaction:abort({AddMagicFeeError,0});
        _ ->
            next
    end,
    %% 扣附魔材料
    {DelList,UpdateList} = 
        case catch mod_equip_build:do_transaction_dedcut_goods(RoleId,MaterialGoodsList,EquipAddMagicBaseInfo#r_equip_add_magic_base_info.item_number) of
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
    IsMaterialBind = 
        lists:foldl(
          fun(#p_goods{bind = PIsMaterialBind},AccIsMaterialBind) -> 
                  case AccIsMaterialBind =:= false andalso PIsMaterialBind =:= true of
                      true ->
                          true;
                      _ ->
                          AccIsMaterialBind
                  end
          end, false, MaterialGoodsList),
    %% 装备附魔效果
    EquipGoods2 = 
        case EquipGoods#p_goods.bind =:= false andalso IsMaterialBind =:= true of
            true -> %% 需要处理装备绑定
                case mod_refining_bind:do_equip_bind_by_config_atom(
                       EquipGoods,equip_bind_attr_number_upcolor,equip_bind_attr_level_upcolor) of
                    {ok,EquipGoodsT} ->
                        EquipGoodsT;
                    _ ->
                        EquipGoods#p_goods{bind = true}
                end;
            _ ->
                EquipGoods
        end,
    EquipGoods3 = EquipGoods2#p_goods{light_code = EquipAddMagicBaseInfo#r_equip_add_magic_base_info.color_code},
    mod_bag:update_goods(RoleId,EquipGoods3),
    %% 如果可以直接操作玩家身上的装备，即需要更新p_role_attr.skin，并广播给场景
    {ok,EquipGoods3,DelList,UpdateList}.
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