package com.components.chat.events
{
	import flash.events.Event;
	/**
	 * 聊天事件
	 */ 
	public class ChatEvent extends Event
	{
		public static const SELECTED_COLOR:String = "selectedColor"; //选择颜色时发生
		public static const SELECTED_FACE:String = "selectedFace"; //选择表情时发生
		public var data:Object; 
		public function ChatEvent(type:String,data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
}