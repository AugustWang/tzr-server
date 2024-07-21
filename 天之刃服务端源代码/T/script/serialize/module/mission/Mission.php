<?php

class Mission extends SerializeBase {
	
	static public $MISSION_BASE_FILE = '/mission/MissionBaseInfo.xls';
	static public $MISSION_BASE_XML_FILE = '/mission/mission_data.xml';
	static public $MISSION_AS3_BASE_FILE = '/output/missions.txt';
	static public $MISSION_ERLANG_BASE_FILE = '/../../config/mission/missions.detail';
	static public $MISSION_NO_GROUP_KEYTO_BASE_FILE = '/../../config/mission/mission.nogroup_keyto';
	static public $MISSION_GROUP_KEYTO_BASE_FILE = '/../../config/mission/mission.group_keyto';
	static public $MISSION_PHP_FILE = '/../../config/mission/mission.php';
	
	//如果NPC的对话内容的某条数据是个数组 (一般是字符串)数组的索引0位置是类型标识
	static public $MISSION_NPC_DIALOGUES_TYPE_QUESTION = 1; //任务NPC对话类型 1为答题
	static public $MISSION_NPC_DIALOGUES_TYPE_CHOOSE_NPC = 2; //任务NPC对话类型 2为选择NPC
	

	public function __construct() {
		self::$MISSION_AS3_BASE_FILE = (ROOT.self::$MISSION_AS3_BASE_FILE);
		self::$MISSION_ERLANG_BASE_FILE = realpath(ROOT.self::$MISSION_ERLANG_BASE_FILE);
		self::$MISSION_NO_GROUP_KEYTO_BASE_FILE = realpath(ROOT.self::$MISSION_NO_GROUP_KEYTO_BASE_FILE);
		self::$MISSION_GROUP_KEYTO_BASE_FILE = realpath(ROOT.self::$MISSION_GROUP_KEYTO_BASE_FILE);
		self::$MISSION_PHP_FILE = realpath(ROOT.self::$MISSION_PHP_FILE);

		$data = $this->buildMissionBase ();
	}
	
	private function is_valid_xml_element($elem) {
		return $elem && $elem->children();
	}
	
