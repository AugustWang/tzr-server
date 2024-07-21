%% Author: chixiaosheng
%% Created: 2011-3-28
%% Description:发放奖励
-module(mod_mission_reward, [RoleID, MissionID, MissionBaseInfo, DORequestRecord]).

%%
%% Include files
%%
-include("mission.hrl").

%%
%% Exported Functions
%%
-export([reward/0]).

%%
%% API Functions
%%
%% --------------------------------------------------------------------
%% 给与奖励 返回 p_mission_reward_data
%% -------------------------------------------------------------------- 

%%@return #p_mission_reward_data{}
reward() ->
    BigGroup = MissionBaseInfo#mission_base_info.big_group,
    if
        BigGroup =:= 0 ->
            do_give_normal();
        true ->
            do_give_group()
    end.

%%循环任务分组奖励
do_give_group() ->
    BigGroup = MissionBaseInfo#mission_base_info.big_group,
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    Level = RoleAttr#p_role_attr.level,
    Key = {BigGroup, Level},
    RewardList = mod_mission_data:get_setting(group_reward),
    MathReward = lists:keyfind(Key, 1, RewardList),
    {Key, Exp, SilverBind, Prestige,PropList} = MathReward,
    
    BaseRewardDataTmp = MissionBaseInfo#mission_base_info.reward_data,
    %% 去掉 attr_reward_formula=?MISSION_ATTR_REWARD_FORMULA_CALC_ALL_TIMES,
    %% 使用任务奖励配置的奖励方式
    BaseRewardData = BaseRewardDataTmp#mission_reward_data{exp=Exp, 
                                                           prestige = Prestige,
                                                           silver_bind=SilverBind}, 
    AttrRewardFormula = BaseRewardData#mission_reward_data.attr_reward_formula,
    PropRewardFormula = BaseRewardData#mission_reward_data.prop_reward_formula,
    {PMissionRewardData, FuncList1} = do_give_attr_reward(AttrRewardFormula, BaseRewardData),
    mod_mission_misc:push_trans_func(RoleID, FuncList1),
    
    SuccTimes = mod_mission_data:get_succ_times(RoleID, MissionBaseInfo),
    PMissionRewardData2 = 
        case lists:keyfind(SuccTimes, 1, PropList) of
            false ->
                PMissionRewardData;
            {SuccTimes, PropRewardBaseList} ->
                {PropRewardList, FuncList2} = do_give_prop_reward(PropRewardFormula, PropRewardBaseList),
                mod_mission_misc:push_trans_func(RoleID, FuncList2),
                PMissionRewardData#p_mission_reward_data{prop=PropRewardList}
        end,
    PMissionRewardData2.

do_give_normal() ->
    BaseRewardData = MissionBaseInfo#mission_base_info.reward_data,
    AttrRewardFormula = BaseRewardData#mission_reward_data.attr_reward_formula,
    PropRewardFormula = BaseRewardData#mission_reward_data.prop_reward_formula,
    
    {PMissionRewardData, FuncList1} = do_give_attr_reward(AttrRewardFormula, BaseRewardData),
    mod_mission_misc:push_trans_func(RoleID,FuncList1),
    
    PropRewardBaseList = BaseRewardData#mission_reward_data.prop_reward,
    {PropRewardList, FuncList2} = do_give_prop_reward(PropRewardFormula, PropRewardBaseList),
    mod_mission_misc:push_trans_func(RoleID,FuncList2),
    
    PMissionRewardData#p_mission_reward_data{prop=PropRewardList}.
    
do_give_attr_reward(?MISSION_ATTR_REWARD_FORMULA_NO, _) ->
    {#p_mission_reward_data{},[]};
    
do_give_attr_reward(?MISSION_ATTR_REWARD_FORMULA_NORMAL, BaseRewardData) ->
    #mission_reward_data{exp=AddExp,
                         silver=AddSilver,
                         silver_bind=AddSilverBind,
                         prestige = Prestige} = BaseRewardData,
    do_give_attr_reward_2({AddExp, AddSilver, AddSilverBind, Prestige});

do_give_attr_reward(?MISSION_ATTR_REWARD_FORMULA_CALC_ALL_TIMES, BaseRewardData) ->
    #mission_reward_data{rollback_times=RollBackTimes,
                         exp=AddExp,
                         silver=AddSilver,
                         silver_bind=AddSilverBind,
                         prestige = Prestige} = BaseRewardData,
   
    CurDoneTimes = mod_mission_data:get_succ_times(RoleID, MissionBaseInfo),
    case CurDoneTimes>RollBackTimes of
        true->
            MultTimes = 1;
        _ ->
            MultTimes = CurDoneTimes
    end,
    do_give_attr_reward_2({AddExp*MultTimes, AddSilver*MultTimes, AddSilverBind*MultTimes, Prestige*MultTimes});

