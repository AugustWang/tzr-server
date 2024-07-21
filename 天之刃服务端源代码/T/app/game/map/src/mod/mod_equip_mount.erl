%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     坐骑模块，坐骑是当做一个特殊的装备来使用
%%%         1)使用中的坐骑同时保存在 p_role_att.equips和背包中
%%%         2)背包中的坐骑下马后不会消失，只设置State=?GOODS_STATE_EQUIP_INVALID
%%% @end
%%% Created : 2011-02-14
%%% -------------------------------------------------------------------
-module(mod_equip_mount).

-include("mgeem.hrl").
-include("refining.hrl").
-include("equip.hrl").

-export([
         handle/1,
         check_is_mounting/1,
         force_mountdown/1,
         check_limit_mount_buf/1,
         t_assert_normal_state/1
        ]).

    
-define(MOUNT_SPEEDUP_CARD_TYPE_ID,11600006).

%%
%% API Functions
%%

handle({Unique, Module, Method, DataRecord, RoleID, _Pid,Line,_State}) ->
    case Method of
        ?EQUIP_MOUNTUP ->
            do_mountup(Unique, Module, Method, DataRecord, RoleID, Line);
        ?EQUIP_MOUNTDOWN ->
            do_mountdown(Unique, Module, Method, DataRecord, RoleID, Line);
        ?EQUIP_MOUNT_CHANGECOLOR ->
            do_changecolor(Unique, Module, Method, DataRecord, RoleID, Line);
        ?EQUIP_MOUNT_RENEWAL ->
            do_mount_renewal(Unique, Module, Method, DataRecord, RoleID, Line);
        _ ->
            nil
    end.


%%@doc 判断是否处于坐骑状态
%%@return true | false
check_is_mounting(RoleID) when is_integer(RoleID)->
    case mod_map_role:get_role_attr(RoleID) of
        {ok, RoleAttr} ->
            Skin = RoleAttr#p_role_attr.skin,
            EquipList = RoleAttr#p_role_attr.equips ,
            check_is_mounting(Skin,EquipList);
        _ ->
            false
    end.
check_is_mounting(Skin,EquipList)->
    Skin#p_skin.mounts>0 andalso 
                    lists:keyfind(?UI_LOAD_POSITION_MOUNT, #p_goods.loadposition, EquipList) =/= false.


%%@doc 判断是否处于禁止骑马的buf状态
%%@return true|false
check_limit_mount_buf(RoleBase) when is_record(RoleBase,p_role_base)->
    #p_role_base{buffs=Buffs} = RoleBase,
    check_limit_mount_buf_2(Buffs).

check_limit_mount_buf_2([])->
    false;
check_limit_mount_buf_2([Buff|T])->
    #p_actor_buf{buff_type=BuffType} = Buff,
    {ok, Func} = mod_skill_manager:get_buff_func_by_type(BuffType),
    
    case Func of 
        limit_mount->
            true;
        _ ->
            check_limit_mount_buf_2(T)
    end.

%%@doc 强制玩家下马，例如进行打坐、摆摊、训练营，则直接下马
%%@return ok | {error,Reason}
force_mountdown(RoleID)->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    EquipList = RoleAttr#p_role_attr.equips ,
    Skin = RoleAttr#p_role_attr.skin,
    case Skin#p_skin.mounts>0 of
        true->
            #p_goods{id=EquipID} = lists:keyfind(?UI_LOAD_POSITION_MOUNT, #p_goods.loadposition, EquipList),
            case common_transaction:transaction(
                   fun() ->
                           t_moutdown_equip_1(RoleID,RoleAttr,EquipID)
                   end)
                of
                {aborted, Reason} ->
                    ?ERROR_MSG("force_mountdown error,Reason=~w",[Reason]),
                    {error,Reason};
                {atomic, ignore} ->
                    ignore;
                {atomic, {ok, Data2, NewSkin2}} ->
                    mod_map_role:do_attr_change(RoleID),
                    %%广播和更新
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?EQUIP, ?EQUIP_MOUNTDOWN, Data2),
                    update_map_role_info(RoleID,NewSkin2),
                    ok
            end;
        _ ->
            ok
    end.

%%对处于打坐状态、在线挂机、摆摊、商贸、训练营，不能上马
t_assert_normal_state(RoleID)->
    case mod_map_actor:get_actor_mapinfo(RoleID,role) of
        undefined->
            next;
        RoleMapInfo when is_record(RoleMapInfo,p_map_role)->
            case RoleMapInfo#p_map_role.state of
                ?ROLE_STATE_NORMAL ->%%正常状态
                    next;
                ?ROLE_STATE_STALL_SELF ->
                    db:abort(<<"摆摊中，无法驾驭坐骑，请先按“K”收摊">>);
                ?ROLE_STATE_ZAZEN ->
                    db:abort(<<"打坐中，无法驾驭坐骑，请先按“D”结束">>);
                ?ROLE_STATE_TRAINING ->
                    db:abort(<<"训练中，无法驾驭坐骑">>);
                ?ROLE_STATE_COLLECT ->
                    db:abort(<<"采集中，无法驾驭坐骑">>);
                _->
                    next
            end
    end,
    {ok, RoleState} = common_misc:get_dirty_role_state(RoleID),
    #r_role_state{stall_self=StallSelf} = RoleState,
    if   
        StallSelf =:= true ->
            db:abort(<<"摆摊中，无法驾驭坐骑，请先按“K”收摊">>);
        true->
            ok
    end.


