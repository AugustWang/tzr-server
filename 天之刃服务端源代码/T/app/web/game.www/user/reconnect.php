<?php
/**
 * 用于生成一个key给客户端去连接gateway
 */

ob_start();
session_start();
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once "../config/config.key.php";
include_once SYSDIR_INCLUDE."/global.php";

$action = trim($_REQUEST['action']);
// 测试模式
if (isDebugMode() && empty($_SESSION['account_name'])) {
	$accountName = trim($_REQUEST['account']);
	if ($accountName == '') {
		echo 'failed#empty_account_name';
		exit();
	}
	$roleID = get_account_role_id($accountName);
	if ($roleID < 1) {
		echo 'failed#need_to_create_user';
		exit();
	}
	if ($action == 'get_key') {
		$result = getKey();
		if (!$result) {
			echo 'internal_error';
			exit();
		}
		echo "succ#{$result['line_key']}|{$result['chat_key']}";
		exit();
	} else if ($action == 'get_all') {
		$result = getAllInfoFromMochiweb($accountName,$roleID);
		if ($result && $result['result'] == 'ok') {
			echo $_SESSION['role_id']."|".$result['map_id']."|".$result['level']."|".$result['gateway_host']
				."|".$result['gateway_port']."|".$result['gateway_key'];
		} else {
			// 写错误日志
		}
	} else {
		$result = getAllInfoFromMochiweb($accountName, $roleID);
		echo "succ#{$accountName}@@@@{$roleID}@@@@{$result['lines']}@@@@{$result['chat_key']}";
		exit();
	}
} else {
	if (empty ( $_SESSION['account_name'] ) || empty ( $_SESSION['role_id'] ) || $_SESSION['role_id'] < 0) {
		exit ('error');
	}
	$accountName = $_SESSION['account_name'];
	// 连接不上普通端口的玩家，返回一个有80端口的服务器给他,key不需要重新生成
	// ccd  => cannt_connect_default
	if ($action == 'ccd') {
		$result = get80Line();
		if ($result['result'] != 'error') {
			echo "succ#{$result['ip']}|{$result['port']}";
		} else {
			echo "error";
		}
	} else if ($action == 'get_key') {
		$result = getKey();
		if (!$result) {
			echo 'internal_error';
			exit();
		}
		echo "succ#{$result['line_key']}|{$result['chat_key']}";
		exit();
	} else if ($action == 'get_all') {
		$accountName = $_SESSION['account_name'];
		$result = getAllInfoFromMochiweb($accountName, $_SESSION['role_id']);
		if ($result && $result['result'] == 'ok') {
			echo $_SESSION['role_id']."|".$result['map_id']."|".$result['level']."|".$result['gateway_host']
				."|".$result['gateway_port']."|".$result['gateway_key'];
		} else {
			// 写错误日志
		}
	} else {
		$result = getAllInfoFromMochiweb( $_SESSION['account_name'], $_SESSION['role_id'] );
		echo "succ#{$accountName}@@@@{$roleID}@@@@{$result['lines']}@@@@{$result['chat_key']}";
	}
	exit ();
}
