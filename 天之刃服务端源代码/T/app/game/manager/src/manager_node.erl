%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2011, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 29 Mar 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(manager_node).

-include("manager.hrl").

%% API
-export([
         start_all/0,
         start_gateway/0
        ]).

start_gateway() ->
    [GatewayConfig] = common_config_dyn:find_common(gateway),
    start_gateway_node(GatewayConfig).

%% 启动所有的其他节点，不包括manager自身和security节点
start_all() ->
    yes = global:register_name(manager_node, erlang:self()),
    case catch do_common_config_check() of
        ok ->
            [MasterHost] = common_config_dyn:find_common(master_host),
            AddressList = common_tool:get_all_bind_address(),
            case lists:member(MasterHost, AddressList) of
                true ->
                    ok;
                false ->
                    ?SYSTEM_LOG("~ts", ["Master Host配置错误，请检查IP地址是否正确"]),
                    timer:sleep(1000),
                    erlang:halt()
            end,
            [GatewayConfig] = common_config_dyn:find_common(gateway),
            [MapConfig] = common_config_dyn:find_common(map),
            start_security_node(MasterHost),
            start_behavior_node(MasterHost),
            start_db_node(MasterHost),
            start_erlangweb_node(MasterHost),
            start_login_node(MasterHost),
            start_chat_node(MasterHost),
            start_world_node(MasterHost),
            %% 顺序启动网关机器的security
            GatewayLanHostList = get_gateway_lan_host_list(GatewayConfig),
            GatewaylanHostList2 = lists:delete(MasterHost, GatewayLanHostList),
            lists:foreach(
              fun(NodeHost) ->
                  start_security_node(NodeHost)
              end, GatewaylanHostList2),
            %% 启动地图节点
            start_map_node(MapConfig),
            %% 启动网关节点
            start_gateway_node(GatewayConfig),
            ?SYSTEM_LOG("~ts", ["游戏启动成功"]),
            timer:sleep(1000),
            ?SYSTEM_LOG("~ts ~n", ["按ctl-c退出"]),
            os:cmd("ps awux | grep 'tail -f /data/logs/tzr_manager.log' | grep -v 'grep' | awk '{print $2}' | xargs kill -9"),
            ok;
        {error, Error} ->
            ?SYSTEM_LOG("~ts:~w", ["读取common.config配置出错", Error]),
            error
    end.


start_gateway_node(GatewayConfig) ->
    ?SYSTEM_LOG("~ts~n", ["准备启动网关集群"]),
    %% 网关节点的绑定从CPU最高核开始
    lists:foreach(
      fun({Host, Domain, PortList}) ->
              lists:foldl(
                fun(Port, Index) ->
                        NodeName = lists:concat(["mgeeg_", Port, "@", Host]),
                        NodeNameAtom = erlang:list_to_atom(NodeName), 
                        net_kernel:connect_node(NodeNameAtom),
                        case lists:member(NodeNameAtom, erlang:nodes()) of
                            true ->
                                ?SYSTEM_LOG("~ts~n", ["警告：指定网关节点已经启动"]),
                                Index - 1;
                            false ->
                                case lists:member(erlang:list_to_atom(NodeName), [erlang:nodes()]) of
                                    true ->
                                        Index + 1;
                                    false ->
                                        Command = get_gateway_start_command(Index, Host, Domain, NodeName, Port),
                                        ?SYSTEM_LOG("~ts~n ~s~n", ["准备启动网关节点", Command]),
                                        erlang:open_port({spawn, Command}, [stream]),
                                        receive 
                                            {gateway_node_up, NodeName2} ->
                                                ?SYSTEM_LOG("~ts ~p~n", ["网关节点启动成功", NodeNameAtom]), 
                                                net_kernel:connect_node(NodeName2)                                                
                                        end,
                                        Index - 1
                                end
                        end
                end, erlang:system_info(logical_processors) - 1, PortList)
      end, GatewayConfig),
    ok.

