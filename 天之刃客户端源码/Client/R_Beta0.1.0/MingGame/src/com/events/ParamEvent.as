package com.events
{
	import flash.events.Event;
	
	public class ParamEvent extends Event
	{
		public var data:Object;
		public function ParamEvent(type:String,data:Object=null,bubbles:Boolean = false)
		{
			super(type,bubbles);
			this.data = data;
		}
	}
}