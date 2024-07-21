<?php


$rowsLength = trim($argv[1]);
$missionID = trim($argv[2]);
if ( !$rowsLength){
	echo '';
	die('参数错误，运行示例：php toxml.php 2000');
} 
/*
 * 将mysql中的老任务数据导出到xml文件中
 */
 
define ( 'ROOT', dirname ( __FILE__ ) );
define ( 'DATA_PATH', ROOT . '/../../config/base_data' );
define('IN_ODINXU_SYSTEM', true);

$paths = array ();
$paths [] = ROOT;
$paths [] = ROOT . '/libs';
$paths [] = ROOT . '/module/npc';
$paths [] = ROOT . '/module/mission';
$paths [] = ROOT . '/module/mission_setting';

set_include_path ( get_include_path () . implode ( PATH_SEPARATOR, $paths ) );

include_once '../../app/web/game.www/config/config.php';
include_once '../../app/web/game.www/include/global.php';
include_once '../../app/web/central.admin/www/protected/views/mission/vo.php';
include_once './module/mission/MissionTransform.php';

$MISSION_BASE_XML_FILE = DATA_PATH . '/mission/mission_data.xml';
$limitString = "";


if( $rowsLength == 'id' ){
	$limitString = "";
}else{
	$limitString = " LIMIT " . $rowsLength;
}


$sql = "SELECT  `mission_id` ,  `mission_name` ,  `mission_type` ,  `mission_group` , " .
" `model_id` ,  `model_args` ,  `desc` ,  `is_time_limit` ,  `time_limit_num` ,  " .
"`c_min_level` ,  `c_max_level` ,  `c_faction` ,  `c_sex` ,  `c_job` ,  `c_family` , " .
" `c_team` ,  `c_time_max` ,  `c_time_award_max` ,  `c_prop` ,  `c_time_type` ," .
"  `c_time_start` ,  `c_time_end` ,  `c_pre_mission` , " .
" `auto_time` ,  `auto_cost` ,`auto_per_time` FROM  `ming2_cent`.`t_Mission` order by mission_id" . $limitString;

$result = GFetchRowSet($sql);

