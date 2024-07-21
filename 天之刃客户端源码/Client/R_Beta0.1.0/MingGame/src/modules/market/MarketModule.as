package modules.market
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	
	import flash.display.Loader;
	import flash.events.Event;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.deal.DealConstant;
	import modules.help.HelperPanel;
	import modules.market.view.MarketWindow;
	import modules.mypackage.vo.BaseItemVO;
	
	import mx.core.mx_internal;
	
	import proto.line.m_stall_buy_toc;
	import proto.line.m_stall_buy_tos;
	import proto.line.m_stall_list_toc;
	import proto.line.m_stall_list_tos;
	
	public class MarketModule extends BaseModule
	{
		private static var instance:MarketModule;
		
		private var sourceLoader:SourceLoader;	
		
		public var marketManager:MarketDataManager=null;
		
		private var marketWindow:MarketWindow;
		
		//资源路径
		private var url:String = "com/assets/market/market.swf";
		
		public function MarketModule(newClass:NewClass)
		{
			super();
		}
		
		public static function getInstance():MarketModule
		{
			if(instance == null)
			{
				instance = new MarketModule(new NewClass());
			}
			return instance;
		}
		
		override protected function initListeners():void
		{
			this.addSocketListener(SocketCommand.STALL_LIST, onGetDataList);
			this.addSocketListener(SocketCommand.STALL_BUY,buyResult);
			
			this.addMessageListener(ModuleCommand.ENTER_GAME, onEnterGame);
			this.addMessageListener(ModuleCommand.PACKAGE_MONEY_CHANGE,updateMoney);
		}
		
		private function onEnterGame():void{
			if(marketManager == null){
				marketManager = new MarketDataManager();
			}
		}
		
		public function getLoader():SourceLoader
		{
			if(sourceLoader != null)
			{
				return sourceLoader;
			}
			return null;
		}
		
		private function loadSource():void
		{
			if(sourceLoader == null){
				sourceLoader = new SourceLoader();
			}
			sourceLoader.loadSource(GameConfig.ROOT_URL+url,"正在加载市场UI",onComplete);
		}
		
		private function onComplete():void
		{
			if(marketWindow == null)
			{
				marketWindow = new MarketWindow(sourceLoader);
			}
			sendData(marketManager.infoViewData.type,1,marketManager.infoViewData.typeid);
		}
		
		private function updateMoney():void
		{
			if(marketWindow != null)
			{
				marketWindow.moneyChange();
			}
		}
		
		public function buyResult(msg:m_stall_buy_toc):void
		{
			// to do 
			if(!msg.succ)
			{
//				Alert.show(msg.reason, "提示",null,null,"确定","",null,false);
				return;
			}
			//通知改变钱　　角色模块的钱
			
			if(goodsVO != null) {
				var coast:int = goodsVO.unit_price * goodsVO.num;
				todoChangeMoney(-coast, goodsVO.price_type);
			}
			//重新获取列表
			if (WindowManager.getInstance().isPopUp(marketWindow)){
				var data:Array = marketManager.deteleBugGood(msg);
				marketWindow.updateData(data);
			}
//				onGetType(type);
		}
		
		private function todoChangeMoney(changeMoney:int, moneyType:int):void
		{
			if(!changeMoney||changeMoney==0)
				return;
			
			var mType:String;
			if(moneyType == DealConstant.STALL_PRICE_TYPE_SILVER)
			{
				mType = DealConstant.SILVER; // RoleStateConstant.SILVER;
			} else if (moneyType == DealConstant.STALL_PRCIE_TYPE_GOLD) {
				mType = DealConstant.GOLD;
			} else {
				mType = DealConstant.SILVER_BIND;
			}
			
			var obj:Object = new Object();
			obj.num = changeMoney;
			obj.moneyType = mType;		
			setStallMoney(obj);
		}
		
		private function setStallMoney(moneyObj:Object):void
		{
			var moneyNum:int=(moneyObj.num as int);
			switch (moneyObj.moneyType)
			{
				case DealConstant.GOLD:
					GlobalObjectManager.getInstance().user.attr.gold=GlobalObjectManager.getInstance().user.attr.gold + moneyNum;
					break;
				case DealConstant.SILVER:
					GlobalObjectManager.getInstance().user.attr.silver=GlobalObjectManager.getInstance().user.attr.silver + moneyNum;
					break;
				case DealConstant.SILVER_BIND:
					GlobalObjectManager.getInstance().user.attr.silver_bind=GlobalObjectManager.getInstance().user.attr.silver_bind + moneyNum;
					break;
				default:
					break;
			}
			changeMoney();
		}
		
		private function changeMoney():void
		{
			dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
		}
		
		private var goodsVO:BaseItemVO;
		/**
		 * 购买物品 
		 * @param roleID    摊主的roleId
		 * @param goodsID
		 * @param num
		 * 
		 */		
		public function requestBuy(roleID:int,goodsID:int,num:int,currentPrice:int,goodVO:BaseItemVO):void
		{
			this.goodsVO = goodVO;
			this.goodsVO.num = num;
			
			var buy_tos:m_stall_buy_tos = new m_stall_buy_tos();
			buy_tos.goods_id = goodsID;
			buy_tos.role_id = roleID;
			buy_tos.number = num;
			buy_tos.goods_price = currentPrice;
			buy_tos.buy_from = 2;
			this.sendSocketMessage(buy_tos);
		}
		
		
		//type类型，page页数，typeid搜索才用，sort_type，1是价格2是数量，is_reverse默认是false，从便宜到贵，从多到少，is_gold_first默认是true元宝优先，和银子优先
		public function sendData(type:int=0,page:int=1,typeid:Array=null,sort_type:int=3,is_reverse:Boolean=false,is_gold_first:Boolean=false,min_level:int=0,max_level:int=0,color:int=0,pro:int=0):void{
			marketManager.infoViewData.type = type;
			marketManager.infoViewData.page = page;
			if(typeid == null){
				typeid = [];
			}
			marketManager.infoViewData.typeid = typeid;
			marketManager.infoViewData.sort_type = sort_type;
			marketManager.infoViewData.is_reverse = is_reverse;
			marketManager.infoViewData.is_gold_first = is_gold_first;
			marketManager.infoViewData.min_level = min_level;
			marketManager.infoViewData.max_level = max_level;
			marketManager.infoViewData.color = color;
			marketManager.infoViewData.pro = pro;
			this.sendSocketMessage(marketManager.infoViewData);
		}
		
		private function onGetDataList(vo:m_stall_list_toc):void
		{
			if(marketWindow != null){
				marketWindow.openWindow(vo);
				marketManager.resetGoodsList(vo.goods_list);
			}
		}
		
		public function openMarketView(index:int=0,searchArray:Array=null):void
		{
			marketManager.infoViewData.type = index;
			if(searchArray == null){
				searchArray = [];
			}
			marketManager.infoViewData.typeid = searchArray;
			
			if(marketWindow == null){
				loadSource();
			}else{
				if(WindowManager.getInstance().isPopUp(marketWindow) == true){
					closeMarketView();
				}else{
					sendData(index,1,searchArray);
				}
			}
		}
		
		public function closeMarketView():void{
			WindowManager.getInstance().removeWindow(marketWindow);
		}
	}
}

//实现单例,没有实质性作用
class NewClass{
	public function NewClass(){};
}