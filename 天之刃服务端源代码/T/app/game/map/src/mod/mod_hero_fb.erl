%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2011, 
%%% @doc
%%%
%%% @end
%%% Created : 28 Apr 2011 by  <>
%%%-------------------------------------------------------------------
-module(mod_hero_fb).

-include("mgeem.hrl").
-include("equip.hrl").
-export([
         handle/1,
         set_role_hero_fb_info/3,
         get_role_hero_fb_info/1,
         erase_role_hero_fb_info/1,
         get_hero_fb_map_name/2,
         get_hero_fb_quit_pos/1,
         is_in_hero_fb/0,
         get_drop_goods_name/1,
         get_role_name_color/2
        ]).
-export([is_hero_fb_map_id/1,
         assert_valid_map_id/1]).

-export([
         hook_role_online/2,
         hook_role_quit/1,
         hook_role_enter/1,
         hook_monster_dead/1,
         hook_monster_drop/3,
         hook_role_dead/0,
         hook_role_offline/1
        ]).

%%weight:int() 权重
%%reward_type:int() 奖励类型 1:声望加倍 2:奖励物品
%%reward_value:int() 奖励数值 目前在reward_type=1时有效，表示声望加倍倍数
%%reward_level:int() 奖励等级 用于告诉前端奖励的好坏
%%reward_list:list() [r_common_item_base_info()] 奖励内容 在reward_type=2时有效
-record(r_poker_reward_info,{weight=0,reward_type=0,reward_value=0,reward_level=0,reward_list=[]}).

%% 英雄副本地图信息
-record(r_hero_fb_map_info, {barrier_id, map_role_id, total_monster, remain_monster, enter_time, first_enter,
                             select_goods_list=[],reward_state=0,select_times=0,all_reward_list=[]}).
%% 奖励状态 r_hero_fb_map_info.reward_state
-define(unable_select,0). %% 不能领取
-define(can_select,1). %% 可翻牌
-define(already_select,2).   %%已翻牌
-define(already_get_reward,3).   %% 已领取

-define(hero_fb_map_info, hero_fb_map_info).
%% 最低排名
-define(max_order, 30).
%% 英雄副本死亡退出
-define(hero_fb_quit_type_relive, 1).
-define(hero_fb_quit_type_normal, 0).
%% 副本完成
-define(fb_quit_status_finish, 0).
%% 副本失败
-define(fb_quit_status_fail, 1).

%% report 返回的类型
-define(hero_fb_fail,0).
-define(hero_fb_succ,1).
-define(hero_fb_break,2).

%% 奖励类型r_poker_reward_info.reward_type
-define(multi_prestige,1).
-define(item_reward,2).

%% poker_reward op_type 
-define(select_poker,1).  %% 翻牌
-define(get_poker_reward,2).  %%获得奖励

%% 错误信息
-define(err_not_select_any_poker,1001). %%还没翻牌
-define(err_not_complete_hero_fb,1002).  %% 没完成副本
-define(err_not_in_hero_fb,1003).    %% 不在副本地图
-define(err_already_select,1004). %% 已经翻过牌了
-define(err_already_get_reward,1005). %% 已经获得奖励
-define(err_no_reward,1006). %%没有奖励
-define(err_get_reward_not_enough_pos,1007). %%背包空间不够
-define(err_unable_select,1008). %%不能选择

handle({Unique, Module, ?HERO_FB_PANEL, _DataIn, RoleID, PID, _Line, _MapState}) ->
    do_panel(Unique, Module, ?HERO_FB_PANEL, RoleID, PID);
