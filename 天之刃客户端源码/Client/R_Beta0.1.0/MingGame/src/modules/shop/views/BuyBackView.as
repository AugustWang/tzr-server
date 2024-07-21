package modules.shop.views {
	import com.managers.Dispatch;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.mypackage.vo.BaseItemVO;
	import modules.shop.ShopDataManager;
	import modules.shop.ShopModule;
	import modules.shop.views.items.BuyBackItem;

	public class BuyBackView extends Sprite {
		private static const VPADDING:int=3;

		private var buyBackItems:Array;

		public function BuyBackView() {
			super();
			var tf:TextFormat = new TextFormat("Tahoma",13,0xfffd4b,true);
			ComponentUtil.createTextField("回购", 7, 7, tf, 30, 20, this);
			buyBackItems=new Array(ShopDataManager.BUYBACK_COUNT);
			createItems();
			Dispatch.register(ModuleCommand.BUYBACK_CHANGED, updateBuyBackItems);
			updateBuyBackItems();
		}

		private function createItems():void {
			var buyBackItem:BuyBackItem;
			var startX:int=43;
			for (var i:int=0; i < ShopDataManager.BUYBACK_COUNT; i++) {
				buyBackItem=new BuyBackItem();
				buyBackItem.addEventListener(MouseEvent.CLICK, clickHandler);
				buyBackItem.x=startX;
				addChild(buyBackItem);
				buyBackItems[i]=buyBackItem;
				startX+=buyBackItem.width + VPADDING;
			}
		}

		/**
		 * 更新可购回项
		 *
		 */
		private function updateBuyBackItems():void {
			var goods:Array=ShopDataManager.getInstance().buyBacks;
			var buyBackItem:BuyBackItem;
			for (var i:int=0; i < ShopDataManager.BUYBACK_COUNT; i++) {
				buyBackItem=buyBackItems[i];
				if (goods) {
					buyBackItem.updateContent(goods[i]);
				} else {
					buyBackItem.updateContent(null);
				}
			}
		}

		/**
		 * 回购物品
		 * @param event
		 *
		 */
		private function clickHandler(event:MouseEvent):void {
			var buyBackItem:BuyBackItem=event.currentTarget as BuyBackItem;
			if (buyBackItem.data) {
				ShopModule.getInstance().buyBackGoods(buyBackItem.data.oid);
			}
		}
	}
}