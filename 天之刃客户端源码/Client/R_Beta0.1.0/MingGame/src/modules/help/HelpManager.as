package modules.help {
	import com.managers.WindowManager;
	
	import modules.BaseModule;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;


	public class HelpManager extends BaseModule {
		public function HelpManager() {

		}

		private static var _instance:HelpManager;

		public static function getInstance():HelpManager {
			if (_instance == null)
				_instance=new HelpManager();
			return _instance;
		}


		private var introducePanel:IntroducePanel;
		
		//帮助文档
		private var helpPanel:HelperPanel;
		
		public function openHelpView():void{
			if(helpPanel == null){
				helpPanel = new HelperPanel();
			}
			helpPanel.openPanel();
		}
		
		/**
		 * 
		 * @return 
		 * 聊天发的信息看在帮助文档中是否存在
		 */		
		public function searchHasKeyWord(msg:String):String{
			if(helpPanel == null){
				helpPanel = new HelperPanel();
			}
			var word:String = helpPanel.searchView.searchOtherWay(msg);
			return word;
		}
		
		public function openSearchView(word:String):void{
			helpPanel.openSearchView(word);
		}
		
		public function openIntroduce(id:int):void {
			if (introducePanel == null) {
				introducePanel=new IntroducePanel();
				introducePanel.setIntroduceId(id);
				introducePanel.closeFunc=closeHandler;
			}
			introducePanel.setIntroduceId(id);
			WindowManager.getInstance().popUpWindow(introducePanel, WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(introducePanel);
		}

		private function closeHandler():void {
			introducePanel.dispose();
			introducePanel=null;
		}

		private function openFactionInfo(vo:NpcLinkVO):void {
			openIntroduce(IntroduceConstant.WAROFFACTION_INTRODUCE);
		}

		override protected function initListeners():void {
			addMessageListener(NPCActionType.NA_54, openFactionInfo);
		}
	}
}