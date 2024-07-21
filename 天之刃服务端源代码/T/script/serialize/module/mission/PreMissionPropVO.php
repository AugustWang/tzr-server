<?php

class PreMissionPropVO implements ISerialize {
	
	public $prop_id;
	public $prop_num;
	
	public function getAS3Data(){
		return array(
			intval($this->prop_id),
			intval($this->prop_num)
		);
	}
	
	public function getErlangData(){
		
		return '{pre_mission_prop,'.
			intval($this->prop_id).','.
			intval($this->prop_num).'}';
	}
}

?>