<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $smarty, $auth;

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
//echo "\$startDate={$startDate} \$endDate={$endDate} ";die();

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

$sqlByDay = " SELECT  `mtime`, `week`, SUM(`amount`) as `amount`, SUM(`op_times`) as `op_times`, {$fieldGold} FROM {$tblStat} {$where} GROUP BY `mtime`  HAVING gold > 0  ";
$rsByDay = GFetchRowSet($sqlByDay);
//echo '<pre>';print_r($rsByDay);echo '</pre>';
$diffDay = ceil(($endDateTime - $startDateTime)/86400); //两日期之间相差的天数
$maxGold = 0;
$maxAmount=0;
$maxOpTimes = 0;
$arrByDay = array();
for ($day=0; $day < $diffDay; $day++ ){
	$datetime = strtotime("+{$day}day",$startDateTime);
	$onlineDate = intval( ($datetime-$serverOnLineTime)/86400 )+1;
	$arrByDay[$datetime] = array('mtime'=>$datetime,'date'=>date('Y-m-d',$datetime), 'week'=>date('w',$datetime),'onlineDate'=>$onlineDate,'gold'=>0,'amount'=>0,'op_times'=>0);
}

//echo '<pre>';print_r($arrByDay);echo '</pre>';
foreach ($rsByDay as &$row) {
	$arrByDay[$row['mtime']]['gold'] = $row['gold'] ;
	$maxGold = $row['gold'] > $maxGold  ? $row['gold'] : $maxGold;
	$arrByDay[$row['mtime']]['amount'] = $row['amount'] ;
	$maxAmount = $row['amount'] > $maxAmount  ? $row['amount'] : $maxAmount;
	$arrByDay[$row['mtime']]['op_times'] = $row['op_times'] ;
	$maxOpTimes = $row['op_times'] > $maxOpTimes  ? $row['op_times'] : $maxOpTimes;
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
	'maxGold'=>$maxGold,
	'maxAmount'=>$maxAmount,
	'maxOpTimes'=>$maxOpTimes
);
//echo '<pre>';print_r($arrByDay);echo '</pre>';

$smarty->assign($data);
$smarty->display("module/analysis/gold_consum_by_type.tpl");
exit();