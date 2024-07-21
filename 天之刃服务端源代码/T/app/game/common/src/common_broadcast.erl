%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     通用的消息广播接口
%%% @end
%%% Created : 2010-12-1
%%%-------------------------------------------------------------------
-module(common_broadcast).

-include("common.hrl").
-include("common_server.hrl").


%% 消息广播接口
-export([bc_send_msg_world/4,
         bc_send_msg_world/3,
         bc_send_msg_faction/5,
         bc_send_msg_faction/4,
         bc_send_msg_family/4,
         bc_send_msg_team/4,
         bc_send_msg_role/3,
         bc_send_msg_role/4,
         bc_send_cycle_msg_world/6,
         bc_send_cycle_msg_faction/7,
         bc_send_cycle_msg_family/7,
         bc_send_cycle_msg_team/7,
         bc_send_cycle_msg_role/7,
         bc_send_msg_world_include_goods/7,
         bc_send_msg_faction_include_goods/8]).


%% 消息广播接口

%% 消息类型——
%%        2905:操作消息,2906:系统消息,2908:喇叭消息,2909:中央广播消息,2910:聊天频道消息,2911:弹窗消息,2920:走马灯
%% 消息子类型 ——
%%        2912:表示没有消息子类型；聊天频道消息子类型：2915世界,2916国家,2917门派,2918组队

%% -define(BC_MSG_TYPE_OPERATE, 2905).
%% -define(BC_MSG_TYPE_SYSTEM, 2906).
%% -define(BC_MSG_TYPE_COUNTDOWN, 2907).
%% -define(BC_MSG_TYPE_ALL, 2908).
%% -define(BC_MSG_TYPE_CENTER, 2909).
%% -define(BC_MSG_TYPE_CHAT, 2910).
%% -define(BC_MSG_TYPE_POP, 2911).
%% -define(BC_MSG_SUB_TYPE, 2912).
%% -define(BC_MSG_TYPE_COUNTDOWN_DUNGEON, 2913).
%% -define(BC_MSG_TYPE_COUNTDOWN_TASK, 2914).
%% -define(BC_MSG_TYPE_CHAT_WORLD, 2915).
%% -define(BC_MSG_TYPE_CHAT_COUNTRY, 2916).
%% -define(BC_MSG_TYPE_CHAT_FAMILY, 2917).
%% -define(BC_MSG_TYPE_CHAT_TEAM, 2918).
%% -define(BC_MSG_TYPE_ROLL_MSG, 2920).

%% world
%% boss群用的接口  弹出框提示
bc_send_msg_world(TypeList,SubType,Content,ExtList) when erlang:is_list(TypeList)  ->
    Msg = #m_broadcast_general_toc{type=TypeList, sub_type=SubType, content=Content, ext_info_list=ExtList},
    common_misc:chat_broadcast_to_world(?BROADCAST, ?BROADCAST_GENERAL, Msg).
bc_send_msg_world(Type,SubType,Content) when erlang:is_integer(Type) ->
    bc_send_msg_world([Type], SubType, Content);
bc_send_msg_world(TypeList, SubType, Content) when erlang:is_list(TypeList) ->
    Msg = #m_broadcast_general_toc{type=TypeList, sub_type=SubType, content=Content},
    common_misc:chat_broadcast_to_world(?BROADCAST, ?BROADCAST_GENERAL, Msg).
%% 附带物品信息
bc_send_msg_world_include_goods(Type, SubType, Content, RoleID, RoleName, Sex, GoodsList) when erlang:is_integer(Type) ->
    bc_send_msg_world_include_goods([Type], SubType, Content, RoleID, RoleName, Sex, GoodsList);
bc_send_msg_world_include_goods(TypeList, SubType, Content, RoleID, RoleName, Sex, GoodsList) when erlang:is_list(TypeList) ->
    case global:whereis_name(mgeec_goods_cache) of
        undefined ->
            ?ERROR_MSG("悲剧，mgeec_goods_cache挂了!!!", []);
        PID ->
            PID ! {bc_send_msg_world, TypeList, SubType, Content, RoleID, RoleName, Sex, GoodsList}
    end.

