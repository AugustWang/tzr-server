package modules.shop
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.utils.ShareObjectUtil;
	
	import modules.system.SystemConfig;
	
	public class ShopConstant
	{
		/**
		 * 商店选项卡数据类型 
		 */		
		public static const TYPE_ON_RUSH:int = 40101;
		public static const TYPE_ON_SALE:int = 80115;
		public static const TYPE_SUNDRY:int = 80110;
		public static const TYPE_STOVE:int = 80111;
		public static const TYPE_STONE:int = 80112;
		public static const TYPE_PET:int = 80113;
		public static const TYPE_DIY:int = 80114;
		public static const TYPE_BIND:int = 80116;
		public static const TYPE_ONE_YUAN:int = 80117;
		public static const TYPE_SEARCH:int = 0;
		public static const SHOP_TYPES:Array = [TYPE_ON_SALE,TYPE_SUNDRY,TYPE_STOVE,TYPE_STONE,TYPE_PET,TYPE_DIY,TYPE_BIND,TYPE_ONE_YUAN,TYPE_SEARCH];
		public static const SHOP_PAGE_CHANGED:String = "SHOP_PAGE_CHANGED";
		
		
		public static const FASHIONBG:String = 'com/assets/fashionImg/fashionBg.png';
		public static const MOUNT_SHOP:int = 10117;
		public static const PET_SHOP:int = 10112;
		public static const MPHP_SHOP:int = 10106;
		public static const FAST_SHOP:int = 30100;
		public static const PEI_QI_ZHEN_YI_SHOU:int = 10112;     //奇珍异宠
		public static const PEI_CHONG_WU_YANG_CHENG:int = 10113; //宠物养成
		public static const PEI_CHU_JI_JI_NENG:int = 10114;      //初级技能
		public static const PEI_ZHONG_JI_NENG:int = 10122;       //中级技能
		public static const PEI_GAO_JI_NENG:int = 10115;         //高级技能
		public static const PEI_DING_JI_NENG:int = 10116;        //顶级技能
		public static const SHI_ZHUANG:String = "时装";
		public static const FIRST_SHOP:int = 10105;
		public static const VIP_SHOP:int = 10108;
		public static const FILL_BUTTON:String = "快速充值";
		public static const BUY_BUTTON:String = "购买";
		public static const NUM_TEXT:String = "数量";
		
		public static const SEARCH_BUTTON:String = "搜索";
		public static const FILTER_BUTTON:String = "筛选";
		public static const SEARCH_RESULT:String = "搜索结果"; 
		
		public static const COST:String = "花费";
		public static const MONEY_COPPER_COIN:String =　"铜钱";//copper coin
		public static const MONEY_SILVER:String =　"银子";
		public static const MONEY_GOLD:String =　"金币";
		
		public static const SUCCESS_BUY:String = "成功购买";
		public static const A:String = "个";
		public static const PE_SHOP:String = "宠物商店";
		
		public static const NCP_SHOP:String = "NCP_SHOP";
		
		public static const COIN:int = 1;
		public static const SILVER:int = 2;
		public static const GOLD:int = 3;
		public static const SILVER_TYPE:int = 1;
		public static const GOLD_TYPE:int = 2;
		
		public static const MEDIUM_SIZED_HP:String = "中型金创药";
		public static const MEDIUM_SIZED_MP:String = "中型内力药水";
		
		public static const SEARCH_WRONG:String = "<font color='#EE0000'>没有搜索到相应的物品，可能是以下情况：\n" +
			"1、目前商店中没有你想要搜索的目标\n" +
			"2、您输入的文字有误</font>";

		public static function getFashionImgById(oid:int):String
		{
			var url:String = "";
			var id:int = oid;
			if(id>30111150)
			{
				id = oid - 50;
			}
			url = GameConfig.ROOT_URL +'com/assets/fashionImg/'+ id + ".png"
			
			return url;
		}
		
		public static const NPC_SKILL:String = "技能";
		
		public static function getMoneyType(type:int):String
		{
			var str:String="";
			switch(type)
			{
				case 0:
					str = "不可卖"; 
					break;
				case 1:
					str = "银子";
					break;
				case 2:
					str = "元宝";;
					break;
				default : break;
				
			}
			
			return str;
		}
		
		public static var todayHasTip:Boolean = true;
		public static var todayHasInit:Boolean = false;
		
		public static function hasTip():Boolean{
			if(todayHasInit == false){
				var userId:int = GlobalObjectManager.getInstance().user.attr.role_id;
				var currentDate:Date = new Date();
				currentDate.time = SystemConfig.serverTime*1000;
				var key:String = "buyTip"+(currentDate.fullYear+"_"+currentDate.month+"_"+currentDate.day)+"_"+userId;
				var value:Object = ShareObjectUtil.read(key);
				if(value === 0){
					todayHasTip = false;
				}else{
					todayHasTip = true;
				}
				todayHasInit = true;
			}
			return todayHasTip;
		}
	}
}