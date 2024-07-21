<?php
session_start();
define('IN_ODINXU_SYSTEM', true);
include('../config/config.php');
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";
include_once SYSDIR_CLASS.'/cache.class.php';

global $smarty, $cache;

$versionDirs = dirtree("/data/tzr/web/static/");
rsort($versionDirs);

if(isPost()) {
	$action = trim($_REQUEST['action']);
	// 客户端自助更新
	if ($action == 'client_svn') {
		$version = intval(trim($_POST['svn_version']));
		if ($version < 1) {
			errorExit("版本号必须大于1");
		}
		//暂时不做其他检查了
		//文件锁，防止多次重复提交
		$lockFileName = "/tmp/lock.svn.client.$version.lock";
		if (file_exists($lockFileName)) {
			errorExit("正在处理客户端 {$version} 版本的更新，请不要重复提交");
		}
		if (($fp=fopen($lockFileName, "xb+")) === false) {
			errorExit("正在处理客户端 {$version} 版本的更新，请不要重复提交");
		}
		fwrite($fp, 'locked');
		fclose($fp);
		echo '正在处理中，稍等5分钟后回来看看吧';
		
		// 开始检出文件
		shell_exec("bash /root/debug_checkout_client.sh {$version} &");
		shell_exec("bash /root/dev_checkout_client.sh {$version} &");
		//删除锁文件
		unlink($lockFileName);
	} else {
		//必须unset掉，否则会出现一些无角色的账号直接跳转到game.php，上一个账号引起
		unset($_SESSION['role_id']);
		if(isset($_POST['account']) && trim($_POST['account']) != '') {
			$account = strtolower(trim($_POST['account']));
			//initStatAccountInfo($account);
			$time = time();
			$agentid = 1;
			$serverid = 10001;
			$fcm = $_POST['fcm'] ? 1 : 0;
			$datakey = $API_SECURITY_TICKEY_LOGIN.$account.$time.$agentid.$serverid.$fcm;
			$ticket = md5($datakey);
			
			$_SESSION['test_host'] = '';
			$_SESSION['test_cvs'] = '';
			if (($_POST['conn_host'] && $_POST['conn_host'] != '')) {
				$_SESSION['test_host'] = trim($_POST['conn_host']);
			}
			if(($_POST['cvs'] && $_POST['cvs'] > 0)) {
				$_SESSION['test_cvs'] = $_POST['cvs'];
			}
			header("location:/user/start.php?account=$account&tstamp={$time}&agentid={$agentid}&serverid={$serverid}&fcm={$fcm}&ticket={$ticket}");
			exit();
		}
	}
} 

$smarty->assign('clientVersions', $versionDirs);
$smarty->display('test.html');

exit();

//遍历出当前目录下的客户端文件夹
function dirtree($path) {
	$d = dir($path);
	$versionDirs = array();
	while(false !== ($v = $d->read())) {
		if($v == '.' || $v == '..') {
			continue;
		}
		$versionDirs[]  = $v;
	}
	return $versionDirs;
}

