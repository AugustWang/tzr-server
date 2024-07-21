package modules.friend.views
{
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.RadioButton;
	import com.ming.ui.controls.RadioButtonGroup;
	import com.ming.ui.controls.TextInput;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.KeyWord;
	import modules.broadcast.views.Tips;
	import modules.friend.FriendsModule;
	
	public class FriendsForluckPanel extends BasePanel
	{
		public var luckWords:Array;
		private var headerText:TextField;
		private var radios:RadioButtonGroup;
		private var radio1:RadioButton;
		private var radio2:RadioButton;
		private var radio3:RadioButton;
		private var radio4:RadioButton;
		private var radio5:RadioButton;
		private var radio6:RadioButton;
		private var radio7:RadioButton;
		private var customInput:TextInput;
		
		private var sendButton:Button;
		private var cancelButton:Button;
		private var tipText:TextField;
		public function FriendsForluckPanel()
		{
			super();
			width = 450;
			height = 275;
			this.title = "好友祝福";
			luckWords = ["愿快乐幸福的光环缠绕你，送来最真挚的祝福：升级成功！"
				,"问君能有几多愁？恰似偶升级慢过小蜗牛~"
				,"将快乐作为礼物送给你，衷心地祝福你－－升级快乐！"
				,"一级又一级，真诚的祝福传递予你，愿开心、幸福！"
				,"节节高升，愿升级的喜悦永远伴随您！"
				,"加油升级，我就追上来啦！"]
			
			
			var back:Sprite = Style.getBlackSprite(425,206);
			back.x = 12;
			back.y = 2;
			addChild(back);
			
			headerText = ComponentUtil.createTextField("",3,2,null,350,25,back);
			
			radios=new RadioButtonGroup();
			radios.direction=RadioButtonGroup.VERTICAL;
			radios.space = 1;
			radio1 = createRadioButton(10, 0, luckWords[0]);
			radio2 = createRadioButton(10, 0, luckWords[1]);
			radio3 = createRadioButton(10, 0, luckWords[2]);
			radio4 = createRadioButton(10, 0, luckWords[3]);
			radio5 = createRadioButton(10, 0, luckWords[4]);
			radio6 = createRadioButton(10, 0, luckWords[5]);
			radio7 = createRadioButton(10, 0, "");
			radios.addItem(radio1);
			radios.addItem(radio2);
			radios.addItem(radio3);
			radios.addItem(radio4);
			radios.addItem(radio5);
			radios.addItem(radio6);
			radios.addItem(radio7);
			radios.x = 18;
			radios.y = 25;
			radio1.selected = true;
			back.addChild(radios);
			
			customInput = new TextInput();
			customInput.addEventListener(FocusEvent.FOCUS_IN,onFocusIn);
			customInput.maxChars = 30;
			customInput.x = 42;
			customInput.y = 178;
			customInput.width = 353;
			back.addChild(customInput);
			
			sendButton = ComponentUtil.createButton("发送",300,210,66,25,this);
			cancelButton = ComponentUtil.createButton("取消",370,210,66,25,this);
			sendButton.addEventListener(MouseEvent.CLICK,onSendHandler);
			cancelButton.addEventListener(MouseEvent.CLICK,onCancelHandler);
			
			tipText = ComponentUtil.createTextField("",15,213,null,250,25,this);
			tipText.htmlText = HtmlUtil.font("前20个好友祝福，将获得丰厚的经验奖励！","#ffff00");
		}
		
		private function onFocusIn(event:FocusEvent):void{
			radios.selectedIndex = 6;
		}
		
		private function onSendHandler(event:MouseEvent):void{
			var content:String;
			if(radios.selectedIndex >= luckWords.length){
				content = StringUtil.trim(customInput.text);
			}else{
				content = luckWords[radios.selectedIndex];
			}
			if(content == ""){
				Tips.getInstance().addTipsMsg("祝福内容不能为空！");
				return;	
			}
			if(KeyWord.instance().hasUnRegisterString(content)){
				var str:String = KeyWord.instance().takeUnRegisterString(content);	
				Alert.show(str,"温馨提示",null,null,"确定","",null,false);
				return;
			}
			FriendsModule.getInstance().goodLuckToFriend(friendId,content);
			onCancelHandler(null);
		}
		
		private function onCancelHandler(event:MouseEvent):void{
			closeWindow();
			dispose();
		}
		
		private function createRadioButton(x:Number, y:Number, title:String):RadioButton{
			var r:RadioButton=new RadioButton(title);
			r.textFormat=Style.textFormat;
			r.x=x;
			r.y=y;
			return r;
		}
		
		private var friendName:String;
		private var friendId:int;
		public function setFriendInfo(roleName:String,roleId:int,level:int):void{
			this.friendName = roleName;
			this.friendId = roleId;
			headerText.htmlText = "你的好友"+HtmlUtil.font("["+friendName+"]","#ffff00")+"升到"+level+"级了，祝福他（她）：";
			
		}
	}
}