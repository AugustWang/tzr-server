-module(mod_refining_bind).

-include("mgeem.hrl").
-include("refining.hrl").
-include("equip.hrl").

%%对角色模块的接口---------------
-export([handle/1]).

%%对其它模块的接口---------------
-export([
         do_equip_bind_for_equip_bind/1,
         do_equip_bind_for_equip_bind_up_attr/2,
         do_equip_bind_for_equip_build/1,
         do_equip_bind_for_monster_flop/1,
         do_equip_bind_for_reinforce/1,
         do_equip_bind_for_quality/1,
         do_equip_bind_for_upgrade/1,
         do_equip_bind_for_punch/1,
         do_equip_bind_for_inlay/1,
         do_equip_bind_for_present/1,
         do_equip_bind_for_mission/1,
         do_equip_bind_for_buy/1,
         do_equip_bind_for_fiveele/1,
         do_equip_bind_for_forging/1,
         do_equip_rebind_for_equip_upgrade/2,
         do_equip_bind_for_equip_upgrade/2,
         do_equip_bind_for_item_gift/3,
         do_equip_bind_by_config_atom/3,
         do_equip_bind_by_config_atom/4
        ]).

%% 装备绑定
handle({_, ?REFINING, ?REFINING_EQUIP_BIND, DataIn, _, _, _, _}=Msg)
  when is_record(DataIn, m_refining_equip_bind_tos) ->
    do_equip_bind(Msg);

handle({_,Module,Method,_,_,_,_,_}) ->
    ?DEBUG("~ts,Module=~w,Method=~w",["无法处理此消息",Module,Method]).

%% 装备绑定
do_equip_bind({Unique, Module, Method, DataRecord, RoleId, Pid, Line,_State}) ->
    case catch do_equip_bind2({DataRecord, RoleId}) of
        {error,R} ->
            do_equip_bind_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},R);
        {ok,BinddGoodsList,ClassBindGoods,EquipBaseInfo} ->
            do_equip_bind3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                           BinddGoodsList,ClassBindGoods,EquipBaseInfo)
    end.

do_equip_bind2({DataRecord, RoleId}) ->
    BagId = DataRecord#m_refining_equip_bind_tos.bag_id,
    BindGoodsList = 
        case get_dirty_goods_bag_id(RoleId,BagId) of
            {error,R} ->
                ?ERROR_MSG("~ts,RoleId=~w,BagId=~w,Error=~w",["获取角色背包物品出错",RoleId,BagId,R]),
                erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ERROR});
            {ok,BGoodsList} ->
                BGoodsList
        end,
    ClassBindGoods = class_equip_bind_goods(BindGoodsList,[]),
    if erlang:length(ClassBindGoods) =/= 2 ->
           ?DEBUG("~ts,ClassBindGoods=~w",["装备绑定材料不合法",ClassBindGoods]),
           erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ERROR});
       true ->
           next
    end,
    EquipId = DataRecord#m_refining_equip_bind_tos.equip_id,
    EquipGoods = 
        case lists:keyfind(EquipId,#p_goods.id,ClassBindGoods) of
            false ->
                ?DEBUG("~ts,EquipId=~w",["参数EquipId不合法",EquipId]),
                erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_ID_ERROR});
            EGoods ->
                EGoods
        end,
    EquipTypeId = EquipGoods#p_goods.typeid,
    {ok,#p_equip_base_info{slot_num=ConfSlotNum}} = mod_equip:get_equip_baseinfo(EquipTypeId),
    if
        ConfSlotNum =:= ?PUT_MOUNT ->
            throw({error,<<"不能对坐骑进行绑定">>});
        true->
            case common_config_dyn:find_equip(EquipTypeId) of
                [EquipBaseInfo] ->
                    {ok,BindGoodsList,ClassBindGoods,EquipBaseInfo};
                _ ->
                    throw({error,?_LANG_EQUIP_BIND_EQUIP_BASE_ERROR})
            end
    end.

do_equip_bind3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                           BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    BindType = DataRecord#m_refining_equip_bind_tos.type,
    do_equip_bind4(BindType,{Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                   BinddGoodsList,ClassBindGoods,EquipBaseInfo).

do_equip_bind4(?EQUIP_BIND_TYPE_FIRST,{Unique, Module, Method, DataRecord, RoleId, Pid, Line},
              BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    do_equip_bind_first({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                       BinddGoodsList,ClassBindGoods,EquipBaseInfo);
do_equip_bind4(?EQUIP_BIND_TYPE_REBIND,{Unique, Module, Method, DataRecord, RoleId, Pid, Line},
              BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    do_equip_bind_rebind({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                        BinddGoodsList,ClassBindGoods,EquipBaseInfo);
do_equip_bind4(?EQUIP_BIND_TYPE_UPGRADE,{Unique, Module, Method, DataRecord, RoleId, Pid, Line},
              BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    do_equip_bind_upgrade({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                          BinddGoodsList,ClassBindGoods,EquipBaseInfo);
do_equip_bind4(_BindType,{Unique, Module, Method, DataRecord, RoleId, Pid, Line},
              _BinddGoodsList,_ClassBindGoods,_EquipBaseInfo) ->
    Reason = ?_LANG_EQUIP_BIND_TYPE_ERROR,
    do_equip_bind_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},Reason).

do_equip_bind_error({Unique, Module, Method, DataRecord, RoleId, _Pid, Line},Reason) ->
    BindType = DataRecord#m_refining_equip_bind_tos.type,
    RetMessage = #m_refining_equip_bind_toc{succ = false,type = BindType,reason = Reason},
    common_misc:unicast(Line, RoleId, Unique, Module, Method, RetMessage).

%% 装备第一次绑定
do_equip_bind_first({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                    BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    case catch do_equip_bind_first2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                    BinddGoodsList,ClassBindGoods,EquipBaseInfo) of 
        {error,Error} ->
            do_equip_bind_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},Error);
        {ok} ->
            do_equip_bind_first3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                    BinddGoodsList,ClassBindGoods,EquipBaseInfo)
    end.
do_equip_bind_first2({_Unique, _Module, _Method, DataRecord, _RoleId, _Pid, _Line},
                     _BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    EquipId = DataRecord#m_refining_equip_bind_tos.equip_id,
    {[BaseGoods],[EquipGoods]} = lists:partition(fun(R) -> R#p_goods.id =/= EquipId end, ClassBindGoods),
    if EquipGoods#p_goods.bind ->
            ?DEBUG("~ts",["装备第一次绑定时,已经绑定"]),
            erlang:throw({error,?_LANG_EQUIP_BIND_FIRST_EQUIP_BIND});
       true ->
            next
    end,
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    case get_equip_bind_equip(EquipCode,EquipProtype) of
        error ->
            ?DEBUG("~ts,EquipCode=~w,EquipProtype=~w",["装备绑定时装备类型编码出错",EquipCode,EquipProtype]),
            erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_CODE_ERROR});
        _ ->
            next
    end,
    BaseGoodsTypeId = BaseGoods#p_goods.typeid,
    BindItem = 
        case get_equip_bind_item(BaseGoodsTypeId) of
            error ->
                ?DEBUG("~ts,BaseGoodsTypeId=~w",["装备绑定时，基础材料Id不合法",BaseGoodsTypeId]),
                erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR});
            [] ->
                ?DEBUG("~ts,BaseGoodsTypeId=~w",["装备绑定时，基础材料Id不合法",BaseGoodsTypeId]),
                erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR});
            [Item] ->
                Item
        end,
    if BindItem#r_equip_bind_item.type =/= 1->
            ?DEBUG("~ts,BaseGoodsTypeId=~w",["装备绑定时，基础材料Id不合法",BaseGoodsTypeId]),
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR});
       true ->
            next
    end,
    if BaseGoods#p_goods.current_num < BindItem#r_equip_bind_item.item_num ->
            ?DEBUG("~ts,GoodsNumber=~w",["装备绑定时绑定材料不够",BaseGoods#p_goods.current_num]),
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_NUM_ERROR});
       true ->
            {ok}
    end.
