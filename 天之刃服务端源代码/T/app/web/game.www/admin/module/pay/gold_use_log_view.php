<?php
/*
 * Author: wuzesen@mingchao.com
 * 2010-10-26
 * 查询用户元宝使用记录
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/log_gold_class.php';
include_once SYSDIR_ADMIN.'/class/admin_item_class.php';


//使用模板

$acname  = trim(SS($_REQUEST['acname']));
$nickname = trim(SS($_REQUEST['nickname']));
$start = trim(SS($_REQUEST['start']));
$end = trim(SS($_REQUEST['end']));
$userid  = trim(SS($_REQUEST['userid']));
$search_sort_1 = SS($_REQUEST['sort_1']);
$search_sort_2 = SS($_REQUEST['sort_2']);
$ex = SS($_REQUEST['excel']);
$mtype = SS($_REQUEST['mtype_name']);

if (empty($search_sort_1))		$search_sort_1 = "mtime desc";	
if (empty($search_sort_2))		$search_sort_2 = "id desc";
if(is_numeric($_REQUEST['forceFlag']))
{
	$forceFlag = $_REQUEST['forceFlag'];
}
else if($_REQUEST['forceFlag'] == 'on')
{
	$forceFlag = 1;
}else{
	$forceFlag = 0;
}


if(empty($start) or empty($end))
{
	$start = date("Y-m-d",time());
	$intstart = strtotime($start);
	$intend = $intstart+24*60*59;
	$end = date("Y-m-d",$intend);
}else{
	$intstart = strtotime($start);
	$intend = strtotime($end)+24*60*59;
}

//global warning
$smarty->assign("warning","");

//forceFalg

$forceFlag = 1;

$typename = LogGoldClass::GetTypeList();
$typelist =array(0=>'全部类型')+ $typename;

if((!empty($acname)) || (!empty($nickname)) ||(!empty($userid)))
{
	$acname  = trim(SS($acname));
	$nickname = trim(SS($nickname));
	$userid  = trim(SS($userid));
	$pageno = getUrlParam('page');
	$search_sort .= $search_sort_1 . ", ". $search_sort_2;
	$where = '1';


	if(!empty($userid))
	{
		$where .= " AND `user_id` = '{$userid}' ";
	}
	if (!empty($acname)) 
	{	
		if($forceFlag == 1)
		{
			$where .= " AND `account_name` = '{$acname}'";
		}else{
			$where .= " AND `account_name` like '%{$acname}%'";
		}
	}

	if (!empty($nickname)) 
	{
		if($forceFlag == 1)
		{
			$where .= " AND `user_name` = '{$nickname}'";
		}else{
			$where .= " AND `user_name` like '%{$nickname}%'";
		}
	}
	
	if(!empty($intstart) && !empty($intend))
	{
		$where.=" AND `mtime` > '{$intstart}' AND `mtime` < '{$intend}' ";	
	}


	$tablename = "t_log_use_gold";
	//满足搜索条件的元宝求和。
	$balance = getBanlance($tablename, $where);
	if(count($balance) <1 ){
		$smarty->assign("warning","对应记录的数目为0");
	}

	if($mtype>0)
	{
		$mtype = trim(SS($mtype));
		$where .= " AND `mtype` = '{$mtype}' ";
	}
	
	$itemNameMap = AdminItemClass::getItemMap();

	$count_result	= 0;
	$keywordlist	= getList($tablename, $where, $pageno, $search_sort, LIST_PER_PAGE_RECORDS, $count_result);
	$excel		= getExcel($tablename, $where, $search_sort, $typename);
	$pagelist	= getPages($pageno, $count_result);

	for($i=0;$i<count($keywordlist);$i++)
	{
		$keywordlist[$i]['mtype_name'] = $typename[$keywordlist[$i]['mtype']];	
		$keywordlist[$i]['item_name'] = $itemNameMap[$keywordlist[$i]['itemid']];	
	}
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
$smarty->assign('start',$start);
$smarty->assign('end',$end);


//排序的
$sortlistopgion  = getSortTypeListOption();
$smarty->assign("balance", $balance);
$smarty->assign("mtype", $mtype);
$smarty->assign("typelist",$typelist);
$smarty->assign("forceFlag", $forceFlag);
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
$smarty->display("module/pay/gold_use_log_view.tpl");

//获取元宝流水统计
function getBanlance($tablename, $where)
{
	$sql = "select SUM(gold_bind)+SUM(gold_unbind) as s from  ".$tablename."  where ".$where;
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
	$excel['title'] = '元宝使用记录';
	// 表头
	$excel['hd'] =  array(
			'ID', 
			'使用时间', 
			'绑定元宝',
			'元宝', 
			'操作类型', 
			'操作内容', 
			'账号名', 
			'角色名', 
			'角色ID'
			);
	// 列数
	$excel['hdnum'] = count($excel['hd']);

	$excel['content'] = array();
	foreach($row_all as $k=>$v){
		$excel['content'][$k] = array();
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['id']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>date('Y-m-d G:i:s',$v['mtime']));
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['gold_bind']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['gold_unbind']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$typename[$v['mtype']]);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['mdetail']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['account_name']);
		$excel['content'][$k][] = array('StyleID'=>'s29', 'Type'=>'String', 'content'=>$v['user_name']);
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
			"gold_bind asc"  => '绑定元宝数↑',
			"gold_bind desc" => '绑定元宝数↓',	
			"gold_unbind asc"  => '元宝数↑',
			"gold_unbind desc" => '元宝数↓',			
			"mtype asc"  => '操作类型↑',
			"mtype desc" => '操作类型↓',
			"mdetail asc"  => '操作内容↑',
			"mdetail desc" => '操作内容↓',	
			"user_id asc"  => '角色ID↑',
			"user_id desc" => '角色ID↓',
		    );
}
