<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/dict/pet.php';

$serverOnLineTime = strtotime(SERVER_ONLINE_DATE);
if (!$serverOnLineTime) {
	die('未设置开服日期');
}
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

$sql = " SELECT count(`pet_id`) as total , `type_id` FROM db_pet_p GROUP BY `type_id` ";
$keepSum = GFetchRowSet($sql);
$maxTotalKeep = 0;
$sumTotalKeep = 0;

foreach ($keepSum as &$row) {
	$sumTotalKeep += $row['total'];
	if ($row['total'] > $maxTotalKeep) {
		$maxTotalKeep = $row['total'];
	}
	$row['pet_type_name'] = $dictPetType[$row['type_id']] ? $dictPetType[$row['type_id']] : $row['type_id'];
	$row['rate'] = 0;
}
if ($sumTotalKeep) {
	foreach ($keepSum as &$row) {
		$row['rate'] = round($row['total']/$sumTotalKeep,1)*100;
	}	
}

$data = array(
	'keepSumSize'=>count($keepSum),
	'keepSum' => $keepSum,
	'maxTotalKeep' => $maxTotalKeep,
	'startDate' => $startDate,
	'endDate' => $endDate,
	"dateStrPrev"=> $dateStrPrev,
	"dateStrToday"=> $dateStrToday,
	"dateStrNext"=> $dateStrNext,
	"serverOnLineTime"=> SERVER_ONLINE_DATE,
);

$smarty->assign($data);
$smarty->display("module/pet/pet_keep_sum.tpl");
exit();