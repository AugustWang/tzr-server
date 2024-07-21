package com.loaders.queueloader
{
	import flash.events.Event;
	
	public class QueueEvent extends Event
	{
		public static const ITEM_PROGRESS:String = "itemProgress";
		public static const ITEM_COMPLETE:String = "itemComplete";
		public static const QUEUE_COMPLETE:String = "queueComplete";
		public static const ITEM_IO_ERROR:String = "itemIOError";
		
		public var loadItem:LoaderItem;
		public var data:*;
		public function QueueEvent(type:String)
		{
			super(type);
		}
	}
}