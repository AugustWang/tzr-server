package modules.friend.views.part
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.common.WordFilter;
	import com.components.BasePanel;
	import com.components.chat.ChatList;
	import com.components.chat.FacesChooser;
	import com.components.chat.MessageTextArea;
	import com.components.chat.events.ChatEvent;
	import com.globals.GameConfig;
	import com.gs.TweenLite;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.events.ItemEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import modules.broadcast.KeyWord;
	import modules.friend.FriendsConstants;
	import modules.friend.FriendsManager;
	import modules.friend.FriendsModule;
	import modules.friend.GroupManager;
	import modules.friend.OpenItemsManager;
	import modules.friend.views.items.PlayerItem;
	import modules.friend.views.vo.GroupItemVO;
	import modules.friend.views.vo.GroupType;
	import modules.friend.views.vo.GroupVO;
	import modules.mypackage.views.ChatItemToolTip;
	
	import proto.line.p_friend_info;

	public class OneToManyPanel extends BasePanel implements IChatWindow
	{
		private var leftBg:Skin;
		private var rightBg:Skin;
		private var groupPlacard:TextField;
		private var groupNameTF:TextField;
		private var groupInfoText:TextField;
		private var chatList:ChatList;
		private var facesChooser:FacesChooser;
		private var txt_sendMsg:MessageTextArea;
		private var jy:Sprite;
		private var friendList:List;
		private var lastTime:Number = -500;
		private var _groupInfo:GroupVO;
		
		private var timeout:int;
		public function OneToManyPanel()
		{
			super();
			
			this.width = 532;
			this.height = 389;
			
			var bigButtonSkin:ButtonSkin=Style.getButtonSkin("small_1skin",
				"small_2skin","small_3skin",null,GameConfig.T1_UI);
			
			var smallBtn:UIComponent = ComponentUtil.createUIComponent(width-45,9,16,6,bigButtonSkin);
			smallBtn.addEventListener(MouseEvent.CLICK,onSmallClickHandler);
			addChildToSuper(smallBtn);
			
	
			leftBg = Style.getPanelContentBg();
			leftBg.mouseChildren = true;
			leftBg.setSize(362,287);
			leftBg.x = 8;
			leftBg.y = 25;
			addChild(leftBg);
			
			rightBg = Style.getPanelContentBg();
			rightBg.mouseChildren = true;
			rightBg.setSize(150,317);
			rightBg.y = 25;
			rightBg.x = 374;
			addChild(rightBg);
			
			groupNameTF = ComponentUtil.createTextField("",16,4,new TextFormat("",14,0xFFFF00),150,22);
			groupNameTF.filters = FilterCommon.FONT_BLACK_FILTERS;
			addChild(groupNameTF);
			
			var placardTitleBar:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			placardTitleBar.x = 2;
			placardTitleBar.y = 1;
			placardTitleBar.width = 147;;
			rightBg.addChild(placardTitleBar);
			
			var txt:TextField = ComponentUtil.createTextField("群公告",9,2,new TextFormat("",12,0xffff00),44,20,rightBg);
			txt.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			groupPlacard = ComponentUtil.createTextField("",3,24,null,150,117,rightBg);
			groupPlacard.filters = FilterCommon.FONT_BLACK_FILTERS;
			groupPlacard.wordWrap = true;
			groupPlacard.multiline = true;
							
			var groupTitleBar:UIComponent = ComponentUtil.createUIComponent(2,144,147,21);
			Style.setTitleBarSkin(groupTitleBar);
			rightBg.addChild(groupTitleBar);
			
			groupInfoText = ComponentUtil.createTextField("群成员",9,145,null,150,20,rightBg);
			groupInfoText.filters = FilterCommon.FONT_BLACK_FILTERS;
			groupInfoText.textColor = 0xffff00;
			
			chatList = new ChatList();
			chatList.scrollBarSkin = Style.getInstance().scrollBarSkin;
			chatList.itemHandler = clickItemHandler;
			chatList.direction = ScrollDirection.RIGHT;
			chatList.verticalScrollPolicy = ScrollPolicy.AUTO;
			chatList.bgAlpha = 0;
			chatList.x = 7;
			chatList.y = 6;
			chatList.width = 353;
			chatList.height = 170;
			leftBg.addChild(chatList);
			
			var titleBar:UIComponent = ComponentUtil.createUIComponent(4,176,353,21);
			Style.setTitleBarSkin(titleBar);
			leftBg.addChild(titleBar);
			
			facesChooser = new FacesChooser();
			facesChooser.clearSkin();
			facesChooser.addEventListener(ChatEvent.SELECTED_FACE,onInsertFace);
			facesChooser.x = 15;
			facesChooser.y = 173;
			leftBg.addChild(facesChooser);
			
			txt_sendMsg = new MessageTextArea();
			txt_sendMsg.multiline = true;
			txt_sendMsg.enterFunc = sendMessage;
			txt_sendMsg.width = 348;
			txt_sendMsg.height = 82;
			txt_sendMsg.x = 7;
			txt_sendMsg.y = 197;
			txt_sendMsg.maxChars = 240;
			leftBg.addChild(txt_sendMsg);

			var jy:TextField = ComponentUtil.createTextField("",42,177,null,100,20,this);
			jy.filters = FilterCommon.FONT_BLACK_FILTERS;
			jy.mouseEnabled = true;
			jy.htmlText = "<a href='event:group'><u>"+HtmlUtil.font("屏蔽群","#3be450")+"</u></a>";
			jy.addEventListener(TextEvent.LINK,onGroupHandler);
			jy.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			jy.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			leftBg.addChild(jy);
			
			var sendBtn:Button = ComponentUtil.createButton("发送",290,313,70,25,this);
			sendBtn.addEventListener(MouseEvent.CLICK,sendMessage);
			
			var closeBtn:Button = ComponentUtil.createButton("关闭",215,313,70,25,this);
			closeBtn.addEventListener(MouseEvent.CLICK,oncloseHandler);
			
			friendList = new List();
			friendList.x = 2;
			friendList.y = 165;
			friendList.width = 147;
			friendList.height = 149;
			friendList.bgSkin = null;
			friendList.itemHeight = 23;
			friendList.verticalScrollPolicy = ScrollPolicy.AUTO;
			friendList.itemRenderer = PlayerItem;
			friendList.itemDoubleClickEnabled = true;
			friendList.addEventListener(ItemEvent.ITEM_CLICK, onItemClick);
			friendList.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,onItemDoubleClick);
			rightBg.addChild(friendList);
		}
		
		private function onRollOver(event:MouseEvent):void{
			ToolTipManager.getInstance().show("屏蔽群消息",200);
		}
		
		private function onRollOut(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		private var handlerView:GroupSetting;
		private function onGroupHandler(event:TextEvent):void{
			if(handlerView && handlerView.parent){
				onMouseDown(null);
			}else{
				if(handlerView == null){
					handlerView = new GroupSetting();
					handlerView.addEventListener(CloseEvent.CLOSE,closeHandlerView);
					handlerView.x = 58; 
					handlerView.y = 226;
					handlerView.setGroup(_groupInfo.id,_groupInfo.type);
				}
				stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				addChild(handlerView);
			}
		}
		
		private function closeHandlerView(event:CloseEvent):void{
			onMouseDown(null);
		}
		
		private function onMouseDown(event:MouseEvent):void{
			if(event && (handlerView.contains(event.target as DisplayObject) || event.target == jy)){
				return;
			}
			if(handlerView && handlerView.parent){
				stage.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				handlerView.parent.removeChild(handlerView);
			}
		}
		
		/**
		 * 退出群 
		 */		
		private function onExitGroup(evt:TextEvent):void{
			
		}
		
		public function set groupArray(value:Array):void{
			friendList.dataProvider = value;	
		}
		
		private function clickItemHandler(event:TextEvent,data:Object):void{
			var text:String = event.text;
			if(text.indexOf("=") != -1){
				var texts:Array = text.split("=");
				ChatItemToolTip.add(texts[0],texts[1],texts[2]);
			}else if(text.indexOf("+") != -1){
				var results:Array = text.split("+");
				var role:p_friend_info = new p_friend_info();
				role.roleid = int(results[0]);
				role.rolename = String(results[1]);
				doItemClick(role);
			}
		}
		
		private function onSmallClickHandler(evt:MouseEvent):void{
			minResize();
		}
		
		private var cloneBitmap:Bitmap;
		public function minResize():void{
			var p:Array = LayerManager.uiLayer.chatwindowBar.getPosition(_groupInfo.id);
			if(cloneBitmap == null){
				cloneBitmap = new Bitmap();
				var bitmapdata:BitmapData = new BitmapData(width,height,true,0);
				bitmapdata.draw(this);
				cloneBitmap.bitmapData = bitmapdata;
			}
			LayerManager.main.addChild(cloneBitmap);
			cloneBitmap.x = x;
			cloneBitmap.y = y;
			TweenLite.to(cloneBitmap,0.2, {x:p[0], y:p[1],scaleX:0,scaleY:0});
			LayerManager.uiLayer.chatwindowBar.setSmall(true,_groupInfo.id);
			WindowManager.getInstance().removeWindow(this);
		}
		
		public function maxReisze(newX:Number,newY:Number):void{
			if(cloneBitmap && cloneBitmap.parent){
				TweenLite.to(cloneBitmap,0.2,{scaleX:1,scaleY:1,x:newX,y:newY,onComplete:smallComplete});
			}
		}
		
		private function smallComplete():void{
			if(cloneBitmap && cloneBitmap.parent){
				cloneBitmap.parent.removeChild(cloneBitmap);
				x = cloneBitmap.x;
				y = cloneBitmap.y;
				WindowManager.getInstance().popUpWindow(this);
				WindowManager.getInstance().bringToFront(this);
			}
		}
			
		private function onItemDoubleClick(event:ItemEvent):void{
			clearTimeout(timeout);
			var itemData:GroupItemVO = event.selectItem as GroupItemVO;
			if(itemData){
				ChatWindowManager.getInstance().openChatWindow(createFriendInfo(itemData));
			}
		}
		
		private function onItemClick(event:ItemEvent):void{
			clearTimeout(timeout);
			var data:GroupItemVO = event.selectItem as GroupItemVO;
			if(data){
				timeout = setTimeout(doItemClick, 200, createFriendInfo(data));
			}
		}
		
		private function createFriendInfo(data:GroupItemVO):p_friend_info{
			var role:p_friend_info = new p_friend_info();
			role.rolename = data.roleName;
			role.roleid = data.roleId;
			role.is_online = data.online;
			role.head = data.head;
			return role;
		}
		
		private function doItemClick(data:p_friend_info):void
		{
			var friendVO:p_friend_info = FriendsManager.getInstance().getFriendVO(data.roleid);
			if(friendVO){
				data.type = friendVO.type;
			}else{
				data.type = FriendsConstants.STRANGER_TYPE;
			}
			OpenItemsManager.getInstance().openFriendItems(data);
		}

		public function set groupInfo(value:GroupVO):void{
			this._groupInfo = value;
			groupNameTF.text = _groupInfo.name;
			var html:String = "1、官方不会发布中奖信息。\n";
			var start:int = 1;
			if(_groupInfo.type == GroupType.LEVEL_GROUP){
				html += (++start)+"、相同等级段在同一个群。\n";
			}
			html += (++start)+"、群消息可设置为屏蔽。\n\n\n";
			html += "请文明聊天，祝您游戏愉快！";
			groupPlacard.htmlText = html;
			//groupInfoText.htmlText = "群成员 ("+HtmlUtil.font(_groupInfo.online_num.toString(),"#ffff00")+"/"+_groupInfo.total_num+")";
			Dispatch.register(GroupManager.GROUP_MEMBER_ONLINE_CHANGED,onOnlineUpdate);
			Dispatch.register(_groupInfo.id,onUpdate);
		}
		
		public function get groupInfo():GroupVO{
			return _groupInfo;
		}

		private function onInsertFace(event:ChatEvent):void{
			txt_sendMsg.appendText(event.data.toString());
		}
		
		private var preMsg:String = "";
		private function sendMessage(event:MouseEvent = null):void{
			var message:String = StringUtil.trim(txt_sendMsg.text);
			if(message == "")return;
			if(preMsg == message){
				chatList.pushMessage(HtmlUtil.font("重复发送相同消息内容。","#ff0000") ,null);	
				return;
			}
			
			if (getTimer() - lastTime <= 3000){
				chatList.pushMessage(HtmlUtil.font("操作速度太快，坐下来喝杯咖啡吧。","#ff0000") ,null);
				return;
			}	
			
			if(message == "" || message==txt_sendMsg.defaultText){
				stage.focus = stage;
			}else{
				preMsg = message;
				message = HtmlUtil.filterHtml(message);
				var msg:String = KeyWord.instance().replace(message,KeyWord.TALK_WORDS);
				if(WordFilter.isValid(msg)){
					FriendsModule.getInstance().sendGroupMessage(msg,groupInfo.id);
				}else{
					wrapperMySelfMsg(msg);
				}
				lastTime = getTimer();
			}
			txt_sendMsg.text = "";
		}
		
		private function onUpdate():void{
			var item:Object = friendList.selectedItem;
			groupArray = GroupManager.getInstance().getMemebers(groupInfo.id);
			friendList.validateNow();
			friendList.selectedItem = item;
		}
		
		private function onOnlineUpdate(item:Object):void{
			friendList.refreshItem(item);
		}
		
		private function oncloseHandler(event:MouseEvent):void{
			var evt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(evt);
		}
		
		override protected function closeHandler(event:CloseEvent=null):void{
			onMouseDown(null);
			super.closeHandler();
			Dispatch.remove(_groupInfo.id,onUpdate);
		}
		
		public function appendMessage(msg:String):void
		{
			chatList.pushMessage(msg,null);
		}
		
		public function getFocus():void{
			txt_sendMsg.setFocus();
		}
		
		public function wrapperMySelfMsg(msg:String):void{
			var nameHTML:String = GlobalObjectManager.getInstance().user.attr.role_name;
			var sex:int = GlobalObjectManager.getInstance().user.base.sex;
			var date:Date = new Date();
			var sexStr:String = sex == 1 ? "<font color='#00ccff'>♂</font>": "<font color='#ff37e0'>♀</font>";
			var msg:String = sexStr+"<font color='#00ff00'>["+nameHTML+"]</font>   "+DateFormatUtil.formatHours(date.time/1000)+"\n" + msg;
			appendMessage(msg);
		}
	}
}