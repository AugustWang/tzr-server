package modules.chat.views
{
	import com.common.GlobalObjectManager;
	import com.common.InputKey;
	import com.components.alert.Alert;
	import com.components.chat.MessageTextArea;
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import modules.chat.ChatActionType;
	import modules.chat.ChatModule;
	import modules.chat.ChatType;
	
	import proto.common.p_chat_role;

	/**
	 * 聊天频道
	 */ 
	public class ChatChannel extends Sprite
	{
		public var currentChannel:String = ChatType.WORLD_CHANNEL;//WORLD_CHANNEL;
		public var preChannel:String = ChatType.WORLD_CHANNEL;//WORLD_CHANNEL; //前一个　频道
		private var tempIndex:int = 0;
		private var hasStageListen:Boolean;
		private var firstFocus:Boolean = true;
		private var btn_chatTo:UIComponent;
		private var vBox:Sprite;
		
		public var priChatHandler:Function;
		
		private var priChatBox:Sprite;
		private var priChatText:TextInput;
		private var priChatBtn:Button;
		
		private var priChatMembers:Array;
		private var text:TextField;
		
		public var pre_private_msg:String=""; 
		
		private var m_protect:Boolean = false;
		private var tragle:UIComponent
		
		public function ChatChannel()
		{
			super();
			
			text = ComponentUtil.createTextField(" 综合   ",2,0,null,46,30,this);
			text.textColor = 0xffff00;
			text.filters = [new GlowFilter(0x000000,1,2,2,3)];
			text.mouseEnabled=false;	
			
			
			//以下是修改的部分，把文本、三角形组合到同一个容器中	
//			textsprite=Style.getViewBg("attackModeSkin");
//			textsprite.x=3;
//			textsprite.y=3;
//			textsprite.width=45;
//			textsprite.height=29;
//			addChildAt(textsprite,0);
			tragle=new UIComponent();
			tragle.bgSkin = Style.getButtonSkin("channel_1skin","channel_2skin","channel_3skin","",GameConfig.T1_UI);
			tragle.x=text.width-12;
			tragle.width=10;
			addChild(tragle);
			
			tragle.buttonMode = true;
			tragle.addEventListener(MouseEvent.CLICK,onShieldChannel);
			tragle.setToolTip("点击切换聊天频道",300);
			createChannels();
			vBox.visible = false;
			
			
//			btn_chatTo = ComponentUtil.createUIComponent(30,1,15,31);
//			Style.setBtnChannelStyle(btn_chatTo);
//			btn_chatTo.useHandCursor = btn_chatTo.buttonMode = true;
//			btn_chatTo.x = 34;//40;
//			text = ComponentUtil.createTextField(" 国家   ",2,8,null,54,25,this);//世界 x=5
//			text.mouseEnabled = true;
//			
//			btn_chatTo.mouseEnabled = false;
//			addChild(btn_chatTo);
//			addChild(text);
////			btn_chatTo.addEventListener(MouseEvent.CLICK,onShieldChannel);
////			text.addEventListener(MouseEvent.CLICK,onShieldChannel);
//			
//			textsprite = new Sprite();
//			textsprite.graphics.beginFill(0xffffff,0);
//			textsprite.graphics.drawRect(2,1,46,30);
//			textsprite.graphics.endFill();
//			textsprite.buttonMode = true;
//			addChild(textsprite);
//			textsprite.addEventListener(MouseEvent.CLICK,onShieldChannel);
//			textsprite.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
//			textsprite.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
//			
//			createChannels();
//			vBox.visible = false;
		}
		
		//index表示是vbox的第几个btn，比如index为1表示channel为国家
		public function setChannel(index:int):void
		{
			
			if(m_protect)  //值已经设置，　tabbar 的 index　引起又来执行一次　所以屏蔽掉！
			{
				m_protect = false;
				return;
			}
			
			
			var btn:Button = vBox.getChildAt(index) as Button;
			
			if(firstFocus)
			{
				firstFocus = false;
			}else{
				_messageTextArea.setFocus();
			}
			
			if(_messageTextArea.text!=_messageTextArea.defaultText)//_messageTextArea.text)
			{
				_msgtxt= _messageTextArea.text;
				_messageTextArea.text = msgTxt;
				_messageTextArea.textField.setSelection(msgTxt.length,msgTxt.length);
				
			}else{
				_messageTextArea.defaultText = ChatActionType.MSG_TXT_DEFUALT;
				_messageTextArea.textField.setSelection(_messageTextArea.text.length,_messageTextArea.text.length);
				_messageTextArea.text = _messageTextArea.defaultText;
				
				switch(index){
	//				case 0 ://世界
	//					_messageTextArea.defaultText = ChatActionType.MSG_TXT_WORLD_DEFUALT;
	//					break;
					case 5://喇叭
						_messageTextArea.maxChars = 50;
						_messageTextArea.defaultText = ChatActionType.HORN_MSG_TXT_DEFUALT;
						_messageTextArea.text = _messageTextArea.defaultText;
						if(stage)
							stage.focus = stage;
						break;
					default :
						
						break;
				}
				
			}
			
			if(btn.name == ChatType.WORLD_CHANNEL)
			{
				if(priChatBox != null && contains(priChatBox))
					removeChild(priChatBox);
				
				if(this.currentChannel == ChatType.PRIVATE_CHANNEL )
				{
					if(priChatMembers != null && priChatMembers.length >= 1)
					{
						this.currentChannel = btn.name;
						preChannel = currentChannel;
						_messageTextArea.text = "/" + priChatMembers[priChatMembers.length -1].rolename + " ";
						_messageTextArea.textField.setSelection(_messageTextArea.text.length,_messageTextArea.text.length);
						_messageTextArea.maxChars = 80;
					}
					
				}
				
				return;
					
			}
			
			
			
			if(btn.name == ChatType.PRIVATE_CHANNEL)
			{
				
				if(priChatMembers != null && priChatMembers.length >= 1)
				{
					text.text = btn.label;
					
					this.currentChannel = btn.name;
					preChannel = currentChannel;
					_messageTextArea.text = "/" + priChatMembers[priChatMembers.length -1].rolename + " ";
					_messageTextArea.textField.setSelection(_messageTextArea.text.length,_messageTextArea.text.length);
					_messageTextArea.maxChars = 80;
					
					_msgtxt = "";
					
					if(_messageTextArea.textField.hasEventListener(Event.CHANGE))
						_messageTextArea.textField.addEventListener(Event.CHANGE,checkNullName);
				}
				else
				{
					_messageTextArea.text = "";
					_msgtxt = "";
					popUpPriChatBox();
					
				}
			}
			else
			{
				_messageTextArea.maxChars = 80;
				
				if(btn.name == ChatType.BUBBLE_CHANNEL) //附近　限制　40　字
					_messageTextArea.maxChars = 40;
				
				text.text = btn.label;
				if(priChatBox != null && contains(priChatBox))
					removeChild(priChatBox);
				
				
				this.currentChannel = btn.name;
				preChannel = currentChannel;
			}
			
		}
		
		private function checkNullName(e:Event):void
		{
//			if(currentChannel != ChatType.PRIVATE_CHANNEL)
//			{
//				return;
//			}
//			if(_messageTextArea.text=="")
//			{
//				if(priChatMembers.length>0)
//				{
//					priChatMembers.pop();
//				}
//			}
		}
		
		private var _msgtxt:String="";
		public function get msgTxt():String
		{
			return _msgtxt;
			
//			_msgtxt = value;
//			_messageTextArea.text = value;
//			_messageTextArea.setFocus();
		}
		
		public function getRoleNameLen():int
		{
			var str:String="";
			if(priChatMembers != null && priChatMembers.length >= 1)
			{
				str = priChatMembers[priChatMembers.length -1].rolename;
				return str.length+2;
			}
			return 0;
		}
		
		public function getRoleName():String
		{
			var str:String ="";
			if(priChatMembers != null && priChatMembers.length >= 1)
			{
				str = priChatMembers[priChatMembers.length -1].rolename;
				return str;
			}
			return str;
		}
		
		public function setPreChannel():void
		{
			//  trace("preChannel :::::::::: "+preChannel);
			//  trace("currentChannel :::::::::: "+currentChannel);
			this.currentChannel = preChannel;
		}
		
		public function addPriMember(vo:p_chat_role):void
		{
			if(priChatMembers == null)
				priChatMembers = new Array();
			if(!vo)
			{
				if(stage && stage.focus == _messageTextArea.textField)
				{
					while(priChatMembers.length>0)
					{
						priChatMembers.pop();
					}
				}
				return;
			}
			
			if(vo != null)
			{
				for(var i:int = 0; i< priChatMembers.length; i++)
				{
					if(priChatMembers[i].roleid == vo.roleid)
					{
						priChatMembers.splice(i, 1);
						i--;
					}
				}
				
				priChatMembers.push(vo);
//				text.text = vo.rolename;
				
				setChannel(6);//(5);
				_msgtxt = "";
				
				
			}
			
			ChatModule.getInstance().priMesSend();
			
		}
		

		private function onShieldChannel(event:MouseEvent):void{
			if(vBox == null){
				createChannels();
			}else{
				vBox.visible = !vBox.visible;
				
			}
			if(vBox.visible){
				if(!hasStageListen)
				{
					stage.addEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
					hasStageListen = true;
				}
			}
			
			if(priChatBox != null && priChatBox.parent != null)
				priChatBox.parent.removeChild(priChatBox);
		}
		
		private function onStageMouseUp(event:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			hasStageListen = false;
			if(event.currentTarget  == btn_chatTo)return;
			if(event.target == tragle)return;
			vBox.visible = false;
		}
		
		private function createChannels():void{
			vBox = new Sprite();
			vBox.addChild(createButtton("综合",0,ChatType.WORLD_CHANNEL));
			vBox.addChild(createButtton("国家",25,ChatType.COUNTRY_CHANNEL));
			vBox.addChild(createButtton("门派",50,ChatType.FAMILY_CHANNEL));
			vBox.addChild(createButtton("队伍",75,ChatType.TEAM_CHANNEL));
			vBox.addChild(createButtton("附近",100,ChatType.BUBBLE_CHANNEL));
			vBox.addChild(createButtton("喇叭",125,ChatType.HORN_CHANNEL));                // change 
			vBox.addChild(createButtton("私聊",150,ChatType.PRIVATE_CHANNEL));
			vBox.y = -175;
			
			
			addChild(vBox)
		}
		
		private function createButtton(label:String,yValue:int,name:String,addListener:Boolean=true):Button{
			var createButton:Button = new Button();
			Style.setDefault1BtnStyle(createButton);
			createButton.name = name;
			createButton.label = label;
			createButton.width = 60;
			createButton.height =25;
			createButton.y = yValue;
			if(addListener){
				createButton.addEventListener(MouseEvent.CLICK,onChannelClick);
			}
			return createButton;
		}
		
		private function onChannelClick(event:MouseEvent):void{
			var channelBtn:Button = event.currentTarget as Button;
			if(currentChannel != ChatType.PRIVATE_CHANNEL)
			{
				if(_messageTextArea.text != _messageTextArea.defaultText)
				{
					_msgtxt = _messageTextArea.text;
					
				}else{
					_msgtxt = "";
				}
			}else{
				_msgtxt = "";
			}
			_messageTextArea.defaultText = ChatActionType.MSG_TXT_DEFUALT;
			_messageTextArea.maxChars = 80;
			
			if(channelBtn.name == ChatType.WORLD_CHANNEL)
			{
				_messageTextArea.defaultText = ChatActionType.MSG_TXT_WORLD_DEFUALT;
				
				_messageTextArea.setFocus();
				if(msgTxt !="")
				{
					_messageTextArea.text = msgTxt;
					_messageTextArea.textField.setSelection(msgTxt.length,msgTxt.length);
				}
				else
				{
					_messageTextArea.text = _messageTextArea.defaultText;
					if(stage)
					{
						stage.focus=stage;
					}
				}
				text.text = channelBtn.label;
				currentChannel = channelBtn.name;
				
			}
			else if(channelBtn.name == ChatType.PRIVATE_CHANNEL)
			{
				popUpPriChatBox();
				
			}
			else if(channelBtn.name == ChatType.HORN_CHANNEL)
			{
				_messageTextArea.defaultText = ChatActionType.HORN_MSG_TXT_DEFUALT;
				_messageTextArea.maxChars = 50;
				
				_messageTextArea.setFocus();
				if(msgTxt !="")
				{
					_messageTextArea.text = msgTxt;
					_messageTextArea.textField.setSelection(msgTxt.length,msgTxt.length);
				}
				else
				{
					_messageTextArea.text = _messageTextArea.defaultText;
					if(stage)
					{
						stage.focus=stage;
					}
				}
				
				text.text = channelBtn.label;
				currentChannel = channelBtn.name;
				
			}
			else
			{
				if(channelBtn.name == ChatType.BUBBLE_CHANNEL)
				{
					_messageTextArea.maxChars = 40;
					
				}
				
				_messageTextArea.setFocus();
				_messageTextArea.text = msgTxt;
				_messageTextArea.textField.setSelection(msgTxt.length,msgTxt.length);
				text.text = channelBtn.label;
				currentChannel = channelBtn.name;
				
			}
		}
		
		
		private function initPriView():void
		{
			if(priChatBox == null)
			{
				priChatText = new TextInput();
				priChatText.width = 155;
				priChatText.height = 25;
				priChatText.maxChars = 7;
				
				//priChatBtn = new Button();
				//GStyle.setSendMsgStyle(priChatBtn);
				priChatBtn = new Button();
				priChatBtn.label = "确定";
				priChatBtn.x = 160;
				priChatBtn.width = 50;
				priChatBtn.height = 25;
				
				priChatBox = new Sprite();
				priChatBox.x = 15;
				priChatBox.y = -30 - ChatView.btnHeight;
				
				priChatBox.addChild(priChatText);
				priChatBox.addChild(priChatBtn);
				
			}
		}
		
		private function popUpPriChatBox():void
		{
			initPriView();
			if(priChatMembers != null && priChatMembers.length >= 1)
			{
				var channelBtn:Button = vBox.getChildAt(6) as Button;//event.currentTarget as Button;
				text.text = channelBtn.label;
				this.currentChannel = ChatType.PRIVATE_CHANNEL;
				preChannel = currentChannel;
				_messageTextArea.setFocus();
				_messageTextArea.text = "/" + priChatMembers[priChatMembers.length -1].rolename + " ";
				_messageTextArea.textField.setSelection(_messageTextArea.text.length,_messageTextArea.text.length);
				_messageTextArea.maxChars = 80;
				
				if(_messageTextArea.textField.hasEventListener(Event.CHANGE))
					_messageTextArea.textField.addEventListener(Event.CHANGE,checkNullName);
				//priChatText.text = priChatMembers[priChatMembers.length -1].rolename;
			}
				
			else
			{
				priChatText.text = "";
				addChild(priChatBox);
				
				priChatText.setFocus();
				priChatBtn.addEventListener(MouseEvent.CLICK, onClick);
				priChatText.addEventListener(KeyboardEvent.KEY_UP, onEnter);
			}
		}
		
		private function onClick(evt:Event):void
		{
			if(priChatBox != null && priChatBox.parent != null)
				priChatBox.parent.removeChild(priChatBox);
			
			var str:String = StringUtil.trim(priChatText.text);
			if(str == "")
			{
				
				return;
			}
			
			if(str == GlobalObjectManager.getInstance().user.base.role_name)
			{
				Alert.show("不能和自己私聊","提示",okHandler,null,"确定","",null,false);
				return;
			}
			if(priChatHandler != null)
			{
				priChatHandler.apply(null,[str]);
				
			}
			if(stage)
				stage.focus = stage;
		}
		
		private function okHandler():void
		{
//			setChannel(0);
//			_tabNav.selectedIndex = 0;
		}
		
		private function onEnter(evt:KeyboardEvent):void
		{
			if(evt.keyCode == InputKey.ENTER)
				onClick(evt);
		}
		
		private var _messageTextArea:MessageTextArea;
		public function set messageTextArea(value:MessageTextArea):void
		{
			_messageTextArea = value;	
		}
		
		private var _tabNav:TabNavigation;
		public function set tabNavigation(value:TabNavigation):void
		{
			_tabNav = value;
		}
	}
}