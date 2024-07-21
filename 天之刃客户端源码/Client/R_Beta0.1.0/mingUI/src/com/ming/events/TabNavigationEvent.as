package com.ming.events
{
	import flash.events.Event;
	
	public class TabNavigationEvent extends Event
	{
		public static const SELECT_TAB_CHANGED:String = "selectTabChanged";
		
		public var index:int;
		
		public function TabNavigationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone() : Event
		{
			var evt:TabNavigationEvent = new TabNavigationEvent(type,bubbles,cancelable);
			evt.index = index;
			return evt;
		}		
	}
}