<?php
/*
 * Author: odinxu, MSN: odinxu@hotmail.com
 * 2008-9-12
 * 列出所有注册用户
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/admin_item_class.php';


if ( !isset($_REQUEST['dateStart']))
	$dateStart = SERVER_ONLINE_DATE;
else
	$dateStart  = trim(SS($_REQUEST['dateStart']));

if ( !isset($_REQUEST['dateEnd']))
	$dateEnd = strftime ("%Y-%m-%d", time() );
else
	$dateEnd = trim(SS($_REQUEST['dateEnd']));

$dateStartStamp = strtotime($dateStart . ' 0:0:0') or $dateStartStamp = GetTime_Today0();
$dateEndStamp   = strtotime($dateEnd . ' 23:59:59') or $dateEndStamp = time();

$dateStartStr = strftime ("%Y-%m-%d", $dateStartStamp);
$dateEndStr   = strftime ("%Y-%m-%d", $dateEndStamp);




$dayArrM = range(0, 30);
$dayArrM[] = -30;
$dayArrName = array(
	"不足24小时",	"1天",	"2天",	"3天",	"4天",
	"5天",	"6天",	"7天",	"8天",	"9天",
	"10天",	"11天",	"12天",	"13天",	"14天",
	"15天",	"16天",	"17天",	"18天",	"19天",
	"20天",	"21天",	"22天",	"23天",	"24天",
	"25天",	"26天",	"27天",	"28天",	"29天",
	"30天",	"30天以上",
	);



$dayArrMSec = array(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,120,180,240,300,360,420,480,540,600,900,1200,1440);

$dayArrNameSec = array( '不足1分钟','1-2分钟','2-3分钟','3-4分钟','4-5分钟','5-6分钟','6-7分钟','7-8分钟','8-9分钟','9-10分钟','10-11分钟','11-12分钟','12-13分钟','13-14分钟','14-15分钟','15-16分钟','16-17分钟','17-18分钟','18-19分钟','19-20分钟','20-25分钟','25-30分钟','30-35分钟','35-40分钟','40-45分钟','45-50分钟','50-55分钟','55-60分钟',
'60-65分钟','65-70分钟','70-75分钟','75-80分钟','80-85分钟','85-90分钟',
        '1.5-2小时','2-3小时','3-4小时','4-5小时','5-6小时','6-7小时','7-8小时','8-9小时','9-10小时','10-15小时','15-20小时','20-24小时');


$dayArrCount = array();
$dayArrCountSec = array();

//总人数

//30k

$sql = "SELECT count(*) as total from db_role_base_p base,db_role_ext_p ext where base.role_id = ext.role_id and 
create_time >= {$dateStartStamp} 
and create_time <= {$dateEndStamp} and last_offline_time >= create_time " ;


/*
$sql = "SELECT COUNT(*) as total FROM `tuser` " .
	"where `reg_time` >= {$dateStartStamp} AND `reg_time` <= {$dateEndStamp} ";
*/
	
$_rs = GFetchRowOne($sql);
$total = intval($_rs['total']);


$sql  = "SELECT FLOOR((last_offline_time - create_time)/86400) as DAYS, count(*) as NUM from 
		db_role_base_p base,db_role_ext_p ext where base.role_id = ext.role_id and create_time >= {$dateStartStamp} and 
			create_time <= {$dateEndStamp} group by FLOOR( (last_offline_time-create_time)/86400)";

//头30天的人数
/*
$sql = "SELECT FLOOR((`last_offline_time` - `reg_time`)/86400) as DAYS, count(*) as NUM FROM `tuser` " .
	"where `reg_time` >= {$dateStartStamp} AND `reg_time` <= {$dateEndStamp} " .
	"group by FLOOR((`last_offline_time` - `reg_time`)/86400);";
	*/
$_rs = GFetchRowSet($sql);
if(!is_array($_rs))
	$_rs = array();
