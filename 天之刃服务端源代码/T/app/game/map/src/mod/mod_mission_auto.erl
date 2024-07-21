%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     自动任务(委托任务)
%%% @end
%%% Created : 2011-4-20
%%%-------------------------------------------------------------------
-module(mod_mission_auto).

%%
%% Include files
%%
-include("mission.hrl").

%%
%% Exported Functions
%%
-export([handle_list_auto/1,
         handle_do_auto/1]).

-export([check_auto_mission_finish/1,
         check_doing_auto_mission/2]).

%%
%% API Functions
%%


-define(MISSION_UNICAST_TOC(DataRecordReturn),
        mod_mission_unicast:p_unicast(RoleID, Unique, Module, Method, DataRecordReturn),
        mod_mission_unicast:c_unicast(RoleID, Line)).

-define(MISSION_COMMIT_UNICAST(RoleID),
        mod_mission_unicast:c_unicast(RoleID),
        mod_mission_misc:c_trans_func(RoleID)).

-define(MISSION_ROLLBACK_UNICAST(RoleID),
        mod_mission_unicast:r_unicast(RoleID),
        mod_mission_misc:r_trans_func(RoleID)).

%% @doc 检查是否真正做指定的委托任务
check_doing_auto_mission(RoleID,BigGroup)->
    RoleAutoList = mod_mission_data:get_role_auto_list(RoleID),
    case is_list(RoleAutoList) of
        true->
            lists:any(
              fun(#r_role_mission_auto{id=AutoID})-> 
                      [#r_mission_auto_conf{big_group=BigGroupCnf}] = common_config_dyn:find(mission_auto,AutoID),
                      BigGroupCnf =:= BigGroup
              end, RoleAutoList);
        _ ->
            false
    end.

%% @doc 在玩家登陆的时候，检查自动任务是否已经完成
check_auto_mission_finish(RoleID)->
    RoleAutoList = mod_mission_data:get_role_auto_list(RoleID),
    case is_list(RoleAutoList) of
        true->
            lists:foreach(fun(RInfo)-> 
                              check_auto_mission_finish_2(RoleID,RInfo)
                          end, RoleAutoList);
        _ ->
            ignore
    end.
check_auto_mission_finish_2(RoleID,RInfo)->
    Now = common_tool:now(),
    #r_role_mission_auto{mission_auto=PAutoInfo}=RInfo,
    #p_mission_auto{start_time=StartTime,end_time=EndTime} = PAutoInfo,
    if
        (StartTime>0) andalso (Now>=EndTime) ->
            %%实际已完成了委托任务
            TransFun = fun()-> t_do_auto_finish(RoleID,PAutoInfo,false) end,
            case common_transaction:transaction(TransFun) of
                {atomic,_}->
                    ?MISSION_COMMIT_UNICAST(RoleID),
                    ok;
                {aborted,Error}->
                    ?MISSION_ROLLBACK_UNICAST(RoleID),
                    ?ERROR_MSG("handle_do_auto error,Error=~w",[Error]),
                    error
            end;
        true->
            ignore
    end.

%% 获取所有的符合条件的自动任务列表
%% @return [#r_mission_auto_conf]
get_auto_conf_list(RoleID)->
    {ok,#p_role_base{faction_id=RoleFaction}} = mod_map_role:get_role_base(RoleID),
    {ok,#p_role_attr{level=RoleLevel}} = mod_map_role:get_role_attr(RoleID),
    AllAutoList = common_config_dyn:list(mission_auto),
    lists:foldl(
      fun(#r_mission_auto_conf{faction_id=MFactionID,min_level=MinLevel}=E,Acc) 
           when (MFactionID =:= RoleFaction) andalso (RoleLevel>=MinLevel)-> 
              [E|Acc];
         (_,Acc)->
              Acc
      end, [], AllAutoList).

handle_list_auto({Unique, Module, Method, _DataIn, RoleID, Line})->
    AutoConfList = get_auto_conf_list(RoleID),
    {ok,#p_role_attr{level=RoleLevel}} = mod_map_role:get_role_attr(RoleID),
    List = lists:foldl(
             fun(E,AccIn)-> 
                     case check_auto_mission_status(RoleID,E) of
                         {error,Err}->
                             ?ERROR_MSG("handle_list_auto,Err=~w",[Err]),
                             AccIn;
                         {Status,MissionID,CommitTimes,MaxDoTimes,RollBackTimes} when is_integer(MissionID)->
                             AutoConf2 = E#r_mission_auto_conf{mission_id=MissionID},
                             PAutoInfo = auto_conf_2_p(AutoConf2,Status,AutoConf2#r_mission_auto_conf.loop_times,
                                                       RoleLevel,CommitTimes,MaxDoTimes,RollBackTimes),
                             [PAutoInfo|AccIn];
                         {?MISSION_AUTO_STATUS_FINISH,PAutoInfo,_CommitTimes,_MaxDoTimes,_RollBackTimes}->
                             %%在获取列表的同时，处理已完成的委托任务
                             hand_list_auto_2(RoleID,PAutoInfo),
                             [PAutoInfo#p_mission_auto{status = ?MISSION_AUTO_STATUS_FINISH}|AccIn];
                         {_Status,PAutoInfo,_CommitTimes,_MaxDoTimes,_RollBackTimes}->
                             [PAutoInfo|AccIn]
                     end
             end, [], AutoConfList),
    R2 = #m_mission_list_auto_toc{list=List},
    ?MISSION_UNICAST_TOC(R2).

hand_list_auto_2(RoleID,PAutoInfo)->
    TransFun = fun()-> t_do_auto_finish(RoleID,PAutoInfo,true) end,
    case common_transaction:transaction(TransFun) of
        {atomic,{ok,_AutoInfo}}->
            mod_mission_handler:reload_pinfo_list(RoleID),
            ?MISSION_COMMIT_UNICAST(RoleID),
            ok;
        {aborted,Error}->
            ?MISSION_ROLLBACK_UNICAST(RoleID),
            ?ERROR_MSG("handle_do_auto error,Error=~w",[Error])
    end.


handle_do_auto({Unique, Module, Method, DataIn, RoleID, Line})->
    #m_mission_do_auto_tos{id=AutoID,loop_times = LoopTimes} = DataIn, 
    case check_auto_mission_status(RoleID,AutoID) of
        {?MISSION_AUTO_STATUS_MAX_LIMIT,_,_,_,_}->
            R2 = #m_mission_do_auto_toc{id=AutoID,code=?MISSION_AUTO_CODE_FAIL_MAX_LIMIT};
        {?MISSION_AUTO_STATUS_NOT_START,MissionID,CommitTimes,MaxDoTimes,RollBackTimes}->
            TransFun = fun()-> t_do_auto_start(RoleID,AutoID,LoopTimes,MissionID,
                                               CommitTimes,MaxDoTimes,RollBackTimes) end,
            case common_transaction:transaction(TransFun) of
                {atomic,{ok,PAutoInfo}}->
                    #p_mission_auto{name=MissionName} = PAutoInfo,
                    ?MISSION_COMMIT_UNICAST(RoleID),
                    broadcast_auto_mission(AutoID,RoleID,MissionName),
                    mod_mission_handler:reload_pinfo_list(RoleID),
                    R2 = #m_mission_do_auto_toc{id=AutoID,auto_info=PAutoInfo,code=?MISSION_AUTO_CODE_SUCC};
                {aborted,{gold_not_enough}}->
                    ?MISSION_ROLLBACK_UNICAST(RoleID),
                    R2 = #m_mission_do_auto_toc{id=AutoID,code=?MISSION_AUTO_CODE_FAIL_GOLD_NOT_ENOUGH};
                {aborted,{max_limit}} ->
                    ?MISSION_ROLLBACK_UNICAST(RoleID),
                    R2 = #m_mission_do_auto_toc{id=AutoID,code=?MISSION_AUTO_CODE_FAIL_MAX_LIMIT};
                {aborted,{not_times}} ->
                    ?MISSION_ROLLBACK_UNICAST(RoleID),
                    R2 = #m_mission_do_auto_toc{id=AutoID,code=?MISSION_AUTO_CODE_FAIL_PARAM_LOOP_TIMES};
                {aborted,Error}->
                    ?MISSION_ROLLBACK_UNICAST(RoleID),
                    ?ERROR_MSG("handle_do_auto error,Error=~w",[Error]),
                    R2 = #m_mission_do_auto_toc{id=AutoID,code=?MISSION_AUTO_CODE_FAIL_SYS}
            end;
        {?MISSION_AUTO_STATUS_FINISH,PAutoInfo,_CommitTimes,_MaxDoTimes,_RollBackTimes}->
            TransFun = fun()-> t_do_auto_finish(RoleID,PAutoInfo,true) end,
            case common_transaction:transaction(TransFun) of
                {atomic,{ok,AutoInfo}}->
                    mod_mission_handler:reload_pinfo_list(RoleID),
                    ?MISSION_COMMIT_UNICAST(RoleID),
                    R2 = #m_mission_do_auto_toc{id=AutoID,auto_info=AutoInfo,code=?MISSION_AUTO_CODE_SUCC};
                {aborted,Error}->
                    ?MISSION_ROLLBACK_UNICAST(RoleID),
                    ?ERROR_MSG("handle_do_auto error,Error=~w",[Error]),
                    R2 = #m_mission_do_auto_toc{id=AutoID,code=?MISSION_AUTO_CODE_FAIL_SYS}
            end;
        {?MISSION_AUTO_STATUS_DOING,PAutoInfo,_CommitTimes,_MaxDoTimes,_RollBackTimes} ->
            R2 = #m_mission_do_auto_toc{id=AutoID,auto_info=PAutoInfo,code=?MISSION_AUTO_CODE_SUCC};
        {error,Reason}->
            ?ERROR_MSG("handle_do_auto error,Error=~w",[Reason]),
            R2 = #m_mission_do_auto_toc{id=AutoID,code=?MISSION_AUTO_CODE_FAIL_SYS}
    end,
    ?MISSION_UNICAST_TOC(R2).


%%开始执行自动任务
%%@return {ok,PAutoInfo}
t_do_auto_start(RoleID,AutoID,LoopTimes,MissionID,CommitTimes,MaxDoTimes,RollBackTimes)->
    case CommitTimes >= MaxDoTimes of
        true -> %% 今天此循环任务已经全部完成不可以再委托
            common_transaction:abort({max_limit});
        _ ->
            next
    end,
    case LoopTimes > 0 of
        true ->
            next;
        _ ->
            common_transaction:abort({not_times})
    end,
    case LoopTimes > (MaxDoTimes - CommitTimes) of
        true -> %% 委托次数大于可委托次数
            common_transaction:abort({max_limit});
        _ ->
            next
    end,
    %%     如果没有开始，则执行委托任务，并扣除元宝。
    [AutoConf] = common_config_dyn:find(mission_auto,AutoID),
    AutoConf2 = AutoConf#r_mission_auto_conf{mission_id=MissionID},
    {ok,#p_role_attr{level = RoleLevel}} = mod_map_role:get_role_attr(RoleID),
    #p_mission_auto{need_gold=NeedGold} = PAutoInfo = auto_conf_2_p(AutoConf2,?MISSION_AUTO_STATUS_DOING,
                                                                    LoopTimes,RoleLevel,CommitTimes,MaxDoTimes,RollBackTimes),
    Fee = NeedGold * LoopTimes,
    {ok,DeductGoldBind,DeductGold,Func} = t_deduct_gold(RoleID,Fee),
    mod_mission_misc:push_trans_func(RoleID,Func),
    
    RoleAutoList = mod_mission_data:get_role_auto_list(RoleID),
    NewMissionAuto = #r_role_mission_auto{id=AutoID,mission_auto=PAutoInfo,deduct_gold=DeductGold,
                                          deduct_gold_bind=DeductGoldBind},
    List2 = lists:keystore(AutoID, #r_role_mission_auto.id, RoleAutoList, NewMissionAuto),
    mod_mission_data:set_role_auto_list(RoleID,List2),
    {ok,PAutoInfo}.

%%处理已经完成的自动任务
%%@return {ok,PAutoInfo}
t_do_auto_finish(RoleID,PAutoInfo,ShouldNotify)->
    %%    如果已经完成，则执行奖励，并删除任务。
    #p_mission_auto{id=AutoID,mission_id=MissionID,loop_times=LoopTimes,start_time = StartTime} = PAutoInfo,
    MissionBaseInfo = mod_mission_data:get_base_info(MissionID),
    
    Module = mod_mission_auto_reward:new(RoleID, MissionID, MissionBaseInfo),
    Module:give_auto(PAutoInfo),
    
    case ShouldNotify of
        true->
            update_mission_auto(RoleID,MissionID);
        _ ->
            ignore
    end,
    hook_mission_finish(RoleID,MissionBaseInfo,LoopTimes),
    
    
    List1 = mod_mission_data:get_role_auto_list(RoleID),
    List2 = lists:keydelete(AutoID, #r_role_mission_auto.id, List1),
    mod_mission_data:set_role_auto_list(RoleID,List2),
    
    %% 判断是否是昨天委托的任务
    {NowDate,_NowTime} = common_tool:seconds_to_datetime(mgeem_map:get_now()),
    TodaySeconds = common_tool:datetime_to_seconds({NowDate,{0,0,0}}),
    case StartTime >= TodaySeconds of
        true ->
            ignore;
        _ -> %% 昨天委托的任务需要重置玩家循环任务次数
            mod_mission_data:set_succ_times(RoleID, MissionBaseInfo, -LoopTimes)
    end,
    {Status,_CommitTimes,_MaxDoTimes,_RollBackTimes} = get_auto_mission_loop_status(RoleID,MissionID,LoopTimes),
    AutoInfo2 = PAutoInfo#p_mission_auto{status=Status},
    {ok,AutoInfo2}.

hook_mission_finish(RoleID,MissionBaseInfo,LoopTimes)->
    #mission_base_info{id=MissionID,type=MissionType,big_group=BigGroup,small_group=SmallGroup} = MissionBaseInfo,
    
    MissionHookRecord =  
        #r_mission_hook{role_id = RoleID,
                        mission_id = MissionID,
                        mission_type = MissionType,
                        big_group = BigGroup,
                        small_group = SmallGroup,
                        do_type = 1, %%执行类型: 0正常 1委托(自动任务)
                        do_times = LoopTimes},
    ?TRY_CATCH (common_hook_achievement:hook({mod_mission,{mission_commit,MissionHookRecord}}),ErrAchv).


%%委托任务的广播
broadcast_auto_mission(AutoID,RoleID,MissionName) ->
    [#r_mission_auto_conf{is_broadcast=IsBroadcast}] = common_config_dyn:find(mission_auto,AutoID),
    if
        IsBroadcast=:=true->
            broadcast_auto_mission_2(RoleID,MissionName);
        true->
            ignore
    end.
broadcast_auto_mission_2(RoleID,MissionName)->
    case mod_map_role:get_role_base(RoleID) of
        {ok, RoleBase} ->
            RoleName= common_misc:get_role_name_color(RoleBase#p_role_base.role_name,RoleBase#p_role_base.faction_id),            
            NotifyChat = common_misc:format_lang( ?_LANG_MISSION_AUTO_ACCEPT_BC_CHAT, [RoleName,MissionName]),            
            common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT, ?BC_MSG_TYPE_CHAT_WORLD, NotifyChat);
        _ ->
            ignore
    end.


%%@doc 更新委托任务的循环任务的数量到Client
update_mission_auto(RoleID,MissionID)->
    #mission_base_info{big_group=BigGroup} = mod_mission_data:get_base_info(MissionID),
    OldPInfoList = mod_mission_data:get_pinfo_list(RoleID),
    
    update_mission_auto_2(RoleID,BigGroup,OldPInfoList).

update_mission_auto_2(_RoleID,_BigGroup,[])->
    ignore;
update_mission_auto_2(RoleID,BigGroup,[OldPInfo|T])->
    #p_mission_info{id=OldMissionID,type=Type} = OldPInfo,
    if
        Type=:= ?MISSION_TYPE_LOOP->
            case mod_mission_data:get_base_info(OldMissionID) of
                #mission_base_info{big_group=BigGroup} ->
                    case b_mission_model:call_mission_model(RoleID, OldMissionID, init_pinfo, [OldPInfo]) of
                        false ->
                            ignore;
                        NewPInfo ->
                            mod_mission_data:set_pinfo(RoleID, NewPInfo, notify)
                    end;
                _ ->
                    update_mission_auto_2(RoleID,BigGroup,T)
            end;
        true->
            update_mission_auto_2(RoleID,BigGroup,T)
    end.


%% ====================================================================
%% Internal functions
%% ====================================================================

%% 扣除元宝
%%@return {ok,DeductGoldBind,DeductGold,Func} | error
t_deduct_gold(RoleID,Fee) when Fee>0 ->
    {ok,RoleAttr1} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{gold = OldGold} = RoleAttr1,
    NewGold = OldGold-Fee,
    if NewGold < 0 ->
           common_transaction:abort({gold_not_enough}),
           error;
       true ->
           RoleAttr2 = RoleAttr1#p_role_attr{gold= NewGold },
           mod_map_role:set_role_attr(RoleID,RoleAttr2),
           Func = {func,fun()-> 
                                common_misc:send_role_gold_change(RoleID,RoleAttr2)
                   end},
           common_consume_logger:use_gold({RoleID, 0, Fee, ?CONSUME_TYPE_GOLD_AUTO_MISSION, ""}),
           {ok,0,Fee,Func}
    end.


%%@doc 将配置的委托数据转换为玩家的初始化委托任务数据
auto_conf_2_p(AutoConf,Status,LoopTimes,RoleLevel,CommitTimes,MaxDoTimes,RollBackTimes) 
  when is_record(AutoConf,r_mission_auto_conf)->
    #r_mission_auto_conf{id=ID,name=Name,total_time=TotalTime,need_gold=NeedGold,
                         mission_id=MissionID,big_group = BigGroup,min_level = MinLevel}=AutoConf,
    StartTime = common_tool:now(),
    EndTime = StartTime + LoopTimes * TotalTime,
    case MaxDoTimes - CommitTimes < 0 of
        true ->
            MaxLoopTimes = 0;
        _ ->
            MaxLoopTimes = MaxDoTimes - CommitTimes
    end,
    #p_mission_auto{id=ID,name=Name,
                    mission_id=MissionID,big_group = BigGroup,
                    loop_times=LoopTimes,loop_one_time = TotalTime,
                    status=Status,
                    start_time=StartTime,end_time = EndTime,
                    need_gold=NeedGold,min_level =MinLevel,
                    max_loop_times = MaxLoopTimes,
                    role_level = RoleLevel,
                    rollback_times = RollBackTimes,
                    cur_times = CommitTimes}.

%%获取委托任务对应的具体任务ID
get_auto_mission_id(RoleID,BigGroup)->
    case mod_mission_data:get_mission_by_big_group(RoleID,BigGroup) of
        #mission_base_info{id=Id}->
            Id;
        _ ->
            {error,big_group_not_found}
    end.

%%检查委托任务的有效状态
get_auto_mission_loop_status(RoleID,MissionID,LoopTimes)->
    #mission_base_info{max_do_times=MaxDoTimes,reward_data=RewardData} = MissionBaseInfo = mod_mission_data:get_base_info(MissionID),
    CommitTimes = mod_mission_data:get_commit_times(RoleID, MissionBaseInfo),
    case (LoopTimes+CommitTimes)>MaxDoTimes of
        true->
            {?MISSION_AUTO_STATUS_MAX_LIMIT,CommitTimes,MaxDoTimes,RewardData#mission_reward_data.rollback_times};
        _ ->
            {?MISSION_AUTO_STATUS_NOT_START,CommitTimes,MaxDoTimes,RewardData#mission_reward_data.rollback_times}
    end.


%%@return Status | {Status,PAutoInfo}
check_auto_mission_status(RoleID,AutoID) when is_integer(AutoID)->
    [AutoConf] = common_config_dyn:find(mission_auto,AutoID),
    check_auto_mission_status(RoleID,AutoConf);
check_auto_mission_status(RoleID,AutoConf) when is_record(AutoConf,r_mission_auto_conf)->
    #r_mission_auto_conf{id=AutoID,loop_times=LoopTimes,big_group=BigGroup} = AutoConf,
    case get_auto_mission_id(RoleID,BigGroup) of
        {error,Reason}->
            {error,Reason};
        MissionID ->
            case get_auto_mission_loop_status(RoleID,MissionID,LoopTimes) of
                {?MISSION_AUTO_STATUS_MAX_LIMIT,CommitTimes,MaxDoTimes,RollBackTimes}->
                    {?MISSION_AUTO_STATUS_MAX_LIMIT,MissionID,CommitTimes,MaxDoTimes,RollBackTimes};
                {_Code,CommitTimes,MaxDoTimes,RollBackTimes} ->
                    check_auto_mission_status_2(RoleID,AutoID,MissionID,CommitTimes,MaxDoTimes,RollBackTimes)
            end
    end.

check_auto_mission_status_2(RoleID,AutoID,MissionID,CommitTimes,MaxDoTimes,RollBackTimes) when is_integer(AutoID)->
    RoleAutoList = mod_mission_data:get_role_auto_list(RoleID),
    case lists:keyfind(AutoID, #r_role_mission_auto.id, RoleAutoList) of
        false->
            {?MISSION_AUTO_STATUS_NOT_START,MissionID,CommitTimes,MaxDoTimes,RollBackTimes};
        #r_role_mission_auto{mission_auto=PAutoInfo}->
            #p_mission_auto{start_time=StartTime,end_time =EndTime} = PAutoInfo,
            Now = common_tool:now(),
            if
                StartTime=:=0->
                    {?MISSION_AUTO_STATUS_NOT_START,MissionID,CommitTimes,MaxDoTimes,RollBackTimes};
                (StartTime>0) andalso (EndTime>0) andalso (Now>=EndTime) ->
                    {?MISSION_AUTO_STATUS_FINISH,PAutoInfo,CommitTimes,MaxDoTimes,RollBackTimes};
                true->
                    {?MISSION_AUTO_STATUS_DOING,PAutoInfo,CommitTimes,MaxDoTimes,RollBackTimes}
            end
    end.
