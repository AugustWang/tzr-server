package modules.pet.newView.items{


	import com.common.FilterCommon;
	import com.components.GoodsBox;
	import com.ming.core.IDataRenderer;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.vo.BaseItemVO;
	import modules.shop.ShopConstant;
	import modules.shop.ShopItem;
	import modules.shop.ShopModule;

	public class PetGoodsItem extends Sprite implements IDataRenderer{
		
		private var goodsBox:GoodsBox;
		private var nameText:TextField;
		private var buyText:TextField;
		private var shopItem:ShopItem;

		public function PetGoodsItem():void {
			buttonMode=true;
			
			goodsBox = new GoodsBox();
			goodsBox.x = 4;
			goodsBox.y = 4;
			addChild(goodsBox);
			
			var tf:TextFormat=new TextFormat(null, 12, 0xffffff);
			nameText = ComponentUtil.createTextField("",46,8,tf,100,20,this);
			
			buyText = ComponentUtil.createTextField("购买", 120, 8, tf, 60, 22, this);
			buyText.mouseEnabled = true;
			buyText.htmlText = "<a href=\"event:buy\"><font color='#00FF00'><u>购买</u></font></a>";
			buyText.addEventListener(TextEvent.LINK, buyHandler);
		}
		
		
		private function buyHandler(event:TextEvent):void{
			if (_itemVO != null) {
				ShopModule.getInstance().requestShopItem(ShopConstant.TYPE_PET,_itemVO.typeId,new Point(stage.mouseX-178, stage.mouseY-90));
			}
		}
		
		private var _itemVO:BaseItemVO;
		public function set data(value:Object):void {
			_itemVO = value as BaseItemVO;
			if (_itemVO != null) {
				goodsBox.baseItemVO = _itemVO;
				nameText.text = _itemVO.name;
				if (_itemVO.num > 0) {
					goodsBox.filters=null;
					buyText.visible=false;
				} else {
					goodsBox.filters = FilterCommon.GRAY_MATRIX;
					buyText.visible = true;
				}
			}	
		}
		
		public 	function get data():Object{
			return 	_itemVO;
		}
	}
}
