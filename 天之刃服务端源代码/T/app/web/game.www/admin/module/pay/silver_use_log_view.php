<?php
/*
 * Author: wuzesen@mingchao.com
 * 2010-10-26
 * 查询用户银两使用记录
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

define('T_LOG_USE_SILVER_','tzr_logs.t_log_use_silver_');


include_once SYSDIR_ADMIN.'/class/log_silver_class.php';
include_once SYSDIR_ADMIN.'/class/admin_item_class.php';


//使用模板
$acname  = trim(SS($_REQUEST['acname']));
$nickname = trim(SS($_REQUEST['nickname']));
$start = trim(SS($_REQUEST['start']));
$end = trim(SS($_REQUEST['end']));
$search_sort_1 = SS($_REQUEST['sort_1']);
$search_sort_2 = SS($_REQUEST['sort_2']);
$ex = SS($_REQUEST['excel']);
$mtype = SS($_REQUEST['mtype_name']);

if (empty($search_sort_1))		$search_sort_1 = "mtime desc";	
if (empty($search_sort_2))		$search_sort_2 = "id desc";


if(empty($start) or empty($end))
{
	$month = date("Y_m",time());
	$start = date("Y-m-d",time());
	$intstart = strtotime($start);
	$intend = $intstart+24*60*59;
	$end = date("Y-m-d",$intend);
	$tablename = T_LOG_USE_SILVER_.$month;	
}else{
	$intstart = strtotime($start);
	$intend = strtotime($end)+24*60*59;
	$start_month = date("Y_m",$intstart);
	$end_month=date("Y_m",$intend);
	if($start_month==$end_month)
	{
		$tablename  = T_LOG_USE_SILVER_.$start_month;
	}
	else
	{
		$_error="起始时间和结束时间必须在同一月份";
	}

}

$typename = LogSilverClass::GetTypeList();
$typelist =array(0=>'全部类型')+ $typename;

$userid = 0;
if ($nickname) 
{
	$userid = UserClass::getUseridByRoleName($nickname);
}

if ($userid<1)
{
	if ($acname)
	{
		$userid = UserClass::getUseridByAccountName($acname);
	}	
}
if ($userid > 0 && empty($_error)){
	$acname  = trim(SS($acname));
	$nickname = trim(SS($nickname));
	$userid  = trim(SS($userid));
	$pageno = intval(getUrlParam('page'));
	$search_sort .= $search_sort_1 . ", ". $search_sort_2;
	
	$where = " `user_id` = '{$userid}'  ";
	
	if($mtype>0)
	{
		$mtype = trim(SS($mtype));
		$where .= " AND `mtype` = '{$mtype}' ";
	}
	
	if(!empty($intstart) && !empty($intend))
	{
		$where.=" AND `mtime` > '{$intstart}' AND `mtime` < '{$intend}' ";	
	}
	//$tablename = "t_log_use_silver";
		
	//满足搜索条件的银两求和。
	$balance = getBanlance($tablename, $where);
	$itemNameMap = AdminItemClass::getItemMap();

	$count_result	= 0;
	$keywordlist	= getNewList($tablename, $where, $pageno, $search_sort, LIST_PER_PAGE_RECORDS, $count_result);
	$excel		= getExcel($tablename, $where, $search_sort, $typename);
	$pagelist	= getPages($pageno, $count_result);

	for($i=0;$i<count($keywordlist);$i++)
	{
		$keywordlist[$i]['mtype_name'] = $typename[$keywordlist[$i]['mtype']];	
		$keywordlist[$i]['item_name'] = $itemNameMap[$keywordlist[$i]['itemid']];	
		$keywordlist[$i]['silver_bind'] = silverUnitConvert($keywordlist[$i]['silver_bind']);
		$keywordlist[$i]['silver_unbind'] = silverUnitConvert($keywordlist[$i]['silver_unbind']);
	}
}

echo "<font color ='red' >".$_error."</font>\n";

$smarty->assign('start',$start);
$smarty->assign('end',$end);

/*
function getList($tablename, $where, $pageno = 1, $order = "id", $per_page_record = LIST_PER_PAGE_RECORDS, & $counts) {
	global $db;
	$sql = SqlSelectClass :: getInstance($tablename, true, true)->select('*')->where($where)->orderby($order)->limit(SqlFuncHelperClass :: calcLimitOffset($pageno, $per_page_record), $per_page_record)->createSql();
	$rowset = $db->fetchAll($sql);
	
	$counts = GFetchRowOne('SELECT FOUND_ROWS() as counts;');
	$counts = $counts['counts'];
			
	return $rowset;
}
*/




