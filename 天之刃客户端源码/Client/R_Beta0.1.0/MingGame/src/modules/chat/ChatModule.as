package modules.chat {
	import com.common.GlobalObjectManager;
	import com.common.WordFilter;
	import com.components.alert.Alert;
	import com.components.alert.Prompt;
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.loaders.ResourcePool;
	import com.loaders.SourceLoader;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.HtmlUtil;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.bigExpresion.BigExpresionModule;
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.KeyWord;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.chat.views.ChatView;
	import modules.chat.views.HornInput;
	import modules.flowers.FlowersTypes;
	import modules.friend.FriendsConstants;
	import modules.help.HelpManager;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.ChatItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.roleStateG.RoleStateDateManager;
	import modules.system.SystemConfig;
	
	import proto.chat.m_chat_add_black_toc;
	import proto.chat.m_chat_auth_toc;
	import proto.chat.m_chat_get_goods_toc;
	import proto.chat.m_chat_get_goods_tos;
	import proto.chat.m_chat_get_roles_toc;
	import proto.chat.m_chat_in_channel_toc;
	import proto.chat.m_chat_in_channel_tos;
	import proto.chat.m_chat_in_pairs_toc;
	import proto.chat.m_chat_in_pairs_tos;
	import proto.chat.m_chat_join_channel_toc;
	import proto.chat.m_chat_leave_channel_toc;
	import proto.chat.m_chat_new_join_toc;
	import proto.chat.m_chat_quick_toc;
	import proto.chat.m_chat_remove_black_toc;
	import proto.chat.m_chat_status_change_toc;
	import proto.chat.m_chat_warofking_toc;
	import proto.common.p_channel_info;
	import proto.common.p_chat_role;
	import proto.common.p_chat_title;
	import proto.common.p_role;
	import proto.common.p_title;
	import proto.line.m_broadcast_laba_toc;
	import proto.line.m_broadcast_laba_tos;
	import proto.line.m_bubble_msg_toc;
	import proto.line.m_goods_show_goods_tos;
	import proto.line.m_role2_online_broadcast_toc;

	/**
	 * 聊天模块(负责接收和处理聊天模块的相关指令)
	 */
	public class ChatModule extends BaseModule {

		public var chat:ChatView;
		private var chatSize:int = 1;
		private var hornInput:HornInput;

		/**
		 * 聊天重连次数
		 */
		private var reconnectTimes:int=0;
		/**
		 * 最多的重连次数
		 */
		private var maxReconnectTimes:int=5;

		public function ChatModule() {
			super();
			if (instance != null) {
				throw new Error("ChatModel只能存在一个实例。");
			}
		}

		private static var instance:ChatModule;

		public static function getInstance():ChatModule {
			if (instance == null) {
				instance=new ChatModule();
			}
			return instance;
		}
		
		/**
		 * 静悄悄的加载资源 
		 * 
		 */		
		public function silentLoadFaceResouce():void {
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSilentLoadFaceComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onSilentLoadFaceError);
			loader.load(new URLRequest(GameConfig.FACES_URL));
		}
		
		private function onSilentLoadFaceComplete(e:Event):void {
			var loader:Loader = (e.target.loader as Loader);
			loader.removeEventListener(Event.COMPLETE, onSilentLoadFaceComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onSilentLoadFaceError);
			ResourcePool.add(GameConfig.FACES_URL, loader.contentLoaderInfo.applicationDomain);
			loader = null;
		}
		
		private function onSilentLoadFaceError(e:IOErrorEvent):void {
			var loader:Loader = (e.target.loader as Loader);
			loader.removeEventListener(Event.COMPLETE, onSilentLoadFaceComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onSilentLoadFaceError);
			loader = null;
		}
		
		/**
		 * 加载聊天表情资源 ，会有一个进度条
		 * 
		 */		
		public function loadFaceResouce(callBackFunc:Function=null):void {
			if (!ResourcePool.hasResource(GameConfig.FACES_URL)) {
				var source:SourceLoader = new SourceLoader;
				source.loadSource(GameConfig.FACES_URL, "正在载入聊天表情", callBackFunc);
			}
		}
		
		override protected function initListeners():void {
			//模块信息
			addMessageListener(ModuleCommand.SEND_FRIEND_PRIVATE, sendFriendPrivate);
			addMessageListener(ModuleCommand.CHAT_APPEND_MSG, chatAppendMsg);
			addMessageListener(ModuleCommand.PRI_CHAT, priChatHandler); //priChatHandler(message.data as String);
			addMessageListener(ModuleCommand.HORN_USE_GOODS, openHornChat); //message.data as GeneralVO
			//服务端信息
			addSocketListener(SocketCommand.CHAT_AUTH, onChatAuth);
			addSocketListener(SocketCommand.CHAT_IN_CHANNEL, onChatInChannel);
			addSocketListener(SocketCommand.CHAT_IN_PAIRS, onChatInPairs);
			addSocketListener(SocketCommand.CHAT_ADD_BLACK, onAddBlack); // 暂时没有用到
			addSocketListener(SocketCommand.CHAT_REMOVE_BLACK, onRemoveBlack); // 暂时没有用到 
			addSocketListener(SocketCommand.BROADCAST_LABA, onHornChat);
			addSocketListener(SocketCommand.CHAT_JOIN_CHANNEL, onChatJoinChannel);
			addSocketListener(SocketCommand.CHAT_LEAVE_CHANNEL, onChatLeaveChannel);
			addSocketListener(SocketCommand.CHAT_GET_ROLES, onChatGetRoles);
			addSocketListener(SocketCommand.CHAT_QUICK, onChatQuick);
			addSocketListener(SocketCommand.CHAT_STATUS_CHANGE, onChatStatusChange);
			addSocketListener(SocketCommand.CHAT_NEW_JOIN, onChatNewJoin);
			addSocketListener(SocketCommand.CHAT_WAROFKING, warOfKingShow);
			addSocketListener(SocketCommand.CHAT_GET_GOODS, setGoodsInfo);
			addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);
			//国王上线提示
			addSocketListener(SocketCommand.ROLE2_ONLINE_BROADCAST, onOnlineBroadcast);
		}
		
		//国王上线提示
		private function onOnlineBroadcast(data:m_role2_online_broadcast_toc):void
		{
			//type=1为国王上线
			if(data.role_type == 1)
			{
				var str:String="<p align='center'><font size='20' color='#ff7e00'>-★----★----★----★----★-";
				if(data.faction_id == 1){
					str+="\n云州王<font color='#ffff00'>[" + data.role_name + "]</font>驾到" + "\n-★----★----★----★----★-</font></p>";
				}else if(data.faction_id == 2){
					str+="\n沧州王<font color='#ffff00'>[" + data.role_name + "]</font>驾到" + "\n-★----★----★----★----★-</font></p>";
				}else if(data.faction_id == 3){
					str+="\n幽州王<font color='#ffff00'>[" + data.role_name + "]</font>驾到" + "\n-★----★----★----★----★-</font></p>";
				}else{
					str+="\n国王<font color='#ffff00'>[" + data.role_name + "]</font>驾到" + "\n-★----★----★----★----★-</font></p>";
				}
				this.sendChatMsg(str, null, ChatType.COUNTRY_CHANNEL);
			}
		}
		
		private function sendOnLineMsg(msg:String, role:*=null, channel:String=null):void
		{
			var vo:Object={msg: msg, role: role, channel: channel};
			if (chat) {
				chat.addOnlineMsg("<font color='#ff0000'>" + vo.msg + "</font>",vo.role);
			}
		}

		private function onStageResize(value:Object):void {
			if (chat) {
				chatResize(chatSize);
				BroadcastModule.getInstance().changeLabapos(chatSize);
			}
		}

		/**
		 * 初始化聊天面版
		 *
		 */
		private function initChatPanel():void {
			if (chat == null) {
				chat=new ChatView();
				chat.y=GlobalObjectManager.GAME_HEIGHT - 250; 
				chat.sendHandler=send;
				chat.priChatNameHandler=priChatHandler;
				LayerManager.uiLayer.addChild(chat);
			}
		}

		/**
		 * 发送私聊信息 
		 * @param vo
		 * 
		 */		
		private function sendFriendPrivate(vo:m_chat_in_pairs_tos):void {
			sendSocketMessage(vo);
		}

		private function chatAppendMsg(vo:Object):void //{msg:msg, role:role, channel:channel}
		{
			if (chat) {
				chat.appendMessage("<font color='#ff0000'>" + vo.msg + "</font>", vo.role, vo.channel);
			}
		}

		private function openHornChat(vo:GeneralVO):void {
			if (!vo)
				return;
			if (!hornInput) {
				hornInput=new HornInput();
				hornInput.x=(GlobalObjectManager.GAME_WIDTH - hornInput.width) * 0.5;
				hornInput.y=(GlobalObjectManager.GAME_HEIGHT - hornInput.height) * 0.5;
			}
			hornInput.goodsId=vo.oid;
			WindowManager.getInstance().openDialog(hornInput);
		}

		private function onChatAuth(vo:m_chat_auth_toc):void {
			this.initChatPanel();
			dispatch(ModuleCommand.FRIENDS_GROUP_INIT, vo);
			openChat(vo);
		}

		private function onChatInChannel(vo:m_chat_in_channel_toc):void {
			if(!vo.succ )
			{
				BroadcastSelf.logger("<font color='#EE0000'>"+ vo.reason +"</font>");
				return;
			}	

			var _msg:String; 
			var sex:String='';
			var type:String=ChatType.getType(vo.channel_sign);
			vo.role_info.sex == 1 ? sex="<font color='#00ccff'><b>♂</b></font>" : sex="<font color='#ff37e0'><b>♀</b></font>"
			var nameHtml:String="<font color ='#ffff00'>[" + vo.role_info.rolename + "] </font>";
			if (vo.role_info.roleid != GlobalObjectManager.getInstance().getRoleID()) {
				nameHtml="<a href = 'event:somebody'>" + nameHtml + "</a>";
			} else {
				chat.scrollEnd();
			}
			var titles:String=getTitles(vo.role_info.titles, type);

			switch (type) {
				case ChatType.WORLD_CHANNEL:
					var countryStr:String=ChatType.getCountryStr(vo.role_info.factionid);
					_msg=countryStr + sex + titles + nameHtml + vo.msg;
					if (vo.role_info.roleid == GlobalObjectManager.getInstance().user.base.role_id) {

//						BroadcastSelf.logger("<font color='#ffffff'>" + ChatActionType.SUCCESS_WORLD_CHAT + "</font>");
						if (!SystemConfig.worldChat) {
							ChatType.shieldChannel(type);
							return;
						}
					}
					break;
				case ChatType.FAMILY_CHANNEL:
					_msg="<font color='#76ff76'>【宗】</font>" + sex + titles + nameHtml + "<font color='#76ff76'>" + vo.msg + "</font>";
					if (!SystemConfig.familyChat) {
						if (vo.role_info.roleid == GlobalObjectManager.getInstance().user.base.role_id) {

							ChatType.shieldChannel(type);
						}
						return;
					}
					break;
				case ChatType.COUNTRY_CHANNEL:
					_msg="<font color='#ff7e56'>【国】</font>" + sex + titles + nameHtml + vo.msg;
					if (!SystemConfig.nationChat) {
						if (vo.role_info.roleid == GlobalObjectManager.getInstance().user.base.role_id) {

							ChatType.shieldChannel(type);
						}
						return;
					}
					break;
				case ChatType.TEAM_CHANNEL:
					_msg="<font color='#58b6ff'>【队】</font>" + sex + titles + nameHtml + "<font color='#58b6ff'>" + vo.msg + "</font>";
					if (!SystemConfig.teamChat) {
						if (vo.role_info.roleid == GlobalObjectManager.getInstance().user.base.role_id) {

							ChatType.shieldChannel(type);
						}
						return;
					}
					break;
			}
			if (type == ChatType.GROUP_CHANNEL || type == ChatType.FAMILY_CHANNEL || type == ChatType.TEAM_CHANNEL) {
				dispatch(ModuleCommand.GROUP_MESSAGE, vo);
			}
			//先去帮助那查询是否有符合的信息,如果发的消息是同一个人，则处理,如果是群聊就不搜索
			if(vo.role_info.roleid == GlobalObjectManager.getInstance().user.base.role_id && type != ChatType.GROUP_CHANNEL){
				_msg = HelpManager.getInstance().searchHasKeyWord(_msg);
			}
			chat.appendMessage(_msg, vo.role_info, type);
		}

		public function sendChatMsg(msg:String, role:*=null, channel:String=null):void {
			var vo:Object={msg: msg, role: role, channel: channel};
			chatAppendMsg(vo);
		}

		//////私聊
		private function onChatInPairs(vo:m_chat_in_pairs_toc):void {
			if (vo.show_type == FriendsConstants.FRIEND_PRIVATE) {
				dispatch(ModuleCommand.SEND_FRIEND_PRIVATE_RETURN, vo);
			} else {
				chatHandler(vo);
			}
		}

		private function chatHandler(vo:m_chat_in_pairs_toc):void {
			if (!vo.succ) {
				if (vo.msg == "") {
					chat.setPreChatChannel();
					chat.appendMessage("<font color='#ff0000'>提示：" + vo.reason + "</font>", null, ChatType.PRIVATE_CHANNEL);
					return;
				}
				return;
			}

			var sender:p_chat_role=vo.from_role_info;
			var receiver:p_chat_role=vo.to_role_info;
			var currentUserId:int=GlobalObjectManager.getInstance().user.base.role_id;

			//第一次模拟发送私人聊天信息，确认私聊对象是否合法
			if (vo.msg == "") {
				if (sender.roleid == currentUserId)
					chat.addPriMember(vo.to_role_info);
				return;
			}

			var msg:String;
			if (sender.roleid == currentUserId) {
				if (vo.msg == FlowersTypes.REPYTYPE3) {
					msg="<font color='#ff4a79'><font color='#ff679d'>【私】</font>" + "你对<a href = 'event:somebody'><font color = '#ffff00'>[" + receiver.rolename + "]</font></a>" + "嘟起小嘴儿，狠狠地啵了一个，说: 谢谢你的鲜花哦！&29" + "</font>";
				} else {
					msg="<font color='#ff4a79'><font color='#ff679d'>【私】</font>" + "你对<a href = 'event:somebody'><font color = '#ffff00'>[" + receiver.rolename + "]</font></a>说: " + vo.msg + "</font>";
				}
				if (!SystemConfig.privateChat) {

					ChatModule.getInstance().sendChatMsg("你已屏蔽私聊频道。", null, ChatType.PRIVATE_CHANNEL);
					return;
				}
				chat.appendMessage(msg, receiver, ChatType.PRIVATE_CHANNEL);
			}
			if (receiver.roleid == currentUserId) {
				if (vo.msg == FlowersTypes.REPYTYPE3) {
					msg="<font color='#ff4a79'><font color='#ff679d'>【私】</font>" + "<a href = 'event:somebody'>" + "<font color = '#ffff00'>[" + sender.rolename + "]</font></a>" + "嘟起小嘴儿，狠狠地啵了你一个，说: 谢谢你的鲜花哦！&29" + "</font>";
				} else {

					msg="<font color='#ffffff'><font color='#ff679d'>【私】</font>" + "<a href = 'event:somebody'><font color = '#ffff00'>[" + sender.rolename + "]" + "</font></a><font color='#ff4a79'>对你说： " + vo.msg + "</font></font>";

				}
				if (!SystemConfig.privateChat) {
					return;
				}
				chat.appendMessage(msg, sender, ChatType.PRIVATE_CHANNEL);
			}
		}
		
		// 黑名单 部分
		private function onAddBlack(vo:m_chat_add_black_toc):void {
			if (!vo.succ) {
				if (vo.reason != "") {
					Alert.show(vo.reason);
					return;
				}
				return;
			}

			var black:p_chat_role=vo.role_info;
			ChatType.addBlack(black);

			var msg:String="<font color='#ffffff'>【系】玩家[" + black.rolename + "]已被屏蔽</font>";
			chat.appendMessage(msg, null, ChatType.WORLD_CHANNEL);
		}

		private function onRemoveBlack(vo:m_chat_remove_black_toc):void {
			if (!vo.succ) {
				if (vo.reason != "") {
					Alert.show(vo.reason);
					return;
				}
				return;
			}

			var black:p_chat_role=vo.role_info;
			ChatType.removeBlack(black.roleid);

			var msg:String="<font color='#ffffff'【系】玩家[" + black.rolename + "]已被解除屏蔽</font>";
			chat.appendMessage(msg, null, ChatType.WORLD_CHANNEL);
		}

		// 喇叭部分
		private function onHornChat(vo:m_broadcast_laba_toc):void {
			if (vo.succ == false) {
				Alert.show(vo.reason, "温馨提示");
				ChatType.useHornGood=false;
				return;
			}
			if (vo.return_self){
				if (!ChatType.isUseHornGood()){
					BroadcastSelf.logger("<font color='#ffffff'>成功使用喇叭，花费10两银子。</font>");
				} else {
					BroadcastSelf.logger("<font color='#ffffff'>成功使用喇叭，信息发送成功。</font>");
					ChatType.useHornGood=false;
				}
			}
		}

		// 加入频道
		private function onChatJoinChannel(vo:m_chat_join_channel_toc):void {
			dispatch(ModuleCommand.JOIN_GROUP_CHANNEL, vo);
			join(vo);
			return;
		}

		private function join(vo:m_chat_join_channel_toc):void {
			if (ChatType.addChannel(vo.channel_info)) {
				var msg:String="";
				//1世界/2国家/3门派/4组队/5好友群
				if (vo.channel_info.channel_type >= 1 && vo.channel_info.channel_type <= 4) {
					msg="<font color='#ffffff'>您已经加入<font color='#ff0000'>" + vo.channel_info.channel_name + "</font>频道！";

					if (vo.channel_info.channel_type == 3) {
						msg+="请按O键，查看门派详情。";
					}
				} else {
					msg="<font color='#ffffff'>您已经加入<font color='#ff0000'>" + vo.channel_info.channel_name + "</font>群组！" + "请按R键，查看这个群组。</font>";

				}
				ChatModule.getInstance().sendChatMsg(msg);
			}
		}

		private function onChatLeaveChannel(vo:m_chat_leave_channel_toc):void {
			dispatch(ModuleCommand.EXIT_GROUP_CHANNEL, vo);
			leave(vo);
			return;
		}

		private function leave(vo:m_chat_leave_channel_toc):void {
			var data:p_channel_info=ChatType.removeChannel(vo.channel_type, vo.channel_sign);

			if (data != null) {
				ChatModule.getInstance().sendChatMsg("<font color='#ffffff'>您已经退出<font color='#ff0000'>" + data.channel_name + "</font>频道！</font>");
			}
		}

		private function onChatGetRoles(vo:m_chat_get_roles_toc):void {
			dispatch(ModuleCommand.INIT_GROUP_MEMBERS, vo);
		}

		private function onChatQuick(vo:m_chat_quick_toc):void {
			dispatch(ModuleCommand.GROUP_MEMBER_EXIT, vo);
		}

		private function onChatStatusChange(vo:m_chat_status_change_toc):void {
			dispatch(ModuleCommand.GROUP_MEMBER_ONOFFLINE, vo);
		}

		private function onChatNewJoin(vo:m_chat_new_join_toc):void {
			dispatch(ModuleCommand.GROUP_MEMBER_JOIN, vo);
		}

		private function openChat(vo:m_chat_auth_toc):void {
			GlobalObjectManager.getInstance().isChatReconnecting=false;
			if (vo.succ == true) {
				GlobalObjectManager.getInstance().isChatSocketClose=false;
			}
			ChatType.channels=vo;
			if (GameParameters.getInstance().debug) {
				chat.appendMessage("<font color='#ffffff'>开发服版本确认字符:111343</font>", null, null);
			}

			chat.appendMessage("<font color='#ffffff'>服务器登录成功！</font>", null, null);
			chat.appendMessage("<font color='#ffffff'>" + ChatActionType.LOGIN_CHAT_WORD + "</font>", null, null);
		}

		private function send(msg:String, sendChannel:String, filterFlag:Boolean=true):void {
			switch (sendChannel) {
				case ChatType.COUNTRY_CHANNEL:
				case ChatType.FAMILY_CHANNEL:
				case ChatType.WORLD_CHANNEL:
				case ChatType.TEAM_CHANNEL:
					commonSend(msg, sendChannel, filterFlag);
					break;
				case ChatType.PRIVATE_CHANNEL:
					privateSend(msg, filterFlag);
					break;
				case ChatType.BUBBLE_CHANNEL:
					bubbleSend(msg, filterFlag);
					break;
				case ChatType.HORN_CHANNEL:
					hornSend(msg);
					break;
			}
		}


		//聊天频道炫耀宠物用  add by liuwei  2011-3-10
		public function showPet(str:String):void {
			if (!chat.timeCheck())
				return;
			chat.sendHandler(str, chat.currentChannel, false);
		}

		public function showGoods(goodsId:int):void {
			if (!chat.timeCheck())
				return;
			if (chat.currentChannel == ChatType.PRIVATE_CHANNEL && chat.lastPriMemver == null) {
				return;
			}
			var vo:m_goods_show_goods_tos=new m_goods_show_goods_tos();
			var sign:String=chat.currentChannel;
			if (sign == ChatType.PRIVATE_CHANNEL) {
				vo.show_type=1; //0频道 1密聊 2对话;	
				vo.to_role_name=chat.lastPriMemver.rolename;
			} else if (sign == ChatType.BUBBLE_CHANNEL) {
				vo.channel_sign=sign;
			} else {
				if (sign == "" || sign == null) {
					sign=ChatType.WORLD_CHANNEL;
				}
				var channel:p_channel_info=ChatType.getChannel(sign);
				if (channel == null) {
					sendChatMsg(HtmlUtil.font("还没有加入该频道", "#ff0000"), null, chat.currentChannel);
					return;
				}
				vo.channel_sign=channel.channel_sign;
			}
			vo.goods_id=goodsId;
			sendSocketMessage(vo);
		}


		public function getGoodsInfo(goodsId:int):void {
			var vo:m_chat_get_goods_tos=new m_chat_get_goods_tos();
			vo.goods_id=goodsId;
			sendSocketMessage(vo);
		}

		/**
		 * 获取详细信息(返回)d
		 */
		private function setGoodsInfo(data:Object):void {
			var vo:m_chat_get_goods_toc=data as m_chat_get_goods_toc;
			if (vo.succ) {
				var info:BaseItemVO=ItemConstant.wrapperItemVO(vo.goods_info);
				ChatItemToolTip.show(info);
			} else {
				ChatItemToolTip.remove(vo.goods_id);
				Tips.getInstance().addTipsMsg("该道具不存在：已经被使用或者出售！");
			}
		}

		//屏蔽响应函数，bool为true表示屏蔽，为false表示解除屏蔽
		private function shield(bool:Boolean, type:String):void {
			//暂时屏蔽
			return;
		}

		//用一次代码模拟私聊来确定对方是否合法
		public function priChatHandler(roleName:String):void {
			if (!_checkUNConnected())
				return;

			if (!roleName)
				return;
			if (roleName == GlobalObjectManager.getInstance().user.base.role_name) {
				Prompt.show("不能跟自己聊天！", "提示", null, null, "确定", "", null, false);
				return;
			}
			var temp:m_chat_in_pairs_tos=new m_chat_in_pairs_tos();
			temp.msg="";
			temp.to_rolename=roleName;

			sendSocketMessage(temp);

		}

		public function priMesSend():void {
			if (!_checkUNConnected())
				return;

			chat.SendPrivate();
		}

		public function priChangeTo(value:int):void {
			chat.tabNav.selectedIndex=value;
		}

		/**
		 * 附近聊天
		 * @param _vo
		 *
		 */
		public function bubbleAppendMsg(_vo:m_bubble_msg_toc):void {
			
			var _sexStr:String=_vo.actor_sex == 1 ? "<font color='#00ccff'><b>♂</b></font>" : "<font color='#ff37e0'><b>♀</b></font>";
			var _msg:String = new String;
			if (_vo.actor_id != GlobalObjectManager.getInstance().getRoleID()) {
				_msg ='<font color="#ffff00">【近】</font> ' + _sexStr + "<a href = 'event:somebody'>" + ' <font color="#ffff00">[' + _vo.actor_name + ']</font> '  + "</a>" + _vo.msg; 
			} else {
				_msg = '<font color="#ffff00">【近】</font> ' + _sexStr + ' <font color="#ffff00">[' + _vo.actor_name + ']</font> ' + _vo.msg;
			}
			var vo:p_chat_role = new p_chat_role;
			vo.roleid = _vo.actor_id;
			vo.factionid = _vo.actor_faction;
			vo.sex = _vo.actor_sex;
			vo.rolename = _vo.actor_name;
			vo.head = _vo.actor_head;
			chat.appendMessage(_msg, null, ChatType.BUBBLE_CHANNEL);
		}

		//国家，门派，世界聊天
		private function commonSend(msg:String, type:String, filterFlag:Boolean=true):void {
			if (!_checkUNConnected())
				return;

			if (msg == 'SHOW_ME_THE_VERSION') {

				chat.appendMessage("SHOW_ME_THE_VERSION_VALUE", null, type);
				return;
			}

			var channel:p_channel_info=ChatType.getChannel(type);

			if (channel == null) {
				if (chat != null) {
					chat.appendMessage("<font color='#ff0000'>您还没有加入该频道，不能聊天！</font>", null, type);
				}

				return;
			}
			var mesg:String=msg;
			if (filterFlag) {
				msg=HtmlUtil.filterHtml(msg);
				mesg=KeyWord.instance().replace(msg, KeyWord.TALK_WORDS);
			}
			if (filterFlag && !WordFilter.isValid(mesg)) {
				selfAppendMessage(mesg, type);
				return;
			}
			
			var temp:m_chat_in_channel_tos=new m_chat_in_channel_tos();
			temp.channel_sign=channel.channel_sign;
			temp.msg=msg;

			sendSocketMessage(temp);
		}

		private function selfAppendMessage(mesg:String, type:String):void {
			var msg:String;
			var sex:String='';
			var roleInfo:p_role=GlobalObjectManager.getInstance().user;
			roleInfo.base.sex == 1 ? sex="<font color='#00ccff'><b>♂</b></font>" : sex="<font color='#ff37e0'><b>♀</b></font>"
			var nameHtml:String="<font color ='#ffff00'>[" + roleInfo.base.role_name + "] </font>";
			var titleArr:Array=RoleStateDateManager.myTitles;

			var i:int;
			var titles:String="";
			// 非常恶心的实现，暂时这样子。。。
			for (i=0; i < titleArr.length; i++) {
				var chatTitle:p_title=titleArr[i];
				var titleVo:Object=TitlePool.getInstance().getObject(chatTitle.name);

				if (titleVo) {
					chatTitle.id=titleVo.id;
				} else {
					chatTitle.id=int.MAX_VALUE - 100 + i;
				}
			}
			// 根据ID大小排序
			titleArr.sortOn("id");

			for (i=0; i < titleArr.length; i++) {
				var chat_title:p_title=titleArr[i]; //p_chat_title
				var color:String=chat_title.color;
				titleVo=TitlePool.getInstance().getObject(chat_title.name);
				if (titleVo) {
					if (titleVo.chatType == 1) {
						var mark:String=ChatType.getTitleMark(titleVo.mark);
						titles+="<font color='#" + titleVo.color + "'>" + mark + titleVo.name + mark + "</font>";
					}
				} else {
					if (chat_title.name != "无") {
						if (!color || color == "")
							color=ItemConstant.COLOR_VALUES[5];
						titles+="<font color='#" + color + "'>" + chat_title.name + "</font>";
					}
				}
			}

			switch (type) {
				case ChatType.WORLD_CHANNEL:
					var countryStr:String=ChatType.getCountryStr(roleInfo.base.faction_id);
					msg=countryStr + sex + titles + nameHtml + mesg;
					if (!SystemConfig.worldChat) {
						return;
					}
					break;
				case ChatType.FAMILY_CHANNEL:
					msg="<font color='#76ff76'>【宗】</font>" + sex + titles + nameHtml + "<font color='#76ff76'>" + mesg + "</font>";
					if (!SystemConfig.familyChat) {
						return;
					}
					break;
				case ChatType.COUNTRY_CHANNEL:
					msg="<font color='#ff7e56'>【国】</font>" + sex + titles + nameHtml + mesg;
					if (!SystemConfig.nationChat) {
						return;
					}
					break;
				case ChatType.TEAM_CHANNEL:
					msg="<font color='#58b6ff'>【队】</font>" + sex + titles + nameHtml + "<font color='#58b6ff'>" + mesg + "</font>";
					if (!SystemConfig.teamChat) {
						return;
					}
					break;
			}
			var chatrole:p_chat_role=new p_chat_role();
			chatrole.roleid=roleInfo.base.role_id;
			chatrole.rolename=roleInfo.base.role_name;
			chatrole.factionid=roleInfo.base.faction_id;
			chatrole.sex=roleInfo.base.sex;
			chat.appendMessage(msg, chatrole, type);
		}

		private function bubbleSend(msg:String, filter:Boolean=true):void {
			var mesg:String=msg;
			if (filter) {
				msg=HtmlUtil.filterHtml(msg);
				mesg=KeyWord.instance().replace(msg, KeyWord.TALK_WORDS);
			}
			if (filter && !WordFilter.isValid(mesg)) {
				selfAppendMessage(mesg, ChatType.BUBBLE_CHANNEL);
				return;
			}

			BigExpresionModule.getInstance().requestSendString(msg);
			return;
		}

		public function hornSend(msg:String, goodId:int=0):void {
			var type:int=0;
			var silver:int=GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind;
			if (goodId != 0) {
				type=goodId;
			} else if (silver < ChatType.horn_money) {
				Alert.show("银子不足10两，不能使用喇叭发言。", "提示", null, null, "确定", "", null, false);
				return;
			}

			var vo:m_broadcast_laba_tos=new m_broadcast_laba_tos();
			vo.content=msg;
			vo.laba_id=goodId;
			if (goodId != 0)
				ChatType.useHornGood=true;
			sendSocketMessage(vo);
		}


		//聊天界面私聊
		private function privateSend(msg:String, filterFlag:Boolean=true):void {
			var temp:m_chat_in_pairs_tos=new m_chat_in_pairs_tos();
			temp.msg=KeyWord.instance().replace(msg);

			var last:p_chat_role=chat.lastPriMemver;
			if (last == null) {
				trace(" ＝＝＝＝＝＝＝私聊对象为空！+++++++++++ ");
				return;
			}
			temp.to_rolename=last.rolename;
			sendSocketMessage(temp);
		}

		private function warOfKingShow(vo:m_chat_warofking_toc):void {
			var str:String="<p align='center'><font size='16' color='#ff7e00'>-★----★----★----★----★-";
			str+="\n<font color='#fe00e9'>" + vo.family_name + "</font>攻占王宫" + "\n掌门" + " <font color='#fe00e9'>[" + vo.role_name + "]</font>" + "\n荣登国王宝座" + "\n-★----★----★----★----★-</font></p>";
			this.sendChatMsg(str, null, ChatType.COUNTRY_CHANNEL);
		}

		public function chatResize(size:int=3):void // 1 max   2 normor  3 min 。1改為3
		{
			chatSize = size;
			switch (size) {
				case 0:
					chat.y=GlobalObjectManager.GAME_HEIGHT - 386;
					break;
				case 1:
					chat.y=GlobalObjectManager.GAME_HEIGHT - 250;
					break;
				case 2:
					chat.y=GlobalObjectManager.GAME_HEIGHT - 318;
					break;
				case 3:
					chat.y=GlobalObjectManager.GAME_HEIGHT - 386;
					break;
//				default:
//					break;
			}
		}

		

		private function _checkUNConnected():Boolean {

			if (GlobalObjectManager.getInstance().isChatReconnecting == true || GlobalObjectManager.getInstance().isChatSocketClose == true) {
				sendChatMsg(HtmlUtil.font("您与聊天服务器断开了链接，系统尝试重连中", "#ffff00"), null, chat.currentChannel);
				return false;
			}
			return true;
		}
		private var def_color:String="ff7e00"; //ItemConstant.COLOR_VALUES[5];

		public function getTitles(titleArr:Array, type:String=""):String {
			var i:int;
			var titles:String="";
			// 非常恶心的实现，暂时这样子。。。
			for (i=0; i < titleArr.length; i++) {
				var chatTitle:p_chat_title=titleArr[i];
				var titleVo:Object=TitlePool.getInstance().getObject(chatTitle.name);

				if (titleVo) {
					chatTitle.id=titleVo.id;
				} else {
					// 后台给的称号给了一个很大的ID
					chatTitle.id=9999999;
				}
			}
			// 根据ID大小排序
			titleArr.sortOn("id");
			for (i=0; i < titleArr.length; i++) {
				var chat_title:p_chat_title=titleArr[i];
				var color:String=chat_title.color;
				titleVo=TitlePool.getInstance().getObject(chat_title.name);
				if (titleVo) {
					if (titleVo.chatType == 1) {
						var mark:String=ChatType.getTitleMark(titleVo.mark);
						titles+="<font color='#" + titleVo.color + "'>" + mark + titleVo.chatName + mark + "</font>";
					}
				} else {
					if (type != ChatType.FAMILY_CHANNEL && (chat_title.name == "掌门" || chat_title.name == "长老" || chat_title.name == "内务使" || chat_title.name == "左护法" || chat_title.name == "右护法" )) {
						titles=titles;
					} else {
						if (!color || color == "")
							color=def_color;
						titles+="<font color='#" + color + "'>★" + chat_title.name + "★</font>";
					}
				}
			}
			return titles;
		}



	}
}