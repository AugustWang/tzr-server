package modules.spy
{
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	import com.components.alert.Alert;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.BroadcastView;
	import modules.chat.ChatType;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.spy.views.SpyFactionTimeView;
	import modules.spy.views.SpyPanel;
	
	import proto.line.m_spy_faction_time_toc;
	import proto.line.m_spy_faction_toc;
	import proto.line.m_spy_faction_tos;
	import proto.line.m_spy_time_toc;
	import proto.line.m_spy_time_tos;
	
	public class SpyModule extends BaseModule
	{
		private var spyFactionTime:SpyFactionTimeView;
		public var spyFactionVo:m_spy_faction_toc;
		private var _spyFactionPanel:SpyPanel;
		/**
		 * 是否正在国探
		 */
		static public var isInSpyFaction:Boolean = false;
		
		public function SpyModule()
		{
		}
		
		private static var instance:SpyModule;
		
		public static function getInstance():SpyModule
		{
			if(!instance){
				
				instance = new SpyModule();
			}
			return instance;
		}
		
		override protected function initListeners():void
		{
			// 模块消息
			addMessageListener(NPCActionType.NA_53, spyTime);
			
			// 服务端消息
			addSocketListener(SocketCommand.SPY_FACTION, spyFactionToc);
			addSocketListener(SocketCommand.SPY_FACTION_TIME, spyFactionTimeToc);
			addSocketListener(SocketCommand.SPY_TIME, spyTimeToc)
		}
		
		// 国探剩余时间
		private function spyFactionTimeToc(vo:m_spy_faction_time_toc):void
		{
			// 显示剩余时间
			if (!spyFactionTime)
				spyFactionTime = new SpyFactionTimeView;
			
			spyFactionTime.reset(vo.remain_time);
		}
		
		// 打开发布国探面版
		private function spyTime(link:NpcLinkVO):void
		{			
			if (!_spyFactionPanel) {
				_spyFactionPanel = new SpyPanel;
			}
			WindowManager.getInstance().popUpWindow(_spyFactionPanel);
			
			var vo:m_spy_time_tos = new m_spy_time_tos;
			vo.request_type = 1;
			sendSocketMessage(vo);
		}
		
		/**
		 * 修改国探时间_toc
		 */
		
		private function spyTimeToc(vo:m_spy_time_toc):void
		{
			if (!vo.succ) {
				BroadcastSelf.logger(vo.reason);
				return;
			}
			
			_spyFactionPanel.setData(vo);
		}
		
		/**
		 * 修改国探时间_tos
		 */
		
		public function spyTimeTos($startHour:String, $startMin:String):void
		{
			if ($startHour == "") {
				BroadcastSelf.logger("输入的小时为空");
				return;
			}
			
			if ($startMin == "") {
				BroadcastSelf.logger("输入的分钟为空");
				return;
			}
			
			var startHourInt:int = int($startHour);
			var startMinInt:int = int($startMin);
			
			if (startHourInt >= 24 || startHourInt < 0) {
				BroadcastSelf.logger("输入的小时大于等于24或小于0");
				return;
			}
			
			if (startHourInt < 12) {
				BroadcastSelf.logger("国探时间只能设在12:00-24:00");
				return;
			}
			
			if  (startMinInt >= 60 || startMinInt < 0) {
				BroadcastSelf.logger("输入的分钟大于等于60或小于0");
				return;
			}
			
			var notice:String = "确定要把默认国探时间修改为" + startHourInt + ":" + _spyFactionPanel.minInt2Str(startMinInt) + "点吗？\n注意：国运、国探、国战不可同时进行";
			Alert.show(notice, "提示", yesHandler);
			
			function yesHandler():void
			{
				var vo:m_spy_time_tos = new m_spy_time_tos;
				vo.start_hour = startHourInt;
				vo.start_min = startMinInt;
				vo.request_type = 2;
				sendSocketMessage(vo);
			}
		}
		
		// 开启国探
		public function spyFactionTos():void
		{
			Alert.show("确定立即开启国探？", "提示", onYes, null);
			
			function onYes():void
			{
				sendSocketMessage(new m_spy_faction_tos);
			}
		}
		
		// 开启国探返回
		private function spyFactionToc(vo:m_spy_faction_toc):void
		{
			if (vo.succ) {
				if (vo.return_self) {
					BroadcastSelf.logger("开启国探成功");
					return;
				}
				
				var factionId:int = GlobalObjectManager.getInstance().user.base.faction_id;
				var factionName:String = getFactionName(vo.faction_id);
				var msg:String;
				
				// 显示剩余时间
				if (!spyFactionTime)
					spyFactionTime = new SpyFactionTimeView;
				
				spyFactionTime.reset(vo.remain_time);
				
				BroadcastView.getInstance().addBroadcastMsg("我国国探开始了，请国民赶紧到京城-冯胜处领取刺探军情任务，参与国探");
				
				// 弹出卷轴
				if (GlobalObjectManager.getInstance().user.attr.level < 35)
					return;
				
				spyFactionVo = vo;
				MessageIconManager.getInstance().removeSpyFactionIcon();
				MessageIconManager.getInstance().showSpyFactionIcon();
				
				return;
			}
			
			BroadcastSelf.logger(vo.reason);
		}
		
		/**
		 * 发送到综合频道
		 */
		
		private function sendToWorldChannel(msg:String):void
		{
			msg = msg.split("<br>").join("");
			msg = msg.split("\\n").join("");
			msg = "【系】<font color='#ffffff'>" + msg + "</font>";
			
			//sendToModule(ModuleConstant.CHAT_APPEND_MSG, {msg:msg, role:null, channel:ChatType.WORLD_CHANNEL}, ModelConstant.CHAT_MODE);
		}
		
		/**
		 * 根据ID获取国家名
		 */
		
		private function getFactionName(faction_id:int):String
		{
			if (faction_id == 1)
				return "<font color=\"#00FF00\">云州</font>";
			
			if (faction_id == 2)
				return "<font color=\"#FC00FF\">沧州</font>";
			
			return "<font color=\"#00AEFF\">幽州</font>";
		}
		
	}
}

