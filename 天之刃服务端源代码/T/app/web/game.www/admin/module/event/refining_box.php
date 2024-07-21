<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

global $smarty;

$action = trim($_GET['action']);
if ($action == 'list') {
	$result = getJson(ERLANG_WEB_URL . "/event/refining_box/list");
	$smarty->assign ( array ('ctVo' => $result ));
	$smarty->display ( "module/event/refining_box.html" );
	
}else if($action == 'set'){
	$isBoxOpen = trim($_GET['isBoxOpen']); //13:00
	$isBoxFree = trim($_GET['isBoxFree']);
	$result = getJson(ERLANG_WEB_URL . "/event/refining_box/set?isBoxOpen=".$isBoxOpen."&isBoxFree=".$isBoxFree);
	$smarty->assign ( array ('ctVo' => $result ));
	$smarty->display ( "module/event/refining_box.html" );
}else if($action == 'reset'){
	$result = getJson(ERLANG_WEB_URL . "/event/refining_box/reset");
	$smarty->assign ( array ('ctVo' => $result ));
	$smarty->display ( "module/event/refining_box.html" );
}else{
	$result = getJson(ERLANG_WEB_URL . "/event/refining_box/list");
	$smarty->assign (array('ctVo' => $result));
	$smarty->display ( "module/event/refining_box.html" );
}


