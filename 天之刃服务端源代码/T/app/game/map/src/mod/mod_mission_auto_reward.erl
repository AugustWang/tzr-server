%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     自动任务的 奖励
%%% @end
%%% Created : 2011-4-20
%%%-------------------------------------------------------------------
-module(mod_mission_auto_reward, [RoleID, MissionID, MissionBaseInfo]).

%%
%% Include files
%%
-include("mission.hrl").

%%
%% Exported Functions
%%
-export([give_auto/1]).

%%
%% API Functions
%%
%% --------------------------------------------------------------------
%% 给与奖励 返回 p_mission_reward_data
%% -------------------------------------------------------------------- 

%%@return #p_mission_reward_data{}
give_auto(AutoInfo) when is_record(AutoInfo,p_mission_auto) ->
    BigGroup = MissionBaseInfo#mission_base_info.big_group,
    if
        BigGroup =:= 0 ->
            do_give_auto_normal(AutoInfo);
        true ->
            do_give_auto_group(AutoInfo)
    end.


%%普通循环任务的奖励
do_give_auto_normal(AutoInfo) ->
    #p_mission_auto{loop_times=LoopTimes} = AutoInfo,
    BaseRewardData = MissionBaseInfo#mission_base_info.reward_data,
    AttrRewardFormula = BaseRewardData#mission_reward_data.attr_reward_formula,
    
    {PMissionRewardData, FuncList1, LetterCont} = do_give_attr_reward(AttrRewardFormula, BaseRewardData,LoopTimes),
    mod_mission_misc:push_trans_func(RoleID,FuncList1),
    
    send_auto_letter(AutoInfo,LetterCont),
    PMissionRewardData.

%%循环任务分组奖励
%%提醒一下：分组任务的奖励呢，除了prop_reward_formula这个属性值，其他都是读取group_reward.xml的配置
do_give_auto_group(AutoInfo) ->
    #p_mission_auto{loop_times=LoopTimes,role_level = RoleLevel} = AutoInfo,
    BigGroup = MissionBaseInfo#mission_base_info.big_group,
    Key = {BigGroup, RoleLevel},
    RewardList = mod_mission_data:get_setting(group_reward),
    MathReward = lists:keyfind(Key, 1, RewardList),
    {Key, Exp, SilverBind, Prestige, _PropList} = MathReward,
    
    %%分组任务，则必须是循环奖励
    BaseRewardDataTmp = MissionBaseInfo#mission_base_info.reward_data,
    BaseRewardData = BaseRewardDataTmp#mission_reward_data{attr_reward_formula=?MISSION_ATTR_REWARD_FORMULA_CALC_ALL_TIMES,
                                                           exp=Exp, 
                                                           prestige=Prestige,
                                                           silver_bind=SilverBind}, 
    AttrRewardFormula = BaseRewardData#mission_reward_data.attr_reward_formula,
    
    {PMissionRewardData, FuncList1, LetterCont} = do_give_attr_reward(AttrRewardFormula, BaseRewardData,LoopTimes),
    mod_mission_misc:push_trans_func(RoleID, FuncList1),
    
    send_auto_letter(AutoInfo,LetterCont),
    PMissionRewardData.


    
do_give_attr_reward(?MISSION_ATTR_REWARD_FORMULA_NO, _,LoopTimes) ->
    mod_mission_data:set_succ_times(RoleID, MissionBaseInfo, LoopTimes),
    
    {#p_mission_reward_data{},[],[]};
     

do_give_attr_reward(?MISSION_ATTR_REWARD_FORMULA_CALC_ALL_TIMES, BaseRewardData,LoopTimes) ->
    #mission_reward_data{rollback_times=RollBackTimes,
                         exp=AddExp,
                         silver=AddSilver,
                         silver_bind=AddSilverBind,
                         prestige=Prestige} = BaseRewardData,
    CurDoneTimes = mod_mission_data:get_succ_times(RoleID, MissionBaseInfo),
    
    {ExpSum,SilverSum,SilverBindSum,PrestigeSum,LetterContent1} = 
        lists:foldl(fun(E,AccIn)-> 
                            {ExpSum,SilverSum,SilverBindSum,PrestigeSum,LettAccIn} = AccIn,
                            DoneTimes = CurDoneTimes+E,
                            case DoneTimes>RollBackTimes of
                                true->
                                    MultTimes = 1;
                                _ ->
                                    MultTimes = DoneTimes
                            end,
                            
                            ToAddExp = AddExp*MultTimes,
                            ToAddSilver = AddSilver*MultTimes,
                            ToAddSilverBind = AddSilverBind*MultTimes,
                            ToPrestige = Prestige*MultTimes,
                            LetterCont = append_letter_text(LettAccIn,DoneTimes,{ToAddExp,ToAddSilver,ToAddSilverBind,ToPrestige}),
                            
                            {(ExpSum+ToAddExp),
                             (SilverSum+ToAddSilver),(SilverBindSum+ToAddSilverBind),
                             (PrestigeSum + ToPrestige),LetterCont}
                    
                    end, {0,0,0,0,""}, lists:seq(1, LoopTimes)),
    LetterContent2 = lists:concat([LetterContent1,"\n\n小提示：前",RollBackTimes,"次经验奖励随着次数而翻倍。"]),
    mod_mission_data:set_succ_times(RoleID, MissionBaseInfo, LoopTimes),
   
    {R,Func1} = do_give_attr_reward_2({ExpSum, SilverSum, SilverBindSum,PrestigeSum}),
    {R,Func1,LetterContent2}.


