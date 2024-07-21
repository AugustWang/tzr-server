package modules.shop.views
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	
	import modules.rank.view.ShooterRankView;
	import modules.shop.ShopItem;
	
	public class ShopItemImg extends UIComponent
	{
		private var imgItem:Image;
		
		private var _data:ShopItem;
		private var _Enter:int = 0;
		public function ShopItemImg(Enterflag:int=0){
			_Enter = Enterflag;
			var itemBg:DisplayObject = null;
			if(_Enter==0)
			{
				height=36;
				width=36;
				itemBg = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			}
			else
			{
				height=60;
				width=60;
				itemBg = Style.getSpriteBitmap(GameConfig.SHOP_UI, "shopItemBg");
			}
			addChild(itemBg);
		}
		
		private function openTip(evnet:MouseEvent):void{
			ShopTip.getInstance().point(this.stage.mouseX, this.stage.mouseY, this);
			ShopTip.getInstance().show(this._data);
		}
		
		private function closeTip(evnet:MouseEvent):void{
			ShopTip.getInstance().hide();
		}
		
		private function createContent():void{
			if(imgItem!=null){
				imgItem.removeEventListener(Event.COMPLETE,onLoadComplete);
				imgItem.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				if(imgItem.parent == this){
					removeChild(imgItem);
				}
				imgItem = null;
			}
			imgItem = new Image();
			if(_Enter==0)
			{	imgItem.source = _data.url;
				imgItem.x = imgItem.y = 4;//11.8;
			}
			else
			{
				imgItem.source = _data.maxico;
				imgItem.x = imgItem.y = 3;//11.8;
			}
			this.addEventListener(MouseEvent.ROLL_OVER, openTip);
			this.addEventListener(MouseEvent.ROLL_OUT, closeTip);
			imgItem.addEventListener(Event.COMPLETE,onLoadComplete);
			imgItem.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			addChild(imgItem);
		}
		
		private function onLoadComplete(event:Event):void{
			if(imgItem){
				if(_Enter==0)
					imgItem.x = imgItem.y = 4;//11.8;
				else
					imgItem.x = imgItem.y = 3;
				imgItem.removeEventListener(Event.COMPLETE,onLoadComplete);
				imgItem.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				addChild(imgItem);
			}
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void{
			if(imgItem){
				imgItem.removeEventListener(Event.COMPLETE,onLoadComplete);
				imgItem.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			}
		}
		
		public function toolTipOff():void{
			this.removeEventListener(MouseEvent.ROLL_OVER, openTip);
			this.removeEventListener(MouseEvent.ROLL_OUT, closeTip);
		}
		
		public function rmImg():void{
			if(imgItem && imgItem.parent == this){
				this.removeChild(this.imgItem);
				this.toolTipOff();
				this._data=null;
			}
		}
		
		override public function get data():Object{
			return this._data;
		}
		
		override public function set data(v:Object):void{
			if(v != null){
				_data = v as ShopItem;
				if(_data.url != ""){
					createContent();
				}
			}
		}
		
		
	}
}