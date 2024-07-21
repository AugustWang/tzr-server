%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2010, 
%%% @doc
%%%
%%% @end
%%% Created : 30 Nov 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_stall).

-include("mgeem.hrl").

-export([
         init/1,
         handle/1,
         do_terminate/0,
         role_offline/1]).

%%亲自摆摊模式
-define(STALL_MODE_SELF, 0).
%%托管摆摊模式
-define(STALL_MODE_AUTO, 1).
%%每页记录条数
-define(STALL_LIST_NUM, 10).
%%多久更新一次列表
-define(STALL_LIST_UPDATE_TICKET, 10000).

-define(STALL_LOG_CHAT, 0).
-define(STALL_LOG_BUY, 1).


-define(STALL_STATE_AUTO, 1).
-define(STALL_STATE_SELF, 2).
-define(STALL_STATE_NOT, 3).
-define(STALL_STATE_TIMEOVER, 4).

-define(DICT_KEY_TIMEREF, timeref).

-define(SYSTEMLETTER, 2).
-define(SENDER, "店小二").

-define(price_type_silver, 1).
-define(price_type_gold, 2).

-define(BUY_FROM_STALL, 1).
-define(BUY_FROM_MARKET, 2).

%%%===================================================================
%%% API
%%%===================================================================

init(MapPName) ->
    EtsLogName = common_tool:list_to_atom(lists:concat(["ets_stall_log_", MapPName])),
    ets:new(EtsLogName, [protected, named_table, set]),
    
    put(ets_stall_log, EtsLogName),
    do_init_stall(),
    ok.

handle(Args) ->
    do_handle(Args).

role_offline(RoleID) ->
    do_role_offline(RoleID).

%%清理当前的所有摊位
do_terminate() ->
    %%所有亲自摆摊摊位都设置为过期，自动摆摊摊位均打上标志
    EtsLogName = get_ets_stall_log(),
    lists:foreach(
      fun({RoleID, _, _}) ->
              do_terminate2(RoleID) 
      end, ets:tab2list(EtsLogName)).
do_terminate2(RoleID) ->
    case db:dirty_read(?DB_STALL, RoleID) of
        [_] ->
            do_terminate3(RoleID);
        _ ->
            ignore
    end.
do_terminate3(RoleID) ->
    case db:transaction(fun() -> t_do_terminate(RoleID) end) of
        {atomic, Result} ->
            case Result of 
                ok ->
                    ok;
                _ ->
                    {TX, TY, RoleName, Name, Mode, _GetSilverFinal, _TaxIncome, GoodsList, Flag, _GetGold, StallGoodsList} = Result,
                    %% 道具使用日志
                    item_logger_insert(RoleID, GoodsList, ?LOG_ITEM_TYPE_GAIN_STALL_GETOUT),
                    EtsLogName = get_ets_stall_log(),
                    case Flag of
                        true ->
                            ok;
                        false ->
                            ets:delete(EtsLogName, RoleID)
                    end,
                    RB = #m_stall_finish_toc{return_self=false, role_id=RoleID},
                    %%消息通知地图模块
                    mod_map_stall:handle_info({stall_finish, TX, TY, RoleID, RoleName, Name, Mode, RB}),
                    mod_stall_list:stall_list_delete(StallGoodsList)
            end;
        {aborted, ErrorInfo} ->
            ?ERROR_MSG("~ts:~w", ["处理玩家摊位出错", ErrorInfo])
    end.

%% ====================================================================
%% Internal functions
%% ====================================================================

do_handle({Unique, Module, ?STALL_REQUEST, DataIn, RoleID, PID, Line}) ->
    do_request(Unique, Module, ?STALL_REQUEST, DataIn, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_PUTIN, DataIn, RoleID, PID, Line}) ->
    do_putin(Unique, Module, ?STALL_PUTIN, DataIn, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_GETOUT, DataIn, RoleID, PID, Line}) ->
    do_getout(Unique, Module, ?STALL_GETOUT, DataIn, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_GETALL, DataIn, RoleID, PID, Line}) ->
    do_getall(Unique, Module, ?STALL_GETALL, DataIn, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_OPEN, _, RoleID, PID, Line}) ->
    do_open(Unique, Module, ?STALL_OPEN, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_DETAIL, DataIn, RoleID, PID, Line}) ->
    #m_stall_detail_tos{role_id=TargetRoleID} = DataIn,
    do_detail(Unique, Module, ?STALL_DETAIL, TargetRoleID, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_BUY, DataIn, RoleID, PID, Line}) ->
    do_buy(Unique, Module, ?STALL_BUY, DataIn, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_CHAT, DataIn, RoleID, PID, Line}) ->
    do_chat(Unique, Module, ?STALL_CHAT, DataIn, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_FINISH, DataIn, RoleID, PID, Line}) ->
    do_finish(Unique, Module, ?STALL_FINISH, DataIn, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_EXTRACTMONEY, _, RoleID, PID, Line}) ->
    do_extractmoney(Unique, Module, ?STALL_EXTRACTMONEY, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_EMPLOY, DataIn, RoleID, PID, Line}) ->
    do_employ(Unique, Module, ?STALL_EMPLOY, DataIn, RoleID, PID, Line);
do_handle({Unique, Module, ?STALL_MOVE, DataIn, RoleID, _PID, Line}) ->
    do_move(Unique, Module, ?STALL_MOVE, DataIn, RoleID, Line);
do_handle({Unique, Module, ?STALL_STATE, _DataIn, RoleID, PID, _Line}) ->
    do_state(Unique, Module, ?STALL_STATE, RoleID, PID);
do_handle({Unique, Module, ?STALL_LIST, DataIn, RoleID, PID, _Line}) ->
    do_list(Unique, Module, ?STALL_LIST, DataIn, RoleID, PID);

do_handle({auto_stall_remain_half_hour, RoleID}) ->
    do_remain_half_hour(RoleID);
do_handle({auto_stall_time_over, RoleID}) ->
    do_time_over(RoleID);
do_handle({kick_role_stall, RoleID}) ->
    do_time_over(RoleID);
do_handle({insert_buy_log, TargetRoleID, NewLog}) ->
    do_insert_buy_log(TargetRoleID, NewLog);
do_handle({stall_init,RoleID})->
    do_stall_init(RoleID);
do_handle({stall_finish, RoleID}) ->
    do_stall_finish(RoleID);
do_handle({stall_employ, RoleID, StartTime, TimeHour}) ->
    do_stall_employ(RoleID, StartTime, TimeHour);
do_handle({clear_item_stall_state, RoleId}) ->
    do_clear_item_stall_state(RoleId);

do_handle(Args) ->
    ?ERROR_MSG("mod_stall, unknow args: ~w", [Args]).

