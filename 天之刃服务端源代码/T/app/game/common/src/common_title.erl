%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     称号的公共方法
%%% @end
%%% Created : 2011-07-20
%%%-------------------------------------------------------------------
-module(common_title).

-include("common.hrl").
-include("common_server.hrl").
-include("office.hrl").


%% API OF TITLES
-export([
         add_title/3,
         remove_by_typeid/2,
         remove_by_titleid/2,
         get_role_sence_titles/1,
         get_role_chat_titles/1,
         send_sence_titles/1,
         get_king_name/1,
         get_default_title/0
        ]).


%% API OF TITLES
-export([
        get_title_name_of_rank/2,
        get_title_name_of_rank/3]).

%%当前可用的ID和申请到的最大的ID
-define(CURENT_NEW_TITLE_ID_INFO,current_new_title_id_info).



%%添加某个单位的称号
add_title(TitleType, DestID, Info) ->
    case TitleType of
        ?TITLE_EMPEROR ->
            set_emperor(DestID);
        ?TITLE_KING ->
            set_king(DestID,Info);
        ?TITLE_WORLD_PKPOINT_RANK ->
            set_world_pkpoint_rank_title(DestID,Info);
        ?TITLE_ROLE_LEVEL_RANK ->
            set_role_level_rank_title(DestID,Info);
        ?TITLE_ROLE_GONGXUN_RANK ->
            set_role_gongxun_rank_title(DestID,Info);
        ?TITLE_EDUCATE ->
            set_educate_title(DestID,Info);
        ?TITLE_OFFICE_MINISTER ->
            set_office_minister(DestID,Info);
        ?TITLE_OFFICE_JINYIWEI ->
            set_office_jinyiwei(DestID,Info);
        ?TITLE_OFFICE_GENERAL ->
            set_office_general(DestID,Info);
        ?TITLE_FAMILY ->
            set_family_title(DestID,Info);
        ?TITLE_VIP ->
            set_vip_title(DestID, Info);
        ?TITLE_MANUAL ->
            set_role_manual_title(DestID,Info);
        ?TITLE_ROLE_GIVE_FLOWERS ->
            set_role_give_flowers(DestID,Info);
        ?TITLE_ROLE_GIVE_FLOWERS_YESTERDAY ->
            set_role_give_flowers_yesterday(DestID,Info);
        ?TITLE_ROLE_RECE_FLOWERS ->
            set_role_rece_flowers(DestID,Info);
        ?TITLE_ROLE_RECE_FLOWERS_YESTERDAY ->
            set_role_rece_flowers_yesterday(DestID,Info);
        ?TITLE_ROLE_ACHIEVEMENT	->
            set_role_achievement_title(DestID,Info);
        ?TITLE_ROLE_HERO_FB ->
            set_role_hero_fb_title(DestID,Info);
        ?TITLE_STUDENT ->
            set_student_title(DestID, Info);
        _ ->
            ignore
    end.


send_sence_titles(RoleID) ->
    Titles = common_title:get_role_sence_titles(RoleID),
    Data = #m_title_get_role_titles_toc{titles=Titles},
    common_misc:unicast({role, RoleID}, ?DEFAULT_UNIQUE, ?TITLE, ?TITLE_GET_ROLE_TITLES, Data).


