%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc hook地图中玩家的各种信息
%%%
%%% @end
%%% Created :  6 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(hook_map_role).

-include("mgeem.hrl").

%% API
-export([
         role_dead/4,
         role_pos_change/1,
         role_been_dizzy/3,
         kick_role/1,
         role_exit/1,
         attack/4,
         be_attacked/4,
         use_item/1,
         role_quit/1,
         role_offline/1,
         role_online/7,
         state_change/3,
         map_enter/3,
         hook_change_map_by_call/2,
         notify_family_contribute_change/2,
         done_family_ybc/2,
         sex_change/2,
         role_reduce_hp/3,
         before_role_quit/3
        ]).

%% 角色门派拉镖完成了
done_family_ybc(RoleID, _RoleName) ->
    ?TRY_CATCH( mod_accumulate_exp:role_do_family_ybc(RoleID) ),
    ok.


%%角色死亡
%% RoleID  死亡角色ID
%% SrcActorID 谁导致角色死亡
%% 导致角色死亡的actor的类型: role monster pet
role_dead(RoleID, RoleMapInfo, SActorID, SActorType) ->
    MapState = mgeem_map:get_state(),
    #p_map_role{pos=Pos} = RoleMapInfo,
    #p_pos{tx=TX, ty=TY} = Pos,
    %% 商贸玩家死亡，删除商贸商票处理
    if MapState#map_state.mapid =:= 10500 ->
            next;
       true ->
            catch mod_trading:hook_role_dead(RoleID,RoleMapInfo,SActorID,SActorType)
    end,
    %% 师门同心副本，玩家死戽处理
    if MapState#map_state.mapid =:= 10600 ->
            catch mod_educate_fb:hook_role_dead(RoleID,RoleMapInfo);
       true ->
            next
    end,
    %% 场景大战副本
    catch mod_scene_war_fb:hook_role_dead(RoleID,RoleMapInfo),
    %% 个人英雄副本
    ?TRY_CATCH(mod_hero_fb:hook_role_dead(),Err),
    %% 刷棋副本
    catch mod_shuaqi_fb:hook_role_dead(RoleID),
    %% 安全区判断
    case get({reado_area, TX, TY}) of
        true ->
            Flag = true;
        _ ->
            Flag = false
    end,

    case SActorType of
        role ->
            case mod_map_actor:get_actor_mapinfo(SActorID, SActorType) of
                undefined ->
                    ignore;
                SRoleMapInfo ->
                    role_dead2(RoleMapInfo, SRoleMapInfo, MapState, Flag)
            end;
        pet ->
             case mod_map_actor:get_actor_mapinfo(SActorID, SActorType) of
                 undefined ->
                     ignore;
                 #p_map_pet{role_id=SRoleID} = _PetMapInfo ->
                     case mod_map_actor:get_actor_mapinfo(SRoleID, role) of
                         undefined ->
                             ignore;
                         SRoleMapInfo ->
                             role_dead2(RoleMapInfo, SRoleMapInfo, MapState, Flag)
                     end
            end;
        _ ->
            ignore
    end,
    %%王座争霸战过程中杀死本国玩家不会变动PK值
    case mod_warofking:if_begin_warofking() of
        true ->
            Flag2 = true;
        false ->
            Flag2 = Flag
    end,
    %%死亡惩罚
    mod_map_role:dead_punish(RoleID, RoleMapInfo, SActorType, MapState, Flag2),
    ok.

role_dead2(RoleMapInfo, SRoleMapInfo, MapState, Flag) ->
    #map_state{mapid=MapID} = MapState,
    #p_map_role{role_id=RoleID, role_name=RoleName, family_id=FamilyID, faction_id=FactionID, gray_name=GrayName} = RoleMapInfo,
    #p_map_role{role_id=SRoleID, role_name=SRoleName, family_id=SFamilyID, faction_id=SFactionID} = SRoleMapInfo,    

    case FamilyID =/= SFamilyID of
        true ->
            case FamilyID > 0 of 
                true ->
                    mod_warofking:add_family_mark(SRoleID);
                false ->
                    ignore
            end;            
        false ->
            ignore
    end,
    mod_warofking:break_holding(RoleID),
    %%王座争霸战过程中杀死本国玩家不会变动PK值
    case mod_warofking:if_begin_warofking() of
        true ->
            Flag2 = true;
        false ->
            Flag2 = Flag
    end,
    %%计算是否可能会产生功勋值
    mod_gongxun:change(RoleID, FactionID, FamilyID, SRoleID, SFactionID, SFamilyID, Flag2),
    %%死亡的一些广播
    mod_dead_broadcast:role_killed(RoleID, RoleName, FactionID,  SRoleID, SRoleName, SFactionID, MapID, Flag2),
    %%PK计算
    mod_pk:kill(RoleID, FactionID, GrayName, SRoleID, SFactionID, Flag2),
    %%添加仇人
    add_enemy(RoleID, SRoleID, role, Flag2, FactionID),
    mod_map_collect:stop_collect(RoleID, ?_LANG_COLLECT_BREAK),
    mod_item:stop_use_special_item(RoleID),
    %%通知师门
    #p_map_role{pos=Pos} = RoleMapInfo,
    call_educate_helper(RoleID, MapID, Pos),
    ok.


