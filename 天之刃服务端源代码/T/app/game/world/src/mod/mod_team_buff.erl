%%%-------------------------------------------------------------------
%%% @author  caochuncheng
%%% @copyright mcsd (C) 2010, 
%%% @doc
%%% 组队状态处理模块
%%% @end
%%% Created :  7 Jul 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_team_buff).

%% Include files
-include("mgeew.hrl").

%% API
-export([handle/1]).


%%%===================================================================
%%% API
%%%===================================================================
handle(Info) ->
    ?DEBUG("~ts Info=~w",["接收到的组队状态处理参数", Info]),
    do_handle_info(Info),
    ok.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
do_handle_info({TeamRoleList}) ->
    do_team_friend_buff(TeamRoleList),
    do_team_educate_buff(TeamRoleList);
do_handle_info({delete_role_team_buff,RoleId}) ->
    common_misc:send_to_rolemap(RoleId, {mod_map_role, 
                                         {remove_buff, RoleId, RoleId, role, 
                                          [?FRIEND_BUFF_TYPE,?EDUCATE_BUFFTYPE1,?EDUCATE_BUFFTYPE2]}}),
    erase({educate_buff,RoleId});
do_handle_info(Info) ->
    ?ERROR_MSG("~ts Info=~w",["无法处理组队状态参数",Info]).

delete_role_team_friend_buff(RoleID) ->
    common_misc:send_to_rolemap(RoleID, {mod_map_role, {remove_buff, RoleID, RoleID, role, ?FRIEND_BUFF_TYPE}}).

