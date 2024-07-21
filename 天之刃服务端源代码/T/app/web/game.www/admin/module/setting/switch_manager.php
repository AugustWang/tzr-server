<?php
/**
 * 开关管理
 * @author QingliangCN
 */

$_DCACHE = null;
define('DIRECT_LOGIN_PHP', "../../../user/game.php");
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);


$type= trim($_REQUEST['type']);
$action = trim($_REQUEST['action']);

//防沉迷
if ($type == 'fcm') {
	if ($action == 'close') {
		setFcmFlag(false);
		sleep(2);
	} else {
		setFcmFlag(true);
		sleep(2);
	}
} else if ($type == 'game') {
	if ($action == 'close') {
		setGameState(false);
	} else {
		setGameState(true);
	}
} else if ($type == 'platform') {
if ($action == 'close') {
		setPlatformState(false);
	} else {
		setPlatformState(true);
	}
}else if ($type == 'guestMode'){
	if ($action == 'close') {
		setGuestAccountFlag(false);
		sleep(2);
	} else {
		setGuestAccountFlag(true);
		sleep(2);
	}
}

$fcmStatus = getFcmStatus();
$platformState = getPlatFormState();
$AllGameState = getAllGameState();
$guestModeStatus = getGuestAccountFlag();

$smarty->assign('fcmStatus', $fcmStatus);
$smarty->assign('platformState', $platformState);
$smarty->assign('AllGameState', $AllGameState);
$smarty->assign('guestModeStatus', $guestModeStatus);
$smarty->display('module/setting/switch_manager.html');


function setGameState($flag) {
	if ($flag) {
		// 开启服务
		@unlink("/data/tzr/web/allgame.lock");
	} else {
		file_put_contents("/data/tzr/web/allgame.lock", "游戏维护中或者尚未开放");
	}
}

function setPlatformState($flag) {
	if ($flag) {
		// 开启服务
		@unlink("/data/tzr/web/platform.lock");
	} else {
		file_put_contents("/data/tzr/web/platform.lock", "游戏维护中或者尚未开放");
	}
}

// 禁止平台登录，通过文件锁来判断
function getPlatFormState() {
	if (file_exists("/data/tzr/web/platform.lock")) {
		return false;
	}
	return true;
}
// 禁止所有的登录，通过文件锁来实现
function getAllGameState() {
	if (file_exists("/data/tzr/web/allgame.lock")) {
		return false;
	}
	return true;
}

//获取防沉迷状态
function getFcmStatus() {
	$result = getWebJson('/system/get_fcm/');
	if ($result['result'] == 'ok') {
		return $result['fcm'];
	}
	return 0;
}

/**
 * 设置防沉迷状态
 * @param bool $flag
 */
function setFcmFlag($flag) {
	if ($flag) {
		$flag = 1;
	} else {
		$flag = 0;
	}
	$result = getWebJson('/system/set_fcm/?flag='.$flag);
	if ($result['result'] == 'ok') {
		return true;
	}
	return false;
}
/**
 * 获取游客模式
 */
function getGuestAccountFlag() {
	$result = getWebJson('/system/get_guest_mode/');
	if ($result['result'] == 'ok') {
		return $result['guest_mode'];
	}
	return 0;
}
/**
 * 是否开启游客模式
 * @param bool $flag
 */
function setGuestAccountFlag($flag) {
	if ($flag) {
		$flag = 1;
	} else {
		$flag = 0;
	}
	$result = getWebJson('/system/set_guest_mode/?flag='.$flag);
	if ($result['result'] == 'ok') {
		return true;
	}
	return false;
}
