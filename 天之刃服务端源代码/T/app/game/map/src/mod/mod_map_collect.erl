-module(mod_map_collect).

-include("mgeem.hrl").

-export([init/3,
         init_collect_points/1,
         get_collect_by_slice_list/1,
         handle/1,
         check_collect/0,
         stop_collect/2,
         role_state_change/2,
         new_point/1,
         delete_point/1,
         update_collect_to_slice/2,
         delete_collect_to_slice/2]).

-define(NOT_COLLECT,1).

-define(GENERAL,1).
-define(TIMING,2).

-define(NOT_BROADCAST,0).
-define(CAN_BROADCAST,1).

-define(DROP_TYPE_NORMAL,1).    %%普通的掉落类型
-define(MISSION_COLLECT_ROLES,mission_collect_roles).   %%记录正在任务采集的玩家列表

%% ====================================================================
%% API functions
%% ====================================================================

handle({update,State}) ->
    #map_state{mapid=MapID,offsetx=OffsetX, offsety=OffsetY}=State,
    remove_collect(),
    ?MODULE:init(MapID,OffsetX,OffsetY);
handle({{new_point,Point},State}) ->
    {_,Collects}=new_point(Point),
    update_collect_to_slice(Collects,State);
handle({Unique, Module, ?COLLECT_GET_GRAFTS_INFO, DataIn, RoleID, _Pid, Line,State}) ->
    do_get_collect_info(Unique,Module,?COLLECT_GET_GRAFTS_INFO,DataIn,RoleID,Line,State);
handle({_Unique, _Module, ?COLLECT_STOP, DataIn, RoleID, _Pid, _Line,_State}) ->
    do_stop_collect(DataIn,RoleID);
handle(Info) ->
    ?ERROR_MSG("~w, unrecognize msg: ~w", [?MODULE,Info]).

