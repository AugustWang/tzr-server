<?php
ob_start();
session_start();
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once "../config/config.key.php";
include_once SYSDIR_INCLUDE."/global.php";

global $smarty, $cache;
if(AGENT_NAME == "360") { 	//360代理
	
	$accountName     = SS($_GET['qid']);       			//360用户ID
	$timestamp   = intval($_GET['time']);      
	$serverID    = SS($_GET['server_id']);        		//游戏分区
	$ticket      = SS($_GET['sign']);							//签名
	$fcmFlag = intval($_GET['isAdult']);
	$agentID = AGENT_ID;
	$serverID2 = strtoupper($serverID);
	$ticketValid = md5("qid=".$accountName."&time=".$timestamp."&server_id=".$serverID2.$API_SECURITY_TICKEY_LOGIN);
	
}elseif (AGENT_NAME == "baidu") {
	$apiKey = SS($_REQUEST['api_key']);
	$accountName     = SS($_REQUEST['user_id']); 
	$timestamp   = SS($_REQUEST['timestamp']);   
	$serverID    = SS($_REQUEST['server_id']);        		//游戏分区
	$ticket      = SS($_REQUEST['sign']);	
	$fcmFlag = SS($_REQUEST['cm_flag']);
	
	$ticketValid = md5($API_SECURITY_TICKEY_LOGIN."api_key".$apiKey."cm_flag".$fcmFlag."server_id".$serverID."timestamp".$timestamp."user_id".$accountName);
	
	if($fcmFlag == 'y' || $fcmFlag == 'Y') {
		$fcmFlag = 1;
	}else {
		$fcmFlag = 0;
	}
	$timestamp  = strtotime($timestamp); 
}elseif (AGENT_NAME == "4399"){ //4399 平台登录接口
	$accountName = urldecode($_GET['username']);
	$timestamp = intval($_GET['time']);
	$ticket = trim($_GET['flag']);
	$fcmFlag = intval($_GET['cm']);
	$serverName = strtoupper(SS($_GET['servername']));
	$agentID = AGENT_ID;
	$serverID = SERVER_ID;
	$ticketValid = md5($accountName.$serverName.$timestamp.$API_SECURITY_TICKEY_LOGIN.$fcmFlag);
}else {		//普通代理，如91玩等
	//检查URL是否合法
	$accountName = urldecode($_GET['account']);
	$timestamp = intval($_GET['tstamp']);
	$agentID = intval($_GET['agentid']);
	$serverID = intval($_GET['serverid']);
	$ticket = trim($_GET['ticket']);
	//是否通过防沉迷验证了
	$fcmFlag = intval($_GET['fcm']);
	$ticketValid = gene_login_ticket($accountName, $timestamp, $agentID, $serverID, $fcmFlag);
}

// 超时检查
if (abs(time() - $timestamp) > 300 ) {
	header ( "location:" . getToGameURL ( N ) );
	exit ();
}

checkPlatformState();
checkGameFromAdminState();

//玩家如果浏览器多开，则必须清理掉，否则新号会直接跳转到官网首页
unset($_SESSION['role_id']);
if (strtolower($ticket) == strtolower($ticketValid))
{
	$_SESSION['account_name'] = $accountName;
	$_SESSION['timestamp'] = $timestamp;
	$_SESSION['agent_id'] = $agentID;
	$_SESSION['server_id'] = $serverID;
	$_SESSION['ticket'] = $ticket;
	$_SESSION['fcm'] = $fcmFlag;
	
	// 这里应该记录IP地址，账号登录日志N
	logAccountLogin($accountName);
	//通过mochiweb通知erlang更新角色的防沉迷状态
	if ($fcmFlag == 1) {
		setAccountFCMPassed ( $accountName );
	}
	header('location:./main.php');
	exit();
} else {
	//echo $ticketValid;
	//die("ticket error");
	header('location:'.OFFICIAL_WEBSITE);
	exit('Access Denied.');
}



/**
 * 记录账号登录日志，加上IP地址，用于判断线路
 * @param string $accountName
 */
function logAccountLogin($accountName) {
	$accountName = SS($accountName);
	$sql = "select 1 from t_portal_account where account_name = '$accountName' limit 1";
	$result = GFetchRowSet($sql);
	if (count($result) >0 ){
		//已经创建过了,不需再创建
		return null;
	}

	$ip = get_real_ip();
	$mtime = time();
	$account_instance = array(
	'account_name'=>$accountName,
	'mtime'=> $mtime,
	'year'=> date('Y',$mtime),
	'month'=>date('m',$mtime),
	'day'=>date('d',$mtime),
	'ip'=>$ip,
	'router_line'=>get_user_isp($ip),
	'account_status'=> 0
	);
	
	$sqlStr = makeInsertSqlFromArray($account_instance, 't_portal_account');
	GQuery($sqlStr);
}

