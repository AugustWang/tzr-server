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
$viewType = intval($_REQUEST['viewType']) ? intval($_REQUEST['viewType']) : 1 ; //默认显示综合统计图
$tmpStartTime = $tmpStartTime ? $tmpStartTime : strtotime(date('Y-m-d',strtotime('-6day')));
$tmpStartTime = $tmpStartTime < strtotime(SERVER_ONLINE_DATE) ?  strtotime(SERVER_ONLINE_DATE) : $tmpStartTime ;

$dateStart = $tmpStartTime ? date('Y-m-d',$tmpStartTime) : date('Y-m-d');
$dateEnd = $tmpEndTime ? date('Y-m-d',$tmpEndTime) : date('Y-m-d');

$diffDay = abs(strtotime($dateStart) - strtotime($dateEnd))/(3600*24) + 1 ;
$dateStartTimeStamp = strtotime($dateStart);
$dateEndTimeStamp = strtotime($dateEnd.' 23:59:59');

//======== 查结果 =====
if (1==$viewType) { //查多天，只计算综合结果
	$sqlSumHour = " SELECT SUM(`pay_money`) AS total_money, COUNT(DISTINCT(account_name)) AS total_person,
					COUNT(`id`) AS total_person_time,`hour`
					FROM ".T_DB_PAY_LOG_P."
					WHERE `pay_time` BETWEEN {$dateStartTimeStamp} AND {$dateEndTimeStamp} 
					GROUP BY `hour` 
					ORDER BY `hour` ASC ";
	$resultSumHour = GFetchRowSet($sqlSumHour);	
	
	$showType = intval($_REQUEST['showType']) ? intval($_REQUEST['showType']) :1 ; 
	$maxSumMoney = 0;
	$maxSumPerson = 0;
	$maxSumPersonTime = 0;
	$maxSumArpu = 0;
	$allSumTotalMoney = 0;	
	$paySumHours = array();
	if (is_array($resultSumHour) && !empty($resultSumHour)) {
		for ($hour=0; $hour <= 23 ; $hour++){
			$existSum = false;
			foreach ($resultSumHour as $key => $row) {
				if ($row['hour'] == $hour) {
					$maxSumMoney = $row['total_money'] > $maxSumMoney ? $row['total_money'] : $maxSumMoney;
					$maxSumPerson = $row['total_person'] > $maxSumPerson ? $row['total_person'] : $maxSumPerson;
					$maxSumPersonTime = $row['total_person_time'] > $maxSumPersonTime ? $row['total_person_time'] : $maxSumPersonTime;
					
					$allSumTotalMoney += $row['total_money'];
					$paySumHours[$hour]['total_money'] = round($row['total_money'],1);
					$paySumHours[$hour]['total_person'] = $row['total_person'];
					$paySumHours[$hour]['total_person_time'] = $row['total_person_time'];
					$existSum = true;
					unset($resultSumHour[$key]);
					break;
				}
			}
			if (!$existSum) {
				$paySumHours[$hour]['total_money'] = 0;
				$paySumHours[$hour]['total_person'] = 0;
				$paySumHours[$hour]['total_person_time'] = 0;
			}
			$paySumHours[$hour]['arpu'] = $paySumHours[$hour]['total_person'] > 0 ? round($paySumHours[$hour]['total_money']/$paySumHours[$hour]['total_person'],1) : 0 ;
			$paySumHours[$hour]['tip'] = "金额：{$paySumHours[$hour]['total_money']}，人数：{$paySumHours[$hour]['total_person']}，人次：{$paySumHours[$hour]['total_person_time']}，ARPU值：{$paySumHours[$hour]['arpu']}";
			$maxSumArpu = $paySumHours[$hour]['arpu'] > $maxSumArpu ? $paySumHours[$hour]['arpu'] : $maxSumArpu;
		}
	}
	$avgSumMoney = round($allSumTotalMoney/$diffDay/24, 2);
	
}else {
	$select = " SUM(`pay_money`) AS total_money , COUNT(DISTINCT(account_name)) AS total_person,
				COUNT(`id`) AS total_person_time, 
				CONCAT(`year`,'-',`month`,'-',`day` ) AS `date`,
				`year`,`month`,`day`,`hour` ";
	
	$sql = " SELECT {$select}
			 FROM ".T_DB_PAY_LOG_P." 
			 WHERE `pay_time` BETWEEN {$dateStartTimeStamp} AND {$dateEndTimeStamp} 
			 GROUP BY `year`,`month`,`day`,`hour` 
			 ORDER BY  `pay_time` ";
	$result = GFetchRowSet($sql);	
	
	$maxMoney = 0;
	$maxPerson = 0;
	$maxPersonTime = 0;
	$maxArpu = 0;
	$allTotalMoney = 0;	
	$showType = isset($_REQUEST['showType']) ? intval($_REQUEST['showType']) : 1 ; //默认显示“金额”视图
	$payHours = array();
	if (is_array($result) && !empty($result)) {
		$timeStamp =  $dateEndTimeStamp >  $dateStartTimeStamp ? $dateEndTimeStamp : $dateStartTimeStamp ;
		for ($day=0; $day < $diffDay; $day++){
			$date = date('Y-n-j',strtotime('-'.$day.'day',$timeStamp));
			for ($hour=0; $hour <= 23 ; $hour++){
				$exist = false;
				foreach ($result as $key => $row) {
					if ($row['date'] == $date && $row['hour'] == $hour) {
						$maxMoney = $row['total_money'] > $maxMoney ? $row['total_money'] : $maxMoney;
						$maxPerson = $row['total_person'] > $maxPerson ? $row['total_person'] : $maxPerson;
						$maxPersonTime = $row['total_person_time'] > $maxPersonTime ? $row['total_person_time'] : $maxPersonTime;
						
						$allTotalMoney += $row['total_money'];
						$payHours[$date][$hour]['total_money'] = round($row['total_money'],1);
						$payHours[$date][$hour]['total_person'] = $row['total_person'];
						$payHours[$date][$hour]['total_person_time'] = $row['total_person_time'];
						$exist = true;
						unset($result[$key]);
						break;
					}
				}
				if (!$exist) {
					$payHours[$date][$hour]['total_money'] = 0;
					$payHours[$date][$hour]['total_person'] = 0;
					$payHours[$date][$hour]['total_person_time'] = 0;
				}
				$payHours[$date][$hour]['arpu'] = $payHours[$date][$hour]['total_person'] > 0 ? round($payHours[$date][$hour]['total_money']/$payHours[$date][$hour]['total_person'],1) : 0 ;
				$payHours[$date][$hour]['tip'] = "金额：{$payHours[$date][$hour]['total_money']}，人数：{$payHours[$date][$hour]['total_person']}，人次：{$payHours[$date][$hour]['total_person_time']}，ARPU值：{$payHours[$date][$hour]['arpu']}";
				$maxArpu = $payHours[$date][$hour]['arpu'] > $maxArpu ? $payHours[$date][$hour]['arpu'] : $maxArpu;
			}
		}
	}
	$avgMoney = round($allTotalMoney/$diffDay/24, 2);
}


