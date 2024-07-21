<?php
/**
 * 天之刃日创建角色清单
 * @date 2010.11.26
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.ip.limit.info.php";
include_once "../config/config.php";
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";

//当查询数据量过大, 在这里打开分页
define(PAGE_SIZE, 0);

$date = $_REQUEST['date'];
$t1 = strtotime($date);
if(!$date || !$t1)
	$t1 = strtotime('today');
$t2 = strtotime("tomorrow", $t1);

$offset = intval($_REQUEST['page']) * PAGE_SIZE;
if($offset < 0) $offset = 0;

$now = strtotime('today');
$sql = "SELECT `account_name` as aname, `role_name` as rname, `create_time` as ctime
	FROM `db_role_base_p`
	WHERE `create_time`>=" . $t1 . " 
		AND `create_time`<" . $t2 . " 
		ORDER BY `role_id` ";
if(defined("PAGE_SIZE")&&PAGE_SIZE) $sql .= "LIMIT " . PAGE_SIZE . " ";
if($offset) $sql .= "OFFSET $offset ";
$rows = $db->fetchAll($sql);

$count = count($rows);
if($count){
	for($i = 0; $i < $count - 1; $i++) {
		$row = $rows[$i];
		echo $row['aname'] . "|" . $row['rname'] . "|" . $row['ctime'] . "\n";
	}
	$row = $rows[$count - 1];
	echo $row['aname'] . "|" . $row['rname'] . "|" . $row['ctime'];
}
