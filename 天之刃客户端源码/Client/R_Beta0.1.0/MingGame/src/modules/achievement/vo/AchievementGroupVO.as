package modules.achievement.vo
{
	public class AchievementGroupVO
	{
		public var id:int;
		public var name:String;
		public var desc:String;
		public var path:String;
		public var goods:Array;
		public var finishCount:int;
		public var totalCount:int;
		public var completeTime:int;
		public var state:int = 1;
		public var popType:int;
		public var parent:AchievementTypeVO;
		public var childrenXML:XMLList;
		public function AchievementGroupVO()
		{
			
		}
	}
}