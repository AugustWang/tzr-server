%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Callbacks for the mgeeweb application.

-module(mgeeweb_app).
-author('author <author@example.com>').

-behaviour(application).
-export([start/2, stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for mgeeweb.
start(_Type, _StartArgs) ->
	mgeeweb_deps:ensure(),
	{ok, SupPid} = mgeeweb_sup:start_link(),
	lists:foreach(
	  fun ({Msg, Thunk}) ->
			   io:format("starting ~-32s ...", [Msg]),
			   Thunk(),
			   io:format("done~n");
		 ({Msg, M, F, A}) ->
			  io:format("starting ~-20s ...", [Msg]),
			  apply(M, F, A),
			  io:format("done~n")
	  end,
	  [
	   {"mgeeweb - Logger",
            fun() ->
                    {ok, LogPath} = application:get_env(log_path),
                    error_logger:add_report_handler(common_logger_h, LogPath),
                    {ok, LogLevel} = application:get_env(log_level),
                    common_loglevel:set(LogLevel)
            end},
           {"Common Config init",
            fun() ->
                    common_config_dyn:init(common)
            end},
           {"Mysql Server",
               fun() ->
                       mod_mysql:start()
               end},
           {"Start WebDB Data",
               fun() ->
                       mod_web_db_service:start()
               end},
           {"Write File",
            fun() ->
                    file:write_file("/data/tzr/server/ebin/mgeeweb/run.lock", "started")
            end}
	  ]
         ), 
    {ok, SupPid}.

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for mgeeweb.
stop(_State) ->
	file:delete_file("/data/tzr/server/ebin/mgeeweb/run.lock"),
    ok.


%%
%% Tests
%%
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).
-endif.
