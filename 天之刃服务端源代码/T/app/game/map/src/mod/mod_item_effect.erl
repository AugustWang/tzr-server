-module(mod_item_effect).

-include("mgeem.hrl").

-export([add_hp/11,add_mp/11,random_transform/11,return_home/11,random_move/11,add_exp_multiple_buff/11,incre_max_endruance/11,
         location_move/11,give_state/11,add_exp/11,add_attr_points/11,add_skill_points/11,used_extend_bag/11,used_gift_bag/11,
         add_big_hp/11,change_ybc_color/11,add_big_mp/11,reduce_pkpoint/11,reset_role_skill/11,add_money/11,member_gather/11,
         reset_attr_points/11, add_training_point/11,show_newcomer_manual/11, gather_factionist/11, change_skin/11,
         get_new_pet/11, add_pet_hp/11, add_pet_exp/11,reset_pet_attr/11, vip_active/11, add_drunk_buff/11,add_pet_refining_exp/11,
        add_pet_room/11]).

%%目前只供内部调用
-export([gift_goods_log/2]).


%%加血
add_hp(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,Par,_EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["加血时配置文件出错，错误的配置是",_ItemBaseInfo]),
            TransModule:abort(?_LANG_ITEM_ADD_HP_SYSTEM_ERROR);
        AddHp ->
            mod_map_role:do_role_add_hp(RoleAttr#p_role_attr.role_id,AddHp,RoleAttr#p_role_attr.role_id),
            %% 成就 add by caochuncheng 2011-03-08
            AchieveFun = {func,fun() ->  common_hook_achievement:hook({mod_item_effect,{add_hp,RoleAttr#p_role_attr.role_id}}) end},
            {NewItemInfo,RoleBase,RoleAttr,[Msg,AchieveFun|MsgList],[?_LANG_ITEM_EFFECT_ADDHP_OK|PromptList]}
    end.

%%加法力
add_mp(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,Par,_EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["加法力时配置文件出错，错误的配置是",_ItemBaseInfo]),
            TransModule:abort(?_LANG_ITEM_ADD_MP_SYSTEM_ERROR);
        AddMp ->
            mod_map_role:do_role_add_mp(RoleAttr#p_role_attr.role_id,AddMp,RoleAttr#p_role_attr.role_id),
            %% 成就 add by caochuncheng 2011-03-08
            AchieveFun = {func,fun() ->  common_hook_achievement:hook({mod_item_effect,{add_mp,RoleAttr#p_role_attr.role_id}}) end},
            {NewItemInfo,RoleBase,RoleAttr,[Msg,AchieveFun|MsgList],[?_LANG_ITEM_EFFECT_ADDMP_OK|PromptList]}
    end.

%%随机移动
random_transform(_ItemInfo,_ItemBaseInfo,_RoleBase,_RoleAttr,_MsgList,_PromptList,_Par,_EffectID,_UseNum,_State, TransModule) ->
    TransModule:abort(<<"暂时没有随机移动的功能！">>).

%%回城
return_home(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,_Par,_EffectID,UseNum,State, TransModule) ->
    %% 监狱不能使用回城卷
    #map_state{mapid=MapID} = State,
    case mod_mission_fb:is_mission_fb_map_id(MapID) of
        true ->
            TransModule:abort(?_LANG_ITEM_RETURN_HOME_IN_MISSION_FB);
        _ ->
            ignore
    end,
    case mod_jail:check_in_jail(MapID) of
        true ->
            TransModule:abort(?_LANG_ITEM_RETURN_HOME_IN_JAIL);
        _ ->
            ignore
    end,
    %% 战斗状态不能使用回城
    case mod_map_role:is_role_fighting(RoleBase#p_role_base.role_id) andalso RoleAttr#p_role_attr.level >= 40 of
        true ->
            TransModule:abort(?_LANG_MAP_TRANSFER_ROLE_FIGHTING);
        _ ->
            ignore
    end,
    [RoleState] = TransModule:read(?DB_ROLE_STATE, RoleBase#p_role_base.role_id),
    #r_role_state{trading = Trading} = RoleState,
    if Trading =:= 1 ->
            TransModule:abort(?_LANG_MAP_TRANSFER_TRADING_STATE);
       true ->
            ok
    end,
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    Fun = {func,fun() ->
                        catch mod_educate_fb:do_cancel_role_educate_fb(RoleAttr#p_role_attr.role_id),
                        catch mod_scene_war_fb:do_cancel_role_sw_fb(RoleAttr#p_role_attr.role_id),
                        mod_map_role:handle({return_home, RoleAttr#p_role_attr.role_id},State)
                end},
    {NewItemInfo,RoleBase,RoleAttr,[Fun,Msg|MsgList],[<<"成功回城">>|PromptList]}.

%%随机传送
random_move(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,_Par,_EffectID,UseNum,State, TransModule) ->
    case mod_map_role:is_role_fighting(RoleBase#p_role_base.role_id) andalso RoleAttr#p_role_attr.level >= 40 of
        true ->
            TransModule:abort(?_LANG_MAP_TRANSFER_ROLE_FIGHTING);
        _ ->
            ignore
    end,
    %% 在国外不能使用传送
    #p_role_base{faction_id=FactionID} = RoleBase,
    #map_state{mapid=MapID} = State,
    case common_misc:if_in_self_country(FactionID, MapID) of
        false ->
            TransModule:abort(?_LANG_ITEM_RANDOM_MOVE_FORBIDDEN);
        _ ->
            ok
    end,
    [RoleState] = db:read(?DB_ROLE_STATE, RoleBase#p_role_base.role_id),
    #r_role_state{trading = Trading} = RoleState,
    if Trading =:= 1 ->
            TransModule:abort(?_LANG_MAP_TRANSFER_TRADING_STATE);
       true ->
            ok
    end,
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    mod_map_role:handle({random_move, RoleAttr#p_role_attr.role_id}, State),
    {NewItemInfo,RoleBase,RoleAttr,[Msg|MsgList],[<<"传送成功">>|PromptList]}.

%%使用多倍经验符
add_exp_multiple_buff(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,Par,_EffectID,UseNum,_State, TransModule) ->
    #p_role_base{role_id=RoleID} = RoleBase,
    {NewItemInfo,Msg} = update_item(RoleID,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?ERROR_MSG("~ts:~w ~w~n",["使用多倍经验符时配置文件出错，错误的配置是",_ItemBaseInfo,_Reason]),
            TransModule:abort(?_LANG_ITEM_ADD_EXP_MULTIPLE_BUFF_SYSTEM_ERROR);
        BuffID ->
            {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
            {ok, RoleBase2, RoleAttr2} = mod_role_buff:t_add_buff2(RoleID, RoleID, role, [BuffDetail], RoleBase, RoleAttr),
            Msg2 = [Msg|mod_role_buff:get_trans_func_list()],
            mod_role_buff:clear_trans_func_list(),
            {NewItemInfo,RoleBase2,RoleAttr2,lists:append([Msg2, MsgList]),[?_LANG_ITEM_EFFECT_ADDEXP_OK|PromptList]}
    end. 

%%使用修理道具
incre_max_endruance(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,Par,EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["使用多修理工具时配置文件出错，错误的配置是",_ItemBaseInfo]),
            TransModule:abort(?_LANG_ITEM_USE_FIX_TOOL_SYSTEM_ERROR);
        ParEnDiff ->
            case mod_bag:get_goods_by_id(RoleAttr#p_role_attr.role_id, EffectID) of
                {ok, E} ->
                    Equip = E;
                _ ->
                    Equips = RoleAttr#p_role_attr.equips,
                    case lists:keyfind(EffectID, #p_goods.id, Equips) of
                        false ->
                            Equip = 0,
                            TransModule:abort(?_LANG_ITEM_CANT_FIND_EFFECT_ITEM);
                        E ->
                            Equip = E
                    end
            end,
            [EquipBaseInfo] = common_config_dyn:find_equip(Equip#p_goods.typeid),
            MaxEnDiff = common_tool:random(1,ParEnDiff),
            R = mod_equip:t_reduce_equip_endurance(
                  RoleBase,RoleAttr,
                  [{Equip#p_goods.id, 0, 0, MaxEnDiff*1000, 2,Equip,EquipBaseInfo}]),
            mod_equip:unicast_equip_endurance_change(RoleAttr#p_role_attr.role_id,R),
            {_, _, _, RoleAttr2, _} = R,
            {NewItemInfo,RoleBase,RoleAttr2,[Msg|MsgList],
             [concat([binary_to_list(_ItemBaseInfo#p_item_base_info.itemname),"使用成功"])|PromptList]}
    end. 

%%定位传送
location_move(_ItemInfo,_ItemBaseInfo,_RoleBase,_RoleAttr,_MsgList,_PromptList,_Par,_EffectID,_UseNum,_State, TransModule) ->
    TransModule:abort(<<"暂时没有定位传送的功能！">>).

%%赋予状态
give_state(_ItemInfo,_ItemBaseInfo,_RoleBase,_RoleAttr,_MsgList,_PromptList,_Par,_EffectID,_UseNum,_State, TransModule) ->
    TransModule:abort(<<"暂时没有赋予状态的功能！">>).

%%加经验
add_exp(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,Par,_EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["使用经验药时配置文件出错，错误的配置是",_ItemBaseInfo]),
            TransModule:abort(?_LANG_ITEM_ADD_EXP_SYSTEM_ERROR);
        AddExp ->
            #p_role_attr{exp=Exp, next_level_exp=NextLevelExp} = RoleAttr,
            case Exp >= NextLevelExp of
                true ->
                    TransModule:abort(?_LANG_ITEM_ADD_EXP_EXP_FULL);
                _ ->
                    ok
            end,
            mod_map_role:add_exp(RoleAttr#p_role_attr.role_id,AddExp),
            {NewItemInfo,RoleBase,RoleAttr,[Msg|MsgList],[concat(["道具使用增加经验",erlang:integer_to_list(AddExp)])|PromptList]}
    end. 

%%加属性点
add_attr_points(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,Par,_EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["增加属性点时配置文件出错，错误的配置是",_ItemBaseInfo]),
            TransModule:abort(?_LANG_ITEM_ADD_ATTR_POINT_SYSTEM_ERROR);
        AddPoints ->
            #p_role_base{role_id=RoleID,remain_attr_points = OldPoints} = RoleBase,
            NewRoleBase = RoleBase#p_role_base{remain_attr_points=OldPoints+AddPoints},
            Change = #p_role_attr_change{change_type = ?ROLE_ATTR_POINT_CHANGE, 
                                         new_value = AddPoints + OldPoints},
            Data = #m_role2_attr_change_toc{roleid = RoleID, changes = [Change]},
            NewMsgList = [{RoleID, ?ROLE2, ?ROLE2_ATTR_CHANGE, Data},Msg|MsgList],
            {NewItemInfo,NewRoleBase,RoleAttr,NewMsgList,[concat(["道具使用增加属性点",erlang:integer_to_list(AddPoints)])|PromptList]}
    end. 

%%加技能点
add_skill_points(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,Par,_EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["增加技能点时配置文件出错，错误的配置是",_ItemBaseInfo]),
            TransModule:abort(?_LANG_ITEM_ADD_SKILL_POINT_SYSTEM_ERROR);
        AddPoints ->
            #p_role_attr{role_id=RoleID,remain_skill_points = OldPoints} = RoleAttr,
            NewRoleAttr = RoleAttr#p_role_attr{remain_skill_points=AddPoints + OldPoints},
            Change = #p_role_attr_change{change_type = ?ROLE_SKILL_POINT_CHANGE, 
                                         new_value = AddPoints + OldPoints},
            Data = #m_role2_attr_change_toc{roleid = RoleID, changes = [Change]},
            NewMsgList = [{RoleID, ?ROLE2, ?ROLE2_ATTR_CHANGE, Data},Msg|MsgList],
            {NewItemInfo,RoleBase,NewRoleAttr,NewMsgList,[concat(["道具使用增加技能点",erlang:integer_to_list(AddPoints)])|PromptList]}
    end. 

%%使用扩展背包
used_extend_bag(ItemInfo,_ItemBaseInfo,_RoleBase,RoleAttr,MsgList,PromptList,_Par,_EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    [BagBasicInfo]= db:read(?DB_ROLE_BAG_BASIC_P,RoleAttr#p_role_attr.role_id),
    {ok,{role_bag_list,IDList},_} = mod_bag:get_role_bag_info(RoleAttr#p_role_attr.role_id),
    BagID =  
        case lists:keyfind(2,1,BagBasicInfo#r_role_bag_basic.bag_basic_list) of
            false ->
                2;
            _ ->
                case lists:keyfind(3,1,BagBasicInfo#r_role_bag_basic.bag_basic_list) of
                    false ->
                        3;
                    _ ->
                        db:abort(?_LANG_ITEM_EFFECT_NOT_EMPTY_BAG)
                end
        end,
    TimeOut = ItemInfo#p_goods.end_time,
    case check_in_use_time(ItemInfo) of
        true->
            [{r_bag_config,_,Rows,Columns,GridNumber}] = 
                common_config_dyn:find(extend_bag,ItemInfo#p_goods.typeid),
            ?INFO_MSG("BagID ：~w Bags:~w~n",[BagID,IDList]),
            mod_bag:create_bag(RoleAttr#p_role_attr.role_id,{BagID,ItemInfo#p_goods.typeid,TimeOut,Rows,Columns,GridNumber}),
            BagBasicList = [{BagID,ItemInfo#p_goods.typeid,TimeOut,Rows,Columns,GridNumber}|BagBasicInfo#r_role_bag_basic.bag_basic_list],
            ?INFO_MSG("BagInfo ~w~n",[get({role_bag,RoleAttr#p_role_attr.role_id,1})]),
            {1,MainBagTypeID,MainOutUseTime,MainRows,MainClowns,MainGridNumber} 
                = mod_bag:get_bag_info_by_id(RoleAttr#p_role_attr.role_id,1),
            BagBasicList2 = lists:keydelete(1,1,BagBasicList),
            NewBagBasicInfo = BagBasicInfo#r_role_bag_basic{bag_basic_list=[{1,MainBagTypeID,MainOutUseTime,MainRows,MainClowns,MainGridNumber}|BagBasicList2]},
            TransModule:write(?DB_ROLE_BAG_BASIC_P,NewBagBasicInfo,write),
            Data =  #m_item_new_extend_bag_toc{ bagid = BagID,
                                                rows = Rows,
                                                columns = Columns,
                                                grid_number = GridNumber, 
                                                main_rows = MainRows,
                                                main_columns = MainClowns,
                                                main_grid_number = MainGridNumber,
                                                typeid = ItemInfo#p_goods.typeid}, 
            %% 成就 add by caochuncheng 2011-03-08
            AchieveFun = {func,fun() ->  common_hook_achievement:hook({mod_item_effect,{used_extend_bag,RoleAttr#p_role_attr.role_id}}) end},
            NewMsgList = [{RoleAttr#p_role_attr.role_id, ?ITEM, ?ITEM_NEW_EXTEND_BAG, Data},Msg,AchieveFun|MsgList],
            {NewItemInfo,_RoleBase,RoleAttr,NewMsgList,[?_LANG_ITEM_EFFECT_USED_BAG_OK|PromptList]};
        false->
            {ItemInfo,_RoleBase,RoleAttr,MsgList,PromptList}
    end.

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

%%使用礼包
used_gift_bag(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,Par,_EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["使用礼包时配置文件出错，错误的配置是",_ItemBaseInfo]),
            TransModule:abort(?_LANG_ITEM_USE_GIFT_SYSTEM_ERROR);
        ID ->
            [{r_gift,ID,Type,GiftList}] = common_config_dyn:find(gift,ID),
            %%1全部产生礼品,2随机产生礼品
            
            RoleID = RoleAttr#p_role_attr.role_id,
            if ItemInfo#p_goods.typeid =:= 11400065 -> %%首充礼包世界广播
                   FunBc = fun()-> 
                                   GoodsName = common_misc:format_goods_name_colour(ItemInfo#p_goods.current_colour,ItemInfo#p_goods.name),
                                   Text = lists:flatten(io_lib:format(?_LANG_ITEM_USE_SHOU_CHONG_BCAST,
                                                                      [common_tool:to_list(RoleBase#p_role_base.role_name),GoodsName])),
                                   common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,Text)
                           end;
               true ->
                   FunBc = fun()-> ignore end
            end,
            if Type =:= 1 ->
                    {ok,GoodsList,GoodsLBase,CreateInfoList} = all_produce_gift(RoleID,GiftList),
                    Names = format_goods_name(GoodsLBase),
                    F1 = fun() -> common_misc:update_goods_notify({role,RoleID}, GoodsList) end,
                    F2 = fun() -> ?MODULE:gift_goods_log(CreateInfoList,RoleID) end,
                    F3 = fun() -> 
                            hook_prop:hook(create, GoodsList)
                         end,
                    
                    ?INFO_MSG("GoodsList:~w~n",[GoodsList]),
                    {NewItemInfo,RoleBase,RoleAttr,[{func,FunBc},{func, F3},{func,F2},{func,F1},Msg|MsgList],
                     [concat([?_LANG_ITEM_EFFECT_USED_GIFT_OK,Names])|PromptList]};
               Type =:= 2 ->
                    {ok,GoodsList,GoodsLBase,CreateInfoList} = random_produce_gift(RoleID,GiftList),
                    Names = format_goods_name(GoodsLBase),
                    F1 = fun() -> common_misc:update_goods_notify({role,RoleID}, GoodsList) end,
                    F2 = fun() -> ?MODULE:gift_goods_log(CreateInfoList,RoleID) end,
                    F3 = fun() -> 
                            hook_prop:hook(create, GoodsList)
                         end,
                    
                    ?INFO_MSG("GoodsList:~w~n",[GoodsList]),
                    {NewItemInfo,RoleBase,RoleAttr,[{func,FunBc},{func, F3},{func,F2},{func,F1},Msg|MsgList],
                     [concat([?_LANG_ITEM_EFFECT_USED_GIFT_OK,Names])|PromptList]};
               true ->
                    TransModule:abort(?_LANG_ITEM_EFFECT_USED_GIFT_FAIL)
            end
    end.

all_produce_gift(RoleID,GiftList) ->
    {CreateInfoList,BaseL} = lists:foldl(
                               fun(GiftBase,{C,B}) ->
                                       case GiftBase#p_gift_goods.type of
                                           ?TYPE_ITEM->
                                               Quality = 0,SubQuality = 0,
                                               [BaseInfo]=common_config_dyn:find_item(GiftBase#p_gift_goods.typeid),
                                               Color = BaseInfo#p_item_base_info.colour;
                                           ?TYPE_STONE->
                                               Quality = 0,SubQuality = 0,
                                               [BaseInfo]=common_config_dyn:find_stone(GiftBase#p_gift_goods.typeid),
                                               Color = BaseInfo#p_stone_base_info.colour;
                                           ?TYPE_EQUIP->
                                               {Quality,SubQuality} = mod_refining_tool:get_equip_quality_by_color(GiftBase#p_gift_goods.color),
                                               Color = GiftBase#p_gift_goods.color
                                       end,
                                       {[#r_goods_create_info{bind=GiftBase#p_gift_goods.bind, 
                                                              type=GiftBase#p_gift_goods.type, 
                                                              start_time=GiftBase#p_gift_goods.start_time,
                                                              end_time=GiftBase#p_gift_goods.end_time,
                                                              type_id=GiftBase#p_gift_goods.typeid,
                                                              num=GiftBase#p_gift_goods.num,
                                                              quality = Quality,sub_quality = SubQuality,
                                                              color=Color}|C],
                                        [{GiftBase#p_gift_goods.typeid,
                                          GiftBase#p_gift_goods.type,
                                          GiftBase#p_gift_goods.num}|B]}
                               end,{[],[]},GiftList),
    {ok,GoodsList} = mod_bag:create_goods(RoleID, CreateInfoList),
    {ok,GoodsList,BaseL,CreateInfoList}.

random_produce_gift(RoleID,GiftList) ->
    Sum = lists:foldl(fun(GiftBase,Acc) -> Acc+GiftBase#p_gift_goods.rate end,0,GiftList),
    RandomR = common_tool:random(1,Sum),
    {ok,Re} = (catch lists:foldl(
                 fun(Result,AccR) ->
                         if AccR+Result#p_gift_goods.rate < RandomR ->
                                AccR+Result#p_gift_goods.rate;
                            true ->
                                throw({ok,Result})
                         end
                 end,0,GiftList)),
    
    Color = 
        case Re#p_gift_goods.type of
            ?TYPE_ITEM->
                [BaseInfo]=common_config_dyn:find_item(Re#p_gift_goods.typeid),
                BaseInfo#p_item_base_info.colour;
            ?TYPE_STONE->
                [BaseInfo]=common_config_dyn:find_stone(Re#p_gift_goods.typeid),
                BaseInfo#p_stone_base_info.colour;
            ?TYPE_EQUIP->
                Re#p_gift_goods.color
        end,
    CreateInfo = #r_goods_create_info{bind=Re#p_gift_goods.bind, 
                                      type=Re#p_gift_goods.type, 
                                      start_time=Re#p_gift_goods.start_time,
                                      end_time=Re#p_gift_goods.end_time,
                                      type_id=Re#p_gift_goods.typeid,
                                      num=Re#p_gift_goods.num,
                                      color=Color},
    {ok,GoodsList} = mod_bag:create_goods(RoleID, CreateInfo),
    CreateInfoList = [CreateInfo],
    {ok,GoodsList,[{Re#p_gift_goods.typeid,Re#p_gift_goods.type,Re#p_gift_goods.num}],CreateInfoList}.

format_goods_name(GoodsList) ->
    lists:foldl(
      fun({TypeID,Type,Num},Names) ->
              Name = 
                  case Type of
                      ?TYPE_EQUIP ->
                          [BaseInfo]=common_config_dyn:find_equip(TypeID),
                          BaseInfo#p_equip_base_info.equipname;
                      ?TYPE_ITEM ->
                          [BaseInfo]=common_config_dyn:find_item(TypeID),
                          BaseInfo#p_item_base_info.itemname;
                      ?TYPE_STONE ->
                          [BaseInfo]=common_config_dyn:find_stone(TypeID),
                          BaseInfo#p_stone_base_info.stonename
                  end,
              concat(["\n",binary_to_list(Name),"×",Num,Names])
      end,"",GoodsList).

gift_goods_log(CreateInfoList,RoleID) ->
    lists:foreach(
      fun(CreateInfo) ->
              common_item_logger:log(RoleID,CreateInfo,?LOG_ITEM_TYPE_LI_BAO_HUO_DE)
      end,CreateInfoList).

%%使用大红药
add_big_hp(_ItemInfo,_ItemBaseInfo,_RoleBase,_RoleAttr,_MsgList,_PromptList,Par,_EffectID,_UseNum,_State, TransModule) ->
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["使用大红时配置文件出错，错误的配置是",_ItemBaseInfo]),
            TransModule:abort(?_LANG_ITEM_USE_BIG_HP_SYSTEM_ERROR);
        Key ->
            [{r_big_hp_mp,Key,_,_,Share}] = common_config_dyn:find(bighpmp,Key),
            {NewItemInfo,AddHp,Msg} = 
                case _ItemInfo#p_goods.current_endurance-Share of
                    R when R =< 0 ->
                        NewItemInfoTmp = _ItemInfo#p_goods{current_num=0},
                        mod_bag:delete_goods(_RoleAttr#p_role_attr.role_id,_ItemInfo#p_goods.id),
                        {NewItemInfoTmp,Share+R,
                         {func,fun() -> undefined end}};
                    R ->
                        NewItemInfoTmp = _ItemInfo#p_goods{current_num=1,current_endurance=R},
                        mod_bag:update_goods(_RoleAttr#p_role_attr.role_id,NewItemInfoTmp),
                        {NewItemInfoTmp,Share,
                         {func,fun() -> common_misc:update_goods_notify({role,_RoleAttr#p_role_attr.role_id},NewItemInfoTmp) end}}
                end,
            ?INFO_MSG("newiteminfo:~w~n",[NewItemInfo]),
            mod_map_role:do_role_add_hp(_RoleAttr#p_role_attr.role_id, AddHp, _RoleAttr#p_role_attr.role_id),
            %% 成就 add by caochuncheng 2011-03-08
            AchieveFun = {func,fun() ->  common_hook_achievement:hook({mod_item_effect,{add_big_hp,_RoleAttr#p_role_attr.role_id}}) end},
            {NewItemInfo,_RoleBase,_RoleAttr,[Msg,AchieveFun|_MsgList],[?_LANG_ITEM_EFFECT_ADDHP_OK|_PromptList]}
    end.

%%使用换车令
change_ybc_color(ItemInfo,_ItemBaseInfo,_RoleBase,RoleAttr,_MsgList,_PromptList,_Par,_EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case mod_ybc_person:change_ybc_color(RoleAttr#p_role_attr.role_id, prop) of
        {error, has_public} ->
            TransModule:abort(?_LANG_PERSONYBC_HAS_PUBLIC_CAN_NOT_CHANGE_COLOR);
        {error, best_color} ->
            TransModule:abort(?_LANG_PERSONYBC_HAS_GOT_THE_BEST_COLOR);
        {ok, Color} ->
			ColorStr = 
				case Color of
					1 ->
						?_LANG_YBC_COLOR1;
					2 ->
						?_LANG_YBC_COLOR2;
					3 ->
						?_LANG_YBC_COLOR3;
					4 ->
						?_LANG_YBC_COLOR4;
					5 ->
						?_LANG_YBC_COLOR5
				end,
			Lang = io_lib:format(?_LANG_CHANGE_YBC_COLOR_SUCC, [ColorStr]),
            {NewItemInfo,_RoleBase,RoleAttr,[Msg|_MsgList],[Lang|_PromptList]}
    end.



%%使用大蓝药
add_big_mp(_ItemInfo,_ItemBaseInfo,_RoleBase,_RoleAttr,_MsgList,_PromptList,Par,_EffectID,_UseNum,_State, TransModule) ->
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["使用大蓝时配置文件出错，错误的配置是",_ItemBaseInfo]),
            TransModule:abort(?_LANG_ITEM_USE_BIG_MP_SYSTEM_ERROR);
        Key ->
            [{r_big_hp_mp,Key,_,_,Share}] = common_config_dyn:find(bighpmp,Key),
            {NewItemInfo,AddMp,Msg} = 
                case _ItemInfo#p_goods.current_endurance-Share of
                    R when R =< 0 ->
                        NewItemInfoTmp = _ItemInfo#p_goods{current_num=0},
                        mod_bag:delete_goods(_RoleAttr#p_role_attr.role_id,_ItemInfo#p_goods.id),
                        {NewItemInfoTmp,Share+R,
                         {func,fun() -> undefined end}};
                    R ->
                        NewItemInfoTmp = _ItemInfo#p_goods{current_num=1,current_endurance=R},
                        mod_bag:update_goods(_RoleAttr#p_role_attr.role_id,NewItemInfoTmp),
                        {NewItemInfoTmp,Share,
                         {func,fun() -> common_misc:update_goods_notify({role,_RoleAttr#p_role_attr.role_id},NewItemInfoTmp) end}}
                end,
            mod_map_role:do_role_add_mp(_RoleAttr#p_role_attr.role_id, AddMp, _RoleAttr#p_role_attr.role_id),
            %% 成就 add by caochuncheng 2011-03-08
            AchieveFun = {func,fun() ->  common_hook_achievement:hook({mod_item_effect,{add_big_mp,_RoleAttr#p_role_attr.role_id}}) end},
            {NewItemInfo,_RoleBase,_RoleAttr,[Msg,AchieveFun|_MsgList],[?_LANG_ITEM_EFFECT_ADDMP_OK|_PromptList]}
    end.

%%减少pk点
reduce_pkpoint(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,_MsgList,_PromptList,Par,_EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    #p_role_base{role_id=RoleID, pk_points=PKPoint} = RoleBase,
    case PKPoint =:= 0 of
        true ->
            TransModule:abort(?_LANG_ITEM_PKPOINT_ZERO);
        _ ->
            next
    end,
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            TransModule:abort(?_LANG_ITEM_USE_REDUCE_PKPOINT_SYSMTE_ERROR);
        ReducePoint ->
            NewPKPoint =
                case PKPoint - ReducePoint < 0 of
                    true ->
                        0;
                    _ ->
                        PKPoint - ReducePoint
                end,
            mod_map_role:do_update_map_role_info(RoleID,[{#p_map_role.pk_point, NewPKPoint}],_State),
            NewPromptList = [common_tool:get_format_lang_resources(?_LANG_MOUNT_REDUCE_PKPOINT_SUCC, [PKPoint-NewPKPoint])|_PromptList],
            {NewItemInfo,RoleBase#p_role_base{pk_points=NewPKPoint},RoleAttr,[Msg|_MsgList],NewPromptList}
    end.

%%洗技能点道具
reset_role_skill(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,PromptList,_Par,_EffectID,UseNum,_State, _TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    {NewRoleBase, NewRoleAttr} = 
        mod_skill:t_reset_role_skill(RoleAttr#p_role_attr.role_id, RoleBase, RoleAttr),

    #p_role_attr{role_id=RoleID} = RoleAttr,

    %% 清空玩家的技能使用时间
    mod_fight:erase_last_skill_time(role, RoleID),

    RemainPoint = NewRoleAttr#p_role_attr.remain_skill_points,
    Data = #m_skill_reset_toc{skill_points=RemainPoint},
    %% add by caochuncheng 2011-04-22 道具奖励功能hook
    ModItemGiftFun = {func,fun() ->  catch mod_gift:hook_category_change(
                                             NewRoleAttr#p_role_attr.role_id,
                                             NewRoleAttr#p_role_attr.level,
                                             NewRoleAttr#p_role_attr.category) end},
    NewMsgList = [ModItemGiftFun,{RoleID,?SKILL,?SKILL_RESET,Data},Msg|MsgList],
    {NewItemInfo,NewRoleBase,NewRoleAttr,NewMsgList,[?_LANG_ITEM_RESET_SKILL_OK|PromptList]}.

concat(List) when is_list(List)->
    lists:concat(List).

%%使用银票
add_money(ItemInfo,_ItemBaseInfo,_RoleBase,RoleAttr,_MsgList,_PromptList,Par,_EffectID,UseNum,_State, _TransModule) ->
    #p_role_attr{role_id=RoleID,gold=Gold1,gold_bind=GoldBind1,
                 silver=Silver1,silver_bind=SilverBind1,
                 sum_prestige = SumPrestige,cur_prestige = CurPrestige}=RoleAttr,
    {NewItemInfo,Msg} = update_item(RoleID,ItemInfo,UseNum),
    
    CardKey = common_tool:to_integer(Par),
    [#r_money{name=Name,deal_list=DealList}] = common_config_dyn:find(money,CardKey),
    
    %%目前只支持单个类型的兑换
    [{DealType,DealNum}|_T] = DealList,
    IsBind = ItemInfo#p_goods.bind,
    {DealMsg,RoleAttr2,ChangeList} =
        case {DealType,IsBind} of
            {gold,true}->
                common_consume_logger:gain_gold({RoleID,DealNum,0,?GAIN_TYPE_GOLD_ITEM_USE,
                                                 "",ItemInfo#p_goods.typeid,1}),
                {concat(["，获得绑定元宝 ",DealNum]),
                 RoleAttr#p_role_attr{gold_bind=GoldBind1+DealNum},
                 [#p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE,new_value=GoldBind1+DealNum}]};
            {gold,false}->
                common_consume_logger:gain_gold({RoleID,0,DealNum,?GAIN_TYPE_GOLD_ITEM_USE,
                                                 "",ItemInfo#p_goods.typeid,1}),
                {concat(["，获得绑元宝 ",DealNum]),
                 RoleAttr#p_role_attr{gold=Gold1+DealNum},
                 [#p_role_attr_change{change_type=?ROLE_GOLD_CHANGE,new_value=Gold1+DealNum}]};
            {silver,true}->
                common_consume_logger:gain_silver({RoleID,DealNum,0,?GAIN_TYPE_SILVER_ITEM_USE,
                                                   "",ItemInfo#p_goods.typeid,1}),
                {concat(["，获得绑定钱币 ",format_silver(DealNum)]),
                 RoleAttr#p_role_attr{silver_bind=SilverBind1+DealNum},
                 [#p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE,new_value=SilverBind1+DealNum}]};
            {silver,false}->
                common_consume_logger:gain_silver({RoleID,0,DealNum,?GAIN_TYPE_SILVER_ITEM_USE,
                                                   "",ItemInfo#p_goods.typeid,1}),
                {concat(["，获得钱币 ",format_silver(DealNum)]),
                 RoleAttr#p_role_attr{silver=Silver1+DealNum},
                 [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE,new_value=Silver1+DealNum}]};
            {prestige,_}->
                {concat(["，获得声望 ",DealNum]),
                 RoleAttr#p_role_attr{sum_prestige=SumPrestige+DealNum,
                                      cur_prestige=CurPrestige+DealNum},
                 [#p_role_attr_change{change_type=?ROLE_CUR_PRESTIGE_CHANGE,new_value=CurPrestige + DealNum},
                  #p_role_attr_change{change_type=?ROLE_SUM_PRESTIGE_CHANGE,new_value=SumPrestige + DealNum}]}
        end,
    DataRec = #m_role2_attr_change_toc{roleid=RoleID,changes=ChangeList},
    NewMsgList = [{RoleID,?ROLE2,?ROLE2_ATTR_CHANGE,DataRec},Msg|_MsgList],
    {NewItemInfo,_RoleBase,RoleAttr2,NewMsgList,[concat(["使用",Name,DealMsg])|_PromptList]}.
        

digital2Silver(Dig0) ->
    C = Dig0 rem 100,
    Dig1 = Dig0 div 100,
    B = Dig1 rem 100,
    A = Dig1 div 100,
    {A,B,C}.

format_silver(Num) when is_integer(Num)->
    format_silver( digital2Silver(Num) );
format_silver({A,B,C})
  when erlang:is_integer(A),
       erlang:is_integer(B),
       erlang:is_integer(C)->
    S0 = case C of
             0 ->
                 "";
             C ->
                 erlang:integer_to_list(C)++"文"
         end,
    S1 = case B of
             0 ->
                 S0;
             B ->
                 erlang:integer_to_list(B)++"两"++S0
         end,
    S2 = case A of
             0 ->
                 S1;
             A ->
                 erlang:integer_to_list(A)++"锭"++S1
         end,
    S2.

-define(member_gather_forbidden_map, [{10500, ?_LANG_ITEM_IN_10500}, {10400, ?_LANG_ITEM_IN_10400}, 
                                      {10600, ?_LANG_ITEM_IN_10600}, {10700, ?_LANG_ITEM_IN_10700}]).

%%使用门派令
member_gather(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,_MsgList,_PromptList,_Par,_EffectID,UseNum,State, TransModule) ->
    #map_state{mapid=MapID} = State,
    case lists:keyfind(MapID, 1, ?member_gather_forbidden_map) of
        {_, Reason} ->
            TransModule:abort(Reason);
        _ ->
            ok
    end,
    case mod_hero_fb:is_hero_fb_map_id(MapID) of
        true->
            TransModule:abort(?_LANG_ITEM_MEMBER_GATHER_IN_HERO_FB);
        _ ->
            ok
    end,
    case mod_mission_fb:is_mission_fb_map_id(MapID) of
        true->
            TransModule:abort(?_LANG_ITEM_MEMBER_GATHER_IN_MISSION_FB);
        _ ->
            ok
    end,
    %% 非国战期间不能在敌国使用门派令
    #p_role_base{faction_id=FactionID, family_id=FamilyID} = RoleBase,
    case (not common_misc:if_in_self_country(FactionID, MapID))
        andalso (not common_misc:if_in_neutral_area(MapID)) andalso MapID =/= 10300
    of
        true ->
            case TransModule:read(?DB_WAROFFACTION, 1, read) of
                [] ->
                    TransModule:abort(?_LANG_ITEM_MEMBER_GATHER_NOT_IN_WAROFFACTION);
                [WarOfFactionInfo] ->
                    #r_waroffaction{attack_faction_id=AFI, defence_faction_id=DFI} = WarOfFactionInfo,

                    case AFI =:= FactionID orelse DFI =:= FactionID of
                        true ->
                            ok;
                        _ ->
                            TransModule:abort(?_LANG_ITEM_MEMBER_GATHER_NOT_IN_WAROFFACTION)
                    end
            end;
        _ ->
            ok
    end,

    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    AccMsgList = [Msg|_MsgList],
    FamilyID = RoleBase#p_role_base.family_id,
    RoleID =RoleAttr#p_role_attr.role_id,
    if FamilyID > 0 -> 
           [FamilyInfo] = TransModule:read(?DB_FAMILY,FamilyID,read),
           if FamilyInfo#p_family_info.owner_role_id =:= RoleID->
                  next;
              true ->
                  TransModule:abort(?_LANG_ITEM_NOT_FAMILY_OWNER)
           end,
           
           [FamilyExtInfo] = TransModule:dirty_read(?DB_FAMILY_EXT,FamilyID),
           #p_map_role{pos=Pos} = mod_map_actor:get_actor_mapinfo(RoleID, role),
           MapID = mgeem_map:get_mapid(),
           DistMapPos = #p_role_pos{map_id=MapID, pos=Pos},
           case FamilyExtInfo#r_family_ext.last_card_use_day =:= erlang:date() of
               true ->
                   case FamilyExtInfo#r_family_ext.last_card_use_count < 5 of
                       true ->
                           AccMsgList2 =  family_member_gather_final(MapID,FamilyInfo,FamilyID,DistMapPos,AccMsgList),
                           {NewItemInfo,RoleBase,RoleAttr,AccMsgList2,["使用成功，请等待帮众回应"|_PromptList]};
                       false ->
                           TransModule:abort(?_LANG_ITEM_COUNT_EXCEED)
                   end;
               false ->
                   AccMsgList2 =  family_member_gather_final(MapID,FamilyInfo,FamilyID,DistMapPos,AccMsgList),
                   {NewItemInfo,RoleBase,RoleAttr,AccMsgList2,["使用成功，请等待帮众回应"|_PromptList]}
           end;
       true  ->
           TransModule:abort(?_LANG_ITEM_NO_FAMILY)
    end.

%% 排除掉特殊状态（包括摆摊、死亡、商贸状态，在线挂机状态）
family_member_gather_final(DestMapID, _FamilyInfo, FamilyID, DistMapPos, AccMsgList)->    
    FuncGatherMember = {func, fun() -> common_family:info(FamilyID, {gather_members, DestMapID, DistMapPos}) end},
    [ FuncGatherMember | AccMsgList].

-define(king_token_used_limited, 3).
-define(general_token_used_limited, 2).

%%{25,使用国王令，召集国民
gather_factionist(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,MsgList,_PromptList,_Par,_EffectID,UseNum, State, TransModule) ->
    #p_role_base{role_id=RoleID, role_name=RoleName, faction_id=FactionID} = RoleBase,
    #map_state{mapid=MapID} = State,
    %% 更新物品数量
    {NewItemInfo,Msg} = update_item(RoleID,ItemInfo,UseNum),
    AccMsgList = [Msg|MsgList],
    %% 只有国战期间才能使用国王令
    WarOfFaction = case TransModule:read(?DB_WAROFFACTION, 1, read) of
                       [] ->
                           TransModule:abort(?_LANG_ITEM_GATHER_FACTIONIST_NOT_IN_WAR);
                       [WOF] ->
                           WOF
                   end,
    %% 进攻方只能在防守方平江跟本国普通地图，以及第二阶段防守方王都使用，防守方只能在本国普通地图使用
    InSelfCountry = common_misc:if_in_self_country(FactionID, MapID),
    #r_waroffaction{attack_faction_id=AttackFaction, defence_faction_id=DefenFaction, war_status=WarStatus} = WarOfFaction,
    if
        FactionID =:= AttackFaction andalso (MapID =/= 1*10000+DefenFaction*1000+102 andalso MapID =/= 1*10000+DefenFaction*1000+100) andalso (not InSelfCountry) ->
            TransModule:abort(?_LANG_ITEM_GATHER_FACTIONIST_ATTACK_CANNT_USED_THIS_MAP);

        FactionID =:= AttackFaction andalso 
        (MapID =/= 1*10000+DefenFaction*1000+102 andalso (MapID =/= 1*10000+DefenFaction*1000+100 orelse WarStatus =/= waroffaction_second_stage)) andalso 
        (not InSelfCountry) ->
            TransModule:abort(?_LANG_ITEM_GATHER_FACTIONIST_ATTACK_CANNT_USED_THIS_MAP_JINGCHENG);

        FactionID =:= DefenFaction andalso (not InSelfCountry) -> 
            TransModule:abort(?_LANG_ITEM_GAHTER_FACTIONIST_DEFEN_CANNT_USED_THIS_MAP);

        FactionID =:= AttackFaction orelse FactionID =:= DefenFaction ->
            AccMsgList2 = gather_factionist_2(RoleID, RoleName, MapID, FactionID, AccMsgList, TransModule),
            {NewItemInfo,RoleBase,RoleAttr,AccMsgList2,[?_LANG_ITEM_GATHER_FACTIONIST_SUCC|_PromptList]};

        true ->
            TransModule:abort(?_LANG_ITEM_GAHTER_FACTIONIST_NOT_IN_WAR)
    end.

gather_factionist_2(RoleID, RoleName, MapID, FactionID, AccMsgList, TransModule) ->
    [FactionInfo] = TransModule:read(?DB_FACTION, FactionID, write),
    Now = common_tool:now(),
    {{Y, M, D}, _} = calendar:gregorian_seconds_to_datetime(Now),
    NowDate = (Y+1970)*10000+M*100+D,
    #p_faction{office_info=OfficeInfo, king_token_used_log=UsedLog} = FactionInfo,
    case UsedLog of
        undefined ->
            UsedLog2 = #p_king_token_used_log{king_last_used_time=0, king_used_counter=0,
                                              general_last_used_time=0, general_used_counter=0};
        _ ->
            UsedLog2 = UsedLog
    end,
    #p_king_token_used_log{king_last_used_time=KingUsedTime, king_used_counter=KingCounter,
                           general_last_used_time=GeneralUsedTime, general_used_counter=GeneralCounter} = UsedLog2,
    {{Y2, M2, D2}, _} = calendar:gregorian_seconds_to_datetime(KingUsedTime),
    {{Y3, M3, D3}, _} = calendar:gregorian_seconds_to_datetime(GeneralUsedTime),
    KingUsedTimeT = (Y2+1970)*10000+M2*100+D2,
    GeneralUsedTimeT = (Y3+1970)*10000+M3*100+D3,
    %% 大将军ID
    GeneralRoleID = common_office:get_general_roleid(OfficeInfo#p_office.offices),
    %%判断宣战的玩家是否是国王或者大将军
    if
        OfficeInfo#p_office.king_role_id =:= RoleID ->
            %% 是否达到次数限制
            case KingUsedTimeT =:= NowDate andalso KingCounter >= ?king_token_used_limited of
                true ->
                    TransModule:abort(?_LANG_ITEM_GATHER_FACTIONIST_KING_LIMITED);
                _ ->
                    %% 更新国王令使用纪录
                    KingCounter2 = if KingUsedTimeT =:= NowDate -> KingCounter+1; true -> 1 end,
                    UsedLog3 = UsedLog2#p_king_token_used_log{king_last_used_time=Now, king_used_counter=KingCounter2},
                    FactionInfo2 = FactionInfo#p_faction{king_token_used_log=UsedLog3},
                    TransModule:write(?DB_FACTION, FactionInfo2, write),

                    gather_factionist_3(RoleID, RoleName, MapID, FactionID, AccMsgList, king, TransModule)
            end; 

        GeneralRoleID =:= RoleID ->
            case GeneralUsedTimeT =:= NowDate andalso GeneralCounter >= ?general_token_used_limited of
                true ->
                    TransModule:abort(?_LANG_ITEM_GATHER_FACTIONIST_GENERAL_LIMITED);
                _ ->
                    GeneralCounter2 = if GeneralUsedTimeT =:= NowDate -> GeneralCounter+1; true -> 1 end,
                    UsedLog3 = UsedLog2#p_king_token_used_log{general_last_used_time=Now, general_used_counter=GeneralCounter2},
                    FactionInfo2 = FactionInfo#p_faction{king_token_used_log=UsedLog3},
                    TransModule:write(?DB_FACTION, FactionInfo2, write),

                    gather_factionist_3(RoleID, RoleName, MapID, FactionID, AccMsgList, general, TransModule)
            end;

        true ->
            TransModule:abort(?_LANG_ITEM_GATHER_FACTIONIST_NO_RIGHT)
    end.

gather_factionist_3(FactionCallerID, RoleName, MapID, FactionID, AccMsgList, RoleType, TransModule)->
    case RoleType of
        king ->
            Msg = lists:flatten(io_lib:format(?_LANG_WAROFFACTION_GATHER_FACTIONIST_KING, [RoleName]));
        _ ->
            Msg = lists:flatten(io_lib:format(?_LANG_WAROFFACTION_GATHER_FACTIONIST_GENERAL, [RoleName]))
    end,

    {TX, TY} = mod_map_actor:get_actor_txty_by_id(FactionCallerID, role),
    %%使用后向本国国民（≥50级）发出召集
    Pattern = #r_role_online{faction_id=FactionID, _='_'},
    case TransModule:dirty_match_object(?DB_USER_ONLINE,Pattern) of
        []->
            AccMsgList;
        RoleOnlieList ->
            OnlineFactionist = lists:filter(fun(E)-> 
                                                    #r_role_online{role_id=RoleID} = E,
                                                    {ok, #p_role_attr{level=Level}} = common_misc:get_dirty_role_attr(RoleID),
                                                    Level>=40 andalso RoleID =/= FactionCallerID
                                            end, RoleOnlieList),
            FuncDoMemberGather = {func,fun() -> do_factionist_gather_toc(OnlineFactionist, Msg, MapID, TX, TY) end},
            ?DEBUG("OnlineFactionist=~w",[OnlineFactionist]),
            [ FuncDoMemberGather |AccMsgList]
    end.


%%执行召集国民（≥50级）的命令
do_factionist_gather_toc(RoleIDList, Msg, MapID, TX, TY)->
    %%TODO:修改国王召集的广播词
    R_toc = #m_waroffaction_gather_factionist_toc{message=Msg, mapid=MapID, tx=TX, ty=TY},
    lists:foreach(fun(#r_role_online{role_id=T})->
                          common_misc:unicast({role,T},?DEFAULT_UNIQUE,?WAROFFACTION,?WAROFFACTION_GATHER_FACTIONIST,R_toc)
                  end,RoleIDList).

%%重置属性点
reset_attr_points(ItemInfo,_ItemBaseInfo,RoleBase,RoleAttr,_MsgList,_PromptList,_Par,_EffectID,UseNum,_State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    #p_role_base{role_id=RoleID,
                 base_str=BaseStr, 
                 base_int=BaseInt, 
                 base_con=BaseCon, 
                 base_dex=BaseDex, 
                 base_men=BaseMen,
                 remain_attr_points=RemainAttrPoints} = RoleBase,
    if BaseStr =:= ?DEFAULT_ROLE_STR andalso 
       BaseInt =:= ?DEFAULT_ROLE_INT andalso 
       BaseCon =:= ?DEFAULT_ROLE_CON andalso 
       BaseDex =:= ?DEFAULT_ROLE_DEX andalso 
       BaseMen =:= ?DEFAULT_ROLE_MEN ->
            TransModule:abort(?_LANG_ITEM_ATTR_POINT_NO_SET);
       true ->
            next
    end,
    NewRoleBase = RoleBase#p_role_base{
                    base_str=?DEFAULT_ROLE_STR,
                    base_int=?DEFAULT_ROLE_INT,
                    base_con=?DEFAULT_ROLE_CON,
                    base_dex=?DEFAULT_ROLE_DEX,
                    base_men=?DEFAULT_ROLE_MEN,
                    remain_attr_points=RemainAttrPoints+(BaseStr-?DEFAULT_ROLE_STR)+(BaseInt-?DEFAULT_ROLE_INT)
                    +(BaseCon-?DEFAULT_ROLE_CON)+(BaseDex-?DEFAULT_ROLE_DEX)+(BaseMen-?DEFAULT_ROLE_MEN)
                   },
    NewMsgList = [{func,fun() -> mod_map_role:attr_change(RoleID) end},Msg|_MsgList],
    {NewItemInfo,NewRoleBase,RoleAttr,NewMsgList,[?_LANG_ITEM_RESET_ATTR_OK|_PromptList]}.

%% @doc 增训练点道具
add_training_point(ItemInfo, _ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, Par, _EffectID, UseNum, _State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    #p_role_base{role_id=RoleID} = RoleBase,
    Add = erlang:list_to_integer(Par),
   
    TrainingInfo = TransModule:read(?DB_TRAINING_CAMP, RoleID, write),
    case TrainingInfo of
        [] ->
            TrainingInfo2 = #r_training_camp{role_id=RoleID, training_point=Add, in_training=false};
        [Info] ->
            TrainingPoint = Info#r_training_camp.training_point,
            TrainingInfo2 = Info#r_training_camp{training_point=TrainingPoint+Add}
    end,
    TransModule:write(?DB_TRAINING_CAMP, TrainingInfo2, write),
    
    {NewItemInfo, RoleBase, RoleAttr,[Msg|MsgList], [io_lib:format(?_LANG_ITEM_ADD_TRAINING_POINT_OK, [Add])|PromptList]}.

-define(spec_role_state, [{?ROLE_STATE_DEAD, "死亡"}, {?ROLE_STATE_STALL, "摆摊"}, {?ROLE_STATE_COLLECT, "采集"},
                          {?ROLE_STATE_TRAINING, "训练"}, {?ROLE_STATE_ZAZEN, "打坐"}]).
-define(spec_buff_state, [{dizzy, "晕迷"}, {stop_body, "定身"}, {paralysis, "麻痹"}, {reduce_move_speed, "减速"}]).
-define(change_skin_buff_id, 10569).

%% @doc 变身符
change_skin(ItemInfo, ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, Par, EffectID, UseNum, _State, _TransModule) ->
    %% 更新物品数量
    #p_role_attr{role_id=RoleID, role_name=RoleName} = RoleAttr,
    {NewItemInfo, Msg} = update_item(RoleID, ItemInfo, UseNum),

    %% 随机变成一种动物
    Rate = random:uniform(100),
    [{WeightList, LastTime}] = common_config_dyn:find(etc, {change_skin, common_tool:to_integer(Par)}),
    ToAnimalID = get_change_skin_id(Rate, WeightList, 0),
    {ok, BuffDetail} = mod_skill_manager:get_buf_detail(?change_skin_buff_id),
    BuffDetail2 = BuffDetail#p_buf{value=ToAnimalID, last_value=LastTime},
    AddChangeSkinBuff = {func, fun() -> mod_role_buff:add_buff(EffectID, RoleID, role, BuffDetail2) end},
    
    case RoleID =:= EffectID of
        true ->
            MsgList2 = [AddChangeSkinBuff, Msg|MsgList];
        _ ->
            ChangeSkinMsg = lists:flatten(io_lib:format(?_LANG_ITEM_CHANGE_SKIN_NOTICE, [RoleName, ItemBaseInfo#p_item_base_info.itemname])),
            ChangeSkinNotice = {func, fun() -> common_broadcast:bc_send_msg_role(EffectID, ?BC_MSG_TYPE_SYSTEM, ChangeSkinMsg) end},

            MsgList2 = [ChangeSkinNotice, AddChangeSkinBuff, Msg|MsgList]
    end,

    {NewItemInfo, RoleBase, RoleAttr, MsgList2, [?_LANG_ITEM_CHANGE_SKIN_SUCC|PromptList]}.

%% @doc 获取变成动物的ID
get_change_skin_id(_Rate, [{AnimalID, _Weight}], _Sum) ->
    AnimalID;
get_change_skin_id(Rate, [{AnimalID, Weight}|T], Sum) ->
    case Weight+Sum >= Rate of
        true ->
            AnimalID;
        _ ->
            get_change_skin_id(Rate, T, Sum+Weight)
    end.
            
%%doc 打开新手卡宝典
show_newcomer_manual(ItemInfo, _ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, _Par, _EffectID, _UseNum, _State, _TransModule) ->
    %%空实现，前端目前不会发消息到后端
    {ItemInfo,RoleBase,RoleAttr,MsgList,PromptList}.


%%doc 更新道具的个数，可能是删除、也可能是更新个数
update_item(RoleID,ItemInfo,UseNum) ->
    case ItemInfo#p_goods.current_num - UseNum of
        R when R > 0 ->
            NewItemInfo = ItemInfo#p_goods{current_num=R},
            {ok,[_OldItemInfo]} = mod_bag:update_goods(RoleID,ItemInfo#p_goods{current_num = R}),
            {NewItemInfo,{func,fun() -> common_misc:update_goods_notify({role,RoleID},NewItemInfo) end}};
        _ ->
            {ok,[_OldItemInfo]} = mod_bag:delete_goods(RoleID,ItemInfo#p_goods.id),
            {ItemInfo#p_goods{current_num=0},{func,fun() -> undefined end}}
    end.

%%doc 使用道具获得一只宠物
get_new_pet(ItemInfo, _ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, Par, _EffectID, UseNum, _State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["使用道具配置文件出错，错误的配置是",_ItemBaseInfo]),
            TransModule:abort(?_LANG_SYSTEM_ERROR);
        PetTypeID ->
            case mod_map_pet:t_get_new_pet(RoleAttr#p_role_attr.role_id,PetTypeID,RoleAttr#p_role_attr.level,
                                           RoleAttr#p_role_attr.role_name,ItemInfo#p_goods.bind,RoleBase#p_role_base.faction_id) of
                ok ->
                    {NewItemInfo, RoleBase, RoleAttr,[Msg|MsgList], [?_LANG_ITEM_GET_NEW_PET_OK|PromptList]};
                {error,Reason} ->
                    TransModule:abort(Reason)
            end 
    end.

%%doc 使用道具增加宠物生命
add_pet_hp(ItemInfo, ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, Par, _EffectID, UseNum, _State, TransModule) ->
     {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["使用道具配置文件出错，错误的配置是",ItemBaseInfo]),
            TransModule:abort(?_LANG_SYSTEM_ERROR);
        HpAddValue ->
            case mod_map_pet:pet_add_hp(RoleAttr#p_role_attr.role_id,HpAddValue) of
                {ok,PetId,NewHp} ->
                    PetMsg = 
                        {func,fun() ->
                                      Record = #m_pet_attr_change_toc{pet_id=PetId,change_type=12,value=NewHp},
                                      common_misc:unicast({role,RoleAttr#p_role_attr.role_id}, ?DEFAULT_UNIQUE, ?PET, ?PET_ATTR_CHANGE, Record)
                         end},
                    {NewItemInfo, RoleBase, RoleAttr,[PetMsg,Msg|MsgList], [?_LANG_PET_ADD_HP_ITEM_USE_OK|PromptList]};
                {error,Reason} ->
                    TransModule:abort(Reason)
            end 
    end.


%%doc 使用道具增加宠物经验
add_pet_exp(ItemInfo, ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, Par, _EffectID, UseNum, _State, TransModule) ->
     {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case catch erlang:list_to_integer(Par) of
        {'EXIT',_Reason} ->
            ?DEBUG("~ts:~w~n",["使用道具配置文件出错，错误的配置是",ItemBaseInfo]),
            TransModule:abort(?_LANG_SYSTEM_ERROR);
        ExpAddValue ->
            case mod_map_pet:add_pet_exp(RoleAttr#p_role_attr.role_id,ExpAddValue,false) of
                {ok,NewPetInfo,NoticeType} ->
                    case NoticeType of
                        levelup ->
                            NoticeFun = 
                                {func,fun() -> 
                                              common_mod_goal:hook_pet_level_up(RoleBase#p_role_base.role_id, NewPetInfo#p_pet.level),
                                              Record = #m_pet_level_up_toc{pet_info=NewPetInfo},
                                              common_misc:unicast({role,RoleBase#p_role_base.role_id}, 
                                                                  ?DEFAULT_UNIQUE, ?PET, ?PET_LEVEL_UP, Record) end};
                        attrchange ->
                            NoticeFun = 
                                {func,fun() -> Record = #m_pet_attr_change_toc{pet_id=NewPetInfo#p_pet.pet_id,
                                                                               change_type=11,value=NewPetInfo#p_pet.exp},
                                               common_misc:unicast({role,RoleBase#p_role_base.role_id}, 
                                                                   ?DEFAULT_UNIQUE, ?PET, ?PET_ATTR_CHANGE, Record) 
                                 end};
                        _ ->
                            NoticeFun = undefined
                    end,
                    case NoticeFun of
                        undefined ->
                            NewMsgList = [Msg|MsgList];
                        _ ->
                            NewMsgList = [NoticeFun,Msg|MsgList]
                    end,
                    {NewItemInfo, RoleBase, RoleAttr,NewMsgList, [?_LANG_PET_ADD_EXP_ITEM_USE_OK|PromptList]};
                {error,Reason} ->
                    TransModule:abort(Reason)
            end 
    end.

  %%doc 使用宠物洗髓丹
reset_pet_attr(ItemInfo, _ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, _Par, _EffectID, UseNum, _State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    case mod_map_pet:reset_pet_attr(RoleAttr#p_role_attr.role_id) of
        {ok,NewPetInfo} ->
            NoticeFun = 
                {func,fun() ->
                              Record = #m_pet_info_toc{succ=true,pet_info=NewPetInfo},
                              common_misc:unicast({role,RoleAttr#p_role_attr.role_id}, ?DEFAULT_UNIQUE, ?PET, ?PET_INFO, Record)
                 end},
            {NewItemInfo, RoleBase, RoleAttr,[NoticeFun,Msg|MsgList], [?_LANG_PET_RESET_ATTR_ITEM_USE_OK|PromptList]};
        {error,Reason} ->
            TransModule:abort(Reason)
    end.

%%doc 使用宠物经验葫芦
add_pet_refining_exp(ItemInfo, _ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, _Par, _EffectID, UseNum, _State, TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    ExpAddValue = ItemInfo#p_goods.level*1000000000 + ItemInfo#p_goods.quality,
    case mod_map_pet:add_pet_exp(RoleAttr#p_role_attr.role_id,ExpAddValue,false) of
        {ok,NewPetInfo,NoticeType} ->
            case NoticeType of
                levelup ->
                    NoticeFun = 
                        {func,fun() -> 
                                      common_mod_goal:hook_pet_level_up(RoleBase#p_role_base.role_id, NewPetInfo#p_pet.level),
                                      Record = #m_pet_level_up_toc{pet_info=NewPetInfo},
                                      common_misc:unicast({role,RoleBase#p_role_base.role_id}, 
                                                          ?DEFAULT_UNIQUE, ?PET, ?PET_LEVEL_UP, Record) end};
                attrchange ->
                    NoticeFun = 
                        {func,fun() -> Record = #m_pet_attr_change_toc{pet_id=NewPetInfo#p_pet.pet_id,
                                                                       change_type=11,value=NewPetInfo#p_pet.exp},
                                       common_misc:unicast({role,RoleBase#p_role_base.role_id}, 
                                                           ?DEFAULT_UNIQUE, ?PET, ?PET_ATTR_CHANGE, Record) 
                         end};
                _ ->
                    NoticeFun = undefined
            end,
            case NoticeFun of
                undefined ->
                    NewMsgList = [Msg|MsgList];
                _ ->
                    NewMsgList = [NoticeFun,Msg|MsgList]
            end,
            Content = io_lib:format(?_LANG_PET_ADD_REFINING_EXP_ITEM_USE_OK, [ExpAddValue]),
            {NewItemInfo, RoleBase, RoleAttr,NewMsgList, [Content|PromptList]};
        {error,Reason} ->
            TransModule:abort(Reason)
    end.

%% @doc 开通VIP
vip_active(ItemInfo, _ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, _Par, _EffectID, UseNum, _State, _TransModule) ->
    #p_role_base{role_id=RoleID} = RoleBase,
    {NewItemInfo, Msg} = update_item(RoleID, ItemInfo, UseNum),
    #p_goods{typeid=TypeID} = ItemInfo,
    [VipType] = common_config_dyn:find(vip, {vip_card_typeid, TypeID}),
    {ok, ActiveType, VipInfo, VipInfoOld} = mod_vip:t_vip_active(RoleID, VipType),
    DataRecord = #m_vip_active_toc{vip_info=VipInfo, item=TypeID},
    Msg2 = {RoleID, ?VIP, ?VIP_ACTIVE, DataRecord},
    Msg3 = {func, fun() -> 
                          mod_vip:do_vip_active4(RoleBase, RoleAttr, item, ActiveType, VipType, VipInfo, VipInfoOld)
                  end},
    MsgList2 = [Msg, Msg2, Msg3|MsgList],
    {NewItemInfo, RoleBase, RoleAttr, MsgList2, PromptList}.

%% @doc 加醉酒bufff
add_drunk_buff(ItemInfo, _ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, _Par, _EffectID, UseNum, _State, _TransModule) ->
    mod_item:add_role_drunk_count(RoleAttr#p_role_attr.role_id),
    BuffID = case ItemInfo#p_goods.current_colour of
                 1 -> 10737;
                 2 -> 10738;
                 3 -> 10739;
                 4 -> 10740;
                 _ -> 0 
             end,
    case BuffID =/= 0 of
        true ->
            {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
            {ok, BuffDetail} = mod_skill_manager:get_buf_detail(BuffID),
            mod_map_role:add_buff(RoleAttr#p_role_attr.role_id,BuffDetail), 
            Prompt = lists:flatten(io_lib:format(?_LANG_ITEM_USE_WINE_OK,[common_tool:to_list(ItemInfo#p_goods.name)])),
            Msg2 = {func,fun() -> 
                                 catch hook_activity_task:done_task(RoleAttr#p_role_attr.role_id,?ACTIVITY_TASK_BONFIRE)
                    end},
            {NewItemInfo,RoleBase,RoleAttr,[Msg2,Msg|MsgList],[Prompt|PromptList]};
        false ->
            {ItemInfo,RoleBase,RoleAttr,MsgList,PromptList}
    end.

%% @doc 添加宠物栏
add_pet_room(ItemInfo, _ItemBaseInfo, RoleBase, RoleAttr, MsgList, PromptList, _Par, _EffectID, UseNum, _State, _TransModule) ->
    {NewItemInfo,Msg} = update_item(RoleAttr#p_role_attr.role_id,ItemInfo,UseNum),
    {ok,PetBagInfo} = mod_map_pet:t_add_pet_room(RoleAttr#p_role_attr.role_id),
    NoticeFun = 
        {func,fun() -> 
                      Record = #m_pet_add_bag_toc{info=PetBagInfo},
                      common_misc:unicast({role,RoleBase#p_role_base.role_id}, 
                                          ?DEFAULT_UNIQUE, ?PET, ?PET_ADD_BAG, Record)
         end},
    {NewItemInfo, RoleBase, RoleAttr,[NoticeFun,Msg|MsgList], [?_LANG_PET_ADD_PET_ROOM_ITEM_USE_OK|PromptList]}.
