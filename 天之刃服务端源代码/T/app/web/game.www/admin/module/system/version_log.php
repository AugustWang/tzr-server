<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

$auth->assertModuleAccess(__FILE__);


$start = SS($_REQUEST['start']);
$end = SS($_REQUEST['end']);

if(empty($start)) $start = date('Y-m-d');
if(empty($end)) $end = date('Y-m-d');

$startstamp = strtotime($start);
$endstamp = strtotime($end) + 24*60*60-1;

$where = " `log_time` > $startstamp AND `log_time` < $endstamp ";

$sql = " SELECT * FROM `t_log_version` WHERE $where ";

$result = GFetchRowSet($sql);
if(count($result))
{ 
	foreach($result as $k=>$v)
	{
		$result[$k]['log_time']=date('Y-m-d H:i:s', $v['log_time']);
	}
}

//-------------------------------------------------------
	
$smarty->assign('start',$start);
$smarty->assign('end',$end);
$smarty->assign('datalist',$result);

$smarty->display('module/system/version_log.tpl');

//-------------------local function ------------------------

