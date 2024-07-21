<?php

/*
 * 单服概况
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;

$auth->assertModuleAccess(__FILE__);

$this_day_time = GetTime_Today0();
$cur_day_time = $this_day_time - 86400 ;
$now = time();

if (! isset($_REQUEST['dateStart'])) {
	//默认两周
	$dateStart = date('Y-m-d', strtotime("-13day")); 
} elseif ($_REQUEST['dateStart'] == 'ALL') {
	$dateStart = SERVER_ONLINE_DATE;
} else {
	$dateStart = $_REQUEST['dateStart'];
}


if (! isset($_REQUEST['dateEnd'])) {
	$dateEnd = strftime("%Y-%m-%d", time());
} elseif ($_REQUEST['dateEnd'] == 'ALL') {
	$dateEnd = strftime("%Y-%m-%d", time());
} else {
	$dateEnd = strtotime($_REQUEST['dateEnd']) > time() ? strftime("%Y-%m-%d", time()) : $_REQUEST['dateEnd'];
}

$dateStartStamp = strtotime($dateStart . ' 0:0:0');
$dateEndStamp = strtotime($dateEnd . ' 23:59:59');

$dateStartStamp = intval($dateStartStamp) > 0 ? intval($dateStartStamp) : strtotime(SERVER_ONLINE_DATE);
$dateEndStamp = intval($dateEndStamp) > 0 ? intval($dateEndStamp) : strtotime(SERVER_ONLINE_DATE);

$dateStartStr = strftime("%Y-%m-%d", $dateStartStamp);
$dateEndStr = strftime("%Y-%m-%d", $dateEndStamp);


$dateStrPrev = strftime("%Y-%m-%d", $dateStartStamp - 86400);
$dateStrToday = strftime("%Y-%m-%d");
$dateStrNext = strftime("%Y-%m-%d", $dateStartStamp + 86400);

$dateStartStamp = SS($dateStartStamp);
$dateEndStamp = SS($dateEndStamp);

$sqlAccount = " SELECT COUNT(`account`) AS `total_account` FROM t_account ";
$accountRs = GFetchRowOne($sqlAccount);
$total_account = $accountRs['total_account'];

$sqlRole = " SELECT COUNT(`role_id`) AS `total_role`, MAX(`level`) AS `max_level` FROM  ".T_DB_ROLE_ATTR_P;
$roleRs = GFetchRowOne($sqlRole);
$role_max_level = $roleRs['max_level'];
$total_role = $roleRs['total_role'];
$sqlPayAccountCnt = "  SELECT COUNT( DISTINCT(`account_name`) ) AS `pay_account_cnt` 
					   FROM ".T_DB_PAY_LOG_P." 
					   WHERE `pay_time`  BETWEEN {$dateStartStamp} AND {$dateEndStamp} 
					   ";
$payAccountCntRs = GFetchRowOne($sqlPayAccountCnt);
$payAccountCnt = intval( $payAccountCntRs['pay_account_cnt'] ) ;

$sqlOnline = " SELECT MAX(`online`) AS max_online, MAX(`dateline`) AS `date` 
			   FROM ".T_LOG_ONLINE." 
			   WHERE `dateline`  BETWEEN {$dateStartStamp} AND {$dateEndStamp} 
			   GROUP BY `year`,`month`,`day` 
			   ORDER BY `date` ASC ";
$online = GFetchRowSet($sqlOnline);

$sqlPay = " SELECT SUM(`pay_money`) AS total_pay, MAX(`pay_time`) AS `date` 
			FROM ".T_DB_PAY_LOG_P."  
			WHERE `pay_time`  BETWEEN {$dateStartStamp} AND {$dateEndStamp} 
			GROUP BY `year`,`month`,`day` ";
$pays = GFetchRowSet($sqlPay);

$payOnline = array();
$allMaxOnline = 0;
$allMaxPay = 0;
$allTotalPay = 0;
$diffDay = intval( ($dateEndStamp - $dateStartStamp )/86400) + 1; //算出相差的天数
for ( $day = 0; $day < $diffDay; $day++ ){
	$curStamp = strtotime('+'.$day.'day',$dateStartStamp );
	
	//======= start =充值数据=========
	$flagPay = false;
	foreach ($pays as $key => &$rowPay) {
		if ($rowPay['date'] > $curStamp+86400 ) {
			break;
		}
		if (date('Y-m-d',$rowPay['date']) == date('Y-m-d',$curStamp) ) {
			$flagPay = true;
			$payOnline[$curStamp]['total_pay'] = round($rowPay['total_pay'],1);
			$allMaxPay = $rowPay['total_pay'] > $allMaxPay ? $rowPay['total_pay'] : $allMaxPay;
			$allTotalPay +=  $rowPay['total_pay'];
			unset($pays[$key]);
			break;
		}
	}
	if (!$flagPay) {
		$payOnline[$curStamp]['total_pay'] = 0;
	}	
	//======= end =充值数据=========
	
	//======= start =在线数据=========
	$flagOnlie = false;
	foreach ($online as $key => &$rowOnline) {
		if ($rowOnline['date'] > $curStamp+86400 ) {
			break;
		}
		if (date('Y-m-d',$rowOnline['date']) == date('Y-m-d',$curStamp) ) {
			$flagOnlie = true;
			$payOnline[$curStamp]['max_online'] = $rowOnline['max_online'];
			$allMaxOnline = $rowOnline['max_online'] > $allMaxOnline ? $rowOnline['max_online'] : $allMaxOnline;
			unset($online[$key]);
			break;
		}
	}
	if (!$flagOnlie) {
		$payOnline[$curStamp]['max_online'] = 0;
	}
	//======= end =在线数据=========
}

$version = @file_get_contents('/data/mccq/server/version_server.txt');
$data = array(
	'allMaxOnline' => $allMaxOnline,
	'allMaxPay' => round($allMaxPay,1),
	'allTotalPay'=>round($allTotalPay,1),
	'payAccountCnt' => $payAccountCnt,
	'server_online_day' => SERVER_ONLINE_DATE ,
	'has_online_day' => intval( ( time()-strtotime(SERVER_ONLINE_DATE) ) / 86400 ) ,
	'role_max_level' => $role_max_level,
	'total_role' => $total_role,
	'total_account' => $total_account,
	'dateStart' =>  $dateStartStr,
	'dateEnd' =>  $dateEndStr,
	'dateStrPrev' =>  $dateStrPrev,
	'dateStrNext' =>  $dateStrNext,
	'dateStrToday' =>  $dateStrToday,
	'diffDay'=>$diffDay,
	'payOnline' => $payOnline,
	'version' => $version,
	'agent' => AGENT_NAME,
	'area_name'=>SERVER_NAME
);
$smarty->assign($data);
$smarty->display("module/world/game_survey.tpl");