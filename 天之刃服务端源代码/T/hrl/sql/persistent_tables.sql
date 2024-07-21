
-- ----------------------------
-- Table structure for `db_role_faction_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_faction_p` (
  `faction_id` int default NULL,
  `number` int default NULL,
  PRIMARY KEY  (`faction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_account_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_account_p` (
  `account_name` varchar(50) default NULL,
  `create_time` int default NULL,
  `role_num` int default NULL,
  PRIMARY KEY  (`account_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_base_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_base_p` (
  `role_id` int default NULL,
  `role_name` varchar(50) default NULL,
  `account_name` varchar(50) default NULL,
  `sex` int default NULL,
  `create_time` int default NULL,
  `status` int default NULL,
  `head` int default NULL,
  `faction_id` int default NULL,
  `team_id` int default NULL,
  `family_id` int default NULL,
  `family_name` varchar(50) default NULL,
  `max_hp` int default NULL,
  `max_mp` int default NULL,
  `str` int default NULL,
  `int2` int default NULL,
  `con` int default NULL,
  `dex` int default NULL,
  `men` int default NULL,
  `base_str` int default NULL,
  `base_int` int default NULL,
  `base_con` int default NULL,
  `base_dex` int default NULL,
  `base_men` int default NULL,
  `remain_attr_points` int default NULL,
  `pk_title` int default NULL,
  `max_phy_attack` int default NULL,
  `min_phy_attack` int default NULL,
  `max_magic_attack` int default NULL,
  `min_magic_attack` int default NULL,
  `phy_defence` int default NULL,
  `magic_defence` int default NULL,
  `hp_recover_speed` int default NULL,
  `mp_recover_speed` int default NULL,
  `luck` int default NULL,
  `move_speed` int default NULL,
  `attack_speed` int default NULL,
  `erupt_attack_rate` int default NULL,
  `no_defence` int default NULL,
  `miss` int default NULL,
  `double_attack` int default NULL,
  `phy_anti` int default NULL,
  `magic_anti` int default NULL,
  `cur_title` varchar(100) default NULL,
  `cur_title_color` varchar(50) default NULL,
  `pk_mode` int default NULL,
  `pk_points` int default NULL,
  `last_gray_name` int default NULL,
  `if_gray_name` tinyint default NULL,
  `weapon_type` int default NULL,
  `buffs` blob default NULL,
  `phy_hurt_rate` int default NULL,
  `magic_hurt_rate` int default NULL,
  `disable_menu` blob default NULL,
  `dizzy` int default NULL,
  `poisoning` int default NULL,
  `freeze` int default NULL,
  `hurt` int default NULL,
  `poisoning_resist` int default NULL,
  `dizzy_resist` int default NULL,
  `freeze_resist` int default NULL,
  `hurt_rebound` int default NULL,
  `achievement` int default NULL,
  `equip_score` int default NULL,
  `spec_score_one` int default NULL,
  `spec_score_two` int default NULL,
  `hit_rate` int default NULL,
  `account_type` int default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_attr_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_attr_p` (
  `role_id` int default NULL,
  `role_name` varchar(50) default NULL,
  `next_level_exp` bigint default NULL,
  `exp` bigint default NULL,
  `level` int default NULL,
  `five_ele_attr` int default NULL,
  `last_login_location` varchar(50) default NULL,
  `equips` blob default NULL,
  `jungong` int default NULL,
  `charm` int default NULL,
  `couple_id` int default NULL,
  `couple_name` int default NULL,
  `skin` blob default NULL,
  `cur_energy` int default NULL,
  `max_energy` int default NULL,
  `remain_skill_points` int default NULL,
  `gold` int default NULL,
  `gold_bind` int default NULL,
  `silver` int default NULL,
  `silver_bind` int default NULL,
  `show_cloth` tinyint default NULL,
  `moral_values` int default NULL,
  `gongxun` int default NULL,
  `last_login_ip` varchar(30) default NULL,
  `office_id` int default NULL,
  `office_name` varchar(50) default NULL,
  `unbund` tinyint default NULL,
  `family_contribute` int default NULL,
  `active_points` int default NULL,
  `category` int default NULL,
  `show_equip_ring` tinyint default NULL,
  `is_payed` tinyint default NULL,
  `sum_prestige` bigint default NULL,
  `cur_prestige` bigint default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_ext_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_ext_p` (
  `role_id` int default NULL,
  `signature` varchar(255) default NULL,
  `birthday` int default NULL,
  `constellation` int default NULL,
  `country` int default NULL,
  `province` int default NULL,
  `city` int default NULL,
  `blog` varchar(255) default NULL,
  `family_last_op_time` int default NULL,
  `last_login_time` int default NULL,
  `last_offline_time` int default NULL,
  `role_name` varchar(50) default NULL,
  `sex` int default NULL,
  `ever_leave_xsc` tinyint(1) default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_level_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_level_rank_p` (
  `role_id` int default NULL,
  `role_name` varchar(50) default NULL,
  `faction_id` int default NULL,
  `family_name` varchar(50) default NULL,
  `level` int default NULL,
  `ranking` int default NULL,
  `title` varchar(255) default NULL,
  `exp` bigint default NULL,
  `category` int default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_pkpoint_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_pkpoint_rank_p` (
  `role_id` int default NULL,
  `role_name` varchar(50) default NULL,
  `faction_id` int default NULL,
  `family_name` varchar(50) default NULL,
  `ranking` int default NULL,
  `title` varchar(255) default NULL,
  `pk_points` int default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_world_pkpoint_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_world_pkpoint_rank_p` (
  `role_id` int default NULL,
  `role_name` varchar(50) default NULL,
  `faction_id` int default NULL,
  `family_name` varchar(50) default NULL,
  `ranking` int default NULL,
  `title` varchar(255) default NULL,
  `pk_points` int default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_family_active_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_family_active_rank_p` (
  `family_id` int default NULL,
  `family_name` varchar(50) default NULL,
  `owner_role_name` varchar(50) default NULL,
  `level` int default NULL,
  `ranking` int default NULL,
  `member_count` int default NULL,
  `active` int default NULL,
  `faction_id` int default NULL,
  PRIMARY KEY  (`family_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_gongxun_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_gongxun_rank_p` (
  `role_id` int default NULL,
  `role_name` varchar(50) default NULL,
  `faction_id` int default NULL,
  `family_name` varchar(50) default NULL,
  `level` int default NULL,
  `ranking` int default NULL,
  `title` varchar(255) default NULL,
  `exp` bigint default NULL,
  `gongxun` int default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_family_gongxun_persistent_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_family_gongxun_persistent_rank_p` (
  `key` int default NULL,
  `family_id` int default NULL,
  `total_gongxun` int default NULL,
  `ranking` int default NULL,
  `date` int default NULL,
  PRIMARY KEY  (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_normal_title_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_normal_title_p` (
  `id` int default NULL,
  `name` varchar(50) default NULL,
  `type` int default NULL,
  `auto_timeout` tinyint(1) default NULL,
  `timeout_time` int default NULL,
  `role_id` int default NULL,
  `show_in_chat` tinyint(1) default NULL,
  `show_in_sence` tinyint(1) default NULL,
  `color` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_category_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_category_p` (
  `role_id` int default NULL,
  `category` int default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_educate_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_educate_p` (
  `roleid` int default NULL,
  `faction_id` int default NULL,
  `level` int default NULL,
  `sex` int default NULL,
  `title` int default NULL,
  `name` varchar(50) default NULL,
  `exp_gifts1` int default NULL,
  `exp_gifts2` int default NULL,
  `exp_devote1` int default NULL,
  `exp_devote2` int default NULL,
  `moral_values` int default NULL,
  `teacher` int default NULL,
  `teacher_name` varchar(50) default NULL,
  `students` blob default NULL,
  `student_num` int default NULL,
  `max_student_num` int default NULL,
  `expel_time` int default NULL,
  `dropout_time` int default NULL,
  `online` tinyint default NULL,
  `apprentice_level` int default NULL,
  `release_info` blob default NULL,
  PRIMARY KEY  (`roleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_give_flowers_yesterday_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_give_flowers_yesterday_rank_p` (
  `role_id` int default NULL,
  `ranking` int default NULL,
  `role_name` varchar(50) default NULL,
  `level` int default NULL,
  `score` int default NULL,
  `family_id` int default NULL,
  `family_name` varchar(50) default NULL,
  `faction_id` int default NULL,
  `title` varchar(255) default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_rece_flowers_yesterday_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_rece_flowers_yesterday_rank_p` (
  `role_id` int default NULL,
  `ranking` int default NULL,
  `role_name` varchar(50) default NULL,
  `level` int default NULL,
  `charm` int default NULL,
  `family_id` int default NULL,
  `family_name` varchar(50) default NULL,
  `faction_id` int default NULL,
  `title` varchar(255) default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_pet_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_pet_rank_p` (
  `pet_id` int default NULL,
  `pet_type_name` varchar(50) default NULL,
  `role_id` int default NULL,
  `ranking` int default NULL,
  `role_name` varchar(50) default NULL,
  `level` int default NULL,
  `color` int default NULL,
  `understanding` int default NULL,
  `score` int default NULL,
  `faction_id` int default NULL,
  `title` varchar(50) default NULL,
  PRIMARY KEY  (`pet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_pet_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_pet_p` (
  `pet_id` int default NULL,
  `type_id` int default NULL,
  `role_id` int default NULL,
  `role_name` varchar(50) default NULL,
  `hp` int default NULL,
  `max_hp` int default NULL,
  `pet_name` varchar(50) default NULL,
  `color` int default NULL,
  `understanding` int default NULL,
  `sex` int default NULL,
  `pk_mode` int default NULL,
  `bind` tinyint default NULL,
  `mate_id` int default NULL,
  `mate_name` varchar(50) default NULL,
  `level` int default NULL,
  `exp` bigint default NULL,
  `life` int default NULL,
  `generated` int default NULL,
  `buffs` blob default NULL,
  `str` int default NULL,
  `int2` int default NULL,
  `con` int default NULL,
  `dex` int default NULL,
  `men` int default NULL,
  `base_str` int default NULL,
  `base_int2` int default NULL,
  `base_con` int default NULL,
  `base_dex` int default NULL,
  `base_men` int default NULL,
  `remain_attr_points` int default NULL,
  `phy_defence` int default NULL,
  `magic_defence` int default NULL,
  `phy_attack` int default NULL,
  `magic_attack` int default NULL,
  `double_attack` int default NULL,
  `hit_rate` int default NULL,
  `miss` int default NULL,
  `attack_speed` int default NULL,
  `equip_score` int default NULL,
  `spec_score_one` int default NULL,
  `spec_score_two` int default NULL,
  `attack_type` int default NULL,
  `period` int default NULL,
  `skills` tinyblob default NULL,
  `title` varchar(50) default NULL,
  `max_hp_aptitude` int default NULL,
  `phy_defence_aptitude` int default NULL,
  `magic_defence_aptitude` int default NULL,
  `phy_attack_aptitude` int default NULL,
  `magic_attack_aptitude` int default NULL,
  `double_attack_aptitude` int default NULL,
  `get_tick` int default NULL,
  `next_level_exp` bigint default NULL,
  `state` int default NULL,
  `max_hp_grow_add` int default NULL,
  `phy_defence_grow_add` int default NULL,
  `magic_defence_grow_add` int default NULL,
  `phy_attack_grow_add` int default NULL,
  `magic_attack_grow_add` int default NULL,
  `max_skill_grid` int default NULL,
  PRIMARY KEY  (`pet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_vip_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_vip_p` (
  `role_id` int default NULL,
  `end_time` int default NULL,
  `total_time` int default NULL,
  `vip_level` int default NULL,
  `multi_exp_times` int default NULL,
  `accumulate_exp_times` int default NULL,
  `mission_transfer_times` int default NULL,
  `is_transfer_notice_free` tinyint default NULL,
  `is_transfer_notice` tinyint default NULL,
  `last_reset_time` int default NULL,
  `is_expire` tinyint default NULL,
  `pet_training_times` int default NULL,
  `remote_depot_num` int default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_fcm_data_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_fcm_data_p` (
  `account` varchar(50) default NULL,
  `card` varchar(50) default NULL,
  `truename` varchar(50) default NULL,
  `offline_time` int default NULL,
  `total_online_time` int default NULL,
  `passed` tinyint default NULL,
  PRIMARY KEY  (`account`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_pay_log_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_pay_log_p` (
  `id` int default NULL,
  `order_id` varchar(20000) default NULL,
  `role_id` int default NULL,
  `role_name` varchar(50) default NULL,
  `account_name` varchar(50) default NULL,
  `pay_time` int default NULL,
  `pay_gold` int default NULL,
  `pay_money` int default NULL,
  `year` int default NULL,
  `month` int default NULL,
  `day` int default NULL,
  `hour` int default NULL,
  `role_level` int default NULL,
  `is_first` tinyint default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_pay_log_index_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_pay_log_index_p` (
  `id` int default NULL,
  `value` int default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_equip_refining_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_equip_refining_rank_p` (
  `goods_id` tinyblob default NULL,
  `role_name` varchar(50) default NULL,
  `type_id` int default NULL,
  `colour` int default NULL,
  `quality` int default NULL,
  `ranking` int default NULL,
  `faction_id` int default NULL,
  `refining_score` int default NULL,
  `reinforce_score` int default NULL,
  `stone_score` int default NULL,
  `role_id` int default NULL,
  PRIMARY KEY  (`ranking`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_rece_flowers_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_rece_flowers_rank_p` (
  `role_id` int default NULL,
  `ranking` int default NULL,
  `role_name` varchar(50) default NULL,
  `level` int default NULL,
  `charm` int default NULL,
  `family_id` int default NULL,
  `family_name` varchar(50) default NULL,
  `faction_id` int default NULL,
  `title` varchar(255) default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `db_role_give_flowers_rank_p`
-- ----------------------------

CREATE TABLE IF NOT EXISTS `db_role_give_flowers_rank_p` (
  `role_id` int default NULL,
  `ranking` int default NULL,
  `role_name` varchar(50) default NULL,
  `level` int default NULL,
  `score` int default NULL,
  `family_id` int default NULL,
  `family_name` varchar(50) default NULL,
  `faction_id` int default NULL,
  `title` varchar(255) default NULL,
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
