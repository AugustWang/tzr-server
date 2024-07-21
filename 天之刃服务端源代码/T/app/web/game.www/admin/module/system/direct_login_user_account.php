<?php
/*
 * Author: wuzesen
 *	
 * 管理员通过游戏后台，直接登录进入指定玩家的帐号
 * 
 * 注意，请勿滥用本功能。
 */

$_DCACHE = null;
define('DIRECT_LOGIN_PHP', "../../../user/game.php");
define('DIRECT_START_PHP', "../../../user/start.php");
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once "../../../config/config.key.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

$action = SS($_REQUEST['action']);

// 直接登录玩家帐号
if ($action == 'login') 
{
	$account = SS($_REQUEST['account']);
	$role_name = SS($_REQUEST['role_name']);
	
	if (!$account  && !$role_name){
		die('帐号不能为空');
	}else {
		$role = UserClass::getUser($role_name,$account,NULL);
	}
	if (!$role['role_id'])
		die ('该帐号不存在');


	$log = new AdminLogClass();
	$log->Log( AdminLogClass::TYPE_DIRECT_LOGIN_USER, '登录帐号: ' . $row['account_name'], 0, '', $row['role_id'], $row['role_name']);
	
	if($role['account_name']) {
		$account = $role['account_name'];
		$time = time();
		$agentid = AGENT_ID;
		$serverid = SERVER_ID;
		$fcmTicket = 0;
		$datakey = $API_SECURITY_TICKEY_LOGIN.$account.$time.$agentid.$serverid.$fcmTicket;
		$ticket = md5($datakey);
		
		$_SESSION['account_name'] = $account;
		$_SESSION['timestamp'] = $time;
		$_SESSION['agent_id'] = $agentid;
		$_SESSION['server_id'] = $serverid;
		$_SESSION['ticket'] = $ticket;
		$_SESSION['fcm'] = $fcmTicket;
		$_SESSION['host'] = '';
		$_SESSION['cvs'] = '';
		//用这个session选项来绕过game.php关闭了入口的问题
		$_SESSION['from_admin'] = true;
		if(($_POST['conn_host']) && ($_POST['cvs'])) {
			$_SESSION['host'] = trim($_POST['conn_host']);
			$_SESSION['cvs'] = $_POST['cvs'];
		}
		header("location:" . DIRECT_LOGIN_PHP);
		exit;
	}
	
}
 

