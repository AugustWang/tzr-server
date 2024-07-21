package modules.conlogin
{
	import com.Message;
	import com.common.GlobalObjectManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.conlogin.views.ClearConloginView;
	import modules.conlogin.views.ConloginView;
	
	import proto.line.m_conlogin_clear_toc;
	import proto.line.m_conlogin_clear_tos;
	import proto.line.m_conlogin_fetch_toc;
	import proto.line.m_conlogin_info_toc;
	import proto.line.m_conlogin_info_tos;
	import proto.line.m_conlogin_notshow_toc;
	
	public class ConloginModule extends BaseModule
	{
		private static var _instance:ConloginModule;
		
		private var _conloginView:ConloginView;
		
		private var _bRequest:Boolean = false;
		/**
		 * 系统公告
		 */
		private var _noticeContent:String ;
		
		private var _rewards:Array;
		
		
		/**
		 * 常量定义
		 */
		public static var OPEN_PANEL:String = "OPEN_PANEL";
		public static var CONLOGIN:String = "CONLOGIN";
		public static var CONLOGIN_INFO:String = "CONLOGIN_INFO";
		public static var CONLOGIN_NOTSHOW:String = "CONLOGIN_NOTSHOW";
		public static var CONLOGIN_FETCH:String = "CONLOGIN_FETCH";
		
		public function ConloginModule() {
			super();
		}
		
		public static function getInstance():ConloginModule {
			if (_instance == null) {
				_instance = new ConloginModule();
			}
			return _instance;
		}
		
		
		override protected function initListeners():void{
//			addSocketListener(SocketCommand.CONLOGIN_FETCH, doFetchBack);
			// addSocketListener(SocketCommand.CONLOGIN_INFO, doInfoBack);
//			addSocketListener(SocketCommand.CONLOGIN_NOTSHOW, doNotShowBack);
//			addSocketListener(SocketCommand.CONLOGIN_CLEAR, clearConloginDaysReturn);
//				
//			addMessageListener(ModuleCommand.CONLOGIN_OPEN_PANEL, openConloginPanel);
//			addMessageListener(ModuleCommand.ENTER_GAME, requestInfoAuto);
		}
		
		public function sendNotShowRequest(vo:Message):void
		{
			this.sendSocketMessage(vo);
		}
		
		private function clearConloginDaysReturn(vo:m_conlogin_clear_toc):void
		{
			if (!vo.succ)
				Tips.getInstance().addTipsMsg(vo.reason);
		}
		
		public function clearConloginDaysRequest():void
		{			
			sendSocketMessage(new m_conlogin_clear_tos);
		}
		
		public function popClearConloginView():void
		{
			var notice:ClearConloginView = new ClearConloginView();
			WindowManager.getInstance().popUpWindow(notice);
		}
		
		/**
		 * 自动请求服务器
		 */
		public function requestInfoAuto():void{
			if (GlobalObjectManager.getInstance().user.attr.level >= 20) {
				var vo:m_conlogin_info_tos = new m_conlogin_info_tos;
				vo.auto = true;
				this._bRequest = true;
				this.sendSocketMessage(vo);
			}
		}
		
		/**
		 * 玩家主动点击按钮请求数据
		 */
		public function requestInfo():void{
			this._bRequest = true;
			var vo:m_conlogin_info_tos = new m_conlogin_info_tos;
			vo.auto = false;
			this.sendSocketMessage(vo);
		}
		
		/**
		 * 处理领取或者购买奖励的返回值
		 */
		private function doFetchBack(vo:m_conlogin_fetch_toc):void{
			if (vo.succ) {
				this._conloginView.updateReward(vo);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		/**
		 * 处理获取连续登录信息的返回值
		 */
		private function doInfoBack(vo:m_conlogin_info_toc):void{
			this._noticeContent = vo.notice;
			this._rewards = vo.rewards;
			if (this._conloginView == null) {
				this._conloginView = new ConloginView;
				this._conloginView.initView(vo);
			} else {
				this._conloginView.update(vo);
			}
			
			if (this._bRequest ) {
				createConloginPanel();
				this._bRequest = false;
			}
		}
		
		/**
		 * 处理点击 当天不显示 的返回值
		 */
		private function doNotShowBack(vo:m_conlogin_notshow_toc):void{
			if (vo.succ) {
				BroadcastSelf.logger("你已设置今天不再自动显示连续登陆窗口");
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		private function openConloginPanel():void{
			if (this._conloginView == null) {
				this._conloginView = new ConloginView;
				// 向服务器请求数据
				requestInfo();
			} else {
				createConloginPanel();
			}
		}
		
		public function send(vo:Message):void{
			this.sendSocketMessage(vo);
		}
		
		private function createConloginPanel():void{
			WindowManager.getInstance().popUpWindow(this._conloginView, WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(this._conloginView);
		}
	}
}