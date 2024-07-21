package modules.present
{
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.present.views.PresentWindow;
	
	import proto.common.p_present_info;
	import proto.line.m_present_get_toc;
	import proto.line.m_present_get_tos;
	import proto.line.m_present_notify_toc;

	public class PresentModule extends BaseModule
	{
		public var _presentWindow:PresentWindow;
		
		
		public function PresentModule()
		{
		}
		
		/**
		 * 单例 
		 */		
		private static var instance:PresentModule;
		public static function getInstance():PresentModule{
			if(instance == null){
				instance = new PresentModule();
			}
			return instance;
		} 
		
		override protected function initListeners():void{
			//服务端消息
			this.addSocketListener(SocketCommand.PRESENT_GET,onGetBack);
			this.addSocketListener(SocketCommand.PRESENT_NOTIFY,onNotifyBack); 
			//模块消息
			this.addMessageListener(ModuleCommand.PRESENT_PRESENT_GET,getPresent); 
			
		} 
		
		/**
		 *后台调弹窗 
		 */		
		private var source:SourceLoader;
		private var _info:p_present_info;
		public function onNotifyBack(obj:Object):void{
			var vo:m_present_notify_toc = obj as m_present_notify_toc;
			var info:p_present_info = vo.present_list[0] as p_present_info;
			_info = info;
			if( !_presentWindow ){
				source = new SourceLoader();
				var reward_url:String =  GameConfig.ROOT_URL+"com/assets/gift/gift.swf";
				var msg:String = "加载礼包模块、、、";
				source.loadSource(reward_url,msg,openPresentWindow);
			}else{
				openPresentWindow();
			}
		}
		
		private function openPresentWindow():void{
			if( !_presentWindow ){
				_presentWindow = new PresentWindow();
				_presentWindow.initView( source );
			}
			_presentWindow.updata(_info);
			WindowManager.getInstance().popUpWindow(_presentWindow);
		}
		
		/**
		 *礼包返回 
		 */		
		private function onGetBack(obj:Object):void{
			var vo:m_present_get_toc = obj as m_present_get_toc;
			if(vo.succ){
				//nothing
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		/**
		 *领取礼包
		 */		
		public function getPresent(obj:Object):void{
			var vo:m_present_get_tos = new m_present_get_tos();
			vo.present_id = 10001;
			sendSocketMessage(vo);
		}
	}
}