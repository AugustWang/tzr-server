<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;

$auth->assertModuleAccess(__FILE__);
define('TBL_OCCUPATION','db_role_category_p');

/*
3=>login 
4=>logout
*/


define('UserOnlineTimeDayNums', 7);
define('ACTIVE_STANDARD',7*60);

$_FACTIONS = array(
	1 => array('id' => 1, 'name'=>'云州'),
	2 => array('id' => 2, 'name'=>'沧州'),
	3 => array('id' => 3, 'name'=>'幽州')
);


$faction_active_count = array();
$faction_reg_count    = array();
foreach($_FACTIONS as $key => $value)
{
	$faction_active_count[$value['id']] = getFactionActivePlayerCount($value['id']);
	$faction_reg_count[$value['id']]    = getFactionRegPlayerCount($value['id']);
}

$max_active_faction = 0;
$max_reg_faction    = 0;
$active_total       = 0;
$reg_total          = 0;
foreach($faction_active_count as $row){
	$active_total += $row;
	if($row>$max_active_faction)$max_active_faction = $row;
}

foreach($faction_reg_count as $value){
	$reg_total  += $value;
	if($value>$max_reg_faction)$max_reg_faction = $value;
}


$data = getOccupationData();


//num,faction_id,category_id,level_range

//[$lv][category][faction_id]

$all = array();
$occupationAry = array();
foreach ($data as &$item){
	$occupationAry[intval($item['level_range'])][intval($item['category'])][intval($item['faction_id'])] = $item['num'];
	$occupationAry[intval($item['level_range'])]['level'] = (intval($item['level_range'])*10).'~'.(intval($item['level_range']+1)*10-1);
	//总共人数
	$occupationAry[intval($item['level_range'])][intval($item['category'])][0] += $item['num'];
	$occupationAry[intval($item['level_range'])][5][intval($item['faction_id'])] +=$item['num'];
	
	//各国各职业总数
	$all[intval($item['category'])][intval($item['faction_id'])] += $item['num'];
	
	//各职业总数
	$all[intval($item['category'])][5] += $item['num'];	
	
	//各国总数
	$all[5][intval($item['faction_id'])] += $item['num'];
	
	//所有全部
	$all[5][5] += $item['num'];
}
$smarty->assign('all',$all);


//每10级给一个比例

//排序,避免页面显示混乱
ksort($occupationAry);
if (!is_array($occupationAry)) {
	$occupationAry = array();
}

foreach ($occupationAry as &$item){
	for($i = 1;$i<6;$i++){
		for($j = 1;$j<4;$j++){
			if(!isset($item[$i][$j])){
				$item[$i][$j] = 0;
			}
		}
	}
}




$smarty->assign('categories',array(1=>'战士',2=>'射手',3=>'侠客',4=>'医仙'));
$smarty->assign('occupationAry',$occupationAry);
$smarty->assign('data',$data);
$smarty->assign("faction",$_FACTIONS);
$smarty->assign("faction_active_count", $faction_active_count);
$smarty->assign("max_active_faction", $max_active_faction);
$smarty->assign("active_total",$active_total);
$smarty->assign("faction_reg_count", $faction_reg_count);
$smarty->assign("max_reg_faction", $max_reg_faction);
$smarty->assign("reg_total",$reg_total);
$smarty->display("module/stat/faction_stat.tpl");

exit;





function getFactionPlayerCounts($last_login_time = 0) {
	global $_FACTIONS;
	$sql = "select `Faction_ID` as F, count(*) as C from `" . TBL_USER . "` where `last_login_time`>={$last_login_time} group by `Faction_ID`";
	$rs = GFetchRowSet($sql);
	if(!is_array($rs))
		$rs = array();
	$sum = 0;
	foreach($rs as $id=>$row) {
		$rs[$id]['faction'] = $_FACTIONS[$row['F']]['name'];
		$sum += intval($row['C']);
	}
	foreach($rs as $id=>$row)
		$rs[$id]['ratio'] = round(intval($row['C']) / $sum * 1000) / 10;
	return $rs;
}

function getFactionActivePlayerCount($faction_id) {
	//new 七天上线时间超过标准则为active_player
	$active_standard = 10;
	$last_active_time = strtotime(" -3 days");	
	
	$sql  ="select count(*) as num from db_role_base_p base,t_stat_user_online stat,db_role_ext_p ext
	where base.role_id = stat.user_id and base.role_id = ext.role_id
		and avg_online_time > ".ACTIVE_STANDARD." and faction_id = $faction_id and last_login_time > $last_active_time";

	$result = GFetchRowOne($sql);
	return $result['num'];
}



function convertMatrix($ary) {
	$newAry = array();
	foreach ($ary as $item) {
		$newAry[$item['role_id']][$item['type']] = $item['total_time'];
	}
	return $newAry;
}




//faction,level
function getOccupationData(){
	$sql = "select count(c.role_id) as num,base.faction_id,c.category,floor(attr.level/10) as level_range from "
	.TBL_OCCUPATION." as c,db_role_base_p base ,db_role_attr_p attr where c.role_id = base.role_id and c.role_id = attr.role_id group by faction_id,category,level_range";
	try{
		$result = GFetchRowSet($sql);
	}catch (Exception $e){
		die("数据库错误!!");
	}
	return $result;
}


//num,faction_id,categories,level/10
/*
function getOccupationData_(){
	$sql = "select count(*) as num,faction_id,category, floor(level/10) as level_range from ".TBL_OCCUPATION." group by faction_id,category,level_range";
	$result = GFetchRowSet($sql);
	return $result;
}
*/



/*
目标：查看各组服务器各种职业的势力对比信息
功能描述：各组服务器各种职业总人数、等级分布、职业比例：横向柱状图；
各组服务器各种职业活跃人数、等级分布、职业比例、横向柱状图；

职业的判定标准：
第一职业：等级≥20级，取已学技能点数最高的为当前职业；如果有多个职业的点数相同，则取最小的职业id
第二职业：等级≥20级，已学技能点第二多，并且超过10点，算第二职业。
*/





function getFactionRegPlayerCount($faction_id)
{
	$sql = "SELECT COUNT(*) AS faction_num FROM `db_role_base_p` WHERE `faction_id`={$faction_id}";
	$rs = GFetchRowOne($sql);
	return $rs['faction_num'];
}