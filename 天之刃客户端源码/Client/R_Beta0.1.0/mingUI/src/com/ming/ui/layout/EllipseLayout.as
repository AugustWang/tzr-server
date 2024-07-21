package com.ming.ui.layout
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	/**
	 * 椭圆布局 
	 * @author huyongbo
	 * 
	 */
	public class EllipseLayout extends CircleLayout
	{
		//Y方向半径
		protected var radiusY:Number;
		
		public function EllipseLayout(centerPoint:Point,groupEls:Array,startAngle:Number,radiusX:Number,radiusY:Number)
		{
			super(centerPoint,groupEls,startAngle,radiusX);
			this.radiusY = radiusY;
		}
		
		//布局算法 基本和圆形一样
		override public function layout():void{
			var len:Number = this.layoutEls.length;
			this.disAngle = 360/len;
			for(var i:int=0;i<len;i++){
				var tempRaian:Number = this.startAngle*Math.PI/180; 
				var node:DisplayObject = this.layoutEls[i] as DisplayObject;
				node.x = this.centerPoint.x + Math.cos(tempRaian)*this.radiusX;
				node.y = this.centerPoint.y + Math.sin(tempRaian)*this.radiusY;
				//角度增加
				this.startAngle+=this.disAngle;
			}
		}
	}
}