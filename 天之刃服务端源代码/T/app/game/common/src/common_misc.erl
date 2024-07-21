
%%%-------------------------------------------------------------------
%%% @author QingliangCn <qing.liang.cn@gmail.com>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created :  9 Jun 2010 by QingliangCn <qing.liang.cn@gmail.com>
%%%-------------------------------------------------------------------
-module(common_misc).

-include("common.hrl").
-include("common_server.hrl").

-export([
         manage_applications/6, 
         start_applications/1, 
         stop_applications/1
        ]).

-export([check_in_special_time/2]).

-export([send_role_silver_change/2,
         send_role_gold_change/2,
         send_role_prestige_change/2
        ]).

-export([
         get_team_proccess_name/1,
         get_home_mapid/2,
         get_level_base_hp/1,
         get_level_base_mp/1,
         get_role_fcm_cofficient/1,
         get_common_map_name/1,
         get_role_detail/1,
         get_home_map_id/1,
         gene_tcp_client_socket_name/1,
         account_process_name/1,
         whereis_name/1,
         register/3,
         unicast/6,
         unicast/5,
         unicast/2,
         broadcast/4,
         broadcast/5,
         broadcast/6,
         broadcast_to_line/4,
         broadcast_include_self/4,
         send_to_rolemap/2,
         send_to_rolemap/3,
         send_to_rolemap_mod/3,
         diff_time/1,
         diff_time/2,
         diff_time/3,
         diff_g_seconds/1,
         get_dirty_rolename/1,
         get_dirty_role_attr/1,
         get_dirty_role_base/1,
         get_dirty_role_pos/1,
         get_dirty_role_fight/1,
         get_dirty_role_ext/1,
         get_dirty_mapid_by_roleid/1,
         get_iso_index_mid_vertex/3,
         send_letter/1,
         get_role_line_by_id/1,
         set_role_line_by_id/2,
         remove_role_line_by_id/1,
         get_max_role_id/0,
         get_stall_name/1,
         tcp_name/3,
         get_map_name/1,
         is_role_online/1,
         get_online_role_ip/1,
         is_role_fighting/1,
         is_role_self_stalling/1,
         is_role_auto_stalling/1,
         is_role_exchanging/1,
         unicast2/5,
         is_abort/1,
         get_roleid/1,
         team_add_role_exp/1,
         team_get_can_pick_goods_role/1,
         team_get_team_member/1,
         new_goods_notify/2,
         del_goods_notify/2,
         update_goods_notify/2,
         get_born_info_by_map/1,
         role_attr_change_notify/3,
         do_calculate_equip_refining_index/1,
         get_dirty_role_state/1,
         if_friend/2,
         if_reach_day_friendly_limited/3,
         get_role_map_process_name/1,
         make_common_monster_process_name/4,
         make_summon_monster_process_name/1,
         make_family_boss_process_name/2,
         make_family_process_name/1,
         get_role_line_process_name/1,
         if_in_self_country/2,
         format_silver/2,
         format_silver/1,
         format_lang/2,
         get_dirty_stall_goods/1,
         get_dirty_bag_goods/1,
         is_role_data_loaded/1,
         get_event_state/1,
         set_event_state/2,
         del_event_state/1,
         get_role_conlogin_reward/1,
         dirty_get_new_counter/1,
         trans_get_new_counter/1,
         
         done_task/2,
         check_distance/6,
         send_to_map/2,
         format_goods_name_colour/2,
         get_equip_ring_and_mount_color/1,
         if_in_neutral_area/1,
         send_to_map_mod/3,
         check_time_conflict/5,
         get_end_time/3,
         get_stall_map_pid/1,
         get_jingcheng_mapid/1
        ]).

-export([update_dict_queue/2]).

-export([
         check_name/1,
         get_roleid_by_accountname/1,
         get_faction_name/1,
         get_faction_color_name/1,
         get_map_faction_id/1,
         add_exp_unicast/2
        ]).

-export([chat_get_role_pname/1,
         chat_join_team_channel/2,
         chat_join_family_channel/2,
         chat_leave_team_channel/2,
         chat_leave_family_channel/2,
         chat_get_world_channel_pname/0,
         chat_get_faction_channel_pname/1,
         chat_get_family_channel_pname/1,
         chat_get_team_channel_pname/1,
         chat_get_world_channel_info/0,
         chat_get_faction_channel_info/1,
         chat_get_family_channel_info/1,
         chat_get_team_channel_info/1,
         
         chat_broadcast_to_world/3,
         chat_broadcast_to_faction/4,
         chat_broadcast_to_family/4,
         chat_broadcast_to_team/4,
         
         chat_broadcast_to_world/4,
         chat_broadcast_to_faction/5,
         chat_broadcast_to_family/5,
         chat_broadcast_to_team/5,
         chat_broadcast_to_role/4,
         chat_cast_role_router/2,
         check_role_chat_ban/1
         ]).


%%@doc 发送银两更新的通知
send_role_silver_change(RoleID,RoleAttr)when is_integer(RoleID)->
    #p_role_attr{silver=Silver,silver_bind=SilverBind,sum_prestige=SumPrestige,cur_prestige=CurPrestige} = RoleAttr,
    ChangeAttList = [#p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE,new_value=SilverBind},
                     #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE,new_value=Silver},
                     #p_role_attr_change{change_type=?ROLE_SUM_PRESTIGE_CHANGE,new_value=SumPrestige},
                     #p_role_attr_change{change_type=?ROLE_CUR_PRESTIGE_CHANGE,new_value=CurPrestige}
                     ],
    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttList).

%%@doc 发送元宝更新的通知
send_role_gold_change(RoleID,RoleAttr)when is_integer(RoleID)->
    #p_role_attr{gold=Gold,gold_bind=GoldBind} = RoleAttr,
    ChangeAttList = [#p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE,new_value=GoldBind},
                     #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE,new_value=Gold}
                    ],
    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttList).
%%@doc 发送声望更新的通知
send_role_prestige_change(RoleID,RoleAttr) when erlang:is_integer(RoleID) ->
    #p_role_attr{sum_prestige=SumPrestige,cur_prestige=CurPrestige} = RoleAttr,
    ChangeAttList = [#p_role_attr_change{change_type=?ROLE_SUM_PRESTIGE_CHANGE,new_value=SumPrestige},
                     #p_role_attr_change{change_type=?ROLE_CUR_PRESTIGE_CHANGE,new_value=CurPrestige}
                    ],
    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttList).
%%加经验接口放在world是很扯淡的事情
%%角色里的加经验代码将会移动到这里 这个接口实现后可认为是事务安全的
add_exp_unicast(RoleID, ExpNum) ->
    send_to_rolemap(RoleID, {mod_map_role, {add_exp, RoleID, ExpNum}}).

get_faction_name(FactionID) ->
    proplists:get_value(FactionID, [{1, ?_LANG_FACTION_1},
                                    {2, ?_LANG_FACTION_2},
                                    {3, ?_LANG_FACTION_3}
                                    ]).
get_faction_color_name(1)->
    ?_LANG_COLOR_FACTION_1;
get_faction_color_name(2)->
    ?_LANG_COLOR_FACTION_2;
get_faction_color_name(3)->
    ?_LANG_COLOR_FACTION_3.


%%检查一个名字是否合法（关键字过滤判断)
check_name(Name) ->
    lists:any(
      fun(P) ->
              case re:run(Name, P) of
                  nomatch ->
                      false;
                  _ ->
                      true
              end
      end, data_filter:name()).



chat_cast_role_router(RoleName_RoleID, RouterData) ->

    RoleProcessName = chat_get_role_pname(RoleName_RoleID),
    case global:whereis_name(RoleProcessName) of
        undefined ->
            {error, not_exists};
        Pid ->
            gen_server:cast(Pid, {router, RouterData}),
            {ok, Pid}
    end.
