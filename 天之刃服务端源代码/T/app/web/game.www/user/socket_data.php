<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_INCLUDE."/global.php";

// socket类型
$type = strtolower(trim($_REQUEST['type']));
if ($type != 'line' && $type != 'chat') {
	exit();
}
$host = strtolower(trim($_REQUEST['host']));
if (!$host) {
	exit();
}
$port = intval(trim($_REQUEST['port']));
if ($port < 1) {
	exit();
}
$reason = intval(trim($_REQUEST['reason']));

$arr = array(
	'type' => $type,
	'host' => $host,
	'port' => $port,
	'reason' => $reason,
	'role_id' => $_SESSION['role_id'],
	'account_name' => $_SESSION['account_name'],
	'dateline' => time(),
	'isp' => get_user_isp(get_real_ip())
);
GQuery(makeInsertSqlFromArray($arr, 't_log_socket'));
