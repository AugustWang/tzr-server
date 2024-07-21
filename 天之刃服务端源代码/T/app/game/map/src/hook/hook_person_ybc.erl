%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% @copyright (C) 2011, QingliangCn
%%% @doc
%%%
%%% @end
%%% Created : 19 Jun 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(hook_person_ybc).

-include("mgeem.hrl").

%% API
-export([
         finish/2
        ]).

%%%===================================================================
%%% API
%%%===================================================================

finish(RoleID, _Color) ->
    %% 特殊任务
    %% 特殊任务事件
    ?TRY_CATCH(hook_mission_event:hook_special_event(RoleID,?MISSON_EVENT_PERSON_YBC),MissionEventErr),
    %% ?TRY_CATCH( common_mod_goal:hook_ybc_color_change(RoleID, Color) ),
    ok.
                        
