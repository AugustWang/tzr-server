<?php
/*
 * Author: odinxu, MSN: odinxu@hotmail.com
 * 2008-9-7
 *
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;

$auth->assertModuleAccess(__FILE__);

if ( !isset($_REQUEST['dateStart']))
	$dateStart = strftime ("%Y-%m", time()) . '-01';
else
	$dateStart  = trim(SS($_REQUEST['dateStart']));

if ( !isset($_REQUEST['dateEnd']))
	$dateEnd = strftime ("%Y-%m-%d", time() );
else
	$dateEnd = trim(SS($_REQUEST['dateEnd']));

$dateStartStamp = strtotime($dateStart . ' 0:0:0') or $dateStartStamp = GetTime_Today0();
$dateEndStamp   = strtotime($dateEnd . ' 23:59:59') or $dateEndStamp = time();

$dateStartStr = strftime ("%Y-%m-%d", $dateStartStamp);
$dateEndStr   = strftime ("%Y-%m-%d", $dateEndStamp);


$data = getSqlData($dateStartStamp, $dateEndStamp);
//new dBug($data);
$reg_count = getAllRegCount();

$smarty->assign("search_keyword1", $dateStartStr);
$smarty->assign("search_keyword2", $dateEndStr);

$smarty->assign("keywordlist", $data);
$smarty->assign("reg_count", $reg_count);

$smarty->display("module/gamer/gamer_reg_stat.tpl");
exit;
//////////////////////////////////////////////////////////////

function getAllRegCount()
{
	global $db;
	$sql = "SELECT COUNT(role_id) as c FROM `db_role_base_p`";
	$arr = GFetchRowOne($sql, $db);
	return intval($arr['c']);
}


function getSqlData($startTime, $endTime)
{
	global $db;
	$sql = "SELECT YEAR( FROM_UNIXTIME( create_time ) ) as `year`, "
		 . " MONTH( FROM_UNIXTIME( create_time ) ) as `month`, "
		 . " DAY( FROM_UNIXTIME( create_time ) ) as `day`,"
		 . " COUNT(`role_id`) as c FROM `db_role_base_p` "
		 . " WHERE create_time>={$startTime} AND create_time<={$endTime} "
		 . " GROUP BY `year`,`month`,`day` WITH ROLLUP " ;
		 //用了 WITH ROLLUP 就不能再用ORDER BY


	$result = GFetchRowSet($sql, $db);
	return $result;
}
