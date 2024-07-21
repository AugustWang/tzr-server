%%%-------------------------------------------------------------------
%%% @author xiaosheng
%%% @doc 已经废弃
%%%-------------------------------------------------------------------
-module(loader).

%% gen_server callbacks
-export([start/0]).
-define(CORRECT_VALUE_MAP, 10000000).
%%%===================================================================
%%% API
%%%===================================================================


%%从mcm文件中载入地图数据
start() ->
    ets:new(map_data, [bag, public, named_table]),
    MapConfigDir = "../../config/map/mcm/",
    ExtName = ".mcm",
    %%列出文件夹中所有的地图文件
    try file:list_dir(MapConfigDir) of
        {ok, FileList} ->

            lists:foreach(
              fun(FileName) ->
                      case filename:extension(FileName) of
                          ExtName ->
                              io:format("====================SUCCESS=====================~n"),
                              io:format("map file loaded:~p~n", [lists:flatten(FileName)]),
                              io:format("====================SUCCESS=====================~n"),
                              loadMapData(MapConfigDir , FileName);
                          _ ->
                              ok
                      end
              end, FileList),

            write_sql_file();
        {error, Reason} ->
            io:format("====================ERROR=====================~n"),
            io:format("read map data file failed:~p~n", [Reason]),
            io:format("====================ERROR=====================~n")
    catch
        _:Reason_2 ->
            io:format("====================ERROR=====================~n"),
            io:format("list map dir failed:~p~n", [Reason_2]),
            io:format("====================ERROR=====================~n")

    end.

loadMapData(MapConfigDir , FileName) ->
    
    FullFileName = MapConfigDir ++ FileName,
    {ok, AllBin} = file:read_file(FullFileName),
    AllBin2 = zlib:uncompress(AllBin),

    <<MapID:32, _MapType:32, _:256, _:256, TileNumber:32, ElementNum:32,  _JumpPointNum:32, _OffsetX:32, _OffsetY:32,
      _TW:32, _TH:32, Data2/binary>> = AllBin2,

    DataTileLength = 288 * TileNumber,
    <<_DataTile:DataTileLength/bitstring, DataRemain/binary>> = Data2,

    loadMapElementTile(DataRemain, ElementNum ,MapID).

loadMapElementTile(RemainData, 0, _MapID) ->
    RemainData;
loadMapElementTile(DataBin, EnterPointlength, MapID) ->
    << ID:32, IndexTX:32, IndexTY:32, Type:32, Link:32, DataRemain/bitstring>> = DataBin,
    LinkLen = 8*Link,
    <<_:LinkLen/bitstring, DataRemain2/bitstring>> = DataRemain,
    case Type of
        %%出生点
        3 ->
           ignore;
        4 ->
            insert_sql(MapID, Type, ID, IndexTX, IndexTY);
        5 when ID > 0 ->
            insert_sql(MapID, Type, ID, IndexTX, IndexTY);
        _ ->
            ignore
    end,
    loadMapElementTile(DataRemain2, EnterPointlength - 1, MapID).

insert_sql(MapId, DataType, DataId, X, Y) ->
    Sql = lists:concat([MapId, ",", DataType, ",", DataId, ",", X, ",", Y]),
    ets:insert(map_data, {Sql}),
    io:format("Insert MapId:~p, DataType:~p, DataId:~p, X:~p, Y:~p~n", [MapId, DataType, DataId, X, Y]).
write_sql_file() ->
    List = ets:tab2list(map_data),
    Sql = "TRUNCATE TABLE `t_Mapdata`;\nINSERT INTO `t_Mapdata` (`map_id`, `data_type`, `data_id`, `x`, `y`) VALUES \n(",
    Sql2 = join_sql(List),
    Sql3 = ");",
    Sql4 = Sql ++ Sql2 ++ Sql3,

    File = "./mapdata.sql",
    try
        file:write_file(File, Sql4),
        io:format("sql succ write to :~p~n", [File])
    catch
        _:Reason ->
            io:format("sql faile write to :~p ~n Reason: ~p ~n", [File, Reason])
    end,
            
    c:q().

join_sql(List) ->
    do_join(List, [], "),\n(").

%% join_hrl(List) ->
%%     do_join(List, [], "}.\n{".

do_join([], Result, Sep) ->
    string:join(Result, Sep);
do_join([{Sql}|List], Result, Sep) ->
    Result2 = [Sql|Result],
    do_join(List, Result2, Sep).
