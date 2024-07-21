%% Author: liuwei
%% Created: 2011-4-28
%%门派采集TD玩法
%% Description: TODO: Add description to mod_family_collect
-module(mod_family_collect).

%%
%% Include files
%%
-include("mgeem.hrl").
%%
%% Exported Functions
%%
-export([
         handle/2,
         init/2,
         loop/0,
         hook_collect/1,
         hook_monster_dead/1,
         check_is_family_collect/1,
         exchange_byscore/2,
         get_prize_info/1
         ]).

-define(FAMILY_COLLECTING_FLAG,family_collecting_flag).
-define(NOW_FAMILY_COLLECT_SCORE,now_family_collect_score).
-define(OLD_FAMILY_COLLECT_SCORE,old_family_collect_score).
-define(ROLE_FAMILY_COLLECT_INFO,role_family_collect_info).
-define(FAMILY_COLLECT_ROLE_IDLIST,family_collect_role_idlist).
-define(FAMILY_COLLECT_MONSTER_KILLED_NUM,family_collect_monster_killed_num).
-define(FAMILY_COLLECT_NUM,family_collect_num).
-define(LAST_PERSISTENT_FAMILY_COLLECT_PRIZE_TIME,last_persistent_family_collect_prize_time).
-define(FAMILY_COLLECT_POINT_MONSTER_BORN_OVER,family_collect_point_monster_born_over).
-define(HASH_FAMILY_COLLECT_ID,hash_family_collect_id).

-record(r_family_collect,{family_collect_id,collect_point_info,collect_monster_list}).
%-record(r_collect_monster_info,{id,type_id,tx,ty}).

%%
%% API Functions
%%
init(10300,_MapName) ->
    put(?FAMILY_COLLECT_ROLE_IDLIST,[]),
    case common_config_dyn:find(etc,is_open_family_collect) of
        [true] ->
            {H,M,S} = erlang:time(),
            [{SH, SM, SS}] = common_config_dyn:find(etc, family_collect_start_time),
            LeftTick = SH * 3600 + SM * 60 + SS - H * 3600 - M * 60 - S ,
            case LeftTick >= 0 of
                true ->
                    erlang:send_after(LeftTick*1000, self(), {mod_family_collect,family_collect_begin});
                false ->
                    case LeftTick + 20 * 60 > 0 of
                        true ->
                            self() ! {mod_family_collect,family_collect_begin};
                        false ->
                            erlang:send_after((86400 + LeftTick)*1000, self(), {mod_family_collect,family_collect_begin})
                    end
            end;
        _ ->
            ignore
    end,
    ok;
init(11000,_MapName) ->
    case common_config_dyn:find(etc,is_open_family_collect) of
        [true] ->
            {H,M,S} = erlang:time(),
            [{SH, SM, SS}] = common_config_dyn:find(etc, family_collect_broadcast_time),
            LeftTick = SH * 3600 + SM * 60 + SS - H * 3600 - M * 60 - S ,
            case LeftTick >= 0 of
                true ->
                    self() ! {mod_family_collect,family_collect_begin_notice_broadcast};
                false ->
                    erlang:send_after((86400 + LeftTick)*1000, self(), {mod_family_collect,family_collect_begin_notice_broadcast})
            end;
        _ ->
            ignore
    end;
init(_,_) ->
    ignore.

handle({Unique, ?FAMILY_COLLECT, ?FAMILY_COLLECT_PRIZE_INFO, DataRecord, RoleID, _, Line},_State) ->
    do_send_role_prize_info(Unique,DataRecord, RoleID, Line);
handle({Unique, ?FAMILY_COLLECT, ?FAMILY_COLLECT_REFRESH_PRIZE, DataRecord, RoleID, _, Line},_State) ->
    do_refresh_prize(Unique,DataRecord, RoleID, Line);
handle({Unique, ?FAMILY_COLLECT, ?FAMILY_COLLECT_GET_PRIZE, DataRecord, RoleID, _, Line},_State) ->
    do_get_prize(Unique,DataRecord, RoleID, Line);
handle({Unique, ?FAMILY_COLLECT, ?FAMILY_COLLECT_GET_ROLE_INFO, DataIn, RoleID,_, Line},_State) ->
    do_get_score(Unique,?FAMILY_COLLECT,?FAMILY_COLLECT_GET_ROLE_INFO,DataIn, RoleID, Line);
