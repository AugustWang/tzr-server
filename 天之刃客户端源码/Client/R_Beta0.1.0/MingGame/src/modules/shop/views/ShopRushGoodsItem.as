package modules.shop.views
{
	import com.common.FilterCommon;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	import modules.shop.ShopItem;
	
	public class ShopRushGoodsItem extends ShopGoodsItem
	{
		private var numText:TextField;	
		public function ShopRushGoodsItem()
		{
			super();
			buyBtn.label = "抢购";
			
			numText = ComponentUtil.createTextField("", 75, 64, null, 128, 20, this);
			numText.filters = FilterCommon.FONT_BLACK_FILTERS;
		}
		
		override protected function createNumericStepper():void{
			
		}
		
		private var _shopItem:ShopItem;
		public function set shopItem(vo:ShopItem):void{
			if(_shopItem){
				_shopItem.removeEventListener(ShopItem.NUM_CHANGED,numChangedHandler);
			}
			_shopItem = vo;
			if(_shopItem){
				numChangedHandler(null);
				_shopItem.addEventListener(ShopItem.NUM_CHANGED,numChangedHandler);
				data = _shopItem;
			}
		}
		
		public function get shopItem():ShopItem{
			return _shopItem;
		}
		
		private function numChangedHandler(event:Event):void{
			if(_shopItem){
				numText.htmlText="<font color='#00ff00'>剩"+_shopItem.num+"个</font>";
			}
		}
	}
}