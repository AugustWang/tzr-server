package modules.smallMap.view.items
{
	import com.common.GlobalObjectManager;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class HelpView extends Sprite
	{
		private var _url:String = "com/ui/other/helpWord.png";
		private var loader:Loader;
		private var conten:Bitmap;
		
		private static var instance:HelpView;
		public static function getInstance():HelpView
		{
			if(!instance)
			{
				instance = new HelpView();
			}
			return instance;
		}
		
		public function HelpView()
		{
			super();
			this.mouseEnabled = this.mouseChildren = false;
			
			var sprite:Sprite = new Sprite(); // 377  199
			sprite.graphics.beginFill(0x77787b,0.6);
			sprite.graphics.drawRect(0,0,377,199);
			sprite.graphics.endFill();
			sprite.x = 318;
			sprite.y = 155;
//			addChild(sprite);
			
			init();
		}
		private function init():void
		{
			conten = new Bitmap();
			addChild(conten);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onerro);
			loader.load(new URLRequest(GameConfig.ROOT_URL+_url),null);//
		}
		
		private function onLoaded(e:Event):void
		{
			conten.bitmapData = e.currentTarget.content.bitmapData;
			
		}
		
		private function onerro(e:IOErrorEvent):void
		{
			trace(":::IOErrorEvent::::");
		}
		
	}
}



