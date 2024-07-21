%%%----------------------------------------------------------------------
%%%
%%% @copyright 2010 mgee (Ming Game Engine Erlang)
%%%
%%% @author odinxu, 2010-01-11
%%% @doc the mgee ctl module
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(mgeed_ctl).
-author('odinxu@gmail.com').

-export([start/0,
	 init/0,
	 process/1,
         mnesia_update/2
	 ]).

-include("mgeed.hrl").
-include("mgeed_ctl.hrl").

-spec start() -> no_return(). 
start() ->
    case init:get_plain_arguments() of
	[SNode | Args]->
	    %io:format("plain arguments is:~n~p", [AArgs]),
	    SNode1 = case string:tokens(SNode, "@") of
		[_Node, _Server] ->
		    SNode;
		_ ->
		    case net_kernel:longnames() of
			 true ->
			     SNode ++ "@" ++ inet_db:gethostname() ++
				      "." ++ inet_db:res_option(domain);
			 false ->
			     SNode ++ "@" ++ inet_db:gethostname();
			 _ ->
			     SNode
		     end
	    end,
	    Node = list_to_atom(SNode1),
            case erlang:length(Args) > 1 of
                true ->
                    [Command | Args2] = Args,
                    case Command of
                        %% 目前只能支持热更新的单独命令
                        "mnesia_update" ->
                            [Module | Method] = Args2,
                            Status = case rpc:call(Node, ?MODULE, mnesia_update, [Module, Method]) of
                                         {badrpc, Reason} ->
                                             ?PRINT("RPC failed on the node ~w: ~w~n",
                                                    [Node, Reason]),
                                             ?STATUS_BADRPC;
                                         S ->
                                             S
                                     end;
                         _ ->
                            ?PRINT("RPC failed on the node ~w: ~s~n",
                                                    [Node, "not support"]),
                            Status = ?STATUS_BADRPC
                    end;
                false ->
                    Status = case rpc:call(Node, ?MODULE, process, [Args]) of
                                 {badrpc, Reason} ->
                                     ?PRINT("RPC failed on the node ~p: ~p~n",
                                            [Node, Reason]),
                                     ?STATUS_BADRPC;
                                 S ->
                                     S
                             end
            end,
            halt(Status);
	_ ->
	    print_usage(),
	    halt(?STATUS_USAGE)
    end.

-spec init() -> 'ok'.
init() ->
    ets:new(mgeed_ctl_cmds, [named_table, set, public]),
    ets:new(mgeed_ctl_host_cmds, [named_table, set, public]),
    ok.


-spec process([string()]) -> integer().
process(["status"]) ->
    {InternalStatus, ProvidedStatus} = init:get_status(),
    ?PRINT("Node ~p is ~p. Status: ~p~n",
              [node(), InternalStatus, ProvidedStatus]),
    case lists:keysearch(mgeed, 1, application:which_applications()) of
        false ->
            ?PRINT("node is not running~n", []),
            ?STATUS_ERROR;
        {value,_Version} ->
            ?PRINT("node is running~n", []),
            ?STATUS_SUCCESS
    end;

process(["stop"]) ->
    init:stop(),
    ?STATUS_SUCCESS;

process(["restart"]) ->
    init:restart(),
    ?STATUS_SUCCESS;

process(["backup"]) ->
    {{Y, M, D}, {H, _, _}} = erlang:localtime(),
    [AgentName] = common_config_dyn:find(common, agent_name),
    [GameID] = common_config_dyn:find(common, game_id),
    File = lists:concat(["/data/database/backup/tzr/", AgentName, "_", GameID, "_", Y, M, D, ".", H]),
    ok = mnesia:backup(File),
    File2 = lists:concat([AgentName, "_", GameID, "_", Y, M, D, ".", H]),
    os:cmd(lists:concat(["cd /data/database/backup/tzr/; tar cfz ", File2, ".tar.gz ", File2, "; rm -f ", File2])),
    ?STATUS_SUCCESS.

%% 升级数据库
mnesia_update(Module, UpdateFunctionName) ->
    ModuleName = common_tool:list_to_atom(Module),
    common_reloader:reload_module(ModuleName),
    Func = common_tool:list_to_atom(UpdateFunctionName),
    case db:dirty_read(db_config_system_p, mnesia_db_version_prepare) of
        [] ->
            try
                mnesia:dirty_write(db_config_system_p, {mnesia_db_version_prepare, Func}),
                erlang:apply(ModuleName, Func, []),
                mnesia:dirty_write(db_config_system_p, {mnesia_db_version, Func}),
                mnesia:dirty_delete(db_config_system_p, mnesia_db_version_prepare)
            catch E:E2 ->
                    {{Y, M, D}, {H, I, _}} = erlang:localtime(),
                    [AgentName] = common_config_dyn:find(common, agent_name),
                    [GameID] = common_config_dyn:find(common, game_id),
                    File = lists:concat(["/data/logs/update_mnesia_", AgentName, "_", GameID, "_", Func, "_", Y, M, D, ".", H, I]),
                    file:write_file(File, erlang:term_to_binary({E, E2}))
            end;
        _ ->
            ignore
    end.

print_usage() ->
    CmdDescs =
	[{"status", "get node status"},
	 {"stop", "stop node"},
	 {"restart", "restart node"}
	 ] ++
	ets:tab2list(mgeed_ctl_cmds),
    MaxCmdLen =
	lists:max(lists:map(
		    fun({Cmd, _Desc}) ->
			    length(Cmd)
		    end, CmdDescs)),
    NewLine = io_lib:format("~n", []),
    FmtCmdDescs =
	lists:map(
	  fun({Cmd, Desc}) ->
		  ["  ", Cmd, string:chars($\s, MaxCmdLen - length(Cmd) + 2),
		   Desc, NewLine]
	  end, CmdDescs),
    ?PRINT(
      "Usage: mgeectl [--node nodename] command [options]~n"
      "~n"
      "Available commands in this node node:~n"
      ++ FmtCmdDescs ++
      "~n"
      "Examples:~n"
      "  mgeectl restart~n"
      "  mgeectl --node node@host restart~n"
      "  mgeectl vhost www.example.org ...~n",
     []).
