%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2010, 
%%% @doc
%%%
%%% @end
%%% Created : 15 Dec 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_equip_onekey).

-include("mgeem.hrl").
-include("equip.hrl").

%% API Func
-export([handle/1]).

%% Test API
-export([
         test_list/1,
         test_info/2,
         test_save/4,
         test_load/2
        ]).

%% 最大套装数目
-define(MAX_EQUIPS_NUM, 8).
%% 套装默认名字
-define(EQUIPS_DEFAULT_NAME, [{1, <<"第一套">>}, {2, <<"第二套">>}, {3, <<"第三套">>}, {4, <<"第四套">>},
                              {5, <<"第五套">>}, {6, <<"第六套">>}, {7, <<"第七套">>}, {8, <<"第八套">>}]).

%% Record defin

%% API Func
handle(Info) ->
    do_handle(Info).

%% Internal Func
do_handle({Unique, Module, ?EQUIPONEKEY_LIST, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_list(Unique, Module, ?EQUIPONEKEY_LIST, DataIn, RoleID, PID);
do_handle({Unique, Module, ?EQUIPONEKEY_INFO, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_info(Unique, Module, ?EQUIPONEKEY_INFO, DataIn, RoleID, PID);
do_handle({Unique, Module, ?EQUIPONEKEY_SAVE, DataIn, RoleID, PID, _Line, _MapState}) ->
    do_save(Unique, Module, ?EQUIPONEKEY_SAVE, DataIn, RoleID, PID);
do_handle({Unique, Module, ?EQUIPONEKEY_LOAD, DataIn, RoleID, PID, Line, _MapState}) ->
    do_load(Unique, Module, ?EQUIPONEKEY_LOAD, DataIn, RoleID, PID, Line);

do_handle(Info) ->
    ?DEBUG("mod_equip_onekey, unknow info: ~w", [Info]).

%% @doc 获取套装列表
do_list(Unique, Module, Method, _DataIn, RoleID, PID) ->
    EquipOneKey = db:dirty_read(?DB_EQUIP_ONEKEY, RoleID),
    case EquipOneKey of
        [] ->
            EquipsList = [];
        [#r_equip_onekey{equips_list=EquipsList}] ->
            ignore
    end,

    EquipsList2 =
        lists:map(
          fun(Equips) ->
                  Equips#p_equip_onekey_info{equips_id_list=[]}
          end, EquipsList),
    ?DEBUG("do_list, equiplist2: ~w", [EquipsList]),

    EquipsList3 =
        lists:foldl(
          fun(EquipsID, Acc) ->
                  case lists:keyfind(EquipsID, #p_equip_onekey_info.equips_id, Acc) of
                      false ->
                          {ok, DefaultEquips} = get_equips_default_info(EquipsID),
                          [DefaultEquips|Acc];
                      _ ->
                          Acc
                  end
          end, EquipsList2, lists:seq(1, ?MAX_EQUIPS_NUM)),
    ?DEBUG("do_list, equiplist3: ~w", [EquipsList3]),

    DataRecord = #m_equiponekey_list_toc{equips_list=EquipsList3},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 查看某套装信息
do_info(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_equiponekey_info_tos{equips_id=EquipsID} = DataIn,

    case db:dirty_read(?DB_EQUIP_ONEKEY, RoleID) of
        [] ->
            EquipsList = [],
            EquipOneKey = #r_equip_onekey{};
        [EquipOneKey] ->
            #r_equip_onekey{equips_list=EquipsList} = EquipOneKey
    end,
    ?DEBUG("do_info, equiplist: ~w", [EquipsList]),

    case lists:keyfind(EquipsID, #p_equip_onekey_info.equips_id, EquipsList) of
        false ->
            %% 如果在列表中找不到就给个默认的
            case get_equips_default_info(EquipsID) of
                {error, Reason} ->
                    DataRecord = #m_equiponekey_info_toc{succ=false, reason=Reason};
                {ok, EquipsInfo} ->
                    DataRecord = #m_equiponekey_info_toc{equips_list=EquipsInfo}
            end;
        EquipsInfo ->
            #p_equip_onekey_info{equips_id_list=EquipsIDList} = EquipsInfo,
            {EquipsInfoList, EquipsIDList2} =
                lists:foldl(
                  fun(EquipSimple, {EqList, EqIDList}) ->
                          #p_equip_onekey_simple{slot_num=SlotNum, equip_id=EquipID} = EquipSimple,
                          %% 在背包以及身上查找，如果找不到的话，就把这项给删了
                          case mod_bag:get_goods_by_id(RoleID, EquipID) of
                              {ok, EquipInfo} ->
                                  EquipInfo2 = EquipInfo#p_goods{loadposition=SlotNum},
                                  {[EquipInfo2|EqList], [EquipSimple|EqIDList]};
                              _ ->
                                  case mod_goods:get_dirty_equip_by_id(RoleID, EquipID) of
                                      {ok, EquipInfo} ->
                                          EquipInfo2 = EquipInfo#p_goods{loadposition=SlotNum},
                                          {[EquipInfo2|EqList], [EquipSimple|EqIDList]};
                                      _ ->
                                          {EqList, EqIDList}
                                  end
                          end
                  end, {[], []}, EquipsIDList),
            ?DEBUG("do_info, equipslist: ~w, equipsidlist: ~w", [EquipsList, EquipsIDList2]),

            %% 如果有的ID找不到了，那么更新数据库
            case EquipsIDList =/= EquipsIDList2 of
                true ->
                    EquipsInfo2 = EquipsInfo#p_equip_onekey_info{equips_id_list=EquipsIDList2},
                    EquipsList2 = [EquipsInfo2|lists:keydelete(EquipsID, #p_equip_onekey_info.equips_id, EquipsList)],
                    EquipOneKey2 = EquipOneKey#r_equip_onekey{equips_list=EquipsList2},
                    db:dirty_write(?DB_EQUIP_ONEKEY, EquipOneKey2);
                _ ->
                    ignore
            end,

            EquipsInfo3 = EquipsInfo#p_equip_onekey_info{equips_list=EquipsInfoList, equips_id_list=[]},
            DataRecord = #m_equiponekey_info_toc{equips_list=EquipsInfo3}
    end,
    ?DEBUG("do_info, datarecord: ~w", [DataRecord]),
    
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%%@doc 过滤掉不能保存的装备，例如坐骑
%%@param    #p_equip_onekey_info
%%@return   #p_equip_onekey_info
do_filter_unsave_equip(Equips) when is_record(Equips,p_equip_onekey_info)->
    #p_equip_onekey_info{equips_id_list=EquipsSaveList} = Equips,
    EquipsSaveList2 = lists:filter(fun(E)->
                                           #p_equip_onekey_simple{slot_num=LoadSlotNum} = E,
                                           LoadSlotNum =/= ?UI_LOAD_POSITION_MOUNT
                                   end, EquipsSaveList),
    Equips#p_equip_onekey_info{equips_id_list=EquipsSaveList2}.
    

%% @doc 保存自定义套装，不做合法性检测，即某个孔位是否可以装备某件物品
do_save(Unique, Module, Method, DataIn, RoleID, PID) ->
    #m_equiponekey_save_tos{equips_list=EquipsArg} = DataIn,
    Equips = do_filter_unsave_equip(EquipsArg),
    
    #p_equip_onekey_info{equips_id=EquipsID, equips_name=EquipsName} = Equips,

    case EquipsID > ?MAX_EQUIPS_NUM orelse EquipsID =< 0 of
        true ->
            DataRecord = #m_equiponekey_save_toc{succ=false, reason=?_LANG_EQUIPONEKEY_EQUIPSID_NOT_EXIST};
        _ ->

            EquipOneKey = db:dirty_read(?DB_EQUIP_ONEKEY, RoleID),
            case EquipOneKey of
                [] ->
                    EquipsOneKey2 = #r_equip_onekey{role_id=RoleID, equips_list=[Equips]};
                [#r_equip_onekey{equips_list=EquipsList}=EOK] ->
                    EquipsOneKey2 = EOK#r_equip_onekey{equips_list=[Equips|lists:keydelete(EquipsID, #p_equip_onekey_info.equips_id, EquipsList)]}
            end,
            db:dirty_write(?DB_EQUIP_ONEKEY, EquipsOneKey2),
            ?DEBUG("do_save, equipsonekey2: ~w", [EquipsOneKey2]),

            DataRecord = #m_equiponekey_save_toc{equips_id=EquipsID, equips_name=EquipsName}
    end,
    ?DEBUG("do_save, datarecord: ~w", [DataRecord]),

    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 一键换装
do_load(Unique, Module, Method, DataIn, RoleID, PID, Line) ->
    #m_equiponekey_load_tos{equips_id=EquipsID} = DataIn,
    
    case db:dirty_read(?DB_EQUIP_ONEKEY, RoleID) of
        [] ->
            EquipsList = [];
        [#r_equip_onekey{equips_list=EquipsList}] ->
            ignore
    end,
    ?DEBUG("do_load, equipslist: ~w", [EquipsList]),

    case lists:keyfind(EquipsID, #p_equip_onekey_info.equips_id, EquipsList) of
        false ->
            case EquipsID > ?MAX_EQUIPS_NUM orelse EquipsID =< 0 of
                true ->
                    do_load_error(Unique, Module, Method, PID, ?_LANG_EQUIPONEKEY_EQUIPSID_NOT_EXIST);
                _ ->
                    do_load2(Unique, Module, Method, RoleID, PID, [], Line)
            end;
        EquipsInfo ->
            #p_equip_onekey_info{equips_id_list=EquipsIDList} = EquipsInfo,
            ?DEBUG("do_load, equipsidlist: ~w", [EquipsIDList]),

            do_load2(Unique, Module, Method, RoleID, PID, EquipsIDList, Line)
    end.

do_load2(Unique, Module, Method, RoleID, PID, EquipsIDList, Line) ->
    lists:foreach(
      fun(EquipSimple) ->
              #p_equip_onekey_simple{slot_num=SlotNum, equip_id=EquipID, equip_typeid=EquipTypeID} = EquipSimple,
              %% 如果已经是穿上身上的就不用再穿了
              case mod_goods:get_equip_by_id(RoleID, EquipID) of
                  {error, _} ->
                      LoadInfo = #m_equip_load_tos{equip_slot_num=SlotNum, equipid=EquipID},
                      mod_equip:do_load(?DEFAULT_UNIQUE, ?EQUIP, ?EQUIP_LOAD, LoadInfo, RoleID, Line, EquipTypeID);
                  _ ->
                      ignore
              end
      end, EquipsIDList),
    
    DataRecord = #m_equiponekey_load_toc{},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

do_load_error(Unique, Module, Method, PID, Reason) ->
    DataRecord = #m_equiponekey_load_toc{succ=false, reason=Reason},
    common_misc:unicast2(PID, Unique, Module, Method, DataRecord).

%% @doc 获取默认的套装属性
get_equips_default_info(EquipsID) ->
    case EquipsID > ?MAX_EQUIPS_NUM orelse EquipsID =< 0 of
        true ->
            {error, ?_LANG_EQUIPONEKEY_EQUIPSID_NOT_EXIST};
        _ ->
            DefaultEquips = #p_equip_onekey_info{equips_id=EquipsID, equips_name=get_equips_default_name(EquipsID)},
            {ok, DefaultEquips}
    end.

%% @doc 获取自定义套装默认名字
get_equips_default_name(EquipsID) ->
    {EquipsID, Name} = lists:keyfind(EquipsID, 1, ?EQUIPS_DEFAULT_NAME),
    Name.


%% Test Func
test_list(RoleID) ->
    do_list(?DEFAULT_UNIQUE, ?EQUIPONEKEY, ?EQUIPONEKEY_LIST, 0, RoleID, 0).

test_info(RoleID, EquipsID) ->
    DataIn = #m_equiponekey_info_tos{equips_id=EquipsID},
    common_misc:send_to_rolemap(RoleID, {?DEFAULT_UNIQUE, ?EQUIPONEKEY, ?EQUIPONEKEY_INFO, DataIn, RoleID, 0, 1}).

test_save(RoleID, EquipsID, EquipsName, EquipsIDList) ->
    EquipList = #p_equip_onekey_info{equips_id=EquipsID, equips_name=EquipsName, equips_id_list=EquipsIDList},
    DataIn = #m_equiponekey_save_tos{equips_list=EquipList},
    do_save(?DEFAULT_UNIQUE, ?EQUIPONEKEY, ?EQUIPONEKEY_SAVE, DataIn, RoleID, 0).

test_load(RoleID, EquipsID) ->
    DataIn = #m_equiponekey_load_tos{equips_id=EquipsID},
    common_misc:send_to_rolemap(RoleID, {?DEFAULT_UNIQUE, ?EQUIPONEKEY, ?EQUIPONEKEY_LOAD, DataIn, RoleID, 0, 1}).
