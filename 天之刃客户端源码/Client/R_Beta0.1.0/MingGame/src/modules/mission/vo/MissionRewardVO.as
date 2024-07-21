package modules.mission.vo {
	/**
	 * 奖励结构 
	 * @author liang
	 * 
	 */
	public class MissionRewardVO {

		static public const I_ROLLBACK_TIMES:int = 0;
		static public const I_PROP_REWARD_FORMULA:int=1;
		static public const I_ATTR_REWARD_FORMULA:int=2;
		static public const I_EXP:int=3;
		static public const I_SILVER:int=4;
		static public const I_SILVER_BIND:int=5;
		static public const I_PRESTIGE:int=6;
		static public const I_PROP_REWARD:int=7;
		
		static public const PROP_REWARD_FORMULA_CHOOSE_ONE:int = 1;
		static public const PROP_REWARD_FORMULA_RANDOM:int = 2;
		static public const PROP_REWARD_FORMULA_ALL:int = 3;

		static public const ATTR_REWARD_FORMULA_NORMAL:int = 1;//1普通 -按照配置多少就给多少 没任何其他计算
		static public const ATTR_REWARD_FORMULA_CALC_ALL_TIMES:int = 2;//2对所有的经验和银两都按照次数来累计计算
		static public const ATTR_REWARD_FORMULA_CALC_EXP_TIMES:int = 3;//3仅对经验按照次数来累计计算
		static public const ATTR_REWARD_FORMULA_WU_XING:int = 4;//给与五行属性
		
		public function MissionRewardVO() {

		}
		
		
		public var rollback_times:int=0;//奖励回滚次数
		public var prop_reward_formula:int=0; //1全部给与 2选择 3随机 4转盘
		public var attr_reward_formula:int=0; //属性奖励给与方式
		public var exp:int;
		public var silver:int;
		public var silver_bind:int;
		public var prestige:int;//任务声望值
		public var prop_reward:Vector.<MissionPropRewardVO>;
	}
}