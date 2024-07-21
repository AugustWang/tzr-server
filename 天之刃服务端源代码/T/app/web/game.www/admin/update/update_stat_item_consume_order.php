<?php
/**
 * @author linruirong
 * 
 */

error_reporting(E_ALL ^ E_NOTICE);
define('IN_ODINXU_SYSTEM', true);
require_once( "../../config/config.php" );
include SYSDIR_ADMIN."/include/global_for_shell.php";
include SYSDIR_ADMIN."/class/admin_item_class.php"; //道具列表
include SYSDIR_ADMIN."/class/item_log_class.php";//道具使用日志

global $db;

$items = AdminItemClass::getItemList();
$itemId_arr = array(); //道具ID（过滤掉装备和任务道具）
foreach($items as $key=>&$item){
	if (3!=$item['type']) {
		$itemId_arr[] = $item['typeid'];
	}
}

$itemLogType = ItemLogClass::$itemLogType;
$tmpArr = array();
$filter = array(
	2001, // 剔除 出售给系统
	2002, // 剔除 交易失去
	2003, // 剔除 摆摊出售
	2006, // 剔除 任务扣除
	3001, // 剔除  '把物品移入摊位'
	3002, // 剔除  '把物品移出摊位'
);
foreach ($itemLogType as $key => &$val) {
	if ($key >= 2000 && !in_array($key,$filter)) {
		$tmpArr[$key] = $val;
	}
}
$consume_type_arr = array_keys($tmpArr);

$datetime = intval(strtotime($argv[1])); //$argv[1]为命令行下运行此文件时的参数
if (!$datetime) {
	$datetime = strtotime("-1day");
}

$dateYestoday = date('Y-m-d',$datetime);
$yesterdayStartTime = strtotime($dateYestoday);
$yesterdayEndTime = strtotime($dateYestoday.' 23:59:59');
$serverOnLineTime =  strtotime(SERVER_ONLINE_DATE);
if (!$serverOnLineTime || $yesterdayStartTime < $serverOnLineTime) {
	die("SERVER_ONLINE_DATE=".SERVER_ONLINE_DATE.", yesterday={$dateYestoday}, yesterday no data!\n");
}

$myear  = date('Y',$yesterdayStartTime);
$mmonth = date('n',$yesterdayStartTime);
$mday   = date('j',$yesterdayStartTime);

$weekOfYear = intval(date('z',$yesterdayStartTime)/7)+1;
$strWeek = $weekOfYear <10 ? '_0'.$weekOfYear : '_'.$weekOfYear;
$table = DB_MING2_LOGS.'.'.T_LOG_ITEM_PREF.$myear.$strWeek;

$strActions = ' `action` in('.implode(',',$consume_type_arr).')';
$sql = "SELECT SUM(amount) as total,`itemid` FROM " . $table . "
		WHERE `start_time`>={$yesterdayStartTime} AND `start_time`<={$yesterdayEndTime} AND {$strActions} 
		GROUP BY itemid ORDER BY total desc ";

$rs = GFetchRowSet($sql);
$arrResult = array();
foreach ($rs as $key => &$row) {
	if (in_array($row['itemid'],$itemId_arr)) {
		$arrResult[$row['itemid']] = $row['total'];
	}
}

$consume_count = combineData($arrResult, 1);  //将每个道具对应的ID和消耗量组合为字符串存储，减少表数据条数
$sqlDelete = " DELETE FROM ".DB_MING2_GAME.'.'.T_STAT_ITEM_CONSUME." WHERE `mtime`={$yesterdayStartTime} ";
GQuery($sqlDelete);
$sqlInsert = " INSERT INTO ".DB_MING2_GAME.'.'.T_STAT_ITEM_CONSUME."(`consume_count`,`mtime`,`year`,`month`,`day`)
		        		  VALUES('{$consume_count}',{$yesterdayStartTime},{$myear},$mmonth,$mday) ";
GQuery($sqlInsert); 

echo "\n update_stat_item_consume_order.php 成功 at ".date("Y-m-d H:i:s")."\n";

?>