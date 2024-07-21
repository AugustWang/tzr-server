package modules.official
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.components.menuItems.TargetRoleInfo;
	import com.net.SocketCommand;
	import com.utils.HtmlUtil;
	
	import modules.BaseModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.chat.ChatType;
	import modules.official.views.KingView;
	
	import proto.chat.m_chat_king_ban_toc;
	import proto.chat.m_chat_king_ban_tos;
	
	public class KingModule extends BaseModule
	{
		public function KingModule()
		{
			super();
		}
		
		private static var _instance:KingModule;
		public static function getInstance():KingModule
		{
			if(_instance == null)
			{
				_instance = new KingModule();				
			}
			return _instance;
		}
		
		override protected function initListeners():void
		{
			addSocketListener(SocketCommand.CHAT_KING_BAN, onChatKingBan);
		}
		
		public function forbidden(roleInfo:TargetRoleInfo):void
		{
			if(roleInfo.faction_id!=GlobalObjectManager.getInstance().user.base.faction_id)
			{
				Alert.show("只能禁言本国玩家！", "提示", null, null, "确定", "", null, false);
				return;
			}
			var kingbanView:KingView = KingView.getInstance();
			kingbanView.setData(roleInfo.roleId,roleInfo.roleName);
			kingbanView.showView();			
		}
		
		private function onChatKingBan(vo:m_chat_king_ban_toc):void {
			if(vo.succ&&vo.bantimes>0)
				BroadcastSelf.logger("<font color='#EE0000'>您今天还有"+ vo.bantimes.toString() +"次禁言机会</font>");
			else if(vo.bantimes==100)
				BroadcastSelf.logger("<font color='#EEEE00'>"+ vo.reason +"</font>");
			else
				Alert.show(vo.reason, "提示", null, null, "确定", "", null, false);
		}
		
		public function kingBan(roleID:int,roleName:String,timeOut:int):void
		{
			var vo:m_chat_king_ban_tos = new m_chat_king_ban_tos();
			vo.roleid=roleID;
			vo.rolename=roleName;
			vo.total_times=timeOut;			
			this.sendSocketMessage(vo);
		}
	}
}