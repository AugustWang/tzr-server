<?php
/**
 * 分时统计充值情况
 * @author linruirong@mingchao.com
 *
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

$sqlCount = " SELECT COUNT(*) as `cnt` FROM ( SELECT  `account_name`  FROM ".T_DB_PAY_LOG_P." GROUP BY `account_name` ) AS TmpPay ";
$cnt = GFetchRowOne($sqlCount);
$cnt = intval( $cnt['cnt'] ); 

$pageno = getUrlParam('page');
$per_page_record = LIST_PER_PAGE_RECORDS;
$offset = ($pageno - 1) * $per_page_record;

$table1 = T_DB_PAY_LOG_P;
$table2 = T_DB_ROLE_EXT_P;

//======== 查结果 =====
$sql = " SELECT pl.account_name, pl.role_id, pl.role_name , SUM(pl.pay_money) AS total , 
			MIN(pl.pay_money) as `min_pay` ,MAX(pl.pay_money) AS `max_pay`, 
			AVG(pl.pay_money) as `avg_pay` , COUNT(pl.id) AS `times` ,
			MAX(pl.pay_time) as `max_pay_time` , re.last_login_time
		 FROM  {$table1} pl
		 LEFT JOIN {$table2} re
		 ON pl.role_id=re.role_id
		 GROUP BY pl.account_name
		 ORDER BY  `total` DESC LIMIT {$offset},{$per_page_record} ";
$result = GFetchRowSet($sql);
//======== end 查结果 =====

$pages = getPages($pageno,$cnt,$per_page_record);
if (is_array($result)) {
	foreach ($result as $key => &$row) {
		$row['rank_no'] = ( $pageno - 1 ) * $per_page_record + $key + 1 ;
		$row['diff_day'] =  $row['last_login_time'] ? intval( ( time() - $row['last_login_time'])/86400 ) :'';
		$row['total'] = round($row['total'],1);
		$row['min_pay'] = round($row['min_pay'],1);
		$row['max_pay'] = round($row['max_pay'],1);
		$row['avg_pay'] = round($row['avg_pay'],1);
	}
}

$data = array(
	'rankList' => $result,
	'page_list' => $pages,
	'page'=>$pageno,
	'per_page_record'=>$per_page_record,
);
//echo '<pre>';print_r($data);die();
$smarty->assign($data);
$smarty->display("module/pay/pay_rank.tpl");



