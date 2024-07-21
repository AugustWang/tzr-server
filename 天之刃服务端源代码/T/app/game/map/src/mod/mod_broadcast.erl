%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2010, 
%%% @doc
%%%
%%% @end
%%% Created : 27 Dec 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_broadcast).

-include("mgeem.hrl").

%% API
-export([handle/1]).

%% 默认喇叭消息费用，单位：文，先扣绑定再扣不绑定
-define(DEFAULT_MSG_LABA_SILVER,1000).
%% 扣除道具ID
-define(ITEM_LABA_TYPEID, 10700002).

%%%===================================================================
%%% API
%%%===================================================================

handle(Info) ->
    do_handle(Info).

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% 喇叭消息广播处理
do_handle({Unique, ?BROADCAST, ?BROADCAST_LABA, DataRecord, RoleId, Pid, Line, _MapState}) 
  when erlang:is_record(DataRecord,m_broadcast_laba_tos)->
    do_broadcast_laba({Unique, ?BROADCAST, ?BROADCAST_LABA, DataRecord, RoleId, Pid, Line});

do_handle(Info) ->
    ?ERROR_MSG("mod_broadcast, unknow info: ~w", [Info]).

%% 前台喇叭消息广播处理，直接在此处理逻辑少一次通知过程
do_broadcast_laba({Unique, Module, Method, DataRecord, RoleId, Pid, Line}) ->
    case mod_map_role:get_role_base(RoleId) of
        {ok,RoleBase} ->
            #p_role_base{role_name=RoleName, faction_id=FactionId, sex=Sex} = RoleBase,
            do_broadcast_laba2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},{RoleName,FactionId, Sex});
        {error,Error} ->
            ?ERROR_MSG("~ts,Error=~w",["获取角色信息出错",Error]),
            R = ?_LANG_BROADCAST_LABA_SEND_FAIL,
            do_broadcast_laba_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},{R,"",0, 0})
    end.
do_broadcast_laba2({Unique, Module, Method, DataRecord, RoleId, Pid, Line},{RoleName,FactionId, Sex}) ->
    case catch do_broadcast_laba3({Unique, Module, Method, DataRecord, RoleId, Pid, Line}) of
        {error,R} ->
            do_broadcast_laba_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},{R,RoleName,FactionId, Sex});
        {ok} ->
            do_broadcast_laba4({Unique, Module, Method, DataRecord, RoleId, Pid, Line},{RoleName,FactionId, Sex})
    end.
do_broadcast_laba3({_Unique, _Module, _Method, DataRecord, RoleId, _Pid, _Line}) ->
    Content = DataRecord#m_broadcast_laba_tos.content,
    if Content =:= "" ->
            erlang:throw({error,?_LANG_BROADCAST_LABA_CONTENT_NULL});
       true ->
            next
    end,
    %% 检查是否被禁言
    case common_misc:check_role_chat_ban(RoleId) of
        ok ->
            next;
        {error,Reason} ->
            erlang:throw({error,Reason})
    end,
    {ok}.

do_broadcast_laba4({Unique, Module, Method, DataRecord, RoleId, Pid, Line},{RoleName,FactionId, Sex}) ->
    #m_broadcast_laba_tos{laba_id=LabaID} = DataRecord,

    Result =
        case LabaID of
            0 ->
        catch t_deduct_laba_msg_fee(RoleId);
            _ ->
                deduct_laba_msg_item(RoleId, LabaID)
        end,

    case Result of
        ok ->
            do_broadcast_laba5({Unique, Module, Method, DataRecord, RoleId, Pid, Line},{RoleName,FactionId, Sex});
        {error, Reason} ->
            do_broadcast_laba_error({Unique, Module, Method, DataRecord, RoleId, Pid, Line},{Reason,RoleName,FactionId, Sex})
    end.

do_broadcast_laba5({Unique, Module, Method, DataRecord, RoleId, _Pid, Line},{RoleName,FactionId, Sex}) ->
    %% 成就 add by caochuncheng 2011-03-08
    common_hook_achievement:hook({chat_module,{mod_broadcast,RoleId}}),
    Content = DataRecord#m_broadcast_laba_tos.content,
    SendSelf = #m_broadcast_laba_toc{succ = true,return_self = true,role_id = RoleId,
                                    role_name = RoleName,content = Content,faction_id = FactionId, sex=Sex},
    common_misc:unicast(Line, RoleId, Unique, Module, Method, SendSelf),
    LabaMessage = #m_broadcast_laba_toc{succ = true,return_self = false,role_id = RoleId,
                                    role_name = RoleName,content = Content,faction_id = FactionId, sex=Sex},
    common_misc:chat_broadcast_to_world(Module, Method, LabaMessage).

