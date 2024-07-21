<?php
/**
 * @author linruirong
 * @desc 每天跑一次，计算前一天使用元宝的记录，把首次使用的标识出来。
 */
 
error_reporting(E_ALL ^ E_NOTICE);
$startExecTime = time();
echo basename(__FILE__) ."  start at :".date('Y-m-d H:i:s',$startExecTime);

define('IN_ODINXU_SYSTEM', true);
require_once( "../../config/config.php" );
include SYSDIR_ADMIN."/include/global_for_shell.php";
include SYSDIR_ADMIN.'/class/log_gold_class.php';

$arrConsumeType= LogGoldClass::getSpendTypeList();


$consumeType =  array_keys($arrConsumeType) ;
$strMType = implode(',', $consumeType);

$tbl = 't_log_use_gold';
$params = trim($argv[1]);

if ('set_old_data' == $params) {
	$sqlSelect =" SELECT MIN(`id`) as `id`,`user_id` FROM t_log_use_gold where `mtype` in({$strMType}) GROUP BY `user_id` ";
	$rsOldFirst = GFetchRowSet($sqlSelect);
	$arrOldFirstIds = array();
	foreach ($rsOldFirst as &$row) {
		array_push($arrOldFirstIds,$row['id']);
	}
	$strIds = empty($arrOldFirstIds) ? '' :implode(',',$arrOldFirstIds);
	
	if ($strIds) {
		$sqlUpdate = " UPDATE {$tbl} set `is_first`=1 where `id` in({$strIds}) ";
		GQuery($sqlUpdate);
		echo " 成功 ";
	}else {
		echo " 成功，但没数据 ";
	}
	
	$endExecTime = time();
	$totalExecTime = $endExecTime-$startExecTime;
	echo 'end at :'.date('Y-m-d H:i:s',$endExecTime).' total use time '.$totalExecTime." second \n";
	die();
}

$datetime = intval(strtotime($params)); 
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

$sqlSelect="SELECT b.user_id , MIN(b.id) AS `id`, a.is_first
			FROM {$tbl} b 
			LEFT JOIN {$tbl} a
			ON a.user_id = b.user_id AND a.is_first=1
			WHERE b.mtime BETWEEN {$yesterdayStartTime} AND {$yesterdayEndTime} 
				AND b.mtype in({$strMType})
			GROUP BY b.user_id ";
$rs= GFetchRowSet($sqlSelect);
$arrNewFirstIds = array(); //新增的首次消费记录的ID
foreach ($rs as &$row) {
	if (!$row['is_first']) {
		array_push($arrNewFirstIds,$row['id']);
	}
}
$strIds = empty($arrNewFirstIds) ? '' : implode(',',$arrNewFirstIds);
if ($strIds) {
	$sqlUpdate = " UPDATE {$tbl} set `is_first`=1 where `id` in({$strIds}) ";
	GQuery($sqlUpdate);
	echo " 成功 ";
}else {
	echo " 成功，但{$dateYestoday}没数据 ";
}
$endExecTime = time();
$totalExecTime = $endExecTime-$startExecTime;
echo 'end at :'.date('Y-m-d H:i:s',$endExecTime).' total use time '.$totalExecTime." second \n";
?>