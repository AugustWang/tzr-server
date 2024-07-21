%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     种植模块
%%% @end
%%% Created : 2011-01-10
%%%-------------------------------------------------------------------
-module(mod_map_family_plant).
-include("mgeem.hrl").

%% API
-export([handle/1]).
-export([loop/1]).
-export([init_ets/0]).
-export([get_farm_by_slice_list/2,get_farm_by_slice_list/1]).


%%田地状态；0=未开垦，1=未种植，2=种子期,3=成长期,4=成熟期
-define(FARM_STATUS_NOT_ASSART,0).
-define(FARM_STATUS_NOT_SOW,1).
-define(FARM_STATUS_SOWING,2).
-define(FARM_STATUS_GROWING,3).
-define(FARM_STATUS_RIPE,4).
%%收割时间段
-define(HARVEST_SEGM_QUICK,5*60).
-define(HARVEST_SEGM_SLOW,15*60).
-define(MINUTE,60*1000).
%%成长时间
-define(GROW_TIME_QUICK,15*60*1000).    %%15分钟
-define(GROW_TIME_SLOW,70*60*1000).     %%70分钟

%%施肥的最短效果
-define(MIN_FERTILIZE_TIME_QUICK,15*60*10*2).    %%18秒
-define(MIN_FERTILIZE_TIME_SLOW,70*60*10*2).     %%84秒

%%种植日志每个人记录的最大条数
-define(MAX_PLANT_LOG_SIZE,20).

-define(ETS_PLANT_SEEDS,ets_plant_seeds).

%% ====================================================================
%% API functions
%% ====================================================================

get_farm_by_slice_list(SliceList)->
    mod_map_slice:get_by_slice_list(SliceList, plant_farm).


%%@doc 获取Slice中的Farm
get_farm_by_slice_list(_AllSlice,MapID) when (MapID=/=?DEFAULT_FAMILY_MAP_ID)->
    [];
get_farm_by_slice_list(AllSlice,_MapID)->
    case mod_map_slice:get_by_slice_list(AllSlice, plant_farm) of
        []->
            FarmList = get_family_farm_from_db(),
            mod_map_slice:init_by_slice(AllSlice,plant_farm,FarmList),
            ?INFO_MSG("FarmList=~w",[FarmList]),
            FarmList;
        List ->
            ?INFO_MSG("FarmList2=~w",[List]),
            List
    end.
