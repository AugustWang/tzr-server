package modules.friend.views.part
{
	import com.common.Constant;
	import com.common.FilterCommon;
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.common.WordFilter;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.components.chat.ChatList;
	import com.components.chat.FacesChooser;
	import com.components.chat.MessageTextArea;
	import com.components.chat.events.ChatEvent;
	import com.globals.GameConfig;
	import com.gs.TweenLite;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import modules.broadcast.KeyWord;
	import modules.friend.FriendsConstants;
	import modules.friend.FriendsManager;
	import modules.friend.FriendsModule;
	import modules.friend.OpenItemsManager;
	import modules.friend.views.friendsetting.LoadPrinceAndCityData;
	
	import proto.common.p_role_ext;
	import proto.line.m_role2_getroleattr_toc;
	import proto.line.p_friend_info;
	import proto.line.p_other_role_info;
	
	public class OneToOnePanel extends BasePanel implements IChatWindow
	{
		private var rolename:TextField;
		private var sign:TextField;
		
		private var announce:TextField;
		private var announceDesc:TextField;
		private var leftBg:Skin;
		private var rightBg:Skin;
		private var chatList:ChatList;
		
		private var facesChooser:FacesChooser;
		private var request:UIComponent;
		private var group:UIComponent;
		
		private var txt_sendMsg:MessageTextArea;
		
		
		private var sendBtn:Button;
		private var historyBtn:Button;
		private var msgBtn:Button;
		
		private var smallBtn:UIComponent;
		
		private var lastTime:Number = -500;
		private var _sender:p_friend_info;
		
		private var left:Number = 10;
		private var headImg:Image
		private var _vipTxt:TextField;
		private var stateTxt:TextField;
		private var familyTxt:TextField;
		private var birthTxt:TextField;
		private var areaTxt:TextField;
		private var _vipBg:Sprite;
		
		public function OneToOnePanel()
		{
			super();
			
			this.width = 532;
			this.height = 389;
			
			var bigButtonSkin:ButtonSkin=Style.getButtonSkin("small_1skin",
				"small_2skin","small_3skin",null,GameConfig.T1_UI);

			smallBtn = createUIComponent(width - 45,9,16,6,bigButtonSkin);
			this.addChildToSuper(smallBtn);
			smallBtn.addEventListener(MouseEvent.CLICK,onSmallClickHandler);
			
			var header:Sprite = new Sprite();
			header.x = 10;
			header.y = 15;
			header.mouseEnabled = header.mouseChildren = false;
			addChildToSuper(header);
			
			var boxBg:Sprite = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			boxBg.x = 8;
			boxBg.mouseChildren = false;
			header.addChild(boxBg);
			headImg = new Image();
			headImg.width = headImg.height = 36;
			boxBg.addChild(headImg);
			var tf:TextFormat = Constant.TEXTFORMAT_DEFAULT;
			rolename = ComponentUtil.createTextField(GlobalObjectManager.getInstance().user.base.role_name,52,0,tf,125);
			rolename.filters = FilterCommon.FONT_BLACK_FILTERS;
			header.addChild(rolename);
			sign = ComponentUtil.createTextField("共铸我们的天之刃！",52,18,tf,148,18,header);
			
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
			
			stateTxt = ComponentUtil.createTextField("国家: ",5,10,null,100,23,rightBg);
			familyTxt = ComponentUtil.createTextField("门派: ",stateTxt.x,stateTxt.y + stateTxt.height,null,120,23,rightBg);
			birthTxt = ComponentUtil.createTextField("生日: ",stateTxt.x,familyTxt.y + familyTxt.height,null,120,23,rightBg);
			_vipTxt = ComponentUtil.createTextField("VIP: ", stateTxt.x, birthTxt.y + birthTxt.height, null, NaN, 23, rightBg);
			areaTxt = ComponentUtil.createTextField("地区: ",stateTxt.x, _vipTxt.y + _vipTxt.height,null,100,46,rightBg);
			
			announce = createTextField("官方郑重声明：",135,23,areaTxt.x,areaTxt.y + areaTxt.height + 40,false,new TextFormat("Arail",13,0xcc6600));
			rightBg.addChild(announce);
			
			announceDesc = createTextField("",135,90,announce.x,announce.y + announce.height,false,new TextFormat("Arail",12,0xffffff));
			rightBg.addChild(announceDesc);
			announceDesc.multiline = true;
			announceDesc.wordWrap = true;
			announceDesc.text = "　　我们不会通过私聊向你发送任何中奖信息。切勿轻信游戏内收到的任何中奖信息，以防受骗！";
	
			sendBtn = createBtn("发送", 70,25,290,313);
			sendBtn.addEventListener(MouseEvent.CLICK,sendMessage);
			addChild(sendBtn);
			
			msgBtn = createBtn("关闭",70,25, 215,313);
			addChild(msgBtn);
			msgBtn.addEventListener(MouseEvent.CLICK,oncloseHandler);
			
		}
		
		public function showFriendInfo(vo:m_role2_getroleattr_toc):void{
			var faction_id:int = vo.role_info.faction_id;
			if(faction_id == 1){//云州
				stateTxt.htmlText = "国家: <font color='#00ff00'>"+ GameConstant.getNation(vo.role_info.faction_id)+"</font>";
			}else if(faction_id == 2){//沧州
				stateTxt.htmlText = "国家: <font color='#ff0000'>"+ GameConstant.getNation(vo.role_info.faction_id)+"</font>";
			}else if(faction_id == 3){//幽州
				stateTxt.htmlText = "国家: <font color='#40DEF9'>"+ GameConstant.getNation(vo.role_info.faction_id)+"</font>";
			}
			
			if(vo.role_info.family_name.length != 0){
				familyTxt.htmlText = "门派: "+vo.role_info.family_name;
			}else{
				familyTxt.htmlText = "门派: 无";
			}
			var p_vo:p_other_role_info = vo.role_info;
			var birth:int = p_vo.birthday;
			if(birth == 0){
				birthTxt.htmlText = "生日: 未填写";
			}else{
				var year:int = int(birth.toString().substr(0,4));
				var month:int = int(birth.toString().substr(4,2));
				var day:int = int(birth.toString().substr(6,2));
				var m:String;
				var d:String;
				if(month<10){
					m = "0"+month;
				}else{
					m = month+"";
				}if(day<10){
					d = "0"+day;
				}else{
					d = day+"";
				}	
				birthTxt.htmlText = "生日: "+year+"-"+m+"-"+d;
			}
			
			if(p_vo.province == 0){
				areaTxt.htmlText = "地区: 未填写";
			}else{
				areaTxt.htmlText = "地区: "+LoadPrinceAndCityData.instance.prince_arr[p_vo.province].princeName + "\n        "+ (LoadPrinceAndCityData.instance.city_arr[p_vo.province])[p_vo.city].cityName;
			}
			
			if (_vipBg) {
				rightBg.removeChild(_vipBg);
				_vipBg = null;
			}
			
			_vipBg = new Sprite;
			_vipBg.x = stateTxt.x + 37;
			_vipBg.y = 79;
			rightBg.addChild(_vipBg);
			
			var vipIcon:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"vip"+p_vo.vip_level);
			vipIcon.y = 3;
			_vipBg.addChild(vipIcon);
		
		}
				
		private function clickItemHandler(event:TextEvent,data:Object):void{
			var friendVO:p_friend_info = FriendsManager.getInstance().getFriendVO(sender.roleid);
			if(friendVO){
				sender.type = friendVO.type;
			}else{
				sender.type = FriendsConstants.STRANGER_TYPE;
			}
			OpenItemsManager.getInstance().openNormalItems(sender);
		}
		
		
		private function oncloseHandler(evt:MouseEvent):void
		{
			var event:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			this.dispatchEvent(event);
		}
		
		private function onSmallClickHandler(evt:MouseEvent):void{
			minResize();
		}
		
		private var cloneBitmap:Bitmap;
		public function minResize():void{
			var p:Array = LayerManager.uiLayer.chatwindowBar.getPosition(sender.roleid);
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
			LayerManager.uiLayer.chatwindowBar.setSmall(true,sender.roleid);
			WindowManager.getInstance().removeWindow(this);
		}
		
		public function maxReisze(newX:Number,newY:Number):void{
			if(cloneBitmap && cloneBitmap.parent){
				x = newX;
				y = newY;
				TweenLite.to(cloneBitmap,0.2,{scaleX:1,scaleY:1,x:newX,y:newY,onComplete:smallComplete});
			}
		}
		
		private function smallComplete():void{
			if(cloneBitmap && cloneBitmap.parent){
				cloneBitmap.parent.removeChild(cloneBitmap);
				WindowManager.getInstance().popUpWindow(this);
				WindowManager.getInstance().bringToFront(this);
			}
		}
		
		private function createBtn(label:String, width:Number, height:Number, xValue:Number, yValue:Number):Button
		{
			var btn:Button = new Button();
			btn.label = label;
			btn.width = width;
			btn.height = height;
			btn.x = xValue;
			btn.y = yValue;
			Style.setDeepRedBtnStyle(btn);
			return btn;
		}
		
		private function createTextField(label:String, width:Number, height:Number, xValue:Number, yValue:Number,htmlText:Boolean = true,textFormat:TextFormat=null):TextField
		{
			var textField:TextField = new TextField();
			if(textFormat != null)
				textField.defaultTextFormat = textFormat;
			textField.htmlText = label;
			textField.width = width;
			textField.height = height;
			textField.selectable = false;
			textField.x = xValue;
			textField.y = yValue;
			return textField;
		}
		
		private function createUIComponent(xValue:Number, yValue:Number, width:Number, height:Number, skin:Skin):UIComponent
		{
			var result:UIComponent = new UIComponent();
			result.x = xValue;
			result.y = yValue;
			result.width = width;
			result.height = height;
			
			skin == null ? '' : result.bgSkin = skin;
			
			return result;
		}
		
		public function set sender(role:p_friend_info):void
		{
			this._sender = role;
			var chatIconItem:ChatIconItem = LayerManager.uiLayer.chatwindowBar.getChatIconItem(role.roleid);
			if(chatIconItem){
				chatIconItem.updateChatInfo(role);
			}
			rolename.text = role.rolename;
			sign.text = role.sign;
			if(sign.text == ""){
				sign.text = "共铸我们的天之刃！";
			}
			this.headImg.source=GameConstant.getHeadImage(role.head);
			this.headImg.height=this.headImg.width=35;
			
		}
		
		public function get sender():p_friend_info
		{
			return this._sender;
		}
		
		private function onInsertFace(event:ChatEvent):void{
			txt_sendMsg.appendText(event.data.toString());
		}

		private var preMsg:String = "";
		private function sendMessage(event:MouseEvent = null):void{
			if(sender == null){
				Alert.show("不存在该玩家","警告",null,null,"确定","",null,false,true);
				return;
			}
			var message:String = StringUtil.trim(txt_sendMsg.text);
			if(message == "")return;
			if(preMsg == message){
				chatList.pushMessage(HtmlUtil.font("重复发送相同消息内容。","#ff0000") ,null);	
				return;
			}
			if (getTimer() - lastTime <= 3000)
			{
				chatList.pushMessage(HtmlUtil.font("操作速度太快，坐下来喝杯咖啡吧。","#ff0000"),null);
				return;
			}
			if(message == "" || message==txt_sendMsg.defaultText){
				stage.focus = stage;
			}else{
				preMsg = message;
				message = HtmlUtil.filterHtml(message);
				var msg:String = KeyWord.instance().replace(message,KeyWord.TALK_WORDS);
				if(WordFilter.isValid(msg)){
					FriendsModule.getInstance().send(msg,sender);
				}else{
					wrapperMySelfMsg(msg);
				}
				lastTime = getTimer();
			}
			txt_sendMsg.text = "";
		}
		
		private function yesHandler():void
		{
			var evt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			this.dispatchEvent(evt);
		}
		
		public function appendMessage(msg:String):void
		{
			chatList.pushMessage(msg, this.sender);
		}
		
		public function getFocus():void{
			txt_sendMsg.setFocus();
		}
		
		public function setTextMessage(msg:String):void{
			if(msg && msg != ""){
				txt_sendMsg.text = msg;
			}
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