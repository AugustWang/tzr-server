-module(mod_pet_training).
-include("mgeem.hrl").

-export([hook_map_loop/1]).

-export([handle/1,
         check_pet_is_training/2]). 

-define(MAX_TRAINING_ROOM,5).
%% 地图统计宠物训练间隔时间
-define(MAP_COUNTER_SPACE_TIME,60).

%% 配置文件计算经验间隔时间(秒)
-define(PET_TRAINING_ADD_EXP_SPACE_TIME,15).
%% 加经验间隔时间 （秒）
-define(ADD_EXP_SPACE_TIME,900).
%% 重设突飞猛进时间间隔
-define(CUT_FLY_CD_TIME,300).
%% 突飞猛进最大冷却时间
-define(FLY_TRAINING_MAX_CD_TIME,3600).

%% 获取训练信息
-define(GET_PET_TRAINING_INFO,1).
%% 添加训练空位
-define(ADD_PET_TRAINING_ROOM,2).
%% 开始训练
-define(START_PET_TRAINING,3).
%% 结束训练
-define(STOP_PET_TRAINING,4).
%% 突飞猛进
-define(FLY_PET_TRAINING,5).
%% 清除突飞猛进cd时间
-define(RESET_PET_FLY_TRAINING_CD_TIME,6).
%% 训练模式
-define(SET_PET_TRAINING_MODE,7).
%% 宠物加经验结果
-define(SET_PET_ADD_EXP,8).


%% 宠物训练获得经验与玩家等级有关
-record(pet_training_exp,{role_level,add_exp}).

%% 训练模式
-define(TRAINING_MODE_1,1).
-define(TRAINING_MODE_2,2).
-define(TRAINING_MODE_3,3).
-define(TRAINING_MODE_4,4).
-define(TRAINING_MODE_5,5).

