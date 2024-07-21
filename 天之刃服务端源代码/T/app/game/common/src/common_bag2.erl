%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     背包操作的外部接口
%%% @end
%%% Created : 2010-12-1
%%%-------------------------------------------------------------------
-module(common_bag2).


%% API
-export([
         get_bag_goods_list/2,
         %% 登录时获取玩家的背包物品信息
         %% 返回[p_bag_content] 或者 []
         get_role_all_bags/1,
         create_item/1,
         creat_stone/1,
         creat_equip_without_expand/1,
         init_role_bag_info/1,
         baglist_cmp/2,
         is_depository_bag/1
        ]).
-export([
         t_new_role_bag/1,
         t_new_role_bag_basic/1
         ]).

-export([
         on_transaction_begin/0,
         on_transaction_commit/0,
         on_transaction_rollback/0
        ]).

-define(ROLE_BAG_TRANSACTION,role_bag_transaction).
-define(ROLE_BAG_LIST_BK,role_bag_list_bk).
-define(ROLE_BAG_BK,role_bag_bk).
-define(ROLE_DEPOSITORY_LIST,role_depository_list).    %%角色仓库的字典Key
-define(ROLE_BAG_LIST,role_bag_list).    %%角色背包概况列表的字典Key
-define(ROLE_BAG,role_bag).    %%角色背包的字典Key

-define(UNDEFINED,undefined).

-define(CAN_OVERLAP,1).
-define(NOT_OVERLAP,2).
-define(MAX_OVER_LAP,50).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common.hrl").
-include("common_server.hrl").

%% ====================================================================
%% API Functions
%% ====================================================================

on_transaction_begin() ->
    case get(?ROLE_BAG_TRANSACTION) of
        ?UNDEFINED ->
            put(?ROLE_BAG_TRANSACTION,true);
        _ ->
            do_delete_bag_transaction_info(),
            ?ERROR_MSG("transaction error,reason=nesting_transaction,strace=~w",[erlang:get_stacktrace()]),
            throw(nesting_transaction)
    end.


on_transaction_commit() ->
    do_delete_bag_transaction_info().


on_transaction_rollback() ->
    erase(?ROLE_BAG_TRANSACTION),
    case get(bag_locked_role_idlist) of
        ?UNDEFINED ->
            ignore;
        RoleIDList ->
            erase(bag_locked_role_idlist),
            [ begin do_rollback_role_bag_info(RoleID),do_clear_bag_backup_info(RoleID) end
              ||RoleID<-RoleIDList ]
    end.


