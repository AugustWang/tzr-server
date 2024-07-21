<?php
/**
 * @author wuzesne
 * @desc 每天跑一次，删除一些老的日志数据
 */
 
error_reporting(E_ALL ^ E_NOTICE);
define('IN_ODINXU_SYSTEM', true);
require_once( "../../config/config.php" );
include SYSDIR_ADMIN."/include/global_for_shell.php";

$startExecTime = time();
echo basename(__FILE__) ."  start at :".date('Y-m-d H:i:s',$startExecTime);


$fiveDaysAgo = strtotime("-5day");

$sqlDelete1="delete from t_family_depot_put_logs where log_time<${fiveDaysAgo};";
$sqlDelete2="delete from t_family_depot_get_logs where log_time<${fiveDaysAgo};";

GQuery($sqlDelete1);
GQuery($sqlDelete2);
echo " 成功 ";

$endExecTime = time();
$totalExecTime = $endExecTime-$startExecTime;
echo 'end at :'.date('Y-m-d H:i:s',$endExecTime).' total use time '.$totalExecTime." second \n";
?>