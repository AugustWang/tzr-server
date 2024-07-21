package {
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.loaders.CommonLocator;
	import com.loaders.ResourcePool;
	import com.loaders.queueloader.LoaderItem;
	import com.loaders.queueloader.QueueEvent;
	import com.loaders.queueloader.QueueLoader;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.managers.ReSizeManager;
	import com.net.connection.ServerMapConfig;
	import com.scene.WorldManager;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.utils.Pos;
	
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Timer;
	
	import modules.ModuleCommand;
	import modules.ModuleFactory;
	import modules.buff.BuffModule;
	import modules.login.LoginModule;
	import modules.mission.MissionDataManager;
	import modules.npc.NPCDataManager;
	import modules.pet.config.PetConfig;
	import modules.skill.SkillDataManager;

	[SWF(backgroundColor="0x0", frameRate="30")]
	public class MingGame extends Sprite {
		private var queueLoader:QueueLoader;
		private var timer:Timer;
		private var connected:Boolean = false;
		private var loaded:Boolean = false;
		public function MingGame() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			ReSizeManager.init(this);
			LoopManager.init(this.stage);
			Security.loadPolicyFile("xmlsocket://" + GameParameters.getInstance().getGatewayHost() + ":5000");
			ModuleFactory.createLoginModule();
			LayerManager.init(this);
			if (GameParameters.getInstance().localDebug == "true") {
				Dispatch.register(ModuleCommand.LOGIN_COMPLETE, loadAndConnect);
				LoginModule.getInstance().onDebugLogin();
			} else {
				if (int(GameParameters.getInstance().role_id) > 0) {
					loadAndConnect();
				} else {
					if ((this.parent as Main).createFinish) {
						loadAndConnect();
					} else {
						this.stage.addEventListener(Main.READY_FOR_CONNECT, loadAndConnect);
					}
				}
			}
		}

		/**
		 * 加载主配置
		 */
		private function loadConfig():void {
			var urlLoader:URLLoader=new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, loadConfigComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadConfigIOError);
			urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			urlLoader.load(new URLRequest(GameConfig.CONFIG_URL));
			GameLoading.getInstance().setItemPercent("主配置", 0, 10);
		}

		/**
		 * 加载主配置完成
		 */
		private function loadConfigComplete(event:Event):void {
			var urlLoader:URLLoader=event.currentTarget as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, loadConfigComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadConfigIOError);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			analyseConfig(XML(urlLoader.data));
			urlLoader=null;
		}

		/**
		 * 加载主配置进度条处理
		 */
		private function onProgress(event:ProgressEvent):void {
			GameLoading.getInstance().setItemPercent("加载主配置", event.bytesLoaded, event.bytesTotal);
		}

		/**
		 * 加载主配置错误处理
		 */
		private function onLoadConfigIOError(event:IOErrorEvent):void {
			//直接刷新游戏
			flash.net.navigateToURL(new URLRequest(GameParameters.getInstance().serviceHost + "game.php"), "_self");
		}

		/**
		 * 解析主配置
		 */
		private function analyseConfig(config:XML):void {
			queueLoader=new QueueLoader();
			queueLoader.addEventListener(QueueEvent.ITEM_PROGRESS, onItemProgress);
			queueLoader.addEventListener(QueueEvent.ITEM_COMPLETE, onItemComplete);
			queueLoader.addEventListener(QueueEvent.ITEM_IO_ERROR, onItemIOError);
			queueLoader.addEventListener(QueueEvent.QUEUE_COMPLETE, onQueueComplete);
			var resources:XMLList=config..resource;
			for each (var resource:XML in resources) {
				var url:String=GameConfig.ROOT_URL + resource.@url;
				var name:String=resource.@name;
				queueLoader.add(url, name);
			}

			//预加载欢迎页面
			if (int(GameParameters.getInstance().level) == 1) {
				queueLoader.add(GameParameters.getInstance().resourceHost + 'com/assets/welcome.swf', "欢迎页面");
			}
			var area:String=GameParameters.getInstance().map_id.substr(0, 2); //预加载当前地图MCM和背景图

			var map_mcm:String=GameConfig.ROOT_URL + "com/maps/mcm/" + area + ".mcms";
			queueLoader.add(map_mcm, "地图配置");
			queueLoader.load();
		}

		/**
		 * 加载资源进度条
		 */

		private function onItemProgress(event:QueueEvent):void {
			GameLoading.getInstance().setItemPercent("正在载入" + event.loadItem.data + "：", event.data.bytesLoaded, event.data.bytesTotal);
		}

		/**
		 * 加载资源项完毕
		 */
		private function onItemComplete(event:QueueEvent):void {
			GameLoading.getInstance().setTotalPercent(queueLoader.loadCount, queueLoader.size);
			if (event.loadItem.type == LoaderItem.SWF) {
				ResourcePool.add(event.loadItem.url, event.data.contentLoaderInfo.applicationDomain);
			} else {
				if (event.loadItem.url.substr(event.loadItem.url.length - 3, 3) == "jpg") {
					ResourcePool.add(event.loadItem.url, event.data.content.bitmapData);
				} else {
					if (event.loadItem.url.substr(event.loadItem.url.length - 4, 4) == "mcms") {
						WorldManager.parseMcmBag(event.data);
					} else {
						ResourcePool.add(event.loadItem.url, event.data);
					}
				}
			}

			if (event.loadItem.url == GameConfig.T1_UI) {
				Style.getInstance().startInit();
			} else if (event.loadItem.url == GameConfig.XML_LIB_URL) {
				CommonLocator.parseXMLFile();
				MonsterConfig.init();
				PetConfig.init();
				SkillDataManager.init();
				BuffModule.init();
				ServerMapConfig.protocolXML=CommonLocator.getXML(CommonLocator.SERVER_MAP);
				WorldManager.setup();
			} else if (event.loadItem.url == GameConfig.WORLDMCM_URL) {
				WorldManager.setup();
			} else if (event.loadItem.url == GameConfig.MISSION_DATA_URL) {
				MissionDataManager.getInstance().initBaseList(event.data);
			}else if (event.loadItem.url == GameConfig.NPC_DATA_URL) {
				NPCDataManager.getInstance().initNpcData(event.data);
			} else if (event.loadItem.url == GameConfig.MISSION_SETTING) {
				MissionDataManager.getInstance().initMissionSetting(event.data);
			} else if (event.loadItem.url == GameConfig.POS_URL) {
				Pos.dealPos(event.data);
			}
		}

		/**
		 * 加载队列资源完毕
		 */
		private function onQueueComplete(event:QueueEvent):void {
			queueLoader.removeEventListener(QueueEvent.ITEM_PROGRESS, onItemProgress);
			queueLoader.removeEventListener(QueueEvent.ITEM_COMPLETE, onItemComplete);
			queueLoader.removeEventListener(QueueEvent.ITEM_IO_ERROR, onItemIOError);
			queueLoader.removeEventListener(QueueEvent.QUEUE_COMPLETE, onQueueComplete);
			queueLoader.clear();
			queueLoader=null;
			loaded = true;
			if(connected){
				initGame();
			}else{
				showConnect();
			}
		}

		/**
		 * 加载资源项出错
		 */
		private function onItemIOError(event:QueueEvent):void {
			//直接刷新游戏
			flash.net.navigateToURL(new URLRequest(GameParameters.getInstance().serviceHost + "game.php"), "_self");
		}

		/**
		 * 开始连接服务器并加载资源
		 */
		private function loadAndConnect(e:Event=null):void {
			this.stage.removeEventListener(Main.READY_FOR_CONNECT, loadAndConnect);
			addChild(GameLoading.getInstance());
			LoginModule.getInstance().onInitConnect(onConnectSucc);
			loadConfig();
		}

		/**
		 * 显示连接服务器进度条
		 */		
		private function showConnect():void{
			if (timer == null) {
				timer=new Timer(200, 0);
				timer.addEventListener(TimerEvent.TIMER, onConnectTimer);
				timer.start();
			}
			GameLoading.getInstance().itemLabel="正在连接服务器";
			GameLoading.getInstance().setTotalPercent(14,15);
		}
		/**
		 * 连接服务器成功后的回调
		 *
		 */
		private function onConnectSucc():void {
			connected = true;
			if(timer){
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, onConnectTimer);
				timer=null;
			}	
			if(loaded){
				initGame();
			}
		}

		/**
		 * 连接服务器的进度条处理
		 */
		private function onConnectTimer(event:TimerEvent):void {
			GameLoading.getInstance().setItemPercent("连接游戏服", timer.currentCount % 10, 9);
		}

		/**
		 * Socket连接成功、资源加载完成后开始初始化游戏
		 */
		private function initGame():void {
			createContextMenu();
			LayerManager.createLayers();
			ModuleFactory.createModules();
			GameLoading.getInstance().setItemPercent("正在获取角色信息", 9, 10);
			LoginModule.getInstance().onStartAuth();
			GameConfig.initGame=true;
		}

		/**
		 * 构建上下文菜单
		 */
		private function createContextMenu():void {
			var customMenu:ContextMenu=new ContextMenu();
			createMenuItem("收藏《天之刃》", bookmarkit, customMenu.customItems);
			createMenuItem("开发团队：广州明朝网络科技有限公司", goHome, customMenu.customItems);
			createMenuItem(GameParameters.getInstance().serviceVersion, copyText, customMenu.customItems);
			customMenu.hideBuiltInItems();
			contextMenu=customMenu;
		}

		private function createMenuItem(label:String, call:Function, menuItems:Array):ContextMenuItem {
			var menuItem:ContextMenuItem=new ContextMenuItem(label)
			menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, call);
			menuItems.push(menuItem);
			return menuItem;
		}

		private function bookmarkit(event:ContextMenuEvent):void {
			try {
				ExternalInterface.call('bookmarkit');
			} catch (e:Error) {

			}
		}

		private function goHome(event:ContextMenuEvent):void {
			navigateToURL(new URLRequest(GameParameters.getInstance().officeSite))
		}

		private function copyText(event:ContextMenuEvent):void {
			System.setClipboard(ContextMenuItem(event.currentTarget).caption)
		}
	}
}