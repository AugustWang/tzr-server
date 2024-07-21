%%% -------------------------------------------------------------------
%%% Author  : Administrator
%%% Description :
%%%
%%% Created : 2010-4-17
%%% -------------------------------------------------------------------
-module(mgeew_educate_server).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeew.hrl").
-include("educate.hrl").


%% --------------------------------------------------------------------
%%define
%%---------------------------------------------------------------------
-define(RELATION_SG,1). %%师公
-define(RELATION_SF,2). %%师傅
-define(RELATION_XD,3). %%师兄弟
-define(RELATION_TD,4). %%徒弟
-define(RELATION_TS,5). %%徒孙

-define(ref(RoleID),{'#role_educate_info#',RoleID}).
-define(change_list,'#role_educate_info_change_list#').
-define(invite_list,'#invite_data_list#').
-define(invite_check_count,'#invite_check_count#').
-define(ref_reco_tcrs(FID),{'#reco_tcrs#', FID}).
-define(ref_reco_stus(FID),{'#reco_stus#', FID}).

-define(RELEASE_ADMISSIONS,1). %%发布收徒
-define(RELEASE_APPRENTICE,2). %%发布拜师
-define(UNRELEASE_ADMISSIONS,3). %%取消发布收徒
-define(UNRELEASE_APPRENTICE,4). %%取消发布拜师

-define(TEACHER_GIFT,11400006).%%恩师礼包
-define(STUDENT_GIFT,11400005).%%高徒礼包
-define(PERSISTENCE_TIME,30000).%%持久化时间
-define(INVITE_TIMEOUT, 180). %%邀请超时的时间

-define(QIN_AI_DE,"亲爱的[").
-define(GONGXI_T,"恭喜你的爱徒[").
-define(GONGXI_S,"恭喜你升至60级").
-define(EDUCATE_LETTER_TITTLE,"师徒关系解除信件").
-define(T_TEXT,"]完成了60级目标，荣誉出师。愿你与爱徒在游戏中共进退，谱写属于你们的天之刃。\n\n请领取恩师奖励：恩师礼包×1。").
-define(S_TEXT,",成功出师。愿你与恩师在游戏中共进退，谱写属于你们的天之刃。\n\n请领取出师奖励：高徒礼包×1。").

-define(EDUCATE_LETTER_STUDENT_LEAVE_TEACHER, "<font color=\"#ffff00\">~s：</font>\n      你的徒弟[<font color=\"#ffff00\">~s</font>]心意已决，与你解除了师徒关系。\n      收徒的好处：\n       徒弟升级，可获得师德值。\n      1）师德值可以换取经验或用来消除PK值。\n      2）与徒弟组队，有5%的经验加成。\n      3）如果徒弟60级出师，将获得恩师礼包。\n      <a href=\"event:teacher\"><font  color=\"#00ff00\"><u>查看更多徒弟</u></font></a>\n\n<p align=\"right\">李梦阳</p>").
-define(EDUCATE_LETTER_TEACHER_QUIT_STUDENT, "<font color=\"#ffff00\">~s：</font>\n      你的导师[<font color=\"#ffff00\">~s</font>]心意已决，将你开除师门，你们已经脱离了师徒关系。请前往王都—师徒管理员处，寻访其他名师吧。\n      拜师的好处：师傅在线，自己可以获得组队经验加成。\n       60级出师，还可以获得出师礼包。\n\n<p align=\"right\">李梦阳</p>").

