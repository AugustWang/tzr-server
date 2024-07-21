package modules.shop.views
{
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import modules.shop.ShopDataManager;
	import modules.shop.ShopItem;
	import modules.shop.ShopModule;
	
	import proto.line.p_shop_info;

	/**
	 * 随身商店 
	 * @author huyongbo
	 * 
	 */	
	public class MyShopPanel extends BasePanel
	{
		public static const MY_SHOP_NPC_ID:int = 13888888;
		public static const HPADDING:int=3;
		public static const VPADDING:int=3;
		public static const rowCount:int = 5;
		public static const columnCount:int = 7;
		private var viewItems:Array; 
		
		private var tabBar:TabBar;
		private var tipTxt:TextField;
		private var tile:Sprite;
		private var buyBackView:BuyBackView;
		
		private var _shopMap:Dictionary = new Dictionary();
		private var _currentShopId:int=0;
		public function MyShopPanel()
		{
			super();
		}
		
		override protected function init():void{
			width = 312;
			height = 422;
			addSmaillTitleBG();
			addImageTitle("title_npcShop");
			addContentBG(88,8,24);
			
			var bitmap:Skin = Style.getSkin("packTileBg",GameConfig.T1_VIEWUI,new Rectangle(60,60,172,177));
			bitmap.setSize(292,252);
			bitmap.x = 11;
			bitmap.y = 33;
			addChild(bitmap);
			
			tile = new Sprite();
			tile.x = 15;
			tile.y = 32;
			addChild(tile);	
			
			tabBar = new TabBar();
			tabBar.x = 12;
			tabBar.selectIndex = -1;
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,changeView);
			addChild(tabBar);
						
			createItems();
			
			buyBackView = new BuyBackView();
			buyBackView.x = 13;
			buyBackView.y = 237;
			addChild(buyBackView);
			
			var sellBtn:Button = ComponentUtil.createButton("出售",20,295,65,26,this);
			sellBtn.addEventListener(MouseEvent.CLICK,sellHandler);
			
			var bottomBg:UIComponent = new UIComponent();
			bottomBg.width = 298;
			bottomBg.height = 57;
			bottomBg.x = 9;
			bottomBg.y = 320;
			Style.setBorderSkin(bottomBg);
			addChild(bottomBg);
			
			tipTxt = ComponentUtil.createTextField("",15,2,Style.textFormat,282,65,bottomBg);
			tipTxt.wordWrap = true;
			tipTxt.multiline = true;
			tipTxt.textColor = 0xffffff;
			
			var html:String = HtmlUtil.font("小提示","#ffff00");
			html += "\n1，鼠标点击道具图标即可进行购买。";
			html += "\n2，在背包栏拖动道具到商店，可以卖出道具。";
			tipTxt.htmlText = html;
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void{
			ShopModule.getInstance().getNPCShopTypes(MY_SHOP_NPC_ID);	
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		protected function createItems():void {
			viewItems = [];
			var size:int=rowCount * columnCount;
			for (var i:int=0; i < size; i++) {
				var item:ShopNpcItemView = new ShopNpcItemView();
				item.addEventListener(MouseEvent.CLICK, buyHandler);
				var row:int=i / columnCount;
				var column:int=i % columnCount;
				item.x=4 + column * item.width + column * HPADDING;
				item.y=5 + row * item.height + row * VPADDING;
				tile.addChild(item);
				viewItems.push(item);
			}
		}
		
		private function sellHandler(event:MouseEvent):void{
			if(CursorManager.getInstance().currentCursor != CursorName.SELL){
				CursorManager.getInstance().setCursor(CursorName.SELL);
				CursorManager.getInstance().enabledCursor = false;
			}else if(CursorManager.getInstance().currentCursor == CursorName.SELL){
				CursorManager.getInstance().enabledCursor = true;
				CursorManager.getInstance().hideCursor(CursorName.SELL);
			}
		}
		
		override protected function closeHandler(event:CloseEvent=null):void{
			super.closeHandler(event)
			ShopBuyView.getInstance().closeView();
		}
		
		private function changeView(event:TabNavigationEvent):void{
			if(_shopMap[event.index] == null || _currentShopId != _shopMap[event.index]){
				addDataLoading();
				openShopView(_shopMap[event.index]);
			}
		}
		
		private function buyHandler(event:MouseEvent):void{
			var shopItem:ShopItemImg = event.currentTarget as ShopItemImg;
			if(shopItem.data){
				var buyView:ShopBuyView = ShopBuyView.getInstance();
				buyView.data = shopItem.data;
				buyView.showView();
			}
		}
		
		private function createTabItems(shops:Array):void{
			var i:int=0;
			for(i=0 ;i<shops.length; i++){
				var shop:p_shop_info = shops[i] as p_shop_info;
				tabBar.addItem(shop.name,shop.name.length*15+20,25);
				this._shopMap[i] = shop.id;
			}
		}
		
		private function renderItems(shopId:int, items:Array):void{
			removeDataLoading();
			var filterArr:Array = new Array();
			for each(var itemTmp:ShopItem in items){
				if(itemTmp.isCanBuy){
					filterArr.push(itemTmp);
				}
			}
			var size:int = rowCount*columnCount;
			for(var i:int=0 ;i<size; i++){
				var view:ShopNpcItemView = viewItems[i] as ShopNpcItemView;
				if(filterArr[i] != null){
					var item:ShopItem = filterArr[i] as ShopItem;	
					view.data = item;
				}else{
					view.rmImg();
				}
			}
			this._currentShopId = shopId;
		}
		
		public function openShopView(shopId:int):void{
			var items:Array = ShopDataManager.getInstance().getShopDatas(shopId);
			if(!items || items.length < 1){
				ShopModule.getInstance().getShopGoods(shopId,MY_SHOP_NPC_ID);
			}else{
				renderItems(shopId, items);
			}
		}
		
		override public function set data(values:Object):void{
			var shopInfos:Array = values as Array;
			createTabItems(shopInfos);
			tabBar.selectIndex = 0;
		}
		
	}
}