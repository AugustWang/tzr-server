%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% Created : 10 Aug 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mod_map_copy).

-include("mgeem.hrl").

%% API
-export([
         create_family_map_copy/1,
         create_family_map_copy/2,
         %% 根据地图ID，ServerNpcId创建逐鹿天下副本地图进程
         create_vwf_map_copy/2,
         %% 创建师门同心副本地图进程
         create_educate_map_copy/2,
         create_copy/2,
         async_create_copy/4
        ]).

-export([
         get_vwf_common_map_name/2
        ]).


%%创建地图副本
create_family_map_copy(FamilyID) ->
    create_family_map_copy(FamilyID, undefined).

create_family_map_copy(FamilyID, BonfireBurnTime) ->
    MAPProcessName = common_map:get_family_map_name(FamilyID),
    case global:whereis_name(MAPProcessName) of
        undefined ->
            MAPID = 10300,
            PID = pool:pspawn(mgeem_router, do_start_map_distribution, [MAPID, MAPProcessName]),
            Ref = erlang:monitor(process, PID),
            %%进程结束后判断是否地图进程正常创建了
            receive
                {'DOWN', Ref, process, _, _} ->
                    case global:whereis_name(MAPProcessName) of
                        undefined ->
                            error;
                        Pid ->
                            case (BonfireBurnTime=:=undefined) of
                                true->
                                    ignore;
                                _ ->
                                    erlang:send(Pid,{mod_map_bonfire,{bonfire_start_time,FamilyID,BonfireBurnTime}})
                            end,
                            {ok, Pid}
                    end
            end;
        PID ->
            {ok, PID}
    end.

%% 根据地图ID，ServerNpcId创建逐鹿天下副本地图进程
create_vwf_map_copy(MapID,MapProcessName) ->
    create_copy(MapID, MapProcessName).

%% 根据ServerNpcId 获取逐鹿天下副本地图
get_vwf_common_map_name(MapId,ServerNpcId) ->
    lists:concat(["map_vwf_",MapId,ServerNpcId]).

%% 创建师门同心副本地图进程                               
create_educate_map_copy(MapID,MapProcessName) ->
    create_copy(MapID, MapProcessName).

%% @doc 同步(阻塞)方式创建副本
create_copy(MapID, MapProcessName) ->
    case global:whereis_name(MapProcessName) of
        undefined ->
            PID = pool:pspawn(mgeem_router, do_start_map_distribution, [MapID, MapProcessName]),
            Ref = erlang:monitor(process, PID),
            receive
                {'DOWN', Ref, process, _, _} ->
                    case global:whereis_name(MapProcessName) of
                        undefined ->
                            error;
                        _ ->
                            ok
                    end
            after 100 ->
                    error
            end;  
        _PID ->
            ok
    end.
%% @doc 异步方式创建副本
%% 模块必须接收{create_map_succ,Key}方法
async_create_copy(MapID, MapProcessName, Module, Key) ->
    global:send(mgeem_router, {create_map_distribution, MapID, MapProcessName, Module, erlang:self(), Key}).

