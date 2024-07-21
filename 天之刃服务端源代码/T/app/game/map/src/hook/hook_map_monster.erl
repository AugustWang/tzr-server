%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     怪物的相关hook，包括怪物死亡
%%%     问题1：如果队员打怪，是否会调用到这里的hook？
%%% @end
%%% Created : 2011-6-18
%%%-------------------------------------------------------------------
-module(hook_map_monster).

-include("mgeem.hrl").

%% API
-export([
         monster_dead/3,
         monster_change/0
        ]).

%%%===================================================================
%%% API
%%%===================================================================
monster_dead(KillerRoleID, MonsterInfo, MonsterBaseInfo) when is_record(MonsterInfo,p_monster)->
    #p_monster{monsterid=MonsterID, typeid=TypeID} = MonsterInfo,
    #p_monster_base_info{rarity=Rarity, monstername=MonsterName,level=MonsterLevel} = MonsterBaseInfo,
    
    ?TRY_CATCH( mod_hero_fb:hook_monster_dead(MonsterBaseInfo),Err1 ),
    ?TRY_CATCH( mod_mission_fb:hook_monster_dead(MonsterBaseInfo),Err2 ),
    ?TRY_CATCH( mod_scene_war_fb:hook_monster_dead({TypeID, MonsterName, Rarity,MonsterLevel}),Err3 ),
    ?TRY_CATCH( mod_family_collect:hook_monster_dead(TypeID),Err4 ),
    %%传奇目标
    ?TRY_CATCH( common_mod_goal:hook_monster_dead(KillerRoleID, TypeID),Err5 ),
    ?TRY_CATCH( mod_monster_addition:hook_monster_dead(MonsterID, TypeID) ),
    ?TRY_CATCH( mod_shuaqi_fb:hook_monster_dead(),Err6),
    ?TRY_CATCH( mod_exercise_fb:hook_monster_dead(),Err7),
    ok.
        
monster_change()->
    ?TRY_CATCH( mod_shuaqi_fb:hook_monster_change(),Err1),
    ok.
