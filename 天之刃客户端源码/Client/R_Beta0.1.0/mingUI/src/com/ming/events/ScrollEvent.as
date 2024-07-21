package com.ming.events
{
	import flash.events.Event;
	
	public class ScrollEvent extends Event
	{
		public static const SCROLL:String = "scroll";
		public var position:Number;
		public var delta:Number;
		public function ScrollEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}