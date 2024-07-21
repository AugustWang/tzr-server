<?php
/*
 * Author: odinxu, MSN: odinxu@hotmail.com
 * 2008-9-5
 *
 */
/*
define('IN_ODINXU_SYSTEM', true);

//用户登录验证，  同时，在这里也引用全站通用的配置和函数，包括数据库类等
include_once '../class/admin_auth.php';

//检查，确认当前用户是否具有对本文件的操作权限
$ADMIN->checkPhpScriptPower(__FILE__, true);

//if ($ADMIN->userlevel != 1 && $ADMIN->userlevel != 4)
//	die('权限不够');

//使用模板
include_once SYSDIR_INCLUDE . '/smarty_init.php';*/

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

if (! isset($_REQUEST['dateStart'])){
	$dateStart = SERVER_ONLINE_DATE;
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

$brandid  = (int)$_REQUEST['brand_id'];
$seriesid = (int)$_REQUEST['series_id'];
$min_price = (int)$_REQUEST['min_price'];
$max_price = (int)$_REQUEST['max_price'];
$q = SS($_REQUEST['q']);
$search_sort_1 = SS($_REQUEST['sort_1']);
$search_sort_2 = SS($_REQUEST['sort_2']);
$account_name = SS(trim($_REQUEST['account_name']));
$role_name = SS(trim($_REQUEST['role_name']));
$pageno = getUrlParam('page');
if ($_POST['account_name'] || $_POST['role_name']) {
	$pageno = 1;
}
$ex = SS($_REQUEST['excel']);

if (empty($search_sort_1))		$search_sort_1 = "pay_time desc";
if (empty($search_sort_2))		$search_sort_2 = "id desc";

$search_sort .= $search_sort_1 . ", ". $search_sort_2;
$where = '1';

$where		.=" AND `pay_time`>={$dateStartStamp} AND `pay_time`<={$dateEndStamp}";
$where		.= $account_name ? " AND `account_name`='{$account_name}' " :'';
$where		.= $role_name ? " AND `role_name`='{$role_name}' " :'';
$tablename	= T_DB_PAY_LOG_P;
$count_result = 0;
if(isset($ex) && $ex == true){
	$excel	= true;
}
$keywordlist	= getList($tablename, $where, $pageno, $search_sort, LIST_PER_PAGE_RECORDS, $count_result);
$pagelist	= getPages($pageno, $count_result);

//输出Excel文件
if(isset($ex) && $ex == true ){
	$excel		= getExcel($tablename, $where, $search_sort);
	$smarty->assign('title', $excel['title']); // 标题
	$smarty->assign('hd', $excel['hd']);       // 表头
	$smarty->assign('num',$excel['hdnum']);    // 列数
	$smarty->assign('ct', $excel['content']);  // 内容

	// 输出文件头，表明是要输出 excel 文件
	header('Content-type: application/vnd.ms-excel');
	header('Content-Disposition: attachment; filename='.$excel['title'].date('_Ymd_Gi').'.xls');
	$smarty->display('module/pay/pay_excel.tpl');
	exit;
}

//排序的
$sortlistopgion  = getSortTypeListOption();

$smarty->assign("search_sort_1", $search_sort_1);
$smarty->assign("search_sort_2", $search_sort_2);
$smarty->assign("search_keyword", $q);
$smarty->assign("search_brandid", $brandid);
$smarty->assign("search_seriesid", $seriesid);
$smarty->assign("account_name", $account_name);
$smarty->assign("role_name", $role_name);

$smarty->assign("mix_names",    $mix_names);
$smarty->assign("mix_selectd",  $mix_selectd);

$smarty->assign("record_count", $count_result);
$smarty->assign("keywordlist", $keywordlist);
$smarty->assign("page_list", $pagelist);
$smarty->assign("page_count", ceil($count_result/LIST_PER_PAGE_RECORDS));
$smarty->assign('sortoption', $sortlistopgion);

$smarty->assign("dateStart", $dateStartStr);
$smarty->assign("dateEnd", $dateEndStr);

$smarty->assign("dateStrPrev", $dateStrPrev);
$smarty->assign("dateStrNext", $dateStrNext);
$smarty->assign("dateStrToday", $dateStrToday);

$smarty->display("module/pay/pay_view.tpl");
exit;
//////////////////////////////////////////////////////////////



function getExcel($tablename, $where, $search_sort){
	if($search_sort != '')
		$search_sort = "ORDER BY " . $search_sort; 
	$sql		= "SELECT * FROM $tablename WHERE $where $search_sort";
	$row_all	= GFetchRowSet($sql);
	$excel = array();

	// 标题
	$excel['title'] = '所有充值记录明细';
	// 表头
	$excel['hd'] =  array(
			'ID',
			'订单号',
			'角色ID',
			'角色名',
			'帐号名',
			'角色等级',
			'充值时间',
			'充值获得元宝数',
			'人民币',
			);
	// 列数
	$excel['hdnum'] = count($excel['hd']);

	$excel['content'] = array();
	foreach($row_all as $k=>$v){
		$excel['content'][$k] = array();
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['id']);
		$excel['content'][$k][] = array('StyleID'=>'s28', 'Type'=>'String', 'content'=>$v['order_id'].' '.$v['desc']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['role_id']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['role_name']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['account_name']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['role_level']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>date('Y-m-d G:i:s',$v['pay_time']));
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['pay_gold']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['pay_money']);
	}
	return $excel;
}

function getSortTypeListOption()
{
	return array(
			"id asc"  => 'ID↑',
			"id desc" => 'ID↓',
			"pay_time asc"  => '充值时间↑',
			"pay_time desc" => '充值时间↓',
			"pay_money asc"  => '人民币↑',
			"pay_money desc" => '人民币↓',
			"pay_gold asc"  => '充值金币↑',
			"pay_gold desc" => '充值金币↓',
			"account_name asc"  => '帐号名↑',
			"account_name desc" => '帐号名↓',
			"role_name asc"  => '角色名↑',
			"role_name desc" => '角色名↓',
			"order_id asc"  => '订单号↑',
			"order_id desc" => '订单号↓',

		    );
}