get_ebin_dir(RootDIR) ->
    List = filelib:wildcard(RootDIR ++ "/*"),
    FoldList2 = lists:foldl(
                  fun(F, Acc) ->
                          case filelib:is_dir(F) of
                              true ->
                                  [F | Acc];
                              false ->
                                  Acc
                          end
                  end, [], List),
    lists:foldl(
      fun(F, Acc) ->
              List2 = filelib:wildcard(F ++ "/*"),
              lists:foldl(
                fun(F2, Acc2) ->
                        case filelib:is_dir(F2) of
                            true ->
                                [F2 | Acc2];
                            false ->
                                Acc2
                        end
                end, Acc, List2)
      end, [RootDIR | FoldList2], FoldList2).


get_node_root_path(security) ->
    "/data/tzr/server/ebin/security";
get_node_root_path(behavior) ->
    "/data/tzr/server/ebin/behavior";
get_node_root_path(db) ->
    "/data/tzr/server/ebin/db";
get_node_root_path(login) ->
    "/data/tzr/server/ebin/login";
get_node_root_path(chat) ->
    "/data/tzr/server/ebin/chat";
get_node_root_path(map) ->
    "/data/tzr/server/ebin/map";
get_node_root_path(world) ->
    "/data/tzr/server/ebin/world";
get_node_root_path(gateway) ->
    "/data/tzr/server/ebin/gateway";
get_node_root_path(mgeeweb) ->
    "/data/tzr/server/ebin/mgeeweb".

get_add_path(mgeeweb)->
    " -pa /data/tzr/server/ebin/chat -pa /data/tzr/server/ebin/chat/mod "; 
get_add_path(_)->
    "".



get_path(NodePrefix) ->
    PathList = get_ebin_dir(get_node_root_path(NodePrefix)),
    Path = lists:foldl(
             fun(P, Acc) ->
                     [" -pa " ++ P | Acc]
             end, [], PathList),
    Path2 = lists:foldl(
             fun(P, Acc) ->
                     [" -pa " ++ P | Acc]
             end, [], get_ebin_dir("/data/tzr/server/ebin/common")),
    " -pa /data/tzr/server/ebin/ -pa /data/tzr/server/ebin/config/ " ++ Path ++ Path2.        
  
get_db_start_command(CPUNumStr, NodeHost, NodeName, StartModule, CodePath, ExtraArgs) ->
    case erlang:system_info(logical_processors)<8 of
        true ->
            RSH = "",
            CPUNum2 = "",
            SaslPath = lists:concat([" -sasl sasl_error_logger \\\{file,\\\"/data/logs/", NodeName, "_sasl.log\\\"\\\} "]), 
            MnesiaPath = "\\\"/data/database/tzr/\\\"";
        _ ->
            RSH = lists:concat(["rsh ", NodeHost]),
            CPUNum2 = lists:concat([" taskset -c ", CPUNumStr]),
            SaslPath = lists:concat([" -sasl sasl_error_logger \\\\\\\{file,\\\\\\\"/data/logs/", NodeName, "_sasl.log\\\\\\\"\\\\\\\} "]), 
            MnesiaPath = "\\\\\\\"/data/database/tzr/\\\\\\\""
    end,
    case string:str(common_tool:to_list(CPUNumStr), ",") > 0 of
        true ->
            Smp = enable;
        false ->
            Smp = disable
    end,
    {{Y, M, D}, {H, I, S}} = erlang:localtime(),
    ErlCrashDump = lists:concat(["/data/logs/", NodeName, "_erl_crash_dump_", Y, M, D, "_", H, I, S, ".dump"]),
    lists:flatten(lists:concat([RSH, CPUNum2,
                                " erl -smp ", Smp, "  +h 10240 +K true -detached -noinput -env ERL_MAX_PORTS 250000 +K true -s ",
                                StartModule, " -name ", NodeName, " ", CodePath, 
                                " -env ERL_MAX_ETS_TABLES 500000  +P 250000 ", 
                                " -mnesia dir ", MnesiaPath ," -mnesia dump_log_write_threshold 100000 -mnesia no_table_loaders 100 "
                                " -env ERL_CRASH_DUMP ", ErlCrashDump, SaslPath,
                                " -master_node ", erlang:node(), 
                                " ", ExtraArgs,
                                " -setcookie ", erlang:get_cookie()])).

