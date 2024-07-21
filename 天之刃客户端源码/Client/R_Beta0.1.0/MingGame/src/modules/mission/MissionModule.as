package modules.mission {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.sceneData.RunVo;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.scene.tile.Pt;
	import com.utils.PathUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TextEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.Activity.ActivityModule;
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.BroadcastView;
	import modules.broadcast.views.Tips;
	import modules.heroFB.HeroFBModule;
	import modules.mission.views.AutoMissionItemRenderer;
	import modules.mission.views.AutoMissionPanel;
	import modules.mission.views.MissionFollowView;
	import modules.mission.views.MissionNPCPanel;
	import modules.mission.views.MissionShouBianTimeView;
	import modules.mission.views.MissionTransferNotice;
	import modules.mission.views.MissionWelcome;
	import modules.mission.views.MissionWindow;
	import modules.mission.vo.MissionBaseIndex;
	import modules.mission.vo.MissionStatusCollectIndex;
	import modules.mission.vo.MissionVO;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.npc.NPCActionType;
	import modules.npc.NPCConstant;
	import modules.npc.NPCModule;
	import modules.npc.vo.NpcLinkVO;
	import modules.playerGuide.PlayerGuideModule;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.sceneWarFb.SceneWarFbModule;
	import modules.vip.VipModule;
	
	import proto.line.m_mission_cancel_toc;
	import proto.line.m_mission_cancel_tos;
	import proto.line.m_mission_do_auto_toc;
	import proto.line.m_mission_do_auto_tos;
	import proto.line.m_mission_do_toc;
	import proto.line.m_mission_do_tos;
	import proto.line.m_mission_list_auto_toc;
	import proto.line.m_mission_list_auto_tos;
	import proto.line.m_mission_list_toc;
	import proto.line.m_mission_list_tos;
	import proto.line.m_mission_listener_toc;
	import proto.line.m_mission_update_toc;
	import proto.line.p_mission_listener;
	import proto.line.p_mission_prop;
	import proto.line.p_mission_reward_data;

	public class MissionModule extends BaseModule {

		public function MissionModule(_singleton:singleton) {
			if (_singleton) {
				super();
			} else {
				throw new Error("MissionModule Singleton.");
			}
		}

		//最后一次做任务的NPCID
		private var _missionDOPreNPCID:int=0;
		//最后一次返回的执行任务的ID
		private var _missionDOPreMissionID:int=0;
		//正在做的任务ID
		private var _doingMissionID:int=0;
                //是否真正延时显示下一个任务
                private var _isWaitingShowNext:Boolean=false;

		private var _transferNotice:MissionTransferNotice;

		private var _transformAlertID:String;

		private static var instance:MissionModule;
		private var _autoMissionPanel:AutoMissionPanel;

		public static function getInstance():MissionModule {
			if (instance == null) {
				instance=new MissionModule(new singleton());
			}
			return instance;
		}
		
		public function getAutoMissionPanel():AutoMissionPanel{
			if( !_autoMissionPanel ){
				_autoMissionPanel = new AutoMissionPanel();
			}
			return _autoMissionPanel;
		}

		
		
		/**
		 * 初始化任务需要的侦听器
		 */
		override protected function initListeners():void {
			//守边相关
			addMessageListener(ModuleCommand.MISSION_UPDATE_SHOU_BIAN_TIME_VIEW_VO, this.onUpdateShouBianTimeViewVO);
			addMessageListener(ModuleCommand.MISSION_REMOVE_SHOU_BIAN_TIME_VIEW, this.onRemoveShouBianTimeView);
			addMessageListener(ModuleCommand.MISSION_SHOU_BIAN_STATUS_CHANGE, this.onShouBianStatusChange);

			addMessageListener(ModuleCommand.ENTER_GAME, this.enterGameHandler);
			addMessageListener(ModuleCommand.OPEN_MISSION_PANNEL, this.openMissionWindow);
			addMessageListener(ModuleCommand.MISSION_DO, this.onMissionDo);
			addMessageListener(ModuleCommand.NPC_CLICK_MISSION_LINK, this.onClickMissionLink);
			addMessageListener(ModuleCommand.MISSION_CANCEL, this.onCancelMission);
			addMessageListener(ModuleCommand.MISSION_LIST_UPDATE, this.onMissionListUpdate);
			addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);
			addMessageListener(ModuleCommand.MISSION_HIDE_FOLLOW_VIEW, this.hideFollowView);
			addMessageListener(ModuleCommand.MISSION_SHOW_FOLLOW_VIEW, this.showFollowView);
			addMessageListener(ModuleCommand.MISSION_CHANGE_FOLLOW_VIEW, this.changeFollowView);
			addMessageListener(ModuleCommand.HIDE_MISSION_NPC_PANEL, this.onHideMissionNpcManel);
			addMessageListener(ModuleCommand.SHOW_MISSION_NPC_PANEL, this.onShowMissionNpcManel);
			
			addMessageListener(ModuleCommand.CHANGE_MAP_ROLE_READY, onChangeMap);
			addMessageListener(NPCActionType.NA_81,this.openAutoMissionPanel);
			
			addMessageListener(ModuleCommand.MISSION_AUTO_SELECTED, this.onAutoMissionSelected);
			addMessageListener(ModuleCommand.MISSION_AUTO_UN_SELECTED, this.onAutoMissionUnSelected);
			
			addMessageListener(ModuleCommand.MISSION_AUTO_DO, this.onDoAutoMission);
			addMessageListener(ModuleCommand.MISSION_REQUEST_LIST_AUTO_MISSION, this.requestListAutoMission);
			
			addSocketListener(SocketCommand.MISSION_LIST, this.onListReturn);
			addSocketListener(SocketCommand.MISSION_DO, this.onMissionDoReturn);
			addSocketListener(SocketCommand.MISSION_UPDATE, this.onMissionUpdate);
			addSocketListener(SocketCommand.MISSION_LISTENER, this.onMissionListenerUpdate);
			addSocketListener(SocketCommand.MISSION_CANCEL, this.onCancelMissionReturn);
			
			addSocketListener(SocketCommand.MISSION_LIST_AUTO, this.onListAutoMissionReturn);
			addSocketListener(SocketCommand.MISSION_DO_AUTO, this.onDoAutoMissionReturn);

		}

		/**
		 * 显示任务的NPC面板 
		 */		
		private function onShowMissionNpcManel():void {
			if ( _missionNPCPanel ) {
				_missionNPCPanel.visible=true;
			}

		}

		/**
		 * 隐藏任务的NPC面板 
		 * 
		 */		
		private function onHideMissionNpcManel():void {
			if ( _missionNPCPanel ) {
				_missionNPCPanel.visible=false;
			}
		}
		
		/**
		 * 地图跳转
		 */
		private function onChangeMap():void { //王座争霸战不显示任务追踪
			var isRobMap:Boolean=SceneDataManager.isRobKingMap;
			var mapId:int=SceneDataManager.mapData.map_id;

			if ( isRobMap || HeroFBModule.isOpenHeroFBPanel || isInMapNoMission( mapId )) {
				followView.visible=false;
			} else {
				followView.visible=true;
			}
		}

		/**
		 * 判断是否是不显示任务列表的地图 
		 */		
		private function isInMapNoMission( mapId:int ):Boolean {
			var isHeroFBMapId:Boolean=HeroFBModule.getInstance().isMapHeroFB( mapId );
			var isSceneWarFbMapId:Boolean=SceneWarFbModule.getInstance().isSceneWarFbMapId( mapId );
			var isCountryTreasureFbMapId:Boolean=( 10500 == mapId );
			var isVieWarFbMapId:Boolean=( 10400 == mapId );
			var isEducateFbMapId:Boolean=( 10600 == mapId );
			var isSingleFbMapId:Boolean=MissionFBModule.getInstance().isMapMisssionFB(mapId);
				

			return isHeroFBMapId || isSceneWarFbMapId || isCountryTreasureFbMapId || isVieWarFbMapId || isEducateFbMapId
				|| isSingleFbMapId;
		}
		
		public function onMissionLink(text:String):void {
			if( isSpecialEventLink(text) ){
				return;
			}
			var args:Array=text.split(',');
			var type:int=parseInt(args.shift());
			var missionID:int=parseInt(args.shift());
			
			if(this.checkDoingAuto(missionID) == true){
				return;
			}
			
			switch (type) {
				case MissionConstant.FOLLOW_LINK_TYPE_NPC:
					PlayerGuideModule.getInstance().checkHideTaskGuide(true);
					PathUtil.findNpcAndOpen(parseInt(args[0]), RunVo.RUN_TYPE_ADVANCED);
					break;
				case MissionConstant.FOLLOW_LINK_TYPE_MONSTER:
					PlayerGuideModule.getInstance().checkHideTaskGuide(false);
					PathUtil.findMonsterAndAttack(args[0], args[1], RunVo.RUN_TYPE_ADVANCED);
					break;
				case MissionConstant.FOLLOW_LINK_TYPE_COLLECT:
					PlayerGuideModule.getInstance().checkHideTaskGuide(false);
					PathUtil.findCollectAndTake(args[0], args[1], args[2], args[3], RunVo.RUN_TYPE_ADVANCED);
					break;
				case MissionConstant.FOLLOW_LINK_TYPE_SHOP_BUY_GROUP:
					var shopID:int = parseInt(args[0]);
					dispatch(ModuleCommand.OPEN_SHOP_PANEL);
					break;
				
				default:
					break;
			}
		}

		/**
		 * 是否特殊的事件处理 
		 */		
		private function isSpecialEventLink( text:String ):Boolean {
			var npcId:String = "";
			
			if( text=='open_activity_benefit' ){
				ActivityModule.getInstance().openActivityBenefit(); //打开领取福利
				return true;
			}else if( text=='find_hero_fb' ){
				npcId = "1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100133";		//打开大明英雄副本NPC
				PathUtil.findNpcAndOpen(npcId);
				return true;
			}else if( text=='find_poyanghu_fb' ){
				npcId = "1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100135";		//打开鄱阳湖副本NPC
				PathUtil.findNpcAndOpen(npcId);
				return true;
			}else if( text=='open_stove_window' ){
				Dispatch.dispatch( ModuleCommand.OPEN_STOVE_WINDOW ); //打开天工炉
				return true;
			}else if( text=='open_forgeshop_window' ){			//打开铁匠铺
				var roleFaction:int = GlobalObjectManager.getInstance().getRoleFactionID();
				var tieJiangNPCID:int = NPCConstant.NPC_JING_CHENG_TIE_JIANG_ID[roleFaction];
				PathUtil.findNpcAndOpen(tieJiangNPCID);
				return true;
			}
			
			
			return false;
		}
		
		/**
		 * 守边视图对象
		 */
		private var _shouBianTimeView:MissionShouBianTimeView;

		/**
		 * 移除守边视图
		 */
		private function onRemoveShouBianTimeView():void {
			if (this._shouBianTimeView) {
				
				BroadcastModule.getInstance().countdownView.removeChildren(this._shouBianTimeView);
				this._shouBianTimeView.dispose();
//				SceneTopTimeIconManager.getInstance().dealPosition();
				LoopManager.removeFromSceond(MissionConstant.SHOU_BIAN_TIMER_KEY);
			}
		}

		/**
		 * 更新守边视图
		 */
		private function onUpdateShouBianTimeViewVO(missionVO:MissionVO):void {
			if (missionVO.currentModelStatus == MissionConstant.FIRST_STATUS) {
				if (this._shouBianTimeView) {
					this._shouBianTimeView.dispose();
					this._shouBianTimeView=null;
				}
				return;
			}
			if (!this._shouBianTimeView) {
				this._shouBianTimeView=new MissionShouBianTimeView(missionVO);
				LoopManager.addToSecond(MissionConstant.SHOU_BIAN_TIMER_KEY, this.updateShouBianTimeView);
//				SceneTopTimeIconManager.getInstance().addChildren(this._shouBianTimeView);
				BroadcastModule.getInstance().countdownView.addChilren(this._shouBianTimeView);
			} else {
				this._shouBianTimeView.vo=missionVO;
			}
		}


		private var first:Boolean=true;

		/**
		 * 显示欢迎窗口
		 *
		 */
		public function showWelcomePannel():void {
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			if (level == 1 && first) {
				first=false;
				MissionWelcome.getInstance().callBack=welcomeTaskCloseFunc;
				MissionWelcome.getInstance().loadWelcome();
			}
		}

		public function welcomeTaskCloseFunc():void {
			var ncpID:String="1" + GlobalObjectManager.getInstance().getRoleFactionID() + "000101";
			PathUtil.findNpcAndOpen( ncpID, RunVo.RUN_TYPE_ADVANCED, false, true );
		}

		/**
		 * 新手任务自动打怪或自动采集
		 * @param missionVO
		 * @return
		 *
		 */
		private function autoFindTargetByListener(missionVO:MissionVO):void {
			if (missionVO != null) {
				for each (var listener:p_mission_listener in missionVO.listenerList) {
					if (listener.type == MissionConstant.LISTENER_TYPE_MONSTER) {
						PathUtil.findMonsterAndAttack(listener.int_list[0], listener.value, RunVo.RUN_TYPE_ADVANCED);
					} else if (listener.type == MissionConstant.LISTENER_TYPE_PROP) {
						var collectData:Array = missionVO.statusCollectList[0];
						if (collectData != null) {
							var mapID:int = collectData[MissionStatusCollectIndex.I_MAP];
							var tx:int = collectData[MissionStatusCollectIndex.I_TX];
							var ty:int = collectData[MissionStatusCollectIndex.I_TY];
							var pointBaseID:int = collectData[MissionStatusCollectIndex.I_BASEID];
							PathUtil.findCollectAndTake(pointBaseID, mapID, tx, ty, RunVo.RUN_TYPE_ADVANCED);
						} else if (missionVO.model == MissionConstant.MODEL_3) {
							PathUtil.findMonsterAndAttack(listener.int_list[0], listener.int_list[1],
								RunVo.RUN_TYPE_ADVANCED);
						}
					}
				}
			}
		}

		/**
		 * 自动找到主线任务并自动点击追踪
		 *
		 */
		public function autoFindTarget():Boolean {
			var missionVO:MissionVO=MissionDataManager.getInstance().getMainMission();
			if (missionVO != null) {
				if (missionVO.statusNpcList.length > 0) {
					var NpcID:int=missionVO.statusNpcList[0];
					PathUtil.findNpcAndOpen(NpcID, RunVo.RUN_TYPE_ADVANCED);
				} else {
					for each (var listener:p_mission_listener in missionVO.listenerList) {
						if (listener.type == MissionConstant.LISTENER_TYPE_MONSTER) {
							PathUtil.findMonsterAndAttack(listener.int_list[0], listener.value, RunVo.RUN_TYPE_ADVANCED);
						} else if (listener.type == MissionConstant.LISTENER_TYPE_PROP ) {
							var collectData:Array=missionVO.statusCollectList[0];
							if (collectData != null) {
								var mapID:int=collectData[MissionStatusCollectIndex.I_MAP];
								var tx:int=collectData[MissionStatusCollectIndex.I_TX];
								var ty:int=collectData[MissionStatusCollectIndex.I_TY];
								var pointBaseID:int=collectData[MissionStatusCollectIndex.I_BASEID];
								PathUtil.findCollectAndTake(pointBaseID, mapID, tx, ty, RunVo.RUN_TYPE_ADVANCED);
							} else if(missionVO.model == MissionConstant.MODEL_3) {
								PathUtil.findMonsterAndAttack(listener.int_list[0], listener.int_list[1], RunVo.RUN_TYPE_ADVANCED);
							}
						}
					}
				}
				return true;
			}
			return false;
		}

		/**
		 * 供LoopManager调用的守边视图更新接口
		 */
		private function updateShouBianTimeView():void {
			if (this._shouBianTimeView) {
				this._shouBianTimeView.update();
			} else {
				LoopManager.removeFromSceond(MissionConstant.SHOU_BIAN_TIMER_KEY);
			}
		}

		/**
		 * 守边状态切换
		 */
		private function onShouBianStatusChange(missionID:int):void {
			var doVO:m_mission_do_tos=new m_mission_do_tos();
			doVO.id=missionID;
			doVO.npc_id=0;
			sendSocketMessage(doVO);
		}

		/**
		 * 当一个任务执行后返回会触发这里
		 * 当角色距离符合要求时(我那个时代写的是5格子) 且有任务 则自动打开面板
		 */
		private function autoShowNextMission():void {
			_isWaitingShowNext = false;
			var npcID:int=this._missionDOPreNPCID;
			if (npcID == 0 ) {
				return;
			}
			
			if( !MissionDataManager.getInstance().hasNpcMission(npcID) ){
				return;
			}
			
			if (NPCModule.getInstance().checkNPCNearby(npcID)) {
				var npcMissionList:Object=MissionDataManager.getInstance().getNpcMissionList(npcID);
				if (!_missionNPCPanel) {
					_missionNPCPanel=new MissionNPCPanel();
				}
				
				if (npcMissionList[this._missionDOPreMissionID]) {
					var missionVO:MissionVO = npcMissionList[this._missionDOPreMissionID];
					//当前任务的下一个状态是可接、可交的任务时，才自动弹窗
					if ( missionVO.currentStatus == MissionConstant.STATUS_ACCEPT || missionVO.currentStatus == MissionConstant.
						STATUS_FINISH ) {
						this._missionNPCPanel.npcID=npcID;
						this._missionNPCPanel.vo=missionVO;
						this._missionNPCPanel.open();
					}else{
						//否则显示任务列表窗口						
						NPCModule.getInstance().openNPCPannel(npcID);
					}
				} else {
					//下一个任务是可接、可交的任务时，才自动弹窗
					var npcMissionIDList:Array=MissionDataManager.getInstance().getNpcMissionIDListSorted(npcID);
					if (npcMissionIDList.length > 0) {
						doShowNextNpcMission(npcMissionList,npcMissionIDList,npcID);
					}
				}
			} else {
				if( shouldAutoFindToCommitMission() ){
					PathUtil.findNpcAndOpen(npcID, RunVo.RUN_TYPE_ADVANCED);	
				}
				
			}

			this._missionDOPreNPCID=0;
			this._missionDOPreMissionID=0;
		}

		/**
		 * 只有10级以内才会自动跑回去交任务
		 * @return 
		 * 
		 */		
		private function shouldAutoFindToCommitMission():Boolean {
			return isNewPlayerByGuide();
		}
		
		/**
		 * 判断并显示本NPC的一个任务 
		 */		
		private function doShowNextNpcMission( npcMissionList:Object, missionIDList:Array, npcID:int ):Boolean {
			for ( var i:int=0; i < missionIDList.length; i++ ) {
				var missionVO:MissionVO=npcMissionList[ missionIDList[ i ]];
				//只有是可接、可交的任务时，才自动弹窗
				if ( missionVO.currentStatus == MissionConstant.STATUS_ACCEPT || missionVO.currentStatus == MissionConstant.
					STATUS_FINISH ) {
					this._missionNPCPanel.npcID=npcID;
					this._missionNPCPanel.vo=missionVO;
					this._missionNPCPanel.open();
					return true;
				}
			}

			return false;
		}		  
		
		/**
		 * 自动打开NPC身上的第一个任务
		 */
		public function autoShowOneMission(npcID:int):Boolean {
			var npcMissionIDList:Array=MissionDataManager.getInstance().getNpcMissionIDListSorted(npcID);

			if (npcMissionIDList && npcMissionIDList.length == 1) {
				var missionID:int=npcMissionIDList[0];
				var missionVO:MissionVO=MissionDataManager.getInstance().getListMission(missionID);
				// 必须针对新手任务做特殊处理
				if ( this.isNewPlayerByGuide() ) {
					if (!_missionNPCPanel) {
						_missionNPCPanel=new MissionNPCPanel();
					}

					this._missionNPCPanel.npcID=npcID;
					this._missionNPCPanel.vo=missionVO;
					this._missionNPCPanel.open();
					return true;
				} else {
					if (NPCModule.getInstance().hasAction(npcID) == false) {
						if (!_missionNPCPanel) {
							_missionNPCPanel=new MissionNPCPanel();
						}

						//只有是可接、可交的任务时，才自动弹窗
						if (missionVO.currentStatus == MissionConstant.STATUS_ACCEPT || missionVO.currentStatus ==
							MissionConstant.STATUS_FINISH) {
							this._missionNPCPanel.npcID = npcID;
							this._missionNPCPanel.vo = missionVO;
							this._missionNPCPanel.open();
							return true;
						}
					}
				}
			}

			return false;
		}
		
		

		/**
		 * 更新任务数据
		 */
		private function onMissionListUpdate():void {
			if (this._missionWindow && WindowManager.getInstance().isPopUp(this._missionWindow)) {
				this._missionWindow.updateMissionList();
			}
			
			if( _isWaitingShowNext ){
				return;
			}
			
			if( waitToShowNextMission() ){
				_isWaitingShowNext = true;
			}else{
				autoShowNextMission();	
			}
			
		}

		/**
		 * 完成打怪任务之后，延时显示显示下一个任务的提交对话框
		 * @return 
		 * 
		 */		
		private function waitToShowNextMission():Boolean {
			var currMissionList:Object=MissionDataManager.getInstance().currentMissionList;
			if ( currMissionList && (_doingMissionID>0) && currMissionList[ _doingMissionID ]) {
				var missVO:MissionVO=currMissionList[ _doingMissionID ];
				if ( missVO && ( missVO.model == 2 || missVO.model == 3 ) && missVO.currentStatus == MissionConstant.STATUS_FINISH ) {
					LoopManager.setTimeout( autoShowNextMission, 2000 );
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 取消任务
		 */
		private function onCancelMission(vo:m_mission_cancel_tos):void {
			if( isMissionFbMissionId(vo.id) ){
				Tips.getInstance().addTipsMsg("副本任务已经完成，不能取消");
			}else{
			sendSocketMessage(vo);
		}
		}

		/**
		 * 判断是否是任务副本的任务ID 
		 */		
		private function isMissionFbMissionId( id:int ):Boolean {
			return ( id == 4042 || id == 4043 || id == 4044 ) 
			|| ( id == 4126 || id == 4127 || id == 4128 );
		}		

		/**
		 * 取消任务返回
		 */
		private function onCancelMissionReturn(vo:m_mission_cancel_toc):void {
			if (MissionError.getError(vo) == true) {
				return;
			}
			
			var missionBaseInfo:Array=MissionDataManager.getInstance().getBase(vo.id);
			var tips:String=missionBaseInfo[MissionBaseIndex.NAME];
			tips='取消了任务：<font color="#ffff00">' + tips + '</font>';

			BroadcastSelf.getInstance().appendMsg(tips);
		}

		/**
		 * 任务侦听器更新
		 */
		private function onMissionListenerUpdate(vo:m_mission_listener_toc):void {
			if (MissionError.getError(vo) == true) {
				return;
			}
			
			var missionVO:MissionVO=MissionDataManager.getInstance().getListMission(vo.mission_id);
			if (missionVO) {
				var listenerKey:String=vo.listener.type + '_' + vo.listener.value;
				missionVO.listenerList[listenerKey]=vo.listener;
				MissionDataManager.getInstance().makeMissionVO(missionVO);
				MissionDataManager.getInstance().updateCanAcceptList(missionVO);
				MissionDataManager.getInstance().updateCurrentList(missionVO);
				MissionDataManager.getInstance().dispatchMissionListUpdate();
			}

			var listenerType:int=vo.listener.type;
			var listenerValue:int=vo.listener.value;
			var currentNum:int=vo.listener.current_num;
			var needNum:int=vo.listener.need_num;

			switch (listenerType) {
				case MissionConstant.LISTENER_TYPE_MONSTER:
					var monster:MonsterType=MonsterConfig.hash[listenerValue];
					showListenerTips(monster.monstername, currentNum, needNum);
					if ( isNewPlayerByGuide()) {
						//停止新手的自动打怪
						if( currentNum<needNum ){
							SceneModule.getInstance().startAutoHitByPlayGuide();
						}else{
							SceneModule.getInstance().stopAutoHitByPlayGuide();
						}
					} else if( PlayerGuideModule.getInstance().isMissionGuideHang(missionVO.id) ){
						//引导自动打怪
						if( needNum>currentNum ){
							PlayerGuideModule.getInstance().showHangGuideTip( missionVO.id );
						}else if( needNum==currentNum ){
							SceneModule.getInstance().stopAutoHitByPlayGuide();
						}
					} else if ( needNum > 1 && needNum > currentNum ) {
						//提示自动打怪
						if ( currentNum < 5 && !SceneModule.isAutoHit ) {
							BroadcastView.getInstance().addBroadcastMsg( "按'Z'键或快捷栏的‘挂机’可自动打怪" );
						}
					}
					break;
				case MissionConstant.LISTENER_TYPE_PROP:
					if( isNewPlayerByGuide() ){
						if( currentNum<needNum ){
							LoopManager.setTimeout(autoFindTargetByListener,1500,[missionVO]);	
						}	
					}else if( PlayerGuideModule.getInstance().isMissionGuideHang(missionVO.id) ){
						//引导自动打怪
						if( needNum>currentNum ){
							PlayerGuideModule.getInstance().showHangGuideTip( missionVO.id );
						}else if( needNum==currentNum ){
							SceneModule.getInstance().stopAutoHitByPlayGuide();
						}
					}
					break;
				case MissionConstant.LISTENER_TYPE_SHOP_BUY_PROP:
					var propBaseItemInfo:BaseItemVO=ItemLocator.getInstance().getObject(listenerValue);
					showListenerTips(propBaseItemInfo.name, currentNum, needNum);
					break;
				default:
					break;
			}
			
		}

		/**
		 * 中央广播及右下角提示侦听器数据
		 */
		private function showListenerTips(name:String, currentNum:int, needNum:int):void {
			var tips:String=name + ':' + currentNum + '/' + needNum;
			tips='<font color="#ffff00">' + tips + '</font>';
			Tips.getInstance().addTipsMsg(tips);
			BroadcastSelf.getInstance().appendMsg(tips);
		}
		
		/**
		 * 判断是否为新手玩家的任务
		 */		
		public function isNewPlayerByGuide():Boolean{
			var roleLevel:int = GlobalObjectManager.getInstance().user.attr.level;
			return roleLevel<=9;
		}
		
		/**
		 * 任务单条更新
		 */
		private function onMissionUpdate(vo:m_mission_update_toc):void {
			var delList:Array = vo.del_mission_list;
			var updateList:Array = vo.update_mission_list;
			MissionDataManager.getInstance().updateMissionList(delList, updateList);
		}

		/**
		 * 做任务
		 */
		private function onMissionDo(vo:m_mission_do_tos):void {
			if(this.checkDoingAuto(vo.id) == true){
				return;
			}
			sendSocketMessage(vo);
			this._doingMissionID = vo.id;
			this._missionDOPreNPCID=vo.npc_id;
			this._missionDOPreMissionID=vo.id;
		}

		/**
		 * 检查是否正在自动任务
		 */
		public function checkDoingAuto(missionID:int):Boolean{
			var missionVO:MissionVO = MissionDataManager.getInstance().getListMission(missionID);
			if(!missionVO || missionVO.currentModelStatus != MissionConstant.FIRST_STATUS){
				return false;
			} 
			
			if(this.getAutoMissionPanel().doingAuto(missionID, missionVO.bigGroup) == true){
				var tips:String = '任务委托中，请先等待任务委托完成。';
				BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">'+tips+'</font>');
				Alert.show(tips, "提示", null, null, "关闭", "", null, false);
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * 做任务返回
		 */
		private function onMissionDoReturn(vo:m_mission_do_toc):void {
			if (MissionError.getError(vo) == true) {
				return;
			}
			
			if(vo.current_status == MissionConstant.STATUS_FINISH ){
				_doingMissionID = 0;
			}
			
			var missionID:int = vo.id;
			var missionBaseInfo:Array=MissionDataManager.getInstance().getBase(missionID);
			var tips:String=missionBaseInfo[MissionBaseIndex.NAME];
			var missionModel:int = missionBaseInfo[MissionBaseIndex.MODEL];
				
			if (vo.pre_status == MissionConstant.STATUS_ACCEPT) {
				PlayerGuideModule.getInstance().hookMissionAccept(MissionDataManager.getInstance().getListMission(missionID));
				tips=this.wrapperAccept(tips, vo);
				BroadcastSelf.getInstance().appendMsg(tips);
			} else if (vo.pre_status == MissionConstant.STATUS_FINISH) {
				PlayerGuideModule.getInstance().hookMissionFinish(missionID);
				tips=this.wrapperFinish(tips, vo);
				BroadcastSelf.getInstance().appendMsg(tips);
				//10~20级，如果通过任务得到装备，那么将会进行背包闪烁，和装备的闪烁
				var roleLevel:int = GlobalObjectManager.getInstance().user.attr.level;
				if (roleLevel >= 10 && roleLevel <= 20) {
					if (vo.reward_data != null && vo.reward_data.prop != null && vo.reward_data.prop.
						length > 0) {
						var hasEquipReward:Boolean = false;
						for each (var p:p_mission_prop in vo.reward_data.prop) {
							if (p.prop_type == 3) {
								hasEquipReward = true;
								break;
							}
						}
						if( hasEquipReward ){
							//NavigationModule.getInstance().startBagFlick();
						}
					}
				}
				
				
			}
			if(vo.pre_status != MissionConstant.STATUS_FINISH && vo.current_status == MissionConstant.STATUS_FINISH){
				this.playMissionEffect(MissionConstant.EFFECT_CAN_FINISH);
			}else if(vo.pre_status == MissionConstant.STATUS_ACCEPT){
				this.playMissionEffect(MissionConstant.EFFECT_ACCEPT);
			}else if(vo.pre_status == MissionConstant.STATUS_FINISH){
				this.playMissionEffect(MissionConstant.EFFECT_FINISH);
			}
			
			/**
			 * 处理不同模型
			 */
			var missionVO:MissionVO = MissionDataManager.getInstance().getListMission(missionID);
			switch(missionModel){
				case MissionConstant.MODEL_6:
					this.missionDoReturn_M6(missionVO, missionBaseInfo, vo);
					break;
				
				default:
					break;
			}
		}

		private function missionDoReturn_M6(missionVO:MissionVO, missionBaseInfo:Array, vo:m_mission_do_toc):void{
			if(vo.current_model_status == 1){
				var model6BuyPropList:Array = [];
				if(missionVO && missionVO.listenerList){
					for each(var model6Listener:p_mission_listener in missionVO.listenerList){
						var baseItemVO:BaseItemVO = ItemLocator.getInstance().getObject(model6Listener.value);
						if(baseItemVO){
							model6BuyPropList.push(baseItemVO.name);
						}
					}
				}
				
				if(model6BuyPropList.length == 0){
					model6BuyPropList = ['任务所需物品'];
				}
				
				var model6BuyPropStr:String = '<font color="#39ff0b">'+model6BuyPropList.join('</font>,<font color="#39ff0b">')+'</font>';
				var model6BuyTips:String = '<font color="#ffff00">请在在商城中购买 '+model6BuyPropStr+'。</font>';
				//dispatch(ModuleCommand.OPEN_SHOP_PANEL);//如果要自动打开商城 请取消注释
				Tips.getInstance().addTipsMsg(model6BuyTips);
				BroadcastSelf.getInstance().appendMsg(model6BuyTips);
			}
		}

		/**
		 * 任务列表返回处理
		 */
		private function onListReturn(vo:m_mission_list_toc):void {
			if (MissionError.getError(vo) == true) {
				return;
			}

			MissionDataManager.getInstance().initMissionList(vo.list);
			//显示欢迎窗口
			showWelcomePannel();
			
			//20级以后请求自动任务列表
			var roleLevel:int = GlobalObjectManager.getInstance().user.attr.level;
			if (roleLevel >= 20) {
				this.requestListAutoMission();
			}
		}
		
		/**
		 * 自动任务列表
		 */
		private function requestListAutoMission():void{
			var vo:m_mission_list_auto_tos = new m_mission_list_auto_tos();
			this.sendSocketMessage(vo);
		}
		
		/**
		 * 自动任务列表返回
		 * @param vo
		 * 
		 */		
		private function onListAutoMissionReturn(vo:m_mission_list_auto_toc):void {
			MissionDataManager.getInstance().autoMissionList = vo.list;
			if( _autoMissionPanel ){
				_autoMissionPanel.listData = vo.list;
			}
			if( _missionWindow){
				_missionWindow.updateMissionList();
			}
		}
		
		/**
		 * 发起自动任务
		 */
		private function onDoAutoMission(doVOArr:Array):void{
			for each(var doVO:m_mission_do_auto_tos in doVOArr){
				this.sendSocketMessage(doVO);
			}
		}
		
		/**
		 * 发起自动任务返回
		 */
		private function onDoAutoMissionReturn(vo:m_mission_do_auto_toc):void {
			
			if (MissionError.getError(vo) == true) {
				return;
			}
			
			this.getAutoMissionPanel().updateDo(vo.auto_info);
		}
		
		/**
		 * 当自动任务被选择时
		 */
		private function onAutoMissionSelected(autoViewRender:AutoMissionItemRenderer):void{
			this.getAutoMissionPanel().addDo(autoViewRender);
			if(_missionWindow && _missionWindow.parent){
				_missionWindow.autoMissionView.addDo(autoViewRender);
			}
		}
		/**
		 * 当自动任务从列表里取消选择时
		 */
		private function onAutoMissionUnSelected(autoViewRender:AutoMissionItemRenderer):void{
			this.getAutoMissionPanel().removeFromDo(autoViewRender);
			if(_missionWindow && _missionWindow.parent){
				_missionWindow.autoMissionView.removeFromDo(autoViewRender);
			}
		}
		
		/**
		 * 进入游戏时调用
		 */
		public var followView:MissionFollowView;

		private function enterGameHandler():void {
			if (followView == null) {
				followView=new MissionFollowView();
				followView.x=GlobalObjectManager.GAME_WIDTH - 210;
				followView.y=190;
			}
			LayerManager.uiLayer.addChild(followView);
			
			//先加载任务数据
			this.requestList();
			//showWelcomePannel();
			//测试方法
			//this.loadMissionSetting();
		}

		/**
		 * 	请求服务器任务列表
		 */
		public function requestList():void {
			sendSocketMessage(new m_mission_list_tos());
		}

		/**
		 * 打开面板
		 */
		private var _missionWindow:MissionWindow;

		private function openMissionWindow(index:int=0):void {
			if (_missionWindow == null) {
				_missionWindow=new MissionWindow();
			}
			_missionWindow.open();
			_missionWindow.seleteIndex = index;
			WindowManager.getInstance().centerWindow(_missionWindow);
		}

		/**
		 * 打开委托任务的面板
		 */		
		private function openAutoMissionPanel(vo:NpcLinkVO=null):void {
			var panel:AutoMissionPanel = this.getAutoMissionPanel();
			WindowManager.getInstance().popUpWindow(panel);
			WindowManager.getInstance().centerWindow(panel);
			this.requestListAutoMission();
		}

		public function get missionNPCPanel():MissionNPCPanel {
			return _missionNPCPanel;
		}

		/**
		 * 当点击NPC面板上的任务链接时调用
		 */
		private var _missionNPCPanel:MissionNPCPanel;

		private function onClickMissionLink(linkVO:NpcLinkVO):void {
			if (!linkVO) {
				return;
			}

			if (!_missionNPCPanel) {
				_missionNPCPanel=new MissionNPCPanel();
			}

			_missionNPCPanel.npcID=linkVO.npcID;
			_missionNPCPanel.vo=linkVO.data as MissionVO;
			_missionNPCPanel.open();
		}

		/**
		 * 格式化接受任务输出
		 */
		private function wrapperAccept(missionName:String, doVO:m_mission_do_toc):String {
			var pattern:RegExp = /([0-9]+)/g;
			missionName = missionName.replace(pattern,"");
			return '<font color="#ffffff">成功领取任务：<font color="#ffff00">' + missionName + '</font></font>';
		}

		/**
		 * 格式化完成任务输出
		 */
		private function wrapperFinish(missionName:String, doVO:m_mission_do_toc):String {

			var rewardData:p_mission_reward_data=doVO.reward_data;
			var str:String='<font color="#ffffff">成功完成任务：<font color="#ffff00">' + missionName + '</font></font>\n';
			str+=MissionDataManager.getInstance().wrapperInt('经验', rewardData.exp);
			str+=MissionDataManager.getInstance().wrapperSilver('银子', rewardData.silver);
			str+=MissionDataManager.getInstance().wrapperSilver('绑定银子', rewardData.silver_bind);
			str+=MissionDataManager.getInstance().wrapperInt('声望', rewardData.prestige);
			for each (var propReward:p_mission_prop in rewardData.prop) {
				var baseItemVO:BaseItemVO=ItemLocator.getInstance().getObject(propReward.prop_id);
				str+=MissionDataManager.getInstance().wrapperProp(baseItemVO.name, propReward.prop_num);
			}
			return str;
		}

		private var _settingLoader:URLLoader;
		private var _settingRetryTimeout:int;
		/**
		 * 是否已经加载过
		 */
		private var _settingLoaded:Boolean=false;

		public function loadMissionSetting():void {

			//可能被多次触发 要防止
			if (this._settingLoaded) {
				return;
			}

			this._settingLoaded=true;

			//如果有重试的timer 清理之
			if (this._settingRetryTimeout > 0) {
				clearTimeout(this._settingRetryTimeout);
				this._settingRetryTimeout=0;
			}
			_settingLoader=new URLLoader();
			_settingLoader.dataFormat=URLLoaderDataFormat.BINARY;
			_settingLoader.addEventListener(Event.COMPLETE, this.onSettingComplete);
			_settingLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onSettingIOError);
			_settingLoader.addEventListener(IOErrorEvent.NETWORK_ERROR, this.onNetError);

			var url:String=GameConfig.MISSION_SETTING + '?r=' + Math.random();
			_settingLoader.load(new URLRequest(url));
		}

		/**
		 *舞台大小改变
		 */
		private function onStageResize(value:Object):void {
			if (followView) {
				if (followView.missionPursueBar && followView.missionPursueBar.visible) {
					followView.missionPursueBar.x=GlobalObjectManager.GAME_WIDTH - 18;
					followView.x=GlobalObjectManager.GAME_WIDTH;
					followView.y=190;
				} else {
					followView.x=followView.x=GlobalObjectManager.GAME_WIDTH - 210;
					followView.y=190;
				}
			}
		}

		/**
		 * 重新加载资源库
		 * 暂时无人调用 热升级预留接口
		 */
		public function reloadMissionSetting():void {
			this._settingLoaded=false;
			this.loadMissionSetting();
		}

		/**
		 * 任务配置加载完成
		 */
		private function onSettingComplete(event:Event):void {
			this._settingLoaded=false;
			MissionDataManager.getInstance().initMissionSetting(event.target.data);
			//this.requestList();
		}


		/**
		 * 任务配置IO错误
		 */
		private function onSettingIOError(event:IOErrorEvent):void {
			this._settingLoaded=false;
			if (!this._settingRetryTimeout) {
				this._settingRetryTimeout=setTimeout(this.loadMissionSetting, 2000);
			}
		}

		/**
		 * 任务配置网络错误
		 */
		private function onNetError(e:IOErrorEvent):void {
			this._settingLoaded=false;
			if (!this._settingRetryTimeout) {
				setTimeout(this.loadMissionSetting, 2000);
			}
		}

		/**
		 * 隐藏任务追踪面板
		 */

		private function hideFollowView():void {
			if (followView) {
				followView.visible = false;
			}
		}

		/**
		 * 显示任务追踪面板
		 */

		private function showFollowView():void {
			if (followView) {
				followView.visible = true;
			}
		}
		
		private function changeFollowView():void{
			if (followView) {
				if( followView.visible ){
					followView.visible = false;
				}else{
					followView.visible = true;
				}
			}
		}

		private function transformAlertLinkHandler(_e:TextEvent):void {
			Alert.removeAlert(this._transformAlertID);
			switch (_e.text) {
				case 'asvip':
					dispatch(ModuleCommand.VIP_PANEL);
					break;
				default:
					break;
			}
		}

		/**
		 * 直接传送到指定的地方(通过传送卷或VIP)
		 * @param linkArgs
		 * @param isVIP
		 * @return
		 *
		 */
		public function carryToPath(linkArgs:String, isVIP:Boolean=false):void {
			var args:Array=linkArgs.split(',');
			if (args.length > 1) {
				var type:int=parseInt(args.shift());
				var missionID:int = parseInt(args.shift());
				
				switch (type) {
					case MissionConstant.FOLLOW_LINK_TYPE_NPC:
						PathUtil.carryNPC(args[0], isVIP, RunVo.RUN_TYPE_ADVANCED);
						break;
					case MissionConstant.FOLLOW_LINK_TYPE_MONSTER:
						PathUtil.carryMonster(args[0], args[1], isVIP, RunVo.RUN_TYPE_ADVANCED);
						break;
					case MissionConstant.FOLLOW_LINK_TYPE_COLLECT:
						PathUtil.carryCollect(args[0], args[1], args[2], args[3], isVIP, RunVo.RUN_TYPE_ADVANCED);
						break;
					case MissionConstant.FOLLOW_LINK_TYPE_GOTO:
						var pt:Pt = new Pt(args[1],0,args[2]);
						PathUtil.carry(args[0],pt);
						break;
					default:
						break;
				}
			}

		}

		public function transGoto(linkArgs:String, _noAlert:Boolean=false):void {
			// VIP5免费传送
			if (VipModule.getInstance().getRoleVipLevel() >= 3) {
				carryToPath(linkArgs, true);
				return;
			}
			var chuanSongJuan:BaseItemVO=PackManager.getInstance().getGoodsByEffectType([ItemConstant.EFFECT_TRANSFORM_MAP]);
			var _freeTransTimes:int=VipModule.getInstance().getMissionTransferTimes();
			var _totalTimes:int=VipModule.getInstance().getMissionTransTotalTimes();
			var _isVip:Boolean=VipModule.getInstance().isVip();

			// VIP有一定的免费传送次数，而且提示跟普通玩家有区别。VIP还可以设置是否提示
			if (_freeTransTimes > 0) {
				if (!VipModule.getInstance().isMissionTransNoticeFree()) {
					carryToPath(linkArgs, true);
					return;
				}

				if (!_transferNotice) {
					_transferNotice=new MissionTransferNotice();
				}

				WindowManager.getInstance().popUpWindow(_transferNotice);
				_transferNotice.setNoticeTxt(_freeTransTimes, _totalTimes, linkArgs);
			} else {
				if (VipModule.getInstance().isVip()) {
					if (!VipModule.getInstance().isMissionTransNotic()) {
						carryToPath(linkArgs, true);
						return;
					}

					if (!_transferNotice) {
						_transferNotice=new MissionTransferNotice();
					}

					WindowManager.getInstance().popUpWindow(_transferNotice);
					_transferNotice.setNoticeTxt(_freeTransTimes, _totalTimes, linkArgs);
				} else {
					var transGotoYes:Function=function():void {
							carryToPath(linkArgs, false);
						}

					var alertMsg:String='确定使用一个<font color="#cde643">【传送卷】</font>传送到达任务地点？\n<font color="#cde643">【传送卷】</font>剩余数量：' + PackManager.getInstance().getGoodsNumByTypeId(10100001) + "；";
					alertMsg+=' <a href="event:asvip"><font color="#cde643"><u>成为VIP</u></font></a>可免费传送';

					if (!_noAlert) {
						this._transformAlertID=Alert.show(alertMsg, "小提示", transGotoYes, null, "确定", "取消", null, true, false, null, transformAlertLinkHandler);
					} else {
						if (chuanSongJuan) {
							transGotoYes();
						}
					}
				}

			}
		}
		
		
		/**
		 * 播放任务完成效果
		 */
		private function playMissionEffect(effectName:String):void{
			var effectUrl:String = GameConfig.ROOT_URL+'com/ui/other/'+effectName+'.swf';
			var effectX:int=LayerManager.alertLayer.stage.stageWidth/2;
			var effectY:int=130;
			var effect:Effect = Effect.getEffect();
			effect.show(effectUrl, effectX, effectY, LayerManager.alertLayer, 5);
		}
		
	}
}

class singleton {
}