%% Author: liuwei
%% Created: 2010-5-26
%% Description: TODO: Add description to mod_map_drop
-module(mod_map_drop).

-include("mgeem.hrl").

-export([
         init/0,
         handle/2,
         drop_thing/3,
         get_new_dropthing_id/0,
         get_dropthing_by_slice_list/2,
         dropthing_no_protect/5,
         do_pick_dropthing_return/3,
         drop_silver/2
        ]).

-export([
         set_role_monster_drop/2,
         clear_role_monster_drop/1,
         get_role_monster_drop/1]).

-export([
         is_in_team_drop_map/0]).

-define(ETS_DROPTHING_COUNTER,dropthing_counter).
-define(PICK_DISTANCE, 10).


-define(DROPTHING_PROTECT_OVER_TIME,60000). %%60秒
-define(DROPTHING_QUIT_MAP_TIME,300000). %%300秒

-record(monster_drop_broadcast,{monster_type,content,goods_type_list}).

%%
%% API Functions
%%
init() ->
    case ets:info(?ETS_DROPTHING_COUNTER) of
        undefined ->
            ets:new(?ETS_DROPTHING_COUNTER,[set,public, named_table]);
        _ ->
            nil
    end.

handle(Msg,State) ->
    do_handle(Msg, State).

%%@doc 判断是否在组队掉落的地图中
is_in_team_drop_map_for_boss()->
    MapId = mgeem_map:get_mapid(),
    case common_config_dyn:find(etc,team_drop_map_list_for_boss) of
        []->
            false;
        [MapIdList]->
            lists:member(MapId, MapIdList)
    end.

is_in_team_drop_map()->
    MapId = mgeem_map:get_mapid(),
    case common_config_dyn:find(etc,team_drop_map_list_for_all) of
        []->
            false;
        [MapIdList]->
            lists:member(MapId, MapIdList)
    end.

dropthing_no_protect(RoleID, DropThingList, ActorID, ActorType, State) ->
    do_dropthing(RoleID, DropThingList, ActorID, ActorType, State).

get_new_dropthing_id() ->
    MapName = mgeem_map:get_mapname(),
    case ets:lookup(?ETS_DROPTHING_COUNTER, MapName) of
        [] ->
            ets:insert(?ETS_DROPTHING_COUNTER, {MapName,2}),
            1;
        [{MapName,ID}] ->
            ets:insert(?ETS_DROPTHING_COUNTER, {MapName, ID+1}),
            ID
    end.

get_dropthing_by_slice_list(RoleID,AllSlice) ->
    IsInTeamDropMap = is_in_team_drop_map() orelse is_in_team_drop_map_for_boss(),
    get_dropthing_by_slice_list_2(AllSlice,RoleID,IsInTeamDropMap).

get_dropthing_by_slice_list_2(AllSlice,_RoleID,false)->
    lists:foldl(
      fun(SliceName, Acc) ->
              case get({dropthing,SliceName}) of
                  undefined ->
                      Acc;
                  DropList ->
                      common_tool:combine_lists(DropList, Acc)
              end
      end, [], AllSlice);
get_dropthing_by_slice_list_2(AllSlice,RoleID,true)->
    lists:foldl(
      fun(SliceName, Acc) ->
              case get({dropthing,SliceName}) of
                  undefined ->
                      Acc;
                  DropList ->
                      DropList2 = 
                          lists:filter(
                            fun(E)-> 
                                    #p_map_dropthing{ismoney=IsMoney,roles=Roles}=E,
                                    IsMoney orelse lists:member(RoleID, Roles)
                            end, DropList),
                      common_tool:combine_lists(DropList2, Acc)
              end
      end, [], AllSlice).

%%怪物掉落物品并通知world那边怪物死亡
%%@param RoleID 打死怪物的玩家 
drop_thing({RoleID,role}, MonsterBaseInfo, MonsterID) ->
    #p_monster_base_info{
                         typeid = Type, droplist = DropInfoList,
                         min_money = MinMoney,max_money = MaxMoney,
                         level=Level, rarity=Rarity,
                         monstername=MonsterName} = MonsterBaseInfo,
    FcmIndex = common_misc:get_role_fcm_cofficient(RoleID),
    LevelIndex = mod_map_monster:get_role_level_index(RoleID, Type, Level, Rarity),
    EnergyIndex = mod_map_monster:get_role_energy_index(RoleID),
    
    %%活动期间内可获得奖品
    catch hook_activity_map:hook_monster_drop(RoleID,Type,EnergyIndex),
    
    IsInTeamDropMap = (is_in_team_drop_map_for_boss() andalso Rarity=:=?BOSS) orelse is_in_team_drop_map(),
    
    DropThingList = get_monster_dropthing_list(IsInTeamDropMap,Type, DropInfoList,RoleID,MinMoney,MaxMoney, FcmIndex, LevelIndex, EnergyIndex),
    catch mod_hero_fb:hook_monster_drop(Type, MonsterName, DropThingList),
    
    do_dropthing(IsInTeamDropMap, RoleID,DropThingList,MonsterID,monster, mgeem_map:get_state()).


%%
%% Local Functions
%%
do_handle({Unique, ?MAP, Method, DataIn, RoleID, PID}, State) ->
    case Method of 
        ?MAP_DROPTHING_PICK ->
            pick_dropthing(Unique,DataIn,RoleID,PID,State);
        _ ->
            nil
    end;

