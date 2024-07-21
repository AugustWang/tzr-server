-module(common_ranking).

-include("common.hrl").

-export([get_level_rank_record/2,
         get_gongxun_rank_record/2,
         get_pkpoint_rank_record/1,
         get_rece_flowers_rank_record/2,
         get_rece_flowers_today_rank_record/3,
         get_give_flowers_rank_record/3,
         get_give_flowers_today_rank_record/3]).

%%===============================================================
get_level_rank_record(RoleBase,RoleAttr)->
    #p_role_level_rank{role_id = RoleBase#p_role_base.role_id,
                       level = RoleAttr#p_role_attr.level,
                       exp =RoleAttr#p_role_attr.exp,
                       role_name = RoleBase#p_role_base.role_name,
                       faction_id = RoleBase#p_role_base.faction_id,
                       family_name =  RoleBase#p_role_base.family_id,
                       category = RoleAttr#p_role_attr.category}.

get_gongxun_rank_record(RoleBase,RoleAttr)->
    #p_role_gongxun_rank{role_id = RoleBase#p_role_base.role_id,
                         level = RoleAttr#p_role_attr.level,
                         exp =RoleAttr#p_role_attr.exp,
                         gongxun = RoleAttr#p_role_attr.gongxun,
                         role_name = RoleBase#p_role_base.role_name,
                         faction_id = RoleBase#p_role_base.faction_id,
                         family_name =  RoleBase#p_role_base.family_id}.

get_pkpoint_rank_record(RoleBase)->
    #p_role_pkpoint_rank{role_id = RoleBase#p_role_base.role_id,
                         pk_points = RoleBase#p_role_base.pk_points,
                         role_name = RoleBase#p_role_base.role_name,
                         faction_id = RoleBase#p_role_base.faction_id,
                         family_name = RoleBase#p_role_base.family_id}.

get_rece_flowers_rank_record(RoleBase,RoleAttr)->
    #p_role_rece_flowers_rank{role_id=RoleBase#p_role_base.role_id,
                              role_name = RoleBase#p_role_base.role_name,
                              level = RoleAttr#p_role_attr.level,
                              charm = RoleAttr#p_role_attr.charm,
                              faction_id = RoleBase#p_role_base.faction_id,
                              family_id = RoleBase#p_role_base.family_id,
                              family_name = RoleBase#p_role_base.family_name}.

get_rece_flowers_today_rank_record(RoleBase,RoleAttr,AddCharm)->
    #p_role_rece_flowers_today_rank{role_id = RoleBase#p_role_base.role_id,
                                    role_name = RoleBase#p_role_base.role_name,
                                    level = RoleAttr#p_role_attr.level,
                                    charm = AddCharm,
                                    faction_id = RoleBase#p_role_base.faction_id,
                                    family_id = RoleBase#p_role_base.family_id,
                                    family_name = RoleBase#p_role_base.family_name}.

get_give_flowers_rank_record(RoleBase,RoleAttr,NewScore)->
        #p_role_give_flowers_rank{role_id = RoleBase#p_role_base.role_id,
                                  role_name = RoleBase#p_role_base.role_name,
                                  level = RoleAttr#p_role_attr.level,
                                  score = NewScore,
                                  faction_id = RoleBase#p_role_base.faction_id,
                                  family_id = RoleBase#p_role_base.family_id,
                                  family_name = RoleBase#p_role_base.family_name}.

get_give_flowers_today_rank_record(RoleBase,RoleAttr,AddScore)->
    #p_role_give_flowers_today_rank{role_id = RoleBase#p_role_base.role_id,
                                    role_name = RoleBase#p_role_base.role_name,
                                    level = RoleAttr#p_role_attr.level,
                                    score = AddScore,
                                    faction_id = RoleBase#p_role_base.faction_id,
                                    family_id = RoleBase#p_role_base.family_id,
                                    family_name = RoleBase#p_role_base.family_name}.

