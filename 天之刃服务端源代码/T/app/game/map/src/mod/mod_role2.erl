%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2010, 
%%% @doc
%%%
%%% @end
%%% Created : 17 Dec 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_role2).

%% Include File
-include("mgeem.hrl").
-include("office.hrl").

%% API Func
-export([
         handle/1,
         do_relive/5,
         do_pk_mode_modify_for_10500/2,
         calc_rest_money/3,
         online_broadcast/5,
         init/1
        ]).

%% Test Func
-export([
         test_sex/1,
         test_hair/3
        ]).

-define(ATTR_STR, 1).
-define(ATTR_CON, 5).
-define(ATTR_INT, 2).
-define(ATTR_MEN, 4).
-define(ATTR_DEX, 3).

-define(SEXMAN, 1).
-define(SEXWOMAN, 2).

-define(DICT_KEY_TIMEREF, time_ref).
-define(PLAIN_RELIVE_INTERVAL, 120).
-define(MAX_PK_MODE, 5).
-define(DEFAULT_ROLE2_FIVE_ELE_ATTR_MIN_LEVEL, 16).

-define(MANWATCHMAN, "<font color=\"#00ff00\">[~s]</font> 挑衅地看着你").
-define(MANWATCHWOMAN, "<font color=\"#00ff00\">[~s]</font> 色迷迷地看着你").
-define(WOMANWATCHMAN, "<font color=\"#00ff00\">[~s]</font> 痴痴地看着你").
-define(WOMANWATCHWOMAN, "<font color=\"#00ff00\">[~s]</font> 鬼鬼祟祟地打量着你").

%% 更换发型价格（文）
-define(HAIR_CUT_PRICE, 10000).
%% 变性价格（元宝）
-define(SEX_CHANGE_PRICE, 50).
%% 更换头像价格（文）
-define(CHANGE_HEAD_PRICE, 10000).

%% 离开新手村事件ID
-define(EVENT_LEVEL_XSC_ID, 1).

%% 发型卡typeid
-define(hair_card_typeid, 10100024).
%% 头像卡typeid
-define(head_card_typeid, 10100023).
%% API Func
handle(Info) ->
    do_handle(Info).

%% Internal Func
do_handle({Unique, Module, ?ROLE2_HEAD, DataIn, RoleID, PID, _Line, MapState}) ->
    do_head(Unique, Module, ?ROLE2_HEAD, DataIn, RoleID, PID, MapState);
do_handle({Unique, Module, ?ROLE2_HAIR, DataIn, RoleID, PID, _Line, MapState}) ->
    do_hair(Unique, Module, ?ROLE2_HAIR, DataIn, RoleID, PID, MapState);
do_handle({Unique, Module, ?ROLE2_SEX, DataIn, RoleID, PID, Line, MapState}) ->
    do_sex(Unique, Module, ?ROLE2_SEX, DataIn, RoleID, PID, MapState, Line);
do_handle({Unique, Module, ?ROLE2_RELIVE, DataIn, RoleID, _PID, Line, _MapState}) ->
    do_relive(Unique, Module, ?ROLE2_RELIVE, RoleID, DataIn, Line);
do_handle({Unique, Module, ?ROLE2_POINTASSIGN, DataIn, RoleID, _PID, Line, _MapState}) ->
    do_point_assgin(Unique, Module, ?ROLE2_POINTASSIGN, DataIn, RoleID, Line);
do_handle({Unique, Module, ?ROLE2_PKMODEMODIFY, DataIn, RoleID, _PID, Line, _MapState}) ->
    do_pk_mode_modify(Unique, Module, ?ROLE2_PKMODEMODIFY, RoleID, DataIn, Line);
do_handle({Unique, Module, ?ROLE2_ZAZEN, DataIn, RoleID, _PID, Line, _MapState}) ->
    do_zazen(Unique, Module, ?ROLE2_ZAZEN, RoleID, DataIn, Line);
do_handle({Unique, Module, ?ROLE2_FIVE_ELE_ATTR, DataIn, RoleID, _PID, Line, _MapState}) ->
    do_five_ele_attr(Unique, Module, ?ROLE2_FIVE_ELE_ATTR, DataIn, RoleID, Line);
do_handle({Unique, Module, ?ROLE2_LEVELUP, DataIn, RoleID, _PID, Line, _MapState}) ->
    do_levelup(Unique, Module, ?ROLE2_LEVELUP, DataIn, RoleID, Line);
do_handle({Unique, Module, ?ROLE2_SHOW_CLOTH, DataIn, RoleID, _PID, Line, _MapState}) ->
    do_show_cloth(Unique, Module, ?ROLE2_SHOW_CLOTH, DataIn, RoleID, Line);
do_handle({Unique, Module, ?ROLE2_PKPOINT_LEFT, _DataIn, RoleID, _PID, Line, _MapState}) ->
    do_pkpoint_left(Unique, Module, ?ROLE2_PKPOINT_LEFT, RoleID, Line);
do_handle({Unique, Module, ?ROLE2_GETROLEATTR, DataIn, RoleID, _PID, Line, _MapState}) ->
    do_get_roleattr(Unique, Module, ?ROLE2_GETROLEATTR, RoleID, DataIn, Line);
do_handle({Unique, Module, ?ROLE2_UNBUND_CHANGE, DataIn, RoleID, _PID, _Line, _MapState}) ->
    do_unbund_change(Unique, Module, ?ROLE2_UNBUND_CHANGE, RoleID, DataIn);
