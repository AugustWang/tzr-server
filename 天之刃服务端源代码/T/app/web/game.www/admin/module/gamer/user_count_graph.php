<?php 
define('IN_ODINXU_SYSTEM', true);
include "../../../config/config.php";
include SYSDIR_ADMIN.'/include/global.php';
global $smarty,$auth;
$auth->assertModuleAccess(__FILE__);
define('LEN_PER_PAGE', 20);


/*
<td>日期</td>				
<td>活跃用户数</td>
<td>忠诚用户数</td>
<td>最大在线</td>
<td>平均在线</td>
<td>当天新注册用户数</td>
<td>全部注册用户数</td>
*/

list($start,$end) = sanitizeTimeSpan($_REQUEST['start'],$_REQUEST['end']);

if (!isset($_REQUEST['start'])){
	$start = $end - 7*60*60*24;
}


$pageId = intval($_REQUEST['page']) or $pageId = 1; 
$startIndex = ($pageId-1)*LEN_PER_PAGE;

$sql = "select SQL_CALC_FOUND_ROWS mtime,active,loyal,max_online,avg_online,new_user,total_user from t_stat_loyal_user where mtime >= $start and mtime <= $end limit $startIndex,".LEN_PER_PAGE ;
$result = GFetchRowSet($sql);

$indexAry = array('active','loyal','max_online','avg_online','new_user','total_user');
$max = array();
foreach ($result as &$item){
	$item['date'] = date('m-d',$item['mtime']);
	$item['weekend'] = judgeIfWeekend($item['mtime']);	
	$item['server'] = checkServerday($item['mtime']);
		
	foreach ($indexAry as $idx){
		if (!isset($max[$idx])){
			$max[$idx] = 0;
		}
		$max[$idx] = max($max[$idx],$item[$idx]);		
	}	
}


//height = 120px*t/max
foreach ($max as &$item){
	$item = $item/120;
}

list($startStr,$endStr) = array(date('Y-m-d',$start),date('Y-m-d',$end));

$count = GFetchRowOne("select FOUND_ROWS() as num ");
$count = $count['num'];

$smarty->assign(
array(
'max'=>$max,
'count'=>$count,
'result'=>$result,
'start'=>$startStr,
'end'=>$endStr
));
$smarty->display('module/gamer/user_count_graph.tpl');

function checkServerday($mtime){
	$diff = intval(($mtime -  strtotime(SERVER_ONLINE_DATE))/(60*60*24));
	if( $diff >= 0){
		$diff++;
	}
	return $diff;
}