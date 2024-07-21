<?php
/**
 * @author Natsuki
 */

/*  单一查找(限定role_name)
 * 	国家统计
 * 	状态比例
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
global $auth,$smarty,$dictFaction;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN . '/class/chat_ban_class.php';
include_once SYSDIR_ADMIN . '/class/user_class.php';
include_once SYSDIR_ADMIN . "/include/search_user.php";


$state = array(
	1=>'领取状态',
	2=>'交还状态',
	3=>'管理员销毁',
	4=>'玩家销毁',
	5=>'玩家死亡'
);



global $dictFaction;



/**
 * 1.领取
 * 2.交还
 * 3.销毁
 * 4:玩家销毁,
 * 5:玩家死亡
 */

$start = strtotime(SS(trim($_REQUEST['start']))) or $start = GetTime_Today0();
$end = strtotime(SS(trim($_REQUEST['end']))) or $end = time();
$viewType = $_REQUEST['viewType'] or $viewType = 2;
$lastResult = array();

	//国家统计,收益金额,玩家人数,门派个数
	$sql = "select faction_id, status ,sum(last_bill) as money ,count(distinct role_id) as role_times, 
	count(distinct id) as taken_times from t_log_role_trading where end_time >= $start and end_time <= $end group by faction_id,status ";

	//faction_id,status,money,role_accept,role_times,taken_times,
	$result = GFetchRowSet($sql);
	$resultList = populateFactionDisplayField($result);
	$factionStat = $resultList;
	
	//hourlyComplete,hourlyDrop
	//cnt,hour,faction_id,status
	$hourlySql = "select count(*) as cnt,floor(start_time/3600) as hour,faction_id,status from t_log_role_trading "
	." where start_time >= $start and start_time <= $end group by hour,status,faction_id";
	$hourlyResult = GFetchRowSet($hourlySql);
	
	//hourlyReceive
	$receiverSql = "select count(*) as cnt,floor(start_time/3600) as hour,faction_id from t_log_role_trading"
	." where start_time >= $start and start_time <= $end group by hour,faction_id";
	$hourlyReceive = GFetchRowSet($receiverSql);
	$finalAry = populateHourlyData($start,$end,$hourlyResult,$hourlyReceive);
	
	
	//daily done,drop
	$dailySql = "select count(*) as cnt,floor(start_time/(3600*24)) as day,faction_id,status from t_log_role_trading "
	." where start_time >= $start and start_time <= $end group by day,status,faction_id";
	$dailyResult = GFetchRowSet($dailySql);
	
	//daily receive
	$dailyReceiverSql = "select count(*) as cnt,floor(start_time/(3600*24)) as day,faction_id from t_log_role_trading"
	." where start_time >= $start and start_time <= $end group by day,faction_id";
	$dailyReceive = GFetchRowSet($dailyReceiverSql);
	$dailyAry = populateDailyData($start,$end,$dailyResult,$dailyReceive);
	
	
	$smarty->assign(
		array(
			'finalAry'=>$finalAry,
			'dailyAry'=>$dailyAry,
			'factionStat'=>$factionStat
			)
	);



//public variables
$smarty->assign(array(
		'start'=>date("Y-m-d H:i:s",$start),
		'end'=>date("Y-m-d H:i:s",$end),
		'viewType'=>$viewType,
		'roleName'=>$roleName,
		'dictFaction'=>$dictFaction,
	
));

$smarty->display('module/stat/trading_log.tpl');


function populateDailyData($start,$end,$dailyResult,$dailyReceive){
	$finalAry = array();
	$start = floor($start/(3600*24));
	$end = ceil($end/(3600*24));
	for($itr = $start; $itr < $end + 2;$itr++){
		$temp = array();
		$temp['rec'] = getReceiveData($itr,$dailyReceive);
		$temp['done'] = getDataFromResult($itr,$dailyResult,2);
		$temp['drop'] = getDataFromResult($itr,$dailyResult,3);
		$temp['time'] = date("y-m-d",$itr*3600*24);
		$finalAry[] = $temp;	
	}
	return  $finalAry;	
}




/**
 * 各个国家的数据
 * @param $itr
 * @param $dailyReceive
 */
function  getReceiveData($itr,$result){
	$retAry = array(
		1=>0,
		2=>0,
		3=>0
	); 
	foreach ($result as $item){
		if (intval($item['day']) == $itr){
			$retAry[intval($item['faction_id'])] = $item['cnt'];
		}
	}
	return  $retAry;
}


/**
 * 
 * Enter description here ...
 * @param $type 2为done,3为drop
 */