	public function buildMissionBase() {
		$xml = $this->readXML ( DATA_PATH . self::$MISSION_BASE_XML_FILE );
		$data = $xml->mission;
		$amfData = '';
		$erlangData = '';
		$phpText = "<?php \n".'$dictMission = array'."(";
		
		$missionVOList = array();
		
		foreach ( $data as $rec ) {
			$isEnable = ( string ) $rec ['enable'];
			if ($isEnable == 'false' || $isEnable == '0' ) {
				continue;
			}
			
			$missionBaseVO = new MissionBaseVO ();
			$missionBaseVO->id = ( string ) $rec ['id'];
			$missionBaseVO->name = ( string ) $rec ['name'];
			$missionBaseVO->desc = ( string ) $rec ['desc'];
			$missionBaseVO->type = ( string ) $rec ['type'];
			$missionBaseVO->model = ( string ) $rec ['mission_model'];
			$missionBaseVO->big_group = ( string ) $rec ['big_group'];
			$missionBaseVO->small_group = ( string ) $rec ['small_group'];
			$missionBaseVO->time_limit_type = ( string ) $rec ['time_limit_type'];
			$missionBaseVO->time_limit_data = ( string ) $rec ['time_limit_data'];
			$missionBaseVO->gender = ( string ) $rec ['gender'];
			$missionBaseVO->faction = ( string ) $rec ['faction'];
			$missionBaseVO->team = ( string ) $rec ['need_team'];
			$missionBaseVO->family = ( string ) $rec ['need_family'];
			$missionBaseVO->min_level = ( string ) $rec ['min_level'];
			$missionBaseVO->max_level = ( string ) $rec ['max_level'];
			$missionBaseVO->max_do_times = ( string ) $rec ['max_do_times'];
			$missionBaseVO->pre_mission_id = ( string ) $rec ['pre_mission_id'];
			$missionBaseVO->star_level = ( string ) $rec['star_level'];
			
			$missionBaseVO->listener_data = array ();
			if (self::is_valid_xml_element ( $rec->listener_data )) {
				$confListenerData = $rec->listener_data [0];
				foreach ( $confListenerData->mission_listener_data as $misListenerData ) {
					$listenerVO = new MissionListenerVO ();
					$listenerVO->type = ( string ) $misListenerData ['type'];
					$listenerVO->value = ( string ) $misListenerData ['value'];
					$listenerVO->need_num = ( string ) $misListenerData ['need_num'];
					$listenerVO->int_list = split ( ",", ( string ) $misListenerData ['int_list'] );
					
					$missionBaseVO->listener_data [] = $listenerVO;
				}
			}
			
			$missionBaseVO->pre_prop_list = array ();
			if (self::is_valid_xml_element ( $rec->pre_prop_list )) {
				$confPropList = $rec->pre_prop_list;
				foreach ( $confPropList->pre_mission_prop as $missProp ) {
					$missionPropVO = new PreMissionPropVO ();
					$missionPropVO->prop_id = ( string ) $missProp ['prop_id'];
					$missionPropVO->prop_num = ( string ) $missProp ['prop_num'];
					
					$missionBaseVO->pre_prop_list [] = $missionPropVO;
				}
			}
			
			$missionBaseVO->model_status_data = array ();
			//格式化状态数据 开始
			if (self::is_valid_xml_element ( $rec->model_status_data )) {
				$confModelStatusData = $rec->model_status_data [0];
				foreach ( $confModelStatusData->status as $statusData ) {
					$statusDataVO = new MissionStatusDataVO ();
					$statusDataVO->npc_list = array ();
					foreach ( $statusData->npc as $npcData ) {
						$missionStatusNPCVO = new MissionStatusNPCVO ();
						$missionStatusNPCVO->npcID = ( string ) $npcData ['npc_id'];
						
						$dialogData = $npcData->dialog;
						$missionStatusNPCVO->dialogues = array ();
						foreach ( $dialogData as $dlg ) {
							$missionStatusNPCVO->dialogues [] = $dlg;
						}
						$statusDataVO->npc_list [] = $missionStatusNPCVO;
					}
					
					$statusDataVO->collect_list = array();
					foreach ( $statusData->collect as $collectData ) {
						$missionCollectVO = new MissionCollectVO ();
						$missionCollectVO->points = explode(',', $collectData->points);
						$missionCollectVO->point_name = $collectData->point_name;
						$missionCollectVO->baseid = $collectData->baseid;
						$missionCollectVO->prop = $collectData->prop;
						$missionCollectVO->map = $collectData->map;
						$missionCollectVO->tx = $collectData->tx;
						$missionCollectVO->ty = $collectData->ty; 
						$statusDataVO->collect_list [] = $missionCollectVO;
					}
					$statusDataVO->use_item_point_list = array();
					foreach ( $statusData->use_item_pos as  $useItemData) {
						$missionUseItemVO = new MissionUseItemVO ();
						$missionUseItemVO->item_id = $useItemData['item_id'];
						$missionUseItemVO->map_id = $useItemData['map_id'];
						$missionUseItemVO->tx = $useItemData['tx'];
						$missionUseItemVO->ty = $useItemData['ty'];
						$missionUseItemVO->total_progress = $useItemData['total_progress'];
						$missionUseItemVO->new_type_id = $useItemData['new_type_id'];
						$missionUseItemVO->new_number = $useItemData['new_number'];
						$missionUseItemVO->show_name = $useItemData['show_name'];
						$missionUseItemVO->progress_desc = $useItemData['progress_desc'];
						$statusDataVO->use_item_point_list [] = $missionUseItemVO;
					}
					
					$statusDataVO->time_limit = $statusData->time_limit;
					
					$missionBaseVO->model_status_data [] = $statusDataVO;
				}
			}
			
			$missionBaseVO->max_model_status = sizeof ( $missionBaseVO->model_status_data ) - 1;
			//格式化状态数据 结束
			

			$recMissionReward = $rec->mission_reward_data;
			$missionRewardVO = new MissionRewardVO ();
			$missionRewardVO->rollback_times = ( string ) $recMissionReward ['rollback_times'];
			$missionRewardVO->prop_reward_formula = ( string ) $recMissionReward ['prop_reward_formula'];
			$missionRewardVO->attr_reward_formula = ( string ) $recMissionReward ['attr_reward_formula'];
			$missionRewardVO->exp = ( string ) $recMissionReward ['exp'];
			$missionRewardVO->silver = ( string ) $recMissionReward ['silver'];
			$missionRewardVO->silver_bind = ( string ) $recMissionReward ['silver_bind'];
			$missionRewardVO->prestige = ( string ) $recMissionReward ['prestige'];
			$missionRewardVO->prop_reward = array ();
			
			if (self::is_valid_xml_element ( $rec->mission_reward_data )) {
				foreach ( $rec->mission_reward_data->p_mission_prop as $propReward ) {
					$missionPropRewardVO = new MissionPropVO ();
					$missionPropRewardVO->prop_id = ( string ) $propReward ['prop_id'];
					$missionPropRewardVO->prop_type = ( string ) $propReward ['prop_type'];
					$missionPropRewardVO->prop_num = ( string ) $propReward ['prop_num'];
					$missionPropRewardVO->bind = ( string ) $propReward ['bind'];
					$missionPropRewardVO->color = ( string ) $propReward ['color'];
					$missionRewardVO->prop_reward [] = $missionPropRewardVO;
				}
			}
			
			$missionBaseVO->reward_data = $missionRewardVO;
			$missionVOList[] = $missionBaseVO;
			
			$phpText .= "\n\t". $rec['id'] ."=>array('type'=>". $rec ['type'] .",'faction'=>". $rec ['faction'] .",'name'=>'". $rec ['name'] ."' ),";
		}
		
		foreach($missionVOList as $m1){
			$m1->next_mission_list = array();
			foreach($missionVOList as $m2){
				if($m2->pre_mission_id == $m1->id){
					$m1->next_mission_list[] = $m2->id;
				}
			}
		}
		
		$noGroupKeytoData = '';
		$groupKeytoData = '';
		$groupKeytoDataExists = array();
		foreach($missionVOList as $mission){
			$amfData .= $this->getArrayAMF ( $mission->getAS3Data () );
			$erlangData .= $mission->getErlangData ();
			$keytoData = $mission->getKeytoData ();
			if($mission->small_group == '0') {
				$noGroupKeytoData .= $keytoData;
			}else{
				if(!$groupKeytoDataExists[$mission->big_group][$mission->small_group]){
					$groupKeytoDataExists[$mission->big_group][$mission->small_group]= true;
					$groupKeytoData .= $keytoData;
				}
			}
		}
		
		$phpText .= "\n);";
		
		$this->writeToFile ( $amfData, self::$MISSION_AS3_BASE_FILE );
		$this->writeToFile ( $erlangData, self::$MISSION_ERLANG_BASE_FILE, false );
		$this->writeToFile ( $noGroupKeytoData, self::$MISSION_NO_GROUP_KEYTO_BASE_FILE, false );
		$this->writeToFile ( $groupKeytoData, self::$MISSION_GROUP_KEYTO_BASE_FILE, false );
		self::writePhp($phpText,self::$MISSION_PHP_FILE);
		
		echo ('导出任务【后端】数据成功，path='. self::$MISSION_ERLANG_BASE_FILE . "\n");
		echo ('导出任务【后端】PHP文件成功，path='. self::$MISSION_PHP_FILE . "\n");
		echo ('导出任务【前端】数据成功，path='. self::$MISSION_AS3_BASE_FILE . "\n");
	
	}
	
	private function writePhp($phpText,$filePath){
		$fp = fopen( $filePath, "w");
		fwrite($fp, $phpText);
		fclose($fp);
	}
	
}

?>