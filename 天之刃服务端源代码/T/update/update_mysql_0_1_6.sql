
#0.1.6版本升级脚本
#====================2011-10-17@ by caisiqiang start   ====================== 
CREATE TABLE IF NOT EXISTS t_log_exercise_fb (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `role_id` INT(11)  NULL COMMENT '玩家id',
  `role_name` VARCHAR(64)  NULL COMMENT '玩家名称',
  `faction_id` TINYINT(1)  NULL COMMENT '国家',
  `level` INT(11)  NULL COMMENT '级别',
  `team_id` INT(11)  NULL COMMENT '队伍 id',
  `status` TINYINT(2) NULL COMMENT '状态',
  `times` TINYINT(2) NULL COMMENT '副本次数',
  `start_time` INT(11) NULL COMMENT '副本时间',
  `end_time` INT(11) NULL COMMENT '副本时间',
  `fb_type` INT(11) NULL COMMENT '副本类型',
  `monster_level` INT(11) NULL COMMENT '怪物等级',
  `in_number` TINYINT(11) NULL COMMENT '进入副本玩家人数',
  `in_role_ids` VARCHAR(128) NULL COMMENT '进入副本玩家id列表',
  `in_role_names` VARCHAR(512) NULL COMMENT '进入副本玩家名称列表',
  `monster_total_number` INT(11)  NULL COMMENT '怪物总数量',
  `monster_born_number` INT(11)  NULL COMMENT '怪物出生数量',
  `monster_dead_number` INT(11)  NULL COMMENT '怪物死亡数量',
  `cur_pass_id` INT(11)  NULL COMMENT '当前第几个出生点',
  `cur_born_times` INT(11)  NULL COMMENT '当前第几批怪物',
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `start_time` (`start_time`),
  KEY `end_time` (`end_time`),
  KEY `fb_type` (`fb_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='练功房副本日志表';
#====================2011-10-17@ by caisiqiang end   ====================== 