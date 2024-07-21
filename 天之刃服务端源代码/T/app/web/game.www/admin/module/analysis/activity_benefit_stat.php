<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

if (! isset($_REQUEST['dateStart'])){
	$dateStart = date('Y-m-d',strtotime('-6day'));
}elseif ($_REQUEST['dateStart'] == 'ALL'){
	$dateStart = SERVER_ONLINE_DATE;
}else{
	$dateStart = trim(SS($_REQUEST['dateStart']));
}

if (! isset($_REQUEST['dateEnd'])){
	$dateEnd = strftime("%Y-%m-%d", time());
}elseif ($_REQUEST['dateStart'] == 'ALL'){
	$dateEnd = strftime("%Y-%m-%d", time());
}else{
	$dateEnd = trim(SS($_REQUEST['dateEnd']));
}
 

$dateStartInt = str_replace('-', '', $dateStart);
$dateEndInt = str_replace('-', '', $dateEnd);

$dateStrPrev = strftime("%Y-%m-%d", $dateStartStamp - 86400);
$dateStrToday = strftime("%Y-%m-%d");
$dateStrNext = strftime("%Y-%m-%d", $dateStartStamp + 86400);

if (empty($_POST)) {
	$pageno = 1;
}else {
	$pageno = intval($_REQUEST['page']);
	$pageno = $pageno > 1 ? $pageno : 1;
}
$where = " AND lbs.type={$type} ";


$sql = " select reward_date,task_num,buy_num,count(role_id) as role_count from t_log_activity_benefit " .
		" where `reward_date` BETWEEN {$dateStartInt} AND {$dateEndInt} group by reward_date,task_num,buy_num order by reward_date desc" ;
$rs = GFetchRowSet($sql);

$rsCnt = count($rs);
 

$smarty->assign("rs", $rs); 
$smarty->assign("rsCnt", $rsCnt);

$smarty->assign("dateStart", $dateStart);
$smarty->assign("dateEnd", $dateEnd);
$smarty->assign("dateStrPrev", $dateStrPrev);
$smarty->assign("dateStrNext", $dateStrNext);
$smarty->assign("dateStrToday", $dateStrToday);

$smarty->display("module/analysis/activity_benefit_stat.tpl");
exit;
//////////////////////////////////////////////////////////////
