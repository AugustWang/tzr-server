<?php
/**
 * @author linruirong
 * 
 * 注意：本脚本每天运行一次。
 * SHELL运行方式：
 * # /usr/bin/php update_stat_use_gold.php (默认，跑昨天的数据)。
 * # /usr/bin/php update_stat_use_gold.php 2011-01-24 (跑指定日期2011-01-24的数据)。
 * # /usr/bin/php update_stat_use_gold.php deal_old_data (跑指定日期的数据)。
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global_for_shell.php';
include_once SYSDIR_ADMIN.'/class/log_gold_class.php';

$params = trim($argv[1]);
if ($params && !('deal_old_data' == $params || strtotime($params) )  ) {
	die('参数错误，日期格式应为：YYYY-mm-dd'."\n");
}

$startExecTime = time();
echo basename(__FILE__) . " start at :".date('Y-m-d H:i:s',$startExecTime);

if ('deal_old_data' == $params) { //处理旧数据
	$sqlClear = " TRUNCATE TABLE t_stat_use_gold ; ";
	$date = 'deal_old_data';
}else{
	$date = strtotime($params) ;
	$date = $date ? $date : strtotime(date('Y-m-d',strtotime('-1day')));//默认跑前一天的数据
	$sqlClear = " DELETE FROM t_stat_use_gold WHERE `mtime`={$date} ";
}
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
	$spendType = array_keys(LogGoldClass::getSpendTypeList());
	$strSpendIds = implode(',',$spendType);
	$where = " WHERE `mtype` IN($strSpendIds) "; //从元宝使用日志中过滤出 玩家消耗元宝类型 的日志
	
	if ('deal_old_data' === $dateStartTime) {
		$where .= "";
	}else{
		$dateEndTime = $dateStartTime+86400-1;
		$where .= " AND `mtime` BETWEEN {$dateStartTime} AND {$dateEndTime} ";
	}
	
	$sqlSelect = "SELECT `level`, SUM(ABS(`gold_bind`)) AS `gold_bind`, SUM(ABS(`gold_unbind`)) AS `gold_unbind`, 
				       `mtype`, `itemid`, SUM(`amount`) AS `amount`, COUNT(`id`) AS `op_times`, MAX(`mtime`) AS `mtime`
				FROM `t_log_use_gold` 
				{$where}
				GROUP BY `level`, `mtype`, `itemid`, FROM_UNIXTIME(`mtime`,'%Y%m%d') ";

	$sqlCntRow = " SELECT COUNT(*) cnt FROM ({$sqlSelect}) AS tmp ";
	$rsCntRow = GFetchRowOne($sqlCntRow);
	$totalCnt = intval($rsCntRow['cnt']);
	$InserCnt = 300; //每次最多处理300条数据。
	$totalPage = ceil($totalCnt/$InserCnt);
//	echo "totalCnt={$totalCnt}\n sqlCntRow={$sqlCntRow}";

	for($page=1; $page<=$totalPage; $page++){
		$offset = ($page-1) * $InserCnt;
		$sqlPage = $sqlSelect." limit {$offset} , {$InserCnt} ";
		$rs = GFetchRowSet($sqlPage); 
		$sqlInsert = " INSERT INTO `t_stat_use_gold` (`level`, `gold_bind`, `gold_unbind`, `mtype`, `itemid`, `amount`, `op_times`, `mtime`, `year`, `month`, `day`, `hour`, `week`) VALUES ";
		foreach ($rs as &$row) {
			$mtime = strtotime(date('Y-m-d',$row['mtime']));
			$year = date('Y',$row['mtime']);
			$month = date('n',$row['mtime']);
			$day = date('j',$row['mtime']);
			$hour = date('G',$row['mtime']);
			$week = date('w',$row['mtime']);
			$sqlInsert .= "({$row['level']},{$row['gold_bind']},{$row['gold_unbind']},{$row['mtype']},{$row['itemid']},{$row['amount']},{$row['op_times']},{$mtime},{$year},{$month},{$day},{$hour},{$week}),";
		}
		$sqlInsert = trim($sqlInsert,',').';';
		GQuery($sqlInsert);
	}
}
