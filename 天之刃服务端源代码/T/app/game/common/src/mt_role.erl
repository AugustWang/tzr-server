%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     运维瑞士军刀，for role
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(mt_role).

%%
%% Include files
%%
-include("common.hrl").

-compile(export_all).
-define( DEBUG(F,D),io:format(F, D) ).

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%
role_base(RoleName) when is_list(RoleName)->
    role_base( get_roleid(RoleName) );
role_base(RoleID)->
    mt_process:role_d(RoleID,{role_base, RoleID}).

role_attr(RoleName) when is_list(RoleName)->
    role_attr( get_roleid(RoleName) );
role_attr(RoleID)->
    mt_process:role_d(RoleID,{role_attr, RoleID}).

role_team(RoleName) when is_list(RoleName)->
    role_team( get_roleid(RoleName) );
role_team(RoleID)->
    mt_process:role_d(RoleID,{role_team, RoleID}).

role_skill(RoleName) when is_list(RoleName)->
    role_skill( get_roleid(RoleName) );
role_skill(RoleID)->
    mt_process:role_d(RoleID,{role_skill, RoleID}).

role_bag(RoleName,BagId) when is_list(RoleName)->
    role_bag( get_roleid(RoleName),BagId );
role_bag(RoleID,BagId)->
    mt_process:bag_d(RoleID,BagId).

role_map_ext(RoleName) when is_list(RoleName)->
    role_map_ext( get_roleid(RoleName) );
role_map_ext(RoleID)->
    mt_process:role_d(RoleID,{role_map_ext, RoleID}).

role_xfire(RoleName) when is_list(RoleName)->
    role_xfire( get_roleid(RoleName) );
role_xfire(RoleID)->
    mt_process:role_d(RoleID,{role_xfire, RoleID}).


%%@doc 从mnesia中读取脏数据
dirty(RoleName) when is_list(RoleName)->
    dirty( get_roleid(RoleName) );
dirty(RoleID) when is_integer(RoleID)->
    case common_misc:get_dirty_role_base(RoleID) of
    {ok, RoleBase} -> 
        {ok, RoleBase};
    Other-> 
        Other
    end.


get_roleid(RoleName) when is_list(RoleName)->
    common_misc:get_roleid_by_accountname(RoleName).


