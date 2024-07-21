%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com (C) 2011, 
%%% @doc
%%% 天工炉天工开物功能代码模块
%%% @end
%%% Created : 31 May 2011 by  <caochuncheng2002@gmail.com>
%%%-------------------------------------------------------------------
-module(mod_refining_box).

%% INCLUDE
-include("mgeem.hrl").
-include("refining.hrl").
-include("equip.hrl").

%% API
-export([do_handle_info/1]).

-export([init_role_refining_box_info/2,
         get_role_refining_box_info/1,
         erase_role_refining_box_info/1]).

%% @doc 初始化角色refining box信息
init_role_refining_box_info(RoleId, RefiningBoxInfo) ->
    case RefiningBoxInfo of
        undefined ->
            ignore;
        _ ->
            erlang:put({?role_refining_box, RoleId}, RefiningBoxInfo)
    end.
%% @doc 获取角色refining box信息
get_role_refining_box_info(RoleId) ->
    case erlang:get({?role_refining_box, RoleId}) of
        undefined ->
            {error, not_found};
        RefiningBoxInfo ->
            {ok,RefiningBoxInfo}
    end.
%% @doc 清除角色refining box信息
erase_role_refining_box_info(RoleId) ->
    case get_role_refining_box_info(RoleId) of
        {ok, RefiningBoxInfo} ->
            mgeem_persistent:role_refining_box_persistent(RefiningBoxInfo),
            erlang:erase({?role_refining_box, RoleId});
        _ ->
            ignore
    end.

%% @doc 设置角色refining box信息
t_set_role_refining_box_info(RoleId, RefiningBoxInfo) ->
    mod_map_role:update_role_id_list_in_transaction(RoleId, ?role_refining_box, ?role_refining_box_copy),
    erlang:put({?role_refining_box, RoleId}, RefiningBoxInfo).

%% @doc 设置角色refining box信息
set_role_refining_box_info(RoleId, RefiningBoxInfo) ->
    case common_transaction:transaction(
           fun() ->
                   t_set_role_refining_box_info(RoleId,RefiningBoxInfo)
           end)
    of
        {atomic, _} ->
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("set_role_refining_box_info, error: ~w", [Error]),
            error
    end.

%% 天工炉功能处理
do_handle_info({Unique, ?REFINING, ?REFINING_BOX, DataRecord, RoleId, PId, Line}) ->
    do_refining_box({Unique, ?REFINING, ?REFINING_BOX, DataRecord, RoleId, PId, Line});

%% 天工开物功能配置变化，需要通知当前在线玩家
do_handle_info({box_fun_config_change}) ->
    do_box_fun_config_change();

do_handle_info(Info) ->
    ?ERROR_MSG("~ts,Info=~w",["天工炉模块无法处理此消息",Info]),
    error.

