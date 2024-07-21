%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2011, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 18 Feb 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_conlogin).

-include("mgeem.hrl").

%% API
-export([
         handle/1,
         role_init/2,
         role_level_up/2,
         loop_minday/0
        ]).


%% -------------------------------------------------------------------
%% 显示的基本步骤：
%% 先找出当天所能领取的所有奖励，再过滤掉已经领取的奖励
%% 如果当天没有奖励或者当天的已经全部领取，则先找出下次奖励在哪一天
%% 根据找出的下一次奖励的天数，找出对应的应该有的奖励
%% -------------------------------------------------------------------

%% -------------------------------------------------------------------
%% 领取的基本步骤:
%% 找出当前角色能够领取的所有奖励（当天的奖励去掉不满足条件以及已经领取的)
%% -------------------------------------------------------------------

%% 处理跨天的问题
loop_minday() ->
    {Date, {H, M, _}} = erlang:localtime(),
    %% 只在0点0分时处理，除非服务器卡了60秒，否则不可能出现意外
    case H =:= 0 andalso M =:= 0 of
        true ->
            %% 判断今天是否已经处理过了
            case Date =:= erlang:get(last_up_conlogin_date) of
                true ->
                    ignore;
                false ->
                    do_update_conlogin(Date)
            end;
        false ->
            ignore
    end.

%% 更新本地图内所有玩家的连续登录天数
do_update_conlogin(Date) ->
    lists:foreach(
      fun(RoleID) ->
              common_transaction:transaction(
                fun() ->
                        {ok, #r_role_conlogin{last_con_refresh_date=LCRD, con_day=CD} = R} = mod_map_role:get_role_conlogin(RoleID),
                        case LCRD =:= Date of
                            true ->
                                ignore;
                            false ->    
                                {ok, #p_role_goal{days=LoginDays} = RoleGoalInfo} = mod_map_role:get_role_goal(RoleID),
                                mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{days=LoginDays+1}),
                                mod_map_role:set_role_conlogin(RoleID, R#r_role_conlogin{con_day=CD+1, last_login_date=Date,
                                                                                         last_con_refresh_date=Date}),
                                %% 成就 累积登录天数事件处理 add by caochuncheng 2011-03-08
                                common_hook_achievement:hook({mod_role2,{conlogin,RoleID}})
                        end
                end)
      end, mod_map_actor:get_in_map_role()),
    erlang:put(last_up_conlogin_date, Date).
                                                     

handle(Info) ->
    do_handle_info(Info),
    ok.

