package com.scene.sceneManager {
	import com.globals.GameParameters;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import modules.system.SystemModule;

	/**
	 * 场景中的循环管理 ,有三种循环：桢频，60毫秒，1秒
	 * @author linxuyang
	 *
	 */
	public class LoopManager {
		private static var lastTime:int; //用于计算帧频
		private static var frameRates:Array=[]; //存放帧频
		private static var frameLoopDic:Dictionary; //放循环函数
		//////////////////////////////////
		private static var timer:Timer; //80毫秒
		private static var timeoutDic:Dictionary; //放setTimeout函数
		private static var timeLoopDic:Dictionary; //放定时器执行函数		
		private static var delayIDKey:int; //键值
		/////////////////////////////////
		private static var secondTimer:Timer; //1秒
		private static var SecondLoopDic:Dictionary; //放定时器执行函数	

		public function LoopManager() {

		}

		public static function init(stage:Stage):void {
			frameLoopDic=new Dictionary; //放循环函数
			timeoutDic=new Dictionary; //放setTimeout函数
			timeLoopDic=new Dictionary; //放定时器执行函数	Rmap
			SecondLoopDic=new Dictionary; //放秒循环函数
			stage.addEventListener(Event.ENTER_FRAME, frameLoop);
			timer=new Timer(80);
			timer.addEventListener(TimerEvent.TIMER, timerLoop);
			timer.start();
			secondTimer=new Timer(1000);
			secondTimer.addEventListener(TimerEvent.TIMER, secondLoop);
			secondTimer.start();
		}

		/**
		 * 帧频循环
		 * @param e
		 *
		 */
		private static function frameLoop(e:Event):void {
			for (var s:Object in frameLoopDic) {
				var f:Function = frameLoopDic[s];
				if (GameParameters.getInstance().isDebug()) {
					f.call();
				} else {
					try {
						f.call();
					} catch (e:Error) {
						SystemModule.getInstance().postError(e, "enter Frame:" + s.toString());
					}
				}
			}
			doFrameRate(); //计算帧频
		}

		/**
		 * 时间循环
		 * @param e
		 *
		 */
		private static function timerLoop(e:TimerEvent):void {
			for each (var obj:Object in timeoutDic) {
				if ((getTimer() - obj.startTime) >= obj.count) { //时间到了，执行
					obj.handler.apply(null, obj.arg);
					timeoutDic[obj.key]=null;
					delete timeoutDic[obj.key];
				}
			}
			
			for (var s:Object in timeLoopDic) {
				var f:Function = timeLoopDic[s];
				if (GameParameters.getInstance().isDebug()) {
					f.call();
				} else {
					try {
						f.call();
					} catch (e:Error) {
						SystemModule.getInstance().postError(e, "timer loop:" + s.toString());
					}
				}
			}
		}

		/**
		 * 秒循环
		 * @param e
		 *
		 */
		private static function secondLoop(e:TimerEvent):void {
			for (var s:Object in SecondLoopDic) {
				var f:Function = SecondLoopDic[s];
				if (GameParameters.getInstance().isDebug()) {
					f.call();
				} else {
					try {
						f.call();
					} catch (e:Error) {
						SystemModule.getInstance().postError(e, "second loop:" + s.toString());
					}
				}
			}
		}

		/**
		 * 加入到桢循环
		 * @param key
		 * @param fun
		 *
		 */
		public static function addToFrame(key:Object, fun:Function):void {
			if (frameLoopDic[key] == null) {
				frameLoopDic[key]=fun;
			}
		}

		/**
		 * 移除出桢循环
		 * @param key
		 *
		 */
		public static function removeFromFrame(key:Object):void {
			if (frameLoopDic[key]) {
				frameLoopDic[key]=null;
				delete frameLoopDic[key];
			}
		}

		public static function addToTimer(key:Object, fun:Function):void {
			if (timeLoopDic[key] == null) {
				timeLoopDic[key]=fun;
			}
		}

		public static function removeFromTimer(key:Object):void {
			if (timeLoopDic[key]) {
				timeLoopDic[key]=null;
				delete timeLoopDic[key];
			}
		}

		/**
		 * 加入到秒循环
		 * @param key
		 * @param fun
		 *
		 */
		public static function addToSecond(key:Object, fun:Function):void {
			if (SecondLoopDic[key] == null) {
				SecondLoopDic[key]=fun;
			}
		}

		/**
		 * 移除秒循环
		 * @param key
		 *
		 */
		public static function removeFromSceond(key:Object):void {
			if (SecondLoopDic[key]) {
				SecondLoopDic[key]=null;
				delete SecondLoopDic[key];
			}
		}

		/**
		 * 代替了setTimeOut
		 * @param delay
		 * @param fun
		 * @param args
		 * @return
		 *
		 */
		public static function setTimeout(fun:Function, delay:int, args:Array=null):int {
			delayIDKey++;
			var obj:Object={key: delayIDKey, startTime: getTimer(), count: delay, handler: fun, arg: args};
			if (timeoutDic[delayIDKey] == null) {
				timeoutDic[delayIDKey]=obj;
			}
			return delayIDKey;
		}

		/**
		 * 清除setTimeout
		 * @param id
		 *
		 */
		public static function clearTimeout(id:int):void {
			if (timeoutDic[id]) {
				timeoutDic[id]=null;
				delete timeoutDic[id];
			}
		}

		/**
		 * 获取最近的平均帧频
		 * @return
		 *
		 */
		public static function get realRate():Number { //记录了12个帧频，排除最快和最慢2个
			frameRates.sort();
			frameRates.pop();
			frameRates.shift();
			var total:Number=0;
			for (var i:int=0; i < frameRates.length; i++) {
				total+=frameRates[i];
			}
			return total / frameRates.length;
		}

		private static function doFrameRate():void {
			var t:int=getTimer();
			var frameRate:Number=1000 / (t - lastTime);
			lastTime=t;
			if (frameRate > 4) { //排除太低的帧频
				if (frameRates.length < 12) {
					frameRates.push(frameRate);
				} else {
					frameRates.shift();
					frameRates.push(frameRate);
				}
			}
		}
	}
}