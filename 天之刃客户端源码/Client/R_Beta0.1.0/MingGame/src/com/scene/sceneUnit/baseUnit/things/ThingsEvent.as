package com.scene.sceneUnit.baseUnit.things
{
	import flash.events.Event;

	public class ThingsEvent extends Event
	{
		public static const THING_LOAD_COMPLETE:String = "thingLoadComplete";
		public static const THING_REPLAY:String = "thingReplay";
		public static const THING_PLAY_END:String = "thingPlayEnd";
		public static const THING_ATTACK_END:String = "thingAttackEnd";
		public static const THING_HURT_END:String = "thingHurtEnd";
		public static const THING_STOP:String='THING_STOP'
		
		public var data:Object;
		
		public function ThingsEvent($type:String, $data:Object = null)
		{
			super($type);
			data = $data;
		}
	}
}