do_equip_bind_first3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                     BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    case catch do_t_equip_bind_attr_change(RoleId,DataRecord,BinddGoodsList,ClassBindGoods,EquipBaseInfo,
                                           equip_bind_attr_number,equip_bind_attr_level) of
        {error,R} ->
            ?DEBUG("~ts,Error=~w",["装备绑定事务处理过程失败",R]),
            do_equip_bind_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},R);
        {ok,EquipGoods,DelGoodsList,UpdateGoodsList} ->
            do_equip_bind_first4({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                 EquipGoods,DelGoodsList,UpdateGoodsList)
    end.

do_equip_bind_first4({Unique, Module, Method, DataRecord, RoleId, _Pid, Line},
                     EquipGoods,DelGoodsList,_UpdateGoodsList) ->
    %% 绑定成功通知操作
    EquipGoodsId = DataRecord#m_refining_equip_bind_tos.equip_id,
    BagId = DataRecord#m_refining_equip_bind_tos.bag_id,
    Type = DataRecord#m_refining_equip_bind_tos.type,
    {ok,BindGoodsList} = get_dirty_goods_bag_id(RoleId,BagId),
    BindGoods = [R || R <- BindGoodsList, R#p_goods.id =/= EquipGoodsId],
    [DepletionGoods] =class_equip_bind_goods(DelGoodsList,[]),
    RetMessage = #m_refining_equip_bind_toc{succ = true,type = Type,
                                            equip_goods =EquipGoods ,
                                            bind_goods = BindGoods,
                                            depletion_goods = DepletionGoods },
    common_misc:unicast(Line, RoleId, Unique, Module, Method, RetMessage),
    %% common_mod_goal:hook_equip_bind(RoleId),
    %% 道具消费日志
    common_item_logger:log(RoleId,DepletionGoods,?LOG_ITEM_TYPE_ZHONG_XIN_BANG_DING_SHI_QU),
    %% 扣费通知
    UnicastArg = {line, Line, RoleId},
    case mod_map_role:get_role_attr(RoleId) of
        {ok, RoleAttr} ->
            AttrChangeList = [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value = RoleAttr#p_role_attr.silver},
                              #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value = RoleAttr#p_role_attr.silver_bind}],
            common_misc:role_attr_change_notify(UnicastArg,RoleId,AttrChangeList);
        {error ,R} ->
            ?ERROR_MSG("~ts,Reason=~w",["获取角色属性出错，打造成功之后无法通知前端银子变化情况",R])
    end.


do_equip_bind_rebind({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                     BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    case catch do_equip_bind_rebind2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                    BinddGoodsList,ClassBindGoods,EquipBaseInfo) of 
        {error,Error} ->
            do_equip_bind_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},Error);
        {ok} ->
            do_equip_bind_rebind3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                    BinddGoodsList,ClassBindGoods,EquipBaseInfo)
    end.
do_equip_bind_rebind2({_Unique, _Module, _Method, DataRecord, _RoleId, _Pid, _Line},
                     _BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    EquipId = DataRecord#m_refining_equip_bind_tos.equip_id,
    {[BaseGoods],[EquipGoods]} = lists:partition(fun(R) -> R#p_goods.id =/= EquipId end, ClassBindGoods),
    if EquipGoods#p_goods.bind ->
            next;
       true ->
            ?DEBUG("~ts",["装备重新绑定时,装备没有绑定过"]),
            erlang:throw({error,?_LANG_EQUIP_BIND_REBIND_EQUIP_BIND})
    end,
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    case get_equip_bind_equip(EquipCode,EquipProtype) of
        error ->
            ?DEBUG("~ts,EquipCode=~w,EquipProtype=~w",["装备绑定时装备类型编码出错",EquipCode,EquipProtype]),
            erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_CODE_ERROR});
        _ ->
            next
    end,
    BaseGoodsTypeId = BaseGoods#p_goods.typeid,
    BindItem = 
        case get_equip_bind_item(BaseGoodsTypeId) of
            error ->
                ?DEBUG("~ts,BaseGoodsTypeId=~w",["装备绑定时，基础材料Id不合法",BaseGoodsTypeId]),
                erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR});
            [Item] ->
                Item
        end,
    if BindItem#r_equip_bind_item.type =/= 1->
            ?DEBUG("~ts,BaseGoodsTypeId=~w",["装备绑定时，基础材料Id不合法",BaseGoodsTypeId]),
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR});
       true ->
            next
    end,
    if BaseGoods#p_goods.current_num < BindItem#r_equip_bind_item.item_num ->
            ?DEBUG("~ts,GoodsNumber=~w",["装备绑定时绑定材料不够",BaseGoods#p_goods.current_num]),
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_NUM_ERROR});
       true ->
            {ok}
    end.
do_equip_bind_rebind3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                    BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    case catch do_t_equip_bind_attr_change(RoleId,DataRecord,BinddGoodsList,ClassBindGoods,EquipBaseInfo,
                                           equip_bind_attr_number,equip_bind_attr_level) of
        {error,R} ->
            ?DEBUG("~ts,Error=~w",["装备重新绑定事务处理过程失败",R]),
            
            do_equip_bind_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},R);
        {ok,EquipGoods,DelGoodsList,UpdateGoodsList} ->
            %% 调用第一次绑定成功之后的操作处理
            do_equip_bind_first4({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                 EquipGoods,DelGoodsList,UpdateGoodsList)
    end.

%% 装备提升绑定属性级别
do_equip_bind_upgrade({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                      BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
     case catch do_equip_bind_upgrade2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                    BinddGoodsList,ClassBindGoods,EquipBaseInfo) of 
        {error,Error} ->
            do_equip_bind_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},Error);
        {ok,BindItem} ->
            do_equip_bind_upgrade3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                    BinddGoodsList,ClassBindGoods,EquipBaseInfo,BindItem)
    end.

do_equip_bind_upgrade2({_Unique, _Module, _Method, DataRecord, _RoleId, _Pid, _Line},
                     _BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    EquipId = DataRecord#m_refining_equip_bind_tos.equip_id,
    {[BaseGoods],[EquipGoods]} = lists:partition(fun(R) -> R#p_goods.id =/= EquipId end, ClassBindGoods),
    if EquipGoods#p_goods.bind ->
            next;
       true ->
            ?DEBUG("~ts",["装备提升绑定附加属性级别时,装备没有绑定过"]),
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_EQUIP_BIND})
    end,
    EquipBindAttrList = EquipGoods#p_goods.equip_bind_attr,
    if erlang:is_list(EquipBindAttrList) ->
            next;
       true ->
            ?DEBUG("~ts",["装备是绑定的，但是没有绑定属性不能提升绑定属性"]),
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_EQUIP_BIND_ATTR})
    end,
    LevelEquipAttrList = [R#p_equip_bind_attr.attr_level || R <- EquipBindAttrList],
    MinLevelAttr = lists:min(LevelEquipAttrList),
    CheckEquipBindAttrList = 
        lists:map(fun(AttrRecord) -> 
                          AttrCode = AttrRecord#p_equip_bind_attr.attr_code,
                          AttrLevel = AttrRecord#p_equip_bind_attr.attr_level,
                          case is_equip_bind_attr_max_level(AttrCode,AttrLevel) of
                              true -> 1;
                              false ->2;
                              _ ->3
                          end
                  end,EquipBindAttrList),
    ?DEBUG("~ts,EquipBindAttrList=~w,CheckEquipBindAttrList=~w",["装备已经绑定的附加属性",EquipBindAttrList,CheckEquipBindAttrList]),
    CheckFlag2 = lists:member(2,CheckEquipBindAttrList),
    CheckFlag3 = lists:member(3,CheckEquipBindAttrList),
    if CheckFlag2 orelse CheckFlag3 ->
            next;
       true ->
            ?DEBUG("~ts",["装备提升绑定附加属性级别时,装备所有绑定附加属性已经升至满级"]),
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_FULL})
    end,
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    case get_equip_bind_equip(EquipCode,EquipProtype) of
        error ->
            ?DEBUG("~ts,EquipCode=~w,EquipProtype=~w",["装备绑定时装备类型编码出错",EquipCode,EquipProtype]),
            erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_CODE_ERROR});
        _ ->
            next
    end,
    BaseGoodsTypeId = BaseGoods#p_goods.typeid,
    BindItem = 
        case get_equip_bind_item(BaseGoodsTypeId) of
            error ->
                ?DEBUG("~ts,BaseGoodsTypeId=~w",["装备绑定时，基础材料Id不合法",BaseGoodsTypeId]),
                erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR});
            [] ->
                ?DEBUG("~ts,BaseGoodsTypeId=~w",["装备绑定时，基础材料Id不合法",BaseGoodsTypeId]),
                erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR});
            [Item] ->
                Item
        end,
    if BindItem#r_equip_bind_item.type =/= 2 ->
            ?DEBUG("~ts,BaseGoodsTypeId=~w",["装备绑定时，基础材料Id不合法",BaseGoodsTypeId]),
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ID_ERROR});
       true ->
            next
    end,
    MaxPossibleLevel = get_possible_max_bind_attr_upgrade_level(BindItem#r_equip_bind_item.item_level),
    if MinLevelAttr >= MaxPossibleLevel ->
            ?DEBUG("~ts,MaxPossibleLevel=~w,MinLevelAttr=~w",["材料不合法，绑定属性的最小级别大于等于附加材料可以提升的最高级别",MaxPossibleLevel,MinLevelAttr]),
            erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_ITEM_LEVEL});
       true ->
           next
    end,
    if BaseGoods#p_goods.current_num < BindItem#r_equip_bind_item.item_num ->
            ?DEBUG("~ts,GoodsNumber=~w",["装备绑定时绑定材料不够",BaseGoods#p_goods.current_num]),
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_NUM_ERROR});
       true ->
            {ok,BindItem}
    end.
