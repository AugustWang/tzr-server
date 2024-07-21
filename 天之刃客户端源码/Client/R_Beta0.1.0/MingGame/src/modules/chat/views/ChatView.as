package modules.chat.views {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.components.chat.ChatList;
	import com.components.chat.FacesChooser;
	import com.components.chat.MessageTextArea;
	import com.components.chat.events.ChatEvent;
	import com.components.menuItems.GameMenuItems;
	import com.components.menuItems.MenuItemConstant;
	import com.components.menuItems.TargetRoleInfo;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.containers.VBox;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.utils.StringUtil;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import modules.Activity.ActivityModule;
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.KeyWord;
	import modules.chat.ChatActionType;
	import modules.chat.ChatModule;
	import modules.chat.ChatType;
	import modules.family.FamilyModule;
	import modules.help.HelpManager;
	import modules.mypackage.views.ChatItemToolTip;
	import modules.skill.SkillConstant;
	import modules.skillTree.SkillTreeModule;
	import modules.system.Anti_addiction;
	import modules.system.SystemModule;
	import modules.vip.VipModule;
	
	import proto.common.p_chat_role;
	import proto.line.m_pet_info_tos;
	import proto.line.m_system_fcm_toc;

	/**
	 * 聊天视图(包括 系统消息 和 聊天消息)
	 */
	public class ChatView extends Sprite {

		//数据高宽数据
		private static var startY:Number=2;
		private static var btnWidth:Number=24;//36; //35;//
		public static var btnHeight:Number=17;
		private static var tabNavWidth:Number=270;
		private static var tabNavHeight:Number=150; //180;
		public static var sendToWidth:Number=15;
		public static var sendToHeight:Number=35; //18;
		private static var sendTxtWidth:Number=175; //150;
		private static var stepHeight:Number=68;

		public var sendHandler:Function;

		public var tabNav:TabNavigation; //消息导航
		private var list_world:ChatList;
		private var list_team:ChatList;
		private var list_family:ChatList;
		private var list_country:ChatList;
		private var list_bubble:ChatList;
		private var list_laba:ChatList;

		private var list_private:ChatList;
		private var _lastPriMember:p_chat_role;

		private var sendMsg_Panel:Sprite; //聊天频道，锁，发送等的总体面板

		private var sendTo:ChatChannel;
		private var facesChooser:FacesChooser;

		private var btn_send:Button;
		private var txt_sendMsg:MessageTextArea;

		private var pre_sendMsg:String="";
		private var echo_times:int=0;

		private var sendTo_Chooser:VBox;

		private var lastTime:Number=-3000;
		private var worldTime:Number=-60000; //-30000

		private var firstLaba:Boolean=true;
		private var firstWorld:Boolean=true;

		private var fieldItems:Array;
		private var targetRoleInfo:TargetRoleInfo;
		
		//新添
		private static var shengsuoY:int=tabNavHeight + stepHeight - btnHeight+3;	
		private var hideShowTabBar:UIComponent;
		private var toolBarContainer:Sprite;
		
		public function ChatView() {
			super();
			this.mouseEnabled=false;
			init();

		}

		public function appendMessage(msg:String, role:p_chat_role, channel:String=null):void {
			appendTxt(msg, role, channel);
		}

		//私聊填写角色名处理函数
		public function set priChatNameHandler(fun:Function):void {
			sendTo.priChatHandler=fun;
		}

		//私聊用户不在，　回到上一个频道
		public function setPreChatChannel():void {
			sendTo.setPreChannel();
		}

		public function addPriMember(vo:p_chat_role):void {

			this._lastPriMember=vo;
			sendTo.addPriMember(vo);
		}

		public function get lastPriMemver():p_chat_role {
			return this._lastPriMember;
		}

		private function appendTxt(msg:String, role:p_chat_role, channel:String):void {
			if (channel == null) {
				list_world.pushMessage(msg, role);
				return;
			}

			var lists:Array=getListByChannel(channel);

			for each (var list:ChatList in lists) {
				list.pushMessage(msg, role);
			}
		}

		private var pri_btn:ToggleButton; //私聊btn
		private var pri_bool:Boolean=false;
		private var team_btn:ToggleButton; //组队btn
		private var team_bool:Boolean=false;

		private function getListByChannel(channel:String):Array {
			var lists:Array=[];

			switch (channel) {
				case ChatType.WORLD_CHANNEL:
					lists.push(list_world);
					break;
				case ChatType.PRIVATE_CHANNEL:
					lists.push(list_world, list_country, list_private);


					if (tabNav.tabContainer.selectIndex != 6) { //私聊
						if (!timer.running)
							timer.start();
						pri_bool=true;
					}
					break;
				case ChatType.COUNTRY_CHANNEL:
					lists.push(list_world, list_country);
					break;
				case ChatType.FAMILY_CHANNEL:
					lists.push(list_world, list_family);
					break;
				case ChatType.TEAM_CHANNEL:
					lists.push(list_world, list_team);

					if (tabNav.tabContainer.selectIndex != 3) { //组队
						if (!timer.running)
							timer.start();
						team_bool=true;
					}
					break;
				case ChatType.BUBBLE_CHANNEL:
					lists.push(list_world, list_country, list_bubble);
					break;
				case ChatType.HORN_CHANNEL:
					lists.push(list_world, list_country, list_laba);
					break;
			}

			return lists;
		}

		private function onTimerHandler(evt:TimerEvent):void {
			if (pri_bool) {
				pri_btn.filters.length > 0 ? pri_btn.filters=null : pri_btn.filters=[glow];
			}
			if (team_bool) {
//				team_btn.filters.length > 0 ? team_btn.filters=null : team_btn.filters=[glow];
			}
		}

		/**
		 * 聊天界面初始化 
		 * 
		 */		
		private function init():void {
			tabNav=new TabNavigation();
			tabNav.tabBarPaddingLeft = 20;
			tabNav.tabBarSkin=Style.getChatTabBarSkin();
			tabNav.tabBar.hPadding = 1;
			tabNav.tabContainerSkin=null;
			tabNav.bgAlpha=0;
			list_world=getChatList();
			list_family=getChatList();
			list_country=getChatList();
			list_private=getChatList();
			list_team=getChatList();
			list_bubble=getChatList();
			list_laba=getChatList();

			tabNav.addItem("综", list_world, btnWidth, btnHeight);
			tabNav.addItem("国", list_country, btnWidth, btnHeight);
			tabNav.addItem("门", list_family, btnWidth, btnHeight);
			tabNav.addItem("队", list_team, btnWidth, btnHeight);
			tabNav.addItem("附", list_bubble, btnWidth, btnHeight);
			tabNav.addItem("喇", list_laba, btnWidth, btnHeight);
			tabNav.addItem("私", list_private, btnWidth, btnHeight);

			tabNav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, selectChange);
//			tabNav.direction=TabDirection.BOTTOM;
			tabNav.width=tabNavWidth;
			tabNav.height=tabNavHeight + stepHeight;
			tabNav.y=startY;
			tabNav.mouseEnabled=false;

			addChild(tabNav);

			// 聊天文字输入框
			txt_sendMsg=new MessageTextArea();
			txt_sendMsg.enterFunc=sendMessage;
			txt_sendMsg.width=sendTxtWidth-btnWidth;//输入框宽度缩小
			txt_sendMsg.height=sendToHeight;
			txt_sendMsg.y=0;
			txt_sendMsg.x=47; 
			txt_sendMsg.defaultText=ChatActionType.MSG_TXT_DEFUALT;

			sendMsg_Panel=new Sprite();
			sendMsg_Panel.y=tabNav.height + startY;
			// 聊天频道选择下拉列表
			sendTo=new ChatChannel();
			sendTo.messageTextArea=txt_sendMsg;
			sendTo.tabNavigation=tabNav;
			var bg:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"inputMsgBg");

			// 选择表情
			facesChooser=new FacesChooser();
			facesChooser.addEventListener(ChatEvent.SELECTED_FACE, onInsertFace);
			facesChooser.x=194; 
			facesChooser.y=-2;
			sendMsg_Panel.addChild(facesChooser);

			btn_send=getButtton("发送", 41, 220,-2); //222
			btn_send.height = 28;
			btn_send.width = 50;
			Style.setChatSendBtnStyle(btn_send);
			btn_send.addEventListener(MouseEvent.CLICK, sendMessage);


			addChild(sendMsg_Panel);
			sendMsg_Panel.addChild(bg);
			sendMsg_Panel.addChild(sendTo);
			sendMsg_Panel.addChild(txt_sendMsg);
			sendMsg_Panel.addChild(btn_send);
			
			txt_sendMsg.textField.addEventListener(KeyboardEvent.KEY_UP, onCheckMsgRecord);

			timer=new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			glow=new GlowFilter(0xffff00, 1, 4, 4, 2, 1, true);
			arr=tabNav.tabBar.buttonList;
			for each (var btn:ToggleButton in arr) {
				switch (btn.label) {
					case "队":
						team_btn=btn;
						team_btn.filters=null;
						break;
					case "私":
						pri_btn=btn;
						pri_btn.filters=null;
						break;
				}
			}
			
			hideShowTabBar = new UIComponent();
			hideShowTabBar.y = 4;
			hideShowTabBar.x = 2;
			hideShowTabBar.bgSkin = Style.getButtonSkin("leftHide_1skin","leftHide_2skin","leftHide_3skin","",GameConfig.T1_UI);
			hideShowTabBar.addEventListener(MouseEvent.CLICK,hideShowTabBarHandler);
			addChild(hideShowTabBar);
			
			toolBarContainer = new Sprite();
			toolBarContainer.x = 195;
			toolBarContainer.y = 2;
			addChild(toolBarContainer);
			
			var clearBtn:Button = ComponentUtil.createButton("",0,0,24,17);
			clearBtn.bgSkin = Style.getChatButtonSkin();
			clearBtn.icon = Style.getBitmap(GameConfig.T1_VIEWUI,"clear");
			clearBtn.iconLeft = -4;
			clearBtn.buttonMode=true;
			toolBarContainer.addChild(clearBtn);
			clearBtn.addEventListener(MouseEvent.CLICK,clearHandler);
			clearBtn.setToolTip("清空聊天信息");
			
			var pingbiBtn:Button = ComponentUtil.createButton("",0,0,24,17);
			pingbiBtn.bgSkin = Style.getChatButtonSkin();
			pingbiBtn.iconLeft = -4;
			pingbiBtn.icon = Style.getBitmap(GameConfig.T1_VIEWUI,"shieldChannel");
			pingbiBtn.buttonMode=true;
			toolBarContainer.addChild(pingbiBtn);
			pingbiBtn.addEventListener(MouseEvent.CLICK,onpingbi);
			pingbiBtn.setToolTip("屏蔽聊天频道");
					
			var shengsuoBtn:Button = ComponentUtil.createButton("",0,0,24,17);
			shengsuoBtn.bgSkin = Style.getChatButtonSkin();
			shengsuoBtn.icon = Style.getBitmap(GameConfig.T1_VIEWUI,"resizeIcon");
			shengsuoBtn.buttonMode=true;
			toolBarContainer.addChild(shengsuoBtn);
			shengsuoBtn.setToolTip("点击可伸缩聊天界面");
			shengsuoBtn.addEventListener(MouseEvent.CLICK,resize);
			LayoutUtil.layoutHorizontal(toolBarContainer,1);
			resizePos(chat_size);
		}

		
		private function hideShowTabBarHandler(event:MouseEvent):void{
			tabNav.tabBar.visible = !tabNav.tabBar.visible;
			toolBarContainer.visible = tabNav.tabBar.visible;
			if(tabNav.tabBar.visible){
				hideShowTabBar.scaleX = 1;
				hideShowTabBar.x = 2;
			}else{
				hideShowTabBar.scaleX = -1;
				hideShowTabBar.x = 17;
			}
		}
		
		private var timer:Timer;
		private var glow:GlowFilter;
		private var arr:Array; //存放当前导航条的按钮

		private function onCheckMsgRecord(evt:KeyboardEvent):void {
			if (evt.keyCode == Keyboard.LEFT && txt_sendMsg.text.length == 0) {
				if (tabNav.selectedIndex == 0) {
					return;
				}
				tabNav.selectedIndex=tabNav.selectedIndex - 1;
			}
			if (evt.keyCode == Keyboard.RIGHT && txt_sendMsg.text.length == 0) {
				if (tabNav.selectedIndex == 5) {
					if (sendTo.getRoleName() == "")
						return;
				}
				if (tabNav.selectedIndex == 6) {
					return;
				}
				tabNav.selectedIndex=tabNav.selectedIndex + 1;
			}
			if (evt.keyCode == Keyboard.UP) {
				if (txt_sendMsg.text == "" || txt_sendMsg.textField.selectedText == txt_sendMsg.text) {
					evt.preventDefault();
				}
				upMsgHandler();

			}
			if (evt.keyCode == Keyboard.DOWN) {
				downMsgHandler();
			}

			if (evt.keyCode != Keyboard.UP && evt.keyCode != Keyboard.DOWN) {
				checkIngRec=false;
			}
		}

		private var checkIngRec:Boolean;

		private function upMsgHandler():void {
			if (txt_sendMsg.text == "" || checkIngRec) //txt_sendMsg.textField.selectedText==txt_sendMsg.text)
			{
				ChatType.chat_record_index--;
				var obj:Object=ChatType.getRecord(ChatType.chat_record_index);
				if (obj) {
					txt_sendMsg.text=obj.msg;
					txt_sendMsg.textField.setSelection(0, txt_sendMsg.text.length);
					checkIngRec=true;
						//频道修改。。。 to do 


				} else { //：“【提示】没有上一条记录。”

					if (ChatType.showOnWorldChannel(sendTo.currentChannel)) {
						this.appendMessage("<font color='#FF0000'>【系】没有上一条记录。</font>", null, sendTo.currentChannel);

					} else {

						this.appendMessage("<font color='#FF0000'>【系】没有上一条记录。</font>", null, ChatType.WORLD_CHANNEL);
					}

					txt_sendMsg.textField.setSelection(0, txt_sendMsg.text.length);
//					checkIngRec = true;
				}

			}
		}

		private function downMsgHandler():void {
			if (txt_sendMsg.text == "" || checkIngRec) {
				ChatType.chat_record_index++;
				var obj:Object=ChatType.getRecord(ChatType.chat_record_index);
				if (obj) {
					txt_sendMsg.text=obj.msg;
					txt_sendMsg.textField.setSelection(0, txt_sendMsg.text.length);
					checkIngRec=true;
						//频道修改。。。 to do 


				} else { //：“【提示】没有上一条记录。”

					if (ChatType.showOnWorldChannel(sendTo.currentChannel)) {
						this.appendMessage("<font color='#FF0000'>【系】没有下一条记录。</font>", null, sendTo.currentChannel);

					} else {

						this.appendMessage("<font color='#FF0000'>【系】没有下一条记录。</font>", null, ChatType.WORLD_CHANNEL);
					}

					txt_sendMsg.textField.setSelection(0, txt_sendMsg.text.length);
				}

			}
		}