%% faction
bc_send_msg_faction(FactionId,TypeList,SubType,Content,ExtList) when erlang:is_list(TypeList) ->
    Msg = #m_broadcast_general_toc{type=TypeList, sub_type=SubType, content=Content,ext_info_list=ExtList},
    common_misc:chat_broadcast_to_faction(FactionId, ?BROADCAST, ?BROADCAST_GENERAL, Msg).
bc_send_msg_faction(FactionId,Type,SubType,Content) when erlang:is_integer(Type) ->
    bc_send_msg_faction(FactionId, [Type], SubType, Content);
bc_send_msg_faction(FactionId, TypeList, SubType, Content) when erlang:is_list(TypeList) ->
    Msg = #m_broadcast_general_toc{type=TypeList, sub_type=SubType, content=Content},
    common_misc:chat_broadcast_to_faction(FactionId, ?BROADCAST, ?BROADCAST_GENERAL, Msg).
%% 附带物品信息
bc_send_msg_faction_include_goods(FactionID, Type, SubType, Content, RoleID, RoleName, Sex, GoodsList) when erlang:is_integer(Type) ->
    bc_send_msg_faction_include_goods(FactionID, [Type], SubType, Content, RoleID, RoleName, Sex, GoodsList);
bc_send_msg_faction_include_goods(FactionID, TypeList, SubType, Content, RoleID, RoleName, Sex, GoodsList) when erlang:is_list(TypeList) ->
    case global:whereis_name(mgeec_goods_cache) of
        undefined ->
            ?ERROR_MSG("悲剧，mgeec_goods_cache挂了!!!", []);
        PID ->
            PID ! {bc_send_msg_faction, FactionID, TypeList, SubType, Content, RoleID, RoleName, Sex, GoodsList}
    end.

%% family
bc_send_msg_family(FamilyId,Type,SubType,Content) when erlang:is_integer(Type) ->
    bc_send_msg_family(FamilyId, [Type], SubType, Content);
bc_send_msg_family(FamilyId, TypeList, SubType, Content) when erlang:is_list(TypeList) ->
    Msg = #m_broadcast_general_toc{type=TypeList, sub_type=SubType, content=Content},
    common_misc:chat_broadcast_to_family(FamilyId, ?BROADCAST, ?BROADCAST_GENERAL, Msg).

%% team
bc_send_msg_team(TeamId,Type,SubType,Content) when erlang:is_integer(Type) ->
    bc_send_msg_team(TeamId,[Type],SubType,Content);
bc_send_msg_team(TeamId,TypeList,SubType,Content) when erlang:is_list(TypeList) ->
    Msg = #m_broadcast_general_toc{type=TypeList, sub_type=SubType, content=Content},
    common_misc:chat_broadcast_to_team(TeamId, ?BROADCAST, ?BROADCAST_GENERAL, Msg).

%% role
%% @param RoleID ::integer() | list() 玩家ID或者玩家ID的列表
%% @param TypeOrList ::integer() | list() 频道ID或频道ID的列表
bc_send_msg_role(RoleId,TypeOrList,Content) ->
    bc_send_msg_role(RoleId,TypeOrList,?BC_MSG_SUB_TYPE,Content).
bc_send_msg_role(RoleId,Type,SubType,Content) when is_integer(Type) ->
    case RoleId of
        RoleId when is_list(RoleId) ->
            RoleIdList = RoleId;
        _ ->
            RoleIdList = [RoleId]
    end,
    Msg = #m_broadcast_general_toc{type=[Type], sub_type=SubType, content=Content},
    case RoleIdList =/= [] of
        true ->
            lists:foreach(
              fun(VRoleId) ->
                      case common_misc:is_role_online(VRoleId) of
                          false -> 
                              ignore;
                          true ->
                              common_misc:unicast({role,VRoleId}, ?DEFAULT_UNIQUE, ?BROADCAST, ?BROADCAST_GENERAL, Msg)
                      end
              end,RoleIdList);
        _ ->
            ignore
    end;
