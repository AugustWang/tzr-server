%%% -------------------------------------------------------------------
%%% Author  : xiaosheng
%%% Description : 任务工具模块
%%%
%%% Created : 2011-04-03
%%% -------------------------------------------------------------------
-module(mod_mission_misc).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mission.hrl"). 

-export([
         call_mission_reward/4,
         random/1,
         give_prop/3,
         give_prop/4,
         del_prop/3,
         get_prop_name/2,
         get_prop_num_in_bag/2
        ]).

-export([
         c_trans_func/1,
         r_trans_func/1,
         push_trans_func/2
        ]).

-export([get_choose_prop_reward/2]).

%%任务共用的方法
-export([
         t_add_money/4,
         t_add_prop/2
         ]).


%%采集任务状态为1时是正在做采集任务
-define(MISSION_MODEL_8_COLLECT_STATUS, 1).
%%给采集调用的接口 判断是否正在做采集任务
-export([is_doing_collect/2]).

%%@doc commit事务外执行方法
c_trans_func(RoleID)->
    case erlang:get(?MISSION_TRANS_FUNC_LIST(RoleID)) of
        undefined->
            ignore;
        []->
            ignore;
        List->
            lists:foreach(fun({func,Fun})->
                                  Fun()
                          end, List),
            erlang:erase(?MISSION_TRANS_FUNC_LIST(RoleID)),
            ok
    end.

%%@doc rollback事务外执行方法
r_trans_func(RoleID)->
    erlang:erase(?MISSION_TRANS_FUNC_LIST(RoleID)),
    ok.

%%@doc 加入单个的事务外执行方法
push_trans_func(_RoleID,[]) ->
    ignore;
push_trans_func(RoleID,FuncList) when is_list(FuncList)->
    case erlang:get(?MISSION_TRANS_FUNC_LIST(RoleID)) of
        undefined->
            erlang:put(?MISSION_TRANS_FUNC_LIST(RoleID),FuncList);
        List->
            FuncList2 = lists:merge(List,FuncList),
            erlang:put(?MISSION_TRANS_FUNC_LIST(RoleID),FuncList2),
            ok
    end;
push_trans_func(RoleID,{func,_Fun}=Func)->
    common_misc:update_dict_queue(?MISSION_TRANS_FUNC_LIST(RoleID),Func),
    ok.


