<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

global $smarty;

$action = trim($_GET['action']);
if ($action == 'list') {
	$result = getJson(ERLANG_WEB_URL . "/event/country_treasure/list");
	$smarty->assign ( array ('ctVo' => $result ));
	$smarty->display ( "module/event/country_treasure.html" );
	
}else if($action == 'start'){
	$startTime = trim($_GET['startTime']); //13:00
	$startSeconds=strtotime($startTime.":00");
	$keepInterval = trim($_GET['keepInterval']);
	$result = getJson(ERLANG_WEB_URL . "/event/country_treasure/start?startSeconds=".$startSeconds."&keepInterval=".$keepInterval);
	$smarty->assign ( array ('ctVo' => $result ));
	$smarty->display ( "module/event/country_treasure.html" );
}else if($action == 'reset'){
	$result = getJson(ERLANG_WEB_URL . "/event/country_treasure/reset");
	$smarty->assign ( array ('ctVo' => $result ));
	$smarty->display ( "module/event/country_treasure.html" );
}else{
	$result = getJson(ERLANG_WEB_URL . "/event/country_treasure/list");
	$smarty->assign (array('ctVo' => $result));
	$smarty->display ( "module/event/country_treasure.html" );
}


