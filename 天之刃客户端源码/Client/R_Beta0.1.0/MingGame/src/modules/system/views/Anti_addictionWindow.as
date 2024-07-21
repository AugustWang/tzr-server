package modules.system.views
{
	
	import com.components.BasePanel;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.KeyUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.system.Anti_addiction;
	
	import proto.line.m_system_fcm_toc;

	public class Anti_addictionWindow extends BasePanel
	{
		//UI组件
		private var content:TextField;
		private var infoTectA:TextField;
		private var nameInput:TextInput;
		private var idInput:TextInput;
		private var sendBtn:Button;
		private var anti:Anti_addiction;
		private var errorText:TextField;
		
		public function Anti_addictionWindow()
		{
			anti = new Anti_addiction();
			anti.complete = complete;
			anti.error = error;
			initUI();
		}
		private function createBorder(w:Number,h:Number,x:int,y:int):UIComponent{
			var border:UIComponent = new UIComponent();
			Style.setBorderSkin(border);
			border.x=x;
			border.y=y;
			border.width = w;
			border.height = h;
			border.mouseChildren=false;
			border.mouseEnabled=false
			addChild(border);
			return border;
		}
		private function initUI():void{
			KeyUtil.getInstance().addKeyHandler(anti_Check,[Keyboard.ENTER]);
			this.width = 518;
			this.height = 433;
			addImageTitle("title_fcm");
			addContentBG(88);
			
			var tf:TextFormat = Style.themeTextFormat;
			tf.leading = 4;
			tf.size = 13;
			content = ComponentUtil.createTextField("",30,10,tf,471,280,this);
			content.multiline = true;
			content.wordWrap = true;
			content.htmlText = "按照版署《网络游戏未成年人防沉迷系统》要求：\n"+
							"\t\t为预防青少年过度游戏，未满18岁的用户和身份信息不完整的用户将受"+
							"到防沉迷系统的限制，《天之刃》积极响应国家新闻出版总署防沉迷政策需"+
							"求，开发出网页游戏防沉迷系统。年龄已满18周岁的玩家，在填写身份证资"+
							"料后，可以不受防沉迷系统影响，自由进行游戏，<font color='#ffff00'>否则游戏每在线3个小时"+
							"必须下线休息5小时</font>。\n"+
							"\t\t说明：系统只支持输入15位或18位的中国身份证号码，持有其他证件"+
							"（如：外国护照，军人证，等）者，请与客服GM联系处理。\n"+
							"\t\t填写身份信息将使我们可以对您的年龄做出判断，以确定您的游戏时间"+
							"是否需要按照国家新闻出版总署的要求纳入防沉迷系统的管理。\n"+
							"\t\t<font color='#ffff00'>隐私说明</font>：用户填写的身份信息属于用户隐私。《天之刃》游戏绝对尊"+
							"重用户个人隐私权。所以，《天之刃》游戏绝不会公开，编辑或透露用户的"+
							"信息内容，除非有法律许可及公安管理规定。</pre>";
			
			infoTectA = ComponentUtil.createTextField("",155,280,new TextFormat("宋体",12,0xD0B58A),270,90,this);//y=15
			errorText = ComponentUtil.createTextField("",18,355,new TextFormat("宋体",12,0xFF0000),300,30,this);//68
			ComponentUtil.createTextField("真实姓名:",18,330,new TextFormat("宋体",12,0xffffff),300,30,this);//92
			ComponentUtil.createTextField("身份证:",279,330,new TextFormat("宋体",12,0xffffff),300,30,this);//122
			
			var tipName:TextField=ComponentUtil.createTextField("例如： 李四",18,305,new TextFormat("宋体",12,0xffffff),200,30,this);//后来挤进来的提示语句
			tipName.mouseEnabled=true;
			tipName.selectable=true;
			var tipID:TextField=ComponentUtil.createTextField("例如： 440106198101010155",130,305,new TextFormat("宋体",12,0xffffff),200,30,this);//
			tipID.mouseEnabled=true;
			tipID.selectable=true;
			
			infoTectA.multiline=true;
			infoTectA.wordWrap=true;
			nameInput = new TextInput();
			nameInput.maxChars = 30;
			nameInput.width = 160;
			nameInput.x = 85;
			nameInput.y = 330//90;
			addChild(nameInput);
			idInput = new TextInput();
			idInput.maxChars = 18;
			idInput.width = 160;
			idInput.x = 331;
			idInput.y = 330//120;
			addChild(idInput);
			sendBtn = new Button();
			sendBtn.width = 70;
			sendBtn.height = 25;
			sendBtn.label = '验证';
			sendBtn.addEventListener(MouseEvent.CLICK,send);
			sendBtn.x  = 415;
			sendBtn.y = 358;
			addChild(sendBtn);
		}
		
		public function resetUI():void{
			nameInput.text = '';
			idInput.text = '';
			errorText.text = '';
		}
		
		
		public function setValue(value:m_system_fcm_toc):void{
			if (value.total_time >= 3600) {
				infoTectA.htmlText = "<font color='#FFFF00'>您累积在线时间已满1小时</font>";
				BroadcastSelf.getInstance().appendMsg( "<font color='#FFFF00'>您累积在线时间已满1小时</font>");
			} else if(value.total_time >= 7200) {
				infoTectA.htmlText = "<font color='#FFFF00'>您累积在线时间已满2小时</font>";
				BroadcastSelf.getInstance().appendMsg( "<font color='#FFFF00'>您累积在线时间已满2小时</font>");
			}
			//infoTectA.htmlText = "<font color='#FFFF00'>由于您未通过防沉迷认证，每天连续在线超过3小时将会被强制下线，请及时进行防沉迷。</font>"; 
		}

		
		private function send(event:MouseEvent):void{
			anti_Check();
		}
		
		private function anti_Check():void{
			anti.check(idInput.text,nameInput.text);
		}
		
		override public function closeWindow(save:Boolean=false):void{
			WindowManager.getInstance().closeDialog(this);
			KeyUtil.getInstance().removeKeyHandler(anti_Check);
		}
		
		public function complete():void{
			closeWindow();
		}
		
		public function error(value:String):void{
			errorText.text = value;
		}
	}
}