%% 是否被禁言
%% ok 未被禁言 {error,Reason} 被禁言
check_role_chat_ban(RoleId) ->
    case db:dirty_match_object(?DB_BAN_CHAT_USER,#r_ban_chat_user{role_id=RoleId,_='_'}) of
        []-> ok;
        [Record] -> 
            #r_ban_chat_user{time_end=TimeEnd} = Record,
            Now = common_tool:now(),
            case Now>TimeEnd of
                true->
                    ok;
                false->
                    StrTimeEnd = common_tool:seconds_to_datetime_string(TimeEnd),
                    Msg = common_misc:format_lang(?_LANG_CHAT_ROLE_BANNED_ENDTIME,[StrTimeEnd]),
                    {error,Msg}
            end
    end.

chat_get_role_pname(RoleID) when erlang:is_integer(RoleID) ->
    {ok, RoleBase} = get_dirty_role_base(RoleID),
    lists:concat(["chat_role_",
                  common_tool:to_list(RoleBase#p_role_base.role_name)
                  ]);

chat_get_role_pname(RoleName) when erlang:is_list(RoleName) ->
    lists:concat(["chat_role_", RoleName]);

chat_get_role_pname(RoleName) when erlang:is_binary(RoleName) ->
    lists:concat(["chat_role_", common_tool:to_list(RoleName)]).

chat_get_world_channel_pname() ->
    ?CHANNEL_SIGN_WORLD.
chat_get_world_channel_info() ->
    ChannelSign = chat_get_world_channel_pname(),
    ChannelInfo = #p_channel_info{channel_sign=ChannelSign, 
                                  channel_type=?CHANNEL_TYPE_WORLD, 
                                  channel_name=?_LANG_CHANNEL_WORLD},
    {ChannelSign, ChannelInfo}.

%%聊天广播接口
chat_broadcast_to_world(Module, Method, DataRecord) ->
    ChannelPName = chat_get_world_channel_pname(),
    do_chat_broadcast_to_channel(ChannelPName, 
                                 Module, 
                                 Method, 
                                 DataRecord, 
                                 []).

chat_broadcast_to_world(Module, Method, DataRecord, IgnoreRoleIDList) ->
    ChannelPName = chat_get_world_channel_pname(),
    do_chat_broadcast_to_channel(ChannelPName, 
                                 Module, 
                                 Method, 
                                 DataRecord, 
                                 IgnoreRoleIDList).

chat_get_faction_channel_pname(FactionID) ->
    lists:concat([?CHANNEL_SIGN_FACTION, "_", FactionID]).

chat_get_faction_channel_info(FactionID) ->
    ChannelSign = chat_get_faction_channel_pname(FactionID),
    ChannelInfo = #p_channel_info{channel_sign=ChannelSign, 
                                  channel_type=?CHANNEL_TYPE_FACTION, 
                                  channel_name=?_LANG_CHANNEL_FACTION},
    {ChannelSign, ChannelInfo}.

chat_broadcast_to_faction(FactionID, Module, Method, DataRecord) ->
    ChannelPName = chat_get_faction_channel_pname(FactionID),
    do_chat_broadcast_to_channel(ChannelPName, 
                                 Module, 
                                 Method, 
                                 DataRecord, 
                                 []).

chat_broadcast_to_faction(FactionID, Module, Method, DataRecord, IgnoreRoleIDList) ->
    ChannelPName = chat_get_faction_channel_pname(FactionID),
    do_chat_broadcast_to_channel(ChannelPName, 
                                 Module, 
                                 Method, 
                                 DataRecord, 
                                 IgnoreRoleIDList).

chat_get_family_channel_pname(FamilyID) ->
    lists:concat([?CHANNEL_SIGN_FAMILY, "_", FamilyID]).
chat_get_family_channel_info(FamilyID) ->
    ChannelSign = chat_get_family_channel_pname(FamilyID),
    ChannelInfo = #p_channel_info{channel_sign=ChannelSign, 
                                  channel_type=?CHANNEL_TYPE_FAMILY, 
                                  channel_name=?_LANG_CHANNEL_FAMILY},
    {ChannelSign, ChannelInfo}.

chat_broadcast_to_family(FamilyID, Module, Method, DataRecord) ->
    ChannelPName = chat_get_family_channel_pname(FamilyID),
    do_chat_broadcast_to_channel(ChannelPName, 
                                 Module, 
                                 Method, 
                                 DataRecord, 
                                 []).

chat_broadcast_to_family(FamilyID, Module, Method, DataRecord, IgnoreRoleIDList) ->
    ChannelPName = chat_get_family_channel_pname(FamilyID),
    do_chat_broadcast_to_channel(ChannelPName, 
                                 Module, 
                                 Method, 
                                 DataRecord, 
                                 IgnoreRoleIDList).

chat_get_team_channel_pname(TeamID) ->
    lists:concat([?CHANNEL_SIGN_TEAM, "_", TeamID]).
chat_get_team_channel_info(TeamID) ->
    ChannelSign = chat_get_team_channel_pname(TeamID),
    ChannelInfo = #p_channel_info{channel_sign=ChannelSign, 
                                  channel_type=?CHANNEL_TYPE_TEAM, 
                                  channel_name=?_LANG_CHANNEL_TEAM},
    {ChannelSign, ChannelInfo}.

chat_broadcast_to_team(TeamID, Module, Method, DataRecord) ->
    ChannelPName = chat_get_team_channel_pname(TeamID),
    do_chat_broadcast_to_channel(ChannelPName, 
                                 Module, 
                                 Method, 
                                 DataRecord, 
                                 []).

chat_broadcast_to_team(TeamID, Module, Method, DataRecord, IgnoreRoleIDList) ->
    ChannelPName = chat_get_team_channel_pname(TeamID),
    do_chat_broadcast_to_channel(ChannelPName, 
                                 Module, 
                                 Method, 
                                 DataRecord, 
                                 IgnoreRoleIDList).

chat_join_team_channel(RoleName, TeamID) ->
    RoleChatPName = chat_get_role_pname(RoleName),
    gen_server:cast({global, RoleChatPName}, 
                    {router, {join_channel, team, TeamID}}).

chat_leave_team_channel(RoleName, TeamID) ->
    RoleChatPName = chat_get_role_pname(RoleName),
    gen_server:cast({global, RoleChatPName}, 
                    {router, {leave_channel, team, TeamID}}).

chat_join_family_channel(RoleName, FamilyID) ->
    RoleChatPName = chat_get_role_pname(RoleName),
    gen_server:cast({global, RoleChatPName}, 
                    {router, {join_channel, family, FamilyID}}).

chat_leave_family_channel(RoleName, FamilyID) ->
    RoleChatPName = chat_get_role_pname(RoleName),
    gen_server:cast({global, RoleChatPName}, 
                    {router, {leave_channel, family, FamilyID}}).

do_chat_broadcast_to_channel(ChannelPName, 
                             Module, 
                             Method, 
                             DataRecord, 
                             IgnoreRoleIDList) ->
    gen_server:cast({global, ChannelPName}, 
                    {broadcast, Module, Method, DataRecord, IgnoreRoleIDList}).

chat_broadcast_to_role(RoleID, Module, Method, DataRecord) ->
    chat_cast_role_router(RoleID, {broadcast_msg, Module, Method, DataRecord}).

