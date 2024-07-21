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

$startTime = $_REQUEST['dateStart'] ? strtotime($_REQUEST['dateStart']) : strtotime(date('Y-m-d',strtotime('-6day')));
$endTime = $_REQUEST['dateEnd'] ? strtotime($_REQUEST['dateEnd']) : strtotime(date('Y-m-d'));
$startTime = $startTime < strtotime(SERVER_ONLINE_DATE) ? strtotime(SERVER_ONLINE_DATE) : $startTime;
$endTime = $endTime && $endTime >= $startTime ? $endTime + 86399 : time();

$dateStart = date('Y-m-d',$startTime);
$dateEnd = date('Y-m-d',$endTime);
$datePrev = date('Y-m-d',$startTime-86400);
$dateNext = date('Y-m-d',$startTime+86400);
$dateToday = date('Y-m-d');
$serverOnLineDate = SERVER_ONLINE_DATE;

$pageno = getUrlParam('page');
if (isPost() || !$pageno ) { //重新提交表单或没设置page时,默认为1
	$pageno = 1;
}


$role_name = SS($_REQUEST['role_name']);
if ($role_name) {
	$role_id = UserClass::getUseridByRoleName($role_name);
}
if (!$role_id) {
	if (isPost()) {
	 	$strMsg = '没有此玩家相关的记录';
	 }else {
	 	$strMsg = '请输入玩家角色名进行查询';
	 }
}else {
	$where = " WHERE mdate >='{$dateStart}' AND mdate <='{$dateEnd}' ";
	$where .= " AND role_id={$role_id} ";
	$sqlCnt = " SELECT COUNT(`id`) as cnt FROM t_log_citan {$where} ";
	$rsCnt = GFetchRowOne($sqlCnt);
	$rowCnt = intval($rsCnt['cnt']);
	$offset = ($pageno -1) * LIST_PER_PAGE_RECORDS;
	$pagelist	= getPages($pageno, $rowCnt);
	
	$sqlQuery = " SELECT * FROM t_log_shoubian {$where} ORDER BY mdate DESC limit {$offset} , ".LIST_PER_PAGE_RECORDS;
	$rsResult = GFetchRowSet($sqlQuery);
	foreach ($rsResult as &$row) {
		$row['faction_name'] = $dictFaction[$row['faction_id']];
		$row['status'] = $arrStatus[$row['status']];
	}
}

$data = array(
	'role_name' => $role_name,
	'result' => $rsResult,
	'pagelist'=>$pagelist,
	'dateStart'=>$dateStart,
	'dateEnd' => $dateEnd,
	'datePrev' => $datePrev,
	'dateNext' => $dateNext,
	'dateToday' => $dateToday,
	'serverOnLineDate'=>$serverOnLineDate,
	'strMsg' => $strMsg,
);
$smarty->assign($data);
$smarty->display("module/gamer/shoubian_view.tpl");
