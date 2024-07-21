<?php
/*
 * Author: odinxu, MSN: odinxu@hotmail.com
 * 2008-9-5
 *
 */
/*
define('IN_ODINXU_SYSTEM', true);

//用户登录验证，  同时，在这里也引用全站通用的配置和函数，包括数据库类等
include_once '../class/admin_auth.php';

//检查，确认当前用户是否具有对本文件的操作权限
$ADMIN->checkPhpScriptPower(__FILE__, true);

//if ($ADMIN->userlevel != 1 && $ADMIN->userlevel != 4)
//	die('权限不够');

//使用模板
include_once SYSDIR_INCLUDE . '/smarty_init.php';*/

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
include_once SYSDIR_ADMIN.'/include/dict.php';

//刺探或国探任务最终状态:
$arrStatus = array(
	2=>'已领奖',
	3=>'放弃任务',
);
$arrType = array(
	1=>'刺探',
	2=>'国探',
);


$startTime = $_REQUEST['dateStart'] ? strtotime($_REQUEST['dateStart']) : strtotime(date('Y-m-d',strtotime('-7day')));
$endTime = $_REQUEST['dateEnd'] ? strtotime($_REQUEST['dateEnd']) : strtotime(date('Y-m-d',strtotime('-1day')));
$endTime = $endTime >= strtotime(date('Y-m-d')) ?  strtotime(date('Y-m-d',strtotime('-1day'))) : $endTime;
$startTime = $startTime < strtotime(SERVER_ONLINE_DATE) ? strtotime(SERVER_ONLINE_DATE) : $startTime;
$endTime = $endTime && $endTime >= $startTime ? $endTime + 86399 : time();

$dateStart = date('Y-m-d',$startTime);
$dateEnd = date('Y-m-d',$endTime);
$datePrev = date('Y-m-d',$startTime-86400);
$dateNext = date('Y-m-d',$startTime+86400);
$dateYestoday = date('Y-m-d',strtotime('-1day'));
$serverOnLineDate = SERVER_ONLINE_DATE;

$ymdStart = date('Ymd',$startTime);
$ymdEnd = date('Ymd',$endTime);


$sqlGuoTan = " SELECT total, COUNT(`role_id`) AS total_person ,mdate 
			   FROM t_log_citan 
			   WHERE `type`=2 AND mdate>='{$dateStart}' AND mdate <='{$dateEnd}' 
			   GROUP BY mdate, total 
			   ORDER BY mdate DESC ";
$rsGuoTan = GFetchRowSet($sqlGuoTan);

$sqlActive = " SELECT ymd, COUNT(role_id) AS active 
			   FROM t_log_active_user_daily
			   WHERE ymd >= {$ymdStart} AND ymd <={$ymdEnd}
			   GROUP BY ymd 
			   ORDER BY ymd DESC ";
$rsActive = GFetchRowSet($sqlActive);

$arrResult = array();
$diffDay = intval( (strtotime($dateEnd) - strtotime($dateStart))/86400 );

for($i=$diffDay; $i>=0; $i--){
	$time = strtotime("+{$i}day",$startTime);
	$ymd = date('Ymd',$time);
	$arrResult[$ymd]['mdate']  =date('Y-m-d',$time);
	$arrResult[$ymd]['active'] =0;
	$arrResult[$ymd]['join_1'] =0;
	$arrResult[$ymd]['join_2'] =0;
	$arrResult[$ymd]['join_3'] =0;
	$arrResult[$ymd]['join_4'] =0;
	$arrResult[$ymd]['join_all'] = 0;
}

foreach ($rsGuoTan as &$row) {
	$ymd = str_replace('-','',$row['mdate']);
	$key  = 'join_'.$row['total'];
	$arrResult[$ymd]['mdate'] = $row['mdate'];
	$arrResult[$ymd][$key] = intval($row['total_person']);
	$arrResult[$ymd]['join_all'] += intval($row['total_person']);
}

foreach ($rsActive as &$row) {
	$arrResult[$row['ymd']]['active'] = intval($row['active']);
}

foreach ($arrResult as &$row) {
	$row['join_all_rate'] = $row['active'] > 0 ? round($row['join_all']*100/$row['active'],1) : 0;
	$row['join_1_rate'] = $row['active'] > 0 ? round($row['join_1']*100/$row['active'],1) : 0;
	$row['join_1_rate'] = $row['active'] > 0 ? round($row['join_2']*100/$row['active'],1) : 0;
	$row['join_1_rate'] = $row['active'] > 0 ? round($row['join_3']*100/$row['active'],1) : 0;
	$row['join_1_rate'] = $row['active'] > 0 ? round($row['join_4']*100/$row['active'],1) : 0;
}

$data = array(
	'result' => $arrResult,
	'dateStart'=>$dateStart,
	'dateEnd' => $dateEnd,
	'datePrev' => $datePrev,
	'dateNext' => $dateNext,
	'dateYestoday' => $dateYestoday,
	'serverOnLineDate'=>$serverOnLineDate,
);
$smarty->assign($data);
$smarty->display("module/stat/guotan_stat.tpl");
