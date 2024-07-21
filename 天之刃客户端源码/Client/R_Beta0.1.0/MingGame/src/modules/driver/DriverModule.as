package modules.driver
{
	import com.common.GlobalObjectManager;
	import com.loaders.CommonLocator;
	import com.net.SocketCommand;
	
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.driver.vo.DriverDataIndex;
	import modules.npc.vo.NpcLinkVO;
	
	import proto.line.m_driver_go_toc;
	import proto.line.m_driver_go_tos;
	
	/**
	 * 车夫模块
	 */
	public class DriverModule extends BaseModule
	{
		
		public function DriverModule(singletonObj:singleton)
		{
			if(singleton){
				super();
			}else{
				throw(new Error("MissionModule Singleton."));
			}
			
			this.loadConfig();
		}
		
		static private var _instance:DriverModule;
		static public function getInstance():DriverModule{
			if(!_instance){
				_instance = new DriverModule(new singleton());
			}
			
			return _instance;
		}
		
		/**
		 * 载入配置 drivers.xml
		 */
		private function loadConfig():void{
			var data:XML = CommonLocator.getXML(CommonLocator.DRIVERS);
			DriverDataManager.getInstance().initDriverData(data);
		}
		
		override protected function initListeners():void {
			addMessageListener(ModuleCommand.NPC_DRIVER_LINK_CLICK, this.onDriverLinkClick);
			addSocketListener(SocketCommand.DRIVER_GO, this.onDriverGOReturn);
		}
		
		/**
		 * 当车夫数据返回时
		 */
		private function onDriverGOReturn(vo:m_driver_go_toc):void{
			if(vo.succ == true && this._preDriverData){
				var cost:String = this._preDriverData[DriverDataIndex.DRIVER_TARGET_DATA_COST_DES];
				this._preDriverData = null;
				BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">使用车夫传送，消耗银子：'+cost+'</font>');
			}else{
				BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">'+vo.reason+'</font>');
			}
		}
		
		/**
		 * 当车夫链接点击时触发
		 */
		private var _preDriverData:Array;
		private function onDriverLinkClick(npcLinkVO:NpcLinkVO):void{
			//[driverTarget.id, abledDriverData, unabledDriverData];
			var data:Array = npcLinkVO.data as Array;
			
			var targetID:int = data.shift();
			this._preDriverData = data.shift();
			var unabledDriverData:Array = data.shift();
			var roleLevel:int = GlobalObjectManager.getInstance().user.attr.level;
			
			if(this._preDriverData == null){
				if(unabledDriverData != null){
					var maxLV:int = unabledDriverData[DriverDataIndex.DRIVER_TARGET_DATA_MAX_LEVEL]+1;
					if(roleLevel < maxLV){
						BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">你的等级小于：'+maxLV+'级，无法为你传送。</font>');
					}else{
						//不能出现这种情况的 出现了可能配置有问题
						BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">未满足传送条件，无法为你传送。</font>');
					}
				}
				return;
			}
			
			if (GlobalObjectManager.getInstance().user.base.pk_points >= 18) {
				BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">你当前处于红名状态，不能使用车夫传送</font>');
				return;
			}
			
			var cost:int = this._preDriverData[DriverDataIndex.DRIVER_TARGET_DATA_COST];
			var costDesc:String = this._preDriverData[DriverDataIndex.DRIVER_TARGET_DATA_COST_DES];
			var roleSilver:int = GlobalObjectManager.getInstance().user.attr.silver;
			var roleSilverBind:int = GlobalObjectManager.getInstance().user.attr.silver_bind;
			if(roleSilver + roleSilverBind < cost){
				BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">传送失败，需要银子：'+costDesc+'</font>');
				return;
			}
			var vo:m_driver_go_tos = new m_driver_go_tos();
			vo.id = targetID;
			vo.type = 1;//暂时没任何作用的
			sendSocketMessage(vo);
		}
	}
}
class singleton{}