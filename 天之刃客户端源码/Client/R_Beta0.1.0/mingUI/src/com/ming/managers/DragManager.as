package com.ming.managers
{
	import com.ming.events.DragEvent;
	import com.ming.utils.Handler;
	import com.ming.utils.RectUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * 这个类可以实现对Bitmap,TextField的拖动，支持多物品拖动,
	 * 并且会自动向外发布DragOver,DragOut,DragDrop等事件。
	 * 
	 * 这个类的DragStart和DragStop事件都是可中断的，若指定中断就可以中止原来的操作。
	 * 
	 * 设定type可以选择拖动临时图标代替拖动本体
	 * 
	 */	
	public class DragManager
	{
//		/**
//		 * 直接拖动
//		 */
//		public static const SELF:String = "self";
		/**
		 * 复制一个图标并拖动
		 */
		public static const CLONE:String = "clone";
		/**
		 * 生成一个虚框
		 */
		public static const BORDER:String = "border";
		/**
		 * 复制一个带有透明度的图标并拖动
		 */
		public static const ALPHA_CLONE:String = "alpha_clone";
		
		/**
		 * 是否正在拖拽
		 */ 
		public static var isDragging:Boolean = false;
		
		private static var list:Dictionary = new Dictionary();//物品对应拖动管理器的临时字典
		private static var regObject:Dictionary = new Dictionary();//注册的拖动物品字典
		
		/**
		 * 开始拖动
		 * 
		 * @param obj	要拖动的物品
		 * @param bounds	拖动的范围，坐标系为父对象
		 * @param type	拖动类型
		 * @param lockCenter	是否以物体中心点为拖动的点
		 * @param collideByRect	判断范围是否以物品的边缘而不是注册点为标准
		 * 
		 */
		public static function startDrag(obj:DisplayObject,type:String = CLONE,bounds:Rectangle=null,
										 lockCenter:Boolean = false):void
		{
			if (list[obj]!=null)
				return;
			var o:DragManager = new DragManager();
			o.obj = obj;
			o.bounds = bounds;
			o.type = type;
			o.lockCenter = lockCenter;
			if(o.obj.stage){
				o.downMouseX = o.obj.mouseX;
				o.downMouseY = o.obj.mouseY;
				o.obj.stage.addEventListener(MouseEvent.MOUSE_MOVE,startMoveHandler);
				o.obj.stage.addEventListener(MouseEvent.MOUSE_UP,startUpHandler);
			}
			function startMoveHandler(event:MouseEvent):void{
				if(Math.abs(o.obj.mouseX - o.downMouseX) > 4 || Math.abs(o.obj.mouseY - o.downMouseY) > 4){
					startUpHandler(null);
					o.startDrag();
				}
			}
			
			function startUpHandler(event:MouseEvent):void{
				o.obj.stage.removeEventListener(MouseEvent.MOUSE_MOVE,startMoveHandler);
				o.obj.stage.removeEventListener(MouseEvent.MOUSE_UP,startUpHandler);
			}
		}
		
		/**
		 * 停止拖动
		 */
		public static function stopDrag(obj:DisplayObject):void
		{
			if (list[obj])
				(list[obj] as DragManager).stopDrag();
		}
				
		/**
		 * 注册一个可拖动的物品
		 * 
		 * @param obj	触发拖动的对象
		 * @param target	被拖动的对象
		 * 
		 */
		public static function register(obj:DisplayObject,target:DisplayObject=null,bounds:Rectangle=null,
										type:String = CLONE,lockCenter:Boolean = false):void
		{
			if (!target)
				target = obj;
			
			regObject[obj] = new Handler(DragManager.startDrag,[target,type,bounds,lockCenter]);
			obj.addEventListener(MouseEvent.MOUSE_DOWN,dragStartHandler);
		}
		
		/**
		 * 取消注册拖动，这样被拖动的物品才可以被回收
		 * @param obj
		 * 
		 */
		public static function unregister(obj:DisplayObject):void
		{
			obj.removeEventListener(MouseEvent.MOUSE_DOWN,dragStartHandler);
			delete regObject[obj];
		}
		
		private static function dragStartHandler(event:MouseEvent):void
		{
			var h:Handler = regObject[event.currentTarget];
			if (h)
				h.call();
		}
		
		protected var obj:DisplayObject;
		protected var type:String;
		protected var lockCenter:Boolean;
		protected var bounds:Rectangle;
		
		protected var downMouseX:Number = 0;
		protected var downMouseY:Number = 0;
		protected var dragMousePos:Point;
		protected var dragPos:Point;
		protected var dragContainer:DisplayObject;
		
		protected var image:DisplayObject;
		
		protected function startDrag():void
		{	
			var e:DragEvent = new DragEvent(DragEvent.DRAG_START,false,true);
			e.dragObj = obj;
			obj.dispatchEvent(e);
			
			if (e.isDefaultPrevented())
				return;
			
			list[obj] = this;
			if (lockCenter)
				dragMousePos = RectUtil.center(obj,obj.stage);
			else
				dragMousePos = RectUtil.localToContent(new Point(downMouseX,downMouseY),obj,obj.stage);
			
			dragPos = obj.parent.localToGlobal(new Point(obj.x,obj.y));
			
			obj.stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			obj.stage.addEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler);
			obj.stage.addEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler);
			obj.stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
			if(type == BORDER){
				image = new Shape();
				var s:Shape = Shape(image);
				s.graphics.lineStyle(2,0xCACACA,1);
				s.graphics.beginFill(0x0,0);
				s.graphics.drawRoundRect(0,0,obj.width,obj.height,4);
				s.graphics.endFill();
//				s.filters = [new GlowFilter(0xffffff)];
			}
			if (type == CLONE || type == ALPHA_CLONE)
			{
				var bitmapdata:BitmapData = new BitmapData(obj.width,obj.height,true,0x0);
				bitmapdata.draw(obj);
				image = new Bitmap(bitmapdata);
				if (type == ALPHA_CLONE)
					image.alpha = 1;
			}
			image.x = dragPos.x;
			image.y = dragPos.y;			
			obj.stage.addChild(image);
			isDragging = true;
		}
		
		protected function stopDrag():void
		{
			var e:DragEvent = new DragEvent(DragEvent.DRAG_STOP,false,true);
			e.dragObj = obj;
			obj.dispatchEvent(e)
			
			if (e.isDefaultPrevented())
				return;
			
			if (obj.stage)
			{
				obj.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
				obj.stage.removeEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler);
				obj.stage.removeEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler);
				obj.stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
			}
	
			dragPos = null;
			dragMousePos = null;
			
			delete list[obj];
			if (image)
			{
				if(obj.parent){
					var point:Point = obj.parent.globalToLocal(new Point(image.x,image.y));
					obj.x = point.x;
					obj.y = point.y;
				}
				if(type  == CLONE){
					Bitmap(image).bitmapData.dispose();
				}
//				image.filters = [];
				if(image.parent){
					image.parent.removeChild(image);
				}
			}
			isDragging = false;
		}
		
		private function mouseMoveHandler(event:MouseEvent):void
		{
			var dragObj:DisplayObject = image ? image : obj;
			if(!dragObj.parent)return;
			bounds = bounds ? bounds : new Rectangle(0,0, dragObj.stage.stageWidth, dragObj.stage.stageHeight);
			var isIn:Boolean = bounds.contains(dragObj.stage.mouseX,dragObj.stage.mouseY);
			if(isIn){
				var	parentOffest:Point = RectUtil.localToContent(new Point(obj.mouseX,obj.mouseY),obj,obj.stage).subtract(dragMousePos);
				var tempx:Number = dragPos.x + parentOffest.x;
				tempx = Math.max(tempx,40 - dragObj.width);
				tempx = Math.min(tempx,dragObj.stage.stageWidth - 30);
				
				var tempy:Number = dragPos.y + parentOffest.y;
				tempy = Math.max(tempy,-15);
				tempy = Math.min(tempy,dragObj.stage.stageHeight - 30);
				if (image)
				{
					image.x = tempx;
					image.y = tempy;
				}
				else
				{
					obj.x = tempx;
					obj.y = tempy;
				}
			}
			var e:DragEvent = new DragEvent(DragEvent.DRAG_ON,false,false);
			e.dragObj = obj;
			obj.dispatchEvent(e);
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			stopDrag();
			
			if (dragContainer)
			{
				var e:DragEvent = new DragEvent(DragEvent.DRAG_DROP,true,false);
				e.dragObj = obj;
				dragContainer.dispatchEvent(e);
				dragContainer = null;
			}
			
			e = new DragEvent(DragEvent.DRAG_COMPLETE,false,false);
			e.dragObj = obj;
			obj.dispatchEvent(e);
		}
		
		private function mouseOverHandler(event:MouseEvent):void
		{
			dragContainer = event.target as DisplayObject;
			
			var e:DragEvent = new DragEvent(DragEvent.DRAG_OVER,true,false);
			e.dragObj = obj;
			event.target.dispatchEvent(e.clone());
		}
		
		private function mouseOutHandler(event:MouseEvent):void
		{
			var e:DragEvent = new DragEvent(DragEvent.DRAG_OUT,true,false);
			e.dragObj = obj;
			event.target.dispatchEvent(e);
		}
	}
}
