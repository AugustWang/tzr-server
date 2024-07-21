-module(mod_gm).
-include("mgeec.hrl").
-include("office.hrl").

-define(SPLIT, $=).
-export([cmd/2, do_cmd/2, get_cmd/5, set_role_attr_opt/2, set_role_base_opt/2]).

cmd(_RoleID, []) ->
    "";
cmd(RoleID, CmdMsg) ->
    get_cmd(common_config:is_debug(), RoleID, CmdMsg, false, {"", [], ""}).


get_cmd(false, _RoleID, CmdMsg, _GotFunName, _FunTuple) ->
    {not_gm, CmdMsg};

get_cmd(true, RoleID, CmdMsg, GotFunName, FunTuple) ->
    case string:substr(CmdMsg, 1, 3) of
        "m2_" ->
            Msg = do_get_cmd(true, RoleID, CmdMsg, GotFunName, FunTuple),
            {gm, lists:flatten(lists:concat([Msg, "\n<FONT COLOR='#FF0000'>旧:", CmdMsg, "</FONT>"]))};
        _ ->
            {not_gm, CmdMsg}
    end.

do_get_cmd(true, _RoleID, [], false, _) ->
    lists:concat(["GM命令有误:\ngm命令统一使用m2_开头,使用", lists:flatten([?SPLIT]), "分隔不同参数\n"]);

do_get_cmd(true, RoleID, [], true, {FunStr, Args, TmpArgStr}) ->

   try 

        Fun=erlang:list_to_atom(FunStr),
    
        TrueArgs = 
            lists:foldl(
              fun(Arg, Result) ->
                      [erlang:list_to_integer(Arg)|Result]
              end, [], [TmpArgStr|Args]),

        ?DEV("~ts:~w ~ts:~w", ["GM命令", Fun, "参数", TrueArgs]),
        apply(?MODULE, do_cmd, [Fun, {[RoleID|TrueArgs]}])
            
   catch
       _:Reason ->
           lists:flatten(lists:concat(["GM命令有误", io_lib:format("~w", [Reason])]))
   end;

do_get_cmd(true, RoleID, [Char|Msg], GotFunName, {FunStr, Args, TmpArgStr}) ->

    case Char of
        ?SPLIT when GotFunName =:= false ->

            TrueFun = lists:flatten([TmpArgStr]),
            TrueFA = {TrueFun, [], ""},
            NewGotFunName=true,

            do_get_cmd(true, RoleID, Msg, NewGotFunName, TrueFA);

        ?SPLIT when TmpArgStr /= "" ->

            TrueFA = {FunStr, [TmpArgStr|Args], ""},
            NewGotFunName=GotFunName,

            do_get_cmd(true, RoleID, Msg, NewGotFunName, TrueFA);

        _ ->

            TrueFA = {FunStr, Args, lists:flatten([TmpArgStr, Char])},
            NewGotFunName=GotFunName,

            do_get_cmd(true, RoleID, Msg, NewGotFunName, TrueFA)
    end.

%%@doc zesen专用
do_cmd(m2_zesen, {[RoleID, ID]}) ->
    case ID of
        1->
            common_role_money:set(RoleID, [{silver, 11111111}]),
            common_role_money:set(RoleID, [{gold, 11111}]),
            Num = 100000,
            set_role_base_opt(RoleID, [{base_str, Num}, {base_int, Num}, {base_con, Num}, {base_dex, Num}, {base_men, Num}]),
            send_to_role_map_gm(RoleID, {set_level, RoleID, 50}),
            %%赠送的道具
            AwdItemList = [{?TYPE_ITEM,10100001,100},{?TYPE_EQUIP,30112199,1}],
            send_to_role_map_gm(RoleID, {add_item, RoleID, AwdItemList}),
            "GM:还我靓靓拳";
        2->
            send_to_role_map_gm(RoleID, {family_enable_map, RoleID}),
            send_to_role_map_gm(RoleID, {family_add_money, RoleID, 11111111}),
            send_to_role_map_gm(RoleID, {family_add_active_points, RoleID, 11111}),
            do_cmd(m2_family_con, {[RoleID, 11111]}), 
            "GM:还门派靓靓拳";
        3->
            common_role_money:set(RoleID, [{gold, 11111}]),
            %%赠送的道具
            AwdItemList = [{?TYPE_ITEM,10100001,100},{?TYPE_EQUIP,30112199,1}],
            send_to_role_map_gm(RoleID, {add_item, RoleID, AwdItemList}),
            "GM:还神马靓靓拳";
        4->
            Num = 100000,
            set_role_base_opt(RoleID, [{base_str, Num}, {base_int, Num}, {base_con, Num}, {base_dex, Num}, {base_men, Num}]),
            "GM:还属性靓靓拳";
        _->
            "2B了吧，这个命令已经不能用了吧~"
    end;