get_gateway_start_command(CPUNumStr, NodeHost, Domain, NodeName, Port) ->
    case erlang:system_info(logical_processors) < 8 of
        true ->
            RSH = "",
            CPUNum2 = 0;
        _ ->
            RSH = lists:concat(["rsh ", NodeHost]),
            CPUNum2 = CPUNumStr
    end,
    {{Y, M, D}, {H, I, S}} = erlang:localtime(),
    ErlCrashDump = lists:concat(["/data/logs/", NodeName, "_erl_crash_dump_", Y, M, D, "_", H, I, S, ".dump"]),
    lists:flatten(lists:concat([RSH, " bash /data/tzr/server/script/start_gateway.sh ", " '", 
                                CPUNum2, "' ", NodeHost, " ", Domain, " ", Port, " ", ErlCrashDump
                               ])).


get_start_command(CPUNumStr, NodeHost, NodeName, StartModule, CodePath, ExtraArgs) ->
    case erlang:system_info(logical_processors) < 8 of
        true ->
            RSH = "",
            SaslPath = lists:concat([" -sasl sasl_error_logger \\\{file,\\\"/data/logs/", NodeName, "_sasl.log\\\"\\\} "]), 
            CPUNum2 = "";
        _ ->
            RSH = lists:concat(["rsh ", NodeHost]),
            SaslPath = lists:concat([" -sasl sasl_error_logger \\\\\\\{file,\\\\\\\"/data/logs/", NodeName, "_sasl.log\\\\\\\"\\\\\\\} "]), 
            CPUNum2 = lists:concat([" taskset -c ", CPUNumStr])
    end,
    case string:str(common_tool:to_list(CPUNumStr), ",") > 0 of
        true ->
            Smp = enable;
        false ->
            Smp = disable
    end,
    {{Y, M, D}, {H, I, S}} = erlang:localtime(),
    ErlCrashDump = lists:concat(["/data/logs/", NodeName, "_erl_crash_dump_", Y, M, D, "_", H, I, S, ".dump"]),
    
    lists:flatten(lists:concat([RSH, CPUNum2,
                                " erl -smp ", Smp, "  +h 10240 +K true -detached -noinput -env ERL_MAX_PORTS 250000 +K true -s ",
                                StartModule, " -name ", NodeName, " ", CodePath, 
                                " -env ERL_MAX_ETS_TABLES 500000  +P 250000 ", 
                                " -env ERL_CRASH_DUMP ", ErlCrashDump, SaslPath,
                                " -master_node ", erlang:node(), 
                                " ", ExtraArgs,
                                " -setcookie ", erlang:get_cookie()])).

%% 启动地图节点
%% 这里只需要启动地图主节点，其他的由地图主节点完成
start_map_node(MapConfig) ->
    %% 排在第一个的内网机器作为地图主节点机器
    {MasterMapHost, _NSlave} = erlang:hd(MapConfig),    
    NodeName = lists:concat(["mgeem@", MasterMapHost]),
    NodeNameAtom = erlang:list_to_atom(NodeName), 
    net_kernel:connect_node(NodeNameAtom),
    case lists:member(NodeNameAtom, erlang:nodes()) of
        true ->
            ?SYSTEM_LOG("~ts~n", ["警告：地图主节点已经启动"]),
            ignore;
        false ->
            case lists:member(erlang:list_to_atom(NodeName), [erlang:nodes()]) of
                true ->
                    ok;
                false ->
                    Command = "bash /data/tzr/server/mgectl start mgeem",
                    erlang:open_port({spawn, Command}, [stream]),
                    ?SYSTEM_LOG("~ts~n ~s~n", ["准备启动地图主节点", Command]),
                    receive 
                        {map_node_up, NodeName2} ->
                            ?SYSTEM_LOG("~ts", ["地图主节点启动成功"]),
                            net_kernel:connect_node(NodeName2);
                        {'DOWN', _, _, _, Info} ->
                            ?SYSTEM_LOG("~ts:~w", ["地图集群启动失败", Info])
                    end,
                    ok
            end
    end,
    ok.

