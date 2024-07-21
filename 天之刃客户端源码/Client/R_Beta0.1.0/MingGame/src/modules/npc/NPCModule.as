package modules.npc {
	import com.common.GlobalObjectManager;
	import com.loaders.CommonLocator;
	import com.scene.sceneManager.NPCTeamManager;
	import com.scene.sceneUnit.NPC;
	import com.scene.sceneUtils.ScenePtMath;
	
	import flash.utils.Dictionary;
	
	import modules.Activity.ActivityModule;
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.driver.DriverConstant;
	import modules.driver.DriverDataManager;
	import modules.driver.vo.DriverDataIndex;
	import modules.duplicate.DuplicateModule;
	import modules.family.FamilyLocator;
	import modules.mission.MissionConstant;
	import modules.mission.MissionDataManager;
	import modules.mission.MissionModule;
	import modules.mission.vo.MissionVO;
	import modules.npc.views.NPCPanel;
	import modules.npc.vo.NPCPannelVO;
	import modules.npc.vo.NpcLinkVO;
	import modules.personalybc.PersonalYbcModule;
	import modules.scene.SceneDataManager;
	import modules.sceneWarFb.SceneWarFbModule;

	/**
	 * 负责NPC对话模块与其它模块和后台进行通信
	 * @author Administrator
	 *
	 */
	public class NPCModule extends BaseModule {
		public function NPCModule(_singleton:singleton) {
			if (_singleton) {
				super();
			} else {
				throw new Error("NPCModule Singleton.");
			}
		}

		private static var instance:NPCModule;

		public static function getInstance():NPCModule {
			if (instance == null) {
				instance=new NPCModule(new singleton());
			}
			return instance;
		}

		/**
		 * 初始化任务需要的侦听器
		 */
		override protected function initListeners():void {
			addMessageListener(ModuleCommand.ENTER_GAME, this.enterGameHandler);
			addMessageListener(ModuleCommand.OPEN_NPC_PANNEL, this.openNPCPannel);
			addMessageListener(NPCActionType.NA_0, this.testNPCAction);
		}

		private function testNPCAction(npcObj:Object):void {
			trace('ok');
		}

		/**
		 * 检查NPC是否在附近
		 */
		public function checkNPCNearby(npcID:int, allowDis:int=8):Boolean {
			var npc:NPC=NPCTeamManager.getNPC(npcID);
			if (!npc) {
				return false;
			}
			var dis:int=ScenePtMath.checkDistance(npc.index, SceneDataManager.getMyPostion().pt);
			if (dis <= allowDis) {
				return true;
			}

			return false;
		}

		public function get view():NPCPanel {
			if (!_npcPannel) {
				_npcPannel=new NPCPanel();
			}
			return _npcPannel;
		}

		/**
		 * 是否有功能
		 */
		public function hasAction(npcID:int):Boolean {
			var npcPannelVO:NPCPannelVO = this.getNPCPannelVO(npcID);
			if(npcPannelVO.actionLinks.length > 0){
				return true;
			}
			return false;
		}

		/**
		 * 是否有任务在身上
		 */
		public function hasMission(npcID:*):Boolean {
			if(MissionDataManager.getInstance().getNpcMissionList(npcID)){
				return true;
			}
			
			return false;
		}

		private var _npcPannel:NPCPanel;

		public function openNPCPannel(npcID:int):void {
//			var svo:SeletedRoleVo=new SeletedRoleVo;
//			var npcVO:Object = NPCDataManager.getInstance().getNpcInfo(npcID);
//			svo.setupNPC(npcVO);
//			this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: true, vo: svo});
			//优先显示玩家任务
			if (npcID == int("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100102")) {
				PersonalYbcModule.getInstance().doRequestInfo();
			}
			if (MissionModule.getInstance().autoShowOneMission(npcID) == true) {
				return;
			} else {
				var shituFBNPCID:Array=[11100131, 12100131, 13100131, 10600100];
				var accumulateExpNpcID:Array = [11100134, 12100134, 13100134];
				if (shituFBNPCID.indexOf(npcID) != -1) {
					//师徒副本NPC入口和出口NPC对话
					DuplicateModule.getInstance().doMouseClickNpc(npcID);
					return;
				} else if (SceneWarFbModule.getInstance().isSceneWarFbNpc(npcID)) {
					SceneWarFbModule.getInstance().doMouseClickNpc(npcID);
					return;
				} 
//				else if (accumulateExpNpcID.indexOf(npcID) > -1) {
//					//ActivityModule.getInstance().openActivityWin(6);
//					AccumulateExpModule.getInstace().clickNpc();
//					return;
//				}

				view.vo=this.getNPCPannelVO(npcID);
				view.open();
			}
		}

		public function getNPCPannelVO(npcID:int):NPCPannelVO {
			
			var npcObj:Object=NPCDataManager.getInstance().getNpcInfo(npcID);
			var npcPannelVO:NPCPannelVO=new NPCPannelVO();
			
			npcPannelVO.npcId=npcID;
			npcPannelVO.npcName=npcObj.name;
			npcPannelVO.content=npcObj.name + "：<br>        " + npcObj.content;
			
			npcPannelVO.actionLinks=new Vector.<NpcLinkVO>();
			npcPannelVO.missionLinks=new Vector.<NpcLinkVO>();
			
			var npcMissions:Object=MissionDataManager.getInstance().getNpcMissionList(npcID);
			var npcMissionIDList:Array=MissionDataManager.getInstance().getNpcMissionIDListSorted(npcID);
			var missionICONStyle:Object={};
			missionICONStyle[MissionConstant.STATUS_ACCEPT]=NPCConstant.LINK_ICON_STYLE_MISSION_ACCEPT;
			missionICONStyle[MissionConstant.STATUS_NEXT]=NPCConstant.LINK_ICON_STYLE_MISSION_NEXT;
			missionICONStyle[MissionConstant.STATUS_FINISH]=NPCConstant.LINK_ICON_STYLE_MISSION_FINISH;
			
			for each (var missionID:int in npcMissionIDList) {
				var missionVO:MissionVO=npcMissions[missionID];
				var missionLink:NpcLinkVO=new NpcLinkVO();
				missionLink.npcID=npcID;
				missionLink.linkName=missionVO.followTitle;
				missionLink.dispatchMessage=ModuleCommand.NPC_CLICK_MISSION_LINK;
				missionLink.data=missionVO;
				missionLink.iconStyle=missionICONStyle[missionVO.currentStatus];
				npcPannelVO.missionLinks.push(missionLink);
			}
			
			var roleLevel:int=GlobalObjectManager.getInstance().user.attr.level;
			if(roleLevel < 9){
				return npcPannelVO;
			}
			
			var npcActionArr:Array=NPCDataManager.getInstance().getNPCActionArr(npcID);
			for each (var npcAction:Array in npcActionArr) {
				var actionLink:NpcLinkVO=new NpcLinkVO();
				actionLink.npcID=npcID;
				//这里判断是否是个人拉镖，如果是，要显示个人拉镖需要的银子   43是个人拉镖，45是国运拉镖不需要显示银子    82和83是门派拉镖
				var actionID:String = npcAction[NPCDataManager.NPC_ACTION_ID_INDEX];
				if(actionID == "43" || actionID == "82" || actionID == "83")
				{
					actionLink.linkName=npcAction[NPCDataManager.NPC_ACTION_NAME_INDEX] + needGold(actionID);
				}else{
					actionLink.linkName=npcAction[NPCDataManager.NPC_ACTION_NAME_INDEX];
				}
				actionLink.dispatchMessage=NPCConstant.NPC_ACTION_PREFIX + actionID;
				actionLink.data=npcObj;
				actionLink.iconStyle=NPCConstant.LINK_ICON_STYLE_ACTION;
				npcPannelVO.actionLinks.push(actionLink);
			}
			
			var npcDriverList:Dictionary=DriverDataManager.getInstance().getNPCDriverList(npcID);
			var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			
			for each (var driverTarget:Dictionary in npcDriverList) {
				
				var showFaction:int=driverTarget.show_faction;
				if (showFaction != 0 && showFaction != roleFaction) {
					continue;
				}
				
				//判断
				if (DriverConstant.FAMILY_TRANS_ID.indexOf(driverTarget.id) != -1) {
					if (GlobalObjectManager.getInstance().getFamilyID() > 0) {
						if (!FamilyLocator.getInstance().familyInfo.enable_map) {
							continue;
						}
					} else {
						continue;
					}
				}
				
				var abledDriverData:Array=null;
				var unabledDriverData:Array=null;
				for each (var driverData:Array in driverTarget.data) {
					var minLV:int=driverData[DriverDataIndex.DRIVER_TARGET_DATA_MIN_LEVEL];
					var maxLV:int=driverData[DriverDataIndex.DRIVER_TARGET_DATA_MAX_LEVEL];
					var abled:Boolean=driverData[DriverDataIndex.DRIVER_TARGET_DATA_ABLED];
					if (roleLevel >= minLV && roleLevel <= maxLV) {
						if (abled == true) {
							abledDriverData=driverData;
							break;
						} else {
							unabledDriverData=driverData;
							break;
						}
					}
				}
				
				var driverLink:NpcLinkVO=new NpcLinkVO();
				driverLink.npcID=npcID;
				
				var driverTips:String='';
				if (abledDriverData) {
					if (abledDriverData[DriverDataIndex.DRIVER_TARGET_DATA_COST_DES] > 0) {
						driverTips='（' + abledDriverData[DriverDataIndex.DRIVER_TARGET_DATA_COST_DES] + '）';
					}
				} else if (unabledDriverData) {
					var maxLVTips:int=unabledDriverData[DriverDataIndex.DRIVER_TARGET_DATA_MAX_LEVEL] + 1;
					driverTips='（' + maxLVTips + '级以上）';
				}
				
				driverLink.linkName=driverTarget.name + driverTips;
				driverLink.dispatchMessage=ModuleCommand.NPC_DRIVER_LINK_CLICK;
				driverLink.data=[driverTarget.id, abledDriverData, unabledDriverData];
				driverLink.iconStyle=NPCConstant.LINK_ICON_STYLE_ACTION;
				npcPannelVO.actionLinks.push(driverLink);
			}
			
			return npcPannelVO;
		}
		
		/**
		 * 进入游戏时调用
		 */
		private function enterGameHandler():void {
			trace('NPCModule enterGame');
		}
		
		/*
		 * 通过级数获取当前个人拉镖需要的银子
		*/
		private function needGold(actionID:String):String
		{
			//当前玩家的级数
			var currentLV:int = GlobalObjectManager.getInstance().user.attr.level;
			//xml数据
			var data:XML;
			//该级数需要的银两数目，是绑定的还是不绑定的
			var silver:String="";
			var result:XML;
			switch(actionID)
			{
				//个人拉镖
				case "43":
					data = CommonLocator.getXML(CommonLocator.YBC_PERSON_COST);
					if( data.ybc_person_cost.(hasOwnProperty('@lv')))
					{
						result = data.ybc_person_cost.(@lv == currentLV.toString())[0] as XML;
						if ( result != null ) {
							var bsilber:String=result.@bsilver;
							if ( bsilber == "0" ) {
								silver="( " + result.@silver + ")";
							} else {
								silver="( " + bsilber + ")";
							}
						} else {
							silver="(需20级)";
						}
					}
					break;
				//国运拉镖
				case "45":
					break;
				//门派拉镖
				case "82":
					data = CommonLocator.getXML(CommonLocator.FAMILY_YBC);
					if( data.ybc.(hasOwnProperty("@lv")))
					{
						result=data.ybc.( @lv == currentLV.toString())[ 0 ] as XML;
						if ( result != null ) {
							silver="(" + result.@common + ")";
						} else {
							silver="(需要25级)";
						}
					}
					break;
				case "83":
					data = CommonLocator.getXML(CommonLocator.FAMILY_YBC);
					if( data.ybc.(hasOwnProperty("@lv")))
					{
						result=data.ybc.( @lv == currentLV.toString())[ 0 ] as XML;
						if ( result != null ) {
							silver="(" + result.@advance + ")";
						} else {
							silver="(需要25级)";
						}
					}
					break;
			}
			return silver;
		}
	}
}

class singleton {
}