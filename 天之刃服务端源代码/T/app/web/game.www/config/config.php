<?php 
if (!defined('IN_ODINXU_SYSTEM')) {
	exit('hack attemp!');
}

//定义项目根目录
define('SYSDIR_ROOT', realpath(dirname(__FILE__)."/../") . DIRECTORY_SEPARATOR);
define('MING2_WEB_ADMIN_FLAG', true);

define('SYSDIR_CLASS', SYSDIR_ROOT."class");
define('SYSDIR_INCLUDE', SYSDIR_ROOT."include");
define('SYSDIR_LIBRARY', SYSDIR_ROOT."library");
define('SYSDIR_CONFIG', SYSDIR_ROOT.'config');

define('SYSDIR_ADMIN', SYSDIR_ROOT.'admin');

//包含配置文件
include_once SYSDIR_CONFIG.'/config.inc.php';
include_once SYSDIR_CONFIG.'/config.cache.php';
include_once SYSDIR_CONFIG.'/config.common.php';
include_once SYSDIR_CONFIG.'/config.admin.php';

include_once SYSDIR_CLASS.'/db.class.php';