handle({Unique, Module, ?HERO_FB_REPORT, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_report(Unique, Module, ?HERO_FB_REPORT, DataIn, RoleID, PID);
handle({Unique, Module, ?HERO_FB_ENTER, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_enter(Unique, Module, ?HERO_FB_ENTER, DataIn, RoleID, PID);
handle({Unique, Module, ?HERO_FB_QUIT, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_quit(Unique, Module, ?HERO_FB_QUIT, DataIn, RoleID, PID);
handle({Unique, Module, ?HERO_FB_REWARD, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_reward(Unique, Module, ?HERO_FB_REWARD, DataIn, RoleID, PID);
handle({Unique, Module, ?HERO_FB_BUY, _DataIn, RoleID, PID, _Line, _MapState}) ->
    do_buy(Unique, Module, ?HERO_FB_BUY, RoleID, PID);
handle({Unique, _Module, ?HERO_FB_POKER_REWARD, DataIn, RoleID, PID, _Line, _MapState}) ->
    case DataIn#m_hero_fb_poker_reward_tos.op_type of
        ?select_poker->
            do_select_poker(Unique,DataIn,RoleID,PID);
        ?get_poker_reward->
            %% 改成即翻即领  这里就不用了...
            do_get_poker_reward(Unique,DataIn,RoleID,PID);
        _->
            ?ERROR_MSG("mod_hero_fb, error poker reward msg: ~w", [DataIn])
    end;
handle({init_hero_fb_map_info, MapInfo}) ->
    set_hero_fb_map_info(MapInfo);
handle({offline_terminate}) ->
    do_offline_terminate();
handle({create_map_succ,RoleID}) ->
    do_async_create_map(RoleID);
handle({hero_fb_ranking,Info})->
    do_hero_fb_ranking(Info);
handle({hero_fb_ranking_result,Info})->
    do_hero_fb_ranking_result(Info);

handle(Info) ->
    ?ERROR_MSG("mod_hero_fb, unrecognize msg: ~w", [Info]).


%% @doc 角色上线hook
hook_role_online(_RoleID, _PID) ->
    %% do_panel(?DEFAULT_UNIQUE, ?HERO_FB, ?HERO_FB_PANEL, RoleID, PID).
    ignore.

%% @doc 物品掉落hook
hook_monster_drop(_MonsterTypeID, MonsterName, DropThingList) ->
    case get_hero_fb_map_info() of
        {ok, MapInfo} ->
            [BroadcastTypeID] = common_config_dyn:find(hero_fb, dropthing_broadcast_typeid),
            DropTypeIDList =
                lists:foldl(
                  fun(#p_map_dropthing{goodstypeid=GoodsTypeID, goodstype=GoodsType, colour=Colour}, Acc) ->
                          case lists:member(GoodsTypeID, BroadcastTypeID) of
                              true ->
                                  [{GoodsTypeID, GoodsType, Colour}|Acc];
                              _ ->
                                  Acc
                          end
                  end, [], DropThingList),
            case DropTypeIDList of
                [] ->
                    ignore;
                _ ->
                    DropNameList = get_drop_goods_name(DropTypeIDList),
                    #r_hero_fb_map_info{map_role_id=RoleID} = MapInfo,
                    {ok, #p_role_base{role_name=RoleName, faction_id=FactionID}} = mod_map_role:get_role_base(RoleID),
                    
                    Msg = io_lib:format(?_LANG_HERO_FB_DROP_BROADCAST, [get_role_name_color(RoleName, FactionID),
                                                                        MonsterName, DropNameList]),

                    common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CENTER, ?BC_MSG_TYPE_CHAT], ?BC_MSG_TYPE_CHAT_WORLD, Msg)
            end;
        _ ->
            ignore
    end.

%% @doc 怪物死亡
hook_monster_dead(MonsterBaseInfo) ->
    case get_hero_fb_map_info() of
        {ok, MapInfo} ->
            %% #p_monster_base_info{rarity=MonsterRarity} = MonsterBaseInfo,
            %% 打完BOSS副本通关
            %% case MonsterRarity of
            %%     ?BOSS ->
            %%         hook_boss_dead(MapInfo);
            %%     _ ->
            %%         ok
            %% end,
            #r_hero_fb_map_info{map_role_id=RoleID, enter_time=EnterTime,total_monster=TotalMonster, barrier_id=BarrierID} = MapInfo,
            TimeUsed = get_hero_fb_time_used(EnterTime),
            %% 清完所有怪，计时
            RemainMonsterNum = erlang:length(mod_map_monster:get_monster_id_list()) - 1,
            case RemainMonsterNum =:= 0 of
                true ->
                    ?TRY_CATCH(common_mod_goal:finish_fero_fb(RoleID, BarrierID),HookGoalHeroFbError),
                    %% 特殊任务事件
                    ?TRY_CATCH(hook_mission_event:hook_special_event(RoleID,?MISSON_EVENT_HERO_FB),MissionEventErr),
                    {ok,Score,StarLevel}=hook_boss_dead(MapInfo, TimeUsed,MonsterBaseInfo),
                    hook_monster_clear(MapInfo,TimeUsed, Score,StarLevel),
                    set_hero_fb_map_info(MapInfo#r_hero_fb_map_info{reward_state=?can_select});
                _ ->
                    ignore
            end,

            DataRecord = #m_hero_fb_state_toc{
              total_monsters=TotalMonster,
              remain_monsters=RemainMonsterNum,
              time_used=TimeUsed},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?HERO_FB, ?HERO_FB_STATE, DataRecord);
        {error, _} ->
            ignore
    end.

%% @doc BOSS挂了
hook_boss_dead(MapInfo, TimeUsed,MonsterBaseInfo) ->
    #r_hero_fb_map_info{map_role_id=RoleID, barrier_id=BarrierID} = MapInfo,
    {ok, OldRoleHeroFBInfo} = get_role_hero_fb_info(RoleID),
    {ok,RoleHeroFBInfo}=do_add_barrier_fight_times(BarrierID,OldRoleHeroFBInfo),
    #p_role_hero_fb_info{progress=Progress, rewards=Rewards, fb_record=FBRecordList} = RoleHeroFBInfo,
	[#r_hero_fb_barrier_info{prestige=AddPrestige,
                             expect_times=ExpectTimes,
                             expect_score=ExpectScore,
                             title_code=TitleCode}] = common_config_dyn:find(hero_fb, {barrier_info, BarrierID}),

    {ok,RoleAttr}=mod_map_role:get_role_attr(RoleID),
    %% 添加声望
    case common_transaction:transaction( 
           fun()->
                   RoleAttr2=RoleAttr#p_role_attr{sum_prestige=RoleAttr#p_role_attr.sum_prestige+AddPrestige,
                                                  cur_prestige=RoleAttr#p_role_attr.cur_prestige+AddPrestige},
                   mod_map_role:set_role_attr(RoleID, RoleAttr2),
                   RoleAttr2
           end ) of
        {atomic, RoleAttr2} ->
            common_misc:send_role_prestige_change(RoleID,RoleAttr2);
        {aborted, Error} ->
            ?ERROR_MSG_STACK("reset_all_online_actpoint error",Error)
    end,
    
    %% 再加分数
    [CareerScore] = common_config_dyn:find(hero_fb,{career_score,RoleAttr#p_role_attr.category}),
    EquipsScore = 
    lists:foldl(fun(Goods,Acc)->
                    case Goods#p_goods.type of 
                        ?TYPE_EQUIP->
                            [EquipBaseInfo] = common_config_dyn:find_equip(Goods#p_goods.typeid),
                            if EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_MOUNT ->
                                   Acc;
                               EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_FASHION ->
                                   Acc;
                               EquipBaseInfo#p_equip_base_info.slot_num =:= ?PUT_ADORN ->
                                   Acc;
                               true ->
                                   Acc+Goods#p_goods.refining_index
                            end;
                        _->Acc
                    end     
                end, 0, RoleAttr#p_role_attr.equips),
    LevelScore = (MonsterBaseInfo#p_monster_base_info.level-RoleAttr#p_role_attr.level)*10,
    TimeScore = (ExpectTimes*1000-TimeUsed) div 1000,
    AllScore =(if CareerScore<0 -> 0; true-> CareerScore end) +
                  (if LevelScore<0 -> 0; true-> LevelScore end) +
                  (if EquipsScore<0 -> 0; true-> (EquipsScore div 10) end) +   %%应淫龙要求改公式
                  (if TimeScore<0 -> 0; true-> TimeScore end),
    if AllScore < 0 ->
           AllScore1 = 0;
       true->
           AllScore1 = AllScore
    end,
    %%星级
    StarLevel =
        if AllScore1 > ExpectScore ->
               5;
           ExpectScore>= AllScore1 andalso AllScore1>0.8*ExpectScore ->
               4;
           0.8*ExpectScore>= AllScore1 andalso AllScore1>0.4*ExpectScore ->
               3;
           0.4*ExpectScore>= AllScore1 andalso AllScore1>0.2*ExpectScore ->
               2;
           true ->
               1
        end,
    %% 一定会有记录 没有就是错的
    Record = lists:keyfind(BarrierID, #p_hero_fb_barrier.barrier_id, FBRecordList),
    case AllScore1 >= Record#p_hero_fb_barrier.score of
        true->            
            FbRecordList2 = 
            [Record#p_hero_fb_barrier{time_used=TimeUsed,
                                     star_level = StarLevel,
                                     score = AllScore1}|lists:delete(Record, FBRecordList)];
        false->
            FbRecordList2 = FBRecordList
    end,
    %%大明英雄福本的活动奖励
    catch (hook_activity_map:hook_hero_fb(RoleID)),
    {ok, Progress2} = get_new_progress(BarrierID, Progress),
    %% 这里是不是首次完成  是首次完成加称号奖励 否则仅奖励
    case Progress2>Progress andalso TitleCode=/=0 of
        true->
            common_title:add_title(?TITLE_ROLE_HERO_FB, RoleID, TitleCode);
        false->
            next
    end,
    %% 奖励
    Rewards2 = get_chapter_reward(Rewards, Progress, Progress2),
	RoleHeroFBInfo2 = RoleHeroFBInfo#p_role_hero_fb_info{progress=Progress2, rewards=Rewards2, fb_record=FbRecordList2},
	set_role_hero_fb_info(RoleID, RoleHeroFBInfo2, true),
    {ok,AllScore1,StarLevel}.

%% @doc 怪清完了
hook_monster_clear(MapInfo, TimeUsed, Score,StarLevel) ->
    #r_hero_fb_map_info{barrier_id=BarrierID, map_role_id=RoleID} = MapInfo,
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            ignore;
        RoleMapInfo ->
            hook_monster_clear2(BarrierID, RoleMapInfo, TimeUsed,Score,StarLevel)
    end.

hook_monster_clear2(BarrierID, RoleMapInfo, TimeUsed,Score,StarLevel) ->
    #p_map_role{role_id=RoleID, role_name=RoleName, faction_id=FactionID} = RoleMapInfo,
    RoleRecord = #p_hero_fb_record{role_id=RoleID, 
                                                  role_name=RoleName,
                                                  faction_id=FactionID,
                                                  time_used=TimeUsed,
                                                  score = Score,
                                                  star_level = StarLevel},
    common_map:hero_fb_ranking({RoleID,BarrierID,RoleRecord}).

%% @doc 排行榜
%% 分数从大到小 即排名从高到低
do_hero_fb_ranking({RoleID,BarrierID,RoleRecord})->
    case db:dirty_read(?DB_HERO_FB_RECORD, BarrierID) of
        [] ->
            RecordList = [];
        [FBRecord] ->
            #r_hero_fb_record{best_record=RecordList} = FBRecord
    end,
    {Order,IsUpdate,NewRecordList}=sort_fb_record(RoleRecord,RecordList),
    case IsUpdate=:=true of
        true->
            db:dirty_write(?DB_HERO_FB_RECORD,#r_hero_fb_record{barrier_id=BarrierID,best_record = NewRecordList}),
            RoleRecord1= RoleRecord#p_hero_fb_record{order=Order};
        false->
            RoleRecord1=RoleRecord
    end, 
    [#r_hero_fb_barrier_info{barrier=Barrier,poker_count=PokerCount}]=common_config_dyn:find(hero_fb, {barrier_info,BarrierID}),
    case Order =:=1 of
        true->
            IsBreak = ?hero_fb_break,
            FirstRecord = RoleRecord1,
            %% 广播
            Lang = common_tool:get_format_lang_resources(?_LANG_HERO_FB_BREAK_RECORD, 
                                                         [common_misc:get_faction_name(RoleRecord#p_hero_fb_record.faction_id),
                                                          RoleRecord#p_hero_fb_record.role_name,
                                                          Barrier]),
            common_broadcast:bc_send_msg_world([?BC_MSG_TYPE_CENTER,?BC_MSG_TYPE_CHAT], 
                                               ?BC_MSG_TYPE_CHAT_WORLD, 
                                               Lang),
            %% 排行榜
            ?TRY_CATCH(global:send(mgeew_ranking, {ranking_element_update, ranking_hero_fb, {BarrierID, RoleRecord}}),Err);
        false->
            IsBreak = ?hero_fb_succ,
            [FirstRecord|_]=NewRecordList
    end,
    ReportToc = #m_hero_fb_report_toc{barrier_id=BarrierID,
                                      fb_record = RoleRecord1,
                                      first_record = FirstRecord,
                                      state = IsBreak,
                                      poker_count = PokerCount},
    common_misc:send_to_rolemap(RoleID, {mod_hero_fb,{hero_fb_ranking_result,{RoleID,ReportToc}}}).

%% RoleRecord:p_hero_fb_record 
%% RecordList:[p_hero_fb_record] 最好记录从高到低
%% return->{Order,IsUpdate,NewRecordList}
%% Order:int()服务器排名
%% IsUpdate:bool()是否需要重写数据库
%% NewRecordList:[p_hero_fb_record]
sort_fb_record(RoleRecord,RecordList)->
    case lists:keyfind(RoleRecord#p_hero_fb_record.role_id, #p_hero_fb_record.role_id, RecordList) of
        OldRoleRecord when is_record(OldRoleRecord,p_hero_fb_record)->
            case OldRoleRecord#p_hero_fb_record.score<RoleRecord#p_hero_fb_record.score of
                true->
                    {Order,_,NewRecordList}=sort_fb_record2(RoleRecord,lists:delete(OldRoleRecord, RecordList)),
                    IsUpdate=true;
                false->
                    {TmpOrder,_,_}=sort_fb_record2(RoleRecord,RecordList),
                    NewRecordList = RecordList,
                    Order = if TmpOrder=<?max_order -> TmpOrder; true->0 end,
                    IsUpdate=false
            end;
        false->
            {TmpOrder,_,TmpRecordList}=sort_fb_record2(RoleRecord,RecordList),
            if TmpOrder =<?max_order ->
                   Order = TmpOrder,
                   NewRecordList = lists:sublist(TmpRecordList,?max_order),
                   IsUpdate = true;
               true->
                   Order = 0,
                   NewRecordList = RecordList,
                   IsUpdate = false
            end
    end,
    {Order,IsUpdate,NewRecordList}.

sort_fb_record2(RoleRecord,RecordList)->
    NewRecordList = lists:sort(fun(R1,R2)-> R1#p_hero_fb_record.score>R2#p_hero_fb_record.score end, [RoleRecord|RecordList]),
    lists:foldr(
      fun(TmpRoleRecord,{RoleOrder,TmpOrder,TmpRecordList})->
              case TmpRoleRecord#p_hero_fb_record.role_id =:=RoleRecord#p_hero_fb_record.role_id of
                  true->
                      NewRoleOrder = TmpOrder;
                  false->
                      NewRoleOrder = RoleOrder
              end,
              {NewRoleOrder,TmpOrder-1,[TmpRoleRecord#p_hero_fb_record{order=TmpOrder}|TmpRecordList]}   
      end, {0,erlang:length(NewRecordList),[]}, NewRecordList).

do_hero_fb_ranking_result({RoleID,ReportToc})->
    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?HERO_FB, ?HERO_FB_REPORT, ReportToc).

%% 玩家死亡处理
hook_role_dead() ->
    case get_hero_fb_map_info() of
        {ok, #r_hero_fb_map_info{barrier_id=BarrierID,map_role_id=RoleID}} ->
            FirstRecord = 
                case db:dirty_read(?DB_HERO_FB_RECORD, BarrierID) of
                    [#r_hero_fb_record{best_record=RecordList}] ->
                        if RecordList=:=[] ->
                               [];
                           true->
                               [_FirstRecord|_]=RecordList,
                               _FirstRecord
                        end;
                    _->undefined
                end,
            {ok, #p_role_hero_fb_info{fail_code=FailCode}=RoleHeroFbInfo} = get_role_hero_fb_info(RoleID),
            [FailCodeNum]=common_config_dyn:find(hero_fb,fail_code_count),
            case FailCode<FailCodeNum  of
                true->
                    NextFailCode = FailCode+1;
                false->
                    NextFailCode = 1
            end,
            set_role_hero_fb_info(RoleID,RoleHeroFbInfo#p_role_hero_fb_info{fail_code=NextFailCode},false),
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?HERO_FB, ?HERO_FB_REPORT, 
                                #m_hero_fb_report_toc{barrier_id=BarrierID,
                                                      first_record = FirstRecord,
                                                      state = ?hero_fb_fail,
                                                      fail_code = FailCode});
        _ ->
            ignore
    end.


%% @doc 角色进入地图
hook_role_enter(_MapID) ->
    case get_hero_fb_map_info() of
        %% 第一次进入，进入后扣次数
        {ok, #r_hero_fb_map_info{map_role_id=RoleID, first_enter=true}=MapInfo} ->
            MonsterNum = erlang:length(mod_map_monster:get_monster_id_list()),
            MapInfo2 = MapInfo#r_hero_fb_map_info{total_monster=MonsterNum, enter_time=erlang:now(), first_enter=false},
            set_hero_fb_map_info(MapInfo2),
            %% 增加进入次数
            {ok, #p_role_hero_fb_info{today_count=TodayCount}=HeroFBInfo} = get_role_hero_fb_info(RoleID),
            %% 增加本关攻击次数
            %%{ok,HeroFBInfo1}=do_add_barrier_fight_times(MapInfo#r_hero_fb_map_info.barrier_id,HeroFBInfo),
            HeroFBInfo1 = HeroFBInfo#p_role_hero_fb_info{today_count=TodayCount+1, last_enter_time=common_tool:now()},
            set_role_hero_fb_info(RoleID, HeroFBInfo1, true),
            %% 发送副本状态
            DataRecord = #m_hero_fb_state_toc{
              total_monsters=MonsterNum,
              remain_monsters=MonsterNum,
              time_used=0},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?HERO_FB, ?HERO_FB_STATE, DataRecord);
        %% 下线后再进入，不扣次数
        {ok, MapInfo} ->
            #r_hero_fb_map_info{map_role_id=RoleID, total_monster=MonsterNum, enter_time=EnterTime}=MapInfo,
            %% 发送副本状态
            RemainMonster = erlang:length(mod_map_monster:get_monster_id_list()),
            DataRecord = #m_hero_fb_state_toc{
              total_monsters=MonsterNum,
              remain_monsters=RemainMonster,
              time_used=get_hero_fb_time_used(EnterTime)},
            common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?HERO_FB, ?HERO_FB_STATE, DataRecord);
        _ ->
            ignore
    end.

%% @doc 角色退出地图hook
hook_role_quit(RoleID) ->
    case get_hero_fb_map_info() of
        {error, _} ->
            ignore;
        {ok, HeroFBMapInfo} ->
            hook_role_quit2(RoleID, HeroFBMapInfo)
    end.

hook_role_quit2(RoleID, HeroFBMapInfo) ->
    #map_state{mapid=MapID, map_name=MapName} = mgeem_map:get_state(),
    case mod_map_actor:is_change_map_quit(RoleID) of
        {true, MapID} ->
            %% 重新打这一章
            catch do_hero_fb_log(HeroFBMapInfo),
            %% 删除所有怪物
            mod_map_monster:delete_all_monster(),
            %% 重新出生怪物
            mod_map_monster:init_monster_id_list(),
            mod_map_monster:init_map_monster(MapName, MapID);
        _ ->
            hook_role_quit3(RoleID, HeroFBMapInfo)
    end.

hook_role_quit3(RoleID, HeroFBMapInfo) ->
    case mod_map_role:is_role_exit_game(RoleID) of
        true ->
            %% 玩家在副本中退出地图，地图进程会保持一段时间
            [ProtectTime] = common_config_dyn:find(hero_fb, offline_protect_time),
            erlang:send_after(ProtectTime*1000, self(), {mod_hero_fb, {offline_terminate}});
        _ ->
            common_map:exit( hero_fb_role_quit ),
            catch do_hero_fb_log(HeroFBMapInfo)
    end.
%% 玩家下线直接帮玩家翻牌



hook_role_offline(RoleID)->
    hook_auto_get_poker_reward(RoleID).

hook_auto_get_poker_reward(RoleID)->
    case get_hero_fb_map_info() of
        {ok,MapInfo}->
            case MapInfo#r_hero_fb_map_info.reward_state of
                ?can_select->
                    role_offline_select(RoleID,MapInfo),
                    set_hero_fb_map_info(MapInfo#r_hero_fb_map_info{reward_state=?already_get_reward});
                ?already_select->
                    role_offline_get_reward(RoleID,MapInfo),
                    set_hero_fb_map_info(MapInfo#r_hero_fb_map_info{reward_state=?already_get_reward});
                _->
                    ignore
            end;
        _->
            ignore
    end.


%% 帮玩家选择 和 领奖
role_offline_select(RoleID,MapInfo)->
    #r_hero_fb_map_info{barrier_id = BarrierID}=MapInfo,
    [HeroFbBarrierInfo]=common_config_dyn:find(hero_fb, {barrier_info,BarrierID}),
    auto_select_poker(RoleID,MapInfo,HeroFbBarrierInfo).
    
%% 帮玩家领奖
auto_select_poker(RoleID,HeroMapInfo,HeroFbBarrierInfo)->
    #r_hero_fb_map_info{select_goods_list=SelectGoodsList,select_times=CurSelectTimes}=HeroMapInfo,
    #r_hero_fb_barrier_info{select_times = SelectTimes,poker_reward_list=PokerRewardList}=HeroFbBarrierInfo,
    case HeroMapInfo#r_hero_fb_map_info.all_reward_list =:=[] of
        true->
            AllRewardList=PokerRewardList;
        false->
            AllRewardList=HeroMapInfo#r_hero_fb_map_info.all_reward_list
    end,
    case AllRewardList =:= [] of
        true->
            ignore;
        false->
            {RestRewardList1,AddSelectRewardList1} =
                lists:foldl(
                  fun(_,{RestRewardList,AddSelectRewardList})-> 
                          {ok,NewRestRewardList,AddSelectReward} = get_select_reward(RestRewardList),
                          {NewRestRewardList,[AddSelectReward|AddSelectRewardList]}
                  end, {AllRewardList,[]}, lists:seq(1, SelectTimes-CurSelectTimes)),
            NewSelectGoodsList = transfer_base_info_to_reward(AddSelectRewardList1)++SelectGoodsList,
            NewHeroMapInfo = HeroMapInfo#r_hero_fb_map_info{select_goods_list=NewSelectGoodsList,
                                                            reward_state=?already_select,
                                                            select_times = SelectTimes,
                                                            all_reward_list=RestRewardList1},
            role_offline_get_reward(RoleID,NewHeroMapInfo)
    end.

role_offline_get_reward(RoleID,MapInfo)->
    #r_hero_fb_map_info{select_goods_list=SelectGoodsList,barrier_id=BarrierID}=MapInfo,
    lists:foreach(
      fun(SelectGoods)->
         case SelectGoods#p_hero_fb_poker_reward.reward_type of
             ?multi_prestige->
                 auto_get_reward_prestige(RoleID,SelectGoods,BarrierID);
             ?item_reward->
                 auto_get_reward_item(RoleID,SelectGoods)
         end
      end,SelectGoodsList).
        
auto_get_reward_prestige(RoleID,SelectGoods,BarrierID)->
    [#r_hero_fb_barrier_info{prestige=AddPrestige}]=common_config_dyn:find(hero_fb, {barrier_info,BarrierID}),
    RewardValue=SelectGoods#p_hero_fb_poker_reward.reward_value,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    RoleName = RoleAttr#p_role_attr.role_name,
    AddPrestige1 = AddPrestige*RewardValue,
    %% 添加声望
    case common_transaction:transaction( 
           fun()->
                   RoleAttr2=RoleAttr#p_role_attr{sum_prestige=RoleAttr#p_role_attr.sum_prestige+AddPrestige1,
                                                  cur_prestige=RoleAttr#p_role_attr.cur_prestige+AddPrestige1},
                   mod_map_role:set_role_attr(RoleID, RoleAttr2),
                   RoleAttr2    
           end ) of
        {atomic,RoleAttr2} ->
            common_misc:send_role_prestige_change(RoleID,RoleAttr2),
            Content = common_letter:create_temp(?HERO_FB_GET_REWARD2, [RoleName,AddPrestige1]),
            common_letter:sys2p(RoleID, Content, "战役信件",3);
        {aborted, Error} ->
            ?ERROR_MSG_STACK("reset_all_online_actpoint error",Error)
    end.

auto_get_reward_item(RoleID,SelectGoods)->
    #p_hero_fb_poker_reward{reward_list = SelectGoodsList} = SelectGoods,
    
    case common_transaction:transaction(
           fun()-> 
                   mod_bag:create_goods_by_p_goods(RoleID, SelectGoodsList) 
           end) 
        of
        {atomic,{ok,NewGoodsList}}->
            [common_item_logger:log(RoleID,Good,?LOG_ITEM_TYPE_HERO_FB_SELECT_POKER_HUO_DE)
            ||Good<-NewGoodsList],
            common_misc:new_goods_notify({role, RoleID}, NewGoodsList);
        {aborted,{bag_error,not_enough_pos}} ->
            #p_map_role{role_name=RoleName}=mod_map_actor:get_actor_mapinfo(RoleID, role),
            Content = common_letter:create_temp(?HERO_FB_GET_REWARD, [RoleName]),
            [common_letter:sys2p(RoleID, Content, "战役信件",
                                 [PGoods#p_goods{id=1,roleid=RoleID,bagid=1,bagposition=1}],3)||PGoods<-SelectGoodsList];
        {aborted,Reason}->
            ?ERROR_MSG("get poker reward error reason:~w",[Reason])
    end.

%%=============================================================
%% local
%%=============================================================
do_get_poker_reward(Unique,DataIn,RoleID,PID)->
    case catch check_can_get_poker_reward() of
        {ok,MapInfo}->
            do_get_poker_reward2(Unique,DataIn,RoleID,PID,MapInfo);
        {error,ErrCode,Reason}->
            do_poker_reward_error(Unique,DataIn,RoleID,PID,ErrCode,Reason)
    end.

check_can_get_poker_reward()->
    case get_hero_fb_map_info() of
        {ok,MapInfo}->
            next;
        false->
            MapInfo = undefined,
            throw({error,?err_not_in_hero_fb,""})
    end,
    SelectGoodsList = MapInfo#r_hero_fb_map_info.select_goods_list,
    case is_list(SelectGoodsList) andalso erlang:length(SelectGoodsList)>0 of
        true->
            {ok,MapInfo};
        false->
            {error,?err_no_reward,""}
    end.

do_get_poker_reward2(Unique,DataIn,RoleID,PID,MapInfo)->
    SelectGoodsList = MapInfo#r_hero_fb_map_info.select_goods_list,
    BarrierID = MapInfo#r_hero_fb_map_info.barrier_id,
    lists:foreach(
      fun(SelectGoods)->  
              case SelectGoods#p_hero_fb_poker_reward.reward_type of
                  ?multi_prestige->
                      do_poker_reward_prestige(Unique,DataIn,RoleID,PID,SelectGoods,BarrierID,[]);
                  ?item_reward->
                      do_poker_reward_item(Unique,DataIn,RoleID,PID,SelectGoods,[])
              end
      end, SelectGoodsList),
    set_hero_fb_map_info(MapInfo#r_hero_fb_map_info{reward_state=?already_get_reward}).
    
do_poker_reward_prestige(Unique,DataIn,RoleID,PID,SelectGoods,BarrierID,RestGoodsList)->
    [#r_hero_fb_barrier_info{prestige=AddPrestige}]=common_config_dyn:find(hero_fb, {barrier_info,BarrierID}),
    RewardValue=SelectGoods#p_hero_fb_poker_reward.reward_value,
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    AddPrestige1 = AddPrestige*RewardValue,
    %% 添加声望
    case common_transaction:transaction( 
           fun()->
                   RoleAttr2=RoleAttr#p_role_attr{sum_prestige=RoleAttr#p_role_attr.sum_prestige+AddPrestige1,
                                                  cur_prestige=RoleAttr#p_role_attr.cur_prestige+AddPrestige1},
                   mod_map_role:set_role_attr(RoleID, RoleAttr2),
                   RoleAttr2
           end ) of
        {atomic, RoleAttr2} ->
            common_misc:send_role_prestige_change(RoleID,RoleAttr2),
            R = #m_hero_fb_poker_reward_toc{op_type=DataIn#m_hero_fb_poker_reward_tos.op_type,
                                            reward_list=SelectGoods,
                                            other_list=RestGoodsList},
            common_misc:unicast2(PID, Unique, ?HERO_FB, ?HERO_FB_POKER_REWARD, R),
            IsSucc=true;
        {aborted, Error} ->
            do_poker_reward_error(Unique,DataIn,RoleID,PID,?ERR_SYS_ERR,""),
            ?ERROR_MSG_STACK("reset_all_online_actpoint error",Error),
            IsSucc=false
    end,
    {ok,IsSucc}.

do_poker_reward_item(Unique,DataIn,RoleID,PID,SelectGoods,RestGoodsList)->
    case common_transaction:transaction(
           fun()-> 
                   mod_bag:create_goods_by_p_goods(RoleID, SelectGoods#p_hero_fb_poker_reward.reward_list) 
           end) 
        of
        {atomic,{ok,[NewGoodsInfo]}}->
            common_item_logger:log(RoleID,NewGoodsInfo,?LOG_ITEM_TYPE_HERO_FB_SELECT_POKER_HUO_DE),
            common_misc:new_goods_notify({role, RoleID}, [NewGoodsInfo]),
            R = #m_hero_fb_poker_reward_toc{op_type=DataIn#m_hero_fb_poker_reward_tos.op_type,
                                            reward_list=SelectGoods,
                                            other_list=RestGoodsList},
            common_misc:unicast2(PID, Unique, ?HERO_FB, ?HERO_FB_POKER_REWARD, R),
            IsSucc = true;
        {aborted,{bag_error,not_enough_pos}} ->
            R = #m_hero_fb_poker_reward_toc{op_type=DataIn#m_hero_fb_poker_reward_tos.op_type,
                                            reward_list=SelectGoods,
                                            other_list=RestGoodsList,
                                            reason = ?_LANG_HERO_FB_GET_REWARD_FROM_LETTER_NOTICE},
            common_misc:unicast2(PID, Unique, ?HERO_FB, ?HERO_FB_POKER_REWARD, R),
            #p_map_role{role_name=RoleName}=mod_map_actor:get_actor_mapinfo(RoleID, role),
            Content = common_letter:create_temp(?HERO_FB_GET_REWARD, [RoleName]),
            common_letter:sys2p(RoleID, Content, "战役信件",SelectGoods#p_hero_fb_poker_reward.reward_list,3),
            IsSucc=true;
        {aborted,Reason}->
            ?ERROR_MSG("get poker reward error reason:~w",[Reason]),
            do_poker_reward_error(Unique,DataIn,RoleID,PID,?ERR_SYS_ERR,""),
            IsSucc=false
    end,
    {ok,IsSucc}.
            


do_select_poker(Unique,DataIn,RoleID,PID)->
    case catch check_can_select_poker(RoleID) of
        {ok,MapInfo,HeroFbBarrierInfo} ->
            do_select_poker2(Unique,DataIn,RoleID,PID,MapInfo,HeroFbBarrierInfo);
        {error,ErrCode,Reason}->
            do_poker_reward_error(Unique,DataIn,RoleID,PID,ErrCode,Reason)
    end.

check_can_select_poker(_RoleID)->
    case get_hero_fb_map_info() of
        {ok,MapInfo}->
            next;
        _->
            MapInfo= undefined,
            throw({error,?err_not_in_hero_fb,""})
    end,
    case mod_map_monster:get_monster_id_list()=:=[] of
        true->
            next;
        false->
            throw({error,?err_not_complete_hero_fb,""})
    end,
    #r_hero_fb_map_info{reward_state=RewardState,barrier_id = BarrierID,select_times=SelectTimes} = MapInfo,
    case RewardState of
        ?unable_select->
            throw({error,?err_unable_select,""});
        ?can_select->
            next;
        ?already_select->
            throw({error,?err_already_select,""});
        ?already_get_reward->
            throw({error,?err_already_get_reward,""});
        _->
            throw({error,?ERR_SYS_ERR,""})
    end,
    [#r_hero_fb_barrier_info{select_times=AbleSelectTimes}=HeroFbBarrierInfo]=
        common_config_dyn:find(hero_fb, {barrier_info,BarrierID}),
    case AbleSelectTimes>SelectTimes of
        true->
            {ok,MapInfo,HeroFbBarrierInfo};
        false->
            {error,?err_already_select,""}
    end.
            
do_select_poker2(Unique,DataIn,RoleID,PID,HeroMapInfo,HeroFbBarrierInfo)->
    #r_hero_fb_map_info{barrier_id=BarrierID,select_times=CurSelectTimes}=HeroMapInfo,
    #r_hero_fb_barrier_info{select_times=SelectTimes,poker_count=PokerCount,poker_reward_list=PokerRewardList}=HeroFbBarrierInfo,
    %% 获取候选奖励
    case HeroMapInfo#r_hero_fb_map_info.all_reward_list =:=[] of
        true->
            AllRewardList = PokerRewardList;
        false->
            AllRewardList=HeroMapInfo#r_hero_fb_map_info.all_reward_list
    end,
    
    %% 选择送给玩家的奖励
    {ok,RestRewardList,AddSelectReward} = get_select_reward(AllRewardList),
    [AddSelectGoodsInfo] = transfer_base_info_to_reward([AddSelectReward]),

    %% 翻牌是否结束
    case CurSelectTimes+1<SelectTimes of
        true->
            State = ?can_select,
            RestGoodsList = [];
        false->
            State = ?already_get_reward,
            {ok,NewRestRewardList}=get_all_poker_reward(PokerCount-SelectTimes,RestRewardList,[]),
            RestGoodsList = transfer_base_info_to_reward(NewRestRewardList)
    end,
    %%　领奖  %% 这里面的函数已经会返回了
    {ok,IsSucc} = 
    case AddSelectGoodsInfo#p_hero_fb_poker_reward.reward_type of
        ?multi_prestige->
            do_poker_reward_prestige(Unique,DataIn,RoleID,PID,AddSelectGoodsInfo,BarrierID,RestGoodsList);
        ?item_reward->
            do_poker_reward_item(Unique,DataIn,RoleID,PID,AddSelectGoodsInfo,RestGoodsList)
    end,
    case IsSucc of
        true->
            set_hero_fb_map_info(HeroMapInfo#r_hero_fb_map_info{reward_state=State,
                                                                select_times = CurSelectTimes+1,
                                                                all_reward_list=RestRewardList});
        false->
            ingore
    end.


transfer_base_info_to_reward(RewardList)->
    [begin
         case RewardType of 
             ?multi_prestige->
                 #p_hero_fb_poker_reward{reward_type = RewardType,
                                         reward_value = RewardValue,
                                         reward_level = RewardLevel};
             ?item_reward->
                 [#r_common_item_base_info{item_type = ItemType,
                                          item_id = ItemId,
                                          item_number = ItemNumber,
                                          bind = ItemBind,
                                          color = ItemColor,
                                          quality = ItemQuality,
                                          sub_quality = ItemSubQuality,
                                          reinforce = ReinforceList,
                                          punch_num = PunchNum,
                                          add_attr = AddAttr}]=RewardGoodsList,
                 {ok,GoodsList} = mod_refining_tool:get_p_goods_by_param({ItemType,
                                                                          ItemId,
                                                                          ItemNumber,
                                                                          ItemBind,
                                                                          ItemColor,
                                                                          ItemQuality,
                                                                          ItemSubQuality,
                                                                          ReinforceList,
                                                                          PunchNum,
                                                                          AddAttr}),
                 #p_hero_fb_poker_reward{reward_type = RewardType,
                                         reward_value = RewardValue,
                                         reward_level = RewardLevel,
                                         reward_list = [PGoods#p_goods{id=1,roleid=1,bagid=1,bagposition=1}||PGoods<-GoodsList]}
         end
     end
     ||#r_poker_reward_info{reward_type=RewardType,
                            reward_value=RewardValue,
                            reward_level=RewardLevel,
                            reward_list=RewardGoodsList}
                               <-RewardList].


%% 根据权重计算玩家领取的奖励
get_select_reward(RewardList)->
    Reward=lists:nth(
             mod_refining:get_random_number([Weight||#r_poker_reward_info{weight=Weight}<-RewardList], 0, 1), 
             RewardList) ,
    {ok,lists:delete(Reward, RewardList),Reward}.

%% 随机6张候选牌给玩家选
get_all_poker_reward(_,[],RewardList)->
    {ok,RewardList};
get_all_poker_reward(PokerCount,AllRewardList,RewardList)->
    case erlang:length(RewardList)>= PokerCount of
        true->
            {ok,RewardList};
        false->
            Num = random:uniform(erlang:length(AllRewardList)),
            Reward = lists:nth(Num, AllRewardList),
            get_all_poker_reward(PokerCount,lists:delete(Reward, AllRewardList),[Reward|RewardList])
    end.

do_poker_reward_error(Unique,DataIn,_RoleID,PID,ErrCode,Reason)->
    R=#m_hero_fb_poker_reward_toc{op_type=DataIn#m_hero_fb_poker_reward_tos.op_type,
                                  err_code=ErrCode,
                                  reason=Reason},
    common_misc:unicast2(PID, Unique, ?HERO_FB, ?HERO_FB_POKER_REWARD, R).



%% @doc 打开英雄副本界面
do_panel(Unique, Module, Method, RoleID, PID) ->
    case get_role_hero_fb_info(RoleID) of
        {ok, RoleHeroFBInfo} ->
            %%获取每关排名
            RoleHeroFBInfo1 = get_role_server_order(RoleID,RoleHeroFBInfo),
            RoleHeroFBInfo2 = reflash_fight_times(RoleHeroFBInfo1),
            DataRecord = #m_hero_fb_panel_toc{hero_fb=RoleHeroFBInfo2};
        _ ->
            DataRecord = #m_hero_fb_panel_toc{succ=false, reason=?_LANG_HERO_FB_PANEL_SYSTEM_ERROR}
    end,
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 战报
do_report(Unique, Module, Method, DataIn, _RoleID, PID) ->
    #m_hero_fb_report_tos{barrier_id=BarrierID} = DataIn,
    case db:dirty_read(?DB_HERO_FB_RECORD, BarrierID) of
        [] ->
            RecordList = [];
        [FBRecord] ->
            #r_hero_fb_record{best_record=RecordList} = FBRecord
    end,
    DataRecord = #m_hero_fb_report_toc{fb_record=RecordList, barrier_id=BarrierID},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 进入副本
do_enter(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_hero_fb_enter_tos{barrier_id=BarrierID} = DataIn,
    case catch check_can_enter_hero_fb(RoleID, BarrierID) of
        {ok, RoleHeroFBInfo,BarrierInfo} ->
            do_enter2(Unique, Module, Method, RoleID, PID, RoleHeroFBInfo, BarrierID,BarrierInfo);
        {error, Reason} ->
            do_enter_error(Unique, Module, Method, PID, Reason)
    end.

log_async_create_map(RoleID, {Unique, Module, Method, RoleID, PID, RoleHeroFBInfo, BarrierID, BarrierMapID, BarrierMapName}) ->
    erlang:put({hero_fb_roleid, RoleID}, {Unique, Module, Method, RoleID, PID, RoleHeroFBInfo, BarrierID, BarrierMapID, BarrierMapName}).
get_async_create_map_info(RoleID) ->
    erlang:get({hero_fb_roleid, RoleID}).

do_async_create_map(RoleID) ->
    case get_async_create_map_info(RoleID) of
        undefined ->
            ignore;
         {Unique, Module, Method, RoleID, PID, RoleHeroFBInfo, BarrierID, BarrierMapID, BarrierMapName} ->
            do_enter3(Unique, Module, Method, RoleID, PID, RoleHeroFBInfo, BarrierID, BarrierMapID, BarrierMapName)
    end.

do_enter2(Unique, Module, Method, RoleID, PID, RoleHeroFBInfo, BarrierID,BarrierInfo) ->
    %% 开启地图
    %%[BarrierInfo] = common_config_dyn:find(hero_fb, {barrier_info, BarrierID}),
    #r_hero_fb_barrier_info{map_id=BarrierMapID} = BarrierInfo,
    #map_state{mapid=CurrentMapID, map_name=CurrentMapName} = mgeem_map:get_state(),
    %% 如果当前已经在该地图
    case CurrentMapID =:= BarrierMapID of
        true ->
            do_enter3(Unique, Module, Method, RoleID, PID, RoleHeroFBInfo, BarrierID, CurrentMapID, CurrentMapName);
        _ ->
            BarrierMapName = get_hero_fb_map_name(BarrierMapID, RoleID),
            case global:whereis_name(BarrierMapName) of
                undefined ->
                    mod_map_copy:async_create_copy(BarrierMapID, BarrierMapName, ?MODULE, RoleID),
                    log_async_create_map(RoleID, {Unique, Module, Method, RoleID, PID, RoleHeroFBInfo, BarrierID, BarrierMapID, BarrierMapName});
                _MPID ->
                    do_enter3(Unique, Module, Method, RoleID, PID, RoleHeroFBInfo, BarrierID, BarrierMapID, BarrierMapName)
            end
    end.

do_enter3(Unique, Module, Method, RoleID, PID, RoleHeroFBInfo, BarrierID, BarrierMapID, BarrierMapName) ->
    hook_auto_get_poker_reward(RoleID),
    common_misc:unicast2(PID, Unique, Module, Method, #m_hero_fb_enter_toc{}),
    %% 增加活跃度，前再次挑战
    #p_role_hero_fb_info{today_count=TodayCount} = RoleHeroFBInfo,
    case TodayCount < 2 of
        true ->
            (catch hook_activity_task:done_task(RoleID, ?ACTIVITY_TASK_PERSON_FB));
        _ ->
            ignore
    end,
    CurMapID = mgeem_map:get_mapid(),
    case is_hero_fb_map_id(CurMapID) of
        true->
            ignore;
        false->
            case  mod_map_actor:get_actor_pos(RoleID, role) of
                undefined->
                    ignore;
                Pos->
                    set_role_hero_fb_info(RoleID, RoleHeroFBInfo#p_role_hero_fb_info{enter_pos = Pos ,enter_mapid = CurMapID}, false)
            end
    end,
    %% 初始化英雄副本地图信息
    MapInfo = #r_hero_fb_map_info{barrier_id=BarrierID, map_role_id=RoleID, first_enter=true},
    global:send(BarrierMapName, {mod_hero_fb, {init_hero_fb_map_info, MapInfo}}),
    %% 传送到新地图
    {_, TX, TY} = common_misc:get_born_info_by_map(BarrierMapID),
    mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, BarrierMapID, TX, TY).

do_enter_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_hero_fb_enter_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 退出地图
do_quit(Unique, Module, Method, DataIn, RoleID, PID) ->
    case catch check_can_quit_hero_fb(RoleID) of
        {ok, RoleMapInfo} ->
            do_quit2(Unique, Module, Method, DataIn, RoleID, PID, RoleMapInfo);
        {error, Reason} ->
            do_quit_error(Unique, Module, Method, PID, Reason)
    end.

do_quit2(Unique, Module, Method, DataIn, RoleID, PID, RoleMapInfo) ->
    common_misc:unicast2(PID, Unique, Module, Method, #m_hero_fb_quit_toc{}),
    #m_hero_fb_quit_tos{quit_type=QuitType} = DataIn,
    case QuitType of
        %% 在副本死亡退出
        ?hero_fb_quit_type_relive ->
            mod_role2:do_relive(?DEFAULT_UNIQUE, ?ROLE2, ?ROLE2_RELIVE, RoleID, ?RELIVE_TYPE_PLAIN);
        %% 主动退出
        ?hero_fb_quit_type_normal ->
            ignore
    end,
    hook_auto_get_poker_reward(RoleID),
    {ok,#p_role_hero_fb_info{enter_pos=EnterPos,enter_mapid=EnterMapID}}=get_role_hero_fb_info(RoleID),
    case is_record(EnterPos,p_pos) 
             andalso erlang:is_integer(EnterMapID) 
             andalso EnterMapID>0 of
        true->
            mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, EnterMapID, EnterPos#p_pos.tx, EnterPos#p_pos.ty);
        false->
            #p_map_role{faction_id=FactionID} = RoleMapInfo,
            {MapID, TX, TY} = get_hero_fb_quit_pos(FactionID),
            mod_map_role:diff_map_change_pos(?CHANGE_MAP_TYPE_NORMAL, RoleID, MapID, TX, TY)
    end.

do_quit_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_hero_fb_quit_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 领取奖励
do_reward(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_hero_fb_reward_tos{reward_id=RewardID} = DataIn,
    case catch check_can_get_reward(RoleID, RewardID) of
        {ok, RoleHeroFBInfo} ->
            do_reward2(Unique, Module, Method, RoleID, PID, RewardID, RoleHeroFBInfo);
        {error, Reason} ->
            do_reward_error(Unique, Module, Method, PID, Reason)
    end.

do_reward2(Unique, Module, Method, RoleID, PID, RewardID, RoleHeroFBInfo) ->
    case common_transaction:t(
           fun() ->
                   t_do_reward(RoleID, RewardID, RoleHeroFBInfo)
           end)
    of
        {atomic, {GoodsInfo, RoleHeroFBInfo2}} ->
            Record = #m_hero_fb_reward_toc{},
            common_misc:unicast2(PID, Unique, Module, Method, Record),
            %% 
            DataRecord = #m_hero_fb_panel_toc{hero_fb=get_role_server_order(RoleID,RoleHeroFBInfo2)},
            common_misc:unicast2(PID, ?DEFAULT_UNIQUE, ?HERO_FB, ?HERO_FB_PANEL, DataRecord),
            %% 通知背包变动
            common_misc:new_goods_notify({role, RoleID}, GoodsInfo);
        {aborted, {bag_error, _}} ->
            do_reward_error(Unique, Module, Method, PID, ?_LANG_HERO_FB_REWARD_BAG_FULL);
        {aborted, Reason} ->
            ?ERROR_MSG("do_reward2, error, reason: ~w", [Reason]),
            do_reward_error(Unique, Module, Method, PID, ?_LANG_HERO_FB_REWARD_SYSTEM_ERROR)
    end.

do_reward_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_hero_fb_reward_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 购买挑战次数
do_buy(Unique, Module, Method, RoleID, PID) ->
    case catch check_can_buy(RoleID) of
        {ok, RoleHeroFBInfo} ->
            do_buy2(Unique, Module, Method, RoleID, PID, RoleHeroFBInfo);
        {error, Reason} ->
            do_buy_error(Unique, Module, Method, PID, Reason)
    end.

do_buy2(Unique, Module, Method, RoleID, PID, RoleHeroFBInfo) ->
    case common_transaction:t(
           fun() ->
                   t_do_buy(RoleHeroFBInfo)
           end)
    of
        {atomic, {RoleHeroFBInfo2, Gold, GoldBind}} ->
            #p_role_hero_fb_info{max_enter_times=MaxEnterTimes, buy_count=BuyCount} = RoleHeroFBInfo2,
            DataRecord = #m_hero_fb_buy_toc{max_enter_times=MaxEnterTimes, buy_count=BuyCount},
            common_misc:unicast2(PID, Unique, Module, Method, DataRecord),
            %% 元宝变动
            ChangeAttrList = [
                              #p_role_attr_change{change_type=?ROLE_GOLD_CHANGE, new_value=Gold},
                              #p_role_attr_change{change_type=?ROLE_GOLD_BIND_CHANGE, new_value=GoldBind}],
            common_misc:role_attr_change_notify({role, RoleID}, RoleID, ChangeAttrList);
        {aborted, Reason} when is_binary(Reason) ->
            do_buy_error(Unique, Module, Method, PID, Reason);
        {aborted, Reason} ->
            ?ERROR_MSG("do_buy2, error, reason: ~w", [Reason]),
            do_buy_error(Unique, Module, Method, PID, ?_LANG_HERO_FB_BUY_SYSTEM_ERROR)
    end.

do_buy_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_hero_fb_buy_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

t_do_buy(RoleHeroFBInfo) ->
    #p_role_hero_fb_info{role_id=RoleID, buy_count=BuyCount, max_enter_times=MaxEnterTimes} = RoleHeroFBInfo,
    {ok, RoleAttr} = mod_map_role:get_role_attr(RoleID),
    #p_role_attr{gold=Gold, gold_bind=GoldBind} = RoleAttr,
    [DefaultGold] = common_config_dyn:find(hero_fb, buy_default_gold),
    [GoldStep] = common_config_dyn:find(hero_fb, buy_gold_step),
    [MaxNeed] = common_config_dyn:find(hero_fb, max_gold),
    GoldNeed = DefaultGold + BuyCount * GoldStep,
    case GoldNeed > MaxNeed of
        true ->
            GoldNeed2 = MaxNeed;
        _ ->
            GoldNeed2 = GoldNeed
    end, 
    case Gold + GoldBind < GoldNeed2 of
        true ->
            common_transaction:abort(?_LANG_HERO_FB_BUY_NOT_ENOUGH_GOLD);
        _ ->
            ok
    end,
    {Gold2, GoldBind2} = mod_role2:calc_rest_money(Gold, GoldBind, GoldNeed2),
    %% 消费日志
    common_consume_logger:use_gold({RoleID, GoldBind-GoldBind2, Gold-Gold2, ?CONSUME_TYPE_GOLD_BUY_HERO_FB_TIMES,
                                      ""}),
    RoleAttr2 = RoleAttr#p_role_attr{gold=Gold2, gold_bind=GoldBind2},
    mod_map_role:set_role_attr(RoleID, RoleAttr2),
    RoleHeroFBInfo2 = RoleHeroFBInfo#p_role_hero_fb_info{buy_count=BuyCount+1, max_enter_times=MaxEnterTimes+1},
    t_set_role_hero_fb_info(RoleID, RoleHeroFBInfo2),
    {RoleHeroFBInfo2, Gold2, GoldBind2}.

check_can_buy(RoleID) ->
    {ok, RoleHeroFBInfo} = get_role_hero_fb_info(RoleID),
    #p_role_hero_fb_info{buy_count=BuyCount} = RoleHeroFBInfo,
    [MaxBuyTimes] = common_config_dyn:find(hero_fb, max_buy_times),
    case BuyCount >= MaxBuyTimes of
        true ->
            throw({error, ?_LANG_HERO_FB_BUY_MAX_TIMES});
        _ ->
            ok
    end,
    {ok, RoleHeroFBInfo}.

t_do_reward(RoleID, RewardID, RoleHeroFBInfo) ->
    #p_role_hero_fb_info{rewards=Rewards} = RoleHeroFBInfo,
    RoleHeroFBInfo2 = RoleHeroFBInfo#p_role_hero_fb_info{rewards=lists:delete(RewardID, Rewards)},
    t_set_role_hero_fb_info(RoleID, RoleHeroFBInfo2),
    
    [RewardList] = common_config_dyn:find(hero_fb, chapter_reward),
    RewardRecord = lists:keyfind(RewardID, #r_item_gift_base.id, RewardList),
    {ok, GoodsList} = mod_gift:get_p_goods_by_item_gift_base_record(RewardRecord),
    {ok, GoodsList2} = mod_bag:create_goods_by_p_goods(RoleID, GoodsList),
    {GoodsList2, RoleHeroFBInfo2}.

%% @doc 是否可以领取奖励
check_can_get_reward(RoleID, RewardID) ->
    {ok, RoleHeroFBInfo} = get_role_hero_fb_info(RoleID),
    #p_role_hero_fb_info{rewards=Rewards} = RoleHeroFBInfo,
    case lists:member(RewardID, Rewards) of
        true ->
            {ok, RoleHeroFBInfo};
        _ ->
            {error, ?_LANG_HERO_FB_REWARD_EVER_GOT}
    end.

%% @doc 是否可以退出副本
check_can_quit_hero_fb(RoleID) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            RoleMapInfo = undefined,
            erlang:throw({error, ?_LANG_HERO_FB_QUTI_SYSTEM_ERROR});
        RoleMapInfo ->
            ok
    end,
    {ok, RoleMapInfo}.

assert_valid_map_id(DestMapID)->
    case is_hero_fb_map_id(DestMapID) of
        true->
            ok;
        _ ->
            ?ERROR_MSG("严重，试图进入错误的地图,DestMapID=~w",[DestMapID]),
            throw({error,error_map_id,DestMapID})
    end.

is_hero_fb_map_id(DestMapID)->
    [HeroFBMapIDList] = common_config_dyn:find(hero_fb, fb_map_id_list),
    lists:member(DestMapID, HeroFBMapIDList).

%% @doc 获取英雄副本地图进程名
get_hero_fb_map_name(MapID, RoleID) ->
    lists:concat(["mgee_personal_fb_map_", MapID, "_", RoleID]).

%% @doc 是否可以进入英雄副本
check_can_enter_hero_fb(RoleID, BarrierID) ->
    case mod_map_actor:get_actor_mapinfo(RoleID, role) of
        undefined ->
            RoleMapInfo = undefined,
            erlang:throw({error, ?_LANG_HERO_FB_ENTER_SYSTEM_ERROR});
        RoleMapInfo ->
            ok
    end,
    %% 是否达到最小进入等级
    [MinLevel] = common_config_dyn:find(hero_fb, min_enter_level),
    #p_map_role{level=Level, state=RoleState, pos=_Pos,faction_id=FactionID} = RoleMapInfo,
    case Level < MinLevel of
        true ->
            erlang:throw({error, common_tool:get_format_lang_resources(?_LANG_HERO_FB_ENTER_LEVEL_LIMITED, [MinLevel])});
        _ ->
            ok
    end,
    %% 检查是否副本地图 除英雄副本    
    MapID = mgeem_map:get_mapid(),
    case ets:lookup(?ETS_MAPS, MapID) of
        [{_, 0}] ->
            %% 是否在外国
            case FactionID =:=(MapID div 1000) rem 10 of
                true->
                    next;
                false ->
                    throw({error,?_LANG_HERO_FB_FOREIGET_ENTER_MAP})
            end;
        _->
            case is_hero_fb_map_id(MapID) of
                true->
                    next;
                false->
                    throw({error,?_LANG_HERO_FB_ILLEGAL_ENTER_MAP})
            end
    end,
    
    %% 角色状态检测
    case RoleState of
        ?ROLE_STATE_DEAD ->
            erlang:throw({error, ?_LANG_HERO_FB_ENTER_ROLE_DEAD});
        ?ROLE_STATE_STALL ->
            erlang:throw({error, ?_LANG_HERO_FB_ENTER_ROLE_STALL});
        ?ROLE_STATE_TRAINING ->
            erlang:throw({error, ?_LANG_HERO_FB_ENTER_ROLE_TRAINING});
        ?ROLE_STATE_FIGHT->
            erlang:throw({error, ?_LANG_HERO_FB_ENTER_ROLE_FIGHT});
        _ ->
            ok
    end,
    %% todo：与NPC距离检测
    case get_role_hero_fb_info(RoleID) of
        {ok, RoleHeroFBInfo} ->
            ok;
        _ ->
            RoleHeroFBInfo = undefined,
            erlang:throw({error, ?_LANG_HERO_FB_ENTER_SYSTEM_ERROR})
    end,
    %% 关卡有没开通
    #p_role_hero_fb_info{progress=Progress, today_count=TodayCount, max_enter_times=MaxTimes,
                         fb_record=HeroFBRecordList,last_enter_time=LastEnterTime} = RoleHeroFBInfo,
    case BarrierID > Progress of
        true ->
            erlang:throw({error, ?_LANG_HERO_FB_ENTER_BARRIER_LOCK});
        _ ->
            ok
    end,
    %% 每日进入次数检查
    case TodayCount >= MaxTimes of
        true ->
            erlang:throw({error, ?_LANG_HERO_FB_ENTER_TIMES_LIMITED});
        _ ->
            ok
    end,
    BarrierInfo =
    case common_config_dyn:find(hero_fb, {barrier_info, BarrierID}) of
        []->
            throw({error,?_LANG_HERO_FB_ENTER_SYSTEM_ERROR});
        [_BarrierInfo]->
            _BarrierInfo
    end,    
    
    {ok,LastReFleshTime} = get_last_reflesh_time(date(),mgeem_map:get_now()),
    case LastEnterTime>LastReFleshTime of
        true->
            next;
        false->
            %% =====此处会重设副本攻击次数=====
            do_reset_barrier_fight_times(RoleID,RoleHeroFBInfo),
            throw({ok, RoleHeroFBInfo,BarrierInfo})
    end,
    %% 获取打关次数
    FightTimes = 
    case lists:keyfind(BarrierID, #p_hero_fb_barrier.barrier_id, HeroFBRecordList) of
        false->
            throw({ok, RoleHeroFBInfo,BarrierInfo});
        #p_hero_fb_barrier{fight_times=_FightTimes}->
            _FightTimes
    end,
    %% 打击次数
    case FightTimes>0 of
        true->
            next;
        false->
            throw({error,?_LANG_HERO_FB_ENTER_ONE_BARRIER_LIMITED})
    end,
    {ok, RoleHeroFBInfo,BarrierInfo}.


%% @doc 清除角色英雄副本信息
erase_role_hero_fb_info(RoleID) ->
    {ok, HeroFBInfo} = get_role_hero_fb_info(RoleID),
    mgeem_persistent:role_hero_fb_persistent(HeroFBInfo),
    erlang:erase({?role_hero_fb, RoleID}).    

%% @doc 添加单关攻击次数  不写进程字典  
do_add_barrier_fight_times(BarrierID,HeroFBInfo)->
    FightTimes =
         case common_config_dyn:find(hero_fb, {barrier_info,BarrierID}) of
             []->1;
             [#r_hero_fb_barrier_info{fight_times=_FightTimes}]->
                 _FightTimes
         end,
    HeroFbRecordList = HeroFBInfo#p_role_hero_fb_info.fb_record,
    NewHeroFbRecordList = 
    case lists:keyfind(BarrierID,#p_hero_fb_barrier.barrier_id,HeroFbRecordList) of
        false->
            [#p_hero_fb_barrier{barrier_id=BarrierID,fight_times=FightTimes-1}|HeroFbRecordList];
        #p_hero_fb_barrier{fight_times=Times}=HeroFbRecord->
            [HeroFbRecord#p_hero_fb_barrier{fight_times=Times-1}|lists:delete(HeroFbRecord, HeroFbRecordList)]
    end,
    {ok,HeroFBInfo#p_role_hero_fb_info{fb_record=NewHeroFbRecordList}}.
%% @doc 重设单关攻击次数 写进程字典
do_reset_barrier_fight_times(RoleID,HeroFBInfo)->
    NewHeroFBInfoList = 
    [begin
         FightTimes =
         case common_config_dyn:find(hero_fb, {barrier_info,BarrierID}) of
             []->1;
             [#r_hero_fb_barrier_info{fight_times=_FightTimes}]->
                 _FightTimes
         end,
        HeroFBBarrierInfo#p_hero_fb_barrier{fight_times=FightTimes}
     end
    || #p_hero_fb_barrier{barrier_id=BarrierID}=HeroFBBarrierInfo <-HeroFBInfo#p_role_hero_fb_info.fb_record],
    NewHeroFBInfo = HeroFBInfo#p_role_hero_fb_info{fb_record=NewHeroFBInfoList},
    set_role_hero_fb_info(RoleID, NewHeroFBInfo, false),
    {ok,NewHeroFBInfo}.

%%[p_hero_fb_barrier]
get_role_server_order(RoleID,RoleHeroFbInfo)->
    #p_role_hero_fb_info{fb_record=RoleHeroFbList} = RoleHeroFbInfo,
    RoleHeroFbList1 =
    [begin
         Order = 
             case db:dirty_read(?DB_HERO_FB_RECORD,BarrierID) of
                 []->0;
                 [#r_hero_fb_record{best_record=RecordList}]->
                     case lists:keyfind(RoleID, #p_hero_fb_record.role_id, RecordList) of
                         false->0;
                         #p_hero_fb_record{order=_Order}->_Order
                     end
             end,
         RoleHeroFb#p_hero_fb_barrier{order=Order}
     end||#p_hero_fb_barrier{barrier_id=BarrierID} = RoleHeroFb<-RoleHeroFbList],
    RoleHeroFbInfo#p_role_hero_fb_info{fb_record=RoleHeroFbList1}.

reflash_fight_times(RoleHeroFBInfo)->
    #p_role_hero_fb_info{role_id=RoleID,last_enter_time=LastEnterTime} = RoleHeroFBInfo,
    %% 记录时间检测
    {ok,LastRefleshTime} = get_last_reflesh_time(date(),mgeem_map:get_now()),
    case LastEnterTime > LastRefleshTime of
        true->
            RoleHeroFBInfo;
        false->
            {ok,RoleHeroFBInfo1} = do_reset_barrier_fight_times(RoleID,RoleHeroFBInfo),
            RoleHeroFBInfo1
    end.
    
%% @doc 获取角色副本信息
get_role_hero_fb_info(RoleID) ->
    case erlang:get({?role_hero_fb, RoleID}) of
        undefined ->
            [MaxEnterTimes] = common_config_dyn:find(hero_fb, max_times_per_day),
            RoleHeroFBInfo = #p_role_hero_fb_info{
              role_id=RoleID,
              last_enter_time=common_tool:now(),
              today_count=0,
              progress=101,
              rewards=[],
              fb_record=[],
              max_enter_times=MaxEnterTimes,
              buy_count=0
             },
            {ok, RoleHeroFBInfo};
        RoleHeroFBInfo ->
            #p_role_hero_fb_info{role_id=RoleID, last_enter_time=LastEnterTime} = RoleHeroFBInfo,
            EnterDate = common_time:time_to_date(LastEnterTime),
            NowDate = erlang:date(),
            case EnterDate =:= NowDate andalso LastEnterTime =/= 0 of
                true ->
                    RoleHeroFBInfo2 = RoleHeroFBInfo;
                _ ->
                    [MaxEnterTimes] = common_config_dyn:find(hero_fb, max_times_per_day),
                    RoleHeroFBInfo2 = RoleHeroFBInfo#p_role_hero_fb_info{
                                        today_count=0,
                                        max_enter_times=MaxEnterTimes, 
                                        buy_count=0, 
                                        last_enter_time=common_tool:now()},
                    set_role_hero_fb_info(RoleID, RoleHeroFBInfo2, true)
            end,
            {ok, RoleHeroFBInfo2}
    end.

%% @doc 设置角色副本信息
set_role_hero_fb_info(RoleID, RoleHeroFB2, IsNotify) ->
    case common_transaction:t(
           fun() ->
                   t_set_role_hero_fb_info(RoleID, RoleHeroFB2)
           end)
    of
        {atomic, _} ->
            case IsNotify of
                true ->
                    DataRecord = #m_hero_fb_panel_toc{hero_fb=get_role_server_order(RoleID,RoleHeroFB2)},
                    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?HERO_FB, ?HERO_FB_PANEL, DataRecord);
                _ ->
                    ignore
            end,
            ok;
        {aborted, Reason} ->
            ?ERROR_MSG("set_role_hero_fb_info, error, reason: ~w", [Reason]),
            error
    end.

%% @doc 
t_set_role_hero_fb_info(RoleID, RoleHeroFB) ->
    mod_map_role:update_role_id_list_in_transaction(RoleID, ?role_hero_fb, ?role_hero_fb_copy),
    erlang:put({?role_hero_fb, RoleID}, RoleHeroFB).

%% @doc 设置英雄副本地图信息
set_hero_fb_map_info(MapInfo) ->
    erlang:put(?hero_fb_map_info, MapInfo).

%% @doc 获取英雄副本地图信息
get_hero_fb_map_info() ->
    case erlang:get(?hero_fb_map_info) of
        undefined ->
            {error, not_found};
        MapInfo ->
            {ok, MapInfo}
    end.

%% @doc 计算闯关时间(ms)
get_hero_fb_time_used(EnterTime) ->
    timer:now_diff(erlang:now(), EnterTime) div 1000.

%% @doc 获取下一关卡ID
get_new_progress(BarrierID, Progress) ->
    case Progress > BarrierID of
        true ->
            {ok, Progress};
        _ ->
            [BarrierInfo] = common_config_dyn:find(hero_fb, {barrier_info, BarrierID}),
            #r_hero_fb_barrier_info{next_barrier_id=NextBarrierID} = BarrierInfo,
            {ok, NextBarrierID}
    end.

%% @doc 获取排名 排名为从分数低到高
%% get_rank_order(Score, Order, [#p_hero_fb_record{score=Sc}|T]) ->
%%     case Score =< Sc of
%%         true ->
%%             {ok, Order};
%%         _ ->
%%             get_rank_order(Score, Order-1, T)
%%     end;
%% get_rank_order(_Score, Order, []) ->
%%     {ok, Order}.

%% @doc 获取掉落物名称
get_drop_goods_name(DropTypeIDList) ->
    DropNameList =
        lists:map(
          fun({TypeID, Type, Colour}) ->
                  case Type of
                      ?TYPE_EQUIP ->
                          {ok, #p_equip_base_info{equipname=GoodsName, colour=BColour}} = mod_equip:get_equip_baseinfo(TypeID);
                      ?TYPE_STONE ->
                          {ok, #p_stone_base_info{stonename=GoodsName, colour=BColour}} = mod_stone:get_stone_baseinfo(TypeID);
                      _ ->
                          {ok, #p_item_base_info{itemname=GoodsName, colour=BColour}} = mod_item:get_item_baseinfo(TypeID)
                  end,

                  case Colour of
                      ?COLOUR_WHITE ->
                          Colour2 = BColour;
                      _ ->
                          Colour2 = Colour
                  end,
                  
                  case Colour2 of
                      ?COLOUR_GREEN->
                          io_lib:format("<font color=\"#12CC95\">【~s】</font>", [GoodsName]);
                      ?COLOUR_BLUE->
                          io_lib:format("<font color=\"#0D79FF\">【~s】</font>", [GoodsName]);
                      ?COLOUR_PURPLE->
                          io_lib:format("<font color=\"#FE00E9\">【~s】</font>", [GoodsName]);
                      ?COLOUR_ORANGE->
                          io_lib:format("<font color=\"#FF7E00\">【~s】</font>", [GoodsName]);
                      ?COLOUR_GOLD->
                          io_lib:format("<font color=\"#FFD700\">【~s】</font>", [GoodsName]);
                      _ ->
                          io_lib:format("<font color=\"#FFFFFF\">【~s】</font>", [GoodsName])
                  end
          end, DropTypeIDList),
    
    string:join(DropNameList, "、"). 

%% @doc 获取跳转点位置
get_hero_fb_quit_pos(FactionID) ->
    [PosList] = common_config_dyn:find(hero_fb, npc_pos),
    {_, {MapID, TX, TY}} = lists:keyfind(FactionID, 1, PosList),
    {MapID, TX, TY}.

%% 各国ID
-define(faction_hongwu, 1).
-define(faction_yongle, 2).
-define(faction_wanli, 3).

%% @doc 获取角色名字，包涵国家颜色
get_role_name_color(RoleName, FactionID) ->
    case FactionID of
        ?faction_hongwu ->
            io_lib:format("<font color=\"#00FF00\">[~s]</font>", [RoleName]);
        ?faction_yongle ->
            io_lib:format("<font color=\"#F600FF\">[~s]</font>", [RoleName]);
        _ ->
            io_lib:format("<font color=\"#00CCFF\">[~s]</font>", [RoleName])
    end.

%% @doc 下线保护时间到，如果角色不在副本中杀掉副本地图进程
do_offline_terminate() ->
    case get_hero_fb_map_info() of
        {ok, MapInfo} ->
            #r_hero_fb_map_info{map_role_id=RoleID} = MapInfo,
            case mod_map_actor:get_actor_mapinfo(RoleID, role) of
                undefined ->
                    common_map:exit( hero_fb_role_quit ),
                    catch do_hero_fb_log(MapInfo);
                _ ->
                    ignore
            end;
        _ ->
            common_map:exit( hero_fb_role_quit )
    end.

%% @doc 是否在英雄副本中
is_in_hero_fb() ->
    case get_hero_fb_map_info() of
        {ok, _} ->
            true;
        _ ->
            false
    end.

%% @doc 通关奖励，首次完成一章会得到奖励
get_chapter_reward(Rewards, Progress, Progress2) ->
    OldChapter = Progress div 100,
    NewChapter = Progress2 div 100,
    case OldChapter =:= NewChapter of
        true ->
            Rewards;
        _ ->
            [OldChapter|Rewards]
    end.

%% @doc 英雄副本日志
do_hero_fb_log(HeroFBMapInfo) ->
    #r_hero_fb_map_info{map_role_id=RoleID, barrier_id=BarrierID, enter_time=EnterTime} = HeroFBMapInfo,
    RemainMonster = erlang:length(mod_map_monster:get_monster_id_list()),
    case RemainMonster =:= 0 of
        true ->
            Status = ?fb_quit_status_finish;
        _ ->
            Status = ?fb_quit_status_fail
    end,
    {ok, #p_role_base{role_name=RoleName, faction_id=FactionID}} = common_misc:get_dirty_role_base(RoleID),
    {A, B, _} = EnterTime,
    EnterTime2 = A * 1000000 + B,
    StopTime = common_tool:now(),

    PersonalFBLog = #r_personal_fb_log{role_id=RoleID,
                                       role_name=RoleName,
                                       faction_id=FactionID,
                                       fb_id=BarrierID,
                                       start_time=EnterTime2,
                                       end_time=StopTime,
                                       status=Status},
    common_general_log_server:log_personal_fb(PersonalFBLog).

%% 获取上次刷新次数时间
get_last_reflesh_time(Date,Now)->
    [ReFleshTimeList]=common_config_dyn:find(hero_fb,reflash_times_list),
    LastReFleshTime=common_tool:datetime_to_seconds({Date,lists:last(ReFleshTimeList)})-86400,
    get_last_reflesh_time(LastReFleshTime,ReFleshTimeList,Date,Now).
    
get_last_reflesh_time(LastReFleshTime,[],_Date,_Now)->
    {ok,LastReFleshTime};
get_last_reflesh_time(LastReFleshTime,[H|RestTimeList],Date,Now)->
    NextReFleshTime = common_tool:datetime_to_seconds({Date,H}),
    case Now<NextReFleshTime of
        true->
            {ok,LastReFleshTime};
        false->
            get_last_reflesh_time(NextReFleshTime,RestTimeList,Date,Now)
    end.
