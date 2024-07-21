<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_INCLUDE."/global.php";

$beginTime = strtotime("2011-4-5 9:00:00");

$sql = "select count(1) as row from t_log_socket where 1";
$result = GFetchRowOne($sql);
$row = $result['row'];

$sql = "select count(1) as row from t_log_socket where isp = 1";
$result = GFetchRowOne($sql);
$dianxin = $result['row'];

$sql = "select count(1) as row from t_log_socket where isp = 2";
$result = GFetchRowOne($sql);
$jiaoyu = $result['row'];

$sql = "select count(1) as row from t_log_socket where isp = 3";
$result = GFetchRowOne($sql);
$liantong = $result['row'];

$sql = "select count(1) as row from t_log_socket where reason = 1";
$result = GFetchRowOne($sql);
$countOfSecurity = $result['row'];

$sql = "select count(1) as row from t_log_socket where reason = 2";
$result = GFetchRowOne($sql);
$countOfIO = $result['row'];

$sql = "select count(1) as row from t_log_login where log_time >= {$beginTime}";
$result = GFetchRowOne($sql);
$countOfLogin = $result['row'];

$sql = "select count(1) as row from t_log_socket_failed";
$result = GFetchRowOne($sql);
$countOfFailed = $result['row'];

$text = "从2011-4-5 9：00 开始，统计数据如下：<br>" 
			. "登录失败总次数:{$row} <br>"
			. "电信失败次数:{$dianxin}" . ", 比例:". ($dianxin/$row) . "<br>"
			. "教育网失败次数:{$jiaoyu}" . ", 比例:". ($jiaoyu/$row) . "<br>"
			. "联通失败次数:{$liantong}" . ", 比例:". ($liantong/$row) . "<br>"
			. "IoError登录失败次数：{$countOfIO} <br>"
			. "Security登录次数：{$countOfSecurity} <br>"
			. "期间成功登录次数: {$countOfLogin}<br>"
			. "登录失败比例：" . ($countOfFailed / ($countOfFailed + $row))
			. "登录重试比例:". ($row / (2 *($row + $countOfLogin / 2)));
			
echo $text;