append_letter_text(LettAccIn,DoneTimes,{ToAddExp,ToAddSilver,ToAddSilverBind,ToPrestige})->
    L1 = lists:concat([LettAccIn,"\n      您委托第",DoneTimes,"次任务，获得"]),
    L2 = case ToAddExp>0 of
             true->
                 lists:concat([L1,ToAddExp,"经验，"]);
             _ ->
                 L1
         end,
    L3 = case ToAddSilver>0 of
             true->
                 lists:concat([L1,ToAddSilver,"银子，"]);
             _ ->
                 L2
         end,
    L4 = case ToAddSilverBind>0 of
             true->
                 lists:concat([L1,ToAddSilverBind,"绑定银子，"]);
             _ ->
                 L3
         end,
    L5 = case ToPrestige > 0 of
             true->
                 lists:concat([L1,ToPrestige,"声望，"]);
             _ ->
                 L4
         end,
    L5.
 

%% 执行具体属性奖励
do_give_attr_reward_2({AddExp, AddSilver, AddSilverBind, Prestige}) ->
    {ok,RoleAttr1} = mod_map_role:get_role_attr(RoleID),
    RoleAttr2 = t_add_money(RoleID,RoleAttr1,AddSilver,AddSilverBind),
    %% 添加声望处理
    RoleAttr3 = RoleAttr2#p_role_attr{sum_prestige = RoleAttr2#p_role_attr.sum_prestige + Prestige,
                                      cur_prestige = RoleAttr2#p_role_attr.cur_prestige + Prestige},
    mod_map_role:set_role_attr(RoleID,RoleAttr3),
    
    R = #p_mission_reward_data{
                               exp=AddExp,
                               silver=AddSilver,
                               silver_bind=AddSilverBind,
                               prestige = Prestige,
                               prop = []%%道具奖励不在这处理
                              },
    Func = {func,fun()-> 
                         common_misc:send_role_silver_change(RoleID,RoleAttr3),
                         case AddExp>0 of
                             true->
                                 mod_map_role:do_add_exp(RoleID, AddExp);
                             _ ->
                                 ignore
                         end
            
            end},
    {R,Func}.
 
    

%% ====================================================================
%% Internal functions
%% ====================================================================
    
%%@doc 增加银两
t_add_money(RoleID,RoleAttr1,AddSilver,AddSilverBind) when is_record(RoleAttr1,p_role_attr)->
    mod_mission_misc:t_add_money(RoleID,RoleAttr1,AddSilver,AddSilverBind).

%% 发送自动任务的奖励经验
send_auto_letter(AutoInfo,LetterCont)->
    #p_mission_auto{start_time=StartTime,name=Name,end_time=EndTime} = AutoInfo,
    case LetterCont of
        []->
            ignore;
        _ ->
            case StartTime>0 of
                true->
                    Text = lists:concat(["自动完成：", common_tool:to_list(Name) ,"任务\n",LetterCont]),
                    Func2 = {func,fun()-> 
                                          common_letter:sys2p(RoleID,Text,"获得委托任务的奖励",[],14,EndTime)
                             end},
                    mod_mission_misc:push_trans_func(RoleID,Func2);
                _ ->
                    ?ERROR_MSG("坑人啊，StartTime=~w,RoleID=~w,MissionBaseInfo=~w",[StartTime,RoleID,MissionBaseInfo])
            end
    end.


