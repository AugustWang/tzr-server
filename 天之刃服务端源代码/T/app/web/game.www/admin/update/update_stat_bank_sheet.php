<?php
/**
 * @author linruirong
 * 
 * 注意：本脚本每天0点时准时运行一次，超过0点越久数据越不准。
 * SHELL运行方式：
 * # /usr/bin/php update_stat_bank_sheet.php
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global_for_shell.php';
include_once SYSDIR_ADMIN."/include/db_defines.php";

$startExecTime = time();
echo basename(__FILE__) . " start at :".date('Y-m-d H:i:s',$startExecTime);

$onlineDate = strtotime(SERVER_ONLINE_DATE);
$dbGame = DB_MING2_GAME;
$dbLog = DB_MING2_LOGS;
$startDateTime = strtotime(date('Y-m-d',strtotime('-1day')));
$endDateTime = $startDateTime + 86399;

$sqlTrading = "SELECT `type`, COUNT(sheet_id) AS sheet_cnt, SUM(current_num) AS sheet_gold, SUM(current_silver) AS sheet_silver FROM t_log_bank_sheet  WHERE state = 1 GROUP BY `type` " ; //还挂着的单
$arrTrading = GFetchRowSet($sqlTrading);
$sqlFinish = "SELECT `type`, COUNT(sheet_id) AS sheet_cnt FROM t_log_bank_sheet  WHERE state = 2 AND update_time BETWEEN {$startDateTime} AND {$endDateTime} GROUP BY `type` "; //今天刚结单的
$arrFinish = GFetchRowSet($sqlFinish);
$sqlCancel = "SELECT `type`, COUNT(sheet_id) AS sheet_cnt FROM t_log_bank_sheet  WHERE state = 3 AND num<>current_num AND update_time BETWEEN {$startDateTime} AND {$endDateTime} GROUP BY `type` "; //今天被撤单的，且已经交易了部份的
$arrCancel = GFetchRowSet($sqlCancel);
$sqlDeal = "SELECT `type`, COUNT(`id`) AS deal_cnt, SUM(num) AS deal_gold, SUM(silver) AS deal_silver, AVG(price) AS avg_price, MIN(price) AS min_price, MAX(price) AS max_price FROM t_log_bank_sheet_deal WHERE  mtime BETWEEN  {$startDateTime} AND {$endDateTime} GROUP BY `type` ";
$arrDeal = GFetchRowSet($sqlDeal);
/*echo '$sqlTrading='.$sqlTrading."\n";
echo '$sqlFinish='.$sqlFinish."\n";
echo '$sqlCancel='.$sqlCancel."\n";
echo '$sqlDeal='.$sqlDeal."\n";*/
$arrData = array(
	0 =>array(
		'type' =>           0,
		'sheet_cnt' =>      0,
		'sheet_gold' =>     0,
		'sheet_silver' =>   0,
		'deal_cnt' =>       0,
		'deal_gold' =>      0,
		'deal_silver' =>    0,
		'avg_price' =>      0,
		'min_price' =>      0,
		'max_price' =>      0,
		'mtime' =>$startDateTime,
	),	
	1 =>array(
		'type' =>           1,
		'sheet_cnt' =>      0,
		'sheet_gold' =>     0,
		'sheet_silver' =>   0,
		'deal_cnt' =>       0,
		'deal_gold' =>      0,
		'deal_silver' =>    0,
		'avg_price' =>      0,
		'min_price' =>      0,
		'max_price' =>      0,
		'mtime' =>$startDateTime,
	)
);
foreach ($arrTrading as $row) {
	$arrData[$row['type']]['sheet_cnt'] += $row['sheet_cnt'];
	$arrData[$row['type']]['sheet_gold'] += $row['sheet_gold'];
	$arrData[$row['type']]['sheet_silver'] += $row['sheet_silver'];
}
foreach ($arrFinish as $row) {
	$arrData[$row['type']]['sheet_cnt'] += $row['sheet_cnt'];
}
foreach ($arrCancel as $row) {
	$arrData[$row['type']]['sheet_cnt'] += $row['sheet_cnt'];
}
foreach ($arrDeal as $row) {
	$arrData[$row['type']]['deal_cnt'] += $row['deal_cnt'];
	$arrData[$row['type']]['sheet_gold'] += $row['deal_gold'];
	$arrData[$row['type']]['sheet_silver'] += $row['deal_silver'];
	$arrData[$row['type']]['deal_gold'] += $row['deal_gold'];
	$arrData[$row['type']]['deal_silver'] += $row['deal_silver'];
	$arrData[$row['type']]['avg_price'] += $row['avg_price'];
	$arrData[$row['type']]['min_price'] += $row['min_price'];
	$arrData[$row['type']]['max_price'] += $row['max_price'];
}

//print_r($arrData);
$sqlClear = " DELETE FROM t_stat_bank_sheet WHERE `mtime` = {$startDateTime} ";
GQuery($sqlClear);
foreach ($arrData as $row) {
	$sql = " INSERT INTO t_stat_bank_sheet (`type`,`sheet_cnt`,`sheet_gold`,`sheet_silver`,`deal_cnt`,`deal_gold`,`deal_silver`,`avg_price`,`min_price`,`max_price`,`mtime`)
			 VALUES ({$row['type']}, {$row['sheet_cnt']}, {$row['sheet_gold']}, {$row['sheet_silver']}, {$row['deal_cnt']}, {$row['deal_gold']}, {$row['deal_silver']}, {$row['avg_price']}, {$row['min_price']}, {$row['max_price']}, {$row['mtime']}) ";
	GQuery($sql);
}

$endExecTime = time();
$totalExecTime  = $endExecTime - $startExecTime;
echo ', end at :'.date('Y-m-d H:i:s',$endExecTime).' total use time '.$totalExecTime." second ";
echo "成功\n";
exit();
////////////==========