%%%-------------------------------------------------------------------
%%% @author liuwei <>
%%% @copyright (C) 2010, liuwei
%%% @doc hook地图中宠物的各种信息
%%%-------------------------------------------------------------------
-module(hook_map_pet).

-include("mgeem.hrl").

%% API
-export([
         be_attacked/3,
         on_grow_update/3
        ]).

%%%===================================================================
%%% API
%%%===================================================================

%% @doc 宠物被攻击，被本国玩家攻击会灰名
be_attacked(PetID, SActorID, SActorType) when is_integer(PetID) ->
    case mod_map_actor:get_actor_mapinfo(PetID, pet) of
        undefined ->
            ignore;
        PetMapInfo ->
            be_attacked(PetMapInfo, SActorID, SActorType)
    end;
be_attacked(PetMapInfo, SActorID, SActorType) ->
    RoleID = PetMapInfo#p_map_pet.role_id,
    mod_gray_name:change(RoleID, SActorID, SActorType),
    ok.

%% 训宠能力升级了
on_grow_update(RoleID, Level, _Type) ->
    ?TRY_CATCH( common_mod_goal:hook_pet_grow_update(RoleID, Level),Err3),
    ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