function getNewList($tablename, $where, $pageno = 1, $order = "id", $per_page_record = LIST_PER_PAGE_RECORDS, & $counts) {
	$start = LIST_PER_PAGE_RECORDS * ($pageno-1);
	$sql = "select SQL_CALC_FOUND_ROWS * from $tablename where $where order by $order limit $start,$per_page_record ";
	$rowset = GFetchRowSet($sql);
	$counts = GFetchRowOne('SELECT FOUND_ROWS() as counts;');
	$counts = $counts['counts'];
	return $rowset;
}




	
//输出Excel文件
if(isset($ex) && $ex == true ){
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
$smarty->assign("balance", $balance);
$smarty->assign("mtype", $mtype);
$smarty->assign("typelist",$typelist);
$smarty->assign("search_sort_1", $search_sort_1);
$smarty->assign("search_sort_2", $search_sort_2);
$smarty->assign("search_keyword1", $acname);
$smarty->assign("search_keyword2", $nickname);
$smarty->assign("search_keyword3", $userid);
$smarty->assign("record_count", $count_result);
$smarty->assign("keywordlist", $keywordlist);
$smarty->assign("page_list", $pagelist);
$smarty->assign("page_count", ceil($count_result/LIST_PER_PAGE_RECORDS));
$smarty->assign('sortoption', $sortlistopgion);
$smarty->display("module/pay/silver_use_log_view.tpl");

//获取银两流水统计
function getBanlance($tablename, $where)
{
	$sql = "select SUM(silver_bind)+SUM(silver_unbind) as s from  ".$tablename."  where ".$where;
	$row = GFetchRowOne($sql);
	return $row['s'];
}






function getExcel($tablename, $where, $search_sort, $typename){
	if($search_sort != '')
		$search_sort = "ORDER BY " . $search_sort; 
	$sql		= "SELECT * FROM $tablename WHERE $where $search_sort";
	$row_all	= GFetchRowSet($sql);
	$excel = array();

	// 标题
	$excel['title'] = '银两使用记录';
	// 表头
	$excel['hd'] =  array(
			'ID', 
			'使用时间', 
			'绑定银两(文)', 
			'绑定银两', 
			'不绑定银两(文)', 
			'不绑定银两', 
			'操作类型', 
			'操作内容', 
			'角色ID'
			);
	// 列数
	$excel['hdnum'] = count($excel['hd']);

	$excel['content'] = array();
	foreach($row_all as $k=>$v){
		$excel['content'][$k] = array();
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['id']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>date('Y-m-d G:i:s',$v['mtime']));
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['silver_bind']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>silverUnitConvert($v['silver_bind']));
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['silver_unbind']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>silverUnitConvert($v['silver_unbind']));
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$typename[$v['mtype']]);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['mdetail']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['user_id']);
	}
	return $excel;
}

function getSortTypeListOption()
{
	return array(
			"id asc"  => 'ID↑',
			"id desc" => 'ID↓',
			"mtime asc"  => '使用时间↑',
			"mtime desc" => '使用时间↓',		
			"silver_bind asc"  => '绑定银两数↑',
			"silver_bind desc" => '绑定银两数↓',	
			"silver_unbind asc"  => '不绑定银两数↑',
			"silver_unbind desc" => '不绑定银两数↓',		
			"mtype asc"  => '操作类型↑',
			"mtype desc" => '操作类型↓',
			"mdetail asc"  => '操作内容↑',
			"mdetail desc" => '操作内容↓',	
			"user_id asc"  => '角色ID↑',
			"user_id desc" => '角色ID↓',
			);
}
