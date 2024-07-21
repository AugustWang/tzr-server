package modules.mypackage.views
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.BaseItemVO;
	
	public class SellTile extends Sprite
	{
		public var rowCount:int = 6;
		public var columnCount:int = 7;
		public static const HPADDING:int = 1;
		public static const VPADDING:int = 1;
		public var owner:Sprite;
		private static var thing:Thing;
		
		public function SellTile()
		{
			super();
			createItems();
		}
		
		public function removeAll():void
		{
			var size:int = numChildren;
			for(var i:int = 0;i<size;i++)
			{
				var item:SellItem = getChildAt(i) as SellItem;
				item.unlock();
				item.disposeContent();
			}
		}
		
		public function getEmplyItem():SellItem
		{
			var size:int = rowCount*columnCount;
			for (var i:int=0; i<size; i++) {
				var item:SellItem =  packItems[i] as SellItem;
				if (!item.islock()) {
					return item;
				}
			}
			return null;
		}
		
		private var packItems:Array;
		private function createItems():void{
			packItems = [];
			var size:int = rowCount*columnCount;
			for(var i:int=0;i<size;i++){
				var item:SellItem = new SellItem();
				item.index = i;
				item.addEventListener(MouseEvent.MOUSE_DOWN,itemDownHandler);
				item.doubleClickEnabled = true;
				item.addEventListener(MouseEvent.DOUBLE_CLICK,onItemDoubleClick);				
				var row:int = i / columnCount;
				var column:int = i % columnCount;
				item.x = 4+column*item.width + column*HPADDING;
				item.y = 5+row*item.height + row*VPADDING;
				addChild(item);
				packItems.push(item);
			}			
		}
		
		private function onItemDoubleClick(event:MouseEvent):void{
			var sellItem:SellItem = event.currentTarget as SellItem;
			if (sellItem == null) {
				return;
			}
			var baseItemVO:BaseItemVO = sellItem.data as BaseItemVO;
			if(sellItem == null || baseItemVO == null) return;
			sellItem.disposeContent();
			sellItem.unlock();
			PackageModule.getInstance().onDragOutSell(baseItemVO);
		}
		
		private function itemDownHandler(event:Event):void
		{
			var item:SellItem = event.currentTarget as SellItem;
			if (item && item.getContent()) {
				DragItemManager.instance.startDragItem(this, item.getContent(), DragConstant.SELL_ITEM, item.data);
			}
		}
	}
}