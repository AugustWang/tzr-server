<?php


/*
 * 将mysql中的老任务数据导出到xml文件中
 */
 
define ( 'ROOT', dirname ( __FILE__ ) );
define('IN_ODINXU_SYSTEM', true);
define('WWW_PATH', '/data/mtzr/app/web/game.www');


include_once WWW_PATH . '/config/config.php';
include_once WWW_PATH . '/include/global.php';


$sql = "SELECT  `map_id`, `level`,`tx`, `ty`, `num` FROM `t_map_liushi` order by map_id,level,tx,ty";

$result = GFetchRowSet($sql);
$liushiArray = array();

$lastMapID = 0;
$lastLevel = 0;
foreach ($result as $row) {
	$mapID = ''.$row['map_id'];
	$level = ''.$row['level'];
	
	if( $lastMapID == $mapID ){
		if( $lastLevel == $level ){
			$liushiArray[$mapID][$level][] = array($row['tx'],$row['ty'],$row['num']);
		}else{
			$liushiArray[$mapID][$level] = getNewLevelArray($row);
		}
	}else{
		$liushiArray[ $mapID ] = array();
		$liushiArray[ $mapID ][ $level ] = getNewLevelArray($row);
	}
	
	$lastMapID = $mapID;
	$lastLevel = $level;
}

function getNewLevelArray($row){
	$r = array();
	$r[] = array($row['tx'],$row['ty'],$row['num']);
	return $r;
}

echo json_encode($liushiArray);

	