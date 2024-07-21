%% Author: liuwei
%% Created: 2010-6-21
%% Description: TODO: Add description to mod_skill
-module(mod_skill).

-include("mgeem.hrl").

-export([
         handle/1,
         t_reset_role_skill/3,
         init_skill_last_use_time/2,
         clear_family_skill/1,
         verify_family_skill/2,
         hook_role_online/2
        ]).

-export([
         init_role_skill_list/2,
         get_role_skill_level/2,
         get_role_skill_list/1,
         erase_role_skill_list/1]).

-define(CATEGORY_FAMILY_SKILL,7).   %%门派技能的类型

hook_role_online(RoleID, PID) ->
    do_getskills(?DEFAULT_UNIQUE, ?SKILL, ?SKILL_GETSKILLS, RoleID, PID).

handle({Unique, ?SKILL, Method, DataRecord, RoleID, PID, Line }) ->
    case Method of
        ?SKILL_LEARN ->
            do_learn(Unique, ?SKILL, Method, DataRecord, RoleID, Line);
        ?SKILL_GETSKILLS ->
            do_getskills(Unique, ?SKILL, Method, RoleID, PID);
        ?SKILL_PERSONAL_FORGET ->
            do_personal_forget(Unique, ?SKILL, Method, DataRecord, RoleID, Line);
        _ ->
            ?ERROR_MSG("~w, unrecognize msg,Method = ~w", [?MODULE,Method])
    end;
handle({gm_learn_skill, RoleId}) ->
    do_gm_learn_skill(RoleId).

