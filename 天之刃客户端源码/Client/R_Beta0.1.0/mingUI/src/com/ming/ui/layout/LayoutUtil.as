package com.ming.ui.layout
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	/**
	 * 简单布局工具类
	 */ 
	public class LayoutUtil
	{
		/**
		 * 垂直布局 
		 */	
		public static function layoutVectical(container:DisplayObjectContainer,
											  vpadding:Number=0,startY:Number=0):void{
			if(!container)return;
			var size:int = container.numChildren;
			if(size == 0)return;
			var y:int = startY;
			for(var i:int = 0;i<size;i++){
				var child:DisplayObject = container.getChildAt(i);
				child.y = y;
				y = child.height + child.y + vpadding;
			}
		}
		/**
		 * 水平布局 
		 */	
		public static function layoutHorizontal(container:DisplayObjectContainer,
											  hpadding:Number=0,startX:int=0):void{
			if(!container)return;
			var size:int = container.numChildren;
			if(size == 0)return;
			var x:int = startX;
			for(var i:int = 0;i<size;i++){
				var child:DisplayObject = container.getChildAt(i);
				child.x = x;
				x = child.width+ child.x + hpadding;
			}
		}
		/**
		 * 网格布局 
		 */		
		public static function layoutGrid(container:DisplayObjectContainer,columnCount:int,hPadding:Number,vPadding:Number):void{
			if(!container)return;
			var size:int = container.numChildren;
			if(size == 0)return;
			for(var i:int;i<size;i++){
				var child:DisplayObject = container.getChildAt(i);
				var row:int = i / columnCount;
				var column:int = i % columnCount;
				child.x = column*child.width + column*hPadding;
				child.y = row*child.height + row*vPadding;
			}			
		}
		/**
		 * 椭圆布局 
		 * 
		 */		
		public static function layoutEllipse(container:DisplayObjectContainer,centerPoint:Point,radiusX:Number,radiusY:Number,startAngle:Number=0):void{
			if(!container)return;
			var size:int = container.numChildren;
			if(size == 0)return;
			var elements:Array = [];
			for(var i:int;i<size;i++){
				elements.push(container.getChildAt(i));
			}
			var layout:EllipseLayout = new EllipseLayout(centerPoint,elements,startAngle,radiusX,radiusY);
			layout.layout();
		}
		/**
		 * 圆形布局 
		 * 
		 */		
		public static function layoutCircle(container:DisplayObjectContainer,centerPoint:Point,radius:Number,startAngle:Number=0):void{
			if(!container)return;
			var size:int = container.numChildren;
			if(size == 0)return;
			var elements:Array = [];
			for(var i:int;i<size;i++){
				elements.push(container.getChildAt(i));
			}
			var layout:CircleLayout = new CircleLayout(centerPoint,elements,startAngle,radius);
			layout.layout();
		}
		/**
		 * 扇形布局 
		 * 
		 */		
		public static function layoutCamber(container:DisplayObjectContainer,centerPoint:Point,radiusX:Number,radiusY:Number,startAngle:Number=0,angleRange:Number=180):void{
			if(!container)return;
			var size:int = container.numChildren;
			if(size == 0)return;
			var elements:Array = [];
			for(var i:int;i<size;i++){
				elements.push(container.getChildAt(i));
					}
			var layout:CamberLayout = new CamberLayout(centerPoint,elements,startAngle,radiusX,radiusY,angleRange);
			layout.layout();
		}
	}
}