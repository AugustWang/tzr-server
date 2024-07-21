package modules.deal.views.stallViews
{
	
	import com.common.dragManager.IDragItem;
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	
	public class OtherStallItem extends UIComponent implements IDragItem
	{
		
		private var content:GoodsItem;
		
		public function OtherStallItem()
		{
			super();
			this.height = this.width = 36;
			this.mouseChildren = false;
			this.bgSkin = new Skin(GStyle.getViewClass("packItemBg"));
			//addEventListener(DragItemEvent.DRAG_DROP,dragDropHandler);
			addEventListener(MouseEvent.CLICK,clickHandler);
		}
		
		private function clickHandler(evt:MouseEvent):void
		{
			if(!DragManager.isDragging)
			{
				if(content)
					dispatchEvent(new ItemEvent(ItemEvent.ITEM_CLICK));
			}
		}
		
		
		override public function set data(value:Object):void
		{
			super.data = value;
			if(data){
				createContent();
			}
		}
		
		protected function createContent():void
		{
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);
			addEventListener(MouseEvent.ROLL_OVER,onRollOver);
		}
		protected function onRollOver(event:MouseEvent):void
		{
			addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			var p:Point = new Point(x+width,y);
			p = parent.localToGlobal(p);
			ItemToolTip.show(data as BaseItemVO,p.x,p.y);
		}
		
		protected function onRollOut(event:MouseEvent):void{
			removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
			ItemToolTip.hide();
		}
		
		public function updateCount(num:int):void{
			if(content){
				content.updateCount(num);
			}	
		}
		
		
	
		
		
		public function setContent(content:*, _data:*):void
		{
//			content = _content;
//			super.data = _data;
//			addChild(_content);
//			addEventListener(MouseEvent.ROLL_OVER,onRollOver);
		}
		
		public function getContent():*
		{
			return content;
		}
		
		public function disposeContent():void
		{
			if(content && contains(content)){
				removeChild(content);
			}
			content = null;
			super.data = null;
			removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
		}
		
		public function allowAccept(data:Object, name:String):Boolean
		{
			return false;
		}
	}
}