%% @doc 清理道具摆摊状态异常
do_clear_item_stall_state(RoleId) ->
    case mod_bag:get_bag_goods_list(RoleId, false) of
        {error, _} ->
            ignore;
        {ok, GoodsList} ->
            UpdateList = 
                lists:foldl(
                  fun(#p_goods{state=State}=G, AccList) ->
                          if State =:= ?GOODS_STATE_IN_STALL ->
                                  [G#p_goods{state=?GOODS_STATE_NORMAL}|AccList];
                             true ->
                                  AccList
                          end
                  end, [], GoodsList),
            {atomic, _} = common_transaction:t(fun() -> mod_bag:update_goods(RoleId, UpdateList) end),
            common_misc:update_goods_notify({role, RoleId}, UpdateList)
    end.

do_request(Unique, Module, Method, DataIn, RoleID, PID, Line)->
    case catch check_can_stall(RoleID,DataIn) of
        {ok,SilverCost,TimeHour}->
            do_request2(Unique,DataIn, RoleID, PID, SilverCost, TimeHour);
        {error,Reason}->
            do_request_error(Unique, Module, Method, Reason, RoleID, PID, Line)
    end.

check_can_stall(RoleID,DataIn)->
    case db:dirty_read(?DB_STALL,RoleID) of
        [_RoleStall]->
            throw({error,?_LANG_STALL_ALREADY_STALL});
        _->
            next
    end,
    RoleAttr = 
    case mod_map_role:get_role_attr(RoleID) of
        {ok,_RoleAttr}->
            _RoleAttr;
        _->
            throw({error,?_LANG_STALL_SYSTEM_ERROR})
    end,
    case check_role_condition2(RoleAttr) of
        ok->
            next;
        Msg->
            throw(Msg)
    end,
    TimeHour = DataIn#m_stall_request_tos.time_hour,
    case TimeHour =<0 of
        true->
             throw({error,?_LANG_STALL_BAD_REQUEST});
        false->
            next
    end,
    SilverCost = TimeHour * ?STALL_AUTO_SILVER_PER_HOUR + ?STALL_BASE_TAX,
    #p_role_attr{silver_bind=BindSilver, silver=Silver} = RoleAttr,
    case BindSilver+Silver<SilverCost of
        true->
            throw({error,?_LANG_STALL_NOT_ENOUGH_SILVER});
        false->
            next
    end,
    {ok,SilverCost,TimeHour}.

do_request2(Unique,_DataIn, RoleID, PID, SilverCost, TimeHour)->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    case db:transaction(fun() -> t_do_request(RoleID,RoleAttr,SilverCost,TimeHour) end) of
        {atomic, Result} ->
            %%mod_map_role:clear_role_spec_state(RoleID),
            %%这里的AllGoods每个都是p_stall_goods
            {TimeHour, RemainTime, _, RoleID, ReduceSilver, ReduceBindSilver, GoodsList} = Result,
            %%如果玩家有摊位，则ets表中必然是有一条记录的，同时 db_role_state中摆摊状态（自动或亲自）标志为true
            #p_map_role{faction_id=FactionID}=mod_map_actor:get_actor_mapinfo(RoleID, role),
            HomeMapID = common_misc:get_home_map_id(FactionID),
            HomeMapProcessName=common_misc:get_common_map_name(HomeMapID),
            global:send(HomeMapProcessName,{mod_stall,{stall_init,RoleID}}),
            %%提前半个小时提醒玩家
            TimeRef = erlang:send_after((RemainTime - 1800) * 1000, self(), {mod_stall, {auto_stall_remain_half_hour, RoleID}}),
            %%时间到了自动过期，不收摊，但是要提取出银两
            TimeRef2 = erlang:send_after(RemainTime * 1000, self(), {mod_stall, {auto_stall_time_over, RoleID}}),
            put({?DICT_KEY_TIMEREF, RoleID}, {TimeRef, TimeRef2}),
            %% 成就 add by caochuncheng 2011-03-08
            common_hook_achievement:hook({mod_stall,{stall_request,RoleID}}),
            Record = #m_stall_request_toc{silver=ReduceSilver, bind_silver=ReduceBindSilver},
            common_misc:unicast2(PID, Unique, ?STALL, ?STALL_REQUEST, Record),
            %%通知mgeem_map更新之前已打上标记的 {stall, {TX, TY}}
            %%mod_map_stall:handle_info({stall_sure, TX, TY, RoleID, RoleName, Name, Mode}),
            %% 发送到摆摊列表
            mod_stall_list:stall_list_insert(GoodsList);
        {aborted,{error,Reason}}->
            do_request_error(Unique, ?STALL, ?STALL_REQUEST, Reason, RoleID, PID, 0);
        {aborted, Detail} ->
            case is_binary(Detail) of
                true ->
                    Reason = Detail;
                false ->
                    ?ERROR_MSG("~ts:~w", ["摆摊失败", Detail]),
                    Reason = ?_LANG_STALL_SYSTEM_ERROR
            end,
            %%mod_map_stall:handle_info({stall_cancel, TX, TY}),
            do_request_error(Unique, ?STALL, ?STALL_REQUEST, Reason, RoleID, PID, 0)
    end.


%%摆摊请求，因为摆摊需要从地图开始检查，所以消息首先被发送到地图了
%%这里检查几个条件：
%%    1. 银子够不够
%%    2. 当前位置是否允许摆摊
%%    3. 玩家是否正处于战斗状态
%%    4. 周围是否有足够的空间来摆摊
%%    5. 玩家等级是否已经达到30级
    
%% do_request(Unique, Module, Method, DataIn, RoleID, PID, Line) ->
%%     ?DEBUG("~ts:~w ~w ~w ~w ~w ~w", ["收到玩家摆摊请求", Unique, Module, Method, RoleID, PID, Line]),
%%     %%检查是否该位置能够摆摊，先检查这个是因为进程字典的速度最快，而且大部分不能摆摊的原因都是当前位置不能摆摊
%%     case mod_map_actor:get_actor_mapinfo(RoleID, role) of
%%         undefined ->
%%             Reason = ?_LANG_STALL_SYSTEM_ERROR,
%%             do_request_error(Unique, Module, Method, Reason, RoleID, PID, Line);
%%         #p_map_role{pos=#p_pos{tx=TX, ty=TY}} ->
%%             %%检查能否摆摊，包括检查周围空间
%%             case check_pos_can_stall(TX, TY) of
%%                 ok ->
%%                     do_request2(Unique, Module, Method, {DataIn, TX, TY}, RoleID, PID, Line);
%%                 {error, Reason} ->
%%                     do_request_error(Unique, Module, Method, Reason, RoleID, PID, Line)
%%             end
%%     end.
%% do_request2(Unique, Module, Method, {DataIn, TX, TY}, RoleID, PID, Line) ->
%%     %%判断玩家是否已经摆摊了
%%     case common_misc:is_role_self_stalling(RoleID) orelse common_misc:is_role_auto_stalling(RoleID) of
%%         false ->
%%             do_request3(Unique, Module, Method, {DataIn, TX, TY}, RoleID, PID, Line);
%%         true ->
%%             Reason = ?_LANG_STALL_ALREADY_STALL,
%%             do_request_error(Unique, Module, Method, Reason, RoleID, PID, Line)
%%     end.
%% do_request3(Unique, Module, Method, {DataIn, TX, TY}, RoleID, PID, Line) ->
%%     %%获取当前玩家的信息
%%     case mod_map_role:get_role_attr(RoleID) of
%%         {ok, RoleAttr} ->
%%             %%判断玩家基本条件是否达到摆摊要求
%%             case check_role_condition(RoleAttr) of
%%                 ok ->
%%                     do_request4(Unique, Module, Method, {DataIn, TX, TY}, RoleID, PID, Line);
%%                 {error, Reason} ->
%%                     do_request_error(Unique, Module, Method, Reason, RoleID, PID, Line)
%%             end;
%%         {error, Reason} ->
%%             ?ERROR_MSG("~ts: roleid->~w, reason->~w", ["脏读玩家信息失败", RoleID, Reason]),
%%             Reason2 = ?_LANG_STALL_SYSTEM_ERROR,
%%             do_request_error(Unique, Module, Method, Reason2, RoleID, PID, Line)
%%     end.
%% do_request4(Unique, Module, Method, {DataIn, TX, TY}, RoleID, PID, Line) ->
%%     %%前提条件在mod_map_stall模块中已经检查过了，这里需要检查摊位中的信息是否为空
%%     #m_stall_request_tos{name=Name, mode=Mode, time_hour=TimeHourTmp} = DataIn,
%%     %%如果是托管模式，这个参数表示托管时间
%%     TimeHour = erlang:abs(TimeHourTmp),
%%     %% 0 为自己摆摊 1 为托管摆摊
%%     Mode2 = filter_mode(Mode),
%%     %%检查摊位名称
%%     case check_name(Name) of
%%         ok ->
%%             do_request5(Unique, Module, Method, {Name, Mode2, TimeHour, TX, TY}, RoleID, PID, Line);
%%         {error, FilterResult} ->
%%             Reason = FilterResult,
%%             do_request_error(Unique, Module, Method, Reason, RoleID, Line)
%%     end.
%% do_request5(Unique, Module, Method, {Name, Mode, TimeHour, TX, TY}, RoleID, PID, Line) ->
%%     case db:transaction(fun() -> t_do_request(RoleID, Name, Mode, TimeHour, TX, TY) end) of
%%         {atomic, {error, _}} ->
%%             %%重新推摊位信息。。
%%             mod_map_stall:handle_info({stall_cancel, TX, TY}),
%%             do_request_error(Unique, Module, Method, ?_LANG_STALL_ERROR_GOODS_BEEN_USED, RoleID, Line),
%% 
%%             do_open(Unique, Module, Method, RoleID, PID, Line);
%%         {atomic, Result} ->
%%             mod_map_role:clear_role_spec_state(RoleID),
%%             %%这里的AllGoods每个都是p_stall_goods
%%             {Name, Mode, TimeHour, RemainTime, _, RoleID, RoleName, ReduceSilver, ReduceBindSilver, GoodsList} = Result,
%%             %%如果玩家有摊位，则ets表中必然是有一条记录的，同时 db_role_state中摆摊状态（自动或亲自）标志为true
%%             EtsLogName = get_ets_stall_log(),
%%             ets:insert(EtsLogName, {RoleID, [], []}),
%%             case Mode of
%%                 ?STALL_MODE_AUTO ->
%%                     %%提前半个小时提醒玩家
%%                     TimeRef = erlang:send_after((RemainTime - 1800) * 1000, self(), {mod_stall, {auto_stall_remain_half_hour, RoleID}}),
%%                     %%时间到了自动过期，不收摊，但是要提取出银两
%%                     TimeRef2 = erlang:send_after(RemainTime * 1000, self(), {mod_stall, {auto_stall_time_over, RoleID}}),
%%                     put({?DICT_KEY_TIMEREF, RoleID}, {TimeRef, TimeRef2});
%%                 _ ->
%%                     %%强制玩家下马
%%                     mod_equip_mount:force_mountdown(RoleID),
%%                     mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.state, ?ROLE_STATE_STALL}], mgeem_map:get_state())
%%             end,
%%             %% 成就 add by caochuncheng 2011-03-08
%%             common_hook_achievement:hook({mod_stall,{stall_request,RoleID}}),
%%             Record = #m_stall_request_toc{silver=ReduceSilver, bind_silver=ReduceBindSilver},
%%             common_misc:unicast(Line, RoleID, Unique, Module, Method, Record),
%%             %%通知mgeem_map更新之前已打上标记的 {stall, {TX, TY}}
%%             mod_map_stall:handle_info({stall_sure, TX, TY, RoleID, RoleName, Name, Mode}),
%%             %% 发送到摆摊列表
%%             mod_stall_list:stall_list_insert(GoodsList);
%%         {aborted, Detail} ->
%%             case is_binary(Detail) of
%%                 true ->
%%                     Reason = Detail;
%%                 false ->
%%                     ?ERROR_MSG("~ts:~w", ["摆摊失败", Detail]),
%%                     Reason = ?_LANG_STALL_SYSTEM_ERROR
%%             end,
%%             mod_map_stall:handle_info({stall_cancel, TX, TY}),
%%             do_request_error(Unique, Module, Method, Reason, RoleID, Line)
%%     end.
%% 
%% 
%% do_request_error(Unique, Module, Method, Reason, RoleID, Line) ->
%%     R = #m_stall_request_toc{succ=false, reason=Reason},
%%     common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

%%将物品放在摊位中
do_putin(Unique, Module, Method, DataIn, RoleID, _PID, Line) ->
    %%检查物品是否存在，检查物品状态，只有正常状态的物品才能被放入摊位中
    #m_stall_putin_tos{goods_id=GoodsID, pos=Pos, price=PriceTmp, price_type=PriceType} = DataIn, 
    Price = erlang:abs(PriceTmp),
    case db:transaction(fun() -> t_do_putin(GoodsID, Price, PriceType, Pos, RoleID) end) of
        {atomic, {ok, GoodsDetail, PutinType, StallGoods}} ->
            case PutinType =:= in_stall of
                true ->
                    mod_stall_list:stall_list_insert([StallGoods]);
                _ ->
                    ok
            end,
            %% 道具使用日志
            item_logger_insert(RoleID, [GoodsDetail], ?LOG_ITEM_TYPE_LOST_STALL_PUTIN),
            Record = #m_stall_putin_toc{},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Record);
        {aborted, ErrorInfo} ->
            ?ERROR_MSG("~ts:~w", ["玩家拖放物品到摊位出错（未摆摊时）", ErrorInfo]),
            case is_binary(ErrorInfo) of
                true ->
                    Reason = ErrorInfo;
                false ->
                    Reason = ?_LANG_STALL_SYSTEM_ERROR
            end,
            do_putin_error(Unique, Module, Method, Reason, RoleID, Line)
    end.

%%考虑两种情况：摆摊和未摆摊
t_do_putin(GoodsID, Price, PriceType, Pos, RoleID) ->
    case mod_bag:get_goods_by_id(RoleID, GoodsID) of
        {ok, GoodsDetail} ->
            #p_goods{state=GoodsState, bind=Bind} = GoodsDetail,
            if
                GoodsState =:= ?GOODS_STATE_IN_STALL ->
                    db:abort(?_LANG_STALL_GOODS_CANNT_STALL);
                Bind =:= true ->
                    db:abort(?_LANG_STALL_GOODS_BIND);
                true ->
                    t_do_putin2(GoodsDetail, Price, PriceType, Pos, RoleID)
            end;
        {error, _} ->
            db:abort(?_LANG_STALL_GOODS_CANNT_STALL)
    end.
