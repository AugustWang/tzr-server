<?php
/**
 * @author linruirong
 * 
 * 注意：本脚本每天运行一次。
 * SHELL运行方式：
 * # /usr/bin/php update_stat_use_gold_with_pay.php (默认，跑昨天的数据)
 * # /usr/bin/php update_stat_use_gold_with_pay.php 2011-01-24 (跑指定日期2011-01-24的数据)
 * # /usr/bin/php update_stat_use_gold_with_pay.php deal_old_data (跑指定日期的数据)
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
	$sqlClear = " TRUNCATE TABLE t_stat_use_gold_with_pay ; ";
	$whereMtime = "";
}else{
	$date = strtotime($params) ;
	$dateStartTime = $date ? $date : strtotime(date('Y-m-d',strtotime('-1day')));//默认跑前一天的数据
	$dateEndTime = $dateStartTime+86399;
	$sqlClear = " DELETE FROM t_stat_use_gold_with_pay WHERE `mtime` between {$dateStartTime} and {$dateEndTime} ";
	$whereMtime .= " AND `mtime` BETWEEN {$dateStartTime} AND {$dateEndTime}  ";
}
GQuery($sqlClear); //清掉旧数据

//=========处理新数据=======
$spendType = array_keys(LogGoldClass::getSpendTypeList());
$strSpendIds = implode(',',$spendType);

$sqlCntRow = " SELECT COUNT(*) cnt FROM t_log_use_gold WHERE mtype IN ({$strSpendIds}) {$whereMtime} ";
$rsCntRow = GFetchRowOne($sqlCntRow);
$totalCnt = intval($rsCntRow['cnt']);
$InserCnt = 200; //每次最多处理300条数据。
$totalPage = ceil($totalCnt/$InserCnt);
//echo "totalCnt={$totalCnt}\n sqlCntRow={$sqlCntRow}";

$sqlSelect = " SELECT * FROM t_log_use_gold WHERE mtype IN ({$strSpendIds}) {$whereMtime} ";
for($page=1; $page<=$totalPage; $page++){
	$offset = ($page-1) * $InserCnt;
	$sqlPage = $sqlSelect." limit {$offset} , {$InserCnt} ";
	$rs = GFetchRowSet($sqlPage); 
	$sqlInsert = " INSERT INTO `t_stat_use_gold_with_pay` (`id`, `user_id`, `user_name`, `account_name`, `level`, `gold_bind`, `gold_unbind`, `mtime`, `mtype`, `itemid`, `amount`, `pay_money`) VALUES ";
	foreach ($rs as &$row) {
		$sqlPay = " SELECT SUM(`pay_money`) AS `pay_money` FROM db_pay_log_p WHERE `role_id`={$row['user_id']} AND `pay_time` < {$row['mtime']} ";
		$rsPay = GFetchRowOne($sqlPay);
		$pay_money = floatval($rsPay['pay_money']);
		$sqlInsert .= "({$row['id']}, {$row['user_id']}, '{$row['user_name']}', '{$row['account_name']}', {$row['level']}, {$row['gold_bind']}, {$row['gold_unbind']}, {$row['mtime']}, {$row['mtype']}, {$row['itemid']}, {$row['amount']}, {$pay_money}),";
	}
	$sqlInsert = trim($sqlInsert,',').';';
	GQuery($sqlInsert);
}

$endExecTime = time();
$totalExecTime  = $endExecTime - $startExecTime;
echo ', end at :'.date('Y-m-d H:i:s',$endExecTime).' total use time '.$totalExecTime." second ";
echo "成功\n";