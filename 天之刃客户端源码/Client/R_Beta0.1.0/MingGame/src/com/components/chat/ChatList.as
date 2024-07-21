package com.components.chat
{
	import com.ming.events.ScrollEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.VScrollCanvas;
	import com.scene.GameScene;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import org.osmf.events.TimeEvent;

	public class ChatList extends VScrollCanvas
	{
		private var messages:Array;
		private var items:Array;
		public var scrollEnable:Boolean = true;
		public var chatScroll:Boolean = false;
		private var freeItems:Array;
		
		public var itemHandler:Function;
		private var time:Number
		
		public static var CLICK_CHAT_LIST:Boolean = false;
		public function ChatList()
		{
			super();
			direction = ScrollDirection.LEFT;
//			this.bgAlpha = 0.6;// 0.4;
//			this.bgColor = 0x000000;
			messages = [];
			items = [];
			freeItems = [];
			scrollBarSkin = Style.alphaScrollBarSkin; 
			mouseEnabled = false;
			addEventListener(MouseEvent.MOUSE_DOWN,downHandler);
			addEventListener(MouseEvent.MOUSE_UP,upHandler);
		}
		
		private function downHandler(event:MouseEvent):void{
			if(event.target is TextField){
				CLICK_CHAT_LIST = true;	
			}else{
				CLICK_CHAT_LIST = false;
			}
		}
		
		private function upHandler(event:MouseEvent):void{
			if(CLICK_CHAT_LIST){
				GameScene.getInstance().onClickMap();
				GameScene.getInstance().clearRoadCounter();
			}
		}
		
		public function pushMessage(vo:Object, role:Object):void{
			messages.push(vo);
			createMessageItem(vo, role);
		}
		
		private function createMessageItem(vo:Object, role:Object):void{
			var item:TextImageItem;
	 
			if(items.length>40){
				item = items.shift();
			}else{
				item = new TextImageItem();
				item.width = width - 15;
			}
			item.setHtmlText(vo.toString());
			item.data = role;
			item.handler = itemHandler;
			items.push(item);
			addChild(item);
			playFit();
			///需要优化一下
			updateLayout();
		}
		
		public function shuapin():void
		{
			while(items.length>0)
			{
				var item:TextImageItem = items.shift();
				if(this.contains(item))
					removeChild(item);
				item = null;
			}
		}
	    
		public function stopPlay():void
		{
			
			var len:int=this.numChildren-1;
			while(len)
			{
				var item:TextImageItem=this.getChildAt(len) as TextImageItem;
				if(item)
				{
					var num:int=item.numChildren-1;
					while(num)
					{
						var mc:Face=item.getChildAt(num) as Face;
						if(mc){
							mc.stop();
						}
						num--;
					}
				}
				len--;
			}
			
		}
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			this.stopPlay();
			var value:DisplayObject=  super.removeChild(child);
			
			return value;
		}
		override public function removeChildAt(index:int):DisplayObject
		{
			this.stopPlay();
			var value:DisplayObject= super.removeChildAt(index);
			
			return value;
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			
			var value:DisplayObject= super.addChild(child);
			playFit();
			return value;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			var value:DisplayObject=super.addChildAt(child,index)
			playFit();
			return value;
		}
		public function playFit():void
		{
			var rect:Rectangle=this.rawChildren.mask.getBounds(this);
			rect.y-=15;
			var len:int=this.numChildren-1;
			if(len<1)
				return;
			while(len)
			{
				var item:TextImageItem=this.getChildAt(len)  as TextImageItem;
				if(item)
				{
					var num:int=item.numChildren-1;
					while(num)
					{
						var mc:Face=item.getChildAt(num) as Face;
						if(mc){
							mc.stop()
							
							var rectMc:Rectangle=mc.getBounds(this)
								if(rectMc.intersects(rect))
								{
									mc.play()
								}else {
									mc.stop()
								}
						}
						num--
					}
				}
				len--
			}	
		}
		private function updateLayout():void{
			var children:Array = getAllChildren();
			var ypos:Number = 0;
			for each(var child:DisplayObject in children){
				child.y = ypos;
				ypos += child.height;
			}
		}
		
		public function updateList():void
		{
			this.invalidateDisplayList();
			playFit()
		}
		
		/**
		 * 用来优化，目的是尽量减少不可见可视对象的重绘。 
		 * @param event
		 * 
		 */		
		override protected function verticalScroll(event:ScrollEvent):void
		{
			super.verticalScroll(event);
			if(chatScroll)
				verticalHandler();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			if(scrollEnable && vscrollBar){
				vscrollBar.scrollPosition = vscrollBar.maxScrollPosition;
			}			
		}
		
		public function verticalHandler():void{
			if(vscrollBar){
				
				var max:Number = vscrollBar.maxScrollPosition;
				var position:Number = vscrollBar.scrollPosition;
				if(position > 0 && position < max){
					scrollEnable = false;
				}else{
					scrollEnable = true;
					
				}
				playFit()
			}
		}
	}
}