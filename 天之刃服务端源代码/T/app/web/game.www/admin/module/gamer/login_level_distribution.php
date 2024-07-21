<?php
//@author natsuki lolicon@mail.az
//登录用户等级分布
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
global $auth,$smarty;


//三天前
$start = $_REQUEST['start'] or $start = date('Y-m-d',time() - 3*60*60*24);
$end = $_REQUEST['end'] or $end = date('Y-m-d',time());





$s = strtotime($start);
$e = strtotime($end)+24*60*60;



$sql = "select floor(level/5) as new_level,count(id) as nid ,count(role_id) as nrid,count(login_ip) as nip from t_log_login where log_time >= $s and 
log_time <= $e group by new_level";

$result = GFetchRowSet($sql);
$result = flattenResult($result);
$max = getMax($result);



$smarty->assign(
array(
'result'=>$result,
'max'=>$max,
'start'=>$start,
'end'=>$end,
'pre'=>date('Y-m-d',$s-24*60*60),
'next'=>date('Y-m-d',$s+24*60*60)
)
);

$smarty->display('module/gamer/login_level_distribution.tpl');

function flattenResult($result){
	foreach ($result as &$item){
		$item['level'] = $item['new_level'];
		$item['label'] = ($item['new_level']*5)."~".($item['new_level']*5+5);		
	}
	return $result;
}


function getMax($ary){
	$max = 0;
	foreach ($ary as $item){
		$max = max($max,$item['nid']);
	}
	return $max/120;
}

