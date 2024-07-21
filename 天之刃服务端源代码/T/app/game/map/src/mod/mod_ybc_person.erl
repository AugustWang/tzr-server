%% Author: lenovo
%% Created: 2010-11-22
%% Description: TODO: Add description to mod_ybc_person
-module(mod_ybc_person).
-include("mgeem.hrl").
-include("office.hrl").
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([
         handle/1, 
         change_ybc_color/2, 
         killed/1, 
         timeout/1,
         stop_personybc_faction/2,
         get_time_mul_award/0,
         faction_ybc_status/1,
         can_use_ybc_faction_time/5,
         notice/1,
         init_event/0
        ]).

-export([get_default_speed/0]).

-define(YBC_MAX_TIMES, 3).%%最大次数
-define(YBC_PERSON_TIME, 1200).%%个人镖车时间限制
-define(YBC_TIMEOUT_DEL_TIME, 7200).%%超时删除时间

-define(YBC_STATE_NOT_PUBLIC, 0).%%未发布状态
-define(YBC_STATE_FIX, 1).%%拉镖状态
-define(YBC_STATE_KILLED, 2).%%镖车被劫状态
-define(YBC_STATE_TIMEOUT, 3).%%超时状态
-define(YBC_STATE_TIMEOUT_DEL, 4).%%超时被删除状态
-define(YBC_STATE_NOT_NEARBY, 5).%%不在附近状态

-define(HP_RECOVER_SPEED_1, 10).%%基础回血速度1
-define(HP_RECOVER_SPEED_2, 3).%%基础回血速度2

-define(HP_BASE_1, 500).%%基础血1
-define(HP_BASE_2, 80).%%基础血2

-define(MAGIC_DEF_1, 4).%%基础魔防1
-define(MAGIC_DEF_2, 30).%%基础魔防2

-define(PHYS_DEF_1, 4).%%基础物防1
-define(PHYS_DEF_2, 30).%%基础物防2

-define(YBC_BASE_MOVE_SPEED_DEBUG, 200).%%镖车调试时的速度
-define(YBC_BASE_MOVE_SPEED, 200).%%基础移动速度

-define(ALLOW_DISTANCE_X, 10).
-define(ALLOW_DISTANCE_Y, 10).
-define(DAY_SECONDS, 86400).
-define(FACTION_TIME, 2400).%%国运状态时间
-define(FACTION_FAMILY_CONTRIBUTE, 5).%%国运扣除门派贡献度数量
-define(FACTION_MIN_LEVEL, 31).%%国运最小等级

%%镖车状态
-define(YBC_LOG_STATE_KILLED_NORMAL, 2).%%普通镖车被劫
-define(YBC_LOG_STATE_KILLED_FACTION, 12).%%国运镖车被劫

-define(YBC_LOG_STATE_TIMEOUT_NORMAL, 3).%%普通镖车超时
-define(YBC_LOG_STATE_TIMEOUT_FACTION, 13).%%国运镖车超时

-define(YBC_LOG_STATE_TIMEOUT_DEL_NORMAL, 4).%%普通镖车超时被删除
-define(YBC_LOG_STATE_TIMEOUT_DEL_FACTION, 14).%%国运镖车超时被删除

-define(YBC_LOG_STATE_SUCC_NORMAL, 6).%%普通镖车成功
-define(YBC_LOG_STATE_SUCC_FACTION, 16).%%国运镖车成功

-define(YBC_LOG_STATE_CANCEL_NORMAL, 7).%%普通镖车取消
-define(YBC_LOG_STATE_CANCEL_FACTION, 17).%%国运镖车取消

-define(FACTION_YBC_START_MIN_H, 0).%%国运允许的最小时间-小时
-define(FACTION_YBC_START_MAX_H, 24).%%国运允许的最大时间-小时
-define(FACTION_YBC_START_DEFAULT_TIME, {19,00}).%%国运开始默认时间
-define(FACTION_PERDAY_CHANGE_TIME_MAX, 1).%%每天修改次数上限

-define(FACTION_PUBLIC_TYPE_CHANGE, 0).%%只是修改时间
-define(FACTION_PUBLIC_TYPE_PUBLIC, 1).%%只是立即发布
-define(FACTION_PUBLIC_TYPE_CHANGE_AND_PUBLIC, 2).%%立即发布及修改时间
-define(PERSON_YBC_BASEEXP(LEAVE),math:pow((LEAVE), 2.1)*20).%%玩家等级^2.1 × 20

%%=============start 一键刷镖颜色 ============
-define(CHANGE_YBC_COLOR_ITEM_TYPE,11600001).   %%换车令type_id

-define(err_not_enough_money,1001). %%没有足够的钱
-define(err_not_need_refresh,1002). %%不需要刷新
-define(err_refresh_again,1003).  %%请重新刷新
-define(err_not_enough_item,1004).  %%没有足够的道具
%%=============end 一键刷镖颜色 ===========
%%国运时间record
-record(faction_ybc_time, {start_h, start_m, end_h, end_m}).
-record(faction_ybc_config, {change_day, old, new, change_time=0}).

-record(ybc_person_cost, {level, silver_bind, silver}).

%% 国运期间自动拉镖消耗的元宝数量
-define(AUTO_YBC_GOLD, 1).

%%
%% API Functions
%%
handle({Unique, ?PERSONYBC, ?PERSONYBC_PUBLIC, DataIn, RoleID, _PID, Line, MapState}) ->
    case auth_request_public({RoleID, DataIn}) of
        {error, not_enough_silver, Silver} ->
            SilverStr = common_misc:format_silver(?_LANG_SILVER, Silver),
            Reason = io_lib:format(?_LANG_PERSONYBC_SILVER_NOT_ENOUGH, [SilverStr]),
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, Reason});
        {error, not_enough_silver_bind, SilverBind} ->
            SilverBindStr = common_misc:format_silver(?_LANG_BIND_SILVER, SilverBind),
            Reason = io_lib:format(?_LANG_PERSONYBC_SILVER_NOT_ENOUGH, [SilverBindStr]),
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, Reason});
        {error, max_times} ->
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_MAX_TIMES});
        {error, has_public} ->
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_HAS_PUBLIC});
        {error, has_end} ->
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_HAS_END});
        {error, not_in_distance} ->
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_DISTANCE});
        {error, level_limit} ->
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_LEVEL_LIMIT});
        {error, family_limit} ->
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_FAMILY});
        {error, doing_faminy_ybc} ->
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_DOING_FAMILY_YBC});
        {error, not_enough_family_contribute} ->
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_NOT_ENOUGH_FAMILY_CONTRIBUTE});
        {error, faction_ybc_level_limit} ->
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_FACTION_LEVEL_LIMIT});
        ok ->
            do_handle({?PERSONYBC_PUBLIC, Line, RoleID, DataIn, Unique, MapState}) 
    end;

handle({Unique, ?PERSONYBC, ?PERSONYBC_CANCEL, _DataIn, RoleID, _PID, Line, MapState}) ->
    case auth_request_cancel(RoleID) of
        {error, not_public} ->
            do_handle_error({?PERSONYBC_CANCEL, Line, RoleID, Unique, ?_LANG_PERSONYBC_NOT_PUBLIC});
        {ok, YbcID} ->
            do_handle({?PERSONYBC_CANCEL, Line, RoleID, Unique, YbcID, MapState})
    end;

handle({Unique, ?PERSONYBC, ?PERSONYBC_COMMIT, _DataIn, RoleID, _PID, Line, MapState}) ->
    case auth_request_commit(RoleID) of
        {error, not_public} ->
            do_handle_error({?PERSONYBC_COMMIT, Line, RoleID, Unique, ?_LANG_PERSONYBC_NOT_PUBLIC});
        {error, not_in_distance} ->
            do_handle_error({?PERSONYBC_COMMIT, Line, RoleID, Unique, ?_LANG_PERSONYBC_DISTANCE});
        {error, ybc_not_in_distance} ->
            common_broadcast:bc_send_msg_role(
              RoleID,
              ?BC_MSG_TYPE_CENTER, 
              ?BC_MSG_SUB_TYPE, 
              ?_LANG_PERSONYBC_YBC_DISTANCE),
            do_handle_error({?PERSONYBC_COMMIT, Line, RoleID, Unique, ?_LANG_PERSONYBC_YBC_DISTANCE}); 
        {ok, YbcID} ->
            do_handle({?PERSONYBC_COMMIT, Line, RoleID, Unique, YbcID, MapState})
    end;

%% 前端请求开始自动拉镖
handle({Unique, ?PERSONYBC, ?PERSONYBC_AUTO, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_personybc_auto(Unique, ?PERSONYBC, ?PERSONYBC_AUTO, DataIn, RoleID, PID);
%% 设置默认自动或者默认不自动
handle({Unique, ?PERSONYBC, ?PERSONYBC_SET_AUTO, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_personybc_set_auto(Unique, ?PERSONYBC, ?PERSONYBC_SET_AUTO, DataIn, RoleID, PID);

handle({Unique, ?PERSONYBC, ?PERSONYBC_INFO, DataIn, RoleID, _PID, Line, MapState}) ->
    case auth_request_info({RoleID, DataIn}) of
        ok ->
            do_handle({?PERSONYBC_INFO, Line, RoleID, DataIn, Unique, MapState});
        Error ->
            ?ERROR_MSG("~ts:~w", ["获取镖车信息失败", Error]),
            ok
    end;

handle({Unique, ?PERSONYBC, ?PERSONYBC_FACTION, DataIn, RoleID, _PID, Line, MapState}) ->
    case auth_request_faction({RoleID, DataIn}) of
        {error, has_public} ->
            do_handle_error({?PERSONYBC_FACTION, 
                             Line, RoleID, Unique, 
                             ?_LANG_PERSONYBC_FACTION_HAS_PUBLIC});
        {error, not_in_distance} ->
            do_handle_error({?PERSONYBC_FACTION, Line, RoleID, Unique, ?_LANG_PERSONYBC_DISTANCE});
        {error, have_no_auth} ->
            do_handle_error({?PERSONYBC_FACTION, Line, RoleID, Unique, ?_LANG_PERSONYBC_HAVE_NO_AUTH});
        {error, not_faction_ybc_time} ->
            do_handle_error({?PERSONYBC_FACTION, Line, RoleID, Unique, ?_LANG_PERSONYBC_NOT_FACTION_YBC_TIME});
        {error, faction_perday_change_time_limit} ->
            do_handle_error({?PERSONYBC_FACTION, Line, RoleID, Unique, ?_LANG_PERSONYBC_FACTION_CHANGE_TIME_LIMIT});
        {error, faction_silver_not_enough} ->
            %%do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_FACTION_SILVER_NOT_ENOUGH});
            do_handle({?PERSONYBC_FACTION, Line, RoleID, Unique, DataIn, MapState});
        {error, faction_doing_spy} ->
            do_handle_error({?PERSONYBC_FACTION, Line, RoleID, Unique, ?_LANG_PERSONYBC_FACTION_DOING_SPY});
        {error, faction_spy_same} ->
            do_handle_error({?PERSONYBC_FACTION, Line, RoleID, Unique, ?_LANG_PERSONYBC_FACTION_SPY_SAME});
        {error, faction_waroffaction_limit} ->
            do_handle_error({?PERSONYBC_FACTION, Line, RoleID, Unique, ?_LANG_PERSONYBC_FACTION_WAROFFACTION_LIMIT});
        ok ->
            do_handle({?PERSONYBC_FACTION, Line, RoleID, Unique, DataIn, MapState})
    end;

handle({Unique,?PERSONYBC,?PERSONYBC_AUTO_REFRESH_COLOR,DataIn,RoleID,PID,_Line,_MapState})->
    case DataIn#m_personybc_auto_refresh_color_tos.is_auto_buy of
        true->
            do_auto_refresh_color_use_money(Unique,DataIn,RoleID,PID);
        _->
            do_auto_refresh_color_use_item(Unique,DataIn,RoleID,PID)
    end;

handle({admin_start_faction_ybc,FactionID, StartH, StartM})->
    do_handle({admin_start_faction_ybc,FactionID, StartH, StartM});

handle(Info) ->
    ?ERROR_MSG("~ts:~w", ["个人拉镖匹配到非法数据", Info]).

do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, Reason}) ->
    DataRecord = #m_personybc_public_toc{succ=false,reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PERSONYBC, ?PERSONYBC_PUBLIC, DataRecord);

do_handle_error({?PERSONYBC_CANCEL, Line, RoleID, Unique, Reason}) ->
    DataRecord = #m_personybc_cancel_toc{succ=false,reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PERSONYBC, ?PERSONYBC_CANCEL, DataRecord);

do_handle_error({?PERSONYBC_COMMIT, Line, RoleID, Unique, Reason}) ->
    DataRecord = #m_personybc_commit_toc{succ=false,reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PERSONYBC, ?PERSONYBC_COMMIT, DataRecord);

do_handle_error({?PERSONYBC_FACTION, Line, RoleID, Unique, Reason}) ->
    DataRecord = #m_personybc_faction_toc{succ=false,reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PERSONYBC, ?PERSONYBC_FACTION, DataRecord);

do_handle_error(Info) ->
    ?ERROR_MSG("~ts:~w", ["个人拉镖匹配到非法数据", Info]).

do_auto_refresh_color_use_money(Unique,DataIn,RoleID,PID)->
    case catch can_auto_refresh_color_use_money(RoleID,DataIn) of
        {ok,MaxRefreshTimes,CurColor,ColorChangeTimes}->
            do_auto_refresh_color_use_money2({Unique,DataIn,RoleID,PID},CurColor,MaxRefreshTimes,ColorChangeTimes);
        {error,ErrCode,ErrReason}->
            do_auto_refresh_color_error(Unique,DataIn,RoleID,PID,ErrCode,ErrReason)
    end.

