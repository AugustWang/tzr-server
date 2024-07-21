package modules.flowers.views
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import modules.flowers.FlowerModule;
	
	public class HuaQuan extends Sprite
	{
		public static var huaQuan_url:String = "com/assets/flowers/999flowers.swf";//"999flowers.swf";
		private var movieclip:MovieClip;
		private var timer:Timer;
		private var tween:Timer;
		
		private var sourceloader:SourceLoader;
		private var clazz:Class;
		
		private var loader:Loader;
		
		public function HuaQuan()
		{
			super();
			this.mouseChildren = this.mouseEnabled = false;
		}
		
		private var hua:MovieClip;
		private function onCompleteHandler(evt:Event):void{
			hua = loader.contentLoaderInfo.content as MovieClip;
			hua.width =GlobalObjectManager.GAME_WIDTH+100;
			hua.height = GlobalObjectManager.GAME_HEIGHT+100;
			addChild(hua);
			loaderInfo.removeEventListener(Event.COMPLETE,onCompleteHandler);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onIoErrorHandler);
			if(!timer)
			{
				timer = new Timer(10000,1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
			}
			timer.start();
		}
		
		private function onEnterframe(e:Event):void
		{
			if(movieclip.currentFrame == movieclip.totalFrames)
			{
				movieclip.removeEventListener(Event.ENTER_FRAME, onEnterframe);
				if(movieclip&&movieclip.parent)
				{
					removeChild(movieclip);
					movieclip = null;
				}
			}
		}
		
		private function onIoErrorHandler(evt:IOErrorEvent):void{
			trace("开花特效加载出错！");
		}
		
		public function initView():void
		{
			if(!loader)
			{
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleteHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onIoErrorHandler);
				loader.load(new URLRequest(GameConfig.ROOT_URL + huaQuan_url));//GameConfig.ROOT_URL +
			}
		}
		
		private function  onTimerComplete(e:TimerEvent):void
		{
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
			timer.stop();
			timer = null;
			
			if(loader)
			{
				loader.unload();
				this.removeChild(hua);
				loader = null;
			}
			
			FlowerModule.getInstance().isQuanOver = true;
			FlowerModule.getInstance().isAccepToc = true;
			dispose();
			FlowerModule.getInstance().showRecieveView();
		}
		
		private var last:int;
		
		
		public function dispose():void
		{
			if(timer)
			{
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
				timer.stop();
				timer = null;
			}
			if(movieclip)
			{
				if(movieclip.parent)
				{
					movieclip.parent.removeChild(movieclip);
				}
				
				movieclip = null;
			}
			if(this.parent)
			{
				this.parent.removeChild(this);
			}
		}
	}
}

