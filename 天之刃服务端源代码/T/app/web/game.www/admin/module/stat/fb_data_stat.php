<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
include_once SYSDIR_ADMIN . "/include/dict.php";

$action = trim($_GET['action']);
$action = $action ? $action : 'dmyx';

$start = SS($_REQUEST['start']);
$end = SS($_REQUEST['end']);
if(empty($start)) $start = date('Y-m-d');
if(empty($end)) $end = date('Y-m-d');
$startstamp = strtotime($start);
$endstamp = strtotime($end) + 24*60*60-1;


if ('dmyx' == $action) {
	$where="TRUE";
	$where1 =$where. " AND `mtime` > $startstamp AND `mtime` < $endstamp ";
	$where2 =$where. " AND `start_time` > $startstamp AND `start_time` < $endstamp ";
	//参与人数统计
	$joinsql =
		"SELECT day,all_count,active_20,round((all_count / active_20)*100) as rate
		FROM 
		(select DATE_FORMAT(FROM_UNIXTIME(mtime),'%Y-%m-%d') as act_day,active_20 
		FROM t_stat_loyal_user WHERE {$where1} ) act,
		
		(SELECT DATE_FORMAT(FROM_UNIXTIME(start_time),'%Y-%m-%d') as day,count(DISTINCT role_id) as all_count 
		FROM `t_log_personal_fb` where {$where2} GROUP BY `day`) fb
		
		WHERE act.act_day=fb.day ";
	$joinlist = GFetchRowSet($joinsql);
	
	//每关进入次数统计
	$insql = "SELECT count(id) as times,fb_id FROM t_log_personal_fb WHERE {$where2} GROUP BY fb_id";
	$inlist=GFetchRowSet($insql);
	foreach($inlist as $k=>$v)
	{
		$inlist[$k]['level']=floor($v['fb_id']/10)."章".fmod($v['fb_id'],10)."关";
	}
	
	//元宝消耗购买次数统计
	$paysql="SELECT count(id) as pay_num, (gold_bind + gold_unbind) as gold FROM t_log_use_gold WHERE {$where1} AND mtype=3029 GROUP BY gold ";
	$paylist = GFetchRowSet($paysql);
	
	//时间范围内玩家打副本次数
	$timessql="select COUNT(role_id) AS times_num,count FROM " .
			"(SELECT count(role_id) as count,role_id  FROM t_log_personal_fb WHERE {$where2} GROUP BY role_id) as a " .
			"GROUP BY a.count ";
	$timeslist=GFetchRowSet($timessql);
	
	$data=array(
		'start'=>$start,
		'end'=>$end,
		'joinlist'=>$joinlist,
		'inlist'=>$inlist,
		'paylist'=>$paylist,
		'timeslist'=>$timeslist,
	);
	$smarty->assign($data);
	$smarty->display ( 'module/stat/dmyx_fb_data_stat.tpl' );
}
else if('pyh' == $action) {
	$fb_type=1;
	$where="TRUE";
	$where1 =$where. " AND `mtime` > $startstamp AND `mtime` < $endstamp ";
	$where2 =$where. " AND `start_time` > $startstamp AND `start_time` < $endstamp AND fb_type={$fb_type} ";
	//副本参与率
	$joinsql =
		"SELECT day,all_count,active_20,round((all_count / active_20)*100) as rate
		FROM 
		(select DATE_FORMAT(FROM_UNIXTIME(mtime),'%Y-%m-%d') as act_day,active_20 
		FROM t_stat_loyal_user WHERE {$where1} ) act,
		(SELECT DATE_FORMAT(FROM_UNIXTIME(start_time),'%Y-%m-%d') as day,count(DISTINCT role_id) as all_count 
		FROM `t_log_scene_war` where {$where2} GROUP BY `day`) fb
		WHERE act.act_day=fb.day ";
	$joinlist = GFetchRowSet($joinsql);
	
	//参与次数
	$insql = "SELECT count(id) as in_num,times FROM t_log_scene_war WHERE {$where2} GROUP BY times ";
	$inlist = GFetchRowSet($insql);
	
	//副本购买次数
	$paysql = "SELECT count(id) as pay_num,times FROM t_log_scene_war WHERE {$where2} AND times>10 GROUP BY times";
	$paylist = GFetchRowSet($paysql);
	$data=array(
		'start'=>$start,
		'end'=>$end,
		'joinlist'=>$joinlist,
		'inlist'=>$inlist,
		'paylist'=>$paylist,
	);
	
	$smarty->assign($data);
	$smarty->display ( 'module/stat/pyh_fb_data_stat.tpl' );
}
else if('dtfd'==$action){
	$fb_type=2;
	$where="TRUE";
	$where .= " AND `start_time` > $startstamp AND `start_time` < $endstamp AND fb_type={$fb_type} ";
	
	$num_sql="SELECT day,
			SUM(num1) num1,
			SUM(num2) num2,
			SUM(num3) num3
		  FROM
			(SELECT day,
				(case when fb_level=1 then all_count else 0 end) num1,
				(case when fb_level=2 then all_count else 0 end) num2,
				(case when fb_level=3 then all_count else 0 end) num3
			FROM
				(SELECT DATE_FORMAT(FROM_UNIXTIME(start_time),'%Y-%m-%d') as day,count(DISTINCT role_id) as all_count ,fb_level 
				FROM t_log_scene_war 
				WHERE {$where}
				GROUP BY day,fb_level) 
			AS a) 
		 as b
		 GROUP BY day ";
	$num_list = GFetchRowSet($num_sql);
	
	
	$times_sql="SELECT day,
			SUM(times1) times1,
			SUM(times2) times2,
			SUM(times3) times3
		  FROM
			(SELECT day,
				(case when fb_level=1 then all_count else 0 end) times1,
				(case when fb_level=2 then all_count else 0 end) times2,
				(case when fb_level=3 then all_count else 0 end) times3
			FROM
				(SELECT DATE_FORMAT(FROM_UNIXTIME(start_time),'%Y-%m-%d') as day,count(role_id) as all_count ,fb_level 
				FROM t_log_scene_war 
				WHERE {$where}
				GROUP BY day,fb_level) 
			AS a) 
		 as b
		 GROUP BY day ";
	$times_list = GFetchRowSet($times_sql);
	//print_r($times_list);
	$all_num_sql="SELECT count(DISTINCT role_id) as all_num FROM t_log_scene_war WHERE {$where} ";
	$all_num = GFetchRowOne($all_num_sql);

	$all_times_sql="SELECT count(id) as all_times FROM t_log_scene_war WHERE {$where} ";
	$all_times = GFetchRowOne($all_times_sql);
	
	$login_num_sql="SELECT  DATE_FORMAT(FROM_UNIXTIME(log_time),'%Y-%m-%d') as day,count(DISTINCT role_id) as login_num FROM t_log_login WHERE level >= 35 AND `log_time` > $startstamp AND `log_time` < $endstamp GROUP BY day ";
	$login_num = GFetchRowSet($login_num_sql);
	$list= array();
	foreach($num_list as $k => $v)
	{
			
			$list[$v['day']]['day']=$v['day'];
			$list[$v['day']]['num1']=$v['num1'];
			$list[$v['day']]['num2']=$v['num2'];
			$list[$v['day']]['num3']=$v['num3'];
			$list[$v['day']]['times1']=$times_list[$k]['times1'];
			$list[$v['day']]['times2']=$times_list[$k]['times2'];
			$list[$v['day']]['times3']=$times_list[$k]['times3'];
			//$list[$v['day']]['login_num']=$login_num[$k]['login_num'];
	}
	foreach($login_num as $k1=>$v1)
	{
		if(!empty($list[$v1['day']]))
			$list[$v1['day']]['login_num']=$v1['login_num'];
	}
	
	
	$data=array(
		'all_num'=>$all_num['all_num'],
		'all_times'=>$all_times['all_times'],
		'start'=>$start,
		'end'=>$end,
		'list'=>$list,
	);
	$smarty->assign($data);
	$smarty->display ( 'module/stat/dtfd_fb_data_stat.tpl' );
}
exit();


?>