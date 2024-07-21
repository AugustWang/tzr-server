<?php
/**
 * 天之刃角色信息接口
 * @date 2010.11.26
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.ip.limit.info.php";
include_once "../config/config.php";
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";

global $db;
//使用Slave数据库
useSlaveDB();

if(AGENT_NAME == "360") {
	$account_name     = intval($_REQUEST['qid']); 
	$server_id    = $_REQUEST['server_id'];        		//游戏分区
	
}elseif(AGENT_NAME == "baidu") {
	$apiKey = SS($_REQUEST['api_key']);
	$account_name     = SS($_REQUEST['user_id']); 
	$timestamp   = SS($_REQUEST['timestamp']);   
	$serverID    = SS($_REQUEST['server_id']);        		//游戏分区
	$ticket      = SS($_REQUEST['sign']);	
	$_s = md5($API_SECURITY_TICKET_INFO."api_key".$apiKey."server_id".$serverID."timestamp".$timestamp."user_id".$account_name);
	if(strtolower($_s) !== strtolower($ticket)) {
		die('forbidden');
	}
}else {
	$account_name = SS($_REQUEST['user_name']);
	$sign = $_REQUEST['sign'];
	$_s = md5($account_name . $API_SECURITY_TICKET_INFO);

	if($_s !== $sign) {
		die('forbidden');
	}
}

$sql = "SELECT b.`role_name`,a.`level`,b.`family_name` FROM `db_role_base_p` as b, `db_role_attr_p` as a 
	WHERE b.`account_name`='$account_name' 
	AND b.`role_id`=a.`role_id` LIMIT 1";
$data = $db->fetchOne($sql);
$rolename = ($data['role_name']);
if(!$rolename) {
	if(AGENT_NAME == "360") {
		echo 0;
	}elseif(AGENT_NAME == "baidu") {
		echo "ERROR_-1406";
	}else {
		die('not found');
	}
}else {
	if(AGENT_NAME == "360") {
		echo 1;
	}elseif(AGENT_NAME == "baidu") {
		echo urlencode($data['role_name']);
	}else {
		echo $data['role_name'] . '|' . $data['level'] . '|' . $data['family_name'] . '|';
	}
}

