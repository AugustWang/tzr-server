<?php

/*
 * Author: wuzesen
 * 获取道具列表
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/admin_item_class.php';


$itemClass = new AdminItemClass();
$item_name = trim(SS($_REQUEST['item_name']));
$action = trim(SS($_REQUEST['action']));


$rsData = array();

if($action && $item_name != ''){//搜索
	$itemList = AdminItemClass::getItemByName($item_name);
	$rsData = transferItemList($itemList);

}else{
	$itemList = AdminItemClass::getItemList();
	$rsData = transferItemList($itemList);
}
$smarty->assign('rsData', $rsData);
$smarty->display("module/gamer/gamer_item_list.tpl");

function transferItemList($itemList){
	$rsData = array();
	foreach($itemList as $k => $v){
		 if( $v["type"] == 1 ){
		 	 $v["type"] = "道具";
		 }else if( $v["type"] == 2 ){
		 	 $v["type"] = "宝石";
		 }else if( $v["type"] == 3 ){
		 	 $v["type"] = "装备";
		 } 
	     $rsData[$k] =  $v;
	}
	return $rsData;
}


exit;
