package modules.broadcast.effect
{
	import com.globals.GameConfig;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	public class LabaEffect extends Sprite
	{
		
		public static var URL:String ="com/ui/flash/laba/laba.swf"; //"assets/laba.swf";
		public static var dataLoadingClazz:Class;
		private var _url:String;
		public function LabaEffect()
		{
			super();
			_url = GameConfig.ROOT_URL + URL;
			loadData();
		}
		
		public function playSwf(times:int=1):void
		{
			if(!labaMc) {
				return;
			}
			labaMc.gotoAndPlay(1);
			if(times>1) {
				labaMc.addEventListener(Event.ENTER_FRAME,toRePlay);
			}
		}
		
		private function toRePlay(e:Event):void
		{
			if(labaMc.currentFrame == labaMc.totalFrames)
			{
				setTimeout(playSwf,600);
				labaMc.removeEventListener(Event.ENTER_FRAME,toRePlay);
			}
		}
		
		private var labaMc:MovieClip;
		private function addLabaSwf():void{
			if(dataLoadingClazz){
				labaMc = new dataLoadingClazz();
				if(labaMc)
				{
					addChild(labaMc);
					labaMc.gotoAndStop(1);
					playSwf(2);
				}
			}
		}
		
		private function loadData():void{
			if(dataLoadingClazz){
				addLabaSwf();
			}else{
				var loader:Loader = new Loader;
				loader.load(new URLRequest(_url));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedFunc);
			}
		}
		
		private var loaded:Boolean;
		private function loadedFunc(event:Event):void
		{
			loaded = true;
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			if(loaderInfo && loaderInfo.applicationDomain && loaderInfo.applicationDomain.hasDefinition("Laba")){
				dataLoadingClazz = loaderInfo.applicationDomain.getDefinition("Laba") as Class;
			}
			addLabaSwf();
		}
	}
}