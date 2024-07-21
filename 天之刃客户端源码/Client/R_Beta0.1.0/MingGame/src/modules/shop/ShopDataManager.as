package modules.shop
{
	import com.managers.Dispatch;
	
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.mypackage.vo.BaseItemVO;

	/**
	 * 商店数据管理 
	 * @author huyongbo
	 * 
	 */	
	public class ShopDataManager
	{
		public static const BUYBACK_COUNT:int = 6;
		
		private var _searchResults:Array;
		private var shopDatas:Dictionary;
		private var npcShopTypes:Dictionary;
		
		public function ShopDataManager()
		{
			shopDatas = new Dictionary();	
			npcShopTypes = new Dictionary();
		}
		
		private static var _instance:ShopDataManager;
		public static function getInstance():ShopDataManager{
			if(_instance == null){
				_instance = new ShopDataManager();
			}
			return _instance;
		}
		
		/**
		 * 可购回物品数据集合 
		 */		
		private var _buyBacks:Array;
		public function get buyBacks():Array{
			return _buyBacks;
		}
		
		/**
		 * 加入回购项 
		 * @param vo
		 * 
		 */		
		public function addBuyBackItem(vo:BaseItemVO):void{
			if(_buyBacks == null){
				_buyBacks = new Array();
			}
			if(_buyBacks.length < BUYBACK_COUNT){
				var index:int = _buyBacks.push(vo);
			}else{
				_buyBacks.shift();
				_buyBacks.push(vo);
			}
			Dispatch.dispatch(ModuleCommand.BUYBACK_CHANGED);
		}
		/**
		 * 删除回购项 
		 * @param itemVO
		 * 
		 */	
		public function removeBuyBackItem(vo:BaseItemVO):int{
			if(_buyBacks){
				var index:int = _buyBacks.indexOf(vo);
				if(index != -1){
					_buyBacks.splice(index,1);
					Dispatch.dispatch(ModuleCommand.BUYBACK_CHANGED);
				}
				return index;
			}
			return -1;
		}
		/**
		 * 根据ID获取可回购项 
		 * @param id
		 * @return 
		 * 
		 */		
		public function getBuyBackItem(id:int):BaseItemVO{
			for each(var vo:BaseItemVO in _buyBacks){
				if(vo.oid == id){
					return vo;
				}
			}
			return null;
		}
		/**
		 * 设置搜索结果 
		 * @param values
		 * 
		 */		
		public function set searchResults(values:Array):void{
			_searchResults = values;
		}
		
		public function get searchResults():Array{
			return _searchResults;
		}
		/**
		 * 根据商店类型获取商店数据 
		 * 
		 */		
		public function getShopDatas(shopType:int):Array{
			return shopDatas[shopType];
		}
		/**
		 * 设置商店数据
		 * 
		 */		
		public function setShopDatas(shopType:int,_shopDatas:Array):void{
			shopDatas[shopType] = _shopDatas;
		}
		/**
		 * 获取物品(某人写的)
		 */		
		public function getItemByNPCID(itemId:int,npcId:int=-1):ShopItem {
			for each (var goodsItems:Array in shopDatas) {
				for each (var item:ShopItem in goodsItems) {
					if (item.id == itemId && (npcId == -1 || npcId == item.npcId)){
						return item;
					}
				}
			}
			return null;
		}
		/**
		 * 通过ID和商店ID获取物品 
		 * 
		 */		
		public function getItem(itemId:int, shopId:int):ShopItem {
			for each (var item:ShopItem in shopDatas[shopId]) {
				if (item.id == itemId) {
					return item;
				}
			}
			return null;
		}
		/**
		 * 根据NPC ID获取NPC商店的分类数据 
		 * 
		 */		
		public function getNPCShopTypes(shopType:int):Array{
			return npcShopTypes[shopType];
		}
		/**
		 * 设置NPC商店的分类数据
		 * 
		 */		
		public function setNPCShopTypes(npcId:int,shopDatas:Array):void{
			npcShopTypes[npcId] = shopDatas;
		}
	}
}