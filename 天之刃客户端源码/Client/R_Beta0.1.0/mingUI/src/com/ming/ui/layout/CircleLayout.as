package com.ming.ui.layout
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	/**
	 * 圆形布局
	 * @author huyongbo
	 * 
	 */	
	public class CircleLayout extends BaseLayout
	{
		//半径 因为X Y 方向半径都是一样的 
		//为了让这个变量可以让椭圆使用 所以使用 radiusX 好和 radiusY对应
		protected var radiusX:Number;
		
		
		public function CircleLayout(centerPoint:Point,groupEls:Array,startAngle:Number,radius:Number){
			this.centerPoint = centerPoint
			this.layoutEls   = groupEls;
			this.startAngle = startAngle;
			this.radiusX = radius;
		}
		
		
		override public function layout():void{
			var len:Number = this.layoutEls.length
			this.disAngle = 360 / len;
			for(var i:int=0;i<len;i++){
				var tempRaian:Number = this.startAngle*Math.PI/180; 
				var node:DisplayObject = this.layoutEls[i] as DisplayObject;
				node.x = this.centerPoint.x + Math.cos(tempRaian)*this.radiusX;
				node.y = this.centerPoint.y + Math.sin(tempRaian)*this.radiusX;
				//角度增加
				this.startAngle+=this.disAngle;
			}
		}
		
	}
}