handle(family_collect_begin_notice_broadcast,_State) ->
    do_family_collect_begin_notice_broadcast(); 
handle(family_collect_begin,_State) ->
    do_family_collect_begin();    
handle(family_collect_end,_State) ->
    do_family_collect_end();   
handle({gm_set_family_collect_score, RoleID, Score}, _MapState) ->
    do_gm_set_family_collect_score(RoleID, Score);
handle(Msg,_State) ->
    ?ERROR_MSG("uexcept msg = ~w",[Msg]).

loop() ->
    [IsOpenFamilyCollect] = common_config_dyn:find(etc,is_open_family_collect),
    case mgeem_map:get_mapid() =:= 10300 andalso IsOpenFamilyCollect =:= true of
        true ->
            Now = common_tool:now(),
            case get(?LAST_PERSISTENT_FAMILY_COLLECT_PRIZE_TIME) of
                undefined ->
                    put(?LAST_PERSISTENT_FAMILY_COLLECT_PRIZE_TIME,Now);
                LastTick ->
                    %%每十分钟持久化一次门派采集TD的玩家奖励信息
                    case Now - LastTick >= 600 of
                        true ->
                            put(?LAST_PERSISTENT_FAMILY_COLLECT_PRIZE_TIME,Now),
                            persistent_family_collect_prize();
                        false ->
                            ignore
                    end
            end,
            case get(?FAMILY_COLLECTING_FLAG) of
                true ->
                    collect_update();
                _ ->
                    ignore
            end;
        _ ->
            ignre
    end.


