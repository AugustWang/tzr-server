%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2010, 
%%% @doc
%%% 装备五行
%%% @end
%%% Created : 23 Oct 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_equip_fiveele).

%% Include files
-include("mgeem.hrl").
-include("equip_build.hrl").
-include("refining.hrl").

%% API
-export([
         do_random_equip_whole_attr/1, %% 装备套装属性预处理
         %% 装备缷下进，针对五行和套装属性进行进理
         %% 参数为p_goods
         %% 返回 EquipGoods
         do_clean_equip_five_ele_and_whole_attr/1,
         %% 装备五行属性和装备套装属性处理
         %% 当装备被使用时需要处理，即装备穿上，装备缷下，装备失效（耐久度为0）
         %% 计算当前人物身上的有效装，即除了副手，饰品，即包括
         %% 1:武器,2:项链,3:戒指,4:头盔,5:胸甲,6:腰带,7:护腕,8:靴子,
         %% 需要处理装备五行，装备套装
         %% 参数：EquipList：人物当前的装备列表
         %% 返回值，
         %% {NewEquipList,[]} 不需要处理套装加成buff只需更新装备信息
         %% {NewEquipList,WholeAttrBuffList} 需要处理处理套装加成buff更新装备信息
         do_equip_five_ele_and_whole_attr/1,
         %% 装备五行和套装部件列表
         get_equip_fiveele_and_whole_slot/0,
         %% 根据人物身上的装备获取套装信息
         %% 参数 EquipList装备列表[p_goods,....] IsEndurance 是否判断耐久度
         %% 返回 {ok,WholeRecord,SubWholeRecord}, {error,no_whole}
         get_equip_whole_attr_record/2,
         %% 获取套装加成属性buff List
         %% 参数，EquipList[p_goods,....] 装备列表,IsEndurance 是否判断耐久度
         %% 返回  WholeAttrBuffList,[]
         get_equip_whole_attr_buff/2,
         %% 成就系统使用此接口
         do_achievement_equip_whole_attr/1
        ]).

-export([do_equip_build_fiveele_goods/2,
         do_equip_build_fiveele/2]).

%% 获取装备五行改造材料
do_equip_build_fiveele_goods({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State) ->
    case get_is_open_equip_five_ele_fun() of
        false ->
            Reason = ?_LANG_EQUIP_CHANGE_FIVEELE_IS_OPEN,
            do_equip_build_fiveele_goods_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State,Reason);
        true ->
            do_equip_build_fiveele_goods2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State)
    end.
do_equip_build_fiveele_goods2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State) ->
    Material = DataRecord#m_equip_build_fiveele_goods_tos.material,
    MaterialList = mod_equip_build:get_equip_build_material_dict(),
    NewMaterialList = lists:append([MaterialList,[0]]),
    case lists:member(Material, NewMaterialList) of 
        false ->
            Reason = ?_LANG_EQUIP_CHANGE_FIVEELE_PARAM_ERROR,
            do_equip_build_fiveele_goods_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State,Reason);
        true ->
            do_equip_build_fiveele_goods3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State)
    end.
do_equip_build_fiveele_goods3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State) ->
    Material = DataRecord#m_equip_build_fiveele_goods_tos.material,
    if Material =:= 0 ->
            do_equip_build_fiveele_goods4({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State);
       true ->
            do_equip_build_fiveele_goods5({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State)
    end.
do_equip_build_fiveele_goods4({Unique, Module, Method, DataRecord, RoleId, _Pid, Line},_State) ->
    Material = DataRecord#m_equip_build_fiveele_goods_tos.material,
    AddList = mod_equip_build:get_dirty_equip_build_goods_list(?EQUIP_BUILD_ADD,RoleId),
    NewAddList = mod_equip_build:count_class_equip_build_goods(AddList,[]),
    FiveGoods = get_five_ele_item_goods(RoleId),
    FiveGoods2 = mod_equip_build:count_class_equip_build_goods(FiveGoods,[]),
    SendSelf = #m_equip_build_fiveele_goods_toc{succ = true,material = Material,add_list = NewAddList},
    SendSelf2 = 
        if FiveGoods2 =/= [] ->
                [FiveGoods3] = FiveGoods2,
                SendSelf#m_equip_build_fiveele_goods_toc{five_good = FiveGoods3};
           true ->
                SendSelf
        end,
    common_misc:unicast(Line,RoleId, Unique, Module, Method,SendSelf2).

do_equip_build_fiveele_goods5({Unique, Module, Method, DataRecord, RoleId, _Pid, Line},_State) ->
    Material = DataRecord#m_equip_build_fiveele_goods_tos.material,
    AddList = mod_equip_build:get_dirty_equip_build_goods_list(?EQUIP_BUILD_ADD,RoleId),
    NewAddList = mod_equip_build:count_class_equip_build_goods(AddList,[]),
    AddMaterial = mod_equip_build:get_equip_build_class_goods(Material,?EQUIP_BUILD_ADD),
    NewAddList2 = lists:filter(fun(AR) ->
                                        case lists:keyfind(AR#p_equip_build_goods.type_id,
                                                           #r_equip_build_item.item_id, AddMaterial) of
                                            false -> false;
                                            _ -> true
                                        end 
                               end,NewAddList),
    FiveGoods = get_five_ele_item_goods(RoleId),
    FiveGoods2 = mod_equip_build:count_class_equip_build_goods(FiveGoods,[]),
    SendSelf = #m_equip_build_fiveele_goods_toc{succ = true,material = Material,add_list = NewAddList2},
    SendSelf2 = 
        if FiveGoods2 =/= [] ->
                [FiveGoods3] = FiveGoods2,
                SendSelf#m_equip_build_fiveele_goods_toc{five_good = FiveGoods3};
           true ->
                SendSelf
        end,
    common_misc:unicast(Line,RoleId, Unique, Module, Method,SendSelf2).

do_equip_build_fiveele_goods_error({Unique, Module, Method, DataRecord, RoleId, _Pid, Line},_State,Reason) ->
    Material = DataRecord#m_equip_build_fiveele_goods_tos.material,
    SendSelf = #m_equip_build_fiveele_goods_toc{succ = false,reason = Reason,material= Material},
    common_misc:unicast(Line,RoleId, Unique, Module, Method,SendSelf).

%% 装备五行改造处理
do_equip_build_fiveele({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State) ->
    case catch do_equip_build_fiveele2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State) of 
        {error,Error} ->
            ?DEBUG("~ts,Error=~w",["装备五行改造验证出错",Error]),
            do_equip_build_fiveele_error({Unique,Module,Method,Error, RoleId, Pid, Line},State);
        {ok, EquipGoods,EquipInfo,LinkEquipBaseInfoList,ItemRecord} ->
            do_equip_build_fiveele3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},State,
                             EquipGoods,EquipInfo,LinkEquipBaseInfoList,ItemRecord)
    end.

do_equip_build_fiveele2({_Unique, _Module, _Method, DataRecord, RoleId, _Pid, _Line},_State) ->
    case get_is_open_equip_five_ele_fun() of
        false ->
            erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_IS_OPEN});
        true ->
            next
        end,
    Type = DataRecord# m_equip_build_fiveele_tos.type,
    EquipId = DataRecord# m_equip_build_fiveele_tos.equip_id,
    GoodTypeId = DataRecord# m_equip_build_fiveele_tos.good_type_id,
    EquipGoods = case get_dirty_goods_by_id(RoleId,EquipId) of
                     {error, E} ->
                         ?DEBUG("~ts,Error=~w",["查询需要装备五行改造信息出错",E]),
                         erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_EQUIP_ERROR});
                     {ok, EGoods} ->
                         EGoods
                 end,
    if Type =:= 1 ->
            if erlang:is_record(EquipGoods#p_goods.five_ele_attr,p_equip_five_ele) ->
                    erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_TYPE_ERROR2});
               true ->
                    next
            end;
       Type =:= 2 orelse Type =:= 3 ->
            if erlang:is_record(EquipGoods#p_goods.five_ele_attr,p_equip_five_ele) ->
                   next;
               true ->
                    erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_TYPE_ERROR3})
            end;
       true ->
            erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_TYPE_ERROR})
    end,
    EquipInfo = case mod_equip:get_equip_baseinfo(EquipGoods#p_goods.typeid) of
                    error ->
                        erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_EQUIP_ERROR});
                    {ok,EInfo} ->
                        EInfo
                end,
    LinkEquipBaseInfoList = 
        case get_equip_fiveele_link_equip_info(EquipGoods,EquipInfo) of
            {error,Error} ->
                ?DEBUG("~ts,Error=~w,EquipGoods",["此装备不是套装不可以获取五行属性",EquipGoods,Error]),
                erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_WHOLE_EQUIP});
            {ok,LEquipBaseInfoList} ->
                if erlang:is_list(LEquipBaseInfoList) 
                   andalso erlang:length(LEquipBaseInfoList) > 0 ->
                        LEquipBaseInfoList;
                   true ->
                        erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_WHOLE_EQUIP})
                end
        end,
    if GoodTypeId =:= 0 ->
            erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_GOOD_ERROR});
       true ->
            next
    end,
    ItemRecord = 
        if Type =:= 1 orelse Type =:= 2 ->
                IR = get_five_ele_item(),
                if IR#r_equip_fiveele_material.type_id =:= GoodTypeId ->
                        IR;
                   true ->
                        erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_GOOD_ERROR})
                end;
           Type =:= 3 ->
                %% 根据附加材料的id进行查找此附加材料记录
                Material = EquipInfo#p_equip_base_info.material,
                case mod_equip_build:get_equip_build_class_goods(Material,?EQUIP_BUILD_ADD) of
                    [] ->
                        ?DEBUG("~ts,Material=~w",["根据装备的材质询不到可用的附加材料",Material]),
                        erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_GOOD_ERROR});
                    TypeIdList ->
                        case lists:keyfind(GoodTypeId,#r_equip_build_item.item_id,TypeIdList) of
                            false ->
                                ?DEBUG("~ts,Material=~w,GoodTypeId=~w",["附加材料跟装备所需的附加材料不合法",Material,GoodTypeId]),
                                erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_GOOD_ERROR});
                            R ->
                                R
                        end
                end;
           true ->
                erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_TYPE_ERROR})
        end,
    ItemRecord2 = 
        if Type =:= 3 ->
                ItemLevel = ItemRecord#r_equip_build_item.level,
                case get_equip_fiveele_upgrade_material(ItemLevel) of
                    undefined ->
                        erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_GOOD_ERROR});
                    R2 ->
                        R2
                end;
           true ->
                ItemRecord
        end,
    if Type =:= 3 ->
            FiveeleAttr = EquipGoods#p_goods.five_ele_attr,
            MaxLevel = get_equip_fiveele_upgrade_max_level(),
            if FiveeleAttr#p_equip_five_ele.level >= MaxLevel ->
                    ?DEBUG("~ts,FiveLevel=~w,MaxLevel=~w",["装备五行级别已是最高级别",FiveeleAttr#p_equip_five_ele.level,MaxLevel]),
                    erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_MAX_LEVEL});
               true ->
                    next
            end;
       true ->
            next
    end,
    if Type =:= 3 ->
            LevelMaxLevel = get_equip_fiveele_upgrade_max_level(ItemRecord2#r_equip_fiveele_upgrade_material.item_level),
            FiveeleAttr2 = EquipGoods#p_goods.five_ele_attr,
            if FiveeleAttr2#p_equip_five_ele.level >= LevelMaxLevel ->
                    erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_GOOD_LEVEL});
               true ->
                    next
            end;
       true ->
            next
    end,
    {ok,EquipGoods,EquipInfo,LinkEquipBaseInfoList,ItemRecord2}.
