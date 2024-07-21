package modules.friend
{
	public class FriendsConstants
	{
		
		/**
		 * 通知社会界面相关数据发生变化，需要立即更新的常量类 
		 */	
		public static const FRIENDS_TYPE:int=1; // 我的好友
		public static const BLACK_TYPE:int=2; // 黑名单 
		public static const ENEMY_TYPE:int=3; // 仇人
		public static const STRANGER_TYPE:int=4; // 陌生人
		
		public static const FRIENDS_TYPE_NAMES:Array = ["","我的好友","黑名单","仇人","陌生人"];
		public static const RELATIVES_NAMES:Array = ["","师","徒","夫","妻"];
		public static const RELATIVES_TIPS:Array = ["","师傅","徒弟","丈夫","妻子"];
		
		public static const MALE:int = 1;
		public static const FEMALE:int = 2;
		
		public static const CHAT_PRIVATE:int = 1;
		public static const FRIEND_PRIVATE:int = 2;
		
		public static function getFriendlyTip(friendly:int):String{
			if(friendly <= 29){
				return "点头之交  组队时双方内外攻同时上升 10点";
			}else if(friendly <= 150){
				return "泛泛之交  组队时双方内外攻同时上升 20点";
			}else if(friendly <= 499){
				return "君子之交  组队时双方内外攻同时上升 35点";
			}else if(friendly <= 999){
				return "莫逆之交  组队时双方内外攻同时上升 50点";
			}else{
				return "生死之交  组队时双方内外攻同时上升 80点";
			}
		}
		
		
	}
}