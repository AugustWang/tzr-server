<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
global $auth,$smarty,$dictFaction;
$auth->assertModuleAccess(__FILE__);
define(LENGTH_PER_PAGE, 40);



/**
 * Requirement:
 * 讨伐敌营后台日志：
（1）单个队伍完成副本的时间
（2）每个国家在**~**（日期）、&&~&&（时间段）参加副本的总队数（记录队长）、进入副本总人次
（3）固定的时间段里，未开启副本数为0的时间
 */

/**
 * id,faction_id,map_id,map_name,npc_id,start_time,status,monster_level
 * role_names,numbers,end_time,role_ids,out_ids,out_numbers
 */

$finalStatus = array(
	1=>'进入',
	2=>'完成',
	3=>'其他'
);

//1.list each
$page = intval($_REQUEST['page']) or $page = 1;

$start = strtotime($_REQUEST['start']) or $start = GetTime_Today0();
$end = strtotime($_REQUEST['end']) or $end = GetTime_Today0();
$view_type = intval($_REQUEST['view_type']) or $view_type = 1;

//当天时间修改
$end += 24*60*60-1;
 

if ($view_type == 2){
	//国家,小时
	$sql = "select faction_id,sum(in_vwf_number) as num,floor(start_time/3600) as 
	mtime from t_log_vwf  where start_time >= $start and start_time <= $end group by faction_id,mtime ORDER BY mtime DESC ";
	$graph = GFetchRowSet($sql);
	$times = array();
	$max = 0;
	foreach($graph as $item){
		if (!isset($times[intval($item['mtime'])])){
			$times[intval($item['mtime'])] = array();
		}
		//每个国家
		$times[intval($item['mtime'])][intval($item['faction_id'])] = $item['num'];
		//总共
		$times[intval($item['mtime'])]['all'] += $item['num'];
		$times[intval($item['mtime'])]['time'] = date("m-d H",intval($item['mtime']*3600));
		//取最大
		if ($times[intval($item['mtime'])]['all'] > $max ){
			$max = $times[intval($item['mtime'])]['all'];
		}
	}	
	$smarty->assign('max',$max);
	$smarty->assign("graph",$times);
	
}
$smarty->assign('view_type',$view_type);



//$period = intval($_REQUEST['period']);
/*
//每日的stat列表
if (isset($_REQUEST['stat'])){
	$sql = "select count(*) as num,sum(in_vwf_number)as mem_num,faction_id,day,period from t_log_vwf group by day,period,faction_id";	
	$stat_result = GFetchRowSet($sql);
	foreach ($stat_result as &$item){
		$item[] = $item[];
			
		
	}
	$smarty->assign('stat_result',$stat_result);	
}

*/

if ($view_type == 1){
	$where = " where start_time >= $start and start_time <= $end ";
	//时段
	$startIndex = ($page - 1)*LENGTH_PER_PAGE;
	$lengthSql = "select count(*) as num from t_log_vwf $where";  
	$lengthResult = GFetchRowOne($lengthSql);
	$sql = "select * from t_log_vwf $where order by start_time desc limit $startIndex,".LENGTH_PER_PAGE;
	$result = GFetchRowSet($sql);
	foreach ($result as &$item){
		$item['faction_name'] = $dictFaction[intval($item['faction_id'])];
		$item['enter_time'] = date("m-d H:i:s",$item['start_time']);
		$item['final_status'] = $finalStatus[intval($item['status'])];
		$item['monster_lv'] = $item['vwf_monster_level'];
		$item['enter_ids'] = $item['in_vwf_role_ids'];
		$item['enter_num'] = $item['in_vwf_number'];
		$item['enter_names'] = $item['in_vwf_role_names'];
		$item['final_num'] = $item['out_vwf_number'];
		$item['complete_time'] = date('m-d H:i:s',$item['end_time']);
		$item['life_span'] = formatTime($item['end_time']-$item['start_time']);
	}
}


$pager = renderPageIndicator('map_copy_stat.php',$page,intval($lengthResult['num']),LENGTH_PER_PAGE,
array('start'=>date('Y-m-d',$start),'end'=>date('Y-m-d',$end)),'page');

$smarty->assign(array(
'pager'=>$pager,
'result'=>$result,
'start'=>date("Y-m-d",$start),
'end'=>date('Y-m-d',$end),
'total'=>intval($lengthResult['num'])
));

$smarty->display('module/gamer/map_copy_stat.tpl');



/*
	<td><{$item.enter_time}></td>
	<td><{$item.final_status}></td>
	<td><{$item.monster_lv}></td>
	<td><{$item.enter_ids}></td>
	<td><{$item.enter_num}>/<{$item.final_num}></td>
	<td><{$item.complete_time}></td>
*/

function formatTime($sec){
	$hour = intval($sec/(60*60));
	$sec = $sec%(60*60);
	$min = intval($sec/60);
	$sec = $sec%60;
	$literal = '';
	if ($hour > 0){
		$literal .= $hour.'小时';
	}
	if($min > 0){
		$literal .= $min.'分钟';
	}
	$literal .= $sec.'秒';
	return $literal;
	}



