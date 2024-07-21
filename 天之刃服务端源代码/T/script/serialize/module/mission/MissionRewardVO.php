<?php

class MissionRewardVO implements ISerialize {
	
	public $rollback_times=0;//奖励回滚次数
	public $prop_reward_formula=0; //1全部给与 2选择 3随机 4转盘
	public $attr_reward_formula=0; //属性奖励给与方式
	public $exp;
	public $silver;
	public $silver_bind;
	public $prop_reward;
	public $prestige;//任务声望值
	
	public function getAS3Data(){
		$propRewardArr = $this->prop_reward;
		$propRewardArrAS3 = array();
		foreach($propRewardArr as $propReward){
			$propRewardArrAS3[] = $propReward->getAS3Data();
		}
		
		return array(
			intval($this->rollback_times),
			intval($this->prop_reward_formula),
			intval($this->attr_reward_formula),
			intval($this->exp),
			intval($this->silver),
			intval($this->silver_bind),
			intval($this->prestige),
			$propRewardArrAS3
		);
	}
	
	public function getErlangData(){
		$propRewardArr = $this->prop_reward;
		$propRewardArrErlang = array();
		foreach($propRewardArr as $propReward){
			$propRewardArrErlang[] = $propReward->getErlangData();
		}
		
		return '{mission_reward_data,'.
		intval($this->rollback_times).','.
		intval($this->prop_reward_formula).','.
		intval($this->attr_reward_formula).','.
		intval($this->exp).','.
		intval($this->silver).','.
		intval($this->silver_bind).','.
		intval($this->prestige).','.
		'['.implode(',', $propRewardArrErlang).']}';
	}
}

?>