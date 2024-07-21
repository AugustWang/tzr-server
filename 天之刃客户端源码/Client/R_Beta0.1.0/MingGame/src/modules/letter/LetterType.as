package modules.letter
{
	/**
	 *  后端定义的信件类型
	 * @author Administrator
	 * 
	 */	
	public final class LetterType
	{
		//信件类型
		public static var PRIVATE:int = 0;
		public static var SYSTEM:int = 2;
		
		//信件的状态
		public static var UNOPEN:int = 1;
		public static var OPEN:int = 2;
		public static var ACCEPT_GOODS:int = 3;//已经收取的物品
		public static var REPLY:int = 4;
		
	}
}