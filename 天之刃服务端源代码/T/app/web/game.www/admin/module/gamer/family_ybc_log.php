<?php
/*
 * 门派拉镖
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
global $auth,$smarty,$dictYbcColor,$dictYbcFinalState;
$auth->assertModuleAccess(__FILE__);

define('NEVER',strtotime('2012-12-20'));
define('FAMILY_YBC_INTERVAL', 3600);


$time = strtotime($_REQUEST['time']) or $time = GetTime_Today0();
$family_name = SS(trim($_REQUEST['family_name']));

$start = $time;
$end = $time + 24*60*60;
$where = " and mtime >= $start and mtime <= $end";

if (strlen($family_name) > 1){
	$family_id = getFamilyId(SS(trim($family_name)));
	$where .= " and family_id = '$family_id' ";
}


$order = " order by mtime desc ";
$sql = "select ybc_no,family_id,mtime,content from t_log_family_ybc where 1=1 $where $order";

$result = GFetchRowSet($sql);

$ybcResult = groupByYbcNo($result);


$preDay = date('Y-m-d',$time-24*60*60);
$postDay = date('Y-m-d',$time+24*60*60);



$smarty->assign(
array(
'today'=>date("Y-m-d",time()),
'preDay'=>$preDay,
'postDay'=>$postDay,
'final_result'=>$ybcResult,
'family_name'=>$family_name,
'time'=>date('Y-m-d',$time)
));

$smarty->display('module/gamer/family_ybc_log.tpl');


//family_id,family_name,ybc_no,start_time,ybc_type,end_time,members
function  parseEachRecord($ele){
	$awarding = array(
		1=>'获得',
		2=>'未获得'
	);
	
	
	$dictFamilyYbcType = array(
		1=>"厚实的镖车",
		2=>"普通的镖车",
		3=>"一般的镖车"
	);

	global  $dictYbcFinalState,$dictYbcColor;
	$start_time = date('Y-m-d H:i:s',$ele['start_time']);
	$end_time = date('Y-m-d H:i:s',$ele['end_time']);
	$ybc_type = $dictFamilyYbcType[intval($ele['ybc_type'])];
	$family_name =  $ele['family_name'];
	$family_id = $ele['family_id'];
	
	//members
	$members = json_decode($ele['members'],true);
	$finalMemberRec = array();
	foreach ($members as $mem){
		$finalMemberRec[] = array(
			'family_name'=>$family_name,
			'start_time'=>$start_time,
			'ybc_type'=>$ybc_type,
			'end_time'=>date("Y-m-d H:i:s",$mem['end_time']),
			'ybc_no'=>$ele['ybc_no'],
			'family_id'=>$family_id,
		
			//private information
			'role_name'=>$mem['role_name'],
			'final_state'=>$dictYbcFinalState[$mem['final_state']],
			'award'=>$awarding[intval($mem['award'])]
		);
	}
	return  $finalMemberRec;
}




/**
 * ybc_no  family_name content
 * 
 */
function groupByYbcNo($resultList){
	$final = array();

	foreach ($resultList as $item){
		if (!isset($final[intval($item['family_id'])])){
			$final[intval($item['family_id'])] = array();
		}
		$final[intval($item['family_id'])]['family_name'] = getFamilyName($item['family_id']);
		$final[intval($item['family_id'])]['content'] .= date("Y-m-d H:i:s",$item['mtime'])." : ".$item['content']."<br/>";
		$final[intval($item['family_id'])]['ybc_no']  = max($final[intval($item['family_id'])]['ybc_no'],$item['ybc_no']);	
	}
	
	return $final;
}


/**
 * 	
 * 
 * @param unknown_type $familyName
 */
function getFamilyId($familyName){
	$sql = "select family_id from t_family_summary where family_name = '$familyName'";
	$result = GFetchRowOne($sql);
	return $result['family_id'];	
}



function getFamilyName($familyId){
	$sql = "select family_name from t_family_summary where family_id = '$familyId'";
	$result = GFetchRowOne($sql);
	return $result['family_name'];
}


