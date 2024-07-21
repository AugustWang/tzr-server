<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global  $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/log_silver_class.php';
include_once SYSDIR_ADMIN.'/class/admin_item_class.php';

if ( !isset($_REQUEST['dateStart'])){
	$start_day = GetTime_Today0() - 7*86400;
	$dateStart = strftime("%Y-%m-%d",$start_day);
}
elseif ( $_REQUEST['dateStart'] == 'ALL') {
    $dateStart  = SERVER_ONLINE_DATE;
}
else
{
	$dateStart  = trim(SS($_REQUEST['dateStart']));
}

if ( !isset($_REQUEST['dateEnd']))
	$dateEnd = strftime ("%Y-%m-%d", time() );
elseif ( $_REQUEST['dateStart'] == 'ALL') {
    $dateEnd = strftime ("%Y-%m-%d", time() );
}
else
	$dateEnd = trim(SS($_REQUEST['dateEnd']));

if ( !isset($_REQUEST['order']))
    $order = 'amount';
else
    $order = SS($_REQUEST['order']);

$nickname = SS(trim($_POST['nickname']));
$acname = SS(trim($_POST['acname']));

$userid = 0;
if ($nickname) 
{
	$userid = UserClass::getUseridByRoleName($nickname);
}

if ($userid<1)
{
	if ($acname)
	{
		$userid = UserClass::getUseridByAccountName($acname);
	}	
}


$dateStartStamp = strtotime($dateStart . ' 0:0:0');
$dateEndStamp   = strtotime($dateEnd . ' 23:59:59');
if( !$dateStartStamp || $dateStartStamp<strtotime(SERVER_ONLINE_DATE) ){
	$dateStartStamp = strtotime(SERVER_ONLINE_DATE);
}
$dateEndStamp = $dateEndStamp ? $dateEndStamp : time();
$dateEndStamp = min($dateEndStamp,time());

$dateStartStr = strftime ("%Y-%m-%d", $dateStartStamp);
$dateEndStr   = strftime ("%Y-%m-%d", $dateEndStamp);

$dateStrPrev  = strftime ("%Y-%m-%d", $dateStartStamp - 86400);
$dateStrToday = strftime ("%Y-%m-%d");
$dateStrNext  = strftime ("%Y-%m-%d", $dateStartStamp + 86400);


$type = $_REQUEST['type'] ? intval($_REQUEST['type']) : 0;

$checkArr = array('uid'=>$userid,'type'=>$type,);
$data = getSilverUseStatData($dateStartStamp, $dateEndStamp, $checkArr);

$buy_stat = array(); 
$itemStart = $dateStartStamp or $itemStart = strtotime(date('Y-m-00',time()));
$itemEnd = $dateEndStamp or $itemEnd = time();
$buy_stat = LogSilverClass :: getBuyLogStats($userid, $order, $dateStartStamp, $dateEndStamp);


$itemMapArray = getItemMapArray();

foreach($buy_stat as $id => $row) {
	$iid = intval($row['itemid']);
	$buy_stat[$id]['item_data'] = $itemMapArray[$iid];
}


$tlist = LogSilverClass :: GetTypeList();


//data


$smarty->assign("tlist", $tlist);
$smarty->assign("search_keyword1", $dateStartStr);
$smarty->assign("search_keyword2", $dateEndStr);

$smarty->assign("dateStrPrev", $dateStrPrev);
$smarty->assign("dateStrNext", $dateStrNext);
$smarty->assign("dateStrToday", $dateStrToday);

$smarty->assign("type", $type);
$smarty->assign("order", $order);

$smarty->assign("keywordlist", $data);
$smarty->assign("search1", $acname);
$smarty->assign("search2", $nickname);

$smarty->assign("buy_stat", $buy_stat);


$smarty->assign('item_start',date("Y-m-d",$itemStart));
$smarty->assign('item_end',  date("Y-m-d",strtotime(date("Y-m-00",$itemStart)." +1 month")-1));

$smarty->display("module/analysis/silver_use_stat.tpl");
exit;
//////////////////////////////////////////////////////////////

function getItemMapArray(){
	$itemMapArray = array();
	$itemList = AdminItemClass::getItemList();
	
	foreach($itemList as  $row) {
		$id = $row["typeid"];
		$itemMapArray[$id] = $row;
	}
	return $itemMapArray;
}

//t_log_use_silver_2011_01  
function makeTableAryWithTimeSpan($start,$end,$orginalTableName){
	$monthPrefix = array();
	while($start <= $end){
		$monthPrefix[] = date("_Y_m",$start);
		$start = strtotime("+1 month",$start);
	}
	$allTables = array();
	foreach ($monthPrefix as $eachItem){
		$allTables[] = $orginalTableName.$eachItem;
	}
	return $allTables;
}


function getSilverUseStatData($startTime, $endTime, $checkArr = array()){
	$uid = $checkArr['uid'];
	$type = $checkArr['type'];
	$order = $checkArr['order'];
	
	$sqlAry = array();	
	$tableAry = makeTableAryWithTimeSpan($startTime, $endTime, 't_log_use_silver');
	foreach ($tableAry as $item){
		$sql = "SELECT `mtype`, count( `id` ) AS c, sum( `amount` ) AS ss ,(sum(`silver_bind`)+sum(`silver_unbind`)) AS silver , "
			. "sum(`silver_bind`) AS silver_bind ,sum(`silver_unbind`) AS silver_unbind FROM tzr_logs.`{$item}`"
		 . " WHERE `mtime`>={$startTime} AND `mtime`<={$endTime} " ;
		if($uid)
			$sql .= " AND `user_id`={$uid} ";
		if($type)
			$sql .= " AND `mtype`={$type} ";
		$sql .= " GROUP BY `mtype` " ;	
	/*	if($order)
			$sql .=  " ORDER BY {$order} DESC ";
		else
			$sql .=  " ORDER BY silver DESC, ss DESC, c DESC ";
			*/
		$sqlAry[] = $sql;
	}
	$sqlStatement = implode(" union ", $sqlAry);
	$result = GFetchRowSet($sqlStatement);
	
	
	if(!is_array($result))
		$result = array();

	$tlist = LogSilverClass :: GetTypeList();
	
	$sumResult = array();
	
	foreach($result as $row) {
		$mtype = intval($row['mtype']);	
		$sumResult[$row['mtype']]['desc'] = $tlist[intval($mtype)];
		$sumResult[$row['mtype']]['silver'] += $row['silver'];
		$sumResult[$row['mtype']]['silver_bind'] += $row['silver_bind'];
		$sumResult[$row['mtype']]['silver_unbind'] += $row['silver_unbind'];
		$sumResult[$row['mtype']]['c'] += $row['c'];
		$sumResult[$row['mtype']]['ss'] += $row['ss'];
		
		
		
		/*
		$mtype = intval($row['mtype']);
		$row['desc'] = $tlist[$mtype];
		$row['silver'] = silverUnitConvert($row['silver']);
		$row['silver_bind'] = silverUnitConvert($row['silver_bind']);
		$row['silver_unbind'] = silverUnitConvert($row['silver_unbind']);
		*/
	}
	
	foreach ($sumResult as $id =>$item){
		$sumResult[$id]['silver'] = silverUnitConvert($item['silver']);
		$sumResult[$id]['silver_bind']= silverUnitConvert($item['silver_bind']);
		$sumResult[$id]['silver_unbind'] = silverUnitConvert($item['silver_unbind']);
	}
		//die(var_dump($sumResult));
			return $sumResult;
}