start_login_node(NodeHost) ->
    NodeName = lists:concat(["mgeel@", NodeHost]),
    NodeNameAtom = erlang:list_to_atom(NodeName), 
    net_kernel:connect_node(NodeNameAtom),
    case lists:member(NodeNameAtom, erlang:nodes()) of
        true ->
            ?SYSTEM_LOG("~ts~n", ["警告：登录login节点已经启动"]),
            ignore;
        false ->
            CodePath = get_path(login),
            %% 核绑定在CPU 1上
            Command = get_start_command(2, NodeHost, NodeName, "mgeel", CodePath, ""),
            ?SYSTEM_LOG("~ts~n~s~n", ["准备启动login节点", Command]),
            erlang:open_port({spawn, Command}, [stream]),
            receive 
                {login_node_up, NodeName2} ->
                    net_kernel:connect_node(NodeName2)
            end
    end,
    ok.

start_world_node(NodeHost) ->
    NodeName = lists:concat(["mgeew@", NodeHost]),
    NodeNameAtom = erlang:list_to_atom(NodeName), 
    net_kernel:connect_node(NodeNameAtom),
    case lists:member(NodeNameAtom, erlang:nodes()) of
        true ->
            ?SYSTEM_LOG("~ts", ["world节点已经启动"]),
            ignore;
        false ->
            CodePath = get_path(world),
            %% 核绑定在CPU 1上
            Command = get_start_command("5,7", NodeHost, NodeName, "mgeew", CodePath, ""),
            ?SYSTEM_LOG("~ts~n", ["准备启动world节点"]),
            erlang:open_port({spawn, Command}, [stream]),
            receive 
                {world_node_up, NodeName2} ->
                    ?SYSTEM_LOG("~ts", ["启动world节点成功"]),
                    net_kernel:connect_node(NodeName2)
            end
    end,
    ok.

start_chat_node(NodeHost) ->
    NodeName = lists:concat(["mgeec@", NodeHost]),
    NodeNameAtom = erlang:list_to_atom(NodeName), 
    net_kernel:connect_node(NodeNameAtom),
    case lists:member(NodeNameAtom, erlang:nodes()) of
        true ->
            ?SYSTEM_LOG("~ts~n", ["警告：聊天节点已经启动"]),
            ignore;
        false ->
            CodePath = get_path(chat),
            %% 核绑定在CPU 1上
            Command = get_start_command(3, NodeHost, NodeName, "mgeec", CodePath, ""),
            ?SYSTEM_LOG("~ts~n~s~n", ["准备启动聊天节点", Command]),
            erlang:open_port({spawn, Command}, [stream]),
            receive 
                {chat_node_up, NodeName2} ->
                    ?SYSTEM_LOG("~ts~n", ["启动聊天节点成功"]),
                    net_kernel:connect_node(NodeName2)
            end
    end,
    ok.
    

start_erlangweb_node(NodeHost) ->
    NodeName = lists:concat(["mgeeweb@", NodeHost]),
    NodeNameAtom = erlang:list_to_atom(NodeName), 
    net_kernel:connect_node(NodeNameAtom),
    case lists:member(NodeNameAtom, erlang:nodes()) of
        true ->
            ?SYSTEM_LOG("~ts~n", ["警告：mgeeweb节点已经启动"]),
            ignore;
        false ->
            CodePath = get_path(mgeeweb) ++ get_add_path(mgeeweb),
            %% 核绑定在CPU 1上
            Command = get_start_command("1,3", NodeHost, NodeName, "mgeeweb", CodePath, " -pa /data/tzr/server/ebin/mochiweb"),
            ?SYSTEM_LOG("~ts~n~s~n", ["准备启动mgeeweb节点", Command]),
            erlang:open_port({spawn, Command}, [stream]),
            receive 
                {mgeeweb_node_up, NodeName2} ->
                    net_kernel:connect_node(NodeName2)
            end
    end,
    ok.


