%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @doc 门派创建管理进程
%%% Created :  2010-07-06
%%%-------------------------------------------------------------------
-module(mod_family_manager).

-behaviour(gen_server).

-include("mgeew.hrl").

%% API
-export([
         start/0,
         start_link/0,
         register_family/1,
         init_all_family_farm/0
        ]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).


-record(state, {}).

-define(all_family_list, all_family_list).

-define(REGENE_RECOMMAND_USER_TICKET, 5 * 60 * 1000).


%%10秒更新一次门派列表
-define(REGENE_FAMILY_LIST, 10 * 1000).

%%三小时检查一次门派在线人数,并作相应处理
-define(FAMILY_ONLINECHK_INTERVAL,1000*60*60*3).
-define(REDUCE_SILVER_FOR_CREATE_FAMILY,reduce_silver_for_create_family).

%%默认门派地图中的初始化田地大小
-define(DEFAULT_FARM_SIZE,10).

-define(donate_gold,1).
-define(donate_silver,2).
%% 创建门派信件

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    {ok, _} = supervisor:start_child(mgeew_sup, {mod_family_sup,
                                                 {mod_family_sup, start_link, []},
                                                 permanent, infinity, supervisor, [mod_family_sup]}),
    {ok, _} = supervisor:start_child(mgeew_sup, {?MODULE, 
                                                 {?MODULE, start_link, []},
                                                 transient, 3000000, worker, [?MODULE]}).

%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).


register_family(FamilyID) ->
    case FamilyID > 0 of
        true ->
            case supervisor:start_child(mod_family_sup, 
                                        {lists:concat(["family_", FamilyID]), 
                                         {mod_family, start_link, [FamilyID]},
                                         transient, 300000, worker, [mod_family]}) of
                {ok, _PID} ->
                    ?DEBUG("~ts:~w", ["门派进程启动成功", FamilyID]),
                    ok;
                {error,{already_started,_}} ->
                    ?DEBUG("~ts:~w", ["门派进程已经启动", FamilyID]),
                    ok;
                {error, Reason} ->
                    ?ERROR_MSG("~ts:~w", ["启动门派进程失败", Reason]),
                    {error, Reason}
            end;
        false ->
            ignore
    end.

init_all_family_farm()->
    erlang:send(mod_family_manager, {init_all_family_farm}).

