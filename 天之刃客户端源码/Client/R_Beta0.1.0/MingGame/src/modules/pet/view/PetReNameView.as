package modules.pet.view {
	import com.components.alert.Alert;
	import com.components.components.DragUIComponent;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;

	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;

	import modules.broadcast.KeyWord;
	import modules.broadcast.views.Tips;
	import modules.pet.PetModule;

	import proto.line.m_pet_change_name_tos;

	public class PetReNameView extends DragUIComponent {
		private static const defaultStr:String="请输入名字";

		private var _txt:TextField;
		private var _input:TextInput;
		private var sendBtn:Button;
		private var closeBtn:Button;
		private var _closeButton:UIComponent;
		private var regEx:RegExp=/([^\u4e00-\u9fa5a-zA-Z0-9])+/;

		public var pet_id:int;
		private var _pet_name:String;

		public function PetReNameView() {
			super();

			this.width=210;
			this.height=106;
			this.showCloseButton=true;

			ComponentUtil.createTextField("宠物改名：", 70, 4, Style.textFormat, 100, 22, this);

			_txt=ComponentUtil.createTextField("每次改名花费1元宝", 4, 25, Style.textFormat, 140, 22, this);
			_txt.textColor=0x3DEA42;
			_txt.selectable=false;
			_txt.mouseEnabled=false;


			_input=new TextInput();
			_input.x=10;
			_input.y=48 //2;
			_input.width=180;
			_input.height=22;
			_input.maxChars=7; // laba 限40字.
			_input.text=defaultStr;

			addChild(_input);
			_input.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_input.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_input.addEventListener(TextEvent.TEXT_INPUT, onInput);
			_input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);


			sendBtn=new Button();
			sendBtn.x=70;
			sendBtn.y=75;
			sendBtn.width=60;
			sendBtn.height=26;
			sendBtn.label="确定";
			Style.setRedBtnStyle(sendBtn);
			addChild(sendBtn);
			sendBtn.addEventListener(MouseEvent.CLICK, onSend);

			closeBtn=new Button();
			closeBtn.x=140;
			closeBtn.y=75;
			closeBtn.width=60;
			closeBtn.height=26;
			closeBtn.label="取消";
			Style.setRedBtnStyle(closeBtn);
			addChild(closeBtn);
			closeBtn.addEventListener(MouseEvent.CLICK, onCloseHandler);

		}

		public function get pet_name():String {
			return _pet_name;
		}

		public function set pet_name(value:String):void {
			_input.text = value;
			_pet_name=value;
		}

		private function onInput(e:TextEvent):void {
			if (e.text == "\n") {
				e.preventDefault();
			}
		}

		private function onKeyDown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER) {
				sendMsg();
			}
		}

		private function onFocusIn(e:FocusEvent):void {
			if (_input.text == defaultStr)
				_input.text="";
		}

		private function onFocusOut(e:FocusEvent):void {
			if (_input.text == "")
				_input.text=defaultStr;
		}


		private function onSend(e:MouseEvent):void {
			if (pet_name == _input.text) {
				Tips.getInstance().addTipsMsg("宠物名没有修改");
				return;
			}
			sendMsg();
		}

		private function sendMsg():void {

			if (regEx.test(_input.text)) {
				Alert.show("用户名必须是中英文数字的组合", "错误", null, null, "确定", "", null, false);
				_input.text=defaultStr;
				return;
			}
			if (_input.text.length < 2 || _input.text.length > 7) {
				Alert.show("宠物名称长度为2-7个字符", "错误", null, null, "确定", "", null, false);
				_input.text=defaultStr;
				return;
			}
			if (KeyWord.instance().hasUnRegisterString(_input.text)) {
				var str:String=KeyWord.instance().takeUnRegisterString(_input.text);
				Alert.show(str, "温馨提示", null, null, "确定", "", null, false);
				_input.text=defaultStr;
				return;
			}
			var vo:m_pet_change_name_tos=new m_pet_change_name_tos;
			vo.pet_id=pet_id;
			vo.pet_name=_input.text;
			PetModule.getInstance().send(vo);
			_input.text=defaultStr;
			WindowManager.getInstance().closeDialog(this);
		}

		override protected function onCloseHandler(e:MouseEvent):void {
			_input.text="";
			WindowManager.getInstance().closeDialog(this);
		}
	}
}