do_equip_bind_upgrade3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                    BinddGoodsList,ClassBindGoods,EquipBaseInfo,_BindItem) ->
    case catch do_t_equip_bind_attr_upgrade(RoleId,DataRecord,BinddGoodsList,ClassBindGoods,EquipBaseInfo) of
        {error,R} ->
            ?DEBUG("~ts,Error=~w",["装备重新绑定事务处理过程失败",R]),
            do_equip_bind_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},R);
        {ok,UpgradeFlag,EquipGoods,DelGoodsList,UpdateGoodsList} ->
            %% 调用第一次绑定成功之后的操作处理
            do_equip_bind_upgrade4({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                 UpgradeFlag,EquipGoods,DelGoodsList,UpdateGoodsList)
    end.

do_equip_bind_upgrade4({Unique, Module, Method, DataRecord, RoleId, _Pid, Line},
                       UpgradeFlag,EquipGoods,DelGoodsList,_UpdateGoodsList) ->
    %% 绑定成功通知操作
    EquipGoodsId = DataRecord#m_refining_equip_bind_tos.equip_id,
    BagId = DataRecord#m_refining_equip_bind_tos.bag_id,
    Type = DataRecord#m_refining_equip_bind_tos.type,
    {ok,BindGoodsList} = get_dirty_goods_bag_id(RoleId,BagId),
    BindGoods = [R || R <- BindGoodsList, R#p_goods.id =/= EquipGoodsId],
    [DepletionGoods] =class_equip_bind_goods(DelGoodsList,[]),
    Reason = 
        if UpgradeFlag =:= 0 ->
                ?_LANG_EQUIP_BIND_UPGRADE_SUCC;
           true->
                ?_LANG_EQUIP_BIND_UPGRADE_ERROR
        end,
    RetMessage = #m_refining_equip_bind_toc{succ = true,type = Type,
                                            reason = Reason,
                                            equip_goods =EquipGoods ,
                                            bind_goods = BindGoods,
                                            depletion_goods = DepletionGoods },
    %% common_mod_goal:hook_equip_bind(RoleId),
    common_misc:unicast(Line, RoleId, Unique, Module, Method, RetMessage),
    %% 道具消费日志
    common_item_logger:log(RoleId,DepletionGoods,?LOG_ITEM_TYPE_ZHONG_XIN_BANG_DING_SHI_QU),
    %% 扣费通知
    UnicastArg = {line, Line, RoleId},
    case mod_map_role:get_role_attr(RoleId) of
        {ok, RoleAttr} ->
            AttrChangeList = [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value = RoleAttr#p_role_attr.silver},
                              #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value = RoleAttr#p_role_attr.silver_bind}],
            common_misc:role_attr_change_notify(UnicastArg,RoleId,AttrChangeList);
        {error ,R} ->
            ?ERROR_MSG("~ts,Reason=~w",["获取角色属性出错，打造成功之后无法通知前端银子变化情况",R])
    end.

%% 绑定装备提升附加属性级别事务操作
do_t_equip_bind_attr_upgrade(RoleId,DataRecord,BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    case common_transaction:transaction(fun() ->
                                    do_transaction_equip_bind_attr_upgrade_level(RoleId,DataRecord,BinddGoodsList,ClassBindGoods,EquipBaseInfo)
                            end) of
        {atomic,{ok, UpgradeFlag,EquipGoods,DelGoodsList,UpdateGoodsList}} ->
            {ok, UpgradeFlag,EquipGoods,DelGoodsList,UpdateGoodsList};
        {aborted, Reason} ->
            ?ERROR_MSG("~ts,Reason=~w",["装备提升绑定附加属性级别事务过程失败",Reason]),
            case Reason of 
                {throw,{error,R}} ->
                    erlang:throw({error,R});
                _ ->
                    erlang:throw({error,?_LANG_EQUIP_BIND_UPGRADE_ERROR})
            end
    end.
do_transaction_equip_bind_attr_upgrade_level(RoleId,DataRecord,_BinddGoodsList,ClassBindGoods,EquipBaseInfo) ->
    EquipId = DataRecord#m_refining_equip_bind_tos.equip_id,
    BagId = DataRecord#m_refining_equip_bind_tos.bag_id,
    {[BaseGoods],[_EquipGoods]} = lists:partition(fun(R) -> R#p_goods.id =/= EquipId end, ClassBindGoods),
    BaseTypeId = BaseGoods#p_goods.typeid,
    [BindItem] = get_equip_bind_item(BaseTypeId),
    #r_equip_bind_item{item_level=ItemLevel,item_num = ItemNum}=BindItem,
    %% 扣绑定附加材料
    {ok, DelGoodsList, UpdateGoodsList} = do_transaction_equip_bind_dedcut_goods(RoleId,BagId,BaseTypeId,ItemNum),
    {ok, UpgradeFlag, NewEquipGoods} = do_transaction_equip_bind_attr_upgrade_level2(RoleId,BagId,EquipId,EquipBaseInfo,ItemLevel),
    {ok, UpgradeFlag, NewEquipGoods, DelGoodsList, UpdateGoodsList}.

do_transaction_equip_bind_attr_upgrade_level2(RoleId,BagId,EquipGoodsId,EquipBaseInfo,ItemLevel) ->
    case get_dirty_goods_by_good_id(RoleId,BagId,EquipGoodsId) of
        {error,Error} ->
            ?DEBUG("~ts,Error=~w",["获取绑定的装备物品失败",Error]),
            erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_GOODS_ERROR});
        {ok,EquipGoods} ->
            do_transaction_equip_bind_attr_upgrade_level3(RoleId,EquipGoods,EquipBaseInfo,ItemLevel)
    end.
do_transaction_equip_bind_attr_upgrade_level3(RoleId,EquipGoods,EquipBaseInfo,ItemLevel) ->
    RefiningFee =#r_refining_fee{type = equip_bind_upgrade_fee,
                                 equip_level = EquipGoods#p_goods.level,
                                 material_level = ItemLevel,
                                 refining_index = EquipGoods#p_goods.refining_index,
                                 punch_num = EquipGoods#p_goods.punch_num,
                                 stone_num = EquipGoods#p_goods.stone_num,
                                 equip_color = EquipGoods#p_goods.current_colour,
                                 equip_quality = EquipGoods#p_goods.quality},
    case mod_refining:get_refining_fee(RefiningFee) of
        {ok,Fee} ->
            do_transaction_equip_bind_attr_upgrade_level4(RoleId,EquipGoods,EquipBaseInfo,ItemLevel,Fee);
        {error,Error} ->
            erlang:throw({error,Error})
    end.
do_transaction_equip_bind_attr_upgrade_level4(RoleId,EquipGoods,EquipBaseInfo,ItemLevel,Fee) ->
    RoleId = EquipGoods#p_goods.roleid,
    EquipConsume = #r_equip_consume{type = bind,
                                    consume_type = ?CONSUME_TYPE_SILVER_EQUIP_BIND,
                                    consume_desc = ""},
    mod_refining:do_refining_deduct_fee(RoleId,Fee,EquipConsume),
    do_transaction_equip_bind_attr_upgrade_level5(RoleId,EquipGoods,EquipBaseInfo,ItemLevel).

do_transaction_equip_bind_attr_upgrade_level5(RoleId,EquipGoods,EquipBaseInfo,ItemLevel) ->
    EquipBindAttrList = EquipGoods#p_goods.equip_bind_attr,
    MaxPossibleLevel = get_possible_max_bind_attr_upgrade_level(ItemLevel),
    %% 将附加的绑定的属性级别为最高级的去掉，只随机没有达到满级的附加属性
    NewEquipBindAttrList = lists:filter(fun(Record) -> 
                                                RLevel = Record#p_equip_bind_attr.attr_level,
                                                if RLevel >= MaxPossibleLevel ->
                                                        false;
                                                   true ->
                                                        true
                                                end
                                        end,EquipBindAttrList),
    Len = erlang:length(NewEquipBindAttrList),
    RandomNumber = random:uniform(Len),
    AttrRecord = lists:nth(RandomNumber,NewEquipBindAttrList),
    AttrCode = AttrRecord#p_equip_bind_attr.attr_code,
    AttrLevel = AttrRecord#p_equip_bind_attr.attr_level,
    case is_equip_bind_attr_max_level(AttrCode,AttrLevel) of
        true ->
            {ok,1,EquipGoods};%%随机到的附加属性已经是最高级别，不需要提升
        false ->
            do_transaction_equip_bind_attr_upgrade_level6(RoleId,EquipGoods,EquipBaseInfo,ItemLevel,AttrRecord);
        error ->
            {ok,2,EquipGoods} %% 随机到的附加属性，在配置中查找不到，有可能是历史版本配置参数改变所造成的
    end.
do_transaction_equip_bind_attr_upgrade_level6(RoleId,EquipGoods,EquipBaseInfo,ItemLevel,AttrRecord) ->
    #p_equip_bind_attr{attr_level=AttrLevel}=AttrRecord,
    %% 根据附加材料的级别概率计算出本次获取的级别
    NewLevel = get_equip_bind_attr_upgrade_level(ItemLevel),
    if NewLevel > AttrLevel ->
            do_transaction_equip_bind_attr_upgrade_level7(RoleId,EquipGoods,EquipBaseInfo,ItemLevel,AttrRecord,NewLevel);
       true ->
            {ok,3,EquipGoods}
    end.
do_transaction_equip_bind_attr_upgrade_level7(RoleId,EquipGoods,EquipBaseInfo,_ItemLevel,AttrRecord,NewLevel) ->
    #p_equip_bind_attr{attr_code=AttrCode,attr_level=Level,type=AddType,value=Value}=AttrRecord,
    MainProperty = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.main_property,
    DelEquipGoods = count_bind_add_attr_one(AttrCode,del,EquipBaseInfo,EquipGoods,MainProperty,AddType,Level,Value),
    %% 获取装备绑定义的属性级别和加成记录
    [EquipBindAttr] = get_equip_bind_attr(AttrCode,NewLevel),
    #r_equip_bind_attr{add_type = NewAddType, value = NewValue} = EquipBindAttr,
    AddEquipGoods = count_bind_add_attr_one(AttrCode,add,EquipBaseInfo,DelEquipGoods,MainProperty,NewAddType,NewLevel,NewValue),
    NewEquipGoods = case common_misc:do_calculate_equip_refining_index(AddEquipGoods) of
                        {error,ErrorCode} ->
                            ?DEBUG("~ts,RefiningIndexErrorCode=~w",["计算装备精炼系数出错",ErrorCode]),
                            AddEquipGoods;
                        {ok, RIGoods} ->
                            RIGoods
                    end,
    mod_bag:update_goods(RoleId,NewEquipGoods),
    {ok,0,NewEquipGoods}.
      
    
%% 装备绑定事务操作过程
do_t_equip_bind_attr_change(RoleId,DataRecord,BinddGoodsList,ClassBindGoods,
                            EquipBaseInfo,NumberProbability,LevelProbability) ->
    case common_transaction:transaction(fun() -> 
                                    do_transaction_equip_bind_count_attr({RoleId,DataRecord,
                                                                          BinddGoodsList,
                                                                          ClassBindGoods,
                                                                          EquipBaseInfo,
                                                                          NumberProbability,LevelProbability})
                            end) of
        {atomic,{ok,EquipGoods,DelGoodsList,UpdateGoodsList}} ->
            {ok,EquipGoods,DelGoodsList,UpdateGoodsList};
        {aborted, Reason} ->
            ?ERROR_MSG("~ts,Reason=~w",["装备绑定事务过程失败",Reason]),
            case Reason of 
                {throw,{error,R}} ->
                    erlang:throw({error,R});
                _ ->
                    erlang:throw({error,?_LANG_EQUIP_BIND_ERROR})
            end
    end.

%% 装备绑定
do_transaction_equip_bind_count_attr({RoleId,DataRecord,_BinddGoodsList,ClassBindGoods,
                                      EquipBaseInfo,NumberProbability,LevelProbability}) ->
    %% 更新消耗绑定基础物品，算出装备附加属性，更新装备物品属性
    EquipId = DataRecord#m_refining_equip_bind_tos.equip_id,
    BagId = DataRecord#m_refining_equip_bind_tos.bag_id,
    {[BaseGoods],[_EquipGoods]} = lists:partition(fun(R) -> R#p_goods.id =/= EquipId end, ClassBindGoods),
    BaseTypeId = BaseGoods#p_goods.typeid,
    [BindItem] = get_equip_bind_item(BaseTypeId),
    #r_equip_bind_item{item_num = ItemNum} = BindItem,
    %% 扣绑定基础材料
    {ok, DelGoodsList, UpdateGoodsList} = do_transaction_equip_bind_dedcut_goods(RoleId,BagId,BaseTypeId,ItemNum),
    %% 更新装备物品属性，需要添加字段保存装备上一次绑定的附加属性
    {ok,NewEquipGoods} = do_transaction_equip_bind_update_attr({RoleId,BagId,EquipId,EquipBaseInfo,
                                                                NumberProbability,LevelProbability}),
    {ok, NewEquipGoods, DelGoodsList, UpdateGoodsList}.
    

do_transaction_equip_bind_update_attr({RoleId,BagId,EquipGoodsId,EquipBaseInfo,NumberProbability,LevelProbability}) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipGoods = 
        case get_dirty_goods_by_good_id(RoleId,BagId,EquipGoodsId) of
            {error,Error} ->
                ?DEBUG("~ts,Error=~w",["获取绑定的装备物品失败",Error]),
                erlang:throw({error,?_LANG_EQUIP_BIND_EQUIP_GOODS_ERROR});
            {ok,EquipGoodsT} ->
                EquipGoodsT
        end,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,NumberProbability,LevelProbability),
    do_transaction_equip_bind_update_attr3(RoleId,EquipGoods,EquipBaseInfo,AttrList).

do_transaction_equip_bind_update_attr3(RoleId,EquipGoods,EquipBaseInfo,AttrList) ->
    %% 先清除已经绑定加成的属性
    OldAttrList = EquipGoods#p_goods.equip_bind_attr,
    case OldAttrList of
        undefined ->
            %% 装备没有绑定加成属性
            %% NewEquipGoods = EquipGoods#p_goods{equip_bind_attr = []},
            do_transaction_equip_bind_update_attr3_1(RoleId,EquipGoods,EquipBaseInfo,AttrList);
        [] ->
            %% 装备没有绑定加成属性
            do_transaction_equip_bind_update_attr3_1(RoleId,EquipGoods,EquipBaseInfo,AttrList);
        _ ->
            do_transaction_equip_bind_update_attr3_2(RoleId,EquipGoods,EquipBaseInfo,OldAttrList,AttrList)
    end.

do_transaction_equip_bind_update_attr3_1(RoleId,EquipGoods,EquipBaseInfo,AttrList) ->
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,EquipGoods),
    RefiningIndexGoods = case common_misc:do_calculate_equip_refining_index(AddEquipGoods) of
                             {error,ErrorCode} ->
                                 ?DEBUG("~ts,RefiningIndexErrorCode=~w",["计算装备精炼系数出错",ErrorCode]),
                                 AddEquipGoods;
                             {ok, RIGoods} ->
                                 RIGoods
                         end,
    NewEquipGoods = RefiningIndexGoods#p_goods{bind = true,use_bind = 0},
    mod_bag:update_goods(RoleId,NewEquipGoods),
    do_transaction_equip_bind_update_attr4(NewEquipGoods).

