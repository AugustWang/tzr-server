package com.components.cooling
{
	import com.ming.errors.IllegalArgumentError;
	import com.ming.ui.controls.Cooling;
	import com.ming.ui.controls.ImageCooling;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;

	public class CoolingManager extends EventDispatcher
	{
		public static var COOLING_ID:int = 99999;
		private var observers:Dictionary;
		public function CoolingManager()
		{
			observers = new Dictionary();
			times = new Dictionary();
		}
		
		private static var instance:CoolingManager;
		public static function getInstance():CoolingManager{
			if(instance == null){
				instance = new CoolingManager();
			}
			return instance;
		}
		
		public function registerObserver(observer:ICooling):void{
			var coolingObserver:CoolingObserver = new CoolingObserver(observer);
			observers[COOLING_ID] = coolingObserver;
			observer.coolingID = COOLING_ID;
			COOLING_ID--;
		}
		
		public function removeObserver(observer:ICooling):void{
			var coolingObserver:CoolingObserver = observers[observer.coolingID] as CoolingObserver;
			if(coolingObserver){
				coolingObserver.dispose();
				delete observers[observer.coolingID];
			}
		}
		private var times:Dictionary;
		public function startCooling(name:String,time:int,hasGoTime:int=0):void{
			var start:int = getTimer();
			times[name] = {startTime:start,endTime:start+(time-hasGoTime),totalTime:time,hasGoTime:hasGoTime};
			var startAngle:int = hasGoTime/time*360;
			for each(var observer:CoolingObserver in observers){
				if(observer.getName() == name){
					observer.startCooling(time,startAngle);
				}
			}
		}
		
		public function currentCoolingTime(name:String):int{
			var timeObject:Object = times[name];
			if(timeObject){
				var endTime:int = timeObject.endTime;
				var current:int = getTimer();
				if(current >= endTime)
					return 0;
				return endTime - current;
			}
			return 0
		}
		
		public function isCoolingByName(name:String):Boolean{
			var timeObject:Object = times[name];
			if(timeObject){
				var endTime:int = timeObject.endTime;
				var current:int = getTimer();
				if(current >= endTime)
					return false;
				return true;
			}
			return false;
		}
		
		public function updateCooling(observer:ICooling):void{
			var timeObject:Object = times[observer.getName()];
			if(timeObject){
				var startTime:int = timeObject.startTime;
				var endTime:int = timeObject.endTime;
				var current:int = getTimer();
				var totalTime:int = timeObject.totalTime;
				var hasGoTime:int = timeObject.hasGoTime;
				var coolingObserver:CoolingObserver = observers[observer.coolingID] as CoolingObserver;
				if(current < endTime && current >= startTime){
					var startAngle:int = ((current - startTime) + hasGoTime)/totalTime*360;
					coolingObserver.startCooling(endTime-current,startAngle);
				}
			}
		}
		
		public function stopCooling(name:String):void{
			for each(var observer:CoolingObserver in observers){
				if(observer.getName() == name){
					observer.stopCooling();
				}
			}
			delete times[name];
		}
		
		public function stopByCoolingID(coolingID:int):void{
			var coolingObserver:CoolingObserver = observers[coolingID] as CoolingObserver;
			if(coolingObserver){
				coolingObserver.stopCooling();
			}
		}		
		
		public function isCooling(observer:ICooling):Boolean{
			var coolingObserver:CoolingObserver = observers[observer.coolingID] as CoolingObserver;
			return coolingObserver.isCooling();
		}
		
		public function createCooling(c:DisplayObjectContainer):ImageCooling{
			var cooling:ImageCooling = new ImageCooling();
//			cooling.color = 0x000000;
//			cooling.alpha = 0.5;
			cooling.setTarget(c);
			return cooling; 
		}
		
		/**
		 * 交换两个冷却条的旋转角度和时间 
		 * @param source
		 * @param target
		 * 
		 */		
		public function exChangeCooling(source:ICooling,target:ICooling):void{
			var sourceObserver:CoolingObserver = observers[source.coolingID] as CoolingObserver;
			var targetObserver:CoolingObserver = observers[target.coolingID] as CoolingObserver;
			if(sourceObserver == null || targetObserver == null){
				throw new IllegalArgumentError("source和target可能没有注册到冷却管理器中");
			}
			var sourceCooling:ImageCooling = sourceObserver.cooling;
			var targetCooling:ImageCooling = targetObserver.cooling;
			if(sourceCooling == null && targetCooling == null)return;
			if(sourceCooling == null && targetCooling){
				if(targetCooling.running){
					sourceObserver.startCooling(targetCooling.getRestTime(),targetCooling.getStandardAngle());
					targetObserver.stopCooling();
				}
			}else if(sourceCooling && targetCooling == null){
				if(sourceCooling.running){
					targetObserver.startCooling(sourceCooling.getRestTime(),sourceCooling.getStandardAngle());
					sourceObserver.stopCooling();
				}
			}else{
				var running:Boolean = sourceCooling.running;
				var restTime:Number = sourceCooling.getRestTime();
				var angle:Number = sourceCooling.getStandardAngle();
				if(targetCooling.running){
					sourceObserver.startCooling(targetCooling.getRestTime(),targetCooling.getStandardAngle());
				}
				if(running){
					targetObserver.startCooling(restTime,angle);
				}
			}
		}
	}
}