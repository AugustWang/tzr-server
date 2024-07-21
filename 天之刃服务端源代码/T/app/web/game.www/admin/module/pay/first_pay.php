<?php
/**
 * 分时统计充值情况
 * @author linruirong@mingchao.com
 *
 */
define('IN_ODINXU_SYSTEM', true);
include "../../../config/config.php";
include SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);


$tmpStartTime = strtotime($_REQUEST['dateStart']);
$tmpEndTime = strtotime($_REQUEST['dateEnd']);
$tmpStartTime = $tmpStartTime ? $tmpStartTime : strtotime('-1month');
$tmpEndTime = $tmpEndTime ? $tmpEndTime : time();
$tmpStartTime = $tmpStartTime < strtotime(SERVER_ONLINE_DATE) ?  strtotime(SERVER_ONLINE_DATE) : $tmpStartTime ;
$dateStart = $tmpStartTime ? date('Y-m-d',$tmpStartTime) : date('Y-m-d',strtotime('-1month'));
$dateEnd = $tmpEndTime ? date('Y-m-d',$tmpEndTime) : date('Y-m-d');

$diffDay = abs(strtotime($dateEnd) - strtotime($dateStart))/(3600*24) + 1 ;

$dateStartTimeStamp = strtotime($dateStart);
$dateEndTimeStamp = strtotime($dateEnd.' 23:59:59');

$where = " AND `pay_time` BETWEEN {$dateStartTimeStamp} AND {$dateEndTimeStamp} ";

$sqlLevelTotalCnt = "  SELECT COUNT(`id`) AS `total_cnt` FROM ".T_DB_PAY_LOG_P." WHERE `is_first`=1 {$where} ";
$rsLevelTotalCnt = GFetchRowOne($sqlLevelTotalCnt);
$levelTotalCnt = $rsLevelTotalCnt['total_cnt'];

$sqlLevel = " SELECT `role_level`, COUNT(`id`) AS `cnt` FROM ".T_DB_PAY_LOG_P." WHERE `is_first`=1 {$where}  GROUP BY `role_level` ORDER BY `role_level` ASC ";
$rsLevel = GFetchRowSet($sqlLevel);

$sqlFirstByDate = "  SELECT MIN(`pay_time`) AS min_pay_time, COUNT(`id`) AS cnt, SUM(`pay_money`) AS `total_money`, SUM(`pay_gold`) AS `total_gold` 
 					 FROM ".T_DB_PAY_LOG_P."  WHERE `is_first`=1 {$where}   GROUP BY `year`,`month`,`day` ORDER BY min_pay_time ASC ";
$rsFirstByDate = GFetchRowSet($sqlFirstByDate);

foreach ($rsLevel as &$row) {
	$row['rate'] = $levelTotalCnt > 0 ? round($row['cnt']/$levelTotalCnt*100, 2) : 0 ;
}

$diffDay = intval( ($dateEndTimeStamp - $dateStartTimeStamp)/86400) + 1 ;
$dateStartDiffOnline = ( ( $dateStartTimeStamp - strtotime(SERVER_ONLINE_DATE) ) /86400) + 1 ;

$resultFirstByDate = array();
$maxPersonByDate = 0;
$maxMoneyByDate = 0;
$maxGoldByDate = 0;
$allMoney=0;

for ($i=0;$i<$diffDay;$i++){
	$current = strtotime("+{$i}day",$dateStartTimeStamp);
	$resultFirstByDate[$i] = array(
		'index' => $i+$dateStartDiffOnline,
		'date' => $current,
		'person'=>0,
		'total_money'=>0,
		'total_gold'=>0,
	);
	foreach ($rsFirstByDate as $key => &$row) {
		if (date('Y-m-d',$row['min_pay_time']) == date('Y-m-d',$current) ) {
			$resultFirstByDate[$i]['person'] = $row['cnt'];
			$resultFirstByDate[$i]['total_money'] = round($row['total_money'],1);
			$resultFirstByDate[$i]['total_gold'] = $row['total_gold'];
			$maxPersonByDate = $row['cnt'] > $maxPersonByDate ? $row['cnt'] : $maxPersonByDate;
			$maxMoneyByDate = $row['total_money'] > $maxMoneyByDate ? $row['total_money'] : $maxMoneyByDate;
			$maxGoldByDate = $row['total_gold'] > $maxGoldByDate ? $row['total_gold'] : $maxGoldByDate;
			$allPerson += $row['cnt']; 
			$allMoney += $row['total_money']; 
			unset($rsFirstByDate[$key]);
			break;
		}
	}
	$avgMoneyByDate = $allMoney > 0 ?  round($allMoney/$diffDay,1) : 0;
}

foreach ($rsFirstByDate as &$row) {
	$row['days'] = intval( ($row['min_pay_time'] - $dateStartTimeStamp)/86400 ) + 1; //开服距首付天数
}
$data = array(
	'rsLevel' => $rsLevel,
	'resultFirstByDate' => $resultFirstByDate,
	'maxPersonByDate' => $maxPersonByDate,
	'maxMoneyByDate' => round($maxMoneyByDate,1),
	'maxGoldByDate' => $maxGoldByDate,
	'dateStart'=>$dateStart,
	'dateEnd'=>$dateEnd,
	'avgMoneyByDate'=>$avgMoneyByDate,
	'allPerson'=>round($allPerson,1),
	'allMoney'=>round($allMoney,1),
);
$smarty->assign($data);
$smarty->display("module/pay/first_pay.tpl");