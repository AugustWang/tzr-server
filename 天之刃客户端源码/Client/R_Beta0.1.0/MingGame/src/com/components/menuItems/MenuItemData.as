package com.components.menuItems
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	use namespace flash.utils.flash_proxy;

	dynamic public class MenuItemData extends Proxy implements IEventDispatcher
	{
		private var obj:Object;
		private var eventDispatcher:EventDispatcher;
		public function MenuItemData()
		{
			obj = new Object();
			eventDispatcher = new EventDispatcher();
		}
		
		override flash_proxy function getProperty(name:*):* {
			var propertyName:String = name.localName;
			return obj[propertyName];
		}
		
		override flash_proxy function hasProperty(name:*):Boolean {
			return obj.hasOwnProperty(name);
		}
		
		override flash_proxy function setProperty(name:*, value:*):void {
			var propertyName:String = name.localName;
			if(obj.hasOwnProperty(propertyName) && !(value is Function)){
				var oldValue:* = obj[propertyName];
				if(oldValue != value){
					var evt:MenuItemEvent = new MenuItemEvent(MenuItemEvent.VALUE_CHANGED);
					evt.propertyName = propertyName;
					evt.value = value;
					dispatchEvent(evt);
				}
			}
			obj[propertyName] = value;
		}
		
		override flash_proxy function callProperty(methodName:*, ... args):* {
			var handler:Function = obj[methodName.toString()];
			var res:*;
			if(handler != null){
				handler.apply(null, args);
			}
			return res;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			eventDispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
		}
		 
		public function dispatchEvent(event:Event):Boolean{
			return eventDispatcher.dispatchEvent(event);
		}
		 
		public function hasEventListener(type:String):Boolean{
			return eventDispatcher.hasEventListener(type);
		}
		 
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			eventDispatcher.removeEventListener(type,listener,useCapture);
		}
		 
		public function willTrigger(type:String):Boolean{
			return eventDispatcher.willTrigger(type);
		}
		

	}
}