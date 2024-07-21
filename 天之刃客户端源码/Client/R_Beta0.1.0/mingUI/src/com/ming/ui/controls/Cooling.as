package com.ming.ui.controls
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
	public class Cooling extends Sprite
	{
		public var running:Boolean = false;
		public var color:uint;
		
		public var beginTime:Number = 0;	// 开始的时间
		public var totalTime:Number = 0;	// 总时间
		public var startFrom:Number = 0;	// 开始的角度
		
		private var sector:Sector;
		private var maskShape:Shape;
		
		public function Cooling() 
		{
			mouseChildren = false;
			mouseEnabled = false;
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
			// init UI
			if (sector) removeChild(sector);
			if (!maskShape) maskShape = new Shape();
			
			
			var radius:Number = Math.sqrt(display.width * display.width + display.height * display.height) * 0.5;
			sector = new Sector();
			sector.fillColor = 0xff00ff;
			sector.radius = radius;
			addChild(sector);
			
			var rect:Rectangle = display.getBounds(display.parent);
			var stageP:Point = display.localToGlobal(new Point(rect.x, rect.y));
			
			var halfW:Number = rect.width * 0.5;
			var halfH:Number = rect.height * 0.5;
			maskShape.graphics.clear();
			maskShape.graphics.beginFill(color);
			maskShape.graphics.drawRect(-halfW,-halfH,rect.width,rect.height);
			addChild(maskShape);
			maskShape.mask = sector;
			
			this.x = rect.x + halfW;
			this.y = rect.y + halfH;
			
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
			if (sector)
			{
				this.startFrom = startFrom;
				changeAngle();
				this.totalTime = totalTime;
				beginTime = getTimer();
				running = true;
				
				// 先画一个圆
				sector.drawSlice(360, 0);
				
				if (!sector.hasEventListener(Event.ENTER_FRAME))
					sector.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
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
			if (sector.hasEventListener(Event.ENTER_FRAME)){
				sector.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);			
			}
			running = false;
			sector.graphics.clear();
		}

//		private var postTime:Number = 0;
//		public function update(time:int):void 
//		{
//			postTime = time - beginTime;
//			if (postTime >= totalTime)
//			{
//				sector.drawSlice(0,0);
//				running = false;
//				dispatchEvent(new Event(Event.COMPLETE));
//			}
//			else
//			{
//				var arc:int = 360 - startFrom;
//				var angle:Number = arc * postTime / totalTime;
//				alreadyAngle = angle;
//				sector.drawSlice(arc - angle, angle + transformAngle);
//			}
//		}		
		private var postTime:Number = 0;
		private function enterFrameHandler(e:Event):void 
		{
			postTime = getTimer() - beginTime;
			if (postTime >= totalTime)
			{
				sector.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				sector.drawSlice(0,0);
				running = false;
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				var arc:int = 360 - startFrom;
				var angle:Number = arc * postTime / totalTime;
				alreadyAngle = angle;
				sector.drawSlice(arc - angle, angle + transformAngle);
			}
		}
	}
}
import com.ming.utils.Pen;

import flash.display.Shape;

class Sector extends Shape{
	public var fillColor:uint = 0x000000;
	public var radius:Number;
	private var pen:Pen;
	public function Sector(){
		pen = new Pen(this.graphics);
	}
	public function drawSlice(arc:Number,startingAngle:Number):void{
		pen.clear();
		pen.beginFill(fillColor);
		pen.drawSlice(arc,radius,startingAngle,0,0);
		pen.endFill();
	}
}