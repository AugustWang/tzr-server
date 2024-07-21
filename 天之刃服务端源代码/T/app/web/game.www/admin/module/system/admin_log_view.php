<?php
/*
 * Author: wuzesen
 *
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth, $smarty;

$auth->assertModuleAccess(__FILE__);

$admin_name = trim($_REQUEST['admin_name']);

if ( !isset($_REQUEST['dateStart']))
	$dateStart = strftime ("%Y-%m-%d", time() - 86400 );
else
	$dateStart  = trim(SS($_REQUEST['dateStart']));

if ( !isset($_REQUEST['dateEnd']))
	$dateEnd = strftime ("%Y-%m-%d", time() );
else
	$dateEnd = trim(SS($_REQUEST['dateEnd']));

//过滤条件
$gulvxt = isPost() ? trim(SS($_POST['gulvxt'])) : '9001' ;

$op_type = trim(SS($_REQUEST['op_type']));
if(empty($op_type))$op_type = '0';

$op_id = $_REQUEST['op_id'];
if(empty($op_id))$op_id = '0';

$dateStartStamp = strtotime($dateStart . ' 0:0:0');
$dateEndStamp   = strtotime($dateEnd . ' 23:59:59');

$dateStartStr = strftime ("%Y-%m-%d", $dateStartStamp);
$dateEndStr   = strftime ("%Y-%m-%d", $dateEndStamp);

$op_name = $ADMIN_LOG_TYPE;

$log = new AdminLogClass();
$data = $log->getGlvLogs($dateStartStamp, $dateEndStamp, $admin_name, $gulvxt, $op_id);

//new dBug($data);
$smarty->assign("gulvxt",$gulvxt);
$smarty->assign("op_name",$op_name);
$smarty->assign("op_id",$op_id);
$smarty->assign("search_keyword1", $dateStartStr);
$smarty->assign("search_keyword2", $dateEndStr);
$smarty->assign("admin_name", $admin_name);

$smarty->assign("keywordlist", $data);

$smarty->display("module/system/admin_log_view.tpl");
exit;
