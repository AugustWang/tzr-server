-module(dev_compile).
-export([start/0]).
-define(COMPILE_ARGS, [
    {i, "/data/mtzr/app/game/map/include/"},
    {i, "/data/mtzr/hrl"},
    {outdir, "/data/tmp"}
]).
start() ->
    code:add_path("/data/tzr/server/ebin/map"),
    code:add_path("/data/tzr/server/ebin/common"),
    T1 = erlang:now(),
    lists:foreach(fun(Module) ->
        case filename:extension(Module) of
            ".erl" ->
                Result = compile:file(lists:concat([Module]), ?COMPILE_ARGS),
                io:format("~w~n", [Result]);
            _ ->
                ignore
        end
    end, list_dir("/data/mtzr/app/game/map/src/")),
    T2 = erlang:now(),
    io:format("~w---~w~n", [T1, T2]).

list_dir(File) ->
    case file:list_dir(File) of
        {ok, FileList} ->
            lists:foldl(fun(File2, Result) ->
                Result ++ list_dir(lists:concat([File, "/", File2]))
            end, [], FileList);
        _ ->
            [File]
    end.