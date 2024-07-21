package modules.warehouse.views
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	
	import flash.display.DisplayObject;
	
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.vo.BaseItemVO;
	import modules.warehouse.WarehouseModule;
	
	public class WarehouseItem extends DragItem
	{
		public static const ITEM_SIZE:int = 36;
		
		public var index:int;
		
		public function WarehouseItem()
		{
			super(ITEM_SIZE);
		}
		
		
		override public function allowAccept(itemVO:Object,name:String):Boolean{
			
			
			if(name == DragConstant.PACKAGE_ITEM || name == DragConstant.WAREHOUSE_ITEM ||name == DragConstant.WARE_ITEM_SPLIT )
			{
				return true;
			}
//			if( name == DragConstant.WARE_ITEM_SPLIT)
//			{
//				if(data)
//					return false;
//				else
//					return true;
//			}
		
			return false;
			
		}
		
		override protected function createContent():void{
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);
			super.createContent();
			
		}
		
		public function updateCount(num:int):void{
			if(content){
				content.updateCount(num);
			}	
		}
		
		override public function disposeContent():void{
			super.disposeContent();
			while(numChildren > 1){
				removeChildAt(1);
			}
		}
		
		
		public function updateContent(itemVO:BaseItemVO):void{
			if(itemVO == null){
				disposeContent();
				return;
			}
			if(content == null){
				data = itemVO;
			}else{
				setData(itemVO);
				content.updateContent(itemVO);
			}
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			if(data){
				createContent();
			}
		}
		
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:BaseItemVO = dragData as BaseItemVO;
			if(itemName == DragConstant.PACKAGE_ITEM)
			{
				WarehouseModule.getInstance().depotSwap(tempData.oid,index+1);//depotDrag(tempData.oid, index+1);//tempData.position
			}
			else if(itemName == DragConstant.WAREHOUSE_ITEM)
			{
				if(tempData.position == index+1)
				{
					return;
				}
				WarehouseModule.getInstance().depotSwap(tempData.oid,index+1);
			}
//			else if(itemName == DragConstant.SPLIT_ITEM)
//			{
//				WarehouseModel.getInstance().depotDivide(tempData.oid,index+1,tempData.num);
//				
//				
//			}
			else if(itemName == DragConstant.WARE_ITEM_SPLIT)
			{
				if(data )//&& tempData.oid == data.oid)
				{
					var currentData:BaseItemVO = data as BaseItemVO;
					if(tempData.oid == currentData.oid)
					{
						content.updateCount(currentData.num);
						return;
					}
				}
				WarehouseModule.getInstance().depotDivide(tempData.oid,index+1,tempData.num);
			}
			
		}
		
		
	}
}