t_do_putin2(GoodsDetail, Price, PriceType, Pos, RoleID) ->   
    StallGoods = #r_stall_goods{id={RoleID, GoodsDetail#p_goods.id}, role_id=RoleID, stall_price=Price, price_type=PriceType,
                                pos=Pos, goods_detail=GoodsDetail},
    %% 不在摆摊状态下则放入缓存表
    case db:read(?DB_STALL, RoleID, write) of
        [_] ->
            PutinType = in_stall,
            OldGoodsList = db:match_object(?DB_STALL_GOODS, #r_stall_goods{role_id=RoleID, _='_'}, write),
            case erlang:length(OldGoodsList) >= ?STALL_MAX_OF_GOODS of
                true ->
                    db:abort(?_LANG_STALL_MAX_OF_GOODS);
                false ->
                    mod_bag:delete_goods(RoleID, GoodsDetail#p_goods.id),
                    db:write(?DB_STALL_GOODS, StallGoods, write)
            end;
        [] ->
            PutinType = in_tmp,
            OldGoodsList = db:match_object(?DB_STALL_GOODS_TMP, #r_stall_goods{role_id=RoleID, _='_'}, write),
            case erlang:length(OldGoodsList) >= ?STALL_MAX_OF_GOODS of
                true ->
                    db:abort(?_LANG_STALL_MAX_OF_GOODS);
                false ->
                    NewGoodsDetail = GoodsDetail#p_goods{state=?GOODS_STATE_IN_STALL},
                    mod_bag:update_goods(RoleID, NewGoodsDetail),

                    db:write(?DB_STALL_GOODS_TMP, StallGoods, write)
            end
    end,
    {ok, GoodsDetail, PutinType, StallGoods}.

do_putin_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_stall_putin_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

do_getout(Unique, Module, Method, DataIn, RoleID, PID, Line) ->
    #m_stall_getout_tos{goods_id=GoodsIDTmp, bagid=BagID, pos=Pos} = DataIn,
    GoodsID = erlang:abs(GoodsIDTmp),
    case db:transaction(fun() -> t_do_getout(RoleID, GoodsID, BagID, Pos) end) of
        {atomic, {ok, GoodsInfo, GetOutType, StallGoods}} ->
            case GetOutType of
                in_stall ->
                    mod_stall_list:stall_list_delete([StallGoods]);
                _ ->
                    ignore
            end,
            %% 道具使用日志
            item_logger_insert(RoleID, [GoodsInfo], ?LOG_ITEM_TYPE_GAIN_STALL_GETOUT),
            common_misc:new_goods_notify({role, RoleID}, GoodsInfo),
            Record = #m_stall_getout_toc{},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Record);
        {atomic, _Result} ->
            Record = #m_stall_getout_toc{},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Record);
        {aborted, {throw, {bag_error, not_enough_pos}}} ->
            do_getout_error(Unique, Module, Method, ?_LANG_STALL_NOT_ENOUGH_BAG_SPACE_2, RoleID, Line);
        {aborted, ErrorInfo} ->
            ?ERROR_MSG("~ts:~w", ["玩家清空摊位出错", ErrorInfo]),
            case erlang:is_binary(ErrorInfo) of
                true ->
                    Reason = ErrorInfo;
                false ->
                    Reason = ?_LANG_STALL_SYSTEM_ERROR
            end,
            do_getout_error(Unique, Module, Method, Reason, RoleID, Line),

            do_open(Unique, Module, Method, RoleID, PID, Line)
    end.
t_do_getout(RoleID, GoodsID, BagID, Pos) -> 
    case db:read(?DB_STALL_GOODS_TMP, {RoleID, GoodsID}, write) of
        [StallGoods] ->
            db:delete(?DB_STALL_GOODS_TMP, StallGoods#r_stall_goods.id, write),
            
            case mod_bag:check_inbag(RoleID, GoodsID) of
                {ok, GoodsDetail} ->
                    GoodsDetail2 = GoodsDetail#p_goods{state=?GOODS_STATE_NORMAL},
                    mod_bag:update_goods(RoleID, GoodsDetail2),
                    {ok, GoodsDetail2, in_tmp, StallGoods};
                {error, _} ->
                    db:abort(?_LANG_STALL_GETOUT_ERROR_GOODS_BEEN_USED)
            end;
        
        [] ->
            case db:read(?DB_STALL_GOODS, {RoleID, GoodsID}, write) of
                [StallGoods] ->
                    #r_stall_goods{goods_detail=GoodsDetail} = StallGoods,
                    GoodsDetail2 = GoodsDetail#p_goods{bagid=BagID, bagposition=Pos, state=?GOODS_STATE_NORMAL},
                    mod_bag:create_goods_by_p_goods_and_id(RoleID, BagID, Pos, GoodsDetail2),
                    db:delete(?DB_STALL_GOODS, StallGoods#r_stall_goods.id, write),
                    {ok, GoodsDetail2, in_stall, StallGoods};
                _ ->
                    db:abort(?_LANG_STALL_GOODS_NOT_EXIST)
            end
    end.

do_getout_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_stall_getout_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

%%未摆摊的情况下取出摊位中的所有物品，如果玩家摊位结束后，背包空间不足，则将摊位中的物品写入到db_stall_goods_tmp表中
do_getall(Unique, Module, Method, _DataIn, RoleID, _PID, Line) ->
    case db:dirty_read(?DB_STALL,RoleID) of
        [_] ->
            Reason = ?_LANG_STALL_CANNT_GETALL_WHEN_STALLING,
            do_getall_error(Unique, Module, Method, Reason, RoleID, Line);
        _ ->
            case db:transaction(fun() -> t_do_getall(RoleID) end) of
                {atomic, {ok, GoodsList}} ->
                    %% 道具使用日志
                    item_logger_insert(RoleID, GoodsList, ?LOG_ITEM_TYPE_GAIN_STALL_GETOUT),
                    R = #m_stall_getall_toc{},
                    common_misc:unicast(Line, RoleID, Unique, Module, Method, R);
                {aborted, Error} ->
                    ?ERROR_MSG("~ts:~w", ["清空玩家摊位出错", Error]),
                    case erlang:is_binary(Error) of
                        true ->
                            Reason = Error;
                        false ->
                            Reason = ?_LANG_STALL_SYSTEM_ERROR
                    end,
                    do_getall_error(Unique, Module, Method, Reason, RoleID, Line)
            end
    end.

t_do_getall(RoleID) ->
    AllGoods = db:match_object(?DB_STALL_GOODS_TMP, #r_stall_goods{role_id=RoleID, _='_'}, write),
    Num = erlang:length(AllGoods),
    case Num > 0 of
        true ->
            lists:foldl(
              fun(Goods, {ok, GL}) ->
                      #r_stall_goods{id=ID, goods_detail=GoodsDetail} = Goods,
                      db:delete(?DB_STALL_GOODS_TMP, ID, write),
                      NewGoods = GoodsDetail#p_goods{state=?GOODS_STATE_NORMAL},
                      mod_bag:update_goods(RoleID, NewGoods),
                      {ok, [GoodsDetail|GL]}
              end, {ok, []}, AllGoods);
        false ->
            {ok, []}
    end.

do_getall_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_stall_getall_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).


%%玩家获得自己的摊位的信息，这里的信息脏读即可
do_open(Unique, Module, Method, RoleID, _PID, Line) ->
    case db:dirty_read(?DB_STALL, RoleID) of
        [StallInfo] ->
            StallGoods = db:dirty_match_object(?DB_STALL_GOODS, #r_stall_goods{role_id=RoleID, _ = '_'}),
            AllGoods = lists:foldl(
                         fun(StallOne, Acc) ->
                                 #r_stall_goods{stall_price=Price, price_type=PriceType, pos=Pos, goods_detail=GoodsDetail} = StallOne,
                                 PStallGoods = #p_stall_goods{goods=GoodsDetail, price=Price, pos=Pos, price_type=PriceType},
                                 [PStallGoods|Acc]
                         end, [], StallGoods),
            EtsLogName = get_ets_stall_log(),
            Logs = ets:lookup(EtsLogName, RoleID),

            case Logs of
                [] ->
                    BuyLogs = [],
                    ChatLogs = [];
                [{RoleID, BLogs, CLogs}] ->
                    BuyLogs = BLogs,
                    ChatLogs = CLogs
            end,
            case db:dirty_read(?DB_STALL_SILVER, RoleID) of
                [#r_stall_silver{get_silver=GetSilver, get_gold=GetGold}] ->
                    ok;
                [] ->
                    GetSilver = 0,
                    GetGold = 0
            end,

            #r_stall{start_time=StartTime, mode=Mode, time_hour=TimeHour, name=Name} = StallInfo,
            Tax = calc_income_tax(Mode, GetSilver),
            RemainTime = get_remain_time(Mode, StartTime, TimeHour),
            StateStall = get_open_state(RemainTime, Mode),
            R = #m_stall_open_toc{get_silver=GetSilver, tax=Tax, goods=AllGoods, 
                                  buy_logs=BuyLogs, chat_logs=ChatLogs, name=Name,
                                  remain_time=RemainTime, mode=Mode, state=StateStall,
                                  get_gold=GetGold};
            
        _ ->
            StallGoods = db:dirty_match_object(?DB_STALL_GOODS_TMP, #r_stall_goods{role_id=RoleID, _ = '_'}),
            AllGoods = sys_stall_bag(RoleID, StallGoods),
            R = #m_stall_open_toc{goods=AllGoods, state=?STALL_STATE_NOT}
    end,
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

get_open_state(RemainTime, Mode) ->
    case RemainTime > 0 of
        true ->
            case Mode of
                ?STALL_MODE_AUTO ->
                    ?STALL_STATE_AUTO;
                _ ->
                    ?STALL_STATE_SELF
            end;
        false ->
            case Mode of
                ?STALL_MODE_AUTO ->
                    ?STALL_STATE_TIMEOVER;
                _ ->
                    ?STALL_STATE_SELF
            end
    end.


%%获取某个玩家的摊位详情
do_detail(Unique, Module, Method, TargetRoleID, RoleID, _PID, Line) ->
    AllGoods = get_dirty_stall_goods(TargetRoleID),
    %%判断玩家是否正处于摆摊状态，是的话则需要获取一系列的相关信息
    EtsLogName = get_ets_stall_log(),
    case ets:lookup(EtsLogName, TargetRoleID) of
        %%能够找到日志记录就说明玩家当前的确是在摆摊
        [{TargetRoleID, BuyLogs, ChatLogs}] ->
            [StallDetail] = db:dirty_read(?DB_STALL, TargetRoleID),
            #r_stall{start_time=StartTime, mode=Mode, time_hour=TimeHour, 
                     name=Name, role_name=RoleName} = StallDetail,
            RemainTime = get_remain_time(Mode, StartTime, TimeHour),
            R = #m_stall_detail_toc{role_id=TargetRoleID, role_name=RoleName, goods=AllGoods, 
                                    buy_logs=BuyLogs, chat_logs=ChatLogs, name=Name,
                                    remain_time=RemainTime, mode=Mode};
        [] ->
            R = #m_stall_detail_toc{succ=false, reason=?_LANG_STALL_HAS_FINISH}
    end,
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).   

%%玩家购买物品
do_buy(Unique, Module, Method, DataIn, RoleID, _PID, Line) ->
    case DataIn#m_stall_buy_tos.number =< 0 of
        true ->
            R = #m_stall_buy_toc{succ=false, reason=?_LANG_STALL_NUM_ILLEGAL, return_self=true},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R);
        _ ->
            do_buy2(Unique, Module, Method, DataIn, RoleID, Line)
    end.
do_buy2(Unique, Module, Method, DataIn, RoleID, Line) ->
    #m_stall_buy_tos{role_id=TargetRoleID, goods_id=GoodsID, number=Number, goods_price=BuyPrice, buy_from=BuyFrom} = DataIn,
    case db:transaction(fun() -> t_do_buy(RoleID, TargetRoleID, GoodsID, Number, BuyPrice, BuyFrom) end) of
        {atomic, {RoleName, GoodsInfo, Number, Price, PriceType, StallMapID, Detail, NewStallGoods}} ->
            hook_prop:hook(create, [GoodsInfo]),
            R = #m_stall_buy_toc{num=Number, role_id=TargetRoleID, goods_id=GoodsID},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R),
            R2 = #m_stall_buy_toc{return_self=false, role_id=RoleID, goods_id=GoodsID, num=Number, role_name=RoleName},
            common_misc:unicast({role, TargetRoleID}, ?DEFAULT_UNIQUE, Module, Method, R2),
            common_misc:update_goods_notify({role, RoleID}, GoodsInfo),
            %%写购买日志
            Now = common_tool:now(),
            NewLog = #p_stall_log{type=?STALL_LOG_BUY, src_role_id=RoleID, src_role_name=RoleName,
                                  goods_info=GoodsInfo, number=Number, price=Price, time=Now, price_type=PriceType},
            MapID = mgeem_map:get_mapid(),
            case MapID =:= StallMapID of
                true ->
                    do_insert_buy_log(TargetRoleID, NewLog);
                _ ->
                    StallMapPName = common_misc:get_map_name(StallMapID),
                    catch global:send(StallMapPName, {mod_stall, {insert_buy_log, TargetRoleID, NewLog}})
            end,
            %% 道具消费日志
            case BuyFrom of
                ?BUY_FROM_STALL ->
                    common_item_logger:log(RoleID,GoodsInfo,Number,?LOG_ITEM_TYPE_BAI_TAN_HUO_DE),
                    common_item_logger:log(TargetRoleID,GoodsInfo,Number,?LOG_ITEM_TYPE_BAI_TAN_CHU_SHOU);
                _ ->
                    common_item_logger:log(RoleID, GoodsInfo, Number, ?LOG_ITEM_TYPE_MARKET_HUO_DE),
                    common_item_logger:log(TargetRoleID, GoodsInfo, Number, ?LOG_ITEM_TYPE_MARKET_CHU_SHOU)
            end,
            case NewStallGoods of
                undefined ->
                    mod_stall_list:stall_list_delete([Detail]);
                _ ->
                    mod_stall_list:stall_list_update(NewStallGoods)
            end,
            ok;
        {aborted, {throw, {bag_error, not_enough_pos}}} ->
            R = #m_stall_buy_toc{succ=false, reason=?_LANG_STALL_NOT_ENOUGH_BAG_SPACE_2, return_self=true},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R);
        {aborted, ErrorInfo} ->
            case erlang:is_binary(ErrorInfo) of
                true ->
                    Reason = ErrorInfo;
                false ->
                    Reason = ?_LANG_STALL_SYSTEM_ERROR
            end,
            %%?ERROR_MSG("~ts:~w", ["购买摊位物品出错", ErrorInfo]),
            case Reason =:= ?_LANG_STALL_HAS_FINISH of
                false ->
                    R = #m_stall_buy_toc{succ=false, reason=Reason, return_self=true};
                true ->
                    R = #m_stall_buy_toc{succ=false, reason=Reason, return_self=true, stall_finish=true}
            end,
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R)
    end.


%%买东西的事务处理逻辑
t_do_buy(RoleID, TargetRoleID, GoodsID, Number, BuyPrice, BuyFrom) ->
    %%判断玩家是否正在摆摊
    case db:read(?DB_STALL, TargetRoleID, write) of
        [] ->
            db:abort(?_LANG_STALL_HAS_FINISH);
        [StallInfo] ->
            %%托管摆摊的话判断是否过期
            #r_stall{start_time=StartTime, mode=Mode, time_hour=TimeHour, mapid=StallMapID} = StallInfo,
            RemainTime = get_remain_time(Mode, StartTime, TimeHour),
            StateStall = get_open_state(RemainTime, Mode),
            case StateStall =:=  ?STALL_STATE_TIMEOVER of
                true ->
                     db:abort(?_LANG_STALL_HAS_FINISH);
                false ->
                    %%判断摊主是否卖这件东西，且数量是否足够
                    case db:read(?DB_STALL_GOODS, {TargetRoleID, GoodsID}) of
                        [] ->
                            db:abort(?_LANG_STALL_GOODS_ALL_SELLED);
                        [Detail] ->
                            t_do_buy2(RoleID, TargetRoleID, Number, Detail, BuyPrice, StallMapID, BuyFrom)
                    end
            end
    end.
%%RoleID是买主  TargetRoleID是卖主
t_do_buy2(RoleID, TargetRoleID, Number, Detail, BuyPrice, StallMapID, BuyFrom) ->
    #r_stall_goods{stall_price=Price, price_type=PriceType, goods_detail=GoodsDetail} = Detail,
    %% 客户端发过来的价格和服务端价格是否一样，不一样则报错
    case BuyPrice =:= Price of
        true ->
            ok;
        _ ->
            db:abort(?_LANG_STALL_GOODS_PRICE_CHANGE)
    end,
    #p_goods{current_num=CurNum, typeid=TypeId} = GoodsDetail,
    %%检查数量够不够
    case CurNum >= Number of
        true ->
            ok;
        false ->
            db:abort(?_LANG_STALL_GOODS_NOT_ENOUGH)
    end,
    %%检查银子够不够
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{silver=OldSilver, gold=OldGold} = RoleAttr,
    if
        PriceType =:= ?price_type_silver andalso OldSilver < Number * Price ->
            db:abort(?_LANG_STALL_YOUR_SILVER_NOT_ENOUGH);
        PriceType =:= ?price_type_gold andalso OldGold < Number * Price ->
            db:abort(?_LANG_STALL_YOUR_GOLD_NOT_ENOUGH);
        true ->
            ok
    end,
    %%判断是删除还是减少
    NewNumber = CurNum - Number,
    case NewNumber =:= 0 of
        true ->
            db:delete(?DB_STALL_GOODS, {TargetRoleID, GoodsDetail#p_goods.id}, write),
            NewStallGoods = undefined;
        false ->
            NewGoodsDetail = GoodsDetail#p_goods{current_num=CurNum-Number},
            NewStallGoods = Detail#r_stall_goods{goods_detail=NewGoodsDetail},
            db:write(?DB_STALL_GOODS, NewStallGoods, write)
    end,
    %%扣除买家的银两
    [#r_stall_silver{get_silver=OldGetSilver, get_gold=OldGetGold}=StallSilver] = db:read(?DB_STALL_SILVER, TargetRoleID, write),
    case PriceType of
        ?price_type_silver ->
            NewRoleAttr = RoleAttr#p_role_attr{silver=OldSilver-Number*Price},
            NewStallSilver = StallSilver#r_stall_silver{get_silver=OldGetSilver+Number*Price},
            case BuyFrom of
                ?BUY_FROM_STALL ->
                    %% 消费日志
                    common_consume_logger:use_silver({RoleID, 0, Number*Price, ?CONSUME_TYPE_SILVER_BUY_ITEM_FROM_STALL,
                                                      "", TypeId, Number}),
                    common_consume_logger:gain_silver({TargetRoleID, 0, Number*Price, ?GAIN_TYPE_SILVER_FROM_STALL_SELL_ITEM,
                                                       ""});
                _ ->
                    common_consume_logger:use_silver({RoleID, 0, Number*Price, ?CONSUME_TYPE_SILVER_BUY_ITEM_FROM_MARKET, 
                                                      "", TypeId, Number}),
                    common_consume_logger:gain_silver({TargetRoleID, 0, Number*Price, ?GAIN_TYPE_SILVER_FROM_MARKET_SELL_ITEM, 
                                                       ""})
            end;
        _ ->
            NewRoleAttr = RoleAttr#p_role_attr{gold=OldGold-Number*Price},
            NewStallSilver = StallSilver#r_stall_silver{get_gold=OldGetGold+Number*Price},
            case BuyFrom of
                ?BUY_FROM_STALL ->
                    %% 消费日志
                    common_consume_logger:use_gold({RoleID, 0, Number*Price, ?CONSUME_TYPE_GOLD_BUY_ITEM_FROM_STALL,
                                                    ""}),
                    common_consume_logger:gain_gold({TargetRoleID, 0, Number*Price, ?GAIN_TYPE_GOLD_FROM_STALL_SELL_ITEM,
                                                     ""});
                _  ->
                    common_consume_logger:use_gold({RoleID, 0, Number*Price, ?CONSUME_TYPE_GOLD_BUY_ITEM_FROM_MARKET,
                                                    ""}),
                    common_consume_logger:gain_gold({TargetRoleID, 0, Number*Price, ?GAIN_TYPE_GOLD_FROM_MARKET_SELL_ITEM,
                                                     ""})
            end 
    end,
    GetGoods = GoodsDetail#p_goods{current_num=Number, state=?GOODS_STATE_NORMAL},
    {ok, [GetGoods2]} = mod_bag:create_goods_by_p_goods(RoleID, GetGoods),
    mod_map_role:set_role_attr(RoleID,NewRoleAttr),
    db:write(?DB_STALL_SILVER, NewStallSilver, write),
    {RoleAttr#p_role_attr.role_name, GetGoods2, Number, Number*Price, PriceType, StallMapID, Detail, NewStallGoods}.

%%处理摆摊中的留言
do_chat(Unique, Module, Method, DataIn, RoleID, PID, Line) ->
    #m_stall_chat_tos{target_role_id=TargetRoleID, content=Content} = DataIn, 
    %%这里是留言，而不是聊天
    EtsLogName = get_ets_stall_log(),
    case ets:lookup(EtsLogName, TargetRoleID) of
        [{TargetRoleID, BuyLogs, OldChatLogs}] ->
            do_chat2(Unique, Module, Method, {TargetRoleID, Content, BuyLogs, OldChatLogs}, RoleID, PID, Line, EtsLogName);
        []  ->
            Reason = ?_LANG_STALL_TARGET_ROLE_NOT_STALLING,
            do_chat_error(Unique, Module, Method, Reason, RoleID, Line)
    end.
do_chat2(Unique, Module, Method, {TargetRoleID, Content, BuyLogs, OldChatLogs}, RoleID, _PID, Line, EtsLogName) ->
    %% 要用脏读，玩家可能不在本地图
    {ok, #p_role_base{role_name=RoleName}} = common_misc:get_dirty_role_base(RoleID),
    Now = common_tool:now(),
    %%给双方发消息，同时插入记录到ets
    RSelf = #m_stall_chat_toc{},
    RTar = #m_stall_chat_toc{return_self=false, src_role_id=RoleID, 
                             src_role_name=RoleName, content=Content, time=Now},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, RSelf),
    common_misc:unicast({role, TargetRoleID}, Unique, Module, Method, RTar),
    %%构造新的记录
    NewLog = #p_stall_log{type=?STALL_LOG_CHAT, src_role_id=RoleID, src_role_name=RoleName,
                          content=Content, time=Now},
    %%判断聊天记录是否已经达到最大条数限制了
    case erlang:length(OldChatLogs) >= ?STALL_CHAT_LOGS_MAX_NUM of
        true ->
            [_|OldChatLogsT] = OldChatLogs,
            NewChatLogs = lists:reverse([NewLog | lists:reverse(OldChatLogsT)]);
        false ->
            NewChatLogs = lists:reverse([NewLog | lists:reverse(OldChatLogs)])
    end,
    ets:insert(EtsLogName, {TargetRoleID, BuyLogs, NewChatLogs}).


%%处理聊天出错
do_chat_error(Unique, Module, Method, Reason, RoleID, Line) ->
    R = #m_stall_chat_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

%%玩家收摊了
do_finish(Unique, Module, Method, _DataIn, RoleID, _PID, Line) ->
    %%判断是否有摊位
    case db:transaction(fun() -> t_do_finish(RoleID) end) of
        {atomic, Result} ->
            {Mode, GetFinal, Tax, GoodsList, RetSilver, RetBindSilver, GetGold, StallMapID, StallGoodsList} = Result,
            %% 道具使用日志
            item_logger_insert(RoleID, GoodsList, ?LOG_ITEM_TYPE_GAIN_STALL_GETOUT),
            %%
            MapID = mgeem_map:get_mapid(),
            case MapID =:= StallMapID of
                true ->
                    do_stall_finish(RoleID);
                _ ->
                    StallMapName = common_misc:get_map_name(StallMapID),
                    catch global:send(StallMapName, {mod_stall, {stall_finish, RoleID}})
            end,
            %%将角色状态标记为正常
            case Mode of
                ?STALL_MODE_AUTO ->
                    ok;
                _ ->
                    mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.state, ?ROLE_STATE_NORMAL}], mgeem_map:get_state())
            end,
            case GoodsList of
                [] ->
                    ignore;
                _ ->
                    common_misc:new_goods_notify({role, RoleID}, GoodsList)
            end,
            mod_stall_list:stall_list_delete(StallGoodsList),
            %%通知客户端
            R = #m_stall_finish_toc{tax=Tax, get_silver=GetFinal, silver=RetSilver, bind_silver=RetBindSilver, get_gold=GetGold},
            ok;
        {aborted, Reason} when is_binary(Reason); is_list(Reason) ->
            R = #m_stall_finish_toc{succ=false, reason=Reason};
        {aborted, ErrorInfo} ->
            ?ERROR_MSG("~ts:~w", ["玩家收摊出错", ErrorInfo]),
            R = #m_stall_finish_toc{succ=false, reason=?_LANG_STALL_SYSTEM_ERROR}
    end,

    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

t_do_finish(RoleID) ->
    %% 把摊位上的物品移回背包
    StallGoodsList = db:match_object(?DB_STALL_GOODS, #r_stall_goods{role_id=RoleID, _='_'}, write),

    {GoodsList, _} =
        lists:foldl(
          fun(StallGoods, {GL, N}) ->
                  #r_stall_goods{id=ID, goods_detail=Goods} = StallGoods,
                  db:delete(?DB_STALL_GOODS, ID, write),
                  Goods2 = Goods#p_goods{state=?GOODS_STATE_NORMAL},
                  case catch mod_bag:create_goods_by_p_goods_and_id(RoleID, Goods2) of
                      {bag_error, _} ->
                          db:abort(lists:flatten(io_lib:format(?_LANG_STALL_NOT_ENOUGH_BAG_SPACE, [N])));
                      {ok, [Goods3]} ->
                          {[Goods3|GL], N-1}
                  end
          end, {[], erlang:length(StallGoodsList)}, StallGoodsList),

    %% 删除摊位信息
    [StallDetail] = db:read(?DB_STALL, RoleID, write),
    db:delete(?DB_STALL, RoleID, write),

    #r_stall{start_time=StartTime, mode=Mode, time_hour=TimeHour, mapid=StallMapID,
             use_silver=UseSilver, use_silver_bind=UseSilverBind} = StallDetail,

    %%计算应该返回的银子
    BackSilver = get_return_back_silver(Mode, StartTime, TimeHour),
    case BackSilver > 0 of
        true ->
            {RetSilver, RetBindSilver} = calc_return_silver(UseSilver, UseSilverBind, BackSilver),

            common_consume_logger:gain_silver({RoleID, RetBindSilver, RetSilver, ?GAIN_TYPE_SILVER_STALL_CANCEL,
                                               ""});
        false ->
            {RetSilver, RetBindSilver} = {0, 0}
    end,

    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{silver=OldSilver, silver_bind=OldBindSilver, gold=OldGold} = RoleAttr,
    %%读取获取银两记录
    [#r_stall_silver{get_silver=GetSilver, get_gold=GetGold}] = db:read(?DB_STALL_SILVER, RoleID, write),
    db:delete(?DB_STALL_SILVER, RoleID, write),
    TaxIncome = calc_income_tax(Mode, GetSilver),
    GetSilverFinal = GetSilver - TaxIncome,
    %%写入银子数据
    mod_map_role:set_role_attr(RoleID,RoleAttr#p_role_attr{silver=OldSilver+GetSilverFinal+RetSilver, 
                                                           silver_bind=OldBindSilver+RetBindSilver,
                                                           gold=OldGold+GetGold}),
    %%将角色状态标记为正常
    %%db:write(?DB_ROLE_STATE, #r_role_state{role_id=RoleID}, write),
    {Mode, GetSilverFinal, TaxIncome, GoodsList, RetSilver, RetBindSilver, GetGold, StallMapID, StallGoodsList}.

%%中途雇佣店小二
do_employ(Unique, Module, Method, DataIn, RoleID, _PID, Line) ->
    #m_stall_employ_tos{hour=HourTmp} = DataIn,
    Hour = erlang:abs(HourTmp),
    case db:transaction(fun() -> t_do_employ(RoleID, Hour) end) of
        {atomic, Result} ->
            {Mode, NewStall, StallMapID, ReduceSilver, ReduceBindSilver} = Result,
            R = #m_stall_employ_toc{silver=ReduceSilver, bind_silver=ReduceBindSilver},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R),
            #r_stall{start_time=StartTime, time_hour=TimeHour} = NewStall,
            MapID = mgeem_map:get_mapid(),
            case MapID =:= StallMapID of
                true ->
                    do_stall_employ(RoleID, StartTime, TimeHour);
                _ ->
                    StallMapName = common_misc:get_map_name(StallMapID),
                    catch global:send(StallMapName, {mod_stall, {stall_employ, RoleID, StartTime, TimeHour}})
            end,
            %%将角色状态标记为正常
            case Mode of
                ?STALL_MODE_AUTO ->
                    ok;
                _ ->
                    mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.state, ?ROLE_STATE_NORMAL}], mgeem_map:get_state())
            end,
            ok;
        {aborted, ErrorInfo} ->
            ?ERROR_MSG("~ts:~w", ["中途雇佣店小二出错", ErrorInfo]),
            case erlang:is_binary(ErrorInfo) of
                true ->
                    Reason = ErrorInfo;
                false ->
                    Reason = ?_LANG_STALL_SYSTEM_ERROR
            end,
            R = #m_stall_employ_toc{succ=false, reason=Reason},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R)            
    end.


