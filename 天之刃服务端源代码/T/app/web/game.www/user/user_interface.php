<?php
/**
 * 玩家常用功能接口
 * @author QingliangCn
 * @create_time 2011/6/17
 */

ob_start();
session_start();
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_INCLUDE."/global.php";

global $cache;

$roleID = intval($_SESSION['role_id']);
if ($roleID < 1) {
	exit();
}
$action = trim($_GET['ac']);
if ($action == 'set_fullscreen') {
	// 设置全屏
	$sql = "INSERT INTO `t_user_interface` (`role_id`, `full_screen_flag`) VALUES ('$roleID', 1) ON DUPLICATE KEY UPDATE `full_screen_flag` = 1";
	GQuery($sql);
	$cache->delete(CACHE_KEY_USER_FULLSCREEN_FLAG.$_SESSION['role_id']);
} else if ($action == 'exit_fullscreen') {
	// 退出全屏
	$sql = "INSERT INTO `t_user_interface` (`role_id`, `full_screen_flag`) VALUES ('$roleID', 0) ON DUPLICATE KEY UPDATE `full_screen_flag` = 0";
	GQuery($sql);
	$cache->delete(CACHE_KEY_USER_FULLSCREEN_FLAG.$_SESSION['role_id']);
}
echo 'ok';
exit();