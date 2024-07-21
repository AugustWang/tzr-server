<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth, $db, $smarty;

$auth->assertModuleAccess(__FILE__);

$year = date('Y');
$month = date('m');
$day = date('d');

//先取出最大的在线
$sql = "select max(online) as online from ".T_LOG_ONLINE
	." where year={$year} and month = {$month} and day={$day}";
$result = $db->fetchAll($sql);
$maxOnline = $result[0]['online'];
//不分页显示
$sql = "select online, dateline from ".T_LOG_ONLINE
	." where year={$year} and month = {$month} and day={$day} order by dateline desc";
	
$result = $db->fetchAll($sql);
foreach ($result as &$v) {
	$v['weight'] = @($v['online'] / $maxOnline) * 480;
}

$smarty->assign(array('onlines' => $result));
$smarty->display("module/online/today.tpl");