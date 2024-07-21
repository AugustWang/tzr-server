<?php



/*
 * 将mysql中的老任务数据导出到xml文件中
 */
 
define ( 'ROOT', dirname ( __FILE__ ) );
define ( 'DATA_PATH', ROOT . '/../../config/base_data' );
define('IN_ODINXU_SYSTEM', true);

$paths = array ();
$paths [] = ROOT;
$paths [] = ROOT . '/libs';
$paths [] = ROOT . '/module/npc';
$paths [] = ROOT . '/module/mission';
$paths [] = ROOT . '/module/mission_setting';

set_include_path ( get_include_path () . implode ( PATH_SEPARATOR, $paths ) );

include_once '../../app/web/game.www/config/config.php';
include_once '../../app/web/game.www/include/global.php';
include_once './module/mission/MissionTransform.php';

$MISSION_BASE_XML_FILE = DATA_PATH . '/mission/mission_data.xml';

  

$xmlRoot = loadXml($MISSION_BASE_XML_FILE);
$data = $xmlRoot->mission;

$txtContent = "";
foreach ($data as $rec) { 
	$txtContent .= "id=".$rec['id']  . ",name=".$rec['name'] . ",mission_model=".$rec['mission_model']
		."\n";
};

$filePath = "/data/mission_test.txt";
writeText($txtContent,$filePath);

echo "输出txt成功,path=". $filePath ."\n";

function loadXml($file){
	return simplexml_load_file( $file );
}


function writeText($txtContent,$filePath) {
	$fp = fopen( $filePath, "w");

	fwrite($fp, $txtContent);
	fclose($fp);
}