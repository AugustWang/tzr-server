%% Author: lenovo
%% Created: 2010-12-24
%% Description: TODO: Add description to mod_gm
-module(mod_gm).
-include("../../map/include/mission.hrl").

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([handle/2]).

%%
%% API Functions
%%
%%global:send(MAPProcessName, {mod_gm, {set_role_attr_opt, RoleID, OptionList}})

handle(Info, State) ->
    ?DEBUG("~ts:~w", ["GM消息", Info]),
    do_handle(Info, State).

do_handle({get_role_attr_opt, RoleID, ReceiverPID,ReplyMsgTag}, _State) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{active_points=ActivePt} = RoleAttr,
    ReceiverPID ! {ReplyMsgTag,{ok,ActivePt}};

do_handle({set_role_attr_opt, RoleID, OptionList}, _State) ->
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    NewRoleAttr =
        lists:foldl(fun({ElementName, Value}, RoleAttrT) ->
                            internal_set_role_attr(RoleID, RoleAttrT, ElementName, Value)
                    end, RoleAttr, OptionList),

    common_transaction:transaction(fun() -> mod_map_role:set_role_attr(RoleID, NewRoleAttr) end),
    DataRecord = #m_role2_attr_reload_toc{role_attr=NewRoleAttr},
    Info = {role_msg, ?ROLE2, ?ROLE2_ATTR_RELOAD, DataRecord},
    common_misc:chat_cast_role_router(RoleID, Info);

