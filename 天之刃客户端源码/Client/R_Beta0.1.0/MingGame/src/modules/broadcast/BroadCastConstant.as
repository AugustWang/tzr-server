package modules.broadcast
{
	public class BroadCastConstant
	{
		public static const POPUP_MESSAGE_WINDOW:String = "POPUP_MESSAGE_WINDOW";
		
		public static const BROADCAST:String = "BROADCAST";
		
		public static const BROADCAST_GENERAL:String = "BROADCAST_GENERAL";
		
		public static const BROADCAST_COUNTDOWN:String = "BROADCAST_COUNTDOWN";
		
		public static const BROADCAST_LABA:String = "BROADCAST_LABA";
		
		public static const OPERATING_MSG:int = 2905;   // 操作消息(预留接口)
		
		public static const SYSTEM_MSG:int = 2906;     // 系统消息,
		
		public static const COUNT_DWON_MSG:int = 2907;// 倒计时消息,
		
		public static const SPEAKER_MSG:int = 2908;    // 传音消息
		
		public static const CENTRAL_BROADCASTING_MSG:int = 2909;      //  中央广播消息
		
		public static const CHAT_CHANNEL_MSG:int = 2910;              //聊天频道消息
		
		public static const POPUP_WINDOW_MSG:int = 2911;              //弹窗消息
		
		public static const NULL_SUB_TYPE_MSG:int = 2912 ;        //表示没和消息子类型,
		public static const DUPLICATE_TIME_MSG:int = 2913;              //副本时间消息
		public static const TASK_TIME_MSG:int = 2914;             //任务时间消息
		
		public static const WORLD_MSG:int = 2915;             //世界
		public static const FACTION_MSG:int = 2916;           //国家
		public static const FAMILY_MSG:int = 2917;            //门派
		public static const TEAM_MSG:int = 2918;              //组队
		public static const PERSON_MSG:int = 2919;            //私人
		
		public static const ATTACK:String="ATTACK";
		
		public static const SEND_TO_TOOLTIP:String = "使用【传送卷】立即传送到遇袭地，官员五分钟内免费传送。"//官员免费。";
		
		public static const WALK_TO_TOOLTIP:String = "免费自动寻路过遇袭地点。";
		public static const SHOW:String='show';
		
		
		public static function getCountryStr(id:int):String
		{
			var str:String ="<font color='#ffffff'>【世】</font>";//"<font color='#ffffff'>【世】</font>"+
			switch(id)
			{
				case 1:
					str = "<font color='#00ff00'>【洪】</font>"
					
					break;
				case 2:
					str = "<font color='#f600ff'>【永】</font>"
					
					break;
				case 3:
					str = "<font color='#00ccff'>【万】</font>"
					
					break;
				default : break;
			}
			return str;
		}
		
	}
}


