-module(update_mnesia_0_1_8).

-compile(export_all).

connect_db() ->
    [MasterHost] = common_config_dyn:find_common(master_host),
    net_kernel:connect_node(erlang:list_to_atom(lists:concat(["master@", MasterHost]))),
    common_db:join_group(),
    ok.

update() ->
    connect_db(),
    code:load_file(common_config_dyn),
    common_config_dyn:init(),
    update_role_vip_info(),
    ok.

update_role_vip_info()->
        TransFormer = 
        fun(R) ->
               case R of
                   {p_role_vip,ROLE_ID,END_TIME,TOTAL_TIME,VIP_LEVEL,MULTI_EXP_TIMES,ACCUMULATE_EXP_TIMES,MISSION_TRANSFER_TIMES,IS_TRANSFER_NOTICE_FREE,IS_TRANSFER_NOTICE,LAST_RESET_TIME,IS_EXPIRE,PET_TRAINING_TIMES,REMOTE_DEPOT_NUM}->
                       {p_role_vip,ROLE_ID,END_TIME,TOTAL_TIME,VIP_LEVEL,MULTI_EXP_TIMES,ACCUMULATE_EXP_TIMES,MISSION_TRANSFER_TIMES,IS_TRANSFER_NOTICE_FREE,IS_TRANSFER_NOTICE,LAST_RESET_TIME,IS_EXPIRE,PET_TRAINING_TIMES,REMOTE_DEPOT_NUM,0};
                   _->
                       R
               end
        end,
    Fields = [role_id,end_time,total_time,vip_level,multi_exp_times,accumulate_exp_times,mission_transfer_times,is_transfer_notice_free,is_transfer_notice,last_reset_time,is_expire,pet_training_times,remote_depot_num,last_get_prestige_time],
    {atomic, ok} = mnesia:transform_table(db_role_vip_p, TransFormer, Fields, p_role_vip).