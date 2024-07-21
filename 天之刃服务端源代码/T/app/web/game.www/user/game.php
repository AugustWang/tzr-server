<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_ROOT."/config/config.key.php";
include_once SYSDIR_INCLUDE."/global.php";
include_once "user_auth.php";

@include_once(SYSDIR_ROOT.'cache/data/base_limit_account.php'); //被封禁
@include_once(SYSDIR_ROOT.'cache/data/base_limit_ip.php');

// 全局变量声明，用于消除PHP警告
global $smarty;
include_once SYSDIR_INCLUDE."/mgc.php";
include_once SYSDIR_INCLUDE.'/name_data.php';

//检查排队
$online = getOnline();
if ($online >= MAX_ONLINE) {
        //人满为患了
        $_SESSION['queue_num'] = getQueue();
        $_SESSION['full'] = true;
        header('location:/user/full.php');
        exit();
} else if($online >= QUEUE_NUM) {
        if (!isset($_SESSION['queue_time'])) {
                $_SESSION['queue_time'] = time();
        }
        $lastQueueTime = $_SESSION['queue_time'];
        //大于10秒就可以等待了
        if (time() - $lastQueueTime >= 10) {
                //清理掉排队信息
                unset($_SESSION['queue_time']);
                unset($_SESSION['full']);
                decreaseQueue();
        } else {
                //需要排队
                increaseQueue();
                $_SESSION['full'] = false;
                $_SESSION['queue_num'] = getQueue();
                $_SESSION['queue_time'] = time();
                header('location:/user/full.php');
                exit();
        }
}

checkPlatformState();
checkGameFromAdminState();

$hasRole = chk_account_role($_SESSION['account_name']);

if (!$hasRole) {
        //随机生成男女名字各一个
        $manName = gene_unique_name ( 1 );
        $womenName = gene_unique_name ( 2 );
        $smarty->assign ( 'manName', $manName );
        $smarty->assign ( 'womenName', $womenName );
        // 用于给客户端拼凑 ping.php 和 reconnect.php的url
        $smarty->assign ( 'gameRoot', WEB_SITEURL . "user/" );
        $smarty->assign ( 'sessionID', session_id () );
        $smarty->assign ( 'faction', get_default_faction () );
        $smarty->assign('OFFICIAL_WEBSITE', OFFICIAL_WEBSITE);
}


//检查是否被封禁
if ($_SESSION['from_admin'] || checkCanPass($_SESSION['account_name'])) {
} else {
        $smarty->assign('msg',"对不起，你的帐号目前禁止登陆游戏，如有疑问，请联系GM。");
        $smarty->display('error.html');
        exit ();
}

$toGameUrl = getToGameURL();
$smarty->assign('toGameUrl', $toGameUrl);

$accountName = $_SESSION['account_name'];
$tstamp = $_SESSION['timestamp'];
$agentID = $_SESSION['agent_id'];
$serverID = $_SESSION['server_id'];
$ticket = $_SESSION['ticket'];
$fcm = !$_SESSION['fcm'] ? 0 : $_SESSION['fcm'];


// 测试用，可以选择任意的客户端版本号
if ($_SESSION['test_cvs'] > 0 ) {
        $clientVersion = $_SESSION['test_cvs'];
} else {
        $clientVersion = getClientVersion();
}


$hasRole = chk_account_role($_SESSION['account_name']);

if (!$hasRole) {
        //随机生成男女名字各一个
        $manName = gene_unique_name ( 1 );
        $womenName = gene_unique_name ( 2 );
        $smarty->assign ( 'manName', $manName );
        $smarty->assign ( 'womenName', $womenName );
        // 用于给客户端拼凑 ping.php 和 reconnect.php的url
        $smarty->assign ( 'gameRoot', WEB_SITEURL . "user/" );
        $smarty->assign ( 'sessionID', session_id () );
        $smarty->assign ( 'faction', get_default_faction () );
        $smarty->assign('OFFICIAL_WEBSITE', OFFICIAL_WEBSITE);
}


$serverVersion = getServerVersion();
$clientRootURL = WEB_STATIC.$clientVersion;

