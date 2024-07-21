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
$tmpStartTime = $tmpStartTime ? $tmpStartTime : strtotime(date('Y-m-d',strtotime('-6day')));

$tmpStartTime = $tmpStartTime < strtotime(SERVER_ONLINE_DATE) ?  strtotime(SERVER_ONLINE_DATE) : $tmpStartTime ;
$dateStart = $tmpStartTime ? date('Y-m-d',$tmpStartTime) : date('Y-m-d',strtotime('-6day'));
$dateEnd = $tmpEndTime ? date('Y-m-d',$tmpEndTime) : date('Y-m-d');

$diffDay = abs(strtotime($dateStart) - strtotime($dateEnd))/(3600*24) + 1 ;

$dateStartTimeStamp = strtotime($dateStart);
$dateEndTimeStamp = strtotime($dateEnd.' 23:59:59');

$select = " SUM(`pay_money`) AS total_money , COUNT(DISTINCT(account_name)) AS total_person,
			COUNT(`id`) AS total_person_time, 
			CONCAT(`year`,'-',`month`,'-',`day` ) AS `date`,`year`,`month`,`day` ";

//======== 查结果 =====
$sql = " SELECT {$select}
		 FROM ".T_DB_PAY_LOG_P." 
		 WHERE `pay_time` BETWEEN {$dateStartTimeStamp} AND {$dateEndTimeStamp} 
		 GROUP BY `year`,`month`,`day` 
		 ORDER BY  `pay_time` ";
$result = GFetchRowSet($sql);
//======== end 查结果 =====

$maxMoney = 0;
$maxPerson = 0;
$maxPersonTime = 0;
$maxArpu = 0;
$allTotalMoney = 0;
$payDays = array();
if (is_array($result) && !empty($result)) {
	$timeStamp = $dateStartTimeStamp ;
	for ($day=0; $day < $diffDay; $day++){
		$date = date('Y-n-j',strtotime('+'.$day.'day',$timeStamp));
		$exist = false;
		foreach ($result as $key => $row) {
			if ($row['date'] == $date) {
				$maxMoney = $row['total_money'] > $maxMoney ? $row['total_money'] : $maxMoney;
				$maxPerson = $row['total_person'] > $maxPerson ? $row['total_person'] : $maxPerson;
				$maxPersonTime = $row['total_person_time'] > $maxPersonTime ? $row['total_person_time'] : $maxPersonTime;
				$allTotalMoney += $row['total_money'];
				$payDays[$date]['total_money'] = round($row['total_money'],1);
				$payDays[$date]['total_person'] = $row['total_person'];
				$payDays[$date]['total_person_time'] = $row['total_person_time'];
				$exist = true;
				unset($result[$key]);
				break;
			}
		}
		if (!$exist) {
			$payDays[$date]['total_money'] = 0;
			$payDays[$date]['total_person'] = 0;
			$payDays[$date]['total_person_time'] = 0;
		}
		$payDays[$date]['arpu'] = $payDays[$date]['total_person'] > 0 ? round($payDays[$date]['total_money']/$payDays[$date]['total_person'],1) : 0 ;
		$payDays[$date]['tip'] = "金额：{$payDays[$date]['total_money']}，人数：{$payDays[$date]['total_person']}，人次：{$payDays[$date]['total_person_time']}，ARPU值：{$payDays[$date]['arpu']}";
		$maxArpu = $payDays[$date]['arpu'] > $maxArpu ? $payDays[$date]['arpu'] : $maxArpu;
	}
}
$avgMoney = round($allTotalMoney/$diffDay, 2);

$arrShowType = array(9=>'全部',1=>'金额',2=>'人数',3=>'人次',4=>'ARPU值',);
$showType = intval($_REQUEST['showType']) ? intval($_REQUEST['showType']) : 1;
$data = array(
	'payDays' => $payDays,
	'maxMoney' => round($maxMoney,1),
	'maxPerson' => $maxPerson,
	'maxArpu' => $maxArpu,
	'maxPersonTime' => $maxPersonTime,
	'avgMoney' => $avgMoney,
	'allTotalMoney' => round($allTotalMoney,1),
	'dateStart' => $dateStart,
	'dateEnd' => $dateEnd,
	'showType'=>$showType,
	'arrShowType'=>$arrShowType,
	'dateStrToday'=>date('Y-m-d'),
	'dateStrPrev'=>date('Y-m-d',strtotime('-1day',$dateStartTimeStamp)),
	'dateStrNext'=>date('Y-m-d',strtotime('+1day',$dateStartTimeStamp)),
	'dateStrOnline'=>date('Y-m-d',strtotime(SERVER_ONLINE_DATE)),
);

$smarty->assign($data);
$smarty->display("module/pay/pay_day.tpl");



