<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
global $auth,$smarty,$dictFaction;
$auth->assertModuleAccess(__FILE__);

/*
final_state:
17   国运取消
7    普通取消
16   国运成功
6    普通成功
13   超时
3    超时
12   国运被截
2    被劫
14   国运超时被删除
4    超时被删除
*/


$start = strtotime($_REQUEST['start']);
$end = strtotime($_REQUEST['end']);
$start = $start ? $start : strtotime(date('Y-m-d',strtotime('-7day'))); //默认取7天前
$start = $start < strtotime(SERVER_ONLINE_DATE) ?  strtotime(SERVER_ONLINE_DATE) : $start ; //若开始日期在开服日期之前,则取开服日期为开始日期
$end = $end ? $end : strtotime(date('Y-m-d'));  //默认取今天
$end = $end < $start ? $start : $end;  //若结束日期在开始日期之前,则设置结束日期与开始日期相同.
echo $diffDay = abs($end - $start)/(3600*24) + 1 ; //相差天数.
$end += 86400 - 1; //算到23:59:59
$startStr = date('Y-m-d',$start);
$endStr = date('Y-m-d',$end);
$ymdStart = date('Ymd',$start);
$ymdEnd = date('Ymd',$end);


$arrResult = array(); //初始化结果,这样即使当前没数据也会显示0,而不是空
for ($i=0; $i<$diffDay; $i++){
	$datetime = $end - 86400 * $i;
	$tmp = array(
		'date' => date('Y-m-d',$datetime),
		'active'=>0, //当前活跃用户数
		'gyrs'=>0, //国运人数(参与国运的人数而非人次)
		'active_rate'=>0, //活跃用户参与国运的比例
		'one'=>0, //国运报名一次的人数
		'two'=>0,//国运报名两次的人数
		'three'=>0, //国运报名三次的人数
		'one_rate'=>0, //国运报名一次的人数
		'two_rate'=>0,//国运报名两次的人数
		'three_rate'=>0 //国运报名三次的人数
	);
	$arrResult[date('Ymd',$datetime)] = $tmp;
}

// ========= 查出当天活跃用户
$active_standard = 7*60; //活跃用户: 最近7天在线时间7小时以上.
$sqlActive = " select count(*) as num, ymd from t_log_active_user_daily 
				where ymd >= {$ymdStart} and ymd<= {$ymdEnd} and avg_online_time >= {$active_standard} group by ymd 
				";
$rsActive = GFetchRowSet($sqlActive);

foreach ( $rsActive as &$row){
	$arrResult[$row['ymd']]['active'] = intval($row['num']);
}
//==============

//========= 查出当天参与国运的人数
$sqlGYRS = "SELECT COUNT( DISTINCT `role_id` ) AS num,  FROM_UNIXTIME(start_time, '%Y%m%d') AS ymd  
			FROM t_log_personal_ybc 
			WHERE `start_time` BETWEEN {$start} AND  {$end} AND `final_state` > 10 
			GROUP BY ymd order by ymd desc ";
$rsGYRS = GFetchRowSet($sqlGYRS);

foreach ($rsGYRS as &$row){

	$arrResult[$row['ymd']]['gyrs'] = intval($row['num']);
	$arrResult[$row['ymd']]['active_rate'] = $arrResult[$row['ymd']]['active'] > 0 ? round($arrResult[$row['ymd']]['gyrs'] * 100 / $arrResult[$row['ymd']]['active'],1) : 0;
}

//============

//=========查出国运参与情况,分别参加1,2,3次的人各有多少.
$sqlGY = "SELECT COUNT(`role_id`) AS num, times, ymd 
		  FROM( 
				SELECT COUNT(`id`) AS times, role_id, FROM_UNIXTIME(`start_time`,'%Y%m%d') AS ymd 
				FROM t_log_personal_ybc WHERE final_state > 10 AND start_time BETWEEN {$start} AND  {$end}  
				GROUP BY ymd, role_id ) AS tmp_table 
		  GROUP BY ymd, times ORDER BY ymd DESC  ";
$rsGY = GFetchRowSet($sqlGY);

foreach ($rsGY as &$row){
	//只计国运报名1到3次的,其他次数则是不正确的,忽略掉.

	$flag = $arrResult[$row['ymd']]['gyrs'] > 0;
	if (3==$row['times']) {
		$arrResult[$row['ymd']]['three'] = intval($row['num']);
		$arrResult[$row['ymd']]['three_rate'] = $flag ? round($arrResult[$row['ymd']]['three'] * 100 / $arrResult[$row['ymd']]['gyrs'],1) : 0;
		continue;
	}
	if (1==$row['times']) {
		$arrResult[$row['ymd']]['one'] = intval($row['num']);
		$arrResult[$row['ymd']]['one_rate'] = $flag ? round($arrResult[$row['ymd']]['one'] * 100 / $arrResult[$row['ymd']]['gyrs'],1) : 0;
		continue;
	}
	if (2==$row['times']) {
		$arrResult[$row['ymd']]['two'] = intval($row['num']);
		$arrResult[$row['ymd']]['two_rate'] = $flag ? round($arrResult[$row['ymd']]['two'] * 100 / $arrResult[$row['ymd']]['gyrs'],1) : 0;
		continue;
	}

}
//================

$smarty->assign(array(
	'arrResult'=>$arrResult,
	'start'=>$startStr,
	'end'=>$endStr,
	'today' => date('Y-m-d'),
	'prevDate' => date('Y-m-d',$start-86400),
	'nextDate' => date('Y-m-d',$start+86400),
));
$smarty->display('module/stat/faction_trans.tpl');
