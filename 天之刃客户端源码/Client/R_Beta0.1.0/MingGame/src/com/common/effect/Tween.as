package com.common.effect
{
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class Tween
	{
		public static const ON_UPDATE:String = "onUpdate";
		public static const ON_UPDATE_PARAMS:String = "onUpdateParams";
		public static const ON_COMPLETE:String = "onComplete";
		public static const ON_COMPLETE_PARAMS:String = "onCompleteParams";
		public static const EASE:String = "ease";
		
		private static var mcMap:Dictionary = new Dictionary(true);
		private static var timer:Timer;
		private static var inited:Boolean = init();
		private static function init():Boolean
		{
			timer = new Timer(30);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
			return true;
		}
		
		private static function onTimer(event:TimerEvent):void{
			var t:int = getTimer();
			for each(var mcDesc:Object in mcMap){
				var useup:Number = t - mcDesc.t;
				useup = Math.min(useup,mcDesc.duration*30);
				var ease:Function = mcDesc.vars.ease == null ? easeInOut : null;
				for(var pro:String in mcDesc.pros){
					mcDesc.mc[pro] = ease(useup,mcDesc.pros[pro].b,mcDesc.pros[pro].c,mcDesc.duration*30)
				}
				var params:* = mcDesc.vars[ON_UPDATE_PARAMS];
				if(mcDesc.vars.hasOwnProperty(ON_UPDATE) ){
					mcDesc.vars[ON_UPDATE].apply(null,params);
				}
				if(useup == mcDesc.duration*30){
					delete mcMap[mcDesc.mc];
					params = mcDesc.vars[ON_COMPLETE_PARAMS];
					if(mcDesc.vars.hasOwnProperty(ON_COMPLETE)){
						mcDesc.vars[ON_COMPLETE].apply(null,params);
					}
				}
			}
			var flag:Boolean = false;;
			for each(var m:Object in mcMap){
				flag = true;
			}
			if(flag == false){
				timer.stop();
			}
		}
		
		private static function onTimerComplete(event:TimerEvent):void{
			
		}
		
		public static function to(mc:*,duration:int,vars:*):void{
			var pros:Object = new Object();
			var t:int = getTimer();
			mcMap[mc] = {mc:mc,duration:duration,vars:vars,pros:pros,count:0,t:t};
			for(var pro:String in vars){
				if(pro == ON_UPDATE || pro == ON_UPDATE_PARAMS || pro == ON_COMPLETE || pro == ON_COMPLETE_PARAMS || pro == EASE){
					continue;
				}
				if(mc.hasOwnProperty(pro)){
					pros[pro] = {b:mc[pro],c:vars[pro] - mc[pro]};
				}	
			}
			if(!timer.running){
				timer.start();
			}
		}
		
		public static function easeInOut(t:Number, b:Number,
										 c:Number, d:Number):Number
		{
			return c * t / d + b;
		}
	}
}