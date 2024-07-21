package com.ming.ui.controls
{
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class TimerButton extends Button
	{
		private var timer:Timer;
		private var oldText:String;
		private var oldEnabled:Boolean;
		public function TimerButton()
		{
			super();
			addEventListener(MouseEvent.CLICK,onClick);
		}
		
		public var repeatCount:int = -1;
		private function onClick(evt:MouseEvent):void{
			if(repeatCount > 0){
				start(repeatCount);
			}
		}
		
		public function start(_repeatCount:int=10):void{
			if(timer == null){
				timer = new Timer(1000);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE,onComplete);
				timer.addEventListener(TimerEvent.TIMER,onTimer);
			}
			oldEnabled = enabled;
			enabled = false;
			oldText = label;
			timer.repeatCount = _repeatCount;
			timer.reset();
			timer.start();
			validateNow();
		}
		
		public function stop():void{
			if(timer){
				timer.stop();
			}
		}
		
		private function onTimer(evt:TimerEvent):void{
			label = (timer.repeatCount - timer.currentCount) + "秒";
			validateNow();
		}
		
		private function onComplete(evt:TimerEvent):void{
			label = oldText;
			enabled = oldEnabled;
			validateNow();
		}
		
		override public function set enabled(value:Boolean):void{
			if(timer && timer.running){
				oldEnabled = value;
			}else{
				super.enabled = value;
			}
		}
	}
}