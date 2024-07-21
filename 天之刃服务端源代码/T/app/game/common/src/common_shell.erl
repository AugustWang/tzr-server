-module(common_shell).

-export([
         update_pet_bag/0,
         send_gift/0,
         send_gift/2,
         send_level_prize/2,
         send_exp_goods/1,
         modify_role_goods/1,
         modify_role_goods_offline/1,
         modify_all_role_goods/2,
         judge_role_bag_thing_error/1,
         check_error_bag_role/1,
         pet_feed_reset/1,
         update_stone_config_handle/1,
         update_role_equips/2,
         map_exec_up_role_equip/0,
         map_process_exec_change_mount_speed/0,
         map_process_exec_change_mount_speed/1,
         update_p_goods_structure/0,
         update_p_goods_data_for_special/0,
         update_p_goods_data_for_whole/0,
         judge_role_bag_thing_error/2,
         t_pay_get_date/5]).

-export([get_liushi_family/0,
         set_all_fuli/0,
         get_liushi/0,
         rep_educate_info/0]).

-include("common.hrl").
-include("common_server.hrl").

%%@doc 发送给所有地图的消息示例
%% Fun=fun(V)-> mod_mission_data:set_vs(V) end.
%% common_map:send_to_all_map({func, Fun, [201105111603]}).

%%@doc 给所有三天内有登陆的玩家赠送所有福利
set_all_fuli()->
    Now = common_tool:now(),
    Last3Days = Now - 3*24*3600,
    MatchHead = #p_role_ext{role_id='$1', _='_',last_login_time='$2'},
    Guard = [{'>','$2',Last3Days}],
    AllRoleIDList = db:dirty_select(db_role_ext, [{MatchHead, Guard, ['$1']}]),
    Today = date(),
    BnftList =  [{10001,Today},{10003,Today},
                 {10004,Today},{10006,Today},{10007,Today},{10008,Today},
                 {20001,Today},{20002,Today},{20003,Today}],
    lists:foreach(fun(RoleID)-> 
                      R2 = #r_role_activity_benefit{role_id=RoleID,reward_date=undefined,
                                                    buy_date=Today,buy_count=9,act_bnft_list=BnftList},
                      db:dirty_write(db_role_activity_benefit,R2)
                  end, AllRoleIDList),
    {length(AllRoleIDList),AllRoleIDList}.


