<?php

class MissionTransform {
	
	public static function getIntList($dbListener,$newModelID){		
		if( $newModelID==2 ){
			//[MapID] = ListenerDataConfig#mission_listener_data.int_list,
			return $dbListener->map ;
		} else if( $newModelID>3 || $newModelID<8){
			//NpcIDList = ListenerDataConfig#mission_listener_data.int_list,
			return $dbListener->npc_id;
		} 
	}
	
	public static function getQuestion($dbTalk){
		$qsIndex = strpos($dbTalk,'a href=');
		return substr($dbTalk,0,$qsIndex-1);
	}
	
	
	public static function getLine($text){
		$idx1 = strpos($text,'submit');
		$idx2 = strpos($text,'</a');
		$r1 = substr($text,$idx1+12,($idx2-$idx1-12));
		$r2 = str_replace("C.","",str_replace("B.","",str_replace("A.","",$r1)));
		$r3 = str_replace("C：","",str_replace("B：","",str_replace("A：","",$r2)));
		$r4 = str_replace("C)","",str_replace("B)","",str_replace("A)","",$r3)));
		$r5 = str_replace("<u>","",$r4);
		$r6 = str_replace("</u>","",$r5);
		return $r6;
	}
	
	public static function getAnswerYes($dbTalk){
		$len = strlen($dbTalk);
		$qsIndex = strpos($dbTalk,'a href=');
		$answers = substr($dbTalk,$qsIndex-1,$len-$qsIndex);
		
		$answersArray = explode('<br><br>', $answers);
		foreach($answersArray as $ans){
			$idx = strpos($ans,'submit');
			$submits = substr($ans,$idx+7,3);
			if( strpos($submits,',1')>0 ){
				return self::getLine($ans);
			}
		}
	}
	
	
	public static function getAnswerNo($dbTalk){
		$len = strlen($dbTalk);
		$qsIndex = strpos($dbTalk,'a href=');
		$answers = substr($dbTalk,$qsIndex-1,$len-$qsIndex);
		
		$answersArray = explode('<br><br>', $answers);
		$answersNoArray = array();
		foreach($answersArray as $ans){
			$idx = strpos($ans,'submit');
			$submits = substr($ans,$idx+7,3);
			if( strpos($submits,',0')>0 ){
				$answersNoArray[] = self::getLine($ans);;
			}
		}
		return $answersNoArray;
	}

	public static function addListener(&$listenerData, $dbListener, $newModelID) {
		//var_export($dbListener);
		//var_export("bison=".$newModelID);
		//var_export( $dbListener instanceof mission_listener_monster );
		
		
		// type:1怪物，2道具
		if( $dbListener instanceof mission_listener_monster ){
			$mlData = $listenerData->addChild("mission_listener_data");
			$mlData->addAttribute('type', 1);
			$mlData->addAttribute('value', $dbListener->monster_type);
			$mlData->addAttribute('need_num', $dbListener->monster_num);
			
			$intList = self::getIntList($dbListener,$newModelID);
			$mlData->addAttribute('int_list', $intList );
			
		}else if( $dbListener instanceof mission_listener_prop ){
			$mlData = $listenerData->addChild("mission_listener_data");
			$mlData->addAttribute('type', 2);
			$mlData->addAttribute('value', $dbListener->prop_id);
			$mlData->addAttribute('need_num', $dbListener->prop_num);
			
			$intList = self::getIntList($dbListener,$newModelID);
			$mlData->addAttribute('int_list', $intList );
			
		}else if( $dbListener instanceof mission_listener_monster_prop ){
			$mlData1 = $listenerData->addChild("mission_listener_data");
			$mlData1->addAttribute('type', 1);
			$mlData1->addAttribute('value', $dbListener->monster_type);
			$mlData1->addAttribute('need_num', $dbListener->monster_num);
			$mlData1->addAttribute('int_list', $dbListener->map );
			
			$mlData2 = $listenerData->addChild("mission_listener_data");
			$mlData2->addAttribute('type', 2);
			$mlData2->addAttribute('value', $dbListener->prop_id);
			$mlData2->addAttribute('need_num', $dbListener->prop_num);
			$mlData2->addAttribute('int_list', $dbListener->drop_pro );
			
		}else {
			echo "fuck,are you kiding me?";
		}

	}

	public static function transModelID($dbModelID) {			
		switch($dbModelID){				
			case 1: return 1;
			case 2: return 2;
			case 3: return 3;
			case 4: return 7;
			case 5: return 0; //fuck
			case 6: return 6;
			case 7: return 1;
			case 8: return 1;
			case 9: return 4;
			case 10: return 5;
			case 11: return 9;
			case 12: return 1;
			case 13: return 0; //fuck
			case 14: return 1;
			case 15: return 1;
			case 16: return 1;
			case 17: return 1;
			case 18: return 8;
			case 19: return 10;
		}
	}
}
?>