package modules.playerGuide {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.net.connection.Connection;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.NPCTeamManager;
	import com.scene.sceneUnit.NPC;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	import com.scene.tile.Pt;
	import com.utils.HtmlUtil;
	import com.utils.PathUtil;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.flowers.FlowersBroacastManager;
	import modules.help.HelpMask;
	import modules.help.HelpTipItem;
	import modules.help.HelpTipSkill;
	import modules.mission.MissionConstant;
	import modules.mission.MissionDataManager;
	import modules.mission.MissionFBModule;
	import modules.mission.MissionModule;
	import modules.mission.views.MissionNPCPanel;
	import modules.mission.views.MissionWelcome;
	import modules.mission.vo.MissionPropRewardVO;
	import modules.mission.vo.MissionVO;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.PackageWindow;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.navigation.NavigationModule;
	import modules.npc.NPCDataManager;
	import modules.npc.NPCModule;
	import modules.npc.views.NPCPanel;
	import modules.pet.PetModule;
	import modules.pet.newView.PetPanel;
	import modules.roleStateG.RoleStateModule;
	import modules.roleStateG.views.details.MyDetailView;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.shop.ShopModule;
	import modules.skillTree.SkillTreeModule;
	import modules.story.StoryModule;
	
	import proto.line.m_map_transfer_tos;

	/**
	 * 新手引导模块
	 *
	 */
	public class PlayerGuideModule {
		public static const BAG_WIDNOW:String="bagWindow";
		public static const SKILL_WIDNOW:String="skillWindow";
		public static const PET_WINDOW:String="petWindow";

		public static const FOLLOW_TIP:String="FOLLOW_TIP";
		public static const PANEL_TIP:String="PANEL_TIP";
		public static const WINDOW_TIP:String="WINDOW_TIP";
		public static const SCENE_TIP:String="SCENE_TIP";

		public var currentType:String;
		public var goodsId:int;
		public var goodsTypeId:int;

		public var currentTip:String;

		public var bagGuideLayer:Sprite;
		public var skillGuideLayer:Sprite;
		public var petGuideLayer:Sprite;

		public var guide_npc:Object;

		private var taskTipsView:TipsView;
		private var taskTipsViewNPC:TipsView;
		private var hpDownTip:TipsView;
		private var hpTipID:int;
		private static var instance:PlayerGuideModule;

		private var _isGuidingAttributePoint:Boolean=false;
		private var _isShowingPackTip:Boolean=false;
		private var _isShowingTransferTip:Boolean=false; //是否真正显示传送符的提示
		private var _hasGuideSuperEquip:Boolean=false;

		private var round:Shape;
		//自动挂机的Tip
		private var closeTipsView:TipsView;

		public function PlayerGuideModule() {
			addListener();
			round=new Shape; //画一个圈圈
			round.graphics.lineStyle(3, 0xFF0000);
			round.graphics.drawCircle(0, 0, 14);
		}

		public function get hasGuideSuperEquip():Boolean {
			return _hasGuideSuperEquip;
		}

		public function get isMasking():Boolean {
			return false;
		}

		public static function getInstance():PlayerGuideModule {
			if (instance == null) {
				instance=new PlayerGuideModule();
			}
			return instance;
		}


		private function addListener():void {
			Dispatch.register(GuideConstant.LEVEL_UP, onLevelUp);
			Dispatch.register(GuideConstant.REMOVE_TASK_GUIDE, onRemoveTaskGuide);
			Dispatch.register(GuideConstant.HIDE_TASK_GUIDE, onHideTaskGuide);
			Dispatch.register(GuideConstant.TASK_LIST_UPDATE, onTaskListUpdate);
			Dispatch.register(GuideConstant.OPEN_NPC_PANEL, onOpenNPCPanel);
			Dispatch.register(GuideConstant.OPEN_PACK_PANEL, onOpenPackPanel);
			Dispatch.register(GuideConstant.OPEN_SKILL_PANEL, onOpenSkillPanel);
			Dispatch.register(GuideConstant.AUTO_FIND_TARGET, onAutoFindTarget);
			Dispatch.register(GuideConstant.SCENE_FIGHT, onSceneFight);
			Dispatch.register(GuideConstant.HP_DOWN_TIP, useHPDrugTip);
			Dispatch.register(GuideConstant.HP_DOWN_TIP_HIDE, hideHpDown);
			Dispatch.register(GuideConstant.CARRY_NPC, onCarryNpc);

			Dispatch.register(ModuleCommand.CHANGE_MAP, onChangeMap);


			//一堆关闭窗口的引导处理
			Dispatch.register(GuideConstant.CLOSE_NPC_PANEL, onCloseNpcPanel);
			Dispatch.register(GuideConstant.CLOSE_PACK_PANEL, onClosePackPanel);
			Dispatch.register(GuideConstant.CLOSE_PET_PANEL, onClosePetPanel);
			Dispatch.register(GuideConstant.CLOSE_MY_DETAIL_VIEW, onCloseMyDetailView);
		}

		private function onCarryNpc():void {
			if (_isShowingTransferTip) {
				onRemoveTaskGuide();
				_isShowingTransferTip=false;
			}

		}

		private function onChangeMap(mapId:int):void {
			if (taskTipsViewNPC) {
				taskTipsViewNPC.remove();
				taskTipsViewNPC=null;
			}

			//如果当前任务是第一个任务副本，9级，而且可提交状态，则自动找功夫教头弹窗
			var roleLevel:int=GlobalObjectManager.getInstance().user.attr.level;
			if (roleLevel == 9) {
				var list:Object=MissionDataManager.getInstance().currentMissionList;
				if (list) {
					for each (var missVO:MissionVO in list) {
						if (isFirstFbMissionDoudizhu(missVO.id) && missVO.currentStatus == MissionConstant.STATUS_FINISH) {
							showTaskFollowTip("点击" + HtmlUtil.font(missVO.targetName, "#00ff00") + "自动寻路", missVO);
							var npcID:String="1" + GlobalObjectManager.getInstance().getRoleFactionID() + "000115";
							PathUtil.findNpcAndOpen(npcID);
							break;
						}
					}
				}
			}
		}

		/**
		 * 打怪时候的处理，去掉膏药指引
		 */
		private function onSceneFight(targetID:int=0):void {
			var list:Object=MissionDataManager.getInstance().currentMissionList;
			if (list && shouldShowFllowTip()) {
				for each (var missVO:MissionVO in list) {
					if (missVO.targetId == targetID) {
						onRemoveTaskGuide();
						break;
					}
				}
			}
		}

		private function onCloseMyDetailView():void {
			if (_isGuidingAttributePoint) {
				if (MissionModule.getInstance().missionNPCPanel) {
					MissionModule.getInstance().missionNPCPanel.visible=true;
				} else {
					MissionModule.getInstance().autoFindTarget();
				}
			}
		}


		private function onHideTaskGuide():void {
			if (taskTipsView) {
				taskTipsView.visible=false;
			}
		}

		private function onCloseNpcPanel():void {
			if (taskTipsView && taskTipsView.taskId > 0) {
				taskTipsView.visible=true;
			}
		}


		/**
		 * 接任务的HOOK接口
		 * @param missionID
		 *
		 */
		public function hookMissionAccept(missionVO:MissionVO):void {
			acceptTask(missionVO);
		}

		/**
		 * 完成任务的HOOK接口
		 * @param missionID
		 *
		 */
		public function hookMissionFinish(missionID:int):void {
			guide_npc=null;
			commitTask(missionID);
		}

		/**
		 * 任务处于可以提交状态
		 * @param missionID
		 *
		 */
		public function hookMissionCanCommit(missionVO:MissionVO):void {
			toFinishTask(missionVO);
		}

		/**
		 * 任务的计数器有更新
		 * @param id
		 *
		 */
		public function showHangGuideTip(id:int):void {

			//横涧山的两个打怪任务
			if (isMissionGuideHang(id)) {
				doShowHangTip();
			}
		}

		/**
		 * 横涧山的两个打怪任务,引导自动挂机
		 */
		public function isMissionGuideHang(id:int):Boolean {
			return (id == 4057 || id == 4058 || id == 4059) || (id == 4075 || id == 4076 || id == 4077);
		}

		private function onLevelUp():void {
			var roleLevel:int=GlobalObjectManager.getInstance().user.attr.level;
			var roleSex:int=GlobalObjectManager.getInstance().user.base.sex;

			preloadResource(roleSex, roleLevel);
		}

		/**
		 * 预加载资源
		 * @param roleSex
		 * @param roleLevel
		 */
		private function preloadResource(roleSex:int, roleLevel:int):void {
			switch (roleLevel) {
				case 11:  {
					//提前高级白虎的变身符
					if (roleSex == 1) {
						SourceManager.getInstance().load(GameConfig.ROOT_URL + "com/ui/npc/10102.swf");
					} else {
						//提前加载蝶恋花的变身符						
						SourceManager.getInstance().load(GameConfig.ROOT_URL + "com/ui/npc/10108.swf");
					}
					break;
				}

				default:  {
					break;
				}
			}

		}

		private function onOpenNPCPanel():void {
			_isGuidingAttributePoint=false;
			if (guide_npc) {
				showMissionNPCPanelTip(guide_npc.str, guide_npc.taskId, guide_npc.x, guide_npc.y, guide_npc.align);
			} else {
				onHideTaskGuide();
			}
		}


		private function onClosePetPanel():void {
			closePetTip();
		}

		public function closePetTip():void {
			if (currentType == PET_WINDOW && petGuideLayer) {
				if (petGuideLayer.parent) {
					petGuideLayer.parent.removeChild(petGuideLayer);
				}
				petGuideLayer=null;
				MissionModule.getInstance().autoFindTarget();
			}
		}

		private function onRemoveTaskGuide():void {
			var id:int=taskTipsView ? taskTipsView.taskId : -1;
			if (id != -1) {
				if (isFirstMissionByID(id)) {
					MissionWelcome.getInstance().remove();
				}

				taskTipsView.taskId=-1;
				taskTipsView.remove();
			}
			if (currentType == BAG_WIDNOW && bagGuideLayer) {
				if (bagGuideLayer.parent) {
					bagGuideLayer.parent.removeChild(bagGuideLayer);
				}
				bagGuideLayer=null;
				var packWindow:PackageWindow=PackManager.getInstance().packWindow;
				packWindow.closeWindow();
			} else if (currentType == SKILL_WIDNOW && skillGuideLayer) {
				if (skillGuideLayer.parent) {
					skillGuideLayer.parent.removeChild(skillGuideLayer);
				}
				skillGuideLayer=null;
				SkillTreeModule.getInstance().skillPanel.closeWindow();
			} else if (currentType == PET_WINDOW && petGuideLayer) {
				if (petGuideLayer.parent) {
					petGuideLayer.parent.removeChild(petGuideLayer);
				}
				petGuideLayer=null;
				Dispatch.dispatch(ModuleCommand.OPEN_OR_CLOSE_PET_MAIN);

			}
			goodsTypeId=0;
			goodsId=0;
			currentType="";
			currentTip="";
			_isShowingPackTip=false;
			_isShowingTransferTip=false;
		}

		private function onClosePackPanel():void {
			if (taskTipsView && _isShowingPackTip) {
				onRemoveTaskGuide();
				_isShowingPackTip=false;
				showMonsterGuideTip(10);
			}
		}

		private function onOpenPackPanel():void {
			if (taskTipsView && this.currentTip == SCENE_TIP) {
				var id:int=taskTipsView.taskId;
				//斗地主任务的处理
				if (isFirstFbMissionDoudizhu(id)) {
					useSuperEquipTip(id);
				}
			}
		}


		private function onOpenSkillPanel():void {
			if (taskTipsView) {
				var id:int=taskTipsView.taskId;
				if (id == 1848 || id == 1863 || id == 1876) {
					showWindowTip("点击学习" + HtmlUtil.font("技能", "#00ff00"), SKILL_WIDNOW, id, 350, 190);
					SkillTreeModule.getInstance().skillPanel.addChild(skillGuideLayer);
				} else if (taskTipsView.status == 4 && (id == 1437 || id == 1482 || id == 1527)) {
					showWindowTip("双击该" + HtmlUtil.font("技能图标", "#00ff00") + "即可学习", SKILL_WIDNOW, id, 195, 138, TipsView.TOP);
					SkillTreeModule.getInstance().skillPanel.addChild(skillGuideLayer);
				}
			}
		}
		/**
		 * 自动搜寻目的地
		 */
		private var targetsDic:Dictionary=new Dictionary();

		private function onAutoFindTarget(mission:MissionVO):void {
			if (mission) {
				var id:int=mission.id;
				if (!targetsDic[id] || isSpecialMissionForFindTarget(id)) {
					//由于自动寻找目的地不能关闭，右边任务追踪的提示，但是下面这些逻辑是由于任务追踪提示关闭触发的，所以目前拷贝一份，等将来逻辑多了，就抽出来。

					var mapId:int=SceneDataManager.mapData.map_id;
					if (!MissionFBModule.getInstance().isMapMisssionFB(mapId)) {
						doAutoFindTarget(id);
					}
				}
			}
		}

		/**
		 * 是否属于特殊的寻路任务
		 */
		private function isSpecialMissionForFindTarget(id:int):Boolean {
			return id == 4009 || id == 4010 || id == 4011;
		}

		private function doAutoFindTarget(id:int):void {
			if (MissionModule.getInstance().autoFindTarget()) {
				if (targetsDic == null) {
					targetsDic=new Dictionary();
				}
				targetsDic[id]=true;
				if (isFirstMissionByID(id)) {
					MissionWelcome.getInstance().remove();
				}

				/*if ( showAttack && ( id == 1847 || id == 1862 || id == 1875 )) {
				   HelpTip.getInstance().showMsg( "单击怪物发起攻击。" ); //显示攻击怪物提示。
				   showAttack=false; //防止提示多次出现
				 }*/
			}
		}

		private function onTaskListUpdate(tasks:Object):void {
			if (MissionModule.getInstance().isNewPlayerByGuide()) {
				for each (var missionVO:MissionVO in tasks) {
					if (!isFirstMission(missionVO)) {
						//前10级才每次自动寻路
						Dispatch.dispatch(GuideConstant.AUTO_FIND_TARGET, missionVO);
					}

					break;
				}
			}
		}

		/**
		 * 是否是第一个任务
		 */
		private function isFirstMission(missionVO:MissionVO):Boolean {
			return isFirstMissionByID(missionVO.id);
		}

		private function isFirstMissionByID(id:int):Boolean {
			return id == 10110001 || id == 20110002 || id == 30110003;
		}



		/**
		 * 是否是第一个副本任务，斗地主
		 */
		private function isFirstFbMissionDoudizhu(id:int):Boolean {
			return id == 4042 || id == 4043 || id == 4044;
		}


		/**
		 * 是否是第二个副本任务，血海深仇
		 */
		private function isSecondFbMissionXuehai(id:int):Boolean {
			return id == 4126 || id == 4127 || id == 4128;
		}


		/**
		 * 接受任务
		 */
		private function acceptTask(missionVO:MissionVO):void {
			var id:int=missionVO.id;
			if (id == 10210097 || id == 20210098 || id == 30210099){//飞行任务
				StoryModule.getInstance().showFly(new Pt(56,0,15));
			}else if (isFirstFbMissionDoudizhu(id)) {//下面是明2的
				//自动传送到地主大院
				transterTo1stMissionFb();
			} else if (id == 4126 || id == 4127 || id == 4128) {
				//自动传送到副本地图
				transterTo2ndMissionFb();
			} else if (id == 4135 || id == 4136 || id == 4137) {
				showRoleAttributeTip();
			} else if (id == 18 || id == 36 || id == 54) {
				showFavoriteTip();
			} else if (id == 4045 || id == 4046 || id == 4047) {
				Alert.show("已接到任务<font color='#50B000'>【投奔瑞恩】</font>，点击<font color='#50B000'>“传送”</font>前往面见瑞恩。", "提示", transterToTanghe, null, "传送", "取消", null, false);
			} else if (isSpecialFollowMission(missionVO.id)) {
				var msg:String="点击" + HtmlUtil.font("传送符", "#00ff00") + "立即传送";
				if (id == 4144 || id == 4145 || id == 4146) {
					showTaskFollowTip(msg, missionVO, 75);
					showRound(true, 84, -79);
					_isShowingTransferTip=true;
				} else if (id == 4183 || id == 4184 || id == 4185) {
					showTaskFollowTip(msg, missionVO, 75);
					showRound(true, 84, -79);
					_isShowingTransferTip=true;
				} else if (id == 104 || id == 172 || id == 241) {
					showTaskFollowTip(msg, missionVO, 85);
					showRound(true, 84, -79);
					_isShowingTransferTip=true;
				} else if (id == 106 || id == 174 || id == 243) {
					showTaskFollowTip(msg, missionVO, 75);
					showRound(true, 84, -79);
					_isShowingTransferTip=true;
				}
			} else if (shouldShowFllowTip()) {

				showTaskFollowTip("点击" + HtmlUtil.font(missionVO.targetName, "#00ff00") + "自动寻路", missionVO);
				if (missionVO.model == MissionConstant.MODEL_2 || missionVO.model == MissionConstant.MODEL_3) {
					if (MissionModule.getInstance().isNewPlayerByGuide()) {
						LoopManager.setTimeout(startAutoHitByPlayGuide, 100);
					}
				}

				/*if( missionVO.id == 7 || missionVO.id == 25 || missionVO.id == 43 ){
				   showRoleAttributeTip();
				 }*/

				/*if ( id == 4009 || id == 4010 || id == 4011 ) {
				   setTimeout( HelpTip.getInstance().showMsg, 2000, "点击小灰兔开始捕捉" );
				 }*/

				/*else if ( id == 1473 || id == 1518 || id == 1563 ) {
				   Alert.show( "已接到任务<font color='#50B000'>【间谍康茂才】</font>，点击<font color='#50B000'>“传送”</font>前往面见朱文正。",
				   "提示", transterToZhuwenzheng, null, "传送", "取消", null, false );
				 }*/
			} else {
				onRemoveTaskGuide();
				showRound(false);
			}
		}

		private function showRound(show:Boolean, x:Number=0, y:Number=0):void {
			if (show == true) {
				if (round.parent == null) {
					taskTipsView.addChild(round);
				}
				round.x=x;
				round.y=y;
			} else {
				if (round.parent) {
					round.parent.removeChild(round);
				}
			}

		}

		/**
		 * 是否是特殊的传送卷寻路ID
		 * @param id
		 * @return
		 *
		 */
		private function isSpecialFollowMission(id:int):Boolean {
			return (id == 4144 || id == 4145 || id == 4146) || //部署
				(id == 4183 || id == 4184 || id == 4185) || //会师
				(id == 104 || id == 172 || id == 241) || //义商沈万三
				(id == 106 || id == 174 || id == 243); //猛将张定边
		}

		private function showFavoriteTip():void {
			onGuideDialogStart();
			Alert.show("请点击<font color='#50B000'>“确定”</font>，收藏你的《天之刃》", "提示", doFavoriteGameOk, doFavoriteGameCancel, "确定", "取消", null, true);
		}

		private function doFavoriteGameCancel():void {
			onGuideDialogEnd();
		}

		/**
		 * 收藏游戏到桌面
		 *
		 */
		private function doFavoriteGameOk():void {
			try {
				ExternalInterface.call('bookmarkit');
			} catch (e:Error) {
			}
			onGuideDialogEnd();
		}

		private function startAutoHitByPlayGuide():void {
			SceneModule.getInstance().startAutoHitByPlayGuide();
		}


		/**
		 * 只有前20级才显示任务追踪的提示
		 */
		private function shouldShowFllowTip():Boolean {
			var roleLevel:int=GlobalObjectManager.getInstance().user.attr.level;
			return roleLevel <= 20;
		}


		/**
		 * 传送到地主大院，,第1个任务副本
		 */
		private function transterTo1stMissionFb():void {
			MissionFBModule.getInstance().onEnter101MissionFb();
		}

		/**
		 * 传送到元军大营,第2个任务副本
		 */
		private function transterTo2ndMissionFb():void {
			MissionFBModule.getInstance().onEnter102MissionFb();
		}


		/**
		 * 传送到汤和
		 */
		private function transterToTanghe():void {
			var npcID:String="1" + GlobalObjectManager.getInstance().getRoleFactionID() + "001102";
			transferToMissionNpc(npcID);

		}

		/**
		 * 传送到朱文正
		 */
		private function transterToZhuwenzheng():void {
			var npcID:String="1" + GlobalObjectManager.getInstance().getRoleFactionID() + "101101";
			transferToMissionNpc(npcID);
		}

		private function transferToMissionNpc(npcID:String):void {
			var npcPos:Array=NPCDataManager.getInstance().getPos(npcID);
			var vo:m_map_transfer_tos=new m_map_transfer_tos;
			vo.mapid=npcPos[0];
			vo.tx=npcPos[1];
			vo.ty=npcPos[2];
			vo.change_type=0;
			Connection.getInstance().sendMessage(vo);
		}

		/**
		 * 完成任务
		 */
		private function toFinishTask(missionVO:MissionVO):void {
			var id:int=missionVO.id;

			if (isFirstMission(missionVO)) {
				showMissionNPCPanelTip("点击完成任务", id,158, 225);
			} else if (isFirstFbMissionDoudizhu(id)) {
				//斗地主副本任务的引导
				var mapId:int=SceneDataManager.mapData.map_id;
				if (MissionFBModule.getInstance().isMapMisssionFB(mapId)) {
					LoopManager.setTimeout(function():void {
							PathUtil.findNpcAndOpen(10302100);
							showOnlyNPCPanelTip("从副本出口退出", id, 215, 75, "left");
						}, 1000);
				}
			} else if (isSecondFbMissionXuehai(id)) {
				//血海深仇副本任务的引导
				showNPCTip("从副本出口退出", 10303100, 95, -75, TipsView.LEFT);
			} else if (shouldShowFllowTip()) {
				showTaskFollowTip("点击" + HtmlUtil.font(missionVO.targetName, "#00ff00") + "自动寻路", missionVO);
			} else {
				onRemoveTaskGuide();
			}
		}


		/**
		 *  提交任务（成功）
		 */
		private function commitTask(id:int):void {
			if (isFirstMissionByID(id)) {
				showMissionNPCPanelTip("点击接受任务", id, 158, 225);
			} else if (isFirstFbMissionDoudizhu(id)) {
				//打完地主后自动穿上铠甲，自动装备武器
				autoUseArmor();
				autoUseNewEquip();
			} else if (id == 4006 || id == 4007 || id == 4008) {
				autoUseNewEquip();
			} else if (id == 4012 || id == 4013 || id == 4014) {
				showPetTip();
			} else if (id == 4066 || id == 4067 || id == 4068) {
				//使用变身符
				showMagicItemTip();
			} else if (id == 4141 || id == 4142 || id == 4143) {
				//使用VIP体验卡
				showVipCardTip();
			} else if (id == 4180 || id == 4181 || id == 4182) {
				//添加猴子召唤符的使用指引
				showMonkeyPetCardTip();
			} else if (id == 4096 || id == 4097 || id == 4098) {
				autoUseFashion();
			} else if (id == 4084 || id == 4085 || id == 4086) {
				autoUseGoods([30207101]);
			} else if (id == 4111 || id == 4112 || id == 4113) {
				autoUseGoods([30303101, 30303102]);
			} else if (id == 4123 || id == 4124 || id == 4125) {
				autoUseGoods([30302101, 30302102]);
			} else if (id == 4036 || id == 4037 || id == 4038) {
				showMissionFlowerTip();
			} else if (id == 4021 || id == 4022 || id == 4023) {
				//第一次习武
				HelpTipSkill.getInstance().show(new Array(10301001, 10302001, 10303001, 10304001), true);
			} else if (id == 4117 || id == 4118 || id == 4119) {
				//武学秘籍
				HelpTipSkill.getInstance().show(new Array(10301004, 10302004, 10303004, 10304004), true);
			} else if (id == 4057 || id == 4058 || id == 4059) {
				//虎口夺粮赠送技能书
				HelpTipSkill.getInstance().show(new Array(10301006, 10302006, 10303006, 10304006), true);
			}

			else {
				onRemoveTaskGuide();
			}

		/*if ( isFirstMissionByID( id )) {
		   showNPCPanelTip( "点击接受任务", id, 138, 170 );
		   } else if ( id == 1891 || id == 1890 || id == 1889 ) {
		   showArmorTip();
		   } else if ( id == 1904 || id == 1905 || id == 1906 ) {
		   showPetTip();
		   } else if ( id == 1888 || id == 1887 || id == 1886 ) {
		   setTimeout( HelpTip.getInstance().showMsg, 2000, "按T键来上马下马。" );
		   } else if ( id == 8 || id == 26 || id == 44 ) {
		   //习武之道
		   HelpTipSkill.getInstance().show(new Array(10301001, 10302001, 10303001, 10304001),true);
		   } else if (id == 1439 || id == 1484 || id == 1529) {
		   //横涧山收编
		   HelpTipSkill.getInstance().show(new Array(10301006, 10302006, 10303006, 10304006));
		   } else if (id == 1460 || id == 1505 || id == 1550) {
		   //冲开血路
		   HelpTipSkill.getInstance().show(new Array(10301004, 10302004, 10303004, 10304004));
		   } else if (id == 1437 || id == 1482 || id == 1527) {
		   if (!skillHasOpen()) {
		   showSceneTip("打开技能面板，学习第二个技能", id, 650, 432);
		   taskTipsView.status=4;
		   } else {
		   taskTipsView.taskId=id;
		   taskTipsView.status=4;
		   onOpenSkillPanel();
		   }
		   }  else if (id == 1434 || id == 1479 || id == 1524) {
		   var factions:Array=PackManager.getInstance().getItemByKind(ItemConstant.KIND_FASHION);
		   if (factions && factions.length > 0) {
		   var faction:EquipVO=factions.shift() as EquipVO;
		   PackageModule.getInstance().useGoods(faction);
		   setTimeout(HelpTip.getInstance().showMsg, 2000, "更多时装可以到京城的美容师处购买哦。");
		   }
		   }  else {
		   onRemoveTaskGuide();
		 }*/
		}

		/**
		 * 添加猴子召唤符的使用指引
		 */
		private function showMonkeyPetCardTip():void {
			onGuideDialogStart();
			var typeId:int=12300006;
			var magicItemVo:BaseItemVO=PackManager.getInstance().getGoodsVOByType(typeId);
			if (magicItemVo) {
				var tip:HelpTipItem=new HelpTipItem();
				tip.callBack=autoUsePetCard;
				tip.btnLabel="开始召唤";
				tip.show(magicItemVo, "使用宠物召唤符", "点击召唤");
			}

			function autoUsePetCard():void {
				autoUseGoods([typeId]);
				onGuideDialogEnd();
			}

		}

		/**
		 * 弹出使用VIP体验卡的提示
		 */
		private function showVipCardTip():void {
			onGuideDialogStart();
			var typeId:int=12400001;
			var magicItemVo:BaseItemVO=PackManager.getInstance().getGoodsVOByType(typeId);
			if (magicItemVo) {
				var tip:HelpTipItem=new HelpTipItem();
				tip.callBack=autoUseVipCard;
				tip.btnLabel="开始使用";
				tip.show(magicItemVo, "使用VIP体验卡，享受至尊服务", "点击使用");
			}

			function autoUseVipCard():void {
				autoUseGoods([typeId]);
				onGuideDialogEnd();
			}
		}



		/**
		 * 显示乔装打扮的提示
		 *
		 */
		private function showMagicItemTip():void {
			onGuideDialogStart();
			var magicItemVo:BaseItemVO=getMagicItemVO();
			if (magicItemVo) {
				var tip:HelpTipItem=new HelpTipItem();
				tip.callBack=autoUseMagicItem;
				tip.btnLabel="开始乔装";
				tip.show(magicItemVo, "请使用变身符乔装改扮", "点击乔装");
			}
		}

		/**
		 * 新手指引的变身符
		 */
		private function getMagicItemVO():BaseItemVO {
			var roleSex:int=GlobalObjectManager.getInstance().user.base.sex;
			var typeId:int=0;
			if (roleSex == 1) {
				typeId=10120009; //白虎变身符
			} else {
				typeId=10120008; //蝶恋花的变身符
			}

			return PackManager.getInstance().getGoodsVOByType(typeId);
		}


		/**
		 *  自动穿上任务赠送的装备
		 * @param typeIdList
		 *
		 */
		private function autoUseGoods(typeIdList:Array):void {
			if (!typeIdList)
				return;
			for each (var typeId:int in typeIdList) {
				var goodsVO:BaseItemVO=PackManager.getInstance().getGoodsVOByType(typeId);
				if (goodsVO) {
					PackageModule.getInstance().useGoods(goodsVO);
				}
			}
		}

		private function showMissionFlowerTip():void {
			var tip:HelpTipItem=new HelpTipItem();
			var followItemVo:GeneralVO=ItemLocator.getInstance().getObject(10100082) as GeneralVO;
			tip.callBack=autoPlayMissionFlower;
			tip.btnLabel="拆开礼物";
			tip.show(followItemVo, "请您拆开小六的礼物", "点击拆开");
			onGuideDialogStart();

			function autoPlayMissionFlower():void {
				//自动播放玫瑰花
				FlowersBroacastManager.getInstance().playNewMissionFlower();
				onGuideDialogEnd();
			}
		}

		/**
		 * 自动穿上服装
		 */
		private function autoUseFashion():void {
			var factions:Array=PackManager.getInstance().getItemByKind(ItemConstant.KIND_FASHION);
			if (factions && factions.length > 0) {
				var faction:EquipVO=factions.shift() as EquipVO;
				PackageModule.getInstance().useGoods(faction);
				BroadcastModule.getInstance().popup("更多时装可以到商城挑选！", "打开时装商店", openFashionShop, null, 5);
			}

		}

		/**
		 * 打开服装商店
		 */
		public function openFashionShop():void {
			var shopID:int=10118;
			ShopModule.getInstance().openFashionShop();
		}

		/**
		 * 自动使用变身符
		 */
		private function autoUseMagicItem():void {
			var roleID:int=GlobalObjectManager.getInstance().user.base.role_id;
			var itemVO:BaseItemVO=getMagicItemVO();
			if (itemVO) {
				PackageModule.getInstance().useItem(itemVO.oid, 1, roleID);
			}
			onGuideDialogEnd();
		}

		/**
		 * 自动穿上铠甲
		 */
		private function autoUseArmor():void {
			var breasts:Array=PackManager.getInstance().getItemByKind(ItemConstant.KIND_BREAT);
			if (breasts && breasts.length > 0) {
				var baseItemVO:BaseItemVO=breasts.shift();
				if (baseItemVO) {
					PackageModule.getInstance().useGoods(baseItemVO);
				}
			}
		}

		/**
		 * 自动穿上朝阳刀
		 */
		private function autoUseNewEquip():void {
			var baseItemVO:BaseItemVO=PackManager.getInstance().getFirstItemOfWeapon();
			if (baseItemVO) {
				PackageModule.getInstance().useGoods(baseItemVO);
			}
		}



		/**
		 * 显示任务追踪提示 (一般都是固定位置,固定方向)
		 */
		private function showTaskFollowTip(str:String, missionVO:MissionVO, x:int=35, y:int=125, align:String="top"):void {
			initTaskTip();
			taskTipsView.x=x;
			taskTipsView.y=y;
			taskTipsView.show(str, align);
			taskTipsView.targetId=missionVO.targetId;
			taskTipsView.taskId=missionVO.id;
			MissionModule.getInstance().followView.addChild(taskTipsView);
			currentTip=FOLLOW_TIP;
		}

		/**
		 * 在NPC窗口上显示提示
		 */
		private function showOnlyNPCPanelTip(str:String, taskId:int, x:int, y:int, align:String="bottom"):void {
			var npcPanel:NPCPanel=NPCModule.getInstance().view;
			if (npcPanel && npcPanel.visible) {
				initTaskTip();
				taskTipsView.x=x;
				taskTipsView.y=y;
				taskTipsView.show(str, align);
				taskTipsView.taskId=taskId;
				currentTip=PANEL_TIP;
				npcPanel.addChild(taskTipsView);
			}
		}

		/**
		 * 在任务NPC窗口上显示提示（由于NPC窗口比较特殊，所以单独处理）
		 */
		private function showMissionNPCPanelTip(str:String, taskId:int, x:int, y:int, align:String="bottom"):void {
			var missionNpcPanel:MissionNPCPanel=MissionModule.getInstance().missionNPCPanel;
			if (missionNpcPanel && missionNpcPanel.visible) {
				initTaskTip();
				taskTipsView.x=x;
				taskTipsView.y=y;
				taskTipsView.show(str, align);
				taskTipsView.taskId=taskId;
				currentTip=PANEL_TIP;
				missionNpcPanel.addChild(taskTipsView);
				guide_npc=null; //reset
			} else {
				//先保存NPC提示信息，等对话框visiable=true之后，才显示出来
				guide_npc={str: str, taskId: taskId, x: x, y: y, align: align};
			}

		}

		/**
		 *  在窗口上显示提示
		 */
		private function showWindowTip(str:String, windowType:String, taskId:int, x:int, y:int, align:String="bottom"):void {
			initTaskTip();
			taskTipsView.x=x;
			taskTipsView.y=y;
			taskTipsView.show(str, align);
			taskTipsView.taskId=taskId;
			this.currentTip=WINDOW_TIP;
			var container:Sprite=getWindow(windowType);
			container.addChild(taskTipsView);
		}

		/**
		 * 根据不同窗口类型获取不同窗口层，
		 */
		private function getWindow(windowType:String):Sprite {
			currentType=windowType;
			if (currentType == BAG_WIDNOW) {
				if (bagGuideLayer == null) {
					bagGuideLayer=new Sprite();
					bagGuideLayer.mouseEnabled=false;
				}
				return bagGuideLayer;
			} else if (currentType == SKILL_WIDNOW) {
				if (skillGuideLayer == null) {
					skillGuideLayer=new Sprite();
					skillGuideLayer.mouseEnabled=false;
				}
				return skillGuideLayer;
			} else if (currentType == PET_WINDOW) {
				if (petGuideLayer == null) {
					petGuideLayer=new Sprite();
					petGuideLayer.mouseEnabled=false;
				}
				return petGuideLayer;
			}

			return null;
		}

		/**
		 * 显示NPC的提示
		 */
		private function showNPCTip(str:String, npcId:int, x:int=-30, y:int=-75, align:String="right"):void {
			if (taskTipsViewNPC == null) {
				taskTipsViewNPC=new TipsView();
			} else {
				taskTipsViewNPC.remove();
			}

			var npc:NPC=NPCTeamManager.getNPC(npcId);
			if (npc) {
				taskTipsViewNPC.x=x;
				taskTipsViewNPC.y=y;
				taskTipsViewNPC.show(str, align);
				npc.addChild(taskTipsViewNPC);
			}
		}

		/**
		 * 显示场景提示
		 */
		private function showSceneTip(str:String, taskId:int, x:int=5, y:int=125, align:String="bottom"):void {
			initTaskTip();
			taskTipsView.x=x;
			taskTipsView.y=y;
			taskTipsView.show(str, align);
			taskTipsView.taskId=taskId;
			this.currentTip=SCENE_TIP;
			LayerManager.uiLayer.addChild(taskTipsView);
		}

		private function initTaskTip():void {
			if (taskTipsView == null) {
				taskTipsView=new TipsView();
			} else {
				taskTipsView.targetId=0;
				taskTipsView.remove();
			}
			taskTipsView.taskId=-1;
			taskTipsView.visible=true;
			_isShowingTransferTip=false;
		}

		/**
		 * 调整指引位置
		 */
		public function adjustTaskTipPos(newX:int, newY:int):void {
			if (taskTipsView) {
				taskTipsView.x=newX;
				taskTipsView.y=newY;
			}
		}


		/**
		 * 显示增加属性点的提示
		 */
		private function showRoleAttributeTip():void {
			var remainAttrPoints:int=GlobalObjectManager.getInstance().user.base.remain_attr_points;
			if (remainAttrPoints <= 0) {
				return;
			}

			onGuideDialogStart();

			RoleStateModule.getInstance().onOpenMyDetail(1);
			var theDetailView:MyDetailView=RoleStateModule.getInstance().getMyDetailView();
			var mask:HelpMask=new HelpMask();
			var p:Point;
			if (theDetailView) {
				p=new Point(theDetailView.x + 10, theDetailView.y + 325);
			} else {
				p=new Point(0, 0);
			}

			var tip:TipsView=new TipsView();
			tip.x=p.x + 188;

			var category:int=GlobalObjectManager.getInstance().user.attr.category;
			switch (category) {
				case 1:  {
					tip.y=p.y + 48;
					tip.show("战士推荐加敏捷", TipsView.LEFT);
					break;
				}
				case 2:  {
					tip.y=p.y;
					tip.show("射手推荐加力量", TipsView.LEFT);
					break;
				}
				case 3:  {
					tip.y=p.y + 24;
					tip.show("侠客推荐加智力", TipsView.LEFT);
					break;
				}
				case 4:  {
					tip.y=p.y + 72;
					tip.show("医仙推荐加精神", TipsView.LEFT);
					break;
				}
				default:  {
					break;
				}
			}
			mask.show(new Rectangle(p.x, p.y, 130, 126), attrFinish, MouseEvent.MOUSE_DOWN);

			mask.addChild(tip);
			LayerManager.alertLayer.addChild(mask);

			function attrFinish():void {
				if (MissionModule.getInstance().missionNPCPanel) {
					MissionModule.getInstance().missionNPCPanel.visible=false;
				}
				_isGuidingAttributePoint=true;
			}
		}

		/**
		 * 领取第一只宠物
		 */
		private function showPetTip():void {
			onGuideDialogStart();

			var petItemVo:BaseItemVO=PackManager.getInstance().getGoodsByEffectType([ItemConstant.EFFECT_CALL_PET]);
			if (petItemVo) {
				var tip:HelpTipItem=new HelpTipItem();
				tip.callBack=showPetMask;
				tip.btnLabel="使用召唤符";
				tip.show(petItemVo, "恭喜您获得宠物召唤符", "点击召唤");
			}
			function showPetMask():void {
				//先召唤小灰兔
				PackageModule.getInstance().useGoods(petItemVo);

//				var mask:HelpMask = new HelpMask();
//				var p:Point;
//				if(PetModule.getInstance().mediator.getPanel()){
//					p = new Point(PetModule.getInstance().mediator.getPanel().x+170,PetModule.getInstance().mediator.getPanel().y+380);
//				}else{
//					p = new Point(0,0);
//				}
//				mask.show(new Rectangle(p.x,p.y,70,70),attrFinish);
//				mask.graphics.clear();
//				mask.mouseEnabled = false;
				showWindowTip("点击出战", PET_WINDOW, 0, 318, 367, TipsView.LEFT);
				PetModule.getInstance().mediator.openPanel();
				var panel:PetPanel=PetModule.getInstance().mediator.getPanel();
				panel.addChild(petGuideLayer);
			}
//			function attrFinish():void{
//				Dispatch.dispatch(ModuleCommand.MISSION_NEW_PLAYER_PET_TASK);
//				Dispatch.dispatch(ModuleCommand.OPEN_OR_CLOSE_PET_MAIN);
//				onMaskEnd();
//			}
		}

		/**
		 *  领取第一件铠甲的提示，暂时屏蔽
		 */
		//private var _isMasking:Boolean = false;


		private function showArmorTip():void {

		/*onMaskStart();

		   var equipTypeId:int = 0;
		   var breasts:Array=PackManager.getInstance().getItemByKind(ItemConstant.KIND_BREAT);
		   if (breasts && breasts.length > 0) {
		   var baseItemVO:BaseItemVO=breasts.shift();
		   equipTypeId = baseItemVO.typeId;
		   showPackMask();
		   }
		   var mask:HelpMask;
		   function showPackMask():void{
		   if ( !hasPackOpen()) {
		   mask = new HelpMask();
		   var p:Point = new Point(NavigationModule.getInstance().navBar.getPackRect().x,NavigationModule.getInstance().navBar.getPackRect().y);
		   mask.show(new Rectangle(p.x,p.y,32,32),showArmorMask);
		   var tip:TipsView = new TipsView();
		   tip.show("点击打开背包",TipsView.BOTTOM);
		   tip.x = p.x - 60;
		   tip.y = p.y - tip.height - 10;
		   mask.addChild(tip);
		   LayerManager.alertLayer.addChild(mask);
		   }else{
		   showArmorMask();
		   }
		   }
		   function showArmorMask():void{
		   var hasPack:Boolean;
		   if(PackManager.getInstance().getPackWindow(PackManager.PACK_1)){
		   hasPack = true;
		   }else{
		   hasPack = false;
		   }
		   if (!PackManager.getInstance().isPopUp(PackManager.PACK_1)) {
		   PackManager.getInstance().popUpWindow(PackManager.PACK_1);
		   }
		   var rect:Rectangle = new Rectangle();
		   var packItem:PackageItem = PackManager.getInstance().getItem(equipTypeId);
		   var packItemPoint:Point = new Point(0,0);
		   if(packItem){
		   if(hasPack){
		   packItemPoint = packItem.localToGlobal(new Point(-36,0));
		   }else{
		   packItemPoint = packItem.localToGlobal(new Point(-36,32));
		   }
		   }
		   rect.x = packItemPoint.x;
		   rect.y = packItemPoint.y;
		   rect.width = 36;
		   rect.height = 36;
		   mask = new HelpMask();
		   mask.show(rect,useArmor,MouseEvent.CLICK);
		   var tip:TipsView = new TipsView();
		   tip.show("双击铠甲，穿上它",TipsView.LEFT);
		   tip.x = packItemPoint.x + 100;
		   tip.y = packItemPoint.y;
		   mask.addChild(tip);
		   LayerManager.alertLayer.addChild(mask);
		   }

		   function useArmor():void {
		   if ( baseItemVO ) {
		   PackageModule.getInstance().useGoods( baseItemVO );
		   }

		   LoopManager.setTimeout( useArmor2, 300 );
		   }

		   function useArmor2():void {
		   onMaskEnd();
		   PackManager.getInstance().popUpWindow( PackManager.PACK_1 );
		 } */
		}

		/**
		 * 遮罩结束
		 */
		private function onGuideDialogEnd(isAddingAttrPoint:Boolean=false):void {
			if (MissionModule.getInstance().missionNPCPanel) {
				MissionModule.getInstance().missionNPCPanel.visible=true;
			}
			_isGuidingAttributePoint=isAddingAttrPoint;
		}

		/**
		 * 遮罩开始
		 */
		private function onGuideDialogStart():void {
			onRemoveTaskGuide();
			if (MissionModule.getInstance().missionNPCPanel) {
				MissionModule.getInstance().missionNPCPanel.visible=false;
			}
			_isGuidingAttributePoint=false;
		}

		/**
		 * 判断任务面板是否已经打开
		 */
		private function taskHasOpen():Boolean {
			var panel:MissionNPCPanel=MissionModule.getInstance().missionNPCPanel;
			if (panel && panel.visible) {
				return true;
			}
			return false;
		}

		/**
		 * 判断背包面板是否打开
		 */
		private function hasPackOpen():Boolean {
			return PackManager.getInstance().isPopUp(PackManager.PACK_1);
		}

		/**
		 * 判断技能面板是否打开
		 */
		private function skillHasOpen():Boolean {
			var panel:BasePanel=SkillTreeModule.getInstance().skillPanel;
			if (panel && panel.stage && panel.visible) {
				return true;
			}
			return false;
		}


		private function initHPDownTip():void {
			if (hpDownTip == null) {
				hpDownTip=new TipsView();
			}
		}

		private function useHPDrugTip(arr:Array):void {
			initHPDownTip();
			if (hpDownTip.parent == null) {
				hpDownTip.x=arr[1];
				hpDownTip.y=arr[2];
				hpDownTip.show(arr[0], TipsView.BOTTOM);
				hpDownTip.taskId=999;
				LayerManager.windowLayer.addChild(hpDownTip);
			}
			LoopManager.clearTimeout(hpTipID);
			hpTipID=LoopManager.setTimeout(hideHpDown, 8000);
		}

		private function hideHpDown():void {
			if (hpDownTip != null) {
				hpDownTip.remove();
			}
		}



		/**
		 * 显示自动打怪的引导提示
		 */
		private function doShowHangTip():void {
			if (SceneModule.isAutoHit) {
				return;
			}

			onRemoveTaskGuide();

			if (!closeTipsView) {
				closeTipsView=new TipsView();
			}

			closeTipsView.x = GlobalObjectManager.GAME_WIDTH-375;
			closeTipsView.y = 126;
			closeTipsView.show("点击" + HtmlUtil.font("挂机", "#00ff00") + "可自动打怪", TipsView.RIGHT);
			LayerManager.alertLayer.addChild(closeTipsView);
			//MissionModule.getInstance().followView.addChild(taskTipsView);
		}

		/**
		 * 关闭自动打怪的引导提示
		 */
		public function closeAutoHitTip():void {
			if (closeTipsView) {
				closeTipsView.remove();
			}
		}


		public function onHelpTipStart():void {
			if (MissionModule.getInstance().missionNPCPanel) {
				MissionModule.getInstance().missionNPCPanel.visible=false;
			}
		}

		public function onHelpTipEnd():void {
			if (MissionModule.getInstance().missionNPCPanel) {
				MissionModule.getInstance().missionNPCPanel.visible=true;
			}
		}

		public function hookMissionFbProp(barrier_id:int, prop_id:int):void {
			//10级的单人任务副本
			if (barrier_id == 101) {
				//拿到武器之后，1秒钟之后提示穿上装备
				LoopManager.setTimeout(showSuperEquipTip, 750, [prop_id]);
			}
		}



		/**
		 * 背包引导使用装备 ，引导的第一个步骤
		 */
		private function showSuperEquipTip(prop_id:int):void {
			var equipItemVo:BaseItemVO=PackManager.getInstance().getGoodsVOByType(prop_id);
			if (_hasGuideSuperEquip && equipItemVo) {
				//第二次不再做背包的引导
				PackageModule.getInstance().useGoods(equipItemVo);
				return;
			}

			var tip:HelpTipItem=new HelpTipItem();
			tip.callBack=showSuperEquipGuide;
			tip.btnLabel="领取神器";
			tip.show(equipItemVo, "刑天神器，威力无敌。本副本才能使用", "立即领取");

			function showSuperEquipGuide():void {
				var taskId:int=4042;
				if (equipItemVo) {
					if (!hasPackOpen()) {
						var p:Point=new Point(NavigationModule.getInstance().navBar.getPackRect().x, NavigationModule.getInstance().navBar.getPackRect().y);
						showSceneTip("单击查看" + HtmlUtil.font("刑天神器", "#00ff00"), taskId, (p.x - 60), (p.y - 100));
					} else {
						useSuperEquipTip(taskId);
					}
				} else {
					BroadcastSelf.getInstance().appendMsg("<font color='#00ff00'><a href='event:useSuperEquip" + "#" + prop_id + "'><u>装备刑天神器</u></a></font>");
				}
			}

		}


		/**
		 * 背包引导使用装备 ，引导的第二个步骤
		 */
		private function useSuperEquipTip(taskId:int):void {

			var baseItemVO:BaseItemVO=getSuperEquipVO();
			showWindowTip("双击，立即装备" + HtmlUtil.font("神器", "#00ff00"), BAG_WIDNOW, taskId, 0, 0, TipsView.TOP);
			if (baseItemVO) {
				//更新数据，从而更新提示位置。
				PackManager.getInstance().updateGoods(baseItemVO.bagid, baseItemVO.position, baseItemVO);
			}

			_isShowingPackTip=true;
			_hasGuideSuperEquip=true;
			var packWindow:BasePanel=PackManager.getInstance().packWindow;
			packWindow.addChild(bagGuideLayer);
		}

		private function getSuperEquipVO():BaseItemVO {
			var category:int=GlobalObjectManager.getInstance().user.attr.category;
			//由于装备配置和人物职业ID不匹配所以特殊处理。
			if (category == 3) {
				category=4;
			} else if (category == 4) {
				category=3;
			}
			goodsTypeId=int("30101" + category + "02");
			return PackManager.getInstance().getGoodsVOByType(goodsTypeId);
		}

		/**
		 * 直接使用装备
		 * @param prop_id
		 */
		public function useSuperEquip(prop_id:*):void {
			prop_id=parseInt(prop_id);
			var equipItemVo:BaseItemVO=PackManager.getInstance().getGoodsVOByType(prop_id);
			if (equipItemVo) {
				PackageModule.getInstance().useGoods(equipItemVo);
			}
		}

		public function hasGuideTip():Boolean {
			if (taskTipsView == null || !taskTipsView.visible || taskTipsView.parent == null) {
				return false;
			}
			return true;
		}

		/**
		 * 第一个任务的引导
		 */
		public function showFirstMissionFollowTip():void {
			var currMissionList:Object=MissionDataManager.getInstance().currentMissionList;
			for each (var missionVO:MissionVO in currMissionList) {
				if (isFirstMission(missionVO)) {
					acceptTask(missionVO);
				}
				break;
			}
		}

		/**
		 * 进入任务副本之后，显示怪物的攻击提示
		 */
		public function showMonsterGuideTip(delay:int=1500):void {
			LoopManager.setTimeout(function showGuide():void {
					Dispatch.dispatch(ModuleCommand.SHOW_HIT_MONSTER_GUIDE);
				}, delay);
		}

		/**
		 * 根据特殊任务，过滤掉任务道具奖励
		 * @param missionVO
		 * @param propList
		 * @return
		 *
		 */
		public function filterPropReward(missionVO:MissionVO, propList:Vector.<MissionPropRewardVO>):void {
			if (!propList) {
				return;
			}

			var id:int=missionVO.id;
			if (id == 4066 || id == 4067 || id == 4068) {
				var roleSex:int=GlobalObjectManager.getInstance().user.base.sex;
				if (roleSex == 1) { //男的给白虎
					filterPropInVector(propList, 10120009);
				} else { //女的给蝶恋花
					filterPropInVector(propList, 10120008);
				}
			}
		}

		private function filterPropInVector(propList:Vector.<MissionPropRewardVO>, propId:int):void {
			for (var i:int=0; i < propList.length; i++) {
				if (propList[i].prop_id == propId) {
					continue;
				} else {
					propList.splice(i, 1);
					i--;
				}
			}
		}

		/**
		 * 检查是否需要做任务向导的隐藏
		 * @param levelLimit
		 *
		 */
		public function checkHideTaskGuide(levelLimit:Boolean=false):void {
			var roleLevel:int=GlobalObjectManager.getInstance().user.attr.level;
			if (levelLimit && roleLevel <= 15) {
				return;
			}

			if (PlayerGuideModule.getInstance().currentTip == PlayerGuideModule.FOLLOW_TIP) {
				Dispatch.dispatch(GuideConstant.HIDE_TASK_GUIDE);
			}
		}
	}
}