do_broadcast_laba_error({Unique, Module, Method, DataRecord, RoleId, _Pid, Line},{R,RoleName,FactionId, Sex}) ->
    Content = DataRecord#m_broadcast_laba_tos.content,
    SendSelf = #m_broadcast_laba_toc{succ = false, reason = R,role_id = RoleId,
                                    role_name = RoleName,content = Content,faction_id = FactionId, sex=Sex},
    common_misc:unicast(Line, RoleId, Unique, Module, Method, SendSelf). 

%% 喇叭消息费用，单位：文
get_msg_laba_silver_fee() ->
    case common_config_dyn:find(broadcast,msg_laba_silver) of
        [LabaSilver] -> LabaSilver;
        _ -> ?DEFAULT_MSG_LABA_SILVER
    end.

%% 扣除喇叭消息费用事务操作
t_deduct_laba_msg_fee(RoleId) -> 
    MsgFee = get_msg_laba_silver_fee(),
    case catch common_transaction:transaction(fun() ->  deduct_laba_msg_fee(RoleId,MsgFee)  end) of
        {atomic, {ok, Silver, SilverBind}} ->
            UnicastArg = {role, RoleId},
            AttrChangeList = [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value = Silver},
                              #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value = SilverBind}],
            common_misc:role_attr_change_notify(UnicastArg,RoleId,AttrChangeList),

            ok;
        {aborted, Reason} ->
            case Reason of 
                {error,R} ->
                    erlang:throw({error,R});
                _ ->
                    erlang:throw({error,?_LANG_BROADCAST_LABA_DEDUCT_FEE})
            end                      
    end.

%% 先扣绑定的，当绑定不够扣时，把绑定的扣为0，再扣不绑定的
deduct_laba_msg_fee(RoleId,MsgFee) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleId),
    SilverBind = RoleAttr#p_role_attr.silver_bind,
    Silver = RoleAttr#p_role_attr.silver,
    if SilverBind < MsgFee ->
            NewSilver = Silver - (MsgFee - SilverBind),
            if NewSilver < 0 ->
                    erlang:throw({error,?_LANG_BROADCAST_LABA_ENOUGH_MONEY});
               true ->
                    NewRoleAttr = RoleAttr#p_role_attr{silver_bind=0,silver=NewSilver },
                    mod_map_role:set_role_attr(RoleId, NewRoleAttr),
                    common_consume_logger:use_silver({RoleId, SilverBind, (MsgFee - SilverBind), ?CONSUME_TYPE_SILVER_SEND_LABA, ""}),
                    {ok, NewRoleAttr#p_role_attr.silver, NewRoleAttr#p_role_attr.silver_bind}
            end;
       true ->
            NewSilverBind = SilverBind - MsgFee,
            NewRoleAttr = RoleAttr#p_role_attr{silver_bind=NewSilverBind},
            mod_map_role:set_role_attr(RoleId, NewRoleAttr),
            common_consume_logger:use_silver({RoleId, MsgFee, 0, ?CONSUME_TYPE_SILVER_SEND_LABA, ""}),
            {ok, NewRoleAttr#p_role_attr.silver, NewRoleAttr#p_role_attr.silver_bind}
    end.

deduct_laba_msg_item(RoleID, LabaID) ->
    case common_transaction:transaction(
           fun() ->
                   case mod_bag:get_goods_by_id(RoleID, LabaID) of
                       {error, _} ->
                           throw({bag_error, goods_not_found});
                       {ok, GoodsInfo} ->
                           Result = mod_bag:decrease_goods(RoleID, [{GoodsInfo, 1}]),
                           {ok, GoodsInfo, Result}
                   end
           end)
    of
        {atomic, {ok, GoodsInfo, {ok, [undefined]}}} ->
            common_misc:del_goods_notify({role, RoleID}, GoodsInfo);
        {atomic, {ok, _GoodsInfo, {ok, [GoodsInfo2]}}} ->
            common_misc:update_goods_notify({role, RoleID}, GoodsInfo2);
        {aborted, {throw, {bag_error, goods_not_found}}} ->
            {error, ?_LANG_BROADCAST_LABA_NOT_ENOUGH_LABA};
        {aborted, Error} ->
            ?ERROR_MSG("deduct_laba_msg_item, error: ~w", [Error]),
            {error, ?_LANG_SYSTEM_ERROR}
    end.
