%%% -------------------------------------------------------------------
%%% Author  : Luo.JCheng
%%% Description :
%%%
%%% Created : 2010-7-9
%%% -------------------------------------------------------------------
-module(mod_shortcut).

-include("mgeem.hrl").

-export([handle/1, shortcut_init/2]).

handle({Unique, Module, ?SHORTCUT_UPDATE, DataIn, RoleID, Line}) ->
    do_update(Unique, Module, ?SHORTCUT_UPDATE, DataIn, RoleID, Line);

handle({_Unique, _Module, _Method, _DataIn, _RoleID, _Line}) ->
    ?ERROR_MSG("mod_shortcut, unknow method", []).

%%初始化快捷栏。。。
shortcut_init(RoleID, Line) ->
    case catch db:dirty_read(?DB_SHORTCUT_BAR, RoleID) of
        [ShortcutInfo] ->
            #r_shortcut_bar{shortcut_list=ShortcutList, selected=Selected} = ShortcutInfo,

            DataRecord = #m_shortcut_init_toc{shortcut_list=ShortcutList, selected=Selected},
            common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE, ?SHORTCUT, ?SHORTCUT_INIT, DataRecord);
        [] ->
            DataRecord = #m_shortcut_init_toc{shortcut_list=[], selected=0},
            common_misc:unicast(Line, RoleID, ?DEFAULT_UNIQUE, ?SHORTCUT, ?SHORTCUT_INIT, DataRecord);
        _ ->
            ?ERROR_MSG("shortcut_init, system_error", []),
            ok
    end.

%%快捷栏更新
do_update(_Unique, _Module, _Method, DataIn, RoleID, _Line) ->
    #m_shortcut_update_tos{shortcut_list=ShortcutList, selected=Selected} = DataIn,

    case if_illegal(ShortcutList) of
        true ->
            ShortcutInfo = #r_shortcut_bar{roleid=RoleID, shortcut_list=ShortcutList, selected=Selected},

            %%脏写就可以了
            catch db:dirty_write(?DB_SHORTCUT_BAR, ShortcutInfo);
        false ->
            ok
    end.      

if_illegal(ShortcutList) ->
    lists:all(
      fun(Shortcut) ->
              is_record(Shortcut, p_shortcut)
      end, ShortcutList).
