%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     检查任务数据
%%% @end
%%%-------------------------------------------------------------------
-module(mod_mission_check).

-include("mission.hrl"). 


-export([
		 check/0,check/1
		]).

%% ====================================================================
%% Macro
%% ====================================================================
-define(MISS_THROW_ERR(Reason),throw({error,Reason})).
-define( ECHO_ERR(F,D),io:format(F, D) ).


%% ====================================================================
%% API functions
%% ====================================================================
check()->
    check(false).

check(IsPrintLog)->
    FilePath = "/data/tzr/server/config/mission/missions.detail",
    {ok,MissionList} = file:consult(FilePath),
    
    case catch check_basic_condition(MissionList) of
        ok->
            case catch check_mission_detail(MissionList) of
                ok->
                    echo_msg(IsPrintLog,"check mission ok!",[]),
                    ok;
                {error,ErrIdList,ErrMsgList}->
                    echo_msg(IsPrintLog,"error,MissionIdList=~w,Reason=~w",[ErrIdList,ErrMsgList]),
                    error
            end;
        {error,Reason}->
            echo_msg(IsPrintLog,"error,Reason=~w",[Reason]),
            error
    end.

echo_msg(true,Msg,Data)->
    ?ERROR_MSG( Msg,Data);
echo_msg(_IsPrintLog,Msg,Data)->
    io:format( Msg,Data).



%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

%%检查三个国家的数量是否相等
check_basic_condition(MissionList)->
	assert_faction(MissionList),
    assert_mission_id(MissionList),
	ok.

%%对每个任务进行具体检查
check_mission_detail(MissionList)->
    CheckResult = lists:foldl(
      fun(E,AccIn)-> 
              #mission_base_info{id=MissionId} = E,
              {ErrIdList,ErrMsgList} = AccIn,
              case catch do_check_mission_detail(E,MissionList) of
                  ok-> 
                      AccIn;
                  {error,Reason}->
                      {[MissionId|ErrIdList],[Reason|ErrMsgList]}
              end
      end, {[],[]},MissionList),
    case CheckResult of
        {[],[]}->
            ok;
        {ErrIdList,ErrMsgList} ->
            {error,ErrIdList,ErrMsgList}
    end.


do_check_mission_detail(Miss,MissionList)->
	#mission_base_info{type=Type,model=MissionModel,pre_mission_id=PreMissionId,faction=FactionId,
					   min_level=MinLevel,reward_data=RewardData} = Miss,
	assert_type(Type),
	assert_model(MissionModel,Miss),
	assert_pre_mission(PreMissionId,MinLevel,FactionId,MissionList),
	assert_reward_data(RewardData),
	ok.

assert_reward_data(RewardData)->
	#mission_reward_data{prop_reward_formula=PropFormula,attr_reward_formula=AttrFormula,prop_reward=PropRewardList}= RewardData,
	case PropFormula<0 orelse PropFormula>3 of
		true->
			?MISS_THROW_ERR({err_prop_reward_formula,PropFormula});
		_ ->
			next
	end,
	case AttrFormula<0 orelse AttrFormula>4 of
		true->
			?MISS_THROW_ERR({err_attr_reward_formula,AttrFormula});
		_ ->
			next
	end,
	case is_list(PropRewardList) andalso length(PropRewardList)>0 of
		true->
			lists:foreach(
			  fun(E)-> 
					  assert_prop(E)
			  end, PropRewardList);
		_ ->
			next
	end,
	ok.

assert_prop(E)->
	#p_mission_prop{prop_type=PropType,prop_id=PropId} = E,
	case PropType<1 orelse PropType>3 of
		true->
			?MISS_THROW_ERR({err_prop_type,PropType});
		_ ->
			next
	end,
	MatchPropType = PropId div 10000000,
	case MatchPropType =:= PropType of
		true->
			next;
		_ ->
			?MISS_THROW_ERR({err_prop_id,PropId})
	end.

assert_type(Type)->
	case Type<1 orelse Type>3 of
		true->
			?MISS_THROW_ERR({err_type,Type});
		_ ->
			next
	end.

assert_model(MissionModel,Miss)->
	case MissionModel<1 orelse MissionModel>30 of
		true->
			?MISS_THROW_ERR({err_mission_model_not_exists,MissionModel});
		_ ->
			next
	end,
	case MissionModel of
		1->
			assert_model_1(Miss);
		2->
			assert_model_2(Miss);
		3->
			assert_model_3(Miss);
		4->
			assert_model_4(Miss);
		5->
			assert_model_5(Miss);
		6->
			assert_model_6(Miss);
		7->
			assert_model_7(Miss);
		12->
			assert_model_12(Miss);
		13->
			assert_model_13(Miss);
		14->
			assert_model_14(Miss);
        15->
            assert_model_15(Miss);
        16->
            assert_model_16(Miss);
        17->
            assert_model_17(Miss);
		_ ->
			ignore
	end.


