<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/log_silver_class.php';
//include_once SYSDIR_ADMIN.'/class/admin_item_class.php';

$serverOnLineTime = strtotime(SERVER_ONLINE_DATE);
if (!$serverOnLineTime) {
	die('未设置开服日期');
}
if (strtotime(date('Y-m-d')) == $serverOnLineTime ) {
	die('今天刚开服，得明天才能有统计的数据哦。');
}
$arrSilverType = array('全部','绑定','不绑定'); //银子类型
$type = intval($_REQUEST['type']);
$silverType = empty($_POST) ? 2 : intval($_REQUEST['silverType']); //默认统计不绑定
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

$tblStat = ' `t_stat_use_silver` ';
$where = " WHERE `mtime` BETWEEN {$startDateTime} AND {$endDateTime} ";
$where .= $type ? " AND `mtype`={$type} " : '';
$fieldSilver = "";
if (1==$silverType) {
	$fieldSilver = " SUM(`silver_bind`) as `silver` ";
}elseif (2==$silverType){
	$fieldSilver = " SUM(`silver_unbind`) as `silver` ";
}else {
	$fieldSilver = " SUM(`silver_bind` + `silver_unbind` ) as `silver` ";
}

$sqlByDay = " SELECT  `mtime`, `week`, {$fieldSilver} FROM {$tblStat} {$where} GROUP BY `mtime` ";
$rsByDay = GFetchRowSet($sqlByDay);

$sqlByAllHour = " SELECT  `hour`, {$fieldSilver} FROM {$tblStat} {$where} GROUP BY `hour` ";
$rsByAllHour = GFetchRowSet($sqlByAllHour);

$sqlByHour = " SELECT  `mtime`, `week`, `hour`, {$fieldSilver} FROM {$tblStat} {$where} GROUP BY `mtime`,`hour` ";
$rsByHour = GFetchRowSet($sqlByHour);

$diffDay = ceil(($endDateTime - $startDateTime)/86400); //两日期之间相差的天数

$arrByDay = array('max_silver'=>0,'rows'=>array());
for ($day=0; $day < $diffDay; $day++ ){
	$exist = false;
	$datetime = strtotime("+{$day}day",$startDateTime);
	foreach ($rsByDay as $key => &$row) {
		if ($datetime == $row['mtime'])  {
			$arrByDay['max_silver'] = $row['silver'] > $arrByDay['max_silver']  ? $row['silver'] : $arrByDay['max_silver'];
			$row['date'] = date('Y-m-d',$row['mtime']);
			array_push($arrByDay['rows'],$row);
			$exist = true;
			unset($rsByDay[$key]);
			break;
		}
	}
	if (!$exist) {
		array_push($arrByDay['rows'],array('silver'=>0,'mtime'=>$datetime,'date'=>date('Y-m-d',$datetime),'week'=>date('w',$datetime)));
	}
}

$arrByAllHour = array('max_silver'=>0,'rows'=>array());
for ($hour=0; $hour < 24; $hour++ ){
	$exist = false;
	foreach ($rsByAllHour as $key => &$row) {
		if ($hour == $row['hour'])  {
			$arrByAllHour['max_silver'] = $row['silver'] > $arrByAllHour['max_silver']  ? $row['silver'] : $arrByAllHour['max_silver'];
			array_push($arrByAllHour['rows'],$row);
			$exist = true;
			unset($rsByAllHour[$key]);
			break;
		}
	}
	if (!$exist) {
		array_push($arrByAllHour['rows'],array('silver'=>0,'hour'=>$hour));
	}
}

$tmp = array();
for ($hour=0; $hour < 24; $hour++ ){
	$tmp[$hour] = 0;
}
$arrByHour = array('max_silver'=>0,'rows'=>array());
for ($day=0; $day < $diffDay; $day++ ){
	$datetime = strtotime("+{$day}day",$startDateTime);
	$onlineDate = intval(($datetime - $serverOnLineTime)/86400)+1; //开服至此时几天
	$date = date('Y-m-d',$datetime);
	$week = date('w',$datetime);
	$arrByHour['rows'][$datetime] = array('date'=>$date,'week'=>$week,'onlineDate'=>$onlineDate,'subRows'=>$tmp);
}

foreach ($rsByHour as &$row) {
	$arrByHour['max_silver'] = $row['silver'] > $arrByHour['max_silver'] ? $row['silver'] : $arrByHour['max_silver']; 
	$arrByHour['rows'][$row['mtime']]['subRows'][$row['hour']] = intval($row['silver']);
}

$data = array(
	'type' => $type,
	'typeName' => $_REQUEST['typeName'],
	'silverType' => $silverType,
	'arrSilverType' => $arrSilverType,
	'arrSpendType' => LogSilverClass::GetConsumeTypeList(),
	'startDate' => $startDate,
	'endDate' => $endDate,
	'diffDay' => $diffDay,
	'arrByDay'=>$arrByDay,
	'arrByAllHour'=>$arrByAllHour,
	'arrByHour'=>$arrByHour,
);

$smarty->assign($data);
$smarty->display("module/analysis/silver_consum_hour.tpl");
exit();