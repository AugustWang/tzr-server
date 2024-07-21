package modules.chat.views
{
	import com.components.components.DragUIComponent;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import modules.chat.ChatModule;
	
	public class HornInput extends DragUIComponent
	{
		private static const defaultStr:String = "请输入文字"; 
		
		private var _txt:TextField; 
		private var _input:TextInput;
		private var sendBtn:Button;
		private var _closeButton:UIComponent;
		
		private var laba_id:int;
		public function HornInput()
		{
			super();
			initView();
		}
		
		private function onAddToStage(e:Event):void
		{
			if(_input)
			{
				_input.setFocus();
				_input.validateNow();
				_input.textField.setSelection(0,_input.text.length);
			}
		}
		
		private function initView():void
		{
			this.width = 260;
			this.height = 80;
			this.showCloseButton = true;
			
			_txt = ComponentUtil.createTextField("使用喇叭：",7,15,Style.textFormat,100,22,this);
			_txt.filters = [new GlowFilter(0x000000, 1, 2, 2, 20)];
			_txt.selectable = false;
			_txt.mouseEnabled = false;
			
			_input = new TextInput();
			_input.x = 8;
			_input.y = 38//2;
			_input.width = 180;
			_input.height = 22;
			_input.maxChars = 40 ; // laba 限40字.
			_input.text = defaultStr;
			
			addChild(_input);
			_input.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_input.addEventListener(FocusEvent.FOCUS_OUT , onFocusOut);
			_input.addEventListener(TextEvent.TEXT_INPUT, onInput);
			_input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			sendBtn = new Button();
			sendBtn.x = 191;
			sendBtn.y = 36;
			sendBtn.width = 60;
			sendBtn.height = 26;
			sendBtn.label = "发送";
			Style.setRedBtnStyle(sendBtn);
			addChild(sendBtn);
			sendBtn.addEventListener(MouseEvent.CLICK,onSend);
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
			if(_input.text == defaultStr)
				_input.text = "";
		}
		private function onFocusOut(e:FocusEvent):void
		{
			if(_input.text == "")
				_input.text = defaultStr;
		}
		
		public function set goodsId(value:int):void
		{
			laba_id = value;
		}
		
		private function onSend(e:MouseEvent):void
		{
			sendMsg();
		}
		
		private function sendMsg():void
		{
			if(_input.text =="" || _input.text ==defaultStr)
			{
				_input.text = defaultStr;
				return;
			}
			
			ChatModule.getInstance().hornSend(_input.text,laba_id);
			WindowManager.getInstance().closeDialog(this);
		}
		
		override protected function onCloseHandler(e:MouseEvent):void
		{
			_input.text ="" ;
			WindowManager.getInstance().closeDialog(this);
		}
	}
}

