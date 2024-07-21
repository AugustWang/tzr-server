%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     NPC兑换物品的功能模块
%%% @end
%%% Created : 2010-11-17
%%%-------------------------------------------------------------------
-module(mod_exchange_npc_deal).

-include("mgeem.hrl").

%% API
-export([ 
         handle/1,
         get_role_deal_num/2
         ]).

%% Macro
-define(DEAL_TYPE_ATTR,1).  %%兑换后，扣除玩家积分
-define(DEAL_TYPE_ITEM,2).  %%兑换后，扣除玩家道具

handle({Unique, Module, ?EXCHANGE_NPC_DEAL, DataIn, RoleID, PID, Line}) ->
    do_npc_deal(Unique, Module, ?EXCHANGE_NPC_DEAL, DataIn, RoleID, PID, Line);
handle({Unique, Module, ?EXCHANGE_EQUIP_INFO, DataIn, RoleID, _PID, Line}) ->
    do_equil_info(Unique, Module, ?EXCHANGE_EQUIP_INFO,RoleID, Line,DataIn);
handle(Args) ->
    ?ERROR_MSG("~w, unknow args: ~w", [?MODULE,Args]),
    ok. 

%%@doc 检查玩家兑换的历史次数
get_role_deal_num(RoleID,DealID)->
    Key = {RoleID,DealID},
    case db:dirty_read(?DB_ROLE_NPC_DEAL_P,Key) of
        []->
            0;
        [#r_role_npc_deal{total_deal_num=TotalDealNum}]->
            TotalDealNum
    end.


do_equil_info(Unique, Module,Method,RoleID,Line,DataIn)->
    #m_exchange_equip_info_tos{chagetype=TypeID,equiplist=GoodsList} = DataIn,
    Ft = fun(X,Acc) ->
                 case get_newpgoods(X,RoleID) of
                     {ok,NewItem} ->
                         [NewItem|Acc];
                     _ ->
                         Acc                 
                 end
         end,    
    case erlang:length(GoodsList)>0 of
        true ->
            NewGoodsList = lists:foldl(Ft,[],GoodsList),
            R2 = #m_exchange_equip_info_toc{chagetype = TypeID,newgoods= NewGoodsList},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R2);
        false ->
            ignroe
    end.
    
get_newpgoods(#p_equip_item{typeid=TypeID,color=Color,quality=Quality,isbind=Bind,timelimit=EndTime}=_Item,RoleID) ->
    case EndTime =/= 0 of
        true ->
            {NewStartTime,NewEndTime} = {common_tool:now(),common_tool:now()+EndTime+500};
        false ->
            {NewStartTime,NewEndTime} = {0,0}
    end,
    CreateBind = case Bind of
                    1 ->
                        true;
                    _ ->
                        false
                 end,
    CreateInfo = #r_equip_create_info{role_id=RoleID,num=1,typeid = TypeID,bind=CreateBind,start_time = NewStartTime,end_time = NewEndTime,color=Color,quality=Quality,interface_type=mission},
    case mod_equip:creat_equip(CreateInfo) of
    %%case common_bag2:creat_equip_without_expand(CreateInfo) of
        {ok,[EquipGoods|_]} ->
            {ok,EquipGoods#p_goods{id=1,bagid = 0,bagposition = 0}};
        {error,EquipError} ->
            ?ERROR_MSG("查询物品错误~w",[EquipError]),
            {error,ignore}
    end.



%%@doc 实现NPC兑换的功能
do_npc_deal(Unique, Module, Method, DataIn, RoleID, _PID, Line)->
    case catch check_npc_deal_condition(RoleID,DataIn) of
        ok->
            do_npc_deal_1(Unique, Module, Method, DataIn, RoleID, _PID, Line);
        {error,Reason}->
            ?SEND_ERR_TOC(m_exchange_npc_deal_toc,Reason)
    end.

check_npc_deal_condition(_RoleID,DataIn)->
	#m_exchange_npc_deal_tos{deal_id=DealUniqueID} = DataIn,
	case common_config_dyn:find(npc_deal,DealUniqueID) of
		[#r_npc_deal{limit_deal_maps=MapIdList}] ->
			case MapIdList of
				undefined->
					next;
				[]->
					next;
				_ ->
					MapID = mgeem_map:get_mapid(),
					case lists:member(MapID, MapIdList) of
						true->
							next;
						_ ->
							throw({error,?_LANG_EXCHANGE_NPC_DEAL_LIMIT_MAP})
					end
			end;
		_ ->
			throw({error,?_LANG_EXCHANGE_NPC_DEAL_INVALID_DEAL})
	end,
	ok.
    
do_npc_deal_1(Unique, Module, Method, DataIn, RoleID, _PID, Line)->    
    #m_exchange_npc_deal_tos{deal_id=DealUniqueID,deal_amount=Amount} = DataIn,
    [#r_npc_deal{deduct_item_type=DeductItemTypeID,deduct_item_num=DeductItemAmount,
                 deal_type=DealType,limit_deal_times=LimitTimes}=ExchangeInfo] = common_config_dyn:find(npc_deal,DealUniqueID),
    case catch check_exchange_num(RoleID,DealUniqueID,LimitTimes,Amount) of
        ok ->  
            case DealType of
                ?DEAL_TYPE_ATTR->
                    CheckResult = check_attr_exchange(RoleID,DeductItemTypeID,DeductItemAmount,Amount);
                ?DEAL_TYPE_ITEM->
                    CheckResult = check_goods_exchange(RoleID,DeductItemTypeID,DeductItemAmount,Amount)
            end,
            case CheckResult of
                ok->
                    do_npc_deal_2(Unique, Module, Method, RoleID, Line, ExchangeInfo,Amount);
                {error,ErrorMsg} ->
                    ?SEND_ERR_TOC(m_exchange_npc_deal_toc,ErrorMsg)
            end;
        {error,Reason1} ->
            ?SEND_ERR_TOC(m_exchange_npc_deal_toc,Reason1)
    end.



check_attr_exchange(RoleID,TypeID,DeductAmount,Amount) when DeductAmount>0, Amount>0 ->
    case TypeID of
        arena_score ->
            ErrReason= ?_LANG_EXCHANGE_NPC_DEAL_NO_ARENA_SCORE,
            Value = mod_arena:get_arena_total_score(RoleID);
        collect_score ->
            ErrReason= ?_LANG_EXCHANGE_NPC_DEAL_NO_COLLECT_SCORE,
            Value = mod_family_collect:get_prize_info(RoleID);
        family_conb ->
            ErrReason= ?_LANG_EXCHANGE_NPC_DEAL_NO_FML_GONGXIAN,
            {ok, #p_role_attr{family_contribute=Value}}  = mod_map_role:get_role_attr(RoleID);
        zgv ->
            ErrReason= ?_LANG_EXCHANGE_NPC_DEAL_NO_ZHANGONG,
            {ok, #p_role_attr{gongxun=Value}}  = mod_map_role:get_role_attr(RoleID)
    end,
    
    AllDealNum = (DeductAmount*Amount),
    if
        Value>=AllDealNum->
            ok;
        true->
            {error,ErrReason}
    end.

check_goods_exchange(RoleID,ItemID,DeductAmount,Amount) ->
    DeductAmountAll = DeductAmount*Amount,
    case mod_bag:check_inbag_by_typeid(RoleID,ItemID) of
        {ok,FoundGoodsList} ->
            FoundItemAmount = lists:foldl(
                                fun(E,AccIn)-> 
                                        #p_goods{current_num=Num}=E,
                                        AccIn + Num
                                end, 0, FoundGoodsList),
            case (FoundItemAmount<DeductAmountAll) of
                true->
                    {error,?_LANG_EXCHANGE_NPC_DEAL_DEDUCT_ITEM_NOT_ENOUGH};
                _->
                    ok
            end;
        _ ->
            {error,?_LANG_EXCHANGE_NPC_DEAL_DEDUCT_ITEM_NOT_EXISTS}
    end.    


do_npc_deal_2(Unique, Module, Method, RoleID, Line, ExchangeInfo,DealNum)->
    #r_npc_deal{deal_unique_id=DealUniqueID,deduct_item_type=DeductItemType,deduct_item_num=DeductItemAmount,
                         award_item_list=AwdItemList,award_attr_list=AwardAttrList,
                    deal_type=DealType,limit_deal_times=LimitDealTimes}=ExchangeInfo,
    TransModule = case DeductItemType of
                      arena_score-> db;
                      _ -> common_transaction
                  end,
    case TransModule:transaction( fun() -> t_do_npc_deal(RoleID,ExchangeInfo,DealNum) end) of
        {atomic, {ok,AddGoodsList,FuncList}} ->
            case LimitDealTimes>0 of
                true ->
                    update_role_deal_num(RoleID,DealUniqueID,DealNum);
                _ ->
                    ignore
            end,
            %%奖励道具日志
            lists:foreach(
              fun(E)-> 
                      #r_simple_prop{prop_id=PropID,prop_num=PropNum} = E,
                      common_item_logger:log(RoleID, PropID,PropNum,true,?LOG_ITEM_TYPE_GAIN_NPC_EXCHANGE_DEAL)
              end,AwdItemList),
            %%扣除道具日志
            case DealType=:=2 of
                true ->
                    common_item_logger:log(RoleID, DeductItemType,DeductItemAmount*DealNum,undefined,?LOG_ITEM_TYPE_LOST_NPC_EXCHANGE_DEAL);
                false ->
                    ignore
            end,
            %%执行事务成功后的方法
            case FuncList of
                []->
                    ignore;
                undefined->
                    ignore;
                {func,Func}->
                    Func()
            end,
            %%属性奖励都在事务后处理
            do_award_attr_list(RoleID,AwardAttrList,DealNum),
            notify_role_goods(update,RoleID,AddGoodsList),
            
            R2 = #m_exchange_npc_deal_toc{succ=true},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R2),
            
            notify_role_tip(RoleID,ExchangeInfo,AddGoodsList,DealNum),
            common_hook_achievement:hook({mod_exchange,{npc_deal,RoleID,ExchangeInfo}});
        {aborted, {bag_error,not_enough_pos}} ->
            do_npc_change_fail(RoleID,ExchangeInfo,DealNum),
            ?SEND_ERR_TOC(m_exchange_npc_deal_toc,?_LANG_EXCHANGE_NPC_DEAL_BAG_FULL);
        {aborted, {throw, {bag_error,not_enough_pos}}} ->
            do_npc_change_fail(RoleID,ExchangeInfo,DealNum),
            ?SEND_ERR_TOC(m_exchange_npc_deal_toc,?_LANG_EXCHANGE_NPC_DEAL_BAG_FULL);
        {aborted, {throw, {bag_error, Reason}}} ->
            do_npc_change_fail(RoleID,ExchangeInfo,DealNum),
            ?ERROR_MSG("do_npc_deal_2，Reason=~w",[Reason]),
            ?SEND_ERR_TOC(m_exchange_npc_deal_toc,?_LANG_BAG_ERROR);
        {aborted, Error} ->
            do_npc_change_fail(RoleID,ExchangeInfo,DealNum),
            ?ERROR_MSG("do_npc_deal_2，Error=~w",[Error]),
            ?SEND_ERR_TOC(m_exchange_npc_deal_toc,?_LANG_SYSTEM_ERROR)
    end.

do_npc_change_fail(RoleID,ExchangeInfo,AwardAmount) ->
    #r_npc_deal{deduct_item_type=DeductItemType,deduct_item_num=DeductNum}=ExchangeInfo,
    DeductItemAmount = DeductNum*AwardAmount,
    case DeductItemType=:=family_conb orelse DeductItemType=:= collect_score orelse DeductItemType=:=pet_arena_score of
        true ->       
            t_decrease_attr(DeductItemType,RoleID,-DeductItemAmount);
        false ->
            ignore
    end.
%%@doc 处理NPC兑换的逻辑
t_do_npc_deal(RoleID,ExchangeInfo,AwardAmount)->
    #r_npc_deal{deduct_item_type=DeductItemType,deduct_item_num=DeductNum,
                award_item_list=AwdItemList,deal_type=DealType}=ExchangeInfo,
    DeductItemAmount = DeductNum*AwardAmount,
    case DealType =:= 1 of
        true ->
            {ok,FuncList} = t_decrease_attr(DeductItemType,RoleID,DeductItemAmount);
        _ ->
            {ok,UpdateGoodsList,DeleteGoodsList} = mod_bag:decrease_goods_by_typeid(RoleID,DeductItemType,DeductItemAmount),
            FuncList ={func,
                       fun()->
                               %%发送消息序列是先删除再新增
                               notify_role_goods(del,RoleID,DeleteGoodsList),
                               notify_role_goods(update,RoleID,UpdateGoodsList)
                       end}
    end,          
    {ok,AddGoodsList} = t_add_item(RoleID,[],AwdItemList,AwardAmount),
    {ok,AddGoodsList,FuncList}.

%% 兑换成功后，给予属性/积分等的奖励
do_award_attr_list(RoleID,AwardAttrList,Amount) ->
    #p_map_role{family_id = FamilyId} =  mod_map_actor:get_actor_mapinfo(RoleID,role),
    
    case AwardAttrList of
        []->
            ignore;
        _ ->
            lists:foreach(
              fun({AwardType,AddMount}) ->
                      case AwardType of
                          exp -> %% 奖励人物经验
                              ?TRY_CATCH( common_misc:add_exp_unicast(RoleID,AddMount*Amount) );
                          family_money -> %% 宗族资金
                              ?TRY_CATCH( common_family:info(FamilyId, {add_money_when_npc_exchange, AddMount*Amount}) );
                          family_contribution -> %% 宗族贡献度
                              ?TRY_CATCH( common_family:info(FamilyId, {add_contribution, RoleID, AddMount*Amount}) )
                      end
              end,AwardAttrList)
    end.


%% ====================================================================
%% Internal functions
%% ====================================================================

%%@doc 给予兑换后的道具
t_add_item(_RoleID,GoodsList,[],_AwardAmount)->
    {ok,GoodsList};
t_add_item(RoleID,GoodsList,[H|T],AwardAmount)->
    #r_simple_prop{prop_id=PropId,prop_type=PropType,prop_num=AwdNum,quality=Quality,color=Color} = H,
    Num = AwdNum*AwardAmount,
    CreateInfo = #r_goods_create_info{bind=true,type=PropType, type_id=PropId, start_time=0, end_time=0, 
                                      num=Num, color=Color,quality=Quality,
                                      punch_num=0,interface_type=present},
    {ok,NewGoodsList} = mod_bag:create_goods(RoleID,CreateInfo),
    t_add_item(RoleID, lists:concat([NewGoodsList,GoodsList]) ,T,AwardAmount).


%%@doc 扣除玩家的对应积分属性
t_decrease_attr(pet_arena_score,RoleID,DeductNum) ->
    global:send(mgeew_pet_arena_server, {add_area_score, RoleID, -DeductNum}),
    {ok,[]};
t_decrease_attr(family_conb,RoleID,DeductNum) ->
    #p_map_role{family_id = FamilyId} =  mod_map_actor:get_actor_mapinfo(RoleID,role),
    ?TRY_CATCH( common_family:info(FamilyId, {add_contribution, RoleID, -DeductNum}) ),
    {ok,[]};
t_decrease_attr(collect_score,RoleID,DeductNum) ->
    mod_family_collect:exchange_byscore(RoleID,DeductNum),
    {ok,[]};
t_decrease_attr(zgv,RoleID,DeductNum) ->
    {ok, #p_role_attr{gongxun=G}=RoleAttr} = mod_map_role:get_role_attr(RoleID),
    NewValue = G-DeductNum,
    RoleAttr2 = RoleAttr#p_role_attr{gongxun=NewValue},
    mod_map_role:set_role_attr(RoleID, RoleAttr2),
    Func = {func,
            fun()-> 
                    RR = #m_role2_attr_change_toc{roleid=RoleID,changes=[#p_role_attr_change{change_type=?ROLE_GONGXUN_CHANGE,new_value=NewValue}]},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, RR),  
                    
                    Notice = common_misc:format_lang(?_LANG_EXCHANGE_NPC_DEAL_LOST_ZHANGONG,[DeductNum]),
                    common_broadcast:bc_send_msg_role(RoleID, ?BC_MSG_TYPE_SYSTEM, lists:flatten(Notice))
            end},
    {ok,Func};
t_decrease_attr(_,_,_) ->
    {ok,[]}.
   

notify_role_goods(_Type,_RoleID,[])->
    ignore;
notify_role_goods(del,RoleID,GoodsList)->
    common_misc:del_goods_notify({role, RoleID}, GoodsList);
notify_role_goods(_,RoleID,GoodsList)->
    common_misc:update_goods_notify({role, RoleID}, GoodsList).


%%发送兑换成功的通知信息
notify_role_tip(RoleID,ExchangeInfo,AddGoodsList,DealNum) ->
    #r_npc_deal{award_item_list=AwdItemList,award_attr_list = AwardAttrList}=ExchangeInfo,
    AwardGoodsDesc = 
        case AwdItemList of
            []->
                "";
            _ ->
                notify_role_tip_2(AwdItemList,AddGoodsList,DealNum)
        end,
    AwardOtherDesc = 
        case AwardAttrList of
            []->
                "";
            _ ->
                notify_role_tip_3(AwardAttrList,DealNum)
        end,
    BcMessage = lists:concat([AwardGoodsDesc,AwardOtherDesc]),
    if BcMessage =/= "" ->
            catch common_broadcast:bc_send_msg_role(
              RoleID,?BC_MSG_TYPE_SYSTEM,common_misc:format_lang(?_LANG_EXCHANGE_NPC_DEAL_SUCC_BC,[BcMessage]));
       true ->
            ok
    end.
    
notify_role_tip_2(AwdItemList,AddGoodsList,DealNum)->
    lists:foldl(
      fun(E,AccIn) ->
              #r_simple_prop{prop_id=PropId,prop_num=Num} = E,
              case lists:keyfind(PropId,#p_goods.typeid,AddGoodsList) of
                  false ->
                      AccIn;
                  Goods ->
                      lists:concat([AccIn," ",
                                    common_goods:get_notify_goods_name(Goods#p_goods{current_num = Num*DealNum})])
              end
      end,"",AwdItemList).

notify_role_tip_3(AwardAttrList,DealNum)->
    case AwardAttrList of
        []->
            "";
        _ ->
            lists:foldl(
              fun({OtherType,AddOtherMount},AccIn) ->
                      case OtherType of
                          exp -> %% 奖励人物经验
                              lists:concat([AccIn," ",AddOtherMount*DealNum,?_LANG_NPC_DEAL_TIP_EXP]);
                          family_money -> %% 宗族资金
                              lists:concat([AccIn," ",AddOtherMount*DealNum,?_LANG_NPC_DEAL_TIP_FAMILY_MONEY]);
                          family_contribution -> %% 宗族贡献度
                              lists:concat([AccIn," ",AddOtherMount*DealNum,?_LANG_NPC_DEAL_TIP_FAMILY_CONB]);
                          family_active_points -> %% 宗族繁荣度
                              lists:concat([AccIn," ",AddOtherMount*DealNum,?_LANG_NPC_DEAL_TIP_FAMILY_ACTPOINT]);
                          _ ->
                              AccIn
                      end
              end,"",AwardAttrList)
    end.
    
%%更新玩家的指定交易次数
update_role_deal_num(RoleID,DealID,ThisNum) when ThisNum>0->
    Key = {RoleID,DealID},
    Now = common_tool:now(),
    case db:dirty_read(?DB_ROLE_NPC_DEAL_P,Key) of
        []->
            R2 = #r_role_npc_deal{key=Key,total_deal_num=ThisNum,last_deal_num=ThisNum,last_deal_time=Now},
            db:dirty_write(?DB_ROLE_NPC_DEAL_P,R2);
        [#r_role_npc_deal{total_deal_num=TotalNum}=R1]->
            R2 = R1#r_role_npc_deal{total_deal_num=ThisNum+TotalNum,last_deal_num=ThisNum,last_deal_time=Now},
            db:dirty_write(?DB_ROLE_NPC_DEAL_P,R2)
    end.

%%检查玩家的交易历史次数
check_exchange_num(_RoleID,_,0,_) ->
    ok;
check_exchange_num(RoleID,DealID,LimitTimes,Amount)->
    case Amount>LimitTimes of
        true ->
            Reason = common_misc:format_lang(?_LANG_EXCHANGE_NPC_DEAL_LIMIT_NUM,[LimitTimes]),
            throw({error,Reason});
        false ->
            assert_role_deal_limit_num(RoleID,DealID,LimitTimes,Amount)               
    end,
    ok.


assert_role_deal_limit_num(RoleID,DealID,LimitTimes,Amount)->
    TotalDealNum = get_role_deal_num(RoleID,DealID),
    if
        TotalDealNum=:=0 ->
            ok;
        TotalDealNum+Amount>LimitTimes->
            Reason = common_misc:format_lang(?_LANG_EXCHANGE_NPC_DEAL_LIMIT_NUM,[LimitTimes]),
            throw({error,Reason});
        true->
            ok
    end.

