package com.utils {
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	import com.scene.GameScene;
	import com.scene.WorldManager;
	import com.scene.sceneData.HandlerAction;
	import com.scene.sceneData.RunVo;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.Collection;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.sceneUtils.SceneUnitSearcher;
	import com.scene.tile.Pt;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.collect.CollectModule;
	import modules.family.FamilyLocator;
	import modules.mission.MissionModule;
	import modules.npc.NPCConstant;
	import modules.npc.NPCDataManager;
	import modules.npc.NPCModule;
	import modules.playerGuide.GuideConstant;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.scene.cases.MapCase;
	import modules.trading.TradingModule;

	public class PathUtil {
		public static const MAP_TRANSFER_TYPE_NORMAL:int=0;
		public static const MAP_TRANSFER_TYPE_VIP:int=1;

		public function PathUtil() {
		}

		public static function findMonsterAndAttack(mapID:int, monsterTypeID:int, runType:String=''):void {
			if (runType == '') {
				runType=RunVo.RUN_TYPE_NORMAL;
			}
			var x:int;
			var y:int;
			var typePT:Pt=MonsterConfig.getMonsterPos(mapID, monsterTypeID);
			if (typePT) {
				x=typePT.x;
				y=typePT.z;
			}


			var index:Pt=SceneUnitManager.getSelf().index;
			var monsterData:Monster=SceneUnitSearcher.searchMonsterByType(index, monsterTypeID);
			if (monsterData) {
				mapID=monsterData.pvo.mapid;
				x=monsterData.pvo.pos.tx;
				y=monsterData.pvo.pos.ty;
			}

			if (dealSpecialMonsterSearchWay(mapID) == true) {
				return;
			}

			var pt:Pt=ScenePtMath.getNearPt(new Pt(x, 0, y), 5, false, false);
			if (SceneDataManager.isSubMap()) {
				BroadcastSelf.logger("在副本地图中不能自动寻路！");
				return;
			}
			if (SceneDataManager.isRobKingMap) {
				BroadcastSelf.logger("在王座争霸战地图中不能自动寻路！");
				return;
			}
			var currentMapId:int=SceneDataManager.mapData.map_id;
			var vo:RunVo=new RunVo();
			vo.mapid=mapID;
			vo.type=runType;
			var toPt:Pt;
			if (mapID != currentMapId) {
				toPt=pt;
			} else {
				toPt=ScenePtMath.getFrontPt(pt, 1);
			}
			vo.pt=toPt;
			vo.action=new HandlerAction(SceneModule.getInstance().toHitMonsterByType, [monsterTypeID]);
			Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, vo);
		}

		public static function findCollectAndTake(collectType:int, mapID:int, x:int, y:int, runType:String=''):void {
			if (runType == '') {
				runType=RunVo.RUN_TYPE_NORMAL;
			}

			//如果已经在采了 还寻你妹啊
			if (CollectModule.getInstance().isCollectIng == true) {
				return;
			}

			if (dealSpecialCollectSearchWay(mapID) == true) {
				return;
			}

			var index:Pt=SceneUnitManager.getSelf().index;
			var collectData:Collection=SceneUnitSearcher.searchCollectionByType(index, collectType);
			if (collectData) {
				x=collectData.pvo.pos.tx;
				y=collectData.pvo.pos.ty;
			}

			var pt:Pt=new Pt(x, 0, y)
			if (SceneDataManager.isSubMap()) {
				BroadcastSelf.logger("在副本地图中不能自动寻路！");
				return;
			}
			if (SceneDataManager.isRobKingMap) {
				BroadcastSelf.logger("在王座争霸战地图中不能自动寻路！");
				return;
			}
			var currentMapId:int=SceneDataManager.mapData.map_id;
			var vo:RunVo=new RunVo();
			vo.mapid=mapID;
			vo.type=runType;
			var toPt:Pt;
			if (mapID != currentMapId) {
				toPt=pt;
			} else {
				toPt=ScenePtMath.getFrontPt(pt, 1);
			}
			vo.pt=toPt;
			vo.action=new HandlerAction(SceneModule.getInstance().toTakeCollectByType, [collectType]);
			Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, vo);
		}

		public static function findNpcAndDO(npcID:*, fun:Function, runType:String=''):void {
			if (runType == '') {
				runType=RunVo.RUN_TYPE_NORMAL;
			}

			npcID=parseInt(npcID);

			if (PathUtil.dealSpecialNPCSearchWay(npcID) == true) {
				return;
			}

			var npcPos:Array=NPCDataManager.getInstance().getPos(npcID);
			var npcInfo:Object=NPCDataManager.getInstance().getNpcInfo(npcID);

			var pt:Pt=new Pt(npcPos[1], 0, npcPos[2]);
			var vo:RunVo=new RunVo;
			vo.cut = 3;
			vo.mapid=npcPos[0];
			vo.type=runType;
			vo.pt=pt;
			vo.action=new HandlerAction(fun);
			Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, vo);
		}


		/**
		 * 找到NPC并打开面板
		 * @param npcID
		 * @param runType 寻路类型 默认是普通(会收到僵硬时间限制)
		 * @param replaceToMyFaction 是否严格检查并把npcID限制为本国NPC
		 * @param isCloseWelcome 是否是关闭欢迎窗口后的寻路
		 *
		 */
		public static function findNpcAndOpen(npcID:*, runType:String='', replaceToMyFaction:Boolean=false, isCloseWelcome:Boolean=false):void {
			if (runType == '') {
				runType=RunVo.RUN_TYPE_NORMAL;
			}


			if (npcID == 0 || npcID == '0') {
				return;
			}

			//如果是严格的替换NPC国家的话 则进行字符串复制 并把NPC的国家限制为角色的NPC
			if (replaceToMyFaction == true) {
				var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
				var npcStr:String=npcID.toString();
				npcID=npcStr.substr(0, 1) + roleFaction + npcStr.substr(2, (npcStr.length - 2));
			}

			npcID=parseInt(npcID);

			if (PathUtil.dealSpecialNPCSearchWay(npcID) == true) {
				return;
			}

			if (NPCModule.getInstance().checkNPCNearby(npcID) == true) {
				if (isCloseWelcome) {
					MissionModule.getInstance().autoShowOneMission(npcID);
				} else {
					NPCModule.getInstance().openNPCPannel(npcID);
				}

				return;
			}

			var npcPos:Array=NPCDataManager.getInstance().getPos(npcID);
			var npcInfo:Object=NPCDataManager.getInstance().getNpcInfo(npcID);
			if (npcInfo.canSearchWay == false) {
				BroadcastSelf.getInstance().appendMsg('不能寻路到该NPC。');
				return;
			}
			var npcPt:Pt=new Pt(npcPos[1], 0, npcPos[2]);
			if (npcPos[0] == SceneDataManager.mapID && ScenePtMath.checkDistance(SceneDataManager.getMyPostion().pt, npcPt) <= 8) {
				arrivedAtNPC(npcID, npcPt);
			} else {
				var pt:Pt=npcPt;
				var vo:RunVo=new RunVo;
				vo.cut = 3;
				vo.mapid=npcPos[0];
				vo.type=runType;
				vo.pt=pt;
				
				vo.action=new HandlerAction(arrivedAtNPC, [npcID, npcPt]);
				Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, vo);
			}
		}
		//目前只在场景副本中使用
		public static function findNpcAndOpenIgnoreScene(npcID:*, runType:String='', replaceToMyFaction:Boolean=false, isCloseWelcome:Boolean=false):void {
			var npcPos:Array=NPCDataManager.getInstance().getPos(npcID);
			var npcInfo:Object=NPCDataManager.getInstance().getNpcInfo(npcID);
			if (npcInfo.canSearchWay == false) {
				BroadcastSelf.getInstance().appendMsg('不能寻路到该NPC。');
				return;
			}
			var npcPt:Pt=new Pt(npcPos[1], 0, npcPos[2]);
			if (npcPos[0] == SceneDataManager.mapID && ScenePtMath.checkDistance(SceneDataManager.getMyPostion().pt, npcPt) <= 8) {
				arrivedAtNPC(npcID, npcPt);
			} else {
				var pt:Pt=npcPt;
				var vo:RunVo=new RunVo;
				vo.cut = 3;
				vo.mapid=npcPos[0];
				vo.type=runType;
				vo.pt=pt;
				
				vo.action=new HandlerAction(arrivedAtNPC, [npcID, npcPt]);
				Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, vo);
			}
		}
		
		
		private static function arrivedAtNPC(npcID:int, pt:Pt):void {
			var hero:MyRole=SceneUnitManager.getSelf();
			if (hero && hero.pvo.state != RoleActState.TRAINING) {
				var dir:int=ScenePtMath.getDretion(hero.index, pt);
				hero.turnDir(dir);
			}
			Dispatch.dispatch(ModuleCommand.OPEN_NPC_PANNEL, npcID);
		}

		/**
		 * 寻路到目标点
		 */
		public static function goto(mapID:int, pt:Pt, runType:String=''):void {
			if (runType == '') {
				runType=RunVo.RUN_TYPE_NORMAL;
			}

			if (mapID != SceneDataManager.mapData.map_id) {
				if (SceneDataManager.isSubMap()) {
					BroadcastSelf.logger("在副本地图中不能自动寻路！");
					return;
				}
				if (SceneDataManager.isRobKingMap) {
					BroadcastSelf.logger("在王座争霸战地图中不能自动寻路！");
					return;
				}
			}
			var vo:RunVo=new RunVo;
			vo.mapid=mapID;
			vo.pt=pt;
			vo.type=runType;
			Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, vo);
		}

		/**
		 * 消耗传送卷到目标点
		 */
		public static function carry(mapID:int, pt:Pt, changeType:int=0, errorMsg:String="已经在目标点的范围内了，不需要传送。", range:int=8):void {
			if (mapID != SceneDataManager.mapData.map_id) {
				if (SceneDataManager.isSubMap()) {
					BroadcastSelf.logger("在副本地图中不能进行地图跳转！");
					return;
				}
				if (SceneDataManager.isRobKingMap) {
					BroadcastSelf.logger("在王座争霸战地图中不能进行地图跳转！");
					return;
				}
			}
			var currentMapId:int=SceneDataManager.mapData.map_id;
			var hero:MyRole=GameScene.getInstance().hero;
			var d:int=ScenePtMath.checkDistance(hero.index, pt);
			if (d <= range && currentMapId == mapID) {
				Tips.getInstance().addTipsMsg(errorMsg);
				return;
			}
			MapCase.getInstance().onTransferTos(mapID, pt, changeType);
		}

		/**
		 * 传送到NPC附近
		 */
		public static function carryToNPC(npcID:*):void {
			var npcPos:Array=NPCDataManager.getInstance().getPos(npcID);
			if (npcPos) {
				carry(npcPos[0], new Pt(npcPos[1], 0, npcPos[2]));
			}
		}

		/**
		 *  寻路到目标NPC
		 */
		public static function findNPC(npcID:String, runType:String=''):void {
			if (runType == '') {
				runType=RunVo.RUN_TYPE_NORMAL;
			}

			var npcPos:Array=NPCDataManager.getInstance().getPos(npcID);
			if (npcPos) {
				goto(npcPos[0], new Pt(npcPos[1], 0, npcPos[2]), runType);
			}
		}


		/**
		 *  跳转到到目标NPC
		 */
		public static function carryNPC(npcID:String, isVIP:Boolean=false, errorMsg:String="已经在目标点的范围内了，不需要传送。"):void {

			if (TradingModule.getInstance().getBeginBill() > 0) {
				Tips.getInstance().addTipsMsg("您正在跑商，无法使用传送卷。");
				return;
			}

			if (npcID == "10300102") {
				//门派长老，则先寻路到门派管理员
				if (SceneDataManager.mapData.map_id != 10300 ) {

					var toNpcId:int=PathUtil.getNpcFamilyFbTransfer();
					PathUtil.carryNPC(toNpcId.toString(),isVIP,errorMsg);
					
					dealWithFamilyMaster(toNpcId);
					
					
					return;
				}
			}

			var npcPos:Array=NPCDataManager.getInstance().getPos(npcID);
			if (npcPos) {
				if (isVIP) {
					carry(npcPos[0], new Pt(npcPos[1], 0, npcPos[2]), PathUtil.MAP_TRANSFER_TYPE_VIP);
				} else {
					carry(npcPos[0], new Pt(npcPos[1], 0, npcPos[2]), PathUtil.MAP_TRANSFER_TYPE_NORMAL);
				}
			}
			
			Dispatch.dispatch(GuideConstant.CARRY_NPC);
		}

		/**
		 * 对门派长老寻路/传送的特殊处理
		 * @param toNpcId
		 *
		 */
		private static function dealWithFamilyMaster( toNpcId:int ):void {
			if ( FamilyLocator.getInstance().familyInfo.enable_map ) {
				BroadcastSelf.getInstance().appendMsg( "<font color='#ff0000'>找<font color='#00ff00'><a href='event:gotoNPC" +
					"#" + toNpcId + "'><u>门派管理员</u></a></font>传送到门派地图</font>" );
			} else {
				if ( FamilyLocator.getInstance().isFamilyOwner( GlobalObjectManager.getInstance().user.base.role_id )) {
					BroadcastSelf.getInstance().appendMsg( "<font color='#ff0000'>先找<font color='#00ff00'><a href='event:gotoNPC" +
						"#" + toNpcId + "'><u>门派管理员</u></a></font>创建门派地图，然后传送到门派地图</font>" );
				} else {
					BroadcastSelf.getInstance().appendMsg( "<font color='#ff0000'>先联系掌门<font color='#00ff00'>创建门派地图</font>，然后传送到门派地图</font>" );
				}
			}
		}
		
		/**
		 * 跳转到目标的怪物
		 */
		public static function carryMonster(mapID:int, monsterTypeID:int, isVIP:Boolean=false, runType:String=''):void {
			if (runType == '') {
				runType=RunVo.RUN_TYPE_NORMAL;
			}

			if (TradingModule.getInstance().getBeginBill() > 0) {
				Tips.getInstance().addTipsMsg("您正在跑商，无法使用传送卷。");
				return;
			}
			if (SceneDataManager.isSubMap()) {
				BroadcastSelf.logger("在副本地图中不能自动寻路！");
				return;
			}
			if (SceneDataManager.isRobKingMap) {
				BroadcastSelf.logger("在王座争霸战地图中不能自动寻路！");
				return;
			}

			//判断是否副本地图ID
			if( isSpecialMissionMapId(mapID) ){
				var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
				if( roleFaction>0 ){
					var transferNPCId:int = dictSpecialMissionMap[mapID][roleFaction];
					PathUtil.carryNPC(transferNPCId.toString(), isVIP);
					return;
				}
			}

			var monsterPOS:Array=MonsterConfig.getPos(mapID, monsterTypeID);
			var x:int=monsterPOS[0];
			var y:int=monsterPOS[1];

			var index:Pt=SceneUnitManager.getSelf().index;
			var monsterData:Monster=SceneUnitSearcher.searchMonsterByType(index, monsterTypeID);
			if (monsterData) {
				mapID=monsterData.pvo.mapid;
				x=monsterData.pvo.pos.tx;
				y=monsterData.pvo.pos.ty;
			}

			var pt:Pt=new Pt(x, 0, y)

			var currentMapId:int=SceneDataManager.mapData.map_id;
			var vo:RunVo=new RunVo();
			vo.mapid=mapID;
			vo.type=runType;
			var toPt:Pt;
			if (mapID != currentMapId) {
				toPt=pt;
			} else {
				toPt=ScenePtMath.getFrontPt(pt, 1);
			}

			if (isVIP) {
				carry(mapID, toPt, PathUtil.MAP_TRANSFER_TYPE_VIP);
			} else {
				carry(mapID, toPt, PathUtil.MAP_TRANSFER_TYPE_NORMAL);
			}
		}


		/**
		 * 跳转到目标的采集物
		 */
		public static function carryCollect(collectType:int, mapID:int, x:int, y:int, isVIP:Boolean=false, runType:String=''):void {
			if (runType == '') {
				runType=RunVo.RUN_TYPE_NORMAL;
			}

			//如果已经在采了 还寻你妹啊
			if (CollectModule.getInstance().isCollectIng == true) {
				return;
			}
			if (TradingModule.getInstance().getBeginBill() > 0) {
				Tips.getInstance().addTipsMsg("您正在跑商，无法使用传送卷。");
				return;
			}
			if (SceneDataManager.isSubMap()) {
				BroadcastSelf.logger("在副本地图中不能自动寻路！");
				return;
			}
			if (SceneDataManager.isRobKingMap) {
				BroadcastSelf.logger("在王座争霸战地图中不能自动寻路！");
				return;
			}

			var index:Pt=SceneUnitManager.getSelf().index;
			var collectData:Collection=SceneUnitSearcher.searchCollectionByType(index, collectType);
			if (collectData) {
				x=collectData.pvo.pos.tx;
				y=collectData.pvo.pos.ty;
			}

			var pt:Pt=new Pt(x, 0, y);
			var currentMapId:int=SceneDataManager.mapData.map_id;
			var vo:RunVo=new RunVo();
			vo.mapid=mapID;
			vo.type=runType;
			var toPt:Pt;
			if (mapID != currentMapId) {
				toPt=pt;
			} else {
				toPt=ScenePtMath.getFrontPt(pt, 1);
			}

			if (isVIP) {
				carry(mapID, toPt, PathUtil.MAP_TRANSFER_TYPE_VIP);
			} else {
				carry(mapID, toPt, PathUtil.MAP_TRANSFER_TYPE_NORMAL);
			}
		}


		/**
		 * 处理特殊NPC寻路
		 */
		private static function dealSpecialNPCSearchWay(npcID:int):Boolean {
			switch (npcID) {
				case 10300102: //门派长老的寻路
					if (PathUtil.isOutsideFaction() == true) {
						PathUtil.gotoKaiFengTips();
						return true;
					}

					var ncpFamilyFbTransfer:int=getNpcFamilyFbTransfer();

					if (NPCModule.getInstance().checkNPCNearby(ncpFamilyFbTransfer) == true) {
						Dispatch.dispatch(ModuleCommand.OPEN_NPC_PANNEL, ncpFamilyFbTransfer);
					} else {
						PathUtil.findNpcAndOpen(ncpFamilyFbTransfer);
					}
					
					dealWithFamilyMaster(ncpFamilyFbTransfer);
					
					return true;
					break;
				case 10302100: //第一个任务副本的NPC
					var currmapId:int=SceneDataManager.mapData.map_id;
					if( currmapId==10302 ){
						return false;
					}else{
						return true;
					}
					break;

				default:
					return PathUtil.checkIsSpecialSearchWay(npcID);
					break;
			}
		}

		/**
		 * 获得门派管理员的NPCID
		 */
		public static function getNpcFamilyFbTransfer():int {
			var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			//先寻路到门派管理员
			if (roleFaction == 1) {
				return 11100120;
			} else if (roleFaction == 2) {
				return 12100120;
			} else {
				return 13100120;
			}
		}
		
		private static var dictSpecialMissionMap:Object = {
			//大明英雄副本(普通)
			10801:{1:11100133,2:12100133,3:13100133},
			//鄱阳湖副本(普通)
			10902:{1:11100135,2:12100135,3:13100135},
			//两个任务副本
			10302:{1:11000115,2:12000115,3:13000115},
			10303:{1:11001109,2:12001109,3:13001109}
		}
		
		/**
		 * 判断是否是特殊的任务地图ID 
		 */		
		private static function isSpecialMissionMapId( mapID:int ):Boolean {
			return dictSpecialMissionMap[mapID] != null;
		}

		/**
		 * 处理怪物特殊地图寻路
		 */
		private static function dealSpecialMonsterSearchWay(mapID:int):Boolean {
			
			if( isSpecialMissionMapId(mapID) ){
				if (PathUtil.isOutsideFaction() == true) {
					PathUtil.gotoKaiFengTips();
					return true;
				}
				
				var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
				if( roleFaction>0 ){
					var transferNPCId:int = dictSpecialMissionMap[mapID][roleFaction];
					if (NPCModule.getInstance().checkNPCNearby(transferNPCId) == true) {
						Dispatch.dispatch(ModuleCommand.OPEN_NPC_PANNEL, transferNPCId);
					} else {
						PathUtil.findNpcAndOpen(transferNPCId);
					}
				}
				return true;
				
			}else{
				return PathUtil.checkIsSpecialSearchWay(mapID);
			}
		}
		

		/**
		 * 处理采集特殊地图寻路
		 */
		private static function dealSpecialCollectSearchWay(mapID:int):Boolean {
			return PathUtil.checkIsSpecialSearchWay(mapID);
		}

		/**
		 * 是否是中立区
		 */
		private static function isNeutralZone(mapID_NPCID:*):Boolean {
			var type:String=mapID_NPCID.toString().substr(0, 3);
			if (type == '102') {
				return true;
			} else {
				return false;
			}
		}

		/**
		 * 是否是在国外
		 */
		private static function isOutsideFaction():Boolean {
			var currentMapID:int=SceneDataManager.mapData.map_id;
			if (PathUtil.isNeutralZone(currentMapID) == true) {
				return false;
			}

			var currentMapFaction:int=parseInt(currentMapID.toString().substr(1, 1));
			var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;

			return roleFaction != currentMapFaction;
		}

		/**
		 * 判断不是自己国家
		 */
		private static function notMyFaction(mapID_NPCID:*):Boolean {
			var gotoFaction:int=parseInt(mapID_NPCID.toString().substr(1, 1));
			var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;

			if (gotoFaction != roleFaction) {
				return true;
			} else {
				return false;
			}
		}

		/**
		 * 判断是否能够寻路过去
		 */
		private static function canGoto(mapID_NPCID:*):Boolean {
			var type:String=mapID_NPCID.toString().substr(0, 3);
			var gotoFaction:int=parseInt(mapID_NPCID.toString().substr(1, 1));

			if (gotoFaction == 0 && type != '102' || SceneDataManager.isSubMap() || mapID_NPCID == 10300102 || mapID_NPCID == 10300) {
				return false;
			} else {
				return true;
			}
		}

		/**
		 * 判断要前往的国家是否正是角色当前所在国家
		 */
		private static function gotoFactionEqualCurrent(gotoMapID_NPCID:*):Boolean {
			var gotoFaction:int=parseInt(gotoMapID_NPCID.toString().substr(1, 1));
			var currentMapID:int=SceneDataManager.mapData.map_id;
			var currentMapFaction:int=parseInt(currentMapID.toString().substr(1, 1));
			return currentMapFaction == gotoFaction;
		}


		/**
		 * 检查是否是特殊寻路 如果返回true 则原来的寻路流程会被打断
		 */
		private static function checkIsSpecialSearchWay(gotoMapID_NPCID:*):Boolean {
			if (PathUtil.canGoto(gotoMapID_NPCID) == false) {
				BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">特殊场景不能寻路</font>');
				return true;
			}

			if (PathUtil.isNeutralZone(gotoMapID_NPCID) == true) {
				return false;
			}

			if (PathUtil.notMyFaction(gotoMapID_NPCID)) {
				if (!PathUtil.isOutsideFaction()) {
					PathUtil.gotoTransToOtherFaction(gotoMapID_NPCID);
					return true;
				}

				if (PathUtil.gotoFactionEqualCurrent(gotoMapID_NPCID)) {
					return false;
				}

				PathUtil.gotoKaiFengTips();
				return true;
			}

			if (PathUtil.isOutsideFaction()) {
				PathUtil.gotoKaiFengTips();
				return true;
			}

			return false;
		}

		/**
		 * 传送到其他国家
		 */
		private static function gotoTransToOtherFaction(gotoMapID_NPCID:*):void {
			var gotoMapID:int=parseInt(gotoMapID_NPCID.toString().substr(0, 5));
			var mapName:String=WorldManager.getMapName(gotoMapID);

			var npcID:int;
			var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			if (roleFaction == 1) {
				npcID=11105100;
			} else if (roleFaction == 2) {
				npcID=12105100;
			} else {
				npcID=13105100;
			}
			var npcObj:Object=NPCDataManager.getInstance().getNpcInfo(npcID);
			BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">找<font color="#39ff0b">' + npcObj.name + '</font>传送到敌国边城，再寻路到<font color="#00f0ff">' + mapName + '。</font></font>');
			PathUtil.findNpcAndOpen(npcID, RunVo.RUN_TYPE_ADVANCED);
		}

		/**
		 * 提示前往开封
		 */
		private static function gotoKaiFengTips():void {
			BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">你当前在国外，需要先回国。</font>');
			var kaifenPosName:String='<font color="#00f0ff">开封</font>';
			BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">进入' + kaifenPosName + '，通过车夫传送或“<font color="#00f0ff">各国</font>”通道回国。</font>');
			PathUtil.findNpcAndOpen(NPCConstant.NPC_KAI_FENG_CHE_FU_ID, RunVo.RUN_TYPE_ADVANCED);
		}
	}
}