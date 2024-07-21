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

$startDate = $_REQUEST['startDate'];
$endDate = $_REQUEST['endDate'];

$startDateTime = strtotime($startDate);
$endDateTime = strtotime($endDate) ? strtotime($endDate)+86399 : false;
if (!$startDateTime || !$endDateTime ) {
	$startDateTime = strtotime(date('Y-m-d',strtotime('-6day')));
	$endDateTime = strtotime(date('Y-m-d 23:59:59'));
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
//echo '<pre>';print_r($arrTable);echo '</pre>';die();

$whereAction = " AND `action`=1023 "; //1023 => '大明宝藏活动的采集获得',
$arrRsItem = array();
foreach ($arrTable as &$tbl) {
	$sql = " SELECT `itemid`, sum(`amount`) as `amount` 
			 FROM {$tbl} 
			 WHERE `start_time` BETWEEN {$startDateTime} AND {$endDateTime} {$whereAction} 
			 GROUP BY `itemid`";
	$rs = GFetchRowSet($sql);
	foreach ($rs as &$row) {
		$arrRsItem[$row['itemid']] = array(
			'itemid'=>$row['itemid'],
			'amount'=>intval($arrRsItem[$row['itemid']]['amount'] + $row['amount']),
		);
	}
	unset($rs,$sql);
}

$items = AdminItemClass::getItemHash();
foreach ($arrRsItem as $key => &$item) {
	$item['itemName'] = $items[$key];
}
unset($items);
$sqlPerson = " SELECT COUNT(DISTINCT(`role_id`)) AS cnt, `level`, max(`mtime`) AS `mtime`
			   FROM t_log_country_treasure 
			   WHERE `mtime` BETWEEN {$startDateTime} AND {$endDateTime}
			   GROUP BY `level`, FROM_UNIXTIME(`mtime`,'%Y%m%d') ";
$rsPerson = GFetchRowSet($sqlPerson);

$arrRsPerson = array();
$diffDay =  floor( ( $endDateTime - $startDateTime )/86400 );
for ($i=0; $i<=$diffDay; $i++){
	$datetime = $startDateTime+$i*86400;
	$arrRsPerson[$datetime] = array(
		'date'=>date('m.d', $datetime), 
		'week'=>date('w',$datetime),
		'total'=>0,
		'20_29'=>0,
		'30_39'=>0,
		'40_49'=>0,
		'50_59'=>0,
		'60_69'=>0,
		'70_79'=>0,
		'80_89'=>0,
		'90_99'=>0,
		'100_MAX'=>0,
	);
}

foreach ($rsPerson as &$person) {
	$time = strtotime(date('Y-m-d',$person['mtime']));
	$arrRsPerson[$time]['total'] = intval($arrRsPerson[$time]['total'] + $person['cnt']);
	if ($person['level'] <= 29) {
		$arrRsPerson[$time]['20_29'] += $person['cnt'];
		continue;
	}
	if ($person['level'] <= 39) {
		$arrRsPerson[$time]['30_39'] += $person['cnt'];
		continue;
	}
	if ($person['level'] <= 49) {
		$arrRsPerson[$time]['40_49'] += $person['cnt'];
		continue;
	}
	if ($person['level'] <= 59) {
		$arrRsPerson[$time]['50_59'] += $person['cnt'];
		continue;
	}
	if ($person['level'] <= 69) {
		$arrRsPerson[$time]['60_69'] += $person['cnt'];
		continue;
	}
	if ($person['level'] <= 79) {
		$arrRsPerson[$time]['70_79'] += $person['cnt'];
		continue;
	}
	if ($person['level'] <= 89) {
		$arrRsPerson[$time]['80_89'] += $person['cnt'];
		continue;
	}
	if ($person['level'] <= 99) {
		$arrRsPerson[$time]['90_99'] += $person['cnt'];
		continue;
	}
	$arrRsPerson[$time]['100_MAX'] += $person['cnt'];
}

$maxDatePerson = 0 ;
foreach ($arrRsPerson as &$person) {
	$maxDatePerson = $person['total'] > $maxDatePerson ? $person['total'] : $maxDatePerson;
}
//echo '<pre>';print_r($arrRsPerson);echo '</pre>';
//echo '<pre>';print_r($arrRsItem);echo '</pre>';

$data = array(
	'arrRsItem' => $arrRsItem,
	'arrRsPerson'=>$arrRsPerson,
	'maxDatePerson'=>$maxDatePerson,
	'startDate' => $startDate,
	'endDate' => $endDate,
	'dateStrPrev'=>date('Y-m-d',strtotime('-1day',$startDateTime)),
	'dateStrNext'=>date('Y-m-d',strtotime('+1day',$startDateTime)),
	'dateStrToday'=>date('Y-m-d'),
	'dateStrOnline'=>SERVER_ONLINE_DATE,
);
//echo '<pre>';print_r($arrByDay);echo '</pre>';

$smarty->assign($data);
$smarty->display("module/analysis/country_treasure_sum.tpl");
exit();