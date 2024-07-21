package modules.trading.tradingManager
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.utils.PathUtil;
	
	import flash.events.EventDispatcher;
	import flash.events.TextEvent;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.system.SystemConfig;
	import modules.trading.TradingModule;
	import modules.trading.vo.TradingGoodVo;
	
	import proto.common.p_trading_goods;
	
	public class TradingManager extends EventDispatcher
	{
		public static var current_trading_npcId:int;
		public static var trading_goods_npcId:int;
		public static var IS_LOCK:Boolean;
		
		//写死的东西
		public static const BOOK_TYPE:int = 10100030;
		public static const EX_POINT_P_BOOK:int = 5;
		public static const TRADING_LV:int = 30;
		
		
		
		
		public function TradingManager()
		{
			super();
		}
		private static var instance:TradingManager;
		public static function getInstance():TradingManager
		{
			if(!instance)
			{
				instance = new TradingManager();
			}
			
			return instance;
		}
		/**
		 * 商贸寻路 
		 * @param npcName
		 * 
		 */		
		public function goToScenceByName(event:TextEvent):void
		{
			var args:Array = new Array();
			if(event.text.indexOf("t_npcid=") != -1){
				args =event.text.split("t_npcid=");
				var nzNpcId:int=int(args[1]);
				PathUtil.findNpcAndOpen(nzNpcId);
			}else if(event.text.indexOf("f_npcid=") != -1){
				args =event.text.split("f_npcid=");
				var npcId:int=int(args[1]);
				if(GlobalObjectManager.getInstance().user.base.faction_id == 1){
					npcId = npcId + 1000000;
				}
				if(GlobalObjectManager.getInstance().user.base.faction_id == 2){
					npcId = npcId + 2000000;
				}
				if(GlobalObjectManager.getInstance().user.base.faction_id == 3){
					npcId = npcId + 3000000;
				}
				PathUtil.findNpcAndOpen(npcId);
			}
		}
		
		
		public function transRoleVoArr(arr:Array):Array
		{
			if(!arr)
				return null;
			var shoparr:Array = TradingModule.getInstance().getShopArr();
			
			var roleArr:Array = new Array();
			for(var i:int=0;i<arr.length;i++)
			{
				var trading_good:p_trading_goods = arr[i] as p_trading_goods;
				var vo:TradingGoodVo = new TradingGoodVo();
				var obj:Object = {};
				
//				vo.name = trading_good.name;
				vo.num = trading_good.number;
				vo.order_index = trading_good.order_index;
				vo.buy_price = trading_good.price;
				vo.type_id = trading_good.type_id;
				vo.npcId = trading_goods_npcId;
				vo.showType = 1;
				for(var j:int =0;j<shoparr.length;j++)
				{
					var shop_good:TradingGoodVo = shoparr[j] as TradingGoodVo;
					if(shop_good && vo.type_id == shop_good.type_id)
					{
						if(shop_good.buy_price > 0){
							vo.sale_price = shop_good.buy_price;
						}else{
							vo.sale_price = shop_good.sale_price;
						}
						break;
					}
				}
				
				obj = TradingLocator.getInstance().getObject(trading_good.type_id ,trading_goods_npcId);
				if(obj)
				{
					vo.url = GameConfig.ROOT_URL + obj.url;
					vo.desc = obj.desc;
					vo.name = obj.name;
				}
				roleArr.push(vo);
			}
			
			
			return roleArr;
		}
		public function transShopVoArr(arr:Array):Array
		{
			if(!arr)
				return null;
//			sortShopArr(arr);
			
			var shopArr:Array = new Array();
			var tmpArr:Array = new Array();
			var roleArr_len:int = TradingModule.getInstance().getRoleArr().length;
			if(roleArr_len>0)
			{
				tmpArr = TradingModule.getInstance().getRoleArr();
			}
//			if(arr.length>0)
//				shopArr.length = arr.length;
			for(var i:int=0;i<arr.length;i++)
			{
				var trading_good:p_trading_goods = arr[i] as p_trading_goods;
				var vo:TradingGoodVo = new TradingGoodVo();
				var obj:Object = {};
//				vo.name = trading_good.name;
				vo.num = trading_good.number;
				vo.order_index = trading_good.order_index;
				vo.sale_price = trading_good.price;
				vo.type_id = trading_good.type_id;
				vo.npcId = current_trading_npcId;
				vo.order_index = trading_good.order_index;
				vo.buy_price = trading_good.sale_price;
				vo.showType = 2;
				obj = TradingLocator.getInstance().getObject(trading_good.type_id ,current_trading_npcId);
				vo.url = GameConfig.ROOT_URL + obj.url;
				vo.desc = obj.desc;
				vo.name = obj.name;
				if(vo.order_index<1)
				{
					shopArr.unshift(vo);
				}else{
					shopArr[vo.order_index-1] = vo;
				}
				
				if(roleArr_len>0)
				{
					for(var j:int=0;j<roleArr_len;j++)
					{
						var roGood:TradingGoodVo = tmpArr[j] as TradingGoodVo;
						if(roGood.type_id == vo.type_id)
						{
							roGood.sale_price = vo.sale_price;
						}
					}
				}
//				shopArr.push(vo);
			}
			
			
			return shopArr;
		}
		
		 
		public function setFailreson():void
		{
			var str:String = "";
			var level:int = GlobalObjectManager.getInstance().user.attr.level;
			if(level<TRADING_LV)
			{
				str += "等级未达到30级，不能商贸\n" +
					"<font color='#ffff00'><a href='event:TO_LV_UP#0'><u>当前该如何升级？</u></a></font>\n";
			}
			if(GlobalObjectManager.getInstance().user.base.family_id<=0)
			{
				str += "未加入门派，不能商贸\n" +
					"<font color='#ffff00'><a href='event:OPEN_FAMILY#1'><u>我想加入门派</u></a></font>\n";
			}
			if(GlobalObjectManager.getInstance().user.attr.active_points<10)
			{
				str += "活跃度不足，本次商贸只能获得绑定银子\n" +
					"<font color='#ffff00'><a href='event:OPEN_ACTIVE#2'><u>我想参加活动，获得活跃度</u></a></font>";
			}
			
			BroadcastSelf.logger(str);
		}
		
		public function isWeekDate():Boolean
		{
			var flag:Boolean = false;
			var times:Number = (SystemConfig.serverTime)* 1000 ;//24*3600
//			trace("===============================" + times );
			var date:Date = new Date(times);
			
			var index:int = date.day;//DateUtil.getWeekIndex(date);
//			trace("===============================" + index);
			if(index == 0)
			{
				flag = true;
			}
			
			return flag;
		}
		
		private function sortShopArr(arr:Array):void
		{
			
		}
		
	}
}

