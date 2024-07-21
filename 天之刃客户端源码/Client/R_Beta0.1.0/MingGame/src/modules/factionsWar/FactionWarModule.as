package modules.factionsWar {
	import com.Message;
	import com.net.SocketCommand;

	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.factionsWar.cases.FactionsWarCase;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;


	public class FactionWarModule extends BaseModule {
		private static var _instance:FactionWarModule;
		public var factionCase:FactionsWarCase;

		public function FactionWarModule() {
			factionCase=new FactionsWarCase();
			super();
		}

		public static function getInstance():FactionWarModule {
			if (_instance == null) {
				_instance=new FactionWarModule();
			}
			return _instance;
		}

		override protected function initListeners():void {
			//模块
			this.addMessageListener(NPCActionType.NA_52, factionCase.showFactionPaned);
			this.addMessageListener(ModuleCommand.CHANGE_MAP, factionCase.onChangeMap);
			//服务器
			this.addSocketListener(SocketCommand.WAROFFACTION_WARINFO, factionCase.onAskWarInfo); //国战信息
			this.addSocketListener(SocketCommand.WAROFFACTION_DECLARE, factionCase.onDeclare); //国战宣战信息
			this.addSocketListener(SocketCommand.WAROFFACTION_BUY_GUARDER, factionCase.onAskBugGuard); //国战购买守卫
			this.addSocketListener(SocketCommand.WAROFFACTION_GATHER_FACTIONIST, factionCase.onGatherFactionist); //国王令
			this.addSocketListener(SocketCommand.WAROFFACTION_RECORD, factionCase.OnAskRecord); //国战购买守卫
			this.addSocketListener(SocketCommand.WAROFFACTION_GATHER_CONFIRM, factionCase.onGatherConfirm); //同意召集
			this.addSocketListener(SocketCommand.WAROFFACTION_COUNT_DOWN, factionCase.onCountDown); //

		}

		public function sendServerMessage(vo:Message):void {
			this.sendSocketMessage(vo);
		}
	}
}