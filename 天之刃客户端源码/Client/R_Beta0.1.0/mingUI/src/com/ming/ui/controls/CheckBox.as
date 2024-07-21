package com.ming.ui.controls
{
	import com.ming.events.ResizeEvent;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.CheckBoxSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class CheckBox extends UIComponent
	{
		public var iconWidth:Number = 17;
		public var iconHeight:Number = 17;
		private var defaultWidth:Number = 80;
		private var defaultHeight:Number = 21;
		private var defaultIconLeft:Number = 0;
		private var defaultSpace:Number = 5;
		
		private var enableChange:Boolean = false;
		private var sizeChange:Boolean = false;
		
		protected var _selected:Boolean;
		private var _enable:Boolean = true;
		private var _showText:Boolean;
		
		private var _text:TextField;
		protected var icon:UIComponent;
		private var _iconLeft:Number = 0;
		private var _space:Number = 0;
		protected var iconSkin:CheckBoxSkin;
		
		public function CheckBox()
		{
			init();
		}
		
		private function init():void
		{
			this.width = defaultWidth;
			this.height = defaultHeight;
			this.buttonMode = true;
			this.useHandCursor = true;
			icon = new UIComponent();
			iconSkin = StyleManager.checkBoxSkin;
			if(iconSkin){
				var unSelectedSkin:Skin = iconSkin.unSelectedSkin;
				if(unSelectedSkin){
					icon.bgSkin = unSelectedSkin;
				}
			}
			sizeChange = true;
			invalidateDisplayList();
			addChild(icon);
			
			this.addEventListener(MouseEvent.CLICK, click);
		}
		
		private var _checkBoxSkin:CheckBoxSkin;
		public function set checkBoxSkin(value:CheckBoxSkin):void{
			iconSkin = value;
			if(iconSkin){
				var unSelectedSkin:Skin = iconSkin.unSelectedSkin;
				if(unSelectedSkin){
					icon.bgSkin = unSelectedSkin;
				}
			}
		}
		
		protected function click(evt:MouseEvent):void
		{
			selected = !selected;
			
			if(selected)
				icon.bgSkin = iconSkin.selectedSkin;
			else
				icon.bgSkin = iconSkin.unSelectedSkin;
		}
		
		public function set iconLeft(value:Number):void
		{
			if(_iconLeft == value)
				return;
			
			_iconLeft = value;
			sizeChange = true;
			invalidateDisplayList();
		}
		
		public function set space(value:Number):void
		{
			if(_space == value)
				return;
			
			this._space = value;
			sizeChange = true;
			invalidateDisplayList();
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		public function set selected(bool:Boolean):void
		{
			if(bool == _selected)
				return;
			
			_selected = bool;
			if(_selected)
				icon.bgSkin = iconSkin.selectedSkin;
			else
				icon.bgSkin = iconSkin.unSelectedSkin;
			icon.validateNow();
			dispatchEvent(new Event(Event.CHANGE));
		}
		/**
		 * 不分发事件的设置选中 
		 */		
		public function setSelected(bool:Boolean):void{
			if(bool == _selected)
				return;
			_selected = bool;
			if(_selected)
				icon.bgSkin = iconSkin.selectedSkin;
			else
				icon.bgSkin = iconSkin.unSelectedSkin;
			icon.validateNow();
		}
		
		public function set enable(bool:Boolean):void
		{
			if(bool == _enable)
				return;
			
			enableChange = true;
			_enable = bool;
			invalidateDisplayList();
		}
		public function get enable():Boolean
		{
			return this._enable;
		}
		
		public function set text(label:String):void
		{
			
			if(_text == null)
				createTextField();
			if(_text.text == label)
				return;
			
			_text.text = label;
			sizeChange = true;
			invalidateDisplayList();
		}
		
		public function get text():String
		{
			if(_text == null)
				return "";
			return _text.text;
		}
		public function set htmlText(label:String):void
		{
			if(_text == null)
				createTextField();
			
			if(_text.htmlText == label)
				return;
			_text.htmlText = label;
			sizeChange = true;
			invalidateDisplayList();
		}
		public function get htmlText():String
		{
			if(_text == null)
				return "";
			return _text.htmlText;
		}
		
		private var _tf:TextFormat;
		public function set textFormat(format:TextFormat):void
		{
			if(_text != null){
				_text.defaultTextFormat = format;
				_text.setTextFormat(format);
			}
			else
				_tf = format;
		}
		
		override public function set width(w:Number):void
		{
			if(super.width == w)
				return;
			sizeChange = true;
			super.width = w;
		}
		override public function set height(h:Number):void
		{
			if(super.height == h)
				return;
			
			sizeChange = true;
			super.height = h;
		}
		private function createTextField() : void
		{
			_text = new TextField();
			_text.mouseEnabled = false;
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.selectable = false;
			_text.defaultTextFormat = _tf == null ? new TextFormat("Tahoma") : _tf;
			addChild(_text);
			sizeChange = true;
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			checkEnable();
			
			checkSize();
		}
		
		private function checkEnable():void
		{
			if(enableChange)
			{
				if(enable)
				{
					this.filters = [];
					this.mouseEnabled = this.mouseChildren = true;
				}
				else
				{
					this.filters = [new ColorMatrixFilter(
										[0.3086, 0.6094, 0.082, 0, 0, 
										 0.3086, 0.6094, 0.082, 0, 0, 
										 0.3086, 0.6094, 0.082, 0, 0, 
										 0, 0, 0, 1, 0
										 ]
										)];
					this.mouseEnabled = this.mouseChildren = false;
				}
			}
			
			enableChange = false;
		}
		
		private function checkSize():void
		{
			if(sizeChange)
			{
				icon.height = iconWidth;
				icon.width = iconHeight;
				
				if(_text == null)
				{
					icon.x = (this.width - icon.width) / 2;
					icon.y = (this.height - icon.height) / 2;
				}
				else
				{
					var left:Number = _iconLeft == 0 ? defaultIconLeft : _iconLeft;
					icon.x = left;
					icon.y = (this.height - icon.height) / 2;
					
					var temp:Number = _space == 0? defaultSpace : _space;
					_text.x = left + icon.width + temp;
					_text.y = (this.height - _text.textHeight - 5) / 2;
					this.width = _text.x + _text.textWidth + temp;
				}
			}
			
			sizeChange = false;
		}
		
		public function set textFilter(_value:Array):void{
			this._text.filters = _value;
		}
	}
}