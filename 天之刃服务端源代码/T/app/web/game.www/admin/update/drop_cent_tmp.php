<?php
define('IN_ODINXU_SYSTEM', true);
include_once '../../config/config.php';

$passwd = $dbConfig_game['passwd'];
$host =$dbConfig_game['host'];
$user = $dbConfig_game['user'];
$con = mysql_connect($host,$user,$passwd);

if (!$con)
{
die('Could not connect: ' . mysql_error());
}
mysql_select_db("ming2_logs", $con);

$drop_log_sql="DROP TABLE ming2_logs.t_log_pay_tmp";
$drop_gold_sql="DROP TABLE ming2_logs.t_log_gold_tmp";
//$drop_online_sql="DROP TABLE ming2_logs.t_log_online_tmp";
mysql_query($drop_log_sql);
mysql_query($drop_gold_sql);
//mysql_query($drop_online_sql);
mysql_close($con);
?>