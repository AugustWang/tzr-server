package com.components
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	public class FPS extends Sprite
	{
		private var _f:int = 0;
		private var _t:int = 0;
		private var _fps:TextField;
		public function FPS()
		{
			super();
			_fps = new TextField();
			_fps.height = 25;
			_fps.width = 150;
			_fps.x = 5;
			_fps.y = 3;
			addChild(_fps);
			
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
			
			with(graphics){
				lineStyle(1,0x000000);
				beginFill(0xffffff,0.6);
				drawRect(0,0,150,25);
			}
		}
		
		private function onEnterFrame(event:Event):void{
			_f++;
			if((getTimer() - _t) >= 1000) {
				_fps.text = "fps:"+_f+"   memory:"+System.totalMemory/1024+"kb";
				_t = getTimer();
				_f = 0;
			}
		}
	}
}