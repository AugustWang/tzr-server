package modules.smallMap.vo
{
	/**
	 * 
	 * @author 跳转点的信息
	 * 
	 */	
	public class SmallMapTurnPoint
	{
		public var tx:int;
		public var ty:int;
		public var toMapId:int;
		public var toMapName:String;
		public var job:String
		public function SmallMapTurnPoint()
		{
		}

		public function setup(x:int, y:int,toId:int=0,toName:String=""):void
		{
			tx=x;
			ty=y;
			toMapId=toId;
			toMapName=toName;
		}
	}
}