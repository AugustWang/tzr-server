%% 练功房

-record(r_exe_fb_map_info,{fb_type=0,monster_level=0,cur_pass_id=1,cur_pos=undefined,start_time=0,end_time=0,
                           create_list = [],cur_born_times=0,monster_type_list=[],
                           monster_born_num=0,monster_dead_num=0,monster_total_num=0,
                           roles_offline_info=[],in_roles_info=[],status=0}).

-record(r_role_exe_fb_map_info,{role_id,role_name,faction_id,level,team_id}).

%% fb_type:int() 副本类型
-record(r_exe_fb_mcm,{fb_type,fb_map_id,min_level,max_level,remain_seconds,team_member,monster_num,fight_times}).
%% pass_id:int() 第几环怪物
-record(r_exe_fb_pass_info,{pass_id,monster_type,born_times,center_pos,pos_list}).

-record(r_exe_fb_npc,{faction_id,map_id,npc_id}).

-record(r_exe_born_monster_weight,{min_level,max_level,weight}).

%% fb_type 副本类型
%% min_num - max_num 人数多少到多少
%% exp_rate 经验比例
-record(r_exe_fb_exp,{fb_type, min_num, max_num, exp_rate}).

%%================define ===================
-define(query_exercise_fb,1).
-define(enter_exercise_fb,2).
-define(quit_exercise_fb,3).
-define(find_path_exercise_fb,4).

-define(exe_fb_status_create,0).
-define(exe_fb_status_running,1).
-define(exe_fb_status_close,2).
-define(exe_fb_status_ignore,3).

-define(exe_fb_map_processname,exe_fb_map_processname).
-define(exe_fb_dict,exe_fb_dict).

-define(finish_pass_id,0).

%% 错误码
-define(err_not_exercise_fb,1001).          %% 不是练功房
-define(err_no_team,1002).                  %% 没有组队
-define(err_not_enough_team_member,1003).   %% 队员人数不够
-define(err_not_team_leader,1004).          %% 不是队长
-define(err_level_limit,1005).              %% 玩家等级不够
-define(err_too_far,1006).                  %% 玩家太远
-define(err_system_too_busy,1007).          %% 系统繁忙
-define(err_fight_times_limit,1008).        %% 战斗次数限制
-define(err_member_too_far,1009).           %% 队员太远
-define(err_member_level_limit,1010).       %% 队员等级限制
-define(err_member_fight_times_limit,1011). %% 队员战斗次数限制
