<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
global $auth,$smarty,$dictFaction,$dictYbcColor,$dictYbcState;
$auth->assertModuleAccess(__FILE__);
define(LENGTH_PER_PAGE, 40);

//sanitize date
$date = SS(trim($_REQUEST['date'])) or $date = date("Y-m-d",time()); 
if (strtotime($date)<strtotime(SERVER_ONLINE_DATE)) {
	$date = SERVER_ONLINE_DATE;
}

$nextDay = date("Y-m-d",strtotime($date)+60*60*24);
$preDay = date("Y-m-d",strtotime($date)-60*60*24);

$accountName = SS(trim($_REQUEST['accountName']));
$roleName = SS(trim($_REQUEST['roleName']));


$userAry = UserClass::getUser($roleName,$accountName);
if ($userAry == false){
	$uid = 0;
}else{
	$uid = $userAry['role_id'];
	$roleName = $userAry['role_name'];
	$accountName = $userAry['account_name'];
}


$start = strtotime($date);
$end =$start+60*60*24;
$where = "and t1.start_time >= $start and t1.start_time <= $end";
if ( $uid > 0){
	$where .= " and t1.role_id = '$uid'";
}

$sql = "select t1.role_id,role_name,start_time,ybc_color,final_state,end_time from t_log_personal_ybc t1,db_role_base_p t2 " .
		"where t1.role_id=t2.role_id $where  order by `start_time` desc ";
$result = GFetchRowSet($sql);

foreach ($result as &$item){
	$item['color'] = $dictYbcColor[$item['ybc_color']];
	$item['state'] = $dictYbcState[$item['final_state']];		
}

$smarty->assign(array(
	'result'=>$result,
	'date'=>$date,
	'nextDay'=>$nextDay,
	'preDay'=>$preDay,
	'roleName'=>$roleName,
	'today'=>date('Y-m-d',time()),
	)
);

$smarty->display('module/gamer/personal_ybc_log.tpl');




