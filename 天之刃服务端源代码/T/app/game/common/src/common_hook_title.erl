%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2010, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 20 Oct 2010 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(common_hook_title).
-include("common.hrl").

%% API
-export([
         exchange_title_name/5,
         delete/2,
         change/1,
         change_role_cur_title/4
        ]).

%%玩家每种称号的名称改变以后
exchange_title_name(RoleID,_OldTitleName,NewTitleName,NewTitleColor,TitleID) ->
    change_role_cur_title(RoleID, TitleID, NewTitleName, NewTitleColor).

%%删除玩家摸个称号以后
delete(RoleID,_TitleName) ->
    change_role_cur_title(RoleID, undefined, undefined, undefined).

%%某个玩家的称号发生了改变
change(RoleID) ->
    %%聊天称号变化
    ChatTitles = common_title:get_role_chat_titles(RoleID),
    catch global:send(common_misc:chat_get_role_pname(RoleID), {update_title, ChatTitles}),
    common_title:send_sence_titles(RoleID),
    ok.

%% @doc 变更角色的当前称号，如果角色在线的话发消息到地图，不在的话直接脏操作数据库，暂时这样处理
change_role_cur_title(RoleID, TitleID, TitleName, TitleColor) ->
    case common_misc:is_role_online(RoleID) of
        true ->
            common_misc:send_to_rolemap(RoleID, {mod_map_role,
                                                 {change_cur_title, RoleID, TitleID, TitleName, TitleColor}}),
            change(RoleID);
        _ ->
            {ok, RoleBase} = common_misc:get_dirty_role_base(RoleID),
            #p_role_base{cur_title=CurTitle} = RoleBase,
            
            case TitleName =:= CurTitle of
                true ->
                    ignore;
                _ ->
                    RoleBase2 = RoleBase#p_role_base{cur_title=TitleName, cur_title_color=TitleColor},
                    db:dirty_write(?DB_ROLE_BASE, RoleBase2)
            end
    end.
