package com.events
{
	import flash.events.Event;
	
	public class WindowEvent extends Event
	{
		public static const OPEN:String = "open";
		public static const CLOSEED:String = "closeed";
		public function WindowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}