package com.ming.ui.layout
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	/**
	 * 扇形布局 
	 * @author huyongbo
	 * 
	 */	
	public class CamberLayout extends EllipseLayout
	{
		//分布范围 如果90那么就是指从startAngle 开始到angelRange 这样以一个范围
		protected var angelRange:Number;
		
		public function CamberLayout(centerPoint:Point,groupEls:Array,startAngle:Number,radiusX:Number,radiusY:Number,angelRange:Number)
		{
			this.type = "CamberLayout";
			super(centerPoint,groupEls,startAngle,radiusX,radiusY);
			this.angelRange = angelRange;
		}
		
		override public function layout():void{
			var len:Number = this.layoutEls.length;
			this.disAngle = this.angelRange / len;
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