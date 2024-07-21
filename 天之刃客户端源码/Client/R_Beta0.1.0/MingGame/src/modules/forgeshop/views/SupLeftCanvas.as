package modules.forgeshop.views
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import com.ming.managers.DragManager;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.forgeshop.views.items.EquipItem;
	import modules.mypackage.vo.BaseItemVO;

	/**
	 * 
	 *左边的背景
	 * 
	 */	
	public class SupLeftCanvas extends Sprite{   
		public var equipItem:EquipItem;
		public function SupLeftCanvas(){
			this.y = 50;
			this.addChild(Style.getViewBg("tglBg"));
			init();
		}
		
		/**
		 * 创建UI
		 * @param currentIndex
		 * 
		 */		
		public function init():void{
			equipItem = new EquipItem();
			equipItem.x = 99;
			equipItem.y = 85;
			equipItem.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownHandler);
			this.addChild(equipItem);
		}
		private function onMouseDownHandler(evt:MouseEvent):void{
			var tempEquipItem:EquipItem = evt.currentTarget as EquipItem;
			if(tempEquipItem.data && !DragManager.isDragging){
				DragItemManager.instance.startDragItem(this,tempEquipItem.getContent(),DragConstant.FORGESHOP_ITEM,tempEquipItem.data);
			}
		}
		
		public function updateGoods(itemVo:BaseItemVO):void{
			equipItem.updateContent(itemVo);
		}
	}
}