do_handle({Unique, Module, ?ROLE2_EVENT, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_event(Unique, Module, ?ROLE2_EVENT, DataIn, RoleID, PID);
do_handle({Unique, Module, ?ROLE2_SHOW_EQUIP_RING, DataIn, RoleID, PID, _Line, MapState}) ->
    do_show_equip_ring(Unique, Module, ?ROLE2_SHOW_EQUIP_RING, DataIn, RoleID, PID, MapState);
do_handle({Unique, Module, ?ROLE2_REMOVE_SKIN_BUFF, _DataIn, RoleID, PID, _Line, _MapState}) ->
    do_remove_skin_buff(Unique, Module, ?ROLE2_REMOVE_SKIN_BUFF, RoleID, PID);
do_handle({Unique, Module, ?ROLE2_ADD_ENERGY, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_add_energy(Unique, Module, ?ROLE2_ADD_ENERGY, DataIn, RoleID, PID);

%% 在线挂机模块处理
%% do_handle({Unique, Module, ?ROLE2_ON_HOOK_BEGIN, DataIn, RoleID, PID, Line, _MapState}) ->
%%     mod_role_on_hook:do_handle_info({Unique, Module, ?ROLE2_ON_HOOK_BEGIN, DataIn, RoleID, PID,Line});
%% do_handle({Unique, Module, ?ROLE2_ON_HOOK_END, DataIn, RoleID, PID, Line, _MapState}) ->
%%     mod_role_on_hook:do_handle_info({Unique, Module, ?ROLE2_ON_HOOK_END, DataIn, RoleID, PID,Line});
%% do_handle({Unique, Module, ?ROLE2_ON_HOOK_STATUS, DataIn, RoleID, PID, Line, _MapState}) ->
%%     mod_role_on_hook:do_handle_info({Unique, Module, ?ROLE2_ON_HOOK_STATUS, DataIn, RoleID, PID,Line});

%% 查询当前国家在线玩家榜数据
do_handle({Unique, Module, ?ROLE2_QUERY_FACTION_ONLINE_RANK, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_query_faction_online_rank(Unique, Module, ?ROLE2_QUERY_FACTION_ONLINE_RANK, DataIn, RoleID, PID);
do_handle({admin_query_faction_online_rank,Msg}) ->
    do_admin_query_faction_online_rank(Msg);
do_handle({admin_join_faction_online_rank,Msg}) ->
    do_admin_join_faction_online_rank(Msg);
do_handle({admin_quit_faction_online_rank,Msg}) ->
    do_admin_quit_faction_online_rank(Msg);
do_handle({admin_uplevel_faction_online_rank,Msg}) ->
    do_admin_uplevel_faction_online_rank(Msg);

%% GM命令设置玩家五行属性
do_handle({admin_set_role_five_ele_attr, RoleID, FiveEleAttr}) ->
    do_admin_set_role_five_ele_attr(RoleID,FiveEleAttr);
do_handle(Info) ->
    ?ERROR_MSG("mod_role2, unknow info: ~w", [Info]).

%% 地图进程创建初始化
init(MapId) ->
    [DoFactionOnlineRoleRankMapId] = common_config_dyn:find(etc,do_faction_online_role_rank_map_id),
    case DoFactionOnlineRoleRankMapId =:= MapId of
        true ->
            init_faction_online_role_rank(DoFactionOnlineRoleRankMapId,1),
            init_faction_online_role_rank(DoFactionOnlineRoleRankMapId,2),
            init_faction_online_role_rank(DoFactionOnlineRoleRankMapId,3);
        _ ->
            ignore
    end,
    ok.

%% @doc 重置精力值
do_add_energy(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_role2_add_energy_tos{gold_exchange=GoldExchange} = DataIn,
    case catch check_can_add_energy(RoleID, GoldExchange) of
        {ok, GoldExchange2, RoleFight} ->
            do_add_energy2(Unique, Module, Method, RoleID, PID, GoldExchange2, RoleFight);
        {error, Reason} ->
            do_add_energy_error(Unique, Module, Method, PID, Reason)
    end.

do_add_energy2(Unique, Module, Method, RoleID, PID, GoldExchange, RoleFight) ->
    case common_transaction:t(
           fun() ->
                   {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
                   #p_role_attr{gold=Gold, gold_bind=GoldBind} = RoleAttr,
                   {Gold2, GoldBind2} = calc_rest_money(Gold, GoldBind, GoldExchange),
                   RoleAttr2 = RoleAttr#p_role_attr{gold=Gold2, gold_bind=GoldBind2},
                   mod_map_role:set_role_attr(RoleID, RoleAttr2),
                   
                   {Gold2, GoldBind2}
           end)
    of
        {atomic, {Gold2, GoldBind2}} ->
            #p_role_fight{energy=Energy, energy_remain=EnergyRemain} = RoleFight,
            [Gold2Energy] = common_config_dyn:find(etc, gold2energy),
            EnergyAdd = GoldExchange * Gold2Energy,

            case EnergyRemain - EnergyAdd < 0 of
                true ->
                    EnergyRemain2 = 0,
                    Energy2 = Energy + EnergyRemain;
                _ ->
                    EnergyRemain2 = EnergyRemain - EnergyAdd,
                    Energy2 = Energy + EnergyAdd
            end,
   
            RoleFight2 = RoleFight#p_role_fight{energy=Energy2, energy_remain=EnergyRemain2},
            mod_map_role:set_role_fight(RoleID, RoleFight2),

            DataRecord = #m_role2_add_energy_toc{gold=Gold2,
                                                 gold_bind=GoldBind2,
                                                 energy=Energy2,
                                                 energy_remain=EnergyRemain2},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord);
        {aborted, Error} ->
            ?ERROR_MSG("do_add_energy, error: ~w", [Error]),
            do_add_energy_error(Unique, Module, Method, PID, ?_LANG_ROLE2_ADD_ENERGY_SYSTEM_ERROR)
    end.

do_add_energy_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_role2_add_energy_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 精力值补充相关判断
check_can_add_energy(RoleID, GoldExchange) ->
    case GoldExchange =< 0 of
        true ->
            erlang:throw({error, ?_LANG_ROLE2_ADD_ENERGY_ILLEGAL_INPUT});
        _ ->
            ok
    end,
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{gold=Gold, gold_bind=GoldBind} = RoleAttr,
    case GoldExchange > GoldBind + Gold of
        true ->
            erlang:throw({error, ?_LANG_ROLE2_ADD_ENERGY_NOT_ENOUGH_GOLD});
        _ ->
            ok
    end,
    %% 剩余精力值兑换元宝
    {ok, RoleFight} = mod_map_role:get_role_fight(RoleID),
    #p_role_fight{energy_remain=EnergyRemain} = RoleFight,
    case EnergyRemain =< 0 of
        true ->
            erlang:throw({error, ?_LANG_ROLE2_ADD_ENERGY_ENERGY_REMAIN_NOT_ENOUGH});
        _ ->
            ok
    end,
    %% 兑换的精力值不超过剩余精力值
    [Gold2Energy] = common_config_dyn:find(etc, gold2energy),
    EnergyAdd = GoldExchange * Gold2Energy,
    case EnergyAdd > EnergyRemain of
        true ->
            GoldExchange2 = common_tool:ceil(erlang:round(EnergyRemain)/Gold2Energy);
        _ ->
            GoldExchange2 = GoldExchange
    end,
    {ok, GoldExchange2, RoleFight}.

%% 移除变身价格，5两
-define(remove_skin_buff_price, 500).
-define(skin_buff_type, 1003).

%% @doc 移除变身状态
do_remove_skin_buff(Unique, Module, Method, RoleID, PID) ->
    case common_transaction:transaction(
           fun() ->
                   t_do_remove_skin_buff(RoleID)
           end)
    of
        {atomic, {Silver, SilverBind}} ->
            %% 移除BUFF
            mod_role_buff:remove_buff(RoleID, RoleID, role, ?skin_buff_type),
            %% 通知银两变动
            SilverChange = #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=Silver},
            SilverBindChange = #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=SilverBind},
            DataRecord2 = #m_role2_attr_change_toc{roleid=RoleID, changes=[SilverChange, SilverBindChange]},
            common_misc:unicast2(PID, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord2),

            DataRecord = #m_role2_remove_skin_buff_toc{};
        {aborted, Reason} when is_binary(Reason) ->
            DataRecord = #m_role2_remove_skin_buff_toc{succ=false, reason=Reason};
        {aborted, Reason} ->
            ?ERROR_MSG("do_remove_skin_buff, error: ~w", [Reason]),
            DataRecord = #m_role2_remove_skin_buff_toc{succ=false, reason=?_LANG_ROLE2_REMOVE_SKIN_BUFF_ERROR}
    end,

    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

t_do_remove_skin_buff(RoleID) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{silver=Silver, silver_bind=SilverBind} = RoleAttr,
    
    case Silver+SilverBind >= ?remove_skin_buff_price of
        true ->
            ok;
        _ ->
            common_transaction:abort(?_LANG_ROLE2_REMOVE_SKIN_BUFF_NOT_ENOUGH_SILVER)
    end,

    {RestSilver, RestSilverBind} = calc_rest_money(Silver, SilverBind, ?remove_skin_buff_price),
    RoleAttr2 = RoleAttr#p_role_attr{silver=RestSilver, silver_bind=RestSilverBind},
    mod_map_role:set_role_attr(RoleID, RoleAttr2),

    %% 消费日志
    common_consume_logger:use_silver({RoleID, SilverBind-RestSilverBind, Silver-RestSilver, ?CONSUME_TYPE_SILVER_CHANGE_SKIN,
                                      ""}),
    
    {RestSilver, RestSilverBind}.

%% @doc 设置是否显示装备特效
do_show_equip_ring(Unique, Module, Method, DataIn, RoleID, PID, MapState) ->
    #m_role2_show_equip_ring_tos{show_equip_ring=ShowEquipRing} = DataIn,
    
    case common_transaction:transaction(
           fun() ->
                   {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
                   RoleAttr2 = RoleAttr#p_role_attr{show_equip_ring=ShowEquipRing},
                   mod_map_role:set_role_attr(RoleID, RoleAttr2)
           end)
    of
        {atomic, _} ->
            mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.show_equip_ring, ShowEquipRing}], MapState),
            DataRecord = #m_role2_show_equip_ring_toc{show_equip_ring=ShowEquipRing};

        {aborted, Reason} ->
            ?ERROR_MSG("do_show_equip_ring, error: ~w", [Reason]),
            DataRecord = #m_role2_show_equip_ring_toc{succ=false, reason=?_LANG_ROLE2_SHOW_EQUIP_RING_ERROR}
    end,
    
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 头像
do_head(Unique, Module, Method, DataIn, RoleID, PID, MapState) ->
    #m_role2_head_tos{head_id=HeadID} = DataIn,
    %% 检测头像ID是否合法
    case check_head_id_illegal(HeadID) of
        ok ->
            do_head2(Unique, Module, Method, HeadID, RoleID, PID, MapState);
        {error, Reason} ->
            do_head_error(Unique, Module, Method, RoleID, Reason, PID)
    end.

do_head2(Unique, Module, Method, HeadID, RoleID, PID, MapState) ->
    case common_transaction:transaction(
           fun() ->
                   t_do_head(RoleID, HeadID)
           end)
    of
        {atomic, {ok, reduce_money, Silver, SilverBind, Skin}} ->
            DataRecord = #m_role2_head_toc{head_id=HeadID},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord),
            %% 通知银两变动
            SilverChange = #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=Silver},
            SilverBindChange = #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=SilverBind},
            DataRecord2 = #m_role2_attr_change_toc{roleid=RoleID, changes=[SilverChange, SilverBindChange]},
            common_misc:unicast2(PID, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord2),
            %% 广播皮肤变动
            mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.skin, Skin}], MapState),
            %% 世界广播
            broadcast_head_change(RoleID),
            ok;
        {atomic, {ok, reduce_card, ChangeList, DelList, Skin}} ->
            %% 返回结果
            DataRecord = #m_role2_head_toc{head_id=HeadID},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord),
            %% 通知物品变动
            case ChangeList of
                []->
                    [Goods] = DelList,
                    item_used_log([Goods#p_goods{current_num=1}]),
                    common_misc:del_goods_notify({role, RoleID}, DelList);
                _->
                    [Goods] = ChangeList,
                    item_used_log([Goods#p_goods{current_num=1}]),
                    common_misc:update_goods_notify({role, RoleID}, Goods)
            end,
            %% 广播皮肤变动
            mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.skin, Skin}], MapState),
            %% 世界广播
            broadcast_head_change(RoleID),
            ok;
        {aborted, Reason} when is_binary(Reason) ->
            do_head_error(Unique, Module, Method, RoleID, Reason, PID);
        {aborted, Reason} ->
            ?ERROR_MSG("do_head, error: ~w", [Reason]),
            do_head_error(Unique, Module, Method, RoleID, ?_LANG_ROLE2_HEAD_SYSTEM_ERROR, PID)
    end.

do_head_error(Unique, Module, Method, _RoleID, Reason, PID) ->
    DataRecord = #m_role2_head_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

t_do_head(RoleID, HeadID) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{skin=Skin, silver=Silver, silver_bind=SilverBind} = RoleAttr,
    %% 先减头像卡
    {ReduceType, ReturnA, ReturnB} =
        case catch mod_bag:decrease_goods_by_typeid(RoleID, ?head_card_typeid, 1) of
            {ok, UpdateList, DelList} ->
                Skin2 = Skin#p_skin{skinid=HeadID},
                RoleAttr2 = RoleAttr#p_role_attr{skin=Skin2},
                mod_map_role:set_role_attr(RoleID, RoleAttr2),
                {reduce_card, UpdateList, DelList};

            _ ->
                case Silver + SilverBind < ?CHANGE_HEAD_PRICE of
                    true ->
                        common_transaction:abort(?_LANG_ROLE2_HEAD_NOT_ENOUGH_SILVER);
                    _ ->
                        ok
                end,

                {Silver2 , SilverBind2} = calc_rest_money(Silver, SilverBind, ?CHANGE_HEAD_PRICE),

                Skin2 = Skin#p_skin{skinid=HeadID},
                RoleAttr2 = RoleAttr#p_role_attr{skin=Skin2, silver=Silver2, silver_bind=SilverBind2},
                mod_map_role:set_role_attr(RoleID, RoleAttr2),

                %% 消费日志
                common_consume_logger:use_silver({RoleID, SilverBind-SilverBind2, Silver-Silver2, ?CONSUME_TYPE_SILVER_CHANGE_HEAD,
                                                  ""}),

                {reduce_money, Silver2, SilverBind2}
        end,

    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    mod_map_role:set_role_base(RoleID, RoleBase#p_role_base{head=HeadID}),

    {ok, ReduceType, ReturnA, ReturnB, Skin2}.

do_hair(Unique, Module, Method, DataIn, RoleID, PID, MapState) ->
    #m_role2_hair_tos{hair_type=HairType, hair_color=HairColor} = DataIn,
    
    case check_hair_type_color_illegal(HairType, HairColor) of
        ok ->
            do_hair2(Unique, Module, Method, HairType, HairColor, RoleID, PID, MapState);
        {error, Reason} ->
            do_hair_error(Unique, Module, Method, RoleID, Reason, PID)
    end.

do_hair2(Unique, Module, Method, HairType, HairColor, RoleID, PID, MapState) ->
    case common_transaction:transaction(
           fun() ->
                   t_do_hair(RoleID, HairType, HairColor)
           end)
    of
        {atomic, {ok, reduce_money, Silver, SilverBind, Skin}} ->
            common_misc:unicast2(PID, Unique, Module, Method, #m_role2_hair_toc{}),

            %% 通知银两变动
            SilverChange = #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=Silver},
            SilverBindChange = #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=SilverBind},
            DataRecord2 = #m_role2_attr_change_toc{roleid=RoleID, changes=[SilverChange, SilverBindChange]},
            common_misc:unicast2(PID, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord2),            
            %% 广播玩家皮肤变动
            mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.skin, Skin}], MapState),
            %% 世界广播
            broadcast_hair_change(RoleID);

        {atomic, {ok, reduce_card, ChangeList, DelList, Skin}} ->
            %% 返回结果
            common_misc:unicast2(PID, Unique, Module, Method, #m_role2_hair_toc{}),
            %% 通知物品变动
            case ChangeList of
                []->
                    [Goods] = DelList,
                    item_used_log([Goods#p_goods{current_num=1}]),
                    common_misc:del_goods_notify({role, RoleID}, DelList);
                _->
                    [Goods] = ChangeList,
                    item_used_log([Goods#p_goods{current_num=1}]),
                    common_misc:update_goods_notify({role, RoleID}, Goods)
            end,
            %% 广播玩家皮肤变动
            mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.skin, Skin}], MapState),
            %% 世界广播
            broadcast_hair_change(RoleID);

        {aborted, Reason} when is_binary(Reason) ->
            do_hair_error(Unique, Module, Method, RoleID, Reason, PID);
        {aborted, Reason} ->
            ?ERROR_MSG("do_hair, error: ~w", [Reason]),
            do_hair_error(Unique, Module, Method, RoleID, ?_LANG_SYSTEM_ERROR, PID)
    end.

do_hair_error(Unique, Module, Method, _RoleID, Reason, PID) ->
    DataRecord = #m_role2_hair_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

do_sex(Unique, Module, Method, _DataIn, RoleID, PID, MapState, Line) ->
    case common_transaction:transaction(
           fun() ->
                   t_do_sex(RoleID)
           end)
    of
        {atomic, {ok, Sex2, Skin2, UnloadEquips, Gold, GoldBind}} ->
            ?DEBUG("~w, ~w, ~w", [Sex2, Skin2, UnloadEquips]),
            case UnloadEquips of
                [] ->
                    ok;
                _ ->
                    %% 通知玩家背包变动
                    common_misc:new_goods_notify({line, Line, RoleID}, UnloadEquips),
                    %% 属性改变
                    mod_map_role:attr_change(RoleID)
            end,
            %%把送花得分清零
            db:dirty_write(?DB_ROLE_GIVE_FLOWERS,#r_give_flowers{role_id=RoleID,score=0}),
            hook_map_role:sex_change(RoleID, Sex2),
            case Sex2 of
                2-> %%切掉之后要把当初送花榜清掉
                    catch global:send(mgeew_ranking,{ranking_element_update,ranking_give_flowers,{clear,RoleID}}),
                    catch global:send(mgeew_ranking,{ranking_element_update,ranking_give_flowers_today,{clear,RoleID}});
                _-> 
                    catch global:send(mgeew_ranking,{ranking_element_update,ranking_rece_flowers,{clear,RoleID}}),
                    catch global:send(mgeew_ranking,{ranking_element_update,ranking_rece_flowers_today,{clear,RoleID}})
            end,
            RC = #m_role2_attr_change_toc{roleid=RoleID,
                                          changes=[#p_role_attr_change{change_type=?ROLE_CHARM_CHANGE,new_value=0}]},
            common_misc:unicast2(PID, ?DEFAULT_UNIQUE,?ROLE2,?ROLE2_ATTR_CHANGE,RC),
            %% 金钱变动
            GoldChange = #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=Gold},
            GoldBindChange = #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=GoldBind},
            Record = #m_role2_attr_change_toc{roleid=RoleID, changes=[GoldChange, GoldBindChange]},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, Record),
            %% 变性成功
            common_misc:unicast2(PID, Unique, Module, Method, #m_role2_sex_toc{sex=Sex2}),
            %% 广播性别及皮肤变化
            mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.skin, Skin2}], MapState),
            %% 成功变性广播
            common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER, ?BC_MSG_SUB_TYPE, ?_LANG_ROLE2_SEX_BROADCAST_MSG),
            ok;
        {aborted, Reason} when is_binary(Reason); is_list(Reason) ->
            do_sex_error(Unique, Module, Method, RoleID, Reason, PID);
        {aborted, Reason} ->
            ?ERROR_MSG("do_sex, error: ~w", [Reason]),
            do_sex_error(Unique, Module, Method, RoleID, ?_LANG_SYSTEM_ERROR, PID)
    end.

do_sex_error(Unique, Module, Method, _RoleID, Reason, PID) ->
    DataRecord = #m_role2_sex_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

t_do_sex(RoleID) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{gold=Gold, gold_bind=GoldBind, equips=Equips} = RoleAttr,
    
    case Gold + GoldBind < ?SEX_CHANGE_PRICE of
        true ->
            common_transaction:abort(?_LANG_ROLE2_SEX_NOT_ENOUGH_GOLD);
        _ ->
            ok
    end,

    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    #p_role_base{sex=Sex} = RoleBase,
    Sex2 = if Sex =:= 1 ->
                   2;
              true -> 1
           end,

    {_Equips2, EquipsUnload} =
        lists:foldl(
          fun(Equip, {EquipT, UnloadT}) ->
                  #p_goods{typeid=TypeID} = Equip,
                  [EquipBaseInfo] = common_config_dyn:find_equip(TypeID),
                  #p_equip_base_info{requirement=Require} = EquipBaseInfo,
                  #p_use_requirement{sex=SexRequire} = Require,

                  %% 如果是变性后仍能够穿的装备就不用换下来了
                  case SexRequire =:= 0 orelse SexRequire =:= Sex2 of
                      true ->
                          {[Equip|EquipT], UnloadT};
                      _ ->
                          {EquipT, [Equip|UnloadT]}
                  end
          end, {[], []}, Equips),
    ?DEBUG("t_do_sex, equips2: ~w, equipsunload: ~w", [Equips, EquipsUnload]),

    {RoleBase2, RoleAttr2, NewEquips} =
        case EquipsUnload of
            [] ->
                {RoleBase, RoleAttr, []};
            _ ->
                lists:foldl(
                  fun(UnloadInfo, {RoleBaseT, RoleAttrT, NewEquipsT}) ->
                          try
                              {ok, RB, RA, NE, _} = mod_equip:t_common_unload_equip(RoleBaseT, RoleAttrT, UnloadInfo, 0, 0),
                              {RB, RA, [NE|NewEquipsT]}
                          catch
                              _:{bag_error,not_enough_pos} ->
                                  EquipName = common_goods:get_notify_goods_name(UnloadInfo),
                                  common_transaction:abort(lists:flatten(io_lib:format(?_LANG_ROLE2_SEX_NOT_ENOUGH_BAG_SAPCE, [EquipName])));
                              _:_ ->
                                  common_transaction:abort(?_LANG_SYSTEM_ERROR)
                          end
                  end, {RoleBase, RoleAttr, []}, EquipsUnload)
        end,
    ?DEBUG("t_do_sex, newequips: ~w", [NewEquips]),

    #p_role_attr{skin=Skin} = RoleAttr2,
    {ok, SkinID, HairType} = get_new_skin_and_hair(Sex2),
    Skin2 = Skin#p_skin{skinid=SkinID, hair_type=HairType, hair_color=1},
    {Gold2, GoldBind2} = calc_rest_money(Gold, GoldBind, ?SEX_CHANGE_PRICE),
    RoleAttr3 = RoleAttr2#p_role_attr{gold=Gold2, gold_bind=GoldBind2, skin=Skin2,charm=0},
    
    %% 消费日志
    common_consume_logger:use_gold({RoleID, GoldBind-GoldBind2, Gold-Gold2, ?CONSUME_TYPE_GOLD_SEX_CHANGE,
                                      ""}),

    RoleBase3 = RoleBase2#p_role_base{sex=Sex2, head=SkinID},
    mod_map_role:set_role_attr(RoleID, RoleAttr3),
    mod_map_role:set_role_base(RoleID, RoleBase3),
    {ok, Sex2, Skin2, NewEquips, Gold2, GoldBind2}.

t_do_hair(RoleID, HairType, HairColor) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{skin=Skin, silver=Silver, silver_bind=SilverBind} = RoleAttr,
    %% 先减发型卡
    case catch mod_bag:decrease_goods_by_typeid(RoleID, ?hair_card_typeid, 1) of
        {ok, UpdateList, DelList} ->
            Skin2 = Skin#p_skin{hair_type=HairType, hair_color=HairColor},
            RoleAttr2 = RoleAttr#p_role_attr{skin=Skin2},
            mod_map_role:set_role_attr(RoleID, RoleAttr2),

            {ok, reduce_card, UpdateList, DelList, Skin2};

        _ ->
            case Silver + SilverBind < ?HAIR_CUT_PRICE of
                true ->
                    common_transaction:abort(?_LANG_ROLE2_HAIR_NOT_ENOUGH_SILVER);
                _ ->
                    ok
            end,

            {Silver2 , SilverBind2} = calc_rest_money(Silver, SilverBind, ?HAIR_CUT_PRICE),

            Skin2 = Skin#p_skin{hair_type=HairType, hair_color=HairColor},
            RoleAttr2 = RoleAttr#p_role_attr{skin=Skin2, silver=Silver2, silver_bind=SilverBind2},
            mod_map_role:set_role_attr(RoleID, RoleAttr2),

            %% 消费日志
            common_consume_logger:use_silver({RoleID, SilverBind-SilverBind2, Silver-Silver2, ?CONSUME_TYPE_SILVER_HAIR_CUT,
                                              ""}),

            {ok, reduce_money, Silver2, SilverBind2, Skin2}
    end.

check_hair_type_color_illegal(_HairType, _HairColor) ->
    ok.

calc_rest_money(Money, MoneyBind, MoneyNeed) ->
    case MoneyBind - MoneyNeed >= 0 of
        true ->
            {Money, MoneyBind-MoneyNeed};
        _ ->
            {Money-(MoneyNeed-MoneyBind), 0}
    end.

%% 国王
-define(role_type_king, 1).

%% @doc 上线广播
online_broadcast(_RoleID, RoleName, _PID, OfficeID, FactionID) ->
    if
        OfficeID =:= ?OFFICE_ID_KING ->
            DataRecord = #m_role2_online_broadcast_toc{role_type=?role_type_king, 
                                                       role_name=RoleName,
                                                       faction_id = FactionID},
            common_misc:chat_broadcast_to_faction(FactionID, ?ROLE2, ?ROLE2_ONLINE_BROADCAST, DataRecord);
        true ->
            ignore
    end.

%% @doc 变性后随机生成头像及头发ID
get_new_skin_and_hair(Sex) ->
    Random = common_tool:random(6, 9),
    {ok, 2*Random+Sex, (Random rem 3) + 1}.

%% @doc 复活
do_relive(Unique, Module, Method, RoleID, ReliveType) -> 
    case common_transaction:transaction(
           fun() ->
                   t_do_relive(RoleID, ReliveType)
           end)
    of
        {atomic, {HP, MP, RoleBase, Silver, BindSilver}} ->

            %%取消自动复活定时
            case get({auto_relive_timer_ref, RoleID}) of
                undefined ->
                    ok;
                TimerRef ->
                    erlang:cancel_timer(TimerRef),
                    erase({auto_relive_timer_ref, RoleID})
            end,

            if is_tuple(ReliveType) ->
                    ReliveType2 = ?RELIVE_TYPE_PLAIN;
               true ->
                    ReliveType2 = ReliveType
            end,
            
            mod_map_role:handle({relive, RoleID, ReliveType2, {HP, MP, RoleBase}, Unique}, mgeem_map:get_state()),

            case Silver =/= -1 of
                true ->
                    SilverChange = #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=Silver},
                    BindSilverChange = #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=BindSilver},

                    Record = #m_role2_attr_change_toc{roleid=RoleID, changes=[SilverChange, BindSilverChange]},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, Record);

                false ->
                    ok
            end;

        {aborted, R} when is_binary(R) ->
            do_relive_error(Unique, Module, Method, RoleID, R);

        {aborted, R} ->
            ?ERROR_MSG("do_relive, error: ~w", [R]),

            do_relive_error(Unique, Module, Method, RoleID, ?_LANG_SYSTEM_ERROR)
    end.

%%复活
do_relive(Unique, Module, Method, RoleID, DataIn, _Line) ->
    ReliveType = DataIn#m_role2_relive_tos.type,
    do_relive(Unique, Module, Method, RoleID, ReliveType).

do_relive_error(Unique, Module, Method, RoleID, Reason) ->
    Record = #m_role2_relive_toc{succ=false, reason=Reason},
    common_misc:unicast({role, RoleID}, Unique, Module, Method, Record).

t_do_relive(RoleID, ReliveType) ->
    {ok,#p_role_base{status=Status}=RoleBase} = mod_map_role:get_role_base(RoleID),
    
    case Status =/= ?ROLE_STATE_DEAD of
        true ->
            common_transaction:abort(?_LANG_ROLE2_RELIVE_NOT_DEAD);
        _ ->
            ok
    end,

    RoleBase2 = RoleBase#p_role_base{status=?ROLE_STATE_NORMAL},
    mod_map_role:set_role_base(RoleID,RoleBase2),

    DeadTime = get({role_dead_time, RoleID}),
    erase({role_dead_time, RoleID}),
    
    case ReliveType of
        ?RELIVE_TYPE_BACK_CITY ->
            t_do_relive_back_city(RoleID, RoleBase2);

        ?RELIVE_TYPE_PLAIN ->
            t_do_relive_plain(RoleID, RoleBase2, DeadTime);

        ?RELIVE_TYPE_PLAIN_MONEY ->
            t_do_relive_plain_money(RoleID, RoleBase2);

        {?RELIVE_TYPE_SKILL, ResumRate} ->
            t_do_relive_skill(RoleID, RoleBase2, ResumRate);
        
        _ ->
            common_transaction:abort(?_LANG_ROLE2_RELIVE_BAD_TYPE)
    end.

t_do_relive_back_city(_RoleID, RoleBase) ->
    #p_role_base{max_hp=MaxHP, max_mp=MaxMP} = RoleBase,
    {MaxHP, MaxMP, RoleBase, -1, -1}.

t_do_relive_plain(_RoleID, RoleBase, DeadTime) ->
    case DeadTime =:= undefined orelse common_tool:now()-DeadTime >= ?PLAIN_RELIVE_INTERVAL of
        true ->
            #p_role_base{max_hp=MaxHP, max_mp=MaxMP} = RoleBase,
            {common_tool:ceil(MaxHP*0.2), common_tool:ceil(MaxMP), RoleBase, -1, -1};
        _ ->
            common_transaction:abort(?_LANG_ROLE2_RELIVE_ILLEGAL_INTERVAL)
    end.

t_do_relive_skill(_RoleID, RoleBase, ResumRate) ->
    #p_role_base{max_hp=MaxHP, max_mp=MaxMP} = RoleBase,
    {common_tool:ceil(MaxHP*ResumRate/10000), common_tool:ceil(MaxMP*ResumRate/10000), RoleBase, -1, -1}.

t_do_relive_plain_money(RoleID, RoleBase) ->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{equips=Equips, level=Level, silver=Silver, silver_bind=BindSilver} = RoleAttr,
    #p_role_base{faction_id=FactionID, max_hp=MaxHP, max_mp=MaxMP} = RoleBase, 

    SilverNeed = mod_map_role:get_relive_silver(FactionID, Level, Equips, mgeem_map:get_state()),
    {RestSilver, RestBindSilver} = calc_rest_silver(Silver, BindSilver, SilverNeed),

    case RestSilver of
        error ->
            common_transaction:abort(?_LANG_NOT_ENOUGH_SILVER);
        _ ->
            ok
    end,

    %%consume log
    common_consume_logger:use_silver({RoleID, BindSilver-RestBindSilver, Silver-RestSilver, ?CONSUME_TYPE_SILVER_RELIVE, 
                                      ""}),

    RoleAttr2 = RoleAttr#p_role_attr{silver=RestSilver, silver_bind=RestBindSilver},
    mod_map_role:set_role_attr(RoleID,RoleAttr2),

    {MaxHP, MaxMP, RoleBase, RestSilver, RestBindSilver}.

%% 分配属性点
do_point_assgin(Unique, Module, Method, DataIn, RoleID, Line) ->
    #m_role2_pointassign_tos{type=Type, value=Value} = DataIn,

    case common_transaction:transaction(fun() -> t_do_point_assign(RoleID, Type, Value) end) of
        {atomic, {ok, RoleAttr, RoleBase}} ->
            DataRecord = #m_role2_pointassign_toc{succ=true},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord),

            %% hook_attr_point_assign:hook({RoleID, RoleBase, Value}),

            RReload = #m_role2_reload_toc{role_base=RoleBase, role_attr=RoleAttr},
            common_misc:unicast(Line, RoleID, Unique, ?ROLE2, ?ROLE2_RELOAD, RReload),
            %% 成就 add by caochuncheng 2011-09-08 
            common_hook_achievement:hook({mod_role2,{point_assgin,RoleID}}),
            ok;
        {aborted, _Error} ->
            DataRecord = #m_role2_pointassign_toc{succ=false, reason=?_LANG_ROLE2_NO_ENOUGH_POINTS},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord)
    end.

t_do_point_assign(RoleID, Type, Value) ->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
    RemainPoints = RoleBase#p_role_base.remain_attr_points,
    case RemainPoints >= Value andalso Value > 0 of
        true ->
            NewRemainPoints = RemainPoints - Value,
            case Type of
                ?ATTR_STR ->
                    NewRoleBase = RoleBase#p_role_base{
                                    remain_attr_points=NewRemainPoints, 
                                    base_str=(RoleBase#p_role_base.base_str)+Value};
                ?ATTR_CON ->
                    NewRoleBase = RoleBase#p_role_base{
                                    remain_attr_points=NewRemainPoints,
                                    base_con=(RoleBase#p_role_base.base_con)+Value};
                ?ATTR_INT ->
                    NewRoleBase = RoleBase#p_role_base{
                                    remain_attr_points=NewRemainPoints,
                                    base_int=(RoleBase#p_role_base.base_int)+Value};
                ?ATTR_MEN ->
                    NewRoleBase = RoleBase#p_role_base{
                                    remain_attr_points=NewRemainPoints,
                                    base_men=(RoleBase#p_role_base.base_men)+Value};
                _ ->
                    NewRoleBase = RoleBase#p_role_base{
                                    remain_attr_points=NewRemainPoints,
                                    base_dex=(RoleBase#p_role_base.base_dex)+Value}
            end,

            {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
            case mod_map_role:calc_attr(RoleAttr, NewRoleBase) of
                {error, Reason} ->
                    common_transaction:abort(Reason);
                {ok, RoleAttr2, NewRoleBase2} ->
                    mod_map_role:set_role_attr(RoleID,RoleAttr2),
                    mod_map_role:set_role_base(RoleID,NewRoleBase2),
                    {ok, RoleAttr2, NewRoleBase2}
            end;
        false ->
            common_transaction:abort(?_LANG_ROLE2_NO_ENOUGH_POINTS)
    end.
%% 进入大明宝藏地图自动设置玩家PK模式
do_pk_mode_modify_for_10500(RoleID,PKMode) ->
    DataIn = #m_role2_pkmodemodify_tos{pk_mode=PKMode},
    Line = common_misc:get_role_line_by_id(RoleID),
    do_pk_mode_modify(?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_PKMODEMODIFY, RoleID, DataIn, Line).

%% 修改PK模式
do_pk_mode_modify(Unique, Module, Method, RoleID, DataIn, Line) ->
    #m_role2_pkmodemodify_tos{pk_mode=PKMode} = DataIn,
    case PKMode =< ?MAX_PK_MODE of
        true ->
            case common_transaction:transaction(fun() -> t_do_modify_pk_mode(RoleID, PKMode) end) of
                {atomic, _} ->
                    global:send(mgeel_stat_server,{pk_mode_modify,RoleID,PKMode}),
                    mod_map_pet:hook_role_pk_mode_change(RoleID,PKMode),
                    R = #m_role2_pkmodemodify_toc{succ=true,pk_mode = PKMode};
                {aborted, Error} ->
                    ?ERROR_MSG("do_pk_mode_modify, error: ~w", [Error]),
                    R = #m_role2_pkmodemodify_toc{succ=false, reason=?_LANG_SYSTEM_ERROR}
            end;
        false ->
            R = #m_role2_pkmodemodify_toc{succ=false, reason=?_LANG_PK_MODE_NOT_EXIST}
    end,
    %% ?DEBUG("~ts,R=~w",["修改PK模式返回值为",R]),
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

t_do_modify_pk_mode(RoleID, PKMode) ->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
    case RoleBase#p_role_base.pk_mode =:= PKMode of
        true ->
            ok;
        false ->
            NewRoleBase = RoleBase#p_role_base{pk_mode=PKMode},
            mod_map_role:set_role_base(RoleID,NewRoleBase)
    end.

%% @doc 打坐
do_zazen(Unique, Module, Method, RoleID, DataIn, Line) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            ignore;
        RoleMapInfo ->
            case common_misc:is_role_self_stalling(RoleID) of
                true ->
                    do_zazen_error(Unique, Module, Method, RoleID, ?_LANG_ROLE2_WRONG_STATUS, Line);
                _ ->
                    do_zazen2(Unique, Module, Method, RoleID, RoleMapInfo, DataIn, Line)
            end
    end.

do_zazen2(Unique, Module, Method, RoleID, RoleMapInfo, DataIn, Line) ->
    %% status: true -> 打坐; false -> 取消打坐
    #m_role2_zazen_tos{status=ToState} = DataIn,
    case common_transaction:transaction(
           fun() ->
                   t_do_zazen(RoleID, ToState, RoleMapInfo)
           end)
    of
        {atomic, {ok, RoleMapInfo2}} ->
            mod_map_actor:set_actor_mapinfo(RoleID, role, RoleMapInfo2),
            %%强制玩家下马
            mod_equip_mount:force_mountdown(RoleID),
            %% 成就 add by caochuncheng 2011-03-08 
            common_hook_achievement:hook({mod_role2,{zazen,RoleID}}),
            case ToState of 
                true->
                    mod_role_on_zazen:add_map_role_on_zazen(RoleMapInfo2),
                    ReturnSelf = #m_role2_zazen_toc{status=ToState};
                false->
                    {ok,SumExp} = mod_role_on_zazen:del_map_role_on_zazen(RoleID),
                    ReturnSelf = #m_role2_zazen_toc{status=ToState,sum_exp=SumExp}
            end,
            common_misc:unicast(Line, RoleID, Unique, Module, Method, ReturnSelf),
            ToOther = #m_role2_zazen_toc{roleid=RoleID, return_self=false, status=ToState},
            mgeem_map:do_broadcast_insence([{role, RoleID}], Module, Method, ToOther, mgeem_map:get_state());
        {aborted, Reason}  when is_binary(Reason) ->
            do_zazen_error(Unique, Module, Method, RoleID, Reason, Line);
        {aborted, Reason} ->
            ?ERROR_MSG("do_zazen, error: ~w", [Reason]),
            do_zazen_error(Unique, Module, Method, RoleID, ?_LANG_SYSTEM_ERROR, Line)
    end.

t_do_zazen(RoleID, ToState, RoleMapInfo) ->
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    #p_role_base{status=RoleState} = RoleBase,

    if
        RoleState =:= ?ROLE_STATE_NORMAL andalso ToState =:= true -> 
            RoleBase2 = RoleBase#p_role_base{status=?ROLE_STATE_ZAZEN},
            RoleMapInfo2 = RoleMapInfo#p_map_role{state=?ROLE_STATE_ZAZEN},
            mod_map_role:set_role_base(RoleID, RoleBase2),
            {ok, RoleMapInfo2};

        (RoleState =:= ?ROLE_STATE_ZAZEN orelse RoleState =:= ?ROLE_STATE_NORMAL) andalso ToState =:= false ->
            RoleBase2 = RoleBase#p_role_base{status=?ROLE_STATE_NORMAL},
            RoleMapInfo2 = RoleMapInfo#p_map_role{state=?ROLE_STATE_NORMAL},
            mod_map_role:set_role_base(RoleID, RoleBase2),
            {ok, RoleMapInfo2};

        true ->
            common_transaction:abort(?_LANG_ROLE2_WRONG_STATUS)
    end.

do_zazen_error(Unique, Module, Method, RoleID, Reason, Line) ->
    DataRecord = #m_role2_zazen_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).


%% 角色设置五行属性消息接口
%% 角色设置五行属性，即获取五行属性消息处理
do_five_ele_attr(Unique, Module, Method, DataRecord, RoleId, Line) ->
    Type = DataRecord#m_role2_five_ele_attr_tos.type,
    if Type =:= 0 ->
            %% 免费获取五行属性
            do_five_ele_attr2(Unique, Module, Method, DataRecord, RoleId, Line);
       Type =:= 1 ->
            %% 有偿获取五行属性
            do_five_ele_attr3(Unique, Module, Method, DataRecord, RoleId, Line);
       true ->
            Reason = ?_LANG_ROLE2_FIVE_ELE_ATTR_TYPE,
            do_five_ele_attr_error(Unique, Module, Method, Reason, RoleId, Line)
    end.
do_five_ele_attr2(Unique, Module, Method, DataRecord, RoleId, Line) ->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
    Level = RoleAttr#p_role_attr.level,
    if Level < ?DEFAULT_ROLE2_FIVE_ELE_ATTR_MIN_LEVEL ->
            Reason = ?_LANG_ROLE2_FIVE_ELE_ATTR_LEVEL,
            do_five_ele_attr_error(Unique, Module, Method, Reason, RoleId, Line);
       true ->
            do_five_ele_attr2_1(Unique, Module, Method, DataRecord, RoleId, Line, RoleAttr)
    end.
do_five_ele_attr2_1(Unique, Module, Method, DataRecord, RoleId, Line, RoleAttr) ->
    if RoleAttr#p_role_attr.five_ele_attr =/= 0 ->
            Reason = ?_LANG_ROLE2_FIVE_ELE_ATTR_FEE,
            do_five_ele_attr_error(Unique, Module, Method, Reason, RoleId, Line);
       true ->
            do_five_ele_attr2_2(Unique, Module, Method, DataRecord, RoleId, Line)
    end.
do_five_ele_attr2_2(Unique, Module, Method, DataRecord, RoleId, Line) ->
    Type = DataRecord#m_role2_five_ele_attr_tos.type,
    FiveEleAttr = random:uniform(5),
    case catch do_transaction_five_ele(RoleId,FiveEleAttr,Type,0) of
        {error,Reason} ->
            ?DEBUG("~ts,Reason=~w",["免费获取角色五行属性出错",Reason]),
            do_five_ele_attr_error(Unique, Module, Method, Reason, RoleId, Line);
        {ok,NewAttr} ->
            %% 成就第一次获取人物五行属性 add by caochuncheng 2011-03-04
            common_hook_achievement:hook({mod_role2,{first_five_ele_attr,RoleId}}),
            do_five_ele_attr_succ(Unique, Module, Method, DataRecord, RoleId, Line, NewAttr)
    end.

do_five_ele_attr3(Unique, Module, Method, DataRecord, RoleId, Line) ->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),
    Level = RoleAttr#p_role_attr.level,
    if Level < ?DEFAULT_ROLE2_FIVE_ELE_ATTR_MIN_LEVEL ->
            Reason = ?_LANG_ROLE2_FIVE_ELE_ATTR_LEVEL,
            do_five_ele_attr_error(Unique, Module, Method, Reason, RoleId, Line);
       true ->
            do_five_ele_attr4(Unique, Module, Method, DataRecord, RoleId, Line, RoleAttr)
    end.
do_five_ele_attr4(Unique, Module, Method, DataRecord, RoleId, Line, RoleAttr) ->
    FiveEleAttr = RoleAttr#p_role_attr.five_ele_attr,
    if FiveEleAttr =:= 0 ->
            Reason = ?_LANG_ROLE2_FIVE_ELE_ATTR_RE_GET,
            do_five_ele_attr_error(Unique, Module, Method, Reason, RoleId, Line);
       true ->
            do_five_ele_attr5(Unique, Module, Method, DataRecord, RoleId, Line)
    end.

do_five_ele_attr5(Unique, Module, Method, DataRecord, RoleId, Line) ->
    Type = DataRecord#m_role2_five_ele_attr_tos.type,
    FiveEleAttr = random:uniform(5),
    case catch do_transaction_five_ele(RoleId,FiveEleAttr,Type,1000) of
        {error,Reason} ->
            ?DEBUG("~ts,Reason=~w",["有偿获取角色五行属性出错",Reason]),
            do_five_ele_attr_error(Unique, Module, Method, Reason, RoleId, Line);
        {ok,NewAttr} ->
            %% 洗刷一次五行 add by caochuncheng 2011-03-04
            common_hook_achievement:hook({mod_role2,{update_five_ele_attr,RoleId}}),
            do_five_ele_attr_succ(Unique, Module, Method, DataRecord, RoleId, Line, NewAttr)
    end.

do_five_ele_attr_succ(Unique, Module, Method, _DataRecord, RoleId, Line, RoleAttr) ->
    Level = RoleAttr#p_role_attr.level,
    FiveEleAttr = RoleAttr#p_role_attr.five_ele_attr,
    FiveEleAttrLevel = if Level >= 0 andalso Level =< 19 ->
                               0;
                          Level >= 20 andalso Level =< 49 ->
                               1;
                          Level >= 50 andalso Level =< 99 ->
                               2;
                          Level >= 100 andalso Level =< 160 ->
                               3;
                          true ->
                               0
                       end,
    SendSelf = #m_role2_five_ele_attr_toc{succ = true, five_ele_attr_level=FiveEleAttrLevel,
                                          five_ele_attr=FiveEleAttr},
    common_misc:unicast(Line, RoleId, Unique, Module, Method, SendSelf),
    AttrChangeList = [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value = RoleAttr#p_role_attr.silver},
                      #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value = RoleAttr#p_role_attr.silver_bind}],
    common_misc:role_attr_change_notify({line, Line, RoleId},RoleId,AttrChangeList).

do_five_ele_attr_error(Unique, Module, Method, Reason, RoleId, Line) ->
    SendSelf = #m_role2_five_ele_attr_toc{succ = false,reason = Reason,
                                          five_ele_attr_level=0,five_ele_attr=0},
    common_misc:unicast(Line, RoleId, Unique, Module, Method, SendSelf).

do_transaction_five_ele(RoleId,FiveEleAttr,Type,Fee) ->
    case common_transaction:transaction(
           fun() ->
                   do_transaction_five_ele2(RoleId,FiveEleAttr,Type,Fee)
           end) of
        {atomic, {ok,RAttr}} ->     
            ?DEBUG("~ts,RoleId=~w",["事务修改角色五行属性成功",RoleId]),
            {ok, RAttr};
        {aborted, Error} ->
            ?ERROR_MSG("~ts,RoleId=~w,Error=~w",["事务修改角色五行属性失败",RoleId,Error]),
            case erlang:is_binary(Error) of 
                true ->
                    erlang:throw({error,Error});
                _ ->
                    erlang:throw({error,?_LANG_ROLE2_FIVE_ELE_ATTR_ERROR})
            end
    end.
do_transaction_five_ele2(RoleId,FiveEleAttr,Type,Fee) ->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleId),  
    RoleAttr2= 
        if Type =:= 1 ->
                SilverBind = RoleAttr#p_role_attr.silver_bind,
                Silver = RoleAttr#p_role_attr.silver,
                if (SilverBind + Silver) < Fee ->
                        db:abort(?_LANG_ROLE2_FIVE_ELE_ATTR_NOT_FEE);
                   true ->
                        next
                end,
                if SilverBind < Fee ->
                        NewSilver = Silver - (Fee - SilverBind),
                        if NewSilver < 0 ->
                                ?ERROR_MSG("~ts",["角色不够银子重洗五行属性"]),
                                db:abort(?_LANG_ROLE2_FIVE_ELE_ATTR_NOT_FEE);
                           true ->
                                %%consume log
                                common_consume_logger:use_silver({RoleId,SilverBind,(Fee - SilverBind),
                                                                  ?CONSUME_TYPE_SILVER_FIVE_ELE_REFRESH,
                                                                  ""}),
                                RoleAttr#p_role_attr{silver_bind=0,silver=NewSilver}
                        end;
                   true ->
                        NewSilverBind = SilverBind - Fee,
                        common_consume_logger:use_silver({RoleId,Fee,0,
                                                          ?CONSUME_TYPE_SILVER_FIVE_ELE_REFRESH,
                                                          ""}),
                        RoleAttr#p_role_attr{silver_bind=NewSilverBind}
                end;
           true ->
                RoleAttr
        end,
    RoleAttr3 = RoleAttr2#p_role_attr{five_ele_attr = FiveEleAttr},
    mod_map_role:set_role_attr(RoleId,RoleAttr3),
    {ok,RoleAttr3}.

do_levelup(Unique, _Module, _Method, _DataIn, RoleID, _Line) ->
    case common_transaction:transaction(
           fun() ->
                   {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                   {ok,RoleBase} = mod_map_role:get_role_base(RoleID),

                   %%训练状态下不给升级
                   State = RoleBase#p_role_base.status,
                   case State of
                       ?ROLE_STATE_TRAINING ->
                           common_transaction:abort(?_LANG_ROLE2_LEVELUP_TRAINING);
                       _ ->
                           ok
                   end,

                   #p_role_attr{exp=Exp, level=Level, next_level_exp=NextLevelExp} = RoleAttr, 

                   %%暂时只开放到100级
                   [MaxLevel] = common_config_dyn:find(etc, max_level),
                   case Level >= MaxLevel of
                       true ->
                           common_transaction:abort(level_full);
                       false ->
                           ok
                   end,
                           
                   case Exp >= NextLevelExp of
                       true ->
                           mod_map_role:t_level_up(RoleAttr, RoleBase, Level, Level+1, Exp-NextLevelExp);
                       false ->
                           common_transaction:abort(exp_not_enough)
                   end
           end) of
        {atomic, {level_up, Level, RoleAttr2, RoleBase2}} ->
            mod_map_role:do_after_level_up(Level, RoleAttr2, RoleBase2, 0, Unique, true);

        {aborted, Error} ->
            ?ERROR_MSG("do_levelup, error: ~w", [Error]),
            error
    end. 

%%是否显示衣服
do_show_cloth(Unique, Module, Method, DataIn, RoleID, Line) ->
    ShowCloth = DataIn#m_role2_show_cloth_tos.show_cloth,

    case common_transaction:transaction(
           fun() ->
                   t_do_show_cloth(RoleID, ShowCloth)
           end)
    of
        {atomic, _} ->
            DataRecord = #m_role2_show_cloth_toc{show_cloth=ShowCloth},

            %%更新角色地图信息
            mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.show_cloth, ShowCloth}], mgeem_map:get_state());
        {aborted, _R} ->
            DataRecord = #m_role2_show_cloth_toc{succ=false, reason=?_LANG_SYSTEM_ERROR}
    end,

    common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord).

t_do_show_cloth(RoleID, ShowCloth) ->
    {ok,RoleAttr}= mod_map_role:get_role_attr(RoleID),
    mod_map_role:set_role_attr(RoleID,RoleAttr#p_role_attr{show_cloth=ShowCloth}).

do_pkpoint_left(Unique, Module, Method, RoleID, Line) ->
    case mod_map_role:get_role_state(RoleID) of
        {error, _} ->
            TimeLeft = 0;
        {ok, #r_role_state2{pkpoint_timer_ref=TimerRef}} ->
            case TimerRef of
                undefined ->
                    TimeLeft = 0;
                _ ->
                    case erlang:read_timer(TimerRef) of
                        false ->
                            TimeLeft = 0;
                        T ->
                            TimeLeft = T
                    end
            end
    end,

    Record = #m_role2_pkpoint_left_toc{time_left=common_tool:ceil(TimeLeft/(1000*60))},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, Record).

do_get_roleattr(Unique, Module, Method, RoleID, DataRecord, Line) ->
    #m_role2_getroleattr_tos{role_id=TargetRoleID,is_check=_IsCheck} = DataRecord,
    Record =
        try
            %% 这里要用脏读，否则查看不了下线玩家的信息
            case mod_map_role:get_role_base(TargetRoleID) of
                {ok, RoleBase} ->
                    ok;
                _ ->
                    {ok, RoleBase} = common_misc:get_dirty_role_base(TargetRoleID)
            end,
            case mod_map_role:get_role_attr(TargetRoleID) of
                {ok, RoleAttr} ->
                    ok;
                _ ->
                    {ok, RoleAttr} = common_misc:get_dirty_role_attr(TargetRoleID)
            end,
            {ok, RoleExt} = common_misc:get_dirty_role_ext(TargetRoleID),
            case db:dirty_read(?DB_ROLE_EDUCATE, TargetRoleID) of
                [#r_educate_role_info{moral_values = MoralValue}] ->
                    ok;
                _ ->
                    MoralValue = 0
            end,
            [#r_sys_config{sys_config=SysConfig}] = db:dirty_read(?DB_SYSTEM_CONFIG, TargetRoleID),
            ByFind = SysConfig#p_sys_config.by_find,
            VipLevel = mod_vip:get_dirty_vip_level(TargetRoleID),
            case mod_map_pet:get_summoned_pet_info(TargetRoleID) of
                undefined ->
                    PetID = 0;
                {PetID, _} ->
                    ok
            end,
            case db:dirty_read(?DB_ROLE_LEVEL_RANK, TargetRoleID) of
                [] ->
                    LevelRank = 0;
                [#p_role_level_rank{ranking=LevelRank}] ->
                    ok
            end,
            RoleInfo = #p_other_role_info{
              role_id=RoleBase#p_role_base.role_id,
              role_name=RoleBase#p_role_base.role_name,
              faction_id=RoleBase#p_role_base.faction_id,
              family_name=RoleBase#p_role_base.family_name,
              five_ele_attr=RoleAttr#p_role_attr.five_ele_attr,
              office_name=RoleAttr#p_role_attr.office_name,
              sex=RoleBase#p_role_base.sex,
              charm=RoleAttr#p_role_attr.charm,
              category=RoleAttr#p_role_attr.category,
              level=RoleAttr#p_role_attr.level,
              level_rank=LevelRank,
              vip_level=VipLevel,
              equips=RoleAttr#p_role_attr.equips,
              gongxun=RoleAttr#p_role_attr.gongxun,
              pk_point=RoleBase#p_role_base.pk_points,
              str=RoleBase#p_role_base.str,
              int2=RoleBase#p_role_base.int2,
              con=RoleBase#p_role_base.con,
              dex=RoleBase#p_role_base.dex,
              men=RoleBase#p_role_base.men,
              max_phy_attack=RoleBase#p_role_base.max_phy_attack,
              min_phy_attack=RoleBase#p_role_base.min_phy_attack,
              max_magic_attack=RoleBase#p_role_base.max_magic_attack,
              min_magic_attack=RoleBase#p_role_base.min_magic_attack,
              double_attack=RoleBase#p_role_base.double_attack,
              phy_defence=RoleBase#p_role_base.phy_defence,
              magic_defence=RoleBase#p_role_base.magic_defence,
              birthday=RoleExt#p_role_ext.birthday,
              province=RoleExt#p_role_ext.province,
              city=RoleExt#p_role_ext.city,
              moral_value= MoralValue,
              pet_id=PetID,
              luck = RoleBase#p_role_base.luck,
              miss = RoleBase#p_role_base.miss,
              no_defence = RoleBase#p_role_base.no_defence,
              hit_rate = RoleBase#p_role_base.hit_rate,
              sum_prestige = RoleAttr#p_role_attr.sum_prestige,
              cur_prestige = RoleAttr#p_role_attr.cur_prestige,
              cur_title = RoleBase#p_role_base.cur_title,
              pk_title = RoleBase#p_role_base.pk_title,
              max_hp = RoleBase#p_role_base.max_hp,
              max_mp = RoleBase#p_role_base.max_mp,
              cur_energy = RoleAttr#p_role_attr.cur_energy,
              max_energy = RoleAttr#p_role_attr.max_energy,
              skin = RoleAttr#p_role_attr.skin
             },
            case ByFind 
                %%andalso IsCheck 
                of 
                true ->
                    {ok, SRoleBase} = mod_map_role:get_role_base(RoleID),
                    #p_role_base{sex=SSex, role_name=SRoleName} = SRoleBase,
                    DSex = RoleBase#p_role_base.sex,
                    Notice = get_target_notice(SSex, SRoleName, DSex),
                    common_broadcast:bc_send_msg_role(TargetRoleID, ?BC_MSG_TYPE_SYSTEM, lists:flatten(Notice));
                _ ->
                    ok
            end,
            #m_role2_getroleattr_toc{role_info=RoleInfo}
        catch
            _ : R ->
                ?ERROR_MSG("do_get_roleattr, r: ~w", [R]),
                #m_role2_getroleattr_toc{succ=false, reason=?_LANG_SYSTEM_ERROR}
        end,
    common_misc:unicast(Line, RoleID, Unique, Module, Method, Record).

do_unbund_change(_Unique, _Module, _Method, RoleID, DataIn) ->
    #m_role2_unbund_change_tos{unbund=Unbund} = DataIn,
    case common_transaction:transaction(
           fun() ->
                   {ok,Attr}= mod_map_role:get_role_attr(RoleID),
                   mod_map_role:set_role_attr(RoleID,Attr#p_role_attr{unbund=Unbund})
           end)
    of
        {aborted, Reason} ->
            ?DEBUG("~ts:~w~n",["更新角色是否不使用绑定货币失败",Reason]);
        {atomic, _} ->
            ?DEBUG("~ts~n",["更新角色是否不使用绑定货币成功！"])
    end.

%% @doc 纪录角色某些事件
do_event(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_role2_event_tos{event_id=EventID} = DataIn,

    case db:transaction(
           fun() ->
                   [RoleExt] = db:read(?DB_ROLE_EXT, RoleID, write),

                   RoleExt2 = 
                       case EventID of
                           ?EVENT_LEVEL_XSC_ID ->
                               RoleExt#p_role_ext{ever_leave_xsc=true};
                           _ ->
                               db:abort(?_LANG_ROLE2_EVENT_ID_NOT_EXIST)
                       end,
                   db:write(?DB_ROLE_EXT, RoleExt2, write)
           end)
    of
        {atomic, _} ->
            DataRecord = #m_role2_event_toc{event_id=EventID};
        {aborted, Reason} when is_binary(Reason) ->
            DataRecord = #m_role2_event_toc{event_id=EventID, reason=Reason};
        {aborted, Reason} ->
            ?ERROR_MSG("do_event, error: ~w", [Reason]),
            DataRecord = #m_role2_event_toc{event_id=EventID, reason=?_LANG_ROLE2_EVENT_SYSTEM_ERROR}
    end,
    
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

get_target_notice(SSex, SRoleName, DSex) ->
    if
        SSex =:= ?SEXMAN andalso DSex =:= ?SEXMAN ->
            io_lib:format(?MANWATCHMAN, [SRoleName]);
        SSex =:= ?SEXMAN andalso DSex =:= ?SEXWOMAN ->
            io_lib:format(?MANWATCHWOMAN, [SRoleName]);
        DSex =:= ?SEXMAN ->
            io_lib:format(?WOMANWATCHMAN, [SRoleName]);
        true ->
            io_lib:format(?WOMANWATCHWOMAN, [SRoleName])
    end.

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
                    {error, not_enough_money}
            end
    end.

%% @doc 头像ID是否合法
check_head_id_illegal(_HeadID) ->
    ok.

%% @doc 世界广播换发型
broadcast_hair_change(RoleID) ->
    {ok, #p_role_base{sex=Sex, role_name=RoleName}} = mod_map_role:get_role_base(RoleID),
    case Sex of
        ?SEXMAN ->
            Msg = io_lib:format(?_LANG_ROLE2_HAIR_BROADCAST_MSG_MALE, [RoleName]);
        _ ->
            Msg = io_lib:format(?_LANG_ROLE2_HAIR_BROADCAST_MSG_FEMALE, [RoleName])
    end,
    common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER, ?BC_MSG_SUB_TYPE, lists:flatten(Msg)).

%% @doc 世界广播换头像
broadcast_head_change(RoleID) ->
    {ok, #p_role_base{sex=Sex, role_name=RoleName}} = mod_map_role:get_role_base(RoleID),
    case Sex of
        ?SEXMAN ->
            Msg = io_lib:format(?_LANG_ROLE2_HEAD_BROADCAST_MSG_MALE, [RoleName]);
        _ ->
            Msg = io_lib:format(?_LANG_ROLE2_HEAD_BROADCAST_MSG_FEMALE, [RoleName])
    end,
    common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER, ?BC_MSG_SUB_TYPE, lists:flatten(Msg)).

%% @doc 道具使用日志
item_used_log(GoodsList) ->
    lists:foreach(
      fun(Goods) ->
              #p_goods{roleid=RoleID}=Goods,
              common_item_logger:log(RoleID,Goods,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU)
      end,GoodsList).

%% Test Func
test_hair(RoleID, HairType, HairColor) ->
    DataIn = #m_role2_hair_tos{hair_type=HairType, hair_color=HairColor},
    common_misc:send_to_rolemap(RoleID, {?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_HAIR, DataIn, RoleID, 0, 0}).

test_sex(RoleID) ->
    common_misc:send_to_rolemap(RoleID, {?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_SEX, 0, RoleID, 0, 0}).
%% GM命令设置玩家五行属性
do_admin_set_role_five_ele_attr(RoleId,FiveEleAttr) ->
    case lists:member(FiveEleAttr,[1,2,3,4,5]) of
        true ->
            case mod_map_role:get_role_attr(RoleId) of
                {ok,RoleAttr} ->
                    common_transaction:transaction(
                      fun() ->
                              mod_map_role:set_role_attr(RoleId,RoleAttr#p_role_attr{five_ele_attr=FiveEleAttr})
                      end);
                _ ->
                    ignore
            end;
        _ ->
            ignore
    end.
%% 当前国家在线玩家榜数据进程字典操作
init_faction_online_role_rank(MapId,FactionId) ->
    erlang:put({faction_online_role_rank,MapId,FactionId},[]).

get_faction_online_role_rank(MapId,FactionId) ->
    erlang:get({faction_online_role_rank,MapId,FactionId}).
    
set_faction_online_role_rank(MapId,FactionId,RoleRankList) ->
    erlang:put({faction_online_role_rank,MapId,FactionId},RoleRankList).

do_admin_join_faction_online_rank({RoleId,RoleName,FactionId,RoleLevel,DoMapId}) ->
    NewRoleRank = #p_faction_online_rank{
      faction_id = FactionId,
      role_id = RoleId,
      role_name = RoleName,
      role_level = RoleLevel
     },
    OnlineRankList = get_faction_online_role_rank(DoMapId,FactionId),
    case OnlineRankList =:= [] of
        true ->
            set_faction_online_role_rank(DoMapId,FactionId,[NewRoleRank]);
        _ ->
            OnlineRankLen = erlang:length(OnlineRankList),
            MinRoleRank = lists:nth(OnlineRankLen,OnlineRankList),
            [MaxRankNumber] = common_config_dyn:find(etc,max_faction_online_role_rank_number),
            case MinRoleRank#p_faction_online_rank.role_level >= RoleLevel of
                true ->
                    case OnlineRankLen >= MaxRankNumber of
                        true ->
                            ignore;
                        _ ->
                            set_faction_online_role_rank(DoMapId,FactionId,lists:append([OnlineRankList,[NewRoleRank]]))
                    end;
                _ ->
                    OnlineRankList2 = 
                        lists:sort(
                          fun(RoleRankA,RoleRankB) ->
                                  RoleRankA#p_faction_online_rank.role_level > RoleRankB#p_faction_online_rank.role_level
                          end,[NewRoleRank|OnlineRankList]),
                    set_faction_online_role_rank(DoMapId,FactionId,lists:sublist(OnlineRankList2,1,MaxRankNumber))
            end
    end,
    ok.

do_admin_quit_faction_online_rank({RoleId,FactionId,DoMapId}) ->
    OnlineRankList = lists:keydelete(RoleId,#p_faction_online_rank.role_id,get_faction_online_role_rank(DoMapId,FactionId)),
    set_faction_online_role_rank(DoMapId,FactionId,OnlineRankList),
    ok.
do_admin_uplevel_faction_online_rank({RoleId,RoleName,FactionId,RoleLevel,DoMapId}) ->
    OnlineRankList = lists:keydelete(RoleId,#p_faction_online_rank.role_id,get_faction_online_role_rank(DoMapId,FactionId)),
    set_faction_online_role_rank(DoMapId,FactionId,OnlineRankList),
    do_admin_join_faction_online_rank({RoleId,RoleName,FactionId,RoleLevel,DoMapId}),
    ok.

%% 查询当前国家在线玩家榜数据
do_query_faction_online_rank(Unique, Module, Method, DataRecord, RoleId, PId) ->
    [DoMapId] = common_config_dyn:find(etc,do_faction_online_role_rank_map_id),
    case mod_map_actor:get_actor_mapinfo(RoleId,role) of
        undefined ->
            Reason = ?_LANG_ROLE2_QUERY_FACTION_ONLINE_RANK_ERROR,
            do_query_faction_online_rank_error(Unique,Module,Method,DataRecord,RoleId,PId,Reason,0);
        #p_map_role{faction_id = FactionId} ->
            global:send(common_map:get_common_map_name(DoMapId),
                        {mod_role2,{admin_query_faction_online_rank,{Unique,Module,Method,DataRecord,RoleId,DoMapId,FactionId}}})
    end.
do_admin_query_faction_online_rank({Unique,Module,Method,DataRecord,RoleId,DoMapId,FactionId}) ->
    OnlineRankList = get_faction_online_role_rank(DoMapId,FactionId),
    SendSelf=#m_role2_query_faction_online_rank_toc{
      op_type = DataRecord#m_role2_query_faction_online_rank_tos.op_type,
      faction_id = DataRecord#m_role2_query_faction_online_rank_tos.faction_id,
      succ = true,
      online_rank = OnlineRankList},
    ?DEBUG("~ts,SendSelf=~w",["查询当前国家在线玩家数据",SendSelf]),
    common_misc:unicast({role,RoleId}, Unique, Module, Method, SendSelf),
    ok.

do_query_faction_online_rank_error(Unique,Module,Method,DataRecord,_RoleId,PId,Reason,ReasonCode) ->
    SendSelf=#m_role2_query_faction_online_rank_toc{
      op_type = DataRecord#m_role2_query_faction_online_rank_tos.op_type,
      faction_id = DataRecord#m_role2_query_faction_online_rank_tos.faction_id,
      succ = false,
      reason = Reason,
      reason_code = ReasonCode,
      online_rank = []},
    ?DEBUG("~ts,SendSelf=~w",["查询当前国家在线玩家数据",SendSelf]),
    common_misc:unicast2(PId, Unique, Module, Method, SendSelf).