check_pet_is_training(RoleID,PetID)->
    {ok,RoleMapExt} = mod_map_role:get_role_map_ext_info(RoleID),
    PetTrainingList = (RoleMapExt#r_role_map_ext.training_pets)#r_pet_training.pet_training_list,
    case lists:keyfind(PetID,#r_pet_training_detail.pet_id,PetTrainingList) of
        PetTrainingDetail when is_record(PetTrainingDetail,r_pet_training_detail)->
            true;
        _->false
    end.
        

%% -------------地图循环   -------------------------
hook_map_loop(Now)->
    case erlang:get(pet_training_counter) of
        undefined->
            put(pet_training_counter,1);
        Counter->
            case Counter<?MAP_COUNTER_SPACE_TIME of
                true->
                    put(pet_training_counter, Counter+1);
                false->
                    put(pet_training_counter,1),
                    hook_map_loop2(Now)
            end
    end.


hook_map_loop2(Now)->
    RoleIDList = mgeem_map:get_all_roleid(),
    lists:foreach(
      fun(RoleID)->
              {ok,#r_role_map_ext{training_pets=TrainingPets}} = mod_map_role:get_role_map_ext_info(RoleID),              
              lists:foreach(
                fun(PetTrainingDetail)->
                        case PetTrainingDetail#r_pet_training_detail.next_add_exp_time< Now of
                            true-> 
                                do_add_pet_training_exp(PetTrainingDetail,Now,RoleID);                             
                            false->
                                ignore
                        end
                end, TrainingPets#r_pet_training.pet_training_list)
      end,RoleIDList).

%% 宠物添加经验过程
do_add_pet_training_exp(PetTrainingDetail,Now,RoleID)->
    {ok,#p_role_attr{level=RoleLevel}}=mod_map_role:get_role_attr(RoleID),
    AddTimes=(Now - PetTrainingDetail#r_pet_training_detail.last_add_exp_time) div ?PET_TRAINING_ADD_EXP_SPACE_TIME,
    [{Rate,_}]=common_config_dyn:find(pet_training,{training_mode,PetTrainingDetail#r_pet_training_detail.training_mode}),
    [#pet_training_exp{add_exp=AddExp}] = common_config_dyn:find(pet_training_exp,RoleLevel),
    TotalAddExp=(AddTimes*AddExp*Rate) div 100,
    case db:transaction(
           fun()-> 
                   {ok,NewPetInfo,RealAddExp,NoticeType}=mod_map_pet:t_common_add_pet_exp(RoleID,PetTrainingDetail#r_pet_training_detail.pet_id,TotalAddExp),
                   %% 新的经验记录 需要重新获取
                   {ok,#r_role_map_ext{training_pets=TrainingPets}=RoleMapExtInfo}=mod_map_role:get_role_map_ext_info(RoleID),
                   {Status,NewPetTrainingDetail} = get_new_training_detail(NewPetInfo,RoleLevel,PetTrainingDetail,Now,AddTimes*?PET_TRAINING_ADD_EXP_SPACE_TIME,RealAddExp),
                   case Status of
                       continue->
                           PetTrainingList = [NewPetTrainingDetail|lists:delete(PetTrainingDetail, TrainingPets#r_pet_training.pet_training_list)];    
                       stop->
                           PetTrainingList = lists:delete(PetTrainingDetail, TrainingPets#r_pet_training.pet_training_list)                       
                   end,
                   NewTrainingPets =TrainingPets#r_pet_training{pet_training_list =PetTrainingList},
                   mod_map_role:t_set_role_map_ext_info(RoleID, RoleMapExtInfo#r_role_map_ext{training_pets=NewTrainingPets}),
                   {ok,NewTrainingPets,NewPetTrainingDetail,Status,NewPetInfo#p_pet.level,NoticeType}
           end) 
        of
        {aborted, Reason} ->
            ?ERROR_MSG("宠物训练加经验失败 Reason:~w~n",[Reason]);
        {atomic, {ok,NewTrainingPets,NewPetTrainingDetail,Status,PetLevel,NoticeType}} ->
            case NoticeType of
                levelup->
                    common_mod_goal:hook_pet_level_up(RoleID, PetLevel);
                _->
                    ignore
            end,
            %% 加经验结果
            %%R = #m_pet_training_request_toc{op_type=?SET_PET_ADD_EXP,pet_info = NewPetInfo},
            %%common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_TRAINING_REQUEST, R),     
            case Status of
                stop->
                   R2 = #m_pet_training_request_toc{op_type=?STOP_PET_TRAINING,
                                                    cur_room=NewTrainingPets#r_pet_training.cur_room,
                                                    pet_training_list=transfer(NewTrainingPets#r_pet_training.pet_training_list),
                                                    pet_training_info=transfer(NewPetTrainingDetail)},
                   common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_TRAINING_REQUEST, R2);
                _->
                    ignore
            end
    end.


            
             


%% 获取新的宠物训练信息
get_new_training_detail(#p_pet{level=PetLevel},RoleLevel,PetTrainingDetail,Now,PassTime,RealAddExp)->
    #r_pet_training_detail{last_add_exp_time=LastAddExpTime,
                           training_end_time=TrainingEndTime,
                           total_get_exp = TotalGetExp}=PetTrainingDetail,
    NewLastAddExpTime = LastAddExpTime+PassTime,
    case PetLevel<RoleLevel  %% 宠物当前等级等级要小于玩家当前等级
        andalso TrainingEndTime>Now 
        andalso NewLastAddExpTime+?ADD_EXP_SPACE_TIME=<TrainingEndTime %%下次加经验时间要不大于训练结束时间
        of
        true->Status = continue;
        false->Status = stop
    end,
    {Status,PetTrainingDetail#r_pet_training_detail{last_add_exp_time = NewLastAddExpTime,
                                                    next_add_exp_time = NewLastAddExpTime+?ADD_EXP_SPACE_TIME,
                                                    total_get_exp = TotalGetExp+RealAddExp}}.



%% ---------------------训练相关请求处理-----------------------------------
handle({Unique, DataIn, RoleID, PID, _Line, _State}) when erlang:is_record(DataIn,m_pet_training_request_tos) ->
    case DataIn#m_pet_training_request_tos.op_type of
        ?GET_PET_TRAINING_INFO->
            do_get_pet_training_info(Unique, DataIn, RoleID, PID);
        ?ADD_PET_TRAINING_ROOM->
            do_add_pet_training_room(Unique, DataIn, RoleID, PID);
        ?START_PET_TRAINING->
            do_start_pet_training(Unique, DataIn, RoleID, PID);
        ?STOP_PET_TRAINING->
            do_stop_pet_training(Unique, DataIn, RoleID, PID);
        ?FLY_PET_TRAINING->
            do_fly_pet_training(Unique, DataIn, RoleID, PID);
        ?RESET_PET_FLY_TRAINING_CD_TIME->
            do_reset_pet_fly_training_cd_time(Unique, DataIn, RoleID, PID);
        ?SET_PET_TRAINING_MODE->
            do_set_pet_training_mode(Unique,DataIn,RoleID,PID);
        _->
            ?ERROR_MSG("mod_pet_training undefine op_type Msg:~w~n",[{Unique, DataIn, RoleID, PID, _Line, _State}])
    end;
handle(Msg)->
    ?ERROR_MSG("mod_pet_training ignore Msg:~w~n",[Msg]).



%%--------------添加训练槽---------------
do_add_pet_training_room(Unique, DataIn, RoleID, PID)->
    {ok,RoleMapExtInfo}=mod_map_role:get_role_map_ext_info(RoleID),
    TrainingPets= RoleMapExtInfo#r_role_map_ext.training_pets,
    NewCurRoom = TrainingPets#r_pet_training.cur_room+1,
    case NewCurRoom>?MAX_TRAINING_ROOM of
        true->
            do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},?_LANG_PET_ADD_TRAINING_ROOM_ENOUGH,0);
        false-> 
            [AddRoomCost]=common_config_dyn:find(pet_training,{training_room,NewCurRoom}),
            case common_transaction:transaction(
                   fun()-> {ok,NewRoleAttr}=t_cost_gold_bind_first(RoleID,AddRoomCost,?CONSUME_TYPE_GOLD_ADD_PET_TRAINING_ROOM,"",2),
                           mod_map_role:t_set_role_map_ext_info(
                             RoleID, 
                             RoleMapExtInfo#r_role_map_ext{training_pets=TrainingPets#r_pet_training{cur_room=NewCurRoom}}),
                           {ok,NewRoleAttr}
                    end) 
                of
                {aborted,{error,Reason,ReasonCode}}->
                    do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},Reason,ReasonCode);
                {atomic,{ok,NewRoleAttr}}->
                    R = #m_pet_training_request_toc{op_type = DataIn#m_pet_training_request_tos.op_type,
                                                    cur_room= NewCurRoom},
                    common_misc:unicast2(PID, Unique, ?PET, ?PET_TRAINING_REQUEST, R),
                    common_misc:send_role_gold_change(RoleID, NewRoleAttr)
            end
    end.



%%---------------获取训练信息---------------
do_get_pet_training_info(Unique, _DataIn, RoleID, PID)-> 
    {ok,#r_role_map_ext{training_pets=TrainingPets}}=mod_map_role:get_role_map_ext_info(RoleID),
    R = #m_pet_training_request_toc{op_type=?GET_PET_TRAINING_INFO,
                                    cur_room=TrainingPets#r_pet_training.cur_room,
                                    pet_training_list=transfer(TrainingPets#r_pet_training.pet_training_list)},
    common_misc:unicast2(PID, Unique, ?PET, ?PET_TRAINING_REQUEST, R).


    
            


%% --------------开始训练  默认普通的训练模式---------------------
do_start_pet_training(Unique, DataIn, RoleID, PID)->
    case catch check_can_start_pet_training(DataIn,RoleID) of
        {ok,RoleMapExt,PetInfo}->
            do_start_pet_training2(Unique, DataIn, RoleID, PID, RoleMapExt,PetInfo);
        {error,Reason,ReasonCode}->
            do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},Reason,ReasonCode)
    end.

check_can_start_pet_training(#m_pet_training_request_tos{pet_id=PetID,training_hours=TrainingHours},RoleID)->
    case TrainingHours>0 andalso TrainingHours=<24 of
        true->
            next;
        false->
            erlang:throw({error,?_LANG_PET_TRAINING_HOURS_ILLEGAL,0})
    end,
    {ok,#r_role_map_ext{training_pets=TrainingPets}=RoleMapExt}=mod_map_role:get_role_map_ext_info(RoleID),
    %% 检查空位
    case TrainingPets#r_pet_training.cur_room>erlang:length(TrainingPets#r_pet_training.pet_training_list) of
        true->
            next;
        false->
            erlang:throw({error,?_LANG_PET_ADD_TRAINING_ROOM_ENOUGH,0})
    end,
    case lists:keyfind(PetID, #r_pet_training_detail.pet_id, TrainingPets#r_pet_training.pet_training_list) of
        false->
            next;
        _->
            erlang:throw({error,?_LANG_PET_IS_TRAINING,0})
    end,
    %%是否有这只宠    
    case mod_map_pet:check_role_has_pet(RoleID,PetID) of
        error->
            PetInfo=undefined,
            erlang:throw({error,?_LANG_PET_NOT_EXIST,0});
        {ok,PetInfo}->
            next
    end,
    case get({?ROLE_SUMMONED_PET_ID,RoleID}) of
        PetID ->
            PetInfo1 = get({?ROLE_PET_INFO,PetID});
        _->
            PetInfo1 =PetInfo
    end,
    %% 宠物等级
    {ok,#p_role_attr{level=RoleLevel}}=mod_map_role:get_role_attr(RoleID),
    case PetInfo1#p_pet.level<RoleLevel of
        true->
            {ok,RoleMapExt,PetInfo1};
        false->
            {error,?_LANG_PET_TRAINING_LEVEL_FULL,0}
    end.

do_start_pet_training2(Unique, DataIn, RoleID, PID, RoleMapExt,PetInfo)->
    Now = mgeem_map:get_now(),
    PetLevel = PetInfo#p_pet.level,
    TrainingCost = common_tool:ceil(math:pow(PetLevel, 1.4)*DataIn#m_pet_training_request_tos.training_hours),
    case common_transaction:transaction(fun()-> t_start_pet_training(RoleID,DataIn,RoleMapExt,TrainingCost,Now) end) of
        {aborted, {error,Reason,ReasonCode}} ->
            do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},Reason,ReasonCode);
        {atomic, {ok,NewTrainingPets,NewRoleAttr}} ->
            write_pet_training_log(RoleID,
                                   NewRoleAttr#p_role_attr.role_name,
                                   DataIn#m_pet_training_request_tos.training_hours,
                                   DataIn#m_pet_training_request_tos.pet_id,
                                   PetLevel,
                                   TrainingCost),
            R = #m_pet_training_request_toc{op_type=DataIn#m_pet_training_request_tos.op_type,
                                    cur_room=NewTrainingPets#r_pet_training.cur_room,
                                    pet_training_list=transfer(NewTrainingPets#r_pet_training.pet_training_list)},
            common_misc:unicast2(PID, Unique, ?PET, ?PET_TRAINING_REQUEST, R),
            common_misc:send_role_silver_change(RoleID, NewRoleAttr)
    end.
                     
t_start_pet_training(RoleID,DataIn,#r_role_map_ext{training_pets=TrainingPets}=RoleMapExt,Cost,Now)->
    {ok,NewRoleAttr} = t_cost_silver_bind_first(RoleID,Cost,?CONSUME_TYPE_SILVER_PET_TRAINING_START,"",1),
    #r_pet_training{pet_training_list=PetTrainingList}=TrainingPets,
    NewPetTrainingList = [#r_pet_training_detail{pet_id=DataIn#m_pet_training_request_tos.pet_id,
                                training_start_time=Now,
                                training_end_time=Now+DataIn#m_pet_training_request_tos.training_hours*3600,
                                last_add_exp_time=Now,
                                next_add_exp_time=Now+?ADD_EXP_SPACE_TIME,
                                training_mode=?TRAINING_MODE_1,
                                fly_cd_end_time=Now,
                                total_get_exp=0}|PetTrainingList],
    NewTrainingPets = TrainingPets#r_pet_training{pet_training_list=NewPetTrainingList},
    mod_map_role:t_set_role_map_ext_info(RoleID, RoleMapExt#r_role_map_ext{training_pets=NewTrainingPets}),
    {ok,NewTrainingPets,NewRoleAttr}.




%% ------------------------终止训练----------------------------   
do_stop_pet_training(Unique, DataIn, RoleID, PID)->
    case catch check_can_stop_pet_training(DataIn, RoleID) of
        {ok,RoleMapExt,TrainingPets,PetTrainingInfo}->
            do_stop_pet_training2(Unique, DataIn, RoleID, PID, RoleMapExt,TrainingPets,PetTrainingInfo);
        {error,Reason,ReasonCode}->
            do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},Reason,ReasonCode)
    end.

check_can_stop_pet_training(#m_pet_training_request_tos{pet_id=PetID},RoleID)->
    {ok,#r_role_map_ext{training_pets=TrainingPets}=RoleMapExt}=mod_map_role:get_role_map_ext_info(RoleID),
    case lists:keyfind(PetID, #r_pet_training_detail.pet_id, TrainingPets#r_pet_training.pet_training_list) of
        false->
            PetTrainingInfo=undefined,
            erlang:throw({error,?_LANG_PET_IS_FREE,0});
        PetTrainingInfo->
            next
    end,
    %%是否有这只宠    
    case mod_map_pet:check_role_has_pet(RoleID,PetID) of
        error->
            erlang:throw({error,?_LANG_PET_NOT_EXIST,0});
        _->
            next
    end,
    {ok,RoleMapExt,TrainingPets,PetTrainingInfo}.

do_stop_pet_training2(Unique, _DataIn, RoleID, PID,RoleMapExt,TrainingPets,PetTrainingInfo)->
    NewPetTrainingList = lists:delete(PetTrainingInfo, TrainingPets#r_pet_training.pet_training_list),
    mod_map_role:set_role_map_ext_info(
      RoleID, 
      RoleMapExt#r_role_map_ext{training_pets=TrainingPets#r_pet_training{pet_training_list = NewPetTrainingList}}),
    R = #m_pet_training_request_toc{op_type=?STOP_PET_TRAINING,
                                     cur_room = TrainingPets#r_pet_training.cur_room,
                                     pet_training_list = transfer(NewPetTrainingList),
                                     pet_training_info = transfer(PetTrainingInfo)},
    common_misc:unicast2(PID, Unique, ?PET, ?PET_TRAINING_REQUEST, R).



%% --------------------------突飞猛进--------------------------
do_fly_pet_training(Unique, DataIn, RoleID, PID)->
     Now =mgeem_map:get_now(),
    case catch check_can_fly_pet_training(DataIn,RoleID,Now) of
        {ok,RoleMapExt,TrainingPets,PetTrainingDetail}->
            do_fly_pet_training2(Unique, DataIn, RoleID, PID, RoleMapExt,TrainingPets,PetTrainingDetail,Now);
        {error,Reason,ReasonCode}->
            do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},Reason,ReasonCode)
    end.

check_can_fly_pet_training(#m_pet_training_request_tos{pet_id=PetID},RoleID,Now)->
    {ok,#r_role_map_ext{training_pets=TrainingPets}=RoleMapExt}=mod_map_role:get_role_map_ext_info(RoleID),
    case lists:keyfind(PetID, #r_pet_training_detail.pet_id, TrainingPets#r_pet_training.pet_training_list) of
        false->
            PetTrainingDetail=undefined,
            erlang:throw({error,?_LANG_PET_IS_FREE,0});
        PetTrainingDetail->
            next
    end,
    case PetTrainingDetail#r_pet_training_detail.fly_cd_end_time-Now> ?FLY_TRAINING_MAX_CD_TIME of
        true->
            erlang:throw({error,?_LANG_PET_FLY_TRAINING_CDING,0});
        false->
            next
    end,
    {ok,RoleMapExt,TrainingPets,PetTrainingDetail}.

do_fly_pet_training2(Unique, DataIn, RoleID, PID, RoleMapExt,TrainingPets,PetTrainingDetail,Now)->
    {ok,#p_role_attr{level=RoleLevel}}=mod_map_role:get_role_attr(RoleID),
    [NeedItemID]=common_config_dyn:find(pet_training,fly_item_id),
    case db:transaction(
           fun()-> 
                   case catch mod_bag:decrease_goods_by_typeid(RoleID, [1,2,3,4], NeedItemID, 1) of
                       {bag_error,num_not_enough} ->
                           ChangeList=DelList=[],
                           db:abort({?_LANG_FLY_PET_TRAINING_NO_GOODS,0});
                       {ok, ChangeList, DelList}->
                           next
                   end,
                   [#pet_training_exp{add_exp=AddExp}] = common_config_dyn:find(pet_training_exp,RoleLevel),
                   {ok,NewPetInfo,RealAddExp,NoticeType} = mod_map_pet:t_common_add_pet_exp(RoleID,DataIn#m_pet_training_request_tos.pet_id,AddExp*20),
                   case NewPetInfo#p_pet.level<RoleLevel of
                       true->
                           case PetTrainingDetail#r_pet_training_detail.fly_cd_end_time< Now of
                               true->
                                   NewFlyCDEndTime = Now+?CUT_FLY_CD_TIME;
                               false->
                                   NewFlyCDEndTime = PetTrainingDetail#r_pet_training_detail.fly_cd_end_time+?CUT_FLY_CD_TIME
                          end,
                           NewPetTrainingDetail = PetTrainingDetail#r_pet_training_detail{fly_cd_end_time =NewFlyCDEndTime},
                           NewPetTrainingList=[NewPetTrainingDetail|lists:delete(PetTrainingDetail,TrainingPets#r_pet_training.pet_training_list)];
                       false->
                           NewPetTrainingDetail = PetTrainingDetail,
                           NewPetTrainingList = lists:delete(PetTrainingDetail,TrainingPets#r_pet_training.pet_training_list)
                   end,
                   NewTrainingPets = TrainingPets#r_pet_training{pet_training_list=NewPetTrainingList},
                   mod_map_role:t_set_role_map_ext_info(RoleID, RoleMapExt#r_role_map_ext{training_pets=NewTrainingPets}),
                   {ok,ChangeList, DelList,NewPetInfo,NewPetTrainingList,NewPetTrainingDetail,NoticeType,RealAddExp}
           end) of
        {aborted, {Reason,ReasonCode}} ->
            %%?ERROR_MSG("突飞猛进失败Reason:~w, ReasonCode:~w~n",[Reason,ReasonCode]),
            do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},Reason,ReasonCode);
        {atomic, {ok,ChangeList, DelList,NewPetInfo,NewPetTrainingList,NewPetTrainingDetail,NoticeType,RealAddExp}} ->
            case NoticeType of
                levelup->
                    Record = #m_pet_level_up_toc{pet_info=NewPetInfo},
                    common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_LEVEL_UP, Record);
                attrchange->
                    Record = #m_pet_attr_change_toc{pet_id=NewPetInfo#p_pet.pet_id,change_type=11,value=NewPetInfo#p_pet.exp},
                    common_misc:unicast({role,RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_ATTR_CHANGE, Record);
                _->
                    ignore
            end,
            case NoticeType of 
                levelup ->
                    common_mod_goal:hook_pet_level_up(RoleID, NewPetInfo#p_pet.level);
                _->
                    ignore
            end,
            %% 加经验结果
            %%R = #m_pet_training_request_toc{op_type=?FLY_PET_TRAINING, pet_info = NewPetInfo},
            %%common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?PET, ?PET_TRAINING_REQUEST, R),
            %% 通知物品变动
            case ChangeList of
                []->
                    [Goods] = DelList,
                    common_misc:del_goods_notify({role, RoleID}, Goods);
                _->
                    [Goods] = ChangeList,
                    common_misc:update_goods_notify({role, RoleID}, Goods)
            end,
            common_item_logger:log(RoleID, NeedItemID,1,undefined,?LOG_ITEM_TYPE_PET_FLY_TRAINING_SHI_QU),
            case NewPetInfo#p_pet.level<RoleLevel of
                true->
                    R1 = #m_pet_training_request_toc{op_type=DataIn#m_pet_training_request_tos.op_type,
                                     cur_room = TrainingPets#r_pet_training.cur_room,
                                     pet_training_info = transfer(NewPetTrainingDetail),
                                                     add_exp=RealAddExp},
                    common_misc:unicast2(PID, Unique, ?PET, ?PET_TRAINING_REQUEST, R1);
                false->
                    R1 = #m_pet_training_request_toc{op_type=?STOP_PET_TRAINING,
                                     cur_room = TrainingPets#r_pet_training.cur_room,
                                     pet_training_list = transfer(NewPetTrainingList),
                                     pet_training_info = transfer(PetTrainingDetail),
                                                     add_exp=RealAddExp},
                    common_misc:unicast2(PID, Unique, ?PET, ?PET_TRAINING_REQUEST, R1)
            end
    end.




%% ------------清除突飞猛进冷却时间---------------
do_reset_pet_fly_training_cd_time(Unique, DataIn, RoleID, PID)->
    Now =mgeem_map:get_now(),    
    case catch check_can_reset_pet_fly_training_cd_time(DataIn,RoleID,Now) of
        {ok,RoleMapExt,TrainingPets,PetTrainingDetail}->
            do_reset_pet_fly_training_cd_time2(Unique, DataIn, RoleID, PID, RoleMapExt,TrainingPets,PetTrainingDetail,Now);
        {error,Reason,ReasonCode}->
            do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},Reason,ReasonCode)
    end.

check_can_reset_pet_fly_training_cd_time(#m_pet_training_request_tos{pet_id=PetID},RoleID,Now)->
    {ok,#r_role_map_ext{training_pets=TrainingPets}=RoleMapExt}=mod_map_role:get_role_map_ext_info(RoleID),
    case lists:keyfind(PetID, #r_pet_training_detail.pet_id, TrainingPets#r_pet_training.pet_training_list) of
        false->
            PetTrainingDetail=undefined,
            erlang:throw({error,?_LANG_PET_IS_FREE,0});
        PetTrainingDetail->
            next
    end,
    case PetTrainingDetail#r_pet_training_detail.fly_cd_end_time<Now of
        true->
            erlang:throw({error,?_LANG_PET_NEED_NOT_TO_RESET_FLY_CD_TIME,0});
        false->
            next
    end,
    {ok,RoleMapExt,TrainingPets,PetTrainingDetail}.

do_reset_pet_fly_training_cd_time2(Unique, DataIn, RoleID, PID, RoleMapExt,TrainingPets,PetTrainingDetail,Now)->
    case common_transaction:transaction(
           fun()->t_reset_pet_fly_training_cd_time(RoleID,RoleMapExt,TrainingPets,PetTrainingDetail,Now) end ) of
        {atomic, {ok,NewRoleAttr,NewPetTrainingDetail}} ->
            R=#m_pet_training_request_toc{op_type=DataIn#m_pet_training_request_tos.op_type,
                                          pet_training_info=transfer(NewPetTrainingDetail)},
            common_misc:unicast2(PID, Unique, ?PET, ?PET_TRAINING_REQUEST, R),
            common_misc:send_role_gold_change(RoleID, NewRoleAttr);
        {aborted, {error,Reason,ReasonCode}} ->
            do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},Reason,ReasonCode)
    end.

t_reset_pet_fly_training_cd_time(RoleID,RoleMapExt,TrainingPets,PetTrainingDetail,Now)->
    CDTime =PetTrainingDetail#r_pet_training_detail.fly_cd_end_time-Now,
    Cost =common_tool:ceil( CDTime / ?CUT_FLY_CD_TIME),
    {ok,NewRoleAttr} = t_cost_gold_bind_first(RoleID,Cost,?CONSUME_TYPE_GOLD_RESET_FLY_TRAINING_CD_TIME,"",2),
    #r_pet_training{pet_training_list=PetTrainingList}=TrainingPets,
    NewPetTrainingDetail = PetTrainingDetail#r_pet_training_detail{fly_cd_end_time=Now},
    NewPetTrainingList = [NewPetTrainingDetail|lists:delete(PetTrainingDetail,PetTrainingList)],
    
    NewTrainingPets = TrainingPets#r_pet_training{pet_training_list=NewPetTrainingList},
    mod_map_role:t_set_role_map_ext_info(RoleID, RoleMapExt#r_role_map_ext{training_pets=NewTrainingPets}),
    {ok,NewRoleAttr,NewPetTrainingDetail}.



%% -------------------训练模式设置------------------------
do_set_pet_training_mode(Unique,DataIn,RoleID,PID)->
    case catch check_can_set_pet_training_mode(DataIn,RoleID) of
        {ok,RoleMapExt,TrainingPets,PetTrainingDetail}->
            do_set_pet_training_mode2(Unique, DataIn, RoleID, PID, RoleMapExt,TrainingPets,PetTrainingDetail);
        {error,Reason,ReasonCode}->
            do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},Reason,ReasonCode)
    end.

check_can_set_pet_training_mode(#m_pet_training_request_tos{pet_id=PetID,training_mode=TrainingMode},RoleID)->
    {ok,#r_role_map_ext{training_pets=TrainingPets}=RoleMapExt}=mod_map_role:get_role_map_ext_info(RoleID),
    case lists:keyfind(PetID, #r_pet_training_detail.pet_id, TrainingPets#r_pet_training.pet_training_list) of
        false->
            PetTrainingDetail=undefined,
            erlang:throw({error,?_LANG_PET_IS_FREE,0});
        PetTrainingDetail->
            next
    end,
    if TrainingMode=<PetTrainingDetail#r_pet_training_detail.training_mode 
         orelse  TrainingMode =< 1 
         orelse TrainingMode>5 ->
            erlang:throw({error,?_LANG_PET_TRAINING_MODE_ILLEGAL,0});
       TrainingMode >=3 ->
           {ok,VipLevel}= mod_vip:get_role_vip_level(RoleID),
           case TrainingMode-2 > VipLevel of
               true->
                   erlang:throw({error,?_LANG_PET_TRAINING_NOT_VIP,0});
               false->
                   next
           end;
       true->
           next
    end,
    {ok,RoleMapExt,TrainingPets,PetTrainingDetail}.
  
do_set_pet_training_mode2(Unique, DataIn, RoleID, PID, RoleMapExt,TrainingPets,PetTrainingDetail)->
    TrainingMode = DataIn#m_pet_training_request_tos.training_mode,
    [{_,GoldCost}] = common_config_dyn:find(pet_training, {training_mode,TrainingMode}),
    case common_transaction:transaction(
           fun()->t_set_pet_training_mode(RoleID,RoleMapExt,TrainingPets,PetTrainingDetail,GoldCost,TrainingMode) end ) of
        {atomic, {ok,NewRoleAttr,NewPetTrainingDetail}} ->
            R=#m_pet_training_request_toc{op_type=DataIn#m_pet_training_request_tos.op_type,
                                          pet_training_info=transfer(NewPetTrainingDetail)},
            common_misc:unicast2(PID, Unique, ?PET, ?PET_TRAINING_REQUEST, R),
            common_misc:send_role_gold_change(RoleID, NewRoleAttr);
        {aborted, {error,Reason,ReasonCode}} ->
            do_pet_training_error({Unique, ?PET, ?PET_TRAINING_REQUEST, DataIn, RoleID, PID},Reason,ReasonCode)
    end.

t_set_pet_training_mode(RoleID,RoleMapExt,TrainingPets,PetTrainingDetail,Cost,TrainingMode)->
    {ok,NewRoleAttr} = t_cost_gold_bind_first(RoleID,Cost,?CONSUME_TYPE_GOLD_PET_CHANGE_TRAINING_MODE,"",2),
    NewPetTrainingDetail=PetTrainingDetail#r_pet_training_detail{training_mode=TrainingMode},
    NewPetTrainingList = [NewPetTrainingDetail|lists:delete(PetTrainingDetail,TrainingPets#r_pet_training.pet_training_list)],
    NewTrainingPets = TrainingPets#r_pet_training{pet_training_list=NewPetTrainingList},
    mod_map_role:t_set_role_map_ext_info(RoleID, RoleMapExt#r_role_map_ext{training_pets=NewTrainingPets}),
    {ok,NewRoleAttr,NewPetTrainingDetail}.


do_pet_training_error({Unique, Module, Method, DataRecord, _RoleId, PId},Reason,ReasonCode)
    when erlang:is_record(DataRecord,m_pet_training_request_tos)->
    TocRecord = #m_pet_training_request_toc{op_type=DataRecord#m_pet_training_request_tos.op_type,
                                            succ= false,
                                            reason=Reason,
                                            reason_code=ReasonCode},
    common_misc:unicast2(PId, Unique, Module, Method, TocRecord);
do_pet_training_error({RoleID,Module,Method,OpType},Reason,ReasonCode)->
    TocRecord = #m_pet_training_request_toc{op_type=OpType,
                                            succ= false,
                                            reason=Reason,
                                            reason_code=ReasonCode},
    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, Module, Method, TocRecord).

transfer(List) when is_list(List)->
    [transfer(Detail)||Detail<-List];
transfer(Detail) when is_record(Detail,r_pet_training_detail)->
    #p_pet_training_info{pet_id = Detail#r_pet_training_detail.pet_id,
                         training_start_time = Detail#r_pet_training_detail.training_start_time,
                         training_end_time = Detail#r_pet_training_detail.training_end_time,
                         training_mode = Detail#r_pet_training_detail.training_mode,
                         fly_cd_end_time = Detail#r_pet_training_detail.fly_cd_end_time,
                         total_get_exp = Detail#r_pet_training_detail.total_get_exp};
transfer(Info)->Info.


t_cost_gold_bind_first(RoleID,Cost,UseType,Reason,ReasonCode)->
    {ok,RoleAttr}=mod_map_role:get_role_attr(RoleID),
    case RoleAttr#p_role_attr.gold_bind<Cost of
        true->
            GoldBindCut = RoleAttr#p_role_attr.gold_bind,
            GoldCut = Cost-RoleAttr#p_role_attr.gold_bind;
        false->
            GoldBindCut = Cost,
            GoldCut = 0
    end,
    case RoleAttr#p_role_attr.gold<GoldCut of
        true->
            common_transaction:abort({error,Reason,ReasonCode});
        false->
            next
    end,
    NewRoleAttr = RoleAttr#p_role_attr{gold=RoleAttr#p_role_attr.gold-GoldCut,
                                       gold_bind =RoleAttr#p_role_attr.gold_bind-GoldBindCut},
    mod_map_role:set_role_attr(RoleID,NewRoleAttr),
    common_consume_logger:use_gold({RoleID, GoldBindCut, GoldCut,UseType,""}),
    {ok,NewRoleAttr}.


t_cost_silver_bind_first(RoleID,Cost,UseType,Reason,ReasonCode)->
    {ok,RoleAttr}=mod_map_role:get_role_attr(RoleID),
    case RoleAttr#p_role_attr.silver_bind<Cost of
        true->
            SilverBindCut = RoleAttr#p_role_attr.silver_bind,
            SilverCut = Cost-RoleAttr#p_role_attr.silver_bind;
        false->
            SilverBindCut = Cost,
            SilverCut = 0
    end,
    case RoleAttr#p_role_attr.silver<SilverCut of
        true->
            common_transaction:abort({error,Reason,ReasonCode});
        false->
            next
    end,
    NewRoleAttr = RoleAttr#p_role_attr{silver=RoleAttr#p_role_attr.silver-SilverCut,
                                       silver_bind =RoleAttr#p_role_attr.silver_bind-SilverBindCut},
    mod_map_role:set_role_attr(RoleID,NewRoleAttr),
    common_consume_logger:use_silver({RoleID, SilverBindCut, SilverCut,UseType,""}),
    {ok,NewRoleAttr}.
    
write_pet_training_log(RoleID,RoleName,TrainingHours,PetID,PetLevel,TrainingCost) ->
    catch global:send(mgeew_pet_log_server,{log_pet_training,{RoleID,RoleName,TrainingHours,PetID,PetLevel,TrainingCost}}).