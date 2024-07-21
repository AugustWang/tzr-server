%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2011, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 23 Jan 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_reloader).

%% API
-export([
         do_all_node/0,
         reload_all/0,
         stop_all_line/0,
         stop_all_application/0,
         start_all_application/0,
         reload_module/1,
         stop_all/0,
         reload_config/1,
         get_map_master_node/0,
         reload_shop/0,
         reload_cu_xiao_shop/0
        ]).

get_map_master_node() ->
    [MapConfig] = common_config_dyn:find_common(map),
    {MasterMapHost, _NSlave} = erlang:hd(MapConfig),
    common_tool:list_to_atom(lists:concat(["mgeem@", MasterMapHost])).

reload_shop() ->
    lists:foreach(fun(Node) -> rpc:call(Node, common_config_dyn, init, [shop_shops]) end, [node() |nodes()]),
    lists:foreach(
      fun(Node) ->
              rpc:call(Node, mod_shop, init, [])
      end, common_debugger:get_all_map_node()).

reload_cu_xiao_shop() ->
    lists:foreach(fun(Node) -> rpc:call(Node, common_config_dyn, init, [shop_shops]) end, [node() |nodes()]),
    lists:foreach(
      fun(Node) ->
              rpc:call(Node, mod_shop, reload_cu_xiao, [])
      end, common_debugger:get_all_map_node()).

stop_all() ->
    %% 首先停止erlangweb
    stop_erlang_web(),
    stop_all_line(),
    stop_map(),
    stop_world(),
    stop_login(),
    stop_chat(),
    timer:sleep(3000),
    stop_db(),
    stop_behavior(),
    stop_security().

stop_security() ->
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "mgees@") =:= 1 of
                  true ->
                      rpc:call(Node, init, stop, []);
                  false ->
                      ignore
              end
      end, [erlang:node() | erlang:nodes()]).

stop_behavior() ->
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "mgeeb@") =:= 1 of
                  true ->
                      rpc:call(Node, init, stop, []);
                  false ->
                      ignore
              end
      end, [erlang:node() | erlang:nodes()]).

stop_db() ->
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "mgeed@") =:= 1 of
                  true ->
                      %% 停止之前先dump log
                      rpc:call(Node, mnesia, dump_log, []),
                      timer:sleep(1000),
                      rpc:call(Node, mgeed_ctl, process, [["stop"]]);
                  false ->
                      ignore
              end
      end, [erlang:node() | erlang:nodes()]).


stop_login() ->
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "mgeel@") =:= 1 of
                  true ->
                      rpc:call(Node, mgeel_ctl, process, [["stop"]]);
                  false ->
                      ignore
              end
      end, [erlang:node() | erlang:nodes()]).


stop_chat() ->
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "mgeec@") =:= 1 of
                  true ->
                      rpc:call(Node, mgeec_ctl, process, [["stop"]]);
                  false ->
                      ignore
              end
      end, [erlang:node() | erlang:nodes()]).

stop_world() ->
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "mgeew@") =:= 1 of
                  true ->
                      rpc:call(Node, mgeew_ctl, process, [["stop"]]);
                  false ->
                      ignore
              end
      end, [erlang:node() | erlang:nodes()]).


stop_map() ->
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "mgeem@") =:= 1 of
                  true ->
                      rpc:call(Node, mgeem_ctl, process, [["stop"]]);
                  false ->
                      ignore
              end
      end, [erlang:node() | erlang:nodes()]).

stop_erlang_web() ->
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "mgeeweb@") =:= 1 of
                  true ->
                      rpc:call(Node, init, stop, []);
                  false ->
                      ignore
              end
      end, [erlang:node() | erlang:nodes()]).

reload_config(File) ->
    lists:foreach(fun(Node) -> rpc:call(Node, common_config_dyn, init, [File]) end, [node() |nodes()]).

reload_module(Module) ->
    lists:foreach(fun(Node) -> rpc:call(Node, c, l, [Module]) end, [node() |nodes()]).

do_all_node() ->
    lists:foreach(
      fun(Node) ->
              ok = rpc:call(Node, common_reloader, reload_all, [])
      end, [erlang:node() | erlang:nodes()]).


reload_all() ->
    lists:foreach(
      fun({Module, FileName}) ->
             case erlang:is_list(FileName) andalso Module =/= common_reloader of
                 true ->
                     code:soft_purge(Module),
                     code:load_file(Module);
                 false ->
                     ignore
             end
      end, code:all_loaded()).

%% 停止所有分线结点
stop_all_line() ->
    file:write_file("/data/tzr/web/platform.lock", "游戏维护中，详情请查看官网", [binary]),
    AllNodes = [erlang:node() | erlang:nodes()],
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "mgeeg") =:= 1 of
                  true ->
                      rpc:call(Node, mgeeg_ctl, process, [["stop"]]);
                  false ->
                      ignore
              end
      end, AllNodes).


start_all_application() ->
    AllNodes = [erlang:node() | erlang:nodes()],
    %%首先是启动地图
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "map@") =:= 1 of
                  true ->
                      ok = rpc:call(Node, application, start, [mgeem]),
                      ok = rpc:call(Node, mgeem_distribution, start_for_hot_reload, []);
                  false ->
                      ignore
              end
      end, AllNodes),
    ok.
                      

stop_all_application() ->
    AllNodes = [erlang:node() | erlang:nodes()],
    %% 从世界开始停止
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "world") =:= 1 of
                  true ->
                      ok = rpc:call(Node, application, stop, [mgeew]);
                  false ->
                      ignore
              end
      end, AllNodes),
    %% 接着是地图
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "map@") =:= 1 of
                  true ->
                      ok = rpc:call(Node, mgeem_clear, stop, []);
                  false ->
                      ignore
              end
      end, AllNodes),
    %% 停止所有地图结点的mgeem app，不停止地图结点和mnesia
    lists:foreach(
      fun(Node) ->
              Node2 = erlang:atom_to_list(Node),
              case string:str(Node2, "map") =:= 1 of
                  true ->
                      ok = rpc:call(Node, application, stop, [mgeem]);
                  false ->
                      ignore
              end
      end, AllNodes),
    ok.
    

