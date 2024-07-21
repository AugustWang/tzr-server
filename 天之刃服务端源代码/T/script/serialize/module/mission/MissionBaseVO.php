<?php

class MissionBaseVO implements ISerialize {
	
	public $id; //任务id
	public $name; //任务名字
	public $desc;//任务描述
	public $type; //任务类型
	public $model; //模型
	public $big_group; //任务大组
	public $small_group; //任务小组
	public $time_limit_type; //任务时间限制类型
	public $time_limit_data; //任务时间限制数据 数组
	public $pre_mission_id; //前置任务ID
	public $next_mission_list; //后置任务ID列表
	public $pre_prop_list; //前置任务道具列表
	public $gender; //性别
	public $faction; //国家
	public $team; //组队
	public $family; //门派
	public $min_level; //最小等级
	public $max_level; //最大等级
	public $max_do_times; //最大次数
	public $listener_data; //侦听器数据
	public $max_model_status; //最大状态值
	public $model_status_data; //状态数据
	public $reward_data; //奖励数据
	public $star_level; //任务星级
	
	public function getAS3Data(){
		
		$timeLimitDataAS3 = array();
		if($this->time_limit_data){
			$timeLimitData = $this->time_limit_data;
			$timeLimitDataAS3 = $timeLimitData->getAS3Data();
		}
		
		$listenerArrAS3 = array();
		if(is_array($this->listener_data) && !empty($this->listener_data)) {
			$listenerArr = $this->listener_data;
			foreach($listenerArr as $listener){
				$listenerArrAS3[] = $listener->getAS3Data();
			}
		}
		
		$statusDataArrAS3 = array();
		if(is_array($this->model_status_data) && !empty($this->model_status_data)) {
			$statusDataArr = $this->model_status_data;
			foreach($statusDataArr as $statusData){
				$statusDataArrAS3[] = $statusData->getAS3Data();
			}
		}
		
		$rewardDataAS3 = array();
		if($this->reward_data){
			$rewardDataAS3 = $this->reward_data->getAS3Data();
		}
		
		return array(
			$this->id,
			$this->name,
			$this->desc,
			$this->type,
			$this->model,
			$this->big_group,
			$this->big_group.(1000+intval($this->small_group)),
			$this->time_limit_type,
			$timeLimitDataAS3,
			$this->pre_mission_id,
			$this->pre_prop_list,
			$this->gender,
			$this->faction,
			$this->team,
			$this->family,
			$this->min_level,
			$this->max_level,
			$this->max_do_times,
			$listenerArrAS3,
			$this->max_model_status,
			$statusDataArrAS3,
			$rewardDataAS3,
			$this->next_mission_list,
			$this->star_level
		);
	}
	
	
	public function getKeytoData(){
		$result = '';
		$minLevelKey = ceil($this->min_level/10);
		$maxLevelKey = ceil($this->max_level/10);
		
		if($this->small_group != '0'){
			$keyTOID = $this->big_group.(1000+intval($this->small_group));
		}else{
			$keyTOID = $this->id;
		}
		
		for($i=$minLevelKey; $i<=$maxLevelKey; $i++){
			if( $this->faction >0 ){
				$result .= "{{". $i .",". $this->faction ."},". $keyTOID ."}.\n";
			}else{
				$result .= "{{". $i .",1},". $keyTOID ."}.\n";
				$result .= "{{". $i .",2},". $keyTOID ."}.\n";
				$result .= "{{". $i .",3},". $keyTOID ."}.\n";
			}
		}
		return $result;
	}
	
	public function getErlangData(){
	
		$timeLimitDataErlang = '{}';
		if($this->time_limit_data){
			$timeLimitData = $this->time_limit_data;
			$timeLimitDataErlang = $timeLimitData->getErlangData();
		}
		
		$listenerArrErlang = array();
		if(is_array($this->listener_data) && !empty($this->listener_data)) {
			$listenerArr = $this->listener_data;
			foreach($listenerArr as $listener){
				$listenerArrErlang[] = $listener->getErlangData();
			}
		}
		
		
		$statusDataArrErlang = array();
		if(is_array($this->model_status_data) && !empty($this->model_status_data)) {
			$statusDataArr = $this->model_status_data;
			foreach($statusDataArr as $statusData){
				$statusDataArrErlang[] = $statusData->getErlangData();
			}
		}
	
		$rewardDataErlang = array();
		if($this->reward_data){
			$rewardDataErlang = $this->reward_data->getErlangData();
		}
		
		if($this->small_group != '0'){
			$mySmallGroup = $this->big_group.(1000+intval($this->small_group));
		}else{
			$mySmallGroup = 0;
		}
		
		return '{mission_base_info, '.
		$this->id.','.
		'"'.addslashes($this->name).'",'.
		$this->type.','.
		$this->model.','.
		$this->big_group.','.
		$mySmallGroup.','.
		$this->time_limit_type.','.
		$timeLimitDataErlang.','.
		$this->pre_mission_id.','.
		self::toErlangList($this->next_mission_list) . ','.
		'undefined,'.
		$this->gender.','.
		$this->faction.','.
		$this->team.','.
		$this->family.','.
		$this->min_level.','.
		$this->max_level.','.
		$this->max_do_times.','.
		self::toErlangList($listenerArrErlang) . ','.
		$this->max_model_status.','.
		self::toErlangList($statusDataArrErlang) . ','.
		$rewardDataErlang.'}.'."\n";
	}
	
	private function toErlangList($arr){
		return '[' . implode ( ',', $arr ) .']';
	}
}
?>