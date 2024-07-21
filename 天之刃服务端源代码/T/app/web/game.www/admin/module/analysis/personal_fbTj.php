<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';


include_once SYSDIR_ADMIN.'/class/log_gold_class.php';

$serverOnLineTime = strtotime(SERVER_ONLINE_DATE);
if (!$serverOnLineTime) {
	die('未设置开服日期');
}

$startDate = $_REQUEST['startDate'];
$endDate = $_REQUEST['endDate'];
$startDateTime = strtotime($startDate);
$endDateTime = strtotime($endDate) ? strtotime($endDate)+86399 : false;

if (!$startDateTime || !$endDateTime ) {
	$startDateTime = strtotime(date('Y-m-d',strtotime('-6day')));
	$endDateTime = strtotime(date('Y-m-d 23:59:59'));
}
if ($startDateTime < $serverOnLineTime) {
	$startDateTime = $serverOnLineTime;
}
$yesTodayLastTime = strtotime(date('Y-m-d 23:59:59',strtotime('-1day')));

$startDate = date('Y-m-d',$startDateTime);
$endDate = date('Y-m-d',$endDateTime);


$where.= " and start_time >= $startDateTime and start_time <= $endDateTime ";
$sqlBody =
"select z.fb_id,hw.rs,hw.rc,yl.ylrs,yl.ylrc,wl.wlrs,wl.wlrc from 
(select fb_id from t_log_personal_fb group by fb_id) z
left join
(select a.fb_id,a.rs,b.rc from 
(select sum(L.ff) as rs,L.fb_id from (select fb_id,faction_id,count(distinct role_id) as ff from t_log_personal_fb where faction_id=1 and status=0 {$where} group by fb_id,faction_id) L group by L.fb_id) a left join
(select sum(T.ff) as rc,T.fb_id from (select fb_id,faction_id,count(role_id) as ff from t_log_personal_fb where faction_id=1 and status=0 {$where} group by fb_id,faction_id) T group by T.fb_id) b on a.fb_id = b.fb_id) hw on z.fb_id = hw.fb_id
left join 
(select c.fb_id,c.rs as ylrs,d.rc as ylrc from 
(select sum(L.ff) as rs,L.fb_id from (select fb_id,faction_id,count(distinct role_id) as ff from t_log_personal_fb where faction_id=2 and status=0 {$where} group by fb_id,faction_id) L group by L.fb_id) c left join
(select sum(T.ff) as rc,T.fb_id from (select fb_id,faction_id,count(role_id) as ff from t_log_personal_fb where faction_id=2 and status=0 {$where} group by fb_id,faction_id) T group by T.fb_id) d on c.fb_id = d.fb_id) yl on z.fb_id = yl.fb_id
left join
(select a.fb_id,a.rs as wlrs,b.rc as wlrc from 
(select sum(L.ff) as rs,L.fb_id from (select fb_id,faction_id,count(distinct role_id) as ff from t_log_personal_fb where faction_id=3 and status=0 {$where} group by fb_id,faction_id) L group by L.fb_id) a left join
(select sum(T.ff) as rc,T.fb_id from (select fb_id,faction_id,count(role_id) as ff from t_log_personal_fb where faction_id=3 and status=0 {$where} group by fb_id,faction_id) T group by T.fb_id) b on a.fb_id = b.fb_id) wl
on z.fb_id = wl.fb_id";
$rsPersonalFB = GFetchRowSet($sqlBody);

foreach ($rsPersonalFB as &$row)
{
	$totalrs = $row['rs']+$row['ylrs']+$row['wlrs'];
	$totalrc = $row['rc']+$row['ylrc']+$row['wlrc'];
	$row['scount'] = $totalrs."/".$totalrc;
	$row['hwrcrs'] = $row['rs']."/".$row['rc'];
	$row['ylrcrs'] = $row['ylrs']."/".$row['ylrc'];
	$row['wlrcrs'] = $row['wlrs']."/".$row['wlrc'];
}
$dateStrPrev = strftime("%Y-%m-%d", $startDateTime - 86400);
$dateStrToday = strftime("%Y-%m-%d");
$dateStrNext = strftime("%Y-%m-%d", $endDateTime + 86400);

$data = array(
	'sqlBody' => $sqlBody,
	'startDate' => $startDate,
	'endDate' => $endDate,
	"dateStrPrev"=> $dateStrPrev,
	"dateStrToday"=> $dateStrToday,
	"dateStrNext"=> $dateStrNext,
	'rsPersonalFB' => $rsPersonalFB,
	"serverOnLineTime"=> SERVER_ONLINE_DATE,
);
$smarty->assign($data);
$smarty->display("module/analysis/personal_fbTj.tpl");
exit();