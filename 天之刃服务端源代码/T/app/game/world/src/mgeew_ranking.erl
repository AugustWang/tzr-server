%%% -------------------------------------------------------------------
%%% Author  : liuwei
%%% Description :排行榜
%%%
%%% Created : 2010-10-9
%%% -------------------------------------------------------------------
-module(mgeew_ranking).

-behaviour(gen_server).
-include("mgeew.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([
         start/0,
         start_link/0,
         cmp/1,
         reload_config/0,
         send_ranking_cofig/1,
         send_activity_prize/4,
         send_ranking_activity/2,
         create_equip/8
        ]).


-define(RERESH_FIXED_TIME,1).   %%定时刷新
-define(RERESH_REAL_TIME,2).    %%实时刷新


start() ->
    {ok, _} = supervisor:start_child(mgeew_sup, {?MODULE,
                                                 {?MODULE, start_link, []},
                                                 transient, brutal_kill, worker, 
                                                 [?MODULE]}).

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).


reload_config() ->
    case global:whereis_name(?MODULE) of
        undefined ->
            mgeew_ranking:start();
        Pid ->
            Pid ! reload_config
    end.


cmp([]) ->
    true;
cmp([{Element1,Element2}|List]) ->
    case Element1 < Element2 of
        true ->
            true;
        false ->
            case Element1 > Element2 of
                true ->
                    false;
                false ->
                    cmp(List)
            end
    end.


send_ranking_cofig(RoleID) ->
    global:send(?MODULE,{send_ranking_to_role,RoleID}).


send_activity_prize(_RoleID,[],_Title,_Text) ->
    ok;