%%雇佣摆摊的事务处理过程
t_do_employ(RoleID, Hour) ->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    %%判断银两是否足够，先判断绑定的
    #p_role_attr{silver=Silver, silver_bind=BindSilver} = RoleAttr,
    case Silver+BindSilver >= Hour*?STALL_AUTO_SILVER_PER_HOUR of
        true ->
            ok;
        _ ->
            db:abort(?_LANG_STALL_NOT_ENOUGH_SILVER)
    end,
    %%一小时一两银子
    {ReduceSilver, ReduceBindSilver} = calc_reduce_silver(Silver, BindSilver, Hour*?STALL_AUTO_SILVER_PER_HOUR),
    NewRoleAttr = RoleAttr#p_role_attr{silver=Silver-ReduceSilver, silver_bind=BindSilver-ReduceBindSilver},
    mod_map_role:set_role_attr(RoleID,NewRoleAttr),
    %%消费日志
    common_consume_logger:use_silver({RoleID, ReduceBindSilver, ReduceSilver, ?CONSUME_TYPE_SILVER_FEE_BUY_ITEM_FROM_STALL,
                                      ""}),    
    %%修改摆摊模式
    [Stall] = db:read(?DB_STALL, RoleID, write),
    #r_stall{mode=Mode, use_silver=UseSilver, use_silver_bind=UseSilverBind, time_hour=OldHour, mapid=StallMapID} = Stall,
    Stall2 = Stall#r_stall{use_silver=UseSilver+ReduceSilver, use_silver_bind=UseSilverBind+ReduceBindSilver},
    NewStall =
        case Mode of
            ?STALL_MODE_AUTO ->
                Stall2#r_stall{time_hour=OldHour+Hour*3600};
            _ ->
                db:write(?DB_ROLE_STATE, #r_role_state{role_id=RoleID}, write),
                Stall2#r_stall{mode=?STALL_MODE_AUTO, time_hour=Hour*3600,                
                               start_time=common_tool:now(), remain_time=Hour*3600}
        end,
    db:write(?DB_STALL, NewStall, write),
    %%构造一个摆摊基本信息作为返回值
    { Mode,  NewStall, StallMapID, ReduceSilver, ReduceBindSilver}.

