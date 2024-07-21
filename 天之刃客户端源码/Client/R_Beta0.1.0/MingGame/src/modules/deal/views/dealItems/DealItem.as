package modules.deal.views.dealItems
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	
	import flash.display.DisplayObject;
	
	import modules.deal.DealConstant;
	import modules.deal.DealModule;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.vo.BaseItemVO;

	public class DealItem extends DragItem
	{
		public static const ITEM_SIZE:int = 36;
		private var isSelf:Boolean;
		private var isLock:Boolean;
		public function DealItem(isSelf:Boolean)
		{
			this.isSelf = isSelf;
			super(ITEM_SIZE);
		}
		
		override public function allowAccept(data:Object, name:String):Boolean{
			
			if(!isLock)
			{
				if(isSelf && name == DragConstant.PACKAGE_ITEM && DealConstant.DEAL_ITEM_LEN<24)
				{
					return true;
				}
			}
			return false;
		}
		
		public function lock():void
		{
			isLock = true;
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
		
		override public function disposeContent():void{
			super.disposeContent();
			while(numChildren > 1){
				removeChildAt(1);
			}
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			if(data){
				createContent();
			}
		}
		
		override protected function createContent():void{
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);
			super.createContent();
			
		}
		
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:BaseItemVO = dragData as BaseItemVO;
			if(itemName == DragConstant.PACKAGE_ITEM){
				//  DealModel 里处理 
				DealModule.getInstance().dragDrop(tempData);
			}
		}
		
	}
}