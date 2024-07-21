package modules.family
{
	import com.common.GlobalObjectManager;
	import com.loaders.CommonLocator;
	import com.utils.MoneyTransformUtil;

	public class FamilyConstants
	{
		/******消息返回常量定义*******/
		
		public static const ZZ:int = 3;
		public static const F_ZZ:int = 2;
		public static const ZY:int = 1;
		public static const NWS:int = 4;
		public static const FILTER_WORDS:RegExp = /恶霸|穷凶极恶|十大恶人|护国精英|护国英雄|初级导师|中级导师|高级导师|一代名师|武林高手|盖世豪侠|武林至尊|独孤求败|掌门|长老|内务使|左护法|右护法|大英雄|帮主|副帮主|国王|皇帝|国家|云州|沧州|幽州|内阁大臣|大将军|锦衣卫指挥使|管理员/g;
		//门派招收人数上限
		public static const counts:Array = [30,30,35,40,50,55,60];
		//门派招收副族长上限
		public static const FZZ_COUNTS:Array = [1,1,1,2,2,3,3];
		//可召唤Boss等级
		public static const CALL_BOSS_LEVEL:Array = [0,20,40,60,80,100,120];
		//门派升级条件
		public static const LEVELUP_CONDITION:Array = [[0,0],[2000,0],
													 [30000,80],
													 [200000,280],
													 [1000000,800],
													 [3500000,3000],
													 [10000000,10000]];

		//门派维护成本
		public static const KEEP_COST:Array = [[0,0],[1000,1],[2000,3],[5000,6],[10000,10],[30000,15],[100000,50]];
		
		public static const YBC_TYPE_NORMAL:int = 1; //普通镖车
		public static const YBC_TYPE_HIGH:int = 2; //高级镖车
		
		//帮众变灰的条件： 不在线的天数。 14天   单位 ：天
		public static const OFF_LINE_LONG:int=14;
		
		/**
		 * 自己所属门派拉镖的当前状态 
		 */		
		public static const YBC_UN_PUBLISH:int = 0; //未发布
		public static const YBC_PUBLISH_ING:int = 1; //发布中
		public static const YBC_PUBLISH_ED:int = 2; //发布后
		
		/**
		 * 帮众在拉镖中的状态 
		 */		
		public static const JOIN_YBC:int = 1;//加入了
		public static const UN_JOIN_YBC:int = 2;//未加入
		
		
		private static var xml:XML;
		public static function getMoney(type:int):Number{
			if(xml == null){
				xml = CommonLocator.getXML(CommonLocator.FAMILY_YBC);
			}
			var level:int = GlobalObjectManager.getInstance().user.attr.level;
			var results:XMLList = xml..ybc.(@lv == level);
			if(results.length() > 0){
				if(type == YBC_TYPE_NORMAL){
					return Number(results[0].@common); 
				}else{
					return Number(results[0].@advance);
				}
			}
			return 0;
		}
		private static const costArr:Array = [0,1000,3000,10000,30000,50000];
		public static function newDepotMoney(depotId:int):String
		{
			var cost:Number = costArr[depotId-1];
			var str:String = "开通第"+ depotId +"个仓库需要消耗门派资金" + MoneyTransformUtil.silverToOtherString(costArr[depotId-1]) +"，你确定开通吗？";
			return str;
		}
	}
}