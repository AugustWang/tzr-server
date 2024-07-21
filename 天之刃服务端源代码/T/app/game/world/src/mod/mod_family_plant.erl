%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     种植模块
%%%     注意:: 该模块属于mod_family的子模块，只能在mod_family中被调用！
%%% @end
%%% Created : 2011-01-10
%%%-------------------------------------------------------------------
-module(mod_family_plant).
-include("mgeew.hrl").
-include("mgeew_family.hrl").

%% API
-export([do_handle_info/1]).
-export([msg_tag/0]).

%%默认的田地大小
-define(DEFAULT_FARM_SIZE,10).


-define(ETS_PLANT_SEEDS,ets_plant_seeds).
-define(PLANT_ASSART_REQUEST,plant_assart_request).

%% ====================================================================
%% API functions
%% ====================================================================


msg_tag()->
    [plant_assart_map_result].



%%开垦田地
do_handle_info({Unique, Module, ?PLANT_ASSART, Record, RoleID, _PID, Line}) ->
    do_plant_assart(Unique, Module, ?PLANT_ASSART, Record, RoleID, Line);
do_handle_info({plant_assart_map_result,IsSuccess,Request}) ->
    do_plant_assart_result(IsSuccess,Request);
do_handle_info(Info) ->
    ?ERROR_MSG("~ts:~w", ["未知信息", Info]).

%%@interface 开垦田地
do_plant_assart(Unique, Module, Method, _Record, RoleID, Line)->
    %%必须掌门、长老才能开垦
    State = mod_family:get_state(),
    FamilyInfo = State#family_state.family_info,
    case mod_family:is_owner_or_second_owner(RoleID, FamilyInfo) of
        true->
            case is_integer(State#family_state.assart_farm_size) of
                true->
                    CurFarmSize = State#family_state.assart_farm_size;
                _ ->
                    CurFarmSize = ?DEFAULT_FARM_SIZE
            end,
            #p_family_info{family_id=FamilyID,level=FamilyLevel} = FamilyInfo,
            [FamilyPlantConf] = common_config_dyn:find(family_plant,FamilyLevel),
            #r_family_plant_config{max_farm_size=MaxFarmSize} = FamilyPlantConf,
            case MaxFarmSize>CurFarmSize of
                true->
                    do_plant_assart_2(Unique, Module, Method, RoleID, Line,FamilyID,FamilyInfo,FamilyPlantConf);
                _ ->
                    NextFamilyLevel = FamilyLevel+1,
                    Reason = lists:concat(["继续开垦需要",NextFamilyLevel,"级门派等级"]),
                    ?SEND_ERR_TOC(m_plant_assart_toc,Reason)
            end;
        _ ->
            ?SEND_ERR_TOC(m_plant_assart_toc,<<"只有掌门/长老才能开垦田地">>)
    end.

do_plant_assart_2(Unique, Module, Method, RoleID, Line,FamilyID,FamilyInfo,FamilyPlantConf)->
    #r_family_plant_config{deduct_ap=DeductActivePt,deduct_money=DeductMoney} = FamilyPlantConf,
    #p_family_info{family_id=FamilyID,active_points=CurrentAp,money=CurrentMoney} = FamilyInfo,

    case (CurrentAp>=DeductActivePt) andalso (CurrentMoney>=DeductMoney) of
        true->
            case get({?PLANT_ASSART_REQUEST, RoleID}) of
                undefined->
                    do_plant_assart_3(Unique, Module, Method, RoleID, Line,FamilyID,FamilyPlantConf);
                _ ->
                     ?SEND_ERR_TOC(m_plant_assart_toc,<<"您的田地正在开垦中，请稍等">>)
            end;
        _ ->
            Reason = common_misc:format_lang("开垦该田地需要~w门派繁荣度和~w两门派资金", [DeductActivePt,DeductActivePt]),
            ?SEND_ERR_TOC(m_plant_assart_toc,Reason)
    end.

do_plant_assart_3(Unique, Module, Method, RoleID, Line,FamilyID,FamilyPlantConf)->
    set_plant_assart_request(RoleID, {Unique, Module, Method, Line,FamilyPlantConf}),

    Request = {plant_assart_map,self(),RoleID,FamilyID},
    MapName = lists:concat(["map_family_", FamilyID]),
    global:send(MapName, {mod,mod_map_family_plant,Request}).


set_plant_assart_request(RoleID, Request) ->
    erlang:put({?PLANT_ASSART_REQUEST, RoleID}, Request).

%%处理Map开垦土地后的结果
do_plant_assart_result(true,{RoleID,NewFarmID}=Request)->
    case get({?PLANT_ASSART_REQUEST, RoleID}) of
        {Unique, Module, Method, Line,FamilyPlantConf}->
            State = mod_family:get_state(),
            FamilyInfo = State#family_state.family_info,
            deduct_for_assart(State,FamilyPlantConf),

            erlang:erase({?PLANT_ASSART_REQUEST, RoleID}),
            
            %%门派广播
            RoleName = common_misc:get_dirty_rolename(RoleID),
            Message  = case mod_family:is_owner(RoleID,FamilyInfo) of
                           true->
                               lists:concat(["恭喜掌门",RoleName,"成功开垦了一块新的种植药地"]);
                           _ ->
                               lists:concat(["恭喜长老",RoleName,"成功开垦了一块新的种植药地"])
                       end,
            mod_family:broadcast_to_family_channel(Message),
            R2 = #m_plant_assart_toc{succ=true,farm_id=NewFarmID},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R2);
        _ ->
            ?ERROR_MSG("收到一个过期的开垦土地的结果消息,Request=~w",[Request])
    end;
do_plant_assart_result(false,{RoleID,Reason}=Request)->
    case get({?PLANT_ASSART_REQUEST, RoleID}) of
        {Unique, Module, Method, Line}->
            erlang:erase({?PLANT_ASSART_REQUEST, RoleID}),
            case is_list(Reason) orelse is_binary(Reason) of
                true->
                    Error = Reason;
                _ ->
                    Error = ?_LANG_SYSTEM_ERROR
            end,
            ?SEND_ERR_TOC(m_plant_assart_toc,Error);
        _ ->
            ?ERROR_MSG("收到一个过期的开垦土地的结果消息,Request=~w",[Request])
    end.
         
%%对开垦田地进行扣除
deduct_for_assart(State,FamilyPlantConf)->
    %%改变当前田地大小
    FarmSize = State#family_state.assart_farm_size,
    NewFarmSize = FarmSize+1,
    
    %%扣取了门派资金，门派繁荣度
    #r_family_plant_config{deduct_ap=DeductActivePt,deduct_money=DeductMoney} = FamilyPlantConf,
    FamilyInfo = State#family_state.family_info,
    
    NewMoney = FamilyInfo#p_family_info.money - DeductMoney,
    NewAp = FamilyInfo#p_family_info.active_points - DeductActivePt,
    NewState = State#family_state{family_info = FamilyInfo#p_family_info{money=NewMoney,active_points=NewAp},
                                  assart_farm_size=NewFarmSize},
    
    R1 = #m_family_money_toc{ new_money = NewMoney },
    mod_family:broadcast_to_all_members(?FAMILY,?FAMILY_MONEY,R1),
    
    R2 = #m_family_active_points_toc{new_points = NewAp},
    mod_family:broadcast_to_all_members(?FAMILY,?FAMILY_ACTIVE_POINTS,R2),
    mod_family:update_state(NewState).
 
 
 
