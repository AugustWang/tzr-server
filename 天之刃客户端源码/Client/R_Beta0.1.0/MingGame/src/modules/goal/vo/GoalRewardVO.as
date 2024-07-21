package modules.goal.vo
{
	/**
	 * 目标奖励VO 
	 * @author mingchao235
	 * 
	 */	
	public class GoalRewardVO
	{
		/**
		 * 绑定元宝 
		 */		
		public var bindGold:int;
		/**
		 * 非绑定元宝 
		 */		
		public var gold:int;
		/**
		 * 绑定银子 
		 */		
		public var bindSilver:int;
		/**
		 * 非绑定银子 
		 */		
		public var silver:int;
		/**
		 * 经验值 
		 */		
		public var exp:Number;
		/**
		 * 选择方式(0,不需要选择,1,多选一)
		 */		
		public var muti_choose:int;
		/**
		 * 道具奖励 
		 */		
		public var goods:Array;
		public function GoalRewardVO()
		{
		}
	}
}