<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_ADMIN."/include/global.php";
include_once SYSDIR_ADMIN."/class/base.config.php";

global $smarty, $ADMIN_PAGE_CONFIG;

$smarty->assign('ADMIN_MENU_TITLE', ADMIN_MENU_TITLE);
$smarty->assign("catalogue", page_structure($ADMIN_PAGE_CONFIG));
$smarty->display("left_gen.html");

exit;

function page_structure($config) {
	global $auth;
	$struct = array();
	$classes = array();
	foreach($config as $pid => $page) {
		$url = $page['url'];
		if($_SESSION ['username'] != ROOT_USERNAME ||filterRootAuthority($pid)){
		if($auth->assertModuleIDAccess($pid, false)) {
			if($class = $page['class']) {
				if(!isset($classes[$class])) {
					$classes[$class] = count($struct);
					$struct[$classes[$class]]['name'] = $class;
				}
				$struct[$classes[$class]]['pages'][$pid] = $page;
			}
		}
		}
	}
	return $struct;
}

	function filterRootAuthority($id){
		if (isDebugMode()) {
			return true;
		}
		if(57==$id||56==$id||55==$id){
			return true;
		}
		return false;
	}
