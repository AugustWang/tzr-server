<?php
define('IN_ODINXU_SYSTEM', true);
include_once '../../config/config.php';

//$gm_reply_sql = "INSERT INTO ming2_cent.t_gm_reply(id,agent_id,server_id,complaint_id,reply_time,reply_gm,content,success,reason,evaluate) 
//                                             (SELECT  id,agent,server_id,complaint_id,reply_time,reply_gm,content,success,reason,evaluate from ming2_cent.t_Gm_Reply); " ;


//$player_complaint_sql = "INSERT INTO ming2_cent.t_player_complaint(id,agent_id,server_id,account_name,role_id,role_name,pay_amount,level,mtime,mtype,mtitle,content,reply_cnt,last_reply_time,is_spam,spam_reporter,spam_time) 
//					                                       (SELECT id,agent_id,server_no,account_name,role_id,role_name,pay_amount,level,mtime,mtype,mtitle,content,reply_cnt,null,is_spam,spam_reporter,spam_time FROM ming2_cent.t_Gm_Complaint); ";

$agent_id = $CONFIG_PARAMS['AGENT_ID'];
$server_id= $CONFIG_PARAMS['SERVER_ID'];
$ming2_game= DB_MING2_GAME;
$server_online_date = SERVER_ONLINE_DATE;
$server_online_time  = strtotime($server_online_date);

