package modules.team {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.components.alert.Prompt;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.scene.sceneData.RunVo;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.IRole;
	import com.scene.sceneUnit.Role;
	import com.scene.tile.Pt;
	import com.utils.HtmlUtil;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.BroadcastView;
	import modules.broadcast.views.Tips;
	import modules.educate.EducateModule;
	import modules.scene.SceneDataManager;
	import modules.system.SystemConfig;
	import modules.team.view.RecommendTeamView;
	import modules.team.view.TeamPanel;
	
	import proto.line.m_team_accept_toc;
	import proto.line.m_team_accept_tos;
	import proto.line.m_team_apply_toc;
	import proto.line.m_team_apply_tos;
	import proto.line.m_team_auto_disband_toc;
	import proto.line.m_team_auto_list_toc;
	import proto.line.m_team_change_leader_toc;
	import proto.line.m_team_change_leader_tos;
	import proto.line.m_team_create_toc;
	import proto.line.m_team_create_tos;
	import proto.line.m_team_disband_toc;
	import proto.line.m_team_disband_tos;
	import proto.line.m_team_invite_toc;
	import proto.line.m_team_invite_tos;
	import proto.line.m_team_kick_toc;
	import proto.line.m_team_kick_tos;
	import proto.line.m_team_leave_toc;
	import proto.line.m_team_leave_tos;
	import proto.line.m_team_member_invite_toc;
	import proto.line.m_team_member_invite_tos;
	import proto.line.m_team_member_recommend_toc;
	import proto.line.m_team_member_recommend_tos;
	import proto.line.m_team_offline_toc;
	import proto.line.m_team_pick_toc;
	import proto.line.m_team_pick_tos;
	import proto.line.m_team_query_toc;
	import proto.line.m_team_query_tos;
	import proto.line.m_team_refuse_toc;
	import proto.line.m_team_refuse_tos;
	import proto.line.p_friend_info;
	import proto.line.p_team_role;

	/**
	 * 组队模块处理
	 * @author LXY
	 *
	 */
	public class TeamProcessor {
		private static const NAME:String="TEAM"
		private static const INVITE:String="TEAM_INVITE"
		private static const LIST:String="TEAM_LIST"
		private static const CREATE:String="TEAM_CREATE"
		private static const ACCEPT:String="TEAM_ACCEPT"
		private static const REFUSE:String="TEAM_REFUSE"
		private static const LEAVE:String="TEAM_LEAVE"
		private static const OFFLINE:String="TEAM_OFFLINE"
		private static const FOLLOW:String="TEAM_FOLLOW"
		private static const CHANGE_LEADER:String="TEAM_CHANGE_LEADER"
		private static const KICK:String="TEAM_KICK"
		private static const DISBAND:String="TEAM_DISBAND";
		private static const PICK:String="TEAM_PICK";
		private static const MEMBER_INVITE:String="TEAM_MEMBER_INVITE";
		private var _view:TeamView;
		private var teamPanel:TeamPanel;
		private var _module:TeamModule;
		private var team_id_invite:int;
		private var role_id_invite:int;
		private var frontid:int=-1;
		public var myteamid:int=-1;
		public var prompts:Array=[]

		/**
		 * 组队具体处理类
		 * @param view
		 * @param model
		 *
		 */
		public function TeamProcessor(view:TeamView, module:TeamModule):void {
			_view=view;
			_module=module;
		}

		public function openTeamPanel():void{
			if(teamPanel == null){
				teamPanel = new TeamPanel();
			}
			teamPanel.centerOpen();
		}
		
		/**
		 * 邀请入队
		 * @param e
		 *
		 */
		public function toInvite(tarid:int, type:int):void {
			//type 1 为收徒  2为拜师
			if (type > 0) {
				if (_view.list.numChildren == 1) {
					if (TeamDataManager.isTeamMember(tarid)) {
						EducateModule.getInstance().alertGotoAdmin();
						return;
					} else {
						Alert.show("你已有队伍，请先退出队伍再申请与对方组队。", "提示", toLeave, null, "退出队伍", "取消");
						return;
					}
				} else if (_view.list.numChildren > 0) {
					Alert.show("你已有队伍，请先退出队伍再申请与对方组队。", "提示", toLeave, null, "退出队伍", "取消");
					return;
				}
			} else {
				if (_view.list.numChildren >= 5) {
					Alert.show("队伍已满，不能再邀请人了", "提示", null, null, "确定", "取消", null, false);
					return;
				}
			}

			var vo:m_team_invite_tos=new m_team_invite_tos();
			vo.role_id=tarid;
			vo.type=type;
			_module.send(vo);
			memberInviteTip(tarid);
		}
        /**
         * 申请入队 
         * @param applyId
         * 
         */        
        public function onApplyTeamTos(applyId:int):void{
            var vo:m_team_apply_tos = new m_team_apply_tos;
            vo.role_id = applyId;
            vo.apply_id = GlobalObjectManager.getInstance().user.base.role_id;
            vo.op_type = 1;
            _module.send(vo);
        }
        
        /**
         * 队长设置允许自动入队状态
         */        
        public function autoApplyTeamItem():void{
			SystemConfig.autoTeam = !SystemConfig.autoTeam;
        }
        private var applyTeamAlertDict:Dictionary;
        /**
         * 清理数据 
         */        
        private function clearApplyTeamAlertDict():void{
            if(applyTeamAlertDict != null){
                for(var key:String in applyTeamAlertDict){
                    if(Alert.isPopUp(applyTeamAlertDict[key])){
                        Alert.removeAlert(applyTeamAlertDict[key]);
                    }
                    applyTeamAlertDict[key] = null;
                    delete applyTeamAlertDict[key];
                }
                applyTeamAlertDict = null;
            }
        }
        /**
         * 申请入队操作返回 
         * @param vo
         * 
         */        
        public function onApplyTeamToc(vo:m_team_apply_toc):void{
            if(applyTeamAlertDict == null){
                applyTeamAlertDict = new Dictionary;
            }
            if(vo.op_type == 1){//申请操作
                if(vo.return_self){//本人需要处理的消息
                    if(vo.succ){
                        broadcast("申请加入队伍操作成功，请等待队长批准");
                    }else{
                        broadcast(vo.reason);
                    }
                }else{//其它人需要处理消息
                    if(vo.succ){//弹窗提示队长
                        if(SystemConfig.autoTeam){
                            var voTos:m_team_apply_tos = new m_team_apply_tos;
                            voTos.role_id = GlobalObjectManager.getInstance().user.base.role_id;
                            voTos.apply_id = vo.apply_id;
                            voTos.op_type = 2;
                            _module.send(voTos);
                        }else{
                            if(!Alert.isPopUp(applyTeamAlertDict[vo.apply_id])){
                                applyTeamAlertDict[vo.apply_id] =  Alert.show("<font color='#FFFF00'>[" + vo.apply_name + "]</font>申请加入队伍，是否同意？", "提示",
                                    doApplyTeamYes, doApplyTeamNo, "同意", "拒绝",[vo],true,true,null,null,false);  
                            }
                        }
                    }
                }
            }
            if(vo.op_type == 2){//队长同意入队操作
                if(vo.return_self){//本人需要处理的消息
                    if(vo.succ){
                        broadcast("你同意<font color='#FFFF00'>[" + vo.apply_name + "]</font>申请入队请求");
                    }else{
                        broadcast(vo.reason);
                    }
                }else{//其它人需要处理消息
                    if(vo.succ){
                        if(vo.role_list != null && vo.role_list.length > 0){
                            upDateRoleList(vo.role_list);
                        }
                        if(GlobalObjectManager.getInstance().user.base.role_id == vo.apply_id){
                            broadcast("你已经成功加入队伍");
                        }else{
                            broadcast("<font color='#FFFF00'>[" + vo.apply_name + "]</font>加入队伍");
                        }
                    }
                }
            }
            if(vo.op_type == 3){//队长拒绝入队操作
                if(vo.return_self){//本人需要处理的消息
                    if(vo.succ){
                        broadcast("你拒绝<font color='#FFFF00'>[" + vo.apply_name + "]</font>申请入队请求");
                    }else{
                        broadcast(vo.reason);
                    }
                }
            }
            
        }
        /**
         * 队长同意玩家入队 
         * @param vo
         * 
         */        
        private function doApplyTeamYes(vo:m_team_apply_toc):void{
            if(applyTeamAlertDict.hasOwnProperty(vo.apply_id)){
                applyTeamAlertDict[vo.apply_id] = null;
                delete applyTeamAlertDict[vo.apply_id];
            }
            var voTos:m_team_apply_tos = new m_team_apply_tos;
            voTos.role_id = GlobalObjectManager.getInstance().user.base.role_id;
            voTos.apply_id = vo.apply_id;
            voTos.op_type = 2;
            _module.send(voTos);
        }
        /**
         * 队长拒绝玩家入队 
         * @param vo
         * 
         */        
        private function doApplyTeamNo(vo:m_team_apply_toc):void{
            if(applyTeamAlertDict.hasOwnProperty(vo.apply_id)){
                applyTeamAlertDict[vo.apply_id] = null;
                delete applyTeamAlertDict[vo.apply_id];
            }
            var voTos:m_team_apply_tos = new m_team_apply_tos;
            voTos.role_id =  GlobalObjectManager.getInstance().user.base.role_id;
            voTos.apply_id = vo.apply_id;
            voTos.op_type = 3;
            _module.send(voTos);
        }

		private function memberInviteTip(role_id:int):void {
			var inTeam:Boolean=checkInTeam(role_id);
			if (myteamid != -1 && _view.isCaptain == false && inTeam == false) { //我有队了，我不是队长，对方没在我的队里
				broadcast("已发送组队邀请，等待队长批准");
			}
		}

		private function checkInTeam(role_id:int):Boolean {
			var isMember:Boolean;
			var arr:Array=TeamModule.getInstance().members;
			for (var i:int=0; i < arr.length; i++) {
				var p:p_team_role=arr[i];
				if (role_id == p.role_id) {
					isMember=true;
					break;
				}
			}
			return isMember;
		}

		/**
		 * 接收邀请
		 * @param e
		 *
		 */
		private function toAccept(rid:int, tid:int, leader_id:int, type_id:int):void {
			var vo:m_team_accept_tos=new m_team_accept_tos();
			vo.role_id=rid;
			vo.team_id=tid;
			vo.type_id=type_id;
			vo.leader_id=leader_id;
			_module.send(vo);
		}

		/**
		 * 拒绝邀请
		 * @param e
		 *
		 */
		private function toRefuse(rid:int, tid:int, leader_id:int, type_id:int):void {
			var vo:m_team_refuse_tos=new m_team_refuse_tos();
			vo.role_id=rid;
			vo.team_id=tid;
			vo.leader_id=leader_id;
			vo.type_id=type_id;
			_module.send(vo);
		}


		/**
		 * 踢人出队
		 * @param e
		 *
		 */
		public function toKick(tarid:int):void {
			var vo:m_team_kick_tos=new m_team_kick_tos;
			vo.role_id=tarid;
			_module.send(vo);
		}

		/**
		 * 解散，队长才有资格
		 *
		 */
		public function toDisband():void {
			if (SceneDataManager.isCrusadeMap == false && SceneDataManager.isEducateFbMap == false && SceneDataManager.isSceneWarFbMap == false) {
				var vo:m_team_disband_tos=new m_team_disband_tos;
				vo.team_id=myteamid;
				_module.send(vo);
			} else {
				if (SceneDataManager.isCrusadeMap) {
					broadcast("在讨伐敌营副本不能解散队伍");
				} else if (SceneDataManager.isEducateFbMap) {
					broadcast("在师徒副本不能解散队伍");
				} else if (SceneDataManager.isSceneWarFbMap) {
					broadcast("在副本内不能解散队伍");
				} else {
					broadcast("此场景不能解散队伍");
				}
			}
		}

		public function toWindowChat(role:p_team_role):void {
			var vo:p_friend_info=new p_friend_info;
			vo.roleid=role.role_id;
			vo.rolename=role.role_name;
			vo.head=role.skin.skinid;
			Dispatch.dispatch(ModuleCommand.OPEN_FRIEND_PRIVATE, vo);
		}

		public function toFollow(role:p_team_role):void {
			if (role.map_id == SceneDataManager.mapID) {
				var tar:Role=SceneUnitManager.getUnit(role.role_id) as Role;
				if (tar != null) { //在附近，就跟随
					Dispatch.dispatch(ModuleCommand.FOLLOW, role.role_id);
				} else { //在同地图，但不在附近，就前往
					var vo:RunVo=new RunVo;
					vo.pt=new Pt(role.tx, 0, role.ty);
					vo.cut=2;
					Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, vo);
				}
			} else { //不在同地图，也前往
				var run:RunVo=new RunVo;
				run.mapid=role.map_id;
				run.pt=new Pt(role.tx, 0, role.ty);
				run.cut=2;
				Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, run);
			}
		}

		/**
		 * 离开队伍
		 * @param vo
		 *
		 */
		public function toLeave():void {
			var vo:m_team_leave_tos=new m_team_leave_tos;
			vo.team_id=myteamid;
			_module.send(vo);
		}

		/**
		 * 请求换队长
		 * @param roleid
		 * @param rolename
		 *
		 */
		public function toChangeLeader(roleid:int, rolename:String):void {
			if (SceneDataManager.isEducateFbMap == false && SceneDataManager.isSceneWarFbMap == false) {
				var vo:m_team_change_leader_tos=new m_team_change_leader_tos;
				vo.team_id=myteamid;
				vo.role_id=roleid;
				vo.role_name=rolename;
				_module.send(vo);
			} else {
				if (SceneDataManager.isEducateFbMap) {
					broadcast("在师徒副本不能移交队长");
				} else if (SceneDataManager.isSceneWarFbMap) {
					broadcast("在副本内不能移交队长");
				} else {
					broadcast("此场景不能移交队长");
				}
			}
		}



		/**
		 * 邀请组队返回
		 * @param vo
		 *
		 */
		public function onInviteBack(vo:m_team_invite_toc):void {
			if (vo.succ) {
				if (vo.return_self) {
					//返回我邀请了别人;
					broadcast("已邀请" + vo.role_name + "组队");
				} else {
					if (vo.type_id > 0) {
						if (vo.type_id == 2) {
							Alert.show("<font color='#FFFF00'>[" + vo.role_name + "]</font>仰慕你名满天下，想拜你为师，特邀请你组队，是否同意？", "提示", yesHandler, noHandler, "同意", "拒绝", [vo.role_id, vo.team_id, vo.leader_id, vo.type_id], true, true, null, null, false);
						} else {
							Alert.show("<font color='#FFFF00'>[" + vo.role_name + "]</font>见你资质过人，想收你为徒，特邀请你组队，是否同意？", "提示", yesHandler, noHandler, "同意", "拒绝", [vo.role_id, vo.team_id, vo.leader_id, vo.type_id], true, true, null, null, false);
						}
					} else if(SystemConfig.autoAcceptTeam){
						//自动同意组队,或拒绝组队
						yesHandler(vo.role_id, vo.team_id, vo.leader_id, vo.type_id); 
					}else {
						//手动同意组队
						var str:String=vo.pick_type == 1 ? "自由拾取" : "独自拾取";
						var msg:String="<font color='#00ff00' size='12'>[" + vo.role_name + "]</font><font color='#ffffff'>" + str + "模式邀请你组队，是否同意？</font>"
						var key:String=Prompt.show(msg, "邀请组队", yesHandler, noHandler, "同意", "拒绝", [vo.role_id, vo.team_id, vo.leader_id, vo.type_id], true, false, new Point(Math.random() * 200 + 300, Math.random() * 200 + 200));
						prompts.push(key);
					}
				}
			} else {
				if (vo.return_self) {
					if (vo.type_id == 1 || vo.type_id == 2) {
						// 师徒组队请求特殊处理
						Alert.show("对方已有队伍，需要进行窗口聊天与对方沟通吗？", "提示", chatFunc, null, "窗口聊天", "取消", new Array(vo.role_id, vo.role_name));
					} else {
						broadcast(vo.reason);
					}
				} else {
					broadcast(vo.reason);
				}
			}
		}

		private function chatFunc(role_id:int, role_name:String):void {
			var p:p_friend_info=new p_friend_info();
			p.roleid=role_id;
			p.rolename=role_name;
			p.head=1;
			Dispatch.dispatch(ModuleCommand.OPEN_FRIEND_PRIVATE, p);
		}

		/**
		 * 接受邀请
		 *
		 */
		private function yesHandler(rid:int, tid:int, leader_id:int, type_id:int):void {
			toAccept(rid, tid, leader_id, type_id);
			for (var i:int=0; i < prompts.length; i++) {
				var key:String=prompts[i];
				Prompt.removePromptItem(key);
			}
			prompts=[];
		}

		/**
		 * 拒绝邀请
		 *
		 */
		private function noHandler(rid:int, tid:int, leader_id:int, type_id:int):void {
			toRefuse(rid, tid, leader_id, type_id);
		}

		/**
		 * 接受邀请返回
		 * @param vo
		 *
		 */
		public function onAcceptBack(vo:m_team_accept_toc):void {
			if (vo.succ) {
				myteamid=vo.team_id;
				GlobalObjectManager.getInstance().user.base.team_id=vo.team_id;
				TeamDataManager.pickMode = vo.pick_type;
				frontid=getFrontId(vo.role_list);
				upDateRoleList(vo.role_list);
				if (vo.return_self) {
					if (vo.type_id == 1 || vo.type_id == 2) {
						EducateModule.getInstance().alertGotoAdmin();
					} else {
						broadcast(vo.role_name + "已加入队伍");
					}
				} else {
					if (vo.type_id == 1 || vo.type_id == 2) {
						EducateModule.getInstance().alertGotoAdmin();
					} else {
						//有新角色加入队伍啦
						broadcast(vo.role_name + "已加入队伍");
					}
				}
			} else {
				broadcast(vo.reason);
			}
		}

		/**
		 * 拒绝邀请返回
		 * @param vo
		 *
		 */
		public function onRefuseBack(vo:m_team_refuse_toc):void {
			if (vo.type_id == 1) {
				Alert.show("抱歉哦，<font color='#FFFF00'>[" + vo.role_name + "]</font>暂时没有拜师的打算，建议你另选高徒。", "提示", null, null, "确定", null, null, false);
			} else if (vo.type_id == 2) {
				Alert.show("抱歉哦，<font color='#FFFF00'>[" + vo.role_name + "]</font>暂时没有收徒的打算，建议你另择名师。", "提示", null, null, "确定", null, null, false);
			} else {
				broadcast(vo.role_name + "不同意组队");
			}
		}


		/**
		 * 离开队伍返回
		 * @param vo
		 *
		 */
		public function onLeaveBack(vo:m_team_leave_toc):void {
			if (vo.succ) {
				if (vo.return_self) {
					//我退出队伍，操作成功！
					myteamid=-1;
					GlobalObjectManager.getInstance().user.base.team_id=0;
					upDateRoleList();
					broadcast("成功退出队伍");
                    clearApplyTeamAlertDict();
				} else {
					//别人退队
					upDateRoleList(vo.role_list);
					broadcast(HtmlUtil.font3("[" + vo.role_name + "]", "#00ff00") + "退出队伍");
				}
			} else {
				//退出队伍，操作失败
				broadcast(vo.reason);
			}
		}

		/**
		 * 某人离线（下行）
		 * @param vo
		 *
		 */
		public function onOffline(vo:m_team_offline_toc):void {
			if (vo.cache_offline == true) {
				_view.offlineSet(vo);
			} else {
				upDateRoleList(vo.role_list);
				broadcast("队伍人员" + HtmlUtil.font3("[" + vo.role_name + "]", "#00ff00") + "下线了");
			}
		}


		/**
		 * 更换队长（下行）
		 * @param vo
		 *
		 */
		public function onChangeLeader(vo:m_team_change_leader_toc):void {
			if (vo.succ) {
				upDateRoleList(vo.role_list);
				broadcast("队长已转移给" + HtmlUtil.font3("[" + vo.role_name + "]", "#00ff00"));
                //转移队长之后需要清除玩家申请的弹窗
                clearApplyTeamAlertDict();
			} else {
				if (vo.return_self) {
					broadcast(vo.reason);
				}
			}
		}

		/**
		 * 踢人（下行）
		 * @param vo
		 *
		 */
		public function onKickBack(vo:m_team_kick_toc):void {
			if (vo.succ) {
				if (vo.role_id == GlobalObjectManager.getInstance().user.base.role_id) { //我被踢了
					myteamid=-1;
					GlobalObjectManager.getInstance().user.base.team_id=0;
					upDateRoleList();
					broadcast("你已经被队长移出队伍");
				} else {
					upDateRoleList(vo.role_list);
					broadcast(HtmlUtil.font3("[" + vo.role_name + "]", "#00ff00") + "已经被队长移出队伍");
				}
			} else {
				if (vo.return_self) {
					broadcast(vo.reason);
				}
			}
		}

		public function onDisband(vo:m_team_disband_toc):void {
			if (vo.succ) {
				myteamid=-1;
				GlobalObjectManager.getInstance().user.base.team_id=0;
				upDateRoleList();
                clearApplyTeamAlertDict();
				if (vo.return_self) {
					broadcast("队伍已解散");
				} else {
					broadcast("队伍已解散");
				}
			} else {
				if (vo.return_self) {
					broadcast(vo.reason);
				}
			}
		}

		public function onAutoDisband(vo:m_team_auto_disband_toc):void {
			if (vo != null && vo.succ) {
				myteamid=-1;
				GlobalObjectManager.getInstance().user.base.team_id=0;
				upDateRoleList();
                clearApplyTeamAlertDict();
				broadcast("队伍解散了");
			} else {
			}
		}

		public function onAutoList(vo:m_team_auto_list_toc):void {
			if (vo) {
				myteamid=vo.team_id;
				GlobalObjectManager.getInstance().user.base.team_id=vo.team_id;
				TeamDataManager.pickMode = vo.pick_type;
				upDateRoleList(vo.role_list);
				_view.reMemberVisible(vo.visible_role_list);
			} else {
				broadcast("队伍已解散");
			}
		}

		/**
		 * 改变物品拾取模式
		 * @param type
		 *
		 */
		public function toChangePick(type:int):void {
			var vo:m_team_pick_tos=new m_team_pick_tos;
			vo.pick_type=type;
			_module.send(vo);
		}

		public function onChangePick(vo:m_team_pick_toc):void {
			if (vo.succ) {
				TeamDataManager.pickMode = vo.pick_type;
				var str:String=vo.pick_type == 1 ? "自由拾取" : "独自拾取";
				broadcast("队伍物品拾取模式改变：" + str);
			} else {
				broadcast(vo.reason);
			}
		}
		/**
		 *
		 * @param vo
		 *
		 */
		public function onMemberInvite(vo:m_team_member_invite_toc):void {
			if (vo.op_status == 1) {
				//表示收到组队请求
				var answer:m_team_member_invite_tos=new m_team_member_invite_tos;
				answer.member_id=vo.member_id;
				answer.member_name=vo.member_name;
				answer.role_id=vo.role_id;
				answer.role_name=vo.role_name;
				if(!SystemConfig.autoTeam){
					var key:String=Prompt.show("队员" + vo.member_name + "邀请玩家" + vo.role_name + "加入队伍，你是否同意？", "邀请组队", yesMemberInvite, nosMemberInvite, "同意", "拒绝", [answer]);
					prompts.push(key);
				}else{
					yesMemberInvite(answer)
				}
			} else if (vo.op_status == 2) {
				broadcast(vo.reason);
			}
		}

		/**
		 * 队长同意队员邀请他人组队
		 * @param vo
		 *
		 */
		private function yesMemberInvite(vo:m_team_member_invite_tos):void {
			vo.op_type=1;
			_module.send(vo);
		}

		private function nosMemberInvite(vo:m_team_member_invite_tos):void {
			vo.op_type=2;
			_module.send(vo);
		}

		/**
		 * 更新组队人员列表界面
		 * @param arr
		 *
		 */
		private function upDateRoleList(arr:Array=null):void {
			if (arr == null) {
				arr=[];
			}
			upDateSceneRole(arr);
			_view.reFresh(arr);
			toFridens();
		}

		private function upDateSceneRole(arr:Array):void {
			var role:IRole;
			for (var i:int=0; i < arr.length; i++) {
				var team:p_team_role=arr[i] as p_team_role;
				role=IRole(SceneUnitManager.getUnit(team.role_id));
				if (role != null && role.pvo != null) {
					role.pvo.team_id=GlobalObjectManager.getInstance().user.base.team_id;
				}
			}

		}

		/**
		 * 请求获取推荐组队的数据
		 * @param
		 *
		 *
		 */
		private var xx:int;
		private var yy:int;

		public function requestRecommendTeamData(posX:int, posY:int):void {
			var vo:m_team_member_recommend_tos=new m_team_member_recommend_tos();
			_module.send(vo);

			xx=posX;
			yy=posY;
		}

		/**
		 *
		 * 请求获取推荐组队的数据返回
		 * @return
		 *
		 */

		public function recommendTeamDataBack(data:Object):void {
			var vo:m_team_member_recommend_toc=data as m_team_member_recommend_toc;
			if (vo.succ) {
				RecommendTeamView.getInstance().setData(vo.member_info, xx, yy);
				WindowManager.getInstance().popUpWindow(RecommendTeamView.getInstance(), WindowManager.UNREMOVE);
					//				WindowManager.getInstance().centerWindow(RecommendTeamView.getInstance());
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		/**
		 * 获得跟随目标roleid
		 * @param arr
		 * @return
		 *
		 */
		private function getFrontId(arr:Array=null):int {
			if (arr == null)
				return -1;
			var tarid:int=-1;
			for (var i:int=0; i < arr.length; i++) {
				if (arr[i].role_id == GlobalObjectManager.getInstance().user.base.role_id) {
					if (arr[i - 1] != null) {
						tarid=arr[i - 1].role_id;
					}
					break;
				}
			}
			return tarid;
		}
		
		public function getNearbyTeam():void{
			var vo:m_team_query_tos = new m_team_query_tos();
			vo.op_type = 1;
			_module.send(vo);
		}
		
		public function onTeamQuery(vo:m_team_query_toc):void{
			if(vo.succ && teamPanel){
				teamPanel.updateNearbyTeam(vo.nearby_list);
			}else{
				broadcast(vo.reason);
			}
			
		}
		
		public function createTeam(roleID:int):void{
			var vo:m_team_create_tos = new m_team_create_tos();
			vo.role_id = roleID;
			_module.send(vo);
		}
		
		public function onTeamCreate(vo:m_team_create_toc):void{
			if (vo.succ) {
				myteamid=vo.team_id;
				GlobalObjectManager.getInstance().user.base.team_id=vo.team_id;
				TeamDataManager.pickMode = vo.pick_type;
				frontid=getFrontId(vo.role_list);
				upDateRoleList(vo.role_list);
				broadcast("创建队伍成功");
			} else {
				broadcast(vo.reason);
			}
		}

		private function broadcast(msg:String):void {
			BroadcastSelf.getInstance().appendMsg(msg);
			Tips.getInstance().addTipsMsg(msg);
			//BroadcastView.getInstance().addBroadcastMsg(msg);
		}

		private function toFridens():void {
			Dispatch.dispatch(ModuleCommand.UPDATE_TEAMGROUP);
		}
	}
}