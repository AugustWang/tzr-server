%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     门派仓库模块
%%% @end
%%% Created : 2010-12-17
%%%-------------------------------------------------------------------
-module(mod_map_fmldepot).

-include("mgeem.hrl").

-define(LOGTYPE_PUTIN,1).
-define(LOGTYPE_GETOUT,2).
-define(PAGE_SIZE,10).  %%仓库日志的每页大小
-define(MAX_LOGS,99).  %%仓库日志的最大数量
-define(MAX_BAG_LENGTH,42). %% 6*7
-define(FMLDEPOT_LOGS,fmldepot_logs).

%% API
-export([
         handle/1,
         handle/2
         ]).
handle(Msg,_State)->
    handle(Msg).

handle({Unique, Module, ?FMLDEPOT_LIST_GOODS, DataIn, RoleID, PID,Line})->
    do_list_goods({Unique, Module, ?FMLDEPOT_LIST_GOODS, DataIn, RoleID, PID, Line});
handle({Unique, Module, ?FMLDEPOT_PUTIN, DataIn, RoleID, PID,Line})->
    do_putin({Unique, Module, ?FMLDEPOT_PUTIN, DataIn, RoleID, PID, Line});
handle({Unique, Module, ?FMLDEPOT_LIST_LOG, DataIn, RoleID, PID,Line})->
    do_list_log({Unique, Module, ?FMLDEPOT_LIST_LOG, DataIn, RoleID, PID, Line});
handle({map_fmldepot_getout,From,RoleID,Record}) ->
    do_map_fmldepot_getout(From,RoleID,Record),
    ok;
handle(Args) ->
    ?ERROR_MSG("~w, unknow args: ~w", [?MODULE,Args]),
    ok. 



%% ====================================================================
%% Internal functions
%% ====================================================================