can_auto_refresh_color_use_money(RoleID,DataIn)->
    %%是否有道具 是否有元宝
    {ok,Num}= mod_bag:get_goods_num_by_typeid([1], RoleID,?CHANGE_YBC_COLOR_ITEM_TYPE),
    {ok,#p_role_attr{gold=Gold,gold_bind=GoldBind}}=mod_map_role:get_role_attr(RoleID),    
    case Num=:=0 andalso Gold+GoldBind<2 of
        true->
            throw({error,?err_not_enough_money,""});
        false->
            next
    end,
    %%是否有需要刷颜色
    case db:dirty_read(?DB_YBC_PERSON, RoleID) of
        [#r_ybc_person{color_change_times=ColorChangeTimes}] ->
            ok;
        [] ->
            ColorChangeTimes=0
    end,
    CurColor = get_ybc_color(RoleID),
    case CurColor < DataIn#m_personybc_auto_refresh_color_tos.color of
        true->
            {ok,Num+((Gold+GoldBind) div 2),CurColor,ColorChangeTimes};
        false->
            throw({error,?err_not_need_refresh,""})
    end.

do_auto_refresh_color_use_money2({Unique,DataIn,RoleID,PID},CurColor,MaxRefreshTimes,ColorChangeTimes)->
    Color = DataIn#m_personybc_auto_refresh_color_tos.color,
    {ok,NewColorChangeTimes,NewColor}=refresh_ybc_color(MaxRefreshTimes,ColorChangeTimes,Color,CurColor),
    RefreshTimes = NewColorChangeTimes-ColorChangeTimes,
    {ok,BindNum}=mod_bag:get_goods_num_by_typeid([1], RoleID, ?CHANGE_YBC_COLOR_ITEM_TYPE, true),
    {ok,Num} = mod_bag:get_goods_num_by_typeid([1], RoleID, ?CHANGE_YBC_COLOR_ITEM_TYPE, false),
    {ok,#p_role_attr{gold=Gold,gold_bind=GoldBind}=RoleAttr} = mod_map_role:get_role_attr(RoleID),
    case db:transaction(
           fun()-> 
                       if RefreshTimes=< BindNum ->
                              {ok,UpList,DelList} = mod_bag:decrease_goods_by_typeid(RoleID, [1], ?CHANGE_YBC_COLOR_ITEM_TYPE, RefreshTimes, true),
                              {UpList,DelList,undefined};
                          RefreshTimes=< BindNum+Num ->
                              {ok,UpList1,DelList1} = mod_bag:decrease_goods_by_typeid(RoleID, [1], ?CHANGE_YBC_COLOR_ITEM_TYPE, BindNum, true),
                              {ok,UpList2,DelList2} = mod_bag:decrease_goods_by_typeid(RoleID, [1], ?CHANGE_YBC_COLOR_ITEM_TYPE, RefreshTimes-BindNum, false),
                              {UpList1++UpList2,DelList1++DelList2,undefined};
                          RefreshTimes=< BindNum+Num+ (GoldBind div 2)->
                              {ok,UpList1,DelList1} = mod_bag:decrease_goods_by_typeid(RoleID, [1], ?CHANGE_YBC_COLOR_ITEM_TYPE, BindNum, true),
                              {ok,UpList2,DelList2} = mod_bag:decrease_goods_by_typeid(RoleID, [1], ?CHANGE_YBC_COLOR_ITEM_TYPE, Num, false),
                              GoldBindCost = (RefreshTimes-BindNum-Num)*2,
                              RoleAttr1 = RoleAttr#p_role_attr{gold_bind=GoldBind-GoldBindCost},
                              mod_map_role:set_role_attr(RoleID, RoleAttr1),
                              common_consume_logger:use_gold({RoleID,GoldBindCost,0,?CONSUME_TYPE_GOLD_FAMILY_DONATE,""}),
                              {UpList1++UpList2,DelList1++DelList2,RoleAttr1};
                          RefreshTimes=< BindNum+Num+((GoldBind+Gold) div 2)->
                              {ok,UpList1,DelList1} = mod_bag:decrease_goods_by_typeid(RoleID, [1], ?CHANGE_YBC_COLOR_ITEM_TYPE, BindNum, true),
                              {ok,UpList2,DelList2} = mod_bag:decrease_goods_by_typeid(RoleID, [1], ?CHANGE_YBC_COLOR_ITEM_TYPE, Num, false),
                              GoldCost = (RefreshTimes - BindNum - Num)*2 - GoldBind,
                              RoleAttr1 = RoleAttr#p_role_attr{gold=Gold-GoldCost,gold_bind=0},
                              mod_map_role:set_role_attr(RoleID, RoleAttr1),
                              common_consume_logger:use_gold({RoleID,GoldBind,GoldCost,?CONSUME_TYPE_GOLD_FAMILY_DONATE,""}),
                              {UpList1++UpList2,DelList1++DelList2,RoleAttr1};
                          true->
                              db:abort({?err_refresh_again,""})
                       end
           end) of
        {atomic,{NewUpList,NewDelList,NewRoleAttr}}->
            %% 成功之后再脏读脏写
            case db:dirty_read(?DB_YBC_PERSON, RoleID) of
                [] ->
                    NewYbcPerson = #r_ybc_person{
                                      role_id=RoleID, 
                                      last_complete_time=erlang:now(), 
                                      do_times=0, 
                                      complete_times=0, 
                                      current_color=NewColor,
                                      color_change_times=NewColorChangeTimes};
                [YbcPerson] ->
                    NewYbcPerson = 
                        YbcPerson#r_ybc_person{current_color=NewColor,
                                               color_change_times=NewColorChangeTimes}
            end,
            db:dirty_write(?DB_YBC_PERSON, NewYbcPerson),
            common_misc:del_goods_notify({role, RoleID}, NewDelList),
            common_misc:update_goods_notify({role, RoleID}, NewUpList),
            case is_record(NewRoleAttr,p_role_attr) of
                true->
                   common_misc:send_role_gold_change(RoleID, NewRoleAttr);
                false->
                    ignore
            end,
            R =#m_personybc_auto_refresh_color_toc{item_num=RefreshTimes,
                                                   color = NewColor
                                                   },
            common_misc:unicast2(PID, Unique, ?PERSONYBC, ?PERSONYBC_AUTO_REFRESH_COLOR, R);
        {aborted,{ErrCode,ErrReason}}->
            ?ERROR_MSG("刷镖车失败  Reason:~w",[ErrCode]),
            do_auto_refresh_color_error(Unique,DataIn,RoleID,PID,ErrCode,ErrReason)
    end.

%% MaxRefreshTimes 最大可刷新次数
%% ColorChangeTimes 当前镖车颜色刷新次数
%% DestColor 目标颜色
%% CurColor 当前颜色

refresh_ybc_color(0,ColorChangeTimes,_DestColor,CurColor)->
    {ok,ColorChangeTimes,CurColor};
refresh_ybc_color(MaxRefreshTimes,ColorChangeTimes,DestColor,CurColor)->
    SeedList = [{get_prop_change_nums_pro(1, ColorChangeTimes), 1}, 
                {get_prop_change_nums_pro(2, ColorChangeTimes), 2}, 
                {get_prop_change_nums_pro(3, ColorChangeTimes), 3}, 
                {get_prop_change_nums_pro(4, ColorChangeTimes), 4}, 
                {get_prop_change_nums_pro(5, ColorChangeTimes), 5}],
    NewColor=random_muti_pro(SeedList),
    case NewColor<DestColor of
        true->
            case CurColor >=4 of
                true->
                    refresh_ybc_color(MaxRefreshTimes-1,ColorChangeTimes+1,DestColor,CurColor);
                false->
                    refresh_ybc_color(MaxRefreshTimes-1,ColorChangeTimes+1,DestColor,NewColor)
            end;
        false->
            {ok,ColorChangeTimes+1,NewColor}
    end.

do_auto_refresh_color_use_item(Unique,DataIn,RoleID,PID)->
    case catch can_auto_refresh_color_use_item(RoleID,DataIn) of
        {ok,MaxRefreshTimes,CurColor,ColorChangeTimes}->
            do_auto_refresh_color_use_item2({Unique,DataIn,RoleID,PID},CurColor,MaxRefreshTimes,ColorChangeTimes);
        {error,ErrCode,ErrReason}->
            do_auto_refresh_color_error(Unique,DataIn,RoleID,PID,ErrCode,ErrReason)
    end.

can_auto_refresh_color_use_item(RoleID,DataIn)->
    %%是否有道具 是否有元宝
    {ok,Num}= mod_bag:get_goods_num_by_typeid([1], RoleID,?CHANGE_YBC_COLOR_ITEM_TYPE),
    case Num=:=0 of
        true->
            throw({error,?err_not_enough_item,""});
        false->
            next
    end,
    %%是否有需要刷颜色
    case db:dirty_read(?DB_YBC_PERSON, RoleID) of
        [#r_ybc_person{color_change_times=ColorChangeTimes}] ->
            ok;
        [] ->
            ColorChangeTimes=0
    end,
    CurColor = get_ybc_color(RoleID),
    case CurColor < DataIn#m_personybc_auto_refresh_color_tos.color of
        true->
            {ok,Num,CurColor,ColorChangeTimes};
        false->
            throw({error,?err_not_need_refresh,""})
    end.

do_auto_refresh_color_use_item2({Unique,DataIn,RoleID,PID},CurColor,MaxRefreshTimes,ColorChangeTimes)->
    Color = DataIn#m_personybc_auto_refresh_color_tos.color,
    {ok,NewColorChangeTimes,NewColor}=refresh_ybc_color(MaxRefreshTimes,ColorChangeTimes,Color,CurColor),
    RefreshTimes = NewColorChangeTimes-ColorChangeTimes,
    {ok,BindNum}=mod_bag:get_goods_num_by_typeid([1], RoleID, ?CHANGE_YBC_COLOR_ITEM_TYPE, true),
    {ok,Num} = mod_bag:get_goods_num_by_typeid([1], RoleID, ?CHANGE_YBC_COLOR_ITEM_TYPE, false),
    case db:transaction(
           fun()-> 
                   if RefreshTimes=< BindNum ->
                          {ok,UpList,DelList} = mod_bag:decrease_goods_by_typeid(RoleID, [1], ?CHANGE_YBC_COLOR_ITEM_TYPE, RefreshTimes, true),
                          {UpList,DelList};
                      RefreshTimes=< BindNum+Num ->
                          {ok,UpList1,DelList1} = mod_bag:decrease_goods_by_typeid(RoleID, [1], ?CHANGE_YBC_COLOR_ITEM_TYPE, BindNum, true),
                          {ok,UpList2,DelList2} = mod_bag:decrease_goods_by_typeid(RoleID, [1], ?CHANGE_YBC_COLOR_ITEM_TYPE, RefreshTimes-BindNum, false),
                          {UpList1++UpList2,DelList1++DelList2};
                      true->
                          db:abort({?err_refresh_again,""})
                   end
           end) of
        {atomic,{NewUpList,NewDelList}}->
            %% 成功之后再脏读脏写
            case db:dirty_read(?DB_YBC_PERSON, RoleID) of
                [] ->
                    NewYbcPerson = #r_ybc_person{
                                      role_id=RoleID, 
                                      last_complete_time=erlang:now(), 
                                      do_times=0, 
                                      complete_times=0, 
                                      current_color=NewColor,
                                      color_change_times=NewColorChangeTimes};
                [YbcPerson] ->
                    NewYbcPerson = 
                        YbcPerson#r_ybc_person{current_color=NewColor,
                                               color_change_times=NewColorChangeTimes}
            end,
            db:dirty_write(?DB_YBC_PERSON, NewYbcPerson),
            common_misc:del_goods_notify({role, RoleID}, NewDelList),
            common_misc:update_goods_notify({role, RoleID}, NewUpList),
            R =#m_personybc_auto_refresh_color_toc{item_num=RefreshTimes,
                                                   color = NewColor
                                                   },
            common_misc:unicast2(PID, Unique, ?PERSONYBC, ?PERSONYBC_AUTO_REFRESH_COLOR, R);
        {aborted,{ErrCode,ErrReason}}->
            ?ERROR_MSG("刷镖车失败  Reason:~w",[ErrCode]),
            do_auto_refresh_color_error(Unique,DataIn,RoleID,PID,ErrCode,ErrReason)
    end.

do_auto_refresh_color_error(Unique,_DataIn,_RoleID,PID,ErrCode,ErrReason)->
    R = #m_personybc_auto_refresh_color_toc{err_code=ErrCode,
                                           reason = ErrReason},
    common_misc:unicast2(PID, Unique, ?PERSONYBC, ?PERSONYBC_AUTO_REFRESH_COLOR, R).
    


