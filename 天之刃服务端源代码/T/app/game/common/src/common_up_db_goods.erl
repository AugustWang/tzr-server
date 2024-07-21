-module(common_up_db_goods).
-export([up_stone_info/0,
         up_equip_info/0,
         up_mount_move_and_vogue_equip/0,
         up_equip_level_info/0,
         reclac_equip_recoup_stone/0,
         pet_act/0,
         rare_act/0,
         up_p_goods_structure/0,
         reclac_equip_refining_index/0
        ]).

-include("common.hrl").
-include("common_server.hrl").

%% 更新mnesia数据库中的物品信息（以后增加mnesia表中包涵p_goods,按以下方式添加到这个函数的后面）
update_db_p_goods(UpFunc)when is_function(UpFunc, 1)  ->
    %%背包
    List1 = db:dirty_match_object(db_role_bag_p, #r_role_bag{_='_'}),
    lists:foreach(
      fun(#r_role_bag{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> UpFunc(Goods) end, GL),
              db:dirty_write(db_role_bag_p, R#r_role_bag{bag_goods=NGL})
      end,List1),
    %%门派仓库
    List2 = db:dirty_match_object(db_family_depot_p, #r_family_depot{_='_'}),
    lists:foreach(
      fun(#r_family_depot{bag_goods=GL}=R) ->
              NGL=lists:map(fun(Goods) -> UpFunc(Goods) end, GL),
              db:dirty_write(db_family_depot, R#r_family_depot{bag_goods=NGL})
      end,List2),
    %%摆摊
    List3 = db:dirty_match_object(db_stall_goods_p, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = UpFunc(Goods),
              db:dirty_write(db_stall_goods, R#r_stall_goods{goods_detail=NewGoods})
      end,List3),
    List4 = db:dirty_match_object(db_stall_goods_tmp_p, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}=R) ->
              NewGoods = UpFunc(Goods),
              db:dirty_write(db_stall_goods_tmp, R#r_stall_goods{goods_detail=NewGoods})
      end,List4),
    %%信件
    List5 = db:dirty_match_object(db_personal_letter_p, #r_personal_letter{_='_'}),
    lists:foreach(
      fun(#r_personal_letter{goods_list=GL}=R) ->
              NGL = lists:map(fun(Goods) -> UpFunc(Goods) end, GL),
              db:dirty_write(db_personal_letter_p, R#r_personal_letter{goods_list=NGL})
      end,List5),
    List6 = db:dirty_match_object(db_public_letter_p, #r_public_letter{_='_'}),
    lists:foreach(
      fun(#r_public_letter{letterbox=GL}=R) ->
              NGL = 
                  lists:map(
                    fun(#r_letter_detail{goods_list = GoodsList} = RR) -> 
                            GoodsList2 = lists:map(fun(Goods) -> UpFunc(Goods) end, GoodsList),
                            RR#r_letter_detail{goods_list = GoodsList2}
                    end,GL),
              db:dirty_write(db_public_letter_p, R#r_public_letter{letterbox=NGL})
      end,List6),
    %%角色身上的装备
    List7 = db:dirty_match_object(db_role_attr_p, #p_role_attr{_='_'}),
    lists:foreach(
      fun(#p_role_attr{equips=GL}=R) ->
              NGL=lists:map(fun(Goods) -> UpFunc(Goods) end, GL),
              db:dirty_write(db_role_attr, R#p_role_attr{equips=NGL})
      end,List7),
    %% 玩家奖励道具
    List8 = db:dirty_match_object(db_role_gift_p, #r_role_gift{_='_'}),
    lists:foreach(
      fun(#r_role_gift{gifts = Gifts}=R) ->
              case lists:keyfind(1,#r_role_gift_info.gift_type,Gifts) of
                  false ->
                      ignore;
                  #r_role_gift_info{cur_gift = GiftGoodsList} = GiftInfo ->
                      GiftGoodsList2 = lists:map(fun(Goods) -> UpFunc(Goods) end, GiftGoodsList),
                      GiftInfo2=GiftInfo#r_role_gift_info{cur_gift = GiftGoodsList2},
                      Gifts2 = lists:keydelete(1,#r_role_gift_info.gift_type,Gifts),
                      db:dirty_write(db_role_gift, R#r_role_gift{gifts = [GiftInfo2|Gifts2]})
              end
      end,List8),
    %% 玩家箱子
    List9 = db:dirty_match_object(db_role_box_p, #r_role_box{_='_'}),
    lists:foreach(
      fun(#r_role_box{cur_list=CL,all_list=AL,log_list=LL}=R) ->
              NCL = lists:map(fun(Goods) -> UpFunc(Goods) end, CL),
              NAL = lists:map(fun(Goods) -> UpFunc(Goods) end, AL),
              NLL = lists:map(
                      fun(#r_box_goods_log{award_list=AWL}=Log) ->
                              NAWL = lists:map(fun(Goods) -> UpFunc(Goods) end, AWL),
                              Log#r_box_goods_log{award_list=NAWL}
                      end,LL),
              db:dirty_write(db_role_box_p,R#r_role_box{cur_list=NCL,all_list=NAL,log_list=NLL})
      end,List9),
    %% 玩家箱子物品获得记录表
    List10 = db:dirty_match_object(db_box_goods_log_p, #r_box_goods_log{_='_'}),
    lists:foreach(
      fun(#r_box_goods_log{award_list=AWL}=Log) ->
              NAWL = lists:map(fun(Goods) -> UpFunc(Goods) end, AWL),
              db:dirty_write(db_box_goods_log, Log#r_box_goods_log{award_list=NAWL})
      end,List10),
    %% 师徒副本
    List11 = db:dirty_match_object(db_educate_fb_p, #r_educate_fb{_='_'}),
    lists:foreach(
      fun(#r_educate_fb{award_list=AWL}=Log) ->
              NAWL = lists:map(fun(Goods) -> UpFunc(Goods) end, AWL),
              db:dirty_write(db_educate_fb, Log#r_educate_fb{award_list=NAWL})
      end, List11).
              
%% 更新p_goods结构，删除添加字段操作
up_p_goods_structure() ->
    update_db_p_goods(fun up_p_goods_structure2/1).
up_p_goods_structure2(Goods) ->
    case Goods of
        {p_goods,ID,TYPE,ROLEID,BAGPOSITION,CURRENT_NUM,BAGID,SELL_TYPE,SELL_PRICE,TYPEID,BIND,
         START_TIME,END_TIME,CURRENT_COLOUR,STATE,NAME,LEVEL,EMBE_POS,EMBE_EQUIPID,LOADPOSITION,
         QUALITY,CURRENT_ENDURANCE,FORGE_NUM,REINFORCE_RESULT,PUNCH_NUM,STONE_NUM,ADD_PROPERTY,
         STONES,REINFORCE_RATE,ENDURANCE,SIGNATURE,EQUIP_BIND_ATTR,REFINING_INDEX,SIGN_ROLE_ID,
         FIVE_ELE_ATTR,WHOLE_ATTR,REINFORCE_RESULT_LIST,USE_BIND,SUB_QUALITY,QUALITY_RATE} ->
            case TYPE =:= 3 andalso STONES =/= undefined 
                andalso STONES =/= [] andalso erlang:is_list(STONES)
                andalso erlang:length(STONES) > 0 of %%装备宝石处理
                true ->
                    NewSTONES = [up_p_goods_structure2(StoneGoodsA)||StoneGoodsA <- STONES];
                _ ->
                    NewSTONES = STONES
            end,
            {p_goods,ID,TYPE,ROLEID,BAGPOSITION,CURRENT_NUM,BAGID,SELL_TYPE,SELL_PRICE,TYPEID,BIND,
             START_TIME,END_TIME,CURRENT_COLOUR,STATE,NAME,LEVEL,EMBE_POS,EMBE_EQUIPID,LOADPOSITION,
             QUALITY,CURRENT_ENDURANCE,FORGE_NUM,REINFORCE_RESULT,PUNCH_NUM,STONE_NUM,ADD_PROPERTY,
             NewSTONES,REINFORCE_RATE,ENDURANCE,SIGNATURE,EQUIP_BIND_ATTR,REFINING_INDEX,SIGN_ROLE_ID,
             FIVE_ELE_ATTR,WHOLE_ATTR,REINFORCE_RESULT_LIST,USE_BIND,SUB_QUALITY,QUALITY_RATE,0,0,0};
        _ ->
            case Goods#p_goods.type =:= 3 andalso Goods#p_goods.stones =/= undefined 
                andalso Goods#p_goods.stones =/= [] andalso erlang:is_list(Goods#p_goods.stones)
                andalso erlang:length(Goods#p_goods.stones) > 0 of %%装备宝石处理
                true ->
                    StoneGoodsList = [up_p_goods_structure2(StoneGoodsB)||StoneGoodsB <- Goods#p_goods.stones],
                    Goods#p_goods{stones = StoneGoodsList};
                _ ->
                    Goods
            end
    end.
%% 重算装备的精炼系数
reclac_equip_refining_index() ->
    update_db_p_goods(fun reclac_equip_refining_index/1).
reclac_equip_refining_index(#p_goods{type=?TYPE_EQUIP} = EquipGoods) ->
    case common_misc:do_calculate_equip_refining_index(EquipGoods) of
        {ok,EquipGoodsT} ->
            EquipGoodsT;
        _ ->
            EquipGoods
    end;
reclac_equip_refining_index(EquipGoods) ->
    EquipGoods.

%% @doc 更新宝石信息（从配置中读数据直接覆盖原先的字段）
%% 注意：宝石信息更新之后，要去调用up_equip_info/0更新装备信息
up_stone_info() ->
    update_db_p_goods(fun up_stone/1).

up_stone(#p_goods{type=?TYPE_EQUIP,stones=[_|_]=Stones}=Goods) ->
    lists:foldl(
      fun(Stone, #p_goods{stones=OldStones}=Equip) ->
              NewStone = up_stone(Stone),
              Equip#p_goods{stones=[NewStone|OldStones]}
      end,Goods#p_goods{stones=[]},Stones);
up_stone(#p_goods{type=?TYPE_STONE}=Goods) ->
    case common_config_dyn:find(stone, Goods#p_goods.typeid) of
        [] ->
            Goods;
        [#p_stone_base_info{sell_type=SellType,
                            sell_price=SellPrice,
                            stonename=StoneName,
                            colour=InitColour,
                            level=Level}] ->
            Goods#p_goods{current_colour =InitColour,level = Level,
                          sell_type = SellType, sell_price = SellPrice,name=StoneName}
    end;
up_stone(Goods) ->
    Goods.

%% @doc 更新装备信息，重算所有装备属性。
up_equip_info() ->
    update_db_p_goods(fun up_equip/1).

up_equip(#p_goods{type=?TYPE_EQUIP, typeid=TypeID}=Goods) ->
    case common_config_dyn:find_equip(TypeID) of
        [#p_equip_base_info{property=Pro,
                            sell_type=SellType,
                            sell_price=SellPrice, 
                            equipname=Name
                           }=NewEquipInfo] ->
            case NewEquipInfo#p_equip_base_info.slot_num =:= 10
                orelse NewEquipInfo#p_equip_base_info.slot_num =:= 11 
                orelse NewEquipInfo#p_equip_base_info.slot_num =:= 12  of
                true ->
                    Goods;
                _ ->
                    %% 重新赋值属性
                    NewEquipGoods = Goods#p_goods{name=Name,add_property=Pro,sell_type=SellType, sell_price=SellPrice},
                    %% 颜色品质处理
                    NewGoods = mod_refining:equip_colour_quality_add(new,NewEquipGoods,1,1,1),
                    %% 强化处理
                    NewGoods2 = equip_reinforce_property_add(NewGoods,NewEquipInfo),
                    %% 宝石处理
                    NewGoods3 = 
                        if NewGoods2#p_goods.stones =/= undefined ->
                                equip_stone_property_add(NewGoods2);
                           true ->
                                NewGoods2
                        end,
                    %% 绑定处理
                    NewGoods4 = mod_refining_bind:do_equip_bind_for_equip_upgrade(NewGoods3,NewEquipInfo),
                    %% 装备五行属性
                    %% 精炼系数处理
                    NewGoods5 = case common_misc:do_calculate_equip_refining_index(NewGoods4) of
                                    {error,_ErrorCode} ->
                                        NewGoods4;
                                    {ok,RefiningIndexGoods} ->
                                        RefiningIndexGoods
                                end,
                    NewGoods5
            end;
        _ ->
            Goods
    end;
up_equip(Goods) ->
    Goods.

%% 装备强化属性处理
equip_reinforce_property_add(EquipGoods,EquipBaseInfo) ->
    EquipPro = EquipGoods#p_goods.add_property,
    BasePro = EquipBaseInfo#p_equip_base_info.property,
    MainProperty = BasePro#p_property_add.main_property,
    ReinforceRate = EquipGoods#p_goods.reinforce_rate,
    NewEquipPro=mod_refining:change_main_property(MainProperty,EquipPro,BasePro,0,ReinforceRate),
    EquipGoods#p_goods{add_property = NewEquipPro}.
%% 宝石加成处理
equip_stone_property_add(EquipGoods) ->
    Stones = EquipGoods#p_goods.stones,
    equip_stone_property_add2(Stones,EquipGoods).
equip_stone_property_add2([],EquipGoods) ->
    EquipGoods;
equip_stone_property_add2([H|T],EquipGoods) ->
    StoneTypeId = H#p_goods.typeid,
    {ok,StoneBaseInfo} = mod_stone:get_stone_baseinfo(StoneTypeId),
    NewEquipGoods = equip_stone_property_add3(StoneBaseInfo,EquipGoods),
    equip_stone_property_add2(T,NewEquipGoods).

equip_stone_property_add3(StoneBaseInfo,EquipGoods) ->
    EquipPro = EquipGoods#p_goods.add_property,
    StoneBasePro = StoneBaseInfo#p_stone_base_info.level_prop,
    SeatList =
        case equip_stone_property_add4(StoneBasePro#p_property_add.main_property) of
            SeatR when is_integer(SeatR) andalso SeatR > 1 ->
                [SeatR];
            SeatR when is_list(SeatR) ->
                SeatR;
            _ ->
                ?INFO_MSG("~ts,EquipGoods=~w,StoneBaseInfo=~w",["装备升级时，处理宝石数据遇到不可处理的宝石数据",EquipGoods,StoneBaseInfo]),
                []
        end,
    NewEquipPro = lists:foldl(
                    fun(Seat,AccPro) ->
                            Value = erlang:element(Seat, AccPro) + erlang:element(Seat,StoneBasePro),
                            erlang:setelement(Seat, AccPro, Value)
                    end,EquipPro,SeatList),
    EquipGoods#p_goods{add_property = NewEquipPro}.
equip_stone_property_add4(Main) ->
    [List] = common_config_dyn:find(refining,main_property),
    proplists:get_value(Main, List).

up_mount_move_and_vogue_equip() ->
	F = fun(Goods0) ->
				Goods1 = up_mount(Goods0),
				Goods2 = up_vogue(Goods1),
				Goods2
		end,
	update_db_p_goods(F).

up_mount(#p_goods{type=?TYPE_EQUIP,typeid=TypeID, current_colour = Colour} = Goods) ->
    case common_config_dyn:find(mount_level, TypeID) of
        [L] -> 
            case lists:keyfind(Colour, 2, L)of
                false ->
                    Goods;
                #r_mount_level{speed=Speed} ->
                    Goods#p_goods{add_property=#p_property_add{move_speed=Speed, _=0}}
            end;
        _ ->
            Goods
    end;
up_mount(Goods) ->
    Goods.

up_vogue(#p_goods{type=?TYPE_EQUIP,typeid=TypeID} = Goods) ->
	case common_config_dyn:find_equip(TypeID) of
		[#p_equip_base_info{slot_num=11,property=Pro}] ->
			Goods#p_goods{add_property=Pro};
		_ ->
			Goods
	end;
up_vogue(Goods) ->
	Goods.

%% 2011/6/17 更新装备等级，所有装备改为整10级的
up_equip_level_info() ->
	update_db_p_goods(fun up_equip_level/1).

up_equip_level(#p_goods{type=?TYPE_EQUIP,typeid=TypeID} = Goods) ->
	case common_config_dyn:find_equip(TypeID) of
		[#p_equip_base_info{requirement=#p_use_requirement{min_level=MinLevel}}] ->
			Goods#p_goods{level=MinLevel};
		_ ->
			Goods
	end;
up_equip_level(Goods) ->
	Goods.


%% 2011/6/29 重算装备属性和根据不同的宝石做不同的补偿
-define(SL,[21000003,21000004,21000005,21000006,21000009,21100003,21100004,21100005,21100006,21100009,21200003,21200004,21200005,21200006,21200009,21300003,21300004,21300005,21300006,21300009,21400003,21400004,21400005,21400006,21400009,21500003,21500004,21500005,21500006,21500009,21600003,21600004,21600005,21600006,21600009,21700003,21700004,21700005,21700006,21700009,21800003,21800004,21800005,21800006,21800009,21000002,21100002,21200002,21300002,21400002,21500002,21600002,21700002,21800002]).

-define(MULT,4).

-define(LETTER_CON,"亲爱的玩家:\n      商店灵石价格大调整，为了补偿您前期对灵石的投入，根据您当前的4级以上高级灵石持有情况，系统赠送您4倍数量的相同灵石，请注意查收。").

reclac_equip_recoup_stone() ->
    R1 = (catch reclac_equip()),
    R2 = ( catch recoup_stone()),
    ?ERROR_MSG("R1:~w,R1:~w~n",[R1,R2]),
    ok.

reclac_equip() ->
    update_db_p_goods(fun reclac_equip/1).

reclac_equip(Goods) ->
    up_equip(Goods).

recoup_stone() ->
    %%背包
    List1 = db:dirty_match_object(db_role_bag_p, #r_role_bag{_='_'}),
    lists:foreach(
      fun(#r_role_bag{bag_goods=GL}) ->
              lists:foreach(fun(Goods) -> recoup_stone(Goods) end, GL)
      end,List1),
    %%摆摊
    List3 = db:dirty_match_object(db_stall_goods_p, #r_stall_goods{_='_'}),
    lists:foreach(
      fun(#r_stall_goods{goods_detail=Goods}) ->
              recoup_stone(Goods)
      end,List3),
    %%信件
    List5 = db:dirty_match_object(db_personal_letter_p, #r_personal_letter{_='_'}),
    lists:foreach(
      fun(#r_personal_letter{goods_list=GL}) ->
              lists:foreach(fun(Goods) -> recoup_stone(Goods) end, GL)
      end,List5),
    List6 = db:dirty_match_object(db_public_letter_p, #r_public_letter{_='_'}),
    lists:foreach(
      fun(#r_public_letter{letterbox=GL}) ->
              lists:foreach(
                fun(#r_letter_detail{goods_list = GoodsList}) -> 
                        lists:foreach(fun(Goods) -> recoup_stone(Goods) end, GoodsList)
                end,GL)
      end,List6),
    %%角色身上的装备
    List7 = db:dirty_match_object(db_role_attr_p, #p_role_attr{_='_'}),
    lists:foreach(
      fun(#p_role_attr{equips=GL}) ->
              lists:foreach(fun(Goods) -> recoup_stone(Goods) end, GL)
      end,List7),
    List9 = db:dirty_match_object(db_role_box_p, #r_role_box{_='_'}),
    lists:foreach(
      fun(#r_role_box{cur_list=CL,all_list=AL}) ->
              lists:foreach(fun(Goods) -> recoup_stone(Goods) end, CL),
              lists:foreach(fun(Goods) -> recoup_stone(Goods) end, AL)
      end,List9),
    send_recoup().
   

recoup_stone(#p_goods{type=?TYPE_STONE,typeid=TypeID}=Goods) ->
    case lists:member(TypeID,?SL) of
        true ->
            up_recoup(Goods);
        false ->
            ignore
    end,
    Goods;
recoup_stone(Goods) ->
    Goods.

up_recoup(Goods) ->
    case get(recoup_stone) of
        undefined ->
            put(recoup_stone,[Goods]);
        L ->
            put(recoup_stone,[Goods|L])
    end.

get_recoup() ->
    case get(recoup_stone) of
        undefined -> [];
        L -> L
    end.

send_recoup() ->
    L1 = get_recoup(),
    L2 = lists:foldl(
           fun(#p_goods{roleid=RoleID}=Goods,Acc) ->
                   case lists:keytake(RoleID,1,Acc) of
                       false ->
                           [{RoleID,[Goods]}|Acc];
                       {value, {_,GL}, NewAcc} ->
                           [{RoleID,[Goods|GL]}|NewAcc]
                   end
           end,[],L1),
    {ok,S} = file:open("/data/old_recoup_stone.txt",write),
    io:format(S,"~w~n",[L2]),
    file:close(S),
    case global:whereis_name(mgeew_letter_server) of
        undefined->
            {error, "mgeew_letter_server proc Does not exist"};
        _Pid->
            L3 = [{RoleID,allot_recoup(merge_recoup(GL,[]),[])} || {RoleID,GL} <- L2],
            lists:foreach(
              fun({RoleID,GL})when is_integer(RoleID),RoleID > 0 ->
                      lists:foreach(
                        fun(G) ->
                                common_letter:sys2p(RoleID,?LETTER_CON,"灵石补偿",[G],20)
                        end,GL),
                      timer:sleep(300);
                 (_) ->
                      ignore
              end,L3)
    end.
                                      
merge_recoup([],GL) ->
    GL;
merge_recoup([#p_goods{typeid=TypeID,current_num=Num0}=H|T],GL) ->
    case lists:keytake(TypeID,#p_goods.typeid,GL) of
        false ->
            merge_recoup(T, [H#p_goods{current_num=Num0*?MULT}|GL]);
        {value,#p_goods{current_num=Num1}=G,NGL} ->
            merge_recoup(T, [G#p_goods{current_num=Num0*?MULT+Num1}|NGL])
    end.

allot_recoup([],GL) ->
    GL;
allot_recoup([#p_goods{current_num=Num}=H|T],GL) ->
    R1 = Num rem 50,
    R2 = Num div 50,
    L1 = lists:duplicate(R2,H#p_goods{current_num=50}),
    L2 = case R1 =:= 0 of
             true -> L1;
             false -> [H#p_goods{current_num=R1}|L1]
         end,
    allot_recoup(T,lists:append(L2,GL)).
                        


-define(PETL,[]).

pet_act() ->    
    WxSql = io_lib:format("SELECT pet_id,role_id,SUBSTRING_INDEX(action_detail_str,'=',-1) FROM t_log_pet_action WHERE action='103' and mtime<=1309492800  GROUP BY pet_id",[]),
    WmSql = io_lib:format("SELECT pet_id,role_id,pet_type FROM t_log_get_pet WHERE mtime >=1309363200 and mtime<=1309492800 and (pet_type='30051009' or pet_type='30051010' or pet_type='30051019' or pet_type='30051020' or pet_type='30051029' or pet_type='30051030' ) GROUP BY pet_id",[]),
    case mod_mysql:select(WxSql) of
        {ok,WxL} ->
            {ok,S1} = file:open("/data/pet_act_wx_2011_7_1.txt",write),
            io:format(S1,"~w~n",[WxL]),
            file:close(S1),
            wx_pet_act(WxL),
            case mod_mysql:select(WmSql) of
                {ok, WmL} ->
                    {ok,S2} = file:open("/data/pet_act_wm_2011_7_1.txt",write),
                    io:format(S2,"~w~n",[WmL]),
                    file:close(S2),
                    wm_pet_act(WmL);
                Error ->
                    {error,Error}
            end;
        Error ->
            {error, Error}
    end.

wx_pet_act(L) ->
    case catch mnesia:dirty_match_object(db_pet_p,#p_pet{_='_'}) of
        [_|_] = DL ->
            RIDL = [RID || [_,RID,_] <- L],
            NDL = [{Pet#p_pet.role_id,Pet#p_pet.understanding} || Pet <- DL, true =:= lists:member(Pet#p_pet.role_id,RIDL)],
            {LanL,ZhiL,ChengL} =
                lists:foldl(
                  fun({RID,M},{LanAL,ZhiAL,ChengAL}) ->
                          if M > 6 andalso M < 10 ->
                                  {[RID|LanAL],ZhiAL,ChengAL};
                             M > 9 andalso M < 13 ->
                                  {LanAL,[RID|ZhiAL],ChengAL};
                             M > 12 ->
                                  {LanAL,ZhiAL,[RID|ChengAL]};
                             true ->
                                  {LanAL,ZhiAL,ChengAL}
                          end
                  end,{[],[],[]},NDL),
            send_pa_lan_rs(LanL),
            send_pa_zhi_rs(ZhiL),
            send_pa_cheng_rs(ChengL);
        [] ->
            {error, empty};
        Error ->
            {error, Error}
    end.

wm_pet_act(L) ->
    WanMeiL = [RID || [_,RID,_] <- L],
    send_pa_wan_mei_rs(WanMeiL),
    ok.

-define(QLActC,"亲爱的玩家:\n      您好！欢迎参与暑期档--SHOW神兵神宠抢夺稀有道具活动，同时恭喜您领养了强力宠物，获得了丰厚的活动奖励。请注意及时查收！\n").
-define(WMActC,"亲爱的玩家:\n      您好！欢迎参与暑期档--SHOW神兵神宠抢夺稀有道具活动，同时恭喜您领养了完美宠物，获得了丰厚的活动奖励。请注意及时查收！\n").

send_pa_lan_rs(RIDList) ->
    [begin send_pet_act_lan(RID),timer:sleep(50) end || RID <- RIDList].

send_pa_zhi_rs(RIDList) ->
    [begin send_pet_act_zhi(RID),timer:sleep(50) end || RID <- RIDList].

send_pa_cheng_rs(RIDList) ->
    [begin send_pet_act_cheng(RID),timer:sleep(50) end || RID <- RIDList].

send_pa_wan_mei_rs(RIDList) ->
    [begin send_pet_act_wan_mei(RID),timer:sleep(50) end || RID <- RIDList].

send_pet_act_lan(RID) ->
    {ok,GL} = common_bag2:create_item(#r_item_create_info{role_id=RID,num=4,bind=true,typeid=10410002,start_time=0,end_time=0,bag_id=1,bagposition=1}),
    common_letter:sys2p(RID,?QLActC,"暑期档--SHOW神兵神宠抢夺稀有道具",[G#p_goods{id=1} || G <-GL],20).

send_pet_act_zhi(RID) ->
    {ok,GL} = common_bag2:create_item(#r_item_create_info{role_id=RID,num=2,bind=true,typeid=10410003,start_time=0,end_time=0,bag_id=1,bagposition=1}),
    common_letter:sys2p(RID,?QLActC,"暑期档--SHOW神兵神宠抢夺稀有道具",[G#p_goods{id=1} || G <-GL],20).

send_pet_act_cheng(RID) ->
    {ok,GL} = common_bag2:create_item(#r_item_create_info{role_id=RID,num=1,bind=true,typeid=10410004,start_time=0,end_time=0,bag_id=1,bagposition=1}),
    common_letter:sys2p(RID,?QLActC,"暑期档--SHOW神兵神宠抢夺稀有道具",[G#p_goods{id=1} || G <-GL],20).

send_pet_act_wan_mei(RID) ->
    {ok,GL} = common_bag2:create_item(#r_item_create_info{role_id=RID,num=3,bind=true,typeid=10410003,start_time=0,end_time=0,bag_id=1,bagposition=1}),
    common_letter:sys2p(RID,?WMActC,"暑期档--SHOW神兵神宠抢夺稀有道具",[G#p_goods{id=1} || G <-GL],20).


%%------------------------------------------------------------------------------------------------------------------------
rare_act() ->
    collect_rare_roles().

collect_rare_roles() ->
    case catch db:dirty_match_object(db_role_attr,#p_role_attr{_='_'}) of
        [_|_] = RL0 ->
            RL1 = [{R#p_role_attr.role_id,c_rare_eq_sum(R#p_role_attr.equips)} || R <- RL0],
            RL2 = lists:foldl(
                    fun({Rid,Num},Acc) ->
                            [{Rid,lists:foldl(
                                    fun(BagID,AccNum) ->
                                            case catch db:dirty_read(db_role_bag_p,{Rid,BagID}) of
                                                [#r_role_bag{bag_goods=GL}] ->
                                                    AccNum+c_rare_eq_sum(GL);
                                                _ ->
                                                    AccNum
                                            end
                                    end,Num,[1,2,3,4,5,6,7,8,9])}|Acc]
                    end,[],RL1),
            {ok,S1} = file:open("/data/pet_act_rare_2011_7_2.txt",write),
            io:format(S1,"~w~n",[RL2]),
            file:close(S1),
            send_rare_act_s(RL2),
            ok;
        [] ->
            {error, empty};
        Error ->
            {error, Error}
    end.

c_rare_eq_sum([_|_]=GL) ->
    c_rare_eq_sum(GL, 0);
c_rare_eq_sum(_) ->
    0.
c_rare_eq_sum([], Sum) ->
    Sum;
c_rare_eq_sum([#p_goods{type=?TYPE_EQUIP,bind=true,current_colour=C}|T], Sum)when C > 3 ->
    c_rare_eq_sum(T, Sum+1);
c_rare_eq_sum([_|T],Sum) ->
    c_rare_eq_sum(T, Sum).

send_rare_act_s(RidNums) ->
    [begin
         if Num >= 10 ->
                 send_rare_act(Rid,20,3);
            Num >= 7 ->
                 send_rare_act(Rid,15,2);
            Num >= 5 ->
                 send_rare_act(Rid,10,1);
            Num >= 3 ->
                 send_rare_act(Rid,5,1);
            true ->
                 ignore
         end 
     end|| {Rid, Num} <- RidNums].

send_rare_act(Rid,Num1,Num2) ->
    send_rare_act_tiwu(Rid,Num1),
    send_rare_act_wuxing(Rid,Num2),
    timer:sleep(50).

-define(XYActC,"亲爱的玩家:\n      您好！欢迎参与暑期档—SHOW神兵神宠抢夺稀有道具活动，同时恭喜您拥有一身绝世神装，获得了丰厚的活动奖励。请注意及时查收！").
send_rare_act_tiwu(Rid,Num) ->
    {ok,GL} = common_bag2:create_item(#r_item_create_info{role_id=Rid,num=Num,bind=true,typeid=12300123,start_time=0,end_time=0,bag_id=1,bagposition=1}),
    common_letter:sys2p(Rid,?XYActC,"暑期档--SHOW神兵神宠抢夺稀有道具",[G#p_goods{id=1} || G <-GL],20).
send_rare_act_wuxing(Rid,Num) ->
    {ok,GL} = common_bag2:create_item(#r_item_create_info{role_id=Rid,num=Num,bind=true,typeid=12300124,start_time=0,end_time=0,bag_id=1,bagposition=1}),
    common_letter:sys2p(Rid,?XYActC,"暑期档--SHOW神兵神宠抢夺稀有道具",[G#p_goods{id=1} || G <-GL],20).
    
