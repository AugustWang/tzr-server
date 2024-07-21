<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth, $db, $smarty;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN."/include/dict.php";
include_once SYSDIR_ADMIN."/dict/map_info.php";

$role_id = intval( $_POST['uid'] );
$role_name = SS( $_REQUEST['nickname'] );
$account_name = SS( $_REQUEST['acname'] );
$action = trim($_REQUEST['action']);
$isPost = intval( $_REQUEST['isPost'] );
$where = '';
if ($role_id) {
	$where .= " AND role_id=".$role_id;
}else {
	$where.= $account_name ? " AND BINARY account_name='".$account_name."' ": '';
	$where.= $role_name ? " AND BINARY role_name='".$role_name."' ": '';
}
if (trim( $where )) {
	$sqlBase = " SELECT * FROM ".T_DB_ROLE_BASE_P." WHERE TRUE ".$where;
	$base = $db->fetchOne($sqlBase);
}else {
	$errMsg = '请输入查找条件!';
}


if ($base['role_id']) {
	$petBag = UserClass::getRolePetBag($base['role_id']);
//	print_r($petBag);die();
	$pets=$petBag['pets'];
}

$data = array(
	'isPost'=>$isPost,
	'base'=>$base,
	'petBag'=>$petBag,
	'pets'=>$pets,
);



$smarty->assign($data);
$smarty->display('module/gamer/gamer_pet_info.tpl');

exit();
///////////////////



function getTimeStr($minute)
{
	$hour = $minute >= 60 ? intval($minute/60) : 0;
	$minute = $minute%60;
	$str = $hour > 0 ? $hour.'小时' : '';
	$str .= $minute > 0 ? $minute.'分钟' : '';
	return $str ? $str : '0分钟';
}
