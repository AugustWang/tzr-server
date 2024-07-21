<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
$auth->assertModuleAccess(__FILE__);

$action = trim ( $_GET ['action'] );
if ('search'==$action) {
	$role = UserClass::getUser($_POST['role_name'],$_POST['account_name'],$_POST['role_id']);
	if (!$role['role_id']) {
		$err = '找不到此玩家相关的升级日志记录';
	}else {
		$sqlExt = ' SELECT * FROM '.T_DB_ROLE_EXT_P.' WHERE role_id='.$role['role_id'];
		$ext = $db->fetchOne($sqlExt);
		
		$sql = " SELECT * FROM `t_log_role_level` WHERE `role_id`={$role['role_id']} ORDER BY log_time DESC ";
		$rsResult = GFetchRowSet($sql);
		
		$sqlLv2 = " SELECT * FROM `t_log_role_level` WHERE `role_id`={$role['role_id']} and level=2 ";
		$rowLv2 = GFetchRowOne($sqlLv2);
		
		$logTimeLv2 = 0;
		if( $rowLv2 ){
			$logTimeLv2 = $rowLv2['log_time'];
		}
		
		foreach ($rsResult as &$row) {
			$row['faction_name'] = $dictFaction[$row['faction_id']];
			$row['elapsed_lv1'] = $row['log_time'] - $role['create_time'];
			$row['elapsed_lv2'] = $row['log_time'] - $logTimeLv2;
		}
		
	}
}
$data = array(
	'role' => $role,
	'ext'=>$ext,
	'result' => $rsResult ,
	'err' => $err
);

$smarty->assign($data);
$smarty->display('module/gamer/gamer_level_log.tpl');
