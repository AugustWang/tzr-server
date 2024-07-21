<?php
/*
 * Author: odinxu, MSN: odinxu@hotmail.com
 * 2008-9-5
 *
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth, $smarty;

$auth->assertModuleAccess(__FILE__);

$q = SS($_REQUEST['q']);
$search_sort_1 = SS($_REQUEST['sort_1']);
$search_sort_2 = SS($_REQUEST['sort_2']);
$pageno = getUrlParam('page');

if (empty($search_sort_1))		$search_sort_1 = "dateline desc";
if (empty($search_sort_2))		$search_sort_2 = "dateline desc";

$search_sort .= $search_sort_1 . ", ". $search_sort_2;


$where = '1';


$tablename =  "t_log_online";
//要显示的内容
$count_result = 0;
$keywordlist = getList($tablename, $where, $pageno, $search_sort, LIST_PER_PAGE_RECORDS, $count_result);
$pagelist = getPages($pageno, $count_result);


$max_online = 0;
foreach($keywordlist as $v)
{
	if ($v['real'] > $max_online)
		$max_online = $v['real'];
}

$TD_WIDTH = 550;
foreach($keywordlist as $k=>$v){
	if ($max_online == 0) {
		$keywordlist[$k]['width'] = 0;
		$keywordlist[$k]['red'] = ($v['real'] >= 1000);		
	}else{
	$keywordlist[$k]['width'] = ceil($v['real'] / $max_online * $TD_WIDTH);
	$keywordlist[$k]['red'] = ($v['real'] >= 1000);		
	}
}

//平均每天在线
$avgonline=AvgCount();
//最高在线
$maxonline=MaxCount();
//最低在线
$minonline=MinCount();

//排序的
$sortlistopgion  = getSortTypeListOption();

$smarty->assign("search_sort_1", $search_sort_1);
$smarty->assign("search_sort_2", $search_sort_2);
$smarty->assign("search_keyword", $q);

$smarty->assign("record_count", $count_result);
$smarty->assign("keywordlist", $keywordlist);
$smarty->assign("page_list", $pagelist);
$smarty->assign("page_count", ceil($count_result/LIST_PER_PAGE_RECORDS));

$smarty->assign("maxcount", $maxonline["maxcount"]);
$smarty->assign("mincount", $minonline["mincount"]);
$smarty->assign("avgcount", $avgonline["avgcount"]);

$smarty->assign('sortoption', $sortlistopgion);
$smarty->display("module/online/online_view.tpl");
exit;
//////////////////////////////////////////////////////////////

function getSortTypeListOption()
{
	return array(
			"dateline asc"  => '统计时间↑',
			"dateline desc" => '统计时间↓',
		);
}



//某时间段内最高在线人数
function MaxCount($field = 'online')
{
	$sql= " SELECT max(`{$field}`) as maxcount  FROM `t_log_online`;";
	//$rs = GFetchRowSet($sql, getDbConnWrite());
	$row = GFetchRowOne($sql);
	return $row;
}

//某时间段内最低在线人数
function MinCount($field = 'online')
{
	$sql= " SELECT min(`{$field}`) as mincount  FROM `t_log_online`;";
	$row = GFetchRowOne($sql);
	return $row;	
}

//某时间段内平均在线人数
function AvgCount($field = 'online')
{
	$sql= " SELECT avg(`{$field}`) as avgcount  FROM `t_log_online`;";
	$row = GFetchRowOne($sql);
	return $row;
}