// 模拟平台登录帐号
if ($action == 'start') 
{
	$account = SS($_REQUEST['account']);
	if (empty($account))
		die('帐号不能为空');
	
	if(AGENT_NAME == "360") {			//360代理特殊处理
		$account = '360' . trim($account);
	}else {
		$account = 'acname' . trim($account);
	}

	$log = new AdminLogClass();
	$log->Log( AdminLogClass::TYPE_DIRECT_LOGIN_PLATFORM , '模拟登录帐号: ' . $account, 0, '', 0, $account);
		
	if(!empty($_POST)) {
		//必须unset掉，否则会出现一些无角色的账号直接跳转到game.php，上一个账号引起
		unset($_SESSION['role_id']);
		if(AGENT_NAME == "360") {			//360代理特殊处理
			if(isset($_POST['account']) && trim($_POST['account']) != '') {
				$time = time();
				$serverID2 = SERVER_NAME;
				$fcmTicket = 0;
				$ticket = md5("qid=".$account."&time=".$time."&server_id=".SERVER_NAME.$API_SECURITY_TICKEY_LOGIN);
				
				$_SESSION['account_name'] = $account;
				$_SESSION['account_type'] = 2;
				$_SESSION['timestamp'] = $time;
				$_SESSION['agent_id'] = AGENT_ID;
				$_SESSION['server_id'] = SERVER_ID;
				$_SESSION['ticket'] = $ticket;
				$_SESSION['fcm'] = $fcmTicket;
				$_SESSION['host'] = '';
				$_SESSION['cvs'] = '';
				//用这个session选项来绕过game.php关闭了入口的问题
				$_SESSION['from_admin'] = true;
				if(($_POST['conn_host']) && ($_POST['cvs'])) {
					$_SESSION['host'] = trim($_POST['conn_host']);
					$_SESSION['cvs'] = $_POST['cvs'];
				}
				
				$url = "location:". DIRECT_START_PHP ."?qid={$account}&time={$time}&server_id={$serverID2}&sign={$ticket}&isAdult={$fcmTicket}";
//				echo $url;
//				die();
				header($url);
			}
		}elseif(AGENT_NAME == "baidu") {			//百度代理特殊处理
			if(isset($_POST['account']) && trim($_POST['account']) != '') {
				$time =date('Y-m-d h:i:s',time());
				$serverID = SERVER_NAME;
				$fcmTicket = 1;
				$apiKey="8ac1904330d59aeb0130da513ee30438";
				$fcm='y';
				$ticket = md5($API_SECURITY_TICKEY_LOGIN."api_key".$apiKey."cm_flag".$fcm."server_id".$serverID."timestamp".$time."user_id".$account);
				
				$_SESSION['account_name'] = $account;
				$_SESSION['account_type'] = 2;
				$_SESSION['timestamp'] = time();
				$_SESSION['agent_id'] = AGENT_ID;
				$_SESSION['server_id'] = SERVER_ID;
				$_SESSION['ticket'] = $ticket;
				$_SESSION['fcm'] = $fcmTicket;
				$_SESSION['host'] = '';
				$_SESSION['cvs'] = '';
				//用这个session选项来绕过game.php关闭了入口的问题
				$_SESSION['from_admin'] = true;
				if(($_POST['conn_host']) && ($_POST['cvs'])) {
					$_SESSION['host'] = trim($_POST['conn_host']);
					$_SESSION['cvs'] = $_POST['cvs'];
				}
				
				$url = "location:". DIRECT_START_PHP ."?user_id={$account}&server_id={$serverID}&timestamp={$time}&sign={$ticket}&cm_flag=y&api_key={$apiKey}";
				//echo $url;
				//die();
				header($url);
			}
		}elseif(AGENT_NAME == "4399"){//4399
			if(isset($_POST['account']) && trim($_POST['account']) != '') {
				$time = time();
				$agentid = AGENT_ID;
				$serverid = SERVER_ID;
				$servername = SERVER_NAME;
				$fcmTicket = 0;
				$ticket = md5($account.$servername.$time.$API_SECURITY_TICKEY_LOGIN.$fcmTicket);
				$_SESSION['account_name'] = $account;
				$_SESSION['account_type'] = 2;
				$_SESSION['timestamp'] = $time;
				$_SESSION['agent_id'] = $agentid;
				$_SESSION['server_id'] = $serverid;
				$_SESSION['ticket'] = $ticket;
				$_SESSION['fcm'] = $fcmTicket;
				$_SESSION['host'] = '';
				$_SESSION['cvs'] = '';
				//用这个session选项来绕过game.php关闭了入口的问题
				$_SESSION['from_admin'] = true;
				if(($_POST['conn_host']) && ($_POST['cvs'])) {
					$_SESSION['host'] = trim($_POST['conn_host']);
					$_SESSION['cvs'] = $_POST['cvs'];
				}
				$url = "location:". DIRECT_START_PHP ."?username={$account}&time={$time}&flag={$ticket}&cm={$fcmTicket}&servername={$servername}";
				header($url);
			}
		}else{//等普通代理
			if(isset($_POST['account']) && trim($_POST['account']) != '') {
				//$account = trim($_POST['account']);
				$time = time();
				$agentid = AGENT_ID;
				$serverid = SERVER_ID;
				$fcmTicket = 0;
				$datakey = $API_SECURITY_TICKEY_LOGIN.$account.$time.$agentid.$serverid.$fcmTicket;
				$ticket = md5($datakey);
				
				$_SESSION['account_name'] = $account;
				$_SESSION['account_type'] = 2;
				$_SESSION['timestamp'] = $time;
				$_SESSION['agent_id'] = $agentid;
				$_SESSION['server_id'] = $serverid;
				$_SESSION['ticket'] = $ticket;
				$_SESSION['fcm'] = $fcmTicket;
				$_SESSION['host'] = '';
				$_SESSION['cvs'] = '';
				//用这个session选项来绕过game.php关闭了入口的问题
				$_SESSION['from_admin'] = true;
				if(($_POST['conn_host']) && ($_POST['cvs'])) {
					$_SESSION['host'] = trim($_POST['conn_host']);
					$_SESSION['cvs'] = $_POST['cvs'];
				}
				
				header("location:". DIRECT_START_PHP ."?account=$account&tstamp={$time}&agentid={$agentid}&serverid={$serverid}&fcm={$fcmTicket}&ticket={$ticket}");
			}
		}
	}
	
}

$smarty->display("module/system/direct_login_user_account.tpl");