%% @doc 角色位置发生了变化
role_pos_change(RoleID) ->
    mod_warofking:break_holding(RoleID),
    mod_map_collect:stop_collect(RoleID,?_LANG_COLLECT_BREAK),
    mod_item:stop_use_special_item(RoleID),
    %% 清除角色特殊状态
    mod_map_role:clear_role_spec_state(RoleID),
    ok.


%%角色被人击晕
role_been_dizzy(RoleID, _SrcActorID, _SrcActorType) ->
    mod_warofking:break_holding(RoleID),
    mod_map_collect:stop_collect(RoleID,?_LANG_COLLECT_BREAK),
    mod_item:stop_use_special_item(RoleID),
    mod_warofcity:break(RoleID),
    ok.


%%角色被T下线
kick_role(RoleID) ->
    mod_warofking:break_holding(RoleID),
    mod_map_collect:stop_collect(RoleID,?_LANG_COLLECT_BREAK),
    mod_item:stop_use_special_item(RoleID),
    mod_warofcity:break(RoleID),
    ok.


%%角色离开地图
role_exit(RoleID) ->
    mod_warofking:break_holding(RoleID),
    mod_map_collect:stop_collect(RoleID,?_LANG_COLLECT_BREAK),
    mod_item:stop_use_special_item(RoleID),
    mod_warofcity:break(RoleID),
    ok.

%% @doc 退出地图前hook，该hook修改base、attr等仍有效
before_role_quit(RoleID, _MapID, _DestMapID) ->
    mod_mission_fb:hook_role_before_quit(RoleID),
    ok.

role_quit(RoleID) ->
    mod_map_collect:stop_collect(RoleID,?_LANG_COLLECT_BREAK),
    mod_item:stop_use_special_item(RoleID),
    mod_hero_fb:hook_role_quit(RoleID),
    mod_mission_fb:hook_role_quit(RoleID),
    mod_country_treasure:hook_role_quit(RoleID),
    ok.


