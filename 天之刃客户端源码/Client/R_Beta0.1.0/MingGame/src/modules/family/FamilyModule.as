package modules.family
{
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	import com.components.alert.Alert;
	import com.components.alert.Prompt;
	import com.events.WindowEvent;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.BroadcastView;
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.chat.ChatType;
	import modules.family.views.AllFamilyPanel;
	import modules.family.views.CombineFamilyPanel;
	import modules.family.views.CreateFamilyPanel;
	import modules.family.views.FamilyList;
	import modules.family.views.InviteFamilyYBCPanel;
	import modules.family.views.MyFamilyView;
	import modules.family.views.NoFamilyView;
	import modules.family.views.PlayerFamilyInfo;
	import modules.help.HelpManager;
	import modules.help.IntroduceConstant;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.skill.SkillConstant;
	import modules.system.SystemConfig;
	
	import proto.common.p_family_info;
	import proto.common.p_family_info_change;
	import proto.common.p_family_member_info;
	import proto.common.p_role;
	import proto.line.*;
	
	public class FamilyModule extends BaseModule
	{
		private var familyView:MyFamilyView;
		private var requestFamilys:Array;
		private var familyList:FamilyList;
		private var familyLocator:FamilyLocator;
		private var noFamilyView:NoFamilyView;
		
		public function FamilyModule(sigleton:SigletonPress){
		
		}
		
		private static var _instance:FamilyModule;
		public static function getInstance():FamilyModule{
			if(_instance == null){
				_instance = new FamilyModule(new SigletonPress);
				
			}
			return _instance;
		}
		
		override protected function initListeners():void{
			familyLocator = FamilyLocator.getInstance();
			
			addMessageListener(ModuleCommand.CREATE_FAMILY,openCreateFamily);
			addMessageListener(ModuleCommand.FAMILYINFO_INIT,familyLocator.setFamilyInfo);
			addMessageListener(ModuleCommand.ROLE_LEVEL_UP,showFamilyIcon);
			addMessageListener(ModuleCommand.ENTER_GAME,onEnterGame);
			addMessageListener(ModuleCommand.INVITE_JOIN_FAMILY,inviteJoinFamily);
			addMessageListener(NPCActionType.NA_9,call_common_bos);
			addMessageListener(NPCActionType.NA_10,call_uplevel_bos);
			addMessageListener(NPCActionType.NA_11,familyLevelUp);
			addMessageListener(NPCActionType.NA_12,openCollectPanel);
			addMessageListener(NPCActionType.NA_60,enterFamilyMapNormal);
			addMessageListener(NPCActionType.NA_61,openCreateFamily);
			addMessageListener(NPCActionType.NA_62,activateFamily);
			addMessageListener(NPCActionType.NA_64,openAllFamilyPanel);
			addMessageListener(NPCActionType.NA_65,introduceFamily);
			addMessageListener(NPCActionType.NA_66,getCombineFamilyInfo);
			
			addSocketListener(SocketCommand.FAMILY_CREATE,setCreateFamily);
			addSocketListener(SocketCommand.FAMILY_LIST,setFamilyList);
			addSocketListener(SocketCommand.FAMILY_REQUEST,setFamilyRequest);
			addSocketListener(SocketCommand.FAMILY_SELF,setFamilyInfo);
			addSocketListener(SocketCommand.FAMILY_LEAVE,setLeaveFamily);
		 	addSocketListener(SocketCommand.FAMILY_DISMISS,setDismissFamily);
			addSocketListener(SocketCommand.FAMILY_AGREE_F,setAgreeJoinFamily);
			addSocketListener(SocketCommand.FAMILY_REFUSE_F,setRefuseJoinFamily);
			addSocketListener(SocketCommand.FAMILY_INVITE,setInviteJoinFamily);
			addSocketListener(SocketCommand.FAMILY_SET_TITLE,setUpdateTitle);
			addSocketListener(SocketCommand.FAMILY_SET_OWNER,setAlienationFamilyCEO);
			addSocketListener(SocketCommand.FAMILY_UNSET_SECOND_OWNER,setUnsetSecondOwner);
			addSocketListener(SocketCommand.FAMILY_FIRE,setFireFamilyMember);
			addSocketListener(SocketCommand.FAMILY_SET_SECOND_OWNER,setSetSecondOwner);
			addSocketListener(SocketCommand.FAMILY_AGREE,setAgreeFamily); 
			addSocketListener(SocketCommand.FAMILY_REFUSE,setRefuseFamily);
			addSocketListener(SocketCommand.FAMILY_MEMBER_JOIN,setMemberJoin);
			addSocketListener(SocketCommand.FAMILY_ROLE_ONLINE,setRoleOnline);
			addSocketListener(SocketCommand.FAMILY_ROLE_OFFLINE,setRoleOffline);
			addSocketListener(SocketCommand.FAMILY_PANEL,setFamilyPanel);
			addSocketListener(SocketCommand.FAMILY_UPDATE_PRI_NOTICE,setPlacard);
			addSocketListener(SocketCommand.FAMILY_UPDATE_PUB_NOTICE,setPubPlacard);
			addSocketListener(SocketCommand.FAMILY_CAN_INVITE,setRecruits);
			addSocketListener(SocketCommand.FAMILY_ACTIVE_POINTS,setActivePoints);
			addSocketListener(SocketCommand.FAMILY_MONEY,setMoney);
			addSocketListener(SocketCommand.FAMILY_DOWNLEVEL,setDownLevel);
			addSocketListener(SocketCommand.FAMILY_ENABLE_MAP,setEnableMap);
			addSocketListener(SocketCommand.FAMILY_CALL_COMMONBOSS,setCallCommonBoss);
			addSocketListener(SocketCommand.FAMILY_CALL_UPLEVELBOSS,setCallUpLevelBoss);
			addSocketListener(SocketCommand.FAMILY_UPLEVEL,setFamilyUpLevel);
			addSocketListener(SocketCommand.FAMILY_CALLMEMBER,setFamilyCallMember);
			addSocketListener(SocketCommand.FAMILY_MEMBER_ENTER_MAP,setMemberEnterFamilyMap);
			addSocketListener(SocketCommand.FAMILY_MEMBERUPLEVEL,setMemberLevelUp);
			addSocketListener(SocketCommand.FAMILY_MEMBERGATHER,setMemberGather);
			addSocketListener(SocketCommand.FAMILY_DETAIL,setFamilyInfoById);
			addSocketListener(SocketCommand.FAMILY_MAP_CLOSED,setFamilyMapClosed);
			addSocketListener(SocketCommand.FAMILY_DEL_REQUEST,setFamilyDelRequest);
			addSocketListener(SocketCommand.FAMILY_INFO_CHANGE,setFamilyInfoChange);
			addSocketListener(SocketCommand.FAMILY_COMBINE_PANEL,setFamilyCombinePanel);
			addSocketListener(SocketCommand.FAMILY_COMBINE_REQUEST,setFamilyCombineRequest);
			addSocketListener(SocketCommand.FAMILY_COMBINE,setFamilyCombine);
			
			addSocketListener(SocketCommand.FAMILY_ACTIVESTATE,setFamilyActive);
			addSocketListener(SocketCommand.FAMILY_SET_INTERIOR_MANAGER,setInteriorManager);
			addSocketListener(SocketCommand.FAMILY_UNSET_INTERIOR_MANAGER,unsetInteriorManager);
			
			addSocketListener(SocketCommand.FAMILY_NOTIFY_ONLINE,refOnlineMember);
			
		}
		
		/*********************************界面视图逻辑********************************************/
		
		private function onEnterGame():void{
			sceneInit = true;
			showFamilyIcon();
			showFamilyBiao();
		}
		
		public function openCreateFamily(vo:NpcLinkVO=null):void{
			var role:p_role = GlobalObjectManager.getInstance().user;
			if(role.attr.gold < 50){
				Tips.getInstance().addTipsMsg("你的非绑定元宝不足，创建门派需要50元宝.");return;
			}
			if(role.attr.level < 20){
				Tips.getInstance().addTipsMsg("等级不满20级，不能创建门派.");return;
			}
			var createFamilyPanel:CreateFamilyPanel = new CreateFamilyPanel();
			WindowManager.getInstance().openDialog(createFamilyPanel);
			WindowManager.getInstance().centerWindow(createFamilyPanel);
		}
		
		private var combine_choice:m_family_combine_panel_toc;
		private var combineFamilyPanel:CombineFamilyPanel;
		public function openCombineFamilyPanel():void{
			getCombineFamilyInfo();
			if(combineFamilyPanel == null){
				combineFamilyPanel = new CombineFamilyPanel();
			}
		}
				
		public function getFamilyView():Sprite{
			if(GlobalObjectManager.getInstance().user.base.family_id > 0){
				if(familyView == null)
					familyView = new MyFamilyView();
				return familyView;
			}else{
				if(familyView){
					familyView.dispose();
					familyView = null;
				}
				if(noFamilyView == null)
					noFamilyView = new NoFamilyView();
				return noFamilyView;
			}
		}
		
		public function getFamilyListView():FamilyList{
			if(familyList == null){
				familyList = new FamilyList();
			}
			if(!familyLocator.familyInfo && GlobalObjectManager.getInstance().user.base.family_id > 0){
				getFamilyInfo();
			}else{
				familyList.setFamilyInfo(familyLocator.familyInfo);
			}
			return familyList;
		}
		
		public function getFamilyTask():void
		{
			var vo:m_family_activestate_tos = new m_family_activestate_tos();
			vo.family_id = GlobalObjectManager.getInstance().user.base.family_id;
			this.sendSocketMessage(vo);
		}
		
		public function isRequest(id:int):Boolean{
			for each(var p:p_family_request_info in requestFamilys){
				if(p.family_id == id){
					return true;
				}
			}
			return false;
		}
		
		public function addRequest(familyId:int):void{
			if(requestFamilys == null){
				requestFamilys = [];
			}
			if(!isRequest(familyId)){
				var p:p_family_request_info = new p_family_request_info();
				p.family_id = familyId;
				requestFamilys.push(p);
			}
		}
		
		public function updateFamilyInfo():void{
			if(familyView){
				familyView.updateFamilyInfo();
			}
		}
		
		public function updateFamilyList():void{
			if(familyList){
				familyList.updateMembers();
			}	
		}
		
		public function updateView(familyId:int,familyName:String,familyInfo:p_family_info):void{
			GlobalObjectManager.getInstance().user.base.family_id = familyId;
			GlobalObjectManager.getInstance().user.base.family_name = familyName;
			familyLocator.setFamilyInfo(familyInfo);
			changeRoleView();
			changeFamilyView();
			if(familyView){
				familyView.setFamilyInfo(familyLocator.familyInfo);
			}
			if(familyList){
				familyList.setFamilyInfo(familyLocator.familyInfo);
			}
			dispatch(ModuleCommand.CHANGE_FAMILY);
		}
		
		public function addMember(member:p_family_member_info):void{
			familyLocator.addMember(member);
			if(familyView){
				familyView.updateMembers();
				familyView.updateFamilyInfo();
			}
			if(familyList){
				familyList.updateMembers();
			}
			//向聊天频道广播一条消息(冒充系统消息)
			ChatModule.getInstance().sendChatMsg(HtmlUtil.font("【系】欢迎"+HtmlUtil.font("["+member.role_name+"]","#ffff00")+"加入我们的门派。","#3be450"),null,ChatType.FAMILY_CHANNEL);
		}
		
		public function changeRoleView():void{
			dispatch(ModuleCommand.FAMILY_CHANGED);	
		}
		
		public function OpenMyFamily():void{
			if(familyView && familyView.stage){
				familyView.setSelectIndex(0);
			}
		}
		
		public function isOpenMyFamily():Boolean{
			if(familyView && familyView.stage && familyView.selectIndex == 0){
				return true;
			}
			return false;
		}
		
		private var sceneInit:Boolean = false;
		public function showFamilyIcon():void{
			if(sceneInit){
				com.components.MessageIconManager.getInstance().showFamilyIcon();
			}
		}
		
		public function showFamilyBiao():void{
			if(sceneInit){
				var ybcModel:FamilyYBCModule = FamilyYBCModule.getInstance();
				if(ybcModel.ybcStatus != FamilyConstants.YBC_UN_PUBLISH){
					ybcModel.ybcCreator = familyLocator.familyInfo.ybc_creator_id;
					ybcModel.ybcType = familyLocator.familyInfo.ybc_type;
					ybcModel.ybcStatus = familyLocator.familyInfo.ybc_status;
					ybcModel.setJoinMembers(familyLocator.familyInfo.ybc_role_id_list);
					var roleId:int = GlobalObjectManager.getInstance().user.attr.role_id;
					var index:int = familyLocator.familyInfo.ybc_role_id_list.indexOf(roleId);
					ybcModel.myStatus = (index != -1) ? FamilyConstants.JOIN_YBC : FamilyConstants.UN_JOIN_YBC;
					if(ybcModel.ybcStatus == FamilyConstants.YBC_PUBLISH_ED && ybcModel.myStatus == FamilyConstants.JOIN_YBC){
						var hasGoTime:int = SystemConfig.serverTime - familyLocator.familyInfo.ybc_begin_time;
						ybcModel.showIconAndTime(hasGoTime);
					}else if(ybcModel.ybcStatus == FamilyConstants.YBC_PUBLISH_ING){
						ybcModel.showFamilyBiao();
					}
				}
			}
		}
		
		private var allFamilyPanel:AllFamilyPanel;
		public function openAllFamilyPanel(vo:NpcLinkVO=null):void{
			if(allFamilyPanel == null){
				allFamilyPanel = new AllFamilyPanel();
				allFamilyPanel.addEventListener(WindowEvent.CLOSEED,onClosedHandler);
			}
			allFamilyPanel.open();
			WindowManager.getInstance().centerWindow(allFamilyPanel);
		}
		
		private function onClosedHandler(event:WindowEvent):void{
			allFamilyPanel.dispose();
			allFamilyPanel = null;
		}
		
		private function introduceFamily(vo:NpcLinkVO=null):void{
			HelpManager.getInstance().openIntroduce(IntroduceConstant.FAMILY);
		}
		/**
		 * 打开邀请面板 
		 */		
		private var invitePanel:InviteFamilyYBCPanel;
		public function openCollectPanel(vo:NpcLinkVO=null):void{
			var officieId:int = familyLocator.getRoleID();
			if(officieId == FamilyConstants.ZY){
				BroadcastSelf.logger("只有掌门或长老才能召集帮众！");
				return;
			}
			if(invitePanel == null){
				invitePanel = new InviteFamilyYBCPanel();
				invitePanel.addEventListener(WindowEvent.CLOSEED,onInviteClosed);
			}
			invitePanel.sendFunc = callMembers;
			WindowManager.getInstance().popUpWindow(invitePanel,WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(invitePanel);
		}
		
		private function onInviteClosed(event:WindowEvent):void{
			invitePanel.dispose();
			invitePanel = null;
		}
		
		public function openJoinFamilyView():void{
			if(noFamilyView){
				noFamilyView.selectedIndex(1);
			}	
		}
		
		/*********************************消息发送逻辑********************************************/
		/**
		 * 获取还没有加入门派之前的信息 
		 */		
		public function getFamilyPanel():void{
			var vo:m_family_panel_tos = new m_family_panel_tos();
			vo.num_per_page = 10;
			sendSocketMessage(vo);
		}
		/**
		 * 获取所有门派列表
		 */	
		public function getFamilyList(pageNumber:int,pageSize:int=9,searchContent:String="",search_type:int=0,request_from:int=1):void{
			var vo:m_family_list_tos = new m_family_list_tos();
			vo.num_per_page = pageSize;
			vo.page_id = pageNumber;
			vo.search_content = searchContent;
			vo.search_type = search_type;
			vo.request_from = request_from;
			sendSocketMessage(vo);
		}
		/**
		 * 请求创建门派 
		 */
		public function createFamily(familyName:String,autoJoin:Boolean=false):void{
			var vo:m_family_create_tos  = new m_family_create_tos();
			vo.family_name = familyName;
			//vo.is_invite = autoJoin;
			sendSocketMessage(vo);
		}
		/**
		 * 请求打开合并门派面板
		 */		
		public function getCombineFamilyInfo(vo:NpcLinkVO=null):void{
			sendSocketMessage(new m_family_combine_panel_tos());
		}
		/**
		 * 请求合并门派
		 */
		public function combineFamilyRequest(target_family_id:int):void{
			var vo:m_family_combine_request_tos  = new m_family_combine_request_tos();
			vo.target_family_id = target_family_id;
			sendSocketMessage(vo);
		}		
		/**
		 * 改变当前显示视图
		 */	
		public function changeFamilyView():void{
			dispatch(ModuleCommand.CHANGE_FAMILY_VIEW);
		}
		/**
		 * 邀请组队
		 */ 
		public function inviteTeam(roleId:int):void{
			dispatch(ModuleCommand.START_TEAM,{"role_id":roleId});
		}
		/**
		 * 申请加入门派 
		 */	
		public function joinFamilyRequest(familyId:int):Boolean{
			if (FamilyLocator.getInstance().familyInfo && FamilyLocator.getInstance().familyInfo.family_id != 0)
			{
				BroadcastSelf.logger(HtmlUtil.font("已经有门派，不能再次申请加入门派!","#F53F3C"));
				return false;
			}
			if(GlobalObjectManager.getInstance().user.attr.level >= 10){
				var vo:m_family_request_tos = new m_family_request_tos();
				vo.family_id = familyId;
				sendSocketMessage(vo);
				addRequest(familyId);
				return true;
			}
			Tips.getInstance().addTipsMsg("等级不到10级，不能申请加入门派!");
			return false;
		}
		/**
		 * 获取当前所在门派信息 
		 */	
		public function getFamilyInfo():void{
			sendSocketMessage(new m_family_self_tos());
		}
		/**
		 * 获取成员推荐列表 
		 */		
		public function getRecruits():void{
			sendSocketMessage(new m_family_can_invite_tos());
		}
		/**
		 * 离开门派 
		 */	
		public function LeaveFamily():void{
			Alert.show("离开门派之后，您的门派贡献度和门派技能以及其他的所有门派福利将会被清空，请问您是否确定退出门派？","警告",yesHandler);
			function yesHandler():void{
				sendSocketMessage(new m_family_leave_tos());
			}
		}
		/**
		 * 解散门派 
		 */	
		public function dismissFamily():void{
			Alert.show("你是否确定要解散门派？24:00之后才可以重新创建门派，门派技能以及其他的所有门派福利将会被清空！","警告",yesHandler);
			function yesHandler():void{
				sendSocketMessage(new m_family_leave_tos());
			}
		}
		/**
		 * 同意某人加入门派 ]
		 */	
		public function agreeJoinFamily(roleId:int):void{
			var vo:m_family_agree_f_tos = new m_family_agree_f_tos();
			vo.role_id = roleId;
			sendSocketMessage(vo);
		}
		/**
		 * 拒绝某人加入门派 
		 */		
		public function refuseJoinFamily(roleId:int):void{
			var vo:m_family_refuse_f_tos = new m_family_refuse_f_tos();
			vo.role_id = roleId;
			sendSocketMessage(vo);
		}
		/**
		 *邀请某人加入门派 
		 */		
		public function inviteJoinFamily(roleName:String):void{
			var vo:m_family_invite_tos = new m_family_invite_tos();
			vo.role_name = roleName;
			sendSocketMessage(vo);
		}
		/**
		 * 修改称号
		 */		
		public function updateTitle(roleId:int,title:String):void{
			var vo:m_family_set_title_tos = new m_family_set_title_tos();
			vo.role_id = roleId;
			vo.title = title;
			sendSocketMessage(vo);
		}
		/**
		 * 转让掌门
		 */		
		public function alienationFamilyCEO(roleId:int,name:String):void{
			Alert.show("你是否确定要禅让掌门职位给"+HtmlUtil.font("["+name+"]","#ff0000")+"吗?","警告",yesHandler);
			function yesHandler():void{
				var vo:m_family_set_owner_tos  = new m_family_set_owner_tos ();
				vo.role_id = roleId;
				sendSocketMessage(vo);
			}
		}
		/**
		 * 解除长老
		 */		
		public function unsetSecondOwner(roleId:int,name:String):void{
			Alert.show("你是否确定要解除"+HtmlUtil.font("["+name+"]","#ff0000")+"长老职位吗?","警告",yesHandler);
			function yesHandler():void{
				var vo:m_family_unset_second_owner_tos  = new m_family_unset_second_owner_tos ();
				vo.role_id = roleId;
				sendSocketMessage(vo);
			}
		}
		/**
		 * 开除帮众
		 */		
		public function fireFamilyMember(roleId:int,name:String):void{
			Alert.show("你是否确定把"+HtmlUtil.font("["+name+"]","#ff0000")+"开除门派?","警告",yesHandler);
			function yesHandler():void{
				var vo:m_family_fire_tos  = new m_family_fire_tos();
				vo.role_id = roleId;
				sendSocketMessage(vo);
			}
		}
		/**
		 * 任命长老
		 */		
		public function setSecondOwner(roleId:int,name:String):void{
			Alert.show("你确定要提拔 "+HtmlUtil.font("["+name+"]","#ff0000")+"为长老吗?","警告",yesHandler);
			function yesHandler():void{
				var vo:m_family_set_second_owner_tos  = new m_family_set_second_owner_tos ();
				vo.role_id = roleId;
				sendSocketMessage(vo);
			}
		}
		
		/**
		 * 任命内务使
		 */		 
		public function sendInteriorManager(roleId:int,name:String):void
		{
			Alert.show("如果已经存在内务使将被解除，你确定要提拔 "+HtmlUtil.font("["+name+"]","#ff0000")+"为内务使吗?","警告",yesHandler);
			function yesHandler():void{
				var vo:m_family_set_interior_manager_tos  = new m_family_set_interior_manager_tos ();
				vo.role_id = roleId;
				sendSocketMessage(vo);
			}
		}
		/**
		 * 解除内务使
		 */
		public function unSetInteriorManager(roleId:int,name:String):void
		{
			Alert.show("你是否确定要解除"+HtmlUtil.font("["+name+"]","#ff0000")+"内务使职位吗?","警告",yesHandler);
			function yesHandler():void{
				var vo:m_family_unset_interior_manager_tos  = new m_family_unset_interior_manager_tos();
				vo.role_id = roleId;
				sendSocketMessage(vo);
			}			
		}
		
		/**
		 *保存公告 
		 */		
		public function savePlacard(content:String,isprivate:Boolean):void
		{
			if(isprivate){
				var vo:m_family_update_pri_notice_tos = new m_family_update_pri_notice_tos();
				vo.content = content;
				sendSocketMessage(vo);
			}else{
				var vo1:m_family_update_pub_notice_tos = new m_family_update_pub_notice_tos();
				vo1.content = content;
				sendSocketMessage(vo1);
			}
		}
		
		/**
		 *激活门派 
		 */		
		public function activateFamily(vo:NpcLinkVO=null):void
		{
			if (GlobalObjectManager.getInstance().user.base.family_id > 0 &&
				!familyLocator.familyInfo.enable_map && 
				familyLocator.familyInfo.owner_role_id != GlobalObjectManager.getInstance().user.base.role_id)
			{
				BroadcastSelf.logger("让你的掌门来找我吧。开启门派地图后，可以每天击杀门派Boss，获得海量经验，还有大量的收集物品换材料的任务。");
			} else {
				sendSocketMessage(new m_family_enable_map_tos);
			}
		}
		
		public function familyLevelUp(vo:NpcLinkVO=null):void
		{
			if(familyLocator.familyInfo){
				var currentLevel:int = familyLocator.familyInfo.level;
				var newLevel:int = currentLevel + 1;
				if(newLevel < FamilyConstants.LEVELUP_CONDITION.length){
					var conditions:Array = FamilyConstants.LEVELUP_CONDITION[newLevel];
					var msg:String = "";
					if(familyLocator.familyInfo.active_points < conditions[1]){
						Tips.getInstance().addTipsMsg("升级门派条件不足");
						BroadcastSelf.logger("升级门派条件不足");
						return;
					}
					if(familyLocator.familyInfo.money < conditions[0]){
						Tips.getInstance().addTipsMsg("升级门派条件不足");
						BroadcastSelf.logger("升级门派条件不足");
						return;
					}
				}
			}
			sendSocketMessage(new m_family_uplevel_tos);
		}
		/**
		 *  召唤怪物
		 * @param level
		 * 
		 */		
		public function callboss(level:int):void
		{
			if(level==1){
				call_common_bos()
			}else if(level==2){
				call_uplevel_bos()
			}
		}
		/**
		 *召唤高级boss 
		 */		
		public function call_uplevel_bos(vo:NpcLinkVO=null):void
		{
			sendSocketMessage(new m_family_call_uplevelboss_tos());
		}
		
		/**
		 *召唤普通boss 
		 */		
		public function call_common_bos(vo:NpcLinkVO=null):void
		{
			if (familyLocator.onlineNum < 10 && (familyLocator.familyInfo.level < 2)) {
				Alert.show("门派人数较少，挑战强大的boss需要足够人手，建议您招兵买马，吸取更多帮众再进行挑战。", "温馨提示", sureCallCommonBoss, null, "确定挑战", "招人再来");
			} else {
				sureCallCommonBoss();
			}
		}
		
		private function sureCallCommonBoss():void
		{
			sendSocketMessage(new m_family_call_commonboss_tos());
		}
		
		/**
		 * 进入门派副本地图 , NPC指令专用
		 */
		public function enterFamilyMapNormal(vo:NpcLinkVO=null):void {
			var vo2:m_family_enter_map_tos=new m_family_enter_map_tos;
			sendSocketMessage(vo2);
		}
		/**
		 * 进入门派副本地图 
		 */		
		public function enterFamilyMap(call_type:int=1):void{
			var vo:m_family_member_enter_map_tos = new m_family_member_enter_map_tos();
			vo.call_type = call_type;
			sendSocketMessage(vo);
		}
		
		/**
		 * 同意 
		 */		
		private function requestGather():void{
			sendSocketMessage(new m_family_gatherrequest_tos());
		}
		/**
		 * 获取某个门派的详细信息 
		 */		
		public function getFamilyInfoById(familyId:int):void{
			if(familyInfoDic){
				var familyInfoView:PlayerFamilyInfo = familyInfoDic[familyId];
				if(familyInfoView){
					WindowManager.getInstance().bringToFront(familyInfoView);
					return;
				}
			}
			var vo:m_family_detail_tos = new m_family_detail_tos();
			vo.family_id = familyId;
			sendSocketMessage(vo);
		}
		/**
		 * 召集帮众
		 */		
		public function callMembers(content:String):void{
			var vo:m_family_callmember_tos = new m_family_callmember_tos();
			vo.message = content;
			sendSocketMessage(vo);
		}
		/**
		 * 返回门派
		 */		
		public function goBackFamily():void{
			var vo:m_map_transfer_tos=new m_map_transfer_tos;
			vo.mapid=10300;	
			vo.change_type=2;
			sendSocketMessage(vo);
		}
		
		/*********************************消息接受并处理逻辑********************************************/
		/**
		 * 获取还没有加入门派之前的信息 
		 */		
		public function setFamilyPanel(vo:m_family_panel_toc):void{
			requestFamilys = vo.requests;
			if(noFamilyView){
				noFamilyView.setFamilyPanel(vo.family_list,requestFamilys,vo.total_page);
			}
		}
		/**
		 * 请求创建门派 (返回)
		 */
		public function setCreateFamily(vo:m_family_create_toc):void{
			if(vo.succ){
				updateView(vo.family_info.family_id,vo.family_info.family_name,vo.family_info);	
				GlobalObjectManager.getInstance().user.attr.silver = vo.new_silver;
				GlobalObjectManager.getInstance().user.attr.silver_bind = vo.new_silver_bind;
				GlobalObjectManager.getInstance().user.attr.gold = vo.new_gold;
				GlobalObjectManager.getInstance().user.attr.gold_bind = vo.new_gold_bind;
				dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
				Tips.getInstance().addTipsMsg("玩家["+vo.family_info.create_role_name+"]创建了门派 "+vo.family_info.family_name);
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/** 
		 * 门派列表(返回)
		 */		
		private function setFamilyList(vo:m_family_list_toc):void{
			if(vo.request_from == 1){
				if(noFamilyView){
					noFamilyView.setFamilyList(vo.family_list,vo.total_page);
				}
			}else if(vo.request_from == 2){
				if(allFamilyPanel){
					allFamilyPanel.setFamilyList(vo.family_list,vo.total_page);
				}
			}
		}
		
		/**
		 * 内务使(返回)
		 */
		private function setInteriorManager(vo:m_family_set_interior_manager_toc):void
		{
			if(vo.succ)
			{
				if(vo.oldrole_id>0)
					familyLocator.unSetInteriorManager(vo.oldrole_id);
				familyLocator.setInteriorManager(vo.role_id);
				if(familyView){
					familyView.setInteriorManager(vo.role_id);
					if(vo.oldrole_id>0)
						familyView.unsetInteriorManager(vo.oldrole_id);
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}			
		}
		
		/**
		 * 解除内务使返回
		 */
		private function unsetInteriorManager(vo:m_family_unset_interior_manager_toc):void
		{
			if(vo.succ){
				familyLocator.unSetInteriorManager(vo.role_id);
				if(familyView){
					familyView.unsetInteriorManager(vo.role_id);
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}			
		}
		
		/**
		 * 左右护法(返回）
		 */
		//private function onGetProtector(vo:m_family_leftright_protector_toc):void
		//{
			
		//}
		
		/** 
		 * 请求加入门派(返回)
		 */		
		private function setFamilyRequest(vo:m_family_request_toc):void{
			if(vo.succ){
				if(vo.return_self && noFamilyView){
					noFamilyView.requestJoinFamily(vo.family_id);
					BroadcastSelf.logger("请求已成功发送");
				}else{
					familyLocator.addRequest(vo.request);
					if(familyView){
						familyView.updateRequestInfo();
					}
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 获取当前门派信息(返回)
		 */	 	
		private function setFamilyInfo(vo:m_family_self_toc):void{
			if(!vo.succ){
				BroadcastSelf.logger(vo.reason);
			}
			familyLocator.setFamilyInfo(vo.family_info);
			if(familyView){
				familyView.setFamilyInfo(familyLocator.familyInfo);
			}
			if(familyList){
				familyList.setFamilyInfo(familyLocator.familyInfo);
			}
		}
		/**
		 * 离开门派(返回)
		 */		
		private function setLeaveFamily(vo:m_family_leave_toc):void{
			if(vo.succ){
				if(vo.return_self){
					updateView(0,"",null);
					dispatch(ModuleCommand.REMOVE_SKILL_ITEM,{category:SkillConstant.CATEGORY_FAMILY,skillid:0});
					Tips.getInstance().addTipsMsg("已成功退出门派");
				}else{
					familyLocator.removeMember(vo.role_id);
					if(familyView){
						familyView.updateMembers();
						familyView.updateFamilyInfo();
					}
					updateFamilyList();
				}
			}else{
				BroadcastSelf.logger(HtmlUtil.font(vo.reason,"#F53F3C"));
			}
		}
		/**
		 * 门派活动
		 */	
		
		private function setFamilyActive(vo:m_family_activestate_toc):void
		{
			if(familyView){
				familyView.setFamilyTask(vo);
			}
		}
		/**
		 * 解散门派(返回 )
		 */		
		private function setDismissFamily(vo:m_family_dismiss_toc):void{
			if(vo.succ){
				updateView(0,"",null);
				dispatch(ModuleCommand.REMOVE_SKILL_ITEM,{category:SkillConstant.CATEGORY_FAMILY,skillid:0});
				Tips.getInstance().addTipsMsg("门派已被解散!");
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 同意某人加入门派(返回)
		 */		
		private function setAgreeJoinFamily(vo:m_family_agree_f_toc):void{
			if(vo.succ){
				if(!vo.return_self){
					var userName:String = GlobalObjectManager.getInstance().user.attr.role_name;
					Tips.getInstance().addTipsMsg("欢迎["+userName+"] 加入"+vo.family_info.family_name+"门派");
					updateView(vo.family_info.faction_id,vo.family_info.family_name,vo.family_info);
					showFamilyBiao();
					ChatModule.getInstance().sendChatMsg(HtmlUtil.font("【系】欢迎"+HtmlUtil.font("["+userName+"]","#ffff00")+"加入我们的门派。","#3be450"),null,ChatType.FAMILY_CHANNEL);
				}
				//同时后台将发送一个成员加入的消息
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		/**
		 * 拒绝某人加入门派(返回)
		 */	
		private function setRefuseJoinFamily(vo:m_family_refuse_f_toc):void{
			if(vo.succ){
				if(!vo.return_self){
					Tips.getInstance().addTipsMsg(vo.family_name+"门派拒绝了你的申请");
				}
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		/**
		 *同意某门派的邀请 
		 */		
		private function setAgreeFamily(vo:m_family_agree_toc):void{
			if(vo.succ){
				if(vo.return_self){
					updateView(vo.family_info.faction_id,vo.family_info.family_name,vo.family_info);
					BroadcastSelf.logger("已成功加入门派");
					var roleName:String = GlobalObjectManager.getInstance().user.attr.role_name;
					ChatModule.getInstance().sendChatMsg(HtmlUtil.font("【系】欢迎"+HtmlUtil.font("["+roleName+"]","#ffff00")+"加入我们的门派。","#3be450"),null,ChatType.FAMILY_CHANNEL);
					showFamilyBiao();
				}else{
					addMember(vo.member_info);
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 *拒绝某门派的邀请 
		 */	
		private function setRefuseFamily(vo:m_family_refuse_toc):void{
			if(vo.succ){
				if(vo.return_self){
					BroadcastSelf.logger("已成功拒绝了门派邀请");
				}else{
					BroadcastSelf.logger(vo.role_name+"拒绝接受门派邀请");
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 邀请某人加入门派(返回)
		 */	
		private function setInviteJoinFamily(vo:m_family_invite_toc):void{
			if(vo.succ){
				if(!vo.return_self){
					Alert.show(vo.role_name+"邀请您加入"+vo.family_name+"门派，您是否同意","提示",yesHandler,noHandler,"同意","不同意");
				}else{
					Tips.getInstance().addTipsMsg("已成功发送邀请！");
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
			function yesHandler():void{
				var familyVo:m_family_agree_tos = new m_family_agree_tos();
				familyVo.family_id = vo.family_id;
				sendSocketMessage(familyVo);
			}
			function noHandler():void{
				var familyVo:m_family_refuse_tos = new m_family_refuse_tos();
				familyVo.family_id = vo.family_id;
				sendSocketMessage(familyVo);
			}
		}
		/**
		 * 修改称号(返回)
		 */
		private function setUpdateTitle(vo:m_family_set_title_toc):void{
			if(vo.succ){
				var item:Object = familyLocator.updateTitle(vo.role_id,vo.title);
				if(familyView){
					familyView.updateMemberItem(item);
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 转让掌门(返回)
		 */
		private function setAlienationFamilyCEO(vo:m_family_set_owner_toc):void{
			if(vo.succ){
				familyLocator.setNewCEO(vo.role_id);
				if(familyView){
					familyView.updateNewCEO();
				}
				updateFamilyInfo();
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 解除长老(返回)
		 */
		private function setUnsetSecondOwner(vo:m_family_unset_second_owner_toc):void{
			if(vo.succ){
				familyLocator.unSetSecondOwner(vo.role_id);
				if(familyView){
					familyView.unSetSecondOwner(vo.role_id);
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 开除帮众(返回)
		 */
		private function setFireFamilyMember(vo:m_family_fire_toc):void{
			if(vo.succ){
				if(GlobalObjectManager.getInstance().user.attr.role_id == vo.role_id){
					updateView(0,"",null);
					dispatch(ModuleCommand.REMOVE_SKILL_ITEM,{category:SkillConstant.CATEGORY_FAMILY,skillid:0});
				}else{
					familyLocator.removeMember(vo.role_id);
					if(familyView){
						familyView.updateMembers();
						familyView.updateFamilyInfo();
					}
					updateFamilyList();
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 任命长老(返回)
		 */
		private function setSetSecondOwner(vo:m_family_set_second_owner_toc):void{
			if(vo.succ){
				familyLocator.setSeconedOwner(vo.role_id);
				if(familyView){
					familyView.setSeconedOwner(vo.role_id);
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 有成员加入门派时(返回) 
		 */		
		private function setMemberJoin(vo:m_family_member_join_toc):void{
			addMember(vo.member);
		}
		/**
		 * 当有角色上线或下线时（返回） 
		 */
		private function setRoleOnline(vo:m_family_role_online_toc):void{
			familyLocator.updateOnline(vo.role_id,true);
			if(familyView){
				familyView.updateMembers();
			}
			updateFamilyList();
		}
		
		private function setRoleOffline(vo:m_family_role_offline_toc):void{
			familyLocator.updateOnline(vo.role_id,false);
			if(familyView){
				familyView.updateMembers();
			}
			updateFamilyList();
		}
		
		/**
		 * 保存公告成功(返回)
		 */	
		private function setPlacard(vo:m_family_update_pri_notice_toc):void{
			var content:String = "";
			if(!vo.succ){
				BroadcastSelf.logger(vo.reason);return;
			}
			content = vo.content;
			familyLocator.familyInfo.private_notice = content;
			if(familyList){
				familyList.setPlcard(content);
			}
			if(familyView){
				familyView.updatePlacard(content,true);
			}
		}
		
		private function setPubPlacard(vo:m_family_update_pub_notice_toc):void{
			if(!vo.succ){
				BroadcastSelf.logger(vo.reason);return;
			}
			familyLocator.familyInfo.public_notice = vo.content;
			if(familyView){
				familyView.updatePlacard(vo.content,false);
			}
		}
		/**
		 * 获取可以推荐列表（返回）
		 */		
		public function setRecruits(vo:m_family_can_invite_toc):void{
			if(familyView){
				familyView.setRecruits(vo.roles);
			}
		}
		/**
		 * 更新活力 
		 */		
		public function setActivePoints(vo:m_family_active_points_toc):void{
			if(familyLocator.familyInfo){
				familyLocator.familyInfo.active_points = vo.new_points;
			}
			if(familyView){
				familyView.updateFamilyInfo();
			}
		}
		/**
		 * 更新Money(返回) 
		 */	
		public function setMoney(vo:m_family_money_toc):void{
			if(familyLocator.familyInfo){
				familyLocator.familyInfo.money = vo.new_money;
			}
			if(familyView){
				familyView.updateFamilyInfo();
			}
		}
		/**
		 * 更新DownLevel(返回) 
		 */	
		public function setDownLevel(vo:m_family_downlevel_toc):void{
			if(familyLocator.familyInfo){
				familyLocator.familyInfo.level = vo.level;
			}
			if(familyView){
				familyView.updateFamilyInfo();
			}
		}
		/**
		 * 激活地图(返回) 
		 */		
		public function setEnableMap(vo:m_family_enable_map_toc):void{
			if(vo.succ){
				if(familyLocator.familyInfo){
					familyLocator.familyInfo.enable_map = true;
				}
				BroadcastSelf.logger('门派地图已开启');	
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}	
		/**
		 *  BOOS召唤（返回）
		 */
		public function setCallCommonBoss(vo:m_family_call_commonboss_toc):void{
			if(vo.succ){
				BroadcastSelf.logger('BOSS召唤成功');	
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 *  BOOS升级（返回）
		 */
		public function setCallUpLevelBoss(vo:m_family_call_uplevelboss_toc):void{
			if(vo.succ){
				BroadcastSelf.logger('已成功召唤门派升级BOSS');	
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 *  门派升级（返回）
		 */
		private function setFamilyUpLevel(vo:m_family_uplevel_toc):void{
			if(vo.succ){
				Tips.getInstance().addTipsMsg('门派升级成功');	
				if(familyLocator.familyInfo){
					familyLocator.familyInfo.level = vo.new_level;
					familyLocator.familyInfo.active_points = vo.active_points;
					familyLocator.familyInfo.money = vo.money;
				}
				if(familyView){
					familyView.updateFamilyInfo();
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 门派号召 (主推)
		 */	
		private var promptId:String = "";
		private function setFamilyCallMember(vo:m_family_callmember_toc):void{
			if(vo.succ){
				if(!Prompt.isPopUp(promptId)){
					promptId = Prompt.show(vo.message,"消息提示",enterFamilyMap,null,"确定","取消",[vo.call_type]);
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 进入地图消息（返回） 
		 */		
		private function setMemberEnterFamilyMap(vo:m_family_member_enter_map_toc):void{
			if(!vo.succ){
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 帮众升级 
		 */		
		private function setMemberLevelUp(vo:m_family_memberuplevel_toc):void{
			var item:Object = familyLocator.updateLevel(vo.role_id,vo.new_level);
			if(familyView){
				familyView.updateMemberItem(item);
			}
		}
		
		/**
		 * 使用门派令(返回) 
		 */		
		private var gatherId:String="";
		private function setMemberGather(vo:m_family_membergather_toc):void{
			if(!Alert.isPopUp(gatherId)){
				gatherId = Alert.show(vo.message,"提示",requestGather);
			}
		}
		/**
		 * 门派令 
		 */		
		private function setRequestGather(vo:m_family_gatherrequest_toc):void{
			if(!vo.succ){
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 获取某个门派的详细信息 (返回)
		 */		
		private var familyInfoDic:Dictionary;
		public function setFamilyInfoById(vo:m_family_detail_toc):void{
			if(vo.succ){
				if(familyInfoDic == null){
					familyInfoDic = new Dictionary();
				}
				if(familyInfoDic[vo.content.faction_id] == null){
					var familyInfoView:PlayerFamilyInfo = new PlayerFamilyInfo();
					familyInfoView.setFamilyInfo(vo.content);
					familyInfoView.addEventListener(WindowEvent.CLOSEED,disposeHandler);
					familyInfoView.open();
					WindowManager.getInstance().centerWindow(familyInfoView);
					familyInfoDic[vo.content.family_id] = familyInfoView;
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		private function disposeHandler(event:WindowEvent):void{
			var playerInfoView:PlayerFamilyInfo = event.currentTarget as PlayerFamilyInfo;
			playerInfoView.dispose();
			delete familyInfoDic[playerInfoView.familyInfo.family_id];
		}
		/**
		 * 设置门派地图关闭
		 */
		private function setFamilyMapClosed(vo:m_family_map_closed_toc):void{
			familyLocator.familyInfo.enable_map = false;
			Tips.getInstance().addTipsMsg("门派地图已被关闭！");
		}
		
		/**
		 * 在缓存中删除玩家的门派申请请求
		 */
		private function setFamilyDelRequest(vo:m_family_del_request_toc):void{
			familyLocator.removeRequest(vo.role_id);
			if( familyView ){
				familyView.updateMembers();
			}
		}
		
		/**
		 * 在缓存中更改门派资金和繁荣 
		 */		
		private function setFamilyInfoChange(vo:m_family_info_change_toc):void{
			for( var i:int = 0; i < vo.changes.length; i++ ){
				var item:p_family_info_change = vo.changes[i];
				switch( item.change_type ){//1表示门派资金；2表示门派繁荣度
					case 1:familyLocator.familyInfo.money = item.new_value;break;
					case 2:familyLocator.familyInfo.active_points = item.new_value;break;
				}
			}
			if(familyView){
				familyView.updateFamilyInfo();
			}
			FamilySkillModule.getInstance().familyInfoUpdata();
		}

		/**
		 * 合并门派面板
		 */
		private function setFamilyCombinePanel(vo:m_family_combine_panel_toc):void{
			var succ:Boolean = vo.succ;
			if(succ == true){
				if(combineFamilyPanel){
					WindowManager.getInstance().openDialog(combineFamilyPanel);
					WindowManager.getInstance().centerWindow(combineFamilyPanel);
					combineFamilyPanel.initData(vo);
				}
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		/**
		 * 合并门派请求
		 */
		private function setFamilyCombineRequest(vo:m_family_combine_request_toc):void{
			if(vo.return_self == true){
				Tips.getInstance().addTipsMsg(vo.reason);
			}else{
				Alert.show(vo.reason,"警告",yesHandler,noHandler);
				var vo_tos:m_family_combine_tos  = new m_family_combine_tos();
				vo_tos.request_role_id = vo.request_role_id;
				function yesHandler():void{
					vo_tos.confirm = true;
					sendSocketMessage(vo_tos);
				}
				function noHandler():void{
					vo_tos.confirm = false;
					sendSocketMessage(vo_tos);
				}
			}
		}
		
		/**
		 * 合并门派
		 */
		private function setFamilyCombine(vo:m_family_combine_toc):void{
			Tips.getInstance().addTipsMsg(vo.reason);
		}
		
		public function reffamilyOnlie():void
		{
			var vo:m_family_notify_online_tos  = new m_family_notify_online_tos();
			sendSocketMessage(vo);			
		}
		/**
		 * 刷新在线返回
		 */		
		
		private function refOnlineMember(vo:m_family_notify_online_toc):void
		{
			if(vo.succ)
			{
				familyLocator.updateAllOnlien(vo.online_list);
				if(familyView){
					familyView.updateMembers();
				}
				updateFamilyList();
			}
			else
				BroadcastSelf.logger(HtmlUtil.font(vo.reason,"#F53F3C"));
		}
		
		public function getDonateInfo():void{
			var vo:m_family_get_donate_info_tos = new m_family_get_donate_info_tos();
			sendSocketMessage(vo);
		}
		
		public function donate(type:int,value:int):void{
			var vo:m_family_donate_tos = new m_family_donate_tos();
			vo.donate_type = type;
			vo.donate_value = value;
			sendSocketMessage(vo);
		}
	}	 
}

class SigletonPress{}