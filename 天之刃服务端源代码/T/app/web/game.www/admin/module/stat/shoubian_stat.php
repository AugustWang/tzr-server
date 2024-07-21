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

//守边状态:
$arrStatus = array(
	1=>'成功',
	2=>'超时',
	3=>'放弃任务',
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
			   FROM t_log_shoubian
			   WHERE mdate>='{$dateStart}' AND mdate <='{$dateEnd}' 
			   GROUP BY mdate, total 
			   ORDER BY mdate DESC ";
$rsGuoTan = GFetchRowSet($sqlGuoTan);

$sqlActive = " SELECT ymd, COUNT(role_id) AS active 
			   FROM t_log_active_user_daily 
			   WHERE ymd >= {$ymdStart} AND ymd <={$ymdEnd}
			   GROUP BY ymd 
			   ORDER BY ymd DESC ";
$rsActive = GFetchRowSet($sqlActive);


$sqlFail = "  SELECT SUM(`fail`) AS fail_sum ,  mdate
				FROM t_log_shoubian
				WHERE mdate>='{$dateStart}' AND mdate <='{$dateEnd}'  
				GROUP BY mdate
				ORDER BY mdate DESC  ";
$rsFail = GFetchRowSet($sqlFail);


$sqlPrize = "  SELECT count(`role_id`) AS get_prize_person ,  mdate
				FROM t_log_shoubian
				WHERE `success`=4  and mdate>='{$dateStart}' AND mdate <='{$dateEnd}'  
				GROUP BY mdate
				ORDER BY mdate DESC  ";
$rsPrize = GFetchRowSet($sqlPrize);


$arrResult = array();
foreach ($rsGuoTan as &$row) {
	$ymd = str_replace('-','',$row['mdate']);
	$key  = 'join_'.$row['total'];
	$arrResult[$ymd]['mdate'] = $row['mdate'];
	$arrResult[$ymd][$key] = $row['total_person'];
	$arrResult[$ymd]['join_all'] += $row['total_person'];
}

foreach ($rsActive as &$row) {
	$arrResult[$row['ymd']]['active'] = $row['active'];
}

foreach ($rsFail as &$row) {
	$ymd = str_replace('-','',$row['mdate']);
	$arrResult[$ymd]['fail_sum'] = $row['fail_sum'];
}

foreach ($rsPrize as &$row) {
	$ymd = str_replace('-','',$row['mdate']);
	$arrResult[$ymd]['get_prize_person'] = $row['get_prize_person'];
}

foreach ($arrResult as &$row) {
	$row['join_all_rate'] = $row['active'] > 0 ? round($row['join_all']*100/$row['active'],1) : 0;
	$row['get_prize_person_rate'] = $row['join_all'] > 0 ? round($row['get_prize_person']*100/$row['join_all'],1) : 0;
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
$smarty->display("module/stat/shoubian_stat.tpl");