%%@doc 获取属于门派地图流失的玩家列表
get_liushi_family()->
    Now = common_tool:now(),
    Last3Days = Now - 3*24*3600,
    
    MatchHead = #p_role_ext{role_id='$1', _='_',last_offline_time='$2'},
    Guard = [{'<','$2',Last3Days}],
    AllRoleIDList = db:dirty_select(db_role_ext, [{MatchHead, Guard, ['$1']}]),
    List2 = lists:filter(fun(RoleID)-> 
                     case db:dirty_read(db_role_pos,RoleID) of
                         [#p_role_pos{old_map_process_name=Name}]->
                             case string:str(Name, "map_family_") of
                                 1->
                                     case db:dirty_read(db_role_pos,RoleID) of
                                         [#p_role_pos{pos=#p_pos{tx=Tx,ty=Ty}}]->
                                             Tx<187+5 andalso Tx>187-5
                                     andalso Ty<177+5 andalso Ty>177-5;
                                         _ ->
                                             false
                                     end;
                                 _ ->
                                     false
                             end;
                         _ ->
                             false
                     end
                     end, AllRoleIDList),
    Count = length(List2),
    GroupByList = group_by_role_level(List2,[]),
    GroupByList2 = lists:sort(fun({_L1,N1},{_L2,N2})-> N2>N1 end, GroupByList),
    {Count,GroupByList2}.

get_liushi()->
    Now = common_tool:now(),
    Last3Days = Now - 3*24*3600,
    
    MatchHead = #p_role_ext{role_id='$1', _='_',last_offline_time='$2'},
    Guard = [{'<','$2',Last3Days}],
    AllRoleIDList = db:dirty_select(db_role_ext, [{MatchHead, Guard, ['$1']}]),
    List2 = lists:foldl(
              fun(RoleID, Acc)-> 
                      case db:dirty_read(db_role_pos,RoleID) of
                          [#p_role_pos{map_process_name=Name1,old_map_process_name=Name2}]->
                              case string:str(Name2, "map_family_") of
                                  1->
                                      case db:dirty_read(db_role_pos,RoleID) of
                                          [#p_role_pos{pos=#p_pos{tx=Tx,ty=Ty}}]->
                                              [{RoleID,Name2,Tx,Ty}|Acc];
                                          _ ->
                                              Acc
                                      end;
                                  _ ->
                                      case db:dirty_read(db_role_pos,RoleID) of
                                          [#p_role_pos{pos=#p_pos{tx=Tx,ty=Ty}}]->
                                              [{RoleID,Name1,Tx,Ty}|Acc];
                                          _ ->
                                              Acc
                                      end
                              end;
                          _ ->
                              Acc
                      end
              end,[], AllRoleIDList),
    Count = length(List2),
    GroupByList = group_by_role_level([RoleID || {RoleID,_,_,_} <- List2],[]),
    GroupByList2 = lists:sort(fun({_L1,N1},{_L2,N2})-> N2>N1 end, GroupByList),

    lists:foreach(fun({R,N,X,Y}) -> file:write_file("/data/liushi1.txt", io_lib:format("{~w ~w ~w ~w}.~n", [R,N,X,Y]), [append]) end, List2),  

    lists:foreach(fun(D) -> file:write_file("/data/liushi2.txt", io_lib:format("~w.~n", [D]), [append]) end, GroupByList2),  

    {Count,GroupByList2}.


group_by_role_level([],ResultList)->
    ResultList;
group_by_role_level([RoleID|T],ResultList)->
    [#p_role_attr{level=RoleLevel}] = db:dirty_read(db_role_attr,RoleID),
    case lists:keyfind(RoleLevel, 1, ResultList) of
        false->
            List2 = [{RoleLevel,1}|ResultList],
            group_by_role_level(T,List2);
        {RoleLevel,N}->
            List2 = lists:keystore(RoleLevel, 1, ResultList, {RoleLevel,N+1}),
            group_by_role_level(T,List2)
    end.


%% 20级以上，3天内有登陆的玩家发放补偿 2011-02-15
send_gift() ->
    {ok, LogHandle} = file:open("/root/log_2011_02_15.log", write),
    
    Now = common_tool:now(),
    RoleList =
        lists:foldl(
          fun(#p_role_ext{role_id=RoleID, last_offline_time=LastOfflineTime}, Acc) ->
                  case LastOfflineTime >= Now orelse Now - LastOfflineTime =< 3*24*3600 of
                      true ->
                          [#p_role_attr{level=Level}] = db:dirty_read(?DB_ROLE_ATTR, RoleID),

                          case Level >= 20 of
                              true ->
                                  [RoleID|Acc];
                              _ ->
                                  Acc
                          end;
                      _ ->
                          Acc
                  end
          end, [], db:dirty_match_object(?DB_ROLE_EXT, #p_role_ext{_='_'})),

    send_gift(LogHandle, RoleList),
    file:close(LogHandle).

%%发明1服17号以后注册账号，25日前40级以上玩家20锭银票
send_level_prize(MinLevel,MaxLevel) ->
      {ok,SSS} = file:open("/log2.txt",write),
    lists:foreach(
      fun(Level) ->
              List = db:dirty_match_object(db_role_attr,#p_role_attr{level=Level,_='_'}),
              List2 = lists:foldr(
                        fun(RoleAttr,Acc) ->
                                RoleID = RoleAttr#p_role_attr.role_id,
                                case RoleID < 35343 of
                                    true ->
                                        [RoleID|Acc];
                                    false ->
                                        Acc
                                end
                        end, [], List),
               io:format(SSS,"$$$$$$$$$ ~w    ~w~n",[List, List2]),
              send_gift(SSS,List2)
      end, lists:seq(MinLevel,MaxLevel)).

send_gift(SSS,RoleIDList) ->
    lists:foreach(
      fun(RoleID) ->
              case db:transaction(
                     fun() ->
                             [AttrInfo] = db:dirty_read(db_role_attr,RoleID),
                             CItem = #r_item_create_info{role_id=RoleID,num=2,typeid=10100004,bind=true,bag_id=1,bagposition=1},
                             {ok,[TGoods]} = common_bag2:create_item(CItem),
                             Title = "系统信件",
                             Text = "亲爱的玩家:\n      您好！对于本次临时维护给您正常游戏带来不便，我们深感抱歉。为表示歉意，对此我们决定给予20级以上、最近三天内有登陆过游戏的玩家，每人两张高级经验符作为补偿，请注意查收！祝您游戏愉快，万事如意！\n\n<p align=\"right\">4399《天之刃》运营团队</p><p align=\"right\">2011年02月15日</p>",
                             receive_letter(RoleID,AttrInfo#p_role_attr.role_name,Title,Text,[TGoods#p_goods{id=1}])
                     end)
              of
                  {aborted, _} ->
                      io:format(SSS," ~w~n",[RoleID]);
                  {atomic, ignore} ->
                      io:format(SSS," ~w~n",[RoleID]);
                  {atomic, ok} ->
                      ok
              end         
      end,RoleIDList).

receive_letter(RoleID,RoleName,Title,Text,GoodsList) ->
    Now = common_tool:now(),
    Letter = #r_letter_info{sender = "系统", 
                            receiver = RoleName, 
                            title = Title,
                            send_time = Now,
                            out_time = 14*86400+Now,
                            type = 2,
                            goods_list = GoodsList, 
                            text = Text},
    case db:read(letter_receiver, RoleID) of
        [] ->
            NewBox = #r_letter_receiver{role_id = RoleID,letter = [Letter#r_letter_info{id=1}],count=1},
            db:write(letter_receiver, NewBox, write),
            toc_letter(RoleID,Letter#r_letter_info{id=1}),
            ok;
        [ReceBox] -> 
            #r_letter_receiver{letter = OldLetter,count=Count} = ReceBox,
            NewBox = ReceBox#r_letter_receiver{letter = [Letter#r_letter_info{id=Count+1}|OldLetter],count=Count+1},
            db:write(letter_receiver, NewBox, write),
            toc_letter(RoleID,Letter#r_letter_info{id=Count+1}),
            ok;
        _ ->
            ignore
    end.


%%@doc 修改在线玩家的活跃度
%% set_ap(RoleID,ActPoint) when is_integer(RoleID) andalso is_integer(ActPoint)->
%%     common_misc:send_to_rolemap_mod(RoleID,hook_activity_task,{set_ap,{RoleID,ActPoint}}).

toc_letter(RoleID,RLetter) ->
    IHG = (not (RLetter#r_letter_info.goods_list =:= [])),
    Letter = #p_letter_simple_info{id   = RLetter#r_letter_info.id,
                                   sender   = RLetter#r_letter_info.sender,
                                   title    = RLetter#r_letter_info.title,       
                                   send_time  = RLetter#r_letter_info.send_time,   
                                   type       = RLetter#r_letter_info.type,     
                                   state      = RLetter#r_letter_info.state,     
                                   is_have_goods = IHG},
    Toc = #m_letter_send_toc{succ = true, letter = Letter},
    common_misc:unicast({role,RoleID}, 0, 21, 2111,Toc).


send_exp_goods(List) ->
    {ok,SSS} = file:open("/log_exp_goods.txt",write),
    lists:foreach(
      fun({RoleID,A,B,C}) ->
              case db:transaction(
                     fun() ->
                             [AttrInfo] = db:dirty_read(db_role_attr,RoleID),
                             case A > 0 of
                                 true ->
                                     CItem = #r_item_create_info{role_id=RoleID,num=A,typeid=10100002,bind=true,bag_id=1,bagposition=1},
                                     {ok,[TGoods]} = common_bag2:create_item(CItem),
                                     Title = "经验符补偿",
                                     Text = io_lib:format("亲爱的玩家:\n         您好，由于经验符的持续时间和价格调整，根据您原有的经验符数量，现给您补偿等量的\"初级经验符\”~w张，请您查收附件。祝您游戏愉快！\n                                     4399《天之刃》 ",[A]),
                                     receive_letter(RoleID,AttrInfo#p_role_attr.role_name,Title,Text,[TGoods#p_goods{id=1}]);
                                 false ->
                                     ignore
                             end,
                             case B > 0 of
                                 true ->
                                     CItem2 = #r_item_create_info{role_id=RoleID,num=B,typeid=10100003,bind=true,bag_id=1,bagposition=1},
                                     {ok,[TGoods2]} = common_bag2:create_item(CItem2),
                                     Title2 = "经验符补偿",
                                     Text2 = io_lib:format("亲爱的玩家:\n         您好，由于经验符的持续时间和价格调整，根据您原有的经验符数量，现给您补偿等量的\"中级经验符\”~w张，请您查收附件。祝您游戏愉快！\n                                     4399《天之刃》 ",[B]),
                                     receive_letter(RoleID,AttrInfo#p_role_attr.role_name,Title2,Text2,[TGoods2#p_goods{id=1}]);
                                 false ->
                                     ignore
                             end,
                              case C > 0 of
                                 true ->
                                     CItem3 = #r_item_create_info{role_id=RoleID,num=C,typeid=10100004,bind=true,bag_id=1,bagposition=1},
                                     {ok,[TGoods3]} = common_bag2:create_item(CItem3),
                                     Title3 = "经验符补偿",
                                     Text3 = io_lib:format("亲爱的玩家:\n         您好，由于经验符的持续时间和价格调整，根据您原有的经验符数量，现给您补偿等量的\"高级经验符\”~w张，请您查收附件。祝您游戏愉快！\n                                     4399《天之刃》 ",[C]),
                                     receive_letter(RoleID,AttrInfo#p_role_attr.role_name,Title3,Text3,[TGoods3#p_goods{id=1}]);
                                 false ->
                                     ignore
                             end
                     end)
                  of
                  {aborted, _} ->
                      io:format(SSS," ~w~n",[RoleID]);
                  {atomic, _} ->
                      ok
              end
      end,List).

modify_role_goods_offline(RoleID) ->
    [Attr] = db:dirty_read(db_role_attr_p,RoleID),
    case Attr#p_role_attr.equips of
        undefined ->
            ID = 1;
        EquipList ->
            {NewEquipList,NewID} = lists:foldr(
              fun(Equip,{AccEquipList,AccEquipID}) ->
                      {[Equip#p_goods{id=AccEquipID}|AccEquipList],AccEquipID+1}
              end,{[],1},EquipList),
            db:dirty_write(db_role_attr_p,Attr#p_role_attr{equips=NewEquipList}),
            ID = NewID
    end,
    ID2 = lists:foldl(
           fun(BagID,Acc) ->
                   case db:dirty_read(db_role_bag_p,{RoleID,BagID}) of
                       [] ->
                           Acc;
                       [Info] ->
                           {NewGoodsList,Acc3} = lists:foldr(
                                                   fun(GoodsInfo,{GoodsList2,Acc2}) ->
                                                           {[GoodsInfo#p_goods{id=Acc2}|GoodsList2],Acc2+1}
                                                   end, {[],Acc}, Info#r_role_bag.bag_goods),
                           db:dirty_write(db_role_bag_p,Info#r_role_bag{bag_goods=NewGoodsList}),
                           Acc3
                   end
           end,ID,[1,2,3,5,6,7,8,9]),
    StallList = db:dirty_match_object(?DB_STALL_GOODS,#r_stall_goods{_='_', role_id=RoleID}),
    lists:foldr(
      fun(Stall,Acc4) ->
              GoodInfo = Stall#r_stall_goods.goods_detail,
              NewGoodInfo = GoodInfo#p_goods{id=Acc4},
              db:dirty_delete(db_stall_goods,Stall#r_stall_goods.id),
              db:dirty_write(db_stall_goods,Stall#r_stall_goods{id={RoleID,Acc4},goods_detail=NewGoodInfo}),
              Acc4+1
      end,ID2,StallList).

modify_role_goods(RoleID) ->
    [Attr] = db:dirty_read(db_role_attr,RoleID),
    case Attr#p_role_attr.equips of
        undefined ->
            ID = 1;
        EquipList ->
            {NewEquipList,NewID} = lists:foldr(
              fun(Equip,{AccEquipList,AccEquipID}) ->
                      {[Equip#p_goods{id=AccEquipID}|AccEquipList],AccEquipID+1}
              end,{[],1},EquipList),
            db:dirty_write(db_role_attr,Attr#p_role_attr{equips=NewEquipList}),
            ID = NewID
    end,
    ID2 = lists:foldl(
           fun(BagID,Acc) ->
                   case db:dirty_read(db_role_bag_p,{RoleID,BagID}) of
                       [] ->
                           Acc;
                       [Info] ->
                           {NewGoodsList,Acc3} = lists:foldr(
                                                   fun(GoodsInfo,{GoodsList2,Acc2}) ->
                                                           {[GoodsInfo#p_goods{id=Acc2}|GoodsList2],Acc2+1}
                                                   end, {[],Acc}, Info#r_role_bag.bag_goods),
                           db:dirty_write(db_role_bag_p,Info#r_role_bag{bag_goods=NewGoodsList}),
                           Acc3
                   end
           end,ID,[1,2,3,5,6,7,8,9]),
    StallList = db:dirty_match_object(?DB_STALL_GOODS,#r_stall_goods{_='_', role_id=RoleID}),
    lists:foldr(
      fun(Stall,Acc4) ->
              GoodInfo = Stall#r_stall_goods.goods_detail,
              NewGoodInfo = GoodInfo#p_goods{id=Acc4},
              db:dirty_delete(db_stall_goods,Stall#r_stall_goods.id),
              db:dirty_write(db_stall_goods,Stall#r_stall_goods{id={RoleID,Acc4},goods_detail=NewGoodInfo}),
              Acc4+1
      end,ID2,StallList).


modify_all_role_goods(MinLevel,MaxLevel) ->
    lists:foreach(
      fun(Level) ->
              RoleList = db:dirty_match_object(db_role_attr,#p_role_attr{_='_',level=Level}),
              lists:foreach(
                fun(RoleAttr) ->
                        RoleID = RoleAttr#p_role_attr.role_id,
                        [Base] = db:dirty_read(db_role_base,RoleID),
                        AccountName = Base#p_role_base.account_name,
                        RoleLineName = common_misc:get_role_line_process_name(AccountName),
                        case global:whereis_name(RoleLineName) of
                            undefined ->
                                common_shell:modify_role_goods(RoleID);
                            _Pid ->
                               ignore
                        end,
                        timer:sleep(1)
                end, RoleList)
      end,lists:seq(MinLevel,MaxLevel)).



judge_role_bag_thing_error(RoleID) ->
    erlang:erase(),
    [Attr] = db:dirty_read(db_role_attr,RoleID),
    case Attr#p_role_attr.equips of
        undefined ->
            ignore;
        EquipList ->
            lists:foreach(
              fun(Equip) ->
                      case get(Equip#p_goods.id) of
                          undefined ->
                              put(Equip#p_goods.id,true);
                          _ ->
                              throw(error)
                      end
              end,EquipList)
    end,
    lists:foreach(
      fun(BagID) ->
              case db:dirty_read(db_role_bag,{RoleID,BagID}) of
                  [] ->
                      ignore;
                  [Info] ->
                      lists:foreach(
                        fun(GoodsInfo) ->
                                case get(GoodsInfo#p_goods.id) of
                                    undefined ->
                                        put(GoodsInfo#p_goods.id,true);
                                    _ ->
                                        throw(error)
                                end
                        end, Info#r_role_bag.bag_goods)
              end
      end,[1,2,3,5,6,7,8,9]),
    StallList = db:dirty_match_object(?DB_STALL_GOODS,#r_stall_goods{_='_', role_id=RoleID}),
    lists:foreach(
      fun(Stall) ->
              StallInfo = Stall#r_stall_goods.goods_detail,
              case get(StallInfo#p_goods.id) of
                  undefined ->
                      put(StallInfo#p_goods.id,true);
                  _ ->
                      throw(error)
              end
      end,StallList),
    ok.

judge_role_bag_thing_error(RoleID,Attr) ->
    erlang:erase(),
    case Attr#p_role_attr.equips of
        undefined ->
            ignore;
        EquipList ->
            lists:foreach(
              fun(Equip) ->
                      case get(Equip#p_goods.id) of
                          undefined ->
                              put(Equip#p_goods.id,true);
                          _ ->
                              throw(error)
                      end
              end,EquipList)
    end,
    lists:foreach(
      fun(BagID) ->
              case db:dirty_read(db_role_bag,{RoleID,BagID}) of
                  [] ->
                      ignore;
                  [Info] ->
                      lists:foreach(
                        fun(GoodsInfo) ->
                                case get(GoodsInfo#p_goods.id) of
                                    undefined ->
                                        put(GoodsInfo#p_goods.id,true);
                                    _ ->
                                        throw(error)
                                end
                        end, Info#r_role_bag.bag_goods)
              end
      end,[1,2,3,5,6,7,8,9]),
    StallList = db:dirty_match_object(?DB_STALL_GOODS,#r_stall_goods{_='_', role_id=RoleID}),
    lists:foreach(
      fun(Stall) ->
              StallInfo = Stall#r_stall_goods.goods_detail,
              case get(StallInfo#p_goods.id) of
                  undefined ->
                      put(StallInfo#p_goods.id,true);
                  _ ->
                      throw(error)
              end
      end,StallList),
    ok.


check_error_bag_role(CheckList) ->
    Fun = fun(RoleID) ->
                  erase(),
                  BagList = [1,2,3,5,6,7,8,9],
                  lists:foreach(
                    fun(BagID) ->
                            case db:dirty_read(db_role_bag,{RoleID,BagID}) of
                                [] ->
                                    ignore;
                                [BagInfo] ->
                                    GoodsList = BagInfo#r_role_bag.bag_goods,
                                    lists:foreach(
                                      fun(GoodsInfo) ->
                                              TypeID = GoodsInfo#p_goods.typeid,
                                              case lists:keyfind(TypeID, 1, CheckList) of
                                                  false ->
                                                      ignore;
                                                  {TypeID,MaxNum} ->
                                                      Num = GoodsInfo#p_goods.current_num,
                                                      case get(TypeID) of
                                                          undefined ->
                                                              NewNum = Num;
                                                          OldNum ->
                                                              NewNum = OldNum + Num
                                                      end,
                                                      case NewNum >= MaxNum of
                                                          true ->
                                                              throw(role_bag_error);
                                                          false ->
                                                              put(TypeID,NewNum)
                                                      end
                                              end
                                      end,GoodsList)
                            end
                    end,BagList)
          end,
    RoleList = db:dirty_match_object(db_role_ext,#p_role_ext{_='_'}),
    lists:foldl(
      fun(RoleExt,Acc) ->
              timer:sleep(1),
              RoleID = RoleExt#p_role_ext.role_id,
              OffTime = RoleExt#p_role_ext.last_offline_time,
              case OffTime > 1292486400 of
                  true ->
                      case catch Fun(RoleID) of
                          role_bag_error ->
                              [RoleID|Acc];
                          _ ->
                              Acc
                      end;
                  false ->
                      Acc
              end
      end,[],RoleList).
              
                  
update_pet_bag() ->
    List = db:dirty_match_object(?DB_ROLE_PET_BAG,#p_role_pet_bag{_='_'}),
    lists:foreach(
      fun(BagInfo) ->
              #p_role_pet_bag{pets=Pets} = BagInfo,
              NewPets = lists:foldr(
                fun({p_pet_id_name,PetID,PetName},Acc) ->
                        case db:dirty_read(?DB_PET,PetID) of
                            [] ->
                                Acc;
                            [#p_pet{color=Color}] ->
                                [#p_pet_id_name{pet_id=PetID,name=PetName,color=Color}|Acc]
                        end
                end,[],Pets),
              db:dirty_write(?DB_ROLE_PET_BAG,BagInfo#p_role_pet_bag{pets=NewPets})
      end,List).
                                
pet_feed_reset(RoleList) when is_list(RoleList) ->
    lists:foreach(fun(RoleID) -> catch pet_feed_reset(RoleID) end, RoleList);
pet_feed_reset(RoleID) ->
    case db:dirty_read(?DB_ROLE_ATTR_P,RoleID) of
        [] ->
            ignore;
        [#p_role_attr{level=RoleLevel}] ->
            case db:dirty_read(?DB_PET_FEED,RoleID) of
                [] ->
                    Exp = trunc(math:pow(RoleLevel, 1.5))*10+200,
                    FeedInfo = #p_pet_feed{role_id=RoleID,feed_type=4,last_feed_exp=Exp, feed_tick = 20*60},
                    db:dirty_write(?DB_PET_FEED,FeedInfo);
                [FeedInfo] ->
                    case FeedInfo#p_pet_feed.state =:= 3 orelse FeedInfo#p_pet_feed.star_level > 1 of
                        true ->
                            ignore;
                        false ->
                            Exp = trunc(math:pow(RoleLevel, 1.5))*10+200,
                            FeedInfo2 = FeedInfo#p_pet_feed{last_feed_exp=Exp},
                             db:dirty_write(?DB_PET_FEED,FeedInfo2)
                    end
            end
    end.


update_stone_config_handle(OldStoneConfigPath) ->              
    {ok, TmpStoneConfig} = file:consult(OldStoneConfigPath),
    TmpKeyValues = [{erlang:element(2, Config),Config} || Config <- TmpStoneConfig],
    common_config_dyn:load_gen_src(tmp_stone, TmpKeyValues),
    %%背包
    List1 = db:dirty_match_object(db_role_bag_p, #r_role_bag{_='_'}),
    lists:foreach(
      fun(#r_role_bag{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_has_stone_equip(Goods) end, GL),
              db:dirty_write(db_role_bag_p, R#r_role_bag{bag_goods=NGL})
      end,List1),
    %%种族背包
    List2 = db:dirty_match_object(db_family_depot, #r_family_depot{_='_'}),
    lists:foreach(
      fun(#r_family_depot{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_has_stone_equip(Goods) end, GL),
              db:dirty_write(db_family_depot, R#r_family_depot{bag_goods=NGL})
      end,List2),
    %%摆摊
    List3 = db:dirty_match_object(db_stall_goods, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = up_has_stone_equip(Goods),
              db:dirty_write(db_stall_goods, R#r_stall_goods{goods_detail=NewGoods})
      end,List3),
    List4 = db:dirty_match_object(db_stall_goods_tmp, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = up_has_stone_equip(Goods),
              db:dirty_write(db_stall_goods_tmp, R#r_stall_goods{goods_detail=NewGoods})
      end,List4),
    %%收件箱
    List5 = db:dirty_match_object(letter_receiver, #r_letter_receiver{_='_'}),
    lists:foreach(
      fun(#r_letter_receiver{letter=LS}=R) ->
              NLS = lists:map(
                      fun(#r_letter_info{goods_list=GL}=Ler) ->
                              NGL = lists:map(fun(Goods) -> up_has_stone_equip(Goods) end, GL),
                              Ler#r_letter_info{goods_list=NGL}
                      end,LS),
              db:dirty_write(letter_receiver, R#r_letter_receiver{letter=NLS})
      end,List5),
    %%角色身上的装备
    List6 = db:dirty_match_object(db_role_attr, #p_role_attr{_='_'}),
    lists:foreach(
      fun(#p_role_attr{equips=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_has_stone_equip(Goods) end, GL),
              db:dirty_write(db_role_attr, R#p_role_attr{equips=NGL})
      end,List6),
    %%
    %%
    %%
    code:purge(tmp_stone_config_codegen).
    
up_has_stone_equip(#p_goods{type=?TYPE_EQUIP,stones=[_|_]}=Goods) ->
    Goods1 = 
        lists:foldl(
          fun(Stone, Equip) ->
                  case common_config_dyn:find(tmp_stone, Stone#p_goods.typeid) of
                      [] ->
                          io:format(user,"bad old stone type id:~w~n",[Stone#p_goods.typeid]),
                          Equip;
                      [BaseInfo] ->
                          BasePro = BaseInfo#p_stone_base_info.level_prop,
                          Pro = Equip#p_goods.add_property,
                          SeatList =
                              case get_main_property_seat(BasePro#p_property_add.main_property) of
                                  SeatR when is_integer(SeatR) andalso SeatR > 1 ->
                                      [SeatR];
                                  SeatR when is_list(SeatR) ->
                                      SeatR;
                                  _ ->
                                      []
                              end,
                          NewPro = lists:foldl(
                                     fun(Seat,AccPro) ->
                                             R = erlang:element(Seat, AccPro)-erlang:element(Seat,BasePro),
                                             erlang:setelement(Seat, AccPro, R)
                                     end,Pro,SeatList),
                          Equip#p_goods{add_property = NewPro}
                  end
          end,Goods,Goods#p_goods.stones),
    Goods2 = 
         lists:foldl(
          fun(Stone, Equip) ->
                  case common_config_dyn:find(stone, Stone#p_goods.typeid) of
                      [] ->
                          io:format(user,"bad new stone type id:~w~n",[Stone#p_goods.typeid]),
                          Equip;
                      [BaseInfo] ->
                          BasePro = BaseInfo#p_stone_base_info.level_prop,
                          Pro = Equip#p_goods.add_property,
                          SeatList =
                              case get_main_property_seat(BasePro#p_property_add.main_property) of
                                  SeatR when is_integer(SeatR) andalso SeatR > 1 ->
                                      [SeatR];
                                  SeatR when is_list(SeatR) ->
                                      SeatR;
                                  _ ->
                                      []
                              end,
                          NewPro = lists:foldl(
                                     fun(Seat,AccPro) ->
                                             R = erlang:element(Seat, AccPro)+erlang:element(Seat,BasePro),
                                             erlang:setelement(Seat, AccPro, R)
                                     end,Pro,SeatList),
                          Equip#p_goods{add_property = NewPro}
                  end
          end,Goods1,Goods#p_goods.stones),
    Goods2;
up_has_stone_equip(Goods) ->
    Goods.


get_main_property_seat(Main) ->
    [List]= common_config_dyn:find(refining,main_property),
    proplists:get_value(Main, List).

update_role_equips(OldConfigPath, RoleIDs) ->
    {ok, TmpStoneConfig} = file:consult(OldConfigPath),
    TmpKeyValues = [{erlang:element(2, Config),Config} || Config <- TmpStoneConfig],
    common_config_dyn:load_gen_src(tmp_stone, TmpKeyValues),
    L1 = lists:foldl(
           fun(RoleID, Acc) ->
                   case db:dirty_read(db_role_attr,RoleID) of
                       [RoleAttr] ->
                           [RoleAttr|Acc];
                       _ ->
                           Acc
                   end
           end,[], RoleIDs),
    lists:foreach(
      fun(#p_role_attr{equips=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_has_stone_equip(Goods) end, GL),
              db:dirty_write(db_role_attr, R#p_role_attr{equips=NGL})
      end,L1),
    code:purge(tmp_stone_config_codegen).

map_exec_up_role_equip() ->
    %%背包
    List1 = db:dirty_match_object(db_role_bag_p, #r_role_bag{_='_'}),
    lists:foreach(
      fun(#r_role_bag{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_equip(Goods) end, GL),
              db:dirty_write(db_role_bag_p, R#r_role_bag{bag_goods=NGL})
      end,List1),
    %%门派仓库
    List2 = db:dirty_match_object(db_family_depot, #r_family_depot{_='_'}),
    lists:foreach(
      fun(#r_family_depot{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_equip(Goods) end, GL),
              db:dirty_write(db_family_depot, R#r_family_depot{bag_goods=NGL})
      end,List2),
    %%摆摊
    List3 = db:dirty_match_object(db_stall_goods, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = up_equip(Goods),
              ?DEBUG("Stall:~w ~w ~n",[NewGoods,Goods]),
              db:dirty_write(db_stall_goods, R#r_stall_goods{goods_detail=NewGoods})
      end,List3),
    List4 = db:dirty_match_object(db_stall_goods_tmp, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = up_equip(Goods),
              db:dirty_write(db_stall_goods_tmp, R#r_stall_goods{goods_detail=NewGoods})
      end,List4),
    %%信件
    List5 = db:dirty_match_object(db_personal_letter_p, #r_personal_letter{_='_'}),
    lists:foreach(
      fun(#r_personal_letter{goods_list=GL}=R) ->
              NGL = lists:map(fun(Goods) -> up_equip(Goods) end, GL),
              db:dirty_write(db_personal_letter_p, R#r_personal_letter{goods_list=NGL})
      end,List5),
    List6 = db:dirty_match_object(db_public_letter_p, #r_letter_detail{_='_'}),
    lists:foreach(
      fun(#r_letter_detail{goods_list=GL}=R) ->
              NGL = lists:map(fun(Goods) -> up_equip(Goods) end, GL),
              db:dirty_write(db_public_letter_p, R#r_letter_detail{goods_list=NGL})
      end,List6),
    %%角色身上的装备
    List7 = db:dirty_match_object(db_role_attr, #p_role_attr{_='_'}),
    lists:foreach(
      fun(#p_role_attr{equips=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_equip(Goods) end, GL),
              db:dirty_write(db_role_attr, R#p_role_attr{equips=NGL})
      end,List7),
    %%
    %%
    %%
    code:purge(tmp_stone_config_codegen).

up_equip(#p_goods{type=?TYPE_EQUIP, typeid=TypeID}=Goods) ->
    [#p_equip_base_info{property=Pro}=NewEquipInfo] = common_config_dyn:find_equip(TypeID),
    SubQuality = 
        if Goods#p_goods.quality > 1 ->
                2;
           true ->
                0
        end,
    NewEquipGoods = Goods#p_goods{add_property=Pro,sub_quality = SubQuality},
    %% 新装备处理
    %% 颜色品质处理
    NewGoods = mod_refining:equip_colour_quality_add(new,NewEquipGoods,1,1,1),
    %% 强化处理
    NewGoods2 = equip_reinforce_property_add(NewGoods,NewEquipInfo),
    %% 宝石处理
    NewGoods3 = 
        if NewGoods2#p_goods.stones =/= undefined ->
                equip_stone_property_add(NewGoods2);
           true ->
                NewGoods2
        end,
    %% 绑定处理
    NewGoods4 = mod_refining_bind:do_equip_bind_for_equip_upgrade(NewGoods3,NewEquipInfo),
    ?DEBUG("~ts,EquipOld=~w,EquipNew=~w",["装备升级前后绑定属性处理结果",NewGoods3,NewGoods4]),
    %% 装备五行属性
    %% 材料绑定处理
    NewGoods5 =
        if NewGoods4#p_goods.bind ->
                case mod_refining_bind:do_equip_bind_for_upgrade(NewGoods4) of 
                    {error,BindErrorCode} ->
                        ?INFO_MSG("~ts,BindErrorCode",["装备升级时，当材料是绑定的，装备是不绑定时，处理绑定出错，只是做绑定处理，没有附加属性",BindErrorCode]),
                        NewGoods4#p_goods{bind=true};
                    {ok,BindGoods} ->
                        BindGoods
                end;
           true ->
                NewGoods4
        end,
    %% 精炼系数处理
    NewGoods6 = case common_misc:do_calculate_equip_refining_index(NewGoods5) of
                    {error,ErrorCode} ->
                        ?DEBUG("~ts,ErrorCode=~w",["计算装备精炼系数出错",ErrorCode]),
                        NewGoods5;
                    {ok,RefiningIndexGoods} ->
                        RefiningIndexGoods
                end,
    NewGoods6,
    up_mount_move(NewGoods6);
up_equip(Goods) ->
    up_mount_move(Goods).

%% 装备强化属性处理
equip_reinforce_property_add(EquipGoods,EquipBaseInfo) ->
    EquipPro = EquipGoods#p_goods.add_property,
    BasePro = EquipBaseInfo#p_equip_base_info.property,
    MainProperty = BasePro#p_property_add.main_property,
    ReinforceRate = EquipGoods#p_goods.reinforce_rate,
    NewEquipPro=mod_refining:change_main_property(MainProperty,EquipPro,BasePro,0,ReinforceRate),
    EquipGoods#p_goods{add_property = NewEquipPro}.
%% 宝石加成处理
equip_stone_property_add(EquipGoods) ->
    Stones = EquipGoods#p_goods.stones,
    equip_stone_property_add2(Stones,EquipGoods).
equip_stone_property_add2([],EquipGoods) ->
    EquipGoods;
equip_stone_property_add2([H|T],EquipGoods) ->
    StoneTypeId = H#p_goods.typeid,
    {ok,StoneBaseInfo} = mod_stone:get_stone_baseinfo(StoneTypeId),
    NewEquipGoods = equip_stone_property_add3(StoneBaseInfo,EquipGoods),
    equip_stone_property_add2(T,NewEquipGoods).

equip_stone_property_add3(StoneBaseInfo,EquipGoods) ->
    EquipPro = EquipGoods#p_goods.add_property,
    StoneBasePro = StoneBaseInfo#p_stone_base_info.level_prop,
    SeatList =
        case equip_stone_property_add4(StoneBasePro#p_property_add.main_property) of
            SeatR when is_integer(SeatR) andalso SeatR > 1 ->
                [SeatR];
            SeatR when is_list(SeatR) ->
                SeatR;
            _ ->
                ?INFO_MSG("~ts,EquipGoods=~w,StoneBaseInfo=~w",["装备升级时，处理宝石数据遇到不可处理的宝石数据",EquipGoods,StoneBaseInfo]),
                []
        end,
    NewEquipPro = lists:foldl(
                    fun(Seat,AccPro) ->
                            Value = erlang:element(Seat, AccPro) + erlang:element(Seat,StoneBasePro),
                            erlang:setelement(Seat, AccPro, Value)
                    end,EquipPro,SeatList),
    EquipGoods#p_goods{add_property = NewEquipPro}.
equip_stone_property_add4(Main) ->
    [List] = common_config_dyn:find(refining,main_property),
    proplists:get_value(Main, List).


map_process_exec_change_mount_speed() ->
    lists:foreach(
      fun(#p_role_attr{role_id=RoleID}) ->
              timer:sleep(10), 
              map_process_exec_change_mount_speed(RoleID)
      end, db:dirty_match_object(db_role_attr, #p_role_attr{_='_'})).


map_process_exec_change_mount_speed(RoleID) ->
    case common_misc:send_to_rolemap(RoleID, 
                                     {func, 
                                      fun() ->   
                                              up_bag_mount(RoleID),
                                              up_attr_mount(RoleID)
                                      end, []}) 
    of
        ok ->
            ok;
        {false, map_process_not_found} ->
            up_bag_mount(RoleID),
            up_attr_mount(RoleID)
    end.

up_bag_mount(RoleID) ->
    State = 
        lists:foldl(
          fun(BagID, A) ->
                  case get({role_bag,RoleID,BagID}) of
                      undefined ->
                          A;
                      {_Content,_OutUseTime,_UsedPositionList,GoodsList,_Modified} ->
                          NG = lists:map(fun(Goods) -> up_mount_move(Goods) end, GoodsList),
                          put({role_bag,RoleID,BagID}, {_Content,_OutUseTime,_UsedPositionList,NG,_Modified}),
                          false
                  end
          end,true,[1,2,3,4,5,6,7,8,9]),
    case State of
        true ->
            lists:foreach(
              fun(BagID) ->
                      case catch db:dirty_read(db_role_bag_p, {RoleID, BagID}) of
                          [#r_role_bag{bag_goods=GL}=R] ->
                              NGL=lists:map(fun(Goods) -> up_mount_move(Goods) end, GL),
                              db:dirty_write(db_role_bag_p, R#r_role_bag{bag_goods=NGL});
                          _ ->
                              ignore
                      end
              end,[1,2,3,4,5,6,7,8,9]);
        false ->
            ok
    end.

up_attr_mount(RoleID) ->
    case  get({role_attr, RoleID}) of
        undefined ->
            case db:dirty_read(db_role_attr,RoleID) of
                [#p_role_attr{equips=Eqs} = Attr] ->
                    NEqs = lists:map(fun(Goods) -> up_mount_move(Goods) end, Eqs),
                    db:dirty_write(db_role_attr,  Attr#p_role_attr{equips=NEqs});
                _ ->
                    notrole
            end;
        #p_role_attr{equips=Eqs} = Attr ->
            ?DEBUG("Attr:~w~n",[Attr]),
            NEqs = lists:map(fun(Goods) -> up_mount_move(Goods) end, Eqs),
            ?DEBUG("R:~w",[Attr =:= Attr#p_role_attr{equips=NEqs}]),
            put({role_attr, RoleID}, Attr#p_role_attr{equips=NEqs}),
            ok
    end.

up_mount_move(#p_goods{typeid=TypeID, current_colour = Colour} = Goods) ->
    case common_config_dyn:find(mount_level, TypeID) of
        [L] -> 
            case lists:keyfind(Colour, 2, L)of
                false ->
                    Goods;
                #r_mount_level{speed=Speed} ->
                    Goods#p_goods{add_property=#p_property_add{move_speed=Speed, _=0}}
            end;
        _ ->
            Goods
    end;
up_mount_move(Goods) ->
    Goods.


%%--------------------------------------------------------------------------------------------
%% -define(ROLE_COLLECT_FILE,"/data/role_collect_file.txt").
%% -define(COLLECT_FILE,"/data/collect_file.txt").
%% -define(ROLE_COLLECT_ERROR_FILE,"/data/role_collect_error_file.txt").

%% map_process_exec_collect() ->
%%     List = db:dirty_match_object(db_role_attr, #p_role_attr{_='_'}),
%%     LevelL = lists:seq(16,26),
%%     RL = lists:foldl(
%%            fun(#p_role_attr{role_id=RoleID,level=Level}, Acc) ->
%%                    case lists:member(Level, LevelL) of
%%                        true ->
%%                            [{RoleID,Level}|Acc];
%%                        false ->
%%                            Acc
%%                    end
%%            end,List),
%%     Pid = spawn(
%%             fun() -> 
                    
%%                     map_reduce_collect(RL, []),
%%             end),
%%     lists:foreach(
%%       fun({RoleID,Level}) ->
%%               case common_misc:send_to_rolemap(RoleID, 
%%                                                {func, 
%%                                                 fun() ->   
%%                                                         collect_mp_hp(RoleID,Level,Pid)
%%                                                 end, []}) 
%%               of
%%                   ok ->
%%                       ok;
%%                   {false, map_process_not_found} ->
%%                       spawn(fun() -> collect_mp_hp(RoleID,Level,Pid) end)
%%               end
%%       end,RL).

%% map_reduce_collect([], Acc) ->
%%     ok;
%% map_reduce_collect(RL, Acc) ->
%%     receive
%%         {collect,{RoleID,Level,RL}} ->
%%             R = format_collect_data(RoleID,Level, RL),
%%             map_reduce_collect(lists:keydelete(RoleID,1,RL), Acc);
%%         _ ->
%%             map_reduce_collect(RL, Acc)
%%     after 50000 ->
%%             file:write_file(Fd, M, [append]),
            
%%     end.

%% format_collect_data(RoleID,Level, RL) ->
%%     lists:foldl(
%%       fun({10200002,V}, {D1,D2,D3,D4,D5,D6}) ->
%%               {D1,D2,D3,D4,D5,D6};
%%          ({10200003,V}, {D1,D2,D3,D4,D5,D6}) ->
%%               ok;
%%          ({10200004,V}, {D1,D2,D3,D4,D5,D6}) ->
%%               ok;
%%          ({10200006,V}, {D1,D2,D3,D4,D5,D6}) ->
%%               ok;
%%          ({10200007,V}, {D1,D2,D3,D4,D5,D6}) ->
%%               ok;
%%          ({10200008,V}, {D1,D2,D3,D4,D5,D6}) ->
%%               ok
%%       end,{0,0,0,0,0,0},Rl),
              
%%     file:write_file(Fd, M, [append])
%%         ok.

%% format_collect_sum_data(Acc) ->
    

%% collect_mp_hp(RoleID,Level,Pid) ->
%%     State = 
%%         lists:foldl(
%%           fun(BagID, {F,CL}) ->
%%                   case get({role_bag,RoleID,BagID}) of
%%                       undefined ->
%%                           {F,CL};
%%                       {_Content,_OutUseTime,_UsedPositionList,GoodsList,_Modified} ->
%%                           NCL = collect_data(GoodsList, CL),
%%                           {false,NCL}
%%                   end
%%           end,{true,[]},[1,2,3,4,5,6,7,8,9]),
%%     case State of
%%         {true, _} ->
%%             List = db:dirty_match_object(db_role_bag_p, #r_role_bag{_='_'}),
%%             NCL = lists:foldl(
%%                     fun(#r_role_bag{role_bag_key = Key, bag_goods=GL}=R, A) ->
%%                             case Key of
%%                                 {RoleID, _} ->
%%                                     collect_data(GL, A);
%%                                 _ ->
%%                                     A
%%                             end
%%                     end,[],List),
%%             erlang:send(Pid,{collect,sum_data(RoleID, Level, NCL)});
%%         {false,CollectL} ->
%%             erlang:send(Pid,{collect,sum_data(RoleID, Level, CollectL)})
%%     end.

%% collect_data(GoodsList, Acc) ->
%%     lists:foldl(
%%       fun(Goods,AL) ->
%%               case lists:keytake(Goods#p_goods.typeid,1,AL) of
%%                   false ->
%%                       [{Goods#p_goods.typeid,1}|AL];
%%                   {value, {K,V}, NAL} ->
%%                       [{K,V+1}|NAL]
%%               end
%%       end,Acc,Goods).

%% sum_data(RoleID, Level, L) ->
%%     TL = [10200002, 10200003, 10200004, 10200006, 10200007, 10200008],
%%     {RoleID, Level, [KV || {K,_}=KV <- L, true =:= lists:member(K,TL)]}.

%% p_goods结构变化，需要处理的数据
%% 执行此函数时，必须确认游戏没有玩家的情况下执行
%% 此脚本可以运行多次
update_p_goods_structure() ->
    %%背包
    List1 = db:dirty_match_object(db_role_bag_p, #r_role_bag{_='_'}),
    lists:foreach(
      fun(#r_role_bag{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_p_goods_structure(Goods) end, GL),
              db:dirty_write(db_role_bag_p, R#r_role_bag{bag_goods=NGL})
      end,List1),
    %%门派仓库
    List2 = db:dirty_match_object(db_family_depot, #r_family_depot{_='_'}),
    lists:foreach(
      fun(#r_family_depot{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_p_goods_structure(Goods) end, GL),
              db:dirty_write(db_family_depot, R#r_family_depot{bag_goods=NGL})
      end,List2),
    %%摆摊
    List3 = db:dirty_match_object(db_stall_goods, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = up_p_goods_structure(Goods),
              db:dirty_write(db_stall_goods, R#r_stall_goods{goods_detail=NewGoods})
      end,List3),
    List4 = db:dirty_match_object(db_stall_goods_tmp, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = up_p_goods_structure(Goods),
              db:dirty_write(db_stall_goods_tmp, R#r_stall_goods{goods_detail=NewGoods})
      end,List4),
    %%信件
    List5 = db:dirty_match_object(db_personal_letter_p, #r_personal_letter{_='_'}),
    lists:foreach(
      fun(#r_personal_letter{goods_list=GL}=R) ->
              NGL = lists:map(fun(Goods) -> up_p_goods_structure(Goods) end, GL),
              db:dirty_write(db_personal_letter_p, R#r_personal_letter{goods_list=NGL})
      end,List5),
    List6 = db:dirty_match_object(db_public_letter_p, #r_public_letter{_='_'}),
    lists:foreach(
      fun(#r_public_letter{letterbox=GL}=R) ->
              NGL = 
                  lists:map(
                    fun(#r_letter_detail{goods_list = GoodsList} = RR) -> 
                            GoodsList2 = lists:map(fun(Goods) -> up_p_goods_structure(Goods) end, GoodsList),
                            RR#r_letter_detail{goods_list = GoodsList2}
                    end,GL),
              db:dirty_write(db_public_letter_p, R#r_public_letter{letterbox=NGL})
      end,List6),
    %%角色身上的装备
    List7 = db:dirty_match_object(db_role_attr_p, #p_role_attr{_='_'}),
    lists:foreach(
      fun(#p_role_attr{equips=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_p_goods_structure(Goods) end, GL),
              db:dirty_write(db_role_attr, R#p_role_attr{equips=NGL})
      end,List7),
    %% 玩家奖励道具
    List8 = db:dirty_match_object(db_role_gift, #r_role_gift{_='_'}),
    lists:foreach(
      fun(#r_role_gift{gifts = Gifts}=R) ->
              case lists:keyfind(1,#r_role_gift_info.gift_type,Gifts) of
                  false ->
                      ignore;
                  #r_role_gift_info{cur_gift = GiftGoodsList} = GiftInfo ->
                      GiftGoodsList2 = lists:map(fun(Goods) -> up_p_goods_structure(Goods) end, GiftGoodsList),
                      GiftInfo2=GiftInfo#r_role_gift_info{cur_gift = GiftGoodsList2},
                      Gifts2 = lists:keydelete(1,#r_role_gift_info.gift_type,Gifts),
                      db:dirty_write(db_role_gift, R#r_role_gift{gifts = [GiftInfo2|Gifts2]})
              end
      end,List8),
    ok.
up_p_goods_structure(Goods) ->
    case  erlang:is_record(Goods,p_goods) of 
        true ->
            if Goods#p_goods.type =:= 3 ->
                    QualityRate = get_p_goods_quality_rate(Goods#p_goods.quality),
                    Goods#p_goods{sub_quality = 2,quality_rate = QualityRate};
               true ->
                    Goods
            end;
        false ->
            {p_goods,Id,Type,Roleid,Bagposition,Current_num,Bagid,Sell_type,Sell_price,Typeid,Bind,Start_time,End_time,Current_colour,
             State,Name,Level,Embe_pos,Embe_equipid,Loadposition,Quality,Current_endurance,Forge_num,Reinforce_result,Punch_num,
             Stone_num,Add_property,Stones,Reinforce_rate,Endurance,Signature,Equip_bind_attr,Refining_index,Sign_role_id,Five_ele_attr,
             Whole_attr,Reinforce_result_list,Use_bind} = Goods,
            if Type =:= 3 -> %% 装备镶嵌的宝石处理
                    Stones2 = 
                        case Stones of
                            undefined ->
                                [];
                            [] ->
                                [];
                            _ ->
                                lists:map(fun(StoneGoods) -> up_p_goods_structure2(StoneGoods) end,Stones)
                        end,
                    QualityRate2 = get_p_goods_quality_rate(Quality),
                    SubQuality2 = 2,
                    ok;
               true ->
                    SubQuality2 = 0,
                    QualityRate2 = 0,
                    Stones2 = Stones
            end,
            {p_goods,Id,Type,Roleid,Bagposition,Current_num,Bagid,Sell_type,Sell_price,Typeid,Bind,Start_time,End_time,Current_colour,
             State,Name,Level,Embe_pos,Embe_equipid,Loadposition,Quality,Current_endurance,Forge_num,Reinforce_result,Punch_num,
             Stone_num,Add_property,Stones2,Reinforce_rate,Endurance,Signature,Equip_bind_attr,Refining_index,Sign_role_id,Five_ele_attr,
             Whole_attr,Reinforce_result_list,Use_bind,SubQuality2,QualityRate2}
    end.
up_p_goods_structure2(Goods) ->
    case  erlang:is_record(Goods,p_goods) of 
        true ->
            Goods;
        false ->
            {p_goods,Id,Type,Roleid,Bagposition,Current_num,Bagid,Sell_type,Sell_price,Typeid,Bind,Start_time,End_time,Current_colour,
             State,Name,Level,Embe_pos,Embe_equipid,Loadposition,Quality,Current_endurance,Forge_num,Reinforce_result,Punch_num,
             Stone_num,Add_property,Stones,Reinforce_rate,Endurance,Signature,Equip_bind_attr,Refining_index,Sign_role_id,Five_ele_attr,
             Whole_attr,Reinforce_result_list,Use_bind} = Goods,
            {p_goods,Id,Type,Roleid,Bagposition,Current_num,Bagid,Sell_type,Sell_price,Typeid,Bind,Start_time,End_time,Current_colour,
             State,Name,Level,Embe_pos,Embe_equipid,Loadposition,Quality,Current_endurance,Forge_num,Reinforce_result,Punch_num,
             Stone_num,Add_property,Stones,Reinforce_rate,Endurance,Signature,Equip_bind_attr,Refining_index,Sign_role_id,Five_ele_attr,
             Whole_attr,Reinforce_result_list,Use_bind,0,0}
    end.
get_p_goods_quality_rate(Quality) ->
    case Quality of 
        1 ->
            0;
        2 ->
            10;
        3 ->
            20;
        4 ->
            30;
        5 ->
            40;
        _ ->
            0
    end.
%% 处理坐骑，时装的品质数据问题
update_p_goods_data_for_special() ->
    %%背包
    List1 = db:dirty_match_object(db_role_bag_p, #r_role_bag{_='_'}),
    lists:foreach(
      fun(#r_role_bag{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_p_goods_data_special(Goods) end, GL),
              db:dirty_write(db_role_bag_p, R#r_role_bag{bag_goods=NGL})
      end,List1),
    %%门派仓库
    List2 = db:dirty_match_object(db_family_depot, #r_family_depot{_='_'}),
    lists:foreach(
      fun(#r_family_depot{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_p_goods_data_special(Goods) end, GL),
              db:dirty_write(db_family_depot, R#r_family_depot{bag_goods=NGL})
      end,List2),
    %%摆摊
    List3 = db:dirty_match_object(db_stall_goods, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = up_p_goods_data_special(Goods),
              db:dirty_write(db_stall_goods, R#r_stall_goods{goods_detail=NewGoods})
      end,List3),
    List4 = db:dirty_match_object(db_stall_goods_tmp, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = up_p_goods_data_special(Goods),
              db:dirty_write(db_stall_goods_tmp, R#r_stall_goods{goods_detail=NewGoods})
      end,List4),
    %%信件
    List5 = db:dirty_match_object(db_personal_letter_p, #r_personal_letter{_='_'}),
    lists:foreach(
      fun(#r_personal_letter{goods_list=GL}=R) ->
              NGL = lists:map(fun(Goods) -> up_p_goods_data_special(Goods) end, GL),
              db:dirty_write(db_personal_letter_p, R#r_personal_letter{goods_list=NGL})
      end,List5),
    List6 = db:dirty_match_object(db_public_letter_p, #r_public_letter{_='_'}),
    lists:foreach(
      fun(#r_public_letter{letterbox=GL}=R) ->
              NGL = 
                  lists:map(
                    fun(#r_letter_detail{goods_list = GoodsList} = RR) -> 
                            GoodsList2 = lists:map(fun(Goods) -> up_p_goods_data_special(Goods) end, GoodsList),
                            RR#r_letter_detail{goods_list = GoodsList2}
                    end,GL),
              db:dirty_write(db_public_letter_p, R#r_public_letter{letterbox=NGL})
      end,List6),
    %%角色身上的装备
    List7 = db:dirty_match_object(db_role_attr_p, #p_role_attr{_='_'}),
    lists:foreach(
      fun(#p_role_attr{equips=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_p_goods_data_special(Goods) end, GL),
              db:dirty_write(db_role_attr, R#p_role_attr{equips=NGL})
      end,List7),
    %% 玩家奖励道具
    List8 = db:dirty_match_object(db_role_gift, #r_role_gift{_='_'}),
    lists:foreach(
      fun(#r_role_gift{gifts = Gifts}=R) ->
              case lists:keyfind(1,#r_role_gift_info.gift_type,Gifts) of
                  false ->
                      ignore;
                  #r_role_gift_info{cur_gift = GiftGoodsList} = GiftInfo ->
                      GiftGoodsList2 = lists:map(fun(Goods) -> up_p_goods_data_special(Goods) end, GiftGoodsList),
                      GiftInfo2=GiftInfo#r_role_gift_info{cur_gift = GiftGoodsList2},
                      Gifts2 = lists:keydelete(1,#r_role_gift_info.gift_type,Gifts),
                      db:dirty_write(db_role_gift, R#r_role_gift{gifts = [GiftInfo2|Gifts2]})
              end
      end,List8),
    ok.
up_p_goods_data_special(Goods) ->
    case Goods#p_goods.type =:= ?TYPE_EQUIP of
        true ->
            [GoodsBaseInfo] = common_config_dyn:find_equip(Goods#p_goods.typeid),
            case (GoodsBaseInfo#p_equip_base_info.slot_num =:= 11 
                  orelse GoodsBaseInfo#p_equip_base_info.slot_num =:= 12) of
                true ->
                    Goods#p_goods{quality = 0,sub_quality = 0,quality_rate = 0};
                _ ->
                    Goods
            end;
        _ ->
            Goods
    end.

%% 处理装备的套装数据
update_p_goods_data_for_whole() ->
    %%背包
    List1 = db:dirty_match_object(db_role_bag_p, #r_role_bag{_='_'}),
    lists:foreach(
      fun(#r_role_bag{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_p_goods_data_whole(Goods) end, GL),
              db:dirty_write(db_role_bag_p, R#r_role_bag{bag_goods=NGL})
      end,List1),
    %%门派仓库
    List2 = db:dirty_match_object(db_family_depot, #r_family_depot{_='_'}),
    lists:foreach(
      fun(#r_family_depot{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_p_goods_data_whole(Goods) end, GL),
              db:dirty_write(db_family_depot, R#r_family_depot{bag_goods=NGL})
      end,List2),
    %%摆摊
    List3 = db:dirty_match_object(db_stall_goods, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = up_p_goods_data_whole(Goods),
              db:dirty_write(db_stall_goods, R#r_stall_goods{goods_detail=NewGoods})
      end,List3),
    List4 = db:dirty_match_object(db_stall_goods_tmp, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = up_p_goods_data_whole(Goods),
              db:dirty_write(db_stall_goods_tmp, R#r_stall_goods{goods_detail=NewGoods})
      end,List4),
    %%信件
    List5 = db:dirty_match_object(db_personal_letter_p, #r_personal_letter{_='_'}),
    lists:foreach(
      fun(#r_personal_letter{goods_list=GL}=R) ->
              NGL = lists:map(fun(Goods) -> up_p_goods_data_whole(Goods) end, GL),
              db:dirty_write(db_personal_letter_p, R#r_personal_letter{goods_list=NGL})
      end,List5),
    List6 = db:dirty_match_object(db_public_letter_p, #r_public_letter{_='_'}),
    lists:foreach(
      fun(#r_public_letter{letterbox=GL}=R) ->
              NGL = 
                  lists:map(
                    fun(#r_letter_detail{goods_list = GoodsList} = RR) -> 
                            GoodsList2 = lists:map(fun(Goods) -> up_p_goods_data_whole(Goods) end, GoodsList),
                            RR#r_letter_detail{goods_list = GoodsList2}
                    end,GL),
              db:dirty_write(db_public_letter_p, R#r_public_letter{letterbox=NGL})
      end,List6),
    %%角色身上的装备
    List7 = db:dirty_match_object(db_role_attr_p, #p_role_attr{_='_'}),
    lists:foreach(
      fun(#p_role_attr{equips=GL}=R) ->
              NGL=lists:map(fun(Goods) -> up_p_goods_data_whole(Goods) end, GL),
              db:dirty_write(db_role_attr, R#p_role_attr{equips=NGL})
      end,List7),
    %% 玩家奖励道具
    List8 = db:dirty_match_object(db_role_gift, #r_role_gift{_='_'}),
    lists:foreach(
      fun(#r_role_gift{gifts = Gifts}=R) ->
              case lists:keyfind(1,#r_role_gift_info.gift_type,Gifts) of
                  false ->
                      ignore;
                  #r_role_gift_info{cur_gift = GiftGoodsList} = GiftInfo ->
                      GiftGoodsList2 = lists:map(fun(Goods) -> up_p_goods_data_whole(Goods) end, GiftGoodsList),
                      GiftInfo2=GiftInfo#r_role_gift_info{cur_gift = GiftGoodsList2},
                      Gifts2 = lists:keydelete(1,#r_role_gift_info.gift_type,Gifts),
                      db:dirty_write(db_role_gift, R#r_role_gift{gifts = [GiftInfo2|Gifts2]})
              end
      end,List8),
    ok.
up_p_goods_data_whole(Goods) ->
    case Goods#p_goods.type =:= ?TYPE_EQUIP of
        true ->
            [GoodsBaseInfo] = common_config_dyn:find_equip(Goods#p_goods.typeid),
            case (GoodsBaseInfo#p_equip_base_info.slot_num =:= 11 
                  orelse GoodsBaseInfo#p_equip_base_info.slot_num =:= 12) of
                true ->
                    Goods;
                _ ->
                    case Goods#p_goods.whole_attr =/= undefined of
                        true ->
                            Goods;
                        _ ->
                            mod_equip_fiveele:do_random_equip_whole_attr(Goods)
                    end
            end;
        _ ->
            Goods
    end.

rep_educate_info() ->
    List = db:dirty_match_object(db_role_educate, #r_educate_role_info{_='_'}),
    lists:foreach(
      fun(#r_educate_role_info{teacher=undefined,teacher_name=TName}=Info) ->
              case TName of
                  undefined->
                      ignore;
                  _ ->
                      Teacher = common_misc:get_roleid(TName),
                      NewInfo = Info#r_educate_role_info{teacher=Teacher},
                      db:dirty_write(db_role_educate, NewInfo)
              end;
         (_) ->
              ignore
      end,List).



t_pay_get_date(OrderID, AccountName, PayTime, PayGold, PayMoney)->
     {{Y,M,D},{H,_,_}} = common_tool:seconds_to_datetime(PayTime),
      t_do_pay(OrderID, AccountName, PayTime, PayGold, PayMoney, {Y, M, D, H}, false).


t_do_pay(OrderID, AccountName, PayTime, PayGold, PayMoney, {Year, Month, Day, Hour},IsFirst) ->
    %%判断是否该订单已经处理过
    case mnesia:match_object(db_pay_log, #r_pay_log{order_id=OrderID, _='_'}, write) of
        [] ->
            case mnesia:match_object(db_role_base_p, #p_role_base{account_name=AccountName, _='_'}, write) of
                [] ->
                    mnesia:abort("error,no role");
                [RoleBase] ->                    
                    t_do_pay2(OrderID, AccountName, RoleBase, PayTime, PayGold, PayMoney, {Year, Month, Day, Hour},IsFirst)
            end;
        _ ->
            mnesia:abort("this order is done")
    end.
t_do_pay2(OrderID, AccountName, RoleBase, PayTime, PayGold, PayMoney, {Year, Month, Day, Hour},IsFirst) ->
    #p_role_base{role_id=RoleID, role_name=RoleName} = RoleBase,
    [#p_role_attr{level=RoleLevel}] = db:read(db_role_attr_p, RoleID),
    [#r_pay_log_index{value=ID}] = db:read(db_pay_log_index, 1),
    %%记录日志
    %%给对应的玩家添加元宝，发信件通知玩家
    RLog = #r_pay_log{id=ID+1,order_id=OrderID, role_id=RoleID, role_name=RoleName,
                      account_name=AccountName, pay_time=PayTime, pay_gold=PayGold,
                      pay_money=PayMoney, year=Year, month=Month, day=Day, hour=Hour, is_first=IsFirst,role_level=RoleLevel},
    t_do_pay_not_first(RLog, 1 + ID).
        
%% 不满足首充
t_do_pay_not_first(RLog, NewID) ->
    mnesia:write(db_pay_log, RLog, write),
    mnesia:write(db_pay_log_index, #r_pay_log_index{id=1, value=NewID}, write),
    ok.


    
