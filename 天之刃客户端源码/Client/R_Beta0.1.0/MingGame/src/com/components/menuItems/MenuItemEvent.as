package com.components.menuItems
{
	import flash.events.Event;
	
	public class MenuItemEvent extends Event
	{
		public static var VALUE_CHANGED:String = "valueChanged";
		public var propertyName:String;
		public var value:*;
		public function MenuItemEvent(type:String)
		{
			super(type);
		}
	}
}