do_equip_build_fiveele3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                        State,EquipGoods,EquipInfo,LinkEquipBaseInfoList,ItemRecord) ->
    Type = DataRecord# m_equip_build_fiveele_tos.type,
    if Type =:= 1 ->
            do_equip_build_fiveele_first({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                         State,EquipGoods,EquipInfo,LinkEquipBaseInfoList,ItemRecord);
       Type =:= 2 ->
            do_equip_build_fiveele_first({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                         State,EquipGoods,EquipInfo,LinkEquipBaseInfoList,ItemRecord);
       Type =:= 3 ->
            do_equip_build_fiveele_upgrade({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                           State,EquipGoods,EquipInfo,LinkEquipBaseInfoList,ItemRecord);
       true ->
            Reason = ?_LANG_EQUIP_CHANGE_FIVEELE_TYPE_ERROR,
            do_equip_build_fiveele_error({Unique, Module, Method, Reason, RoleId, Pid, Line},State)
    end.

do_equip_build_fiveele_first({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                         State,EquipGoods,EquipInfo,LinkEquipBaseInfoList,ItemRecord) ->
    case get_equip_fiveele_attr(LinkEquipBaseInfoList) of
        {error,undefined} ->
            Reason = ?_LANG_EQUIP_CHANGE_FIVEELE_ERROR,
            do_equip_build_fiveele_error({Unique, Module, Method, Reason, RoleId, Pid, Line},State);
        {ok,EquipFiveEle} ->
            do_equip_build_fiveele_first2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                         State,EquipGoods,EquipInfo,ItemRecord,EquipFiveEle)
    end.
do_equip_build_fiveele_first2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                         State,EquipGoods,EquipInfo,ItemRecord,EquipFiveEle) ->
    %% 获取费用
    RefiningFee =#r_refining_fee{type = equip_five_ele_fee,
                                 equip_level = EquipGoods#p_goods.level,
                                 refining_index = EquipGoods#p_goods.refining_index,
                                 punch_num = EquipGoods#p_goods.punch_num,
                                 stone_num = EquipGoods#p_goods.stone_num,
                                 equip_color = EquipGoods#p_goods.current_colour,
                                 equip_quality = EquipGoods#p_goods.quality},
    case mod_refining:get_refining_fee(RefiningFee) of
        {ok,Fee} ->
            do_equip_build_fiveele_first3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                          State,EquipGoods,EquipInfo,ItemRecord,EquipFiveEle,Fee);
        {error,Error} ->
            do_equip_build_fiveele_error({Unique, Module, Method, Error, RoleId, Pid, Line},State)          
    end.

do_equip_build_fiveele_first3({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                         State,EquipGoods,EquipInfo,ItemRecord,EquipFiveEle,Fee) ->
    case catch do_t_equip_build_fiveele_first(RoleId,DataRecord,EquipGoods,EquipInfo,ItemRecord,EquipFiveEle,Fee) of
        {error,Error} ->
             ?DEBUG("~ts,Error=~w",["装备五行改造出错",Error]),
             do_equip_build_fiveele_error({Unique,Module,Method, Error, RoleId, Pid, Line},State),
             do_equip_fiveele_deduct_fee_notify(RoleId, Line);
        {ok,NewEquip,DeleteLists,UpdateLists} ->
             do_equip_build_fiveele_first4({Unique,Module,Method,DataRecord, RoleId, Pid, Line},
                                          State,NewEquip,DeleteLists,UpdateLists)
    end.

do_equip_build_fiveele_first4({Unique,Module,Method,DataRecord, RoleId, Pid, Line},
                                          State,NewEquip,DeleteLists,UpdateLists) ->
    AddList = mod_equip_build:get_dirty_equip_build_goods_list(?EQUIP_BUILD_ADD,RoleId),
    NewAddList = mod_equip_build:count_class_equip_build_goods(AddList,[]),
    FiveGoods = get_five_ele_item_goods(RoleId),
    FiveGoods2 = mod_equip_build:count_class_equip_build_goods(FiveGoods,[]),
    SendSelf = #m_equip_build_fiveele_toc{succ = true,equip=NewEquip, add_list = NewAddList},
    SendSelf2 = 
        if FiveGoods2 =/= [] ->
                [FiveGoods3] = FiveGoods2,
                SendSelf#m_equip_build_fiveele_toc{five_good = FiveGoods3};
           true ->
                SendSelf
        end,
    [UsedGoods] = mod_equip_build:count_class_equip_build_goods(DeleteLists,[]),
    SendSelf3 = SendSelf2#m_equip_build_fiveele_toc{used_good = UsedGoods},
    common_misc:unicast(Line,RoleId, Unique, Module, Method,SendSelf3),
    %% 道具消费日志
    catch common_item_logger:log(RoleId,UsedGoods#p_equip_build_goods.type_id, 
                                        UsedGoods#p_equip_build_goods.current_num,
                                 undefined,?LOG_ITEM_TYPE_WU_XING_GAI_ZAO_SHI_QU),
    do_equip_build_fiveele_first5({Unique,Module,Method,DataRecord, RoleId, Pid, Line},
                                          State,NewEquip,DeleteLists,UpdateLists).
do_equip_build_fiveele_first5({_Unique,_Module,_Method,_DataRecord, RoleId, _Pid, Line},
                                          _State,_NewEquip,DeleteLists,UpdateLists) ->
    %% 材料
    NotifyBaseList = lists:filter(fun(R) -> 
                                          case lists:keyfind(R#p_goods.id,#p_goods.id,UpdateLists) of
                                              false -> true;
                                              _ -> false
                                          end
                                  end,DeleteLists),
    if NotifyBaseList =/= [] ->
            common_misc:del_goods_notify({line, Line, RoleId}, NotifyBaseList);
       true ->
            ignore
    end,
    if UpdateLists =/= [] ->
            common_misc:update_goods_notify({line, Line, RoleId},UpdateLists);
       true ->
            next
    end,
    do_equip_fiveele_deduct_fee_notify(RoleId, Line).
    %% common_misc:update_goods_notify({line, Line, RoleId},NewEquip).

do_t_equip_build_fiveele_first(RoleId,DataRecord,EquipGoods,EquipInfo,ItemRecord,EquipFiveEle,Fee) ->
    case db:transaction(fun() -> 
                                do_t_equip_build_fiveele_first2(RoleId,DataRecord,EquipGoods,EquipInfo,
                                                                ItemRecord,EquipFiveEle,Fee)
                        end) of
        {atomic,{ok,NewEquip,DelGoddsList,UpdateGoodsList}} ->
            {ok,NewEquip,DelGoddsList,UpdateGoodsList};
        {aborted, Reason} ->
            case Reason of 
                {throw,{error,R}} ->
                    erlang:throw({error,R});
                _ ->
                    ?DEBUG("~ts,Reason=~w",["装备五行改造失败",Reason]),
                    erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_ERROR})
            end
    end.
do_t_equip_build_fiveele_first2(RoleId,DataRecord,EquipGoods,_EquipInfo,ItemRecord,EquipFiveEle,Fee) ->
    %% 扣费
    EquipConsume = #r_equip_consume{type = fiveele,     
                                    consume_type = ?CONSUME_TYPE_SILVER_EQUIP_FIVEELE,
                                    consume_desc = ""},
    mod_refining:do_refining_deduct_fee(RoleId,Fee,EquipConsume),
    %% 扣除材料
    BagIdList = mod_equip_build:get_equip_build_bag_id(),
    GoodTypeId = DataRecord# m_equip_build_fiveele_tos.good_type_id,
    GoodNumber = ItemRecord#r_equip_fiveele_material.number,
    {DelGoodsList,UpdateGoddsList} = 
        case mod_equip_change:do_transaction_consume_goods(RoleId,BagIdList,GoodTypeId,GoodNumber) of
            {error,Error} ->
                ?DEBUG("~ts,Error=~w",["扣除材料出错",Error]),
                erlang:throw({error,Error});
            {ok,DBList,UBList} ->
                {DBList,UBList}
        end,
    MatrailBind1 = mod_equip_change:do_check_matrail_bind(DelGoodsList),
    MatrailBind2 = mod_equip_change:do_check_matrail_bind(UpdateGoddsList),
    EquipGoods2 = 
        if EquipGoods#p_goods.bind ->
                EquipGoods;
           true ->
                if MatrailBind1 orelse MatrailBind2 ->
                        case mod_refining_bind:do_equip_bind_for_fiveele(EquipGoods) of
                            {error,BindError} ->
                                ?DEBUG("~ts,BindError=~w",["处理材料为绑定时，装备五行改造绑定出错",BindError]),
                                EquipGoods#p_goods{bind = true};
                            {ok,BindGoods} ->
                                BindGoods
                        end;
                   true ->
                        EquipGoods
                end
        end,    
    do_t_equip_build_fiveele_first3(RoleId,DataRecord,EquipGoods2,EquipFiveEle,DelGoodsList,UpdateGoddsList).

do_t_equip_build_fiveele_first3(RoleId,_DataRecord,EquipGoods,EquipFiveEle,DelGoodsList,UpdateGoddsList) ->
    EquipGoods2 = EquipGoods#p_goods{five_ele_attr = EquipFiveEle},
    %% 精炼系数处理
    EquipGoods3 = case common_misc:do_calculate_equip_refining_index(EquipGoods2) of
                      {error,ErrorCode} ->
                          ?DEBUG("~ts,ErrorCode=~w",["计算装备精炼系数出错",ErrorCode]),
                          EquipGoods2;
                      {ok,RefiningIndexGoods} ->
                          RefiningIndexGoods
                  end,
    %% EquipGoods4 = do_random_equip_whole_attr(EquipGoods3),
    mod_bag:update_goods(RoleId,EquipGoods3),
    {ok,EquipGoods3,DelGoodsList,UpdateGoddsList}.