%%@doc 立即更新排行榜
do_cmd(m2_rank, {[_RoleID,_Num]}) ->
    global:send(mgeew_ranking,update_all_rank),
    "GM:立即更新排行榜";

do_cmd(m2_addexp, {[RoleID, Exp]}) ->
    common_misc:send_to_rolemap(RoleID, {mod_map_role, {add_exp, RoleID, Exp}}),
    
    "GM:加经验命令";
 
 
do_cmd(m2_bc, {[_RoleID, FileID]}) ->
    BroadCastDataDir = lists:concat(["config/broadcast_", FileID,  ".config"]),
    {ok, List} = file:consult(BroadCastDataDir),
    DataRecord = List,
    Unique = ?DEFAULT_UNIQUE,
    Module =  ?BROADCAST,
    Method = ?BROADCAST_ADMIN,
    global:send("mod_broadcast_server", {Unique, Module, Method, DataRecord}),

    "GM:系统广播";

do_cmd(m2_baseattr, {[_RoleID, _Num]}) ->
    "2B了吧，这个命令已经不能用了吧~";

do_cmd(m2_baseattr, {[RoleID, Num, Int]}) when is_integer(Int) ->
    set_role_base_opt(RoleID, [{base_str, Num}, {base_int, Num}, {base_con, Num}, {base_dex, Num}, {base_men, Num}]),
    "GM:加攻基本属性";
    
do_cmd(m2_apoint, {[RoleID, Num]}) ->
    set_role_base_opt(RoleID, [{remain_attr_points, Num}]),
    "GM:加基本属性点";
    
do_cmd(m2_spoint, {[RoleID, Num]}) ->
    set_role_attr_opt(RoleID, [{remain_skill_points, Num}]),
    "GM:加技能属性点";

do_cmd(m2_silver, {[RoleID, Num]}) ->
    common_role_money:set(RoleID, [{silver, Num}]),
    "GM:设置银两";
  
do_cmd(m2_bsilver, {[RoleID, Num]}) ->
    common_role_money:set(RoleID, [{silver_bind, Num}]),
    "GM:设置绑定银两";

do_cmd(m2_gold, {[RoleID, Num]}) ->
    common_role_money:set(RoleID, [{gold, Num}]),
    "GM:设置元宝";
  
do_cmd(m2_bgold, {[RoleID, Num]}) ->
    common_role_money:set(RoleID, [{gold_bind, Num}]),
    "GM:设置绑定元宝";

do_cmd(m2_miss, {[RoleID, MissID]}) ->
    send_to_role_map_gm(RoleID, {gm_set_mission, RoleID, MissID}),
    "GM:设置完成主线任务成功";

do_cmd(m2_family_add_active_points, {[RoleID, Num]}) ->
    send_to_role_map_gm(RoleID, {family_add_active_points, RoleID, Num}),
    "GM:添加门派繁荣度成功";

do_cmd(m2_family_enable_map, {[RoleID, _]}) ->
    send_to_role_map_gm(RoleID, {family_enable_map, RoleID}),
    "GM:激活门派地图成功 ";


do_cmd(m2_family_add_money, {[RoleID, Num]}) ->
    send_to_role_map_gm(RoleID, {family_add_money, RoleID, Num}),
    "GM:添加门派财富成功";

do_cmd(m2_family_uplevel, {[RoleID, _Num]}) ->
    send_to_role_map_gm(RoleID, {family_uplevel,RoleID}),
    "GM:门派直接升级";

do_cmd(m2_family_maintain, {[RoleID, _]}) ->
    common_family:info_by_roleid(RoleID, gm_family_maintain),
    "GM:执行门派地图维护成功";

