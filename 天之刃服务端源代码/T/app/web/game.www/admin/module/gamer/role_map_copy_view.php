<?php 
//@author natsuki
define('IN_ODINXU_SYSTEM', true);
define('LEN_PER_PAGE', 20);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
global $auth,$smarty,$dictFaction;


$start = strtotime($_REQUEST['start']) or $start = strtotime(SERVER_ONLINE_DATE);
$end = strtotime($_REQUEST['end']) or $end = GetTime_Today0();
$end += 24*60*60-1;

$rolename = SS(trim($_REQUEST['rolename']));
$page = $_REQUEST['page'] or $page = 1;
$pageStart = ($page-1)*LEN_PER_PAGE;

$where = " where start_time >= $start and start_time <= $end ";
if (strlen($rolename)>1){
	$where .= " and role_name = '$rolename'";
}

$order = " order by start_time desc ";

$sql = "select SQL_CALC_FOUND_ROWS id,faction_id,map_name,npc_id,map_id,start_time,vwf_monster_level,
role_name,end_time,leader_role_id from t_log_role_vwf $where $order limit $pageStart,".LEN_PER_PAGE;
$result = GFetchRowSet($sql);
$counts = GFetchRowOne("select FOUND_ROWS() as counts");
$counts = $counts['counts'];


foreach ($result as &$item){
	$item['faction_name'] = $dictFaction[$item['faction_id']];
	$item['leader_role_name'] = UserClass::getRoleNameByRoleId($item['leader_role_id']);
}

$pager = renderPageIndicator('role_map_copy_view.php',$page,$counts,LEN_PER_PAGE,
array('start'=>date('Y-m-d',$start),'end'=>date('Y-m-d',$end),'rolename'=>$rolename),'page');

$smarty->assign(array(
	'page'=>$page,
	'pager'=>$pager,
	'start'=>date('Y-m-d',$start),
	'end'=>date('Y-m-d',$end),
	'result'=>$result,
	'rolename'=>$rolename
));


$smarty->display('module/gamer/role_map_copy_view.tpl');



