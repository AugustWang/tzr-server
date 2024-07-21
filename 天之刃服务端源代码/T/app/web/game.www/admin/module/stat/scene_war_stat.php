<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

$auth->assertModuleAccess(__FILE__);

$fb_list=array(
	0=>'请选择副本',
	5=>'地下王陵副本',
	6=>'魔神之殿'
);

$fb_type=SS($_REQUEST['fb_sel']);
$start = SS($_REQUEST['start']);
$end = SS($_REQUEST['end']);

if(empty($start)) $start = date('Y-m-d');
if(empty($end)) $end = date('Y-m-d');

$startstamp = strtotime($start);
$endstamp = strtotime($end) + 24*60*60-1;

$where="WHERE TRUE ";

$where.= " AND `start_time` > $startstamp AND `start_time` < $endstamp ";

if(!empty($fb_type))
{
	$where.=" AND fb_type=$fb_type ";


//进入次数的人数分布
$PeopleTimesSql = " SELECT times, count(id) as num FROM ".T_LOG_SCENE_WAR." $where GROUP BY times ";
$PeopleTimes = GFetchRowSet($PeopleTimesSql);

for($i=0;$i<count($PeopleTimes);$i++)
{
	$thisdata = $PeopleTimes[$i];
	$nextdata = $PeopleTimes[$i+1];
	if($nextdata)
	{
		$thisdata['num'] -= $nextdata['num'];
	}
	$PeopleTimes[$i]=$thisdata;
}

//队伍人数的次数分布
$TeamTimesSql = "SELECT a.out_number,count(a.out_number) as num FROM (SELECT out_number,team_id FROM ".T_LOG_SCENE_WAR." $where AND team_id>0 GROUP BY team_id) as a GROUP BY a.out_number ";
$TeamTimes = GFetchRowSet($TeamTimesSql);

$SingleTimesSql = "SELECT count(id) as num FROM ".T_LOG_SCENE_WAR." $where AND team_id=0";
$SingleTimesList = GFetchRowSet($SingleTimesSql);
$SingleTimes = array();
$SingleTimes['out_number']="1(非组队)";
$SingleTimes['num']=$SingleTimesList[0]['num'];

////玩家(当时)等级的人次分布
$GamerLevelSql = "SELECT level,count(id) as num FROM ".T_LOG_SCENE_WAR." $where GROUP BY level ";
$GamerLevel = GFetchRowSet($GamerLevelSql);

//按持续时间的人次分布
$ContinueTimeSql="SELECT count(id) as num, (end_time-start_time) DIV 60 as contime FROM ".T_LOG_SCENE_WAR." $where AND `end_time`<>0 GROUP BY contime ";
$ContinueTime = GFetchRowSet($ContinueTimeSql);
foreach($ContinueTime as $ct)
{
	$ct['contime']+=1;
}
//进入时间的分布
$StartTimeSql = "SELECT count(id) as num, (start_time DIV 3600) as start_hour FROM ".T_LOG_SCENE_WAR." $where GROUP BY start_hour ";
$StartTime = GFetchRowSet($StartTimeSql);

foreach($StartTime as $k=>$st)
{
	$st['start_hour'] *=3600;
	$StartTime[$k]['start_from']=date("Y-m-d H", $st['start_hour']);
}

}
//-------------------------------------------------------
	
$smarty->assign('start',$start);
$smarty->assign('end',$end);
$smarty->assign('fb_list',$fb_list);
$smarty->assign('fb_type',$fb_type);
$smarty->assign('SingleTimes',$SingleTimes);
$smarty->assign('PeopleTimes',$PeopleTimes);
$smarty->assign('TeamTimes',$TeamTimes);
$smarty->assign('GamerLevel',$GamerLevel);
$smarty->assign('ContinueTime',$ContinueTime);
$smarty->assign('StartTime',$StartTime);

$smarty->display('module/stat/scene_war_stat.tpl');

//-------------------local function ------------------------

