package com.scene.sceneUnit.baseUnit.things
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	/**
	 * 动画的心跳，统一管理avatar和thing的timer 
	 * @author yingbf
	 */	
	public class ThingFrame
	{
		private static var _instance:ThingFrame
		private static var funs:Dictionary = new Dictionary();
		
		public function ThingFrame(){
			var timer:Timer = new Timer(33);
			timer.addEventListener(TimerEvent.TIMER,loop);
			timer.start();
		}
		
		public function loop(event:TimerEvent):void{
			for each(var i:Function in funs){
				i.call();
			}
		}
		
		private function onTimer(event:Event):void{
			for each(var i:Function in funs){
				i.call();
			}
		}
		
//		public static function getInstance():ThingFrame
//		{
//			if(_instance == null)_instance = new ThingFrame();
//			return _instance;
//		}
		
		public  function add($id:String,$fun:Function):void{
			if(!funs.hasOwnProperty($id)){
				funs[$id] = $fun;
			}
		}
		
		public function remove($id:String):void{
			if(funs.hasOwnProperty($id)){
				funs[$id] = null;
				delete funs[$id];
			}
		}
	}
}