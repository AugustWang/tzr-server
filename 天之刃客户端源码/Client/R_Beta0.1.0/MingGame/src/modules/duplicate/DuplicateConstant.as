package modules.duplicate
{
	public class DuplicateConstant
	{
		/**
		 * 与后台通信常量 
		 */	
		public static const DUPLICATE:String = "DUPLICATE";
		
		
		
		
		public static const GO_TO:String = "goto";
		
		public static const AWARD_EVENT:String = "awardEvent";//奖励界面事件
		public static const AWARD_EVENT_REFRESH_COUNT:String = "refreshCountEvent";//刷新积分
		public static const AWARD_EVENT_AWARD_GOODS:String = "awardGoodsEvent";//领取奖励
		public static const AWARD_EVENT_CLOSE_WIN:String = "closeWinEvent";//查看奖励
		
		public static const LEADER_EVENT:String = "leaderEvent";//队长帮助界面事件
		public static const LEADER_EVENT_NOTICE:String = "leaderNoticeEvent";
		
		public static const LEADER_EVENT_NOTICE_USE:String = "leaderNoticeUseEvent";
		
		
		public static const MEMBER_EVENT:String = "memberEvent";//队员界面事件
		public static const MEMBER_EVENT_USE_ITEM:String = "memberUseItemEvent";//队员使用道具
		
		public static var EDUCATE_FB_OP_TYPE_OPEN:int = 1;//打开师徒副本NPC界面
		public static var EDUCATE_FB_OP_TYPE_USE_LEADER_ITEM_INIT:int = 2;//进入副本自动打开队长界面
		public static var EDUCATE_FB_OP_TYPE_USE_LEADER_ITEM:int =3;//队长使用队长令牌打开界面
		public static var EDUCATE_FB_OP_TYPE_AWARD_VIEW:int = 4;//领取奖励界面
		public static var EDUCATE_FB_OP_TYPE_NOTICE:int = 5;//队长提醒队员操作
		public static var EDUCATE_FB_OP_TYPE_NOTICE_USE:int = 6;//提示队员使用道具操作
		
	}
}