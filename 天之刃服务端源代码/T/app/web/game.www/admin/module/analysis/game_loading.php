<?php
/**
 * 3级玩家数据统计分析
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

//记录的总数量
$sql = "SELECT count(id) as count FROM `t_log_user_collect`";
$result = GFetchRowOne($sql);
$allSize = $result['count'];
if ($allSize < 1) {
	echo "尚无数据";
	exit();
}
$smarty->assign('allSize', $allSize);

//状态为3表示已经收到map_enter_toc了
$sqlAllEnter = "SELECT count(id) as count FROM `t_log_user_collect` WHERE `status`>=3";
$result = GFetchRowOne($sqlAllEnter);
$allEnterSize = $result['count'];

$smarty->assign('allEnterSize', $allEnterSize);

//流失率
$leavePercentage = sprintf("%.2f", 100 * ($allSize - $allEnterSize) / $allSize);

//平均加载时间
$sql = "SELECT avg(loading_time) as ave_loading_time, max(loading_time) as max_loading_time,".
		"min(loading_time) as min_loading_time, avg(max_speed) as avg_max_speed ,"
		." avg(npd_id_number) as avg_npd_id_number, "
		." max(first_npc_open_time) as max_first_npc_open_time,"
		." min(first_npc_open_time) as min_first_npc_open_time,"
		." avg(first_npc_open_time) as avg_first_npc_open_time,"
		." avg(welcome_time) as avg_welcome_time,"
		." avg(dead_times) as avg_dead_times,"
		." avg(relive_times) as avg_relive_times,"
		." avg(min_speed) as age_min_speed FROM  `t_log_user_collect`";
$result = GFetchRowOne($sql);

$smarty->assign('leavePercentage', $leavePercentage);
$smarty->assign('averageLoadTime', intval($result['ave_loading_time']));
$smarty->assign('maxLoadTime', intval($result['max_loading_time']));
$smarty->assign('minLoadTime', intval($result['min_loading_time']));
$smarty->assign('maxLoadSpeed', intval($result['avg_max_speed']));
$smarty->assign('minLoadSpeed', intval($result['age_min_speed']));
$smarty->assign('averageLoadSpeed', (intval($result['avg_max_speed']) + intval($result['age_min_speed']))/2);
$smarty->assign('averageNpcOpenNum', intval($result['avg_npd_id_number']));


$smarty->assign('welcomeAvgTime', intval($result['avg_welcome_time']));
$smarty->assign('avgDeadTimes', intval($result['avg_dead_times']));
$smarty->assign('avgReliveTimes', intval($result['avg_relive_times']));

$sql = "SELECT avg(loading_time) as ave_loading_time, max(loading_time) as max_loading_time,".
		"min(loading_time) as min_loading_time, avg(max_speed) as avg_max_speed ,"
		." avg(npd_id_number) as avg_npd_id_number, "
		." max(first_npc_open_time) as max_first_npc_open_time,"
		." min(first_npc_open_time) as min_first_npc_open_time,"
		." avg(first_npc_open_time) as avg_first_npc_open_time,"
		." avg(welcome_time) as avg_welcome_time,"
		." avg(dead_times) as avg_dead_times,"
		." avg(relive_times) as avg_relive_times,"
		." avg(min_speed) as age_min_speed FROM  `t_log_user_collect` WHERE end_enter > 0 and first_npc_open_time > 0";
$result = GFetchRowOne($sql);
$smarty->assign('averageOpenNpcTime', intval($result['avg_first_npc_open_time']));
$smarty->assign('minOpenNpcTime', intval($result['min_first_npc_open_time']));
$smarty->assign('maxOpenNpcTime', intval($result['max_first_npc_open_time']));

//移动过的玩家数量
$sql = "SELECT count(id) as count FROM `t_log_user_collect` WHERE if_move = 1";
$result = GFetchRowOne($sqlAllEnter);
$allMoveSize = $result['count'];
$movePercepage = sprintf("%.2f", 100 * $allMoveSize / $allEnterSize);

$smarty->assign('movePercentage', $movePercepage);

//死亡过的玩家
$sql = "SELECT count(id) as count FROM `t_log_user_collect` WHERE dead_times > 0 ";
$result = GFetchRowOne($sql);
$allDeadSize = $result['count'];
$deadPercentage = sprintf("%.2f", 100 * $allDeadSize / $allEnterSize);
$smarty->assign('deadPercentage', $deadPercentage);

// 复活过的玩家
$sql = "SELECT count(id) as count FROM `t_log_user_collect` WHERE relive_times > 0 ";
$result = GFetchRowOne($sql);
$allReliveSize = $result['count'];
if ($allDeadSize > 0 ) {
	$relivePercentage = sprintf("%.2f", 100 * $allReliveSize / $allDeadSize);
} else {
	$relivePercentage = "0.00";
}

$smarty->assign('relivePercentage', $relivePercentage);

// 打开过背包的玩家
$sql = "SELECT count(id) as count FROM `t_log_user_collect` WHERE if_open_bag = 1";
$result = GFetchRowOne($sql);
$allOpenBagSize = $result['count'];
$openBagPercentage = sprintf("%.2f", 100 * $allOpenBagSize / $allEnterSize);
$smarty->assign('openBagPercentage', $openBagPercentage);

$smarty->display("module/analysis/game_loading.html");