do_transaction_equip_bind_update_attr3_2(RoleId,EquipGoods,EquipBaseInfo,OldAttrList,AttrList) ->
    %% 记录结构转换 p_equip_bind_attr  -> r_equip_bind_attr
    NewOldAttrList = lists:map(fun(PR) ->
                                       #r_equip_bind_attr{attr_code = PR#p_equip_bind_attr.attr_code,
                                                          add_type = PR#p_equip_bind_attr.type, 
                                                          level = PR#p_equip_bind_attr.attr_level, 
                                                          value = PR#p_equip_bind_attr.value}
                               end,OldAttrList),
    DelEquipGoods = count_bind_add_attr(NewOldAttrList,del,EquipBaseInfo,EquipGoods),
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,DelEquipGoods),
    NewEquipGoods = case common_misc:do_calculate_equip_refining_index(AddEquipGoods) of
                        {error,ErrorCode} ->
                            ?DEBUG("~ts,RefiningIndexErrorCode=~w",["计算装备精炼系数出错",ErrorCode]),
                            AddEquipGoods;
                        {ok, RIGoods} ->
                            RIGoods
                    end,
    NewEquipGoods2 = NewEquipGoods#p_goods{bind = true,use_bind = 0},
    mod_bag:update_goods(RoleId,NewEquipGoods2),
    do_transaction_equip_bind_update_attr4(NewEquipGoods2).

