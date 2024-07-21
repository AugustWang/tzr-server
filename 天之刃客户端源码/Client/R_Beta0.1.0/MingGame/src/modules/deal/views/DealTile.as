package modules.deal.views
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import com.ming.ui.controls.TextInput;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.deal.DealConstant;
	import modules.deal.views.dealItems.DealItem;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	
	public class DealTile extends Sprite{
		public static const COUNT:int = 21;//24;
		public static const COLUMN_COUNT:int =7;// 8;
		public static const HPADDING:int = 3;
		public static const VPADDING:int = 1;	
		
		private var input_yb:TextInput;
		private var input_yl:TextInput;
		private var input_tq:TextInput;
		
		private var isSelf:Boolean;
		
		public function DealTile(isSelf:Boolean=true):void{
			this.isSelf = isSelf
			
			_itemArr = [];
			items = [];
			
			createItems(isSelf);
			
			if(isSelf){
				
//				addEventListener(DragItemEvent.NOT_FIND_TARGET,notFindTargetHandler);
//				addEventListener(DragItemEvent.DRAG_ENTER,onDragEnter);
//				addEventListener(DragItemEvent.DRAG_THREW,stopDragHandler);
			}
		}
		
		private var items:Array;
		private var _itemArr:Array;
		private var goodsItems:Array;
		private var _baseItemArr:Array;
		
		
		public function onDragEnter(itemVO:BaseItemVO):void{ 
			
			if(itemVO){
				if( itemVO.position != -1){
					if(itemArr.length<24)
					{
						itemArr.push(itemVO);
						setContent(itemArr.length-1,itemVO);
						
						DealConstant.DEAL_ITEM_LEN = itemArr.length;
						
						items.push(itemVO.oid);
						PackManager.getInstance().lockGoods(itemVO,true);
						DragItemManager.instance.stop();
					}
				}
			}
		}
		
		
		public function deleteOneRecord(index:int):void
		{
			var size:int = itemArr.length-1;
			var i:int = index;
			while(i<size){
				var preItemVo:BaseItemVO = itemArr[i];
				var nextItemVo:BaseItemVO = itemArr[i+1];
				setContent(i,nextItemVo);
				i++ ;
			}
			
			setContent(i,null);
			
			itemArr.splice(index,1);
			items.splice(index,1);
			DealConstant.DEAL_ITEM_LEN = itemArr.length;
			
		}
		
		
		public function getIndexByVo(vo:BaseItemVO):int
		{
			if(!vo)
				return -1;
			
			for(var i:int = 0;i<this.numChildren;i++)
			{
				var tmpItem:DealItem = getChildAt(i) as DealItem;
				if(tmpItem)
				{
					var tmpVo:BaseItemVO = tmpItem.data as BaseItemVO;
					if(tmpVo == vo)
					{
						return i;
					}
				}
			}
			return -1;
		}
		
		
		private function createItems(isSelf:Boolean):void{
			
			for(var i:int=0;i<COUNT;i++){
				
				var item:DealItem = new DealItem(isSelf);	
				if(isSelf){
					item.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownHandler);
				}
				var row:int = i / COLUMN_COUNT;
				var column:int = i % COLUMN_COUNT;
				item.x = column*item.width + column*HPADDING;
				item.y = row*item.height + row*VPADDING;
				addChild(item);
			}
		}	
		
		private function setContent(pos:int,vo:BaseItemVO):void{
			var dealItem:DealItem = getChildAt(pos) as DealItem;
//			dealItem.data = vo;
			dealItem.updateContent(vo);
		}
		
		private function onMouseDownHandler(evt:MouseEvent):void
		{
			var item:DealItem = evt.currentTarget as DealItem;
			if(item.data && !DragItemManager.isDragging()){
				DragItemManager.instance.startDragItem(this,item.getContent(),DragConstant.DEAL_ITEM,item.data);
			}
		}
		
		public function onlock():void
		{
			if(isSelf)
			{
				for(var i:int=0;i<COUNT;i++)
				{
					var item:DealItem = getChildAt(i) as DealItem;
					item.lock();
					item.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDownHandler);
				}
			}
		}
		
		public function get goodsArr():Array
		{
			if(items)
			{
				return items;
			}
			return null;
		}
		
		public function get itemArr():Array
		{
			if(_itemArr)
			{
				return _itemArr;
			}
			return null
		}
		
//		public function get baseItemArr():Array
//		{
//			if(_baseItemArr)
//			{
//				return _baseItemArr
//			}
//			return null;
//		}

		
		public function setGoods(items:Array):void{			
			var size:int = items.length;
			for(var i:int = 0;i<size;i++){
				updateGoods(i,items[i]);
			}		
		}
		
		public function updateGoods(pos:int,itemvo:BaseItemVO):void{
			var item:DealItem = getChildAt(pos) as DealItem;
			item.updateContent(itemvo);
		}
		
		public function disposeItems():void
		{
			var size:int = numChildren
			for(var i:int = 0;i<size;i++)
			{
				var item:DealItem = getChildAt(i) as DealItem
				item.disposeContent();
			}
		}
	}
}
