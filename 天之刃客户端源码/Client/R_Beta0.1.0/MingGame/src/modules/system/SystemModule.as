package modules.system
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameParameters;
	import com.managers.MusicManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.sceneKit.LoadingSetter;
	import com.scene.sceneManager.LoopManager;
	import com.utils.HtmlUtil;
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.chat.ChatType;
	import modules.scene.SceneDataManager;
	import modules.skill.vo.SkillVO;
	import modules.system.views.Anti_PopUpWindow;
	import modules.system.views.Anti_addictionWindow;
	import modules.system.views.SystemWindow;
	
	import proto.line.m_system_config_change_toc;
	import proto.line.m_system_config_change_tos;
	import proto.line.m_system_config_toc;
	import proto.line.m_system_error_toc;
	import proto.line.m_system_fcm_toc;
	import proto.line.m_system_heartbeat_toc;
	import proto.line.m_system_heartbeat_tos;
	import proto.line.m_system_message_toc;
	import proto.line.m_system_need_fcm_toc;
	import proto.line.m_system_set_fcm_toc;
	import proto.line.m_system_set_fcm_tos;
	import proto.line.p_sys_config;
	
	public class SystemModule extends BaseModule
	{
		public static var showSuccessMsg:Boolean = false;
		private var messages:Array;
		private var inited:Boolean;
		private var timer:Timer;
		private var beats:Dictionary;
		// 是否已经提示弹窗错误
		private var errorShowed:Boolean=false;
		public function SystemModule()
		{
			messages = [];
		}

		private static var instance:SystemModule;
		public static function getInstance():SystemModule{
			if(instance == null){
				instance = new SystemModule();
			}
			return instance;
		}
		
		override protected function initListeners():void{
			addMessageListener(ModuleCommand.CHANGE_MAP,mapChanged);
			addMessageListener(ModuleCommand.OPEN_SYSTEM_WINDOW,openSystemWindow);
			addMessageListener(ModuleCommand.OPEN_AUTOKILL_MONSTER,openAutoKill);
			addMessageListener(ModuleCommand.RESET_SKILL,resetSkill);
			addMessageListener(ModuleCommand.ENTER_GAME, this.onEnterGame);
			addMessageListener(ModuleCommand.HP_AUTOUSE_CHANGE, onHPPercentChange);
			addMessageListener(ModuleCommand.MP_AUTOUSE_CHANGE, onMPPercentChange);
			
			addSocketListener(SocketCommand.SYSTEM_FCM,showFCMInfo);
			addSocketListener(SocketCommand.SYSTEM_NEED_FCM,openFCMPopUpWindow);
			addSocketListener(SocketCommand.SYSTEM_SET_FCM,setFCMHandler);
			addSocketListener(SocketCommand.SYSTEM_CONFIG,setInitConfig);
			addSocketListener(SocketCommand.SYSTEM_CONFIG_CHANGE,setSaveConfig);
			addSocketListener(SocketCommand.SYSTEM_HEARTBEAT,onHeartBeat);
			addSocketListener(SocketCommand.SYSTEM_MESSAGE,showSystemMessage);
			addSocketListener(SocketCommand.SYSTEM_ERROR,onSystemError);	
			
			// 检查变速用
			LoopManager.addToSecond('SystemModule', checkBiansu);
		}
		
		private function onHPPercentChange(percent:int):void{
			if(systemWindow){
				systemWindow.gamesettingView.onHPAutoChange(percent);
			}
			SystemConfig.hp=percent/100;
			SystemConfig.save();
		}
		
		private function onMPPercentChange(percent:int):void{
			if(systemWindow){
				systemWindow.gamesettingView.onMPAutoChange(percent);
			}
			SystemConfig.mp=percent/100;
			SystemConfig.save();
		}
		
		private var oldvalue:Number=0;
		private var runTime:Number=0;
		private var num:int=0;
		
		private function checkBiansu():void{
			var date:Date=new Date;
			var newValue:Number=date.valueOf();
			var timerValue:Number=getTimer();
			var value:Number=(timerValue-runTime) - (newValue-oldvalue);
			if(value > 30) {
				num++;
				if(num >= 6)
				{
					this.errorShowed = false;
					connect.close();
					Alert.show('你已从服务器断开连接，错误码:0x0001', '提示', redirectToOfficeSite, null, '确定', null, null, false);
				}
			} else {
				num = 0;
			}
			//  保存这一次的fp timer
			runTime=timerValue;
			oldvalue=newValue;	
		}
		
		/**
		 * 显示服务器断开连接的提示 
		 * 
		 */		
		public function showSocketClosedWindow():void{
			onServerClosed();
		}
		
		public function onServerClosed():void{
			if (!this.errorShowed) {
				LoadingSetter.mapLoading(false);
				if (GlobalObjectManager.getInstance().system_error != null) {
					var error:m_system_error_toc = GlobalObjectManager.getInstance().system_error;
					var str:String = error.error_info;
					var errorNo:int = error.error_no;
					if (errorNo == 10006 || errorNo == 10017) {
						// 显示防沉迷提示界面
						showFcmAlert(str);
					} else if (errorNo == 10005 || errorNo == 10010 || errorNo == 10012 || errorNo == 10015) {
						// 网络不稳定的话，提示玩家重新连接
						showReconnectAlert();
					} else {
						// 其他情况跳转到官网
						Alert.show(str, '提示', redirectToOfficeSite, null, '确定', null, null, false);
					}
				} else {
					// 显示重连提示
					showReconnectAlert();
				}
			}
			this.errorShowed = true;
		}
		
		/**
		 * 跳转到官网 
		 */		
		private function redirectToOfficeSite():void{
			flash.net.navigateToURL(new URLRequest(GameParameters.getInstance().officeSite), "_self");
		}
		
		/**
		 * 显示防沉迷提示窗口 
		 * @param info
		 * 
		 */		
		private function showFcmAlert(info:String):void{
			Alert.show(info, '防沉迷提示', redirectToFcmUrl, redirectToOfficeSite, "填写防沉迷", "暂时不填");
		}
		
		/**
		 * 弹出防沉迷填写页面
		 */
		private function redirectToFcmUrl():void {
			flash.net.navigateToURL(new URLRequest(GameParameters.getInstance().fcmApiUrl), '_self');
		}
		
		/**
		 * 提示玩家是否自动重新连接 
		 * 
		 */		
		private function showReconnectAlert():void{
			Alert.show("你已从服务器断开连接", "温馨提示", reconnectToServer, null, "重新连接", null, null, false);
		}
		
		/**
		 * 自动重连服务器，目前的做法是直接刷新，由PHP和session来判断 
		 */		
		private function reconnectToServer():void{
			flash.net.navigateToURL(new URLRequest(GameParameters.getInstance().serviceHost + "game.php"), "_self");
		}
		
		private function onSystemError(vo:m_system_error_toc):void{
			if(10002 != vo.error_no && 10006 != vo.error_no){
				Alert.show(vo.error_info, '温馨提示', this.navigateToFCM, this.navigateToFCM);
			}
			if(vo.error_no == 10017){
				return;	
			}
			GlobalObjectManager.getInstance().system_error = vo;
		}
		
		private function navigateToFCM():void{
			navigateToURL(new URLRequest(GameParameters.getInstance().fcmApiUrl), "_self");
		}
		
		private function initHeartBeat():void{
			if(beats == null){
				beats = new Dictionary();
				timer = new Timer(1000);
				timer.addEventListener(TimerEvent.TIMER, toSendHeartBeat);
				timer.start();
			}
		}
		
		private function toSendHeartBeat(e:TimerEvent):void
		{
			var time:int=getTimer();
			beats[time]=time;
			var vo:m_system_heartbeat_tos=new m_system_heartbeat_tos;
			vo.time = time;
			sendSocketMessage(vo);
		}
		
		public function onHeartBeat(vo:m_system_heartbeat_toc):void
		{
			SystemConfig.serverTime = vo.server_time;
			if (beats[vo.time] != null)
			{
				var oldTime:int=beats[vo.time];
				var nowTime:int=getTimer();
				netPing(nowTime-oldTime);
				delete beats[vo.time];
			}
		}
		
		private var count:int = 1;
		private var totalTime:int = 0
		private function netPing(lazyTime:int):void{
			totalTime += lazyTime;
			count++;
			if(count == 30){
				dispatch(ModuleCommand.NET_PING_VALUE,int(totalTime/count));
				count = 0;
				totalTime = 0;
			}
			dispatch(ModuleCommand.HEART_BEAT);
		}
		
		private function resetSkill():void{
			SystemConfig.skills = [null,null,null,null,null];
			if(systemWindow != null){
				systemWindow.skillReset();
			}
			SystemConfig.save();
		}
		
		public function addSkill($skill:SkillVO):void{
			if(SystemConfig.skills.length == 0)SystemConfig.skills = [null,null,null,null,null];
			for(var i:int = 0; i < SystemConfig.skills.length; i++){
				if(SystemConfig.skills[i] == null){
					SystemConfig.skills[i] = $skill;
					SystemConfig.save();
					return;
				}else{
					if(SystemConfig.skills[i].sid == $skill.sid){
						return;
					}
				}
			}
			
		}
	
		private var systemWindow:SystemWindow;
		private function openSystemWindow(point:Point=null):void{
			if(systemWindow == null){
				systemWindow = new SystemWindow();
				WindowManager.getInstance().centerWindow(systemWindow);
			}
			WindowManager.getInstance().popUpWindow(systemWindow);
			if(point){
				systemWindow.x=point.x;
				systemWindow.y=point.y;
			}
			if(systemWindow && systemWindow.parent){
				systemWindow.selectIndex(0);
			}
		}
		
		private function mapChanged(mapId:int):void{
			var isSubMap:Boolean=SceneDataManager.isSubMap();
			SystemConfig.hitMonsters = SceneDataManager.getMonsters(isSubMap);//副本地图默认全部怪，普通地图默认普通怪
			if(systemWindow){
				systemWindow.changeHitMonster();
			}
			MusicManager.play();
		}
		
		private function openAutoKill():void{
			openSystemWindow();
			if(systemWindow && systemWindow.parent){
				systemWindow.selectIndex(1);
			}
		}
		
		
		public function startFlight():void{
			dispatch(ModuleCommand.START_FLIGHT);
		}
		
		public function showFCMInfo(value:m_system_fcm_toc):void{
			var time:Number = value.total_time;
			if (value.total_time >= 7200) {
				Alert.show("<font color='#FFFF00'>您累积在线时间已满2小时</font>", "防沉迷提示");
				BroadcastSelf.getInstance().appendMsg( "<font color='#FFFF00'>您累积在线时间已满2小时</font>");
			} else if (value.total_time >= 3600) {
				Alert.show("<font color='#FFFF00'>您累积在线时间已满1小时</font>", "防沉迷提示");
				BroadcastSelf.getInstance().appendMsg( "<font color='#FFFF00'>您累积在线时间已满1小时</font>");
			}
		}
		
		private var fcmPopWin:Anti_PopUpWindow;
		private var fcmWin:Anti_addictionWindow;
		public function openFCMWindow(value:m_system_fcm_toc):void{
			var proxyName:String = GameParameters.getInstance().proxyName;
			if(proxyName == GameParameters.PROXY_NAME_BAIDU || proxyName == GameParameters.PROXY_NAME_360){
				navigateToURL(new URLRequest(GameParameters.getInstance().fcmApiUrl), "_bank");
				return;
			}
			if(fcmWin == null){
				fcmWin = new Anti_addictionWindow();
				fcmWin.setValue(value);
			}else{
				fcmWin.resetUI();
				fcmWin.setValue(value);
			}
			fcmWin.x = 326;
			fcmWin.y = 170;
			WindowManager.getInstance().openDialog(fcmWin,false);
		}
		
		public function openFCMPopUpWindow(value:m_system_need_fcm_toc):void{
			if(fcmPopWin == null){
				fcmPopWin = new Anti_PopUpWindow();
				fcmPopWin.setOnlineTime(value.remain_time);
				fcmPopWin.x = 338;
				fcmPopWin.y = 174;
			} else {
				fcmPopWin.setOnlineTime(value.remain_time);
			}
			setTimeout(function createPop():void{
				WindowManager.getInstance().openDialog(fcmPopWin);
			},5000);
		}
		
		private function timeFormat(time:Number):String{
			var minutes:String = (int(time/60%60)).toString(); 
			var hours:String = (int(time/60/60)).toString(); 
			if(int(hours) == 0)return minutes + '分钟';
			if(int(hours) != 0 && int(minutes)== 0)return hours + '小时';
			return hours + '小时' + minutes + '分钟';
		}
		
		/**
		 * 显示系统提示面板，例如打击背包时，系统可能会提示：背包系统已关闭
		 */
		private function showSystemMessage(vo:m_system_message_toc):void {
			Alert.show(vo.message);
		}
		
		private function setFCMHandler(vo:m_system_set_fcm_toc):void{
			if(vo.succ){
				if(fcmWin != null){
					fcmWin.complete();
				}
				BroadcastSelf.getInstance().appendMsg("成功通过防沉迷验证.");
			}else{
				if(fcmWin != null){
					fcmWin.error(vo.reason);
				}
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
			
		}
		
		private function onEnterGame():void{
			initHeartBeat();
		}
		
		public function setFCM(card:String,realName:String):void{
			var vo:m_system_set_fcm_tos = new m_system_set_fcm_tos();
			vo.card = card;
			vo.name = realName;
			sendSocketMessage(vo);
		}
		
		public function saveConfig(sysConfig:p_sys_config):void{
			var vo:m_system_config_change_tos = new m_system_config_change_tos();
			vo.sys_config = sysConfig;
			sendSocketMessage(vo);
		}
		
		private function setInitConfig(data:Object):void{
			var vo:m_system_config_toc = data as m_system_config_toc;
			SystemConfig.init(vo.sys_config);
			dispatch(ModuleCommand.SYSTEM_CONFIG_INIT);
			if(SystemConfig.centerBroadcast == false){
				setTimeout(showTip,3000);
			}
			initSound();
		}
		
		private function showTip():void{
			Tips.getInstance().addTipsMsg("中央广播被关闭，请在系统设置中打开，以免遗漏重要信息！");
		}
		
		private function initSound():void{
			MusicManager.init();
			changeBackMusic();
		}
		
		public function changeBackMusic():void{
			if(SystemConfig.openBackSound){
				MusicManager.play();
			}else{
				MusicManager.stop();
			}
//			SmallMapWindow.getInstance().changeMusicButton();

			backMusicBoxChange();
		}
		
		public function backMusicBoxChange():void{
			if(systemWindow){
				systemWindow.backMusicBoxChange();
			}
		}
		
		public function teamCheckBoxChange():void{
			if(systemWindow){
				systemWindow.teamCheckBoxChange();
			}	
		}
		
		private function setSaveConfig(vo:m_system_config_change_toc):void{
			if(vo.succ){
				for each(var m:String in messages){
					ChatModule.getInstance().sendChatMsg(m,null,ChatType.WORLD_CHANNEL);
				}
				if(showSuccessMsg){
					BroadcastSelf.logger("系统配置保存成功!");
				}
				showSuccessMsg = false;
				dispatch(ModuleCommand.CONFIG_CHANGED);
			}else{
				showSuccessMsg = false;
				BroadcastSelf.logger(vo.reason);
			}
			messages.length = 0;
			if(systemWindow)
			{
				systemWindow.updateQualityView();
			}
		}
		
		public function postError(error:Error, type:String=null, module:String=null, method:String=null):void{
			if( GameParameters.getInstance().isDebug() || 
				GameParameters.getInstance().isShowException() ){
				throw error;
			}else{
				var urlLoader:URLLoader = new URLLoader;
				var request:URLRequest = new URLRequest(GameParameters.getInstance().serviceHost + "error_collect.php");
				var data:URLVariables = new URLVariables;
				data.error = error.toString();
				data.error_id = error.errorID;
				var stack:String=error.getStackTrace();
				if(stack!=null){
					type=stack;
				}
				data.type = type;
				data.module = module;
				data.method = method;
				request.data = data;
				request.method = "post";
				urlLoader.load(request);
			}
		}
		
		public function log(prefix:String,flag:Boolean):void{
			var result:String;
			if(flag){
				result = "成功开启" + prefix;
			}else{
				result = "成功屏蔽" + prefix;
			}
			var message:String = HtmlUtil.font(result,"#ff0000");
			messages.push(message);
		}
		
	}
}