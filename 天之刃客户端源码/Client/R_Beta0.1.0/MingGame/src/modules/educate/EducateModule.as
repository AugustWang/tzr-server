package modules.educate
{
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	import com.components.alert.Alert;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.HtmlUtil;
	import com.utils.PathUtil;
	
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.educate.views.CommemdStudentPanel;
	import modules.educate.views.CommemdTeacherPanel;
	import modules.educate.views.EducateCommendView;
	import modules.educate.views.EducateList;
	import modules.educate.views.EducateView;
	import modules.educate.views.ExpTransformPanel;
	import modules.educate.views.PkTransformPanel;
	import modules.educate.views.TeacherLevelUpPanel;
	import modules.friend.FriendsModule;
	import modules.help.HelpManager;
	import modules.help.IntroduceConstant;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.team.TeamModule;
	
	import proto.line.*;
	
	public class EducateModule extends BaseModule
	{
		public var educateInfo:p_educate_role_info;
		private var educateView:EducateView;
		private var expPanel:ExpTransformPanel;
		private var pkPanel:PkTransformPanel;
		private var educateList:EducateList;
		private var upLevelPanel:TeacherLevelUpPanel;
		private static var _instance:EducateModule;
		private var commendView:EducateCommendView;
		
		private var relType:int;
		
		public function EducateModule(){
			
		}
		
		public static function getInstance():EducateModule{
			if(_instance == null)
				_instance = new EducateModule();
			return _instance;
		}
			
		override protected function initListeners():void{
			addMessageListener(NPCActionType.NA_67, openCStudentPanel);
			addMessageListener(NPCActionType.NA_68, buildEducate);
			addMessageListener(NPCActionType.NA_69, openCTeacherPanel);
			addMessageListener(NPCActionType.NA_70, dropOutS);
			addMessageListener(NPCActionType.NA_71, openDismissView);
			addMessageListener(NPCActionType.NA_72, openUpLevelPanel);
			addMessageListener(NPCActionType.NA_73, openExpPanel);
			addMessageListener(NPCActionType.NA_74, openPkPanel);
			addMessageListener(NPCActionType.NA_75, onEducateIntroduce);
			addMessageListener(NPCActionType.NA_24, openPkPanel);
			addMessageListener(NPCActionType.NA_96, openUpLevelPanel);
			
			addSocketListener(SocketCommand.EDUCATE_GET_INFO,setEducateInfo);
			addSocketListener(SocketCommand.EDUCATE_FILTER_STUDENT,setCommendStudents);
			addSocketListener(SocketCommand.EDUCATE_FILTER_TEACHER,setCommendTeachers);
			addSocketListener(SocketCommand.EDUCATE_EXPEL,setDismissStudent);
			addSocketListener(SocketCommand.EDUCATE_GET_STUDENTS_INFO,setStudentInfo);
			addSocketListener(SocketCommand.EDUCATE_GET_CLAN_INFO,setTeacherInfo);
			addSocketListener(SocketCommand.EDUCATE_INVITE_APPRENTICE,setInviteApprentice);
			addSocketListener(SocketCommand.EDUCATE_INVITE_ADMISSIONS,setInviteAdmissions);
			addSocketListener(SocketCommand.EDUCATE_REPLY_INVITE_APPRENTICE,setInviteReplyApprentice);
			addSocketListener(SocketCommand.EDUCATE_REPLY_INVITE_ADMISSIONS,setInviteReplyAdmissions);
			addSocketListener(SocketCommand.EDUCATE_SWORN_MENTORING,setBuildEducate);
			addSocketListener(SocketCommand.EDUCATE_DROPOUT,setDropOut);
			addSocketListener(SocketCommand.EDUCATE_UPGRADE,setUpGrade);
			addSocketListener(SocketCommand.EDUCATE_MORAL_VALUE_TO_EXP,setValueToExp);
			addSocketListener(SocketCommand.EDUCATE_INVITE_APPRENTICE_RESULT,setInviteApprenticeResult);
			addSocketListener(SocketCommand.EDUCATE_INVITE_ADMISSIONS_RESULT,setInviteAdmissionsResult);
			addSocketListener(SocketCommand.EDUCATE_MORAL_VALUE_TO_PKPOINT,setValueToPk);
			addSocketListener(SocketCommand.EDUCATE_GET_EXPEL_MORAL_VALUE,setDismissS);
			addSocketListener(SocketCommand.EDUCATE_GET_DROPOUT_MORAL_VALUE,setDropOutS);
			addSocketListener(SocketCommand.EDUCATE_TIP_CAPTAIN,setEducateTipCaptain);
			addSocketListener(SocketCommand.EDUCATE_CALL_HELPER,setCallHelper);
			addSocketListener(SocketCommand.EDUCATE_AGREE_HELP,setAgreeHelp);
			addSocketListener(SocketCommand.EDUCATE_GET_RELATE_PEOPLE,setRelatePeoples);
			addSocketListener(SocketCommand.EDUCATE_RELEASE, release);
		}
	
		/*********************************界面视图逻辑********************************************/
		
		public function alertGotoAdmin():void
		{
			Alert.show("组队成功！赶快前往<u><font color='#00FF00'><a href='event:'>京城-师徒管理员</a></font></u>处和对方结为师徒吧。	", "", onAlertAdminLink, null, "立刻免费传送", "稍后前往", null, true, false, null, onFindEducateAdmin,false);
		}
		
		private function onFindEducateAdmin(e:Event):void
		{
			PathUtil.findNPC("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100121");
		} 
		
		/**
		 * 同意立刻拜师，则免费传送 
		 * @param e
		 * 
		 */		
		private function onAlertAdminLink():void
		{
			// 传送
			var vo:m_educate_transfer_tos = new m_educate_transfer_tos;
			sendSocketMessage(vo);
		}
		
		private function onEducateIntroduce(vo:NpcLinkVO=null):void{
			HelpManager.getInstance().openIntroduce(IntroduceConstant.EDUCATE);	
		}
		
		public function hasTeacherTitle():Boolean{
			return educateInfo ? educateInfo.title > 0 : false;
		}
		public function hasTeacher():Boolean{
			return educateInfo ? educateInfo.teacher != 0 : false;
		}
		public function hasReleaseAdmissions():Boolean{
			return educateInfo ? educateInfo.rel_admissions != false : false; 
		}
		public function hasReleaseApprentice():Boolean{
			return educateInfo ? educateInfo.rel_apprentice != false : false;
		}
		public function isCanBecomeStudent():Boolean{
			return educateInfo.level >=10 && educateInfo.level <= 49 && educateInfo.teacher == 0;
		}
		public function isCanBecomeTeacher():Boolean{
			return educateInfo.level >=25 && educateInfo.level <= 160;
		}
		public function isFullStudentNum():Boolean{
			return !(educateInfo.student_num < educateInfo.student_max_num);
		}
		/**
		 * 为了防止后端数据丢失（这是个杯具的搞法） 
		 */		
		private var startTime:int;
		private function againGetEducateInfo():void{
			var t:int = getTimer();
			if(t - startTime >= 10000){
				getEducateInfo();
				startTime = t;
			}
		}
		/**
		 * 获取师徒界面视图 
		 */		
		public function getEducateView():EducateView{
			if(educateView == null){
				educateView = new EducateView();
			}
			return educateView;
		}
		/**
		 * 获取QQ列表中师门信息视图 
		 */		
		public function getEducateList():EducateList{
			if(educateList == null){
				educateList = new EducateList();
			}	
			return educateList;
		}
		/**
		 * 获取当前玩家的师傅ID 
		 */		
		public function get teacherId():int{
			return educateInfo ? educateInfo.teacher : 0;
		}
		/**
		 * 改变界面
		 */		
		public function changeView():void{
			if(educateInfo && educateView){
				educateView.setEducateInfo(educateInfo);
			}
		}
		/**
		 * 当师徒界面数据发送变化时，需要重新根据数据渲染不同的界面。 
		 */		
		public function loadEducateView():void{
			if(educateView){
				getEducateInfo();
			}
		}
		/**
		 * 打开升级面板 
		 */		
		public function openUpLevelPanel(vo:NpcLinkVO=null):void{
			if(educateInfo == null){
				againGetEducateInfo();
				return;
			}
			if(upLevelPanel == null){
				upLevelPanel = new TeacherLevelUpPanel();
				upLevelPanel.closeFunc = closeHandler;
			}
			upLevelPanel.currentTitle = educateInfo.title;
			WindowManager.getInstance().popUpWindow(upLevelPanel,WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(upLevelPanel);
			function closeHandler():void{
				upLevelPanel.dispose();
				upLevelPanel = null;
			}
		}
		/**
		 * 打开师德值转换经验面板 
		 */		
		public function openExpPanel(vo:NpcLinkVO = null):void{
			if(educateInfo == null){
				againGetEducateInfo();
				return;
			}
			if(expPanel == null){
				expPanel = new ExpTransformPanel();
				expPanel.closeFunc = closeHandler;
			}
			expPanel.setEducateInfo(educateInfo);
			WindowManager.getInstance().popUpWindow(expPanel,WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(expPanel);
			function closeHandler():void{
				expPanel.dispose();
				expPanel = null;
			}
		}
		/**
		 * 打开师德值转换PK值面板 
		 */		
		public function openPkPanel(vo:NpcLinkVO = null):void{
			if(educateInfo == null){
				againGetEducateInfo();
				return;
			}
			if(pkPanel == null){
				pkPanel = new PkTransformPanel();
				pkPanel.closeFunc = closeHandler;
			}
			pkPanel.setEducateInfo(educateInfo);
			WindowManager.getInstance().popUpWindow(pkPanel,WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(pkPanel);
			function closeHandler():void{
				pkPanel.dispose();
				pkPanel = null;
			}
		}
		/**
		 * 打开推荐师傅面板 
		 */		
		public function openCTeacherPanel(vo:NpcLinkVO = null):void{
			if (commendView == null) {
				commendView = new EducateCommendView;
			}
			WindowManager.getInstance().popUpWindow(commendView,WindowManager.REMOVE);
			WindowManager.getInstance().centerWindow(commendView);
			commendView.setTab(2);
			commendView.load();
		}
		/**
		 * 打开推荐徒弟面板 
		 */		
		public function openCStudentPanel(vo:NpcLinkVO = null):void{
			if (commendView == null) {
				commendView = new EducateCommendView;
			}
			WindowManager.getInstance().popUpWindow(commendView,WindowManager.REMOVE);
			WindowManager.getInstance().centerWindow(commendView);
			commendView.setTab(1);
			commendView.load();
		}
		
		/**
		 *打开开除徒弟面板 
		 */		
		public function openDismissView(vo:NpcLinkVO = null):void{
			if(educateInfo && educateInfo.student_num == 0){
				Alert.show("你还没有徒弟，赶快去收徒吧！","提示",null,null,"确定","",null,false);return;	
			}
			FriendsModule.getInstance().openEducateView();
			if(educateView){
				educateView.openDismissView();
			}
		}
		private function getOtherId(members:Array):int{
			var roleId:int = GlobalObjectManager.getInstance().user.attr.role_id;
			for each(var role:p_team_role in members){
				if(role.role_id != roleId){
					return role.role_id;
				}
			}
			return 0;
		}
		private function removeStudent(roleId:int):void{
			if(educateView){
				if(educateInfo.student_num == 0){
					changeView();
				}else{
					educateView.removeStudent(roleId);
				}
			}
		}
		
		
		private function moralValueChanged():void{
			GlobalObjectManager.getInstance().user.attr.moral_values = educateInfo.moral_values;
			dispatch(ModuleCommand.MORAL_VALUE_CHANGED);
		}
		/**
		 * 显示图标
		 */		
		private function showHideIcons():void{
			com.components.MessageIconManager.getInstance().showTeacherIcon();
		}
		
		/*********************************消息发送逻辑********************************************/
		/**
		 * 加为好友 
		 */		
		public function addFriend(name:String):void{
			dispatch(ModuleCommand.ADD_FRIEND,name);
		}
		/**
		 *获取师徒信息 
		 */		
		public function getEducateInfo():void{
			sendSocketMessage(new m_educate_get_info_tos());
		}
		/**
		 *获取推荐师傅 
		 */		
		public function getCommendTeachers():void{
			sendSocketMessage(new m_educate_filter_teacher_tos());
		}
		/**
		 *获取推荐徒弟 
		 */		
		public function getCommendStudents():void{
			sendSocketMessage(new m_educate_filter_student_tos());
		}
		/**
		 * 开除徒弟（由于这个过程需要计算被减去的师德值，而客户端所掌握的徒弟等级不准确，所以需要发送消息让服务端计算，然后才开始调用dismissStudent的方法） 
		 */		
		public function dismissS(roleId:int):void{
			var vo:m_educate_get_expel_moral_value_tos = new m_educate_get_expel_moral_value_tos();
			vo.roleid = roleId;
			sendSocketMessage(vo);
		}
		/**
		 *开除徒弟 
		 */
		public function dismissStudent(roleId:int,roleName:String,morals:int):void{
			Alert.show("你确定要与  "+HtmlUtil.font(roleName,"#ffff00")+"  解除师徒关系吗？将会扣"+HtmlUtil.font(morals+"","#ffff00")+"点师德值，请慎重考虑！（徒弟多天没上线，惩罚将下降）","警告",yesHandler);
			function yesHandler():void{
				var vo:m_educate_expel_tos = new m_educate_expel_tos();
				vo.roleid = roleId;
				sendSocketMessage(vo);
			}
		}
		/**
		 * 获取师徒信息 
		 */		
		public function getTeacherInfo():void{
			sendSocketMessage(new m_educate_get_clan_info_tos());
		}
		/**
		 * 获取徒弟信息 
		 */		
		public function getStudentInfo():void{
			sendSocketMessage(new m_educate_get_students_info_tos());
		}
		/**
		 * 当消息抵达客户端时是否同意作为别人的师傅 
		 */
		public function inviteReplyApprentice(ref:String,isagree:Boolean):void{
			var vo:m_educate_reply_invite_apprentice_tos = new m_educate_reply_invite_apprentice_tos();
			vo.ref = ref;
			vo.is_agree = isagree;
			sendSocketMessage(vo);	
		}
		/**
		 * 当消息抵达客户端时是否同意作为别人的徒弟
		 */
		public function inviteReplyAdmissions(ref:String,isagree:Boolean):void{
			var vo:m_educate_reply_invite_admissions_tos = new m_educate_reply_invite_admissions_tos();
			vo.ref = ref;
			vo.is_agree = isagree;
			sendSocketMessage(vo);	
		}
		/**
		 *结为师徒 
		 */
		public function buildEducate(vo:NpcLinkVO=null):void{
			var members:Array = TeamModule.getInstance().members;
			if(!members || (members && members.length != 1)){
				Alert.show("拜师的时候必须两个人组队来找我!","提示",null,null,"确定","",null,false);
				return;
			}
			var roleId:int = getOtherId(members);
			var vo2:m_educate_sworn_mentoring_tos = new m_educate_sworn_mentoring_tos();
			vo2.roleid = roleId;
			sendSocketMessage(vo2);
		}
		/**
		 *  离开师门  请求离开师门需要条件数据
		 */		
		public function dropOutS(vo:NpcLinkVO=null):void{
			if(educateInfo && educateInfo.teacher == 0){
				Alert.show("你还没有师傅，赶快去拜师吧！","警告",null,null,"确定","",null,false);
				return;
			}
			sendSocketMessage(new m_educate_get_dropout_moral_value_tos());
		}
		/**
		 *升级导师称号 
		 */
		public function upGrade():void{
			sendSocketMessage(new m_educate_upgrade_tos());
		}
		/**
		 * 师德值换取经验 
		 */		
		public function valueToExp(value:int):void{
			var vo:m_educate_moral_value_to_exp_tos = new m_educate_moral_value_to_exp_tos();
			vo.moral_value = value;
			sendSocketMessage(vo);
		}
		/**
		 *  师德值换取Pk值
		 */
		public function valueToPk(value:int):void{
			var vo:m_educate_moral_value_to_pkpoint_tos = new m_educate_moral_value_to_pkpoint_tos();
			vo.moral_value = value;
			sendSocketMessage(vo);
		}
		/**
		 * 出师 
		 */
		public function changeToTeacher(address:String):void{
			var vo:m_educate_graduate_to_teacher_toc = new m_educate_graduate_to_teacher_toc();
			vo.address = address;
			sendSocketMessage(vo);
		}
		/**
		 * 通过角色ID获取角色师门信息 
		 */		
		public function getTeacherInfoById(roleId:int):void{
			
		}
		/**
		 * 答应帮助 
		 */		
		public function agreeHelp(roleid:int):void{
			var vo:m_educate_agree_help_tos = new m_educate_agree_help_tos();
			vo.role_id = roleid;
			sendSocketMessage(vo);
		}
		/**
		 * 获取本人有关系的人
		 */		
		public function getRelatePeoples():void{
			sendSocketMessage(new m_educate_get_relate_people_tos());
		}
		/**
		 * 发布收徒的消息
		 */
		public function releaseAdm(msg:String):void{
			var vo:m_educate_release_tos = new m_educate_release_tos;
			relType = 1;
			vo.opt = 1;
			vo.msg = msg;
			sendSocketMessage(vo);
		}
		/**
		 * 发布拜师的消息
		 */		
		public function releaseApp(msg:String):void{
			var vo:m_educate_release_tos = new m_educate_release_tos;
			relType = 2;
			vo.opt = 2;
			vo.msg = msg;
			sendSocketMessage(vo);
		}
		/**
		 * 撤销发布收徒
		 */		
		public function unReleaseAdmissions():void{
			var vo:m_educate_release_tos = new m_educate_release_tos;
			relType = 3;
			vo.opt = 3;
			sendSocketMessage(vo);
		}
		/**
		 * 撤销发布拜师
		 */		
		public function unReleaseApprentice():void{
			var vo:m_educate_release_tos = new m_educate_release_tos;
			relType = 4;
			vo.opt = 4;
			sendSocketMessage(vo);
		}	
		/*********************************消息接受并处理逻辑********************************************/
		
		/**
		 *获取师徒信息(返回) 
		 */		
		private function setEducateInfo(vo:m_educate_get_info_toc):void{
			if(educateInfo){
				var getValue:int = vo.roleinfo.moral_values - educateInfo.moral_values;
				if(getValue > 0){
					BroadcastSelf.logger("你获得了"+getValue+"点师德值");
				}else if(getValue < 0){
					BroadcastSelf.logger("你减少了"+Math.abs(getValue)+"点师德值");
				}
			}
			educateInfo = vo.roleinfo;
			showHideIcons();
			moralValueChanged();
			if(educateView){
				educateView.setEducateInfo(educateInfo);
			}
		}
		/**
		 *获取推荐师傅（返回） 
		 */		
		private function setCommendTeachers(vo:m_educate_filter_teacher_toc):void{
			if(educateView){ 
				educateView.setTeachers(vo.roles);
			}
			if (commendView) {
				commendView.setTeachers(vo.roles);
			}
		}
		/**
		 *获取推荐徒弟（返回） 
		 */	
		private function setCommendStudents(vo:m_educate_filter_student_toc):void{
			if(educateView){
				educateView.setStudents(vo.roles);
			}
			if (commendView) {
				commendView.setStudents(vo.roles);
			}
		}
		/**
		 * 开除徒弟计算扣除师德值（返回） 
		 */		
		private function setDismissS(vo:m_educate_get_expel_moral_value_toc):void{
			if(vo.succ){
				dismissStudent(vo.roleid,vo.name,vo.value);
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 开除徒弟（返回） 
		 */	
		private function setDismissStudent(vo:m_educate_expel_toc):void{
			if(vo.succ){
				educateInfo = vo.info;
				if(vo.is_teacher){
					removeStudent(vo.roleid);
					changeView();
					BroadcastSelf.logger(HtmlUtil.font("成功开除徒弟！","#00ffff"));
				}else{
					changeView();
					BroadcastSelf.logger(HtmlUtil.font("你已经被师傅开除！","#00ffff"));
				}
				moralValueChanged();
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 获取徒弟列表信息（返回） 
		 */		
		private function setStudentInfo(vo:m_educate_get_students_info_toc):void{
			if(educateView){
				educateView.setStudentInfo(vo.students);
			}
		}
		/**
		 * 获取同门师兄弟列表信息（返回） 
		 */		
		private function setTeacherInfo(vo:m_educate_get_clan_info_toc):void{
			if(educateView){
				educateView.setTeacherInfo(vo.clans);
			}
		}
		/**
		 * 邀请玩家，拜玩家为师,Server主动发送 （返回） 
		 */		
		private function setInviteApprentice(vo:m_educate_invite_apprentice_toc):void{
			Alert.show(HtmlUtil.font("["+vo.rolename+"]","#ffff00") + "仰慕你名满天下，想拜你为师，是否同意","提示",yesHandler,noHandler,"接受","拒绝",null,true,true,null,null,false);
			function yesHandler():void{
				inviteReplyApprentice(vo.ref,true);
			}
			function noHandler():void{
				inviteReplyApprentice(vo.ref,false);	
			}
		}
		/**
		 * 拜玩家为师回复 （返回） 
		 */		
		private function setInviteReplyApprentice(vo:m_educate_reply_invite_apprentice_toc):void{
			if(vo.succ){
				educateInfo = vo.info;
				changeView();
				BroadcastSelf.logger("恭喜你们成功建立师徒关系!");
				showHideIcons();
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 *  拜玩家为师结果 （返回）  
		 */
		private function setInviteApprenticeResult(vo:m_educate_invite_apprentice_result_toc):void{
			if(vo.succ){
				educateInfo = vo.info;
				changeView();
				BroadcastSelf.logger("恭喜你们成功建立师徒关系!");
				showHideIcons();
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 邀请玩家，收玩家为徒 Server主动发送（返回） 
		 */		
		private function setInviteAdmissions(vo:m_educate_invite_admissions_toc):void{
			Alert.show(HtmlUtil.font("["+vo.rolename+"]","#ffff00") + "见你资质过人，想收你为徒，是否同意","提示",yesHandler,noHandler,"接受","拒绝");
			function yesHandler():void{
				inviteReplyAdmissions(vo.ref,true);
			}
			function noHandler():void{
				inviteReplyAdmissions(vo.ref,false);	
			}
		}
		/**
		 * 收玩家为徒回复 （返回） 
		 */		
		private function setInviteReplyAdmissions(vo:m_educate_reply_invite_admissions_toc):void{
			if(vo.succ){
				educateInfo = vo.info;
				changeView();
				BroadcastSelf.logger("恭喜你们成功建立师徒关系!");
				showHideIcons();
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 *  收玩家为徒结果 （返回）  
		 */
		private function setInviteAdmissionsResult(vo:m_educate_invite_admissions_result_toc):void{
			if(vo.succ){
				educateInfo = vo.info;
				changeView();
				BroadcastSelf.logger("恭喜你们成功建立师徒关系!");
				showHideIcons();
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 接为师徒(返回) 
		 */		
		private function setBuildEducate(vo:m_educate_sworn_mentoring_toc):void{
			BroadcastSelf.logger(vo.reason);
		}
		/**
		 * 请求离开师门需要条件数据(返回 )
		 */		
		private function setDropOutS(vo:m_educate_get_dropout_moral_value_toc):void{
			if(vo.succ && educateInfo){
				Alert.show("你确定要与 "+HtmlUtil.font("["+educateInfo.teacher_name+"]","#ffff00")+"解除师徒关系吗？背叛师门，将会扣"+HtmlUtil.font(vo.value+"","#ffff00")+"点师德值，请慎重考虑！（师傅多天没上线，惩罚将下降）","警告",yesHandler);
			}else{
				BroadcastSelf.logger(vo.reason);
			}
			function yesHandler():void{
				sendSocketMessage(new m_educate_dropout_tos());
			}
		}
		/**
		 * 离开师门（返回） 
		 */		
		private function setDropOut(vo:m_educate_dropout_toc):void{
			if(vo.succ){
				if(vo.is_teacher){
					removeStudent(vo.roleid);
				}else{
					BroadcastSelf.logger("已成功脱离师门");
				}
				educateInfo = vo.info;
				changeView();
				moralValueChanged();
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 升级导师称号(返回) 
		 */		
		private function setUpGrade(vo:m_educate_upgrade_toc):void{
			if(vo.succ){
				if(educateInfo){
					educateInfo.title++;
					if(upLevelPanel){
						upLevelPanel.currentTitle = educateInfo.title;
					}
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 师德值装换成经验（返回）
		 */		
		private function setValueToExp(vo:m_educate_moral_value_to_exp_toc):void{
			if(vo.succ){
				educateInfo = vo.info;
				if(educateView){
					educateView.setEducateInfo(educateInfo);
				}
				if(expPanel){
					expPanel.setEducateInfo(educateInfo);
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}	
		}
		/**
		 *  师德值装换成Pk值（返回）
		 */
		private function setValueToPk(vo:m_educate_moral_value_to_pkpoint_toc):void{
			if(vo.succ){
				educateInfo.moral_values = vo.moral_value;
				if(educateView){
					educateView.setEducateInfo(educateInfo);
				}
				if(pkPanel){
					pkPanel.setEducateInfo(educateInfo);
				}
				BroadcastSelf.logger("成功清除 "+vo.pk_point+"点PK值!");
			}else{
				BroadcastSelf.logger(vo.reason);
			}	
		}
		/**
		 * 组队提示消息 
		 */		
		private function setEducateTipCaptain(vo:m_educate_tip_captain_toc):void{
			BroadcastSelf.logger(vo.tip);
		}
		/**
		 * 呼叫帮助 
		 */	
		private function setCallHelper(vo:m_educate_call_helper_toc):void{
			Alert.show(vo.message,"紧急呼救",agreeHelp,null,"同意","不同意",[vo.role_id]);
		}
		/**
		 * 答应帮助（返回）
		 */		
		private function setAgreeHelp(vo:m_educate_agree_help_toc):void{
			if(vo.again){
				Alert.show(vo.message,"紧急呼救",agreeHelp,null,"同意","不同意",[vo.role_id]);
			}
			BroadcastSelf.logger(vo.reason);
		}
		/**
		 * 获取同门师兄弟和师傅，徒弟列表 
		 */		
		private function setRelatePeoples(vo:m_educate_get_relate_people_toc):void{
			if(educateList){
				educateList.dataProvider = vo.educate_role_info;
			}
		}
		/**
		 * 发布拜师或者信息成功
		 */		
		private function release(vo:m_educate_release_toc):void{
			if(vo.info != null && vo.succ){
				educateInfo = vo.info;
			}
			switch(this.relType){
				case 1: //发布收徒信息结果
					if(vo.succ){
						Tips.getInstance().addTipsMsg("发布找徒弟成功！");
					}else{
						Tips.getInstance().addTipsMsg(vo.reason);
					}
					break;
				case 2: //发布收徒信息结果
					if(vo.succ){
						Tips.getInstance().addTipsMsg("发布找师傅成功！");
					}else{
						Tips.getInstance().addTipsMsg(vo.reason);
					}
					break;
				case 3: //撤销发布收徒信息结果
					if(vo.succ){
						Tips.getInstance().addTipsMsg("取消找徒弟成功");
					}else{
						Tips.getInstance().addTipsMsg(vo.reason);
					}
					break;
				case 4: //撤销发布收徒信息结果
					if(vo.succ){
						Tips.getInstance().addTipsMsg("取消找师傅成功");
					}else{
						Tips.getInstance().addTipsMsg(vo.reason);
					}
			}
			if(commendView){commendView.refCommendView();}
			if(educateView){educateView.refCommendView();}
		}
	}
}