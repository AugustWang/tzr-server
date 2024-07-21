<?php
/**
 * 1-2级玩家流失统计
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

//默认统计48小时内的数据
$interval = (intval($_POST['interval']) > 0 ) ? intval($_POST['interval']) : 48;

$smarty->assign('intervalHour', $interval);

$beginTime = strtotime(SERVER_ONLINE_DATE);
$endTime = $beginTime + 48 * 3600;

// 获得0级玩家的数量
$sqlLevelZero = "SELECT count(1) as count FROM  "
				. "`db_role_attr_p` as a, `db_role_base_p` as b "
				."WHERE a.level = 0 and a.role_id = b.role_id and b.create_time < {$endTime}";
$resultLevelZeror = GFetchRowOne($sqlLevelZero);
$numOfLevelZero = $resultLevelZeror['count'];				

// 获得1级玩家的数量
$sqlLevelOne = "SELECT count(1) as count FROM " 
				. "`db_role_attr_p` as a, `db_role_base_p` as b "
				."WHERE a.level = 1 and a.role_id = b.role_id and b.create_time < {$endTime}";
$resultLevelOne = GFetchRowOne($sqlLevelOne);
$numOfLevelOne = $resultLevelOne['count'];

// 获得2级玩家的数量
$sqlLevelSecond = "SELECT count(1) as count FROM " 
				. "`db_role_attr_p` as a, `db_role_base_p` as b "
				."WHERE a.level = 2 and a.role_id = b.role_id and b.create_time < {$endTime}";
$resultLevelSecond = GFetchRowOne($sqlLevelSecond);
$numOfLevelSecond = $resultLevelSecond['count'];

// 获得期间的总角色数量
$sqlAllRole = "select count(1) as count from db_role_base_p where create_time < {$endTime}";
$resultAllRole = GFetchRowOne($sqlAllRole);
$numOfAll = $resultAllRole['count'];

// 获得3级玩家数量
$sqlLevelTrd = "SELECT count(1) as count FROM " 
				. "`db_role_attr_p` as a, `db_role_base_p` as b "
				."WHERE a.level = 3 and a.role_id = b.role_id and b.create_time < {$endTime}";
$resultLevelTrd = GFetchRowOne($sqlLevelTrd);
$numOfLevelTrd = $resultLevelTrd['count'];

// 获得10级以下玩家数量，包括10级
$sqlLevelTen = "SELECT count(1) as count FROM " 
				. "`db_role_attr_p` as a, `db_role_base_p` as b "
				."WHERE a.level <= 10 and a.role_id = b.role_id and b.create_time < {$endTime}";
$resultLevelTen = GFetchRowOne($sqlLevelTen);
$numOfLevelTen = $resultLevelTen['count'];

// 获得20级一下玩家数量，包括20级
$sqlLevelTweenty = "SELECT count(1) as count FROM " 
				. "`db_role_attr_p` as a, `db_role_base_p` as b "
				."WHERE a.level <= 20 and a.role_id = b.role_id and b.create_time < {$endTime}";
$resultLevelTweenty = GFetchRowOne($sqlLevelTweenty);
$numOfLevelTweenty = $resultLevelTweenty['count'];

// 获得30级一下玩家数量，包括20级
$sqlLevelThirty = "SELECT count(1) as count FROM " 
				. "`db_role_attr_p` as a, `db_role_base_p` as b "
				."WHERE a.level <= 30 and a.role_id = b.role_id and b.create_time < {$endTime}";
$resultLevelThirty = GFetchRowOne($sqlLevelThirty);
$numOfLevelThirty = $resultLevelThirty['count'];

// 统计所有从平台跳转过来的账号数量
$allAccountSql = "SELECT count(1) as count FROM "
					."`t_portal_account` WHERE mtime < {$endTime}";
$resultAllAccount = GFetchRowOne($allAccountSql);
$numOfAllAccount = $resultAllAccount['count'];

// 统计创角成功的数量
$allCreate = "SELECT count(1) as count FROM`t_role_create_after` WHERE mtime < {$endTime}";
$resultAllCreate = GFetchRowOne($allCreate);
$numOfCreate = $resultAllCreate['count'];

// 进入游戏的玩家数量
$allEnterGame = "SELECT count(1) as count FROM`t_log_behavior` WHERE ".
					"log_time < {$endTime} and behavior_type = 1";
$resultAllEnterGame = GFetchRowOne($allEnterGame);
$numOfAllEnterGame = $resultAllEnterGame['count'];
					
$arr = array(
	 'numOfAll' => $numOfAll,
     'server_online_date' => SERVER_ONLINE_DATE,
     'numOfLevelOne' => $numOfLevelOne,
     'numOfLevelSecond' => $numOfLevelSecond,
     'numOfLevelTrd' => $numOfLevelTrd,
     'numOfLevelTen' => $numOfLevelTen,
     'numOfLevelTweenty' => $numOfLevelTweenty,
     'numOfLevelThirty' => $numOfLevelThirty,
	 'numOfAllAccount' => $numOfAllAccount,
	 'numOfCreate' => $numOfCreate,
	 'numOfAllEnterGame' => $numOfAllEnterGame,
	 'numOfLevelZero' => $numOfLevelZero,
);
$smarty->assign($arr);
$smarty->display("module/stat/level_1_2_liushi.tpl");
