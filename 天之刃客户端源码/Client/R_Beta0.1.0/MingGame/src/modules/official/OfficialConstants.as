package modules.official
{
	public class OfficialConstants
	{		
		/**
		 * 官职类型 
		 */		
		public static const OFFICIAL_KING:int = 0;
		public static const OFFICIAL_CHENGXIANG:int = 1;
		public static const OFFICIAL_DAJIANGJUN:int = 2;
		public static const OFFICIAL_JINYIWEI:int = 3;
		
		public static const OFFICE_NAMES:Array = ["国王","内阁大臣","大将军","锦衣卫指挥使"];
		public static function getOfficeIdByName(name:String):int{
			return OFFICE_NAMES.indexOf(name);
		}
		
		public function OfficialConstants()
		{
		}
	}
}