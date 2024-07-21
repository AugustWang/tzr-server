%%%-------------------------------------------------
%%% @author <caisiqiang@mingchao.com>   
%%% @copyright (C) 2010, mingchao.com        
%%% @doc                                     
%%%     mod_family                     
%%% @end                                     
%%% Created : 2011-01-13                     
%%%-------------------------------------------------

-module(mod_family_service).

-include("mgeeweb.hrl").

%%API

-export([get/1,getFamilyInfoByFamilyId/2]).

get(Req)->
	QueryString = Req:parse_qs(),
	try
	    case handle(QueryString) of
		{ok,Rtn}->
			?DEBUG("RTN~w~n",[Rtn]),
			mgeeweb_tool:return_json(Rtn, Req);
			
		{error,Error}->
			?ERROR_MSG("~w error,QueryString=~w,Error=~w,stacktrace=~w",[?MODULE,QueryString,Error,erlang:get_stacktrace()]),
			mgeeweb_tool:return_json_error(Req)
	    end
	catch
		_:Reason->
			?ERROR_MSG("~w error,Reason=~w,stacktrace=~w",[?MODULE,Reason,elang:get_stacktrace()]),
			mgeeweb_tool:return_json_error(Req)
	end.

handle(QueryString)->
	Fun = proplists:get_value("fun",QueryString),
	Arg0 = proplists:get_value("arg0",QueryString),
	Arg1 = proplists:get_value("arg1",QueryString),
	?DEBUG("fun:~w,arg0:~w,arg1:~w ~n",[Fun,Arg0,Arg1]),
	case Fun of
		"getFamilyInfo"->
			getFamilyInfoByFamilyId(Arg0,Arg1);
		"getFamilyExtInfo"->
			getFamilyExtInfo(Arg0)
	end.


%% @doc 根据门派id获取门派信息
getFamilyInfoByFamilyId(FID,FName)->
	FamilyID = case FID =:= [] of
					true -> '_';
					false -> common_tool:to_integer(FID)
			   	end,
	FamilyName = case FName =:= [] of
					 true -> '_';
					 false -> FName
				 end,
	Pattern =#p_family_info{family_id = FamilyID,family_name=FamilyName, _ = '_'},     
	?DEBUG("~ts,Parrten=~w",["查询条件为",Pattern]),                       
    	case mnesia:dirty_match_object(?DB_FAMILY,Pattern) of                    
		{aborted, Reason} ->
			?ERROR_MSG("~ts,FamilyID=~w,function=getFamilyInfo,Reason=~w.", ["查询门派信息出错",FamilyID,Reason]),    
			{error,Reason};
		[] ->      
			?DEBUG("找不到门派信息",[]),
			{ok,[]};
		[FamilyInfo] ->
			?DEBUG("FAMILYINFO ~w~n",[FamilyInfo]),
			%%防止编码出错
			Res = transfer_to_json(FamilyInfo#p_family_info{ybc_role_id_list=[]}), 
			?DEBUG("getfamilyinfo================~w",[FamilyInfo]),
			{ok, Res}
	end.

%% @doc 根据宗id获取门派扩展信息
getFamilyExtInfo(FID)->
	FamilyID = case FID =:= [] of
					true -> '_';
					false -> common_tool:to_integer(FID)
			   	end,

    Pattern =#r_family_ext{family_id = FamilyID,_ = '_'},     
    ?DEBUG("~ts,Parrten=~w",["查询条件为",Pattern]),                       
        case mnesia:dirty_match_object(?DB_FAMILY_EXT,Pattern) of                    
        {aborted, Reason} ->
            ?ERROR_MSG("~ts,FamilyName=~w,function=getFamilyInfo,Reason=~w.", ["查询门派信息出错",FamilyID,Reason]),    
            {error,Reason};
        [] ->      
            {ok,[]};
        [FamilyExtInfo] ->
			#r_family_ext{last_set_owner_time=LastSetOwnerTime,
						  common_boss_called=CommonBossCalled,
						  common_boss_killed=CommonBossKilled,
						  common_boss_call_time=CommonBossCallTime,
						  last_ybc_finish_date=LastYbcFinishDate,
						  last_ybc_begin_time=LastYbcBeginTime,
						  last_ybc_result=LastYbcResult,
						  last_resume_time=LastResumeTime,
						  last_card_use_count=LastCardUseCount,
						  last_card_use_day=LastCardUseDay,
						  common_boss_call_count=CommonBossCallCount
						  }=FamilyExtInfo,
			
            Res = [{last_set_owner_time,trans_element(LastSetOwnerTime)},
				   {common_boss_called,trans_element(CommonBossCalled)},
				   {common_boss_killed,trans_element(CommonBossKilled)},
				   {common_boss_call_time,trans_element(CommonBossCallTime)},
				   {last_ybc_finish_date,trans_element(LastYbcFinishDate)},
				   {last_ybc_begin_time,trans_element(LastYbcBeginTime)},
				   {last_ybc_result,trans_element(LastYbcResult)},
				   {last_resume_time,trans_element(LastResumeTime)},
				   {last_card_use_count,trans_element(LastCardUseCount)},
				   {last_card_use_day,trans_element(LastCardUseDay)},
				   {common_boss_call_count,trans_element(CommonBossCallCount)}], 
            ?DEBUG("getfamilyinfo================~w",[FamilyExtInfo]),
            {ok, Res}
    end.

trans_element(Element)->
	case Element of
		undefined->[];
		{{Y,M,D},{HH,_MM,_SS}} when is_integer(Y) andalso is_integer(M) 
                                                      andalso is_integer(D) andalso is_integer(HH) ->
                          date_to_string(Element);
        {HH,MM,SS}when is_integer(HH) andalso is_integer(MM)andalso is_integer(SS)   ->
                          time_to_string(Element);
		
		_->Element
	end.	
	
date_to_string(DateTime)->
    {{Y,M,D},{HH,MM,SS}} = DateTime,
    lists:flatten( io_lib:format("~w-~w-~w ~w:~w:~w",[Y,M,D,HH,MM,SS]) ).

time_to_string(Time)->
    {HH,MM,SS} = Time,
    lists:flatten( io_lib:format("~w-~w-~w",[HH,MM,SS]) ).

transfer_to_json(Rec)->                                    
	mgeeweb_tool:transfer_to_json(Rec).                        



