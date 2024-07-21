package modules.family
{
	import flash.events.Event;
	
	public class FamilyItemEvent extends Event
	{
		public static const SHOW_TOOLTIP:String = "showToolTip";
		public static const REMOVE_ITEM:String = "removeItem";
		public var data:Object;
		public function FamilyItemEvent(data:Object,type:String=SHOW_TOOLTIP)
		{
			this.data = data;
			super(type, true);
		}
		
		override public function clone():Event{
			var evt:FamilyItemEvent = new FamilyItemEvent(data,type);
			return evt;
		}
	}
}