$create_tb_log = " CREATE TABLE IF NOT EXISTS `t_log_pay_tmp` (
  `id` int NOT NULL auto_increment,
  `agent_id` int NOT NULL COMMENT '代理商ID',
  `server_id` int NOT NULL COMMENT '服务器ID',
  `order_id` varchar(50) COMMENT '充值订单号',
  `role_id` int NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `account_name` varchar(50) NOT NULL,
  `pay_money` float default NULL  COMMENT '充值金额',
  `pay_gold` int unsigned NOT NULL COMMENT '充值获得的元宝',
  `give_gold` int unsigned NOT NULL COMMENT '附赠元宝',
  `role_level` smallint NOT NULL COMMENT '充值时的等级',
  `pay_time` int NOT NULL  COMMENT '充值时间',
  `pay_date_time` int NOT NULL  COMMENT '充值时间(0点时间戳)',
  `year` int NOT NULL,
  `month` tinyint NOT NULL,
  `day` tinyint NOT NULL,
  `hour` tinyint NOT NULL,
  `online_day` int not null comment '开服第几天',
  PRIMARY KEY  (`id`),
  KEY `role_id` (`role_id`),
  KEY `pay_money` (`pay_money`),
  KEY `pay_time` (`pay_money`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8  COMMENT '充值日志表';";

$create_tb_gold = "CREATE TABLE IF NOT EXISTS `t_log_gold_tmp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_id` int(11) NOT NULL DEFAULT '0' COMMENT '代理商ID',
  `server_id` int(11) NOT NULL DEFAULT '0' COMMENT '游戏服务器',
  `role_id` int COMMENT '角色ID',
  `role_name` varchar(50)  COMMENT '角色名称',
  `account_name` varchar(50) COMMENT '登录帐号',
  `role_level` int COMMENT '玩家角色级别',
  `gold_bind` int COMMENT '使用绑定元宝的数量',
  `gold_unbind` int COMMENT '使用元宝的数量',
  `mtime` int  COMMENT '操作时间',
  `mtype` int COMMENT '操作类型',
  `item_id` int  COMMENT '涉及的道具ID',
  `item_name` varchar(50) COMMENT '道具名',
  `amount` int COMMENT '道具数量或操作次数',
  `year` int(4) NOT NULL DEFAULT '0',
  `month` int(2) NOT NULL DEFAULT '0',
  `day` int(2) NOT NULL DEFAULT '0',
  `hour` int(2) NOT NULL DEFAULT '0',
  `mdatetime` int NOT NULL  COMMENT '消费时间(0点时间戳)',
   PRIMARY KEY  (`id`),
   KEY `role_id` (`role_id`),
   KEY `item_id` (`item_id`),
   KEY `mtime` (`mtime`),
   KEY `mdatetime` (`mdatetime`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='元宝日志表';";

//$create_tb_online = "CREATE TABLE IF NOT EXISTS `t_log_online_tmp` (
//  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, 
//  `agent_id` INT(11) NOT NULL DEFAULT '0' COMMENT '代理商ID',
//  `server_id` INT(11) NOT NULL DEFAULT '0' COMMENT '游戏服务器',
//  `online` INT(10)  NOT NULL COMMENT '在线数量',
//  `log_time` INT(11)  NOT NULL,
//  `mdatetime` INT NOT NULL  COMMENT '(0点时间戳)',
//  `online_day` INT NOT NULL COMMENT '开服第几天',
//  `week_day` TINYINT(4) NOT NULL COMMENT '周几',# 0(周日)--6(周六)
//  `year` INT(4) NOT NULL,
//  `month` TINYINT NOT NULL,
//  `day` TINYINT NOT NULL,
//  `hour` TINYINT NOT NULL,
//  `min` TINYINT NOT NULL,
//   PRIMARY KEY  (`id`),
//   KEY `online` (`online`),
//   KEY `log_time` (`log_time`),
//   KEY `mdatetime` (`mdatetime`)
//) ENGINE=MYISAM DEFAULT CHARSET=utf8 COMMENT='玩家在线数历史表';";

$log_pay_sql = "INSERT INTO ming2_logs.t_log_pay_tmp (agent_id,server_id,order_id,role_id,role_name,account_name,pay_money,pay_gold,give_gold,role_level,pay_time,pay_date_time,year,month,day,hour,online_day) 
					   	                 (SELECT $agent_id,$server_id,order_id,role_id,role_name,account_name,pay_money*100,pay_gold,null,role_level,pay_time,UNIX_TIMESTAMP(DATE_FORMAT(FROM_UNIXTIME(pay_time),'%Y-%m-%d')),year,month,day,hour, (pay_time-{$server_online_time})div 86400 FROM  ".$ming2_game.".db_pay_log_p); ";				   	 

$log_gold_sql = "INSERT INTO ming2_logs.t_log_gold_tmp (agent_id,server_id,role_id,role_name,account_name,role_level,gold_bind,gold_unbind,mtime,mtype,item_id,item_name,amount,year,month,day,hour,mdatetime) 
								(SELECT $agent_id,$server_id,a.user_id,a.user_name,a.account_name,a.level,a.gold_bind,a.gold_unbind,a.mtime,a.mtype, a.itemid,
										(SELECT item_name FROM ming2_game.t_item_list WHERE typeid=a.itemid),
										a.amount,
										DATE_FORMAT(FROM_UNIXTIME(a.mtime),'%Y'),
										DATE_FORMAT(FROM_UNIXTIME(a.mtime),'%m'),
										DATE_FORMAT(FROM_UNIXTIME(a.mtime),'%d'),
										DATE_FORMAT(FROM_UNIXTIME(a.mtime),'%H'),
										UNIX_TIMESTAMP(DATE_FORMAT(FROM_UNIXTIME(a.mtime),'%Y-%m-%d')) 
										FROM ".$ming2_game.".t_log_use_gold as a); ";

//$log_online_sql = "INSERT INTO ming2_logs.t_log_online_tmp (agent_id,server_id,online,log_time,mdatetime,online_day,week_day,year,month,day,hour,min) 
//					   	                       (SELECT $agent_id,$server_id,online,dateline,UNIX_TIMESTAMP(DATE_FORMAT(FROM_UNIXTIME(dateline),'%Y-%m-%d')),(dateline-{$server_online_time})div 86400,week_day,year,month,day,hour,min  FROM ".$ming2_game.".t_log_online); ";
	
$passwd = $dbConfig_game['passwd'];
$host =$dbConfig_game['host'];
$user = $dbConfig_game['user'];
$con = mysql_connect($host,$user,$passwd);
if (!$con)
{
die('Could not connect: ' . mysql_error());
}
mysql_select_db("ming2_logs", $con);

mysql_query($create_tb_log)or die(mysql_error());
mysql_query($create_tb_gold)or die(mysql_error());
//mysql_query($create_tb_online)or die(mysql_error());

mysql_query($log_pay_sql);
mysql_query($log_gold_sql);
//mysql_query($log_online_sql);
mysql_close($con);
?>
