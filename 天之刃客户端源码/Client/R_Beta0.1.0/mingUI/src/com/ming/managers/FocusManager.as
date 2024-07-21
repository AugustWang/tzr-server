package com.ming.managers
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;

	public class FocusManager
	{
		public function FocusManager()
		{
		}
		
		private static var instance:FocusManager;
		public static function getInstance():FocusManager{
			if(instance == null){
				instance = new FocusManager();
			}
			return instance;
		}
		
		
		private var _stage:Stage;
		public function set stage(value:Stage):void{
			_stage = value;
			_stage.addEventListener(FocusEvent.FOCUS_OUT,focusOutHandler);
			focusStage();
		}
		
		public function get stage():Stage{
			return _stage;	
		}
		
		public function focusStage():void{
			if(_stage){
				_stage.focus = _stage;
			}	
		}
		
		private function focusOutHandler(event:FocusEvent):void{
			setFocus(event.relatedObject);
		}
		
		private var focusObj:InteractiveObject;
		private function setFocus(obj:InteractiveObject):void{
			if(focusObj){
				removeEventListener();
			}
			focusObj = obj;
			addEventListener();
		}
		
		public function getFocus():InteractiveObject{
			return focusObj;
		}
		
		private function addEventListener():void{
			if(focusObj){
				focusObj.addEventListener(Event.REMOVED_FROM_STAGE,removeHandler);
			}
		}
		
		private function removeEventListener():void{
			if(focusObj){
				focusObj.removeEventListener(Event.REMOVED_FROM_STAGE,removeHandler);
			}
		}
		
		private function clearFocus():void{
			removeEventListener();
			focusObj = null;
		}
		
		private function removeHandler(event:Event):void{
			clearFocus();
			stage.focus = stage;
		}
	}
}