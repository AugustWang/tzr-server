<?php
/*
 * Author: 许昭鹏, MSN: xzp@live.com
 * 2009-06-23
 * 
 * 功能：
 * 		在开服之前，生成激活码，
 * 		将激活码保存在 t_activate_code数据表中，
 * 		并同时保存到同目录下的文件  MING_AGENTER . ALL_SERVER . active_number
 * 
 * 注意：
 * 		本程序只能在服务器端运行，已经开服后，就不能再运行了。
 */
 
 
//**********************************************
//运行前，注意先修改GRANT_TYPE,GRANT_TIMES两个常量
//这个将在服务器上跑命令行进程，请在apache设置不可WEB访问。


error_reporting(E_ALL ^ E_NOTICE);
define('IN_ODINXU_SYSTEM', true);
require_once( "../../config/config.php" );
include SYSDIR_ADMIN."/include/global_for_shell.php";

define('CRLF', "\r\n");

global $db;

define('ACTIVE_NUM_LENGTH'     , 12);  //激活码的前缀长度 

///示例： /usr/bin/php ./makeActivateCode.php type=${PUBLISH_TYPE} times=${PUBLISH_TIMES} count=${MAKE_ACTIVE_NUM_COUNT}

$paramType = trim($argv[1]);
$paramTimes = trim($argv[2]);
$paramCount = trim($argv[3]);

echo "发放类型=". $paramType .",发放批次=" . $paramTimes . ",生成激活码个数=" . $paramCount . "\n\n";

if ($paramType && $paramTimes && $paramCount  ) {
	$publishType = intval($paramType);
	$publishTimes = intval($paramTimes);
	$activeNumCount = intval($paramCount);
}else{
	die('参数错误，运行示例：php ./makeActivateCodeAllServer.php type=1 times=1 count=10');
}


//产生激活码的加密KEY，每个代理商的每个服，都不同。
$KEY='bqxyunaAMc8uCXN4' . AGENT_NAME . 'C,3Dx,fd3';
$sql = "SELECT COUNT(1) as c FROM `t_activate_code`";
$row = GFetchRowOne($sql);
if (!isset($row['c']))
die('database error' . CRLF);


if( $paramType<1 ){
	die('发放类型不能小于1' . CRLF);
}else if( $publishTimes<1 ){
	die('发放批次不能小于1' . CRLF);
}

$publishID = '' . $publishType . $publishTimes;

//else if ($row['c'] != 0)
//die("database had active number. Can't make again." . CRLF);

$filename = AGENT_NAME . '_ALL_SERVER_activate_code_' . $publishType . '_' . $publishTimes . '_' . strftime("%Y%m%d") . '.txt';
$text = '';
$arr = array();
for($i=1;$i<=$activeNumCount;$i++)
{
	//每次重新生成，激活码都会不同。因为有time()
	$nn = substr(md5($KEY. $i. time() . $KEY),0, ACTIVE_NUM_LENGTH ) . $publishID;

	//产生绝对不会重复的激活码/////////////////////////////////////////////
	$ppp = 0;
	while( isset($arr[$nn]))
	{
		echo CRLF, $nn , ' rebuild. ';
		$ppp ++;
		$nn = substr(md5($KEY. $i. time() . $KEY . $ppp),0, ACTIVE_NUM_LENGTH );
	}
	$arr[$nn] = true;


	$text .= $nn . "\r\n";
	$mtime = time();

	$sqlInsert = "INSERT INTO `t_activate_code` (`code`, `publish_id`, `publish_time`) VALUES ('{$nn}','{$publishID}','{$mtime}')";
	GQuery($sqlInsert);

	echo $i , ' ';
}

echo CRLF, 'make ', $activeNumCount , ' active number succ.';

file_put_contents($filename, $text);

echo CRLF, 'save all active number to file: ', $filename , CRLF, CRLF;