%%根据称类型移除某个单位的称号
remove_by_typeid(TitleType, DestID) ->
    case db:dirty_match_object(?DB_NORMAL_TITLE,#p_title{type=TitleType,role_id=DestID,_='_'}) of
        [] ->
            case db:dirty_match_object(?DB_SPEC_TITLE,#p_title{type=TitleType,role_id=DestID,_='_'})of
                [] ->
                    {fail,not_exist};
                [R] ->
                    db:dirty_delete_object(?DB_SPEC_TITLE,R),
                    common_hook_title:delete(DestID,R#p_title.name),
                    ok
            end;
        [R]  ->
            db:dirty_delete_object(?DB_NORMAL_TITLE,R),
            common_hook_title:delete(DestID,R#p_title.name),
            ok
    end.

%%根据称号ID删除称号，目前只用于后台的自定义称号
remove_by_titleid(TitleID,DestID) ->
     case db:dirty_read(?DB_NORMAL_TITLE,TitleID) of
         [] ->
             {fail,not_exist};
         [R] ->
              db:dirty_delete(?DB_NORMAL_TITLE,TitleID),
              common_hook_title:delete(DestID,R#p_title.name),
              ok
     end.


%%获取玩家的所有称号信息, 返回 p_title的list
get_role_sence_titles(RoleID) ->
    NormalTiles = db:dirty_match_object(?DB_NORMAL_TITLE, #p_title{role_id=RoleID,show_in_sence=true,_='_'}),
    SpecTitles = get_spec_sence_titles(RoleID),
	%% 默认称号
	{DefaultTitleName,DefaultTitleColor} = get_default_title(),
	DefaultTitle = #p_title{id=0, name=DefaultTitleName, type=0, auto_timeout=false, role_id=RoleID, 
							show_in_chat=false, show_in_sence=true, color=DefaultTitleColor},
	%% 签名称号
	{ok, RoleExt} = common_misc:get_dirty_role_ext(RoleID),
	if RoleExt#p_role_ext.signature =:= undefined orelse RoleExt#p_role_ext.signature =:= "" ->
		   SignatureTitle = [];
	   true ->
		   Signature = common_tool:sublist_utf8(RoleExt#p_role_ext.signature, 1, 7),
		   [ForbidTitleList] = common_config_dyn:find(title, family_title_forbidden),
		   case lists:member(Signature, ForbidTitleList) of
			   true ->
				   SignatureTitle = [];
			   false ->
				   SignatureTitle = [#p_title{id=-1, name=Signature, type=0, auto_timeout=false, role_id=RoleID,
											  show_in_chat=false, show_in_sence=true, color=get_signature_title_color()}]
		   end
	end,
	lists:append([[DefaultTitle],NormalTiles,SpecTitles,SignatureTitle]).

get_default_title() ->
    [{DefaultTitleName,DefaultTitleColor}] = common_config_dyn:find(title,default_title),
    {DefaultTitleName, DefaultTitleColor}.

get_signature_title_color() ->
    [Color] = common_config_dyn:find(title, signature_title_color),
    Color.

%%获取玩家的所有聊天称号，返回p_chat_title的list
get_role_chat_titles(RoleID) ->
    NormalTiles = case db:dirty_match_object(?DB_NORMAL_TITLE, #p_title{role_id=RoleID,show_in_chat=true,_='_'}) of
                      [] ->
                          [];
                      Titles ->
                          lists:foldl(
                            fun(Title, Acc) ->
                                    #p_title{id=ID, name=Name, color=Color, type=Type} = Title,
                                    case Type =:= ?TITLE_VIP of
                                        true ->
                                            [#p_chat_title{id=ID, name="VIP", color=Color} | Acc];
                                        false ->
                                            [#p_chat_title{id=ID, name=Name, color=Color} | Acc]
                                    end                                    
                            end, [], Titles)
                  end,
    SpecTitles = get_spec_chat_titles(RoleID),
    lists:append(NormalTiles,SpecTitles).



%%
%%==================LOCAL FUNCTION OF KING====================
%%
get_spec_sence_titles(RoleID) ->
    db:dirty_match_object(?DB_SPEC_TITLE, #p_title{role_id=RoleID,show_in_sence=true,_='_'}).


get_spec_chat_titles(RoleID) ->
    Titles = db:dirty_match_object(?DB_SPEC_TITLE, #p_title{role_id=RoleID,show_in_chat=true,_='_'}),
    lists:foldl(
      fun(Title, Acc) ->
              #p_title{id=ID, name=Name, color=Color} = Title,
              [#p_chat_title{id=ID, name=Name, color=Color} | Acc]
      end, [], Titles).


%%获取新的titleID，每次获取最新的1000个ID，存在进程字典
get_new_titleid() ->
	case get(?CURENT_NEW_TITLE_ID_INFO) of
		undefined ->
			CurrentID = 1,
			MaxID = 1;
		{CurrentID,MaxID} ->
			ignore
	end,
	case CurrentID >= MaxID of
		true ->
    Fun = fun() ->
                  case db:read(?DB_TITLE_COUNTER, 1, write) of
                      [] ->
                          Record = #r_title_counter{id = 1,last_title_id = 100000},
                          db:write(?DB_TITLE_COUNTER, Record, write),
								  101000;
                      [Record] ->
                          #r_title_counter{last_title_id = LastID} = Record,
								  NewRecord = Record#r_title_counter{last_title_id = LastID+1001},
                          db:write(?DB_TITLE_COUNTER, NewRecord, write),
								  LastID+1001
                  end
          end,
			{atomic,MaxID2} = db:transaction(Fun),
			CurrentID2 = MaxID2 - 1000;
		false ->
			CurrentID2 = CurrentID,
			MaxID2 = MaxID
	end,
	put(?CURENT_NEW_TITLE_ID_INFO,{CurrentID2+1,MaxID2}),
	CurrentID2.

delete_old_titles(TitleList, DBName, RankList) ->
    lists:foldr(
	  fun(Title, {DelList,ChangeList,NoChangeList}) ->
			  #p_title{role_id=RoleID, name=OldTitleName} = Title,
			  case lists:keyfind(RoleID, 1, RankList) of
                  false ->
					  db:dirty_delete_object(DBName, Title),
					  common_hook_title:change_role_cur_title(RoleID, undefined, undefined, undefined),
					  {[RoleID|DelList],ChangeList,NoChangeList};
				  {RoleID,NewTitleName} ->
					  case NewTitleName of
						  "" ->
							  db:dirty_delete_object(DBName, Title),
							  common_hook_title:change_role_cur_title(RoleID, undefined, undefined, undefined),
							  {[RoleID|DelList],ChangeList,NoChangeList};
                  _ ->
							  case NewTitleName =:= OldTitleName of
								  true ->
									  {DelList,ChangeList,[RoleID|NoChangeList]};
								  false ->
									  common_hook_title:change_role_cur_title(RoleID, undefined, undefined, undefined),
									  {DelList,[{RoleID,Title}|ChangeList],NoChangeList}
							  end
					  end
			  end
	  end,{[],[],[]},TitleList).

%%========================TILTE EMPEROR=======================
%%设置皇帝
set_emperor(RoleID) ->
    common_hook_title:change(RoleID),
    ok.


%%=========================TITLE KING=========================
    

%%直接使用FactionID为对应国家的国王称号的称号ID
get_king_titleid(FactionID) ->
    FactionID.


%%设置国王
set_king(RoleID, FactionID) ->
    TitleID = get_king_titleid(FactionID),
    case db:transaction(fun() -> t_do_set_king(RoleID, TitleID, get_king_name(FactionID)) end) of
        {atomic, Rtn} ->
            case Rtn of
                ok ->
                    ok;
                {ok, {OldRoleID,TitleName}}->
                    common_hook_title:delete(OldRoleID,TitleName)
            end,
            common_hook_title:change(RoleID),
            ok;
        {aborted, Error} ->
            {error, Error}
    end.


%%设置新的国王
t_do_set_king(RoleID, TitleID, TitleName) ->
    case db:dirty_match_object(?DB_SPEC_TITLE, #p_title{id=TitleID, _='_'}) of
        [] ->
            %%上一届没有对应的国王称号
            t_do_set_king2(RoleID, TitleID, TitleName),
            ok;
        [#p_title{role_id=OldRoleID} = TObject] ->
            case RoleID =:= OldRoleID of
                true ->
                    ok;
                false ->
                    %%取消上一次的国王的称号
                    db:delete_object(?DB_SPEC_TITLE, TObject, write),
                    t_do_set_king2(RoleID, TitleID, TitleName),
                    {ok,{OldRoleID,TitleName}}
            end
    end.


t_do_set_king2(RoleID, TitleID, TitleName) ->
    R = #p_title{id=TitleID, name=TitleName, type=?TITLE_KING, auto_timeout=false,
                 role_id=RoleID, show_in_chat=if_show_in_chat(TitleName), show_in_sence=true,color="ffff00"},
    db:write(?DB_SPEC_TITLE, R, write).
    

%%根据国家ID获取对应的国王的名称
get_king_name(FactionID) when is_integer(FactionID)->
    [KingNameList] = common_config_dyn:find(title,king_name),
    {_,KingName} = lists:keyfind(FactionID, 1, KingNameList),
    KingName.

    
%%=========================TITLE ROLE_LEVEL_RANK=========================




set_role_level_rank_title2(RoleID,TitleName,Color) ->
    case db:dirty_match_object(?DB_NORMAL_TITLE,#p_title{type=?TITLE_ROLE_LEVEL_RANK,role_id=RoleID,_='_'}) of
        [] ->
            OldTitleName = undefined,
            TitleID = get_new_titleid(),
            R = #p_title{id=TitleID, name=TitleName, type=?TITLE_ROLE_LEVEL_RANK, auto_timeout=false, 
                         role_id=RoleID, show_in_chat=if_show_in_chat(TitleName), show_in_sence=true,color=Color};
        [TitleInfo] ->
            ?DEBUG("~w",[TitleInfo]),
            OldTitleName = TitleInfo#p_title.name,
            TitleID = TitleInfo#p_title.id,
            R = TitleInfo#p_title{name = TitleName,color=Color,show_in_chat=if_show_in_chat(TitleName)};
        %% 暂时这样处理
        TitleInfoList when is_list(TitleInfoList)  ->
            lists:foreach(fun(TmpTitleInfo)->
                                  db:dirty_delete_object(?DB_NORMAL_TITLE,TmpTitleInfo)
                          end, TitleInfoList),
            OldTitleName = undefined,
            TitleID = get_new_titleid(),
            R = #p_title{id=TitleID, name=TitleName, type=?TITLE_ROLE_LEVEL_RANK, auto_timeout=false, 
                         role_id=RoleID, show_in_chat=if_show_in_chat(TitleName), show_in_sence=true,color=Color}
    end,
    db:dirty_write(?DB_NORMAL_TITLE, R),
    common_hook_title:change(RoleID),
    case OldTitleName of
        undefined ->
            nil;
        _ ->
            common_hook_title:exchange_title_name(RoleID,OldTitleName,TitleName,Color,TitleID)
    end.

get_role_level_rank_titlename_by_level(Level) ->
    [LevelTitleList] = common_config_dyn:find(title,{rank_type,?TITLE_ROLE_LEVEL}),
    lists:foldl(
      fun({MinLevel,MaxLevel,TitleName},Acc) ->
              case "" =:= Acc andalso  Level >= MinLevel andalso Level < MaxLevel of
                  true ->
                      TitleName;
                  _ ->
                      Acc
              end
      end, "", LevelTitleList).

%%=========================TITLE ROLE_GONGXUN_RANK=========================                               

%%%%%%%%%%% 更新排行榜的头衔      %%%%%%%%%%% 
-define(SET_RANK_TITLE(RankList,TitleType,RecordName),
		List = db:dirty_match_object(?DB_NORMAL_TITLE,#p_title{type=TitleType,_='_'}),
		RankList2 = lists:map(
            fun(RankInfo) ->
				#RecordName{role_id = RoleID,title=TitleName} = RankInfo,
				{RoleID,TitleName} 
			end, RankList),
		{_DelList,ChangeList,NoChangeList} = delete_old_titles(List,?DB_NORMAL_TITLE, RankList2),
        lists:foreach(
        fun({RoleID,NewTitleName}) ->
              case NewTitleName =:= "" orelse lists:member(RoleID, NoChangeList) =/= false of
                  true ->
                      ignore;
                  _ ->
                      Color = get_title_color(NewTitleName),
                      ShowChat = if_show_in_chat(NewTitleName),
					  case lists:keyfind(RoleID, 1, ChangeList) of
						  {RoleID,OldTitle} ->
                                db:dirty_write(?DB_NORMAL_TITLE, OldTitle#p_title{name=NewTitleName, show_in_chat=ShowChat, color=Color});
                          false ->
                      			TitleID = get_new_titleid(),
                      			R = #p_title{id=TitleID, name=NewTitleName, type=TitleType, auto_timeout=false, 
                                   	role_id=RoleID, show_in_chat=ShowChat, show_in_sence=true,color=Color},
                      			db:dirty_write(?DB_NORMAL_TITLE, R)
						end,
                      common_hook_title:change(RoleID)
              end
      end,RankList2)).


set_role_level_rank_title(RoleID,Level) when is_integer(Level) ->
    case Level < 30 of
        true ->
            case db:dirty_match_object(?DB_NORMAL_TITLE,#p_title{type=?TITLE_ROLE_LEVEL_RANK,role_id=RoleID,_='_'}) of
                [] ->
                    nil;
                [TitleInfo] ->
                    db:dirty_delete_object(?DB_NORMAL_TITLE,TitleInfo),
                    common_hook_title:delete(RoleID,TitleInfo#p_title.name);
                 TitleInfoList when is_list(TitleInfoList)  ->
                    lists:foreach(fun(TmpTitleInfo)->
                                  db:dirty_delete_object(?DB_NORMAL_TITLE,TmpTitleInfo)
                          end, TitleInfoList)
            end;
        false ->
            TitleName = get_role_level_rank_titlename_by_level(Level),
            Color = get_title_color(TitleName),
            set_role_level_rank_title2(RoleID,TitleName,Color)
    end;
set_role_level_rank_title(0,RankList) ->
    ?SET_RANK_TITLE(RankList,?TITLE_ROLE_LEVEL_RANK,p_role_level_rank).

set_world_pkpoint_rank_title(0,RankList) ->
    ?SET_RANK_TITLE(RankList,?TITLE_WORLD_PKPOINT_RANK,p_role_pkpoint_rank).
        
set_role_gongxun_rank_title(0,RankList) ->
    ?SET_RANK_TITLE(RankList,?TITLE_ROLE_GONGXUN_RANK,p_role_gongxun_rank).

set_role_give_flowers(0,RankList) ->
    ?SET_RANK_TITLE(RankList,?TITLE_ROLE_GIVE_FLOWERS,p_role_give_flowers_rank).

set_role_give_flowers_yesterday(0,RankList) ->
    ?SET_RANK_TITLE(RankList,?TITLE_ROLE_GIVE_FLOWERS_YESTERDAY,p_role_give_flowers_yesterday_rank).

set_role_rece_flowers(0,RankList) ->
    ?SET_RANK_TITLE(RankList,?TITLE_ROLE_RECE_FLOWERS,p_role_rece_flowers_rank).

set_role_rece_flowers_yesterday(0,RankList) ->
    ?SET_RANK_TITLE(RankList,?TITLE_ROLE_RECE_FLOWERS_YESTERDAY,p_role_rece_flowers_yesterday_rank).

%%=========================TITLE EDUCAT=========================
set_educate_title(RoleID,{TitleName,Color}) ->
    set_simple_role_title(RoleID,?TITLE_EDUCATE,TitleName,Color).

set_family_title(RoleID,TitleName) ->
    set_simple_role_title(RoleID,?TITLE_FAMILY,TitleName,"00ffff").

set_student_title(RoleID,{TitleName,TitleColor}) ->
    case db:dirty_match_object(?DB_NORMAL_TITLE,#p_title{type=?TITLE_STUDENT,role_id=RoleID,_='_'}) of
        [] ->
            OldTitleName = undefined,
            TitleID = get_new_titleid(),
            R = #p_title{id=TitleID, name=TitleName, type=?TITLE_STUDENT, auto_timeout=false, 
                         role_id=RoleID, show_in_chat=if_show_in_chat(TitleName), show_in_sence=true,color=TitleColor};
        [TitleInfo] ->
            #p_title{id=TitleID,name=OldTitleName} = TitleInfo,
            R = TitleInfo#p_title{name=TitleName, show_in_chat=if_show_in_chat(TitleName), color=TitleColor}
    end,
    db:dirty_write(?DB_NORMAL_TITLE, R),
    common_hook_title:exchange_title_name(RoleID,OldTitleName,TitleName,TitleColor,TitleID,true).


set_simple_role_title(RoleID,TitleType,TitleName,TitleColor) when is_integer(TitleType)->
    case db:dirty_match_object(?DB_NORMAL_TITLE,#p_title{type=TitleType,role_id=RoleID,_='_'}) of
        [] ->
            OldTitleName = undefined,
            TitleID = get_new_titleid(),
            R = #p_title{id=TitleID, name=TitleName, type=TitleType, auto_timeout=false, 
                         role_id=RoleID, show_in_chat=if_show_in_chat(TitleName), show_in_sence=true,color=TitleColor};
        [TitleInfo] ->
            #p_title{id=TitleID,name=OldTitleName} = TitleInfo,
            R = TitleInfo#p_title{name=TitleName, show_in_chat=if_show_in_chat(TitleName), color=TitleColor}
    end,
    db:dirty_write(?DB_NORMAL_TITLE, R),
    common_hook_title:change(RoleID),  
    case OldTitleName of
        undefined ->
            nil;
        _ ->
            common_hook_title:exchange_title_name(RoleID,OldTitleName,TitleName,"00ffff",TitleID)
    end.

%%=========================TITLE VIP===========================
set_vip_title(RoleID, {TitleName, Color}) ->
    case db:dirty_match_object(?DB_NORMAL_TITLE, #p_title{type=?TITLE_VIP, role_id=RoleID, _='_'}) of
        [] ->
            OldTitleName = undefined,
            TitleID = get_new_titleid(),
            if TitleName =:= "" ->
            R = #p_title{id=TitleID, name=TitleName, type=?TITLE_VIP, auto_timeout=false, 
                                 role_id=RoleID, show_in_chat=true, show_in_sence=false, color=Color};
               true ->
                    R = #p_title{id=TitleID, name=TitleName, type=?TITLE_VIP, auto_timeout=false, 
                                 role_id=RoleID, show_in_chat=true, show_in_sence=true, color=Color}
            end;
        [TitleInfo] ->
            #p_title{id=TitleID, name=OldTitleName} = TitleInfo,
            if TitleName =:= "" ->
                    R = TitleInfo#p_title{name=TitleName, show_in_chat=true, color=Color};
               true ->
                    R = TitleInfo#p_title{name=TitleName, show_in_chat=true, show_in_sence=true, color=Color}
            end
    end,
    db:dirty_write(?DB_NORMAL_TITLE, R),

    common_hook_title:change(RoleID),
    if TitleName =:= "" ->
            ignore;
	   true ->
    		common_hook_title:exchange_title_name(RoleID, OldTitleName, TitleName, Color, TitleID)
	end.

%%=========================TITLE ROLE_MANUAL====================
%% 设置成就称号
set_role_achievement_title(RoleID,AchievementTitleCode) ->
    case common_config_dyn:find(title,achievement_title) of
        [AchievementTitleList] when erlang:is_list(AchievementTitleList) ->
            case lists:keyfind(AchievementTitleCode,#r_achievement_title.code,AchievementTitleList) of
                false ->
                    AchievementTitle = undefined,
                    ?ERROR_MSG("~ts,RoleID=~w,AchievementTitleCode=~w",["添加成就称号出错",RoleID,AchievementTitleCode]);
                AchievementTitle ->
                    ignore
            end;
        _ ->
            AchievementTitle = undefined
    end,
    case AchievementTitle =/= undefined of
        true ->
    TitleID = get_new_titleid(),
            R = #p_title{id=TitleID, 
                         name=AchievementTitle#r_achievement_title.title_name, 
                         color=AchievementTitle#r_achievement_title.title_color, 
                         type=?TITLE_ROLE_ACHIEVEMENT, 
                         auto_timeout=false, 
                         timeout_time=0, 
                         role_id=RoleID, 
                         show_in_chat=AchievementTitle#r_achievement_title.is_show_in_chat, 
                         show_in_sence=AchievementTitle#r_achievement_title.is_show_in_sence},
            db:dirty_write(?DB_NORMAL_TITLE, R),
            common_hook_title:change(RoleID),
            common_hook_title:exchange_title_name(RoleID,undefined,AchievementTitle#r_achievement_title.title_name,
                                                  AchievementTitle#r_achievement_title.title_color,TitleID),
            ok;
        _ ->
            ignore
    end.

set_role_hero_fb_title(RoleID,TitleCode)->
    case common_config_dyn:find(title,hero_fb_title) of
        [TitleList] when erlang:is_list(TitleList) ->
            case lists:keyfind(TitleCode,#r_hero_fb_title.code,TitleList) of
                false ->
                    Title = undefined;
                    %%?ERROR_MSG("~ts,RoleID=~w,AchievementTitleCode=~w",["添加英雄副本称号出错",RoleID,TitleCode]);
                Title ->
                    ignore
            end;
        _ ->
            Title = undefined
    end,
    case Title =/= undefined of
        true ->
            case db:dirty_match_object(?DB_NORMAL_TITLE,#p_title{type=?TITLE_ROLE_HERO_FB,role_id=RoleID,_='_'}) of
                [TitleInfo] when is_record(TitleInfo,p_title)->
                    TitleID=TitleInfo#p_title.id;
                 _ ->
                    TitleID = get_new_titleid()
            end,
            R = #p_title{id=TitleID, 
                         name=Title#r_hero_fb_title.title_name, 
                         color=Title#r_hero_fb_title.title_color, 
                         type=?TITLE_ROLE_HERO_FB, 
                         auto_timeout=false, 
                         timeout_time=0, 
                         role_id=RoleID, 
                         show_in_chat=Title#r_hero_fb_title.is_show_in_chat, 
                         show_in_sence=Title#r_hero_fb_title.is_show_in_sence},
            db:dirty_write(?DB_NORMAL_TITLE, R),
            common_hook_title:change(RoleID),
            common_hook_title:exchange_title_name(RoleID,undefined,Title#r_hero_fb_title.title_name,
                                                  Title#r_hero_fb_title.title_color,TitleID),
            ok;
        _ ->
            ignore
    end.

%%=========================TITLE_OFFICE=========================
set_office_title(RoleID,FactionID,TitleType,TitleName,Color) ->
    TitleID = TitleType + FactionID,
    case db:dirty_read(?DB_SPEC_TITLE,TitleID) of
        [] ->
            OldRoleID = 0,
            R = #p_title{id=TitleID, name=TitleName, type=TitleType, auto_timeout=false, 
                         role_id=RoleID, show_in_chat=if_show_in_chat(TitleName), show_in_sence=true,color=Color};
        [TitleInfo] ->
            OldRoleID = TitleInfo#p_title.role_id,
            R = TitleInfo#p_title{role_id = RoleID}
    end,
    db:dirty_write(?DB_SPEC_TITLE, R),
    case OldRoleID =:= RoleID of
        true ->
            nil;
        false ->
            common_hook_title:change(RoleID),
            case OldRoleID of
                0 ->
                    common_hook_title:change(OldRoleID);
                _ ->
                    nil
            end
    end.

%%=========================TITLE_OFFICE_MINISTER================
set_office_minister(RoleID,FactionID) ->
    set_office_title(RoleID,FactionID,?TITLE_OFFICE_MINISTER,?OFFICE_NAME_MINISTER,"ffc000").
   

%%=========================TITLE_OFFICE_JINYIWEI================
set_office_jinyiwei(RoleID,FactionID) ->
    set_office_title(RoleID,FactionID,?TITLE_OFFICE_JINYIWEI,?OFFICE_NAME_JINYIWEI,"00aeff").


%%=========================TITLE_OFFICE_GENERAL=================
set_office_general(RoleID,FactionID) ->
    set_office_title(RoleID,FactionID,?TITLE_OFFICE_GENERAL,?OFFICE_NAME_GENERAL,"fc00ff").

    
%%=========================TITLE MANUAL=========================
set_role_manual_title(RoleID,{Type,TitleName,TitleColor,ShowChat,ShowSence,AutoTimeOut,Time}) ->
    TitleID = get_new_titleid(),
    R = #p_title{id=TitleID, name=TitleName, color=TitleColor, type=Type, 
                 auto_timeout=AutoTimeOut, timeout_time=Time, role_id=RoleID, 
                 show_in_chat=ShowChat, show_in_sence=ShowSence},
    db:dirty_write(?DB_NORMAL_TITLE, R),
    common_hook_title:change(RoleID),
    common_hook_title:exchange_title_name(RoleID,undefined,TitleName,TitleColor,TitleID).


%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

%% 是否在聊天窗口中显示
if_show_in_chat(undefined)->
    false;
if_show_in_chat([])->
    false;
if_show_in_chat(TitleName) ->
    StrTitleName = common_tool:to_list(TitleName),
    [ShowInChatList] = common_config_dyn:find(title,show_in_chat),
    lists:member(StrTitleName, ShowInChatList).

%% 获取称号颜色
get_title_color(TitleName)->
    case common_config_dyn:find(title,{title_color,TitleName}) of
        []->
            "ffffff";
        [Color]->
            Color
    end.

%% 获取排行榜对应的称号名称
get_title_name_of_rank(RankType,Rank)->
    case common_config_dyn:find(title,{rank_type,RankType}) of
        []->
            false;
        [TitleList]->
            get_title_name_of_rank_2(TitleList,Rank)
    end.
get_title_name_of_rank(RankType,Rank,SubType)->
    case common_config_dyn:find(title,{rank_type,RankType,SubType}) of
        []->
            false;
        [TitleList]->
            get_title_name_of_rank_2(TitleList,Rank)
    end.

get_title_name_of_rank_2([],_Rank)->
    "";
get_title_name_of_rank_2([H|T],Rank)->
    {Min,Max,TitleName}= H,
    case Rank>=Min andalso Rank=<Max of
        true->
            TitleName;
        _ ->
            get_title_name_of_rank_2(T,Rank)
    end.
