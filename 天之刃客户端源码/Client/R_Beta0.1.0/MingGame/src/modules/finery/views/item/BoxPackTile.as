package modules.finery.views.item
{
	import com.common.dragManager.DragItemEvent;
	import com.components.cooling.CoolingManager;
	import com.events.ParamEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.finery.StoveConstant;
	import modules.mypackage.views.PackTile;
	import modules.mypackage.views.PackageItem;
	import modules.mypackage.vo.BaseItemVO;

	public class BoxPackTile extends Sprite
	{
		public var rowCount:int=6;
		public var columnCount:int=7;
		public static const HPADDING:int=3;
		public static const VPADDING:int=3;
		protected var packId:int;
		public var owner:Sprite;
		
		private var packItems:Array;
		public function BoxPackTile(packId:int, rowCount:int=6, columnCount:int=7)
		{
			this.packId = packId;
			this.rowCount = rowCount;
			this.columnCount = columnCount;
			createItems();
		}
		
		protected function onItemDoubleClick(event:MouseEvent):void{
			var item:BoxPackageItem=event.currentTarget as BoxPackageItem;
			var baseItemVO:BaseItemVO=item.data as BaseItemVO;
			if(baseItemVO){
				var e:ParamEvent = new ParamEvent(StoveConstant.BOX_ITEM_DOULE_CLICK,null,true);
				e.data={ids:[baseItemVO.oid]};
				dispatchEvent(e);
			}
		}
		
		protected function createItems():void {
			packItems=[];
			var size:int=rowCount * columnCount;
			for (var i:int=0; i < size; i++) {
				var item:BoxPackageItem=new BoxPackageItem();
				item.index=i;
				item.packId=packId;
				item.doubleClickEnabled=true;
				item.addEventListener(MouseEvent.DOUBLE_CLICK, onItemDoubleClick);
				var row:int=i / columnCount;
				var column:int=i % columnCount;
				item.x=4 + column * item.width + column * HPADDING;
				item.y=5 + row * item.height + row * VPADDING;
				addChild(item);
				packItems.push(item);
			}
		}
		
		public function updateGoods(pos:int, itemvo:BaseItemVO):void {
			var item:PackageItem=packItems[pos] as PackageItem;
			var tempData:Object=item.data;
			item.updateContent(itemvo);
			if (itemvo == null && item.lock) {
				item.lock=false;
			}
		}
		
		public function setLock(pos:int, lock:Boolean):void {
			var item:PackageItem=packItems[pos] as PackageItem;
			item.lock=lock;
		}
		
		public function getTileItem(pos:int):PackageItem {
			return packItems[pos];
		}
		
		public function getTileItems():Array{
			return packItems;
		}
		
		public function setGoods(items:Array):void {
			var size:int=packItems.length;
			for (var i:int=0; i < size; i++) {
				updateGoods(i, items[i]);
			}
		}
		
		public function dispose():void{
			
		}
	}
}