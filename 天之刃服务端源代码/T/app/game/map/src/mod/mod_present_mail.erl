%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     通过邮件赠送玩家礼品，目前是通过判断玩家的创建时间的长度
%%% @end
%%% Created : 2011-04-13
%%%-------------------------------------------------------------------
-module(mod_present_mail).

-include("mgeem.hrl").

%% API
-export([
         loop/1,
         hook_first_enter_map/3
         ]).


-define(TIME_PRESENT_SINCE,55*60).

-define(TIME_LIST,[{55*60,mail55},{50*60,mail50},{45*60,mail45}]).
-define(MAIL_LIST,[{r_present_mail_info,mail55,<<"恭喜您获得超大经验果实">>,
                    <<"<TEXTFORMAT LEADING='2'><P ALIGN='LEFT'><FONT FACE='Arial' SIZE='12' COLOR='#FFFFFF' LETTERSPACING='0' KERNING='0'>亲爱的玩家：</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING='2'><P ALIGN='LEFT'><FONT FACE='Arial' SIZE='12' COLOR='#FFFFFF' LETTERSPACING='0' KERNING='0'>        欢迎您来到《天之刃》！恭喜您获得1个【超大经验果实】，领取后在背包双击使用即可获得海量经验，助您轻松升级！请点击附件领取奖励！</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING='2'><P ALIGN='RIGHT'><FONT FACE='Arial' SIZE='12' COLOR='#FFFFFF' LETTERSPACING='0' KERNING='0'>《天之刃》运营团队</FONT></P></TEXTFORMAT>">>,
                      true,1,10800023,1},
                    {r_present_mail_info,mail50,<<"5分钟后可领取大量经验奖励">>,
                    <<"<TEXTFORMAT LEADING='2'><P ALIGN='LEFT'><FONT FACE='Arial' SIZE='12' COLOR='#FFFFFF' LETTERSPACING='0' KERNING='0'>亲爱的玩家：</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING='2'><P ALIGN='LEFT'><FONT FACE='Arial' SIZE='12' COLOR='#FFFFFF' LETTERSPACING='0' KERNING='0'>        欢迎您来到《天之刃》！想要光速升级？除了经验，其他神马的都是浮云！5分钟后系统将会通过系统邮件方式赠送您超大经验果实。有神马用？你懂的！</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING='2'><P ALIGN='RIGHT'><FONT FACE='Arial' SIZE='12' COLOR='#FFFFFF' LETTERSPACING='0' KERNING='0'>《天之刃》运营团队</FONT></P></TEXTFORMAT>">>,
                      false,0,0,0},
                    {r_present_mail_info,mail45,<<"10分钟后可领取大量经验奖励">>,
                    <<"<TEXTFORMAT LEADING='2'><P ALIGN='LEFT'><FONT FACE='Arial' SIZE='12' COLOR='#FFFFFF' LETTERSPACING='0' KERNING='0'>亲爱的玩家：</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING='2'><P ALIGN='LEFT'><FONT FACE='Arial' SIZE='12' COLOR='#FFFFFF' LETTERSPACING='0' KERNING='0'>        欢迎您来到《天之刃》！想要光速升级？除了经验，其他神马的都是浮云！10分钟后系统将会通过系统邮件方式赠送您超大经验果实。有神马用？你懂的！</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING='2'><P ALIGN='RIGHT'><FONT FACE='Arial' SIZE='12' COLOR='#FFFFFF' LETTERSPACING='0' KERNING='0'>《天之刃》运营团队</FONT></P></TEXTFORMAT>">>,
                      false,0,0,0}
                ]).
-define(PRESENT_ID_SUPER_EXP,20001).

%===================================================================
%%% API
%%%===================================================================

loop(_MapID)->
    case common_config_dyn:find(etc,is_open_present_mail) of
        [true]->
            do_loop();
        _ ->
            ignore
    end.

%%@doc 玩家首次进入地图，处理赠品通知
hook_first_enter_map(RoleID,RoleAttr,RoleBase) ->
    case common_config_dyn:find(etc,is_open_present_mail) of
        [true]->
            case has_present_super_exp(RoleID) of
                true->
                    ignore;
                _ ->
                    do_check_present_mail(RoleID,RoleAttr,RoleBase)
            end;
        _ ->
            ignore
    end.


%% ====================================================================
%% Internal functions
%% ====================================================================

get_map_roleid_list()->
    case mod_map_actor:get_in_map_role() of
        undefined->
            [];
        List->
            List
    end.

