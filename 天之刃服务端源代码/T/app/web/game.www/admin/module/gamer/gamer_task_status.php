<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
if (file_exists('/data/tzr/server/config/mission/mission.php')) {
        include_once('/data/tzr/server/config/mission/mission.php');
}else {
        die('任务配置文件mission.php丢失了。');
}
$action = trim ( $_GET ['action'] );
if ('search'==$action) {
	$role = UserClass::getUser($_POST['role_name'],$_POST['account_name'],$_POST['role_id']);
	if (!$role['role_id']) {
		$err = '找不到此玩家相关的任务日志记录';
	}else {
		$sql = " SELECT * FROM `t_log_mission` WHERE `role_id`={$role['role_id']} ORDER BY mtime DESC ";
		$tasks = GFetchRowSet($sql);
		$missionTypes = array(1=>'主',2=>'支');
		$statusName = array(1=>'已接受',2=>'已完成',3=>'已领奖',4=>'已取消');
		foreach ($tasks as &$row) {
			$row['mission_name'] = $dictMission[$row['mission_id']]['name'];
			$row['mission_type_name'] = $missionTypes[$row['mission_type']];
			$row['status_name'] = $statusName[$row['status']];
			$row['mtime'] = date('Y-m-d H:i:s',$row['mtime']);
		}
	}
}
$data = array(
	'role' => $role,
	'tasks' => $tasks ,
	'err' => $err
);

$smarty->assign($data);
$smarty->display('module/gamer/gamer_task_status.tpl');