do_team_friend_buff(TeamRoleList) ->

    %%筛选队伍成员，并得到两人的亲密度等级
    FriendList = [{TeamRoleA#p_team_role.role_id, TeamRoleB#p_team_role.role_id, 
                   get_friend_level(TeamRoleA#p_team_role.role_id, TeamRoleB#p_team_role.role_id)} 
                  || TeamRoleA <- TeamRoleList,
                     TeamRoleB <- TeamRoleList,
                     TeamRoleA#p_team_role.is_offline =:= false,
                     TeamRoleB#p_team_role.is_offline =:= false,
                     TeamRoleA#p_team_role.role_id =/= TeamRoleB#p_team_role.role_id,
                     mod_team:check_valid_distance(TeamRoleA,TeamRoleB) =:= true],
    ?DEBUG("do_team_friend_buff, friendlist: ~w", [FriendList]),

    %%去掉等级为0的组
    FriendList2 = filter_friend_level(FriendList),
    ?DEBUG("do_team_friend_buff, friendlist3: ~w", [FriendList2]),

    %%加好友度
    do_team_add_friendly(FriendList2),

    FriendList3 = filter_friend_level2(FriendList2),
    ?DEBUG("do_team_friend_buff, friendlsit4: ~w", [FriendList3]),

    %%每个队员分别加BUFF
    do_team_friend_buff2(FriendList3).
    

do_team_friend_buff2(FriendList) ->
    [FriendBuffList] = common_config_dyn:find(friend,friend_buff),
    lists:foreach(
      fun({RoleID, _FriendID, Level}) ->
              %%获取应该加的BUFF
              {Level,BuffID}= lists:keyfind(Level,1,FriendBuffList),
              {ok, BuffDetail} = mgeew_skill_server:get_buf_detail(BuffID),
              %%发一个加BUFF的消息给角色
              common_misc:send_to_rolemap(RoleID, {mod_map_role, {add_buff, RoleID, RoleID, role, BuffDetail}})
      end, FriendList).

do_team_add_friendly(FriendList) ->
    Now = common_tool:now(),
    lists:foreach(
      fun({RoleID, FriendID, _}) ->
              case get({add_friendly, FriendID, RoleID}) of
                  undefined ->
                      case get_last_time_add_friendly(RoleID, FriendID) of
                          undefined ->
                              do_team_add_friendly2(RoleID, FriendID);
                          LastTime ->
                              [{_,InternalSeconds,_}] = common_config_dyn:find(friend,add_friendly_by_team),
                              case Now - LastTime >= InternalSeconds of
                                  true ->
                                      do_team_add_friendly2(RoleID, FriendID);
                                  _ ->
                                      ignore
                              end
                      end;
                  _ ->
                      erase({add_friendly, FriendID, RoleID})
              end
      end, FriendList).

do_team_add_friendly2(RoleID, FriendID) ->
    case global:whereis_name(mod_friend_server) of
        undefined ->
            ignore;
        PID ->
            [{AddFriendly,_,_}] = common_config_dyn:find(friend,add_friendly_by_team),
            PID ! {add_friendly, RoleID, FriendID, AddFriendly, 1},
            put({last_time_add_friendly, RoleID, FriendID}, common_tool:now()),
            put({add_friendly, RoleID, FriendID}, true)
    end.

get_last_time_add_friendly(RoleID, FriendID) ->
    case get({last_time_add_friendly, RoleID, FriendID}) of
        undefined ->
            get({last_time_add_friendly, FriendID, RoleID});
        LastTime ->
            LastTime
    end.

%%根据亲密度划分等级，仇人或黑名单都没有BUFF加成
get_friend_level(RoleID, FriendID) ->
    try
        FriendInfo = mod_friend_server:get_dirty_friend_info(RoleID, FriendID),
        Friendly = FriendInfo#r_friend.friendly,
        FriendType = FriendInfo#r_friend.type,
        if FriendType =/= 1 ->
                0;
           true ->
                case mod_friend_server:get_friend_base_info_by_friendly(Friendly) of
                    #r_friend_base_info{friend_level = FriendLevel} ->
                        FriendLevel;
                    _ ->
                        0
                end
        end
    catch
        _ : _ ->
            0
    end.

filter_friend_level(FriendList) ->
    lists:foldl(
      fun({RoleID, FriendID, Level}, Acc) ->
              case Level =:= 0 of
                  true ->
                      case if_other_friend_in_team(RoleID, FriendList) of
                          true ->
                              Acc;

                          false ->
                              delete_role_team_friend_buff(RoleID),
                              Acc
                      end;
                  _ ->
                      [{RoleID, FriendID, Level}|Acc]
              end
      end, [], FriendList).

filter_friend_level2(FriendList) ->
    lists:foldl(
      fun({RoleID, FriendID, Level}, Acc) ->
              case lists:keyfind(RoleID, 1, Acc) of
                  false ->
                      [{RoleID, FriendID, Level}|Acc];
                  {RoleID, _, MaxLevel} ->
                      case Level > MaxLevel of
                          true ->
                              [{RoleID, FriendID, Level}|lists:keydelete(RoleID, 1, Acc)];
                          _ ->
                              Acc
                      end
              end
      end, [], FriendList).

do_team_educate_buff(TeamRoleList) ->
    ?DEBUG("TeamRoleList:~w~n",[TeamRoleList]),
    %%取出队伍中的师徒关系
    RoleIDs1 = [RoleID || #p_team_role{role_id = RoleID} <- TeamRoleList],
    {_,TupleList} = 
        lists:foldl(
          fun(RoleID1, {[_|RoleIDs2], Acc1}) ->
                  {RoleIDs2,lists:foldl(fun(RoleID2, Acc2) ->[{RoleID1,RoleID2}|Acc2] end,Acc1,RoleIDs2)}
          end,{RoleIDs1, []},RoleIDs1),
    RList = lists:foldl(
              fun({RoleID1,RoleID2}, Acc) ->
                      lists:append(Acc, check(RoleID1,RoleID2,
                                              lists:keyfind(RoleID1,#p_goods.roleid,TeamRoleList),
                                              lists:keyfind(RoleID2,#p_goods.roleid,TeamRoleList)))
              end,[], TupleList),
    ?DEBUG("TupleList:~w RList:~w~n",[TupleList,RList]),
    {L1,L2,L3} = 
        lists:foldl(
          fun({true, RoleID},{Acc1,Acc2,Acc3}) ->
                  {[RoleID|Acc1], Acc2, Acc3};
             ({false,RoleID},{Acc1,Acc2,Acc3}) ->
                  {Acc1, Acc2, [RoleID|Acc3]};
             ({true, RoleID1, RoleID2},{Acc1,Acc2,Acc3}) ->
                  {Acc1, [RoleID1,RoleID2|Acc2], Acc3};
             ({false,RoleID1,RoleID2},{Acc1,Acc2,Acc3}) ->
                  {Acc1, Acc2, [RoleID1,RoleID2|Acc3]}
          end,{[],[],[]},zip(RList)),
    {NL1,NL2,NL3}={zip(L1),zip(L2),zip(L3)},
    {NNL1,NNL2,NNL3}={lists:subtract(NL1,NL2),NL2,lists:subtract(NL3,NL1++NL2)},
    ?DEBUG("L1:~w L2:~w L3:~w~n",[L1,L2,L3]),
    ?DEBUG("NL1:~w NL2:~w NL3:~w~n",[NL1,NL2,NL3]),
    ?DEBUG("NNL1:~w NNL2:~w NNL3:~w~n",[NNL1,NNL2,NNL3]),
    lists:foreach(fun(R) -> check_delete_educate_buff(R) end, NL3),
    {ok,BuffDetail1} = mgeew_skill_server:get_buf_detail(?EDUCATE_BUFFID1),
    {ok,BuffDetail2} = mgeew_skill_server:get_buf_detail(?EDUCATE_BUFFID2),
    lists:foreach(fun(R) -> add_educate_team_buf(BuffDetail1,R) end, NL1),
    lists:foreach(fun(R) -> add_educate_team_buf(BuffDetail2,R) end, NL2).

zip(List) ->
    lists:foldl(
      fun(R,Acc) ->
              case lists:member(R,Acc) of
                  true ->
                      Acc;
                  false ->
                      [R|Acc]
              end
      end,[],List).

check(RoleID1, RoleID2, TeamRoleInfoA,TeamRoleInfoB) ->
    [#r_educate_role_info{teacher=T1,level=L1}]
        = db:dirty_read(?DB_ROLE_EDUCATE,RoleID1),
    [#r_educate_role_info{teacher=T2,level=L2}] 
        = db:dirty_read(?DB_ROLE_EDUCATE,RoleID2),
    if T1 =:= RoleID2 ->
            case L1 > 59 of
                false ->
                    case TeamRoleInfoB#p_team_role.is_offline =:= false of
                        false ->
                            ?DEBUG("Teacher offline",[]),
                            [{false,RoleID2,RoleID1}];
                        _  ->
                            case mod_team:check_valid_distance(TeamRoleInfoA,TeamRoleInfoB) of
                                true ->
                                    [{true, RoleID2,RoleID1}];
                                false ->
                                    [{true, RoleID1},{false,RoleID2}]
                            end
                    end;
                true ->
                    [{false,RoleID2,RoleID1}]
            end;
       T2 =:= RoleID1 ->
             case L2 > 59 of
                false ->
                    case TeamRoleInfoA#p_team_role.is_offline =:= false of
                        false ->
                            ?DEBUG("Teacher offline",[]),
                            [{false,RoleID1,RoleID2}];
                        _  ->
                            case mod_team:check_valid_distance(TeamRoleInfoA,TeamRoleInfoB) of
                                true ->
                                    [{true, RoleID1,RoleID2}];
                                false ->
                                    [{true, RoleID2},{false,RoleID1}]
                            end
                    end;
                true ->
                    [{false,RoleID1,RoleID2}]
            end;
       T1 =:= undefined andalso T2 =:= undefined ->
            [{false, RoleID1, RoleID2}];
       true ->
            Acc1 = 
                case L1 > 59 of
                    false ->
                        case common_misc:is_role_online(T1) of
                            false ->
                                ?DEBUG("other teacher offline",[]),
                                [{false, RoleID1, RoleID2}];
                            _ ->
                                [{true,RoleID1},{false,RoleID2}]
                        end;
                    true ->
                        [{false, RoleID1, RoleID2}]
                end,
            Acc2 = 
                case L2 > 59 of
                    false ->
                        case common_misc:is_role_online(T2) of
                            false ->
                                ?DEBUG("other teacher offline",[]),
                                [{false, RoleID1, RoleID2}|Acc1];
                            _ ->
                                [{true,RoleID2},{false,RoleID1}|Acc1]
                        end;
                    true ->
                        [{false, RoleID1, RoleID2}|Acc1]
                end,
            Acc2
    end.

check_delete_educate_buff(RoleID) ->
    case get({educate_buff, RoleID}) of
        undefined ->
            ok;
        BuffType ->
            delete_role_team_educate_buff(RoleID, BuffType)
    end.
                    
delete_role_team_educate_buff(_,undefined) ->  
    ok;
delete_role_team_educate_buff(RoleID,BuffType) ->
    ?DEBUG("Remove RoleID:~w Educate Buff:~w~n",[RoleID, BuffType]),
    common_misc:send_to_rolemap(RoleID, {mod_map_role, {remove_buff, RoleID, RoleID, role, BuffType}}),
    erase({educate_buff,RoleID}).

add_educate_team_buf(BuffDetail,RoleID) ->
    ?DEBUG("add educate team buf, buffdetail: ~w", [BuffDetail]),
    BuffType1 = BuffDetail#p_buf.buff_type,
    case get({educate_buff, RoleID}) of
        undefined ->
            common_misc:send_to_rolemap(RoleID, {mod_map_role, {add_buff, RoleID, RoleID, role, BuffDetail}}),
            put({educate_buff, RoleID},BuffType1);
        BuffType1 ->
            ok;
        BuffType2 ->
            ?DEBUG("BuffID2 ~w ~n",[BuffType2]),
            delete_role_team_educate_buff(RoleID,BuffType2),
            common_misc:send_to_rolemap(RoleID, {mod_map_role, {add_buff, RoleID, RoleID, role, BuffDetail}}),
            put({educate_buff, RoleID}, BuffType1)
    end.

if_other_friend_in_team(RoleID, FriendList) ->
    lists:any(
      fun({TmpRoleID, _FriendID, Level}) ->
              case RoleID =:= TmpRoleID of
                  true ->
                      case Level =:= 0 of
                          true ->
                              false;

                          _ ->
                              true
                      end;
                  
                  _ ->
                      false
              end
      end, FriendList).
