package modules.mission.vo {

	/**
	 * 任务基础数据数组 索引映射
	 */
	public class MissionBaseIndex {
		public function MissionBaseIndex() {

		}

		static public const ID:int=0; //任务ID
		static public const NAME:int=1; //任务名字
		static public const DESC:int=2; //任务描述
		static public const TYPE:int=3; //任务类型
		static public const MODEL:int=4; //模型
		static public const BIG_GROUP:int=5; //任务大组
		static public const SMALL_GROUP:int=6; //任务小组
		static public const TIME_LIMIT_TYPE:int=7; //任务时间限制类型
		static public const TIME_LIMIT_DATA:int=8; //任务时间限制数据 数组
		static public const PRE_MISSION_ID:int=9;
		static public const PRE_MISSION_PROP:int=10;
		static public const GENDER:int=11; //性别
		static public const FACTION:int=12; //国家
		static public const TEAM:int=13; //组队
		static public const FAMILY:int=14; //门派
		static public const MIN_LEVEL:int=15; //最小等级
		static public const MAX_LEVEL:int=16; //最大等级
		static public const MAX_DO_TIMES:int=17; //最大次数
		static public const LISTENER_DATA:int=18; //侦听器数据
		static public const MAX_MODEL_STATUS:int=19; //最大状态值
		static public const STATUS_DATA:int=20; //状态数据
		static public const REWARD_DATA:int=21; //奖励数据
		static public const STAR_LEVEL:int=22; //任务星级

	}
}