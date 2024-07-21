%% Author: Administrator
%% Created: 2011-3-31
%% Description: TODO: Add description to mod_family_letter
-module(mod_letter).
%%
%% Include files
%%
-include("mgeem.hrl").
-define(ALL_FAMILY_MEMBERS,0).
-define(ONLINE_FAMILY_MEMBERS,1).
-define(OFFLINE_FAMILY_MEMBERS,2).
-define(ROLE_SEND_COUNT,role_send_count).
%%
%% Exported Functions
%%
-export([
         get_send_count_data/1,
         set_send_count_data/2,
         handle/1
        ]).



%%
%% API Functions
%% 

%%---------------------------------角色模块调用的借口-------------------------------
handle({send_family_letter,Msg})->
    send_family_letter(Msg);
handle({send_p2p,Msg})->
    send_p2p_letter(Msg);
handle({accept_goods,Msg})->
    accept_goods(Msg).


%% ==================== start 玩家发送门派信件 =============================
send_family_letter({Unique, _Module, _Method, DataIn, RoleID, _Pid, Line})->
    #m_letter_family_send_tos{text = Text ,range = Range} =DataIn,
    case catch check_send_family_letter(RoleID,Range) of
        {ok,RoleName,FamilyName,MembersList}->
            case db:transaction(fun() ->common_letter:t_cut_money(?LETTER_SEND_COST,RoleID) end) of
                {atomic,{ok,{NewSilverBind,NewSilver}}}->
                    %%通知前端银两改了
                    ChangeMoneyToc = common_letter:get_change_money_toc(RoleID,NewSilverBind,NewSilver),
                    common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE,?ROLE2,?ROLE2_ATTR_CHANGE,ChangeMoneyToc),
                    Info = {map_send_family_letter,Text,RoleID,RoleName,FamilyName,MembersList},
                    common_letter:send_letter_package(Info);
                {aborted, Error}->
                    ErrorMsg = case Error of
                                   {_,Reason1}->Reason1;
                                   _->"扣钱失败了"
                               end,
                    R2 = #m_letter_send_toc{succ=false,reason=ErrorMsg},
                    common_misc:unicast(Line, RoleID, Unique, ?LETTER, ?LETTER_SEND, R2)
              end;        
        {error,Reason}->
            R2 = #m_letter_send_toc{succ=false,reason=Reason},
            common_misc:unicast(Line, RoleID, Unique, ?LETTER, ?LETTER_SEND, R2)
    end.            