do_transaction_equip_bind_update_attr4(NewEquipGoods) ->
    RefiningFee =#r_refining_fee{type = equip_bind_fee,
                                 equip_level = NewEquipGoods#p_goods.level,
                                 refining_index = NewEquipGoods#p_goods.refining_index,
                                 punch_num = NewEquipGoods#p_goods.punch_num,
                                 stone_num = NewEquipGoods#p_goods.stone_num,
                                 equip_color = NewEquipGoods#p_goods.current_colour,
                                 equip_quality = NewEquipGoods#p_goods.quality},
    case mod_refining:get_refining_fee(RefiningFee) of
        {ok,Fee} ->
           do_transaction_equip_bind_update_attr5(NewEquipGoods,Fee);
        {error,Error} ->
            erlang:throw({error,Error})
    end.
do_transaction_equip_bind_update_attr5(NewEquipGoods,Fee) ->
    RoleId = NewEquipGoods#p_goods.roleid,
    EquipConsume = #r_equip_consume{type = bind,      
                                    consume_type = ?CONSUME_TYPE_SILVER_EQUIP_BIND,
                                    consume_desc = ""},
    mod_refining:do_refining_deduct_fee(RoleId,Fee,EquipConsume),
    {ok, NewEquipGoods}.
    
%% 重新计算装备属性，根据OpType操作类型处理
%% OpType: add添加附加属性处理，del删除附加属性处理
count_bind_add_attr([],_OpType,_EquipBaseInfo,EquipGoods) ->
    EquipGoods;
count_bind_add_attr([H|T],OpType,EquipBaseInfo,EquipGoods) ->
    #r_equip_bind_attr{attr_code = AttrCode, add_type = AddType, level = Level, value = Value} = H,
    MainProperty = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.main_property,
    NewEquipGoods = count_bind_add_attr_one(AttrCode,OpType,EquipBaseInfo,EquipGoods,MainProperty,AddType,Level,Value),
    count_bind_add_attr(T,OpType,EquipBaseInfo,NewEquipGoods).

