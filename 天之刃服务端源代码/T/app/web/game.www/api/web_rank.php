<?php
/**
 * 游戏内排行榜查询
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";

header('Content-Type: text/html; charset=UTF-8');
include_once SYSDIR_CLASS."/db.class.php";
include_once SYSDIR_CLASS."/cache.class.php";
include_once SYSDIR_ROOT."/include/functions.php";


global  $db, $dbConfig, $dbConfig_game;

//$runtime= new runtime;
//$runtime->start();
//初始化数据库连接
//主数据库
if($dbConfig_game) {
	global $db_game;
	$db_game = new DBClass();
	$db_game->connect($dbConfig_game);
}
global $db;
$db = $db_game;


$type = $_REQUEST['type'];
$key = $_REQUEST['key'];

if (empty($key))
{
    die();
}

//if (md5($time.$API_SECURITY_TICKET_RANK) != $ticket)
//{
//    die();
//}

$key = "chuanqirank201169";
$rank_table = array(
	1001 => '',		//战士排行榜
	1002 => '',     //射手排行榜
	1003 => '', 	//侠客排行榜
	1004 => '',		//医仙排行榜
	2001 => '',		//门派排行
	3001 => '',		//神兵榜
	5001 => '',		//云州护国榜
	5002 => '',     //沧州护国榜
	5003 => '', 	//幽州护国榜
	6001 => '',		//百花谱
	7001 => '',		//送花谱
	8001 => '',		//宠物榜
	9001 => '',		//英雄副本榜
);


    //获得排行榜，直接返回json字符串，方便处理
	if($type == 1001)
	{
		$sql = "SELECT `role_name` , `faction_id` , `family_name` , `level` , `ranking` , `title` FROM `db_role_level_rank_p` WHERE `category` = 1 ORDER BY `level` DESC , `exp` DESC";
	}elseif ($type == 1002)
	{
		$sql = "SELECT `role_name` , `faction_id` , `family_name` , `level` , `ranking` , `title` FROM `db_role_level_rank_p` WHERE `category` = 2 ORDER BY `level` DESC , `exp` DESC";
	}elseif ($type == 1003)
	{
		$sql = "SELECT `role_name` , `faction_id` , `family_name` , `level` , `ranking` , `title` FROM `db_role_level_rank_p` WHERE `category` = 3 ORDER BY `level` DESC , `exp` DESC";
	}elseif ($type == 1004)
	{
		$sql = "SELECT `role_name` , `faction_id` , `family_name` , `level` , `ranking` , `title` FROM `db_role_level_rank_p` WHERE `category` = 4 ORDER BY `level` DESC , `exp` DESC";
	}elseif ($type == 2001)
	{
		$sql = "SELECT `family_name`, `owner_role_name`, `level`, `ranking`, `member_count`, `active`, `faction_id` FROM `db_family_active_rank_p` ORDER BY `ranking` ASC";
	}elseif ($type == 3001)
	{
		die();
	}elseif ($type == 5001)
	{
		$sql = "SELECT `role_name`, `faction_id`, `family_name`, `level`, `ranking`, `title`,`gongxun` FROM `db_role_gongxun_rank_p` WHERE `faction_id` = 1 ORDER BY `ranking` ASC";
	}elseif ($type == 5002)
	{
		$sql = "SELECT `role_name`, `faction_id`, `family_name`, `level`, `ranking`, `title`,`gongxun` FROM `db_role_gongxun_rank_p` WHERE `faction_id` = 2 ORDER BY `ranking` ASC";
	}elseif ($type == 5003)
	{
		$sql = "SELECT `role_name`, `faction_id`, `family_name`, `level`, `ranking`, `title`,`gongxun` FROM `db_role_gongxun_rank_p` WHERE `faction_id` = 3 ORDER BY `ranking` ASC";
	}elseif ($type == 6001)
	{
		$sql = "SELECT `ranking`, `role_name`, `family_name`, `faction_id`, `title`, `charm` FROM `db_role_rece_flowers_rank_p` ORDER BY `ranking`";
	}elseif ($type == 7001)
	{
		$sql = "SELECT `ranking`, `role_name`, `family_name`, `faction_id`, `title`, `score` FROM `db_role_give_flowers_rank_p` ORDER BY `ranking`";
	}elseif ($type == 8001)
	{
		$sql = "SELECT `pet_id`, `pet_type_name`, `ranking`, `role_name`, `level`, `color`, `score`, `faction_id`, `title` FROM `db_role_pet_rank_p` ORDER BY `ranking` ASC";
	}elseif ($type == 9001)
	{
		die();
	}
	else 
	{
		die();
	}
	
	$rank = GFetchRowSet($sql);
	$result = array(
		'type' => $type,
		'rank_info' => $rank,
	);
	$result = json_encode($result);
	
	
   // $cache->store($type, $result);


print $result;