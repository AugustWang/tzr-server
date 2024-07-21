<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/log_gold_class.php';

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
	$endDateTime = strtotime(date('Y-m-d 23:59:59',strtotime('-1day')));
}
if ($startDateTime < $serverOnLineTime) {
	$startDateTime = $serverOnLineTime;
}
$yesTodayLastTime = strtotime(date('Y-m-d 23:59:59',strtotime('-1day')));
if ($endDateTime > $yesTodayLastTime) {
	$endDateTime = $yesTodayLastTime;
}
$startDate = date('Y-m-d',$startDateTime);
$endDate = date('Y-m-d',$endDateTime);

$sqlStatEducate = " SELECT * FROM t_stat_educate WHERE `mtime` BETWEEN {$startDateTime}  AND {$endDateTime} order by `mtime` desc ";
$rsStatEducate = GFetchRowSet($sqlStatEducate);
foreach ($rsStatEducate as &$row) {
	$row['date'] = date('Y-m-d',$row['mtime']);
	$row['rate'] = $row['total_educate'] > 0 ? round(100*$row['join_count']/$row['total_educate'],2): 0;
	$row['active_educate_rate'] = $row['active_educate'] > 0 ? round(100*$row['join_count']/$row['active_educate'],2): 0;
	$row['active_join_rate'] = $row['join_count'] > 0 ? round(100*$row['active_join']/$row['join_count'],2): 0;
}
$dateStrPrev = strftime("%Y-%m-%d", $startDateTime - 86400);
$dateStrToday = strftime("%Y-%m-%d");
$dateStrNext = strftime("%Y-%m-%d", $endDateTime + 86400);



$data = array(
	'rsStatEducate' => $rsStatEducate,
	'startDate' => $startDate,
	'endDate' => $endDate,
	"dateStrPrev"=> $dateStrPrev,
	"dateStrToday"=> $dateStrToday,
	"dateStrNext"=> $dateStrNext,
	"serverOnLineTime"=> SERVER_ONLINE_DATE,
	'yesToday'=>date('Y-m-d',$yesTodayLastTime),
);
$smarty->assign($data);
$smarty->display("module/analysis/educate_sum.tpl");
exit();