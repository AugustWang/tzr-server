package modules.market.view
{
	import com.components.alert.Alert;
	import com.components.components.DragUIComponent;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import modules.broadcast.KeyWord;
	import modules.deal.DealModule;
	import modules.pet.PetModule;
	
	import proto.line.m_pet_change_name_tos;
	import proto.line.p_stall_list_item;
	
	public class SendMsgView extends DragUIComponent
	{
		private static const defaultStr:String = "请输入想对摊主说的话"; 
		
		private var _txt:TextField; 
		private var _input:TextInput;
		private var sendBtn:Button;
		private var closeBtn:Button;
		private var _closeButton:UIComponent;
		private var regEx:RegExp=/([^\u4e00-\u9fa5a-zA-Z0-9])+/;
		//标识是否更改过留意
		private var isChange:Boolean=false;
		
		public var pet_id:int;
		
		public function SendMsgView()
		{
			super();
			
			this.width = 210;
			this.height = 106;
			this.showCloseButton = true;
			
			ComponentUtil.createTextField("发送信息：",70,4,Style.textFormat,100,22,this);
			
			_txt = ComponentUtil.createTextField("XXX",4,25,Style.textFormat,140,22,this);
			_txt.textColor = 0x3DEA42;
			_txt.selectable = false;
			_txt.mouseEnabled = false;
			
			
			_input = new TextInput();
			_input.x = 10;
			_input.y = 48//2;
			_input.width = 180;
			_input.height = 22;
			_input.maxChars = 30 ; // laba 限40字.
			_input.text = defaultStr;
			
			addChild(_input);
			_input.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_input.addEventListener(FocusEvent.FOCUS_OUT , onFocusOut);
			_input.addEventListener(TextEvent.TEXT_INPUT, onInput);
			_input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			
			sendBtn = new Button();
			sendBtn.x = 70;
			sendBtn.y = 75;
			sendBtn.width = 60;
			sendBtn.height = 26;
			sendBtn.label = "确定";
			Style.setRedBtnStyle(sendBtn);
			addChild(sendBtn);
			sendBtn.addEventListener(MouseEvent.CLICK,onSend);
			
			closeBtn = new Button();
			closeBtn.x = 140;
			closeBtn.y = 75;
			closeBtn.width = 60;
			closeBtn.height = 26;
			closeBtn.label = "取消";
			Style.setRedBtnStyle(closeBtn);
			addChild(closeBtn);
			closeBtn.addEventListener(MouseEvent.CLICK,onCloseHandler);
			
		}
		
		private var ownID:p_stall_list_item;
		
		public function set ownerID(owner:p_stall_list_item):void {
			this.ownID = owner;
			_txt.text = this.ownID.role_name;
		}
		
		private function onInput(e:TextEvent):void
		{
			if(e.text == "\n")
			{
				e.preventDefault();
			}
		}
		private function onKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.ENTER)
			{
				sendMsg();
			}
		}
		private function onFocusIn(e:FocusEvent):void
		{
			isChange = true;
			
			if(_input.text == defaultStr)
				_input.text = "";
		}
		private function onFocusOut(e:FocusEvent):void
		{
			if(_input.text == "")
				_input.text = defaultStr;
		}
		
		private var content:String;
		private function onSend(e:MouseEvent):void
		{
			sendMsg();
		}
		
		private var ownerId:int;
		private function sendMsg():void
		{
			if(isChange == false){
				Alert.show("你还没有写留言", "错误", null, null, "确定", "", null, false);
				_input.text = defaultStr;
				return ;
			}
			
			if (_input.text.length < 2 || _input.text.length > 30)
			{
				Alert.show("留言长度必须大于2,小于30", "错误", null, null, "确定", "", null, false);
				_input.text = defaultStr;
				return ;
			}
			content = KeyWord.instance().replace(_input.text,KeyWord.TALK_WORDS);
			var message:String = StringUtil.trim(content);
			DealModule.getInstance().sendMsg(this.ownID.role_id,message);
			_input.text = defaultStr;
			
			isChange = false;
			
			WindowManager.getInstance().closeDialog(this);
		}
		
		override protected function onCloseHandler(e:MouseEvent):void
		{
			_input.text ="" ;
			WindowManager.getInstance().closeDialog(this);
		}
	}
}
