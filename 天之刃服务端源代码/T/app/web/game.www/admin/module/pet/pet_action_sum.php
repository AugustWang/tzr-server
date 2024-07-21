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

//======================
$arrDate = array();
$diffDay = intval( ($endDateTime - $startDateTime)/(3600*24) );
for ($day=0;$day<=$diffDay;$day++){
	$datetime = strtotime("+{$day}day",$startDateTime);
	$arrDate[$datetime] = 0;
}
$arrHour = array();
for ($h=0;$h<=23;$h++){
	$arrHour[$h] = 0;
}
$role_id = UserClass::getUseridByRoleName($_REQUEST['role_name']);
if ($_REQUEST['role_name']) {
	$where = " AND role_id={$role_id} ";
}
//---------
$sqlAction = " SELECT count(`id`) as total_action , `action`, `action_str`, min(mtime) as mtime
			  FROM t_log_pet_action WHERE `mtime` BETWEEN {$startDateTime} AND {$endDateTime} {$where}
			  GROUP BY `action`, FROM_UNIXTIME(`mtime`,'%Y-%m-%d') ";
$arrAction = GFetchRowSet($sqlAction);

$arrActionByDate = array();
foreach ($arrAction as &$row) {
	if (!is_array($arrActionByDate[$row['action']])) {
		$arrActionByDate[$row['action']] = array(
			'action_str'=>$row['action_str'],
			'action_cnt'=>$arrDate,
		);
	}
	$datetime = strtotime( date('Y-m-d',$row['mtime']) );
	$arrActionByDate[$row['action']]['action_cnt'][$datetime] += $row['total_action'];
}
//echo '<pre>';print_r($arrActionByDate);echo '</pre>';die();
//-----------------------------------
$sqlActionHour = " SELECT count(`id`) as total_action , `action`, `action_str`, FROM_UNIXTIME(`mtime`,'%k') as mhour
			  FROM t_log_pet_action WHERE `mtime` BETWEEN {$startDateTime} AND {$endDateTime} {$where}
			  GROUP BY `action`, mhour ";
$arrActionHour = GFetchRowSet($sqlActionHour);

$arrActionByHour = array();
foreach ($arrActionHour as &$row) {
	if (!is_array($arrActionByHour[$row['action']])) {
		$arrActionByHour[$row['action']] = array(
			'action_str'=>$row['action_str'],
			'action_cnt'=>$arrHour,
		);
	}
	$arrActionByHour[$row['action']]['action_cnt'][$row['mhour']] += $row['total_action'];
}
//echo '<pre>';print_r($arrActionByHour);echo '</pre>';die();


//-------------------
$skill = 105; //学技能的操作代号,见(common.hrl或dict/pet.php)
$sqlActionDetail = " SELECT count(`id`) as total_action_detail , `action_detail`, `action_detail_str`, min(mtime) as mtime
			  FROM t_log_pet_action WHERE `action`={$skill} AND `mtime` BETWEEN {$startDateTime} AND {$endDateTime} {$where}
			  GROUP BY `action_detail`, FROM_UNIXTIME(`mtime`,'%Y-%m-%d') ";
$arrActionDetail = GFetchRowSet($sqlActionDetail);


$arrActionDetailByDate = array();
foreach ($arrActionDetail as &$row) {
	if (!is_array($arrActionDetailByDate[$row['action_detail']])) {
		$arrActionDetailByDate[$row['action_detail']] = array(
			'action_detail_str'=>$row['action_detail_str'],
			'action_detail_cnt'=>$arrDate,
		);
	}
	$datetime = strtotime( date('Y-m-d',$row['mtime']) );
	$arrActionDetailByDate[$row['action_detail']]['action_detail_cnt'][$datetime] += $row['total_action_detail'];
}
//echo '<pre>';print_r($arrActionDetailByDate);echo '</pre>';die();

//-----------------------------------
$sqlActionDetailHour = " SELECT count(`id`) as total_action_detail , `action_detail`, `action_detail_str`, FROM_UNIXTIME(`mtime`,'%k') as mhour
			  FROM t_log_pet_action WHERE `action`={$skill} AND `mtime` BETWEEN {$startDateTime} AND {$endDateTime} {$where}
			  GROUP BY `action_detail`, mhour ";
$arrActionDetailHour = GFetchRowSet($sqlActionDetailHour);

$arrActionDetailByHour = array();
foreach ($arrActionDetailHour as &$row) {
	if (!is_array($arrActionDetailByHour[$row['action_detail']])) {
		$arrActionDetailByHour[$row['action_detail']] = array(
			'action_detail_str'=>$row['action_detail_str'],
			'action_detail_cnt'=>$arrHour,
		);
	}
	$arrActionDetailByHour[$row['action_detail']]['action_detail_cnt'][$row['mhour']] += $row['total_action_detail'];
}
//echo '<pre>';print_r($arrActionDetailByHour);echo '</pre>';die();
//====================


$data = array(
	'arrDate' => $arrDate,
	'arrActionByDate' => $arrActionByDate,
	'arrActionDetailByDate' => $arrActionDetailByDate,
	'arrHour' => $arrHour,
	'arrActionDetailByHour' => $arrActionDetailByHour,
	'arrActionByHour' => $arrActionByHour,
	
	'role_name'=> $_REQUEST['role_name'],
	'startDate' => $startDate,
	'endDate' => $endDate,
	"dateStrPrev"=> $dateStrPrev,
	"dateStrToday"=> $dateStrToday,
	"dateStrNext"=> $dateStrNext,
	"serverOnLineTime"=> SERVER_ONLINE_DATE,
);
$smarty->assign($data);
$smarty->display("module/pet/pet_action_sum.tpl");
exit();