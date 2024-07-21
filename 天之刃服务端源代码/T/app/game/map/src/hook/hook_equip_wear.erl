%%% -------------------------------------------------------------------
%%% Author  : xiaosheng
%%% Description : 穿装备通知
%%%
%%% Created : 2010-9-5
%%% -------------------------------------------------------------------
-module(hook_equip_wear).
-export([
         hook/1
        ]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeem.hrl").

%% --------------------------------------------------------------------
%% Function: hook/1
%% Description: hook检查口
%% Parameter: int() RoleId 角色id
%% Parameter: record() GoodsInfo #p_goods
%% Parameter: record() GoodsBaseInfo #p_item_base_info
%% Returns: ok
%% --------------------------------------------------------------------
%%检查
hook({RoleID, GoodsInfo, _GoodsBaseInfo}) ->
    ?TRY_CATCH( hook_achievement(RoleID),Err2),
    ?TRY_CATCH( common_mod_goal:hook_equip_wear(RoleID, GoodsInfo#p_goods.current_colour),Err3),
    ok;

hook({RoleID, SlotNum, GoodsInfo, _GoodsBaseInfo, NewRoleAttr}) ->
    ?TRY_CATCH( hook_achievement(RoleID,NewRoleAttr),Err2),
    ?TRY_CATCH( common_mod_goal:hook_equip_wear(RoleID, SlotNum, GoodsInfo#p_goods.current_colour),Err3),
    ok.


%% 成就系统添加hook
hook_achievement(RoleId) ->
    ?DEBUG("~ts,RoleId=~w",["成就系统添加hook",RoleId]),
    case mod_map_role:get_role_attr(RoleId) of
        {ok, RoleAttr} ->
            hook_achievement2(RoleId,RoleAttr);
        _ ->
            ok
    end.

hook_achievement(RoleId,RoleAttr) ->
    hook_achievement2(RoleId,RoleAttr).

hook_achievement2(RoleId,RoleAttr) ->
    EquipList = if erlang:is_list(RoleAttr#p_role_attr.equips) ->
                     RoleAttr#p_role_attr.equips;
                true ->
                     []
             end,
    %%成就 add by caochuncheng 2011-03-07 装备强化成就
    if erlang:length(EquipList) >= 2 ->
            hook_achievement4(RoleId,RoleAttr,EquipList);
       true ->
            next
    end,
    ?DEBUG("~ts,RoleId=~w,EquipList=~w",["成就系统添加hook",RoleId,EquipList]),
    %% 装备五行和套装部件列表
    SlotList = [1,2,3,4,5,6,7,8],
    %% 过滤副手和其它不需要处理的装备
    EquipList2 = 
        lists:foldl(fun(Equip,Acc) ->
                            if Equip#p_goods.type =:= 3 ->
                                    TypeId = Equip#p_goods.typeid,
                                    case mod_equip:get_equip_baseinfo(TypeId) of
                                        {ok,BaseInfo} ->
                                            SlotNum = BaseInfo#p_equip_base_info.slot_num,
                                            case lists:member(SlotNum,SlotList) of
                                                false ->
                                                    Acc;
                                                true ->
                                                    [Equip|Acc]
                                            end;
                                        error ->
                                            Acc
                                    end;
                               true ->
                                    Acc
                            end
                    end,[], EquipList),
    
    if erlang:length(EquipList2) =:= 10 ->
            hook_achievement3(RoleId,RoleAttr,EquipList2);
       true ->
            ok
    end.
hook_achievement3(RoleId,_RoleAttr,EquipList) ->
    EquipList2 = 
        lists:map(fun(EquipGoods) ->
                          mod_equip_fiveele:do_achievement_equip_whole_attr(EquipGoods)
                  end,EquipList),
    Flag = 
        lists:foldl(fun(EquipGoods2,Acc) ->
                          WholeAttr =  EquipGoods2#p_goods.whole_attr,
                          WholeId = 
                              if erlang:is_record(WholeAttr,p_equip_whole_attr) ->
                                      WholeAttr#p_equip_whole_attr.id;
                                 true ->
                                  0
                              end,
                          if WholeId =:= 3 ->
                                  Acc;
                             true ->
                                  false
                          end
                  end,true,EquipList2),
    ?DEBUG("~ts,Flag=~w,EquipList=~w",["成就系统添加hook",Flag,EquipList2]),
    case Flag of 
        true ->
            catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [100002]});
        false ->
            ok
    end.
%% 人物身上装备强化hook
hook_achievement4(RoleId,_RoleAttr,EquipList) ->
    {EquipList2,EquipList3} = 
        lists:foldl(
          fun(EquipGoods,{Acc2,Acc3}) ->
                  #p_goods{typeid = TypeId,reinforce_result = ReinforceResult} = EquipGoods,
                  [#p_equip_base_info{slot_num = SlotNum}]=common_config_dyn:find_equip(TypeId),
                  Flag2 = lists:member(SlotNum,[1,2,3,4,5,6,7,8,9]),
                  NewAcc2 = 
                      if Flag2 =:= true andalso ReinforceResult >= 66 ->
                              [EquipGoods|Acc2];
                         true ->
                              Acc2
                      end,
                  Flag3 = lists:member(SlotNum,[1,2,3,4,5,6,7,8]),
                  NewAcc3 = 
                      if Flag3 =:= true andalso ReinforceResult >= 66 ->
                              [EquipGoods|Acc3];
                         true ->
                              Acc3
                      end,
                  {NewAcc2,NewAcc3}
          end,{[],[]},EquipList),
    if erlang:length(EquipList2) >= 2 ->
            catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [304005]});
       true ->
            next
    end,
    if erlang:length(EquipList3) =:= 10 ->
            catch common_achievement:hook(#r_achievement_hook{role_id = RoleId,event_ids = [304006]});
       true ->
            next
    end,
    ok.
    
    
