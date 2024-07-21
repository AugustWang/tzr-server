<?php
/**
 * 收集新手玩家进入游戏后达到3级前的一些数据
 * @author Qingliang.Cn 
 * @date 2011/1/23
 */

session_start();
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_INCLUDE."/global.php";
include_once "./user_auth.php";

$action = $_REQUEST['ac'];

$open_collect = true;
if ($open_collect !== true) {
	exit();	
}
if (!$_SESSION['account_name'] || $_SESSION['role_id'] < 1) {
	exit();
}

$accountName = $_SESSION['account_name'];
$roleID = $_SESSION['role_id'];

//load 是第一个被记录的数据
if ($action == 'load') {
	//记录玩家载入加载页面的总时间
	$loadingTime = intval($_REQUEST['load']);
	if ($loadingTime < 1) {
		exit();
	}
	$maxSpeed = floatval($_REQUEST['max']);
	if ($maxSpeed < 1) {
		exit();
	}
	$minSpeed = floatval($_REQUEST['min']);
	$sqlSelect = "SELECT id FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	_error(GFetchRowOne($sqlSelect));
	if (count(GFetchRowOne($sqlSelect)) > 0) {
		exit();
	}
	
	$arr = array(
				'loading_time' => $loadingTime,
				'max_speed' => $maxSpeed,
				'min_speed' => $minSpeed,
				'begin_enter' => 0,
				'end_enter' => 0,
				'if_move' => 0,
				'account_name' => $_SESSION['account_name'],
				'role_id' => $_SESSION['role_id'],
				'isp' => get_user_isp(get_real_ip()),
				'npc_id_list' => '',
				'npd_id_number' => 0,
				'status' => 1,
				'first_npc_open_time' => 0,
				'enter_time' => 0,
				'welcome_time' => 0,
				'weapon' => 0,
				'monster_id' => 0,
				'attack_monster_time' => 0,
				'if_open_bag' => 0,
				'dead_times' => 0,
				'relive_times' => 0
 	);
	$sqlStr = makeInsertSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 0, 'detail' => $loadingTime);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'e_q_t') {
	//请求进入地图
	$sqlSelect = "SELECT id FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	$result = GFetchRowOne($sqlSelect);
	if (count($result) < 1) {
		exit();
	}
	$arr = array(
				'id' => $result['id'],
				'begin_enter' => time(),
				'status' => 2,
	);
	$sqlStr = makeUpdateSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 1, 'detail' => '');
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'e_r_t') {
	$sqlSelect = "SELECT id,begin_enter FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	$result = GFetchRowOne($sqlSelect);
	if (count($result) < 1) {
		exit();
	}
	$arr = array(
				'id' => $result['id'],
				'end_enter' => time(),
				'enter_time' => time() - $result['begin_enter'],
				'status' => 3,
	);
	$sqlStr = makeUpdateSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 2, 'detail' => time() - $result['begin_enter']);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'move') {
	//玩家移动了
	$sqlSelect = "SELECT id FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	$result = GFetchRowOne($sqlSelect);
	if (count($result) < 1) {
		exit();
	}
	$arr = array(
				'id' => $result['id'],
				'if_move' => 1,
				'status' => 4,
	);
	$sqlStr = makeUpdateSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
} else if ($action == 'npc') {
	//玩家点击NPC了
	//玩家移动了
	$sqlSelect = "SELECT id, first_npc_open_time, npc_id_list, npd_id_number, end_enter FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	$result = GFetchRowOne($sqlSelect);
	if (count($result) < 1) {
		exit();
	}
	$npcID = intval($_REQUEST['npc_id']);
	if ($npcID < 0) {
		exit();
	}
	if ($result['npc_id_list'] == '') {
		$openNpcIDList = $npcID;
		$firstNpcOpenTime = time() - $result['end_enter'];
	} else {
		$openNpcIDList .= "|".$npcID;
		$firstNpcOpenTime = $result['first_npc_open_time'];
	}
	$arr = array(
				'id' => $result['id'],
				'npc_id_list' => $openNpcIDList,
				'npd_id_number' => $result['npd_id_number'] + 1,
				'first_npc_open_time' => $firstNpcOpenTime,
				'status' => 5
	);
	$sqlStr = makeUpdateSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 3, 'detail' => $npcID);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'welcome') {
	$sqlSelect = "SELECT id, end_enter FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	$result = GFetchRowOne($sqlSelect);
	if (count($result) < 1) {
		exit();
	}
	$arr = array(
				'id' => $result['id'],
				'welcome_time' => time() - $result['end_time'],
				'status' => 6,
	);
	$sqlStr = makeUpdateSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 4, 'detail' => time() - $result['end_time']);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'weapon') {
	$sqlSelect = "SELECT id FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	$result = GFetchRowOne($sqlSelect);
	if (count($result) < 1) {
		exit();
	}
	$arr = array(
				'id' => $result['id'],
				'weapon' => 1,
				'status' => 7,
	);
	$sqlStr = makeUpdateSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 5, 'detail' => time() - $result['end_time']);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'monster') {
	$sqlSelect = "SELECT id, monster_id, attack_monster_time FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	$result = GFetchRowOne($sqlSelect);
	if (count($result) < 1) {
		exit();
	}
	if ($result['monster_id'] == 0) {
		$monster_id = intval($_REQUEST['id']);
	} else {
		$monster_id = $result['monster_id'];
	}
	$arr = array(
				'id' => $result['id'],
				'monster_id' => $monster_id,
				'attack_monster_time' => $result['attack_monster_time'] + 1,
				'status' => 8,
	);
	$sqlStr = makeUpdateSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 6, 'detail' => intval($_REQUEST['id']));
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'levelup') {
	$level = intval($_REQUEST['id']);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 10, 'detail' => $level);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'click_m') {
	//点击任务追踪
	$id = intval($_REQUEST['id']);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 11, 'detail' => $id);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'finish_m') {
	$id = intval($_REQUEST['id']);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 12, 'detail' => $id);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'accept_m') {
	$id = intval($_REQUEST['id']);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 13, 'detail' => $id);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'learn_skill') {
	$id = intval($_REQUEST['id']);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 14, 'detail' => $id);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'open_skill') {
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 15, 'detail' => '');
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'open_bag') {
	$sqlSelect = "SELECT id FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	$result = GFetchRowOne($sqlSelect);
	if (count($result) < 1) {
		exit();
	}
	$arr = array(
				'id' => $result['id'],
				'if_open_bag' => 1,
				'status' => 9,
	);
	$sqlStr = makeUpdateSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 7, 'detail' => '');
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'dead') {
	$sqlSelect = "SELECT id, dead_times FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	$result = GFetchRowOne($sqlSelect);
	if (count($result) < 1) {
		exit();
	}
	$arr = array(
				'id' => $result['id'],
				'dead_times' => $result['dead_times'] + 1,
				'status' => 10,
	);
	$sqlStr = makeUpdateSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 8, 'detail' => $result['dead_times'] + 1);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
} else if ($action == 'relive') {
	$sqlSelect = "SELECT id, relive_times FROM `t_log_user_collect` WHERE `role_id`={$_SESSION['role_id']}";
	$result = GFetchRowOne($sqlSelect);
	if (count($result) < 1) {
		exit();
	}
	$arr = array(
				'id' => $result['id'],
				'relive_times' => $result['relive_times'] + 1,
				'status' => 11,
	);
	$sqlStr = makeUpdateSqlFromArray($arr, 't_log_user_collect');
	GQuery($sqlStr);
	$sqlArr = array('account_name'=>$accountName, 'role_id'=>$roleID, 'dateline'=>time(), 'action' => 9, 'detail' => $result['relive_times'] + 1);
	GQuery(makeInsertSqlFromArray($sqlArr, 't_log_new_user'));
}
exit();