<?php

class GroupReward extends SerializeBase implements ISerialize {
	
	
	private $_xml_data;
	public function __construct($path) {
		$this->_xml_data = $this->readXML($path)->group;
	}
	
	/**
	 * 返回守边奖励配置大数组
	 */
	public function getAS3Data() {
		$data = $this->_xml_data;
		$return = array ();
		foreach ( $data as $rec ) {
			foreach ( $rec->reward as $reward ) {
				$groupID = ( string ) $rec ['id'];
				$level = ( string ) $reward ['level'];
				$exp = ( string ) $reward ['exp'];
				$bind_silver = ( int ) $reward ['bind_silver'];
				$prestige = ( int ) $reward['prestige'];
				if($bind_silver <= 0){
					$bind_silver = 0;
				}
				
				$propGroupArr = array();
				foreach ( $reward->prop_group as $propGroup ) {
					$propGroupVO = new PropGroupVO();
					$propGroupVO->do_times = ( string ) $propGroup['do_times'];
					$propGroupVO->props = array();
					foreach( $propGroup->p_mission_prop as $prop ){
						$propVO = new MissionPropVO();
						$propVO->prop_id = ( string ) $prop['prop_id'];
						$propVO->prop_type = ( string ) $prop['prop_type'];
						$propVO->prop_num = ( string ) $prop['prop_num'];
						$propVO->bind = ( string ) $prop['bind'];
						
						$propGroupVO->props[] = $propVO;
					}
					$propGroupArr[] = $propGroupVO->getAS3Data();
				}
				
				$return [] = array(
					intval($groupID),
					intval($level),
					intval($exp),
					intval($bind_silver),
					intval($prestige),
					$propGroupArr
				);
			}
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
			foreach ( $rec->reward as $reward ) {
				$groupID = ( string ) $rec ['id'];
				$level = ( string ) $reward ['level'];
				$exp = ( string ) $reward ['exp'];
				$bind_silver = ( int ) $reward ['bind_silver'];
				if($bind_silver <= 0){
					$bind_silver = 0;
				}
				$prestige = ( string ) $reward['prestige'];
				
				$propGroupArr = array();
				foreach ( $reward->prop_group as $propGroup ) {
					$propGroupVO = new PropGroupVO();
					$propGroupVO->do_times = ( string ) $propGroup['do_times'];
					$propGroupVO->props = array();
					foreach( $propGroup->p_mission_prop as $prop ){
						$propVO = new MissionPropVO();
						$propVO->prop_id = ( string ) $prop['prop_id'];
						$propVO->prop_type = ( string ) $prop['prop_type'];
						$propVO->prop_num = ( string ) $prop['prop_num'];
						$propVO->bind = ( string ) $prop['bind'];
						
						$propGroupVO->props[] = $propVO;
					}
					$propGroupArr[] = $propGroupVO->getErlangData();
				}
				
				
				$return [] = '  {{' . $groupID . ',' . $level . '},' . $exp . ',' . $bind_silver .','.$prestige.','
				. self::toErlangList($propGroupArr) . '}';
			}
		} 
		
		return '{group_reward, ' . "\n" . self::toErlangList($return) .'}.' . "\n";
	}
	
	private function toErlangList($arr){
		return '[' . implode ( ',' . "\n", $arr ) .']';
	}
}

?>