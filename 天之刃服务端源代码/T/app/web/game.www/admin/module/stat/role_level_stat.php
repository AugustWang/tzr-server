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
$smarty->display("module/stat/role_level_stat.tpl");
exit;



function getAllStat($start,$end,$minlv,$maxlv){
	global $db;
	$sql = " SELECT min(t1.log_time - t2.log_time) as mintime,t1.level as level, FLOOR( avg( t1.log_time - t2.log_time ) ) as elapsed, count(1) as role_count " .
			" FROM t_log_role_level t1,  `v_log_role_level_2` t2, db_role_base_p t3 " .
			" WHERE t1.role_id = t2.role_id and t2.role_id=t3.role_id and t3.create_time > $start and t3.create_time <$end and t1.level >= $minlv and t1.level <= $maxlv " .
			" GROUP BY t1.level ORDER BY t1.level";
	
	$allAry  = GFetchRowSet($sql);
	return $allAry;	
}


function getMaxLv(){
	$sql = "select max(level) as l from db_role_attr_p";
	$maxLevel = GFetchRowOne($sql);
	return $maxLevel['l'];
}




