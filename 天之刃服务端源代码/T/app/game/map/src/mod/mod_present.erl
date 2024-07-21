%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     处理赠送模块（例如新手时装的赠送）
%%% @end
%%% Created : 2011-02-22
%%%-------------------------------------------------------------------
-module(mod_present).

-include("mgeem.hrl").

%% API
-export([
         log_present_fashion/1,
         hook_first_enter_map/3,
         hook_level_up/3,
         handle/1
         ]).
-define(PRESENT_ID_FASHION,10001).


%===================================================================
%%% API
%%%===================================================================


handle(Args) ->
    do_handle(Args).



%%@doc 玩家升级后，处理赠品通知
hook_level_up(RoleID,RoleAttr,RoleBase)->
    #p_role_attr{level=Level} = RoleAttr,
    
    if
        %% 升级到20~30的时候，如果没有领过赠送时装，则弹窗提示
        Level>=20 andalso Level<31 ->
            do_notify_present(RoleID,RoleAttr,RoleBase);
        true->
            ignore
    end.

%%@doc 玩家首次进入地图，处理赠品通知
hook_first_enter_map(RoleID,RoleAttr,RoleBase) ->
    do_notify_present(RoleID,RoleAttr,RoleBase).


%% ====================================================================
%% Internal functions
%% ====================================================================


do_handle({Unique, Module, ?PRESENT_GET, DataIn, RoleID, PID,Line})->
    do_get_present({Unique, Module, ?PRESENT_GET, DataIn, RoleID, PID, Line});

do_handle(Args) ->
    ?ERROR_MSG("~w, unknow args: ~w", [?MODULE,Args]),
    ok. 

%%@doc 记录赠送时装的纪录
log_present_fashion(RoleID)->
    update_present_log(RoleID,?PRESENT_ID_FASHION).


%%@doc  通知赠品可以领取
do_notify_present(RoleID,RoleAttr,RoleBase) when is_integer(RoleID) andalso is_record(RoleAttr,p_role_attr)
            andalso is_record(RoleBase,p_role_base)->
    case db:dirty_read(?DB_ROLE_PRESENT,RoleID) of
        [#r_role_present{present_list=DbPresList}]->
            SendPresList = get_present_list(RoleAttr,RoleBase,DbPresList);
        []->
            SendPresList = get_present_list(RoleAttr,RoleBase,[])
    end,
    case SendPresList of
        []->
            ignore;
        _ ->
            R = #m_present_notify_toc{present_list=SendPresList},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?PRESENT, ?PRESENT_NOTIFY, R)
    end.


get_present_get_times([],_PresentID)->
    0;
get_present_get_times(PresList,PresentID) when is_list(PresList)->
    case lists:keyfind(PresentID, 1, PresList) of
        {_,Num}-> Num;
        false-> 0
    end.
    
%%@doc 获取玩家符合条件的赠品列表
get_present_list(RoleAttr,RoleBase,DbPresList)->
    case common_config_dyn:list(present) of
        []-> [];
        PresList->
            get_present_list_2(RoleAttr,RoleBase,DbPresList,PresList)
    end.
get_present_list_2(RoleAttr,RoleBase,DbPresList,PresList)->
    #p_role_attr{level=CurLevel} = RoleAttr,
    #p_role_base{sex=Sex,faction_id=FactionID} = RoleBase,
    Now = common_tool:datetime_to_seconds( calendar:local_time() ),
    PresList = common_config_dyn:list(present),
    PresList2 = lists:filter(fun(E)-> 
                                     #r_present_config{present_id=PresentID,level=PrstLevel,max_times=MaxTimes,
                                                       start_date=StartDate,end_date=EndDate} = E,
                                     TheUseTime = get_present_get_times(DbPresList,PresentID),
                                     StartTimeStamp = common_tool:datetime_to_seconds({StartDate,{0,0,0}}),
                                     EndTimeStamp = common_tool:datetime_to_seconds({EndDate,{23,59,59}}),
                                     CurLevel>=PrstLevel andalso MaxTimes>TheUseTime 
                                         andalso Now>=StartTimeStamp andalso EndTimeStamp>=Now
                             end, PresList),
    
    [ transform_present_info(PresConfig,FactionID,Sex)||PresConfig<-PresList2 ].
    

transform_present_info(PresConfig,FactionID,Sex)->
    #r_present_config{present_id=ID,title=Title,item_list_male=ItemListMale,item_list_female=ItemListFemale,
                      is_direct_get=IsDirectGet,npc_list=NpcList} =PresConfig,
    NpcID = lists:nth(FactionID, NpcList),
    ItemList = case Sex of
                   1-> [ItemTypeID||{_Type,ItemTypeID,_Num}<-ItemListMale];
                   _ -> [ItemTypeID||{_Type,ItemTypeID,_Num}<-ItemListFemale]
               end,
    #p_present_info{present_id=ID,title=Title,is_direct_get=IsDirectGet,item_list=ItemList,npc_id=NpcID}.


format_lang(Format,Args) when is_list(Args)->
    lists:flatten( io_lib:format(Format, Args) ).

