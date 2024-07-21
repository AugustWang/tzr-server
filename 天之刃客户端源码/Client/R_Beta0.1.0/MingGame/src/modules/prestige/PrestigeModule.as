package modules.prestige
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.loaders.ViewLoader;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.prestige.views.PrestigeExChangePanel;
	
	import proto.line.m_prestige_deal_toc;
	import proto.line.m_prestige_deal_tos;
	import proto.line.m_prestige_query_toc;
	import proto.line.m_prestige_query_tos;
	
	public class PrestigeModule extends BaseModule
	{
		private var prestigePanel:PrestigeExChangePanel;
		public function PrestigeModule()
		{
			super();
		}
		
		private static var _instance:PrestigeModule;
		public static function getInstance():PrestigeModule{
			if(_instance == null){
				_instance = new PrestigeModule();
			}	
			return _instance;
		}
		
		override protected function initListeners():void{
			addSocketListener(SocketCommand.PRESTIGE_QUERY,onQueryPrestige);
			addSocketListener(SocketCommand.PRESTIGE_DEAL,onDealPrestige);
			addMessageListener(ModuleCommand.OPEN_PRESTIGE_PANEL,openPresitgeExChangePanel);
		}
		
		public function openPresitgeExChangePanel():void{
			if(!ViewLoader.hasLoaded(GameConfig.CREDIT_UI)){
				ViewLoader.load(GameConfig.CREDIT_UI,openPresitgeExChangePanel);
				return;
			}
			if(prestigePanel == null){
				prestigePanel = new PrestigeExChangePanel();
			}
			prestigePanel.centerOpen();
		}
		/**
		 * 查询可兑换物品数据 
		 * @param group_id
		 * @param class_id
		 * 
		 */		
		public function queryPrestige(group_id:int,class_id:int):void{
			var vo:m_prestige_query_tos = new m_prestige_query_tos();
			vo.group_id = group_id;
			vo.class_id = class_id;
			vo.op_type = 1;
			sendSocketMessage(vo);
		}
		/**
		 * 兑换物品 
		 * @param group_id
		 * @param class_id
		 * @param key
		 * 
		 */		
		public function dealPrestige(group_id:int,class_id:int,key:int):void{
			var vo:m_prestige_deal_tos = new m_prestige_deal_tos();
			vo.class_id = class_id;
			vo.group_id = group_id;
			vo.key = key;
			vo.number = 1;
			sendSocketMessage(vo);
		}
		
		/**
		 * 返回可兑换物品数据 
		 * @param vo
		 * 
		 */		
		private function onQueryPrestige(vo:m_prestige_query_toc):void{
			if(vo.succ){
				if(prestigePanel){
					prestigePanel.dataProviders = vo.item_list;
				}
			}else{
				if(prestigePanel){
					prestigePanel.removeDataLoading();
				}
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		/**
		 * 兑换物品返回 
		 * @param vo
		 * 
		 */		
		private function onDealPrestige(vo:m_prestige_deal_toc):void{
			if(vo.succ){
				GlobalObjectManager.getInstance().user.attr.cur_prestige = vo.cur_prestige;
				dispatch(ModuleCommand.PRESTIGE_CHANGED);
				if(prestigePanel){
					prestigePanel.updatePrestige();
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
	}
}