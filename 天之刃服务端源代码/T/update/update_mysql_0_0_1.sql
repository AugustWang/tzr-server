
#====================2011-07-18@ by caochuncheng begin ====================== 
ALTER TABLE `db_role_attr_p` ADD `sum_prestige` bigint DEFAULT NULL COMMENT '玩家总获得的声望值' AFTER `is_payed`;
ALTER TABLE `db_role_attr_p` ADD `cur_prestige` bigint DEFAULT NULL COMMENT '玩家当前的声望值' AFTER `sum_prestige`;
#====================2011-07-18@ by caochuncheng end   ====================== 
#====================2011-08-29@ by caochuncheng begin ====================== 
drop table db_role_skill_p;
#====================2011-08-29@ by caochuncheng end ====================== 
#==================by luojincheng @2011-08-06 bengin================

CREATE TABLE IF NOT EXISTS `db_stall_list` (
  `id` int(11) NOT NULL COMMENT '数据id',
  `role_id` int(11) DEFAULT NULL COMMENT '角色id',
  `goods_id` int(11) DEFAULT NULL COMMENT '道具id',
  `typeid` int(11) DEFAULT NULL COMMENT '道具类型id',
  `category` int(11) DEFAULT NULL COMMENT '市场类型id',
  `sub_category` int(11) DEFAULT NULL COMMENT '市场子类型id',
  `level` int(11) DEFAULT NULL COMMENT '道具等级',
  `num` int(11) DEFAULT NULL COMMENT '道具数量',
  `price` int(11) DEFAULT NULL COMMENT '道具价格',
  `price_type` int(11) DEFAULT NULL COMMENT '价格类型',
  `color` int(11) DEFAULT NULL COMMENT '道具颜色',
  `pro` int(11) DEFAULT NULL COMMENT '道具内外属性',
  PRIMARY KEY (`id`)
)ENGINE=MEMORY DEFAULT CHARSET=utf8;
ALTER TABLE  `db_stall_list` ADD INDEX (  `typeid` );
ALTER TABLE  `db_stall_list` ADD INDEX (  `category` );
ALTER TABLE  `db_stall_list` ADD INDEX (  `sub_category` );
ALTER TABLE  `db_stall_list` ADD INDEX (  `level` );
ALTER TABLE  `db_stall_list` ADD INDEX (  `num` );
ALTER TABLE  `db_stall_list` ADD INDEX (  `price` );
ALTER TABLE  `db_stall_list` ADD INDEX (  `price_type` );
ALTER TABLE  `db_stall_list` ADD INDEX (  `color` );
ALTER TABLE  `db_stall_list` ADD INDEX (  `pro` );

#==================by luojincheng @2011-08-06 end===================

#====================2011-09-06@ by caochuncheng begin ====================== 
ALTER TABLE `db_role_base_p` ADD `account_type` int default '0' COMMENT '帐号类型' AFTER `hit_rate`;
#====================2011-09-06@ by caochuncheng end   ====================== 

INSERT INTO `t_config` (`id`, `ckey`, `ctype`, `cvalue`, `readonly`, `memo`, `example`, `gm`) VALUES  (NULL, 'GUEST', 'boolean', 'false', 0, '是否开启游客模式', 'false', 0);

#====================2011-09-21@ by caisiqiang start   ====================== 

CREATE TABLE IF NOT EXISTS `t_log_shuaqi_fb` (
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
  `dead_times` INT(11) NULL COMMENT '玩家副本死亡次数',
  `in_number` TINYINT(11) NULL COMMENT '进入副本玩家人数',
  `in_role_ids` VARCHAR(128) NULL COMMENT '进入副本玩家id列表',
  `in_role_names` VARCHAR(512) NULL COMMENT '进入副本玩家名称列表',
  `monster_total_number` INT(11)  NULL COMMENT '怪物总数量',
  `monster_born_number` INT(11)  NULL COMMENT '怪物出生数量',
  `monster_dead_number` INT(11)  NULL COMMENT '怪物死亡数量',
  `monster_change_times` INT(11)  NULL COMMENT '怪物改变次数',
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `start_time` (`start_time`),
  KEY `end_time` (`end_time`),
  KEY `fb_type` (`fb_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='刷棋副本日志表';
#====================2011-09-21@ by caisiqiang end   ====================== 

#====================2011-09-23@ by caisiqiang start   ====================== 
CREATE TABLE IF NOT EXISTS `t_guest_info` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `account`  VARCHAR(64)  NULL COMMENT '玩家账号',
  `role_id` INT(11)  NULL COMMENT '玩家id',
  `log_time` INT(11) NULL COMMENT '记录时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='游客进入表';
#====================2011-09-23@ by caisiqiang end   ====================== 


#====================2011-09-24@ by caisiqiang start   ====================== 
DROP TABLE `t_log_pet_training`;

CREATE TABLE IF NOT EXISTS `t_log_pet_training` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pet_id` int(10) unsigned NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `role_id` int(10) unsigned NOT NULL,
  `pet_level` int(10) unsigned NOT NULL COMMENT '宠物等级',
  `training_hours` int(10) unsigned NOT NULL COMMENT '训练时间',
  `training_cost` int(10) unsigned NOT NULL COMMENT '消耗银两',
  `mtime` int(11) unsigned NOT NULL COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `pet_id` (`pet_id`),
  KEY `role_id` (`role_id`),
  KEY `mtime` (`mtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
#====================2011-09-24@ by caisiqiang end   ====================== 