get_born_info_by_map(MapID) ->
    case common_config_dyn:find(born_point,MapID) of
        [#r_born_point{tx=TX, ty=TY}] ->
            {MapID, TX, TY};
        _ ->
            error
    end.

manage_applications(Iterate, Do, Undo, SkipError, ErrorTag, Apps) ->
    Iterate(fun (App, Acc) ->
                    case Do(App) of
                        ok -> [App | Acc];
                        {error, {SkipError, _}} -> Acc;
                        {error, Reason} ->
                            lists:foreach(Undo, Acc),
                            throw({error, {ErrorTag, App, Reason}})
                    end
            end, [], Apps),
    ok.

start_applications(Apps) ->
    manage_applications(fun lists:foldl/3,
                        fun application:start/1,
                        fun application:stop/1,
                        already_started,
                        cannot_start_application,
                        Apps).

stop_applications(Apps) ->
    manage_applications(fun lists:foldr/3,
                        fun application:stop/1,
                        fun application:start/1,
                        not_started,
                        cannot_stop_application,
                        Apps).

tcp_name(Prefix, IPAddress, Port)
  when is_atom(Prefix) andalso is_number(Port) ->
    list_to_atom(
      lists:flatten(
        io_lib:format("~w_~s:~w",
                      [Prefix, inet_parse:ntoa(IPAddress), Port]))).


%% get the pid of a registered name
whereis_name({local, Atom}) -> 
    erlang:whereis(Atom);

whereis_name({global, Atom}) ->
    global:whereis_name(Atom).

register(local, Name, Pid) ->
    erlang:register(Name, Pid);
register(global, Name, Pid) ->
    global:register_name(Name, Pid).


gene_tcp_client_socket_name(LSock) ->
    io_lib:format("mgee_tcp_client_~w", [LSock]).


%%--------------------------------------------------------------------------------------
%% 处理玩家所在分线信息
%%--------------------------------------------------------------------------------------
get_role_line_process_name(AccountName) ->
    common_tool:list_to_atom(lists:append(["mgeeg_account_", common_tool:to_list(AccountName)])).
%%获得玩家分线 
get_role_line_by_id(RoleID) ->
    common_role_line_map:get_role_line(RoleID).
%%设置玩家分线
set_role_line_by_id(RoleID, Line) ->
    common_role_line_map ! {set, RoleID, Line}.
%%移除玩家分线
remove_role_line_by_id(RoleID) ->
    common_role_line_map ! {remove, RoleID}.

unicast2(PID, Unique, Module, Method, R) ->
    case Module =:= ?FIGHT andalso Method =:= ?FIGHT_ATTACK of
        true ->
            ?ERROR_MSG("~ts,Unique=~w, R=~w", ["战斗调试信息", Unique, R]);
        _ ->
            ignore
    end,
    case erlang:get({pid_to_roleid, PID}) of
        undefined ->
            PID ! {message, Unique, Module, Method, R};
        _ ->
            Binary = mgeeg_packet:packet_encode(Unique, Module, Method, R),
            mgeem_map:update_role_msg_queue(PID, Binary),
            ok
    end.
    

unicast(Line, RoleID, Unique, Module, Method, DataRecord) 
  when is_integer(RoleID) ->
    case erlang:get({roleid_to_pid, RoleID}) of
        undefined ->
            Name = lists:concat(["unicast_server_", Line]),
            catch global:send(Name, {message, RoleID, Unique, Module, Method, DataRecord});
        PID ->
            Binary = mgeeg_packet:packet_encode(Unique, Module, Method, DataRecord),
            mgeem_map:update_role_msg_queue(PID, Binary)
    end,
    ok;
unicast(_, _, _, _, _, _) ->
    ok.

unicast({role, RoleID}, Unique, Module, Method, DataRecord) when is_integer(RoleID) ->
    case erlang:get({roleid_to_pid, RoleID}) of
        undefined ->
            case common_misc:get_role_line_by_id(RoleID) of
                false ->
                    broadcast([RoleID], Unique, Module, Method, DataRecord),
                    ignore;
                Line  ->
                    Name = lists:concat(["unicast_server_", Line]),
                    catch global:send(Name, {message, RoleID, Unique, Module, Method, DataRecord})
            end;
        PID ->
            Binary = mgeeg_packet:packet_encode(Unique, Module, Method, DataRecord),
            mgeem_map:update_role_msg_queue(PID, Binary)
    end.

%% Todo 需要兼容world/login
unicast(RoleID, Binary) when erlang:is_integer(RoleID) andalso erlang:is_binary(Binary) ->
    case erlang:get({roleid_to_pid, RoleID}) of
        undefined ->
            ?ERROR_MSG("~ts:~p", ["地图中没有找到对应的玩家", RoleID]),
            ok;
        PID ->
            mgeem_map:update_role_msg_queue(PID, Binary)
    end;
unicast(PID, Binary) when erlang:is_pid(PID) andalso erlang:is_binary(Binary) ->
    mgeem_map:update_role_msg_queue(PID, Binary);
unicast(Line, UnicastList) when is_list(UnicastList) andalso erlang:length(UnicastList) > 0 ->
    case erlang:get(is_map_process) of
        undefined ->
            Name = lists:concat(["unicast_server_", Line]),
            case global:whereis_name(Name) of
                undefined ->
                    ignore;
                PID ->
                    PID ! {send_multi, UnicastList}
            end;
        _ ->
            [begin                 
                 case erlang:get({roleid_to_pid, RoleID}) of
                     undefined ->
                         unicast({role, RoleID}, Unique, Module, Method, DataRecord);
                     PID ->
                         Binary = mgeeg_packet:packet_encode(Unique, Module, Method, DataRecord),
                         mgeem_map:update_role_msg_queue(PID, Binary)
                 end
             end || #r_unicast{roleid = RoleID, module = Module, unique = Unique, method = Method, record = DataRecord} <- UnicastList],
            ok
    end;
unicast(_, _) ->
    ignore.


broadcast_to_line(RoleIDlist, Module, Method, DataRecord)
  when is_list(RoleIDlist) andalso is_integer(Module) andalso is_integer(Method) ->
    case erlang:length(RoleIDlist) > 0 of 
        true ->
            Lines = common_role_line_map:get_lines(),
            %%?ERROR_MSG("~w", [Lines]),
            lists:foreach(
              fun(Line) ->
                      Name=lists:concat(["unicast_server_", Line]),
                      case global:whereis_name(Name) of
                          undefined ->
                              ?ERROR_MSG("~ts ~w", ["分线的unicast进程down了", Line]),
                              ignore;
                          PID ->
                              PID ! {send, RoleIDlist, ?DEFAULT_UNIQUE, Module, Method, DataRecord}
                      end
              end, Lines
             );
        false ->
            ignore
    end.

%%向各个分线广播，带有优先级的
broadcast(RoleIDListPrior, RoleIDList2, _Unique, _Module, _Method, _DataRecord)
  when erlang:length(RoleIDListPrior) =:= 0 andalso erlang:length(RoleIDList2) =:= 0 ->
    ignore;
broadcast(RoleIDListPrior, RoleIDList2, Unique, Module, Method, DataRecord)
  when is_list(RoleIDListPrior) andalso is_integer(Module) andalso is_integer(Method) ->
    Lines = common_role_line_map:get_lines(),
    lists:foreach(
      fun(Line) ->
              Name = lists:concat(["unicast_server_", Line]),
              case global:whereis_name(Name) of
                  undefined ->
                      ?ERROR_MSG("unicast server on line ~p is down", [Line]),
                      ignore;
                  PID ->
                      PID ! {send, RoleIDListPrior, RoleIDList2, Unique, Module, Method, DataRecord}
              end
      end, Lines).


broadcast(RoleIDList, _Unique, _Module, _Method, _DataRecord)
  when erlang:length(RoleIDList) =:= 0 ->
    ignore;
broadcast(RoleIDList, Unique, Module, Method, DataRecord)
  when is_list(RoleIDList) andalso is_integer(Module) andalso is_integer(Method) ->
    Lines = common_role_line_map:get_lines(),
    lists:foreach(
      fun(Line) ->
              Name = lists:concat(["unicast_server_", Line]),
              case global:whereis_name(Name) of
                  undefined ->
                      ?ERROR_MSG("unicast server on line ~p is down", [Line]),
                      ignore;
                  PID ->
                      PID ! {send, RoleIDList, Unique, Module, Method, DataRecord}
              end
      end, Lines).


%%通过地图服务器广播信息
broadcast(RoleID, Module, Method, DataRecord) 
  when is_integer(RoleID) andalso is_integer(Module) andalso is_integer(Method)  ->
    ?DEBUG("broadcast to round roles,Module = ~p,Method = ~p , Data = ~p",
           [Module, Method, DataRecord]),
    case get_role_map_process_name(RoleID) of
        {ok, MapName} ->
            case global:whereis_name(MapName) of
                undefined ->
                    ?ERROR_MSG("map ~p not started !!!", [MapName]),
                    ignore;
                PID ->
                    PID ! {broadcast_in_sence, [RoleID], Module, Method, DataRecord}
            end,
            ok;
        {error, Reason} ->
            ?ERROR_MSG("broadcast error :~p role:[~p] module:~p method:~p", 
                       [Reason, RoleID, Module, Method]),
            ignore
    end.


broadcast_include_self(RoleID, Module, Method, DataRecord) 
  when is_integer(RoleID) andalso is_integer(Module) andalso is_integer(Method) ->
    ?DEBUG("broadcast to round roles,Module = ~p,Method = ~p , Data = ~p",
           [Module, Method, DataRecord]),
    case get_role_map_process_name(RoleID) of
        {ok, MapName} ->
            case global:whereis_name(MapName) of
                undefined ->
                    ?ERROR_MSG("map ~p not started !!!", [MapName]),
                    ignore;
                PID ->
                    PID ! {broadcast_in_sence_include, [RoleID], Module, Method, DataRecord}
            end,
            ok;
        {error, Reason} ->
            ?ERROR_MSG("broadcast error :~p role:[~p] module:~p method:~p", 
                       [Reason, RoleID, Module, Method]),
            ignore
    end.


%% don't care about chinese, it performance well.
account_process_name(AccountName) when is_integer(AccountName) or is_atom(AccountName) ->
    common_tool:list_to_atom(
      lists:concat([mgeew_account_, AccountName]));
account_process_name(AccountName) when is_list(AccountName) ->
    common_tool:list_to_atom(
      lists:flatten(["mgeew_account_"|AccountName]));
account_process_name(AccountName) when is_binary(AccountName) ->
    common_tool:list_to_atom(
      lists:concat([mgeew_account_, binary_to_list(AccountName)])).


get_map_name(MAPID) ->
    lists:concat([mgee_map_, MAPID]).

diff_time(0) ->
    0;
diff_time(Time) when is_integer(Time) ->
    common_tool:now() - Time;
diff_time(Time) ->
    diff_time(erlang:now(), Time).

diff_time(Time1, Time2) ->
    diff_time(Time1, Time2, 1000000).

diff_time(Time1, Time2, TimeChange) ->
    TimeDiff = timer:now_diff(Time1, Time2),
    erlang:round(TimeDiff/TimeChange).

diff_g_seconds(Seconds) ->
    LocalTime = calendar:local_time(),
    GSeconds = calendar:datetime_to_gregorian_seconds(LocalTime),
    GSeconds - Seconds.


get_role_map_process_name(RoleID) ->
    case db:dirty_read(?DB_ROLE_POS, RoleID) of
        [] ->
            {error, role_map_process_name_not_found};
        [#p_role_pos{map_process_name=MapProcessName}] ->
            {ok, MapProcessName}
    end.

%% 有时一些消息 是在玩家下线后收到的 依然要被处理 那么使用该方法 会始终发送数据到地图
send_to_rolemap(strict, RoleID, Msg) ->
    case get_role_map_process_name(RoleID) of
        {ok, MapName} ->
            case global:whereis_name(MapName) of
                undefined ->
                    ?ERROR_MSG("~ts:~w !!!", ["地图进程没有找到", MapName]),
                    ignore;
                PID ->
                    PID ! Msg
            end,
            ok;
        {error, role_map_process_name_not_found} ->
            ?DEBUG("~ts:~w", ["玩家地图信息不存在，将直接发送到mgeem_router", RoleID]),
            global:send(mgeem_router, {role_offline_msg, RoleID, Msg});
        {error, _Reason} ->
            ignore
    end.

%% 发送消息到用户的地图进程
send_to_rolemap(RoleID, Msg) when is_integer(RoleID) ->
    case erlang:get({?role_base, RoleID}) of
        undefined ->
            send_to_rolemap2(RoleID, Msg);
        _ ->
            self() ! Msg
    end.

send_to_rolemap2(RoleID, Msg) when is_integer(RoleID) ->
    case db:dirty_read(db_role_base, RoleID) of
        [] ->
            ?ERROR_MSG("~ts:~p, ~w", ["不存在的用户", RoleID, erlang:get_stacktrace()]),
            ignore;
        [#p_role_base{account_name=AccountName}] ->
            RegName = common_misc:get_role_line_process_name(AccountName),
            case global:whereis_name(RegName) of
                undefined ->
                    case Msg of
                        {mod_map_role,{remove_buff,_MsgParamA,_MsgParamB,_MsgParamC,[?FRIEND_BUFF_TYPE,?EDUCATE_BUFFTYPE1,?EDUCATE_BUFFTYPE2]}} ->
                            ignore;
                        _ ->
                            ?ERROR_MSG("~ts:~p ~w", ["玩家网关进程不存在", AccountName, Msg])
                    end,
                    ignore;
                PID ->
                    PID ! {router_to_map, Msg}
            end
    end.

send_to_map_mod(MapID,Mod,Msg) ->
    send_to_map(MapID, {mod,Mod,Msg}).

%%@doc 将消息发给玩家所在地图进程，并有指定的模块去处理
send_to_rolemap_mod(RoleID,Mod,Msg) when is_integer(RoleID) ->
    send_to_rolemap(RoleID, {mod,Mod,Msg}).

send_to_map(MapID, Info) ->
    MapName = get_map_name(MapID),
    case global:whereis_name(MapName) of
        undefined ->
            ?ERROR_MSG("~ts:~w !!!", ["地图进程没有找到", MapName]),
            {false, map_process_not_found};
        PID ->
            PID ! Info,
            ok
    end.

get_dirty_rolename(RoleID)->
    case get_dirty_role_base(RoleID) of
        {ok, #p_role_base{role_name=RoleName}} -> 
            RoleName;
        _ -> 
            ""
    end.

get_dirty_role_attr(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_ATTR, RoleID) of
        {'EXIT', Reason} ->
            ?ERROR_MSG("mnesia dirty read exit:~p", [Reason]),
            {error, system_error};
        [] ->
            ?INFO_MSG("role attr not found ~p", [RoleID]),
            {error, not_found};
        [RoleAttr] ->
            {ok, RoleAttr}
    end.


get_dirty_role_base(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_BASE, RoleID) of
        {'EXIT', Reason} ->
            ?ERROR_MSG("mnesia dirty read exit:~p", [Reason]),
            {error, system_error};
        [] ->
            ?INFO_MSG("role attr not found ~p", [RoleID]),
            {error, not_found};
        [RoleBase] ->
            {ok, RoleBase}
    end.
%% 脏读获取玩家当前位置信息
get_dirty_role_pos(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_POS, RoleID) of
        {'EXIT', Reason} ->
            ?ERROR_MSG("mnesia dirty read exit:~p", [Reason]),
            {error, system_error};
        [] ->
            ?INFO_MSG("role attr pos not found ~p", [RoleID]),
            {error, not_found};
        [RolePos] ->
            {ok, RolePos}
    end.
%% 脏读获取玩家当前战斗信息
get_dirty_role_fight(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_FIGHT, RoleID) of
        {'EXIT', Reason} ->
            ?ERROR_MSG("mnesia dirty read exit:~p", [Reason]),
            {error, system_error};
        [] ->
            ?INFO_MSG("role attr fight not found ~p", [RoleID]),
            {error, not_found};
        [RoleFight] ->
            {ok, RoleFight}
    end.
%% 脏读获取玩家当前额外属性
get_dirty_role_ext(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_EXT, RoleID) of
        {'EXIT', Reason} ->
            ?ERROR_MSG("mnesia dirty read exit:~p", [Reason]),
            {error, system_error};
        [] ->
            ?INFO_MSG("role attr ext not found ~p", [RoleID]),
            {error, not_found};
        [RoleExt] ->
            {ok, RoleExt}
    end.
%%脏读获取玩家当前的地图信息
get_dirty_mapid_by_roleid(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_POS, RoleID) of
        {'EXIT', Reason} ->
            ?ERROR_MSG("mnesia dirty read exit:~p", [Reason]),
            {error, system_error};
        [] ->
            ?INFO_MSG("role pos not found ~p", [RoleID]),
            {error, not_found};
        [RolePos] ->
            {ok, RolePos#p_role_pos.map_id}
    end.

%%获取最大的玩家id
get_max_role_id() ->
   case  db:transaction( 
           fun() ->
                    db:read(?DB_ROLEID_COUNTER, 1)
           end)
   of
       {aborted, Reason} -> 
           ?ERROR_MSG("~ts:~p",["Mnesia 读取失败", Reason]),
           {error, system_error};
       {atomic, []} ->
           ?ERROR_MSG("~ts",["没有找到最大玩家id"]),
           {error, not_found};
       {atomic, [#r_roleid_counter{last_role_id=N}]} ->
           {ok, N}
   end.

check_distance(TX, TY, TTX, TTY, MaxX, MaxY) ->
    {PX, PY} = common_misc:get_iso_index_mid_vertex(TX, 0, TY),
    {TPX, TPY} = common_misc:get_iso_index_mid_vertex(TTX, 0, TTY),
    erlang:abs(PX - TPX) < MaxX andalso erlang:abs(PY - TPY) < MaxY.
    

-spec(index2flat(X :: integer(), Y :: integer(), Z :: integer()) -> tuple()).
index2flat(X, Y, Z) ->
    X2 = X - Z,
    Y2 = Y * ?CORRECT_VALUE + (X + Z) * 0.5,
    {X2 * ?TILE_SIZE, Y2 * ?TILE_SIZE}.

-spec(get_iso_index_mid_vertex(X :: integer(), Y :: integer(), Z :: integer()) -> tuple()).
get_iso_index_mid_vertex(X, Y, Z) ->
    {X2, Y2} = index2flat(X, Y, Z),
    Y3 = round(Y2 + ?TILE_SIZE / 2),
    {X2, Y3}.


%%发送信件
send_letter({ok}) ->
    ok.

get_stall_name(MAPID) ->
    lists:concat(["stall_server_", MAPID]).


%%判断角色是否在线
is_role_online(RoleID) ->
    case db:dirty_read(?DB_USER_ONLINE, RoleID) of
        [] ->
            false;
        _ ->
            true
    end.

%%获取在线玩家的登录IP
%%@return tuple() eg: {127.0.0.1}
get_online_role_ip(RoleID) when is_integer(RoleID)->
    case db:dirty_read(?DB_USER_ONLINE, RoleID) of
        [Record] ->
            Record#r_role_online.login_ip;
        _->
            undefined
    end.

is_role_data_loaded(RoleID) ->
    case db:dirty_read(?DB_USER_DATA_LOAD_MAP_P, RoleID) of
        [] ->
            false;
        _ ->
            true
    end.


%%是否玩家处于战斗状态
is_role_fighting(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_STATE, RoleID) of
        {'EXIT', Detail} ->
            ?ERROR_MSG("~ts:~p -> ~w", ["脏读玩家状态信息出错", RoleID, Detail]),
            false;
        [#r_role_state{fight=Fight}] ->
            Fight =:= true;
        [] ->
            false
    end.

%%是否玩家处于亲自摆摊中
is_role_self_stalling(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_STATE, RoleID) of
        {'EXIT', Detail} ->
            ?ERROR_MSG("~ts:~p -> ~w", ["脏读玩家状态信息出错", RoleID, Detail]),
            false;
        [#r_role_state{stall_self=StallSelf}] ->
            StallSelf =:= true;
        [] ->
            false
    end.

%%是否玩家处于托管摆摊中
is_role_auto_stalling(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_STATE, RoleID) of
        {'EXIT', Detail} ->
            ?ERROR_MSG("~ts:~p -> ~w", ["脏读玩家状态信息出错", RoleID, Detail]),
            false;
        [#r_role_state{stall_auto=StallAuto}] ->
            StallAuto =:= true;
        [] ->
            false
    end.

%%是否玩家正处于交易状态
is_role_exchanging(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_STATE, RoleID) of
        {'EXIT', Detail} ->
            ?ERROR_MSG("~ts:~p -> ~w", ["脏读玩家状态信息出错", RoleID, Detail]),
            false;
        [#r_role_state{exchange=Exchange}] ->
            Exchange =:= true;
        [] ->
            false
    end.

is_abort(Fun) when is_function(Fun) ->
    case Fun() of
    {aborted, _} ->
        true;
    _ ->
        false
    end;
is_abort(Tuple) when is_tuple(Tuple) ->
    case Tuple of
    {aborted, _} ->
        true;
    _ ->
        false
    end.

-spec(get_roleid(string()|binary())-> integer()).
get_roleid(Name) when is_list(Name) ->
    BinName = list_to_binary(Name),
    get_roleid(BinName);
get_roleid(Name) when is_binary(Name) ->
    case db:dirty_read(?DB_ROLE_NAME, Name) of
        [#r_role_name{role_id=RoleID}] ->
            RoleID;
        _ ->
            0
    end.

-spec(get_roleid_by_accountname(string()|binary())-> integer()).
get_roleid_by_accountname(Name) when is_list(Name) ->
    BinName = list_to_binary(Name),
    get_roleid_by_accountname(BinName);
get_roleid_by_accountname(Name) when is_binary(Name) ->
    Pattern = #p_role_base{_ = '_',account_name= Name,_ = '_'},
    ?DEBUG("~nName:~p Pattern:~p~n",[Name,Pattern]),
    case catch (db:dirty_match_object(?DB_ROLE_BASE,Pattern)) of
    [R] -> R#p_role_base.role_id;
    Other -> ?DEBUG("~nOther:~p~n",[Other]),0
    end.    

%% 队伍经验接口
%% MonsterExpList 结构为 [r_monster_exp,r_monster_exp,]
%% id,唯一标记，killer_id 杀死怪物的RoleId, map_id 地图id monster_id  怪物id, ,monster_type 怪物类型 
%% monster_tx,monster_ty 怪物死亡坐标，role_exp_list 获取得经验的玩家记录类型r_monster_role_exp
%% team_exp_list  队伍经验记录r_monster_team_exp
%% -record(r_monster_exp,{id,killer_id,map_id,monster_id,monster_type,monster_tx,monster_ty,role_exp_list,team_exp_list}).
%% 怪物经验玩家经验记录
%% -record(r_monster_role_exp,{role_id,exp}).
%% 队伍经验记录,team_sub_list 队伍成员经验记录列表r_monster_team_sub_exp
%% -record(r_monster_team_exp,{team_id,team_sub_list}).
%% role_id 角色id,exp 角色所得经验
%% -record(r_monster_team_sub_exp,{role_id, exp, team_id, team_exp, level,kill_flag,status}).
team_add_role_exp(MonsterExpList) ->
    catch global:send("mod_team_exp_server",{add_role_exp, MonsterExpList}).
%% 此接口只能在地图进程使用
%% 获取当前什么玩家可以拾取怪物掉落的物品
%% 返回的结果为一个玩家ID列表 [RoleId,RoleId2,RoleId3,...]
team_get_can_pick_goods_role(RoleId) ->
    case mod_map_role:get_role_base(RoleId) of
        {ok,RoleBase} ->
            case RoleBase#p_role_base.team_id =/= 0 of
                true ->
                    team_get_can_pick_goods_role2(RoleId);
                _ ->
                    [RoleId]
            end;
        _ ->
            [RoleId]
    end. 
team_get_can_pick_goods_role2(RoleId) ->
    case mod_map_team:get_role_team_info(RoleId) of
        {ok,MapTeamInfo} ->
            case MapTeamInfo#r_role_team.team_id =/= 0
                                             andalso erlang:length(MapTeamInfo#r_role_team.role_list) > 0
                                             andalso MapTeamInfo#r_role_team.pick_type =:= 1 of
                true ->
                    [TeamRoleInfo#p_team_role.role_id || TeamRoleInfo <- MapTeamInfo#r_role_team.role_list];
                _ ->
                    [RoleId]
            end;
        _ ->
            [RoleId]
    end.
%% 此接口只能在地图进程使用
%% 根据角色id获取当前角色的队伍的队伍成员
%% 如果没有队伍即返回[]
%% 结构为 [RoleId, RoleId2, ...]
team_get_team_member(RoleId) ->
    case mod_map_role:get_role_base(RoleId) of
        {ok,RoleBase} ->
            case RoleBase#p_role_base.team_id =/= 0 of
                true ->
                    team_get_team_member2(RoleId);
                _ ->
                    []
            end;
        _ ->
            []
    end. 
team_get_team_member2(RoleId) ->
    case mod_map_team:get_role_team_info(RoleId) of
        {ok,MapTeamInfo} ->
            case MapTeamInfo#r_role_team.team_id =/= 0
                                             andalso erlang:length(MapTeamInfo#r_role_team.role_list) > 0 of
                true ->
                    [TeamRoleInfo#p_team_role.role_id || TeamRoleInfo <- MapTeamInfo#r_role_team.role_list];
                _ ->
                    []
            end;
        _ ->
            []
    end.
%% UnicastArg 可以是下面几种情况
%% {role, RoleId}
%% {line, Line, RoleId}
%% {socket, Line, Socket}
del_goods_notify(UnicastArg, GoodsData) ->
     GoodsList = 
        case GoodsData of
            GoodsData when is_record(GoodsData, p_goods) ->
                [GoodsData];
            GoodsData when is_list(GoodsData) ->
                GoodsData;
            _Other ->
                []
        end,
    NewGoodsList = [R#p_goods{current_num = 0} || R<-GoodsList],
    do_goods_notify(UnicastArg, NewGoodsList),
    ok.

%% UnicastArg 可以是下面几种情况
%% {role, RoleId}
%% {line, Line, RoleId}
%% {socket, Line, Socket}
new_goods_notify(UnicastArg, GoodsData) ->
    update_goods_notify(UnicastArg, GoodsData).


%% UnicastArg 可以是下面几种情况
%% {role, RoleId}
%% {line, Line, RoleId}
%% {socket, Line, Socket}
update_goods_notify(UnicastArg, GoodsData) ->
    GoodsList = 
        case GoodsData of
            GoodsData when is_record(GoodsData, p_goods) ->
                [GoodsData];
            GoodsData when is_list(GoodsData) ->
                GoodsData;
            _Other ->
                []
        end,

    do_goods_notify(UnicastArg, GoodsList),
    ok.


%% UnicastArg 可以是下面几种情况
%% {role, RoleId}
%% {line, Line, RoleId}
%% {socket, Line, Socket}
do_goods_notify(UnicastArg, GoodsList) ->
    DataRecord = #m_goods_update_toc{goods = GoodsList},
    case UnicastArg of
        PID when erlang:is_pid(PID) ->
            unicast2(PID, ?DEFAULT_UNIQUE, ?GOODS, ?GOODS_UPDATE, DataRecord);
        {role, RoleId} ->
            unicast({role, RoleId}, ?DEFAULT_UNIQUE, ?GOODS, ?GOODS_UPDATE, DataRecord);
        {line, Line, RoleId} ->
            unicast(Line, RoleId, ?DEFAULT_UNIQUE, ?GOODS, ?GOODS_UPDATE, DataRecord);
        {socket, Line, Socket} ->
            unicast(Line, Socket, ?DEFAULT_UNIQUE, ?GOODS, ?GOODS_UPDATE, DataRecord)
    end.


%% 角色属性变化通知接口
%% UnicastArg 可以是下面几种情况
%% {role, RoleId}
%% {line, Line, RoleId}
%% {socket, Line, Socket}
%% {pid, PID}
role_attr_change_notify(UnicastArg, RoleId, ChangeAttList) ->
    DataRecord = #m_role2_attr_change_toc{roleid = RoleId, changes = ChangeAttList},
    case UnicastArg of
        {role, RoleId} ->
            unicast({role, RoleId}, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord);
        {line, Line, RoleId} ->
            unicast(Line, RoleId, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord);
        {socket, Line, Socket} ->
            unicast(Line, Socket, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord);
        {pid, PID} ->
            unicast2(PID, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord)
    end.

%%@doc 获取指定玩家的摆摊物品
get_dirty_stall_goods(RoleID) ->
    Pattern = #r_stall_goods{role_id = RoleID, _ = '_'},
    case catch db:dirty_match_object(?DB_STALL_GOODS, Pattern) of
        StallRecList when is_list(StallRecList) ->
            GoodsList = [ Goods ||#r_stall_goods{goods_detail=Goods}<-StallRecList],
            {ok, GoodsList};
        _ ->
            {error, ?_LANG_SYSTEM_ERROR}
    end.

%% 计算装备的精炼系数
%% 1攻击   = 10分 （取最小攻）
%% 1防御   = 10分 （取最小防）
%% 1生命值 = 0.6分
%% 1力量   = 11.2分
%% 1智力   = 13分
%% 1身法   = 25分
%% 1精神   = 3分
%% 1体质   = 15分
%% 新的 精炼系数 公式  = 攻击 + 防御 + 生命值 + 力量 + 智力 + 身法 + 精神 + 体质
%% 输入参数 p_goods
%% 返回结果 {ok,NewEquipGoods}
%%         {error,ErrorCode}
%% ErrorCode = {1,不是装备}
do_calculate_equip_refining_index(EquipGoods) ->
    case EquipGoods#p_goods.type =:= ?TYPE_EQUIP of
        true ->
            #p_property_add{min_physic_att = MinPhysicAtt, %% 最小物攻
                            max_physic_att = MaxPhysicAtt, %% 最大物攻
                            min_magic_att = MinMagicAtt, %% 最小魔攻
                            max_magic_att = MaxMagicAtt, %% 最大魔攻
                            physic_def = PhysicDef, %% 物防
                            magic_def = MagicDef, %% 魔防
                            blood = Blood, %% 生命值
                            power = Power, %% 力量
                            agile = Agile, %% 敏捷
                            brain = Brain, %% 智力
                            vitality = Vitality, %% 体质        
                            spirit = Spirit %% 精神
                           } = EquipGoods#p_goods.add_property,
            case MaxPhysicAtt >= MaxMagicAtt of
                true ->
                    MinAtt = MinPhysicAtt, MaxAtt = MaxPhysicAtt;
                _ ->
                    MinAtt = MinMagicAtt, MaxAtt = MaxMagicAtt
            end,
            RefiningIndex = (MinAtt + MaxAtt) * 10 / 2 + PhysicDef * 10 + MagicDef * 10 + Blood * 0.6 + 
                                Power * 11.2 + Agile * 25 + Spirit * 3 + Vitality * 15 + Brain * 13,
            common_tool:ceil(RefiningIndex),
            {ok,EquipGoods#p_goods{refining_index = common_tool:ceil(RefiningIndex)}};
        _ ->
            {error,1}
    end.

get_dirty_role_state(RoleID) ->
    case catch db:dirty_read(?DB_ROLE_STATE, RoleID) of
        {'EXIT', R} ->
            ?DEBUG("get_dirty_role_state, r: ~w", [R]),
            {error, ?_LANG_SYSTEM_ERROR};
        [] ->
            {error, ?_LANG_SYSTEM_ERROR};
        [RoleState] ->
            {ok, RoleState}
    end.                           
        
    
    


get_home_map_id(FactionID) ->
    10000 + FactionID * 1000 + 100.

if_friend(RoleID, FriendID) ->
    Pattern = #r_friend{roleid=RoleID, friendid=FriendID, type=1, _='_'},
    case catch db:dirty_match_object(?DB_FRIEND, Pattern) of
        [_F] ->
            true;
        R ->
            ?DEBUG("if_friend, r: ~w", [R]),
            false
    end.

%%type, 方式：1、组队，2、聊天
if_reach_day_friendly_limited(RoleID, FriendID, Type) ->
    Pattern = #r_friend{roleid=RoleID, friendid=FriendID, _='_'},
    case catch db:dirty_match_object(?DB_FRIEND, Pattern) of
        [FriendInfo] ->
            case Type of
                1 ->
                    if_reach_day_friendly_limited2_1(FriendInfo);
                2 ->
                    if_reach_day_friendly_limited2_2(FriendInfo)
            end;
        R ->
            ?DEBUG("if_reach_day_friendly_limited, r: ~w", [R]),
            true
    end.
if_reach_day_friendly_limited2_1(FriendInfo) ->
    TeamTime = FriendInfo#r_friend.team_time,
    case TeamTime =:= undefined of
        true ->
            false;
        false ->
            {Date, Times} = TeamTime,
            {Date2, _} = calendar:now_to_local_time(now()),
            not(Date =/= Date2 orelse Times < 20)
    end.
if_reach_day_friendly_limited2_2(FriendInfo) ->
    ChatTime = FriendInfo#r_friend.chat_time,
    case ChatTime =:= undefined of
        true ->
            false;
        false ->
            {Date, Times} = ChatTime,
            {Date2, _} = calendar:now_to_local_time(now()),
            not(Date =/= Date2 orelse Times < 10)
    end.

make_family_map_name(FamilyID) ->
    lists:concat(["map_family_", FamilyID]).


%%构造一个唯一的普通怪物进程名称 
make_common_monster_process_name(MonsterType, MapProcessName, Tx, Ty) ->
    lists:concat([monster_, MonsterType, MapProcessName, Tx,Ty]).

%%构造一个唯一的召唤怪物进程名称 
make_summon_monster_process_name(Tick) ->
    lists:concat([monster_, Tick]).


%%构造一个唯一的门派boss进程名称
make_family_boss_process_name(FamilyID, MonsterType) ->
    MapName = make_family_map_name(FamilyID),
    lists:concat([monster_, MapName, MonsterType]).

%%获取门派进程名称
make_family_process_name(FamilyID) ->
    lists:concat(["family_", FamilyID]).

%%获取玩家防沉迷系数
get_role_fcm_cofficient(RoleID) ->
    %%如果防沉迷没有打开，就不用惩罚了
    case ?FCM_OPEN of
        true ->
            case catch mod_map_role:get_role_base(RoleID) of
                {ok,RoleBase} ->
                    get_role_fcm_cofficient2(RoleBase);
                _ ->
                    case db:dirty_read(?DB_ROLE_BASE, RoleID) of
                        [RoleBase] ->
                            get_role_fcm_cofficient2(RoleBase);
                        _ ->
                            1
                    end
            end;        
        false ->
            1
    end.

get_role_fcm_cofficient2(RoleBase) ->
    AccountName = RoleBase#p_role_base.account_name,
    case db:dirty_read(?DB_FCM_DATA, AccountName) of
        [FCMData] ->
            get_role_fcm_cofficient3(FCMData);
        _ ->
            1
    end.

get_role_fcm_cofficient3(FCMData) ->
    #r_fcm_data{total_online_time=TotalOnlineTime, passed=Passed} = FCMData,

    %%如果通过防沉迷验证的话，没有防沉迷惩罚
    case Passed =:= true of
        true ->
            1;
        _ ->
            if
                %%大于5小时，获得经验为0，装备掉落概率为0
                TotalOnlineTime >= 5 * 3600 ->
                    0.00001;

                %%大于3小时小于5小时，经验、装备掉落率减半
                TotalOnlineTime >= 3 * 3600 ->
                    0.5;

                %%无惩罚
                true ->
                    1
            end
    end.


%%获取角色详细信息
get_role_detail(RoleID) ->
    {ok, RoleBase} = common_misc:get_dirty_role_base(RoleID),
    {ok, RoleAttr} = common_misc:get_dirty_role_attr(RoleID),
    {ok, RolePos} = common_misc:get_dirty_role_pos(RoleID),
    {ok, RoleFight} = common_misc:get_dirty_role_fight(RoleID),
    {ok, RoleExt} = common_misc:get_dirty_role_ext(RoleID),
    #p_role{base=RoleBase, fight=RoleFight, pos=RolePos, attr=RoleAttr, ext=RoleExt}.

%%判断玩家所在地图是否是在自己国家
if_in_self_country(FactionID, MapID) ->
    case MapID rem 10000 div 1000 of
        FactionID ->
            true;
        _ ->
            false
    end.


get_common_map_name(MAPID) when is_integer(MAPID) ->
    lists:concat([mgee_map_, MAPID]).

get_map_faction_id(MapID) ->
    MapID div 1000 rem 10.

format_silver(_Name, 0) ->
    "";
format_silver(Name, Num) ->
    Silver_1 = Num div 10000,
    Silver_2 = Num rem 10000 div 100,
    Silver_3 = Num rem 10000 rem 100,

    case {Silver_1, Silver_2, Silver_3} of
        {0, 0, 0} ->
            "";

        {0, 0, Silver_3} ->
            lists:concat([Name,
                          Silver_3, ?_LANG_UNIT_SILVER_1]);

        {0, Silver_2, 0} ->
            lists:concat([Name,
                          Silver_2, ?_LANG_UNIT_SILVER_2]);

        {Silver_1, 0, 0} ->
            lists:concat([Name,
                          Silver_1, ?_LANG_UNIT_SILVER_3]);

        {0, Silver_2, Silver_3} ->
            lists:concat([Name, 
                          Silver_2, ?_LANG_UNIT_SILVER_2, 
                          Silver_3, ?_LANG_UNIT_SILVER_1]);

        {Silver_1, 0, Silver_3} ->
            lists:concat([Name, 
                          Silver_1, ?_LANG_UNIT_SILVER_3, 
                          Silver_3, ?_LANG_UNIT_SILVER_1]);

        {Silver_1, Silver_2, 0} ->
            lists:concat([Name,
                          Silver_1, ?_LANG_UNIT_SILVER_3, 
                          Silver_2, ?_LANG_UNIT_SILVER_2]);
        _ ->
            lists:concat([Name,
                          Silver_1, ?_LANG_UNIT_SILVER_3, 
                          Silver_2, ?_LANG_UNIT_SILVER_2, 
                          Silver_3, ?_LANG_UNIT_SILVER_1])

    end.

format_silver(Num) ->
    Silver_1 = Num div 10000,
    Silver_2 = Num rem 10000 div 100,
    Silver_3 = Num rem 10000 rem 100,

    case {Silver_1, Silver_2, Silver_3} of
        {0, 0, 0} ->
            "";

        {0, 0, Silver_3} ->
            lists:concat([Silver_3, ?_LANG_UNIT_SILVER_1]);

        {0, Silver_2, 0} ->
            lists:concat([Silver_2, ?_LANG_UNIT_SILVER_2]);

        {Silver_1, 0, 0} ->
            lists:concat([Silver_1, ?_LANG_UNIT_SILVER_3]);

        {0, Silver_2, Silver_3} ->
            lists:concat([Silver_2, ?_LANG_UNIT_SILVER_2, 
                          Silver_3, ?_LANG_UNIT_SILVER_1]);

        {Silver_1, 0, Silver_3} ->
            lists:concat([Silver_1, ?_LANG_UNIT_SILVER_3, 
                          Silver_3, ?_LANG_UNIT_SILVER_1]);

        {Silver_1, Silver_2, 0} ->
            lists:concat([Silver_1, ?_LANG_UNIT_SILVER_3, 
                          Silver_2, ?_LANG_UNIT_SILVER_2]);
        _ ->
            lists:concat([Silver_1, ?_LANG_UNIT_SILVER_3, 
                          Silver_2, ?_LANG_UNIT_SILVER_2, 
                          Silver_3, ?_LANG_UNIT_SILVER_1])

    end.

%%@doc 格式化多语言支持的消息
%%@spec format_lang(Message::binary(),Argument::list())-> binary()
format_lang(Message,Argument) when is_list(Argument)->
    lists:flatten(io_lib:format(Message,Argument) ).



%%@doc 从数据库获取玩家的背包物品列表（非实时）
%%@spec get_dirty_bag_goods/1 -> {ok,GoodsList}->{error,not_found}
get_dirty_bag_goods(RoleID)->
    case db:dirty_read(?DB_ROLE_BAG_BASIC_P,RoleID) of
        [] -> 
            {error,not_found};
        [ #r_role_bag_basic{bag_basic_list=BagBasicList} ]->
            GoodsList = [ get_dirty_bag_goods_2(RoleID,BagBasic)||BagBasic<-BagBasicList],
            {ok,lists:flatten(GoodsList)}
    end.
get_dirty_bag_goods_2(RoleID,BagBasic)->
        BagID = element(1,BagBasic),
        BagKey = {RoleID,BagID},
        case db:dirty_read(?DB_ROLE_BAG_P,BagKey) of
             [] ->
                  [];
             [BagInfo] ->
                  BagInfo#r_role_bag.bag_goods
        end.
    
get_level_base_hp(Level) ->
    ?BASE_ROLE_MAX_HP + 100 * Level.

get_level_base_mp(Level) ->
    ?BASE_ROLE_MAX_MP + 4 * Level.

%%通用的全局活动状态表-比如国运-国探
get_event_state(Key) ->
    case db:dirty_read(?DB_EVENT_STATE, Key) of
        [] ->
            {false, []};
        [Data] ->
            {ok, Data}
    end.

set_event_state(Key, Data) ->
    NewEventData = #r_event_state{key=Key, data=Data},
    db:dirty_write(?DB_EVENT_STATE, NewEventData).

del_event_state(Key) ->
    db:dirty_delete(?DB_EVENT_STATE, Key).

%%非获得新的ID
dirty_get_new_counter(Key) ->
    case db:dirty_read(?DB_COUNTER, Key) of
        [] ->
            NewCounterNum = 1,
            NewRecord = #r_counter{key=Key, value=NewCounterNum};
        [Counter] ->
            NewCounterNum = Counter#r_counter.value + 1,
            NewRecord = Counter#r_counter{value=NewCounterNum}
    end,
    db:dirty_write(?DB_COUNTER, NewRecord),
    {ok, NewCounterNum}.

%%事务获得新的ID
trans_get_new_counter(Key) ->
    Result = 
    db:transaction(fun() ->
        case db:read(?DB_COUNTER, Key, read) of
            [] ->
                NewCounterNum = 1,
                NewRecord = #r_counter{key=Key, value=NewCounterNum};
            [Counter] ->
                NewCounterNum = Counter#r_counter.value + 1,
                NewRecord = Counter#r_counter{value=NewCounterNum}
        end,
        db:write(?DB_COUNTER, NewRecord, write),
        NewCounterNum
    end),

    case Result of
        {atomic, NewCounterNum} ->
            {ok, NewCounterNum};
        {aborted, Reason} ->
            {false, Reason}
    end.

%%@doc 增加玩家的活跃度
done_task(RoleID,ActivityKey) when is_integer(ActivityKey) ->
    common_misc:send_to_rolemap(RoleID, {mod,hook_activity_task,{done_task,{RoleID,ActivityKey}}}).   

%%@doc 将数据值更新到进程字典的队列
update_dict_queue(TheKey,Val)->
    case get(TheKey) of
        undefined ->
            put(TheKey, [Val]);
        Queues ->
            put( TheKey,[ Val|Queues ] )
    end.

%% @doc 获取回城点
get_home_mapid(FactionID, MapID) ->
    %%本国的话回到本片区的回城点，中立区回到开封，其它情况回到本国王都
    case MapID =:= 10210 of
        true ->
            if
                FactionID =:= 1 ->
                    11000;
                FactionID =:= 2 ->
                    12000;
                true ->
                    13000
            end;
        _ ->
            case if_in_self_country(FactionID, MapID) of
                false ->
                    case if_in_neutral_area(MapID) of
                        true ->
                            10200;
                        _ ->
                            get_home_mapid2(FactionID)
                    end;
                true ->
                    get_home_mapid3(MapID)
            end
    end.

get_home_mapid2(FactionID) ->    
    10000 + FactionID * 1000 + 100.

get_home_mapid3(MapID) ->
    MapID div 100 * 100.

get_jingcheng_mapid(FactionID) ->
    10000 + FactionID * 1000 + 100.

%%是否在中立区
if_in_neutral_area(MapID) ->
    MapID div 100 =:= 102.

get_team_proccess_name(TeamId) ->
    lists:concat([team_,TeamId]).

%%格式化物品名字的颜色
format_goods_name_colour(Colour,Name) ->
    if Colour =:= ?COLOUR_WHITE ->
            lists:append(["<font color=\"#FFFFFF\">【",common_tool:to_list(Name),"】</font>"]);
       Colour =:= ?COLOUR_GREEN->
            lists:append(["<font color=\"#12CC95\">【",common_tool:to_list(Name),"】</font>"]);
       Colour =:= ?COLOUR_BLUE->
            lists:append(["<font color=\"#0D79FF\">【",common_tool:to_list(Name),"】</font>"]);
       Colour =:= ?COLOUR_PURPLE->
            lists:append(["<font color=\"#FE00E9\">【",common_tool:to_list(Name),"】</font>"]);
       Colour =:= ?COLOUR_ORANGE->
            lists:append(["<font color=\"#FF7E00\">【",common_tool:to_list(Name),"】</font>"]);
       Colour =:= ?COLOUR_GOLD->
            lists:append(["<font color=\"#FFD700\">【",common_tool:to_list(Name),"】</font>"]);
       true ->
            lists:append(["<font color=\"#FFFFFF\">【",common_tool:to_list(Name),"】</font>"])
    end.

-define(equip_ring_color_gold, 3).
-define(equip_ring_color_oranger, 2).
-define(equip_ring_color_purple, 1).
-define(equip_ring_color_white, 0).

%% @doc 获取装备光环颜色
get_equip_ring_and_mount_color(EquipsList) ->
    {PurpleNum, OrangerNum, GoldNum, MountColor} =
        lists:foldl(
          fun(Equip, {PurpleCount, OrangeCounter, GoldCount, MC}) ->
                  #p_goods{loadposition=LoadPosition, current_colour=Colour} = Equip,
                  case LoadPosition =:= 15 of
                      true ->
                          MC2 = Colour;
                      _ ->
                          MC2 = MC
                  end,
                  %% 时装及特殊装备不计入考虑范围
                  case LoadPosition =:= 7 orelse LoadPosition =:= 8 orelse LoadPosition =:= 14 of
                      true ->
                          {PurpleCount, OrangeCounter, GoldCount, MC2};
                      _ ->
                          case Colour of
                              ?COLOUR_PURPLE ->
                                  {PurpleCount+1, OrangeCounter, GoldCount, MC2};
                              ?COLOUR_ORANGE ->
                                  {PurpleCount, OrangeCounter+1, GoldCount, MC2};
                              ?COLOUR_GOLD ->
                                  {PurpleCount, OrangeCounter, GoldCount+1, MC2};
                              _ ->
                                  {PurpleCount, OrangeCounter, GoldCount, MC2}
                          end
                  end
          end, {0, 0, 0, 0}, EquipsList),
    %% 5件以上紫色，紫光；橙色，橙光；金色，金光
    EquipRingColor =
        if
            GoldNum >= 5 ->
                ?equip_ring_color_gold;
            GoldNum + OrangerNum >= 5 ->
                ?equip_ring_color_oranger;
            GoldNum + OrangerNum + PurpleNum >= 5 ->
                ?equip_ring_color_purple;
            true ->
                ?equip_ring_color_white
        end,
    {ok, EquipRingColor, MountColor}.

get_role_conlogin_reward(RoleID) ->
    [R] = db:dirty_read(?DB_ROLE_CONLOGIN_P, RoleID),
    R.


%%@doc 检查是否在当天的规定时间段内
%%@param    参数均为{时,分,秒}
%%@return   bool()
check_in_special_time({SH,SI,SS}, {EH,EI,ES})->
    {H, I, S} = erlang:time(),
    StartSeconds = SH*3600 + SI*60 + SS,
    EndSeconds = EH*3600 + EI*60 + ES,
    NowSeconds = H*3600 + I*60 + S,
    (NowSeconds>=StartSeconds) andalso (EndSeconds>=NowSeconds).

%% @doc 检测时间是否冲突
%%LastTime秒
check_time_conflict(StartHour, StartMin, LastTime, CheckHour, CheckMin) ->
    StartTime = StartHour * 60 + StartMin,
    EndTime = StartTime + LastTime,
    CheckTime = CheckHour * 60 + CheckMin,
    
    case CheckTime >= StartTime andalso CheckTime =< EndTime of
        true ->
            error;
        _ ->
            ok
    end.

%%LastTime秒
get_end_time(StartH, StartM, LastTime) ->
    EndH = StartH+((StartM + LastTime div 60) div 60),
    EndM = (StartM + LastTime div 60) rem 60,
    {EndH, EndM}.

%% @doc 获取指定角色摆摊所在地图进程
get_stall_map_pid(RoleID) ->
    case db:dirty_read(?DB_STALL, RoleID) of
        [] ->
            {error, not_found};
        [#r_stall{mapid=MapID}] ->
            MapPName = common_misc:get_map_name(MapID),
            case global:whereis_name(MapPName) of
                undefined ->
                    {error, not_found};
                PID ->
                    {ok, PID}
            end
    end.

