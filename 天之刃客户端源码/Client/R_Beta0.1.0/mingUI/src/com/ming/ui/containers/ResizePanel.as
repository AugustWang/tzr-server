package com.ming.ui.containers
{
	import com.ming.events.ResizeEvent;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.TextUtil;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class ResizePanel extends Panel
	{
		private var minShape:UIComponent;
		private var restoreShape:UIComponent;
		private var resizeShape:UIComponent;
		private var myRestoreHeight:int;
		private var isMinimized:Boolean = false;
		private var _allowResize:Boolean = true;
		public var minWidth:Number = 100;
		public var minHeight:Number = 100;
		public var maxWidth:Number = 800;
		public var maxHeight:Number = 800;
		public function ResizePanel()
		{
			super();
			init();
		}
		
		public function set allowResize(value:Boolean):void{
			_allowResize = value;
			if(_allowResize){
				createResizeUI();
			}else{
				removeResizeUI();
			}
		}
		public function get allowResize():Boolean{
			return _allowResize;
		}
		
		private function init():void{
			minShape = new UIComponent();
			minShape.width = closeWidth;
			minShape.height = closeHeight;
			
			minShape.addEventListener(MouseEvent.MOUSE_DOWN, minPanelSizeHandler);
			addChildToSuper(minShape);
			
			restoreShape = new UIComponent();
			restoreShape.width = closeWidth;
			restoreShape.height = closeHeight;			
			restoreShape.addEventListener(MouseEvent.MOUSE_DOWN, restorePanelSizeHandler);
			addChildToSuper(restoreShape);	
			
			allowResize = true;
		}
		
		private function createResizeUI():void{
			resizeShape = new UIComponent();
			resizeShape.width = 15;
			resizeShape.height = 15;
			resizeShape.alpha = 0;
			resizeShape.useHandCursor = resizeShape.buttonMode = true;
			resizeShape.addEventListener(MouseEvent.MOUSE_DOWN,resizeHandler);
			addChildToSuper(resizeShape);			
		}
		
		private function removeResizeUI():void{
			removeSuperChild(resizeShape);
			resizeShape.removeEventListener(MouseEvent.MOUSE_DOWN,resizeHandler);
			resizeShape = null;
		}
		
		override public function dispose() : void{
			super.dispose();
			minShape.dispose();
			restoreShape.dispose();
		}
		
		override protected function onReisze(event:ResizeEvent) : void{
			super.onReisze(event);
			_closeButton.x= this.width - _closeButton.width - closeRight;
			_closeButton.y= closeTop;
			
			minShape.y = closeTop;
			minShape.x = width - closeRight - 2*closeWidth - 5;
			
			restoreShape.y = closeTop;
			restoreShape.x = minShape.x - closeWidth - 5;
			
			if(resizeShape){
				resizeShape.y = height - resizeShape.height;
				resizeShape.x = width - resizeShape.width;
			}
			
			_dragBar.width = width;
			if(_titleText){
				_titleText.x= 10;
				_titleText.y=(headHeight - _titleText.height) / 2;	
				_titleText.width = restoreShape.x;
				
				TextUtil.fitText(_titleText,title,restoreShape.x);	
			}
		}

		private function minPanelSizeHandler(event:Event):void
		{
			if (isMinimized != true)
			{
				myRestoreHeight = height;	
				height = _dragBar.height;
				isMinimized = true;	
				if(resizeShape){
					resizeShape.visible = false;
				}
			}				
		}
		
		private function restorePanelSizeHandler(event:Event):void
		{
			if (isMinimized == true)
			{
				height = myRestoreHeight;
				isMinimized = false;
				if(resizeShape){
					resizeShape.visible = true;
				}				
			}
		}
		private var dragPos:Point;
		private var shape:Shape;
		private var leaveing:Boolean = false;
		public function resizeHandler(event:MouseEvent):void
		{
			if(shape){
				mouseUpHandler(null);
			}
			shape = new Shape();
			drawShape(width,height);	
			var point:Point = localToGlobal(new Point(0,0));
			shape.x = point.x;
			shape.y = point.y;
			stage.addChild(shape);
			dragPos = new Point(event.stageX,event.stageY);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);	
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		private var tempW:Number = 0;
		private var tempH:Number = 0;
		private function mouseMoveHandler(event:MouseEvent):void{
			var currentX:Number = event.stageX;
			var currentY:Number = event.stageY;
			var addWidth:Number = currentX - dragPos.x;
			var addHeight:Number = currentY - dragPos.y;
			if(width + addWidth >= minWidth && width + addWidth < maxWidth && currentX <= (stage.stageWidth - closeWidth)){
				tempW = width+addWidth;
			}
			if(height + addHeight >= minHeight && height + addHeight < maxHeight && currentY <= (stage.stageHeight - closeHeight)){
				tempH = height + addHeight;
			}
			drawShape(tempW,tempH);
			//event.updateAfterEvent();
		}
		
		private function mouseUpHandler(event:MouseEvent):void{
			this.width = shape.width;
			this.height = shape.height;
			stage.removeChild(shape);
			shape = null;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function drawShape(w:Number,h:Number):void{
			shape.graphics.clear();
			shape.graphics.lineStyle(2,0xCCCCCC);
			shape.graphics.drawRect(0,0,w,h);
			shape.graphics.endFill();				
		}
	}
}