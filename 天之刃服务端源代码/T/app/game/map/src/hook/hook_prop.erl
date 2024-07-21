%%% -------------------------------------------------------------------
%%% Author  : xiaosheng
%%% Description : 得到道具/销毁道具
%%%
%%% Created : 2010-6-28
%%% -------------------------------------------------------------------
-module(hook_prop).
-export([
         hook/2
        ]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("mgeem.hrl").


%% --------------------------------------------------------------------
%% Function: hook/1
%% Description: hook检查口
%% Parameter: record() PGoodsRecord #p_goods
%% Parameter: int() NumChange 数量改变 正/负数
%% Returns: ok
%% --------------------------------------------------------------------
%%检查
hook(decreate, PropList) ->
    ?TRY_CATCH( hook_mission(prop_decreate, PropList) );

hook(shop_buy, PropList) ->
    ?TRY_CATCH( hook_mission(prop_shop_buy, PropList) );

hook(create, PropList) ->
    ?TRY_CATCH( hook_mission(prop_create, PropList) ).

%% ====================================================================
%% 第三方hook代码放置在此
%% ====================================================================

%%触发任务更新
hook_mission(Type, PropList) ->
    Result = 
        lists:foldl(
            fun(PropInfo, _Result) ->
          
                #p_goods{type = PropType2, 
                    typeid = PropTypeID2,
                    roleid = RoleID2
                } = PropInfo,
                {RoleID2, PropType2, PropTypeID2}
            
            end, false, PropList),
    
    case Result of
        {RoleID, _PropType, PropTypeID} ->
            Msg =  {mod_mission_handler, {listener_dispatch, Type, RoleID, PropTypeID}},
            common_misc:send_to_rolemap(RoleID, Msg);
        false ->
            ignore
    end.