assert_model_1(Miss)->
	#mission_base_info{id=Id,listener_list=ListenerList,faction=FactionId,model_status_data=StatusDataList} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_1,9999),
    assert_model_listener(Id,ListenerList,assert_model_1,false),
    assert_npc_faction(2,Id,FactionId,StatusDataList),
    ok.

assert_model_2(Miss)->
    #mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList,faction=FactionId} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_2,3),
    assert_model_listener(Id,ListenerList,assert_model_2,true),
    lists:foreach(
      fun(E)-> 
              case E of
                  #mission_listener_data{type=?MISSION_LISTENER_TYPE_MONSTER,int_list=[MapId],value=_MonsterId} ->
                      assert_map_id(MapId,FactionId);
                  _ ->
                      ?MISS_THROW_ERR({assert_model_2,listener_type,Id})
              end
      end,ListenerList),
    ok.
    

assert_model_3(Miss)->
    #mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList,faction=FactionId} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_3,3),
    assert_model_listener(Id,ListenerList,assert_model_3,true),
    lists:foreach(
      fun(E)-> 
              case E of
                  #mission_listener_data{type=?MISSION_LISTENER_TYPE_MONSTER,int_list=[MapId],value=_MonsterId} ->
                      assert_map_id(MapId,FactionId);
                  #mission_listener_data{type=?MISSION_LISTENER_TYPE_PROP} ->
                      next;
                  _ ->
                      ?MISS_THROW_ERR({assert_model_3,listener_type,Id})
              end
      end,ListenerList).

assert_map_id(MapId,FactionId)->
    case (MapId-10000) div 1000 of
        0->
            next;
        FactionId->
            next;
        _ ->
            ?MISS_THROW_ERR({assert_model_3,err_map_id,MapId,FactionId})
    end.

assert_model_4(Miss)->
    #mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_4,2),
    assert_model_listener(Id,ListenerList,assert_model_4,true),
    assert_model_listener_type(Id,ListenerList,assert_model_4,?MISSION_LISTENER_TYPE_PROP),
    ok.


assert_model_5(Miss)->
    #mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_5,3),
    assert_model_listener(Id,ListenerList,assert_model_5,true),
    assert_model_listener_type(Id,ListenerList,assert_model_5,?MISSION_LISTENER_TYPE_PROP),
    ok.

assert_model_6(Miss)->
	#mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_6,3),
    assert_model_listener(Id,ListenerList,assert_model_6,true),
    assert_model_listener_type(Id,ListenerList,assert_model_6,?MISSION_LISTENER_TYPE_BUY_PROP),
    ok.

assert_model_7(Miss)->
	#mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList} = Miss,
	assert_model_status(Id,StatusDataList,assert_model_7,3),
    assert_model_listener(Id,ListenerList,assert_model_7,true),
    assert_model_listener_type(Id,ListenerList,assert_model_7,?MISSION_LISTENER_TYPE_PROP),
    ok.

assert_model_12(Miss)->
	#mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_12,3),
    assert_model_listener(Id,ListenerList,assert_model_12,true),
    assert_model_listener_type(Id,ListenerList,assert_model_12,?MISSION_LISTENER_TYPE_ROLE_LEVEL),
    ok.

assert_model_13(Miss)->
	#mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_13,3),
    assert_model_listener(Id,ListenerList,assert_model_13,true),
    assert_model_listener_type(Id,ListenerList,assert_model_13,?MISSION_LISTENER_TYPE_SPECIAL_EVENT),
    ok.

assert_model_14(Miss)->
    #mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_14,3),
    assert_model_listener(Id,ListenerList,assert_model_14,true),
    lists:foreach(
      fun(E)-> 
              case E of
                  #mission_listener_data{type=?MISSION_LISTENER_TYPE_REINFORCE} ->
                      next;
                  #mission_listener_data{type=?MISSION_LISTENER_TYPE_CHANGE_QUALITY} ->
                      next;
                  _ ->
                      ?MISS_THROW_ERR({err_model_14,listener_type,Id})
              end
      end,ListenerList).

assert_model_15(Miss)->
    #mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_15,3),
    assert_model_listener(Id,ListenerList,assert_model_15,true),
    assert_model_listener_type(Id,ListenerList,assert_model_15,?MISSION_LISTENER_TYPE_PROP),
    ok.

assert_model_16(Miss)->
    #mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_16,4),
    assert_model_listener(Id,ListenerList,assert_model_16,true),
    lists:foreach(
      fun(E)-> 
              case E of
                  #mission_listener_data{type=?MISSION_LISTENER_TYPE_PROP} ->
                      next;
                  #mission_listener_data{type=?MISSION_LISTENER_TYPE_GIVE_USE_PROP} ->
                      next;
                  _ ->
                      ?MISS_THROW_ERR({err_model_16,listener_type,Id})
              end
      end,ListenerList),
    ok.