%% DataRecord 结构为 m_refining_box_tos
do_refining_box({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    #m_refining_box_tos{op_type = OpType} = DataRecord,
    case OpType of
        ?BOX_OP_TYPE_FUN -> %% 查询天工开物信息
            do_refining_box_fun({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?BOX_OP_TYPE_SUB_FUN -> %% 查询天工开物功能信息 只查询或通知通前端箱子功能开放信息
            do_refining_box_sub_fun({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?BOX_OP_TYPE_OPEN -> %% 开箱子
            do_refining_box_open({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?BOX_OP_TYPE_OPEN_AUTO -> %% 开箱子并自动放置物品
            do_refining_box_open({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?BOX_OP_TYPE_RESTORE -> %% 放置物品
            do_refining_box_restore({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?BOX_OP_TYPE_QUERY -> %% 查询放置物品
            do_refining_box_query({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?BOX_OP_TYPE_GET -> %% 提取物品
            do_refining_box_get({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?BOX_OP_TYPE_SALE -> %% 出售物品
            do_refining_box_sale({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?BOX_OP_TYPE_DESTROY -> %% 销毁物品
            do_refining_box_destory({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?BOX_OP_TYPE_INBAG -> %% 直接提取物品到背包
            do_refining_box_inbag({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        ?BOX_OP_TYPE_MERGE -> %% 整理宝物空间物品接口
            do_refining_box_merge({Unique, Module, Method, DataRecord, RoleId, PId, Line});
        _ ->
            Reason = ?_LANG_BOX_OP_TYPE_ERROR,
            do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId},Reason,0)
    end.
do_refining_box_error({Unique, Module, Method, DataRecord, _RoleId, PId, _Line},Reason,ReasonCode) ->
    SendSelf = #m_refining_box_toc{
      succ = false,
      reason = Reason,
      reason_code = ReasonCode,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = DataRecord#m_refining_box_tos.page_no,
      page_type = DataRecord#m_refining_box_tos.page_type},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).

%% 天工开物功能配置变化，需要通知当前在线玩家
do_box_fun_config_change() ->
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = ?BOX_OP_TYPE_SUB_FUN,
      goods_ids = [],
      is_open = IsBoxOpen,
      is_free = IsBoxFree},
    ?DEBUG("~ts,SendSelf=~w",["天工开物配置修改通知消息",SendSelf]),
    catch common_misc:chat_broadcast_to_world(?REFINING,?REFINING_BOX,SendSelf),
    ok.


%% 查询天工开物功能信息 只查询或通知通前端箱子功能开放信息
do_refining_box_sub_fun({Unique, Module, Method, DataRecord, _RoleId, PId, _Line}) ->
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = DataRecord#m_refining_box_tos.page_no,
      page_type = DataRecord#m_refining_box_tos.page_type,
      is_open = IsBoxOpen,
      is_free = IsBoxFree},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.

%% 查询天工开物信息
do_refining_box_fun({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_box_fun2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,MapRoleInfo} ->
            do_refining_box_fun3({Unique, Module, Method, DataRecord, RoleId, PId, Line},MapRoleInfo)
    end.
do_refining_box_fun2(RoleId,_DataRecord) ->
    MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(RoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0})
    end,
    {ok,MapRoleInfo}.
do_refining_box_fun3({Unique, Module, Method, DataRecord, RoleId, PId, Line},MapRoleInfo) ->
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    case IsBoxOpen of
        false -> %% 功能关闭
            SendSelf = #m_refining_box_toc{
              succ = true,
              op_type = DataRecord#m_refining_box_tos.op_type,
              op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
              goods_ids = DataRecord#m_refining_box_tos.goods_ids,
              page_no = DataRecord#m_refining_box_tos.page_no,
              page_type = DataRecord#m_refining_box_tos.page_type,
              is_open = IsBoxOpen,
              is_free = false},
            ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
            common_misc:unicast2(PId, Unique, Module, Method, SendSelf);
        _ ->
            do_refining_box_fun4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                 MapRoleInfo,IsBoxOpen)
    end.
do_refining_box_fun4({Unique, Module, Method, DataRecord, RoleId, PId, _Line},
                     MapRoleInfo,IsBoxOpen) ->
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    %% 判断是否需要产生箱子物品
    NowSeconds = common_tool:now(),
    [MaxKeepTime] = common_config_dyn:find(refining_box,max_keep_time),
    RoleBox = 
        case get_role_refining_box_info(RoleId) of
            {ok,RoleBoxT} ->
                RoleBoxT;
            _ ->
                %% 以当前时间开始创建箱子记录
                NewRoleBox = #r_role_box{
                  role_id = RoleId,
                  faction_id = MapRoleInfo#p_map_role.faction_id,
                  start_time = NowSeconds,
                  end_time = 0,
                  fee_flag =?BOX_FEE_FLAG_0,  
                  is_generate = ?BOX_IS_GENERATE_0,
                  cur_list = [],bc_list = [],
                  all_list = [],free_times = 0,
                  log_list = [],fee_times = 0},
                set_role_refining_box_info(RoleId, NewRoleBox),
                NewRoleBox
        end,
    #r_role_box{end_time = EndTime,is_generate = IsGenerate,fee_flag = FeeFlag,cur_list = CurList} = RoleBox,
    RoleBox2 = 
        case NowSeconds > EndTime 
            andalso (FeeFlag =:= ?BOX_FEE_FLAG_0 
                     orelse (IsGenerate =:= ?BOX_IS_GENERATE_0 andalso FeeFlag =:= ?BOX_FEE_FLAG_1 andalso CurList =:= [])) of
            true -> %% 时间到了，需要生居箱子物品
                {ok,CurBoxGoodsList,CurBcList} = generate_box_goods(RoleId,?BOX_FEE_TYPE_0,?BOX_USE_GOLD_0),
                RoleBox2T = RoleBox#r_role_box{
                              free_times = RoleBox#r_role_box.free_times + 1,
                              start_time = NowSeconds,
                              end_time = NowSeconds + MaxKeepTime,
                              is_generate = ?BOX_IS_GENERATE_1,
                              fee_flag = ?BOX_FEE_FLAG_0,
                              cur_list = CurBoxGoodsList,
                              bc_list = CurBcList},
                set_role_refining_box_info(RoleId, RoleBox2T),
                RoleBox2T;
            _ ->
                RoleBox
        end,
    AwardStatus = 
        case RoleBox2#r_role_box.cur_list =/= []  of
            true ->
                1;
            _ ->
                0
        end,
    %% 获得玩家开箱子日志
    BoxSelfLogList = get_self_box_log(RoleBox2#r_role_box.log_list),
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = DataRecord#m_refining_box_tos.page_no,
      page_type = DataRecord#m_refining_box_tos.page_type,
      is_open = IsBoxOpen,
      is_free = IsBoxFree,
      award_time = RoleBox2#r_role_box.end_time,
      generate_type = RoleBox2#r_role_box.fee_flag,
      is_restore = RoleBox2#r_role_box.is_restore,
      award_status = AwardStatus, 
      cur_list = RoleBox2#r_role_box.cur_list,
      all_log_list = get_all_box_log(),
      self_log_list = BoxSelfLogList},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
%% 开箱子
do_refining_box_open({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_box_open2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,MapRoleInfo,RoleBox,BoxOpenFee} ->
            do_refining_box_open3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                  MapRoleInfo,RoleBox,BoxOpenFee)
    end.
do_refining_box_open2(RoleId,DataRecord) ->
    #m_refining_box_tos{op_fee_type = OpFeeType} = DataRecord,
    case OpFeeType =:= ?BOX_FEE_TYPE_1 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_OP_FEE_TYPE_ERROR,0})
    end,
    MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(RoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0})
    end,
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    case IsBoxOpen =:= true of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_IS_OPEN_ERROR,0})
    end,
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    case IsBoxFree of
        false ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_IS_FREE_ERROR,0})
    end,
    RoleBox = 
        case get_role_refining_box_info(RoleId) of
            {ok,RoleBoxT} ->
                RoleBoxT;
            _ ->
                erlang:throw({error,?_LANG_BOX_INIT_ERROR,0})
        end,
    case DataRecord#m_refining_box_tos.op_type =:= ?BOX_OP_TYPE_OPEN_AUTO of
        true ->
            next;
        _ ->
            case RoleBox#r_role_box.cur_list =:= [] of
                true ->
                    next;
                _ ->
                    erlang:throw({error,?_LANG_BOX_HAS_GOODS_ERROR,0})
            end
    end,
    [BoxFeeList] = common_config_dyn:find(refining_box,box_fee),
    BoxOpenFee = 
        case lists:keyfind(OpFeeType,1,BoxFeeList) of
            false ->
                erlang:throw({error,?_LANG_BOX_OP_FEE_TYPE_ERROR,0});
            {_OpFeeTypeT,BoxOpenFeeT} ->
                BoxOpenFeeT
        end,
    {ok,MapRoleInfo,RoleBox,BoxOpenFee}.
%% 正常的立即开箱子
do_refining_box_open3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                      MapRoleInfo,RoleBox,BoxOpenFee) ->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_box_open(RoleId,DataRecord,RoleBase,RoleBox,BoxOpenFee)
           end) of
        {atomic,{ok,RoleAttr,RoleBox,RoleBox2,RoleBox3,NewCurList}} ->
            do_refining_box_open4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                  MapRoleInfo,RoleBase,RoleAttr,RoleBox,RoleBox2,RoleBox3,NewCurList);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_REFINING_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_BOX_OPEN_ERROR,
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_box_open4({Unique, Module, Method, DataRecord, RoleId, PId, _Line},
                      _MapRoleInfo,RoleBase,RoleAttr,RoleBox,RoleBox2,RoleBox3,NewCurList) ->
    AwardStatus = 
        case RoleBox3#r_role_box.cur_list =/= []  of
            true ->
                1;
            _ ->
                0
        end,
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    %% 获得玩家开箱子日志,刷新并不需要获得自已的日志
    case DataRecord#m_refining_box_tos.op_type =:= ?BOX_OP_TYPE_OPEN_AUTO of
        true ->
            %% 处理所有玩家开箱子记录
            catch do_insert_box_log_all(RoleBase,RoleBox),
            catch do_insert_box_log_all(RoleBase,RoleBox2),
            BoxSelfLogList = get_self_box_log(RoleBox3#r_role_box.log_list), 
            BoxAllLogList = get_all_box_log();
        _ ->
            BoxSelfLogList = [],
            BoxAllLogList = []
    end,
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = DataRecord#m_refining_box_tos.page_no,
      page_type = DataRecord#m_refining_box_tos.page_type,
      is_open = IsBoxOpen,
      is_free = IsBoxFree,
      award_time = RoleBox3#r_role_box.end_time,
      generate_type = RoleBox3#r_role_box.fee_flag,
      is_restore = RoleBox3#r_role_box.is_restore,
      award_status = AwardStatus, 
      award_list = NewCurList,
      cur_list = RoleBox3#r_role_box.cur_list,
      all_log_list = BoxAllLogList,
      self_log_list = BoxSelfLogList},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    UnicastArg = {role, RoleId},
    AttrChangeList = [#p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value = RoleAttr#p_role_attr.gold},
                      #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value = RoleAttr#p_role_attr.gold_bind}],
    common_misc:role_attr_change_notify(UnicastArg,RoleId,AttrChangeList),
    %% 自动放置处理
    case DataRecord#m_refining_box_tos.op_type =:= ?BOX_OP_TYPE_OPEN_AUTO of
        true ->
            %% 记录日志
            lists:foreach(
              fun(BoxGoodsLog) ->
                      catch common_item_logger:log(RoleId,BoxGoodsLog,?LOG_ITEM_TYPE_BOX_RESTORE_HUO_DE)
              end,NewCurList),
            catch do_refining_box_goods_notify(RoleId,RoleBase,RoleBox2),
            ok;
        _ ->
            next
    end,
    ok.

do_t_refining_box_open(RoleId,DataRecord,RoleBase,RoleBox,BoxOpenFee) ->
    {ok,RoleBox2,AwardList} = 
        if RoleBox#r_role_box.cur_list =/= []
           andalso RoleBox#r_role_box.cur_list =/= undefined ->
                [MaxBoxGoodsNumber] = common_config_dyn:find(refining_box,max_box_goods_number),
                case MaxBoxGoodsNumber >= (erlang:length(RoleBox#r_role_box.all_list) + erlang:length(RoleBox#r_role_box.cur_list)) of
                    true ->
                        do_t_refining_box_open2(RoleBase,RoleBox);
                    _ ->
                        common_transaction:abort({?_LANG_BOX_OPEN_NO_BOX_POS,0})
                end;
           true ->
                {ok,RoleBox,[]}
        end,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
    {RoleAttr2,GoldType} = do_t_refining_box_open_fee(RoleId,RoleAttr,BoxOpenFee),
    #r_role_box{fee_times = FeeTimes} = RoleBox2,
    {ok,CurBoxGoodsList,CurBcList} = generate_box_goods(RoleId,DataRecord#m_refining_box_tos.op_fee_type,GoldType),
    RoleBox3 = RoleBox2#r_role_box{
                 fee_flag = ?BOX_FEE_FLAG_1,
                 fee_times = FeeTimes + 1,
                 is_generate = ?BOX_IS_GENERATE_1,
                 cur_list = CurBoxGoodsList,
                 bc_list = CurBcList},
    {ok,RoleBox4,AwardList2} = 
        case DataRecord#m_refining_box_tos.op_type =:= ?BOX_OP_TYPE_OPEN_AUTO of
            true -> %% 需要自动放入宝物空间
                do_t_refining_box_open2(RoleBase,RoleBox3);
            _ ->
                {ok,RoleBox3,[]}
        end,
    %% 检查系统箱子时间是否已经到了，需要更新
    NowSeconds = common_tool:now(),
    RoleBox5 = 
        case NowSeconds > RoleBox4#r_role_box.end_time andalso RoleBox4#r_role_box.cur_list =:= [] of
            true -> %% 系统自动更新时间到，需要创建物品
                [MaxKeepTime] = common_config_dyn:find(refining_box,max_keep_time),
                {ok,CurFreeBoxGoodsList,CurFreeBcList} = generate_box_goods(RoleId,?BOX_FEE_TYPE_0,?BOX_USE_GOLD_0),
                RoleBox4#r_role_box{
                  free_times = RoleBox#r_role_box.free_times + 1,
                  start_time = NowSeconds,
                  end_time = NowSeconds + MaxKeepTime,
                  is_generate = ?BOX_IS_GENERATE_1,
                  fee_flag = ?BOX_FEE_FLAG_0,
                  cur_list = CurFreeBoxGoodsList,
                  bc_list = CurFreeBcList};
            _ ->
                RoleBox4
        end,
    t_set_role_refining_box_info(RoleId,RoleBox5),
    {ok,RoleAttr2,RoleBox,RoleBox3,RoleBox5,lists:append([AwardList,AwardList2])}.

do_t_refining_box_open2(RoleBase,RoleBox) ->
    [MaxBoxGoodsNumber] = common_config_dyn:find(refining_box,max_box_goods_number),
    case MaxBoxGoodsNumber >= (erlang:length(RoleBox#r_role_box.all_list) + erlang:length(RoleBox#r_role_box.cur_list)) of
        true ->
            %% {ok,NewRoleBox,NewCurList}
            get_restore_new_role_box(RoleBase,RoleBox);
        _ ->
            {ok,RoleBox,[]}
    end.

do_t_refining_box_open_fee(RoleId,RoleAttr,Fee) ->
    #p_role_attr{gold = Gold,gold_bind = GoldBind} = RoleAttr,
    if (Gold + GoldBind) < Fee ->
            common_transaction:abort({?_LANG_BOX_OPEN_NOT_GOLD,1});
       true ->
            next
    end,
    if GoldBind < Fee ->
            NewGold = Gold - (Fee - GoldBind),
            if NewGold < 0 ->
                    common_transaction:abort({?_LANG_BOX_OPEN_NOT_GOLD,1});
               true ->
                    RoleAttr2 = RoleAttr#p_role_attr{gold= NewGold,gold_bind=0 },
                    mod_map_role:set_role_attr(RoleId,RoleAttr2),
                    common_consume_logger:use_gold({RoleId, GoldBind, (Fee - GoldBind), ?CONSUME_TYPE_GOLD_OPEN_BOX, ""}),
                    if GoldBind > 0 ->
                            GoldType = ?BOX_USE_GOLD_2;
                       true ->
                            GoldType = ?BOX_USE_GOLD_1
                    end,
                    {RoleAttr2,GoldType}
            end;
       true ->
            NewGoldBind = GoldBind - Fee,
            RoleAttr2 = RoleAttr#p_role_attr{gold_bind=NewGoldBind},
            mod_map_role:set_role_attr(RoleId, RoleAttr2),
            common_consume_logger:use_gold({RoleId, Fee, 0, ?CONSUME_TYPE_GOLD_OPEN_BOX, ""}),
            {RoleAttr2,?BOX_USE_GOLD_2}
    end.

%% 放置物品,将物品放置宝物箱
do_refining_box_restore({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_box_restore2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,MapRoleInfo,RoleBox} ->
            do_refining_box_restore3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                     MapRoleInfo,RoleBox)
    end.
do_refining_box_restore2(RoleId,_DataRecord) ->
    MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(RoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0})
    end,
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    case IsBoxOpen =:= true of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_IS_OPEN_ERROR,0})
    end,
    RoleBox = 
        case get_role_refining_box_info(RoleId) of
            {ok,RoleBoxT} ->
                RoleBoxT;
            _ ->
                erlang:throw({error,?_LANG_BOX_RESTORE_NOT_GOODS_ERROR,0})
        end,
    case erlang:is_list(RoleBox#r_role_box.cur_list) andalso RoleBox#r_role_box.cur_list =/= [] of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_RESTORE_NOT_GOODS_ERROR,0})
    end,
    [MaxBoxGoodsNumber] = common_config_dyn:find(refining_box,max_box_goods_number),
    case MaxBoxGoodsNumber >= (erlang:length(RoleBox#r_role_box.all_list) + erlang:length(RoleBox#r_role_box.cur_list)) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_RESTORE_BOX_POS_NO_ENOUGH,90})
    end,
    {ok,MapRoleInfo,RoleBox}.
do_refining_box_restore3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                         MapRoleInfo,RoleBox) ->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_box_restore(RoleId,RoleBase,RoleBox)
           end) of
        {atomic,{ok,RoleBox,NewRoleBox,NewCurList}} ->
            do_refining_box_restore4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                     MapRoleInfo,RoleBase,RoleBox,NewRoleBox,NewCurList);
        {aborted, Error} ->
            case Error of
                {Reason, ReasonCode} ->
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_BOX_RESTORE_ERROR,
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_box_restore4({Unique, Module, Method, DataRecord, RoleId, PId, _Line},
                         _MapRoleInfo,RoleBase,RoleBox,NewRoleBox,NewCurList) ->
    %% 处理所有玩家开箱子记录
    catch do_insert_box_log_all(RoleBase,RoleBox),
    %% 需要通知宝物空间物品 TODO 暂时未处理
    %% 返回结果
    AwardStatus = 
        case NewRoleBox#r_role_box.cur_list =/= []  of
            true ->
                1;
            _ ->
                0
        end,
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    %% 获得玩家开箱子日志
    BoxSelfLogList = get_self_box_log(NewRoleBox#r_role_box.log_list),
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = DataRecord#m_refining_box_tos.page_no,
      page_type = DataRecord#m_refining_box_tos.page_type,
      is_open = IsBoxOpen,
      is_free = IsBoxFree,
      award_time = NewRoleBox#r_role_box.end_time,
      award_status = AwardStatus, 
      cur_list = NewRoleBox#r_role_box.cur_list,
      award_list = NewCurList,
      all_log_list = get_all_box_log(),
      generate_type = NewRoleBox#r_role_box.fee_flag,
      is_restore = NewRoleBox#r_role_box.is_restore,
      self_log_list = BoxSelfLogList},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    %% 记录日志
    lists:foreach(
      fun(BoxGoodsLog) ->
              catch common_item_logger:log(RoleId,BoxGoodsLog,?LOG_ITEM_TYPE_BOX_RESTORE_HUO_DE)
      end,RoleBox#r_role_box.cur_list),
    catch do_refining_box_goods_notify(RoleId,RoleBase,RoleBox),
    ok.
do_t_refining_box_restore(RoleId,RoleBase,RoleBox) ->
    %% 放置物品
    {ok,NewRoleBox,NewCurList} = get_restore_new_role_box(RoleBase,RoleBox),
    t_set_role_refining_box_info(RoleId,NewRoleBox),
    {ok,RoleBox,NewRoleBox,NewCurList}.

%% 根据玩家的当前的箱子物品，放置到宝物空间记录操作
%% 返回放置好的玩家箱子记录
get_restore_new_role_box(RoleBase,RoleBox) ->
    NowSeconds = common_tool:now(),
    #r_role_box{cur_list = CurList,all_list = AllList,end_time = EndTime,
                log_list = LogList,box_gid_index = BoxGIDIndex} = RoleBox,
    {NewCurList,NewBoxGIDIndex} =
        lists:foldl(
          fun(CurGoods,{AccNewCurList,AccNewBoxGIDIndex}) ->
                  {[CurGoods#p_goods{id = AccNewBoxGIDIndex} | AccNewCurList],AccNewBoxGIDIndex + 1}
          end,{[],BoxGIDIndex},CurList),
    NewAllList = lists:append(AllList,NewCurList),
    %% 玩家箱子物品日志
    [MaxBoxSelfLogNumber] = common_config_dyn:find(refining_box,max_box_self_log_number),
    LogList2 = 
        case erlang:length(LogList) > MaxBoxSelfLogNumber - 1 of
            true ->
                lists:sublist(LogList,MaxBoxSelfLogNumber -1);
            _ ->
                LogList
        end,
    BoxGoodsLogRecord = #r_box_goods_log{
      role_id = RoleBase#p_role_base.role_id,role_sex = RoleBase#p_role_base.sex,
      role_name = RoleBase#p_role_base.role_name,
      faction_id = RoleBase#p_role_base.faction_id,
      award_time = NowSeconds,award_list = CurList},
    NewLogList = [BoxGoodsLogRecord|LogList2],
    NewRoleBox = 
        case NowSeconds > EndTime of
            true -> %% 系统自动更新时间到，需要创建物品
                [MaxKeepTime] = common_config_dyn:find(refining_box,max_keep_time),
                {ok,CurBoxGoodsList,CurBcList} = generate_box_goods(RoleBase#p_role_base.role_id,?BOX_FEE_TYPE_0,?BOX_USE_GOLD_0),
                RoleBox#r_role_box{
                  free_times = RoleBox#r_role_box.free_times + 1,
                  start_time = NowSeconds,
                  end_time = NowSeconds + MaxKeepTime,
                  is_generate = ?BOX_IS_GENERATE_1,
                  fee_flag = ?BOX_FEE_FLAG_0,
                  all_list = NewAllList,
                  log_list = NewLogList,
                  box_gid_index = NewBoxGIDIndex,
                  cur_list = CurBoxGoodsList,
                  bc_list = CurBcList};
            _ ->
                RoleBox#r_role_box{
                  is_generate = ?BOX_IS_GENERATE_0,
                  fee_flag = ?BOX_FEE_FLAG_0,
                  all_list = NewAllList,
                  log_list = NewLogList,
                  box_gid_index = NewBoxGIDIndex,
                  cur_list = [],
                  bc_list = []}
        end,
    {ok,NewRoleBox,NewCurList}.


%% 查询放置物品
do_refining_box_query({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_box_query2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,not_box_goods,MaxPageNumber} -> %% 玩家没有箱子物品
            do_refining_box_query3_1({Unique, Module, Method, DataRecord, RoleId, PId, Line},MaxPageNumber);
        {ok,PageBoxGoodsList,MaxPageNumber} ->
            do_refining_box_query3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                   PageBoxGoodsList,MaxPageNumber)
    end.
do_refining_box_query3_1({Unique, Module, Method, DataRecord, _RoleId, PId, _Line},MaxPageNumber) ->
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = DataRecord#m_refining_box_tos.page_no,
      page_type = DataRecord#m_refining_box_tos.page_type,
      is_open = IsBoxOpen,
      is_free = IsBoxFree,
      box_list = [],
      total_pages = MaxPageNumber},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
do_refining_box_query2(RoleId,DataRecord) ->
    _MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(RoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0})
    end,
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    case IsBoxOpen =:= true of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_IS_OPEN_ERROR,0})
    end,
    [MaxBoxGoodsNumber] = common_config_dyn:find(refining_box,max_box_goods_number),
    [MaxPageGoodsNumber] = common_config_dyn:find(refining_box,max_page_goods_number),
    MaxPageNumber = 
        case (MaxBoxGoodsNumber rem MaxPageGoodsNumber) > 0 of
            true ->
                MaxBoxGoodsNumber div MaxPageGoodsNumber + 1;
            _ ->
                MaxBoxGoodsNumber div MaxPageGoodsNumber
        end,
    RoleBox = 
        case get_role_refining_box_info(RoleId) of
            {ok,RoleBoxT} ->
                RoleBoxT;
            _ ->
                erlang:throw({ok,not_box_goods,MaxPageNumber})
        end,
    #m_refining_box_tos{page_no = PageNo,page_type = PageType} = DataRecord,
    case PageNo > 0 andalso MaxPageNumber >= PageNo of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_QUERY_ERROR,0})
    end,
    case lists:member(PageType,[?BOX_PAGE_TYPE_0,?BOX_PAGE_TYPE_1,?BOX_PAGE_TYPE_2,?BOX_PAGE_TYPE_3,?BOX_PAGE_TYPE_4]) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_QUERY_ERROR,0})
    end,
    case erlang:is_list(RoleBox#r_role_box.all_list) of
        true ->
            next;
        _ ->
            erlang:throw({ok,not_box_goods,MaxPageNumber})
    end,
    BoxGoodsList =  
        lists:foldl(
          fun(BoxGoods,AccBoxGoodsList) ->
                  if PageType =:= ?BOX_PAGE_TYPE_1 andalso BoxGoods#p_goods.type =:= ?BOX_PAGE_TYPE_1 ->
                          [BoxGoodsBaseItemInfoT] = common_config_dyn:find_item(BoxGoods#p_goods.typeid),
                          if BoxGoodsBaseItemInfoT#p_item_base_info.kind =:= 4 ->
                                  AccBoxGoodsList;
                             true ->
                                  [BoxGoods|AccBoxGoodsList]
                          end;
                     PageType =:= ?BOX_PAGE_TYPE_2 andalso BoxGoods#p_goods.type =:= ?BOX_PAGE_TYPE_2 ->
                          [BoxGoods|AccBoxGoodsList];
                     PageType =:= ?BOX_PAGE_TYPE_3 andalso BoxGoods#p_goods.type =:= ?BOX_PAGE_TYPE_3 ->
                          [BoxGoods|AccBoxGoodsList];
                     PageType =:= ?BOX_PAGE_TYPE_0 ->
                          [BoxGoods|AccBoxGoodsList];
                     true ->
                          case PageType =:= ?BOX_PAGE_TYPE_4 andalso BoxGoods#p_goods.type =:= ?BOX_PAGE_TYPE_1 of
                              true ->
                                  [BoxGoodsBaseItemInfo] = common_config_dyn:find_item(BoxGoods#p_goods.typeid),
                                  if BoxGoodsBaseItemInfo#p_item_base_info.kind =:= 4 ->
                                          [BoxGoods|AccBoxGoodsList];
                                     true ->
                                          AccBoxGoodsList
                                  end;
                              _ ->
                                  AccBoxGoodsList
                          end
                  end 
          end,[],RoleBox#r_role_box.all_list),
    TotalNumber =  erlang:length(BoxGoodsList),
    TotalPageNumber = 
        case (TotalNumber rem MaxPageGoodsNumber) > 0 of
            true ->
                TotalNumber div MaxPageGoodsNumber + 1;
            _ ->
                TotalNumber div MaxPageGoodsNumber
        end,
    case PageNo > TotalPageNumber  of
        true ->
            erlang:throw({ok,not_box_goods,MaxPageNumber});
        _ ->
            next
    end,
    SortBoxGoodsList = 
        lists:sort(
          fun(#p_goods{id = GoodsIdA},#p_goods{id = GoodsIdB}) ->
                  GoodsIdA < GoodsIdB
          end,BoxGoodsList),
    PageBoxGoodsList = lists:sublist(SortBoxGoodsList,(PageNo - 1) * MaxPageGoodsNumber + 1,MaxPageGoodsNumber),
    {ok,PageBoxGoodsList,MaxPageNumber}.
do_refining_box_query3({Unique, Module, Method, DataRecord, _RoleId, PId, _Line},
                       PageBoxGoodsList,MaxPageNumber) ->
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = DataRecord#m_refining_box_tos.page_no,
      page_type = DataRecord#m_refining_box_tos.page_type,
      is_open = IsBoxOpen,
      is_free = IsBoxFree,
      box_list = PageBoxGoodsList,
      total_pages = MaxPageNumber},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
%% 提取物品
do_refining_box_get({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
     case catch do_refining_box_get2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,MapRoleInfo,RoleBox} ->
            do_refining_box_get3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                 MapRoleInfo,RoleBox)
    end.
do_refining_box_get2(RoleId,DataRecord) ->
    #m_refining_box_tos{goods_ids = GoodsIdList} = DataRecord,
    case erlang:is_list(GoodsIdList) andalso  erlang:length(GoodsIdList) > 0  of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_GET_NOT_GOODS_ID_ERROR,0})
    end,
    MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(RoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0})
    end,
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    case IsBoxOpen =:= true of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_IS_OPEN_ERROR,0})
    end,
    RoleBox = 
        case get_role_refining_box_info(RoleId) of
            {ok,RoleBoxT} ->
                RoleBoxT;
            _ ->
                 erlang:throw({error,?_LANG_BOX_GET_NOT_GOODS_ERROR,0})
        end,
    case lists:foldl(
           fun(GoodsId,AccGoodsIdFlag) ->
                   case lists:keyfind(GoodsId,#p_goods.id,RoleBox#r_role_box.all_list) of
                       false ->
                           false;
                       _ ->
                           AccGoodsIdFlag
                   end
           end,true,GoodsIdList) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_GET_NO_GOODS_ERROR,0})
    end,
    {ok,MapRoleInfo,RoleBox}.
