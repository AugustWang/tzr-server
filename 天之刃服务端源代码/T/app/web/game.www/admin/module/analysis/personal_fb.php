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


$role_id = intval( $_GET['uid'] );
$role_name = SS( $_REQUEST['nickname'] );
$account_name = SS( $_REQUEST['acname'] );
$where_role = '';
if ($role_id) {
	$where_role .= " AND role_id=".$role_id;
}else {
	$where_role.= $account_name ? " AND BINARY account_name='".$account_name."' ": '';
	$where_role.= $role_name ? " AND BINARY role_name='".$role_name."' ": '';
}
if (trim( $where_role )) {
	$sqlBase = " SELECT * FROM ".T_DB_ROLE_BASE_P." WHERE TRUE ".$where_role;
	$base = $db->fetchOne($sqlBase);
}

if(!empty($base['role_id']))
{
	$where =" AND role_id =".$base['role_id'];
}
else
{
	$where = "";
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


$itemPerPage = LIST_PER_PAGE_RECORDS;
$pageno = getUrlParam('page');
$where.= "  AND start_time BETWEEN {$startDateTime} AND {$endDateTime} ";
$sqlCnt = " SELECT count(*) as cnt FROM t_log_personal_fb WHERE TRUE {$where} ";
$rsCnt = GFetchRowOne($sqlCnt);
$cnt = intval($rsCnt['cnt']);
$offset = ( $pageno-1 ) * $itemPerPage;

$sqlPersonalFB = " SELECT * FROM t_log_personal_fb WHERE TRUE {$where} order by start_time desc limit {$offset} , {$itemPerPage} ";
$rsPersonalFB = GFetchRowSet($sqlPersonalFB);
$pagelist	= getPages($pageno, $cnt, $itemPerPage);

foreach ($rsPersonalFB as &$row) {
	$row['faction_name']=$dictFaction[$row['faction_id']];
	$row['use_time'] = $row['end_time']-$row['start_time'];
	$row['start_time']=date('Y-m-d H:i:s',$row['start_time']);

	if ($row['status'] == 0)
		$row['status'] = "已完成";
	else
		$row['status'] = "未完成";
}

$dateStrPrev = strftime("%Y-%m-%d", $startDateTime - 86400);
$dateStrToday = strftime("%Y-%m-%d");
$dateStrNext = strftime("%Y-%m-%d", $endDateTime + 86400);

$data = array(
	'rsPersonalFB' => $rsPersonalFB,
	'pagelist' => $pagelist,
	'startDate' => $startDate,
	'endDate' => $endDate,
	"dateStrPrev"=> $dateStrPrev,
	"dateStrToday"=> $dateStrToday,
	"dateStrNext"=> $dateStrNext,
	"serverOnLineTime"=> SERVER_ONLINE_DATE,
);
$smarty->assign($data);
$smarty->display("module/analysis/personal_fb.tpl");
exit();