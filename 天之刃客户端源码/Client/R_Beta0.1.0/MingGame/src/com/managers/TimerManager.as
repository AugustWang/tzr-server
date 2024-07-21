package com.managers
{
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * 时间函数管理器,默认时间基数是100ms 
	 */	
	public class TimerManager
	{
		private var handlerMaps:Dictionary;
		private var timer:Timer;
		public function TimerManager()
		{
			handlerMaps = new Dictionary();
		}
		
		private static var instance:TimerManager;
		public static function getInstance():TimerManager{
			if(instance == null){
				instance = new TimerManager();
			}
			return instance;
		}
		/**
		 * 注册管理函数 
		 * @param handler 执行函数
		 * @param delay 时间间隔 1*100
		 * @param loop  是否循环执行，（默认-1为循环，否则就是loop的次数）
		 * 
		 */		
		public function add(handler:Function,delay:int=1,loop:int=0):void{
			if(handler && loop >= 0 && delay >= 1){
				handlerMaps[handler] = {delay:delay*100,loop:loop,count:0,t:getTimer()};
				start();
			}else{
				throw new Error("注册时间管理函数参数有误！");
			}
		}
		/**
		 * 删除执行函数 
		 * @param handler
		 * 
		 */		
		public function remove(handler:Function):void{
			delete handlerMaps[handler];
			if(!hasHandler()){
				stop();
			}
		}
		/**
		 * 判断是否还有可执行函数 
		 */		
		public function hasHandler():Boolean{
			for each(var desc:Object in handlerMaps){
				return true;
			}
			return false;
		}
		/**
		 * 启动管理Timer 
		 */		
		public function start():void{
			if(timer == null){
				timer = new Timer(100);
				timer.addEventListener(TimerEvent.TIMER,onTimerHandler);
			}
			if(hasHandler() && !timer.running){
				timer.start();
			}
		}
		/**
		 * 停止管理Timer 
		 * 
		 */		
		public function stop():void{
			if(timer){
				timer.stop();
				timer.reset();
			}
		}
		/**
		 * 每个时基执行函数 
		 * @param event
		 * 
		 */		
		private function onTimerHandler(event:TimerEvent):void{
			var t:int = getTimer();
			for(var h:Object in handlerMaps){
				var handler:Function = h as Function;
				var desc:Object = handlerMaps[handler];
				var ok:Boolean = (t - desc.t) >= desc.delay;
				if((desc.loop == 0 || desc.count < desc.loop) && ok){
					handler.apply(null,null);
					desc.count++;
					desc.t = t;
					if(desc.loop != 0 && desc.loop == desc.count){
						remove(handler);
					}
				}
			}
		
		}
	}
}