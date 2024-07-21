<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);
define('ACTIVE_STANDARD',7*60);


$keyList = array(
//100002=>'春节活动二：集如意贺帖，换珍贵礼品',
//100003=>'春节活动三：挖天地灵药，奖春节红包',
//100004=>'春节活动四：极速讨伐，成就佳话',
//100005=>'春节活动五：新年新彩头，押镖有礼送',
//100006=>'春节活动六：齐聚门派贺新年，喜庆活动奖不停',
100011=>'情人节活动二：鲜花纷沓来，情人乐开怀',
100012=>'愚人节活动一：玩家击败BOSS后，100%掉落变身符',
100013=>'愚人节活动二：玩家到野外各处挖草药、毛皮、玉石等，掉落动物变身符'
);



$lastMsg = array();
foreach ($keyList as $id=>$item){
	$lastMsg[$id] = getInfoAry($id);
}




//start_time,end_time,is_open,rec

	
$smarty->assign(array(
	'lastMsg'=>$lastMsg,
	'keyList'=>$keyList
));

$smarty->display('module/event/activity_config.tpl');



function getInfoAry($id){
	$myAry = array();
	$content = getJson(ERLANG_WEB_URL."/activity/mccq_activity/?key=$id");
	foreach ($content as $key=>$value){
		$start = strtotime($value['start_time']);
		$end = strtotime($value['end_time']);
		$time  = time();
		if ( $value['is_open'] == true && $time >= $start && $end >= $time){
			$content[$key]['color'] = 'red';
		}	
		if ( $value['is_open'] == true ){
			$content[$key]['is_open'] = "是";
		}else{
			$content[$key]['is_open'] = "否";
		}
		
		//每一个事件
		foreach ($value as $k=>$v){
			
			if ($k == 'rec'){
				$tmpVal = '';
				foreach ($v as $label=>$con){
					$tmpVal .= $label.":".json_encode($con).'<br>';	
				}
				$content[$key]['rec'] = $tmpVal;
			}
		}
	}
	return $content;
}
