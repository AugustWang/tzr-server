<?php
/*
* Author: 杨金平, gdpencil@google.com
* 2009-12-4
* 流失用户
*/
//ob_start("ob_gzhandler");
define('IN_ODINXU_SYSTEM', true);
define('IMG_HEIGHT', 120);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;





$auth->assertModuleAccess(__FILE__);

$date1 = trim(SS($_REQUEST['date1']));
$date2 = trim(SS($_REQUEST['date2']));

if (! isset($_REQUEST['date1'])){
	$start_day = GetTime_Today0() - 7*86400;
	$date1 = strftime("%Y-%m-%d",$start_day);
	//$date1 = strftime("%Y-%m", time()) . '-01';
}
else
	$date1 = trim(SS($_REQUEST['date1']));

if (! isset($_REQUEST['date2']))
	$date2 = strftime("%Y-%m-%d", time());
else
	$date2 = trim(SS($_REQUEST['date2']));

$date1Stamp = strtotime($date1 . ' 0:0:0') or $date1Stamp = GetTime_Today0();
$date2Stamp = strtotime($date2 . ' 23:59:59') or $date2Stamp = time();

//默认应该显示多少天的数据(从哪一天开始，一直到今天)
if (! isset($_REQUEST['date1']))
{
	while ($date2Stamp + 1 - $date1Stamp < 86400 * 8) 
		$date1Stamp -= 86400;
	
	$server_open_stamp = strtotime(SERVER_ONLINE_DATE . ' 0:0:0');
	if ($server_open_stamp > $date1Stamp)
		$date1Stamp = $server_open_stamp;
		
	$date1 = GetDayString($date1Stamp);
}




//$dataAry = $itemAry[]['dateStr']
//$dataAry = $itemAry[]['online']
//$dataAry = $itemAry[]['paidOnline']

$ary = array();
$maxOnlineNum = $maxOnlinePaid = 0;
for($tempStamp = $date1Stamp;$tempStamp <$date2Stamp; $tempStamp += 60*60*24) {
		$tempAry = array(
			'datestr'=>date("m-d",$tempStamp),
			'serverOnlineDays'=>getServerOpenDays($tempStamp),
			'weekend'=>judgeIfWeekend($tempStamp),
			'onlineNum' =>getOnlineUserOfEachDay($tempStamp,$tempStamp+60*60*24),
			'onlinePaid'=>getOnlinePaidUserOfTimeSpan($tempStamp,$tempStamp+60*60*24)
			);		
			
		$ary[] = $tempAry;
		$maxOnlineNum = max($maxOnlineNum,$tempAry['onlineNum']);
		$maxOnlinePaid = max($maxOnlinePaid,$tempAry['onlinePaid']);
}

$aryWeek = array();
$maxWeekOnline = $maxWeekPaid = 0;
for($tempStamp = $date1Stamp;$tempStamp <$date2Stamp; $tempStamp += 7*60*60*24) {
	list($weekStart,$weekEnd) = getWeekStartAndEnd($tempStamp);
	$tempAry =  array(
			'datestr'=>date("m-d",$tempStamp), //本周开始时间
			'startStr'=>date('m-d',$weekStart),//本周结束时间
			'endStr'=>date('m-d',$weekEnd -24*60*60),
			'weekNo'=>getWeekno($tempStamp),
			'onlineNum' =>getOnlineUserOfEachday($weekStart,$weekEnd),
			'onlinePaid'=>getOnlinePaidUserOfTimeSpan($weekStart,$weekEnd),
			'weekend'=>judgeIfWeekend($tempStamp),
			'serverOnlineDays'=>getServerOpenDays($tempStamp)
		);	
		
		$maxWeekOnline = max($maxWeekOnline,$tempAry['onlineNum']);
		$maxWeekPaid = max($maxWeekPaid,$tempAry['onlinePaid']);
		$aryWeek[] = $tempAry;
}





$smarty->assign("date1", date('Y-m-d',$date1Stamp));
$smarty->assign("date2", date('Y-m-d',$date2Stamp));
$smarty->assign(array(
	'maxOnline'=>$maxOnlineNum == 0 ? 0: 120/$maxOnlineNum,
	'maxPaid'=>$maxOnlinePaid == 0 ? 0 :120/$maxOnlinePaid,
	'weekMaxOnline'=>$maxWeekOnline == 0 ? 0:120/$maxWeekOnline,
	'weekMaxPaid'=>$maxWeekPaid == 0 ? 0:120/$maxWeekPaid
));


$smarty->assign("ary", $ary);
$smarty->assign('aryWeek',$aryWeek);
$smarty->display("module/stat/user_leave_count.tpl");
exit();



//取得开服第几天
function getServerOpenDays($stamp){
	if (!defined('SERVER_ONLINE_DATE')){
		return  1;
	}
	
	return intval(($stamp - strtotime(SERVER_ONLINE_DATE))/(24*60*60));
	
}





function getWeekNo($time){
	if (!defined('SERVER_ONLINE_DATE')) {
		define('SERVER_ONLINE_DATE','2010-11-28');
	}
	$startStr = strtotime(SERVER_ONLINE_DATE);
	$span = $time - $startStr ;
	$weekNo = floor($span/(60*60*24*7))+1;
	return abs($weekNo);
}


function getOnlineuserOfEachDay($startStamp,$endStamp){
	$sql = "SELECT count(*) as num from db_role_ext_p where last_login_time > $startStamp and last_login_time < $endStamp";
	$result = GFetchRowOne($sql);
	return $result['num'];
}


function getOnlinePaidUserOfTimeSpan($start,$end){
	$sql = "SELECT count(distinct pay.role_id) as num from db_role_ext_p as ext,db_pay_log_p pay where ext.role_id = pay.role_id 
		and ext.last_login_time > $start and ext.last_login_time < $end ";
	$result = GFetchRowOne($sql);
	return $result['num'];
}


function getWeekStartAndEnd($time){
	if (date('w',$time) == 0){
		$start = strtotime(date("Y-m-d",$time));
	}else{
		$start = strtotime('last Sunday',$time);
	}
	$end = $start+7*60*60*24;
	return array($start,$end);
}

/*
function getOnlineUserOfEachday($dayStamp,$spanStamp){
	$sql = "SELECT count( distinct role_id) as num from t_log_behavior where log_time >= $dayStamp 
		and log_time <= $spanStamp and behavior_type = 3";
	$result =  GFetchRowOne($sql);
	return $result['num'];
}


function getOnlinePaidUserOfTimeSpan($startSpan,$endSpan){	
	$sql = "SELECT count(distinct pay.role_id) as num from t_log_behavior as beh ,db_pay_log_p pay where beh.role_id = 
		pay.role_id and beh.log_time > $startSpan and beh.log_time < $endSpan and behavior_type = 3 ";
	$result = GFetchRowOne($sql);
	return $result['num'];
}

*/
























