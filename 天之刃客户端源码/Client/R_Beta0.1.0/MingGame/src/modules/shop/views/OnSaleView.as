package modules.shop.views
{
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	import modules.ModuleCommand;
	import modules.shop.ShopConstant;
	import modules.shop.ShopDataManager;
	import modules.shop.ShopModule;

	public class OnSaleView extends Sprite implements IShopSellView
	{
		private var shopTileView:ShopTileView;
		private var onSaleBg:UIComponent;
		private var onsalePlcard:TextField;
		private var rushItems:Array;
		
		public function OnSaleView()
		{
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			initView();
		}
		
		private function initView():void{
			shopTileView = new ShopTileView();
			shopTileView.y = 2;
			shopTileView.HPADDING = 1;
			shopTileView.columns = 2;
			addChild(shopTileView);
			
			onSaleBg = new UIComponent();
			onSaleBg.y = 6;
			onSaleBg.x = 430;
			onSaleBg.width = 216;
			onSaleBg.height = 352;
			Style.setBorderSkin(onSaleBg);
			addChild(onSaleBg);
			
			var titleBitmap:Bitmap = Style.getBitmap(GameConfig.SHOP_UI,"rushTitle");
			titleBitmap.x = onSaleBg.width - titleBitmap.width >> 1;
			titleBitmap.y = 3;
			onSaleBg.addChild(titleBitmap);
			
			rushItems = new Array();
			for(var i:int=0; i<3; i++){
				var rushItem:ShopRushGoodsItem = new ShopRushGoodsItem();
				rushItem.x = 3;
				rushItem.y = i*90+32;
				onSaleBg.addChild(rushItem);
				rushItems.push(rushItem);
			}
			
			onsalePlcard = ComponentUtil.createTextField("", 10, onSaleBg.height-38, Style.themeTextFormat, onSaleBg.width-20, 52, onSaleBg);
			onsalePlcard.wordWrap = true;
			onsalePlcard.multiline = true;
			onsalePlcard.htmlText = "限量抢购商品每天中午12:00刷新，售完即止。";
			ShopModule.getInstance().getShopGoods(ShopConstant.TYPE_ON_RUSH);
			Dispatch.register(ModuleCommand.RUSH_GOODS_UPDATE,updateRushGoods);
		}
		
		public function set dataProvider(values:Array):void{
			if(shopTileView){
				shopTileView.dataProvider = values;
			}
		}
		
		public function set pageCount(value:int):void{
			if(shopTileView){
				shopTileView.pageCount = value;
			}
		}
		
		public function updateRushGoods():void{
			var rushShopDatas:Array = ShopDataManager.getInstance().getShopDatas(ShopConstant.TYPE_ON_RUSH);
			for(var i:int=0;i<3;i++){
				var rushItem:ShopRushGoodsItem = rushItems[i];
				if(rushShopDatas){
					rushItem.shopItem = rushShopDatas[i]
				}else{
					rushItem.shopItem = null;
				}
			}
		}
		
	}
}