get_family_farm_from_db()->
    State = mgeem_map:get_state(),
    case get_family_id_from_map_name(State) of
        undefined->
            [];
        FamilyID->
            case db:dirty_read(?DB_FAMILY_PLANT,FamilyID) of
                [#r_family_plant{farm_list=FarmList}] ->
                    FarmList;
                _ ->
                    []
            end
    end.

%%@doc 农田每秒的循环，更新庄稼的状态
loop(MapID) when (MapID=:=?DEFAULT_FAMILY_MAP_ID)->
    State = mgeem_map:get_state(),
    case get_family_id_from_map_name(State) of
        undefined->
            ignore;
        FamilyID->
            %%?INFO_MSG("State=~w,FamilyID=~w",[State,FamilyID]),
            case db:dirty_read(?DB_FAMILY_PLANT,FamilyID) of
                [#r_family_plant{farm_list=FarmList}=R1] ->
                    {ChangeFarmList,FarmList2} =
                        lists:foldl(fun(E,Acc)-> 
                                            get_change_farm_list(E,Acc)
                                    end, {[],[]}, FarmList),
                    lists:foreach(fun(E)-> 
                                          update_farm_for_slice_list(E,State)
                                  end, ChangeFarmList),
                    R2 = R1#r_family_plant{farm_list=FarmList2},
                    db:dirty_write(?DB_FAMILY_PLANT,R2);
                _ ->
                    ignore
            end
    end;
loop(_MapID)->
    ignore.

get_family_id_from_map_name(State)->
    MapName = State#map_state.map_name,
    case string:str(MapName, "map_family_") of
        1->
            Index = length("map_family_")+1,
            common_tool:to_integer(string:substr(MapName, Index));
        _ ->
            undefined
    end.

%%获取田地对应的SliceList
get_slicelist_for_farm(State,FarmID)->
    #map_state{offsetx = OffsetX, 
               offsety = OffsetY} = State,
    [#r_plant_farm_config{tx=X,ty=Y}] = common_config_dyn:find(plant_farm,FarmID),
    SliceList = mgeem_map:get_9_slice_by_txty(X, Y, OffsetX, OffsetY),
    SliceList.

get_change_farm_list(E,{ChangeList,AllList}=Acc)->
    #p_map_farm{status=Status} = E,
    case (Status=:=?FARM_STATUS_SOWING) orelse (Status=:=?FARM_STATUS_GROWING) of
        true->
            case change_farm_status(E) of
                {ok,NewOne}->
                    #p_map_farm{farm_id=FarmID} = NewOne,
                    AllList2 = lists:keyreplace(FarmID, 2, AllList, NewOne),
                    {[NewOne|ChangeList],AllList2};
                _->
                    Acc
            end;
        _ ->    
            Acc
    end.
change_farm_status(FarmInfo)->
    %%1、成长期变为收获期
    %%2、种子期变为成长期
    Now = common_tool:now(),
    #p_map_farm{sow_time=SowTime,harvest_time=HarvestTime} = FarmInfo,
    
    if
        (SowTime=:=undefined) orelse(HarvestTime=:=undefined) ->
            ignore;
        SowTime>= Now->
            ignore;
        HarvestTime >= Now->
            {ok,FarmInfo#p_map_farm{status=?FARM_STATUS_RIPE}};
        true->
            SowingInterval = Now-SowTime,
            case SowingInterval*100 div (HarvestTime-SowTime) >= 30 of
                true->
                    {ok,FarmInfo#p_map_farm{status=?FARM_STATUS_GROWING}};
                _ ->
                    ignore
            end
    end.


%%初始化种植的种子配置
init_ets()->
    ets:new(?ETS_PLANT_SEEDS, [named_table, set, protected,{keypos,2}]),
    RecList = common_config_dyn:list(plant_seeds),
    lists:foreach(fun(R)->
                          ets:insert(?ETS_PLANT_SEEDS, R)
                  end, RecList).

handle(Request)->
    do_handle_info(Request).

%%播种
do_handle_info({Unique, Module, ?PLANT_SOW, Record, RoleID, _PID, Line}) ->
    do_plant_sow(Unique, Module, ?PLANT_SOW, Record, RoleID, Line);
%%施肥
do_handle_info({Unique, Module, ?PLANT_FERTILIZE, Record, RoleID, _PID, Line}) ->
    do_plant_fertilize(Unique, Module, ?PLANT_FERTILIZE, Record, RoleID, Line);
%%显示种植日记
do_handle_info({Unique, Module, ?PLANT_LIST_LOG, Record, RoleID, _PID, Line}) ->
    do_plant_list_log(Unique, Module, ?PLANT_LIST_LOG, Record, RoleID, Line);
%%清空种植日记
do_handle_info({Unique, Module, ?PLANT_CLEAR_LOG, Record, RoleID, _PID, Line}) ->
    do_plant_clear_log(Unique, Module, ?PLANT_CLEAR_LOG, Record, RoleID, Line);
%%收获
do_handle_info({Unique, Module, ?PLANT_HARVEST, Record, RoleID, _PID, Line}) ->
    do_plant_harvest(Unique, Module, ?PLANT_HARVEST, Record, RoleID, Line);
%%显示种植技能
do_handle_info({Unique, Module, ?PLANT_SHOW_SKILL, Record, RoleID, _PID, Line}) ->
    do_plant_show_skill(Unique, Module, ?PLANT_SHOW_SKILL, Record, RoleID, Line);
%%升级种植技能
do_handle_info({Unique, Module, ?PLANT_UPGRADE_SKILL, Record, RoleID, _PID, Line}) ->
    do_plant_upgrade_skill(Unique, Module, ?PLANT_UPGRADE_SKILL, Record, RoleID, Line);
%%获取对应的种子列表
do_handle_info({Unique, Module, ?PLANT_LIST_SEEDS, Record, RoleID, _PID, Line}) ->
    do_plant_list_seeds(Unique, Module, ?PLANT_LIST_SEEDS, Record, RoleID, Line);
%%处理开垦田地的请求
do_handle_info({plant_assart_map,From,RoleID,FamilyID}) ->
    do_plant_assart_map(RoleID,From,FamilyID);
                                                                               
do_handle_info(Info) ->
    ?ERROR_MSG("~ts:~w", ["未知信息", Info]).

%%@interface 处理开垦田地的请求
do_plant_assart_map(RoleID,From,FamilyID)->
    assert_in_legal_map(),
    try
        [#r_family_plant{farm_list=FarmList,max_farm_id=MaxFarmID}=RecFamily] =  db:dirty_read(?DB_FAMILY_PLANT,FamilyID),
        NewFarmID = MaxFarmID+1,
        NewFarm = #p_map_farm{farm_id=NewFarmID,status=?FARM_STATUS_NOT_SOW},
        FarmList2 = [NewFarm|FarmList],
        ok = db:dirty_write(?DB_FAMILY_PLANT,RecFamily#r_family_plant{farm_list=FarmList2,max_farm_id=NewFarmID}),
        From ! {plant_assart_map_result,true,{RoleID,NewFarmID}}
    catch
        _:Reason->
            ?ERROR_MSG("do_plant_assart_map failed,Reason=~w",[Reason]),
            From ! {plant_assart_map_result,false,{RoleID,Reason}}
    end.

%%@interface 播种  
do_plant_sow(Unique, Module, Method, Record, RoleID, Line)->
    assert_in_legal_map(),
    %%     1、判断是否已经种植
    #m_plant_sow_tos{farm_id=TheFarmID} = Record,
    FamilyID = get_family_id(RoleID),
    case get_farm_status(FamilyID,TheFarmID) of
        {error,_}->
            ?SEND_ERR_TOC(m_plant_sow_toc,<<"该田地尚未开垦，不能播种">>);
        {ok,?FARM_STATUS_NOT_ASSART}->
            ?SEND_ERR_TOC(m_plant_sow_toc,<<"该田地尚未开垦，不能播种">>);
        {ok,?FARM_STATUS_NOT_SOW}->
            case db:dirty_read(?DB_ROLE_PLANT,RoleID) of
                [#r_role_plant{farm_id=CurFarmID}] when (CurFarmID>0)->
                    ?SEND_ERR_TOC(m_plant_sow_toc,<<"每人最多只能播种一块田地">>);
                []->
                    do_plant_sow_2(Unique, Module, Method, Record, RoleID, Line,FamilyID,undefined);
                RolePlantRec ->
                    do_plant_sow_2(Unique, Module, Method, Record, RoleID, Line,FamilyID,RolePlantRec)
            end;
        {ok,_}->
            ?SEND_ERR_TOC(m_plant_sow_toc,<<"该田地已经种植，不能再播种">>)
    end.

do_plant_sow_2(Unique, Module, Method, Record, RoleID, Line,RolePlantRec,FamilyID)->
    %%     2、判断种子的等级
    %%     3、增加种植熟练度
    #m_plant_sow_tos{farm_id=TheFarmID,seed_id=SeedID} = Record,
    case RolePlantRec of
        #r_role_plant{cur_skill_level=CurSkillLevel,cur_proficiency=CurProficiency}->
            ignore;
        undefined->
            CurSkillLevel=1,
            CurProficiency=0
    end,
    case common_config_dyn:find(plant_seeds,SeedID) of
        [#r_plant_seeds_config{name=SeedName,skill_level=SkillLevel,seed_type=SeedType}]->
            case SkillLevel>CurSkillLevel of
                true->
                    ?SEND_ERR_TOC(m_plant_sow_toc,<<"种植技能等级不够，必须拥有xx等级">>);
                _ ->
                    NewRolePlantRec =  case RolePlantRec of
                                           undefined->
                                               #r_role_plant{role_id=RoleID,cur_skill_level=1,cur_proficiency=10};
                                           _ ->
                                               RolePlantRec#r_role_plant{cur_proficiency=CurProficiency+10}
                                       end,
                    db:dirty_write(?DB_ROLE_PLANT,NewRolePlantRec),
                    SowTime = common_tool:now(),
                    case SeedType of
                        1->
                            HarvestTime = SowTime+?GROW_TIME_QUICK,
                            HarvestSegment = ?HARVEST_SEGM_QUICK;
                        2->
                            HarvestTime = SowTime+?GROW_TIME_SLOW,
                            HarvestSegment = ?HARVEST_SEGM_SLOW
                    end,
                    NewFarmInfo = #p_map_farm{farm_id=TheFarmID,status=?FARM_STATUS_SOWING,
                                            planter_id=RoleID,seed_id=SeedID,seed_name=SeedName,
                                            sow_time=SowTime,harvest_time=HarvestTime,
                                            harvest_segment=HarvestSegment},
                    do_plant_sow_3(Unique, Module, Method, Record, RoleID, Line,NewFarmInfo,FamilyID)
            end;
        _ ->
            ?ERROR_MSG("非法的种子,SeedID=~w,RoleID=~w",[SeedID,RoleID]),
            ?SEND_ERR_TOC(m_plant_sow_toc,<<"非法的种子">>)
    end.

do_plant_sow_3(Unique, Module, Method, Record, RoleID, Line,NewFarmInfo,FamilyID)->
    #m_plant_sow_tos{seed_id=SeedID} = Record,
    %% 扣除背包中的种子或贡献度
    case mod_bag:check_inbag_by_typeid(RoleID,SeedID) of
        {ok,FoundGoodsInfoList} when length(FoundGoodsInfoList)>0 ->
            case common_transaction:transaction(fun() -> 
                                                        mod_bag:decrease_goods_by_typeid(RoleID,SeedID,1)
                                                end) of
                {atomic, {ok,UpdateGoodsList,DeleteGoodsList}} ->
                    common_item_logger:log(RoleID, SeedID,1,undefined,?LOG_ITEM_TYPE_LOST_NPC_EXCHANGE_DEAL),
                    
                    send_goods_notify(del,RoleID,DeleteGoodsList),
                    send_goods_notify(update,RoleID,UpdateGoodsList),
                    
                    do_plant_sow_4(Unique, Module, Method, Record, RoleID, Line,NewFarmInfo,FamilyID);
                {aborted, {throw, {bag_error, Reason}}} ->
                    ?ERROR_MSG("NPC兑换错误，{bag_error, Reason=~w}",[Reason]),
                    ?SEND_ERR_TOC(m_plant_sow_toc,<<"非法的种子">>);
                {aborted, Error} ->
                    ?ERROR_MSG("NPC兑换错误，Error=~w",[Error]),
                    ?SEND_ERR_TOC(m_plant_sow_toc,<<"非法的种子">>)
            end;
        _ ->
            %%选择扣除贡献度
            {ok,RoleAttr} = common_misc:get_dirty_role_attr(RoleID),
            #p_role_attr{family_contribute=RoleFamilyContribute} = RoleAttr,
            SeedsConfig =  common_config_dyn:find(plant_seeds,SeedID) ,
            [#r_plant_seeds_config{family_contribute=NeedFamilyContribute}] = SeedsConfig,
            
            if
                (NeedFamilyContribute>RoleFamilyContribute)->
                    ?SEND_ERR_TOC(m_plant_sow_toc,<<"门派贡献度不够，无法升级">>);
                true->
                    deduct_family_contribute(RoleID,FamilyID,NeedFamilyContribute),
                    do_plant_sow_4(Unique, Module, Method, Record, RoleID, Line,NewFarmInfo,FamilyID)
            end
    end.

do_plant_sow_4(Unique, Module, Method, Record, RoleID, Line,NewFarmInfo,FamilyID)->
    %%     4、改变田地的状态
    #p_map_farm{seed_name=SeedName} = NewFarmInfo,
    #m_plant_sow_tos{farm_id=TheFarmID} = Record,
    [#r_family_plant{farm_list=FarmList}=RecFamily] =  db:dirty_read(?DB_FAMILY_PLANT,FamilyID),
    FarmList2 = lists:keyreplace(TheFarmID, 2, FarmList, NewFarmInfo),
    RecFamily2 = RecFamily#r_family_plant{farm_list=FarmList2},
    db:dirty_write(?DB_FAMILY_PLANT,RecFamily2),
    
    Event = lists:concat(["播种【",SeedName,"】"]),
    add_plant_log(RoleID,Event),
    update_farm_info(RoleID,TheFarmID,NewFarmInfo),
    
    R2 = #m_plant_sow_toc{succ=true,farm_info=NewFarmInfo},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2).


%%@interface 施肥  
do_plant_fertilize(Unique, Module, Method, Record, RoleID, Line)->
    assert_in_legal_map(),
    %% 1、判断田地状态
    %% 2、判断剩余施肥次数
    #m_plant_fertilize_tos{farm_id=TheFarmID} = Record,
    FamilyID = get_family_id(RoleID),
    case get_farm_status(FamilyID,TheFarmID) of
        {error,farm_not_found} ->
            ?SEND_ERR_TOC(m_plant_fertilize_toc,<<"非法的田地">>);
        {ok,Status} ->
            case Status of
                ?FARM_STATUS_NOT_ASSART->
                    ?SEND_ERR_TOC(m_plant_fertilize_toc,<<"该田地尚未开垦，不能施肥">>);
                ?FARM_STATUS_NOT_SOW->
                    ?SEND_ERR_TOC(m_plant_fertilize_toc,<<"该田地尚未种植，不能施肥">>);
                ?FARM_STATUS_RIPE->
                    ?SEND_ERR_TOC(m_plant_fertilize_toc,<<"农作物已经成熟，无需施肥">>);
                _ ->
                    case db:dirty_read(?DB_ROLE_PLANT,RoleID) of
                        [#r_role_plant{remain_fertilize_times=RemainFertilizeTimes}=RolePlantRec]->
                            case RemainFertilizeTimes>0 of
                                true->
                                    do_plant_fertilize_2(Unique, Module, Method, Record, RoleID, Line,{FamilyID,TheFarmID,RolePlantRec});
                                _ ->
                                    ?SEND_ERR_TOC(m_plant_fertilize_toc,<<"每次种植只有3次施肥机会">>)
                            end;
                        _ ->
                            do_plant_fertilize_2(Unique, Module, Method, Record, RoleID, Line,{FamilyID,TheFarmID,undefined})
                    end
            end
    end.

do_plant_fertilize_2(Unique, Module, Method, _Record, RoleID, Line,{FamilyID,TheFarmID,RolePlantRec})->
    %% 3、判断是给自己施肥还是给别人施肥
    %% 4、给成长增加buff,修改收割时间
    %% 5、修改施肥的记录次数
    %% 6、还要加上log
    case RolePlantRec of
        #r_role_plant{farm_id=MyFarmID,self_fertilize_times=SelfFertilizeTimes,remain_fertilize_times=RemainFertilizeTimes}->
            ok;
        undefined->
            MyFarmID=0,
            SelfFertilizeTimes=0,
            RemainFertilizeTimes=3
    end,
    case (TheFarmID=:= MyFarmID) and SelfFertilizeTimes>0 of
        true->
            ?SEND_ERR_TOC(m_plant_fertilize_toc,<<"每次种植只能给自己施肥一次">>);
        _ ->
            {ok,NewFarmInfo} = update_farm_for_fertilize(FamilyID,TheFarmID),
            add_fertilize_times(RoleID, (TheFarmID=:= MyFarmID) ),
            add_plant_log(RoleID,"施肥"),
            update_farm_info(RoleID,FamilyID,NewFarmInfo),
    
            R2 = #m_plant_fertilize_toc{succ=true,farm_info=NewFarmInfo,remain_fertilize_times=RemainFertilizeTimes-1},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R2)
    end.

%%@interface 显示种植日记
do_plant_list_log(Unique, Module, Method, _Record, RoleID, Line)->
    R2 = case db:dirty_read(?DB_ROLE_PLANT_LOG,RoleID) of
             []->
                 #m_plant_list_log_toc{succ=true,logs=[]};
             [#r_role_plant_log{logs=LogList}]->
                 #m_plant_list_log_toc{succ=true,logs=LogList}
         end,
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2).

%%@interface 清空种植日记
do_plant_clear_log(Unique, Module, Method, _Record, RoleID, Line)->
    ok = db:dirty_delete(?DB_ROLE_PLANT_LOG,RoleID),
    R2 = #m_plant_clear_log_toc{succ=true},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2).

%%@interface 收获
do_plant_harvest(Unique, Module, Method, Record, RoleID, Line)->
    assert_in_legal_map(),
    %% 1、判断田地是否已种植
    %% 2、判断是否为自己的植物、判断收获期,收割期内果实只能归属种植人所有，获得果实的概率为100%
    #m_plant_harvest_tos{farm_id=TheFarmID} = Record,
    FamilyID = get_family_id(RoleID),
    case get_farm_info(FamilyID,TheFarmID) of
        {error,farm_not_found} ->
            ?SEND_ERR_TOC(m_plant_harvest_toc,<<"非法的田地">>);
        {ok,FarmInfo} ->
            #p_map_farm{status=Status,planter_id=PlanterID,seed_id=SeedID,harvest_time=HarvestTime,harvest_segment=HarvestSegment} = FarmInfo,
            case Status of
                ?FARM_STATUS_RIPE->
                    HarvestProtectTime = HarvestTime + HarvestSegment*60,
                    Now = common_tool:now(),
                    if 
                        (PlanterID=/=RoleID andalso (HarvestProtectTime>Now)) ->
                            ?SEND_ERR_TOC(m_plant_harvest_toc,<<"收割期内果实只能归属种植人所有">>);
                        (PlanterID=:=RoleID andalso (HarvestProtectTime>Now)) ->
                            %%获得果实的概率为100%
                            do_plant_harvest_2(Unique, Module, Method, Record, RoleID, Line,FamilyID,SeedID,true);
                        true->  
                            do_plant_harvest_2(Unique, Module, Method, Record, RoleID, Line,FamilyID,SeedID,false)
                    end;
                _ ->
                    ?SEND_ERR_TOC(m_plant_harvest_toc,<<"农作物尚未成熟，不能摘采">>)
            end
    end.

do_plant_harvest_2(Unique, Module, Method, Record, RoleID, Line,FamilyID,SeedID,IsHarvestBySelf)->
    #m_plant_harvest_tos{farm_id=TheFarmID} = Record,
    %% 3、东西入库
    %% 4、改变农田状态
    %% 5、还要加上log
    NewFarmInfo = #p_map_farm{farm_id=TheFarmID,status=?FARM_STATUS_NOT_SOW},
    
    [PlantSeedsConf] = common_config_dyn:find(plant_seeds_config,SeedID),
    #r_plant_seeds_config{name=SeedName,fruit_id=FruitID,fruit_count=FruitCount1,fruit_rate=FruitRate} = PlantSeedsConf,
    
    case IsHarvestBySelf of
        true->
            FruitCount2=FruitCount1;
        _ ->
            random:seed(erlang:now()),
            FruitCount2 = FruitCount1 * FruitRate div 100
    end,
    case FruitCount2>0 of
        true->
            case add_fruit_to_bag(RoleID,{FruitID,FruitCount2},{Unique, Module, Method, RoleID, Line}) of
                ok->
                    Event = lists:concat(["收割【",SeedName,"】,获得果实*",FruitID,FruitCount2]),
                    add_plant_log(RoleID,Event),
                    update_farm_info(RoleID,FamilyID,NewFarmInfo),

                    R2 = #m_plant_harvest_toc{succ=true,farm_id=TheFarmID},
                    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2);
                _ ->
                    ignore
            end;
        _ ->
            Event = lists:concat(["收割【",SeedName,"】,没有获得果实"]),
            add_plant_log(RoleID,Event),
            update_farm_info(RoleID,FamilyID,NewFarmInfo),

            R2 = #m_plant_harvest_toc{succ=true,farm_id=TheFarmID},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R2)
    end.


%%@interface 显示种植技能
do_plant_show_skill(Unique, Module, Method, _Record, RoleID, Line)->
    case db:dirty_read(?DB_ROLE_PLANT,RoleID) of
        [#r_role_plant{cur_skill_level=CurSkillLevel,cur_proficiency=CurProficiency}]->
            ignore;
        _ ->
            CurSkillLevel=0,
            CurProficiency=0
    end,
    NextSkillLevel = CurSkillLevel+1,
    %%获取下一级的升级条件
    [ConfigRec] = common_config_dyn:find(plant_skill,NextSkillLevel),
    #r_plant_skill_config{need_role_level=NeedRoleLevel,
                                 need_proficiency=NeedProficiency,need_expr=NeedExpr,need_silver=NeedSilver}=ConfigRec,
    R2 = #m_plant_show_skill_toc{succ=true,
                                 cur_skill_level=CurSkillLevel,
                                 cur_proficiency=CurProficiency,
                                 need_role_level=NeedRoleLevel,
                                 need_proficiency=NeedProficiency,
                                 need_expr=NeedExpr,
                                 need_silver=NeedSilver
                                },
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2).


%%@interface 升级种植技能
do_plant_upgrade_skill(Unique, Module, Method, _Record, RoleID, Line)->
    case get({upgrade_skill_request, RoleID}) of
        undefined->
            do_plant_upgrade_skill_2(Unique, Module, Method, _Record, RoleID, Line);
        _ ->
            ?SEND_ERR_TOC(m_plant_upgrade_skill_toc,<<"正在升级种植技能">>)
    end.
do_plant_upgrade_skill_2(Unique, Module, Method, _Record, RoleID, Line)->
    %%1、检查熟练度、检查角色等级
    %%2、消耗门派贡献度
    %%3、消耗银子、消耗经验
    case db:dirty_read(?DB_ROLE_PLANT,RoleID) of
        [#r_role_plant{cur_skill_level=CurSkillLevel,cur_proficiency=CurProficiency}]->
            ignore;
        _ ->
            CurSkillLevel=0,
            CurProficiency=0
    end,
    NextSkillLevel = CurSkillLevel+1,
    [ConfigRec] = common_config_dyn:find(plant_skill,NextSkillLevel),
    #r_plant_skill_config{need_role_level=NeedRoleLevel,family_contribute=NeedFamilyContribute,
                                 need_proficiency=NeedProficiency,need_expr=NeedExpr,need_silver=NeedSilver}=ConfigRec,
    {ok,RoleAttr} = common_misc:get_dirty_role_attr(RoleID),
    #p_role_attr{level=RoleLevel,family_contribute=RoleFamilyContribute} = RoleAttr,
    
    if
        (NeedProficiency>CurProficiency)->
            ?SEND_ERR_TOC(m_plant_upgrade_skill_toc,<<"您的熟练度不够，无法升级">>);
        (NeedRoleLevel>RoleLevel) ->
            ?SEND_ERR_TOC(m_plant_upgrade_skill_toc,<<"您的等级不够，无法升级">>);
        (NeedFamilyContribute>RoleFamilyContribute)->
            ?SEND_ERR_TOC(m_plant_upgrade_skill_toc,<<"门派贡献度不够，无法升级">>);
        true->
            case common_transaction:transaction(fun() -> t_reduce_for_upgrade_skill(RoleID,NeedExpr,NeedSilver) end) of
                {atomic, RoleAttr} ->
                        do_plant_upgrade_skill_3(Unique, Module, Method, RoleID, Line, NeedFamilyContribute, RoleAttr);
                {aborted, Error} ->
                    case Error of
                        {'EXIT', ErrorInfo} ->
                            ?ERROR_MSG("~ts:~w", ["扣除玩家财富时发生系统错误", ErrorInfo]),
                            Reason = ?_LANG_ROLE_MONEY_SYSTEM_ERROR_WHEN_REDUCE;
                        {error, ErrorInfo} ->
                            ?ERROR_MSG("~ts:~w", ["扣除玩家财富时发生系统错误", ErrorInfo]),
                            Reason = ?_LANG_ROLE_MONEY_SYSTEM_ERROR_WHEN_REDUCE;
                        _ ->
                            Reason = Error
                    end,
                    ?SEND_ERR_TOC(m_plant_upgrade_skill_toc,Reason)
            end
    end.

do_plant_upgrade_skill_3(Unique, Module, Method, RoleID, Line, NeedFamilyContribute, RoleAttr)->
    FamilyID = get_family_id(RoleID),
    case is_integer(FamilyID) andalso FamilyID>0 of
        true->
            deduct_family_contribute(RoleID,FamilyID,NeedFamilyContribute),

            R2 = #m_plant_upgrade_skill_toc{succ=true},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R2),
            send_role_attr_change(RoleID,RoleAttr);
        _ ->
            ?SEND_ERR_TOC(m_plant_upgrade_skill_toc,<<"你没有加入门派，无法升级种植技能">>)
    end.


%%扣除银两和经验
t_reduce_for_upgrade_skill(RoleID,NeedExpr,NeedSilver)->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    RoleAttr2 = mod_role_money:t_reduce_silver_any(RoleAttr,NeedSilver,?CONSUME_TYPE_SILVER_PLANT_UP_SKILL),
    #p_role_attr{exp=OldExpr} = RoleAttr2,
    %%扣经验
    case OldExpr<NeedExpr of
        true->
            common_transaction:abort("经验值不够");
        _ ->
            RoleAttr3 = RoleAttr2#p_role_attr{exp=OldExpr-NeedExpr},
            mod_map_role:set_role_attr(RoleID,RoleAttr3),
            RoleAttr3
    end.

%%@interface 获取对应的种子列表
do_plant_list_seeds(Unique, Module, Method, _Record, RoleID, Line)->
    Seeds = case db:dirty_read(?DB_ROLE_PLANT,RoleID) of
                [#r_role_plant{cur_skill_level=CurSkillLevel}]->
                    SeedsList = get_seed_list(CurSkillLevel),
                    [ #p_seed_info{seed_id=ID,seed_name=Name,seed_type=SeedType,level=Lv}||
                                  #r_plant_seeds_config{id=ID,name=Name,skill_level=Lv,seed_type=SeedType} <-SeedsList ];
                _ ->
                    []
            end,
    R2 = #m_plant_list_seeds_toc{succ=true,seeds=Seeds},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2).

%% ====================================================================
%% Internal functions
%% ====================================================================
%% 确认接口操作只在门派地图中进行
assert_in_legal_map()->
    State = mgeem_map:get_state(),
    MapID = State#map_state.mapid,
    case MapID =:= ?DEFAULT_FAMILY_MAP_ID of
        true->
            ok;
        _ ->
            throw(not_in_family_map_id)
    end.

%% 更新Slice中的Farm
update_farm_by_slice(RoleID,NewFarmInfo)->
    #p_map_farm{farm_id=FarmID} = NewFarmInfo,
    RecordData = #m_plant_update_farm_toc{farm_info=NewFarmInfo},
    BroadcastInsenceArgs = {RoleID,?PLANT,?PLANT_UPDATE_FARM,RecordData},
    mod_map_slice:update_by_slice(BroadcastInsenceArgs,plant_farm,FarmID,NewFarmInfo).

%% 更新Slice中的Farm
update_farm_for_slice_list(NewFarmInfo,State)->
    #p_map_farm{farm_id=FarmID} = NewFarmInfo,
    RecordData = #m_plant_update_farm_toc{farm_info=NewFarmInfo},
    
    SliceList = get_slicelist_for_farm(State,FarmID),
    SliceArgs = {SliceList,?PLANT,?PLANT_UPDATE_FARM,RecordData},
    mod_map_slice:update_by_slice_list(SliceArgs,plant_farm,FarmID,NewFarmInfo).
  

%% 扣除门派贡献度
deduct_family_contribute(RoleID,FamilyID,NeedFamilyContribute)->
    common_family:info(FamilyID, {add_contribution, RoleID, -NeedFamilyContribute}).


%% 将收获的道具放入背包
add_fruit_to_bag(RoleID,{FruitID,Num},{Unique, Module, Method, RoleID, Line})->
    case common_transaction:transaction( fun() -> t_add_item(RoleID,{FruitID,Num}) end)
        of
        {atomic, {ok,AddGoodsList}} ->
            common_item_logger:log(RoleID, FruitID,Num,undefined,?LOG_ITEM_TYPE_LOST_NPC_EXCHANGE_DEAL),
            common_misc:update_goods_notify({role, RoleID}, AddGoodsList),
            ok;
        {aborted, {bag_error,not_enough_pos}} ->
            ?SEND_ERR_TOC(m_plant_harvest_toc,<<"背包空间已满，请整理背包！">>),
            error;
        {aborted, {throw, {bag_error, Reason}}} ->
            ?ERROR_MSG("收获物品放入背包错误，{bag_error, Reason=~w}",[Reason]),
            ?SEND_ERR_TOC(m_plant_harvest_toc,<<"背包错误">>),
            error;
        {aborted, Error} ->
            ?ERROR_MSG("收获物品放入背包错误，Error=~w",[Error]),
            ?SEND_ERR_TOC(m_plant_harvest_toc,?_LANG_SYSTEM_ERROR),
            error
    end.

%% 给予道具
t_add_item(RoleID,{ItemTypeID,Num})->
    Type = ?TYPE_ITEM,
    CreateInfo = #r_goods_create_info{bind=true,type=Type, type_id=ItemTypeID, start_time=0, end_time=0, 
                                      num=Num, color=?COLOUR_WHITE,quality=?QUALITY_GENERAL,
                                      punch_num=0,interface_type=present},
    mod_bag:create_goods(RoleID,CreateInfo).


send_goods_notify(_Type,_RoleID,[])->
    ignore;
send_goods_notify(Type,RoleID,GoodsList)->
    ?INFO_MSG("GoodsList=~w",[GoodsList]),
    case Type of
        del->
            common_misc:del_goods_notify({role, RoleID}, GoodsList);
        _ ->
            common_misc:update_goods_notify({role, RoleID}, GoodsList)
    end.

send_role_attr_change(RoleID,RoleAttr)->
    #p_role_attr{silver=Silver,silver_bind=SilverBind,family_contribute=FamilyCtb} = RoleAttr,
    ChangeAttList = [
                     #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE,new_value=SilverBind},
                     #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE,new_value=Silver},
                     #p_role_attr_change{change_type=?ROLE_FAMILY_CONTRIBUTE_CHANGE,new_value=FamilyCtb}
                    ],
    
    ?INFO_MSG("ChangeList=~w",[ChangeAttList]),
    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttList).



%%获取指定级别以上的种子列表
get_seed_list(Level)->
    MatchHead = #r_plant_seeds_config{_='_'},
    Guard = [{'>=', '$3', Level}],
    Result = ['$_'],
    case ets:select(?ETS_PLANT_SEEDS,[{MatchHead, Guard, Result}]) of
        '$end_of_table' ->
            ?ERROR_MSG("no data in the ets table",[]),
            [];
        {ExpRecordList,Continuation} ->
            ?INFO_MSG("ExpRecordList=~p,Continuation=~pw",[ExpRecordList,Continuation]),
            ExpRecordList
    end.

%%施肥更新田地的收割时间
update_farm_for_fertilize(FamilyID,TheFarmID)->
    [#r_family_plant{farm_list=FarmList}=RecFamily] =  db:dirty_read(?DB_FAMILY_PLANT,FamilyID),
    OldFarmInfo = lists:keyfind(TheFarmID, 2, FarmList),
    #p_map_farm{seed_type=SeedType,sow_time=SowTime,harvest_time=HarvestTime} = OldFarmInfo,

    %%每次施肥缩短当前剩余时间的5%，最短效果不低于总时间的2% 
    T1 = (HarvestTime-SowTime)*5 div 100,
    case SeedType of
        1-> 
        if T1>?MIN_FERTILIZE_TIME_QUICK ->
                DeductTime = T1;
            true->
                DeductTime = ?MIN_FERTILIZE_TIME_QUICK
        end;
        2->
        if T1>?MIN_FERTILIZE_TIME_SLOW ->
                DeductTime = T1;
            true->
                DeductTime = ?MIN_FERTILIZE_TIME_SLOW
        end
    end,
    NewHarvestTime = HarvestTime - DeductTime,
    case common_tool:now() >=  NewHarvestTime of
        true->
            NewFarmInfo = OldFarmInfo#p_map_farm{harvest_time=NewHarvestTime,status=?FARM_STATUS_RIPE};
        _ ->
            NewFarmInfo = OldFarmInfo#p_map_farm{harvest_time=NewHarvestTime}
    end,
    FarmList2 = lists:keyreplace(TheFarmID, 2, FarmList, NewFarmInfo),
    RecFamily2 = RecFamily#r_family_plant{farm_list=FarmList2},
    
    db:dirty_write(?DB_FAMILY_PLANT,RecFamily2),
    {ok,NewFarmInfo}.


%%增加施肥次数
add_fertilize_times(RoleID,IsSelfFertilize)->
    case IsSelfFertilize of
        true->
            SelfFertilizeTimes=1;
        _ ->
            SelfFertilizeTimes=0
    end,
    case db:dirty_read(?DB_ROLE_PLANT,RoleID) of
        [#r_role_plant{remain_fertilize_times=RemainFertilizeTimes}=R]->
            R2 = R#r_role_plant{remain_fertilize_times=RemainFertilizeTimes-1,
                                self_fertilize_times=SelfFertilizeTimes},
            db:dirty_write(?DB_ROLE_PLANT,R2);
        _ ->
            R2 = #r_role_plant{remain_fertilize_times=2,self_fertilize_times=SelfFertilizeTimes},
            db:dirty_write(?DB_ROLE_PLANT,R2)
    end.

%%记录种植日志
add_plant_log(RoleID,Event) when is_list(Event)->
    LogString = io_lib:format("~w,~ts",[common_tool:now(),Event]),
    R2 = case db:dirty_read(?DB_ROLE_PLANT_LOG,RoleID) of
             []->
                 #r_role_plant_log{role_id=RoleID,logs=[LogString]};
             [#r_role_plant_log{logs=LogList}]->
                 #r_role_plant_log{role_id=RoleID,logs=merge_logs(LogString,LogList)}
         end,
    db:dirty_write(?DB_ROLE_PLANT_LOG,R2).

merge_logs(Log,LogList) when length(LogList)<?MAX_PLANT_LOG_SIZE->
    [Log|LogList];
merge_logs(Log,LogList) ->
    T = lists:last(LogList),
    [Log|lists:delete(T, LogList)].

%%获取田地的信息
get_farm_info(FamilyID,FarmID) when is_integer(FarmID)->
    [#r_family_plant{farm_list=FarmList}] =  db:dirty_read(?DB_FAMILY_PLANT,FamilyID),
    case lists:keyfind(FarmID, 2, FarmList) of
        false->
            {error,farm_not_found};
        FarmInfo->
            {ok,FarmInfo}
    end.

%%更新田地的信息
update_farm_info(RoleID,FamilyID,NewFarmInfo)->
    FarmID = NewFarmInfo#p_map_farm.farm_id,
    [#r_family_plant{farm_list=FarmList}=R1] =  db:dirty_read(?DB_FAMILY_PLANT,FamilyID),
    case lists:keyfind(FarmID, 2, FarmList) of
        false->
            R2 = R1#r_family_plant{farm_list=[FarmList|NewFarmInfo]},
            db:dirty_write(?DB_FAMILY_PLANT,R2);
        _ ->
            FarmList2 = lists:keyreplace(FarmID, 2, FarmList, NewFarmInfo),
            R2 = R1#r_family_plant{farm_list=[FarmList2]},
            db:dirty_write(?DB_FAMILY_PLANT,R2)
    end,
    update_farm_by_slice(RoleID,NewFarmInfo).
    

%%获取田地的状态
get_farm_status(FamilyID,FarmID) when is_integer(FarmID)->
    case db:dirty_read(?DB_FAMILY_PLANT,FamilyID) of
        [#r_family_plant{farm_list=FarmList}] ->
            case lists:keyfind(FarmID, 2, FarmList) of
                false->
                    {error,farm_not_found};
                #p_map_farm{status=Status}->
                    {ok,Status}
            end;
        _ -> 
            {error,farm_not_found}
    end.

%%获取玩家的门派ID
get_family_id(RoleID)->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
    #p_role_base{family_id=FamilyID} = RoleBase,
    FamilyID.
