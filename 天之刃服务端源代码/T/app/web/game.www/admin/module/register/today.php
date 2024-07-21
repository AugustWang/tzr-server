<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $db, $smarty;

$auth->assertModuleAccess(__FILE__);

$year = date('Y');
$month = date('m');
$day = date('d');

//取出总注册账号的数量、取出总的角色数量
$sqlAllAccount = "SELECT COUNT(account_name) AS count FROM ".T_DB_ACCOUNT_P.
	" WHERE 1";
$result = $db->fetchOne($sqlAllAccount);
$countOfAccount = $result['count'];

$sqlAllRole = "SELECT COUNT(role_id) AS count FROM ".T_DB_ROLE_ATTR_P. " WHERE 1";
$result = $db->fetchOne($sqlAllRole);
$countOfRole = $result['count'];

$sqlFactionRole = "SELECT count(role_id) AS count , faction_id FROM "
			.T_DB_ROLE_BASE_P." WHERE 1 GROUP BY faction_id";
$result = $db->fetchAll($sqlFactionRole);
foreach ($result as $v) {
	if ($v['faction_id'] == 1) {
		$role_count_of_hongwu = $v['count'];
	} else if ($v['faction_id'] == 2) {
		$role_count_of_yongle = $v['count'];
	} else if ($v['faction_id'] == 3) {
		$role_count_of_wanli = $v['count'];
	}
}

$smarty->assign(array(
	'role_count_of_hongwu' => $role_count_of_hongwu,
	'role_count_of_yongle' => $role_count_of_yongle,
	'role_count_of_wanli' => $role_count_of_wanli
));

$startTime = strtotime(strftime ("%Y-%m-%d"));
$endTime = time();
//分时显示
$sql = "SELECT YEAR( FROM_UNIXTIME( create_time ) ) as `year`, "
		 . " MONTH( FROM_UNIXTIME( create_time ) ) as `month`, "
		 . " DAY( FROM_UNIXTIME( create_time ) ) as `day`,"
		 . " COUNT(`account_name`) as c FROM `".T_DB_ACCOUNT_P."` "
		 . " WHERE create_time>={$startTime} AND create_time<={$endTime} "
		 . " GROUP BY `year`,`month`,`day` WITH ROLLUP " ;
		 //用了 WITH ROLLUP 就不能再用ORDER BY
		 
$result = $db->fetchAll($sql);
$smarty->assign(array(
	'keywordlist'=>$result,
	'account_count' => $countOfAccount,
	'role_count' => $countOfRole
));
$smarty->display("module/register/today.html");