-module(common_update).
-export([update_collect_config/0]).

update_collect_config() ->
    lists:foreach(
      fun(Node) ->
              rpc:call(Node,mod_map_collect,update_ets,[]),
              rpc:call(Node,common_config_dyn,reload,[collect_base]),
              rpc:call(Node,common_config_dyn,reload,[collect_point])
      end,common_debugger:get_all_map_node()),
    lists:foreach(
      fun(GlobalName) -> 
              global:send(GlobalName,{mod_map_collect,update}) 
      end,common_debugger:get_all_map_pid()).