do_handle({dropthing,RoleID,DropThingList}, State) ->
    F = fun(Drop) -> 
                Drop#p_map_dropthing{id=get_new_dropthing_id()}
        end,
    do_dropthing(RoleID,[F(I)|| I <- DropThingList],RoleID,role, State);


do_handle({pick_dropthing_return,Succ,DropThing}, State) ->
    do_pick_dropthing_return(Succ,DropThing, State);

do_handle({dropthing_pick_protect_over,DropThingList}, _State) ->
    do_dropthing_pick_protect_over(DropThingList);

do_handle({dropthing_quit,TX,TY,OffsetX,OffsetY,DropThingList}, _State) ->
    do_dropthing_quit(TX,TY,OffsetX,OffsetY,DropThingList);
do_handle({dropthing_quit,DropThing}, State) ->
    do_dropthing_quit(DropThing,State);

do_handle(Msg,_State) ->
    ?INFO_MSG("unexcept msg",[Msg]).


do_pick_dropthing_return(Succ,DropThing, State) ->
    #p_map_dropthing{pos = Pos,id = ID} = DropThing,
    case Succ of
        true ->
            #p_pos{tx = TX, ty = TY} = Pos,
            #map_state{offsetx = OffsetX, offsety = OffsetY} = State,
            do_dropthing_quit(TX, TY, OffsetX, OffsetY, [DropThing]);
        false ->
            case get({drop,ID}) of
                undefined ->
                    nil;
                _ ->
                    put({drop,ID},{unpick,DropThing})
            end
    end.

do_dropthing(RoleID,DropThingList,ActorID,ActorType, State)->
    do_dropthing(false,RoleID,DropThingList,ActorID,ActorType, State).

do_dropthing(_,_,[],_,_,_) ->
    nil;
do_dropthing(IsInTeamDropMap,RoleID,DropThingList,ActorID,ActorType, State) ->
    ?DEV("dropthing ~w ~w",[DropThingList,ActorID]),
    case mod_map_actor:get_actor_txty_by_id(ActorID,ActorType) of
        undefined ->
            nil;
        {TX,TY} ->
            do_dropthing2(IsInTeamDropMap,TX,TY,RoleID,ActorID,ActorType,DropThingList,State)
    end.

do_dropthing2(IsInTeamDropMap,TX,TY,RoleID,ActorID,ActorType,DropThingList,State) ->
    Num = length(DropThingList),
    PosList = get_droppos_list(TX,TY,Num),
    ?DEV("dropthing ~w ~w ~w ~w ~w ~w",[TX,TY,ActorID,DropThingList,Num, PosList]),
    #map_state{offsetx = OffsetX, offsety = OffsetY} = State,
    {_,NewDropTingList} = 
        lists:foldl(
          fun(DropThing,{RestPosList,NewDropTingList}) ->
                  case length(RestPosList) > 0 of
                      true ->
                          [{X, Y}|NewRestPosList] = RestPosList,
                          Pos = #p_pos{tx = X, ty = Y, dir = 1},
                          NewDropThing = DropThing#p_map_dropthing{pos = Pos},
                          case get({ref2,X,Y}) of
                              undefined ->
                                  put({ref2,X,Y},{dropthing,[NewDropThing]});
                              {dropthing,Ref2List} when is_list(Ref2List) ->
                                  put({ref2,X,Y},{dropthing,[NewDropThing|Ref2List]})
                          end,
                          Slice = mgeem_map:get_slice_by_txty(X, Y, OffsetX, OffsetY),
                          case get({dropthing,Slice}) of
                              undefined ->
                                  put({dropthing,Slice},[NewDropThing]);
                              Ref2List2 when is_list(Ref2List2) ->
                                  put({dropthing,Slice},[NewDropThing|Ref2List2]) 
                          end,
                          ID = NewDropThing#p_map_dropthing.id,
                          put({drop,ID},{unpick,NewDropThing}),
                          {NewRestPosList,[NewDropThing|NewDropTingList]};
                      false ->
                          {[],NewDropTingList}
                  end
          end, {PosList,[]}, DropThingList),
    ?DEV("do_dropthing2, newdropthinglist: ~w", [NewDropTingList]),
    erlang:send_after(?DROPTHING_PROTECT_OVER_TIME, self(), {mod_map_drop,{dropthing_pick_protect_over,NewDropTingList}}),
    erlang:send_after(?DROPTHING_QUIT_MAP_TIME, self(), {mod_map_drop,{dropthing_quit,TX,TY,OffsetX,OffsetY,NewDropTingList}}),
    AllSlice = mgeem_map:get_9_slice_by_txty(TX,TY,OffsetX,OffsetY),
    InSceneRoleList = mgeem_map:get_all_in_sence_user_by_slice_list(AllSlice),
    
    do_dropthing_enter_broadcast(IsInTeamDropMap,InSceneRoleList,NewDropTingList),
    
    case ActorType of
        monster ->
            ?TRY_CATCH( do_drop_broadcast(RoleID,ActorID,NewDropTingList),ErrDropBc );
        _ ->
            ignore
    end,
    NewDropTingList.

