<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/log_gold_class.php';
//include_once SYSDIR_ADMIN.'/class/admin_item_class.php';

$serverOnLineTime = strtotime(SERVER_ONLINE_DATE);
if (!$serverOnLineTime) {
	die('未设置开服日期');
}
if (strtotime(date('Y-m-d')) == $serverOnLineTime ) {
	die('今天刚开服，得明天才能有统计的数据哦。');
}
$arrGoldType = array('全部','绑定','不绑定'); //元宝类型
$type = intval($_REQUEST['type']);
$goldType = empty($_POST) ? 2 : intval($_REQUEST['goldType']); //默认统计不绑定
$startDate = $_REQUEST['startDate'];
$endDate = $_REQUEST['endDate'];

$startDateTime = strtotime($startDate);
$endDateTime = strtotime($endDate) ? strtotime($endDate)+86399 : false;

if (!$startDateTime || !$endDateTime ) {
	$startDateTime = strtotime(date('Y-m-d',strtotime('-7day')));
	$endDateTime = strtotime(date('Y-m-d 23:59:59',strtotime('-1day')));
}
if ($startDateTime < $serverOnLineTime) {
	$startDateTime = $serverOnLineTime;
}
$yesTodayLastTime = strtotime(date('Y-m-d 23:59:59',strtotime('-1day')));
if ($endDateTime > $yesTodayLastTime) {
	$endDateTime = $yesTodayLastTime;
}
$startDate = date('Y-m-d',$startDateTime);
$endDate = date('Y-m-d',$endDateTime);

$tblStat = ' `t_stat_use_gold` ';
$where = " WHERE `mtime` BETWEEN {$startDateTime} AND {$endDateTime} ";
$where .= $type ? " AND `mtype`={$type} " : '';
$fieldGold = "";
if (1==$goldType) {
	$fieldGold = " SUM(`gold_bind`) as `gold` ";
}elseif (2==$goldType){
	$fieldGold = " SUM(`gold_unbind`) as `gold` ";
}else {
	$fieldGold = " SUM(`gold_bind` + `gold_unbind` ) as `gold` ";
}

$sqlByDay = " SELECT  `mtime`, `week`, {$fieldGold} FROM {$tblStat} {$where} GROUP BY `mtime` ";
$rsByDay = GFetchRowSet($sqlByDay);

$sqlByAllHour = " SELECT  `hour`, {$fieldGold} FROM {$tblStat} {$where} GROUP BY `hour` ";
$rsByAllHour = GFetchRowSet($sqlByAllHour);

$sqlByHour = " SELECT  `mtime`, `week`, `hour`, {$fieldGold} FROM {$tblStat} {$where} GROUP BY `mtime`,`hour` ";
$rsByHour = GFetchRowSet($sqlByHour);

$diffDay = ceil(($endDateTime - $startDateTime)/86400); //两日期之间相差的天数

$arrByDay = array('max_gold'=>0,'rows'=>array());
for ($day=0; $day < $diffDay; $day++ ){
	$exist = false;
	$datetime = strtotime("+{$day}day",$startDateTime);
	foreach ($rsByDay as $key => &$row) {
		if ($datetime == $row['mtime'])  {
			$arrByDay['max_gold'] = $row['gold'] > $arrByDay['max_gold']  ? $row['gold'] : $arrByDay['max_gold'];
			$row['date'] = date('Y-m-d',$row['mtime']);
			array_push($arrByDay['rows'],$row);
			$exist = true;
			unset($rsByDay[$key]);
			break;
		}
	}
	if (!$exist) {
		array_push($arrByDay['rows'],array('gold'=>0,'mtime'=>$datetime,'date'=>date('Y-m-d',$datetime),'week'=>date('w',$datetime)));
	}
}

$arrByAllHour = array('max_gold'=>0,'rows'=>array());
for ($hour=0; $hour < 24; $hour++ ){
	$exist = false;
	foreach ($rsByAllHour as $key => &$row) {
		if ($hour == $row['hour'])  {
			$arrByAllHour['max_gold'] = $row['gold'] > $arrByAllHour['max_gold']  ? $row['gold'] : $arrByAllHour['max_gold'];
			array_push($arrByAllHour['rows'],$row);
			$exist = true;
			unset($rsByAllHour[$key]);
			break;
		}
	}
	if (!$exist) {
		array_push($arrByAllHour['rows'],array('gold'=>0,'hour'=>$hour));
	}
}

$tmp = array();
for ($hour=0; $hour < 24; $hour++ ){
	$tmp[$hour] = 0;
}
$arrByHour = array('max_gold'=>0,'rows'=>array());
for ($day=0; $day < $diffDay; $day++ ){
	$datetime = strtotime("+{$day}day",$startDateTime);
	$onlineDate = intval(($datetime - $serverOnLineTime)/86400)+1; //开服至此时几天
	$date = date('Y-m-d',$datetime);
	$week = date('w',$datetime);
	$arrByHour['rows'][$datetime] = array('date'=>$date,'week'=>$week,'onlineDate'=>$onlineDate,'subRows'=>$tmp);
}

foreach ($rsByHour as &$row) {
	$arrByHour['max_gold'] = $row['gold'] > $arrByHour['max_gold'] ? $row['gold'] : $arrByHour['max_gold']; 
	$arrByHour['rows'][$row['mtime']]['subRows'][$row['hour']] = intval($row['gold']);
}

$data = array(
	'type' => $type,
	'typeName' => $_REQUEST['typeName'],
	'goldType' => $goldType,
	'arrGoldType' => $arrGoldType,
	'arrSpendType' => LogGoldClass::getSpendTypeList(),
	'startDate' => $startDate,
	'endDate' => $endDate,
	'diffDay' => $diffDay,
	'arrByDay'=>$arrByDay,
	'arrByAllHour'=>$arrByAllHour,
	'arrByHour'=>$arrByHour,
);

$smarty->assign($data);
$smarty->display("module/analysis/gold_consum_hour.tpl");
exit();