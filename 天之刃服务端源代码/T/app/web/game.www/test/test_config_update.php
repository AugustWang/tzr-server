<?php
session_start();
define('IN_ODINXU_SYSTEM', true);
include('../config/config.php');
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";
include_once SYSDIR_CLASS.'/cache.class.php';

global $smarty;

$action = trim($_POST['action']);
if ($action == 'update') {
    $result = shell_exec('/usr/bin/svn up /data/mtzr/config/  --username readonly --password ffg1sYCid8iZtao9');
    if (strpos($result, 'revision') > -1 ) {
        echo "<br /><pre>".$result."</pre>";
        shell_exec('cd /data/mtzr/script/;bash copy_config_file.sh');
        exit();
    } else {
        echo '更新失败，请联系开发人员！'.$result;
    }
    exit();
} else if ($action == 'reload') {
	$config = trim($_POST['config']);
	$result = shell_exec("cd /data/tzr/server/; bash mgectl manager reload_config {$config}");
	if ($result != '') {
		echo '更新失败：'.$result;
	} else {
		echo '更新成功：'.$config.".config";
	}
	exit();
} else if ($action == 'reload_shop') {
	$result = shell_exec("cd /data/tzr/server/; bash mgectl manager reload_shop");
	if ($result != '') {
		echo '更新商店失败:'.$result;
	} else {
		echo '更新商店成功，需要刷新游戏(游戏内缓存了信息)';
	}
	exit();
} else {
	$configFileList = getConfigFileList("/data/tzr/server/config/");
	$smarty->assign('configFileList', $configFileList);
	$defaultUpdateMsg = '当前config的svn版本号：'.getConfigSvnVersion();
	$smarty->assign('defaultUpdateMsg', $defaultUpdateMsg);
	$smarty->display('test_config_update.html');
}


function getConfigFileList($directory) 
{ 
	$result = array();
	$mydir = dir ( $directory );
	while (false !== ($file = $mydir->read())) {
		if ((is_dir ( "$directory/$file" )) and ($file != ".") and ($file != "..")) {
			$t = getConfigFileList ( "$directory/$file" );
			$result  = array_merge($t, $result);
		} else {
			if (getFileExt($file) == 'config') {
				$filename = basename("$directory/$file", ".config");
				$result[$filename] = $file;
			}
		}
	}
	$mydir->close (); 
	ksort($result, SORT_STRING);
	return $result;
} 

function getFileExt($filename) {
	return array_pop(explode('.', $filename));
}

/**
 * 获得config目录的版本号
 */
function getConfigSvnVersion() {
	$content = shell_exec("cd /data/mtzr/config/; svn info --username readonly --password ffg1sYCid8iZtao9");
	$info = explode("\n", $content);
	foreach ($info as $v) {
		if (strpos($v, 'Revision: ') > -1) {
			$tmp = explode(':', $v);
			return intval($tmp[1]);
		}
	}
	return 0;
}