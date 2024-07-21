package com.components.cooling
{
	
	import com.ming.ui.controls.ImageCooling;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;

	public class CoolingObserver
	{
		public var target:ICooling;
		public var cooling:ImageCooling;
		
		public function CoolingObserver(target:ICooling)
		{
			this.target = target;
		}
		
		public function getName():String{
			return target.getName();
		}
		
		public function startCooling(time:int,startAngle:int=0):void{
			if(cooling == null){
				cooling = CoolingManager.getInstance().createCooling(target as DisplayObjectContainer);
				cooling.addEventListener(Event.COMPLETE,onCompleteHandler);
			}else{
				cooling.setTarget(target as DisplayObjectContainer);
			}
			cooling.stop();
			cooling.start(time,startAngle);
		}
		
		public function isCooling():Boolean{
			return cooling ? cooling.running : false;
		}
		
		public function stopCooling():void{
			if(cooling){
				cooling.stop();
				onCompleteHandler(null);
			}
		}
		
		private function onCompleteHandler(event:Event):void{
			if(cooling.parent){
				cooling.parent.removeChild(cooling);
			}
		}
		
		public function dispose():void{
			if(cooling){
				if(cooling.parent){
					cooling.parent.removeChild(cooling);
				}
				cooling.removeEventListener(Event.COMPLETE,onCompleteHandler);
			}
			cooling = null;
			target = null;
		}
	}
}