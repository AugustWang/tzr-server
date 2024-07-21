%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     处理新手子模块，包括（新手卡激活码等）
%%% @end
%%% Created : 2010-12-17
%%%-------------------------------------------------------------------
-module(mod_newcomer).

-include("mgeem.hrl").

%% API
-export([
         handle/1
         ]).

-define(MIN_ACTIVATE_CODE_LEN,14).  %%目前最短的激活码长度为14
-define(DO_ACTIVATE_ERROR(Reason),do_activate_error(Unique, Module, Method, Reason, PID)).



%%%===================================================================
%%% API
%%%===================================================================

handle({_, ?NEWCOMER, ?NEWCOMER_ACTIVATE_CODE, _, _, _PID, _Line}=Info)->
    do_activate_code(Info);

handle(Args) ->
    ?ERROR_MSG("~w, unknow args: ~w", [?MODULE,Args]),
    ok. 


%% ====================================================================
%% Internal functions
%% ====================================================================


%%检查激活码是否有效
check_activate_code(Code)->
    case is_list(Code) andalso length(Code)>= ?MIN_ACTIVATE_CODE_LEN of
        true->
            next;
        _ ->
            throw({error,?_LANG_NEWCOMER_ACTIVATE_CODE_WRONG})
    end,
    PublishKey = get_publish_key(Code),
    case common_config_dyn:find(activate_code,PublishKey) of
        []->
            throw({error,?_LANG_NEWCOMER_ACTIVATE_CODE_TYPE_ERROR});
        [#r_activate_code_info{begin_time=0,end_time=0}]->
            next;
        [#r_activate_code_info{begin_time=BeginTime,end_time=EndTime}]->
            Now = common_tool:now(),
            if
                Now < BeginTime->
                    Msg = common_misc:format_lang(?_LANG_NEWCOMER_ACTIVATE_CODE_BEGINTIME_ERR, [common_tool:seconds_to_datetime_string2(BeginTime)]),
                    throw({error,Msg});
                Now > EndTime->
                    Msg = common_misc:format_lang(?_LANG_NEWCOMER_ACTIVATE_CODE_ENDTIME_ERR, [common_tool:seconds_to_datetime_string2(EndTime)]),
                    throw({error,Msg});
                true->
                    next
            end
    end,
    ok.

%%@doc处理新手卡激活码功能
do_activate_code({Unique, Module, Method, DataIn, RoleID, PID, _Line})->
    #m_newcomer_activate_code_tos{code=Code}=DataIn,
    case catch check_activate_code(Code) of
        ok->
            WhereExpr = io_lib:format("code='~s' ",[Code]),
            SqlCode = mod_mysql:get_esql_select(t_activate_code,[role_id],WhereExpr) ,
            case mod_mysql:select(SqlCode) of
                {ok,[]}->
                    ?DO_ACTIVATE_ERROR( ?_LANG_NEWCOMER_ACTIVATE_CODE_WRONG );
                {ok,[[MatchID]]}->
                    case (MatchID>0) of
                        true->
                            ?DO_ACTIVATE_ERROR( ?_LANG_NEWCOMER_ACTIVATE_CODE_BE_AWARED );
                        false->
                            PublishKey = get_publish_key(Code),
                            SqlRole = mod_mysql:get_esql_select(t_activate_code,[role_id],io_lib:format("`role_id`=~w and `publish_id`=~w limit 1",[RoleID,PublishKey])) ,
                            case mod_mysql:select(SqlRole) of
                                {ok,[]}->
                                    %%赠送奖品
                                    send_activate_gift({Unique, Module, Method, DataIn, RoleID, PID},PublishKey,WhereExpr);
                                {ok,_}->    
                                    ?DO_ACTIVATE_ERROR( ?_LANG_NEWCOMER_ACTIVATE_CODE_ROLE_ONLY_ONCE );
                                Error1 ->
                                    ?ERROR_MSG("领取激活码错误，Error=~w",[Error1]),
                                    ?DO_ACTIVATE_ERROR( ?_LANG_SYSTEM_ERROR )
                            end
                    end;
                Error2 ->
                    ?ERROR_MSG("领取激活码错误，Error=~w",[Error2]),
                    ?DO_ACTIVATE_ERROR( ?_LANG_SYSTEM_ERROR )
            end;
        {error,Reason}->
            ?DO_ACTIVATE_ERROR( Reason )
    end.

%%@doc 更新系统数据库
update_activate_log(_PublishKey,RoleID,WhereExpr)->
    {ok, #p_role_attr{level=RoleLevel}} = mod_map_role:get_role_attr(RoleID),
    LoginIP = case db:dirty_read(?DB_USER_ONLINE, RoleID) of
                  [Record] ->
                      common_tool:ip_to_str( Record#r_role_online.login_ip );
                  _->
                      ""
              end,
    MTime = common_tool:now(),
    
    SqlUpdate = mod_mysql:get_esql_update(t_activate_code,[{role_id,RoleID},{role_level,RoleLevel},{mtime,MTime},{userip,LoginIP}],WhereExpr),
    {ok,_} = mod_mysql:update(SqlUpdate).

%%@doc 获取激活码发放PublishKey
%%@return -> 有发放类型和发放批次组成
get_publish_key(Code)->
    PublishKey = string:substr(Code,13,(length(Code)-12)),
    common_tool:to_integer(PublishKey).

%%赠送激活码的礼品
send_activate_gift({Unique, Module, Method, _DataIn, RoleID, PID},PublishKey,WhereExpr)->
    [#r_activate_code_info{gift_id=GiftID,gift_num=GiftNum}] = common_config_dyn:find(activate_code,PublishKey),
    
    case send_activate_gift2(RoleID,GiftID,GiftNum) of
        ok->
            try
                update_activate_log(PublishKey,RoleID,WhereExpr),
                ?UNICAST_TOC( #m_newcomer_activate_code_toc{succ=true} ),
                common_item_logger:log(RoleID, GiftID,GiftNum,true,?LOG_ITEM_TYPE_XI_TONG_ZENG_SONG)
            catch
                _:Reason3->
                    ?ERROR_MSG("更新激活码数据库错误，Error=~w",[Reason3]),
                    ?DO_ACTIVATE_ERROR( ?_LANG_SYSTEM_ERROR )
            end;
        {error,Reason}->
            ?DO_ACTIVATE_ERROR( Reason )
    end.

send_activate_gift2(RoleID,ItemTypeID,ItemNum)->   
    CreateInfo = #r_goods_create_info{bind=true,type=?TYPE_ITEM, type_id=ItemTypeID, start_time=0,
                                      end_time=0, num=ItemNum, color=0,quality=0,
                                      punch_num=0,interface_type=present},
    case db:transaction(fun() -> mod_bag:create_goods(RoleID,CreateInfo) end) of
        {atomic, {ok,GoodsList}} ->
            common_misc:new_goods_notify({role, RoleID},GoodsList),
            ok;
        {aborted, Error} when Error =:= {bag_error,not_enough_pos}
            orelse Error =:= {bag_error,not_enough_pos}->
            ?ERROR_MSG("赠送激活码时，背包已满",[]),
            {error,?_LANG_NEWCOMER_ACTIVATE_CODE_BAG_FULL};
        {aborted, Reason2} ->
            ?ERROR_MSG("赠送激活码的礼品 Error,Reason2=~w~n=====",[Reason2]),
            {error,?_LANG_SYSTEM_ERROR}
    end.


%%处理出错
do_activate_error(Unique, Module, Method, Reason, PID) ->
    Rec = #m_newcomer_activate_code_toc{succ=false, reason=Reason},
    ?UNICAST_TOC( Rec ).