%%--------------------------------------------------------------------
init([]) ->
    case db:transaction(fun() -> t_init_family_counter() end) of
        {atomic, ok} ->
            ets:new(ets_family_join_history, [named_table, set, public]),
            gene_family_list([1, 2, 3]),
            ok = common_config_dyn:reload(family_ybc_money),
            erlang:send_after(1000, self(), gene_recommend_user),
            {ok, #state{}};
        {aborted, Reason} ->
            ?ERROR_MSG("", ["初始化门派计数表失败", Reason]),
            {stop, Reason}
    end.




t_init_family_counter() ->
    case db:read(?DB_FAMILY_COUNTER, 1, write) of
        [] ->
            db:write(?DB_FAMILY_COUNTER, #r_family_counter{id=1, value=1}, write);
        _ ->
            ok
    end.


gene_family_list(FactionIDList) ->
    gene_family_list_no_loop(FactionIDList),
    erlang:send_after(?REGENE_FAMILY_LIST, self(), gene_family_list).

gene_family_list_no_loop(FactionIDList) ->
    lists:foreach(
      fun(FactionID) ->
              SqlResult = mod_mysql:select(io_lib:format("select family_id, family_name, create_role_id, create_role_name, " ++ 
                                                              "owner_role_id," ++
                                                              "owner_role_name, faction_id, active_points, cur_members, level from " ++
                                                              "t_family_summary where faction_id=~w " ++ 
                                                              "order by active_points desc, level desc", [FactionID])),
			  case SqlResult of
				  {ok, FamilyList} ->
			  			FamilyList2 = [ transform_family_fields(Family) || Family<-FamilyList ],
              			put(lists:concat(["faction_family_list_", FactionID]), FamilyList2);
				  {error,Reason}->
					  	?WARNING_MSG("~ts: ~w", ["获取门派排行榜数据出错", Reason])
			  end
			  
      end, FactionIDList).

transform_family_fields(FamilyFields) when is_list(FamilyFields)->
    [FamilyID, FamilyName, CreateRoleID, CreateRoleName, OwnerRoleID, OwnerRoleName,
     FactionID, ActivePoints, CurMembers, Level] = FamilyFields,
    #p_family_summary{id=FamilyID, name=FamilyName, create_role_id=CreateRoleID, 
                      create_role_name=CreateRoleName, owner_role_id=OwnerRoleID,
                      owner_role_name=OwnerRoleName, cur_members=CurMembers, 
                      faction_id=FactionID, level=Level, active_points=ActivePoints}.


%%--------------------------------------------------------------------
handle_call(hot_create_ets, _From, State) ->
    Reply = ets:new(ets_family_join_history, [named_table, set, public]),
    {reply, Reply, State};
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.


%%--------------------------------------------------------------------
handle_info({'EXIT', PID, Reason}, State) ->
    ?ERROR_MSG("~ts: ~w, ~w", ["门派管理进程收到exit消息", PID, Reason]),
    {noreply, State};
handle_info(Info, State) ->
    ?DO_HANDLE_INFO(Info, State),
    {noreply, State}.


%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.


%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

-define(FAMILY_MODULE_ROUTER(TheModule),do_handle_info({Unique, TheModule, Method, Record, RoleID, PID, Line}) ->
    [#p_role_base{family_id=FamilyID}] = db:dirty_read(?DB_ROLE_BASE, RoleID),
    router_to_family_process(FamilyID, {Unique, TheModule, Method, Record, RoleID, PID, Line})).

do_handle_info({Unique, Module, ?FAMILY_LIST, Record, RoleID, PID, Line}) 
  when is_record(Record, m_family_list_tos) ->
    do_list(Unique, Module, ?FAMILY_LIST, Record, RoleID, PID, Line);

%%创建门派
do_handle_info({Unique, Module, ?FAMILY_CREATE, Record, RoleID, PID, Line}) 
  when is_record(Record, m_family_create_tos) ->
    do_create(Unique, Module, ?FAMILY_CREATE, Record, RoleID, PID, Line);
%%申请加入门派
do_handle_info({Unique, Module, ?FAMILY_REQUEST, Record, RoleID, PID, Line}) 
  when is_record(Record, m_family_request_tos) ->
    #m_family_request_tos{family_id=FamilyID} = Record, 
    do_request(FamilyID, {Unique, Module, ?FAMILY_REQUEST, Record, RoleID, PID, Line});
%%同意门派的邀请
do_handle_info({Unique, Module, ?FAMILY_AGREE, Record, RoleID, PID, Line})
  when is_record(Record, m_family_agree_tos) ->
    #m_family_agree_tos{family_id=FamilyID} = Record,
    router_to_family_process(FamilyID, {Unique, Module, ?FAMILY_AGREE, Record, RoleID, PID, Line});
%%获取门派活动状态
do_handle_info({Unique, Module, ?FAMILY_ACTIVESTATE, Record, RoleID, PID, Line})
  when is_record(Record, m_family_activestate_tos) ->
    #m_family_activestate_tos{family_id=FamilyID} = Record,
    router_to_family_process(FamilyID, {Unique, Module, ?FAMILY_ACTIVESTATE, Record, RoleID, PID, Line});
%%拒绝门派邀请
do_handle_info({Unique, Module, ?FAMILY_REFUSE, Record, RoleID, PID, Line})
  when is_record(Record, m_family_refuse_tos) ->
    #m_family_refuse_tos{family_id=FamilyID} = Record,
    router_to_family_process(FamilyID, {Unique, Module, ?FAMILY_REFUSE, Record, RoleID, PID, Line});
%%打开我的门派面板
do_handle_info({Unique, Module, ?FAMILY_PANEL, Record, RoleID, PID, Line}) 
  when is_record(Record, m_family_panel_tos) ->
    do_panel(Unique, Module, ?FAMILY_PANEL, Record, RoleID, PID, Line);

%%获取某个门派的详细信息 p_family_info
do_handle_info({Unique,Module,?FAMILY_DETAIL,Record,RoleID,PID,Line})
    when is_record(Record,m_family_detail_tos)->
    do_family_detail(Unique,Module,?FAMILY_DETAIL,Record,RoleID,PID,Line);

%%获取推荐的邀请玩家列表
do_handle_info({Unique, Module, ?FAMILY_CAN_INVITE, _, RoleID, _, Line}) ->
    do_can_invite(Unique, Module, ?FAMILY_CAN_INVITE, RoleID, Line);

%%召唤帮众参与门派boss战
do_handle_info({Unique,_Module,?FAMILY_MEMBER_ENTER_MAP,Record,RoleID,PID,Line}) ->
    ?DEBUG("jojocatcallmember comming ~p",[RoleID]),
    [#p_role_base{family_id=FamilyID}] = db:dirty_read(?DB_ROLE_BASE, RoleID),
    router_to_family_process(FamilyID,{Unique,?FAMILY,?FAMILY_MEMBER_ENTER_MAP,Record,RoleID,PID,Line});
%%宗族捐献
do_handle_info({Unique, _Module, ?FAMILY_GET_DONATE_INFO, Record, RoleID, PID, _Line})->
    do_get_donate_info(Unique,Record,RoleID,PID);

%%种植模块
?FAMILY_MODULE_ROUTER( ?PLANT );
%%门派技能模块
?FAMILY_MODULE_ROUTER( ?FMLSKILL );
%%门派仓库
?FAMILY_MODULE_ROUTER( ?FMLDEPOT );
%%门派主模块
?FAMILY_MODULE_ROUTER( ?FAMILY );


%%处理异步方式Money接口的返回消息
do_handle_info({?REDUCE_ROLE_MONEY_SUCC, RoleID, RoleAttr, ?REDUCE_SILVER_FOR_CREATE_FAMILY}) ->
    do_reduce_role_silver_for_create_successful(RoleID, RoleAttr);
do_handle_info({?REDUCE_ROLE_MONEY_FAILED, RoleID, Reason, ?REDUCE_SILVER_FOR_CREATE_FAMILY}) ->
    do_reduce_role_silver_for_create_failed(RoleID, Reason);
    

%%成员升级之后的处理
do_handle_info({member_levelup,FamilyID,MemberID,NewLevel})->
    router_to_family_process(FamilyID,{member_levelup,MemberID,NewLevel});


do_handle_info(gene_recommend_user) ->
    gene_recommend_user();

do_handle_info({gene_family_list, FactionList}) when erlang:is_list(FactionList) ->
    gene_family_list(FactionList);

do_handle_info(gene_family_list) ->
    gene_family_list([1, 2, 3]);

do_handle_info({update_family_ext_info,FamilyID,NewFamilyExtInfo})->
    router_to_family_process(FamilyID,{update_family_ext_info,NewFamilyExtInfo});

do_handle_info({role_online, _RoleID, FamilyID}) ->
    register_family(FamilyID);

do_handle_info({init_all_family_farm}) ->
    do_init_all_family_farm();

do_handle_info({family_donate,FamilyID,RoleName,{Unique,DataIn,RoleID,PID}})->
    {ok,AddContribute,AddMoney}=do_role_family_donate(FamilyID,RoleName,{Unique,DataIn,RoleID,PID}),
    router_to_family_process(FamilyID,{family_donate,RoleID,AddContribute,AddMoney});

do_handle_info({donate_delete_role,FamilyID,RoleID})->
    do_delete_role_donate(FamilyID,RoleID);

do_handle_info({donate_delete_family,FamilyID})->
    do_delete_family_donate(FamilyID);

do_handle_info(Info) ->
    ?ERROR_MSG("~ts:~w", ["未知的消息", Info]),
    ok.

%%删除捐献列表中的角色
do_delete_role_donate(FamilyID,RoleID)->
    case db:dirty_read(?DB_FAMILY_DONATE,FamilyID) of
        []->ignore;
        [FamilyDonate]->
            GoldDonateList = lists:keydelete(RoleID, #p_role_family_donate_info.role_id, FamilyDonate#r_family_donate.gold_donate_record),
            SilverDonateList = lists:keydelete(RoleID, #p_role_family_donate_info.role_id, FamilyDonate#r_family_donate.silver_donate_record),
            db:dirty_write(?DB_FAMILY_DONATE,FamilyDonate#r_family_donate{gold_donate_record=GoldDonateList,
                                                                          silver_donate_record=SilverDonateList})
    end.

%% 删除捐献列表中的宗族
do_delete_family_donate(FamilyID)->
    case db:dirty_read(?DB_FAMILY_DONATE,FamilyID) of
        []->ignore;
        [_FamilyDonate]->
            db:dirty_delete(?DB_FAMILY_DONATE, FamilyID)
    end.

do_role_family_donate(FamilyID,RoleName,{Unique,DataIn,RoleID,PID})->
    #m_family_donate_tos{donate_type=DonateType,
                         donate_value = DonateValue}=DataIn,   
    case db:dirty_read(?DB_FAMILY_DONATE,FamilyID) of
        []->
            FamilyDonate =#r_family_donate{family_id = FamilyID,
                             gold_donate_record=[],
                             silver_donate_record =[]};
        [FamilyDonate]->
            next
        end,
    #r_family_donate{gold_donate_record=GoldDonateList,
                     silver_donate_record = SilverDonateList} = FamilyDonate,
    case DonateType of
        ?donate_gold->
            {RoleDonateInfo,NewGoldDonateList}=do_add_donate_value(RoleID,RoleName,DonateValue,GoldDonateList),
            db:dirty_write(?DB_FAMILY_DONATE, FamilyDonate#r_family_donate{gold_donate_record=NewGoldDonateList}),
            AddMoney = DataIn#m_family_donate_tos.donate_value*1000,
            AddContribute = DataIn#m_family_donate_tos.donate_value*10;
        ?donate_silver->
            {RoleDonateInfo,NewSilverDonateList}=do_add_donate_value(RoleID,RoleName,DonateValue,SilverDonateList),
            db:dirty_write(?DB_FAMILY_DONATE, FamilyDonate#r_family_donate{silver_donate_record=NewSilverDonateList}),
            AddMoney = DataIn#m_family_donate_tos.donate_value,
            AddContribute = DataIn#m_family_donate_tos.donate_value div 100
    end,
    R = #m_family_donate_toc{donate_type=DonateType,
                             donate_info=RoleDonateInfo},
    common_misc:unicast2(PID, Unique, ?FAMILY, ?FAMILY_DONATE, R),
    {ok,AddContribute,AddMoney}.

do_add_donate_value(RoleID,RoleName,DonateValue,List)->
    case lists:keyfind(RoleID, #p_role_family_donate_info.role_id,List) of
        false->
            NewRoleDonateInfo = #p_role_family_donate_info{role_id=RoleID,role_name=RoleName,donate_amount=DonateValue},
            {NewRoleDonateInfo,[NewRoleDonateInfo|List]};
        RoleDonateInfo->
            NewRoleDonateInfo =RoleDonateInfo#p_role_family_donate_info{donate_amount=RoleDonateInfo#p_role_family_donate_info.donate_amount+DonateValue},
            {NewRoleDonateInfo,[NewRoleDonateInfo|lists:delete(RoleDonateInfo, List)]}
    end.


do_get_donate_info(Unique,_Record,RoleID,PID)->
    [#p_role_base{family_id=FamilyID}] = db:dirty_read(?DB_ROLE_BASE, RoleID),
    case db:dirty_read(?DB_FAMILY_DONATE,FamilyID) of
        []->
            R=#m_family_get_donate_info_toc{donate_gold_list=[],donate_silver_list = []};
        [FamilyDonateInfo]->
            R=#m_family_get_donate_info_toc{donate_gold_list=FamilyDonateInfo#r_family_donate.gold_donate_record,
                                   donate_silver_list = FamilyDonateInfo#r_family_donate.silver_donate_record}
    end,
    common_misc:unicast2(PID, Unique, ?FAMILY, ?FAMILY_GET_DONATE_INFO, R). 




make_recommend_key(FactionID) ->
    lists:concat(["recommend_user_", FactionID]).


do_family_detail(Unique,Module,Method,Record,RoleID,_PID,Line)->
    case db:dirty_read(?DB_FAMILY, Record#m_family_detail_tos.family_id) of
	[] ->
	    R_toc = #m_family_detail_toc{
	      succ = false,
	      reason = ?_LANG_FAMILY_NOT_EXITS_WHEN_REQUEST_DETAIL
	     };
	[Detail] ->
	    R_toc = #m_family_detail_toc{succ=true, content = Detail}
    end,    
    common_misc:unicast(Line,RoleID,Unique,Module,Method,R_toc).


do_can_invite(Unique, Module, Method, RoleID, Line) ->
    {ok, #p_role_base{faction_id=FactionID}} = common_misc:get_dirty_role_base(RoleID),
    InviteList = case get(make_recommend_key(FactionID)) of
                     undefined ->
                         [];
                     L ->
                         get_can_invite_list(RoleID, L, [])
                 end,

    R = #m_family_can_invite_toc{roles=InviteList},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).

%% @doc 获取推荐帮众列表
get_can_invite_list(_RoleID, [], InviteList) ->
    InviteList;
get_can_invite_list(_RoleID, _OnlineList, InviteList) when length(InviteList) >= 8 ->
    InviteList;
get_can_invite_list(RoleID, [#r_role_online{role_id=TargetID}|T], InviteList) ->
    %% 百分之十的机会先中
    case 10 < common_tool:random(1, 100) andalso RoleID =/= TargetID of
        true ->
            {ok, #p_role_attr{level=Level,category = CategoryT}} = common_misc:get_dirty_role_attr(TargetID),
            case Level >= 10 of
                true ->
                    {ok, #p_role_base{role_name=TargetName, sex=Sex}} = common_misc:get_dirty_role_base(TargetID),
                    case CategoryT =:= 0 of
                        true ->
                            Category = 1;
                        _ ->
                            Category = CategoryT
                    end,
                    InviteList2 = [#p_recommend_member_info{role_id=TargetID, role_name=TargetName, sex=Sex, level=Level, category=Category}|InviteList],
                    get_can_invite_list(RoleID, T, InviteList2);
                _ ->
                    get_can_invite_list(RoleID, T, InviteList)
            end;
        _ ->
            get_can_invite_list(RoleID, T, InviteList)
    end.


%%生成邀请推荐玩家列表
gene_recommend_user() ->
    lists:foreach(
      fun(FactionID) ->
              L1 = db:dirty_match_object(?DB_USER_ONLINE, #r_role_online{family_id=0, faction_id=FactionID, _='_'}),
              put(make_recommend_key(FactionID), L1)
      end, [1, 2, 3]),
    erlang:send_after(?REGENE_RECOMMAND_USER_TICKET, self(), gene_recommend_user).


%%获得所有门派列表中的某一页
get_family_list_of_all(PageID, NumOfPage) ->
    All = get(?all_family_list),
    Size =  erlang:length(All),
    case Size > 0 of
        true ->
            Start = (PageID - 1) * NumOfPage + 1,
            TotalPage = common_tool:ceil(Size/NumOfPage),
            {TotalPage, lists:sublist(All, Start, NumOfPage)};
        false ->
            {0, []}
    end.
    

%%获得本国门派中的某一页
get_family_list_of_faction(FactionID, PageID, NumOfPage) ->
    Key = lists:concat(["faction_family_list_", FactionID]),
    All = get(Key),
    Size = erlang:length(All),
    case Size > 0 of
        true ->
            Start = (PageID - 1) * NumOfPage + 1,
            TotalPage = common_tool:ceil(Size/NumOfPage),
            {TotalPage, lists:sublist(All, Start, NumOfPage)};
        false ->
            {0, []}
    end.


get_family_list(FactionID, FamilyID, PageID, NumOfPage, [], _Type) ->
    case FamilyID > 0 of
        true ->
            %%显示所有的门派
            get_family_list_of_all(PageID, NumOfPage);
        false ->
            %%显示本国门派
            get_family_list_of_faction(FactionID, PageID, NumOfPage)
    end;
get_family_list(FactionID, FamilyID, PageID, NumOfPage, SearchContent, Type) ->
    case FamilyID > 0 of
        true ->
            %%显示所有的门派
            get_family_list_of_all_search(PageID, NumOfPage, SearchContent, Type);
        false ->
            %%显示本国门派
            get_family_list_of_faction_search(FactionID, PageID, NumOfPage, SearchContent, Type)
    end.

get_family_list_of_all_search(PageID, NumOfPage, SearchContent, Type) ->
    All = get(?all_family_list),
    Size =  erlang:length(All),
    case Size > 0 of
        true ->
            Lists = lists:filter(
                      fun(F) ->
                              case Type of
                                  1 ->
                                      string:str(common_tool:to_list(F#p_family_summary.name), SearchContent) > 0;
                                  2 ->
                                      string:str(common_tool:to_list(F#p_family_summary.owner_role_name), SearchContent) > 0
                              end
                      end, All),
            Start = (PageID - 1) * NumOfPage + 1,
            TotalPage = common_tool:ceil(Size/NumOfPage),
            {TotalPage, lists:sublist(Lists, Start, NumOfPage)};
        false ->
            {0, []}
    end.
    

get_family_list_of_faction_search(FactionID, PageID, NumOfPage, SearchContent, Type) ->
    Key = lists:concat(["faction_family_list_", FactionID]),
    %%搜索所有的门派，检查出哪些符合条件
    All = get(Key),
    Size =  erlang:length(All),
    case Size > 0 of
        true ->
            Lists = lists:filter(
                      fun(F) ->
                              case Type of
                                  1 ->
                                      string:str(common_tool:to_list(F#p_family_summary.name), SearchContent) > 0;
                                  2 ->
                                      string:str(common_tool:to_list(F#p_family_summary.owner_role_name), SearchContent) > 0
                              end
                      end, All),
            Start = (PageID - 1) * NumOfPage + 1,
            TotalPage = common_tool:ceil(Size/NumOfPage),
            {TotalPage, lists:sublist(Lists, Start, NumOfPage)};
        false ->
            {0, []}
    end.


do_list(Unique, Module, Method, Record, RoleID, _PID, Line) ->
    #m_family_list_tos{page_id=PageID, num_per_page=NumOfPage, search_content=SearchContent, search_type=Type} = Record,
    case Type of
        1 ->
            Type2 = 1;
        _ ->
            Type2 = 2
    end,
    case PageID < 1 orelse NumOfPage =:= undefined of
        true ->
            PageID2 = 1;
        false ->
            PageID2 = PageID
    end,
    case NumOfPage < 1 orelse NumOfPage =:= undefined of
        true ->
            NumOfPage2 = 5;
        false ->
            NumOfPage2 = NumOfPage
    end,
    RequestFrom = Record#m_family_list_tos.request_from,
    ?DEBUG("family_request_from ~w",[RequestFrom]),
    [#p_role_base{family_id=FamilyID, faction_id=FactionID}] = db:dirty_read(?DB_ROLE_BASE, RoleID),
    SearchContent2 = string:strip(SearchContent),
    case RequestFrom of 
	1 ->
	    {TotalPage, FamilyList} = get_family_list(FactionID, FamilyID, PageID2, NumOfPage2, SearchContent2, Type2);
	_ ->
	    {TotalPage,FamilyList} = get_family_list(FactionID,0,PageID2,NumOfPage2,SearchContent2,Type2)
    end,
    
    R = #m_family_list_toc{
      family_list=FamilyList,
      total_page = TotalPage,
      page_id=PageID2,
      request_from=RequestFrom
     },
    common_misc:unicast(Line,RoleID,Unique,Module,Method,R),
    ok.
        

%%查看门派面板
do_panel(Unique, Module, Method, Record, RoleID, _PID, Line) ->
    #m_family_panel_tos{num_per_page=NumPerPageTmp} = Record,
    NumPerPage = erlang:abs(NumPerPageTmp),
    [#p_role_base{family_id=FamilyID, faction_id=FactionID}] = db:dirty_read(?DB_ROLE_BASE, RoleID),
    {TotalPage, FamilyList} = get_family_list(FactionID, FamilyID, 1, NumPerPage, [], 1),
    %%获取门派邀请列表
    Invites = db:dirty_match_object(?DB_FAMILY_INVITE, #p_family_invite_info{target_role_id=RoleID, _='_'}),
    Request = db:dirty_match_object(?DB_FAMILY_REQUEST, #p_family_request_info{role_id=RoleID, _='_'}),
    %%获取本国门派第一页
    R = #m_family_panel_toc{requests=Request, invites=Invites, family_list=FamilyList, total_page=TotalPage},
    common_misc:unicast(Line, RoleID, Unique, Module, Method, R).


%%申请加入门派
do_request(FamilyID, {Unique, Module, Method, Record, RoleID, PID, Line}) ->
    %% 特殊任务事件
    catch common_misc:send_to_rolemap(RoleID,{hook_mission_event,{special_event,RoleID,?MISSON_EVENT_JOIN_FAMILY}}),
    case router_to_family_process(FamilyID, {Unique, Module, Method, Record, RoleID, PID, Line}) of
        ok ->
            ok;
        error ->
            Reason = ?_LANG_FAMILY_THE_REQUEST_FAMILY_NOT_EXIST,
            R = #m_family_request_toc{succ=false, reason=Reason},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R)
    end.

%%将消息路由到门派进程
router_to_family_process(FamilyID, Info) when is_integer(FamilyID) ->
    ProcessName = common_misc:make_family_process_name(FamilyID),
    case global:whereis_name(ProcessName) of
        undefined ->
            register_family(FamilyID),
            do_send_to_family_process(ProcessName, Info);
        PID ->
            erlang:send(PID, Info),
            ok
    end.
do_send_to_family_process(ProcessName, Info) when is_list(ProcessName)->
    case global:whereis_name(ProcessName) of
        undefined ->
            ?ERROR_MSG("~ts:~w ~w", ["没有找到门派进程", ProcessName, Info]),
            error;
        _ ->
            global:send(ProcessName, Info),
            ok
    end.


do_reduce_role_silver_for_create_successful(RoleID, RoleAttr) ->
    case get_create_family_request(RoleID) of
        undefined ->
            ok;
        {Unique, Module, Method, {FamilyName, PublicNotice, PrivateNotice ,IsInvite}, PID,_Line} ->
            case db:transaction(fun() -> t_do_create(RoleID, FamilyName, PublicNotice, PrivateNotice) end) of
                {atomic, FamilyInfo} ->
                    mod_family:add_family_join_times(RoleID),
                    FamilyID = FamilyInfo#p_family_info.family_id,
                    register_family(FamilyID),
                    FamilyName = FamilyInfo#p_family_info.family_name,
                    {ok, RoleBase} = common_misc:get_dirty_role_base(RoleID),
                    mod_family:notify_world_update({RoleID, join_family,FamilyID,FamilyName,FamilyInfo#p_family_info.level}),
                    RoleName = RoleBase#p_role_base.role_name,
                    gene_family_list_no_loop([FamilyInfo#p_family_info.faction_id]),
                    %% 发送门派开通信件
                    Letter = common_letter:create_temp(?FAMILY_CREATE_FAMILY_LETTER,[RoleName, FamilyName]),
                    common_letter:sys2p(RoleID, Letter, "成功创建门派的通知", 14),
                    Content = lists:flatten(io_lib:format("~s ~s ~s ~s", ["玩家[", RoleName, "]创建了门派", FamilyName])),
                    %%邀请好友
                    if IsInvite ->
                            RoleList = invite_join_family(RoleID),
                            lists:foreach(fun(TargetRole)->
                                            {_TargetRoleID,TargetRoleName}=TargetRole,
                                            Record=#m_family_invite_tos{role_name=TargetRoleName},
                                            router_to_family_process(FamilyID, {Unique, Module, ?FAMILY_INVITE, Record, RoleID, PID, _Line})
                                            end,RoleList);
                       true->
                            ignore
                    end,
                    %%广播通知所有的好友
                    FList = mod_friend_server:get_dirty_friend_list(RoleID),
                    RF = #m_friend_create_family_toc{role_id=RoleID, family_id=FamilyID, family_name=FamilyName},
                    lists:foreach(
                      fun(#r_friend{friendid=FID}) ->
                              common_misc:unicast({role, FID}, ?DEFAULT_UNIQUE, ?FRIEND, ?FRIEND_CREATE_FAMILY, RF)
                      end, FList),
                    %%需要世界广播
                    common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE, Content),
                    hook_family_change:hook({RoleID, FamilyID, 0}),
                    %% 成就 add by caochuncheng 2011-03-08
                    common_hook_achievement:hook({family_module,{agree,RoleID,FamilyID,RoleBase}}),
                    
                    hook_family:create(FamilyInfo),
                    common_title:add_title(?TITLE_FAMILY,RoleID,?FAMILY_TITLE_OWNER),
                    %%end	    
                    R = #m_family_create_toc{family_info=FamilyInfo, 
                                             new_silver=RoleAttr#p_role_attr.silver,
                                             new_silver_bind=RoleAttr#p_role_attr.silver_bind,
                                             new_gold = RoleAttr#p_role_attr.gold,
                                             new_gold_bind = RoleAttr#p_role_attr.gold_bind},
                    common_misc:unicast2(PID, Unique, Module, Method, R);
                {aborted, ErrorInfo} ->
                    case erlang:is_binary(ErrorInfo) of
                        true ->
                            Reason = ErrorInfo;
                        false ->
                            Reason = ?_LANG_SYSTEM_ERROR
                    end,
                    ?ERROR_MSG("创建门派失败:RoleID=~w,ErrorInfo=~w", [RoleID, ErrorInfo]),
                    do_create_error(Unique, Module, Method, Reason, PID)
            end,
            erase_create_family_request(RoleID)
    end.

do_reduce_role_silver_for_create_failed(RoleID, Reason) ->
    case get_create_family_request(RoleID) of
        undefined ->
            ignore;
        {Unique, Module, Method, {_FamilyName, _PublicNotice, _PrivateNotice,_IsInvite}, PID,_Line} ->
            do_create_error(Unique, Module, Method, Reason, PID),
            erase_create_family_request(RoleID)
    end,
    ok.

%%创建门派
do_create(Unique, Module, Method, Record, RoleID, PID, Line) ->
    #m_family_create_tos{family_name=FamilyNameTmp, public_notice=PublicNotice, 
                         private_notice=PrivateNotice,is_invite=IsInvite} = Record,
    FamilyName = filter_family_name(FamilyNameTmp),
    %%检查门派名称，检查门派内外公告，检查是否满足创建条件
    case check_name(FamilyName) of
        ok ->
            case check_notice(PublicNotice, PrivateNotice) of
                ok ->
                    %%先检查其他创建条件
                    case check_create_condition(RoleID) of
                        ok->
                            do_create2(Unique, Module, Method, 
                                       {FamilyName, PublicNotice, PrivateNotice,IsInvite}, RoleID, PID,Line);
                        {error,Reason}->
                            do_create_error(Unique, Module, Method, Reason, PID)
                    end;
                {error, Reason} ->
                    do_create_error(Unique, Module, Method, Reason, PID)
            end;
        {error, Reason} ->
            do_create_error(Unique, Module, Method, Reason, PID)
    end.
do_create2(Unique, Module, Method, {FamilyName, PublicNotice, PrivateNotice,IsInvite}, RoleID, PID,Line) ->
    case get_create_family_request(RoleID) of
        undefined ->
            %% 异步消息给地图
            [UseFeeType] = common_config_dyn:find(family_base_info,use_fee_type),
            if UseFeeType =:= 1 ->
                    [CreateFamilyGold] = common_config_dyn:find(family_base_info,create_family_gold),
                    common_role_money:reduce(RoleID, [{gold,CreateFamilyGold,?CONSUME_TYPE_GOLD_CREATE_FAMILY,""}],
                                             ?REDUCE_SILVER_FOR_CREATE_FAMILY,?REDUCE_SILVER_FOR_CREATE_FAMILY);
               true ->
                    [CreateFamilySilver] = common_config_dyn:find(family_base_info,create_family_silver),
                    common_role_money:reduce(RoleID, [{silver_any,CreateFamilySilver,?CONSUME_TYPE_SILVER_CREATE_FAMILY,""}],
                                             ?REDUCE_SILVER_FOR_CREATE_FAMILY,?REDUCE_SILVER_FOR_CREATE_FAMILY)
            end,
            set_create_family_request(RoleID, {Unique, Module, Method, {FamilyName, PublicNotice, PrivateNotice,IsInvite}, PID,Line});
        _ ->
            do_create_error(Unique, Module, Method, ?_LANG_FAMILY_CREATE_REQUEST_IN_PROCESS, PID)
    end.

%%@doc 检查创建门派的条件,非事务实现
check_create_condition(RoleID)->
    [#p_role_attr{level=RoleLevel}] = db:dirty_read(?DB_ROLE_ATTR, RoleID),
    [MinLevelCreateFamily] = common_config_dyn:find(family_base_info,min_level_create_family),
    %% 检查玩家等级
    case RoleLevel >= MinLevelCreateFamily of
        true ->
            [RoleBase] = db:dirty_read(?DB_ROLE_BASE, RoleID),
            %%检查是否已经有门派了
            case RoleBase#p_role_base.family_id > 0 of
                false ->
                    case mod_family:is_special_family_date() of
                        true->
                            case mod_family:can_join_family_in_special_date(RoleID) of
                                true->
                                    ok;
                                _ ->
                                    {error,"今天最多可以加入或创建3个门派"}
                            end;
                        _ ->
                            %%检查上一次离开门派的时间
                            case do_check_last_op_time(RoleID) of
                                true->
                                    ok;
                                _ ->
                                    {error,?_LANG_FAMILY_LAST_OP_TIME_CREATE_LIMIT}
                            end
                    end;
                true ->
                    {error,?_LANG_FAMILY_ALREAD_HAS_A_FAMILY_WHEN_CREATE}
            end;
        _ ->
            Err = common_tool:to_binary(io_lib:format(?_LANG_FAMILY_LEVE_NOT_ENOUGH_WHEN_CREATE, [MinLevelCreateFamily])),
            {error,Err}
    end.


%% 保存玩家请求创建门派信息
set_create_family_request(RoleID, {Unique, Module, Method, {FamilyName, PublicNotice, PrivateNotice,IsInvite}, PID,Line}) ->
    erlang:put({create_family_request, RoleID}, {Unique, Module, Method, {FamilyName, PublicNotice, PrivateNotice,IsInvite}, PID,Line}).
get_create_family_request(RoleID) ->
    erlang:get({create_family_request, RoleID}).
erase_create_family_request(RoleID) ->
    erlang:erase({create_family_request, RoleID}).

do_create_error(Unique, Module, Method, Reason, PID) ->
    R = #m_family_create_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, R).


%%成功则返回门派的ID
t_do_create(RoleID, FamilyName, PublicNotice, PrivateNotice) ->
    %%扣玩家银两，修改玩家属性
    [#p_role_attr{office_name=OfficeName, level=RoleLevel}] = db:read(?DB_ROLE_ATTR, RoleID, write),
    %% 玩家等级可以直接读取，因为玩家升级时一定会进行持久化
    
    [RoleBase] = db:read(?DB_ROLE_BASE, RoleID, write),
    [#r_family_counter{value=LID}] = db:read(?DB_FAMILY_COUNTER, 1, write),
    FamilyID = LID + 1,
    NewRoleBase = RoleBase#p_role_base{family_id=FamilyID, family_name=FamilyName},
    #p_role_base{role_name=RoleName, faction_id=FactionID, sex=Sex, head=Head} = NewRoleBase,
    NewM = #p_family_member_info{role_id=RoleID, role_name=RoleName,
                                 sex=Sex, head=Head, office_name=OfficeName, family_contribution=0,
                                 role_level= RoleLevel,
                                 online=true, title=?FAMILY_TITLE_OWNER},
    Members = [NewM],
    [DefaultCreateFamilyLevel] = common_config_dyn:find(family_base_info,default_create_family_level),
    [IsCreateFamilyMap] = common_config_dyn:find(family_base_info,is_create_family_map),
    FamilyRecord = #p_family_info{family_id=FamilyID, family_name=FamilyName, 
                                  owner_role_id=RoleID, owner_role_name=RoleName,
                                  faction_id=FactionID, level=DefaultCreateFamilyLevel, create_role_id=RoleID,
                                  create_role_name=RoleName, cur_members=1, enable_map=IsCreateFamilyMap,
                                  kill_uplevel_boss=false, uplevel_boss_called=false,
                                  second_owners=[], active_points=0, money=0, 
                                  request_list=[], invite_list=[],members=Members,  
                                  ybc_type=0, ybc_creator_id=0,
                                  gongxun=0,
                                  public_notice=PublicNotice, private_notice=PrivateNotice},
    db:write(?DB_FAMILY_EXT, 
             #r_family_ext{family_id=FamilyID, last_resume_time=0, 
                           common_boss_called=false, 
                           common_boss_killed=false}, 
             write),
    db:write(?DB_FAMILY, FamilyRecord, write),
    db:write(?DB_ROLE_BASE, NewRoleBase, write),
    db:write(?DB_FAMILY_COUNTER, #r_family_counter{id=1, value=FamilyID}, write),
    FamilyRecord.


%%检查常见的门派名称是否合法
check_name(FamilyName) ->
    case erlang:length(FamilyName) < 2 of
        true ->
            {error, ?_LANG_FAMILY_NAME_MUST_MORE_THAN_ONE};
        false ->
            %%是否重名
            Sql = lists:flatten(io_lib:format("select family_id from t_family_summary where family_name='~s';", [FamilyName])),
            case mod_mysql:select(Sql) of
                {ok, []} ->
                    ok;
                _ ->
                    {error, ?_LANG_FAMILY_NAME_DUPLICATEED}
            end
    end.


%%检查门派的内外公告
check_notice(_PublicNotice, _PrivateNotice) ->
    ok.


%%过滤门派名称
filter_family_name(FamilyNameTmp) ->
    string:strip(FamilyNameTmp).

%%@doc 初始化所有门派的田地，默认为一个门派10块田地
do_init_all_family_farm()->
    case db:dirty_read(?DB_FAMILY_PLANT) of
        []->
            do_init_all_family_farm_2();
        _ ->
            has_been_inited
    end.

do_init_all_family_farm_2()->
    MatchHead = #p_family_info{family_id='$1', _='_'},
    Guard = [],
    FamilyIDList = db:dirty_select(?DB_FAMILY, [{MatchHead, Guard, ['$1']}]),
    
    %%默认10个已开垦的土地
    FarmList = mod_family:get_default_farm_list(),
    lists:foreach(fun(ID)-> 
                          R = #r_family_plant{family_id=ID,farm_list=FarmList,max_farm_id=?DEFAULT_FARM_SIZE},
                          db:dirty_write(?DB_FAMILY_PLANT,R)  
                  end, FamilyIDList),
    ok.

%%@doc 离开门派当天，创建不能再新门派
do_check_last_op_time(RoleID) ->
    [#p_role_ext{family_last_op_time=LastOpTime}]= db:dirty_read(?DB_ROLE_EXT,RoleID),
    case is_integer(LastOpTime) andalso LastOpTime>0 of
        true->
            {Date,_Time} = common_tool:seconds_to_datetime(LastOpTime),
            Date =/= date();
        false->
            true
    end.

invite_join_family(RoleID)->
    {RoleList1,RestNum1}=get_clan(RoleID,30),
    if RestNum1>0 ->
            {RoleList2,_RestNum2}=get_friend(RoleList1,RoleID,RestNum1),
            RoleList1++RoleList2;
        true->
            RoleList1
    end.
            
%%同门
get_clan(RoleID,Num)->
    [RoleEduInfo]=db:dirty_read(?DB_ROLE_EDUCATE,RoleID),
    Teacher=RoleEduInfo#r_educate_role_info.teacher,
    RoleIDList1 = 
        if Teacher =:=undefined ->
            [];
        true->
            [TeacherEduInfo]=db:dirty_read(?DB_ROLE_EDUCATE,Teacher),
            lists:delete(RoleID,TeacherEduInfo#r_educate_role_info.students)
    end,
    filter_list([],RoleIDList1,Num).

%%好友
get_friend(RoleIDList,RoleID,Num)->
    RoleFriendList1 = mod_friend_server:get_dirty_friend_list(RoleID),
    RoleIDList1 = [Friend#r_friend.friendid||Friend<-RoleFriendList1],
    filter_list(RoleIDList,RoleIDList1,Num).


filter_list(OldList,NewList,Num)->
    NewList1 =lists:foldr(fun(RoleID,Acc)-> 
                    case common_misc:is_role_online(RoleID) of
                        false->Acc;
                        true->
                            {ok,RoleBase} = common_misc:get_dirty_role_base(RoleID),
                            case RoleBase#p_role_base.family_id=:=0 of
                                true->  
                                        {ok,RoleAttr} = common_misc:get_dirty_role_attr(RoleID),
                                        Level= RoleAttr#p_role_attr.level,
                                        RoleName = RoleAttr#p_role_attr.role_name,
                                        case Level>9 of
                                            true->[{Level,RoleID,RoleName}|Acc];
                                            false->Acc
                                        end;
                                false->Acc
                            end
                    end
                end, [], NewList),
    NewList2 = lists:sort(fun(E1,E2)-> {L1,_,_}=E1,{L2,_,_}=E2,L1>L2 end,NewList1),
    NewList3=[begin {_,RoleID,RoleName}=E,{RoleID,RoleName} end ||E<-NewList2],
    NewList4 = lists:filter(fun(E2)->lists:all(fun(E1)-> E1=/=E2 end ,OldList) end,NewList3),

    if length(NewList4) <Num ->
            {NewList4,Num-length(NewList4)};
        true->
            {List1,_List2}= lists:split(Num,NewList4),
            {List1,0}
    end.