%%@doc 创建道具
%%@spec create_item(CreateInfo::#r_item_create_info()) -> {ok,GoodsList} | {error,typeid_not_found}
create_item(CreateInfo)when is_record(CreateInfo,r_item_create_info) ->
    #r_item_create_info{role_id=RoleID,bag_id=BagID,bagposition=BagPos,
                        num=Num,typeid=TypeID,bind=Bind,color=Color,
                        start_time=StartTime,end_time=EndTime} = CreateInfo,
    case common_config_dyn:find_item(TypeID) of
        [] ->
            {error,typeid_not_found};
        [BaseInfo] ->
            #p_item_base_info{sell_type=SellType,
                              sell_price=SellPrice,
                              itemname=ItemName,
                              usenum=UseNum,
                              is_overlap=IsOverlap,
                              effects=Effects,
                              colour=InitColour}=BaseInfo,
            {NewStartTime,NewEndTime}=
                if StartTime =:= 0 andalso EndTime =/= 0 ->
                       {common_tool:now(),common_tool:now()+EndTime};
                   true ->
                       {StartTime,EndTime}
                end,    
            Endurance =
                if erlang:is_list(Effects) ->
                       Effect = 
                           case lists:keyfind(15,2,Effects) of
                               false ->
                                   lists:keyfind(17,2,Effects);
                               EffectTmp ->
                                   EffectTmp
                           end,
                       if Effect =:= false ->
                              0;
                          true ->
                              ConfigID = list_to_integer(Effect#p_item_effect.parameter),
                              [Config] = common_config_dyn:find(bighpmp,ConfigID),
                              Config#r_big_hp_mp.total
                       end;
                   true ->
                       0
                end,
            NewColour = case Color of 0 -> InitColour; Color -> Color end,
            GoodsTmp= #p_goods{type=?TYPE_ITEM, typeid = TypeID,roleid = RoleID , 
                               bagid = BagID, bagposition = BagPos ,bind = Bind , 
                               end_time = NewEndTime,current_colour =NewColour,sell_type = SellType, 
                               sell_price = SellPrice,start_time=NewStartTime,
                               name=ItemName, current_endurance=Endurance,endurance=Endurance},
            GoodsList = case IsOverlap =:= ?CAN_OVERLAP andalso UseNum =:= 1 of
                            true ->
                                case Num rem ?MAX_OVER_LAP of
                                    0 -> 
                                        lists:duplicate(Num div ?MAX_OVER_LAP,
                                                        GoodsTmp#p_goods{current_num=?MAX_OVER_LAP});
                                    R -> [GoodsTmp#p_goods{current_num=R}|
                                                              lists:duplicate(Num div ?MAX_OVER_LAP,
                                                                              GoodsTmp#p_goods{current_num=?MAX_OVER_LAP})]
                                end;
                            false ->
                                lists:duplicate(Num,GoodsTmp#p_goods{current_num=1})
                        end,
            {ok,GoodsList}
    end.

%%@doc 创建宝石
%%@spec create_stone/1 -> {ok,GoodsList} | {error,typeid_not_found}
creat_stone(CreatInfo)when erlang:is_record(CreatInfo,r_stone_create_info) ->
    #r_stone_create_info{role_id=RoleID,bag_id=BagID,bagposition=BagPos,
                         num=Num,typeid=TypeID,bind=Bind,start_time=StartTime,
                         end_time=EndTime}=CreatInfo,
    case common_config_dyn:find_stone(TypeID) of
        [] ->
            {error,typeid_not_found};
        [BaseInfo] ->
            {NewStartTime,NewEndTime}=
                if StartTime =:= 0 andalso EndTime =/= 0 ->
                        {common_tool:now(),common_tool:now()+EndTime};
                   true ->
                        {StartTime,EndTime}
                end, 
            #p_stone_base_info{sell_type=SellType,
                               sell_price=SellPrice,
                               stonename=StoneName,
                               colour=InitColour,
                               level=Level}=BaseInfo,
            GoodsTmp = #p_goods{type = ?TYPE_STONE ,typeid = TypeID,roleid = RoleID ,
                                bagposition = BagPos ,bind = Bind, current_colour =InitColour,level = Level,bagid = BagID,
                                start_time=NewStartTime,end_time=NewEndTime,
                                add_property = BaseInfo#p_stone_base_info.level_prop,
                                sell_type = SellType, sell_price = SellPrice,name=StoneName},
            GoodsList = 
                case Num rem ?MAX_OVER_LAP of
                    0 -> 
                        lists:duplicate(Num div ?MAX_OVER_LAP,
                                        GoodsTmp#p_goods{current_num=?MAX_OVER_LAP});
                    R ->
                        [GoodsTmp#p_goods{current_num=R}|
                         lists:duplicate(Num div ?MAX_OVER_LAP,GoodsTmp#p_goods{current_num=?MAX_OVER_LAP})]
                end,
            {ok,GoodsList}
    end.

%%@doc 创建装备 （没有进行装备扩展属性的设置）
%%@spec creat_equip_without_expand/1 -> {ok,GoodsList} | {error,typeid_not_found}
creat_equip_without_expand(CreateInfo) when is_record(CreateInfo,r_equip_create_info) ->
    #r_equip_create_info{role_id=RoleID,bag_id=BagID,bagposition=BagPos,num=Num,
                         typeid=TypeID,bind=Bind,start_time=StartTime,end_time=EndTime,
                         color=Color,quality=Quality,punch_num = PunchNum,sub_quality = SubQuality,
                         property=Pro,rate=Rate,result=Result,result_list=ResultList
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
                               equipname=Name,endurance=Endurance}=BaseInfo,
            NewProp = if Pro =:= undefined -> Prop;true -> Pro end,
            NewResultList = if ResultList =:= undefined -> [];true -> ResultList end, 
            GoodsTmp = #p_goods{typeid = TypeID,roleid = RoleID ,bagposition = BagPos ,bind = Bind , 
                                add_property = NewProp,start_time = NewStartTime,end_time = NewEndTime, 
                                current_colour = Color,quality = Quality,current_endurance = Endurance ,
                                bagid = BagID, type = ?TYPE_EQUIP,sell_type = SellType,stones=[], 
                                sell_price = SellPrice,name = Name,loadposition = 0,punch_num = PunchNum, endurance = Endurance,
                                level = (BaseInfo#p_equip_base_info.requirement)#p_use_requirement.min_level,
                                reinforce_rate=Rate,reinforce_result=Result,reinforce_result_list=NewResultList,
                                sub_quality = SubQuality},
            NewGoodsTmp = GoodsTmp,
            {ok, lists:duplicate(Num,NewGoodsTmp#p_goods{current_num=1})};
        [] ->
            {error,typeid_not_found}
    end.




%%@doc 事务内初始化Role的 DB_ROLE_BAG表
t_new_role_bag(RoleID) ->
    BagIDList = [1,5,6],
    [ do_t_new_role_bag(RoleID,BagID)||BagID<- BagIDList].

%%@doc 事务内初始化Role的DB_ROLE_BAG_BASIC表
t_new_role_bag_basic(RoleID)->
    %%  [{bag_id,bag_type_id,due_time,roles,columns,grid_number}]
    BasicList =[{1,0,0,5,8,40},    %%第一个背包
                {5,0,0,3,3,9},    %%天工炉
                {6,0,0,6,7,42}     %%仓库
               ],
    Record = #r_role_bag_basic{role_id=RoleID,bag_basic_list=BasicList},
    db:write(?DB_ROLE_BAG_BASIC_P, Record, write).

%%@doc 异步方式，获取玩家的全部背包信息
%%@param RoleID::integer()  角色ID
%%@return   
get_bag_goods_list(RoleID,ReplyMsgTag)-> 
    async_call_map_process(RoleID,{get_bag_goods_list,[RoleID],ReplyMsgTag}).


%%
%% Local Functions
%%

do_t_new_role_bag(RoleID,BagID)->
    Record = #r_role_bag{
                         role_bag_key = {RoleID,BagID},
                         bag_goods = [] },
    db:write(?DB_ROLE_BAG_P, Record, write).

%%@doc 异步方式地调用Map进程，并返回指定的CallbackInfo消息类型
%%  TIP:调用者和接收者必须是同一个gen_server
async_call_map_process(RoleID,{Func,Args,ReplyMsgTag})->
    ReceiverPID = self(),
    common_misc:send_to_rolemap(RoleID, {mod_bag_handler,{ReceiverPID,Func,Args,ReplyMsgTag}}).



%%@doc 背包操作失败的时候直接回滚回备份的背包数据
do_rollback_role_bag_info(RoleID) ->
    case  get({?ROLE_BAG_LIST_BK,RoleID}) of
        ?UNDEFINED ->
            ignore;
        BakList ->
            put({role_bag_list,RoleID},BakList),
            lists:foreach(
              fun({BagID,_BagBasic}) ->
                      BakRoleBag = get({?ROLE_BAG_BK,RoleID,BagID}),
                      put({role_bag,RoleID,BagID},BakRoleBag)
              end,BakList)
    end.


do_delete_bag_transaction_info() ->
    erase(?ROLE_BAG_TRANSACTION),
    case get(bag_locked_role_idlist) of
        ?UNDEFINED ->
            ignore;
        RoleIDList ->
            erase(bag_locked_role_idlist),
            [ do_clear_bag_backup_info(RoleID) || RoleID<-RoleIDList ]
    end.


do_clear_bag_backup_info(RoleID) ->
    case  get({?ROLE_BAG_LIST_BK,RoleID}) of
        ?UNDEFINED ->
            ignore;
        BakList ->
            erase({?ROLE_BAG_LIST_BK,RoleID}),
            lists:foreach(
              fun({BagID,_BagBasic}) -> erase({?ROLE_BAG_BK,RoleID,BagID}) 
              end, BakList)
    end.



%% 登录时获取玩家的背包物品信息
%% 从DB_ROLE_BAG_BASIC表中查询背包信息
%% 从DB_ROLE_BAG 表中查询物品信息r_role_bag_basic
%% 参数
%% RoleId 玩家id
%% 返回[p_bag_content] 或者 []
get_role_all_bags(RoleId) ->
    BagIds = [1,2,3,4],
    case db:dirty_read(?DB_ROLE_BAG_BASIC_P, RoleId) of
        {'EXIT', Reason} ->
            ?ERROR_MSG("~ts,Reason=~w", ["登录时脏读玩家背包信息出错",Reason]),
            [];
        [] ->
            ?INFO_MSG("~ts,RoleId=~w", ["登录时脏读玩家背包信息为空",RoleId]),
            [];
        [BagInfoRecord] ->
            #r_role_bag_basic{bag_basic_list = BagInfoListT} = BagInfoRecord,
            lists:foldl(
              fun({BagId,BagTypeId,DueTime,Rows,Columns,GridNumber},Acc) ->
                      case lists:member(BagId,BagIds) of
                          true ->
                              BagContent = get_role_all_bags2(RoleId,BagId,BagTypeId,DueTime,Rows,Columns,GridNumber),
                              [BagContent|Acc];
                          false ->
                              Acc
                      end
              end,[],BagInfoListT)
    end.
%% 返回p_bag_content
get_role_all_bags2(RoleId,BagId,BagTypeId,_DueTime,Rows,Columns,GridNumber) ->
    RoleBagKey = {RoleId,BagId},
    GoodsList = 
        case db:dirty_read(?DB_ROLE_BAG_P, RoleBagKey) of
            {'EXIT', Reason} ->
                ?ERROR_MSG("~ts,RoleId=~w,BagId=~w,Reason=~w", 
                           ["登录时脏读玩家背包物品信息出错",RoleId,BagId,Reason]),
                [];
            [] ->
                ?INFO_MSG("~ts,RoleId=~w,BagId=~w", 
                          ["登录时脏读玩家背包物品信息为空",RoleId,BagId]),
                [];
            [RoleBagRecord] ->
                #r_role_bag{bag_goods = GoodsListT} = RoleBagRecord,
                GoodsListT
        end,
    #p_bag_content{bag_id=BagId, 
                   goods= GoodsList,
                   rows=Rows,
                   columns= Columns,
                   grid_number = GridNumber,
                   typeid=BagTypeId}.

baglist_cmp({BagID1,_},{BagID2,_}) ->
    BagID1 < BagID2.

%%@doc 判断背包ID是否为仓库的背包
is_depository_bag(BagID)->
    BagID > 5.

%%@doc  初始化玩家背包信息,第一次进入地图时使用
%%@param RoleID::integer()  角色ID
%%@return   
init_role_bag_info(RoleID) when is_integer(RoleID) ->
    Fun = fun()->
                  case db:read(?DB_ROLE_BAG_BASIC_P,RoleID,read) of
                      [] ->
                          throw({bag_error,no_bag_basic_data});
                      [ #r_role_bag_basic{bag_basic_list=BagBasicList} ]->
                          {BagList,DepositList} = lists:foldr(
                                                    fun(BagBasic,{Acc1,Acc2}) ->
                                                            BagID = element(1,BagBasic),
                                                            %%玩家默认背包1，两个扩展背包2 3 天工炉5  ，其他的都是银行仓库，不放入背包列表中
                                                            case is_depository_bag(BagID) of
                                                                false ->
                                                                    %% 扩展背包不需要处理
                                                                    case BagID > 1 andalso BagID < 5 of
                                                                        true ->
                                                                            {Acc1,Acc2};
                                                                        _ ->
                                                                            {[{BagID,BagBasic}|Acc1],Acc2}
                                                                    end;
                                                                true ->
                                                                    {Acc1,[{BagID,BagBasic}|Acc2]}
                                                            end
                                                    end,{[], []},BagBasicList),
                          
                          BagInfoList = [{{?ROLE_BAG_LIST,RoleID},lists:sort(fun(E1,E2) -> baglist_cmp(E1,E2) end,BagList)}],
                          BagInfoList2 = [{{?ROLE_DEPOSITORY_LIST,RoleID},lists:sort(fun(E1,E2) -> baglist_cmp(E1,E2) end,DepositList)}|BagInfoList],
                          {BagInfoList3,GoodsIDList} = lists:foldl(
                            fun( {BagID,_BagTypeID,OutUseTime,_Rows,_Clowns,GridNumber},{Acc,AccID}) ->
                                    case db:read(?DB_ROLE_BAG_P,{RoleID,BagID},read) of
                                        [] ->
                                            throw({bag_error,no_bagid_data});
                                        [BagInfo] ->
                                            %%Content = Rows * Clowns,
                                            Content = GridNumber,
                                            GoodsList = BagInfo#r_role_bag.bag_goods,
                                            {UsedPositionList,AccID2} = get_used_position_list(GoodsList,AccID),
                                            MaxID = get_role_bag_max_goodsid(GoodsList),
                                            case get({role_bag_max_goodsid,RoleID}) of
                                                undefined ->
                                                    put({role_bag_max_goodsid,RoleID},MaxID);
                                                MaxID2 ->
                                                    case MaxID > MaxID2 of
                                                        true ->
                                                            put({role_bag_max_goodsid,RoleID},MaxID);
                                                        false ->
                                                            ignore 
                                                    end
                                            end,
                                            {[{{?ROLE_BAG,RoleID,BagID},{Content,OutUseTime,UsedPositionList,GoodsList,false}}|Acc],AccID2}
                                    end
                            end,{BagInfoList2,[]},[BagBasicT || BagBasicT <- BagBasicList,
                                                                element(1,BagBasicT) =/= 2,
                                                                element(1,BagBasicT) =/= 3,
                                                                element(1,BagBasicT) =/= 4]),
                          update_role_max_goodsid_by_equips_and_stall(RoleID,GoodsIDList),
                          MaxID3 = get({role_bag_max_goodsid,RoleID}),
                          erase({role_bag_max_goodsid,RoleID}),
                          [{{role_bag_max_goodsid,RoleID},MaxID3}|BagInfoList3]
                  end
          end,
    case db:transaction(Fun) of
        {atomic,Info} ->
            {ok,Info};
        {aborted,Reason} ->
            ?ERROR_MSG("init role bag data error when first enter,roleid=~w,reason=~w",[RoleID,Reason]),
            {error,Reason}
    end.

get_used_position_list(GoodsList,IDList) ->
    {PosList,NewIDList} = lists:foldl(
                            fun(GoodsInfo,{Acc,Acc2}) ->
                                    Pos = GoodsInfo#p_goods.bagposition,
                                    ID = GoodsInfo#p_goods.id,
                                    case lists:member(ID,Acc2) of
                                        true ->
                                            db:abort(bag_data_error);
                                        false ->
                                            {[Pos|Acc],[ID|Acc2]}
                                    end
                            end,{[],IDList},GoodsList),
    {lists:sort(PosList),NewIDList}.

get_role_bag_max_goodsid([]) ->
    0;
get_role_bag_max_goodsid(GoodsList) ->
    lists:foldl(
      fun(GoodsInfo,Acc) -> 
              case GoodsInfo#p_goods.id > Acc of
                  true ->
                      GoodsInfo#p_goods.id;
                  false ->
                      Acc
              end
      end,0,GoodsList).

update_role_max_goodsid_by_equips_and_stall(RoleID,IDList) ->
    [RoleAttr] = db:read(?DB_ROLE_ATTR,RoleID,read),
    {MaxID,IDList2} = case RoleAttr#p_role_attr.equips of
                undefined ->
                    0;
                Equips ->
                    lists:foldr(
                      fun(Equip,{Acc,AccID}) ->
                              case lists:member(Equip#p_goods.id,AccID) of
                                  true ->
                                       ?ERROR_MSG("装备中有物品数据异常,RoleID=~w,Equip=~w",[RoleID,Equip]),
                                       db:abort(bag_data_error);
                                  false ->
                                      ignore
                              end,
                              case Equip#p_goods.id > Acc of
                                  true ->
                                      {Equip#p_goods.id,[Equip#p_goods.id|AccID]};
                                  false ->
                                       {Acc,[Equip#p_goods.id|AccID]}
                              end
                      end,{0,IDList},Equips)
            end,
    Stalls = db:match_object(?DB_STALL_GOODS,#r_stall_goods{_='_', role_id=RoleID},read),
      {MaxID2,_IDList3} = lists:foldr(
               fun(Stall,{Acc2,AccID2}) ->
                       GoodsID = (Stall#r_stall_goods.goods_detail)#p_goods.id,
                         case lists:member(GoodsID,AccID2) of
                                  true ->
                                       ?ERROR_MSG("摊位中有物品数据异常,RoleID=~w,Stall=~w",[RoleID,Stall]),
                                       db:abort(bag_data_error);
                                  false ->
                                      ignore
                              end,
                       case GoodsID > Acc2 of
                           true ->
                               {GoodsID,[GoodsID|AccID2]};
                           false ->
                               {Acc2,[GoodsID|AccID2]}
                       end
               end,{MaxID,IDList2},Stalls),
    case get({role_bag_max_goodsid,RoleID}) of
        undefined ->
            put({role_bag_max_goodsid,RoleID},MaxID2);
        MaxID3 ->
            case MaxID2 > MaxID3 of
                true ->
                    put({role_bag_max_goodsid,RoleID},MaxID2);
                false ->
                    ignore 
            end
    end.
