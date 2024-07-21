package com.loaders
{
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class DelayLoader extends Loader
	{
		public var delay:int = 0;
		public var url:String;
		private var timeOut:int;
		public function DelayLoader()
		{
			super();
		}
		
		public function start():void{
			timeOut = setTimeout(load,delay,new URLRequest(url));
		}
		
		override public function unload():void{
			clearTimeout(timeOut);
			super.unload();
		}
		
		public function stop():void{
			clearTimeout(timeOut);
			try{
				unload();
				close();
			}catch(e:*){
				
			}
		}
	}
}