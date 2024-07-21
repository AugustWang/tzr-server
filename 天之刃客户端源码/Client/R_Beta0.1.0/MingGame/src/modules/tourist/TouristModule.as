package modules.tourist {
	import com.adobe.crypto.MD5;
	import com.common.GlobalObjectManager;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import flashx.textLayout.elements.BreakElement;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.tourist.views.TouristRegPanel;

	public class TouristModule extends BaseModule {
		/*-----------------------------
		//返回注销
		1	成功，并注册了name这个用户
		-1      参数不全，或者部分参数的值不合规范
		-2      用户名不合法（可能被注册，也可能非法）
		-3      Email地址不合法
		-4      超时，链接失效
		-5      验证失败
		-6      平台暂停注册
		-7      未知原因用户注册失败
		-----------------------------*/
		public static const REG_SUCC:int=1;
		public static const ERROR_PARAM:int=-1;
		public static const ERROR_USERNAME:int=-2;
		public static const ERROR_EMAIL:int=-3;
		public static const ERROR_TIME_OUT:int=-4;
		public static const ERROR_REG:int=-5;
		public static const ERROR_PAUSE:int=-6;
		public static const ERROR:int=7;
		
		/*-----------------------------
		1	恭喜您乙方不存在username或者是email不存在
		0	已存在检验失败，请玩家重新再输入
		-1      参数不全，或者部分参数的值不合规范
		-5      验证失败
		-6      平台暂停注册
		-----------------------------*/
		public static const VERIFY_SUCC:int=1;
		public static const VERIFY_ERROR:int=0;
		public static const VERIFY_ERROR_PARAM:int=-1;
		public static const VERIFY_ERROR_REG:int=-5;
		public static const VERIFT_PAUSE:int=-6;
		
		public static const ACTION_REG:String="reg";
		public static const ACTION_CHECK:String="check";
		
		public static const GAME_NAME:String="tzr";
		
		public var key:String="";
		public var verifyURL:String="http://web.4399.com/api/reg/gamereg.php";
		public var regURL:String="http://web.4399.com/api/reg/gamereg.php";
		private var regBtn:Button;

		private static var instance:TouristModule;
		public static function getInstance():TouristModule{
			if(instance == null){
				instance = new TouristModule();
			}
			return instance;
		}
		
		public function TouristModule() {
		}
		
		override protected function initListeners():void{
			addMessageListener(ModuleCommand.ENTER_GAME,onEnterGame);
		}
		
		private function onEnterGame():void{
			removeMessageListener(ModuleCommand.ENTER_GAME,onEnterGame);
			if(GlobalObjectManager.getInstance().user.base.account_type == 3){//游客模式
				showRegBtn();
			}else{
				unload();
			}
		}
		
		private function unload():void{
			if(regBtn){
				regBtn.removeEventListener(MouseEvent.CLICK,onRegBtnClickHandler);
				regBtn.parent.removeChild(regBtn.parent);
			}
			instance=null;
		}
		
		public function showRegBtn():void{
			regBtn=ComponentUtil.createButton("注册",200,200,100,24,LayerManager.uiLayer);
			regBtn.addEventListener(MouseEvent.CLICK,onRegBtnClickHandler);
		}
		
		private var _regPanel:TouristRegPanel;
		private function onRegBtnClickHandler(event:MouseEvent):void{
			if(!_regPanel){
				_regPanel = new TouristRegPanel();
			}else{
				_regPanel.reset();
			}
			WindowManager.getInstance().popUpWindow(_regPanel);
			WindowManager.getInstance().centerWindow(_regPanel);
		}
		
		public function reg($username:String,$password:String,$email:String,$cid:int=3000):void{
			var variables:URLVariables = new URLVariables();
			variables.action = ACTION_REG;
			variables.game = GAME_NAME;
			variables.username = $username;
			variables.password = $password;
			variables.email = $email;
			variables.cid = $cid;
			variables.key = key;
			var time:int = new Date().getTime()
			variables.time = time;
			variables.flag = MD5.hash(GAME_NAME+$username+$email+key+time+$cid);
			send(regURL,variables,regCompleteHandler,regIOErrorHandler);
		}
		
		private function regCompleteHandler(event:Event):void{
			var urlLoader:URLLoader = URLLoader(event.target);
			var state:int = int(urlLoader.data);
			if(_regPanel){
				_regPanel.regCallBack(state);
			}
		}
		
		private function regIOErrorHandler(event:Event):void{
			
		}
		
		public function verifyEmail($email:String):void{
			var variables:URLVariables = new URLVariables();
			variables.action = ACTION_CHECK;
			variables.email = escape($email);
			variables.time = new Date().getTime();
			variables.flag = MD5.hash(key+$email);
			send(verifyURL,variables,verifyEmailCompleteHandler,verifyEmailIOErrorHandler);
		}
		
		private function verifyEmailCompleteHandler(event:Event):void{
			var urlLoader:URLLoader = URLLoader(event.target);
			var state:int = int(urlLoader.data);
			if(_regPanel){
				_regPanel.verifyEmailCallBack(state);
			}
		}
		
		private function verifyEmailIOErrorHandler(event:Event):void{
			
		}
		
		public function verifyUserName($usermane:String):void{
			var variables:URLVariables = new URLVariables();
			variables.action = ACTION_CHECK;
			variables.username = escape($usermane);
			variables.time = String(new Date().getTime());
			variables.flag = MD5.hash(key+$usermane);
			send(verifyURL,variables,verifyUserNameCompleteHandler,verifyUserNameIOErrorHandler);
		}
		
		private function verifyUserNameCompleteHandler(event:Event):void{
			var urlLoader:URLLoader = URLLoader(event.target);
			var state:int = int(urlLoader.data);
			if(_regPanel){
				_regPanel.verifyUserNmaeCallBack(state);
			}
		}
		
		private function verifyUserNameIOErrorHandler(event:Event):void{
			
		}
		
		private function send(url:String,vars:URLVariables,complete:Function,ioerror:Function):void{
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			//loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			request.data = vars;
			request.method = URLRequestMethod.POST;
			loader.addEventListener(Event.COMPLETE, complete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioerror);
			loader.load(request);
		}
	}
}