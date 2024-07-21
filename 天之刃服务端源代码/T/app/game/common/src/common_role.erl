%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2010, 
%%% @doc
%%%
%%% @end
%%% Created : 21 Dec 2010 by  <>
%%%-------------------------------------------------------------------
-module(common_role).

-include("common.hrl").
-include("common_server.hrl").

%% API
-export([
         on_transaction_begin/0,
         on_transaction_rollback/0,
         on_transaction_commit/0,
         is_in_role_transaction/0,
         update_role_id_list_in_transaction/3,
         get_state_string/1
        ]).


%%%===================================================================
%%% API
%%%===================================================================
on_transaction_begin() ->
    erlang:put(?role_id_list_in_transaction, []),
    case erlang:get(?mod_map_role_transaction_flag) of
        undefined ->
            erlang:put(?mod_map_role_transaction_flag, true),
            ok;
        _ ->
            %% 禁止嵌套事务
            erlang:throw({nesting_transaction, mod_map_role})
    end,
    ok.

on_transaction_rollback() ->
    lists:foreach(
      fun({RoleId, Key, KeyBk}) ->
              DataBk = erlang:get({KeyBk, RoleId}),
              erlang:put({Key, RoleId}, DataBk),
              erlang:erase({KeyBk, RoleId})
      end, erlang:get(?role_id_list_in_transaction)),
    erlang:erase(?mod_map_role_transaction_flag),
    erlang:erase(?role_id_list_in_transaction).

on_transaction_commit() ->
    lists:foreach(
      fun({RoleId, _Key, KeyBk}) ->
              erlang:erase({KeyBk, RoleId})
      end, erlang:get(?role_id_list_in_transaction)),

    erlang:erase(?mod_map_role_transaction_flag),
    erlang:erase(?role_id_list_in_transaction).

is_in_role_transaction() ->
    case erlang:get(?mod_map_role_transaction_flag) of
        undefined ->
            false;
        _ ->
            true
    end.

update_role_id_list_in_transaction(RoleId, Key, KeyBk) ->
    case erlang:get(?role_id_list_in_transaction) of
        undefined ->
            erlang:throw({error, not_in_transaction});
        BkList ->
            case lists:member({RoleId, Key, KeyBk}, BkList) of
                true ->
                    ignore;
                _ ->
                    erlang:put(?role_id_list_in_transaction, [{RoleId, Key, KeyBk}|BkList]),
                    case erlang:get({Key, RoleId}) of
                        undefined ->
                            ignore;
                        Value ->
                            erlang:put({KeyBk, RoleId}, Value)
                    end
            end
    end.

get_state_string(Status) ->
    case Status of
        ?ROLE_STATE_ZAZEN ->
            ?_LANG_ROLE_STATE_ZAZEN_STRING;
        ?ROLE_STATE_TRAINING ->
            ?_LANG_ROLE_STATE_TRAINING_STRING;
        ?ROLE_STATE_DEAD ->
            ?_LANG_ROLE_STATE_DEAD_STRING;
        ?ROLE_STATE_STALL_SELF ->
            ?_LANG_ROLE_STATE_STALL_SELF_STRING;
        ?ROLE_STATE_STALL_AUTO ->
            ?_LANG_ROLE_STATE_STALL_AUTO_STRING;
        ?ROLE_STATE_YBC_FAMILY ->
            ?_LANG_ROLE_STATE_YBC_FAMILY_STRING;
        ?ROLE_STATE_NORMAL ->
            ?_LANG_ROLE_STATE_NORMAL_STRING;
        ?ROLE_STATE_FIGHT ->
            ?_LANG_ROLE_STATE_FIGHT_STRING;
        ?ROLE_STATE_EXCHANGE ->
            ?_LANG_ROLE_STATE_EXCHANGE_STRING;
        ?ROLE_STATE_COLLECT ->
            ?_LANG_ROLE_STATE_COLLECT_STRING;
        _ ->
            <<>>
    end.
