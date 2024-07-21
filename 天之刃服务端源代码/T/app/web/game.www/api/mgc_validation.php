<?php
ob_start();
session_start();
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_INCLUDE."/global.php";
include_once SYSDIR_INCLUDE."/mgc.php";
include_once SYSDIR_INCLUDE.'/name_data.php';
include_once "../config/config.key.php";

$userName = trim(urldecode($_GET['new_rolename']));
$roleID = intval($_GET['role_id']);
_error($userName.":".$roleID);
// 过滤用户名:非法字符和大小写转换
if (validateUserName ( $userName ) === false) {
	echo "error#{$roleID}@用户名只能由字母、数字以及汉字组成，长度必须在2-7个字符之间";
	exit ();
}
if (($rtn = filterMGZ ( $userName )) !== true) {
	echo "error#{$roleID}@包含非法字符:" . $rtn;
	exit ();
}
echo "ok#{$roleID}@{$userName}";
exit();