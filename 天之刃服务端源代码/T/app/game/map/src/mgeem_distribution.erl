%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc 地图分布式启动主模块 
%%%
%%% @end
%%% Created : 26 Jun 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mgeem_distribution).

%% API
-export([
         start/0,
         start_slave/2,
         start_slave_master/0,
         start_maps/0,
         start_for_hot_reload/0,
         do_start_master_independency/0
        ]).

-include("mgeem.hrl").


%%启动
start() ->
    do_start_master().


start_for_hot_reload() ->
    mgeem:start(),
    Tables = db_loader:define_table_mapping(map),
    lists:foreach(
      fun(T) ->
              case T of
                  {Tab_Disk,Tab_Ram} ->
                      db_subscriber:start( mgeem_sup,Tab_Ram,Tab_Disk );
                  {Tab_Disk,Tab_Ram, _} ->
                      db_subscriber:start( mgeem_sup,Tab_Ram,Tab_Disk )
              end
      end, Tables),
    start_maps().


%% 第一个启动的地图结点是真正的master
do_start_master() ->
    {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
    net_kernel:connect_node(erlang:list_to_atom(MasterNodeTmp)),
    timer:sleep(2000),    
    error_logger:add_report_handler(common_logger_h, ""),
    common_loglevel:set(3),
    io:format("~p~n", [nodes()]),
    global:send(manager_node, {map_init, erlang:self()}),
    receive 
        {map_config, MasterMapHost} ->
            do_start_master2(MasterMapHost),
            ok
    after 3000 ->
            ?SYSTEM_LOG("~ts~n", ["等待manager结点发送config配置超时"]),
            erlang:exit(wait_for_config_from_manager_timeout)
    end.

%% 独立启动模式，可能是live模式或者 mgectl start mgeem
do_start_master_independency() ->    
    {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
    net_kernel:connect_node(erlang:list_to_atom(MasterNodeTmp)),
    timer:sleep(2000),    
    ?SYSTEM_LOG("~ts~n", ["准备以独立启动方式启动地图节点"]),
    error_logger:add_report_handler(common_logger_h, ""),
    common_loglevel:set(3),
    common_config_dyn:init(common),
    %% 分析MasterMapHost信息
    [MapConfig] = common_config_dyn:find_common(map),
    [_ | MapConfig2] = MapConfig,
    do_start_master2(MapConfig2).
    

do_start_master2(Slaves) ->
    global:register_name(mgeem_distribution, erlang:self()),
    application:start(sasl),
    gen_server:start({global, pool_master}, pool, [], []),
    ?SYSTEM_LOG("start map pool succfull.~n", []),
    ?SYSTEM_LOG("prepare to join mnesia group ... ~n", []),
    common_db:join_group(),
    ?SYSTEM_LOG("join mnesia group done.~n", []),
    timer:sleep(2000),
    io:format("prepare to init map table ...~n", []),
    db_loader:init_map_tables(),
    ?SYSTEM_LOG("init map table done.~n", []),
    ?SYSTEM_LOG("prepare to load all map tables~n", []),
    db_loader:load_map_whole_tables(),
    error_logger:delete_report_handler(common_logger_h),
    ?SYSTEM_LOG("~ts~n" ,["准备启动主节点map application"]),
    %% 先启动mgeem
    mgeem:start(),
    ?SYSTEM_LOG("~ts~n" ,["启动主节点map application完成"]),
    Tables = db_loader:define_table_mapping(map),
    lists:foreach(
      fun(T) ->
              case T of
                  {Tab_Disk,Tab_Ram} ->
                      db_subscriber:start( mgeem_sup,Tab_Ram,Tab_Disk );
                  {Tab_Disk,Tab_Ram, _} ->
                      db_subscriber:start( mgeem_sup,Tab_Ram,Tab_Disk )
              end
      end, Tables),
    %% 开始启动slave机器的erlang结点
    {ok, Paths} = init:get_argument(pa),
    Path = lists:foldl(
          fun([Path], Acc) ->
                  Acc ++ " -pa " ++ Path ++ " "
          end, [], Paths),
    
    %% 首先是开slave，其次是在每个slave上面开二级slave
    %% mgeem -> 在每台负载机上开slave -> 每个slave根据本机的CPU数量创建一定数量的Beam进程
    ?SYSTEM_LOG("~ts~n~p~n", ["准备启动map负载结点", Slaves]),
    lists:foldl(
      fun({SlaveIP, N}, Index) ->
              NodeName = common_tool:list_to_atom(lists:concat(["map_slave_master_", Index, "@", SlaveIP])),              
              Command = lists:concat(["rsh ", SlaveIP, " taskset -c 0", 
                                      " erl -smp disable  +h 10240 -detached -noinput -s mgeem_distribution start_slave_master -name ", NodeName, Path, 
                                      " -master_node ", erlang:node(),
                                      " -setcookie ", erlang:get_cookie()]),
              erlang:open_port({spawn, Command}, [stream]),
              receive 
                  {slave_master_started, _} ->
                      ok = rpc:call(NodeName, mgeem_distribution, start_slave, [SlaveIP, N]),
                      pool:attach(NodeName),
                      do_receiver_slave(),
                      Index + 1
              after 15000 ->
                      timer:sleep(11000),
                      erlang:exit(start_slave_master_timeout)
              end
      end, 1, Slaves),    
    ?SYSTEM_LOG("~ts~n", ["地图负载结点启动完成"]),
    {ok, [[SlaveNumTmp]]} = init:get_argument(slave_num),
    case erlang:system_info(logical_processors) >= 8 of
        true ->
            SlaveNumTmp2 = SlaveNumTmp;
        false ->
            SlaveNumTmp2 = 0
    end,
    {ok, [[MasterHost]]} = init:get_argument(master_host),
    ?SYSTEM_LOG("~ts~n", ["准备启动地图主结点的负载结点"]),
    erlang:spawn(fun() -> start_slave(MasterHost, common_tool:to_integer(SlaveNumTmp2)) end),
    do_receiver_slave(),    
    ?SYSTEM_LOG("~ts~n", ["启动地图主结点的负载结点完成"]),
    ?SYSTEM_LOG("~ts~n", ["准备创建地图"]),
    start_maps(),
    ?SYSTEM_LOG("~ts~n", ["创建地图完成!"]),
    global:send(manager_node, {map_node_up, erlang:node()}),
    ok.

start_maps() ->
    MapIDListOfPreCreate = [10500,11000, 11001, 12000, 12001, 13000, 13001, 11100, 12100, 13100, 11101, 12101, 13101, 11102, 12102, 13102,
                           11103, 12103, 13103, 11104, 12104, 13104, 11105, 12105, 13105],
    lists:foldl(
      fun(SlaveNodeName, Index) ->
              case Index > erlang:length(MapIDListOfPreCreate) of
                  true ->
                      ignore;
                  false ->
                      rpc:call(SlaveNodeName, mod_map_loader, create_map, [lists:nth(Index, MapIDListOfPreCreate)])
              end,
              Index + 1
      end, 1, pool:get_nodes()),
    ?SYSTEM_LOG("~ts~n", ["地图预创建完成"]),
    %% 开始创建地图，前面已经创建好几张压力较大的地图了
    mod_map_loader:auto_create_maps(),    
    mod_map_loader:create_family_maps(),
    mod_map_loader:auto_create_maps(), 
    global:send(manager_node, {map_node_up, erlang:node()}),
    ?SYSTEM_LOG("start map distribution done ~n", []),
    ok.

do_receiver_slave() ->
    receive 
        {slave_started, NodeName} ->
            ok = rpc:call(NodeName, mgeem, start, []),
            ?SYSTEM_LOG("~ts:~p~n", ["正在启动节点application", NodeName]),
            pool:attach(NodeName),
            do_receiver_slave();
        slave_started_done ->
            ok
    after 8000 ->
            erlang:exit(start_slave_timeout)
    end.

start_slave_master() ->
    {ok, [[MasterNodeTmp]]} = init:get_argument(master_node),
    MasterNode = erlang:list_to_atom(MasterNodeTmp),
    net_kernel:connect_node(MasterNode),
    erlang:process_flag(trap_exit, true),
    erlang:monitor_node(MasterNode, true),
    timer:sleep(2000),
    global:send(mgeem_distribution, {slave_master_started, erlang:node()}),
    loop(MasterNode).

loop(MasterNode) ->
    receive 
        {nodedown, MasterNode} ->
            init:stop();
        _ ->
            loop(MasterNode)
    end.


start_slave(IP, SlaveNum) ->   
    {ok, Paths} = init:get_argument(pa),      
    Path = lists:foldl(
          fun([Path], Acc) ->
                  Acc ++ " -pa " ++ Path ++ " "
          end, [], Paths),
    global:register_name(lists:concat(["master_", erlang:node()]), erlang:self()),
    mgeem:start(),
    lists:foldl(
      fun(Number, Index) ->
              NodeName = erlang:list_to_atom(lists:concat(["map_slave_", Number, "@", IP])),
              Command = lists:concat(["taskset -c ", Number, 
                                      " erl -smp disable  +h 10240 -detached -noinput -name ", NodeName, Path, 
                                      " -s mgeem_slave ",
                                      " -master_node ", erlang:node(),
                                      " -setcookie ", erlang:get_cookie()]),
              erlang:open_port({spawn, Command}, [stream]),
              receive
                  {slave_started, NodeName} ->
                      global:send(mgeem_distribution, {slave_started, NodeName})
              after 8000 ->
                      erlang:exit(start_slave_timeout)
              end,
              Index + 1
      end, 1, lists:seq(1, SlaveNum)), 
    %% 通知本节点的所有slave都已经启动了
    global:send(mgeem_distribution, slave_started_done),
    ok.
