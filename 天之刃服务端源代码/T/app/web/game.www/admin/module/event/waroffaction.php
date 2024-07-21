<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

$action = trim($_GET['action']);
$attack_faction_id = intval($_GET['attack_faction_id']);
$defence_faction_id = intval($_GET['defence_faction_id']);

if ($action == 'begin_apply') {
	//立刻开始
	$result = getJson(ERLANG_WEB_URL . "/event/waroffaction/begin_apply/?attack_faction_id={$attack_faction_id}&defence_faction_id={$defence_faction_id}");
	if ($result['result'] == 'ok') {
		$msg = "设置成功";
	} else {
		$msg = "设置失败";
	}
	succExit($msg, null);
}else if ($action == 'begin_war') {
	//立刻开始
	$result = getJson(ERLANG_WEB_URL . "/event/waroffaction/begin_war/?attack_faction_id={$attack_faction_id}&defence_faction_id={$defence_faction_id}");
	if ($result['result'] == 'ok') {
		$msg = "设置成功";
	} else {
		$msg = "设置失败";
	}
	succExit($msg, null);
} else if ($action == 'end_war') {
	//立刻结束
	$result = getJson(ERLANG_WEB_URL . "/event/waroffaction/end_war/?attack_faction_id={$attack_faction_id}&defence_faction_id={$defence_faction_id}");
	if ($result['result'] == 'ok') {
		$msg = "设置成功";
	} else {
		$msg = "设置失败";
	}
	succExit($msg, null);
} else if ($action == 'reset') {
	//设置为默认值
	$result = getJson(ERLANG_WEB_URL . "/event/waroffaction/reset");
	if ($result['result'] == 'ok') {
		$msg = "设置成功";
	} else {
		$msg = "设置失败";
	}
	succExit($msg, null);
}

//当前状态
$ret = getJson(ERLANG_WEB_URL . "/event/waroffaction/get_info");
$smarty->assign('attack_faction_id', $ret['attack_faction_id']);
$smarty->assign('defence_faction_id', $ret['defence_faction_id']);
$smarty->assign('seconds', $ret['seconds']);
$smarty->display("module/event/waroffaction.html");