%% ====================================================================
%% Internal functions
%% ====================================================================


%%@interface 更换坐骑颜色（即等级）
do_changecolor(Unique, Module, Method, DataRecord, RoleID, Line)->
    #m_equip_mount_changecolor_tos{mountid=MountID} = DataRecord,
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    Skin = RoleAttr#p_role_attr.skin,
    EquipList = RoleAttr#p_role_attr.equips ,
    GoodsMountPosition = lists:keyfind(?UI_LOAD_POSITION_MOUNT, #p_goods.loadposition, EquipList),
    if
        (GoodsMountPosition=:=false) orelse (GoodsMountPosition#p_goods.id =/=MountID)->
            %%刷新背包中的坐骑
            do_changecolor_1(Unique, Module, Method, MountID, RoleID, Line);
        (GoodsMountPosition#p_goods.id =:=MountID) andalso (Skin#p_skin.mounts>0) ->
            %%刷新正在驾驭的坐骑
            do_changecolor_2(Unique, Module, Method, MountID, RoleID, Line,
                             GoodsMountPosition,true);
        (GoodsMountPosition#p_goods.id =:=MountID) ->
            %%刷新身上的但没有正在驾驭的坐骑
            do_changecolor_2(Unique, Module, Method, MountID, RoleID, Line,
                             GoodsMountPosition,false);
        true->
            ?ERROR_MSG("玩家的坐骑状态有误！RoleID=~w,GoodsMountPosition=~w",[RoleID,GoodsMountPosition]),
            ?SEND_ERR_TOC(m_equip_mount_changecolor_toc,<<"玩家坐骑状态有误">>)
    end.


%%刷新背包里面的坐骑
do_changecolor_1(Unique, Module, Method, MountID, RoleID, Line)->
    case mod_bag:get_goods_by_id(RoleID,MountID) of
        {error,goods_not_found} ->
            ?SEND_ERR_TOC(m_equip_mount_changecolor_toc,<<"背包中找不到相应的坐骑">>);
        {ok,#p_goods{typeid=ItemTypeID,current_colour=OldColor}=MountGoods} ->
            IsMountEquip = is_mount_equip(ItemTypeID),
            if
                OldColor>=?COLOUR_ORANGE->
                    ?SEND_ERR_TOC(m_equip_mount_changecolor_toc,?_LANG_MOUNT_HIGHEST_SPEED);
                IsMountEquip =:= false->
                    ?SEND_ERR_TOC(m_equip_mount_changecolor_toc,<<"只有坐骑才能进行提速">>);
                true->
                    IsInEquip = false,
                    do_changecolor_3(Unique, Module, Method, MountID, RoleID, Line,MountGoods,IsInEquip,false)
            end
    end.

%%刷新身上的坐骑
do_changecolor_2(Unique, Module, Method, MountID, RoleID, Line,MountGoods,IsMounting)->
    #p_goods{typeid=ItemTypeID,current_colour=OldColor} = MountGoods,
    IsMountEquip = is_mount_equip(ItemTypeID),
    if
        OldColor>=?COLOUR_ORANGE->
            ?SEND_ERR_TOC(m_equip_mount_changecolor_toc,?_LANG_MOUNT_HIGHEST_SPEED);
        IsMountEquip =:= false->
            ?SEND_ERR_TOC(m_equip_mount_changecolor_toc,<<"只有坐骑才能进行提速">>);
        true->
            IsInEquip = true,
            do_changecolor_3(Unique, Module, Method, MountID, RoleID, Line,MountGoods,IsInEquip,IsMounting)
    end.

do_changecolor_3(Unique, Module, Method, MountID, RoleID, Line,MountGoods,IsInEquip,IsMounting)->
    case mod_bag:check_inbag_by_typeid(RoleID,?MOUNT_SPEEDUP_CARD_TYPE_ID) of
        {ok,FoundGoodsList} ->
            case check_goods_num(FoundGoodsList) of
                true-> 
                    do_changecolor_4(Unique, Module, Method, MountID, RoleID, Line,MountGoods,IsInEquip,IsMounting);
                _ ->
                    ?SEND_ERR_TOC(m_equip_mount_changecolor_toc,?_LANG_MOUNT_SPEEDUP_COLOR_NOTFOUND)
            end;
        _ ->
            ?SEND_ERR_TOC(m_equip_mount_changecolor_toc,?_LANG_MOUNT_SPEEDUP_COLOR_NOTFOUND)
    end.

check_goods_num(GoodsInfoList)->
    AllNum = lists:foldl(fun(E,AccIn)-> 
                                 #p_goods{current_num=Num}=E,
                                 AccIn + Num
                         end, 0, GoodsInfoList),
    AllNum > 0.


-define(DO_CHANGE_COLOR_SUCC(RoleID,NewColor,NewMount),
        R2 = #m_equip_mount_changecolor_toc{succ=true,color=NewColor,mount=NewMount},
        common_misc:unicast(Line, RoleID, Unique, Module, Method, R2),
        send_goods_notify(RoleID,DeleteGoodsList,UpdateGoodsList)
       ).

do_changecolor_4(Unique, Module, Method, _MountID, RoleID, Line,MountGoods,IsInEquip,IsMounting)->
    #p_goods{name=GoodsName,current_colour=OldColor}=MountGoods,
    case common_transaction:transaction(
           fun() ->
                   t_change_mount_color(RoleID,MountGoods,IsInEquip)
           end)
        of
        {aborted, Reason} when is_binary(Reason); is_list(Reason) ->
            ?SEND_ERR_TOC(m_equip_mount_changecolor_toc,Reason);
        {aborted, Reason} ->
            ?ERROR_MSG("do_changecolor_2 fail, reason = ~w", [Reason]),
            ?SEND_ERR_TOC(m_equip_mount_changecolor_toc,?_LANG_SYSTEM_ERROR);
        {atomic, {ok, the_same_color,UpdateGoodsList,DeleteGoodsList}} ->
            common_item_logger:log(RoleID, ?MOUNT_SPEEDUP_CARD_TYPE_ID,1,undefined,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
            ?DO_CHANGE_COLOR_SUCC(RoleID,OldColor,undefined);
        {atomic, {ok,NewColor,NewEquip,UpdateGoodsList,DeleteGoodsList}} ->
            common_item_logger:log(RoleID, ?MOUNT_SPEEDUP_CARD_TYPE_ID,1,undefined,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
            case IsMounting of
                true->
                    %% 重算属性
                    mod_map_role:attr_change(RoleID);
                _ ->
                    ignore
            end,
            if
                %%紫色进行广播
                NewColor>=4 ->
                    {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
                    #p_role_base{role_name=RoleName,faction_id=FactionID}= RoleBase,
                    FactionName = common_misc:get_faction_color_name(FactionID),
                    BcMessage = common_misc:format_lang(?_LANG_MOUNT_USE_SPEEDUP_COLOR_BROADCAST,
                                                        [FactionName,RoleName,GoodsName,get_mount_color(NewColor)] ),
                    common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CENTER],?BC_MSG_TYPE_CHAT_WORLD,BcMessage);
                true->
                    ignore
            end,
            ?DO_CHANGE_COLOR_SUCC(RoleID,NewColor,NewEquip)
    end.


send_goods_notify(RoleID,DeleteGoodsList,UpdateGoodsList)->
    common_misc:del_goods_notify({role, RoleID}, DeleteGoodsList),
    common_misc:update_goods_notify({role, RoleID}, UpdateGoodsList),
    ok.

get_mount_color(1)->
    ?_LANG_MOUNT_COLOR1;
get_mount_color(2)->
    ?_LANG_MOUNT_COLOR2;
get_mount_color(3)->
    ?_LANG_MOUNT_COLOR3;
get_mount_color(4)->
    ?_LANG_MOUNT_COLOR4;
get_mount_color(5)->
    ?_LANG_MOUNT_COLOR5.


is_mount_equip(ItemTypeID)->
    case common_config_dyn:find(equip,ItemTypeID) of
        [#p_equip_base_info{slot_num=ConfSlotNum}]->
            ConfSlotNum =:= ?PUT_MOUNT;
        _ ->
            false
    end.

%%@doc 更换坐骑颜色（即等级），事务内的方法
t_change_mount_color(RoleID,MountGoods,IsInEquip) when is_record(MountGoods,p_goods)->
    DeductItemTypeID = ?MOUNT_SPEEDUP_CARD_TYPE_ID,
    {ok,UpdateGoodsList,DeleteGoodsList} = mod_bag:decrease_goods_by_typeid(RoleID,DeductItemTypeID,1),
    
    #p_goods{current_colour=OldColor,typeid=ItemTypeID}=MountGoods,
    NewRandomColor = get_random_color(RoleID),
    IsMountCannotUplevel = common_config_dyn:find(mount_level,ItemTypeID) =:= [],
    %%颜色的跳级保护
    case NewRandomColor>(OldColor+1) of
        true->
            NewColor = (OldColor+1);
        _ ->
            NewColor = NewRandomColor
    end,
    if
        IsMountCannotUplevel ->
            db:abort(<<"该坐骑不能进行提速。">>);
        %%颜色的刷新保护
        OldColor>=NewColor->
            {ok,the_same_color,UpdateGoodsList,DeleteGoodsList};
        true->
            {ok,NewEquip} = t_change_mount_color_2(RoleID,MountGoods,NewColor,IsInEquip),
            {ok,NewColor,NewEquip,UpdateGoodsList,DeleteGoodsList}
    end.

t_change_mount_color_2(RoleID,MountGoods,NewColor,IsInEquip)when is_integer(NewColor)andalso is_record(MountGoods,p_goods)->
    #p_goods{id=GoodsID,typeid=ItemTypeID,add_property=OldProp}=MountGoods,
    NewProp = OldProp#p_property_add{move_speed=get_color_speed(ItemTypeID,NewColor)},
    
    NewMountGoods = MountGoods#p_goods{current_colour=NewColor,add_property=NewProp},
    case IsInEquip of
        true->
            update_role_equips(RoleID,GoodsID,NewMountGoods);
        _ ->
            mod_bag:update_goods(RoleID,[NewMountGoods])
    end,
    {ok,NewMountGoods}.


get_color_speed(ItemTypeID,Color) when is_integer(Color) ->
    [MountLevelList] = common_config_dyn:find(mount_level,ItemTypeID),
    #r_mount_level{speed=Speed} = lists:keyfind(Color,#r_mount_level.level,MountLevelList),
    Speed.

get_random_color(RoleID)->
    case db:dirty_read(?DB_ROLE_MOUNT,RoleID) of
        []->
            [DefMountWeights] = common_config_dyn:find(mount_level,mount_weights),
            ColorWeights = [ {L,W}||#r_mount_color_weight{level=L,weight=W}<-DefMountWeights];
        [#r_role_mount{color_weights=ColorWeights}]->
            ok
    end,
    WeightSum = lists:sum( [ W||{_,W}<-ColorWeights] ),
    RandomRate = common_tool:random(1,WeightSum),
    ColorWeights2 = lists:sort(fun({_,W1},{_,W2})-> W1<W2 end, ColorWeights),
    %%只有当玩家刷出最高级颜色的时候，刷新次数清零
    
    NewColor = get_match_color(RandomRate,ColorWeights2),
    case NewColor =:= ?COLOUR_ORANGE of
        true->
            save_next_color_weights(RoleID,[]);
        _ ->
            save_next_color_weights(RoleID,ColorWeights2)
    end,
    NewColor.

%%将颜色权重保存到数据库中
save_next_color_weights(RoleID,[])->
    db:dirty_delete(?DB_ROLE_MOUNT,RoleID);
save_next_color_weights(RoleID,ColorWeights) when is_list(ColorWeights)->
    [DefMountWeights] = common_config_dyn:find(mount_level,mount_weights),
    ColorWeights2 = lists:map(fun({L,W})-> 
            #r_mount_color_weight{increment=Inc} = lists:keyfind(L, #r_mount_color_weight.level, DefMountWeights),
            
            W2 = W+Inc,
            if  
                %%如果权重值（权重值≤0或者权重值≥10000，都以0计算
                W =:= 0-> {L,0};
                W2 =< 0-> {L,0};
                W2 >= 10000 -> {L,0};
                true-> {L,W2}
            end
        end, ColorWeights),
    R1 = #r_role_mount{role_id=RoleID,color_weights=ColorWeights2},
    db:dirty_write(?DB_ROLE_MOUNT,R1).
    
get_match_color(_RandomRate,[{L,_Weight}])->
    L;
get_match_color(RandomRate,[{L1,Wt1},{L2,Wt2}|T]) when is_integer(RandomRate)->
    if
        RandomRate=<Wt1->
            L1;
        true->
            T2 = [{L2,Wt1+Wt2}|T],
            get_match_color(RandomRate,T2)
    end.

  

%%@interface 玩家上马
do_mountup(Unique, Module, Method, DataRecord, RoleID, Line) ->
    #m_equip_mountup_tos{ mountid=EquipID} = DataRecord,
    
    case common_transaction:transaction(
           fun() ->
                   t_mountup_equip(RoleID,EquipID)
           end)
    of
        {aborted, Reason} when is_binary(Reason); is_list(Reason) ->
            ?SEND_ERR_TOC(m_equip_mountup_toc,Reason);
        {aborted, Reason} ->
            ?ERROR_MSG("do_mountup transaction fail, reason = ~w", [Reason]),
            ?SEND_ERR_TOC(m_equip_mountup_toc,?_LANG_SYSTEM_ERROR);
        {atomic, {ok,Data,_NewSkin}} ->
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Data),
            %% 重算属性
            mod_map_role:attr_change(RoleID)
    end.

%%@return {ok, DataRecord, NewSkin}
t_mountup_equip(RoleID,EquipID) ->
    t_assert_normal_state(RoleID),
    
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    OldEquips = RoleAttr#p_role_attr.equips,
    Skin = RoleAttr#p_role_attr.skin,
    
    case check_load_mount_in_equips(OldEquips,EquipID) of
        {ok, GoodsInfo}->
            case check_is_mounting(Skin,OldEquips) of
                true->
                    db:abort(<<"您正在驾驭坐骑">>);
                _ ->
                    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
                    case check_limit_mount_buf(RoleBase) of
                        true->
                            db:abort(<<"处于禁止坐骑状态，不能驾驭">>);
                        _ ->
                            ok = check_equip_use_requirement(GoodsInfo,RoleAttr, RoleBase),
                            t_moutup_equip_2(RoleID,RoleAttr,GoodsInfo)
                    end
            end;
        _ ->
            db:abort(<<"尚未选择坐骑，不能驾驭">>)
    end.


%%处理从无坐骑状态，骑上坐骑
%%@param GoodsInfo #p_goods 坐骑的物品
%%@return {ok, DataRecord, NewSkin}
t_moutup_equip_2(RoleID,OldRoleAttr,LoadGoodsInfo)->
    OldEquips = get_role_old_equips(OldRoleAttr),
    #p_role_attr{skin=OldSkin} = OldRoleAttr,
    #p_goods{id=GoodsID,typeid=TypeID} = LoadGoodsInfo,
    {Bind,UseBind} = mod_equip:calc_bindinfo_while_using(LoadGoodsInfo),
    LoadGoodsInfo2 = LoadGoodsInfo#p_goods{loadposition=?UI_LOAD_POSITION_MOUNT,bind=Bind,use_bind=UseBind,state=?GOODS_STATE_NORMAL},
    
    %%更新RoleAttr，包括skin和equips
    Skin2 = OldSkin#p_skin{mounts=TypeID},
    Equips2 = lists:keyreplace(GoodsID, #p_goods.id, OldEquips,LoadGoodsInfo2),
    
    update_role_attr(RoleID,OldRoleAttr,Skin2,Equips2),
    
    DataRecord = #m_equip_mountup_toc{succ=true,mount_new=LoadGoodsInfo2,mount_old=undefined},
    {ok, DataRecord, Skin2}.




%%@interface 玩家下马
do_mountdown(Unique, Module, Method, DataRecord, RoleID,Line) ->
    #m_equip_mountdown_tos{mountid=EquipID} = DataRecord,
    {Data, _NewSkin} =
        case common_transaction:transaction(
               fun() ->
                       {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
                       t_moutdown_equip_1(RoleID,RoleAttr,EquipID)
               end)
            of
            {aborted, Reason} when is_binary(Reason) ->
                {#m_equip_mountdown_toc{succ=false, reason=Reason},undefined};
            {aborted,{bag_error,not_enough_pos}} ->
                {#m_equip_mountdown_toc{succ=false, reason=?_LANG_MOUNT_BAG_FULL},undefined};
            {aborted, Reason} ->
                ?ERROR_MSG("~ts,Reason=~w",["缷下装备时出错",Reason]),
                {#m_equip_mountdown_toc{succ = false, reason = ?_LANG_SYSTEM_ERROR},undefined};
            {atomic, ignore} ->
                {ignore,ignore};
            {atomic, {ok, Data2, NewSkin2}} ->
                mod_map_role:attr_change(RoleID),
                {Data2, NewSkin2}
        end,
    
    case Data of
        ignore->
            ignore;
        _ ->
            %%广播和更新
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Data)
    end.

 
%%@return {ok, DataRecord, NewSkin}
t_moutdown_equip_1(RoleID,RoleAttr,EquipID) ->
    %%是否有穿该件装备
    EquipList = RoleAttr#p_role_attr.equips,
    case check_load_mount_in_equips(EquipList,EquipID) of
        {ok,GoodsInfo}->
            t_moutdown_equip_2(RoleID,RoleAttr, GoodsInfo);
        false ->
            ignore
    end.

t_moutdown_equip_2(RoleID,OldRoleAttr, UnLoadGoodsInfo)->
    #p_role_attr{skin=OldSkin,equips=OldEquips} = OldRoleAttr,
    #p_goods{id=GoodsID, loadposition=LoadPosition} = UnLoadGoodsInfo,
    
    case LoadPosition of
        ?UI_LOAD_POSITION_MOUNT->
            next;
        _ ->
            db:abort(<<"坐骑必须装备在指定的位置上">>)
    end,
    
    %%更新RoleAttr，包括skin和equips
    Skin2 = OldSkin#p_skin{mounts=0},
    UnMountEquip = UnLoadGoodsInfo#p_goods{state=?GOODS_STATE_EQUIP_INVALID},
    Equips2 = lists:keyreplace(GoodsID, #p_goods.id, OldEquips,UnMountEquip),
    
    update_role_attr(RoleID,OldRoleAttr,Skin2,Equips2),
    
    DataRecord = #m_equip_mountdown_toc{succ=true, mount=UnMountEquip},
    {ok,DataRecord,Skin2}. 
  

%%@doc检查是否符合要求
check_equip_use_requirement(Info,RoleAttr, RoleBase)->
    case get_equip_baseinfo(Info#p_goods.typeid) of
        error ->
            db:abort(?_LANG_SYSTEM_ERROR);
        {ok, BaseInfo} ->
            #p_equip_base_info{requirement=Req,slot_num=ConfSlotNum}=BaseInfo,
            if
                ConfSlotNum =:= ?PUT_MOUNT ->
                    case check_equip_use_requirement2(1,Req,RoleAttr,RoleBase) of
                        {error, Reason} ->
                            %%{no, Reason, Info};
                            db:abort(Reason);
                        ok ->
                            ok
                    end;
                true->
                    db:abort(<<"只有坐骑才能使用">>)
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
            {error,?_LANG_MOUNT_SEX_DO_NOT_MEET}
    end;
check_equip_use_requirement2(2,Req,Attr,_RoleBase)->
    case Attr#p_role_attr.level of
        R when Req#p_use_requirement.min_level-1<R andalso
                                         Req#p_use_requirement.max_level+1>R -> 
            ok;
        _ ->
            {error,?_LANG_MOUNT_LEVEL_DO_NOT_MEET}
    end.

                          
get_equip_baseinfo(TypeID) ->
    case common_config_dyn:find_equip(TypeID) of
        [BaseInfo] -> 
            {ok,BaseInfo};
        [] ->
            error
    end.

update_role_equips(RoleID,GoodsID,NewMountGoods) when is_record(NewMountGoods,p_goods)->
    {ok, OldRoleAttr} = mod_map_role:get_role_attr(RoleID),
    OldEquips = OldRoleAttr#p_role_attr.equips ,
    Equips2 = lists:keyreplace(GoodsID, #p_goods.id, OldEquips,NewMountGoods),
    RoleAttr2 = OldRoleAttr#p_role_attr{equips=Equips2},
    mod_map_role:set_role_attr(RoleID, RoleAttr2).

%%@doc 在地图中更新RoleAttr
update_role_attr(RoleID,OldRoleAttr,Skin2,Equips2) when is_integer(RoleID) andalso is_list(Equips2)->
    RoleAttr2 = OldRoleAttr#p_role_attr{skin=Skin2,equips=Equips2},
    mod_map_role:set_role_attr(RoleID, RoleAttr2).

  
%%@doc 在地图中更新Skin的改变
update_map_role_info(_RoleID,undefined)->
    ignore;
update_map_role_info(RoleID,NewSkin) when is_record(NewSkin,p_skin)->
    ChangeList = [{#p_map_role.skin, NewSkin}],
    mod_map_role:do_update_map_role_info(RoleID, ChangeList, mgeem_map:get_state()).

%%@doc 获取当前玩家的装备列表（包括坐骑）
get_role_old_equips(RoleAttr)->
    OldEquips = RoleAttr#p_role_attr.equips ,
    case is_list(OldEquips) of
        true->
            OldEquips;
        _->
            []
    end.

%%@doc 检查装备列表中是否有 坐骑
%%@return {ok,GoodsInfo} | false
check_load_mount_in_equips(EquipList,EquipID)->
    case lists:keyfind(EquipID, #p_goods.id, EquipList) of
        #p_goods{loadposition=LoadPosition}=GoodsInfo->
            case LoadPosition=:= ?UI_LOAD_POSITION_MOUNT of
                true->
                    {ok,GoodsInfo};
                _ ->
                    false
            end;
        _ ->
            false
    end.
%% 坐骑续期处理
%% DataRecord 结构为 m_equip_mount_renewal_tos
do_mount_renewal(Unique, Module, Method, DataRecord, RoleId, Line) ->
    case catch do_mount_renewal2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_mount_renewal_error(Unique, Module, Method, DataRecord, 
                                   RoleId, Line,Reason,ReasonCode);
        {ok,1,RoleAttr,PMountRenewalList,MountGoods} ->
            do_mount_renewal3_1(Unique,Module,Method,DataRecord,RoleId,Line,
                                RoleAttr,PMountRenewalList,MountGoods);
        {ok,2,RoleAttr,MountGoods,PMountRenewalList,RenewalConfing} ->
            do_mount_renewal3_2(Unique,Module,Method,DataRecord,RoleId,Line,
                                RoleAttr,MountGoods,PMountRenewalList,RenewalConfing)
    end.
do_mount_renewal3_1(Unique,Module,Method,DataRecord,RoleId,Line,
                    RoleAttr,PMountRenewalList,MountGoods) -> 
    AllGold = RoleAttr#p_role_attr.gold + RoleAttr#p_role_attr.gold_bind,
    SendSelf=#m_equip_mount_renewal_toc{
      succ = true,
      op_type = DataRecord#m_equip_mount_renewal_tos.op_type,
      mount_id = DataRecord#m_equip_mount_renewal_tos.mount_id,
      mount_type_id = DataRecord#m_equip_mount_renewal_tos.mount_type_id,
      mount_pos = DataRecord#m_equip_mount_renewal_tos.mount_pos,
      renewal_type = DataRecord#m_equip_mount_renewal_tos.renewal_type,
      mount = MountGoods,
      end_time = MountGoods#p_goods.end_time,
      renewal_confs= PMountRenewalList,
      all_gold = AllGold},
    ?DEBUG("~ts,SendSelf=~w",["坐骑续期返回结果为",SendSelf]),
    common_misc:unicast(Line, RoleId, Unique, Module, Method, SendSelf).

do_mount_renewal2(RoleId,DataRecord) ->
    #m_equip_mount_renewal_tos{mount_id = MountId,
                               op_type = OpType,
                               mount_type_id = MountTypeId,
                               mount_pos = MountPos,
                               renewal_type = RenewalType} = DataRecord,
    [RenewalConfingList] = common_config_dyn:find(mount_level,mount_renewals),
    PMountRenewalList = 
        lists:foldl(
          fun(PMountRenewal,AccPMountRenewalList) ->
                  if MountTypeId =:= PMountRenewal#p_equip_mount_renewal.type_id ->
                          [PMountRenewal|AccPMountRenewalList];
                     true ->
                          AccPMountRenewalList
                  end
          end,[],RenewalConfingList),
    if PMountRenewalList =/= [] ->
            next;
       true ->
            erlang:throw({error,?_LANG_MOUNT_RENEWAL_QUERY_TYPE_ID,0})
    end,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
    MountGoods = 
        if MountPos =:= 1 -> %% 1背包
                case mod_bag:get_goods_by_id(RoleId,MountId) of
                    {error,goods_not_found} ->
                        erlang:throw({error,?_LANG_MOUNT_RENEWAL_NOT_GOODS,0});
                    {ok,BagMountGoods} ->
                        BagMountGoods
                end;
           MountPos =:= 2 -> %% 2身上
                EquipList = 
                    case RoleAttr#p_role_attr.equips of
                        undefined ->
                            [];
                        _ ->
                            RoleAttr#p_role_attr.equips
                    end,
                case lists:keyfind(MountId,#p_goods.id,EquipList) of
                    false ->
                        erlang:throw({error,?_LANG_MOUNT_RENEWAL_NOT_GOODS,0});
                    EquipMountGoods ->
                        EquipMountGoods
                end;
           true ->
                erlang:throw({error,?_LANG_MOUNT_RENEWAL_PARAM_ERROR,0})
        end,
    if MountGoods#p_goods.typeid =:= MountTypeId ->
            next;
       true ->
            erlang:throw({error,?_LANG_MOUNT_RENEWAL_NOT_GOODS,0})
    end,
    if OpType =:= 1 -> %% 查询操作
            {ok,OpType,RoleAttr,PMountRenewalList,MountGoods};
       OpType =:= 2 -> %% 续期操作
            RenewalConfing = 
                case 
                    lists:foldl(
                      fun(PRenewalConfing,AccRenewalConfing) ->
                              if AccRenewalConfing =:= undefined 
                                 andalso PRenewalConfing#p_equip_mount_renewal.type_id =:= MountTypeId 
                                 andalso PRenewalConfing#p_equip_mount_renewal.renewal_type =:= RenewalType ->
                                      PRenewalConfing;
                                 true ->
                                      AccRenewalConfing
                              end 
                      end,undefined,PMountRenewalList) of
                    undefined ->
                        erlang:throw({error,?_LANG_MOUNT_RENEWAL_SELECT_RENEWAL_TYPE,0});
                    RenewalConfingT ->
                        RenewalConfingT
                end,
            if MountGoods#p_goods.end_time =:= 0 ->
                    erlang:throw({error,?_LANG_MOUNT_RENEWAL_NOT_EXPIRED,0});
               true ->
                    next
            end,
            {ok,OpType,RoleAttr,MountGoods,PMountRenewalList,RenewalConfing};
       true ->
            erlang:throw({error,?_LANG_MOUNT_RENEWAL_PARAM_ERROR,0})
    end.

do_mount_renewal3_2(Unique,Module,Method,DataRecord,RoleId,Line,
                    RoleAttr,MountGoods,PMountRenewalList,RenewalConfing) ->
    
    case db:transaction(
           fun() -> 
                   do_t_mount_renewal(RoleId,DataRecord,RoleAttr,MountGoods,RenewalConfing)
           end) of
        {atomic,{ok,NewRoleAttr,NewMountGoods}} ->
            do_mount_renewal4(Unique,Module,Method,DataRecord,RoleId,Line,
                              NewRoleAttr,NewMountGoods,PMountRenewalList,RenewalConfing);
        {aborted,{Reason,ReasonCode}} ->
            {Reason2,ReasonCode2} = 
                if erlang:is_binary(Reason) ->
                        {Reason,ReasonCode};
                   true ->
                        ?ERROR_MSG("~ts,Reason=~w",["刷新幸运积分出错",Reason]),
                        {?_LANG_EDUCATE_FB_GAMBLING_PARAM_ERROR,0}
                end,
            do_mount_renewal_error(Unique, Module, Method, DataRecord, RoleId, Line,Reason2,ReasonCode2)
    end.
    
do_mount_renewal4(Unique,Module,Method,DataRecord,RoleId,Line,
                  RoleAttr,MountGoods,PMountRenewalList,RenewalConfing) ->
    %% 通知银子变化 通知背包物品变化 返回
    AllGold = RoleAttr#p_role_attr.gold + RoleAttr#p_role_attr.gold_bind,
    SendSelf=#m_equip_mount_renewal_toc{
      succ = true,
      op_type = DataRecord#m_equip_mount_renewal_tos.op_type,
      mount_id = DataRecord#m_equip_mount_renewal_tos.mount_id,
      mount_type_id = DataRecord#m_equip_mount_renewal_tos.mount_type_id,
      mount_pos = DataRecord#m_equip_mount_renewal_tos.mount_pos,
      renewal_type = DataRecord#m_equip_mount_renewal_tos.renewal_type,
      end_time = MountGoods#p_goods.end_time,
      op_fee = RenewalConfing#p_equip_mount_renewal.renewal_fee,
      mount = MountGoods,
      renewal_confs= PMountRenewalList,
      all_gold = AllGold},
    ?DEBUG("~ts,SendSelf=~w",["坐骑续期返回结果为",SendSelf]),
    common_misc:unicast(Line, RoleId, Unique, Module, Method, SendSelf),
    UnicastArg = {role, RoleId},
    AttrChangeList = [#p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value = RoleAttr#p_role_attr.gold},
                      #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value = RoleAttr#p_role_attr.gold_bind}],
    common_misc:role_attr_change_notify(UnicastArg,RoleId,AttrChangeList).
do_mount_renewal_error(Unique, Module, Method, DataRecord, RoleId, Line,Reason,ReasonCode) ->
    SendSelf=#m_equip_mount_renewal_toc{
      succ = false,
      op_type = DataRecord#m_equip_mount_renewal_tos.op_type,
      mount_id = DataRecord#m_equip_mount_renewal_tos.mount_id,
      mount_type_id = DataRecord#m_equip_mount_renewal_tos.mount_type_id,
      mount_pos = DataRecord#m_equip_mount_renewal_tos.mount_pos,
      renewal_type = DataRecord#m_equip_mount_renewal_tos.renewal_type,
      reason = Reason,
      reason_code = ReasonCode},
    ?DEBUG("~ts,SendSelf=~w",["坐骑续期返回结果为",SendSelf]),
    common_misc:unicast(Line, RoleId, Unique, Module, Method, SendSelf).

do_t_mount_renewal(RoleId,DataRecord,RoleAttr,MountGoods,RenewalConfing) ->
    #p_equip_mount_renewal{renewal_fee = RenewalFee} = RenewalConfing,
    NewEndTime = get_new_equip_monut_end_time(RenewalConfing,MountGoods),
    NewMountGoods = MountGoods#p_goods{end_time = NewEndTime},
    if DataRecord#m_equip_mount_renewal_tos.mount_pos =:= 1 -> %% 背包
            NewRoleAttr = RoleAttr,
            {ok,_}= mod_bag:update_goods(RoleId,NewMountGoods);
       DataRecord#m_equip_mount_renewal_tos.mount_pos =:= 2 -> %% 人物身上
            EquipList = lists:keydelete(MountGoods#p_goods.id,#p_goods.id,RoleAttr#p_role_attr.equips),
            NewRoleAttr = RoleAttr#p_role_attr{equips = [NewMountGoods|EquipList]};
       true ->
            NewRoleAttr = RoleAttr,
            db:abort({?_LANG_MOUNT_RENEWAL_NOT_GOODS,0})
    end,
    {ok,NewRoleAttr2}=do_t_mount_renewal2(RoleId,NewRoleAttr,RenewalFee),
    {ok,NewRoleAttr2,NewMountGoods}.

do_t_mount_renewal2(RoleId,RoleAttr,Fee) ->
    #p_role_attr{gold = Gold,gold_bind = GoldBind} = RoleAttr,
    NewRoleAttr = 
        if GoldBind < Fee ->
                NewGold = Gold - (Fee - GoldBind),
                if NewGold < 0 ->
                        db:abort({?_LANG_EDUCATE_FB_GAMBLING_NOT_GOLD,0});
                   true ->
                        RoleAttr2 = RoleAttr#p_role_attr{gold= NewGold,gold_bind=0 },
                        mod_map_role:set_role_attr(RoleId,RoleAttr2),
                        common_consume_logger:use_gold({RoleId, GoldBind, (Fee - GoldBind), ?CONSUME_TYPE_GOLD_EQUIP_MOUNT_RENEWAL, ""}),
                        RoleAttr2
                end;
           true ->
                NewGoldBind = GoldBind - Fee,
                RoleAttr2 = RoleAttr#p_role_attr{gold_bind=NewGoldBind},
                mod_map_role:set_role_attr(RoleId, RoleAttr2),
                common_consume_logger:use_gold({RoleId, Fee, 0, ?CONSUME_TYPE_GOLD_EQUIP_MOUNT_RENEWAL, ""}),
                RoleAttr2
        end,
    {ok,NewRoleAttr}.


get_new_equip_monut_end_time(RenewalConfing,MountGoods) ->
    NowSeconds = common_tool:now(),
    #p_equip_mount_renewal{renewal_type = RenewalType,
                           renewal_days = RenewalDays} = RenewalConfing,
    OldEndTime = 
        if MountGoods#p_goods.end_time >= NowSeconds ->
                MountGoods#p_goods.end_time;
           true ->
                NowSeconds
        end,
    NewEndTime = 
        if RenewalType =:= 9 ->
                0;
           true ->
                OldEndTime + (RenewalDays * 24 * 60 * 60)
        end,
    ?DEBUG("~ts,RenewalConfing=~w,NowSeconds=~w,OldEndTime=~w,NewEndTime=~w",
           ["坐骑过期时间计算如下",RenewalConfing,NowSeconds,MountGoods#p_goods.end_time,NewEndTime]),
    NewEndTime.