%%@doc 执行循环检查
do_loop()->
    RoleIDList = get_map_roleid_list(),
    lists:foreach(fun(RoleID)-> 
                          case has_present_super_exp(RoleID) of
                              true-> 
                                  ignore;
                              _ ->
                                  do_notify_present_mail(RoleID)
                          end
                  end, RoleIDList),
    ok.

%%@doc 根据条件检查是否需要进行赠送的通知
do_notify_present_mail(RoleID)->
    TimeSince = get_create_time_since(RoleID),
    do_notify_present_mail_2(RoleID,TimeSince,?TIME_LIST).

do_notify_present_mail_2(_RoleID,_TimeSince,[])->
    ignore;
do_notify_present_mail_2(RoleID,TimeSince,[H|T])->
    {TimeKey,MailKey} = H,
    case TimeSince=:=TimeKey of
        true->
            case lists:keyfind(MailKey, #r_present_mail_info.mail_key, ?MAIL_LIST) of
                MailInfo when is_record(MailInfo,r_present_mail_info)->
                    do_send_mail(RoleID,MailInfo);
                false->
                    ?ERROR_MSG("系统错误！！{RoleID,TimeKey,MailKey}=~w",[{RoleID,TimeKey,MailKey}]),
                    ignore
            end;
        _ ->
            do_notify_present_mail_2(RoleID,TimeSince,T)
    end.

do_send_mail(RoleID,false)->
    ?ERROR_MSG("系统错误！！RoleID=~w",[RoleID]),
    ignore;
do_send_mail(RoleID,MailInfo)->
    #r_present_mail_info{mail_title=MailTitle,mail_text=MailText,has_attach=HasAttack,
                         item_type=_ItemType,item_id=ItemID,item_num=ItemNum} = MailInfo,
    case HasAttack of
        true->
            %%这样将会使用默认的道具颜色
            Info = #r_item_create_info{role_id=RoleID, num=ItemNum, typeid=ItemID, bind=true,
                                       start_time=0, end_time=0,color=0},
            case common_bag2:create_item(Info) of
                {ok, GoodsList} ->    
                    NewGoodsList = [ G#p_goods{id=1,bagposition=1,bagid=9999} || G<-GoodsList ],
                    common_letter:sys2p(RoleID,MailText,MailTitle,NewGoodsList,14),
                    mark_present_super_exp(RoleID),
                    [Goods|_] = NewGoodsList,
                    common_item_logger:log(RoleID,Goods,ItemNum,?LOG_ITEM_TYPE_XI_TONG_ZENG_SONG),
                    ok;
                {error, Reason} ->
                    ?ERROR_MSG("通过邮件赠送物品出错！~w", [Reason])
            end;
        _ ->
            common_letter:sys2p(RoleID,MailText,MailTitle,14)
    end.


%%@doc 根据条件检查是否需要进行赠送礼品
do_check_present_mail(RoleID,_RoleAttr,RoleBase)->
    #p_role_base{create_time=CreateTime} = RoleBase,
    TimeSince = common_tool:now() - CreateTime,
    case TimeSince>=?TIME_PRESENT_SINCE of
        true->
            MailInfo = lists:keyfind(mail55, #r_present_mail_info.mail_key, ?MAIL_LIST),
            do_send_mail(RoleID,MailInfo);
        _ ->
            ignore
    end.

%%@doc 判断玩家是否领过指定的奖品
has_present_super_exp(RoleID)->
    case db:dirty_read(?DB_ROLE_PRESENT,RoleID) of
        [#r_role_present{present_list=PresentList}]->
            lists:keyfind(?PRESENT_ID_SUPER_EXP, 1, PresentList) =/= false;
        _ -> 
            false
    end.


%%@doc 标记已经领取了超级经验果实
mark_present_super_exp(RoleID)->
    Tpl = {?PRESENT_ID_SUPER_EXP,1},
    case db:dirty_read(?DB_ROLE_PRESENT,RoleID) of
        [#r_role_present{present_list=List1}=R1]->
            List2 = lists:keystore(?PRESENT_ID_SUPER_EXP, 1, List1, Tpl),
            R2 = R1#r_role_present{present_list=List2};
        [] -> 
            R2 = #r_role_present{role_id=RoleID, present_list=[Tpl]}
    end,
    db:dirty_write(?DB_ROLE_PRESENT,R2).


%%@doc 获取玩家的离当前的创建时间距离
get_create_time_since(RoleID)->
    case mod_map_role:get_role_base(RoleID) of
        {ok,#p_role_base{create_time=CreateTime}} ->
            common_tool:now() - CreateTime;
        _ ->
            0
    end.



