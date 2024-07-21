<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

if (! isset($_REQUEST['dateStart'])){
	$dateStart = date('Y-m-d');
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
$dateStartStamp = strtotime($dateStart . ' 0:0:0');
$dateEndStamp = strtotime($dateEnd . ' 23:59:59');

$dateStartStamp = intval($dateStartStamp) > 0 ? intval($dateStartStamp) : intval(strtotime(SERVER_ONLINE_DATE));
$dateEndStamp = intval($dateEndStamp) > 0 ? intval($dateEndStamp) : time();

$dateStartStr = strftime("%Y-%m-%d", $dateStartStamp);
$dateEndStr = strftime("%Y-%m-%d", $dateEndStamp);

$dateStrPrev = strftime("%Y-%m-%d", $dateStartStamp - 86400);
$dateStrToday = strftime("%Y-%m-%d");
$dateStrNext = strftime("%Y-%m-%d", $dateStartStamp + 86400);

$role_name = SS($_REQUEST['role_name']);
$type =  intval($_REQUEST['type']);
$state = intval($_REQUEST['state']);
if (empty($_POST)) {
	$pageno = 1;
	$type = 1; //默认显示求购的。
	$state = 1; //默认显示仍处理挂单状态的。
}else {
	$pageno = intval($_REQUEST['page']);
	$pageno = $pageno > 1 ? $pageno : 1;
}
$where = " AND lbs.type={$type} ";
$where .= $dateStartStamp && $dateEndStamp ? " AND lbs.create_time BETWEEN {$dateStartStamp} AND {$dateEndStamp} " :'';
$where .= $state ? " AND  lbs.state={$state} " : '' ;
$where .= $role_name ? " AND BINARY rb.role_name='{$role_name}' " : '' ;
$sqlCnt = "SELECT count(lbs.sheet_id) as cnt FROM t_log_bank_sheet lbs, db_role_base_p rb WHERE lbs.role_id=rb.role_id  {$where} ";
$rsCnt = GFetchRowOne($sqlCnt);
$count_result = $rsCnt['cnt'];

$itemPerPage = 50;
$offset = ($pageno-1)*$itemPerPage;
$sql = " SELECT rb.role_name, lbs.* FROM t_log_bank_sheet lbs , db_role_base_p rb WHERE lbs.role_id=rb.role_id {$where} ORDER BY  lbs.create_time desc limit {$offset}, {$itemPerPage} " ;
$rs = GFetchRowSet($sql);
$pagelist	= getPages($pageno, $count_result);

$arrType = array(0=>'挂单卖元宝',1=>'挂单求购元宝');
$arrState= array(0=>'全部',1=>'挂单中',2=>'已结单',3=>'已撤单');
foreach ($rs as &$row) {
	$row['state_str'] = $arrState[$row['state']];
}

$smarty->assign("arrType", $arrType);
$smarty->assign("arrState", $arrState);
$smarty->assign("type", $type);
$smarty->assign("state", $state);
$smarty->assign("role_name", $role_name);

$smarty->assign("rs", $rs);
$smarty->assign("record_count", $count_result);
$smarty->assign("page_list", $pagelist);
$smarty->assign("page_count", ceil($count_result/$itemPerPage));

$smarty->assign("dateStart", $dateStartStr);
$smarty->assign("dateEnd", $dateEndStr);
$smarty->assign("dateStrPrev", $dateStrPrev);
$smarty->assign("dateStrNext", $dateStrNext);
$smarty->assign("dateStrToday", $dateStrToday);

$smarty->display("module/analysis/bank_sheet_view.tpl");
exit;
//////////////////////////////////////////////////////////////
