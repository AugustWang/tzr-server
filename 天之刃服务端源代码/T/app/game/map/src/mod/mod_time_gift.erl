%% Author: MarkyCai
%% Created: 2011-2-10
%% Description: 时间礼包
-module(mod_time_gift).

-include("mgeem.hrl").

%%
%% Exported Functions
%%

-export([get_time_gift/1,handle/1,if_get_all_time_gift/1,pause_time_gift/1]).

%%
%% =====================API Functions=====================================
%%
get_time_gift(RoleID)->
	case common_config:chk_module_method_open(?LEVEL_GIFT, ?TIME_GIFT_LIST) of
		true->
			case get_next_time_gift(RoleID) of
				{ok,[]}->
					?DEBUG("Send RoleID:~w level ignore~n",[RoleID]),
					mod_level_gift:send_role_level_gift(RoleID);
				{ok,[Gift]}->
					Data = # m_time_gift_list_toc{gift = Gift},
					common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE,?LEVEL_GIFT,?TIME_GIFT_LIST,Data)
			end;
		{false,Reason}->
			?DEBUG("Reason~w~n",[Reason]),
			mod_level_gift:send_role_level_gift(RoleID)
	end.
		
%%检查时间礼包是否领取完毕,给等级礼包用
if_get_all_time_gift(RoleID)->
	case common_config:chk_module_method_open(?LEVEL_GIFT, ?TIME_GIFT_LIST) of
		{false,Reason}->
			?DEBUG("Reason~w~n",[Reason]),
			true;
		true->
			case db:dirty_read(?DB_ROLE_TIME_GIFT,RoleID) of
				[#r_role_time_gift{gifts=Gifts}] when Gifts=/=[] ->
					case lists:keyfind(notget,2,Gifts) of 
						false->
							true;
						_-> 
							false
					end;
				[]->
					false
			end
	end.

%%停止倒计时
pause_time_gift(RoleID)->
	case common_config:chk_module_method_open(?LEVEL_GIFT, ?TIME_GIFT_LIST) of
		true->
			RoleGift=db:dirty_read(?DB_ROLE_TIME_GIFT,RoleID),
			case RoleGift of
				[#r_role_time_gift{gifts=Gifts}] when Gifts=/=[] ->
					case lists:keyfind(notget,2,Gifts) of 
						false->
							ignore;
						Record->
							{ID,notget,StartTime,RestTime}=Record,
							NowTime=common_tool:now(),
							NewRestTime = case StartTime+RestTime-NowTime of
											  TempRestTime when TempRestTime < 0 ->
												  0;
											  TempRestTime->
												  TempRestTime
										  end, 
							?DEBUG("NewRestTime ~w~n",[NewRestTime]),
							NewRoleGift=#r_role_time_gift{role_id=RoleID,gifts=[{ID,notget,NowTime,NewRestTime}|lists:delete(Record,Gifts)]},
							db:dirty_write(?DB_ROLE_TIME_GIFT,NewRoleGift),
							?DEBUG("UPDATE THE LIST ~w~n",[NewRoleGift])
					end;
				_->
					ignore
			end;
		{false,Reason}->
			?DEBUG("Reason~w~n",[Reason]),
			ignore
	end.

handle({Unique,?LEVEL_GIFT,?TIME_GIFT_ACCEPT,DataIn,RoleID, _PID,_Line,_State}) ->
	%%要获取的时间礼包id
    #m_time_gift_accept_tos{id=ID} = DataIn,
	%%已获取的时间礼包
	RoleTimeGiftList = db:dirty_read(?DB_ROLE_TIME_GIFT,RoleID),
    RoleGift =case RoleTimeGiftList of
					[#r_role_time_gift{gifts=Gifts}]->
						Gifts;
					_->
						 []
				end,
	
    ?DEBUG("RoleGift:~w~n",[RoleGift]),
	
    case check_accept(RoleID,RoleGift,ID) of
        {error,Error} ->
            #m_level_gift_accept_toc{succ=false,reason=Error};
        {ok,{GoodsList}} ->
            case common_transaction:transaction(
                   fun() ->
                           mod_bag:create_goods_by_p_goods(RoleID,GoodsList)
                   end) 
            of
                {atomic,{ok,NewGoodsList}} ->
					?DEBUG("going to insert data into database~w~n",[]),
                    gift_goods_log(GoodsList),
					NewGifts=get_new_role_time_gift(ID,RoleGift),
					NewRoleTimeGifts1=make_new_role_time_gift(RoleID),
                    db:dirty_write(?DB_ROLE_TIME_GIFT,
                                   NewRoleTimeGifts1#r_role_time_gift{gifts=NewGifts}),
                    common_misc:update_goods_notify({role,RoleID},NewGoodsList),                   
                    Data = #m_time_gift_accept_toc{succ=true},
                    common_misc:unicast({role, RoleID},Unique,?LEVEL_GIFT,?TIME_GIFT_ACCEPT,Data),
                    %% 通知客户端下一个时间礼包信息，注意一定要在accept返回之后
                    get_time_gift(RoleID);
                {aborted,{bag_error,not_enough_pos}} ->
                    Data = #m_time_gift_accept_toc{succ=false,reason=?_LANG_TIME_GIFT_ENOUGH_POS},
                    common_misc:unicast({role, RoleID}, Unique,?LEVEL_GIFT,?TIME_GIFT_ACCEPT,Data);
                {aborted, Reason} ->
                    ?ERROR_MSG("Accept time gift error:~w~n",[Reason]),
                    Data = #m_time_gift_accept_toc{succ=false,reason=?_LANG_TIME_GIFT_SYSTEM_ERROR},
                    common_misc:unicast({role, RoleID}, Unique,?LEVEL_GIFT,?TIME_GIFT_ACCEPT,Data)
            end
    end.

%%
%% ==========================Local Functions======================================
%%

%% 进入地图就要检查,生成第一个包

get_next_time_gift(RoleID)->
	%%获取数据库中的记录（未领取）
	OldRoleTimeGift = db:dirty_read(?DB_ROLE_TIME_GIFT,RoleID),
	{ok,NewRoleTimeGift,NextTimeGift} = case OldRoleTimeGift of
		[#r_role_time_gift{gifts=Gifts}] when Gifts=/=[] ->
			case lists:keyfind(notget,2,Gifts) of 
				{TmpID,notget,_StartTime,TmpRestTime}-> 
					OldRecord1={TmpID,notget,_StartTime,TmpRestTime},
					NewRecord1={TmpID,notget,common_tool:now(),TmpRestTime},
					NewRoleTimeGift1=#r_role_time_gift{role_id=RoleID,gifts=[NewRecord1|lists:delete(OldRecord1,Gifts)]},
					db:dirty_write(?DB_ROLE_TIME_GIFT,NewRoleTimeGift1),
					{ok,NewRoleTimeGift1,[NewRecord1]};
				_->
					{ok,OldRoleTimeGift,[]}
			end;
		_->
			RoleTimeGift2 = make_new_role_time_gift(RoleID),
			[{_TypeID,Time}] = common_config_dyn:find(time_gift,1),
			NewTimeGift2 = {1,notget,common_tool:now(),Time},
			NewRoleTimeGift2 = RoleTimeGift2#r_role_time_gift{gifts=[NewTimeGift2]},
			db:dirty_write(?DB_ROLE_TIME_GIFT,NewRoleTimeGift2),
			{ok,NewRoleTimeGift2,[NewTimeGift2]}
	end,
	?DEBUG("NextTimeGiftRecord:~w~n",[NextTimeGift]),
	%%生成礼物包
	case NextTimeGift of
		[]->
			{ok,[]};
		[{ID,notget,_Time,RestTime}]->
			case common_config_dyn:find(time_gift,ID) of
				[{TypeID,_}]->
					case common_config_dyn:find(gift,TypeID) of
						[#r_gift{gift_list=GiftBaseList}] ->
         		           GoodsList = create_gift_goods_list(RoleID,GiftBaseList),
          		          {ok,[#p_time_gift_info{id=ID,goods_list=GoodsList,time=RestTime}]};
         		       _ ->
         		           {ok,[]}
					end;
				_->
					%%读不到这个礼包则把这个礼包去掉
					NewTimeGift3=NewRoleTimeGift#r_role_time_gift.gifts,
					NewTimeGift4=lists:delete({ID,notget,_Time,RestTime}, NewTimeGift3),
					db:dirty_write(?DB_ROLE_TIME_GIFT,NewRoleTimeGift#r_role_time_gift{gifts=[NewTimeGift4]}),
					
					{ok,[]}
			end
	end.

%%插入新数据，老玩家没有的
make_new_role_time_gift(RoleID) ->
	#r_role_time_gift{role_id=RoleID,gifts=[]}.


	
create_gift_goods_list(RoleID,GiftBaseList)->
	 GoodsList = 
        lists:foldl(
          fun(GiftBase,Acc) ->
                  CI = #r_goods_create_info{bind=GiftBase#p_gift_goods.bind, 
                                            type=GiftBase#p_gift_goods.type, 
                                            start_time=GiftBase#p_gift_goods.start_time,
                                            end_time=GiftBase#p_gift_goods.end_time,
                                            type_id=GiftBase#p_gift_goods.typeid,
                                            num=GiftBase#p_gift_goods.num,
                                            color=GiftBase#p_gift_goods.color},
                  {ok,TempGoodsList} = mod_bag:create_p_goods(RoleID, CI),
                  lists:append(TempGoodsList,Acc)
          end,[],GiftBaseList),
    lists:map(fun(Goods) -> Goods#p_goods{id=1,bagposition=0,bagid=0} end,GoodsList).

%%检查请求合法性
check_accept(RoleID,Gift,NextGiftID) ->
	case lists:keyfind(notget,2,Gift) of
		{ID,notget,_,_}->
			case ID=:=NextGiftID of
				true->
					case common_config_dyn:find(time_gift,NextGiftID) of
						[{TypeID,_Time}] ->
							case common_config_dyn:find(gift,TypeID) of
								[#r_gift{gift_list=GiftBaseList}] ->
									  %%{goodslist,{stamptime,typeid}}
									?DEBUG("past check===== ~w~n",[GiftBaseList]),
                            		{ok,{create_gift_goods_list(RoleID,GiftBaseList)}};
                        		_ ->
                           			{error,?_LANG_TIME_GIFT_NOT_GIFT}
							end;
						 _ ->
                    		{error,?_LANG_TIME_GIFT_NOT_GIFT}
					end;
				false->
					{error,?_LANG_TIME_GIFT_NOT_GIFT}
			end;
		false->
			{error,?_LANG_TIME_GIFT_NOT_GIFT}
	end.
	


%%写入日志
gift_goods_log(GoodsList) ->
    lists:foreach(
      fun(Goods) ->
              #p_goods{roleid=RoleID}=Goods,
              common_item_logger:log(RoleID,Goods,?LOG_ITEM_TYPE_LI_BAO_HUO_DE)
      end,GoodsList).

get_new_role_time_gift(ID,Gifts)->
	?DEBUG("获取要添加到更新的db数据~n",[]),
	case lists:keyfind(ID,1,Gifts) of
		false->
			?ERROR_MSG("could not find the gift",[]),
			Gifts;
		Record->
			{ID,_,StartTime,RestTime}=Record,
			NewRecord=[{ID,get,StartTime,RestTime}|lists:delete(Record,Gifts)],
			NextID=ID+1,
			case common_config_dyn:find(time_gift,NextID) of
				[{_TypeID,Time}]->
					[{NextID,notget,common_tool:now(),Time}|NewRecord];  
				[]->
					NewRecord
			end
	end.
	
	
