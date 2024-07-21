package com.ming.events
{
	import flash.events.Event;
	
	public class ComponentEvent extends Event
	{
		public static const ENTER:String = "enter";
		public function ComponentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}