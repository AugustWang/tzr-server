<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

$nodes = getJson ( ERLANG_WEB_URL ."/nodes" );
foreach ( $nodes as $k => $v ) {
	if (strpos ( $v, 'behavior' ) !== false) {
		$type = '行为日志服务';
	} else if (strpos ( $v, 'chat' ) !== false) {
		$type = '聊天服务';
	} else if (strpos ( $v, 'map' ) !== false || strpos ( $v, 'mgeem' ) !== false) {
		$type = '地图服务';
	} else if (strpos ( $v, 'login' ) !== false) {
		$type = '登录服务';
	} else if (strpos ( $v, 'world' ) !== false) {
		$type = '世界服务';
	} else if (strpos ( $v, 'mgee_line' ) !== false) {
		$type = '分线服务';
	} else if (strpos ( $v, 'db' ) !== false) {
		$type = '数据库服务';
	}
	$nodes [$k] = array ('mem' => 0, 'name' => $v, 'type' => $type );
}
$smarty->assign ( array ('nodes' => $nodes ) );
$smarty->display ( "module/statistics/server_info.html" );

