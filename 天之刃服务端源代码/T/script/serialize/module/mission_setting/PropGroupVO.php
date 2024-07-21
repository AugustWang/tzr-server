<?php

class PropGroupVO implements ISerialize {
	
	public $do_times;
	public $props;
	
	public function getAS3Data(){
		$props = array();
		foreach($this->props as $p){
			$props[] = $p->getAS3Data();
		}
		
		return array(
			intval($this->do_times),
			$props
		);
	}
	
	public function getErlangData(){
		$strProps = array();
		foreach($this->props as $p){
			$strProps[] = $p->getErlangData();
		}
		return '{'.
		intval($this->do_times).','.
		self::toErlangList( $strProps ) .'}';
	}
	
	private function toErlangList($arr){
		return '[' . implode ( ',' . "\n", $arr ) .']';
	}
	
}

?>