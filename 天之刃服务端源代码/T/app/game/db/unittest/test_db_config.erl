%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(test_db_config).
-include("mnesia.hrl").
-include("all_pb.hrl").


%%
%% Include files
%%


%%%%%%%%%%%%%%%%% 友情提示
%% gen_defines()用于生成表定义文件
%% gen_config()用于生成 db.config

%%
%% Exported Functions
%%
-export([]).
-compile(export_all).
-define( INFO(F,D),io:format(F, D) ).
-define( GET_ATTRS(Rec),get_attrs(Rec,record_info(fields,Rec)) ).

gen_defines()->
    Bytes = io_lib:format("~p", [table_defines()]),
    file:write_file("/data/table_defines.txt", list_to_binary(Bytes) ),
    ok.

gen_config()->
    List = db_loader:define_table_mapping(),
    FilePath = "/data/mtzr/config/db/db.config",
    file:delete(FilePath),
    lists:foreach(fun(E)-> 
                          {PTab,MTab} = case E of
                                            {P1,P2} ->
                                                {P1,P2};
                                            {P1,P2,_}->
                                                {P1,P2}
                                        end,
                          NodeType = get_node_type(PTab),
                          RecordName = mnesia:table_info(PTab,record_name),
                          TabType = mnesia:table_info(PTab,type),
                          Bytes = io_lib:format("~w.~n~n", [{MTab,PTab,TabType,NodeType,RecordName}]),
                          file:write_file(FilePath, list_to_binary(Bytes),[append] ) 
                  end, List).

get_node_type(PTab)->
    Login = db_loader:define_table_mapping(login),
    Chat = db_loader:define_table_mapping(chat),
    Map = db_loader:define_table_mapping(map),
    World = db_loader:define_table_mapping(world),
    
    case lists:keyfind(PTab, 1, Login) of
        false->
            case lists:keyfind(PTab, 1, Chat) of
                false->
                    case lists:keyfind(PTab, 1, Map) of
                        false->
                            case lists:keyfind(PTab, 1, World) of
                                false->
                                    undefined;
                                _ ->world
                            end;
                        _ ->map
                    end;
                _ ->chat
            end;
        _ ->
            login
    end.
    
    


bag_table_defines()->
	[{db_friend_p,?GET_ATTRS(r_friend)},
	 {db_chat_channel_roles_p,?GET_ATTRS(p_chat_channel_role_info)},
	 {db_chat_role_channels_p,?GET_ATTRS(r_chat_role_channel_info)},
	 {db_family_invite_p,?GET_ATTRS(p_family_invite_info)},
	 {db_family_request_p,?GET_ATTRS(p_family_request_info)}
	].

