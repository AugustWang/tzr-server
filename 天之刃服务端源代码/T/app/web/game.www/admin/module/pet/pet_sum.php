<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/dict/pet.php';
include_once SYSDIR_ADMIN.'/include/dict.php';

$serverOnLineTime = strtotime(SERVER_ONLINE_DATE);
if (!$serverOnLineTime) {
	die('未设置开服日期');
}
$faction = intval($_REQUEST['faction']);
$startDate = $_REQUEST['startDate'];
$endDate = $_REQUEST['endDate'];
$startDateTime = strtotime($startDate);
$endDateTime = strtotime($endDate) ? strtotime($endDate)+86399 : false;

if (!$startDateTime || !$endDateTime ) {
	$startDateTime = strtotime(date('Y-m-d',strtotime('-6day')));
	$endDateTime = strtotime(date('Y-m-d 23:59:59'));
}
if ($startDateTime < $serverOnLineTime) {
	$startDateTime = $serverOnLineTime;
}
$yesTodayLastTime = strtotime(date('Y-m-d 23:59:59',strtotime('-1day')));

$startDate = date('Y-m-d',$startDateTime);
$endDate = date('Y-m-d',$endDateTime);

$dateStrPrev = strftime("%Y-%m-%d", $startDateTime - 86400);
$dateStrToday = strftime("%Y-%m-%d");
$dateStrNext = strftime("%Y-%m-%d", $startDateTime + 86400);

$where = $faction ? " AND `faction`={$faction} " : '';
//======================
$sqlFirst = " SELECT count(`id`) as total_person , `role_level` 
			  FROM t_log_get_pet WHERE `is_first`=1 AND `mtime` BETWEEN {$startDateTime} AND {$endDateTime} {$where} 
			  GROUP BY `role_level` ORDER BY role_level ";
$arrFirst = GFetchRowSet($sqlFirst);
$maxFirst = 0;
$minFirst = intval($arrFirst[0]['total_person']);
$sumFirst = 0;

foreach ($arrFirst as &$row) {
	$sumFirst += $row['total_person'];
	if ($row['total_person'] > $maxFirst) {
		$maxFirst = $row['total_person'];
	}
	if ($row['total_person'] < $minFirst) {
		$minFirst = $row['total_person'];
	}
	$row['rate'] = 0;
}
if ($sumFirst) {
	foreach ($arrFirst as &$row) {
		$row['rate'] = round($row['total_person']/$sumFirst,1)*100;
	}
}
//------------------
$get_way = 1 ;//属于使用宠物召唤符获得的，见(common.hrl或dict/pet.php)
$sqlDiaoLuo = " SELECT count(`id`) as total_pet , `pet_type_str` 
			  FROM t_log_get_pet WHERE `get_way`={$get_way} AND `mtime` BETWEEN {$startDateTime} AND {$endDateTime} {$where} 
			  GROUP BY `pet_type` ";
$arrDiaoLuo = GFetchRowSet($sqlDiaoLuo);
$maxDiaoLuo = 0;
$minDiaoLuo = intval($arrDiaoLuo[0]['total_pet']);
$sumDiaoLuo = 0;

foreach ($arrDiaoLuo as &$row) {
	$sumDiaoLuo += $row['total_pet'];
	if ($row['total_pet'] > $maxDiaoLuo) {
		$maxDiaoLuo = $row['total_pet'];
	}
	if ($row['total_pet'] < $minDiaoLuo) {
		$minDiaoLuo = $row['total_pet'];
	}
	$row['rate'] = 0;
}
if ($sumDiaoLuo) {
	foreach ($arrDiaoLuo as &$row) {
		$row['rate'] = round($row['total_pet']/$sumDiaoLuo,1)*100;
	}
}
//========================


$data = array(
	'firstCnt'=>count($arrFirst),
	'arrFirst' => $arrFirst,
	'minFirst' => $minFirst,
	'maxFirst' => $maxFirst,
	
	'diaoLuoCnt'=>count($arrDiaoLuo),
	'arrDiaoLuo' => $arrDiaoLuo,
	'minDiaoLuo' => $minDiaoLuo,
	'maxDiaoLuo' => $maxDiaoLuo,
	
	'faction' => $faction,
	'arrFaction' => $dictFaction,
	'startDate' => $startDate,
	'endDate' => $endDate,
	"dateStrPrev"=> $dateStrPrev,
	"dateStrToday"=> $dateStrToday,
	"dateStrNext"=> $dateStrNext,
	"serverOnLineTime"=> SERVER_ONLINE_DATE,
);

$smarty->assign($data);
$smarty->display("module/pet/pet_sum.tpl");
exit();