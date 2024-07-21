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

$sql = "select SQL_CALC_FOUND_ROWS mtime,active,loyal,max_online,avg_online,new_user,total_user from t_stat_loyal_user where mtime >= $start and mtime <= $end  order by mtime desc limit $startIndex,".LEN_PER_PAGE ;
$result = GFetchRowSet($sql);
foreach ($result as &$item){
	$item['date'] = date('Y-m-d',$item['mtime']);
	$item['weekend'] = judgeIfWeekend($item['mtime']);		
}


list($startStr,$endStr) = array(date('Y-m-d',$start),date('Y-m-d',$end));

$count = GFetchRowOne("select FOUND_ROWS() as num ");
$count = $count['num'];
$pager = renderPageIndicator('user_count.php',$pageId,$count,LEN_PER_PAGE,array('start'=>$startStr,'end'=>$endStr),'page');


foreach ($result as &$item){
	$item['date'] = date('m-d',strtotime("-1 day",strtotime($item['date'])));
}



$smarty->assign(
array(
	'count'=>$count,
	'pager'=>$pager,
	'result'=>$result,
	'start'=>$startStr,
	'end'=>$endStr
));

$smarty->display('module/gamer/user_count.tpl');
