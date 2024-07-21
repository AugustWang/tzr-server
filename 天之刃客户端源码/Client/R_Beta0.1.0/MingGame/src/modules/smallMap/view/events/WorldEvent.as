package modules.smallMap.view.events
{
	import flash.events.Event;
	
	public class WorldEvent extends Event
	{
		public static const COUNTRY_EVENT:String='COUNTRY_EVENT';
		
		public var country_id:String
		public function WorldEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}