do_refining_box_get3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                     MapRoleInfo,RoleBox) ->
    %% 提取物品放入背包
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_box_get(RoleId,DataRecord,MapRoleInfo,RoleBox)
           end) of
        {atomic,{ok,RoleBox,NewRoleBox,PGoodsList,AwardGoodsList}} ->
            do_refining_box_get4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                    MapRoleInfo,RoleBox,NewRoleBox,PGoodsList,AwardGoodsList);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_BOX_GET_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_BOX_GET_ERROR,
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_box_get4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                        _MapRoleInfo,_RoleBox,NewRoleBox,PGoodsList,AwardGoodsList) ->
    %% 记录日志，道具更新通知，返回结果
    catch common_misc:update_goods_notify({line, Line, RoleId},AwardGoodsList),
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    %% 获得玩家开箱子日志
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = DataRecord#m_refining_box_tos.page_no,
      page_type = DataRecord#m_refining_box_tos.page_type,
      is_open = IsBoxOpen,
      is_free = IsBoxFree,
      award_list = PGoodsList,
      generate_type = NewRoleBox#r_role_box.fee_flag,
      is_restore = NewRoleBox#r_role_box.is_restore},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    _AwardGoodsLogList = 
        lists:foldl(
          fun(AwardGoodsLog,AccAwardGoodsLogList) ->
                  AwardGoodsLogNumber = 
                      case AwardGoodsLog#p_goods.type =:= ?TYPE_EQUIP of
                          true ->
                              1;
                          _ ->
                              case lists:keyfind(AwardGoodsLog#p_goods.typeid,#p_goods.typeid,AccAwardGoodsLogList) of
                                  false ->
                                      lists:foldl(
                                        fun(#p_goods{typeid = AwardGoodsLogTypeId,current_num = AwardGoodsLogNum},AccAwardGoodsLogNumber) ->
                                                if AwardGoodsLog#p_goods.typeid =:= AwardGoodsLogTypeId ->
                                                        AwardGoodsLogNum + AccAwardGoodsLogNumber;
                                                   true ->
                                                        AccAwardGoodsLogNumber
                                                end
                                        end,0,PGoodsList);
                                  _ ->
                                      0
                              end
                      end,
                  if AwardGoodsLogNumber > 0 ->
                          catch common_item_logger:log(RoleId,AwardGoodsLog#p_goods{current_num = AwardGoodsLogNumber},?LOG_ITEM_TYPE_OPEN_BOX_HUO_DE),
                          [AwardGoodsLog#p_goods{current_num = AwardGoodsLogNumber}|AccAwardGoodsLogList];
                     true ->
                          AccAwardGoodsLogList
                  end
          end,[],AwardGoodsList),
    lists:foreach(
      fun(PGoodsLog) ->
              catch common_item_logger:log(RoleId,PGoodsLog,?LOG_ITEM_TYPE_BOX_RESTORE_P_CHU_SHOU)
      end,PGoodsList),
    ok.
do_t_refining_box_get(RoleId,DataRecord,_MapRoleInfo,RoleBox) ->
    #m_refining_box_tos{goods_ids = GoodsIdList} = DataRecord,
    case lists:foldl(
           fun(GoodsId,AccGoodsIdFlag) ->
                   case lists:keyfind(GoodsId,#p_goods.id,RoleBox#r_role_box.all_list) of
                       false ->
                           false;
                       _ ->
                           AccGoodsIdFlag
                   end
           end,true,GoodsIdList) of
        true ->
            next;
        _ ->
            common_transaction:abort({?_LANG_BOX_GET_NO_GOODS_ERROR,0})
    end,
    {PGoodsList,AllList} = 
        lists:foldl(
          fun(GoodsIdT,{AccPGoodsList,AccAllList}) ->
                  AccPGoods = lists:keyfind(GoodsIdT,#p_goods.id,AccAllList),
                  {[AccPGoods|AccPGoodsList],
                   lists:keydelete(GoodsIdT,#p_goods.id,AccAllList)}
          end,{[],RoleBox#r_role_box.all_list},GoodsIdList),
    {ok,AwardGoodsList} = mod_bag:create_goods_by_p_goods(RoleId,PGoodsList),
    RoleBox2 = RoleBox#r_role_box{all_list = AllList},
    t_set_role_refining_box_info(RoleId,RoleBox2),
    {ok,RoleBox,RoleBox2,PGoodsList,AwardGoodsList}.
%% 出售物品
do_refining_box_sale({_Unique, _Module, _Method, _DataRecord, _RoleId, _PId, _Line}) ->
    
    ok.
%% 销毁物品
do_refining_box_destory({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
     case catch do_refining_box_destory2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,MapRoleInfo,RoleBox} ->
            do_refining_box_destory3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                     MapRoleInfo,RoleBox)
    end.
do_refining_box_destory2(RoleId,DataRecord) ->
    #m_refining_box_tos{goods_ids = GoodsIdList} = DataRecord,
    case erlang:is_list(GoodsIdList) andalso  erlang:length(GoodsIdList) > 0  of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_GET_NOT_GOODS_ID_ERROR,0})
    end,
    MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(RoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0})
    end,
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    case IsBoxOpen =:= true of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_IS_OPEN_ERROR,0})
    end,
    RoleBox = 
        case get_role_refining_box_info(RoleId) of
            {ok,RoleBoxT} ->
                RoleBoxT;
            _ ->
                erlang:throw({error,?_LANG_BOX_DESTORY_NOT_GOODS_ERROR,0})
        end,
    case lists:foldl(
           fun(GoodsId,AccGoodsIdFlag) ->
                   case lists:keyfind(GoodsId,#p_goods.id,RoleBox#r_role_box.all_list) of
                       false ->
                           false;
                       _ ->
                           AccGoodsIdFlag
                   end
           end,true,GoodsIdList) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_DESTORY_NO_GOODS_ERROR,0})
    end,
    {ok,MapRoleInfo,RoleBox}.
do_refining_box_destory3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                         MapRoleInfo,RoleBox) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_box_destory(RoleId,DataRecord,MapRoleInfo,RoleBox)
           end) of
        {atomic,{ok,NewRoleBox,PGoodsList}} ->
            do_refining_box_destory4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                     MapRoleInfo,NewRoleBox,PGoodsList);
        {aborted, Error} ->
            case Error of
                {Reason, ReasonCode} ->
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_BOX_DESTORY_ERROR,
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_box_destory4({Unique, Module, Method, DataRecord, RoleId, PId, _Line},
                         _MapRoleInfo,NewRoleBox,PGoodsList) ->
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    %% 获得玩家开箱子日志
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = DataRecord#m_refining_box_tos.page_no,
      page_type = DataRecord#m_refining_box_tos.page_type,
      is_open = IsBoxOpen,
      is_free = IsBoxFree,
      award_list = PGoodsList,
      generate_type = NewRoleBox#r_role_box.fee_flag,
      is_restore = NewRoleBox#r_role_box.is_restore},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    lists:foreach(
      fun(PGoodsLog) ->
              catch common_item_logger:log(RoleId,PGoodsLog,?LOG_ITEM_TYPE_BOX_RESTORE_D_CHU_SHOU)
      end,PGoodsList),
    ok.
