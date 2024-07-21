<?php
include_once SYSDIR_CLASS."/db.class.php";
include_once SYSDIR_ADMIN."/class/user_class.php";
include_once SYSDIR_INCLUDE."/functions.php";
include_once SYSDIR_ADMIN."/include/db_defines.php";
include_once SYSDIR_CLASS.'/cache.class.php';

global $db, $dbConfig, $dbConfig_game;

//初始化数据库连接
//主数据库
if($dbConfig_game) {
	global $db_game;
	$db_game = new DBClass();
	$db_game->connect($dbConfig_game);
}
global $db;
$db = $db_game;


global $cacheConfig, $cache;
$cache = ConnectCache($cacheConfig, true);


global $CONFIG_PARAMS;
define_SystemConfigFromDB($CONFIG_PARAMS);
