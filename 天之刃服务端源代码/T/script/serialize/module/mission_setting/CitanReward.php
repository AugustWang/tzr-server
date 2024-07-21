<?php

class CitanReward extends SerializeBase {
	

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
			$level = ( int ) $rec ['level'];
			$exp = ( int ) $rec['exp'];
			$silver_bind = ( int ) $rec['silver_bind'];
			$spy_exp = ( int ) $rec['spy_exp'];
			$spy_silver_bind = ( int ) $rec['spy_silver_bind'];
			$prestige = ( int ) $rec['prestige'];
			$spy_prestige = ( int ) $rec['spy_prestige'];
			
			$return [] = array(
				$level,
				$exp,
				$silver_bind,
				$spy_exp,
				$spy_silver_bind,
				$prestige,
				$spy_prestige
			);
		} 
		
		
		return $this->getArrayAMF ( $return );
	}
	
	/**
	 * 返回后端配置数据
	 */
	public function getErlangData() {
		$data = $this->_xml_data;
		
		$rewardErlang = array();
		foreach ( $data as $rec ) {
			$level = ( int ) $rec ['level'];
			$exp = ( int ) $rec['exp'];
			$silver_bind = ( int ) $rec['silver_bind'];
			$spy_exp = ( int ) $rec['spy_exp'];
			$spy_silver_bind = ( int ) $rec['spy_silver_bind'];
			$prestige = ( int ) $rec['prestige'];
            $spy_prestige = ( int ) $rec['spy_prestige'];
			
			$rewardErlang [] = '{'.
				$level.','.
				$exp.','.
				$silver_bind.','.
				$spy_exp.','.
				$spy_silver_bind.','.
				$prestige.','.
				$spy_prestige.'}';
		} 
		
		
		return '{citan_reward, ' . "\n" . self::arrayToStr($rewardErlang) .'}.' . "\n";
	}
	
	private function arrayToStr($arr){
		return '[' . implode ( ',' . "\n", $arr ) .']';
	}
}

?>