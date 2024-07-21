package modules.countrytreasure {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.managers.LayerManager;
	import com.net.SocketCommand;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.tile.Pt;
	import com.utils.MoneyTransformUtil;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.countrytreasure.views.CountryPointsView;
	import modules.mission.MissionFBModule;
	import modules.npc.NPCActionType;
	import modules.npc.NPCDataManager;
	import modules.npc.vo.NpcLinkVO;
	import modules.scene.SceneDataManager;
	
	import proto.line.m_country_treasure_enter_toc;
	import proto.line.m_country_treasure_enter_tos;
	import proto.line.m_country_treasure_points_toc;
	import proto.line.m_country_treasure_query_toc;
	import proto.line.m_country_treasure_query_tos;
	import proto.line.m_country_treasure_quit_toc;
	import proto.line.m_country_treasure_quit_tos;

	/**
	 * 大明宝藏模块代码
	 * @author caochuncheng
	 *
	 */
	public class CountryTreasureModule extends BaseModule {
		private var countryPointList:CountryPointsView;
		private var timeoutId:int;

		public function CountryTreasureModule() {

		}
		private static var instance:CountryTreasureModule;

		public static function getInstance():CountryTreasureModule {
			if (!instance) {
				instance = new CountryTreasureModule();
			}
			return instance;
		}


		override protected function initListeners():void {
			addMessageListener(NPCActionType.NA_86,doEnterCountryTreasureTos);
			addMessageListener(NPCActionType.NA_23,doQuitCountryTreasureTos);
			addMessageListener(ModuleCommand.CHANGE_MAP,doChangeMap);
			addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);

			addSocketListener(SocketCommand.COUNTRY_TREASURE_ENTER,doEnterCountryTreasureToc);
			addSocketListener(SocketCommand.COUNTRY_TREASURE_QUIT,doQuitCountryTreasureToc);
			addSocketListener(SocketCommand.COUNTRY_TREASURE_POINTS,doCountryTreasurePointsToc);
            addSocketListener(SocketCommand.COUNTRY_TREASURE_QUERY,doQueryCountryTreasureToc);
		}
        
		private function onStageResize(value:Object):void
		{
			if (countryPointList)
				countryPointList.onStageResize();
		}

		private function doCountryTreasurePointsToc(vo:m_country_treasure_points_toc):void {
			if (countryPointList != null)
				countryPointList.update(vo);
		}
        
		private function doChangeMap(mapId:int):void {
			if (mapId == 10500) {
				showPointsPanel(true);
			} else {
				showPointsPanel(false);
			}
		}

		public function showPointsPanel(show:Boolean):void {
			if (show == true) {
				if (countryPointList == null)
					countryPointList = new CountryPointsView;

				LayerManager.uiLayer.addChild(countryPointList);
			} else {
				if (countryPointList != null && countryPointList.parent != null) {
					countryPointList.parent.removeChild(countryPointList);
				}
			}
		}

		private function doEnterCountryTreasureTos(npcLinkVO:NpcLinkVO):void {
			var npcObj:Object = npcLinkVO.data;
			var npcId:int = npcObj.id;
			var vo:m_country_treasure_enter_tos = new m_country_treasure_enter_tos;
			vo.npc_id = npcId;
			vo.map_id = SceneDataManager.mapData.map_id;
			sendSocketMessage(vo);
		}

		private function doEnterCountryTreasureToc(vo:m_country_treasure_enter_toc):void {
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("进入大明宝藏地图");
				BroadcastSelf.logger("进入大明宝藏地图，扣除路费1两银子");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		public function doQuitCountryTreasureTos(npcLinkVO:NpcLinkVO=null):void {
			var npcId:int;
			if (npcLinkVO) {
				var npcObj:Object = npcLinkVO.data;
			 	npcId = npcObj.id;
			} else npcId = 0;
			var vo:m_country_treasure_quit_tos = new m_country_treasure_quit_tos;
			vo.npc_id = npcId;
			vo.map_id = SceneDataManager.mapData.map_id;
			sendSocketMessage(vo);
		}

		private function doQuitCountryTreasureToc(vo:m_country_treasure_quit_toc):void {
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("离开大明宝藏地图");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
        private var bcQueryAlert:String = null;
        private function doQueryCountryTreasureToc(vo:m_country_treasure_query_toc):void{
            if(vo.succ && vo.op_type == 1){
				if (MissionFBModule.getInstance().isMapMisssionFB(SceneDataManager.mapData.map_id)
					|| SceneDataManager.mapData.map_id == 10500
					|| SceneDataManager.isSubMap()) {
					return;
				}
                //判断是不是已经在NPC附近了
                var npcId:int = vo.npc_id + GlobalObjectManager.getInstance().user.base.faction_id * 1000000;
                var npc:Object=NPCDataManager.getInstance().getPos(npcId);
                var bcStr:String = "大明宝藏已经开启，花费 <font color=\"#FFFF00\">" + MoneyTransformUtil.silverToOtherHtml(vo.fee) + "</font> 可以直接传送\n到“大明宝藏”地图里面。你确定传送吗？";
                if(npc[0] == SceneDataManager.mapData.map_id){
                    var d:int = ScenePtMath.checkDistance(new Pt(npc[1],0,npc[2]),SceneDataManager.getMyPostion().pt);
                    if (d > 20 && !Alert.isPopUp(bcQueryAlert) && GlobalObjectManager.getInstance().user.attr.level >= 20) {
                        bcQueryAlert = Alert.show(bcStr,"大明宝藏",doSendCountryTreasure,null,"传送","取消",null,true,false,null,null,false);
                    }
                }else{
	                if(GlobalObjectManager.getInstance().user.attr.level >= 20){
	                    bcQueryAlert = Alert.show(bcStr,"大明宝藏",doSendCountryTreasure,null,"传送","取消",null,true,false,null,null,false);
	                }
                }
                
            }else{
                if(vo.op_type == 2){
                    if(vo.succ){
                        BroadcastSelf.logger("传送成功，扣除路费" + MoneyTransformUtil.silverToOtherHtml(vo.fee) +"银子");
                    }else{
                        Tips.getInstance().addTipsMsg(vo.reason);
                    }
                }
            }
        }
        private function doSendCountryTreasure():void{
            var vo:m_country_treasure_query_tos = new m_country_treasure_query_tos;
            vo.op_type = 2;
            sendSocketMessage(vo);
        }
	}
}