%% @doc 角色发起攻击操作
attack(RoleID, TargetType, TargetID, SkillBaseInfo) ->
    mod_warofking:break_holding(RoleID),
    mod_map_collect:stop_collect(RoleID,?_LANG_COLLECT_BREAK),
    mod_item:stop_use_special_item(RoleID),
    mod_warofcity:break(RoleID),
    %% 减攻击装备耐久
    mod_map_role:reduce_equip_endurance(RoleID, true),
    %% 清除角色某些特殊BUFF，如隐身
    mod_map_role:clear_role_spec_buff(RoleID),
    %% 更新角色攻击状态时间
    mod_map_role:update_role_fight_time(RoleID, TargetType, TargetID, SkillBaseInfo#p_skill.effect_type),
    ok.

%% @doc 角色被攻击
be_attacked(RoleID, SActorID, SActorType, SkillBaseInfo) ->
    %% 更新角色攻击状态时间
    mod_map_role:update_role_fight_time(RoleID, SActorType, SActorID, SkillBaseInfo#p_skill.effect_type),
    %% 清除打坐状态
    mod_map_role:clear_role_spec_state(RoleID),
    %% 减装备耐久度
    mod_map_role:reduce_equip_endurance(RoleID, false),
    mod_item:stop_use_special_item(RoleID),
    ok.

use_item(RoleID) ->
    mod_warofking:break_holding(RoleID),
    ok.

%% 添加仇人
add_enemy(RoleID, SrcActorID, SrcActorType, Flag, FactionID) ->
    case global:whereis_name(mod_friend_server) of
        undefined ->
            ignore;
        _ ->
            IsWarOfFaction = mod_map_role:is_in_waroffaction(FactionID),
            global:send(mod_friend_server, {add_enemy, RoleID, SrcActorID, SrcActorType, Flag, IsWarOfFaction})
    end.

%% 通知同门报仇
call_educate_helper(RoleID, MapID, Pos)->
    case global:whereis_name(mgeew_educate_server) of
        undefined->
            ignore;
        _->
            global:send(mgeew_educate_server,{call_educate_helper,RoleID, MapID, Pos})
    end.

state_change(RoleID,OldState,NewState) ->
    if OldState =:= ?ROLE_STATE_NORMAL andalso 
       NewState =:= ?ROLE_STATE_NORMAL ->
            ignore;
       OldState =:= ?ROLE_STATE_COLLECT ->
            ignore;
       true ->
            mod_map_collect:role_state_change(RoleID,NewState)
    end.

%% @doc 进入地图
map_enter(RoleID, RoleMapInfo, MapID) ->
    catch mod_map_role:map_enter_broadcast(RoleID, MapID),
    catch mod_country_treasure:hook_role_map_enter(RoleID,MapID),
    catch mod_educate_fb:hook_role_enter_map(RoleID,MapID),
    catch mod_scene_war_fb:hook_role_enter_map(RoleID,MapID),
    catch mod_shuaqi_fb:hook_role_enter_map(RoleID,MapID),
    catch mod_waroffaction:hook_role_map_enter(RoleMapInfo),
    catch mod_hero_fb:hook_role_enter(MapID),
    mod_mission_fb:hook_role_enter(MapID),
    catch mod_map_bonfire:send_bonfire_info(RoleID),
    catch mod_exercise_fb:hook_role_enter_map(RoleID, MapID),
    ok.

%% @doc 角色下线hook
role_offline(RoleID) ->
    catch mod_role_buff:hook_role_offline(RoleID),
    {ok, RoleState} = mod_map_role:get_role_state(RoleID),
    {ok,#p_role_base{faction_id = FactionId}} = mod_map_role:get_role_base(RoleID), 
    #r_role_state2{client_ip=ClientIP} = RoleState,
    %%下线时检查，避免一个月没登录的玩家登陆后加入排行榜后会再被清除掉
    catch check_unactivity_role_back(RoleID),
    %% 纪录下线时间及登陆ip
    catch mod_map_role:update_offline_time_and_ip(RoleID, ClientIP),
    %% 交易角色下线处理
    catch mod_exchange:role_offline(RoleID),
    %% 摊位角色下线处理
    catch mod_stall:role_offline(RoleID),
    %% 下线提醒
    catch offline_nofity(RoleID),
    %% 更新在线列表
    case global:whereis_name(mgeew_online) of
        undefined ->
            ?ERROR_MSG("mgeew_online server down", []),
            ignore;
        OLPID ->
            OLPID ! {remove_online, RoleID}
    end,
    %% 组队下线处理
    catch hook_map_team:role_offline(RoleID),
    %% 训练营
    catch mod_training:role_offline(RoleID),
    %% 清除角色状态，如打坐
    catch mod_map_role:clear_role_spec_state(RoleID),
    %% 玩家退出游戏时，需要处理在线挂机
    catch mod_role_on_zazen:hook_role_exit(RoleID),
    %% 玩家推出游戏时，时间礼包倒计时暂停
    catch mod_time_gift:pause_time_gift(RoleID),
    %% 师徒副本
    catch mod_educate_fb:hook_role_offline(RoleID),
    %% 场景大战副本
    catch mod_scene_war_fb:hook_role_offline(RoleID),
    %% 玩家退出游戏，清楚世界进程字典中师徒的数据
    case global:whereis_name(mgeew_educate_server) of
        undefined ->
            ?ERROR_MSG("mgeew_educate_server down ~n",[]),
            ignore;
        EDPID ->
            EDPID! {remove_time_and_pos,RoleID}
    end,
    %% 当前国家玩家在线榜
    case common_config_dyn:find(etc,do_faction_online_role_rank_map_id) of
        [FactionOnlineRoleRankMapId] ->
            catch global:send(common_map:get_common_map_name(FactionOnlineRoleRankMapId),
                              {mod_role2,{admin_quit_faction_online_rank,
                                          {RoleID,FactionId,FactionOnlineRoleRankMapId}}});
        _ ->
            ignore
    end,
    catch mod_shuaqi_fb:hook_role_offline(RoleID),
    ?TRY_CATCH(mod_hero_fb:hook_role_offline(RoleID),Err),
    catch mod_exercise_fb:hook_role_offline(RoleID),
    ok.

%% @doc 角色上线hook
role_online(RoleID, PID, RoleBase, RoleAttr, MapID, ClientIP, Line) ->
    #p_role_base{role_name=RoleName, faction_id=FactionID, family_id=FamilyID, team_id=TeamID} = RoleBase,
    #p_role_attr{level=Level, office_id=OfficeID} = RoleAttr,
    ?TRY_CATCH( mod_accumulate_exp:role_online(RoleID) ),
    %% 注册玩家分线
    common_misc:set_role_line_by_id(RoleID, Line),
    %% 更新在线列表
    update_online_list(RoleBase, ClientIP, Line, Level),
    %% 初始化系统设置
    mod_system:sys_config_init(RoleID, Line),
    %% 初始化快捷栏
    mod_shortcut:shortcut_init(RoleID, Line),
    %% 技能树信息
    mod_skill:hook_role_online(RoleID, PID),
    %% 相关上线提醒
    online_nofity(RoleID, RoleBase, RoleAttr),
    %% 注册门派进程
    global:send(mod_family_manager, {role_online, RoleID, FamilyID}),
    %% 称号
    common_title:send_sence_titles(RoleID),
    %% 发送排行榜配置
    global:send(mgeew_ranking, {send_ranking_to_role, RoleID}),
    %% 师徒副本
    catch mod_educate_fb:hook_role_online(RoleID),
    %% 场景大战副本
    catch mod_scene_war_fb:hook_role_online(RoleID),
    %% 组队重新登陆处理
    catch hook_map_team:role_online(RoleID,TeamID),
    %% 好友离线请求
    gen_server:cast({global, mod_friend_server}, {offline_request, RoleID, Line}),
    %% 更新最后一次登录时间
    catch mod_map_role:update_online_time(RoleID),
    %% 上线角色灰名处理
    mod_gray_name:login_gray_name_init(RoleID),
    %% 上线角色PK值处理
    mod_pk:login_pk_init(RoleID),
    %% 登陆BUFF处理
    mod_role_buff:hook_role_online(RoleID),
    %% 技能上次使用登时
    mod_skill:init_skill_last_use_time(RoleID, Line),
    %% 商贸活动初始化
    catch mod_trading:hook_first_enter_map(RoleID,RoleBase),
    %% 赠品模块的通知
    catch mod_present:hook_first_enter_map(RoleID,RoleAttr,RoleBase),
    catch mod_present_mail:hook_first_enter_map(RoleID,RoleAttr,RoleBase),
    
    catch mod_mission_auto:check_auto_mission_finish(RoleID),
    
    %% 对玩家门派技能的校验
    catch mod_skill:verify_family_skill(RoleID,RoleBase),
    %% 有无系统BUFF
    catch global:send(mgeew_system_buff, {role_online, RoleID, PID, FactionID, FamilyID}),
    %% 国探剩余时间
    mod_spy:role_online(RoleID, PID, RoleBase#p_role_base.faction_id),
    %%国战倒计时信息
    mod_waroffaction:send_waroffaction_count_down(RoleID, FactionID),
    %% 离线官职指派请求
    catch common_office:role_online(RoleID),
    %%宠物背包信息
    catch mod_map_pet:auto_summon_role_pet(RoleID),
    %% 国战宣战通知
    mod_waroffaction:hook_role_online(RoleID, FactionID),
    %% VIP信息
    mod_vip:hook_role_online(RoleID, PID),
    %% 英雄副本信息
    mod_hero_fb:hook_role_online(RoleID, PID),
    %%篝火
    mod_map_bonfire:send_bonfire_info(RoleID),
    %% 上线广播
    mod_role2:online_broadcast(RoleID, RoleName, PID, OfficeID, FactionID),
    %% 训练营初始化
    mod_training:role_online(RoleID, MapID),
    %% 当前国家在线玩家榜
    case common_config_dyn:find(etc,do_faction_online_role_rank_map_id) of
        [FactionOnlineRoleRankMapId] ->
            catch global:send(common_map:get_common_map_name(FactionOnlineRoleRankMapId),
                              {mod_role2,{admin_join_faction_online_rank,
                                          {RoleID,RoleName,FactionID,RoleAttr#p_role_attr.level,FactionOnlineRoleRankMapId}}});
        _ ->
            ignore
    end,
    catch mod_shuaqi_fb:hook_role_online(RoleID),
    catch mod_exercise_fb:hook_role_online(RoleID),
    ?TRY_CATCH(mod_mission_fb:hook_role_online(RoleID),MissionFbOnlineError),
    ok.

%% 上线提醒
online_nofity(RoleID, RoleBase, RoleAttr) ->
    %% 好友上线提醒
    gen_server:cast({global, mod_friend_server}, {online_notice, RoleID, RoleAttr#p_role_attr.level}),
    %% 师徒上线提醒
    gen_server:cast({global,mgeew_educate_server}, {online_nofity, RoleID, RoleBase, RoleAttr}),
    %% 门派上线提醒
    common_family:nofity_role_online(RoleBase#p_role_base.family_id, RoleID).

%% 下线提醒
offline_nofity(RoleID) ->
    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    %% 好友下线提醒
    gen_server:cast({global, mod_friend_server}, {offline_notice, RoleID, RoleAttr#p_role_attr.level}),
    %% 师徒下线提醒
    gen_server:cast({global, mgeew_educate_server}, {offline_nofity, RoleID}),
    %% 门派下线提醒
    common_family:nofity_role_offline(RoleBase#p_role_base.family_id, RoleID),
    ok.

update_online_list(RoleBase, ClientIP, Line , Level) ->
    RoleOnlineRec = get_role_online(RoleBase, ClientIP),
    
    case global:whereis_name(mgeew_online) of
        undefined ->
            ?ERROR_MSG("mgeew_online server down", []),
            ignore;
        PID ->
            PID ! {add_online, RoleOnlineRec, Line ,Level}
    end.

%%@doc 获取r_role_online的记录
get_role_online(RoleBase,ClientIP)->
    LoginTime = common_tool:now(),
    #p_role_base{role_id=RoleID, role_name=RoleName, account_name=AccountName, faction_id=FactionId, 
                 family_id=FamilyId} = RoleBase,
    #r_role_online{role_id=RoleID, role_name=RoleName, account_name=AccountName, faction_id=FactionId, 
                   family_id=FamilyId, login_time=LoginTime, login_ip=ClientIP}.

check_unactivity_role_back(RoleID) ->
    case db:dirty_read(?DB_ROLE_EXT, RoleID) of
        [] ->
            ignore;
        [RoleExt] ->
            Now = common_tool:now(),
            LastOfflineTime = RoleExt#p_role_ext.last_offline_time,
            case LastOfflineTime =:= undefined 
                        orelse Now - LastOfflineTime < 2592000 of
                true ->
                    ignore;    
                false ->
                    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
                    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
                    RoleLevelRank = common_ranking:get_level_rank_record(RoleBase, RoleAttr),
                    catch global:send(mgeew_ranking, {ranking_element_update, ranking_role_level, RoleLevelRank}),
                    RoleGongXunRank = common_ranking:get_gongxun_rank_record(RoleBase, RoleAttr),
                    catch global:send(mgeew_ranking, {ranking_element_update, ranking_role_gongxun,RoleGongXunRank}),
                    RolePkPointRank = common_ranking:get_pkpoint_rank_record(RoleBase),
                    catch global:send(mgeew_ranking, {ranking_element_update, ranking_role_world_pkpoint,RolePkPointRank}),
                    catch global:send(mgeew_ranking, {ranking_element_update, ranking_role_pkpoint,RolePkPointRank})
            end
    end.

%% 玩家被召集传送前处理
%% 门派召集，门派拉镖召集，王座争霸战召集，门派令召集，国王令召集
hook_change_map_by_call(Type,RoleId) ->
    ?DEBUG("~ts,Type=~w,RoleId=~w",["玩家被召集hook",Type,RoleId]),
    %%catch mod_role_on_zazen:do_cancel_role_on_hook(RoleId),
    catch mod_educate_fb:do_cancel_role_educate_fb(RoleId),
    catch mod_scene_war_fb:do_cancel_role_sw_fb(RoleId),
    ok.

notify_family_contribute_change(RoleID,NewFamilyContrb)->
    R = #p_role_attr_change { change_type = ?ROLE_FAMILY_CONTRIBUTE_CHANGE, new_value = NewFamilyContrb },
    R_TOC = #m_role2_attr_change_toc{ roleid = RoleID, changes = [R] },
    common_misc:unicast({role,RoleID},?DEFAULT_UNIQUE,?ROLE2,?ROLE2_ATTR_CHANGE,R_TOC).

sex_change(RoleID, NewSex) ->
   ChatRolePName = common_misc:chat_get_role_pname(RoleID),
   ?TRY_CATCH( gen_server:cast({global,mgeew_educate_server},{change_sex, RoleID, NewSex}),Err1),
   ?TRY_CATCH( global:send(ChatRolePName,{change_sex, NewSex}),Err2),
   ok.

%% @doc 角色掉血
role_reduce_hp(RoleMapInfo, SActorID, SActorType) ->
    %% 攻击者灰名
    catch mod_gray_name:change(RoleMapInfo, SActorID, SActorType),
    %% 
    #p_map_role{role_id=RoleID} = RoleMapInfo,
    mod_map_collect:stop_collect(RoleID, ?_LANG_COLLECT_BREAK),
    mod_item:stop_use_special_item(RoleID),
    ok.