do_handle({set_role_base_opt, RoleID, OptionList}, _State) ->
    TransFun = fun()-> 
                   {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
                   NewRoleBase =
                     lists:foldl(fun({ElementName, Value}, RoleBaseT) ->
                                     internal_set_role_base(RoleID, RoleBaseT, ElementName, Value)
                                 end, RoleBase, OptionList),
                   mod_map_role:set_role_base(RoleID, NewRoleBase),
                   {ok,NewRoleBase}
               end,
    case common_transaction:transaction( TransFun ) of
        {atomic,{ok,NewRoleBase}}->
            DataRecord = #m_role2_base_reload_toc{role_base=NewRoleBase},
            Info = {role_msg, ?ROLE2, ?ROLE2_BASE_RELOAD, DataRecord},
            common_misc:chat_cast_role_router(RoleID, Info);
        {aborted,Error} ->
            ?ERROR_MSG("Error=~w",[Error]),
            error
    end;

%%设置门派繁荣度
do_handle({family_add_active_points, RoleID, Value}, _State) ->
    {ok, #p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    common_family:info(FamilyID,{gm_add_active_points, Value});


%%进入门派地图
do_handle({family_enable_map, RoleID}, _State) ->
    {ok, #p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    common_family:info(FamilyID,{gm_enable_map, RoleID});

%%增加门派资金
do_handle({family_add_money, RoleID, Value}, _State) ->
    {ok, #p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    common_family:info(FamilyID,{gm_add_money, Value});

%%直接门派升级
do_handle({family_uplevel,RoleID}, _State) ->
    {ok, #p_role_base{family_id=FamilyID}} = mod_map_role:get_role_base(RoleID),
    common_family:info(FamilyID,{gm_uplevel,RoleID});

%%设置完成任务
do_handle({gm_set_mission, RoleID, MissID}, _State) ->
    gm_set_mission(RoleID,MissID,false);
do_handle({gm_set_mission, RoleID, MissID, IsComplete}, _State) ->
    gm_set_mission(RoleID,MissID,IsComplete);

%%设置等级
do_handle({set_level, RoleID, Level}, _State) ->
    case common_config_dyn:find(level, Level + 1) of
        [#p_level_exp{exp = NextLevelExp}] ->
            {ok, OldAttr} = mod_map_role:get_role_attr(RoleID),
            {ok, OldRoleBase} = mod_map_role:get_role_base(RoleID),
            OldExp = OldAttr#p_role_attr.exp,
            OldLevel = OldAttr#p_role_attr.level,
            Increment = NextLevelExp - OldExp,
            if
                Increment =< 0 ->
                    ignore;
                true ->
                    common_misc:send_to_rolemap(RoleID, 
                                                {mod_map_role, 
                                                 {gm_level_up, OldAttr, OldRoleBase, OldLevel, Level, 0}
                                                })
            end;
        _ ->
            ignore
    end;

%%GM赠送道具
do_handle({add_item, RoleID, AwdItemList}, _State) ->
    case common_transaction:transaction( 
           fun() ->  t_add_item(RoleID,[],AwdItemList) 
           end)of
        {atomic, {ok,AddGoodsList}} ->
            lists:foreach(fun(AwdItem)-> 
                                  {_Type,ItemTypeID,Num} = AwdItem,   
                                  common_item_logger:log(RoleID, ItemTypeID,Num,true,?LOG_ITEM_TYPE_XI_TONG_ZENG_SONG)
                          end,AwdItemList),
            common_misc:update_goods_notify({role, RoleID}, AddGoodsList);
        {aborted, {bag_error,not_enough_pos}} ->
            ?ERROR_MSG("GM赠送道具,背包空间已满，请整理背包！,RoleID=~w",[RoleID]);
        {aborted, {throw, {bag_error, Reason}}} ->
            ?ERROR_MSG("GM赠送道具出错，Reason=~w",[Reason]);
        {aborted, Error} ->
            ?ERROR_MSG("GM赠送道具出错，Reason=~w",[Error])
    end;

do_handle(Info, _State) ->
    ?ERROR_MSG("~ts:~w", ["GM命令地图辅助接口匹配到错误数据", Info]).

%%Local Functions

%%@doc 给予道具
t_add_item(_RoleID,GoodsList,[])->
    {ok,GoodsList};
t_add_item(RoleID,GoodsList,[AwdItem|T])->
    ?INFO_MSG("AwdItem:~w~n",[AwdItem]),
    {Type,ItemTypeID,Num} = AwdItem,
    CreateInfo = #r_goods_create_info{bind=true,type=Type, type_id=ItemTypeID, start_time=0, end_time=0, 
                                      num=Num, color=?COLOUR_WHITE,quality=?QUALITY_GENERAL,
                                      punch_num=0,interface_type=present},
    {ok,NewGoodsList} = mod_bag:create_goods(RoleID,CreateInfo),
    t_add_item(RoleID, lists:concat([NewGoodsList,GoodsList]) ,T).

internal_set_role_base(RoleID, RoleBase, ElementName, Value) ->
    List = record_info(fields, p_role_base),
    {ResultBool, TrueIndex} = internal_get_record_element_index(List, ElementName),
    if
        ResultBool =:= true ->
            NewRoleBase = erlang:setelement(TrueIndex, RoleBase, Value),
            mod_map_role:set_role_base(RoleID, NewRoleBase),
            NewRoleBase;
        true ->
            RoleBase
    end.

internal_set_role_attr(RoleID, RoleAttr, ElementName, Value) ->
    List = record_info(fields, p_role_attr),
    {ResultBool, TrueIndex} = internal_get_record_element_index(List, ElementName),
    if
        ResultBool =:= true ->
            NewRoleAttr = erlang:setelement(TrueIndex, RoleAttr, Value),
            mod_map_role:set_role_attr(RoleID, NewRoleAttr),
            NewRoleAttr;
        true ->
            RoleAttr
    end.

internal_get_record_element_index(ElementList, ElementName) ->
    lists:foldl(
        fun(E, {Bool, Index}) ->
            Index2 = Index+1,
            if
                E =:= ElementName ->
                    {true, Index2};
                Bool =:= true ->
                    {Bool, Index};
                true ->
                    {false, Index2}
             end
         end, {false, 1}, ElementList).

%% ====================================================================
%% Internal functions
%% ====================================================================

gm_set_mission(RoleID,MissionID,IsComplete) when is_integer(RoleID), is_integer(MissionID)->
    MissionBaseInfo = mod_mission_data:get_base_info(MissionID),
    
    LocalNow = calendar:local_time(),
    case IsComplete =:= true of
        true ->
            MissionIDList = [MissionID | get_pre_id_list(MissionID,[])];
        _ ->
            MissionIDList = get_pre_id_list(MissionID,[])
    end,
    #mission_data{counter_list=CounterListTmp} = mod_mission_data:get_mission_data(RoleID),
    DoneMissList = [ ID ||#mission_counter{id=ID}<-CounterListTmp],
    ExpSum = lists:foldl(fun(E,Acc)-> 
                             case lists:member(E, DoneMissList) of
                                 true->
                                     Acc;
                                 _ ->
                                     #mission_base_info{reward_data=RewardData} = mod_mission_data:get_base_info(E),
                                     #mission_reward_data{exp=Exp} = RewardData,
                                     Exp+Acc
                             end
                         end, 0, MissionIDList),
    CounterList = lists:map(fun(ID)->
                                #mission_counter{key={0, ID}, 
                                                 id=ID,big_group=0,last_clear_counter_time=LocalNow, 
                                                 commit_times=1,  succ_times=1}
                            end, MissionIDList),
    NewPInfo = get_new_pinfo(MissionBaseInfo),
    MissionData2 = #mission_data{last_store_time=common_tool:now(),
                                 data_version=common_tool:now(),
                                 mission_list=[NewPInfo],
                                 counter_list=CounterList},
    db:dirty_write(?DB_MISSION_DATA_P,#r_db_mission_data{role_id=RoleID ,mission_data=MissionData2}),
    mod_mission_data:init_role_data(RoleID, MissionData2),
    common_misc:send_to_rolemap(RoleID, {mod_map_role, {add_exp, RoleID, ExpSum}}),
    ok.

get_new_pinfo(MissionBaseInfo)->
    #p_mission_info{id=MissionBaseInfo#mission_base_info.id,
                                       model=MissionBaseInfo#mission_base_info.model,
                                       type=MissionBaseInfo#mission_base_info.type,
                                       current_status=1,
                                       pre_status=1,
                                       current_model_status=0,
                                       pre_model_status=0,
                                       commit_times=0,
                                       succ_times=0,
                                       accept_time=0,
                                       status_change_time=0,
                                       listener_list=[],
                                       int_list_1=[],
                                       int_list_2=[],
                                       int_list_3=[],
                                       int_list_4=[]}.

get_pre_id_list(0,Acc)->
    Acc;
get_pre_id_list(ID,Acc)->
    #mission_base_info{pre_mission_id=PreID} = mod_mission_data:get_base_info(ID),
    case PreID of
        0->
            Acc;
        _ ->
            get_pre_id_list(PreID,[PreID|Acc])
    end.