do_equip_build_fiveele_upgrade({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                               State,EquipGoods,EquipInfo,_LinkEquipBaseInfoList,ItemRecord) ->
    %% 根据概率获取使用附加材料时的五行级别
    ItemLevel = ItemRecord#r_equip_fiveele_upgrade_material.item_level,
    NewLevel = get_equip_fiveele_u_level(ItemLevel),
    RefiningFee =#r_refining_fee{type = equip_five_ele_upgrade_fee,
                                 equip_level = EquipGoods#p_goods.level,
                                 material_level = ItemLevel,
                                 refining_index = EquipGoods#p_goods.refining_index,
                                 punch_num = EquipGoods#p_goods.punch_num,
                                 stone_num = EquipGoods#p_goods.stone_num,
                                 equip_color = EquipGoods#p_goods.current_colour,
                                 equip_quality = EquipGoods#p_goods.quality},
    case mod_refining:get_refining_fee(RefiningFee) of
        {ok,Fee} ->
            do_equip_build_fiveele_upgrade2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                          State,EquipGoods,EquipInfo,ItemRecord,NewLevel,Fee);
        {error,Error} ->
            do_equip_build_fiveele_error({Unique, Module, Method, Error, RoleId, Pid, Line},State)          
    end.
do_equip_build_fiveele_upgrade2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},
                                State,EquipGoods,EquipInfo,ItemRecord,NewLevel,Fee) ->
    case catch do_t_equip_build_fiveele_upgrade(RoleId,DataRecord,EquipGoods,EquipInfo,ItemRecord,NewLevel,Fee) of
        {error,Error} ->
             ?DEBUG("~ts,Error=~w",["装备五行升级出错",Error]),
             do_equip_build_fiveele_error({Unique,Module,Method, Error, RoleId, Pid, Line},State),
             do_equip_fiveele_deduct_fee_notify(RoleId, Line);
        {ok,NewEquip,DeleteLists,UpdateLists,LevelFlag} ->
             do_equip_build_fiveele_upgrade3({Unique,Module,Method,DataRecord, RoleId, Pid, Line},
                                          State,NewEquip,DeleteLists,UpdateLists,LevelFlag)
    end.

do_equip_build_fiveele_upgrade3({Unique,Module,Method,DataRecord, RoleId, Pid, Line},
                                          State,NewEquip,DeleteLists,UpdateLists,LevelFlag) ->
    AddList = mod_equip_build:get_dirty_equip_build_goods_list(?EQUIP_BUILD_ADD,RoleId),
    NewAddList = mod_equip_build:count_class_equip_build_goods(AddList,[]),
    FiveGoods = get_five_ele_item_goods(RoleId),
    FiveGoods2 = mod_equip_build:count_class_equip_build_goods(FiveGoods,[]),
    SendSelf = #m_equip_build_fiveele_toc{succ = true,equip=NewEquip, add_list = NewAddList},
    SendSelf2 = 
        if FiveGoods2 =/= [] ->
                [FiveGoods3] = FiveGoods2,
                SendSelf#m_equip_build_fiveele_toc{five_good = FiveGoods3};
           true ->
                SendSelf
        end,
    [UsedGoods] = mod_equip_build:count_class_equip_build_goods(DeleteLists,[]),
    SendSelf3 = SendSelf2#m_equip_build_fiveele_toc{used_good = UsedGoods},
    ?DEBUG("~ts,LevelFlag=~w",["装备五行升级改造级别是否提升",LevelFlag]),
    SendSelf4 = case LevelFlag of
                    true ->
                        SendSelf3;
                    false ->
                        Reason = ?_LANG_EQUIP_CHANGE_FIVEELE_U_NO_CHANGE,
                        SendSelf3#m_equip_build_fiveele_toc{succ = false,reason = Reason}
                end,
    common_misc:unicast(Line,RoleId, Unique, Module, Method,SendSelf4),
    %% 道具消费日志
    catch common_item_logger:log(RoleId,UsedGoods#p_equip_build_goods.type_id, 
                                        UsedGoods#p_equip_build_goods.current_num,
                                 undefined,?LOG_ITEM_TYPE_WU_XING_GAI_ZAO_SHI_QU),
    do_equip_build_fiveele_upgrade4({Unique,Module,Method,DataRecord, RoleId, Pid, Line},
                                          State,NewEquip,DeleteLists,UpdateLists).
do_equip_build_fiveele_upgrade4({_Unique,_Module,_Method,_DataRecord, RoleId, _Pid, Line},
                                          _State,_NewEquip,DeleteLists,UpdateLists) ->
    %% 材料
    NotifyBaseList = lists:filter(fun(R) -> 
                                          case lists:keyfind(R#p_goods.id,#p_goods.id,UpdateLists) of
                                              false -> true;
                                              _ -> false
                                          end
                                  end,DeleteLists),
    if NotifyBaseList =/= [] ->
            common_misc:del_goods_notify({line, Line, RoleId}, NotifyBaseList);
       true ->
            ignore
    end,
    if UpdateLists =/= [] ->
            common_misc:update_goods_notify({line, Line, RoleId},UpdateLists);
       true ->
            next
    end,
    do_equip_fiveele_deduct_fee_notify(RoleId, Line).
    %% common_misc:update_goods_notify({line, Line, RoleId},NewEquip).
   
do_t_equip_build_fiveele_upgrade(RoleId,DataRecord,EquipGoods,EquipInfo,ItemRecord,NewLevel,Fee) ->
    case db:transaction(fun() -> 
                                do_t_equip_build_fiveele_upgrade2(RoleId,DataRecord,EquipGoods,EquipInfo,
                                                                  ItemRecord,NewLevel,Fee)
                        end) of
        {atomic,{ok,NewEquip,DelGoddsList,UpdateGoodsList,LevelFlag}} ->
            {ok,NewEquip,DelGoddsList,UpdateGoodsList,LevelFlag};
        {aborted, Reason} ->
            case Reason of 
                {throw,{error,R}} ->
                    erlang:throw({error,R});
                _ ->
                    ?DEBUG("~ts,Reason=~w",["装备五行升级失败",Reason]),
                    erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_ERROR})
            end
    end.
do_t_equip_build_fiveele_upgrade2(RoleId,DataRecord,EquipGoods,_EquipInfo,ItemRecord,NewLevel,Fee) ->
    %% 扣费
    EquipConsume = #r_equip_consume{type = fiveele,          
                                    consume_type = ?CONSUME_TYPE_SILVER_EQUIP_FIVEELE,
                                    consume_desc = ""},
    mod_refining:do_refining_deduct_fee(RoleId,Fee,EquipConsume),
    %% 扣除材料
    BagIdList = mod_equip_build:get_equip_build_bag_id(),
    GoodTypeId = DataRecord#m_equip_build_fiveele_tos.good_type_id,
    GoodNumber = ItemRecord#r_equip_fiveele_upgrade_material.item_num,
    {DelGoodsList,UpdateGoddsList} = 
        case mod_equip_change:do_transaction_consume_goods(RoleId,BagIdList,GoodTypeId,GoodNumber) of
            {error,Error} ->
                ?DEBUG("~ts,Error=~w",["扣除材料出错",Error]),
                erlang:throw({error,Error});
            {ok,DBList,UBList} ->
                {DBList,UBList}
        end,
    MatrailBind1 = mod_equip_change:do_check_matrail_bind(DelGoodsList),
    MatrailBind2 = mod_equip_change:do_check_matrail_bind(UpdateGoddsList),
    EquipGoods2 = 
        if EquipGoods#p_goods.bind ->
                EquipGoods;
           true ->
                if MatrailBind1 orelse MatrailBind2 ->
                        case mod_refining_bind:do_equip_bind_for_fiveele(EquipGoods) of
                            {error,BindError} ->
                                ?DEBUG("~ts,BindError=~w",["处理装备五行升级时,材料为绑定装备绑定处理失败",BindError]),
                                EquipGoods#p_goods{bind = true};
                            {ok,BindGoods} ->
                                BindGoods
                        end;
                   true ->
                        EquipGoods
                end
        end,         
    do_t_equip_build_fiveele_upgrade3(RoleId,EquipGoods2,NewLevel,DelGoodsList,UpdateGoddsList).

do_t_equip_build_fiveele_upgrade3(RoleId,EquipGoods,NewLevel,DelGoodsList,UpdateGoddsList) ->
    FiveEleAttr = EquipGoods#p_goods.five_ele_attr,
    OldLevel = FiveEleAttr#p_equip_five_ele.level,
    EquipGoods2 = 
        if OldLevel >= NewLevel ->
                EquipGoods;
           true ->
                Code = get_equip_fiveele_attr_code(FiveEleAttr),
                NewFiveEleAttr = 
                    case get_equip_fiveele_ative_attr(Code,NewLevel) of 
                        undefined ->
                            ?DEBUG("~ts,Code=~w,NewLevel=~w",["根据五行级别和编码无法找到五行加成值",Code,NewLevel]),
                            erlang:throw({error,?_LANG_EQUIP_CHANGE_FIVEELE_U_ERROR});
                        _ ->
                            get_equip_fiveele_attr2(FiveEleAttr,Code,NewLevel)
                    end,
                EquipGoods#p_goods{five_ele_attr = NewFiveEleAttr}
        end,
        %% 精炼系数处理
    EquipGoods3 = case common_misc:do_calculate_equip_refining_index(EquipGoods2) of
                      {error,ErrorCode} ->
                          ?DEBUG("~ts,ErrorCode=~w",["计算装备精炼系数出错",ErrorCode]),
                          EquipGoods2;
                      {ok,RefiningIndexGoods} ->
                          RefiningIndexGoods
                  end,
    %% EquipGoods4 = do_random_equip_whole_attr(EquipGoods3),
    mod_bag:update_goods(RoleId,EquipGoods3),
    LevelFlag = if OldLevel >= NewLevel ->
                        false;
                   true ->
                        true
                end,
    {ok,EquipGoods3,DelGoodsList,UpdateGoddsList,LevelFlag}.

do_equip_build_fiveele_error({Unique, Module, Method, Reason, RoleId, _Pid, Line},_State) ->
    SendSelf = #m_equip_build_fiveele_toc{succ = false,reason = Reason},
    common_misc:unicast(Line,RoleId, Unique, Module, Method,SendSelf).

