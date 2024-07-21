<?php
/**
 * @author wangtao
 * 
 */
 
//更新最近的在线状态
define('IN_ODINXU_SYSTEM', true);
include_once "../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global_for_shell.php';
define('ACTIVE_STANDARD', 7*60);


/**
 * today,mtime,avg
 */
  

 //由于要删除数据,所有函数的time由外部调用传入不要在函数内获取以免数据不同步
 
 
 //2:00
 $gMtime = strtotime('today 0:0:0');
 $lastNightTime = strtotime('-1 day 0:0:0');
 $lastSevenDays = strtotime(" -7 days 0:0:0");
 
 //转换时间格式
 $gMtime = date('Ymd',$gMtime);
 $lastNightTime = date('Ymd',$lastNightTime);
 $lastSevenDays =date('Ymd',$lastSevenDays);
 
 


$todayModifyAry = retrieveToday($gMtime,$lastNightTime);


updateToday($todayModifyAry,$gMtime);

$weekmodifyAry = retrieveWeek($gMtime,$lastSevenDays);
updateSevenDayas($weekmodifyAry);

/**
 * 记录本日的活跃用户
 */
recordActivePlayer(intval($gMtime));


echo "\n update_stat_user_online.php 成功 at ".date("Y-m-d H:i:s");

//removeObsoleteData($lastSevenDays);


/**
 * update the today,total,create,last_record_time      id,today,mtime
 */
function updateToday($recordAry,$mtime){
    $zeroSql = "
        update t_stat_user_online set today_live_time = 0;
    ";
    GQuery($zeroSql);
    foreach ($recordAry as $item) {
        $sql = " 
        insert into t_stat_user_online  
        (user_id,total_live_time,today_live_time,last_record_time)
        values
        ( {$item['role_id']} , {$item['today']} , {$item['today']} , {$mtime} )
        on duplicate key update 
            total_live_time = total_live_time + {$item['today']},
            today_live_time = {$item['today']},
            last_record_time =  {$mtime} 
        ";
        GQuery($sql);
    }
}



/**
 * update the avg column    id  avg
 */
function updateSevenDayas($recordAry){
    $zeroSql = "update t_stat_user_online set avg_online_time = 0";
    GQuery($zeroSql);
    foreach ($recordAry as $item) {
        $sql = "insert into t_stat_user_online  
        (user_id,avg_online_time)
        values
        ({$item['role_id']},{$item['avg']})
        on duplicate key update 
            avg_online_time = {$item['avg']};
        ";
        GQuery($sql);
    }
}


/**
 * get data should be updated 
 */
function retrieveToday($mtime,$yesTime){
    $sql = "
    select role_id ,sum(online_time) as today from t_log_daily_online where mdate >=$yesTime and mdate<$mtime group by role_id
        ";
    $result = GFetchRowSet($sql);
    return $result;
}


/**
 * get data need to be updated for the last 7 days
 */
function retrieveWeek($mtime,$lastSevenTime){
    $sql  = "select role_id,sum(online_time) as avg from t_log_daily_online where mdate>=$lastSevenTime and mdate<$mtime group by role_id";
    $result = GFetchRowSet($sql);
    return $result;
}



/**
 * delete date out of date
 */
function removeObsoleteData($time){
    $sql = "delete from t_log_daily_online where mdate < $time";
    GQuery($sql);
}



/**
 * 记录某一天的活跃用户
 * @param $ymd
 */
function recordActivePlayer($ymd){
	$sql = "select user_id,avg_online_time,level from t_stat_user_online online, db_role_attr_p attr where attr.role_id = user_id and avg_online_time > ".ACTIVE_STANDARD;
	$result = GFetchRowSet($sql);
	
	$recList = array();
	foreach ($result as $item){
		$temp = array();
		$temp['role_id'] = $item['user_id'];
		$temp['avg_online_time'] = $item['avg_online_time'];
		$temp['ymd'] = $ymd;
		$temp['level'] = $item['level'];
		$recList[] = $temp;
	}
	if(count($recList) < 1) {
         return;       
	}
	
	$sql = 'insert into t_log_active_user_daily(role_id,avg_online_time,ymd,level) values ';
	
	$valuesAry = array();
	foreach($recList as $item){
		$valuesAry[] = "( {$item['role_id']},{$item['avg_online_time']},{$item['ymd']},{$item['level']})";		
	}
	$valueStr = implode(',', $valuesAry);
	$sql .= $valueStr;
	GQuery($sql);
}





?>
