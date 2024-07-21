<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_ADMIN."/include/global.php";
global $smarty;


$json = getJson(ERLANG_WEB_URL . "/server");
$smarty->assign('erlangWebUrl', ERLANG_WEB_URL);
$smarty->assign('isDebug', isDebugMode());
$smarty->assign('erlang_version', $json['erlang_version']);
$smarty->assign('product_version', getPoroduct_version());
$smarty->display("main.html");

function getPoroduct_version(){
	$content=file_get_contents("/data/tzr/server/version_server.txt");
	return $content;
}