$ip = get_real_ip();
$arr = GetIPaddr($ip);
$true_arr = iconv("gb2312","utf-8",$arr);

getPayUrl($_SESSION['account_name'],$true_arr);

if ($hasRole) {
        $allInfo = getAllInfoFromMochiweb($_SESSION['account_name'], $_SESSION['role_id']);
        $smarty->assign ('level', $allInfo ['level'] );
        $smarty->assign ('map_id', $allInfo ['map_id'] );
        //弹出收藏夹处理
        if ($allInfo ['level'] < 3) {
                $favStr = true;
        } else {
                $favStr = false;
        }
		global $cache;
		// 获取玩家的全屏设置
		$fullScreenFlag = $cache->fetch(CACHE_KEY_USER_FULLSCREEN_FLAG.$_SESSION['role_id']);
		if ($fullScreenFlag == null) {
			$sql = "SELECT full_screen_flag FROM `t_user_interface` WHERE role_id='{$_SESSION['role_id']}'";
			$result = GFetchRowOne($sql);
			if ($result) {
				$fullScreenFlag = intval($result['full_screen_flag']);
				$cache->store(CACHE_KEY_USER_FULLSCREEN_FLAG.$_SESSION['role_id'], $fullScreenFlag);
			}
		}
		$fullScreenFlag = intval($fullScreenFlag);
		if ($fullScreenFlag === 1) {
			$smarty->assign('defaultWidth', '100%');
			$smarty->assign('defaultHeight', '100%');
		} else if ($fullScreenFlag === 0) {
			if ($allInfo ['level'] < 11) {
				$smarty->assign ( 'defaultWidth', '1002' );
				$smarty->assign ( 'defaultHeight', '580' );
			} else {
				if (FULL_SCREEN) {
					$smarty->assign ( 'defaultWidth', '100%' );
					$smarty->assign ( 'defaultHeight', '100%' );
				} else {
					$smarty->assign ( 'defaultWidth', '1002' );
					$smarty->assign ( 'defaultHeight', '580' );
				}
			}
		} else {
			if ($allInfo ['level'] < 11) {
				$smarty->assign ( 'defaultWidth', '1002' );
				$smarty->assign ( 'defaultHeight', '580' );
			} else {
				if (FULL_SCREEN) {
					$smarty->assign ( 'defaultWidth', '100%' );
					$smarty->assign ( 'defaultHeight', '100%' );
				} else {
					$smarty->assign ( 'defaultWidth', '1002' );
					$smarty->assign ( 'defaultHeight', '580' );
				}
			}
		}
        $smarty->assign('role_id', $_SESSION['role_id']);
        $smarty->assign('map_id', $allInfo['map_id']);
        $smarty->assign('gatewayStr', $allInfo['lines']);
} else {
	if (FULL_SCREEN) {
		$smarty->assign('defaultWidth', '100%');
		$smarty->assign('defaultHeight', '100%');
	} else {
		$smarty->assign('defaultWidth', '1002');
		$smarty->assign('defaultHeight', '580');
	}
}
$account_type = $_SESSION['account_type'];
if(empty($account_type)){
	$account_type = 0;
}
$isDebug ='false';
if(isDebugMode()==1)
	$isDebug='true';

initStatAccountInfo($accountName);
// 充值链接必须形如
// http://web.4399.com/user/select_pay_type.php?gamename=GAME_NAME|gameserver=SERVER_NAME|username=ACCNAME
$smarty->assign('activateCodeUrl', ACTIVATE_CODE_URL);
if (AGENT_NAME == 'baidu') {
	$smarty->assign ('domain', TO_GAME_URL );
} else {
	$smarty->assign ( 'domain', WEB_SITEURL . "user/game.php" );
}
$smarty->assign('qqQun1', qqQun1);
$smarty->assign('qqQun2', qqQun2);
$smarty->assign('qqQun3', qqQun3);

$smarty->assign('bbsUrl', BBS_URL);
$smarty->assign('GMOnline', GMOnline);
$smarty->assign('account', $accountName);
$smarty->assign('account_type', $account_type);
$smarty->assign('title', WEB_TITLE);
$smarty->assign('selectPageURL', SERVER_LIST_URL);
$smarty->assign('pkTip', PK_TIP);

