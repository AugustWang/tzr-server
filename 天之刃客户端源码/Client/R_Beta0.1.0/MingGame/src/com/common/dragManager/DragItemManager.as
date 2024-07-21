package com.common.dragManager
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	/**
	 * 用于小图标项拖拽和粘附，便于判断是否脱离母体，或者其他逻辑判断，并且支持延迟拖拽和粘附拖拽
	 * 区别于DragManager，DragManager主要用于窗口等逻辑比较简单的拖拽功能
	 * 当拖拽当前项将要停止拖拽时并不在IDragItem的实现项和UILayer上时将获取DragTarget派发一个冒泡事件
	 */ 
	public class DragItemManager extends Sprite
	{
		/**
		 * 拖拽类型
		 */ 
		public static const CLONE:String = "clone"; //克隆副本拖拽
		public static const ENTITY:String = "entity"; //实体对象拖拽
		
		private static const ADHERE:String = "adhere"; //粘附
		private static const DRAG:String = "drag"; //拖拽
		
		public static var instance:DragItemManager;
		public function DragItemManager(layer:Sprite)
		{
			layer.addChild(this);
			layer.addEventListener(DragItemEvent.DRAG_DROP,dragDropHandler);
			init();
		}
		
		public static function setUp(p:Sprite):void{
			instance = new DragItemManager(p);
		}
		
		private var actionType:String;
		private var dragProxy:Sprite;
		private var bitmap:Bitmap;
		private var timer:Timer;
		private function init():void{
			dragProxy = new Sprite();
			dragProxy.mouseChildren = dragProxy.mouseEnabled = false;
			dragProxy.buttonMode = dragProxy.useHandCursor = true;
			bitmap = new Bitmap();
			timer = new Timer(200,1);
			timer.addEventListener(TimerEvent.TIMER,timerHandler);
		}
		
		private function timerHandler(event:TimerEvent):void{
			doStartDrag();
		}
		
		private var dragTarget:DisplayObject;
		private var dragSource:DisplayObject;
		private var type:String;
		private var itemName:String;
		private var dragData:Object;
		private var dragStartPoint:Point;
		private var dragOffset:Point;
		private var parentItem:IDragItem;
		/**
		 * 开始粘附 
		 * @param dragSource 粘附源 （也就是对于物品丢弃在世界时，抛出threw事件被它所感知）
		 * @param dragTarget 粘附目标
		 * @param itemName 当前拖拽项的名称，起到标识作用
		 * @param dragData   数据
		 * @param type 类型
		 * @param lockCenter 是否已锁定中心粘附
		 * 
		 */		
		public function startAdhereItem(dragSource:DisplayObject,dragTarget:DisplayObject,itemName:String,dragData:Object=null,type:String = ENTITY,delay:int=200,lockCenter:Boolean=true):void{
			if(isDragging())return;
			if(this.dragTarget == dragTarget && timer.running){
				stop();
				return;
			}
			actionType = ADHERE;
			doAction(dragSource,dragTarget,itemName,dragData,type,lockCenter);
			timer.delay = delay;
			timer.reset();
			timer.start();
		}
		
		
		/**
		 * 开始拖拽 
		 * @param dragSource 拖拽 源 （也就是对于物品丢弃在世界时，抛出threw事件被它所感知）
		 * @param dragTarget 拖拽 目标
		 * @param dragData   数据
		 * @param itemName 当前拖拽项的名称，起到标识作用 
		 * @param type 类型
		 * @param lockCenter 是否已锁定中心拖拽 
		 * 
		 */		
		public function startDragItem(dragSource:DisplayObject,dragTarget:DisplayObject,itemName:String,dragData:Object=null,type:String = CLONE,lockCenter:Boolean=false):void{
			if(isDragging())return;
			actionType = DRAG;
			doAction(dragSource,dragTarget,itemName,dragData,type,lockCenter);
			stage.addEventListener(MouseEvent.MOUSE_UP,onDragMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onDragMouseMove);
		}
		
		private function onDragMouseUp(event:MouseEvent):void{
			if(isDragging()){
				mouseEventHandler(event);
			}else{
				clear();
			}
		}
		
		private function onDragMouseMove(event:MouseEvent):void{
			if(Math.abs(dragStartPoint.x - stage.mouseX) > 4 || Math.abs(dragStartPoint.y - stage.mouseY) > 4){
				doStartDrag();
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,onDragMouseMove);
			}
		}
		
		private function doAction(dragSource:DisplayObject,dragTarget:DisplayObject,itemName:String,dragData:Object=null,type:String = ENTITY,lockCenter:Boolean=false):void{
			this.dragTarget = dragTarget;
			this.parentItem = dragTarget.parent as IDragItem;
			this.dragSource = dragSource;
			this.type = type;
			this.dragData = dragData;
			this.itemName = itemName;
			if(dragTarget.width == 0 || dragTarget.height == 0){
				return;
			}
			var targetTopLeft:Point = dragTarget.localToGlobal(new Point(0,0));
			dragStartPoint = new Point(stage.mouseX,stage.mouseY);
			var offsetX:Number = 0,offsetY:Number = 0;
			if(lockCenter){
				offsetX = -dragTarget.width/2 ;
				offsetY = -dragTarget.height/2;
			}else{
				offsetX = targetTopLeft.x - stage.mouseX;
				offsetY = targetTopLeft.y - stage.mouseY;
			}
			dragOffset = new Point(offsetX,offsetY);		
		}
		
		private function doStartDrag():void{
			if(dragTarget == null)return;
			parent.mouseEnabled = true;
			dispatchEvent(new DragItemEvent(DragItemEvent.START_DRAG,dragData,dragTarget,itemName));
			if(actionType == ADHERE){
				Mouse.hide();
				stage.addEventListener(MouseEvent.CLICK,mouseEventHandler);
			}
			if(type == ENTITY){
				var oldParent:IDragItem = dragTarget.parent as IDragItem;
				if(oldParent){
					oldParent.disposeContent();
				}
				dragTarget.x = 0;
				dragTarget.y = 0;
				dragProxy.addChild(dragTarget);	
			}else{
				var bitmapdata:BitmapData = new BitmapData(dragTarget.width,dragTarget.height,true,0x00ffffff);
				bitmapdata.draw(dragTarget);
				bitmap.bitmapData = bitmapdata;
				dragProxy.addChild(bitmap);
			}
			dragProxy.x = stage.mouseX + dragOffset.x;
			dragProxy.y = stage.mouseY + dragOffset.y;
			stage.addChild(dragProxy);
			dragProxy.startDrag();
		}
		
		private function dragDropHandler(event:DragItemEvent):void{
			if(dragSource){
				dragSource.dispatchEvent(new DragItemEvent(DragItemEvent.DRAG_THREW,event.dragData,event.dragTarget,event.itemName));
			}
		}
		
		private function mouseEventHandler(event:MouseEvent):void{
			var dragItem:IDragItem = event.target as IDragItem;
			if(dragItem && dragItem.allowAccept(dragData,itemName)){
				dragItem.dragDrop(dragData,dragTarget,itemName);
				clear();
				return
			}
			if(event.target == parent && DragOnMap.allowAccept(dragData,itemName)){
				doStopDrag(parent);
				clear();
				return
			}
			var target:DisplayObject = dragProxy.dropTarget;
			if(target){
				target.dispatchEvent(new DragItemEvent(DragItemEvent.DRAG_ENTER,dragData,dragTarget,itemName,true));
			}
			
			var evt:DragItemEvent = new DragItemEvent(DragItemEvent.NOT_FIND_TARGET,dragData,dragTarget,itemName);
			evt.toTarget = event.target as DisplayObject;
			if(dragSource){
				dragSource.dispatchEvent(evt);
			}
			if(actionType == DRAG){
				if(type == ENTITY)
					cancel();
				clear();
			}
		}
		
		private function doStopDrag(target:DisplayObject):void{
			if(!dragProxy.parent)return
			var evt:DragItemEvent = new DragItemEvent(DragItemEvent.DRAG_DROP,dragData,dragTarget,itemName);
			target.dispatchEvent(evt);
		}

		private function clear():void{
			parent.mouseEnabled = false;
			if(actionType == ADHERE){
				Mouse.show();
			}
			dispatchEvent(new DragItemEvent(DragItemEvent.STOP_DRAG,dragData,dragTarget,itemName));
			timer.stop();
			if(actionType == ADHERE){
				stage.removeEventListener(MouseEvent.CLICK,mouseEventHandler);
			}else{
				stage.removeEventListener(MouseEvent.MOUSE_UP,onDragMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,onDragMouseMove);
			}
			if(dragProxy.parent){
				dragProxy.stopDrag();
				dragProxy.parent.removeChild(dragProxy);
				if(dragProxy.numChildren > 0){
					var child:DisplayObject = dragProxy.removeChildAt(0);
					if(type == CLONE){
						(child as Bitmap).bitmapData.dispose();
					}					
				}
			}
			parentItem = null;
			dragTarget = null;
			dragSource = null;	
			dragData = null;
			dragStartPoint = null;
			dragOffset = null;			
			itemName = "";
		}
		
		public function cancel():void{
			if(parentItem){
				parentItem.setContent(dragTarget,dragData);
			}
		}
		
		public function stop():void{
			clear();
		}
		
		public static function isDragging():Boolean{
			return instance.dragProxy.parent != null;
		}
	}
}