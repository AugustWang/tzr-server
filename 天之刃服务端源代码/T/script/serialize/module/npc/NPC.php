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
	const NPC_BASE_FILE = '/npc/NPC_base.xml';
	const NPC_ACTION_FILE = '/npc/NPC_action.xml';
	const NPC_JOB_FILE = '/npc/NPC_job.xml';
	const NPC_DATA_OUTPUT_FILE = '/data/mtzr/script/serialize/output/npc_data.txt';
	const NPC_ACTION_TYPE_AS3_FILE = '/data/mtzr/script/serialize/output/NPCActionType.as';
	
	public function __construct() {
		$data = $this->buildNPCBase ();
		list($npcActionAMF, $npcActionAS3Code) = $this->buildNPCAction ();
		$data .= $npcActionAMF;
		$data .= $this->buildNPCJob ();
		
		$this->writeToFile ( $npcActionAS3Code, self::NPC_ACTION_TYPE_AS3_FILE, false );
		$this->writeToFile ( $data, self::NPC_DATA_OUTPUT_FILE );
	}
	
	
	/**
	 * buildNPCBase
	 * npc基础信息
	 * @param String $inFile
	 */
	public function buildNPCBase() {
		$data = $this->readXML ( DATA_PATH . self::NPC_BASE_FILE );
		$data = $data->npc_base;
		$asArray = array();
		foreach ( $data as $rec ) {
			$f1 = (string)$rec['npc_id'];
			$f2 = (string)$rec['npc_name'];
			$f3 = (string)$rec['job_id'];
			$f4 = explode(',',(string)$rec['action']);
			$f5 = (string)$rec['avatar'];
			$f6 = (string)$rec['skin'];
			$f7 = (string)$rec['content'];
			$f8 = (string)$rec['npc_type'];
			$f9 = (string)$rec['map_id'];
			$f10 = (string)$rec['icon_id'];
			$f11 = (string)$rec['can_find_path'];
			$f12 = (string)$rec['npc_color'];
			$asArray[] = array( intval($f1),trim($f2),intval($f3),
				$f4,$f5,$f6,$f7,intval($f8),intval($f9),$f10,intval($f11),trim($f12));
		}
		return $this->getArrayAMF ( $asArray );
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
		
		$data = $this->readXML ( DATA_PATH . self::NPC_ACTION_FILE );
		$data = $data->npc_action;
		$asArray = array();
		foreach ( $data as $rec ) {
			$id = (string)$rec['action_id'];
			$name = (string)$rec['action_name'];
			$asArray[] = array( intval($id),trim($name) );
			
			$npcAS3Code .= "\n\t\t/**";
			$npcAS3Code .= "\n\t\t * ".iconv('utf-8', 'utf-8', $name);
			$npcAS3Code .= "\n\t\t */";
			$npcAS3Code .= "\n\t\tstatic public const NA_".$id.':String = "NPCAction_'.$id.'";';
			$npcAS3Code .= "\n\t\t";
		}
		$npcAS3Code .= "\n\t}";
		$npcAS3Code .= "\n}";
		
		echo ('导出NPC【前端】数据成功，path='. self::NPC_DATA_OUTPUT_FILE . "\n");
		echo ('导出NPC【前端】AS文件成功，path='. self::NPC_ACTION_TYPE_AS3_FILE . "\n");
		return array($this->getArrayAMF ( $asArray ), $npcAS3Code);
	}
	
	/**
	 * buildNPCJob
	 * npc职位
	 * @param String $inFile
	 */
	public function buildNPCJob() {
		$data = $this->readXML ( DATA_PATH . self::NPC_JOB_FILE );
		$data = $data->npc_job;
		$asArray = array();
		foreach ( $data as $rec ) {
			$id = (string)$rec['job_id'];
			$name = (string)$rec['job_name'];
			$asArray[] = array( intval($id),trim($name) );
		}
		
		return $this->getArrayAMF ( $asArray );
	}

/**--------------BUILD函数区---------------**/
}

?>