send_activity_prize(RoleID,[#r_rank_prize_goods{type_id=TypeID,num=Number,bind=Bind,last_time=LastTime}|List],Title,Text) ->
    case LastTime of
        0 ->
            StartTime = 0,
            EndTime = 0;
        _ ->
            StartTime = common_tool:now(),
            EndTime = StartTime + LastTime
    end,
    case common_config_dyn:find(item,TypeID) of
        [] ->
            case common_config_dyn:find(equip,TypeID) of
                [] ->
                     create_stone(RoleID,Number,TypeID,Bind,StartTime,EndTime,Title,Text),
                     send_activity_prize(RoleID,List,Title,Text);
                _ ->
                     create_equip(RoleID,Number,TypeID,Bind,StartTime,EndTime,Title,Text),
                     send_activity_prize(RoleID,List,Title,Text)
            end;
        _ ->
            create_item(RoleID,Number,TypeID,Bind,StartTime,EndTime,Title,Text), 
            send_activity_prize(RoleID,List,Title,Text)
    end.
   
     
create_stone(RoleID,Number,TypeID,Bind,StartTime,EndTime,Title,Text) ->
    Info = #r_stone_create_info{role_id=RoleID,bag_id=0,num=Number,
                                typeid=TypeID,bind=Bind,start_time=StartTime,end_time=EndTime},
    case common_bag2:creat_stone(Info) of
        {ok,GoodsList} ->
            NewGoodsList = [ G#p_goods{id=1,bagposition=1,bagid=9999}||G<-GoodsList ],
            common_letter:sys2single(RoleID,Title,Text,NewGoodsList);
        {error,Reason}->
            ?ERROR_MSG("create_goods error,Reason=~w",[Reason])
    end.
create_equip(RoleID,Number,TypeID,Bind,StartTime,EndTime,Title,Text) ->
    Info = #r_equip_create_info{role_id=RoleID,bag_id=0,num=Number,color=1,
                                typeid=TypeID,bind=Bind,start_time=StartTime,end_time=EndTime},
    case common_bag2:creat_equip_without_expand(Info) of
        {ok,GoodsList} ->
            NewGoodsList = [ G#p_goods{id=1,bagposition=1,bagid=9999}||G<-GoodsList ],
            common_letter:sys2single(RoleID,Title,Text,NewGoodsList);
        {error,Reason}->
            ?ERROR_MSG("create_goods error,Reason=~w",[Reason])
    end.
create_item(RoleID,Number,TypeID,Bind,StartTime,EndTime,Title,Text) ->
     Info = #r_item_create_info{role_id=RoleID, bag_id=0,  num=Number, typeid=TypeID, bind=Bind,
                               start_time=StartTime, end_time=EndTime},
    case common_bag2:create_item(Info) of
        {ok,GoodsList} ->
            NewGoodsList = [ G#p_goods{id=1,bagposition=1,bagid=9999}||G<-GoodsList ],
            common_letter:sys2single(RoleID,Title,Text,NewGoodsList);
        {error,Reason}->
            ?ERROR_MSG("create_goods error,Reason=~w",[Reason])
    end.

%%======================================================
init([]) ->
    load_ranking_config(),
    init_all_module(),
    {_,{_H,M,S}} = erlang:localtime(),
    %%每十分钟检测一次，并且根据当前时间计算下次检测时间
    erlang:send_after((9 - (M rem 10))*60*1000 + (60-S)*1000, self(), loop),
    {ok, none}.


handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(exit, State) ->
    {stop, bad, State};

handle_info({rank,ModuleName}, State) ->
    ModuleName:rank(),
    {noreply, State};

handle_info({debug,Fun,Args}, State) ->
    Ret = apply(Fun,Args),
    ?ERROR_MSG("ret = ~w",[Ret]),
    {noreply, State};


handle_info(Info, State) ->
    ?DO_HANDLE_INFO(Info, State),
    {noreply, State}.


do_handle_info(loop) ->
    RankIDList = get(rank_id_list),
    {_,{H,M,S}} = erlang:localtime(),
    erlang:send_after((9 - (M rem 10))*60*1000 + (60-S)*1000, self(), loop),
    ?DEBUG("loop time is ~w",[date()]),
    lists:foreach(
      fun(RankID) ->
			  timer:sleep(10),
              {RankInfo,ModuleName} = get({rank_info,RankID}),
              case RankInfo#p_ranking.refresh_type of
                  ?RERESH_REAL_TIME ->
                      nil;
                  ?RERESH_FIXED_TIME ->
                      case (H*60+M) rem RankInfo#p_ranking.refresh_interval of
                          0 ->
                              case ModuleName of
                                  {ranking_role_level,1} ->
                                      ?TRY_CATCH( ranking_role_level:rank(),Err1 );
                                  {ranking_role_level,_} ->
                                      ignore;
                                  _ ->
                                      ?TRY_CATCH( ModuleName:rank(),Err2 )
                              end;
                          _ ->
                              nil
                      end
              end
      end,RankIDList);

%%GM专用，更新所有排行榜
do_handle_info(update_all_rank) ->
    RankIDList = get(rank_id_list),
    lists:foreach(
      fun(RankID) ->
              {_,ModuleName} = get({rank_info,RankID}),
              case ModuleName of
                  {ranking_role_level,1} ->
                      ?TRY_CATCH( ranking_role_level:rank(),Err1 );
                  {ranking_role_level,_} ->
                      ignore;
                  _ ->
                      ?TRY_CATCH( ModuleName:rank(),Err2 )
              end
      end,RankIDList);

do_handle_info({rank_activity,ModuleName}) ->
     ModuleName:do_rank_activity();

do_handle_info({ranking_element_update,ModuleName,Info}) ->
    ?DEBUG("ranking_element_update ~w",[Info]),
    ModuleName:update(Info);


do_handle_info({ranking_handle,ModuleName,Info}) ->
    ?DEBUG("ranking_handle ~w ~w",[ModuleName,Info]),
    ModuleName:handle(Info);


do_handle_info({send_ranking_to_role,_RoleID}) ->
%%     RankInfoList = get(rank_config_info_list),
%%     Record = #m_ranking_config_toc{rankings = RankInfoList},
%%     common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?RANKING, ?RANKING_CONFIG, Record);
    ignore;
    
do_handle_info({_Unique, ?RANKING, _Method, _DataIn, _RoleID, _Pid, _Line}=Info) ->
    do_handle_method(Info);

do_handle_info(reload_config) ->
    erase(),
    load_ranking_config();

do_handle_info({init,RankID})->
    init_all_module2(RankID).

terminate(Reason, State) ->
    ?INFO_MSG("terminate : ~w , reason: ~w", [Reason, State]),
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

load_ranking_config() ->
    %%读取每个排行榜的详细信息
    RankInfoFile = common_config:get_world_config_file_path(rank_info),
    {ok,RankInfoList} = file:consult(RankInfoFile),
    {RankIDList,RankConfigInfoList} = lists:foldr(
                      fun({RankID,RankInfo,ModuleName},{Acc,Acc2}) ->
                              put({rank_info,RankID},{RankInfo,ModuleName}),
                              {[RankID|Acc],[RankInfo|Acc2]}
                      end,{[],[]},RankInfoList),
    ?DEBUG("~w",[RankInfoList]),
    put(rank_config_info_list,RankConfigInfoList),
    put(rank_id_list,RankIDList).


init_all_module() ->
    RankIDList = get(rank_id_list),
    lists:foreach(
      fun(RankID) ->
               init_all_module2(RankID)
      end,RankIDList).

init_all_module2(RankID) ->
    {RankInfo,ModuleName} = get({rank_info,RankID}),
    try
        case ModuleName of
            {ranking_role_level,1} ->
                ranking_role_level:init(RankInfo);
            {ranking_role_level,_} ->
                ignore;
            _ ->
                ModuleName:init(RankInfo)
        end
    catch _:Reason -> 
              ?ERROR_LOG(" Reason: ~w, strace:~w", [Reason, erlang:get_stacktrace()])
    end.

send_ranking_activity(ActivityKey,List)->
    common_activity:send_special_activity({stat_ranking,{ActivityKey,List}}).


do_handle_method({_, ?RANKING, ?RANKING_GET_RANK, _, _RoleID, _Pid, _Line}=Info) ->
    do_ranking_get_rank(Info);
do_handle_method({_, ?RANKING, ?RANKING_EQUIP_JOIN_RANK, _, _RoleID, _Pid, _Line}=Info) ->
    do_ranking_equip_join_rank(Info);
do_handle_method({_, ?RANKING, ?RANKING_ROLE_ALL_RANK, _, _RoleID, _Pid, _Line}=Info) ->
    do_ranking_role_all_rank(Info);
do_handle_method({_, ?RANKING, ?RANKING_PET_JOIN_RANK, _, _RoleID, _Pid, _Line}=Info) ->
    do_ranking_pet_join_rank(Info);
do_handle_method(Info) ->
    ?ERROR_MSG("~w, unrecognize msg: ~w", [?MODULE,Info]).


do_ranking_get_rank({Unique, Module, Method, DataIn, RoleID, PID, _Line})->
    #m_ranking_get_rank_tos{rank_id=RankID} = DataIn,
    case get({rank_info,RankID}) of
        {_RankInfo,ModuleName} ->
            case ModuleName of
                {ranking_role_level,Category} ->
                    ranking_role_level:send_ranking_info(Unique, Module, Method, RoleID, PID, RankID,Category);
                _ ->
                    ModuleName:send_ranking_info(Unique, Module, Method, RoleID, PID, RankID)
            end;
        undefined ->
            self() ! {send_ranking_to_role,RoleID}
    end.

do_ranking_equip_join_rank({Unique, Module, Method, DataIn, RoleID, PID, _Line})->
    %% goods_id已经地图路由过来的时候改成了goodsinfo
    #m_ranking_equip_join_rank_tos{rank_id = RankID,goods_id = GoodsInfo} = DataIn,
    
    case get({rank_info,RankID}) of
        {_RankInfo,ModuleName} ->
            case ModuleName:update({GoodsInfo,RoleID}) of
                ok ->
                    Record = #m_ranking_equip_join_rank_toc{succ = true,rank_id = RankID};
                {fail,Reason} ->
                    Record = #m_ranking_equip_join_rank_toc{reason = Reason, rank_id = RankID}
            end;
        undefined ->
            self() ! {send_ranking_to_role,RoleID},
            Record = #m_ranking_equip_join_rank_toc{reason = ?_LANG_RANKING_NOT_OPEN, rank_id = RankID}
    end,
    ?UNICAST_TOC(Record).

do_ranking_role_all_rank({Unique, ?RANKING, _Method, DataIn, RoleID, _Pid, Line})->
    ranking_role_all_rank:send_role_all_ranking_info(RoleID,Line,DataIn,Unique).

do_ranking_pet_join_rank({Unique, Module, Method, DataIn, RoleID, PID, _Line})->
    #m_ranking_pet_join_rank_tos{rank_id = RankID,pet_id = PetID} = DataIn,
    case get({rank_info,RankID}) of
        {_RankInfo,ModuleName} ->
            case ModuleName:update({PetID,RoleID}) of
                ok ->
                    Record = #m_ranking_pet_join_rank_toc{succ = true,rank_id = RankID};
                {fail,Reason} ->
                    Record = #m_ranking_pet_join_rank_toc{reason = Reason, rank_id = RankID}
            end;
        undefined ->
            self() ! {send_ranking_to_role,RoleID},
            
            Record = #m_ranking_pet_join_rank_toc{reason = ?_LANG_RANKING_NOT_OPEN, rank_id = RankID}
    end,
    ?UNICAST_TOC(Record).

