package modules.warehouse.views
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemEvent;
	import com.common.dragManager.DragItemManager;
	import com.components.alert.Alert;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.SplitItemPanel;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.warehouse.WarehouseModule;
	
	public class WareTile extends Sprite
	{
		public var rowCount:int = 6;
		public var columnCount:int = 7;
		public static const HPADDING:int = 0;
		public static const VPADDING:int = 0;
//		private var wareId:int;
		public function WareTile()
		{
			super();
			createItems();
			addEventListener(DragItemEvent.DRAG_THREW,onDragThrew);
		}
		
		private function onDragThrew(event:DragItemEvent):void{			
			var itemVo:BaseItemVO = event.dragData as BaseItemVO;
			var color:String = ItemConstant.COLOR_VALUES[itemVo.color];
			Alert.show("你是否确定要丢弃"+HtmlUtil.font("【"+itemVo.name+"】",color)+"?","警告",desctoryGoods,updateItem);
			function desctoryGoods():void{
				WarehouseModule.getInstance().depotDestroy(itemVo.oid);
			}
			function updateItem():void{
				updateGoods(itemVo.position,itemVo);
			}
		}
		
		private var wareItems:Array;
		private function createItems():void{
//			wareItems = [];
			var size:int = rowCount*columnCount;
			for(var i:int=0;i<size;i++){
				var item:WarehouseItem = new WarehouseItem();
				item.index = i;
//				item.packId = packId;
				item.addEventListener(MouseEvent.MOUSE_DOWN,itemDownHandler);
				item.doubleClickEnabled = true;
				item.addEventListener(MouseEvent.DOUBLE_CLICK,onItemDoubleClick);				
				var row:int = i / columnCount;
				var column:int = i % columnCount;
				item.x = column*item.width + column*HPADDING;
				item.y = row*item.height + row*VPADDING;
				addChild(item);
//				wareItems.push(item);
			}			
		}
		
		private function itemDownHandler(event:MouseEvent):void{
			var item:WarehouseItem = event.currentTarget as WarehouseItem;
			var baseItemVO:BaseItemVO = item.data as BaseItemVO;
			if(baseItemVO == null || DragItemManager.isDragging())return;
			
			if(event.shiftKey){
				var hashId:int = WarehouseModule.getInstance().hashId;
				var arr:Array = WarehouseModule.getInstance().hash[hashId];
				if(arr.length == 42)
				{
					BroadcastSelf.logger("仓库已满，不能进行拆分！");
				}
				else{
					splitItemPanel(item);
				}
			}else{	
				DragItemManager.instance.startDragItem(this,item.getContent(),DragConstant.WAREHOUSE_ITEM,item.data);
			}
		}
		
		private var splitUi:SplitItemPanel;
		private function splitItemPanel(item:WarehouseItem):void{
			var generalVO:GeneralVO = item.data as GeneralVO;
			if(generalVO && generalVO.num > 1 )//&& generalVO.usenum != ItemConstant.LOCK
			{
				splitUi = new SplitItemPanel();
				splitUi.x = WarehouseModule.getInstance().warehouse.x + 100;
				splitUi.y =WarehouseModule.getInstance().warehouse.y + 200;
				splitUi.warehouseItem = item;
//				WindowManager.getInstance().openDialog(splitUi);
				WindowManager.getInstance().openDialog(splitUi);
			}else{
				BroadcastSelf.logger("该物品不能拆分!");
			}
		}
		
//		private function itemDownHandler(evt:MouseEvent):void
//		{
//			var item:WarehouseItem = evt.currentTarget as WarehouseItem;
//			if(item.data && !DragItemManager.isDragging()){
//				DragItemManager.instance.startAdhereItem(this,item.getContent(),DragConstant.WAREHOUSE_ITEM,item.data);
//			}
//		}
		
		
		private function onItemDoubleClick(e:MouseEvent):void
		{
			//取出到背包。。。
			var item:WarehouseItem = e.currentTarget as WarehouseItem;
			var bsItemVo:BaseItemVO = item.data as BaseItemVO ;
			if(bsItemVo)
				WarehouseModule.getInstance().takeOut(bsItemVo.oid,0)
		}
		
//		public function setGoods(items:Array):void{			
//			var size:int = items.length;
//			for(var i:int = 0;i<size;i++){
//				updateGoods(i+1,items[i]);
//			}		
//		}
		
		public function updateGoods(pos:int,itemvo:BaseItemVO):void{
			if(pos<1)
				return;
			var item:WarehouseItem = getChildAt(pos-1) as WarehouseItem;
			item.updateContent(itemvo);
			
		}
		
		public function disposeItems():void
		{
			var size:int = numChildren;
			for(var i:int = 0;i<size;i++)
			{
				var item:WarehouseItem = getChildAt(i) as WarehouseItem;
				item.disposeContent();
			}
		}
		
	}
}