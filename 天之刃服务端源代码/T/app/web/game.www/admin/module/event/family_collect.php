<?php
/**
 * 门派采集活动
 * @author QingliangCn
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

$action = trim($_GET['action']);

if ($action == 'open_family_collect') {
	$familyId = intval($_POST['family_id']);
	
	$result = getJson(ERLANG_WEB_URL . "/event/family_collect/open_family_collect/?family_id={$familyId}");
	if ($result['result'] == 'ok') {
		$msg = "开启门派 {$roleName} 采集活动成功";
	} else {
		$msg = "开启门派采集活动失败";
	}
	
	succExit($msg, null);
}
else if($action == 'end_family_collect') {
	$familyId = intval($_POST['family_id']);
	$result = getJson(ERLANG_WEB_URL . "/event/family_collect/end_family_collect/?family_id={$familyId}");
if ($result['result'] == 'ok') {
		$msg = "设置成功";
	} else {
		$msg = "设置失败";
	}
	succExit($msg, null);
}

//当前状态
$smarty->display("module/event/family_collect.html");