start_db_node(NodeHost) ->
    NodeName = lists:concat(["mgeed@", NodeHost]),
    NodeNameAtom = erlang:list_to_atom(NodeName), 
    net_kernel:connect_node(NodeNameAtom),
    case lists:member(NodeNameAtom, erlang:nodes()) of
        true ->
            ?SYSTEM_LOG("~ts~n", ["警告:db节点已经启动"]),
            ignore;
        false ->
            CodePath = get_path(db),
            %% 核绑定在CPU 1上
            Command = get_db_start_command(4, NodeHost, NodeName, "mgeed", CodePath, ""),
            ?SYSTEM_LOG("~ts~n~s~n", ["准备启动db节点", Command]),
            erlang:open_port({spawn, Command}, [stream]),
            receive 
                {db_node_up, NodeName2} ->
                    ?SYSTEM_LOG("~ts~n", ["db节点启动成功"]),
                    net_kernel:connect_node(NodeName2)
            end
    end,
    ok.

%% 启动行为日志节点
start_behavior_node(NodeHost) ->
    NodeName = lists:concat(["mgeeb@", NodeHost]),
    NodeNameAtom = erlang:list_to_atom(NodeName), 
    net_kernel:connect_node(NodeNameAtom),
    case lists:member(NodeNameAtom, erlang:nodes()) of
        true ->
            ?SYSTEM_LOG("~ts~n", ["警告:行为日志节点已经启动"]),
            ignore;
        false ->
            CodePath1 = get_path(behavior),
            CodePath2 = lists:concat([CodePath1," -pa /data/tzr/server/ebin/proto/ -pa /data/tzr/server/ebin/library/ "]),
            %% 核绑定在CPU 1上
            Command = get_start_command(1, NodeHost, NodeName, "mgeeb", CodePath2, ""),
            ?SYSTEM_LOG("~ts~n~s~n", ["准备启动行为日志节点", Command]),
            erlang:open_port({spawn, Command}, [stream]),
            receive 
                {behavior_node_up, NodeName2} ->
                    ?SYSTEM_LOG("~ts~n", ["启动行为日志节点成功"]),
                    net_kernel:connect_node(NodeName2)
            end
    end,
    ok.

%% 根据网关配置获取网关机器的内网机器IP列表
get_gateway_lan_host_list(GatewayConfig) ->
    lists:foldl(
      fun({IP, _Domain, _PortList}, Acc) ->
              case lists:member(IP, Acc) of
                  true ->
                      Acc;
                  false ->
                      [IP | Acc]
              end
      end, [], GatewayConfig).


%% 启动A机的安全沙箱处理节点
start_security_node(NodeHost) ->
    NodeName = lists:concat(["mgees@", NodeHost]),
    NodeNameAtom = erlang:list_to_atom(NodeName), 
    net_kernel:connect_node(NodeNameAtom),
    case lists:member(NodeNameAtom, erlang:nodes()) of
        true ->
            ?SYSTEM_LOG("~p ~ts", [NodeHost, "安全沙箱处理节点已经启动"]),
            ignore;
        false ->
            CodePath = get_path(security),
            %% 启动A机的security，manager节点一定要在A机启动
            %% 核绑定在CPU 1上
            Command = get_start_command(1, NodeHost, NodeName, "mgees", CodePath, ""),
            ?SYSTEM_LOG("~ts~n~s~n", ["准备启动安全沙箱处理节点", Command]),
            erlang:open_port({spawn, Command}, [stream]),
            receive 
                {security_node_up, SecurityNodeName2} ->
                    ?SYSTEM_LOG("~ts~n", ["安全沙箱节点启动成功"]),
                    net_kernel:connect_node(SecurityNodeName2)
            end
    end,
    ok.

do_common_config_check() ->
    case common_config_dyn:find(common, master_host) of
        [_MasterHost] ->
            ok;
        _ ->
            erlang:throw({error, "common.config缺少master_host配置项"})
    end,
    case common_config_dyn:find(common, gateway) of
        [] ->
            erlang:throw({error, "common.config缺少gateway配置"});
        _ ->
            ok
    end,
    case common_config_dyn:find(common, map) of
        [] ->
            erlang:throw({error, "common.config缺少map配置"});
        _ ->
            ok
    end,
    ok.
            