do_give_attr_reward(?MISSION_ATTR_REWARD_FORMULA_CALC_EXP_TIMES, BaseRewardData) ->
    #mission_reward_data{rollback_times=RollBackTimes,
                         exp=AddExp1,
                         silver=AddSilver1,
                         silver_bind=AddSilverBind1,
                         prestige = Prestige} = BaseRewardData,
    CurDoneTimes = mod_mission_data:get_succ_times(RoleID, MissionBaseInfo),
    case CurDoneTimes>RollBackTimes of
        true->
            MultTimes = 1;
        _ ->
            MultTimes = CurDoneTimes
    end,
    do_give_attr_reward_2({AddExp1*MultTimes,AddSilver1,AddSilverBind1,Prestige});

%%直接给五行属性
do_give_attr_reward(?MISSION_ATTR_REWARD_FORMULA_WU_XING, _) ->
    Fun = fun() ->
            FineRecord = #m_role2_five_ele_attr_tos{type=0},
            {ok, RoleState} = mod_map_role:get_role_state(RoleID),
            #r_role_state2{pid=PID} = RoleState,
            Line = common_misc:get_role_line_by_id(RoleID),
            mod_role2:handle({?DEFAULT_UNIQUE, ?ROLE2, 
                      ?ROLE2_FIVE_ELE_ATTR, FineRecord, 
                      RoleID, PID, Line, mgeem_map:get_state()})
          end,
    {#p_mission_reward_data{},[{func, Fun}]}.

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
 


%%@return {PropRewardList,FuncList}
do_give_prop_reward(?MISSION_PROP_REWARD_FORMULA_NO, _) ->
    {[],[]};
do_give_prop_reward(_, []) ->
    {[],[]};
%%@return {PropRewardList,FuncList}
do_give_prop_reward(?MISSION_PROP_REWARD_FORMULA_CHOOSE_ONE, PropRewardList) ->
    Reward = mod_mission_misc:get_choose_prop_reward(DORequestRecord,PropRewardList),
    Func = t_add_prop(RoleID,Reward),
    {[Reward],Func};
do_give_prop_reward(?MISSION_PROP_REWARD_FORMULA_CHOOSE_RANDOM, PropRewardList) ->
    Size = length(PropRewardList),
    case Size>0 of
        true->
            RandomIndex = common_tool:random(1,Size),
            Reward = lists:nth(RandomIndex, PropRewardList),
            Func = t_add_prop(RoleID,Reward),
            {[Reward],Func};
        _ ->
            {[],[]}
    end;
do_give_prop_reward(?MISSION_PROP_REWARD_FORMULA_ALL, PropRewardList) ->
    FuncList = lists:foldl(fun(E,AccIn)-> 
                                   Func = t_add_prop(RoleID,E),
                                   [Func|AccIn]
                           end, [], PropRewardList),
    {PropRewardList,FuncList}.
    

%% ====================================================================
%% Internal functions
%% ====================================================================
    
%%@doc 增加银两
t_add_money(RoleID,RoleAttr1,AddSilver,AddSilverBind)->
    common_consume_logger:gain_silver({RoleID, AddSilverBind, AddSilver, ?GAIN_TYPE_SILVER_MISSION_NORMAL,""}),
    #p_role_attr{silver=OldSilver,silver_bind=OldSilverBind} = RoleAttr1,
    RoleAttr1#p_role_attr{silver=(OldSilver+AddSilver),silver_bind=(OldSilverBind+AddSilverBind)}.

%%@doc 增加道具
t_add_prop(RoleID,PropReward) when is_record(PropReward,p_mission_prop)->
    #p_mission_prop{prop_id=PropID,prop_type=PropType,prop_num=PropNum,bind=IsBind,color=ColorConfigTmp} = PropReward,
    if
        ColorConfigTmp =:= undefined ->
            ColorConfig = 0;
        true ->
            %%默认是0，这样就按照装备的配置中指定颜色来赠送
            ColorConfig = ColorConfigTmp
    end,
    
    if
        PropType =:= ?TYPE_EQUIP ->
            [BaseInfo] = common_config_dyn:find_equip(PropID),
            if
                BaseInfo#p_equip_base_info.kind =:= 1101 ->
                    Color = ?COLOUR_PURPLE,
                    {Quality,SubQuality} = mod_refining_tool:get_equip_quality_by_color(Color);
                true ->
                    Color = ColorConfig,
                    {Quality,SubQuality} = mod_refining_tool:get_equip_quality_by_color(Color)
            end;
        true ->
            SubQuality = 1,
            Color = ColorConfig,
            Quality = 1
    end,
    
    CreateInfo = #r_goods_create_info{bind=IsBind,type=PropType, type_id=PropID, start_time=0, end_time=0, 
                                      num=PropNum, color=Color, quality=Quality, sub_quality=SubQuality,
                                      punch_num=0,interface_type=mission},
    {ok,NewGoodsList} = mod_bag:create_goods(RoleID,CreateInfo),
    [Goods|_] = NewGoodsList,
    Func = 
        {func,fun()->  
                      common_misc:update_goods_notify({role, RoleID}, NewGoodsList),
                      common_item_logger:log(RoleID,Goods#p_goods{current_num=PropNum},?LOG_ITEM_TYPE_REN_WU_HUO_DE)
         end},
    Func.