%% Param 参数AttrCode,OpType,MainProperty,AddType,Level,Value
%% OpType 操作类型 add加属性，del减属性
count_bind_add_attr_one(1,OpType,EquipBaseInfo,EquipGoods,MainProperty,AddType,Level,Value) ->
    %% 主属性，1:生命值,2:物理,3:法力,4:外防,5:内防
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 1,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    if MainProperty =:= 1 ->
            GoodsBlood = (EquipGoods#p_goods.add_property)#p_property_add.blood,
            BaseBlood = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.blood,
            NewGoodsBlood = count_bind_add_attr_one_value(OpType,GoodsBlood,BaseBlood,AddType,Value),
            AddProperty1 = (EquipGoods#p_goods.add_property)#p_property_add{blood = NewGoodsBlood},
            EquipGoods#p_goods{add_property = AddProperty1,equip_bind_attr = NewAttrList};
       MainProperty =:= 2 ->
            GoodsMinPhyAtt = (EquipGoods#p_goods.add_property)#p_property_add.min_physic_att,
            GoodsMaxPhyAtt = (EquipGoods#p_goods.add_property)#p_property_add.max_physic_att,
            %% BaseMinPhyAtt = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.min_physic_att,
            BaseMaxPhyAtt = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.max_physic_att,
            NewGoodsMinPhyAtt = count_bind_add_attr_one_value(OpType,GoodsMinPhyAtt,BaseMaxPhyAtt,AddType,Value),
            NewGoodsMaxPhyAtt = count_bind_add_attr_one_value(OpType,GoodsMaxPhyAtt,BaseMaxPhyAtt,AddType,Value),
            AddProperty2 = (EquipGoods#p_goods.add_property)#p_property_add{min_physic_att= NewGoodsMinPhyAtt,
                                                                           max_physic_att= NewGoodsMaxPhyAtt},
            EquipGoods#p_goods{add_property = AddProperty2,equip_bind_attr = NewAttrList};
       MainProperty =:= 3 ->
            GoodsMinMgcAtt = (EquipGoods#p_goods.add_property)#p_property_add.min_magic_att,
            GoodsMaxMgcAtt = (EquipGoods#p_goods.add_property)#p_property_add.max_magic_att,
            %% BaseMinMgcAtt = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.min_magic_att,
            BaseMaxMgcAtt = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.max_magic_att,
            NewGoodsMinMgcAtt = count_bind_add_attr_one_value(OpType,GoodsMinMgcAtt,BaseMaxMgcAtt,AddType,Value),
            NewGoodsMaxMgcAtt = count_bind_add_attr_one_value(OpType,GoodsMaxMgcAtt,BaseMaxMgcAtt,AddType,Value),
            AddProperty3 = (EquipGoods#p_goods.add_property)#p_property_add{min_magic_att= NewGoodsMinMgcAtt,
                                                                        max_magic_att= NewGoodsMaxMgcAtt},
            EquipGoods#p_goods{add_property = AddProperty3,equip_bind_attr = NewAttrList};
       MainProperty =:= 4 ->
            GoodsPhyDef = (EquipGoods#p_goods.add_property)#p_property_add.physic_def,
            BasePhyDef = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.physic_def,
            NewGoodsPhyDef = count_bind_add_attr_one_value(OpType,GoodsPhyDef,BasePhyDef,AddType,Value),
            AddProperty4 = (EquipGoods#p_goods.add_property)#p_property_add{physic_def= NewGoodsPhyDef},
            EquipGoods#p_goods{add_property = AddProperty4,equip_bind_attr = NewAttrList};
       MainProperty =:= 5 ->
            GoodsMgcDef = (EquipGoods#p_goods.add_property)#p_property_add.magic_def,
            BaseMgcDef = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.magic_def,
            NewGoodsMgcDef = count_bind_add_attr_one_value(OpType,GoodsMgcDef,BaseMgcDef,AddType,Value),
            AddProperty5 = (EquipGoods#p_goods.add_property)#p_property_add{magic_def = NewGoodsMgcDef},
            EquipGoods#p_goods{add_property = AddProperty5,equip_bind_attr = NewAttrList};
       true ->
            EquipGoods
    end;
count_bind_add_attr_one(2,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 2、力量
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 2,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.power,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.power,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{power = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList};
count_bind_add_attr_one(3,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 3、敏捷
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 3,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.agile,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.agile,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{agile = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList};
count_bind_add_attr_one(4,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 4、智力
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 4,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.brain,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.brain,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{brain = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList};
count_bind_add_attr_one(5,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 5、精神
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 5,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.spirit,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.spirit,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{spirit = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList};
count_bind_add_attr_one(6,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 6、体质
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 6,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.vitality,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.vitality,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{vitality = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList};
count_bind_add_attr_one(7,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 7、最大生命值
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 7,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.blood,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.blood,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{blood = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList};
count_bind_add_attr_one(8,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 8、最大法力值
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 8,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.magic,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.magic,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{magic = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList};
count_bind_add_attr_one(9,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 9、生命恢复速度
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 9,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.blood_resume_speed,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.blood_resume_speed,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{blood_resume_speed = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList};
count_bind_add_attr_one(10,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 10、法力恢复速度
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 10,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.magic_resume_speed,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.magic_resume_speed,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{magic_resume_speed = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList};
count_bind_add_attr_one(11,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 11、攻击速度
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 11,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.attack_speed,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.attack_speed,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{attack_speed = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList};

count_bind_add_attr_one(12,OpType,EquipBaseInfo,EquipGoods,_MainProperty,AddType,Level,Value) ->
    %% 12、移动速度
    AttrList = EquipGoods#p_goods.equip_bind_attr,
    PEquipBindAttr = #p_equip_bind_attr{attr_code = 12,type = AddType,attr_level = Level,value = Value},
    NewAttrList = count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr),
    GoodsValue = (EquipGoods#p_goods.add_property)#p_property_add.move_speed,
    BaseValue = (EquipBaseInfo#p_equip_base_info.property)#p_property_add.move_speed,
    NewValue = count_bind_add_attr_one_value(OpType,GoodsValue,BaseValue,AddType,Value),
    AddProperty = (EquipGoods#p_goods.add_property)#p_property_add{move_speed = NewValue},
    EquipGoods#p_goods{add_property = AddProperty,equip_bind_attr = NewAttrList}.
 
%% 根据加成类型和加成值，还有装备原来的值计算装备属性的最新值
%% 参数 OpType,GoodsValue,BaseValue,AddType,Value
count_bind_add_attr_one_value(add,GoodsValue,BaseValue,AddType,Value) ->
    if AddType =:= 1 ->
            GoodsValue + Value;
       AddType =:= 2 ->
            GoodsValue + common_tool:ceil((BaseValue * Value) / 100);
       true ->
            GoodsValue
    end;
count_bind_add_attr_one_value(del,GoodsValue,BaseValue,AddType,Value) ->
    if AddType =:= 1 ->
            GoodsValue - Value;
       AddType =:= 2 ->
            GoodsValue - common_tool:ceil((BaseValue * Value) / 100);
       true ->
            GoodsValue
    end;
count_bind_add_attr_one_value(_,GoodsValue,_BaseValue,_AddType,_Value) ->
    GoodsValue.
%% 列新装备绑定附加属性列表信息 OpType:操作类型，add添加，del删除
count_bind_attr_one_value(OpType,AttrList,PEquipBindAttr) ->
    NewAttrList = case AttrList of
                      undefined -> [];
                      _ -> AttrList
                  end,
    case OpType of
        add ->
            lists:append([NewAttrList,[PEquipBindAttr]]);
        del ->
            lists:delete(PEquipBindAttr,NewAttrList)
    end.
                           
%% 扣绑定基础材料
do_transaction_equip_bind_dedcut_goods(RoleId,BagId,BaseTypeId,ItemNum) ->
    ?DEBUG("~ts,ItemId=~w",["消耗绑定的基础材料",BaseTypeId]),
    case mod_refining_bag:get_goods_by_bag_id_and_item_id(RoleId,BagId,BaseTypeId) of
        [] ->
            ?ERROR_MSG("~ts,ItemId=~w",["角色没有绑定所需要的基础材料",BaseTypeId]),
            erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ENOUGH});
        BaseGoodsList ->
            GoodsSum = mod_equip_build:get_goods_sum(BaseGoodsList,0),
            NewBaseNum = GoodsSum - ItemNum,
            if  NewBaseNum =:= 0 -> %%此物品已经没有，必须删除
                    DeleteGoodsIds = [GoodsRecord#p_goods.id || GoodsRecord <- BaseGoodsList],
                    mod_bag:delete_goods(RoleId,DeleteGoodsIds),
                    {ok,BaseGoodsList, []};
                NewBaseNum > 0 ->
                    %%更新物品信息
                    {ok,DelList,UpdateList} = mod_equip_build:do_transaction_dedcut_goods(RoleId,BaseGoodsList,ItemNum),
                    {ok,DelList, UpdateList};
                true ->
                    ?ERROR_MSG("~ts,ItemId=~w",["角色绑定所需要的基础材料数量不够",BaseTypeId]),
                    erlang:throw({error,?_LANG_EQUIP_BIND_GOODS_ENOUGH})
            end
    end.

%% 获取角色某一个背包Id的所有物品记录
get_dirty_goods_bag_id(RoleId,BagId) ->
    case mod_refining_bag:get_goods_by_bag_id(RoleId,BagId) of
        [] ->
            {error,not_found};
        BinddGoodList ->
            {ok, BinddGoodList}
    end.

%% 获取角色某一个背包Id的物品记录
get_dirty_goods_by_good_id(RoleId,BagId,GoodsId) ->
    mod_refining_bag:get_goods_by_bag_id_goods_id(RoleId,BagId,GoodsId).

%% 将背包中的所有物品按物品类型id分类
class_equip_bind_goods([],Result) -> Result;
class_equip_bind_goods([H|T],Result) ->
    TypeId = H#p_goods.typeid,
    case lists:keyfind(TypeId, #p_goods.typeid, Result) of
        false ->
            class_equip_bind_goods(T, lists:append([Result,[H]]));
        Record ->
            ResultList = lists:delete(Record, Result),
            NewNum = Record#p_goods.current_num + H#p_goods.current_num,
            NewR = Record#p_goods{current_num = NewNum},
            class_equip_bind_goods(T, lists:append([ResultList,[NewR]]))
    end.

%% 获取装备绑定材料记录
get_equip_bind_item(ItemId) ->
    case common_config_dyn:find(equip_bind,equip_bind_item) of
        [ItemList] ->
            [R || R <- ItemList, R#r_equip_bind_item.item_id =:= ItemId];
        _ ->
            error
    end.
%% 获取装备编码对应的绑定属性记录
get_equip_bind_equip(EquipCode,Protype) ->
    case common_config_dyn:find(equip_bind,equip_bind_equip) of
        [ EquipList] ->
            [R || R <- EquipList, 
                  R#r_equip_bind_equip.equip_code =:= EquipCode,
                  R#r_equip_bind_equip.protype =:= Protype ];
        _ ->
            error
    end.
%% 获取装备绑定义的属性级别和加成记录
get_equip_bind_attr(AttrCode,AttrLevel) ->
    case common_config_dyn:find(equip_bind,equip_bind_attr) of
        [ EquipAttrList ] ->
            [R || R <- EquipAttrList, 
                  R#r_equip_bind_attr.attr_code =:= AttrCode,
                  R#r_equip_bind_attr.level =:= AttrLevel];
        _ ->
            error
    end.
%% 获取附加属性级别最高级
is_equip_bind_attr_max_level(AttrCode,Level) ->
     case common_config_dyn:find(equip_bind,equip_bind_attr) of
        [ EquipAttrList] ->
             NewAttrList = [R#r_equip_bind_attr.level || R <- EquipAttrList, 
                                R#r_equip_bind_attr.attr_code =:= AttrCode],
             MaxLevel = lists:max(NewAttrList),
             ?DEBUG("~ts,AttrCode=~w,Level=~w,MaxLevel=~w",["获取附加属性的最高级别",AttrCode,Level,MaxLevel]),
             if MaxLevel =:= Level ->
                     true;
                true ->
                     false
             end;
         _ ->
             error
     end.
%% 获取绑定时随机附加属性
%% @return [#r_equip_bind_attr] | []
get_equip_bind_random_attr(EquipColor,EquipCode,Protype,NumberProbability,LevelProbability) ->
    case get_equip_bind_equip(EquipCode,Protype) of
        []->
            [];
        [EquipBindEquip] ->
    #r_equip_bind_equip{attr_list = AttrList} = EquipBindEquip,
    AttrRandomNumber = get_equip_bind_attr_number(EquipColor,NumberProbability),
    %% 当配置可以绑定获取的属性个数，大过此装备绑定可获取的属性个数大时处理
    Len = erlang:length(AttrList),
    AttrNumber =  if AttrRandomNumber > Len ->
                          Len;
                     true ->
                          AttrRandomNumber
                  end,
            get_equip_bind_equip_attr(AttrNumber,LevelProbability,EquipBindEquip,[])
    end.
    
%% 获取装备绑定属性列表
get_equip_bind_equip_attr(0,_LevelProbability,_EquipBindEquip,Result) ->
    Result;
get_equip_bind_equip_attr(AttrNumber,LevelProbability,EquipBindEquip,Result) ->
    #r_equip_bind_equip{attr_list = AttrList} = EquipBindEquip,
    Len = erlang:length(AttrList),
    RondomNumber = random:uniform(Len),
    AttrCode = lists:nth(RondomNumber,AttrList),
    case lists:keyfind(AttrCode,#r_equip_bind_attr.attr_code,Result) of
        false ->
            AttrLevel = get_equip_bind_attr_level(LevelProbability),
            [AttrRecord] = get_equip_bind_attr(AttrCode,AttrLevel),
            NewAttrNumber = AttrNumber -1,
            NewResult = lists:append([Result,[AttrRecord]]),
            get_equip_bind_equip_attr(NewAttrNumber,LevelProbability,EquipBindEquip,NewResult);
        _ ->
            get_equip_bind_equip_attr(AttrNumber,LevelProbability,EquipBindEquip,Result)
    end.
            
%% 获取绑定时随机的附加属性个数
get_equip_bind_attr_number(EquipColor,NumberProbability) ->
    case common_config_dyn:find(equip_bind,NumberProbability) of
        [AttrNumList] ->
            AttrNumList2 = [R1 || R1 <- AttrNumList,R1#r_equip_bind_attr_number.equip_color =:= EquipColor],
            AttrNumList3 = 
                if AttrNumList2 =:= [] ->
                        [R2 || R2 <- AttrNumList,R2#r_equip_bind_attr_number.equip_color =:= 0];
                   true ->
                        AttrNumList2
                end,
            if AttrNumList3 =:= [] ->
                    ?DEFAULT_EQUIP_BIND_ATTR_NUM;
               true ->
                    get_equip_bind_attr_number2(AttrNumList3)
            end;
        _ ->
            ?DEFAULT_EQUIP_BIND_ATTR_NUM
    end.
get_equip_bind_attr_number2(AttrNumList) ->
    NumList = [R#r_equip_bind_attr_number.probability || R <- AttrNumList],
    SumNum = lists:sum(NumList),
    RandomNumber = random:uniform(SumNum),
    SortList = lists:sort(fun(Item1,Item2) -> 
                                  Item1#r_equip_bind_attr_number.attr_number =< Item2#r_equip_bind_attr_number.attr_number
                          end,AttrNumList),
    DefaulRecord = #r_equip_bind_attr_number{attr_number = ?DEFAULT_EQUIP_BIND_ATTR_NUM},
    get_equip_bind_attr_number3(SortList,RandomNumber,0,DefaulRecord,false).

get_equip_bind_attr_number3([],_RandomNumber,_Num,_Record,false) ->
    ?DEFAULT_EQUIP_BIND_ATTR_NUM;
get_equip_bind_attr_number3(_AttrNumList,_RandomNumber,_Num,Record,true) ->
    Record#r_equip_bind_attr_number.attr_number;
get_equip_bind_attr_number3([H|T],RandomNumber,Num,Record,Flag) ->
    NewNum = H#r_equip_bind_attr_number.probability + Num,
    if RandomNumber > Num andalso RandomNumber =< NewNum ->
            get_equip_bind_attr_number3(T,RandomNumber,Num,H,true);
       true ->
            get_equip_bind_attr_number3(T,RandomNumber,NewNum,Record,Flag)
    end.

%% 获取绑定时附加属性的级别
get_equip_bind_attr_level(LevelProbability) ->
    case common_config_dyn:find(equip_bind,LevelProbability) of
        [ LevelList ] ->
            get_equip_bind_attr_level2(LevelList);
        _ ->
            ?DEFAULT_EQUIP_BIND_ATTR_LEVEL
    end.
get_equip_bind_attr_level2(LevelList) ->
    NumList = [R#r_equip_bind_attr_level.probability || R <- LevelList],
    SumNum = lists:sum(NumList),
    RandomNumber = random:uniform(SumNum),
    SortList = lists:sort(fun(Item1,Item2) -> 
                                  Item1#r_equip_bind_attr_level.attr_level =< Item2#r_equip_bind_attr_level.attr_level
                          end,LevelList),
    DefaulRecord = #r_equip_bind_attr_level{attr_level = ?DEFAULT_EQUIP_BIND_ATTR_LEVEL},
    get_equip_bind_attr_level3(SortList,RandomNumber,0,DefaulRecord,false).

get_equip_bind_attr_level3([],_RandomNumber,_Num,_Record,false) ->
    ?DEFAULT_EQUIP_BIND_ATTR_LEVEL;
get_equip_bind_attr_level3(_LevelList,_RandomNumber,_Num,Record,true) ->
    Record#r_equip_bind_attr_level.attr_level;
get_equip_bind_attr_level3([H|T],RandomNumber,Num,Record,Flag) ->
    NewNum = H#r_equip_bind_attr_level.probability + Num,
    if RandomNumber > Num andalso RandomNumber =< NewNum ->
            get_equip_bind_attr_level3(T,RandomNumber,Num,H,true);
       true ->
            get_equip_bind_attr_level3(T,RandomNumber,NewNum,Record,Flag)
    end.

%% 根据附加材料的级别概率计算出本次获取的级别
get_equip_bind_attr_upgrade_level(ItemLevel) ->
    case common_config_dyn:find(equip_bind,equip_bind_add_level) of
        [AddLevelList] ->
            LevelList = [R || R <- AddLevelList, R#r_equip_bind_add_level.material_level =:= ItemLevel],
            get_equip_bind_attr_upgrade_level2(LevelList);
        _ ->
            ?DEFAULT_EQUIP_BIND_UPGRADE_ATTR_LEVEL
    end.
get_equip_bind_attr_upgrade_level2(LevelList) ->
    NumList = [R#r_equip_bind_add_level.probability || R <- LevelList],
    SumNum = lists:sum(NumList),
    RandomNumber = random:uniform(SumNum),
    SortList = lists:sort(fun(Item1,Item2) -> 
                                  Item1#r_equip_bind_add_level.attr_level =< Item2#r_equip_bind_add_level.attr_level
                          end,LevelList),
    DefaulRecord = #r_equip_bind_add_level{attr_level = ?DEFAULT_EQUIP_BIND_UPGRADE_ATTR_LEVEL},
    get_equip_bind_attr_upgrade_level3(SortList,RandomNumber,0,DefaulRecord,false).

get_equip_bind_attr_upgrade_level3([],_RandomNumber,_Num,_Record,false) ->
    ?DEFAULT_EQUIP_BIND_UPGRADE_ATTR_LEVEL;
get_equip_bind_attr_upgrade_level3(_LevelList,_RandomNumber,_Num,Record,true) ->
    Record#r_equip_bind_add_level.attr_level;
get_equip_bind_attr_upgrade_level3([H|T],RandomNumber,Num,Record,Flag) ->
    NewNum = H#r_equip_bind_add_level.probability + Num,
    if RandomNumber > Num andalso RandomNumber =< NewNum ->
            get_equip_bind_attr_upgrade_level3(T,RandomNumber,Num,H,true);
       true ->
            get_equip_bind_attr_upgrade_level3(T,RandomNumber,NewNum,Record,Flag)
    end.

%% 根据附加材料的级别获取可能提交的最高级别
get_possible_max_bind_attr_upgrade_level(MaterialLevel) ->
    case common_config_dyn:find(equip_bind,equip_bind_add_level) of
        [ AddLevelList ] ->
            LevelList = [R || R <- AddLevelList, R#r_equip_bind_add_level.material_level =:= MaterialLevel],
            get_possible_max_bind_attr_upgrade_level2(LevelList);
        _ ->
            ?DEFAULT_EQUIP_BIND_UPGRADE_ATTR_LEVEL
    end.
get_possible_max_bind_attr_upgrade_level2(LevelList) ->
    NumList = [R#r_equip_bind_add_level.attr_level || R <- LevelList],
    lists:max(NumList).

%% 装备绑定时或重刷装备绑定属性处理
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {error,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_equip_bind(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods#p_goods{bind = false}) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_equip_bind2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_equip_bind2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,equip_bind_attr_number,equip_bind_attr_level),
    EquipGoods2 = 
        case erlang:is_list(EquipGoods#p_goods.equip_bind_attr) =:= true of
            true -> %% 删除旧的绑定属性
                OldAttrList = 
                    lists:map(
                      fun(PR) ->
                              #r_equip_bind_attr{
                           attr_code = PR#p_equip_bind_attr.attr_code,
                           add_type = PR#p_equip_bind_attr.type, 
                           level = PR#p_equip_bind_attr.attr_level, 
                           value = PR#p_equip_bind_attr.value}
                      end,EquipGoods#p_goods.equip_bind_attr),
                EquipGoodsT = count_bind_add_attr(OldAttrList,del,EquipBaseInfo,EquipGoods),
                count_bind_add_attr(AttrList,add,EquipBaseInfo,EquipGoodsT);
            _ ->
                count_bind_add_attr(AttrList,add,EquipBaseInfo,EquipGoods)
        end,
    {ok,EquipGoods2#p_goods{bind = true,use_bind = 0}}.
%% 根据装备新的绑定属性重新计算装备属性
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {error,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_equip_bind_up_attr(EquipGoods,NewBindAttrList) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods#p_goods{bind = false}) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_equip_bind_up_attr2(EquipGoods,EquipBaseInfo,NewBindAttrList)
    end.
do_equip_bind_for_equip_bind_up_attr2(EquipGoods,EquipBaseInfo,NewBindAttrList) ->
    OldAttrList = 
        lists:map(
          fun(PR1) ->
                  #r_equip_bind_attr{
               attr_code = PR1#p_equip_bind_attr.attr_code,
               add_type = PR1#p_equip_bind_attr.type, 
               level = PR1#p_equip_bind_attr.attr_level, 
               value = PR1#p_equip_bind_attr.value}
          end,EquipGoods#p_goods.equip_bind_attr),
    EquipGoodsT = count_bind_add_attr(OldAttrList,del,EquipBaseInfo,EquipGoods),
    NewAttrList = 
        lists:map(
          fun(PR2) ->
                  #r_equip_bind_attr{
               attr_code = PR2#p_equip_bind_attr.attr_code,
               add_type = PR2#p_equip_bind_attr.type, 
               level = PR2#p_equip_bind_attr.attr_level, 
               value = PR2#p_equip_bind_attr.value}
          end,NewBindAttrList),
    {ok,count_bind_add_attr(NewAttrList,add,EquipBaseInfo,EquipGoodsT)}.

%% 装备打造时，绑定装备接口，
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_equip_build(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_equip_build2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_equip_build2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_build,
                                          equip_bind_attr_level_build),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.

%% 怪物掉落装备时，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_monster_flop(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_monster_flop2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_monster_flop2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_monster,
                                          equip_bind_attr_level_monster),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = []},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.
%% 装备强化，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_reinforce(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_reinforce2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_reinforce2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_reinforce,
                                          equip_bind_attr_level_reinforce),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.

%% 装备品质改造，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_quality(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_quality2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_quality2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_quality,
                                          equip_bind_attr_level_quality),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.

%% 装备升级，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_upgrade(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_upgrade2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_upgrade2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_upgrade,
                                          equip_bind_attr_level_upgrade),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.

%% 装备打孔，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_punch(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_punch2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_punch2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_punch,
                                          equip_bind_attr_level_punch),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.

%% 装备镶嵌，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_inlay(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_inlay2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_inlay2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_inlay,
                                          equip_bind_attr_level_inlay),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.
%% 后台赠送装备，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_present(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_present2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_present2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_present,
                                          equip_bind_attr_level_present),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.

%% 任务赠送装备，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_mission(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_mission2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_mission2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_mission,
                                          equip_bind_attr_level_mission),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.
%% 商店购买装备，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_buy(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_buy2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_buy2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_buy,
                                          equip_bind_attr_level_buy),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.
%% 装备五行改造时，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_fiveele(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_fiveele2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_fiveele2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_fiveele,
                                          equip_bind_attr_level_fiveele),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.
%% 天工炉炼制时，绑定装备接口
%% 参数 EquipGoods为装备的物品信息，物品信息必须有以下的属性
%% 返回 添加了绑定信息的装备物品信息
%% 注：输入参数和输出结果数据结构为 p_goods
%% 返回结果为：{ok,NewGoods}
%%           {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_for_forging(EquipGoods) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_for_forging2(EquipGoods,EquipBaseInfo)
    end.
do_equip_bind_for_forging2(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_forging,
                                          equip_bind_attr_level_forging),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.
%% 检查装备物品是不是符加绑定
%% 返回结果 {ok,EquipBaseInfo}
%%         {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
check_equip_bind_for_equip_goods(EquipGoods) ->
    if EquipGoods#p_goods.bind ->
            ?DEBUG("~ts,Bind=~w",["装备已经绑定，不需执行绑定",EquipGoods#p_goods.bind]),
            erlang:throw({error,1}); %% 装备已经绑定
       true ->
            next
    end,
    EquipTypeId = EquipGoods#p_goods.typeid,
    EquipBaseInfo = 
        case common_config_dyn:find_equip(EquipTypeId) of
            [EquipBaseInfoT] ->
                EquipBaseInfoT;
            _ ->
                erlang:throw({error,2})
        end,
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    case get_equip_bind_equip(EquipCode,EquipProtype) of
        error ->
            ?DEBUG("~ts,EquipCode=~w,EquipProtype=~w",["装备绑定时装备类型编码出错",EquipCode,EquipProtype]),
            erlang:throw({error,3}); %% 装备类型不合法
        _ ->
            {ok,EquipBaseInfo}
    end.
    
%% 装备升级时，没有保留装备属性时，重新获取绑定属性
do_equip_rebind_for_equip_upgrade(EquipGoods,EquipBaseInfo) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,
                                          equip_bind_attr_number_upgrade,
                                          equip_bind_attr_level_upgrade),
    NewAttrList = [#p_equip_bind_attr{
                      attr_code = R#r_equip_bind_attr.attr_code,
                      type = R#r_equip_bind_attr.add_type,
                      attr_level = R#r_equip_bind_attr.level,
                      value =  R#r_equip_bind_attr.value
                     } ||R <- AttrList],
    EquipGoods#p_goods{equip_bind_attr=NewAttrList}.
    

    
%% 装备升级时，重新计算装备的绑定属性加成
do_equip_bind_for_equip_upgrade(EquipGoods,EquipBaseInfo) ->
    EquipBindAttr = EquipGoods#p_goods.equip_bind_attr,
    if erlang:is_list(EquipBindAttr)
       andalso erlang:length(EquipBindAttr) > 0 ->
            %% if EquipGoods#p_goods.bind ->
            do_equip_bind_for_equip_upgrade2(EquipGoods,EquipBaseInfo);
       true ->
            EquipGoods
    end.
do_equip_bind_for_equip_upgrade2(EquipGoods,EquipBaseInfo) ->  
    BindAttrList = EquipGoods#p_goods.equip_bind_attr,
    case BindAttrList of 
        undefined ->
            EquipGoods;
        [] ->
            EquipGoods;
        _ ->
            do_equip_bind_for_equip_upgrade3(EquipGoods,EquipBaseInfo,BindAttrList)
    end.
do_equip_bind_for_equip_upgrade3(EquipGoods,EquipBaseInfo,BindAttrList) ->
    NewAttrList = lists:map(fun(PR) ->
                                    #r_equip_bind_attr{attr_code = PR#p_equip_bind_attr.attr_code,
                                                       add_type = PR#p_equip_bind_attr.type, 
                                                       level = PR#p_equip_bind_attr.attr_level, 
                                                       value = PR#p_equip_bind_attr.value}
                            end,BindAttrList),
    NewEquipGoods = EquipGoods#p_goods{equip_bind_attr=[]},
    count_bind_add_attr(NewAttrList,add,EquipBaseInfo,NewEquipGoods).

%% 道具礼包装备 处理装备的绑定属性
do_equip_bind_for_item_gift(EquipGoods,EquipBaseInfo,AddBindAttrList) ->
    EquipGoods2 = EquipGoods#p_goods{equip_bind_attr=[]},
    [EquipAttrList] = common_config_dyn:find(equip_bind,equip_bind_attr),
    NewAttrList = 
        lists:foldl(
          fun({Code,Level},AccNewAttrList) ->
                  case lists:foldl(
                         fun(#r_equip_bind_attr{attr_code = AttrCode,level = AttrLevel} = EquipBindAttrRecordT,EquipBindAttrRecord) ->
                                 case (EquipBindAttrRecord =:= undefined 
                                       andalso Code =:= AttrCode
                                       andalso Level =:= AttrLevel) of
                                     true ->
                                         EquipBindAttrRecordT;
                                     false ->
                                         EquipBindAttrRecord
                                 end
                         end,undefined,EquipAttrList) of
                      undefined ->
                          AccNewAttrList;
                      AccEquipBindAttrRecord ->
                          [AccEquipBindAttrRecord|AccNewAttrList]
                  end
          end,[],AddBindAttrList),
    count_bind_add_attr(NewAttrList,add,EquipBaseInfo,EquipGoods2).

%% 检查装备物品是不是符加绑定
%% 返回结果 {ok,EquipBaseInfo}
%%         {ok,ErrorCode}
%% {1,装备已经绑定},{2,装备基本属性不合法},{3,装备类型不合法}
do_equip_bind_by_config_atom(EquipGoods,AddAttrNumberAtom,AddAttrLevelAtom) ->
    case catch check_equip_bind_for_equip_goods(EquipGoods) of
        {error,R} ->
            {error,R};
        {ok,EquipBaseInfo} ->
            do_equip_bind_by_config_atom(EquipGoods,EquipBaseInfo,AddAttrNumberAtom,AddAttrLevelAtom)
    end.
do_equip_bind_by_config_atom(EquipGoods,EquipBaseInfo,AddAttrNumberAtom,AddAttrLevelAtom) ->
    EquipCode = EquipBaseInfo#p_equip_base_info.slot_num,
    EquipProtype = EquipBaseInfo#p_equip_base_info.protype,
    EquipColor = EquipGoods#p_goods.current_colour,
    %% 获取绑定时随机附加属性 [#r_equip_bind_attr]
    AttrList = get_equip_bind_random_attr(EquipColor,EquipCode,EquipProtype,AddAttrNumberAtom,AddAttrLevelAtom),
    NewEquipGoods = EquipGoods#p_goods{bind = true,equip_bind_attr = [],use_bind = 0},
    AddEquipGoods = count_bind_add_attr(AttrList,add,EquipBaseInfo,NewEquipGoods),
    {ok,AddEquipGoods}.
