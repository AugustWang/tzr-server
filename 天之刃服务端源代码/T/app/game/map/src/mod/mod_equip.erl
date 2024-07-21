%%% -------------------------------------------------------------------
%%% Author  : liuwei
%%% Description :
%%%
%%% Created : 2010-3-27
%%% -------------------------------------------------------------------
-module(mod_equip).

-include("mgeem.hrl").
-include("refining.hrl").
-include("equip.hrl").

-export([
         handle/1,
         creat_equip/1,
         get_equip_baseinfo/1,
         reduce_equip_endurance/5,
         cut_weapon_type/2,
         make_reduce_endurance_equips/5,
         t_reduce_equip_endurance/3,
         unicast_equip_endurance_change/2,
         %% 获取人物新地形象
         %% 返回结果 {ok,NewRoleAttr,NewSkin}或者{ok,RoleAttr,undefined}
         get_role_skin_change_info/4,
         creat_equip_expand/2,
         do_load/7,
         t_common_unload_equip/5,
         calc_bindinfo_while_using/1
        ]).



%%
%% API Functions
%%
handle({Unique, Module, Method, DataRecord, RoleID, _Pid,Line,_State}=Info) ->
    case Method of
        ?EQUIP_LOAD ->
            do_load(Unique, Module, Method, DataRecord, RoleID, Line, 0);
        ?EQUIP_UNLOAD ->
            do_unload(Unique, Module, Method, DataRecord, RoleID, Line);
        ?EQUIP_LOADED_LIST ->
            do_list(Unique, Module, Method, DataRecord, RoleID, Line);
        ?EQUIP_SWAP ->
            do_swap(Unique, Module, Method, DataRecord, RoleID, Line);
        ?EQUIP_FIX ->
            do_fix(Unique, Module, Method, DataRecord, RoleID,Line);
        ?EQUIP_MOUNTUP ->
            mod_equip_mount:handle(Info);
        ?EQUIP_MOUNTDOWN ->
            mod_equip_mount:handle(Info);
        ?EQUIP_MOUNT_CHANGECOLOR ->
            mod_equip_mount:handle(Info);
        ?EQUIP_MOUNT_RENEWAL ->
            mod_equip_mount:handle(Info);
        _ ->
            nil
    end;
handle({admin_set_endurance, RoleID, Num}) ->
    do_admin_set_endurance(RoleID, Num);
handle(Info) ->
    ?ERROR_MSG("mod_equip, unknow msg: ~w", [Info]).

do_admin_set_endurance(RoleID, Num) ->
    case common_transaction:t(
           fun() ->
                   t_do_admin_set_endurance(RoleID, Num)
           end)
    of
        {atomic, ChangeList} ->
            case ChangeList =/= [] of
                true ->
                    DataRecord = #m_equip_endurance_change_toc{equip_list=ChangeList},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?EQUIP, ?EQUIP_ENDURANCE_CHANGE, DataRecord);
                _ ->
                    ignore
            end,
            %% 如果耐久变0了还要重算人物属性
            case Num =:= 0 andalso ChangeList =/= [] of
                true ->
                    mod_map_role:attr_change(RoleID);
                _ ->
                    ignore
            end;
        {aborted, Reason} ->
            ?ERROR_MSG("do_admin_set_endurance, error: ~w", [Reason])
    end.

t_do_admin_set_endurance(RoleID, Num) ->
    {ok, #p_role_attr{equips=EquipList}=RoleAttr} = mod_map_role:get_role_attr(RoleID),
    {ChangeList, EquipList2} =
        lists:foldl(
          fun(Equip, {CL, EL}) ->
                  #p_goods{id=ID, endurance=MaxEndurance} = Equip,
                  if Num > MaxEndurance ->
                          {CL, [Equip|EL]};
                     true ->
                          Equip2 = Equip#p_goods{current_endurance=Num},
                          {[#p_equip_endurance_info{equip_id=ID,
                                                    num=Num,
                                                    max_num=MaxEndurance}|CL], [Equip2|EL]}
                  end
          end, {[], []}, EquipList),
    RoleAttr2 = RoleAttr#p_role_attr{equips=EquipList2},
    mod_map_role:set_role_attr(RoleID, RoleAttr2),
    ChangeList.

%%fixtype false: 全部修理, true: 单个修理
do_fix(Unique, Module, Method, DataRecord, RoleID, Line) ->
    #m_equip_fix_tos{fix_type=FixType, equip_id=EquipID} = DataRecord,
    ?DEBUG("do_fix, fixtype: ~w, equip_id: ~w", [FixType, EquipID]),
    Ret =
        case FixType of
            true ->
                do_fix2(RoleID,EquipID);  
            false ->
                reduce_equip_endurance(RoleID, ?ALLEQUIP, 100, false, 1)
        end,
    case Ret of
        ignore ->
            Data = ignore;
        {error, Reason} ->
            Data = #m_equip_fix_toc{succ=false, reason=Reason};
        {ok, EquipList, RestSilver, RestBindSilver} ->
            ?DEBUG("do_fix, equiplist: ~w, restsilver: ~w, restbindsilver: ~w", [EquipList, RestSilver, RestBindSilver]),
            Data = #m_equip_fix_toc{equip_list=EquipList, silver=RestSilver, bind_silver=RestBindSilver}

    end,
    case Data of
        ignore ->
            ignore;
        _ ->
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Data)
    end.

