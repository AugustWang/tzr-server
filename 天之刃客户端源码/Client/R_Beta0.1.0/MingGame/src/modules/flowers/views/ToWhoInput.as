package modules.flowers.views
{
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import modules.flowers.FlowerModule;
	
	public class ToWhoInput extends DragUIComponent
	{
		private var decsTf:TextField;//请输入收花人的角色名（可以是自己）
		private var txtInput:TextInput;
		private var sendBtn:Button;
		private var cancelBtn:Button;
		public function ToWhoInput()
		{
			super();
			this.width = 307;
			this.height = 135;
			Style.setRectBorder(this);
			this.showCloseButton = true;
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.width = 254;
			line.height = 2;
			line.x = 3;
			line.y = 33;
			addChild(line);
			
			initView();
			addEventListener(Event.ADDED_TO_STAGE,onaddtostage);
		}
		
		private function onaddtostage(e:Event):void
		{
			if(txtInput)
			{
				txtInput.setFocus();
				txtInput.validateNow();
			}
		}
		
		private function initView():void
		{
			var txtformat:TextFormat = new TextFormat("Tahoma",15,0xF6F5CD);
			decsTf = ComponentUtil.createTextField("请输入收花人的角色名（可以是自己）：",14,6,txtformat,265,23,this);
			
			txtInput = new TextInput();
			txtInput.x = 50;
			txtInput.y = 47;
			txtInput.width = 200;
			txtInput.height = 25;
			txtInput.maxChars = 7;
			
			addChild(txtInput);
			txtInput.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEnter);
			
			sendBtn = ComponentUtil.createButton("送花",60,89, 66,25, this);
			sendBtn.addEventListener(MouseEvent.CLICK,onSendFlower);
			
			cancelBtn = ComponentUtil.createButton("取消",180,89, 66,25, this);
			cancelBtn.addEventListener(MouseEvent.CLICK, onCancel);
		}
		private function onKeyEnter(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.ENTER)
				onSendFlower();
		}
		
		private function onSendFlower(e:MouseEvent = null):void
		{
			//model. openInputToWho(); //300 148
			var role_name:String = StringUtil.trim(txtInput.text); 
			if(role_name=="")
				return;
			
			FlowerModule.getInstance().requestToWhow_tos(role_name);
		}
		
		private function onCancel(e:MouseEvent):void
		{
			var evt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(evt);
			if(this.parent)
				this.parent.removeChild(this);
		}
		
		override protected function onCloseHandler(event:MouseEvent):void
		{
			var e:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(e);
			if(this.parent)
				this.parent.removeChild(this);
		}
		
		override public function dispose():void
		{
			super.dispose();
			if(sendBtn&&sendBtn.hasEventListener(MouseEvent.CLICK))
			{
				sendBtn.removeEventListener(MouseEvent.CLICK,onSendFlower);
				cancelBtn.removeEventListener(MouseEvent.CLICK, onCancel);
			}
			while(numChildren>0)
			{
				var obj:DisplayObject = getChildAt(0) as DisplayObject;
				
				removeChild(obj);
				obj = null;
			}
		}
		
		
	}
}



