-module(update_mnesia_0_1_7).

-compile(export_all).

-record(r_db_mission_data, {role_id, mission_data}).
-record(mission_data, {last_store_time=0,data_version=0,mission_list=[],tutorial_list=[],listener_list=[],counter_list=[],auto_list=[],extend_list=[]}).
-record(r_role_mission_auto,{id,mission_auto,deduct_gold=0,deduct_gold_bind=0}).
%% 旧的记录
%% -record(p_mission_auto, {id,name,mission_id,loop_times,total_time,status=0,start_time=0,need_gold}).
-record(p_mission_auto, {id,name,big_group,mission_id,loop_times=0,status=0,start_time=0,end_time=0,need_gold=0,loop_one_time=0,max_loop_times=0,role_level=0,min_level=0,rollback_times=0,cur_times=0}).

connect_db() ->
    [MasterHost] = common_config_dyn:find_common(master_host),
    net_kernel:connect_node(erlang:list_to_atom(lists:concat(["master@", MasterHost]))),
    common_db:join_group(),
    ok.

update() ->
    connect_db(),
    code:load_file(common_config_dyn),
    common_config_dyn:init(),
    update_mission_auto_info(),
    ok.

update_mission_auto_info() ->
    DbMissionDataList = db:dirty_match_object(db_mission_data_p, #r_db_mission_data{ _ ='_' }),
    lists:foreach(
      fun(DbMissionData) ->
              MissionData = DbMissionData#r_db_mission_data.mission_data,
              MissionData2 = 
                  case lists:foldl(
                         fun(AutoRecord,Acc) -> 
                                 case Acc =:= true 
                                     andalso erlang:is_record(AutoRecord#r_role_mission_auto.mission_auto,p_mission_auto) =:= true of
                                     true ->
                                         Acc;
                                     _ ->
                                         false
                                 end
                         end, true, MissionData#mission_data.auto_list) of
                      true ->
                          MissionData;
                      _ ->
                          MissionData#mission_data{auto_list = []}
                  end,
              db:dirty_write(db_mission_data_p,DbMissionData#r_db_mission_data{mission_data = MissionData2})
      end,DbMissionDataList),
    ok.