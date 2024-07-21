<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth, $db, $smarty, $dictMapInfo, $dictWeaponType, $dictPkMode, $dictFaction, $dictBuffType;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN."/class/vip_class.php";

$role_id = intval( $_GET['uid'] );
$role_name = SS( $_REQUEST['nickname'] );
$account_name = SS( $_REQUEST['acname'] );

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

if(empty($errMsg) and $base['role_id'])
{
	$vip = VipClass::getVipInfo($base['role_id']);
	$roleId = $base['role_id'];
	$roleName = $base['role_name'];
	$accountName = $base ['account_name'];
	$vipTime = 0;
	$vipLevel = 0;
	$vipEndTime = 0;
	if(!empty($vip))
	{
		$vipTime = $vip['total_time'];
		$vipLevel = $vip['vip_level'];
		if($vip['end_time']<time())
		{
			$vipEndTime="已过期";
		}
		else
		{
			$vipEndTime= date("Y-m-d H:i:s", $vip['end_time']) ;
		}
	}
	$smarty->assign('role_id',$roleId);
$smarty->assign('account_name',$accountName);
$smarty->assign('role_name',$roleName);
$smarty->assign('vip_time',$vipTime);
$smarty->assign('vip_level',$vipLevel);
$smarty->assign('vip_end_time',$vipEndTime);

}


$smarty->display('module/gamer/gamer_vip.tpl');


?>