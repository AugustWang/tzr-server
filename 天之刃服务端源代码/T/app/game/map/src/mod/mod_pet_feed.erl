%% Author: liuwei
%% Created: 2011-3-16
%% Description:  宠物训练
-module(mod_pet_feed).

%%
%% Include files
%%
-include("mgeem.hrl").

%%
%% Exported Functions
%%
-export([
         do_pet_feed_info/5,
         do_pet_feed_begin/5,
         do_pet_feed_commit/6,
         do_pet_feed_give_up/5,
         do_pet_feed_star_up/5,
         reset_role_pet_feed_info/1,
         check_feed_over/0,
         init_role_pet_feed/0,
         change_feed_exp/2,
         t_deduct_gold/3
        ]).
-define(ROLE_PET_FEED_OVER_TICK,role_pet_feed_over_tick).
-define(ROLE_PET_FEED_LIST,role_pet_feed_list).

-define(FEED_LOG_COMMIT_NORMAL,1).    %% 1=>完成训练
-define(FEED_LOG_COMMIT_SPEED,2).     %% 2=>立即完成训练
-define(FEED_LOG_GIVE_UP,3).          %% 3=>放弃训练
-define(FEED_LOG_STAR_UP_FREE,4).     %% 4=>提升星级
-define(FEED_LOG_STAR_UP,5).          %% 5=>立即提升星级
-define(FEED_LOG_EXTRA_FEED,6).       %% 6=>强行训练

%%
%% API Functions
%%
init_role_pet_feed() ->
    put(?ROLE_PET_FEED_LIST,[]).

do_pet_feed_info(Unique, _DataIn, RoleID, Line, _State) ->
    
    case db:dirty_read(?DB_PET_FEED,RoleID) of
        [] ->
            NewFeedInfo = #p_pet_feed{role_id=RoleID,last_feed_exp=2005,feed_type=4,feed_tick=(16+4)*60},
            db:dirty_write(?DB_PET_FEED,NewFeedInfo),
            do_pet_feed_info_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR);
        [FeedInfo] ->
            FeedInfo2=change_over_tick_to_left_tick_for_client(FeedInfo),
            Record = #m_pet_feed_info_toc{succ=true,info=FeedInfo2},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_INFO, Record)
    end.


do_pet_feed_info_error(Unique, RoleID, Line, Reason) ->
%%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_feed_info_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_INFO, Record).



