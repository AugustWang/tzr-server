%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     test for config
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(test_config).

%%
%% Include files
%%
%%
%% Include files
%%
 
-define( INFO(F,D),io:format(F, D) ).
-compile(export_all).
-include("common.hrl").

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%


t_item()->
	ItemFile = common_config:get_world_config_file_path(item),
    {ok,_ItemList} = file:consult(ItemFile),

    ExtendBagFile = common_config:get_world_config_file_path(extend_bag),
    {ok, _ExtendList} = file:consult(ExtendBagFile),
	
    GiftFile = common_config:get_world_config_file_path(gift),
    {ok, _GiftList} = file:consult(GiftFile),
    BigHpMpFile = common_config:get_world_config_file_path(bighpmp),
    {ok, _BigHpMpList} = file:consult(BigHpMpFile),

    ItemCDFile = common_config:get_world_config_file_path(item_cd),

    {ok, [_ItemCD]} = file:consult(ItemCDFile),

    MoneyFile = common_config:get_map_config_file_path(money),
    {ok, _MoneyList} = file:consult(MoneyFile),
	
	ok.

t_educate() ->
    {ok,N} = common_misc:get_max_role_id(),
    io:format("Max Role Id:~w~n",[N]),
    t_educate1(N).

t_educate1(0) ->
     io:format("ok!");
t_educate1(H) ->
    case (H rem 100) =:= 0 of
        true ->
            timer:sleep(100);
        false ->
            next
    end,
    case catch db:dirty_read(db_role_educate,H) of
        [_] ->
            next;
        _ ->
            case catch {db:dirty_read(db_role_attr,H),
                        db:dirty_read(db_role_base,H)} of
                {[RoleAttr],[RoleBase]} ->
                    Info =  #r_educate_role_info{
                      roleid = H,
                      faction_id = RoleBase#p_role_base.faction_id,
                      level = RoleAttr#p_role_attr.level,
                      title = 0,
                      name = RoleBase#p_role_base.role_name,
                      exp_gifts1 = 0,
                      exp_gifts2 = 0,
                      exp_devote1 = 0,
                      exp_devote2 = 0,
                      moral_values = 0,
                      teacher = undefined,
                      students = [],
                      student_num = 0,
                      max_student_num = 0, 
                      expel_time = 0,
                      dropout_time = 0,
                      online = false,
                      apprentice_level=0},
                    R = (catch db:dirty_write(db_role_educate,Info)),
                    io:format("role_id:~w insert data :~w~n",[H,R]);
                _ ->
                    next
            end
    end,
    t_educate1(H-1).

 
   
