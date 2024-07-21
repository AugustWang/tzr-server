package com.common.effect
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	/**
	 * 
	 * 发光效果类
	 * 
	 */		
	public class FlickerEffect
	{
		/**
		 *目标对象 
		 */			
		private var _target:DisplayObject; 
		private var _frameCount:int = 8;
		private var i:int = 0;
		private var _initState:Boolean;
		public function FlickerEffect()
		{
			
		}
		
		public function start(target:DisplayObject,perframe:int=8):void
		{
			if(target){
				_target=target;
				_initState = target.visible;
				_frameCount = perframe;
				_target.addEventListener(Event.ENTER_FRAME, blinkHandler);
				i = 0;
			}
		}
		
		public function stop():void
		{
			if(_target){
				_target.visible = _initState;
				_target.removeEventListener(Event.ENTER_FRAME, blinkHandler);
				_target = null;
			}
		}
		
		public function running():Boolean{
			return _target != null;
		}
		
		private function blinkHandler(evt:Event):void
		{
			if(i == _frameCount){
				_target.visible = !_target.visible;
				i = 0;
			}
			i++;
		}
	}
}