%%%-------------------------------------------------------------------
%%% @author  <caochuncheng@mingchao.com>
%%% @copyright www.mingchao.com(C) 2011, 
%%% @doc
%%% 玩家在线挂机模块处理
%%% @end
%%% Created : 18 Jan 2011 by  <caochuncheng>
%%%-------------------------------------------------------------------
-module(mod_role_on_zazen).

-include("mgeem.hrl").
-include("role_on_zazen.hrl").

%% API
%% API
-export([
         %% 地图初始化时，在线挂机模块处理
         init/1,
         %% 地图循环处理函数，每一秒一次检查
         loop/1
        ]).

-export([
         add_map_role_on_zazen/1,
         del_map_role_on_zazen/1,
         %% 玩家退出游戏时，需要处理在线挂机
         hook_role_exit/1
        ]).

%%%===================================================================
%%% API 进程字典操作函数
%%%===================================================================
init_map_role_on_zazen(MapId) ->
    erlang:put({?MAP_ON_ZAZEN_ROLE_DICT_PREFIX,MapId},[]).

add_map_role_on_zazen(MapId,Record) ->
    RoleOnZazenList =  erlang:get({?MAP_ON_ZAZEN_ROLE_DICT_PREFIX,MapId}),
    case lists:keyfind(Record#r_role_on_zazen.role_id,#r_role_on_zazen.role_id,RoleOnZazenList) of
        false ->
            erlang:put({?MAP_ON_ZAZEN_ROLE_DICT_PREFIX,MapId},[Record|RoleOnZazenList]);
        _ ->
            RoleOnZazenList2 = lists:keydelete(Record#r_role_on_zazen.role_id,#r_role_on_zazen.role_id,RoleOnZazenList),
            erlang:put({?MAP_ON_ZAZEN_ROLE_DICT_PREFIX,MapId},[Record|RoleOnZazenList2])
    end.
del_map_role_on_zazen(MapId,RoleId) ->
    RoleOnZazenList =  erlang:get({?MAP_ON_ZAZEN_ROLE_DICT_PREFIX,MapId}),
    case lists:keyfind(RoleId,#r_role_on_zazen.role_id,RoleOnZazenList) of
        false ->
            {ok,0};
        RoleRecord ->        
            RoleOnZazenList2 = lists:keydelete(RoleId,#r_role_on_zazen.role_id,RoleOnZazenList),
            erlang:put({?MAP_ON_ZAZEN_ROLE_DICT_PREFIX,MapId},RoleOnZazenList2),
            {ok,RoleRecord#r_role_on_zazen.sum_exp}
    end.

get_map_role_on_zazen(MapId) ->
    erlang:get({?MAP_ON_ZAZEN_ROLE_DICT_PREFIX,MapId}).

%% get_map_role_on_zezen(MapId,RoleId) ->
%%     RoleOnZazenList = erlang:get({?MAP_ON_ZAZEN_ROLE_DICT_PREFIX,MapId}),
%%     case lists:keyfind(RoleId,#r_role_on_zazen.role_id,RoleOnZazenList) of
%%         false ->
%%             {error,not_found};
%%         RoleOnZazen ->
%%             {ok,RoleOnZazen}
%%     end.


%%%===================================================================
%%% API
%%%===================================================================

%% 地图初始化时，在线挂机模块
%% 参数：
%% MapId 地图id
%% MapName 地图进程名称
init(MapId) ->
    init_map_role_on_zazen(MapId).

%% 地图循环处理函数，即一秒循环
%% 参数
%% MapId 地图id
loop(MapId) ->
    case get_map_role_on_zazen(MapId) of
        [] ->
            ignore;
        OnZazenRoleList ->
            NowSeconds = common_tool:now(),
            MaxRoleNumber = get_on_zazen_max_role_number(),
            Seconds = get_on_zazen_exp_min_seconds(),
            loop2(MapId,OnZazenRoleList,NowSeconds,MaxRoleNumber,Seconds)
    end.
%% OnZazenRoleList 结构为 r_role_on_zazen

loop2(_,[],_,_,_)->
    ignore;
loop2(_,_,_,Num,_) when Num=<0 ->
    ignore;
loop2(MapId,[OnZazenRecord|OnZazenRoleList],NowSecords,Num,Seconds)->
    case catch check_can_add_exp(OnZazenRecord,NowSecords) of
        ok->
            add_zazen_exp(MapId,OnZazenRecord,Seconds),
            loop2(MapId,OnZazenRoleList,NowSecords,Num+1,Seconds);
        ignore->
            loop2(MapId,OnZazenRoleList,NowSecords,Num,Seconds);
        _->
            del_map_role_on_zazen(MapId,OnZazenRecord#r_role_on_zazen.role_id),
            loop2(MapId,OnZazenRoleList,NowSecords,Num,Seconds)
        
    end.

check_can_add_exp(OnZazenRecord,NowSecords)->
    case OnZazenRecord#r_role_on_zazen.next_time<NowSecords of
        true->
            next;
        false->
            throw(ignore)
    end,
    RoleMapInfo = 
    case mod_map_actor:get_actor_mapinfo(OnZazenRecord#r_role_on_zazen.role_id, role) of
        undefined->
            throw(error);
        TRoleMapInfo ->
            TRoleMapInfo  
    end,
    case RoleMapInfo#p_map_role.state =:=?ROLE_STATE_ZAZEN of
        true->
            ok;
        _->
            error
    end.
    
add_zazen_exp(MapId,OnZazenRecord,Seconds)->
    Exp = (OnZazenRecord#r_role_on_zazen.role_exp_record)#r_on_zazen_role_exp.exp,
    MultiExp = common_tool:ceil(mod_team_exp:get_multi_exp(OnZazenRecord#r_role_on_zazen.role_id,Exp,[?BUFF_TYPE_ADD_EXP_MULTIPLE])),
    TotalExp = OnZazenRecord#r_role_on_zazen.sum_exp,
    NextTimes = OnZazenRecord#r_role_on_zazen.next_time,
    add_map_role_on_zazen(MapId,OnZazenRecord#r_role_on_zazen{next_time = Seconds+NextTimes,sum_exp=TotalExp+MultiExp}),
    catch mod_map_role:handle({add_exp, OnZazenRecord#r_role_on_zazen.role_id, MultiExp},undefined).


%% 玩家退出游戏时，需要处理在线挂机
hook_role_exit(RoleId) ->
    MapId = mgeem_map:get_mapid(),
    del_map_role_on_zazen(MapId,RoleId).


add_map_role_on_zazen(RoleMapInfo)->
    Seconds = get_on_zazen_exp_min_seconds(),
    MapId = mgeem_map:get_mapid(),
    case get_on_zazen_role_exp(RoleMapInfo) of
        {error,not_found}->
            ignore;
        {ok,OnZazenInfo}->
            Record  = #r_role_on_zazen{role_id=RoleMapInfo#p_map_role.role_id,
                                       role_exp_record=OnZazenInfo,
                                       next_time =Seconds+common_tool:now(),
                                       sum_exp=0},
            add_map_role_on_zazen(MapId,Record)
    end.

del_map_role_on_zazen(RoleID)->
    MapId = mgeem_map:get_mapid(),
    del_map_role_on_zazen(MapId,RoleID).



%%%===================================================================
%%% Internal functions
%%%===================================================================

%% 根据玩家的级别获取玩家打坐的经验配置
%% 返回 {ok,OnZazenRoleExp} or {error,Reason}
%% OnZazenRoleExp 结构为 r_on_zazen_role_exp
get_on_zazen_role_exp(RoleMapInfo) ->
    RoleLevel = RoleMapInfo#p_map_role.level,
    OnZazenRoleExpList = 
        case common_config_dyn:find(?on_zazen_config,on_zazen_role_exp) of
            [Value] ->
                Value;
            _ ->
                []
        end,
    case lists:keyfind(RoleLevel,#r_on_zazen_role_exp.role_level,OnZazenRoleExpList) of
        false ->
            {error,not_found};
        OnZazenRoleExp ->
            {ok,OnZazenRoleExp}
    end.

%% 玩家在线挂机持续多少时间可以得经验，单位：秒 15
get_on_zazen_exp_min_seconds() ->
    case common_config_dyn:find(?on_zazen_config,on_zazen_get_exp_min_seconds) of
        [Value] ->
            Value;
        _ ->
            15
    end.

%% 每次在图大循环处理的玩家在线挂机数为 20
get_on_zazen_max_role_number() ->
    case common_config_dyn:find(?on_zazen_config,on_zazen_max_role_number) of
        [Value] ->
            Value;
        _ ->
            50
    end.
