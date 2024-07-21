%%% -------------------------------------------------------------------
%%% Author  : liuwei
%%% Description :角色等级排行榜
%%% 
%%% Created : 2010-10-9
%%% -------------------------------------------------------------------
-module(ranking_role_level).

-include("mgeew.hrl").


-export([
         init/1,
         rank/0,
         update/1,
         cmp/2,
         send_ranking_info/7,
         get_role_rank/1,
         check_unactivity_role_back/1,
         do_rank_activity/0
        ]).
%%
%%================API FUCTION=======================
%%
init(RankInfo) ->
    RankSize = RankInfo#p_ranking.capacity,
    case db:dirty_match_object(?DB_ROLE_LEVEL_RANK,#p_role_level_rank{_ = '_'}) of
        [] ->
            read_rank_data(RankSize);
        _RoleRankList ->
            RoleRankList2 = rank(),
            lists:foldl(
              fun(NewList, Acc) ->
                      ranking_minheap:new_heap(?MODULE, {?MODULE, Acc}, RankSize, NewList),
                      Acc - 1
              end, 4, RoleRankList2)
    end.


rank() ->
    RankList = db:dirty_match_object(?DB_ROLE_LEVEL_RANK, #p_role_level_rank{_='_'}),
    {CateList1, CateList2, CateList3, CateList4} =
        lists:foldl(
          fun(#p_role_level_rank{role_id=RoleID}=Rank, {List1, List2, List3, List4}) ->
                  case db:dirty_read(?DB_ROLE_ATTR, RoleID) of
                      [] ->
                          {List1, List2, List3, List4};
                      [RoleAttr] ->
                          #p_role_attr{category=Category} = RoleAttr,
                          case Category of
                              1 ->
                                  {[{RoleAttr, Rank}|List1], List2, List3, List4};
                              2 ->
                                  {List1, [{RoleAttr, Rank}|List2], List3, List4};
                              3 ->
                                  {List1, List2, [{RoleAttr, Rank}|List3], List4};
                              4 ->
                                  {List1, List2, List3, [{RoleAttr, Rank}|List4]};
                              _ ->
                                  db:dirty_delete(?DB_ROLE_LEVEL_RANK, RoleID),
                                  {List1, List2, List3, List4}
                          end
                  end
          end, {[], [], [], []}, RankList),

    {_, AllList, RankList2} = 
        lists:foldl(
          fun(CateL, {C, TL, RL}) -> 
                  {NewList, TitleList} = rank2(C, CateL), 
                  {C+1, lists:append(TitleList, TL), [NewList|RL]}
          end, {1, [], []}, [CateList1, CateList2, CateList3, CateList4]),
    common_title:add_title(?TITLE_ROLE_LEVEL_RANK,0,AllList),
    RankList2.

rank2(Category, List) ->
    case ranking_minheap:get_max_heap_size({?MODULE,Category}) of
        undefined ->
            RankSize = undefined,
            RankSize2=50;
        RankSize ->
            RankSize2 = RankSize
    end,
    List2 = delete_unactivity_from_rank_list(List),
    List3 = lists:foldr(
              fun({RoleAttr, RoleLevelRank}, Acc) ->
                      RoleID = RoleLevelRank#p_role_level_rank.role_id,
                      #p_role_attr{exp=NewExp, level=NewLevel} = RoleAttr,
                      case common_misc:get_dirty_role_base(RoleID) of
                          {ok, RoleBase} ->
                              FamilyName = RoleBase#p_role_base.family_name,
                              NewRoleLevelRank = RoleLevelRank#p_role_level_rank{
                                                                                 level=NewLevel, 
                                                                                 exp = NewExp,
                                                                                 family_name=FamilyName},
                              [NewRoleLevelRank|Acc];
                          _ ->
                              Acc
                      end
              end, [], List2),
    List4 = lists:sort(fun(E1,E2) -> cmp(E1,E2) end,List3),
    {_, List5} = lists:foldl(
                   fun(RoleLevelRank, {Rank, Acc}) ->
                           case Rank > RankSize2 of
                               true ->
                                   db:dirty_delete(?DB_ROLE_LEVEL_RANK,RoleLevelRank#p_role_level_rank.role_id),
                                   {Rank-1,Acc};
                               false ->
                                   TitleName = common_title:get_title_name_of_rank(?TITLE_ROLE_LEVEL_RANK,Rank,Category),
                                   NewRoleLevelRank = RoleLevelRank#p_role_level_rank{ranking=Rank, title=TitleName},
                                   db:dirty_write(?DB_ROLE_LEVEL_RANK,NewRoleLevelRank),
                                   {Rank-1, [NewRoleLevelRank|Acc]}
                           end
                   end,{length(List4),[]},List4),
    put({{?MODULE, Category},ranking_info_list},List5), 
    NewList = lists:foldr(
                fun(RoleLevelRank2,Acc2) -> 
                        [{RoleLevelRank2,RoleLevelRank2#p_role_level_rank.role_id}|Acc2]
                end,[],List5),
    case RankSize of
        undefined ->
            ignore;
        _ ->
        ranking_minheap:clear_heap({?MODULE,Category}),
        ranking_minheap:new_heap(?MODULE,{?MODULE,Category},RankSize2,NewList)
    end,
    {NewList, List5}.


%% update(RoleAttr) ->
%%     ?DEBUG("rolettr = ~w",[RoleAttr]),
%%     #p_role_attr{
%%                  role_id = RoleID,
%%                  level = Level,
%%                  exp = Exp,
%%                  role_name = RoleName
%%                 } = RoleAttr,
%%     case db:dirty_read(?DB_ROLE_BASE,RoleID) of
%%         [] ->
%%             nil;
%%         [RoleBase] ->
%%             #p_role_base{faction_id = FactionID, family_name = FamilyName} = RoleBase,
%%             ?DEBUG("family name = ~w",[FamilyName]),
%%             RoleLevelRank = #p_role_level_rank{
%%                                                role_id = RoleID,
%%                                                level = Level,
%%                                                exp = Exp,
%%                                                role_name = RoleName,
%%                                                faction_id = FactionID, 
%%                                                family_name = FamilyName},
%%             Category = RoleAttr#p_role_attr.category,
%%             ranking_minheap:update_heap(RoleLevelRank#p_role_level_rank{category=Category},RoleID,?DB_ROLE_LEVEL_RANK,?MODULE,{?MODULE,Category})
%%     end.          

update(RoleLevelRank) when is_record(RoleLevelRank,p_role_level_rank)->
    Category = RoleLevelRank#p_role_level_rank.category,
    RoleID = RoleLevelRank#p_role_level_rank.role_id,
    ranking_minheap:update_heap(RoleLevelRank,RoleID,?DB_ROLE_LEVEL_RANK,?MODULE,{?MODULE,Category});
update(Info)->
    ?ERROR_MSG("ranking role level unknow info:~w",[Info]).


cmp(RoleLevelRank1, RoleLevelRank2) ->
    ?DEBUG(" ~w     ~w",[RoleLevelRank1, RoleLevelRank2]),
    #p_role_level_rank{level = Level1, exp = Exp1, ranking=Rank1, role_id = RoleID1} = RoleLevelRank1,
    #p_role_level_rank{level = Level2, exp = Exp2, ranking=Rank2, role_id = RoleID2} = RoleLevelRank2,
    NewRank1 =case Rank1 of
                  undefined->999;
                  _->Rank1
              end,
    NewRank2 = case Rank2 of
                   undefined->999;
                   _->Rank2
               end,
    mgeew_ranking:cmp([{Level1,Level2},{Exp1,Exp2},{NewRank2,NewRank1},{RoleID2,RoleID1}]).


get_role_rank(RoleID) ->
    case db:dirty_read(?DB_ROLE_LEVEL_RANK,RoleID) of
        [] ->
            undefined;
        [RoleLevelRank] ->
            #p_role_level_rank{level = Level,ranking = Rank} = RoleLevelRank,
            #p_role_all_rank{ key_value=Level, ranking = Rank}
    end.

send_ranking_info(Unique, Module, Method, _RoleID, PID, RankID,Category)->
    RoleRankList = get({{?MODULE,Category},ranking_info_list}),
    RankRows = transform_row(RoleRankList),
    R2 = #m_ranking_get_rank_toc{rank_id=RankID,rows=RankRows},
    ?UNICAST_TOC(R2).

transform_row(undefined)->
    [];
transform_row(RoleRankList) when is_list(RoleRankList)->
    [ transform_row(Rec) ||Rec<-RoleRankList];
transform_row(Rec)->
    #p_role_level_rank{ranking=Ranking,role_id=RoleID,role_name=RoleName,faction_id=FactionId,family_name=FamilyName,level=Level,title=Title} = Rec,
    #p_rank_row{row_id=Ranking,role_id=RoleID,
                elements=[RoleName,common_misc:get_faction_name(FactionId),FamilyName,
                          common_tool:to_list(Level),Title
                         ]}.

     
check_unactivity_role_back(RoleID) ->
    case db:dirty_read(db_role_ext,RoleID) of
        [] ->
            ignore;
        [RoleExt] ->
            Now = common_tool:now(),
            LastOfflineTime = RoleExt#p_role_ext.last_offline_time,
            case LastOfflineTime =:= undefined 
                     orelse Now - LastOfflineTime < 2592000 of
                true ->
                    ignore;    
                false ->
                    case db:dirty_read(db_role_attr,RoleID) of
                        [] ->
                            ignore;
                        [RoleAttr] ->
                            common_rank:update_element(ranking_role_level,RoleAttr)
                    end
            end
    end.

do_rank_activity()->
    lists:foreach(fun(Category)-> 
                          List1 = get({{?MODULE,Category},ranking_info_list}),
                          List2 = [{RankInfo#p_role_level_rank.role_id,RankInfo#p_role_level_rank.ranking}||RankInfo<-List1],
                          mgeew_ranking:send_ranking_activity(?RANK_ROLE_LEVEL_KEY,List2)
                  end,[1,2,3,4]).

%%
%%================LOCAL FUCTION=======================
%%
read_rank_data(RankSize) ->
    ranking_minheap:new_heap({?MODULE,1},RankSize),
    ranking_minheap:new_heap({?MODULE,2},RankSize),
    ranking_minheap:new_heap({?MODULE,3},RankSize),
    ranking_minheap:new_heap({?MODULE,4},RankSize),
    case db:dirty_match_object(?DB_ROLE_ATTR_P,#p_role_attr{_ = '_'}) of
        [] ->
            nil;
        List -> 
            lists:foreach(fun(RoleAttr) -> 
                                  case RoleAttr#p_role_attr.level>=30 of
                                      true->
                                          {ok,RoleBase}=common_misc:get_dirty_role_base(RoleAttr#p_role_attr.role_id),
                                          RoleLevelRank=common_ranking:get_level_rank_record(RoleBase, RoleAttr),
                                          update(RoleLevelRank);
                                      _->
                                          ignore
                                  end
                          end,List)
    end,
    rank().
    

delete_unactivity_from_rank_list(List) ->
    {H,_M,_S} = erlang:time(),
    %%每天凌晨4点刷新排行榜的时候清除1个月内没有登录的玩家
    case H =:= 4 of
        true ->
            Now = common_tool:now(),
            lists:foldr(
              fun({RA, RoleLevelRank}, Acc) ->
                      RoleID = RoleLevelRank#p_role_level_rank.role_id,
                      case db:dirty_read(?DB_ROLE_EXT,RoleID) of
                          [] ->
                              Acc;
                          [RoleExt] ->
                              LastOfflineTime = RoleExt#p_role_ext.last_offline_time,
                              
                              case LastOfflineTime =:= undefined 
                                       orelse Now - LastOfflineTime < 2592000 of
                                  true ->
                                      [{RA, RoleLevelRank}|Acc];
                                  false ->
                                      db:dirty_delete(?DB_ROLE_LEVEL_RANK,RoleID),
                                      Acc
                              end
                      end
              end,[],List);
        false ->
            List
    end.
