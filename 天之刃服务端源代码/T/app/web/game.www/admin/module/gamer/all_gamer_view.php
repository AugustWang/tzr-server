<?php

/*

select a.role_id,a.role_name,a.account_name,c.create_time, /*d.last_login_time, * a.last_login_ip,a.level,b.status 
	from 
		db_role_attr_p a,db_account_p c,db_role_base_p b/*,db_role_ext d*

*/

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

define('SIZE_PER_PAGE',20);

$search_sort_1 = SS($_REQUEST['sort_1']);
$search_sort_2 = SS($_REQUEST['sort_2']);


$search_sort_1 = getRequest('sort_1','id desc');
$search_sort_2 = getRequest('sort_2','reg_time desc');
$page = getRequest('page',0);
$oldPage = $page;
$page = ($page == 0)?0:($page-1);

$sql = "select a.role_id id,b.role_name nickname,b.account_name AccountName,c.create_time reg_time,d.last_login_time as last_login_time,a.last_login_ip last_login_ip,a.level level,b.status status 
	from db_role_attr_p a,db_role_base_p b,db_account_p c,db_role_ext_p d where a.role_id = b.role_id and b.account_name = c.account_name and  a.role_id = d.role_id order by $search_sort_1  , $search_sort_2  limit "
	.intval($page)*20 . " , " . SIZE_PER_PAGE;


$result = GFetchRowSet($sql);

$sql = "select count(*) as cnt
	from db_role_attr_p a,db_role_base_p b,db_account_p c,db_role_ext_p d where a.role_id = b.role_id and b.account_name =c.account_name and  a.role_id = d.role_id";



$countResult = GFetchRowOne($sql);
$countResult = intval($countResult['cnt']);



$pagelist = getPages($oldPage, $countResult);
$keywordlist = $result;

//排序的
$sortlistoption  = getSortTypeListOption();
$smarty->assign("search_sort_1", $search_sort_1);
$smarty->assign("search_sort_2", $search_sort_2);
$smarty->assign("record_count", $countResult);
$smarty->assign("keywordlist", $keywordlist);
$smarty->assign("page_list", $pagelist);
$smarty->assign("page_count", ceil($countResult/SIZE_PER_PAGE));
$smarty->assign('sortoption', $sortlistoption);
$smarty->display("module/gamer/all_gamer_view.tpl");
exit;


//////////////////////////////////////////////////////////////

function getSortTypeListOption()
{
	return array(
			"id asc"  => '角色ID↑',
			"id desc" => '角色ID↓',
			"nickname asc"  => '角色名↑',
			"nickname desc" => '角色名↓',
			"AccountName asc"  => '帐号名↑',
			"AccountName desc" => '帐号名↓',
			"reg_time asc"  => '注册时间↑',
			"reg_time desc" => '注册时间↓',
			"last_login_time asc"  => '最后一次登录时间↑',
			"last_login_time desc" => '最后一次登录时间↓',
			"last_login_ip asc"  => '最后登录IP↑',
			"last_login_ip desc" => '最后登录IP↓',
			"level asc"  => '角色等级↑',
			"level desc" => '角色等级↓',
			"status asc"  => '用户状态↑',
			"status desc" => '用户状态↓',

			);
}










?>