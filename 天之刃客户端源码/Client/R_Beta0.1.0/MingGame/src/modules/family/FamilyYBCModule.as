package modules.family {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.MessageIconManager;
	import com.components.alert.Alert;
	import com.components.alert.Prompt;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUtils.RoleActState;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.accumulateExp.AccumulateExpModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.family.views.FamilyYBCPanel;
	import modules.family.views.GetFamilyYBCPanel;
	import modules.family.views.InviteFamilyYBCPanel;
	import modules.family.views.JoinFamilyYBCPanel;
	import modules.help.HelpManager;
	import modules.help.IntroduceConstant;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	
	import proto.common.p_accumulate_exp_info;
	import proto.common.p_family_member_info;
	import proto.line.m_family_ybc_accept_collect_toc;
	import proto.line.m_family_ybc_accept_collect_tos;
	import proto.line.m_family_ybc_accept_help_toc;
	import proto.line.m_family_ybc_accept_help_tos;
	import proto.line.m_family_ybc_add_hp_toc;
	import proto.line.m_family_ybc_add_hp_tos;
	import proto.line.m_family_ybc_agree_publish_toc;
	import proto.line.m_family_ybc_agree_publish_tos;
	import proto.line.m_family_ybc_alert_toc;
	import proto.line.m_family_ybc_alert_tos;
	import proto.line.m_family_ybc_call_help_toc;
	import proto.line.m_family_ybc_collect_toc;
	import proto.line.m_family_ybc_collect_tos;
	import proto.line.m_family_ybc_commit_toc;
	import proto.line.m_family_ybc_commit_tos;
	import proto.line.m_family_ybc_giveup_toc;
	import proto.line.m_family_ybc_giveup_tos;
	import proto.line.m_family_ybc_invite_toc;
	import proto.line.m_family_ybc_invite_tos;
	import proto.line.m_family_ybc_kick_toc;
	import proto.line.m_family_ybc_kick_tos;
	import proto.line.m_family_ybc_list_toc;
	import proto.line.m_family_ybc_list_tos;
	import proto.line.m_family_ybc_publish_toc;
	import proto.line.m_family_ybc_publish_tos;
	import proto.line.m_family_ybc_status_toc;
	import proto.line.m_family_ybc_sure_toc;
	import proto.line.m_family_ybc_sure_tos;
	import proto.line.m_trainingcamp_stop_tos;

	public class FamilyYBCModule extends BaseModule {
		private static var _instance:FamilyYBCModule;
		public var showYbcArrow:Boolean = false;

		public function FamilyYBCModule() {

		}

		public static function getInstance():FamilyYBCModule {
			if (_instance == null)
				_instance=new FamilyYBCModule();
			return _instance;
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.OPEN_FAMILY_YBC_PEANL, openFamilyYBCPanel);
			addMessageListener(NPCActionType.NA_90, commitFamilyYBC);
			addMessageListener(NPCActionType.NA_82, publishNormalYBC);
			addMessageListener(NPCActionType.NA_83, publishHighYBC);
			addMessageListener(ModuleCommand.FAMILY_CAR_TO_CONVENE, openCollectPanel);
			addMessageListener(NPCActionType.NA_84, openIntroduce);
			addMessageListener(NPCActionType.NA_85, openCollectPanel);
			addMessageListener(ModuleCommand.CHANGE_MAP_ROLE_READY, showArrow);

			addSocketListener(SocketCommand.FAMILY_YBC_AGREE_PUBLISH, setAgreePublishYBC);
			addSocketListener(SocketCommand.FAMILY_YBC_COMMIT, setCommitFamilyYBC);
			addSocketListener(SocketCommand.FAMILY_YBC_CALL_HELP, setCallHelp);
			addSocketListener(SocketCommand.FAMILY_YBC_ACCEPT_HELP, setStartHelp);
			addSocketListener(SocketCommand.FAMILY_YBC_COLLECT, setCollectFamilyMember);
			addSocketListener(SocketCommand.FAMILY_YBC_ACCEPT_COLLECT, setAcceptCollect);
			addSocketListener(SocketCommand.FAMILY_YBC_LIST, setFamilyYBCMembers);
			addSocketListener(SocketCommand.FAMILY_YBC_KICK, setKickMember);
			addSocketListener(SocketCommand.FAMILY_YBC_ADD_HP, setAddBiaoCheHP);
			addSocketListener(SocketCommand.FAMILY_YBC_PUBLISH, setPublishFamilyYBC);
			addSocketListener(SocketCommand.FAMILY_YBC_ALERT, setAlertMember);
			addSocketListener(SocketCommand.FAMILY_YBC_STATUS, setUpdateYBCStatus);
			addSocketListener(SocketCommand.FAMILY_YBC_SURE, setSurePublishYBC);
			addSocketListener(SocketCommand.FAMILY_YBC_INVITE, setInviteMember);
			addSocketListener(SocketCommand.FAMILY_YBC_GIVEUP, setGiveUpYBC);
		}

		/*********************************界面视图逻辑********************************************/
		
		private function showArrow():void
		{
			if (this.showYbcArrow) {
				this.dispatch(ModuleCommand.SCENE_SHOW_SIGN);
			}
		}

		private function publishNormalYBC(link:NpcLinkVO=null):void {
			publishFamilyYBC(FamilyConstants.YBC_TYPE_NORMAL);
		}

		private function publishHighYBC(link:NpcLinkVO=null):void {
			publishFamilyYBC(FamilyConstants.YBC_TYPE_HIGH);
		}

		private function openIntroduce(link:NpcLinkVO=null):void {
			HelpManager.getInstance().openIntroduce(IntroduceConstant.INTRO_FAMILY_YBC);
		}

		/**
		 * 处理单击“镖”字事件
		 */
		private function clickFamilyYBCIcon():void {
			if (myStatus == FamilyConstants.UN_JOIN_YBC && ybcStatus == FamilyConstants.YBC_PUBLISH_ING) {
				openYBCJoinPanel();
			} else if (myStatus == FamilyConstants.JOIN_YBC && ybcStatus == FamilyConstants.YBC_PUBLISH_ING) {
				openGetYBCPanel();
			}
			if (myStatus == FamilyConstants.JOIN_YBC && ybcStatus == FamilyConstants.YBC_PUBLISH_ED) {
				openFamilyYBCPanel();
			}
		}
		/**
		 * 打开加入镖车面板(未加入)
		 */
		private var joinYBCPanel:JoinFamilyYBCPanel;

		private function openYBCJoinPanel():void {
			if (joinYBCPanel == null) {
				joinYBCPanel=new JoinFamilyYBCPanel();
			}
			joinYBCPanel.setYBCType(ybcType);
			joinYBCPanel.open();
			WindowManager.getInstance().centerWindow(joinYBCPanel);
		}
		/**
		 * 打开自己已经加入的镖车面板(加入了，当未开始)
		 */
		private var getYBCPanel:GetFamilyYBCPanel;

		private function openGetYBCPanel():void {
			if (getYBCPanel == null) {
				getYBCPanel=new GetFamilyYBCPanel();
			}
			getYBCPanel.setYBCType(ybcType);
			getYBCPanel.setMembers(members);
			WindowManager.getInstance().openDistanceWindow(getYBCPanel);
			getYBCPanel.x=65;
			getYBCPanel.y=65;
		}
		/**
		 * 打开镖车控制面板 (加入了，并已经开始)
		 */
		private var familyYBCPanel:FamilyYBCPanel;

		private function openFamilyYBCPanel():void {
			if (familyYBCPanel == null) {
				familyYBCPanel=new FamilyYBCPanel();
			}
			getFamilyYBCMembers();
			familyYBCPanel.open();
			WindowManager.getInstance().centerWindow(familyYBCPanel);
		}
		/**
		 * 打开邀请面板
		 */
		private var invitePanel:InviteFamilyYBCPanel;

		public function openCollectPanel(link:NpcLinkVO=null):void {
			if (isTakeYBC()) {
				if (invitePanel == null) {
					invitePanel=new InviteFamilyYBCPanel();
				}
				invitePanel.sendFunc=collectFamilyMember;
				WindowManager.getInstance().popUpWindow(invitePanel, WindowManager.UNREMOVE);
				WindowManager.getInstance().centerWindow(invitePanel);
			}
		}

		/**
		 * 当押镖结束(销毁所有面板)
		 */
		private function disposeFamilyPanel():void {
			disposePanel(joinYBCPanel);
			disposePanel(getYBCPanel);
			disposePanel(familyYBCPanel);
			joinYBCPanel=null;
			getYBCPanel=null;
			familyYBCPanel=null;
		}

		/**
		 * 销毁当个面板
		 */
		private function disposePanel(panel:BasePanel):void {
			if (panel) {
				panel.closeWindow();
				panel.dispose();
			}
		}

		/**
		 * 显示”镖“字
		 */
		public function showFamilyBiao():void {
			MessageIconManager.getInstance().showFamilyBiao(clickFamilyYBCIcon);
		}

		/**
		 * 供外部调用同时显示“镖”字和时间
		 */
		public function showIconAndTime(hasGoTime:int):void {
			showFamilyBiao();
			MessageIconManager.getInstance().showFamilyYBCTime(hasGoTime);
		}

		/**
		 * 移除拉镖状态 相关的界面
		 */
		public function removeYBCViews():void {
			this.showYbcArrow = false;
//			SceneModule.getInstance().view.removeYBCArrow();
			this.dispatch(ModuleCommand.SCENE_CLEAR_SIGN);
			disposeFamilyPanel();
			MessageIconManager.getInstance().removeFamilyBiao();
			MessageIconManager.getInstance().removeFamilyYBCTime();
			myStatus=FamilyConstants.UN_JOIN_YBC;
		}

		/**
		 * 获取镖车押金 (带单位的形式,xxx银xxx两xxx文)
		 */
		public function getYBCMoney(type:int):String {
			var money:Number=getMoney(type);
			if (money == 0) {
				return "需要25级";
			}
			return MoneyTransformUtil.silverToOtherString(getMoney(type));
		}

		/**
		 * 获取镖车押金
		 */
		public function getMoney(type:int):Number {
			return FamilyConstants.getMoney(type);
		}

		/**
		 * 判断是否可以接镖车
		 */
		private function isTakeYBC():Boolean {
			if (ybcStatus == FamilyConstants.YBC_PUBLISH_ED) {
				Tips.getInstance().addTipsMsg("当前门派正在进行门派拉镖。");
				return false;
			}
			var factionId:int=FamilyLocator.getInstance().getRoleID();
			if (factionId == FamilyConstants.ZY) {
				Tips.getInstance().addTipsMsg("门派拉镖是集体活动，掌门或长老才能发布。");
				return false;
			}
			if (GlobalObjectManager.getInstance().user.attr.level < 25) {
				Tips.getInstance().addTipsMsg("需要25级才能进行门派拉镖。");
				return false;
			}
			return true;
		}

		/**
		 * 设置门派拉镖状态(0：未发布，1：发布中，2，发布了.)
		 */
		public function set ybcStatus(value:int):void {
			FamilyLocator.getInstance().familyInfo.ybc_status=value;
			if (value == FamilyConstants.YBC_PUBLISH_ING) {
				disposePanel(joinYBCPanel);
				joinYBCPanel=null;
			}
			if (value == FamilyConstants.YBC_PUBLISH_ED) {
				disposePanel(getYBCPanel);
				getYBCPanel=null;
			}
		}

		public function get ybcStatus():int {
			return FamilyLocator.getInstance().familyInfo.ybc_status;
		}
		/**
		 * 获取个人当前拉镖状态 (1,未加入，2，加入)
		 */
		private var _myStatus:int=FamilyConstants.UN_JOIN_YBC;

		public function set myStatus(value:int):void {
			_myStatus=value;
			if (value == FamilyConstants.JOIN_YBC) {
				disposePanel(joinYBCPanel);
				joinYBCPanel=null;
			}
		}

		public function get myStatus():int {
			return _myStatus;
		}

		/**
		 * 设置谁发布的拉镖
		 */
		public function set ybcCreator(roleId:int):void {
			FamilyLocator.getInstance().familyInfo.ybc_creator_id=roleId;
		}

		public function get ybcCreator():int {
			return FamilyLocator.getInstance().familyInfo.ybc_creator_id;
		}

		/**
		 * 设置拉镖的类型
		 */
		public function set ybcType(type:int):void {
			FamilyLocator.getInstance().familyInfo.ybc_type=type;
		}

		public function get ybcType():int {
			return FamilyLocator.getInstance().familyInfo.ybc_type;
		}
		/**
		 * 更新入拉镖活动的帮众列表
		 */
		private var memberInfos:Dictionary;
		private var members:Array;

		public function setJoinMembers(ids:Array):void {
			if (memberInfos == null) {
				memberInfos=new Dictionary();
			}
			members=[];
			for each (var roleId:int in ids) {
				var obj:Object=members[roleId];
				if (obj == null) {
					var roleInfo:p_family_member_info=FamilyLocator.getInstance().getMemberById(roleId);
					if (roleInfo == null)
						continue;
					obj={roleId: roleId, roleName: roleInfo.role_name};
					memberInfos[roleId]=obj;
				}
				members.push(obj);
			}
			if (getYBCPanel) {
				getYBCPanel.setMembers(members);
			}
		}

		/**
		 * 帮众退出拉镖活动
		 */
		public function removeJoinMember(roleId:int):void {
			if (members == null)
				return;
			for (var i:int=0; i < members.length; i++) {
				var obj:Object=members[i];
				if (obj.roleId == roleId) {
					members.splice(i, 1);
					if (getYBCPanel) {
						getYBCPanel.setMembers(members);
					}
					break;
				}
			}
		}

		/*********************************消息发送逻辑********************************************/
		/**
		 * 发布镖车
		 */
		public function publishFamilyYBC(ybc_type:int):void {
			if (isTakeYBC()) {
				var vo:m_family_ybc_publish_tos=new m_family_ybc_publish_tos();
				vo.type=ybc_type;
				sendSocketMessage(vo);
			}
		}

		/**
		 * 接受开始拉镖
		 */
		public function agreePublishYBC():void {
			sendSocketMessage(new m_family_ybc_agree_publish_tos());
		}

		/**
		 * "确定" 开始 拉镖活动
		 */
		public function surePublishYBC():void {
			sendSocketMessage(new m_family_ybc_sure_tos());
		}

		/**
		 * "取消" 拉镖活动
		 */
		public function giveUpYBC():void {
			sendSocketMessage(new m_family_ybc_giveup_tos());
		}

		/**
		 * 召集帮众
		 */
		public function collectFamilyMember(content:String):void {
			var vo:m_family_ybc_collect_tos=new m_family_ybc_collect_tos();
			vo.content=content;
			sendSocketMessage(vo);
		}

		/**
		 * 邀请所有帮众
		 */
		public function inviteMember():void {
			sendSocketMessage(new m_family_ybc_invite_tos());
		}

		/**
		 * 前往拉镖地点
		 */
		public function acceptCollect():void {
			promptKey="";
			if (ybcStatus == FamilyConstants.YBC_PUBLISH_ED) {
				Tips.getInstance().addTipsMsg("门派拉镖活动已开始，无法传送。");
				return;
			}
			if(GlobalObjectManager.getInstance().user.base.status == RoleActState.TRAINING)
				cancelOnHook();	
			else
				sendSocketMessage(new m_family_ybc_accept_collect_tos());
		}

		/**
		 * 取消在线挂机
		 */
		private function cancelOnHook():void {
			sendSocketMessage(new m_trainingcamp_stop_tos);
			LoopManager.setTimeout(goFamily,800);
		}
		
		/**
		 * 结束挂机后再传送到拉镖地点
		 */		
		private function goFamily():void
		{
			sendSocketMessage(new m_family_ybc_accept_collect_tos());			
		}
		/**
		 * 完成运镖
		 */
		public function commitFamilyYBC(vo:NpcLinkVO=null):void {
			if (ybcStatus != FamilyConstants.YBC_PUBLISH_ED) {
				Tips.getInstance().addTipsMsg("当前门派没有进行门派拉镖活动！");
				return;
			}
			Alert.show("随行护送镖车的帮众都到齐了吗？确定要交镖车了吗？", "提示", yesHandler);
			function yesHandler():void {
				sendSocketMessage(new m_family_ybc_commit_tos());
			}
		}

		/**
		 * 获取拉镖成员
		 */
		public function getFamilyYBCMembers():void {
			sendSocketMessage(new m_family_ybc_list_tos());
		}

		/**
		 * 掌门踢人
		 */
		public function kickMember(roleId:int):void {
			var vo:m_family_ybc_kick_tos=new m_family_ybc_kick_tos();
			vo.role_id=roleId;
			sendSocketMessage(vo);
		}

		/**
		 * 为镖车加血
		 */
		public function addBiaoCheHP():void {
			sendSocketMessage(new m_family_ybc_add_hp_tos());
		}

		/**
		 * 前往营救
		 */
		public function startHelp():void {
			sendSocketMessage(new m_family_ybc_accept_help_tos());
		}

		/**
		 * 提醒帮众
		 */
		public function alertMember(roleId:int):void {
			var vo:m_family_ybc_alert_tos=new m_family_ybc_alert_tos();
			vo.role_id=roleId;
			sendSocketMessage(vo);
		}

		/*********************************消息接受并处理逻辑********************************************/
		/**
		 * 发布镖车 (返回)
		 */
		/**
		 * 发布镖车 (返回)
		 */
		//		private var inviteId:String="";
		private function setPublishFamilyYBC(data:Object):void {
			var vo:m_family_ybc_publish_toc=data as m_family_ybc_publish_toc;
			if (vo.succ) {
				ybcType=vo.type;
				ybcCreator=vo.owner_id;
				ybcStatus=FamilyConstants.YBC_PUBLISH_ING;
				if (!vo.return_self && vo.is_alert) {
					agreePublishYBC();
				} else if (vo.return_self) {
					myStatus=FamilyConstants.JOIN_YBC;
					setJoinMembers([ybcCreator]);
					openGetYBCPanel();
					var pcName:String=vo.type == FamilyConstants.YBC_TYPE_NORMAL ? "普通" : "厚实";
					BroadcastSelf.logger(HtmlUtil.font("成功申请领取" + pcName + "镖车， 收取押金" + MoneyTransformUtil.silverToOtherString(vo.silver), "#ffcc00"));
				} else if (!vo.return_self && !vo.is_alert) {
					openYBCJoinPanel();
				}
				showFamilyBiao();
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		/**
		 * 接受开始拉镖 (返回)
		 */
		public function setAgreePublishYBC(vo:m_family_ybc_agree_publish_toc):void {
			if (vo.succ) {
				if (vo.return_self) {
					myStatus=FamilyConstants.JOIN_YBC;
					showFamilyBiao();
					openGetYBCPanel();
					BroadcastSelf.logger(HtmlUtil.font("成功加入镖队，收取押金" + MoneyTransformUtil.silverToOtherString(vo.silver), "#ffcc00"));
					if (AccumulateExpModule.getInstace().hasFamilyYbcExp()) {
						var acc:p_accumulate_exp_info=AccumulateExpModule.getInstace().getFamilyYbcExp();
						BroadcastSelf.logger(HtmlUtil.font("提示：你已连续" + acc.day + "天未完成该任务，累计任务次数" + acc.day + "次，完成任务后可到" + HtmlUtil.link("累积经验管理员", "gotoNPC#1" + GlobalObjectManager.getInstance().user.base.faction_id + "100127", true) + "处领取大量额外的经验奖励。", "#00FF00"));
					}

				} else {
					Tips.getInstance().addTipsMsg("帮众" + HtmlUtil.font("[" + vo.role_name + "]", "#00ff00", 16) + "已经成功加入镖队伍！");
				}
				setJoinMembers(vo.ybc_role_id_list);
			} else {
				Alert.show(vo.reason, "提示", null, null, "确定", "", null, false);
			}
		}

		/**
		 * "确定" 开始 拉镖活动(返回)
		 */
		public function setSurePublishYBC(vo:m_family_ybc_sure_toc):void {
			if (vo.succ) {
				if (myStatus == FamilyConstants.JOIN_YBC) {
					Tips.getInstance().addTipsMsg("门派拉镖活动正式开始，请各位帮众同心协力完成门派的光荣使命。");
					MessageIconManager.getInstance().showFamilyYBCTime();
					this.showYbcArrow = true;
					this.dispatch(ModuleCommand.SCENE_SHOW_SIGN);
				} else {
					removeYBCViews(); //移除没有加入镖队的人的界面。
				}
				ybcStatus=FamilyConstants.YBC_PUBLISH_ED;
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * "取消" 拉镖活动(返回)
		 */
		public function setGiveUpYBC(vo:m_family_ybc_giveup_toc):void {
			if (vo.succ) {
				if (vo.role_id == ybcCreator) {
					Tips.getInstance().addTipsMsg("门派拉镖活动已被取消，押金已被退回。");
					removeYBCViews();
				} else if (vo.role_id == GlobalObjectManager.getInstance().user.base.role_id) {
//					Tips.getInstance().addTipsMsg("你已退出门派拉镖，退回押金。");
					removeYBCViews();
				} else {
					if (ybcStatus == FamilyConstants.YBC_PUBLISH_ED) {
						if (familyYBCPanel) {
							familyYBCPanel.removeMember(vo.role_id);
						}
					} else {
						removeJoinMember(vo.role_id);
						var memberInfo:p_family_member_info=FamilyLocator.getInstance().getMemberById(vo.role_id);
						if (memberInfo) {
							BroadcastSelf.logger("帮众" + HtmlUtil.font("[" + memberInfo.role_name + "]", "#00ff00") + "已经退出了镖队。");
						}
					}
				}
				this.showYbcArrow = false;
//				SceneModule.getInstance().view.removeYBCArrow();
				this.dispatch(ModuleCommand.SCENE_CLEAR_SIGN);
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 召集帮众(返回)
		 */
		private var promptKey:String="";

		private function setCollectFamilyMember(vo:m_family_ybc_collect_toc):void {
			if (vo.succ) {
				if (!vo.return_self) {
					var name:String=vo.owner_type == 1 ? "掌门" : "长老";
					var html:String;
					if(GlobalObjectManager.getInstance().user.base.status != RoleActState.TRAINING)
						html = name + HtmlUtil.font("[" + vo.owner_name + "]", "#00ff00") + "正在集合大家准备门派拉镖，确定立即前往拉镖地点？";
					else
						html = name + HtmlUtil.font("[" + vo.owner_name + "]", "#00ff00") + "正在集合大家准备门派拉镖，你正在训练，确定立即结束训练并前往拉镖地点？";
					if (vo.content != "") {
						html=html + HtmlUtil.font("\nTA说：" + vo.content, "#ffff00")
					}
					if (promptKey == "") {
						promptKey=Prompt.show(html, "温馨提示", acceptCollect, refuseHandler, "接受", "拒绝");
					}
				} else {
					Tips.getInstance().addTipsMsg("拉镖通知已成功发送！");
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		private function refuseHandler():void {
			promptKey="";
		}

		/**
		 * 前往拉镖地点(返回 )
		 */
		private function setAcceptCollect(vo:m_family_ybc_accept_collect_toc):void {
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		/**
		 * 邀请所有帮众
		 */
		public function setInviteMember(data:Object):void {
			var vo:m_family_ybc_invite_toc=data as m_family_ybc_invite_toc;
			if (vo.succ) {
				if (!vo.return_self && myStatus != FamilyConstants.JOIN_YBC) {
					agreePublishYBC();
				} else {
					Tips.getInstance().addTipsMsg("邀请通知已成功发送！");
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 完成运镖(返回)
		 */
		private function setCommitFamilyYBC(vo:m_family_ybc_commit_toc):void {
			if (vo.succ) {
				ybcStatus=FamilyConstants.YBC_UN_PUBLISH;
				removeYBCViews();
				if (vo.silver == 0) { //远离交镖范围，返回押金为0
					Tips.getInstance().addTipsMsg("掌门提交镖车时远离镖队，个人任务失败。");
					BroadcastSelf.logger(HtmlUtil.font("掌门提交镖车时远离镖队\n个人任务失败\n不退回押金\n门派资金：" + MoneyTransformUtil.silverToOtherString(vo.family_money) + "\n门派繁荣度：" + vo.active_point, "#ffcc00"));

				} else {
					Tips.getInstance().addTipsMsg("门派拉镖任务完成。");
					BroadcastSelf.logger(HtmlUtil.font("完成门派拉镖任务\n退回押金：" + MoneyTransformUtil.silverToOtherString(vo.silver) + "\n获得经验：" + vo.exp + "\n门派贡献度：" + vo.contribution + "\n门派资金：" + MoneyTransformUtil.silverToOtherString(vo.family_money) + "\n门派繁荣度：" + vo.active_point, "#ffcc00"));
				}
				this.showYbcArrow = false;
//				SceneModule.getInstance().view.removeYBCArrow();
				this.dispatch(ModuleCommand.SCENE_CLEAR_SIGN);
				if (vo.reason != "") {
					BroadcastSelf.logger(vo.reason);
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 获取拉镖成员(返回)
		 */
		private function setFamilyYBCMembers(vo:m_family_ybc_list_toc):void {
			if (vo.succ) {
				if (familyYBCPanel) {
					familyYBCPanel.setMembers(vo.members);
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 掌门踢人（返回）
		 */
		private function setKickMember(vo:m_family_ybc_kick_toc):void {
			if (vo.succ) {
				var roleId:int=GlobalObjectManager.getInstance().user.attr.role_id;
				if (roleId == vo.role_id) {
					this.showYbcArrow = false;
//					SceneModule.getInstance().view.removeYBCArrow();
					this.dispatch(ModuleCommand.SCENE_CLEAR_SIGN);
					removeYBCViews();
				} else if (familyYBCPanel) {
					familyYBCPanel.removeMember(vo.role_id);
				}
				BroadcastSelf.logger(HtmlUtil.font(vo.role_name + "被踢出了镖队!", "#ff0000"));
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 为镖车加血（返回）
		 */
		private function setAddBiaoCheHP(vo:m_family_ybc_add_hp_toc):void {
			if (vo.succ) {
				if (familyYBCPanel) {
					//familyYBCPanel.setHP(vo.hp/vo.);
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 收到镖车被攻击通知
		 */
		private function setCallHelp(vo:m_family_ybc_call_help_toc):void {
			Alert.show("您门派的镖车正受到敌国玩家猛烈攻击，是否立即前往营救？", "温馨提示", startHelp, null, "是", "否");
		}

		/**
		 * 前往营救 (返回)
		 */
		public function setStartHelp(vo:m_family_ybc_accept_help_toc):void {
			if (!vo.succ) {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 提醒帮众 (返回)
		 */
		public function setAlertMember(vo:m_family_ybc_alert_toc):void {
			if (vo.succ) {
				if (!vo.return_self) {
					Tips.getInstance().addTipsMsg("你已远离镖车，请尽快回到镖车附近。");
				} else {
					Tips.getInstance().addTipsMsg("提醒消息已经成功发送。");
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 设置门派镖车状态
		 */
		public function setUpdateYBCStatus(vo:m_family_ybc_status_toc):void {
			if (vo.status == 0) { //镖车被打爆掉
				ybcStatus=FamilyConstants.YBC_UN_PUBLISH;
				removeYBCViews();
			}
		}
	}
}