%%@interface 处理从门派仓库获取物品
do_map_fmldepot_getout(From,RoleID,Record)->
    assert_in_family_map(),

    {ok,#p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    #m_fmldepot_getout_tos{bag_id=FromBagID,goods_id=GoodsID,num=ItemNum} = Record,
    case FamilyID>0 of
        true-> 
            TransFun = fun()-> t_do_map_fmldepot_getout(RoleID,FamilyID,FromBagID,GoodsID,ItemNum) end,
            case db:transaction(TransFun) of
                {atomic,{ok,UpdateRoleGoodsList,DepotRemainGoods}} ->
                    #p_goods{typeid=ItemTypeID,current_colour=ItemColor,current_num=RemainNum} = DepotRemainGoods,
                    %%道具日志
                    common_item_logger:log(RoleID,DepotRemainGoods#p_goods{current_num=ItemNum},?LOG_ITEM_TYPE_FAMILY_DEPOT_GETOUT),
                    %%门派仓库日志
                    update_fmldepot_logs(RoleID,?LOGTYPE_GETOUT,ItemTypeID,ItemColor,ItemNum),
                    
                    common_misc:update_goods_notify({role, RoleID}, UpdateRoleGoodsList),
                    R2 = #m_fmldepot_getout_toc{succ=true,goods_id=GoodsID,remain_num=RemainNum},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?FMLDEPOT, ?FMLDEPOT_GETOUT, R2),

                    Request = {RoleID,DepotRemainGoods},
                    From ! {fmldepot_getout_result,true,Request};
                {aborted,Reason}->   
                    send_fmldepot_getout_error(RoleID,Reason),
                    From ! {fmldepot_getout_result,false,{RoleID}}
            end;
        _ ->
            send_fmldepot_getout_error(RoleID,<<"只有加入门派，才能从门派仓库获取物品">>)
    end.

t_do_map_fmldepot_getout(RoleID,FamilyID,FromBagID,GoodsID,DeductNum)->
    case t_deduct_fmldepot_goods(FamilyID,FromBagID,GoodsID,DeductNum) of
        {error,not_found}->
            db:abort(<<"门派仓库中找不到对应的物品，可能刚被其他帮众取走">>);
        {error,not_enough_num} ->
            db:abort(<<"门派仓库中没有足够数量的物品，可能刚被其他帮众取走">>);
        {ok,ToRoleGoods,DepotRemainGoods}->
            {ok, UpdateRoleGoodsList} = mod_bag:create_goods_by_p_goods(RoleID,ToRoleGoods),
            {ok, UpdateRoleGoodsList,DepotRemainGoods}
    end.

t_deduct_fmldepot_goods(FamilyID,FromBagID,GoodsID,DeductNum)->
    DepotKey = {FamilyID,FromBagID},
    case db:read(?DB_FAMILY_DEPOT,DepotKey) of
        []->
            {error,not_found};
        [#r_family_depot{bag_goods=GoodsList}=RecFml] ->
            case lists:keyfind(GoodsID, #p_goods.id, GoodsList) of
                false-> {error,not_found};
                #p_goods{current_num=CurNum}=FmlGoods-> 
                    if
                        CurNum=:=0 ->
                            GoodsList2 = lists:keydelete(GoodsID, #p_goods.id, GoodsList),
                            db:write(?DB_FAMILY_DEPOT,RecFml#r_family_depot{bag_goods=GoodsList2},write),
                            {error,not_enough_num};
                        CurNum>=DeductNum ->
                            ToRoleGoods = FmlGoods#p_goods{current_num=DeductNum},
                            RemainNum = (CurNum-DeductNum),
                            DepotRemainGoods = FmlGoods#p_goods{current_num=RemainNum},
                            case RemainNum>0 of
                                true->
                                    GoodsList2 = lists:keyreplace(GoodsID, #p_goods.id, GoodsList, DepotRemainGoods);
                                _->
                                    GoodsList2 = lists:keydelete(GoodsID, #p_goods.id, GoodsList)
                            end,
                            db:write(?DB_FAMILY_DEPOT,RecFml#r_family_depot{bag_goods=GoodsList2},write),
                            {ok,ToRoleGoods,DepotRemainGoods};
                        true ->
                            {error,not_enough_num}
                    end
            end         
    end.

send_fmldepot_getout_error(RoleID,Reason)->
    case is_binary(Reason) of
        true ->
            R2 = #m_fmldepot_getout_toc{succ=false,reason=Reason};
        false ->
            ?ERROR_MSG_STACK("System Error",Reason),
            R2 = #m_fmldepot_getout_toc{succ=false,reason=?_LANG_SYSTEM_ERROR}
    end,
    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?FMLDEPOT, ?FMLDEPOT_GETOUT, R2).
    

%%@interface 获取门派仓库中的物品列表
do_list_goods({Unique, Module,Method, _DataIn, RoleID, _PID, Line})->
    assert_in_family_map(),

    {ok,#p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    BagNum = get_family_depot_bag_num(FamilyID),
    Depots = lists:map(fun(BagID)->
                               DepotKey = {FamilyID,BagID},
                               case db:dirty_read(?DB_FAMILY_DEPOT,DepotKey) of
                                   []-> #p_fmldepot_bag{bag_id=BagID,goods_list=[]};
                                   [#r_family_depot{bag_goods=GoodsList}] ->
                                       #p_fmldepot_bag{bag_id=BagID,goods_list=GoodsList}
                               end
                       end, lists:seq(1, BagNum)),
    
    R2 = #m_fmldepot_list_goods_toc{depots=Depots},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2).

%%@interface 获取门派仓库中的物品
do_putin({Unique, Module,Method, DataIn, RoleID, _PID, Line})->
    assert_in_family_map(),

    {ok,#p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    case FamilyID>0 of
        true->
            do_putin_2({Unique, Module,Method, DataIn, RoleID, Line},FamilyID);
        _ ->
            ?SEND_ERR_TOC(m_fmldepot_putin_toc,<<"必须加入门派才能提取门派仓库的物品">>)
    end.
do_putin_2({Unique, Module,Method, DataIn, RoleID, Line},FamilyID)->
    {ok,#p_role_base{family_id=FamilyID,role_name=RoleName}} = mod_map_role:get_role_base(RoleID),
    #m_fmldepot_putin_tos{bag_id=ToBagID,goods_id=GoodsID} = DataIn,
    case mod_bag:check_inbag(RoleID,GoodsID) of
        {ok,PutinGoods}->
            #p_goods{typeid=ItemTypeID,current_num=ItemNum,bind=IsBind,current_colour=ItemColor} = PutinGoods,
            TransFun = fun()-> 
                               case IsBind of
                                   true->
                                       db:abort(<<"不能将绑定的物品存放到门派仓库">>);
                                   _->
                                       mod_bag:delete_goods(RoleID,GoodsID),
                                       t_add_goods_to_depot(FamilyID,ToBagID,PutinGoods)
                               end
                       end,
            case db:transaction(TransFun) of
                {atomic, {ok,DepotGoods}} ->
                    %%道具日志
                    common_item_logger:log(RoleID,DepotGoods#p_goods{current_num=ItemNum},?LOG_ITEM_TYPE_FAMILY_DEPOT_GETOUT),
                    %%门派仓库日志
                    update_fmldepot_logs(RoleID,?LOGTYPE_PUTIN,ItemTypeID,ItemColor,ItemNum),
                    
                    common_misc:del_goods_notify({role, RoleID}, PutinGoods),
                    R2 = #m_fmldepot_putin_toc{succ=true,add_goods=DepotGoods},
                    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2),
                    
                    RecMember = #m_fmldepot_update_goods_toc{update_type=?LOGTYPE_PUTIN,goods=[DepotGoods]},
                    common_family:broadcast_to_all_inmap_member_except(FamilyID, ?FMLDEPOT,?FMLDEPOT_UPDATE_GOODS, RecMember, RoleID),
                    
                    case ItemColor>=?COLOUR_BLUE of
                        true-> 
                            GoodsName = common_misc:format_goods_name_colour(ItemColor,PutinGoods#p_goods.name),
                            FamilyMsg = common_misc:format_lang(<<"<font color=\"#FFFF00\">[~s]</font>在门派仓库贡献了~s×~w，有需要的帮众快去看看吧！">>,[RoleName,GoodsName,ItemNum]),
                            common_broadcast:bc_send_msg_family(FamilyID,?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_FAMILY,FamilyMsg);
                        _ ->
                            ignore
                    end;
                {aborted,Reason}->
                    ?SEND_ERR_TOC2(m_fmldepot_putin_toc,Reason)
            end;
        _ ->
            ?SEND_ERR_TOC(m_fmldepot_putin_toc,<<"背包中没有对应的物品">>)
    end.

t_add_goods_to_depot(FamilyID,ToBagID,AddGoodsInfo)->
    %%check is not full
    DepotKey = {FamilyID,ToBagID},
    case db:read(?DB_FAMILY_DEPOT,DepotKey) of
        []->
            NewDepotGoods = transform_goods(AddGoodsInfo,ToBagID,[]),
            R1 = #r_family_depot{depot_key=DepotKey,bag_goods=[ NewDepotGoods ]},
            ok = db:write(?DB_FAMILY_DEPOT,R1,write),
            {ok,NewDepotGoods};
        [#r_family_depot{bag_goods=GoodsList}]->
            if
                length(GoodsList)=:= ?MAX_BAG_LENGTH ->
                    db:abort(<<"门派该仓库已满，请使用其他仓库">>);
                true->
                    NewDepotGoods = transform_goods(AddGoodsInfo,ToBagID,GoodsList),
                    R1 = #r_family_depot{depot_key=DepotKey,bag_goods=[ NewDepotGoods|GoodsList ]},
                    ok = db:write(?DB_FAMILY_DEPOT,R1,write),
                    {ok,NewDepotGoods}
            end
    end.



do_list_log({Unique, Module,Method, DataIn, RoleID, _PID, Line})->
    assert_in_family_map(),

    {ok,#p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    case FamilyID>0 of
        true->
            do_list_log_2({Unique, Module,Method, DataIn, RoleID, Line},FamilyID);
        _ ->
            ?SEND_ERR_TOC(m_fmldepot_list_log_toc,<<"必须加入门派才能查看门派仓库日志">>)
    end.
do_list_log_2({Unique, Module,Method, DataIn, RoleID, Line},FamilyID)->
    #m_fmldepot_list_log_tos{log_type=LogType,page_num=PageNum} = DataIn,
    {Logs,LogCount} = get_fmldepot_logs(FamilyID,LogType,PageNum),
    R2 = #m_fmldepot_list_log_toc{succ=true,log_type=LogType,log_count=LogCount,page_num=PageNum,logs=Logs},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2).


%%更新仓库日志
update_fmldepot_logs(RoleID,LogType,ItemTypeID,ItemColor,ItemNum) ->
    try
        {ok,#p_role_base{role_name=RoleName,family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
        R2 = #p_fmldepot_log{log_time=common_tool:now(),role_name=RoleName,item_type_id=ItemTypeID,item_color=ItemColor,item_num=ItemNum},
        update_fmldepot_logs_2(FamilyID,LogType,R2)
    catch
        _:Reason->
            ?ERROR_MSG_STACK("update_fmldepot_logs error",Reason)
    end.

update_fmldepot_logs_2(FamilyID,LogType,LogRecord) when is_record(LogRecord,p_fmldepot_log)->
    #p_fmldepot_log{log_time=LogTime,role_name=RoleName,item_type_id=ItemTypeID,item_color=ItemColor,item_num=ItemNum} = LogRecord,
    Table = get_tab_for_logtype(LogType),
    FieldNames = [family_id,log_time,role_name,item_type_id,item_color,item_num],
    SQL = mod_mysql:get_esql_insert(Table,FieldNames,[FamilyID,LogTime,RoleName,ItemTypeID,ItemColor,ItemNum]),
    {ok,_} = mod_mysql:insert(SQL),
    Key = {?FMLDEPOT_LOGS,FamilyID,LogType},
    Queues = case get(Key) of
        undefined-> 
            refresh_fmldepot_logs_from_db(FamilyID,LogType);
        List1 -> 
            List2 = [LogRecord|List1],
            case length(List2)>?MAX_LOGS of
                true->
                    lists:sublist(List2, ?MAX_LOGS);
                _ ->
                    List2
            end
    end,
    put(Key,Queues),
    ok.

get_fmldepot_logs(_FamilyID,_LogType,PageNum) when (PageNum<1)->
    {[],0};
get_fmldepot_logs(FamilyID,LogType,PageNum)->
    Key = {?FMLDEPOT_LOGS,FamilyID,LogType},
    case get(Key) of
        undefined-> 
            List = refresh_fmldepot_logs_from_db(FamilyID,LogType);
        [] -> List = [];
        List -> next
    end,
    case List of
        []-> {[],0};
        _ ->
            LogCount = length(List),
            Start = (PageNum-1)*?PAGE_SIZE+1,
            Logs = lists:sublist(List, Start, ?PAGE_SIZE),
            {Logs,LogCount}
    end.
    

get_tab_for_logtype(?LOGTYPE_PUTIN)->
    t_family_depot_put_logs;
get_tab_for_logtype(?LOGTYPE_GETOUT)->
    t_family_depot_get_logs.

%%@doc 从数据库中读取日志到内存中
refresh_fmldepot_logs_from_db(FamilyID,LogType)->
    try
        Table = get_tab_for_logtype(LogType),
        refresh_fmldepot_logs_from_db_2(FamilyID,Table,LogType)
    catch
        _:Reason->
            ?ERROR_MSG_STACK("refresh_fmldepot_logs_from_db error",Reason),
            []
    end.

refresh_fmldepot_logs_from_db_2(FamilyID,Table,LogType) when is_atom(Table) and is_integer(FamilyID)->
    WhereExpr = io_lib:format("`family_id`=~w order by log_time desc limit ~w",[FamilyID,?MAX_LOGS]),
    FieldNames = [log_time,role_name,item_type_id,item_color,item_num],
    SQL = mod_mysql:get_esql_select(Table,FieldNames,WhereExpr) ,
    case mod_mysql:select(SQL) of
        {ok,[]}->
            put({?FMLDEPOT_LOGS,FamilyID,LogType},[]),
            Result = [];
        {ok,LogList}->
            Logs = [ get_fmldepot_log(Log) || Log<-LogList],
            put({?FMLDEPOT_LOGS,FamilyID,LogType},Logs),
            Result = Logs;
        {error,Error}->
            ?ERROR_MSG_STACK("refresh_fmldepot_logs_from_db error",Error),
            Result = []
    end,
    Result.

get_fmldepot_log([LogTime,RoleName,ItemTypeID,ItemColor,ItemNum])->
    #p_fmldepot_log{log_time=LogTime,role_name=RoleName,item_type_id=ItemTypeID,item_color=ItemColor,item_num=ItemNum}.
    


transform_goods(AddGoods,BagID,[])->
    AddGoods#p_goods{bagposition=0,id=1,bagid=BagID};
transform_goods(AddGoods,BagID,OldGoodsList) when is_record(AddGoods,p_goods)->
    GoodsID = lists:max([G#p_goods.id||G<-OldGoodsList])+1,
    AddGoods#p_goods{bagposition=0,id=GoodsID,bagid=BagID}.

%%@doc 获取门派仓库的背包数目
get_family_depot_bag_num(FamilyID)->
    case db:dirty_read(?DB_FAMILY_ASSETS,FamilyID) of
        []-> 1;
        [#r_family_assets{bag_num=BagNum}]->
            BagNum
    end.

%% 确认接口操作只在门派地图中进行
assert_in_family_map()->
    State = mgeem_map:get_state(),
    MapID = State#map_state.mapid,
    case MapID =:= ?DEFAULT_FAMILY_MAP_ID of
        true->
            ok;
        _ ->
            throw(not_in_family_map_id)
    end.
