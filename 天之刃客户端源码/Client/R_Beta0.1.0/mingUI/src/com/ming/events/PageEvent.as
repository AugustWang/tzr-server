package com.ming.events
{
	import flash.events.Event;
	/**
	 * 页码事件 
	 * @author Administrator
	 * 
	 */	
	public class PageEvent extends Event
	{	
		public static const CHANGED:String = "changed";
		
		public var pageNumber:uint;
		
		public function PageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone() : Event
		{
			var evt:PageEvent = new PageEvent(type,bubbles,cancelable);
			evt.pageNumber = this.pageNumber;
			return evt;
		}
	}
}