reset_role_speed(RoleID) ->
    RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID, role),
    case mod_map_role:get_role_base(RoleID) of
        {ok, #p_role_base{move_speed=MoveSpeed}} ->
            %% 玩家停止自动拉镖，还原玩家速度并广播
            mod_map_actor:set_actor_mapinfo(RoleID, role, RoleMapInfo#p_map_role{move_speed=MoveSpeed}),
            R = #m_map_update_actor_mapinfo_toc{actor_id=RoleID, actor_type=1, role_info=RoleMapInfo#p_map_role{move_speed=MoveSpeed}},
            mgeem_map:do_broadcast_insence_include([{role, RoleID}], ?MAP, ?MAP_UPDATE_ACTOR_MAPINFO, R, mgeem_map:get_state());
        _ ->
            ignore
    end.

%% 请求自动拉镖
do_personybc_auto(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_personybc_auto_tos{type=Type} = DataIn,
    %% 做如下几件事情: 修改玩家速度和状态，广播玩家信息
    case db:transaction(fun() -> t_do_personybc_auto(RoleID, Type) end) of
        {atomic, Result} ->
            RoleMapInfo = mod_map_actor:get_actor_mapinfo(RoleID, role),
            YbcID = mod_map_ybc:get_person_ybc_id(RoleID),            
            case Result of
                ok ->
                    [#r_ybc{move_speed=MoveSpeed}] = db:dirty_read(?DB_YBC, YbcID),
                    mod_map_actor:set_actor_mapinfo(RoleID, role, RoleMapInfo#p_map_role{move_speed=MoveSpeed}),
                    R = #m_map_update_actor_mapinfo_toc{actor_id=RoleID, actor_type=1, role_info=RoleMapInfo#p_map_role{move_speed=MoveSpeed}},
                    mgeem_map:do_broadcast_insence_include([{role, RoleID}], ?MAP, ?MAP_UPDATE_ACTOR_MAPINFO, R, mgeem_map:get_state()),
                    %% 玩家开始自动拉镖，降低玩家速度并并广播
                    ok;
                reset ->
                    reset_role_speed(RoleID),
                    ok
            end,            
            {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
            ChangeList = [
                          #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=RoleAttr#p_role_attr.gold}],
            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList),
            common_misc:unicast2(PID, Unique, Module, Method, #m_personybc_auto_toc{succ=true}),
            ok;
        {aborted, Error} ->
            case erlang:is_binary(Error) of
                true ->
                    Reason = Error;
                false ->
                    Reason = ?_LANG_PERSONYBC_SYSTEM_ERROR_WHEN_AUTO_YBC,
                    ?ERROR_MSG("~ts:~w", ["自动拉镖时发生意外错误", Error])
            end,
            common_misc:unicast2(PID, Unique, Module, Method, #m_personybc_auto_toc{succ=falser, reason=Reason})
    end,                   
    ok.

t_do_personybc_auto(RoleID, Type) ->  
    ?ERROR_MSG("~p", [Type]),
    case Type of
        true ->
            t_set_auto_begin(RoleID);
        false ->
            t_set_auto_end(RoleID)
    end.

%% 开始自动拉镖
t_set_auto_begin(RoleID) ->
    {ok, RoleState} = mod_map_role:get_role_state(RoleID),
    [#r_ybc_person{last_auto_date=LastAutoDate} = PersonYbc] = db:read(?DB_YBC_PERSON, RoleID, write),
    {ok, #p_role_base{faction_id=FactionID}} = mod_map_role:get_role_base(RoleID),
    {Date, _} = erlang:localtime(),
    case Date =:= LastAutoDate of
        true ->
            %% 不用扣费了
            mod_map_role:set_role_state(RoleID, RoleState#r_role_state2{auto_ybc=true}),
            ok;
        false ->
            case is_faction_ybc(FactionID) of
                true ->
                    case mod_vip:is_role_vip(RoleID) of
                        true ->
                            %% VIP 特权
                            mod_map_role:set_role_state(RoleID, RoleState#r_role_state2{auto_ybc=true}),
                            ok;
                        false ->                            
                            %% 扣除元宝
                            {ok, #p_role_attr{gold=Gold}=RoleAttr} = mod_map_role:get_role_attr(RoleID),
                            case Gold >= ?AUTO_YBC_GOLD of
                                true ->
                                    mod_map_role:set_role_attr(RoleID, RoleAttr#p_role_attr{gold=Gold-?AUTO_YBC_GOLD}),
                                    db:write(?DB_YBC_PERSON, PersonYbc#r_ybc_person{last_auto_date=Date}, write),
                                    common_consume_logger:use_gold({RoleID, 0, ?AUTO_YBC_GOLD, ?CONSUME_TYPE_GOLD_AUTO_YBC, ""}),
                                    mod_map_role:set_role_state(RoleID, RoleState#r_role_state2{auto_ybc=true}),
                                    ok;
                                false ->
                                    Reason = common_tool:to_binary(io_lib:format(?_LANG_YBC_PERSON_NOT_ENOUGH_GOLD_WHEN_AUTO_YBC, [?AUTO_YBC_GOLD])),
                                    db:abort(Reason)
                            end
                    end;
                false ->
                    %% 非国运期间不用扣费
                    mod_map_role:set_role_state(RoleID, RoleState#r_role_state2{auto_ybc=true}),
                    ok
            end
    end.            

%% 停止自动拉镖
t_set_auto_end(RoleID) ->
    {ok, RoleState} = mod_map_role:get_role_state(RoleID),
    mod_map_role:set_role_state(RoleID, RoleState#r_role_state2{auto_ybc=false}),
    reset.


%% 设置默认自动拉镖或者默认不自动拉镖
do_personybc_set_auto(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_personybc_set_auto_tos{flag=Flag} = DataIn,
    case db:transaction(
           fun() ->
                   [PersonYbc] = db:read(?DB_YBC_PERSON, RoleID, write),
                   db:write(?DB_YBC_PERSON, PersonYbc#r_ybc_person{auto=Flag}, write)
           end)
    of
        {atomic, ok} ->
            R = #m_personybc_set_auto_toc{succ=true, flag=Flag},
            common_misc:unicast2(PID, Unique, Module, Method, R);
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w", ["设置自动拉镖开关发生系统错误", Error]),
            R = #m_personybc_set_auto_toc{succ=false, reason=?_LANG_PERSONYBC_SYSTEM_ERROR_WHEN_SET_AUTO},
            common_misc:unicast2(PID, Unique, Module, Method, R)
    end,
    ok.


do_handle({?PERSONYBC_PUBLIC, Line, RoleID, DataIn, Unique, MapState}) ->

    Type = DataIn#m_personybc_public_tos.type,

    YbcCreateInfo = init_ybc_create_info(RoleID),
    MapProcessName = MapState#map_state.map_name,
    global:send(MapProcessName, {mod_map_ybc, {create_ybc, YbcCreateInfo}}),

    Color = YbcCreateInfo#p_ybc_create_info.color,
    [{RoleID, RoleName, _RoleLevel, CostSilverBind, CostSilver}] = YbcCreateInfo#p_ybc_create_info.role_list, 

    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    FactionID = RoleBase#p_role_base.faction_id,
    {FactionStatusAtom, _} = faction_ybc_status(FactionID),
    Info = get_info(Color, Type, RoleID),

    Result = 
        common_transaction:transaction(
          fun() ->
                  {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
                  #p_role_attr{silver=RoleSilver, 
                               silver_bind=RoleSilverBind,
                               gold=Gold,
                               gold_bind=GoldBind,
                               family_contribute=FamilyContribute} = RoleAttr,
                  if
                      CostSilver > RoleSilver ->
                          common_transaction:abort({not_enough_silver, CostSilver});
                      CostSilverBind > RoleSilverBind ->
                          common_transaction:abort({not_enough_silver_bind, CostSilverBind});
                      Type =:= 1 andalso FamilyContribute < ?FACTION_FAMILY_CONTRIBUTE ->
                          common_transaction:abort(not_enough_family_contribute);
                      true ->
                          ignore
                  end,
                  NewSilver = RoleSilver-CostSilver,
                  NewSilverBind = RoleSilverBind-CostSilverBind,
                  NewGold = Gold,
                  NewGoldBind = GoldBind,
                  if
                      Type =:= 1 ->
                          CostFamilyContribute =  ?FACTION_FAMILY_CONTRIBUTE;
                      true ->
                          CostFamilyContribute = 0
                  end,
                  NewRoleAttr = RoleAttr#p_role_attr{silver=NewSilver, 
                                                     silver_bind=NewSilverBind,
                                                     gold=NewGold,
                                                     gold_bind=NewGoldBind},

                  mod_map_role:set_role_attr(RoleID, NewRoleAttr),

                  common_consume_logger:use_silver(
                    {RoleID, 
                     CostSilverBind, 
                     CostSilver, 
                     ?CONSUME_TYPE_SILVER_MISSION_YBC,
                     ""}),

                  common_consume_logger:use_gold(
                    {RoleID, 
                     0, 
                     0, 
                     ?CONSUME_TYPE_GOLD_MISSION_YBC,
                     ""}),

                  {NewSilver, NewSilverBind, NewGold, NewGoldBind, CostSilverBind, CostSilver, -CostFamilyContribute}
          end),

    case Result of
        {atomic, {NewSilver, NewSilverBind, NewGold, NewGoldBind, CostSilverBind, CostSilver, CostFamilyContribute}} ->
            FamilyID = RoleBase#p_role_base.family_id,
            if
                CostFamilyContribute < 0 ->
                    common_family:info(FamilyID, {add_contribution, RoleID, CostFamilyContribute});
                true ->
                    ignore
            end,

            if
                Type =:= 1 andalso FactionStatusAtom =:= activing ->
                    set_doing_person_ybc(RoleID, public_faction_ybc);
                FamilyID =:= 0 ->
                    set_doing_person_ybc(RoleID, public_no_family);
                true ->
                    set_doing_person_ybc(RoleID, public)
            end,

            notify_attr_change(RoleID, 
                               Line, 
                               NewSilver, 
                               NewSilverBind, 
                               NewGold, 
                               NewGoldBind),

            ColorName = get_color_name(Color),
            if
                Color >= 4 ->
                    RoleNameStr = common_tool:to_list(RoleName),
                    BroadcastMsg = 
                        lists:flatten(
                          io_lib:format(
                            ?_LANG_PERSONYBC_GET_GOOD_COLOR, 
                            [common_misc:get_faction_name(FactionID),RoleNameStr, ColorName])
                         ),
                    common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER, ?BC_MSG_SUB_TYPE, BroadcastMsg);
                true ->
                    ignore
            end,
            CostSilverStr = common_misc:format_silver(?_LANG_SILVER, CostSilver),
            CostSilverBindStr = common_misc:format_silver(?_LANG_BIND_SILVER, CostSilverBind),
            CostStr = lists:concat([CostSilverStr, CostSilverBindStr]),
            GetYbcNotify = io_lib:format(?_LANG_PERSONYBC_SUCC_PUBLIC_YBC, [CostStr, ColorName]),
            common_broadcast:bc_send_msg_role(RoleID, ?BC_MSG_TYPE_SYSTEM, GetYbcNotify),

            NewInfo = Info#p_personybc_info{
                        status=?YBC_STATE_FIX, 
                        start_time = YbcCreateInfo#p_ybc_create_info.create_time,
                        time_limit=?YBC_PERSON_TIME},

            DataRecord = #m_personybc_public_toc{
              succ=true, 
              info=NewInfo},
            common_misc:unicast(Line, RoleID, Unique, ?PERSONYBC, ?PERSONYBC_PUBLIC, DataRecord),
            reset_color_change_times(RoleID);

        {aborted, {not_enough_silver, Silver}} ->
            SilverStr = common_misc:format_silver(?_LANG_SILVER, Silver),
            Reason = io_lib:format(?_LANG_PERSONYBC_SILVER_NOT_ENOUGH, [SilverStr]),
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, Reason});
        {aborted, {not_enough_silver_bind, SilverBind}} ->
            SilverBindStr = common_misc:format_silver(?_LANG_BIND_SILVER, SilverBind),
            Reason = io_lib:format(?_LANG_PERSONYBC_SILVER_NOT_ENOUGH, [SilverBindStr]),
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, Reason});
        {aborted, not_enough_family_contribute} ->
            do_handle_error({?PERSONYBC_PUBLIC, Line, RoleID, Unique, ?_LANG_PERSONYBC_NOT_ENOUGH_FAMILY_CONTRIBUTE});
        Other ->
            ?ERROR_MSG("~ts:~w", ["玩家接镖车发生了错误", Other])
    end;

do_handle({?PERSONYBC_CANCEL, Line, RoleID, Unique, YbcID, _MapState}) ->
    [YbcInfo] = db:dirty_read(?DB_YBC, YbcID),
    [#r_role_state{ybc=YbcState}] = db:dirty_read(?DB_ROLE_STATE, RoleID),
    if
        YbcState =:= 3 ->
            YBCLogState = ?YBC_LOG_STATE_CANCEL_FACTION;
        true ->
            YBCLogState = ?YBC_LOG_STATE_CANCEL_NORMAL
    end,
    LogYBC = #r_personal_ybc_log{role_id=RoleID,
                                 start_time=YbcInfo#r_ybc.create_time,
                                 ybc_color=YbcInfo#r_ybc.color,
                                 final_state=YBCLogState,
                                 end_time=common_tool:now()},

    catch common_general_log_server:log_personal_ybc(LogYBC),
    do_cancel_and_notify(Line, RoleID, Unique, YbcID),
    reset_role_speed(RoleID),
    ok;

do_handle({?PERSONYBC_COMMIT, Line, RoleID, Unique, YbcID, _MapState}) ->
    case erlang:get({last_ybc_commit_time, RoleID}) of
        undefined ->
            do_commit(Line, RoleID, Unique, YbcID),
            ok;
        Time ->
            case common_tool:now() - Time < 30 of
                true ->
                    error;
                false ->
                    do_commit(Line, RoleID, Unique, YbcID)
            end
    end;

%% 获取镖车信息
do_handle({?PERSONYBC_INFO, Line, RoleID, DataIn, Unique, _MapState}) ->
    Type = DataIn#m_personybc_info_tos.type,	
    Color = get_ybc_color(RoleID),    
    Info = get_info(Color, Type, RoleID),
    DataRecord = #m_personybc_info_toc{succ=true, info=Info},
    common_misc:unicast(Line, RoleID, Unique, ?PERSONYBC, ?PERSONYBC_INFO, DataRecord);

do_handle({?PERSONYBC_FACTION, Line, RoleID, Unique, DataIn, _MapState}) ->
    #m_personybc_faction_tos{
           type = Type,
           start_h = StartHTmp,
           start_m = StartMTmp
          } = DataIn,

    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    FactionID = RoleBase#p_role_base.faction_id,

    {true, 
     NewTimeStartH, 
     NewTimeStartM,
     NewTimeEndH,
     NewTimeEndM,
     NewStartTime,
     _} = get_faction_ybc_time(StartHTmp, StartMTmp),

    NewTimeTmp = #faction_ybc_time{
      start_h = NewTimeStartH,
      start_m = NewTimeStartM,
      end_h = NewTimeEndH,
      end_m = NewTimeEndM},

    {NowDay, {NowH, NowM, _}} = calendar:local_time(),

    {true, 
     NowTimeStartH, 
     NowTimeStartM,
     NowTimeEndH,
     NowTimeEndM,
     _,
     _} = get_faction_ybc_time(NowH, NowM),

    NowTime = #faction_ybc_time{
      start_h = NowTimeStartH,
      start_m = NowTimeStartM,
      end_h = NowTimeEndH,
      end_m = NowTimeEndM},

    {OldData, CurrentStartTime, _CurrentEndTime} = get_faction_ybc_time(FactionID),
    NowTimeStamp = common_tool:now(),

    if
        Type =:= ?FACTION_PUBLIC_TYPE_CHANGE_AND_PUBLIC ->
            StartTime = NowTimeStamp,
            OldTime = NowTime,
            NewTime = NewTimeTmp;
        Type =:= ?FACTION_PUBLIC_TYPE_PUBLIC ->
            StartTime = NowTimeStamp,
            OldTime = NowTime,
            NewTime = OldData#faction_ybc_config.new;
        NowTimeStamp >= CurrentStartTime ->
            StartTime = CurrentStartTime,
            OldTime = OldData#faction_ybc_config.new,
            NewTime = NewTimeTmp;
        true ->
            OldTime = NewTimeTmp,
            StartTime = NewStartTime,
            NewTime = NewTimeTmp
    end,

    OldChangeDay = OldData#faction_ybc_config.change_day,
    OldChangeTime = OldData#faction_ybc_config.change_time,
    if
        OldChangeDay =/= NowDay ->
            NewChangeTime = 1;
        true ->
            NewChangeTime = OldChangeTime+1
    end,

    NewData = #faction_ybc_config{change_day=NowDay, 
                                  new=NewTime, 
                                  old=OldTime, 
                                  change_time=NewChangeTime},

    common_misc:set_event_state({personybc_faction, FactionID}, NewData),
    %% 扣国库银两
    [YbcFactionSilver] = common_config_dyn:find(office, ybc_faction_fee),
    catch global:send(mgeew_office, {reduce_faction_silver, FactionID, ybc_faction, YbcFactionSilver}),

    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{office_id=OfficeID} = RoleAttr,
    {NpcID, NpcMapID, _TX, _TY} = get_npc_pos(FactionID, 0, ?PERSONYBC_PUBLIC),
    DataRecord = #m_personybc_faction_toc{succ = true, 
                                          public_role_id = RoleID,
                                          public_role_name = common_tool:to_list(RoleBase#p_role_base.role_name),
                                          public_office = OfficeID,
                                          new_start_h = NewTimeStartH,
                                          new_start_m = NewTimeStartM,
                                          new_start_time = NewStartTime,
                                          today_start_time = StartTime,
                                          time_limit = ?FACTION_TIME,
                                          npc_id = NpcID,
                                          map_id = NpcMapID},

    set_event(StartTime, FactionID),

    common_misc:unicast(Line, RoleID, Unique, ?PERSONYBC, ?PERSONYBC_FACTION, DataRecord),

    common_misc:chat_broadcast_to_faction(
      FactionID, 
      ?PERSONYBC, 
      ?PERSONYBC_FACTION, 
      DataRecord,
      [RoleID]);

do_handle({admin_start_faction_ybc, FactionID, StartH, StartM}) ->
    {true,  NewStartH, NewStartM, NewEndH, NewEndM, StartTime, _} = get_faction_ybc_time(StartH, StartM),

    NowTime = #faction_ybc_time{
      start_h = NewStartH,
      start_m = NewStartM,
      end_h = NewEndH,
      end_m = NewEndM},

    {NpcID, NpcMapID, _TX, _TY} = get_npc_pos(FactionID, 0, ?PERSONYBC_PUBLIC),
    DataRecord = #m_personybc_faction_toc{succ = true, 
                                          public_role_id = 0,
                                          public_role_name = "GM",
                                          public_office = ?OFFICE_ID_KING,
                                          new_start_h = NewStartH,
                                          new_start_m = NewStartM,
                                          today_start_time = StartTime,
                                          time_limit = ?FACTION_TIME,
                                          npc_id = NpcID,
                                          map_id = NpcMapID},

    {NowDay, _} = calendar:local_time(),
    NewData = #faction_ybc_config{change_day=NowDay, 
                                  new=NowTime, 
                                  old=NowTime, 
                                  change_time=1},

    common_misc:set_event_state({personybc_faction, FactionID}, NewData),

    set_event(StartTime, FactionID),

    common_misc:chat_broadcast_to_faction(
      FactionID, 
      ?PERSONYBC, 
      ?PERSONYBC_FACTION, 
      DataRecord);

do_handle(Info) ->
    ?ERROR_MSG("~ts:~w", ["个人拉镖匹配到非法数据", Info]).

do_commit(Line, RoleID, Unique, YbcID) ->
    [YbcInfo] = db:dirty_read(?DB_YBC, YbcID),

    [RoleState] = db:dirty_read(?DB_ROLE_STATE, RoleID),
    RoleYbcState = RoleState#r_role_state.ybc,

    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    FactionID = RoleBase#p_role_base.faction_id,

    Result = 
        db:transaction(
          fun() ->
                  t_commit(RoleID, FactionID, RoleYbcState, YbcInfo)
          end),
    case Result of
        {atomic, {Color, Status, AttrAwardList, PropAwardList, ReturnFamilyContribute}} ->
            erlang:put({last_ybc_commit_time, RoleID}, common_tool:now()),
            catch mod_accumulate_exp:role_do_person_ybc(RoleID),
            if
                Status =:= ?YBC_STATE_FIX ->
                    YBCLogState = ?YBC_LOG_STATE_SUCC_NORMAL,
                    [{_RoleID, _RoleName, _RoleLevel, CostSilverBind, CostSilver}] = YbcInfo#r_ybc.role_list,
                    CostSilverStr = common_misc:format_silver(?_LANG_SILVER, CostSilver),
                    CostSilverBindStr = common_misc:format_silver(?_LANG_BIND_SILVER, CostSilverBind),
                    CostStr = lists:concat([CostSilverStr, CostSilverBindStr]),
                    CostStr2 = io_lib:format(?_LANG_PERSONYBC_GIVE_BACK_COST,  [CostStr]),
                    hook_person_ybc:finish(RoleID, Color),
                    common_broadcast:bc_send_msg_role(RoleID, ?BC_MSG_TYPE_SYSTEM, CostStr2);
                Status =:= ?YBC_STATE_TIMEOUT ->
                    YBCLogState = ?YBC_LOG_STATE_TIMEOUT_NORMAL,
                    common_broadcast:bc_send_msg_role(RoleID,?BC_MSG_TYPE_SYSTEM, 
                                                      ?_LANG_PERSONYBC_TIMEOUT_NO_GIVE_BACK_COST);
                Status =:= ?YBC_STATUS_KILLED -> 
                    YBCLogState = ?YBC_LOG_STATE_KILLED_NORMAL,
                    common_broadcast:bc_send_msg_role(RoleID,?BC_MSG_TYPE_SYSTEM, 
                                                      ?_LANG_PERSONYBC_KILLED_NO_GIVE_BACK_COST)
            end,
            FamilyID = RoleBase#p_role_base.family_id,
            if
                ReturnFamilyContribute =/= 0 ->
                    common_family:info(FamilyID, {add_contribution, RoleID, ReturnFamilyContribute});
                true ->
                    ignore
            end,
            set_doing_person_ybc(RoleID, commit),
            change_ybc_color(RoleID, commit),
            mod_map_ybc:del_ybc(YbcID),
            %%完成个人拉镖增加活跃度
            catch hook_activity_task:done_task(RoleID,?ACTIVITY_TASK_PERSON_YBC),
            %% 拉镖活动 
            %% ?TRY_CATCH(hook_spec_activity:hook_ybc_person(RoleID, YbcInfo#r_ybc.color), Err1),
            %%完成拉镖增加拉镖的道具奖励
            hook_activity_map:hook_ybc_person(RoleID),
            if
                RoleYbcState =:= 3 ->
                    YBCLogState2 = YBCLogState+10;%%个人镖状态+10即国运镖状态
                true ->
                    YBCLogState2 = YBCLogState
            end,
            LogYBC = #r_personal_ybc_log{role_id=RoleID,
                                         start_time=YbcInfo#r_ybc.create_time,
                                         ybc_color=YbcInfo#r_ybc.color,
                                         final_state=YBCLogState2,
                                         end_time=common_tool:now()},

            catch common_general_log_server:log_personal_ybc(LogYBC),
            %% 成就 add by caochuncheng 2011-03-07
            if RoleYbcState =:= 1 orelse RoleYbcState =:= 4 ->
                    catch common_mod_achievement:hook(#r_achievement_hook{role_id = RoleID,event_ids = [306006]});
               RoleYbcState =:= 3 ->
                    catch common_mod_achievement:hook(#r_achievement_hook{role_id = RoleID,event_ids = [306006,306007]});
               true ->
                    ignore
            end,
            reset_role_speed(RoleID),
            DataRecord = #m_personybc_commit_toc{succ=true, status=Status, attr_award_list=AttrAwardList, prop_award_list=PropAwardList},
            common_misc:unicast(Line, RoleID, Unique, ?PERSONYBC, ?PERSONYBC_COMMIT, DataRecord);
        {aborted, {man, Reason}} ->
            do_handle_error({?PERSONYBC_COMMIT, Line, RoleID, Unique, Reason});
        {aborted, Error} ->
            ?ERROR_MSG("~ts:~w", ["提交个人拉镖任务出错了", Error]),
            do_handle_error({?PERSONYBC_COMMIT, Line, RoleID, Unique, ?_LANG_SYSTEM_ERROR})
    end.
%%
%% Local Functions
%%
auth_request_info({_RoleID, _DataIn}) ->
    ok.

auth_request_public({RoleID, DataIn}) ->
    %%{error, not_enough_silver}%%银子不足
    %%{error, not_enough_silver_bind}%%绑定银子不足
    %%{error, max_times}%%达到最大次数
    %%ok
    %%{error, has_public}
    Dotimes = get_dotimes(RoleID),
    if
        Dotimes > ?YBC_MAX_TIMES ->
            {error, max_times};
        true ->
            auth_request_public_2({RoleID, DataIn})
    end.

auth_request_public_2({RoleID, DataIn}) ->
    Key = get_unique_key(RoleID),
    case db:dirty_read(?DB_YBC_UNIQUE, Key) of
        [] ->
            auth_request_public_3({RoleID, DataIn});
        [_] ->
            {error, has_public}
    end.

auth_request_public_3({RoleID, DataIn}) ->
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    {_, MapID, TX, TY} = get_npc_pos(RoleBase#p_role_base.faction_id, 0, ?PERSONYBC_PUBLIC),
    NpcPos = #p_pos{tx=TX, ty=TY},

    MapState = mgeem_map:get_state(),
    InMapID = MapState#map_state.mapid,
    case mod_map_actor:get_actor_pos(RoleID, role) of
        undefined ->
            {error, not_in_distance};
        _ when MapID =/= InMapID ->
            {error, not_in_distance};
        Pos ->
            case auth_distance(Pos, NpcPos, ?ALLOW_DISTANCE_X, ?ALLOW_DISTANCE_Y) of
                true ->
                    auth_request_public_4({RoleID, DataIn});
                _ ->
                    {error, not_in_distance}
            end
    end.

auth_request_public_4({RoleID, DataIn}) -> 
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{level=RoleLevel, silver=RoleSilver, silver_bind=RoleSilverBind} = RoleAttr,
    if
        RoleLevel < 30 ->
            {error, level_limit};
        true ->
            {CostType, Silver, _SilverBind} = get_cost(RoleLevel),
            case CostType of

                _ when RoleLevel < 30 ->
                    {error, level_limit};

                _ ->
                    if
                        Silver > RoleSilver + RoleSilverBind ->
                            {error, not_enough_silver, Silver-RoleSilver-RoleSilverBind};
                        true ->
                            auth_request_public_5({RoleID, RoleAttr, DataIn})
                    end
            end
    end.

auth_request_public_5({RoleID, RoleAttr, DataIn}) ->
    Type=DataIn#m_personybc_public_tos.type,
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    FamilyID = RoleBase#p_role_base.family_id,
    if
        FamilyID =:= 0 andalso Type =:= 1 ->
            {error, family_limit};
        true ->
            auth_request_public_6({RoleID, RoleAttr, RoleBase, DataIn})
    end.

auth_request_public_6({RoleID, RoleAttr, RoleBase, DataIn}) ->
    [RoleState] = db:dirty_read(?DB_ROLE_STATE, RoleID),
    RoleYbcState = RoleState#r_role_state.ybc,
    if
        RoleYbcState =:= 3 ->%%国运镖
            {error, has_public}; 
        RoleYbcState =:= 4 ->%%个人普通镖-没门派
            {error, has_public}; 
        RoleYbcState =:= 8 ->
            {error, doing_faminy_ybc};
        RoleYbcState =:= 1 ->
            {error, has_public}; 
        true ->
            auth_request_public_7({RoleID, RoleAttr, RoleBase, DataIn})
    end.

auth_request_public_7({_RoleID, RoleAttr, _RoleBase, DataIn}) ->
    RoleLevel = RoleAttr#p_role_attr.level,
    Type = DataIn#m_personybc_public_tos.type,
    case Type of
        0 ->
            ok;
        1 when RoleLevel < ?FACTION_MIN_LEVEL ->
            {error, faction_ybc_level_limit};
        1 ->
            FamilyContribute = RoleAttr#p_role_attr.family_contribute,
            ?DEBUG("贡献:~w",[FamilyContribute]),
            if
                FamilyContribute < ?FACTION_FAMILY_CONTRIBUTE ->
                    {error, not_enough_family_contribute};
                true ->
                    ok
            end;
        _ ->
            {error, system_error}
    end.

auth_request_cancel(RoleID) ->
    Key = get_unique_key(RoleID),
    case db:dirty_read(?DB_YBC_UNIQUE, Key) of
        [] ->
            {error, not_public};
        [#r_ybc_unique{unique=Key, id=YbcID}] ->
            {ok, YbcID}
    end.

auth_request_commit(RoleID) ->
    Key = get_unique_key(RoleID),
    case db:dirty_read(?DB_YBC_UNIQUE, Key) of
        [] ->
            {error, not_public};
        [#r_ybc_unique{unique=Key, id=YbcID}] ->
            auth_request_commit_2({RoleID, YbcID})
    end.

auth_request_commit_2({RoleID, YbcID}) ->
    {ok, #p_role_attr{level=RoleLevel}} = mod_map_role:get_role_attr(RoleID),
    MapID = mgeem_map:get_mapid(),
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            {error, not_in_distance};
        #p_map_role{pos=Pos, faction_id=FactionID} ->
            Auth =
                lists:foldl(
                  fun({_, _, _, _}, true) ->
                          true;
                     ({_NID, MID, TX, TY}, Acc) ->
                          NpcPos = #p_pos{tx=TX, ty=TY},
                          case MapID =:= MID andalso auth_distance(Pos, NpcPos, ?ALLOW_DISTANCE_X, ?ALLOW_DISTANCE_Y) of
                              true ->
                                  true;
                              _ ->
                                  Acc
                          end
                  end, false, get_commit_npc_list(FactionID, RoleLevel)),
            case Auth of
                true ->
                    auth_request_commit_3({RoleID, YbcID, MapID, Pos});
                _ ->
                    {error, not_in_distance}
            end
    end.

auth_request_commit_3({_RoleID, YbcID, _NpcMapID, RolePos}) -> 
    case mod_map_actor:get_actor_pos(YbcID, ybc) of
        undefined ->
            {error, ybc_not_in_distance};
        Pos ->
            case auth_distance(Pos, RolePos, ?ALLOW_DISTANCE_X, ?ALLOW_DISTANCE_Y) of
                true ->
                    {ok, YbcID};
                _ ->
                    {error, ybc_not_in_distance}
            end
    end.

is_faction_ybc_dirty(FactionID) ->
    {_, TodayStartTime, TodayEndTime} = get_faction_ybc_time(FactionID),
    case TodayStartTime > 0 of
        true ->
            case common_tool:now() > TodayStartTime andalso common_tool:now() < TodayEndTime of
                true ->
                    true;
                false ->
                    false
            end;
        false ->
            false
    end.

is_faction_ybc(FactionID) ->
    {_, TodayStartTime, TodayEndTime} = get_faction_ybc_time(FactionID),
    case TodayStartTime > 0 of
        true ->
            case common_tool:now() > TodayStartTime andalso common_tool:now() < TodayEndTime of
                true ->
                    true;
                false ->
                    false
            end;
        false ->
            false
    end.

get_faction_ybc_time(FactionID) ->
    {Data1, Data2, Data3} = 
        case common_misc:get_event_state({personybc_faction, FactionID}) of
            {false, []} ->
                {StartHTmp, StartMTmp} = ?FACTION_YBC_START_DEFAULT_TIME,
                {true, 
                 StartH, 
                 StartM, 
                 EndH, 
                 EndM, 
                 TodayStartTime, 
                 TodayEndTime} = get_faction_ybc_time(StartHTmp, StartMTmp),

                Time = #faction_ybc_time{
                  start_h = StartH, 
                  start_m = StartM, 
                  end_h = EndH, 
                  end_m = EndM},

                {NowDay, _} = calendar:local_time(),
                Data = #faction_ybc_config{change_day=NowDay, new=Time, old=Time},
                common_misc:set_event_state({personybc_faction, FactionID}, Data),
                {Data, TodayStartTime, TodayEndTime};
            {ok, Data} ->
                {NowDay, _} = calendar:local_time(),
                CurrentData = Data#r_event_state.data,
                ChangeDay = CurrentData#faction_ybc_config.change_day,
                if
                    ChangeDay =:= NowDay ->
                        CurrentTime = CurrentData#faction_ybc_config.old;
                    true ->
                        CurrentTime = CurrentData#faction_ybc_config.new
                end,
                StartHTmp = CurrentTime#faction_ybc_time.start_h,
                StartMTmp = CurrentTime#faction_ybc_time.start_m,
                {true, _, _, _, _, TodayStartTime, TodayEndTime} = get_faction_ybc_time(StartHTmp, StartMTmp),
                {CurrentData, TodayStartTime, TodayEndTime}
        end,

    TimeLimit = auth_request_faction_5(),

    if
        TimeLimit =:= ok ->
            {Data1, Data2, Data3};
        true ->
            {Data1, 0, Data3}
    end.

%% 根据设定的开始小时和分钟来确定具体的开始时间和结束时间（秒数）
get_faction_ybc_time(StartH, StartM) ->
    EndH = StartH+((StartM + ?FACTION_TIME div 60) div 60),
    EndM = (StartM + ?FACTION_TIME div 60) rem 60,
    if
        StartM > 60 orelse EndM < 0 ->
            {error, not_alow_faction_time};
        StartH > ?FACTION_YBC_START_MAX_H orelse EndH > ?FACTION_YBC_START_MAX_H ->
            {error, not_alow_faction_time};
        StartH < ?FACTION_YBC_START_MIN_H orelse EndH < ?FACTION_YBC_START_MIN_H ->
            {error, not_alow_faction_time};
        true ->
            {Day, _} = calendar:local_time(),
            TodayStartTime = common_tool:datetime_to_seconds({Day, {StartH, StartM, 0}}),
            TodayEndTime = common_tool:datetime_to_seconds({Day, {EndH, EndM, 0}}),
            {true, StartH, StartM, EndH, EndM, TodayStartTime, TodayEndTime}
    end.

%%todo
%%注意如果设置的时间已经超过了当前时间，生效时间是明天
%%所以要有个字段标识
auth_request_faction({RoleID, DataIn}) ->
    #m_personybc_faction_tos{
                      type = Type,
                      start_h = StartH,
                      start_m = StartM
                     } = DataIn,

    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    case get_faction_ybc_time(StartH, StartM) of
        {error, Reason} ->
            {error, Reason};
        NewData ->
            {true, NewTimeStartH, 
             NewTimeStartM,
             NewTimeEndH,
             NewTimeEndM,_, _} = NewData,

            FactionID = RoleBase#p_role_base.faction_id,
            CanUseSpyTime = mod_spy:can_use_spy_time(FactionID, NewTimeStartH, NewTimeStartM, NewTimeEndH, NewTimeEndM),

            {OldData, TodayStartTime, TodayEndTime} = get_faction_ybc_time(FactionID),
            {NowDay, {NowH, _, _}} = calendar:local_time(),
            OldChangeTime = OldData#faction_ybc_config.change_time,
            OldChangeDay = OldData#faction_ybc_config.change_day,

            NowTimeStamp = common_tool:now(),
            if
                NowH < 12 andalso Type =:= ?FACTION_PUBLIC_TYPE_CHANGE_AND_PUBLIC ->
                    {error, not_faction_ybc_time};
                CanUseSpyTime =:= false ->
                    {error, faction_spy_same};
                NowTimeStamp >= TodayStartTime
                andalso
                (Type =:= ?FACTION_PUBLIC_TYPE_CHANGE_AND_PUBLIC 
                 orelse
                 Type =:= ?FACTION_PUBLIC_TYPE_PUBLIC)->
                    if
                        NowTimeStamp >= TodayEndTime ->
                            {error, has_end};
                        true ->
                            {error, has_public}
                    end;
                OldChangeDay =:= NowDay 
                andalso
                OldChangeTime >= ?FACTION_PERDAY_CHANGE_TIME_MAX ->
                    {error, faction_perday_change_time_limit};
                true ->
                    auth_request_faction_1(RoleID, RoleBase)
            end
    end.

auth_request_faction_1(RoleID, RoleBase) ->   
    {_, NpcMapID, TX, TY} = get_npc_pos(RoleBase#p_role_base.faction_id, 0, ?PERSONYBC_FACTION),
    NpcPos = #p_pos{tx=TX, ty=TY},

    MapState = mgeem_map:get_state(),
    RoleMapID = MapState#map_state.mapid,

    case mod_map_actor:get_actor_pos(RoleID, role) of
        undefined ->
            {error, not_in_distance};
        _ when NpcMapID =/= RoleMapID ->
            {error, not_in_distance};
        Pos ->
            case auth_distance(Pos, NpcPos, ?ALLOW_DISTANCE_X, ?ALLOW_DISTANCE_Y) of
                true ->
                    auth_request_faction_2(RoleID, RoleBase);
                _ ->
                    {error, not_in_distance}
            end
    end.

auth_request_faction_2(RoleID, RoleBase) ->
    {ok, RoleAttr} = common_misc:get_dirty_role_attr(RoleID),
    OfficeID = RoleAttr#p_role_attr.office_id,
    if
        OfficeID =/= ?OFFICE_ID_KING
        andalso
        OfficeID =/= ?OFFICE_ID_MINISTER ->
            {error, have_no_auth};
        true ->
            auth_request_faction_3(RoleID, RoleAttr, RoleBase)
    end.

auth_request_faction_3(_RoleID, _RoleAttr, RoleBase) ->
    FactionID = RoleBase#p_role_base.faction_id,
    [#p_faction{silver=Silver}] = db:dirty_read(?DB_FACTION, FactionID),
    [YbcFactionFee] = common_config_dyn:find(office, ybc_faction_fee),

    case Silver > YbcFactionFee of
        false ->
            {error, faction_silver_not_enough};
        _ ->
            ok
    end.

auth_request_faction_4() ->
    %% 国战期间不能发布国探
    case mod_waroffaction:get_waroffaction_stage() of
        undefined ->
            auth_request_faction_5();
        _ ->
            {error, faction_waroffaction_limit}
    end.

auth_request_faction_5() ->
    %% 开服第几天后开启开探
    [StartDiff] = common_config_dyn:find(etc, ybc_faction_start_day),
    [IsOpenYbcFaction] = common_config_dyn:find(etc,is_open_ybc_faction),
    case common_config:get_opened_days() >= StartDiff andalso IsOpenYbcFaction =:= true of
        true ->
            ok;
        _ ->
            {error, start_day_limit}
    end.


auth_distance(Pos1, Pos2, TXDistanceLimit, TYDistanceLimit) ->
    #p_pos{tx=Tx1, ty=Ty1} = Pos1,
    #p_pos{tx=Tx2, ty=Ty2} = Pos2,
    TXDiff = erlang:abs(Tx1 - Tx2),
    TYDiff = erlang:abs(Ty1 - Ty2),
    if
        TXDiff < TXDistanceLimit andalso TYDiff < TYDistanceLimit ->
            true;
        true ->
            false
    end.

%%获取镖车颜色
%%todo 读取数据库获取颜色
get_ybc_color(RoleID) ->
    Now = erlang:now(),
    case db:dirty_read(?DB_YBC_PERSON, RoleID) of
        [] ->
            SeedList = get_commited_change_random_list(),
            Color = random_muti_pro(SeedList),
            NewYbcPerson = 
                #r_ybc_person{
              role_id=RoleID, 
              last_complete_time=Now, 
              do_times=0, 
              complete_times=0, 
              current_color=Color},
            db:dirty_write(?DB_YBC_PERSON, NewYbcPerson),
            Color;
        [YbcPerson] ->
            Key = get_unique_key(RoleID),
            case db:dirty_read(?DB_YBC_UNIQUE, Key) of
                [] ->
                    LastCompleteTime = YbcPerson#r_ybc_person.last_complete_time,
                    {LastDate, _} = calendar:now_to_local_time(LastCompleteTime),
                    {CurrentDate, _} = calendar:now_to_local_time(Now),
                    if
                        LastDate =/= CurrentDate ->
                            SeedList = get_commited_change_random_list(),
                            Color = random_muti_pro(SeedList),
                            NewYbcPerson = 
                                #r_ybc_person{
                              role_id=RoleID, 
                              last_complete_time=Now, 
                              do_times=0, 
                              complete_times=0, 
                              current_color=Color,
                              color_change_times=0},
                            db:dirty_write(?DB_YBC_PERSON, NewYbcPerson),
                            Color;
                        true ->
                            YbcPerson#r_ybc_person.current_color
                    end;
                [#r_ybc_unique{unique=Key, id=YbcID}] ->
                    [YbcInfo] = db:dirty_read(?DB_YBC, YbcID),
                    YbcInfo#r_ybc.color
            end
    end.

%%todo刷新颜色
change_ybc_color(RoleID, Type) ->
    Color = do_change_color(RoleID, Type),
    DataRecord = #m_personybc_color_change_toc{color=Color},
    Line = common_misc:get_role_line_by_id(RoleID),
    common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE, ?PERSONYBC, ?PERSONYBC_COLOR_CHANGE, DataRecord),
    {ok, Color}.

do_change_color(RoleID, prop) ->
    SeedList = get_prop_change_random_list(RoleID),
    Color = random_muti_pro(SeedList),
    CurColor = get_ybc_color(RoleID),
    NewColor = if
                   CurColor >= 4 -> %%保护紫色/橙色
                       if 
                           CurColor < Color ->
                               Color;
                           true ->
                               CurColor
                       end;
                   true ->
                       Color
               end,
    do_set_color_to_db(RoleID, NewColor, prop),
    NewColor;

do_change_color(RoleID, commit) ->
    SeedList = get_commited_change_random_list(),
    Color = random_muti_pro(SeedList),
    do_set_color_to_db(RoleID, Color, commit),
    Color.

do_set_color_to_db(RoleID, Color, Type) ->
    if
        Type =:= prop ->
            ChangeProNum = 1;
        true ->
            ChangeProNum = 0
    end,
    Now = erlang:now(),
    case db:dirty_read(?DB_YBC_PERSON, RoleID) of
        [] ->
            NewYbcPerson = 
                #r_ybc_person{
              role_id=RoleID, 
              last_complete_time=Now, 
              do_times=0, 
              complete_times=0, 
              current_color=Color,
              color_change_times=ChangeProNum};
        [YbcPerson] ->
            OldChangTimes = YbcPerson#r_ybc_person.color_change_times,
            NewYbcPerson = 
                YbcPerson#r_ybc_person{current_color=Color,
                                       color_change_times=OldChangTimes+ChangeProNum}
    end,
    db:dirty_write(?DB_YBC_PERSON, NewYbcPerson).




%%重设镖车颜色刷新次数
reset_color_change_times(RoleID) ->
    Now = erlang:now(),
    case db:dirty_read(?DB_YBC_PERSON, RoleID) of
        [] ->
            NewYbcPerson = 
                #r_ybc_person{
              role_id=RoleID, 
              last_complete_time=Now, 
              do_times=0, 
              complete_times=0, 
              current_color=1,
              color_change_times=0};
        [YbcPerson] ->
            NewYbcPerson = YbcPerson#r_ybc_person{color_change_times=0}
    end,
    db:dirty_write(?DB_YBC_PERSON, NewYbcPerson).

%%获取剩余时间
get_remain_times(CreateTime) ->
    Result = ?YBC_PERSON_TIME - common_misc:diff_time(CreateTime),
    if
        Result < 0 ->
            0;
        true ->
            Result
    end.

get_info(Color, Type, RoleID) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    RoleLevel = RoleAttr#p_role_attr.level,
    Faction = RoleBase#p_role_base.faction_id,    
    Key = get_unique_key(RoleID),    
    case db:dirty_read(?DB_YBC_UNIQUE, Key) of
        [] ->
            FamilyID = RoleBase#p_role_base.family_id,
            if
                %%没有门派的拉镖
                FamilyID =:= 0 andalso Type =:= 0 ->
                    Type2 = 2;
                true ->
                    Type2 = Type
            end,
            do_get_info(0, Type2, Color, RoleID, RoleLevel, Faction);
        [#r_ybc_unique{unique=Key, id=YbcID}] ->
            [RoleState] = db:dirty_read(?DB_ROLE_STATE, RoleID),
            RoleYbcState = RoleState#r_role_state.ybc,
            if
                RoleYbcState =:= 3 ->
                    Type2 = 1;
                RoleYbcState =:= 4 ->
                    Type2 = 2;
                true ->
                    Type2 = 0
            end,
            do_get_info(YbcID, Type2, Color, RoleID, RoleLevel, Faction)
    end.

do_get_info(0, Type, Color, RoleID, RoleLevel, FactionID) ->
    DoTimes = get_dotimes(RoleID),

    %%TYPE只用来获取奖励
    {AttrAwardList, PropAwardList} = get_award_list(succ, Type, DoTimes, RoleLevel),

    %%TYPE在这里不起作用 是因为一旦发布了国运 不管玩家是选择普通还是国运 都应该让前端知道当前状态是国运
    {CostType, Silver, SilverBind} = get_cost(RoleLevel),
    case CostType of

        cost_type_a ->%%主要扣绑定 不够扣不绑定
            CostTypeID=1;

        cost_type_b ->%%只扣不绑定
            CostTypeID=2
    end,

    {CurrentData, TodayStartTime, _TodayEndTime} = get_faction_ybc_time(FactionID),
    CurrentTime = CurrentData#faction_ybc_config.new,
    StartH = CurrentTime#faction_ybc_time.start_h,
    StartM = CurrentTime#faction_ybc_time.start_m,
    {true, _, _, _, _, NewStartTime, _} = get_faction_ybc_time(StartH, StartM),

    {PublicNpcID, _, _, _} = get_npc_pos(FactionID, 0, ?PERSONYBC_PUBLIC),
    {CommitNpcID, _, _, _} = get_npc_pos(FactionID, RoleLevel, ?PERSONYBC_COMMIT),
    {ok, #p_role_base{faction_id=FactionID}} = mod_map_role:get_role_base(RoleID),
    {Date, _} = erlang:localtime(),
    case is_faction_ybc_dirty(FactionID) of
        true ->
            case db:dirty_read(?DB_YBC_PERSON, RoleID) of
                [#r_ybc_person{last_auto_date=LastAutoDate, auto=Auto}] ->
                    case LastAutoDate =:= Date of
                        true ->
                            AutoPayGold = false;
                        false ->
                            AutoPayGold = true
                    end;
                [] ->
                    AutoPayGold = true,
                    Auto = true
            end;
        false ->
            Auto = true,
            AutoPayGold = false
    end,
    #p_personybc_info{color=Color,
                      status=?YBC_STATE_NOT_PUBLIC,
                      start_time=0,
                      time_limit = ?YBC_PERSON_TIME,
                      public_npc_id = PublicNpcID,
                      commit_npc_id = CommitNpcID,
                      do_times=DoTimes,
                      desc="<font color='#F6F5CD'>张将军：\n    护送镖车到边城交给蓝玉将军，请保护好镖车！蓝将军收不到镖车不会给予奖励。</font>",
                      attr_award=AttrAwardList,
                      prop_award=PropAwardList,
                      type=Type,
                      faction_new_start_time = NewStartTime,
                      faction_start_time = TodayStartTime,
                      faction_time_limit = ?FACTION_TIME,
                      cost_type=CostTypeID,
                      cost_silver=Silver,
                      cost_silver_bind=SilverBind,
                      need_notice_when_auto=AutoPayGold,
                      auto_pay_gold=?AUTO_YBC_GOLD,
                      auto=Auto
                     }; 

do_get_info(YbcID, Type, Color, RoleID, RoleLevel, FactionID) ->
    [YbcInfo] = db:dirty_read(?DB_YBC, YbcID),
    InfoStatus = YbcInfo#r_ybc.status,
    CreateTime = YbcInfo#r_ybc.create_time,
    RemainTime = get_remain_times(CreateTime),
    DistanceCheck = check_in_commit_distance(RoleID, YbcID),
    DoTimes = get_dotimes(RoleID),

    {AttrAwardList, PropAwardList} = 
        if
            RemainTime =< 0 ->
                get_award_list(timeout, Type, DoTimes, RoleLevel);
            true ->
                get_award_list(succ, Type, DoTimes, RoleLevel)
        end,        

    if
        InfoStatus =:= ?YBC_STATUS_KILLED ->
            Status = ?YBC_STATE_KILLED,
            Tips = "<font color='#F6F5CD'>蓝玉：\n    镖车没了？边防战火不断，你这种行为会耽误守边战事你知道吗？不罚你难以服众。押金不归还，不给于奖励。</font>";
        RemainTime =< 0 ->
            Status = ?YBC_STATE_TIMEOUT,
            Tips = "<font color='#F6F5CD'>蓝玉：\n    现在才来？！大家都眼巴巴地等着你的镖车，耽误了战事怎么办？</font>";
        DistanceCheck =:= false ->
            Status = ?YBC_STATE_NOT_NEARBY,
            Tips = "<font color='#F6F5CD'>蓝玉：\n    张将军要你送来的镖车呢?快沿途去找找。</font>";
        true ->
            Status = ?YBC_STATE_FIX,
            Tips = "<font color='#F6F5CD'>蓝玉：\n    千里迢迢送镖车，张将军果然没看错人，很有责任心，这是你的银子和一点小意思，请收好。</font>"
    end,

    {PublicNpcID, _, _, _} = get_npc_pos(FactionID, 0, ?PERSONYBC_PUBLIC),
    {CommitNpcID, _, _, _} = get_npc_pos(FactionID, RoleLevel, ?PERSONYBC_COMMIT),
    {CurrentData, TodayStartTime, _TodayEndTime} = get_faction_ybc_time(FactionID),
    CurrentTime = CurrentData#faction_ybc_config.new,
    StartH = CurrentTime#faction_ybc_time.start_h,
    StartM = CurrentTime#faction_ybc_time.start_m,
    {true, _, _, _, _, NewStartTime, _} = get_faction_ybc_time(StartH, StartM),
    {Date, _} = erlang:localtime(),
    {ok, #p_role_base{faction_id=FactionID}} = mod_map_role:get_role_base(RoleID),
    case is_faction_ybc_dirty(FactionID) of
        true ->
            case db:dirty_read(?DB_YBC_PERSON, RoleID) of
                [#r_ybc_person{last_auto_date=LastAutoDate, auto=Auto}] ->
                    case LastAutoDate =:= Date of
                        true ->
                            AutoPayGold = false;
                        false ->
                            AutoPayGold = true
                    end;
                [] ->
                    AutoPayGold = true,
                    Auto = true
            end;
        false ->
            Auto = true,
            AutoPayGold = false
    end,
    #p_personybc_info{color=Color,
                      start_time = CreateTime,
                      time_limit = ?YBC_PERSON_TIME,
                      public_npc_id = PublicNpcID,
                      commit_npc_id = CommitNpcID,
                      status = Status,
                      do_times = DoTimes,
                      desc = Tips,
                      attr_award = AttrAwardList,
                      prop_award = PropAwardList,
                      type = Type,
                      faction_new_start_time = NewStartTime,
                      faction_start_time = TodayStartTime,
                      faction_time_limit = ?FACTION_TIME,
                      need_notice_when_auto=AutoPayGold,
                      auto_pay_gold=?AUTO_YBC_GOLD,
                      auto=Auto
                     }.

check_in_commit_distance(RoleID, YbcID) ->
    RolePos = mod_map_actor:get_actor_pos(RoleID, role),
    YbcPos = mod_map_actor:get_actor_pos(YbcID, ybc),
    if
        RolePos =:= undefined
        orelse
        YbcPos =:= undefined ->
            false;
        true ->
            TXDiff = erlang:abs(RolePos#p_pos.tx-YbcPos#p_pos.tx),
            TYDiff = erlang:abs(RolePos#p_pos.ty-YbcPos#p_pos.ty),
            (TXDiff =< 3 andalso TYDiff =< 3)
    end.

%%获得镖车创建的信息
init_ybc_create_info(RoleID) ->

    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),

    Color = get_ybc_color(RoleID),
    RoleName = RoleBase#p_role_base.role_name,
    RoleNameStr = common_tool:to_list(RoleName),
    YbcName = lists:flatten(io_lib:format(?_LANG_PERSONYBC_OWNER, [RoleNameStr])),
    CreateType = 1,
    CreatorID = RoleID, 
    GroupID = 0,%%RoleBase#p_role_base.family_id,
    GroupType = 1,
    Color = Color,
    CreateTime = common_tool:now(),
    [YbcTimeOut] = common_config_dyn:find(etc, ybc_timeout),
    EndTime = common_tool:now() + YbcTimeOut,

    RoleLevel = RoleAttr#p_role_attr.level,
    CanAttack = (RoleLevel >= 31),
    FactionID = RoleBase#p_role_base.faction_id,

    ColorMul = get_color_mul(Color),

    MoveSpeed = get_default_speed(),
    PhysDef = erlang:round(?PHYS_DEF_1 * RoleLevel + ?PHYS_DEF_2 * RoleLevel),
    MagicDef = PhysDef,
    RecoverSpeed = erlang:round(?HP_RECOVER_SPEED_1 * ColorMul + ?HP_RECOVER_SPEED_2 * ColorMul),
    MaxHp = erlang:round(?HP_BASE_1 * ColorMul + ?HP_BASE_2 * RoleLevel),

    %%todo 获取真正的押金
    {_CostType, Silver, _SilverBind} = get_cost(RoleLevel),

    RoleSilverBind = RoleAttr#p_role_attr.silver_bind,

    if
        RoleSilverBind >= Silver ->
            CostSilverBind = Silver,
            CostSilver = 0;
        true ->
            CostSilverBind = RoleSilverBind,
            CostSilver = Silver - RoleSilverBind
    end,

    #p_ybc_create_info{
      role_list=[{RoleID, RoleName, RoleLevel, CostSilverBind, CostSilver}], 
      max_hp=MaxHp,
      move_speed=MoveSpeed, name= YbcName,
      faction_id=FactionID, 
      create_type=CreateType, creator_id=CreatorID,
      group_id=GroupID, group_type=GroupType, color=Color, create_time=CreateTime,
      end_time=EndTime,
      can_attack=CanAttack, 
      buffs=[],
      recover_speed=RecoverSpeed, magic_defence=MagicDef,
      physical_defence=PhysDef, level=RoleLevel}.

%%获取镖车与玩家的映射关系数据
get_unique_key(RoleID) ->
    {0, 1, RoleID}.

get_timeout_exp_award(DoTimes, RoleLevel, Color) ->
    Exp = get_succ_exp_award(DoTimes, RoleLevel, Color),
    NewExpNum = erlang:round(0.2 * Exp#p_personybc_award_attr.attr_num),
    Exp#p_personybc_award_attr{attr_num=NewExpNum}.

get_timeout_silver_bind_award(DoTimes, RoleLevel, Color) ->
    SilverBind = get_succ_silver_bind_award(DoTimes, RoleLevel, Color),
    TimeoutMul = 
        if
            DoTimes < ?YBC_MAX_TIMES ->
                0.2;
            true ->
                0.4
        end,
    NewSilverBindNum = erlang:round(TimeoutMul * SilverBind#p_personybc_award_attr.attr_num),
    SilverBind#p_personybc_award_attr{attr_num=NewSilverBindNum}.

get_succ_exp_award(DoTimes, RoleLevel, Color) ->    
    Num = DoTimes * ?PERSON_YBC_BASEEXP(RoleLevel) * get_color_mul_exp(Color) * get_time_mul_award(exp),
    Num2 = erlang:round(Num),
    #p_personybc_award_attr{color=Color, attr_type=1, attr_num=Num2}.

get_succ_silver_bind_award(DoTimes, RoleLevel, Color) when DoTimes < ?YBC_MAX_TIMES ->
    Num = erlang:round(0.5 * (RoleLevel*50+5000)*get_color_mul(Color)*get_time_mul_award(silver_bind)),
    #p_personybc_award_attr{color=Color, attr_type=3, attr_num=Num};

get_succ_silver_bind_award(_DoTimes, RoleLevel, Color) ->
    Num = erlang:round((RoleLevel*50+5000)*get_color_mul(Color)*get_time_mul_award(silver_bind)),
    #p_personybc_award_attr{color=Color, attr_type=3, attr_num=Num}.

get_exp_award(succ, DoTimes, RoleLevel, Color) ->
    get_succ_exp_award(DoTimes, RoleLevel, Color);
get_exp_award(timeout, DoTimes, RoleLevel, Color) ->
    get_timeout_exp_award(DoTimes, RoleLevel, Color).

get_silver_bind_award(succ, DoTimes, RoleLevel, Color) ->
    get_succ_silver_bind_award(DoTimes, RoleLevel, Color);
get_silver_bind_award(timeout, DoTimes, RoleLevel, Color) ->
    get_timeout_silver_bind_award(DoTimes, RoleLevel, Color).

get_award_list(Status, Type, DoTimes, RoleLevel) ->

    case Type of
        0 ->
            SilverBind1 = get_silver_bind_award(Status, DoTimes, RoleLevel, 1),
            SilverBind2 = get_silver_bind_award(Status, DoTimes, RoleLevel, 2),
            SilverBind3 = get_silver_bind_award(Status, DoTimes, RoleLevel, 3),
            SilverBind4 = get_silver_bind_award(Status, DoTimes, RoleLevel, 4),
            SilverBind5 = get_silver_bind_award(Status, DoTimes, RoleLevel, 5),

            Exp1 = get_exp_award(Status, DoTimes, RoleLevel, 1),
            Exp2 = get_exp_award(Status, DoTimes, RoleLevel, 2),
            Exp3 = get_exp_award(Status, DoTimes, RoleLevel, 3),
            Exp4 = get_exp_award(Status, DoTimes, RoleLevel, 4),
            Exp5 = get_exp_award(Status, DoTimes, RoleLevel, 5),

            SilverBindAwardList = [SilverBind1, SilverBind2, SilverBind3, SilverBind4, SilverBind5],
            SilverAwardList = [],
            ExpAwardList = [Exp1, Exp2, Exp3, Exp4, Exp5];
        1 ->
            SilverBind1 = get_silver_bind_award(Status, DoTimes, RoleLevel, 1),
            SilverBind2 = get_silver_bind_award(Status, DoTimes, RoleLevel, 2),
            SilverBind3 = get_silver_bind_award(Status, DoTimes, RoleLevel, 3),
            SilverBind4 = get_silver_bind_award(Status, DoTimes, RoleLevel, 4),
            SilverBind5 = get_silver_bind_award(Status, DoTimes, RoleLevel, 5),

            Exp1 = get_faction_exp_award(Status, DoTimes, RoleLevel, 1),
            Exp2 = get_faction_exp_award(Status, DoTimes, RoleLevel, 2),
            Exp3 = get_faction_exp_award(Status, DoTimes, RoleLevel, 3),
            Exp4 = get_faction_exp_award(Status, DoTimes, RoleLevel, 4),
            Exp5 = get_faction_exp_award(Status, DoTimes, RoleLevel, 5),

            {Silver1, SilverBind12} = get_faction_silver_award(SilverBind1),
            {Silver2, SilverBind22} = get_faction_silver_award(SilverBind2),
            {Silver3, SilverBind32} = get_faction_silver_award(SilverBind3),
            {Silver4, SilverBind42} = get_faction_silver_award(SilverBind4),
            {Silver5, SilverBind52} = get_faction_silver_award(SilverBind5),

            SilverBindAwardList = [SilverBind12, SilverBind22, SilverBind32, SilverBind42, SilverBind52],
            SilverAwardList = [Silver1, Silver2, Silver3, Silver4, Silver5],
            ExpAwardList = [Exp1, Exp2, Exp3, Exp4, Exp5];
        2 ->%%没有门派拉镖
            SilverBind1 = get_silver_bind_award(Status, DoTimes, RoleLevel, 1),
            SilverBind2 = get_silver_bind_award(Status, DoTimes, RoleLevel, 2),
            SilverBind3 = get_silver_bind_award(Status, DoTimes, RoleLevel, 3),
            SilverBind4 = get_silver_bind_award(Status, DoTimes, RoleLevel, 4),
            SilverBind5 = get_silver_bind_award(Status, DoTimes, RoleLevel, 5),


            SilverBind12 = get_no_family_silver_award(SilverBind1, succ),
            SilverBind22 = get_no_family_silver_award(SilverBind2, succ),
            SilverBind32 = get_no_family_silver_award(SilverBind3, succ),
            SilverBind42 = get_no_family_silver_award(SilverBind4, succ),
            SilverBind52 = get_no_family_silver_award(SilverBind5, succ),

            Exp1 = get_exp_award(Status, DoTimes, RoleLevel, 1),
            Exp2 = get_exp_award(Status, DoTimes, RoleLevel, 2),
            Exp3 = get_exp_award(Status, DoTimes, RoleLevel, 3),
            Exp4 = get_exp_award(Status, DoTimes, RoleLevel, 4),
            Exp5 = get_exp_award(Status, DoTimes, RoleLevel, 5),

            Exp12 = get_no_family_exp_award(Exp1, succ),
            Exp22 = get_no_family_exp_award(Exp2, succ),
            Exp32 = get_no_family_exp_award(Exp3, succ),
            Exp42 = get_no_family_exp_award(Exp4, succ),
            Exp52 = get_no_family_exp_award(Exp5, succ),

            SilverBindAwardList = [SilverBind12, SilverBind22, SilverBind32, SilverBind42, SilverBind52],
            SilverAwardList = [],
            ExpAwardList = [Exp12, Exp22, Exp32, Exp42, Exp52];
        _ ->
            SilverBindAwardList = [],
            SilverAwardList = [],
            ExpAwardList = []
    end,
    {ExpAwardList ++ SilverBindAwardList ++ SilverAwardList, []}.

%%返回 {不绑银子, 绑银子}
get_faction_silver_award(SilverBind) ->
    SilverBindNum = SilverBind#p_personybc_award_attr.attr_num,
    SilverBindNum2 = erlang:round(0.85 * SilverBindNum),
    SilverNum = erlang:round(0.15 * SilverBindNum),
    {SilverBind#p_personybc_award_attr{attr_type=2, attr_num=SilverNum},
     SilverBind#p_personybc_award_attr{attr_num=SilverBindNum2}}.

get_faction_exp_award(Status, DoTimes, RoleLevel, Color) ->
    #p_personybc_award_attr{color=Color, attr_type=1, attr_num=Num} 
        = get_exp_award(Status, DoTimes, RoleLevel, Color),
    Num2 = erlang:round(Num * 2),
    #p_personybc_award_attr{color=Color, attr_type=1, attr_num=Num2}.

get_no_family_silver_award(SilverBind, succ) ->
    SilverBindNum = SilverBind#p_personybc_award_attr.attr_num,
    SilverBindNum2 = erlang:round(0.2 * SilverBindNum),
    SilverBind#p_personybc_award_attr{attr_num=SilverBindNum2};

get_no_family_silver_award(SilverBind, timeout) ->
    SilverBindNum = SilverBind#p_personybc_award_attr.attr_num,
    SilverBindNum2 = erlang:round(0.05 * SilverBindNum),
    SilverBind#p_personybc_award_attr{attr_num=SilverBindNum2}.

get_no_family_exp_award(Exp, succ) ->
    ExpNum = Exp#p_personybc_award_attr.attr_num,
    ExpNum2 = erlang:round(0.2 * ExpNum),
    Exp#p_personybc_award_attr{attr_num=ExpNum2};

get_no_family_exp_award(Exp, timeout) ->
    ExpNum = Exp#p_personybc_award_attr.attr_num,
    ExpNum2 = erlang:round(0.05 * ExpNum),
    Exp#p_personybc_award_attr{attr_num=ExpNum2}.
%%发放奖励
%%todo 返回金钱给玩家
%%todo 判断镖车是被劫了 超时了还是成功提交
t_commit(RoleID, FactionID, RoleYbcState, YbcInfo) ->
    #r_ybc{ ybc_id=_YbcID,
            status=Status,
            role_list=[{RoleID, _RoleName, RoleLevel, SilverBind, Silver}],
            map_id=_MapID,
            hp=_HP,
            max_hp=_MaxHP,
            pos=_Pos,
            move_speed=_MoveSpeed,  
            name=_YbcName,
            create_type=_CreateType,  
            creator_id=_CreatorID,  
            group_id=_GroupID,  
            group_type=_GroupType,  
            physical_defence=_PhysDef,  
            magic_defence=_MagicDef,  
            recover_speed=_RecoverSpeed,  
            buffs=_Buffers,  
            create_time=CreateTime,  
            end_time=_EndTime,  
            color=Color,  
            can_attack=_CanAttack} = YbcInfo,

    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),

    DoTimes = get_dotimes(RoleID),

    DiffTime = common_misc:diff_time(CreateTime),

    {FactionStatusAtom, _} = faction_ybc_status(FactionID),
    if
        RoleYbcState =:= 3 andalso FactionStatusAtom =:= activing ->
            ReturnFamilyContribute = 0,
            Type = 1;
        RoleYbcState =:= 3 ->
            ReturnFamilyContribute = ?FACTION_FAMILY_CONTRIBUTE,
            Type = 0;
        RoleYbcState =:= 4 ->
            ReturnFamilyContribute = 0,
            Type = 2;
        true ->
            ReturnFamilyContribute = 0,
            Type = 0
    end,

    if
        Status =:= ?YBC_STATUS_KILLED ->
            AttrAwardList = [],
            PropAwardList = [],
            TrueStatus = ?YBC_STATE_KILLED;%%被劫了
        DiffTime > ?YBC_PERSON_TIME ->
            TrueStatus = ?YBC_STATE_TIMEOUT,
            {AttrAwardList, PropAwardList} = 
                get_commit_award(RoleLevel, DoTimes, Color, Type, timeout),

            give_award_and_notify(RoleID, RoleAttr, AttrAwardList, PropAwardList, 0, 0, ReturnFamilyContribute),
            set_dotimes(RoleID);%%超时
        DiffTime > ?YBC_TIMEOUT_DEL_TIME ->
            AttrAwardList = [],
            PropAwardList = [],
            TrueStatus = ?YBC_STATE_TIMEOUT_DEL;%%超时
        true ->
            {AttrAwardList, PropAwardList} = 
                get_commit_award(RoleLevel, DoTimes, Color, Type, succ),

            give_award_and_notify(RoleID, RoleAttr, AttrAwardList, PropAwardList, SilverBind, Silver, ReturnFamilyContribute),
            TrueStatus = ?YBC_STATE_FIX,
            set_dotimes(RoleID)%%正好
    end,

    {Color, TrueStatus, AttrAwardList, PropAwardList, ReturnFamilyContribute}.

get_commit_award(RoleLevel, DoTimes, Color, Type, succ) ->
    SilverBind = get_succ_silver_bind_award(DoTimes, RoleLevel, Color),

    if
        Type =:= 1 ->
            Exp = get_faction_exp_award(succ, DoTimes, RoleLevel, Color),
            {SilverAward, SilverBindAward} = get_faction_silver_award(SilverBind),
            AttrAwardList = [Exp, SilverAward, SilverBindAward];
        Type =:= 2 ->
            Exp = get_succ_exp_award(DoTimes, RoleLevel, Color),
            Exp2 = get_no_family_exp_award(Exp, succ),
            SilverBindAward = get_no_family_silver_award(SilverBind, succ),
            AttrAwardList = [Exp2, SilverBindAward];
        true ->
            Exp = get_succ_exp_award(DoTimes, RoleLevel, Color),
            AttrAwardList = [Exp, SilverBind]
    end,

    {AttrAwardList, []};

get_commit_award(RoleLevel, DoTimes, Color, Type, timeout) ->

    SilverBind = get_succ_silver_bind_award(DoTimes, RoleLevel, Color),
    TimeoutMul = 
        if
            DoTimes < ?YBC_MAX_TIMES ->
                0.2;
            true ->
                0.4
        end,
    NewSilverBindNum = erlang:round(TimeoutMul * SilverBind#p_personybc_award_attr.attr_num),
    NewSilverBind = SilverBind#p_personybc_award_attr{attr_num=NewSilverBindNum},

    if
        Type =:= 1 ->
            Exp = get_faction_exp_award(timeout, DoTimes, RoleLevel, Color),
            {SilverAward, SilverBindAward} = get_faction_silver_award(NewSilverBind),
            AttrAwardList = [Exp, SilverAward, SilverBindAward];
        Type =:= 2 ->
            Exp = get_timeout_exp_award(DoTimes, RoleLevel, Color),
            NewExp = get_no_family_exp_award(Exp, timeout),
            SilverBindAward = get_no_family_silver_award(SilverBind, timeout),
            AttrAwardList = [NewExp, SilverBindAward];
        true ->
            Exp = get_timeout_exp_award(DoTimes, RoleLevel, Color),
            AttrAwardList = [Exp, NewSilverBind]
    end,

    {AttrAwardList, []}.

give_award_and_notify(RoleID, RoleAttr, AttrAwardList, _PropAwardList, CostSilverBind, CostSilver, ReturnFamilyContribute) ->
    {GetSilverBind, GetSilver, GetExp} = 
        lists:foldl(
          fun(AttrAward, {ResultSilverBind, ResultSilver, ResultExp}) ->
                  #p_personybc_award_attr{color=_Color, attr_type=Type, attr_num=Num} = AttrAward,
                  if
                      Type =:= 1 ->
                          {ResultSilverBind, ResultSilver, ResultExp+Num};
                      Type =:= 2 ->
                          {ResultSilverBind, ResultSilver+Num, ResultExp};
                      Type =:= 3 ->
                          {ResultSilverBind+Num, ResultSilver, ResultExp};
                      true ->
                          {ResultSilverBind, ResultSilver, ResultExp}
                  end
          end, {0, 0, 0},AttrAwardList),
    #p_role_attr{silver_bind=RoleSilverBind, silver=RoleSilver, gold=RoleGold, gold_bind=RoleGoldBind} = RoleAttr,

    GetSilverBind2 =  GetSilverBind+CostSilverBind,
    NewRoleSilverBind = RoleSilverBind+GetSilverBind2,
    GetSilver2 = GetSilver+CostSilver,
    NewRoleSilver = RoleSilver+GetSilver2,

    NewRoleAttr = RoleAttr#p_role_attr{silver_bind=NewRoleSilverBind, 
                                       silver=NewRoleSilver},
    mod_map_role:set_role_attr(RoleID, NewRoleAttr),

    Line = common_misc:get_role_line_by_id(RoleID),
    notify_attr_change(RoleID, 
                       Line, 
                       NewRoleSilver, 
                       NewRoleSilverBind, 
                       RoleGold, 
                       RoleGoldBind),

    common_consume_logger:gain_silver(
      {RoleID, 
       GetSilverBind2, 
       GetSilver, 
       ?GAIN_TYPE_SILVER_MISSION_YBC, 
       ""}),

    common_consume_logger:gain_gold(
      {RoleID, 
       0, 
       0, 
       ?GAIN_TYPE_GOLD_MISSION_YBC,
       ""}),

    if
        ReturnFamilyContribute > 0 ->
            {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
            FamilyID = RoleBase#p_role_base.family_id,
            common_family:info(FamilyID, {add_contribution, RoleID, ReturnFamilyContribute});
        true ->
            ignore
    end,

    common_misc:add_exp_unicast(RoleID, GetExp).

%%设置角色role_state
set_doing_person_ybc(RoleID, Status) ->
    [RoleState] = db:dirty_read(?DB_ROLE_STATE, RoleID),

    if
        Status =:= commit
        orelse
        Status =:= cancel ->
            Data = RoleState#r_role_state{role_id=RoleID,  normal=true, ybc=0};
        Status =:= public ->
            Data = RoleState#r_role_state{role_id=RoleID,  ybc=1};
        Status =:= public_faction_ybc ->
            Data = RoleState#r_role_state{role_id=RoleID,  ybc=3};
        Status =:= public_no_family ->
            Data = RoleState#r_role_state{role_id=RoleID,  ybc=4}
    end,
    db:dirty_write(?DB_ROLE_STATE, Data).

%%获得押金数量
get_cost(RoleLevel) when RoleLevel < 20->
    {cost_type_a, 999999, 999999};%%该等级下玩家不能接镖的
get_cost(RoleLevel) ->
    [#ybc_person_cost{level=RoleLevel, 
                      silver=Silver, 
                      silver_bind=SilverBind}] = common_config_dyn:find(ybc_person_cost, RoleLevel),

    if
        RoleLevel >= 31 ->
            CostType = cost_type_b;
        true ->
            CostType = cost_type_a
    end,
    {CostType, SilverBind, Silver}.

%%@doc 获取拉镖的次数，这里会比实际的+1，很恶心的代码，有木有！
get_dotimes(RoleID) ->
    case db:dirty_read(?DB_YBC_PERSON, RoleID) of
        [YbcPerson] ->
            #r_ybc_person{
          role_id=RoleID, 
          last_complete_time=LastCompleteTime, 
          do_times=_DoTimes, 
          complete_times=CompleteTimes, 
          current_color=_CurrentColor} = YbcPerson,

            {{Y, M, D}, _} = calendar:now_to_local_time(LastCompleteTime),
            {{NY, NM, ND}, _} = calendar:now_to_local_time(erlang:now()),

            if
                NY =/= Y
                orelse
                NM =/= M
                orelse
                ND =/= D ->
                    1;
                true ->
                    CompleteTimes+1
            end;

        [] ->
            1
    end.

set_dotimes(RoleID) ->
    Now = erlang:now(),
    case db:read(?DB_YBC_PERSON, RoleID, write) of
        [YbcPerson] ->
            #r_ybc_person{
          role_id=RoleID, 
          last_complete_time=LastCompleteTime, 
          do_times=_DoTimes, 
          complete_times=CompleteTimes, 
          current_color=_CurrentColor} = YbcPerson,

            {{Y, M, D}, _} = calendar:now_to_local_time(LastCompleteTime),
            {{NY, NM, ND}, _} = calendar:now_to_local_time(Now),

            if
                NY =/= Y
                orelse
                NM =/= M
                orelse
                ND =/= D ->
                    NewCompleteTimes = 0;
                true ->
                    NewCompleteTimes = CompleteTimes+1
            end,

            %%暂时不考虑do_times和complete_times的区别
            NewYbcPerson = YbcPerson#r_ybc_person{
                             last_complete_time=Now,
                             complete_times=NewCompleteTimes,
                             do_times=NewCompleteTimes};

        [] ->
            NewYbcPerson = 
                #r_ybc_person{
              role_id=RoleID, 
              last_complete_time=Now, 
              do_times=1, 
              complete_times=1, 
              current_color=1}
    end,
    db:write(?DB_YBC_PERSON, NewYbcPerson, write),
    NewYbcPerson.

notify_attr_change(RoleID, 
                   Line, 
                   RoleSilver, 
                   RoleSilverBind, 
                   RoleGold, 
                   RoleGoldBind) ->

    AttrChangeList = 
        [#p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, 
                             new_value = RoleSilver},
         #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, 
                             new_value = RoleSilverBind},
         #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, 
                             new_value = RoleGold},
         #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE,
                             new_value = RoleGoldBind}],

    common_misc:role_attr_change_notify({line, Line, RoleID}, RoleID, AttrChangeList).

%% --------------------------------------------------------------------
%% 多个指定随机概率的随机
%% -------------------------------------------------------------------- 
%% 多概率随机
random_muti_pro(SeedList) ->
    [{BaiPro, BaiVal},{LvPro, LvVal},{LanPro, LanVal},{ZiPro, ZiVal},{ChengPro, ChengVal}] = SeedList,   
    AllRange = BaiPro+LvPro+LanPro+ZiPro+ChengPro,
    Random = common_tool:random(1,AllRange),
    if Random >0 andalso Random =< BaiPro                   
                -> Color = BaiVal;
       Random >BaiPro andalso Random =< BaiPro+LvPro        
                -> Color = LvVal;
       Random > BaiPro+LvPro andalso Random =< BaiPro+ LvPro+LanPro
                -> Color = LanVal;
       Random >BaiPro+ LvPro+LanPro andalso Random =< BaiPro+ LvPro+LanPro+ ZiPro
                -> Color = ZiVal;
       Random >BaiPro+ LvPro+LanPro+ ZiPro 
                -> Color = ChengVal
    end,
    Color.

%% --------------------------------------------------------------------
%% 单个概率随机
%% --------------------------------------------------------------------
%% random_single_pro(Pro) when Pro >= 1 ->
%%     random:seed(erlang:now()),
%%     Random = random:uniform(100),
%%     Random =< Pro;
%% random_single_pro(Pro) ->
%%     ?ERROR_MSG("~ts:~w~n", ["单一概率随机的参数错了", Pro]),
%%     false.

%%-----------------------------------------------------------------------------------------------

get_color_name(1) ->
    "<FONT COLOR='#FFFFFF'>白色</FONT>";
get_color_name(2) ->
    "<FONT COLOR='#10ff04'>绿色</FONT>";
get_color_name(3) ->
    "<FONT COLOR='#00c6ff'>蓝色</FONT>";
get_color_name(4) ->
    "<FONT COLOR='#ff00c6'>紫色</FONT>";
get_color_name(5) ->
    "<FONT COLOR='#FF6c00'>橙色</FONT>".

get_time_mul_award(exp) ->
    {Exp, _, _} = get_time_mul_award(),
    Exp;
get_time_mul_award(silver) ->
    {_, Silver, _} = get_time_mul_award(),
    Silver;
get_time_mul_award(silver_bind) ->
    {_, _, SilverBind} = get_time_mul_award(),
    SilverBind;
get_time_mul_award(_) ->
    1.

get_time_mul_award()->
    case common_config_dyn:find(mccq_activity,activity_ybc_person) of 
        [ActKey|_] when is_integer(ActKey)-> 
             get_time_mul_award_2(ActKey);
        _ ->
            {1,1,1}
    end.
get_time_mul_award_2(ActKey) ->
    case common_activity:get_activity_config(ActKey) of
        [ActivityRecord]->
            #r_activity_person_ybc_award{start_time=StartTime,
                                         end_time=EndTime,
                                         award_expr_times=EXPTimes,
                                         award_silver_times=SilverTimes,
                                         award_silver_bind_times=BindSilverTimes} = ActivityRecord,

            CheckActivityTime = check_activity_time(StartTime, EndTime),
            if 
                CheckActivityTime=:=true ->
                    {EXPTimes, SilverTimes, BindSilverTimes};
                true->
                    {1, 1, 1}
            end;
        _ ->
            {1, 1, 1}
    end.

%%@doc 检查活动是否在当天的规定时间段内
check_activity_time({SH,SI,SS}, {EH,EI,ES})->
    {H, I, S} = erlang:time(),
    StartSeconds = SH*3600 + SI*60 + SS,
    EndSeconds = EH*3600 + EI*60 + ES,
    NowSeconds = H*3600 + I*60 + S,
    (NowSeconds>=StartSeconds) andalso (EndSeconds>=NowSeconds).


get_prop_change_nums_pro(1, ChangeTimes) ->
    do_get_prop_change_nums_pro(-200, 6500, ChangeTimes);

get_prop_change_nums_pro(2, ChangeTimes) ->
    do_get_prop_change_nums_pro(150, 2500, ChangeTimes);

get_prop_change_nums_pro(3, ChangeTimes) ->
    do_get_prop_change_nums_pro(75, 500, ChangeTimes);

get_prop_change_nums_pro(4, ChangeTimes) ->
    do_get_prop_change_nums_pro(30, 250, ChangeTimes);

get_prop_change_nums_pro(5, ChangeTimes) ->
    do_get_prop_change_nums_pro(10, 80, ChangeTimes).

do_get_prop_change_nums_pro(Num, CurrentPro, ChangeTimes) ->
    NewPro = CurrentPro + Num*ChangeTimes,
    if
        NewPro < 0 orelse NewPro > 10000 ->
            0;
        true ->
            NewPro
    end.

get_prop_change_random_list(RoleID) ->
    case db:dirty_read(?DB_YBC_PERSON, RoleID) of
        [#r_ybc_person{color_change_times=ColorChangeTimes}] ->
            ok;
        [] ->
            ColorChangeTimes = 0
    end,

    [{get_prop_change_nums_pro(1, ColorChangeTimes), 1}, 
     {get_prop_change_nums_pro(2, ColorChangeTimes), 2}, 
     {get_prop_change_nums_pro(3, ColorChangeTimes), 3}, 
     {get_prop_change_nums_pro(4, ColorChangeTimes), 4}, 
     {get_prop_change_nums_pro(5, ColorChangeTimes), 5}].

get_commited_change_random_list() ->
    [{6000, 1}, {3000, 2}, {600, 3}, {300, 4}, {1, 5}].

get_color_mul_exp(1) ->
    1 ;
get_color_mul_exp(2) ->
    1.25 ;
get_color_mul_exp(3) ->
    1.8 ;
get_color_mul_exp(4) ->
    2.5 ;
get_color_mul_exp(5) ->
    3.2 .

get_color_mul(1) ->
    1 ;
get_color_mul(2) ->
    1.25 ;
get_color_mul(3) ->
    2 ;
get_color_mul(4) ->
    4 ;
get_color_mul(5) ->
    7 .

get_npc_pos(FactionID, Level, Type) ->
    case Type of
        ?PERSONYBC_PUBLIC ->
            [{NpcID, MapID, IndexTX, IndexTY}] = common_config_dyn:find(personybc, {personybc_public_npc, FactionID});
        ?PERSONYBC_FACTION ->
            [{NpcID, MapID, IndexTX, IndexTY}] = common_config_dyn:find(personybc, {personybc_faction_npc, FactionID});
        ?PERSONYBC_COMMIT ->
            [NpcList] = common_config_dyn:find(personybc, {personybc_commit_npc, FactionID}),
            [{NpcID, MapID, IndexTX, IndexTY}] = 
                lists:foldl(fun({MinLevel, MaxLevel, NID, MID, TX, TY}, []) ->
                                    case Level >= MinLevel andalso Level =< MaxLevel of 
                                        true ->
                                            [{NID, MID, TX, TY}];
                                        _ ->
                                            []
                                    end;
                               (_, [R]) ->
                                    [R]
                            end, [], NpcList)
    end,
    {NpcID, MapID, IndexTX, IndexTY}.

get_commit_npc_list(FactionID, Level) ->
    [NpcList] = common_config_dyn:find(personybc, {personybc_commit_npc, FactionID}),
    lists:foldl(
      fun({_MinLevel, MaxLevel, NID, MID, TX, TY}, Acc) ->
              case MaxLevel >= Level of
                  true ->
                      [{NID, MID, TX, TY}|Acc];
                  _ ->
                      Acc
              end
      end, [], NpcList).

killed(YbcID) ->
    [YbcInfo] = db:dirty_read(?DB_YBC, YbcID),
    RoleID = YbcInfo#r_ybc.creator_id,
    Line = common_misc:get_role_line_by_id(RoleID),
    [#r_role_state{ybc=YbcState}] = db:dirty_read(?DB_ROLE_STATE, RoleID),
    if
        YbcState =:= 3 ->
            YBCLogState = ?YBC_LOG_STATE_KILLED_FACTION;
        true ->
            YBCLogState = ?YBC_LOG_STATE_KILLED_NORMAL
    end,
    LogYBC = #r_personal_ybc_log{role_id=RoleID,
                                 start_time=YbcInfo#r_ybc.create_time,
                                 ybc_color=YbcInfo#r_ybc.color,
                                 final_state=YBCLogState,%%todo 找下王涛要真实的拉镖被截状态
                                 end_time=common_tool:now()},

    catch common_general_log_server:log_personal_ybc(LogYBC),
    do_cancel_and_notify(Line, RoleID, ?DEFAULT_UNIQUE, YbcID).

timeout(YbcID) ->
    [YbcInfo] = db:dirty_read(?DB_YBC, YbcID),
    RoleID = YbcInfo#r_ybc.creator_id,
    Line = common_misc:get_role_line_by_id(RoleID),
    [#r_role_state{ybc=YbcState}] = db:dirty_read(?DB_ROLE_STATE, RoleID),
    if
        YbcState =:= 3 ->
            YBCLogState = ?YBC_LOG_STATE_TIMEOUT_DEL_FACTION;
        true ->
            YBCLogState = ?YBC_LOG_STATE_TIMEOUT_DEL_NORMAL
    end,
    LogYBC = #r_personal_ybc_log{role_id=RoleID,
                                 start_time=YbcInfo#r_ybc.create_time,
                                 ybc_color=YbcInfo#r_ybc.color,
                                 final_state=YBCLogState,
                                 end_time=common_tool:now()},
    reset_role_speed(RoleID),
    catch common_general_log_server:log_personal_ybc(LogYBC),
    do_cancel_and_notify(Line, RoleID, ?DEFAULT_UNIQUE, YbcID).

stop_personybc_faction(_EventStateKey, _EventTimeData) ->
    ignore.

faction_ybc_status(FactionID) ->

    ISWarOffFaction = auth_request_faction_4(),

    case common_misc:get_event_state({personybc_faction, FactionID}) of
        _ when ISWarOffFaction ->
            {false, null};
        {false, _} ->
            {false, null};
        {ok, EventState} ->

            {NowDay, _} = calendar:local_time(),
            Data = EventState#r_event_state.data,
            ChangeDay = Data#faction_ybc_config.change_day,
            UseTimeData = 
                if
                    NowDay =/= ChangeDay ->
                        Data#faction_ybc_config.new;
                    true ->
                        Data#faction_ybc_config.old
                end,

            StartH = UseTimeData#faction_ybc_time.start_h,
            StartM = UseTimeData#faction_ybc_time.start_m,

            {true, _, _, _, _, TodayStartTime, TodayEndTime} = get_faction_ybc_time(StartH, StartM),
            NowTime = common_tool:now(),
            if
                NowTime >= TodayStartTime 
                andalso
                NowTime =< TodayEndTime ->
                    %%{activing, {已经持续的时间, 剩余时间}
                    {activing, {NowTime-TodayStartTime, TodayEndTime-NowTime}};
                true ->
                    {not_activing, Data}
            end
    end.

get_default_speed() ->
    IsDebug = common_config:is_debug(),
    if
        IsDebug =:= true ->
            ?YBC_BASE_MOVE_SPEED_DEBUG;
        true ->
            ?YBC_BASE_MOVE_SPEED
    end.

do_cancel_and_notify(Line, RoleID, Unique, YbcID) ->
    mod_map_ybc:del_ybc(YbcID),
    set_doing_person_ybc(RoleID, cancel),
    DataRecord = #m_personybc_cancel_toc{succ=true},
    common_misc:unicast(Line, RoleID, Unique, ?PERSONYBC, ?PERSONYBC_CANCEL, DataRecord).

send_protect_info(FactionID, StartTime) ->
    case FactionID of
        1 ->
            MapIDS = [11102, 11100, 11105];
        2 ->
            MapIDS = [12102, 12100, 12105];
        3 ->
            MapIDS = [13102, 13100, 13105]
    end,

    lists:foreach(fun(MapID) ->
                          common_misc:send_to_map_mod(MapID,
                                                      mod_map_actor,
                                                      {set_map_protected,
                                                       faction_ybc,
                                                       StartTime, 
                                                       FactionID, 
                                                       ?MAP_PROTECT_RC_FACTION_YBC})
                  end, MapIDS).

can_use_ybc_faction_time(FactionID, StartH, StartM, EndH, EndM) ->
    EventData = common_misc:get_event_state({personybc_faction, FactionID}),
    case EventData of
        {false, _} ->
            true;
        {ok, Data} ->
            Config =  Data#r_event_state.data,
            UserTime = Config#faction_ybc_config.new,

            #faction_ybc_time{start_h=YbcFactionStartH, 
                              start_m=YbcFactionStartM,
                              end_h=YbcFactionEndH,
                              end_m=YbcFactionEndM} = UserTime,

            LastTime = ?FACTION_TIME div 60,
            StartCheck = common_misc:check_time_conflict(YbcFactionStartH, 
                                                         YbcFactionStartM, 
                                                         LastTime, 
                                                         StartH, 
                                                         StartM),
            EndCheck = common_misc:check_time_conflict(YbcFactionEndH, 
                                                       YbcFactionEndM, 
                                                       LastTime, 
                                                       EndH, 
                                                       EndM),
            StartCheck =:= ok andalso EndCheck =:= ok
    end.

init_event() ->
    {_, CurrentStartTime1, _} = get_faction_ybc_time(1),
    {_, CurrentStartTime2, _} = get_faction_ybc_time(2),
    {_, CurrentStartTime3, _} = get_faction_ybc_time(3),

    set_event(CurrentStartTime1, 1),
    set_event(CurrentStartTime2, 2),
    set_event(CurrentStartTime3, 3).


set_event(StartTimeTmp, FactionID) ->

    Now = common_tool:now(),
    Minute15Tmp = StartTimeTmp - 15*60,
    Minute5Tmp = StartTimeTmp - 5*60,
    StopTimeTmp = StartTimeTmp + ?FACTION_TIME ,

    if
        Now > StartTimeTmp ->
            StartTime = StartTimeTmp+?DAY_SECONDS;
        true ->
            StartTime = StartTimeTmp
    end,

    if
        Now > Minute15Tmp ->
            Minute15 = Minute15Tmp+?DAY_SECONDS;
        true ->
            Minute15 = Minute15Tmp
    end,

    if
        Now > Minute5Tmp ->
            Minute5 = Minute5Tmp+?DAY_SECONDS;
        true ->
            Minute5 = Minute5Tmp
    end,

    if
        Now > StopTimeTmp ->
            StopTime = StopTimeTmp+?DAY_SECONDS;
        true ->
            StopTime = StopTimeTmp
    end,


    Now = common_tool:now(),
    do_set_event(
      {faction_ybc, FactionID, notice_15minute}, 
      Minute15, 
      FactionID),
    do_set_event(
      {faction_ybc, FactionID, notice_5minute}, 
      Minute5, 
      FactionID),
    do_set_event(
      {faction_ybc, FactionID, notice_start}, 
      StartTime, 
      FactionID),
    do_set_event(
      {faction_ybc, FactionID, notice_stop}, 
      StopTime, 
      FactionID).

do_set_event(Key, StartTime, FactionID) ->
    mgeem_event:set_event(
      Key, 
      StartTime, 
      mod_ybc_person, 
      notice, 
      {Key, StartTime, FactionID}).

notice({Key, _, FactionID}) ->
    {EventData, _, _} = get_faction_ybc_time(FactionID),
    TimeData = EventData#faction_ybc_config.new,
    StartHTmp = TimeData#faction_ybc_time.start_h,
    StartMTmp = TimeData#faction_ybc_time.start_m,
    %%有问题 不同通知时间是不同的
    {true, _, _, _, _, NewStartTime, _} = get_faction_ybc_time(StartHTmp, StartMTmp),
    notice2({Key, NewStartTime+?DAY_SECONDS, FactionID}).

notice2({{_, _, notice_15minute}=Key, NewStartTime, FactionID}) ->
    Minute15 = NewStartTime - 15*60,
    do_set_event(
      Key, 
      Minute15, 
      FactionID),

    ISWarOffFaction = auth_request_faction_4(),
    if
        ISWarOffFaction =:= ok ->
            do_notice(1, FactionID);
        true ->
            ignore
    end;
notice2({{_, _, notice_5minute}=Key, NewStartTime, FactionID}) ->
    Minute5 = NewStartTime - 5*60,
    do_set_event(
      Key, 
      Minute5, 
      FactionID),

    ISWarOffFaction = auth_request_faction_4(),
    if
        ISWarOffFaction =:= ok ->
            do_notice(2, FactionID);
        true ->
            ignore
    end;
notice2({{_, _, notice_start}=Key, NewStartTime, FactionID}) ->
    do_set_event(
      Key, 
      NewStartTime, 
      FactionID),

    ISWarOffFaction = auth_request_faction_4(),
    if
        ISWarOffFaction =:= ok ->
            send_protect_info(FactionID, NewStartTime+5),
            do_notice(3, FactionID);
        true ->
            ignore
    end;
notice2({{_, _, notice_stop}=Key, NewStartTime, FactionID}) ->
    StopTime = NewStartTime + ?FACTION_TIME ,
    do_set_event(
      Key, 
      StopTime, 
      FactionID),

    ISWarOffFaction = auth_request_faction_4(),
    if
        ISWarOffFaction =:= ok ->
            do_notice(4, FactionID);
        true ->
            ignore
    end.

do_notice(Type, FactionID) ->
    DataRecord = #m_personybc_faction_notice_toc{type=Type, last_time=?FACTION_TIME},
    common_misc:chat_broadcast_to_faction(
      FactionID, 
      ?PERSONYBC, 
      ?PERSONYBC_FACTION_NOTICE, 
      DataRecord).
