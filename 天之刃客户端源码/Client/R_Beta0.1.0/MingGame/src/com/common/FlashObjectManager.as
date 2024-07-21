package com.common {
	import com.scene.sceneUnit.baseUnit.SceneStyle;

	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class FlashObjectManager {
		private static var flashTimer:Timer;
		private static var flashArray:Array=[];

		public function FlashObjectManager() {
		}

		public static function setFlash(target:DisplayObject):void {
			if (flashTimer == null) {
				flashTimer=new Timer(500)
				flashTimer.addEventListener(TimerEvent.TIMER, onFalshTimer)
				flashTimer.start()
			}
			var index:int=flashArray.indexOf(target);
			if (index == -1) {
				flashArray.push(target);
			}
		}

		public static function colseFlash(target:DisplayObject):void {
			target.filters=[];
			var index:int=flashArray.indexOf(target);
			if (index != -1) {
				flashArray.splice(index, 1);
			}
		}

		private static function onFalshTimer(e:TimerEvent):void {
			for (var i:int=0; i < flashArray.length; i++) {
				var tar:DisplayObject=flashArray[i];
				if(tar == null)continue;
				if (tar.filters.length == 0) {
					tar.filters=SceneStyle.bodyFilter;
				} else {
					tar.filters=[];
				}
			}
		}

		public static function clearAll():void {
			for (var i:int=0; i < flashArray.length; i++) {
				var tar:DisplayObject=flashArray[i];
				tar.filters=[];
			}
			flashArray=[];
		}
	}
}