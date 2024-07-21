<?php
//@author natsuki lolicon@mail.az
//活跃用户等级分布
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
global $auth,$smarty;



//默认显示一周之前的
$start = SS(trim($_REQUEST['start'])) or $start = date('Y-m-d',time()-3*60*60*24 );
$end = SS(trim($_REQUEST['end'])) or $end = date('Y-m-d',time());


$startYmd = date('Ymd',strtotime($start));
$endYmd = date('Ymd',strtotime($end));
$sql = "select count(id) as cid,count(distinct role_id) as crid ,floor(level/5) as new_level,ymd from t_log_active_user_daily
where ymd >= $startYmd and ymd <= $endYmd group by new_level,ymd";




$result = GFetchRowSet($sql);
list($max,$dailyData) = flattenByDay($result);
$max['cid'] =  $max['cid'] / 120;
$max['crid'] = $max['crid'] /120;

$smarty->assign(array(
'start'=>date('Y-m-d',strtotime($start)),
'end'=>date('Y-m-d',strtotime($end)),
'data'=>$dailyData,
'cid'=>$max['cid'],
'crid'=>$max['crid'],
'max'=>$max,
'prev'=>date('Y-m-d',strtotime($start)-60*60*24),
'succ'=>date('Y-m-d',strtotime($start)+60*60*24)
));
$smarty->display('module/gamer/active_user_level_distribution.tpl');


function flattenByDay($result){
	$max = array('cid'=>0,'crid'=>0) ;
	$ret = array();
	foreach ($result as $item) {
		$item['ymd'] = date('Y-m-d',strtotime($item['ymd']));

		if (!isset($ret[$item['ymd']])) {
			$ret[$item['ymd']] = array();
		}
		$ret[$item['ymd']][$item['new_level']] = array(
			'cid'=>$item['cid'],
			'crid'=>$item['crid'],
			'label'=>"[".($item['new_level']*5)."~".($item['new_level']*5+5).")",
		);		
		$max['cid'] = max($max['cid'],$item['cid']);
		$max['crid'] = max($max['crid'],$item['crid']);
	}
	return array($max,$ret);
}








?>