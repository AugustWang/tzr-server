<?php
/*
* Author: odinxu, MSN: odinxu@hotmail.com
* 2008-9-6
*
*/
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

$date1=trim(SS($_REQUEST['date1']));
$date2=trim(SS($_REQUEST['date2']));
$viewtype=trim(SS($_REQUEST['viewtype']));

if ( !isset($_REQUEST['date1']))
$date1 = strftime ("%Y-%m-%d", time());
else
$date1  = trim(SS($_REQUEST['date1']));
if ( !isset($_REQUEST['date2']))
$date2 = strftime ("%Y-%m-%d", time()) ;
else
$date2  = trim(SS($_REQUEST['date2']));
$date1Stamp = strtotime($date1 . ' 0:0:0') or $date1Stamp = GetTime_Today0();
$date2Stamp   = strtotime($date2 . ' 23:59:59') or $date2Stamp = time();
if ( !isset($_REQUEST['viewtype']))
$viewtype = 4;

if($viewtype==1)
	$datalist = AvgCountHour($date1Stamp,$date2Stamp);
elseif($viewtype==2)
	$datalist = AvgCountDay($date1Stamp,$date2Stamp);
elseif($viewtype==3)
	$datalist = AvgCount1Min($date1Stamp,$date2Stamp);
elseif($viewtype==4)
	$datalist = AvgCountMax($date1Stamp,$date2Stamp);

$dateStrPrev = strftime("%Y-%m-%d", $date1Stamp - 86400);
$dateStrNext = strftime("%Y-%m-%d", $date2Stamp + 86400);
$dateStamp = time();
if($date2Stamp >$dateStamp){
    $date2Stamp   = strtotime(date('Y-m-d',$dateStamp) . ' 23:59:59');
}
if($date1Stamp>$dateStamp){
    $date1Stamp   = strtotime(date('Y-m-d',$dateStamp) . ' 23:59:59');
}
$maxOnline=0;
$avgOnline=0;
if(Count($datalist)>0)
{
	foreach($datalist as $id=>$row)
	{
		if($datalist[$id]['avgonline']>$maxOnline)
		{
			$maxOnline=$datalist[$id]['avgonline'];
		}
		$avgOnline+=$datalist[$id]['avgonline'];
	}

	$avgOnline=intval($avgOnline/count($datalist));

	foreach($datalist as $id=>$row)
	{
		$rate=1;
		if($maxOnline>150)
		{
			$rate=150/$maxOnline;
		}
		$datalist[$id]['height']=intval($datalist[$id]['avgonline']*$rate);
		$datalist[$id]['week'] = date('w',strtotime($datalist[$id]['mtime']));
	}
}

$smarty->assign("viewtype", $viewtype);
$smarty->assign("date1", date('Y-m-d',$date1Stamp));
$smarty->assign("date2", date('Y-m-d',$date2Stamp));
$smarty->assign("maxonline", $maxOnline);
$smarty->assign("avgonline", $avgOnline);
$smarty->assign("datalist", $datalist);
$smarty->assign("dateStrPrev",$dateStrPrev);
$smarty->assign("dateStrNext",$dateStrNext);
$smarty->display("module/online/online_stat.tpl");

exit;






//取一天的样本计算最大在线
function AvgCountDay($date1Stamp,$date2Stamp)
{
	$sql= " SELECT floor(avg(`online`)) as avgonline,`year`,`month`,`day` FROM `t_log_online` WHERE 1=1 ";
	$sql.=" and dateline>=".$date1Stamp." and dateline<=".$date2Stamp;
	$sql.=" group by year,month,day";	
	$row = GFetchRowSet($sql);
	return $row;
}
	
	//取一小时的样本计算最大在线
function AvgCountHour($date1Stamp,$date2Stamp)
{
	$sql= " SELECT floor(max(`online`)) as avgonline,`year`,`month`,`day`,`hour` FROM `t_log_online` WHERE 1=1 ";
	$sql.=" and dateline>=".$date1Stamp." and dateline<=".$date2Stamp;
	$sql.=" group by year,month,day,hour";
	$row = GFetchRowSet($sql);
	return $row;
}
	
	//取1分钟的样本计算最大在线
function AvgCount1Min($date1Stamp,$date2Stamp)
{
	$sql= " SELECT floor(max(`online`)) as avgonline,`year`,`month`,`day`,`hour`,`min` FROM `t_log_online` WHERE 1=1 ";
	$sql.=" and dateline>=".$date1Stamp." and dateline<=".$date2Stamp;
	$sql.=" group by year,month,day,hour,`min`";
	$row = GFetchRowSet($sql);
	return $row;
}

	
	//取每天最大的 数量
function AvgCountMax($date1Stamp,$date2Stamp)
{
	$sql= "SELECT MAX( `online` ) as avgonline , `year`,`month`,`day`,`hour`,`min` FROM `t_log_online` WHERE 1=1 ";
	$sql.=" and dateline>=".$date1Stamp." and dateline<=".$date2Stamp;
	$sql.=" GROUP BY `year` , `month` , `day` ";
	$row = GFetchRowSet($sql);
	return $row;
}