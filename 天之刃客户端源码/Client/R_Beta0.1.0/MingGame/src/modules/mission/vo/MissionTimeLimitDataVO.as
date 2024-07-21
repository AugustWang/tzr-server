package modules.mission.vo {

	public class MissionTimeLimitDataVO {
		public var I_TIME_LIMIT_START=0; //开始--时*3600+分*60
		public var I_TIME_LIMIT_START_DAY=1; //开始--周几、月几
		public var I_TIME_LIMIT_START_TIMESTAMP=2; //开始--具体某一天的时间戳
		public var I_TIME_LIMIT_END=3; //结束--时*3600+分*60
		public var I_TIME_LIMIT_END_DAY=4; //结束--周几、月几
		public var I_TIME_LIMIT_END_TIMESTAMP=5; //结束--具体某一天的时间戳 

		public function MissionTimeLimitDataVO() {

		}

		public var time_limit_start; //开始--时*3600+分*60
		public var time_limit_start_day; //开始--周几、月几
		public var time_limit_start_timestamp; //开始--具体某一天的时间戳
		public var time_limit_end; //结束--时*3600+分*60
		public var time_limit_end_day; //结束--周几、月几
		public var time_limit_end_timestamp; //结束--具体某一天的时间戳 

	}
}