get_choose_prop_reward(RequestRecord,PropRewardList) when is_record(RequestRecord,m_mission_do_tos),
                                                          is_list(PropRewardList)->
    Length = length(RequestRecord#m_mission_do_tos.prop_choose),
    
    case Length>0 of
        true->
            [ChooseID|_] = RequestRecord#m_mission_do_tos.prop_choose,
            Reward = lists:keyfind(ChooseID, #p_mission_prop.prop_id, PropRewardList);
        _ ->
            [Reward|_T] = PropRewardList
    end,
    Reward.

%%@doc 查询奖励道具的名称
get_prop_name(PropID,PropType)->
    case PropType of
        ?TYPE_EQUIP->
            [#p_equip_base_info{equipname=Name}] = common_config_dyn:find_equip(PropID);
        ?TYPE_ITEM->
            [#p_item_base_info{itemname=Name}] = common_config_dyn:find_item(PropID);
        ?TYPE_STONE->
            [#p_stone_base_info{stonename=Name}] = common_config_dyn:find_stone(PropID)
    end,
    Name.



%%@doc 查询玩家背包中的道具数量
%%@return num:integer()
get_prop_num_in_bag(RoleID,PropTypeID) when is_integer(PropTypeID)->
    case mod_bag:check_inbag_by_typeid(RoleID,PropTypeID) of
        {ok,FoundGoodsList}->
            get_prop_num_in_bag_2(FoundGoodsList);
        _ ->
            0
    end.
get_prop_num_in_bag_2(Goods) when is_record(Goods,p_goods)->
    Goods#p_goods.current_num;
get_prop_num_in_bag_2(FoundGoodsList) when is_list(FoundGoodsList)->
    lists:foldl(fun(E,AccIn)-> 
                        #p_goods{current_num=Num}=E,
                        AccIn + Num
                end, 0, FoundGoodsList).

%% --------------------------------------------------------------------
%% 调用通用奖励发放奖励
%% -------------------------------------------------------------------- 
call_mission_reward(RoleID, MissionID, MissionBaseInfo, DORequestRecord) ->
    Module = mod_mission_reward:new(RoleID, MissionID, MissionBaseInfo, DORequestRecord),
    Module:reward().

%% --------------------------------------------------------------------
%% 给定几率随机 返回是否命中 true/false
%% -------------------------------------------------------------------- 
random(Rate) ->
    if
        Rate =/= 0 ->
            true;
        true ->
            false
    end.


%% --------------------------------------------------------------------
%% 给任务道具
%% -------------------------------------------------------------------- 
give_prop(RoleID, PropTypeID, PropNum) ->
    give_prop(RoleID, PropTypeID, PropNum, true).

give_prop(RoleID, PropTypeID, PropNum, DoHook) ->
    %%这里对策划的ID配置规则有要求！！
    PropType = PropTypeID div 10000000, 
    Bind = true, %%任务给道具都是指定绑定的
    CreateInfo = #r_goods_create_info{bind=Bind,type=PropType, type_id=PropTypeID, start_time=0, end_time=0, 
                                      num=PropNum, color=?COLOUR_WHITE,quality=?QUALITY_GENERAL, sub_quality=0,
                                      punch_num=0,interface_type=mission},
    {ok,AddGoodsList} = mod_bag:create_goods(RoleID,CreateInfo),
    
    if
        DoHook =:= true ->
            FuncList = [
                %%临时的任务道具，就不记录日志了。
                {func,fun()->  hook_prop:hook(create,AddGoodsList) end},
                {func,fun()->  common_misc:update_goods_notify({role, RoleID}, AddGoodsList) end}
               ];
        true ->
            FuncList = [
                {func,fun()->  common_misc:update_goods_notify({role, RoleID}, AddGoodsList) end}
               ]
    end,
            
    mod_mission_misc:push_trans_func(RoleID,FuncList),
    ok.
    

%% --------------------------------------------------------------------
%% 删除任务道具
%% -------------------------------------------------------------------- 
   
%%@doc 扣除任务道具
del_prop(RoleID, PropTypeID, PropNum) ->
    DoResult = case get_prop_num_in_bag(RoleID,PropTypeID)>=PropNum of
                   true->
                       catch mod_bag:decrease_goods_by_typeid(RoleID,PropTypeID,PropNum);
                   _ ->
                       {error,prop_not_in_bag}
               end,
    case DoResult of
        {ok,UpdateGoodsList,DeleteGoodsList}  ->
            GoodsList = lists:merge(UpdateGoodsList,DeleteGoodsList),
            FuncList = [
                        %%临时的任务道具，就不记录日志了。
                        {func,fun()->  hook_prop:hook(decreate,GoodsList) end},
                        {func,fun()->  common_misc:del_goods_notify({role, RoleID}, DeleteGoodsList) end},
                        {func,fun()->  common_misc:update_goods_notify({role, RoleID}, UpdateGoodsList) end}
                       ],
            mod_mission_misc:push_trans_func(RoleID,FuncList);
        Error  ->
            %% TODO：这里的bug暂时还不确定，先忽略
            ?ERROR_MSG("del_prop error,{RoleID, PropTypeID, PropNum}=~w,Reason=~w",[{RoleID, PropTypeID, PropNum},Error])%%,
            %%throw({?MISSION_ERROR_MAN, ?MISSION_CODE_FAIL_DEL_PROP, []})
    end.

%%%===================================================================
%%% Internal functions
%%%===================================================================


%%@doc 是否正在做采集任务
is_doing_collect(RoleID, CollectPoint) when is_integer(CollectPoint) ->
  MissionList = mod_mission_data:get_pinfo_list(RoleID),
  ModelID = 8,
  PInfo = lists:keyfind(ModelID, #p_mission_info.model, MissionList),
  if
      PInfo =:= false ->
        false;
      true ->
        CurrentModelStatus = PInfo#p_mission_info.current_model_status,
        MissionID = PInfo#p_mission_info.id,
        if
            CurrentModelStatus =:= ?MISSION_MODEL_8_COLLECT_STATUS ->
              MissionBaseInfo = mod_mission_data:get_base_info(MissionID),
              StatusDataList = MissionBaseInfo#mission_base_info.model_status_data,
              TheCollectNth = ?MISSION_MODEL_8_COLLECT_STATUS+1,
              case length(StatusDataList)>= TheCollectNth of
                  true->
                    StatusData = lists:nth(TheCollectNth, StatusDataList),
                    ThisCollectPointList = StatusData#mission_status_data.collect_point_list,
                    case length(ThisCollectPointList)>0 of
                        true->
                          [List1|_T] = ThisCollectPointList,
                          lists:member(CollectPoint, List1);
                        _ ->
                          false
                    end;
                  _ ->
                    false
              end;
            true ->
              false
        end
  end.



%%@doc 增加银两
t_add_money(RoleID,RoleAttr1,AddSilver,AddSilverBind) when is_record(RoleAttr1,p_role_attr)->
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
                    SubQuality = 0,
                    Color = ?COLOUR_PURPLE,
                    Quality = ?QUALITY_GENERAL;
                true ->
                    SubQuality = 1,
                    Color = ColorConfig,
                    Quality = ?QUALITY_WELL
            end;
        true ->
            SubQuality = 1,
            Color = ColorConfig,
            Quality = ?QUALITY_WELL
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






