<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_ROOT."/config/config.key.php";
include_once SYSDIR_INCLUDE."/global.php";
include_once "user_auth.php";

global $smarty;

$ip = get_real_ip();
$arr = GetIPaddr($ip);
$true_arr = iconv("gb2312","utf-8",$arr);

getPayUrl($_SESSION['account_name'],$true_arr);

$smarty->assign('gonglueURL', gonglueURL);
$smarty->assign('domain', WEB_SITEURL."user/main.php");
$smarty->assign('agent', AGENT_NAME);
$smarty->assign('title', WEB_TITLE);
$smarty->assign('bbsUrl', BBS_URL);
$smarty->assign('jihoumaURL', JIHUOMA_URL);
$smarty->assign('firstPayUrl', FIRST_PAY_URL);
$smarty->assign('firstPayTitle', FIRST_PAY_TITLE);
$smarty->assign('officialWebSite', OFFICIAL_WEBSITE);
$smarty->assign('agentName', AGENT_NAME);
//给台湾代理的链接
$smarty->assign('FBfunsURL', 'http://www.facebook.com/Unalis.MTW');
$smarty->assign('bhmtURL', 'http://forum.gamer.com.tw/A.php?bsn=20331');
$smarty->assign('yxjdURL', 'http://www.gamebase.com.tw/forum/62271');

$smarty->display('nav.html');

