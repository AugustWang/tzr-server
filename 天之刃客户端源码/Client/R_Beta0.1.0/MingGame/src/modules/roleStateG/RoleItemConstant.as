package modules.roleStateG
{
	
	public class RoleItemConstant
	{
		public static const VIEW_EQUI_ITEM:String="       查看        ";
		public static const FOLLOW_OTHERS_ITEM:String="       跟随        ";
		public static const PRIVATE_TALK_ITEM:String="       私聊        ";
		public static const DEAL_ITEM:String="       交易        ";
		public static const INVITE_TEAM_ITEM:String="       组队        ";
		public static const ADD_FRIEND_ITEM:String="    加为好友     ";
		public static const ADD_BLACK_LIST_ITEM:String="    加入黑名单  ";
		public static const SEND_FLOWER_ITEM:String="       送花        ";
		
		
		public static const PEACE_ITEM:String="   和平   "
		public static const TEAM_ITEM:String="   组队   "
		public static const FAMILY_ITEM:String="   门派   "
		public static const FACTION_ITEM:String="   国家   "
		public static const ALL_ITEM:String="   全体   "
		public static const KIND_EVIL_ITEM:String="   善恶   "
		
		public static const PEACE:String="和平";
		public static const TEAM:String="组队";
		public static const FAMILY:String="门派"
		public static const FACTION:String="国家";
		public static const ALL:String="全体";
		public static const KIND_EVIL:String="善恶";
		
		public static const FOLLOW_ITEM_NAME:String="FOLLOW_ITEM_NAME";
		
		public static const PEACE_TOOLTIP:String="该攻击模式下，不能攻击其他玩家";
		public static const ALL_TOOLTIP:String="该攻击模式下，对所有目标进行攻击会造成伤害"
		public static const TEAM_TOOLTIP:String="该攻击模式下，只对非队友目标攻击才能造成伤害"
		public static const FAMILY_TOOLTIP:String="该攻击模式下，只对非同一门派目标攻击才能造成伤害"
		public static const FACTION_TOOLTIP:String="该攻击模式下，只对非同一国家目标攻击才能造成伤害"
		public static const KIND_EVIL_TOOLTIP:String="该攻击模式下，只能攻击灰名、红名的玩家和怪物"
		public static var attackTips:Array=[PEACE_TOOLTIP, ALL_TOOLTIP, TEAM_TOOLTIP, FAMILY_TOOLTIP, FACTION_TOOLTIP, KIND_EVIL_TOOLTIP];
	}
}