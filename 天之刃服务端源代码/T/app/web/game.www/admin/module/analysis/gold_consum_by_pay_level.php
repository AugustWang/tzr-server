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
//以下区间除0-0以外，其他按 [a,b) 方式比较
$arrRmbLevel=array(
	'0—0'          => '0',
	'1—100'        => '[1 , 100)',
	'100—500'      => '[100 , 500)',
	'500—1000'     => '[500 , 1000)',
	'1000—5000'    => '[1000 , 5000)',
	'5000—10000'   => '[5000 , 10000)',
	'10000—50000'  => '[10000 , 50000)',
	'50000—∞'      => '>=50000'
);
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

$tblStat = ' `t_stat_use_gold_with_pay` ';
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


$maxGold = 0;
$maxAmount=0;
$maxOpTimes = 0;
$maxRoleCnt = 0;
$arrByPayLevel = array();
foreach ($arrRmbLevel as $rmbLevel => &$rmbLevelName) {
	$level=explode('—',$rmbLevel);
	if (0==$level[0] && 0==$level[1]) {
		$wherePay = " AND pay_money=0 ";
	}elseif('∞'==$level[1]) {
		$wherePay = " AND pay_money >={$level[0]}  ";
	}else {
		$wherePay = " AND pay_money >={$level[0]} AND pay_money < {$level[1]} "; //[a,b) 方式
	}
	$sqlByRmbLevel = " SELECT COUNT(DISTINCT(`user_id`)) as `role_cnt`, SUM(`amount`) as `amount`, count(`id`) as `op_times`, {$fieldGold} FROM {$tblStat} {$where} {$wherePay} ";
	$rsByRmbLevel = GFetchRowOne($sqlByRmbLevel);
	$maxGold = $rsByRmbLevel['gold'] > $maxGold ? $rsByRmbLevel['gold'] : $maxGold;
	$maxAmount = $rsByRmbLevel['amount'] > $maxAmount ? $rsByRmbLevel['amount'] : $maxAmount;
	$maxOpTimes = $rsByRmbLevel['op_times'] > $maxOpTimes ? $rsByRmbLevel['op_times'] : $maxOpTimes;
	$maxRoleCnt = $rsByRmbLevel['role_cnt'] > $maxRoleCnt ? $rsByRmbLevel['role_cnt'] : $maxRoleCnt;
	$arr = array(
		'level' => $rmbLevelName,
		'role_cnt' => intval($rsByRmbLevel['role_cnt']),
		'amount' => intval($rsByRmbLevel['amount']),
		'op_times' => intval($rsByRmbLevel['op_times']),
		'gold' => intval($rsByRmbLevel['gold']),
	);
	array_push($arrByPayLevel,$arr);
}

//echo '<pre>';print_r($arrByPayLevel);echo '</pre>';die();
$data = array(
	'type' => $type,
	'typeName' => $_REQUEST['typeName'],
	'goldType' => $goldType,
	'arrGoldType' => $arrGoldType,
	'arrSpendType' => LogGoldClass::getSpendTypeList(),
	'startDate' => $startDate,
	'endDate' => $endDate,
	'arrByPayLevel'=>$arrByPayLevel,
	'maxGold'=>$maxGold,
	'maxAmount'=>$maxAmount,
	'maxOpTimes'=>$maxOpTimes,
	'maxRoleCnt'=>$maxRoleCnt,
);
//echo '<pre>';print_r($arrByPayLevel);echo '</pre>';

$smarty->assign($data);
$smarty->display("module/analysis/gold_consum_by_pay_level.tpl");
exit();