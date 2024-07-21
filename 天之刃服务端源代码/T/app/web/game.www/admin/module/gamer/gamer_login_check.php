<?php 
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $smarty,$auth;
define('LEN_PER_PAGE',20);
$auth->assertModuleAccess(__FILE__);


$role_id = trim(SS($_REQUEST['role_id']));
$role_name = trim(SS($_REQUEST['role_name']));
$account = trim($_REQUEST['account']);
$roleInfo = UserClass::getUser($role_name,$account,$role_id);
list($start,$end) = sanitizeTimeSpan($_REQUEST['start'],$_REQUEST['end']);





if ($roleInfo == false){
	$smarty->assign('error',"不存在该玩家，请检查并重新输入");
}else{
	$loginInfo = getLoginInfo($roleInfo['role_id'],$start,$end);
	$smarty->assign('loginInfo',$loginInfo);
	
}

$smarty->assign('roleInfo',$roleInfo);
$smarty->assign('start',date('Y-m-d',strtotime(SERVER_ONLINE_DATE)));
$smarty->assign('end',date('Y-m-d',$end));
$smarty->display('module/gamer/gamer_login_check.tpl');

function getLoginInfo($role_id,$start,$end){
	$sql = "select role_id,log_time,login_ip from t_log_login where role_id = $role_id and log_time>=$start and log_time <= $end order by log_time desc ";
	$result = GFetchRowSet($sql);
	return $result;
}

