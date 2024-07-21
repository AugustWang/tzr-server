<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $smarty,$auth;
$auth->assertModuleAccess(__FILE__);

$start = strtotime($_REQUEST['start']) or $start = GetTime_Today0() ;
$end = strtotime($_REQUEST['end']) or $end = time();
$minlv = intval($_REQUEST['minlv']);
$maxlv = intval($_REQUEST['maxlv']);
if ($maxlv < 10) {
	$maxlv = getMaxLv();
}


if($_REQUEST['ac']) {
	$rs = getAllStat($start, $end, $minlv, $maxlv);
	$smarty->assign('rs', $rs);
	
} else {
	$now = time();
	$start = strtotime('-3 days');
	$end = $now;
}

$smarty->assign('now', $now);
$smarty->assign('start', $start);
$smarty->assign('end', $end);
$smarty->assign('minlv', $minlv);
$smarty->assign('maxlv', $maxlv);
$smarty->display("module/analysis/login_event_rate.tpl");
exit;



function getAllStat($start,$end,$minlv,$maxlv){
	global $db;
	$sql = "select count(*) as totalNum,level  from db_role_ext_p as ext ,db_role_attr_p as attr,db_role_base_p as acc 
	where ext.role_id = attr.role_id and attr.role_id = acc.role_id
	and create_time > $start and create_time <$end and  level >= $minlv and level <= $maxlv
	group by level";
	
	$lossTime = strtotime("-3days");
	
	//改为last_offline_time
	$lossSql = " select count(*) as lossNum,level from db_role_ext_p as ext,db_role_attr_p as attr,db_role_base_p as acc 
	where ext.role_id = attr.role_id  and ext.role_id = acc.role_id and last_offline_time < $lossTime 
	and create_time > $start and create_time <$end and  level >= $minlv and level <= $maxlv
	group by level";
	
	
	$allAry  = GFetchRowSet($sql);
	$lossAry = GFetchRowSet($lossSql);
	
	
	foreach ($allAry as &$item) {
		$level = $item['level'];
		$item['lossNum'] = getLossNumlOf($lossAry,$level);
		$item['deviedNum'] = getNumDownTo($allAry,$level);
	}//level totalNum lossNum
	return $allAry;	
}


function getMaxLv(){
	$sql = "select max(level) as l from db_role_attr_p";
	$maxLevel = GFetchRowOne($sql);
	return $maxLevel['l'];
}

function getNumDownTo($allAry,$le){
	$total = 0;
	foreach ($allAry as $item) {
		if ($item['level'] >= $le) {
			$total += $item['totalNum'];	
		}
	}
	return $total;
}


function getLossNumlOf($lossAry,$level){
	foreach ($lossAry as $item) {
		if ($item['level'] == $level) {
			return $item['lossNum'];
		}
	}
	return 0; //没有loss的情况
}


