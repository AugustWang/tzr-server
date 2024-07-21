-module(update_mnesia_0_1_6).

-compile(export_all).

-record(p_role_goal, {role_id,goals,days}).
-record(r_db_mission_data, {role_id, mission_data}).
-record(mission_data, {last_store_time=0,data_version=0,mission_list=[],tutorial_list=[],listener_list=[],counter_list=[],auto_list=[],extend_list=[]}).
-record(mission_counter, {key={0, 0},id=0,big_group=0,last_clear_counter_time=0,commit_times=0,succ_times=0,other_data=null}).
-record(mission_base_info, {id,name,type=0,model,big_group=0,small_group=0,time_limit_type=0,time_limit=[],pre_mission_id=0,next_mission_list=[],pre_prop_list=[],gender=0,faction=0,team=0,family=0,min_level=0,max_level=0,max_do_times=1,listener_list=[],max_model_status=0,model_status_data=[],reward_data}).
connect_db() ->
    [MasterHost] = common_config_dyn:find_common(master_host),
    net_kernel:connect_node(erlang:list_to_atom(lists:concat(["master@", MasterHost]))),
    common_db:join_group(),
    ok.

update() ->
    connect_db(),
    code:load_file(common_config_dyn),
    common_config_dyn:init(),
    update_db_role_hero_fb_info(),
    clear_not_exist_mission_id(),
    clear_role_goal_info(),
    ok.


update_db_role_hero_fb_info() ->
    TransFormer = 
        fun(R) ->
               case R of
                   {p_role_hero_fb_info,ROLE_ID,LAST_ENTER_TIME,TODAY_COUNT,PROGRESS,REWARDS,FB_RECORD,MAX_ENTER_TIMES,BUY_COUNT,ENTER_MAPID,ENTER_POS} ->
                        {p_role_hero_fb_info,ROLE_ID,LAST_ENTER_TIME,TODAY_COUNT,PROGRESS,REWARDS,FB_RECORD,MAX_ENTER_TIMES,BUY_COUNT,ENTER_MAPID,ENTER_POS,1};
                   _ ->
                       R
               end
        end,
    Fields = [role_id,last_enter_time,today_count,progress,rewards,fb_record,max_enter_times,buy_count,enter_mapid,enter_pos,fail_code],
    {atomic, ok} = mnesia:transform_table(db_role_hero_fb_p, TransFormer, Fields, p_role_hero_fb_info).

