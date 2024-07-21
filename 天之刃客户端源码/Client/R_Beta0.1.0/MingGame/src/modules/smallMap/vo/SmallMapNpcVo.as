package modules.smallMap.vo
{
	/**
	 * 
	 * @author NPC的信息
	 * 
	 */	
	public class SmallMapNpcVo
	{
		public var id:int;
		public var name:String;
		public var tx:int;
		public var ty:int;

		public function SmallMapNpcVo()
		{
		}

		public function setup(x:int, y:int, pid:int=0):void
		{
			tx=x;
			ty=y;
			id=pid;
		}
	}
}