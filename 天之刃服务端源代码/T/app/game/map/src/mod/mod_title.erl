%% Author: liuwei
%% Created: 2010-6-21
%% Description: TODO: Add description to mod_skill
-module(mod_title).

-include("mgeem.hrl").

-export([
         handle/1
        ]).


%%==================API  function================================================
handle({Unique, ?TITLE, Method, DataRecord, RoleID, Line}) ->
    case Method of
        ?TITLE_CHANGE_CUR_TITLE ->
            do_change_cur_title(Unique,DataRecord, RoleID, Line);
        _ ->
            nil
    end.




%%================First Level Local Function=====================================
do_change_cur_title(Unique, DataRecord, RoleID, Line) ->
    TitleID = DataRecord#m_title_change_cur_title_tos.id,
    
    case common_transaction:transaction(fun() -> t_set_role_cur_title(RoleID,TitleID) end) of
        {aborted, Reason} when is_binary(Reason) ->
            Data = #m_title_change_cur_title_toc{succ=false,reason=Reason,id=TitleID},
            common_misc:unicast(Line, RoleID, Unique, ?TITLE, ?TITLE_CHANGE_CUR_TITLE, Data);
        {aborted, Reason} ->
            ?ERROR_MSG("do_change_cur_title, error: ~w", [Reason]),
            Data = #m_title_change_cur_title_toc{succ=false,reason=?_LANG_SYSTEM_ERROR,id=TitleID},
            common_misc:unicast(Line, RoleID, Unique, ?TITLE, ?TITLE_CHANGE_CUR_TITLE, Data);
	{atomic, {TitleName, TitleColor}} ->
            Data = #m_title_change_cur_title_toc{succ=true,id=TitleID,color=TitleColor},
            common_misc:unicast(Line, RoleID, Unique, ?TITLE, ?TITLE_CHANGE_CUR_TITLE, Data),
            mod_map_role:do_update_map_role_info(RoleID, [{#p_map_role.cur_title, TitleName}, {#p_map_role.cur_title_color, TitleColor}], mgeem_map:get_state())
    end.

%%设置玩家当前在地图中显示的称号的名字
t_set_role_cur_title(RoleID,TitleID) ->
    case TitleID of
        0 ->
            {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
            mod_map_role:set_role_base(RoleID, RoleBase#p_role_base{cur_title=undefined,cur_title_color=undefined}),
            {undefined,undefined};
        _ ->
            SenceTitles = common_title:get_role_sence_titles(RoleID),
            case lists:keyfind(TitleID,#p_title.id,SenceTitles) of
                false ->
                    common_transaction:abort(?_LANG_TITLE_NOT_EXIST);
                TitleInfo ->
                    {ok, RoleBase} = mod_map_role:get_role_base(RoleID),
                    #p_title{name = TitleName, color = Color} = TitleInfo,
                    mod_map_role:set_role_base(RoleID, RoleBase#p_role_base{cur_title=TitleName,cur_title_color=Color}),
                    {TitleInfo#p_title.name,TitleInfo#p_title.color}
            end
    end.
