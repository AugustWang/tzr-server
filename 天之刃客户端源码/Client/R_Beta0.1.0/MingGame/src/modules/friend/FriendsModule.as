package modules.friend {
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	import com.components.alert.Alert;
	import com.components.alert.Prompt;
	import com.managers.MusicManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.chat.ChatType;
	import modules.family.FamilyModule;
	import modules.friend.views.CommunityWindow;
	import modules.friend.views.FriendManagerPanel;
	import modules.friend.views.FriendsForluckPanel;
	import modules.friend.views.FriendsListPanel;
	import modules.friend.views.friends.FriendView;
	import modules.friend.views.messageBox.MessageBox;
	import modules.friend.views.part.ChatWindowManager;
	import modules.friend.views.part.OneToOnePanel;
	import modules.friend.views.recommendFriends.RecommendFriendView;
	import modules.friend.views.vo.GroupSettingVO;
	import modules.friend.views.vo.GroupType;
	import modules.friend.views.vo.GroupVO;
	import modules.letter.LetterModule;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.team.TeamModule;
	
	import proto.chat.m_chat_auth_toc;
	import proto.chat.m_chat_get_roles_toc;
	import proto.chat.m_chat_get_roles_tos;
	import proto.chat.m_chat_in_channel_toc;
	import proto.chat.m_chat_in_channel_tos;
	import proto.chat.m_chat_in_pairs_toc;
	import proto.chat.m_chat_in_pairs_tos;
	import proto.chat.m_chat_join_channel_toc;
	import proto.chat.m_chat_leave_channel_toc;
	import proto.chat.m_chat_new_join_toc;
	import proto.chat.m_chat_quick_toc;
	import proto.chat.m_chat_status_change_toc;
	import proto.common.p_channel_info;
	import proto.common.p_chat_role;
	import proto.common.p_role_ext;
	import proto.line.*;

	public class FriendsModule extends BaseModule {
		private var messageFails:Dictionary; //为防止对方不在将发送失败之前的消息缓存在此。等失败返回之后换成写信功能（其实要后台做才准确）
		public var communityWindow:CommunityWindow;
		private var friendManagerPanel:FriendManagerPanel;
		private var friendView:FriendView;
		private var friendsListPanel:FriendsListPanel;
		private var friendsManager:FriendsManager;
		private static var _instance:FriendsModule;

		public function FriendsModule() {
			friendsManager=FriendsManager.getInstance();
		}

		public static function getInstance():FriendsModule {
			if (_instance == null)
				_instance=new FriendsModule();
			return _instance;
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.OPEN_FRIEND_LIST, openFriendsPanel);
			addMessageListener(ModuleCommand.GET_FRIEND_ENERMY, getFriendsEnermy);
			addMessageListener(ModuleCommand.SEND_FRIEND_PRIVATE_RETURN, acceptMessage);
			addMessageListener(ModuleCommand.ADD_FRIEND, requestFriend);
			addMessageListener(ModuleCommand.ADD_BLACK, addBlack);
			addMessageListener(ModuleCommand.OPEN_FRIEND_PRIVATE, openPrivateWindow);
			addMessageListener(ModuleCommand.CHANGE_FAMILY_VIEW, changeFamilyView);
			addMessageListener(ModuleCommand.FRIENDS_GROUP_INIT, initGroup);
			addMessageListener(ModuleCommand.INIT_GROUP_MEMBERS, initGroupMembers);
			addMessageListener(ModuleCommand.GROUP_MEMBER_EXIT, groupMemberExit);
			addMessageListener(ModuleCommand.GROUP_MEMBER_ONOFFLINE, groupMemberOffOnline);
			addMessageListener(ModuleCommand.GROUP_MEMBER_JOIN, groupMemberJoin);
			addMessageListener(ModuleCommand.GROUP_MESSAGE, groupMessage);
			addMessageListener(ModuleCommand.JOIN_GROUP_CHANNEL, joinGroupChannel);
			addMessageListener(ModuleCommand.EXIT_GROUP_CHANNEL, exitGroupChannel);
			addMessageListener(ModuleCommand.UPDATE_TEAMGROUP, updateTeamGroup);
			addMessageListener(ModuleCommand.OPEN_OFFLINE_PANEL, openOffLinePanel);
			addMessageListener(ModuleCommand.OPEN_FAMILY_RQUEST_PANEL, openFamliyRequestPanel);
			addMessageListener(ModuleCommand.ENTER_GAME, getFriendsList);
			addMessageListener(NPCActionType.NA_63, openFamilyView);
			addMessageListener(ModuleCommand.OPEN_EDUCATE_VIEW,openEducateView);

			addSocketListener(SocketCommand.FRIEND_LIST, setFriendsList);
			addSocketListener(SocketCommand.FRIEND_REQUEST, setRequestFriend);
			addSocketListener(SocketCommand.FRIEND_ACCEPT, setAcceptFriend);
			addSocketListener(SocketCommand.FRIEND_REFUSE, setRefuseFriend);
			addSocketListener(SocketCommand.FRIEND_DELETE, setDeleteFriend);
			addSocketListener(SocketCommand.FRIEND_BLACK, setAddBlack);
			addSocketListener(SocketCommand.FRIEND_MODIFY, setModifyInfo);
			addSocketListener(SocketCommand.FRIEND_ONLINE, setFriendOnline);
			addSocketListener(SocketCommand.FRIEND_OFFLINE, setFriendOffline);
			addSocketListener(SocketCommand.FRIEND_CHANGE_RELATIVE, setChangeRelative);
			addSocketListener(SocketCommand.FRIEND_ADD_FRIENDLY, setAddFriendly);
			addSocketListener(SocketCommand.FRIEND_CREATE_FAMILY, setFriendCreateFamliy);
			addSocketListener(SocketCommand.FRIEND_OFFLINE_REQUEST, setFriendOfflineRequest);
			addSocketListener(SocketCommand.FRIEND_ENEMY, setFriendEnemy);
			addSocketListener(SocketCommand.FRIEND_UPGRADE, setFriendUpGrade);
			addSocketListener(SocketCommand.FRIEND_GET_INFO, setFriendGetInfo);
			addSocketListener(SocketCommand.FRIEND_UPDATE_FAMILY, setFriendLevelUpFamliy);
			addSocketListener(SocketCommand.FRIEND_RECOMMEND, setRecommendFriendsData);
			addSocketListener(SocketCommand.FRIEND_CONGRATULATION, setFriendsGoodLuck);
			addSocketListener(SocketCommand.FRIEND_ADVERTISE, friendAdvertiseRet);
		}

		/*********************************界面视图逻辑********************************************/
		public function openFriendsPanel(p:Point=null):void {
			if (friendsListPanel == null) {
				friendsListPanel=new FriendsListPanel();
				friendsListPanel.x=500;
				friendsListPanel.y=30;
			}
			if (p) {
				friendsListPanel.x=p.x;
				friendsListPanel.y=p.y;
			}
			WindowManager.getInstance().popUpWindow(friendsListPanel);
		}

		/**
		 * 从聊天频道受到消息(好友窗口聊天)
		 */
		private function acceptMessage(data:Object):void {
			var vo:m_chat_in_pairs_toc=data as m_chat_in_pairs_toc;
			if (vo.succ && vo.msg != "") {
				var friendId:int=vo.from_role_info.roleid;
				var fromFriend:p_chat_role;
				var isSelf:Boolean=false;
				if (vo.from_role_info.roleid == GlobalObjectManager.getInstance().user.attr.role_id) {
					friendId=vo.to_role_info.roleid;
					isSelf=true;
				} else {
					fromFriend=vo.from_role_info;
				}
				if (!ChatWindowManager.getInstance().isPopUp(friendId)) {
					if (fromFriend) {
						var friendVO:p_friend_info=friendsManager.getFriendVO(fromFriend.roleid);
						if (friendVO == null) {
							friendVO=new p_friend_info();
							friendVO.roleid=fromFriend.roleid;
							friendVO.rolename=fromFriend.rolename;
							friendVO.head=fromFriend.head;
							friendVO.type=FriendsConstants.STRANGER_TYPE;
							friendsManager.addFriend(friendVO);
						}
						MessageBox.getInstance().addMessage(friendVO);
					}
					friendsManager.setFlick(friendId, true);
					MusicManager.playSound(MusicManager.NEWMESSAGE);
				}
				if (messageFails) {
					delete messageFails[friendId];
				}
				var titles:String=getRoleTitles(vo.from_role_info);
				var nameHTML:String=vo.from_role_info.rolename;
				if (!isSelf) {
					nameHTML="<a href='event:popUp'>" + nameHTML + "</a>";
				}
				var msg:String=titles + "<font color='#00ff00'>[" + nameHTML + "]</font>   " + DateFormatUtil.formatHours(vo.tstamp) + "\n" + vo.msg;
				ChatWindowManager.getInstance().addMessage(friendId, msg);
			} else {
				if (vo.error_code == 1) { //不在线
					if (messageFails && messageFails[vo.to_role_id]) {
						var obj:Object=messageFails[vo.to_role_id];
						Alert.show("您的好友" + HtmlUtil.font("[" + obj.roleName + "]", "#00ff00") + "不在线，请问是否给他发信件？", "温馨提示", sendLetter, null, "确定", "取消", [obj]);
					} else {
						ChatWindowManager.getInstance().addMessage(vo.to_role_id, HtmlUtil.font("对方已离线，无法发送信息！", "#ff0000"));
					}
				} else if (vo.error_code == 2) {
					ChatWindowManager.getInstance().addMessage(vo.to_role_id, HtmlUtil.font("已将对方加入黑名单，无法发送信息！", "#ff0000"));
				} else {
					ChatWindowManager.getInstance().addMessage(vo.to_role_id, HtmlUtil.font(vo.reason, "#ff0000"));
				}
			}
		}

		private function sendLetter(obj:Object):void {
			LetterModule.getInstance().writeLetter(obj.roleName, obj.msg);
		}

		public function getRoleTitles(vo:p_chat_role, channel_sign:String=""):String {
			var sex:String=vo.sex == 1 ? "<font color='#00ccff'>♂</font>" : "<font color='#ff37e0'>♀</font>";
			var titles:String=ChatModule.getInstance().getTitles(vo.titles, ChatType.COUNTRY_CHANNEL);
			return sex + titles;
		}

		/**
		 * 窗口聊天消息发送
		 */
		public function send(msg:String, receiver:p_friend_info):void {
			if (messageFails == null) {
				messageFails=new Dictionary();
			}
			messageFails[receiver.roleid]={msg: msg, roleName: receiver.rolename};
			var vo:m_chat_in_pairs_tos=new m_chat_in_pairs_tos();
			vo.msg=msg;
			vo.to_rolename=receiver.rolename;
			vo.show_type=FriendsConstants.FRIEND_PRIVATE;
			dispatch(ModuleCommand.SEND_FRIEND_PRIVATE, vo);
		}

		/**
		 * 获取好友ID和仇人ID
		 */
		private function getFriendsEnermy():void {
			var friends:Array=friendsManager.getIdsByType(FriendsConstants.FRIENDS_TYPE);
			var enermys:Array=friendsManager.getIdsByType(FriendsConstants.ENEMY_TYPE);
			var result:Object={'friends': friends, 'enermys': enermys};
			dispatch(ModuleCommand.SET_FRIEND_ENERMY, result);
		}

		/**
		 * 打开私聊对话窗口
		 */
		private function openPrivateWindow(friend:p_friend_info):void {
			if (friend) {
				ChatWindowManager.getInstance().openChatWindow(friend);
			}
		}

		public function showTaskBounds():void {
		}

		/**
		 * 改变 门派界面
		 */
		private function changeFamilyView():void {
			if (communityWindow) {
				communityWindow.changeFamilyView();
			}
		}

		/**
		 * 打开社会面板
		 */
		public function openCommunityWindow(remove:Boolean=true):void {
			if (communityWindow == null) {
				communityWindow=new CommunityWindow();
				WindowManager.getInstance().centerWindow(communityWindow);
			}
			var mode:String=remove ? WindowManager.REMOVE : WindowManager.UNREMOVE;
			WindowManager.getInstance().popUpWindow(communityWindow, mode);
		}
		/**
		 * 打开好友管理面板  
		 * 
		 */		
		public function openFriendManagerPanel(remove:Boolean=true):void{
			if(friendManagerPanel == null){
				friendManagerPanel = new FriendManagerPanel();
			}
			var mode:String=remove ? WindowManager.REMOVE : WindowManager.UNREMOVE;
			WindowManager.getInstance().popUpWindow(friendManagerPanel, mode);
			WindowManager.getInstance().centerWindow(friendManagerPanel);
		}
		/**
		 * 获取好友社会视图
		 */
		public function getFriendView():FriendView {
			if (friendView == null) {
				friendView=new FriendView();
			}
			return friendView;
		}

		/**
		 * 打开好友离线申请面板
		 */
		private function openOffLinePanel():void {
			openFriendManagerPanel(false);
			if (friendView) {
				friendView.selectIndex(3);
			}
		}

		/**
		 * 打开门派请求面板
		 */
		public function openFamliyRequestPanel():void {
			openFamilyView();
			FamilyModule.getInstance().OpenMyFamily();
		}

		/**
		 *打开好友列表面板
		 */
		public function openFriendView():void {
			openFriendManagerPanel(false);
			friendManagerPanel.selectedIndex=0;
		}

		/**
		 *打开师徒面板
		 */
		public function openEducateView():void {
			openCommunityWindow(false);
			communityWindow.selectedIndex=1;
		}

		/**
		 *打开门派面板
		 */
		public function openFamilyView(vo:NpcLinkVO=null):void {
			openCommunityWindow(false);
			communityWindow.selectedIndex=0;
			FamilyModule.getInstance().openJoinFamilyView();
		}

		/**
		 * 提供给导航条打开门派面板
		 */
		public function openFamilyPanel():void {
			openCommunityWindow();
			if (communityWindow && communityWindow.parent) {
				communityWindow.selectedIndex=0;
			}
		}

		/**
		 *打开国家面板
		 */
		public function openNationView():void {
			openCommunityWindow(false);
			communityWindow.selectedIndex=2;
		}

		/**
		 * 打开申请列表
		 */
		public function openApplications():void {
			openCommunityWindow(true);
			friendView.selectIndex(3);
		}

		/**
		 * 打开个人设置面板
		 */
		public function openFriendsSettings():void {
			openFriendManagerPanel(true);
			friendManagerPanel.selectedIndex=1;
		}

		/*********************************消息发送逻辑********************************************/
		
		/**
		 * 一键征友
		 */
		
		public function doFriendAdvertise():void
		{
			sendSocketMessage(new m_friend_advertise_tos());
		}
		
		/**
		 * 获取好友列表
		 */
		private function getFriendsList():void {
			sendSocketMessage(new m_friend_list_tos());
		}

		/**
		 * 请求加为好友
		 */
		public function requestFriend(friendName:String):void {
			if (friendName == GlobalObjectManager.getInstance().user.base.role_name) {
				Tips.getInstance().addTipsMsg("不能邀请自己为好友!");
				return;
			}
			var vo:m_friend_request_tos=new m_friend_request_tos();
			vo.name=friendName;
			sendSocketMessage(vo);
		}

		/**
		 * 接受对方好友请求
		 */
		public function acceptFriend(friendName:String):void {
			var vo:m_friend_accept_tos=new m_friend_accept_tos();
			vo.name=friendName;
			sendSocketMessage(vo);
		}

		/**
		 * 拒绝对方好友请求
		 */
		public function refuseFriend(friendName:String):void {
			var vo:m_friend_refuse_tos=new m_friend_refuse_tos();
			vo.name=friendName;
			sendSocketMessage(vo);
		}

		/**
		 * 删除好友
		 */
		public function deleteFriend(roleId:int):void {
			var friendVO:p_friend_info=friendsManager.getFriendVO(roleId);
			if (friendVO == null)
				return;
			if (friendVO.relative.length > 0) {
				Alert.show("不能删除有特殊关系的好友!", "警告", null, null, "确定", "", null, false);
				return;
			}
			var groupName:String=FriendsConstants.FRIENDS_TYPE_NAMES[friendVO.type];
			var msg:String="您真的要把" + HtmlUtil.font("[" + friendVO.rolename + "]", "#00ff00") + "从我的" + groupName + "列表移出？";
			if (friendVO.type == FriendsConstants.FRIENDS_TYPE) {
				msg+=HtmlUtil.font("\n（删除好友时双方的好友度将变成0）", "#f53f3c");
			}
			Alert.show(msg, "提示", yesHandler, null, "确定", "取消");
			function yesHandler():void {
				var vo:m_friend_delete_tos=new m_friend_delete_tos();
				vo.roleid=friendVO.roleid;
				sendSocketMessage(vo);
			}
		}

		/**
		 * 加入黑名单
		 */
		public function addBlack(name:String):void {
			Alert.show("你是否确定要将 " + HtmlUtil.font("[" + name + "]", "#00ff00") + " 加入黑名单？", "提示", yesHandler);
			function yesHandler():void {
				var vo:m_friend_black_tos=new m_friend_black_tos();
				vo.name=name;
				sendSocketMessage(vo);
			}
		}

		/**
		 * 修改个人信息
		 */
		public function modifyInfo(info:p_role_ext):void {
			var vo:m_friend_modify_tos=new m_friend_modify_tos();
			vo.info=info;
			sendSocketMessage(vo);
		}

		/**
		 *  获取某个群的好友列表，
		 */
		public function getGroupList(sign:String):void {
			var vo:m_chat_get_roles_tos=new m_chat_get_roles_tos();
			vo.channel_sign=sign;
			sendSocketMessage(vo);
		}

		/**
		 * 群消息发送
		 */
		public function sendGroupMessage(message:String, sign:String):void {
			var vo:m_chat_in_channel_tos=new m_chat_in_channel_tos();
			vo.msg=message;
			vo.channel_sign=sign;
			sendSocketMessage(vo);
		}

		/**
		 * 通过ID获取玩家窗口聊天基本信息
		 */
		public function getFriendInfoById(id:int):void {
			var vo:m_friend_get_info_tos=new m_friend_get_info_tos();
			vo.roleid=id;
			sendSocketMessage(vo);
		}

		/**
		 * 祝福好友
		 */
		public function goodLuckToFriend(toFriendId:int, content:String):void {
			var vo:m_friend_congratulation_tos=new m_friend_congratulation_tos();
			vo.to_friend_id=toFriendId;
			vo.congratulation=content;
			sendSocketMessage(vo);
		}

		/*********************************消息接受并处理逻辑***************************************/
		
		/**
		 * 一键征友
		 */
		
		private function friendAdvertiseRet(vo:m_friend_advertise_toc):void
		{
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("已提交征友请求，请稍后");
				return;
			}
			BroadcastSelf.logger(vo.reason);
		}
		
		/**
		 * 获取好友信息列表(返回)
		 */
		private function setFriendsList(data:Object):void {
			var vo:m_friend_list_toc=data as m_friend_list_toc;
			if (vo.succ) {
				friendsManager.setFriendLists(vo.friend_list);
				if (friendsListPanel) {
					friendsListPanel.setFriendsDataProvider(friendsManager.friendsDataProvider);
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 请求加为好友(返回)
		 */
		private function setRequestFriend(data:Object):void {
			var vo:m_friend_request_toc=data as m_friend_request_toc;
			if (vo.succ) {
				if (vo.return_self) {
					Tips.getInstance().addTipsMsg("请求添加好友[" + vo.name + "]已发送.");
				} else {
					Prompt.show(HtmlUtil.font("[" + vo.name + "]", "#00ff00") + " 想加您为好友，是否接受并加他为好友？", "提示", yesHandler, noHandler, "接受", "取消", null, true, true);
				}
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
			function yesHandler():void {
				acceptFriend(vo.name);
			}
			function noHandler():void {
				refuseFriend(vo.name);
			}
		}

		/**
		 * 接受对方好友请求(返回)
		 */
		private function setAcceptFriend(data:Object):void {
			var vo:m_friend_accept_toc=data as m_friend_accept_toc;
			if (vo.succ) {
				friendsManager.addFriend(vo.friend_info);
				Tips.getInstance().addTipsMsg("恭喜[" + vo.friend_info.rolename + "]与你结为好友，成为点头之交。");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		/**
		 * 拒绝对方好友请求(返回)
		 */
		private function setRefuseFriend(data:Object):void {
			var vo:m_friend_refuse_toc=data as m_friend_refuse_toc;
			if (vo.succ) {
				if (vo.return_self) {
					Tips.getInstance().addTipsMsg("您拒绝了[" + vo.name + "]的好友请求。");
				} else {
					Tips.getInstance().addTipsMsg("不好意思，[" + vo.name + "]拒绝了您的好友请求。");
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 删除好友(返回)
		 */
		private function setDeleteFriend(data:Object):void {
			var vo:m_friend_delete_toc=data as m_friend_delete_toc;
			if (vo.succ) {
				var friend:p_friend_info=friendsManager.getFriendVO(vo.roleid);
				friendsManager.deleteFriend(vo.roleid);
				if (vo.return_self) {
					var msg:String="成功删除";
					if (friend) {
						if (friend.type == FriendsConstants.FRIENDS_TYPE) {
							msg+="好友!";
						} else if (friend.type == FriendsConstants.BLACK_TYPE) {
							msg="已经将对方从黑名单移除!";
						} else if (friend.type == FriendsConstants.ENEMY_TYPE) {
							msg+="仇人!";
						} else if (friend.type == FriendsConstants.STRANGER_TYPE) {
							msg+="陌生人!";
						}
					}
					Tips.getInstance().addTipsMsg(msg);
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 加入黑名单(返回)
		 */
		private function setAddBlack(data:Object):void {
			var vo:m_friend_black_toc=data as m_friend_black_toc;
			if (vo.succ) {
				friendsManager.addBlack(vo.friend_info);
				if (vo.return_self) {
					Tips.getInstance().addTipsMsg("玩家[" + vo.friend_info.rolename + "]已被屏蔽");
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 修改个人信息
		 */
		private function setModifyInfo(data:Object):void {
			var vo:m_friend_modify_toc=data as m_friend_modify_toc;
			if (vo.succ) {
				if (vo.return_self) {
					GlobalObjectManager.getInstance().user.ext=vo.info;
					Tips.getInstance().addTipsMsg("个人信息修改成功.");
					if (friendsListPanel) {
						friendsListPanel.updateMyInfo();
					}
				} else {
					friendsManager.changeSign(vo.info.role_id, vo.info.signature);
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 好友上线
		 */
		private function setFriendOnline(data:Object):void {
			var vo:m_friend_online_toc=data as m_friend_online_toc;
			friendsManager.setOnline(vo.roleid, true);
			var friend:p_friend_info=friendsManager.getFriendVO(vo.roleid);
			if (friend) {
				var tip:String="";
				if (friend.type == FriendsConstants.FRIENDS_TYPE) {
					if (friend.relative == null || friend.relative.length == 0) {
						tip=HtmlUtil.font("你的好友[" + friend.rolename + "]上线了", "#00ff00");
						BroadcastSelf.logger(tip);
					} else if (friend.relative.length > 0) {
						tip=HtmlUtil.font("你的" + FriendsConstants.RELATIVES_TIPS[friend.relative[friend.relative.length - 1]] + "[" + friend.rolename + "]上线了", "#40DEF9");
						BroadcastSelf.logger(tip);
					}
				} else if (friend.type == FriendsConstants.ENEMY_TYPE) {
					tip=HtmlUtil.font("你的仇人[" + friend.rolename + "]上线了", "#ff0000");
					BroadcastSelf.logger(tip);
				}
			}
		}

		/**
		 * 好友离线
		 */
		private function setFriendOffline(data:Object):void {
			var vo:m_friend_offline_toc=data as m_friend_offline_toc;
			friendsManager.setOnline(vo.roleid, false);
			var friend:p_friend_info=friendsManager.getFriendVO(vo.roleid);
			if (friend) {
				var tip:String="";
				if (friend.type == FriendsConstants.FRIENDS_TYPE) {
					if (friend.relative == null || friend.relative.length == 0) {
						tip=HtmlUtil.font("你的好友[" + friend.rolename + "]下线了", "#00ff00");
						BroadcastSelf.logger(tip);
					} else if (friend.relative.length > 0) {
						tip=HtmlUtil.font("你的" + FriendsConstants.RELATIVES_TIPS[friend.relative[friend.relative.length - 1]] + "[" + friend.rolename + "]下线了", "#40DEF9");
						BroadcastSelf.logger(tip);
					}
				} else if (friend.type == FriendsConstants.ENEMY_TYPE) {
					tip=HtmlUtil.font("你的仇人[" + friend.rolename + "]下线了", "#ff0000");
					BroadcastSelf.logger(tip);
				}
			}
		}

		/**
		 *改变和好友之间的特殊关系
		 */
		private function setChangeRelative(data:Object):void {
			var vo:m_friend_change_relative_toc=data as m_friend_change_relative_toc;
			friendsManager.changeRelative(vo.role_id, vo.relative);
		}

		/**
		 * 设置好友亲密度
		 */
		private function setAddFriendly(data:Object):void {
			var vo:m_friend_add_friendly_toc=data as m_friend_add_friendly_toc;
			var friend:p_friend_info=friendsManager.getFriendVO(vo.role_id);
			if (friend) {
				friend.friendly=vo.friendly;
				dispatch(friend.type.toString());
			}
		}

		/**
		 * 好友门派升级
		 */
		private function setFriendLevelUpFamliy(data:Object):void {
			var vo:m_friend_update_family_toc=data as m_friend_update_family_toc;
			var friend:p_friend_info=friendsManager.getFriendVO(vo.role_id);
			if (friend) {
				BroadcastModule.getInstance().popupWindowMsg("你的好友" + HtmlUtil.font("[" + friend.rolename + "]", "#00ff00") + "成功将门派  " + HtmlUtil.font(vo.family_name, "#ff7e00") + " 升级到 " + vo.level + " 级，快去恭喜TA吧")
			}
		}

		/**
		 * 好友创建了门派
		 */
		private function setFriendCreateFamliy(data:Object):void {
			var vo:m_friend_create_family_toc=data as m_friend_create_family_toc;
			var friend:p_friend_info=friendsManager.getFriendVO(vo.role_id);
			if (friend) {
				BroadcastModule.getInstance().popupWindowMsg("你的好友" + HtmlUtil.font("[" + friend.rolename + "]", "#00ff00") + "创建了门派  " + HtmlUtil.font(vo.family_name, "#ff7e00") + "，快去恭喜TA吧。")
			}
		}

		/**
		 * 玩家离线请求
		 */
		private function setFriendOfflineRequest(data:Object):void {
			var vo:m_friend_offline_request_toc=data as m_friend_offline_request_toc;
			friendsManager.offlineRequest=vo.request_list;
			BroadcastModule.getInstance().popupMsg("你有新的好友请求，赶快去查看吧!", HtmlUtil.font("点击查看", "#00ff00"), openOffLinePanel);
			//sendToModule(NavActionType.FRIEND_FLICK.toString(),null,ModelConstant.NAVIGATION_MODEL);
		}

		/**
		 *  设置仇人
		 */
		private function setFriendEnemy(data:Object):void {
			var vo:m_friend_enemy_toc=data as m_friend_enemy_toc;
			friendsManager.addFriend(vo.enemy_info);
		}

		/**
		 * 提示好友已经升级
		 */
		private function setFriendUpGrade(data:Object):void {
			var vo:m_friend_upgrade_toc=data as m_friend_upgrade_toc;
			var friend:p_friend_info=friendsManager.getFriendVO(vo.roleid);
			if (friend) {
				if (friend.type == FriendsConstants.FRIENDS_TYPE) {
					var goodLuck:Boolean=vo.newlevel % 10 == 0;
					var tip:String="";
					var level:int=GlobalObjectManager.getInstance().user.attr.level;
					var friendLevel:int=vo.newlevel;
					var isPopUp:Boolean=goodLuck && level >= 20 && friendLevel >= 20;
					//删除好友祝福提示窗口
//					if (friend.relative == null || friend.relative.length == 0) {
//						if (isPopUp) {
//							tip="你的好友[" + friend.rolename + "]升到" + vo.newlevel + "级了，快去恭喜他吧！";
//							tip="<font color='#ffff00'><u><a href='event:friendCongratula#" + friend.rolename + "," + friend.roleid + "," + vo.newlevel + "'>" + tip + "</a></u></font>";
////							tip="<font color='#ffff00'>你的好友[" + friend.rolename + "]升到" + vo.newlevel + "级了，快去<font color='#00ff00'><u><a href='event:friendCongratula#" + friend.rolename + "," + friend.roleid + "," + vo.newlevel + "'>恭喜</a></u></font>他吧！</font>";
//						} else {
//							tip=HtmlUtil.font("你的好友[" + friend.rolename + "]升到" + vo.newlevel + "级了。", "#00ff00");
//						}
//					} else if (friend.relative.length > 0) {
//						if (isPopUp) {
//							tip=HtmlUtil.font("你的" + FriendsConstants.RELATIVES_TIPS[friend.relative[friend.relative.length - 1]] + "[" + friend.rolename + "]升" + vo.newlevel + "级了，快去恭喜他吧！", "#00ff00");
//						} else {
//							tip=HtmlUtil.font("你的" + FriendsConstants.RELATIVES_TIPS[friend.relative[friend.relative.length - 1]] + "[" + friend.rolename + "]升到" + vo.newlevel + "级了。", "#00ff00");
//						}
//					}
					if (isPopUp) {
						MessageIconManager.getInstance().showGoodLuckIcon({handler: goodLuckHandler, friendName: friend.rolename, friendId: friend.roleid, level: vo.newlevel});
//						BroadcastModule.getInstance().popupMsg(tip);
					} else {
						BroadcastSelf.logger(tip);
					}
				} else if (friend.type == FriendsConstants.ENEMY_TYPE) {
					BroadcastSelf.logger(HtmlUtil.font("天哪，你的仇人[" + friend.rolename + "]居然升到" + vo.newlevel + "级了！", "#ff0000"));
				}


				// 更新好友等级
				friend.level=vo.newlevel;
				dispatch(friend.type.toString());
			}
		}

		/**
		 * 设置获取好友详细信息
		 */
		private function setFriendGetInfo(data:Object):void {
			var vo:m_friend_get_info_toc=data as m_friend_get_info_toc;
			var panel:OneToOnePanel=ChatWindowManager.getInstance().getPrivateWindow(vo.roleinfo.roleid);
			if (panel) {
				panel.sender=vo.roleinfo;
			}
		}

		/**
		 *
		 * 请求推荐好友数据
		 *
		 */
		private var xx:int;
		private var yy:int;

		public function requestRecommendData(posX:int, posY:int):void {
			var vo:m_friend_recommend_tos=new m_friend_recommend_tos();
			sendSocketMessage(vo);
			xx=posX;
			yy=posY;
		}

		/**
		 *
		 * 返回添加推荐好友数据
		 *
		 */
		private function setRecommendFriendsData(data:Object):void {
			var vo:m_friend_recommend_toc=data as m_friend_recommend_toc;
			if (vo.succ) {
				RecommendFriendView.getInstance().setData(vo.friend_info, xx, yy);
				WindowManager.getInstance().popUpWindow(RecommendFriendView.getInstance(), WindowManager.UNREMOVE);
			}
		}

		private function setFriendsGoodLuck(data:Object):void {
			var vo:m_friend_congratulation_toc=data as m_friend_congratulation_toc;
			if (vo.succ) {
				if (vo.return_self) {
					var tip:String="成功祝福好友" + HtmlUtil.font("[" + vo.from_friend + "]", "#00ff00");
					if (vo.exp_add > 0) {
						tip+="\n经验增加：" + vo.exp_add;
					}
					if (vo.hyd_add > 0) {
						tip+="\n好友度增加：" + vo.hyd_add;
					}
					BroadcastSelf.logger(tip);
				} else {
					tip="成功接受好友" + HtmlUtil.font("[" + vo.from_friend + "]", "#00ff00") + "的祝福：";
					if (vo.exp_add > 0) {
						tip+="\n经验增加：" + vo.exp_add;
					}
					if (vo.hyd_add > 0) {
						tip+="\n好友度增加：" + vo.hyd_add;
					}
					BroadcastSelf.logger(tip);
					MessageIconManager.getInstance().showFriendLuckIcon({from_friend: vo.from_friend, congratulation: vo.congratulation});
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		//关闭推荐好友的界面
		public function closeRecommendView():void {
			RecommendFriendView.getInstance().closeWinHandler();
		}

		public function goodLuckHandler(friendName:String, friendId:int, level:int):void {
			var luckPanel:FriendsForluckPanel=new FriendsForluckPanel();
			luckPanel.open();
			luckPanel.setFriendInfo(friendName, friendId, level);
			WindowManager.getInstance().centerWindow(luckPanel);
		}

		////////////////////////////////////////////好友群组//////////////////////////////////////////////////
		/**
		 * 等级群组初始化
		 */
		private function initGroup(data:Object):void {
			var vo:m_chat_auth_toc=data as m_chat_auth_toc;
			var channels:Array=vo.channel_list;
			for each (var channel:p_channel_info in channels) {
				if (channel.channel_type >= GroupType.FAMILY_GROUP) {
					createGroup(channel);
				}
			}
		}

		/**
		 *  初始化 等级群组列表的详细成员信息
		 */
		private function initGroupMembers(data:Object):void {
			var vo:m_chat_get_roles_toc=data as m_chat_get_roles_toc;
			if (vo.succ) {
				GroupManager.getInstance().initGroupMembers(vo.channel_sign, vo.roles);
			} else {
				GroupManager.getInstance().setGroupInit(vo.channel_sign, false);
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 等级群成员退出
		 */
		private function groupMemberExit(data:Object):void {
			var vo:m_chat_quick_toc=data as m_chat_quick_toc;
			GroupManager.getInstance().deleteMember(vo.channel_sign, vo.role_id);
		}

		/**
		 * 设置等级群成员上下状态
		 */
		private function groupMemberOffOnline(data:Object):void {
			var vo:m_chat_status_change_toc=data as m_chat_status_change_toc;
			var online:Boolean=vo.status == 2 ? true : false;
			GroupManager.getInstance().setOnOffLine(vo.channel_sign, vo.role_id, online);
		}

		/**
		 *  等级群成员加入
		 */
		private function groupMemberJoin(data:Object):void {
			var vo:m_chat_new_join_toc=data as m_chat_new_join_toc;
			GroupManager.getInstance().addGroupMember(vo.channel_sign, vo.role_info);
		}

		/**
		 *  加入新的群聊天频道
		 */
		private function joinGroupChannel(data:Object):void {
			var vo:m_chat_join_channel_toc=data as m_chat_join_channel_toc;
			if (GroupManager.getInstance().isexist(vo.channel_info.channel_sign))
				return;
			if (vo.channel_info.channel_type >= GroupType.FAMILY_GROUP) {
				createGroup(vo.channel_info);
			}
		}

		/**
		 * 退出群聊天频道
		 */
		private function exitGroupChannel(data:Object):void {
			var vo:m_chat_leave_channel_toc=data as m_chat_leave_channel_toc;
			if (vo.channel_type >= GroupType.FAMILY_GROUP) {
				GroupManager.getInstance().removeGroupNode(vo.channel_sign);
			}
		}

		/**
		 * 群消息
		 */
		private function groupMessage(data:Object):void {
			try {
				var vo:m_chat_in_channel_toc=data as m_chat_in_channel_toc;
				var type:int=GroupManager.getInstance().getTypeByGroupId(vo.channel_sign);
				var groupSetting:GroupSettingVO=GroupManager.getGroupSetting(vo.channel_sign, type);
				if (groupSetting.acptTipMsg) {
					if (!ChatWindowManager.getInstance().isPopUp(vo.channel_sign)) {
						var groupVO:GroupVO=GroupManager.getInstance().getGroupVOById(vo.channel_sign);
						MessageBox.getInstance().addMessage(groupVO, MessageBox.GROUP);
						GroupManager.getInstance().setFlick(vo.channel_sign, true);
					}
				}
				if (groupSetting && groupSetting.stopMsg)
					return;
				var nameHTML:String=vo.role_info.rolename;
				if (vo.role_info.roleid != GlobalObjectManager.getInstance().user.attr.role_id) {
					nameHTML="<a href='event:" + vo.role_info.roleid + "+" + vo.role_info.rolename + "'>" + nameHTML + "</a>"
				}
				var titles:String=getRoleTitles(vo.role_info, vo.channel_sign);
				var msg:String=titles + "<font color='#00ff00'>[" + nameHTML + "]</font>   " + DateFormatUtil.formatHours(vo.tstamp) + "\n" + vo.msg;
				ChatWindowManager.getInstance().addMessage(vo.channel_sign, msg);
			} catch (e:Error) {
			}
		}

		private var me:p_team_role;

		private function updateTeamGroup():void {
			var id:String=GroupManager.getInstance().getGroupIdByType(GroupType.TEAM_GROUP);
			var members:Array=TeamModule.getInstance().members;
			if (me == null) {
				me=new p_team_role();
				me.is_offline=false;
				me.role_name=GlobalObjectManager.getInstance().user.attr.role_name;
				me.role_id=GlobalObjectManager.getInstance().user.attr.role_id;
				me.skin=GlobalObjectManager.getInstance().user.attr.skin;
			}
			members.unshift(me);
			GroupManager.getInstance().updateGroupChildren(id, members);
		}

		private function createGroup(channel:p_channel_info):void {
			if (!GroupManager.getInstance().hasGroup(channel.channel_sign)) {
				var groupVO:GroupVO=new GroupVO();
				groupVO.id=channel.channel_sign;
				groupVO.name=channel.channel_name;
				groupVO.online_num=channel.online_num;
				groupVO.total_num=channel.total_num;
				groupVO.type=channel.channel_type;
				GroupManager.getInstance().createGroupNode(groupVO);
			}
		}
	}
}