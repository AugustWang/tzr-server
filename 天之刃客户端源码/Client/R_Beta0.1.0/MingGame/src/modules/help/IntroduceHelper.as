package modules.help
{
	import com.globals.GameConfig;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	public class IntroduceHelper extends EventDispatcher
	{
		private var loader:URLLoader;
		private var introducs:XML;
		public var isLoading:Boolean = false;
		public var init:Boolean = false;
		private static var instance:IntroduceHelper;
		public function IntroduceHelper()
		{
			
		}
		
		public static function getInstance():IntroduceHelper{
			if(instance == null){
				instance = new IntroduceHelper();
			}
			return instance;
		}
		
		public function load():void{
			if(introducs == null && isLoading == false){
				loader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.TEXT;
				loader.addEventListener(Event.COMPLETE,onComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
				var url:String = GameConfig.ROOT_URL+"com/data/introduce.xml";
				loader.load(new URLRequest(url));
				isLoading = true;
			}
		}
		
		private function onComplete(evt:Event):void{
			introducs = new XML(loader.data);
			loader.removeEventListener(Event.COMPLETE,onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
			isLoading = false;
			init = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onIOErrorHandler(evt:IOErrorEvent):void{
			isLoading = false;
			trace(evt.text);
		}
		
		public function getIntroduce(id:int):Object{
			if(introducs){
				var introduces:XMLList = introducs.introduce;
				for each(var introduce:XML in introduces){
					if(introduce.id == id){
						var obj:Object = {};
						obj.name = String(introduce.name);
						obj.desc = String(introduce.desc);
						return obj
					}
				}
				return null;
			}
			return null;
		}
	}
}