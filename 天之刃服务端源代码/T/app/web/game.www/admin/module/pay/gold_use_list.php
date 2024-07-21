<?php
/*
 * Author: wuzesen
 * 2010-1-6
 *
 */
$_DCACHE = null;
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/log_gold_class.php';


//if ($ADMIN->userlevel != 1 && $ADMIN->userlevel != 4)
//	die('权限不够');


if ( !isset($_REQUEST['dateStart']))
	$dateStart = SERVER_ONLINE_DATE;
else if ( $_REQUEST['dateStart'] == 'ALL') {
    $dateStart  = SERVER_ONLINE_DATE;
}
else
	$dateStart  = trim(SS($_REQUEST['dateStart']));

if ( !isset($_REQUEST['dateEnd']))
	$dateEnd = strftime ("%Y-%m-%d", time() );
else if ( $_REQUEST['dateStart'] == 'ALL') {
    $dateEnd = strftime ("%Y-%m-%d", time() );
}
else
	$dateEnd = trim(SS($_REQUEST['dateEnd']));

$dateStartStamp = strtotime($dateStart . ' 0:0:0');
$dateEndStamp   = strtotime($dateEnd . ' 23:59:59');
$dateStartStamp = $dateStartStamp ? $dateStartStamp : strtotime(SERVER_ONLINE_DATE);
$dateEndStamp = $dateEndStamp ? $dateEndStamp : time();

$dateStartStr = strftime ("%Y-%m-%d", $dateStartStamp);
$dateEndStr   = strftime ("%Y-%m-%d", $dateEndStamp);

$dateStrPrev  = strftime ("%Y-%m-%d", $dateStartStamp - 86400);
$dateStrToday = strftime ("%Y-%m-%d");
$dateStrNext  = strftime ("%Y-%m-%d", $dateStartStamp + 86400);

$strConsumeTypes = implode(',',array_keys(LogGoldClass::getSpendTypeList()));
$where = " WHERE log.`mtime` >={$dateStartStamp} AND log.`mtime` <= {$dateEndStamp} AND  log.mtype in ({$strConsumeTypes}) " ;
$sqlCnt = "SELECT count(DISTINCT(log.user_id)) as cnt FROM t_log_use_gold log {$where} ";
$rsCnt = GFetchRowOne($sqlCnt);
$cnt = intval($rsCnt['cnt']);
$resetPage = intval($_REQUEST['resetPage']);
$pageno = isPost() || $resetPage ? 1 : getUrlParam('page');
$per_page_record = LIST_PER_PAGE_RECORDS;
$pages = getPages($pageno,$cnt,$per_page_record);
$offset = ($pageno - 1) * $per_page_record;

$sql = "SELECT log.`user_id`,log.`user_name`,log.`account_name`,
		SUM(log.`gold_bind`)+SUM(log.`gold_unbind`) as ug, 
		SUM(log.`gold_bind`) as gb, SUM(log.`gold_unbind`) as gub,
		ext.last_login_time
		FROM `t_log_use_gold` log LEFT JOIN db_role_ext_p ext on ext.role_id=log.user_id 
		{$where}
		GROUP BY log.user_id ORDER BY ug DESC  LIMIT {$offset},{$per_page_record} ";
$rs = GFetchRowSet($sql);

foreach ($rs as $key => &$row) {
	$row['rank_no'] = ( $pageno - 1 ) * $per_page_record + $key + 1 ;
	$row['diff_day'] = $row['last_login_time'] ? intval( ( time() - $row['last_login_time'])/86400 ) :'';
}
//var_export($rs);
$data = array(
	'rs'=>$rs,
	'page_list' => $pages,
	'page'=>$pageno,
	'per_page_record'=>$per_page_record,
);
$smarty->assign($data);
$smarty->assign("search_keyword1", $dateStartStr);
$smarty->assign("search_keyword2", $dateEndStr);

$smarty->assign("dateStrPrev", $dateStrPrev);
$smarty->assign("dateStrNext", $dateStrNext);
$smarty->assign("dateStrToday", $dateStrToday);

$smarty->display("module/pay/gold_use_list.tpl");

?>