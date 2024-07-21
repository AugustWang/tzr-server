<?php

class ShouBianReward extends SerializeBase {
	

	private $_xml_data;
	public function __construct($path) {
		$this->_xml_data = $this->readXML($path)->reward;
	}
	
	/**
	 * 返回守边奖励配置大数组
	 */
	public function getAS3Data() {
		$data = $this->_xml_data;
		
		$rewardAS = array();
		$return = array ();
		foreach ( $data as $rec ) {
			$level = ( string ) $rec ['level'];
			$succ_exp = ( string ) $rec['succ_exp'];
			$timeout_exp = ( string ) $rec['timeout_exp'];
			$succ_prestige = ( string ) $rec['succ_prestige'];
            $timeout_prestige = ( string ) $rec['timeout_prestige'];
			
			$strProps = array();
			foreach ( $rec->p_mission_prop as $prop ) {
				$propVO = new MissionPropVO();
				$propVO->prop_id = ( string ) $prop['prop_id'];
				$propVO->prop_type = ( string ) $prop['prop_type'];
				$propVO->prop_num = ( string ) $prop['prop_num'];
				$propVO->bind = ( string ) $prop['bind'];
				$strProps[] = $propVO->getAS3Data();
			}
			
			$return [] = array(
				intval($level),
				intval($succ_exp),
				intval($timeout_exp),
				intval($succ_prestige),
				intval($timeout_prestige),
				$strProps
			);
		} 
		
		
		return $this->getArrayAMF ( $return );
	}
	
	/**
	 * 返回后端配置数据
	 */
	public function getErlangData() {
		$data = $this->_xml_data;
		$return = array ();
		foreach ( $data as $rec ) {
			$level = ( string ) $rec ['level'];
			$succ_exp = ( string ) $rec['succ_exp'];
			$timeout_exp = ( string ) $rec['timeout_exp'];
			$succ_prestige = ( string ) $rec['succ_prestige'];
			$timeout_prestige = ( string ) $rec['timeout_prestige'];
			
			$strProps = array();
			foreach ( $rec->p_mission_prop as $prop ) {
				$propVO = new MissionPropVO();
				$propVO->prop_id = ( string ) $prop['prop_id'];
				$propVO->prop_type = ( string ) $prop['prop_type'];
				$propVO->prop_num = ( string ) $prop['prop_num'];
				$propVO->bind = ( string ) $prop['bind'];
				$strProps[] = $propVO->getErlangData();
			}
			$return [] = '  {' . $level .','. $succ_exp . ',' . $timeout_exp .','.$succ_prestige.','.$timeout_prestige.','
				. self::toErlangList($strProps) . '}';
		} 
		
		return '{shoubian_reward, ' . "\n" . self::toErlangList($return) .'}.' . "\n";
	}
	
	private function toErlangList($arr){
		return '[' . implode ( ',' . "\n", $arr ) .']';
	}
}

?>