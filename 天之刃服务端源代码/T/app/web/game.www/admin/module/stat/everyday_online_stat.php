<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;
define('LEN_PER_PAGE', 30);
$auth->assertModuleAccess(__FILE__);

$start = strtotime($_REQUEST['start']) or $start = GetTime_Today0();
$end = strtotime($_REQUEST['end']) or $end = GetTime_Today0();
$end += 60*60*24-1;
$page = intval($_REQUEST['page']) or $page = 1;

if (!isset($_REQUEST['end'])){
	$start = $end - 7*24*60*60;
}

$startIndex = ($page-1)*LEN_PER_PAGE;


$login = array();
$paid = array();
for ($itr = $start;$itr <= $end; $itr += 24*60*60 ){
	$cur = strtotime(date('Y-m-d',$itr));
	$paid[] = getPaidData($cur);
	$login[] = getLoginData($cur);
}



$data = array();
for ($itr = 0; $itr < count($paid);$itr++){
	$data[] = array(
		'date'=>$paid[$itr]['label'],
		'weekend'=>$paid[$itr]['weekend'],
		'cid'=>$login[$itr]['cid'],
		'crid'=>$login[$itr]['crid'],
		'cip'=>$login[$itr]['cip'],
		'login'=>$paid[$itr]['login'],
		'loss'=>$paid[$itr]['loss']
	);
}



//generate max
$max = array(
'cid'=>0,
'crid'=>0,
'cip'=>0,
'login'=>0,
'loss'=>0,
);




$idxAry = array('cid','crid','cip','loss','login');
foreach ($data as $item){
	foreach ($idxAry as $idx){
		$max[$idx] = max($item[$idx],$max[$idx]);
	}
}
foreach ($max as &$item){
	$item = $item/120;
}



$smarty->assign(array(
	'start'=>date('Y-m-d',$start),
	'end'=>date('Y-m-d',$end),
	'data'=>$data,
	'max'=>$max
));

$smarty->display('module/stat/everyday_online_stat.tpl');





function getLoginData($start){
	$end = $start +60*60*24;
	$sql = "select count(distinct id) as cid, count(distinct role_id ) as crid,count(distinct login_ip) as cip
	from t_log_login where log_time >= $start and log_time <= $end ";
	return GFetchRowOne($sql);
}

/*
$where = " where log_time >= $start and log_time <= $end ";
$sql = "select SQL_CALC_FOUND_ROWS count(distinct id) as cid,count( distinct role_id) as crid,count( distinct login_ip) as cip ,
floor(log_time/86400) as d from  t_log_login $where group by d limit $startIndex,".LEN_PER_PAGE;
$result = GFetchRowSet($sql);
$length = GFetchRowOne("select FOUND_ROWS() as num");
$length = $length['num'];
*/


/**
 * 充值信息综合
 */
function getPaidData($start){
	$ary['login'] = getLatestThreeDaysOnline($start+60*60*24);
	$ary['loss'] = getPaidLoss($start, $start+60*60*24);
	$ary['label'] = date('Y-m-d',$start);
	$ary['weekend'] = judgeIfWeekend($start+1);
	return $ary;
}




/**
 * 付费用户某一天的停留数
 * @param $start
 * @param $end
 */
function getPaidLoss($start,$end){
	$sql = "SELECT count(distinct pay.role_id) as num from db_role_ext_p as ext,db_pay_log_p pay where ext.role_id = pay.role_id 
		and ext.last_login_time > $start and ext.last_login_time < $end ";
	$result = GFetchRowOne($sql);	
	return $result['num'];
}

/**
 * 
 * 近三日有登录信息的付费玩家
 * @param unknown_type $end
 */
function getLatestThreeDaysOnline($end){
	$start = $end - 60*60*24*3;
	$sql = "SELECT count(distinct login.role_id) as num from t_log_login login ,db_pay_log_p pay 
	where pay.role_id = login.role_id and log_time > $start and log_time < $end";
	$result = GFetchRowOne($sql);
	return $result['num'];
}







