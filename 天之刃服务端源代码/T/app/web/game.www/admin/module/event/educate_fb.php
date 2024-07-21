<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

global $smarty;

$action = trim($_GET['action']);
if ($action == 'query') {
	$roleAccount = trim($_GET['roleAccount']);
	$result = getJson(ERLANG_WEB_URL . "/event/educate_fb/query?roleAccount=".$roleAccount);
	$smarty->assign ( array ('vo' => $result ));
	$smarty->display ( "module/event/educate_fb.html" );
	
}else if($action == 'reset_times'){
	$roleId = trim($_GET['roleId']);
	$newTimes = trim($_GET['newTimes']);
	$roleAccount = trim($_GET['roleAccount']);
	$result = getJson(ERLANG_WEB_URL . "/event/educate_fb/reset_times?roleId=".$roleId."&newTimes=".$newTimes."&roleAccount=".$roleAccount);
	$smarty->assign ( array ('vo' => $result ));
	$smarty->display ( "module/event/educate_fb.html" );
}else{
	$result = getJson(ERLANG_WEB_URL . "/event/educate_fb/list");
	$smarty->assign (array('vo' => $result));
	$smarty->display ( "module/event/educate_fb.html" );
}


