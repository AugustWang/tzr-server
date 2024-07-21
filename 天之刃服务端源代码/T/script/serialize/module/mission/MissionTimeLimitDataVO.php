<?php

class MissionTimeLimitDataVO implements ISerialize {
	public $time_limit_start;//开始--时*3600+分*60
    public $time_limit_start_day;//开始--周几、月几
    public $time_limit_start_timestamp;//开始--具体某一天的时间戳
    public $time_limit_end;//结束--时*3600+分*60
    public $time_limit_end_day;//结束--周几、月几
    public $time_limit_end_timestamp;//结束--具体某一天的时间戳 

	public function getAS3Data(){
		return array(
			intval($this->time_limit_start),
			intval($this->time_limit_start_day),
			intval($this->time_limit_start_timestamp),
			intval($this->time_limit_end),
			intval($this->time_limit_end_day),
			intval($this->time_limit_end_timestamp)
		);
	}
	
	public function getErlangData(){
		return '{mission_time_limit,'.
			intval($this->time_limit_start).','.
			intval($this->time_limit_start_day).','.
			intval($this->time_limit_start_timestamp).','.
			intval($this->time_limit_end).','.
			intval($this->time_limit_end_day).','.
			intval($this->time_limit_end_timestamp).'}';
	}
}

?>