%%检查是否可以发送并获取发送的信息
check_send_family_letter(RoleID,Range)->
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    ?ERROR_MSG("FAMILY_LETTER_CHECK1 ~w,~w~n",[RoleID,Range]),
    case RoleAttr#p_role_attr.silver +RoleAttr#p_role_attr.silver_bind >=10 of
        true ->
            next;
        false->
            throw({error,"银两不够"})
    end,
    ?ERROR_MSG("FAMILY_LETTER_CHECK2 ~w,~w~n",[RoleID,Range]),
    {ok,RoleBase} = mod_map_role:get_role_base(RoleID),
    RoleID = RoleBase#p_role_base.role_id,
    FamilyInfo = 
        case db:dirty_read(?DB_FAMILY,RoleBase#p_role_base.family_id) of
            [TmpFamilyInfo] when erlang:is_record(TmpFamilyInfo,p_family_info)->
                TmpFamilyInfo;
            _->
                throw({error,"找不到门派"})
        end,
    ?ERROR_MSG("FAMILY_LETTER_CHECK3 ~w,~w~n",[RoleID,Range]),
    case check_right_send_family_letter(FamilyInfo,RoleID) of
        true->
            next;
        false->
            throw({error,"没有权限"})
    end,
    %%获取全门派成员
    Members1= FamilyInfo#p_family_info.members,
    ?ERROR_MSG("Members1~w~n",[Members1]),
    %%剔除发信人
    Members2 =lists:delete(lists:keyfind(RoleID, #p_family_member_info.role_id, Members1) ,Members1),
    ?ERROR_MSG("Members2~w~n",[Members2]),
    %%筛选发信范围
    Members3 = 
        lists:foldl(
          fun(Member,Acc)->
                  %% 玩家在线bool
                  %% 收信范围(0:全部,1:在线,-1:离线)
                  %% 帮众在线状态 (0:离线,1:在线)
                  case Range of
                      0->[Member|Acc];
                      1->if Member#p_family_member_info.online ->
                                [Member|Acc];
                            true->Acc
                         end;
                      -1->if Member#p_family_member_info.online ->
                                 Acc;
                             true->[Member|Acc]
                          end
                  end
          end,[],Members2),
    ?ERROR_MSG("Members3~w~n",[Members3]),
    
    case Members3 of
        []->
            throw({error,"没有收信对象"});
        _->
            next
    end,
    MembersList = [{Member#p_family_member_info.role_id,Member#p_family_member_info.role_name}||Member <-Members3],
    FamilyName = FamilyInfo#p_family_info.family_name,
    RoleName = RoleBase#p_role_base.role_name,
    {ok,RoleName,FamilyName,MembersList}.
             
check_right_send_family_letter(FamilyInfo,RoleID)->
    %%是否掌门
    (RoleID=:=FamilyInfo#p_family_info.owner_role_id)  
        orelse
        %%是否长老
        lists:any(fun(SecondOwner)-> 
                          SecondOwner#p_family_second_owner.role_id =:=RoleID
                  end,
                  FamilyInfo#p_family_info.second_owners).

%% ==================== end 玩家发送门派信件 ====================

%% ====================start 玩家发送个人信件 ===================
send_p2p_letter({Unique, _Module, _Method, DataIn, RoleID, _Pid, Line})->
    #m_letter_p2p_send_tos{receiver = RecvName, 
                           text = Text, 
                           goods_list = LetterGoodsList} = DataIn,
    case catch check_can_send_p2p_letter(RoleID,RecvName,Text,LetterGoodsList) of
        {ok,IfHaveGoods,RecvID}-> 
            case IfHaveGoods of 
                true-> %% 扣钱,扣物,
                    GoodsIDList = [GoodsID || #p_letter_goods{goods_id=GoodsID} <- LetterGoodsList],
                    case db:transaction(fun()->t_cut_goods_and_money(RoleID,GoodsIDList) end) of
                        {atomic,{GoodsList,NewSilverBind,NewSilver}}->
                            %%通知前端银两改变
                            ChangeMoneyToc = common_letter:get_change_money_toc(RoleID,NewSilverBind,NewSilver),
                            common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE,?ROLE2,?ROLE2_ATTR_CHANGE,ChangeMoneyToc),
                            add_send_p2p_count(RoleID),
                            common_letter:send_letter_package({map_send_p2p,RoleID,RecvID,Text,GoodsList});
                        {aborted,{error,Error}}->
                            R1 = #m_letter_send_toc{succ=false,reason=Error},
                            common_misc:unicast(Line, RoleID, Unique, ?LETTER, ?LETTER_SEND, R1)
                    end;
                false->
                    common_letter:send_letter_package({map_send_p2p,RoleID,RecvID,Text,[]})
            end;
        
        {error,Reason}->
            R2 = #m_letter_send_toc{succ=false,reason=Reason},
            common_misc:unicast(Line, RoleID, Unique, ?LETTER, ?LETTER_SEND, R2)
    end.

%% 扣钱扣物
t_cut_goods_and_money(RoleID,LetterGoodsList)->
    {ok,GoodsList} = mod_bag:delete_goods(RoleID,LetterGoodsList),
    {ok,{NewSilverBind,NewSilver}} = common_letter:t_cut_money(?LETTER_SEND_COST,RoleID),
    {GoodsList,NewSilverBind,NewSilver}.


check_can_send_p2p_letter(RoleID,RecvName,Text,LetterGoodsList)->
    %%  检查发送次数    
    case check_send_p2p_count(RoleID) of
        false->throw({error,"今天发送信件已达上限"});
        true->next
    end,
    %%  检查对方是否存在    
    RecvID =
        case common_misc:get_roleid(RecvName) of
            0->throw({error,"该玩家不存在"});
            RecvID1->RecvID1
        end,
    %%  检查信件长度
    case length(Text) of
        Length when Length>?LIMIT_LETTER_LENGTH->
            throw({error,"信件内容太长"});
        0->
            throw({error,"信件内容不能为空"});
        _->
            next
    end,
    %%  检查是否有物品
    case LetterGoodsList=:=[] of
        true->
            throw({ok,false,RecvID});
        false->
            next
    end,
    %%   检查是否够钱        
    {ok,RoleAttr} = mod_map_role:get_role_attr(RoleID),
    TotalSilver = RoleAttr#p_role_attr.silver + RoleAttr#p_role_attr.silver_bind,
    case TotalSilver<10 of
        true->
            throw({error, ?_LANG_LETTER_SILVER_NOT_ENOUGH_WHEN_SEND_LETTER_WHEN_ACH});
        false->
            {ok,true,RecvID}
    end.

add_send_p2p_count(RoleID)->
    {NewDate,NewCount} = 
    case get({?ROLE_SEND_COUNT,RoleID}) of
        {Date,Count}->
            case Date =:=common_tool:date_format() of
                true->
                    {Date,Count+1};
                false ->
                    {common_tool:date_format(),1}
            end;
        _->{common_tool:date_format(),1}
    end,
    put({?ROLE_SEND_COUNT,RoleID},{NewDate,NewCount}).

%% 检查发信次数
check_send_p2p_count(RoleID)->
    case get({?ROLE_SEND_COUNT,RoleID}) of
        {Date,Count}->
            common_tool:date_format()=/=Date orelse Count<?LIMIT_SEND_LETTER_COUNT ;
        _->true
    end.


%% ====================end 玩家发送个人信件 ===================

%% ====================start 玩家获取物品 ========================
%% LetterAttr:atom() public|personal
%% LetterID:int() 
%% LetterLog:tuple() r_letter_log
accept_goods({LetterAttr,LetterID,LetterLog})->
    if is_record(LetterLog,r_letter_log) ->
           accept_goods2(LetterAttr,LetterID,LetterLog);
       true->
           ?ERROR_MSG("获取信件失败~n",[])
    end.
accept_goods2(LetterAttr,LetterID,LetterLog)-> 
    GoodsList = LetterLog#r_letter_log.goods,
    RecvID= LetterLog#r_letter_log.target_role_id,
    case db:transaction(
           fun() ->
                   %% 后台赠送物品需要扩展属性
                   GoodsList1 = transform_goods_for_gm_present(GoodsList), 
                   {ok,GoodsList2} = mod_bag:create_goods_by_p_goods(RecvID,GoodsList1),
                   LetterLog1 = 
                       LetterLog#r_letter_log{goods=mod_exchange:gen_json_goods_list(GoodsList2),
                                              time=common_tool:now()},
                   
                   {GoodsList2,LetterLog1}
           end) 
        of
        {atomic,{NewGoodsList,NewLetterLog}}->
            %% 写道具流向日志
            common_general_log_server:log_letter(NewLetterLog),
            %% 写道具使用记录
            lists:foreach(
              fun(Goods) ->
                      #p_goods{roleid=RoleID,current_num=Num}=Goods,
                      common_item_logger:log(RoleID,Goods,Num,?LOG_ITEM_TYPE_XIN_JIAN_FU_JIAN_HUO_DE)
              end,GoodsList),
            %% 通知前端
            R = #m_letter_accept_goods_toc{succ=true,
                                           goods_list=[],
                                           goods_take=NewGoodsList},
            common_misc:unicast({role,RecvID}, ?DEFAULT_UNIQUE, ?LETTER, ?LETTER_ACCEPT_GOODS, R),
            %% 通知世界节点
            common_letter:send_letter_package({map_accept_goods,{LetterAttr,LetterID,RecvID}});
        {aborted,Error}->
            ?ERROR_MSG("提取物品错误：~w~n",[Error]),
            R = #m_letter_accept_goods_toc{succ = false, reason = "提取物品错误"},
            common_misc:unicast({role,RecvID}, ?DEFAULT_UNIQUE, ?LETTER, ?LETTER_ACCEPT_GOODS, R)
    end.


%% 真不想这么干的,后台赠送装备的时候怎么就不把扩展属性加上嘞!?
%% 暂时先留着，等有空了再收拾

%%@doc 需要赠送的装备计算扩展属性
transform_equips_expand( #p_goods{type=?TYPE_EQUIP}= Goods )->
    mod_equip:creat_equip_expand(Goods,present);
transform_equips_expand( OtherGoods )->
    OtherGoods.

%%@doc 判断物品列表是否为GM后台赠送所得,并对装备处理扩展属性
transform_goods_for_gm_present(GoodsList)->
    [#p_goods{bagid=BagID}|_T] = GoodsList,
    %% 9999表示后台赠送,只是临时值
    case (BagID =:= 9999)  of
        true->
           [ transform_equips_expand(Goods) ||Goods<-GoodsList ];
        false->
            GoodsList
    end.

%% =========================end 玩家获取物品 ========================

    
get_send_count_data(RoleID) ->
    get({?ROLE_SEND_COUNT,RoleID}).


set_send_count_data(RoleID,Data) ->
    case Data of
        {_,_} ->
            erlang:put({?ROLE_SEND_COUNT,RoleID},Data);
        _ ->
            Date = common_tool:date_format(),
            erlang:put({?ROLE_SEND_COUNT,RoleID},{Date,0})
    end.