do_cmd(m2_set_energy, {[RoleID, Num]}) ->
    {ok, RoleFight} = common_misc:get_dirty_role_fight(RoleID),
    db:dirty_write(?DB_ROLE_FIGHT, RoleFight#p_role_fight{energy=Num}),
    ChangeAttList = [#p_role_attr_change{change_type=?ROLE_ENERGY_CHANGE, new_value=?DEFAULT_ENERGY}],
    DataRecord = #m_role2_attr_change_toc{roleid=RoleID, changes=ChangeAttList},
    Info = {role_msg, ?ROLE2, ?ROLE2_ATTR_CHANGE, DataRecord},
    common_misc:chat_cast_role_router(RoleID, Info),
    "GM:设置精力值成功";

%%未处理 不知道可不可用
do_cmd(m2_add_hyd, {[RoleID, FriendName, Friendly]}) ->
    FriendID = (catch common_misc:get_roleid(common_tool:to_list(FriendName))),
    global:send(mod_friend_server, {add_friendly, RoleID, FriendID, Friendly, 3}),
    Pattern = #r_friend{roleid=RoleID, friendid=FriendID, _='_'},
    Friendly0 =
        case catch db:dirty_match_object(?DB_FRIEND, Pattern) of
            {'EXIT', _} ->
                {error, system_error};
            [] ->
                {error, not_friend};
            [FriendInfo] ->
                FriendInfo#r_friend.friendly
        end,
    case Friendly0 of
        {error, system_error} ->
            "GM:系统错误";
        {error, not_friend} ->
            "GM:对方不是您的好友";
        _ ->
            io_lib:format("GM:添加友好度成功，当前友好度：~w", [Friendly0+Friendly])
    end;

do_cmd(m2_add_morals,{[RoleID,Value]}) ->
    gen_server:cast({global,mgeew_educate_server},
                    {add_morals,RoleID,Value}),
    "增加师德值成功";

do_cmd(m2_chefu, {[RoleID, ID, Line]}) ->
    
    [Config] = common_config_dyn:find(driver,ID),
    
    {_, ID, TX, TY, MapID, _RuleList} = Config,

    common_misc:send_to_rolemap(RoleID, {mod_map_role, {change_map, RoleID, MapID, TX, TY, ?CHANGE_MAP_TYPE_DRIVER}}),

    MapChangeTocDataRecord = 
        #m_map_change_map_toc{succ=true, 
                              mapid=MapID, 
                              tx=TX, 
                              ty=TY},
    
    common_misc:unicast(Line, 
                        RoleID, 
                        ?DEFAULT_UNIQUE, 
                        ?MAP, 
                        ?MAP_CHANGE_MAP, 
                        MapChangeTocDataRecord),

    "GM:车夫地图传送";
    
do_cmd(m2_lv, {[RoleID, Level]}) ->
    [MaxLevel] = common_config_dyn:find(etc, max_level),
    case Level > MaxLevel of
        true ->
            "GM:等级只开放到" ++ erlang:integer_to_list(MaxLevel) ++ "设置无效";
        _ ->
            send_to_role_map_gm(RoleID, {set_level, RoleID, Level}),
            "GM:设置等级"
    end;

do_cmd(m2_add_gx, {[RoleID, Add]}) ->
    common_misc:send_to_rolemap(RoleID, {mod_map_role, {add_gongxun, RoleID, Add}}),
    "GM:增加战功命令";

%%切换官职
do_cmd(m2_set_office, {[RoleID, OfficeID]}) ->
    {ok, RoleAttr} = common_misc:get_dirty_role_attr(RoleID),
    case OfficeID of
        0 ->
            NewOfficeID = 0,
            GMStr = "GM:已成功切换为平民";
        ?OFFICE_ID_MINISTER ->
            NewOfficeID = OfficeID,
            GMStr = "GM:已成功切换为"++binary_to_list(?OFFICE_NAME_MINISTER);
        ?OFFICE_ID_GENERAL ->
            NewOfficeID = OfficeID,
            GMStr = "GM:已成功切换为"++binary_to_list(?OFFICE_NAME_GENERAL);
        ?OFFICE_ID_JINYIWEI ->
            NewOfficeID = OfficeID,
            GMStr = "GM:已成功切换为"++binary_to_list(?OFFICE_NAME_JINYIWEI);
        ?OFFICE_ID_KING ->
            NewOfficeID = OfficeID,
            GMStr = "GM:已成功切换为国王";
        _ ->
            NewOfficeID = 0,
            GMStr = "失败，没有该官职"
    end,

    NewRoleAttr = RoleAttr#p_role_attr{office_id=NewOfficeID},
    
    db:dirty_write(?DB_ROLE_ATTR, NewRoleAttr),

    DataRecord = #m_role2_attr_reload_toc{role_attr=NewRoleAttr},

    Info = {role_msg, ?ROLE2, ?ROLE2_ATTR_RELOAD, DataRecord},

    common_misc:chat_cast_role_router(RoleID, Info),
    GMStr;

do_cmd(m2_family_con, {[RoleID, Num]}) ->
    %%必须先脏写数据库
    {ok, RoleAttr} = common_misc:get_dirty_role_attr(RoleID),
    {ok, RoleBase} = common_misc:get_dirty_role_base(RoleID),
    #p_role_attr{family_contribute=OldFmlConb} = RoleAttr,
    #p_role_base{family_id=FamilyID} = RoleBase,
  
    db:dirty_write(?DB_ROLE_ATTR, RoleAttr#p_role_attr{family_contribute=Num}),
    
    common_family:info(FamilyID, {add_contribution, RoleID, (Num-OldFmlConb)}),
    
    set_role_attr_opt(RoleID, [{family_contribute, Num}]),
    "GM:设置门派贡献度";

%% @doc 设置活跃度
do_cmd(m2_set_ap, {[RoleID, Num]}) ->
    set_role_attr_opt(RoleID, [{active_points, Num}]),

    "GM:设置活跃度";

%% @doc 获取玩家活跃度
do_cmd(m2_get_ap, {[RoleID, _Num]}) ->
    case get_role_attr_opt(RoleID) of
        {ok,ActivePt} -> 
            lists:flatten(lists:concat(["GM:查询活跃度:" , ActivePt]));
        {error,_Reason}->
            "GM:查询活跃度出错！"
    end;

%% @doc 学习所有技能
do_cmd(m2_skill, {[RoleID, _Num]}) ->
    common_misc:send_to_rolemap(RoleID, {mod_skill, {gm_learn_skill, RoleID}}),
    "GM:成功学习所有技能";
    
do_cmd(m2_god, {[RoleID, Level]}) ->
	do_cmd(m2_lv, {[RoleID, Level]}),
	do_cmd(m2_gold, {[RoleID, 5000000]}),
	do_cmd(m2_bgold, {[RoleID, 5000000]}),
	do_cmd(m2_silver, {[RoleID, 5000000]}),
	do_cmd(m2_bsilver, {[RoleID, 5000000]}),
	do_cmd(m2_baseattr, {[RoleID, 5000000, 123456]});

do_cmd(m2_ach, {[RoleID, EventId]}) ->
    do_m2_achieve(RoleID, EventId,1);
do_cmd(m2_ach, {[RoleID, EventId,AddProgress]}) ->
    do_m2_achieve(RoleID, EventId,AddProgress);
%% 设置玩家的五行属性
do_cmd(m2_five_ele_attr, {[RoleID, FiveEleAttr]}) ->
    case lists:member(FiveEleAttr,[1,2,3,4,5]) of
        true ->
            catch common_misc:send_to_rolemap(RoleID, {mod_role2, {admin_set_role_five_ele_attr, RoleID, FiveEleAttr}}),
            "GM:设置五行属性成功";
        _ ->
            "GM:五行属性的值为1：金，2：木，3：水，4：火，5：土"
    end; 
%% 设置玩家声望值
do_cmd(m2_prestige, {[RoleID, ShengWang]}) ->
    case erlang:is_integer(ShengWang) andalso ShengWang >= 0 of
        true ->
            catch common_misc:send_to_rolemap(RoleID, {mod_prestige, {admin_set_role_prestige, RoleID, ShengWang}}),
            "GM:设置声望成功";
        _ ->
            "GM:设置声望失败"
    end; 

do_cmd(m2_set_cj, {[RoleID, Num]}) ->
    {ok, #p_role_pos{map_id=MapID}} = common_misc:get_dirty_role_pos(RoleID),
    case MapID =:= 10300 of
        true ->
            common_misc:send_to_rolemap(RoleID, {mod_family_collect, {gm_set_family_collect_score, RoleID, Num}}),
            "GM:门派采集积分设置成功";
        _ ->
            "GM:这个命令暂时只能在门派地图使用呀"
    end;

do_cmd(m2_set_pk, {[RoleID, Num]}) ->
    case common_misc:send_to_rolemap(RoleID, {mod_pk, {admin_set_pkpoint, RoleID, Num}}) of
        ignore ->
            "GM: 设置PK值失败，系统错误";
        _ ->
            "GM: 设置PK值成功"
    end;

do_cmd(m2_set_njd, {[RoleID, Num]}) ->
    case common_misc:send_to_rolemap(RoleID, {mod_equip, {admin_set_endurance, RoleID, Num}}) of
        ignore ->
            "GM: 设置耐久度失败，系统错误";
        _ ->
            "GM: 设置耐久度成功"
    end;    

do_cmd(m2_hexie, _) ->
    HelpList = 
        [
         "<B>GM命令帮助菜单:</B>\n",
         lists:concat(["使用:<B><FONT COLOR='#FF0000'>", lists:flatten([?SPLIT]), "</FONT></B>分隔不同参数\n"]),
         help_format("加经验", "m2_addexp", ["经验值"]),
         help_format("创建怪物", "m2_cmonster", ["怪物类型", "怪物数量"]),
         help_format("载入系统广播", "m2_bc", ["文件ID"]),
         help_format("修改基础攻击等属性", "m2_baseattr", ["数值"]),
         help_format("修改基本属性点数", "m2_apoint", ["数值"]),
         help_format("修改技能属性点数", "m2_spoint", ["数值"]),
         help_format("修改银子", "m2_silver", ["数值"]),
         help_format("修改绑定银子", "m2_bsilver", ["数值"]),
         help_format("修改元宝", "m2_gold", ["数值"]),
         help_format("修改绑定元宝", "m2_bgold", ["数值"]),
         help_format("修改门派繁荣度", "m2_family_add_active_points", ["数值"]),
         help_format("激活门派地图", "m2_family_enable_map", ["1"]),
         help_format("维护门派地图", "m2_family_maintain", ["1"]),
         help_format("修改门派资金", "m2_family_add_money", ["数值"]),
         help_format("门派直接升级", "m2_family_uplevel", ["1"]),
         help_format("添加好友度，姓名暂时只支持数字", "m2_add_hyd", ["好友姓名", "数值"]),
         help_format("增加师德值","m2_add_morals",["师德值"]),
         help_format("车夫地图传送","m2_chefu",["传送地点ID，与车夫配置相同", "分线ID"]),
         help_format("设置等级", "m2_lv", ["等级"]),
         help_format("增加功勋", "m2_add_gx", ["数值"]),
         help_format("设置门派贡献度", "m2_family_con", ["数值"]),
         help_format("设置称号", "m2_set_office", ["数值"]),
         help_format("设置活跃度", "m2_set_ap", ["数值"]),
         help_format("查询活跃度", "m2_get_ap", ["1"]),
         help_format("上帝命令(加很多东西)", "m2_god", ["等级"]),
         help_format("成就事件", "m2_ach", ["事件"]),
         help_format("学习所有技能", "m2_skill", ["1"]),
         help_format("设置精力值", "m2_set_energy", ["数值"]),
         help_format("设置完成主线任务成功", "m2_miss", ["数值"]),
         help_format("设置门派采集积分", "m2_set_cj", ["数值"]),
         help_format("设置PK值", "m2_set_pk", ["数值"]),
         help_format("调置所有装备的耐久度", "m2_set_njd", ["数值"]),
         help_format("设置玩家五行属性", "m2_five_ele_attr", ["数值"]),
         help_format("设置声望值", "m2_prestige", ["数值"]),
		 ""
        ],

    lists:flatten(lists:concat(HelpList));

do_cmd(_, _) ->
    "失败了,没找到该命令".
    

help_format(FunTitle, FunName, Args) ->
    
    SplitStr = lists:flatten([?SPLIT]),
    Result = 
        lists:foldl(
          fun(Item, Result) ->
                  lists:concat([Result, SplitStr, Item])
          end, 
          ["<B>", 
           FunTitle, 
           ":</B>\n<FONT COLOR='#FF0000'>", 
           FunName
          ], 
          Args),

    lists:flatten(lists:concat([Result, "</FONT>\n"])).

%%获取角色ATTR
get_role_attr_opt(RoleID)->
    Info = {get_role_attr_opt, RoleID, self(),reply_get_role_attr_opt},
    common_misc:send_to_rolemap(RoleID, {mod_gm, Info}),
    receive_async_msg(reply_get_role_attr_opt).

%%接收其他进程发来的异步信息
receive_async_msg(ReplyTag)->
    receive 
        {ReplyTag,ReturnVal} ->
            ReturnVal
        after 5000 ->
            ?ERROR_MSG("time out  %%%%%%%%%",[]),
            {error,timeout}
    end.

    

%%设置角色ATTR
set_role_attr_opt(RoleID, OptionList) ->
    send_to_role_map_gm(RoleID, {set_role_attr_opt, RoleID, OptionList}).
set_role_base_opt(RoleID, OptionList) ->
    send_to_role_map_gm(RoleID, {set_role_base_opt, RoleID, OptionList}).
send_to_role_map_gm(RoleID, Info) ->
    common_misc:send_to_rolemap(RoleID, {mod_gm, Info}).
%% 成就事件
do_m2_achieve(RoleId,EventId,AddProgress) ->
    EventIdList = common_config_dyn:list(achievement_event),
    case lists:keyfind(EventId,#r_achievement_event.event_id,EventIdList) of
        false ->
            "此成就事件无效";
        _ ->
            common_hook_achievement:hook({chat_gm,{RoleId,EventId,AddProgress}}),
            ""
    end.