do_gm_learn_skill(RoleId) ->
    {ok,#p_role_attr{category = RoleCategory }} = mod_map_role:get_role_attr(RoleId),
    {SkillList, SkillListFront} =
        lists:foldl(
          fun(SkillInfo, {TSL, TSLF}) ->
                  case RoleCategory =:= SkillInfo#p_skill.category of
                      true ->
                          RoleSkill = #r_role_skill_info{
                            skill_id=SkillInfo#p_skill.id,
                            cur_level=20,
                            category=SkillInfo#p_skill.category},
                          {[RoleSkill|TSL],
                           [#p_role_skill{skill_id=SkillInfo#p_skill.id, cur_level=20}|TSLF]};
                      _ ->
                          {TSL, TSLF}
                  end
          end, {[], []}, common_config_dyn:list(skill)),
    case common_transaction:t(
           fun() ->
                   set_role_skill_list(RoleId, SkillList)
           end)
    of
        {atomic, _} ->
            DataRecord = #m_skill_getskills_toc{skills=SkillListFront},
            common_misc:unicast({role, RoleId}, ?DEFAULT_UNIQUE, ?SKILL, ?SKILL_GETSKILLS, DataRecord);
        {aborted, Reason} ->
            ?ERROR_MSG("do_gm_learn_skill, error: ~w", [Reason])
    end.


%% @doc 技能上次使用时间
init_skill_last_use_time(RoleID, Line) ->
    case catch db:dirty_read(?DB_SKILL_TIME, RoleID) of
        [#r_skill_time{last_use_time=LastUseTime}] ->
            mod_fight:set_last_skill_time(role, RoleID, LastUseTime),
            ServerTime = common_tool:now(),
            LastUseTime2 = 
                lists:map(
                  fun({SkillID, {A, B, _}}) ->
                          #p_skill_time{skill_id=SkillID, last_use_time=A*1000000+B}
                  end, LastUseTime),
            DataRecord = #m_skill_use_time_toc{skill_time=LastUseTime2, server_time=ServerTime},
            common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE, ?SKILL, ?SKILL_USE_TIME, DataRecord);
        _ ->
            ok
    end.

%%@doc 校验玩家的门派技能（若离开门派，则需要清空原门派技能）
verify_family_skill(RoleID,#p_role_base{family_id=FamilyID})->
    case FamilyID>0 of
        true->
            ignore;
        _->
            clear_family_skill(RoleID)
    end.
    

%%@doc 清空玩家本人的门派技能（在离开门派之后）
%%@return ok | {error,Reason}
clear_family_skill(RoleID)->
    TransFun = 
        fun() ->
                SkillList = get_role_skill_list(RoleID),
                SkillList2 =
                    lists:foldl(
                      fun(#r_role_skill_info{category=?CATEGORY_FAMILY_SKILL}, Acc) ->
                              Acc;
                         (Skill, Acc) ->
                              [Skill|Acc]
                      end, [], SkillList),

                case erlang:length(SkillList) =:= erlang:length(SkillList2) of
                    true ->
                        {ok, no_skill};
                    _ ->
                        {ok, skill_deleted}
                end
        end,
    case common_transaction:transaction(TransFun) of
        {atomic, {ok,no_skill}} ->
            ok;
        {atomic, {ok,skill_deleted}} ->
            Msg = ?_LANG_FAMKLY_SKILL_WHEN_LEAVE_FAMILY,
            common_broadcast:bc_send_msg_role(RoleID,[?BC_MSG_TYPE_SYSTEM,?BC_MSG_TYPE_CENTER],Msg),

            case get_role_all_skill_level(RoleID) of
                {fail,Reason1} ->
                    ?ERROR_MSG_STACK("clear_family_skill",Reason1),
                    ignore;
                SkillLevelList ->
                    R2 = #m_skill_getskills_toc{skills=SkillLevelList},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?SKILL, ?SKILL_GETSKILLS, R2)
            end;
        {aborted, Reason} ->
            ?ERROR_MSG_STACK("clear_family_skill",Reason),
            {error,Reason}
    end.

%%================First Level Local Function=====================================


%%@interface 玩家学习新技能或升级技能
do_learn(Unique, Module, Method, DataIn, RoleID, Line) ->
    #m_skill_learn_tos{skill_id = SkillID} = DataIn,
    case common_config_dyn:find(family_skill,SkillID) of
        [SkillDetails] when is_list(SkillDetails)->
            do_learn_family_skill(Unique, Module, Method, SkillID, RoleID, Line);
        _ ->
            do_learn_normal_skill(Unique, Module, Method, SkillID, RoleID, Line) 
    end.


%%@doc 玩家学习宗族技能
do_learn_family_skill(Unique, Module, Method, SkillID, RoleID, Line)->
    {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
    #p_role_base{family_id=FamilyID} = RoleBase,
    if
        FamilyID>0->
            do_learn_family_skill_2({Unique, Module, Method, SkillID, RoleID, Line}, FamilyID);
        true ->
            ?SEND_ERR_TOC(m_skill_learn_toc,?_LANG_FML_SKILL_LEARN_MUST_JOIN_FAMILY)
    end.
do_learn_family_skill_2({Unique, Module, Method, SkillID, RoleID, Line}, FamilyID)->
    [SkillDetails] = common_config_dyn:find(family_skill,SkillID),    
    TransFun = 
        fun() ->
                {ok, SkillLevel} = get_role_skill_level(RoleID, SkillID),
                NextSkillLevel = SkillLevel + 1,
                MaxFamilyLevel = get_max_family_level(),
                CurFamilyLevel = get_cur_family_level(FamilyID,SkillID),
                if
                    NextSkillLevel>MaxFamilyLevel->
                        db:abort(?_LANG_FML_SKILL_LEARN_WHEN_MAX_LEVEL);
                    CurFamilyLevel =:= 0->
                        db:abort(?_LANG_FML_SKILL_LEARN_WHEN_NOT_RESEARCH);
                    NextSkillLevel>CurFamilyLevel->
                        db:abort(?_LANG_FML_SKILL_LEARN_WHEN_LARGE_THAN_FAMILY_LEVEL);
                    true->
                        FamilySkillDetail = get_family_skill(NextSkillLevel,SkillDetails),
                        t_learn_family_skill(RoleID,SkillID,NextSkillLevel,FamilySkillDetail)
                end
        end,
    case db:transaction(TransFun) of
        {atomic, {ok,RoleAttr3,NextSkillLevel,DeductFamilyConb}} ->
            R2 = #m_skill_learn_toc{skill=#p_role_skill{skill_id=SkillID,cur_level=NextSkillLevel}},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R2),
            %% common_mod_goal:hook_learn_family_skill(RoleID, SkillID, NextSkillLevel),
            %% 扣除门派贡献度
            common_family:info(FamilyID, {add_contribution, RoleID, -DeductFamilyConb}),
            ChangeList = [
                          #p_role_attr_change{change_type=?ROLE_SILVER_CHANGE, new_value=RoleAttr3#p_role_attr.silver},
                          #p_role_attr_change{change_type=?ROLE_SILVER_BIND_CHANGE, new_value=RoleAttr3#p_role_attr.silver_bind},
                          #p_role_attr_change{change_type=?ROLE_FAMILY_CONTRIBUTE_CHANGE, new_value=RoleAttr3#p_role_attr.family_contribute}],
            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeList);
        {aborted, Reason} ->
            ?ERROR_MSG("do_learn_family_skill error,Reason=~w",[Reason]),
            ?SEND_ERR_TOC2(m_skill_learn_toc,Reason)
    end.

%%@doc 玩家学习普通技能
do_learn_normal_skill(Unique, Module, Method, SkillID, RoleID, Line) ->
    Fun = 
        fun() ->
                {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
                {ok, SkillLevel} = get_role_skill_level(RoleID, SkillID),
                if SkillLevel =:= 0 ->
                        learn_new_skill(SkillID, RoleID, RoleAttr);
                   true ->
                        upgrade_skill(SkillID, SkillLevel,RoleID,RoleAttr)
                end
        end,
    
    case common_transaction:t(Fun) of
        {aborted, Reason} when erlang:is_binary(Reason) ->
            erlang:erase({category_skill_level, RoleID}),
            ?SEND_ERR_TOC(m_skill_learn_toc, Reason);
        {aborted, Reason} ->
            ?ERROR_MSG("do_learn, error: ~w", [Reason]),
            erlang:erase({category_skill_level, RoleID}),
            ?SEND_ERR_TOC2(m_skill_learn_toc,Reason);
        {atomic, {ok, CurLevel, RoleAttr2, ChangeList, DelList, IsCategoryChange}} ->
            erlang:erase({category_skill_level, RoleID}),
            hook_skill_learn:hook({RoleID, SkillID, CurLevel}),
            DataRecord = #m_skill_learn_toc{skill=#p_role_skill{skill_id=SkillID,cur_level=CurLevel}},
            
            %% 通知客户端角色属性变动
            DataRecord2 = #m_role2_attr_reload_toc{role_attr=RoleAttr2},
            common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_RELOAD, DataRecord2),
            
            %% 通知客户端物品变动
            case ChangeList of
                [] ->
                    ignore;
                [Goods] ->
                    do_insert_item_logger(RoleID,Goods),
                    common_misc:update_goods_notify({line, Line, RoleID}, Goods)
            end,
            
            case DelList of
                [] ->
                    ignore;
                [Goods2] ->
                    do_insert_item_logger(RoleID,Goods2),
                    common_misc:del_goods_notify({line, Line, RoleID}, Goods2)
            end,
            common_misc:unicast(Line, RoleID, Unique, Module, Method, DataRecord),
            
            case IsCategoryChange of
                true ->
                    %% add by caochuncheng 2011-04-21 道具奖励hook
                    ?TRY_CATCH(mod_gift:hook_category_change(RoleID,RoleAttr2#p_role_attr.level,RoleAttr2#p_role_attr.category),Err1),
                    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
                    RoleLevelRank = common_ranking:get_level_rank_record(RoleBase, RoleAttr2),
                    ?TRY_CATCH(global:send(mgeew_ranking, {ranking_element_update, ranking_role_level, RoleLevelRank}),Err2);
                _ ->
                    false
            end
    end.



%%@interface 遗忘个人的门派技能
do_personal_forget(Unique, Module, Method, DataIn, RoleID,Line)->
    #m_skill_personal_forget_tos{skill_id = SkillID} = DataIn,
    [SkillDetails] = common_config_dyn:find(family_skill,SkillID),
    TransFun = 
        fun() ->
                {ok, SkillLevel} = get_role_skill_level(RoleID, SkillID),
                #r_family_skill{forget_need_silver=DeductSilver} = get_family_skill(SkillLevel,SkillDetails),
                t_personal_forget(RoleID,SkillID,DeductSilver)
        end,
    case common_transaction:transaction(TransFun) of
        {atomic, {ok,RoleAttr2}} ->
            R2 = #m_skill_personal_forget_toc{succ=true,skill_id=SkillID},
            common_misc:unicast(Line, RoleID, Unique, Module, Method, R2),
            
            %% 通知客户端角色属性变动
            R3 = #m_role2_attr_reload_toc{role_attr=RoleAttr2},
            common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_ATTR_RELOAD, R3);
        {aborted, Reason} when erlang:is_binary(Reason) ->
            ?SEND_ERR_TOC2(m_skill_personal_forget_toc,Reason);
        {aborted, Reason} ->
            ?SEND_ERR_TOC2(m_skill_personal_forget_toc,Reason)
    end.

%%@interface 玩家获取当前已学所有技能的等级信息（包括个人技能、门派技能）
do_getskills(Unique, Module, Method, RoleID, PId)->
    case get_role_all_skill_level(RoleID) of
        {fail, Reason} ->
            DataRecord = #m_skill_getskills_toc{succ=false, reason=Reason};
        SkillLevelList ->
            DataRecord = #m_skill_getskills_toc{skills=SkillLevelList}
    end,
    common_misc:unicast2(PId, Unique, Module, Method, DataRecord).


%%================Second Level Local Function=====================================
t_learn_family_skill(RoleID,SkillID,NextSkillLevel,FamilySkillDetail) when is_record(FamilySkillDetail,r_family_skill)->
    #r_family_skill{category=Category,learn_need_silver=DeductSilver,learn_family_contribute=DeductFamilyConb} = FamilySkillDetail,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
    #p_role_base{family_id=FamilyID} = RoleBase,
    #p_role_attr{ silver_bind = BindSilver,silver = Silver,family_contribute=CurFamilyContrb} = RoleAttr,
    case BindSilver + Silver >= DeductSilver of
        true ->
            case FamilyID > 0 of
                true->
                    case CurFamilyContrb >= DeductFamilyConb  of
                        true->
                            RoleAttr2 = deduct_silver(RoleAttr,DeductSilver),
                            RoleAttr3 = deduct_family_conb(RoleAttr2,DeductFamilyConb),
                            t_add_role_skill(RoleID,SkillID,NextSkillLevel,Category),
                            mod_map_role:set_role_attr(RoleID, RoleAttr3),
                            {ok,RoleAttr3,NextSkillLevel,DeductFamilyConb};
                        _ ->
                            db:abort(?_LANG_FML_SKILL_WHEN_GONGXIAN_NOT_ENOUGH)
                    end;
                _ ->
                    db:abort(?_LANG_FML_SKILL_FORGET_MUST_JOIN_FAMILY)
            end;
        false ->
            db:abort(?_LANG_SKILL_REST_SILVER_NOT_ENOUGH)
    end.
 
t_personal_forget(RoleID,SkillID,DeductSilver)->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
    #p_role_base{family_id=FamilyID} = RoleBase,
    #p_role_attr{ silver_bind = BindSilver,silver = Silver} = RoleAttr,
    case BindSilver + Silver >= DeductSilver of
        true ->
            case FamilyID > 0 of
                true->
                    RoleAttr2 = deduct_silver(RoleAttr,DeductSilver),
                    mod_map_role:set_role_attr(RoleID, RoleAttr2),
                    delete_role_skill_info(RoleID, SkillID),
                    {ok,RoleAttr2};
                _ ->
                    common_transaction:abort(?_LANG_FML_SKILL_FORGET_MUST_JOIN_FAMILY)
            end;
        false ->
            common_transaction:abort(?_LANG_SKILL_REST_SILVER_NOT_ENOUGH)
    end.


%% 记录道具消费日志
do_insert_item_logger(RoleId,Goods) ->
    common_item_logger:log(RoleId,Goods,1,?LOG_ITEM_TYPE_SHI_YONG_SHI_QU).

learn_new_skill(SkillID,RoleID,RoleAttr) ->
    case mod_skill_manager:get_skill_level_info(SkillID,1) of
        {ok, SkillLevelInfo} ->
            case judge_can_learn_skill(SkillLevelInfo,RoleID,RoleAttr) of
                ok ->
                    learn_new_skill2(SkillLevelInfo,SkillID,RoleID,RoleAttr);
                {fail,Reason} ->
                    common_transaction:abort(Reason)
            end;
        {error,Reason} ->
            common_transaction:abort(Reason)
    end.


learn_new_skill2(SkillLevelInfo,SkillID,RoleID,RoleAttr) ->
    #p_skill_level{need_item=NeedItemID} = SkillLevelInfo,
    {ok, ChangeList, DelList} = t_deduct_item(NeedItemID, RoleID),
    upgrade_skill2(SkillLevelInfo,SkillID,RoleID,RoleAttr, ChangeList, DelList).


upgrade_skill(SkillID,Level,RoleID,RoleAttr) ->
    case mod_skill_manager:get_skill_level_info(SkillID,Level+1) of
        {ok, SkillLevelInfo} ->
            case judge_can_upgrade_skill(SkillLevelInfo,RoleID,RoleAttr) of
                ok ->
                    upgrade_skill2(SkillLevelInfo,SkillID,RoleID,RoleAttr, [], []);
                {fail,Reason} ->
                    common_transaction:abort(Reason)
            end;
        {error, _Reason} ->
            common_transaction:abort(?_LANG_SKILL_LEVEL_IS_MAXLEVEL)
    end.


upgrade_skill2(SkillLevelInfo,SkillID,RoleID,RoleAttr, ChangeList, DelList) ->
    #p_skill_level{
                category = Category,
                level = CurLevel,
                need_silver = NeedSilver,
                consume_exp = NeedExp
               } = SkillLevelInfo,
    t_add_role_skill(RoleID,SkillID,CurLevel,Category),
    RoleAttr2 = deduct_skill_points(RoleAttr),
    RoleAttr3 = deduct_silver(RoleAttr2,NeedSilver),
    RoleAttr4 = deduct_exp(RoleAttr3,NeedExp),

    %% 各职业技能总级数
    SkillLevel = get({category_skill_level, RoleID}),
    {RoleCategory, _} = get_role_category(SkillLevel, Category),
    %% 设置玩家职业
    #p_role_attr{category=OldCategory} = RoleAttr4,
    case RoleCategory =/= OldCategory of
        true ->
            NewCategory = RoleCategory;
        _ ->
            NewCategory = OldCategory
    end,
    RoleAttr5 = RoleAttr4#p_role_attr{category=NewCategory},
    mod_map_role:set_role_attr(RoleID, RoleAttr5),
    add_passive_skill_buff(RoleID,SkillID,SkillLevelInfo,CurLevel),
    {ok, CurLevel, RoleAttr5, ChangeList, DelList, OldCategory =/= NewCategory}.

%% @doc 获取玩家当前职业
get_role_category(SkillLevel, Category) ->
    lists:foldl(
      fun({C, L}, {MaxC, MaxL}) ->
              case C > 0 andalso C < 5 of
                  true ->
                      if
                          %% 如果等级相等则取现在正学的职业
                          L =:= MaxL ->
                              case C =:= Category of
                                  true ->
                                      {C, L};
                                  _ ->
                                      {MaxC, MaxL}
                              end;
                          L > MaxL ->
                              {C, L};
                          true ->
                              {MaxC, MaxL}
                      end;
                  false ->
                      {MaxC, MaxL}
              end
      end, {0, 0}, SkillLevel).

get_role_all_skill_level(RoleID) ->
    SkillList = get_role_skill_list(RoleID),
    lists:foldr(
      fun(RoleSkillInfo, Acc) ->
              #r_role_skill_info{skill_id=SkillID, cur_level=CurLevel} = RoleSkillInfo, 
              [#p_role_skill{skill_id=SkillID,cur_level=CurLevel}|Acc]
      end, [], SkillList).

%% @doc 重置技能点
t_reset_role_skill(RoleID, RoleBase, RoleAttr) ->
    RemainPoint = RoleAttr#p_role_attr.remain_skill_points,
    SkillList = get_role_skill_list(RoleID),
    case SkillList =:= [] of
        true ->
            common_transaction:abort(?_LANG_SKILL_LEARN_NO_SKILL);
        _ ->
            ok
    end,
    %%计算使用了多少点
    ReturnPoint =
        lists:foldl(
          fun(RoleSkill, Acc) ->
                  case RoleSkill#r_role_skill_info.category > 4 of
                      true ->
                          Acc;
                      _ ->
                          Acc + RoleSkill#r_role_skill_info.cur_level
                  end
          end, 0, SkillList),
    set_role_skill_list(RoleID, []),
    %%返回技能点 mod by caochuncheng 2011-10-10 洗技能点不需要重置职业信息 category=0
    RoleAttr2 = RoleAttr#p_role_attr{remain_skill_points=RemainPoint+ReturnPoint},
    %%删除被动技能
    delete_passive_skill_buff(RoleID, SkillList, RoleBase, RoleAttr2).

judge_can_learn_skill(SkillLevelInfo,RoleID,RoleAttr) ->
    TypeID = SkillLevelInfo#p_skill_level.need_item,
    case TypeID > 0 of
        true ->
            case mod_bag:check_inbag_by_typeid(RoleID, TypeID) of
                {ok, _} ->
                    judge_can_upgrade_skill(SkillLevelInfo,RoleID,RoleAttr);
                false ->
                    {fail, ?_LANG_SKILL_ITEM_NOT_EXIST}
            end;
        false ->
              judge_can_upgrade_skill(SkillLevelInfo,RoleID,RoleAttr)
    end.

judge_can_upgrade_skill(SkillLevelInfo,RoleID,RoleAttr) ->
    #p_role_attr{
                  level = Level,
                  remain_skill_points = Points,
                  silver_bind = BindSilver,
                  silver = Silver,
                  exp = Exp
                } = RoleAttr,
    #p_skill_level{
                    category = Category,
                    premise_point = NeedPrePoints,
                    pre_condition = NeedPreSkill,
                    premise_role_level = NeedRoleLevel,
                    need_silver = NeedSilver,
                    consume_exp = NeedExp
                  } = SkillLevelInfo,

    case Points > 0 of
        true ->
            case BindSilver + Silver >= NeedSilver of
                true ->
                    case Exp >= NeedExp of
                        true ->
                            case Level >= NeedRoleLevel of
                                true ->
                                    judge_can_upgrade_skill2(RoleID,NeedPrePoints,NeedPreSkill,Category);
                                false ->
                                    {fail,?_LANG_SKILL_ROLE_LEVEL_NOT_ENOUGH}
                            end;
                        false ->
                            {fail,?_LANG_SKILL_REST_EXP_NOT_ENOUGH}
                    end;
                false ->
                    {fail,?_LANG_SKILL_REST_SILVER_NOT_ENOUGH}
            end;
        false ->
            {fail,?_LANG_SKILL_POINT_NOT_ENOUGH}
    end.


judge_can_upgrade_skill2(RoleID, NeedPrePoints, NeedPreSkill, Category) ->
    {SkillLevel, CategoryList} = get_role_all_category_skill_level(RoleID, Category),
    put({category_skill_level, RoleID}, SkillLevel),

    {_, Level} = lists:keyfind(Category, 1, SkillLevel),
    Points = Level - 1,

    case Points >= NeedPrePoints of
        true ->
            judge_can_upgrade_skill3(NeedPreSkill, CategoryList);
        false ->
            
            %%技能点不足，不同的职业提示有所不同
            if
                Category =:= ?CATEGORY_WARRIOR ->
                    {fail, ?_LANG_SKILL_WARRIOR_SKILL_POINT_NOT_ENOUGH};
                Category =:= ?CATEGORY_HUNTER ->
                    {fail, ?_LANG_SKILL_HUNTER_SKILL_POINT_NOT_ENOUGH};
                Category =:= ?CATEGORY_RANGER ->
                    {fail, ?_LANG_SKILL_RANGER_SKILL_POINT_NOT_ENOUGH};
                true ->
                    {fail, ?_LANG_SKILL_DOCTOR_SKILL_POINT_NOT_ENOUGH}
            end
    end.


judge_can_upgrade_skill3(NeedPreSkillList,RoleSkillList) ->
    LearnedSkillList = 
        lists:foldr(
          fun(Skill,Acc) ->
                  #r_role_skill_info{
               skill_id = SkillID,
               cur_level = CurLevel
              } = Skill,
                  [#p_skill_precondition{skill_id=SkillID,skill_level=CurLevel}|Acc]
          end,[],RoleSkillList),
    Index = #p_skill_precondition.skill_id,
    lists:foldr(
      fun(NeedSkill,Acc) ->
              case Acc of
                  ok ->
                      NeedLevel = NeedSkill#p_skill_precondition.skill_level,
                      NeedSkillID =  NeedSkill#p_skill_precondition.skill_id,
                      case lists:keyfind(NeedSkillID,Index,LearnedSkillList) of
                          false ->
                              {fail,?_LANG_SKILL_PRE_SKILL_NOT_LREANED};
                          TmpSkill ->
                              TmpLevel = TmpSkill#p_skill_precondition.skill_level,
                              case TmpLevel >= NeedLevel of
                                  true ->
                                      Acc;
                                  false ->
                                      {fail,?_LANG_SKILL_PRE_SKILL_NOT_LREANED}
                              end
                      end;
                  {fail,Reason} ->
                      {fail,Reason}
              end
      end,ok,NeedPreSkillList).


%% @doc 获取角色所有职业已学技能等级，以及指定职业技能列表
get_role_all_category_skill_level(RoleID, Category) ->
    SkillList = get_role_skill_list(RoleID),
    lists:foldl(
      fun(Skill, {SkillLevel, CList}) ->
              #r_role_skill_info{cur_level=CurLevel, category=C} = Skill,

              SkillLevel2 =
                  case lists:keyfind(C, 1, SkillLevel) of
                      false ->
                          [{C, CurLevel}|SkillLevel];
                      {C, Level} ->
                          [{C, Level+CurLevel}|lists:keydelete(C, 1, SkillLevel)]
                  end,

              CList2 =
                  case C =:= Category of
                      true ->
                          [Skill|CList];
                      _ ->
                          CList
                  end,

              {SkillLevel2, CList2}
      end, {[{Category, 1}], []}, SkillList).

t_deduct_item(NeedItemID,RoleID) ->
    case catch mod_bag:decrease_goods_by_typeid(RoleID, [1, 2, 3], NeedItemID, 1) of
        {bag_error,num_not_enough} ->
            common_transaction:abort(?_LANG_GOODS_NUM_NOT_ENOUGH);
        Other ->
            Other
    end.

t_add_role_skill(RoleID,SkillID,CurLevel,Category) ->
    Record = #r_role_skill_info{
                           skill_id = SkillID,
                           cur_level = CurLevel,
                           category = Category},
    update_role_skill_info(RoleID, Record).


deduct_skill_points(Attr) ->
    OldPoints = Attr#p_role_attr.remain_skill_points,
    %% mod by caochuncheng 2011-08-02 学习技能和升级技能不需要技能点
    Attr#p_role_attr{remain_skill_points = OldPoints}.


deduct_silver(Attr,NeedSilver) ->
    #p_role_attr{role_id=RoleID, silver_bind=BindSilver, silver=Silver} = Attr,

    case BindSilver >= NeedSilver of
        true ->
            common_consume_logger:use_silver({RoleID, NeedSilver, 0, ?CONSUME_TYPE_SILVER_UP_SKILL,
                                              ""}),

            Attr#p_role_attr{silver_bind=BindSilver-NeedSilver};
        false ->
            common_consume_logger:use_silver({RoleID, BindSilver, NeedSilver-BindSilver, ?CONSUME_TYPE_SILVER_UP_SKILL,
                                              ""}),

            Attr#p_role_attr{silver_bind=0, silver=Silver+BindSilver-NeedSilver}
    end.

deduct_family_conb(Attr,DeductFamilyConb) ->
    OldVal = Attr#p_role_attr.family_contribute,
    Attr#p_role_attr{family_contribute = OldVal - DeductFamilyConb}.

deduct_exp(Attr,NeedExp) ->
    OldExp = Attr#p_role_attr.exp,
    Attr#p_role_attr{exp = OldExp - NeedExp}.

%%被动技能
add_passive_skill_buff(RoleID, SkillID, SkillLevelInfo, _CurLevel) ->
    
    %%获取技能信息
    {ok, Skillinfo} = mod_skill_manager:get_skill_info(SkillID),

    %%如果是被动技能则要加个BUFF
    Attacktype = Skillinfo#p_skill.attack_type,
    case Attacktype of
        ?ATTACK_TYPE_PASSIVE ->
            Buffs = SkillLevelInfo#p_skill_level.buffs,
            mod_map_role:add_buff(RoleID,Buffs);
        _ ->
            nil
    end.

%%删掉被动技能所加的BUFF
delete_passive_skill_buff(RoleID, SkillList, RoleBase, RoleAttr) ->
    Buffs = RoleBase#p_role_base.buffs,

    Buffs2 = 
        lists:foldl(
          fun(Skill, Acc) ->
                  #r_role_skill_info{skill_id=SkillID, cur_level=Level} = Skill,

                  {ok, SkillInfo} = mod_skill_manager:get_skill_info(SkillID),

                  AttackType = SkillInfo#p_skill.attack_type,
                  case AttackType of
                      ?ATTACK_TYPE_PASSIVE ->
                          {ok, SkillLevelInfo} = mod_skill_manager:get_skill_level_info(SkillID, Level),

                          SkillBuffs = SkillLevelInfo#p_skill_level.buffs,
                          lists:foldl(
                            fun(BuffDetail, Acc2) ->
                                    BuffID = BuffDetail#p_buf.buff_id,
                                    lists:keydelete(BuffID, #p_actor_buf.buff_id, Acc2)
                            end, Acc, SkillBuffs);

                      _ ->
                          Acc
                  end
          end, Buffs, SkillList),
    
    RoleBase2 = RoleBase#p_role_base{buffs=Buffs2},

    %%如果有删掉的BUFF则还要发个消息改变角色的属性
    case Buffs =:= Buffs2 of
        true ->
            ok;
        _ ->
            mod_map_role:attr_change(RoleID)
    end,
    
    {RoleBase2, RoleAttr}.


%%@doc 获取门派技能
get_family_skill(SkillLevel,SkillDetails) when is_integer(SkillLevel) andalso is_list(SkillDetails)->
    lists:keyfind(SkillLevel, 3, SkillDetails).

%%@doc 获取门派的当前技能等级
get_cur_family_level(FamilyID,SkillID)->
    Key = {FamilyID,SkillID},
    case db:read(?DB_FAMILY_SKILL_RESEARCH,Key,write) of
        []->
            0;
        [#r_family_skill_research{cur_level=CurSkillLevel}]->
            CurSkillLevel
    end.
    

%%@doc 获取门派技能配置的最高等级
get_max_family_level()->
    [Level] = common_config_dyn:find(family_skill,max_family_level),
    Level.

init_role_skill_list(RoleId, SkillList) ->
    erlang:put({?role_skill, RoleId}, SkillList).

%% @doc 获取角色技能列表
get_role_skill_list(RoleId) ->
    case erlang:get({?role_skill, RoleId}) of
        undefined ->
            [];
        SkillList ->
            SkillList
    end.

%% @doc 设置角色技能列表
set_role_skill_list(RoleId, SkillList) ->
    mod_map_role:update_role_id_list_in_transaction(RoleId, ?role_skill, ?role_skill_copy),
    erlang:put({?role_skill, RoleId}, SkillList).

%% @doc 清除角色技能列表
erase_role_skill_list(RoleId) ->
    SkillList = get_role_skill_list(RoleId),
    mgeem_persistent:role_skill_list_persistent(RoleId, SkillList),
    erlang:erase({?role_skill, RoleId}).

%% @doc 获取角色某技能信息
get_role_skill_info(RoleId, SkillId) ->
    case lists:keyfind(SkillId,#r_role_skill_info.skill_id,get_role_skill_list(RoleId)) of
        false ->
            {error, not_found};
        SkillInfo when erlang:is_record(SkillInfo,r_role_skill_info) ->
            {ok,SkillInfo};
        _ ->
            {error, not_found}
    end.

%% @doc 更新玩家技能信息
update_role_skill_info(RoleId, SkillInfo) ->
    SkillList = get_role_skill_list(RoleId),
    SkillList2 = [SkillInfo|lists:keydelete(SkillInfo#r_role_skill_info.skill_id, #r_role_skill_info.skill_id, SkillList)],
    set_role_skill_list(RoleId, SkillList2).

delete_role_skill_info(RoleId, SkillId) ->
    SkillList = get_role_skill_list(RoleId),
    set_role_skill_list(RoleId, lists:keydelete(SkillId, #r_role_skill_info.skill_id, SkillList)).

%% @doc 获取角色某技能等级
get_role_skill_level(RoleId, SkillId) ->
    case get_role_skill_info(RoleId, SkillId) of
        {ok, SInfo} ->
            {ok, SInfo#r_role_skill_info.cur_level};
        _ ->
            {ok, 0}
    end.
