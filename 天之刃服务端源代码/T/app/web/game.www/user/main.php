<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_ROOT."/config/config.key.php";
include_once SYSDIR_INCLUDE."/global.php";
include_once "./user_auth.php";

global $smarty;
$smarty->assign('title', WEB_TITLE);
$smarty->display('main.html');