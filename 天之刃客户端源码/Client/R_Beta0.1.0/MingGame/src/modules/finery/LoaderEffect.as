package modules.finery
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class LoaderEffect extends Sprite
	{
		public static var movieclip:MovieClip;
		private static var _instance:LoaderEffect;
		public static function getInstance():LoaderEffect{
			if(!_instance){
				_instance = new LoaderEffect();
			}
			return _instance;
		}
		
		public function loader($url:String):void{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleteHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onIoErrorHandler);
			loader.load(new URLRequest($url));
		}
		
		private function onCompleteHandler(evt:Event):void{
			var loaderInfo:LoaderInfo = evt.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onCompleteHandler);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onIoErrorHandler);
			
			var clazz:Class = loaderInfo.applicationDomain.getDefinition("effect") as Class;
			
			movieclip = new clazz() as MovieClip;
		}
		private function onIoErrorHandler(evt:IOErrorEvent):void{
			trace("天工炉特效加载出错！");
		}
	}
}