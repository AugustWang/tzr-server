<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/dict/pet.php';
include_once SYSDIR_ADMIN.'/include/dict.php';

$startDate = $_REQUEST['startDate'];
$endDate = $_REQUEST['endDate'];
$startDateTime = strtotime($startDate);
$endDateTime = strtotime($endDate) ? strtotime($endDate)+86399 : false;

if (!$startDateTime || !$endDateTime ) {
	$startDateTime = strtotime(date('Y-m-d',strtotime('-6 day')));
	$endDateTime = strtotime(date('Y-m-d 23:59:59'));
}
if ($startDateTime < $serverOnLineTime) {
	$startDateTime = $serverOnLineTime;
}

$startDate = date('Y-m-d',$startDateTime);
$endDate = date('Y-m-d',$endDateTime);

if($startDate && $endDate){
    $sql = "select pet_id,role_name,role_id,pet_level,training_hours,training_cost,mtime
                 from t_log_pet_training where mtime >{$startDateTime} and mtime<{$endDateTime}";
    $result = GFetchRowSet($sql);

}

$smarty->assign("rowResult",$result);
$smarty->assign("startDate",$startDate);
$smarty->assign("endDate",$endDate);
$smarty->display("module/pet/pet_training.tpl");


function star(){
    return array('1星','2星','3星','4星','5星','6星','7星','8星','9星' );
}