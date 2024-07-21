%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @doc 删除死号模块
%%%
%%% @end
%%% Created : 14 Jul 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_del_role_info).

-include("common_server.hrl").

-include("common.hrl").

%% API
-export([
         do/0,
         do_guest/0,
         do_soft_clear/0
        ]).

%%%===================================================================
%%% API
%%%===================================================================

%% 开始删除死号
do() ->
    RoleIDList = get_del_role_list(),
    ?ERROR_MSG("~ts:~p", ["准备删除的角色数量", erlang:length(RoleIDList)]),
    del_role_info(RoleIDList),
    clear_family_request_and_invite(),
    clear_friend_request(),
    ok.
%% 删除游客帐号
do_guest() ->
    RoleIDList = get_guest_role_list(),
    ?ERROR_MSG("~ts:~p", ["准备删除的游客角色数量", erlang:length(RoleIDList)]),
    del_role_info(RoleIDList),
    clear_family_request_and_invite(),
    clear_friend_request(),
    ok.

%% 软清档操作
do_soft_clear() ->
    RoleIDList = get_soft_clear_role_list(),
    ?ERROR_MSG("~ts:~p", ["本次清档角色数量", erlang:length(RoleIDList)]),
    del_role_info(RoleIDList),
    clear_family_request_and_invite(),
    clear_friend_request(),
    ok.
if_role_info_whole(RoleID) ->
    case db:dirty_read(?DB_ROLE_BASE_P, RoleID) of
        [] ->
            erlang:throw(false);
        _ ->
            ok
    end,
    case db:dirty_read(?DB_ROLE_ATTR_P, RoleID) of
        [] ->
            erlang:throw(false);
        _ ->
            ok
    end,
    case db:dirty_read(?DB_ROLE_POS_P, RoleID) of
        [] ->
            erlang:throw(false);
        _ ->
            ok
    end,
    case db:dirty_read(?DB_ROLE_EXT_P, RoleID) of
        [] ->
            erlang:throw(false);          
        _ ->
            ok
    end,
    case db:dirty_read(?DB_ROLE_STATE_P, RoleID) of
        [] ->
            erlang:throw(false);          
        _ ->
            ok
    end,
    case db:dirty_read(?DB_ROLE_EDUCATE_P, RoleID) of
        [] ->
            erlang:throw(false);
        _ ->
            ok
    end,
    true.


