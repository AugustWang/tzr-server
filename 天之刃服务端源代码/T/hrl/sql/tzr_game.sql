/*
###注意：数据库的完整表结构就只存在tzr_game.sql中。
﻿###     mnesia的对应表结构保存在persistent_tables.sql中,对应索引保存在persistent_indexes.sql中

###########################################################################################
﻿###     各位小朋友记得将升级脚本(包括mnesia持久化表的升级脚本)同步到update目录下的B_beta*_mysql.txt中
###########################################################################################
*/

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

#切换到数据库 tzr_game
use tzr_game;


CREATE TABLE IF NOT EXISTS `t_family_summary` (
  `family_id` int(10) unsigned NOT NULL,
  `family_name` varchar(50) NOT NULL,
  `create_role_id` int(10) unsigned NOT NULL COMMENT '创始人角色ID',
  `create_role_name` varchar(50) NOT NULL,
  `owner_role_id` int(10) unsigned NOT NULL,
  `owner_role_name` varchar(50) NOT NULL,
  `faction_id` int(11) NOT NULL,
  `active_points` int(11) NOT NULL,
  `money` int(11) NOT NULL,
  `cur_members` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `gongxun` int(11) NOT NULL,
  `create_time` int(10) unsigned NOT NULL,
  PRIMARY KEY (`family_id`),
  KEY `cur_members` (`cur_members`),
  KEY `active_points` (`active_points`),
  KEY `level` (`level`),
  KEY `gongxun` (`gongxun`),
  KEY `create_time` (`create_time`),
  KEY `faction_id` (`faction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


## 管理后台帐号密码，管理权限
CREATE TABLE `t_admin_user` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `username` varchar(50) NOT NULL,
  `passwd` varchar(50) NOT NULL,
  `user_power` text NOT NULL,
  `last_login_time` int(11) NOT NULL,
  `groupid` int(10) unsigned NOT NULL,
  `comment` varchar(100) NOT NULL,
  PRIMARY KEY  (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

## 初始化管理用户，账号密码都是 admin 
INSERT INTO `t_admin_user` (`uid` ,`username` ,`passwd` ,`user_power` ,`last_login_time` )
VALUES (NULL , 'admin', MD5( 'admin' ) , '', '0');


-- 元宝使用记录
CREATE TABLE IF NOT EXISTS `t_log_use_gold` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL default '0' COMMENT '角色ID',
  `user_name` varchar(50) NOT NULL default '' COMMENT '角色名称',
  `account_name` varchar(50) NOT NULL default '' COMMENT '登录帐号',
  `level` int(11) NOT NULL default '0' COMMENT '玩家角色级别',
  `gold_bind` int(11) NOT NULL default '0' COMMENT '使用绑定元宝的数量',
  `gold_unbind` int(3) NOT NULL default '0' COMMENT '使用元宝的数量',
  `mtime` int(11) NOT NULL default '0' COMMENT '操作时间',
  `mtype` int(11) NOT NULL default '0' COMMENT '操作类型',
  `mdetail` varchar(1000) NOT NULL default '' COMMENT '操作内容',
  `itemid` int(11) unsigned NOT NULL default '0' COMMENT '涉及的道具ID',
  `amount` int(11) NOT NULL default '0' COMMENT '涉及的道具等的数量',
  PRIMARY KEY  (`id`),
  KEY `user_id` (`user_id`),
  KEY `user_name` (`user_name`),
  KEY `account_name` (`account_name`),
  KEY `gold_bind` (`gold_bind`),
  KEY `gold_unbind` (`gold_unbind`),
  KEY `mtype` (`mtype`),
  KEY `mtime` (`mtime`),
  KEY `itemid` (`itemid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- 银两使用记录
CREATE TABLE IF NOT EXISTS `t_log_use_silver` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL default '0' COMMENT '角色ID',
  `silver_bind` int(11) NOT NULL default '0' COMMENT '使用绑定银两的数量',
  `silver_unbind` int(3) NOT NULL default '0' COMMENT '使用不绑定银两的数量',
  `mtime` int(11) NOT NULL default '0' COMMENT '操作时间',
  `mtype` int(11) NOT NULL default '0' COMMENT '操作类型',
  `mdetail` varchar(1000) NOT NULL default '' COMMENT '操作内容',
  `itemid` int(11) unsigned NOT NULL default '0' COMMENT '涉及的道具ID',
  `amount` int(11) NOT NULL default '0' COMMENT '涉及的道具等的数量',
  PRIMARY KEY  (`id`),
  KEY `user_id` (`user_id`),
  KEY `silver_bind` (`silver_bind`),
  KEY `silver_unbind` (`silver_unbind`),
  KEY `mtype` (`mtype`),
  KEY `mtime` (`mtime`),
  KEY `itemid` (`itemid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='记录玩家银两的获得与使用';

--
-- 数据库: `ming2_game`
--

-- --------------------------------------------------------

--
-- 表的结构 `t_account` 帐号信息
--

CREATE TABLE IF NOT EXISTS `t_account` (
  `account` varchar(100) NOT NULL COMMENT '帐号',
  `role_name` varchar(100) NOT NULL COMMENT '角色名',
  `account_create_dateline` int(10) unsigned NOT NULL COMMENT '帐号初始化时间',
  `account_create_y` smallint(4) unsigned NOT NULL COMMENT '帐号初始化y',
  `account_create_m` tinyint(2) NOT NULL COMMENT '帐号初始化m',
  `account_create_d` tinyint(2) NOT NULL COMMENT '帐号初始化d',
  `account_create_h` tinyint(2) NOT NULL COMMENT '帐号初始化h',
  `role_create_dateline` int(10) unsigned NOT NULL COMMENT '角色初始化时间',
  `role_create_y` smallint(4) unsigned NOT NULL COMMENT '角色初始化y',
  `role_create_m` tinyint(2) NOT NULL COMMENT '角色初始化m',
  `role_create_d` tinyint(2) NOT NULL COMMENT '角色初始化d',
  `role_create_h` tinyint(2) NOT NULL COMMENT '角色初始化h',
  `account_last_dateline` int(10) unsigned NOT NULL COMMENT '帐号最后一次登录的时间',
  `account_last_y` smallint(4) unsigned NOT NULL COMMENT '帐号最后一次登录y',
  `account_last_m` int(11) NOT NULL COMMENT '帐号最后一次登录m',
  `account_last_d` int(11) NOT NULL COMMENT '帐号最后一次登录d',
  `account_last_h` int(11) NOT NULL COMMENT '帐号最后一次登录h',
  `role_last_dateline` int(10) unsigned NOT NULL COMMENT '角色最后一次登录时间',
  `role_last_y` smallint(4) unsigned NOT NULL COMMENT '角色最后一次登录y',
  `role_last_m` tinyint(2) NOT NULL COMMENT '角色最后一次登录m',
  `role_last_d` tinyint(2) NOT NULL COMMENT '角色最后一次登录d',
  `role_last_h` tinyint(2) NOT NULL COMMENT '角色最后一次登录h',
  `account_login_times` int(10) unsigned NOT NULL COMMENT '帐号登录次数',
  `role_login_times` int(10) unsigned NOT NULL COMMENT '角色登录次数',
  `last_ip` char(30) NOT NULL COMMENT '最后一次的ip',
  `status` tinyint(2) NOT NULL COMMENT '状态 1正常 2进制登录',
  PRIMARY KEY  (`account`),
  UNIQUE KEY `role_name` (`role_name`,`role_last_y`,`role_last_m`,`role_last_d`,`role_last_h`),
  KEY `account_create_y` (`account_create_y`,`account_create_m`,`account_create_d`,`account_create_h`,`role_create_y`,`role_create_m`,`role_create_d`,`role_create_h`,`account_last_y`,`account_last_m`,`account_last_d`,`account_last_h`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `t_log_online` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `online` int(10) unsigned NOT NULL COMMENT '在线数量',
  `dateline` int(11) NOT NULL,
  `week_day` tinyint(4) NOT NULL,
  `year` int(11) NOT NULL,
  `month` int(11) NOT NULL,
  `day` int(11) NOT NULL,
  `hour` int(11) NOT NULL,
  `min` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `year` (`year`),
  KEY `week_day` (`week_day`),
  KEY `dateline` (`dateline`),
  KEY `month` (`month`),
  KEY `day` (`day`),
  KEY `hour` (`hour`),
  KEY `min` (`min`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='玩家在线日志表';


--
-- Table structure for table `t_log_admin`
--
CREATE TABLE IF NOT EXISTS `t_log_admin` (
  `id` int(11) NOT NULL auto_increment,
  `admin_id` int(11) NOT NULL default '0' COMMENT '管理员ID',
  `admin_name` varchar(50) NOT NULL default '' COMMENT '管理员帐号名',
  `admin_ip` varchar(15) NOT NULL default '',
  `user_id` int(11) NOT NULL default '0' COMMENT '操作的角色ID',
  `user_name` varchar(50) NOT NULL default '',
  `mtime` int(11) NOT NULL default '0',
  `mtype` int(11) NOT NULL default '0' COMMENT '操作类型',
  `mdetail` text NOT NULL COMMENT '操作内容',
  `number` int(11) NOT NULL default '0' COMMENT '数量',
  `desc` varchar(5000) NOT NULL default '' COMMENT '详细使用说明',
  PRIMARY KEY  (`id`),
  KEY `admin_id` (`admin_id`),
  KEY `admin_name` (`admin_name`),
  KEY `user_id` (`user_id`),
  KEY `user_name` (`user_name`),
  KEY `mtype` (`mtype`),
  KEY `mtime` (`mtime`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='管理后台的日志表';

--
-- Table structure for table `t_log_item`
--
CREATE TABLE IF NOT EXISTS `t_log_item` (
  `id` int unsigned NOT NULL auto_increment,
  `userid` int unsigned NOT NULL,
  `userlevel` int(11) NOT NULL default '0' COMMENT '用户等级',
  `action` int(11) unsigned NOT NULL COMMENT '操作类型',
  `itemid` int(11) unsigned NOT NULL COMMENT '道具ID(道具合成记录的是entID)',
  `amount` int(11) unsigned NOT NULL COMMENT '个数',
  `equipid` int(11) unsigned NOT NULL COMMENT '如果是装备，则记录装备的唯一ID',
  `color` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '颜色',
  `fineness` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '品质',
  `start_time` int unsigned NOT NULL COMMENT '起始时间',
  `end_time` int unsigned COMMENT '失效时间',
  PRIMARY KEY  (`id`),
  KEY `userid` (`userid`),
  KEY `itemid` (`itemid`),
  KEY `action` (`action`),
  KEY `start_time` (`start_time`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='按周分表，记录道具变动';


#=========start 2010-11-18  ========

CREATE TABLE IF NOT EXISTS `t_user_online` (
  `role_id` int(11) unsigned NOT NULL  COMMENT '用户ID',
  `role_name` varchar(50) NOT NULL COMMENT '角色名',
  `account_name` varchar(50) NOT NULL COMMENT '帐号名',
  `faction_id` int(11) unsigned NOT NULL COMMENT '国家ID',
  `family_id` int(11) unsigned NOT NULL COMMENT '门派ID',
  `login_time` int(11) unsigned NOT NULL COMMENT '登陆时间',
  `login_ip` varchar(15) COMMENT '登陆IP',
  PRIMARY KEY  (`role_id`)
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='在线用户列表';

#=========end	2010-11-18 ========

#=========start 2010-11-19  ========

CREATE TABLE IF NOT EXISTS `t_item_list` (
  `typeid` int(11) NOT NULL COMMENT '类型ID',
  `type` int(11) NOT NULL COMMENT '分类',
  `item_name` varchar(50) NOT NULL default '' COMMENT '道具名称',
  `sell_price` int(11) NOT NULL COMMENT '售卖价格',
  PRIMARY KEY  (`typeid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='系统的道具、宝石、装备的列表';

#=========end	2010-11-19 ========


#=========start 2010-11-20  ========

CREATE TABLE IF NOT EXISTS `t_log_behavior` (
`id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
`role_id` INT( 11 ) NOT NULL ,
`log_time` INT( 11 ) NOT NULL ,
`behavior_type` INT( 11 ) NOT NULL COMMENT '玩家行为类别',
`login_ip` varchar(15) COMMENT '登陆IP',
PRIMARY KEY (  `id` ),
  KEY `role_id` (`role_id`),
  KEY `behavior_type` (`behavior_type`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='玩家行为的日志表，用于统计流失率';

#=========end	2010-11-20 ========

#=========start 2010-11-23  ========

CREATE TABLE IF NOT EXISTS `t_log_exchange` (
  `id` int(11) NOT NULL auto_increment,
  `from_role_id` int(11) NOT NULL,
  `from_role_name` varchar(50) NOT NULL,
  `from_silver` int(11) default NULL,
  `from_goods` varchar(1024) default NULL,
  `to_role_id` int(11) NOT NULL,
  `to_role_name` varchar(50) NOT NULL,
  `to_silver` int(11) default NULL,
  `to_goods` varchar(1024) default NULL,
  `time` int(11) NOT NULL,
  `from_gold` int(10) unsigned default NULL,
  `to_gold` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `from_role_id` (`from_role_id`),
  KEY `to_role_id` (`to_role_id`),
  KEY `from_gold` (`from_gold`,`to_gold`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='玩家交易日志表';


#=========end	2010-11-23 ========

#=========start 2010-11-23  ========

CREATE TABLE IF NOT EXISTS `t_log_letter` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`role_id` INT(11) NOT NULL,
	`role_name` VARCHAR(50) NOT NULL,
	`target_role_id` INT(11) NOT NULL,
	`target_role_name` VARCHAR(50) NOT NULL,
	`goods` VARCHAR(1024) NOT NULL,
	`time` INT(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `target_role_id` (`target_role_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='信件道具提取日志表';

#=========end	2010-11-23 ========


#==========start 2010-11-23 

ALTER TABLE  `t_account` CHANGE  `role_name`  `role_name` VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT  '用户账号';
ALTER TABLE  `t_account` CHANGE  `role_create_dateline`  `role_create_dateline` INT( 10 ) UNSIGNED NULL DEFAULT NULL ;
ALTER TABLE  `t_account` CHANGE  `role_create_y`  `role_create_y` SMALLINT( 4 ) UNSIGNED NULL DEFAULT NULL;
ALTER TABLE  `t_account` CHANGE  `role_create_m`  `role_create_m` SMALLINT( 2 ) UNSIGNED NULL DEFAULT NULL ;
ALTER TABLE  `t_account` CHANGE  `role_create_d`  `role_create_d` SMALLINT( 2 ) UNSIGNED NULL DEFAULT NULL ;
ALTER TABLE  `t_account` CHANGE  `role_create_h`  `role_create_h` SMALLINT( 2 ) UNSIGNED NULL DEFAULT NULL ;
ALTER TABLE  `t_account` CHANGE  `role_last_dateline`  `role_last_dateline` INT( 10 ) UNSIGNED NULL DEFAULT NULL; 
ALTER TABLE  `t_account` CHANGE  `role_last_y`  `role_last_y` SMALLINT( 4) UNSIGNED NULL DEFAULT NULL ;
ALTER TABLE  `t_account` CHANGE  `role_last_m`  `role_last_m` SMALLINT( 2 ) UNSIGNED NULL DEFAULT NULL ;
ALTER TABLE  `t_account` CHANGE  `role_last_d`  `role_last_d` SMALLINT( 2 ) UNSIGNED NULL DEFAULT NULL ;
ALTER TABLE  `t_account` CHANGE  `role_last_h`  `role_last_h` SMALLINT( 2 ) UNSIGNED NULL DEFAULT NULL ;
ALTER TABLE  `t_account` CHANGE  `role_login_times`  `role_login_times` INT( 10 ) UNSIGNED NULL DEFAULT NULL;
ALTER TABLE  `t_account` CHANGE  `last_ip`  `last_ip` CHAR( 30 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;
ALTER TABLE  `t_account` CHANGE  `status`  `status` TINYINT( 2 ) NULL DEFAULT NULL;

#============end 2010-11-23



#=========start 2010-11-26 ========

CREATE TABLE `t_admin_group` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`name` VARCHAR( 50 ) NOT NULL ,
`rule` VARCHAR( 1024 ) NOT NULL ,
`comment` VARCHAR( 200 ) NOT NULL ,
INDEX ( `name` )
) ENGINE = InnoDB ;
#=========end 2010-11-26 ========


#=========start 2010-11-27 ========
## 增加索引
ALTER TABLE `t_log_behavior` ADD INDEX ( `log_time` ) ;

CREATE TABLE `t_log_pay_request` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `payto_user` varchar(100) NOT NULL default '' COMMENT '充值用户名',
  `user_ip` varchar(30) NOT NULL default '' COMMENT '玩家IP',
  `detail` varchar(500) NOT NULL default '' COMMENT '参数内容',
  `desc` varchar(300) NOT NULL default '' COMMENT '备注',
  `mtime` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `payto_user` (`payto_user`),
  KEY `user_ip` (`user_ip`),
  KEY `desc` (`desc`),
  KEY `mtime` (`mtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='充值请求详细日志表';
#=========end 2010-11-26 ========

#=========start 2010-12-01 ========
CREATE TABLE `t_config` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `ckey` varchar(100) NOT NULL COMMENT '配置项KEY',
  `ctype` varchar(100) NOT NULL default 'string' COMMENT '配置项取值类型',
  `cvalue` varchar(2000) NOT NULL COMMENT '配置项当前值',
  `readonly` smallint(2) NOT NULL default '0' COMMENT '配置项状态：0可修改，1只读',
  `memo` varchar(2000) NOT NULL COMMENT '配置项说明',
  `example` varchar(2000) NOT NULL COMMENT '配置项取值举例',
  `gm` smallint(2) NOT NULL default '0' COMMENT 'GM可操作',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='系统配置参数';
#=========end 2010-12-01 ========

#=========start 2010-12-06 ========
INSERT INTO `t_config` VALUES
(NULL, 'OFFICIAL_WEBSITE', 'string', 'http://tzr.mingchao.com', 0, '', '', 0),
(NULL, 'WEB_DOMAIN', 'string', 'www.tzrgame-debug.com', 0, '', '', 0),
(NULL, 'WEB_SITEURL', 'string', 'http://www.tzrgame-debug.com/', 0, '', '', 0),
(NULL, 'WEB_ADMINURL', 'string', 'http://www.tzrgame-debug.com/admin/', 0, '', '', 0),
(NULL, 'WEB_STATIC', 'string', 'http://static.tzrgame-debug.com/', 0, '', '', 0),
(NULL, 'ERLANG_WEB_URL', 'string', 'http://127.0.0.1:8000', 0, '', '', 0),
(NULL, 'PAY_URL', 'string', 'http://web.4399.com/user/select_pay_type.php?gamename=mccq&gameserver=<SERVER_NAME>', 0, '', '', 0),
(NULL, 'BBS_URL', 'string', 'http://bbs.mingchao.com/forum-23-1.html', 0, '', '', 0),
(NULL, 'FCM_API_URL', 'string', '', 0, '', '', 0),
(NULL, 'CHAT_LOGS_DIR', 'string', '/data/logs/chat.logs/', 0, '', '', 0),
(NULL, 'MAX_ONLINE', 'int', '100', 0, '设置最大在线人数', '1500', 0),
(NULL, 'QUEUE_NUM', 'int', '50', 0, '设置排队人数', '1200', 0),
(NULL, 'WEB_AUTH_URL', 'string', 'http://www.tzrgame-debug.com/', 0, '玩家在哪里登陆游戏', 'http://web.4399.com/user/login.php', 0),
(NULL, 'WEB_TITLE', 'string', '天之刃-玩家QQ群：88888888', 0, '网页标题', '天之刃-玩家QQ群：88888888', 0),
(NULL, 'ACTIVATE_CODE_URL', 'string', 'http://www.mingchao.com/xsk/index.php?game=mccq', 0, '领取激活码的URL', 'http://www.mingchao.com/xsk/index.php?game=mccq', 0),
(NULL, 'SERVER_LIST_URL', 'string', 'http://web.4399.com/mccq/select_server.html', 0, '平台选服页', 'http://web.4399.com/mccq/select_server.html', 0),
(NULL, 'TO_GAME_URL', 'string', 'http://web.4399.com/stat/togame.php', 0, '游戏跳转页', 'http://web.4399.com/stat/togame.php', 0),
(NULL, 'BAN_BEIJIN', 'boolean', 'false', 0, '是否屏蔽北京的IP充值', 'false', 0),
(NULL, 'PK_TIP', 'boolean', 'true', 0, '是否开启pk提示', 'false', 0),
(NULL, 'ADMIN_MENU_TITLE', 'string', '天之刃Debug服', 0, '管理后台左侧菜单的顶部标题', '天之刃1服管理后台', 0),
(NULL, 'CREATE_ROLE_VERSION', 'int', '2', 0, '创建页版本', '只能是1或者2', 0);
INSERT INTO `t_config` (`id`, `ckey`, `ctype`, `cvalue`, `readonly`, `memo`, `example`, `gm`) VALUES (NULL, 'JIHUOMA_URL', 'string', 'http://web.4399.com/mccq/xsk/', '0', '领取新手激活码的URL地址', 'http://web.4399.com/mccq/xsk/', '0'), (NULL, 'FIRST_PAY_URL', 'string', 'http://web.4399.com/mccq/xinwengonggao/xinwen/201102/24-42557.html', '0', '首充礼包的网址', 'http://web.4399.com/mccq/xinwengonggao/xinwen/201102/24-42557.html', '0');

INSERT INTO `t_config` (`id`, `ckey`, `ctype`, `cvalue`, `readonly`, `memo`, `example`, `gm`) VALUES (NULL, 'FIRST_PAY_TITLE', 'string', '首次充值就送大礼包,价值1888元宝!', '0', '首充活动的标题', '首次充值就送大礼包,价值1888元宝!', '0');

INSERT INTO `t_config` (`id`, `ckey`, `ctype`, `cvalue`, `readonly`, `memo`, `example`, `gm`) VALUES (NULL, 'gonglueURL', 'string', 'http://web.4399.com/mccq/youxigonglue/', '0', '游戏攻略的url地址', 'http://web.4399.com/mccq/youxigonglue/', '0');

INSERT INTO `t_config` (`id`, `ckey`, `ctype`, `cvalue`, `readonly`, `memo`, `example`, `gm`) VALUES (NULL, 'qqQun1', 'string', 'QQ群：126934341', '0', 'QQ群：126934341', 'QQ群：126934341', '0'), (NULL, 'qqQun2', 'string', '', '0', '', '', '0'), (NULL, 'qqQun3', 'string', '', '0', '', '', '0');

INSERT INTO `t_config` (`id`, `ckey`, `ctype`, `cvalue`, `readonly`, `memo`, `example`, `gm`) VALUES  (NULL, 'FULL_SCREEN', 'boolean', 'true', 0, '是否默认开启全屏', 'false', 0);

INSERT INTO `t_config` (`id`, `ckey`, `ctype`, `cvalue`, `readonly`, `memo`, `example`, `gm`) VALUES  (NULL, 'GUEST', 'boolean', 'false', 0, '是否开启游客模式', 'false', 0);

#=========end 2010-12-06 ========


#--corntab的统计表.消费统计 2010-12-9
CREATE TABLE `t_stat_money_consume` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `mtime` int(11) NOT NULL default '0',
  `year` int(4) NOT NULL default '0',
  `month` int(2) NOT NULL default '0',
  `day` int(2) NOT NULL default '0',
  `user_level` int(11) NOT NULL default '-1' COMMENT '玩家级别，-1表示全部级别的玩家',
  `save_bind_gold` int(11) NOT NULL default '0' COMMENT '当天元宝留存总额',
  `consume_bind_gold` int(11) NOT NULL default '0' COMMENT '当天元宝消耗总额',
  `new_bind_gold` int(11) NOT NULL default '0' COMMENT '当天新增元宝总数量',
  `save_unbind_gold` int(11) NOT NULL default '0' COMMENT '当天元宝留存总额',
  `consume_unbind_gold` int(11) NOT NULL default '0' COMMENT '当天元宝消耗总额',
  `new_unbind_gold` int(11) NOT NULL default '0' COMMENT '当天新增元宝总数量',
  `save_bind_silver` int(11) NOT NULL default '0' COMMENT '当天元宝留存总额',
  `consume_bind_silver` int(11) NOT NULL default '0' COMMENT '当天元宝消耗总额',
  `new_bind_silver` int(11) NOT NULL default '0' COMMENT '当天新增元宝总数量',
  `save_unbind_silver` int(11) NOT NULL default '0' COMMENT '当天元宝留存总额',
  `consume_unbind_silver` int(11) NOT NULL default '0' COMMENT '当天元宝消耗总额',
  `new_unbind_silver` int(11) NOT NULL default '0' COMMENT '当天新增元宝总数量',
  PRIMARY KEY  (`id`),
  KEY `mtime` (`mtime`),
  KEY `year` (`year`),
  KEY `month` (`month`),
  KEY `day` (`day`),
  KEY `user_level` (`user_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='统计每天的元宝存量和消耗量';


--
-- Table structure for table `t_log_login`
--
CREATE TABLE IF NOT EXISTS `t_log_login` (
`id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
`role_id` INT( 11 ) NOT NULL ,
`log_time` INT( 11 ) NOT NULL ,
`login_ip` varchar(15) COMMENT '登陆IP',
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `log_time` (`log_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家的登录日志表';


--
-- Table structure for table `t_log_daily_online`
--

CREATE TABLE IF NOT EXISTS `t_log_daily_online` (
  `role_id` int(11) NOT NULL DEFAULT '0',
  `mdate` int(11) NOT NULL DEFAULT '0',
  `year` int(4) NOT NULL DEFAULT '0',
  `month` int(2) NOT NULL DEFAULT '0',
  `day` int(2) NOT NULL DEFAULT '0',
  `online_time` int(11) NOT NULL DEFAULT '0' COMMENT '在线时长(分钟)',
  PRIMARY KEY (`role_id`,`mdate`),
  KEY `mdate` (`mdate`),
  KEY `year` (`year`),
  KEY `month` (`month`),
  KEY `day` (`day`),
  KEY `online_time` (`online_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='记录用户每天的在线时长';

#========= end 2010-12-09 =======

--
-- 表的结构 `t_stat_user_online`
--

CREATE TABLE IF NOT EXISTS `t_stat_user_online` (
  `user_id` int(11) NOT NULL,
  `total_live_time` double DEFAULT '0' COMMENT '该玩家累计实际在线时长',
  `today_live_time` double DEFAULT '0' COMMENT '该玩家当天在线时长',
  `last_record_time` double DEFAULT '0' COMMENT '最后记录时间',
  `avg_online_time` int(11) DEFAULT '0' COMMENT '最近几天(7天)的平均在线时长(分钟)',
  `active` tinyint(4) DEFAULT '1' COMMENT '是否活跃用户, 默认1活动, 0流失',
  PRIMARY KEY (`user_id`),
  KEY `avg_online_time` (`avg_online_time`),
  KEY `active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户在线时长的统计表';


#=======start 2010-12-13====
CREATE TABLE IF NOT EXISTS `t_stat_item_consume` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `consume_count` longtext NOT NULL COMMENT '道具ID：道具消耗量',
  `mtime` int(11) NOT NULL DEFAULT '0' COMMENT '统计数据时间',
  `year` smallint(4) NOT NULL DEFAULT '0' COMMENT '统计开始年份',
  `month` tinyint(2) NOT NULL DEFAULT '0' COMMENT '统计开始月份',
  `day` tinyint(2) NOT NULL DEFAULT '0' COMMENT '统计开始日',
  PRIMARY KEY (`id`),
  KEY `mtime` (`mtime`),
  KEY `year` (`year`),
  KEY `month` (`month`),
  KEY `day` (`day`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='每天道具消耗情况' ;
#=======end 2010-12-13====

#=======start 2010-12-15====
CREATE TABLE IF NOT EXISTS `t_monitor_map_msg` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mtime` int(11) NOT NULL DEFAULT '0' COMMENT '统计数据时间',
  `map_name` varchar(512) NOT NULL COMMENT '地图进程名称',
  `node` varchar(512) NOT NULL COMMENT '节点名称',
  `online_num` int(11) NOT NULL DEFAULT '0' COMMENT '地图的在线人数',
  `msg_len` int(11) NOT NULL DEFAULT '0' COMMENT '地图进程的消息长度',
  PRIMARY KEY (`id`),
  KEY `map_name` (`map_name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='地图消息队列的监控表' ;
#=======end 2010-12-15====

#========== start 2010-12-20 ========
CREATE TABLE IF NOT EXISTS `t_log_mission` (
  `role_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '角色ID',
  `mission_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '任务ID',
  `mission_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '任务类型',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '状态',
  `total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '总次数',
  `mtime` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`role_id`,`mission_id`),
  KEY `mission_type` (`mission_type`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
#========== end 2010-12-20 ============




#============12-21=================
CREATE TABLE IF NOT EXISTS `t_portal_account` (
`account_name` VARCHAR( 50 ) NOT NULL COMMENT  '平台账号',
`mtime` INT( 11 ) NOT NULL COMMENT  '第一次进来时间',
`year` INT( 4 ) NOT NULL ,
`month` INT( 2 ) NOT NULL ,
`day` INT( 2 ) NOT NULL ,
`ip` VARCHAR( 20 ) NULL ,
`router_line` INT( 40 ) NULL COMMENT  '1.电信,2.教育网,3.联通,4。其他',
`account_status` INT( 3 ) NULL COMMENT  '状态1。活跃,2。其他',
  PRIMARY KEY (  `account_name` )
) ENGINE = InnoDB COMMENT =  '第一次进入游戏之后的数据统计表';





CREATE TABLE IF NOT EXISTS `t_role_create_before` (
`account_name` VARCHAR( 50 ) NOT NULL COMMENT  '平台账号',
`mtime` INT( 11 ) NOT NULL COMMENT  '来老创建页时间',
`year` INT( 4 ) NOT NULL ,
`month` INT( 2 ) NOT NULL ,
`day` INT( 2 ) NOT NULL ,
PRIMARY KEY (  `account_name` )
) ENGINE = InnoDB COMMENT =  '刚进入创建角色页的数据统计表';




CREATE TABLE IF NOT EXISTS `t_role_create_after` (
`account_name` VARCHAR( 50 ) NOT NULL COMMENT  '平台账号',
`role_name` VARCHAR( 50 ) NOT NULL COMMENT  '角色名',
`faction_id` INT(2) NOT NULL COMMENT  '国家',
`mtime` INT( 11 ) NOT NULL ,
`year` INT( 4 ) NOT NULL ,
`month` INT( 2 ) NOT NULL ,
`day` INT( 2 ) NOT NULL ,
PRIMARY KEY (  `account_name` )
) ENGINE = InnoDB COMMENT =  '创建角色之后的数据统计表';

#===========12-21==================



#===========start 12-22==================
CREATE TABLE IF NOT EXISTS `t_activate_code` (
  `code` varchar(32) NOT NULL COMMENT '激活码',  
  `publish_id` int(11) NOT NULL COMMENT '发放ID，由发放类型+发放批次组成',
  `publish_time` int(11) NOT NULL default '0' COMMENT '激活码生成时间',   
  `role_id` int(11) NOT NULL default '0' COMMENT '玩家角色ID',  
  `role_level` int(11) NOT NULL default '0' COMMENT '玩家角色级别',  
  `mtime` int(11) NOT NULL default '0' COMMENT '领取激活码的时间',  
  `userip` char(15) NOT NULL default '',
  PRIMARY KEY  (`code`),
  KEY `role_id` (`role_id`),
  KEY `publish_id` (`publish_id`),  
  KEY `mtime` (`mtime`),
  KEY `userip` (`userip`)  
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='激活码列表' ;

#===========end 12-22==================



#===========start 12-24============
CREATE TABLE  IF NOT EXISTS `t_log_boss_state` (
`id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
`boss_id` INT( 11 ) NOT NULL ,
`boss_state` INT( 2 ) NOT NULL ,
`mtime` INT( 10 ) NOT NULL ,
`drop_item` VARCHAR( 1024 ) NULL ,
`last_hurt_player` INT NULL ,
PRIMARY KEY (  `id` )
) ENGINE = InnoDB COMMENT =  'boss记录的查看';
#===========end 12-24==============
#===========start 12-24================
CREATE TABLE IF NOT EXISTS `t_log_role_trading` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '记录id',
`role_id` INT( 11 ) NULL COMMENT '玩家id',
`role_name` VARCHAR( 50 ) NULL COMMENT '玩家名称',
`role_level` TINYINT( 3 ) NULL COMMENT '玩家级别',
`faction_id` TINYINT( 1 ) NULL COMMENT '国家id',
`family_id` INT( 11 ) NULL COMMENT '门派id',
`family_name` VARCHAR( 100 ) NULL COMMENT '门派名称',
`base_bill` INT( 11 ) NULL COMMENT '商票基础金额',
`bill` INT( 11 ) NULL COMMENT '商票金额',
`max_bill` INT( 11 ) NULL COMMENT '商票金额上限',
`trading_times` TINYINT( 1 ) NULL COMMENT '商贸活动次数',
`status` TINYINT( 1 ) NULL COMMENT '商贸状态',
`start_time` INT( 11 ) NULL COMMENT '领取商票时间',
`last_bill` INT( 11 ) NULL COMMENT '最终商票金额',
`family_money` INT( 11 ) NULL COMMENT '门派收益金额',
`family_contribution` INT( 11 ) NULL COMMENT '门派贡献度',
`end_time` INT( 11 ) NULL COMMENT '交还商票时间') ENGINE = InnoDB COMMENT = '商贸活动日志表';
ALTER TABLE  `t_log_role_trading` ADD INDEX (  `id` );
ALTER TABLE  `t_log_role_trading` ADD INDEX (  `role_id` );
ALTER TABLE  `t_log_role_trading` ADD INDEX (  `role_name` );
ALTER TABLE  `t_log_role_trading` ADD INDEX (  `faction_id` );
ALTER TABLE  `t_log_role_trading` ADD INDEX (  `status` );
ALTER TABLE  `t_log_role_trading` ADD INDEX (  `start_time` );
ALTER TABLE  `t_log_role_trading` ADD INDEX (  `end_time` );


#==========end 12-24====================


#=====================12-27==================
ALTER TABLE  `t_log_boss_state` ADD  `boss_type` INT( 20 ) NOT NULL ,
ADD  `boss_name` VARCHAR( 60 ) NOT NULL ,
ADD  `ext` VARCHAR( 100 ) NOT NULL;
ALTER TABLE  `t_log_boss_state` CHANGE  `boss_type`  `boss_type` INT( 20 ) NULL DEFAULT NULL;
ALTER TABLE  `t_log_boss_state` CHANGE  `boss_name`  `boss_name` VARCHAR( 60 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;
ALTER TABLE  `t_log_boss_state` CHANGE  `ext`  `ext` VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL;

#======================12-27==========================


#==================12-18====================
CREATE TABLE  IF NOT EXISTS `t_ban_ip_list` (
`ip` VARCHAR( 15 ) NOT NULL ,
`mtime` INT( 10 ) NOT NULL ,
`adminid` INT( 11 ) NOT NULL ,
PRIMARY KEY (  `ip` )
) ENGINE = InnoDB ;
CREATE TABLE  IF NOT EXISTS `t_ban_role_list` (
`role_name` VARCHAR( 50 ) NOT NULL ,
`mtime` INT( 10 ) NOT NULL ,
`adminid` INT( 11 ) NOT NULL ,
PRIMARY KEY (  `role_name` )
) ENGINE = InnoDB ;
#=================12-28=================

#=================start 2011-01-03=================
CREATE TABLE IF NOT EXISTS `t_log_vwf` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '记录id',
`faction_id` TINYINT( 1 ) NULL COMMENT '国家id',
`map_id` INT( 11 ) NULL COMMENT '地图id',
`map_name` VARCHAR( 64 ) NULL COMMENT '地图名称',
`npc_id` INT( 11 ) NULL COMMENT '副本NPCID',
`start_time` INT( 11 ) NULL COMMENT '进入副本时间',
`status` TINYINT( 1 ) NULL COMMENT '副本状态，1进入，2完成，3其它',
`vwf_monster_level` TINYINT( 3 ) NULL COMMENT '副本怪物级别',
`in_vwf_role_ids` VARCHAR( 128 ) NULL COMMENT '进入副本玩家id',
`in_vwf_role_names` VARCHAR( 512 ) NULL COMMENT '进入副本玩家名称',
`in_vwf_number` TINYINT( 1 ) NULL COMMENT '进入副本人数',
`end_time` INT( 11 ) NULL COMMENT '完成副本时间',
`out_vwf_role_ids` VARCHAR( 128 ) NULL COMMENT '完成副本玩家id',
`out_vwf_number` TINYINT( 1 ) NULL COMMENT '完成副本人数',
`leader_role_id` INT( 11 ) NULL COMMENT '队长id',
`deal_state` TINYINT( 1 ) NULL COMMENT '记录处理状态，0未处理，1已处理') ENGINE = InnoDB COMMENT = '讨伐敌营日志表';
ALTER TABLE  `t_log_vwf` ADD INDEX (  `faction_id` );
ALTER TABLE  `t_log_vwf` ADD INDEX (  `map_id` );
ALTER TABLE  `t_log_vwf` ADD INDEX (  `start_time` );
ALTER TABLE  `t_log_vwf` ADD INDEX (  `status` );
ALTER TABLE  `t_log_vwf` ADD INDEX (  `end_time` );
ALTER TABLE  `t_log_vwf` ADD INDEX (  `leader_role_id` );
ALTER TABLE  `t_log_vwf` ADD INDEX (  `deal_state` );


#=================end 2011-01-03=================

#=================start 2011-01-06=================
CREATE TABLE IF NOT EXISTS `t_log_role_vwf` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '记录id',
`faction_id` TINYINT( 1 ) NULL COMMENT '国家id',
`map_id` INT( 11 ) NULL COMMENT '地图id',
`map_name` VARCHAR( 64 ) NULL COMMENT '地图名称',
`npc_id` INT( 11 ) NULL COMMENT '副本NPCID',
`start_time` INT( 11 ) NULL COMMENT '进入副本时间',
`vwf_monster_level` TINYINT( 3 ) NULL COMMENT '副本怪物级别',
`role_id` INT( 11 ) NULL COMMENT '玩家id',
`role_name` VARCHAR( 64 ) NULL COMMENT '玩家名称',
`end_time` INT( 11 ) NULL COMMENT '完成副本时间',
`leader_role_id` INT( 11 ) NULL COMMENT '队长id') ENGINE = InnoDB COMMENT = '讨伐敌营个人日志表';
ALTER TABLE  `t_log_role_vwf` ADD INDEX (  `faction_id` );
ALTER TABLE  `t_log_role_vwf` ADD INDEX (  `start_time` );
ALTER TABLE  `t_log_role_vwf` ADD INDEX (  `end_time` );
#=================end 2011-01-06=================


#=========start 2011-1-8  ========
ALTER TABLE `t_ban_role_list` DROP PRIMARY KEY ;
ALTER TABLE `t_ban_role_list` ADD `role_id` INT NOT NULL FIRST ;
ALTER TABLE `t_ban_role_list` ADD PRIMARY KEY ( `role_id` ) ;
ALTER TABLE `t_ban_role_list` ADD `account_name` VARCHAR( 50 ) NOT NULL AFTER `role_name` ;
ALTER TABLE `t_ban_role_list` CHANGE `mtime` `end_time` INT( 10 ) NOT NULL ;
ALTER TABLE `t_ban_role_list` ADD `ban_reason` VARCHAR( 256 ) NULL ;
ALTER TABLE `t_ban_role_list` CHANGE `adminid` `admin_name` VARCHAR( 50 ) NOT NULL ;

ALTER TABLE `t_ban_ip_list` CHANGE `mtime` `end_time` INT( 11 ) NOT NULL ,
CHANGE `adminid` `admin_name` VARCHAR( 50 ) NOT NULL ;
ALTER TABLE `t_ban_ip_list` ADD `ban_reason` VARCHAR( 256 ) NULL ;

ALTER TABLE `t_log_vwf`  ADD `leader_role_name` VARCHAR( 50 ) NULL COMMENT '队长名称' ;
ALTER TABLE `t_log_role_vwf`  ADD `leader_role_name` VARCHAR( 50 ) NULL COMMENT '队长名称' ;
#=========end 2011-1-8  ========

#================start 2011-1-11=====================
CREATE TABLE IF NOT EXISTS `t_personal_ybc_stat` (
`id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
`role_id` INT( 11 ) NOT NULL ,
`role_name` VARCHAR( 30 ) NOT NULL ,
`start_time` INT( 10 ) NOT NULL ,
`ybc_color` INT( 2 ) NOT NULL ,
`final_state` INT( 2 ) NOT NULL ,
`end_time` INT( 10 ) NOT NULL ,
PRIMARY KEY (  `id` ) ,
INDEX (  `role_id` ,  `role_name` ,  `start_time` ,  `end_time` )
) ENGINE = INNODB COMMENT =  '个人拉镖状态查询';

ALTER TABLE  `t_personal_ybc_stat` ADD INDEX (  `role_id` );
ALTER TABLE  `t_personal_ybc_stat` ADD INDEX (  `role_name` );
ALTER TABLE  `t_personal_ybc_stat` ADD INDEX (  `start_time` );
ALTER TABLE  `t_personal_ybc_stat` ADD INDEX (  `end_time` );
#====================end 2011-1-11======================


#==================start 2011-1-13=====================
#批量发信、发道具 的日志表
CREATE TABLE IF NOT EXISTS `t_log_batch_email` (
`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`type` TINYINT NOT NULL COMMENT '类型',
`role_names` TEXT NOT NULL COMMENT '收件人列表',
`conditions` TEXT NOT NULL COMMENT '条件',
`email_content` TEXT NOT NULL COMMENT '信件内容',
`good_info` TEXT NOT NULL COMMENT '道具列表',
`create_time` INT NOT NULL ,
`update_time` INT NOT NULL ,
`admin_name` VARCHAR( 50 ) NOT NULL COMMENT '管理员帐号名'
) ENGINE = InnoDb;
#==================end 2011-1-13=======================

#==================start 2011-1-15=====================
CREATE TABLE IF NOT EXISTS `t_log_pay_gold` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `order_id` varchar(100) NOT NULL default '' COMMENT '充值账单ID',
  `role_id` int(11) unsigned NOT NULL  COMMENT '用户ID',
  `is_succ` tinyint(2) unsigned NOT NULL default 1 COMMENT '是否赠送元宝成功',
  `pay_type` int(3) unsigned NOT NULL  COMMENT '充值方式：1表示在线充值，2表示离线充值',
  `pay_gold` int(11) unsigned NOT NULL  COMMENT '元宝数量',
  `mtime` int(11) unsigned NOT NULL  COMMENT '时间',
  `reason` VARCHAR( 512 )  NOT NULL default '' COMMENT '失败原因',
  PRIMARY KEY  (`id`),
  KEY `role_id` (`role_id`),
  KEY `is_succ` (`is_succ`),  
  KEY `mtime` (`mtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='在线充值后元宝入账的日志表';
#==================end 2011-1-15=======================


#===============start 2011-1-14======================
CREATE TABLE IF NOT EXISTS `t_log_family_ybc` (
  `ybc_no` int(11) NOT NULL COMMENT '镖车ID',
  `family_id` int(11) NOT NULL COMMENT '门派ID',
  `mtime` int(10) NOT NULL COMMENT '记录时间',
  `content` mediumtext NOT NULL COMMENT '日志内容'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='门派拉镖的日志表';
ALTER TABLE  `t_log_family_ybc` ADD INDEX (  `ybc_no` );
ALTER TABLE  `t_log_family_ybc` ADD INDEX (  `family_id` );
ALTER TABLE  `t_log_family_ybc` ADD INDEX (  `mtime` );
#=============end 2011-1-14======================

#===============start 2011-1-16======================
#元宝使用记录，添加是否首次消耗或流通失去元宝的标识字段（首次消费统计）
ALTER TABLE `t_log_use_gold` ADD `is_first` BOOL NOT NULL DEFAULT '0' COMMENT '是否首次消耗或流通';
#=============end 2011-1-16=============================

#===============start 2011-1-18======================
CREATE TABLE IF NOT EXISTS `t_log_create_role_failed` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_name` varchar(50) NOT NULL,
  `reason` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
#=============end 2011-1-18======================

#===============start 2011-1-20====================
CREATE TABLE IF NOT EXISTS  `t_stat_loyal_user` (
`id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
`mtime` INT( 11 ) NOT NULL ,
`active` INT( 6 ) NULL ,
`loyal` INT( 6 ) NULL ,
`avg_online` INT( 6 ) NULL ,
`max_online` INT( 6 ) NULL ,
`new_user` INT( 6 ) NULL ,
`total_user` INT( 6 ) NULL ,
`active_20` INT( 6 ) NULL,
PRIMARY KEY (  `id` ) ,
INDEX (  `mtime` )
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT =  '忠诚/活跃用户统计表';
#==============end 2011-1-20===================

#===============start 2011-1-21====================
CREATE TABLE IF NOT EXISTS `t_stat_use_gold` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '玩家角色级别',
  `gold_bind` int(11) NOT NULL DEFAULT '0' COMMENT '使用绑定元宝的数量',
  `gold_unbind` int(3) NOT NULL DEFAULT '0' COMMENT '使用元宝的数量',
  `mtype` int(11) NOT NULL DEFAULT '0' COMMENT '操作类型',
  `itemid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '涉及的道具ID',
  `amount` int(11) NOT NULL DEFAULT '0' COMMENT '涉及的道具等的数量',
  `op_times` int(11) NOT NULL DEFAULT '0' COMMENT '操作次数',
  `mtime` int(11) NOT NULL DEFAULT '0' COMMENT '操作时间',
  `year` int(4) DEFAULT NULL,
  `month` tinyint(2) DEFAULT NULL,
  `day` tinyint(2) DEFAULT NULL,
  `hour` tinyint(2) DEFAULT NULL,
  `week` tinyint(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mtype` (`mtype`),
  KEY `mtime` (`mtime`)
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT='元宝消耗统计表';
#==============end 2011-1-21===================

#==============start 2011-1-22===================
CREATE TABLE IF NOT EXISTS `t_stat_use_gold_with_pay` (
`id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL default '0' COMMENT '角色ID',
  `user_name` varchar(50) NOT NULL default '' COMMENT '角色名称',
  `account_name` varchar(50) NOT NULL default '' COMMENT '登录帐号',
  `level` int(11) NOT NULL default '0' COMMENT '玩家角色级别',
  `gold_bind` int(11) NOT NULL default '0' COMMENT '使用绑定元宝的数量',
  `gold_unbind` int(3) NOT NULL default '0' COMMENT '使用元宝的数量',
  `mtime` int(11) NOT NULL default '0' COMMENT   '操作时间',
  `mtype` int(11) NOT NULL default '0' COMMENT '操作类型',  
  `itemid` int(11) unsigned NOT NULL default '0' COMMENT '涉及的道具ID',
  `amount` int(11) NOT NULL default '0' COMMENT '涉及的道具等的数量',
  `pay_money` float NOT NULL default '0' COMMENT '此前付费总额',
  PRIMARY KEY  (`id`),
  KEY `pay_money` (`pay_money`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='元宝消耗同付费情况统计表';
#==============end 2011-1-22===================

#===============start 2011-1-24====================
CREATE TABLE IF NOT EXISTS `t_stat_use_silver` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `level` INT(11) NOT NULL DEFAULT '0' COMMENT '玩家角色级别',
  `silver_bind` INT(11) NOT NULL DEFAULT '0' COMMENT '使用绑定银子的数量',
  `silver_unbind` INT(3) NOT NULL DEFAULT '0' COMMENT '使用银子的数量',
  `mtype` INT(11) NOT NULL DEFAULT '0' COMMENT '操作类型',
  `itemid` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '涉及的道具ID',
  `amount` INT(11) NOT NULL DEFAULT '0' COMMENT '涉及的道具等的数量',
  `op_times` INT(11) NOT NULL DEFAULT '0' COMMENT '操作次数',
  `mtime` INT(11) NOT NULL DEFAULT '0' COMMENT '操作时间',
  `year` INT(4) DEFAULT NULL,
  `month` TINYINT(2) DEFAULT NULL,
  `day` TINYINT(2) DEFAULT NULL,
  `hour` TINYINT(2) DEFAULT NULL,
  `week` TINYINT(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mtype` (`mtype`),
  KEY `mtime` (`mtime`)
) ENGINE=INNODB  DEFAULT CHARSET=utf8 COMMENT='银子消耗统计表';
#==============end 2011-1-24===================

#==============start 2011-1-24===================
CREATE TABLE IF NOT EXISTS  `t_log_active_user_daily` (
`id` INT NOT NULL AUTO_INCREMENT ,
`role_id` VARCHAR( 30 ) NOT NULL ,
`ymd` INT( 8 ) NOT NULL ,
`avg_online_time` INT( 5 ) NOT NULL ,
PRIMARY KEY (  `id` )
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT='每日活跃用户的日志表';
ALTER TABLE  `t_log_active_user_daily` ADD INDEX (  `role_id` );
ALTER TABLE  `t_log_active_user_daily` ADD INDEX (  `ymd` );
#==============end 2011-1-24===================


#==============start 2011-1-26===================
CREATE TABLE `t_log_bank_sheet` (
  `sheet_id` int(11) NOT NULL COMMENT '挂单单号',
  `role_id` int(11) NOT NULL,
  `price` int(11) NOT NULL COMMENT '单价',
  `num` int(11) NOT NULL COMMENT '初始数量',
  `silver` int(11) NOT NULL COMMENT '初始总银两数',
  `current_num` int(11) NOT NULL COMMENT '当前数量',
  `current_silver` int(11) NOT NULL COMMENT '当前总银两',
  `type` tinyint(1) NOT NULL COMMENT '类型',
  `state` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` int(11) NOT NULL,
  `update_time` int(11) NOT NULL,
  PRIMARY KEY (`sheet_id`)
) ENGINE=InnoDb DEFAULT CHARSET=utf8;


CREATE TABLE `t_log_bank_sheet_deal` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
  `sheet_id` int(11) NOT NULL COMMENT '挂单单号',
  `type` tinyint(1) NOT NULL COMMENT '类型',
  `role_id` int(11) NOT NULL,
  `price` int(11) NOT NULL COMMENT '单价',
  `num` int(11) NOT NULL COMMENT '数量',
  `silver` int(11) NOT NULL COMMENT '总银两数',
  `mtime` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDb DEFAULT CHARSET=utf8;


CREATE TABLE `t_stat_bank_sheet` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
  `type` tinyint(1) NOT NULL COMMENT '类型',
  `sheet_cnt` int(11) NOT NULL COMMENT '挂单次数',
  `sheet_gold` int(11) NOT NULL COMMENT '挂单总元宝',
  `sheet_silver` int(11) NOT NULL COMMENT '挂单总银子数',
  `deal_cnt` int(11) NOT NULL COMMENT '交易次数',
  `deal_gold` int(11) NOT NULL COMMENT '成交总元宝',
  `deal_silver` int(11) NOT NULL COMMENT '成交总银子数',
  `avg_price` float NOT NULL COMMENT '平均成交价',
  `min_price` float NOT NULL COMMENT '最低成交价',
  `max_price` float NOT NULL COMMENT '最高成交价',
  `mtime` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDb DEFAULT CHARSET=utf8;

#==============end 2011-1-26=================================

#==============start 2011-1-27===================
CREATE TABLE IF NOT EXISTS `t_log_user_collect` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_name` varchar(50) NOT NULL,
  `role_id` int(10) unsigned NOT NULL,
  `loading_time` int(11) NOT NULL,
  `max_speed` float NOT NULL,
  `min_speed` float NOT NULL,
  `begin_enter` int(11) NOT NULL,
  `end_enter` int(11) NOT NULL,
  `enter_time` int(11) NOT NULL COMMENT '进入地图所花费的时间',
  `if_move` tinyint(4) NOT NULL,
  `isp` tinyint(4) NOT NULL,
  `status` tinyint(3) unsigned NOT NULL COMMENT '记录的状态',
  `npc_id_list` varchar(1024) NOT NULL,
  `npd_id_number` int(10) unsigned NOT NULL,
  `first_npc_open_time` int(11) NOT NULL COMMENT '进入游戏后过了多久打开了NPC',
  `welcome_time` int(11) NOT NULL COMMENT '进入游戏后多久显示欢迎窗口',
  `weapon` tinyint(1) NOT NULL,
  `monster_id` int(11) NOT NULL COMMENT '打的第一只怪的id',
  `attack_monster_time` int(11) NOT NULL COMMENT '攻击怪物的总次数',
  `if_open_bag` tinyint(1) NOT NULL COMMENT '是否打开过背包',
  `dead_times` int(10) unsigned NOT NULL COMMENT '死亡次数',
  `relive_times` int(10) unsigned NOT NULL COMMENT '重生次数',
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `npd_id_number` (`npd_id_number`),
  KEY `enter_time` (`enter_time`),
  KEY `first_npc_open_time` (`first_npc_open_time`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
#==============end 2011-1-27===================

#==============start 2011-1-28===================
CREATE TABLE `t_log_create_user_changed` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`account_name` VARCHAR( 50 ) NOT NULL ,
`default_sex` TINYINT NOT NULL ,
`changed_sex` TINYINT NOT NULL ,
`sex` TINYINT NOT NULL ,
`sex_changed_same` TINYINT NOT NULL ,
`default_category` TINYINT NOT NULL ,
`changed_category` TINYINT NOT NULL ,
`category_changed_same` TINYINT NOT NULL ,
`category` TINYINT NOT NULL ,
`c_name` TINYINT NOT NULL 
) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT = '记录玩家在创角页的变化行为';
#==============end 2011-1-28===================


#==============start 2011-1-29===================
CREATE TABLE IF NOT EXISTS `t_map_list` (
  `map_id` int(11) NOT NULL COMMENT '地图ID',
  `map_name` VARCHAR( 50 ) NOT NULL COMMENT '地图名称',
  PRIMARY KEY  (`map_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='地图列表';
#==============end 2011-1-29===================


#=========start 2011-1-29  ========

ALTER TABLE `t_log_boss_state` ADD  `map_id` int(11) default 0 COMMENT '地图ID' AFTER `boss_state`;
ALTER TABLE `t_log_boss_state` ADD  `special_id` int(11) default 0 COMMENT '特殊ID，例如门派ID' AFTER `map_id`;

CREATE TABLE IF NOT EXISTS `t_log_user_offline` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_name` varchar(50) NOT NULL,
  `offline_time` int(10) unsigned NOT NULL,
  `offline_reason_no` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_name` (`account_name`),
  KEY `offline_time` (`offline_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家下线原因记录';

#=========end   2011-1-29 ========


#============start 2011-2-10==================
ALTER TABLE  `t_log_active_user_daily` ADD  `level` INT( 5 ) NULL DEFAULT  '0';
ALTER TABLE  `t_log_login` ADD  `level` INT( 5 ) NULL DEFAULT  '0';
#=============end 2011-2-10===================

#=============start 2011-2-14===================
CREATE TABLE IF NOT EXISTS `t_log_country_treasure` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mtime` int(10) unsigned NOT NULL,
  `role_id` int(11) NOT NULL,
  `level` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mtime` (`mtime`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
#=============end 2011-2-14===================

#=============start 2011-2-14===================
CREATE TABLE IF NOT EXISTS `t_stat_button` (
  `btn_key` int(10) unsigned NOT NULL,
  `level_type` int(10) unsigned NOT NULL,
  `use_type` int(10) unsigned NOT NULL,
  `num` int(10) unsigned NOT NULL,
  KEY `btn_key` (`btn_key`),
  KEY `level_type` (`level_type`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
#=============end 2011-2-14===================

#=============start 2011-2-16===================
CREATE TABLE IF NOT EXISTS `t_stat_pk_mode` (
  `pkmode_key` int(10) unsigned NOT NULL,
  `pk_peace` int(10) unsigned NOT NULL,
  `pk_all` int(10) unsigned NOT NULL,
  `pk_team` int(10) unsigned NOT NULL,
  `pk_family` int(10) unsigned NOT NULL,
  `pk_faction` int(10) unsigned NOT NULL,
  `pk_master` int(10) unsigned NOT NULL,
  KEY `pkmode_key` (`pkmode_key`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
#=============end 2011-2-16===================

#=============start 2011-2-17===================
CREATE TABLE IF NOT EXISTS `t_stat_exchange` (
  `type_id` int(10) unsigned NOT NULL,
  `equip_type` int(10) unsigned NOT NULL,
  `exchange` int(10) unsigned NOT NULL,
  `num` int(10) unsigned NOT NULL,
  KEY `type_id` (`type_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
#=============end 2011-2-17===================

#=============start 2011-2-18===================
#批量发信历史记录增加一列：信件标题
ALTER TABLE `t_log_batch_email` ADD `email_title` VARCHAR( 255 ) NOT NULL COMMENT '信件标题';
#=============end 2011-2-18===================

#=============start 2011-2-21===================
CREATE TABLE IF NOT EXISTS `t_log_educate` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `faction_id` TINYINT(1)  NULL COMMENT '国家',
  `leader_role_id` INT(11)  NULL COMMENT '队长玩家id',
  `leader_role_name` VARCHAR(64)  NULL COMMENT '队长玩家名称',
  `monster_level` INT(11)  NULL COMMENT '副本怪物级别',
  `start_time` INT(11) NULL COMMENT '进入副本时间',
  `status` TINYINT(2) NULL COMMENT '状态',
  `end_time` INT(11) NULL COMMENT '退出副本时间',
  `count` TINYINT(5) NULL COMMENT '副本积分',
  `in_role_ids` VARCHAR(128) NULL COMMENT '进入副本玩家id列表',
  `in_role_names` VARCHAR(512) NULL COMMENT '进入副本玩家名称列表',
  `out_role_ids` VARCHAR(128) NULL COMMENT '副本完成id列表',
  `in_number` TINYINT(1) NULL COMMENT '进入副本人数',
  `out_number` TINYINT(1) NULL COMMENT '完成副本人数',
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `start_time` (`start_time`),
  KEY `count` (`count`),
  KEY `end_time` (`end_time`)
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT='师门同心副本日志表';

CREATE TABLE IF NOT EXISTS `t_log_role_educate` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `faction_id` TINYINT(1)  NULL COMMENT '国家',
  `role_id` INT(11)  NULL COMMENT '玩家id',
  `role_name` VARCHAR(64)  NULL COMMENT '玩家名称',
  `leader_role_id` INT(11)  NULL COMMENT '队长玩家id',
  `leader_role_name` VARCHAR(64)  NULL COMMENT '队长玩家名称',
  `monster_level` INT(11)  NULL COMMENT '副本怪物级别',
  `start_time` INT(11) NULL COMMENT '进入副本时间',
  `status` TINYINT(2) NULL COMMENT '状态',
  `end_time` INT(11) NULL COMMENT '退出副本时间',
  `count` TINYINT(5) NULL COMMENT '副本积分',
  `times` TINYINT(1) NULL COMMENT '进入副本次数',
  PRIMARY KEY (`id`),
  KEY `faction_id` (`faction_id`),
  KEY `status` (`status`),
  KEY `start_time` (`start_time`),
  KEY `count` (`count`),
  KEY `end_time` (`end_time`)
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT='师门同心副本玩家日志表';


#增加索引：

alter table t_log_online add index(online);

#=============end 2011-2-21===================

#=============start 2011-2-22=================
ALTER TABLE `t_log_role_educate` ADD `lucky_count` TINYINT( 5 ) NOT NULL COMMENT '幸运积分';
#=============end 2011-2-22===================

#=============start 2011-2-24=================
ALTER TABLE  `t_log_role_trading` ADD  `award_type` TINYINT( 1 ) NULL DEFAULT  '1' COMMENT  '奖励类型 1 银子，2 绑定银子';
#=============end 2011-2-24===================

#=============start 2011-2-25=================

CREATE TABLE IF NOT EXISTS `t_conlogin_reward` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) NOT NULL,
  `silver` int(11) NOT NULL,
  `gold` int(11) NOT NULL,
  `min_level` int(11) NOT NULL,
  `max_level` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `loop_day` int(11) NOT NULL,
  `bind` tinyint(1) NOT NULL,
  `num` int(11) NOT NULL,
  `item_name` varchar(200) NOT NULL,
  `need_payed` tinyint(1) NOT NULL,
  `need_vip_level` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `t_conlogin_reward_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `begin_day` int(11) NOT NULL,
  `end_day` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
#=============end 2011-2-25===================




 ALTER TABLE  `t_stat_money_consume` ADD  `cur_bind_gold_added` INT( 20 )  NULL DEFAULT  '0';
 ALTER TABLE  `t_stat_money_consume` ADD  `cur_unbind_gold_added` INT( 20 )  NULL DEFAULT  '0';
 ALTER TABLE  `t_stat_money_consume` ADD  `cur_bind_gold_consume` INT( 20 )  NULL DEFAULT  '0';
 ALTER TABLE  `t_stat_money_consume` ADD  `cur_unbind_gold_consume` INT( 20 )  NULL DEFAULT  '0';
 
 ALTER TABLE  `t_stat_money_consume` ADD  `cur_bind_silver_added` INT( 20 )  NULL DEFAULT  '0';
 ALTER TABLE  `t_stat_money_consume` ADD  `cur_unbind_silver_added` INT( 20 )  NULL DEFAULT  '0';
 ALTER TABLE  `t_stat_money_consume` ADD  `cur_bind_silver_consume` INT( 20 )  NULL DEFAULT  '0';
 ALTER TABLE  `t_stat_money_consume` ADD  `cur_unbind_silver_consume` INT( 20 )  NULL DEFAULT  '0';

#============= by caochuncheng @2011-2-28=================
ALTER TABLE `t_log_educate` ADD  `dead_times` INT(11) NULL COMMENT '玩家死亡次数' AFTER `out_number`;
ALTER TABLE `t_log_role_educate` ADD  `dead_times` INT(11) NULL COMMENT '玩家死亡次数' AFTER `lucky_count`;
#=============end===================

#=============start 2011-03-01=================
#统计每日师徒副本参与的情况
CREATE TABLE `t_stat_educate` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	`join_count` INT UNSIGNED NOT NULL COMMENT '当天参与师徒副本的人数',
	`total_educate` INT UNSIGNED NOT NULL COMMENT '当天以前有师徒关系的人数',
	`total_gold` INT UNSIGNED NOT NULL COMMENT '当天师徒副本刷幸运积分扣除元宝总数',
	`max_online` INT UNSIGNED NOT NULL COMMENT '当天最高在线用户量',
	`mtime` INT( 11 ) UNSIGNED NOT NULL ,
	INDEX ( `mtime` )
) ENGINE = InnoDB ;

CREATE TABLE `t_system_notice` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`content` LONGTEXT NOT NULL 
) ENGINE = InnoDB;
#=============end  2011-03-01===================

#==================start 2011-03-05=============
#玩家获得宠物记录表
CREATE TABLE `t_log_get_pet` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pet_id` int(10) unsigned NOT NULL,
  `pet_name` varchar(50) NOT NULL,
  `pet_type` int(11) unsigned NOT NULL,
  `pet_level` int(11) unsigned NOT NULL,
  `get_way` int(11) unsigned NOT NULL COMMENT '获得的方式',
  `role_id` int(10) unsigned NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `account_name` varchar(50) NOT NULL,
  `role_level` tinyint(4) unsigned NOT NULL,
  `faction` tinyint(3) unsigned NOT NULL COMMENT '玩家国家ID',
  `mtime` int(11) unsigned NOT NULL,
  `is_first` BOOL NOT NULL DEFAULT '0' COMMENT '是否首次获得宠物',
  PRIMARY KEY (`id`),
  KEY `pet_id` (`pet_id`),
  KEY `pet_type` (`pet_type`),
  KEY `role_id` (`role_id`),
  KEY `role_level` (`role_level`),
  KEY `faction` (`faction`),
  KEY `mtime` (`mtime`),
  KEY `is_first` (`is_first`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#对宠物操作日志表
CREATE TABLE `t_log_pet_action` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pet_id` int(10) unsigned NOT NULL,
  `pet_name` varchar(50) NOT NULL,
  `pet_type` int(11) NOT NULL COMMENT '宠物类型',
  `role_id` int(10) unsigned NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `action` int(11) unsigned NOT NULL COMMENT '操作类型',
  `action_detail` int(11) unsigned NOT NULL COMMENT '详细操作类型',
  `mtime` int(11) unsigned NOT NULL COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `pet_id` (`pet_id`),
  KEY `action` (`action`),
  KEY `action_detail` (`action_detail`),
  KEY `pet_type` (`pet_type`),
  KEY `mtime` (`mtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='对宠物操作日志表';
#==================end  2011-03-05 =============

#==================start 2011-03-05 16:00=============
ALTER TABLE `t_log_get_pet` ADD `pet_type_str` VARCHAR( 50 ) NULL COMMENT '宠物类型名称',
ADD `get_way_str` VARCHAR( 50 ) NULL COMMENT '获得方式说明';

ALTER TABLE `t_log_pet_action` ADD `pet_type_str` VARCHAR( 50 ) NOT NULL COMMENT '宠物类型名称',
ADD `action_str` VARCHAR( 50 ) NOT NULL COMMENT '操作名',
ADD `action_detail_str` VARCHAR( 50 ) NOT NULL COMMENT '详细操作名';
#==================end  2011-03-05 16:00 =============

#==================start 2011-03-07 =============
ALTER TABLE `t_log_item` ADD `bind_type` int(3) NOT NULL default '0' COMMENT '绑定类型';
#==================end  2011-03-07  =============


#==================start 2011-03-07 =============
ALTER TABLE `t_log_get_pet` DROP `role_name` ,
DROP `account_name` ;

ALTER TABLE `t_log_pet_action` DROP `role_name` ;
#==================end  2011-03-07 ====================

#=======start 2011-03-14====
CREATE TABLE IF NOT EXISTS `t_stat_item_buy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buy_count` longtext NOT NULL COMMENT '道具ID：道具获得量',
  `mtime` int(11) NOT NULL DEFAULT '0' COMMENT '统计数据时间',
  `year` smallint(4) NOT NULL DEFAULT '0' COMMENT '统计开始年份',
  `month` tinyint(2) NOT NULL DEFAULT '0' COMMENT '统计开始月份',
  `day` tinyint(2) NOT NULL DEFAULT '0' COMMENT '统计开始日',
  PRIMARY KEY (`id`),
  KEY `mtime` (`mtime`),
  KEY `year` (`year`),
  KEY `month` (`month`),
  KEY `day` (`day`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='每天商店购买道具获得情况' ;
#=======end 2011-03-14====

#=======start 2011-03-15====
CREATE TABLE IF NOT EXISTS `t_log_super_item` (
  `super_unique_id` int(11) unsigned NOT NULL COMMENT '装备唯一ID',  
  `mtime` int(11) unsigned NOT NULL COMMENT  '操作时间',  
  `type_id` int(11) unsigned NOT NULL COMMENT  '物品类型ID',  
  `level` int(5) default NULL COMMENT '道具级别',  
  `reinforce_result` int(11) default NULL COMMENT '当前强化结果（强化等级和星级的结合整数）',  
  `punch_num` int(5) default NULL COMMENT '当前打孔个数',  
  `stone_num` int(5) default NULL COMMENT '当前镶嵌宝石个数',  
  `signature` varchar(255) default NULL COMMENT '装备签名',  
  `refining_index` int(5) default NULL COMMENT '精炼系数',  
  PRIMARY KEY (`super_unique_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='特殊道具记录' ;
#=======end 2011-03-15====

#=======start 2011-03-15====
 ALTER TABLE  `t_log_item` ADD  `super_unique_id` INT(11)  NULL DEFAULT  '0';
#=======end 2011-03-15===========
#================by wuzesen @2011-03-14 begin=====================
CREATE TABLE IF NOT EXISTS `t_log_personal_ybc` (
`id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
`role_id` INT( 11 ) NOT NULL ,
`start_time` INT( 10 ) NOT NULL ,
`ybc_color` INT( 2 ) NOT NULL ,
`final_state` INT( 2 ) NOT NULL ,
`end_time` INT( 10 ) NOT NULL ,
  PRIMARY KEY (  `id` ) ,
  KEY `role_id` (`role_id`),
  KEY `start_time` (`start_time`),
  KEY `final_state` (`final_state`)
) ENGINE = INNODB COMMENT =  '个人拉镖状态查询';
#====================end 2011-03-14======================

#==================start 2011-03-15 =============
ALTER TABLE `t_stat_educate` ADD `active_join` INT NOT NULL COMMENT '当天活跃且参加师徒副本的人数';
ALTER TABLE `t_stat_educate` ADD `active_educate` INT NOT NULL COMMENT '当天活跃且有师徒关系的人数';
#====================end 2011-03-15 ======================

#=======start 2011-03-17====
ALTER TABLE  `t_item_list` ADD  `is_overlap` int( 2 ) NOT NULL default '1' COMMENT '道具是否可重叠';
#=======end 2011-03-17===========
#=======start 2011-03-17====  高级装备记录添加镶嵌的石头记录
ALTER TABLE  `t_log_super_item` ADD  `stones` varchar(50)  NULL COMMENT '镶嵌石头记录';

#=======end 2011-03-17===========


#==================by linruirong start 2011-03-18 =============
CREATE TABLE `t_log_shoubian` (
  `id` varchar(32) NOT NULL,
  `role_id` int(10) unsigned NOT NULL COMMENT '角色ID',
  `faction_id` tinyint(3) unsigned NOT NULL COMMENT '国家ID',
  `mdate` date NOT NULL,
  `status` tinyint(4) NOT NULL,
  `success` int(11) NOT NULL COMMENT '成功次数',
  `fail` int(11) NOT NULL COMMENT '失败次数',
  `total` int(11) NOT NULL COMMENT '总次数',
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='守边日志';


CREATE TABLE `t_log_citan` (
  `id` varchar(32) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL COMMENT '类型(刺探或国探)',
  `role_id` int(10) unsigned NOT NULL COMMENT '角色ID',
  `faction_id` tinyint(3) unsigned NOT NULL COMMENT '国家ID',
  `mdate` date NOT NULL,
  `status` tinyint(4) NOT NULL,
  `success` int(11) NOT NULL COMMENT '成功次数',
  `fail` int(11) NOT NULL COMMENT '失败次数',
  `total` int(11) NOT NULL COMMENT '总次数',
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `type` (`type`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='刺探国探日志';
#====================end 2011-03-18 ======================


#=======by qingliang start 2011-03-18====
CREATE TABLE IF NOT EXISTS `t_log_conlogin` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL,
  `days` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `bind` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `num` int(11) NOT NULL,
  `gold` int(11) NOT NULL,
  `gold_bind` int(11) NOT NULL,
  `silver` int(11) NOT NULL,
  `silver_bind` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `dateline` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `dateline` (`dateline`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='连续登陆奖励领取日志';
#=======end 2011-03-18===========

#================by wuzesen @2011-03-18 begin=====================
CREATE TABLE IF NOT EXISTS `t_family_depot_put_logs` (
`id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
`family_id` INT( 11 ) NOT NULL COMMENT '门派ID',
`log_time` INT( 11 ) NOT NULL COMMENT '操作时间',
`role_name` varchar(50) NOT NULL COMMENT '角色名称',
`item_type_id` INT( 11 ) NOT NULL COMMENT '道具类型ID',
`item_color` INT( 2 ) NOT NULL COMMENT '道具颜色',
`item_num` INT( 2 ) NOT NULL COMMENT '道具数量',
  PRIMARY KEY (  `id` ) ,
  KEY `family_id` (`family_id`)
) ENGINE = INNODB COMMENT =  '门派仓库的存入记录';

CREATE TABLE IF NOT EXISTS `t_family_depot_get_logs` (
`id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
`family_id` INT( 11 ) NOT NULL COMMENT '门派ID',
`log_time` INT( 11 ) NOT NULL COMMENT '操作时间',
`role_name` varchar(50) NOT NULL COMMENT '角色名称',
`item_type_id` INT( 11 ) NOT NULL COMMENT '道具类型ID',
`item_color` INT( 2 ) NOT NULL COMMENT '道具颜色',
`item_num` INT( 2 ) NOT NULL COMMENT '道具数量',
  PRIMARY KEY (  `id` ) ,
  KEY `family_id` (`family_id`)
) ENGINE = INNODB COMMENT =  '门派仓库的取出记录';
#====================end 2011-03-14======================

#===================by caisiqiang @2011-03-23 begin ===============
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `save_bind_gold`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `consume_bind_gold`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `save_unbind_gold`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `consume_unbind_gold`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `save_bind_silver`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `consume_bind_silver`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `save_unbind_silver`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `consume_unbind_silver`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `new_bind_gold`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `new_unbind_gold`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `new_bind_silver`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_money_consume`   MODIFY   `new_unbind_silver`   BIGINT   NOT   NULL;

ALTER   TABLE   `t_stat_use_silver`   MODIFY   `silver_bind`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_use_silver`   MODIFY   `silver_unbind`   BIGINT   NOT   NULL;

ALTER   TABLE   `t_stat_use_gold`   MODIFY   `gold_bind`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_use_gold`   MODIFY   `gold_unbind`   BIGINT   NOT   NULL;

ALTER   TABLE   `t_stat_use_gold_with_pay`   MODIFY   `gold_bind`   BIGINT   NOT   NULL;
ALTER   TABLE   `t_stat_use_gold_with_pay`   MODIFY   `gold_unbind`   BIGINT   NOT   NULL;
#===================end 2011-03-23 ================================

#=============start 2011-3-31===================
CREATE TABLE IF NOT EXISTS `t_log_personal_fb` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `role_id` INT(11)  NULL COMMENT '玩家id',
  `role_name` VARCHAR(64)  NULL COMMENT '玩家名称',
  `faction_id` TINYINT(1)  NULL COMMENT '国家',
  `fb_id` INT(10) NULL COMMENT '关数',
  `start_time` INT(11) NULL COMMENT '进入副本时间',
  `end_time` INT(11) NULL COMMENT '退出副本时间',
  `status` TINYINT(2) NULL COMMENT '状态',
  PRIMARY KEY (`id`),
  KEY `start_time` (`start_time`),
  KEY `fb_id` (`fb_id`),
  KEY `faction_id` (`faction_id`)
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT='个人副本日志表';
#====================end 2011-03-31======================

#=============start 2011-3-31===================
CREATE TABLE IF NOT EXISTS `t_log_activity_benefit` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `role_id` INT(11)  NULL COMMENT '玩家id',
  `reward_date` INT(10) NULL COMMENT '领奖日期',  
  `reward_time` INT(10) NULL COMMENT '领奖时间',
  `task_num` INT(11) NULL COMMENT '完成的任务次数',
  `buy_num` INT(11) NULL COMMENT '购买的勋章次数',
  PRIMARY KEY (`id`),
  KEY `task_num` (`task_num`),
  KEY `buy_num` (`buy_num`),
  KEY `reward_date` (`reward_date`)
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT='个人日常福利的日志表';
#====================end 2011-03-31======================

#=============start 2011-04-01===================
CREATE TABLE IF NOT EXISTS `t_log_vip_pay` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `role_id` INT(11)  NULL COMMENT '玩家id',
  `pay_type` INT(3)  NULL COMMENT '消费类型',
  `pay_time` INT(10) NULL COMMENT '消费时间',
  `is_first` BOOL NOT NULL DEFAULT '0' COMMENT '是否第一次',
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `is_first` (`is_first`)
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT='VIP消费统计';

#====================end 2011-04-01======================

#=============start 2011-04-01===================
CREATE TABLE IF NOT EXISTS `t_stat_big_face` (
  `face` INT(4) NOT NULL AUTO_INCREMENT,
  `num` INT(11)  NULL COMMENT '次数',
  KEY `face` (`face`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
#=============start 2011-04-01===================

#=============start 2011-04-04===================
CREATE TABLE `t_log_socket` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`role_id` INT NOT NULL ,
`account_name` VARCHAR( 50 ) NOT NULL ,
`type` VARCHAR( 12 ) NOT NULL ,
`host` VARCHAR( 200 ) NOT NULL ,
`port` INT NOT NULL ,
`reason` INT NOT NULL ,
`dateline` INT UNSIGNED NOT NULL ,
`isp` INT NOT NULL ,
INDEX ( `dateline` ) 
) ENGINE = InnoDB COMMENT = '玩家socket连接不上的记录';

CREATE TABLE `t_log_socket_failed` (
`id` INT NOT NULL ,
`role_id` INT NOT NULL ,
`account_name` VARCHAR( 50 ) NOT NULL ,
`dateline` INT NOT NULL ,
`isp` INT NOT NULL 
) ENGINE = InnoDB COMMENT = '连接socket失败的';
#=============end 2011-04-04===================
#====================start 2011-04-12======================
CREATE TABLE IF NOT EXISTS `t_log_scene_war` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `role_id` INT(11)  NULL COMMENT '玩家id',
  `role_name` VARCHAR(64)  NULL COMMENT '玩家名称',
  `faction_id` TINYINT(1)  NULL COMMENT '国家',
  `level` INT(11)  NULL COMMENT '级别',
  `team_id` INT(11)  NULL COMMENT '队伍 id',
  `status` TINYINT(2) NULL COMMENT '状态',
  `times` TINYINT(2) NULL COMMENT '副本次数',
  `start_time` INT(11) NULL COMMENT '进入副本时间',
  `end_time` INT(11) NULL COMMENT '退出副本时间',
  `fb_id` INT(11) NULL COMMENT '副本创建者角色 id',
  `fb_seconds` INT(11) NULL COMMENT '副本创建时间戳',
  `fb_type` INT(11) NULL COMMENT '副本类型 1:鄱阳湖大战',
  `fb_level` INT(11) NULL COMMENT '副本级别',
  `dead_times` INT(11) NULL COMMENT '玩家副本死亡次数',
  `in_number` TINYINT(11) NULL COMMENT '进入副本玩家人数',
  `out_number` TINYINT(11) NULL COMMENT '退出副本玩家人数',
  `in_role_ids` VARCHAR(128) NULL COMMENT '进入副本玩家id列表',
  `in_role_names` VARCHAR(512) NULL COMMENT '进入副本玩家名称列表',
  `out_role_ids` VARCHAR(128) NULL COMMENT '副本完成id列表',
  `monster_born_number` INT(11)  NULL COMMENT '怪物出生数量',
  `monster_dead_number` INT(11)  NULL COMMENT '怪物死亡数量',
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `start_time` (`start_time`),
  KEY `end_time` (`end_time`),
  KEY `fb_id` (`fb_id`),
  KEY `fb_seconds` (`fb_seconds`),
  KEY `fb_type` (`fb_type`),
  KEY `fb_level` (`fb_level`)
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT='场景大战日志表';
CREATE TABLE IF NOT EXISTS `t_log_scene_war_collect` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `fb_id` INT(11) NULL COMMENT '副本创建者角色 id',
  `fb_seconds` INT(11) NULL COMMENT '副本创建时间戳',
  `collect_id` INT(11) NULL COMMENT '采集物 id',
  `collect_number` INT(11) NULL COMMENT '采集物数量 id',
  PRIMARY KEY (`id`),
  KEY `fb_id` (`fb_id`)
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT='场景大战日志表';
#====================end 2011-04-12======================

#====================by wuzesen start 2011-04-12======================
ALTER TABLE  `t_user_online` ADD  `line` INT NOT NULL COMMENT  '分线端口';
#====================end 2011-04-12======================

#====================by wuzesen start 2011-05-11======================
CREATE TABLE IF NOT EXISTS `t_map_liushi` (
  `level`  INT(11) NOT NULL ,
  `map_id` INT(11) NOT NULL ,
  `tx` INT(11) NULL COMMENT '',
  `ty` INT(11) NULL COMMENT '',
  `num` INT(11) NULL COMMENT '个数'
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 COMMENT='地图流失率统计表';
#====================end======================


#====================by qingliang start 2011-05-16======================
CREATE TABLE IF NOT EXISTS `t_log_error_collect` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`error_id` INT UNSIGNED NOT NULL ,
`error` INT NOT NULL ,
`dateline` INT UNSIGNED NOT NULL ,
INDEX ( `error_id` , `dateline` ) 
) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT = '前端报错信息记录';
#====================by qingliang start 2011-05-16======================

#====================by caisiqiang start 2011-05-25====================== 
CREATE TABLE IF NOT EXISTS `t_send_batch_result` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `all_count` int(6)  NOT NULL DEFAULT '0' COMMENT '全部数量',
  `fail_count` int(6)  NOT NULL DEFAULT '0' COMMENT '失败数量',
	`fail_list` text NOT NULL DEFAULT '' COMMENT '失败id列表',
	`log_time` int(11) NOT NULL DEFAULT '0' COMMENT '日志时间',
  PRIMARY KEY (`id`)
) ENGINE=INNODB  DEFAULT CHARSET=utf8 ;
#====================end 2011-05-25===================== 

#====================by liuwei start 2011-06-01======================
CREATE TABLE IF NOT EXISTS `t_log_family_collect` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
    `family_id` INT UNSIGNED NOT NULL COMMENT '门派ID',
    `log_time` INT UNSIGNED NOT NULL COMMENT '时间',
    `role_num` INT UNSIGNED NOT NULL COMMENT '参与活动人数',
    `score` INT UNSIGNED NOT NULL COMMENT '活动得分',
    KEY `family_id` (`family_id`),
    KEY `log_time` (`log_time`)
) ENGINE=INNODB  DEFAULT CHARSET=utf8 COMMENT = '门派采集活动日志';
#====================end 2011-06-01======================


#====================by wuzesen start 2011-06-07======================
CREATE TABLE IF NOT EXISTS `t_log_role_level` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` int(10) unsigned NOT NULL,
  `faction_id` int(10) unsigned NOT NULL,
  `level` int(10) unsigned NOT NULL,
  `log_time` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `log_time` (`log_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家升级日志记录';
#====================end 2011-06-07======================

#=================by caisiqiang start 2011-06-08====================
CREATE TABLE IF NOT EXISTS `t_log_fb_drop_thing`(
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type_id` int(6)  NOT NULL DEFAULT '0' COMMENT '物品id',
  `map_id` int(6)  NOT NULL DEFAULT '0' COMMENT '地图id',
	`drop_time` int(11) NOT NULL DEFAULT '0' COMMENT '掉落时间',
	`fb_type` int(4) NOT NULL DEFAULT '0' COMMENT '副本类型',
  PRIMARY KEY (`id`)
)ENGINE=INNODB DEFAULT CHARSET=utf8 ;
#==================end 2011-06-08=================================


#=================by wuzesen start 2011-06-13====================
CREATE VIEW `v_log_role_level_2` AS select `role_id`,`log_time` from `t_log_role_level` where (`t_log_role_level`.`level` = 2);
#==================end 2011-06-08=================================

#====================by caisiqiang start 2011-06-15====================== 
ALTER TABLE `t_send_batch_result` ADD `title` VARCHAR(255) NULL COMMENT '信件标题' AFTER `log_time`;
#====================end 2011-06-15====================== 

#=================by qingliang start 2011-06-17====================
CREATE TABLE IF NOT EXISTS `t_user_interface` (
 `role_id` INT UNSIGNED NOT NULL ,
 `full_screen_flag` BOOLEAN NOT NULL COMMENT'是否全屏',
 PRIMARY KEY (`role_id`) 
) ENGINE= InnoDB DEFAULT CHARSET=utf8 ;
#=================by qingliang end 2011-06-17====================

#====================by caisiqiang start 2011-06-19====================== 
ALTER TABLE `t_send_batch_result` ADD `letter_type` INT(1) NULL COMMENT '信件类型' AFTER `title`;
ALTER TABLE `t_send_batch_result` ADD `time_spend` INT(4) NULL NULL COMMENT '花费时间' AFTER `letter_type`;
#====================end 2011-06-10====================== 

#====================by caisiqiang start 2011-06-22====================== 
CREATE TABLE IF NOT EXISTS `t_log_version` (
	`id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`version` varchar(50) NOT NULL DEFAULT '' COMMENT '版本号',
  `log_time` int(11) NOT NULL DEFAULT '0' COMMENT '记录时间',
	PRIMARY KEY (`id`)
)ENGINE=INNODB DEFAULT CHARSET=utf8 AUTO_INCREMENT=0;
#====================end 2011-06-22======================
#====================by wuzesen start 2011-06-20====================== 
ALTER TABLE  `t_log_mission` ADD  `level` INT NOT NULL COMMENT  '级别' AFTER  `role_id`;
#====================end 2011-06-10====================== 


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