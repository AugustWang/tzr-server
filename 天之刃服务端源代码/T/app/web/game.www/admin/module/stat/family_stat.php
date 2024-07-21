<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

//list($start,$end) = sanitizeTimeSpan($_REQUEST['start'],$_REQUEST['end']);



$start = strtotime(SERVER_ONLINE_DATE);
$end = time();





function getDataByLevel($lv,$ary){
	foreach ($ary as $item){
		if (intval($item['level']) == intval($lv)){
			return $item['num'];
		}
	}
	return 0;
}


$sql = "select max(level) as max_level from db_role_attr_p";
$maxLevel = GFetchRowOne($sql);
$maxLevel = $maxLevel['max_level'];

function getLevelNumArr($arr)
{	
	
	$newarr = array();
	foreach($arr as $item)
	{
		$newarr[$item['level']] =$item['num'];
	}
	return $newarr;
}

$user_with_family = getLevelNumArr(getUserWithFamily());
$user_without_family = getLevelNumArr(getUserWithoutFamily());
$active_user = getLevelNumArr(getActiveUser());
$active_user_without_family = getLevelNumArr(getActivePlayerWithoutFamily());
$rmb_user_with_family = getLevelNumArr(getRmbUserWithFamily());
$non_rmb_user_with_family = array();
foreach($user_with_family as $k=>$v)
{
	$non_rmb_user_with_family[$k]=$v - $rmb_user_with_family[$k];
}
$rmb_user_without_family = getLevelNumArr(getRmbPlayerWithoutFamily());
$non_family_and_non_rmb_user = array();
foreach($user_without_family as $k=>$v)
{
	$non_family_and_non_rmb_user[$k] = $v - $rmb_user_without_family[$k];
}

$finalAry = array();
for($i = 10;$i <$maxLevel+1;$i++){
	$finalAry[intval($i)]['level'] =  $i;
	$finalAry[intval($i)]['withFamily'] = $user_with_family[$i]; 
	$finalAry[intval($i)]['withoutFamily'] =$user_without_family[$i]; 
	$finalAry[intval($i)]['active'] =$active_user[$i]; 
	$finalAry[intval($i)]['activeWithoutFamily'] = $active_user_without_family[$i]; 
	$finalAry[intval($i)]['rmbWithFamily'] =$rmb_user_with_family[$i]; 
	$finalAry[intval($i)]['nonrmbWithFamily'] = $non_rmb_user_with_family[$i]; 
	$finalAry[intval($i)]['rmbWithoutFamily'] = $rmb_user_without_family[$i]; 
	$finalAry[intval($i)]['nonFamilyNoneRmb'] = $non_family_and_non_rmb_user[$i]; 
	
}

$smarty->assign(array(
	'finalAry'=>$finalAry,
));


$smarty->display('module/stat/family_stat.tpl');

////////////////////////////////////////////////////////////////////

//以下所有统计都要group by level的
function getUserWithFamily(){
	$sql = "select level,count(base.role_id) as num from db_role_base_p base,db_role_attr_p attr WHERE base.role_id = attr.role_id and 
			family_id > 0 GROUP by level";
		$result = GFetchRowSet($sql);
	return $result;	
}


function getUserWithoutFamily(){
	$sql = "select level,count(base.role_id) as num from db_role_base_p base,db_role_attr_p attr WHERE base.role_id = attr.role_id and 
			family_id = 0 GROUP by level";
	$result = GFetchRowSet($sql);
	return $result;
}


//活跃用户
function getActiveUser(){
	$sql = "select count(online.user_id) as num,level from t_stat_user_online online,db_role_attr_p attr 
			where online.user_id = attr.role_id and online.avg_online_time >= 420  group by level";
	$result = GFetchRowSet($sql);
	return $result;
}

function getActivePlayerWithoutFamily(){
	$sql = "select count(online.user_id) as num,level from t_stat_user_online online,db_role_attr_p attr,db_role_base_p base
			where online.user_id = attr.role_id and attr.role_id = base.role_id and base.family_id = 0 and avg_online_time >= 420 group by level";
	$result = GFetchRowSet($sql);
	return $result;	
	
}

function  getRmbUserWithFamily(){
	$sql = "select count(distinct base.role_id) as num,level from db_role_base_p base,db_role_attr_p attr,db_pay_log_p pay where base.role_id = attr.role_id and attr.role_id = pay.role_id
	and family_id > 0 group by level";
	$result = GFetchRowSet($sql);
	return $result;	
}

function getRmbPlayerWithoutFamily(){
	$sql = "select count(distinct base.role_id) as num,level from db_role_base_p base,db_role_attr_p attr,db_pay_log_p pay where base.role_id = attr.role_id and attr.role_id = pay.role_id
	and family_id = 0 group by level";
	$result = GFetchRowSet($sql);
	return $result;	
}