do_t_refining_box_destory(RoleId,DataRecord,_MapRoleInfo,RoleBox) ->
    #m_refining_box_tos{goods_ids = GoodsIdList} = DataRecord,
    case lists:foldl(
           fun(GoodsId,AccGoodsIdFlag) ->
                   case lists:keyfind(GoodsId,#p_goods.id,RoleBox#r_role_box.all_list) of
                       false ->
                           false;
                       _ ->
                           AccGoodsIdFlag
                   end
           end,true,GoodsIdList) of
        true ->
            next;
        _ ->
            common_transaction:abort({?_LANG_BOX_DESTORY_NO_GOODS_ERROR,0})
    end,
    {PGoodsList,AllList} = 
        lists:foldl(
          fun(GoodsIdT,{AccPGoodsList,AccAllList}) ->
                  AccPGoods = lists:keyfind(GoodsIdT,#p_goods.id,AccAllList),
                  {[AccPGoods|AccPGoodsList],
                   lists:keydelete(GoodsIdT,#p_goods.id,AccAllList)}
          end,{[],RoleBox#r_role_box.all_list},GoodsIdList),
    RoleBox2 = RoleBox#r_role_box{all_list = AllList},
    t_set_role_refining_box_info(RoleId,RoleBox2),
    {ok,RoleBox,RoleBox2,PGoodsList}.
%% 整理宝物空间物品接口
do_refining_box_merge({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_box_merge2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,RoleBox} ->
            do_refining_box_merge3({Unique, Module, Method, DataRecord, RoleId, PId, Line},RoleBox)
    end.
do_refining_box_merge2(RoleId,_DataRecord) ->
    _MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(RoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0})
    end,
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    case IsBoxOpen =:= true of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_IS_OPEN_ERROR,0})
    end,
    RoleBox = 
        case get_role_refining_box_info(RoleId) of
            {ok,RoleBoxT} ->
                RoleBoxT;
            _ ->
                erlang:throw({error,?_LANG_BOX_MERGE_ERROR,0})
        end,
    case erlang:is_list(RoleBox#r_role_box.all_list) andalso RoleBox#r_role_box.all_list =/= [] of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_MERGE_ERROR,0})
    end,
    {ok,RoleBox}.
do_refining_box_merge3({Unique, Module, Method, DataRecord, RoleId, PId, Line},RoleBox) ->
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_box_merge(RoleId,DataRecord,RoleBox)
           end) of
        {atomic,{ok,NewRoleBox}} ->
            do_refining_box_merge4({Unique, Module, Method, DataRecord, RoleId, PId, Line},NewRoleBox);
        {aborted, Error} ->
            case Error of
                {Reason, ReasonCode} ->
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_BOX_DESTORY_ERROR,
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_box_merge4({Unique, Module, Method, DataRecord, _RoleId, PId, _Line},NewRoleBox) ->
    [MaxBoxGoodsNumber] = common_config_dyn:find(refining_box,max_box_goods_number),
    [MaxPageGoodsNumber] = common_config_dyn:find(refining_box,max_page_goods_number),
    MaxPageNumber = 
        case (MaxBoxGoodsNumber rem MaxPageGoodsNumber) > 0 of
            true ->
                MaxBoxGoodsNumber div MaxPageGoodsNumber + 1;
            _ ->
                MaxBoxGoodsNumber div MaxPageGoodsNumber
        end,
    SortBoxGoodsList = 
        lists:sort(
          fun(#p_goods{id = GoodsIdA},#p_goods{id = GoodsIdB}) ->
                  GoodsIdA < GoodsIdB
          end,NewRoleBox#r_role_box.all_list),
    PageBoxGoodsList = lists:sublist(SortBoxGoodsList,1,MaxPageGoodsNumber),
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = 1,
      page_type = 0,
      is_open = IsBoxOpen,
      is_free = IsBoxFree,
      box_list = PageBoxGoodsList,
      total_pages = MaxPageNumber},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    ok.
do_t_refining_box_merge(RoleId,_DataRecord,RoleBox) ->
    {[],AllList} = 
        lists:foldl(
          fun(BoxGoods,{AccOldAllList,AccNewAllList}) ->
                  case lists:keyfind(BoxGoods#p_goods.id,#p_goods.id,AccOldAllList) of
                      false ->
                          {AccOldAllList,AccNewAllList};
                      _ ->
                          AccOldAllList2 = lists:keydelete(BoxGoods#p_goods.id,#p_goods.id,AccOldAllList),
                          %% 是否可合并
                          IsMergeFlag = 
                              if BoxGoods#p_goods.type =:= ?TYPE_EQUIP ->
                                      false;
                                 BoxGoods#p_goods.type =:= ?TYPE_ITEM ->
                                      [BoxGoodsBaseInfo] = common_config_dyn:find_item(BoxGoods#p_goods.typeid),
                                      case BoxGoodsBaseInfo#p_item_base_info.is_overlap =:= 1 
                                          andalso BoxGoodsBaseInfo#p_item_base_info.usenum =:= 1 of
                                          true ->
                                              true;
                                          _ ->
                                              false
                                      end;
                                 true ->
                                      true
                              end,
                          case IsMergeFlag =:= true andalso BoxGoods#p_goods.current_num < 50 of
                              true -> %% 物品可以合并
                                  case lists:keyfind(BoxGoods#p_goods.typeid,#p_goods.typeid,AccOldAllList2) of
                                      false ->
                                          {AccOldAllList2,[BoxGoods|AccNewAllList]};
                                      _ ->
                                          {AccOldAllList3,MergeBoxGoodsList}= 
                                              lists:foldl(
                                                fun(BoxGoodsT,{AccAccOldAllList,AccMergeBoxGoodsList}) ->
                                                        if BoxGoodsT#p_goods.typeid =:= BoxGoods#p_goods.typeid ->
                                                                AccAccOldAllList2 = lists:keydelete(BoxGoodsT#p_goods.id,#p_goods.id,AccAccOldAllList),
                                                                {AccAccOldAllList2,[BoxGoodsT|AccMergeBoxGoodsList]};
                                                           true ->
                                                                {AccAccOldAllList,AccMergeBoxGoodsList}
                                                        end
                                                end,{AccOldAllList2,[BoxGoods]},AccOldAllList2),
                                          {AccOldAllList3,lists:append([get_merge_p_goods(MergeBoxGoodsList),AccNewAllList])}
                                  end;
                              _ ->
                                  {AccOldAllList2,[BoxGoods|AccNewAllList]}
                          end
                  end
          end,{RoleBox#r_role_box.all_list,[]},RoleBox#r_role_box.all_list),
    NewRoleBox=RoleBox#r_role_box{all_list = AllList},
    t_set_role_refining_box_info(RoleId,NewRoleBox),
    {ok,NewRoleBox}.
%% 根据物品列表合并物品 typeid相关的物品列表
%% 此参数必须是同类型的物品列表，不区分绑定和不绑定
get_merge_p_goods([]) ->
    [];
get_merge_p_goods(BoxGoodsList) ->
    {BindGoodsList,BindGoodsNumber,NotBindGoodsList,NotBindGoodsNumber}=
        lists:foldl(
          fun(Goods,{AccBindGoodsList,AccBindGoodsNumber,AccNotBindGoodsList,AccNotBindGoodsNumber}) ->
                  case Goods#p_goods.bind =:= true of
                      true ->
                          {[Goods|AccBindGoodsList],AccBindGoodsNumber + Goods#p_goods.current_num,
                           AccNotBindGoodsList,AccNotBindGoodsNumber};
                      _ ->
                          {AccBindGoodsList,AccBindGoodsNumber,
                           [Goods|AccNotBindGoodsList],AccNotBindGoodsNumber + Goods#p_goods.current_num}
                  end
          end,{[],0,[],0},BoxGoodsList),
    BindList = 
        if BindGoodsList =/= [] ->
                [BindGoods | _TBindGoods] = BindGoodsList,
                case BindGoodsNumber rem 50 of
                    0 -> 
                        lists:duplicate(BindGoodsNumber div 50, BindGoods#p_goods{current_num=50});
                    RemBindNumber -> 
                        [BindGoods#p_goods{current_num=RemBindNumber}|
                         lists:duplicate(BindGoodsNumber div 50,BindGoods#p_goods{current_num=50})]
                end;
           true ->
                []
        end,
    BindList2 =
        case BindList =/= [] of
            true ->
                {_,BindListT} = 
                    lists:foldl(
                      fun(BindGoodsT,{AccBindIndex,AccBindList}) ->
                              OldBindGoods = lists:nth(AccBindIndex,BindGoodsList),
                              {AccBindIndex + 1,[BindGoodsT#p_goods{id = OldBindGoods#p_goods.id}|AccBindList]}
                      end,{1,[]},BindList),
                BindListT;
            _ ->
                BindList
        end, 
    NotBindList = 
        if NotBindGoodsList =/= [] ->
                [NotBindGoods | _TNotBindGoods] = NotBindGoodsList,
                case NotBindGoodsNumber rem 50 of
                    0 -> 
                        lists:duplicate(NotBindGoodsNumber div 50, NotBindGoods#p_goods{current_num=50});
                    RemNotBindNumber -> 
                        [NotBindGoods#p_goods{current_num=RemNotBindNumber}|
                         lists:duplicate(NotBindGoodsNumber div 50,NotBindGoods#p_goods{current_num=50})]
                end;
           true ->
                []
        end,
    NotBindList2 = 
        case NotBindList =/= [] of
            true ->
                {_,NotBindListT} = 
                    lists:foldl(
                      fun(NotBindGoodsT,{AccNotBindIndex,AccNotBindList}) ->
                              OldNotBindGoods = lists:nth(AccNotBindIndex,NotBindGoodsList),
                              {AccNotBindIndex + 1,[NotBindGoodsT#p_goods{id = OldNotBindGoods#p_goods.id}|AccNotBindList]}
                      end,{1,[]},NotBindList),
                NotBindListT;
            _ ->
                NotBindList
        end,
    lists:append([BindList2,NotBindList2]).


%% 直接提取物品到背包
do_refining_box_inbag({Unique, Module, Method, DataRecord, RoleId, PId, Line}) ->
    case catch do_refining_box_inbag2(RoleId,DataRecord) of
        {error,Reason,ReasonCode} ->
            do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
        {ok,MapRoleInfo,RoleBase,RoleBox} ->
            do_refining_box_inbag3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                   MapRoleInfo,RoleBase,RoleBox)
    end.
do_refining_box_inbag2(RoleId,_DataRecord) ->
    MapRoleInfo = 
        case mod_map_actor:get_actor_mapinfo(RoleId,role) of
            undefined ->
                erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0});
            MapRoleInfoT ->
                MapRoleInfoT
        end,
    case common_misc:is_role_online(RoleId) of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_ON_LINE_ERROR,0})
    end,
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    case IsBoxOpen =:= true of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_IS_OPEN_ERROR,0})
    end,
    RoleBox = 
        case get_role_refining_box_info(RoleId) of
            {ok,RoleBoxT} ->
                RoleBoxT;
            _ ->
                erlang:throw({error,?_LANG_BOX_NOT_GOODS_ERROR,0})
        end,
    case erlang:is_list(RoleBox#r_role_box.cur_list)
        andalso erlang:length(RoleBox#r_role_box.cur_list) > 0 of
        true ->
            next;
        _ ->
            erlang:throw({error,?_LANG_BOX_NOT_GOODS_ERROR,0})
    end,
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    {ok,MapRoleInfo,RoleBase,RoleBox}.

do_refining_box_inbag3({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                       MapRoleInfo,RoleBase,RoleBox) ->
    %% 提取物品放入背包，有可以更新时间到，需要再次计算生成物品
    case common_transaction:transaction(
           fun() ->
                   do_t_refining_box_inbag(RoleId,DataRecord,MapRoleInfo,RoleBase,RoleBox)
           end) of
        {atomic,{ok,NewRoleBox,AwardGoodsList}} ->
            do_refining_firing_inbag4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                                      MapRoleInfo,RoleBase,RoleBox,NewRoleBox,AwardGoodsList);
        {aborted, Error} ->
            case Error of
                {bag_error,not_enough_pos} -> %% 背包够空间,将物品发到玩家的信箱中
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},?_LANG_BOX_IN_BAG_NOT_BAG_POS_ERROR,0);
                {Reason, ReasonCode} ->
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason,ReasonCode);
                _ ->
                    Reason2 = ?_LANG_BOX_IN_BAG_ERROR,
                    do_refining_box_error({Unique, Module, Method, DataRecord, RoleId, PId, Line},Reason2,0)
            end
    end.
do_refining_firing_inbag4({Unique, Module, Method, DataRecord, RoleId, PId, Line},
                          _MapRoleInfo,RoleBase,RoleBox,NewRoleBox,AwardGoodsList) ->
    %% 处理所有玩家开箱子记录
    catch do_insert_box_log_all(RoleBase,RoleBox),
    
    catch common_misc:update_goods_notify({line, Line, RoleId},AwardGoodsList),
    
    %% 返回结果
    AwardStatus = 
        case NewRoleBox#r_role_box.cur_list =/= []  of
            true ->
                1;
            _ ->
                0
        end,
    [IsBoxOpen] = common_config_dyn:find(refining_box,is_box_open),
    [IsBoxFree] = common_config_dyn:find(refining_box,is_box_free),
    %% 获得玩家开箱子日志
    BoxSelfLogList = get_self_box_log(NewRoleBox#r_role_box.log_list),
    SendSelf = #m_refining_box_toc{
      succ = true,
      op_type = DataRecord#m_refining_box_tos.op_type,
      op_fee_type = DataRecord#m_refining_box_tos.op_fee_type,
      goods_ids = DataRecord#m_refining_box_tos.goods_ids,
      page_no = DataRecord#m_refining_box_tos.page_no,
      page_type = DataRecord#m_refining_box_tos.page_type,
      is_open = IsBoxOpen,
      is_free = IsBoxFree,
      award_time = NewRoleBox#r_role_box.end_time,
      award_status = AwardStatus, 
      cur_list = NewRoleBox#r_role_box.cur_list,
      award_list = AwardGoodsList,
      all_log_list = get_all_box_log(),
      generate_type = NewRoleBox#r_role_box.fee_flag,
      is_restore = NewRoleBox#r_role_box.is_restore,
      self_log_list = BoxSelfLogList},
    ?DEBUG("~ts,SendSelf=~w",["天工炉模块返回结果",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf),
    %% 道具通知，记录道具日志并返回
    _AwardGoodsLogList = 
        lists:foldl(
          fun(AwardGoodsLog,AccAwardGoodsLogList) ->
                  AwardGoodsLogNumber = 
                      case AwardGoodsLog#p_goods.type =:= ?TYPE_EQUIP of
                          true ->
                              1;
                          _ ->
                              case lists:keyfind(AwardGoodsLog#p_goods.typeid,#p_goods.typeid,AccAwardGoodsLogList) of
                                  false ->
                                      lists:foldl(
                                        fun(#p_goods{typeid = AwardGoodsLogTypeId,current_num = AwardGoodsLogNum},AccAwardGoodsLogNumber) ->
                                                if AwardGoodsLog#p_goods.typeid =:= AwardGoodsLogTypeId ->
                                                        AwardGoodsLogNum + AccAwardGoodsLogNumber;
                                                   true ->
                                                        AccAwardGoodsLogNumber
                                                end
                                        end,0,RoleBox#r_role_box.cur_list);
                                  _ ->
                                      0
                              end
                      end,
                  if AwardGoodsLogNumber > 0 ->
                          catch common_item_logger:log(RoleId,AwardGoodsLog#p_goods{current_num = AwardGoodsLogNumber},?LOG_ITEM_TYPE_OPEN_BOX_HUO_DE),
                          [AwardGoodsLog#p_goods{current_num = AwardGoodsLogNumber}|AccAwardGoodsLogList];
                     true ->
                          AccAwardGoodsLogList
                  end
          end,[],AwardGoodsList),
    catch do_refining_box_goods_notify(RoleId,RoleBase,RoleBox),
    ok.

do_t_refining_box_inbag(RoleId,_DataRecord,MapRoleInfo,RoleBase,RoleBox) ->
    #r_role_box{end_time = EndTime,cur_list = CurGoodsList,log_list = LogList} = RoleBox,
    {ok,AwardGoodsList} = mod_bag:create_goods_by_p_goods(RoleId,CurGoodsList),
    [MaxBoxSelfLogNumber] = common_config_dyn:find(refining_box,max_box_self_log_number),
    LogList2 = 
        case erlang:length(LogList) > MaxBoxSelfLogNumber - 1 of
            true ->
                lists:sublist(LogList,(MaxBoxSelfLogNumber - 1));
            _ ->
                LogList
        end,
    
    NowSeconds = common_tool:now(),
    BoxGoodsLogRecord = #r_box_goods_log{
      role_id = RoleId,role_sex = RoleBase#p_role_base.sex,
      role_name = MapRoleInfo#p_map_role.role_name,
      faction_id = MapRoleInfo#p_map_role.faction_id,
      award_time = NowSeconds,award_list = CurGoodsList},
    NewLogList = [BoxGoodsLogRecord|LogList2],
    RoleBox2 = 
        case NowSeconds > EndTime of
            true -> %% 系统自动更新时间到，需要创建物品
                [MaxKeepTime] = common_config_dyn:find(refining_box,max_keep_time),
                {ok,CurBoxGoodsList,CurBcList} = generate_box_goods(RoleId,?BOX_FEE_TYPE_0,?BOX_USE_GOLD_0),
                RoleBox#r_role_box{
                  free_times = RoleBox#r_role_box.free_times + 1,
                  start_time = NowSeconds,
                  end_time = NowSeconds + MaxKeepTime,
                  is_generate = ?BOX_IS_GENERATE_1,
                  fee_flag = ?BOX_FEE_FLAG_0,
                  cur_list = CurBoxGoodsList,
                  log_list = NewLogList,
                  bc_list = CurBcList};
            _ ->
                RoleBox#r_role_box{
                  cur_list = [],
                  log_list = NewLogList,
                  fee_flag = ?BOX_FEE_FLAG_0,
                  is_generate = ?BOX_IS_GENERATE_0,
                  bc_list = []}
        end,
    t_set_role_refining_box_info(RoleId,RoleBox2),
    {ok,RoleBox2,AwardGoodsList}.

%% 箱子获得物品消息通知处理
do_refining_box_goods_notify(RoleId,RoleBase,RoleBox) ->
    %% 提取物品广播
    AwardGoodsLogList = RoleBox#r_role_box.cur_list,
    if RoleBox#r_role_box.bc_list =/= [] andalso RoleBox#r_role_box.bc_list =/= undefined ->
            BcGoodsName = 
                lists:foldl(
                  fun(BcAwardGoodsLog,AccBcGoodsName) ->
                          case lists:member(BcAwardGoodsLog#p_goods.typeid,RoleBox#r_role_box.bc_list) of
                              true ->
                                  lists:append([common_goods:get_notify_goods_name(BcAwardGoodsLog),AccBcGoodsName]);
                              _ ->
                                  AccBcGoodsName
                          end
                  end,"",AwardGoodsLogList),
            FactionName = 
                if RoleBase#p_role_base.faction_id =:= 1 ->
                        ?_LANG_COLOR_FACTION_1;
                   RoleBase#p_role_base.faction_id =:= 2 ->
                        ?_LANG_COLOR_FACTION_2;
                   true ->
                        ?_LANG_COLOR_FACTION_3
                end,
            BCLeftMessage = common_tool:get_format_lang_resources(?_LANG_BOX_IN_BAG_SUCC_BC_LEFT,[FactionName,RoleBase#p_role_base.role_name]),
            BCCenterMessage = common_tool:get_format_lang_resources(?_LANG_BOX_IN_BAG_SUCC_BC_CENTER,[FactionName,RoleBase#p_role_base.role_name,BcGoodsName]),
            catch common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,BCCenterMessage),
            catch common_broadcast:bc_send_msg_world_include_goods([?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_WORLD,BCLeftMessage,
                                                                   RoleId,common_tool:to_list(RoleBase#p_role_base.role_name),
                                                                   RoleBase#p_role_base.sex, AwardGoodsLogList),
            ok;
       true ->
            ignore
    end,
    ok.

%% 处理玩家提取箱子物品是否记录所有人提示记录
do_insert_box_log_all(RoleBase,RoleBox) ->
    %% 处理所有玩家开箱子记录
    case RoleBox#r_role_box.bc_list =:= undefined 
        orelse RoleBox#r_role_box.bc_list =:= [] of
        true ->
            next;
        _ ->
            AllLogSelfList = 
                lists:foldl(
                  fun(AllLogGoods,AccAllLogSelfList) ->
                          case lists:member(AllLogGoods#p_goods.typeid,RoleBox#r_role_box.bc_list) of
                              true ->
                                  [AllLogGoods|AccAllLogSelfList];
                              _ ->
                                  AccAllLogSelfList
                          end
                  end,[],RoleBox#r_role_box.cur_list),
            BoxGoodsLogRecord = #r_box_goods_log{
              key = {RoleBase#p_role_base.role_id,common_tool:now_nanosecond()},
              role_id = RoleBase#p_role_base.role_id,
              role_sex = RoleBase#p_role_base.sex,
              role_name = RoleBase#p_role_base.role_name,
              faction_id = RoleBase#p_role_base.faction_id,
              award_time = common_tool:now(),award_list = AllLogSelfList},
            AllLogList = 
                case db:dirty_match_object(?DB_BOX_GOODS_LOG,#r_box_goods_log{_ = '_'}) of
                    AllLogListT when erlang:is_list(AllLogListT) ->
                        AllLogListT;
                    _ ->
                        []
                end,
            [MaxBoxAllLogNumber] = common_config_dyn:find(refining_box,max_box_all_log_number),
            lists:foldl(
              fun(AllBoxGoodsLog,AccBoxGoodsLogIndex) ->
                      if AccBoxGoodsLogIndex > MaxBoxAllLogNumber ->
                              db:dirty_delete(?DB_BOX_GOODS_LOG,AllBoxGoodsLog);
                         true ->
                              ignore
                      end,
                      AccBoxGoodsLogIndex + 1
              end,0,AllLogList),
            db:dirty_write(?DB_BOX_GOODS_LOG,BoxGoodsLogRecord)
    end.


%% 获取玩家箱子第一页物品列表
%% PageType 页面类型
%% PageNo 页码
%% BoxGoodsList 玩家所有箱子物品
%% get_role_box_goods(PageType,PageNo,_BoxGoodsList) -> 

%%     [].

%% 获得玩家开箱子日志
%% SelfLogList [r_box_goods_log,...]
get_self_box_log(SelfLogList) ->
    [ShowMaxBoxSelfLogNumber] = common_config_dyn:find(refining_box,max_box_show_self_log_number),
    SelfLogList2 = 
        case erlang:length(SelfLogList) > ShowMaxBoxSelfLogNumber of
            true ->
                lists:sublist(SelfLogList,ShowMaxBoxSelfLogNumber);
            _ ->
                SelfLogList
        end,
    lists:reverse([get_p_refining_box_log(R)|| R <- SelfLogList2]).
%% 获取所有玩家开箱子日志
get_all_box_log() ->
    [ShowMaxBoxAllLogNumber] = common_config_dyn:find(refining_box,max_box_show_all_log_number),
    AllLogList = 
        case db:dirty_match_object(?DB_BOX_GOODS_LOG,#r_box_goods_log{_ = '_'}) of
            AllLogListT when erlang:is_list(AllLogListT) ->
                AllLogListT;
            _ ->
                []
        end,
    AllLogList2 = 
        lists:sort(
          fun(#r_box_goods_log{award_time = AwardTimeA},#r_box_goods_log{award_time = AwardTimeB}) ->
                  AwardTimeA > AwardTimeB
          end,AllLogList),
    SumLen = erlang:length(AllLogList2),
    AllLogList3 = 
        case SumLen > ShowMaxBoxAllLogNumber of
            true ->
                lists:sublist(AllLogList2,ShowMaxBoxAllLogNumber);
            _ ->
                AllLogList2
        end,
    lists:reverse([get_p_refining_box_log(R)|| R <- AllLogList3]).
get_p_refining_box_log(BoxGoodsLogRecord) ->
    #r_box_goods_log{role_id = RoleId,
                     role_sex = RoleSex,
                     role_name = RoleName,
                     faction_id = FactionId,
                     award_time = AwardTime,
                     award_list = AwardList} = BoxGoodsLogRecord,
    #p_refining_box_log{role_id = RoleId,
                        role_sex = RoleSex,
                        role_name = RoleName,
                        faction_id = FactionId,
                        award_time = AwardTime,
                        box_list = AwardList}.

%% 根据概率生成箱子物品
%% FeeType 费用类型 0免费 1:9元宝
%% 返回 {ok,GoodsList,BcGoodsList}
%% GoodsList [p_goods,...]
%% BcGoodsList [typeId,...]
generate_box_goods(RoleId,FeeType,GoldType) ->
    [BoxProbabilityList] = common_config_dyn:find(refining_box,box_probability),
    BoxProbabilityRecord = lists:keyfind(FeeType,#r_box_probability.fee_type,BoxProbabilityList),
    #r_box_probability{item_number = ItemNumberList} = BoxProbabilityRecord,
    ItemNumber = mod_refining:get_random_number(ItemNumberList,0,0),
    if ItemNumber =< 0 ->
            {ok,[],[]};
       true ->
            generate_box_goods2(RoleId,FeeType,GoldType,BoxProbabilityRecord,ItemNumber)
    end.
generate_box_goods2(RoleId,FeeType,GoldType,BoxProbabilityRecord,ItemNumber) ->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleId),
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
    #r_box_probability{item_type = ItemTypeList} = BoxProbabilityRecord,
    [BoxSubProbabilityList] = common_config_dyn:find(refining_box,box_goods_probability),
    [MinBoxEquipColor] = common_config_dyn:find(refining_box,min_box_equip_color),
    {GoodsList,BcGoodsList} = 
        lists:foldl(
          fun(_Index,{AccGoodsList,AccBcGoodsList}) ->
                  ItemType = mod_refining:get_random_number(ItemTypeList,0,1),
                  case get_box_sub_probability(FeeType,ItemType,BoxSubProbabilityList) of
                      undefined ->
                          {AccGoodsList,AccBcGoodsList};
                      #r_box_sub_probability{goods_list = BoxGoodsProbabilityListT} ->
                          case filter_box_goods_probability(RoleBase,RoleAttr,BoxGoodsProbabilityListT) of
                              [] ->
                                  {AccGoodsList,AccBcGoodsList};
                              BoxGoodsProbabilityList ->
                                  BoxGoodsWeightList = [BoxGoodsWeight || #r_box_goods_probability{weight = BoxGoodsWeight} <- BoxGoodsProbabilityList],
                                  BoxGoodsWeightIndex = mod_refining:get_random_number(BoxGoodsWeightList,0,0),
                                  BoxGoodsProbability = lists:nth(BoxGoodsWeightIndex,BoxGoodsProbabilityList),
                                  case create_p_goods(FeeType,BoxGoodsProbability,GoldType) of
                                      {ok,GoodsListT} ->
                                          AccBcGoodsList2 = 
                                              if BoxGoodsProbability#r_box_goods_probability.is_broadcast =:= 1 
                                                 andalso BoxGoodsProbability#r_box_goods_probability.item_type =/= ?TYPE_EQUIP  ->
                                                      [BoxGoodsProbability#r_box_goods_probability.item_id|AccBcGoodsList];
                                                 BoxGoodsProbability#r_box_goods_probability.item_type =:= ?TYPE_EQUIP ->
                                                      [HEquipBCBoxGoods|_THEquipBCBoxGoods] = GoodsListT,
                                                      if HEquipBCBoxGoods#p_goods.current_colour >= MinBoxEquipColor ->
                                                              [BoxGoodsProbability#r_box_goods_probability.item_id|AccBcGoodsList];
                                                         true ->
                                                             AccBcGoodsList
                                                      end;
                                                 true ->
                                                      AccBcGoodsList
                                              end,
                                          {lists:append([GoodsListT,AccGoodsList]),AccBcGoodsList2};
                                      _ ->
                                          {AccGoodsList,AccBcGoodsList}
                                  end
                          end;
                      _ ->
                          {AccGoodsList,AccBcGoodsList}
                  end
          end,{[],[]},lists:seq(1,ItemNumber,1)),
    GoodsList2 = [Goods#p_goods{id = ?DEFAULT_BOX_GOODS_ID,
                                roleid = RoleBase#p_role_base.role_id,
                                bagid = 0,
                                bagposition = 0} || Goods <- GoodsList],
    {ok,GoodsList2,BcGoodsList}.
%% 根据r_box_goods_probability创建p_goods
%% 返回 {ok,p_goods} or {error,Reason}
%% GoldType 元宝类型 1元宝 2绑定元宝
create_p_goods(FeeType,BoxGoodsProbability,GoldType) ->
    #r_box_goods_probability{item_id = ItemId,item_type = ItemType,item_number = ItemNumber,
                             item_bind = ItemBind,
                             start_time = PStartTime,end_time = PEndTime,days = PDays} = BoxGoodsProbability,
    Bind = 
        if ItemBind =:= 1 ->
                true;
           ItemBind =:= 2 ->
                false;
           true ->
                if FeeType =:= ?BOX_FEE_FLAG_0 ->
                        true;
                   true ->
                        if GoldType =:= ?BOX_USE_GOLD_1 ->
                                false;
                           GoldType =:= ?BOX_USE_GOLD_2 ->
                                true;
                           true ->
                                true
                        end
                end
        end,
    NowSeconds = common_tool:now(),
    {StartTime,EndTime} = 
        if PStartTime =:= 0 andalso PEndTime =:= 0 andalso PDays =/= 0 ->
                {NowSeconds - 5, NowSeconds + 24*60*60 * PDays};
           PStartTime =/= 0 andalso PEndTime =/= 0 andalso PDays =:= 0 ->
                {PStartTime,PEndTime};
           PStartTime =:= 0 andalso PEndTime =/= 0 andalso PDays =:= 0 ->
                {NowSeconds - 5,PEndTime};
           true ->
                {0,0}
        end,
    if ItemType =:= ?TYPE_EQUIP ->
            %% 需要根据装备概率计算装备的属性
            EquipCreateInfo = #r_equip_create_info{
              num=ItemNumber,typeid = ItemId,bind=Bind,start_time = StartTime,end_time = EndTime},
            create_box_equip_p_goods(EquipCreateInfo,BoxGoodsProbability);
       ItemType =:= ?TYPE_STONE ->
            CreateInfo = #r_stone_create_info{num=ItemNumber,typeid = ItemId,bind=Bind,start_time = StartTime,end_time = EndTime},
            common_bag2:creat_stone(CreateInfo);
       ItemType =:= ?TYPE_ITEM ->
            CreateInfo = #r_item_create_info{num = ItemNumber,typeid = ItemId,bind=Bind,start_time = StartTime,end_time = EndTime},
            common_bag2:create_item(CreateInfo);
       true ->
            {error,item_type_error}
    end.
%% 创建箱子装备物品
create_box_equip_p_goods(EquipCreateInfo,BoxGoodsProbability) ->
    #r_box_goods_probability{use_bind = PUseBind,equip_probability_id = EquipProbabilityId} = BoxGoodsProbability,
    #r_equip_create_info{typeid = ItemId,bind=Bind} = EquipCreateInfo,
    EquipBind = 
        case Bind =:= true of
            true ->
                UseBind = 0,
                Bind;
            _ ->
                if PUseBind =:= 1 ->
                        UseBind = 1,
                        false;
                   true ->
                        UseBind = 0,
                        Bind
                end
        end,
    [BoxEquipProbabilityList] = common_config_dyn:find(refining_box,box_equip_probability),
    BoxEquipProbabilityRecord = 
        case lists:keyfind(EquipProbabilityId,#r_box_equip_probability.id,BoxEquipProbabilityList) of
            false ->
                lists:keyfind(0,#r_box_equip_probability.id,BoxEquipProbabilityList);
            BoxEquipProbabilityTT ->
                BoxEquipProbabilityTT
        end,
    EquipCreateInfo2 = EquipCreateInfo#r_equip_create_info{bind = EquipBind},
    CreateInfo = get_equip_create_info(BoxEquipProbabilityRecord,EquipCreateInfo2),
    case common_bag2:creat_equip_without_expand(CreateInfo) of
        {ok,EquipGoodsList} ->
            [EquipBaseInfo] = common_config_dyn:find_equip(ItemId),
            EquipGoodsList2 = 
                lists:foldl(
                  fun(EquipGoods,AccEquipGoodsList) ->
                          EquipGoods2 = mod_refining:equip_colour_quality_add(new,EquipGoods,1,1,1),%% 装备颜色品质
                          EquipGoods3 = mod_equip_change:equip_reinforce_property_add(EquipGoods2,EquipBaseInfo),%%强化处理
                          EquipGoods4 = 
                              case EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT
                                  orelse EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_FASHION of
                                  true ->
                                      EquipGoods3#p_goods{bind = EquipBind,use_bind = UseBind};
                                  _ ->
                                      %% 处理绑定属性
                                      case UseBind =:= 1 orelse Bind =:= true of
                                          true ->
                                              {AddAttrNumberAtom,AddAttrLevelAtom} = BoxEquipProbabilityRecord#r_box_equip_probability.add_attr,
                                              case mod_refining_bind:do_equip_bind_by_config_atom(
                                                     EquipGoods3#p_goods{bind = false},EquipBaseInfo,AddAttrNumberAtom,AddAttrLevelAtom) of
                                                  {ok,EquipGoods4T} ->
                                                      if UseBind =:= 1 ->
                                                              EquipGoods4T#p_goods{bind = EquipBind,use_bind = UseBind};
                                                         true ->
                                                              EquipGoods4T
                                                      end;
                                                  _ ->
                                                      EquipGoods3#p_goods{bind = EquipBind,use_bind = UseBind}
                                              end;
                                          _ ->
                                              EquipGoods3#p_goods{bind = EquipBind,use_bind = UseBind}
                                      end    
                              end,
                          EquipGoods5 = 
                              case common_misc:do_calculate_equip_refining_index(EquipGoods4) of
                                  {ok,EquipGoods5T} ->
                                      EquipGoods5T;
                                  _ ->
                                      EquipGoods4
                              end,
                          [EquipGoods5#p_goods{stones = []}|AccEquipGoodsList]
                  end,[],EquipGoodsList),
            {ok,EquipGoodsList2};
        {error,EquipError} ->
            {error,EquipError}
    end.

%% 箱子物品是装备，即需要计算装备的概率属性
%% 返回 r_equip_create_info
get_equip_create_info(BoxEquipProbabilityRecord,EquipCreateInfo) ->
    #r_equip_create_info{typeid = TypeId} = EquipCreateInfo,
    #r_box_equip_probability{
          color = ColorList,
          quality = QualityList,
          sub_quality = SubQualityList,
          reinforce = ReinforceList,
          punch_num = PunchNumList} = BoxEquipProbabilityRecord,
    [EquipBaseInfo] = common_config_dyn:find_equip(TypeId),
    case EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT
        orelse EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_FASHION of
        true ->
            Color = 1,Quality = 1,SubQuality = 1;
        _ ->
            Color = mod_refining:get_random_number(ColorList,0,1),
            Quality = mod_refining:get_random_number(QualityList,0,1),
            SubQuality = mod_refining:get_random_number(SubQualityList,0,1)
    end,
    if ReinforceList =:= [] ->
            ReinforceResultList = [],
            ReinforceResult = 0,
            ReinforceRate = 0;
       true ->
            ReinforceWeightList = [Weight || {Weight,_ReinforceResultListT} <- ReinforceList],
            ReinforceWeightIndex = mod_refining:get_random_number(ReinforceWeightList,0,0),
            if ReinforceWeightIndex =< 0 ->
                    ReinforceResultList = [],
                    ReinforceResult = 0,
                    ReinforceRate = 0;
               true ->
                    {_Weight,ReinforceResultList} = lists:nth(ReinforceWeightIndex,ReinforceList),
                    case erlang:is_list(ReinforceResultList) andalso ReinforceResultList =/= [] of
                        true ->
                            ReinforceResult = lists:max(ReinforceResultList),
                            ReinforceLevel = ReinforceResult div 10,
                            ReinforceGrade = ReinforceResult rem 10,
                            [ReinforceRateList] = common_config_dyn:find(refining,reinforce_rate),
                            {_,ReinforceRate} = lists:keyfind({ReinforceLevel,ReinforceGrade},1,ReinforceRateList);
                        _ ->
                            ReinforceResult = 0,
                            ReinforceRate = 0
                    end
            end
    end,
    PunchNum =  mod_refining:get_random_number(PunchNumList,0,0),
    EquipCreateInfo#r_equip_create_info{color=Color,quality=Quality,sub_quality = SubQuality,
                                        punch_num=PunchNum,rate=ReinforceRate,
                                        result=ReinforceResult,result_list=ReinforceResultList}.
%% 查询箱子子概率
%% 返回 undefined or r_box_sub_probability
get_box_sub_probability(FeeType,ItemType,BoxSubProbabilityList) ->
    lists:foldl(
      fun(#r_box_sub_probability{fee_type = FeeTypeB,goods_type = GoodsType} = R,Acc) ->
              case FeeType =:= FeeTypeB andalso GoodsType =:= ItemType of
                  true ->
                      R;
                  _ ->
                      Acc
              end
      end,undefined,BoxSubProbabilityList).
%% 过滤符合玩家条件的概率物品
%% 返回 [] or [r_box_goods_probability,...]
filter_box_goods_probability(RoleBase,RoleAttr,BoxGoodsProbabilityList) ->
    lists:foldl(
      fun(BoxGoodsProbability,AccBoxGoodsProbabilityList) ->
              IsRoleCategory = 
                  case BoxGoodsProbability#r_box_goods_probability.role_category of
                      [] ->
                          true;
                      RoleCategoryList when erlang:is_list(RoleCategoryList) ->
                          lists:member(RoleAttr#p_role_attr.category,RoleCategoryList);
                      _ ->
                          true
                  end,
              IsRoleSex = 
                  case BoxGoodsProbability#r_box_goods_probability.role_sex of
                      [] ->
                          true;
                      RoleSexList when erlang:is_list(RoleSexList) ->
                          lists:member(RoleBase#p_role_base.sex,RoleSexList);
                      _ ->
                          true
                  end,
              IsRoleLevel = 
                  case BoxGoodsProbability#r_box_goods_probability.role_level of
                      [] ->
                          true;
                      RoleLevelList when erlang:is_list(RoleLevelList),erlang:length(RoleLevelList) =:= 2 ->
                          case RoleAttr#p_role_attr.level >=  lists:nth(1,RoleLevelList)
                              andalso lists:nth(2,RoleLevelList) >= RoleAttr#p_role_attr.level of
                              true ->
                                  true;
                              _ ->
                                  false
                          end;
                      _ ->
                          true
                  end,
              case IsRoleCategory =:= true andalso IsRoleSex =:= true andalso IsRoleLevel =:= true of
                  true ->
                      [BoxGoodsProbability|AccBoxGoodsProbabilityList];
                  _ ->
                      AccBoxGoodsProbabilityList
              end 
      end,[],BoxGoodsProbabilityList).

