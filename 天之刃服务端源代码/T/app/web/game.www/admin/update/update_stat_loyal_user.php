<?php 
/**
 * @author wangtao
 * 
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global_for_shell.php';
define('TBL_STAT_LOYAL', 't_stat_loyal_user');

//读取昨天零点到今天零点的数据
$time = strtotime(date('Y-m-d',time()));
$yesTime = $time - 60*60*24;


$record = getTodayRecord($yesTime,$time);
$sql = makeInsertSqlFromArray($record,TBL_STAT_LOYAL);
$result = GQuery($sql);

$startExecTime = time();
echo basename(__FILE__) ."  start at :".date('Y-m-d H:i:s',$startExecTime);


/*
<td>日期</td>
<td>活跃用户数</td>
<td>忠诚用户数</td>
<td>最大在线</td>
<td>平均在线</td>
<td>当天新注册用户数</td>
<td>全部注册用户数</td>
 */

/*
<b>活跃用户</b>：最近7天总在线时间不低于7小时的用户。并且最近三天有登录
<br/>
<b>忠诚用户</b>：最近7天(不是周区间)最少有3次登录，每天登录多次只算1次，并且玩家级别大于等于20级。
<br/>
<b>平均在线</b>：某一天的 09:00:00--23:59:59 期间，游戏实际在线数的平均数值。
（不是24小时平均，因为0点到8点，半夜，人数太少，没有实际统计意义）
*/



function getTodayRecord($yesTime,$time){
	$result = array();
	$result['mtime'] = $time;
	//active 最近三天
	$threeDaysAgo = $time - 3*60*60*24;
	$sql = "select count(*) as active from t_stat_user_online online,db_role_ext_p ext 
	where online.user_id = ext.role_id and avg_online_time > 420 and last_offline_time > $threeDaysAgo ";
	$active = GFetchRowOne($sql);
	
	
	$result['active'] = $active['active'] or $result['active'] = 0;
	
	
	//loyal 最近7天
	$sevenDaysAgo = $time - 7*60*60*24;
	$sql = "select count( DISTINCT ri) as loyal from ( 
	select ri,count(mdate) as day_num from (	
	SELECT COUNT( id ) AS num, login.role_id AS ri, FLOOR( log_time /86400 ) AS mdate
	FROM t_log_login login, db_role_attr_p attr
		WHERE attr.role_id = login.role_id
		AND attr.level >20
		AND log_time >= $sevenDaysAgo
		AND log_time <= $time
		GROUP BY mdate, login.role_id
		HAVING num >0		
	) as d_table group by ri having count(mdate) >2
	) as dd_table";
	$loyal = GFetchRowOne($sql);
	
	
	
	$result['loyal'] = $loyal['loyal'] or $result['loyal'] = 0;
	
	$nineOClock = $time - 15*60*60;
	$sql = "select avg(online) as aver,max(online) as maxo from t_log_online where 
	dateline >= $nineOClock and dateline <= $time";
	$online = GFetchRowOne($sql);
	
	$result['avg_online'] = $online['aver'];
	$result['max_online'] = $online['maxo'];
	
	//new_user
	$sql = "select count(*) as new_user from db_role_base_p where create_time >= $yesTime and create_time < $time";
	$new_user = GFetchRowOne($sql);
	$result['new_user'] =$new_user['new_user'] or $result['new_user'] = 0; 
	
	
	//total_user
	$sql = "select count(*) as total_user from db_role_base_p where create_time < $time ";
	$total = GFetchRowOne($sql);
	$result['total_user'] = $total['total_user'] or $result['total_user'] = 0;
	
	//active 最近三天>20级
	$threeDaysAgo = $time - 3*60*60*24;
	$sql = "select count(*) as active_20 from t_stat_user_online online,db_role_ext_p ext,db_role_attr_p attr 
	where online.user_id = ext.role_id AND online.user_id = attr.role_id AND level>19 and avg_online_time > 420 and last_offline_time > $threeDaysAgo ";
	$active_20 = GFetchRowOne($sql);
	
	
	$result['active_20'] = $active_20['active_20'] or $result['active_20'] = 0;
	
	return $result;	
}