-define(PET_FEED_ITEM_TYPE,12300134).
do_pet_feed_begin(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_feed_begin_tos{pet_id=PetID} = DataIn,
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        PetID ->
            do_pet_feed_begin_error(Unique, RoleID, Line, ?_LANG_CAN_NOT_FEED_SUMMONED_PET);
        _ ->
            Fun = fun() ->
                          case db:read(?DB_PET_FEED,RoleID) of
                              [] ->
                                  db:abort(?_LANG_PET_NOT_EXIST);
                              [FeedInfo] ->
                                  case FeedInfo#p_pet_feed.state =:= ?PET_FEED_STATE of
                                      true ->
                                          db:abort(?_LANG_PET_ALREADLY_FEEDED);
                                      false ->
                                          pet_feed_begin_2(FeedInfo,RoleID, PetID)
                                  end
                          end
                  end,
            case db:transaction(Fun) of
                {aborted, Reason} ->
                    do_pet_feed_begin_error(Unique, RoleID, Line, Reason);
                {atomic, {ok,NewFeedInfo,ChangeList, DelList,{NewRoleAttr,Gold,UnbindGold}}} ->
                    put({?ROLE_PET_FEED_OVER_TICK,RoleID},{PetID,NewFeedInfo#p_pet_feed.feed_over_tick}),
                    put(?ROLE_PET_FEED_LIST,[RoleID|get(?ROLE_PET_FEED_LIST)]),
                    %% 通知客户端物品变动
                    case ChangeList of
                        [] ->
                            ignore;
                        GoodsList ->
                            lists:foreach( 
                              fun(Goods) ->
                                      common_item_logger:log(RoleID,Goods,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                                      common_misc:update_goods_notify({line, Line, RoleID}, Goods)
                              end,GoodsList)
                    end,
                    
                    case DelList of
                        [] ->
                            ignore;
                        GoodsList2 ->
                            lists:foreach( 
                              fun(Goods2) ->
                                      common_item_logger:log(RoleID,Goods2,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU),
                                      common_misc:del_goods_notify({line, Line, RoleID}, Goods2)
                              end,GoodsList2)
                    end,
                    NewFeedInfo2=change_over_tick_to_left_tick_for_client(NewFeedInfo),
                    Record = #m_pet_feed_begin_toc{succ=true,info=NewFeedInfo2},
                    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_BEGIN, Record),
                    case NewRoleAttr of
                        undefined ->
                            ignore;
                        _ ->
                            write_pet_feed_log(NewFeedInfo#p_pet_feed.pet_id, "", RoleID, ?FEED_LOG_EXTRA_FEED, Gold,UnbindGold, NewFeedInfo#p_pet_feed.star_level),
                            AttrChangeList = [
                                              #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=NewRoleAttr#p_role_attr.gold},
                                              #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.gold_bind}],
                            common_misc:role_attr_change_notify({role, RoleID}, RoleID, AttrChangeList)
                    end
            end
    end.


pet_feed_begin_2(FeedInfo,RoleID, PetID) ->
    Day = calendar:date_to_gregorian_days(date()),
    #p_pet_feed{
                last_feed_day=LastFeedDay,
                feed_time=FeedTime} = FeedInfo,
    case LastFeedDay =:= undefined orelse LastFeedDay < Day of
        true ->
            pet_feed_begin_3(FeedInfo,RoleID, 1, Day, PetID);
        false ->
            %%每天最多饲养6次
            case FeedTime < 6 of
                true ->
                    pet_feed_begin_3(FeedInfo,RoleID,FeedTime+1,Day, PetID);
                false ->
                    pet_feed_begin_4(FeedInfo,RoleID,FeedTime+1,Day, PetID)
            end
    end.


pet_feed_begin_3(FeedInfo,RoleID, NewFeedTime, Day, PetID) ->
    {ok, ChangeList, DelList} = mod_map_pet:t_deduct_item(?PET_FEED_ITEM_TYPE, RoleID),
    Time = FeedInfo#p_pet_feed.feed_tick,
    Now = common_tool:now(),
    NewFeedInfo = FeedInfo#p_pet_feed{state=?PET_FEED_STATE,
                                      pet_id=PetID,
                                      last_feed_day=Day,
                                      feed_time=NewFeedTime,
                                      feed_over_tick=Now+Time},
    db:write(?DB_PET_FEED,NewFeedInfo,write),
    [PetInfo] = db:read(?DB_PET,PetID),
    db:write(?DB_PET,PetInfo#p_pet{state=?PET_FEED_STATE},write),
    {ok,NewFeedInfo,ChangeList, DelList,{undefined,0,0}}.

pet_feed_begin_4(FeedInfo,RoleID, NewFeedTime, Day, PetID) ->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    NeedGold = get_extra_feed_gold(NewFeedTime-1),
    #p_role_attr{gold_bind = BindGold, gold = Gold} = RoleAttr,
    case BindGold + Gold >= NeedGold of
        false ->
            NewRoleAttr = undefined,
            {DeductBind,DeductUnBind} = {0,0},
            db:abort(?_LANG_NOT_ENOUGH_GOLD);
        true ->
            {NewRoleAttr,DeductBind,DeductUnBind} = t_deduct_gold(RoleAttr,NeedGold,?CONSUME_TYPE_GOLD_PET_EXTRA_FEED),
            mod_map_role:set_role_attr(RoleID, NewRoleAttr)
    end,
    {ok, ChangeList, DelList} = mod_map_pet:t_deduct_item(?PET_FEED_ITEM_TYPE, RoleID),
    Time = FeedInfo#p_pet_feed.feed_tick,
    Now = common_tool:now(),
    NewFeedInfo = FeedInfo#p_pet_feed{state=?PET_FEED_STATE,
                                      pet_id=PetID,
                                      last_feed_day=Day,
                                      feed_time=NewFeedTime,
                                      feed_over_tick=Now+Time},
    db:write(?DB_PET_FEED,NewFeedInfo,write),
    [PetInfo] = db:read(?DB_PET,PetID),
    db:write(?DB_PET,PetInfo#p_pet{state=?PET_FEED_STATE},write),
    {ok,NewFeedInfo,ChangeList, DelList,{NewRoleAttr,DeductBind,DeductUnBind}}.

get_extra_feed_gold(FeedTime) ->
    case FeedTime < 6 of
        true ->
            0;
        false ->
            case FeedTime < 11 of
                true ->
                    (FeedTime - 5) * 2;
                false ->
                    case FeedTime < 21 of
                        true ->
                            (FeedTime - 10) * 3 + 10;
                        false ->
                            (FeedTime - 20) * 5 + 40
                    end
            end
    end.
                            
                            
do_pet_feed_begin_error(Unique, RoleID, Line, Reason) ->
%%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_feed_begin_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_BEGIN, Record).

-define(FEED_COMMIT_NORMAL,1).
-define(FEED_COMMIT_USE_GOLD,2).
do_pet_feed_commit(Unique, DataIn, RoleID, PID, Line, _State) ->
    #m_pet_feed_commit_tos{pet_id=PetID, type=CommitType} = DataIn,
    %%?ERROR_MSG("feed commit  ~w",[DataIn]),
    case CommitType of
        ?FEED_COMMIT_NORMAL ->
            pet_feed_commit_normal(PetID,RoleID,Unique,Line);
        ?FEED_COMMIT_USE_GOLD ->
            pet_feed_commit_use_gold(PetID,RoleID,PID,Unique,Line);
        _ ->
            do_pet_feed_commit_error(Unique, RoleID, Line, ?_LANG_SYSTEM_ERROR)
    end.



do_pet_feed_commit_error(Unique, RoleID, Line, Reason) ->
%%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_feed_commit_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_COMMIT, Record).


do_pet_feed_give_up(Unique, DataIn, RoleID, Line, _State) ->
    #m_pet_feed_give_up_tos{pet_id=PetID} = DataIn,
    Fun = fun() ->
                  case db:read(?DB_PET_FEED,RoleID) of
                      [] ->
                          db:abort(?_LANG_PET_NOT_EXIST);
                      [FeedInfo] ->
                          case FeedInfo#p_pet_feed.pet_id =:= PetID andalso FeedInfo#p_pet_feed.state =:= ?PET_FEED_STATE of
                              false ->
                                  db:abort(?_LANG_SYSTEM_ERROR);
                              true ->
                                  pet_feed_give_up_2(FeedInfo,RoleID,PetID)
                          end
                  end
          end,
    case db:transaction(Fun) of
        {aborted, Reason} ->
            do_pet_feed_give_up_error(Unique, RoleID, Line, Reason);
        {atomic, {ok,NewFeedInfo}} ->
            write_pet_feed_log(0, "", RoleID, ?FEED_LOG_GIVE_UP, 0,0, NewFeedInfo#p_pet_feed.star_level-1),
            Record = #m_pet_feed_give_up_toc{succ=true, info=NewFeedInfo},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_GIVE_UP, Record)
    end.



pet_feed_give_up_2(FeedInfo,_RoleID, PetID) ->
    [PetInfo] = db:read(?DB_PET,PetID),
    db:write(?DB_PET,PetInfo#p_pet{state=?PET_NORMAL_STATE},write),
    NewFeedInfo = FeedInfo#p_pet_feed{state=?PET_NORMAL_STATE},
    db:write(?DB_PET_FEED,NewFeedInfo,write),
    {ok,NewFeedInfo}.


do_pet_feed_give_up_error(Unique, RoleID, Line, Reason) ->
%%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_feed_give_up_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_GIVE_UP, Record).


do_pet_feed_star_up(Unique, _DataIn, RoleID, Line, _State) ->
    Fun = fun() ->
                  case db:read(?DB_PET_FEED,RoleID) of
                      [] ->
                          db:abort(?_LANG_PET_NOT_EXIST);
                      [FeedInfo] ->
                          case FeedInfo#p_pet_feed.state =:= ?PET_FEED_STATE of
                              true ->
                                  db:abort(?_LANG_SYSTEM_ERROR);
                              false ->
                                  case FeedInfo#p_pet_feed.star_up_flag of
                                      true ->
                                          pet_feed_star_up_2(FeedInfo,RoleID);
                                      false ->
                                          db:abort(?_LANG_SYSTEM_ERROR)
                                  end
                          end
                  end
          end,
    case db:transaction(Fun) of
        {aborted, Reason} ->
            do_pet_feed_star_up_error(Unique, RoleID, Line, Reason);
        {atomic, {ok,Ret, NewFeedInfo, NewRoleAttr,DeductBind,DeductUnBind}} ->
          
            Record = #m_pet_feed_star_up_toc{succ=true, succ2=Ret, info=NewFeedInfo},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_STAR_UP, Record),
            
            case NewRoleAttr of 
                undefined ->
                      write_pet_feed_log(0, "", RoleID, ?FEED_LOG_STAR_UP, DeductBind,DeductUnBind, NewFeedInfo#p_pet_feed.star_level-1),
                    ignore;
                _ ->
                    write_pet_feed_log(0, "", RoleID, ?FEED_LOG_STAR_UP, DeductBind,DeductUnBind, NewFeedInfo#p_pet_feed.star_level-1),
                    ChangeList = [
                                  #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=NewRoleAttr#p_role_attr.gold},
                                  #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.gold_bind}],
                    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList)
            end
    end.


-define(PET_FEED_STAR_UP_USE_GOLD,5).
pet_feed_star_up_2(FeedInfo,RoleID) ->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    case FeedInfo#p_pet_feed.free_star_up_flag of
        false ->
            #p_role_attr{gold_bind = BindGold, gold = Gold} = RoleAttr,
            case BindGold + Gold >= ?PET_FEED_STAR_UP_USE_GOLD of
                false ->
                    NewRoleAttr = RoleAttr,
                    {DeductBind,DeductUnBind} = {0,0},
                    db:abort(?_LANG_NOT_ENOUGH_GOLD);
                true ->
                     {NewRoleAttr,DeductBind,DeductUnBind} = t_deduct_gold(RoleAttr,?PET_FEED_STAR_UP_USE_GOLD,?CONSUME_TYPE_GOLD_PET_FEED_STAR_UP),
                    mod_map_role:set_role_attr(RoleID, NewRoleAttr)
            end;
        true ->
            {DeductBind,DeductUnBind} = {0,0},
            NewRoleAttr = undefined
    end,
    StarLevel = FeedInfo#p_pet_feed.star_level,
    case StarLevel >= 9 of
        true ->
            db:abort(?_LANG_SYSTEM_ERROR);
        false ->
            ignore
    end,
    FailTime = FeedInfo#p_pet_feed.star_up_fail_time,
    Rate = get_star_up_rate(FailTime, StarLevel),
    %%?ERROR_MSG("22333333333333333  ~w",[Rate]),
    case random:uniform(10000) =< Rate of
        false ->
            {_,Time2,FeedType2} = get_feed_exp_time_by_star_level(StarLevel,RoleAttr#p_role_attr.level),
            NewFeedInfo = FeedInfo#p_pet_feed{star_up_fail_time=FailTime+1,
                                              free_star_up_flag=false,
                                              feed_type=FeedType2,
                                              feed_tick=Time2*60},
            db:write(?DB_PET_FEED,NewFeedInfo,write),
            {ok,false,NewFeedInfo,NewRoleAttr,DeductBind,DeductUnBind};
        true ->
            {Exp,Time,FeedType} = get_feed_exp_time_by_star_level(StarLevel+1,RoleAttr#p_role_attr.level),
            NewFeedInfo = FeedInfo#p_pet_feed{
                                              last_feed_exp=Exp,                  
                                              feed_type=FeedType,
                                              feed_tick=Time*60,
                                              free_star_up_flag=false,
                                              star_up_fail_time=0,
                                              star_up_flag=false,
                                              star_level=StarLevel+1},
            db:write(?DB_PET_FEED,NewFeedInfo,write),
             case StarLevel =:= 3 orelse StarLevel > 6 of
                true ->
                    {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
                    FactionName = common_misc:get_faction_color_name(RoleBase#p_role_base.faction_id),
                    Content = io_lib:format(?_LANG_PET_FEED_STAR_UP_BROADCAST,[FactionName,RoleAttr#p_role_attr.role_name,StarLevel+1]),               
                    catch common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_WORLD,common_tool:to_list(Content));
                false ->
                      ignore
             end,
            {ok,true,NewFeedInfo,NewRoleAttr, DeductBind,DeductUnBind}
    end.


get_star_up_rate(FailTime, StarLevel) ->
    [{BaseRate, XiShu}] = common_config_dyn:find(etc,{pet_feed_star_up,StarLevel}),
    BaseRate + XiShu * FailTime.



do_pet_feed_star_up_error(Unique, RoleID, Line, Reason) ->
%%%%?ERROR_MSG("###########   error  ~w",[Reason]),
    Record = #m_pet_feed_star_up_toc{succ=false, reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_STAR_UP, Record).



reset_role_pet_feed_info(MapRoleIDList) when is_list(MapRoleIDList)->
    Fun = fun() ->
                  lists:foreach(fun(RoleID) -> reset_role_pet_feed_info(RoleID) end,MapRoleIDList)
          end,
    erlang:spawn(Fun);
reset_role_pet_feed_info(RoleID) ->
    Fun = fun()->
                  [FeedInfo] = db:read(?DB_PET_FEED,RoleID),
                  #p_pet_feed{
                              last_feed_day=LastFeedDay,
                              last_clear_star_week=LastClearStarWeek
                             }=FeedInfo,
                  Date=erlang:date(),
                  Day = calendar:date_to_gregorian_days(Date),
                  WeekDay=calendar:day_of_the_week(Date),
                  Day2=Day-WeekDay-1,
                  case LastFeedDay =:= undefined orelse LastFeedDay < Day of
                      true ->
                          FeedInfo2 = FeedInfo#p_pet_feed{last_feed_day=Day,feed_time=0};
                      false ->
                          FeedInfo2 = FeedInfo
                  end,
                  
                  case LastClearStarWeek =:= undefined orelse LastClearStarWeek < Day2 of
                      true ->
                          OldLevel = FeedInfo2#p_pet_feed.star_level,
                          OldExp = FeedInfo2#p_pet_feed.last_feed_exp,
                          case FeedInfo2#p_pet_feed.state =:= ?PET_FEED_STATE of
                              false ->
                                  case OldLevel of
                                      2 -> NewExp = trunc(OldExp/2),NewTick=18+random:uniform(7);
                                      3 -> NewExp = trunc(OldExp/3),NewTick=20+random:uniform(7);
                                      4 -> NewExp = trunc(OldExp/6),NewTick=22+random:uniform(7);
                                      5 -> NewExp = trunc(OldExp/8),NewTick=24+random:uniform(7);
                                      6 -> NewExp = trunc(OldExp/10),NewTick=26+random:uniform(7);
                                      7 -> NewExp = trunc(OldExp/12),NewTick=28+random:uniform(7);
                                      8 -> NewExp = trunc(OldExp/19),NewTick=30+random:uniform(7);
                                      9 -> NewExp = trunc(OldExp/25),NewTick=31+random:uniform(7);
                                      _ -> NewExp = OldExp,NewTick=18+random:uniform(7)
                                  end;
                              true ->
                                  NewExp=OldExp,
                                  NewTick=FeedInfo2#p_pet_feed.feed_tick
                          end,    
                          FeedInfo3 = FeedInfo2#p_pet_feed{star_level=1,
                                                           feed_tick=NewTick,
                                                           last_feed_exp=NewExp,
                                                           free_star_up_flag=false,
                                                           last_clear_star_week=Day2,
                                                           star_up_flag=false,
                                                           star_up_fail_time=0};
                      false ->
                          FeedInfo3 = FeedInfo2
                  end,
                  case FeedInfo3 =:= FeedInfo of
                      true ->
                          ignore;
                      false ->
                          db:write(?DB_PET_FEED,FeedInfo3,write),
                          FeedInfo4=change_over_tick_to_left_tick_for_client(FeedInfo3),
                          Record = #m_pet_feed_info_toc{succ=true,info=FeedInfo4},
                          common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_FEED_INFO, Record)
                  end
          end,
    db:transaction(Fun).


check_feed_over() ->
    Now=common_tool:now(),
    lists:foreach(
      fun(RoleID) ->
              check_feed_over(RoleID,Now)
      end, get(?ROLE_PET_FEED_LIST)).
check_feed_over(RoleID,Now) ->
    case get({?ROLE_PET_FEED_OVER_TICK,RoleID}) of
        undefined ->
            put(?ROLE_PET_FEED_LIST,lists:delete(RoleID, get(?ROLE_PET_FEED_LIST)));
        {PetID,Tick} ->
            case Now >= Tick of
                true ->
                    Record = #m_pet_feed_over_toc{pet_id=PetID},
                    common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_FEED_OVER, Record),
                    erase({?ROLE_PET_FEED_OVER_TICK,RoleID}),
                    put(?ROLE_PET_FEED_LIST,lists:delete(RoleID, get(?ROLE_PET_FEED_LIST)));
                false ->
                    ignore
            end
    end.

change_feed_exp(RoleID,Level) ->
    Fun = fun() ->
                  [FeedInfo] = db:read(?DB_PET_FEED,RoleID),
                  case FeedInfo#p_pet_feed.state =:= ?PET_FEED_STATE of
                      true ->
                          ignore;
                      false ->
                          {Exp,_,_} = get_feed_exp_time_by_star_level(FeedInfo#p_pet_feed.star_level,Level),
                          db:write(?DB_PET_FEED,FeedInfo#p_pet_feed{last_feed_exp=Exp},write)
                  end
          end,
    spawn(fun() -> db:transaction(Fun) end).


%%
%% Local Functions
%%
get_feed_exp_time_by_star_level(StarLevel, RoleLevel) ->
    BaseExp = trunc(math:pow(RoleLevel, 1.7))*10+2000,
    {BeiShu,Time} = case StarLevel of
                        1 -> {1, 20};
                        2 -> {2, 22};
                        3 -> {3, 24};
                        4 -> {6, 26};
                        5 -> {8, 28};
                        6 -> {10, 30};
                        7 -> {12, 32};
                        8 -> {19, 34};
                        9 -> {25, 35};
                        _ -> {1, 20}
                    end,
    FeedType = random:uniform(7),
    {BeiShu*BaseExp, Time + random:uniform(7) - 4, FeedType}.


pet_feed_commit_normal(PetID,RoleID,Unique,Line) ->
    Fun = fun() ->
                  {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                  pet_feed_commit(PetID,RoleID,true,RoleAttr) 
          end,
    case db:transaction(Fun) of
        {aborted, Reason} ->
            do_pet_feed_commit_error(Unique, RoleID, Line, Reason);
        {atomic, {ok,NewFeedInfo,NewPetInfo}} ->
            put(?ROLE_PET_FEED_LIST,lists:delete(RoleID, get(?ROLE_PET_FEED_LIST))),
            write_pet_feed_log(PetID, NewPetInfo#p_pet.pet_name, RoleID, ?FEED_LOG_COMMIT_NORMAL, 0, 0, NewFeedInfo#p_pet_feed.star_level),
            Record = #m_pet_feed_commit_toc{succ=true,info=NewFeedInfo,pet_info=NewPetInfo},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_COMMIT, Record)
    end.


-define(PET_FEED_COMMIT_USE_GOLD,5).
pet_feed_commit_use_gold(PetID,RoleID,PID,Unique,Line) ->
    Fun = fun() -> 
                  {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                  case mod_vip:t_check_can_pet_training_free(RoleID) of
                      {ok, VipInfo} ->
                          NewRoleAttr = undefined,
                          DeductBind = 0,
                          DeductUnBind = 0;
                      _ ->
                          #p_role_attr{gold_bind = BindGold, gold = Gold} = RoleAttr,
                          case BindGold + Gold >= ?PET_FEED_COMMIT_USE_GOLD of
                              false ->
                                  NewRoleAttr = RoleAttr,
                                  {DeductBind,DeductUnBind} = {0,0},
                                  db:abort(?_LANG_NOT_ENOUGH_GOLD);
                              true ->
                                  {NewRoleAttr,DeductBind,DeductUnBind} = t_deduct_gold(RoleAttr,?PET_FEED_COMMIT_USE_GOLD,?CONSUME_TYPE_GOLD_PET_FEED_SPEED_UP),
                                  mod_map_role:set_role_attr(RoleID, NewRoleAttr)
                          end,
                          VipInfo = undefined
                  end,
                  {ok,NewFeedInfo,NewPetInfo} = pet_feed_commit(PetID,RoleID,false,RoleAttr),
                  {ok,NewFeedInfo,NewRoleAttr,NewPetInfo,DeductBind,DeductUnBind,VipInfo}
          end,
    case db:transaction(Fun) of
        {aborted, Reason} ->
            do_pet_feed_commit_error(Unique, RoleID, Line, Reason);
        {atomic, {ok,NewFeedInfo,NewRoleAttr2,NewPetInfo,DeductBind2,DeductUnBind2, VipInfo}} ->
            put(?ROLE_PET_FEED_LIST,lists:delete(RoleID, get(?ROLE_PET_FEED_LIST))),
            Record = #m_pet_feed_commit_toc{succ=true,info=NewFeedInfo,pet_info=NewPetInfo},
            common_misc:unicast(Line, RoleID, Unique, ?PET, ?PET_FEED_COMMIT, Record),

            case VipInfo of
                undefined ->
                    write_pet_feed_log(PetID, NewPetInfo#p_pet.pet_name, RoleID, ?FEED_LOG_COMMIT_SPEED, DeductBind2,DeductUnBind2, NewFeedInfo#p_pet_feed.star_level),
                    ChangeList = [
                                  #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=NewRoleAttr2#p_role_attr.gold},
                                  #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=NewRoleAttr2#p_role_attr.gold_bind}],
                    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList);
                _ ->
                    mod_vip:notify_vip_info_change(RoleID, PID, VipInfo)
            end
    end.


pet_feed_commit(PetID,RoleID,CheckTimeFlag,RoleAttr) ->
    %%?ERROR_MSG("1111111111111111",[]),
    case db:read(?DB_PET_FEED,RoleID) of
        [] ->
            db:abort(?_LANG_PET_NOT_EXIST);
        [FeedInfo] ->
            case FeedInfo#p_pet_feed.state =:= ?PET_FEED_STATE 
                                          andalso PetID =:= FeedInfo#p_pet_feed.pet_id of
                false ->
                    db:abort(?_LANG_PET_NOT_IN_FEEDING);
                true ->
                    Now = common_tool:now(),
                    case CheckTimeFlag =:= false 
                             orelse FeedInfo#p_pet_feed.feed_over_tick =< Now of
                        false ->
                            db:abort(?_LANG_PET_FEEDING_NOT_OVER);
                        true ->
                            Exp = FeedInfo#p_pet_feed.last_feed_exp,
                            {ok,NewPetInfo} = mod_map_pet:t_add_pet_exp(PetID,Exp,false),
                            {FeedExp,Time,FeedType} = get_feed_exp_time_by_star_level(FeedInfo#p_pet_feed.star_level, RoleAttr#p_role_attr.level),
                            case FeedInfo#p_pet_feed.star_level < 9 of
                                true ->
                                    StarUpFlag = true;
                                false ->
                                    StarUpFlag = false
                            end,
                            NewFeedInfo = FeedInfo#p_pet_feed{state=?PET_NORMAL_STATE,
                                                              free_star_up_flag=StarUpFlag,
                                                              last_feed_exp=FeedExp,
                                                              feed_tick=Time*60,
                                                              feed_type=FeedType,
                                                              star_up_flag=StarUpFlag,
                                                              pet_id=undefined},
                            db:write(?DB_PET,NewPetInfo#p_pet{state=1},write),
                            db:write(?DB_PET_FEED,NewFeedInfo,write),
                            {ok,NewFeedInfo,NewPetInfo}
                    end
            end
    end.



t_deduct_gold(RoleAttr,NeedGold,DeduceLog) ->
    #p_role_attr{role_id=RoleID, gold_bind = BindGold, gold = Gold} = RoleAttr,
    
    case BindGold >= NeedGold of
        true ->
            common_consume_logger:use_gold({RoleID, NeedGold, 0, DeduceLog,
                                            ""}),
            
            {RoleAttr#p_role_attr{gold_bind=BindGold-NeedGold},NeedGold,0};
        false ->
            common_consume_logger:use_gold({RoleID, BindGold, NeedGold-BindGold, DeduceLog,
                                            ""}),
            
            {RoleAttr#p_role_attr{gold_bind=0, gold=Gold+BindGold-NeedGold},BindGold, NeedGold-BindGold}
    end.


change_over_tick_to_left_tick_for_client(FeedInfo) ->
    case FeedInfo#p_pet_feed.state =:= ?PET_FEED_STATE of
        false ->
            FeedInfo;
        true ->
            Now = common_tool:now(),
            OverTick = FeedInfo#p_pet_feed.feed_over_tick ,
            case Now >= OverTick of
                true ->
                    FeedInfo#p_pet_feed{feed_over_tick=0};
                false ->
                    FeedInfo#p_pet_feed{feed_over_tick=OverTick - Now}
            end
    end.


write_pet_feed_log(PetId, PetName, RoleId, OpType, BindGold, UnBindGold, Star) ->
    catch global:send(mgeew_pet_log_server,{log_pet_training,{PetId, PetName, RoleId, OpType, BindGold, UnBindGold, Star}}).