%%
%% API Functions
%%
table_defines()->
    [{db_role_faction_p,?GET_ATTRS(r_role_faction)},
     {db_account_p,?GET_ATTRS(r_account)},
     {t_log_super_item,?GET_ATTRS(p_goods)},
     {db_role_attr_p,?GET_ATTRS(p_role_attr)},
     {db_role_base_p,?GET_ATTRS(p_role_base)},
     {db_role_fight_p,?GET_ATTRS(p_role_fight)},
     {db_role_pos_p,?GET_ATTRS(p_role_pos)},
     {db_role_ext_p,?GET_ATTRS(p_role_ext)},
     {db_roleid_counter_p,?GET_ATTRS(r_roleid_counter)},
     {db_monster_persistent_info_p,?GET_ATTRS(r_monster_persistent_info)},
     {db_monsterid_couter_p,?GET_ATTRS(r_monsterid_counter)},
     {db_role_state_p,?GET_ATTRS(r_role_state)},
     {db_stall_p,?GET_ATTRS(r_stall)},
     {db_stall_silver_p,?GET_ATTRS(r_stall_silver)},
     {db_stall_goods_p,?GET_ATTRS(r_stall_goods)},
     {db_stall_goods_tmp_p,?GET_ATTRS(r_stall_goods)},
     {goods_map_p,?GET_ATTRS(p_goods)},
     {db_role_bag_p,?GET_ATTRS(r_role_bag)},
     {role_buffs_p,?GET_ATTRS(r_role_buf)},

     {letter_sender_p,?GET_ATTRS(r_letter_sender)},
     {letter_receiver_p,?GET_ATTRS(r_letter_receiver)},
     {db_bank_sheets_p,?GET_ATTRS(p_bank_sheet)},
     {db_bank_sell_p,?GET_ATTRS(r_bank_sell)},
     {db_bank_buy_p,?GET_ATTRS(r_bank_buy)},
     {db_sheet_counter_p,?GET_ATTRS(r_sheet_counter)},
     {db_shortcut_bar_p,?GET_ATTRS(r_shortcut_bar)},
     {db_broadcast_message_p,?GET_ATTRS(r_broadcast_message)},
     {db_family_p,?GET_ATTRS(p_family_info)},
     {db_family_ext_p,?GET_ATTRS(r_family_ext)},
     {db_family_summary_p,?GET_ATTRS(p_family_summary)},
     {db_family_counter_p,?GET_ATTRS(r_family_counter)},
     {db_chat_channels_p,?GET_ATTRS(p_channel_info)},
     {db_role_educate_p,?GET_ATTRS(r_educate_role_info)},
     {db_fcm_data_p,?GET_ATTRS(r_fcm_data)},
     {db_key_process,?GET_ATTRS(r_key_process)},
     {db_system_config_p,?GET_ATTRS(r_sys_config)},
     {db_role_level_rank_p,?GET_ATTRS(p_role_level_rank)},
     {db_normal_title_p,?GET_ATTRS(p_title)},
     {db_spec_title_p,?GET_ATTRS(p_title)},
     {db_title_counter_p,?GET_ATTRS(r_title_counter)},
     {db_role_pkpoint_rank_p,?GET_ATTRS(p_role_pkpoint_rank)},
     {db_role_world_pkpoint_rank_p,?GET_ATTRS(p_role_pkpoint_rank)},
     {db_family_active_rank_p,?GET_ATTRS(p_family_active_rank)},
     {db_equip_refining_rank_p,?GET_ATTRS(p_equip_rank)},
     {db_equip_reinforce_rank_p,?GET_ATTRS(p_equip_rank)},
     {db_equip_stone_rank_p,?GET_ATTRS(p_equip_rank)},
     {db_role_gongxun_rank_p,?GET_ATTRS(p_role_gongxun_rank)},
     {db_family_gongxun_persistent_rank_p,
      ?GET_ATTRS(p_family_gongxun_persistent_rank)},
     {db_ban_user_p,?GET_ATTRS(r_ban_user)},
     {db_ban_ip_p,?GET_ATTRS(r_ban_ip)},
     {db_warofking_history_p,?GET_ATTRS(r_warofking_history)},
     {db_warofking_history_index_p,?GET_ATTRS(r_warofking_history_index)},
     {db_training_camp_p,?GET_ATTRS(r_training_camp)},
     {db_pay_log_p,?GET_ATTRS(r_pay_log)},
     {db_pay_log_index_p,?GET_ATTRS(r_pay_log_index)},
     {db_faction_p,?GET_ATTRS(p_faction)},
     {?DB_ROLE_VIP_P,?GET_ATTRS(p_role_vip)},
     {?DB_PET,?GET_ATTRS(p_pet)},
     {?DB_ROLE_PET_RANK,?GET_ATTRS(p_role_pet_rank)},
     {?DB_ROLE_GIVE_FLOWERS_YESTERDAY_RANK,?GET_ATTRS(p_role_give_flowers_yesterday_rank)},
     {?DB_ROLE_RECE_FLOWERS_YESTERDAY_RANK,?GET_ATTRS(p_role_rece_flowers_yesterday_rank)}
    ].


get_attrs(Record,Fields)->
	AttrList = [ {R,int} || R<-Fields],
	[{type, set},
	 {record_name,Record},
 	{attributes, AttrList }].