package com.ming.ui.controls
{
	import com.ming.events.ComponentEvent;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;

	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	public class TextInput extends UIComponent
	{
		private var _textfield:TextField;

		public function TextInput()
		{
			init();
		}

		protected function init():void
		{
			width=100;
			height=22;
			_textfield=new TextField();
			_textfield.textColor=0xffffff;
			_textfield.selectable=true;
			_textfield.type=TextFieldType.INPUT;
			_textfield.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			var borderSkin:Skin=StyleManager.textInputSkin;
			if (borderSkin)
			{
				bgSkin=borderSkin;
			}
			_textfield.addEventListener(Event.CHANGE, onChange);
			addChild(_textfield);
		}

		public function setFocus():void
		{
			if (stage)
			{
				stage.focus=_textfield;
			}
		}

		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ENTER)
			{
				var evt:ComponentEvent=new ComponentEvent(ComponentEvent.ENTER);
				dispatchEvent(evt);
			}
		}

		private var _text:String="";

		public function set text(value:String):void
		{
			if (value != _text)
			{
				_text=value;
				if (_text == null)
					_text="";
				invalidateDisplayList();
			}
		}

		public function get text():String
		{
			return _text;
		}

		public function get textField():TextField
		{
			return _textfield;
		}

		public function set restrict(str:String):void
		{
			_textfield.restrict=str;
		}

		public function get restrict():String
		{
			return _textfield.restrict;
		}

		public function set maxChars(max:int):void
		{
			_textfield.maxChars=max;
		}

		public function get maxChars():int
		{
			return _textfield.maxChars;
		}

		private var _displayAsPassword:Boolean=false;

		public function set displayAsPassword(value:Boolean):void
		{
			if (value != _displayAsPassword)
			{
				_displayAsPassword=value;
				invalidateDisplayList();
			}
		}

		public function get displayAsPassword():Boolean
		{
			return _displayAsPassword;
		}

		private var _enabled:Boolean=true;

		public function set enabled(value:Boolean):void
		{
			_enabled=value;
			mouseEnabled=mouseChildren=value;
			_textfield.tabEnabled=value;
			_textfield.mouseEnabled=value;
			if (value)
			{
				_textfield.type=TextFieldType.INPUT;
			}
			else
			{
				_textfield.type=TextFieldType.DYNAMIC;
			}
			if (bgSkin)
			{
				bgSkin.enableMouse=value;
			}
		}

		public function get enabled():Boolean
		{
			return _enabled;
		}

		private var _borderThickness:Number=1;

		public function set borderThickness(value:Number):void
		{
			if (_borderThickness != value)
			{
				_borderThickness=value;
				invalidateDisplayList();
			}
		}

		private var _leftPadding:int=0;

		public function set leftPadding(value:int):void
		{
			if (_leftPadding != value)
			{
				_leftPadding=value;
				invalidateDisplayList();
			}
		}

		public function get leftPadding():int
		{
			return _leftPadding;
		}

		public function get borderThickness():Number
		{
			return _borderThickness;
		}

		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			_textfield.displayAsPassword=_displayAsPassword;
			_textfield.text=_text;
			_textfield.width=width - 2 * _borderThickness;
			if (_textfield.text == "")
			{
				_textfield.text="   ";
				_textfield.height=Math.min(_textfield.textHeight + 5 + 2 * _borderThickness, height);
				_textfield.text="";
			}
			else
			{
				_textfield.height=Math.min(_textfield.textHeight + 5 + 2 * _borderThickness, height);
			}
			_textfield.x=_borderThickness + leftPadding;
			_textfield.y=Math.round(height / 2 - _textfield.height / 2);
		}

		protected function onChange(event:Event):void
		{
			_text=_textfield.text;
		}
	}
}