%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2011, 
%%% @doc
%%%
%%% @end
%%% Created : 15 Mar 2011 by  <>
%%%-------------------------------------------------------------------
-module(mod_vip).

-include("mgeem.hrl").

-export([
         handle/1,
         is_role_vip/1,
         get_role_vip_level/1,
         get_dirty_vip_level/1,
         get_vip_shop_discount/1,
         t_vip_active/2,
         notify_vip_info_change/3,
         get_vip_level_info/1,
         %%do_vip_list_info_update/1,
         get_vip_pet_understand_rate/1,
         do_vip_active4/7]).

-export([
         init_role_vip_info/2,
         get_role_vip_info/1,
         erase_role_vip_info/1]).

-export([
         check_vip_valid/2,
         check_can_map_transfer_free/1,
         check_can_refresh_exp_free/2,
         t_check_can_pet_training_free/1]).

-export([
         hook_role_online/2,
         hook_map_init/1
        ]).

-define(vip_multiple_exp_type, 1050).
-define(vip_list_records_per_page, 10).
-define(vip_list_mapid, 10700).
-define(last_update_time, last_update_time).
-define(vip_list_update_interval, 600).

handle({Unique, Module, ?VIP_ACTIVE, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_vip_active(Unique, Module, ?VIP_ACTIVE, DataIn, RoleID, PID);
handle({Unique, Module, ?VIP_MULTI_EXP, _DataIn, RoleID, PID, _Line, _MapState}) ->
    do_vip_multi_exp(Unique, Module, ?VIP_MULTI_EXP, RoleID, PID);
handle({Unique, Module, ?VIP_STOP_NOTIFY, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_vip_stop_notify(Unique, Module, ?VIP_STOP_NOTIFY, DataIn, RoleID, PID);
handle({Unique, Module, ?VIP_LIST, DataIn, RoleID, PID, _Line, _MapState}) ->
    MapName = common_misc:get_map_name(?vip_list_mapid),
    catch global:send(MapName, {mod_vip, {vip_list, Unique, Module, ?VIP_LIST, DataIn, RoleID, PID}});
handle({Unique, Module, ?VIP_REMOTE_DEPOT, _DataIn, RoleID, PID, Line, MapState}) ->
    do_remote_depot(Unique, Module, ?VIP_REMOTE_DEPOT, RoleID, PID, Line, MapState);
handle({Unique, Module, ?VIP_EXCHANGE_PRESTIGE, _DataIn, RoleID, PID, Line, MapState}) ->
    do_exchange_prestige(Unique, Module, ?VIP_EXCHANGE_PRESTIGE, RoleID, PID, Line, MapState);

%% handle({vip_list_insert, VipInfo}) ->
%%     vip_list_insert(VipInfo);
%% handle({vip_list_delete, RoleID, Time}) ->
%%     vip_list_delete(RoleID, Time);
%% handle({vip_list_update, OldTime, VipInfo}) ->
%%     vip_list_update(OldTime, VipInfo);
%% handle({vip_list, Unique, Module, Method, DataIn, RoleID, PID}) ->
%%     do_vip_list(Unique, Module, Method, DataIn, RoleID, PID);

handle(Info) ->
    ?ERROR_MSG("mod_vip, unknow info: ~w", [Info]).

%% @doc 通知VIP信息变动
notify_vip_info_change(_RoleID, PID, VipInfo) ->
    DataRecord = #m_vip_info_toc{vip_info=VipInfo},
    common_misc:unicast2(PID, ?DEFAULT_UNIQUE, ?VIP, ?VIP_INFO, DataRecord).

%% @doc 是否可以累积经验
check_can_refresh_exp_free(RoleID, NowRate) ->
    case get_role_vip_info(RoleID) of
        {ok, VipInfo} ->
            #p_role_vip{is_expire=IsExpire, accumulate_exp_times=Times} = VipInfo,
            [ExpRate] = common_config_dyn:find(vip, exp_rate_below),
            if
                IsExpire ->
                    {error, has_expired};
                Times =< 0 ->
                    {error, all_used};
                NowRate > ExpRate ->
                    {error, exp_rate_above};
                true ->
                    VipInfo2 = VipInfo#p_role_vip{accumulate_exp_times=Times-1},
                    set_role_vip_info(RoleID, VipInfo2, true)
            end;
        _ ->
            {error, not_vip}
    end.

%% @doc 是否可以立即完成宠物训练
t_check_can_pet_training_free(RoleID) ->
    case get_role_vip_info(RoleID) of
        {ok, VipInfo} ->
            #p_role_vip{is_expire=IsExpire, pet_training_times=Times, vip_level=VipLevel} = VipInfo,
            [MinLevel] = common_config_dyn:find(vip, min_pet_training_level),
            if
                IsExpire ->
                    {error, has_expired};
                VipLevel < MinLevel ->
                    {error, level_below};
                Times =< 0 ->
                    {error, all_used};
                true ->
                    VipInfo2 = VipInfo#p_role_vip{pet_training_times=Times-1},
                    t_set_role_vip_info(RoleID, VipInfo2),
                    {ok, VipInfo2}
            end;
        _ ->
            {error, not_vip}
    end.

%% @doc VIP免费传送
check_can_map_transfer_free(RoleID) ->
    case get_role_vip_info(RoleID) of
        {ok, VipInfo} ->
            #p_role_vip{is_expire=IsExpire, mission_transfer_times=MissionTransT, vip_level=VipLevel} = VipInfo,
            if
                IsExpire ->
                    error;
                VipLevel >= 3 ->
                    ok;
                MissionTransT =< 0 ->
                    error;
                true ->
                    VipInfo2 = VipInfo#p_role_vip{mission_transfer_times=MissionTransT-1},
                    set_role_vip_info(RoleID, VipInfo2, true)
            end;
        _ ->
            error
    end.

%% @doc 检测VIP有效期
check_vip_valid(VipInfo, Now) ->
    #p_role_vip{role_id=RoleID, end_time=EndTime, is_expire=IsExpire} = VipInfo,
    if
        IsExpire =:= true ->
            ignore;
        Now >= EndTime ->
            VipInfo2 = VipInfo#p_role_vip{is_expire=true},
            set_role_vip_info(RoleID, VipInfo2, true),
            %% 删除称号
            common_title:remove_by_typeid(?TITLE_VIP, RoleID),
            %% 删除多倍经验
            mod_role_buff:remove_buff(RoleID, RoleID, role, ?vip_multiple_exp_type),
            %% 在VIP列表中移除
            %%MapName = common_misc:get_map_name(?vip_list_mapid),
            %%(catch global:send(MapName, {mod_vip, {vip_list_delete, RoleID, VipInfo#p_role_vip.total_time}})),
            %% 删除名字前面的VIP
            mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.vip_level, 0}], mgeem_map:get_state());
        true ->
            ignore
    end.

%% @doc 角色上线，把VIP数据推过去
hook_role_online(RoleID, PID) ->
    case get_role_vip_info(RoleID) of
        {ok, VipInfo} ->
            DataRecord = #m_vip_info_toc{vip_info=VipInfo};
        _ ->
            DataRecord = #m_vip_info_toc{}
    end,
    common_misc:unicast2(PID, ?DEFAULT_UNIQUE, ?VIP, ?VIP_INFO, DataRecord).

%% @doc 获取角色VIP信息
get_role_vip_info(RoleID) ->
    case erlang:get({?role_vip, RoleID}) of
        undefined ->
            {error, not_found};
        VipInfo ->
            reset_vip_weal(VipInfo)
    end.

%% @doc 重置VIP福利
reset_vip_weal(VipInfo) ->
    #p_role_vip{role_id=RoleID, last_reset_time=LRT, vip_level=VipLevel} = VipInfo,
    LRDate = common_time:time_to_date(LRT),
    Now = common_tool:now(),
    NowDate = common_time:time_to_date(Now),
    %% 隔天重置，VIP属性
    case LRDate =:= NowDate of
        true ->
            {ok, VipInfo};
        _ ->
            {ok, LevelInfo} = get_vip_level_info(VipLevel),
            #r_vip_level_info{multi_exp_times=MET, accumulate_exp_times=AET, mission_transfer_times=MTT, pet_training_times=PTT} = LevelInfo,
            VipInfo2 = VipInfo#p_role_vip{last_reset_time=Now,
                                          multi_exp_times=MET,
                                          accumulate_exp_times=AET, 
                                          mission_transfer_times=MTT,
                                          is_transfer_notice_free=true,
                                          is_transfer_notice=true,
                                          pet_training_times=PTT
                                         },
            set_role_vip_info(RoleID, VipInfo2, true),

            {ok, VipInfo2}
    end.

%% @doc 清除角色VIP信息
erase_role_vip_info(RoleID) ->
    case get_role_vip_info(RoleID) of
        {ok, VipInfo} ->
            mgeem_persistent:role_vip_persistent(VipInfo),
            erlang:erase({?role_vip, RoleID});
        _ ->
            ignore
    end.

%% @doc 开通VIP，time: 时长
t_vip_active(RoleID, VipType) ->
    case get_role_vip_info(RoleID) of
        {error, _} ->
            t_vip_active_new(RoleID, VipType);

        {ok, #p_role_vip{is_expire=true}=VipInfo} ->
            t_vip_active_recharge(RoleID, VipType, VipInfo);

        {ok, VipInfo} ->
            t_vip_active_recharge(RoleID, VipType, VipInfo)
    end.

%% @doc 开通VIP，之前是VIP，而且没过期
t_vip_active_recharge(RoleID, VipType, VipInfo) ->
    [#r_vip_card{last_time=LastTime, time_add=TimeAdd}] = common_config_dyn:find(vip, {vip_card, VipType}),

    #p_role_vip{vip_level=VipLevel,
                end_time=EndTime,
                total_time=TotalTime,
                multi_exp_times=MultiExpT,
                accumulate_exp_times=AccuExpT,
                mission_transfer_times=_MissionTransferT,
                pet_training_times=PetTrainingT,
                remote_depot_num=RemoteDepot,
                last_get_prestige_time=LastGetPrestigeTime} = VipInfo,

    {ok, OldLevelInfo} = get_vip_level_info(VipLevel),
    {ok, VipLevel2} = get_vip_level_by_time(TotalTime+TimeAdd),
    {ok, NewLevelInfo} = get_vip_level_info(VipLevel2),
    #r_vip_level_info{multi_exp_times=OldMultiExpT,
                      accumulate_exp_times=OldAccuExpT,
                      mission_transfer_times=_OldMissionTransferT,
                      pet_training_times=OldPetTrainingT} = OldLevelInfo,

    #r_vip_level_info{multi_exp_times=NewMultiExpT,
                      accumulate_exp_times=NewAccuExpT,
                      mission_transfer_times=NewMissionTransferT,
                      pet_training_times=NewPetTrainingT} = NewLevelInfo,

    Now = common_tool:now(),
    case Now > EndTime of
        true ->
            EndTime2 = Now;
        _ ->
            EndTime2 = EndTime
    end,

    [RemoteDepotMinLevel] = common_config_dyn:find(vip, remote_depot_min_level),
    RemoteDepot2 =
        case RemoteDepot =:= 0 andalso VipLevel2 >= RemoteDepotMinLevel of
            true ->
                1;
            _ ->
                RemoteDepot
        end,

    VipInfo2 = VipInfo#p_role_vip{vip_level=VipLevel2,
                                  total_time=TotalTime+TimeAdd,
                                  end_time=EndTime2+LastTime,
                                  multi_exp_times=NewMultiExpT-(OldMultiExpT-MultiExpT),
                                  accumulate_exp_times=NewAccuExpT-(OldAccuExpT-AccuExpT),
                                  %%mission_transfer_times=NewMissionTransferT-(OldMissionTransferT-MissionTransferT),
                                  mission_transfer_times = NewMissionTransferT,
                                  is_expire=false,
                                  pet_training_times=NewPetTrainingT-(OldPetTrainingT-PetTrainingT),
                                  remote_depot_num=RemoteDepot2,
                                  last_get_prestige_time=LastGetPrestigeTime},
    
    t_set_role_vip_info(RoleID, VipInfo2),
    {ok, recharge, VipInfo2, VipInfo}.

%% @doc 开通VIP，之前不是VIP的
t_vip_active_new(RoleID, VipType) ->
    Now = common_tool:now(),
    [#r_vip_card{last_time=LastTime, time_add=TimeAdd}] = common_config_dyn:find(vip, {vip_card, VipType}),
    {ok, VipLevel} = get_vip_level_by_time(TimeAdd),
    {ok, LevelInfo} = get_vip_level_info(VipLevel),
    #r_vip_level_info{multi_exp_times=MultiExpTimes,
                      accumulate_exp_times=AccuExpTimes,
                      mission_transfer_times=MissionTransferT,
                      pet_training_times=PetTrainingT} = LevelInfo,

    [RemoteDepotMinLevel] = common_config_dyn:find(vip, remote_depot_min_level),
    RemoteDepotNum =
        case VipLevel >= RemoteDepotMinLevel of
            true ->
                1;
            _ ->
                0
        end,

    VipInfo =#p_role_vip{role_id=RoleID, 
                         end_time=Now+LastTime, 
                         total_time=TimeAdd,
                         vip_level=VipLevel,
                         multi_exp_times=MultiExpTimes,
                         accumulate_exp_times=AccuExpTimes, 
                         mission_transfer_times=MissionTransferT,
                         is_transfer_notice_free=true, 
                         is_transfer_notice=true, 
                         last_reset_time=Now,
                         is_expire=false,
                         pet_training_times=PetTrainingT,
                         remote_depot_num=RemoteDepotNum},
    
    t_set_role_vip_info(RoleID, VipInfo),
    {ok, new, VipInfo, undefined}.

%% @doc 开通VIP
do_vip_active(Unique, Module, Method, DataIn, RoleID, PID) ->
    case catch check_can_active(RoleID, DataIn) of
        ok ->
            do_vip_active2(Unique, Module, Method, DataIn, RoleID, PID);
        {error, Reason} ->
            do_vip_active_error(Unique, Module, Method, PID, Reason);
        Error ->
            ?ERROR_MSG("do_vip_active, error: ~w", [Error]),
            do_vip_active_error(Unique, Module, Method, PID, ?_LANG_VIP_ACTIVE_SYSTEM_ERROR)
    end.

do_vip_active2(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_vip_active_tos{vip_type=VipType} = DataIn,

    case common_transaction:t(
           fun() ->
                   t_do_vip_active(RoleID, VipType)
           end)
    of
        {atomic, {ok, RoleAttr, ActiveType, VipInfo, VipInfoOld, UpdateList, DelList, Type, GoldNeed, ItemNeed}} ->
            case Type of
                gold ->
                    DataRecord = #m_vip_active_toc{vip_info=VipInfo, gold=GoldNeed};
                _ ->
                    DataRecord = #m_vip_active_toc{vip_info=VipInfo, item=ItemNeed}
            end,
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord),
            %% 通知背包、元宝变动
            if UpdateList =:= [] andalso DelList =:= [] ->
                    GoldChange = #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=RoleAttr#p_role_attr.gold},
                    Record = #m_role2_attr_change_toc{roleid=RoleID, changes=[GoldChange]},
                    common_misc:unicast2(PID, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, Record);
               UpdateList =:= [] ->
                    [Goods] = DelList,
                    common_item_logger:log(RoleID, Goods, ?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                    common_misc:del_goods_notify({role, RoleID}, DelList);
               true ->
                    [Goods] = UpdateList,
                    common_item_logger:log(RoleID, Goods, ?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                    common_misc:update_goods_notify({role, RoleID}, UpdateList)
            end,
            do_vip_active3(RoleID, Type, ActiveType, VipType, VipInfo, VipInfoOld);
            
        {aborted, Reason} when is_binary(Reason) ->
            do_vip_active_error(Unique, Module, Method, PID, Reason);
        {aborted, Reason} ->
            ?ERROR_MSG("do_vip_active2, error: ~w", [Reason]),
            do_vip_active_error(Unique, Module, Method, PID, ?_LANG_VIP_ACTIVE_SYSTEM_ERROR)
    end.


do_vip_active3(RoleID, Type, ActiveType, VipType, VipInfo, VipInfoOld) ->
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    do_vip_active4(RoleBase, RoleAttr, Type, ActiveType, VipType, VipInfo, VipInfoOld).

do_vip_active4(RoleBase, RoleAttr, Type, ActiveType, VipType, VipInfo, _VipInfoOld) ->
    #p_role_vip{vip_level=Level} = VipInfo,
    %% 如果首次成为VIP需要世界广播
    %%MapName = common_misc:get_map_name(?vip_list_mapid),
    #p_role_base{role_id=RoleID, role_name=RoleName} = RoleBase,
    #p_role_attr{skin=#p_skin{skinid=_SkinID}} = RoleAttr,
%%     VipListInfo = #p_vip_list_info{
%%       role_id=RoleID, 
%%       role_name=RoleName,
%%       skin_id= RoleHead,
%%       level=RoleLevel,
%%       faction_id=FactionID,
%%       family_name=FamilyName,
%%       total_time=TotalTime,
%%       is_online=true},
    case ActiveType of
        %% VIP体验卡不广播
        new when VipType =/= 10 ->
            {ok, #p_role_attr{role_name=RoleName}} = mod_map_role:get_role_attr(RoleID),
            Msg = lists:flatten(io_lib:format(?_LANG_VIP_ACTIVE_BROADCAST, [RoleName])),
            common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CENTER], ?BC_MSG_TYPE_CHAT_WORLD, Msg),
            %% 好友弹窗
            (catch global:send(mod_friend_server, {vip_active, RoleID, RoleName, Level})),
            %% 更新VIP列表
            %%(catch global:send(MapName, {mod_vip, {vip_list_insert, VipListInfo}}));
            ignore;
        _ ->
            ignore
            %%(catch global:send(MapName, {mod_vip, {vip_list_update, VipInfoOld#p_role_vip.total_time, VipListInfo}}))
    end,
    {ok, LevelInfo} = get_vip_level_info(Level),
    #r_vip_level_info{title_name=TitleName, color=Color, multi_exp_buff_id=ExpBuffID} = LevelInfo,
    %% 添加VIP称号
    case TitleName =:= "" of
        true ->
            ignore;
        _ ->
            common_title:add_title(?TITLE_VIP, RoleID, {TitleName, Color})
    end,
    %% 添加多倍经验的buff
    {ok, BuffDetail} = mod_skill_manager:get_buf_detail(ExpBuffID), 
    mod_role_buff:add_buff(RoleID, RoleID, role, BuffDetail),
    %%添加vip充值记录
    PayType = case Type of
                  gold->2;
                  item->1
              end,
    IsFirst = case ActiveType of
                  new->1;
                  recharge->0
              end,
    VipPayLog = #r_vip_pay_log{role_id = RoleID, pay_type = VipType * 10 +PayType, pay_time = common_tool:now(), is_first=IsFirst},
    common_general_log_server:log_vip_pay(VipPayLog),
    %% 更新p_map_role
    mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.vip_level, Level}], mgeem_map:get_state()).

do_vip_active_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_vip_active_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 领取VIP多倍经验
do_vip_multi_exp(Unique, Module, Method, RoleID, PID) ->
    case catch check_can_get_multi_exp(RoleID) of
        ok->
            do_vip_multi_exp2(Unique, Module, Method, RoleID, PID);
        {error, Reason} ->
            do_vip_multi_exp_error(Unique, Module, Method, PID, Reason);
        Error ->
            ?ERROR_MSG("do_vip_multi_exp, error: ~w", [Error]),
            do_vip_multi_exp_error(Unique, Module, Method, PID, ?_LANG_VIP_MULTI_EXP_SYSTEM_ERROR)
    end.

do_vip_multi_exp2(Unique, Module, Method, RoleID, PID) ->
    case common_transaction:t(
           fun() ->
                   {ok, VipInfo} = get_role_vip_info(RoleID),

                   #p_role_vip{multi_exp_times=ExpTimes} = VipInfo,
                   VipInfo2 = VipInfo#p_role_vip{multi_exp_times=ExpTimes-1},
                   t_set_role_vip_info(RoleID, VipInfo2),
                   VipInfo2
           end)
    of
        {atomic, VipInfo} ->
            #p_role_vip{vip_level=VipLevel} = VipInfo,
            {ok, LevelInfo} = get_vip_level_info(VipLevel),
            %% 添加经验BUFF
            #r_vip_level_info{multi_exp_buff_id=ExpBuffID} = LevelInfo,
            {ok, BuffDetail} = mod_skill_manager:get_buf_detail(ExpBuffID), 
            mod_role_buff:add_buff(RoleID, RoleID, role, BuffDetail),

            common_misc:unicast2(PID, Unique, Module, Method, #m_vip_multi_exp_toc{}),
            ok;
        {aborted, Reason} when is_binary(Reason) ->
            do_vip_multi_exp_error(Unique, Module, Method, PID, Reason);
        {aborted, Reason} ->
            ?ERROR_MSG("do_vip_multi_exp2, error: ~w", [Reason]),
            do_vip_multi_exp_error(Unique, Module, Method, PID, ?_LANG_VIP_MULTI_EXP_SYSTEM_ERROR)
    end.

do_vip_multi_exp_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_vip_multi_exp_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

-define(notify_type_transfer_free, 1).
-define(notify_type_transfer_normal, 2).

%% 停止提示
do_vip_stop_notify(Unique, Module, Method, DataIn, RoleID, PID) ->
    case catch check_can_stop_notify(RoleID) of
        {ok, VipInfo} ->
            do_vip_stop_notify2(Unique, Module, Method, DataIn, RoleID, PID, VipInfo);
        {error, Reason} ->
            do_vip_stop_notify_error(Unique, Module, Method, PID, Reason);
        Error ->
            ?ERROR_MSG("do_vip_stop_notify, error: ~w", [Error]),
            do_vip_stop_notify_error(Unique, Module, Method, PID, ?_LANG_VIP_STOP_NOTIFY_SYSTEM_ERROR)
    end.

do_vip_stop_notify2(Unique, Module, Method, DataIn, RoleID, PID, VipInfo) ->
    #m_vip_stop_notify_tos{notify_type=NotifyType} = DataIn,
    case common_transaction:t(
           fun() ->
                   case NotifyType of
                       ?notify_type_transfer_free ->
                           VipInfo2 = VipInfo#p_role_vip{is_transfer_notice_free=false};
                       _ ->
                           VipInfo2 = VipInfo#p_role_vip{is_transfer_notice=false}
                   end,

                   t_set_role_vip_info(RoleID, VipInfo2)
           end)
    of
        {atomic, _} ->
            DataRecord = #m_vip_stop_notify_toc{notify_type=NotifyType},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord);
        {aborted, Error} ->
            ?ERROR_MSG("do_vip_stop_notify, error: ~w", [Error]),
            do_vip_stop_notify_error(Unique, Module, Method, PID, ?_LANG_VIP_STOP_NOTIFY_SYSTEM_ERROR)
    end.

do_vip_stop_notify_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_vip_stop_notify_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

do_remote_depot(Unique, Module, Method, RoleID, PID, Line, MapState) ->
    case catch check_can_active_remote_depot(RoleID) of
        {ok, VipInfo, RoleAttr} ->
            do_remote_depot2(Unique, Module, Method, RoleID, PID, Line, MapState, VipInfo, RoleAttr);
        {error, Reason} ->
            do_remote_depot_error(Unique, Module, Method, PID, Reason);
        E ->
            ?ERROR_MSG("do_remote_depot, error: ~w", [E]),
            do_remote_depot_error(Unique, Module, Method, PID, ?_LANG_VIP_REMOTE_DEPOT_SYSTEM_ERROR)
    end.

do_remote_depot2(Unique, Module, Method, RoleID, PID, Line, MapState, VipInfo, RoleAttr) ->
    case common_transaction:t(
           fun() ->
                   t_do_remote_depot(RoleID, VipInfo, RoleAttr)
           end)
    of 
        {atomic, {ok, VipInfo2, RoleAttr2}} ->
            %% VIP信息变动
            notify_vip_info_change(RoleID, PID, VipInfo2),
            common_misc:unicast2(PID, Unique, Module, Method,  #m_vip_remote_depot_toc{}),
            #p_role_vip{remote_depot_num=RemoteDepotNum} = VipInfo2,
            %% 金钱变动
            #p_role_attr{gold=Gold, gold_bind=GoldBind} = RoleAttr2,
            AttrChangeList = [
                              #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=Gold},
                              #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=GoldBind}],
            common_misc:role_attr_change_notify({pid, PID}, RoleID, AttrChangeList),
            case mod_bag:judge_bag_exist(RoleID, RemoteDepotNum+5) of
                true ->
                    ignore;
                _ ->
                    mod_depot:handle({?DEFAULT_UNIQUE, ?DEPOT, ?DEPOT_DREDGE, #m_depot_dredge_tos{bagid=RemoteDepotNum+5}, RoleID, PID, Line, MapState})
            end;
        {aborted, Reason} when is_binary(Reason) ->
            do_remote_depot_error(Unique, Module, Method, PID, Reason);
        {aborted, Reason} ->
            ?ERROR_MSG("do_remote_depot2, error: ~w", [Reason]),
            do_remote_depot_error(Unique, Module, Method, PID, ?_LANG_VIP_REMOTE_DEPOT_SYSTEM_ERROR)
    end.

t_do_remote_depot(RoleID, VipInfo, RoleAttr) ->
    #p_role_vip{remote_depot_num=RemoteDepot} = VipInfo,
    VipInfo2 = VipInfo#p_role_vip{remote_depot_num=RemoteDepot+1},
    t_set_role_vip_info(RoleID, VipInfo2),
    
    [GoldNeed] = common_config_dyn:find(vip, {remote_depot_fee, RemoteDepot}),
    #p_role_attr{gold=Gold, gold_bind=GoldBind} = RoleAttr,
    {Gold2, GoldBind2} = mod_role2:calc_rest_money(Gold, GoldBind, GoldNeed),
    RoleAttr2 = RoleAttr#p_role_attr{gold=Gold2, gold_bind=GoldBind2},
    mod_map_role:set_role_attr(RoleID, RoleAttr2),
    %% 消费日志
    common_consume_logger:use_gold({RoleID, GoldBind-GoldBind2, Gold-Gold2, ?CONSUME_TYPE_GOLD_VIP_REMOTE_DEPOT,
                                    ""}),
    {ok, VipInfo2, RoleAttr2}.

do_remote_depot_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_vip_remote_depot_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

check_can_active_remote_depot(RoleID) ->
    VipInfo =
        case get_role_vip_info(RoleID) of
            {ok, Info} ->
                Info;
            _ ->
                erlang:throw({error, ?_LANG_VIP_REMOTE_DEPOT_NOT_VIP})
        end,
    #p_role_vip{remote_depot_num=RemoteDepot, vip_level=VipLevel} = VipInfo,
    [MinVipLevel] = common_config_dyn:find(vip, remote_depot_min_level),
    case VipLevel < MinVipLevel of
        true ->
            erlang:throw({error, ?_LANG_VIP_REMOTE_DEPOT_LEVEL_NOT_ENOUGH});
        _ ->
            ok
    end,
    case RemoteDepot >= 4 of
        true ->
            erlang:throw({error, ?_LANG_VIP_REMOTE_DEPOT_MAX_DEPOT});
        _ ->
            ok
    end,
    [GoldNeed] = common_config_dyn:find(vip, {remote_depot_fee, RemoteDepot}),
    {ok, #p_role_attr{gold=Gold, gold_bind=GoldBind}=RoleAttr} = mod_map_role:get_role_attr(RoleID),
    case Gold + GoldBind >= GoldNeed of
        true ->
            ok;
        _ ->
            erlang:throw({error, ?_LANG_VIP_REMOTE_DEPOT_NOT_ENOUGH_GOLD})
    end,
    {ok, VipInfo, RoleAttr}.


do_exchange_prestige(Unique, _Module, _Method, RoleID, PID, _Line, _MapState) ->
    case catch check_can_exchange_prestige(RoleID) of
        {ok,VipInfo,Prestige,ExchangeTime}->
            do_exchange_prestige2(Unique,RoleID, PID,VipInfo,Prestige,ExchangeTime);
        {error,Reason}->
            do_exchange_prestige_error(Unique,RoleID,PID,Reason)
    end.

do_exchange_prestige2(Unique,RoleID, PID,VipInfo,Prestige,ExchangeTime)->
    {ok,RoleAttr}=mod_map_role:get_role_attr(RoleID),
     case common_transaction:transaction( 
           fun()->
                   RoleAttr2=RoleAttr#p_role_attr{sum_prestige=RoleAttr#p_role_attr.sum_prestige+Prestige,
                                                  cur_prestige=RoleAttr#p_role_attr.cur_prestige+Prestige},
                   mod_map_role:set_role_attr(RoleID, RoleAttr2),
                   t_set_role_vip_info(RoleID, VipInfo#p_role_vip{last_get_prestige_time=ExchangeTime}),
                   RoleAttr2
           end ) of
        {atomic, RoleAttr2} ->
            common_misc:send_role_prestige_change(RoleID,RoleAttr2),
            R = #m_vip_exchange_prestige_toc{reason = common_tool:get_format_lang_resources(?_LANG_VIP_GET_PRESTIGE_SUCC,[Prestige])},
            common_misc:unicast2(PID, Unique, ?VIP, ?VIP_EXCHANGE_PRESTIGE, R);
        {aborted, Error} ->
            ?ERROR_MSG_STACK("reset_all_online_actpoint error",Error)
    end.

check_can_exchange_prestige(RoleID)->
    VipInfo = 
      case get_role_vip_info(RoleID) of
        {ok, _VipInfo} ->
            _VipInfo;
        _ ->
            throw({error,?_LANG_VIP_GET_PRESTIGE_NOT_VIP})
    end,
    case VipInfo#p_role_vip.is_expire of
        true->
            throw({error,?_LANG_VIP_GET_PRESTIGE_NOT_VIP});
        false->
            next
    end,
    DateTimeStamp=common_tool:datetime_to_seconds({date(),{0,0,0}}),
    Now = common_tool:now(),
    case VipInfo#p_role_vip.last_get_prestige_time =<DateTimeStamp of
        true->
            next;
        false->
            throw({error,?_LANG_VIP_GET_PRESTIGE_ALREADY})
    end,
    VipLevel = VipInfo#p_role_vip.vip_level,
    case common_config_dyn:find(vip, {exchange_prestige,VipLevel}) of
        []->
            throw({error,?_LANG_VIP_GET_NO_PRESTIGE});
        [Prestige]->
            {ok,VipInfo,Prestige,Now}
    end.
            

do_exchange_prestige_error(Unique,_RoleID,PID,Reason)->
    R = #m_vip_exchange_prestige_toc{succ=false,
                                    reason =Reason},
    common_misc:unicast2(PID, Unique, ?VIP, ?VIP_EXCHANGE_PRESTIGE, R).


%% %% @doc 查看VIP列表
%% do_vip_list(Unique, Module, Method, _DataIn, _RoleID, PID) ->
%%     VipList = get_all_vip_list(),
%%     %% VipList2 = lists:map(
%%     %%              fun(#p_vip_list_info{role_id=RoleID}=ListInfo) ->
%%     %%                      ListInfo#p_vip_list_info{is_online=common_misc:is_role_online(RoleID)}
%%     %%              end, VipList),
%%     DataRecord = #m_vip_list_toc{vip_list=VipList},
%%     common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc
check_can_stop_notify(RoleID) ->
    VipInfo =
        case get_role_vip_info(RoleID) of
            {ok, VI} ->
                VI;
            _ ->
                erlang:throw({error, ?_LANG_VIP_STOP_NOTIFY_NOT_VIP})
        end,
    
    {ok, VipInfo}.

%% @doc 判断是否可以领取多倍经验
check_can_get_multi_exp(RoleID) ->
    throw({error, ?_LANG_VIP_MULTI_EXP_CLOSE}),
    case get_vip_remain_time(RoleID, #p_role_vip.multi_exp_times) of
        {error, has_expired} ->
            throw({error, ?_LANG_VIP_MULTI_EXP_VIP_EXPIRED});
        {error, not_vip} ->
            throw({error, ?_LANG_VIP_MULTI_EXP_NOT_VIP});
        {error, all_used} ->
            throw({error, ?_LANG_VIP_MULTI_EXP_ALL_USED});
        _ ->
            ok
    end.

%% @doc 是否可以开通VIP
check_can_active(_RoleID, _DataIn) ->
    ok.

t_do_vip_active(RoleID, VipType) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{gold=Gold} = RoleAttr,

    [#r_vip_card{gold=GoldNeed, item_need=ItemNeed}] = common_config_dyn:find(vip, {vip_card, VipType}),

    %% 先扣道具
    case mod_bag:get_goods_by_typeid(RoleID, ItemNeed, [1, 2, 3]) of
        {ok, []} ->
            case Gold < GoldNeed of
                true ->
                    common_transaction:abort(?_LANG_VIP_ACTIVE_NOT_ENOUGH_GOLD);
                _ ->
                    ok
            end,

            RoleAttr2 = RoleAttr#p_role_attr{gold=Gold-GoldNeed},
            mod_map_role:set_role_attr(RoleID, RoleAttr2),

            %% 消费日志
            common_consume_logger:use_gold({RoleID, 0, GoldNeed, ?CONSUME_TYPE_GOLD_VIP_ACTIVE,
                                            ""}),

            Type = gold,
            UpdateList = [],
            DelList = [];

        _ ->
            {ok, UpdateList, DelList} = mod_bag:decrease_goods_by_typeid(RoleID, ItemNeed, 1),
            Type = item,
            RoleAttr2 = RoleAttr
    end,
    {ok, ActiveType, VipInfo, VipInfoOld} = t_vip_active(RoleID, VipType),
        
    {ok, RoleAttr2, ActiveType, VipInfo, VipInfoOld, UpdateList, DelList, Type, GoldNeed, ItemNeed}.
    
%% @doc 初始化角色VIP信息
init_role_vip_info(RoleID, VipInfo) ->
    case VipInfo of
        undefined ->
            ignore;
        _ ->
            erlang:put({?role_vip, RoleID}, VipInfo)
    end.

%% @doc 设置角色VIP信息
t_set_role_vip_info(RoleID, VipInfo) ->
    mod_map_role:update_role_id_list_in_transaction(RoleID, ?role_vip, ?role_vip_copy),
    erlang:put({?role_vip, RoleID}, VipInfo).

%% @doc 设置角色VIP信息
set_role_vip_info(RoleID, VipInfo, IsNotify) ->
    case common_transaction:t(
           fun() ->
                   t_set_role_vip_info(RoleID, VipInfo)
           end)
    of
        {atomic, _} ->
            case IsNotify of
                true ->
                    DataRecord = #m_vip_info_toc{vip_info=VipInfo},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?VIP, ?VIP_INFO, DataRecord);
                _ ->
                    ignore
            end,
            ok;
        {aborted, Error} ->
            ?ERROR_MSG("set_role_vip_info, error: ~w", [Error]),
            error
    end.

%% @doc 获取商店折扣
get_vip_shop_discount(RoleID) ->
    case get_role_vip_level(RoleID) of
        {ok, 0} ->
            100;
        {ok, VipLevel} ->
            {ok, #r_vip_level_info{shop_discount=Discount}} = get_vip_level_info(VipLevel),
            Discount
    end.

%% @doc 获取VIP等级信息
get_vip_level_info(Level) ->
    [LevelInfo] = common_config_dyn:find(vip, {vip_level_info, Level}),
    {ok, LevelInfo}.

%% @doc 获取VIP宠物提悟概率提升
get_vip_pet_understand_rate(RoleID) ->
    {ok, VipLevel} = get_role_vip_level(RoleID),
    case VipLevel =:= 0 of
        true ->
            0;
        _ ->
            {ok, LevelInfo} = get_vip_level_info(VipLevel),
            LevelInfo#r_vip_level_info.pet_understanding_rate
    end.

%% @doc 通过时长获取VIP等级
get_vip_level_by_time(Time) ->
    [Time2Level] = common_config_dyn:find(vip, vip_time_to_level),
    get_vip_level_by_time2(Time2Level, Time).

%% @doc 获取vip等级，不是VIP或者过期都算0级
get_role_vip_level(RoleID) ->
    case get_role_vip_info(RoleID) of
        {error, _} ->
            {ok, 0};
        {ok, VipInfo} ->
            #p_role_vip{is_expire=IsExpire, vip_level=VipLevel} = VipInfo,

            if
                IsExpire =:= true ->
                    {ok, 0};
                true ->
                    {ok, VipLevel}
            end
    end.

get_vip_level_by_time2([{_, Level}], _Time) ->
    {ok, Level};
get_vip_level_by_time2([{{MinT, MaxT}, Level}|T], Time) ->
    if Time >= MinT andalso Time =< MaxT ->
            {ok, Level};
       true ->
            get_vip_level_by_time2(T, Time)
    end.

%% @doc 获取VIP某项优惠的剩余次数
get_vip_remain_time(RoleID, Field) ->
    case get_role_vip_info(RoleID) of
        {error, _} ->
            {error, not_vip};
        {ok, VipInfo} ->
            #p_role_vip{is_expire=IsExpire} = VipInfo,
            Value = erlang:element(Field, VipInfo),

            if
                IsExpire ->
                    {error, has_expired};
                Value =:= 0 ->
                    {error, all_used};
                true ->
                    {ok, Value}
            end
    end.

%% @doc 赃读VIP等级
get_dirty_vip_level(RoleID) ->
    case db:dirty_read(?DB_ROLE_VIP_P, RoleID) of
        [] ->
            0;
        [VipInfo] ->
            VipInfo#p_role_vip.vip_level
    end.

%% @doc 是否VIP
is_role_vip(RoleID) ->
    case get_role_vip_info(RoleID) of
        {ok, VipInfo} ->
            not VipInfo#p_role_vip.is_expire;
        _ ->
            false
    end.

%% %% @doc 通过时间获取VIP列表KEY
%% get_vip_list_key(Time) ->
%%     {ok, Level} = get_vip_level_by_time(Time),
%%     case Level < 2 of
%%         true ->
%%             {vip_list_time, Time};
%%         _ ->
%%             {vip_list_level, Level}
%%     end.
%% 
%% %% @doc 获取VIP排行KEY列表
%% get_vip_list_key_list() ->
%%     get(vip_list_key_list).
%% 
%% %% @doc 初始化VIP列表KEY列表
%% init_vip_list_key_list() ->
%%     [#r_vip_card{time_add=TimeAdd}] = common_config_dyn:find(vip, {vip_card, 4}),
%%     KeyList = [{vip_list_time, TimeAdd*2}, {vip_list_time, TimeAdd}],
%%     KeyList2 = lists:foldl(
%%                  fun(Level, Acc) ->
%%                          [{vip_list_level, Level}|Acc]
%%                  end, KeyList, [2, 3, 4, 5]),
%%     put(vip_list_key_list, {0, KeyList2}),
%%     
%%     lists:foreach(fun(Key) -> put(Key, {0, []}) end, KeyList2).
%% 
%% %% @doc VIP列表信息更新，如等级、门派名称
%% do_vip_list_info_update(10700) ->
%%     case get(?last_update_time) of
%%         undefined ->
%%             do_vip_list_info_update2();
%%         LastTime ->
%%             Now = common_tool:now(),
%%             put(?last_update_time, Now),
%%             case Now - LastTime >= ?vip_list_update_interval of 
%%                 true ->
%%                     do_vip_list_info_update2();
%%                 _ ->
%%                     ignore
%%             end
%%     end;
%% do_vip_list_info_update(_) ->
%%     ignore.
%% 
%% do_vip_list_info_update2() ->
%%     {_, KeyList} = get_vip_list_key_list(),
%%     lists:foreach(
%%       fun(Key) ->
%%               case get(Key) of
%%                   undefined ->
%%                       ignore;
%%                   {N, L} ->
%%                       L2 =
%%                           lists:map(
%%                             fun(#p_vip_list_info{role_id=RoleID}=ListInfo) ->
%%                                     {ok, #p_role_base{family_name=FamilyName}} = common_misc:get_dirty_role_base(RoleID),
%%                                     {ok, #p_role_attr{level=Level}} = common_misc:get_dirty_role_attr(RoleID),
%%                                     ListInfo#p_vip_list_info{level=Level, family_name=FamilyName}
%%                             end, L),
%%                       put(Key, {N, L2})
%%               end
%%       end, KeyList).
%% 
%% %% @doc 获取所有VIP
%% get_all_vip_list() ->
%%     {_, KeyList} = get_vip_list_key_list(),
%%     lists:foldr(
%%       fun(Key, Acc) ->
%%               case get(Key) of
%%                   undefined ->
%%                       Acc;
%%                   {_, L} ->
%%                       lists:append(L, Acc)
%%               end
%%       end, [], KeyList).
%%     
%% %% @doc VIP列表插入
%% vip_list_insert(VipInfo) ->
%%     #p_vip_list_info{total_time=Time} = VipInfo,
%%     Key = get_vip_list_key(Time),
%%     case get(Key) of
%%         undefined ->
%%             ignore;
%%         {Count, List} ->
%%             case Key of
%%                 {vip_list_time, _} ->
%%                     put(Key, {Count+1, [VipInfo|List]});
%%                 _ ->
%%                     put(Key, {Count+1, lists:reverse(lists:sort([VipInfo|List]))})
%%             end,
%%             {Total, L} = get_vip_list_key_list(),
%%             put(vip_list_key_list, {Total+1, L})
%%     end.
%% 
%% %% @doc VIP列表删除
%% vip_list_delete(RoleID, Time) ->
%%     Key = get_vip_list_key(Time),
%%     {Count, List} = get(Key),
%%     put(Key, {Count-1, lists:keydelete(RoleID, #p_vip_list_info.role_id, List)}),
%%     {Total, L} = get_vip_list_key_list(),
%%     put(vip_list_key_list, {Total-1, L}).
%% 
%% %% @doc VIP列表更新
%% vip_list_update(OldTime, VipInfo2) ->
%%     #p_vip_list_info{role_id=RoleID} = VipInfo2,
%%     vip_list_delete(RoleID, OldTime),
%%     vip_list_insert(VipInfo2).

%% %% @doc 获取VIP列表页数
%% get_vip_list_page() ->
%%     {Total, _} = get_vip_list_key_list(),
%%     common_tool:ceil(Total/?vip_list_records_per_page).

%% %% @doc 获取VIP列表某页数据
%% get_vip_list_page_info(PageID) ->
%%     {_, KeyList} = get_vip_list_key_list(),
%%     StartIndex = (PageID-1) * ?vip_list_records_per_page,
%%     EndIndex = StartIndex + ?vip_list_records_per_page,
%%     get_vip_list_page_info2(StartIndex, EndIndex, KeyList, 0, 0, []).

%% get_vip_list_page_info2(_StartIndex, _EndIndex, [], _Total, _Count, List) ->
%%     List;
%% get_vip_list_page_info2(StartIndex, EndIndex, [Key|T], Total, 0, []) ->
%%     {Num, L} = get(Key),
%%     Total2 = Total + Num,
%%     if Total2 >= StartIndex andalso Total2 < EndIndex andalso L =/= [] ->
%%             get_vip_list_page_info2(StartIndex, EndIndex, T, Total2, Total2-StartIndex, lists:sublist(L, StartIndex-Total+1, Total2-StartIndex));
%%        Total2 >= StartIndex andalso L =/= [] ->
%%             lists:sublist(L, StartIndex-Total+1, ?vip_list_records_per_page);
%%        true ->
%%             get_vip_list_page_info2(StartIndex, EndIndex, T, Total2, 0, [])
%%     end;
%% get_vip_list_page_info2(StartIndex, EndIndex, [Key|T], Total, Count, List) ->
%%     {Num, L} = get(Key),
%%     Total2 = Total + Num,
%%     case Total2 >= EndIndex of
%%         true ->
%%             lists:append(List, lists:sublist(L, EndIndex-Total));
%%         _ ->
%%             get_vip_list_page_info2(StartIndex, EndIndex, T, Total2, Count+Num, lists:append(List, L))
%%     end.

%% @doc 地图初始化HOOK
%% hook_map_init(?vip_list_mapid) ->
%%     init_vip_list_key_list(),
%%     VipList = db:dirty_match_object(?DB_ROLE_VIP_P, #p_role_vip{_='_'}),
%%     lists:foreach(
%%       fun(#p_role_vip{role_id=RoleID, total_time=TotalTime, is_expire=false}) ->
%%               {ok, RoleBase} = common_misc:get_dirty_role_base(RoleID),
%%               {ok, RoleAttr} = common_misc:get_dirty_role_attr(RoleID),
%%               #p_role_base{role_name=RoleName, faction_id=FactionID, family_name=FamilyName,head = RoleHead} = RoleBase,
%%               #p_role_attr{skin=#p_skin{skinid=_SkinID}, level=Level} = RoleAttr,
%%               VipListInfo = #p_vip_list_info{
%%                 role_id=RoleID, 
%%                 role_name=RoleName,
%%                 skin_id=RoleHead,
%%                 level=Level,
%%                 faction_id=FactionID,
%%                 family_name=FamilyName,
%%                 total_time=TotalTime,
%%                 is_online=true}, %% 暂时这样
%%               vip_list_insert(VipListInfo);
%%          (_) ->
%%               ignore
%%       end, VipList),
%%     put(?last_update_time, common_tool:now());
hook_map_init(_) ->
    ignore.
