package modules.shop.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.ButtonPageBar;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.ming.events.ComponentEvent;
	import com.ming.events.PageEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.JSUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import modules.mypackage.managers.ItemLocator;
	import modules.shop.ShopConstant;
	import modules.shop.ShopDataManager;
	import modules.shop.ShopModule;
	import modules.stat.StatConstant;
	import modules.stat.StatModule;
	
	import proto.common.p_role_attr;
	
	public class ShopPanel extends BasePanel
	{	
		private static const DEFAULT_TEXT:String = "请输入搜索内容";
		private var views:Dictionary;
		private var shopNav:TabNavigation;
		private var rechargeBtn:Button;
		private var pageBar:ButtonPageBar;
		private var goldText:TextField;
		private var bindGoldText:TextField;
		private var input:TextInput;
		private var searchButton:Button;
		
		private var onSaleView:OnSaleView;
		private var shopTileView:ShopTileView;
		private var fashionShopView:FashionShopView;
		
		private var currentView:IShopSellView;
		private var currentShopType:int;
		public function ShopPanel()
		{
			super();
		}
		
		override protected function init():void{
			width = 671;
			height = 460;
			  
			addTitleBG(448);
			addImageTitle("title_shop");
			addContentBG(30,8,25);
			
			onSaleView = new OnSaleView();
			shopTileView = new ShopTileView();
			shopTileView.y = 2;
			shopTileView.x = 5;
			shopTileView.HPADDING = 2;
			fashionShopView = new FashionShopView();
			onSaleView.addEventListener(ShopConstant.SHOP_PAGE_CHANGED,shopPageHandler);
			shopTileView.addEventListener(ShopConstant.SHOP_PAGE_CHANGED,shopPageHandler);
			fashionShopView.addEventListener(ShopConstant.SHOP_PAGE_CHANGED,shopPageHandler);
			
			views = new Dictionary();
			views[ShopConstant.TYPE_ON_SALE] = onSaleView;
			views[ShopConstant.TYPE_SUNDRY] = shopTileView;
			views[ShopConstant.TYPE_STOVE] = shopTileView;
			views[ShopConstant.TYPE_STONE] = shopTileView;
			views[ShopConstant.TYPE_PET] = shopTileView;
			views[ShopConstant.TYPE_DIY] = fashionShopView;
			views[ShopConstant.TYPE_BIND] = shopTileView;
			views[ShopConstant.TYPE_ONE_YUAN] = shopTileView;
			
			shopNav = new TabNavigation();
			shopNav.addItem("热卖",onSaleView,50,25);
			shopNav.addItem("杂货",shopTileView,50,25);
			shopNav.addItem("锻造",shopTileView,50,25);
			shopNav.addItem("宝石",shopTileView,50,25);
			shopNav.addItem("宠物",shopTileView,50,25);
			shopNav.addItem("个性",fashionShopView,50,25);
			shopNav.addItem("绑定商店",shopTileView,65,25);
			shopNav.addItem("一元店",shopTileView,60,25);
			shopNav.tabBarPaddingLeft = 10;
			shopNav.x = 10;
			shopNav.width = 700;
			shopNav.height = 417;
			shopNav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,tabChangedHandler);
			addChild(shopNav);
			
			pageBar = new ButtonPageBar();
			pageBar.hideGotoBar = true;
			pageBar.x = 15;
			pageBar.y = 390;
			pageBar.addEventListener(PageEvent.CHANGED,changePageHandler);
			addChild(pageBar);
			
			var goldBack:Sprite = new Sprite();
			goldBack.x = 215;
			goldBack.y = pageBar.y+2;
			addChild(goldBack);
			
			ComponentUtil.createTextField("元宝：",1, 1,Style.themeTextFormat,40,18,goldBack);
			ComponentUtil.createTextField("绑定元宝：",170, 1,Style.themeTextFormat,64,18,goldBack);
			
			goldText = ComponentUtil.createTextField("",42, 1,Style.textFormat,125,18,goldBack);
			var back:UIComponent = ComponentUtil.createUIComponent(goldText.x - 5,goldText.y-2,120,25);
			back.bgSkin = Style.getInstance().textInputSkin;
			goldBack.addChildAt(back,0);
			
			bindGoldText = ComponentUtil.createTextField("",243, 1,Style.textFormat,125,50,goldBack);
			back = ComponentUtil.createUIComponent(bindGoldText.x - 5,bindGoldText.y-2,120,25);
			back.bgSkin = Style.getInstance().textInputSkin;
			goldBack.addChildAt(back,0);
			
			rechargeBtn = ComponentUtil.createButton("快速充值",bindGoldText.x+bindGoldText.width+5,0,70,26,goldBack);
			Style.setYellowButtonStyle(rechargeBtn);
			rechargeBtn.textColor = 0xffffff;
			rechargeBtn.textBold = true;
			rechargeBtn.setToolTip("充值比例 1：10",0);
			rechargeBtn.addEventListener(MouseEvent.CLICK,rechargeHandler);
			
			createSearchView();
			
			updateGold();
		}
		
		private function createSearchView():void{
			if(GameParameters.getInstance().debug == "true"){
				shopNav.addItem("搜索结果",shopTileView,70,25);
				views[ShopConstant.TYPE_SEARCH] = shopTileView;
				input = ComponentUtil.createTextInput(width-185,1,100,25,this);
				input.text = DEFAULT_TEXT;
				searchButton = ComponentUtil.createButton("搜索",width-77,1,70,25,this);
				input.addEventListener(ComponentEvent.ENTER,searchHandler);
				input.addEventListener(FocusEvent.FOCUS_IN,focusHandler);
				input.addEventListener(FocusEvent.FOCUS_OUT,focusHandler);
				searchButton.addEventListener(MouseEvent.CLICK,searchHandler);
			}
		}
		
		private function focusHandler(event:FocusEvent):void{
			if(event.type == FocusEvent.FOCUS_IN && input.text == DEFAULT_TEXT){
				input.text = "";
			}else if(input.text == ""){
				input.text = DEFAULT_TEXT;
			}
		}
				
		private function searchHandler(event:Event):void{
			var searchList:Array = new Array();
			var content:String = StringUtil.trim(input.text);
			if(content != "" && content != DEFAULT_TEXT){
				var itemxml:XML = ItemLocator.getInstance().itemsXML;
				var goodsName:String = "";
				for each(var item:XML in itemxml.item){
					goodsName = item.@name;
					if(goodsName.indexOf(content)>=0){
						searchList.push( int(item.@id));
					}
				}
				var equipxml:XML = ItemLocator.getInstance().equipsXML;
				for each(var equipitem:XML in equipxml.equip){
					goodsName = equipitem.@name;
					if(goodsName.indexOf(content)>=0){
						searchList.push(int(equipitem.@id));
					}
				}
				var stonexml:XML = ItemLocator.getInstance().stonesXML;	
				for each(var stoneitem:XML in stonexml.stone){
					goodsName = stoneitem.@name;
					if(goodsName.indexOf(content)>=0){
						searchList.push( int(stoneitem.@id));
					}
				}
				addDataLoading();
				ShopModule.getInstance().searchGoods(searchList, 0);
			}
		}
		
		public function updateSearchResult():void{
			removeDataLoading();
			if(currentShopType == ShopConstant.TYPE_SEARCH){
				currentView.dataProvider = ShopDataManager.getInstance().searchResults;
			}else{
				selectedIndex(8);
			}
		}
		
		public function selectedIndex(index:int):void{
			shopNav.selectedIndex = index;
		}
		
		private function tabChangedHandler(event:TabNavigationEvent):void{
			var index:int = event.index;
			currentShopType = ShopConstant.SHOP_TYPES[index];
			currentView = views[currentShopType];
			if(currentShopType == ShopConstant.TYPE_SEARCH){
				currentView.dataProvider = ShopDataManager.getInstance().searchResults;
			}else{
				updateDataProvider();
			}
		}
		
		public function updateDataProvider():void{
			if(currentView){
				var shopDatas:Array = ShopDataManager.getInstance().getShopDatas(currentShopType);
				if(shopDatas == null){
					addDataLoading();
					ShopModule.getInstance().getShopGoods(currentShopType);
				}else{
					removeDataLoading();
					currentView.dataProvider = shopDatas;
				}
			}
		}
		
		private function changePageHandler(event:PageEvent):void{
			currentView.pageCount = event.pageNumber;
		}
		
		private function shopPageHandler(event:ParamEvent):void{
			pageBar.totalPageCount = int(event.data);	
			pageBar.currentPage = 1;
		}
		
		private function rechargeHandler(evt:MouseEvent):void{
			JSUtil.openPaySite();
			StatModule.getInstance().addButtonHandler(StatConstant.VALUE_SHOP_PAY);
		}
		
		public function updateGold():void{
			var user:p_role_attr = GlobalObjectManager.getInstance().user.attr;
			goldText.text =  user.gold.toString();
			bindGoldText.text = user.gold_bind.toString();
		}
	}
}