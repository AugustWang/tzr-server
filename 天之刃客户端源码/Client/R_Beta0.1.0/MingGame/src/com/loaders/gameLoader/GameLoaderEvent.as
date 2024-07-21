package com.loaders.gameLoader
{
	import flash.events.Event;
	
	public class GameLoaderEvent extends Event
	{
		public static const COMPLETE:String = "GAME_LOAD_COMPLETE";
		public var url:String;
		public var data:Object;
		public function GameLoaderEvent(type:String,url:String,data:Object)
		{
			super(type);
			this.url = url;
			this.data = data;
		}
	}
}