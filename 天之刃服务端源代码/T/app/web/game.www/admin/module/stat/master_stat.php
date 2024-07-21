<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
global $auth,$smarty,$dictFaction;
$auth->assertModuleAccess(__FILE__);
define('ACTIVE_STANDARD',7*60);

$min = intval($_REQUEST['min']) or $min = 10;
$min < 10 or $min = 10;
$max = intval($_REQUEST['max']) or $max = getMaxLevel();


$finalAry = array();
//min,max
$maxLevel = getMaxLevel();








$ymd = intval(date('Ymd',time()));
for ($itr = 0;$itr <= $maxLevel;$itr++){
	$finalAry[$itr] = array(
		'level'=>$itr,
		'master'=>extractLevelData(getMaterNumberWithLevel(),$itr),
		'withoutMaster'=>extractLevelData(getUserWithoutMaster(),$itr),
		'active'=>extractLevelData(getActiveUserWithLevel($ymd),$itr),
		'activeMaster'=>extractLevelData(getActiveUserWithMaster(),$itr),
		'activeWithoutMaster'=>extractLevelData(getActiveWithoutMaster(),$itr),
		'nonactiveWithMaster'=>extractLevelData(getNonActiveAndMaster(),$itr),
		'nonactiveNonmaster'=>extractLevelData(getNonActiveAndNoneMaster(),$itr),
		'paidWithMaster'=>extractLevelData(getPaidWithMaster(),$itr),
		'paidWithoutMaster'=>extractLevelData(getPaidWithoutMaster(),$itr),
		'nopaidWithMaster'=>extractLevelData(getNopaidWithMaster(),$itr),
		'nopaidWithoutMaster'=>extractLevelData(getNopaidWithoutMaster(),$itr)
	);
}

$smarty->assign(
	array(
	'finalAry'=>$finalAry
	)
);

$smarty->display('module/stat/master_stat.tpl');



function extractLevelData($data,$level){
	foreach ($data as $item){
		if(intval($item['level']) == $level){
			return $item['num'];
		}
	}
	return 0;
}




//有师门
function getMaterNumberWithLevel(){
	$sql = "
	select count(roleid) as num,attr.level as level from db_role_educate_p edu,db_role_attr_p attr where 
	edu.roleid = attr.role_id and (teacher is not null or student_num != 0) group by attr.level
	";
	
	
	return GFetchRowSet($sql);
}

//没师门
function getUserWithoutMaster(){
	$sql = "
	select count(role_id) as num,attr.level as level from db_role_educate_p edu,db_role_attr_p attr where 
	edu.roleid = attr.role_id and teacher is null and  student_num = 0 group by attr.level
	";
	return GFetchRowSet($sql);
}


//活跃玩家
function getActiveUserWithLevel($ymd){
	$ymd = intval($ymd);
	$sql = "select count(active.role_id) as num,attr.level as level from t_log_active_user_daily active,db_role_attr_p attr where active.role_id = attr.role_id 
		and ymd = $ymd group by level";
	$result = GFetchRowSet($sql);
	return $result;
}



//活跃&师门
function getActiveUserWithMaster(){
	
	$sql = "select count(attr.role_id) as num,attr.level as level from t_stat_user_online online,db_role_educate_p edu,db_role_attr_p attr 
	where edu.roleid = online.user_id and attr.role_id = online.user_id and (student_num > 0 or teacher is not null) 
	and online.avg_online_time >= ".ACTIVE_STANDARD." group by attr.level "	;
	
	return GFetchRowSet($sql);
}




//活跃&非师门
function getActiveWithoutMaster(){
	$sql = "
	select count(online.user_id) as num,attr.level as level from t_stat_user_online online,db_role_educate_p edu,db_role_attr_p attr where
	online.user_id  = edu.roleid and edu.roleid = attr.role_id and avg_online_time > ".ACTIVE_STANDARD."
	and edu.student_num = 0 and edu.teacher is null group by attr.level";
	return GFetchRowSet($sql);
}



//非活跃&师门
function getNonActiveAndMaster(){
	$sql = "
	select count(attr.role_id) as num,attr.level as level from db_role_attr_p attr,db_role_educate_p edu ,t_stat_user_online online
	where attr.role_id = edu.roleid and attr.role_id = online.user_id and (student_num > 0 or teacher is not null)
	and online.avg_online_time < ".ACTIVE_STANDARD." group by attr.level	";
	return GFetchRowSet($sql);
}


//非活跃&非师门


//1.查出非师门


/*
$sql = "
select attr.role_id as ri,level from db_role_educate_p edu,
db_role_attr_p attr where edu.roleid = attr.role_id and
where edu.student_num = 0 and teacher = null and ri not in(
select id from 
)";
*/
  


//非师徒非活跃
function getNonActiveAndNoneMaster(){
	//非师徒非活跃
	$sql = "select count(attr.role_id) as num,attr.level from db_role_educate_p edu,t_stat_user_online online,db_role_attr_p attr where
	edu.roleid = online.user_id and online.user_id = attr.role_id and
	online.avg_online_time < ".ACTIVE_STANDARD." and student_num = 0 and teacher is null group by attr.level";	
	return GFetchRowSet($sql);
}




//师门*充值  role_id
function  getPaidWithMaster(){
	$sql = "select count(role_id) as num,attr.level as level from db_role_attr_p attr where role_id in(
	select roleid from db_role_educate_p where (student_num != 0 or teacher is not null) and roleid in(
		select role_id from db_pay_log_p 
	)
	) group by attr.level";
	
	return GFetchRowSet($sql);
}



function  getPaidWithoutMaster(){
	$sql = "select count(role_id) as num,attr.level as level from db_role_attr_p  attr where  role_id in(
	select roleid from db_role_educate_p where student_num = 0 and teacher is null and roleid in(
		select role_id from db_pay_log_p 
	)
	) group by attr.level";
	return GFetchRowSet($sql);
}




function getNopaidWithMaster(){
	$sql = "select count(role_id) as num,attr.level level from db_role_attr_p  attr where  role_id in(
	select roleid from db_role_educate_p where (student_num != 0 or teacher is not null) and roleid  not in(
		select role_id from db_pay_log_p 
	)
	) group by attr.level";
	return GFetchRowSet($sql);
	
}


function getNopaidWithoutMaster(){
	$sql = "select count(role_id) as num,attr.level as level from db_role_attr_p attr where  role_id in(
	select roleid from db_role_educate_p where student_num = 0 and teacher is null and roleid not in(
		select role_id from db_pay_log_p 
	)
	) group by attr.level";
	return GFetchRowSet($sql);
	
}



function getMaxLevel(){
	$sql = "select max(level) as mlevel from db_role_attr_p";
	$result = GFetchRowOne($sql);
	return $result['mlevel'];
}
