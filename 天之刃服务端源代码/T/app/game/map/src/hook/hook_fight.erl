%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 19 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(hook_fight).

-include("mgeem.hrl").

%% API
-export([
         check_fight_condition/4,
         check_fight_pk_mod/5
        ]).

%%检查两人能否进行PK
check_fight_pk_mod(_SActorID, SActorMapInfo, _DActorID, DActorMapInfo,MapID)->
    #p_map_role{faction_id=SFactionID, level=SLevel} = SActorMapInfo,
    #p_map_role{faction_id=DFactionID, level=DLevel, state=DState} = DActorMapInfo,
    case check_fight_level(DState, SLevel, DLevel, SFactionID, DFactionID, MapID) of
        true->
            true;
        {false, Reason} ->
            {false, Reason}
    end.


%%简单当前地图是否允许战斗
check_fight_condition(_RoleID,_TargetID,_TargetType,_SkillID) ->
    case mod_warofking:is_in_safetime() of
        true -> %%抢国王的安全期
            {error, ?_LANG_WAROFKING_IN_SAFE_TIME};
        _ ->
            case mod_warofcity:is_in_safetime() of
                true -> %%城市争夺战的安全期
                    {error, ?_LANG_WAROFCITY_IN_SAFE_TIME};
                _ ->
                    true
            end
    end.

check_fight_level(DState, SLevel, DLevel, SFactionID, DFactionID, MapID) ->
    SInSelfCountry = common_misc:if_in_self_country(SFactionID, MapID),
    DInSelfCountry = common_misc:if_in_self_country(DFactionID, MapID),
    SInWarOfFaction = mod_map_role:is_in_waroffaction(SFactionID),
    DInWarOfFaction = mod_map_role:is_in_waroffaction(DFactionID),
    InPalace = (MapID =:= 11111 orelse MapID =:= 12111 orelse MapID =:= 13111),
    %%不能攻击处于摆摊状态下的玩家
    %%在保护地图下20级以下的玩家不会被攻击，也不能攻击人。。。
    if DState =:= ?ROLE_STATE_TRAINING ->
            {false, ?_LANG_FIGHT_TARGET_TRAINING};
       DState =:= ?ROLE_STATE_STALL ->
            {false, ?_LANG_FIGHT_TARGET_STALL};
       SLevel < 40 andalso SInSelfCountry andalso (not SInWarOfFaction) andalso (not InPalace) ->
            {false, ?_LANG_FIGHT_ATTACK_LESS_THAN_PROTECTED_LEVEL};
       DLevel < 40 andalso DInSelfCountry andalso (not DInWarOfFaction) andalso (not InPalace) ->
            {false, ?_LANG_FIGHT_ATTACKED_LESS_THAN_PROTECTED_LEVEL};
       true ->
            true
    end.


