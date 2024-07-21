<?php
/* markycai
 * 游客专用..
 * 
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once "../config/config.key.php";
include_once SYSDIR_INCLUDE."/global.php";

include_once SYSDIR_INCLUDE."/mgc.php";
include_once SYSDIR_INCLUDE.'/name_data.php';

if(GUEST==true) {
	//必须unset掉，否则会出现一些无角色的账号直接跳转到game.php，上一个账号引起
	unset($_SESSION['role_id']);
	if(AGENT_NAME == "360") {			//360代理特殊处理
		$time = time();
		$account = 	randomGuestAccount($time);
		if($account!="error")
		{
			$result=createUser($account);
			if (is_int($result) && $result > 0)
			{
				$time = time();
				$serverID2 = AGENT_ID;
				$fcmTicket = 0;
				$ticket = md5("qid=".$account."&time=".$time."&server_id=".$serverID2.$API_SECURITY_TICKEY_LOGIN);
				setSession($account,$time,AGENT_ID,$serverID,$ticket,$fcmTicket);
				$url = "location:start.php?qid={$account}&time={$time}&server_id={$serverID2}&sign={$ticket}&isAdult={$fcmTicket}";
				//				echo $url;
				//				die();
				header($url);
			}
		}
	}elseif(AGENT_NAME == "baidu") {			//百度代理特殊处理
		$time = time();
		$account = 	randomGuestAccount($time);
		if($account!="error")
		{
			$result=createUser($account);
			if (is_int($result) && $result > 0)
			{
				$time =date('Y-m-d h:i:s',time());
				$serverID = SERVER_ID;
				$fcmTicket = 1;
				$apiKey="8ac1904330d59aeb0130da513ee30438";
				$fcm='y';
				$ticket = md5($API_SECURITY_TICKEY_LOGIN."api_key".$apiKey."cm_flag".$fcm."server_id".$serverID."timestamp".$time."user_id".$account);
				setSession($account,$time,AGENT_ID,$serverID,$ticket,$fcmTicket);
				$url = "location:start.php?user_id={$account}&server_id={$serverID}&timestamp={$time}&sign={$ticket}&cm_flag=y&api_key={$apiKey}";
				//echo $url;
				//die();
				header($url);
			}
		}
	}elseif(AGENT_NAME == "4399"){								//4399等普通代理
		$action = SS($_GET['action']);
		$account = urldecode($_GET['account']);
		if($action=="login" && !empty($account)){
			$hasRole = chk_account_role($account);
			if(!$hasRole){
				$agentid = AGENT_ID;
				$serverid = SERVER_ID;
				$servername = SERVER_NAME;
				$fcmTicket = 0;
				$time = time();
				$ticket = md5($account.$servername.$time.$API_SECURITY_TICKEY_LOGIN.$fcmTicket);
				setSession($account,$time,$agentid,$serverid,$ticket,$fcmTicket);
				header("location:start.php?username={$account}&time={$time}&servername={$servername}&cm={$fcmTicket}&flag={$ticket}");
				exit();
			}else{
				header ( "location:" . getToGameURL () );
				exit();
			}
		}else{
			//$account = trim($_POST['account']);
			$time = time();
			$account = 	randomGuestAccount($time);
			if($account!="error")
			{
				$result=createUser($account);
				if (is_int($result) && $result > 0)
				{
					// 游客的方式进入
					logGuestInfo($account,$result,$time);
					$agentid = AGENT_ID;
					$serverid = SERVER_ID;
					$servername =SERVER_NAME;
					$fcmTicket = 0;
					$ticket = md5($account.$servername.$time.$API_SECURITY_TICKEY_LOGIN.$fcmTicket);
					setSession($account,$time,$agentid,$serverid,$ticket,$fcmTicket);
					header("location:start.php?username={$account}&time={$time}&servername={$servername}&cm={$fcmTicket}&flag={$ticket}");
					exit();
				}
				header ( "location:" . getToGameURL () );
				exit();
			}
			header ( "location:" . getToGameURL () );
			exit();
		}
	}else{								//普通代理
		$action = SS($_GET['action']);
		$account = urldecode($_GET['account']);
		if($action=="login" && !empty($account)){
			$hasRole = chk_account_role($account);
			if(!$hasRole){
				$agentid = AGENT_ID;
				$serverid = SERVER_ID;
				$fcmTicket = 0;
				$time = time();
				$datakey = $API_SECURITY_TICKEY_LOGIN.$account.$time.$agentid.$serverid.$fcmTicket;
				$ticket = md5($datakey);
				setSession($account,$time,$agentid,$serverid,$ticket,$fcmTicket);
				header("location:start.php?account=$account&tstamp={$time}&agentid={$agentid}&serverid={$serverid}&fcm={$fcmTicket}&ticket={$ticket}");
				exit();
			}else{
				header ( "location:" . getToGameURL () );
				exit();
			}
		}else{
			//$account = trim($_POST['account']);
			$time = time();
			$account = 	randomGuestAccount($time);
			if($account!="error")
			{
				$result=createUser($account);
				if (is_int($result) && $result > 0)
				{
					logGuestInfo($account,$result,$time);
					$agentid = AGENT_ID;
					$serverid = SERVER_ID;
					$fcmTicket = 0;
					$datakey = $API_SECURITY_TICKEY_LOGIN.$account.$time.$agentid.$serverid.$fcmTicket;
					$ticket = md5($datakey);
					setSession($account,$time,$agentid,$serverid,$ticket,$fcmTicket);
					header("location:start.php?account=$account&tstamp={$time}&agentid={$agentid}&serverid={$serverid}&fcm={$fcmTicket}&ticket={$ticket}");
					exit();
				}
				header ( "location:" . getToGameURL () );
				exit();
			}
			header ( "location:" . getToGameURL () );
			exit();
		}
	}
}else{
	header ( "location:" . getToGameURL () );
}


function logGuestInfo($account,$role_id,$time){
	$sql = "INSERT INTO `t_guest_info` (`account`,`role_id`,`log_time`) values('{$account}','{$role_id}','{$time}')";
	GQuery($sql);
}

function setSession($account,$time,$agentid,$serverid,$ticket,$fcmTicket){
	$_SESSION['account_name'] = $account;
	$_SESSION['timestamp'] = $time;
	$_SESSION['agent_id'] = $agentid;
	$_SESSION['server_id'] = $serverid;
	$_SESSION['ticket'] = $ticket;
	$_SESSION['fcm'] = $fcmTicket;
	$_SESSION['host'] = '';
	$_SESSION['cvs'] = '';
	if(($_POST['conn_host']) && ($_POST['cvs'])) {
		$_SESSION['host'] = trim($_POST['conn_host']);
		$_SESSION['cvs'] = $_POST['cvs'];
	}
}


function randomGuestAccount($time){
	$rand_time = 0;
	$hasRole = true;
	$account="error";
	while($rand_time<10 && $hasRole==true){
		$account="guest_".$time.rand(0,1000);
		$hasRole = chk_account_role($account);
	}
	if(!$hasRole){
		return $account;
	}else{
		return "error";
	}
}

function createUser($account){
        $sex = rand(1,2);
        $username = gene_unique_name( $sex );
        $factionID = rand(1,3);
        $head = 13;
        $hairType = 1;
        $hairColor = 000000;
        $category = rand(1,4);
        $accountType = 3;
        $result = getWebJson("/account/create_role/?ac={$account}&uname={$username}&sex={$sex}"
                ."&fid={$factionID}&head={$head}&hair_type={$hairType}"
                . "&hair_color={$hairColor}&category={$category}&account_type={$accountType}");
        if($result['result']=='ok'){
                logAfterCreateRole($account,$username,$factionID);
                return $result['role_id'];
        }
        return $result['result'];
}



function logAfterCreateRole($accountName,$roleName,$factionId){
	$accountName = SS($accountName);
	$checkSql = "select 1 from t_role_create_after where account_name = '$accountName' ";
	$result = GFetchRowSet($checkSql);
	if (count($result)>0){
		//已经创建过了,不需再创建
		return null;
	}
	
	$factionId = SS($factionId);
	$roleName = SS($roleName);
	$mtime = time();
	$ary = array(
		'account_name'=>$accountName,
		'role_name'=>$roleName,
		'faction_id'=>$factionId,
		'mtime'=>$mtime,
		'year'=>date('Y',$mtime),
		'month'=>date('m',$mtime),
		'day'=>date('d',$mtime)
	);
	$sql = makeInsertSqlFromArray($ary, 't_role_create_after');
	GQuery($sql);
}