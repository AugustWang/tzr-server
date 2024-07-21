package com.ming.events
{
	import flash.events.Event;
	
	public class HelpEvent extends Event
	{
		/**
		 * 关闭
		 */
		public static const HELP:String = "help";
		
		public function HelpEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone() : Event
		{
			var evt:HelpEvent = new HelpEvent(type,bubbles,cancelable);
			return evt;
		}		
	}
}