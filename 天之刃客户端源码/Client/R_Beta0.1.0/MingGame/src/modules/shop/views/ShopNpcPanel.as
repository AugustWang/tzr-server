package modules.shop.views
{
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
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
	
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.shop.ShopDataManager;
	import modules.shop.ShopItem;
	import modules.shop.ShopModule;
	
	import proto.line.p_shop_info;
	
	public class ShopNpcPanel extends BasePanel
	{
		private var tabBar:TabBar;
		private var tipTxt:TextField;
		private var fixBtn:Button;
		private var fixAllBtn:Button;
		private var tile:Sprite;
		private var buyBackView:BuyBackView;
		
		private var _npc:int;
		private var _shopMap:Dictionary = new Dictionary();
		private var _currentShopId:int=0;
		
		private var _item_pool:Array = new Array();
		
		public function ShopNpcPanel(key:String=null)
		{
			super(key);
		}
		
		override protected function init():void{
			initView();
		}
		
		private function initView():void{
			this.x = 510;
			this.y = 280;
			width = 312;
			height = 424;
			addSmaillTitleBG();
			addImageTitle("title_npcShop");
			addContentBG(88,8,25);
			
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
			tabBar.y = 5;
			tabBar.x = 20;
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,changeView);
			addChild(tabBar);
						
			buyBackView = new BuyBackView();
			buyBackView.x = 13;
			buyBackView.y = 237;
			addChild(buyBackView);
			
			var sellBtn:Button = ComponentUtil.createButton("出售",20,295,65,26,this);
			fixBtn = ComponentUtil.createButton("修理",118,295,65,26,this);
			fixAllBtn = ComponentUtil.createButton("修理全部",210,295,80,26,this);
		
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
			createItems();
			
			addEventListener(WindowEvent.CLOSEED,onClose);
			sellBtn.addEventListener(MouseEvent.CLICK,sellHandler);
			fixBtn.addEventListener(MouseEvent.CLICK,onFixHandler);
			fixAllBtn.addEventListener(MouseEvent.CLICK,onFixAll);
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			
		}
		
		public static const HPADDING:int=3;
		public static const VPADDING:int=3;
		public static const rowCount:int = 5;
		public static const columnCount:int = 7;
		private var viewItems:Array; 
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
		
		private function onClose(event:WindowEvent):void{
			if(event.currentTarget == this){
				ShopBuyView.getInstance().closeView();
			}
		}
		
		private function onAddedToStage(event:Event):void{
			var level:int = GlobalObjectManager.getInstance().user.attr.level;
			this.fixBtn.visible = this.fixAllBtn.visible = (level >= 10);
		}
		
		private function onFixHandler(evt:MouseEvent):void
		{
			CursorManager.getInstance().setCursor(CursorName.HAMMER);
		}
		
		private function onFixAll(evt:MouseEvent):void
		{
			if(CursorManager.getInstance().currentCursor == CursorName.HAMMER){
				CursorManager.getInstance().hideCursor(CursorName.HAMMER);
			}
			PackageModule.getInstance().fixEquip(0,false);
		}
		
		private function changeView(event:TabNavigationEvent):void{
			if(!this._shopMap[event.index] || this._currentShopId == this._shopMap[event.index]){
				return;
			}else{
				openShopView(this._shopMap[event.index]);
			}
		}
		
		private function buyHandler(event:MouseEvent):void{
			var img:ShopItemImg = event.currentTarget as ShopItemImg;
			if(!img.data){
				return
			}else{
				var buyView:ShopBuyView = ShopBuyView.getInstance();
				buyView.data = img.data;
				buyView.showView();
			}
		}
		
		private function initShops(shops:Array):void{
			var i:int=0;
			for(i=0 ;i<shops.length; i++){
				var shop:p_shop_info = shops[i] as p_shop_info;
				tabBar.addItem(shop.name,shop.name.length*15+20,25);
				this._shopMap[i] = shop.id;
			}
		}
		
		public function setSelect(index:int):void{
			if(tabBar){
				tabBar.selectIndex = index;
			}
		}
		
	
		private function upItemsView(shopId:int, items:Array):void{
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
				addDataLoading();
				ShopModule.getInstance().getShopGoods(shopId,this._npc);
			}else{
				upItemsView(shopId, items);
			}
		}
		
		override public function open():void{
			WindowManager.getInstance().openDistanceWindow(this);
			WindowManager.getInstance().centerWindow(this);
			this.x = this.x - int(this.width/2);
			PackManager.getInstance().popUpWindow(PackManager.PACK_1,this.x+this.width,this.y,false);
		}
		
		public function set npc(npc_id:int):void{
			tabBar.removeItems();
			this._npc = npc_id;
		}
		
		override public function set data(o:Object):void{
			var shops:Array = o as Array;
			initShops(shops);
			tabBar.selectIndex = 0;
		}
		
	}
}