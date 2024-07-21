<?php

class MissionSetting extends SerializeBase {
	
	//守边奖励文件
	const SBR_REWARD_FILE = '/mission/shoubian_reward.xml';
	
	//分组奖励文件
	const GROUP_REWARD_FILE = '/mission/group_reward.xml';
	
	//刺探文件
	const CT_REWARD_FILE = '/mission/citan_reward.xml';
	
	const OUT_PUT_SETTING_AS3_FILE = '/data/mtzr/script/serialize/output/mission_setting.txt';
	const OUT_PUT_SETTING_ERLANG_FILE = '/data/mtzr/config/mission/mission_setting.config';
	
	public function __construct() {
		$missionBaseXML = $this->readXML ( DATA_PATH . Mission::$MISSION_BASE_XML_FILE );
		$missionBaseDataArr = $missionBaseXML->mission;
		$previewList = array();
		
		foreach ( $missionBaseDataArr as $missionBaseData ) {
			$isEnable = ( string ) $missionBaseData ['enable'];
			if ($isEnable == 'false' || $isEnable == '0' ) {
				continue;
			}
			
			$missionID = ( int ) $missionBaseData ['id'];
			$missionType = ( int ) $missionBaseData ['type'];
			$minLV = ( int ) $missionBaseData ['min_level'];
			if($minLV >= 200 || $missionType != 1){
				continue;
			}
			$previewList[] = array($minLV, $missionID);
		}
		
		
		
		$shouBianReward = new ShouBianReward ( DATA_PATH . self::SBR_REWARD_FILE );
		$groupReward = new GroupReward ( DATA_PATH . self::GROUP_REWARD_FILE );
		$citanReward = new CitanReward ( DATA_PATH . self::CT_REWARD_FILE );
		$as3Data = '';
		$as3Data .= $shouBianReward->getAS3Data ();
		$as3Data .= $groupReward->getAS3Data ();
		$as3Data .= $citanReward->getAS3Data();
		$as3Data .= $this->getArrayAMF($previewList);
		
		$this->writeToFile ( $as3Data, self::OUT_PUT_SETTING_AS3_FILE );
		$dataVERSION = date ( 'Ymdhis', time () );
		$erlangSetting = '{data_version, ' . $dataVERSION . '}.' . "\n";
		$erlangSetting .= $shouBianReward->getErlangData () . "\n";
		$erlangSetting .= $groupReward->getErlangData () . "\n";
		$erlangSetting .= $citanReward->getErlangData()."\n";
		
		$this->writeToFile ( $erlangSetting, self::OUT_PUT_SETTING_ERLANG_FILE, false );
		
		echo ('导出任务配置【后端】数据成功，path=' . self::OUT_PUT_SETTING_ERLANG_FILE . "\n");
		echo ('导出任务配置【前端】数据成功，path=' . self::OUT_PUT_SETTING_AS3_FILE . "\n");
	}
}

?>