<?php
/**
 * @author caisiqiang
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
		$itemId_arr[] = $item['typeid'];
}


$itemLogType = ItemLogClass::$itemLogType;
$tmpArr = array();

foreach ($itemLogType as $key => &$val) {
	if($key == 1010){
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
$buy_count = combineData($arrResult, 1);  //将每个道具对应的ID和消耗量组合为字符串存储，减少表数据条数
//原则上每天统计一次数据，如果当天需要修复数据，则要清除之前的数据
$sqlDelete = " DELETE FROM ".DB_MING2_GAME.'.'.T_STAT_ITEM_BUY." WHERE `mtime`={$yesterdayStartTime} ";
GQuery($sqlDelete);
$sqlInsert = " INSERT INTO ".DB_MING2_GAME.'.'.T_STAT_ITEM_BUY."(`buy_count`,`mtime`,`year`,`month`,`day`)
		        		  VALUES('{$buy_count}',{$yesterdayStartTime},{$myear},$mmonth,$mday) ";
GQuery($sqlInsert); 

echo "\n update_stat_item_buy_order.php 成功 at ".date("Y-m-d H:i:s")."\n";

?>