%%---------------------------------------------------------------------
%% External exports
-export([start/0, start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% External functions
%% ====================================================================
start() ->
    {ok, _} = supervisor:start_child(mgeew_sup, {?MODULE,
                                                 {?MODULE, start_link, []},
                                                 permanent, 300000, worker, 
                                                 [?MODULE]}).

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    erlang:process_flag(trap_exit, true),
    erlang:send_after(?PERSISTENCE_TIME,self(),persistence),
    {ok,[]}.

handle_call({func, Func}, _From, State) ->
    {reply, (catch Func()), State};
handle_call(Request, From, State) ->
    ?ERROR_MSG("unknow call ~p from ~p", [Request, From]),
    Reply = ok,
    {reply, Reply, State}.

handle_cast({add_morals,RoleID,Value}, State) ->
    case get_(RoleID) of
        [] ->
            undefined;
        [#r_educate_role_info{moral_values=V}=Info] ->
            NewInfo = Info#r_educate_role_info{moral_values=V+Value},
            put_(RoleID, NewInfo),
            common_misc:unicast({role,RoleID},
                                ?DEFAULT_UNIQUE,
                                ?EDUCATE,
                                ?EDUCATE_GET_INFO,
                                #m_educate_get_info_toc{
                                   roleinfo = convert2toc(NewInfo,0)
                                  })
    end,
    {noreply, State};

%% 玩家上线信息处理
handle_cast({online_nofity, RoleID, _RoleBase, _RoleAttr}, State) ->
    case load(RoleID) of
        {[{_,Info}],[]} ->
            common_misc:unicast({role,RoleID},
                                ?DEFAULT_UNIQUE,
                                ?EDUCATE,
                                ?EDUCATE_GET_INFO,
                                #m_educate_get_info_toc{
                                   roleinfo = convert2toc(Info,0)
                                  });
        _ ->
            ignore
    end,
    {noreply, State};

%% 角色下线处理
handle_cast({offline_nofity, RoleID},State) ->
    ?DEBUG("RoleID :~w offline~n",[RoleID]),
    quit(RoleID),
    {noreply, State};
%% 角色升级处理
handle_cast({upgrade, RoleID, OldLevel, NewLevel}, State) ->
    [GraduateLevel]=common_config_dyn:find(educate,graduate_level),
    [GiftStartLevel]=common_config_dyn:find(educate,gift_start_level),
    [EducateLevel]=common_config_dyn:find(educate,educate_level),
    {teacher,TeacherLevel}=proplists:lookup(teacher,EducateLevel),
    %%玩家升级到可以做导师的等级发消息通知玩家到王都师徒管理处升级导师称号
    if NewLevel =:= TeacherLevel -> 
            TeacherLevel;
       true ->
            ok
    end,
    %%玩家升级小于出师等级级师德值贡献
    catch begin
              [RoleInfo] = get_(RoleID),
              NewInfo = RoleInfo#r_educate_role_info{level=NewLevel},
              put_(RoleID,NewInfo),
              updata_educate_role_info([NewInfo]),
              if NewLevel > GiftStartLevel-1 andalso NewLevel < GraduateLevel -> 
                      ?DEBUG("RoleID:~w ~w > ~w andalso ~w < ~w~n",[RoleID,NewLevel ,GiftStartLevel-1, NewLevel, GraduateLevel]),
                      do_role_upgrade(RoleID,OldLevel,NewLevel,State);
                 NewLevel =:= GraduateLevel ->
                      ?DEBUG("RoleID:~w ~w > ~w ~n",[RoleID, NewLevel ,GraduateLevel-1]),
                      do_graduate(RoleID,OldLevel,NewLevel,State);
                 true ->
                      ignore
              end
          end,
    {noreply, State};
handle_cast({change_sex,RoleID,NewSex}, State) ->
    try
        [Info] = get_(RoleID),
        put_(RoleID,Info#r_educate_role_info{sex=NewSex})
    catch
        _:Error ->
            ?ERROR_MSG("~w change sex ~w failed error ~w!~n",[RoleID,NewSex,Error])
    end,
    {noreply,  State};
handle_cast(Request, State) ->
    ?ERROR_MSG("unknow call ~p ", [Request]),
    {noreply,  State}.

%% 处理游戏玩家的请求信息
handle_info({Unique, ?EDUCATE, Method, DataIn, RoleID, Pid, Line}, State) ->
    ?DEBUG("EDUCATE DATA:~w~n",[DataIn]),
    Info = #r_msg{unique=Unique,
                  module=?EDUCATE,
                  method=Method,
                  data=DataIn,
                  roleid=RoleID,
                  pid=Pid,
                  line=Line,
                  state=State},
    ?DO_HANDLE_INFO(Info, State),
    {noreply, State};

%% 减PK值成功
handle_info({moral_value_to_pkpoint_succ, RoleID, ReturnPoint, ReducePoint, Msg}, State) ->
    %% 返还师德
    case get_(RoleID) of
        [Info] ->
            #r_educate_role_info{moral_values=Morals}=Info,
            put_(RoleID,Info#r_educate_role_info{moral_values=Morals+ReturnPoint}),
            Record = #m_educate_moral_value_to_pkpoint_toc{moral_value=Morals+ReturnPoint, pk_point=ReducePoint},
            educate_unicast(Msg, Record);
        _ ->
            ignore
    end,
    {noreply, State};

%% 减PK值失败，返还师德
handle_info({moral_value_to_pkpoint_fail, RoleID, MoralValue, Msg}, State) ->
    case get_(RoleID) of
        [Info] ->
            #r_educate_role_info{moral_values=Morals}=Info,
            put_(RoleID,Info#r_educate_role_info{moral_values=Morals+MoralValue}),
            Record = #m_educate_moral_value_to_pkpoint_toc{succ=false, reason=?_LANG_SYSTEM_ERROR},
            educate_unicast(Msg, Record);
        _ ->
            ignore
    end,
    {noreply, State};

%% call友劈人
handle_info({call_educate_helper,RoleID,MapID,Pos},State)->
    catch do_call_educate_helper(RoleID, MapID, Pos),
    {noreply, State};

%% 玩家下线清除数据
handle_info({remove_time_and_pos,RoleID},State)->
    erlang:erase({?EDUCATE_HELP_TIME_AND_DEAD_POS,RoleID}),
    {noreply, State};

handle_info(persistence, State) ->
    erlang:send_after(?PERSISTENCE_TIME,self(),persistence),
    catch persistence(),
    case up_invite_ck_ct() of
        100 ->
            erlang:send(self(), check_timeout_invite),
            rm_invite_ck_ct();
        _ ->
            ignore
    end,
    {noreply, State};

handle_info(check_timeout_invite, State) ->
    catch del_timeout_invite(),
    {noreply, State};

%%测试
handle_info({test,RoleID}, State) ->
    catch ?DEBUG("get5relation:~w~n",[get5relation(RoleID)]),
    {noreply, State};

handle_info(Info, State) ->
    ?ERROR_MSG("unknow info ~w",[Info]),
    {noreply, State}.
    
terminate(Reason, State) ->
    catch persistence(),
    ?ERROR_MSG("educate server terminate error:~w",[Reason]),
    {stop,Reason, State}.

code_change(_Request,_Code,_State)->
    ok.  

do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_REPLY_INVITE_APPRENTICE ->
    do_reply_apprentice(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_REPLY_INVITE_ADMISSIONS ->
    do_reply_admissions(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_SWORN_MENTORING ->
    do_sworn_mentoring(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_FILTER_STUDENT ->
    do_filter_student(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_FILTER_TEACHER ->
    do_filter_teacher(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_EXPEL ->
    do_expel(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_DROPOUT ->
    do_dropout(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_GET_STUDENTS_INFO ->
    do_get_students_info(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_GET_CLAN_INFO ->
    do_get_clan_info(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_GET_INFO ->
    do_get_info(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_MORAL_VALUE_TO_EXP ->
    do_mora2exp(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_UPGRADE ->
    do_upgrade(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_MORAL_VALUE_TO_PKPOINT ->
    do_moral_value_to_pkpoint(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_GET_EXPEL_MORAL_VALUE ->
    do_get_expel_moral_value(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_GET_DROPOUT_MORAL_VALUE ->
    do_get_dropout_moral_value(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_AGREE_HELP ->
    do_help_educate_role(Msg);
do_handle_info(Msg)when Msg#r_msg.method =:= ?EDUCATE_GET_RELATE_PEOPLE->
    do_get_educate_relate_people(Msg);
do_handle_info(Msg) when Msg#r_msg.method =:= ?EDUCATE_TRANSFER ->
    do_transfer(Msg);
do_handle_info(Msg) when Msg#r_msg.method =:= ?EDUCATE_RELEASE ->
    do_release(Msg);
do_handle_info(Info) ->
    ?ERROR_MSG("unknow info ~w",[Info]).


%% 拜师、收徒弟时可以免费传送
do_transfer(Msg) ->
    common_misc:send_to_rolemap(Msg#r_msg.roleid, {mod_educate, {sure_jump, Msg#r_msg.roleid}}).

%% 发布 拜师、收徒的信息
do_release(Msg) ->
    #m_educate_release_tos{opt=Opt, msg=RMsg}=Msg#r_msg.data, %%Opt 1为发布收徒,2为发布拜师,3为撤销发布
    [Info] = get_(Msg#r_msg.roleid),
    ?DEBUG("OPT:~w Info:~w~n",[Opt, Info]),
    Data = case Opt of
               ?RELEASE_ADMISSIONS ->
                   #r_educate_role_info{level=Level,
                                        student_num=StuNum,
                                        max_student_num=MaxStuNum} = Info,
                   [EducateLevelConfig]=common_config_dyn:find(educate,educate_level),
                   {teacher,TeacherLevel} = proplists:lookup(teacher,EducateLevelConfig),
                   case Level > TeacherLevel-1 of
                       false -> #m_educate_release_toc{succ=false,reason=?_LANG_EDUCATE_LEVEL_LOW};
                       true ->
                           case MaxStuNum == 0 orelse MaxStuNum > StuNum of
                               false -> #m_educate_release_toc{succ=false,reason=?_LANG_EDUCATE_STUDENT_NUM_MAX};
                               true -> 
                                   ReleaseInfo = 
                                       case Info#r_educate_role_info.release_info of
                                           undefined -> #r_release_info{rel_admissions=true,rel_adm_msg=RMsg,rel_adm_time=common_tool:now()};
                                           RelInfo -> RelInfo#r_release_info{rel_admissions=true,rel_adm_msg=RMsg,rel_adm_time=common_tool:now()}
                                       end,
                                   NewInfo = Info#r_educate_role_info{release_info=ReleaseInfo},
                                   put_(Msg#r_msg.roleid, NewInfo),
                                   ?DEBUG("CVTINFO:~w~n",[convert2toc(NewInfo,0)]),
                                   #m_educate_release_toc{succ=true, info=convert2toc(NewInfo,0)}
                           end
                   end;
               ?RELEASE_APPRENTICE ->
                   #r_educate_role_info{level=Level,
                                        teacher=Teacher} = Info,
                   [EducateLevelConfig]=common_config_dyn:find(educate,educate_level),
                   {min_student,MinStudentLevel} = proplists:lookup(min_student,EducateLevelConfig),
                   {max_student,MaxStudentLevel} = proplists:lookup(max_student,EducateLevelConfig),
                   case Level > MinStudentLevel-1 andalso Level < MaxStudentLevel of
                       false -> #m_educate_release_toc{succ=false,reason=?_LANG_EDUCATE_LEVEL_MAX};
                       true ->
                           case Teacher =:= undefined of
                               false -> #m_educate_release_toc{succ=false,reason=?_LANG_EDUCATE_HAS_TEACHER};
                               true ->
                                   ReleaseInfo = 
                                       case Info#r_educate_role_info.release_info of
                                           undefined -> #r_release_info{rel_apprentice=true,rel_app_msg=RMsg,rel_app_time=common_tool:now()};
                                           RelInfo -> RelInfo#r_release_info{rel_apprentice=true,rel_app_msg=RMsg,rel_app_time=common_tool:now()}
                                       end,
                                   NewInfo = Info#r_educate_role_info{release_info=ReleaseInfo},
                                   put_(Msg#r_msg.roleid, NewInfo),
                                   #m_educate_release_toc{succ=true, info=convert2toc(NewInfo,0)}
                           end
                   end;
               ?UNRELEASE_ADMISSIONS ->
                   NewReleaseInfo = 
                       case Info#r_educate_role_info.release_info of
                           undefined -> #r_release_info{rel_admissions=false,rel_adm_msg="",rel_adm_time=0};
                           RelInfo -> RelInfo#r_release_info{rel_admissions=false,rel_adm_msg="",rel_adm_time=0}
                       end,
                   NewInfo = Info#r_educate_role_info{release_info=NewReleaseInfo},
                   put_(Msg#r_msg.roleid, NewInfo),
                   #m_educate_release_toc{succ=true, info=convert2toc(NewInfo,0)};
               ?UNRELEASE_APPRENTICE ->
                   NewReleaseInfo = 
                       case Info#r_educate_role_info.release_info of
                           undefined -> #r_release_info{rel_apprentice=false,rel_app_msg="",rel_app_time=0};
                           RelInfo -> RelInfo#r_release_info{rel_apprentice=false,rel_app_msg="",rel_app_time=0}
                       end,
                   NewInfo = Info#r_educate_role_info{release_info=NewReleaseInfo},
                   put_(Msg#r_msg.roleid, NewInfo),
                   #m_educate_release_toc{succ=true, info=convert2toc(NewInfo,0)};
               _ ->
                   #m_educate_release_toc{succ=false,reason=?_LANG_EDUCATE_RELEASE_TYPE_ERROR}
           end,
    ?DEBUG("Data:~w~n",[Data]),
    educate_unicast(Msg, Data).


%%玩家结为师徒的动作--------------------------------------------------------------------------------
do_sworn_mentoring(Msg) ->
    #r_msg{roleid = RoleID1}=Msg,
    #m_educate_sworn_mentoring_tos{roleid=RoleID2}=(Msg#r_msg.data),
    Now = common_tool:now(),
    ?DEBUG("Msg:~w~n",[Msg]),
    Data = case get_invite({RoleID1, RoleID2}) of
               [{_,_,Invite}] when Now - Invite < ?INVITE_TIMEOUT ->
                   #m_educate_sworn_mentoring_toc{succ=false,reason=?_LANG_EDUCATE_ALREADY_REPLY};
               _ ->
                   ?DEBUG("RoleID1:~w, RoleID2:~w~n",[RoleID1,RoleID2]),
                   [Info1] = get_(RoleID1),
                   [Info2] = get_(RoleID2),
                   ?DEBUG("Info1:~w, Info2:~w~n",[Info1,Info2]),
                   case check_action(Info1, Info2) of
                       {ok, Action, TeacherInfo,TeacherRoleID,StudentInfo,StudentRoleID} ->
                           Name = Info1#r_educate_role_info.name,
                           case check_sworn(Action, TeacherInfo,TeacherRoleID,StudentInfo,StudentRoleID) of
                               {error, Reason} ->
                                   #m_educate_sworn_mentoring_toc{succ=false,reason=Reason};
                               ok when Action =:= 1-> %%拜 Role2为师
                                   Ref = put_invite(RoleID1, RoleID2),
                                   Invite = #m_educate_invite_apprentice_toc{ref=Ref,rolename = Name},
                                   educate_unicast(RoleID2,?EDUCATE_INVITE_APPRENTICE,Invite),
                                   #m_educate_sworn_mentoring_toc{succ=true,reason=?_LANG_EDUCATE_INVITE_OK};
                               ok when Action =:= 2 -> %%收 Role2为徒
                                   Ref = put_invite(RoleID1, RoleID2),
                                   Invite = #m_educate_invite_admissions_toc{ref=Ref,rolename = Name},
                                   educate_unicast(RoleID2,?EDUCATE_INVITE_ADMISSIONS,Invite),
                                   #m_educate_sworn_mentoring_toc{succ=true,reason=?_LANG_EDUCATE_INVITE_OK}
                           end;
                       {error, Reason} ->
                             #m_educate_sworn_mentoring_toc{succ=false,reason=Reason}
                   end
           end,
    educate_unicast(Msg, Data).

%%回复拜自己为师
do_reply_apprentice(Msg) ->
    #m_educate_reply_invite_apprentice_tos{ref=Ref, is_agree=IsAgree} = (Msg#r_msg.data),
    Now = common_tool:now(),
    case pop_invite(Ref) of
        [{RoleID1,RoleID2,Invite}] when Now - Invite < ?INVITE_TIMEOUT , IsAgree =:= true ->
            %%RoleID1表示是师傅，RoleID2表示自己
            [Info1] = get_(RoleID1),
            [Info2] = get_(RoleID2),
            case check_action(Info2, Info1) of
                {ok, 2, _, _, _, _} ->
                    case check_sworn(2, Info2,RoleID2,Info1,RoleID1) of
                        {error, Reason} ->
                            do_reply_apprentice_succ(false,RoleID1,?_LANG_EDUCATE_APPRENTICE_FAIL,undefined,
                                                     Msg,Reason,undefined);
                        ok ->
                            case add_friend(RoleID2,RoleID1) of
                                {error, Reason} ->
                                    do_reply_apprentice_succ(false,RoleID1,?_LANG_EDUCATE_APPRENTICE_FAIL,undefined, 
                                                             Msg,Reason, undefined);
                                ok ->
                                    #r_educate_role_info{name=Name01,level=Level}=Info1,
                                    #r_educate_role_info{name=Name02,students=Stus,student_num=Num,
                                                         max_student_num=MaxNum,title=Title, release_info=RelInfo}=Info2,
                                    NewInfo1 = Info1#r_educate_role_info{teacher=RoleID2,apprentice_level=Level,teacher_name=Name02},
                                    {NewMaxNum,NewNum,NewTitle} =
                                        if Title =:= 0 ->
                                                [ConfigTitle]=common_config_dyn:find(educate,title),
                                                {title_list,TitleList} = proplists:lookup(title_list,ConfigTitle),
                                                {_, _TName, _TColor, _L,_Mo,_MMo,Sn} = lists:keyfind(1,1,TitleList),
                                                {Sn,1,1};
                                           true ->
                                                {MaxNum,Num+1,Title}
                                        end,
                                    NewReleaseInfo = 
                                        if NewMaxNum =:= NewNum andalso  is_record(RelInfo,r_release_info) ->
                                                RelInfo#r_release_info{rel_admissions=false,rel_adm_msg="",rel_adm_time=0};
                                           true ->
                                                RelInfo
                                        end,
                                    NewInfo2 = Info2#r_educate_role_info{students=[RoleID1|Stus],student_num=NewNum, max_student_num=NewMaxNum,
                                                                         title=NewTitle, release_info=NewReleaseInfo},
                                    put_(RoleID1, NewInfo1),
                                    put_(RoleID2, NewInfo2),
                                    Name1 = common_tool:to_list(Name01),
                                    Name2 = common_tool:to_list(Name02),
                                    common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,"哇！["++Name1++"]拜得名师["++Name2++"]！"),
                                    common_hook_achievement:hook({mgeew_educate_server,{agree,NewInfo2,NewInfo1}}),
                                    common_mod_goal:hook_educate(RoleID1, RoleID2),
                                    do_reply_apprentice_succ(true,RoleID1,?_LANG_EDUCATE_AGREE_REPLY_APPRENTICE,NewInfo1,
                                                             Msg,?_LANG_EDUCATE_SWORN_OK,NewInfo2)
                            end
                    end;
                Other1 ->
                    ?DEBUG("376 Other:~w~n",[Other1]),
                    do_reply_apprentice_succ(false,undefined,undefined,undefined,
                                             Msg,?_LANG_EDUCATE_INVITE_OUTTIME,undefined)
            end;
        [{RoleID1,_,Invite}] when Now - Invite < ?INVITE_TIMEOUT , IsAgree =:= false ->
            do_reply_apprentice_succ(false,RoleID1,?_LANG_EDUCATE_REFUSAL_INVITE,undefined,
                                     Msg,?_LANG_EDUCATE_YOU_REFUSAL_APPRENTICE_OK,undefined);
        Other2 ->
            ?DEBUG("384 Other:~w~n",[Other2]),
            do_reply_apprentice_succ(false,undefined,undefined,undefined,
                                     Msg,?_LANG_EDUCATE_INVITE_OUTTIME,undefined)
    end.

do_reply_apprentice_succ(Succ,OtherRoleID,OtherReason,Info1,Msg,SelfReason,Info2) ->
    case OtherRoleID of
        undefined ->
            ignore;
        _ ->
            Result =  #m_educate_invite_apprentice_result_toc{succ = Succ,
                                                              info = convert2toc(Info1,0),
                                                              reason = OtherReason},
            educate_unicast(OtherRoleID,?EDUCATE_INVITE_APPRENTICE_RESULT,Result)
    end,
    Data = #m_educate_reply_invite_apprentice_toc{succ = Succ,
                                                  info = convert2toc(Info2,0),
                                                  reason = SelfReason},
    educate_unicast(Msg, Data).

%%回复收自己为徒
do_reply_admissions(Msg) ->
    #m_educate_reply_invite_admissions_tos{ref=Ref, is_agree=IsAgree} = (Msg#r_msg.data),
    Now = common_tool:now(),
    case pop_invite(Ref) of
        [{RoleID1,RoleID2,Invite}] when Now - Invite < ?INVITE_TIMEOUT, IsAgree =:= true ->
            %%RoleID1表示是徒弟，RoleID2表示自己
            [Info1] = get_(RoleID1),
            [Info2] = get_(RoleID2),
            case check_action(Info2, Info1) of
                {ok, 1, _, _, _, _} -> 
                    case check_sworn(1, Info1,RoleID1,Info2,RoleID2) of
                        {error, Reason} ->
                            do_reply_admissions_succ(false,RoleID1,?_LANG_EDUCATE_ADMISSIONS_FAIL,undefined,
                                                     Msg,Reason,undefined);
                        ok ->
                            case add_friend(RoleID1,RoleID2) of
                                {error, Reason} ->
                                    do_reply_admissions_succ(false,RoleID1,?_LANG_EDUCATE_ADMISSIONS_FAIL,undefined,
                                                             Msg,Reason,undefined);
                                ok ->
                                    #r_educate_role_info{name=Name01,students=Stus, student_num=Num,
                                                         max_student_num=MaxNum,title=Title, release_info=RelInfo}=Info1,
                                    #r_educate_role_info{name=Name02,level=Level}=Info2,
                                    {NewMaxNum,NewNum,NewTitle} =
                                        if Title =:= 0 ->
                                                [ConfigTitle]=common_config_dyn:find(educate,title),
                                                {title_list,TitleList} = proplists:lookup(title_list,ConfigTitle),
                                                {_, _TName, _TColor, _L,_Mo,_MMo,Sn} = lists:keyfind(1,1,TitleList),
                                                {Sn,1,1};
                                           true ->
                                                {MaxNum,Num+1,Title}
                                        end,
                                    NewReleaseInfo = 
                                        if NewMaxNum =:= NewNum andalso  is_record(RelInfo,r_release_info) ->
                                                RelInfo#r_release_info{rel_admissions=false,rel_adm_msg="",rel_adm_time=0};
                                           true ->
                                                RelInfo
                                        end,
                                    NewInfo1 = Info1#r_educate_role_info{students=[RoleID2|Stus],student_num=NewNum,max_student_num=NewMaxNum,
                                                                         title= NewTitle, release_info=NewReleaseInfo},
                                    NewInfo2 = Info2#r_educate_role_info{teacher=RoleID1,apprentice_level=Level,teacher_name=Name01},
                                    put_(RoleID1, NewInfo1),
                                    put_(RoleID2, NewInfo2),
                                    Name1 = common_tool:to_list(Name01),
                                    Name2 = common_tool:to_list(Name02),
                                    common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CENTER,?BC_MSG_SUB_TYPE,"哇！["++Name2++"]拜得名师["++Name1++"]！"),
                                    common_hook_achievement:hook({mgeew_educate_server,{agree,NewInfo1,NewInfo2}}),
                                    common_mod_goal:hook_educate(RoleID1, RoleID2),
                                    do_reply_admissions_succ(true,RoleID1,?_LANG_EDUCATE_AGREE_REPLY_ADMISSIONS,NewInfo1,
                                                             Msg,?_LANG_EDUCATE_SWORN_OK,NewInfo2)
                            end
                    end;
                Other1 ->
                    ?DEBUG("440 Other:~w~n",[Other1]),
                    do_reply_admissions_succ(false,undefined,undefined,undefined,
                                             Msg,?_LANG_EDUCATE_INVITE_OUTTIME,undefined)
            end;
        [{RoleID1,_,Invite}] when Now - Invite < ?INVITE_TIMEOUT, IsAgree =:= false ->
            do_reply_admissions_succ(false,RoleID1,?_LANG_EDUCATE_REFUSAL_INVITE,undefined,
                                     Msg,?_LANG_EDUCATE_YOU_REFUSAL_ADMISSIONS_OK, undefined);
        Other2 ->
            ?DEBUG("448 Other:~w~n",[Other2]),
            do_reply_admissions_succ(false,undefined,undefined,undefined,
                                     Msg,?_LANG_EDUCATE_INVITE_OUTTIME,undefined)
    end.

do_reply_admissions_succ(Succ,OtherRoleID,OtherReason,Info1,Msg,SelfReason,Info2) ->
    case OtherRoleID of
        undefined ->
            ignore;
        _ ->
            Result =  #m_educate_invite_admissions_result_toc{succ = Succ,
                                                              info = convert2toc(Info1,0),
                                                              reason = OtherReason},
            educate_unicast(OtherRoleID,?EDUCATE_INVITE_ADMISSIONS_RESULT,Result)
    end,
    Data = #m_educate_reply_invite_admissions_toc{succ = Succ,
                                                  info = convert2toc(Info2,0),
                                                  reason = SelfReason},
    educate_unicast(Msg, Data).
   
add_friend(TeacherRoleID, StudentRoleID) ->
    case mod_friend_server:add_friend(TeacherRoleID, StudentRoleID, 1) of
        {error,Reason} when is_binary(Reason) ->
            {error, Reason};
        {error,_Reason} ->
            {error, ?_LANG_EDUCATE_PERSONALS_FAIL};
        ok ->
            ok
    end.

%%@docAction为1表示拜师，为2表示收徒
%%返回 {ok, Action, TeacherInfo,TeacherRoleID,StudentInfo,StudentRoleID}|{error, Reason}
check_action(SelfInfo, OtherInfo) ->
    if
        SelfInfo#r_educate_role_info.level >
        OtherInfo#r_educate_role_info.level ->
            {ok,2, 
             SelfInfo, SelfInfo#r_educate_role_info.roleid ,
             OtherInfo, OtherInfo#r_educate_role_info.roleid};
        SelfInfo#r_educate_role_info.level <
        OtherInfo#r_educate_role_info.level ->
            {ok,1, 
             OtherInfo, OtherInfo#r_educate_role_info.roleid ,
             SelfInfo, SelfInfo#r_educate_role_info.roleid};
        true ->
            {error, ?_LANG_EDUCATE_LEVEL_NOT_DO_EQUAL}
    end.

check_sworn(Action, TeacherInfo, TeacherRoleID, StudentInfo, StudentRoleID) ->
    try
        case is_integer(StudentInfo#r_educate_role_info.teacher) andalso
                 StudentInfo#r_educate_role_info.teacher > 0
            of
            true -> throw(?_LANG_EDUCATE_HAS_TEACHER);
            false -> next
        end,
        case check_relation(TeacherRoleID, StudentRoleID) of
            undefined ->
                next;
            {?RELATION_SG,_,_} -> %%师公
                throw(?_LANG_EDUCATE_ALREADY_IS_GS);
            {?RELATION_SF,_,_} -> %%师傅
                throw(?_LANG_EDUCATE_ALREADY_IS_TEACHER);
            {?RELATION_XD,_,_} -> %%师兄弟
                throw(?_LANG_EDUCATE_ALREADY_IS_XD);
            {?RELATION_TD,_,_} -> %%徒弟
                throw(?_LANG_EDUCATE_ALREADY_IS_TEACHER);
            {?RELATION_TS,_,_} -> %%徒孙
                throw(?_LANG_EDUCATE_ALREADY_IS_GS)
        end,
        case mod_friend_server:get_friend_type(TeacherRoleID, StudentRoleID) of
            {3,_ }when Action =:= 2 ->
                throw(?_LANG_EDUCATE_IS_ENEMY_ADMISSIONS);
            _Other1 ->
                ok
        end,
        case mod_friend_server:get_friend_type(StudentRoleID,TeacherRoleID) of
            {3,_ }when Action =:= 1 ->
                throw(?_LANG_EDUCATE_IS_ENEMY_APPRENTICE);
            _Other2 ->
                ok
        end,
        ok = check_level(Action, TeacherInfo, StudentInfo),
        ok = check_teacher(Action, TeacherInfo)
    catch
        throw:Reason when is_binary(Reason) ->
            {error, Reason};
        _:_ ->
            {error, ?_LANG_SYSTEM_ERROR}
    end.

%%Action为1表示拜师，为2表示收徒
check_level(Action,#r_educate_role_info{level=TeacherLevel}=TeacherInfo, 
            #r_educate_role_info{level=StudentLevel}=StudentInfo) -> 
    [EducateLevelConfig]=common_config_dyn:find(educate,educate_level),
    {teacher,TeacherLevelConfig} = proplists:lookup(teacher,EducateLevelConfig),
    {min_student,MinStudentLevelConfig} = proplists:lookup(min_student,EducateLevelConfig),
    {max_student,MaxStudentLevelConfig} = proplists:lookup(max_student,EducateLevelConfig),
    {level_diff,LevelDiff} = proplists:lookup(level_diff,EducateLevelConfig),
    TeacherLevel = TeacherInfo#r_educate_role_info.level,
    StudentLevel = StudentInfo#r_educate_role_info.level,
    case TeacherLevel < TeacherLevelConfig of
        true when Action =:= 1 ->
            throw(?_LANG_EDUCATE_OTHER_SIDE_NOT_TITLE);
        true when Action =:= 2 ->
            throw(?_LANG_EDUCATE_NOT_TITLE);
        false ->
            ok
    end,
    case StudentLevel < MinStudentLevelConfig of
        true when Action =:= 1 ->
            throw(?_LANG_EDUCATE_LEVEL_LOW);
        true when Action =:= 2 ->
            throw(?_LANG_EDUCATE_OTHER_SIDE_LEVEL_LOW);
        false ->
            ok
    end,
    case StudentLevel > MaxStudentLevelConfig-1 of
        true when Action =:= 1 ->
            throw(?_LANG_EDUCATE_LEVEL_MAX);
        true when Action =:= 2 ->
            throw(?_LANG_EDUCATE_OTHER_SIDE_LEVEL_MAX);
        false ->
            ok
    end,
    case TeacherLevel - StudentLevel of
        R when R < LevelDiff,Action =:= 1 ->
            throw(?_LANG_EDUCATE_LEVEL_POOR_LOW);
        R when R < LevelDiff,Action =:= 2 ->
            throw(?_LANG_EDUCATE_LEVEL_OTHER_SIDE_POOR_LOW);
        _ ->
            ok
    end.

%%Action为1表示拜师，为2表示收徒
check_teacher(Action,#r_educate_role_info{max_student_num=Max,student_num=Num}) ->
    case Max =/= 0 andalso Num +1 > Max of
        true when Action =:= 1 ->
            throw(?_LANG_EDUCATE_OTHER_SIDE_STUDENT_NUM_MAX);
        true when Action =:= 2 ->
            throw(?_LANG_EDUCATE_STUDENT_NUM_MAX);
        false ->
            ok
    end.
                                                           
%%过滤徒弟
do_filter_student(Msg) ->
    [EducateLevelConfig]=common_config_dyn:find(educate,educate_level),
    {level_diff,LevelDiff} = proplists:lookup(level_diff,EducateLevelConfig),
    [#r_educate_role_info{faction_id=FactionID,level=Level}] = get_(Msg#r_msg.roleid),    
    AllRoleID = get5all(Msg#r_msg.roleid),
    List0 = [TR || {Lv,TR} <- get_reco_stus(FactionID), Level-Lv > LevelDiff],
    List1 = lists:filter(fun(RID) -> not lists:member(RID, AllRoleID) end, List0),
    List2 = [convert2toc(Info,0) || Info <- get_s(lists:sublist(List1,20))],
    R = #m_educate_filter_student_toc{roles = lists:sort(fun filter_student_cmp/2, List2)},
    educate_unicast(Msg, R).

filter_student_cmp(#p_educate_role_info{level=LVL1,rel_app_time=RT1},
                   #p_educate_role_info{level=LVL2,rel_app_time=RT2}) ->
    if LVL1 > LVL2 -> true;
       LVL1 =:= LVL2 ->
            if RT1 > RT2 -> true;
               true -> false
            end;
       true -> false
    end.
    
%%过滤师傅
do_filter_teacher(Msg) ->
    [EducateLevelConfig]=common_config_dyn:find(educate,educate_level),
    {level_diff,LevelDiff} = proplists:lookup(level_diff,EducateLevelConfig),   
    [#r_educate_role_info{faction_id=FactionID,level=Level}] = get_(Msg#r_msg.roleid),
    AllRoleID = get5all(Msg#r_msg.roleid),
    List0 = [TR || {Lv,TR} <- get_reco_tcrs(FactionID), Lv-Level > LevelDiff],
    List1 = lists:filter(fun(RID) -> not lists:member(RID, AllRoleID) end, List0),
    List2 = [convert2toc(Info,0) || Info <- get_s(lists:sublist(List1,20))],
    R = #m_educate_filter_teacher_toc{roles = lists:sort(fun filter_teacher_cmp/2, List2)},
    educate_unicast(Msg, R).

filter_teacher_cmp(#p_educate_role_info{level=LVL1,moral_values=MV1,student_num=SN1},
                   #p_educate_role_info{level=LVL2,moral_values=MV2,student_num=SN2}) ->
    if MV1 > MV2 -> true;
       MV1 =:= MV2 ->
            if SN1 > SN2 -> true;
               SN1 =:= SN2 ->
                    if LVL1 > LVL2 -> true;
                       true -> false
                    end;
               true -> false
            end;
       true -> false
    end.


%%同门的信息
do_get_clan_info(Msg) ->
    Clans = [convert2toc(Info,Relate) || {Relate,Info} <- get_clan(Msg#r_msg.roleid)],
    educate_unicast(Msg, #m_educate_get_clan_info_toc{clans=Clans}).
   
%%徒弟的信息
do_get_students_info(Msg) ->
    Stus = [convert2toc(Info,Relate) || {Relate,Info} <- get_posterity(Msg#r_msg.roleid)],
    educate_unicast(Msg, #m_educate_get_students_info_toc{students=Stus}).

%%获取5代关系（师公，师傅，师兄弟，徒弟，徒孙）
do_get_educate_relate_people(Msg)->
    RelationList = [convert2toc(Info,Relate) || {Relate,Info} <- get5relation(Msg#r_msg.roleid)],
    educate_unicast(Msg, #m_educate_get_relate_people_toc{educate_role_info=RelationList}).

%%自己的信息
do_get_info(Msg) ->
    [Info] = get_(Msg#r_msg.roleid),
    educate_unicast(Msg, #m_educate_get_info_toc{roleinfo = convert2toc(Info,0)}).

%%离开师门   
do_dropout(Msg)->
    [#r_educate_role_info{teacher=Teacher,
                          level = Level,
                          apprentice_level = ALevel,
                          moral_values=Morals1}=Info1] 
        = get_(Msg#r_msg.roleid),
    case check_dropout(Info1) of
        ok ->
            Now = common_tool:now(),
            [#r_educate_role_info{students=Stus,moral_values = Morals2,student_num=Num} = Info2]
                = get_(Teacher),
            [[{TRate,TValue0},{SRate,SValue0}]]=common_config_dyn:find(educate,dropout_moral_rate),
            TValue = calc_value(ALevel,Level,TRate,TValue0,Now,Now),
            SValue = calc_value(ALevel,Level,SRate,SValue0,Now,Now),
            NewInfo1 = Info1#r_educate_role_info{teacher=undefined,
                                                 teacher_name = <<>>,
                                                 moral_values=Morals1-SValue,
                                                 dropout_time=Now},
            NewInfo2 = Info2#r_educate_role_info{students=lists:delete(Msg#r_msg.roleid,Stus),
                                                 moral_values = Morals2-TValue,
                                                 student_num=Num-1},
            put_(Msg#r_msg.roleid, NewInfo1),
            put_(Teacher, NewInfo2),
            %%离开师门发送信件给老师
            LeaveTeacherText = lists:flatten(io_lib:format(?EDUCATE_LETTER_STUDENT_LEAVE_TEACHER, 
                                                           [NewInfo2#r_educate_role_info.name,
                                                            NewInfo1#r_educate_role_info.name])),
            common_letter:sys2p(Teacher,LeaveTeacherText,?EDUCATE_LETTER_TITTLE,2),
            mod_friend_server:relative_modify(Teacher, Msg#r_msg.roleid, 1, 2),
            educate_unicast(Teacher,?EDUCATE_DROPOUT,
                            #m_educate_dropout_toc{succ=true,
                                                   roleid=Teacher,
                                                   info= convert2toc(NewInfo2,0),
                                                   is_teacher = true}),
            educate_unicast(Msg,#m_educate_dropout_toc{succ=true,
                                                       roleid=Msg#r_msg.roleid,
                                                       info=convert2toc(NewInfo1,0),
                                                       is_teacher=false});
        {error, Reason} ->
            educate_unicast(Msg,#m_educate_dropout_toc{succ=false,reason=Reason})
    end.

check_dropout(#r_educate_role_info{level=Level,teacher=Teacher}) ->
    try
        [GraduateLevel]=common_config_dyn:find(educate,graduate_level),
        case (is_integer(Teacher) andalso Teacher > 0) of
            true ->
                ok;
            false ->
                throw(?_LANG_EDUCATE_NOT_TEACHER)
        end,
        case Level > GraduateLevel-1 of
            true ->
                throw(?_LANG_EDUCATE_ALREADY_GRADUATE_DROPOUT);
            false ->
                ok
        end
    catch
        throw:Reason when is_binary(Reason) ->
            {error, Reason};
        _:_  ->
            {error, ?_LANG_SYSTEM_ERROR}
    end.

%%开除徒弟
do_expel(Msg) ->
    [#r_educate_role_info{roleid=RoleID,
                          moral_values=Morals1,
                          students=Stus,
                         student_num=Num}=Info1] = 
        get_(Msg#r_msg.roleid),
    [#r_educate_role_info{roleid=Student,
                          level=Level,
                          apprentice_level=ALevel,
                          online=OnLine} = Info2] = 
        get_((Msg#r_msg.data)#m_educate_expel_tos.roleid),
    [{Rate,Value}]=common_config_dyn:find(educate,expel_moral_rate),
    case check_expel(Info1,Info2) of
        ok ->
            Now = common_tool:now(),
            RValue = case OnLine of 
                         true -> calc_value(ALevel,Level,Rate,Value,Now,Now);
                         false -> 
                             {ok, #p_role_ext{last_offline_time=OffLineTime}}= 
                                 common_misc:get_dirty_role_ext(Student),
                             calc_value(ALevel,Level,Rate,Value,Now, OffLineTime)
                     end,
            NewInfo1 = Info1#r_educate_role_info{moral_values=Morals1-RValue,
                                                 students=lists:delete(Student,Stus),
                                                 expel_time=Now,
                                                 student_num=Num-1},
            NewInfo2 = Info2#r_educate_role_info{teacher=undefined,teacher_name= <<>>},
            put_(RoleID, NewInfo1),
            put_(Student, NewInfo2),
            mod_friend_server:relative_modify(RoleID, Student, 1, 2),
            %%开除徒弟发送信件给徒弟
            QuitStudentText = lists:flatten(io_lib:format(?EDUCATE_LETTER_TEACHER_QUIT_STUDENT, 
                                                          [NewInfo2#r_educate_role_info.name,
                                                           NewInfo1#r_educate_role_info.name])),
            common_letter:sys2p(Student,QuitStudentText,?EDUCATE_LETTER_TITTLE,2),
            educate_unicast(Student,?EDUCATE_EXPEL,
                            #m_educate_expel_toc{succ=true,
                                                 roleid=Student,
                                                 info=convert2toc(NewInfo2,0),
                                                 is_teacher = false}),
            educate_unicast(Msg,#m_educate_expel_toc{succ=true,
                                                     roleid=RoleID,
                                                     info=convert2toc(NewInfo1,0),
                                                     is_teacher = true});
        {error, Reason} ->
            educate_unicast(Msg,#m_educate_expel_toc{succ=false,reason=Reason})
    end.

check_expel(#r_educate_role_info{students=Students}=_TeacherInfo, 
            #r_educate_role_info{roleid=StuID,level=Level}=_StudentInfo) ->
    try
        [GraduateLevel]=common_config_dyn:find(educate,graduate_level),
        case lists:member(StuID,Students) of
            false ->
                throw(?_LANG_EDUCATE_NOT_FIND_SUTDENT);
            true ->
                ok
        end,
        case Level > GraduateLevel of
            true ->
                throw(?_LANG_EDUCATE_ALREADY_GRADUATE_EXPEL);
            false ->
                ok
        end
    catch
        throw:Reason when is_binary(Reason) ->
            {error, Reason};
        _:_ ->
            {error, ?_LANG_SYSTEM_ERROR}
    end.
             
%%导师升级------------------------------------------------------------------------------------------
do_upgrade(Msg) ->
    ?DEBUG("MSG:~w~n",[Msg]),
    [Info] = get_(Msg#r_msg.roleid),
    case check_upgrade(Info) of
        {ok, NInfo, TitleName, TitleColor} ->
            ?DEBUG("NewInfo:~w~n",[NInfo]),
            put_(Msg#r_msg.roleid, NInfo),
            Faction=?GET_FACTION(NInfo#r_educate_role_info.faction_id),
            Name= common_tool:to_list(NInfo#r_educate_role_info.name),
            Text = "<font color=\"#FFFFFF\">恭喜 "++Faction++" 的<font color=\"#FFFF00\">["++
                Name++"]</font>获得 "++TitleName++" 称号，可以收更多的徒弟!</font>",
            common_broadcast:bc_send_msg_faction(NInfo#r_educate_role_info.faction_id,?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_COUNTRY,Text),
%%             common_broadcast:bc_send_msg_world(?BC_MSG_TYPE_CHAT,?BC_MSG_TYPE_CHAT_WORLD,Text),
            common_title:add_title(?TITLE_EDUCATE,Info#r_educate_role_info.roleid,{TitleName, TitleColor}),
            educate_unicast(Msg,#m_educate_upgrade_toc{succ=true});
        {error, Reason} ->
            educate_unicast(Msg,#m_educate_upgrade_toc{succ=false,reason=Reason})
    end.

check_upgrade(#r_educate_role_info{level=Level,moral_values=Morals,title=Title}=Info) ->
    try
        [ConfigTitle]=common_config_dyn:find(educate,title),
        {title_list,TitleList} = proplists:lookup(title_list,ConfigTitle),
        {max_title,Max} = proplists:lookup(max_title,ConfigTitle),
        case Title+1 > Max of
            true ->
                throw(?_LANG_EDUCATE_ALREADY_MAX_TITLE);
            false ->
                ok
        end,
        {_,TName, TColor, L,Mo,_MMo,Sn} = lists:keyfind(Title+1,1,TitleList),
        case Level < L of
            true ->
                throw(?_LANG_EDUCATE_NOT_LEVEL);
            false ->
                ok
        end,
        case Morals - Mo of
            Morals ->
                ok;
            R when R < 0 ->
                throw(?_LANG_EDUCATE_NOT_MORALS);
            _R ->
                ok
        end,
        {ok, Info#r_educate_role_info{title=Title+1, max_student_num=Sn}, TName, TColor}
    catch
        throw:Reason when is_binary(Reason) ->
            {error, Reason};
        _:_ ->
            {error, ?_LANG_SYSTEM_ERROR}
    end.

%%师德值换经验-------------------------------------------------------------
do_mora2exp(Msg) ->
    #m_educate_moral_value_to_exp_tos{moral_value=MoralValues} = (Msg#r_msg.data),
    [Info] = get_(Msg#r_msg.roleid),
    case check_moral2exp(Info, MoralValues) of
        {ok, NInfo, AddExp} ->
            put_(Msg#r_msg.roleid, NInfo),
            common_misc:add_exp_unicast(Msg#r_msg.roleid, AddExp),
            educate_unicast(Msg, #m_educate_moral_value_to_exp_toc{succ=true,info=convert2toc(NInfo,0)});
        {error, Reason} ->
            educate_unicast(Msg, #m_educate_moral_value_to_exp_toc{succ=false, reason=Reason})
    end.

check_moral2exp(#r_educate_role_info{moral_values=Morals,
                                       exp_gifts1=Exp1,
                                       exp_gifts2=Exp2}=Info,MoralValues) ->
    try
        [MoralExp]=common_config_dyn:find(educate,moral_exp),
        if MoralValues < 1 ->
                throw(?_LANG_EDUCATE_MORALS_ERROR);
           Morals - MoralValues < 0 ->
                throw(?_LANG_EDUCATE_MORALS_EXIST);
           true ->
                ok
        end,
        case Exp1+Exp2-MoralValues*MoralExp of
            R when R < 0 ->
                {ok, Info#r_educate_role_info{moral_values=Morals-MoralValues,
                                              exp_gifts1=0,
                                              exp_gifts2=0}, MoralValues*MoralExp};
            R when R > Exp2 ->
                {ok, Info#r_educate_role_info{moral_values=Morals-MoralValues,
                                              exp_gifts1=R-Exp2}, MoralValues*MoralExp};
            R ->
                {ok, Info#r_educate_role_info{moral_values=Morals-MoralValues,
                                              exp_gifts1=0,
                                              exp_gifts2=R}, MoralValues*MoralExp}
        end
    catch
        throw:Reason when is_binary(Reason) ->
            {error ,Reason};
        _:_ ->
            {error ,?_LANG_SYSTEM_ERROR}
    end.

%% @doc 师徒值换PK点
do_moral_value_to_pkpoint(Msg) ->
    [#r_educate_role_info{moral_values=Morals}=Info]
        = get_(Msg#r_msg.roleid),
    #m_educate_moral_value_to_pkpoint_tos{moral_value=MoralValues} 
        = Msg#r_msg.data,
    case Morals - MoralValues < 0 orelse MoralValues < 10 of
        true ->
            educate_unicast(Msg, #m_educate_moral_value_to_pkpoint_toc{succ=false, 
                                                                       reason=?_LANG_EDUCATE_MORAL_VALUE_NOT_ENOUGH});
        _ ->
            %% 发消息到地图减PK值
            case common_misc:send_to_rolemap(Msg#r_msg.roleid, 
                                             {mod_map_role, {moral_value_to_pkpoint, self(), Msg#r_msg.roleid, MoralValues, Msg}}) 
            of
                ignore ->
                    DataRecord = #m_educate_moral_value_to_pkpoint_toc{succ=false, reason=?_LANG_SYSTEM_ERROR},
                    educate_unicast(Msg, DataRecord);
                _ ->
                    %% 修改师德值
                    put_(Msg#r_msg.roleid,Info#r_educate_role_info{moral_values=Morals-MoralValues})
            end
    end.

%%玩家升级的计算师德值和贡献经验
%%------------------------------------------------------------    
do_role_upgrade(RoleID, _OldLevel,NewLevel,_State) ->
    [Info] = get_(RoleID),
    [{X,Y}]=common_config_dyn:find(educate,range),
    [EducateLevelConfig]=common_config_dyn:find(educate,educate_level),
    [Rate1]=common_config_dyn:find(educate,gift1_rate),
    [Rate2]=common_config_dyn:find(educate,gift2_rate),
    {level_diff,LevelDiff} = proplists:lookup(level_diff,EducateLevelConfig),
    RelationList = get_clan(RoleID),
    ?DEBUG("RelationList:~w~n",[RelationList]),
    NewInfo1 = Info#r_educate_role_info{level=NewLevel},
    MaxInfo1 = get_max_role_info(NewInfo1, X, Y, LevelDiff),
    SFInfo1 = proplists:get_value(?RELATION_SF, RelationList),
    SGInfo1 = proplists:get_value(?RELATION_SG, RelationList),
    ?DEBUG("NewInfo1:~w,MaxInfo1:~w,SFInfo1:~w,SGInfo1:~w~n",[NewInfo1,MaxInfo1,SFInfo1,SGInfo1]),
    if MaxInfo1 =:= undefined andalso SFInfo1 =:= undefined ->
            updata_educate_role_info([NewInfo1]);
       SFInfo1 =:= undefined ->
            {MaxInfo2,AddMoral} = max_add_moral_values(NewInfo1,MaxInfo1),
            tip_captain(NewInfo1,MaxInfo2#r_educate_role_info.roleid,AddMoral),
            updata_educate_role_info([NewInfo1, MaxInfo2]);
       MaxInfo1 =:= undefined ->
            {NewInfo2,SFInfo2,SGInfo2} = add_gift_exp(NewInfo1, SFInfo1,SGInfo1,Rate1,Rate2),
            SFInfo3 = teacher_add_moral_values(NewInfo2, SFInfo2),
            updata_educate_role_info([NewInfo2,SFInfo3,SGInfo2]);
       MaxInfo1#r_educate_role_info.roleid =:=  SFInfo1#r_educate_role_info.roleid ->
            {MaxInfo2, AddMoral} = max_add_moral_values(NewInfo1, MaxInfo1),
            tip_captain(NewInfo1,MaxInfo2#r_educate_role_info.roleid,AddMoral),
            {NewInfo2,SFInfo2,SGInfo2} = add_gift_exp(NewInfo1,MaxInfo2,SGInfo1,Rate1,Rate2),
            SFInfo3 = teacher_add_moral_values(NewInfo2, SFInfo2),
            updata_educate_role_info([NewInfo2,SFInfo3,SGInfo2]);
       true ->
            {MaxInfo2, AddMoral} = max_add_moral_values(NewInfo1, MaxInfo1),
            tip_captain(NewInfo1,MaxInfo2#r_educate_role_info.roleid,AddMoral),
            {NewInfo2,SFInfo2,SGInfo2} = add_gift_exp(NewInfo1,SFInfo1,SGInfo1,Rate1,Rate2),
            SFInfo3 = teacher_add_moral_values(NewInfo2, SFInfo2),
            updata_educate_role_info([NewInfo2,SFInfo3,SGInfo2,MaxInfo2])
    end.

tip_captain(RoleInfo,MaxRoleID,AddMoral) ->
    #r_educate_role_info{name=Name,level=Level}=RoleInfo,
    Tip = lists:concat(["队员[",binary_to_list(Name),"]升到",Level,"级，队长获得师德值",AddMoral,"点"]),
    educate_unicast(MaxRoleID,?EDUCATE_TIP_CAPTAIN,#m_educate_tip_captain_toc{tip=Tip}).
    
updata_educate_role_info(NewRoleInfoList)
  when is_list(NewRoleInfoList)->
    lists:foreach(
      fun(undefined) ->
              ignore;
         (RoleInfo) ->
              RoleID = RoleInfo#r_educate_role_info.roleid,
              ?DEBUG("RoleID:~w, RoleInfo:~w~n",[RoleID,RoleInfo]),
              put_(RoleID,RoleInfo),
              R = #m_educate_get_info_toc{roleinfo = convert2toc(RoleInfo,0)},
              educate_unicast(RoleID,?EDUCATE_GET_INFO,R)
      end,NewRoleInfoList). 

max_add_moral_values(RoleInfo,MaxRoleInfo) ->
    RoleLevel = RoleInfo#r_educate_role_info.level,
    #r_educate_role_info{roleid=_RoleID,moral_values=Moral}=MaxRoleInfo,
    AddMoral = round(RoleLevel*RoleLevel/100),
    {MaxRoleInfo#r_educate_role_info{moral_values=Moral+ AddMoral},AddMoral}.

teacher_add_moral_values(RoleInfo,TeacherInfo) ->
    RoleLevel = RoleInfo#r_educate_role_info.level,
    #r_educate_role_info{roleid=_RoleID,moral_values=Moral} = TeacherInfo,
    TeacherInfo#r_educate_role_info{ moral_values=Moral+ round(RoleLevel*RoleLevel/16)}.

%%函数的返回值的格式为 {自己信息,师傅信息,师公信息}
add_gift_exp(RoleInfo,SFInfo,SGInfo,Rate1,Rate2) ->
    #r_educate_role_info{level=RoleLevel,
                         exp_devote1=OldDevote1,
                         exp_devote2=OldDevote2}=RoleInfo,
    _Exp1 = RoleLevel*RoleLevel*Rate1,
    _Exp2 = RoleLevel*RoleLevel*Rate2,
    #r_educate_role_info{exp_gifts1=OldGifts1}=SFInfo,
    if SGInfo =:= undefined ->
            {RoleInfo#r_educate_role_info{exp_devote1=_Exp1+OldDevote1},
             SFInfo#r_educate_role_info{exp_gifts1=_Exp1+OldGifts1},
             undefined};
       true ->
            #r_educate_role_info{exp_gifts1=OldGifts2}=SGInfo,
            {RoleInfo#r_educate_role_info{exp_devote1=_Exp1+OldDevote1,exp_devote2=_Exp2+OldDevote2},
             SFInfo#r_educate_role_info{exp_gifts1=_Exp1+OldGifts1},
             SGInfo#r_educate_role_info{exp_gifts2=_Exp2+OldGifts2}}
    end. 

get_max_role_info(#r_educate_role_info{roleid=RoleID}=RoleInfo, X, Y, LevelDiff) ->
    case common_misc:team_get_team_member(RoleID) of
        [] ->
            undefined;
        RoleList ->
            get_max_role(filter_valid(RoleList,RoleID,X,Y),RoleInfo,LevelDiff)
    end.

filter_valid(List,RoleID,X,Y) ->
    lists:foldl(
      fun(Id,Acc)when Id =/= RoleID ->
              case common_misc:check_effective_distance(RoleID, Id, X, Y, []) of
                  false ->
                      Acc;     
                  true ->
                      [Id|Acc]
              end;
         (_,Acc) ->
              Acc
      end,[],List).

get_max_role(List, RoleInfo,LevelDiff) ->
    case lists:foldl(
           fun(Id,Info1) ->
                   case get_(Id) of
                       [Info2] 
                         when Info1#r_educate_role_info.level <
                              Info2#r_educate_role_info.level ->
                           Info2;
                       _ ->
                           Info1
                   end      
           end,RoleInfo,List)
    of
        R when R#r_educate_role_info.level - 
               RoleInfo#r_educate_role_info.level < LevelDiff ->
            undefined;
        R ->
            R
    end.
        
%%出师-------------------------------------------------------------------------------------------
do_graduate(RoleID,_OldLevel,NewLevel,State) ->  
    [Info] = get_(RoleID),
    NewInfo = Info#r_educate_role_info{level=NewLevel},
    ?DEBUG("NewInfo:~w~n",[NewInfo]),
    Teacher = Info#r_educate_role_info.teacher,
    [TeacherInfo] = get_(Teacher),
    mod_friend_server:relative_modify(Teacher, RoleID, 1, 1),
    NewTeacherInfo = do_graduate2(TeacherInfo,NewInfo,State),
    put_(RoleID, NewInfo),
    put_(Teacher, NewTeacherInfo),
    updata_educate_role_info([NewInfo,NewTeacherInfo]),
    %% 成就 add by caochuncheng 2011-03-08
    common_hook_achievement:hook({mgeew_educate_server,{graduate,RoleID,NewLevel,NewInfo,NewTeacherInfo}}).


do_graduate2(#r_educate_role_info{roleid=TeacherRoleID,name=TeacherName,
                                  student_num=Num,moral_values=Moral}=TeacherInfo,
             #r_educate_role_info{roleid=StudentRoleID,name=StudentName},
             _State) ->
   Match = #r_friend{roleid=TeacherRoleID,friendid=StudentRoleID,_='_'},
    NewTeacherInfo =
        case db:dirty_match_object(?DB_FRIEND,Match) of
            [Info] when Info#r_friend.friendly > 29 ->
                TeacherInfo#r_educate_role_info{
                   student_num=Num-1,
                   moral_values=Moral+Info#r_friend.friendly};
            _ ->
                TeacherInfo#r_educate_role_info{student_num=Num-1}
        end,
    ?DEBUG("TeacherInfo：~w~n",[NewTeacherInfo]),
    TeacherText = lists:concat([?QIN_AI_DE,binary_to_list(TeacherName),"]:\n      ",?GONGXI_T,binary_to_list(StudentName),?T_TEXT]),
    StudentText=  lists:concat([?QIN_AI_DE,binary_to_list(StudentName),"]:\n      ",?GONGXI_S,?S_TEXT]),
    CItem1 = #r_item_create_info{role_id=TeacherRoleID,num=1,typeid=?TEACHER_GIFT,bind=true,bag_id=1,bagposition=1},
    CItem2 = #r_item_create_info{role_id=StudentRoleID,num=1,typeid=?STUDENT_GIFT,bind=true,bag_id=1,bagposition=1},
    {ok,[TGoods]} = common_bag2:create_item(CItem1),
    {ok,[SGoods]} = common_bag2:create_item(CItem2),
    ?INFO_MSG("DFDFSDSAFDFF ~w ~w ~n",[TGoods,SGoods]),
    common_letter:sys2p(TeacherRoleID,TeacherText,"师徒管理员-李梦阳给你的信",[TGoods#p_goods{id=1}],14),
    common_letter:sys2p(StudentRoleID,StudentText,"师徒管理员-李梦阳给你的信",[SGoods#p_goods{id=1}],14),
    NewTeacherInfo.

%%获取开除徒弟需要的师德值
do_get_expel_moral_value(Msg) ->
    [{Rate,Value}]=common_config_dyn:find(educate,expel_moral_rate),
    #m_educate_get_expel_moral_value_tos{roleid = StudentID}=Msg#r_msg.data,
    [Info] = get_(Msg#r_msg.roleid),
    Data = 
        case lists:member(StudentID,Info#r_educate_role_info.students) of
            true ->
                Now = common_tool:now(),
                [StudentInfo] = get_(StudentID),
                #r_educate_role_info{name=Name,
                                     level=Level,
                                     apprentice_level=ALevel,
                                     online = Online
                                    }=StudentInfo,
                RValue = case Online of
                             true -> calc_value(ALevel,Level,Rate,Value,Now,Now);
                             false -> 
                                 {ok, #p_role_ext{last_offline_time=OffLineTime}}= 
                                     common_misc:get_dirty_role_ext(StudentID),
                                 calc_value(ALevel,Level,Rate,Value,Now,OffLineTime)
                         end,
                #m_educate_get_expel_moral_value_toc{succ = true,
                                                     roleid=StudentID,
                                                     name=Name,
                                                     value=RValue};
            false ->
                case get_(StudentID) of
                    [] ->
                        #m_educate_get_expel_moral_value_toc{succ = false,roleid=StudentID};
                    [#r_educate_role_info{name=Name}] ->
                        TocReason = lists:concat([common_tool:to_list(Name),?_LANG_EDUCATE_NOT_SELF_STUDENT]),
                        #m_educate_get_expel_moral_value_toc{succ = false,
                                                             roleid=StudentID,
                                                             reason=TocReason}
                end
        end,
    educate_unicast(Msg,Data).

%%离开师门需要扣去的师德值
 do_get_dropout_moral_value(Msg) ->
    Now = common_tool:now(),
    [#r_educate_role_info{level = Level,apprentice_level = ALevel}] = get_(Msg#r_msg.roleid),
    [[{_TRate,_TValue},{SRate,SValue}]]=common_config_dyn:find(educate,dropout_moral_rate),
    RValue = calc_value(ALevel,Level,SRate,SValue,Now,Now),
    Data = #m_educate_get_dropout_moral_value_toc{succ=true,value = RValue},
    educate_unicast(Msg,Data).

%%===角色被杀call友=======
%% 是否国战   抢国王时间
do_call_educate_helper(RoleID, MapID, Pos)->
    case check_in_effective_map(MapID) of
        true->
            put({?EDUCATE_HELP_TIME_AND_DEAD_POS,RoleID},{undefined, {MapID, Pos}}),
            case get_(RoleID) of
                [] ->
                    ignore;
                [Info] ->                    
                    do_call_educate_helper2(RoleID, Info)
            end;
        false->
            ignore
    end.

%% 筛选角色发送信息
do_call_educate_helper2(RoleID,Info)->
    TeacherID = Info#r_educate_role_info.teacher,
    case is_integer(TeacherID) of
        true->
            case catch check_is_able_to_send(TeacherID,RoleID) of 
                ok ->
                    Msg4Teacher = create_help_msg(forteacher,RoleID),
                    R4Teacher = #m_educate_call_helper_toc{message=Msg4Teacher,role_id=RoleID},
                    educate_unicast(TeacherID,?EDUCATE_CALL_HELPER,R4Teacher),
                    set_educate_help_time(TeacherID);
                {error,_Reason1} ->
                    ?ERROR_MSG("_Reason1:~w~n",[_Reason1]),
                    ignore 
            end;
        false->
            ignore
    end,

    StudentsIDList =Info#r_educate_role_info.students,
    StudentsIDList1 = 
        lists:foldl(fun(StudentID,Acc)-> 
                            case catch check_is_able_to_send(StudentID,RoleID) of 
                                ok ->
                                    set_educate_help_time(StudentID),
                                    [StudentID|Acc];
                                {error,_Reason2} ->
                                    ?ERROR_MSG("_Reason2:~w~n",[_Reason2]),
                                    Acc
                            end
                    end,[],StudentsIDList),
    Msg4Students = create_help_msg(forstudent,RoleID),
    R4Students =#m_educate_call_helper_toc{message=Msg4Students,role_id=RoleID},
    common_misc:broadcast_to_line(StudentsIDList1,?EDUCATE,?EDUCATE_CALL_HELPER,R4Students).

%% 检查是否有效地图
check_in_effective_map(MapID)->
(MapID>=10200 andalso MapID<10300) orelse (MapID>=11000 andalso MapID<14000).

%% ok:可以传送，throw 不行
check_is_able_to_send(HelperID,DeadID)->
    %%检查是否在线
    case common_misc:is_role_online(HelperID) of
        true->
            next;
        false->
            throw({error,role_offline})
    end,
    case common_misc:is_role_online(DeadID) of
        true->
            next;
        false->
            throw({error,role_offline})
    end,
    %%是否拒绝时间
    case  check_is_in_refuse_time(HelperID) of
        true->
            throw({error,in_refuse_time});
        false->
            next
    end,
    %% 找不到就throw
    {ok,RA} = common_misc:get_dirty_role_pos(HelperID),
    %% 用死亡位置不用当前位置
    {ok, {MapIDB, _RB}} = get_dead_pos(DeadID),
    %%是否是有效地图
    MapIDA = RA#p_role_pos.map_id,
    case check_in_effective_map(MapIDA) of
        true->
            next;
        false ->
            throw({error,in_illegal_map})
    end,

    {ok,HelperAttr} = common_misc:get_dirty_role_attr(HelperID),
    Level = HelperAttr#p_role_attr.level,
    {ok,HelperBase} = common_misc:get_dirty_role_base(HelperID),
    FactionID = HelperBase#p_role_base.faction_id,
    %%检查是否在本国
    case common_misc:if_in_self_country(FactionID, MapIDB) of
        true->
            next;
        false->
            throw({error,in_foreign_map})
    end,
    %% 检查地图等级
    case common_config_dyn:find(map_level_limit, MapIDB) of
        [] ->
            erlang:throw({error,could_not_get_map});
        [LevelLimit] ->
            case LevelLimit > Level of
                true ->
                    throw({error,level_too_low});
                false ->
                    next
            end
    end,
    ok.


%% 是否在拒绝时限内
check_is_in_refuse_time(RoleID)->
    case get({?EDUCATE_HELP_TIME_AND_DEAD_POS,RoleID}) of
        undefined ->
            false;
        {LastHandleTime,_}->
            is_integer(LastHandleTime) 
                andalso (LastHandleTime+?IGNORE_LAST_TIME>common_tool:now())
    end.

%% 获取死亡位置
get_dead_pos(RoleID)->
    case get({?EDUCATE_HELP_TIME_AND_DEAD_POS,RoleID}) of
        undefined ->
            {error,no_dead_pos_maybe_offline};
        {_, {MapID, Pos}}->
            if is_record(Pos,p_pos)->
                   {ok, {MapID, Pos}};
               true->
                   {error,no_dead_pos}
            end
    end.

set_educate_help_time(RoleID)->
    Pos1 = case get({?EDUCATE_HELP_TIME_AND_DEAD_POS,RoleID}) of
        undefined->
            undefined;
        {_,Pos}->
            Pos
        end,
    put({?EDUCATE_HELP_TIME_AND_DEAD_POS,RoleID},{common_tool:now(),Pos1}).

create_help_msg(Type,RoleID)->
    Name = common_misc:get_dirty_rolename(RoleID),
    case Type of
        forteacher->
            lists:flatten(io_lib:format(?EDUCATE_CALL_HELP_MESSEGE, ["徒弟", Name]));
        forstudent->
            lists:flatten(io_lib:format(?EDUCATE_CALL_HELP_MESSEGE, ["师父", Name]))
    end.

%% =======同意传送===========
do_help_educate_role(Msg)-> 
    #m_educate_agree_help_tos{role_id=DeadID}=Msg#r_msg.data,
    HelperID=Msg#r_msg.roleid,
    %%是否符合传送状态
    case catch check_can_transfer(HelperID,DeadID) of
        {ok,Pos}->
            MapID = Pos#p_role_pos.map_id,
            #p_pos{tx=TX, ty=TY} = Pos#p_role_pos.pos,
            R = #m_map_change_map_toc{mapid=MapID, tx=TX, ty=TY},
            common_misc:send_to_rolemap(HelperID,{mod_map_role,{educate_dead_call_help,HelperID,R}});
        {error,Reason}->
            {Again,HelpMsg1} = 
                case check_relation(HelperID, DeadID) of
                    {?RELATION_SF,HelperID,DeadID} ->
                        HelpMsg = create_help_msg(forteacher,DeadID),
                        {true,HelpMsg};
                    {?RELATION_TD,HelperID,DeadID} ->
                        HelpMsg = create_help_msg(forstudent,DeadID),
                        {true,HelpMsg};
                    {?RELATION_SF,DeadID,HelperID} ->
                        HelpMsg = create_help_msg(forstudent,DeadID),
                        {true,HelpMsg};
                    {?RELATION_TD,DeadID,HelperID} ->
                        HelpMsg = create_help_msg(forteacher,DeadID),
                        {true,HelpMsg};
                    _ ->
                        {false,"不是师徒关系"}
                end,
            R = #m_educate_agree_help_toc{again = Again,
                                          message = HelpMsg1,
                                          role_id = DeadID,
                                          reason = Reason},
            educate_unicast(Msg,R);
        {cancel,Reason}->
            R = #m_educate_agree_help_toc{again = false,reason = Reason},
            educate_unicast(Msg,R)
    end.

%% 传送时检查传送者的合法性 ，（可能玩家会等了一分钟才确定传送）
%% result==ok:合法  cancel:取消 error:失败重传
check_can_transfer(HelperID,DeadID)->
    %%检查dead是否在线，下线会清除进程中数据
    case common_misc:is_role_online(DeadID) of
        true->
            next;
        false->
            throw({cancel,"对方已经下线"})
    end, 
    %%检查地理位置
    {ResultPosA,RA} = common_misc:get_dirty_role_pos(HelperID),
    case ResultPosA of
        ok->next;
        error -> throw({cancel,"无法获取你的位置信息"})
    end,
    {ResultPosB,RB} = get_dead_pos(DeadID),
    case ResultPosB of
        ok->next;
        error -> throw({cancel,"无法获取TA的位置信息"})
    end,
    MapIDA = RA#p_role_pos.map_id,
    %%检查helper是否在有效地图
    case check_in_effective_map(MapIDA) of
        true->
            next;
        false ->
            throw({cancel,"您所在的位置不能传送"})
    end,
    %% ==检查helper状态==
    %% 摆摊中，传送失败
    case common_misc:is_role_self_stalling(HelperID) of
        true ->
            throw({error,"摆摊中，传送失败"});
        false ->
            next
    end,
    %% 你已死亡，传送失败
    %% 训练中，传送失败
    {ResultHelperBase,HelperBase} = common_misc:get_dirty_role_base(HelperID),
    case ResultHelperBase of
        ok->next;
        error->throw({cancel,"系统错误"})
    end,
    #p_role_base{status =HelperStatus}=HelperBase,
    case HelperStatus of
        ?ROLE_STATE_DEAD->
            throw({error,"你已死亡，传送失败"});
        ?ROLE_STATE_TRAINING->
            throw({error,"训练中，传送失败"});
        _->
            next
    end,
    {ok,RB}.

%%--------------------------------------------------------------------------------------------------
educate_unicast(Msg,R)->
    #r_msg{line=Line,
           roleid=RoleID,
           unique=Unique,
           module=Module,
           method=Method}=Msg,
    common_misc:unicast(Line,RoleID,Unique,Module,Method, R).

educate_unicast(Msg,Method,R)when is_record(Msg,r_msg)->
    #r_msg{line=Line,
           roleid=RoleID}=Msg,
    common_misc:unicast(Line,RoleID,?DEFAULT_UNIQUE,?EDUCATE,Method, R);
educate_unicast(RoleID,Method,R) ->
    common_misc:unicast({role,RoleID},?DEFAULT_UNIQUE,?EDUCATE,Method,R).

%%-----------------------------------------------------------------------------
%%@doc 角色初始化,将表中的数据put到dict,将5代关系的角色也put到dict
%%返回 {[{RoleID,#r_educate_role_info},...],[BadRoleID,...]}
load([_|_]=RoleIDs) ->
    load(RoleIDs,{[],[]});
load(RoleID) ->
    load([RoleID]).
load([], Acc) ->
    Acc;
load([RoleID|T], {Acc1,Acc2}) ->
    case catch db:dirty_read(?DB_ROLE_EDUCATE, RoleID) of
        [#r_educate_role_info{teacher=MyTeacher,students=MyStudents}=Info] ->
            put_(RoleID, Info#r_educate_role_info{online=true}),
            load5relation(?RELATION_SF, RoleID, MyTeacher),
            load5relation(?RELATION_TD, RoleID, MyStudents),
            load(T, {[{RoleID,Info#r_educate_role_info{online=true}}|Acc1],Acc2});
        _ ->
            load(T, {Acc1, [RoleID|Acc2]})
    end.

load5relation(?RELATION_SF, SelfRoleID, RoleID) ->
    Info = 
        case get_(RoleID) of
            [] ->      
                case catch db:dirty_read(?DB_ROLE_EDUCATE, RoleID) of
                    [TmpInfo]->
                        TmpInfo#r_educate_role_info{online=false};
                    _ ->
                        undefined
                end;
            [TmpInfo] ->
                TmpInfo
        end,
    case Info of 
        undefined ->
            ignroe;
        #r_educate_role_info{teacher=MyTeacher,students=MyStudents}=Info ->
            put_(RoleID,Info),
            load5relation(?RELATION_SG,SelfRoleID,MyTeacher),
            load5relation(?RELATION_XD,SelfRoleID,lists:delete(SelfRoleID,MyStudents))
    end;
load5relation(?RELATION_SG, _SelfRoleID, RoleID) ->
    case get_(RoleID) of
        [] ->
            case catch db:dirty_read(?DB_ROLE_EDUCATE, RoleID) of
                [Info]->
                    put_(RoleID,Info#r_educate_role_info{online=false});
                _ ->
                    ignore
            end;
        [_] ->
            ignore
    end;
load5relation(?RELATION_XD, _SelfRoleID, [_|_]=RoleIDs) ->
    lists:foreach(fun(RoleID) ->
                          case get_(RoleID) of
                              [] ->
                                  case catch db:dirty_read(?DB_ROLE_EDUCATE, RoleID) of
                                      [Info]->
                                          put_(RoleID,Info#r_educate_role_info{online=false});
                                      _ ->
                                          ignore
                                  end;
                              [_] ->
                                  ignore
                          end
                  end,RoleIDs);
load5relation(?RELATION_XD, _SelfRoleID, _) ->
    ignore;
load5relation(?RELATION_TD, SelfRoleID, [_|_]=RoleIDs) ->
    lists:foreach(fun(RoleID) ->
                          Info = 
                              case get_(RoleID) of
                                  [] ->
                                      case catch db:dirty_read(?DB_ROLE_EDUCATE, RoleID) of
                                          [TmpInfo] ->
                                              TmpInfo#r_educate_role_info{online=false};
                                          _ ->
                                              undefined
                                      end;
                                  [TmpInfo] ->
                                      TmpInfo
                              end,
                          case Info of
                              undefined ->
                                  ignore;
                              #r_educate_role_info{students=MyStudents}=Info ->
                                  put_(RoleID,Info),
                                  load5relation(?RELATION_TS, SelfRoleID, MyStudents)
                          end
                  end,RoleIDs);
load5relation(?RELATION_TD, _SelfRoleID, _) ->
    ignore;
load5relation(?RELATION_TS, _SelfRoleID, [_|_]=RoleIDs) ->
    lists:foreach(fun(RoleID) ->
                          case get_(RoleID) of
                              [] ->
                                  case catch db:dirty_read(?DB_ROLE_EDUCATE, RoleID) of
                                      [Info]->
                                          put_(RoleID,Info#r_educate_role_info{online=false});
                                      _ ->
                                          ignore
                                  end;
                              [_] ->
                                  ignore
                          end
                  end,RoleIDs);
load5relation(?RELATION_TS, _SelfRoleID, _) ->
    ignore.

%%@doc 将改变过的角色信息持久化到表中
%%返回 ok
persistence() ->
    lists:foreach(fun(Info) ->
                          db:dirty_write(?DB_ROLE_EDUCATE,Info)
                  end,get_s(pop_c_l())).

%%@doc 将退出游戏的角色信息持久到表中
%%返回void
quit(RoleID) ->
    case lists:foldl(
           fun(#r_educate_role_info{online=true}=Info, Acc) ->
                   [Info|Acc];
              (_Info, Acc) ->
                   Acc
           end,[],get5relation(RoleID))
    of
        [] ->
            case pop_(RoleID) of
                [] ->
                    ignore;
                [Info] ->
                    rm_reco(RoleID, Info#r_educate_role_info.faction_id),
                    db:dirty_write(?DB_ROLE_EDUCATE,Info#r_educate_role_info{online=false})
            end;
        _ ->
            ignore
    end.

%%@doc 把存储结构转换成客服端接口
%%返回 
convert2toc(undefined,_) -> undefined;
convert2toc(Info,Relation)when is_record(Info,r_educate_role_info) ->
    ReleaseInfo = Info#r_educate_role_info.release_info,
    #p_educate_role_info{roleid = Info#r_educate_role_info.roleid,
                         level = Info#r_educate_role_info.level,
                         sex = Info#r_educate_role_info.sex,
                         title = Info#r_educate_role_info.title,
                         name = Info#r_educate_role_info.name,
                         exp_gifts1 = Info#r_educate_role_info.exp_gifts1,
                         exp_grfts2 = Info#r_educate_role_info.exp_gifts2,
                         exp_devote1 = Info#r_educate_role_info.exp_devote1,
                         exp_devote2 = Info#r_educate_role_info.exp_devote2,
                         moral_values = Info#r_educate_role_info.moral_values,
                         student_num = Info#r_educate_role_info.student_num,
                         student_max_num = Info#r_educate_role_info.max_student_num,
                         teacher = Info#r_educate_role_info.teacher,
                         teacher_name = Info#r_educate_role_info.teacher_name,
                         online = Info#r_educate_role_info.online,
                         apprentice_level = Info#r_educate_role_info.apprentice_level,
                         rel_admissions = if ReleaseInfo =/= undefined -> ReleaseInfo#r_release_info.rel_admissions;true -> false end,
                         rel_adm_msg = if ReleaseInfo =/= undefined -> ReleaseInfo#r_release_info.rel_adm_msg;true -> "" end,
                         rel_adm_time = if ReleaseInfo =/= undefined -> ReleaseInfo#r_release_info.rel_adm_time;true -> 0 end,
                         rel_apprentice = if ReleaseInfo =/= undefined -> ReleaseInfo#r_release_info.rel_apprentice;true -> false end,
                         rel_app_msg = if ReleaseInfo =/= undefined -> ReleaseInfo#r_release_info.rel_app_msg;true -> "" end,
                         rel_app_time = if ReleaseInfo =/= undefined -> ReleaseInfo#r_release_info.rel_app_time;true -> 0 end,
                         relation = Relation
                        }.

%%@doc 从dict中获取RoleID的5代关系的角色id
%%返回 RoliIDs
get5all(RoleID) ->
    [Info#r_educate_role_info.roleid || {_,Info} <- get5relation(RoleID)].

%%@doc 从dict中获取RoleID的5代关系的角色信息
%%返回 [{Relation,Info},...]
get5relation(RoleID) ->
    case get_(RoleID) of
        [] ->
            [];
        [#r_educate_role_info{teacher=MyTeacher,students=MyStudents}] ->
            Acc = get_relation(?RELATION_SF, RoleID, MyTeacher, []),
            get_relation(?RELATION_TD, RoleID, MyStudents, Acc)
    end.

%%@doc 从dict中获取RoleID的上3代关系（师公，师傅，同门）的角色信息
%%返回 [{Relation,Info},...]
get_clan(RoleID) ->
    case get_(RoleID) of
        [] ->
            [];
        [#r_educate_role_info{teacher=MyTeacher}] ->
            get_relation(?RELATION_SF, RoleID, MyTeacher, [])
    end.

%%@doc 从dict中获取RoleID的下2代关系(徒弟，徒孙）的角色信息
%%返回 [{Relation,Info},...]
get_posterity(RoleID) ->
    case get_(RoleID) of
        [] ->
            [];
        [#r_educate_role_info{students=MyStudents}] ->
            get_relation(?RELATION_TD, RoleID, MyStudents, [])
    end.

%%@doc 从dict中获取RoleID1的5代关系，判断与RoleID2的关系
%%返回 {Relation,RoleID2,RoleID1}|undefined
check_relation(RoleID1,RoleID2) ->
    catch lists:foldl(
            fun({Relation,Info}, Acc) ->
                    if Info#r_educate_role_info.roleid =:= RoleID2 ->
                            throw({Relation,RoleID2,RoleID1});
                       true ->
                            Acc
                    end
            end, undefined, get5relation(RoleID1)).

%%@doc 从dict中获取与SelfRoleID有Relation的RoleID的信息以及衍生的关系
%%参数，Relation关系宏，SelfRoleID，RoleID, Acc搜集的关系
%%返回 [{Relation,Info},...]
get_relation(?RELATION_SF, SelfRoleID, RoleID, Acc) ->
    case get_(RoleID) of
        [#r_educate_role_info{teacher=MyTeacher,students=MyStudents}=Info]->
            Acc1 = get_relation(?RELATION_SG,SelfRoleID,MyTeacher,Acc),
            get_relation(?RELATION_XD,SelfRoleID,lists:delete(SelfRoleID,MyStudents),[{?RELATION_SF,Info}|Acc1]);
        _ ->
            Acc
    end;
get_relation(?RELATION_SG, _SelfRoleID, RoleID, Acc) ->
    case get_(RoleID) of
        [Info]->
            [{?RELATION_SG,Info}|Acc];
        _ ->
            Acc
    end;
get_relation(?RELATION_XD, _SelfRoleID, [_|_]=RoleIDs, Acc) ->
    lists:foldl(fun(Info,TmAcc) ->
                        [{?RELATION_XD,Info}|TmAcc]
                end,Acc,get_s(RoleIDs));
get_relation(?RELATION_XD, _SelfRoleID, _, Acc) ->
    Acc;
get_relation(?RELATION_TD, SelfRoleID, [_|_]=RoleIDs, Acc) ->
    lists:foldl(fun(RoleID,TmAcc) ->
                        case get_(RoleID) of
                            [#r_educate_role_info{students=MyStudents}=Info] ->
                                [{?RELATION_TD,Info}|
                                 get_relation(?RELATION_TS, SelfRoleID, MyStudents, TmAcc)];
                            _ ->
                                TmAcc
                        end
                end,Acc,RoleIDs);
get_relation(?RELATION_TD, _SelfRoleID, _, Acc) ->
    Acc;
get_relation(?RELATION_TS, _SelfRoleID, [_|_]=RoleIDs, Acc) ->
    lists:foldl(fun(Info,TmAcc) ->
                        [{?RELATION_TS,Info}|TmAcc]
                end,Acc,get_s(RoleIDs));
get_relation(?RELATION_TS, _SelfRoleID, _, Acc) ->
    Acc.

%%@doc dict Operation
get_s([]) ->
    [];
get_s([_|_] = RoleIDs) ->
    [begin [Info]=R,Info end || R <- [get_(RoleID) || RoleID <- RoleIDs], R =/= []].

get_(RoleID) ->
    case get(?ref(RoleID)) of
        undefined ->
            [];
        Info ->
            [Info]
    end.

put_(RoleID,Info) -> 
    up_c_l(RoleID),
    up_reco_stus(Info),
    up_reco_tcrs(Info),
    put(?ref(RoleID),Info).

pop_(RoleID) ->
    case erase(?ref(RoleID)) of
        undefined ->
            [];
        Info ->
            [Info]
    end.

up_c_l(RoleID) ->
    case get(?change_list) of
        undefined ->
            put(?change_list,[RoleID]);
        Changes ->
            put(?change_list,[RoleID|lists:delete(RoleID,Changes)])
    end.

pop_c_l() ->
    case erase(?change_list) of
        undefined ->
            [];
        Changes ->
            Changes
    end.

up_reco_stus(#r_educate_role_info{roleid=RoleID,
                                  faction_id=FactionID,
                                  level=Level,
                                  teacher=Teacher,
                                  online=Online,
                                  release_info= RelInfo}) ->
    [EducateLevelConfig]=common_config_dyn:find(educate,educate_level),
    {min_student,MinStudentLevel} = proplists:lookup(min_student,EducateLevelConfig),
    {max_student,MaxStudentLevel} = proplists:lookup(max_student,EducateLevelConfig),
    case 
        Level > MinStudentLevel-1 andalso 
        Level < MaxStudentLevel andalso 
        Teacher =:= undefined andalso 
        Online =:= true andalso
        is_record(RelInfo, r_release_info) andalso
        RelInfo#r_release_info.rel_apprentice =:= true
    of
        true ->
            put(?ref_reco_stus(FactionID),[{Level,RoleID}|lists:keydelete(RoleID,2,get_reco_stus(FactionID))]);
        false ->
            put(?ref_reco_stus(FactionID),lists:keydelete(RoleID,2,get_reco_stus(FactionID)))
    end;
up_reco_stus(_) ->
    ignore.

get_reco_stus(FactionID) ->
    case get(?ref_reco_stus(FactionID)) of
        undefined ->
            [];
        Stus ->
            Stus
    end.
    
up_reco_tcrs(#r_educate_role_info{roleid=RoleID,
                                  faction_id=FactionID,
                                  level=Level,
                                  student_num=StuNum,
                                  max_student_num=MaxStuNum,
                                  online=Online,
                                  release_info=RelInfo}) ->
    [EducateLevelConfig]=common_config_dyn:find(educate,educate_level),
    {teacher,TeacherLevel} = proplists:lookup(teacher,EducateLevelConfig),
    case 
        Level > TeacherLevel-1 andalso
        (MaxStuNum == 0 orelse MaxStuNum > StuNum) andalso
        Online =:= true andalso
        is_record(RelInfo, r_release_info) andalso
        RelInfo#r_release_info.rel_admissions =:= true
    of
        true ->
            put(?ref_reco_tcrs(FactionID),[{Level,RoleID}|lists:keydelete(RoleID,2,get_reco_tcrs(FactionID))]);
        false ->
            put(?ref_reco_tcrs(FactionID),lists:keydelete(RoleID,2,get_reco_tcrs(FactionID)))
    end;
up_reco_tcrs(_) ->
    ignore.

get_reco_tcrs(FactionID) ->
    case get(?ref_reco_tcrs(FactionID)) of
        undefined ->
            [];
        Tcrs ->
            Tcrs
    end.

rm_reco(RoleID, FactionID) ->
    put(?ref_reco_tcrs(FactionID),lists:keydelete(RoleID,2,get_reco_tcrs(FactionID))),
    put(?ref_reco_stus(FactionID),lists:keydelete(RoleID,2,get_reco_stus(FactionID))).
        
get_invite({R1, R2}) ->
    Ref = common_tool:to_list(R1)++"#"++common_tool:to_list(R2),
    get_invite(Ref);
get_invite(Ref) ->
    case get(?invite_list) of
        undefined ->
            [];
        IL ->
            proplists:get_value(Ref,IL, [])
    end.

put_invite(R1, R2) ->
    Ref = common_tool:to_list(R1)++"#"++common_tool:to_list(R2),
    Data = {Ref,[{R1,R2,common_tool:now()}]},
    case get(?invite_list) of
        undefined ->
            put(?invite_list,[Data]);
        IL ->
            put(?invite_list,[Data|lists:keydelete(Ref,1,IL)])
    end,
    Ref.

pop_invite({R1, R2}) ->
    Ref = common_tool:to_list(R1)++"#"++common_tool:to_list(R2),
    pop_invite(Ref);
pop_invite(Ref) ->
    case get(?invite_list) of
        undefined ->
            [];
        IL ->
            case lists:keytake(Ref,1,IL) of 
                false ->[];
                {value,{_,V}, NIL} ->
                    put(?invite_list, NIL),
                    V
            end
    end.

del_timeout_invite() ->
    case get(?invite_list) of
        undefined ->
            [];
        IL ->
            Now = common_tool:now(),
            put(?invite_list, 
                lists:foldl(
                  fun({_,[{_,_,TM}]}=R,Acc) ->
                          if TM+?INVITE_TIMEOUT < Now ->
                                  Acc;
                             true ->
                                  [R|Acc]
                          end
                  end,[],IL))
    end.

up_invite_ck_ct() ->
    case get(?invite_check_count) of
        undefined -> put(?invite_check_count,1),0;
        Old -> put(?invite_check_count,1+Old),Old
    end.

rm_invite_ck_ct() ->
    case erase(?invite_check_count) of
        undefined -> 0;
        Old -> Old
    end.
                                        
calc_value(ALevel,Level,Rate,Value,Now,OffLineTime) ->
    Sum = lists:foldl(fun(L,S) -> round(S+L*L/16) end,0,lists:seq(ALevel+1,Level)),
    Ra = 
        case round((Now-OffLineTime) / 86400) of
            R when R < 1 ->
                1;
            R ->
                1/(R+1)
        end,
    round((Sum*Rate+Value)*Ra).
