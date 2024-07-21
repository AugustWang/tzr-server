<?php

class NPC extends SerializeBase {
	
	const NPC_BASE_ID_INDEX = 0; //NPC ID
	const NPC_BASE_NAME_INDEX = 1; //NPC 名
	const NPC_BASE_JOB_INDEX = 2; //NPC 职位ID
	const NPC_BASE_ACTION_INDEX = 3; //NPC 功能ID列表
	const NPC_BASE_AVATAR_INDEX = 4; //NPC 头像
	const NPC_BASE_SKIN_INDEX = 5; //NPC 皮肤
	const NPC_BASE_CONTENT_INDEX = 6; //NPC 默认内容
	const NPC_BASE_TYPE_INDEX = 7; //NPC 类型
	const NPC_BASE_MAP_INDEX = 8;//NPC 所在地图
	const NPC_BASE_ICON_INDEX = 9;//NPC 图标
	const NPC_BASE_CAN_SEARCH_WAY_INDEX = 10;//是否能寻路

	//NPC Job
	const NPC_JOB_ID_INDEX = 0; //NPC职位ID
	const NPC_JOB_NAME_INDEX = 1; //NPC职位名
	

	//NPC Action
	const NPC_ACTION_ID_INDEX = 0; //NPC 功能ID
	const NPC_ACTION_NAME_INDEX = 1; //NPC 功能名
	const NPC_ACTION_CONDITION_INDEX = 2; //NPC 显示该功能的条件列表
	

	//NPC数据分隔符
	const NPC_SEPARATOR_DATA = ',';
	const NPC_SEPARATOR_DATA_ACTION = '|';
	
	//文件定义
	const NPC_BASE_FILE = '/npc/NPC_base.xls';
	const NPC_ACTION_FILE = '/npc/NPC_action.xls';
	const NPC_JOB_FILE = '/npc/NPC_job.xls';
	const NPC_DATA_OUTPUT_FILE = '/data/mtzr/script/serialize/output/npc_data.txt';
	const NPC_ACTION_TYPE_AS3_FILE = '/data/mtzr/as3/NPCActionType.as';
	
	public function __construct() {
//		$data = $this->buildNPCBase ();
//		list($npcActionAMF, $npcActionAS3Code) = $this->buildNPCAction ();
//		$data .= $npcActionAMF;
//		$data .= $this->buildNPCJob ();
//		
//		$this->writeToFile ( $npcActionAS3Code, self::NPC_ACTION_TYPE_AS3_FILE, false );
//		$this->writeToFile ( $data, self::NPC_DATA_OUTPUT_FILE );
		$this->toXml();
	}
	
	private function generateXml($fileName) {
		return new SimpleXMLElement("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root/>");
	}
	
	public function toXml(){
		$baseData = $this->readExcel ( DATA_PATH . self::NPC_BASE_FILE );
		$filePath = "/data/mtzr/config/base_data/npc/NPC_base.xml";
		$xmlRoot = $this->generateXml($filePath);
		foreach ( $baseData as $rec ) {
			$row = $xmlRoot->addChild('npc_base');
			$row['enable'] = '1';
			$row['npc_id'] = $rec[0];
			$row['npc_name'] = $rec[1];
			$row['job_id'] = $rec[2];
			$row['action'] = $rec[3];
			$row['avatar'] = $rec[4];
			$row['skin'] = $rec[5];
			$row['content'] = $rec[6];
			$row['npc_type'] = $rec[7];
			$row['map_id'] = $rec[8];
			$row['icon_id'] = $rec[9];
			$row['can_find_path'] = $rec[10];
		}
		$this->writeXml($xmlRoot,$filePath);
		
		$actionData = $this->readExcel ( DATA_PATH . self::NPC_ACTION_FILE );
		$filePath = "/data/mtzr/config/base_data/npc/NPC_action.xml";
		$xmlRoot = $this->generateXml($filePath);
		foreach ( $actionData as $rec ) {
			$row = $xmlRoot->addChild('npc_action');
			$row['enable'] = '1';
			$row['action_id'] = $rec[0];
			$row['action_name'] = $rec[1];
		}
		$this->writeXml($xmlRoot,$filePath);
		
		$jobData = $this->readExcel ( DATA_PATH . self::NPC_JOB_FILE );
		$filePath = "/data/mtzr/config/base_data/npc/NPC_job.xml";
		$xmlRoot = $this->generateXml($filePath);
		foreach ( $jobData as $rec ) {
			$row = $xmlRoot->addChild('npc_job');
			$row['enable'] = '1';
			$row['job_id'] = $rec[0];
			$row['job_name'] = $rec[1];
		}
		$this->writeXml($xmlRoot,$filePath);
	}
	
	private function writeXml($xmlRoot,$filePath) {
		$fp = fopen( $filePath, "w");
		
		$xmlContent = $xmlRoot->asXML();
		$xmlContent = str_replace("><", ">\n\t<", $xmlContent);
		fwrite($fp, $xmlContent);
		fclose($fp);
	}
	
	/**
	 * buildNPCBase
	 * npc基础信息
	 * @param String $inFile
	 */
	public function buildNPCBase() {
		$data = $this->readExcel ( DATA_PATH . self::NPC_BASE_FILE );
		foreach ( $data as &$columns ) {
			$columns [self::NPC_BASE_ACTION_INDEX] = explode ( self::NPC_SEPARATOR_DATA, $columns [self::NPC_BASE_ACTION_INDEX] );
		}
		return $this->getArrayAMF ( $data );
	}
	
	/**
	 * buildNPCAction
	 * npc功能
	 * @param String $inFile
	 */
	public function buildNPCAction() {
		
		$npcAS3Code = 'package modules.npc';
		$npcAS3Code .= "\n{";
		$npcAS3Code .= "\n\tpublic class NPCActionType";
		$npcAS3Code .= "\n\t{";
		$npcAS3Code .= "\n\t\tpublic function NPCActionType(){}";
		
		$data = $this->readExcel ( DATA_PATH . self::NPC_ACTION_FILE );
		foreach ( $data as &$columns ) {
			$conditions = explode ( self::NPC_SEPARATOR_DATA_ACTION, $columns [self::NPC_ACTION_CONDITION_INDEX] );
			foreach ( $conditions as &$condition ) {
				$condition = explode ( self::NPC_SEPARATOR_DATA, $condition );
			}
			$columns [self::NPC_ACTION_CONDITION_INDEX] = $conditions;
			$id = $columns[self::NPC_ACTION_ID_INDEX];
			$name = $columns[self::NPC_ACTION_NAME_INDEX];
			$npcAS3Code .= "\n\t\t/**";
			$npcAS3Code .= "\n\t\t * ".iconv('utf-8', 'utf-8', $name);
			$npcAS3Code .= "\n\t\t */";
			$npcAS3Code .= "\n\t\tstatic public const NA_".$id.':String = "NPCAction_'.$id.'";';
			$npcAS3Code .= "\n\t\t";
		}
		$npcAS3Code .= "\n\t}";
		$npcAS3Code .= "\n}";
		
		echo ('导出NPC【前端】数据成功，path='. self::NPC_DATA_OUTPUT_FILE . "\n");
		return array($this->getArrayAMF ( $data ), $npcAS3Code);
	}
	
	/**
	 * buildNPCJob
	 * npc职位
	 * @param String $inFile
	 */
	public function buildNPCJob() {
		return $this->getArrayAMF ( $this->readExcel ( DATA_PATH . self::NPC_JOB_FILE ) );
	}

/**--------------BUILD函数区---------------**/
}

?>