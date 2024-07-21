package com.ming.events
{
	
	import flash.events.Event;
	
	/**
	 * 当组件大小改变时抛出的事件.
	 */	
	public class ResizeEvent extends Event
	{	
		/**
		 * 大小变化 
		 */
		public static const RESIZE:String = "m_resize";
		
		public function ResizeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone() : Event
		{
			var evt:ResizeEvent = new ResizeEvent(type,bubbles,cancelable);
			return evt;
		}
	}

}