init_collect_points(DataCollectPoints) ->
    {ok, PointList} = file:consult(common_config:get_map_config_file_path(collect_point)),
    MapCollectPoints = [{Key,proplists:get_all_values(Key, DataCollectPoints)} || Key <- proplists:get_keys(DataCollectPoints)],
    CL = lists:foldl(
           fun({MapID,L},Acc1) ->
                   NL = lists:foldl(
                          fun({Id,X,Y}, Acc2) ->
                                  case lists:keyfind(Id,#p_collect_point_base_info.id,PointList) of
                                      false -> Acc2;
                                      Point -> [Point#p_collect_point_base_info{mapid=MapID,pos=#p_pos{tx=X,ty=Y,px=1,py=1,dir=0}}|Acc2]
                                  end
                          end,[],L),
                   [{P#p_collect_point_base_info.id,P} || P <- NL]++ [{{map,MapID},NL}|Acc1]
           end,[],MapCollectPoints),
    common_config_dyn:load_gen_src(collect_point,CL).

init(MapID,_OffsetX,_OffsetY) ->
    next(),
    Points = 
        case common_config_dyn:find(collect_point,{map,MapID}) of
            [] ->
                [];
            [PointsT] ->
                PointsT
        end,
    lists:foreach(
      fun(BasePoint) ->
              new_point(BasePoint)
      end,Points).

next() ->
    case get(collect_count) of
        undefined ->
            put(collect_count,2),
            1;
        N ->
            put(collect_count,N+1),
            N
    end.
new_point(#p_collect_point_base_info{id=ID,
                                     pos=Pos,
                                     max_num=Num,
                                     refresh=Refresh,
                                     ripening_time=Ripening,
                                     grafts=Grafts,
                                     drop_type=DropType}) ->
    NewID = 
        if is_integer(ID) =:= false ->
                next();
           true ->
                ID
        end,
    {StartTime,EndTime} = 
        if Refresh =:= undefined ->
                {0,0};
           Refresh#p_collect_refresh.type =:= ?TIMING ->
                {Refresh#p_collect_refresh.start_time,
                 Refresh#p_collect_refresh.end_time};
           Refresh#p_collect_refresh.type =:= ?GENERAL ->
                Now = common_tool:now(),
                {Now,
                 Now+Refresh#p_collect_refresh.interval}
        end,    
    ?DEBUG("start_time:~w end_time:~w~n",[StartTime,EndTime]),
    Sum = lists:foldl(fun(#p_collect{rate=Rate},S) -> Rate+S end,0,Grafts),
    {IDList,Collects} = 
        lists:foldl(
          fun({X,Y}, {Acc1,Acc2}) ->
                  Rate1 = random:uniform(Sum),
                  {ok,CollectTypeID} = get_collect_typeid(Rate1, Grafts),
                  case new_collect(NewID,CollectTypeID, X,Y) of
                      undefined ->
                          {Acc1,Acc2};
                      #p_map_collect{id=CollectID}=Collect ->
                          {[CollectID|Acc1],[Collect|Acc2]}
                  end
          end,{[],[]},get_pos_list(Pos,Num)),
    Point = #p_collect_point{id=NewID,
                             typeid=NewID,
                             state=?NOT_COLLECT,
                             pos=Pos,
                             start_time=StartTime,
                             end_time=EndTime,
                             id_list=IDList,
                             refresh=Refresh,
                             ripening_time=Ripening,
                             drop_type=DropType,
                             max_num=Num,
                             grafts=Grafts},
    case get(collect_point) of
        undefined ->
            put(collect_point,[Point]);
        List ->
            put(collect_point,[Point|List])
    end,
    {Point,Collects};
new_point(TypeID) ->
    [Config] = common_config_dyn:find(collect_point,TypeID),
    new_point(Config).

update_point(#p_collect_point{id=ID,
                              pos=Pos,
                              refresh=#p_collect_refresh{interval=Interval},
                              id_list=IDList,
                              max_num=MaxNum,
                              grafts=Grafts}=Point) ->
    Sum = lists:foldl(fun(#p_collect{rate=Rate},S) -> Rate+S end,0,Grafts),
    Collects = lists:foldl(
                 fun({X,Y}, Acc) ->
                         Rate1 = random:uniform(Sum),
                         {ok,CollectTypeID} = get_collect_typeid(Rate1, Grafts),
                         case new_collect(ID,CollectTypeID, X,Y) of
                             undefined -> 
                                 Acc;
                             Collect ->
                                 [Collect|Acc]
                         end
                 end,[],get_pos_list(Pos, MaxNum - erlang:length(IDList))),
    IDList2 = [Collect#p_map_collect.id || Collect <- Collects, Collect =/= undefined],
    {Point#p_collect_point{id_list=IDList++IDList2,end_time=common_tool:now()+Interval},Collects}.

delete_point(#p_collect_point{id=ID,id_list=IDList}) ->
    Points = get(collect_point),
    NewPoints = lists:keydelete(ID,#p_collect_point.id,Points),
    put(collect_point,NewPoints),
    lists:foldl(
      fun(CollectID,AccList) ->
              case del_collect(CollectID) of
                  undefined ->
                      AccList;
                  Info ->
                      [Info|AccList]
              end
      end,[],IDList);
delete_point(ID) ->
    case get(collect_point) of
        undefined ->
            [];
        List ->
            case lists:keyfind(ID, #p_collect_point.id, List) of
                false -> [];
                Point -> delete_point(Point)
            end
    end.

new_collect(PointID,TypeID, X,Y) ->
    case get({X,Y}) of 
        undefined ->
            ?DEBUG("X:~w Y:~w Can not be used~n",[X,Y]),
            undefined;
        _ ->
            case get({ref_collect,X,Y}) of
                undefined ->
                    ID = next(),
                    #map_state{offsetx = OffsetX, 
                               offsety = OffsetY} = mgeem_map:get_state(),
                    Info = make_collect_info(ID,TypeID,PointID,X,Y),
                    Slice = mgeem_map:get_slice_by_txty(X, Y, OffsetX, OffsetY),
                    case get({collection,Slice}) of
                        undefined ->
                            put({collection,Slice},[Info]);
                        CollectList ->
                            put({collection,Slice},[Info|CollectList])
                    end,
                    put({ref_collect,X,Y},ID),
                    put({collect,ID},Info),
                    Info;
                _ ->
                    ?DEBUG("X:~w Y:~w Has been used~n",[X,Y]),
                    undefined
            end
    end.

make_collect_info(ID,TypeID,PointID,X,Y) ->
    [#p_collect_base_info{name=Name,
                          degree=Degree,
                          demand=Demand,
                          times=Times,
                          goodslist=GoodsList,
                          tool_typeid=ToolTypeID}]
        = common_config_dyn:find(collect_base,TypeID),
    #p_map_collect{id = ID,
                   typeid = TypeID,
                   name=Name,
                   degree=Degree,
                   demand=Demand,
                   times=Times,
                   goodslist=GoodsList,
                   tool_typeid=ToolTypeID,
                   point_id=PointID,
                   pos = #p_pos{tx=X,ty=Y},
                   roles=[]
                  }.

del_collect(ID) ->
    case erase({collect,ID}) of 
        undefined ->
            undefined;
        #p_map_collect{id=CollectID,pos=#p_pos{tx=X,ty=Y}}=Info ->
            #map_state{offsetx = OffsetX, 
                       offsety = OffsetY} = mgeem_map:get_state(),
            Slice = mgeem_map:get_slice_by_txty(X, Y, OffsetX, OffsetY),
            CollectList = get({collection,Slice}),
            NewList = lists:keydelete(CollectID,#p_map_collect.id,CollectList),
            put({collection,Slice},NewList), 
            erase({ref_collect,X,Y}),
            Info
    end.

get_collect_typeid(Rate1, Grafts) ->
    catch lists:foldl(
            fun(#p_collect{rate=Rate2},S)
                  when (Rate2+S) < Rate1 ->
                    Rate2+S;
               (#p_collect{typeid=TypeID},_S) ->
                    throw({ok, TypeID})
            end,0,Grafts).

get_pos_list(Pos,Num) ->
    #p_pos{tx=Tx,ty=Ty} = Pos,
    STEP = (Num div 2)+1,
    XList = lists:seq(Tx-STEP,Tx+STEP),
    YList = lists:seq(Ty-STEP,Ty+STEP),
    {PosList0,Length} =
        lists:foldl(
          fun(X,{APL1,AN1}) ->
                  lists:foldl(
                    fun(Y,{APL2,AN2}) ->
                            {[{X,Y}|APL2],AN2+1}
                    end,{APL1,AN1},YList)
          end,{[],0},XList),
    {PosList1, _}=
        lists:foldl(
          fun(N, {APL,PL}) ->
                  U = random:uniform(Length-N),
                  R = lists:nth(U,PL),
                  {[R|APL],lists:delete(R,PL)}
          end,{[],PosList0},lists:seq(1,Num)),
    PosList1.
              
get_collect_by_slice_list(AllSlice) ->
    lists:foldl(
      fun(SliceName, Acc) ->
              case get({collection,SliceName}) of 
                  undefined ->
                      Acc;
                  CollectList ->
                      common_tool:combine_lists(CollectList, Acc)
              end
      end, [], AllSlice).



%% 开始采集
do_get_collect_info(Unique,Module,Method,DataIn,RoleID,Line,State) ->
    try
        %%强制玩家下马
        mod_equip_mount:force_mountdown(RoleID),
                        
        #m_collect_get_grafts_info_tos{id=Id} = DataIn,
        case stop_collect(RoleID,?_LANG_COLLECT_BREAK) of
            ignore ->
                next;
            _ ->
                throw(?_LANG_COLLECT_BREAK)
        end,
        RoleMapInfo =  mod_map_actor:get_actor_mapinfo(RoleID, role),
        case RoleMapInfo#p_map_role.state of
            ?ROLE_STATE_NORMAL ->%%正常状态
                next;
            ?ROLE_STATE_DEAD ->%%死亡状态
                throw(?_LANG_COLLECT_ROLE_STATE_DEAD);
            ?ROLE_STATE_FIGHT ->%%战斗状态
                throw(?_LANG_COLLECT_ROLE_STATE_FIGHT);
            ?ROLE_STATE_EXCHANGE ->%%交易状态
                throw(?_LANG_COLLECT_ROLE_STATE_EXCHANGE);
            ?ROLE_STATE_ZAZEN ->%%打坐状态
                throw(?_LANG_COLLECT_ROLE_STATE_ZAZEN);
            ?ROLE_STATE_STALL ->%%摆摊状态
                throw(?_LANG_COLLECT_ROLE_STATE_STALL);
            ?ROLE_STATE_TRAINING ->%%训练状态
                throw(?_LANG_COLLECT_ROLE_STATE_TRAINING);
            ?ROLE_STATE_COLLECT ->
                throw(?_LANG_COLLECT_ROLE_STATE_COLLECT)
        end,
        case get({collect,Id}) of
            undefined ->
                throw(?_LANG_COLLECT_NO_GRAFTS);
            Info ->
                case check_is_mission_collect(RoleID,Info) of
                    true->
                        do_start_mission_collect(RoleID,Info,[Line, Unique, Module, Method]);
                    _ ->
                        case check_can_collect_for_10500(Info,State) of 
                            {ok} ->
                                Data = do_get_collect_info2(RoleID,State,Info),
                                common_misc:unicast(Line, RoleID, Unique, Module, Method, Data);
                            {error,Reason10500} ->
                                throw(Reason10500)
                        end
                end
        end
    catch
        _:Reason1 when is_binary(Reason1) ->
            Data1 = #m_collect_get_grafts_info_toc{succ=false,reason=Reason1},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Data1);
        _:Reason1 ->
            ?DEBUG("~ts:~w~n",["采集出错",Reason1]),
            Data1 = #m_collect_get_grafts_info_toc{succ=false,reason=?_LANG_SYSTEM_ERROR},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, Data1)
    end.
%% 检查当前采集是不是在大明宝藏地图内
%% 是否有人已经在采集此采集物
%% 参数
%% Info 结构为：p_map_collect
%% State 结构为：map_state
%% 返回 {ok} or {error,Reason}
check_can_collect_for_10500(Info,State) ->
    #map_state{mapid=MapID}=State,
    #p_map_collect{roles = CollectRoles} = Info,
    case MapID =:= 10500 andalso CollectRoles of
        [#p_collect_role{roleid = RoleId}] ->
            #p_map_role{role_name = RoleName} = mod_map_actor:get_actor_mapinfo(RoleId,role),
            Reason = lists:flatten(io_lib:format(?_LANG_COLLECT_ROLE_COLLECTED,[RoleName])),
            {error,common_tool:to_binary(Reason)};
        _ ->
            {ok}
    end.

do_get_collect_info2(RoleID,State,Info) ->
    case common_transaction:transaction(
           fun() ->
                   {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
                   {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
                   case check_has_tool(Info#p_map_collect.tool_typeid,RoleAttr) of
                       ok ->
                           next;
                       {ok,ToolID}->
                           [Tool] = mod_bag:get_goods_by_id(RoleID,ToolID),
                           NewTool = Tool#p_goods{current_endurance=Tool#p_goods.current_endurance-1},
                           NewRoleAttr = RoleAttr#p_role_attr{
                                           equips=lists:keyreplace(Tool#p_goods.id,#p_goods.id,RoleAttr#p_role_attr.equips,NewTool)},
                           mod_bag:update_goods(RoleID,NewTool),
                           mod_map_role:set_role_attr(RoleID, NewRoleAttr);
                       {error,Reason1} ->
                           db:abort(Reason1)
                   end,  
                   case check_pos(Info#p_map_collect.pos,RoleID) of
                       ok ->
                           next;
                       {error,Reason2} ->
                           db:abort(Reason2)
                   end,
                   case check_demand(Info#p_map_collect.demand,RoleBase,RoleAttr) of
                       ok ->
                           next;
                       {error,Reason3} ->
                           db:abort(Reason3)
                   end
           end)
    of
        {aborted, Reason}when is_binary(Reason) ->
            #m_collect_get_grafts_info_toc{succ=false,reason=Reason};
        {aborted, Reason} ->
            ?DEBUG("~ts:~w~n",["采集出错",Reason]),
            #m_collect_get_grafts_info_toc{succ=false,reason=?_LANG_SYSTEM_ERROR};
        {atomic, _} ->
            StartTime = common_tool:now(),
            EndTime = StartTime+Info#p_map_collect.times,
            CollectRole = #p_collect_role{roleid=RoleID,start_time=StartTime,end_time=EndTime},
            OldRoles = lists:reverse(Info#p_map_collect.roles),
            NewInfo=Info#p_map_collect{roles=lists:reverse([CollectRole|OldRoles])},
            #map_state{offsetx = OffsetX, offsety = OffsetY} = State,
            #p_pos{tx=X,ty=Y}=Info#p_map_collect.pos,
            Slice = mgeem_map:get_slice_by_txty(X, Y, OffsetX, OffsetY),
            CollectList = get({collection,Slice}),
            NewList = lists:keydelete(NewInfo#p_map_collect.id,#p_map_collect.id,CollectList),
            put({collect_role,RoleID},NewInfo#p_map_collect.id),
            put({collection,Slice},[NewInfo|NewList]),
            put({collect,NewInfo#p_map_collect.id},NewInfo),
            updata_collect_end_time(NewInfo#p_map_collect.point_id),
            Change = [{#p_map_role.state, ?ROLE_STATE_COLLECT}],
            mod_map_role:do_update_map_role_info(RoleID, Change, State),
            #m_collect_get_grafts_info_toc{succ=true,info=Info}
    end.

do_stop_collect(DataIn,RoleID) ->
    #m_collect_stop_tos{id=Id}=DataIn,
    case get({collect,Id}) of
        undefined ->
            ignore;
        Collect ->
            remove_collect_role(RoleID,Collect,?_LANG_COLLECT_BREAK)
    end.

check_has_tool(0, _) ->
    ok;
check_has_tool(ToolTypeID,RoleAttr) ->
    case lists:keyfind(ToolTypeID,#p_goods.typeid,RoleAttr#p_role_attr.equips) of
        false ->
            {error,?_LANG_COLLECT_NO_TOOL};
        Tool ->
            {ok,Tool#p_goods.id}
    end.

check_pos(#p_pos{tx=Tx1,ty=Ty1},RoleID) ->
    case mod_map_actor:get_actor_pos(RoleID, role) of
        undefined ->
            {error, ?_LANG_SYSTEM_ERROR};
        #p_pos{tx=Tx2, ty=Ty2} ->
            case erlang:abs(Tx1-Tx2)=<1 andalso erlang:abs(Ty1-Ty2)=<1 of
                true ->
                    ok;
                false ->
                    {error,?_LANG_COLLECT_FAR_FROM}
            end
    end.

%%检查采集的条件
check_demand(Demand,_RoleBase,RoleAttr) ->
    if Demand#p_collect_demand.min_level =< RoleAttr#p_role_attr.level andalso
       Demand#p_collect_demand.max_level >= RoleAttr#p_role_attr.level ->
            ok;
       true ->
            {error,?_LANG_COLLECT_LEVEL_ENOUGH}
    end.

updata_collect_end_time(CollectPointID) ->
    case get(collect_point) of
        undefined ->
            ignore;
        PointList ->
            case lists:keytake(CollectPointID, #p_collect_point.id, PointList) of
                {value, CollectPoint, NewPointList} ->
                    if (CollectPoint#p_collect_point.refresh)#p_collect_refresh.type =:= ?TIMING ->
                            ignore;
                       (CollectPoint#p_collect_point.refresh)#p_collect_refresh.type =:= ?GENERAL ->
                            NewCollectPoint = CollectPoint#p_collect_point{end_time=common_tool:now()+
                                                                        (CollectPoint#p_collect_point.refresh)#p_collect_refresh.interval},
                            put(collect_point,[NewCollectPoint| NewPointList]);
                       true ->
                            ignore
                    end;
                false ->
                    %%?DEBUG("CollectPointID:~w PointList:~w~n",[CollectPointID,PointList]),
                    ignore
            end
    end.


%%@doc 检查新手任务类型的采集，如果满足时间条件，则直接赠送采集物品
%%  added by wuzesen
check_mission_collect()->
    case get(?MISSION_COLLECT_ROLES) of
        undefined->
            ignore;
        []->
            ignore;
        List ->
            check_mission_collect_2(List)
    end.
check_mission_collect_2(List)->
    Now = common_tool:now(),
    lists:foreach(
      fun({RoleID,EndTime,PropGoodsList})-> 
              if
                  Now>=EndTime->
                      check_mission_collect_3(RoleID,PropGoodsList),
                      List2 = lists:keydelete(RoleID, 1, List),
                      put(?MISSION_COLLECT_ROLES,List2),
                      ok;
                  true->
                      ignore
              end
      end, List).
check_mission_collect_3(RoleID,GoodsList) when is_list(GoodsList)->
    case common_transaction:t(  
           fun() -> t_create_goods(RoleID,GoodsList) end) 
        of 
        {aborted, Reason}when is_binary(Reason) ->
            TocData = #m_collect_grafts_toc{succ=false,reason=Reason};
        {aborted,{bag_error,not_enough_pos}} ->
            TocData = #m_collect_grafts_toc{succ=false,reason=?_LANG_COLLECT_BAG_NOT_ENOUGH};
        {aborted, Reason} ->
            ?ERROR_MSG_STACK("check_mission_collect_3",Reason),
            TocData = #m_collect_grafts_toc{succ=false,reason=?_LANG_SYSTEM_ERROR};
        {atomic, {ok,GoodsInfoList,Num,_IsBroadcast}} ->
            collect_goods_log(GoodsInfoList,Num),
            hook_prop:hook(create, GoodsInfoList),
            common_misc:update_goods_notify({role,RoleID}, GoodsInfoList),
            TocData = #m_collect_grafts_toc{succ=true,goods_list=GoodsInfoList}
    end,
    common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?COLLECT, ?COLLECT_GRAFTS, TocData),
    ok.

%%@doc 判断是否真正做新手任务的采集
check_is_mission_collect(RoleID,Info) when is_record(Info,p_map_collect)->
    #p_map_collect{point_id=CollectPointId} = Info,
    IsDoing = mod_mission_misc:is_doing_collect(RoleID, CollectPointId),
    IsDoing.

%%@doc 开始执行任务的采集流程
do_start_mission_collect(RoleID,Info,[Line, Unique, Module, Method]) when is_record(Info,p_map_collect)->
    #p_map_collect{times = NeedTimes,goodslist=PropGoodsList} = Info,
    EndTime = common_tool:now() + NeedTimes,
    CollectRoleInfo = {RoleID,EndTime,PropGoodsList},
    case get(?MISSION_COLLECT_ROLES) of
        undefined->
            common_misc:update_dict_queue(?MISSION_COLLECT_ROLES,CollectRoleInfo);
        List1 ->
            List2 = lists:keystore(RoleID, 1, List1, CollectRoleInfo),
            put(?MISSION_COLLECT_ROLES,List2)
    end,
    R2 = #m_collect_get_grafts_info_toc{succ=true,info=Info},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R2),
    ok.

check_collect() ->
    ?TRY_CATCH( check_mission_collect() ),
    %%?DEBUG("检查时间 ~w~n",[self()]),
    PointList = 
        case get(collect_point) of
            undefined ->
                [];
            List ->
                %%?DEBUG("检查时间采集点:~w~w~n",[self(),List]),
                List          
        end,
    NewPointList = 
        lists:foldl(
          fun(Point,AccList) ->
                  case check_point(Point) of
                      false ->
                          AccList;
                      {ok,NewPoint} ->
                          [NewPoint|AccList]
                  end
          end,[],PointList),
    put(collect_point,NewPointList).

check_point(Point) ->
    Now = common_tool:now(),
    State = mgeem_map:get_state(),
    %%?DEBUG("State:~w~n",[State]),
    #p_collect_point{start_time=StartTime,
                     end_time=EndTime,
                     refresh=Refresh,
                     ripening_time=Ripening}=Point,
    case Refresh of
        undefined ->
            case check_grafts(Point, State) of
                false -> 
                    false;
                NewPoint ->
                    
                    case NewPoint#p_collect_point.id_list of
                        [] ->  false;
                        [_|_] ->  {ok, NewPoint}
                    end
            end;
        #p_collect_refresh{type=Type} ->
            if StartTime =:= 0 andalso EndTime =:= 0 ->
                   case check_grafts(Point, State) of
                       false ->
                           false;
                       NewPoint ->
                           case NewPoint#p_collect_point.id_list of
                               [] -> false;
                               [_|_] -> {ok, NewPoint}
                           end
                   end;
               (StartTime+Ripening) >= Now ->
                    {ok,Point};
               EndTime =< Now andalso Type =:= ?GENERAL ->
                    {NewPoint,Collects} = update_point(Point),
                    update_collect_to_slice(Collects,State),
                    {ok,NewPoint};
               EndTime =< Now andalso Type =:= ?TIMING ->
                    Collects = delete_point(Point),
                    delete_collect_to_slice(Collects,State),
                    false;
               EndTime > Now ->
                    case check_grafts(Point, State) of
                       false ->
                           false;
                       NewPoint ->
                           {ok, NewPoint}
                   end;
               true ->
                    {ok,Point}
            end
    end.

update_collect_to_slice(Collects,State) ->
    #map_state{offsetx = OffsetX, 
               offsety = OffsetY} = State,
    AllSlice = lists:foldl(
                 fun(Collect,AccList1) ->
                         #p_pos{tx=X,ty=Y} = Collect#p_map_collect.pos,
                         SliceList = mgeem_map:get_9_slice_by_txty(X, Y, OffsetX, OffsetY),
                         lists:foldl(
                           fun(Slice,AccList2) ->  
                                   [Slice|lists:delete(Slice,AccList2)]
                           end,AccList1,SliceList)
                 end,[],Collects),
    RoleList = mgeem_map:get_all_in_sence_user_by_slice_list(AllSlice),
    Record = #m_collect_updata_grafts_toc{grafts=Collects},
    mgeem_map:broadcast(RoleList, ?DEFAULT_UNIQUE, ?COLLECT, ?COLLECT_UPDATA_GRAFTS, Record).

delete_collect_to_slice(Collects,State) ->
    #map_state{offsetx = OffsetX, 
               offsety = OffsetY} = State,
    AllSlice = lists:foldl(
                 fun(Collect,AccList1) ->
                         #p_pos{tx=X,ty=Y} = Collect#p_map_collect.pos,
                         SliceList = mgeem_map:get_9_slice_by_txty(X, Y, OffsetX, OffsetY),
                         lists:foldl(
                           fun(Slice,AccList2) ->  
                                   [Slice|lists:delete(Slice,AccList2)]
                           end,AccList1,SliceList)
                 end,[],Collects),
    RoleList1 = mgeem_map:get_all_in_sence_user_by_slice_list(AllSlice),
    RoleList2 = lists:foldl(
                  fun(#p_map_collect{roles=Roles},Acc1) ->
                          lists:foldl(
                            fun(#p_collect_role{roleid=CRoleID}, Acc2) ->
                                    [CRoleID|Acc2]
                            end,Acc1,Roles)
                  end,[],Collects),
    %%?DEBUG("RoleList:~w~n",[RoleList]),
    Record = #m_collect_remove_grafts_toc{grafts=Collects},
    mgeem_map:broadcast(RoleList1, ?DEFAULT_UNIQUE, ?COLLECT, ?COLLECT_REMOVE_GRAFTS, Record),
    lists:foreach(
      fun(RoleID) ->
              Change = [{#p_map_role.state, ?ROLE_STATE_NORMAL}],
              Data=#m_collect_grafts_toc{succ=false,reason=?_LANG_COLLECT_DELETE_GRAFTS},
              mod_map_role:do_update_map_role_info(RoleID, Change, State),
              common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?COLLECT, ?COLLECT_GRAFTS, Data)
      end,RoleList2).

check_grafts(Point,State) ->
    {NewIDList,_DelCollects,FamilyCollectDelList} = 
        lists:foldl(
          fun(ID,{AccIDList,AccDel,FamilyCollectDelListAcc}) ->
                  case get({collect,ID}) of
                      undefined ->
                          {AccIDList,AccDel,FamilyCollectDelListAcc};
                      Info ->
                          %%?DEBUG("Collect Roles:~w~n",[Info#p_map_collect.roles]),
                          case check_collect_roles(Info) of
                              false ->
                                  %%?DEBUG("Can't Collect Role ! @@@@@@@@@@@@@@@@@@@@@@@@@@~n",[]),
                                  {[ID|AccIDList],AccDel,FamilyCollectDelListAcc};
                              {ok,RoleID,Roles} ->
                                  %% ?DEBUG("Collect RoleID:~w~n",[RoleID]),
                                  %%门派采集TD玩家特殊处理，这里门派采集TD的每个采集点肯定只有一个固定的采集物
                                  case  mod_family_collect:check_is_family_collect(Point#p_collect_point.id) of
                                      false ->
                                          NewFamilyCollectDelListAcc = FamilyCollectDelListAcc,       
                                          TocData = creat_goods(RoleID,Info#p_map_collect.goodslist,Point,State),
                                          common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?COLLECT, ?COLLECT_GRAFTS, TocData);
                                      true ->
                                          case mod_family_collect:hook_collect(Point#p_collect_point.id) of
                                              delete ->
                                                  NewFamilyCollectDelListAcc = [ID|FamilyCollectDelListAcc];
                                              _ ->
                                                  NewFamilyCollectDelListAcc = FamilyCollectDelListAcc
                                          end,
                                          TocData = #m_collect_grafts_toc{succ=true,goods_list=[]},
                                          common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?COLLECT, ?COLLECT_GRAFTS, TocData)
                                  end,
                                  #p_pos{tx=X,ty=Y} = Info#p_map_collect.pos,
                                  #map_state{offsetx = OffsetX, offsety = OffsetY} = State,
                                  SliceList = mgeem_map:get_9_slice_by_txty(X, Y, OffsetX, OffsetY),
                                  RoleList1 = mgeem_map:get_all_in_sence_user_by_slice_list(SliceList),
                                  Record = #m_collect_remove_grafts_toc{grafts=[Info]},
                                  mgeem_map:broadcast(lists:subtract(RoleList1,Roles), ?DEFAULT_UNIQUE, ?COLLECT, ?COLLECT_REMOVE_GRAFTS, Record),
                                  lists:foreach(
                                    fun(#p_collect_role{roleid=RoleID1}) ->
                                            Change = [{#p_map_role.state, ?ROLE_STATE_NORMAL}],
                                            mod_map_role:do_update_map_role_info(RoleID1, Change, State),
                                            Data=#m_collect_grafts_toc{succ=false,reason=?_LANG_GOLLECT_HAS_COLLECT},
                                            common_misc:unicast({role,RoleID1}, ?DEFAULT_UNIQUE, ?COLLECT, ?COLLECT_GRAFTS, Data)
                                    end,Roles),
                                  Change = [{#p_map_role.state, ?ROLE_STATE_NORMAL}],
                                  mod_map_role:do_update_map_role_info(RoleID, Change, State),
                                  del_collect(ID),
                                  erase({collect_role,RoleID}),
                                  {AccIDList,[Info|AccDel],NewFamilyCollectDelListAcc}
                          end
                  end
          end,{[],[],[]},Point#p_collect_point.id_list),
    case FamilyCollectDelList of
        [] ->
            Point#p_collect_point{id_list=NewIDList};
        _ -> 
            false
    end.

check_collect_roles(Info) ->
    Now = common_tool:now(),
    case lists:foldl(
           fun(Role,{nil,AccRoles})
                 when Role#p_collect_role.end_time > Now ->
                   {nil,[Role|AccRoles]};
              (Role,{nil,AccRoles}) ->
                   {Role,AccRoles};
              (Role,{AccRole,AccRoles}) ->
                   {AccRole,[Role|AccRoles]}
           end,{nil,[]},Info#p_map_collect.roles)
    of
        {nil,_Roles} ->
            false;
        {Role,Roles} ->
            {ok,
             Role#p_collect_role.roleid,
             Roles}
    end.

t_create_goods(RoleID,GoodsList) when is_list(GoodsList)->
  Sum = lists:foldl(fun(#p_collect_goods{rate=Rate},S) -> Rate+S end,0,GoodsList),
  Rate1 = random:uniform(Sum),
  
  {ok,Goods} = (catch lists:foldl(
                  fun(G,S)when G#p_collect_goods.rate+S < Rate1 ->
                      G#p_collect_goods.rate+S;
                   (G,_) ->
                    throw({ok,G}) 
                  end,0,GoodsList)),
  
  #p_collect_goods{goods_type=Type,
                   goods_typeid=TypeID,
                   goods_start_time=StartTime,
                   goods_end_time=EndTime,
                   goods_bind=Bind,
                   goods_num=Num,
                   is_broadcast=IsBroadcast
                  }=Goods,
  CreateInfo = #r_goods_create_info{type=Type,type_id=TypeID,num=Num,
                                    bind=Bind,start_time=StartTime,end_time=EndTime},
  {ok,GoodsInfoList} = mod_bag:create_goods(RoleID,CreateInfo),
  {ok,GoodsInfoList,Num,IsBroadcast}.

creat_goods(RoleID,GoodsList,Point,State) ->  
    case common_transaction:t(  
            fun() -> t_create_goods(RoleID,GoodsList) end) 
    of 
        {aborted, Reason}when is_binary(Reason) ->
            Data = #m_collect_grafts_toc{succ=false,reason=Reason};
        {aborted,{bag_error,not_enough_pos}} ->
            Data = #m_collect_grafts_toc{succ=false,reason=?_LANG_COLLECT_BAG_NOT_ENOUGH};
        {aborted, Reason} ->
            ?DEBUG("~ts:~w~n",["采集生成物品时错误",Reason]),
            Data = #m_collect_grafts_toc{succ=false,reason=?_LANG_SYSTEM_ERROR};
        {atomic, {ok,GoodsInfoList,Num,IsBroadcast}} ->
            collect_goods_log(GoodsInfoList,Num),
            case IsBroadcast of
                ?NOT_BROADCAST ->
                    ignore;
                ?CAN_BROADCAST ->
                    catch collect_broadcast(RoleID,GoodsInfoList,State)
            end,
            hook_prop:hook(create, GoodsInfoList),
            case Point#p_collect_point.drop_type of
                ?DROP_TYPE_NORMAL->
                    RedBagList = hook_activity_map:hook_collect(RoleID),
                    AllGoodsList = lists:concat([GoodsInfoList,RedBagList]);
                _ ->
                    AllGoodsList = GoodsInfoList
            end,
            
            common_misc:update_goods_notify({role,RoleID}, AllGoodsList),
            Data = #m_collect_grafts_toc{succ=true,goods_list=AllGoodsList},
            %% 当什么东西都采不到的话，则给经验
            case GoodsInfoList of
                [] ->
                    [ExpAdd] = common_config_dyn:find(etc, collect_exp_add),
                    mod_map_role:do_add_exp(RoleID, ExpAdd),
                    ok;
                _ ->
                    ignore
            end
    end,
    Data.

%%@doc 记录采集获得的道具日志
collect_goods_log(GoodsList,Num) ->
    State = mgeem_map:get_state(),
    MapID = State#map_state.mapid,
    IsCountryTreasureMapId = mod_country_treasure:get_default_map_id() =:= MapID,
    IsSceneWarFbMapId = mod_scene_war_fb:is_scene_war_fb_map_id(MapID),
    if IsCountryTreasureMapId =:= true ->
            LogAction = ?LOG_ITEM_TYPE_CAI_JI_COUNTRY_TREASURE;
       IsSceneWarFbMapId =:= true ->
            LogAction =?LOG_ITEM_TYPE_CAI_JI_SCENE_WAR_FB;
        true ->
            LogAction = ?LOG_ITEM_TYPE_CAI_JI_HUO_DE
    end,
    lists:foreach(
      fun(Goods) ->
              #p_goods{roleid=RoleID}=Goods,
              common_item_logger:log(RoleID,Goods,Num,LogAction)
      end,GoodsList).

collect_broadcast(RoleID,GoodsInfoList,State) ->
    #map_state{mapid=Mapid}=State,
    if Mapid =:= 10500 ->
            %% 成就 大明宝藏，挖到上电视的宝贝:303002 add by caochuncheng 2011-03-04
            common_hook_achievement:hook({mod_fb,{country_treasure_collect,RoleID}});
       true ->
            next
    end,
    {ok,#p_role_base{role_name=RoleName,faction_id = FactionID}} = 
        mod_map_role:get_role_base(RoleID),
    Addr = common_map:get_map_str_name(Mapid),
    Result = (Mapid div 1000) rem 10,
    ?DEBUG("Result:~w,FactionID:~w~n",[Result,FactionID]),
    if Result =:= 0 orelse 
       Result =/= FactionID ->
            lists:foreach(
              fun(Goods) ->
                      ?DEBUG("Goods Colour:~w~n",[Goods#p_goods.current_colour]),
                      GoodsName = common_misc:format_goods_name_colour(Goods#p_goods.current_colour,Goods#p_goods.name),
                      Text = format_broadcasting(FactionID,RoleName,Addr,GoodsName,Mapid),
                      common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], ?BC_MSG_TYPE_CHAT_WORLD, Text)
              end,GoodsInfoList);
       true ->
            lists:foreach(
              fun(Goods) ->
                      ?DEBUG("Goods Colour:~w~n",[Goods#p_goods.current_colour]),
                      GoodsName = common_misc:format_goods_name_colour(Goods#p_goods.current_colour,Goods#p_goods.name),
                      Text = format_broadcasting(RoleName,Addr,GoodsName),
                      common_broadcast:bc_send_msg_faction(FactionID, [?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], ?BC_MSG_TYPE_CHAT_WORLD, Text)
              end,GoodsInfoList)
    end.

format_broadcasting(RoleName,Addr,GoodsName) ->
    NewAddr = 
        case Addr of
            "幽州-" ++ R ->
                R;
            "云州-" ++ R ->
                R;
            "沧州-" ++ R ->
                R;
            R ->
                R
        end,
    NewRoleName = common_tool:to_list(RoleName),
    NewGoodsName = common_tool:to_list(GoodsName),
    lists:flatten(io_lib:format(?_LANG_COLLECT_CHAT_BROADCAST_1,[NewRoleName,NewAddr,NewGoodsName])).
    
format_broadcasting(FactionID,RoleName,Addr,GoodsName,Mapid) ->
    FactionName = 
        case FactionID of
            1 ->
                ?_LANG_COLLECT_HONGWU_COLOR;
            2 ->
                ?_LANG_COLLECT_YONGLE_COLOR;
            3 ->
                ?_LANG_COLLECT_WANLI_COLOR
        end,
    NewRoleName = common_tool:to_list(RoleName),
    NewGoodsName = common_tool:to_list(GoodsName),
    if Mapid =:= 10500 ->
            mod_country_treasure:get_collect_broadcast_msg(NewRoleName, FactionID, FactionName, Addr, NewGoodsName);
       true ->
            lists:flatten(io_lib:format(?_LANG_COLLECT_CHAT_BROADCAST_2,[FactionName,NewRoleName,Addr,NewGoodsName]))
    end.

remove_collect_role(RoleID,Collect,Reason) ->
    MapState = mgeem_map:get_state(),
    Change = [{#p_map_role.state, ?ROLE_STATE_NORMAL}],
    NewRoles = lists:keydelete(RoleID,#p_collect_role.roleid,Collect#p_map_collect.roles),
    put({collect,Collect#p_map_collect.id},Collect#p_map_collect{roles=NewRoles}),
    Data = #m_collect_grafts_toc{succ=false,reason=Reason},
    common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?COLLECT, ?COLLECT_GRAFTS, Data),
    erase({collect_role,RoleID}),
    mod_map_role:do_update_map_role_info(RoleID, Change, MapState).

stop_collect(RoleID,_Reason) ->
    case get({collect_role,RoleID}) of
        undefined ->
            ignore;
        CollectID->
            case get({collect,CollectID}) of
                undefined ->
                    ignore;
                Collect ->
                    remove_collect_role(RoleID,Collect,_Reason)
            end
    end.

remove_collect() ->
    {dictionary,DictL} = erlang:process_info(self(),dictionary),
    Collects = lists:foldl(
                 fun({collect_point,_},AL) ->
                         erlang:erase(collect_point),
                         AL;
                    ({{ref_collect,X,Y},_},AL) ->
                         erlang:erase({ref_collect,X,Y}),
                         AL;
                    ({{collection,Slice},_},AL) ->
                         erlang:erase({collection,Slice}),
                         AL;
                    ({{collect,Id},Collect},AL) ->
                         erlang:erase({collect,Id}),
                         [Collect|AL];
                    (_,AL) ->
                         AL
                 end,[],DictL),
    delete_collect_to_slice(Collects,mgeem_map:get_state()).
    
%%玩家状态改变时，判断是否应清除采集标识
role_state_change(RoleID,NewState)when NewState =/= ?ROLE_STATE_COLLECT ->
    case get({collect_role,RoleID}) of
        undefined ->
            ignore;
        CollectID->
            case get({collect,CollectID}) of
                undefined ->
                    ignore;
                Collect ->
                    remove_collect_role(RoleID,Collect,?_LANG_COLLECT_BREAK)
            end
    end;
role_state_change(_RoleID,_NewState) ->
    ignore.


