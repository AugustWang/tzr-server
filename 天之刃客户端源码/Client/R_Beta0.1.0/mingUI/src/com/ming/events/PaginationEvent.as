package com.ming.events
{
	import flash.events.Event;
	/**
	 * 页码事件 
	 * @author Administrator
	 * 
	 */	
	public class PaginationEvent extends Event
	{	
		public static const PAGINATION:String = "pagination";
		
		public var pageNum:uint;
		
		public function PaginationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone() : Event
		{
			var evt:PaginationEvent = new PaginationEvent(type,bubbles,cancelable);
			evt.pageNum = this.pageNum;
			return evt;
		}
	}
}