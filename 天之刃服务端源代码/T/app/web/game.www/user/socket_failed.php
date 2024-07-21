<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_INCLUDE."/global.php";

$arr = array(
	'role_id' => $_SESSION['role_id'],
	'account_name' => $_SESSION['account_name'],
	'dateline' => time(),
	'isp' => get_user_isp(get_real_ip())
);
GQuery(makeInsertSqlFromArray($arr, 't_log_socket_failed'));