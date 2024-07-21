package modules.login.views
{
	import com.globals.GameParameters;
	import com.managers.Dispatch;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import modules.ModuleCommand;
	
	public class LoginView extends Sprite
	{
		private var loader:Loader;
		private var login:MovieClip;
		public function LoginView()
		{
			super();
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			loader.load(new URLRequest("assets/Login.swf"));
		}
		
		
		private function onComplete(event:Event):void{
			login = MovieClip(loader.content);
			login.addEventListener(Event.COMPLETE,onStartGame);
			addChild(login);
			onIOError();
		}
		
		private function onIOError(event:IOErrorEvent=null):void{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onComplete);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
			loader.unload();
			loader = null;
		}
		
		private function onStartGame(event:Event):void{
			GameParameters.getInstance().gatewayArr = login.gatewayArr;
			GameParameters.getInstance().serviceHost = login.serviceHost;
			GameParameters.getInstance().account = login.account;
			GameParameters.getInstance().role_id = login.role_id;
			Dispatch.dispatch(ModuleCommand.LOGIN_COMPLETE);
		}
		
		public function dispose():void{
			login.removeEventListener(Event.COMPLETE,onStartGame);
			login = null;
			if(parent){
				parent.removeChild(this);
			}
		}
	}
}