package {
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.globals.GameParameters;

	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
    //天之刃
	//[SWF(backgroundColor="0x0", frameRate="30")]
	[SWF(backgroundColor="0x0", frameRate="24")]
	public class Main extends Sprite {
		public static const CREATE_ROLE_FINISH:String="createRoleFinish";
		public static const READY_FOR_CONNECT:String="readyForConnect";

		private var createRole:MovieClip;
		public var createFinish:Boolean=false;
		private var createRoleURL:String;

		private var loader:Loader;
		private var url:String;
		private var game:Sprite;

		public function Main() {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 * 初始化游戏参数和预加载界面
		 */
		private function init(e:Event):void {
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, resizeHandler);
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			removeEventListener(Event.ADDED_TO_STAGE, init);
			GameParameters.getInstance().initParameters(loaderInfo.parameters);
			if (GameParameters.getInstance().localDebug == "true") {
				this.createRoleURL=GameConfig.CREATE_ROLE_URL;
			} else {
				this.createRoleURL=GameParameters.getInstance().resourceHost + GameConfig.CREATE_ROLE_URL
			}
			var params:String="";
			for (var index:String in loaderInfo.parameters) {
				params+=index + "=" + loaderInfo.parameters[index] + "&";
			}
			this.createRoleURL+="?" + params;
			this.addEventListener(CREATE_ROLE_FINISH, onCreateRoleFinish);
			addChildAt(GameLoading.getInstance(), 0);
		}

		private function resizeHandler(e:Event):void {
			if (createRole) {
				createRole.x=(this.stage.stageWidth - 1002)*0.5;
			}
		}

		public function loadCreateAndGame():void {
			GameLoading.getInstance().setTotalPercent(1, 100);
			if (GameParameters.getInstance().localDebug == "true") {
				loadGame();
				GameLoading.getInstance().loadWelcomeBG();
			} else {
				// 正常模式下会根据
				if (int(GameParameters.getInstance().role_id) < 1) {
					loadCreateRole();
				} else {
					loadGame();
					GameLoading.getInstance().loadWelcomeBG();
				}
			}
		}

		private function loadCreateRole():void {
			GameLoading.getInstance().setTotalPercent(2, 100);
			var loader:Loader=new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCreateRoleLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onCreateRoleLoadIOError);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onCreateRoleLoadProgress);
			loader.load(new URLRequest(createRoleURL));
		}

		private function onCreateRoleLoadComplete(e:Event):void {
			var loader:Loader=(e.target.loader as Loader);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCreateRoleLoadComplete);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onCreateRoleLoadIOError);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onCreateRoleLoadProgress);
			createRole=MovieClip((e.target.loader as Loader).content);
			createRole.addEventListener(CREATE_ROLE_FINISH, onCreateRoleFinish);
			GameLoading.getInstance().setTotalPercent(3, 100);
			for (var i:int=0; i < this.numChildren; i++) {
				this.getChildAt(i).visible=false;
			}
			addChild(createRole);
			if (createRole.stage) {
				createRole.stage.scaleMode=StageScaleMode.NO_SCALE;
				createRole.stage.align=StageAlign.TOP_LEFT;
			}
			createRole.x=(this.stage.stageWidth - 1002)*0.5;
			loadGame();
			GameLoading.getInstance().loadWelcomeBG();
		}

		private function onCreateRoleLoadIOError(event:Event):void {
			loadCreateRole();
		}

		private function onCreateRoleLoadProgress(event:ProgressEvent):void {
			GameLoading.getInstance().setItemPercent("加载创建角色页面", event.bytesLoaded, event.bytesTotal);
		}

		/**
		 * 开始加载游戏
		 */
		private function loadGame():void {
			GameLoading.getInstance().setTotalPercent(1, 20);
			url=GameConfig.GAME_URL;
			var loader:Loader=new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.load(new URLRequest(url));
		}

		/**
		 * 加载完成
		 */
		private function onComplete(event:Event):void {
			addChildAt((event.target.loader as Loader).content, 0);
		}

		/**
		 * 创角成功
		 */
		private function onCreateRoleFinish(event:Event):void {
			createRole.removeEventListener(CREATE_ROLE_FINISH, onCreateRoleFinish);
			createRole.stop();
			removeChild(createRole);
			createRole=null;
			for (var i:int=0; i < this.numChildren; i++) {
				this.getChildAt(i).visible=true;
			}
			var urlLoader:URLLoader=new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, getAllInfoFinish);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, getAllInfoError);
			urlLoader.load(new URLRequest(GameParameters.getInstance().serviceHost + "reconnect.php?action=get_all"));
		}


		private function getAllInfoError(e:Event):void {
			var loader:URLLoader=e.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, getAllInfoFinish);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, getAllInfoError);
			var urlLoader:URLLoader=new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, getAllInfoFinish);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, getAllInfoError);
			urlLoader.load(new URLRequest(GameParameters.getInstance().serviceHost + "reconnect.php?action=get_all"));
		}

		/**
		 * 创建角色成功后向服务器请求信息
		 * @param e
		 *
		 */
		private function getAllInfoFinish(e:Event):void {
			var loader:URLLoader=e.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, getAllInfoFinish);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, getAllInfoError);

			var result:String=e.target.data;
			var info:Array=result.split('|');
			GameParameters.getInstance().role_id=info[0];
			GameParameters.getInstance().map_id=info[1];
			GameParameters.getInstance().level=info[2];
			GameParameters.getInstance().gatewayArr=new Array({'host': info[3], 'port': info[4], 'key': info[5]});
			stage.dispatchEvent(new Event(READY_FOR_CONNECT));
			this.createFinish=true;
		}

		private function onIOError(event:IOErrorEvent):void {
			flash.net.navigateToURL(new URLRequest(GameParameters.getInstance().serviceHost + "game.php"), "_self");
		}

		private function onProgress(event:ProgressEvent):void {
			GameLoading.getInstance().setItemPercent("加载游戏主文件", event.bytesLoaded, event.bytesTotal);
		}
	}
}