<?php
header("P3P: CP=CURa ADMa DEVa PSAo PSDo OUR BUS UNI PUR INT DEM STA PRE COM NAV OTC NOI DSP COR");
header('Content-Type: text/html; charset=UTF-8');

include_once SYSDIR_ADMIN."/class/auth.class.php";
include_once SYSDIR_CLASS."/db.class.php";
include_once SYSDIR_ADMIN."/class/user_class.php";

include_once SYSDIR_ADMIN."/library/smarty/Smarty.class.php";
include_once SYSDIR_ROOT."/include/functions.php";
include_once SYSDIR_ADMIN."/include/db_defines.php";
include_once SYSDIR_CLASS.'/cache.class.php';

global $smarty, $auth, $db, $dbConfig, $dbConfig_game;

//ob_start();
session_start();

//初始化smarty
$smarty = new Smarty();
$smarty->compile_check = true;
$smarty->force_compile = true;
$smarty->template_dir = SYSDIR_ADMIN."/template/default/";
$smarty->compile_dir = SYSDIR_ADMIN."/template_c";
$smarty->left_delimiter = '<{';
$smarty->right_delimiter = '}>';

//初始化数据库连接
//主数据库
if($dbConfig_game) {
	global $db_game;
	$db_game = new DBClass();
	$db_game->connect($dbConfig_game);
}
global $db;
$db = $db_game;

//标志是否处在debug模式
if(isDebugMode()){
    $_SESSION['admin_debug'] = true;
}

$auth = new AuthClass();
if (basename($_SERVER['SCRIPT_FILENAME']) != 'login.php') {
	if (!$auth->auth()) {
		header("Location:/admin/login.php");
		exit();
	} 
	//更新最后操作时间
	$_SESSION['last_op_time'] = time();
}


global $cacheConfig, $cache;
$cache = ConnectCache($cacheConfig, true);


//页面显示的定义
define(LIST_PER_PAGE_RECORDS, 20); //Search page show ... records per page
define(LIST_SHOW_PREV_NEXT_PAGES, 7); //First Prev 1 2 3 4 5 6 7 8 9 10... Next Last

include_once SYSDIR_ADMIN."/class/base.config.php";
include_once SYSDIR_ADMIN."/class/admin_user.class.php";
include_once SYSDIR_ADMIN."/class/admin_group.class.php";
include_once SYSDIR_ADMIN.'/class/admin_log_class.php';
include_once SYSDIR_ADMIN.'/class/admin_access_rule.class.php';

//定义CRLF
define("CRLF", "<BR>\r\n");

global $CONFIG_PARAMS;
define_SystemConfigFromDB($CONFIG_PARAMS);
