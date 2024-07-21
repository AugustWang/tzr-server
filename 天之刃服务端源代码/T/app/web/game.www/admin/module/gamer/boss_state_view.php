<?php
//@author natsuki lolicon@mail.az
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
include_once SYSDIR_ADMIN.'/class/map_class.php';
global $auth,$smarty;


$auth->assertModuleAccess(__FILE__);

define('EDITOR_DB', 'game_admin');

//获取地图和门派的基础信息
$mapList = MapClass::getMapList();
$familyNameList = MapClass::getFamilyNameList();

$dictBossState= array(
	1=>'重生',
	2=>'其他',
	3=>'死亡'
);


$bossname = SS(trim($_REQUEST['bossname']));
$start = strtotime($_REQUEST['start']) or $start = GetTime_Today0();
$end = strtotime($_REQUEST['end']) or $end = GetTime_Today0();
$page_no = intval($_REQUEST['page_no']) or $page_no = 1;

$end += 60*60*24-1;

$real_page = ($page_no - 1)* LIST_PER_PAGE_RECORDS;
if(strlen($bossname)>1)
	$sqlPage = " select count(`id`) as row_cnt from t_log_boss_state where boss_name like '%$bossname%' and mtime >= {$start} and mtime < {$end} ";
else
	$sqlPage = " select count(`id`) as row_cnt from t_log_boss_state where mtime >= {$start} and mtime < {$end} ";
$rsCnt = GFetchRowOne($sqlPage);
$pageCnt = intval($rsCnt['row_cnt']);
$pagelist = getPages($page_no, $pageCnt);

if(strlen($bossname)>1)
	$sql = "select * from t_log_boss_state where boss_name like '%$bossname%' and mtime >= $start and mtime < $end order by id desc limit $real_page,".LIST_PER_PAGE_RECORDS;
else
	$sql = "select * from t_log_boss_state where mtime >= $start and mtime < $end order by id desc limit $real_page,".LIST_PER_PAGE_RECORDS;
$result = GFetchRowSet($sql);


$popularity  = getLastPopulation($start);
$popularityWithBossAsIndex = array();
foreach ($popularity as $each){
	$popularityWithBossAsIndex[$each['boss_id']] = $each['num'];
}

foreach ($result as &$item){
	$item['display_name'] = $item['boss_name'];
	$item['display_state'] = $dictBossState[intval($item['boss_state'])];
	$item['map_name'] = $mapList[ $item['map_id'] ] ;
	if( $item['special_id']>0 ){
		$item['family_name'] = $familyNameList[ $item['special_id'] ] ;
	}else{
		$item['family_name'] = "";
	}
	$item['display_player'] = UserClass::getRoleNameByRoleId(intval($item['last_hurt_player']));
	$item['display_item'] = generateDisplayName($item['drop_item']);
	$item['display_time'] = date('m-d H:i:s',$item['mtime']);
	$item['popularity'] = $popularityWithBossAsIndex[$item['boss_id']] or $item['popularity'] = 0;
}

$smarty->assign(array(
'bossname'=>$bossname,
'start'=>date("Y-m-d",$start),
'end'=>date('Y-m-d',$end),
'page_no'=>$page_no,
'logs'=>$result,
'pagelist'=>$pagelist,
));

$smarty->display('module/gamer/boss_state_view.tpl');


/**
 * 	
 * 昨日总共被打次数,按照较小的日期来算昨日
 */
function getLastPopulation($start){
	$stamp = strtotime(date("Y-m-d",$start). " -1 day");
	$end = $stamp - 24*60*60;
	$sql = "select count(*) as num, boss_id from t_log_boss_state where mtime > $end and mtime < $stamp group by boss_id";
	$result = GFetchRowSet($sql);
	return 	$result;
}



//item_type,item_typeid,color,quality,num
function generateDisplayName($itemList){
	global $dictQualityType;
	global $dictColor;
	
	if (strlen($itemList) < 1 || !is_array(json_decode($itemList,true))){
		return "";
	}
	$aryList = json_decode($itemList,true);
	
	$eachDisplayName = array();
	foreach ($aryList as $each){
		$num = intval($each['num']);
		$color = $dictColor[intval($each['color'])];
		$quality = $dictQualityType[intval($each['quality'])];
		$itemName = getNameOf($each['item_typeid']);
		$eachDisplayName[] = $color.$quality.$itemName." * ".$num;
	}
	return implode('<br>', $eachDisplayName);
}


function getNameOf($id){	
	$id = intval($id);
	$sql = "SELECT item_name from t_item_list where typeid = $id";
	$result = GFetchRowOne($sql);
	if (is_array($result)) {
		return $result['item_name'];
	}else {
		return "不知名物品($id)";
	}
}

