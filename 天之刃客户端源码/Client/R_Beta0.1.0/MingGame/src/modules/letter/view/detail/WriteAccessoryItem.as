package modules.letter.view.detail
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import modules.letter.LetterModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;

	public class WriteAccessoryItem extends AccessoryItem{
		
		private var _data:BaseItemVO;
		private var currentChild:DisplayObject;
		public function WriteAccessoryItem()
		{
			super();
		}
		
		override public function setContent(content:*, _data:*):void{
			addData(_data, null, false);
		}
		
		override public function disposeContent():void{
			reset();
		}
		
		override public function dragDrop(dragData:Object,dragTarget:DisplayObject,itemName:String):void{
			var vo:BaseItemVO = dragData as BaseItemVO;
			
			if(this._data != null)
				returnCurrentData();
			
			addData(dragData, itemName);
			LetterModule.getInstance().panel.letterWrite.money_txt.text = "发送附件费用：10 两银子";
		}
		
		override protected function drag(evt:MouseEvent):void
		{
			if(currentChild == null)
				return;
			DragItemManager.instance.startDragItem(this, currentChild,DragConstant.WRITE_ITEM_BACK, _data);
		}
		
		override public function allowAccept(data:Object, name:String):Boolean
		{
			if(name == DragConstant.WRITE_ITEM_BACK)
				return true;
			
			return super.allowAccept(data, name);
		}
		
		public function returnCurrentData():void
		{
			if(this._data != null)
				PackManager.getInstance().lockGoods(this._data, false);
			
			this._data = null;
			if(currentChild != null && contains(currentChild))
				removeChild(currentChild);
			
			currentChild = null;
		}
		
		private function addData(dragData:Object,itemName:String, lock:Boolean = true):void{
			currentChild = new GoodsItem(dragData as BaseItemVO);
			this.addChild(currentChild);
			
			this._data = dragData as BaseItemVO;
			addTooltip();
			if(lock)
				PackManager.getInstance().lockGoods(this._data, true);
			
			currentChild.x = 2;
			currentChild.y = 2;
		}
		
		private function addTooltip():void{
			if(!this.hasEventListener(MouseEvent.MOUSE_OVER)){
				this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			}
		}
		
		private function removeTooltip():void{
			if(this.hasEventListener(MouseEvent.MOUSE_OVER)){
				this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			}
		}
		
		private function mouseOver(evt:MouseEvent):void{
			var p:Point = new Point(x+36 , y);
			p = parent.localToGlobal(p);
			ItemToolTip.show(_data , p.x , p.y , false);
			
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		private function mouseOut(evt:MouseEvent):void{
			ItemToolTip.hide();
			this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		public function reset():void{
			_data = null;
			if(currentChild != null && currentChild.parent == this)
				removeChild(currentChild);
			
			removeTooltip();
			currentChild = null;
		}
		
		public function get param():BaseItemVO
		{
			return this._data;
		}
	}
}