package modules.login {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameParameters;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.net.SocketCommand;
	import com.net.connection.Connection;
	import com.net.event.ConnectionEvent;
	import com.scene.sceneManager.LoopManager;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.login.views.LoginView;
	import modules.system.SystemConfig;
	
	import proto.line.m_auth_key_toc;
	import proto.line.m_auth_key_tos;
	import proto.line.m_bgp_login_toc;
	import proto.line.m_bgp_login_tos;

	/**
	 * 登录模块 
	 * 
	 */	
	public class LoginModule extends BaseModule {
		private var loginView:LoginView;

		public function LoginModule() {
			super();
		}

		private static var instance:LoginModule;

		public static function getInstance():LoginModule {
			if (instance == null) {
				instance=new LoginModule();
			}
			return instance;
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.START_LOGIN, onDebugLogin);
			
			connect.addEventListener(ConnectionEvent.SUCCESS, onConnected);
			connect.addEventListener(ConnectionEvent.IO_ERROR, onIoError);
			connect.addEventListener(ConnectionEvent.SECURITY_ERROR, onSecurityError);
			
			addMessageListener(ModuleCommand.BGP_STANDBY_RECONNECT_GATEWAY, reConnectLine);
			addSocketListener(SocketCommand.AUTH_KEY, onAuthKey);
			addSocketListener(SocketCommand.BGP_LOGIN, this.onBGPSuccess);
		}
		
		/**
		 * socket连接成功时的回调函数 
		 */		
		private var connectSuccFunc:Function;

		public function onInitConnect(_connectSuccFunc:Function):void {
			this.connectSuccFunc = _connectSuccFunc;
			
			GameParameters.getInstance().lineKey=GameParameters.getInstance().gatewayArr[0].key;
			if (GameParameters.getInstance().directly_use_bgp == 'true') {
				GameLoading.getInstance().itemLabel='正在非常努力地连接服务器';
				connectBGP();
			} else {
				connect.connect(GameParameters.getInstance().gatewayArr[0].host, GameParameters.getInstance().gatewayArr[0].port);
			}
		}

		private function onConnected(event:ConnectionEvent):void {
			if (isConnectBGP) {
				connectBGPSucc();
			} else{
				if (connectSuccFunc != null) {
					connectSuccFunc.apply();
				}
			}
		}

		private var _hasTryBGP:int=0;

		private function reConnectLine():void {
			if (_hasTryBGP <= 5) {
				GameLoading.getInstance().itemLabel='正在很努力地连接服务器';
				connectBGP();
				_hasTryBGP++;
			}
		}
		
		private var isConnectBGP:Boolean = false;
		
		/**
		 * 开始向BGP服务器发送连接请求
		 */
		private function connectBGP():void {
			if(!GameParameters.getInstance().bgp_host ||　!GameParameters.getInstance().bgp_port){
				return;
			}
			if (isConnectBGP) {
				return;
			}
			isConnectBGP = true;
			
			var bgpHost:String = GameParameters.getInstance().bgp_host;
			var bgPort:int = parseInt(GameParameters.getInstance().bgp_port);
			
			Connection.getInstance().connect(bgpHost, bgPort);
		}
		
		/**
		 * 当连接bgp服务器成功时 向bgp发送vo 通知bgp帮玩家转发给定分线的消息
		 */
		private function connectBGPSucc():void{
			var vo:m_bgp_login_tos = new m_bgp_login_tos();
			vo.host = GameParameters.getInstance().lineServer;
			vo.port = parseInt(GameParameters.getInstance().linePort);
			vo.id = 1;
			
			Connection.getInstance().sendMessage(vo);
			this.connectSuccFunc.apply();
		}


		private function onIoError(event:ConnectionEvent):void {
			reConnectLine();
		}

		private function onSecurityError(event:ConnectionEvent):void {
			reConnectLine();
		}

		public function onStartAuth():void {
			var vo:m_auth_key_tos=new m_auth_key_tos();
			vo.account_name=GameParameters.getInstance().account;
			vo.key=GameParameters.getInstance().gatewayArr[0].key;
			vo.role_id=int(GameParameters.getInstance().role_id);
			vo.time=int(GameParameters.getInstance().line_time);
			sendSocketMessage(vo);
			LoopManager.addToTimer(this, getingRole);
		}
		private var percent:Number=0.1;

		private function getingRole():void {
			percent+=0.4;
			percent=percent % 10;
			GameLoading.getInstance().setItemPercent("正在获取角色信息", percent, 10);
		}

		private function onAuthKey(vo:m_auth_key_toc):void {
			if (vo.succ) {
				LoopManager.removeFromTimer(this);
				GameLoading.getInstance().setItemPercent("正在请求进入地图", 1, 1);
				GameLoading.getInstance().dispose();
				GlobalObjectManager.getInstance().user=vo.role_details;
				SystemConfig.serverTime=vo.server_time;
				dispatch(ModuleCommand.START_UP_SCENE);
				dispatch(ModuleCommand.FAMILYINFO_INIT, vo.family);
				dispatch(ModuleCommand.GOODS_INIT, vo.bags);
			} else {
				// key验证失败，直接刷新页面，通常的原因是玩家的网速太慢，key已经过期了
				flash.net.navigateToURL(new URLRequest(GameParameters.getInstance().serviceHost + "game.php"), "_self");
			}
		}

		/**
		 * 开发模式下的登录 
		 * 
		 */		
		public function onDebugLogin():void {
			if (loginView == null) {
				loginView=new LoginView();
				addMessageListener(ModuleCommand.LOGIN_COMPLETE, onLoginComplete);
			}
			(LayerManager.main).parent.addChild(loginView);
		}

		private function onLoginComplete():void {
			if (loginView) {
				loginView.dispose();
				loginView=null;
			}
		}

		private function onBGPSuccess(vo:m_bgp_login_toc):void {
			if (vo.succ == true) {
				dispatch(ModuleCommand.CONNECTED);
			}
		}
	}
}