get_del_role_list() ->
    [#r_roleid_counter{last_role_id=MaxRoleID}] = db:dirty_read(?DB_ROLEID_COUNTER_P, 1),
    lists:foldl(
        fun(RoleID, Acc) ->
                %% 首先检查角色信息是否完成，在一些意外宕机的情况下，某些玩家的部分数据可能会意外丢失
                case catch if_role_info_whole(RoleID) of
                    true ->
                        [#p_role_attr{level=Level, is_payed=IsPayed, gold=Gold}] = db:dirty_read(?DB_ROLE_ATTR_P, RoleID),
                        [#p_role_ext{last_login_time=LastLoginTime}] = db:dirty_read(?DB_ROLE_EXT_P, RoleID),
                        [#p_role_base{family_id=FamilyID}] = db:dirty_read(?DB_ROLE_BASE_P, RoleID),     
                        %% 检查是否有挂单
                        BBank = check_role_bank(RoleID),
                        %% 检查玩家等级
                        BLevel = check_role_level(Level),
                        %% 检查玩家充值情况
                        BPayed = check_role_payed(IsPayed),
                        %% 检查玩家是否有元宝
                        BGold = check_role_gold(Gold),
                        %% 检查玩家是否是族长，且宗族人数大于2
                        BFamily = check_role_family(RoleID, FamilyID),
                        %% 检查玩家是否有师门
                        BEducate = check_role_educate(RoleID),
                        %% 检查玩家最近30条是否登录过
                        BLastLoginTime = check_role_last_login_time(LastLoginTime),
                        case BLevel andalso BPayed andalso BGold andalso BFamily andalso BEducate andalso BLastLoginTime andalso BBank of
                            true ->
                                %% 全部都不符合则加入删除列表
                                [RoleID | Acc];
                            false ->
                                Acc
                        end;
                    false ->
                        [RoleID | Acc]
                end
        end, [], lists:seq(1, MaxRoleID)).
%% 删除游客帐号
get_guest_role_list() ->
    [#r_roleid_counter{last_role_id=MaxRoleID}] = db:dirty_read(?DB_ROLEID_COUNTER_P, 1),
    lists:foldl(
      fun(RoleID, Acc) ->
              case catch if_role_info_whole(RoleID) of
                  true ->
                      [#p_role_base{account_type=AccountType}] = db:dirty_read(?DB_ROLE_BASE_P, RoleID),
                      case AccountType =:= 3 of
                          true ->
                              [RoleID | Acc];
                          _ ->
                              Acc
                      end;
                  _ ->
                      Acc
              end
      end, [], lists:seq(1, MaxRoleID)).

%% 软清档操作
get_soft_clear_role_list() ->
    [#r_roleid_counter{last_role_id=MaxRoleID}] = db:dirty_read(?DB_ROLEID_COUNTER_P, 1),
    lists:foldl(
      fun(RoleID, Acc) ->
              case catch if_role_info_whole(RoleID) of
                  true ->
                      [RoleID | Acc];
                  _ ->
                      Acc
              end
      end, [], lists:seq(1, MaxRoleID)).

check_role_bank(RoleID) ->
    case db:dirty_match_object(?DB_BANK_SHEETS_P, #p_bank_sheet{roleid=RoleID, _='_'}) of
        [] ->
            true;
        _ ->
            false
    end.

%% 检查玩家等级条件
check_role_level(Level) ->
    Level < 30.

%% 检查玩家是否已充值
check_role_payed(IsPayed) ->
    not IsPayed.

%% 检查玩家元宝
check_role_gold(Gold) ->
    Gold =< 0.

%% 检查玩家宗族
check_role_family(RoleID, FamilyID) ->
    case db:dirty_read(?DB_FAMILY_P, FamilyID) of
        [] ->
            case db:dirty_match_object(?DB_FAMILY_P, #p_family_info{create_role_id=RoleID, _='_'}) of
                [] ->
                    true;
                _ ->
                    false
            end;
        [#p_family_info{owner_role_id=OwnerRoleID, create_role_id=CreateRoleID, members=Members}] ->
            case RoleID =:= OwnerRoleID orelse RoleID =:= CreateRoleID of
                false ->
                    case db:dirty_match_object(?DB_FAMILY_P, #p_family_info{create_role_id=RoleID, _='_'}) of
                        [] ->
                            true;
                        _ ->
                            false
                    end;
                true ->
                    %% 宗族只有一个人，符合删除条件
                    erlang:length(Members) =:= 1
            end
    end.

check_role_last_login_time(LastLoginTime) ->
    common_tool:now() - LastLoginTime > 30 * 86400 .
    

%% 检查玩家师门
check_role_educate(RoleID) ->
    [#r_educate_role_info{teacher=TRoleID, students=Students}] = db:dirty_read(?DB_ROLE_EDUCATE_P, RoleID),
    case (TRoleID =/= undefined andalso TRoleID > 0) orelse erlang:length(Students) > 0 of
        true ->
            false;
        false ->
            case db:dirty_match_object(?DB_ROLE_EDUCATE_P, #r_educate_role_info{teacher=RoleID, _='_'}) of
                [] ->
                    true;
                _ ->
                    false
            end
    end.

del_role_info(RoleIDList) ->
    lists:foreach(
      fun(RoleID) ->
              catch remove_role_account(RoleID),
              catch remove_role_family_info(RoleID),
              remove_role_friend_info(RoleID),
              remove_role_mission_info(RoleID),
              remove_role_rank_info(RoleID),

              remove_role_stall_info(RoleID),
              remove_role_bag_info(RoleID),

              remove_role_system_info(RoleID),
              remove_role_shortbar_info(RoleID),

              remove_role_chat_info(RoleID),
              catch remove_role_fcm_info(RoleID),
              remove_role_title_info(RoleID),
              remove_role_educate_info(RoleID),
              remove_role_training_info(RoleID),
              remove_role_achievement_info(RoleID),
              remove_role_achievement_rank_info(RoleID),
              remove_role_ybc_info(RoleID),
              remove_role_onekey_info(RoleID),
              remove_role_trading_info(RoleID),
              remove_role_flower_info(RoleID),
              remove_role_user_event_info(RoleID),
              remove_role_activity_info(RoleID),
              remove_role_accumulate_exp(RoleID),
              remove_role_vip_info(RoleID),
              remove_role_gift_info(RoleID),
              remove_role_hero_fb_info(RoleID),
              remove_role_mission_fb_info(RoleID),
              remove_role_scene_war_fb_info(RoleID),
              remove_role_educate_fb(RoleID),
              remove_role_goal_info(RoleID),
              remove_role_box_info(RoleID),
              remove_role_conlogin_info(RoleID),
              remove_role_spy_info(RoleID),
              remove_role_pet_info(RoleID),
              remove_role_mount_info(RoleID),
              remove_role_sq_fb_info(RoleID),
              remove_role_activity_reward(RoleID),
              remove_role_exe_fb_info(RoleID),
              
              del_role_letter(RoleID),
              del_role_skill(RoleID),

              catch del_role_name(RoleID),
              del_role_state(RoleID),
              del_role_base(RoleID),
              del_role_attr(RoleID),
              del_role_pos(RoleID),
              del_role_ext(RoleID),
              del_role_fight(RoleID)
      end, RoleIDList),
    ok.

%% 清理掉宗族申请列表信息和邀请记录
clear_family_request_and_invite() ->   
    db:clear_table(?DB_FAMILY_REQUEST_P),
    db:clear_table(?DB_FAMILY_INVITE_P),
    lists:foreach(
      fun(FamilyInfo) ->
              db:dirty_write(?DB_FAMILY_P, FamilyInfo#p_family_info{request_list=[], invite_list=[]})
      end, db:dirty_match_object(?DB_FAMILY_P, #p_family_info{_='_'})),
    ok.

%% 清理掉好友请求列表信息
clear_friend_request() ->
    db:clear_table(?DB_FRIEND_REQUEST),
    ok.

remove_role_mission_fb_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_MISSION_FB_P, {RoleID, 101}),
    db:dirty_delete(?DB_ROLE_MISSION_FB_P, {RoleID, 102}),
    ok.

remove_role_scene_war_fb_info(RoleID) ->
    db:dirty_delete(?DB_SCENE_WAR_FB_P, RoleID).

remove_role_educate_fb(RoleID) ->
    db:dirty_delete(?DB_EDUCATE_FB_P, RoleID).

del_role_base(RoleID) ->
    db:dirty_delete(?DB_ROLE_BASE_P, RoleID).

del_role_attr(RoleID) ->
    db:dirty_delete(?DB_ROLE_ATTR_P, RoleID).

del_role_pos(RoleID) ->
    db:dirty_delete(?DB_ROLE_POS_P, RoleID).

del_role_ext(RoleID) ->
    db:dirty_delete(?DB_ROLE_EXT_P, RoleID).

del_role_fight(RoleID) ->
    db:dirty_delete(?DB_ROLE_FIGHT_P, RoleID).

del_role_state(RoleID) ->
    db:dirty_delete(?DB_ROLE_STATE_P, RoleID).

del_role_name(RoleID) ->
    [#p_role_base{role_name=RoleName}] = db:dirty_read(?DB_ROLE_BASE_P, RoleID),
    db:dirty_delete(?DB_ROLE_NAME_P, RoleName).

del_role_skill(RoleID) ->
    db:dirty_delete(?DB_ROLE_SKILL_P, RoleID),
    ok.

del_role_letter(RoleID) ->
    [db:dirty_delete_object(?DB_PERSONAL_LETTER_P, R) || 
        R <- db:dirty_match_object(?DB_PERSONAL_LETTER_P, #r_personal_letter{send_id=RoleID, _='_'})],
    [db:dirty_delete_object(?DB_PERSONAL_LETTER_P, R) || 
        R <- db:dirty_match_object(?DB_PERSONAL_LETTER_P, #r_personal_letter{recv_id=RoleID, _='_'})],
    db:dirty_delete(?DB_PUBLIC_LETTER_P, RoleID),
    ok.

remove_role_mount_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_MOUNT_P, RoleID),
    ok.
%% 玩家刷棋副本
remove_role_sq_fb_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_SQ_FB_INFO_P, RoleID),
    ok.

remove_role_exe_fb_info(RoleID)->
    db:dirty_delete(?DB_ROLE_EXE_FB_INFO_P,RoleID),
    ok.

remove_role_pet_info(RoleID) ->    
    db:dirty_delete(?DB_PET_EGG_P, RoleID),
    case db:dirty_read(?DB_ROLE_PET_BAG_P, RoleID) of
        [] ->
            ignore;
        [#p_role_pet_bag{pets=Pets}] ->
            lists:foreach(
              fun(Pet) ->
                      db:dirty_delete(?DB_PET_P, Pet#p_pet_id_name.pet_id)
              end, Pets)
    end,
    db:dirty_delete(?DB_ROLE_PET_BAG_P, RoleID),
    db:dirty_delete(?DB_ROLE_PET_GROW, RoleID),
    db:dirty_delete(?DB_PET_FEED_P, RoleID),
    db:dirty_delete(?DB_PET_TRAINING_P,RoleID),
    ok.

remove_role_spy_info(RoleID) ->
    db:dirty_delete(?DB_SPY_P, RoleID).

remove_role_conlogin_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_CONLOGIN_P, RoleID).

remove_role_box_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_BOX_P, RoleID).

remove_role_goal_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_GOAL_P, RoleID).

remove_role_hero_fb_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_HERO_FB_P, RoleID),
    [begin
     List=lists:keydelete(RoleID, #p_hero_fb_record.role_id, R#r_hero_fb_record.best_record),
     db:dirty_write(?DB_ROLE_HERO_FB_P, R#r_hero_fb_record{best_record=List})
     end
     ||R<-db:dirty_match_object(?DB_HERO_FB_RECORD_P,#r_hero_fb_record{_='_'})].

remove_role_gift_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_TIME_GIFT_P, RoleID),
    db:dirty_delete(?DB_ROLE_LEVEL_GIFT_P, RoleID),
    ok.

remove_role_vip_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_VIP_P, RoleID).

remove_role_accumulate_exp(RoleID) ->
    db:dirty_delete(?DB_ROLE_ACCUMULATE_EXP_P, RoleID).

%% 删除活动相关信息
remove_role_activity_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_ACTIVITY_P, RoleID).

%% 删除角色相关事件
remove_role_user_event_info(RoleID) ->
    [db:dirty_delete_object(?DB_USER_EVENT_P, R) || R <- db:dirty_match_object(?DB_USER_EVENT_P, #r_user_event{role_id=RoleID, _='_'})],
    ok.


%% 删除角色鲜花相关信息
remove_role_flower_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_GIVE_FLOWERS_P, RoleID),
    db:dirty_delete(?DB_ROLE_RECEIVE_FLOWERS_P, RoleID),
    ok.

%% 玩家商贸信息
remove_role_trading_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_TRADING_P, RoleID),
    ok.    

%% 删除玩家一键换装信息
remove_role_onekey_info(RoleID) ->
    db:dirty_delete(?DB_EQUIP_ONEKEY_P, RoleID),
    ok.

%% 删除镖车信息
remove_role_ybc_info(RoleID) ->
    db:dirty_delete(?DB_YBC_PERSON_P, RoleID),
    db:dirty_delete(?DB_YBC_UNIQUE_P, {0, 1, RoleID}).

%% 删除角色成就信息
remove_role_achievement_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_ACHIEVEMENT_P, RoleID).
%% 删除成就榜信息
remove_role_achievement_rank_info(RoleID) ->
    [db:dirty_delete_object(?DB_ACHIEVEMENT_RANK_P, R) || 
       R <- db:dirty_match_object(?DB_ACHIEVEMENT_RANK_P, #r_achievement_rank{role_id = RoleID, _='_' })],
    ok.
%% 删除角色称号信息
remove_role_title_info(RoleID) ->
    [db:dirty_delete_object(?DB_NORMAL_TITLE_P, R) || R <- db:dirty_match_object(?DB_NORMAL_TITLE_P, #p_title{role_id=RoleID,_='_'})],
    [db:dirty_delete_object(?DB_SPEC_TITLE_P, R) || R <- db:dirty_match_object(?DB_SPEC_TITLE_P, #p_title{role_id=RoleID,_='_'})].

remove_role_educate_info(RoleID) ->
    db:dirty_delete(?DB_ROLE_EDUCATE_P, RoleID).

%% 删除角色训练信息
remove_role_training_info(RoleID) ->
    db:dirty_delete(?DB_TRAINING_CAMP_P, RoleID),
    ok.
    

%% 删除聊天信息
remove_role_chat_info(RoleID) ->
    [db:dirty_delete_object(?DB_CHAT_CHANNEL_ROLES_P, R) || 
        R <- db:dirty_match_object(?DB_CHAT_CHANNEL_ROLES_P, #p_chat_channel_role_info{role_id=RoleID, _='_'})],
    db:dirty_delete(?DB_CHAT_ROLE_CHANNELS_P, RoleID),
    ok.

%% 删除角色快捷栏设置
remove_role_shortbar_info(RoleID) ->
    db:dirty_delete(?DB_SHORTCUT_BAR_P, RoleID),
    ok.

remove_role_system_info(RoleID) ->
    db:dirty_delete(?DB_SYSTEM_CONFIG_P, RoleID).

%% 删除角色背包信息
remove_role_bag_info(RoleID) ->
    case db:dirty_read(?DB_ROLE_BAG_BASIC_P, RoleID) of
        [] ->
            ignore;
        [ #r_role_bag_basic{bag_basic_list=BagBasicList} ] ->
            [db:dirty_delete(?DB_ROLE_BAG_P, {RoleID, BagID}) || {BagID, _, _, _, _} <- BagBasicList],
            db:dirty_delete(?DB_ROLE_BAG_BASIC_P,RoleID)
    end.


%% 删除玩家摆摊信息
remove_role_stall_info(RoleID) ->
    db:dirty_delete(?DB_STALL_P, RoleID),
    [db:dirty_delete_object(?DB_STALL_GOODS_P, R) || R <- db:dirty_match_object(?DB_STALL_GOODS_P, #r_stall_goods{role_id=RoleID, _='_'})],
    [db:dirty_delete_object(?DB_STALL_GOODS_TMP_P, R) || R <- db:dirty_match_object(?DB_STALL_GOODS_TMP_P, #r_stall_goods{role_id=RoleID, _='_'})],
    db:dirty_delete(?DB_STALL_SILVER_P, RoleID),
    ok.
    

remove_role_rank_info(_RoleID) ->    
    ok.

%% 删除角色任务信息
remove_role_mission_info(RoleID) ->
    db:dirty_delete(?DB_MISSION_DATA_P, RoleID),    
    ok.

%% 删除角色好友信息
remove_role_friend_info(RoleID) ->
    [db:dirty_delete_object(?DB_FRIEND_P, R) || R <- db:dirty_match_object(?DB_FRIEND_P, #r_friend{roleid=RoleID, _='_'})],
    [db:dirty_delete_object(?DB_FRIEND_P, R) || R <- db:dirty_match_object(?DB_FRIEND_P, #r_friend{friendid=RoleID, _='_'})],
    ok.

remove_role_fcm_info(RoleID) ->
    [#p_role_base{account_name=AccountName}] = db:dirty_read(?DB_ROLE_BASE_P, RoleID),
    db:dirty_delete(?DB_FCM_DATA_P, AccountName).

%% 删除玩家账号
remove_role_account(RoleID) ->
    [#p_role_base{account_name=AccountName}] = db:dirty_read(?DB_ROLE_BASE_P, RoleID),
    db:dirty_delete(?DB_ACCOUNT_P, AccountName).

%% 删除角色宗族的相关信息
remove_role_family_info(RoleID) ->
    [#p_role_base{family_id=FamilyID}] = db:dirty_read(?DB_ROLE_BASE_P, RoleID),
    case FamilyID > 0 of
        true ->
            %% 如果是族长，则是解散宗族，前提是宗族只有一个人
            case db:dirty_read(?DB_FAMILY_P, FamilyID) of
                [] ->
                    ok;
                [#p_family_info{members=Members, owner_role_id=OwnerRoleID, second_owners=SecondOwners} = FamilyInfo] ->
                    case RoleID =:= OwnerRoleID of
                        true ->
                            case erlang:length(Members) =:= 1 of
                                true ->
                                    db:dirty_delete(?DB_FAMILY_EXT_P, FamilyID),
                                    db:dirty_delete(?DB_FAMILY_P, FamilyID);
                                false ->
                                    ?ERROR_MSG("~ts:~p", ["严重错误，一个要被删除的族长的宗族成员数量大于1，RoleID：", RoleID]),
                                    erlang:throw(error)
                            end;
                        false ->
                            %% 从宗族成员列表中删除对应的成员，如果是副族长也要删除
                            NewMembers = lists:keydelete(RoleID, #p_family_member_info.role_id, Members),
                            NewSecondOwners = lists:keydelete(RoleID, #p_family_second_owner.role_id, SecondOwners),
                            db:dirty_write(?DB_FAMILY_P, FamilyInfo#p_family_info{second_owners=NewSecondOwners,
                                                                                  members=NewMembers,
                                                                                  cur_members=erlang:length(NewMembers)})
                    end
            end,
            %% 玩家宗族捐献记录
            case db:dirty_read(?DB_FAMILY_DONATE_P,FamilyID) of
                [] ->
                    ok;
                [FamilyDonate] ->
                    GoldDonateList = lists:keydelete(RoleID, #p_role_family_donate_info.role_id, FamilyDonate#r_family_donate.gold_donate_record),
                    SilverDonateList = lists:keydelete(RoleID, #p_role_family_donate_info.role_id, FamilyDonate#r_family_donate.silver_donate_record),
                    db:dirty_write(?DB_FAMILY_DONATE,FamilyDonate#r_family_donate{gold_donate_record=GoldDonateList,silver_donate_record=SilverDonateList})
            end,
            ok;
        false ->
            ignore
    end.

remove_role_activity_reward(RoleID)->
    db:dirty_delete(?DB_ACTIVITY_REWARD_P, RoleID).

    
