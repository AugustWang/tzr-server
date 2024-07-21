<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/log_gold_class.php';

$serverOnLineTime = strtotime(SERVER_ONLINE_DATE);
if (!$serverOnLineTime) {
	die('未设置开服日期');
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

$arrSpendType = LogGoldClass::getSpendTypeList();
$strSpendTypeIds = implode(',',array_keys($arrSpendType));
$where = " WHERE `mtime` BETWEEN {$startDateTime} AND {$endDateTime} ";
$where .= $type ? " AND `mtype`={$type} " : " AND `mtype` in ({$strSpendTypeIds}) ";
$fieldGold = "";
$having = "";
if (1==$goldType) {
	$fieldGold = " SUM(`gold_bind`) as `gold` ";
	$having = " HAVING `gold` > 0 ";
}elseif (2==$goldType){
	$fieldGold = " SUM(`gold_unbind`) as `gold` ";
	$having = " HAVING `gold` > 0 ";
}else {
	$fieldGold = " SUM(`gold_bind` + `gold_unbind` ) as `gold` ";
	$having = " HAVING `gold` > 0 ";
}

$sql = "SELECT COUNT(`user_id`) AS `role_cnt` ,MAX(`mtime`) as `mtime` ,  {$fieldGold} FROM t_log_use_gold {$where} GROUP BY FROM_UNIXTIME(`mtime`,'%Y%m%d') {$having} ";
$rs = GFetchRowSet($sql);

$diffDay = ceil(($endDateTime - $startDateTime)/86400); //两日期之间相差的天数
$arrData = array();
$max_gold = 0;
$max_role_cnt = 0;
for ($day=0; $day < $diffDay; $day++){
	$datetime = strtotime("+{$day}day",$startDateTime);
	$onlineDate = intval( ($datetime-$serverOnLineTime)/86400 )+1;
	$arrData[$datetime] =  array(
		'date'=>date('Y-m-d',$datetime),
		'week'=>date('w',$datetime),
		'onlinedays'=> $onlineDate,
		'role_cnt'=>0,
		'gold'=>0
	);
}

foreach ($rs as &$row) {
	$datetime = strtotime(date('Y-m-d',$row['mtime']));
	if(!empty($arrData[$datetime])){
		$arrData[$datetime]['role_cnt'] = intval($row['role_cnt']);
		$arrData[$datetime]['gold'] = intval($row['gold']);
		$max_role_cnt = $row['role_cnt'] > $max_role_cnt ? $row['role_cnt'] : $max_role_cnt;
		$max_gold = $row['gold'] > $max_gold ? $row['gold'] : $max_gold;
	}
}


$data = array(
	'type' => $type,
	'typeName' => $_REQUEST['typeName'],
	'goldType' => $goldType,
	'arrGoldType' => $arrGoldType,
	'arrSpendType' => $arrSpendType,
	'startDate' => $startDate,
	'endDate' => $endDate,
	'max_role_cnt'=>$max_role_cnt,
	'max_gold'=>$max_gold,
	'diffDay' => $diffDay,
	'arrData'=>$arrData,
);

$smarty->assign($data);
$smarty->display("module/analysis/gold_consum_role_count.tpl");
exit();