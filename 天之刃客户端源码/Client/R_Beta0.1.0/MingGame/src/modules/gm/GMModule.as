package modules.gm
{
	import com.components.alert.Alert;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	
	import flash.utils.Timer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.gm.view.GMSendView;
	
	import proto.line.m_gm_complaint_toc;
	import proto.line.m_gm_complaint_tos;

	public class GMModule extends BaseModule
	{
		private var sendTimer:Timer;
		public function GMModule(sigleton:SigletonPress)
		{
			
		}
		
		private static var _instance:GMModule
		public static function getInstance():GMModule
		{
			if(_instance == null)
				_instance = new GMModule(new SigletonPress);
			
			return _instance;
		}
		
		
		private var view:GMSendView;
		public function openLetterWin():void{
			if(view == null){
				view = new GMSendView();
				view.initUI();
				WindowManager.getInstance().popUpWindow(view);
				WindowManager.getInstance().centerWindow(view);
			}else{
				view.reset();
				WindowManager.getInstance().popUpWindow(view);
				WindowManager.getInstance().centerWindow(view);
			}
		}
	
		
		override protected function initListeners():void{
			addMessageListener(ModuleCommand.GM_OPEN_SENDVIEW,openLetterWin);
			addSocketListener(SocketCommand.GM_COMPLAINT,gmComplaint);
		}
		
		private function gmComplaint(vo:m_gm_complaint_toc):void{
			if(vo.succ){
				Tips.getInstance().addTipsMsg("信件发送成功，谢谢您的建议/信息。");
				if(view != null){
					WindowManager.getInstance().removeWindow(view);
					sendTimer = new Timer(180000,1);
					sendTimer.start();
				}
			}else{
				sendTimer = null;
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		public function send(title:String,content:String,type:int):void{
			if(sendTimer != null && sendTimer.running){
				Alert.show("发信间隔3分钟，稍后再试哦。","提示",null,null,"确定","取消",null,false);
				return;
			}
			var vo:m_gm_complaint_tos = new m_gm_complaint_tos();
			vo.title = title;
			vo.type = type;
			vo.content = content;
			this.sendSocketMessage(vo);
		}
	}
}
class SigletonPress{}