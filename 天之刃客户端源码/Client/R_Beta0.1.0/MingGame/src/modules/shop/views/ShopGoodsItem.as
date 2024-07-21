package modules.shop.views
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.NumericStepper;
	import com.ming.ui.controls.TimerButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.shop.ShopConstant;
	import modules.shop.ShopItem;
	import modules.shop.ShopModule;

	public class ShopGoodsItem extends UIComponent{
		
		private var modify:Shape;
		private var titleText:TextField;
		private var oldPrice:TextField;
		private var oldPriceIcon:Bitmap;
		private var newPrice:TextField;
		private var newPriceIcon:Bitmap;
		private var goodsBg:Sprite;
		private var goodsImage:Image;
		private var countText:TextField;
		public var buyGoodsNum:NumericStepper;
		public var buyBtn:TimerButton;
		public var modifyColor:uint = 0xffffff;
		
		private var shopItemVo:ShopItem;
		private var point:Point;
		
		private var tf:TextFormat;
		public function ShopGoodsItem(){
			super();
			initView();
			
		}
		
		private function initView():void {
			width = 210;
			height = 90;
			
			Style.setItemBgSkin(this);
			
			goodsBg = Style.getSpriteBitmap(GameConfig.SHOP_UI, "shopItemBg");
			goodsBg.x = 7;
			goodsBg.y = 13;
			addChild(goodsBg);
			
			goodsImage = new Image();
			goodsImage.visible = false;
			goodsImage.mouseEnabled = true;
			goodsImage.x = 3;
			goodsImage.y = 3;
			goodsImage.width = 55
			goodsImage.height = 55;
			goodsImage.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
			goodsImage.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
			goodsImage.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			goodsBg.addChild(goodsImage);
			
			tf = Style.textFormat;
			tf.color=0xbcffa1;
			titleText = ComponentUtil.createTextField("", 74, 3, tf, width - 6, 20, this);
			titleText.filters=[Style.BLACK_FILTER];
			
			oldPrice = ComponentUtil.createTextField("", 74, 20, tf, 100, 20, this); 
			newPrice = ComponentUtil.createTextField("", 74, 40, tf, 100, 20, this);
			
			oldPriceIcon = new Bitmap();
			oldPriceIcon.x = width - 40;
			oldPriceIcon.y = oldPrice.y+3;
			addChild(oldPriceIcon);
				
			newPriceIcon = new Bitmap();
			newPriceIcon.x = width - 40;
			newPriceIcon.y = newPrice.y+3;
			addChild(newPriceIcon);
			
			createNumericStepper();
			
			buyBtn = new TimerButton();
			buyBtn.visible = false;
			buyBtn.textColor = 0xffff00;
			buyBtn.x = this.width - 58;
			buyBtn.y = 61;
			buyBtn.width = 55;
			buyBtn.height = 25;
			buyBtn.label = "购买";
			buyBtn.repeatCount = 1;
			buyBtn.visible = false;
			buyBtn.addEventListener(MouseEvent.CLICK,buyGoodsHandler);
			addChild(buyBtn);
		}
		
		protected function createNumericStepper():void{
			countText = ComponentUtil.createTextField("数量",74,62,tf,30,20,this);
			buyGoodsNum = new NumericStepper();
			buyGoodsNum.visible = false;
			buyGoodsNum.x = 100;
			buyGoodsNum.y = 61;
			buyGoodsNum.width = 50;
			buyGoodsNum.height = 25;
			buyGoodsNum.value = 1;
			buyGoodsNum.maxnum = 200;
			buyGoodsNum.minnum = 1;
			addChild(buyGoodsNum);	
		}
		
		private function buyGoodsHandler(event:MouseEvent):void {
			var buyCount:int = 1;
			if(buyGoodsNum){
				buyCount = buyGoodsNum.value;
			}
			if(ShopConstant.hasTip()){
				BuyGoodsDialog.getInstance().openDialog(shopItemVo,buyCount,yesHandler);
			}else{
				yesHandler();
			}
			function yesHandler():void{
				ShopModule.getInstance().toBuyGoods(shopItemVo.id,buyCount,shopItemVo.shopId);
			}
		}
		
		private function onRollOverHandler(evt:MouseEvent):void{
			if(point == null){
				point = new Point(goodsBg.x+goodsBg.width,goodsBg.y);
			}
			var p:Point = localToGlobal(point);
			ShopTip.getInstance().point(p.x,p.y, this);
			ShopTip.getInstance().show(shopItemVo);
		}
		
		private function onRollOutHandler(evt:MouseEvent):void{
			ShopTip.getInstance().hide();
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void{
			trace(event.text);
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			shopItemVo = data as ShopItem;
			if(shopItemVo){
				buyBtn.visible = true;
				if(buyGoodsNum){
					countText.visible = true;
					buyGoodsNum.visible = true;
					buyGoodsNum.value = 1;
				}
				goodsImage.visible = true;
				titleText.htmlText = HtmlUtil.font(HtmlUtil.bold(shopItemVo.name),shopItemVo.colour);
				if (shopItemVo.discountType ==1 && shopItemVo.price != shopItemVo.priceVip){
					newPrice.htmlText = "VIP" + shopItemVo.vipLevel + "：" + shopItemVo.priceVip;
				}else if(shopItemVo.discountType != 0 && shopItemVo.discountType != 1){
					newPrice.htmlText = "现价：" + shopItemVo.discPrice;
				}else{
					newPrice.htmlText = "";
				}
				if(shopItemVo.price){
					if(newPrice.htmlText != ""){
						oldPrice.htmlText = "原价：" + shopItemVo.price;
						createModify();
					}else{
						oldPrice.htmlText = "现价：" + shopItemVo.price;
					}
					if(shopItemVo.bind){
						oldPriceIcon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"");
					}
				}else{
					hideModify();
					oldPrice.htmlText = "";
				}
				createGoldBitmap();
				goodsImage.source = shopItemVo.maxico;
			}else{
				newPriceIcon.bitmapData = null;
				oldPriceIcon.bitmapData = null;
				buyBtn.visible = false;
				goodsImage.visible = false;
				if(buyGoodsNum){
					buyGoodsNum.visible = false;
					countText.visible = false;
				}
				newPrice.htmlText = "";
				titleText.htmlText = "";
				oldPrice.htmlText = "";
				hideModify();
			}
		}
		
		private function createGoldBitmap():void{
			if(oldPrice.htmlText != ""){
				if(shopItemVo.price_bind == ShopItem.ALL){
					oldPriceIcon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"gold");
				}else if(shopItemVo.price_bind == ShopItem.BIND){
					oldPriceIcon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"bindGold");
				}else if(shopItemVo.price_bind == ShopItem.NO_BIND){
					oldPriceIcon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"gold");
				}
			}else{
				oldPriceIcon.bitmapData = null;
			}
			if(newPrice.htmlText != ""){
				if(shopItemVo.price_bind == ShopItem.ALL){
					newPriceIcon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"gold");
				}else if(shopItemVo.price_bind == ShopItem.BIND){
					newPriceIcon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"bindGold");
				}else if(shopItemVo.price_bind == ShopItem.NO_BIND){
					newPriceIcon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"gold");
				}
			}else{
				newPriceIcon.bitmapData = null;
			}
		}
		
		private function createModify():void{
			if(modify == null){
				modify = new Shape();
				modify.x = oldPrice.x+35;
				modify.y = oldPrice.y;
				addChild(modify);
			}
			modify.graphics.clear();
			modify.graphics.lineStyle(2,modifyColor,1);
			modify.graphics.moveTo(3,6);
			modify.graphics.lineTo(oldPrice.textWidth-31,10);
			modify.visible = true;
		}
		
		private function hideModify():void{
			if(modify){
				modify.visible = false;
			}
		}
	}
}