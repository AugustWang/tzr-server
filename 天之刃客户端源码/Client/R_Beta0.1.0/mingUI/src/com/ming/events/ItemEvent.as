package com.ming.events
{
	import flash.events.Event;
	/**
	 * 列表组件里面的渲染项所对应的事件类型 
	 * @author Administrator
	 * 
	 */	
	public class ItemEvent extends Event
	{
		public static const ITEM_CLICK:String = "itemClick";
		public static const ITEM_MOUSE_DOWN:String = "itemMouseDown";
		public static const ITEM_ROLL_OVER:String = "itemRollOver";
		public static const ITEM_ROLL_OUT:String = "itemRollOut";
		public static const ITEM_DOUBLE_CLICK:String = "itemDoubleClick";
		public static const ITEM_CHANGE:String = "itemChange";
		public var selectIndex:int;
		public var selectItem:Object;
		public function ItemEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		public override function clone() : Event{
			var evt:ItemEvent = new ItemEvent(type,bubbles,cancelable);
			evt.selectIndex = selectIndex;
			evt.selectItem = selectItem;
			return evt;
		}
	}
}