%%@interface 领取赠品
do_get_present({Unique, Module, Method, DataIn, RoleID, _PID, Line}=InterfaceData)->
    #m_present_get_tos{present_id=PresentID} = DataIn,
    %%判断次数
    case common_config_dyn:find(present,PresentID) of
        [PresConfig] when is_record(PresConfig,r_present_config)->
            #r_present_config{level=PrstLevel,max_times=MaxTimes,start_date=StartDate,end_date=EndDate} = PresConfig,
            case MaxTimes>0 of
                true->
                    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
                    #p_role_attr{level=CurLevel} = RoleAttr,
                    StartTimeStamp = common_tool:datetime_to_seconds({StartDate,{0,0,0}}),
                    EndTimeStamp = common_tool:datetime_to_seconds({EndDate,{23,59,59}}),
                    Now = common_tool:datetime_to_seconds( calendar:local_time() ),
                    if  
                        CurLevel<PrstLevel->
                            ?SEND_ERR_TOC(m_present_get_toc,format_lang(<<"必须达到~w等级才能领取该赠品">>,[PrstLevel]));
                        Now<StartTimeStamp ->
                            ?SEND_ERR_TOC(m_present_get_toc,<<"该赠品的赠送活动尚未开始，感谢您的支持">>);
                        Now>EndTimeStamp ->
                            ?SEND_ERR_TOC(m_present_get_toc,<<"该赠品的赠送活动已经结束，感谢您的支持">>);
                        true->
                            do_get_present_2(PresentID,PresConfig,MaxTimes,InterfaceData)
                    end;
                _ ->
                    ?SEND_ERR_TOC(m_present_get_toc,<<"没有指定的赠品">>)
            end;
        
        _ ->
            ?SEND_ERR_TOC(m_present_get_toc,<<"没有指定的赠品">>)
    end.

do_get_present_2(PresentID,PresConfig,MaxTimes,InterfaceData)->
    {Unique, Module, Method, _DataIn, RoleID, _PID, Line}=InterfaceData,
    case db:dirty_read(?DB_ROLE_PRESENT,RoleID) of
        [#r_role_present{present_list=PresList}]->
            case lists:keyfind(PresentID, 1, PresList) of
                {PresentID,Num}->
                    case Num>= MaxTimes of
                        true->
                            Reason = <<"您已经领取完赠品，不能继续领取">>,
                            ?SEND_ERR_TOC(m_present_get_toc,Reason)
                    end;
                _ ->
                    do_get_present_3(PresConfig,InterfaceData)
            end;
        []->
            do_get_present_3(PresConfig,InterfaceData);
        _ ->
            ?SEND_ERR_TOC(m_present_get_toc,?_LANG_SYSTEM_ERROR)
    end.

do_get_present_3(PresConfig,{Unique, Module, Method, _DataIn, RoleID, _PID, Line})->
    #r_present_config{present_id=PresentID,item_list_male=ItemListMale,item_list_female=ItemListFemale} =PresConfig,
    {ok, #p_role_base{sex=Sex}} = mod_map_role:get_role_base(RoleID),
    AwdItemList = case Sex of
                      1-> ItemListMale;
                      _ -> ItemListFemale
                  end,
    case common_transaction:transaction( fun() -> t_add_item(RoleID,[],AwdItemList) end)
        of
        {atomic, {ok,AddGoodsList}} ->
            update_present_log(RoleID,PresentID),
            lists:foreach(fun(AwdItem)-> 
                                  {_Type,ItemTypeID,Num} = AwdItem,   
                                  common_item_logger:log(RoleID, ItemTypeID,Num,undefined,?LOG_ITEM_TYPE_XI_TONG_ZENG_SONG)
                          end,AwdItemList),
            %%发送消息序列最好是先删除再新增
            common_misc:update_goods_notify({role, RoleID}, AddGoodsList),
            
            R = #m_present_get_toc{succ=true,present_id=PresentID},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R);
        {aborted, {bag_error,not_enough_pos}} ->
            ?SEND_ERR_TOC(m_present_get_toc,<<"背包空间已满，请整理背包！">>);
        {aborted, {throw, {bag_error, Reason}}} ->
            ?ERROR_MSG("赠送赠品错误，{bag_error, Reason=~w}",[Reason]),
            ?SEND_ERR_TOC(m_present_get_toc,<<"背包错误!">>);
        {aborted, Error} ->
            ?ERROR_MSG("赠送赠品错误，Error=~w",[Error]),
            ?SEND_ERR_TOC(m_present_get_toc,?_LANG_SYSTEM_ERROR)
    end.

update_present_log(RoleID,PresentID)->
    case db:dirty_read(?DB_ROLE_PRESENT,RoleID) of
        [#r_role_present{present_list=PresList}]->
            case lists:keyfind(PresentID, 1, PresList) of
                {PresentID,Num}->
                    PresList2 = lists:keyreplace(PresentID, 1, PresList, {PresentID,Num+1}),
                    R = #r_role_present{role_id=RoleID,present_list=PresList2};
                _ ->
                    R = #r_role_present{role_id=RoleID,present_list=[{PresentID,1}|PresList]}
            end;
        []->
            R = #r_role_present{role_id=RoleID,present_list=[{PresentID,1}]}
    end,
    db:dirty_write(?DB_ROLE_PRESENT,R).



%%@doc 给予道具列表
t_add_item(_RoleID,GoodsList,[])->
    {ok,GoodsList};
t_add_item(RoleID,GoodsList,[AwdItem|T])->
    ?INFO_MSG("AwdItem:~w~n",[AwdItem]),
    {Type,ItemTypeID,Num} = AwdItem,
    CreateInfo = #r_goods_create_info{bind=true,type=Type, type_id=ItemTypeID, start_time=0, end_time=0, 
                                      num=Num, color=?COLOUR_WHITE,quality=?QUALITY_GENERAL,
                                      punch_num=0,interface_type=present},
    {ok,NewGoodsList} = mod_bag:create_goods(RoleID,CreateInfo),
    t_add_item(RoleID, lists:concat([NewGoodsList,GoodsList]) ,T).

                                                
 
 








