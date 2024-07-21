<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';

$auth->assertModuleAccess(__FILE__);
$start = SS($_REQUEST['start']);
$end = SS($_REQUEST['end']);
if(empty($start)) $start = date('Y-m-d');
if(empty($end)) $end = date('Y-m-d');
$startstamp = strtotime($start);
$endstamp = strtotime($end) + 24*60*60-1;
$action =$_REQUEST['action'];
if($action=="search")
{ 
	$where="TRUE";
	
	$where .= " AND `drop_time` > $startstamp AND `drop_time` < $endstamp ";
	
	$fb_type=SS($_REQUEST['fb_type']);
	if(!empty($fb_type))
	{
		$where.=" AND fb_type= {$fb_type} ";
	}
	$fb_level=SS($_REQUEST['fb_level']);
	if(!empty($fb_level))
	{
		$where.=" AND map_id = {$fb_level} ";
	}
	
	
	$logsql="SELECT type_id,(SELECT c.item_name from t_item_list as c WHERE c.typeid=type_id) as item_name,(SELECT b.map_name FROM t_map_list as b WHERE b.map_id=a.map_id) as map_name,drop_time FROM t_log_fb_drop_thing as a WHERE {$where} ";
	$log_list = GFetchRowSet($logsql);
	foreach($log_list as $k=>$v)
	{
		$log_list[$k]['drop_time']=date('Y-m-d H:i:s',$v['drop_time']);
	}
	
	
	$statsql="SELECT type_id,(SELECT c.item_name from t_item_list as c WHERE c.typeid=type_id) as item_name,COUNT(id) as count FROM t_log_fb_drop_thing WHERE {$where} GROUP BY type_id ";
	$stat_list = GFetchRowSet($statsql);

	$result=getFBLevelList($fb_type);
	$fb_level_list=array();
	foreach($result as $k=>$v)
	{
		$fb_level_list[$v['map_id']]=$v['map_name'];
	}
	
}
else if($action =="change_fb")
{
	$fb_type=SS($_REQUEST['fb_type']);
	$fb_level_list = getFBLevelList($fb_type);
    $json_level_list=json_encode($fb_level_list);
	echo $json_level_list;
	exit ;
}
	$fb_type_list= getFBTypeList();
	$smarty->assign('fb_type_list',$fb_type_list);
	$smarty->assign('fb_level_list',$fb_level_list);
	$smarty->assign('log_list',$log_list);
	$smarty->assign('start',$start);
	$smarty->assign('end',$end);
	$smarty->assign('stat_list',$stat_list);	
	$smarty->assign('fb_type',$fb_type);
	$smarty->assign('fb_level',$fb_level);
	$smarty->display('module/stat/fb_drop_thing_stat.tpl');


function getFBLevelList($fb_type)
{
	$fb_level_list= array();
	$head=array();
	if($fb_type==1)
		$fb_level_list=getPYHLevelList();
	else if($fb_type==2)
		$fb_level_list=getFDDTLevelList();
	else if($fb_type==3)
		$fb_level_list=getDMYXLevelList();
	$head[]=array('map_id'=>'0','map_name'=>'全部等级');
	$fb_level_list = array_merge($head,$fb_level_list);
	return $fb_level_list;
}


function getFBTypeList()
{
	$fbTypeList=array(
		0=>"全部副本",
		1=>"鄱阳湖副本",
		2=>"洞天福地副本",
		3=>"大明英雄副本",
	);
	return $fbTypeList;
}



function getPYHLevelList()
{
	$sql="SELECT * FROM t_map_list WHERE map_id>=10901 AND map_id<=10903 ";
	$result=GFetchRowSet($sql);
	$PYHLevelList=array();
	
	
	return $result;
}
function getFDDTLevelList()
{
	$sql="SELECT * FROM t_map_list WHERE map_id>=10904 AND map_id<=10906 ";
	$result=GFetchRowSet($sql);
	$FDDTLevelList=array();
//	foreach($result as $v)
//	{
//		$FDDTLevelList[$v['map_id']]=$v['map_name'];
//	}
	return $result;
}
function getDMYXLevelList()
{
	$sql="SELECT * FROM t_map_list WHERE map_id>=10801 AND map_id<=10837 ";
	$result=GFetchRowSet($sql);
	$DMYXLevelList=array();
//	foreach($result as $v)
//	{
//		$DMYXLevelList[$v['map_id']]=$v['map_name'];
//	}
	return $result;
}


?>