//======== end 查结果 =====

$arrShowType = array(9=>'全部',1=>'金额',2=>'人数',3=>'人次',4=>'ARPU值',);
$arrViewType = array(1=>'综合统计图',2=>'按天统计图');

$data = array(
	'payHours' => $payHours,
	'maxMoney' => round($maxMoney,1),
	'avgMoney' => $avgMoney,
	'allTotalMoney' => round($allTotalMoney,1),
	'maxMoney' => round($maxMoney,1),
	'maxPerson' => $maxPerson,
	'maxPersonTime' => $maxPersonTime,
	'maxArpu' => $maxArpu,
	
	'maxSumMoney' =>    round($maxSumMoney,1),
	'maxSumPerson' =>   $maxSumPerson,
	'maxSumPersonTime'=>$maxSumPersonTime,
	'maxSumArpu' =>     $maxSumArpu,
	'allSumTotalMoney'=>round($allSumTotalMoney,1),	
	'paySumHours' =>    $paySumHours,
	'avgSumMoney' => $avgSumMoney,
	
	'dateStart' => $dateStart,
	'dateEnd' => $dateEnd,
	'showType'=>$showType,
	'arrShowType'=>$arrShowType,
	'viewType'=>$viewType,
	'arrViewType'=>$arrViewType,
	'dateStrToday'=>date('Y-m-d'),
	'dateStrPrev'=>date('Y-m-d',strtotime('-1day',$dateStartTimeStamp)),
	'dateStrNext'=>date('Y-m-d',strtotime('+1day',$dateStartTimeStamp)),
	'dateStrOnline'=>date('Y-m-d',strtotime(SERVER_ONLINE_DATE)),
);
//echo '<pre>';print_r($data);die();
$smarty->assign($data);
$smarty->display("module/pay/pay_hour.tpl");



