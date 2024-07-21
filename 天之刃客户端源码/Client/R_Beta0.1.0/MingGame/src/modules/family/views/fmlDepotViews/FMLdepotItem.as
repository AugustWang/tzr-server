package modules.family.views.fmlDepotViews
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	
	import flash.display.DisplayObject;
	
	import modules.family.FamilyDepotModule;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.vo.BaseItemVO;
	
	public class FMLdepotItem extends DragItem
	{
		public var index:int;
		public function FMLdepotItem()
		{
			super(36);
//			addEventListener(MouseEvent.CLICK, onClickHandler);
		}
		
		
		
		
		override public function allowAccept(itemVO:Object,name:String):Boolean{
			
			var item:BaseItemVO = itemVO as BaseItemVO 
			if(name == DragConstant.PACKAGE_ITEM && item && !item.bind )
			{
				return true;
			}
			
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
				FamilyDepotModule.getInstance().putIn(tempData.oid);
				//WarehouseModel.getInstance().depotSwap(tempData.oid,index+1);
			}
		}
		
		
	}
}
