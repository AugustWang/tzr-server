<?php
/**
 * 官职管理
 * @author QingliangCn
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

$action = trim($_GET['action']);

if ($action == 'set_king') {
	$roleName = trim($_POST['role_name']);
	if ($roleName == '' ) {
		errorExit("角色名不能为空");
	}
	if (validUsername($roleName) !== true) {
		errorExit("角色名格式非法");
	}
	$result = getJson(ERLANG_WEB_URL . "/event/office/set_king/?role_name={$roleName}");
	if ($result['result'] == 'ok') {
		$msg = "成功设置角色 {$roleName} 为国王";
	} else {
		$msg = "设置失败，请检查角色名称";
	}
	
	succExit($msg, null);
}
else if($action == 'set_faction_silver') {
	$factionID = intval($_POST['faction_id']);
	$silver = intval($_POST['silver']);
	$result = getJson(ERLANG_WEB_URL . "/event/office/set_faction_silver/?faction_id={$factionID}&silver={$silver}");
if ($result['result'] == 'ok') {
		$msg = "设置成功";
	} else {
		$msg = "设置失败";
	}
	succExit($msg, null);
}

//当前状态
$smarty->display("module/event/office.html");