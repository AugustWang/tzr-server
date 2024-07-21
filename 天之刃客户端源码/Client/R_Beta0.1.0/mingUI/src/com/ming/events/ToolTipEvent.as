package com.ming.events
{
	import flash.events.Event;
	/**
	 * 提示事件 
	 * @author Administrator
	 * 
	 */	
	public class ToolTipEvent extends Event
	{
		private var _tipType:String = "";
		private var data:Object;
		public static const TIP_SHOW:String = "toolTipShow";
		public static const TIP_HIDE:String = "toolTipHide";
		
		public function ToolTipEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type,bubbles,cancelable);
		}
		
	}
}