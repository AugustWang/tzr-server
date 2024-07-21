<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

global $smarty;

$action = trim($_GET['action']);
if ($action == 'list') {
	$result = getJson(ERLANG_WEB_URL . "/event/vwf/list");
	$smarty->assign ( array ('vwfVo' => $result ));
	$smarty->display ( "module/event/vwf.html" );
	
}else if($action == 'start'){
	$interval = trim($_GET['interval']);
	$result = getJson(ERLANG_WEB_URL . "/event/vwf/start?interval=".$interval);
	$smarty->assign ( array ('vwfVo' => $result ));
	$smarty->display ( "module/event/vwf.html" );
}else if($action == 'stop'){
	$result = getJson(ERLANG_WEB_URL . "/event/vwf/stop");
	$smarty->assign ( array ('vwfVo' => $result ));
	$smarty->display ( "module/event/vwf.html" );
}else{
	$result = getJson(ERLANG_WEB_URL . "/event/vwf/list");
	$smarty->assign (array('vwfVo' => $result));
	$smarty->display ( "module/event/vwf.html" );
}


