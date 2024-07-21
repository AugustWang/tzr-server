<?php

class MissionStatusDataVO implements ISerialize {
	public $npc_list;
	public $collect_list;
	public $time_limit;
	public $use_item_point_list;
	
	public function getAS3Data() {
		$npcListAS3 = array();
		foreach($this->npc_list as $npcVO) {
			$npcListAS3[] = $npcVO->getAS3Data();
		}
	
		$collectListAS3 = array();
		foreach($this->collect_list as &$collectVO) {
			$collectListAS3[] = $collectVO->getAS3Data();
		}
		
		$time_limit = intval($this->time_limit);
		
		$useitemPointListAS3 = array();
		foreach($this->use_item_point_list as &$useItemVO) {
			$useitemPointListAS3[] = $useItemVO->getAS3Data();
		}
		
		return array(
			$npcListAS3,
			$collectListAS3,
			$time_limit,
			$useitemPointListAS3
		);
	}
	
	public function getErlangData() {
		$npcListErlang = array();
		foreach($this->npc_list as $npcVO) {
			$npcListErlang[] = $npcVO->getErlangData();
		}
	
		$collectListErlang = array();
		foreach($this->collect_list as &$collectVO) {
			$collectListErlang[] = $collectVO->getErlangData();
		}
		
		$time_limit = intval($this->time_limit);
		
		$useitemPointListErlang = array();
		foreach($this->use_item_point_list as &$useItemVO) {
			$useitemPointListErlang[] = $useItemVO->getErlangData();
		}
		
		
		return '{mission_status_data, '.
			'['.implode(',', $npcListErlang).'],'.
			'['.implode(',', $collectListErlang).'],'.
			$time_limit.','.
			'['.implode(',', $useitemPointListErlang).']}';
	}
}

?>