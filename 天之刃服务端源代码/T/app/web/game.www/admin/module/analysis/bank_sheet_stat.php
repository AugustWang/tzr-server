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
$where .= $state ? " AND  lbs.state={$state} " : '' ;
$where .= $role_name ? " AND BINARY rb.role_name='{$role_name}' " : '' ;


$sql = " select * from t_stat_bank_sheet WHERE `type`={$type} and `mtime` BETWEEN {$dateStartStamp} AND {$dateEndStamp} ORDER BY mtime desc " ;
$rs = GFetchRowSet($sql);

$arrType = array(0=>'挂单卖元宝',1=>'挂单求购元宝');
$max_avg_price = 0 ;
$rsCnt = count($rs);
foreach ($rs as &$row) {
	$max_avg_price = $row['avg_price'] > $max_avg_price ?  $row['avg_price'] : $max_avg_price;
	$row['avg_price'] = round($row['avg_price'],1);
}
$max_avg_price = round($max_avg_price,1);

$smarty->assign("arrType", $arrType);
$smarty->assign("type", $type);

$smarty->assign("rs", $rs);
$smarty->assign("max_avg_price", $max_avg_price);
$smarty->assign("rsCnt", $rsCnt);

$smarty->assign("dateStart", $dateStartStr);
$smarty->assign("dateEnd", $dateEndStr);
$smarty->assign("dateStrPrev", $dateStrPrev);
$smarty->assign("dateStrNext", $dateStrNext);
$smarty->assign("dateStrToday", $dateStrToday);

$smarty->display("module/analysis/bank_sheet_stat.tpl");
exit;
//////////////////////////////////////////////////////////////
