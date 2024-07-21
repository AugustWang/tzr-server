%%%-------------------------------------------------------------------
%%% @author QingliangCn <qing.liang.cn@gmail.com>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created :  5 Jun 2010 by QingliangCn <qing.liang.cn@gmail.com>
%%%-------------------------------------------------------------------
-module(mod_map_loader).

-include("mgeem.hrl").


-behaviour(gen_server).

%%%===================================================================
%%% Macro
%%%===================================================================
-define(PLAYGROUND_ITEM, 1).
-define(ENTER_POINT, 2).
-define(LIVE_POINT, 3).
-define(NPC_POINT, 4).
-define(MONSTER_POINT, 5).
-define(COLLECTION_POINT, 6).


%%%===================================================================
%%% API
%%%===================================================================
-export([
         start/0,
         start_link/0,
         auto_create_maps/0,
         create_warofcity_maps/0,
         create_map/1,
         create_family_maps/0
        ]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    {ok, _} = supervisor:start_child(mgeem_sup,
                                     {?MODULE,
                                      {?MODULE, start_link, []},
                                      transient, brutal_kill, worker, [?MODULE]}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


%%自动载入地图
auto_create_maps() ->
    Maps = ets:tab2list(?ETS_MAPS),
    lists:foreach(
      fun({MapID, Type}) ->
              case Type =:= 0 orelse MapID =:= 10700  of
                  false ->
                      ignore;
                  _ ->
                      case MapID =:= 0 of
                          true ->
                              ignore;
                          false ->
                              mgeem_router:create_map_if_not_exist(MapID)
                      end
              end
      end, Maps).

create_map(MapID) ->
    MName = common_map:get_common_map_name(MapID),
    mgeem_router:do_start_map_distribution(MapID, MName).

create_family_maps() ->
	FamilyList = db:dirty_match_object(db_family_p, #p_family_info{enable_map=true, _='_'}),
	lists:foreach(
		fun(#p_family_info{family_id=FamilyID, hour=H, minute=M, level=Level}) ->
                        case FamilyID > 0 andalso Level > 0 of
                            true ->
                                mod_map_copy:create_family_map_copy(FamilyID, common_tool:today(H,M,0));
                            false ->
                                ignore
                        end
		end, FamilyList).
		
	
create_warofcity_maps() ->
    Maps = [11000, 11001, 11101, 11102, 11103, 11104, 11100,
            12000, 12001, 12101, 12102, 12103, 12104, 12100,
            13000, 13001, 13101, 13102, 13103, 13104, 13100
           ],
    MapIDWarOfCity = 10301,
    lists:foreach(
      fun(MapID) ->
              MapName = common_map:get_warofcity_map_name(MapID),
              mgeem_router:create_copy_map(MapIDWarOfCity, MapName)
      end, Maps).
    


init([]) ->
    %%保存各个地图的详细信息
    ets:new(?ETS_IN_MAP_DATA, [protected, bag, named_table]),
    %%保存各个地图中的NPC信息
    ets:new(?ETS_MAP_NPC, [protected, set, named_table]),
    %%保存各个地图中的怪物信息
    ets:new(?ETS_MAP_MONSTER, [protected, bag, named_table]),
    %%地图ID列表
    ets:new(?ETS_MAPS, [protected, set, named_table]),
    %%保存各个地图上篝火的信息
    ets:new(?ETS_BONFIRES, [protected, set, named_table]),
    %%缓存采集点的数据
    ets:new(?ETS_COLLECT_POINTS, [protected, bag, named_table]),
    %%载入地图数据
    loadMapData(),
    {ok, none}.


handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%从mcm文件中载入地图数据
loadMapData() ->
    MapConfigDir = common_config:get_map_config_dir(),
    ExtName = ".mcm",
    %%列出文件夹中所有的地图文件
    try file:list_dir(MapConfigDir) of
        {ok, FileList} ->
            lists:foreach(
              fun(FileName) ->
                      case filename:extension(FileName) of
                          ExtName ->
                              loadMapDataFrom(MapConfigDir , FileName);
                          _ ->
                              ok
                      end
              end, FileList),
            DataCollectPoints = ets:tab2list(?ETS_COLLECT_POINTS),
            mod_map_collect:init_collect_points(DataCollectPoints),
            ets:delete(?ETS_COLLECT_POINTS),
            ?DEV("~ts", ["读取地图数据完成"]);
        {error, Reason} ->
            ?ERROR_MSG("MAP Router loadMapData error: ~w, from dir: ~w", [Reason, MapConfigDir])
    catch
        _ -> ?ERROR_MSG("MAP Router loadMapData error, from dir: ~w", [MapConfigDir])      
    end.

loadMapDataFrom(MapConfigDir , FileName) ->
    FullFileName = MapConfigDir ++ FileName,
    {ok, AllBin} = file:read_file(FullFileName),
    ?DEV(" ~w", [ MapConfigDir ++ FileName]),
    AllBin2 = zlib:uncompress(AllBin),
    <<MapID:32, MapType:32, _MapName:256, _:256, TileRow:32, TileCol:32, ElementNum:32, JumpPointNum:32, OffsetX:32, OffsetY:32,
      TW:32, TH:32, Data2/binary>> = AllBin2,
    TileNumber = TileRow * TileCol,
    OffsetX2 = OffsetX - ?CORRECT_VALUE_MAP,
    OffsetY2 = OffsetY - ?CORRECT_VALUE_MAP,
    ?DEV("mod_map_loader, loadMapDataFrom: ~w", [{MapID, TileRow, TileCol, OffsetX2, OffsetY2, TW, TH}]),
    ets:new(?ETS_MAP_DATA_TMP, [set, private, named_table]),
    ets:new(?ETS_MAP_DATA_STALL, [bag, private, named_table]),
    ets:new(?ETS_MAP_DATA_READO, [bag, private, named_table]),
    %%每个格子包括 x y z type stall等 一共9个int 288字节
    DataTileLength = 8 * TileNumber,
    <<DataTile:DataTileLength/bitstring, DataRemain/binary>> = Data2,
    %%解析格子数据
    loadMapDataTile(DataTile, 0, 0, TileCol),
    %%解析出生点、怪物点、摆摊点等信息
    DataRemain2 = loadMapElementTile(DataRemain, ElementNum ,MapID),
    %%解析跳转点信息
    loadMapJumpTile(DataRemain2, JumpPointNum, MapID),
    Data = ets:tab2list(?ETS_MAP_DATA_TMP),
    DataStall = ets:tab2list(?ETS_MAP_DATA_STALL),
    DataReado = ets:tab2list(?ETS_MAP_DATA_READO),
    DataBonfire  = ets:tab2list(?ETS_BONFIRES),
    common_config_dyn:load_gen_src(map_bonfire,DataBonfire),
    ets:delete(?ETS_MAP_DATA_TMP),
    ets:delete(?ETS_MAP_DATA_STALL),
    ets:delete(?ETS_MAP_DATA_READO),
    ets:insert(?ETS_IN_MAP_DATA, {MapID, {MapID, TW, TH, OffsetX2, OffsetY2, TileRow-1, TileCol-1, Data}}), 
    ?DEV("~ts:~w", ["地图副本类型", MapType]),
    ets:insert(?ETS_IN_MAP_DATA, {{stall, MapID}, DataStall}),
    ets:insert(?ETS_IN_MAP_DATA, {{reado, MapID}, DataReado}),
    ets:insert(?ETS_MAPS, {MapID, MapType}).

%%解析格子信息：安全区或者非安全区，不在这里的格子统统都是不可走的
loadMapDataTile(<<>>, _TX, _TY, _TileCol) ->
    ok;
loadMapDataTile(DataBin, TX, TY, TileCol) ->
    %% 每个格子由8位表示，各位分别代表
    %% 预留，竞技区、摆摊区、绝对安全区、安全区、阻挡区、半透、是否存在
    <<_YuLiu:1, Arena:1, Sell:1, AllSafe:1, Safe:1, _Run:1, _Alpha:1, Exist:1, DataRemain/binary>> = DataBin,
    if Exist =:= 1 ->
            if Safe =:= 1 andalso AllSafe =:= 1 ->
                    ets:insert(?ETS_MAP_DATA_TMP, {{TX, TY}, absolute_safe});
               Safe =:= 1  ->
                    ets:insert(?ETS_MAP_DATA_TMP, {{TX, TY}, safe});
               true ->
                    ets:insert(?ETS_MAP_DATA_TMP, {{TX, TY}, not_safe})
            end,
            if Sell =:= 1 ->
                    ets:insert(?ETS_MAP_DATA_STALL, {TX, TY});
               true ->
                    ignore
            end,
            if Arena =:= 1 ->
                    ets:insert(?ETS_MAP_DATA_READO, {TX, TY});
               true ->
                    ignore
            end;
       true ->
            ignore
    end,
    if TY + 1 >= TileCol ->
            loadMapDataTile(DataRemain, TX+1, 0, TileCol);
       true ->
            loadMapDataTile(DataRemain, TX, TY+1, TileCol)
    end.

loadMapElementTile( RemainData, 0, _MapID) ->
    RemainData;
loadMapElementTile(DataBin, EnterPointlength, MapID) ->
    << ID:32, IndexTX:32, IndexTY:32, Type:32, Link:32, DataRemain/bitstring>> = DataBin,
    LinkLen = 8*Link,
    <<_:LinkLen/bitstring, DataRemain2/bitstring>> = DataRemain,
    case Type of
        %%出生点
        ?LIVE_POINT ->
            %%Rtn = db:dirty_write(?DB_BORN_POINT, #r_born_point{mapid=MapID, tx=IndexTX, ty=IndexTY}),
            ets:insert(?ETS_IN_MAP_DATA, {{born_point, MapID}, {IndexTX, IndexTY}}),
            ok;
            %%?DEBUG("~ts ~w", ["写出生点结果", Rtn]);
        %%NPC
        ?NPC_POINT ->
            check_ncp_id(ID,MapID),
            ets:insert(?ETS_MAP_NPC, {{MapID, IndexTX, IndexTY}, ID}),
            ets:insert(?ETS_MAP_NPC, {ID, {MapID, IndexTX, IndexTY}}),
            ets:insert(?ETS_MAP_NPC, {MapID, IndexTX, IndexTY});
        %%怪物
        ?MONSTER_POINT when ID > 0 ->
            check_monster_id(ID,MapID),
            ets:insert(?ETS_MAP_MONSTER, {{MapID, IndexTX, IndexTY}, ID}),
            ets:insert(?ETS_MAP_MONSTER, {ID, {IndexTX, IndexTY}}),
            ets:insert(?ETS_MAP_MONSTER, {MapID, IndexTX, IndexTY});
        %%采集
        ?COLLECTION_POINT ->
            ets:insert(?ETS_COLLECT_POINTS, {MapID, {ID, IndexTX,IndexTY}});
        _ when ID =:= 10300222 ->
            ets:insert(?ETS_BONFIRES, {MapID,{IndexTX,IndexTY}});
        _ ->
            ignore
    end,
    loadMapElementTile( DataRemain2, EnterPointlength - 1, MapID).

check_monster_id(MonsterID,MapId)->
    if
        MonsterID =:= 0->
            ?ERROR_MSG("check_ncp_id error,NpcId=~w,MapId=~w",[MonsterID,MapId]),
            error;
        true->
            ok
    end.

%%@doc 检查NPC的配置是否正确
check_ncp_id(NpcId,MapId)->
    NpcFaction = get_npc_faction_id(NpcId),
    MapFaction = get_map_faction_id(MapId),
    if
        NpcId =:= 0->
            ?ERROR_MSG("check_ncp_id error,NpcId=~w,MapId=~w",[NpcId,MapId]),
            error;
        NpcFaction =:= 0 ->
            ok;
        MapFaction =:= 0 ->
            ok;
        MapFaction =:= NpcFaction ->
            ok;
        true->
            ?ERROR_MSG("check_ncp_id error,NpcId=~w,MapId=~w",[NpcId,MapId]),
            error
    end.

get_npc_faction_id(NpcId) when is_integer(NpcId)->
    NpcId div 1000000 rem 10.
get_map_faction_id(MapId)->
    MapId div 1000 rem 10.


loadMapJumpTile( _, 0, _MapID) ->
    ok;
loadMapJumpTile( DataBin, EnterPointlength, MapID) ->
    <<_ID:32, IndexTX:32, IndexTY:32,TargetMapID:32, TIndexTX:32, 
      TIndexTY:32, _HW:32, _YL:32, _WL:32, _MinLevel:32, _MaxLevel:32, Link:32, DataRemain/bitstring>> = DataBin,
    LinkLen = 8*Link,
    <<_:LinkLen/bitstring, DataRemain2/bitstring>> = DataRemain,
    ets:insert(?ETS_IN_MAP_DATA, 
               {{MapID, TargetMapID}, {IndexTX, IndexTY, TIndexTX, TIndexTY}}),
    loadMapJumpTile(DataRemain2, EnterPointlength - 1, MapID).
