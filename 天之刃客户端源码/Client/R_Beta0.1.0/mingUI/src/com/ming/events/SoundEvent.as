package com.ming.events
{
	import flash.events.Event;
	
	public class SoundEvent extends Event
	{
		public static const START_PLAY:String = "start";
		public static const PLAY_COMPLETE:String = "playComplete";
		public function SoundEvent(type:String)
		{
			super(type);
		}
	}
}