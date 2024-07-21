<?php
define('IN_ODINXU_SYSTEM', true);
include "../../../config/config.php";
include SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
if (file_exists('/data/tzr/server/config/mission/mission.php')) {
	include_once('/data/tzr/server/config/mission/mission.php');
}else {
	die('任务配置文件mission.php丢失了。');
}

$allMissionType = array(0=>'全部',1=>'主','支');
$allUserType = array(0=>'全部',1=>'流失用户',2=>'未流失用户');
$missionType =  intval($_REQUEST['mission_type']);
$userType =  intval($_REQUEST['userType']);
$startDate = $_REQUEST['start_date'] ? $_REQUEST['start_date'] : date('Y-m-d',strtotime('-7day'));
$endDate = $_REQUEST['end_date'] ? $_REQUEST['end_date'] : date('Y-m-d');

$startTime = strtotime($startDate);
$endTime = strtotime($endDate.' 23:59:59');
$startLevel = intval($_REQUEST['startLevel']);
$endLevel = intval($_REQUEST['endLevel']);

$orderby = " ORDER BY lm.mission_id ASC ";
$tblLM = 't_log_mission';
$tblRB = T_DB_ROLE_BASE_P;
$tblRa = T_DB_ROLE_ATTR_P;
$tblRe = T_DB_ROLE_EXT_P;
$tables = " {$tblLM} lm , {$tblRB} rb ";
$where = " AND lm.role_id = rb.role_id AND rb.create_time BETWEEN {$startTime} AND {$endTime} ";
$where .= $missionType ? " AND lm.mission_type={$missionType} "  : '';
if ($startLevel && $endLevel) {
	$tables .= ", {$tblRa} ra ";
	$where .= " AND lm.role_id=ra.role_id AND ra.level BETWEEN {$startLevel} AND {$endLevel} ";
}

$lastLoginTime = strtotime(date('Y-m-d',strtotime('-2day')));
if (1==$userType) {
	$tables .= ", {$tblRe} re ";
	$where .= " AND re.role_id=lm.role_id AND re.last_login_time < {$lastLoginTime} ";
}elseif (2==$userType){
	$tables .= ", {$tblRe} re ";
	$where .= " AND re.role_id=lm.role_id AND re.last_login_time >= {$lastLoginTime} ";
}

$sqlTotal  = "SELECT lm.mission_id, lm.mission_type, SUM(lm.total) AS `total` FROM {$tables} WHERE TRUE {$where} GROUP BY lm.mission_id {$orderby};";
$sqlAccept = "SELECT lm.mission_id, COUNT(*) AS `accept` FROM {$tables} WHERE lm.status=1 {$where} GROUP BY lm.mission_id {$orderby};";
$sqlFinish = "SELECT lm.mission_id, COUNT(*) AS `finish` FROM {$tables} WHERE lm.status=2 {$where} GROUP BY lm.mission_id {$orderby};";
$sqlReward = "SELECT lm.mission_id, COUNT(*) AS `reward` FROM {$tables} WHERE lm.status=3 {$where} GROUP BY lm.mission_id {$orderby};";
$sqlCancel = "SELECT lm.mission_id, COUNT(*) AS `cancel` FROM {$tables} WHERE lm.status=4 {$where} GROUP BY lm.mission_id {$orderby};";

/*echo $sqlTotal;echo '<hr />';
echo $sqlAccept;echo '<hr />';
echo $sqlFinish;echo '<hr />';
echo $sqlReward;echo '<hr />';
echo $sqlCancel;echo '<hr />';die();*/
$rsTotal  = GFetchRowSet($sqlTotal);
$rsAccept = GFetchRowSet($sqlAccept);
$rsFinish = GFetchRowSet($sqlFinish);
$rsReward = GFetchRowSet($sqlReward);
$rsCancel = GFetchRowSet($sqlCancel);

$arrAccept = array();
foreach ($rsAccept as &$row) {
	$arrAccept[$row['mission_id']] = $row['accept'];
}

$arrFinish = array();
foreach ($rsFinish as &$row) {
	$arrFinish[$row['mission_id']] = $row['finish'];
}

$arrReward = array();
foreach ($rsReward as &$row) {
	$arrReward[$row['mission_id']] = $row['reward'];
}

$arrCancel = array();
foreach ($rsCancel as &$row) {
	$arrCancel[$row['mission_id']] = $row['cancel'];
}

$result = array();
foreach ($rsTotal as &$row) {
	$factionId = $dictMission[$row['mission_id']]['faction'];
	if ($factionId) {
		$tmp['mission_id'] = $row['mission_id'];
		$tmp['mission_name'] = $dictMission[$row['mission_id']]['name'];
		$tmp['mission_type'] = $row['mission_type'];
		$tmp['mission_type_name'] = $allMissionType[$row['mission_type']];
		$tmp['total']  = intval($row['total']);
		$tmp['accept'] = intval($arrAccept[$row['mission_id']]);
		$tmp['finish'] = intval($arrFinish[$row['mission_id']]);
		$tmp['reward'] = intval($arrReward[$row['mission_id']]);
		$tmp['cancel'] = intval($arrCancel[$row['mission_id']]);
		if ($tmp['total'] > 0 ) {
			$tmp['accept_rate'] = round($tmp['accept']/$tmp['total']*100,2);
			$tmp['finish_rate'] = round($tmp['finish']/$tmp['total']*100,2);
			$tmp['reward_rate'] = round($tmp['reward']/$tmp['total']*100,2);
			$tmp['cancel_rate'] = round($tmp['cancel']/$tmp['total']*100,2);
		}else {
			$tmp['accept_rate'] = 0;
			$tmp['finish_rate'] = 0;
			$tmp['reward_rate'] = 0;
			$tmp['cancel_rate'] = 0;
		}
		$result[$factionId][$tmp['mission_id']] = $tmp;
	}
}
//echo '<pre>';print_r($result);die();
$data = array(
	'result'=>$result,
	'startDate'=>$startDate,
	'endDate'=>$endDate,
	'missionType' => $missionType,
	'allMissionType' => $allMissionType,
	'startLevel'=>$startLevel,
	'endLevel'=>$endLevel,
	'allUserType'=>$allUserType,
	'userType'=>$userType,
);
$smarty->assign($data);
$smarty->display ( 'module/gamer/task_count_rate.tpl' );
exit;
//////////////////////////////////////////////////////////////

function getSortTypeListOption() {
	return array (
			'mission_id asc' => '任务ID↑',
			'mission_id desc' => '任务ID↓',
			'mission_type asc' => '任务类型↑',
			'mission_type desc' => '任务类型↓',
	);
}
