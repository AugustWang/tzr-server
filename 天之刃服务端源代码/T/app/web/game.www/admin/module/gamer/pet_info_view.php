<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth, $db, $smarty;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN."/include/dict.php";
include_once SYSDIR_ADMIN."/dict/map_info.php";

$pet_id = intval( $_POST['uid'] );
$action = trim($_REQUEST['action']);
$isPost = intval( $_REQUEST['isPost'] );


if ($pet_id) {
	$pet = UserClass::getPetInfo($pet_id);
	//print_r($pet);die();
	$petSkills = $pet.skills;
}else {
	$errMsg = '请输入查找条件!';
}

$data = array(
	'isPost'=>$isPost,
	'pet'=>$pet,
	'petskills'=>$petSkills,
);



$smarty->assign($data);
$smarty->display('module/gamer/pet_info_view.tpl');

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