%% @doc 处理自动摆摊的过期
do_time_over(RoleID) ->
    case db:transaction(
           fun() ->
                   t_do_time_over(RoleID)
           end)
    of
        {atomic, {Mode,RoleName}} ->
            %%清掉定时
            case get({?DICT_KEY_TIMEREF, RoleID}) of
                undefined ->
                    ok;

                {T1, T2} ->
                    erlang:cancel_timer(T2),
                    case T1 =:= undefined of
                        true ->
                            ignore;
                        _ ->
                            erlang:cancel_timer(T1)
                    end
            end,
            erase({?DICT_KEY_TIMEREF, RoleID}),
            %% 恢复角色状态
            case Mode of
                ?STALL_MODE_AUTO ->
                    ok;
                _ ->
                    mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.state, ?ROLE_STATE_NORMAL}], mgeem_map:get_state())
            end,
            %%消息通知地图进程某个摆摊结束了
            %%RB = #m_stall_finish_toc{return_self=false, role_id=RoleID},
            RSelf = #m_stall_finish_toc{time_over=true},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?STALL, ?STALL_FINISH, RSelf),
            %% 通知地图清掉摊位
            %%mod_map_stall:handle_info({stall_finish, TX, TY, RoleID, RoleName, StallName, Mode, RB}),
            notify_finish(RoleID, RoleName),
            %% 清除市场列表
            StallGoodsList = db:dirty_match_object(?DB_STALL_GOODS, #r_stall_goods{role_id=RoleID, _='_'}),
            mod_stall_list:stall_list_delete(StallGoodsList),
            ok;
        {aborted, Reason} when is_binary(Reason) ->
            {error, Reason};
        {aborted, Reason} ->
            ?ERROR_MSG("do_kick_role_stall, reaosn: ~w", [Reason]),
            {error, ?_LANG_SYSTEM_ERROR}
    end.

t_do_time_over(RoleID) ->
    case db:read(?DB_STALL, RoleID, write) of
        [] ->
            db:abort(?_LANG_STALL_NOT_STALL);
        [StallDetail] ->
            #r_stall{mode=Mode, role_name=RoleName, remain_time=RemainTime} = StallDetail,
            StallDetail2 = StallDetail#r_stall{mode=?STALL_MODE_AUTO, start_time=0, time_hour=0, remain_time=0},
            case Mode of
                ?STALL_MODE_AUTO ->
                    case RemainTime =:= 0 of
                        true ->
                            db:abort(?_LANG_STALL_HAS_FINISH);
                        _ ->
                            ignore
                    end;
                _ ->
                    [RoleState] = db:read(?DB_ROLE_STATE, RoleID, write),
                    db:write(?DB_ROLE_STATE, RoleState#r_role_state{stall_self=false, stall_auto=true}, write)
            end,
            db:write(?DB_STALL, StallDetail2, write),
            {Mode, RoleName}
    end.

do_extractmoney(Unique, Module, Method, RoleID, _PID, Line) ->
    case db:transaction(fun() -> t_do_extractmoney(RoleID) end) of
        {atomic, {GetSilver, Tax, GetGold}} ->
            R = #m_stall_extractmoney_toc{silver=GetSilver, tax=Tax, gold=GetGold},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R);
        {aborted, Error} ->
            case erlang:is_binary(Error) of
                true ->
                    Reason = Error;
                false ->
                    Reason = ?_LANG_STALL_SYSTEM_ERROR
            end,
            ?ERROR_MSG("~ts:~w", ["提取摊位银两失败", Error]),
            R = #m_stall_extractmoney_toc{succ=false, reason=Reason},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R)
    end.
t_do_extractmoney(RoleID) ->
    [#r_stall_silver{get_silver=GetSilver, get_gold=GetGold}] = db:read(?DB_STALL_SILVER, RoleID, write),
    [#r_stall{mode=Mode}] = db:dirty_read(?DB_STALL, RoleID),
    Tax = calc_income_tax(Mode, GetSilver),
    %% 消费日志
    common_consume_logger:use_silver({RoleID, 0, Tax, ?CONSUME_TYPE_SILVER_STALL_TAX,
                                      ""}),

    GetSilverFinal = GetSilver - Tax,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{silver=OldSilver, gold=OldGold} = RoleAttr,
    NewRoleAttr = RoleAttr#p_role_attr{silver=OldSilver+GetSilverFinal, gold=OldGold+GetGold},
    mod_map_role:set_role_attr(RoleID,NewRoleAttr),
    db:write(?DB_STALL_SILVER, #r_stall_silver{role_id=RoleID, get_silver=0, get_gold=0}, write),
    {GetSilverFinal, Tax, GetGold}.


%%玩家的托管摆摊只剩半个小时了
do_remain_half_hour(RoleID) ->
    notify_half_hour(RoleID).


%%摆摊的事务处理过程
t_do_request(RoleID,RoleAttr,SilverCost,TimeHour)->
    #p_role_attr{silver=Silver,silver_bind=BindSilver} = RoleAttr,
    {ReduceSilver, ReduceBindSilver} = calc_reduce_silver(Silver, BindSilver, SilverCost),
    case ReduceSilver>Silver of
        true->
            db:abort({error,?_LANG_STALL_NOT_ENOUGH_SILVER});
        false->
            ignore
    end,
    NewRoleAttr = RoleAttr#p_role_attr{silver=Silver-ReduceSilver, silver_bind=BindSilver-ReduceBindSilver},
    %%消费日志
    common_consume_logger:use_silver({RoleID, ReduceBindSilver, ReduceSilver, ?CONSUME_TYPE_SILVER_FEE_BUY_ITEM_FROM_STALL,""}),

    %%放在摊位中的物品全部写到正式摆摊的表中，背包中的对应道具也必须要删除
    GoodsList = db:match_object(?DB_STALL_GOODS_TMP, #r_stall_goods{role_id=RoleID, _='_'}, write),
    case erlang:length(GoodsList) > 0 of
        true ->
            GoodsList2 =
                lists:foldl(
                  fun(GoodsOne, Acc) ->
                          Goods = GoodsOne#r_stall_goods.goods_detail,
                          #p_goods{id=GoodsID, bagid=_BagID, bagposition=_BagPos} = Goods,
                          db:delete(?DB_STALL_GOODS_TMP, GoodsOne#r_stall_goods.id, write),

                          %%由于很多地方没做使用的限制，正式摆摊的时候还要确定物品是否还存在
                          case mod_bag:check_inbag(RoleID, GoodsID) of
                              {ok, GoodsInfo} ->
                                  mod_bag:delete_goods(RoleID, GoodsID),
                                  GoodsOne2 = GoodsOne#r_stall_goods{goods_detail=GoodsInfo},
                                  db:write(?DB_STALL_GOODS, GoodsOne2, write),
                                  [GoodsOne2|Acc];
                              {error, _} ->
                                  Acc
                          end
                  end, [], GoodsList),

            case erlang:length(GoodsList2) > 0 of
                true ->
                    %%写入数据
                    #p_map_role{faction_id=FactionID}=mod_map_actor:get_actor_mapinfo(RoleID, role),

                    StallMapID = common_misc:get_home_map_id(FactionID),
                    db:write(?DB_STALL, #r_stall{role_id=RoleID, start_time=common_tool:now(), 
                                                      mode=?STALL_MODE_AUTO, time_hour=TimeHour*3600, name="",
                                                      role_name=RoleAttr#p_role_attr.role_name,
                                                      remain_time=TimeHour*3600, mapid=StallMapID,
                                                      use_silver=ReduceSilver, use_silver_bind=ReduceBindSilver}, write),
                    db:write(?DB_STALL_SILVER, #r_stall_silver{role_id=RoleID, get_silver=0, get_gold=0}, write),
                    mod_map_role:set_role_attr(RoleID,NewRoleAttr),
                    {TimeHour, TimeHour*3600, GoodsList, RoleID, ReduceSilver, ReduceBindSilver, GoodsList2};
                _ ->
                    db:abort({error, ?_LANG_STALL_NO_GOODS_IN_STALL})
            end;

        false ->
            db:abort({error,?_LANG_STALL_NO_GOODS_IN_STALL})
    end.


do_move(Unique, Module, Method, DataIn, RoleID, Line) ->
    #m_stall_move_tos{goodsid = GoodsID, pos = Pos} = DataIn,
    case db:transaction(
           fun() ->
                   t_do_move(RoleID, GoodsID, Pos)
           end)
    of
        {atomic, _} ->
            DataRecord = #m_stall_move_toc{succ=true},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord);
        {aborted, Reason} ->
            ?ERROR_MSG("mod_stall, do_move, error: ~w", [Reason]),
            do_move_error(Unique, Module, Method, RoleID, ?_LANG_SYSTEM_ERROR, Line)
    end.

do_move_error(Unique, Module, Method, RoleID, Reason, Line) ->
    DataRecord = #m_stall_move_toc{succ = false, reason = Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

%% @doc 摆摊状态，用于打开背包时请求当前摆摊状态
%% stallstate: 0、未摆摊，1、摆摊中，2、过期
do_state(Unique, Module, Method, RoleID, PID) ->
    case db:dirty_read(?DB_STALL, RoleID) of
        [] ->
            StallState = 0;
        [StallInfo] ->
            #r_stall{mode=Mode, remain_time=RemainTime} = StallInfo,
            case Mode =:= ?STALL_MODE_AUTO andalso RemainTime =:= 0 of
                true ->
                    StallState = 2;
                _ ->
                    StallState = 1
            end
    end,

    DataRecord = #m_stall_state_toc{stall_state=StallState},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord),
    ok.

do_list(Unique, Module, Method, DataIn, _RoleID, PID) ->
    SortType = get_sort_type(DataIn),
    {ok, MaxPage, GoodsList} = mod_stall_list:stall_list_get(SortType),
    DataRecord = #m_stall_list_toc{type=DataIn#m_stall_list_tos.type,
                                   page=DataIn#m_stall_list_tos.page,
                                   typeid=DataIn#m_stall_list_tos.typeid,
                                   sort_type=DataIn#m_stall_list_tos.sort_type,
                                   is_reverse=DataIn#m_stall_list_tos.is_reverse,
                                   is_gold_first=DataIn#m_stall_list_tos.is_gold_first,
                                   min_level=DataIn#m_stall_list_tos.min_level,
                                   max_level=DataIn#m_stall_list_tos.max_level,
                                   color=DataIn#m_stall_list_tos.color,
                                   pro=DataIn#m_stall_list_tos.pro,
                                   goods_list=GoodsList,
                                   max_page=MaxPage},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

get_sort_type(DataIn) ->
    if DataIn#m_stall_list_tos.min_level =:= 0 andalso DataIn#m_stall_list_tos.max_level =:= 0 ->
            MinLevel = undefined,
            MaxLevel = undefined;
       true ->
            MinLevel = DataIn#m_stall_list_tos.min_level,
            MaxLevel = DataIn#m_stall_list_tos.max_level
    end,
    if DataIn#m_stall_list_tos.color =:= 0 ->
            Color = undefined;
       true ->
            Color = DataIn#m_stall_list_tos.color
    end,
    if DataIn#m_stall_list_tos.pro =:= 0 ->
            Pro = undefined;
       true ->
            Pro = DataIn#m_stall_list_tos.pro
    end,
    if DataIn#m_stall_list_tos.sort_type =/= ?SORT_TYPE_PRICE ->
            GoldFirst = undefined;
       true ->
            GoldFirst = DataIn#m_stall_list_tos.is_gold_first
    end,
    if DataIn#m_stall_list_tos.typeid =:= [] andalso DataIn#m_stall_list_tos.type =:= 0 ->
            TypeIdList = undefined,
            Category = undefined;
       DataIn#m_stall_list_tos.typeid =:= [] ->
            TypeIdList = undefined,
            Category = DataIn#m_stall_list_tos.type;
       true ->
            TypeIdList = DataIn#m_stall_list_tos.typeid,
            Category = undefined
    end,
    if DataIn#m_stall_list_tos.page =:= 0 ->
            Page = 1;
       true ->
            Page = DataIn#m_stall_list_tos.page
    end,
    #r_sort_type{category=Category, typeid=TypeIdList, sort_type=DataIn#m_stall_list_tos.sort_type,
                 gold_first=GoldFirst, min_level=MinLevel, max_level=MaxLevel, color=Color,
                 pro=Pro, page=Page, is_reverse=DataIn#m_stall_list_tos.is_reverse}.

t_do_move(RoleID, GoodsID, Pos) ->
    case db:read(?DB_STALL_GOODS_TMP, {RoleID, GoodsID}, write) of
        [StallGoods] ->
            NewGoods = StallGoods#r_stall_goods{pos=Pos},
            db:write(?DB_STALL_GOODS_TMP, NewGoods, write);
        [] ->
            [StallGoods] = db:read(?DB_STALL_GOODS, {RoleID, GoodsID}, write),
            NewGoods = StallGoods#r_stall_goods{pos=Pos},
            db:write(?DB_STALL_GOODS, NewGoods, write)
    end.

%%根据玩家的摆摊模式获得新的玩家状态
%% get_new_state_by_mode(Mode, RoleID) ->
%%     case Mode of
%%         ?STALL_MODE_SELF ->
%%             #r_role_state{role_id=RoleID, stall_self=true};
%%         ?STALL_MODE_AUTO ->
%%             #r_role_state{role_id=RoleID, stall_auto=true}
%%     end.
%% 
%% 
%% %%获得摆摊所需要的银两
%% get_silver(Mode, TimeHour) ->
%%     case Mode of
%%         ?STALL_MODE_AUTO ->
%%             TimeHour * ?STALL_AUTO_SILVER_PER_HOUR + ?STALL_BASE_TAX;
%%         ?STALL_MODE_SELF ->
%%             ?STALL_BASE_TAX
%%     end.
%% 
%% 
%% %%过滤玩家传递过来的摆摊模式参数
%% filter_mode(Mode) ->
%%     case Mode of
%%         ?STALL_MODE_SELF ->
%%             ?STALL_MODE_SELF;
%%         _ ->
%%             ?STALL_MODE_AUTO
%%     end.
%%     
%% check_name(_Name) ->
%%     ok.

%%系统初始化时需要扫描db_stall表，把自动摆摊的都拉出来放在地图上
do_init_stall() ->
    case db:transaction(fun() -> t_do_init_stall() end) of
        {atomic, Result} ->
            ?DEBUG("~ts:~w", ["初始化摊位列表成功", Result]),
            ok;
        {aborted, ErrorInfo} ->
            ?ERROR_MSG("~ts:~w", ["初始化摊位列表失败", ErrorInfo]),
            error
    end,
    
    #map_state{mapid=MapID} = mgeem_map:get_state(),
    do_finish_exception_stall(MapID).
t_do_init_stall() ->                       
    MapState = mgeem_map:get_state(),
    StallList = db:match_object(?DB_STALL, #r_stall{mapid=MapState#map_state.mapid, mode=?STALL_MODE_AUTO, _='_'}, read),
    Now = common_tool:now(),
    lists:foreach(
      fun(Stall) ->
              #r_stall{role_id=RoleID, time_hour=_TimeHour,remain_time=RemainTime} = Stall,
              %%判断是否已经过期了
              case RemainTime > 0 of
                  true ->
                      %%更新时间
                      db:write(?DB_STALL, Stall#r_stall{start_time=Now, time_hour=RemainTime}, write),
                      %%通知地图摆摊
                      %%mod_map_stall:handle_info({stall_sure, TX, TY, RoleID, RoleName, Name, Mode}),
                      EtsLogName = get_ets_stall_log(),
                      ets:insert(EtsLogName, {RoleID, [], []}),
                      %%提前半个小时提醒玩家
                      case RemainTime > 1800 of
                          true ->
                              TimeRef = erlang:send_after((RemainTime-1800)*1000, self(), {mod_stall, {auto_stall_remain_half_hour, RoleID}});
                          _ ->
                              TimeRef = undefined
                      end,
                      %%时间到了自动过期，不收摊，但是要提取出银两
                      TimeRef2 = erlang:send_after(RemainTime*1000, self(), {mod_stall, {auto_stall_time_over, RoleID}}),
                      put({?DICT_KEY_TIMEREF, RoleID}, {TimeRef, TimeRef2});
                  false ->
                      ignore
              end
      end, StallList).

%%处理玩家下线
do_role_offline(RoleID) ->
    do_terminate2(RoleID).

%%处理异常的没有、结束的摊位
do_finish_exception_stall(MapID) ->
    case db:dirty_match_object(?DB_STALL, #r_stall{mode=?STALL_MODE_SELF, mapid=MapID, _='_'}) of
        [] ->
            ok;
        StallLists ->
            ?DEBUG("~ts:~w", ["异常摊位列表", StallLists]),
            lists:foreach(
              fun(Stall) ->
                      RoleID = Stall#r_stall.role_id,
                      do_finish_exception_stall2(RoleID)
              end, StallLists)
    end.

%% 处理异常退出的摊位，在地图挂掉的时候会有一次处理，不过有可能出现失败的情况，有可能是因为玩家背包已满
%% 这里仅将所有异常的摊位都当做是过期。。。
do_finish_exception_stall2(RoleID) ->
    case db:transaction(
           fun() ->
                   t_do_finish_exception_stall(RoleID)
           end)
    of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("do_finish_exception_stall2, error: ~w", [Error])
    end.

t_do_finish_exception_stall(RoleID) ->
    [Stall] = db:read(?DB_STALL, RoleID, write),
    #r_stall{mode=Mode} = Stall,

    case Mode of
        ?STALL_MODE_AUTO ->
            ok;
        _ ->
            NewStall = Stall#r_stall{mode=?STALL_MODE_AUTO, start_time=0, time_hour=0,
                                     remain_time=0},
            db:write(?DB_STALL, NewStall, write),
            db:write(?DB_ROLE_STATE, #r_role_state{role_id=RoleID, stall_auto=true}, write)
    end.

t_do_terminate(RoleID) ->
    [Stall] = db:read(?DB_STALL, RoleID, write),
    #r_stall{mode=Mode, start_time=StartTime, tx=TX, ty=TY, name=Name,
             remain_time=RemainTime, time_hour=TimeHour} = Stall,
    ?DEBUG("~ts:~w", ["玩家摊位信息", Stall]),
    %%如果是托管模式摆摊，计算剩余时间是多少
    case Mode of
        ?STALL_MODE_AUTO ->
            case RemainTime of
                0 ->
                    ok;
                _ ->
                    RemainTime2 = TimeHour - (common_tool:now()-StartTime),
                    NewStall = Stall#r_stall{remain_time=RemainTime2},
                    db:write(?DB_STALL, NewStall, write),
                    ok
            end;
        _ ->   %%% 这个分支进不来
            %%返回玩家所获得的银两
            [#r_stall_silver{get_silver=GetSilver, get_gold=GetGold}] = db:read(?DB_STALL_SILVER, RoleID, write),
            %%计算个人所得税
            TaxIncome = calc_income_tax(Mode, GetSilver),
            GetSilverFinal = GetSilver - TaxIncome,
            %%从摊位中取出所有的该玩家的物品，写入到背包中去
            StallGoodsList = db:match_object(?DB_STALL_GOODS, #r_stall_goods{role_id=RoleID, _='_'}, write),
            GoodsList =
                lists:foldl(
                  fun(StallGoods, Acc) ->
                          #r_stall_goods{goods_detail=Goods} = StallGoods,
                          Goods2 = Goods#p_goods{state=?GOODS_STATE_NORMAL},
                          [Goods2|Acc]
                  end, [], StallGoodsList),
            
            {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
            RoleName = RoleAttr#p_role_attr.role_name,
            
            %% 把玩家状态设置为正常
            [RoleState] = db:read(?DB_ROLE_STATE, RoleID),
            db:write(?DB_ROLE_STATE, RoleState#r_role_state{stall_self=false}, write),

            try
                mod_bag:create_goods_by_p_goods_and_id(RoleID, GoodsList),
                lists:foreach(fun(StallGoods) -> db:delete(?DB_STALL_GOODS, StallGoods#r_stall_goods.id, write) end, StallGoodsList),
                db:write(?DB_ROLE_STATE, #r_role_state{role_id=RoleID, normal=true}, write),
                db:delete(?DB_STALL, RoleID, write),
                db:delete(?DB_STALL_SILVER, RoleID, write),

                #p_role_attr{silver=OldSilver, gold=OldGold} = RoleAttr,
                mod_map_role:set_role_attr(RoleID,RoleAttr#p_role_attr{silver=OldSilver+GetSilverFinal, gold=OldGold+GetGold}),          
                {TX, TY, RoleName, Name, Mode, GetSilverFinal, TaxIncome, GoodsList, false, GetGold, StallGoodsList}
            catch
                _:_ ->
                    NewStall = Stall#r_stall{mode=?STALL_MODE_AUTO, start_time=0, time_hour=0,
                                             remain_time=0},
                    db:write(?DB_STALL, NewStall, write),
                    db:write(?DB_ROLE_STATE, #r_role_state{role_id=RoleID, stall_auto=true}, write),
                    {TX, TY, RoleName, Name, Mode, 0, 0, [], true, 0, []}
            end
    end.

%%计算个人所得税
calc_income_tax(Mode, GetSilver) ->
    case GetSilver > 0 of
        true ->
            case Mode of
                ?STALL_MODE_AUTO ->
                    common_tool:ceil(GetSilver*?AUTO_STALL_INCOME_TAX_RATE);
                _ ->
                    common_tool:ceil(GetSilver*?SELF_STALL_INCOME_TAX_RATE)
            end;
        false ->
            0
    end.

%%计算自动摆摊的剩余时间
get_remain_time(Mode, StartTime, TimeHour) ->
    case Mode of
        ?STALL_MODE_AUTO ->
            Now = common_tool:now(),
            TimeHour - (Now - StartTime);
        _ ->
            0
    end.


%%通知某个玩家托管摆摊还剩半个小时了
notify_half_hour(RoleID) ->
    case mod_map_role:get_role_base(RoleID) of
        {error, _} ->
            ok;
        {ok, RoleBase} ->
            RoleName = RoleBase#p_role_base.role_name,
            Text = common_letter:create_temp(?STALL_HALF_TIME_LETTER,[RoleName]),
            common_letter:sys2p(RoleID,Text,"委托摊位即将过期通知", 14) 
    end.

%%通知玩家摊位结束了
notify_finish(RoleID, RoleName) ->
    Text = common_letter:create_temp(?STALL_TIME_UP_LETTER,[RoleName]),  
    common_letter:sys2p(RoleID, Text, "委托摊位过期通知", 14).

%%收摊时判断应该退回多少托管费
get_return_back_silver(Mode, StartTime, TimeHour) ->
    case Mode of
        ?STALL_MODE_AUTO ->
            T = common_tool:now()-StartTime,
            TDiff = (TimeHour - T) / 3600,
            case TDiff > 1 of
                true ->
                    (common_tool:ceil(TDiff) - 1) * ?STALL_AUTO_SILVER_PER_HOUR;
                false ->
                    0
            end;
        _ ->
            0
    end.

%%获得玩家放在摊位中的物品（无论是否处于摆摊状态）
get_dirty_stall_goods(RoleID) ->
    %%脏读出玩家在摊位中的所有物品，因为无论玩家是否处于摆摊状态，这个数据都是需要被读取的
    case db:dirty_match_object(?DB_STALL_GOODS, #r_stall_goods{role_id=RoleID, _ = '_'}) of

        [] ->
            %%脏读出 db_stall_goods_tmp表中的数据
            case db:dirty_match_object(?DB_STALL_GOODS_TMP, #r_stall_goods{role_id=RoleID, _='_'}) of
                [] ->
                    [];
                StallGoods ->
                    sys_stall_bag(RoleID, StallGoods)
            end;
        StallGoods ->
            lists:map(
              fun(StallOne) ->
                      #r_stall_goods{stall_price=Price, price_type=PriceType, pos=Pos, goods_detail=GoodsDetail} = StallOne,
                      #p_stall_goods{goods=GoodsDetail, price=Price, pos=Pos, price_type=PriceType}
              end, StallGoods)
    end.

calc_reduce_silver(_Silver, BindSilver, SilverNeed) ->
    case BindSilver >= SilverNeed of
        true ->
            {0, SilverNeed};
        _ ->
            Rest = SilverNeed - BindSilver,
            {Rest, BindSilver}
    end.

%% @doc 计算返还的绑定及不绑定银两
calc_return_silver(0, 0, SilverRet) ->
    {SilverRet, 0};
calc_return_silver(Silver, BindSilver, SilverRet) ->
    SilverUse = Silver + BindSilver - SilverRet,
    case BindSilver >= SilverUse of
        true ->
            {Silver, BindSilver-SilverUse};
        _ ->
            Rest = SilverUse - BindSilver,
            {Silver-Rest, 0}
    end.

%% %%检查玩家的基本属性是否满足摆摊条件:等级、银子、战斗状态
%% check_role_condition(RoleAttr) ->
%%     case common_misc:is_role_fighting(RoleAttr#p_role_attr.role_id) of
%%         false ->
%%             check_role_condition2(RoleAttr);
%%         true ->
%%             {error, ?_LANG_STALL_CANNT_STALL_WHEN_FIGHTING}
%%     end.
check_role_condition2(RoleAttr) ->
    #p_role_attr{level=Level, silver=Silver, silver_bind=SilverBind} = RoleAttr,
    case Level >= ?STALL_MIN_LEVEL of
        true ->
            case Silver+SilverBind >= ?STALL_BASE_TAX of
                true ->
                    ok;
                false ->
                    {error, ?_LANG_STALL_NOT_ENOUGH_SILVER}
            end;
        false ->
            {error, ?_LANG_STALL_LEVEL_NOT_ENOUGH}
    end.
%% 
%% %%检查当前位置能不能摆摊，包括对摆摊空间的检查
%% check_pos_can_stall(TX, TY) ->
%%     case if_pos_can_stall(TX, TY) of
%%         true ->
%%             case check_space_around(TX, TY) of
%%                 true ->
%%                     ok;
%%                 false ->
%%                     {error, ?_LANG_STALL_AROUND_HAS_STALL}
%%             end;
%%         _ ->
%%             {error, ?_LANG_STALL_CANNOT_STALL}
%%     end.
%% 
%% 
%% %%检查当前点能否摆摊
%% if_pos_can_stall(TX, TY) ->
%%     get({can_stall, TX, TY}).
%% 
%%         
%% %%检查一个点周围是否有空间摆摊
%% check_space_around(TX, TY) ->
%%     List = get_around_txty(TX, TY),
%%     lists:foldl(
%%       fun({X, Y}, Acc) ->
%%               case check_point(X, Y) of
%%                   false ->
%%                       Acc;
%%                   true ->
%%                       false
%%               end
%%       end,
%%       true, List).
%% 
%% 
%% %%获得以一个格子为中心的9个格子
%% get_around_txty(TX, TY) ->
%%     BeginX = TX - 1,
%%     EndX = TX + 1,
%%     BeginY = TY - 1,
%%     EndY = TY + 1,
%%     lists:foldl(
%%       fun(X, Acc) ->
%%               lists:foldl(
%%                 fun(Y, AccSub) ->
%%                         [{X, Y} | AccSub]
%%                 end, Acc, lists:seq(BeginY, EndY))
%%       end, [], lists:seq(BeginX, EndX)).
%% 
%% %%检查某个点是否有摊位或者摊位标志
%% check_point(X, Y) ->
%%     case get({stall, {X, Y}}) of
%%         undefined ->
%%             false;
%%         _ ->
%%             true
%%     end.

%%处理摆摊请求错误
do_request_error(Unique, Module, Method, Reason, _RoleID, PID, _Line) ->
    R = #m_stall_request_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, R).

%% 同步摊位跟背包里面的物品
sys_stall_bag(RoleID, StallGoods) ->
    lists:foldl(
      fun(StallOne, Acc) ->
              #r_stall_goods{stall_price=Price, price_type=PriceType, pos=Pos, goods_detail=GoodsDetail} = StallOne,
              GoodsID = GoodsDetail#p_goods.id,

              case mod_bag:check_inbag(RoleID, GoodsID) of
                  {ok, GoodsInfo} ->
                      PStallGoods = #p_stall_goods{goods=GoodsInfo, price=Price, pos=Pos, price_type=PriceType},
                      [PStallGoods | Acc];
                  {error, _} ->
                      db:dirty_delete(?DB_STALL_GOODS_TMP, GoodsID),
                      Acc
              end
      end, [], StallGoods).

get_ets_stall_log() ->
    get(ets_stall_log).


%% @doc 道具使用日志
item_logger_insert(RoleID, GoodsList, LogAction) ->
    lists:foreach(
      fun(Goods) ->
              common_item_logger:log(RoleID,Goods,LogAction),
              ok
      end, GoodsList).

do_stall_init(RoleID)->
    EtsLogName = get_ets_stall_log(),
    ets:insert(EtsLogName, {RoleID, [], []}).

%% @doc 摊位结束
do_stall_finish(RoleID) ->
    %%删掉日志
    EtsLogName = get_ets_stall_log(),
    ets:delete(EtsLogName, RoleID),
    %%消息通知地图模块，某个摊位结束了
    %%RB = #m_stall_finish_toc{return_self=false, role_id=RoleID},
    %%mod_map_stall:handle_info({stall_finish, TX, TY, RoleID, RoleName, Name, Mode, RB}),
    %%清掉定时
    case get({?DICT_KEY_TIMEREF, RoleID}) of
        undefined ->
            ok;
        {T1, T2} ->
            erlang:cancel_timer(T2),
            case T1 =:= undefined of
                true ->
                    ignore;
                _ ->
                    erlang:cancel_timer(T1)
            end
    end,
    erase({?DICT_KEY_TIMEREF, RoleID}).

%% @doc 插入购买日志
do_insert_buy_log(TargetRoleID, NewLog) ->
    EtsLogName = get_ets_stall_log(),
    [{TargetRoleID, OldBuyLogs, ChatLogs}] = ets:lookup(EtsLogName, TargetRoleID),
    %%判断聊天记录是否已经达到最大条数限制了
    case erlang:length(OldBuyLogs) >= ?STALL_CHAT_LOGS_MAX_NUM of
        true ->
            [_|OldBuyLogsT] = OldBuyLogs,
            NewBuyLogs = lists:reverse([NewLog | lists:reverse(OldBuyLogsT)]);
        false ->
            NewBuyLogs = lists:reverse([NewLog | lists:reverse(OldBuyLogs)])
    end,
    ets:insert(EtsLogName, {TargetRoleID, NewBuyLogs, ChatLogs}).

do_stall_employ(RoleID, StartTime, TimeHour) ->
    %%需要通知地图更新一下摊位的基本信息，同时广播告诉周围的玩家
    %%mod_map_stall:handle_info({stall_update, TX, TY, RoleID, RoleName, ?STALL_MODE_AUTO, Name, Mode}),

    case get({?DICT_KEY_TIMEREF, RoleID}) of
        undefined ->
            ok;
        {T1, T2} ->
            erlang:cancel_timer(T2),
            case T1 =:= undefined of
                true ->
                    ignore;
                _ ->
                    erlang:cancel_timer(T1)
            end
    end,
    RemainTime = get_remain_time(?STALL_MODE_AUTO, StartTime, TimeHour),
    %%提前半个小时提醒玩家
    TimeRef = erlang:send_after((RemainTime-1800)*1000, self(), {mod_stall, {auto_stall_remain_half_hour, RoleID}}),
    %% %%时间到了自动过期，不收摊，但是要提取出银两
    TimeRef2 = erlang:send_after(RemainTime*1000, self(), {mod_stall, {auto_stall_time_over, RoleID}}),
    put({?DICT_KEY_TIMEREF, RoleID}, {TimeRef, TimeRef2}).
