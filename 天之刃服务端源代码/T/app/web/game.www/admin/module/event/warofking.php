<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

$action = trim($_GET['action']);

if ($action == 'begin_now') {
	//立刻开始
	getJson(ERLANG_WEB_URL . "/event/warofking/begin_now");
} else if ($action == 'end_now') {
	//立刻结束
	getJson(ERLANG_WEB_URL . "/event/warofking/end_now");
} else if ($action == 'reset') {
	//设置为默认值
	getNothing(ERLANG_WEB_URL . "/event/warofking/reset");
} else if ($action == 'begin_after_60s') {
	getNothing(ERLANG_WEB_URL . "/event/warofking/begin_after_60s");
}

//当前状态
$result = getJson(ERLANG_WEB_URL . "/event/warofking/get_info");
$smarty->assign('nextBeginTime', date('Y-m-d H:i:s', $result['begin_time']));
$smarty->assign('nextEndTime', date('Y-m-d H:i:s', $result['end_time']));
$smarty->display("module/event/warofking.html");
