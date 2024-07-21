package modules.broadcast.views
{
	import com.components.chat.TextImageItem;
	import com.ming.events.ScrollEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.containers.VScrollCanvas;
	
	import flash.display.DisplayObject;
	import flash.events.TextEvent;
	
	import modules.chat.ChatModule;
	
	public class LabaList extends VScrollCanvas
	{
		private var messages:Array;
		private var items:Array;
		public var scrollEnable:Boolean = false;
		private var freeItems:Array;
		private static const LabaRecordNum:int = 20;
//		public var itemHandler:Function;
		
		public function LabaList()
		{
			super();
			direction = ScrollDirection.RIGHT;
//			this.bgAlpha = 0.4;
//			this.bgColor = 0x000000;//0xacacac;//
//			this.width = 280;
//			this.height = 266;
//			messages = [];
			items = [];
			freeItems = [];
		}
		
		public function pushMessage(vo:Object, role:Object=null):void{
//			messages.push(vo);
			createMessageItem(vo, role);
		}
		
		private function createMessageItem(vo:Object, role:Object):void{
			var item:TextImageItem;
			
			item = new TextImageItem();
			item.width = width - 25;
			item.mouseEnabled = mouseEnabled;
			items.push(item);
			
			if(items.length>LabaRecordNum){
				var tempItem:TextImageItem = items.shift();
				removeChild(tempItem);
				tempItem = null;
			}
				
				
			item.setHtmlText(vo.toString());
			item.data = role;
			item.handler = itemClickHandler;
			
			addChild(item);
			///需要优化一下
			updateLayout();
		}
		private function itemClickHandler(evt:TextEvent, data:Object):void
		{
			ChatModule.getInstance().chat.itemClickHandler(evt,data)
			
		}
		
		private function updateLayout():void{
			var children:Array = getAllChildren();
			var ypos:Number = 0;
			for each(var child:DisplayObject in children){
				child.y = ypos;
				ypos += child.height;
			}
		}
		
		/**
		 * 用来优化，目的是尽量减少不可见可视对象的重绘。 
		 * @param event
		 * 
		 */		
		override protected function verticalScroll(event:ScrollEvent):void
		{
			super.verticalScroll(event);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			if(!scrollEnable){
				vscrollBar.scrollPosition = vscrollBar.maxScrollPosition;
			}			
		}
		
	}
}



