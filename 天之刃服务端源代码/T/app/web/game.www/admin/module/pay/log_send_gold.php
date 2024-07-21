<?php
/**
 * 赠送元宝记录
 */
define('IN_ODINXU_SYSTEM', true);
include "../../../config/config.php";
include SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

$adminID = 2003;

if ( !isset($_REQUEST['dateStart'])) {
	$dateStart = strftime ("%Y-%m-%d", time() - 86400 );
} else {
	$dateStart  = trim(SS($_REQUEST['dateStart']));
}

if ( !isset($_REQUEST['dateEnd'])) {
	$dateEnd = strftime ("%Y-%m-%d", time() );
} else {
	$dateEnd = trim(SS($_REQUEST['dateEnd']));
}

$dateStartStamp = strtotime($dateStart . ' 0:0:0');
$dateEndStamp   = strtotime($dateEnd . ' 23:59:59');

$log = new AdminLogClass();
$data = $log->getGlvLogs($dateStartStamp, $dateEndStamp, "", 9001, $adminID);

$smarty->assign("keywordlist", $data);

$smarty->display("module/pay/log_send_gold.tpl");
exit;