$rs = array();
foreach($_rs as $r) {
	$days = intval($r['DAYS']);
	if($days < 0)
		continue;
	$rs[$days] += intval($r['NUM']); 
}
foreach($dayArrM as $idx => $dv){
	$num = 0;
	foreach($rs as $days => $_num)
		if($dv >= 0 && $days == $dv
			|| $dv < 0 && $days > -$dv //负数: "大于这个绝对值", -30:大于30的
			)
			$num += $_num;
	$dayArrCount[$idx] = $num;
}
foreach($dayArrCount as $key => $val ){
	$dayArrCount[$key] = array();
	$dayArrCount[$key]['lostplayer'] = $val;
	if ($total == 0) {
		$dayArrCount[$key]['percentLost'] = 0;
	}else {
		$dayArrCount[$key]['percentLost'] = round($val/$total * 100, 2);	
	}	
}


//每分钟分布

$sql = "SELECT FLOOR((`last_offline_time`-`create_time`)/60) as MINUTES,count(*) as NUM from db_role_base_p base ,db_role_ext_p ext
	where  base.role_id = ext.role_id and create_time > {$dateStartStamp} and create_time < {$dateEndStamp} 
group by  FLOOR(( `last_offline_time` - create_time)/60) having MINUTES <= 1440 and MINUTES >= 0 ;";






//头24小时内
/*
$sql = "SELECT FLOOR((`last_offline_time` - `reg_time`)/60) as MINUTES, count(*) as NUM FROM `tuser` " .
	"where `reg_time` >= {$dateStartStamp} AND `reg_time` <= {$dateEndStamp} " .
	"group by FLOOR((`last_offline_time` - `reg_time`)/60) having MINUTES <= 1440 and MINUTES >= 0;";
	*/
	
$_rs = GFetchRowSet($sql);
if(!is_array($_rs))
	$_rs = array();
	
	
$rs = array();
foreach($_rs as $r) {
	$minutes = intval($r['MINUTES']);
	if($minutes < 0)
		continue;

	$rs[$minutes] += intval($r['NUM']);
}


$minNum = array();
foreach ($_rs as $item) {
	$minNum[intval($item['MINUTES'])] =  $item['NUM'];
}

//dayArrMSec
$numOfEachMinLevel = array();


//0,5,17,133
foreach ($minNum as $min => $num) {
	for ($i=0; $i < count($dayArrMSec); $i++) { 
		if ($min>=$dayArrMSec[$i] && $min<$dayArrMSec[$i+1]) {
			 $numOfEachMinLevel[$i] += $num;
				break;
		}
	}
}





//此时  numOfEachMinLevel 是 5,7,8之类的,对应label在上面dayArrNameSec,dayArrNameSec应该少一个元素



$littleSum = array_sum($numOfEachMinLevel);
$newLabelValue = array();



foreach ($dayArrNameSec as $id => $label) {
if ($littleSum == 0){
	$per = 0.00;
}else{
	$per = number_format(($numOfEachMinLevel[$id] / $littleSum)*100,2);
}

	
	
	
	
$newLabelValue[$id]  = array(
	'label'=>$label,
	'num'=>$numOfEachMinLevel[$id],
	'percentage'=>$per
		);
}




foreach($dayArrMSec as $idx => $dv){
	$num = 0;
	foreach($rs as $minutes => $_num)
		if($dv >= 0 && $minutes >= $dv)
			if((isset($dayArrMSec[$idx + 1]) && $minutes < $dayArrMSec[$idx + 1])
				|| !isset($dayArrMSec[$idx + 1]))
				$num += $_num;
				
	//$dayArrCountSec[$idx] = $num;
	$dayArrCountSec[$idx] = $_num;
}



foreach($dayArrCountSec as $key => $val ){
	$dayArrCountSec[$key] = array();
	$dayArrCountSec[$key]['lostplayer'] = $val;
	if ($total == 0) {
		$dayArrCountSec[$key]['percentLost']  = 0;
	}else {
		$dayArrCountSec[$key]['percentLost'] = round($val/$total * 100, 2);
	}
}



$smarty->assign("dayArrName", $dayArrName);
$smarty->assign("dayArrCount", $dayArrCount);
$smarty->assign('newLabelValue',$newLabelValue);
$smarty->assign("dayArrNameSec", $dayArrNameSec);
$smarty->assign("dayArrCountSec", $dayArrCountSec);

$smarty->assign("type", $type);
$smarty->assign("dateStart", $dateStartStr);
$smarty->assign("dateEnd", $dateEndStr);

$smarty->display("module/gamer/lost_user_event.tpl");
exit;

