<?php

class MissionCollectVO implements ISerialize {
	public $points;
	public $baseid;
	public $prop;
	public $map;
	public $tx;
	public $ty;
	public $point_name;
	
	public function getAS3Data() {
		foreach ( $this->points as &$point ) {
			$point = intval ( trim ( $point ) );
		}
		
		$this->baseid = intval ( trim ( $this->baseid ) );
		$this->tx = intval ( $this->tx );
		$this->ty = intval ( $this->ty );
		$this->map = intval ( $this->map );
		$this->point_name = trim ( $this->point_name );
		return array ($this->points, 
			intval ( $this->baseid ), 
			intval ( $this->prop ), 
			intval ( $this->map ), 
			intval ( $this->tx ), 
			intval ( $this->ty ), 
			$this->point_name );
	}
	
	public function getErlangData() {
		return '[' . implode ( ',', $this->points ) . ']';
	}
}

?>