//		private function onHideShow(event:MouseEvent):void{
//			tabNav.contentVisible = !tabNav.contentVisible;
//			if(tabNav.contentVisible)
//			{
//				Button(event.currentTarget).label = "隐藏";
//				BroadcastModel.getInstance().showLabaView();
//			}
//			else
//			{
//				Button(event.currentTarget).label = "显示";
//				BroadcastModel.getInstance().hideLabaView();
//			}
//		}

		private function selectChange(evt:TabNavigationEvent):void {
			var btn:ToggleButton=arr[evt.index] as ToggleButton;
			if (btn.label == "私") {
				pri_btn.filters=null;
				pri_bool=false;
			} else if (btn.label == "队") {
				team_btn.filters=null;
				team_bool=false;
			}
			if (pri_bool == false && team_bool == false) {
				timer.stop();
			}

			sendTo.setChannel(evt.index);
		}

		private function onInsertFace(event:ChatEvent):void {
			txt_sendMsg.appendText(event.data.toString());
			txt_sendMsg.setFocus();
			//getFoucs();
		}

		private function getChatList():ChatList {
			var chatlist:ChatList=new ChatList();
			chatlist.chatScroll=true;
			chatlist.itemHandler=itemClickHandler;
			chatlist.width=tabNavWidth;
			chatlist.height=tabNavHeight + stepHeight - btnHeight; //tabNavHeight * 1.6 - 2* btnHeight + 2;//tabNavHeight - btnHeight;	
			chatlist.mouseEnabled=false;
			chatlist.scrollBarHeight=tabNavHeight + stepHeight - btnHeight;// 滚动条的高度
			return chatlist;
		}

		//data 为设置进去的数据
		public function itemClickHandler(evt:TextEvent, data:Object):void {
			var _args:Array=new Array();
			if (evt.text == "somebody") {
				popup(evt, data);
				return;
			} else if (evt.text == "goto_country_treasure") {
				//点击直接寻路到大明宝藏传送员
				gotoCountryTreasure();
				return;
			} else if(evt.text == "openRefining"){//打开天式炉
				Dispatch.dispatch(ModuleCommand.OPEN_STOVE_WINDOW);
			} else if (evt.text == "open_activity_benefit") {
				ActivityModule.getInstance().openActivityBenefit(); //打开领取福利
			} else if (evt.text == "openVip") {
				VipModule.getInstance().onOpenVipPannel();
			} else if (evt.text == "openShop") {
				Dispatch.dispatch(ModuleCommand.OPEN_SHOP_PANEL);
			} else if (evt.text.indexOf("=") != -1) {
				_args=evt.text.split("=");
				ChatItemToolTip.add(_args[0], _args[1], _args[2]);
			} else if (evt.text.indexOf("#") != -1) {
				_args=evt.text.split('#');
				var order:String=_args.shift();
				switch (order) {
					case Anti_addiction.OPEN_VIEW:
						_args=_args[0].split(',')
						var value:m_system_fcm_toc=new m_system_fcm_toc();
						value.total_time=int(_args[0]);
						value.remain_time=int(_args[1]);
						SystemModule.getInstance().openFCMWindow(value);
						break;
					case 'gotoNpc':
						var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
						PathUtil.findNpcAndOpen(_args[0].toString().replace('X', roleFaction));
						break;
					case "gotoSWFBNPC":
						var SwFbNPCId:int=int(_args[0]) + GlobalObjectManager.getInstance().user.base.faction_id * 1000000;
						PathUtil.findNpcAndOpen(SwFbNPCId);
						break;

				}
			} else if (evt.text.indexOf("pet_info:") != -1) {
				_args=evt.text.split('pet_info:');
				var pet_id:int=int(_args[1]);
				var vo:m_pet_info_tos=new m_pet_info_tos;
				vo.pet_id=pet_id;
				vo.role_id=GlobalObjectManager.getInstance().user.base.role_id;
				Connection.getInstance().sendMessage(vo);
			} else if (evt.text.indexOf("pet_grow") != -1) {
				SkillTreeModule.getInstance().openSkillTree(SkillConstant.CATEGORY_LABEL_PETGROW);
			} else if (evt.text == "goto_pet_npc") {
				//点击直接寻路到宠物驯养师
				gotoPetNpc();
				return;
			} else if (evt.text == "goto_herofb") {
				gotoHeroFb();
				return;
			}else if (evt.text == "openShouchongWin" || evt.text == "sclb") {
				ActivityModule.getInstance().openShouchongWin();
				return;
			}else if (evt.text.indexOf("view_family:") != -1) 
			{
				_args=evt.text.split('view_family:');
				var familyID:int = int(_args[1]);
				FamilyModule.getInstance().getFamilyInfoById(familyID);
			}else if (evt.text.indexOf("join_family:") != -1) 
			{
				_args=evt.text.split('join_family:');
				var family_ID:int = int(_args[1]);
				FamilyModule.getInstance().joinFamilyRequest(family_ID);
			}else if(evt.text == "checkout") {
				var contentText:TextField = evt.currentTarget as TextField;
				var content:String = contentText.text.split("\"")[1];
				HelpManager.getInstance().openSearchView(content);
			}
			
		/*case Anti_addiction.OPEN_VIEW:
		   args=args[0].split(',')
		   var value:m_system_fcm_toc = new m_system_fcm_toc();
		   value.total_time = int(args[0]);
		   value.remain_time = int(args[1]);
		 SystemModel.getInstance().openFCMWindow(value);*/
		}

		public function popup(evt:TextEvent, data:Object):void {
			if (!data || data == 0)
				return;
			if (data.roleid == GlobalObjectManager.getInstance().user.base.role_id)
				return;

			var type:Boolean=ChatType.isBlack(data.roleid);
			var role:p_chat_role=data as p_chat_role;

			if (!type) {
				if (fieldItems == null) {
					//ItemFactory.VIEW_DETAIL |  ItemFactory.SHIELD | 屏蔽跟查看去掉
					targetRoleInfo=new TargetRoleInfo();
					if (GlobalObjectManager.getInstance().user.attr.office_id == 4) {
						fieldItems=[MenuItemConstant.CHAT, MenuItemConstant.OPEN_FRIEND_CHAT, MenuItemConstant.REQUEST_GROUP, MenuItemConstant.APPLY_TEAM, MenuItemConstant.LETTER, MenuItemConstant.VIEW_DETAIL, MenuItemConstant.COPYNAME, MenuItemConstant.FRIEND, MenuItemConstant.ADD_BLACK, MenuItemConstant.FLOWER, MenuItemConstant.KINGBAN];
					} else {
						fieldItems=[MenuItemConstant.CHAT, MenuItemConstant.OPEN_FRIEND_CHAT, MenuItemConstant.REQUEST_GROUP, MenuItemConstant.APPLY_TEAM, MenuItemConstant.LETTER, MenuItemConstant.VIEW_DETAIL, MenuItemConstant.COPYNAME, MenuItemConstant.FRIEND, MenuItemConstant.ADD_BLACK, MenuItemConstant.FLOWER];
					}
				}
				targetRoleInfo.faction_id=role.factionid;
				targetRoleInfo.roleId=role.roleid;
				targetRoleInfo.roleName=role.rolename;
				targetRoleInfo.head=role.head;
				targetRoleInfo.sex=role.sex;
				GameMenuItems.getInstance().show(fieldItems, targetRoleInfo);
				return;
			}
		}

		/**
		 * 点击直接寻路到英雄副本传送员
		 */

		private function gotoHeroFb():void {
			var factionId:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var npcId:String="";
			if (factionId == 1) {
				npcId="11100133";
			} else if (factionId == 2) {
				npcId="12100133";
			} else if (factionId == 3) {
				npcId="13100133";
			} else {
				return;
			}
			PathUtil.findNpcAndOpen(npcId);
		}

		/**
		 * 点击直接寻路到大明宝藏传送员
		 * @return
		 *
		 */
		private function gotoCountryTreasure():void {
			var factionId:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var npcId:String="";
			if (factionId == 1) {
				npcId="11100129";
			} else if (factionId == 2) {
				npcId="12100129";
			} else if (factionId == 3) {
				npcId="13100129";
			} else {
				return;
			}
			PathUtil.findNpcAndOpen(npcId);
		}

		/**
		 * 点击直接寻路到宠物驯养师
		 * @return
		 *
		 */
		public function gotoPetNpc():void {
			var factionId:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			var npcId:String="";

			if (factionId == 1 && level < 10) {
				npcId="11000114";
			} else if (factionId == 2 && level < 10) {
				npcId="12000114";
			} else if (factionId == 3 && level < 10) {
				npcId="13000114";
			} else if (factionId == 1 && level >= 10) {
				npcId="11100132";
			} else if (factionId == 2 && level >= 10) {
				npcId="12100132";
			} else if (factionId == 3 && level >= 10) {
				npcId="13100132";
			} else {
				return;
			}
			PathUtil.findNpcAndOpen(npcId);
		}



		public function timeCheck():Boolean {
			var flag:Boolean=false;

			if (sendTo.currentChannel == ChatType.WORLD_CHANNEL) {
//				if (GlobalObjectManager.getInstance().user.attr.level < ChatType.WORLD_CHAT_LEVEL) {
//					this.appendMessage("<font color='#FF0000'>【系】综合频道发言需10级以上。</font>", null, sendTo.currentChannel);
//					return flag;
//				} else if (getTimer() - worldTime <= ChatType.WORLD_CHAT_TIMES) {
//					this.appendMessage("<font color='#FF0000'>【系】综合频道发言间隔需大于3秒。</font>", null, sendTo.currentChannel);
//					flag=false;
//
//				} 
				
				//世界聊天不需要银子
//				else if (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind < 200) {
//					this.appendMessage("<font color='#ff0000'>您的银子不足，世界聊天需要至少2两银子！</font>", null, sendTo.currentChannel);
//					flag=false;
//				} 
//				else {

					worldTime=getTimer();
					flag=true;
//				}

				return flag;

			} else {

				if (getTimer() - lastTime < 3000) {
					if (ChatType.showOnWorldChannel(sendTo.currentChannel)) {
						this.appendMessage("<font color='#FF0000'>【系】发言间隔需大于3秒。</font>", null, sendTo.currentChannel);

					} else {
						this.appendMessage("<font color='#FF0000'>【系】发言间隔需大于3秒。</font>", null, ChatType.WORLD_CHANNEL);
					}

					return flag;

				} else {

					lastTime=getTimer();
					flag=true;
					return flag;
				}
			}
		}

		private function getButtton(label:String, w:Number, xValue:int, yValue:int):Button {
			var btn:Button=new Button();
			btn.label=label;
			btn.width=w;
			btn.x=xValue;
			btn.y=yValue;
			return btn;
		}

		private function sendMessage(event:MouseEvent=null):void {
			var msg:String=KeyWord.instance().replace(txt_sendMsg.text, KeyWord.TALK_WORDS);
			var message:String=StringUtil.trim(msg);

			message=checkPrivateChat(message);
			if (message == "" || message == txt_sendMsg.defaultText)
				return;

			if (sendTo.currentChannel == ChatType.WORLD_CHANNEL) {
//				if (GlobalObjectManager.getInstance().user.attr.level < ChatType.WORLD_CHAT_LEVEL) {
//					this.appendMessage("<font color='#FF0000'>【系】综合频道发言需10级以上。</font>", null, sendTo.currentChannel);
//					return;
//				} 
				//世界聊天不需要银子（代码先保留着）
//				else if (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind < 200) {
//					this.appendMessage("<font color='#ff0000'>您的银子不足，世界聊天需要至少2两银子！</font>", null, sendTo.currentChannel);
//					return;
//				} 
				if (getTimer() - worldTime < ChatType.WORLD_CHAT_TIMES) {
					this.appendMessage("<font color='#FF0000'>【系】综合频道发言间隔需大于3秒。</font>", null, sendTo.currentChannel);
					return;
				}
				//世界聊天不需要银子（代码先保留着）
//				if (firstWorld) {
//					Alert.show("使用综合频道发言需要用2两银子!", "提示：", yesFunc, null);
//					firstWorld=false;
//					return;
//				}
			} else if (sendTo.currentChannel == ChatType.HORN_CHANNEL) {
				if (firstLaba) {
					Alert.show("使用喇叭频道发言需要用10两银子!", "提示：", yesFunc, null);
					firstLaba=false;

				} else {

//					this.appendMessage("<font color='#ffffff'>【提示】成功使用喇叭，花费10两银子。</font>", null, sendTo.currentChannel);
					yesFunc();
				}
//				if(stage)
//					stage.focus = stage;
				return;
			}

			if (getTimer() - lastTime < 3000) {
				if (ChatType.showOnWorldChannel(sendTo.currentChannel)) {
					this.appendMessage("<font color='#FF0000'>【系】发言间隔需大于3秒。</font>", null, sendTo.currentChannel);

				} else {

					this.appendMessage("<font color='#FF0000'>【系】发言间隔需大于3秒。</font>", null, ChatType.WORLD_CHANNEL);
				}

				return;
			}

			if (sendHandler != null) {
				if (pre_sendMsg == message) {
					echo_times++;
					if (echo_times >= 3) {
						if (ChatType.showOnWorldChannel(sendTo.currentChannel)) {
							this.appendMessage("<font color='#FF0000'>【系】请不要重复发言。</font>", null, sendTo.currentChannel);

						} else {

							this.appendMessage("<font color='#FF0000'>【系】请不要重复发言。</font>", null, ChatType.WORLD_CHANNEL);
						}

						return;
					}

				} else {
					pre_sendMsg=message;
					echo_times=0;
				}

				sendHandler.apply(null, [message, sendTo.currentChannel,false]);

				ChatType.addRecord(message, sendTo.currentChannel);
					//ChatType.addRecord(txt_sendMsg.text,sendTo.currentChannel);
			}
//			if(sendTo.currentChannel!=  ChatType.WORLD_CHANNEL)
//			{
//				lastTime = getTimer();
//			}else{

			lastTime=worldTime=getTimer(); //都是3秒了
//			}


			if (sendTo.currentChannel == ChatType.PRIVATE_CHANNEL) {
				sendTo.setChannel(6);
			} else {
				txt_sendMsg.text="";
			}
		}


		private function yesFunc():void {
			var msg:String=KeyWord.instance().replace(txt_sendMsg.text, KeyWord.TALK_WORDS);
			var message:String=StringUtil.trim(msg);
			if (message == "" || message == txt_sendMsg.defaultText) {
				//				stage.focus = stage;
			} else {
				if (sendHandler != null) {

					sendHandler.apply(null, [message, sendTo.currentChannel]);
				}
				lastTime=getTimer();

				ChatType.addRecord(message, sendTo.currentChannel);
			}
			txt_sendMsg.text="";
			txt_sendMsg.setFocus();
		}

		public var pre_private_msg:String;

		public function SendPrivate():void //先确认过角色存在 再把之前保存下来的内容发出去。
		{
			if (!pre_private_msg || pre_private_msg == "")
				return;
			if (sendHandler != null) {
				if (pre_sendMsg == pre_private_msg) {
					echo_times++;
					if (echo_times >= 3) {
						if (ChatType.showOnWorldChannel(sendTo.currentChannel)) {
							this.appendMessage("<font color='#FF0000'>【系】请不要重复发言。</font>", null, sendTo.currentChannel);
						} else {

							this.appendMessage("<font color='#FF0000'>【系】请不要重复发言。</font>", null, ChatType.WORLD_CHANNEL);
						}

						return;
					}

				} else {
					pre_sendMsg=pre_private_msg;
					echo_times=0;
				}
				sendHandler.apply(null, [pre_private_msg, sendTo.currentChannel]);
			}
			lastTime=getTimer();
			ChatType.addRecord(pre_private_msg, sendTo.currentChannel);
			if (sendTo.currentChannel == ChatType.PRIVATE_CHANNEL) {
				sendTo.setChannel(6);
				pre_private_msg="";
			} else {
				txt_sendMsg.text="";
			}
		}

		public function resetEchoTimes():void {
			if (echo_times != 0)
				echo_times=0;
		}

		private function checkPrivateChat(msg:String):String {
			pre_private_msg="";
			var str:String=msg;
			var tmpName:String="";
			var msgArr:Array=new Array();
			if (currentChannel == ChatType.PRIVATE_CHANNEL) {
				msgArr=msg.split(" ");

				tmpName=msgArr[0];
				if (str.indexOf("/") != 0 || tmpName.length > 8) {
					Alert.show("私聊格式不对。", "提示", null, null, "确定", "", null, false);
					return "";
				}
				if (tmpName == "/" + sendTo.getRoleName()) {
					str=msg.substr(sendTo.getRoleNameLen());
					return str;
				}
			}
			if (str.indexOf("/") == 0) {
//				var tmp:String = "039";
//				var ch0:Number = tmp.charCodeAt(0);
//				var ch3:Number = tmp.charCodeAt(1);
//				var ch9:Number = tmp.charCodeAt(2);
//				
//				var ch1:Number = str.charCodeAt(1);
//				var ch2:Number = str.charCodeAt(2);
//				if(ch1>=ch0 && ch1<=ch3 && ch2>=ch0 && ch2<=ch9)
//				{
//					return str;
//				}

				var len:int=str.indexOf(" ");
				if (len > 8) {
					Alert.show("私聊对象或格式不对。", "提示", null, null, "确定", "", null, false);
				}
				if (len == -1) {
					if (str.length <= 8) {
						len=str.length;
					}
				}
				var toRole:String=str.substr(1, len - 1);
				if (toRole == GlobalObjectManager.getInstance().user.base.role_name) {
					Alert.show("不能和自己私聊。", "提示", null, null, "确定", "", null, false);
					return "";
				}
				ChatModule.getInstance().priChatHandler(toRole);
				pre_private_msg=str.substring(len);
				return "";
			}

			return str;
		}

		private function onScrollEnable(evt:MouseEvent=null):void {
			list_world.scrollEnable=true;
			list_family.scrollEnable=true;
			list_country.scrollEnable=true;
			list_private.scrollEnable=true;
			list_team.scrollEnable=true;

			list_world.invalidateDisplayList();
			list_family.invalidateDisplayList();
			list_country.invalidateDisplayList();
			list_private.invalidateDisplayList();
			list_team.invalidateDisplayList();

		}

		public function scrollEnd():void {
			onScrollEnable();
		}

		private var chat_size:int=1; //本來為1，改為2

		public function onresize(evt:MouseEvent=null):void {
			switch (chat_size) {
				case 0:
					chat_size=1;
					break;
				case 1:
					chat_size=2;
					break;
				case 2:
					chat_size=3;
					break;
				case 3:
					chat_size=1;
					break;
			}
			BroadcastModule.getInstance().changeLabapos(chat_size);
			ChatModule.getInstance().chatResize(chat_size); //变大
			chatVisable(chat_size);
			resizePos(chat_size);


		}

		private function resizePos(size:int=2):void //本來為1，改為2
		{
			if (size == 0) {
				return;
			}
			if (size == 3) {
				tabNav.height=tabNavHeight + 2 * stepHeight;
				shengsuoY=tabNavHeight + 2 * stepHeight - btnHeight +3;

			} else if (size == 2) {
				tabNav.height=tabNavHeight + stepHeight; //tabNavHeight * 1.6 - btnHeight +1;
				shengsuoY=tabNavHeight + stepHeight - btnHeight+3 ; 

			} else if (size == 1) {
				tabNav.height=tabNavHeight;
				shengsuoY=tabNavHeight - btnHeight+3 ;
			}
			if(shieldchatchannel)
			{
				shieldchatchannel.y=shengsuoY-shieldchatchannel.height+btnHeight-2;
			}
			resizeListPos(list_world, size);
			resizeListPos(list_family, size);
			resizeListPos(list_country, size);
			resizeListPos(list_private, size);
			resizeListPos(list_team, size);
			resizeListPos(list_bubble, size);
			resizeListPos(list_laba, size);
			sendMsg_Panel.y=tabNav.height + startY;
			tabNav.validateNow();
		}

		private function resizeListPos(list:ChatList, size:int=1):void {
			if (size == 2) {
				list.height=tabNavHeight + stepHeight - btnHeight; //tabNavHeight * 1.6 - 2* btnHeight + 2;	
				list.scrollBarHeight=tabNavHeight + stepHeight - btnHeight ; //tabNavHeight * 1.6 - 2* btnHeight - 12;

			} else if (size == 1) {
				list.height=tabNavHeight - btnHeight;
				list.scrollBarHeight=tabNavHeight - btnHeight ;

			} else if (size == 3) {
				list.height=tabNavHeight + 2 * stepHeight - btnHeight;
				list.scrollBarHeight=tabNavHeight + 2 * stepHeight - btnHeight;
			}
			list.validateNow();
		}

		private function chatVisable(size:int=2):void //本為1，改為2
		{
			if (size == 0) {
				tabNav.removeTabContainer();
			} else {
				tabNav.addTabContainer();
			}
		}

		public function shuapin():void {
			var list:ChatList=getCurrentList();
			if (list) {
				list.shuapin();
			}
		}

		private var shieldchatchannel:ShieldChatChannel;		
		public function showpingbiView():void 
		{
			if (!shieldchatchannel)
			{
				shieldchatchannel=new ShieldChatChannel();
			}
			shieldchatchannel.x=toolBarContainer.x+25;
			shieldchatchannel.y=toolBarContainer.y+20;
			addChild(shieldchatchannel);
		}

		private function getCurrentList():ChatList {
			var idex:int=tabNav.selectedIndex;
			switch (idex) {
				case 0:
					return list_world;
				case 1:
					return list_country;
				case 2:
					return list_family;
				case 3:
					return list_team;
				case 4:
					return list_bubble;
				case 5:
					return list_laba;
				case 6:
					return list_private;
				default:
					return null;
			}
		}

		//国王上线
		public function addOnlineMsg(vo:Object, role:Object):void {
			list_country.pushMessage(vo, role);
		}

		public function get currentChannel():String {
			return sendTo.currentChannel;
		}

		/**
		 * 整合在一起的方法
		 * **/
		private function resize(evt:MouseEvent):void
		{
			onresize();
		}

		private function onpingbi(evt:MouseEvent):void{
			showpingbiView();
		}
		
		private function clearHandler(event:MouseEvent):void{
			shuapin();
		}

	}
}