hook_collect(ID) ->
    Score = get(?NOW_FAMILY_COLLECT_SCORE),
    case (Score+1) rem 10 of
        0 ->
            case random:uniform(2) of
                1 ->
                    family_collect_monster_summon_by_score(Score+1);
                _ ->
                    ignore
            end;
        _ ->
            ignore
    end,
    case get({?HASH_FAMILY_COLLECT_ID,ID}) of
        undefined ->
            mod_map_collect:delete_point(ID),
            delete;
        CollectID ->
            put(?NOW_FAMILY_COLLECT_SCORE,Score + 1),
            put(?FAMILY_COLLECT_NUM,get(?FAMILY_COLLECT_NUM) + 1),
            RoleIDList = mod_map_actor:get_in_map_role(),
            PointNum = get_point_num_by_role_num(length(RoleIDList)),
            case CollectID > PointNum of
                true ->
                    erase({?HASH_FAMILY_COLLECT_ID,ID}),
                    mod_map_collect:delete_point(ID),
                    case common_config_dyn:find(family_collect,CollectID) of
                        [] ->
                            ignore;
                        [#r_family_collect{collect_monster_list=MonsterList}] ->   
                            erase({?FAMILY_COLLECT_POINT_MONSTER_BORN_OVER,CollectID}),
                            delete_collect_point_monster(MonsterList)
                    end,
                    delete;
                false ->
                    ignore
            end
    end.



family_collect_monster_summon_by_score(Score) when Score <16 ->
    {FamilyID,_} = common_map:get_map_family_id(),
    common_broadcast:bc_send_msg_family(FamilyID,[?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_FAMILY,?_LANG_FAMILY_COLLECT_SUMMON_BOSS),
    self() ! {mod_map_monster,{dynamic_summon_monster, 10202101 , 1, 44, 15, 300}};
family_collect_monster_summon_by_score(Score) when Score <31 ->
    {FamilyID,_} = common_map:get_map_family_id(),
    common_broadcast:bc_send_msg_family(FamilyID,[?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_FAMILY,?_LANG_FAMILY_COLLECT_SUMMON_BOSS),
    self() ! {mod_map_monster,{dynamic_summon_monster, 10202102 , 1, 44, 15, 300}};
family_collect_monster_summon_by_score(Score) when Score <51 ->
    {FamilyID,_} = common_map:get_map_family_id(),
    common_broadcast:bc_send_msg_family(FamilyID,[?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_FAMILY,?_LANG_FAMILY_COLLECT_SUMMON_BOSS),
    self() ! {mod_map_monster,{dynamic_summon_monster, 10202103 , 1, 44, 15, 300}};
family_collect_monster_summon_by_score(Score) when Score <101 ->
    {FamilyID,_} = common_map:get_map_family_id(),
    common_broadcast:bc_send_msg_family(FamilyID,[?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_FAMILY,?_LANG_FAMILY_COLLECT_SUMMON_BOSS),
    self() ! {mod_map_monster,{dynamic_summon_monster, 10202104 , 1, 44, 15, 300}};
family_collect_monster_summon_by_score(Score) when Score <201 ->
    {FamilyID,_} = common_map:get_map_family_id(),
    common_broadcast:bc_send_msg_family(FamilyID,[?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_FAMILY,?_LANG_FAMILY_COLLECT_SUMMON_BOSS),
    self() ! {mod_map_monster,{dynamic_summon_monster, 10202105 , 1, 44, 15, 300}};
family_collect_monster_summon_by_score(Score) when Score <301 ->
    {FamilyID,_} = common_map:get_map_family_id(),
    common_broadcast:bc_send_msg_family(FamilyID,[?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_FAMILY,?_LANG_FAMILY_COLLECT_SUMMON_BOSS),
    self() ! {mod_map_monster,{dynamic_summon_monster, 10202106 , 1, 44, 15, 300}};
family_collect_monster_summon_by_score(_) ->
    ok.

hook_monster_dead(MonsterTypeID) ->
    case lists:member(MonsterTypeID, [10202101,10202102,10202103,10202104,10202105]) of
        true ->
            case get(?NOW_FAMILY_COLLECT_SCORE) of
                undefined ->
                    ignore;
                Score ->
                    put(?NOW_FAMILY_COLLECT_SCORE,Score + 15)
            end;
        false ->
            ignore
    end.

check_is_family_collect(ID) ->
    case get({?HASH_FAMILY_COLLECT_ID,ID}) of
        undefined ->
            false;
        _ ->
            true
    end.
             
%%
%% Local Functions
%%
collect_update() ->
    RoleIDList = mod_map_actor:get_in_map_role(),
    PointNum = get_point_num_by_role_num(length(RoleIDList)),
    CollectPointIDList = lists:seq(1, PointNum),
    State = mgeem_map:get_state(),
    Collects = lists:foldr(
      fun(CollectPointID,Acc) ->
            collect_point_update(CollectPointID,Acc)
      end, [], CollectPointIDList),
      mod_map_collect:update_collect_to_slice(Collects,State),
    NowFamilyCollectScore = get(?NOW_FAMILY_COLLECT_SCORE),
    case get(?OLD_FAMILY_COLLECT_SCORE) =:= NowFamilyCollectScore of
        true ->
            ignore;
        false ->
            put(?OLD_FAMILY_COLLECT_SCORE,NowFamilyCollectScore),
            CollectNum= get(?FAMILY_COLLECT_NUM),
            %KillMonsterNum = get(?FAMILY_COLLECT_MONSTER_KILLED_NUM),
            {H,M,S} = erlang:time(),
            [{EH, EM, ES}] = common_config_dyn:find(etc, family_collect_end_time),
            LeftTick = EH * 3600 + EM * 60 + ES - H * 3600 - M * 60 - S ,
            {FamilyID,_} = common_map:get_map_family_id(),
            Record = #m_family_collect_info_toc{score=NowFamilyCollectScore,
                                                collect_num=CollectNum,
                                                left_tick=LeftTick},
            common_misc:chat_broadcast_to_family(FamilyID, ?FAMILY_COLLECT, ?FAMILY_COLLECT_INFO, Record)
    end,
    ok.

get_point_num_by_role_num(RoleNum) ->
    trunc((RoleNum + 1)/2).


collect_point_update(CollectPointID,Acc) ->
    [#r_family_collect{collect_point_info=CollectPointInfo,collect_monster_list=MonsterList}] = common_config_dyn:find(family_collect,CollectPointID),
    case get({?HASH_FAMILY_COLLECT_ID,CollectPointInfo#p_collect_point_base_info.id}) of
        CollectPointID ->
            case get({?FAMILY_COLLECT_POINT_MONSTER_BORN_OVER,CollectPointID}) of
                true ->
                    Acc;
                _ ->
                    born_collect_point_monster(MonsterList,CollectPointID),
                    Acc
            end;
        undefined ->
            {_Point,Collects} = mod_map_collect:new_point(CollectPointInfo),
            put({?HASH_FAMILY_COLLECT_ID,CollectPointInfo#p_collect_point_base_info.id},CollectPointID),
            lists:append(Collects, Acc)
    end.


born_collect_point_monster([],CollectPointID) ->
    put({?FAMILY_COLLECT_POINT_MONSTER_BORN_OVER,CollectPointID},true);
born_collect_point_monster([{r_collect_monster_info,MonsterID,MonsterType,Tx,Ty}|List],CollectPointID) ->
    case mod_map_monster:get_monster_state(MonsterID) of
        undefined ->
            Pos = #p_pos{tx = Tx, ty = Ty, dir = 1},
            MonsterInfo = #p_monster{reborn_pos = Pos,
                          monsterid =  MonsterID,
                          typeid = MonsterType,
                          mapid = 10300},
            {_FamilyID,MapProcessName} = common_map:get_map_family_id(),
            mod_map_monster:init([MonsterInfo, ?MONSTER_CREATE_TYPE_NORMAL, 10300, MapProcessName, undefined, ?FIRST_BORN_STATE, null]);
        _ ->
            born_collect_point_monster(List,CollectPointID)
    end.


do_family_collect_begin_notice_broadcast() ->
    {H,M,S} = erlang:time(),
    [{SH, SM, SS}] = common_config_dyn:find(etc, family_collect_broadcast_time),
    LeftTick = SH * 3600 + SM * 60 + SS - H * 3600 - M * 60 - S ,
    case LeftTick > 10 of
        true ->
            erlang:send_after(LeftTick*1000,self(),{mod_family_collect,family_collect_begin_notice_broadcast});
        false ->
            Content = io_lib:format(?_LANG_FAMILY_COLLECT_WILL_BEGIN, []),
            Now = common_tool:now(),
            common_broadcast:bc_send_cycle_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_FAMILY,Content,Now, Now+180,90),
            erlang:send_after((86400 + LeftTick)*1000, self(), {mod_family_collect,family_collect_begin_notice_broadcast})
    end.
    
    

do_family_collect_begin() ->
    {FamilyID,_} = common_map:get_map_family_id(),
    {H,M,S} = erlang:time(),
    [{EH, EM, ES}] = common_config_dyn:find(etc, family_collect_end_time),
    LeftTick = EH * 3600 + EM * 60 + ES - H * 3600 - M * 60 - S ,
    case LeftTick > 0 of
        true ->
            put(?FAMILY_COLLECTING_FLAG,true),
            put(?NOW_FAMILY_COLLECT_SCORE,0),
            put(?FAMILY_COLLECT_NUM,0),
            %put(?FAMILY_COLLECT_MONSTER_KILLED_NUM,0),
            erlang:send_after(LeftTick*1000,self(),{mod_family_collect,family_collect_end}),
            Record = #m_family_collect_begin_toc{left_tick=LeftTick},
            common_misc:chat_broadcast_to_family(FamilyID, ?FAMILY_COLLECT, ?FAMILY_COLLECT_BEGIN, Record);
        false ->
            ignore
    end.


do_family_collect_end() ->
    {H,M,S} = erlang:time(),
    [{SH, SM, SS}] = common_config_dyn:find(etc, family_collect_start_time),
    LeftTick = SH * 3600 + SM * 60 + SS - H * 3600 - M * 60 - S ,
    case LeftTick >= 0 of
        true ->
            erlang:send_after(LeftTick*1000, self(), {mod_family_collect,family_collect_begin});
        false ->
            erlang:send_after((86400 + LeftTick)*1000, self(), {mod_family_collect,family_collect_begin})
    end,
    sum_family_collect_prize(),
    erase(?FAMILY_COLLECTING_FLAG),
    erase(?NOW_FAMILY_COLLECT_SCORE),
    erase(?OLD_FAMILY_COLLECT_SCORE),
    erase(?FAMILY_COLLECT_NUM),
    %erase(?FAMILY_COLLECT_MONSTER_KILLED_NUM),
    delete_family_collect_point(1,[]),
    ok.


delete_family_collect_point(CollectPointID,CollectsAcc) ->
    case common_config_dyn:find(family_collect,CollectPointID) of
        [] ->
            mod_map_collect:delete_collect_to_slice(CollectsAcc,mgeem_map:get_state());
        [#r_family_collect{collect_point_info=CollectPointInfo,collect_monster_list=MonsterList}] ->
            erase({?FAMILY_COLLECT_POINT_MONSTER_BORN_OVER,CollectPointID}),
            case get({?HASH_FAMILY_COLLECT_ID,CollectPointInfo#p_collect_point_base_info.id}) of
                CollectPointID ->
                    erase({?HASH_FAMILY_COLLECT_ID,CollectPointInfo#p_collect_point_base_info.id}),
                    DelCollects = mod_map_collect:delete_point(CollectPointInfo#p_collect_point_base_info.id),
                    delete_collect_point_monster(MonsterList);
                _ ->
                    DelCollects = []
            end,
            delete_family_collect_point(CollectPointID+1,lists:append(DelCollects,CollectsAcc))
    end.

%%并非真正的删除怪物，而是把这些怪物设置为死亡后不再重生
delete_collect_point_monster([]) ->
    ignore;
delete_collect_point_monster([{r_collect_monster_info,MonsterID,_,_,_}|List]) ->
    case mod_map_monster:get_monster_state(MonsterID) of
        undefined ->
                delete_collect_point_monster(List);
        MonsterState ->
            NewMonsterState = MonsterState#monster_state{create_type=?MONSTER_CREATE_TYPE_MANUAL_CALL},
            mod_map_monster:set_monster_state(MonsterID,NewMonsterState),
            delete_collect_point_monster(List)
    end.

%% @doc 设置门派采集积分
do_gm_set_family_collect_score(RoleID, Score) ->
    {ok, CollectInfo} = get_role_family_collect_info(RoleID),
    set_role_family_collect_info(RoleID, CollectInfo#p_family_collect_role_prize_info{total_score=Score}).

%% @doc 获取门派采集信息
get_role_family_collect_info(RoleID) ->
    case get({?ROLE_FAMILY_COLLECT_INFO, RoleID}) of
        undefined ->
            case db:dirty_read(?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO, RoleID) of
                [] ->
                    CollectInfo = #p_family_collect_role_prize_info{role_id=RoleID};
                [CollectInfo] ->
                    ok
            end,
            set_role_family_collect_info(RoleID, CollectInfo),
            put(?FAMILY_COLLECT_ROLE_IDLIST, [RoleID|get(?FAMILY_COLLECT_ROLE_IDLIST)]);
        CollectInfo ->
            ok
    end,
    {ok, CollectInfo}.

%% @doc 设置门派采集信息
set_role_family_collect_info(RoleID, CollectInfo) ->
    put({?ROLE_FAMILY_COLLECT_INFO, RoleID}, CollectInfo).
            
do_send_role_prize_info(Unique,_DataRecord, RoleID, Line) ->
    case get({?ROLE_FAMILY_COLLECT_INFO,RoleID}) of
        undefined ->
            case db:dirty_read(?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO,RoleID) of
                [] ->
                    Info = #p_family_collect_role_prize_info{role_id=RoleID},
                    put({?ROLE_FAMILY_COLLECT_INFO,RoleID},Info),
                    put(?FAMILY_COLLECT_ROLE_IDLIST,[RoleID|get(?FAMILY_COLLECT_ROLE_IDLIST)]),
                    Record = #m_family_collect_prize_info_toc{succ=true,info=Info};
                [Info] ->
                    put({?ROLE_FAMILY_COLLECT_INFO,RoleID},Info),
                    put(?FAMILY_COLLECT_ROLE_IDLIST,[RoleID|get(?FAMILY_COLLECT_ROLE_IDLIST)]),
                    Record = #m_family_collect_prize_info_toc{succ=true,info=Info}
            end;
        Info2 ->
            Record = #m_family_collect_prize_info_toc{succ=true,info=Info2}
    end,
    common_misc:unicast(Line, RoleID, Unique, ?FAMILY_COLLECT, ?FAMILY_COLLECT_PRIZE_INFO, Record).


do_refresh_prize(Unique,DataRecord, RoleID, Line) ->
    case get({?ROLE_FAMILY_COLLECT_INFO,RoleID}) of
        undefined ->
            case db:dirty_read(?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO,RoleID) of
                [] ->
                    do_refresh_prize_error(Unique,RoleID,Line,?_LANG_FAMILY_COLLECT_NO_ROLE_PRIZE);
                [Info] ->
                    put({?ROLE_FAMILY_COLLECT_INFO,RoleID},Info),
                    put(?FAMILY_COLLECT_ROLE_IDLIST,[RoleID|get(?FAMILY_COLLECT_ROLE_IDLIST)]),
                    do_refresh_prize_2(Unique,DataRecord, RoleID, Line, Info)
            end;
        Info2 ->
            do_refresh_prize_2(Unique,DataRecord, RoleID, Line, Info2)
    end.

-define(REFRESH_FAMILY_COLLECT_SILVER,500).
do_refresh_prize_2(Unique,_DataRecord, RoleID, Line, PrizeInfo) ->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{silver_bind = BindSilver,silver = Silver} = RoleAttr,
    case BindSilver + Silver >= ?REFRESH_FAMILY_COLLECT_SILVER of
        false ->
            do_refresh_prize_error(Unique, RoleID, Line, ?_LANG_NOT_ENOUGH_SILVER);
        true ->
            Fun = 
                fun() ->
                    NewRoleAttr = mod_map_pet:t_deduct_silver(RoleAttr,?REFRESH_FAMILY_COLLECT_SILVER,?CONSUME_TYPE_SILVER_FAMILY_COLLECT_REFRESH_PRIZE),
                    mod_map_role:set_role_attr(RoleID, NewRoleAttr),
                    NewColor = get_random_collect_color(PrizeInfo#p_family_collect_role_prize_info.color),
                    NewPrizeInfo = PrizeInfo#p_family_collect_role_prize_info{color=NewColor},
                    put({?ROLE_FAMILY_COLLECT_INFO,RoleID},NewPrizeInfo),
                    {ok,NewPrizeInfo,NewRoleAttr}
                end,
            case db:transaction(Fun) of
                {aborted, Reason} ->
                    do_refresh_prize_error(Unique, RoleID, Line, Reason);
                {atomic, {ok, NewPrizeInfo,NewRoleAttr}} ->
                    DataRecord = #m_family_collect_refresh_prize_toc{succ=true,info=NewPrizeInfo},
                    common_misc:unicast(Line, RoleID, Unique, ?FAMILY_COLLECT, ?FAMILY_COLLECT_REFRESH_PRIZE, DataRecord),          
                    ChangeList = [
                                  #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=NewRoleAttr#p_role_attr.silver},
                                  #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=NewRoleAttr#p_role_attr.silver_bind}],
                    common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList)
            end
    end.


get_random_collect_color(OldColor) ->
    Rate = random:uniform(10000),
    Color = case Rate =< 2000 of
        true ->
            1;
        false ->
            case Rate =< 8500 of
                true ->
                    2;
                false ->
                    case Rate =< 9200 of
                        true ->
                            3;
                        false ->
                            case Rate =< 9700 of
                                true ->
                                    4;
                                false ->
                                    5
                            end
                    end
            end
    end,
    case OldColor >= 4 andalso OldColor > Color of
        true ->
            OldColor;
        false ->
            Color
    end.


do_refresh_prize_error(Unique,RoleID,Line,Reason) ->
    Record = #m_family_collect_refresh_prize_toc{succ=false,reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?FAMILY_COLLECT, ?FAMILY_COLLECT_REFRESH_PRIZE, Record).


do_get_prize(Unique,DataRecord, RoleID, Line) ->
     case get({?ROLE_FAMILY_COLLECT_INFO,RoleID}) of
        undefined ->
            case db:dirty_read(?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO,RoleID) of
                [] ->
                    do_refresh_prize_error(Unique,RoleID,Line,?_LANG_FAMILY_COLLECT_NO_ROLE_PRIZE);
                [Info] ->
                    put({?ROLE_FAMILY_COLLECT_INFO,RoleID},Info),
                    put(?FAMILY_COLLECT_ROLE_IDLIST,[RoleID|get(?FAMILY_COLLECT_ROLE_IDLIST)]),
                    do_get_prize_2(Unique,DataRecord, RoleID, Line, Info)
            end;
        Info2 ->
            do_get_prize_2(Unique,DataRecord, RoleID, Line, Info2)
    end.

do_get_prize_2(Unique,_DataRecord, RoleID, Line, PrizeInfo) ->
    #p_family_collect_role_prize_info{color=Color,base_exp=Exp} = PrizeInfo,
    case Exp > 0 of
        true ->
            case Color of
                1 -> AddExp = Exp;
                2 -> AddExp = trunc(Exp * 1.5);
                3 -> AddExp = trunc(Exp * 2);
                4 -> AddExp = trunc(Exp * 2.5);
                5 -> AddExp = trunc(Exp * 3.5);
                _ -> AddExp = 1
            end,
            case mod_map_role:do_add_exp(RoleID,AddExp) of
                ok ->
                    put({?ROLE_FAMILY_COLLECT_INFO,RoleID},PrizeInfo#p_family_collect_role_prize_info{base_exp=0,color=1}),
                    db:dirty_write(?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO,PrizeInfo#p_family_collect_role_prize_info{base_exp=0,color=1}),
                    Record = #m_family_collect_get_prize_toc{succ=true,addexp=AddExp},
                    common_misc:unicast(Line, RoleID, Unique, ?FAMILY_COLLECT, ?FAMILY_COLLECT_GET_PRIZE, Record),
                    {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
                    Content = io_lib:format(?_LANG_FAMILY_COLLECT_BROADCAST_GET_PRIZE, [common_tool:to_list(RoleBase#p_role_base.role_name),AddExp]),
                    common_broadcast:bc_send_msg_family(RoleBase#p_role_base.family_id,[?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_CHAT],?BC_MSG_TYPE_CHAT_FAMILY,Content);
                {fail,Reason} ->
                    do_get_prize_error(Unique,RoleID,Line,Reason)
            end;
        false ->
            do_get_prize_error(Unique,RoleID,Line,?_LANG_FAMILY_COLLECT_NO_ROLE_PRIZE)
    end.


do_get_prize_error(Unique,RoleID,Line,Reason) ->
    Record = #m_family_collect_get_prize_toc{succ=false,reason=Reason},
    common_misc:unicast(Line, RoleID, Unique, ?FAMILY_COLLECT, ?FAMILY_COLLECT_GET_PRIZE, Record).


persistent_family_collect_prize() ->
    List = get(?FAMILY_COLLECT_ROLE_IDLIST),
    lists:foreach(
      fun(RoleID) ->
              case get({?ROLE_FAMILY_COLLECT_INFO,RoleID}) of
                  undefined ->
                      ignore;
                  Info ->
                      db:dirty_write(?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO,Info)
              end,
              erase({?ROLE_FAMILY_COLLECT_INFO,RoleID})
      end, List),
    put(?FAMILY_COLLECT_ROLE_IDLIST,[]).


sum_family_collect_prize() ->
    RoleIDList = mod_map_actor:get_in_map_role(),
    Score = get(?NOW_FAMILY_COLLECT_SCORE),
    %% common_mod_goal:hook_family_collect_score(RoleIDList, Score),
    case Score > 0 of
        true ->
            sum_role_prize(RoleIDList,Score),
            {FamilyID,_} = common_map:get_map_family_id(),
            FamilyProcessName = common_misc:make_family_process_name(FamilyID),
            RoleNum = length(RoleIDList),
            catch global:send(FamilyProcessName,{add_prize_when_family_collect_end, Score,RoleNum}),
            Now = common_tool:now(),
            catch global:send(common_general_log_server, {family_collect_log,#r_family_collect_log{family_id=FamilyID,time=Now,role_num=RoleNum,score=Score}});
        false ->
            ignore
    end,
    ok.


sum_role_prize([],_) ->
    ok;
sum_role_prize([RoleID|List],Score) when Score =< 25->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    BaseExp = trunc(math:pow(RoleAttr#p_role_attr.level,1.3)*200 + 10*math:pow(RoleAttr#p_role_attr.level,1.3)* math:pow(25, 0.7)),
    sum_role_prize_2(RoleID,List,BaseExp,Score);
sum_role_prize([RoleID|List],Score) ->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    BaseExp = trunc(math:pow(RoleAttr#p_role_attr.level,1.3)*200 + 10*math:pow(RoleAttr#p_role_attr.level,1.3)* math:pow(Score, 0.7)),
    sum_role_prize_2(RoleID,List,BaseExp,Score).



sum_role_prize_2(RoleID,List,BaseExp,Score) ->
    OldScore = get_prize_info(RoleID),
    NewPrizeInfo = #p_family_collect_role_prize_info{role_id=RoleID,color=1,base_exp=BaseExp,total_score=OldScore+Score},
    put({?ROLE_FAMILY_COLLECT_INFO,RoleID},NewPrizeInfo),
    sum_role_prize(List,Score).

get_prize_info(RoleID) ->
   case get({?ROLE_FAMILY_COLLECT_INFO,RoleID}) of
        undefined ->
            case db:dirty_read(?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO,RoleID) of
                [] ->
                    put(?FAMILY_COLLECT_ROLE_IDLIST,[RoleID|get(?FAMILY_COLLECT_ROLE_IDLIST)]),
                    0;
                [Info] ->
                    put(?FAMILY_COLLECT_ROLE_IDLIST,[RoleID|get(?FAMILY_COLLECT_ROLE_IDLIST)]),
                    Info#p_family_collect_role_prize_info.total_score
            end;
        Info2 ->
            Info2#p_family_collect_role_prize_info.total_score
    end.

get_score_rec(RoleID) ->
   case get({?ROLE_FAMILY_COLLECT_INFO,RoleID}) of
        undefined ->
            case db:dirty_read(?DB_FAMILY_COLLECT_ROLE_PRIZE_INFO,RoleID) of
                [] ->
                    put(?FAMILY_COLLECT_ROLE_IDLIST,[RoleID|get(?FAMILY_COLLECT_ROLE_IDLIST)]),
                    undefine;
                [Info] ->
                    put(?FAMILY_COLLECT_ROLE_IDLIST,[RoleID|get(?FAMILY_COLLECT_ROLE_IDLIST)]),
                    Info
            end;
        Info2 ->
            Info2
    end.    
%%积分兑换后会扣除相应积分
exchange_byscore(RoleID,SubScroe) ->
    case get_score_rec(RoleID) of
       undefine ->
           {error,?_LANG_FAMILY_SCORE_EXCHANGE_NOSCORE};
       Info when is_record(Info,p_family_collect_role_prize_info)->
           Scores = Info#p_family_collect_role_prize_info.total_score-SubScroe,
           case Scores>=0 of
               true ->                  
                   NewPrizeInfo = Info#p_family_collect_role_prize_info{total_score=Scores},
                   UserList = get(?FAMILY_COLLECT_ROLE_IDLIST),
                   case lists:member(RoleID,UserList) of 
                       true ->
                            set_role_family_collect_info(RoleID,NewPrizeInfo);
                       false ->
                            put(?FAMILY_COLLECT_ROLE_IDLIST,[RoleID|get(?FAMILY_COLLECT_ROLE_IDLIST)]),
                            set_role_family_collect_info(RoleID,NewPrizeInfo)
                   end,                            
                   {ok,?_LANG_FAMILY_SCORE_EXCHANGE_OK};
               false ->
                   {error,?_LANG_FAMILY_SCORE_EXCHANGE_NOSCORE}
           end;
        _ ->
            {error,?_LANG_FAMILY_SCORE_EXCHANGE_MESSAGE}
    end.

do_get_score(Unique, Module, Method,DataIn, RoleID,Line) ->
    {ok, #p_role_attr{family_contribute=FamilyVaule}}  = mod_map_role:get_role_attr(RoleID),
    #m_family_collect_get_role_info_tos{type_id=TypeID} = DataIn,
    case TypeID of
       1 ->
           Value = get_prize_info(RoleID);
       2 ->
           Value = FamilyVaule;
       3 ->
           Value = get_zgong_value(RoleID);
       GoodID->           
           Value = query_num_bygoods(RoleID,GoodID) 
    end,
    Rec = #m_family_collect_get_role_info_toc{value=Value,type_id=TypeID},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, Rec). 

query_num_bygoods(RoleID,GoodsId) ->
    mod_exchange_npc_deal:get_role_deal_num(RoleID,GoodsId).

get_zgong_value(RoleID) ->
    try mod_map_role:get_role_attr(RoleID) of
        {ok, #p_role_attr{gongxun=GongXun}} ->
            GongXun
    catch
        _:Error ->
            ?DEBUG("gx:~w",[Error]),
            0
    end.
