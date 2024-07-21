package com.ming.ui.controls
{
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class Text extends UIComponent
	{
		protected var _textfield:TextField;
		protected var displayAsHtml:Boolean = false;
		public function Text()
		{
			init();
		}
		
		protected function init():void
		{
			width = 200;
			height = 100;
			_textfield = new TextField();
			_textfield.x = 2;
			_textfield.y = 2;
			_textfield.textColor = 0xffffff;
			_textfield.height = height;
			_textfield.multiline = true;
			_textfield.wordWrap = true;
			_textfield.selectable = true;
			_textfield.defaultTextFormat = new TextFormat("Tahoma",12,0xffffff);
			_textfield.type = TextFieldType.INPUT;
			_textfield.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			_textfield.addEventListener(Event.CHANGE, onTextChange);
			addEventListener(Event.CHANGE, onChange);
			addChild(_textfield);
			
		}
		
		public function setFocus():void{
			if(stage){
				stage.focus = _textfield;
			}
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			resizeTextField();
			if(displayAsHtml && _textfield.htmlText != _htmlText){
				_textfield.htmlText = _htmlText;
				dispatchEvent(new Event(Event.CHANGE));
			}else if(_textfield.text != _text){
				_textfield.text = _text;
				dispatchEvent(new Event(Event.CHANGE));
			}
			if(_editable){
				_textfield.mouseEnabled = true;
				_textfield.selectable = true;
				_textfield.type = TextFieldType.INPUT;
			}
			else{
				_textfield.mouseEnabled = _selectable;
				_textfield.selectable = _selectable;
				_textfield.type = TextFieldType.DYNAMIC;
			}
		}
		
		protected function resizeTextField():void{
			_textfield.width = width - 2*borderThickness;
			_textfield.height = height - 2*borderThickness;
		}
		
		protected function onTextChange(event:Event):void{
			_text = _textfield.text;			
		}

		protected function onChange(event:Event):void{
			
		}
		
		protected function onTextInput(event:TextEvent):void{
			
		}
		
		private var _borderThickness:Number = 1;
		public function set borderThickness(value:Number):void{
			if(_borderThickness != value){
				_borderThickness = value;
				invalidateDisplayList();
			}
		}
		public function get borderThickness():Number{
			return _borderThickness;	
		}
		
		private var _text:String = "";
		public function set text(value:String):void{
			if(value != _text){
				_text = value;
				if(_text == null) _text = "";
				displayAsHtml = false;
				invalidateDisplayList();
			}
		}
		
		public function get text():String{
			return _text;
		}
		
		private var _htmlText:String = "";
		public function set htmlText(value:String):void{
			if(value != _htmlText){
				_htmlText = value;
				if(_htmlText == null) _htmlText = "";
				displayAsHtml = true;
				invalidateDisplayList();
			}
		}
		public function get htmlText():String{
			return _htmlText;
		}
		
		public function get textField():TextField{
			return _textfield;
		}
		
		private var _editable:Boolean = true;
		public function set editable(value:Boolean):void{
			if(value != _editable){
				_editable = value;
				invalidateDisplayList();
			}
		}
		public function get editable():Boolean{
			return _editable;
		}
		
		private var _selectable:Boolean = true;
		public function set selectable(value:Boolean):void{
			if(value != _selectable){
				_selectable = value;
				invalidateDisplayList();
			}
		}
		public function get selectable():Boolean{
			return _selectable;
		}
		
		private var _enabled:Boolean = true;
        public function set enabled(value:Boolean):void
        {
			_enabled = value;
			mouseEnabled = mouseChildren = value;
			_textfield.tabEnabled = value;
			_textfield.mouseEnabled = value;
			if(value){
				_textfield.type = TextFieldType.INPUT;
			}else{
				_textfield.type = TextFieldType.DYNAMIC;
			}
			if(bgSkin){
				bgSkin.enableMouse = value;
			}
        }
		
		public function get enabled():Boolean{
			return _enabled;
		}

	}
}