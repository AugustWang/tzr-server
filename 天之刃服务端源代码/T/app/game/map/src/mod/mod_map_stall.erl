%%%-------------------------------------------------------------------
%%% @author  QingliangCn <qing.liang.cn@gmail.com>
%%% @doc 处理玩家发出的摆摊请求，该模块只能被mgeem_map调用！！
%%%
%%% @end
%%% Created :  1 Jun 2010 by  <qing.liang.cn@gmail.com>
%%%-------------------------------------------------------------------
-module(mod_map_stall).

-include("mgeem.hrl").

%% API
-export([
         handle_info/1
        ]).

%%亲自摆摊模式
-define(STALL_MODE_SELF, 0).
%%托管摆摊模式
-define(STALL_MODE_AUTO, 1).

%%%===================================================================
%%% 一个格子上是否有摊位 get({stall, {TX, TY}} -> p_stall_base_info 有摊位
%%                                             mark 打了标志
%%%===================================================================


%%%===================================================================
%%% API
%%%===================================================================

handle_info({stall_sure, TX, TY, RoleID, RoleName, Name, Mode}) ->
    do_stall_sure(TX, TY, RoleID, RoleName, Name, Mode);
handle_info({stall_cancel, TX, TY}) ->
    do_stall_cancel(TX, TY);
%%RB用于广播给其他玩家
handle_info({stall_finish, TX, TY, RoleID, RoleName, Name, Mode, RB}) ->
    do_stall_finish(TX, TY, RoleID, RoleName, Name, Mode, RB);
handle_info({stall_update, TX, TY, RoleID, RoleName, Mode, Name, OldMode}) ->
    do_stall_update(TX, TY, RoleID, RoleName, Mode, Name, OldMode);
handle_info({Unique, Module, Method, {DataIn, MAPID}, RoleID, PID, Line}) ->
    do_request(Unique, Module, Method, {DataIn, MAPID}, RoleID, PID, Line).

%%目前只有摆摊模式的更新
do_stall_update(TX, TY, RoleID, RoleName, Mode, Name, OldMode) ->
    Pos = #p_pos{tx = TX, ty = TY},
    OldStall = #p_map_stall{role_id = RoleID, role_name = RoleName, stall_name = Name, mode = OldMode, pos = Pos},
    case OldMode of
        ?STALL_MODE_AUTO ->
            Stall2 = OldStall;
        _ ->
            Stall2 = OldStall#p_map_stall{mode = Mode}
    end,
    mgeem_map:remove_slice_stall(TX, TY, OldStall),
    mgeem_map:add_slice_stall(TX, TY, Stall2),
    R = #m_stall_request_toc{return_self=false, stall_info=Stall2},
    mgeem_map:do_broadcast_insence([{role, RoleID}], ?STALL, ?STALL_REQUEST, R, mgeem_map:get_state()).

%%摆摊成功后，将摊位的简介信息写入到进程字典中去
do_stall_sure(TX, TY, RoleID, RoleName, Name, Mode) ->
    %%打上标记，进行广播，加入到某个slice里面去
    put({stall, {TX, TY}}, sure),
    Pos = #p_pos{tx=TX, ty=TY},
    Stall = #p_map_stall{role_id=RoleID, role_name=RoleName, stall_name=Name, mode=Mode, pos=Pos},
    %%需要广播通知
    R = #m_stall_request_toc{return_self=false, stall_info=Stall},
    mgeem_map:do_broadcast_insence([{role, RoleID}], ?STALL, ?STALL_REQUEST, R, mgeem_map:get_state()),
    mgeem_map:add_slice_stall(TX, TY, Stall).


%%清理掉之前打上的标记
do_stall_cancel(TX, TY) ->
    erase({stall, {TX, TY}}).


%%摆摊结束后，应该清理掉摊位信息，将之前的标记也去掉
do_stall_finish(TX, TY, RoleID, RoleName, Name, Mode, RB) ->
    ?DEV("~ts", ["玩家摊位结束"]),
    erase({stall, {TX, TY}}),
    Pos = #p_pos{tx=TX, ty=TY},
    Stall = #p_map_stall{role_id=RoleID, role_name=RoleName, stall_name=Name, mode=Mode, pos=Pos},
    mgeem_map:remove_slice_stall(TX, TY, Stall),
    %RegName = lists:concat([mgeew_role_, RoleID]),
    mgeem_map:do_broadcast_insence_by_txty(TX, TY, ?STALL, ?STALL_FINISH, RB, mgeem_map:get_state()).



%%摆摊请求，因为摆摊需要从地图开始检查，所以消息首先被发送到地图了
%%这里检查几个条件：
%%    1. 银子够不够
%%    2. 当前位置是否允许摆摊
%%    3. 玩家是否正处于战斗状态
%%    4. 周围是否有足够的空间来摆摊
%%    5. 玩家等级是否已经达到30级
do_request(Unique, Module, Method, {DataIn, MAPID}, RoleID, PID, Line) ->
    ?DEBUG("~ts:~w ~w ~w ~w ~w ~w ~w", ["收到玩家摆摊请求", Unique, Module, Method, MAPID, RoleID, PID, Line]),
    %%检查是否该位置能够摆摊，先检查这个是因为进程字典的速度最快，而且大部分不能摆摊的原因都是当前位置不能摆摊
    case mod_map_actor:get_actor_txty_by_id(RoleID, role) of
        undefined ->
            Reason = ?_LANG_STALL_SYSTEM_ERROR,
            do_request_error(Unique, Module, Method, Reason, RoleID, PID, Line);
        {TX, TY} ->
            %%检查能否摆摊，包括检查周围空间
            case check_pos_can_stall(TX, TY) of
                ok ->
                    do_request2(Unique, Module, Method, {DataIn, MAPID, TX, TY}, RoleID, PID, Line);
                {error, Reason} ->
                    do_request_error(Unique, Module, Method, Reason, RoleID, PID, Line)
            end
    end.
do_request2(Unique, Module, Method, {DataIn, MAPID, TX, TY}, RoleID, PID, Line) ->
    %%判断玩家是否已经摆摊了
    case common_misc:is_role_self_stalling(RoleID) orelse common_misc:is_role_auto_stalling(RoleID) of
        false ->
            do_request3(Unique, Module, Method, {DataIn, MAPID, TX, TY}, RoleID, PID, Line);
        true ->
            Reason = ?_LANG_STALL_ALREADY_STALL,
            do_request_error(Unique, Module, Method, Reason, RoleID, PID, Line)
    end.
do_request3(Unique, Module, Method, {DataIn, MAPID, TX, TY}, RoleID, PID, Line) ->
    %%获取当前玩家的信息
    case mod_map_role:get_role_attr(RoleID) of
        {ok, RoleAttr} ->
            %%判断玩家基本条件是否达到摆摊要求
            case check_role_condition(RoleAttr) of
                ok ->
                    do_request4(Unique, Module, Method, {DataIn, MAPID, TX, TY}, RoleID, PID, Line);
                {error, Reason} ->
                    do_request_error(Unique, Module, Method, Reason, RoleID, PID, Line)
            end;
        {error, Reason} ->
            ?ERROR_MSG("~ts: roleid->~w, reason->~w", ["脏读玩家信息失败", RoleID, Reason]),
            Reason2 = ?_LANG_STALL_SYSTEM_ERROR,
            do_request_error(Unique, Module, Method, Reason2, RoleID, PID, Line)
    end.
do_request4(Unique, Module, Method, {DataIn, MAPID, TX, TY}, RoleID, PID, Line) ->
    PName = mod_stall_server:get_stall_process_name_by_mapid(MAPID),
    %%检查对应的交易进程是否已经启动，如果没有启动则启动
    case global:whereis_name(PName) of
        undefined ->
            mod_stall_server:start_stall_server(MAPID),
            do_request4(Unique, Module, Method, {DataIn, MAPID, TX, TY}, RoleID, PID, Line);
        _ ->
            put({stall, TX, TY}, mark),
            global:send(PName, {Unique, Module, Method, {DataIn, TX, TY}, RoleID, PID, Line})
    end.



%%检查玩家的基本属性是否满足摆摊条件:等级、银子、战斗状态
check_role_condition(RoleAttr) ->
    case common_misc:is_role_fighting(RoleAttr#p_role_attr.role_id) of
        false ->
            check_role_condition2(RoleAttr);
        true ->
            {error, ?_LANG_STALL_CANNT_STALL_WHEN_FIGHTING}
    end.
check_role_condition2(RoleAttr) ->
    #p_role_attr{level=Level, silver=Silver, silver_bind=SilverBind} = RoleAttr,
    case Level >= ?STALL_MIN_LEVEL of
        true ->
            case (Silver >= ?STALL_BASE_TAX) orelse (SilverBind >= ?STALL_BASE_TAX) of
                true ->
                    ok;
                false ->
                    {error, ?_LANG_STALL_NOT_ENOUGH_SILVER}
            end;
        false ->
            {error, ?_LANG_STALL_LEVEL_NOT_ENOUGH}
    end.

%%检查当前位置能不能摆摊，包括对摆摊空间的检查
check_pos_can_stall(TX, TY) ->
    case if_pos_can_stall(TX, TY) of
        true ->
            case check_space_around(TX, TY) of
                true ->
                    ok;
                false ->
                    {error, ?_LANG_STALL_AROUND_HAS_STALL}
            end;
        _ ->
            {error, ?_LANG_STALL_CANNOT_STALL}
    end.


%%检查当前点能否摆摊
if_pos_can_stall(TX, TY) ->
    get({can_stall, TX, TY}).

        
%%检查一个点周围是否有空间摆摊
check_space_around(TX, TY) ->
    List = get_around_txty(TX, TY),
    lists:foldl(
      fun({X, Y}, Acc) ->
              case check_point(X, Y) of
                  false ->
                      Acc;
                  true ->
                      false
              end
      end,
      true, List).


%%获得以一个格子为中心的9个格子
get_around_txty(TX, TY) ->
    BeginX = TX - 1,
    EndX = TX + 1,
    BeginY = TY - 1,
    EndY = TY + 1,
    lists:foldl(
      fun(X, Acc) ->
              lists:foldl(
                fun(Y, AccSub) ->
                        [{X, Y} | AccSub]
                end, Acc, lists:seq(BeginY, EndY))
      end, [], lists:seq(BeginX, EndX)).

%%检查某个点是否有摊位或者摊位标志
check_point(X, Y) ->
    case get({stall, {X, Y}}) of
        undefined ->
            false;
        _ ->
            true
    end.

%%处理摆摊请求错误
do_request_error(Unique, Module, Method, Reason, RoleID, _PID, Line) ->
    R = #m_stall_request_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

