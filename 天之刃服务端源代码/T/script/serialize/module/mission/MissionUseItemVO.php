<?php

class MissionUseItemVO implements ISerialize {
	public $item_id;
	public $map_id;
	public $tx;
	public $ty;
	public $total_progress;
	public $new_type_id;
	public $new_number;
	public $show_name;
	public $progress_desc;
	
	public function getAS3Data() {
		$this->item_id = intval ( $this->item_id );
		$this->map_id = intval ($this-> map_id);
		$this->tx = intval ( $this->tx );
		$this->ty = intval ( $this->ty );
		$this->total_progress = intval( $this->total_progress);
		$this->new_type_id = intval ( $this->new_type_id );
		$this->new_number = intval ( $this->new_number );
		$this->show_name = trim($this->show_name);
		$this->progress_desc = trim($this->progress_desc);
		return array ($this->item_id, 
			intval ( $this->map_id ), 
			intval ( $this->tx ), 
			intval ( $this->ty ), 
			intval( $this->total_progress),
			intval ( $this->new_type_id ), 
			intval ( $this->new_number ),
			$this->show_name,
			$this->progress_desc);
	}
	
	public function getErlangData() {
		return '{mission_status_data_use_item,'.
		intval($this->item_id).','.
		intval($this->map_id).','.
		intval($this->tx).','.
		intval($this->ty).','.
		intval($this->total_progress).','.
		intval($this->new_type_id).','.
		intval($this->new_number).','.
		'"'.addslashes($this->show_name).'",'.
		'"'.addslashes($this->progress_desc).'"}';
	}
}

?>