package modules.Activity
{
	public class ActivityConstants
	{
		public static const ACT_TYPE_ACT:int = 1;
		public static const ACT_TYPE_SILVER:int = 2;
		public static const ACT_TYPE_EXP:int = 3;
		public static const ACT_TYPE_ITEM:int = 4;
		
		public static const STATE_NOTICE:int = 1;
		public static const STATE_START:int = 2;
		public static const STATE_PASS:int = 3;
		
		public static const ACTION_NAMES:Array = [{name:"个人拉镖",id:1001},{name:"除恶令任务",id:1002},{name:"门派普通Boss",id:1003},
			{name:"门派拉镖",id:1004},{name:"刺探军情",id:1005},{name:"守卫国土",id:1006},
			{name:"师徒同心副本",id:1007},{name:"大明英雄副本",id:1008}]; 
		
		public static const SPECIAL_ACTIVITY_KEY_LIST:Object = {
			1001:"等级排行榜活动",1002:"射手等级排行榜",1003:"侠客等级排行榜",
			1004:"医仙等级排行榜",1005:"神兵总分榜活动",1006:"强化排行榜活动",
			1007:"镶嵌排行榜活动",1008:"宠物总分榜活动",1009:"昨日送花榜活动",1010:"昨日鲜花榜活动",
			2001:"累计充值活动",2002:"单笔充值活动",2003:"累计消费活动",
			3001:"指定装备强化",3002:"指定装备镶嵌",3003:"指定装备评分",3004:"指定装备开孔",
			3005:"宠物悟性",3006:"宠物技能数",3007:"宠物资质",3008:"玩家等级活动"};
	}
}