<?php
/**
 * 分时统计充值情况
 * @author linruirong@mingchao.com
 *
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

$tmpStartTime = strtotime($_REQUEST['dateStart']);
$tmpEndTime = strtotime($_REQUEST['dateEnd']);
$tmpStartTime = $tmpStartTime < strtotime(SERVER_ONLINE_DATE) ?  strtotime(SERVER_ONLINE_DATE) : $tmpStartTime ;
$dateStart = $tmpStartTime ? date('Y-m',$tmpStartTime) : date('Y-m',strtotime('-1month'));
$dateEnd = $tmpEndTime ? date('Y-m',$tmpEndTime) : date('Y-m');

$startYearMonth = explode('-',$dateStart);
$endYearMonth = explode('-',$dateEnd);
$startYear = $startYearMonth[0];
$startMonth = $startYearMonth[1];
$endYear = $endYearMonth[0];
$endMonth = $endYearMonth[1];

$dateStartTimeStamp = strtotime($dateStart.'-01');
$daysOfEndMonth = date('t',strtotime($dateEnd.'-01'));
$dateEndTimeStamp = strtotime($dateEnd.'-'.$daysOfEndMonth.' 23:59:59');

$diffMonth = ($endYear - $startYear) * 12 + $endMonth - $startMonth;

$select = " SUM(`pay_money`) AS total_money, COUNT(DISTINCT(account_name)) AS total_person ,
			COUNT(`id`) AS total_person_time, 
			CONCAT(`year`,'-',`month`) AS `date`, `year`,`month`  ";
//======== 查结果 =====
$sql = " SELECT {$select}
		 FROM ".T_DB_PAY_LOG_P." 
		 WHERE `pay_time` BETWEEN {$dateStartTimeStamp} AND {$dateEndTimeStamp} 
		 GROUP BY `year`,`month` 
		 ORDER BY  `pay_time` ";
$result = GFetchRowSet($sql);
//======== end 查结果 =====

$maxMoney = 0;
$maxPerson = 0;
$maxPersonTime = 0;
$maxArpu = 0;
$allTotalMoney = 0;
$payMonths = array();
if (is_array($result) && !empty($result)) {
	$tmpEndMonth = $startMonth + $diffMonth ;
	for ($m=$startMonth; $m <= $tmpEndMonth; $m++){
		$year = $startYear + ($m > 12 ? intval($m/12) : 0);
		$month = 0==$m%12 ? 12 : $m%12; 
		$date = $year.'-'.$month;
		$exist = false;
		foreach ($result as $key => $row) {
			if ($row['date'] == $date) {
				$maxMoney = $row['total_money'] > $maxMoney ? $row['total_money'] : $maxMoney;
				$maxPerson = $row['total_person'] > $maxPerson ? $row['total_person'] : $maxPerson;
				$maxPersonTime = $row['total_person_time'] > $maxPersonTime ? $row['total_person_time'] : $maxPersonTime;
				$allTotalMoney += $row['total_money'];
				$payMonths[$date]['total_money'] = round($row['total_money'],1);
				$payMonths[$date]['total_person'] = $row['total_person'];
				$payMonths[$date]['total_person_time'] = $row['total_person_time'];
				$exist = true;
				unset($result[$key]);
				break;
			}
		}
		if (!$exist) {
			$payMonths[$date]['total_money'] = 0;
			$payMonths[$date]['total_person'] = 0;
			$payMonths[$date]['total_person_time'] = 0;
		}
		$payMonths[$date]['arpu'] = $payMonths[$date]['total_person'] > 0 ? round($payMonths[$date]['total_money']/$payMonths[$date]['total_person'],1) : 0 ;
		$payMonths[$date]['tip'] = "金额：{$payMonths[$date]['total_money']}，人数：{$payMonths[$date]['total_person']}，人次：{$payMonths[$date]['total_person_time']}，ARPU值：{$payMonths[$date]['arpu']}";
		$maxArpu = $payMonths[$date]['arpu'] > $maxArpu ? $payMonths[$date]['arpu'] : $maxArpu;
	}
}
//echo '<pre>';print_r($payMonths);die();
$avgMoney = round($allTotalMoney/($diffMonth+1), 2);

$arrShowType = array(9=>'全部',1=>'金额',2=>'人数',3=>'人次',4=>'ARPU值',);
$showType = intval($_REQUEST['showType']) ? intval($_REQUEST['showType'])  : 1 ;
$data = array(
	'payMonths' => $payMonths,
	'maxPerson'=>$maxPerson,
	'maxPersonTime'=>$maxPersonTime,
	'maxMoney' => round($maxMoney,1),
	'maxArpu'=>$maxArpu,
	'avgMoney' => $avgMoney,
	'allTotalMoney' => round($allTotalMoney,1),
	'dateStart' => $dateStart,
	'dateEnd' => $dateEnd,
	'showType'=>$showType,
	'arrShowType'=>$arrShowType,
	'dateStrToday'=>date('Y-m'),
	'dateStrPrev'=>date('Y-m',strtotime('-1month',$dateStartTimeStamp)),
	'dateStrNext'=>date('Y-m',strtotime('+1month',$dateStartTimeStamp)),
	'dateStrOnline'=>date('Y-m',strtotime(SERVER_ONLINE_DATE)),
);
//echo '<pre>';print_r($data);die();
$smarty->assign($data);
$smarty->display("module/pay/pay_month.tpl");