$xmlRoot = generateXml();
foreach ($result as $row) {
	
	if( $rowsLength=='id' && $missionID>0 ){
		if( $row['mission_id'] == $missionID ){
			echo "only export mission_id=". $missionID . "\n";
		}else{
			continue;
		}
	}
	
	
	$xmMission = $xmlRoot->addChild('mission');
	$xmMission->addAttribute('id', $row['mission_id']);
	$xmMission->addAttribute('enable', true);
	$xmMission->addAttribute('name', $row['mission_name']);
	$xmMission->addAttribute('desc', $row['desc']);
	$xmMission->addAttribute('type', $row['mission_type'] );
	
	$oldModelID = $row['model_id'];
	$newModelID = MissionTransform::transModelID( $oldModelID );
	$xmMission->addAttribute('mission_model', $newModelID );
	
	$dbMisionGroup = intval($row['mission_group']);
	if( $dbMisionGroup>0 ){
		$xmMission->addAttribute('big_group', intval($dbMisionGroup/10000));
		$xmMission->addAttribute('small_group', intval($dbMisionGroup%10000));
	}else{
		$xmMission->addAttribute('big_group', 0);
		$xmMission->addAttribute('small_group', 0);
	}
	
	$xmMission->addAttribute('time_limit_type', $row['c_time_type']);
	$xmMission->addAttribute('gender', $row['c_sex']);
	$xmMission->addAttribute('faction', $row['c_faction']);
	$xmMission->addAttribute('need_team', $row['c_team']);
	$xmMission->addAttribute('need_family', $row['c_family']);
	$xmMission->addAttribute('min_level', $row['c_min_level']);
	$xmMission->addAttribute('max_level', $row['c_max_level']);
	$xmMission->addAttribute('max_do_times', $row['c_time_max']);
	$xmMission->addAttribute('pre_mission_id', $row['c_pre_mission']);

	$model_args = unserialize(base64_decode($row['model_args']));
	//$c_prop = unserialize(base64_decode( $row['c_prop'] ));
	$c_time_start = unserialize(base64_decode($row['c_time_start']));
	$c_time_end = unserialize(base64_decode($row['c_time_end']));
	
	


	/**
	 * mission_time_limit 子节点
	 */
	$missionTimeLimit = $xmMission->addChild('mission_time_limit');
	$missionTimeLimit->addAttribute('time_limit_start', "0");
	$missionTimeLimit->addAttribute('time_limit_start_day', "0");
	$missionTimeLimit->addAttribute('time_limit_start_timestamp', "0");
	$missionTimeLimit->addAttribute('time_limit_end', "0");
	$missionTimeLimit->addAttribute('time_limit_end_day', "0");
	$missionTimeLimit->addAttribute('time_limit_end_timestamp', "0");

	
	$prePropList = $xmMission->addChild('pre_prop_list');
	 
	
	/**
	 * listener_data 子节点
	 */
	$listenerData = $xmMission->addChild('listener_data');
	foreach ($model_args->status_data as $dbStatusData) {
		
		foreach( $dbStatusData->listeners as $dbListener ){
			MissionTransform::addListener($listenerData,$dbListener,$newModelID);
		}
//		var_export($dbStatusData->listeners);
	}
	

	/**
	 * model_status_data 子节点
	 */
	$modelStatusData = $xmMission->addChild('model_status_data');
	$collectPropID=0;
	$collectPropName='';
	foreach ($model_args->status_data as $dbStatusData) {
		$status = $modelStatusData->addChild('status');
		
		/**
		 * npc子节点
		 */
		foreach ($dbStatusData->touches as $dbNpcInfo) {
			$npc = $status->addChild('npc');
			$collectMapName = $dbNpcInfo->pos_name;
			
			$npc->addAttribute('npc_id', $dbNpcInfo->npc_id);
			
			foreach($dbNpcInfo->talk as $dbTalk){
				$dialog = $npc->addChild('dialog');
				/**
				 * 处理答题任务
				 */
				 if( $oldModelID==17 ){
				 	$dbQuestion = MissionTransform::getQuestion($dbTalk);
				 	$dbAnswer_yes = MissionTransform::getAnswerYes($dbTalk);
				 	$dbAnswer_noArray = MissionTransform::getAnswerNo($dbTalk);
				 	
				 	$dialog->addAttribute('content', getContent($dbQuestion));
				 	$questionsNode = $dialog->addChild('questions');
				 	
				 	$qsYes = $questionsNode->addChild('question',$dbAnswer_yes);
				 	$qsYes->addAttribute('answer', 'true'); 
				 	
				 	foreach($dbAnswer_noArray as $a){
					 	$qsYes = $questionsNode->addChild('question',$a);
				 	}	
				 } else if( $newModelID==10 ){
				 	$dbTalkString = (string)$dbTalk;
				 	$dialog->addAttribute('content', getContent($dbTalkString));
				 	
				 	$idxSubmit = strpos($dbTalkString,"submit");
				 	if( $idxSubmit>0 ){
					 	$choose_npcsNode = $dialog->addChild('choose_npcs');
					 	if( $row['c_faction'] != 1 ){
						 	$choose_npcsNode->addChild('choose_npc', '去云州')->addAttribute('npc_id','11102100');	
					 	}
					 	if( $row['c_faction'] != 2 ){
						 	$choose_npcsNode->addChild('choose_npc', '去沧州')->addAttribute('npc_id','12102100');
					 	}
					 	if( $row['c_faction'] != 3 ){
						 	$choose_npcsNode->addChild('choose_npc', '去幽州')->addAttribute('npc_id','13102100');
					 	}
				 	}
				 } else{
					$dialog->addAttribute('content', getContent($dbTalk));
				 }
				
			}
		}
		
		if( $newModelID==8 ){ //采集模型
			/**
			 * collect子节点
			 */
			$dbOtherData = $dbStatusData->other_data;
			$dbListener = $dbStatusData->listeners[0];
			//var_export($dbStatusData);
			
			if( $collectPropID==0 ){
				$collectPropID = $dbListener->prop_id;
			}
			
			$collectPoints = $dbOtherData['collect_point'];
			$statusTitle = $dbOtherData['status_title'];
			
			if( $collectPoints && count($collectPoints)>1 ){
				
				$gotoStart = strpos($statusTitle,'goto#');
				$gotoEnd = strpos($statusTitle,'\'>');
				$gotoStr = substr($statusTitle,$gotoStart+5,($gotoEnd-$gotoStart-5));
				$gotoArray = explode(',', $gotoStr);
				
				$collect = $status->addChild('collect');
				$collect->addChild('points',arrayToString($collectPoints));
				$collect->addChild('baseid',$gotoArray[4]);
				$collect->addChild('point_name',$collectMapName);
				$collect->addChild('prop',$collectPropID);
				$collect->addChild('map',$gotoArray[0]);
				$collect->addChild('tx',$gotoArray[1]);
				$collect->addChild('ty',$gotoArray[2]);
			}
			
		}
		
		 
		 
	}

	/**
	 * mission_reward_data 子节点
	 */

	$prop_awardArray = $model_args->prop_award;
	
	$attr_awardArray = $model_args->attr_award;
	$prop_award_type = $model_args->prop_award_type;
	

	$missionRewardData = $xmMission->addChild('mission_reward_data');
	$missionRewardData->addAttribute('rollback_times', "1");
	$missionRewardData->addAttribute('prop_reward_formula', $prop_award_type);
	$missionRewardData->addAttribute('attr_reward_formula', "1");

	foreach ($attr_awardArray as $attrAward) {
		if ($attrAward->attr_type == 5) {
			$missionRewardData->addAttribute('exp', $attrAward->attr_num);
		} else if ($attrAward->attr_type == 6) {
			$missionRewardData->addAttribute('silver', $attrAward->attr_num);
		} else if ($attrAward->attr_type == 7) {
			$missionRewardData->addAttribute('silver_bind', $attrAward->attr_num);
		}
	}
	
	foreach ($prop_awardArray as $propAward) {
		$missionProp = $missionRewardData->addChild('p_mission_prop');
		$missionProp->addAttribute('prop_id', $propAward->prop_id);
		$missionProp->addAttribute('prop_type', $propAward->prop_type);
		$missionProp->addAttribute('prop_num', $propAward->prop_num);
		$missionProp->addAttribute('bind', $propAward->bind);
	}


};

$count = count($result);

writeXml($xmlRoot,$MISSION_BASE_XML_FILE);

echo "输出XML成功,count=${count},path=". $MISSION_BASE_XML_FILE ."\n";

function generateXml() {
	$xml = new SimpleXMLElement("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<missions>" .
	"</missions>");
	return $xml;
}

function getContent($dbContent){
	$strContent = (string)$dbContent;
//	$r1 = preg_replace('/....：/','',$strContent);
//	$r2 = preg_replace('/...：/','',$r1);
//	$r3 = preg_replace('/..：/','',$r2); 
//	$r3 = preg_replace('/\<br\>/','',$r2);
//	$r4 = preg_replace('/ \<br\>/','',$r3); 
	return $strContent;
}


function arrayToString($arr){
	return implode ( ',', $arr ) ;
}

function writeXml($xmlRoot,$filePath) {
	$fp = fopen( $filePath, "w");

	$xmlContent = $xmlRoot->asXML();
	$xmlContent = str_replace("><", ">\n\t<", $xmlContent);
	$xmlContent = str_replace("\t<mission id", "<mission id", $xmlContent);
	$xmlContent = str_replace("\t</mission>", "</mission>", $xmlContent);

	fwrite($fp, $xmlContent);
	fclose($fp);
}