<?php
define ( 'ROOT', dirname ( __FILE__ ) );
define ( 'DATA_PATH', ROOT . '/../../config/base_data' );

$paths = array ();
$paths [] = ROOT;
$paths [] = ROOT . '/libs';
$paths [] = ROOT . '/module/npc';
$paths [] = ROOT . '/module/mission';
$paths [] = ROOT . '/module/mission_setting';

set_include_path ( get_include_path () . implode ( PATH_SEPARATOR, $paths ) );
include 'Zend/Loader/Autoloader.php';
Zend_Loader_Autoloader::getInstance ()->setFallbackAutoloader ( true );

mkdir_if_notexists ( ROOT . '/output' );
$action = $argv [1];
switch ($action) {
	case 'npc' :
		new NPC ();
		break;
	
	case 'mission' :
		new Mission ();
		break;
	
	case 'mission_setting' :
		new MissionSetting ();
		break;
	
	default :
		trigger_error ( '系统错误' );
		break;
}

function mkdir_if_notexists($path) {
	if (is_dir ( $path )) {
	} else {
		mkdir ( $path );
	}
}
?>