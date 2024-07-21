package com.common.cursor.cursors {
	import com.common.cursor.BaseCursor;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.globals.GameConfig;
	
	import flash.events.MouseEvent;
	
	import modules.mypackage.views.PackageItem;
	import modules.mypackage.vo.BaseItemVO;
	import modules.shop.ShopModule;

	public class TradeCursor extends BaseCursor {
		public function TradeCursor() {
			super();
			setMouse("Mouse_trade");
		}

		override public function normalHandler():void {
			
		}
		
		override public function downHandler(event:MouseEvent):void{
			var clickTarget:PackageItem = event.target as PackageItem;
			if(clickTarget == null || clickTarget.data == null){
				CursorManager.getInstance().enabledCursor = true;
				CursorManager.getInstance().hideCursor(CursorName.SELL);
			}else if(clickTarget.data){
				var itemVO:BaseItemVO = clickTarget.data as BaseItemVO;
				ShopModule.getInstance().toSaleGoods(itemVO.oid,itemVO.typeId, itemVO.position,itemVO.num, itemVO.name);
			}
		}
	}
}