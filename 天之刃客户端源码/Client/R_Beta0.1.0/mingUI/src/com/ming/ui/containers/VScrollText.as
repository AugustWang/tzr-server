package com.ming.ui.containers
{
	import com.ming.events.ResizeEvent;
	import com.ming.ui.skins.ScrollBarSkin;
	import com.ming.ui.style.StyleManager;
	
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class VScrollText extends VScrollCanvas
	{
		private var _textField:TextField;
		public function VScrollText()
		{
			super();
			this.mouseEnabled=false;
			init();
		}
		
		protected function init():void{
			_textField = new TextField();
			_textField.selectable = false;
			_textField.wordWrap = true;
			_textField.multiline = true;
			_textField.mouseWheelEnabled = false;
			_textField.defaultTextFormat = new TextFormat("Tahoma",12,0x000000);
			text = " ";
			addChild(_textField);
		}
		
		public function set selectable(value:Boolean):void{
			_textField.selectable = value;
		}
		
		public function get selectable():Boolean{
			return _textField.selectable;
		}
		
		override public function set width(value:Number):void
		{
			super.width=value
			this._textField.width=value	
		
		}
		public function set selecteable(value:Boolean):void{
			_textField.selectable = value;
		}
		
		public function get textField():TextField{
			return _textField;
		}
		
		private var heightChanged:Boolean = false;
		public function set text(value:String):void{
			_textField.text = value;
			heightChanged = true;
			invalidateDisplayList();
		}
		
		public function get text():String{
			return _textField.text;
		}
		
		public function set htmlText(value:String):void{
			_textField.htmlText = value;
			heightChanged = true;
			invalidateDisplayList();
		}
		
		public function get htmlText():String{
			return _textField.htmlText;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			if(heightChanged){
				heightChanged = false;
				_textField.height = _textField.textHeight + 4;
				updateScrollBar();
			}
		}
		
		override protected function updatePosition():void{
			super.updatePosition();
			if(vscrollBar){
				_textField.width = width - vscrollBar.width;
			}
		}
		
		override protected function getContentSize():Array{
			return [_textField.width,_textField.height];
		}
	}
}