do_fix2(RoleID,EquipID) ->
    %%装备ID，修复比例100%，修理类型NPC商店修理，紧大耐久变化
    case db:transaction(
           fun() ->
                   {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
                   {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
                   EquipList = RoleAttr#p_role_attr.equips,

                   %% 在身上及背包里查找装备
                   Equip =
                       case lists:keyfind(EquipID, #p_goods.id, EquipList) of
                           false ->
                               case mod_bag:get_goods_by_id(RoleID, EquipID) of
                                   {ok, GoodsInfo} ->
                                       GoodsInfo;
                                   _ ->
                                       db:abort(?_LANG_EQUIP_FIX_ERROR)
                               end;

                           EquipInfo ->
                               EquipInfo
                       end,

                   #p_goods{typeid=TypeID} = Equip,
                   {ok, BaseInfo} = get_equip_baseinfo(TypeID),
                   %% 修理不降最大耐久度
                   Reduce = 0,

                   t_reduce_equip_endurance(RoleBase,
                                            RoleAttr, 
                                            [{EquipID, 100, false, Reduce, 1,Equip,BaseInfo}])
           end)
    of
        {atomic, Result} ->
            unicast_equip_endurance_change(RoleID,Result);
        {aborted, R} when is_binary(R) ->
            {error, R};
        {aborted, R} ->
            ?DEBUG("reduance_equip_endurance, r: ~w", [R]),
            {error, ?_LANG_SYSTEM_ERROR}
    end.

%% mod by caochuncheng 2010-12-02 背包代码重构的相应修改
%% 同时处理掉事务中发送消息和嵌套事务问题
%% 操作过程中注意将需要处理的结果返回，事务完成之后才发送消息
%% 当装备穿上身上时，装备信息只保存在p_role_attr.equips
%% 背包表则删除此装备信息记录
do_load(Unique, Module, Method, DataRecord, RoleID, Line, EquipTypeID) ->
    %% add caochuncheng 添加装备套装处理
    #m_equip_load_tos{equip_slot_num=SlotNum, equipid=EquipID} = DataRecord,

    {Data, NewRoleAttr, WholeAttrBuffList,NewSkin,UnLoadEquip} =
        case common_transaction:transaction(
               fun() ->
                       t_load_equip(SlotNum, EquipID, RoleID, EquipTypeID)
               end)
        of
            {aborted, Reason} when is_binary(Reason); is_list(Reason) ->
                {#m_equip_load_toc{succ=false, reason=Reason}, undefined, 0, undefined, undefined};
            {aborted, Reason} ->
                ?ERROR_MSG("load_equip transaction fail,RoleID=~w, reason = ~w", [RoleID,Reason]),
                {#m_equip_load_toc{succ=false, reason=?_LANG_SYSTEM_ERROR}, undefined, 0, undefined, undefined};
            {atomic, {Data2, GoodsInfo, GoodsBaseInfo, NewRoleAttr2, WholeAttrBuffList2,NewSkin2,UnLoadEquip2}} ->
                hook_equip_wear:hook({RoleID, SlotNum, GoodsInfo, GoodsBaseInfo, NewRoleAttr2}),
                {Data2, NewRoleAttr2, WholeAttrBuffList2, NewSkin2, UnLoadEquip2}
            
        end,

    common_misc:unicast(Line, RoleID, Unique, Module, Method, Data),

    case NewRoleAttr of
        undefined ->
            ignore;
        _ ->
            do_load2(Unique, Module, Method, DataRecord, RoleID,Line,
                     NewRoleAttr, WholeAttrBuffList,NewSkin,UnLoadEquip)
    end.

do_load2(_Unique, _Module, _Method, _DataRecord, RoleID,_Line,
         _NewRoleAttr, WholeAttrBuffList,_NewSkin,UnLoadEquip) ->
    %% 需要通知前端有副手装备需要缷下
    case UnLoadEquip of
        undefined ->
            next;
        _ ->
            UnLoadMessage = #m_equip_unload_toc{succ = true, equip = UnLoadEquip},
            common_misc:unicast({role,RoleID},?DEFAULT_UNIQUE, ?EQUIP, ?EQUIP_UNLOAD,UnLoadMessage)
    end,
    %% 装备套装属性处理
    if WholeAttrBuffList =/= [] andalso WholeAttrBuffList =/= 0 ->
            %% 处理套装信息
            BuffDetailList = lists:map(fun(BuffId) ->
                                               {ok,BuffDetail} = mod_skill_manager:get_buf_detail(BuffId),
                                               BuffDetail
                                       end,WholeAttrBuffList),
            mod_map_role:add_buff(RoleID, BuffDetailList);
       WholeAttrBuffList =:= 0 ->
            ignore;
       true ->
            %% 重算属性
            mod_map_role:attr_change(RoleID)
    end.

t_load_equip(SlotNum, EquipID, RoleID, EquipTypeID) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),

    %%判断是否可穿装备
    {Info, BaseInfo} = 
        judge_can_load(RoleID, EquipID, SlotNum, RoleAttr, RoleBase, EquipTypeID),
    {Result,NewRoleAttr,WholeAttrBuffList, NewSkin, UnloadEquip} = 
        t_load_equip2(SlotNum, Info, BaseInfo, RoleID, RoleAttr, RoleBase),
    {Result, Info, BaseInfo, NewRoleAttr, WholeAttrBuffList, NewSkin, UnloadEquip}.
    %% end.

t_load_equip2(SlotNum, Info, BaseInfo, RoleID, RoleAttr, RoleBase) ->
    %%判断是否有冲突装备
    {RoleBase2, RoleAttr2, UnLoadEquip} =
        case check_equip_kind_requirement_1(SlotNum, BaseInfo, RoleID, RoleAttr, RoleBase) of
            {ok, RoleBaseT, RoleAttrT, UnLoadEquipT} ->
                {RoleBaseT, RoleAttrT, UnLoadEquipT};
            {error, _} ->
                db:abort(?_LANG_EQUIP_BAG_FULL)
        end,
    %% add caochuncheng 获取旧的套装状态
    OldEquips = if erlang:is_list(RoleAttr#p_role_attr.equips) ->
                       RoleAttr#p_role_attr.equips;
                  true ->
                       []
               end,
    ?DEBUG("OldEquips:~w~n",[OldEquips]),
    OldWholeAttrBuffList = mod_equip_fiveele:get_equip_whole_attr_buff(OldEquips,true),
    ?DEBUG("OldWholeAttrBuffList:~w~n",[OldWholeAttrBuffList]),
    %%判断原位置是否有装备
    case judge_slot_is_empty(RoleID, SlotNum, OldEquips) of
        false ->
            %%装备到空位置，并广播皮肤变更
            ?DEBUG("load_to_empty_slot", []),
            NewInfo = load_to_empty_slot(RoleID, Info, SlotNum),
            NewRoleBase = add_weapon_type(SlotNum,RoleBase2,Info#p_goods.typeid),
            {ok,NewRoleAttr, NewSkin} = 
                get_role_skin_change_info(RoleAttr2, SlotNum, Info#p_goods.typeid, Info#p_goods.light_code),
            %%修改人物属性
            Equip = NewRoleAttr#p_role_attr.equips,
            Equip2 = if erlang:is_list(Equip) ->
                             Equip;
                        true ->
                             []
                     end,
            %% add caochuncheng 装备五行套装计逄处理
            %% NewRoleAttr2 = NewRoleAttr#p_role_attr{equips=[NewInfo|Equip2]},
            %% 获取旧的套装属性加成的buff list
            Buffs = if erlang:is_list(NewRoleBase#p_role_base.buffs) ->
                            NewRoleBase#p_role_base.buffs;
                       true->
                            []
                    end,
            Buffs2 = lists:foldl(fun(BuffId,AccBuffs) ->
                                        lists:keydelete(BuffId,#p_actor_buf.buff_id,AccBuffs)
                                end,Buffs,OldWholeAttrBuffList),
            NewRoleBase2 = NewRoleBase#p_role_base{buffs = Buffs2},
            %% 装备五行和套装部件列表
            EquipList = [NewInfo|Equip2],
            {EquipList2,WholeAttrBuffList} =  mod_equip_fiveele:do_equip_five_ele_and_whole_attr(EquipList),
            NewRoleAttr2 = NewRoleAttr#p_role_attr{equips=EquipList2},
            mod_map_role:set_role_attr(RoleID, NewRoleAttr2),
            mod_map_role:set_role_base(RoleID, NewRoleBase2),
            SendSelf = #m_equip_load_toc{succ=true, equip1=NewInfo, equip2=Info#p_goods{id=0}},
            {SendSelf,NewRoleAttr2,WholeAttrBuffList,NewSkin,UnLoadEquip};
        LoadedInfo ->
            %%交换装备，并广播皮肤变更
            {NewInfo, NewLoadInfo} = change_equip(SlotNum, Info, LoadedInfo),
            
            %%以后可能会有问题，没去掉原来的武器类型
            NewRoleBase = add_weapon_type(SlotNum,RoleBase2,Info#p_goods.typeid),
            {ok,NewRoleAttr, NewSkin} = 
                get_role_skin_change_info(RoleAttr2, SlotNum, Info#p_goods.typeid, Info#p_goods.light_code),

            %%修改人物属性
            Equip = NewRoleAttr#p_role_attr.equips,
            %% add caochuncheng 装备五行套装计逄处理
            Buffs = if erlang:is_list(NewRoleBase#p_role_base.buffs) ->
                            NewRoleBase#p_role_base.buffs;
                       true->
                            []
                    end,
            Buffs2 = lists:foldl(fun(BuffId,AccBuffs) ->
                                        lists:keydelete(BuffId,#p_actor_buf.buff_id,AccBuffs)
                                end,Buffs,OldWholeAttrBuffList),
            NewRoleBase2 = NewRoleBase#p_role_base{buffs = Buffs2},
            %% 装备五行和套装部件列表
            Equip2 = lists:keydelete(LoadedInfo#p_goods.id,#p_goods.id,Equip),
            EquipList = [NewInfo|Equip2],
            {EquipList2,WholeAttrBuffList} =  mod_equip_fiveele:do_equip_five_ele_and_whole_attr(EquipList),
            NewInfo3 = case lists:keyfind(NewInfo#p_goods.id,#p_goods.id,EquipList2) of
                           false ->
                               NewInfo;
                           NewInfo2 ->
                               NewInfo2
                       end,
            NewRoleAttr2 = NewRoleAttr#p_role_attr{equips=EquipList2},
            mod_map_role:set_role_attr(RoleID, NewRoleAttr2),
            mod_map_role:set_role_base(RoleID, NewRoleBase2),
            SendSelf = #m_equip_load_toc{succ=true, equip1=NewInfo3 ,equip2=NewLoadInfo},
            {SendSelf,NewRoleAttr2,WholeAttrBuffList,NewSkin,UnLoadEquip}
    end.


%% mod by caochuncheng 
do_unload(Unique, Module, Method, DataRecord, RoleID,Line) ->
    #m_equip_unload_tos{equipid = EquipID, bagid=BagID, position=Pos} = DataRecord,
    case common_transaction:transaction(
           fun() ->
                   t_unload_equip0(EquipID, RoleID, BagID, Pos)
           end)
        of
        {aborted, Reason} when is_binary(Reason) ->
            ?SEND_ERR_TOC(m_equip_unload_toc,Reason);
        {aborted,{bag_error,not_enough_pos}} ->
            ?SEND_ERR_TOC(m_equip_unload_toc,?_LANG_EQUIP_BAG_FULL);
        {aborted, Reason} ->
            ?ERROR_MSG("~ts,Reason=~w",["缷下装备时出错",Reason]),
            ?SEND_ERR_TOC(m_equip_unload_toc,?_LANG_SYSTEM_ERROR);
        {atomic, {ok, Data, _NewSkin, _Equips}} ->
            mod_map_role:attr_change(RoleID),
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Data)
    end.

t_unload_equip0(EquipID, RoleID, BagID, Pos) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    t_unload_equip(EquipID, RoleID, RoleAttr, RoleBase, BagID, Pos).

t_unload_equip(EquipID, RoleID, RoleAttr, RoleBase, undefined, undefined) ->
    t_unload_equip(EquipID, RoleID, RoleAttr, RoleBase, 0, 0);
t_unload_equip(EquipID, RoleID, RoleAttr, RoleBase,  BagID, Pos) ->
    %%是否有穿该件装备
    EquipList = RoleAttr#p_role_attr.equips,
    case judge_loaded(EquipID, RoleID, EquipList) of
        false ->
            db:abort(?_LANG_SYSTEM_ERROR);
        Info ->
            case BagID =:= 0 orelse mod_bag:get_goods_by_position(BagID, Pos, RoleID) of
                %% 背包原来的位置上没有东西
                false ->
                    %% %% 放到指定位置
                    %% %% 装备放入背包
                    %% NewInfo = Info#p_goods{loadposition=0},
                    %% NewInfo2 = mod_equip_fiveele:do_clean_equip_five_ele_and_whole_attr(NewInfo),
                    %% {ok, [NewInfo3]} = mod_bag:create_goods_by_p_goods_and_id(RoleID, BagID, Pos, NewInfo2),
                    %% %% add caochuncheng 
                    %% %% 装备缷下时需要处理五行和套装属性
                    %% t_unload_equip2(Info, NewInfo3, RoleID, RoleAttr, RoleBase);
                    {ok, RoleBase2, RoleAttr2, Info2, Skin} = t_common_unload_equip(RoleBase, RoleAttr, Info, BagID, Pos);
                %% 背包位置有东西
                _ ->
                    %% %%后台找位置
                    %% NewInfo = Info#p_goods{loadposition=0},
                    %% %% add caochuncheng 
                    %% %% 装备缷下时需要处理五行和套装属性
                    %% NewInfo2 = mod_equip_fiveele:do_clean_equip_five_ele_and_whole_attr(NewInfo),
                    %% {ok,[NewInfo3]} = mod_bag:create_goods_by_p_goods_and_id(RoleID,NewInfo2),

                    %% t_unload_equip2(Info, NewInfo3, RoleID, RoleAttr, RoleBase)
                    {ok, RoleBase2, RoleAttr2, Info2, Skin} = t_common_unload_equip(RoleBase, RoleAttr, Info, 0, 0)
            end,
            
            mod_map_role:set_role_base(RoleID, RoleBase2),
            mod_map_role:set_role_attr(RoleID, RoleAttr2),
            
            DataRecord = #m_equip_unload_toc{succ=true, equip=Info2},
            {ok, DataRecord, Skin, RoleAttr2#p_role_attr.equips}
    end.

%% @doc 脱装备通用操作
t_common_unload_equip(RoleBase, RoleAttr, UnloadInfo, BagID, Pos) ->
    #p_role_base{role_id=RoleID} = RoleBase,

    %%卸下的装备，设置为正常状态
    UnloadInfo2 = mod_equip_fiveele:do_clean_equip_five_ele_and_whole_attr(UnloadInfo#p_goods{loadposition=0,state=?GOODS_STATE_NORMAL}),
    %% 0自动找位置、其它代表指定位置
    case BagID of
        0 ->
            {ok, [EquipInfo]} = mod_bag:create_goods_by_p_goods_and_id(RoleID, UnloadInfo2);
        _ ->
            {ok, [EquipInfo]} = mod_bag:create_goods_by_p_goods_and_id(RoleID, BagID, Pos, UnloadInfo2)
    end,
    
    Equips = if erlang:is_list(RoleAttr#p_role_attr.equips) ->
                     RoleAttr#p_role_attr.equips;
                true ->
                     []
             end,
    WholeAttrBuffList = mod_equip_fiveele:get_equip_whole_attr_buff(Equips, true),
    
    #p_goods{id=GoodsID, loadposition=SlotNum} = UnloadInfo,
    RoleBase2 = cut_weapon_type(SlotNum, RoleBase),

    Buffs = if erlang:is_list(RoleBase2#p_role_base.buffs) ->
                    RoleBase2#p_role_base.buffs;
               true ->
                    []
            end,
    Buffs2 = lists:foldl(fun(BuffId, AccBuffs) ->
                                 lists:keydelete(BuffId, #p_actor_buf.buff_id, AccBuffs)
                         end, Buffs, WholeAttrBuffList),
    RoleBase3 = RoleBase2#p_role_base{buffs=Buffs2},

    %% 装备五行和套装部件列表
    Equips2 = lists:keydelete(GoodsID, #p_goods.id, Equips),
    {Equips3, _WholeAttrBuffList2} = mod_equip_fiveele:do_equip_five_ele_and_whole_attr(Equips2),

    #p_role_attr{skin=Skin} = RoleAttr,
    {ok, Skin2} = get_role_skin_change_info(Skin, SlotNum, 0, 0),
    RoleAttr2 = RoleAttr#p_role_attr{skin=Skin2, equips=Equips3},
    
    {ok, RoleBase3, RoleAttr2, EquipInfo, Skin2}.

%% t_unload_equip2(Info, NewInfo, _RoleID, RoleAttr, RoleBase) ->
%%     %% add caochuncheng 获取旧的套装状态
%%     OldEquips = if erlang:is_list(RoleAttr#p_role_attr.equips) ->
%%                        RoleAttr#p_role_attr.equips;
%%                   true ->
%%                        []
%%                end,
%%     OldWholeAttrBuffList = mod_equip_fiveele:get_equip_whole_attr_buff(OldEquips,true),

%%     %%改变武器类型及广播皮肤变更
%%     SlotNum = Info#p_goods.loadposition,
%%     NewRoleBase = cut_weapon_type(SlotNum, RoleBase),
%%     {ok,NewRoleAttr,NewSkin} = 
%%         get_role_skin_change_info(RoleAttr, SlotNum,0, 0),

%%     %% add caochuncheng 装备五行套装计逄处理
%%     Buffs = if erlang:is_list(NewRoleBase#p_role_base.buffs) ->
%%                     NewRoleBase#p_role_base.buffs;
%%                true->
%%                     []
%%             end,
%%     Buffs2 = lists:foldl(fun(BuffId,AccBuffs) ->
%%                                  lists:keydelete(BuffId,#p_actor_buf.buff_id,AccBuffs)
%%                          end,Buffs,OldWholeAttrBuffList),
%%     NewRoleBase2 = NewRoleBase#p_role_base{buffs = Buffs2},
%%     %% 装备五行和套装部件列表
%%     EquipList = lists:keydelete(Info#p_goods.id,#p_goods.id, OldEquips),
%%     {EquipList2,_WholeAttrBuffList} =  mod_equip_fiveele:do_equip_five_ele_and_whole_attr(EquipList),
%%     NewRoleAttr2 = NewRoleAttr#p_role_attr{equips=EquipList2},

%%     db:write(?DB_ROLE_ATTR, NewRoleAttr2, write),
%%     db:write(?DB_ROLE_BASE, NewRoleBase2, write),

%%     %%返回
%%     SendSelf = #m_equip_unload_toc{succ = true, equip = NewInfo},
%%     {SendSelf, NewRoleBase2, NewRoleAttr2,OldWholeAttrBuffList,NewSkin}.

do_list(Unique, Module, Method, DataRecord, RoleID, Line) ->
    #m_equip_loaded_list_tos{roleid = Role} = DataRecord,
    Data = 
        case mod_map_role:get_role_attr(RoleID) of
            {ok, RoleAttr} ->
                EquipList = 
                    case RoleAttr#p_role_attr.equips of
                        Equips when erlang:is_list(Equips) ->
                            Equips;
                        _ ->
                            []
                    end,
                #m_equip_loaded_list_toc{roleid = Role, equips = EquipList};
            _ ->
                #m_equip_loaded_list_toc{roleid = Role, equips = []}
        end,
    common_misc:unicast(Line, RoleID, Unique, Module, Method, Data).

do_swap(Unique, Module, Method, DataRecord, RoleID, Line) ->
    #m_equip_swap_tos{
         equipid1 = EquipID1, 
         position2 = Position2} = DataRecord,

    case db:transaction(
           fun() ->
                   t_swap_equip(EquipID1, Position2, RoleID)
           end)
    of
	{aborted, Reason} ->
            ?ERROR_MSG("swap_loaded_equips transaction fail, reason = ~w", [Reason]),
            Data = #m_equip_load_toc{succ = false, reason = ?_LANG_SYSTEM_ERROR};
	{atomic, Data} ->
            Data
    end,
    common_misc:unicast(Line, RoleID, Unique, Module, Method, Data).

t_swap_equip(EquipID1, Postion2, RoleID) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    EquipList = RoleAttr#p_role_attr.equips,
    case judge_loaded(EquipID1, RoleID,EquipList) of
        flase ->
            #m_equip_swap_toc{succ = false ,reason = "装备不在背包中"};
        Info ->
            t_swap_equip2(Postion2, Info, RoleID)
    end.

t_swap_equip2(Position2, Info, RoleID) ->
    case move_loaded_equip(Info, RoleID, Position2) of
        {ok, NewInfo1, NewInfo2} ->
            ?DEBUG("move_loaded_equip ok", []),
            #m_equip_swap_toc{equip1 = NewInfo1, equip2 = NewInfo2};
        {no,Reason} ->
            ?DEBUG("move_loaded_equip fail, reason = ~w", [Reason]),
            #m_equip_swap_toc{succ = false ,reason = Reason}
    end.

add_weapon_type(?UI_LOAD_POSITION_ARM,RoleBase,EquipType) ->
    case get_equip_baseinfo(EquipType) of
        error ->
            ?ERROR_MSG("~ts", ["获取装备基础信息失败了"]),
            db:abort(get_equip_baseinfo_failed);
        {ok, BaseInfo} ->
            Kind = BaseInfo#p_equip_base_info.kind,
            RoleBase#p_role_base{weapon_type=Kind}
    end;
add_weapon_type(_, RoleBase,_) ->
    RoleBase.

cut_weapon_type(?UI_LOAD_POSITION_ARM,RoleBase) ->
    RoleBase#p_role_base{weapon_type=0};
cut_weapon_type(_, RoleBase) ->
    RoleBase.

%% add by caochuncheng 添加此接口
%% 获取人物新地形象
%% 返回结果 {ok,NewRoleAttr,NewSkin}或者{ok,RoleAttr,undefined}
get_role_skin_change_info(OldAttr, SlotNum, EquipType, LightCode) 
when erlang:is_record(OldAttr, p_role_attr) ->
    OldSkin = OldAttr#p_role_attr.skin,
    case SlotNum of
        ?UI_LOAD_POSITION_BREAST -> %%3：护甲
            NewSkin = OldSkin#p_skin{clothes=EquipType},
            NewAttr = OldAttr#p_role_attr{skin=NewSkin};
        ?UI_LOAD_POSITION_ARM -> %% 4：武器
            NewSkin = OldSkin#p_skin{weapon=EquipType,light_code = LightCode},
            NewAttr = OldAttr#p_role_attr{skin=NewSkin};
        ?UI_LOAD_POSITION_ASSISTANT -> %% 5、副手武器
            NewSkin = OldSkin#p_skin{assis_weapon=EquipType},
            NewAttr = OldAttr#p_role_attr{skin=NewSkin};
        ?UI_LOAD_POSITION_MOUNT -> %% 15：坐骑
            NewSkin = OldSkin#p_skin{mounts=EquipType},
            NewAttr = OldAttr#p_role_attr{skin=NewSkin};
        ?UI_LOAD_POSITION_FASHION -> %% 8：时装
            NewSkin = OldSkin#p_skin{fashion=EquipType},
            NewAttr = OldAttr#p_role_attr{skin=NewSkin};
        _ ->
            NewAttr = OldAttr,
            NewSkin = undefined
    end,
    {ok,NewAttr,NewSkin};
get_role_skin_change_info(Skin, SlotNum, EquipType, LightCode) ->
    case SlotNum of
        ?UI_LOAD_POSITION_BREAST ->
            {ok, Skin#p_skin{clothes=EquipType}};
        ?UI_LOAD_POSITION_ARM ->
            {ok, Skin#p_skin{weapon=EquipType,light_code = LightCode}};
        ?UI_LOAD_POSITION_ASSISTANT ->
            {ok, Skin#p_skin{assis_weapon=EquipType}};
        ?UI_LOAD_POSITION_MOUNT ->
            {ok, Skin#p_skin{mounts=EquipType}};
        ?UI_LOAD_POSITION_FASHION ->
            {ok, Skin#p_skin{fashion=EquipType}};
        _ ->
            {ok, Skin}
    end.

judge_can_load(RoleID, EquipID, SlotNum, RoleAttr, RoleBase, EquipTypeID) ->
    %%是否在背包中
    case mod_bag:check_inbag(RoleID, EquipID) of
        {ok, Info} ->
            case check_in_use_time(Info) of
                true->
                    #p_goods{typeid=TypeID, state=State} = Info,                    
                    [BaseInfo] = common_config_dyn:find_equip(TypeID),
                    #p_equip_base_info{equipname=EquipName, slot_num=Slot} = BaseInfo,
                    
                    %% 处于锁定状态的装备不能使用
                    case State =/= ?GOODS_STATE_NORMAL of
                        true ->
                            db:abort(lists:flatten(io_lib:format(?_LANG_EQUIP_IS_LOCKED, [EquipName])));
                        _ ->
                            assert_mount_normal_state(Slot,RoleID),
                            %%判断位置是否正确
                            judge_can_load2(Slot, SlotNum, Info, RoleAttr, RoleBase)
                    end;
                %% end;
                false->
                    db:abort(?_LANG_EQUIP_NOT_IN_USE_TIME)
            end;
        _ ->
            abort_equip_not_in_bag(EquipTypeID)
    end.

%%确认坐骑的正常状态
assert_mount_normal_state(?PUT_MOUNT,RoleID)->
    mod_equip_mount:t_assert_normal_state(RoleID);
assert_mount_normal_state(_SlotNum,_RoleID)->
    ok.

check_in_use_time(ItemInfo) ->
    #p_goods{start_time = StartTime,
             end_time = EndTime} = ItemInfo,
    Now = common_tool:now(),         
    if StartTime =:= 0  orelse 
           StartTime =< Now ->
           if EndTime =:= 0  orelse 
                  EndTime >= Now ->
                  true;
              true ->
                  false
           end;
       true ->
           false
    end.

abort_equip_not_in_bag(EquipTypeID) ->
    case EquipTypeID of
        0 ->
            db:abort(?_LANG_EQUIP_NOT_IN_BAG);
        _ ->
            [BaseInfo] = common_config_dyn:find_equip(EquipTypeID),
            #p_equip_base_info{equipname=EquipName} = BaseInfo,
            db:abort(lists:flatten(io_lib:format(?_LANG_EQUIP_NOT_IN_BAG2, [EquipName])))
    end.

%%@doc SlotNum是跟玩家装备界面的孔一一对应
judge_can_load2(?PUT_ARM,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_ARM) ->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_NECKLACE,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_NECKLACE) ->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_FINGER,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_FINGER_1 
                                                              orelse SlotNum =:= ?UI_LOAD_POSITION_FINGER_2) ->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_ARMET,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_ARMET) ->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_BREAST,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_BREAST)->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_CAESTUS,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_CAESTUS) ->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_HAND,SlotNum,Info,Attr,RoleBase) when(SlotNum =:= ?UI_LOAD_POSITION_HAND_1 
                                                           orelse SlotNum =:= ?UI_LOAD_POSITION_HAND_2) ->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_SHOES,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_SHOES)->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_ASSISTANT,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_ASSISTANT) ->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_ADORN,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_ADORN_1)
        orelse (SlotNum =:= ?UI_LOAD_POSITION_ADORN_2)->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_FASHION,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_FASHION) ->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(?PUT_MOUNT,SlotNum,Info,Attr,RoleBase) when (SlotNum =:= ?UI_LOAD_POSITION_MOUNT) ->
    check_equip_use_requirement(Info,Attr,RoleBase);
judge_can_load2(_,_,_Info,_Attr,_RoleBase)->
    db:abort(?_LANG_EQUIP_WRONG_SLOTNUM).


%%@doc检查装备是否符合要求


check_equip_use_requirement(Info,RoleAttr, RoleBase)->
    case get_equip_baseinfo(Info#p_goods.typeid) of
        error ->
            db:abort(?_LANG_SYSTEM_ERROR);
        {ok, BaseInfo} ->
            #p_equip_base_info{requirement=Req}=BaseInfo,
            case check_equip_use_requirement2(1,Req,RoleAttr,RoleBase) of
                {error, Reason} ->
                    %%{no, Reason, Info};
                    db:abort(Reason);
                ok ->
                    {Info, BaseInfo}
            end
    end.
check_equip_use_requirement2(1,Req,Attr,RoleBase)->
    Sex = RoleBase#p_role_base.sex,
    ReqSex = Req#p_use_requirement.sex,
    ?DEV("~ts:~w,~ts:~w~n",["玩家性别",Sex,"性别要求",ReqSex]),
    if
        ReqSex =:= 0 orelse ReqSex =:= Sex ->
            check_equip_use_requirement2(2,Req,Attr,RoleBase);
        true ->
            {error,?_LANG_EQUIP_SEX_DO_NOT_MEET}
    end;
check_equip_use_requirement2(2,Req,Attr,_RoleBase)->
    case Attr#p_role_attr.level of
        R when Req#p_use_requirement.min_level-1<R andalso
                                         Req#p_use_requirement.max_level+1>R -> 
            ok;
        _ ->
            {error,?_LANG_EQUIP_LEVEL_DO_NOT_MEET}
    end.

judge_slot_is_empty(_RoleID,SlotNum,EquipList) ->
    lists:keyfind(SlotNum, #p_goods.loadposition, EquipList).


%%@doc 获取使用装备时的绑定属性
%%@return {Bind,UseBind}
calc_bindinfo_while_using(GoodsInfo)->
    if GoodsInfo#p_goods.bind ->
           {GoodsInfo#p_goods.bind,0};
       true ->
           if GoodsInfo#p_goods.use_bind =:= 1 ->
                  {true,0};
              true ->
                  {false,GoodsInfo#p_goods.use_bind}
           end
    end.
    
load_to_empty_slot(RoleID, Info, SlotNum) ->
    {Bind,UseBind} = calc_bindinfo_while_using(Info),
    
    NewInfo = Info#p_goods{bagposition = 0, loadposition = SlotNum, bagid = 0, bind = Bind, use_bind = UseBind},
    %% mod by caochuncheng 从背包删除此物品
    mod_bag:delete_goods(RoleID,Info#p_goods.id),
    NewInfo.

change_equip(SlotNum,Info,LoadedInfo) ->
    {Bind,UseBind} = calc_bindinfo_while_using(Info),
    
    #p_goods{roleid=RoleId, bagid=BagID, bagposition=Pos} = Info,
    Info2 = Info#p_goods{bagposition = 0,loadposition = SlotNum, bagid = 0, bind = Bind, use_bind = UseBind},
    mod_bag:delete_goods(RoleId,Info#p_goods.id),
    %%将要卸下的装备，设置为正常状态
    LoadedInfo2 = LoadedInfo#p_goods{loadposition = 0,bagid = 0,bagposition = 0,state=?GOODS_STATE_NORMAL},
    %% add caochuncheng 
    %% 装备缷下时需要处理五行和套装属性
    LoadedInfo3 = mod_equip_fiveele:do_clean_equip_five_ele_and_whole_attr(LoadedInfo2),
    {ok,[LoadedInfo4]} = mod_bag:create_goods_by_p_goods_and_id(RoleId, BagID, Pos, LoadedInfo3),
    {Info2,LoadedInfo4}.

move_loaded_equip(Info1,RoleID,Position2) ->
    case check_in_use_time(Info1) of
        true->
            #p_goods{typeid = Type1} = Info1,
            [BaseInfo1] = common_config_dyn:find_equip(Type1),
            SlotNum1 = BaseInfo1#p_equip_base_info.slot_num,
            {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
            Equips = RoleAttr#p_role_attr.equips,
            case judge_slot_can_load(SlotNum1 , Position2) of
                true ->
                    case lists:keyfind(Position2, #p_goods.loadposition, Equips) of
                        false ->
                            NewInfo1 = Info1#p_goods{loadposition = Position2},
                            NewInfo2 = Info1#p_goods{id = 0},
                            Equips2 = [NewInfo1|lists:keydelete(NewInfo1#p_goods.id, #p_goods.id, Equips)];
                        Info2 ->
                            NewInfo1 = Info1#p_goods{loadposition = Position2},
                            NewInfo2 = Info2#p_goods{loadposition = Info1#p_goods.loadposition},
                            EquipsTmp = [NewInfo1|lists:keydelete(NewInfo1#p_goods.id, #p_goods.id, Equips)],
                            Equips2 = [NewInfo2|lists:keydelete(NewInfo2#p_goods.id, #p_goods.id, EquipsTmp)]
                    end,
                    RoleAttr2 = RoleAttr#p_role_attr{equips=Equips2},
                    mod_map_role:set_role_attr(RoleID, RoleAttr2),
                    {ok, NewInfo1, NewInfo2};
                false ->
                    {no,<<"不能将装备移到这个位置">>}
            end;
        false->
            {no,<<"装备已经过期">>}
    end.

judge_slot_can_load(?PUT_ARM, Position) ->
    Position =:= 4;
judge_slot_can_load(?PUT_NECKLACE, Position) ->
    Position =:= 2;
judge_slot_can_load(?PUT_FINGER, Position) ->
    Position =:= 12 orelse Position =:= 13;
judge_slot_can_load(?PUT_ARMET, Position) ->
    Position =:= 1;
judge_slot_can_load(?PUT_BREAST, Position) ->
    Position =:= 3;
judge_slot_can_load(?PUT_CAESTUS, Position) ->
    Position =:= 11;
judge_slot_can_load(?PUT_HAND, Position) ->
    Position =:= 9 orelse Position =:= 10;
judge_slot_can_load(?PUT_SHOES, Position) ->
    Position =:= 6;
judge_slot_can_load(?PUT_ASSISTANT, Position) ->
    Position =:= 5;
judge_slot_can_load(?PUT_ADORN, Position) ->
    Position =:= ?UI_LOAD_POSITION_ADORN_1 orelse Position =:= ?UI_LOAD_POSITION_ADORN_2;
judge_slot_can_load(?PUT_MOUNT, Position) ->
    Position =:= ?UI_LOAD_POSITION_MOUNT;
judge_slot_can_load(?PUT_FASHION, Position) ->
    Position =:= ?UI_LOAD_POSITION_FASHION.

judge_loaded(EquipID,_RoleID,EquipList) ->
    lists:keyfind(EquipID, #p_goods.id, EquipList).


%%创建物品
creat_equip(CreateInfo) when is_record(CreateInfo,r_equip_create_info) ->
    #r_equip_create_info{role_id=RoleID,bag_id=BagID,bagposition=BagPos,num=Num,
                         typeid=TypeID,bind=Bind,start_time=StartTime,end_time=EndTime,
                         color=Color,quality=Quality,interface_type=InterfaceType,
                         property=Pro,rate=Rate,result=Result,result_list=ResultList,
                         sub_quality = SubQuality
                        }=CreateInfo,
    case common_config_dyn:find_equip(TypeID) of
        [BaseInfo] ->
            {NewStartTime,NewEndTime}=
                if StartTime =:= 0 andalso EndTime =/= 0 ->
                        {common_tool:now(),common_tool:now()+EndTime};
                   true ->
                        {StartTime,EndTime}
                end, 
            #p_equip_base_info{property=Prop,sell_type=SellType,sell_price=SellPrice, 
                               equipname=Name,endurance=Endurance,colour=InitColor,slot_num=ConfSlotNum}=BaseInfo,
            NewProp = if Pro =:= undefined -> Prop;true -> Pro end,
            NewResultList = if ResultList =:= undefined -> [];true -> ResultList end, 
            NewColour = if Color =:= 0 -> InitColor;true -> Color end,
            NewUseBind = case is_equip_that_use_bind(ConfSlotNum) of
                               true-> 1;
                                _ ->  0
                         end,
            GoodsTmp = #p_goods{typeid = TypeID,roleid = RoleID ,bagposition = BagPos ,bind = Bind , 
                                add_property = NewProp,start_time = NewStartTime,end_time = NewEndTime, 
                                current_colour = NewColour,quality = Quality,current_endurance = Endurance ,
                                bagid = BagID, type = ?TYPE_EQUIP,sell_type = SellType,stones=[], 
                                sell_price = SellPrice,name = Name,loadposition = 0,punch_num = 0, endurance = Endurance,
                                level = (BaseInfo#p_equip_base_info.requirement)#p_use_requirement.min_level,
                                reinforce_rate=Rate,reinforce_result=Result,reinforce_result_list=NewResultList,
                                use_bind=NewUseBind,sub_quality = SubQuality },
            NewGoodsTmp = creat_equip_expand(GoodsTmp,InterfaceType,InitColor),
            {ok, lists:duplicate(Num,NewGoodsTmp#p_goods{current_num=1})};
        [] ->
            db:abort(?_LANG_ITEM_NO_TYPE_EQUIP)
    end.

%%@doc 此种装备在使用的时候进行绑定
is_equip_that_use_bind(ConfSlotNum) ->
    ConfSlotNum=:=?PUT_FASHION orelse ConfSlotNum =:=?PUT_MOUNT.

creat_equip_expand(Info,BindAttrType) ->
    creat_equip_expand(Info,BindAttrType,?COLOUR_WHITE).

creat_equip_expand(Info,BindAttrType,InitColor) ->
    %% 绑定属性处理
    NewInfo1 = creat_equip_expand2(BindAttrType,Info,InitColor),
    NewInfo2 = mod_refining:equip_colour_quality_add(new,NewInfo1,1,1,1),%%liurisheng add
    %%NewInfo3 = mod_refining:equip_random_add_property(NewInfo2),
    %% 计算装备精炼系数
    case common_misc:do_calculate_equip_refining_index(NewInfo2) of
        {error,RIErrorCode} ->
            ?DEBUG("~ts,RefiningIndexErrorCode=~w",["计算装备精炼系数出错",RIErrorCode]),
            NewInfo2;
        {ok, RIGoods} ->
            RIGoods
    end.

%%任务
creat_equip_expand2(mission,Info,_InitColor)when Info#p_goods.bind =:= true ->
    case mod_refining_bind:do_equip_bind_for_mission(Info#p_goods{bind=false}) of
        {error,ErrorCode} ->
            ?INFO_MSG("~ts,ErrorCode=~w",["任务赠送装备，参数为绑定，处理绑定出错，只是做绑定处理，没有附加属性",ErrorCode]),
            Info;
        {ok,BindGoods} ->
            BindGoods
    end;
%% 成就
creat_equip_expand2(achievement,Info,_InitColor)when Info#p_goods.bind =:= true ->
    case mod_refining_bind:do_equip_bind_for_mission(Info#p_goods{bind=false}) of
        {error,ErrorCode} ->
            ?INFO_MSG("~ts,ErrorCode=~w",["成就赠送装备，参数为绑定，处理绑定出错，只是做绑定处理，没有附加属性",ErrorCode]),
            Info;
        {ok,BindGoods} ->
            BindGoods
    end;
%%购买
creat_equip_expand2(buy,Info,_InitColor)when Info#p_goods.bind =:= true ->
    case mod_refining_bind:do_equip_bind_for_buy(Info#p_goods{bind=false}) of
        {error,ErrorCode} ->
            ?INFO_MSG("~ts,ErrorCode=~w",["当创建装备时，参数为绑定，处理绑定出错，只是做绑定处理，没有附加属性",ErrorCode]),
            Info;
        {ok,BindGoods} ->
            BindGoods
    end;
%%赠送
creat_equip_expand2(present,Info,_InitColor)when Info#p_goods.bind =:= true ->
    case mod_refining_bind:do_equip_bind_for_present(Info#p_goods{bind=false}) of
        {error, ErrorCode} ->
            ?INFO_MSG("~ts,ErrorCode=~w",["当创建装备时，参数为绑定，处理绑定出错，只是做绑定处理，没有附加属性",ErrorCode]),
            Info;
        {ok,PresentGoods} ->
            PresentGoods
    end;
%%场景大战副本
creat_equip_expand2(scene_war_fb,Info,_InitColor)when Info#p_goods.bind =:= true ->
    case mod_refining_bind:do_equip_bind_for_monster_flop(Info#p_goods{bind = false}) of
        {error,ErrorCode} ->
            ?DEBUG("~ts,ErrorCode=~w,Goods=~w",["怪物掉落绑定装备，执行绑定操作失败，但不处理返回不绑定的装备",ErrorCode,Info]),
            Info;
        {ok,BindGoods} ->
            ?DEV("~ts,Goods=~w,BindGoods=~w",["怪物掉落绑定装备，执行绑定操作成功结枿",Info,BindGoods]),
            BindGoods
    end;
%%掉落物
creat_equip_expand2(monster_flop,Info,_InitColor)when Info#p_goods.bind =:= true ->
    case mod_refining_bind:do_equip_bind_for_monster_flop(Info#p_goods{bind = false}) of
        {error,ErrorCode} ->
            ?DEBUG("~ts,ErrorCode=~w,Goods=~w",["怪物掉落绑定装备，执行绑定操作失败，但不处理返回不绑定的装备",ErrorCode,Info]),
            Info;
        {ok,BindGoods} ->
            ?DEV("~ts,Goods=~w,BindGoods=~w",["怪物掉落绑定装备，执行绑定操作成功结枿",Info,BindGoods]),
            BindGoods
    end;
%% 天工炉炼制
creat_equip_expand2(refining_forging,Info,_InitColor)when Info#p_goods.bind =:= true ->
    case mod_refining_bind:do_equip_bind_for_forging(Info#p_goods{bind=false}) of
        {error,ErrorCode} ->
            ?INFO_MSG("~ts,ErrorCode=~w",["天工炉炼制装备，参数为绑定，处理绑定出错，只是做绑定处理，没有附加属性",ErrorCode]),
            Info;
        {ok,BindGoods} ->
            BindGoods
    end;
%%普通
creat_equip_expand2(_BindAttrType,Info,_InitColor) ->
    Info.
                          
get_equip_baseinfo(TypeID) ->
    case common_config_dyn:find_equip(TypeID) of
        [BaseInfo] -> 
            {ok,BaseInfo};
        [] ->
            error
    end.


%%---------------------
%% 检查是否需要卸载当前装备
%%---------------------
check_equip_kind_requirement_1(SlotNum, BaseInfo, RoleId, RoleAttr, RoleBase) ->
    Kind = BaseInfo#p_equip_base_info.kind,
    case SlotNum of
        %%当前需要装备的是武器,则查询副手装备
        ?UI_LOAD_POSITION_ARM ->
            ?DEBUG("~ts:~p",["是武器，kind为：", SlotNum]),
            check_equip_kind_requeirement_2(RoleId, ?UI_LOAD_POSITION_ASSISTANT, Kind, RoleAttr, RoleBase);           
        %%当前需要装备的是副手装备，则查询武器装备
        ?UI_LOAD_POSITION_ASSISTANT ->
            ?DEBUG("~ts:~p",["是副手装备，kind为：", SlotNum]),
            check_equip_kind_requeirement_2(RoleId, ?UI_LOAD_POSITION_ARM, Kind, RoleAttr, RoleBase);
        %% 某类特殊装备只能穿一件
        ?UI_LOAD_POSITION_ADORN_1 ->
            check_equip_kind_requeirement_2(RoleId, ?UI_LOAD_POSITION_ADORN_2, Kind, RoleAttr, RoleBase);
        ?UI_LOAD_POSITION_ADORN_2 ->
            check_equip_kind_requeirement_2(RoleId, ?UI_LOAD_POSITION_ADORN_1, Kind, RoleAttr, RoleBase);
        %%坐骑，则检查buff
        ?UI_LOAD_POSITION_MOUNT->
            case mod_equip_mount:check_limit_mount_buf(RoleBase) of
                true-> 
                    db:abort(<<"处于禁止坐骑状态，不能驾驭">>);
                _ ->
                    {ok, RoleBase, RoleAttr, undefined}
            end;
        _ ->
            ?DEBUG("~ts:~p",["是其他位置的装备，kind为：", SlotNum]),
            {ok, RoleBase, RoleAttr, undefined}
    end.

check_equip_kind_requeirement_2(RoleId, SlotNum, Kind, RoleAttr, RoleBase) ->
    EquipList = RoleAttr#p_role_attr.equips,
    case judge_slot_is_empty(RoleId, SlotNum, EquipList) of
        false ->
            %%什么也不用做
            {ok, RoleBase, RoleAttr, undefined};
        LoadInfo ->
            TypeId = LoadInfo#p_goods.typeid,
            case get_equip_baseinfo(TypeId)of
                error ->
                    ?DEBUG("~ts~p~ts:~w~n",["查找冲突的装备",TypeId,"基础属性失败，找不到该装备"]),
                    {error, system_error};
                {ok,LoadBaseInfo} ->
                    #p_equip_base_info{kind=KindConfilt, equipname=EquipName} = LoadBaseInfo,
                    %%key使用相加方式拼凑
                    case SlotNum of
                        ?UI_LOAD_POSITION_ARM -> 
                            Key = KindConfilt*10000 + Kind,
                            Conflict = false;
                        ?UI_LOAD_POSITION_ASSISTANT ->
                            Key = Kind*10000 + KindConfilt,
                            Conflict = false;
                        ?UI_LOAD_POSITION_ADORN_1 ->
                            Key = 0,
                            Conflict = (Kind =:= KindConfilt);
                        ?UI_LOAD_POSITION_ADORN_2 ->
                            Key = 0,
                            Conflict = (Kind =:= KindConfilt)
                    end,
                    ?DEBUG("~ts:~p~n",["需要匹配的Key= ", Key]),
                    case  lists:member(Key, ?CONFLICT_EQUIP_LIST) orelse Conflict =:= true of
                        true ->
                            %%需要卸载装备
                            ?DEBUG("~ts~p~ts:~p~ts:~p~n",["需要卸载装备，kind= ", KindConfilt, " 装备ID为=", TypeId, " 角色ID为=", RoleId]),
                            LoadInfo2 = LoadInfo#p_goods{loadposition = 0},
                            %% add caochuncheng 
                            %% 装备缷下时需要处理五行和套装属性
                            LoadInfo3 = mod_equip_fiveele:do_clean_equip_five_ele_and_whole_attr(LoadInfo2),
                            {ok,[LoadInfo4]} = 
                                try
                                    mod_bag:create_goods_by_p_goods_and_id(RoleId,LoadInfo3)
                                catch
                                    _:{bag_error, not_enough_pos} ->
                                        db:abort(lists:flatten(io_lib:format(?_LANG_EQUIP_BAG_FULL2, [EquipName])));
                                    _:_ ->
                                        db:abort(?_LANG_SYSTEM_ERROR)
                                end,
                            %% mod by caochuncheng 这里只修改为只把需要缷下的装备信息从，p_role_attr删除，并返回
                            EquipList2 = lists:keydelete(LoadInfo#p_goods.id, #p_goods.id,EquipList),
                            RoleAttr2 = RoleAttr#p_role_attr{equips = EquipList2},
                            {ok, RoleAttr3, _} = get_role_skin_change_info(RoleAttr2, LoadInfo#p_goods.loadposition, 0, 0),
                            RoleBase2 = cut_weapon_type(SlotNum, RoleBase),
                            {ok,RoleBase2, RoleAttr3, LoadInfo4};
                        false  ->
                            %%什么也不用做
                            {ok, RoleBase, RoleAttr, undefined}
                    end
            end
    end.

%%equiplist: [{equipid, num, type, max_en, reducetype}, {equipid, num, type, max_en}.....]
%%type: true: 绝对值、false: 百分比
%%reduce_type：1、NPC修理，2、增加最大耐久道具
reduce_equip_endurance(RoleId,KindList,Num,Type,ReduceType) ->
    case db:transaction(
           fun() ->
                   {ok, RoleBase} = mod_map_role:get_role_base(RoleId),
                   {ok, RoleAttr} = mod_map_role:get_role_attr(RoleId),
                   Equips = lists:foldl(
                              fun(Equip,Acc) ->
                                      {ok,BaseInfo}=get_equip_baseinfo(Equip#p_goods.typeid),
                                      [{Equip,BaseInfo}|Acc]
                              end,[],RoleAttr#p_role_attr.equips),
                   EquipList = make_reduce_endurance_equips(Equips,KindList,Num,Type,ReduceType),
                   
                   case EquipList of
                       [] ->
                           ignore;
                       _ ->
                           t_reduce_equip_endurance(RoleBase,RoleAttr,EquipList)
                   end
           end)
    of
        {atomic, ignore} ->
            ignore;
        {atomic, Result} ->
            unicast_equip_endurance_change(RoleId,Result);
        {aborted, R} when is_binary(R) ->
            {error, R};
        {aborted, R} ->
            ?ERROR_MSG("reduance_equip_endurance, error: ~w", [R]),
            {error, ?_LANG_SYSTEM_ERROR}
    end.

unicast_equip_endurance_change(RoleID,{EquipList,Flag,SilverNeed,RoleAttr,BuffList}) ->
    ?DEBUG("reduce_equip_endurance, equiplist: ~w, flag: ~w", [EquipList, Flag]),
            %%如果有耐久度的情况，人物属性要变动
    case Flag of
        true ->
            %% add caochuncheng 添加是否增加装备套装buff
            if BuffList =/= [] ->
                    BuffDetailList = lists:map(
                                       fun(BuffId) ->
                                               {ok,BuffDetail} = 
                                                   mod_skill_manager:get_buf_detail(BuffId),
                                               BuffDetail
                                       end,BuffList),
                    mod_map_role:add_buff(RoleID,BuffDetailList);
               true ->
                    mod_map_role:attr_change(RoleID)
            end;
        false ->
            ok
    end,

    %%silver > 0 表示修理
    case SilverNeed > 0 of
        true ->
            ok;
        false ->
            %%通知客户端，如果没有可以修理的装备就免了
            case EquipList =:= [] of
                true ->
                    ok;
                false ->
                    DataRecord = #m_equip_endurance_change_toc{equip_list=EquipList},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?EQUIP, ?EQUIP_ENDURANCE_CHANGE, DataRecord)
            end
    end,
    {ok, EquipList, RoleAttr#p_role_attr.silver, RoleAttr#p_role_attr.silver_bind}.

%%reducetype: 1、NPC修理，2、道具，3、特殊，0、其它
%%仅在耐久度上升的时候
%%修理也是减耐久度，只是反向减

t_reduce_equip_endurance(RoleBase0,RoleAttr0, EquipList0) ->
    {Send, Flag, SilverNeed, RoleAttr1,_EquipList1} = 
        t_reduce_equip_endurance2(RoleAttr0, EquipList0),
    RoleID = RoleBase0#p_role_base.role_id,
    Silver = RoleAttr1#p_role_attr.silver,
    BindSilver = RoleAttr1#p_role_attr.silver_bind,

    {_RestSilver, _RestBindSilver, RoleAttr2} =
        if SilverNeed > 0 ->
                %%计算剩余银子，不足则失败
                {RestSilverTmp,RestBindSilverTmp} = calc_rest_silver(Silver, BindSilver, SilverNeed),
                common_consume_logger:use_silver({RoleAttr0#p_role_attr.role_id, 
                                                  BindSilver-RestBindSilverTmp, 
                                                  Silver-RestSilverTmp, 
                                                  ?CONSUME_TYPE_SILVER_FIX_EQUIP, 
                                                  ""}),
                {RestSilverTmp,
                 RestBindSilverTmp,
                 RoleAttr1#p_role_attr{silver=RestSilverTmp, silver_bind=RestBindSilverTmp}};
           true ->
                {Silver,BindSilver,RoleAttr1}
        end,
    {RoleBase1,RoleAttr3,WholeAttrBuffList} =  
        if Flag =:= true ->
                t_do_equip_endurance_for_five_ele_whole_attr(RoleBase0,RoleAttr2);
           true ->
                {RoleBase0,RoleAttr2,[]}
        end,
    mod_map_role:set_role_attr(RoleID, RoleAttr3),
    mod_map_role:set_role_base(RoleID, RoleBase1),
    {Send, Flag, SilverNeed, RoleAttr3, WholeAttrBuffList}.
    

make_reduce_endurance_equips(Equips,KindList,Num,Type,ReduceType) ->
    lists:foldl(
      fun({Equip,BaseInfo},Acc) ->
              case lists:member(BaseInfo#p_equip_base_info.kind, KindList) of
                  false ->
                      Acc;
                  true ->
                      %% 修理不降最大耐久度
                      Reduce = 0,
                      [{Equip#p_goods.id, Num, Type, Reduce, ReduceType,Equip,BaseInfo}|Acc]
              end
      end,[],Equips).

%% add caochuncheng 添加装备耐久度为0时处理装备五行装备套装处理
%% 参数，
%% 返回新的套装buff
t_do_equip_endurance_for_five_ele_whole_attr(RoleBase,RoleAttr) ->
    OldEquips = if erlang:is_list(RoleAttr#p_role_attr.equips) ->
                        RoleAttr#p_role_attr.equips;
                   true ->
                        []
                end,
    Buffs = if erlang:is_list(RoleBase#p_role_base.buffs) ->
                    RoleBase#p_role_base.buffs;
               true->
                    []
            end,
    OldWholeAttrBuffList = mod_equip_fiveele:get_equip_whole_attr_buff(OldEquips,false),
    NewBuffs = 
        lists:foldl(fun(BuffId,AccBuffs) ->
                            lists:keydelete(BuffId,#p_actor_buf.buff_id,AccBuffs)
                    end,Buffs,OldWholeAttrBuffList),
    RoleBase2 = RoleBase#p_role_base{buffs = NewBuffs},
    %% 装备五行和套装部件列表
    {EquipList2,WholeAttrBuffList} =  mod_equip_fiveele:do_equip_five_ele_and_whole_attr(OldEquips),
    RoleAttr2 = RoleAttr#p_role_attr{equips=EquipList2},
    {RoleBase2,RoleAttr2,WholeAttrBuffList}.

t_reduce_equip_endurance2(RoleAttr, EquipList) ->
    lists:foldl(
      fun({EquipID,Num,Type,MaxEnDiff,ReduceType,Equip,BaseInfo},
          {Send,Flag,SilverTotal,RoleAttrTmp0,AccEquipList}) ->
              RoleEquips = RoleAttrTmp0#p_role_attr.equips,
              Endurance = Equip#p_goods.current_endurance,
              MaxEndurance = Equip#p_goods.endurance,
              EquipType = Equip#p_goods.type,
              %%是否装备
              case EquipType =:= 3 of
                  true ->
                      ok;
                  false ->
                      db:abort(?_LANG_EQUIP_FIX_NOT_EQUIP)
              end,

              %%当前耐久度等于最大耐久度的话就没必要修理了
              %%如果最大耐久度为0，就没必要减或修理了，不过增加最大耐久度道具除外
              %%当前耐久度是0的话也没必要减耐久
              if MaxEndurance =:= 0 orelse 
                 (MaxEndurance=:=0 andalso ReduceType =/= 2)orelse 
                 (Endurance =:= MaxEndurance andalso ReduceType =:= 1)orelse 
                 (Endurance =:= 0 andalso ReduceType =:= 0) ->
                      {Send, Flag, SilverTotal, RoleAttrTmp0,[Equip|AccEquipList]};
                 true ->
                      %%又是特殊处理，耐久度最大调整值不超过5
                      MaxEndurance0 = BaseInfo#p_equip_base_info.endurance,
                      if ReduceType =/= 2 ->
                              MaxEnDiff2 = MaxEnDiff;
                         MaxEndurance0+5000 > MaxEndurance+MaxEnDiff ->
                              MaxEnDiff2 = MaxEnDiff;
                         MaxEndurance0+5000 =:= MaxEndurance ->
                              db:abort(?_LANG_EQUIP_REACH_MAX_LIMIT),
                              MaxEnDiff2 = MaxEnDiff;
                         true ->
                              MaxEnDiff2 = MaxEndurance0 + 5000 - MaxEndurance
                      end,
                      %%获取新的耐久度及最大耐久度
                      CurrentEndurance = get_current_endurance(Num, Endurance, MaxEndurance, MaxEnDiff2, Type),
                      ?DEBUG("t_reduce_equip_endurance2, currentendurance: ~w", [CurrentEndurance]),
                      Equip2 = Equip#p_goods{current_endurance=CurrentEndurance, endurance=MaxEndurance+MaxEnDiff2},

                      %%更新装备和角色装备属性，如果是身上装备的话，还要更新角色属性
                      case lists:keymember(EquipID,#p_goods.id,RoleEquips) of
                          true ->
                              RoleEquips2 = lists:keyreplace(EquipID, #p_goods.id, RoleEquips, Equip2),
                              RoleAttrTmp1 = RoleAttrTmp0#p_role_attr{equips=RoleEquips2};
                          false ->
                              %% 如果是在背包里则需要更新背包物品
                              mod_bag:update_goods(RoleAttr#p_role_attr.role_id, Equip2),
                              
                              RoleAttrTmp1 = RoleAttrTmp0
                      end,

                      %%修理收费
                      case ReduceType =:= 1 andalso Num > 0 of
                          true ->
                              %%获取修理费用
                              SilverNeed = get_fix_silver(CurrentEndurance-Endurance, Equip2),
                              ?DEBUG("t_reduce_equip_endurance2, silverneed: ~w", [SilverNeed]),
                              SilverTotal2 = SilverTotal + SilverNeed;
                          false ->
                              SilverTotal2 = SilverTotal
                      end,

                      %%返回，如果当前耐久度变到0了，装备失效，重算人物属性
                      %%如果原来耐久度是0，修理的话也要重新计算人物属性
                      Data = #p_equip_endurance_info{equip_id=EquipID, num=CurrentEndurance, max_num=MaxEndurance+MaxEnDiff2},
                      case CurrentEndurance =:= 0 orelse (Endurance =:= 0 andalso ReduceType =/= 0) of
                          true ->
                              {[Data|Send], true, SilverTotal2, RoleAttrTmp1,[Equip2|AccEquipList]};
                          _ ->
                              {[Data|Send], Flag, SilverTotal2, RoleAttrTmp1,[Equip2|AccEquipList]}
                      end
              end
      end, {[], false, 0, RoleAttr,[]}, EquipList).

get_current_endurance(Num, Endurance, MaxEndurance, MaxEnDiff, Type) ->
    %%耐久度变化
    MaxEndurance2 = MaxEndurance + MaxEnDiff,
    ?DEBUG("get_current_endurance, endurance: ~w, maxendurance2: ~w", [Endurance, MaxEndurance2]),
    if
        Type =:= true andalso Num > 0 andalso Endurance + Num > MaxEndurance2 ->
            MaxEndurance2;
            %% Num2 = MaxEndurance2 - Endurance;
        Type =:= true andalso Endurance + Num =< 0 ->
            0;
            %% Num2 = -Endurance;
        Type =:= true ->
            Endurance + Num;
            %% Num2 = Num;
        Type =:= false andalso Num > 0 andalso Endurance + round(MaxEndurance2*Num/100) > MaxEndurance2 ->
            MaxEndurance2;
            %% Num2 = MaxEndurance2 - Endurance;
        Type =:= false andalso Endurance + round(MaxEndurance2*Num/100) =< 0 ->
            0;
            %% Num2 = -Endurance;
        true ->
            Endurance + round(MaxEndurance2*Num/100)
            %% Num2 = round(MaxEndurance2*Num/100)
    end.
    %% {Currentendurance, Num2}.

%%费用计算
get_fix_silver(Num, Equip) ->
    #p_goods{sell_price=SellPrice, refining_index=RefinIndex,
             endurance=MaxEndurance} = Equip,

    %%修理系数
    common_tool:ceil(SellPrice*RefinIndex*0.5*Num/MaxEndurance/10).

calc_rest_silver(Silver, BindSilver, SilverNeed) ->
    case BindSilver - SilverNeed >= 0 of
        true ->
            {Silver, BindSilver-SilverNeed};
        _ ->
            Rest = SilverNeed - BindSilver,
            case Silver - Rest >= 0 of
                true ->
                    {Silver-Rest, 0};
                _ ->
                    db:abort(?_LANG_EQUIP_FIX_NOT_ENOUGH_SILVER)
            end
    end.