%% 获取装备五行记录
get_equip_fiveele_attr(LinkEquipBaseInfoList) ->
    Id = random:uniform(5),
    AttrIndex = random:uniform(5),
    Level = get_equip_fiveele_level(),
    Active = 0,
    FiveeleAttrRecord = #p_equip_five_ele{id = Id, active = Active},
    case get_equip_fiveele_attr2(FiveeleAttrRecord,AttrIndex,Level) of
        undefined ->
            {error,undefined};
        Record ->
            TypeIds = [R#p_equip_base_info.typeid|| R<-LinkEquipBaseInfoList],
            EquipNames = [R#p_equip_base_info.equipname|| R<-LinkEquipBaseInfoList],
            SlotNums = [R#p_equip_base_info.slot_num || R <- LinkEquipBaseInfoList],
            SlotNum = if SlotNums =:= [] -> 
                              0; 
                         true -> 
                              [HSlotNum|_TSlotNums] = SlotNums,
                              HSlotNum
                      end,
            [HTypeId|_TTypeId] = TypeIds,
            %% 根据装备的typeid 获取装备的套装属性
            WholeName = get_equip_equip_whole_attr(HTypeId),
            {ok,Record#p_equip_five_ele{type_id = TypeIds,
                                        equip_name = EquipNames,
                                        link_slot_num = SlotNum,
                                        whole_name = WholeName}}
    end.
    

get_equip_fiveele_attr2(FiveeleAttrRecord,AttrIndex,Level) ->
    case get_equip_fiveele_ative_attr(AttrIndex, Level) of
        undefined ->
            undefined;
        Record ->
            FiveeleAttrRecord2 = FiveeleAttrRecord#p_equip_five_ele{level = Level},
            Value = Record#r_equip_fiveele_attr.value,
            if AttrIndex =:= 1 ->
                    FiveeleAttrRecord2#p_equip_five_ele{phy_anti = Value};
               AttrIndex =:= 2 ->
                    FiveeleAttrRecord2#p_equip_five_ele{magic_anti = Value};
               AttrIndex =:= 3 ->
                    FiveeleAttrRecord2#p_equip_five_ele{hurt = Value};
               AttrIndex =:= 4 ->
                    FiveeleAttrRecord2#p_equip_five_ele{no_defence = Value};
               AttrIndex =:= 5 ->
                    FiveeleAttrRecord2#p_equip_five_ele {hurt_rebound = Value};
               true ->
                    undefined
            end
    end.
                    

%% 根据装备的基本属性查找装备相生的装备信息
%% 要装备套装属性中查找 如果不是套装即不可以获取得到装备的五行属性
get_equip_fiveele_link_equip_info(EquipGoods,EquipInfo) ->
    case common_config_dyn:find(equip_five_ele,equip_fiveele_link) of
        [ LinkLists ] ->
            get_equip_fiveele_link_equip_info2(EquipGoods,EquipInfo,LinkLists);
            
        _ ->
            {error,undefined_link}
    end.
get_equip_fiveele_link_equip_info2(EquipGoods,EquipInfo,LinkLists) ->
    SlotNum = EquipInfo#p_equip_base_info.slot_num,
    case get_equip_fiveele_link_slot_num(LinkLists,SlotNum,false,0) of
        0 ->
            {error,not_link};
        LinkSlotNum ->
            get_equip_fiveele_link_equip_info3(EquipGoods,EquipInfo,LinkLists,LinkSlotNum)
    end.
get_equip_fiveele_link_equip_info3(EquipGoods,EquipInfo,_LinkLists,LinkSlotNum) ->
    TypeId = EquipGoods#p_goods.typeid,
    case get_equip_fiveele_link_equip_info4(TypeId) of
        {error,Error} ->
            {error,Error};
        {ok,WholeAttrList} ->
            if erlang:is_list(WholeAttrList) andalso erlang:length(WholeAttrList) =:= 1 ->
                    [WholeAttrRecord] = WholeAttrList,
                    get_equip_fiveele_link_equip_info5(EquipGoods,EquipInfo,LinkSlotNum,WholeAttrRecord);
               true ->
                    {error,whole_config_error}
            end
    end.
%% 根据装备的typeid 获取装备的套装属性
get_equip_equip_whole_attr(TypeId) ->
    case get_equip_fiveele_link_equip_info4(TypeId) of
        {error,Error} ->
            ?DEBUG("~ts,TypeId=~w,Error=~w",["查询不到此装备的套装信息",TypeId,Error]),
            "";
         {ok,WholeAttrList} ->
            if erlang:is_list(WholeAttrList) andalso erlang:length(WholeAttrList) =:= 1 ->
                    [WholeAttrRecord] = WholeAttrList,
                    WholeAttrRecord#r_equip_whole_attr.name;
               true ->
                    ""
            end
    end.
%% 在装备套装属性配置表中查找此装的五行生相装备
get_equip_fiveele_link_equip_info4(TypeId) ->
    WholeAttrList = common_config_dyn:list(equip_whole_attr),
    case lists:foldl(
           fun(#r_equip_whole_attr{equip_list = EquipList} = R,Acc) ->
                   case lists:member(TypeId,EquipList) of
                       true ->
                           [R|Acc];
                       false ->
                           Acc       
                   end
           end,[],WholeAttrList) of
        [] ->
            ?INFO_MSG("~ts,TypeId=~w",["此装备在套装配置表中查询不到",TypeId]),
            {error,not_found};
        List->
            ?DEBUG("~ts,Length=~w",["获取的装备套装数据存在多个",erlang:length(List)]),
            {ok,List}
    end.

get_equip_fiveele_link_equip_info5(_EquipGoods,_EquipInfo,LinkSlotNum,WholeAttrRecord) ->
    EquipList = WholeAttrRecord#r_equip_whole_attr.equip_list,
    LinkEquipBaseInfoList = get_equip_fiveele_link_type_id(EquipList,LinkSlotNum,[]),
    {ok, LinkEquipBaseInfoList}.
    
get_equip_fiveele_link_type_id([],_LinkSlotNum,Result) ->
    Result;
get_equip_fiveele_link_type_id([H|T],LinkSlotNum,Result) ->
    case mod_equip:get_equip_baseinfo(H) of
        error ->
            get_equip_fiveele_link_type_id(T,LinkSlotNum,Result);
        {ok,EInfo} ->
            SlotNum = EInfo#p_equip_base_info.slot_num,
            if LinkSlotNum =:= SlotNum ->
                    get_equip_fiveele_link_type_id(T,LinkSlotNum,[EInfo|Result]);
               true ->
                    get_equip_fiveele_link_type_id(T,LinkSlotNum,Result)
            end
    end.
%% 查找装备相生连接表中的下一个装备位置
get_equip_fiveele_link_slot_num([],_SlotNum,_Flag,Acc) ->
    Acc;
get_equip_fiveele_link_slot_num(_LinkList,_SlotNum,true,Acc) ->
    Acc;
get_equip_fiveele_link_slot_num([H|T],SlotNum,Flag,Acc) ->
    if H =:= SlotNum ->
            if erlang:is_list(T) andalso erlang:length(T) > 0 ->
                    [TH|_TT] = T,
                    get_equip_fiveele_link_slot_num(T,SlotNum,true,TH);
               true ->
                    get_equip_fiveele_link_slot_num(T,SlotNum,true,0)
            end;
       true ->
            get_equip_fiveele_link_slot_num(T,SlotNum,Flag,Acc)
    end.
%% 根据装备五行属性记录获取五行属性的编码
get_equip_fiveele_attr_code(FiveEleAttrRecord) ->
    PhyAnti = FiveEleAttrRecord#p_equip_five_ele.phy_anti,
    MagicAnti = FiveEleAttrRecord#p_equip_five_ele.magic_anti,
    Hurt = FiveEleAttrRecord#p_equip_five_ele.hurt,
    NoDefence = FiveEleAttrRecord#p_equip_five_ele.no_defence,
    HurtRebound = FiveEleAttrRecord#p_equip_five_ele.hurt_rebound,
    if PhyAnti =/= 0 ->
            1;
       MagicAnti =/= 0->
            2;
       Hurt =/= 0 ->
            3;
       NoDefence =/= 0 ->
            4;
       HurtRebound =/= 0 ->
            5;
       true ->
            0
    end.

%% 根据激活的五行属性编码和级别查询激活五行记录
get_equip_fiveele_ative_attr(Code, Level) ->
    case common_config_dyn:find(equip_five_ele,equip_fiveele_attr) of
        [ RecordList ] -> 
            RsList = [R || R <- RecordList,
                         R#r_equip_fiveele_attr.code =:= Code,
                         R#r_equip_fiveele_attr.level =:= Level
                     ],
            if erlang:length(RsList) =:= 1 ->
                    [R] = RsList,
                    R;
               true ->
                    undefined
            end;
        _ -> 
            undefined
    end.

%% 根据概率获取使用五行珠材料时的五行级别
get_equip_fiveele_level() ->
    case common_config_dyn:find(equip_five_ele,equip_fiveele_attr_level) of
        [ Record ] -> 
            case catch get_equip_fiveele_level2(Record) of
                {ok,Level} ->
                    Level
            end;
        _ -> 
            1
    end.
get_equip_fiveele_level2(Record)->
    #r_equip_fiveele_attr_level{level_1 = Level_1,
                                level_2 = Level_2,
                                level_3 = Level_3,
                                level_4 = Level_4,
                                level_5 = Level_5,
                                level_6 = Level_6}=Record,
    SumNumber = Level_1 + Level_2 + Level_3 + Level_4 + Level_5 + Level_6,
    RandomNumber = random:uniform(SumNumber),
    if Level_1 > 0 andalso RandomNumber =< Level_1 ->
            erlang:throw({ok,1});
       Level_2 > 0 andalso  RandomNumber >= (Level_1 + 1)
       andalso RandomNumber =< (Level_1 + Level_2) ->
            erlang:throw({ok,2});
       Level_3 > 0 andalso RandomNumber >= (Level_1 + Level_2 + 1)
       andalso RandomNumber =< (Level_1 + Level_2 + Level_3) ->
            erlang:throw({ok,3});
       Level_4 > 0 andalso RandomNumber >= (Level_1 + Level_2 + Level_3 + 1)
       andalso RandomNumber =< (Level_1 + Level_2 + Level_3 + Level_4) ->
            erlang:throw({ok,4});
       Level_5 > 0 andalso RandomNumber >= (Level_1 + Level_2 + Level_3 + Level_4 + 1)
       andalso RandomNumber =< (Level_1 + Level_2 + Level_3 + Level_4 + Level_5) ->
            erlang:throw({ok,5});
       Level_6 > 0 andalso RandomNumber >= (Level_1 + Level_2 + Level_3 + Level_4 + Level_5 + 1)
       andalso RandomNumber =< (Level_1 + Level_2 + Level_3 + Level_4 + Level_5 + Level_6) ->
            erlang:throw({ok,6});
       true ->
            ({ok,1})
    end.

%% 根据概率获取使用附加材料时的五行级别
get_equip_fiveele_u_level(ItemLevel) ->
    case get_equip_fiveele_upgrade_material(ItemLevel) of
        undefined ->
            0;
        R ->
           case catch  get_equip_fiveele_u_level2(ItemLevel,R) of
               {ok,Level} ->
                   Level
           end
    end.
get_equip_fiveele_u_level2(_ItemLevel,R) ->
    #r_equip_fiveele_upgrade_material{
                         level_1 = Level_1,
                         level_2 = Level_2,
                         level_3 = Level_3,
                         level_4 = Level_4,
                         level_5 = Level_5,
                         level_6 = Level_6
                        } = R,
    LevelList = [{1,Level_1},{2,Level_2},{3,Level_3},
                 {4,Level_4},{5,Level_5},{6,Level_6}],
    SumNumber = lists:foldl(fun({_,Level},Acc) -> Acc + Level end, 0, LevelList),
    RandomNumber = random:uniform(SumNumber),
    if Level_1 > 0 andalso RandomNumber =< Level_1 ->
            erlang:throw({ok,1});
       Level_2 > 0 andalso  RandomNumber >= (Level_1 + 1)
       andalso RandomNumber =< (Level_1 + Level_2) ->
            erlang:throw({ok,2});
       Level_3 > 0 andalso RandomNumber >= (Level_1 + Level_2 + 1)
       andalso RandomNumber =< (Level_1 + Level_2 + Level_3) ->
            erlang:throw({ok,3});
       Level_4 > 0 andalso RandomNumber >= (Level_1 + Level_2 + Level_3 + 1)
       andalso RandomNumber =< (Level_1 + Level_2 + Level_3 + Level_4) ->
            erlang:throw({ok,4});
       Level_5 > 0 andalso RandomNumber >= (Level_1 + Level_2 + Level_3 + Level_4 + 1)
       andalso RandomNumber =< (Level_1 + Level_2 + Level_3 + Level_4 + Level_5) ->
            erlang:throw({ok,5});
       Level_6 > 0 andalso RandomNumber >= (Level_1 + Level_2 + Level_3 + Level_4 + Level_5 + 1)
       andalso RandomNumber =< (Level_1 + Level_2 + Level_3 + Level_4 + Level_5 + Level_6) ->
            erlang:throw({ok,6});
       true ->
            ({ok,1})
    end.
%% 获取装备五行改造升级材料配置
get_equip_fiveele_upgrade_material(ItemLevel) ->
    case common_config_dyn:find(equip_five_ele,equip_fiveele_upgrade_material) of
        [ RecordList ] -> 
            case lists:keyfind(ItemLevel,#r_equip_fiveele_upgrade_material.item_level,RecordList) of
                false ->
                    undefined;
                R ->
                    R
            end;
        _ -> 
            undefined
    end.
%% 获取装备五行改造的最高级别
get_equip_fiveele_upgrade_max_level()->
    case common_config_dyn:find(equip_five_ele,equip_fiveele_upgrade_material) of
        [ RecordList ] -> 
            lists:foldl(fun(Record,Acc) ->
                                Level = Record#r_equip_fiveele_upgrade_material.item_level,
                                if Level > Acc ->
                                        Level;
                                   true ->
                                        Acc
                                end
                        end,0,RecordList);
        _ ->
            0
    end.
%% 获取装备五行改造附加材料可以提升的最高级别
get_equip_fiveele_upgrade_max_level(ItemLevel) ->
    case get_equip_fiveele_upgrade_material(ItemLevel) of
        undefined ->
            0;
        R ->
            get_equip_fiveele_upgrade_max_level2(ItemLevel,R)
    end.
get_equip_fiveele_upgrade_max_level2(_ItemLevel,R) ->
    LevelList = [
                 {1,R#r_equip_fiveele_upgrade_material.level_1},
                 {2,R#r_equip_fiveele_upgrade_material.level_2},
                 {3,R#r_equip_fiveele_upgrade_material.level_3},
                 {4,R#r_equip_fiveele_upgrade_material.level_4},
                 {5,R#r_equip_fiveele_upgrade_material.level_5},
                 {6,R#r_equip_fiveele_upgrade_material.level_6}
                ],
    lists:foldl(fun({Level,Probability},MaxLevel) ->
                        if Probability =/= 0 ->
                                Level; 
                           true ->
                                MaxLevel
                        end
                       end, 0,LevelList).

%% 根据物品id获取物品详细信息
get_dirty_goods_by_id(RoleId,GoodsId) ->
    BagIds = mod_equip_build:get_equip_build_bag_id(),
    mod_refining_bag:get_goods_by_bag_ids_and_goods_id(RoleId,BagIds,GoodsId).

%% 获取五行珠材料id
get_five_ele_item() ->
    case common_config_dyn:find(equip_five_ele,equip_fiveele_material) of
        [ Record ] -> Record;
        _ -> undefined
    end.
get_five_ele_item_goods(RoleId) ->
    TypeId = 
        case get_five_ele_item() of
            undefined ->
                0;
            IteamRecord ->
                IteamRecord#r_equip_fiveele_material.type_id
        end,
    BagIds = mod_equip_build:get_equip_build_bag_id(),
    mod_refining_bag:get_goods_by_bag_ids_and_type_id(RoleId,BagIds,TypeId).
    
%% 扣费通知
do_equip_fiveele_deduct_fee_notify(RoleId, Line) ->
    UnicastArg = {line, Line, RoleId},
    case mod_map_role:get_role_attr(RoleId) of
        {ok, RoleAttr} ->
            AttrChangeList = [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value = RoleAttr#p_role_attr.silver},
                              #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value = RoleAttr#p_role_attr.silver_bind}],
            common_misc:role_attr_change_notify(UnicastArg,RoleId,AttrChangeList);
        {error ,R} ->
            ?ERROR_MSG("~ts,Reason=~w",["获取角色属性出错，装备五行改造失败之后无法通知前端银子变化情况",R])
    end.

%% 成就系统计算是否是套装装备时使用此函数处理套装属性
do_achievement_equip_whole_attr(EquipGoods) ->
    TypeId = EquipGoods#p_goods.typeid,
    case mod_equip:get_equip_baseinfo(TypeId) of
        {ok,BaseInfo} ->
            do_achievement_equip_whole_attr2(EquipGoods,BaseInfo);
        error ->
            EquipGoods
    end.
do_achievement_equip_whole_attr2(EquipGoods,BaseInfo) ->
    SlotList = get_equip_fiveele_and_whole_slot(),
    SlotNum = BaseInfo#p_equip_base_info.slot_num,
    case lists:member(SlotNum,SlotList) of
        true ->
            do_achievement_equip_whole_attr3(EquipGoods);
        false ->
            EquipGoods
    end.
do_achievement_equip_whole_attr3(EquipGoods) ->
    do_random_equip_whole_attr5(EquipGoods).

%% 根据装信息随机产生装备套装属性
do_random_equip_whole_attr(EquipGoods) ->
    case get_is_open_equip_whole_attr_fun() of
        false ->
            ?DEBUG("~ts",["装备套装功能未开放，不需要处理"]),
            EquipGoods;
        true ->
            do_random_equip_whole_attr2(EquipGoods)
    end.
do_random_equip_whole_attr2(EquipGoods) ->
    TypeId = EquipGoods#p_goods.typeid,
    case mod_equip:get_equip_baseinfo(TypeId) of
        {ok,BaseInfo} ->
            do_random_equip_whole_attr3(EquipGoods,BaseInfo);
        error ->
            EquipGoods
    end.

do_random_equip_whole_attr3(EquipGoods,BaseInfo) ->
    SlotList = get_equip_fiveele_and_whole_slot(),
    SlotNum = BaseInfo#p_equip_base_info.slot_num,
    case lists:member(SlotNum,SlotList) of
        true ->
            do_random_equip_whole_attr4(EquipGoods);
        false ->
            EquipGoods
    end.
do_random_equip_whole_attr4(EquipGoods) ->
    Color = get_equip_whole_attr_color(),
    RoleId = EquipGoods#p_goods.roleid,
    SignRoleId = EquipGoods#p_goods.sign_role_id,
    CurrentColour = EquipGoods#p_goods.current_colour,
    if CurrentColour >= Color
       andalso RoleId =:= SignRoleId ->
            do_random_equip_whole_attr5(EquipGoods);
       true ->
            EquipGoods
    end.

do_random_equip_whole_attr5(EquipGoods) ->
    TypeId = EquipGoods#p_goods.typeid,
    WholeAttrList = common_config_dyn:list(equip_whole_attr),
    case lists:foldl(
           fun(#r_equip_whole_attr{equip_list = EquipList} = R,AccWholeAttrList) ->
                   case lists:member(TypeId,EquipList) of
                       true ->
                           [R|AccWholeAttrList];
                       false ->
                           AccWholeAttrList          
                   end
           end,[],WholeAttrList) of
        [] ->
            ?INFO_MSG("~ts,TypeId=~w",["此装备不是套装",TypeId]),
            EquipGoods;
        EquipWholeAttrList ->
            do_random_equip_whole_attr6(EquipGoods,EquipWholeAttrList)
    end.

do_random_equip_whole_attr6(EquipGoods,WholeAttrList) ->
    if erlang:length(WholeAttrList) =:= 1 ->
            [WholeAttrRecord] = WholeAttrList,
            #r_equip_whole_attr{id = Id,name = Name,sub_whole = SubWholeList} = WholeAttrRecord,
            SubIdList = [SubWholeRecord#r_equip_sub_whole_attr.id || SubWholeRecord <-  SubWholeList],
            MaxIndex = lists:max(SubIdList),
            Index = random:uniform(MaxIndex),
            DataRecord = #p_equip_whole_attr{id=Id,
                                             sub_id = 0,
                                             active = 0,
                                             name = Name,
                                             index = Index,
                                             number = 1
                                            },
            EquipGoods#p_goods{whole_attr = DataRecord};
       true ->
            ?DEBUG("~ts",["查找出来的套装信息存在多个不合法，不处理此装备套装信息"]),
            EquipGoods
    end.

%% 获取装备五行和装备套装的部件
get_equip_fiveele_and_whole_slot() ->
    case common_config_dyn:find(equip_five_ele,equip_fiveele_and_whole_slot) of
        [ SlotList ] -> 
            SlotList;
        _ -> 
            []
    end.


%% 装备缷下进，针对五行和套装属性进行进理
%% 参数为p_goods
%% 返回 EquipGoods
do_clean_equip_five_ele_and_whole_attr(EquipGoods) ->
    TypeId = EquipGoods#p_goods.typeid,
    case mod_equip:get_equip_baseinfo(TypeId) of
        {ok,BaseInfo} ->
            do_clean_equip_five_ele_and_whole_attr2(EquipGoods,BaseInfo);
        error ->
            EquipGoods
    end.

do_clean_equip_five_ele_and_whole_attr2(EquipGoods,BaseInfo) ->
    SlotList = get_equip_fiveele_and_whole_slot(),
    SlotNum = BaseInfo#p_equip_base_info.slot_num,
    case lists:member(SlotNum,SlotList) of
        false ->
            EquipGoods;
        true ->
            do_clean_equip_five_ele_and_whole_attr3(EquipGoods,BaseInfo)
    end.
do_clean_equip_five_ele_and_whole_attr3(EquipGoods,BaseInfo) ->
    EquipGoods3 = 
        case get_is_open_equip_five_ele_fun() of
            false ->
                EquipGoods;
            true ->
                FiveEleAttr = EquipGoods#p_goods.five_ele_attr,
                if erlang:is_record(FiveEleAttr,p_equip_five_ele)
                   andalso FiveEleAttr#p_equip_five_ele.id =/= 0 ->
                        [{EquipGoods2,_BaseInfo2}] = update_equip_attr_for_five_ele_attr([{EquipGoods,BaseInfo}],del,[]),
                        EquipGoods2;
                   true ->
                        EquipGoods
                end
        end,
    case get_is_open_equip_whole_attr_fun() of
        false ->
            EquipGoods3;
        true ->
            
            WholeAttr = EquipGoods3#p_goods.whole_attr,
            if  erlang:is_record(WholeAttr,p_equip_whole_attr)
                andalso WholeAttr#p_equip_whole_attr.id =/= 0 ->
                    WholeAttr2 = WholeAttr#p_equip_whole_attr{sub_id = 0,
                                                              active = 0,
                                                              desc = "", 
                                                              number = 1},
                    EquipGoods3#p_goods{whole_attr = WholeAttr2};
                true ->
                    EquipGoods3
            end
    end.
%% 装备五行属性和装备套装属性处理
%% 当装备被使用时需要处理，即装备穿上，装备缷下，装备失效（耐久度为0）
%% 计算当前人物身上的有效装，即除了副手，饰品，即包括
%% 1:武器,2:项链,3:戒指,4:头盔,5:胸甲,6:腰带,7:护腕,8:靴子,
%% 需要处理装备五行，装备套装
%% 参数：EquipList：人物当前的装备列表
%% 返回值，
%% {NewEquipList,[]} 不需要处理套装加成buff只需更新装备信息
%% {NewEquipList,WholeAttrBuffList} 需要处理处理套装加成buff更新装备信息
do_equip_five_ele_and_whole_attr(EquipList) ->
    %% 查检装是否有五行属性，并激活
    %% 装备五行和套装部件列表
    SlotList = get_equip_fiveele_and_whole_slot(),
    %% 过滤副手和其它不需要处理的装备
    NewEquipList = 
        lists:foldl(fun(Equip,Acc) ->
                            if Equip#p_goods.type =:= 3 ->
                                    TypeId = Equip#p_goods.typeid,
                                    case mod_equip:get_equip_baseinfo(TypeId) of
                                        {ok,BaseInfo} ->
                                            SlotNum = BaseInfo#p_equip_base_info.slot_num,
                                            case lists:member(SlotNum,SlotList) of
                                                false ->
                                                    Acc;
                                                true ->
                                                    [{Equip,BaseInfo}|Acc]
                                            end;
                                        error ->
                                            Acc
                                    end;
                               true ->
                                    Acc
                            end
                    end,[], EquipList),
    do_equip_five_ele_and_whole_attr2(EquipList,NewEquipList).

do_equip_five_ele_and_whole_attr2(EquipList,NewEquipList) ->
    NewEquipList2 = 
        case get_is_open_equip_five_ele_fun() of
            false ->
                NewEquipList;
            true ->
                do_equip_five_ele_and_whole_attr3(EquipList,NewEquipList)
        end,
    case get_is_open_equip_whole_attr_fun() of
        false ->
            EquipList2 = [R2 || {R2,_RT2} <- NewEquipList2],
            EquipList3 = lists:foldl(fun(Equip,AccList) ->
                                             EquipId = Equip#p_goods.id,
                                             NewAccList = lists:keydelete(EquipId,#p_goods.id,AccList),
                                             [Equip|NewAccList]
                                     end, EquipList,EquipList2),
            {EquipList3,[]};
        true ->
            do_equip_five_ele_and_whole_attr4(EquipList,NewEquipList2)
    end.
    
%% 处理装备五行
do_equip_five_ele_and_whole_attr3(EquipList,NewEquipList) ->
    %% 查找出有五行属性的装备列表，并且耐久度> 0的装备
    %% 结构为 [{EquipGoods,EquipBaseInfo},..]
    FiveEleEquipList = 
        lists:foldl(fun({Equip2,BaseInfo2},Acc) ->
                            FiveEleAttr = Equip2#p_goods.five_ele_attr,
                            CurrentEndurance = Equip2#p_goods.current_endurance,
                            if erlang:is_record(FiveEleAttr,p_equip_five_ele)
                               andalso FiveEleAttr#p_equip_five_ele.id =/= 0
                               andalso CurrentEndurance > 0 ->
                                    [{Equip2,BaseInfo2}|Acc];
                               true ->
                                    Acc
                            end
                    end,[],NewEquipList),
    %% 删除已经激活的五行属性
    %% 结构为 [{EquipGoods,EquipBaseInfo},..]
    FiveEleEquipList2 = update_equip_attr_for_five_ele_attr(FiveEleEquipList,del,[]),
    %% 将已经处理的五行属性的装备同步到装备列表
    %% 结构为 [{EquipGoods,EquipBaseInfo},..]
    FiveEleEquipList3 = [RE2 || {RE2,_RB2} <- FiveEleEquipList2],
    NewEquipList2 = sync_equip_goods_list(NewEquipList,FiveEleEquipList3,[]),
    %% 查找出激活的五行属性的装备
    %% 结构为 [{EquipGoods,EquipBaseInfo},..]
    FiveEleEquipList4 = do_handle_active_five_ele_equip(FiveEleEquipList2,EquipList,[]),
    %% 添加已经激活的五行属性
    %% 处理装备激活五行属性数据修改
    %% 结构为 [{EquipGoods,EquipBaseInfo},..]
    FiveEleEquipList5 = update_equip_attr_for_five_ele_attr(FiveEleEquipList4,add,[]),
    %% 将已经处理的五行属性的装备同步到装备列表
    %% 结构为 [{EquipGoods,EquipBaseInfo},..]
    FiveEleEquipList6 = [RE5 || {RE5,_RB5} <- FiveEleEquipList5],
    sync_equip_goods_list(NewEquipList2,FiveEleEquipList6,[]).
%% 处理装备套装
do_equip_five_ele_and_whole_attr4(EquipList,NewEquipList) ->
    %% 套装处理
    %% 参数 [{EquipGoods,EquipBaseInfo},...]
    %% 返回值 {no_whole,EquipList},{whole,EquipList,WholeRecord,SubWholeRecord}
    case do_handle_active_whole_attr_equip(NewEquipList) of
        {no_whole,NewEquipList2} ->
            EquipList2 = [R2 || {R2,_RT2} <- NewEquipList2],
            EquipList3 = lists:foldl(fun(Equip,AccList) ->
                                             EquipId = Equip#p_goods.id,
                                             NewAccList = lists:keydelete(EquipId,#p_goods.id,AccList),
                                             [Equip|NewAccList]
                                     end, EquipList,EquipList2),
            {EquipList3,[]};
        {whole,NewEquipList3,_WholeRecord,SubWholeRecord} ->
            EquipList4 = [R3 || {R3,_RT3} <- NewEquipList3],
            EquipList5 = lists:foldl(fun(Equip,AccList) ->
                                             EquipId = Equip#p_goods.id,
                                             NewAccList = lists:keydelete(EquipId,#p_goods.id,AccList),
                                             [Equip|NewAccList]
                                     end, EquipList,EquipList4),
            {EquipList5,SubWholeRecord#r_equip_sub_whole_attr.buff_list}
    end.
%% 将已经处理的五行属性的装备同步到装备列表
%% 参数结果 都是[{EquipGoods,EquipBaseInfo},..]
%% 返回 结构为 [{EquipGoods,EquipBaseInfo},..]
sync_equip_goods_list([],_DataList,ResultList) ->
    ResultList;
sync_equip_goods_list([H|T],DataList,ResultList) ->
    {EquipGoods,BaseInfo} = H,
    EquipId = EquipGoods#p_goods.id,
    case lists:keyfind(EquipId,#p_goods.id,DataList) of
        false ->
            sync_equip_goods_list(T,DataList,[H|ResultList]);
        NewEquipGoods ->
            sync_equip_goods_list(T,DataList,[{NewEquipGoods,BaseInfo}|ResultList])
    end.
    
%% 查找出激活的五行属性的装备
do_handle_active_five_ele_equip([],_EquipList,ResultList) ->
    ResultList;
do_handle_active_five_ele_equip([H|T],EquipList,ResultList) ->
    {EquipGoods,EquipBaseInfo} = H,
    FiveEleAttr = EquipGoods#p_goods.five_ele_attr,
    if erlang:is_record(FiveEleAttr,p_equip_five_ele)
       andalso FiveEleAttr#p_equip_five_ele.id =/= 0 ->
            %% 此装备有五行属性，需要查找是否激活
            case do_handle_active_five_ele_equip2(EquipGoods,EquipBaseInfo,EquipList) of
                {error,Error} ->
                    ?DEBUG("~ts,Error=~w",["获取装备五行属性激活装备信息出错",Error]),
                    do_handle_active_five_ele_equip(T,EquipList,ResultList);
                {ok,active} ->
                    do_handle_active_five_ele_equip(T,EquipList,[H|ResultList])
            end;
       true ->
            do_handle_active_five_ele_equip(T,EquipList,ResultList)
    end. 
%% 查询装备的五行相生装备基本信息
do_handle_active_five_ele_equip2(EquipGoods,EquipBaseInfo,EquipList) ->
    %% 根据装备的部件查询五行相生需要的装备记录信息
    %% 等到的结果为p_equip_base_info 
    case get_equip_fiveele_link_equip_info(EquipGoods,EquipBaseInfo) of
        {error,Error} ->
            {error,Error};
        {ok,LinkEquipBaseInfoList} when erlang:length(LinkEquipBaseInfoList) > 0->
            case do_handle_active_five_ele_equip3(LinkEquipBaseInfoList,EquipGoods,EquipList,false,false) of
                true ->
                    {ok,active};
                false ->
                    {error,no_active}
            end;
        {ok,_List} ->
            {error,no_find_link_equip}
    end.
%% 根据装备相生装备列表查询当前人物装备中是否存在
do_handle_active_five_ele_equip3([],_EquipGoods,_EquipList,_Flag,Result) ->
    Result;
do_handle_active_five_ele_equip3(_List,_EquipGoods,_EquipList,true,Result) ->
    Result;
do_handle_active_five_ele_equip3([H|T],EquipGoods,EquipList,Flag,Result) ->
    LinkTypeId = H#p_equip_base_info.typeid,
    FiveEleAttr = EquipGoods#p_goods.five_ele_attr,
    Id = FiveEleAttr#p_equip_five_ele.id,
    case check_equip_five_ele_effect(EquipList,LinkTypeId,Id,false,false) of
        true ->
            do_handle_active_five_ele_equip3(T,EquipGoods,EquipList,true,true);
        false ->
            do_handle_active_five_ele_equip3(T,EquipGoods,EquipList,Flag,Result)
    end.
%% 检查相个五行属性是否相生
check_equip_five_ele_effect([],_LinkTypeId,_Id,_Flag,Result) ->
    Result;
check_equip_five_ele_effect(_,_LinkTypeId,_Id,true,Result) ->
    Result;
check_equip_five_ele_effect([H|T],LinkTypeId,Id,Flag,Result) ->
    EquipTypeId = H#p_goods.typeid,
    if LinkTypeId =:= EquipTypeId ->
            FiveEleAttr = H#p_goods.five_ele_attr,
            if erlang:is_record(FiveEleAttr,p_equip_five_ele)
               andalso FiveEleAttr#p_equip_five_ele.id =/= 0 ->
                    Id2 = FiveEleAttr#p_equip_five_ele.id,
                    case check_equip_five_ele_effect2(Id,Id2) of
                        true ->
                            check_equip_five_ele_effect(T,LinkTypeId,Id,true,true);
                        false ->
                            check_equip_five_ele_effect(T,LinkTypeId,Id,Flag,Result)
                    end;
               true ->
                    check_equip_five_ele_effect(T,LinkTypeId,Id,Flag,Result)
            end;
       true ->
            check_equip_five_ele_effect(T,LinkTypeId,Id,Flag,Result)
    end.
        
check_equip_five_ele_effect2(Id1,Id2) ->
    EffectList = get_equip_fiveele_effect(),
    lists:member({Id1,Id2},EffectList).

%% 获取装备五行相生配置
get_equip_fiveele_effect() ->
    case common_config_dyn:find(equip_five_ele,equip_fiveele_effect) of
        [ EffectList ] -> 
            EffectList;
        _ -> 
            []
    end.

%% 装备五行,Type add 添加属性，del,删除属性
update_equip_attr_for_five_ele_attr([],_Type,Result) ->
    Result;
update_equip_attr_for_five_ele_attr([H|T],Type,Result) ->
    {EquipGoods,EquipBaseInfo} = H,
    FiveEleAttr = EquipGoods#p_goods.five_ele_attr,
    if erlang:is_record(FiveEleAttr,p_equip_five_ele)
       andalso FiveEleAttr#p_equip_five_ele.id =/= 0 ->
            NewEquipGoods = update_equip_attr_for_five_ele_attr2(Type,EquipGoods,FiveEleAttr),
            update_equip_attr_for_five_ele_attr(T,Type,[{NewEquipGoods,EquipBaseInfo}|Result]);
       true ->
            update_equip_attr_for_five_ele_attr(T,Type,[H|Result])
    end.
update_equip_attr_for_five_ele_attr2(add,EquipGoods,FiveEleAttr) ->
    if FiveEleAttr#p_equip_five_ele.active =/= 0 ->
            EquipGoods;
       true ->
            NewFiveEleAttr = FiveEleAttr#p_equip_five_ele{active = 1},
            EquipPro = EquipGoods#p_goods.add_property,
            PhyAnti = NewFiveEleAttr#p_equip_five_ele.phy_anti,
            MagicAnti = NewFiveEleAttr#p_equip_five_ele.magic_anti,
            Hurt = NewFiveEleAttr#p_equip_five_ele.hurt,
            HurtRebound = NewFiveEleAttr#p_equip_five_ele.hurt_rebound,
            NoDefence = NewFiveEleAttr#p_equip_five_ele.no_defence,
            if PhyAnti =/= 0 ->
                    NewPhyAnti = EquipPro#p_property_add.phy_anti + PhyAnti,
                    NewEquipPro1 = EquipPro#p_property_add{phy_anti = NewPhyAnti},
                    EquipGoods#p_goods{add_property = NewEquipPro1,five_ele_attr = NewFiveEleAttr};
               MagicAnti =/= 0 ->
                    NewMagicAnti = EquipPro#p_property_add.magic_anti + MagicAnti,
                    NewEquipPro2 = EquipPro#p_property_add{magic_anti = NewMagicAnti},
                    EquipGoods#p_goods{add_property = NewEquipPro2,five_ele_attr = NewFiveEleAttr};
               Hurt =/= 0 -> 
                    NewHurt = EquipPro#p_property_add.hurt + Hurt,
                    NewEquipPro3 = EquipPro#p_property_add{hurt = NewHurt},
                    EquipGoods#p_goods{add_property = NewEquipPro3,five_ele_attr = NewFiveEleAttr};
               HurtRebound =/= 0 ->
                    NewHurtRebound = EquipPro#p_property_add.hurt_rebound + HurtRebound,
                    NewEquipPro4 = EquipPro#p_property_add{hurt_rebound = NewHurtRebound},
                    EquipGoods#p_goods{add_property = NewEquipPro4,five_ele_attr = NewFiveEleAttr};
               NoDefence =/= 0 ->
                    NewNoDefence = EquipPro#p_property_add.no_defence + NoDefence,
                    NewEquipPro5 = EquipPro#p_property_add{no_defence = NewNoDefence},
                    EquipGoods#p_goods{add_property = NewEquipPro5,five_ele_attr = NewFiveEleAttr};
               true ->
                    EquipGoods
            end
    end;
update_equip_attr_for_five_ele_attr2(del,EquipGoods,FiveEleAttr) ->
    if FiveEleAttr#p_equip_five_ele.active =/= 1 ->
            EquipGoods;
       true ->
            NewFiveEleAttr = FiveEleAttr#p_equip_five_ele{active = 0},
            EquipPro = EquipGoods#p_goods.add_property,
            PhyAnti = NewFiveEleAttr#p_equip_five_ele.phy_anti,
            MagicAnti = NewFiveEleAttr#p_equip_five_ele.magic_anti,
            Hurt = NewFiveEleAttr#p_equip_five_ele.hurt,
            HurtRebound = NewFiveEleAttr#p_equip_five_ele.hurt_rebound,
            NoDefence = NewFiveEleAttr#p_equip_five_ele.no_defence,
            if PhyAnti =/= 0 ->
                    NewPhyAnti = EquipPro#p_property_add.phy_anti - PhyAnti,
                    NewEquipPro1 = EquipPro#p_property_add{phy_anti = NewPhyAnti},
                    EquipGoods#p_goods{add_property = NewEquipPro1,five_ele_attr = NewFiveEleAttr};
               MagicAnti =/= 0 ->
                    NewMagicAnti = EquipPro#p_property_add.magic_anti - MagicAnti,
                    NewEquipPro2 = EquipPro#p_property_add{magic_anti = NewMagicAnti},
                    EquipGoods#p_goods{add_property = NewEquipPro2,five_ele_attr = NewFiveEleAttr};
               Hurt =/= 0 -> 
                    NewHurt = EquipPro#p_property_add.hurt - Hurt,
                    NewEquipPro3 = EquipPro#p_property_add{hurt = NewHurt},
                    EquipGoods#p_goods{add_property = NewEquipPro3,five_ele_attr = NewFiveEleAttr};
               HurtRebound =/= 0 ->
                    NewHurtRebound = EquipPro#p_property_add.hurt_rebound - HurtRebound,
                    NewEquipPro4 = EquipPro#p_property_add{hurt_rebound = NewHurtRebound},
                    EquipGoods#p_goods{add_property = NewEquipPro4,five_ele_attr = NewFiveEleAttr};
               NoDefence =/= 0 ->
                    NewNoDefence = EquipPro#p_property_add.no_defence - NoDefence,
                    NewEquipPro5 = EquipPro#p_property_add{no_defence = NewNoDefence},
                    EquipGoods#p_goods{add_property = NewEquipPro5,five_ele_attr = NewFiveEleAttr};
               true ->
                    EquipGoods
            end
    end.
            

%% 套装处理
%% 参数 [{EquipGoods,EquipBaseInfo},...]
%% 返回值 {no_whole,EquipList},{whole,EquipList}
do_handle_active_whole_attr_equip(EquipList) ->
    %% 清理已经失效的套装属性
    CleanEquipList = clean_equip_whole_attr(EquipList),
    %% EquipList2 = fill_equip_whole_attr(EquipList,[]),
    %% 根据套装分类
    %% 结果 [{wholeId,[{EquipGoods,EquipBaseInfo},...]},..]
    ClassEquipList = class_equip_whole_attr(CleanEquipList,[]),
    %% 将分类好的套装装备进行套装个数计逄
    %% 参数[{wholeId,[{EquipGoods,EquipBaseInfo},...]},..]
    CalcEquipList = calc_equip_whole_attr_number(ClassEquipList,[]),
    %% 检查人物装备是否是套装，如果是则并设算套装子属性
    %% 参数[{wholeId,[{EquipGoods,EquipBaseInfo},...]},..]
    %% 返回值 {ok,WholeEquipList,WholeRecord,SubWholeRecord},{error,WholeEquipList}
    case check_role_equip_whole_attr(CalcEquipList) of
        {error,EquipList3} ->
            {no_whole,change_lists_structure(EquipList3,[])};
        {ok,EquipList4,WholeRecord,SubWholeRecord} ->
            {whole,change_lists_structure(EquipList4,[]),
             WholeRecord,SubWholeRecord}
    end.
%% 转换列表结构
%% 没有套装的为0分类，其它的以套装id为分类id
%% 参数 [{wholeId,[{EquipGoods,EquipBaseInfo},...]},..]
%% 返回值 [{EquipGoods,EquipBaseInfo},...]
change_lists_structure([],Result) ->
    Result;
change_lists_structure([H|T],Result) ->
    {_Id,EquipList} = H,
    NewResult = lists:append([EquipList,Result]),
    change_lists_structure(T,NewResult).

%% 清理已经失效的套装属性
clean_equip_whole_attr(EquipList) ->
    lists:map(fun({EquipGoods,EquipBaseInfo}) ->
                      WholeAttr = EquipGoods#p_goods.whole_attr,
                      EquipGoods2 = 
                          if  erlang:is_record(WholeAttr,p_equip_whole_attr)
                              andalso WholeAttr#p_equip_whole_attr.id =/= 0 ->
                                  WholeAttr2 = WholeAttr#p_equip_whole_attr{sub_id = 0,
                                                                            active = 0,
                                                                            desc = "", 
                                                                            number = 1},
                                  EquipGoods#p_goods{whole_attr = WholeAttr2};
                              true ->
                                  EquipGoods
                          end,
                      {EquipGoods2,EquipBaseInfo}
              end,EquipList).
%% 将人物身上的装备信息进行装备套装属性处理
%% 参数[{EquipGoods,EquipBaseInfo},...]
%% fill_equip_whole_attr([],Result) ->
%%     Result;
%% fill_equip_whole_attr([H|T],Result) ->
%%     {EquipGoods,EquipBaseInfo} = H,
%%     WholeAttr = EquipGoods#p_goods.whole_attr,
%%     if erlang:is_record(WholeAttr,p_equip_whole_attr)
%%        andalso WholeAttr#p_equip_whole_attr.id =/= 0 ->
%%             fill_equip_whole_attr(T,[H|Result]);
%%        true ->
%%             NewEquipGoods = do_random_equip_whole_attr(EquipGoods),
%%             fill_equip_whole_attr(T,[{NewEquipGoods,EquipBaseInfo}|Result])
%%     end.
%% 将人物身上的装备进行套装分类
%% 没有套装的为0分类，其它的以套装id为分类id
%% 分类结果 [{wholeId,[{EquipGoods,EquipBaseInfo},...]},..]
class_equip_whole_attr([],Result) ->
    Result;
class_equip_whole_attr([H|T],Result) ->
    {EquipGoods,EquipBaseInfo} = H,
    WholeAttr = EquipGoods#p_goods.whole_attr,
    Id = if erlang:is_record(WholeAttr,p_equip_whole_attr)
            andalso WholeAttr#p_equip_whole_attr.id =/= 0 ->
                 WholeAttr#p_equip_whole_attr.id;
            true ->
                 0
         end,
    case lists:keyfind(Id,1,Result) of
        false ->
            class_equip_whole_attr(T,[{Id,[{EquipGoods,EquipBaseInfo}]}|Result]);
        WholeTuple ->
            {_WholeId,WholeList} = WholeTuple,
            NewResult = lists:keydelete(Id,1,Result),
            class_equip_whole_attr(T,[{Id,[{EquipGoods,EquipBaseInfo}|WholeList]}|NewResult])
    end.

%% 将分类好的套装装备进行套装个数计逄
%% 参数[{wholeId,[{EquipGoods,EquipBaseInfo},...]},..]
calc_equip_whole_attr_number([],Result) ->
    Result;
calc_equip_whole_attr_number([H|T],Result) ->
    {Id,EquipList} = H,
    if Id =/= 0 ->
            EquipList2 = [{RE,RB} || {RE,RB} <- EquipList,
                                RE#p_goods.sign_role_id =/= 0,
                                RE#p_goods.sign_role_id =:= RE#p_goods.roleid,
                                RE#p_goods.current_endurance > 0
                         ],
            Length = erlang:length(EquipList2),
            ?DEBUG("~ts,wholeid=~w,length=~w,EquipListLength=~w",["套装备个数",Id,Length,erlang:length(EquipList)]),
            EquipList3 = 
                lists:map(fun({EquipGoods,EquipBaseInfo}) ->
                                  WholeAttr = EquipGoods#p_goods.whole_attr,
                                  NewWholeAttr = WholeAttr#p_equip_whole_attr{number = Length},
                                  {EquipGoods#p_goods{whole_attr = NewWholeAttr},EquipBaseInfo}
                          end,EquipList2),
            EquipList4 = [RE2 || {RE2,_RB2} <- EquipList3],
            EquipList5 = sync_equip_goods_list(EquipList,EquipList4,[]),
            calc_equip_whole_attr_number(T,[{Id,EquipList5}|Result]);
       true ->
            calc_equip_whole_attr_number(T,[H|Result])
    end.

%% 检查人物装备是否是套装，如果是则并设算套装子属性
%% 参数[{wholeId,[{EquipGoods,EquipBaseInfo},...]},..]
%% 返回值 {ok,WholeEquipList,WholeRecord,SubWholeRecord},{error,WholeEquipList}
check_role_equip_whole_attr(WholeEquipList) ->
    if erlang:length(WholeEquipList) =:= 1 ->
            check_role_equip_whole_attr2(WholeEquipList);
       true ->
            {error,WholeEquipList}
    end.
check_role_equip_whole_attr2(WholeEquipList)->
    [{_Id,EquipList}] = WholeEquipList,
    EquipList2 = [RE || {RE,_RB} <- EquipList],
    SignRoleIds = [R#p_goods.sign_role_id || 
                      R <- EquipList2,
                      R#p_goods.sign_role_id =/= 0,
                      R#p_goods.sign_role_id =:= R#p_goods.roleid,
                      R#p_goods.current_endurance > 0
                  ],
    if erlang:length(EquipList2) =:= 10 
       andalso erlang:length(SignRoleIds) =:= 10 ->
            check_role_equip_whole_attr3(WholeEquipList);
       true ->
            {error,WholeEquipList}
    end.
check_role_equip_whole_attr3(WholeEquipList) ->
    [{Id,_EquipList}] = WholeEquipList,
    case common_config_dyn:find(equip_whole_attr,Id) of
        [WholeRecord] ->
            check_role_equip_whole_attr4(WholeEquipList,WholeRecord);
        _ ->
            ?DEBUG("~ts,EquipWholeId=~w",["查询不到套装配置",Id]),
            {error,WholeEquipList}
    end.      
check_role_equip_whole_attr4(WholeEquipList,WholeRecord) ->
    [{Id,EquipList}] = WholeEquipList,
    SumIndex = 
        lists:foldl(fun({EquipGoods,_EquipBaseInfo},Acc) ->
                            WholeAttr = EquipGoods#p_goods.whole_attr,       
                            Index = WholeAttr#p_equip_whole_attr.index,
                            Acc + Index
                    end,0,EquipList),
    SubWholeList = WholeRecord#r_equip_whole_attr.sub_whole,
    SubIdList = [SR#r_equip_sub_whole_attr.id || SR <-  SubWholeList],
    MaxIndex = lists:max(SubIdList),
    SubId = SumIndex rem MaxIndex + 1,
    case lists:keyfind(SubId,#r_equip_sub_whole_attr.id,SubWholeList) of
        false ->
            ?DEBUG("~ts,EquipWholeId=~w,EquipWholeSubId=~w,SumIndex=~w",["查询到的套装子信息",Id,SubId,SumIndex]),
            {error,WholeEquipList};
        SubWholeRecord ->
            check_role_equip_whole_attr5(WholeEquipList,WholeRecord,SubWholeRecord)
    end.
check_role_equip_whole_attr5(WholeEquipList,WholeRecord,SubWholeRecord) ->
    [{Id,EquipList}] = WholeEquipList,
    Desc = SubWholeRecord#r_equip_sub_whole_attr.desc,
    SubId = SubWholeRecord#r_equip_sub_whole_attr.id,
    NewEquipList = lists:map(fun({EquipGoods,EquipBaseInfo}) ->
                                     WholeAttr = EquipGoods#p_goods.whole_attr,
                                     WholeAttr2 = WholeAttr#p_equip_whole_attr{sub_id = SubId,
                                                                               active = 1,
                                                                               desc = Desc},
                                     EquipGoods2 = EquipGoods#p_goods{whole_attr = WholeAttr2},
                                     {EquipGoods2,EquipBaseInfo}
                             end,EquipList),
    {ok,[{Id,NewEquipList}],WholeRecord,SubWholeRecord}.

%% 获取套装加成属性buff List
%% 参数 EquipList装备列表[p_goods,....] IsEndurance 是否判断耐久度
%% 返回  WholeAttrBuffList,[]
get_equip_whole_attr_buff(EquipList,IsEndurance) ->
    case get_is_open_equip_whole_attr_fun() of
        false ->
            [];
        true ->
            get_equip_whole_attr_buff2(EquipList,IsEndurance)
    end.
get_equip_whole_attr_buff2(EquipList,IsEndurance) ->
    case get_equip_whole_attr_record(EquipList,IsEndurance) of
        {error,no_whole} ->
            [];
         {ok,_WholeRecord,SubWholeRecord} ->
            SubWholeRecord#r_equip_sub_whole_attr.buff_list
    end.
%% 根据人物身上的装备获取套装信息
%% 参数 EquipList装备列表[p_goods,....] IsEndurance 是否判断耐久度
%% 返回 {ok,WholeRecord,SubWholeRecord}, {error,no_whole}
get_equip_whole_attr_record(EquipList,IsEndurance) ->
    case get_is_open_equip_whole_attr_fun() of
        false ->
            {error,no_whole};
        true ->
            get_equip_whole_attr_record2(EquipList,IsEndurance)
    end.

get_equip_whole_attr_record2(EquipList,IsEndurance) ->
    %% 装备五行和套装部件列表
    SlotList = get_equip_fiveele_and_whole_slot(),
    %% 过滤副手和其它不需要处理的装备
    EquipList2 = 
        lists:foldl(fun(Equip,Acc) ->
                            if Equip#p_goods.type =:= 3 ->
                                    TypeId = Equip#p_goods.typeid,
                                    case mod_equip:get_equip_baseinfo(TypeId) of
                                        {ok,BaseInfo} ->
                                            SlotNum = BaseInfo#p_equip_base_info.slot_num,
                                            case lists:member(SlotNum,SlotList) of
                                                false ->
                                                    Acc;
                                                true ->
                                                    [Equip|Acc]
                                            end;
                                        error ->
                                            Acc
                                    end;
                               true ->
                                    Acc
                            end
                    end,[], EquipList),
    get_equip_whole_attr_record3(EquipList2,IsEndurance).
get_equip_whole_attr_record3(EquipList,IsEndurance) ->
    SignRoleIds = case IsEndurance of
                      true ->
                          [R1#p_goods.sign_role_id || 
                              R1 <- EquipList,
                              R1#p_goods.sign_role_id =/= 0,
                              R1#p_goods.sign_role_id =:= R1#p_goods.roleid,
                              R1#p_goods.current_endurance > 0
                          ];
                      false ->
                          [R2#p_goods.sign_role_id || 
                              R2 <- EquipList,
                              R2#p_goods.sign_role_id =/= 0,
                              R2#p_goods.sign_role_id =:= R2#p_goods.roleid
                          ]
                  end,
    if erlang:length(EquipList) =:= 10 
       andalso erlang:length(SignRoleIds) =:= 10 ->
            get_equip_whole_attr_record4(EquipList);
       true ->
            {error,no_whole}
    end.
get_equip_whole_attr_record4(EquipList) ->
    [H|_T] = EquipList,
    WholeAttr = H#p_goods.whole_attr,
    if erlang:is_record(WholeAttr,p_equip_whole_attr)
       andalso WholeAttr#p_equip_whole_attr.id =/= 0 
       andalso WholeAttr#p_equip_whole_attr.sub_id =/= 0 
       andalso WholeAttr#p_equip_whole_attr.number =:= 10 ->
            get_equip_whole_attr_record5(EquipList,WholeAttr);
       true ->
            {error,no_whole}
    end.
get_equip_whole_attr_record5(EquipList,WholeAttr) ->
    WholeId = WholeAttr#p_equip_whole_attr.id, 
    case common_config_dyn:find(equip_whole_attr,WholeId) of
        [WholeRecord] ->
            get_equip_whole_attr_record6(EquipList,WholeAttr,WholeRecord);
        _ ->
            ?DEBUG("~ts,EquipWholeId=~w",["查询不到套装配置",WholeId]),
            {error,no_whole}
    end.     
get_equip_whole_attr_record6(_EquipList,WholeAttr,WholeRecord) ->
    WholeId = WholeAttr#p_equip_whole_attr.id, 
    SubId =  WholeAttr#p_equip_whole_attr.sub_id,
    SubWholeList = WholeRecord#r_equip_whole_attr.sub_whole,
    case lists:keyfind(SubId,#r_equip_sub_whole_attr.id,SubWholeList) of
        false ->
            ?DEBUG("~ts,EquipWholeId=~w,EquipWholeSubId=~w",["查询到的套装子信息",WholeId,SubId]),
            {error,no_whole};
        SubWholeRecord ->
            {ok,WholeRecord,SubWholeRecord}
    end.
%% 获取装备套装的颜色限制条件
get_equip_whole_attr_color() ->
    case common_config_dyn:find(equip_five_ele,equip_whole_attr_color) of
         [ Color ] -> 
            Color;
         _ -> 
            3
     end.
%% 是否开启装备五行功能
get_is_open_equip_five_ele_fun() ->
    case common_config_dyn:find(equip_five_ele,is_open_equip_five_ele_fun) of
        [ IsOpen ] -> 
            IsOpen;
         _ -> 
            false
     end.
%% 是否开启装备套装功能
get_is_open_equip_whole_attr_fun() ->
    case common_config_dyn:find(equip_five_ele,is_open_equip_whole_attr_fun) of
        [ IsOpen ] -> 
            IsOpen;
        _ -> 
            false
    end.
