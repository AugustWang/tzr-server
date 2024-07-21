<?php
/**
 * @author linruirong
 * 
 * 注意：本脚本每天运行一次。
 * SHELL运行方式：
 * # /usr/bin/php update_stat_educate.php (默认，跑昨天的数据)。
 * # /usr/bin/php update_stat_educate.php 2011-01-24 (跑指定日期2011-01-24的数据，注意：此操作，时间距今天越久前数据会越不准。不建议用。）
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global_for_shell.php';
include_once SYSDIR_ADMIN.'/class/log_gold_class.php';

$params = trim($argv[1]);
if ($params && !strtotime($params)   ) {
	die('参数错误，日期格式应为：YYYY-mm-dd'."\n");
}

$startExecTime = time();
echo basename(__FILE__) . " start at :".date('Y-m-d H:i:s',$startExecTime);


$date = strtotime($params) ;
$date = $date ? $date : strtotime(date('Y-m-d',strtotime('-1day')));//默认跑前一天的数据
$sqlClear = " DELETE FROM t_stat_educate WHERE `mtime`={$date} ";

GQuery($sqlClear);
deal($date);

$endExecTime = time();
$totalExecTime  = $endExecTime - $startExecTime;
echo ', end at :'.date('Y-m-d H:i:s',$endExecTime).' total use time '.$totalExecTime." second ";
echo "成功\n";
////////////==========
exit();

function deal($dateStartTime)
{
	$ymd = date('Ymd',$dateStartTime);
	$dateEndTime = $dateStartTime+86400-1;
	$sqlEducateLog = " SELECT SUM(`in_number`) as total_in_number FROM t_log_educate WHERE start_time BETWEEN {$dateStartTime} AND {$dateEndTime} ";
	$rsEducateLog = GFetchRowOne($sqlEducateLog);
	
	$sqlActiveEducate = " SELECT COUNT(DISTINCT re.roleid) AS active_educate   FROM db_role_educate_p re, t_log_active_user_daily laud  WHERE  re.roleid = laud.role_id  AND laud.ymd={$ymd} ";
	$rsActiveEducate = GFetchRowOne($sqlActiveEducate);
	
	$sqlActive = " SELECT COUNT(DISTINCT lre.role_id) AS active_join  FROM t_log_role_educate lre, t_log_active_user_daily laud WHERE lre.start_time between {$dateStartTime} AND {$dateEndTime} and lre.role_id = laud.role_id AND laud.ymd={$ymd}";
	$rsActive = GFetchRowOne($sqlActive);
	
	$sqlEducate = " SELECT COUNT( DISTINCT `roleid`) as total_educate FROM db_role_educate_p WHERE `teacher` IS NOT NULL OR `student_num` > 0  ";
	$rsEducate = GFetchRowOne($sqlEducate);
	
	$sqlGold = " SELECT SUM(`gold_bind`)+SUM(`gold_unbind`) as total_gold FROM t_log_use_gold WHERE `mtype`=3009 AND `mtime`  BETWEEN {$dateStartTime} AND {$dateEndTime} "; //3009=>师徒副本消耗元宝
	$rsGold = GFetchRowOne($sqlGold);
	
	$sqlOnline = " SELECT MAX(`online`) as max_online FROM t_log_online WHERE dateline  BETWEEN {$dateStartTime} AND {$dateEndTime}    ";
	$rsOnline = GFetchRowOne($sqlOnline);
	
	$total_in_number = intval($rsEducateLog['total_in_number']); //当天参与师徒副本的人数。
	$total_educate = intval($rsEducate['total_educate']); //当天有师、徒关系的人数
	$total_gold = intval($rsGold['total_gold']); //当天师徒副本刷幸运积分扣除元宝总数
	$max_online = intval($rsOnline['max_online']); //当天最高在线用户量。
	$active_educate = intval($rsActiveEducate['active_educate']); // 活跃且有师徒关系的玩家数
	$active_join = intval($rsActive['active_join']); //当天活跃且有参加师徒副本的玩家数
	$sqlInsert = " INSERT INTO t_stat_educate(`join_count`,`active_join`,`active_educate`, `total_educate`,`total_gold`,`max_online`,`mtime`)
									values({$total_in_number},{$active_join},{$active_educate},{$total_educate},{$total_gold},{$max_online},{$dateStartTime});";
	
 	GQuery($sqlInsert);
}