do_dropthing_enter_broadcast(false,InSceneRoleList,DropTingList)->
    Record = #m_map_dropthing_enter_toc{dropthing = DropTingList},
    mgeem_map:broadcast(InSceneRoleList, ?DEFAULT_UNIQUE, ?MAP, ?MAP_DROPTHING_ENTER, Record);
do_dropthing_enter_broadcast(true,_InSceneRoleList,DropTingList)->
    {DropMoneyList,DropPropList} = 
        lists:partition(
          fun(#p_map_dropthing{ismoney=IsMoney})->
                  IsMoney
          end, DropTingList),
    
    %%分类出每个玩家对应的组队掉落的物品
    RoleDropThingList = 
        lists:foldl(
          fun(E,AccIn)-> 
                  #p_map_dropthing{roles=[Role|_T]}=E,
                  case lists:keyfind(Role, 1, AccIn) of
                      false->
                          NewRoleDropProps = {Role,[E|DropMoneyList]};
                      {_,OldList}->
                          NewRoleDropProps = {Role,[E|OldList]}
                  end,
                  lists:keystore(E, 1, AccIn, NewRoleDropProps)
          end, [], DropPropList),
    %%每个组队的玩家只广播属于自己的掉落物品
    lists:foreach(
      fun({RoleID2,DropTingList2})->
              Record = #m_map_dropthing_enter_toc{dropthing = DropTingList2},
              mgeem_map:broadcast([RoleID2], ?DEFAULT_UNIQUE, ?MAP, ?MAP_DROPTHING_ENTER, Record)
      
      end, RoleDropThingList),
    ok.


do_drop_broadcast(RoleID,MonsterID,DropTingList) ->
    #monster_state{monster_info=MonsterInfo} = mod_map_monster:get_monster_state(MonsterID),
    MonsterType = MonsterInfo#p_monster.typeid,
    case common_config_dyn:find(monster_drop_broadcast,MonsterType) of
        [] ->
            ignore;
        [#monster_drop_broadcast{content=Content,goods_type_list=GoodsTypeList}] ->
            DropTypeIDList =
                lists:foldl(
                  fun(#p_map_dropthing{goodstypeid=GoodsTypeID, goodstype=GoodsType, colour=Colour}, Acc) ->
                          case lists:member(GoodsTypeID, GoodsTypeList) of
                              true ->
                                  [{GoodsTypeID, GoodsType, Colour}|Acc];
                              _ ->
                                  Acc
                          end
                  end, [], DropTingList),
            
            case DropTypeIDList of
                [] ->
                    ignore;
                _ ->
                    DropNameList = mod_hero_fb:get_drop_goods_name(DropTypeIDList),
                    {ok, #p_role_base{role_name=RoleName, faction_id=FactionID}} = mod_map_role:get_role_base(RoleID),
                    
                    Msg = io_lib:format(Content, [mod_hero_fb:get_role_name_color(RoleName, FactionID), DropNameList]),
                    
                    common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], ?BC_MSG_TYPE_CHAT_WORLD, Msg)
            end
    end.

do_dropthing_quit(DropThing,State) when is_record(DropThing,p_map_dropthing)->
    #p_map_dropthing{pos = Pos } = DropThing,
    #p_pos{tx = TX, ty = TY} = Pos,
    #map_state{offsetx = OffsetX, offsety = OffsetY} = State,
    do_dropthing_quit(TX, TY, OffsetX, OffsetY, [DropThing]).

do_dropthing_quit(TX, TY, OffsetX, OffsetY, DropThingList) ->
    AllSlice = mgeem_map:get_9_slice_by_txty(TX,TY,OffsetX,OffsetY),
    RoleList = mgeem_map:get_all_in_sence_user_by_slice_list(AllSlice),
    
    lists:foreach(
      fun(Slice) ->
              case get({dropthing,Slice}) of
                  undefined ->
                      nil;
                  Ref2List when is_list(Ref2List) ->
                      Ref2List2 = lists:foldl(
                                    fun(Arg,Acc) ->
                                            lists:keydelete(Arg#p_map_dropthing.id, #p_map_dropthing.id, Acc)        
                                    end, Ref2List,DropThingList),
                      put({dropthing,Slice},Ref2List2)
              end
      end,AllSlice),
    IDList =
        lists:foldl(
          fun(DropThing,Acc) ->
                  #p_map_dropthing{
                                   id = ID,
                                   pos = Pos
                                  } = DropThing,
                  #p_pos{tx = X, ty = Y} = Pos,
                  case get({ref2,X,Y}) of
                      undefined ->
                          nil;
                      {dropthing,Ref2List3} when is_list(Ref2List3) ->
                          Ref2List4 = lists:keydelete(DropThing#p_map_dropthing.id, #p_map_dropthing.id, Ref2List3),
                          put({ref2,X,Y},{dropthing,Ref2List4})
                  end,
                  case get({drop,ID}) of
                      undefined ->
                          Acc;
                      _ ->
                          [ID|Acc]
                  end
          end, [], DropThingList),
    lists:foreach(
      fun(DropThing) ->
              #p_map_dropthing{id = ID} = DropThing,
              erase({drop,ID})
      end, DropThingList),
    case length(IDList) > 0 of
        true ->
            Record = #m_map_dropthing_quit_toc{dropthingid = IDList},
            mgeem_map:broadcast(RoleList, ?DEFAULT_UNIQUE, ?MAP, ?MAP_DROPTHING_QUIT, Record);
        false ->
            nil
    end.

do_dropthing_quit(TX, TY, OffsetX, OffsetY, DropThingList, RolePid) ->
    AllSlice = mgeem_map:get_9_slice_by_txty(TX,TY,OffsetX,OffsetY),
    RoleList = mgeem_map:get_all_in_sence_user_by_slice_list(AllSlice),
    lists:foreach(
      fun(Slice) ->
              case get({dropthing,Slice}) of
                  undefined ->
                      nil;
                  Ref2List when is_list(Ref2List) ->
                      Ref2List2 = lists:foldl(
                                    fun(Arg,Acc) ->
                                            lists:keydelete(Arg#p_map_dropthing.id, #p_map_dropthing.id, Acc)
                                    end, Ref2List,DropThingList),
                      put({dropthing,Slice},Ref2List2)
              end
      end,AllSlice),
    NewRoleList =
        lists:foldl(
          fun(Role,Acc)->
                  case Role =:= RolePid of
                      true->
                          Acc;
                      false ->
                          [Role|Acc]
                  end
          end, [], RoleList),
    IDList =
        lists:foldl(
          fun(DropThing,Acc) ->
                  #p_map_dropthing{
                                   id = ID,
                                   pos = Pos
                                  } = DropThing,
                  #p_pos{tx = X, ty = Y} = Pos,
                  case get({ref2,X,Y}) of
                      undefined ->
                          nil;
                      {dropthing,Ref2List3} when is_list(Ref2List3) ->
                          Ref2List4 = lists:keydelete(DropThing#p_map_dropthing.id, #p_map_dropthing.id, Ref2List3),
                          put({ref2,X,Y},{dropthing,Ref2List4})
                  end,
                  case get({drop,ID}) of
                      undefined ->
                          Acc;
                      _ ->
                          [ID|Acc]
                  end
          end, [], DropThingList),                                                            
    lists:foreach(
      fun(DropThing) ->
              #p_map_dropthing{id = ID} = DropThing,
              erase({drop,ID})
      end, DropThingList),
    case length(IDList) > 0 of
        true ->
            Record = #m_map_dropthing_quit_toc{dropthingid = IDList},
            mgeem_map:broadcast(NewRoleList, ?DEFAULT_UNIQUE, ?MAP, ?MAP_DROPTHING_QUIT, Record);
        false ->
            nil
    end.


do_dropthing_pick_protect_over(DropThingList) 
  when is_list(DropThingList)->
    lists:foreach(
      fun(DropThing) ->
              ID = DropThing#p_map_dropthing.id,
              case get({drop,ID}) of
                  undefined ->
                      nil;
                  {_A,_} ->
                      NewDropThing = DropThing#p_map_dropthing{roles = []},
                      put({drop,ID},{_A,NewDropThing})
              end
      end, DropThingList).

pick_dropthing(Unique, DataIn, RoleID, PID, State) ->
    ?DEBUG("pick_dropthiing:~w~n",[DataIn]),
    #m_map_dropthing_pick_tos{dropthingid = ID} = DataIn,
    Ret = 
        case get({drop,ID}) of
            undefined ->
                {fail,?_LANG_DROPTHING_NOT_FOUND};
            {unpick,DropThing} ->
                ?DEBUG("unpick pick_dropthiing:~w~n",[DropThing]),
                #p_map_dropthing{roles = RoleList,goodstype=GoodsType} = DropThing,
                NewRoleList =
                    case RoleList of
                        [] ->
                            [RoleID];
                        _ ->
                            RoleList
                    end,
                case intlist_keyfind(RoleID, NewRoleList) of
                    false ->
                        {fail,?_LANG_DROPTHING_PICK_PROTECEED};
                    _ ->
                        case check_inpick_distance(RoleID,DropThing) of
                            true ->
                                #map_state{offsetx = OffsetX, offsety = OffsetY} = State,
                                case GoodsType of
                                    ?DROPTHING_TYPE_BOX->
                                        pick_box(Unique, RoleID, DropThing, PID );
                                    _ ->
                                        case pick(Unique,RoleID,DropThing,OffsetX,OffsetY, PID) of
                                            ok ->
                                                put({drop,ID},{picked,DropThing});
                                            error ->
                                                next
                                        end
                                end;
                            false ->
                                {fail,?_LANG_DROPTHING_TOO_FAR_AWAY}
                        end
                end;
            _ ->
                {fail,?_LANG_DROPTHING_NOT_FOUND}
        end,
    case Ret of
        {fail,Reason} ->
            ?DEBUG("~w",[Reason]),
            DataRecord = #m_map_dropthing_pick_toc{succ = false, reason = Reason,dropthingid = ID},
            common_misc:unicast({role, RoleID}, Unique, ?MAP, ?MAP_DROPTHING_PICK, DataRecord);
        _ ->
            nil
    end.


intlist_keyfind(Key,List) ->
    lists:foldl(
      fun(Value,Acc)->
              Acc orelse Value =:= Key
      end, false, List).


check_inpick_distance(RoleID,DropThing) ->
    Pos = DropThing#p_map_dropthing.pos,
    #p_pos{tx = TX, ty = TY} = Pos,
    ActorPos = mod_map_actor:get_actor_txty_by_id(RoleID,role),
    case ActorPos of
        {X,Y} ->
            abs(TX - X) =< ?PICK_DISTANCE andalso abs(TY - Y) =< ?PICK_DISTANCE;
        _ ->
            false
    end.

pick_box(Unique, _RoleID, DropThing, PID )->
    #p_map_dropthing{id = ID } = DropThing,
    %%mod_hero_fb:hook_pick_box(RoleID,DropThing),
    R3 = #m_map_dropthing_pick_toc{succ = true, pick_type=?PICK_TYPE_BOX, goods = undefined, num=1, dropthingid = ID},
    Module = ?MAP,
    Method = ?MAP_DROPTHING_PICK,
    ?UNICAST_TOC( R3 ),
    ok.

%%@param 当goodstype=11，表示特殊的道具——宝箱
pick(Unique, RoleID, DropThing, OffsetX, OffsetY, PID) ->
    #p_map_dropthing{
                     id = ID,
                     ismoney = IsMoney,
                     bind=Bind,
                     money = Money,
                     pos = Pos
                    } = DropThing,
    if
        IsMoney->
            #p_pos{tx = TX, ty = TY} = Pos,
            pick_silver(Bind, Unique, RoleID, Money, ID),
            do_dropthing_quit(TX,TY,OffsetX, OffsetY, [DropThing],PID),
            ok;
        true->
            mod_goods:pick_dropthing(DropThing,Unique,RoleID)
    end.     

pick_silver(Bind,  Unique, RoleID, AddNum, ID) ->
    case common_transaction:transaction(
           fun() ->
                   common_consume_logger:gain_silver(
                     {RoleID, 
                      0, 
                      AddNum, 
                      ?GAIN_TYPE_SILVER_FROM_PICKUP,
                      ""
                     }),
                   {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                   if Bind =:= true ->
                           common_consume_logger:gain_silver({RoleID, AddNum, 0, ?GAIN_TYPE_SILVER_FROM_PICKUP,""}),
                           SilverBind = RoleAttr#p_role_attr.silver_bind,
                           NewSilverBind = SilverBind + AddNum,
                           Result = {silver_bind, NewSilverBind,1},
                           NewRoleAttr = RoleAttr#p_role_attr{silver_bind = NewSilverBind};
                       true ->
                           common_consume_logger:gain_silver({RoleID, 0, AddNum, ?GAIN_TYPE_SILVER_FROM_PICKUP,""}),
                           Silver = RoleAttr#p_role_attr.silver,
                           NewSilver = Silver + AddNum,
                           Result = {silver, NewSilver,2},
                           NewRoleAttr = RoleAttr#p_role_attr{silver = NewSilver}
                   end,
                   mod_map_role:set_role_attr(RoleID, NewRoleAttr),
                   Result
           end) of
        {atomic, {_, NewNum,MoneyType}} ->
            %% MoneyType 1绑定 2不绑定
            Data = #m_map_dropthing_pick_toc{money = NewNum, dropthingid = ID,add_money = AddNum,money_type = MoneyType},
            common_misc:unicast({role,RoleID}, Unique, ?MAP, ?MAP_DROPTHING_PICK, Data);
        {aborted, Reason} ->
            ?ERROR_MSG("拾取银子失败,RoleID:~w AddNum:~w Reason:~w",[RoleID, AddNum, Reason])
    end.

get_droppos_list(TX,TY,Num) ->
    List = [{-1,0},{1,0},{0,-1},{0,1},
            {-1,-1},{1,-1},{-1,1},{1,1},
            {0,0},
            {-2,0},{2,0},{0,-2},{0,2},
            {-2,-1},{-2,1},{2,-1},{2,1},
            {-1,-2},{1,-2},{-1,2},{1,2},
            {-2,-2},{2,-2},{2,-2},{2,2}],
    {PosList,Count} = 
        lists:foldl(
          fun({X,Y},{PosList,Count})->
                  case Count >= Num of
                      true ->
                          {PosList,Count};
                      false ->
                          XX = TX + X,
                          YY = TY + Y,
                          case get({XX,YY}) of 
                              undefined ->
                                  {PosList,Count};
                              _ ->
                                  case get({ref2,XX,YY}) of
                                      undefined ->
                                          {[{XX,YY}|PosList],Count+1};
                                      _ ->
                                          {PosList,Count}
                                  end
                          end
                  end
          end,{[],0}, List),
    case Count =:= Num of
        true->
            PosList;
        false ->
            {PosList3,_Count3} = 
                lists:foldl(
                  fun({X,Y},{PosList2,Count2})->
                          case Count2 >= Num of
                              true ->
                                  {PosList2,Count2};
                              false ->
                                  XX = TX + X,
                                  YY = TY + Y,
                                  case get({XX,YY}) of 
                                      undefined ->
                                          {PosList2,Count2};
                                      _ ->
                                          case get({ref2,XX,YY}) of
                                              undefined ->
                                                  {PosList2,Count2};
                                              _ ->
                                                  {[{XX,YY}|PosList2],Count2+1}
                                          end
                                  end
                          end
                  end,{PosList,Count}, List),
            PosList3
    end.



%%获取怪物的掉落物品列表
%%@return [#p_map_dropthing]
get_monster_dropthing_list(IsInTeamDropMap,MonsterTypeID, DropInfoList,RoleID, MinMoney, MaxMoney, FcmIndex, LevelIndex, EnergyIndex) ->
    random:seed(now()),
    PickRoleList = common_misc:team_get_can_pick_goods_role(RoleID),
    %%掉银两
    DropMoneyList =
        case MaxMoney < MinMoney orelse MinMoney =:= 0 of
            false ->
                Money = MinMoney + random:uniform(MaxMoney - MinMoney + 1) - 1,
                DropID = mod_map_drop:get_new_dropthing_id(),
                DropMoney = #p_map_dropthing{
                  id = DropID,
                  ismoney = true,
                  roles = PickRoleList,
                  num = 1,
                  bind = true,
                  money = Money},
                [DropMoney];
            true ->
                []
        end,
    MapID = mgeem_map:get_mapid(),
    case common_config_dyn:find(monster_drop_times, {MapID, MonsterTypeID}) of 
        [] ->
            MonsterDropTypeID = undefined,
            DropInfoList2 = DropInfoList;
        [{MaxKill, [{MonsterDropGroup, MonsterDropTypeID}]}] ->
            KillTimes = get_role_monster_drop_times(RoleID, {MapID, MonsterTypeID}),
            case KillTimes >= MaxKill of 
                true ->
                    {_, DropInfoList2} = lists:foldl(
                                           fun(#p_drop_info{drops=Drops}=Drop, {CurGroup, InfoList}) ->
                                                   case CurGroup =:= MonsterDropGroup of 
                                                       true ->
                                                           case lists:keyfind(MonsterDropTypeID, #p_single_drop.typeid, Drops) of 
                                                               false ->
                                                                   {CurGroup+1, [Drop|InfoList]};
                                                               D ->
                                                                   {CurGroup+1, [Drop#p_drop_info{drops=[D], rate=10000}|InfoList]}
                                                           end;
                                                       _ ->
                                                           {CurGroup+1, [Drop|InfoList]}
                                                   end
                                           end, {1, []}, DropInfoList);
                _ ->
                    DropInfoList2 = DropInfoList
            end
    end,
    %%掉落道具
    DropThingList2 =
        lists:foldl(
          fun(DropInfo,AccList) ->
                  case IsInTeamDropMap of
                      true->
                          lists:foldl(
                            fun(PickRoleId,AccInTeam)-> 
                                    get_monster_dropthing_list2(DropInfo,AccInTeam,[PickRoleId], FcmIndex, LevelIndex, EnergyIndex)		  
                            end, AccList, PickRoleList);
                      _ ->
                          get_monster_dropthing_list2(DropInfo,AccList,PickRoleList, FcmIndex, LevelIndex, EnergyIndex)
                  end
          end, DropMoneyList, DropInfoList2),
    case MonsterDropTypeID of 
        undefined ->
            ignore;
        _ ->
            case lists:keyfind(MonsterDropTypeID, #p_map_dropthing.goodstypeid, DropThingList2) of 
                false ->
                    add_role_monster_drop_times(RoleID, {MapID, MonsterTypeID});
                _ ->
                    reset_role_monster_drop_times(RoleID, {MapID, MonsterTypeID})
            end 
    end,
    DropThingList2.

get_monster_dropthing_list2(DropInfo,DropAccList,PickRoleList, FcmIndex, LevelIndex, EnergyIndex) ->
    #p_drop_info{
                 drops = SingleDropList,
                 rate = Rate,
                 max_num = MaxNum,
                 drop_mode = DropMode
                } = DropInfo,
    Rate2 = Rate * FcmIndex * LevelIndex * EnergyIndex,
    Rand = random:uniform(10000),
    
    case Rate2 >= Rand of
        true->
            SeedNum = lists:foldl(
                        fun(SingleDroup,Acc) ->
                                Acc+ SingleDroup#p_single_drop.weight
                        end,0,SingleDropList),
            Rand2 = random:uniform(SeedNum),
            %%?DEV("SeedNum:~w Rand2:~w~n",[SeedNum,Rand2]),
            case catch lists:foldl(
                   fun(SingleDrop,{Sum,_DropThing}) ->
                           get_monster_dropthing_list3(SingleDrop,
                                                       Sum,
                                                       _DropThing,
                                                       Rand2,
                                                       MaxNum,
                                                       PickRoleList,
                                                       DropMode)    
                   end, {0,undefined}, SingleDropList)
                of
                {ok,DropThing} when is_record(DropThing,p_map_dropthing) ->  
                    [DropThing|DropAccList];
                {ok,TeamDropList} when is_list(TeamDropList)->
                    lists:merge(TeamDropList, DropAccList);
                {_,undefined} ->
                    DropAccList
            end;
        false ->
            DropAccList
    end.


get_monster_dropthing_list3(SingleDrop,Sum,_DropThing,Rand2,MaxNum,PickRoleList,DropMode) ->
    #p_single_drop{type = Type, typeid = TypeID,weight = W} = SingleDrop,
    Sum2 = Sum + W,
    case Sum2 >= Rand2 of
        true ->
            Num = common_tool:random(1,MaxNum),
            case erlang:is_record(DropMode, p_drop_mode) =:= true of
                true ->
                    DropProperty = get_drop_mode_property(DropMode);
                _ ->
                    case Type of
                        ?TYPE_ITEM ->
                            [#p_item_base_info{colour = ItemColour}] = common_config_dyn:find_item(TypeID);
                        ?TYPE_STONE ->
                            [#p_stone_base_info{colour = ItemColour}] = common_config_dyn:find_stone(TypeID);
                        _ ->
                            ItemColour = 1
                    end,
                    DropProperty = #p_drop_property{bind = false,colour = ItemColour, quality = 1, use_bind=0}
            end,
            MapDropThingList = get_monster_dropthing_list4(PickRoleList,Num,Type,TypeID,DropProperty),
            throw({ok,MapDropThingList});
        false ->
            {Sum2,_DropThing}
    end.

%%进行组队掉落的特殊处理，每个组队的成员都可以看到和捡到属于自己的物品
%%@param 当Type=GoodsType=11表示它是特殊道具——宝箱。
get_monster_dropthing_list4(PickRoleList,Num,Type,TypeID,DropProperty)->
    ID = mod_map_drop:get_new_dropthing_id(),
    #p_map_dropthing{ id = ID, roles = PickRoleList,
                      num = Num,
                      goodstype = Type,
                      goodstypeid = TypeID,
                      drop_property = DropProperty,
                      bind=DropProperty#p_drop_property.bind,
                      colour=DropProperty#p_drop_property.colour}.

get_drop_mode_property(DropMode)
  when erlang:is_record(DropMode, p_drop_mode)->
    Pro = #p_drop_property{},
    Rate = DropMode#p_drop_mode.bind_rate,
    UseBind = DropMode#p_drop_mode.use_bind,
    Rand = random:uniform(100),
    %%?DEV("~ndrop Rate:~w,drop Rand:~w~n",[Rate,Rand]),
    case Rand > Rate of
        true ->
            get_drop_mode_property2(#p_drop_mode.unbind_colour,
                                    DropMode,
                                    Pro#p_drop_property{bind = false, use_bind = UseBind});
        false ->           
            get_drop_mode_property2(#p_drop_mode.bind_colour,
                                    DropMode,
                                    Pro#p_drop_property{bind = true, use_bind = UseBind})
    end;
get_drop_mode_property(_) ->
    #p_drop_property{bind = false,colour = 1, quality = 1, use_bind=0}.

get_drop_mode_property2(#p_drop_mode.bind_colour,DropMode, Pro) ->
    {P,_} = get_drop_property(DropMode#p_drop_mode.bind_colour),
    P1 = case P of undefined -> 1;P -> P end,
    get_drop_mode_property2(#p_drop_mode.bind_quality,
                            DropMode, 
                            Pro#p_drop_property{colour=P1});
get_drop_mode_property2(#p_drop_mode.bind_quality,DropMode,Pro) ->
    {P,_} = get_drop_property(DropMode#p_drop_mode.bind_quality),
    P1 = case P of undefined -> 1;P -> P end,
    get_drop_mode_property2(#p_drop_mode.bind_hole,
                            DropMode, 
                            Pro#p_drop_property{quality=P1});
get_drop_mode_property2(#p_drop_mode.bind_hole,DropMode,Pro) ->
    {P,_} = get_drop_property(DropMode#p_drop_mode.bind_hole),
    P1 = case P of undefined -> 0;P -> P end,
    Pro#p_drop_property{hole_num=P1};

get_drop_mode_property2(#p_drop_mode.unbind_colour,DropMode, Pro) ->
    {P,_} = get_drop_property(DropMode#p_drop_mode.unbind_colour),
    P1 = case P of undefined -> 1;P -> P end,
    get_drop_mode_property2(#p_drop_mode.unbind_quality,
                            DropMode, 
                            Pro#p_drop_property{colour=P1});
get_drop_mode_property2(#p_drop_mode.unbind_quality,DropMode,Pro) ->
    {P,_} = get_drop_property(DropMode#p_drop_mode.unbind_quality),
    P1 = case P of undefined -> 1;P -> P end,
    get_drop_mode_property2(#p_drop_mode.unbind_hole,
                            DropMode, 
                            Pro#p_drop_property{quality=P1});
get_drop_mode_property2(#p_drop_mode.unbind_hole,DropMode,Pro) ->
    {P,_} = get_drop_property(DropMode#p_drop_mode.unbind_hole),
    P1 = case P of undefined -> 0;P -> P end,
    Pro#p_drop_property{hole_num=P1}.

get_drop_property([]) ->
    {undefined,undefined};
get_drop_property(Addition)
  when is_list(Addition) ->
    Sum = lists:foldl(
            fun({_,_,R},Acc) ->
                    ?DEV("!!R:~w~n",[Acc]),
                    R+Acc
            end,0,Addition),
    Rate = random:uniform(Sum),
    ?DEV("!!!R:~w,Sum:~w~n",[Rate,Sum]),
    catch lists:foldl(
      fun({_,P1,S1},{P2,S2}) ->
              if (S1+S2) > Rate ->
                     ?DEV("!R:~w,!S:~w~n",[Rate,S1+S2]),
                     throw({P1,S1});
                 true ->
                     ?DEV("R:~w,S:~w~n",[Rate,S1]),
                     {P2,S1+S2}
              end
      end,{undefined,0},Addition).

drop_silver(_Pos, 0) ->
    ignore;
drop_silver(Pos,Num) ->
    #p_pos{tx=X,ty=Y}=Pos,
    #map_state{offsetx = OffsetX, offsety = OffsetY} = mgeem_map:get_state(),
    DropMoney = 
        #p_map_dropthing{roles = [],
                         id = mod_map_drop:get_new_dropthing_id(),
                         ismoney = true,  
                         pos = Pos,
                         num = 1,
                         money = Num},
    case get({X,Y}) of
        undefined ->
            error;
        _ ->
            case get({ref2,X,Y}) of
                undefined ->
                    put({ref2,X,Y},{dropthing,[DropMoney]});
                {dropthing,Ref2List} when is_list(Ref2List) ->
                    put({ref2,X,Y},{dropthing,[DropMoney|Ref2List]})
            end,
            Slice = mgeem_map:get_slice_by_txty(X, Y, OffsetX, OffsetY),
            case get({dropthing,Slice}) of
                undefined ->
                    put({dropthing,Slice},[DropMoney]);
                Ref2List2 when is_list(Ref2List2) ->
                    put({dropthing,Slice},[DropMoney|Ref2List2]) 
            end,
            put({drop,DropMoney#p_map_dropthing.id},{unpick,DropMoney}),
            erlang:send_after(?DROPTHING_QUIT_MAP_TIME, self(), {mod_map_drop,{dropthing_quit,X,Y,OffsetX,OffsetY,[DropMoney]}}),
            AllSlice = mgeem_map:get_9_slice_by_txty(X,Y,OffsetX,OffsetY),
            RoleList = mgeem_map:get_all_in_sence_user_by_slice_list(AllSlice),
            Record = #m_map_dropthing_enter_toc{dropthing = [DropMoney]},
            mgeem_map:broadcast(RoleList, ?DEFAULT_UNIQUE, ?MAP, ?MAP_DROPTHING_ENTER, Record)
    end.

%% ========================================================================

%% @doc 初始化角色打怪未掉落纪录
set_role_monster_drop(RoleID, DropInfo) ->
    {atomic, _} = common_transaction:t(fun() -> t_set_role_monster_drop(RoleID, DropInfo) end).

t_set_role_monster_drop(RoleID, DropInfo) ->
    mod_map_role:update_role_id_list_in_transaction(RoleID, ?role_monster_drop, ?role_monster_drop_copy),
    erlang:put({?role_monster_drop, RoleID}, DropInfo).

%% @doc 清除角色打怪未掉落纪录
clear_role_monster_drop(RoleID) ->
    case get_role_monster_drop(RoleID) of
        {ok, DropInfo} ->
            mgeem_persistent:role_monster_drop_persistent(DropInfo);
        _ ->
            ignore
    end,
    erlang:erase({?role_monster_drop, RoleID}).

%% @doc 获取角色打怪未掉落纪录
get_role_monster_drop(RoleID) ->
    case erlang:get({?role_monster_drop, RoleID}) of
        undefined ->
            {error, not_found};
        DropInfo ->
            {ok, DropInfo}
    end.

%% @doc 获取打某个怪未掉落的数据
get_role_monster_drop_times(RoleID, {MapID, MonsterTypeID}) ->
    case get_role_monster_drop(RoleID) of
        {error, _} ->
            0;
        {ok, #r_role_monster_drop{kill_times=KillTimes}} ->
            case lists:keyfind({MapID, MonsterTypeID}, 1, KillTimes) of
                false ->
                    0;
                {_, Times} ->
                    Times
            end 
    end.

%% @doc 增加角色打某个怪未掉落的次数
add_role_monster_drop_times(RoleID, {MapID, MonsterTypeID}) ->
    case get_role_monster_drop(RoleID) of
        {error, _} ->
            DropInfo2 = #r_role_monster_drop{role_id=RoleID, kill_times=[{{MapID, MonsterTypeID}, 1}]};
        {ok, #r_role_monster_drop{kill_times=KillTimes}=DropInfo} ->
            case lists:keyfind({MapID, MonsterTypeID}, 1, KillTimes) of
                false ->
                    Add = {{MapID, MonsterTypeID}, 1};
                {_, Times} ->
                    Add = {{MapID, MonsterTypeID}, Times+1}
            end,
            DropInfo2 = DropInfo#r_role_monster_drop{kill_times=[Add|lists:keydelete({MapID, MonsterTypeID}, 1, KillTimes)]}
    end,
    set_role_monster_drop(RoleID, DropInfo2).

%% @doc 重置角色打某个怪的未掉落次数
reset_role_monster_drop_times(RoleID, {MapID, MonsterTypeID}) ->    
    case get_role_monster_drop(RoleID) of
        {error, _} ->
            ignore;
        {ok, #r_role_monster_drop{kill_times=KillTimes}=DropInfo} ->
            DropInfo2 = DropInfo#r_role_monster_drop{kill_times=lists:keydelete({MapID, MonsterTypeID}, 1, KillTimes)},
            set_role_monster_drop(RoleID, DropInfo2)
    end.
