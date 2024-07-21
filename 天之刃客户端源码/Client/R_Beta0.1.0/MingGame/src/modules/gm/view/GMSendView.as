package modules.gm.view
{
	import com.common.FilterCommon;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.RadioButton;
	import com.ming.ui.controls.RadioButtonGroup;
	import com.ming.ui.controls.TextArea;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.style.StyleManager;
	import com.utils.ComponentUtil;
	import com.utils.JSUtil;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.gm.GMModule;
	import modules.heroFB.HeroFBModule;
	import modules.heroFB.newViews.items.HeroFBRecordView;
	import modules.pet.newView.PetPanel;
	import modules.pet.newView.items.PetTrainingModelPanel;
	
	import proto.line.m_hero_fb_report_toc;

	public class GMSendView extends BasePanel
	{
		private var titleInput:TextInput;
		private var pushBug:RadioButton;
		private var complaints:RadioButton;
		private var proposal:RadioButton;
		private var other:RadioButton;
		private var radios:RadioButtonGroup;
		private var content:TextArea;
		
		private var selectType:int = 0;
		public function GMSendView()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,onAddToStateHandler);
		}
		
		private function onAddToStateHandler(evt:Event):void{
			if(titleInput){
				titleInput.setFocus();
			}
		}
		
		public function initUI():void{
			this.width = 313;
			this.height = 390;
			addSmaillTitleBG();
			addImageTitle("title_contactGM");
			addContentBG(30,8,0);
			
			this.x = 336;
			this.y = 98;
			//标题
			//背景
			var topbackBg:UIComponent = ComponentUtil.createUIComponent(14,8,286,70);
			Style.setBorderSkin(topbackBg);
			topbackBg.mouseEnabled = false;
			addChild(topbackBg);
			
			var bottombackBg:UIComponent = ComponentUtil.createUIComponent(14,80,286,238);
			Style.setBorderSkin(bottombackBg);
			bottombackBg.mouseEnabled = false;
			addChild(bottombackBg);
			
			//按键
			var closeBtn:Button = ComponentUtil.createButton('关闭',152,321,70,25,this);
			var sendBtn:Button = ComponentUtil.createButton('发信',228,321,70,25,this);
			closeBtn.addEventListener(MouseEvent.CLICK,closeBtnClickHandler);
			sendBtn.addEventListener(MouseEvent.CLICK,sendBtnClickHandler);
			
			//选类型
			pushBug=putRadioButton(40,12,"提交BUG","1");
			complaints=putRadioButton(110,12,"投诉","2");
			proposal=putRadioButton(162,12,"游戏建议","3");
			other=putRadioButton(236,12,"其他","4");
			other.selected = true;
			addChild(pushBug);
			addChild(complaints);
			addChild(proposal);
			addChild(other);
			
			//标题输入
			titleInput = new TextInput();
			titleInput.x = 62;
			titleInput.y = 40;
			titleInput.width = 220;
			//titleInput.height = 25;
			addChild(titleInput);
			
			//输入框
			content = new TextArea();
			addChild(content);
			content.x = 15;
			content.y = 83;
			content.width = 282;
			content.height = 177;
			content.textField.maxChars = 200;
			content.textField.defaultTextFormat = new TextFormat("Tahoma",12,0xffffff);
			content.bgSkin = null;
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.width = 284;
			line.height = 2;
			line.x = 14;
			line.y = 258;
			addChild(line);
			
			ComponentUtil.createTextField('标题：',22,40,StyleManager.textFormat,40,25,this);
			ComponentUtil.createTextField(GameParameters.getInstance().content_1,15,262,StyleManager.textFormat,250,25,this);
			ComponentUtil.createTextField(GameParameters.getInstance().content_2,15,280,StyleManager.textFormat,250,25,this);
			ComponentUtil.createTextField(GameParameters.getInstance().content_3,15,298,StyleManager.textFormat,250,25,this);
			/*addChild(createLinkBtn(255,262,'玩家论坛',Config.BBS_LINK4));
			addChild(createLinkBtn(255,280,'点击充值',Config.GM_LINK2));
			addChild(createLinkBtn(255,298,'联系客服',Config.GM_LINK3));*/
			var tf:TextFormat = new TextFormat('Tahoma',12,0x00ff00,null,null,true)
			var bbs:TextField = ComponentUtil.createTextField("",245,259,tf,70,25,this);//createLinkBtn(255,262,'玩家论坛',"bbs");
			bbs.mouseEnabled = true;
			bbs.htmlText = "<a href='event:bbs'>玩家论坛</a>";
			bbs.filters = FilterCommon.FONT_BLACK_FILTERS;
			bbs.addEventListener(TextEvent.LINK,onClickLinkHandler);
			
			var pay:TextField = ComponentUtil.createTextField("",245,277,tf,70,25,this);//createLinkBtn(255,280,'点击充值',"pay");
			pay.mouseEnabled = true;
			pay.htmlText = "<a href='event:pay'>点击充值</a>";
			pay.filters = FilterCommon.FONT_BLACK_FILTERS;
			pay.addEventListener(TextEvent.LINK,onClickLinkHandler);
			
			var customer:TextField = ComponentUtil.createTextField("",244,296,tf,70,25,this);//createLinkBtn(255,298,'联系客服',"customer"); 
			customer.mouseEnabled = true;
			customer.htmlText = "<a href='event:customer'>联系客服</a>";
			customer.filters = FilterCommon.FONT_BLACK_FILTERS;
			customer.addEventListener(TextEvent.LINK,onClickLinkHandler);
		}
		
		private var rep:RegExp = /\|/g;
		private function onClickLinkHandler(evt:TextEvent):void{
			if(evt.text == "bbs"){
				var bbs:String = GameParameters.getInstance().bbs//.BBS_LINK4;
				bbs = bbs.replace(rep,"&");
				JSUtil.openWebSite(bbs);
			}else if(evt.text == "pay"){
				JSUtil.openPaySite();
			}else if(evt.text == "customer"){
				var cus:String = GameParameters.getInstance().gm_link_3//Config.GM_LINK3;
				cus = cus.replace(rep,"&");
				JSUtil.openWebSite(cus);
			}
		}
		
		public function reset():void{
			titleInput.text = '';
			content.text = '';
			
		}
		
		private function closeBtnClickHandler(event:MouseEvent):void{
			WindowManager.getInstance().removeWindow(this);
		}
		
		private var fcmXML:XML;
		private function sendBtnClickHandler(event:MouseEvent):void{
//			var time:Number = 10000;
//			var s:String = '';
//			time = time*0.001;
//			if(fcmXML == null){
//				var loader:URLLoader = WealthPool.getInstance().remove(Config.FCM) as URLLoader;
//				var byte:ByteArray = loader.data;
//				byte.position = 0;
//				fcmXML = XML(byte.readUTFBytes(byte.length));
//			}
//			if(time < 10800){
//				s = s + fcmXML.content[0].@data.toString() + '<a href="http://www.mingchao.com" target="blank">参与防沉迷认证</a>';
//			}else if(time == 10800){
//				s = s + fcmXML.content[1].@data.toString() + '<a href="http://www.mingchao.com" target="blank">参与防沉迷认证</a>';
//			}else if(10800 < time < 18000){
//				s = s + fcmXML.content[2].@data.toString() + '<a href="http://www.mingchao.com" target="blank">参与防沉迷认证</a>';
//			}else if(time > 18000){
//				s = s + fcmXML.content[3].@data.toString() + '<a href="http://www.mingchao.com" target="blank">参与防沉迷认证</a>';
//			}
//			SpeakerView.getInstance().appMsgRole(null);
//			SpeakerView.getInstance().appendMsg(s);
//			BroadcastSelf.getInstance().appendMsg(s);
//			var vo:m_system_fcm_toc = new m_system_fcm_toc();
//			vo.info = "请尽快更新你的防乘幂资料,未录入防乘幂资料的玩家,按照国家有关规定";
//			vo.total_time = 7850;
//			vo.remain_time = 7850;
//			SystemModel.getInstance().showFCMInfo(vo);
//			return;
//			var h:PetTrainingModelPanel = new PetTrainingModelPanel();
//			WindowManager.getInstance().popUpWindow(h);
//			WindowManager.getInstance().centerWindow(h);
//			return;
			if(titleInput.text == null || titleInput.text.length < 5){
				Alert.show("标题不能少于5个字符！", "提示",null,null,"确定","取消",null,false);
				//标题不能少于5个字符
				return;
			}
			if(content.text == null || content.text.length < 10){
				Alert.show("内容不能少于10个字符！", "提示",null,null,"确定","取消",null,false);
				//内容不能少于10个字符
				return;
			}
			GMModule.getInstance().send(titleInput.text,content.text,selectType);
		}
		
		private function selectChange(event:Event):void{
			var radio:RadioButton = event.target as RadioButton;
			if(!radio.selected)return;
			if(pushBug.selected && radio.name != pushBug.name)pushBug.selected = false;
			if(complaints.selected && radio.name != complaints.name)complaints.selected = false;
			if(proposal.selected && radio.name != proposal.name)proposal.selected = false;
			if(other.selected && radio.name != other.name)other.selected = false;
			selectType = int(radio.name);
		}
		
		private function putRadioButton(x:Number,y:Number,title:String,name:String):RadioButton
		{
			var r:RadioButton=new RadioButton(title);
			r.name = name;
			r.textFormat=StyleManager.textFormat;
			r.x = x;
			r.y = y;
			r.addEventListener(Event.CHANGE,selectChange);
			return r;
		}
		
		/*private function createLinkBtn(x:Number,y:Number,label:String,link:String):TextField{
			var t:TextField = new TextField();
			t.defaultTextFormat = new TextFormat('Tahoma',12,0x00ff00,null,null,true);
			t.htmlText = "<a href='event:'"+link+"'>"+label+"</a>";
			t.x = x;
			t.y = y;
			t.height = 26;
			return t;
		}*/
	}
}