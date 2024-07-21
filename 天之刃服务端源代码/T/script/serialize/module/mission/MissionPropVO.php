<?php

class MissionPropVO implements ISerialize {
	
	public $prop_id;
	public $prop_type;
	public $prop_num;
	public $bind;
	public $color='0';
	
	public function getAS3Data(){
		return array(
			intval($this->prop_id),
			intval($this->prop_type),
			intval($this->prop_num),
			(trim($this->bind) == 'true' ? true : false),
			intval($this->color)
		);
	}
	
	public function getErlangData(){
		return '{p_mission_prop,'.
		intval($this->prop_id).','.
		intval($this->prop_type).','.
		intval($this->prop_num).','.
		trim($this->bind).','.
		intval($this->color).'}';
	}
}

?>