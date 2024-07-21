package com.ming.events
{
	import flash.events.Event;
	/**
	 * 关闭窗口事件 ,当关闭窗口的时候触发该事件 
	 * @author Administrator
	 * 
	 */
	public class CloseEvent extends Event
	{
		/**
		 * 关闭
		 */
		public static const CLOSE:String = "close";
		
		public function CloseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone() : Event
		{
			var evt:CloseEvent = new CloseEvent(type,bubbles,cancelable);
			return evt;
		}		
	}
}