function getDataFromResult($itr,$result,$type=2){
	$ret = array(
		1=>0,
		2=>0,
		3=>0
	);
	foreach ($result as $item){
		if (intval($item['day']) == $itr && $type == $item['status']){
			$ret[intval($item['faction_id'])] = $item['cnt'];
		}
		if (intval($item['day']) == $itr  && $type == 3 && in_array($item['status'], array(4,5))){
			$ret[intval($item['faction_id'])] = $item['cnt'];
		}
		
		
		
	}
	return  $ret;
}






/**
 * each item has four elements,rec/done/drop/time
 * @param unknown_type $start
 * @param unknown_type $end
 * @param unknown_type $hourlyResult
 * @param unknown_type $hourlyReceive
 */
function populateHourlyData($start,$end,$hourlyResult,$hourlyReceive){
	$finalAry = array();
	$start = floor($start/3600);
	$end = ceil($end/3600);
	for($itr = $start; $itr <$end+1; $itr++){
		$temp = array();
		$temp['rec'] = grasbReceiveData($itr, $hourlyReceive);
		$temp['done'] = grasbDataFromResult($itr, $hourlyResult,2);
		$temp['drop'] = grasbDataFromResult($itr, $hourlyResult,3);
		$temp['time'] = $itr*3600;
		$finalAry[$itr] = $temp;		
	}
	return $finalAry;
}


/**
 * 从done和drop两种状态中找出对应小时的数据	
 * @param $itr
 * @param $ary
 * @param $whichState (2,交还   3.销毁)
 */
function grasbDataFromResult($itr,$ary,$whichState=2){
//cnt,hour,faction_id,status
	$retAry = array(
		1=>0,
		2=>0,
		3=>0
	);

	foreach ($ary as $item){
		if (intval($item['hour']) == $itr && intval($item['status'] == $whichState)){
			$retAry[intval($item['faction_id'])] += $item['cnt'];
		}
		
		//补足另外两种状态
		if (intval($item['hour']) == $itr && $whichState  == 3 && in_array($item['status'],array(4,5))){
			$retAry[intval($item['faction_id'])] += $item['cnt'];
		}
	}
	return  $retAry;
}

/**
 * 给定特定的时间,返回一个三元数组	
 * @param $itr
 * @param $result
 */
function  grasbReceiveData($itr,$result){
	//cnt,hour,faction_id
	$retAry = array(
		1=>0,
		2=>0,
		3=>0
	);
	foreach($result as $item){
		if (intval($item['hour']) == $itr){
			$retAry[intval($item['faction_id'])] += $item['cnt'];
		}
	}
	return  $retAry;
}





/**
 * 
 
$state = array(
	1=>'领取状态',
	2=>'交还状态',
	3=>'销毁',
	4=>'玩家销毁',
	5=>'玩家死亡'
);

*/
//status,money,taken_times
function  populateRoleDisplayField($totalAry){
	$retAry = array(
		'accept'=>0,
		'drop'=>0,
		'complete'=>0,
		'earn'=>0
	);
	//accept
	
	foreach ($totalAry as $ary){		
		if ($ary['status'] == 2){
			$retAry['complete'] += $ary['taken_times'];
			$retAry['accept']+=$ary['taken_times'];
			$retAry['earn'] += $ary['money'];
		}
		
		if ($ary['status'] == 3){
			$retAry['drop'] += $ary['taken_times'];
			$retAry['accept']+= $ary['taken_times'];
		}
		
		if ($ary['status'] == 4){
			$retAry['user_drop'] += $ary['taken_times'];
			$retAry['accept']+= $ary['taken_times'];
		}
		
		if ($ary['status'] == 5){
			$retAry['dead'] += $ary['taken_times'];
			$retAry['accept']+= $ary['taken_times'];
		}
	}
	return $retAry;
}



//faction_id ,money,role_times,taken_times
function populateFactionDisplayField($ary){
	global $dictFaction;
	$result = array();
	foreach ($ary as $item){
		if(!is_array($result[intval($item['faction_id'])])){
			$result[intval($item['faction_id'])] = 	array();
		}
		
		$result[intval($item['faction_id'])]['factionName'] = $dictFaction[intval($item['faction_id'])];
		
		//接收状态
		$result[intval($item['faction_id'])]['role_accept'] += $item['role_times'];
		$result[intval($item['faction_id'])]['all_accept'] += $item['taken_times'];
		
		//交还状态
		if ($item['status'] == 2){
			$result[intval($item['faction_id'])]['all_earn'] += $item['money'];
			$result[intval($item['faction_id'])]['role_complete'] += $item['role_times'];
			$result[intval($item['faction_id'])]['all_complete'] += $item['taken_times'];
		}
		//销毁状态,玩家销毁,玩家死亡
		if ( in_array($item['status'], array(3,4,5))  ){
			$result[intval($item['faction_id'])]['role_des'] += $item['role_times'];
			$result[intval($item['faction_id'])]['all_des'] += $item['taken_times'];
		}
		
		
		
		
	}
	return $result;
}