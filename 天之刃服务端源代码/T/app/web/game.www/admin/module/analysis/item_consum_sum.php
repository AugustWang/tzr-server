<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/item_log_class.php';
include_once SYSDIR_ADMIN.'/class/admin_item_class.php';

$serverOnLineTime = strtotime(SERVER_ONLINE_DATE);
if (!$serverOnLineTime) {
	die('未设置开服日期');
}
$itemid = intval($_REQUEST['itemid']);
$type = intval($_REQUEST['type']);

$startDate = $_REQUEST['startDate'];
$endDate = $_REQUEST['endDate'];

$startDateTime = strtotime($startDate);
$endDateTime = strtotime($endDate) ? strtotime($endDate)+86399 : false;
if (!$startDateTime || !$endDateTime ) {
	$startDateTime = strtotime(date('Y-m-d',strtotime('-6day')));
	$endDateTime = strtotime(date('Y-m-d 23:59:59',strtotime('-1day')));
}
if ($startDateTime < $serverOnLineTime) {
	$startDateTime = $serverOnLineTime;
}
$todayLastTime = strtotime(date('Y-m-d 23:59:59'));
if ($endDateTime > $todayLastTime) {
	$endDateTime = $todayLastTime;
}
$startDate = date('Y-m-d',$startDateTime);
$endDate = date('Y-m-d',$endDateTime);

$startWeek =  ceil((date('z',$startDateTime)+1)/7);
$endWeek =  ceil((date('z',$endDateTime)+1)/7);
$startYear = date('Y',$startDateTime);
$endYear = date('Y',$endDateTime);
$arrTable = array();
$diffWeek = ($endYear - $startYear)*53 + $endWeek - $startWeek;
for ($w=0; $w<=$diffWeek; $w++){
	$week = $w + $startWeek;
	$year = $startYear + floor($week/54);
	$week = $week % 53;
	$week = $week==0 ? 53 : $week;
	$week = $week >9 ? $week : '0'.$week;
	$str = DB_MING2_LOGS.'.t_log_item_'.$year.'_'.$week;
	array_push($arrTable,$str);
}

$itemlist=AdminItemClass::getItemList();  

$itemid = $itemid ? $itemid : $itemlist[0]['typeid'];
$itemname = trim($_POST['itemname']) ? trim($_POST['itemname']) : $itemlist[0]['typeid'].' | '.$itemlist[0]['item_name'];
$arrConsumeType = array_keys(ItemLogClass::getConsumType());
if ($type) {
	$whereAction = " AND `action`={$type} ";
}else {
	$strConsumeTypes = implode(',',$arrConsumeType);
	$whereAction = " AND `action` in ({$strConsumeTypes}) ";
}

$arrRs = array();
foreach ($arrTable as &$tbl) {
	$sql = " SELECT sum(`amount`) as `amount`, max(`start_time`) as `mtime` 
			 FROM {$tbl} 
			 WHERE `itemid`={$itemid} {$whereAction} 
			 GROUP BY FROM_UNIXTIME(`start_time`,'%Y%m%d') ";
	$rs = GFetchRowSet($sql);
	array_push($arrRs,$rs);
}

$arrResult = array();
$diffDay =  floor( ( $endDateTime - $startDateTime )/86400 );
for ($i=0; $i<=$diffDay; $i++){
	$arrResult[$startDateTime+$i*86400] = array('date'=>date('m.d', $startDateTime+$i*86400), 'amount'=>0, 'week'=>date('w',$startDateTime+$i*86400));
}

$maxAmount = 0 ;
foreach ($arrRs as &$rs) {
	foreach ($rs as &$row) {
		$mtime = strtotime(date('Y-m-d',$row['mtime']) );
		if (!empty($arrResult[$mtime])) {
			$arrResult[$mtime]['amount'] = $row['amount'];
			$maxAmount = $row['amount'] > $maxAmount ? $row['amount'] : $maxAmount;
		}
	}
}

$data = array(
	'type' => $type,
	'itemid' => $itemid,
	'arrItems' => $items,
	'arrConsumTypes' => ItemLogClass::getConsumType(),
	'startDate' => $startDate,
	'endDate' => $endDate,
	'arrResult'=>$arrResult,
	'maxAmount'=>$maxAmount,
	'headerCol'=>count($arrResult)+1,
	'headerTip'=>"{$startDate} - {$endDate} 【{$itemname}】 消耗数量柱状图",
	'itemlist'=>$itemlist,
	'itemname'=>$itemname,
);
//echo '<pre>';print_r($arrByDay);echo '</pre>';

$smarty->assign($data);
$smarty->display("module/analysis/item_consum_sum.tpl");
exit();