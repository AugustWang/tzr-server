package modules.mission.views {
	import com.common.GlobalObjectManager;
	import com.globals.GameParameters;
	import com.loaders.ResourcePool;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.playerGuide.PlayerGuideModule;
	import modules.playerGuide.WelcomeTipsView;

	public class MissionWelcome extends Sprite {
		private var bgBitmap:Bitmap;
		private var txt:TextField;
		private var startButton:Button;
		public var callBack:Function;
		private var container:Sprite;

		public function MissionWelcome() {
			super();
			container=new Sprite();
			container.x=(GlobalObjectManager.GAME_WIDTH - container.width) * 0.5;
			container.y=(GlobalObjectManager.GAME_HEIGHT - container.height) * 0.5;
			addChild(container);
			var tf:TextFormat=Style.textFormat;
			tf.size=14;
			tf.color=0xD0B58A;
			tf.leading=7;
			txt=ComponentUtil.createTextField("", 237, 156, tf, 350, 95, container);
			txt.wordWrap=true;
			txt.multiline=true;
			/*txt.htmlText = '欢迎来到<FONT COLOR="#00FF00">天之刃</FONT>的世界，五百年前的你是谁？无论是横扫千军，君临天下，还是 琴心剑胆，侠骨柔情。' +
				'你的<FONT COLOR="#8de8ed">第一步</FONT>需要先<FONT COLOR="#8de8ed">提升等级</FONT>,现在请先跟着指引升级！'*/
			txt.htmlText = '仙魔大战，使得天地失衡，人间混沌。你是否是拯救天下苍生的有缘人？赶快先提升你的<FONT COLOR="#8de8ed">等级</FONT>，开始愉快的旅途吧！';
				
			/*txt.htmlText='      亲爱的' + HtmlUtil.font("[" + GlobalObjectManager.getInstance().getRoleName() + "]", "#00ff00",
				14) + '，恭喜你穿越时空来到大天之刃！<FONT COLOR="#00FF00">[陈圆圆]</FONT>已在<FONT COLOR="#00FF00">“太平村”</FONT>恭候你多时，赶快去看看，开始你的传奇之旅吧！'*/

			with (graphics) {
				clear();
				beginFill(0, 0.5);
				drawRect(0, 0, GlobalObjectManager.GAME_WIDTH, GlobalObjectManager.GAME_HEIGHT);
				endFill();
			}
		}

		private static var instance:MissionWelcome;

		public static function getInstance():MissionWelcome {
			if (instance == null) {
				instance=new MissionWelcome();
			}
			return instance;
		}

		private var repeatCount:int=1;
		private var loader:Loader;
		public var loaded:Boolean=false;
		private var taskTipsView:WelcomeTipsView;

		public function loadWelcome():void {
			if (loaded == false) {
				var url:String=GameParameters.getInstance().resourceHost + 'com/assets/welcome.swf';
				if (ResourcePool.hasResource(url)) {
					//var data:
					var app:ApplicationDomain=ResourcePool.get(url);
					if (app) {
						showWelcome(app);
					} else {
						throw new Error("找不到资源:welcome.swf");
					}
				} else {
					loaded=true;
					loader=new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					loader.load(new URLRequest(url));
				}
			}
		}

		private function showWelcome(app:ApplicationDomain):void {
			if (app && app.hasDefinition("welcomeBg")) {
				var bitmapClazz:Class=app.getDefinition("welcomeBg") as Class;
				bgBitmap=new Bitmap();
				bgBitmap.bitmapData=BitmapData(new bitmapClazz(0, 0));
			} else {
				bgBitmap=new Bitmap();
			}
			container.addChild(bgBitmap);
			container.addChild(txt);
			startButton=ComponentUtil.createButton("开始旅程", 400, 228, 87, 30, container);
			addEventListener(MouseEvent.CLICK, onStartGame);
			container.x=(GlobalObjectManager.GAME_WIDTH - container.width) * 0.5;
			container.y=(GlobalObjectManager.GAME_HEIGHT - container.height) * 0.5;
			
			taskTipsView = new WelcomeTipsView();
			taskTipsView.x=575;
			taskTipsView.y=230;
			taskTipsView.show("", WelcomeTipsView.LEFT);
			container.addChild(taskTipsView);
			
			with (graphics) {
				clear();
				beginFill(0, 0);
				drawRect(0, 0, GlobalObjectManager.GAME_WIDTH, GlobalObjectManager.GAME_HEIGHT);
				endFill();
			}
			LayerManager.alertLayer.addChild(this);
		}

		private function onLoadComplete(event:Event=null):void {
			var app:ApplicationDomain=loader.contentLoaderInfo.applicationDomain;
			showWelcome(app);
		}

		private function onIOError(event:IOErrorEvent):void {
			loaded=false;
			repeatCount++;
			if (repeatCount <= 3) {
				loadWelcome();
			}
		}

		private function onStartGame(event:MouseEvent):void {
			if (this.parent) {
				if (callBack != null) {
					callBack.apply(null, null);
				}
				this.parent.removeChild(this);
				this.unload();
				PlayerGuideModule.getInstance().showFirstMissionFollowTip();
					
			}
		}

		public function unload():void {
			if (loader) {
				loader.unload();
			}
			var url:String=GameParameters.getInstance().resourceHost + 'com/assets/welcome.swf';
			if (ResourcePool.hasResource(url)) {
				ResourcePool.remove(url);
			}
			if (!bgBitmap) {
				return;
			}
			bgBitmap.bitmapData.dispose();
			callBack=null;
		}

		public function remove():void {
			if (parent) {
				LayerManager.uiLayer.removeChild(this);
				unload();
				instance=null;
			}
		}

		override public function get width():Number {
			return 1002;
		}

		override public function get height():Number {
			return GlobalObjectManager.GAME_HEIGHT;
		}
	}
}