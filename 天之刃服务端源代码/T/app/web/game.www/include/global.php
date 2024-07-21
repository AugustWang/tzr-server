<?php
header('Content-Type: text/html; charset=UTF-8');

include_once SYSDIR_ROOT."admin/library/smarty/Smarty.class.php";
include_once SYSDIR_CLASS."/db.class.php";
include_once SYSDIR_ROOT."/include/define.php";
include_once SYSDIR_ROOT."/include/functions.php";
include_once SYSDIR_ADMIN."/include/db_functions.php";
include_once SYSDIR_CLASS.'/cache.class.php';
include_once SYSDIR_CLASS.'/Class_iplocation.php';

global $smarty, $auth, $db, $dbConfig, $dbConfig_game;

ob_start();
session_start();

//初始化smarty
$smarty = new Smarty();
$smarty->compile_check = true;
$smarty->force_compile = true;
$smarty->template_dir = SYSDIR_ROOT."template/default/";
$smarty->compile_dir = SYSDIR_ROOT."template_c";
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

//缓存初始化
global $cacheConfig, $cache;
$cache = ConnectCache($cacheConfig, true);

global $CONFIG_PARAMS;
$CONFIG_PARAMS['ACCNAME'] = $_SESSION['account_name'];
// 根据数据库记录定义系统常量
define_SystemConfigFromDB($CONFIG_PARAMS);

if (!testMochiwebIsOk()) {
	echo '后台Web服务尚未启动，请联系管理员！';
	exit();
} 

//更新最后操作时间
$_SESSION['last_op_time'] = time();

//页面显示的定义
define(LIST_PER_PAGE_RECORDS, 20); //Search page show ... records per page
define(LIST_SHOW_PREV_NEXT_PAGES, 7); //First Prev 1 2 3 4 5 6 7 8 9 10... Next Last

define('MIN_UNAME_LENGTH'       , 2);
define('MAX_UNAME_LENGTH'       , 7);
define('MAX_CN_UNAME_LENGTH'    , 7);


//ISP列表
global $g_net_line;
$g_net_line = array(
	1=>'电信',
	2=>'教育',
	3=>'网通',
	4=>'其他'
);

