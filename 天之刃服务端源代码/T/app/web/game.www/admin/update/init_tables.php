<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global_for_shell.php';
//$auth->assertModuleAccess(__FILE__);

/**
 * 初始化道具日志表
 */
init_item_log_tables();
init_silver_log_tables();

$startExecTime = time();
echo basename(__FILE__) ."  start at :".date('Y-m-d H:i:s',$startExecTime);




function init_item_log_tables(){
	$tables = getItemTables();
	foreach($tables as $tab){
		GQuery( genLogItemTableSQL($tab) );
	}
}

function init_silver_log_tables(){
	$tables = getSilverTables();
	foreach($tables as $tab){
		GQuery( getLogSilverTableSQL($tab) );
	}
}

/**
 * 获取本月、下月的银两日志表名
 */
function getSilverTables(){
	$tab_1 = "t_log_use_silver_" . date("Y_m");
	$tab_2 = "t_log_use_silver_" . date("Y_m",strtotime("+1 month")) ;
	
	return array($tab_1,$tab_2);
}

/**
 * 获取本周、下周、两周后的道具日志表名
 */
function getItemTables(){
	
	$res = array();
	//年末可能有特殊日期,所以特别处理
	for($i=0; $i<8; $i++){
		$res[] = T_LOG_ITEM_PREF . getWeek( strtotime("+". $i ." day") );
	}
	$res[] = T_LOG_ITEM_PREF . getWeek( strtotime("+14 day") );
	
	return array_unique($res);
}

function getWeek($date){
	$year = date('Y',$date);
	$days = date('z',$date);
	$weeks = intval($days / 7) + 1;
	
	if( $weeks<10 ){
		return $year.'_0'.$weeks;
	}else{
		return $year.'_'.$weeks;
	}
	
}


function getLogSilverTableSQL($table){
	$sql = "
		CREATE TABLE IF NOT EXISTS ". DB_MING2_LOGS .".`{$table}` (
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
		) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='按月分表，记录玩家银两的获得与使用';";
	return $sql;
}


function genLogItemTableSQL($table){
	$sql = "
		CREATE TABLE IF NOT EXISTS ". DB_MING2_LOGS .".`{$table}` (
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
        `bind_type` int(3) NOT NULL default '0' COMMENT '绑定类型',
		`super_unique_id` int(11) NOT NULL default '0' COMMENT '高级装备唯一标志',
		PRIMARY KEY  (`id`),
		KEY `userid` (`userid`),
		KEY `itemid` (`itemid`),
		KEY `action` (`action`),
		KEY `start_time` (`start_time`)
		) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='按周分表，记录道具变动';";
	return $sql;
}
 


?>