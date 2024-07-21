package com.ming.ui.controls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * 在结束后，触发 flash.events.Event.COMPLETE 事件
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * 一个可转动的扇形,就像游戏里的冷却时间一样<br />
	 * 可以附加到任意显示对象,<br />
	 * 
	 */
	public class ImageCooling extends Bitmap
	{
		public var running:Boolean = false;
		public var color:uint;
		
		public var beginTime:Number = 0;	// 开始的时间
		public var totalTime:Number = 0;	// 总时间
		public var startFrom:Number = 0;	// 开始的角度
		
		private static var slices:Dictionary;
		public function ImageCooling() 
		{
			if(slices == null){
				slices = new Dictionary();
				var cd:CD = new CD();				
				for(var i:int=0;i<=72;i++){
					cd.draw(360-5*i,5*i-90);
					var bitmapData:BitmapData = new BitmapData(36,36,true,0);
					var matrix:Matrix = new Matrix();
					matrix.tx = 18;
					matrix.ty = 18;
					bitmapData.draw(cd,matrix);
					slices[i] = bitmapData;
				}
			}
		}
		
		/**
		 * 设置目标，并添加到目标上层<br />
		 * 目标必须在现实列表里<br />
		 * 转动结束后出发complete事件
		 * 
		 * @param	display
		 * @eventType	flash.events.Event
		 */
		public function setTarget(display:DisplayObject):void
		{		
			var rect:Rectangle = display.getBounds(display.parent);
//			var halfW:Number = rect.width * 0.5;
//			var halfH:Number = rect.height * 0.5;
			this.x = rect.x;
			this.y = rect.y;
			
			// 添加到显示列表
			display.parent.addChildAt(this, display.parent.getChildIndex(display) + 1);
		}
		
		/**
		 * 从某个角度开始转一周
		 * @param	startFrom	开始转动的角度
		 * @param	totalTime	转一圈所用的时间(单位:毫秒)
		 */
		public function  start(totalTime:Number,startFrom:Number = 0):void
		{
			this.startFrom = startFrom;
			changeAngle();
			this.totalTime = totalTime;
			beginTime = getTimer();
			running = true;
			
			drawSlice(startFrom);
			
			if (!hasEventListener(Event.ENTER_FRAME))
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		/**
		 * 将以x轴正方向为0°的角度，转行为y轴正方向为0°
		 */ 
		private var transformAngle:Number;
		private function changeAngle():void{
			if(startFrom < 0){
				transformAngle = startFrom + 90;
			}else{
				transformAngle = startFrom - 90;
			}
		}
		/**
		 * 获取已经旋转角度
		 */ 
		private var alreadyAngle:Number = 0;
		public function getStandardAngle():Number{
			return alreadyAngle + startFrom;
		}
		/**
		 * 获取剩余时间
		 */ 
		public function getRestTime():int{
			return totalTime - postTime;
		}
		
		public function stop():void{
			if (hasEventListener(Event.ENTER_FRAME)){
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);			
			}
			running = false;
		}

	
		private var postTime:Number = 0;
		private function enterFrameHandler(e:Event):void 
		{
			postTime = getTimer() - beginTime;
			if (postTime >= totalTime)
			{
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				bitmapData = null;
				running = false;
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				var arc:int = 360 - startFrom;
				var angle:Number = arc * postTime / totalTime;
				alreadyAngle = angle;
				drawSlice(angle + startFrom);
			}
		}
		
		private function drawSlice(angle:Number):void{
			var index:int = angle/5;
			bitmapData = slices[index];
		}
	}
}
import com.ming.utils.Pen;

import flash.display.Shape;
import flash.display.Sprite;

class CD extends Sprite{
	private var rect:Shape;
	private var pen:Pen;
	public function CD(){
		rect = new Shape();
		rect.graphics.beginFill(0,0.5);
		rect.graphics.drawRect(-18,-18,36,36);
		rect.graphics.endFill();
		addChild(rect);
		
		var sector:Shape = new Shape();
		sector.x = rect.x;
		sector.y = rect.y;
		addChild(sector);
		rect.mask = sector;
		pen = new Pen(sector.graphics);
	}
	
	
	public function draw(arc:Number,angle:Number):void{
		pen.clear();
		pen.beginFill(0,0.6);
		pen.drawSlice(arc,30,angle,0,0);
		pen.endFill();
	}
}