assert_model_17(Miss)->
    #mission_base_info{id=Id,listener_list=ListenerList,model_status_data=StatusDataList} = Miss,
    assert_model_status(Id,StatusDataList,assert_model_17,3),
    assert_model_listener(Id,ListenerList,assert_model_17,true),
    lists:foreach(
      fun(E)-> 
              case E of
                  #mission_listener_data{type=?MISSION_LISTENER_TYPE_PROP} ->
                      next;
                  #mission_listener_data{type=?MISSION_LISTENER_TYPE_GIVE_USE_PROP} ->
                      next;
                  _ ->
                      ?MISS_THROW_ERR({err_model_17,listener_type,Id})
              end
      end,ListenerList),
    ok.
%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

assert_pre_mission(0,_,_,_)->
	ignore;
assert_pre_mission(_,MinLevel,_,_) when MinLevel>150->
	ignore;
assert_pre_mission(PreMissionId,_MinLevel,MyFaction,MissionList)->
	case lists:keyfind(PreMissionId,#mission_base_info.id,MissionList) of
		false->
			?MISS_THROW_ERR({err_pre_mission_not_exists,PreMissionId});
		#mission_base_info{faction=PreFaction}->
			case PreFaction =:= MyFaction of
				true->
					next;
				_ ->
					?MISS_THROW_ERR({err_pre_faction,PreMissionId,PreFaction})
			end
	end.

assert_mission_id(MissionList)->
    lists:foldl(
      fun(E,AccIn)-> 
              #mission_base_info{id=Id}=E,
              case lists:member(Id, AccIn) of
                  true->
                      ?MISS_THROW_ERR({err_mission_id_duplicate,Id});
                  _ ->
                      [Id|AccIn]
              end
      end, [], MissionList).

assert_faction(MissionList)->
	FactionNum = 
		lists:foldl(
		  fun(E,AccIn)-> 
				  #mission_base_info{faction=FactionId}=E,
				  {Num1,Num2,Num3} = AccIn,
				  case FactionId of
					  1->
						  {Num1+1,Num2,Num3};
					  2->
						  {Num1,Num2+1,Num3};
					  3->
						  {Num1,Num2,Num3+1};
					  _->
						  ?MISS_THROW_ERR({err_faction,FactionId})
				  end
		  end,{0,0,0},MissionList),
	{Num1,Num2,Num3} = FactionNum,
	if
		Num1=:=Num2 andalso Num2=:=Num3->
			next;
		true ->
			?MISS_THROW_ERR({err_faction_num,Num1,Num2,Num3})
	end.

assert_npc_faction(1,Id,FactionId,StatusDataList)->
    %%#mission_status_data
    %%12000101
    lists:foreach(
      fun(E)-> 
              #mission_status_data{npc_list=NpcList} = E,
              lists:foreach(
                fun(NpcId)-> 
                        NpcFaction = (NpcId-10000000) div 1000000,
                        if
                            NpcFaction =:= FactionId->
                                next;
                            true->
                                ?MISS_THROW_ERR({err_npc_faction,Id,FactionId,NpcId})
                        end
                end, NpcList)
      end, StatusDataList);
assert_npc_faction(_,_Id,_FactionId,_StatusDataList)->
    ok. 

assert_model_status(Id,StatusDataList,ErrModel,ListLength) when ListLength=:=9999->
    case is_list(StatusDataList) andalso length(StatusDataList)>0 of
        true->
            next;
        _ ->
            ?MISS_THROW_ERR({ErrModel,Id,status_data})
    end;
assert_model_status(Id,StatusDataList,ErrModel,ListLength)->
    case is_list(StatusDataList) andalso length(StatusDataList)=:=ListLength of
        true->
            next;
        _ ->
            ?MISS_THROW_ERR({ErrModel,Id,status_data})
    end.


assert_model_listener(Id,ListenerList,ErrModel,HasListener)->
    ListenerSize = length(ListenerList),
    if
        ListenerSize>0 andalso HasListener=:=true ->
            next;
        ListenerSize=:=0 andalso HasListener=:=false->
            next;
        true->
            ?MISS_THROW_ERR({ErrModel,Id,listener,ListenerSize})
    end.

assert_model_listener_type(Id,ListenerList,ErrModel,ListenerType)->
    lists:foreach(
      fun(E)-> 
              case E of
                  #mission_listener_data{type=ListenerType} ->
                      next;
                  _ ->
                      ?MISS_THROW_ERR({ErrModel,Id,listener_type,listener_type})
              end
      end,ListenerList).