$smarty->assign('sessionID',  session_id());
// 用于给客户端拼凑 ping.php 和 reconnect.php的url
$httpHost = "http://".$_SERVER['HTTP_HOST']."/user/";
$smarty->assign ( 'gameRoot', $httpHost );
$smarty->assign('if_fav', $favStr);
$smarty->assign('serverVersion', $serverVersion);
$smarty->assign('clientVersion', $clientVersion);
$smarty->assign('web_auth_url', WEB_AUTH_URL);
$smarty->assign('jihoumaURL', JIHUOMA_URL);
$smarty->assign('firstPayUrl', FIRST_PAY_URL);
$smarty->assign('firstPayTitle', FIRST_PAY_TITLE);
//客户端地址
$smarty->assign('clientRootUrl', $clientRootURL);
$smarty->assign('fcmApiUrl', FCM_API_URL);
// 登录、聊天和端口转发都设置在A机上
$smarty->assign('officialWebSite', OFFICIAL_WEBSITE);
$smarty->assign('agentName', AGENT_NAME);
$smarty->assign('bgpHost', BGP_HOST);
$smarty->assign('bgpPort', BGP_PORT);
$smarty->assign('directlyUseBgp', DIRECTLY_USE_BGP);
$smarty->assign('showException', SHOW_EXCEPTION);
$smarty->assign('isDebug',$isDebug);
$smarty->display("game.html");

/**
 * 没有被禁止返回true,被禁止返回false 
 * @param $roleName
 */
function checkCanPass($accountName){
        global $_DCACHE;
        if ($_DCACHE == null) {
        	rewriteCacheFile();
        	@include_once (SYSDIR_ROOT . 'cache/data/base_limit_account.php'); //被封禁
        	@include_once (SYSDIR_ROOT . 'cache/data/base_limit_ip.php');
		}
        if($_DCACHE['limit_account'][$accountName]){
                //99999 表示无限期封禁
                if (time() <= $_DCACHE['limit_account'][$accountName]['end_time'] || 99999 == $_DCACHE['limit_account'][$accountName]['end_time']) {
                        return false;
                }
        }
        $client_ip = GetIP();
        if($_DCACHE['limit_ip'][$client_ip] && time() <= $_DCACHE['limit_ip'][$client_ip]['end_time']){
                return false;
        }
        return true;
}

//用于初始化流失率分析的数据
function initStatAccountInfo($accountName){
        $count = GFetchRowOne("select count(*) as cnt from t_account where account = '$accountName'");
        $count = $count['cnt'];
        $timestamp = time();
        $year =date('Y',$timestamp);
        $month = date("m",$timestamp);
        $day = date('d',$timestamp);
        $hour = date('h',$timestamp);
        $ip = $_SERVER['REMOTE_ADDR'];
        if ($count ==  0) {
                //insert a new record
                $sql  = "INSERT INTO `t_account` (
                `account`, `role_name`, `account_create_dateline`, `account_create_y`, `account_create_m`, `account_create_d`,
                 `account_create_h`, `role_create_dateline`, `role_create_y`, `role_create_m`, `role_create_d`, `role_create_h`, `account_last_dateline`, `account_last_y`, 
                 `account_last_m`, `account_last_d`, `account_last_h`, `role_last_dateline`, `role_last_y`, `role_last_m`, `role_last_d`, `role_last_h`, `account_login_times`,
                  `role_login_times`, `last_ip`, `status`) VALUES (
                 '$accountName', NULL, '$timestamp', '$year', '$month', '$day', '$hour', NULL, NULL, NULL, NULL, NULL, '$timestamp', '$year', '$month', '$day', '$hour',
                  NULL, NULL, NULL, NULL, NULL, '1', NULL, '$ip', '0')";
                GQuery($sql);     
        }else {
                //update 
                $sql = "UPDATE t_account set account_last_dateline  = '$timestamp',account_last_y = '$year',account_last_m =  '$month', account_last_d = '$day', account_last_h = '$hour', 
                        account_login_times = account_login_times+1 ,last_ip = '$ip' where account = '$accountName'";
                GQuery($sql);
        }

}

