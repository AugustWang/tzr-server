<?php
/*
 * 创建角色页流失率统计
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

define('NEVER',strtotime('2012-12-20'));

//判断是否输入了开始和结束时间
if (isset($_POST['setTime']) && trim($_POST['start_time'] > 0)) {
	$start_time = $_POST['start_time'];
	$end_time = $_POST['end_time'];
	$start = strtotime(trim($start_time)) or $start = GetTime_Today0();
	$start_time = $start;
	
	if(ifSpecifiedHour(trim($end_time))){
		$end = strtotime($end_time);
	}else {
		//没有:的情况
		$end = strtotime(trim($end_time)) or $end = GetTime_Today0();
		$end = $end+24*60*60-1;
	}
	
	$end_time = $end;
	
	$portal_num	= getPortalAccountNum($start_time,$end_time);
 	//$before_num = getRoleNumBeforeCreate($start_time,$end_time);
	$after_num = getRoleNumAfterCreate($start_time,$end_time);
	$role_num = getMainRoleNum($start_time,$end_time);
	$game_num = getSplashScreenCount($start_time,$end_time);
	$mission_num = getFirstMissionCount($start_time,$end_time);
	$level_num = getUserOverThanLeveX($start_time,$end_time);

	$in = array(
			'start_time' => date('Y-m-d H:i:s',$start),
			'end_time' => date('Y-m-d H:i:s',$end)
		);	
		
}else{
	$portal_num = getPortalAccountNum();
	//$before_num = getRoleNumBeforeCreate();
	$after_num = getRoleNumAfterCreate();
	$role_num = getMainRoleNum();
	$game_num = getSplashScreenCount();
	$mission_num = getFirstMissionCount();
	$level_num = getUserOverThanLeveX();
}


$input = isset($in)? $in : array(
	'start_time' => date('Y-m-d H:i:s',strtotime(SERVER_ONLINE_DATE)),
	'end_time' => date('Y-m-d H:i:s',time())
	) ;


$smarty->assign('input',$input);
$smarty->assign(
	array(
	'portal'=>$portal_num['num'],	//平台账号数
	//'before'=>$before_num['num'],	// ##暂时已经废弃##
	'after'=>$after_num['num'],		//完成创建页人数
	'role'=>$role_num['num'],		//游戏中的角色数
	'game'=>$game_num['num'],		//到达欢迎窗口人数
	'mission'=>$mission_num['num'],	//完成第一个任务人数
	'level'=>$level_num['num'],
	'portal_ip'=>$portal_num['ip_num'],
	'before_ip'=>$before_num['ip_num'],
	'after_ip'=>$after_num['ip_num'],
	'role_ip'=>$role_num['ip_num'],
	'game_ip'=>$game_num['ip_num'],
	'mission_ip'=>$mission_num['ip_num'],
	'level_ip'=>$level_num['ip_num'],
	)
);

$smarty->display("module/stat/create_user_stat.tpl");

/*目前所以的流失率对比
 1.平台账号  t_portal_account
 2.进入到创建页 t_role_create_before
 3.创建成功页 t_role_create_after
 4.游戏中账号  =:= 3 db_account_p
 5.spalsh screen 进入主游戏 
 6.完成第一个任务
*/



function ifSpecifiedHour($str){
	if(strpos($str,':') > 0){
		return true;
	}else {
		return false;
	}
}



/**
 * 某段时间内平台过来的账号数
 * @param $start
 * @param $end
 */
function getPortalAccountNum($start = 0,$end = NEVER){
	$sql = "select count(account_name) as num, count(distinct ip) as ip_num from t_portal_account where mtime >= $start and mtime <= $end";

	
	$result = GFetchRowOne($sql);
	return $result;
}


/**
 * 某段时间平台过来的账号到达创建页的人数，##暂时已经废弃##
 * @param $start
 * @param $end
 */
//function getRoleNumBeforeCreate($start=0,$end = NEVER){
//	$sql = "select count(distinct b.account_name) as num , count(distinct p.ip) as ip_num from t_portal_account p,t_role_create_before b "  
//	." where p.account_name = b.account_name and p.mtime >= $start and p.mtime <= $end ";
//	
//	$result = GFetchRowOne($sql);
//	return $result;
//}

/**
 * 某段时间内平台过来的账号完成创建任务的人数
 * @param unknown_type $start
 * @param unknown_type $end
 */
function getRoleNumAfterCreate($start=0,$end = NEVER){
	$sql = "select count(distinct a.account_name) as num,count(distinct p.ip) as ip_num from t_portal_account p,t_role_create_after a "  
	." where p.account_name = a.account_name and p.mtime >= $start and p.mtime <= $end ";

	$result = GFetchRowOne($sql);
	return $result;
}

/**
 * 某段时间内平台过来的账号在游戏中有数据的数目
 * @param $start
 * @param $end
 */
function getMainRoleNum($start=0,$end = NEVER){
	$sql = "select count(distinct a.account_name) as num,count(distinct p.ip) as ip_num from t_portal_account p,db_role_base_p a "  
	." where p.account_name = a.account_name and p.mtime >= $start and p.mtime <= $end ";

		
	$result = GFetchRowOne($sql);
	return $result;
}

/**
 * 某段时间内平台过来的账号在main.swf加载成功的数目
 * @param $start
 * @param $end
 */
function getSplashScreenCount($start=0,$end = NEVER){
	$sql = "SELECT count(distinct beh.role_id) as num ,count(distinct beh.login_ip) as ip_num " 
	."from t_log_behavior beh,db_role_base_p a, t_portal_account p where " 
		."beh.role_id = a.role_id and a.account_name = p.account_name and p.mtime >= "
		." $start  and p.mtime <= $end and beh.behavior_type = 1";
		
		
		
	/*	log_time >= $start and log_time <= $end and behavior_type = 1";*/
	$rs = GFetchRowOne($sql);
	return $rs;
}

/**
 * 某段时间内平台过来的额账号在完成第一个任务的数目
 * @param $start
 * @param $end
 */
function getFirstMissionCount($start=0,$end=NEVER){
	$sql = "SELECT count(distinct beh.role_id) as num ,count(distinct beh.login_ip) as ip_num " 
	."from t_log_behavior beh,db_role_base_p a, t_portal_account p where " 
		."beh.role_id = a.role_id and a.account_name = p.account_name and p.mtime >= "
		." $start  and p.mtime <= $end and beh.behavior_type = 2";
	
		
	/*	log_time >= $start and log_time <= $end and behavior_type = 1";*/
	$rs = GFetchRowOne($sql);
	return $rs;
}



/**
 * 某段时间内注册并且到达二级以及以上的人数 
 * @param unknown_type $start
 * @param unknown_type $end
 */
function getUserOverThanLeveX($start=0,$end=NEVER,$level = 2){
	$sql = "
	select count(distinct attr.role_id) as num,count(distinct attr.last_login_ip) as ip_num from db_role_attr_p attr,db_role_base_p base where 
	attr.role_id = base.role_id and base.create_time >= $start
	and base.create_time < $end and attr.level > $level
	";
	$rs = GFetchRowOne($sql);
	return $rs;
}
