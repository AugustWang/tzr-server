<?php

/**
 * 将地图流失率数据转换成JSON并显示
 */
 
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";

header('Content-Type: text/html; charset=UTF-8');
include_once SYSDIR_CLASS."/db.class.php";
include_once SYSDIR_ROOT."/include/functions.php";

global  $db, $dbConfig, $dbConfig_game;


//初始化数据库连接
//主数据库
if($dbConfig_game) {
	global $db_game;
	$db_game = new DBClass();
	$db_game->connect($dbConfig_game);
}
global $db;
$db = $db_game;



$keyVector = 'jinchengshimasaikezhifu0525'; //密钥（用于与地图流失前端的匹配）
$reqKey=trim(SS($_REQUEST['key']));

if( $reqKey !== $keyVector ){
	exit("密钥错误！");
}


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

	