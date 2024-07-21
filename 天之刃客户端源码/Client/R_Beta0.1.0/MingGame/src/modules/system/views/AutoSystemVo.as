package modules.system.views
{

	public class AutoSystemVo
	{
		public var open:Boolean;
		public var autoHp:Boolean;
		public var autoHpLine:int;
		public var autoMp:Boolean;
		public var autoMpLine:int;
		public var buyHpDrug:Boolean;
		public var backTown:Boolean;

		public var pickEquit:Boolean;
		public var white:Boolean;
		public var green:Boolean;
		public var blue:Boolean;
		public var purple:Boolean;
		public var orange:Boolean;
		public var pickDrug:Boolean;
		public var pickStone:Boolean;
		public var pickOther:Boolean;
		
		public var fireSkill:Boolean;
		public var skillArray:Array;

		public var acceptTeam:Boolean;
		public var refuseTeam:Boolean;

		public var hangTime:int;
		public var restTime:int;

		private static var _instance:AutoSystemVo;

		public function AutoSystemVo():void
		{

		}

		public static function get instance():AutoSystemVo
		{
			if (_instance == null)
			{
				_instance=new AutoSystemVo;
			}
			return _instance;
		}
	}
}