%% 处理任务数据，删除没有的任务id
clear_not_exist_mission_id() ->
    MissionDataList = db:dirty_match_object(db_mission_data_p,#r_db_mission_data{ _ ='_' }),
    lists:foreach(
      fun(DBMissionData) ->
              MissionData = DBMissionData#r_db_mission_data.mission_data,
              CounterList = 
                  lists:foldl(
                    fun(CounterRecord,AccCounterList) ->
                            case catch mod_mission_data:get_base_info(CounterRecord#mission_counter.id) of
                                MissionBaseInfo when erlang:is_record(MissionBaseInfo, mission_base_info) ->
                                    [CounterRecord|AccCounterList];
                                _ ->
                                    AccCounterList
                            end
                    end, [], MissionData#mission_data.counter_list),
              DBMissionData2 = DBMissionData#r_db_mission_data{mission_data = MissionData#mission_data{mission_list = [],listener_list = [],counter_list = CounterList}},
              db:dirty_write(db_mission_data_p,DBMissionData2)
      end,MissionDataList),
    ok.
%% 清空玩家目标数据
clear_role_goal_info() ->
    RoleGoalList = db:dirty_match_object(db_role_goal_p,#p_role_goal{ _ ='_' }),
    lists:foreach(
      fun(RoleGoal) ->
              db:dirty_write(db_role_goal_p,RoleGoal#p_role_goal{goals = []})
      end,RoleGoalList),
    ok.


-record(p_role_attr, {role_id,role_name,next_level_exp,exp,level,five_ele_attr,last_login_location,equips,jungong=0,charm=0,couple_id=0,couple_name="",skin,cur_energy=2000,max_energy=2000,remain_skill_points=0,gold=0,gold_bind=0,silver=0,silver_bind=0,show_cloth=true,moral_values=0,gongxun=0,last_login_ip="",office_id=0,office_name="",unbund=false,family_contribute=0,active_points=0,category,show_equip_ring=true,is_payed=false,sum_prestige=0,cur_prestige=0}).
-record(p_role_ext, {role_id,signature,birthday,constellation,country,province,city,blog,family_last_op_time=0,last_login_time,last_offline_time,role_name,sex,ever_leave_xsc=false}).
-record(p_role_fight, {role_id,hp,mp,energy,energy_remain,time_reset_energy}).

get_energy_info()->
    MatchHead1 = #p_role_attr{role_id='$1', _='_',level='$2'},
    RoleIDList1 = db:dirty_select(db_role_attr_p, [{MatchHead1, [{'>=','$2',30}], ['$1']}]),
    common_logger:error_msg(sum_role_rest_energy,debug,sum_role_rest_energy,"=====Length1:~w",[erlang:length(RoleIDList1)]),
    TimeStamp=common_tool:datetime_to_seconds({date(),{0,0,0}})-86400,
    MatchHead2 = #p_role_ext{role_id='$1', _='_',last_login_time='$2'},
    RoleIDList2 = db:dirty_select(db_role_ext_p, [{MatchHead2, [{'>','$2',TimeStamp}], ['$1']}]),
    common_logger:error_msg(sum_role_rest_energy,debug,sum_role_rest_energy,"=====Length2:~w",[erlang:length(RoleIDList2)]),
    RoleIDList = lists_filter([RoleIDList1,RoleIDList2]),
    common_logger:error_msg(sum_role_rest_energy,debug,sum_role_rest_energy,"=====FliterLength:~w",[erlang:length(RoleIDList2)]),
    put({energy_sum,0},0),
    put({energy_sum,100},0),
    put({energy_sum,500},0),
    put({energy_sum,1000},0),
    put({energy_sum,2000},0),
    put({energy_sum,3000},0),
    put({energy_sum,4000},0),
    lists:foreach(fun(RoleID)->
                          [#p_role_fight{energy=Energy}]=db:dirty_read(db_role_fight_p,RoleID),
                          if Energy=:=0->
                                 put({energy_sum,0},get({energy_sum,0})+1);
                             Energy=<100->
                                 put({energy_sum,100},get({energy_sum,100})+1);
                             Energy=<500->
                                 put({energy_sum,500},get({energy_sum,500})+1);
                             Energy=<1000->
                                 put({energy_sum,1000},get({energy_sum,1000})+1);
                             Energy=<2000->
                                 put({energy_sum,2000},get({energy_sum,2000})+1);
                             Energy=<3000->
                                 put({energy_sum,3000},get({energy_sum,3000})+1);
                             true->
                                 put({energy_sum,4000},get({energy_sum,4000})+1)
                          end
                  end, RoleIDList),
    lists:foreach(fun(Val)->
                      common_logger:error_msg(sum_role_rest_energy,debug,sum_role_rest_energy,"range=<~w , sum=~w", [Val,get({energy_sum,Val})])
                  end,[0,100,500,1000,2000,3000,4000]),
    erase({energy_sum,0}),
    erase({energy_sum,100}),
    erase({energy_sum,500}),
    erase({energy_sum,1000}),
    erase({energy_sum,2000}),
    erase({energy_sum,3000}),
    erase({energy_sum,4000}).
    
    
-define(ETS_FILTER_LIST,ets_filter_list).

lists_filter([FList|RList])->                      
    {SmallList,_SmallCount,RestList} = 
        lists:foldl(fun(TmpRoleIDList,{TmpSmallList,TmpSmallCount,TmpRestList})->
                            TmpCount = length(TmpRoleIDList),
                            if TmpCount=<TmpSmallCount ->
                                   {TmpRoleIDList,TmpCount,[TmpSmallList|TmpRestList]};
                               true->
                                   {TmpSmallList,TmpSmallCount,[TmpRoleIDList|TmpRestList]}
                            end
                    end, {FList,length(FList),[]}, RList),
    if SmallList=/=[] ->
           ets:new(?ETS_FILTER_LIST, [named_table, set, private]),
           lists:foreach(fun(RoleID)->ets:insert(?ETS_FILTER_LIST,{RoleID,1}) end,SmallList),
           lists:foreach(fun(TmpRoleIDList)-> 
                                 lists:foreach(fun(TmpRoleID)->
                                                       case ets:lookup(?ETS_FILTER_LIST,TmpRoleID) of
                                                           [{_, _}] ->
                                                               ets:update_counter(?ETS_FILTER_LIST,TmpRoleID,{2,1});
                                                           _->ignore
                                                       end
                                               end,TmpRoleIDList)
                         end, RestList),
           %% ets:match(send_goods, {1+length(RestList),'$1'}),
           MatchHead = {'$1', '$2'},
           Guard = [{'=:=','$2',1+length(RestList)}],
           Result = ['$1'],
           RoleIDList = 
           case ets:select(?ETS_FILTER_LIST,[{MatchHead, Guard, Result}]) of
               '$end_of_table'->[];
               _RoleIDList->_RoleIDList
           end,
           ets:delete(?ETS_FILTER_LIST),
           RoleIDList;
    true->
            []
end.

-record(r_scene_war_fb,{role_id,role_name,faction_id,level,team_id = 0,status = 0,start_time = 0,end_time = 0,map_id,pos,fb_map_name,fb_id,fb_seconds,fb_type,fb_level,fb_info = []}).
-record(r_scene_war_fb_info,{times = 0,fb_type}).
-record(p_role_hero_fb_info, {role_id,last_enter_time,today_count,progress,rewards,fb_record,max_enter_times,buy_count,enter_mapid,enter_pos,fail_code=1}).
-record(p_hero_fb_barrier, {barrier_id,time_used=0,star_level=0,score=0,fight_times=0,order=0}).

-record(r_role_exe_fb_info,{role_id,fb_map_name,enter_map_id,enter_pos,fb_info=[]}).
-record(r_role_exe_fb_detail,{fb_type,last_enter_time,fight_times=0}).

clear_fb_times()->
    clear_hero_fb_times(),
    clear_scene_war_fb_times(),
    clear_exercise_fb_times().


clear_hero_fb_times()->
    RoleDataList = db:dirty_match_object(db_role_hero_fb_p,#p_role_hero_fb_info{ _ ='_' }),
    lists:foreach(fun(R)->
            FbRecordList = R#p_role_hero_fb_info.fb_record,
            NewFbRecordList = [FbRecord#p_hero_fb_barrier{fight_times=3}||FbRecord<-FbRecordList],
            db:dirty_write(db_role_hero_fb_p,R#p_role_hero_fb_info{fb_record=NewFbRecordList})
          end,RoleDataList).

clear_scene_war_fb_times()->
    RoleDataList = db:dirty_match_object(db_scene_war_fb_p,#r_scene_war_fb{ _ ='_' }),
    lists:foreach(fun(R)->
            FbRecordList = R#r_scene_war_fb.fb_info,
            NewFbRecordList = [FbRecord#r_scene_war_fb_info{times=0}||FbRecord<-FbRecordList],
            db:dirty_write(db_scene_war_fb_p,R#r_scene_war_fb{fb_info=NewFbRecordList})
          end,RoleDataList).

clear_exercise_fb_times()->
    RoleDataList = db:dirty_match_object(db_role_exe_fb_info_p,#r_role_exe_fb_info{ _ ='_' }),
    lists:foreach(fun(R)->
            FbRecordList = R#r_role_exe_fb_info.fb_info,
            NewFbRecordList = [FbRecord#r_role_exe_fb_detail{fight_times=0}||FbRecord<-FbRecordList],
            db:dirty_write(db_role_exe_fb_info_p,R#r_role_exe_fb_info{fb_info=NewFbRecordList})
          end,RoleDataList).