role_level_up(RoleID, Level) ->
    case Level >= 20 of
        true ->
            {ok, #r_role_conlogin{not_show_date=NotShowDate}} = mod_map_role:get_role_conlogin(RoleID),
            {Date, _} = erlang:localtime(),
            case Date =:= NotShowDate of
                true ->
                    ignore;
                false ->
                    do_info(?DEFAULT_UNIQUE, ?CONLOGIN, ?CONLOGIN_INFO, false, RoleID)
            end;
        false ->
            ignore
    end,
    ok.

%% 角色first_enter时调用
role_init(RoleID, _PID) ->
    %% 计算玩家的连续登录天数，下线时也要计算,需要处理玩家长时间不下线的问题
    {ok, #r_role_conlogin{last_con_refresh_date=LastConRefreshDate, last_login_date=LastLoginDate,
                          con_day=Conday} = RoleConlogin} = mod_map_role:get_role_conlogin(RoleID),
    {Date, _} = erlang:localtime(),
    case Date =:= LastConRefreshDate of
        true ->
            ignore;
        false ->
            %% 需要刷新连续登录奖励天数，连续登陆有一定的保护时间
            {ok, ProtectDay} = get_conlogin_protect_day(RoleID),
            case calendar:date_to_gregorian_days(Date) - calendar:date_to_gregorian_days(LastLoginDate) =< ProtectDay of
                true ->
                    NewRoleConlogin = RoleConlogin#r_role_conlogin{last_con_refresh_date=Date, 
                                                                   last_login_date=Date, con_day=Conday + 1};
                false ->
                    NewRoleConlogin = RoleConlogin#r_role_conlogin{last_con_refresh_date=Date, last_login_date=Date, con_day=1,
                                                                  fetch_history=[]}
            end,
            common_transaction:transaction(
              fun() -> 
                      mod_map_role:set_role_conlogin(RoleID, NewRoleConlogin) ,
                      {ok, #p_role_goal{days=LoginDays} = RoleGoalInfo} = mod_map_role:get_role_goal(RoleID),
                      mod_map_role:set_role_goal(RoleID, RoleGoalInfo#p_role_goal{days=LoginDays+1})
              end),
            %% 成就 累积登录天数事件处理 add by caochuncheng 2011-03-08
            common_hook_achievement:hook({mod_role2,{conlogin,RoleID}})
    end,      
    ok.

do_handle_info({payed, RoleID}) ->
    do_payed(RoleID);
do_handle_info({Unique, ?CONLOGIN, ?CONLOGIN_INFO, R, RoleID, PID, _Line}) ->
    do_info(Unique, ?CONLOGIN, ?CONLOGIN_INFO, R, RoleID, PID);
do_handle_info({Unique, ?CONLOGIN, ?CONLOGIN_FETCH, R, RoleID, PID, _Line}) ->
    do_fetch(Unique, ?CONLOGIN, ?CONLOGIN_FETCH, R, RoleID, PID);
do_handle_info({Unique, ?CONLOGIN, ?CONLOGIN_NOTSHOW, _, RoleID, PID, _Line}) ->
    do_notshow(Unique, ?CONLOGIN, ?CONLOGIN_NOTSHOW, RoleID, PID);
do_handle_info({Unique, ?CONLOGIN, ?CONLOGIN_CLEAR, _DataIn, RoleID, PID, _Line}) ->
    do_clear(Unique, ?CONLOGIN, ?CONLOGIN_CLEAR, RoleID, PID);
do_handle_info({set_conlogin_day, FromPID, RoleID, Day}) ->
    do_set_conlogin_day(FromPID, RoleID, Day);
do_handle_info(Info) ->
    ?ERROR_MSG("~ts:~w", ["未知消息", Info]).

%% 玩家充值后需要重新推信息过去
do_payed(RoleID) ->
    case common_transaction:transaction(
           fun() ->
                   {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
                   mod_map_role:set_role_attr(RoleID, RoleAttr#p_role_attr{is_payed=true}),
                   RoleAttr#p_role_attr{is_payed=true}
           end)
    of
        {atomic, NewRoleAttr} ->
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_RELOAD, #m_role2_attr_reload_toc{role_attr=NewRoleAttr}),
            do_info(?DEFAULT_UNIQUE, ?CONLOGIN, ?CONLOGIN_INFO, false, RoleID);
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w", ["更新角色已充值属性时发生系统错误", Error])
    end,
    ok.

%% 后台管理接口：设置玩家连续登录天数
do_set_conlogin_day(FromPID, RoleID, Day) ->
    case common_transaction:transaction(fun() ->
                                                {ok, R} = mod_map_role:get_role_conlogin(RoleID),
                                                {Date, _} = erlang:localtime(),
                                                mod_map_role:set_role_conlogin(RoleID, 
                                                                               R#r_role_conlogin{last_con_refresh_date=Date, 
                                                                                                 con_day=Day, last_login_date=Date})
                                        end)
    of
        {atomic, _} ->
            do_info(?DEFAULT_UNIQUE, ?CONLOGIN, ?CONLOGIN_INFO, false, RoleID),
            FromPID ! ok;
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w", ["处理不显示连续登录奖励时发生系统错误", Error]),
            FromPID ! error
    end.


%% 当天不显示连续登录
do_notshow(Unique, Module, Method, RoleID, PID) ->
    case common_transaction:transaction(fun() ->
                                                {ok, R} = mod_map_role:get_role_conlogin(RoleID),
                                                {Date, _} = erlang:localtime(),
                                                mod_map_role:set_role_conlogin(RoleID, R#r_role_conlogin{not_show_date=Date})
                                        end)
    of
        {atomic, _} ->
            common_misc:unicast2(PID, Unique, Module, Method, #m_conlogin_notshow_toc{});
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w", ["处理不显示连续登录奖励时发生系统错误", Error]),
            common_misc:unicast2(PID, Unique, Module, Method, #m_conlogin_notshow_toc{succ=false, reason=?_LANG_CONLOGIN_SYSTEM_ERROR_WHEN_NOTSHOW})
    end.

%% @doc 清除连续登陆连续天数
do_clear(Unique, Module, Method, RoleID, PID) ->
    {ok, ConloginInfo} = mod_map_role:get_role_conlogin(RoleID),
    {Date, _} = erlang:localtime(),
    ConloginInfo2 = ConloginInfo#r_role_conlogin{last_con_refresh_date=Date, con_day=1},
    {atomic, _} = common_transaction:t(fun() -> mod_map_role:set_role_conlogin(RoleID, ConloginInfo2) end),
    common_misc:unicast2(PID, Unique, Module, Method, #m_conlogin_clear_toc{}),
    %% 重新推下连续登陆信息
    do_info(?DEFAULT_UNIQUE, ?CONLOGIN, ?CONLOGIN_INFO, true, RoleID).

%% 领取或者购买奖励
do_fetch(Unique, Module, Method, R, RoleID, PID) ->
    %% 分两种情况，一种是购买，一种是领取，购买可以输入个数，领取则是全部领取
    #m_conlogin_fetch_tos{id=ID, num=NumT} = R,
    Num = erlang:abs(NumT),
    %% 先判断该奖励玩家是否能够领取
    {ok, #r_role_conlogin{con_day=CurrentDay}} = mod_map_role:get_role_conlogin(RoleID),
    Rewards = get_reward_today_for_fetch(RoleID, CurrentDay),
    case lists:keyfind(ID, #r_conlogin_reward.id, Rewards) of
        false ->
            do_fetch_error(Unique, Module, Method, ?_LANG_CONLOGIN_ALREADY_FETCH, PID);
        #r_conlogin_reward{silver=Silver, gold=Gold} = Reward ->
            %% 再判断是否需要付费
            case Silver > 0 orelse Gold > 0 of
                true ->
                    do_fetch_not_free(Unique, Module, Method, Reward, ID, Num, RoleID, PID);
                false ->
                    do_fetch_free(Unique, Module, Method, Reward, ID, RoleID, PID)
            end
    end.

do_fetch_error(Unique, Module, Method, Reason, PID) ->
    R = #m_conlogin_fetch_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, R).

%% 免费领取
do_fetch_free(Unique, Module, Method, Reward, ID, RoleID, PID) ->
    #r_conlogin_reward{bind=Bind, type=Type, type_id=TypeID, num=Num} = Reward, 
    %% 给玩家道具，更新角色领取奖励的列表
    case common_transaction:transaction(fun() -> t_fetch_free(RoleID, Reward, ID) end) of
        {atomic, GoodsList} ->
            [Goods] = GoodsList,
            {ok, #r_role_conlogin{con_day=CurrentDay}} = mod_map_role:get_role_conlogin(RoleID),
            {ok, #p_role_attr{level=Level}} = mod_map_role:get_role_attr(RoleID),
            Log = #r_conlogin_log{role_id=RoleID, type=Type, type_id=TypeID, num=Num, days=CurrentDay, bind=Bind, level=Level, 
                                  dateline=common_tool:now()},
            common_general_log_server:log_conlogin(Log),
            common_item_logger:log(RoleID, Goods, ?LOG_ITEM_TYPE_GAIN_CONLOGIN),
            common_misc:update_goods_notify({role,RoleID}, GoodsList),
            R = #m_conlogin_fetch_toc{id=ID, num=0},
            common_misc:unicast2(PID, Unique, Module, Method, R),
            ok;
        {aborted, Error} ->
            case erlang:is_binary(Error) of
                true ->
                    Reason = Error;
                false ->
                    case Error of
                        {bag_error,not_enough_pos} ->
                            Reason = ?_LANG_CONLOGIN_BAG_NO_ENOUGH_POS_WHEN_FETCH;
                        _ ->
                            ?ERROR_MSG("~ts:~w", ["领取连续登录发生系统错误", Error]),
                            Reason = ?_LANG_CONLOGIN_SYSTEM_ERROR_WHEN_FETCH                            
                    end
            end,
            R = #m_conlogin_fetch_toc{succ=false, reason=Reason},
            common_misc:unicast2(PID, Unique, Module, Method, R)
    end,                   
    ok.

t_fetch_free(RoleID, Reward, ID) ->
    #r_conlogin_reward{bind=Bind, type=Type, type_id=TypeID, num=Num} = Reward, 
    {ok, RoleConloginReward} = mod_map_role:get_role_conlogin(RoleID),
    #r_role_conlogin{fetch_history=FetchHistory, con_day=ConDay} = RoleConloginReward,
    %% 判断是否已经领取过了
    case lists:keyfind({ID, ConDay}, 1, FetchHistory) of
        false ->
            ok;
        _ ->
            erlang:throw({error, ?_LANG_CONLOGIN_FETCH_ALREADY})
    end,
    CreateInfo = #r_goods_create_info{bind=Bind, type=Type, type_id=TypeID, num=Num},
    %% 向玩家背包添加道具
    {ok, GoodsList} = mod_bag:create_goods(RoleID, CreateInfo),
    mod_map_role:set_role_conlogin(RoleID, RoleConloginReward#r_role_conlogin{fetch_history=[{{ID, ConDay}, Num} | FetchHistory]}),
    GoodsList.

%% 购买
do_fetch_not_free(Unique, Module, Method, Reward, ID, Num, RoleID, PID) ->
    #r_conlogin_reward{bind=Bind, type=Type, type_id=TypeID} = Reward, 
    %% 给玩家道具，更新角色领取奖励的列表
    case common_transaction:transaction(fun() -> t_fetch_not_free(RoleID, Reward, ID, Num) end) of
        {atomic, {UseSilverBind, UseSilver, UseGoldBind, UseGold, GoodsList, RoleAttr}} ->
            {ok, #r_role_conlogin{con_day=CurrentDay}} = mod_map_role:get_role_conlogin(RoleID),
            {ok, #p_role_attr{level=Level}} = mod_map_role:get_role_attr(RoleID),
            Log = #r_conlogin_log{role_id=RoleID, type=Type, type_id=TypeID, num=Num, days=CurrentDay, bind=Bind, level=Level,
                                  dateline=common_tool:now(),
                                 gold_bind=UseGoldBind, gold=UseGold, silver_bind=UseSilverBind, silver=UseSilver},
            common_general_log_server:log_conlogin(Log),
            R = #m_conlogin_fetch_toc{id=ID, num=Num},
            common_misc:unicast2(PID, Unique, Module, Method, R),
            ChangeList = [
                          #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=RoleAttr#p_role_attr.gold},
                          #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=RoleAttr#p_role_attr.gold_bind},
                          #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=RoleAttr#p_role_attr.silver},
                          #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=RoleAttr#p_role_attr.silver_bind}],
            common_misc:role_attr_change_notify({pid, PID}, RoleID, ChangeList),
            common_misc:update_goods_notify({role,RoleID}, GoodsList),
            [Goods] = GoodsList,
            common_item_logger:log(RoleID, Goods, Num, ?LOG_ITEM_TYPE_GAIN_CONLOGIN),
            ok;
        {aborted, Error} ->
            case erlang:is_binary(Error) of
                true ->
                    Reason = Error;
                false ->
                    case Error of
                        {bag_error,not_enough_pos} ->
                            Reason = ?_LANG_CONLOGIN_BAG_NO_ENOUGH_POS_WHEN_FETCH;
                        _ ->
                            ?ERROR_MSG("~ts:~w", ["领取连续登录发生系统错误", Error]),
                            Reason = ?_LANG_CONLOGIN_SYSTEM_ERROR_WHEN_FETCH   
                    end
            end,
            R = #m_conlogin_fetch_toc{succ=false, reason=Reason},
            common_misc:unicast2(PID, Unique, Module, Method, R)
    end,                   
    ok.

t_fetch_not_free(RoleID, Reward, ID, FetchNum) ->
    #r_conlogin_reward{bind=Bind, type=Type, type_id=TypeID, num=Num, silver=Silver, gold=Gold} = Reward, 
    %% 判断数量是否足够
    case FetchNum > Num of
        true ->
            erlang:throw({error, ?_LANG_CONLOGIN_NO_ENOUGH_NUM_FOR_FETCH});
        false ->
            ok
    end,
    {ok, RoleConloginReward} = mod_map_role:get_role_conlogin(RoleID),
    #r_role_conlogin{fetch_history=FetchHistory, con_day=ConDay} = RoleConloginReward,
    %% 更新玩家购买的奖励的数量
    case lists:keyfind({ID, ConDay}, 1, FetchHistory) of
        false ->
            mod_map_role:set_role_conlogin(RoleID, RoleConloginReward#r_role_conlogin{fetch_history=[{{ID, ConDay}, FetchNum} | FetchHistory]}),
            ok;
        {{ID, ConDay}, OldNum} ->
            FetchHistory2 = lists:keyreplace({ID, ConDay}, 1, FetchHistory, {{ID, ConDay}, OldNum + FetchNum}),
            mod_map_role:set_role_conlogin(RoleID, RoleConloginReward#r_role_conlogin{fetch_history=FetchHistory2})
    end,
    %% 判断玩家是否有足够的银两或者元宝
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{silver=S, silver_bind=SB, gold=G, gold_bind=GB} = RoleAttr, 
    NeedSilver = Silver * FetchNum,
    case NeedSilver > 0 of
        true ->
            case SB >= NeedSilver of
                true ->
                    common_consume_logger:use_silver({RoleID, NeedSilver, 0, 
                                                        ?CONSUME_TYPE_SILVER_FETCH_CONLOGIN_REWARD, 
                                                        ""}),
                    UseSilverBind = NeedSilver,
                    UseSilver = 0,
                    Bind2 = true,
                    RoleAttr2 = RoleAttr#p_role_attr{silver_bind=SB - NeedSilver};
                false ->
                    case S >= NeedSilver of
                        true ->
                            common_consume_logger:use_silver({RoleID, 0, NeedSilver, 
                                                        ?CONSUME_TYPE_SILVER_FETCH_CONLOGIN_REWARD, 
                                                        ""}),
                            UseSilverBind = 0,
                            UseSilver = NeedSilver,
                            Bind2 = Bind, 
                            RoleAttr2 = RoleAttr#p_role_attr{silver=S - NeedSilver};
                        false ->
                            RoleAttr2 = RoleAttr, %%消除编译警告
                            UseSilverBind = 0,
                            UseSilver = 0,
                            Bind2 = Bind,
                            erlang:throw({error, ?_LANG_CONLOGIN_NOT_ENOUGH_SILVER_WHEN_FETCH})
                    end
            end;
        false ->
            UseSilverBind = 0,
            UseSilver = 0,
            Bind2 = Bind,
            RoleAttr2 = RoleAttr
    end,
    NeedGold = Gold * FetchNum, 
    case NeedGold > 0 of
        true ->
            case GB >= NeedGold of
                true ->
                    common_consume_logger:use_gold({RoleID, NeedGold, 0, 
                                                        ?CONSUME_TYPE_GOLD_FETCH_CONLOGIN_REWARD, 
                                                        ""}),
                    UseGoldBind = NeedGold,
                    UseGold = 0,
                    Bind3 = true,
                    RoleAttr3 = RoleAttr2#p_role_attr{gold_bind=GB - NeedGold};
                false ->
                    case G >= NeedGold of
                        true ->
                            common_consume_logger:use_gold({RoleID, 0, NeedGold, 
                                                        ?CONSUME_TYPE_GOLD_FETCH_CONLOGIN_REWARD, 
                                                        ""}),
                            UseGoldBind = 0,
                            UseGold = NeedGold,
                            Bind3 = Bind2,
                            RoleAttr3 = RoleAttr2#p_role_attr{gold=G - NeedGold};
                        false ->
                            RoleAttr3 = RoleAttr2,
                            UseGoldBind = 0,
                            UseGold = 0,
                            Bind3 = Bind2,
                            erlang:throw({error, ?_LANG_CONLOGIN_NOT_ENOUGH_GOLD_WHEN_FETCH})
                    end
            end;
        false ->
            UseGoldBind = 0,
            UseGold = 0,
            Bind3 = Bind2,
            RoleAttr3 = RoleAttr2
    end,
    CreateInfo = #r_goods_create_info{bind=Bind3, type=Type, type_id=TypeID, num=FetchNum},
    %% 向玩家背包添加道具
    {ok, GoodsList} = mod_bag:create_goods(RoleID, CreateInfo),
    mod_map_role:set_role_attr(RoleID, RoleAttr3),
    {UseSilverBind, UseSilver, UseGoldBind, UseGold, GoodsList, RoleAttr3}.


%% 玩家主动请求数据
do_info(Unique, Module, Method, R, RoleID, PID) ->
    #m_conlogin_info_tos{auto=Auto} = R,
    case get_conlogin_info(RoleID, Auto) of
        ignore ->
            ignore;
        R2 ->
            common_misc:unicast2(PID, Unique, Module, Method, R2)
    end,
    ok.

do_info(Unique, Module, Method, Auto, RoleID) ->
    case get_conlogin_info(RoleID, Auto) of
        ignore ->
            ignore;
        R ->
            common_misc:unicast({role, RoleID}, Unique, Module, Method, R)
    end,
    ok.


get_conlogin_info(RoleID, Auto) ->    
    %% 获取角色连续登录的天数
    {ok, #r_role_conlogin{con_day=CurrentDay, not_show_date=NotShowDate}} = mod_map_role:get_role_conlogin(RoleID),
    {Date, _} = erlang:localtime(),
    case Date =:= NotShowDate andalso Auto =:= true of
        true ->
            ignore;
        false ->
            Notice = mod_system_notice:get_notice(),
            AllRewards = common_config_dyn:list(conlogin_reward),
            case get_reward_today_for_display(RoleID, CurrentDay) of
                [] ->
                    NextDay = get_next_reward_day(CurrentDay, AllRewards),
                    Rewards = get_reward_of_next_day(NextDay, AllRewards),
                    #m_conlogin_info_toc{rewards=Rewards, day=CurrentDay, next_day=NextDay, notice=Notice};
                Rewards ->
                    #m_conlogin_info_toc{rewards=Rewards, day=CurrentDay, next_day=0, notice=Notice}
            end
    end.


%% 返回当前确认可以领取的奖励
get_reward_today_for_fetch(RoleID, CurrentDay) ->
    RewardList = common_config_dyn:list(conlogin_reward),
    {ok, #p_role_attr{level=RoleLevel, is_payed=IsPayed}} = mod_map_role:get_role_attr(RoleID),
    {ok, VipLevel} = mod_vip:get_role_vip_level(RoleID),
    RewardList2 = lists:foldl(
                    fun(#r_conlogin_reward{begin_day=BeginDay, end_day=EndDay, need_vip_level=NeedVipLevel,
                                           loop_day=LoopDay, min_level=MinLevel, max_level=MaxLevel, need_payed=NeedPay} = R, Acc) ->
                            %% 过滤掉等级不符合的
                            case CurrentDay >= BeginDay andalso CurrentDay =< EndDay andalso MinLevel =< RoleLevel andalso MaxLevel >= RoleLevel of
                                true ->
                                    case (((CurrentDay - BeginDay) rem LoopDay) =:= 0  orelse CurrentDay =:= BeginDay) of
                                        true ->
                                            %% 过滤充值条件不符合的
                                            case NeedPay of
                                                true ->
                                                    case IsPayed of
                                                        true ->
                                                            case VipLevel >= NeedVipLevel of
                                                                true ->
                                                                    [R | Acc];
                                                                _ ->
                                                                    Acc
                                                            end;
                                                        false ->
                                                            Acc
                                                    end;
                                                false ->
                                                    case VipLevel >= NeedVipLevel of
                                                        true ->
                                                            [R | Acc];
                                                        _ ->
                                                            Acc
                                                    end
                                            end;
                                        false ->
                                            Acc
                                    end;
                                false ->
                                    Acc
                            end
                    end, [], RewardList),
    {ok, #r_role_conlogin{fetch_history=RoleHistory}} = mod_map_role:get_role_conlogin(RoleID),
    %% RoleHistory : [{{day, goods_id}, num} , ...]
    lists:foldl(
      fun(#r_conlogin_reward{id=ID, num=Num} = R, Acc) ->
              case lists:keyfind({ID, CurrentDay}, 1, RoleHistory) of
                  false ->
                      [R | Acc];
                  {{ID, CurrentDay}, NumGeted} ->
                      case NumGeted >= Num of
                          true ->
                              Acc;
                          false ->
                              %% 付费奖励需要过滤能够购买的个数，玩家可能是单个单个的购买
                              [R#r_conlogin_reward{num=Num - NumGeted} | Acc]
                      end
              end
      end, [], RewardList2).
        

%% 获取玩家当天可能领取的奖励（包括条件为满足的，如充值、等级等等）
%% 仅仅用作客户端显示，实际领取的时候需要判断能否领取，用于防止外挂
get_reward_today_for_display(RoleID, CurrentDay) ->
    RewardList = common_config_dyn:list(conlogin_reward),
    %% 先获取当天所有可领取的奖励
    RewardList2 = lists:foldl(
                    fun(#r_conlogin_reward{begin_day=BeginDay, end_day=EndDay, loop_day=LoopDay} = R, Acc) ->
                            case CurrentDay >= BeginDay andalso CurrentDay =< EndDay of
                                true ->
                                    case (((CurrentDay - BeginDay) rem LoopDay) =:= 0 orelse CurrentDay =:= BeginDay) of
                                        true ->
                                            [R | Acc];
                                        false ->
                                            Acc
                                    end;
                                false ->
                                    Acc
                            end
                    end, [], RewardList),
    {ok, #r_role_conlogin{fetch_history=RoleHistory}} = mod_map_role:get_role_conlogin(RoleID),
    RewardList3 = lists:foldl(
                    fun(#r_conlogin_reward{id=ID, num=Num} = R, Acc) ->
                            case lists:keyfind({ID, CurrentDay}, 1, RoleHistory) of
                                false ->
                                    [R | Acc];
                                {{ID, CurrentDay}, NumGeted} ->
                                    case NumGeted >= Num of
                                        true ->
                                            Acc;
                                        false ->
                                            %% 付费奖励需要过滤能够购买的个数，玩家可能是单个单个的购买
                                            [R#r_conlogin_reward{num=Num - NumGeted} | Acc]
                                    end
                            end
                    end, [], RewardList2),
    lists:foldl(
      fun(#r_conlogin_reward{id=ID, min_level=MinLevel, max_level=MaxLevel, need_payed=NeedPayed,
                             type=Type, type_id=TypeID, need_vip_level=NeedVipLevel,
                             num=Num, silver=Silver, gold=Gold, bind=Bind}, Acc) ->
              [#p_conlogin_reward{id=ID, type=Type, type_id=TypeID, min_level=MinLevel, max_level=MaxLevel, need_vip_level=NeedVipLevel,
                                  need_payed=NeedPayed, num=Num, silver=Silver, gold=Gold, bind=Bind} | Acc]
      end, [], RewardList3).


%% 获取下一次奖励的列表
get_reward_of_next_day(NextDay, AllRewards) ->
    Rewards = lists:foldl(
                fun(#r_conlogin_reward{begin_day=BeginDay, end_day=EndDay, loop_day=LoopDay} = R, Acc) ->
                        case NextDay >= BeginDay andalso NextDay =< EndDay of
                            true ->
                                case (((NextDay - BeginDay) rem LoopDay) =:= 0 orelse BeginDay =:= NextDay) of
                                    true ->
                                        [R | Acc];
                                    false ->
                                        Acc
                                end;
                            false ->
                                Acc
                        end
                end, [], AllRewards),
    lists:foldl(
      fun(#r_conlogin_reward{id=ID, min_level=MinLevel, max_level=MaxLevel, need_payed=NeedPayed,
                             type=Type, type_id=TypeID, need_vip_level=NeedVipLevel,
                             num=Num, silver=Silver, gold=Gold, bind=Bind}, Acc) ->
              [#p_conlogin_reward{id=ID, type=Type, type_id=TypeID, min_level=MinLevel, max_level=MaxLevel, need_vip_level=NeedVipLevel,
                                  need_payed=NeedPayed, num=Num, silver=Silver, gold=Gold, bind=Bind} | Acc]
      end, [], Rewards).
    
    

%% 获取最近的下一次奖励的天数
%% 返回-1表示没有下一次奖励
get_next_reward_day(CurrentDay, AllRewards) ->
    %% 遍历出所有 begin end 之间的所有奖励
    lists:foldl(
        fun(#r_conlogin_reward{begin_day=BeginDay, end_day=EndDay, loop_day=LoopDay}, Acc) ->
                case  EndDay > CurrentDay of
                    true ->
                        case CurrentDay - BeginDay >= 0 of
                            true ->
                                RemDay = (CurrentDay - BeginDay) rem LoopDay,
                                NextDayTmp = CurrentDay + (LoopDay - RemDay),
                                case NextDayTmp < Acc orelse Acc =:= -1 of
                                    true ->
                                        NextDayTmp;
                                    false ->
                                        Acc
                                end;
                            false ->
                                case Acc > BeginDay orelse Acc =:= -1 of
                                    true ->
                                        BeginDay;
                                    false ->
                                        Acc
                                end
                        end; 
                    false ->
                        Acc
                end
        end, -1, AllRewards).

%% @doc 获取连续登陆保护时间
get_conlogin_protect_day(RoleID) ->
    IsVip = mod_vip:is_role_vip(RoleID),
    if
        IsVip ->
            [ProtectDay] = common_config_dyn:find(etc, vip_conlogin_protect_day);
        true ->
            [ProtectDay] = common_config_dyn:find(etc, conlogin_protect_day)
    end,
    {ok, ProtectDay}.
