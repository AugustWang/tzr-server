<?php

class MissionListenerVO implements ISerialize {
	
	public $type;
	public $value;
	public $int_list;
	public $need_num;
	
	public function getAS3Data(){
		$int_list = $this->int_list;
		foreach($int_list as &$int){
			$int = intval($int);
		}
		return array(
			intval($this->type),
			intval($this->value),
			$int_list,
			intval($this->need_num)
		);
	}
	
	public function getErlangData(){
		$int_list = $this->int_list;
		foreach($int_list as &$int){
			$int = intval($int);
		}
		
		return '{mission_listener_data,'.
			intval($this->type).','.
			intval($this->value).','.
			'['.implode(',', $int_list).'],'.
			intval($this->need_num).'}';
	}
}

?>