bc_send_msg_role(RoleID,TypeList,SubType,Content) when is_list(TypeList) ->
    Msg = #m_broadcast_general_toc{type=TypeList, sub_type=SubType, content=Content},
    common_misc:chat_broadcast_to_role(RoleID, ?BROADCAST, ?BROADCAST_GENERAL, Msg).


%% 消息类型——
%%        2905:操作消息,2906:系统消息,2908:喇叭消息,2909:中央广播消息,2910:聊天频道消息,2911:弹窗消息
%% 消息子类型 ——
%%        2912:表示没有消息子类型；聊天频道消息子类型：2915世界,2916国家,2917门派,2918组队
%% Content消息内容 ,
%% StartTime开始时间,格式为：common_tool:now()
%% EndTime结束时间,格式为：common_tool:now()
%% IntervalTime间隔时间 单位：秒
bc_send_cycle_msg_world(Type,SubType,Content,StartTime,EndTime,IntervalTime) ->
    Record = #m_broadcast_cycle_tos{type = Type,sub_type = SubType,content = Content,
                                    send_type = 1,start_time = StartTime,
                                    end_time = EndTime,interval = IntervalTime,
                                    role_list = [],is_world = true,country_id = 0,
                                    famliy_id = 0,team_id = 0},
    broadcast_send_message(?BROADCAST_CYCLE,Record).
bc_send_cycle_msg_faction(FactionId,Type,SubType,Content,StartTime,EndTime,IntervalTime) ->
    Record = #m_broadcast_cycle_tos{type = Type,sub_type = SubType,content = Content,
                                    send_type = 1,start_time = StartTime,
                                    end_time = EndTime,interval = IntervalTime,
                                    role_list = [],is_world = false,country_id = FactionId,
                                    famliy_id = 0,team_id = 0},
    broadcast_send_message(?BROADCAST_CYCLE,Record).
bc_send_cycle_msg_family(FamilyId,Type,SubType,Content,StartTime,EndTime,IntervalTime) ->
    Record = #m_broadcast_cycle_tos{type = Type,sub_type = SubType,content = Content,
                                    send_type = 1,start_time = StartTime,
                                    end_time = EndTime,interval = IntervalTime,
                                    role_list = [],is_world = false,country_id = 0,
                                    famliy_id = FamilyId,team_id = 0},
    broadcast_send_message(?BROADCAST_CYCLE,Record).
bc_send_cycle_msg_team(TeamId,Type,SubType,Content,StartTime,EndTime,IntervalTime) ->
    Record = #m_broadcast_cycle_tos{type = Type,sub_type = SubType,content = Content,
                                    send_type = 1,start_time = StartTime,
                                    end_time = EndTime,interval = IntervalTime,
                                    role_list = [],is_world = false,country_id = 0,
                                    famliy_id = 0,team_id = TeamId},
    broadcast_send_message(?BROADCAST_CYCLE,Record).
bc_send_cycle_msg_role(RoleID,Type,SubType,Content,StartTime,EndTime,IntervalTime) ->
    case RoleID of
        RoleID when is_list(RoleID) ->
            RoleList = RoleID;
        _ ->
            RoleList = [RoleID]
    end,
    if RoleList =/= [] ->
            Record = #m_broadcast_cycle_tos{type = Type,sub_type = SubType,content = Content,
                                            send_type = 1,start_time = StartTime,
                                            end_time = EndTime,interval = IntervalTime,
                                            role_list = RoleList,is_world = false,country_id = 0,
                                            famliy_id = 0,team_id = 0},
            broadcast_send_message(?BROADCAST_CYCLE,Record);
       true ->
            ignore
    end.
broadcast_send_message(Method,Record) ->
    global:send("mod_broadcast_server",{0, ?BROADCAST, Method, Record}).

