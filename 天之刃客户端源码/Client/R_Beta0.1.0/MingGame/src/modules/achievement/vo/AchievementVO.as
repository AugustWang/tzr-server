package modules.achievement.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class AchievementVO extends EventDispatcher
	{
		public static const STATE_UN_FINISH:int = 0;
		public static const STATE_FINISH:int = 1;
		public static const STATE_TAKE_FINISH:int = 2;
		
		public var id:int;
		public var bigGroup:AchievementTypeVO;
		public var smallGroup:AchievementGroupVO;
		public var name:String;
		public var sort:int;
		public var points:int;
		public var path:String;
		public var desc:String;
		public var state:int = 1;
		public var popType:int;
		
		public var currentStep:int;
		public var totalStep:int;
		public var completeTime:Number;
		
		/**
		 * 世界成就相关 
		 */		
		public var roleId:int;
		public var roleName:String;
		/**
		 * 奖励相关属性
		 */		
		public var title:int;
		public var hasGoodsReward:Boolean = false;
		public var goods:Array;
		public function AchievementVO()
		{
		}
		
		public function update():void{
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}