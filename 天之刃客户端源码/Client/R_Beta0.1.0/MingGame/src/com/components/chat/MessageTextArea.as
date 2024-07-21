package com.components.chat
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import modules.chat.ChatModule;
	import modules.chat.ChatType;
	
	import proto.common.p_chat_role;

	/**
	 * 消息文本
	 */ 
	public class MessageTextArea extends Sprite
	{
		private var _maxChars:int = 80;
		private var _defaultText:String = "请在这里输入聊天内容";
		private var txt:TextField;
		private var _color:uint = 0xffffff;
		private var _text:String;
		private var _width:Number;
		private var _height:Number;
		public var enterFunc:Function;
		public function MessageTextArea()
		{
			super();
			txt = new TextField();
			var tf:TextFormat = Style.textFormat;
			txt.defaultTextFormat = tf;
			tf.color = txt.textColor = 0xffffff;
			txt.type = "input";
			txt.maxChars = maxChars;
			txt.text = defaultText;
			txt.addEventListener(KeyboardEvent.KEY_DOWN,onKeyUp);
			txt.addEventListener(TextEvent.TEXT_INPUT,onTextInput);
			txt.addEventListener(Event.CHANGE,onTextChanged);
			txt.addEventListener(FocusEvent.FOCUS_IN,onFocusIn);
			txt.addEventListener(FocusEvent.FOCUS_OUT,onFocusOut);
			addChild(txt);
			this.addEventListener(Event.ADDED_TO_STAGE,onAddListen);
		}
		
		public function set multiline(value:Boolean):void{
			if(value){
				txt.multiline = true;
				txt.wordWrap = true;
			}	
		}
		
		private function onAddListen(e:Event):void
		{
			addStageListener();
			
		}
//		private function ontxtfocus(evt:KeyboardEvent):void
//		{
//			if(evt.keyCode == Keyboard.ENTER)
//			{	
//				if(stage)
//				{
//					stage.removeEventListener(KeyboardEvent.KEY_UP,ontxtfocus);
//				}
//				setFocus();
//			}
//		}
		
		
		public function get textField():TextField
		{
			return txt;
		}
		
		public function set maxChars(value:int):void{
			_maxChars = value;
			txt.maxChars = value;
		}
		public function get maxChars():int{
			return _maxChars;
		}
		
		public function set defaultText(value:String):void{
			_defaultText = value;
			txt.text = _defaultText;
			sureText = txt.text;
		}
		
		public function get defaultText():String{
			return _defaultText;
		}
		
		override public function set width(value:Number):void{
			this._width = value;
			txt.width = value;
		}
		override public function get width():Number{
			return this._width;
		}
		
		override public function set height(value:Number):void{
			this._height = value;
			txt.height = value;
		}
		override public function get height():Number{
			return this._height;
		}	
		
		public function set color(value:uint):void{
			_color = value;
			txt.textColor = value;
		}
		
		public function get color():uint{
			return this._color;
		}
		
		public function set text(value:String):void{
			txt.text = value;
			sureText = txt.text;
		}
		
		public function get text():String{
			var textStr:String = txt.text.replace(/\r/g, "");
			return textStr;
		}
		
		public function appendText(_text:String):void
		{
			if(text == defaultText){
				text = "";
			}			
			txt.appendText(_text);	
			sureText = txt.text;
		}
		
		private function onFocusIn(event:FocusEvent):void{
			if(text == defaultText){
				text = "";
			}
			
			setTimeout(removeStageListener,300);
//			if(stage.hasEventListener(KeyboardEvent.KEY_UP))
//			{
//				stage.removeEventListener(KeyboardEvent.KEY_UP,onFocusHandler);
//			}
		}
		
		private function onFocusOut(event:FocusEvent):void{
			if(text == ""){
				text = defaultText;
			}	
			
			setTimeout(addStageListener,300);
		}
		
		private function onTextInput(event:TextEvent):void{
			if(event.text == "\n"){
				event.preventDefault();
			}	
		}
		
		private var sureText:String = "";
		private function onTextChanged(event:Event):void{
			sureText = txt.text;
		}
		
		private function onKeyUp(event:KeyboardEvent):void{
			if(sureText != txt.text)return; //以此来确保是否使用了中文输入法，并且是要输入英文。
			if (event.keyCode == Keyboard.ENTER)
			{
				if(txt.text !='')
				{
					if(txt.text.indexOf("/")==0 && ChatModule.getInstance().chat.lastPriMemver)
					{
						var tmpArr:Array = txt.text.split(" ");
						var last:p_chat_role = ChatModule.getInstance().chat.lastPriMemver;
						if("/"+last.rolename == tmpArr[0]&& tmpArr.length==2 && tmpArr[1]=="")
						{
							stage.focus = stage;
//							if(IME.enabled)
//								IME.enabled = false;
//							setTimeout(addStageListener,100);
							return;
						}
						
					}
					
					if(enterFunc != null){
						enterFunc();
					} 
				}else
				{
					
					stage.focus = stage;
//					if(IME.enabled)
//						IME.enabled = false;
//					setTimeout(addStageListener,100);
				}
			}
			
			if(event.keyCode == Keyboard.BACKSPACE)
			{
				if(txt.text == "")
				{
					trace("currentChannel::"+ChatModule.getInstance().chat.currentChannel);
//					if(ChatModel.getInstance().chat.currentChannel == ChatType.PRIVATE_CHANNEL)
//					{
//						ChatModel.getInstance().chat.addPriMember(null);
//					}
				}
			}
			
		}
		
		private function addStageListener():void
		{
//			if(!stage.hasEventListener(KeyboardEvent.KEY_UP))
			if(stage)
			stage.addEventListener(KeyboardEvent.KEY_UP,onFocusHandler);
		}
		
		private function removeStageListener():void
		{
//			if(stage.hasEventListener(KeyboardEvent.KEY_UP))
			if(stage)
			stage.removeEventListener(KeyboardEvent.KEY_UP,onFocusHandler);
		}
		
		private function onFocusHandler(evt:KeyboardEvent):void
		{
			var txt:TextField = evt.target as TextField;
			if(txt && txt.type == TextFieldType.INPUT)
				return;
			
			if(evt.keyCode == Keyboard.ENTER && stage)
			{
//				removeStageListener();
				setFocus();
			}
		}
		
		public function getFoucs():void{
			if(stage){
				stage.focus = txt;
			}
		}
		
		public function setFocus():void
		{
			var last:p_chat_role = ChatModule.getInstance().chat.lastPriMemver;
			stage.focus = txt;
			
			if(last)
			{
				if(txt.text == "/"+last.rolename+" "|| txt.text == "/"+last.rolename)
				{
					txt.text = "/"+last.rolename+" "
					txt.setSelection(txt.text.length,txt.text.length);
				}
			}
			
		}
	}
}