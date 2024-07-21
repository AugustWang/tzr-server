package modules.greenHand
{
	import com.globals.GameParameters;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.JSUtil;
	
	import modules.BaseModule;
	import modules.broadcast.views.Tips;
	import modules.greenHand.view.GensWindow;
	import modules.greenHand.view.GreenHandWindow;
	import modules.greenHand.view.TreasuryWindow;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	
	import proto.line.m_newcomer_activate_code_toc;
	import proto.line.m_newcomer_activate_code_tos;
	
	public class GreenHandModule extends BaseModule
	{
		private static var _instance:GreenHandModule;
		public function GreenHandModule()
		{
		}
		
		public static function getInstance():GreenHandModule{
			if(!_instance){
				_instance = new GreenHandModule();
			}
			return _instance;
		}
		
		override protected function initListeners():void{
			//服务端消息
			this.addSocketListener(SocketCommand.NEWCOMER_ACTIVATE_CODE,activationCodeBack);
			
			// 模块消息
			this.addMessageListener(NPCActionType.NA_41, openGreenHandWindow);
			this.addMessageListener(NPCActionType.NA_42, getActiveCode);
			this.addMessageListener(NPCActionType.NA_94, openGensWindow);
		}
		
		// 领取激活码
		private function getActiveCode(vo:NpcLinkVO):void
		{	
			JSUtil.openWebSite(GameParameters.getInstance().activateCodeUrl);
		}
		
		//打开新手卡的界面
		private var greenHandlerWin:GreenHandWindow;
		private function openGreenHandWindow(vo:NpcLinkVO):void
		{
			if(!greenHandlerWin){
				greenHandlerWin = new GreenHandWindow();
			}
			
			WindowManager.getInstance().popUpWindow(greenHandlerWin,WindowManager.UNREMOVE);
		}
		
		//打开门派卡兑换礼包的界面
		private var gensWin:GensWindow;
		private function openGensWindow(vo:NpcLinkVO):void
		{
			if(!gensWin){
				gensWin = new GensWindow();
			}
			WindowManager.getInstance().popUpWindow(gensWin,WindowManager.UNREMOVE);
		}
		
		//请求激活码
		public function requestActivationCode(code:String):void{
			var vo:m_newcomer_activate_code_tos = new m_newcomer_activate_code_tos();
			vo.code = code;
			
			this.sendSocketMessage(vo);
		}
		
		
		private function activationCodeBack(vo:m_newcomer_activate_code_toc):void{
			if(vo.succ){
				Tips.getInstance().addTipsMsg("激活码礼包已领取，请到背包查看！");
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		
		//打开江湖宝典的界面
		
		private var treasuryWin:TreasuryWindow;
		public function openTreasuryWindow():void{
			if(!treasuryWin){
				treasuryWin = new TreasuryWindow();
			}
			
			WindowManager.getInstance().popUpWindow(treasuryWin,WindowManager.UNREMOVE);
		}
		
		//江湖宝典数据返回
		private function treasuryBack(data:Object):void{}
	}
}