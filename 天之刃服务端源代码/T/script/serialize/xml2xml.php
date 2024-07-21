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

include_once './module/mission/MissionTransform.php';

$MISSION_BASE_XML_FILE = DATA_PATH . '/mission/mission_data.xml';
  

$xmlRoot = loadXml($MISSION_BASE_XML_FILE);
$data = $xmlRoot->mission;
foreach ($data as $rec) { 
	$minLevel = intval((string) $rec['min_level']);
	$type = intval((string) $rec ['type']);
	$preMissID = ( string ) $rec ['pre_mission_id'];
	if( $minLevel>3 && $minLevel<20 && $type==1 && $preMissID != '0' ){
		$rec['min_level'] = $minLevel-2;
	} 
	
};
 


writeXml($xmlRoot,$MISSION_BASE_XML_FILE);

echo "转换XML成功,path=". $MISSION_BASE_XML_FILE ."\n";

function loadXml($file){
	return simplexml_load_file( $file );
} 


function writeXml($xmlRoot,$filePath) {
	$fp = fopen( $filePath, "w");

	$xmlContent = $xmlRoot->asXML();
	$xmlContent = str_replace("><", ">\n\t<", $xmlContent);
	$xmlContent = str_replace("\t<mission id", "<mission id", $xmlContent);
	$xmlContent = str_replace("\t</mission>", "</mission>", $xmlContent);

	fwrite($fp, $xmlContent);
	fclose($fp);
}