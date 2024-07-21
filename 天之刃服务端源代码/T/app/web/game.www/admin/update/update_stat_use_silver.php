<?php
/**
 * @author linruirong
 * 
 * 注意：本脚本每天运行一次。
 * SHELL运行方式：
 * # /usr/bin/php update_stat_use_silver.php (默认，跑昨天的数据)。
 * # /usr/bin/php update_stat_use_silver.php 2011-01-24 (跑指定日期2011-01-24的数据)。
 * # /usr/bin/php update_stat_use_silver.php deal_old_data (跑指定日期的数据)。
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global_for_shell.php';
include_once SYSDIR_ADMIN."/include/db_defines.php";
include_once SYSDIR_ADMIN.'/class/log_silver_class.php';

$startExecTime = time();
echo basename(__FILE__) . " start at :".date('Y-m-d H:i:s',$startExecTime);

$onlineDate = strtotime(SERVER_ONLINE_DATE);
$dbGame = DB_MING2_GAME;
$dbLog = DB_MING2_LOGS;

if (!$onlineDate) {
	die("错误：未设置开服日期");
}
$params = trim($argv[1]);
if ($params && !('deal_old_data' == $params || strtotime($params) )  ) {
	die('参数错误，日期格式应为：YYYY-mm-dd'."\n");
}

$spendType = array_keys(LogSilverClass::GetConsumeTypeList());
$strSpendIds = implode(',',$spendType);
$where = " WHERE `mtype` IN($strSpendIds) "; //从银子使用日志中过滤出 玩家消耗银子类型 的日志

if ('deal_old_data' == $params) { //处理旧数据
	$sqlClear = " TRUNCATE TABLE {$dbGame}.t_stat_use_silver ; ";
	$startDateTime = $onlineDate;
	$endDateTime = strtotime(date('Y-m-d 23:59:59',strtotime('-1day')));
	$arrTblSubFix = array();
	for ($day=$startDateTime; $day<=$endDateTime; $day+=86400){
		array_push($arrTblSubFix,date('_Y_m',$day));
	}
	$arrTblSubFix = array_unique($arrTblSubFix);
}else{
	$startDateTime = strtotime($params) ;
	$startDateTime = $startDateTime ? $startDateTime : strtotime(date('Y-m-d',strtotime('-1day')));//默认跑前一天的数据
	$endDateTime = $startDateTime+86400-1;
	$sqlClear = " DELETE FROM {$dbGame}.t_stat_use_silver WHERE `mtime`={$startDateTime} ";
	$where .= " AND `mtime` BETWEEN {$startDateTime} AND {$endDateTime} ";
	$arrTblSubFix = array(date('_Y_m',$startDateTime));
}
GQuery($sqlClear); //清掉旧数据

//print_r($arrTblSubFix);
if (!empty($arrTblSubFix)) {
	foreach ($arrTblSubFix as &$month) {
		$tbl = "{$dbLog}.t_log_use_silver".$month;
		$sqlSelect = "SELECT SUM(ABS(`silver_bind`)) AS `silver_bind`, SUM(ABS(`silver_unbind`)) AS `silver_unbind`, 
		       `mtype`, `itemid`, SUM(`amount`) AS `amount`, COUNT(`id`) AS `op_times`, MAX(`mtime`) AS `mtime`
		FROM {$tbl} 
		{$where}
		GROUP BY `mtype`, `itemid`, FROM_UNIXTIME(`mtime`,'%Y%m%d') ";
		
		$sqlCntRow = " SELECT COUNT(*) cnt FROM ({$sqlSelect}) AS tmp ";
		$rsCntRow = GFetchRowOne($sqlCntRow);
		$totalCnt = intval($rsCntRow['cnt']);
		$InserCnt = 300; //每次最多处理300条数据。
		$totalPage = ceil($totalCnt/$InserCnt);
//		echo "\ntotalCnt={$totalCnt}\n sqlCntRow={$sqlCntRow}\n";

		for($page=1; $page<=$totalPage; $page++){
			$offset = ($page-1) * $InserCnt;
			$sqlPage = $sqlSelect." limit {$offset} , {$InserCnt} ";
			$rs = GFetchRowSet($sqlPage); 
			$sqlInsert = " INSERT INTO {$dbGame}.t_stat_use_silver (`silver_bind`, `silver_unbind`, `mtype`, `itemid`, `amount`, `op_times`, `mtime`, `year`, `month`, `day`, `hour`, `week`) VALUES ";
			foreach ($rs as &$row) {
				$mtime = strtotime(date('Y-m-d',$row['mtime']));
				$year = date('Y',$row['mtime']);
				$month = date('n',$row['mtime']);
				$day = date('j',$row['mtime']);
				$hour = date('G',$row['mtime']);
				$week = date('w',$row['mtime']);
				$sqlInsert .= "({$row['silver_bind']},{$row['silver_unbind']},{$row['mtype']},{$row['itemid']},{$row['amount']},{$row['op_times']},{$mtime},{$year},{$month},{$day},{$hour},{$week}),";
			}
			$sqlInsert = trim($sqlInsert,',').';';
			GQuery($sqlInsert);
		}
	}
}

$endExecTime = time();
$totalExecTime  = $endExecTime - $startExecTime;
echo ', end at :'.date('Y-m-d H:i:s',$endExecTime).' total use time '.$totalExecTime." second ";
echo "成功\n";
exit();
////////////==========