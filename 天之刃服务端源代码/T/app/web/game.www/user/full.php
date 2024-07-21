<?php
define('IN_ODINXU_SYSTEM', true);
include "../config/config.php";
include_once SYSDIR_INCLUDE."/global.php";
include_once "./user_auth.php";

global $smarty;

$onlineNum = getOnline();

$timeWait = $_SESSION['queue_num'];
if ($timeWait > 60) {
	$timeWait = 60;
} else  if ($timeWait < 10) {
	$timeWait = 10;
}

$smarty->assign('queueNum', $_SESSION['queue_num']);
$smarty->assign('title', WEB_TITLE);
$smarty->assign('full', $_SESSION['full']);
$smarty->assign('timeWait', $timeWait);
$smarty->assign('serverListUrl', SERVER_LIST_URL);
$smarty->display('full.html');